using VarStructs
using Test

@testset "VarStructs.jl" begin

    @testset "parse" begin
        include("parse.jl")
    end

    @testset "@var" begin
        include("@var.jl")
    end

end
