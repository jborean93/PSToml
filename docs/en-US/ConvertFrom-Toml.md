---
external help file: PSToml.dll-Help.xml
Module Name: PSToml
online version: https://www.github.com/jborean93/PSToml/blob/main/docs/en-US/ConvertFrom-Toml.md
schema: 2.0.0
---

# ConvertFrom-Toml

## SYNOPSIS
Converts a TOML-formatted string to a dictionary.

## SYNTAX

```
ConvertFrom-Toml [-InputObject] <String[]> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The `ConvertFrom-Toml` cmdlet converts a Tom's Obvious Minimal Language (TOML) formatted string to a `Dictionary` object that hs a key for field in the TOML string.

To generate a TOML string from any object, use the [ConvertTo-Toml](./ConvertTo-Toml.md) cmdlet.

## EXAMPLES

### Example 1 - Convert TOML string to object
```powershell
PS C:\> $obj = ConvertFrom-Toml -InputObject @'
foo = "bar"
'@
PS C:\> $obj.foo  # bar
```

Converts the TOML string to a Dictionary object.
The TOML keys can be accessed in the dictionary like any other dictionary object in PowerShell.

### Example 2 - Convert TOML from file to an object
```powershell
PS C:\> Get-Content pyproject.toml | ConvertFrom-Toml
```

Reads the contents of the file `pyproject.toml` and converts it from the TOML string to an object.

## PARAMETERS

### -InputObject
The TOML string to convert.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ProgressAction
New common parameter introduced in PowerShell 7.4.

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]
All the string inputs will be combined together as a single string to convert from a TOML string.

## OUTPUTS

### System.Collections.Specialized.OrderedDictionary
This cmdlet returns an `OrderedDictionary` for each input TOML string provided. The underlying TOML table/dicts will also be an `OrderedDictionary` and a TOML list will be an `Object[]`.

## NOTES
This cmdlet uses the dotnet assembly [Tomlyn](https://github.com/xoofx/Tomlyn/tree/main) to perform the TOML conversions.

## RELATED LINKS

[TOML](https://toml.io/en/)
