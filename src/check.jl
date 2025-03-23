#!/usr/bin/env julia
# File: check.jl

using Pkg

Pkg.activate(".")
Pkg.instantiate()

println("🔍 Running tests before publishing...")
Pkg.test()
