using VarStructs: Props

    # Call Syntax
    person = @var Person(
                name::String = "Amin",
                number::Float64 = 20.0,
            )

    animal = @var Animal(
                name = "lion",
                number = 20,
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

    # getting an instance
    person = Person(name = "Amin", number = 20.0)


    # alternative way of getting instance
    person2 = Person(Dict(
        :name => Props("Amin"),
        :number => Props(20.0),
    ))

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


    # Struct Syntax

    person2 = @var struct Person2
            name::String
            number::Float64 = 20.0
        end

    animal2 = @var struct Animal2
                name::String
                number::Int64
            end


    # getproperty
    @test isunset(person2.name)
    @test person2.number == 20.0


    # setproperty
    person2.name = "Tim"
    person2.number = 21.0
    @test person2.name == "Tim"
    @test person2.number == 21.0

    # fieldnames
    @test fieldnames(person2) == [:name, :number]

    # add fields
    person2.initial = "TH"
    @test fieldnames(person2) == [:initial, :name, :number]


    # Dispatch
    function info(x::Person2)
        println("Their home is city")
        return x.name
    end

    function info(x::Animal2)
        println("Their home is jungle")
        return x.name
    end

    # getting an instance
    person2 = Person2(name = "Amin", number = 20.0)
    animal2 = Animal2(name = "lion", number = 2)

    # alternative way of getting instance
    person3 = Person2(Dict(
        :name => Props("Amin"),
        :number => Props(20.0),
    ))

    @test info(person2) == "Amin"
    @test info(animal2) == "lion"



    mystruct = @var struct MyStruct
        x::Int64
    end

    @test isunset(mystruct.x)
