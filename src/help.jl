function format_type(argtype)
    if argtype isa BoolFlag
        return "flag"
    elseif argtype isa ChoiceArg
        return "choice: " * join(argtype.choices, ", ")
    elseif argtype isa PathArg
        return "path"
    elseif argtype isa IntArg
        return "int"
    elseif argtype isa FloatArg
        return "float"
    else
        return "str"
    end
end

function print_argsl_help(dsl::String, io::IO=stdout)
    args = parse_argsl_from_argv(dsl, String[]; allow_incomplete=true)
    
    println(io, "Available arguments:\n")
    
    for d in args.defs
        parts = String[]
        if !isempty(d.name)
            push!(parts, "--" * d.name)
        end
        if d.short !== nothing
            push!(parts, "-" * d.short)
        end

        flags = join(parts, ", ")

        meta = join(filter(!isempty, [
        string(d.argtype),
        d.required ? "required" : "optional",
        d.envfallback !== nothing ? "env: " * d.envfallback : "",
        d.default !== nothing ? "default: " * string(d.default) : "",
        d.multiple ? "multiple" : ""
        ]), ", ")

    

        println(io, rpad(flags, 24), meta)
        d.description !== nothing && println(io, "  → ", d.description)
    end
end
