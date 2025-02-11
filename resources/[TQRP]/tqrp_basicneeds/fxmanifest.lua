fx_version 'adamant'

game 'gta5'

description 'ESX Basic Needs'

version '1.1.5'

server_scripts {
	'@es_extended/locale.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'config.lua',
	'client/efeitodroga.lua',
	'client/main.lua'
}

dependencies {
	'es_extended',
	'tqrp_status'
}

ui_page 'index.html'

files {
	'index.html'
}

export 'DoAcid'

