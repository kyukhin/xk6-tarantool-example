local vshard = require('vshard')
local cartridge = require('cartridge')
local errors = require('errors')

local err_vshard_router = errors.new_class("Vshard routing error")

function api_car_add(car)
    local bucket_id = vshard.router.bucket_id(car.car_id)
    car.bucket_id = bucket_id

    local _, error = err_vshard_router:pcall(
        vshard.router.call,
        bucket_id,
        'write',
        'car_add',
        {car}
    )

    if error then
        return 'Error occured'
    end

    return 'Ok'
end

function api_car_get(car_id)
    local bucket_id = vshard.router.bucket_id(car_id)

    local car, error = err_vshard_router:pcall(
        vshard.router.call,
        bucket_id,
        'read',
        'car_lookup',
        {car_id}
    )

    if error then
        return nil
    end

    if car == nil then
        return nil
    end

    return car
end

local function init(opts)
    rawset(_G, 'vshard', vshard)

    if opts.is_master then
        box.schema.user.grant('guest',
            'read,write,execute',
            'universe',
            nil, { if_not_exists = true }
        )
    end

    return true
end

return {
    role_name = 'api',
    init = init,
    dependencies = {'cartridge.roles.vshard-router'},
}
