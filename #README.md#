# Argsl.jl 📜

A readable DSL on top of Julia CLI parsing — inspired by Python’s argparse, but designed for elegance using Julia’s type system and multiple dispatch.

---

## 💡 Why use Argsl.jl?

Writing CLI parsers manually in Julia is verbose. `Argsl.jl` lets you define arguments declaratively, like this:

```julia
args = argsl("""
filename <path!>                      # Required positional
--name|-n <str=env:USER>              # Optional flag with env fallback
--level|-l <choice:low,med,high="med"> # Choice type with default
--debug <flag>                        # Boolean flag
--logfile <path!>                     # Required logfile
""")
```

### 🧠 Features:
- ✅ Type-safe args (`int`, `str`, `float`, `path`, `bool`, `choice`)
- ✅ Required & optional args
- ✅ Defaults & environment fallbacks
- ✅ Flag booleans (`--flag` → true)
- ✅ Long/short flag variants
- ✅ Multiple values support
- ✅ Rich help output via `--help`
- ✅ Autocompletion script generator
- ✅ GitHub Actions CI support

---

## 🔧 Installation

```julia
using Pkg
Pkg.add(url="https://github.com/gwangjinkim/Argsl.jl")
```

---

## 🧪 Test it works

```bash
julia --project -e 'using Pkg; Pkg.test()'
```
Or via helper:
```bash
./check.jl
```

---

## 🚀 Example CLI Run
Run:
```bash
julia bin/argsl.jl myfile.txt --name Alice --debug --level high --logfile out.log
```
Which prints:
```
Args parsed:
  filename: myfile.txt
  name: Alice
  debug: true
  level: high
  logfile: out.log
```

---

## 📖 Argument Types DSL Table

| DSL Syntax                         | Description                              |
|-----------------------------------|------------------------------------------|
| `<str>` / `<int>` / `<float>`     | Typed single value                       |
| `<path>`                          | File path                                |
| `<flag>`                          | Becomes true when passed                 |
| `<str!>`                          | Required argument                        |
| `<int=42>`                        | With default value                       |
| `<choice:a,b,c="b">`             | Only one of choices                      |
| `=env:VARNAME`                    | Fallback to environment variable         |
| `--name|-n`                       | Long and short forms                     |
| `--onlyflag`                      | Long-only flag                           |
| `--no-cache <flag>`              | Treated as normal flag (true if present) |
| `<int*>`                          | Multiple values                          |

---

## 📜 Help Output (`--help`)

When `--help` is passed, you'll see:
```
Available arguments:

--name, -n              str, optional, env: USER
  → The user name

--debug                 flag, optional
  → Enable debug mode

--level, -l             choice: low, med, high, optional, default: med
  → Level of verbosity

--logfile               path, required
  → Output file

filename                path, required
```

---

## ⌨️ Shell Completion
Generate a bash completion script:
```bash
julia Argsl/gen_completion.jl > argsl-complete.sh
source argsl-complete.sh
```

---

## 📘 README Example Generator
Auto-generate usage snippet:
```bash
julia Argsl/gen_readme_example.jl >> README.md
```

---

## 🔁 CI Setup with GitHub Actions

`.github/workflows/ci.yml`
```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: julia-actions/setup-julia@v1
        with:
          version: '1.9'
      - name: Install & Test
        run: |
          julia --project -e 'using Pkg; Pkg.instantiate(); Pkg.test()'
```

---

## 🔮 Coming Soon
- [x] Pretty `--help` descriptions ✅
- [x] CLI binary & script mode ✅
- [x] Bash completions ✅
- [ ] Auto-generated README 
- [ ] Optional Zsh completion
- [ ] Registry submission

---

MIT Licensed • Created by Gwang-Jin Kim
