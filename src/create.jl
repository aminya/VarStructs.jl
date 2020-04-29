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
