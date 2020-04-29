function varstruct_construct(modul::Module, T, args_field, args_defaultvalue, args_type)
    return quote
        $(get_struct_definition(modul, T, args_field, args_defaultvalue, args_type))
    end
end

function get_struct_definition(modul::Module, T, args_field, args_defaultvalue, args_type)
    esc_T = esc(T)
    T_declaration = Symbol("___", T , "_declaration___")

    if isdefined(modul, T) && isa(getfield(modul, T), Type)
        # if already defined don't define it again
        out = quote
            # Struct Initialization (returns an instance)
            $(initialize_struct(modul, T, args_field, args_defaultvalue, getfield.(Ref(modul), args_type), T_declaration))
        end
    else
        strdef = :(mutable struct $T
            fieldtable::FieldTable
        end)

        out = quote

            # Struct Declaration
            Base.eval($modul, $strdef)

            # Struct Interface
            $(get_struct_interface(esc_T))

            # Struct Constructor
            $(get_struct_constructor(modul, T, T_declaration))

            # Show
            $(show_struct(esc_T))

            # Struct Initialization (returns an instance)
            # @eval $modul $strinit
            $(initialize_struct(modul, T, args_field, args_defaultvalue, getfield.(Ref(modul), args_type), T_declaration))
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

function get_struct_constructor(modul, T, T_declaration)
    T_declaration = QuoteNode(T_declaration)
    esc_T = esc(T)
    return quote
        # kw method
        function $esc_T(; args...)
            # Type Checking for already defined fields
            fieldtable = getfield(getfield($modul, $T_declaration), :fieldtable)
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


function initialize_struct(modul, T, esc_args_field, esc_args_defaultvalue, esc_args_type, T_declaration)
    esc_T_declaration = esc(T_declaration)
    return quote
        # initialize the struct

        $esc_T_declaration = $modul.$T($(FieldTable( n => Props(v, t) for (n, v, t) in zip(esc_args_field, esc_args_defaultvalue, esc_args_type))))
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
