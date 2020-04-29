function varstruct_construct(modul::Module, T, args_field, args_defaultvalue, args_type)
    return quote
        $(get_struct_definition(modul, T, args_field, args_defaultvalue, args_type))
    end
end

function get_struct_definition(modul::Module, T, args_field, args_defaultvalue, args_type)
    esc_T = esc(T)

    if isdefined(modul, T) && isa(getfield(modul, T), Type)
        # if already defined don't define it again
        out = quote
            # Struct Initialization (returns an instance)
            $(initialize_struct(esc_T, args_field, args_defaultvalue, getfield.(Ref(modul), args_type) ))
        end
    else
        strdef = :(mutable struct $esc_T
            fieldtable::FieldTable
        end)

        out = quote

            # Struct Declaration
            Core.eval($modul, $strdef)

            # Struct Interface
            $(get_struct_interface(esc_T))

            # Struct Constructor
            $(get_struct_constructor(esc_T))

            # Show
            $(show_struct(esc_T))

            # Struct Initialization (returns an instance)
            $(initialize_struct(esc_T, args_field, args_defaultvalue, getfield.(Ref(modul), args_type) ))
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

function get_struct_constructor(esc_T)
    return quote

            return $esc_T(fieldtable)
        end
    end
end


function initialize_struct(esc_T, esc_args_field, esc_args_defaultvalue, esc_args_type)
    return quote
        # initialize the struct

        $esc_T($(FieldTable( n => Props(v, t) for (n, v, t) in zip(esc_args_field, esc_args_defaultvalue, esc_args_type))))
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
                arg_show_all = arg_show_all * "\t $name::$(props.type) = $(props.value), \n"
                # iArg = iArg+1
            end

            out = """
            $($esc_T)(
                $arg_show_all)
            """
            return print(io, out)
        end
    end
end
