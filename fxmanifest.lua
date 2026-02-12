fx_version 'cerulean'
game 'gta5'

description 'Discord role → give ox_inventory weapons via commands'
version '1.0'

server_only 'yes'

server_scripts {
    'config.lua',
    'server.lua'
}

dependencies {
    'ox_inventory',
    'ox_lib'    -- optional but usually already present
}