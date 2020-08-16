# VarStructs

![CI](https://github.com/aminya/VarStructs.jl/workflows/CI/badge.svg)

# Features

VarStructs are similar to structs but have extra features:
  - You can add fields after their definition.
  - They can be defined inside a function or a local scope.
  - They can be redefined.

Similar to structs
  - They can be used for dispatching (zero-cost)
  - They can have custom constructors
  - They have type conversion/checking for the fields that are declared


VarStructs removes the limitations of structs, and so in addition to all the applications of structs, you can use structures in new applications! For example, it can be used to define a "Schema" for your type, or you can used it for serialization of unknown data.

# Install and Usage
```julia
using Pkg; Pkg.add("VarStructs")
```
```julia
using VarStructs
```

If you want to see a full example see [here]( https://github.com/aminya/VarStructs.jl/blob/master/example/schema.jl).

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
You can redeclare the struct later, but in redeclaration you will not get type checking based on the previous declaration.

## Call Syntax
In this syntax, you **should** provide the initial values for the fields. Providing type for the fields are optional (if not provided, it is considered as `Any`).
```julia
@var Person(
        name = "Amin",
        number::Float64 = 20.0,
    )
```

# Getting an Instance
Use the following syntax for getting an instance:
```julia
julia> person = Person(name = "Amin", number = 20.0)
Person(
    name::Any = Amin,       
    number::Float64 = 20.0,
)

# Type conversion for the fields that were declared
julia> person2 = Person(name = "Amin", number = 20)  # number is converted to Float64
Person(
    name::Any = Amin,       
    number::Float64 = 20.0,
)

# Type checking for the fields that were declared
julia> person2 = Person(name = "Amin", number = "20")
ERROR: MethodError: Cannot `convert` an object of type String to an object of type Float64

# new field added
julia> person2 = Person(name = "Amin", number = 20.0, initial = "A")
Person(
    initial::String = A,    
    name::Any = Amin,       
    number::Float64 = 20.0,
)
```

The two syntaxes that are used for declaration also return an instance of the VarStruct. So if you need an instance right away, you can use the following.
```julia
animal = @var Animal(
        name = "lion",
        number::Int64 = 10,
    )

# redefinition of `Animal` returns a new instance:
animal2 = @var Animal(
        name = "dog",
        number::Int64 = 1,
    )
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
To define a custom constructor return an instance using keyword method:
```julia
function Person(name, number)
    return Person(
        name = name,
        number = number,
        initial = name[1],
    )
end

Person("Amin", 20.0)
```

If you are a geek see here too: [ReadmeGeeks](https://github.com/aminya/VarStructs.jl/blob/master/ReadmeGeeks.md)
