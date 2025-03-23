module Parser

using ..Types
import ..Types: ArgDef, ArgType, ArgResult, Str, IntArg, FloatArg, PathArg, BoolFlag, ChoiceArg

function parse_type(typstr::String)
    if startswith(typstr, "choice:")
        choices = split(replace(typstr, "choice:" => ""), ",")
        return ChoiceArg(choices)
    end
    Dict(
        "str"   => Str(),
        "int"   => IntArg(),
        "float" => FloatArg(),
        "path"  => PathArg(),
        "flag"  => BoolFlag()
    )[typstr]
end

function parse_line(line::String)::ArgDef
    s = split(line, r"\s*<|>\s*")
    flags, type_expr = strip(s[1]), strip(s[2])

    name, short = nothing, nothing
    if startswith(flags, "--")
        parts = split(flags, "|")
        name = replace(parts[1], "--" => "")
        short = length(parts) > 1 ? replace(parts[2], "-" => "") : nothing
    else
        name = strip(flags)
    end

    required    = occursin("!", type_expr)
    multiple    = occursin("*", type_expr)
    envfallback = occursin("=env:", type_expr) ? split(type_expr, "=env:")[2] : nothing
    default     = occursin("=", type_expr) && !occursin("=env:", type_expr) ? eval(Meta.parse(split(type_expr, "=")[2])) : nothing
    clean_type  = replace(split(split(type_expr, "=")[1], "!")[1], "*" => "")

    argtype = parse_type(clean_type)

    ArgDef(name, short, argtype, required, default, multiple, envfallback)
end

function parse_argsl_from_argv(dsl::String, argv=ARGS)::ArgResult
    defs = ArgDef[]
    for line in split(dsl, "\n")
        line = strip(line)
        isempty(line) || startswith(line, "#") && continue
        push!(defs, parse_line(line))
    end

    res = ArgResult()
    i = 1
    while i <= length(argv)
        arg = argv[i]
        if startswith(arg, "--") || startswith(arg, "-")
            name = replace(arg, "--" => "")
            def = findfirst(d -> d.name == name || d.short == name, defs)
            isnothing(def) && error("Unknown flag: $arg")
            d = defs[def]
            if d.argtype isa BoolFlag
                res.values[d.name] = true
                i += 1
            else
                i + 1 > length(argv) && error("Missing value for $arg")
                res.values[d.name] = argv[i+1]
                i += 2
            end
        else
            d = findfirst(d -> d.short === nothing && !(d.name in keys(res.values)), defs)
            isnothing(d) && error("Unexpected positional arg: $arg")
            res.values[defs[d].name] = arg
            i += 1
        end
    end

    for d in defs
        if !haskey(res.values, d.name)
            if d.default !== nothing
                res.values[d.name] = d.default
            elseif d.envfallback !== nothing
                res.values[d.name] = get(ENV, d.envfallback, nothing)
            elseif d.argtype isa BoolFlag
                res.values[d.name] = false
            elseif d.required
                error("Required argument $(d.name) not provided.")
            end
        end
    end

    return res
end

function argsl(dsl::String)
    return parse_argsl_from_argv(dsl, String[])
end

end
