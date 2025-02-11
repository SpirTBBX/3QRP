fx_version 'bodacious'
game 'gta5'

author 'Tazio de Bruin'
title 'ESX Invest'
description 'Invest in companies'
version '1.3'

ui_page 'client/html/UI.html'

dependencies {
    'mysql-async',
    'es_extended'
}

server_scripts {
	'locales/main.lua',
	'locales/en.lua', 
    'config.lua',
    'server/server.lua',
    'server/version.lua',
    '@mysql-async/lib/MySQL.lua'
}

client_scripts {
	'locales/main.lua',
	'locales/en.lua', 
    'config.lua',
    'client/client.lua'
}

export 'openUI'

files {
    'client/html/UI.html',
    'client/html/script.js',
    'client/html/style.css',
    'client/html/media/font/Futura-Bold.woff',
    'client/html/media/img/logo.png'
}