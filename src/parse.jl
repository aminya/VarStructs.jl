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
