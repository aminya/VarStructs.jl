module VarStructs

if VERSION <= v"1.1"
    isnothing(x) = x == nothing
end
if VERSION <= v"1.2.0"
    @warn("Please upgrade to Julia 1.4 for a better experience")
    Base.print(io, x::Nothing) = Base.show(io, x)
end

export @var, @shared_var, Unset, isunset

include("sugar.jl")


"""
    Unset

The value of a VarStruct field when it is not set yet.

# Examples
```julia
mystruct = @var struct MyStruct
    x::Int64
end

typeof(mystruct.x) # Unset

```
"""
struct Unset end

"""
  isunset(x)

Returns true if the value of a field is not set yet.

# Examples
```julia
mystruct = @var struct MyStruct
    x::Int64
end

isunset(mystruct.x) # true
```


```julia
isunset( Unset() ) # true
```
"""
isunset(x) = isa(x, Unset)

"""
type of the field names

# Example
```julia
f = :Amin
typeof(f) <: VarStructs.Name # true
```
"""
Name = Union{Symbol, String}

"""
A struct to hold the information about a VarStruct field

# Example
```julia
fp = Props(20.0, Float64)
```
"""
mutable struct Props{T}
    value::Union{Unset, T} # Unset when the value is not provided yet, but the type is known
    type::Type{T}
    # check::Union{Function, Nothing}
end

function Props(value::Union{Unset, T}) where T
    return Props{T}(value, T)
end

"""
A Dict that maps the field names to field properties

# Examples
```julia
ft = FieldTable( :Amin => Props(20.0, Float64) )
```
"""
FieldTable = Dict{Name, Props}

################################################################
include("parse.jl")
include("create.jl")

################################################################
"""
Create shared var struct instances (calling constructor will mutate the old instances).
"""
macro shared_var(expr)
    # __module__ = @__MODULE__ # for functions debuging.
    expr = macroexpand(__module__, expr) # to expand literal macros and @static
    return var(expr, __module__, __source__,  true)
end

macro var(expr)
    # __module__ = @__MODULE__ # for functions debuging.
    expr = macroexpand(__module__, expr) # to expand literal macros and @static
    return var(expr, __module__, __source__,  false)
end

function var(expr, __module__, __source__,  shred_var::Bool = false)
    #  check if @var is used before struct
    if expr isa Expr && expr.head == :struct

        # expr.args[3] # arguments
        expr.args[3], args_field, args_defaultvalue, args_type, args_param, args_check, is_struct_mutable, T = varstruct_struct_parse(__module__, expr)

    #  check if @var  is used before call
    elseif expr isa Expr && expr.head == :call

        expr, args_field, args_defaultvalue, args_type, args_param, T = varstruct_call_parse(__module__, expr)

    else
        error("Invalid usage of @var")
    end

    # check if the field name is a defined type
    for arg_field in args_field
        if isdefined(__module__, arg_field) && isa(getfield(__module__, arg_field), Type)
            @error "Change the field name `$arg_field` in struct `$T` to something else. The name conflicts with an already defined type name." _module = __module__  _file =__source__.file  _line = __source__.line
        end
    end

    return varstruct_construct(__module__, T, args_field, args_defaultvalue, args_type, shred_var)
end



end
