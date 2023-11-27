using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Management.Automation;
using System.Text;
using Tomlyn;
using Tomlyn.Model;

namespace PSToml;

[Cmdlet(VerbsData.ConvertFrom, "Toml")]
[OutputType(typeof(OrderedDictionary))]
public sealed class ConvertFromTomlCommand : PSCmdlet
{
    private StringBuilder _inputValues = new();

    [Parameter(
        Mandatory = true,
        Position = 0,
        ValueFromPipeline = true,
        ValueFromPipelineByPropertyName = true
    )]
    [AllowEmptyString]
    public string[] InputObject { get; set; } = Array.Empty<string>();

    protected override void ProcessRecord()
    {
        foreach (string toml in InputObject)
        {
            _inputValues.AppendLine(toml);
        }
    }

    protected override void EndProcessing()
    {
        string toml = _inputValues.ToString();
        TomlTable table;
        try
        {
            table = Toml.ToModel(toml);
        }
        catch (Exception e)
        {
            WriteError(new ErrorRecord(
                e,
                "ParseError",
                ErrorCategory.NotSpecified,
                toml
            ));
            return;
        }

        OrderedDictionary result = ConvertToOrderedDictionary(table);
        WriteObject(result);
    }

    private OrderedDictionary ConvertToOrderedDictionary(TomlTable table)
    {
        OrderedDictionary result = new();
        foreach (KeyValuePair<string, object> kvp in table)
        {
            result[kvp.Key] = kvp.Value switch
            {
                TomlArray a => ConvertToArray(a),
                TomlTable t => ConvertToOrderedDictionary(t),
                TomlTableArray ta => ConvertToListOfOrderedDictionary(ta),
                TomlDateTime dt => dt.DateTime,
                _ => kvp.Value,
            };
        }

        return result;
    }

    private object?[] ConvertToArray(TomlArray array)
    {
        List<object?> result = new();
        result.AddRange(array);

        return result.ToArray();
    }

    private OrderedDictionary[] ConvertToListOfOrderedDictionary(TomlTableArray tableArray)
    {
        List<OrderedDictionary> result = new();
        foreach (TomlTable table in tableArray)
        {
            result.Add(ConvertToOrderedDictionary(table));
        }

        return result.ToArray();
    }
}
