abstract type ArgType end

struct Str       <: ArgType end
struct IntArg    <: ArgType end
struct FloatArg  <: ArgType end
struct PathArg   <: ArgType end
struct BoolFlag  <: ArgType end

struct ChoiceArg <: ArgType
    choices::Vector{String}
end

struct ArgDef
    name::String
    short::Union{Nothing, String}
    argtype::ArgType
    required::Bool
    default::Any
    multiple::Bool
    envfallback::Union{Nothing, String}
end

Base.@kwdef mutable struct ArgResult
    values::Dict{String, Any} = Dict()
end

# Conversion methods
convert_value(::Str, val) = val
convert_value(::PathArg, val) = val
convert_value(::BoolFlag, val) = val  # Already handled as `true`/`false`
convert_value(::IntArg, val) = parse(Int, val)
convert_value(::FloatArg, val) = parse(Float64, val)
convert_value(arg::ChoiceArg, val) = val in arg.choices ? val : error("Invalid choice: $val. Valid: $(join(arg.choices, ", "))")

## for any new type add convert_table(::NewType, val) = do-something-with val
