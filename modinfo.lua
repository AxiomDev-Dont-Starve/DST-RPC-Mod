-- This information tells other players more about the mod
name = "DST-Discord RPC Mod"
description = "Show off what you're doing in-game with Discord Rich Presence!\nExternal proxy program required."
author = "ArmoredFuzzball"
version = "v0.2.0"

-- PLEASE NOTE: This version of the rich presence mod uses the [Nodejs] proxy server!
-- It can be found here: https://github.com/AxiomDev-Dont-Starve/DST-RPC-Proxy

-- This is the URL name of the mod's thread on the forum; the part after the index.php? and before the first & in the URL
-- Example:
-- http://forums.kleientertainment.com/index.php?/files/file/202-sample-mods/
-- becomes
-- /files/file/202-sample-mods/
forumthread = ""

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