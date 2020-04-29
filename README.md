# VarStructs

[![Build Status](https://github.com/aminya/VarStructs.jl/workflows/CI/badge.svg)](https://github.com/aminya/VarStructs.jl/actions)

# Features

VarStructs are similar to struct but have extra features:
  - You can fields to the VarStruct after its definition.
  - They can be defined inside a function or a local scope.
  - They can be redefined.

Similar to structs
  - They can be used for dispatching
  - They can have custom constructors

# Install and Usage
```julia
using Pkg; Pkg.add(PackageSpec(url = "https://github.com/aminya/VarStructs.jl", rev = "master"))
```
```julia
using VarStructs
```

# Declaration
There are two ways to declare them:

## Struct Syntax
In this syntax, providing initial values and types for the fields are optional.
```julia
@var struct Animal
    name::String
    number::Int64
end
```

## Call Syntax
In this syntax, you **should** provide the initial values for the fields. Providing types for the fields are optional.
```julia
@var Person(
        name = "Amin",
        number::Float64 = 20.0,
    )
```

# Getting an Instance

Two syntax that used for declaration also return an instance of the VarStruct. So if you need an instance right away you can:
```julia
animal = @var Animal(
        name = "lion",
        number::Int64 = 10,
    )

# redefinition of `Animal` returns a new instance:
animal2 = @var Person(
        name = "dog",
        number::Int64 = 1,
    )
```

There are two alternative syntax for getting an instance:
```julia
# names, values method:
animal = Animal([:name, :number], ["lion", 10])

# names, values, types method:
animal = Animal([:name, :number], ["lion", 10], ["String", Int64])

# Dict of `name => Props(value, type)`
person = Person(Dict(
    :name => Props("Amin"),
    :number => Props(20.0, Float64),
))
```

# Accessing, Setting, Adding Fields
```julia
# Accessing
julia> person.name
"Amin"

# Setting
julia> person.name = "Tim"

# Adding Fields
julia> person.initial = "T"

```

# Dispatch
`info` function dispatch for `Person` and `Animal` type:
```julia
function info(x::Person)
    println("Their home is city")
    return x.name
end

function info(x::Animal)
    println("Their home is jungle")
    return x.name
end
```
```julia
julia> info(person)
"Their home is city"
"Amin"

julia> info(animal)
"Their home is jungle"
"lion"
```


# Custom Constructor
To define a custom constructor return an instance using one the above methods:
```julia
function Person(name, number)
    return Person(Dict(
        :name => Props(name),
        :number => Props(number),
        :initial => Props(name[1]),
    ))
end

Person("Amin", 20.0)
```


This type will be used in the developing of a pckage called JuliaSON which aims to provide data serialization with Julia syntax.
