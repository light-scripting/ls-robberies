fx_version "cerulean"
game "gta5"
lua54 "yes"

author "lnd"
description "A simple script for stealing from NPCs with ox skill check"

files {
    "web/build/index.html",
    "web/build/**/*",
    "locales/*.json",
    "client/modules/*.lua"
}

shared_scripts {
    "@ox_lib/init.lua",
    "configs/config.lua",
    "shared/*.lua",
    "@es_extended/imports.lua",
}

client_scripts {
    "utils/client/*.lua",
    "client/main.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "configs/sv-config.lua",
    "utils/server/*.lua",
    "server/main.lua",
}

escrow_ignore {
    "utils/client/editable.lua",
    "utils/server/editable.lua",
    "configs/sv-config.lua",
    "configs/config.lua",
    "locales/*.json",
}
