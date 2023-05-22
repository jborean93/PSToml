# PSToml

[![Test workflow](https://github.com/jborean93/PSToml/workflows/Test%20PSTOML/badge.svg)](https://github.com/jborean93/PSToml/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/jborean93/PSToml/branch/main/graph/badge.svg?token=b51IOhpLfQ)](https://codecov.io/gh/jborean93/PSToml)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PSToml.svg)](https://www.powershellgallery.com/packages/PSToml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jborean93/PSToml/blob/main/LICENSE)

A TOML parser and writer for PowerShell 7+.

See [PSToml index](docs/en-US/PSToml.md) for more details.

## Requirements

These cmdlets have the following requirements

* PowerShell v7.2 or newer

## Examples

Parsing a TOML object can be done with the [ConvertFrom-Toml](./docs/en-US/ConvertFrom-Toml.md) cmdlet.
It accepts a string as the input:

```powershell
$obj = ConvertFrom-Toml @'
global = "this is a string"
# This is a comment of a table
[my_table]
key = 1 # Comment a key
value = true
list = [4, 5, 6]
'@

$obj.global -eq "this is a string"
$obj.my_table.key -eq 1
$obj.my_table.value -eq $true
$obj.my_table.list[0] -eq 4
```

Accessing the value is the same as any other dictionary or list like object.

Creating a TOML string can be done with the [ConvertTo-Toml](./docs/en-US/ConvertTo-Toml.md) cmdlet.
It accepts any input object that is a dictionary or a non-primitive dotnet type:

```powershell
ConvertTo-Toml -InputObject @{Foo = 'bar'}

ConvertTo-Toml -InputObject ([PSCustomObject]@{Foo = 'bar'})

ConvertTo-Toml -Depth 3 -InputObject @{
    global = 'this is a string'
    my_table = [Ordered]@{
        key = 1
        value = $true
        list = @(4, 5, 6)
    }
}
```

The `-Depth` parameter can be used to serialize deeply nested objects, it defaults to `2` to avoid issues with objects with recursive properties.

## Installing

The easiest way to install this module is through [PowerShellGet](https://docs.microsoft.com/en-us/powershell/gallery/overview).

You can install this module by running;

```powershell
# Install for only the current user
Install-Module -Name PSToml -Scope CurrentUser

# Install for all users
Install-Module -Name PSToml -Scope AllUsers
```

## Contributing

Contributing is quite easy, fork this repo and submit a pull request with the changes.
To build this module run `.\build.ps1 -Task Build` in PowerShell.
To test a build run `.\build.ps1 -Task Test` in PowerShell.
This script will ensure all dependencies are installed before running the test suite.
