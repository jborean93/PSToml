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
            uintptr_1 = [UIntPtr]::new(1)
            uintptr_2 = [UIntPtr]::new(9223372036854775808)
            uint64 = [UInt64]::MaxValue
        })
        $actual | Should -Be @'
guid = "00000000-0000-0000-0000-000000000000"
char = "c"
null = ""
enum = 3
intptr = -1
uintptr_1 = 1
uintptr_2 = "9223372036854775808"
uint64 = "18446744073709551615"

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

    It "Emits warning when exceeding -Depth" {
        $specialString = [PSCUstomObject]@{} | Add-Member -MemberType ScriptMethod -Name ToString -Value { 'Special' } -Force -PassThru
        $actual = @{
            1 = @{
                2 = [Ordered]@{
                    3 = @{ foo = 'bar' }
                    4 = $specialString
                }
            }
        } | ConvertTo-Toml -WarningAction SilentlyContinue -WarningVariable warn

        $actual | Should -Be @'
[1]
[1.2]
3 = "System.Collections.Hashtable"
4 = "Special"

'@
        $warn.Count | Should -Be 1
        $warn[0] | Should -Be "Resulting TOML is truncated as serialization has exceeded the set depth of 2"
    }

    It "Converts null value" {
        $actual = @{ key = $null } | ConvertTo-Toml
        $actual | Should -Be @'
key = ""

'@
    }

    It "Serializes BigInteger value" {
        $actual = ConvertTo-Toml -InputObject ([Ordered]@{
            int64 = [System.Numerics.BigInteger]::Parse('9223372036854775807')
            int64_negative = [System.Numerics.BigInteger]::Parse('-9223372036854775808')
            uint64_1 = [System.Numerics.BigInteger]::Parse('9223372036854775808')
            uint64_2 = [System.Numerics.BigInteger]::Parse('18446744073709551615')
            too_big = [System.Numerics.BigInteger]::Parse('18446744073709551616')
            too_small = [System.Numerics.BigInteger]::Parse('-18446744073709551616')
        })
        $actual | Should -Be @'
int64 = 9223372036854775807
int64_negative = -9223372036854775808
uint64_1 = "9223372036854775808"
uint64_2 = "18446744073709551615"
too_big = "18446744073709551616"
too_small = "-18446744073709551616"

'@
    }

    It "Serializes Int128 values" -Skip:(-not $IsCoreCLR) {
        $actual = ConvertTo-Toml -InputObject ([Ordered]@{
            positive_small = [Int128]1
            positive_big = [Int128]"170141183460469231731687303715884105727"
            negative_small = [Int128]-1
            negative_big = [Int128]"-170141183460469231731687303715884105728"
        })

        $actual | Should -Be @'
positive_small = 1
positive_big = "170141183460469231731687303715884105727"
negative_small = -1
negative_big = "-170141183460469231731687303715884105728"

'@
    }

    It "Serializes UInt128 values" -Skip:(-not $IsCoreCLR) {
        $actual = ConvertTo-Toml -InputObject ([Ordered]@{
            small = [UInt128]1
            int128 = [UInt128]"9223372036854775807"
            big = [UInt128]"340282366920938463463374607431768211455"
        })

        $actual | Should -Be @'
small = 1
int128 = 9223372036854775807
big = "340282366920938463463374607431768211455"

'@
    }

    It "Serializes UInt64 enum" {
        Add-Type -TypeDefinition @'
public enum MyEnum : ulong {
    One = 0x7FFFFFFFFFFFFFFF,
    Two = 0x8000000000000000
}
'@

        $actual = ConvertTo-Toml -InputObject ([Ordered]@{
            one = [MyEnum]::One
            two = [MyEnum]::Two
        })

        $actual | Should -Be @'
one = 9223372036854775807
two = "9223372036854775808"

'@
    }
}
