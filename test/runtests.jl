using Argsl
using Test

@testset "Argsl parsing tests" begin
    dsl = """
    filename <path!>
    --name|-n <str=env:USER>     # The user name
    --debug <flag>               # Enable debug mode
    --level|-l <choice:low,med,high="med">  # Level of verbosity
    --threads <int=4>            # Number of threads
    --logfile <path!>            # Required logfile
    --values <int*>              # Multiple int values
    --no-cache <flag>            # Disable cache
    """

    argv = [
        "input.txt", "--name", "Alice", "--debug", "--level", "high",
        "--threads", "8", "--logfile", "out.log", "--values", "1", "2", "3", "--no-cache"
    ]

    args = Argsl.parse_argsl_from_argv(dsl, argv)

    @test args.values["filename"] == "input.txt"
    @test args.values["name"] == "Alice"
    @test args.values["debug"] == true
    @test args.values["level"] == "high"
    @test args.values["threads"] == 8
    @test args.values["logfile"] == "out.log"
    @test isa(args.values["values"], Vector)
    @test args.values["values"] == [1, 2, 3]
    @test args.values["no-cache"] == true

    # 📦 Test argument metadata (descriptions, short flags, etc.)
    defmap = Dict(d.name => d for d in args.defs)

    @test defmap["name"].short == "n"
    @test defmap["name"].description == "The user name"

    @test defmap["debug"].short === nothing
    @test defmap["debug"].description == "Enable debug mode"

    @test defmap["level"].short == "l"
    @test defmap["level"].description == "Level of verbosity"

    @test defmap["threads"].description == "Number of threads"
    @test defmap["logfile"].description == "Required logfile"
    @test defmap["values"].description == "Multiple int values"
    @test defmap["no-cache"].description == "Disable cache"
    @test defmap["filename"].description == ""  # No inline description provided
end


@testset "Argsl help output should render" begin
    io = IOBuffer()
    Argsl.print_argsl_help("""
        --name|-n <str=env:USER>     # The user name
        --debug <flag>               # Enable debug mode
        --level|-l <choice:low,med,high="med">  # Level of verbosity
        --logfile <path!>            # Output file
        --values <int*>              # Multiple values
        filename <path!>             # Input file
    """, io)
    output = String(take!(io))
    
    @test occursin("Available arguments", output)
    @test occursin("--logfile", output)
    @test occursin("--values", output)
    @test occursin("multiple", output)
    @test occursin("filename", output)
end


@testset "Argsl error handling" begin
    @test_throws ErrorException Argsl.parse_argsl_from_argv("""
        filename <path!>
        --level <choice:low,med,high>
    """, [])

    @test_throws ErrorException Argsl.parse_argsl_from_argv("""
        --threads <int!>
    """, ["--threads", "notanint"])

    @test_throws ErrorException Argsl.parse_argsl_from_argv("""
        --level <choice:low,med,high>
    """, ["--level", "ultra"])
end

@testset "DSL description parsing" begin
    dsl = """
    # This script processes files
    # and outputs a result

    --file|-f <path>  # Input file
    """
    args = Argsl.parse_argsl_from_argv(dsl, ["--file", "input.txt"])
    @test occursin("processes files", args.meta["description"])
    @test length(args.defs) == 1
    @test args.defs[1].description == "Input file"
end

