print("Hello from the DST-Discord RPC Mod!")

local ACTIVITY = {
    largeImageKey = 'large-image',
    largeImageText = 'DST-RPC-Mod on GitHub',
    details = 'Loading...'
}

local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local function capfirst(string)
    return string:gsub("^%l", string.upper)
end

local function GetCurrentScreenName()
    local activeScreen = GLOBAL.TheFrontEnd:GetActiveScreen()
    return activeScreen and activeScreen.name or nil
end

local function forwardActivityData()
    ACTIVITY.nonce = math.random(0, 9999)
    local payload = GLOBAL.json.encode(ACTIVITY)
    -- interchangeable with Discord Game SDK, IPC pipe, websocket, or proxy server (IPC pipe failed: sandbox too restrictive)
    if not GLOBAL.TheSim then return end
    GLOBAL.TheSim:QueryServer("http://localhost:4747/update", function() end, "POST", payload) --post to custom proxy server
end

local function checkServerGameMode()
    local gameMode = GLOBAL.TheNet:GetServerGameMode()
    if gameMode == "lavaarena" then
        ACTIVITY.state = "Playing The Forge"
        ACTIVITY.smallImageText = "ReForged Mod"
        ACTIVITY.smallImageKey = "forge"
    elseif gameMode == "quagmire" then
        ACTIVITY.state = "Playing The Gorge"
        ACTIVITY.smallImageText = "Re-Gorge-itated Mod"
        ACTIVITY.smallImageKey = "gorge"
    end
end

local function updateWorldData()
    if not GLOBAL.TheWorld then return end
    local isInCaves = GLOBAL.TheWorld:HasTag("cave")
    ACTIVITY.smallImageKey = isInCaves and "caves" or "surface"
    ACTIVITY.smallImageText = isInCaves and "In the Caves" or "On the Surface"
    local season = GLOBAL.TheWorld.state.season
    local dayPhase = GLOBAL.TheWorld.state.isnight and "Night" or GLOBAL.TheWorld.state.isdusk and "Dusk" or "Day"
    local caveDayPhase = GLOBAL.TheWorld.state.iscavenight and "Night" or GLOBAL.TheWorld.state.iscavedusk and "Dusk" or "Day"
    local day = GLOBAL.TheWorld.state.cycles + 1
    ACTIVITY.state =  "Cycle " .. day .. " in " .. capfirst(season) .. " - " .. (isInCaves and caveDayPhase or dayPhase)
    checkServerGameMode()
end

local function updatePlayerData()
    if not GLOBAL.ThePlayer then return end
    local playerCount = tablelength(GLOBAL.TheNet:GetClientTable())
    local maxPlayers = GLOBAL.TheNet:GetServerMaxPlayers()
    local isGhost = GLOBAL.ThePlayer:HasTag("playerghost")
    ACTIVITY.details = "Playing as " .. capfirst(GLOBAL.ThePlayer.prefab) .. (isGhost and " [Ghost]" or "")  .. " (" .. playerCount .. " of " .. maxPlayers .. ")"
end

local function updateMenuData(string, saveState)
    if not saveState then ACTIVITY.state = "" end
    ACTIVITY.details = string
    ACTIVITY.smallImageKey = ""
    ACTIVITY.smallImageText = ""
end

-- LobbyScreen cannot be detected like other screens
AddClassPostConstruct("screens/redux/lobbyscreen", function()
    local playerCount = tablelength(GLOBAL.TheNet:GetClientTable())
    local maxPlayers = GLOBAL.TheNet:GetServerMaxPlayers()
    updateMenuData("Selecting a character (" .. playerCount .. " of " .. maxPlayers .. ")", true)
    forwardActivityData()
end)

GLOBAL.scheduler:ExecutePeriodic(1, function()
    updateWorldData()
    updatePlayerData()
    local screen = GetCurrentScreenName()
    if not screen then forwardActivityData() return end -- optimization
    if     screen == "MultiplayerMainScreen" then updateMenuData("At the Main Menu")
    elseif screen == "ServerListingScreen"   then updateMenuData("Browsing Games")
    elseif screen == "ServerCreationScreen"  then updateMenuData("Creating a Game")
    elseif screen == "WardrobeScreen"        then updateMenuData("Customizing a character's looks")
    elseif screen == "CompendiumScreen"      then updateMenuData("In the Compendium")
    elseif screen == "CollectionScreen"      then updateMenuData("In the Curio Cabinet")
    elseif screen == "PlayerSummaryScreen"   then updateMenuData("Browsing the Item Collection")
    elseif screen == "PurchasePackScreen"    then updateMenuData("Browsing the Shop")
    elseif screen == "ModsScreen"            then updateMenuData("Managing Mods")
    elseif screen == "CreditsScreen"         then updateMenuData("Watching the Credits")
    elseif screen == "OptionsScreen"         then updateMenuData("Changing Options")
    elseif screen == "CharacterBioScreen"    then updateMenuData("Reading a character's biography")
    elseif screen == "ServerSlotScreen"      then updateMenuData("Browsing Save Games")
    elseif screen == "MysteryBoxScreen"      then updateMenuData("At the Treasury")
    elseif screen == "TradeScreen"           then updateMenuData("At the Trade Inn") end
    forwardActivityData()
end, nil, nil, "DSTD")