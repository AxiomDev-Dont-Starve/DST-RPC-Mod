print("Hello from the Discord Rich Presence Mod!")

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
    local season = capfirst(GLOBAL.TheWorld.state.season)
    local day = GLOBAL.TheWorld.state.cycles + 1
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
    local playerCount = tablelength(clientTable)
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
    if GLOBAL.TheSim then forwardActivityData() end
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
    if not GetModConfigData("show_update_alert") then return end
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

GLOBAL.scheduler:ExecutePeriodic(0.4, function()
    if not GLOBAL.TheSim then return end
    if GLOBAL.TheWorld then
        updateWorldData()
        if GLOBAL.ThePlayer then updatePlayerData() end
    end
    local screen = GetCurrentScreenName()
    if SCREENS[screen] then updateMenuData(SCREENS[screen]) end
    forwardActivityData()
end, nil, nil, "DSTRPC-Loop")