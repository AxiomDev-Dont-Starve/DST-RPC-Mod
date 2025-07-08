-- This information tells other players more about the mod
name = "Discord Rich Presence"
description = "Show off what you're doing in-game with Discord Rich Presence!\nExternal proxy program required.\n\nDetailed presence configuration coming soon!"
author = "ArmoredFuzzball"
version = "v0.5.0"

-- PLEASE NOTE: This version of the rich presence mod uses the [Nodejs] proxy server!
-- It can be found here: https://github.com/AxiomDev-Dont-Starve/DST-RPC-Proxy

-- This is the URL name of the mod's thread on the forum; the part after the index.php? and before the first & in the URL
-- Example:
-- http://forums.kleientertainment.com/index.php?/files/file/202-sample-mods/
-- becomes
-- /files/file/202-sample-mods/
forumthread = "/forums/topic/160226-discord-rich-presence-mod-released/"

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

---- Can specify a custom icon for this mod!
icon_atlas = "modicon.xml"
icon = "modicon.tex"

--This lets the clients know that they need to download the mod before they can join a server that is using it.
--all_clients_require_mod = true

--This let's the game know that this mod doesn't need to be listed in the server's mod listing
all_clients_require_mod = false
client_only_mod = true
server_only_mod = false

--Let the mod system know that this mod is functional with Don't Starve Together
dst_compatible = true

--These tags allow the server running this mod to be found with filters from the server listing screen
-- server_filter_tags = {"discord rpc"}

configuration_options = {
    {
        name = "show_update_alert",
        label = "Proxy Update Alerts",
        options = {
            {description = "Show", data = true},
            {description = "Hide", data = false}
        },
        default = true,
        hover = "Show or hide the alert for proxy server updates in the main menu.",
    },
    {
        name = "forwarding_frequency",
        label = "Forwarding Frequency",
        options = {
            {description = "0.1s", data = 0.1},
            {description = "0.2s", data = 0.2},
            {description = "0.3s", data = 0.3},
            {description = "0.4s", data = 0.4},
            {description = "0.5s", data = 0.5},
            {description = "0.6s", data = 0.6},
            {description = "0.7s", data = 0.7},
            {description = "0.8s", data = 0.8},
            {description = "0.9s", data = 0.9},
            {description = "1.0s", data = 1},
            {description = "1.5s", data = 1.5},
        },
        default = 0.4,
        hover = "Changes how often the mod forwards data to the proxy server.\nMore frequent updates increase CPU usage.",
    },
    {
        name = "forward_menu_data",
        label = "Forward Menu Data",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false}
        },
        default = true,
        hover = "Forward menu data to Discord.\nThis includes what menu screens you're viewing.",
    },
    {
        name = "forward_player_data",
        label = "Forward Player Data",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false}
        },
        default = true,
        hover = "Forward player data to Discord.\nThis includes playercount, character name, and ghost status.",
    },
    {
        name = "forward_world_data",
        label = "Forward World Data",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false}
        },
        default = true,
        hover = "Forward world data to Discord.\nThis includes your dimension, day phase, and server game mode.",
    }
}