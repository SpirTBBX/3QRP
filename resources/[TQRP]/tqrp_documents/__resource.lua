resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

ui_page 'html/form.html'

files {
	'html/form.html',
	'html/img/seal.png',
	'html/img/document.jpg',
	'html/img/signature.png',
	'html/img/cursor.png',
	'html/css.css',
	'html/language_en.js',
	'html/language_gr.js',
	'html/language_br.js',
	'html/language_de.js',
	'html/script.js',
	'html/jquery-3.4.1.min.js',
}

server_scripts {
	'config.lua',
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/gr.lua',
	'locales/en.lua',
	'locales/br.lua',
	'locales/de.lua',
	'server.lua',
}

client_scripts {
	'config.lua',
	'@es_extended/locale.lua',
	'locales/gr.lua',
	'locales/en.lua',
	'locales/br.lua',
	'locales/de.lua',
	'GUI.lua',
	'client.lua',
}
