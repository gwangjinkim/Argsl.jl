#!/usr/bin/env julia

using Argsl

function generate_completion_script(dsl::String; cmdname::String="argsl")
    defs = Argsl.Parser.parse_line.(split(dsl, "\n") |> x -> filter(!isempty∘strip, x))
    options = filter(d -> d.short !== nothing || startswith(d.name, "-"), defs)
    flags = map(d -> "--" * d.name, options)
    shortflags = map(d -> d.short === nothing ? "" : "-" * d.short, options)
    allflags = join(filter(!isempty, vcat(flags, shortflags)), " ")

    println("""
# Bash completion for $cmdname
generate_argsl_completion() {
    COMPREPLY=( $(compgen -W "$allflags" -- "${COMP_WORDS[COMP_CWORD]}") )
}
complete -F generate_argsl_completion $cmdname
""")
end

if abspath(PROGRAM_FILE) == @__FILE__
    const DSL = """
    filename <path!>
    --name|-n <str=env:USER>
    --debug <flag>
    --level|-l <choice:low,med,high="med">
    --logfile <path!>
    """
    generate_completion_script(DSL)
end
