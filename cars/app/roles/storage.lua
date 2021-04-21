local function init_spaces()
    local car = box.schema.space.create(
        'car',
        {
            format = {
                {'car_id', 'string'},
                {'bucket_id', 'unsigned'},
                {'model', 'string'},
            },
            if_not_exists = true,
        }
    )

    car:create_index('pk', {
        parts = {'car_id'},
        if_not_exists = true,
    })

    car:create_index('bucket_id', {
        parts = {'bucket_id'},
        unique = false,
        if_not_exists = true,
    })
end

local function car_add(car)
    box.space.car:insert({
        car.car_id,
        car.bucket_id,
        car.model
    })

    return true
end

local function car_lookup(car_id)
    local car = box.space.car:get(car_id)
    if car == nil then
        return nil
    end
    car = {
        car_id = car.car_id;
        model = car.model;
    }

    return car
end

local exported_functions = {
    car_add = car_add,
    car_lookup = car_lookup,
}

local function init(opts)
    if opts.is_master then
        init_spaces()

        for name in pairs(exported_functions) do
            box.schema.func.create(name, {if_not_exists = true})
            box.schema.role.grant('public', 'execute', 'function', name, {if_not_exists = true})
        end
    end

    for name, func in pairs(exported_functions) do
        rawset(_G, name, func)
    end

    return true
end

return {
    role_name = 'storage',
    init = init,
    dependencies = {
        'cartridge.roles.vshard-storage',
    },
}
