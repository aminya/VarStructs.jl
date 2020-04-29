function varstruct_construct(modul::Module, T, args_field, args_defaultvalue, args_type)
    return quote
        $(get_struct_definition(modul, T, args_field, args_defaultvalue, args_type))
    end
end
