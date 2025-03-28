# Argsl.jl

A DSL for command line interface (CLI) argument parser for Julia (Args-DSL => Argsl). 🧩

## ✨ Features

- Declarative argument specification using a human-friendly DSL
- Supports:
  - Positional and optional arguments
  - Short and long flag variants (`--flag`, `-f`)
  - Required `!`, Fallback to a default value `=default_value`, Fallback to an Environment varible `=env:USER`
  - Multiple values via `*`
  - Type conversion: `int`, `float`, `str`, `path`
  - Choice validation like enums via `choice:a,b,c`
  - Help strings via inline `# comments`
  - Global description via leading `#` comments

## 📦 Installation

```julia
pkg> add https://github.com/yourusername/Argsl.jl

julia> using Argsl
```

## 🚀 Usage

```julia
using Argsl

dsl = """
# This program processes input files and logs results.
filename <path!>                       # Input filename, checked as a path and required argument (!)
--name|-n <str=env:USER>               # The user name - default value is USER environment variable
--debug <flag>                         # Enable debug mode - acts as a flag (value: true)
--level|-l <choice:low,med,high="med"> # Level of verbosity, to choose between "low", "med"(default), and "high"
--threads <int=4>                      # Number of threads (default 4)
--logfile <path!>                      # Required logfile, checked to be a path
--values <int*>                        # Multiple int values (variadic arguments)
--no-cache <flag>                      # Disable cache (value is `true`)
"""

argv = [
    "input.txt", "--name", "Alice", "--debug", "--level", "high",
    "--threads", "8", "--logfile", "out.log", "--values", "1", "2", "3", "--no-cache"
]

args = parse_argsl_from_argv(dsl, argv)

@show args.values["filename"]    # => "input.txt"
@show args.values["name"]        # => "Alice"
@show args.values["debug"]       # => true
@show args.values["level"]       # => "high"
@show args.values["threads"]     # => 8
@show args.values["logfile"]     # => "out.log"
@show args.values["values"]      # => [1, 2, 3]
@show args.values["no-cache"]    # => true
@show args.meta["description"]   # => "This program processes input files and logs results."
```

## 📄 DSL Syntax

Each line defines an argument. Syntax:

```
--flag|-f <type[!][*][=default][=env:VAR]>  # Optional help message
```

- `!`: Required
- `*`: Multiple values
- `=value`: Default value
- `=env:VAR`: Fallback to environment variable
- Short form optional (e.g., `--long|-l`)
- Leading `#` lines define the global description

## 🧠 Types

| DSL Type        | Julia Type | Description                      |
|-----------------|------------|----------------------------------|
| `str`           | String     | Standard string                  |
| `int`           | Int64      | Integer                          |
| `float`         | Float64    | Floating-point number            |
| `path`          | String     | File or directory path           |
| `flag`          | Bool       | Boolean toggle (true if present) |
| `choice:a,b,c`  | String     | Must be one of listed choices    |

## 📋 Help Text Generation

```julia
print_argsl_help(dsl)
```

Will render:

```
Available arguments:

--name, -n            str, optional, env: USER
  → The user name
debug                 flag, optional
  → Enable debug mode
--level, -l           choice: low, med, high, optional, default: med
  → Level of verbosity
logfile               path, required
  → Required logfile
filename              path, required
  → Input filename
```
(Cave: The text which comes after `#` in the DSL string `dsl` will be shown.
In my example - I wanted to explain more - so the texts deviate -
but you can see that one can determine in the `dsl` string what should become
the help text!)

## 🧪 Testing

See `test/runtests.jl` for usage examples and test coverage.


Manually start tests by:

```julia
julia> ]
pkg> test Argsl

# or do:
julis> include("test/runtests.jl")
```

## Package Structure

```bash
.
├── LICENSE
├── Manifest.toml
├── Project.toml
├── README.md
├── argsl-complete.sh
├── gen_completion.jl
├── src
│   ├── Argsl.jl
│   ├── bin
│   │   └── argsl.jl
│   ├── check.jl
│   ├── help.jl
│   ├── parser.jl
│   └── types.jl
└── test
    └── runtests.jl
```

---

Pull requests, suggestions, and issues welcome 🙌 !
