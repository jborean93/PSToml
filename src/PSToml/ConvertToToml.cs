using System;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;
using System.Numerics;
using Tomlyn;
using Tomlyn.Model;

namespace PSToml;

[Cmdlet(VerbsData.ConvertTo, "Toml")]
[OutputType(typeof(string))]
public sealed class ConvertToTomlCommand : PSCmdlet
{
    [Parameter(
        Mandatory = true,
        Position = 0,
        ValueFromPipeline = true,
        ValueFromPipelineByPropertyName = true
    )]
    public object[] InputObject { get; set; } = Array.Empty<object>();

    [Parameter]
    public int Depth { get; set; } = 2;

    protected override void ProcessRecord()
    {
        foreach (object input in InputObject)
        {
            string res;
            bool wasTruncated = false;
            try
            {
                TomlConverter converter = new(Depth);
                TomlTable model = converter.ConvertToToml(input);
                wasTruncated = converter.WasTruncated;

                res = Toml.FromModel(model);
            }
            catch (Exception e)
            {
                WriteError(new ErrorRecord(
                    e,
                    "InputObjectInvalid",
                    ErrorCategory.InvalidArgument,
                    input
                ));
                continue;
            }

            if (wasTruncated)
            {
                WriteWarning($"Resulting TOML is truncated as serialization has exceeded the set depth of {Depth}");
            }

            WriteObject(res);
        }
    }
}

internal sealed class TomlConverter
{
    public int Depth { get; }
    public bool WasTruncated { get; set; }

    public TomlConverter(int depth)
    {
        Depth = depth;
    }

    public TomlTable ConvertToToml(object? inputObject)
    {
        object rawModel = ConvertToTomlObject(inputObject, Depth);
        if (rawModel is not TomlTable model)
        {
            throw new ArgumentException("Input object must be a dictionary like object.");
        }

        return model;
    }

    private object ConvertToTomlObject(object? inputObject, int depth)
    {
        if (inputObject == null)
        {
            return "";
        }

        if (depth < 0)
        {
            WasTruncated = true;
            return CastToString(inputObject);
        }

        return inputObject switch
        {
            IDictionary dict => ConvertToTomlTable(dict, depth),
            IList array => ConvertToTomlArray(array, depth),
            _ => ConvertToTomlFriendlyObject(inputObject, depth),
        };
    }

    private TomlObject ConvertToTomlArray(IList array, int depth)
    {
        List<object> results = new(array.Count);
        bool isTableArray = array.Count > 0;

        foreach (object value in array)
        {
            object toSerialize = ConvertToTomlObject(value, depth - 1);

            if (toSerialize is not TomlTable tt)
            {
                isTableArray = false;
            }

            results.Add(toSerialize);
        }

        if (isTableArray)
        {
            TomlTableArray ta = new();
            foreach (object v in results)
            {
                ta.Add((TomlTable)v);
            }

            return ta;
        }
        else
        {
            TomlArray a = new();
            foreach (object v in results)
            {
                a.Add(v);
            }

            return a;
        }
    }

    private TomlTable ConvertToTomlTable(IDictionary dict, int depth)
    {
        TomlTable model = new(inline: false);
        foreach (DictionaryEntry entry in dict)
        {
            object value = ConvertToTomlObject(entry.Value, depth - 1);
            model.Add(CastToString(entry.Key), value);
        }

        return model;
    }

    private object ConvertToTomlFriendlyObject(object obj, int depth)
    {
        if (obj is PSObject psObj)
        {
            obj = psObj.BaseObject;
        }
        else
        {
            psObj = PSObject.AsPSObject(obj);
        }

        if (obj is char || obj is Guid)
        {
            return CastToString(obj);
        }
        else if (obj is Enum enumObj)
        {
            object rawEnum = Convert.ChangeType(enumObj, enumObj.GetTypeCode());
            if (rawEnum is ulong ul && ul > long.MaxValue)
            {
                return ul.ToString();
            }
            else
            {
                return rawEnum;
            }
        }
        else if (obj is nint ptr)
        {
            return (long)ptr;
        }
        else if (obj is nuint uptr)
        {
            ulong uptrValue = uptr;
            if (uptrValue <= long.MaxValue)
            {
                return (long)uptr;
            }
            else
            {
                return uptrValue.ToString();
            }
        }
        else if (obj is BigInteger bi)
        {
            if (bi >= long.MinValue && bi <= long.MaxValue)
            {
                return (long)bi;
            }
            else
            {
                return bi.ToString();
            }
        }
        else if (obj is ulong ul && ul > long.MaxValue)
        {
            return ul.ToString();
        }
#if NET8_0_OR_GREATER
        else if (obj is Int128 int128)
        {
            if (int128 >= long.MinValue && int128 <= long.MaxValue)
            {
                return (long)int128;
            }
            else
            {
                return int128.ToString();
            }
        }
        else if (obj is UInt128 uint128)
        {
            if (uint128 <= long.MaxValue)
            {
                return (ulong)uint128;
            }
            else
            {
                return uint128.ToString();
            }
        }
#endif

        if (
            obj is bool ||
            obj is DateTime ||
            obj is DateTimeOffset ||
            obj is sbyte ||
            obj is byte ||
            obj is short ||
            obj is ushort ||
            obj is int ||
            obj is uint ||
            obj is long ||
            obj is ulong ||
            obj is float ||
            obj is double ||
            obj is string
        )
        {
            return obj;
        }

        TomlTable model = new();
        foreach (PSPropertyInfo prop in psObj.Properties)
        {
            object? propValue = null;
            try
            {
                propValue = prop.Value;
            }
            catch (GetValueInvocationException e)
            {
                propValue = e.Message;
            }

            model[prop.Name] = ConvertToTomlObject(propValue, depth - 1);
        }

        return model;
    }

    private static string CastToString(object? obj)
        => LanguagePrimitives.ConvertTo<string>(obj);
}
