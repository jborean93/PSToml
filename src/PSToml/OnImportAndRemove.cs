using System;
using System.IO;
using System.Management.Automation;
using System.Reflection;
using System.Runtime.Loader;

namespace PSToml;

internal class PSTOMLResolver : AssemblyLoadContext
{
    private readonly string _assemblyDir;

    public PSTOMLResolver(string assemblyDir)
    {
        _assemblyDir = assemblyDir;
    }

    protected override Assembly? Load(AssemblyName assemblyName)
    {
        string asmPath = Path.Join(_assemblyDir, $"{assemblyName.Name}.dll");
        if (File.Exists(asmPath))
        {
            return LoadFromAssemblyPath(asmPath);
        }
        else
        {
            return null;
        }
    }
}

public class OnModuleImportAndRemove : IModuleAssemblyInitializer, IModuleAssemblyCleanup
{
    private static readonly string _assemblyDir = Path.GetDirectoryName(
        typeof(PSTOMLResolver).Assembly.Location)!;

    private static readonly PSTOMLResolver _alc = new PSTOMLResolver(_assemblyDir);

    public void OnImport()
    {
        AssemblyLoadContext.Default.Resolving += ResolveAlc;
    }

    public void OnRemove(PSModuleInfo module)
    {
        AssemblyLoadContext.Default.Resolving -= ResolveAlc;
    }

    private static Assembly? ResolveAlc(AssemblyLoadContext defaultAlc, AssemblyName assemblyToResolve)
    {
        string asmPath = Path.Join(_assemblyDir, $"{assemblyToResolve.Name}.dll");
        if (IsSatisfyingAssembly(assemblyToResolve, asmPath))
        {
            return _alc.LoadFromAssemblyName(assemblyToResolve);
        }
        else
        {
            return null;
        }
    }

    private static bool IsSatisfyingAssembly(AssemblyName requiredAssemblyName, string assemblyPath)
    {
        if (requiredAssemblyName.Name == "PSToml.Shared" || !File.Exists(assemblyPath))
        {
            return false;
        }

        AssemblyName asmToLoadName = AssemblyName.GetAssemblyName(assemblyPath);

        return string.Equals(asmToLoadName.Name, requiredAssemblyName.Name, StringComparison.OrdinalIgnoreCase)
            && asmToLoadName.Version >= requiredAssemblyName.Version;
    }
}
