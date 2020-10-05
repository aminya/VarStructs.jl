# Call Syntax
person = @shared_var Citizen(
            name::String = "Amin",
            number::Float64 = 20.0,
        )

person2 = Citizen(name = "Not-Amin", number = 1)

@test person.name == person2.name
@test person2.number == person2.number
