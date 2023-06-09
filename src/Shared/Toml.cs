using System;
using System.Collections;
using System.Management.Automation;
using Tomlyn;
using Tomlyn.Model;

namespace PSToml.Shared;

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
            return inputObject?.ToString() ?? "";
        }

        return inputObject switch
        {
            IDictionary dict => ConvertToTomlTable(dict, depth),
            Array array => ConvertToTomlArray(array, depth),
            _ => ConvertToTomlFriendlyObject(inputObject, depth),
        };
    }

    private TomlArray ConvertToTomlArray(Array array, int depth)
    {
        TomlArray result = new();

        foreach (object value in array)
        {
            result.Add(ConvertToTomlObject(value, depth - 1));
        }

        return result;
    }

    private TomlTable ConvertToTomlTable(IDictionary dict, int depth)
    {
        TomlTable model = new();
        foreach (DictionaryEntry entry in dict)
        {
            object value = ConvertToTomlObject(entry.Value ?? "", depth - 1);
            model.Add(entry.Key.ToString() ?? "", value);
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
            return obj.ToString() ?? "";
        }
        else if (obj is Enum enumObj)
        {
            return Convert.ChangeType(enumObj, enumObj.GetTypeCode());
        }

        if (
            obj is bool ||
            obj is DateTime ||
            obj is DateTimeOffset ||
            obj is sbyte ||
            obj is byte ||
            obj is Int16 ||
            obj is UInt16 ||
            obj is Int32 ||
            obj is UInt32 ||
            obj is Int64 ||
            obj is UInt64 ||
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
}

public static class TOMLLib
{
    public static string ConvertToToml(object inputObject, int depth, out bool wasTruncated)
    {
        TomlConverter converter = new(depth);
        TomlTable model = converter.ConvertToToml(inputObject);
        wasTruncated = converter.WasTruncated;

        return Toml.FromModel(model);
    }

    public static TomlTable ConvertFromToml(string toml)
        => Toml.ToModel(toml);
}
