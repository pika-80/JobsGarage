fx_version 'cerulean'
game 'gta5'

author 'pika80'
description 'Sistema de Garagens Trabalhos'
version '1.0.0'

dependency 'es_extended'

server_scripts {
    '@es_extended/locale.lua',
    'config.lua',
    'server.lua',
}

client_scripts {
    '@es_extended/locale.lua',
    'config.lua',
    'client.lua'
}

shared_script 'config.lua'

