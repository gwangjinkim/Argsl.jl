module Types

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

end
