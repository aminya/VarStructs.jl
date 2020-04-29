@testset "call" begin
    person = @var Person(
                name::String = "Amin",
                number::Float64 = 20.0,
            )

    # getproperty
    @test person.name == "Amin"
    @test person.number == 20.0


    # setproperty
    person.name = "Tim"
    person.number = 21.0
    @test person.name == "Tim"
    @test person.number == 21.0

    # fieldnames
    @test fieldnames(person) == [:name, :number]

    # add fields
    person.initial = "TH"
    @test fieldnames(person) == [:initial, :name, :number]


    animal = @var Animal(
                name = "lion",
                number = 20,
            )


    # Dispatch
    function info(x::Person)
        println("Their home is city")
        return x.name
    end

    function info(x::Animal)
        println("Their home is jungle")
        return x.name
    end

    @test info(person) == "Tim"
    @test info(animal) == "lion"

    # alternative way of getting instance
    person = Person(Dict(
        :name => Props("Amin"),
        :number => Props(20.0),
    ))

    # alternative way of getting instance
    animal = Animal([:name, :number], ["lion", 10])

    @test info(person) == "Amin"
    @test info(animal) == "lion"

    # custom constructor
    function Person(name, number)
        return Person(Dict(
            :name => Props(name),
            :number => Props(number),
            :initial => Props(name[1]),
        ))
    end

    Person("Amin", 20.0)

end

@testset "struct" begin
    person = @var struct Person2
            name::String
            number::Float64 = 20.0
        end

    # getproperty
    @test ismissing(person.name)
    @test person.number == 20.0


    # setproperty
    person.name = "Tim"
    person.number = 21.0
    @test person.name == "Tim"
    @test person.number == 21.0

    # fieldnames
    @test fieldnames(person) == [:name, :number]

    # add fields
    person.initial = "TH"
    @test fieldnames(person) == [:initial, :name, :number]


    animal = @var struct Animal2
                name::String
                number::Int64
            end


    # Dispatch
    function info(x::Person2)
        println("Their home is city")
        return x.name
    end

    function info(x::Animal2)
        println("Their home is jungle")
        return x.name
    end

    # alternative way of getting instance
    person = Person2(Dict(
        :name => Props("Amin"),
        :number => Props(20.0),
    ))

    # alternative way of getting instance
    animal = Animal2([:name, :number], ["lion", 10])

    @test info(person) == "Amin"
    @test info(animal) == "lion"
end
