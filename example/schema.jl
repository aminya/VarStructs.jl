using VarStructs

# use synatx sugar :)
using VarStructs: U, UN # union and union with nothing


# declare
@var struct Address
    country::String
    city::UN{String} = nothing
    street::UN{String} = nothing
    unit::UN{ U{String, Int64} } = nothing
    zip::UN{ U{String, Int64} } = nothing
end

@var struct Human
    name::String
    address::UN{Address} = nothing
    id::UN{Int64} = nothing
end

@var struct Animal
    name::String
end

# get instance
h1 = Human(name = "Amin") # don't define all the things
h1.address = Address(country = "Canada") # add things later

h2 =  Human(name = "Someone", address = Address(country = "RandomCountry", street = "Street 1", zip = 1) )
h2.id = 2

a1 = Animal(name = "lion")


# redeclare!
@var struct Animal
    name::String
    id::UN{Int64} = nothing
end

a2 = Animal(name = "lion", id = 1)


# Dispatch!
function introduce_yourself(x::Human)
    println("My name is $(x.name), and I am from $(x.address.country)")
end

function introduce_yourself(x::Animal)
    println("My name is $(x.name), and I live in jungle")
end


introduce_yourself(h1)
introduce_yourself(h2)
introduce_yourself(a1)
introduce_yourself(a2)

# Custom constructor
function Human(n::String)
    @info "Address of human with name $n not found"
    return Human(name = n, address = Address(country = "Earth"))
end

h3 = Human("UnknownPerson")
