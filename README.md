# Argsl.jl

A minimalist DSL-based argument parser for Julia.

## ✨ Features

- Declarative argument specification using a simple DSL
- Support for:
  - Positional arguments
  - Flags (boolean switches)
  - Environment variable fallbacks
  - Default values
  - Required arguments
  - Multiple values
  - Choice validation (like enums)
- Automatic type parsing (e.g., `int`, `float`, etc.)
- Clear help output generation

## 📦 Installation

```julia
pkg> add https://github.com/yourusername/Argsl.jl
```

## 🚀 Usage

```julia
using Argsl

dsl = """
filename <path!>
--threads <int=4>
--debug <flag>
--level <choice:low,med,high="med">
--values <int*>
"""

argv = ["input.txt", "--threads", "8", "--debug", "--level", "high", "--values", "1", "2", "3"]
args = parse_argsl_from_argv(dsl, argv)

@show args.values["filename"]  # => "input.txt" :: String
@show args.values["threads"]   # => 8          :: Int
@show args.values["debug"]     # => true       :: Bool
@show args.values["level"]     # => "high"     :: String
@show args.values["values"]    # => [1, 2, 3]   :: Vector{Int}
```

## 🎛️ Supported Types

| DSL Type        | Julia Type   | Description                            |
|----------------|--------------|----------------------------------------|
| `str`          | `String`     | Default string input                   |
| `int`          | `Int64`      | Integer value                          |
| `float`        | `Float64`    | Floating-point number                  |
| `path`         | `String`     | Treated as a file or directory path    |
| `flag`         | `Bool`       | Boolean switch (true if present)       |
| `choice:a,b,c` | `String`     | Must be one of the listed choices      |

## ✅ Argument Modifiers

- `!` → Required argument
- `=val` → Default value
- `=env:VAR` → Fallback to environment variable
- `*` → Accept multiple values

## 📤 Help Output

Use `print_argsl_help(dsl)` to render a description of all arguments:

```julia
print_argsl_help(dsl)
```

Example Output:
```
Available arguments:

--threads               int, optional, default: 4
--debug                 flag, optional
--level                 choice: low, med, high, optional, default: med
--values                int, optional, multiple
filename                path, required
```

## 🔒 Error Handling

Argsl validates types and choices:

```julia
parse_argsl_from_argv("--threads <int>", ["--threads", "notanint"])
# => Error: Invalid value for --threads: 'notanint'. Expected IntArg

parse_argsl_from_argv("--level <choice:low,med,high>", ["--level", "extreme"])
# => Error: Invalid choice 'extreme' for --level. Must be one of: low, med, high
```

## 🧪 Testing

```julia
Pkg.test("Argsl")
```

## 📜 License
MIT



Written by Gwang-Jin Kim

