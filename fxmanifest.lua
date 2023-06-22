fx_version 'cerulean'
game 'gta5'

version '0.0'
description 'https://github.com/Project-Sloth/nc-dispatch'

shared_scripts {
    'config.lua',
    'locales/locales.lua',
}

client_scripts{
    '@vrp/lib/utils.lua',
    'client/cl_main.lua',
    'client/cl_events.lua',
    'client/cl_extraalerts.lua',
    'client/cl_commands.lua',
    'client/cl_loops.lua',
}
server_script {
    '@oxmysql/lib/MySQL.lua',
    '@vrp/lib/utils.lua',
    'server/sv_dispatchcodes.lua',
    'server/sv_main.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/app.js',
    'ui/style.css',
}
