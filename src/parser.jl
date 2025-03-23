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

function match_arg_line(line::String)
    groups = Dict{String, Union{String, Nothing}}(
        "longflag" => nothing,
        "shortflag" => nothing,
        "shortonly" => nothing,
        "positional" => nothing,
        "type_expr" => nothing,
        "description" => nothing,
    )

    # Step 1: Trim and check for <...>
    type_start = findfirst(isequal('<'), line)
    type_end = findfirst(isequal('>'), line)
    if type_start === nothing || type_end === nothing || type_end < type_start
        error("Invalid line format in DSL: '$line'. Must contain one '<...>' block.")
    end

    # Step 2: Split off description if any
    main_part = line
    description = ""
    hash_index = findfirst('#', line)
    if hash_index !== nothing && hash_index > type_end
        main_part = strip(line[1:hash_index-1])
        description = strip(line[hash_index+1:end])
    end
    if !isempty(description)
        groups["description"] = description
    end

    # Step 3: Extract type_expr
    groups["type_expr"] = strip(line[type_start+1:type_end-1])

    # Step 4: Flags and positional
    flag_part = strip(line[1:type_start-1])
    if startswith(flag_part, "--")
        parts = split(flag_part, "|")
        groups["longflag"] = replace(strip(parts[1]), "--" => "")
        if length(parts) > 1
            groups["shortflag"] = replace(strip(parts[2]), "-" => "")
        end
    elseif startswith(flag_part, "-")
        groups["shortonly"] = replace(strip(flag_part), "-" => "")
    else
        groups["positional"] = strip(flag_part)
    end

    return groups
end

maybe_strip(x::Union{Nothing,String}, default=nothing) = isnothing(x) ? default : strip(x)

function parse_line(line::AbstractString)::ArgDef

    m = match_arg_line(line)

    # Extract from regex captures
    longflag    = m["longflag"]
    shortflag   = m["shortflag"]
    shortonly   = m["shortonly"]
    positional  = m["positional"]
    type_expr   = strip(m["type_expr"])
    description = maybe_strip(get(m, "description", ""), "")

    # Determine name and short flag
    name, short = if longflag !== nothing
        (replace(longflag, "--" => ""), shortflag !== nothing ? replace(shortflag, "-" => "") : nothing)
    elseif shortonly !== nothing
        (replace(shortonly, "-" => ""), nothing)
    elseif positional !== nothing
        (positional, nothing)
    else
        error("Could not determine argument name.")
    end

    # Extract info from type_expr
    required    = occursin("!", type_expr)
    multiple    = occursin("*", type_expr)
    envfallback = occursin("=env:", type_expr) ? split(type_expr, "=env:")[2] : nothing

    default     = occursin("=" , type_expr) && !occursin("=env:", type_expr) ?
        split(type_expr, "=", limit=2)[2] : nothing

    default_val = if default !== nothing
        try
            eval(Meta.parse(default))
        catch
            default
        end
    else
        nothing
    end

    clean_type = replace(split(split(type_expr, "=")[1], "!")[1], "*" => "")
    argtype = parse_type(clean_type)

    return ArgDef(name, short, argtype, required, default_val, multiple, envfallback, description)
end

function parse_argsl_from_argv(dsl::String, argv=ARGS; allow_incomplete::Bool=false)::ArgResult
    lines = split(dsl, "\n")

    # 📝 Extract description from initial comment lines
    description_lines = String[]
    arg_lines = String[]

    for line in lines
        stripped = strip(line)
        if isempty(stripped)
            continue
        elseif startswith(stripped, "#")
            push!(description_lines, replace(stripped, "#" => "") |> maybe_strip)
        else
            push!(arg_lines, stripped)
        end
    end

    description = join(description_lines, " ")
    defs = ArgDef[]
    for line in arg_lines
        occursin(r"<.*?>", line) || continue
        push!(defs, parse_line(line))
    end

    res = ArgResult()
    res.meta["description"] = description
    res.defs = defs

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
            elseif d.multiple
                vals = String[]
                i += 1
                while i <= length(argv) && !startswith(argv[i], "-")
                    push!(vals, argv[i])
                    i += 1
                end
                isempty(vals) && error("Missing values for $arg")
                parsed = if d.argtype isa IntArg
                    parse.(Int, vals)
                elseif d.argtype isa FloatArg
                    parse.(Float64, vals)
                else
                    vals
                end
                res.values[d.name] = parsed
            else
                i + 1 > length(argv) && error("Missing value for $arg")
                value = argv[i + 1]
                try
                    value = if d.argtype isa IntArg
                        parse(Int, value)
                    elseif d.argtype isa FloatArg
                        parse(Float64, value)
                    elseif d.argtype isa ChoiceArg
                        if !(value in d.argtype.choices)
                            error("Invalid choice '$value' for --$(d.name). Must be one of: $(join(d.argtype.choices, ", "))")
                        end
                        value
                    else
                        value
                    end
                catch e
                    error("Invalid value for --$(d.name): '$value'. Expected $(typeof(d.argtype))")
                end
                res.values[d.name] = value
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
            elseif d.required && !allow_incomplete
                error("Required argument $(d.name) not provided.")
            end
        end
    end

    return res
end

function argsl(dsl::String)
    return parse_argsl_from_argv(dsl, String[])
end
