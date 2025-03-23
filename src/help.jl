module Help

using ..Types
import ..Parser: parse_line

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

function print_argsl_help(dsl::String)
    println("Available arguments:\n")
    for line in split(dsl, "\n")
        line = strip(line)
        isempty(line) || startswith(line, "#") && continue

        helptext = ""
        if occursin("#", line)
            line, helptext = strip.(split(line, "#", limit=2))
        end

        arg = parse_line(line)
        flags = arg.short !== nothing ? "--$(arg.name), -$(arg.short)" : "$(arg.name)"

        info = format_type(arg.argtype)
        if arg.required
            info *= ", required"
        else
            info *= ", optional"
        end

        if arg.default !== nothing
            info *= ", default: $(arg.default)"
        end

        if arg.envfallback !== nothing
            info *= ", env: $(arg.envfallback)"
        end

        if arg.multiple
            info *= ", multiple"
        end

        println(rpad(flags, 25), info)
        if !isempty(helptext)
            println("  → ", helptext)
        end
    end
end

end
