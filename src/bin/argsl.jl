#!/usr/bin/env julia

using Argsl

const DSL = """
filename <path!>
--name|-n <str=env:USER>
--debug <flag>
--level|-l <choice:low,med,high="med">
"""

function main()
    if "--help" in ARGS
        Argsl.print_argsl_help(DSL)
        return
    end
    args = Argsl.parse_argsl_from_argv(DSL)
    println("Args parsed:")
    for (k, v) in args.values
        println("  ", k, ": ", v)
    end
end

main()
