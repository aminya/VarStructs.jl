function varstruct_construct(modul::Module, T, args_field, args_defaultvalue, args_type, shared_var = false)
    return quote
        $(get_struct_definition(modul, T, args_field, args_defaultvalue, args_type, shared_var))
    end
end

function get_struct_definition(modul::Module, T, args_field, args_defaultvalue, args_type, shared_var = false)
    esc_T = esc(T)
    T_declaration = Symbol("___", T , "_declaration___")

    if isdefined(modul, T) && isa(getfield(modul, T), Type)
        # if already defined don't define it again
        out = quote
            # Struct Initialization (returns an instance)
            $(initialize_struct(modul, T, args_field, args_defaultvalue, args_type, T_declaration))
        end
    else
        strdef = :(mutable struct $T
            fieldtable::FieldTable
        end)

        out = quote

            # Struct Declaration
            # we need to eval manually to support definition inside non-toplevel scope (like functions). Otherwise this is not necessary
            Base.eval($modul, $strdef)

            # Struct Interface
            $(get_struct_interface(esc_T))

            # Struct Constructor
            $(get_struct_constructor(modul, T, T_declaration, shared_var))

            # Show
            $(show_struct(esc_T))

            # Struct Initialization (returns an instance)
            # @eval $modul $strinit
            $(initialize_struct(modul, T, args_field, args_defaultvalue, args_type, T_declaration))
        end

    end
    return out
end

function get_struct_interface(esc_T)
    return quote
        Base.getproperty(vs::$esc_T, fieldname::Symbol)= getfield(vs, :fieldtable)[fieldname].value
        Base.getproperty(vs::$esc_T, fieldname::String)= getfield(vs, :fieldtable)[fieldname].value

        function Base.setproperty!(vs::$esc_T, fieldname::Symbol, value)
            fieldtable = getfield(vs, :fieldtable)

            if haskey(fieldtable, fieldname)
                # Type conversion - checks for the type errors too
                value_converted = convert(fieldtable[fieldname].type, value)

                # Setting the fields
                fieldtable[fieldname].value = value_converted
            else
                # new field without type
                fieldtable[fieldname] = Props(value, typeof(value))
            end

            return vs
        end
        function Base.setproperty!(vs::$esc_T, fieldname::String, value)

            if haskey(fieldtable, fieldname)
                # Type conversion - checks for the type errors too
                value_converted = convert(fieldtable[fieldname].type, value)

                # Setting the fields
                fieldtable[fieldname].value = value_converted
            else
                # new field without type
                fieldtable[fieldname] = Props(value, typeof(value))
            end

            return vs
        end

        Base.fieldnames(vs::$esc_T) = collect(keys(getfield(vs, :fieldtable)))

    end # end quote
end

function get_struct_constructor(modul, T, T_declaration, shared_var = false)
    T_declaration = QuoteNode(T_declaration)
    esc_T = esc(T)
    return quote
        # kw method
        function $esc_T(; args...)
            # Type Checking for already defined fields
            fieldtableDeclaration = getfield(getfield($modul, $T_declaration), :fieldtable)

            # shared instance
            @static if ($shared_var)
                fieldtable = fieldtableDeclaration
            else
                fieldtable = deepcopy(fieldtableDeclaration)
            end

            for (fieldname, value) in args
                if haskey(fieldtable, fieldname)
                    # Type conversion - checks for the type errors too
                    value_converted = convert(fieldtable[fieldname].type, value)

                    # Setting the fields
                    fieldtable[fieldname].value = value_converted
                else
                    # new field without type
                    fieldtable[fieldname] = Props(value, typeof(value))
                end
            end
            return $esc_T(fieldtable)
        end
    end
end


function initialize_struct(modul, T, esc_args_field, args_defaultvalue, args_type, T_declaration)
    esc_T_declaration = esc(T_declaration)

    # we need to store declaration in the memory. This is needed for type checking, conversion, etc.
    # If someday Julia decides to include this in the Base, we can hide this from the memory.

    # also, we can't just call the constrctor directly because some default values might be missing in the declaration. We should use FieldTable

    return quote
        # initialize the struct
        $esc_T_declaration = $modul.$T( VarStructs.FieldTable( n => VarStructs.Props(v, t) for (n, v, t) in zip($esc_args_field, [$(esc.(args_defaultvalue)...)],  [$(esc.(args_type)...)]) ) )
    end
end


function show_struct(esc_T)
    return quote
        function Base.show(io::IO, vs::$esc_T)
            fieldtable = getfield(vs, :fieldtable)
            # arg_show = Vector{String}(undef, length(fieldtable))
            # iArg = 1
            arg_show_all = ""
            for (name, props) in fieldtable
                arg_show_all = arg_show_all * "    $name::$(props.type) = $(props.value), \n"
                # iArg = iArg+1
            end

            out = "$($esc_T)(\n$arg_show_all)"
            return print(io, out)
        end
    end
end
