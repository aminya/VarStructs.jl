module VarStructs

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
    value::Union{Missing, T} # missing when the value is not provided yet, but the type is known
    type::Type{T}
    # check::Union{Function, Nothing}
end

function Props(value::Union{Missing, T}) where T
    return Props{T}(value, T)
end




end
