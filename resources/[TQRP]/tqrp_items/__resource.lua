resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'LosSantosRP Useable Items'

version '1.0.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'server/main.lua',
	'config.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'client/main.lua',
	'config.lua'
}

dependencies {
	'es_extended',
	'cron',
	'tqrp_addonaccount'
}