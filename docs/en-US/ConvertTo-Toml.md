---
external help file: PSToml.dll-Help.xml
Module Name: PSToml
online version: https://www.github.com/jborean93/PSToml/blob/main/docs/en-US/ConvertTo-Toml.md
schema: 2.0.0
---

# ConvertTo-Toml

## SYNOPSIS
Converts an object to a TOML-formatted string.

## SYNTAX

```
ConvertTo-Toml [-InputObject] <Object[]> [-Depth <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The `ConvertTo-Toml` cmdlet converts any dotnet object to a string in the Tom's Obvious Minimal Language (TOML) format.
The [ConvertFrom-Toml](./ConvertFrom-Toml.md) cmdlet can be used to convert a TOML string into a dictionary that can be managed in PowerShell.

## EXAMPLES

### Example 1 - Convert dictionary to TOML
```powershell
PS C:\> @{Foo = 'Bar'} | ConvertTo-Toml
```

Converts the input hashtable into a TOML string.

### Example 2 - Convert dotnet object to TOML
```powershell
PS C:\> [PSCustomObject]@{Foo = 'Bar'} | ConvertTo-Toml
```

Converts the input object into a TOML string.
While this example uses a `PSCustomObject`, any dotnet object can be used as the input object.

## PARAMETERS

### -Depth
Specifies how many levels of contained objects are included in the TOML representation.
The value can be any non-negative number with the default being `2`.
`ConvertTo-Toml` emits a warning if the number of levels in an input object exceeds this number.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 2
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
The input object to convert to the TOML string.
This can be either a dictionary like object or any class object where the properties are used as the TOML keys.

```yaml
Type: Object[]
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

### System.Object
Any object piped into this cmdlet will be converted to a TOML string.

## OUTPUTS

### System.String
This cmdlet returns a string representation of the input object converted to a TOML string.

## NOTES
This cmdlet uses the dotnet assembly [Tomlyn](https://github.com/xoofx/Tomlyn/tree/main) to perform the TOML conversions.

## RELATED LINKS

[TOML](https://toml.io/en/)
