. ([IO.Path]::Combine($PSScriptRoot, 'common.ps1'))

Describe "ConvertFrom-Toml" {
    It "Fails on invalid TOML" {
        $actual = ConvertFrom-Toml -InputObject 'foo' -ErrorAction SilentlyContinue -ErrorVariable err
        $actual | Should -BeNullOrEmpty
        $err.Count | Should -Be 1
        [string]$err[0] | Should -BeLike '*Expecting ``=`` after a key instead of*'
    }

    It "Converts multiple input values into 1 toml object" {
        $actual = "", "foo = 'bar'`n", "`n", "", "hello = 123`r`n", "`r`n" | ConvertFrom-Toml
        $actual.foo | Should -Be bar
        $actual.hello | Should -Be 123
    }

    It "Converts string type - <Scenario>" -TestCases @(
        @{
            Scenario = 'Basic'
            Raw = '"I''m a string. \"You can quote me\". Name\tJos\u00E9\nLocation\tSF."'
            Expected = "I'm a string. ""You can quote me"". Name`tJos$([char]0x00E9)`nLocation`tSF."
        }
        @{
            Scenario = 'Multi-line basic'
            Raw = @'
"""
Roses are red
Violets are blue"""
'@
            Expected = "Roses are red$([Environment]::NewLine)Violets are blue"
        }
        @{
            Scenario = 'Literal string'
            Raw = '''C:\Users\nodejs\templates'''
            Expected = "C:\Users\nodejs\templates"
        }
        @{
            Scenario = 'Multi-line literal'
            Raw = "'''I [dw]on't need \d{2} apples'''"
            Expected = 'I [dw]on''t need \d{2} apples'
        }
    ) {
        param($Scenario, $Raw, $Expected)
        $actual = ConvertFrom-Toml -InputObject "foo = $raw"
        $actual.foo | Should -Be $Expected
    }

    It "Converts integer type - <Scenario>" -TestCases @(
        @{
            Scenario = 'Decimal positive'
            Raw = '+99'
            Expected = 99
        }
        @{
            Scenario = 'Decimal'
            Raw = '42'
            Expected = 42
        }
        @{
            Scenario = 'Decimal negative'
            Raw = '-17'
            Expected = -17
        }
        @{
            Scenario = 'Hexadecimal'
            Raw = '0xDEADBEEF'
            Expected = [uint32]"0xDEADBEEF"
        }
    ) {
        param($Scenario, $Raw, $Expected)
        $actual = ConvertFrom-Toml -InputObject "foo = $raw"
        $actual.foo | Should -Be $Expected
    }

    It "Converts DateTimeOffset type - <Scenario>" -TestCases @(
        @{
            Scenario = 'TZ UTC'
            Raw = '1979-05-27T00:32:00.999999Z'
            Expected = '1979-05-27T00:32:00.9999990+00:00'
        }
        @{
            Scenario = 'TZ'
            Raw = '1979-05-27T00:32:00.999999-07:00'
            Expected = '1979-05-27T00:32:00.9999990-07:00'
        }
        @{
            Scenario = 'Local'
            Raw = '1979-05-27T00:32:00.999999'
            Expected = "1979-05-27T00:32:00.9999990$([DateTimeOffset]::Now.ToString('zzz'))"
        }
        @{
            Scenario = 'Date Only'
            Raw = '1979-05-27'
            Expected = "1979-05-27T00:00:00.0000000$([DateTimeOffset]::Now.ToString('zzz'))"
        }
        @{
            Scenario = 'Time Only'
            Raw = '07:32:00'
            Expected = "$([DateTimeOffset]::Now.ToString("yyyy-MM-dd"))T07:32:00.0000000$([DateTimeOffset]::Now.ToString('zzz'))"
        }
    ) {
        param($Scenario, $Raw, $Expected)

        $actual = ConvertFrom-Toml -InputObject "foo = $Raw"
        $actual.foo | Should -BeOfType ([DateTimeOffset])
        $actual.foo.ToString("o") | Should -Be $Expected
    }

    It "Converts Array type" {
        $actual = ConvertFrom-Toml -InputObject @'
foo = [1, 2, "3"]
'@

        $actual.foo.Count | Should -Be 3
        $actual.foo[0] | Should -Be 1
        $actual.foo[1] | Should -Be 2
        $actual.foo[2] | Should -Be '3'
    }

    It "Converts inline table type" {
        $actual = ConvertFrom-Toml -InputObject @'
name = { first = "Tom", last = "Preston-Werner" }
'@

        $actual.name.first | Should -Be Tom
        $actual.name.last | Should -Be 'Preston-Werner'
    }

    It "Converts Array of table type" {
        $actual = ConvertFrom-Toml -InputObject @'
[[products]]
name = "Hammer"
sku = 738594937

[[products]]  # empty table within the array

[[products]]
name = "Nail"
sku = 284758393

color = "gray"
'@

        $actual.products.Count | Should -Be 3
        $actual.products[0].name | Should -Be Hammer
        $actual.products[0].sku | Should -Be 738594937
        $actual.products[1].Keys.Count | Should -Be 0
        $actual.products[2].name | Should -Be Nail
        $actual.products[2].sku | Should -Be 284758393
        $actual.products[2].color | Should -Be gray
    }
}
