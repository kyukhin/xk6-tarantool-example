#!/usr/bin/env tarantool

require('strict').on()

if package.setsearchroot ~= nil then
    package.setsearchroot()
else
    local fio = require('fio')
    local app_dir = fio.abspath(fio.dirname(arg[0]))
    package.path = app_dir .. '/?.lua;' .. package.path
    package.path = app_dir .. '/?/init.lua;' .. package.path
    package.path = app_dir .. '/.rocks/share/tarantool/?.lua;' .. package.path
    package.path = app_dir .. '/.rocks/share/tarantool/?/init.lua;' .. package.path
    package.cpath = app_dir .. '/?.so;' .. package.cpath
    package.cpath = app_dir .. '/?.dylib;' .. package.cpath
    package.cpath = app_dir .. '/.rocks/lib/tarantool/?.so;' .. package.cpath
    package.cpath = app_dir .. '/.rocks/lib/tarantool/?.dylib;' .. package.cpath
end

local cartridge = require('cartridge')

local ok, err = cartridge.cfg({
    roles = {
        'cartridge.roles.vshard-storage',
        'cartridge.roles.vshard-router',
        'cartridge.roles.metrics',
        'app.roles.api',
        'app.roles.storage',
    },
    cluster_cookie = 'cars-cluster-cookie',
})

assert(ok, tostring(err))

local admin = require('app.admin')
admin.init()

local metrics = require('cartridge.roles.metrics')
metrics.set_export({
    {
        path = '/metrics',
        format = 'prometheus'
    },
    {
        path = '/health',
        format = 'health'
    }
})
