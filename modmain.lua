print("Hello from the Discord Rich Presence Mod!")

local ACTIVITY = {}

local CONFIG_SHOW_UPDATE_ALERT    = GetModConfigData("show_update_alert")
local CONFIG_FORWARDING_FREQUENCY = GetModConfigData("forwarding_frequency")
local CONFIG_FORWARD_MENU_DATA    = GetModConfigData("forward_menu_data")
local CONFIG_FORWARD_PLAYER_DATA  = GetModConfigData("forward_player_data")
local CONFIG_FORWARD_WORLD_DATA   = GetModConfigData("forward_world_data")

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
    return activeScreen and activeScreen.name or "none"
end

local function forwardActivityData()
    local payload = GLOBAL.json.encode_compliant(ACTIVITY)
    GLOBAL.TheSim:QueryServer("http://localhost:4747/update", function() end, "POST", payload)
end

local currentProxyVersion = "Unknown"
GLOBAL.TheSim:QueryServer("http://localhost:4747/version/current", function(response, ok, code)
    if ok and code == 200 then currentProxyVersion = response end
end, "GET")

local latestProxyVersion = ">=v2.2.0"
GLOBAL.TheSim:QueryServer("http://localhost:4747/version/latest", function(response, ok, code)
    if ok and code == 200 then latestProxyVersion = response end
end, "GET")

local function checkServerGameMode()
    local gameMode = GLOBAL.TheNet:GetServerGameMode()
    if gameMode == "lavaarena" then
        ACTIVITY.state = "Playing The Forge"
        ACTIVITY.smallImageText = "ReForged Mod"
        ACTIVITY.smallImageKey = "forge"
        return true
    elseif gameMode == "quagmire" then
        ACTIVITY.state = "Playing The Gorge"
        ACTIVITY.smallImageText = "Re-Gorge-itated Mod"
        ACTIVITY.smallImageKey = "gorge"
        return true
    end
    return false
end

local function updateWorldData()
    if checkServerGameMode() then return end
    local day = GLOBAL.TheWorld.state.cycles + 1
    local season = capfirst(GLOBAL.TheWorld.state.season)
    local phase = ""
    if (GLOBAL.TheWorld:HasTag("cave")) then
        ACTIVITY.smallImageKey = "caves"
        ACTIVITY.smallImageText = "In the Caves"
        phase = GLOBAL.TheWorld.state.iscavenight and "Night" or GLOBAL.TheWorld.state.iscavedusk and "Dusk" or "Day"
    else
        ACTIVITY.smallImageKey = "surface"
        ACTIVITY.smallImageText = "On the Surface"
        phase = GLOBAL.TheWorld.state.isnight and "Night" or GLOBAL.TheWorld.state.isdusk and "Dusk" or "Day"
    end
    ACTIVITY.state =  "Cycle " .. day .. " in " .. season .. " - " .. phase
end

local function updatePlayerData()
    local clientTable = GLOBAL.TheNet:GetClientTable()
    if clientTable == nil then return end
    local isGhost = GLOBAL.ThePlayer:HasTag("playerghost")
    local playerCount = tablelength(clientTable)
    local maxPlayers = GLOBAL.TheNet:GetServerMaxPlayers()
    ACTIVITY.details = "Playing as " .. capfirst(GLOBAL.ThePlayer.prefab) .. (isGhost and " [Ghost]" or "")  .. " (" .. playerCount .. " of " .. maxPlayers .. ")"
end

-- LobbyScreen cannot be detected like other screens
AddClassPostConstruct("screens/redux/lobbyscreen", function()
    if not GLOBAL.TheSim then return end
    ACTIVITY.smallImageKey = ''
    ACTIVITY.smallImageText = ''
    if CONFIG_FORWARD_PLAYER_DATA then
        local playerCount = tablelength(GLOBAL.TheNet:GetClientTable())
        local maxPlayers = GLOBAL.TheNet:GetServerMaxPlayers()
        ACTIVITY.details = "Selecting a character (" .. playerCount .. " of " .. maxPlayers .. ")"
    end
    forwardActivityData()
end)

function CreateProxyUpdatePopup()
	local function onClose() GLOBAL.TheFrontEnd:PopScreen() end
    local function onGitHub()
        local url = "https://github.com/AxiomDev-Dont-Starve/DST-RPC-Proxy/releases/latest"
        GLOBAL.VisitURL(url)
        GLOBAL.TheFrontEnd:PopScreen()
    end

    local PopupDialogScreen = GLOBAL.require("screens/redux/popupdialog")
    GLOBAL.TheFrontEnd:PushScreen(PopupDialogScreen(
        "Discord Rich Presence Proxy Update",
        "Current Proxy Version: " .. currentProxyVersion ..
        "\nLatest Proxy Version: " .. latestProxyVersion ..
        "\nThis alert can be disabled in the mod config.",
        {
            { text = "Visit GitHub", cb = onGitHub },
            { text = "Close", cb = onClose }
	    }
    ))
end

AddClassPostConstruct("screens/redux/multiplayermainscreen", function()
    if currentProxyVersion == latestProxyVersion then return end
    if not CONFIG_SHOW_UPDATE_ALERT then return end
    GLOBAL.scheduler:ExecuteInTime(0.6, CreateProxyUpdatePopup, "DSTRPC-Popup")
end)

local SCREENS = {
    MultiplayerMainScreen  = "At the Main Menu",
    ServerListingScreen    = "Browsing Games",
    ServerCreationScreen   = "Creating a Game",
    WardrobeScreen         = "Customizing a character's looks",
    CompendiumScreen       = "In the Compendium",
    CollectionScreen       = "In the Curio Cabinet",
    PlayerSummaryScreen    = "Browsing the Item Collection",
    PurchasePackScreen     = "Browsing the Shop",
    ModsScreen             = "Managing Mods",
    ModConfigurationScreen = "Configuring a Mod",
    CreditsScreen          = "Watching the Credits",
    OptionsScreen          = "Changing Options",
    CharacterBioScreen     = "Reading a character's Biography",
    ServerSlotScreen       = "Browsing Save Games",
    MysteryBoxScreen       = "At the Treasury",
    TradeScreen            = "At the Trade Inn",
    WorldGenScreen         = "Generating a World",
    ThankYouPopup          = "Opening a Gift",
    RedeemDialog           = "Entering a Code",
    ItemBoxPreviewer       = "Viewing a Treasure Chest",
    ItemBoxOpenerPopup     = "Opening a Treasure Chest",
}

local skipLoop = CONFIG_FORWARDING_FREQUENCY < 0.3
local function main()
    if not GLOBAL.TheSim then return end
    if skipLoop then skipLoop = false return end
    -- reset state
    ACTIVITY.smallImageKey = ''
    ACTIVITY.smallImageText = ''
    ACTIVITY.details = 'Loading...'
    ACTIVITY.state = ''
    -- set menu data
    if CONFIG_FORWARD_MENU_DATA then
        local screen = GetCurrentScreenName()
        if SCREENS[screen] then ACTIVITY.details = SCREENS[screen] end
    end
    -- set world data
    if GLOBAL.TheWorld then
        if CONFIG_FORWARD_WORLD_DATA then updateWorldData() end
        -- set player data
        if CONFIG_FORWARD_PLAYER_DATA and GLOBAL.ThePlayer then updatePlayerData() end
    end
    forwardActivityData()
end

GLOBAL.scheduler:ExecutePeriodic(CONFIG_FORWARDING_FREQUENCY, main, nil, nil, "DSTRPC-Loop")