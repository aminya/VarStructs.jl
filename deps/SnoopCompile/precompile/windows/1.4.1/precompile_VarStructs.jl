function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{Type{Dict},Pair{Symbol,Props{String}},Vararg{Pair,N} where N})
    Base.precompile(Tuple{Type{Dict},Tuple{Pair{Symbol,Props{String}},Pair{Symbol,Props{Float64}}}})
    Base.precompile(Tuple{Type{Pair},Symbol,Props{Any}})
    Base.precompile(Tuple{Type{Pair},Symbol,Props{Float64}})
    Base.precompile(Tuple{Type{Pair},Symbol,Props{Int64}})
    Base.precompile(Tuple{Type{Pair},Symbol,Props{String}})
    Base.precompile(Tuple{Type{Props},Float64,Type{Float64}})
    Base.precompile(Tuple{Type{Props},Float64})
    Base.precompile(Tuple{Type{Props},Int64,Type{Any}})
    Base.precompile(Tuple{Type{Props},Missing,Type{Int64}})
    Base.precompile(Tuple{Type{Props},Missing,Type{String}})
    Base.precompile(Tuple{Type{Props},String,Type{Any}})
    Base.precompile(Tuple{Type{Props},String,Type{String}})
    Base.precompile(Tuple{Type{Props},String})
    Base.precompile(Tuple{typeof(Base._compute_eltype),Type{Tuple{Pair{Symbol,Props{String}},Pair{Symbol,Props{Float64}},Pair{Symbol,Props{Char}}}}})
    Base.precompile(Tuple{typeof(Base._compute_eltype),Type{Tuple{Pair{Symbol,Props{String}},Pair{Symbol,Props{Float64}}}}})
    Base.precompile(Tuple{typeof(Base.grow_to!),Dict{Symbol,Props{String}},Tuple{Pair{Symbol,Props{String}},Pair{Symbol,Props{Float64}},Pair{Symbol,Props{Char}}},Int64})
    Base.precompile(Tuple{typeof(Base.grow_to!),Dict{Symbol,Props{String}},Tuple{Pair{Symbol,Props{String}},Pair{Symbol,Props{Float64}}},Int64})
    Base.precompile(Tuple{typeof(Base.grow_to!),Dict{Symbol,Props},Tuple{Pair{Symbol,Props{String}},Pair{Symbol,Props{Float64}},Pair{Symbol,Props{Char}}},Int64})
    Base.precompile(Tuple{typeof(Base.grow_to!),Dict{Symbol,Props},Tuple{Pair{Symbol,Props{String}},Pair{Symbol,Props{Float64}}},Int64})
    Base.precompile(Tuple{typeof(VarStructs.initialize_struct),Module,Symbol,Array{Union{String, Symbol},1},Array{Any,1},Array{DataType,1},Symbol})
    Base.precompile(Tuple{typeof(VarStructs.varT),Expr})
    Base.precompile(Tuple{typeof(VarStructs.varT),Symbol})
    Base.precompile(Tuple{typeof(VarStructs.varTdefVal),Expr})
    Base.precompile(Tuple{typeof(VarStructs.varstruct_call_parse),Module,Expr})
    Base.precompile(Tuple{typeof(VarStructs.varstruct_construct),Module,Symbol,Array{Union{String, Symbol},1},Array{Any,1},Array{Union{Expr, Symbol, Type},1}})
    Base.precompile(Tuple{typeof(VarStructs.varstruct_struct_parse),Module,Expr})
    Base.precompile(Tuple{typeof(empty),Dict{Any,Any},Type{Symbol},Type{Props{String}}})
    Base.precompile(Tuple{typeof(empty),Dict{Symbol,Props{String}},Type{Symbol},Type{Props}})
    Base.precompile(Tuple{typeof(getproperty),Props{Float64},Symbol})
    Base.precompile(Tuple{typeof(getproperty),Props{Int64},Symbol})
    Base.precompile(Tuple{typeof(getproperty),Props{String},Symbol})
    Base.precompile(Tuple{typeof(merge!),Dict{Symbol,Props},Dict{Symbol,Props{String}}})
    Base.precompile(Tuple{typeof(setindex!),Dict{Symbol,Props{String}},Props{String},Symbol})
    Base.precompile(Tuple{typeof(setindex!),Dict{Symbol,Props},Props{Char},Symbol})
    Base.precompile(Tuple{typeof(setindex!),Dict{Symbol,Props},Props{Float64},Symbol})
    Base.precompile(Tuple{typeof(setindex!),Dict{Union{String, Symbol},Props},Props{Any},Symbol})
    Base.precompile(Tuple{typeof(setindex!),Dict{Union{String, Symbol},Props},Props{Char},Symbol})
    Base.precompile(Tuple{typeof(setindex!),Dict{Union{String, Symbol},Props},Props{Float64},Symbol})
    Base.precompile(Tuple{typeof(setindex!),Dict{Union{String, Symbol},Props},Props{Int64},Symbol})
    Base.precompile(Tuple{typeof(setindex!),Dict{Union{String, Symbol},Props},Props{String},Symbol})
    Base.precompile(Tuple{typeof(setproperty!),Props{Float64},Symbol,Float64})
    Base.precompile(Tuple{typeof(setproperty!),Props{Int64},Symbol,Int64})
    Base.precompile(Tuple{typeof(setproperty!),Props{String},Symbol,String})
    isdefined(VarStructs, Symbol("#3#4")) && Base.precompile(Tuple{getfield(VarStructs, Symbol("#3#4")),Tuple{Symbol,Float64,DataType}})
    isdefined(VarStructs, Symbol("#3#4")) && Base.precompile(Tuple{getfield(VarStructs, Symbol("#3#4")),Tuple{Symbol,Int64,DataType}})
    isdefined(VarStructs, Symbol("#3#4")) && Base.precompile(Tuple{getfield(VarStructs, Symbol("#3#4")),Tuple{Symbol,Missing,DataType}})
    isdefined(VarStructs, Symbol("#3#4")) && Base.precompile(Tuple{getfield(VarStructs, Symbol("#3#4")),Tuple{Symbol,String,DataType}})
end