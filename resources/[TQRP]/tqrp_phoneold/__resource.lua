resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

ui_page 'html/ui.html'

files {
	'html/css/balloon.min.css',
	'html/css/all.min.css',
	'html/ui.html',
	'html/css/materialize.min.css',
	'html/css/style.css',
	'html/js/materialize.min.js',
	'html/js/debounce.min.js',
	'html/js/moment.min.js',
	'html/js/script.js',
	'html/images/cursor.png',
	'html/images/background.png',	
	'html/images/s8.png',	
	'html/images/phone-shell.png',
	'html/images/phone-background.jpg',
	'html/images/gurgle.png',
	'html/images/pager.png',
	'html/webfonts/fa-brands-400.eot',
	'html/webfonts/fa-brands-400.svg',
	'html/webfonts/fa-brands-400.ttf',
	'html/webfonts/fa-brands-400.woff',
	'html/webfonts/fa-brands-400.woff2',
	'html/webfonts/fa-regular-400.eot',
	'html/webfonts/fa-regular-400.svg',
	'html/webfonts/fa-regular-400.ttf',
	'html/webfonts/fa-regular-400.woff',
	'html/webfonts/fa-regular-400.woff2',
	'html/webfonts/fa-solid-900.eot',
	'html/webfonts/fa-solid-900.svg',
	'html/webfonts/fa-solid-900.ttf',
	'html/webfonts/fa-solid-900.woff',
	'html/webfonts/fa-solid-900.woff2',
}

client_scripts {
	'client/assistance.lua',
	'client/stocks.lua',
	'client/main.lua',
	'client/twitter.lua',
}

server_script '@mysql-async/lib/MySQL.lua'
server_script "server.lua"


-- DO THIS FOR RECENT EMAILS!
-- TriggerClientEvent('phone:addnotification', src, name, message)
