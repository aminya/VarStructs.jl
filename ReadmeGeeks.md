# Give me benchmarks:
The dispatching is zero-cost like a normal struct:
```julia
julia> using VarStructs

julia> @var struct A
       end;
julia> @var struct B
       end;

julia> dispacth_varstruct(x::A) = 1
dispath_varstruct (generic function with 1 method)

julia> dispacth_varstruct(x::B) = 2
dispath_varstruct (generic function with 2 methods)

julia> using BenchmarkTools
julia> @btime dispath_varstruct(x) setup=(x=rand()<0.5 ? A() : B())
  0.001 ns (0 allocations: 0 bytes)
```


# Getting instances programmatically
You can get the instances of a VarStruct programmatically using a `Dict` of `symbol => VarStruct.Props`, but do not use this unless you are adventurous. 😁 This is not a supported API, and it suspect to change and breakage.
```julia
function Person(name, number)
    return Person(Dict(
        :name => VarStruct.Props(name),
        :number => VarStruct.Props(number),
        :initial => VarStruct.Props(name[1]),
    ))
end
```
