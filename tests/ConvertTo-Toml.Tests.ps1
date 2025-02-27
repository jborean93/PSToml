. ([IO.Path]::Combine($PSScriptRoot, 'common.ps1'))

Describe "ConvertTo-Toml" {
    It "Fails to serialize primitive types" {
        $actual = ConvertTo-Toml -InputObject 'foo' -ErrorAction SilentlyContinue -ErrorVariable err
        $actual | Should -BeNullOrEmpty
        $err.Count | Should -Be 1
        [string]$err[0] | Should -BeLike 'Input object must be a dictionary like object.'
    }

    It "Converts dictionary" {
        $actual = ConvertTo-Toml -InputObject ([Ordered]@{
            foo = 'bar'
            list = @(1, 2, 3)
        })
        $actual | Should -Be @'
foo = "bar"
list = [1, 2, 3]

'@
    }

    It "Converts PSCustomObject" {
        $actual = ConvertTo-Toml -InputObject ([PSCustomObject]@{
            foo = 'bar'
            list = @(1, 2, 3)
        })
        $actual | Should -Be @'
foo = "bar"
list = [1, 2, 3]

'@
    }

    It "Converts complex object" {
        $actual = ConvertTo-Toml -Depth 5 -InputObject ([Ordered]@{
            fruits = @(
                [Ordered]@{
                    name = 'apple'
                    physical = [Ordered]@{
                        color = 'red'
                        shape = 'round'
                    }
                    varieties = @(
                        @{name = 'red delicious'}
                        @{name = 'granny smith'}
                    )
                }
                [Ordered]@{
                    name = 'banana'
                    varieties = @(
                        @{name = 'plantain'}
                    )
                }
            )
        })
        $actual | Should -Be @'
[[fruits]]
name = "apple"
[fruits.physical]
color = "red"
shape = "round"
[[fruits.varieties]]
name = "red delicious"
[[fruits.varieties]]
name = "granny smith"
[[fruits]]
name = "banana"
[[fruits.varieties]]
name = "plantain"

'@
    }

    It "Serializes special types" {
        $actual = ConvertTo-Toml -InputObject ([Ordered]@{
            guid = [Guid]::Empty
            char = [char]'c'
            null = $null
            enum = [System.IO.FileShare]::ReadWrite
            intptr = [IntPtr]::new(-1)
            uintptr = [UIntPtr]::new(1)
        })
        $actual | Should -Be @'
guid = "00000000-0000-0000-0000-000000000000"
char = "c"
null = ""
enum = 3
intptr = -1
uintptr = 1

'@
    }

    It "Serializes array and list types" {
        $actual = ConvertTo-Toml -InputObject ([Ordered]@{
            array = @(1, 2, 3)
            typed_array = [string[]]@(1, 2, "3")
            array_list = [System.Collections.ArrayList]@(1, 2, 3)
            generic_list = [System.Collections.Generic.List[string]]@(1, "2", 3)
        })
        $actual | Should -Be @'
array = [1, 2, 3]
typed_array = ["1", "2", "3"]
array_list = [1, 2, 3]
generic_list = ["1", "2", "3"]

'@
    }

    It "Shows property get exception in serialized format" {
        $obj = [PSCustomObject]@{}
        $obj | Add-Member -MemberType ScriptProperty -Name Getter -Value { throw "exception msg" }
        $actual = ConvertTo-Toml -InputObject $obj
        $actual | Should -Be @'
Getter = "Exception getting \"Getter\": \"exception msg\""

'@
    }

    It "Converts table with empty array values" {
        $actual = ConvertTo-Toml -InputObject ([Ordered]@{
            default = @("foo")
            foo = @()
            bar = @()
        })
        $actual | Should -Be @'
default = ["foo"]
foo = []
bar = []

'@
    }
}
