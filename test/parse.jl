@testset "varstruct_call_parse" begin
    expr, args_field, args_defaultvalue, args_type, args_param, T = VarStructs.varstruct_call_parse(
        Main,
        quote
            Person(
                name::String = "Amin",
                number::Float64 = 20.0,
            )
        end
    )

    @test args_field == [:name, :number]
    @test args_defaultvalue == ["Amin", 20.0]
    @test args_type == [:String, :Float64]
    @test args_param == [Expr(:kw, :name, "Amin"), Expr(:kw, :number, 20.0)]
    @test T == :Person
end

@testset "varstruct_struct_parse" begin
    argsexpr, args_field, args_defaultvalue, args_type, args_param, args_check, is_struct_mutable, T = VarStructs.varstruct_struct_parse(
        Main,
        quote
            struct Person
                name::String
                number::Float64 = 20.0
            end
        end
    )

    @test args_field == [:name, :number]
    @test any(args_defaultvalue .== [missing, 20.0])
    @test args_type == [:String, :Float64]
    @test args_param == [:name, Expr(:kw, :number, 20.0)]
    @test T == :Person
end
