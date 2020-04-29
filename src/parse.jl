"""
Parse `var::T` or `var`
"""
function varT(input)

    # Type Checker
    if input isa Symbol #  var

        var = input

        args_type = :Any
        args_field =  var
        args_param = var

        exprargsI = var # remove = defVal for type definition

    elseif input isa Expr && input.head == :(::) && input.args[1] isa Symbol # var::T

        var = input.args[1]
        varType = input.args[2] # Type

        args_type = varType
        args_field =  var
        args_param = var

        exprargsI = input # remove =defVal for type definition

    else
        # something else, e.g. inline inner constructor
        #   F(...) = ...
        args_type, args_field, args_param, exprargsI = missing, missing, missing, nothing
    end

    return args_type, args_field, args_param, exprargsI
end

"""
Parse `var::T = defVal` or `var = defVal`
"""
function varTdefVal(input)
    input.head == :(kw) || input.head == :(=) || throw(ArgumentError("Input should be in form of `var/var::T = defVal`. You passed $input"))

    lhs = input.args[1] # var or var::T
    args_type, args_field, args_param, exprargsI = varT(lhs)

    args_defaultvalue = input.args[2] # defVal
    args_param = Expr(:kw, args_field, args_defaultvalue)

    return args_defaultvalue, args_type, args_param, args_field, exprargsI
end

################################################################

"""
VarStruct definer function. It also serves as a parser.
# Examples
```julia
varstruct_call_parse(
    Main,
    quote
        Person(
            name::String,
            number::Float64 = 20.0,
        )
    end
)
```
"""
function varstruct_call_parse(modul::Module, expr::Expr)
    # The following code is taken and simplified from the `aml_parse` function of AcuteML.jl (@aminya):

    if expr.head == :block
        expr = expr.args[2]
    end
    if expr.head !== :call
        error("Invalid usage of `@var`")
    end

    T = expr.args[1] # Type name

    if !isa(T, Symbol)
        error("Invalid name for the type. Change `$T` to a Symbol")
    end

    data = expr.args[2:end] # arguments of the type
    argsnum = length(data)

    args_param = Vector{Union{Expr,Symbol}}(undef, argsnum) # Expr(:parameters)[]
    args_field = Vector{Union{Symbol, String}}(undef, argsnum)
    args_defaultvalue = Vector{Any}(missing, argsnum)
    args_type = Vector{Union{Type, Symbol, Expr}}(undef, argsnum)

    for iArg = 1:argsnum # iterating over arguments of each type argument

        ei = data[iArg] # type argument element i
        iExprArgs = iArg + 1
        ################################################################
        # Arguments
        ################################################################
        # No defVal
        if (ei isa Symbol) || (ei.head == :(::)) # var/var::T

            error("You should provide an initial value for $ei")

            args_type[iArg], args_field[iArg], args_param[iArg], exprargsI = varT(ei)
            !isnothing(exprargsI) ? expr.args[iExprArgs] = exprargsI : nothing
        ################################################################
        # Function not provided
        elseif ei.head == :(kw) # def value provided
             # var/var::T = defVal

             args_defaultvalue[iArg], args_type[iArg], args_param[iArg], args_field[iArg], exprargsI = varTdefVal(ei)
             !isnothing(exprargsI) ? expr.args[iExprArgs] = exprargsI : nothing
        ################################################################
        # Needs reevaluation
        elseif ei.head == :call
            error("Chaining not supported yet")
            expr.args[iExprArgs],  args_field[iArg], args_defaultvalue[iArg], args_type[iArg],  args_param[iArg], T  = varstruct_call_parse(modul, expr)
            # should call creator here:

        elseif ei.head == :block
            error("Chaining not supported yet")
            expr.args[iExprArgs],  args_field[iArg], args_defaultvalue[iArg], args_type[iArg],  args_param[iArg], T  = varstruct_call_parse(modul, expr.args[2])
            # should call creator here:
        else
            error("Syntax is not supported")
        end  # end ifs
    end # endfor

    return expr, args_field, args_defaultvalue, args_type, args_param, T
end

################################################################
"""
VarStruct declaration function. Use this syntax when you only need to declare the struct and not fully initialize it.
# Examples
```julia
varstruct_struct_parse(
    Main,
    quote
        struct Person
            name::String
            number::Float64 = 20.0
        end
    end
)
```
"""
function varstruct_struct_parse(modul::Module, expr::Expr)
    # The following code is taken and simplified from the aml_parse function of AcuteML.jl (@aminya):

    if expr.head == :block
        expr = expr.args[2]
    end
    if expr.head !== :struct
        error("Invalid usage of `@var`")
    end

    is_struct_mutable = expr.args[1] # for future use
    T = expr.args[2] # Type name +(curly braces)

    if !isa(T, Symbol)
        error("Invalid name for the type. Change `$T` to a Symbol")
    end

    argsexpr = expr.args[3] # arguments of the type

    areargs_inds = findall(x->!(isa(x, LineNumberNode)), argsexpr.args)
    data = argsexpr.args[areargs_inds]
    argsnum = length(areargs_inds)

    args_param = Vector{Union{Expr,Symbol}}(undef, argsnum) # Expr(:parameters)[]
    args_field = Vector{Union{Symbol, String}}(undef, argsnum)
    args_defaultvalue = Vector{Any}(missing, argsnum)
    args_type = Vector{Union{Type, Symbol, Expr}}(undef, argsnum)
    args_check = Vector{Union{Missing, Symbol, Function}}(missing, argsnum)
    # struct_check = Array{Union{Missing, Symbol, Function},0}(missing)

    for iArg = 1:argsnum # iterating over arguments of each type argument

        i = areargs_inds[iArg] # used for argsexpr.args[i]

        ei = data[iArg] # type argument element i

        ################################################################
        # Arguments
        # No defVal
        if (ei isa Symbol) || (ei.head == :(::)) # var/var::T

            args_type[iArg], args_field[iArg], args_param[iArg], exprargsI = varT(ei)
            !isnothing(exprargsI) ? argsexpr.args[i] = exprargsI : nothing

        ########################
        # Function provided
        elseif  ei.head == :tuple

            # var/var::T = defVal, F
            if isa(ei.args[2], Union{Function, Symbol})  # function provided

                # var/var::T = defVal
                args_defaultvalue[iArg], args_type[iArg], args_param[iArg], args_field[iArg], exprargsI = varTdefVal(ei.args[1])
                !ismissing(exprargsI) ? argsexpr.args[i] = exprargsI : nothing

                 # F
                args_check[iArg] = ei.args[2]
            else
                error("Unkown syntax.")
            end

        ################################################################
        # Function not provided
        elseif ei.head == :(=) # def value provided
             # var/var::T = defVal

             args_defaultvalue[iArg], args_type[iArg], args_param[iArg], args_field[iArg], exprargsI = varTdefVal(ei)
             !isnothing(exprargsI) ? argsexpr.args[i] = exprargsI : nothing

        # Needs reevaluation
        elseif ei.head == :struct
             error("Chaining not supported yet")
             # TODO: only works for structs
             argsexpr.args[i], args_field[iArg], args_defaultvalue[iArg], args_type[iArg], args_param[iArg], args_check[iArg], _, _  = varstruct_struct_parse(modul, expr)

        ################################################################
        else
            error("Syntax is not supported")
        end # end ifs
    end # endfor

    return argsexpr, args_field, args_defaultvalue, args_type, args_param, args_check, is_struct_mutable, T
end
