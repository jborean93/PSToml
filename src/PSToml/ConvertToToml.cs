using PSToml.Shared;
using System;
using System.Management.Automation;

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
                res = TOMLLib.ConvertToToml(input, Depth, out wasTruncated);
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
