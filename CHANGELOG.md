# Changelog for PSToml

## v0.5.0 - TBD

+ Serializes `UInt64` values that are larger than `Int64.MaxValue` as a string
  + Toml only supports a 64-bit signed integer so Tomlyn would auto cast to a `Int64` changing the result to a negative number
+ Ensure depth stringification uses the PowerShell string casting behaviour
+ Support `BigInteger` and `Int128`/`UInt128` (PowerShell 7+)
  + Values that fit within a `Int64` will be serialized as an integer while anything beyond the range will become a string

## v0.4.0 - 2025-03-12

+ Raise minimum PowerShell 7.x version to 7.4
+ Bump Tomlyn to `0.19.0` for empty array bugfix
+ Fix logic to properly serialize an empty array value

## v0.3.1 - 2024-01-29

+ Serialize any IList type as a Toml array value and not just an array
+ Deserialize Toml array values that contain table/array/ values into the proper dotnet object
+ Support serializing `IntPtr` and `UIntPtr` instances

## v0.3.0 - 2023-11-28

+ Migrated to new ALC structure that simplifies the code and ensures deps are loaded in the ALC
+ Added support for Windows PowerShell (5.1)
  + WinPS will not run with an ALC but should still load the libraries side by side if needed

## v0.2.0 - 2023-05-23

+ Changed piping behaviour of `ConvertFrom-Toml` to build the final TOML string for each input rather than try and convert each string input as individual TOML entries
  + This copies the behaviour of `ConvertFrom-Json` and makes `Get-Content $path | ConvertFrom-Toml` work as people would expect

## v0.1.0 - 2023-05-22

+ Initial version of the `PSToml` module
