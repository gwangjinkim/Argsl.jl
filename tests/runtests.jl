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
    @test parse(Int, args.values["threads"]) == 8
    @test args.values["logfile"] == "out.log"
    @test isa(args.values["values"], Vector)
    @test args.values["values"] == ["1", "2", "3"]
    @test args.values["no-cache"] == true
end

@testset "Argsl help output should render" begin
    try
        Argsl.print_argsl_help("""
        --name|-n <str=env:USER>     # The user name
        --debug <flag>               # Enable debug mode
        --level|-l <choice:low,med,high="med">  # Level of verbosity
        --logfile <path!>            # Output file
        filename <path!>
        """)
    catch e
        @test false "Help output threw an error: $e"
    end
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

