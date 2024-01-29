# Changelog for PSToml

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
