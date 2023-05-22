# Changelog for PSToml

## v0.2.0 - 2023-05-23

+ Changed piping behaviour of `ConvertFrom-Toml` to build the final TOML string for each input rather than try and convert each string input as individual TOML entries
  + This copies the behaviour of `ConvertFrom-Json` and makes `Get-Content $path | ConvertFrom-Toml` work as people would expect

## v0.1.0 - 2023-05-22

+ Initial version of the `PSToml` module
