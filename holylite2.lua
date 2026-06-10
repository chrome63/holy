--==================================================
-- HOLY SNIPER LITE
-- v0.1 UI SHELL ONLY
--==================================================

--==================================================
-- [0] SERVICES
--==================================================

local Players =
    game:GetService("Players")

local TeleportService =
    game:GetService("TeleportService")

local HttpService =
    game:GetService("HttpService")

local ReplicatedStorage =
    game:GetService("ReplicatedStorage")

local CoreGui =
    game:GetService("CoreGui")

local VirtualUser =
    game:GetService("VirtualUser")
--==================================================
-- [0.1] PLACE CONSTANTS
--==================================================

local TRADING_WORLD_PLACE_ID =
    129954712878723

local GROW_A_GARDEN_PLACE_ID =
    126884695634066

--==================================================
-- [1] UI URLS
--==================================================

local REPO_URL =
    "https://raw.githubusercontent.com/bencapalot041/goons/main/"

local OBSIDIAN_URL =
    REPO_URL
    .. "librarylite.lua?v="
    .. tostring(os.time())

local THEME_MANAGER_URL =
    REPO_URL
    .. "addons/ThemeManager.lua?v="
    .. tostring(os.time())

local SAVE_MANAGER_URL =
    REPO_URL
    .. "addons/SaveManager.lua?v="
    .. tostring(os.time())

--==================================================
-- [2] BASIC LOAD
--==================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local LocalPlayer =
    Players.LocalPlayer

if not LocalPlayer then
    warn("[HOLY SNIPER LITE] LocalPlayer missing.")
    return
end

--==================================================
-- [2.0A] DEV ACCESS
--==================================================

local LiteDeveloperUserIds = {
    [78428093] = true,
}

function IsLiteDeveloper()

    return LocalPlayer
        and LiteDeveloperUserIds[LocalPlayer.UserId] == true
end

local HolyLiteRuntimeRoot =
    (
        type(getgenv) == "function"
        and getgenv()
        or _G
    ).HOLY_LITE_RUNTIME_ROOT
    or {}

if type(getgenv) == "function" then
    getgenv().HOLY_LITE_RUNTIME_ROOT =
        HolyLiteRuntimeRoot
else
    _G.HOLY_LITE_RUNTIME_ROOT =
        HolyLiteRuntimeRoot
end

local HolyLiteRunId =
    tostring(os.clock())
    .. "_"
    .. tostring(math.random(100000, 999999))

HolyLiteRuntimeRoot.RunId =
    HolyLiteRunId

function IsHolyLiteCurrentRun()

    return HolyLiteRuntimeRoot
        and HolyLiteRuntimeRoot.RunId == HolyLiteRunId
end
--==================================================
-- [2.0] RESET HELPERS
--==================================================

function DeleteFileIfExists(path)

    if type(isfile) ~= "function"
    or type(delfile) ~= "function" then
        return false
    end

    local exists =
        false

    pcall(function()
        exists =
            isfile(path)
    end)

    if exists ~= true then
        return false
    end

    local ok =
        pcall(function()
            delfile(path)
        end)

    return ok == true
end

function ResetHolyLiteConfig()

    local deleted = 0

    local paths = {
    "HolySniperLite/autosave.json",
    "HolySniperLite/autosave_v2.json",
    "HolySniperLite/settings/autosave.json",
    "HolySniperLite/settings/autosave_v2.json",
    "HolySniperLite/SniperFilters.json",
    "HolySniperLite/AvoidUsers.json",
}

    for _, path in ipairs(paths) do

        if DeleteFileIfExists(path) then
            deleted =
                deleted + 1
        end
    end

    warn(
        "[HOLY SNIPER LITE] Reset complete. Deleted files:",
        tostring(deleted),
        "| Re-execute the script now."
    )

    return deleted
end

getgenv().HOLY_LITE_RESET =
    ResetHolyLiteConfig
--==================================================
-- [2.1] WORLD HELPERS
--==================================================

function IsTradeWorld()

    return game.PlaceId == TRADING_WORLD_PLACE_ID
end

function IsGardenWorld()

    return game.PlaceId == GROW_A_GARDEN_PLACE_ID
end

function CanRunTradeSniper()

    return IsTradeWorld()
end
--==================================================
-- [3] OBSIDIAN LOAD
--==================================================

local Library =
    loadstring(
        game:HttpGet(OBSIDIAN_URL)
    )()

local ThemeManager =
    loadstring(
        game:HttpGet(THEME_MANAGER_URL)
    )()

local SaveManager =
    loadstring(
        game:HttpGet(SAVE_MANAGER_URL)
    )()

--==================================================
-- [3.1] DEVICE HELPERS
--==================================================

local DeviceState = {
    IsMobile = Library.IsMobile == true,
}

function IsMobileClient()

    return DeviceState.IsMobile == true
end

--==================================================
-- [3.9] EARLY UI SETTINGS
--==================================================

local LITE_UI_SETTINGS_FILE =
    "HolySniperLite/UISettings.json"

local LiteUIState = {
    ShowUIOnLoad = true,
    AutoTeleportTradeWorld = false,
}

function CanUseLiteUISettingsFile()

    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

function EnsureLiteUISettingsFolder()

    if type(makefolder) ~= "function"
    or type(isfolder) ~= "function" then
        return false
    end

    local ok =
        pcall(function()

            if not isfolder("HolySniperLite") then
                makefolder("HolySniperLite")
            end
        end)

    return ok == true
end

function LoadLiteUISettingsEarly()

    if not CanUseLiteUISettingsFile() then
        return false
    end

    local exists =
        false

    local existsOk =
        pcall(function()
            exists =
                isfile(LITE_UI_SETTINGS_FILE)
        end)

    if existsOk ~= true
    or exists ~= true then
        return false
    end

    local readOk, raw =
        pcall(function()
            return readfile(LITE_UI_SETTINGS_FILE)
        end)

    if readOk ~= true
    or type(raw) ~= "string"
    or raw == "" then
        return false
    end

    local decodeOk, payload =
        pcall(function()
            return HttpService:JSONDecode(raw)
        end)

    if decodeOk ~= true
    or type(payload) ~= "table" then
        return false
    end

    if type(payload.ShowUIOnLoad) == "boolean" then
        LiteUIState.ShowUIOnLoad =
            payload.ShowUIOnLoad
    end

    if type(payload.AutoTeleportTradeWorld) == "boolean" then
        LiteUIState.AutoTeleportTradeWorld =
            payload.AutoTeleportTradeWorld
    end

    return true
end

function SaveLiteUISettingsNow()

    if not CanUseLiteUISettingsFile() then
        return false
    end

    EnsureLiteUISettingsFolder()

    local payload = {
        ShowUIOnLoad =
            LiteUIState.ShowUIOnLoad == true,

        AutoTeleportTradeWorld =
            LiteUIState.AutoTeleportTradeWorld == true,
    }

    local ok, encoded =
        pcall(function()
            return HttpService:JSONEncode(payload)
        end)

    if ok ~= true
    or type(encoded) ~= "string" then
        return false
    end

    local writeOk =
        pcall(function()
            writefile(
                LITE_UI_SETTINGS_FILE,
                encoded
            )
        end)

    return writeOk == true
end

LoadLiteUISettingsEarly()

local LiteTradeWorldTeleportState = {
    Token = 0,
    Status = "Idle",
}

function RequestLiteTradeWorldTeleportCountdown(reason)

    if LiteUIState.AutoTeleportTradeWorld ~= true then
        return false
    end

    if IsTradeWorld() then

        LiteTradeWorldTeleportState.Status =
            "Already in Trade World"

        return false
    end

    local player =
        LocalPlayer
        or Players.LocalPlayer

    if not player then

        LiteTradeWorldTeleportState.Status =
            "LocalPlayer missing"

        warn("[HOLY SNIPER LITE] Trade World teleport failed: LocalPlayer missing.")

        return false
    end

    LiteTradeWorldTeleportState.Token =
        LiteTradeWorldTeleportState.Token + 1

    local token =
        LiteTradeWorldTeleportState.Token

    LiteTradeWorldTeleportState.Status =
        "Teleporting in 10s"

    print(
        "[HOLY SNIPER LITE] Auto Trade World teleport armed:",
        tostring(reason or "manual"),
        "| 10 seconds"
    )

    task.delay(10, function()

        if not IsHolyLiteCurrentRun() then
            return
        end

        if token ~= LiteTradeWorldTeleportState.Token then
            return
        end

        if LiteUIState.AutoTeleportTradeWorld ~= true then

            LiteTradeWorldTeleportState.Status =
                "Cancelled"

            print("[HOLY SNIPER LITE] Auto Trade World teleport cancelled.")

            return
        end

        if IsTradeWorld() then

            LiteTradeWorldTeleportState.Status =
                "Already in Trade World"

            return
        end

        LiteTradeWorldTeleportState.Status =
            "Teleporting..."

        print("[HOLY SNIPER LITE] Teleporting to Trade World...")

        local ok, err =
            pcall(function()

                TeleportService:Teleport(
                    TRADING_WORLD_PLACE_ID,
                    player
                )
            end)

        if ok ~= true then

            LiteTradeWorldTeleportState.Status =
                "Teleport failed"

            warn(
                "[HOLY SNIPER LITE] Trade World teleport failed:",
                tostring(err)
            )
        end
    end)

    return true
end

function CancelLiteTradeWorldTeleportCountdown()

    LiteTradeWorldTeleportState.Token =
        LiteTradeWorldTeleportState.Token + 1

    LiteTradeWorldTeleportState.Status =
        "Cancelled"

    print("[HOLY SNIPER LITE] Auto Trade World teleport countdown cancelled.")
end

--==================================================
-- [4] WINDOW
--==================================================
if LiteUIState.AutoTeleportTradeWorld == true
and not IsTradeWorld() then

    RequestLiteTradeWorldTeleportCountdown(
        "startup"
    )
end

local Window =
    Library:CreateWindow({
        Title = '<font color="rgb(232,230,240)">Holy</font> <font color="rgb(196,181,253)"><b>LITE</b></font>',
        Footer = "holy lite · private build",
        ToggleKeybind = Enum.KeyCode.LeftAlt,
        Font = Enum.Font.GothamMedium,
        Center = true,
        AutoShow = LiteUIState.ShowUIOnLoad == true,

        Size = UDim2.fromOffset(840, 560),
        CornerRadius = 6,

        GlobalSearch = true,
        EnableCompacting = true,
        EnableSidebarResize = true,
        MinSidebarWidth = 170,
    })

--==================================================
-- [5] TABS
--==================================================

local Tabs = {
    Home =
        Window:AddTab({
            Name = "Sanctum",
            Icon = "sparkles",
            Description = "Holy center.",
        }),
}

if CanRunTradeSniper() then

    Tabs.Sniper =
        Window:AddTab({
            Name = "Sniper",
            Icon = "crosshair",
            Description = "Sniper filters and watchlist.",
        })

    Tabs.Server =
        Window:AddTab({
            Name = "Server",
            Icon = "server",
            Description = "Server selection and hop memory.",
        })

    Tabs.Webhook =
        Window:AddTab({
            Name = "Webhook",
            Icon = "link",
            Description = "Successful snipe notifications.",
        })
end

if IsGardenWorld() then

    Tabs.Transfer =
        Window:AddTab({
            Name = "Transfer",
            Icon = "gift",
            Description = "Move filtered pets to alts using safe trade automation.",
        })
end

Tabs.Settings =
    Window:AddTab({
        Name = "Settings",
        Icon = "settings",
        Description = "UI preferences.",
    })

if IsLiteDeveloper() then

    Tabs.Dev =
        Window:AddTab({
            Name = "Dev",
            Icon = "terminal",
            Description = "Developer tools.",
        })
end
--==================================================
-- [6] GROUPBOXES
--==================================================

local HomeLeftBox

if type(Tabs.Home.AddLeftCollapsibleGroupbox) == "function" then

    HomeLeftBox =
        Tabs.Home:AddLeftCollapsibleGroupbox(
            "Sanctum",
            "sparkles",
            true
        )

else

    HomeLeftBox =
        Tabs.Home:AddLeftGroupbox(
            "Sanctum",
            "sparkles"
        )
end

local AvoidUsersBox

if type(Tabs.Home.AddLeftCollapsibleGroupbox) == "function" then

    AvoidUsersBox =
        Tabs.Home:AddLeftCollapsibleGroupbox(
            "Anti Alt",
            "shield",
            true
        )

else

    AvoidUsersBox =
        Tabs.Home:AddLeftGroupbox(
            "Anti Alt",
            "shield"
        )
end

local HomeRightBox

if type(Tabs.Home.AddRightCollapsibleGroupbox) == "function" then

    HomeRightBox =
        Tabs.Home:AddRightCollapsibleGroupbox(
            "Presence",
            "activity",
            true
        )

else

    HomeRightBox =
        Tabs.Home:AddRightGroupbox(
            "Presence",
            "activity"
        )
end

--==================================================
-- SANCTUM: GARDEN WORLD ACTION
-- Only visible in Garden World.
--==================================================

if IsGardenWorld() then

    HomeLeftBox:AddButton({
        Text = "Rejoin",
        Tooltip = "Teleport to normal Grow a Garden.",
        Func = function()

            local player =
                LocalPlayer
                or Players.LocalPlayer

            if not player then
                warn("[HOLY SNIPER LITE] Garden teleport failed: LocalPlayer missing.")
                return
            end

            print("[HOLY SNIPER LITE] Teleporting to Garden World...")

            local ok, err =
                pcall(function()

                    TeleportService:Teleport(
                        GROW_A_GARDEN_PLACE_ID,
                        player
                    )
                end)

            if ok ~= true then

                warn(
                    "[HOLY SNIPER LITE] Garden teleport failed:",
                    tostring(err)
                )
            end
        end,
    })
end

local PresenceStateLabel =
    HomeRightBox:AddLabel({
        Text = '<font color="rgb(103,232,249)"><b>● IDLE</b></font>',
        DoesWrap = false,
        Size = 15,
    })

local PresenceSpacerLabel =
    HomeRightBox:AddLabel({
        Text = " ",
        DoesWrap = false,
        Size = 4,
    })

local PresenceStatsList =
    nil

local RecentSnipesLabel =
    nil

if type(HomeRightBox.AddStatusList) == "function" then

    PresenceStatsList =
        HomeRightBox:AddStatusList("PresenceStats", {
            RowHeight = 24,
            KeyWidth = 0.31,

            Rows = {
                {
                    "SERVER",
                    "Ready",
                },

                {
                    "AUTO HOP",
                    "Ready / 30s",
                },

                {
                    "BOOTHS",
                    "0",
                },

                {
                    "LISTINGS",
                    "0",
                },

                {
                    "MATCHES",
                    "0",
                },

                {
                    "BUY",
                    "Idle",
                },

                {
                    "LAST ERROR",
                    "None",
                },

                {
                    "SESSION",
                    "00:00",
                },

                {
                    "BOUGHT",
                    "0",
                },

                {
                    "LAST",
                    "None",
                },
            },
        })

else

    warn("[HOLY SNIPER LITE] AddStatusList missing from library. Using old Presence labels.")

    PresenceStatsList =
        nil
end

RecentSnipesLabel =
    HomeRightBox:AddLabel({
        Text = '<font color="rgb(125,116,145)"><b>RECENT SNIPES</b></font>\nNone',
        DoesWrap = true,
        Size = 13,
    })

local SniperFilterBox
local SniperWatchlistBox
local SniperRuntimeBox

if Tabs.Sniper then

    if type(Tabs.Sniper.AddLeftCollapsibleGroupbox) == "function" then

        SniperFilterBox =
            Tabs.Sniper:AddLeftCollapsibleGroupbox(
                "Filter",
                "filter",
                true
            )

    else

        SniperFilterBox =
            Tabs.Sniper:AddLeftGroupbox(
                "Filter",
                "filter"
            )
    end

    if type(Tabs.Sniper.AddRightCollapsibleGroupbox) == "function" then

        SniperWatchlistBox =
            Tabs.Sniper:AddRightCollapsibleGroupbox(
                "Watchlist",
                "list",
                true
            )

        SniperRuntimeBox =
            Tabs.Sniper:AddRightCollapsibleGroupbox(
                "Runtime",
                "activity",
                true
            )

    else

        SniperWatchlistBox =
            Tabs.Sniper:AddRightGroupbox(
                "Watchlist",
                "list"
            )

        SniperRuntimeBox =
            Tabs.Sniper:AddRightGroupbox(
                "Runtime",
                "activity"
            )
    end
end

local ServerRouteBox
local ServerGatewayBox
local ServerCurrentBox
local ServerMemoryBox

if Tabs.Server then

    if type(Tabs.Server.AddLeftCollapsibleGroupbox) == "function" then

        ServerRouteBox =
            Tabs.Server:AddLeftCollapsibleGroupbox(
                "Route",
                "route",
                true
            )

        ServerMemoryBox =
            Tabs.Server:AddLeftCollapsibleGroupbox(
                "Memory",
                "database",
                true
            )

    else

        ServerRouteBox =
            Tabs.Server:AddLeftGroupbox(
                "Route",
                "route"
            )

        ServerMemoryBox =
            Tabs.Server:AddLeftGroupbox(
                "Memory",
                "database"
            )
    end

    if type(Tabs.Server.AddRightCollapsibleGroupbox) == "function" then

        ServerCurrentBox =
            Tabs.Server:AddRightCollapsibleGroupbox(
                "Current",
                "activity",
                true
            )

        ServerGatewayBox =
            Tabs.Server:AddRightCollapsibleGroupbox(
                "Gateway",
                "link",
                true
            )

    else

        ServerCurrentBox =
            Tabs.Server:AddRightGroupbox(
                "Current",
                "activity"
            )

        ServerGatewayBox =
            Tabs.Server:AddRightGroupbox(
                "Gateway",
                "link"
            )
    end
end

local WebhookConfigBox

local SettingsInterfaceBox

local DevToolsBox

if Tabs.Webhook then

    if type(Tabs.Webhook.AddLeftCollapsibleGroupbox) == "function" then

        WebhookConfigBox =
            Tabs.Webhook:AddLeftCollapsibleGroupbox(
                "Configuration",
                "link",
                true
            )

    else

        WebhookConfigBox =
            Tabs.Webhook:AddLeftGroupbox(
                "Configuration",
                "link"
            )
    end
end


if Tabs.Settings then

    if type(Tabs.Settings.AddLeftCollapsibleGroupbox) == "function" then

        SettingsInterfaceBox =
            Tabs.Settings:AddLeftCollapsibleGroupbox(
                "Interface",
                "settings",
                true
            )

    else

        SettingsInterfaceBox =
            Tabs.Settings:AddLeftGroupbox(
                "Interface",
                "settings"
            )
    end
end

if Tabs.Dev then

    if type(Tabs.Dev.AddLeftCollapsibleGroupbox) == "function" then

        DevToolsBox =
            Tabs.Dev:AddLeftCollapsibleGroupbox(
                "Tools",
                "terminal",
                true
            )

    else

        DevToolsBox =
            Tabs.Dev:AddLeftGroupbox(
                "Tools",
                "terminal"
            )
    end
end
--==================================================
-- [7] RUNTIME STATE
--==================================================

local RuntimeState = {
    SniperEnabled = false,
    AutoHop = false,
    ScanDuration = 30,

    SniperMode = "Standard",

    CustomOpeningStrike = false,
    CustomChainStrike = false,
    CustomStrikeLimit = 3,
    CustomSilentBuyPath = false,

    ExtraStaySeconds = 10,
    ExtraStayUntil = 0,

    SessionStartedAt = os.clock(),
    BoughtCount = 0,
    LastSnipeText = "None",
    LastErrorText = "None",

    RecentSnipes = {},

    ForceStopped = false,

    Status = "Idle",
    BoothStatus = "Not ready",
    BoothDataAge = 0,
    BoothCount = 0,
    PlayerDataCount = 0,
    LastBoothRefreshAt = 0,

    ListingsCount = 0,
    ScannedListingCount = 0,
    LastExtractMs = 0,
    LastExtractAt = 0,

    MatchesCount = 0,
    LastMatchMs = 0,
    LastMatchText = "None",

    BestText = "None",
    BestPrice = 0,
    BestBooth = "None",

    PriorityTarget = "None",

    BuyRemotePath = "Not resolved",
    BuyStatus = "Idle",

    WebhookEnabled = false,
    WebhookSuccessfulSnipes = true,
    WebhookRejectedBuys = false,
    WebhookURL = "",

    TimingDebugEnabled = false,
    TimingDebugURL = "",
}


local ServerState = {
    Mode = "Fullest Under Max",
    MaxPlayers = 30,
    SearchPages = 0,
    AvoidRecent = true,

    BlockDuration = 60,

    IsHopping = false,
    ScanStartedAt = 0,

    LastHop = "None",
    LastTarget = "None",
    LastError = "None",

    RecentServers = {},
    BlockedServers = {},
}

local GatewayState = {
    HudEnabled = false,

    TargetText = "",
    LastTargetText = "",

    StatusText = "Paste a server link.",
    PreviewText = "Paste a server link.",

    ExactOnlyUntil = 0,
}

local AvoidUsersState = {
    Enabled = false,
    AutoHopOnMatch = true,

    RawInput = "",

    StatusText = "● Off",
    LastDetectedName = "None",
    LastCheckAt = 0,
    CheckInterval = 2.5,

    Users = {},
    UserIds = {},
}

local TeleportRetryState = {
    Retrying = false,
    Attempt = 0,
    MaxAttempts = 12,

    LastTarget = nil,
    BlockedServers = {},

    RetryDelay = 0.05,
}

local FilterState = {
    SaveTarget = 1,

    AllowMultiSelectPets = false,

    SelectedPet = "None",
    SelectedPets = {},

    SelectedEgg = "None",
    SelectedEggs = {},

    MaxPrice = nil,
    MaxPriceWasEntered = false,

    MinWeight = 0,
    MinWeightWasEntered = false,

    WeightMode = "Base Weight",
    Priority = "Normal",

    MutationMode = "Off",
    SelectedMutations = {},
}

local SniperFilterSets = {
    [1] = {}, -- W1 Main
    [2] = {}, -- W2 Alt
    [3] = {}, -- Eggs
}

local WatchlistState = {
    ViewTarget = 1,
    SearchText = "",
    Page = 1,
    PerPage = 8,

    SelectedWatchlistId = nil,
    SelectedPet = nil,
}

local RefreshWatchlist =
    nil

local WatchlistViewButtons =
    {}

local WatchlistRowButtons =
    {}

local WatchlistFilterList =
    nil

local WatchlistVisibleEntries =
    {}

local WatchlistStatusLabel =
    nil

local WatchlistImportPasteInput =
    nil

local WatchlistImportPreviewLabel =
    nil

local WatchlistTransferState = {
    ImportText = "",
    PreviewText = "Paste watchlist code.",
}

local LiteAllowMultiSelectToggle =
    nil

local SinglePetDropdown =
    nil

local MultiPetDropdown =
    nil

local SingleEggDropdown =
    nil

local MultiEggDropdown =
    nil

local MaxPriceInput =
    nil

local MinWeightInput =
    nil

local WeightModeDropdown =
    nil

local PriorityDropdown =
    nil

local MutationModeDropdown =
    nil

local MutationDropdown =
    nil    

local SNIPER_FILTER_SAVE_FOLDER =
    "HolySniperLite"

local SNIPER_FILTER_SAVE_FILE =
    "HolySniperLite/SniperFilters.json"

local TRANSFER_SETTINGS_SAVE_FILE =
    "HolySniperLite/TransferSettings.json"

local SaveSniperFiltersNow =
    nil

local LoadSniperFiltersNow =
    nil

local LiteTradeBoothController =
    nil

local LiteBoothStore =
    nil

local LatestBoothData =
    nil

local LatestBoothUpdate =
    0

local LiteBoothRefreshWorkerRunning =
    false

local LITE_BOOTH_REFRESH_INTERVAL =
    0.04

local LITE_MAX_BOOTH_CACHE_AGE =
    0.35

local RuntimeStatusLabel =
    nil

local RuntimeBoothDataLabel =
    nil

local RuntimeBoothCountLabel =
    nil

local RuntimePlayerCountLabel =
    nil

local RuntimeListingsLabel =
    nil

local RuntimeScannedLabel =
    nil

local RuntimeExtractLabel =
    nil

local RuntimeMatchesLabel =
    nil

local RuntimeMatchTimeLabel =
    nil

local RuntimeLastMatchLabel =
    nil

local RuntimeBestLabel =
    nil

local RuntimeBestPriceLabel =
    nil

local RuntimeBestBoothLabel =
    nil

local RuntimePriorityTargetLabel =
    nil

local RuntimeBuyRemoteLabel =
    nil

local RuntimeBuyStatusLabel =
    nil

local ServerJobIdLabel =
    nil

local ServerPlayersLabel =
    nil

local ServerAutoHopLabel =
    nil

local ServerMemoryLabel =
    nil

local GatewayHudToggle =
    nil

local GatewayTargetInput =
    nil

local GatewayPreviewLabel =
    nil

local GatewayHudGui =
    nil

local GatewayHudFrame =
    nil

local GatewayHudInput =
    nil

local GatewayHudStatusLabel =
    nil

local AvoidUsersStatusLabel =
    nil

local AvoidUsersListLabel =
    nil

local AvoidUsersFilterList =
    nil

local AvoidUsersVisibleRows =
    {}

local AvoidUsersSelectedIndex =
    nil

local AvoidUsersInput =
    nil

local ExtraStayInput =
    nil

local SniperModeDropdown =
    nil

local SniperModeStatusLabel =
    nil

local CustomOpeningStrikeToggle =
    nil

local CustomChainStrikeToggle =
    nil

local CustomStrikeLimitInput =
    nil

local CustomSilentBuyPathToggle =
    nil

local TimingDebugWarningLabel =
    nil

local TimingDebugURLInput =
    nil

local LiteBuyListingRemote =
    nil

local LiteBuyListingPath =
    nil

local LiteBuyInFlight =
    false

local LiteSniperLoopRunning =
    false

local LiteFailedListingLocks =
    {}

local LiteBoughtListingLocks =
    {}

local LITE_SCAN_INTERVAL =
    0.05

local LITE_FAILED_LOCK_SECONDS =
    6

local LITE_BOUGHT_LOCK_SECONDS =
    20

local LatestLiteListings =
    {}

local LatestLiteMatches =
    {}

local LatestBestCandidate =
    nil

local HardcodedPriorityPets = {

    ["Rainbow Elephant"] = {
        MaxPrice = 80000,
    },

    ["Rainbow Dilophosaurus"] = {
        MaxPrice = 10000,
    },

    ["Rainbow Birb"] = {
        MaxPrice = 10000,
    },

    ["Albino Peacock"] = {
        MaxPrice = 10000,
    },

    ["Ghostly Spider"] = {
        MaxPrice = 10000,
    },

    ["Ghostly Headless Horseman"] = {
        MaxPrice = 5000,
    },

    ["Blue Whale"] = {
        MaxPrice = 5000,
    },

    ["Giant Scorpion"] = {
        MaxPrice = 5000,
    },

    ["Rainbow Fire Wisp"] = {
        MaxPrice = 10000,
    },

    ["Fire Wisp"] = {
        MaxPrice = 50,
    },
}

--==================================================
-- [7.1] DYNAMIC PET / MUTATION LISTS
--==================================================

local PetRegistry =
    nil

local DynamicPetList =
    {
        "None",
    }

local DynamicMutationList =
    {
        "None",
    }

local DynamicEggList =
    {
        "None",
    }

function CleanText(value)

    return tostring(value or "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

function ParseNumberInput(value, fallback)

    local text =
        tostring(value or "")
            :gsub(",", "")
            :gsub("%s+", "")

    local number =
        tonumber(text)

    if number == nil then
        return fallback or 0
    end

    return number
end

function ParseOptionalNumberInput(value)

    local text =
        tostring(value or "")
            :gsub(",", "")
            :gsub("%s+", "")

    if text == "" then
        return nil
    end

    return tonumber(text)
end

function AddUniqueTextValue(target, seen, value)

    local name =
        CleanText(value)

    if name == ""
    or name == "None"
    or name == "---"
    or name == "Normal"
    or name == "Unknown" then
        return false
    end

    if seen[name] == true then
        return false
    end

    seen[name] =
        true

    table.insert(
        target,
        name
    )

    return true
end

function AddUniquePetName(target, seen, value)

    local name =
        CleanText(value)

    if name == "" then
        return false
    end

    -- Do not pollute the normal pet dropdown with egg pseudo-items.
    if name:sub(1, 4) == "Egg/" then
        return false
    end

    if seen[name] == true then
        return false
    end

    seen[name] =
        true

    table.insert(
        target,
        name
    )

    return true
end

function GetPetRegistry()

    if type(PetRegistry) == "table" then
        return PetRegistry
    end

    local ok, result =
        pcall(function()

            local dataFolder =
                ReplicatedStorage:FindFirstChild("Data")
                or ReplicatedStorage:WaitForChild("Data", 5)

            if not dataFolder then
                return nil
            end

            local petRegistryModule =
                dataFolder:FindFirstChild("PetRegistry")
                or dataFolder:WaitForChild("PetRegistry", 5)

            if not petRegistryModule then
                return nil
            end

            return require(petRegistryModule)
        end)

    if ok
    and type(result) == "table" then

        PetRegistry =
            result

        return PetRegistry
    end

    return nil
end

function BuildDynamicPetList()

    local names = {}
    local seen = {}

    local registry =
        GetPetRegistry()

    if type(registry) == "table"
    and type(registry.PetList) == "table" then

        for petName, petData in pairs(registry.PetList) do

            if type(petName) == "string"
            and type(petData) == "table" then

                AddUniquePetName(
                    names,
                    seen,
                    petName
                )
            end
        end
    end

    if #names <= 0 then

        local containers = {
            LocalPlayer and LocalPlayer:FindFirstChild("Backpack"),
            LocalPlayer and LocalPlayer.Character,
        }

        for _, container in ipairs(containers) do

            if container then

                for _, child in ipairs(container:GetChildren()) do

                    if child:IsA("Tool") then

                        local petName =
                            child:GetAttribute("f")
                            or child:GetAttribute("PetType")
                            or child:GetAttribute("PetName")

                        AddUniquePetName(
                            names,
                            seen,
                            petName
                        )
                    end
                end
            end
        end
    end

    table.sort(names)

    table.insert(
        names,
        1,
        "None"
    )

    return names
end

function AddUniqueMutationName(target, seen, value)

    local name =
        CleanText(value)

    if name == ""
    or name == "None"
    or name == "---"
    or name == "Normal"
    or name == "Unknown" then
        return false
    end

    if name == "EnumToPetMutation"
    or name == "PetMutationToEnum"
    or name == "PetMutationRegistry"
    or name == "MachineMutationTypes"
    or name == "RollRandomMutation" then
        return false
    end

    if seen[name] == true then
        return false
    end

    seen[name] =
        true

    table.insert(
        target,
        name
    )

    return true
end

function BuildDynamicEggList()

    local names = {}
    local seen = {}

    local registry =
        GetPetRegistry()

    if type(registry) == "table"
    and type(registry.PetEggs) == "table" then

        for eggName, eggData in pairs(registry.PetEggs) do

            if type(eggName) == "string"
            and type(eggData) == "table"
            and type(eggData.RarityData) == "table"
            and type(eggData.RarityData.Items) == "table" then

                AddUniqueTextValue(
                    names,
                    seen,
                    eggName
                )
            end
        end
    end

    table.sort(names)

    table.insert(
        names,
        1,
        "None"
    )

    return names
end

function GetLiteEggPets(eggName)

    eggName =
        CleanText(eggName)

    if eggName == ""
    or eggName == "None" then
        return {}
    end

    local registry =
        GetPetRegistry()

    if type(registry) ~= "table"
    or type(registry.PetEggs) ~= "table" then
        return {}
    end

    local eggData =
        registry.PetEggs[eggName]

    local items =
        eggData
        and eggData.RarityData
        and eggData.RarityData.Items

    if type(items) ~= "table" then
        return {}
    end

    local pets = {}
    local seen = {}

    for petName in pairs(items) do

        petName =
            CleanText(petName)

        if petName ~= ""
        and seen[petName] ~= true then

            seen[petName] =
                true

            table.insert(
                pets,
                petName
            )
        end
    end

    table.sort(pets)

    return pets
end

function BuildDynamicMutationList()

    local names = {}
    local seen = {}

    local registry =
        GetPetRegistry()

    local mutationRoot =
        type(registry) == "table"
        and rawget(registry, "PetMutationRegistry")
        or nil

    local petMutationRegistry =
        type(mutationRoot) == "table"
        and rawget(mutationRoot, "PetMutationRegistry")
        or nil

    if type(petMutationRegistry) == "table" then

        for mutationName, mutationData in pairs(petMutationRegistry) do

            if type(mutationName) == "string" then

                AddUniqueMutationName(
                    names,
                    seen,
                    mutationName
                )

            elseif type(mutationData) == "string" then

                AddUniqueMutationName(
                    names,
                    seen,
                    mutationData
                )
            end
        end
    end

    if type(mutationRoot) == "table" then

        for mutationName, mutationData in pairs(mutationRoot) do

            if type(mutationName) == "string" then

                AddUniqueMutationName(
                    names,
                    seen,
                    mutationName
                )

            elseif type(mutationData) == "string" then

                AddUniqueMutationName(
                    names,
                    seen,
                    mutationData
                )
            end
        end
    end

    table.sort(names)

    table.insert(
        names,
        1,
        "None"
    )

    return names
end

function RefreshDynamicLists()

    DynamicPetList =
        BuildDynamicPetList()

    DynamicMutationList =
        BuildDynamicMutationList()

    DynamicEggList =
        BuildDynamicEggList()

    print(
        "[HOLY SNIPER LITE] Dynamic pets:",
        tostring(#DynamicPetList)
    )

    print(
        "[HOLY SNIPER LITE] Dynamic mutations:",
        tostring(#DynamicMutationList)
    )

    print(
        "[HOLY SNIPER LITE] Dynamic eggs:",
        tostring(#DynamicEggList)
    )
end

RefreshDynamicLists()

FilterState.SelectedPet =
    DynamicPetList[1]
    or "None"

FilterState.SelectedEgg =
    DynamicEggList[1]
    or "None"
--==================================================
-- [8] SILENT CONFIG HELPERS
--==================================================

local ConfigState = {
    AutosaveName = "autosave_v3",
    Dirty = false,
    Loading = true,
}

function MarkConfigDirty()

    if ConfigState.Loading == true then
        return
    end

    ConfigState.Dirty =
        true
end

function SetControlVisible(control, visible)

    if not control then
        return
    end

    if type(control.SetVisible) == "function" then

        pcall(function()
            control:SetVisible(visible == true)
        end)

        return
    end

    pcall(function()
        control.Visible = visible == true
    end)
end

function SetControlValue(control, value)

    if not control then
        return
    end

    if type(control.SetValue) == "function" then

        pcall(function()
            control:SetValue(value)
        end)

        return
    end

    if type(control.SetValues) == "function"
    and type(value) == "table" then

        pcall(function()
            control:SetValues(value)
        end)
    end
end

function ClearLiteMultiDropdown(control)

    if not control then
        return
    end

    if type(control.SetValue) == "function" then

        pcall(function()
            control:SetValue({})
        end)
    end

    if type(control.SetValues) == "function" then

        pcall(function()
            control:SetValues({})
        end)
    end

    if type(control.Value) == "table" then

        pcall(function()
            table.clear(control.Value)
        end)
    end
end

function SetControlText(control, text)

    if not control then
        return
    end

    if type(control.SetText) == "function" then

        pcall(function()
            control:SetText(tostring(text or ""))
        end)

        return
    end

    if type(control.SetName) == "function" then

        pcall(function()
            control:SetName(tostring(text or ""))
        end)

        return
    end

    pcall(function()
        control.Text = tostring(text or "")
    end)
end

function AddTransferLeftBox(tab, title, icon)

    if not tab then
        return nil
    end

    if type(tab.AddLeftCollapsibleGroupbox) == "function" then

        return tab:AddLeftCollapsibleGroupbox(
            title,
            icon,
            true
        )
    end

    return tab:AddLeftGroupbox(
        title,
        icon
    )
end

function AddTransferRightBox(tab, title, icon)

    if not tab then
        return nil
    end

    if type(tab.AddRightCollapsibleGroupbox) == "function" then

        return tab:AddRightCollapsibleGroupbox(
            title,
            icon,
            true
        )
    end

    return tab:AddRightGroupbox(
        title,
        icon
    )
end

function CopyLiteTransferText(text)

    local clipboard =
        setclipboard
        or toclipboard
        or set_clipboard

    if type(clipboard) ~= "function" then
        warn("[HOLY LITE TRANSFER] Clipboard unsupported.")
        return false
    end

    pcall(function()
        clipboard(tostring(text or ""))
    end)

    return true
end

--==================================================
-- [12.5] TRANSFER SYSTEM
-- Garden World only.
-- Uses DataService PetData.BaseWeight, not visible KG.
--==================================================

if IsGardenWorld() ~= true then
    warn("[HOLY LITE TRANSFER] Transfer system skipped: Garden World only.")
end

local TransferState =
    nil

local TransferConfigState = {
    Loading = true,
    Dirty = false,
    SaveQueued = false,
}

function CopyTransferBoolMap(source)

    local output = {}

    if type(source) ~= "table" then
        return output
    end

    for key, value in pairs(source) do

        if value == true then
            output[tostring(key)] =
                true
        end
    end

    return output
end

function CanUseTransferSettingsFile()

    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

function EnsureTransferSettingsFolder()

    if type(makefolder) ~= "function"
    or type(isfolder) ~= "function" then
        return false
    end

    local ok =
        pcall(function()

            if not isfolder("HolySniperLite") then
                makefolder("HolySniperLite")
            end
        end)

    return ok == true
end

function SaveTransferSettingsNow(reason)

    if CanUseTransferSettingsFile() ~= true then
        return false
    end

    EnsureTransferSettingsFolder()

    local payload = {
        Mode =
            tostring(TransferState.Mode or "Sender"),

        TargetPlayerName =
            tostring(TransferState.TargetPlayerName or ""),

        SelectedPets =
            CopyTransferBoolMap(TransferState.SelectedPets),

        SelectedMutations =
            CopyTransferBoolMap(TransferState.SelectedMutations),

        MaxPetsPerTrade =
            tonumber(TransferState.MaxPetsPerTrade) or 12,

        AddPetDelay =
            tonumber(TransferState.AddPetDelay) or 0.5,

        AddBurstCount =
            tonumber(TransferState.AddBurstCount) or 1,

        NextTicketDelay =
            tonumber(TransferState.NextTicketDelay) or 0,

        AutoAcceptTicket =
            TransferState.AutoAcceptTicket == true,

        AutoConfirm =
            TransferState.AutoConfirm == true,

        AutoAcceptGift =
            TransferState.AutoAcceptGift == true,

        AutoUnfavorite =
            TransferState.AutoUnfavorite == true,

        KeepGoing =
            TransferState.KeepGoing == true,

        DebugPrints =
            TransferState.DebugPrints == true,

        MinLevel =
            tonumber(TransferState.MinLevel) or 1,

        MaxLevel =
            tonumber(TransferState.MaxLevel) or 100,

        MinBaseWeight =
            tonumber(TransferState.MinBaseWeight) or 0,

        MaxBaseWeight =
            tonumber(TransferState.MaxBaseWeight) or 999,

        SavedAt =
            os.time(),

        Reason =
            tostring(reason or "manual"),
    }

    local ok, encoded =
        pcall(function()
            return HttpService:JSONEncode(payload)
        end)

    if ok ~= true
    or type(encoded) ~= "string" then
        return false
    end

    local writeOk =
        pcall(function()

            writefile(
                TRANSFER_SETTINGS_SAVE_FILE,
                encoded
            )
        end)

    return writeOk == true
end

function QueueSaveTransferSettings(reason)

    if TransferConfigState.Loading == true then
        return
    end

    TransferConfigState.Dirty =
        true

    if TransferConfigState.SaveQueued == true then
        return
    end

    TransferConfigState.SaveQueued =
        true

    task.delay(0.35, function()

        TransferConfigState.SaveQueued =
            false

        if TransferConfigState.Dirty ~= true then
            return
        end

        TransferConfigState.Dirty =
            false

        SaveTransferSettingsNow(
            reason or "autosave"
        )
    end)
end

function LoadTransferSettingsIntoState()

    if CanUseTransferSettingsFile() ~= true then
        return false
    end

    local exists =
        false

    local existsOk =
        pcall(function()
            exists =
                isfile(TRANSFER_SETTINGS_SAVE_FILE)
        end)

    if existsOk ~= true
    or exists ~= true then
        return false
    end

    local readOk, raw =
        pcall(function()
            return readfile(TRANSFER_SETTINGS_SAVE_FILE)
        end)

    if readOk ~= true
    or type(raw) ~= "string"
    or raw == "" then
        return false
    end

    local decodeOk, payload =
        pcall(function()
            return HttpService:JSONDecode(raw)
        end)

    if decodeOk ~= true
    or type(payload) ~= "table" then
        return false
    end

    if payload.Mode == "Receiver" then
        TransferState.Mode =
            "Receiver"
    else
        TransferState.Mode =
            "Sender"
    end

    TransferState.TargetPlayerName =
        CleanText(payload.TargetPlayerName)

    if type(payload.SelectedPets) == "table" then
        TransferState.SelectedPets =
            CopyTransferBoolMap(payload.SelectedPets)
    end

    if type(payload.SelectedMutations) == "table" then
        TransferState.SelectedMutations =
            CopyTransferBoolMap(payload.SelectedMutations)
    end

    TransferState.MaxPetsPerTrade =
        math.clamp(
            math.floor(tonumber(payload.MaxPetsPerTrade) or 12),
            1,
            50
        )

    TransferState.AddPetDelay =
        math.clamp(
            tonumber(payload.AddPetDelay) or 0.5,
            0.01,
            3
        )

    TransferState.AddBurstCount =
        math.clamp(
            math.floor(tonumber(payload.AddBurstCount) or 1),
            1,
            50
        )

    TransferState.NextTicketDelay =
        math.clamp(
            tonumber(payload.NextTicketDelay) or 0,
            0,
            60
        )

    TransferState.AutoAcceptTicket =
        payload.AutoAcceptTicket ~= false

    TransferState.AutoConfirm =
        payload.AutoConfirm ~= false

    TransferState.AutoAcceptGift =
        payload.AutoAcceptGift == true

    TransferState.AutoUnfavorite =
        payload.AutoUnfavorite ~= false

    TransferState.KeepGoing =
        payload.KeepGoing == true

    TransferState.DebugPrints =
        payload.DebugPrints == true

    TransferState.MinLevel =
        math.max(
            1,
            math.floor(tonumber(payload.MinLevel) or 1)
        )

    TransferState.MaxLevel =
        math.max(
            TransferState.MinLevel,
            math.floor(tonumber(payload.MaxLevel) or 100)
        )

    TransferState.MinBaseWeight =
        math.max(
            0,
            tonumber(payload.MinBaseWeight) or 0
        )

    TransferState.MaxBaseWeight =
        math.max(
            0,
            tonumber(payload.MaxBaseWeight) or 999
        )

    return true
end

function MapHasTransferValue(map, value)

    value =
        CleanText(value)

    if value == "" then
        return false
    end

    return type(map) == "table"
        and map[value] == true
end

function EnsureTransferDropdownChoice(choices, value)

    value =
        CleanText(value)

    if value == "" then
        return choices
    end

    for _, existing in ipairs(choices) do

        if existing == value then
            return choices
        end
    end

    table.insert(
        choices,
        value
    )

    table.sort(choices)

    return choices
end

TransferState = {
    SelectedPets = {},
    SelectedMutations = {},

    Mode = "Sender",
    TargetPlayerName = "",

    TransferEnabled = false,
    KeepGoing = false,
    IsTransferRunning = false,
    WorkerToken = 0,

    MaxPetsPerTrade = 12,
    AddPetDelay = 0.5,
    AddBurstCount = 1,
    NextTicketDelay = 0,

    AutoAcceptTicket = true,
    AutoConfirm = true,
    AutoAcceptGift = false,
    AutoAcceptGiftResponseValue = true,

    Batch = 0,
    AddedThisBatch = 0,

    MinLevel = 1,
    MaxLevel = 100,

    MinBaseWeight = 0,
    MaxBaseWeight = 999,

    AutoUnfavorite = true,

    MatchedPets = {},
    Sent = 0,

    AllPetChoices = {},

    AllMutationChoices = {},

    Status = "Idle",
    LastResult = "None",

    ModeDropdown = nil,
    PetDropdown = nil,
    MutationDropdown = nil,
    TargetDropdown = nil,

    TransferEnabledToggle = nil,
    AutoUnfavoriteToggle = nil,
    KeepGoingToggle = nil,
    MaxPetsInput = nil,
    AddPetDelayInput = nil,
    AddBurstInput = nil,
    NextTicketDelayInput = nil,
    AutoAcceptTicketToggle = nil,
    AutoConfirmToggle = nil,
    AutoAcceptGiftToggle = nil,

    SourceLabel = nil,
    StatusLabel = nil,
    TargetLabel = nil,
    MatchLabel = nil,
    ResultLabel = nil,

    LastSourceRefresh = 0,
    CachedSourceText = "Inventory Parsed: ...",
    IsAddingPets = false,

    TradeOpen = false,
    TradeId = "",
    TradePlayers = {},
    TradeStates = {},
    TradeOfferCounts = {},
    LocalTradeSide = nil,
    OtherTradeSide = nil,
    TradeOwnItemCount = 0,
    TradeOtherItemCount = 0,
    TradeCompleted = false,
    TradeResult = "",
    TradeDeclined = false,
    TradeDeclineReason = "",

    RequestBlocked = false,
    RequestBlockedReason = "",

    RequestExpired = false,
    RequestExpiredReason = "",

    RequestAcceptValue = nil,
    LastRequestAcceptValue = "unknown",

    IncomingRequestId = "",
    IncomingRequestPlayerName = "",
    IncomingRequestAt = 0,
    IncomingRequestHandled = {},

    IncomingGiftHandled = {},
    LastGiftId = "",
    LastGiftPetName = "",
    LastGiftSenderName = "",

    LastTradeUpdate = 0,
    TradeWatchConnected = false,

    DebugPrints = false,
    Timing = {},
}

LoadTransferSettingsIntoState()

function TransferDebugPrint(...)

    if TransferState.DebugPrints == true then
        print(...)
    end
end

function TransferTimingReset(label)

    TransferState.Timing = {
        Label = tostring(label or "Trade"),
        Started = os.clock(),

        ValueSeenAt = nil,
        FirstAcceptAt = nil,
        AcceptLockedAt = nil,
        ConfirmSeenAt = nil,
        CompletedAt = nil,

        Attempts = 0,
        LastValue = 0,
        FirstButton = "",
        LastButton = "",
        Reported = false,
    }
end

function TransferTimingMark(key)

    local timing =
        TransferState.Timing

    if type(timing) ~= "table"
    or not timing.Started then
        return
    end

    if timing[key] == nil then
        timing[key] =
            os.clock() - timing.Started
    end
end

function TransferTimingSet(key, value)

    local timing =
        TransferState.Timing

    if type(timing) ~= "table" then
        return
    end

    timing[key] =
        value
end

function TransferTimingBumpAttempts(count)

    local timing =
        TransferState.Timing

    if type(timing) ~= "table" then
        return
    end

    timing.Attempts =
        (tonumber(timing.Attempts) or 0)
        + (tonumber(count) or 1)
end

function TransferTimingFormat(value)

    value =
        tonumber(value)

    if not value then
        return "-"
    end

    return string.format("%.3fs", value)
end

function TransferTimingReport(reason)

    local timing =
        TransferState.Timing

    if type(timing) ~= "table"
    or timing.Reported == true then
        return
    end

    timing.Reported =
        true

    print(
        "[TRANSFER TIMING]",
        tostring(timing.Label or "Trade"),
        "| reason:",
        tostring(reason or "done"),
        "| value:",
        TransferTimingFormat(timing.ValueSeenAt),
        "| firstAccept:",
        TransferTimingFormat(timing.FirstAcceptAt),
        "| locked:",
        TransferTimingFormat(timing.AcceptLockedAt),
        "| confirm:",
        TransferTimingFormat(timing.ConfirmSeenAt),
        "| completed:",
        TransferTimingFormat(timing.CompletedAt),
        "| attempts:",
        tostring(timing.Attempts or 0),
        "| lastValue:",
        tostring(timing.LastValue or 0),
        "| firstButton:",
        tostring(timing.FirstButton or ""),
        "| lastButton:",
        tostring(timing.LastButton or "")
    )
end

TransferSetStatus =
    nil

TransferAcceptPetGift =
    nil

TransferDataService =
    nil

TransferTradeData =
    nil

TransferPetRegistry =
    nil

function TransferGetTradeData()

    if TransferTradeData then
        return TransferTradeData
    end

    local dataFolder =
        ReplicatedStorage:FindFirstChild("Data")

    local tradeDataModule =
        dataFolder
        and dataFolder:FindFirstChild("TradeData")

    if not tradeDataModule
    or not tradeDataModule:IsA("ModuleScript") then
        return nil
    end

    local ok, result =
        pcall(function()
            return require(tradeDataModule)
        end)

    if ok
    and type(result) == "table" then

        TransferTradeData =
            result

        return TransferTradeData
    end

    return nil
end

function TransferGetTradeItemLimit()

    local tradeData =
        TransferGetTradeData()

    local limit =
        tradeData
        and tonumber(tradeData.ItemLimit)

    return math.clamp(
        math.floor(limit or 12),
        1,
        50
    )
end

function TransferGetMaxPetsPerTrade()

    local tradeLimit =
        TransferGetTradeItemLimit()

    local userLimit =
        tonumber(TransferState.MaxPetsPerTrade)
        or tradeLimit

    return math.clamp(
        math.floor(userLimit),
        1,
        tradeLimit
    )
end

function TransferGetAddPetDelay()

    local delay =
        tonumber(TransferState.AddPetDelay)
        or 0.5

    return math.clamp(
        delay,
        0.01,
        3
    )
end

function TransferGetAddBurstCount()

    local burst =
        tonumber(TransferState.AddBurstCount)
        or 1

    return math.clamp(
        math.floor(burst),
        1,
        TransferGetMaxPetsPerTrade()
    )
end

function TransferGetNextTicketDelay()

    local delay =
        tonumber(TransferState.NextTicketDelay)
        or 0

    return math.clamp(
        delay,
        0,
        60
    )
end

function TransferWaitBeforeNextTicket()

    local delay =
        TransferGetNextTicketDelay()

    if delay <= 0 then
        return
    end

    local started =
        os.clock()

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true
    and os.clock() - started < delay do

        local remaining =
            math.max(
                0,
                delay - (os.clock() - started)
            )

        TransferSetStatus(
            "Ticket Delay",
            "Next trade request in "
                .. string.format("%.1f", remaining)
                .. "s"
        )

        task.wait(0.1)
    end
end

function TransferToNumber(value, fallback)

    local text =
        tostring(value or "")

    text =
        text:gsub(",", "")

    text =
        text:gsub("%s+", "")

    local number =
        tonumber(text)

    if number == nil then
        return fallback or 0
    end

    return number
end

function TransferFormatNumber(value)

    local number =
        tonumber(value)

    if not number then
        return "?"
    end

    if number % 1 == 0 then
        return tostring(math.floor(number))
    end

    return string.format("%.4f", number)
end

function TransferUnpack(list)

    if type(table.unpack) == "function" then
        return table.unpack(list)
    end

    if type(unpack) == "function" then
        return unpack(list)
    end

    if type(list) ~= "table" then
        return nil
    end

    local count =
        #list

    if count == 1 then
        return list[1]
    end

    if count == 2 then
        return list[1], list[2]
    end

    if count == 3 then
        return list[1], list[2], list[3]
    end

    return nil
end

function TransferMapIsEmpty(map)

    if type(map) ~= "table" then
        return true
    end

    for _ in pairs(map) do
        return false
    end

    return true
end

function TransferBuildMapFromDropdown(value)

    local output = {}

    if type(value) == "table" then

        for key, selected in pairs(value) do

            if selected == true then

                key =
                    CleanText(key)

                if key ~= "" then
                    output[key] =
                        true
                end
            end
        end

    elseif type(value) == "string" then

        value =
            CleanText(value)

        if value ~= "" then
            output[value] =
                true
        end
    end

    return output
end

function TransferNormalizeUUID(value)

    value =
        tostring(value or "")
            :gsub("{", "")
            :gsub("}", "")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    if not value:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
        return ""
    end

    return "{" .. value .. "}"
end

function TransferNormalizeUUIDNoBraces(value)

    return tostring(TransferNormalizeUUID(value))
        :gsub("{", "")
        :gsub("}", "")
end

function TransferGetDataService()

    if TransferDataService then
        return TransferDataService
    end

    local modules =
        ReplicatedStorage:FindFirstChild("Modules")

    if not modules then
        return nil
    end

    local dataServiceModule =
        modules:FindFirstChild("DataService")

    if not dataServiceModule then
        return nil
    end

    local ok, result =
        pcall(function()
            return require(dataServiceModule)
        end)

    if ok
    and result then

        TransferDataService =
            result

        return TransferDataService
    end

    return nil
end

function TransferGetDataServiceData()

    local dataService =
        TransferGetDataService()

    if not dataService then
        return nil
    end

    local ok, data =
        pcall(function()
            return dataService:GetData()
        end)

    if ok
    and type(data) == "table" then
        return data
    end

    ok, data =
        pcall(function()
            return dataService.GetData()
        end)

    if ok
    and type(data) == "table" then
        return data
    end

    return nil
end

function TransferGetInventoryData()

    local data =
        TransferGetDataServiceData()

    if type(data) ~= "table" then
        return nil
    end

    local petsData =
        rawget(data, "PetsData")

    local petInventory =
        type(petsData) == "table"
        and rawget(petsData, "PetInventory")
        or nil

    local inventoryData =
        type(petInventory) == "table"
        and rawget(petInventory, "Data")
        or nil

    if type(inventoryData) ~= "table" then
        return nil
    end

    return inventoryData
end

function TransferGetInventoryPetDataByUUID(uuid)

    local inventoryData =
        TransferGetInventoryData()

    if type(inventoryData) ~= "table" then
        return nil, nil
    end

    local noBraces =
        TransferNormalizeUUIDNoBraces(uuid)

    local withBraces =
        TransferNormalizeUUID(uuid)

    local item =
        inventoryData[withBraces]
        or inventoryData[noBraces]

    if type(item) ~= "table" then
        return nil, nil
    end

    local petData =
        rawget(item, "PetData")

    if type(petData) == "table" then
        return petData, item
    end

    return item, item
end

function TransferResolveRawBaseWeight(petData, itemData, tool)

    local sources = {
        petData,
        itemData,
    }

    for _, source in ipairs(sources) do

        if type(source) == "table" then

            local candidates = {
                rawget(source, "BaseWeight"),
                rawget(source, "baseWeight"),
                rawget(source, "Base_Weight"),
                rawget(source, "BaseKg"),
                rawget(source, "BaseKG"),
                rawget(source, "Base"),
            }

            for _, value in ipairs(candidates) do

                local number =
                    tonumber(value)

                if number then
                    return number, "PetData"
                end
            end
        end
    end

    if tool then

        local attrs = {
            "BaseWeight",
            "baseWeight",
            "Base_Weight",
            "BaseKg",
            "BaseKG",
            "Base",
        }

        for _, attr in ipairs(attrs) do

            local number =
                tonumber(
                    tool:GetAttribute(attr)
                )

            if number then
                return number, "ToolAttribute:" .. attr
            end
        end
    end

    return nil, "Missing"
end

function TransferResolveRawLevel(petData, itemData, tool, fallbackAge)

    local sources = {
        petData,
        itemData,
    }

    for _, source in ipairs(sources) do

        if type(source) == "table" then

            local candidates = {
                rawget(source, "Level"),
                rawget(source, "level"),
                rawget(source, "Age"),
                rawget(source, "age"),
                rawget(source, "PetLevel"),
                rawget(source, "PetAge"),
            }

            for _, value in ipairs(candidates) do

                local number =
                    tonumber(value)

                if number then
                    return math.floor(number), "PetData"
                end
            end
        end
    end

    if tool then

        local attrs = {
            "Level",
            "level",
            "Age",
            "age",
        }

        for _, attr in ipairs(attrs) do

            local number =
                tonumber(
                    tool:GetAttribute(attr)
                )

            if number then
                return math.floor(number), "ToolAttribute:" .. attr
            end
        end
    end

    local fallback =
        tonumber(fallbackAge)

    if fallback then
        return math.floor(fallback), "ToolName"
    end

    return 1, "Fallback"
end

function TransferResolvePetName(petData, itemData, tool, fallbackName)

    local candidates = {
        tool and tool:GetAttribute("f"),
        tool and tool:GetAttribute("PetType"),
        tool and tool:GetAttribute("PetName"),

        itemData and rawget(itemData, "PetType"),
        itemData and rawget(itemData, "PetName"),
        itemData and rawget(itemData, "Name"),

        petData and rawget(petData, "PetType"),
        petData and rawget(petData, "PetName"),
        petData and rawget(petData, "Name"),

        fallbackName,
    }

    for _, value in ipairs(candidates) do

        value =
            CleanText(value)

        if value ~= "" then
            return value
        end
    end

    return ""
end

function TransferResolveFavorite(tool, petData, itemData)

    if tool then

        if tool:GetAttribute("d") == true
        or tool:GetAttribute("IsFavorite") == true
        or tool:GetAttribute("Favorite") == true
        or tool:GetAttribute("Favorited") == true then
            return true
        end
    end

    for _, source in ipairs({ petData, itemData }) do

        if type(source) == "table" then

            if rawget(source, "d") == true
            or rawget(source, "IsFavorite") == true
            or rawget(source, "Favorite") == true
            or rawget(source, "Favorited") == true
            or rawget(source, "Favourited") == true then
                return true
            end
        end
    end

    return false
end

function TransferResolveMutation(toolName, basePetName, petData, itemData)

    local function CleanMutation(value)

        value =
            CleanText(value)

        if value == ""
        or value == "---"
        or value == "Normal"
        or value == "Unknown" then
            return nil
        end

        return value
    end

    for _, source in ipairs({ petData, itemData }) do

        if type(source) == "table" then

            local direct = {
                rawget(source, "Mutation"),
                rawget(source, "MutationType"),
                rawget(source, "PetMutation"),
                rawget(source, "Variant"),
            }

            for _, value in ipairs(direct) do

                local cleaned =
                    CleanMutation(value)

                if cleaned then
                    return cleaned
                end
            end

            for _, key in ipairs({
                "Mutations",
                "MutationData",
                "MutationTraits",
                "Traits",
            }) do

                local container =
                    rawget(source, key)

                if type(container) == "table" then

                    for k, v in pairs(container) do

                        if v == true then

                            local cleaned =
                                CleanMutation(k)

                            if cleaned then
                                return cleaned
                            end

                        elseif type(v) == "string"
                        or type(v) == "number" then

                            local cleaned =
                                CleanMutation(v)

                            if cleaned then
                                return cleaned
                            end
                        end
                    end
                end
            end
        end
    end

    local displayName =
        CleanText(
            tostring(toolName or "")
                :gsub("%b[]", "")
                :gsub("%s+", " ")
        )

    basePetName =
        CleanText(basePetName)

    if displayName == ""
    or basePetName == ""
    or displayName == basePetName then
        return "---"
    end

    local suffixStart =
        displayName:find(basePetName, 1, true)

    if not suffixStart then
        return "---"
    end

    local mutation =
        CleanText(
            displayName:sub(1, suffixStart - 1)
        )

    if mutation == "" then
        return "---"
    end

    return mutation
end

function TransferParseDisplayWeight(toolName)

    return tonumber(
        tostring(toolName or "")
            :match("%[([%d%.]+)%s*KG%]")
    )
end

function TransferParseDisplayAge(toolName)

    return tonumber(
        tostring(toolName or "")
            :match("%[Age%s*(%d+)%]")
    )
end

function TransferResolveToolUUID(tool)

    if not tool
    or not tool:IsA("Tool") then
        return ""
    end

    local candidates = {
        tool:GetAttribute("PET_UUID"),
        tool:GetAttribute("UUID"),
        tool:GetAttribute("ItemUUID"),
        tool:GetAttribute("ItemId"),
        tool:GetAttribute("PetUUID"),
    }

    for _, value in ipairs(candidates) do

        local uuid =
            TransferNormalizeUUID(value)

        if uuid ~= "" then
            return uuid
        end
    end

    return ""
end

function TransferParseInventoryTool(tool)

    if not tool
    or not tool:IsA("Tool") then
        return nil
    end

    local displayWeight =
        TransferParseDisplayWeight(tool.Name)

    if not displayWeight then
        return nil
    end

    local uuid =
        TransferResolveToolUUID(tool)

    if uuid == "" then
        return nil
    end

    local petData, itemData =
        TransferGetInventoryPetDataByUUID(uuid)

    local nameFromTool =
        CleanText(
            tostring(tool.Name or "")
                :gsub("%b[]", "")
                :gsub("%s+", " ")
        )

    local petName =
        TransferResolvePetName(
            petData,
            itemData,
            tool,
            nameFromTool
        )

    if petName == "" then
        return nil
    end

    local displayAge =
        TransferParseDisplayAge(tool.Name)

    local baseWeight, baseWeightSource =
        TransferResolveRawBaseWeight(
            petData,
            itemData,
            tool
        )

    local level, levelSource =
        TransferResolveRawLevel(
            petData,
            itemData,
            tool,
            displayAge
        )

    return {
        Tool = tool,
        ToolName = tool.Name,

        UUID = uuid,

        PetName = petName,

        Mutation =
            TransferResolveMutation(
                tool.Name,
                petName,
                petData,
                itemData
            ),

        Level = level,
        LevelSource = levelSource,

        BaseWeight = baseWeight,
        BaseWeightSource = baseWeightSource,

        DisplayWeight = displayWeight,

        IsFavorite =
            TransferResolveFavorite(
                tool,
                petData,
                itemData
            ),

        ValidForSend =
            baseWeight ~= nil,
    }
end

function TransferBuildInventoryPets()

    local pets = {}
    local seen = {}

    local containers = {
        LocalPlayer:FindFirstChild("Backpack"),
        LocalPlayer.Character,
    }

    for _, container in ipairs(containers) do

        if container then

            for _, child in ipairs(container:GetChildren()) do

                local pet =
                    TransferParseInventoryTool(child)

                if pet
                and pet.UUID ~= ""
                and not seen[pet.UUID] then

                    seen[pet.UUID] =
                        true

                    table.insert(
                        pets,
                        pet
                    )
                end
            end
        end
    end

    table.sort(pets, function(a, b)

        local aName =
            tostring(a.PetName or ""):lower()

        local bName =
            tostring(b.PetName or ""):lower()

        if aName ~= bName then
            return aName < bName
        end

        local aBase =
            tonumber(a.BaseWeight)
            or -1

        local bBase =
            tonumber(b.BaseWeight)
            or -1

        if aBase ~= bBase then
            return aBase > bBase
        end

        return tostring(a.UUID) < tostring(b.UUID)
    end)

    return pets
end

function TransferAddUniquePetName(target, seen, value)

    local name =
        CleanText(value)

    if name == "" then
        return false
    end

    if name == "None"
    or name == "---"
    or name == "Normal"
    or name == "Unknown" then
        return false
    end

    -- Do not pollute normal pet dropdown with egg pseudo-items.
    if name:sub(1, 4) == "Egg/" then
        return false
    end

    if seen[name] == true then
        return false
    end

    seen[name] =
        true

    table.insert(
        target,
        name
    )

    return true
end

function TransferGetPetRegistry()

    if type(TransferPetRegistry) == "table" then
        return TransferPetRegistry
    end

    local ok, result =
        pcall(function()

            local dataFolder =
                ReplicatedStorage:FindFirstChild("Data")
                or ReplicatedStorage:WaitForChild("Data", 5)

            if not dataFolder then
                return nil
            end

            local petRegistryModule =
                dataFolder:FindFirstChild("PetRegistry")
                or dataFolder:WaitForChild("PetRegistry", 5)

            if not petRegistryModule then
                return nil
            end

            return require(petRegistryModule)
        end)

    if ok == true
    and type(result) == "table" then

        TransferPetRegistry =
            result

        return TransferPetRegistry
    end

    return nil
end

function TransferBuildAllGamePetChoices()

    if type(TransferState.AllPetChoices) == "table"
    and #TransferState.AllPetChoices > 0 then
        return TransferState.AllPetChoices
    end

    local choices = {}
    local seen = {}

    local registry =
        TransferGetPetRegistry()

    if type(registry) == "table"
    and type(registry.PetList) == "table" then

        for petName, petData in pairs(registry.PetList) do

            if type(petName) == "string"
            and type(petData) == "table" then

                TransferAddUniquePetName(
                    choices,
                    seen,
                    petName
                )
            end
        end
    end

    -- Fallback only. This should only run if PetRegistry.PetList fails.
    if #choices <= 0 then

        for _, pet in ipairs(TransferBuildInventoryPets()) do

            TransferAddUniquePetName(
                choices,
                seen,
                pet.PetName
            )
        end
    end

    table.sort(choices)

    TransferState.AllPetChoices =
        choices

    print(
        "[TRANSFER PET LIST]",
        "PetRegistry pets:",
        tostring(#choices)
    )

    return choices
end

function TransferBuildPetChoices()

    return TransferBuildAllGamePetChoices()
end

function TransferAddUniqueMutationName(target, seen, value)

    local name =
        CleanText(value)

    if name == "" then
        return false
    end

    if name == "---"
    or name == "Normal"
    or name == "Unknown" then
        return false
    end

    if name == "EnumToPetMutation"
    or name == "PetMutationToEnum"
    or name == "PetMutationRegistry"
    or name == "MachineMutationTypes"
    or name == "RollRandomMutation" then
        return false
    end

    if seen[name] == true then
        return false
    end

    seen[name] =
        true

    table.insert(
        target,
        name
    )

    return true
end

function TransferBuildMutationChoices()

    if type(TransferState.AllMutationChoices) == "table"
    and #TransferState.AllMutationChoices > 0 then
        return TransferState.AllMutationChoices
    end

    local choices = {}
    local seen = {}

    local registry =
        TransferGetPetRegistry()

    local mutationRoot =
        type(registry) == "table"
        and rawget(registry, "PetMutationRegistry")
        or nil

    local petMutationRegistry =
        type(mutationRoot) == "table"
        and rawget(mutationRoot, "PetMutationRegistry")
        or nil

    if type(petMutationRegistry) == "table" then

        for mutationName, mutationData in pairs(petMutationRegistry) do

            TransferAddUniqueMutationName(
                choices,
                seen,
                mutationName
            )

            if type(mutationData) == "table" then

                TransferAddUniqueMutationName(
                    choices,
                    seen,
                    rawget(mutationData, "Name")
                )

                TransferAddUniqueMutationName(
                    choices,
                    seen,
                    rawget(mutationData, "Mutation")
                )

                TransferAddUniqueMutationName(
                    choices,
                    seen,
                    rawget(mutationData, "DisplayName")
                )

            elseif type(mutationData) == "string" then

                TransferAddUniqueMutationName(
                    choices,
                    seen,
                    mutationData
                )
            end
        end
    end

    local machineMutationTypes =
        type(mutationRoot) == "table"
        and rawget(mutationRoot, "MachineMutationTypes")
        or nil

    if type(machineMutationTypes) == "table" then

        for mutationName, mutationData in pairs(machineMutationTypes) do

            TransferAddUniqueMutationName(
                choices,
                seen,
                mutationName
            )

            if type(mutationData) == "table" then

                TransferAddUniqueMutationName(
                    choices,
                    seen,
                    rawget(mutationData, "Name")
                )

                TransferAddUniqueMutationName(
                    choices,
                    seen,
                    rawget(mutationData, "Mutation")
                )

                TransferAddUniqueMutationName(
                    choices,
                    seen,
                    rawget(mutationData, "DisplayName")
                )

            elseif type(mutationData) == "string" then

                TransferAddUniqueMutationName(
                    choices,
                    seen,
                    mutationData
                )
            end
        end
    end

    local enumToPetMutation =
        type(mutationRoot) == "table"
        and rawget(mutationRoot, "EnumToPetMutation")
        or nil

    if type(enumToPetMutation) == "table" then

        for _, mutationName in pairs(enumToPetMutation) do

            TransferAddUniqueMutationName(
                choices,
                seen,
                mutationName
            )
        end
    end

    local petMutationToEnum =
        type(mutationRoot) == "table"
        and rawget(mutationRoot, "PetMutationToEnum")
        or nil

    if type(petMutationToEnum) == "table" then

        for mutationName, _ in pairs(petMutationToEnum) do

            TransferAddUniqueMutationName(
                choices,
                seen,
                mutationName
            )
        end
    end

    -- Fallback only if the registry shape changes.
    if #choices <= 0 then

        for _, pet in ipairs(TransferBuildInventoryPets()) do

            TransferAddUniqueMutationName(
                choices,
                seen,
                pet.Mutation
            )
        end
    end

    table.sort(choices)

    TransferState.AllMutationChoices =
        choices

    print(
        "[TRANSFER MUTATION LIST]",
        "PetRegistry mutations:",
        tostring(#choices)
    )

    return choices
end

function TransferBuildTargetChoices()

    local choices = {}

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then
            table.insert(
                choices,
                player.Name
            )
        end
    end

    table.sort(choices)

    return choices
end

function TransferResolveTargetPlayer()

    local targetName =
        CleanText(TransferState.TargetPlayerName)

    if targetName == "" then
        return nil
    end

    for _, player in ipairs(Players:GetPlayers()) do

        if player.Name == targetName
        or player.DisplayName == targetName then
            return player
        end
    end

    return nil
end

function TransferPetPassesFilters(pet)

    if type(pet) ~= "table" then
        return false
    end

    if pet.ValidForSend ~= true then
        return false
    end

    if TransferMapIsEmpty(TransferState.SelectedPets) then
        return false
    end

    if TransferState.SelectedPets[pet.PetName] ~= true then
        return false
    end

    if not TransferMapIsEmpty(TransferState.SelectedMutations) then

        if TransferState.SelectedMutations[pet.Mutation] ~= true then
            return false
        end
    end

    local level =
        tonumber(pet.Level)
        or 1

    if level < TransferState.MinLevel then
        return false
    end

    if level > TransferState.MaxLevel then
        return false
    end

    local baseWeight =
        tonumber(pet.BaseWeight)

    if not baseWeight then
        return false
    end

    if baseWeight < TransferState.MinBaseWeight then
        return false
    end

    if baseWeight > TransferState.MaxBaseWeight then
        return false
    end

    return true
end

function TransferBuildMatches()

    local matches = {}

    for _, pet in ipairs(TransferBuildInventoryPets()) do

        if TransferPetPassesFilters(pet) then

            table.insert(
                matches,
                pet
            )

            if #matches >= TransferGetMaxPetsPerTrade() then
                break
            end
        end
    end

    TransferState.MatchedPets =
        matches

    return matches
end

TransferSetStatus = function(status, result, forceSourceRefresh)

    TransferState.Status =
        tostring(status or "Idle")

    TransferState.LastResult =
        tostring(result or "None")

    if TransferState.StatusLabel then
        SetControlText(
            TransferState.StatusLabel,
            "Mode: " .. TransferState.Status
        )
    end

    if TransferState.TargetLabel then
        SetControlText(
            TransferState.TargetLabel,
            "Player: "
                .. (
                    TransferState.TargetPlayerName ~= ""
                    and TransferState.TargetPlayerName
                    or "None"
                )
        )
    end

    if TransferState.MatchLabel then
        SetControlText(
            TransferState.MatchLabel,
            "Matched: "
                .. tostring(#(TransferState.MatchedPets or {}))
                .. " | Added: "
                .. tostring(TransferState.AddedThisBatch or 0)
        )
    end

    if TransferState.ResultLabel then
        SetControlText(
            TransferState.ResultLabel,
            "Batch: "
                .. tostring(TransferState.Batch or 0)
                .. " | Sent: "
                .. tostring(TransferState.Sent)
                .. " | Result: "
                .. tostring(TransferState.LastResult)
        )
    end

    if TransferState.SourceLabel then

        local now =
            os.clock()

        local shouldRefreshSource =
            forceSourceRefresh == true
            or TransferState.LastSourceRefresh <= 0
            or (
                TransferState.IsAddingPets ~= true
                and now - TransferState.LastSourceRefresh >= 2
            )

        if shouldRefreshSource then

            TransferState.LastSourceRefresh =
                now

            local valid = 0
            local missingBase = 0

            for _, pet in ipairs(TransferBuildInventoryPets()) do

                if pet.ValidForSend then
                    valid =
                        valid + 1
                else
                    missingBase =
                        missingBase + 1
                end
            end

            TransferState.CachedSourceText =
                "Inventory Parsed: "
                    .. tostring(valid + missingBase)
                    .. " | Valid BaseWeight: "
                    .. tostring(valid)
                    .. " | Missing BaseWeight: "
                    .. tostring(missingBase)
        end

        SetControlText(
            TransferState.SourceLabel,
            TransferState.CachedSourceText
        )
    end
end

function TransferApplyModeUI()

    local isReceiver =
        TransferState.Mode == "Receiver"

    -- Always visible. Both sender and receiver need a start/stop switch.
    SetControlVisible(
        TransferState.TransferEnabledToggle,
        true
    )

    -- Sender-only controls.
    SetControlVisible(
        TransferState.AutoUnfavoriteToggle,
        not isReceiver
    )

    SetControlVisible(
        TransferState.MaxPetsInput,
        not isReceiver
    )

    SetControlVisible(
        TransferState.AddPetDelayInput,
        not isReceiver
    )

    SetControlVisible(
        TransferState.AddBurstInput,
        not isReceiver
    )

    SetControlVisible(
        TransferState.NextTicketDelayInput,
        not isReceiver
    )

    -- Receiver controls.
    SetControlVisible(
        TransferState.AutoAcceptTicketToggle,
        isReceiver
    )

    SetControlVisible(
        TransferState.AutoConfirmToggle,
        isReceiver
    )

    -- Keep Going is useful for both:
    -- Sender = keep sending batches.
    -- Receiver = keep accepting next tickets.
    SetControlVisible(
        TransferState.KeepGoingToggle,
        true
    )
end

function TransferFindTradeTicketTool()

    local function scan(container)

        if not container then
            return nil
        end

        for _, child in ipairs(container:GetChildren()) do

            if child:IsA("Tool") then

                local name =
                    tostring(child.Name or ""):lower()

                local isTradeTicket =
                    name:find("trading ticket", 1, true)
                    or (
                        name:find("trade", 1, true)
                        and name:find("ticket", 1, true)
                    )
                    or (
                        name:find("trading", 1, true)
                        and name:find("ticket", 1, true)
                    )

                if isTradeTicket then
                    return child
                end
            end
        end

        return nil
    end

    local character =
        LocalPlayer.Character

    local equipped =
        scan(character)

    if equipped then
        return equipped, true
    end

    local backpack =
        LocalPlayer:FindFirstChild("Backpack")

    return scan(backpack), false
end

function TransferEquipTradeTicket()

    local tool, alreadyEquipped =
        TransferFindTradeTicketTool()

    if not tool then

        TransferSetStatus(
            "No Ticket",
            "No Trading Ticket found in Backpack."
        )

        return false
    end

    if alreadyEquipped == true then
        return true
    end

    local character =
        LocalPlayer.Character

    local humanoid =
        character
        and character:FindFirstChildOfClass("Humanoid")

    if not humanoid then

        TransferSetStatus(
            "Equip Failed",
            "Humanoid missing. Cannot equip Trading Ticket."
        )

        return false
    end

    TransferSetStatus(
        "Equipping Ticket",
        "Equipping "
            .. tostring(tool.Name)
    )

    local ok, err =
        pcall(function()
            humanoid:EquipTool(tool)
        end)

    if not ok then

        TransferSetStatus(
            "Equip Failed",
            tostring(err)
        )

        return false
    end

    local equipStarted =
        os.clock()

    while os.clock() - equipStarted < 0.6 do

        if tool.Parent == character then
            return true
        end

        task.wait()
    end

    TransferSetStatus(
        "Equip Failed",
        "Trading Ticket did not equip."
    )

    return false
end

TransferFavoriteRemote =
    nil

function TransferGetFavoriteRemote()

    if TransferFavoriteRemote then
        return TransferFavoriteRemote
    end

    local gameEvents =
        ReplicatedStorage:FindFirstChild("GameEvents")

    if not gameEvents then
        return nil
    end

    local remote =
        gameEvents:FindFirstChild("Favorite_Item")

    if remote
    and remote:IsA("RemoteEvent") then

        TransferFavoriteRemote =
            remote

        return TransferFavoriteRemote
    end

    return nil
end

function TransferUnfavoritePetIfNeeded(pet)

    if TransferState.AutoUnfavorite ~= true then
        return true, "Auto Unfavorite OFF"
    end

    if type(pet) ~= "table" then
        return false, "Invalid pet"
    end

    if not pet.Tool
    or not pet.Tool:IsA("Tool") then
        return false, "Pet tool missing"
    end

    if pet.Tool:GetAttribute("d") ~= true
    and pet.IsFavorite ~= true then
        return true, "Not favorite"
    end

    local remote =
        TransferGetFavoriteRemote()

    if not remote then
        return false, "Favorite_Item remote missing"
    end

    TransferSetStatus(
        "Unfavoriting",
        "Unfavoriting "
            .. tostring(pet.PetName)
            .. " before sending."
    )

    local ok, err =
        pcall(function()
            remote:FireServer(pet.Tool)
        end)

    if not ok then
        return false, tostring(err)
    end

    local timeout =
        os.clock() + 3

    while os.clock() < timeout do

        if not IsHolyLiteCurrentRun() then
            return false, "Runtime stopped"
        end

        local favoriteState =
            pet.Tool:GetAttribute("d")

        if favoriteState == false then

            pet.IsFavorite =
                false

            print(
                "[TRANSFER] Unfavorite confirmed:",
                tostring(pet.ToolName or pet.PetName)
            )

            return true, "Unfavorited"
        end

        task.wait(0.1)
    end

    return false, "Unfavorite timeout"
end

function TransferUnfavoriteMatchingPetsBeforeTrade(matches)

    if TransferState.AutoUnfavorite ~= true then
        return true, "Auto Unfavorite OFF"
    end

    if type(matches) ~= "table"
    or #matches <= 0 then
        return true, "No matches"
    end

    local totalFavorites = 0
    local unfavorited = 0
    local failed = 0
    local lastError = ""

    for index, pet in ipairs(matches) do

        if not IsHolyLiteCurrentRun() then
            return false, "Runtime stopped"
        end

        if type(pet) == "table"
        and pet.IsFavorite == true then

            totalFavorites =
                totalFavorites + 1

            TransferSetStatus(
                "Unfavoriting",
                "Preparing "
                    .. tostring(index)
                    .. "/"
                    .. tostring(#matches)
                    .. ": "
                    .. tostring(pet.PetName)
            )

            local ok, msg =
                TransferUnfavoritePetIfNeeded(pet)

            if ok then
                unfavorited =
                    unfavorited + 1
            else

                failed =
                    failed + 1

                lastError =
                    tostring(msg)
            end

            task.wait(0.03)
        end
    end

    if totalFavorites <= 0 then
        return true, "No favorited matches"
    end

    task.wait(0.75)

    TransferSetStatus(
        "Unfavorite Done",
        tostring(unfavorited)
            .. "/"
            .. tostring(totalFavorites)
            .. " unfavorited"
            .. (
                failed > 0
                and (", " .. tostring(failed) .. " failed")
                or ""
            )
    )

    if failed > 0 then
        return false, lastError
    end

    return true, "Unfavorited matching pets"
end

function TransferRefreshDropdowns()

    local petChoices =
        TransferBuildPetChoices()

    local mutationChoices =
        TransferBuildMutationChoices()

    local targetChoices =
        TransferBuildTargetChoices()

    if TransferState.PetDropdown
    and type(TransferState.PetDropdown.SetValues) == "function" then

        TransferState.PetDropdown:SetValues(
            petChoices
        )
    end

    if TransferState.MutationDropdown
    and type(TransferState.MutationDropdown.SetValues) == "function" then

        TransferState.MutationDropdown:SetValues(
            mutationChoices
        )
    end

    if TransferState.TargetDropdown
    and type(TransferState.TargetDropdown.SetValues) == "function" then

        TransferState.TargetDropdown:SetValues(
            targetChoices
        )
    end

    TransferBuildMatches()

    print(
        "[TRANSFER LISTS]",
        "pets:",
        tostring(#petChoices),
        "| mutations:",
        tostring(#mutationChoices),
        "| targets:",
        tostring(#targetChoices)
    )

    TransferSetStatus(
        TransferState.Status,
        TransferState.LastResult
    )

    return petChoices, mutationChoices, targetChoices
end

function TransferSafeFullName(instance)

    if not instance then
        return "nil"
    end

    local ok, result =
        pcall(function()
            return instance:GetFullName()
        end)

    if ok == true then
        return tostring(result)
    end

    return tostring(instance)
end

function TransferCompactValue(value, depth)

    depth =
        tonumber(depth)
        or 0

    if depth >= 3 then
        return tostring(value)
    end

    local valueType =
        typeof(value)

    if valueType == "Instance" then
        return TransferSafeFullName(value)
    end

    if type(value) ~= "table" then
        return tostring(value)
    end

    local parts = {}

    local count =
        0

    for key, child in pairs(value) do

        count =
            count + 1

        if count > 40 then
            table.insert(parts, "...more")
            break
        end

        table.insert(
            parts,
            tostring(key)
                .. "="
                .. TransferCompactValue(child, depth + 1)
        )
    end

    return "{"
        .. table.concat(parts, ", ")
        .. "}"
end

function TransferBuildTradeDebugDump()

    local lines = {}

    table.insert(lines, "========== HOLY FRESH TRADE DEBUG DUMP ==========")
    table.insert(lines, "Time: " .. tostring(os.date("%Y-%m-%d %H:%M:%S")))
    table.insert(lines, "Player: " .. tostring(LocalPlayer.Name) .. " / " .. tostring(LocalPlayer.UserId))
    table.insert(lines, "PlaceId: " .. tostring(game.PlaceId))
    table.insert(lines, "JobId: " .. tostring(game.JobId))
    table.insert(lines, "")

    table.insert(lines, "---- TRANSFER STATE ----")
    table.insert(lines, "Mode: " .. tostring(TransferState.Mode))
    table.insert(lines, "TargetPlayerName: " .. tostring(TransferState.TargetPlayerName))
    table.insert(lines, "TransferEnabled: " .. tostring(TransferState.TransferEnabled))
    table.insert(lines, "TradeOpen: " .. tostring(TransferState.TradeOpen))
    table.insert(lines, "TradeId: " .. tostring(TransferState.TradeId))
    table.insert(lines, "LocalTradeSide: " .. tostring(TransferState.LocalTradeSide))
    table.insert(lines, "OtherTradeSide: " .. tostring(TransferState.OtherTradeSide))
    table.insert(lines, "LocalState: " .. tostring(TransferGetLocalTradeState()))
    table.insert(lines, "OtherState: " .. tostring(TransferGetOtherTradeState()))
    table.insert(lines, "OwnItemCount: " .. tostring(TransferState.TradeOwnItemCount))
    table.insert(lines, "OtherItemCount: " .. tostring(TransferState.TradeOtherItemCount))
    table.insert(lines, "TradeCompleted: " .. tostring(TransferState.TradeCompleted))
    table.insert(lines, "TradeResult: " .. tostring(TransferState.TradeResult))
    table.insert(lines, "TradeDeclined: " .. tostring(TransferState.TradeDeclined))
    table.insert(lines, "TradeDeclineReason: " .. tostring(TransferState.TradeDeclineReason))
    table.insert(lines, "LastTradeUpdateAgo: " .. string.format("%.3f", os.clock() - (tonumber(TransferState.LastTradeUpdate) or os.clock())))
    table.insert(lines, "")

    table.insert(lines, "---- TIMING ----")
    table.insert(lines, TransferCompactValue(TransferState.Timing))
    table.insert(lines, "")

    table.insert(lines, "---- TRADE DATA MODULE ----")

    local tradeData =
        TransferGetTradeData()

    if type(tradeData) == "table" then

        for key, value in pairs(tradeData) do

            table.insert(
                lines,
                tostring(key)
                    .. " = "
                    .. TransferCompactValue(value)
            )
        end

    else

        table.insert(lines, "TradeData missing/unreadable.")
    end

    table.insert(lines, "")

    table.insert(lines, "---- TRADE EVENTS ----")

    local gameEvents =
        ReplicatedStorage:FindFirstChild("GameEvents")

    local tradeEvents =
        gameEvents
        and gameEvents:FindFirstChild("TradeEvents")

    if tradeEvents then

        for _, child in ipairs(tradeEvents:GetChildren()) do

            table.insert(
                lines,
                child.Name
                    .. " | "
                    .. child.ClassName
                    .. " | "
                    .. TransferSafeFullName(child)
            )
        end

    else

        table.insert(lines, "TradeEvents missing.")
    end

    table.insert(lines, "")

    table.insert(lines, "---- BUTTON / VALUE CHECKS ----")
    table.insert(lines, "TradeButtonText: " .. tostring(TransferGetTradeButtonText()))
    table.insert(lines, "ParsedCooldown: " .. tostring(TransferParseCooldownText(TransferGetTradeButtonText())))

    local hasValue, value =
        TransferGuiHasPositiveTradeValue()

    table.insert(lines, "GuiHasPositiveValue: " .. tostring(hasValue) .. " / " .. tostring(value))
    table.insert(lines, "WaitingForTarget: " .. tostring(TransferGuiWaitingForSpecificPlayer()))
    table.insert(lines, "LocalAcceptLocked: " .. tostring(TransferLocalAcceptLocked()))
    table.insert(lines, "LikelyLocked: " .. tostring(TransferAcceptLikelyLockedFromButtonPhase()))
    table.insert(lines, "ReceiverAcceptedAfterLocal: " .. tostring(TransferReceiverAcceptedAfterLocal()))
    table.insert(lines, "")

    table.insert(lines, "---- TRADING UI TEXT OBJECTS ----")

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    local tradingUI =
        playerGui
        and playerGui:FindFirstChild("TradingUI")

    if tradingUI then

        for _, obj in ipairs(tradingUI:GetDescendants()) do

            if obj:IsA("TextLabel")
            or obj:IsA("TextButton")
            or obj:IsA("TextBox") then

                local visible =
                    TransferIsGuiObjectVisible(obj)

                local text =
                    CleanText(obj.Text)

                if text ~= "" then

                    table.insert(
                        lines,
                        "[" .. tostring(visible) .. "] "
                            .. TransferSafeFullName(obj)
                            .. " | Name="
                            .. tostring(obj.Name)
                            .. " | Class="
                            .. tostring(obj.ClassName)
                            .. " | Text="
                            .. text
                    )
                end
            end
        end

    else

        table.insert(lines, "TradingUI missing.")
    end

    table.insert(lines, "")

    table.insert(lines, "---- TRADING UI GUI OBJECTS ----")

    if tradingUI then

        for _, obj in ipairs(tradingUI:GetDescendants()) do

            if obj:IsA("GuiObject") then

                table.insert(
                    lines,
                    TransferSafeFullName(obj)
                        .. " | Class="
                        .. tostring(obj.ClassName)
                        .. " | Visible="
                        .. tostring(obj.Visible)
                        .. " | Name="
                        .. tostring(obj.Name)
                )
            end
        end
    end

    table.insert(lines, "=================================================")

    return table.concat(lines, "\n")
end

function TransferGetTradeRemote(name)

    local gameEvents =
        ReplicatedStorage:FindFirstChild("GameEvents")

    local tradeEvents =
        gameEvents
        and gameEvents:FindFirstChild("TradeEvents")

    if not tradeEvents then
        return nil
    end

    return tradeEvents:FindFirstChild(name)
end

function TransferFireTradeRemote(name, ...)

    name =
        tostring(name or "")

    local remote =
        TransferGetTradeRemote(name)

    if not remote
    or not remote:IsA("RemoteEvent") then
        return false, "Missing RemoteEvent: " .. tostring(name)
    end

    local args =
        { ... }

    local ok, err =
        pcall(function()
            remote:FireServer(
                TransferUnpack(args)
            )
        end)

    if not ok then
        return false, tostring(err)
    end

    return true, "Fired " .. tostring(name)
end

TransferAcceptPetGift = function(giftId, petName, senderName)

    giftId =
        CleanText(giftId)

    petName =
        CleanText(petName)

    senderName =
        CleanText(senderName)

    if giftId == "" then
        return false, "Missing gift id"
    end

    if TransferState.AutoAcceptGift ~= true then
        return false, "Auto Accept Gift OFF"
    end

    if TransferState.IncomingGiftHandled[giftId] == true then
        return true, "Gift already handled"
    end

    local trusted =
        CleanText(TransferState.TargetPlayerName)

    if trusted ~= ""
    and senderName ~= trusted then

        print(
            "[TRANSFER GIFT]",
            "Ignored gift from untrusted sender:",
            tostring(senderName),
            "| wanted:",
            tostring(trusted),
            "| pet:",
            tostring(petName)
        )

        return false, "Untrusted sender"
    end

    local gameEvents =
        ReplicatedStorage:FindFirstChild("GameEvents")

    local remote =
        gameEvents
        and gameEvents:FindFirstChild("AcceptPetGift")

    if not remote
    or not remote:IsA("RemoteEvent") then
        return false, "AcceptPetGift remote missing"
    end

    local responseValue =
        TransferState.AutoAcceptGiftResponseValue == true

    local ok, err =
        pcall(function()

            remote:FireServer(
                responseValue,
                giftId
            )
        end)

    if ok == true then

        TransferState.IncomingGiftHandled[giftId] =
            true

        TransferState.LastGiftId =
            giftId

        TransferState.LastGiftPetName =
            petName

        TransferState.LastGiftSenderName =
            senderName

        TransferSetStatus(
            "Gift Accepted",
            tostring(senderName)
                .. " -> "
                .. tostring(petName)
        )

        print(
            "[TRANSFER GIFT]",
            "Auto accepted gift:",
            "| ok:",
            tostring(ok),
            "| value:",
            tostring(responseValue),
            "| id:",
            tostring(giftId),
            "| pet:",
            tostring(petName),
            "| sender:",
            tostring(senderName)
        )

        return true, "Accepted gift"
    end

    print(
        "[TRANSFER GIFT]",
        "AcceptPetGift failed:",
        tostring(err),
        "| id:",
        tostring(giftId),
        "| pet:",
        tostring(petName),
        "| sender:",
        tostring(senderName)
    )

    return false, tostring(err)
end

function TransferReadOfferCountFromOffers(offers, side)

    if type(offers) ~= "table" then
        return nil
    end

    local function CountOfferItems(offer)

        if type(offer) ~= "table" then
            return nil
        end

        local items =
            rawget(offer, "items")
            or rawget(offer, "Items")

        local count =
            0

        if type(items) == "table" then

            for _ in pairs(items) do
                count =
                    count + 1
            end
        end

        return count
    end

    if side ~= nil then

        local offer =
            offers[side]
            or offers[tostring(side)]

        local count =
            CountOfferItems(offer)

        if count ~= nil then
            return count
        end
    end

    local bestCount =
        nil

    for _, offerKey in ipairs({
        0,
        "0",
        1,
        "1",
        2,
        "2",
    }) do

        local count =
            CountOfferItems(
                offers[offerKey]
            )

        if count ~= nil then

            if bestCount == nil
            or count > bestCount then
                bestCount =
                    count
            end
        end
    end

    return bestCount
end

function TransferResolveTradeSidesFromPlayers(playersTable)

    if type(playersTable) ~= "table" then
        return
    end

    TransferState.TradePlayers =
        playersTable

    TransferState.LocalTradeSide =
        nil

    TransferState.OtherTradeSide =
        nil

    for side, player in pairs(playersTable) do

        if player == LocalPlayer then

            TransferState.LocalTradeSide =
                side

        elseif typeof(player) == "Instance"
        and player:IsA("Player") then

            TransferState.OtherTradeSide =
                side
        end
    end
end

function TransferGetTradeState(side)

    if side == nil then
        return "None"
    end

    return tostring(
        TransferState.TradeStates[side]
            or TransferState.TradeStates[tostring(side)]
            or "None"
    )
end

function TransferGetLocalTradeState()

    return TransferGetTradeState(
        TransferState.LocalTradeSide
    )
end

function TransferGetOtherTradeState()

    return TransferGetTradeState(
        TransferState.OtherTradeSide
    )
end

function TransferResetTradeRuntime()

    TransferState.TradeOpen =
        false

    TransferState.TradeId =
        ""

    TransferState.TradePlayers =
        {}

    TransferState.TradeStates =
        {}

    TransferState.TradeOfferCounts =
        {}

    TransferState.LocalTradeSide =
        nil

    TransferState.OtherTradeSide =
        nil

    TransferState.TradeOwnItemCount =
        0

    TransferState.TradeOtherItemCount =
        0

    TransferState.TradeCompleted =
        false

    TransferState.TradeResult =
        ""

    TransferState.TradeDeclined =
        false

    TransferState.TradeDeclineReason =
        ""

    TransferState.RequestBlocked =
        false

    TransferState.RequestBlockedReason =
        ""

    TransferState.RequestExpired =
        false

    TransferState.RequestExpiredReason =
        ""

    TransferState.LastRequestAcceptValue =
        "unknown"

    TransferState.LastTradeUpdate =
        0
end

function TransferUpdateTradeStatusText(status, result)

    local localState =
        TransferGetLocalTradeState()

    local otherState =
        TransferGetOtherTradeState()

    TransferSetStatus(
        status,
        tostring(result or "None")
            .. " | "
            .. tostring(localState)
            .. "/"
            .. tostring(otherState)
    )
end

function TransferMarkTradeDeclined(reason)

    reason =
        tostring(reason or "Trade declined.")

    if TransferState.TradeCompleted == true
    or TransferState.TradeResult == "Completed" then

        print(
            "[TRANSFER] Ignored late decline after completed trade:",
            reason
        )

        return
    end

    TransferState.TradeDeclined =
        true

    TransferState.TradeDeclineReason =
        reason

    TransferState.TradeOpen =
        false

    TransferState.TradeId =
        ""

    TransferState.TradePlayers =
        {}

    TransferState.TradeStates =
        {}

    TransferState.TradeOfferCounts =
        {}

    TransferState.LocalTradeSide =
        nil

    TransferState.OtherTradeSide =
        nil

    TransferState.TradeOwnItemCount =
        0

    TransferState.TradeOtherItemCount =
        0

    TransferState.LastTradeUpdate =
        os.clock()

    TransferSetStatus(
        "Trade Declined",
        reason
    )

    print(
        "[TRANSFER] Trade declined:",
        reason
    )
end

function TransferMarkRequestBlocked(reason)

    reason =
        tostring(reason or "Request blocked.")

    TransferState.RequestBlocked =
        true

    TransferState.RequestBlockedReason =
        reason

    TransferState.LastTradeUpdate =
        os.clock()

    TransferSetStatus(
        "Request Blocked",
        reason
    )

    print(
        "[TRANSFER] Request blocked:",
        reason
    )
end

function TransferMarkRequestExpired(reason)

    reason =
        tostring(reason or "Request expired.")

    local expiredRequestId =
        CleanText(TransferState.IncomingRequestId)

    if expiredRequestId == "" then

        print(
            "[TRANSFER] Ignored request expired with no active request:",
            reason
        )

        return
    end

    TransferState.RequestExpired =
        true

    TransferState.RequestExpiredReason =
        reason

    TransferState.IncomingRequestHandled[expiredRequestId] =
        nil

    TransferState.IncomingRequestId =
        ""

    TransferState.IncomingRequestPlayerName =
        ""

    TransferState.IncomingRequestAt =
        0

    TransferState.LastTradeUpdate =
        os.clock()

    TransferSetStatus(
        "Request Expired",
        reason
    )

    print(
        "[TRANSFER] Request expired:",
        reason,
        "| requestId:",
        tostring(expiredRequestId),
        "| lastAcceptValue:",
        tostring(TransferState.LastRequestAcceptValue)
    )
end

function TransferMarkTradeCompleted(reason)

    TransferState.TradeCompleted =
        true

    TransferState.TradeResult =
        "Completed"

    TransferState.TradeOpen =
        false

    TransferState.LastTradeUpdate =
        os.clock()

    TransferSetStatus(
        "Trade Completed",
        tostring(reason or "Completed")
    )

    print(
        "[TRANSFER] Trade completed:",
        tostring(reason or "Completed")
    )
end

function TransferUpdateTradeTrackerFromPayload(payload)

    if type(payload) ~= "table" then
        return
    end

    local directId =
        rawget(payload, "id")

    if directId ~= nil then
        TransferState.TradeId =
            tostring(directId)
    end

    local playersTable =
        rawget(payload, "players")
        or rawget(payload, "Players")

    if type(playersTable) == "table" then
        TransferResolveTradeSidesFromPlayers(playersTable)
    end

    local statesTable =
        rawget(payload, "states")
        or rawget(payload, "States")

    if type(statesTable) == "table" then

        for side, state in pairs(statesTable) do
            TransferState.TradeStates[side] =
                tostring(state)
        end
    end

    local directOffers =
        rawget(payload, "offers")
        or rawget(payload, "Offers")

    if type(directOffers) == "table" then

        TransferState.TradeOpen =
            true

        for side, offer in pairs(directOffers) do

            if type(offer) == "table" then

                local count =
                    TransferReadOfferCountFromOffers(
                        directOffers,
                        side
                    )

                if count ~= nil then
                    TransferState.TradeOfferCounts[side] =
                        count
                end
            end
        end

        local ownCount =
            TransferReadOfferCountFromOffers(
                directOffers,
                TransferState.LocalTradeSide
            )

        if ownCount ~= nil then
            TransferState.TradeOwnItemCount =
                ownCount
        end

        local otherCount =
            TransferReadOfferCountFromOffers(
                directOffers,
                TransferState.OtherTradeSide
            )

        if otherCount ~= nil then
            TransferState.TradeOtherItemCount =
                otherCount
        end

        if ownCount == nil then

            local bestCount =
                TransferReadOfferCountFromOffers(directOffers)

            if bestCount ~= nil then
                TransferState.TradeOwnItemCount =
                    bestCount
            end
        end

        TransferState.LastTradeUpdate =
            os.clock()
    end

    local status =
        rawget(payload, "status")
        or rawget(payload, "Status")

    if type(status) == "table" then

        local result =
            rawget(status, "result")
            or rawget(status, "Result")

        if result ~= nil then

            TransferState.TradeResult =
                tostring(result)

            if tostring(result) == "Completed" then
                TransferState.TradeCompleted =
                    true
            end
        end
    end

    for _, row in pairs(payload) do

        if type(row) == "table" then

            local path =
                tostring(row[1] or "")

            local value =
                row[2]

            local stateSide =
                path:match("^ROOT/states/([^/]+)$")

            if stateSide then

                TransferState.TradeOpen =
                    true

                local oldState =
                    TransferState.TradeStates[stateSide]

                TransferState.TradeStates[stateSide] =
                    tostring(value)

                TransferState.LastTradeUpdate =
                    os.clock()
                
                if tostring(value) == "Processing" then

                    local localSideText =
                        tostring(TransferState.LocalTradeSide or "")

                    -- Only our own side Processing means this client is done.
                    -- Other side Processing means the other player confirmed,
                    -- but we may still need to press Confirm locally.
                    if localSideText ~= ""
                    and tostring(stateSide) == localSideText then

                        TransferMarkTradeCompleted(
                            "Local DataStream state Processing."
                        )

                    elseif TransferGetLocalTradeState() == "Processing" then

                        TransferMarkTradeCompleted(
                            "Local state Processing."
                        )
                    end
                end

                if tostring(oldState) ~= tostring(value) then

                    print(
                        "[TRANSFER DATA]",
                        "StateChanged",
                        "| side:",
                        tostring(stateSide),
                        "| old:",
                        tostring(oldState),
                        "| new:",
                        tostring(value),
                        "| localSide:",
                        tostring(TransferState.LocalTradeSide),
                        "| otherSide:",
                        tostring(TransferState.OtherTradeSide),
                        "| localState:",
                        tostring(TransferGetLocalTradeState()),
                        "| otherState:",
                        tostring(TransferGetOtherTradeState()),
                        "| otherItems:",
                        tostring(TransferState.TradeOtherItemCount),
                        "| button:",
                        tostring(TransferGetTradeButtonText())
                    )
                end
            end

            local offerSide, indexText =
                path:match("^ROOT/offers/([^/]+)/items/(%d+)")

            if offerSide
            and indexText then

                local index =
                    tonumber(indexText)

                if index then

                    local count =
                        index

                    TransferState.TradeOpen =
                        true

                    TransferState.TradeOfferCounts[offerSide] =
                        math.max(
                            tonumber(TransferState.TradeOfferCounts[offerSide]) or 0,
                            count
                        )

                    if tostring(offerSide) == tostring(TransferState.LocalTradeSide) then

                        TransferState.TradeOwnItemCount =
                            math.max(
                                tonumber(TransferState.TradeOwnItemCount) or 0,
                                count
                            )

                    elseif tostring(offerSide) == tostring(TransferState.OtherTradeSide) then

                        TransferState.TradeOtherItemCount =
                            math.max(
                                tonumber(TransferState.TradeOtherItemCount) or 0,
                                count
                            )

                    elseif TransferState.LocalTradeSide == nil then

                        TransferState.TradeOwnItemCount =
                            math.max(
                                tonumber(TransferState.TradeOwnItemCount) or 0,
                                count
                            )
                    end

                    TransferState.LastTradeUpdate =
                        os.clock()
                end
            end

            if type(value) == "table" then
                TransferUpdateTradeTrackerFromPayload(value)
            end
        end
    end
end

function TransferStartTradeWatchers()

    if TransferState.TradeWatchConnected == true then
        return
    end

    TransferState.TradeWatchConnected =
        true

    local gameEvents =
        ReplicatedStorage:FindFirstChild("GameEvents")

    if not gameEvents then
        return
    end

    local dataStream2 =
        gameEvents:FindFirstChild("DataStream2")

    if dataStream2
    and dataStream2:IsA("RemoteEvent") then

        dataStream2.OnClientEvent:Connect(function(...)

            local args =
                { ... }

            if args[1] == "InitData"
            and type(args[3]) == "table" then

                TransferUpdateTradeTrackerFromPayload(
                    args[3]
                )

            elseif args[1] == "UpdateData"
            and type(args[3]) == "table" then

                TransferUpdateTradeTrackerFromPayload(
                    args[3]
                )
            end
        end)
    end

    local tradeEvents =
        gameEvents:FindFirstChild("TradeEvents")

    if not tradeEvents then
        return
    end

    local sendRequest =
        tradeEvents:FindFirstChild("SendRequest")

    if sendRequest
    and sendRequest:IsA("RemoteEvent") then

        sendRequest.OnClientEvent:Connect(function(requestId, senderPlayer)

            local requestText =
                tostring(requestId or "")

            if requestText ~= ""
            and TransferState.IncomingRequestHandled[requestText] == true then
                return
            end

            if typeof(senderPlayer) == "Instance"
            and senderPlayer:IsA("Player") then

                TransferState.RequestExpired =
                    false

                TransferState.RequestExpiredReason =
                    ""

                TransferState.IncomingRequestId =
                    requestText

                TransferState.IncomingRequestPlayerName =
                    tostring(senderPlayer.Name)

                TransferState.IncomingRequestAt =
                    os.clock()

                print(
                    "[TRANSFER] Incoming request:",
                    tostring(senderPlayer.Name),
                    tostring(requestId)
                )
            end
        end)
    end

    local giftPet =
        gameEvents:FindFirstChild("GiftPet")

    if giftPet
    and giftPet:IsA("RemoteEvent") then

        giftPet.OnClientEvent:Connect(function(giftId, petName, senderName)

            giftId =
                CleanText(giftId)

            petName =
                CleanText(petName)

            senderName =
                CleanText(senderName)

            if giftId == "" then
                return
            end

            TransferState.LastGiftId =
                giftId

            TransferState.LastGiftPetName =
                petName

            TransferState.LastGiftSenderName =
                senderName

            print(
                "[TRANSFER GIFT]",
                "Incoming gift:",
                "| id:",
                tostring(giftId),
                "| pet:",
                tostring(petName),
                "| sender:",
                tostring(senderName),
                "| auto:",
                tostring(TransferState.AutoAcceptGift)
            )

            if TransferState.AutoAcceptGift == true then

                task.defer(function()

                    TransferAcceptPetGift(
                        giftId,
                        petName,
                        senderName
                    )
                end)
            end
        end)
    end

    local updateTradeState =
        tradeEvents:FindFirstChild("UpdateTradeState")

    if updateTradeState
    and updateTradeState:IsA("RemoteEvent") then

        updateTradeState.OnClientEvent:Connect(function(tradeId)

            if tradeId == nil then

                if TransferState.TradeCompleted == true
                or TransferState.TradeResult == "Completed"
                or TransferGetLocalTradeState() == "Processing" then

                    TransferMarkTradeCompleted(
                        "UpdateTradeState closed after local processing."
                    )

                    return
                end

                if TransferState.TradeOpen == true then

                    TransferMarkTradeDeclined(
                        "Trade closed before completion."
                    )
                end

                return
            end

            TransferState.TradeId =
                tostring(tradeId)

            -- Do NOT mark TradeOpen from tradeId alone.
            -- The request popup can exist before LiveTrade/DataStream offer data is ready.
            -- TradeOpen is set only by TransferWaitForTradeOpen() after real UI/data appears.
            TransferState.LastTradeUpdate =
                os.clock()
        end)
    end

    local addToHistory =
        tradeEvents:FindFirstChild("AddToHistory")

    if addToHistory
    and addToHistory:IsA("RemoteEvent") then

        addToHistory.OnClientEvent:Connect(function(payload)

            TransferUpdateTradeTrackerFromPayload(
                payload
            )
        end)
    end

    local notification =
        gameEvents:FindFirstChild("Notification")

    if notification
    and notification:IsA("RemoteEvent") then

        notification.OnClientEvent:Connect(function(message)

            local text =
                tostring(message or "")

            local lower =
                text:lower()

            if lower:find("request expired", 1, true) then

                TransferMarkRequestExpired(
                    text
                )

            elseif lower:find("trade completed", 1, true) then

                TransferMarkTradeCompleted(
                    text
                )

            elseif lower:find("declined the trade", 1, true)
            or lower:find("declined trade", 1, true) then

                TransferMarkTradeDeclined(
                    text
                )

            elseif lower:find("can't send a trade request while in a trade", 1, true)
            or lower:find("cant send a trade request while in a trade", 1, true)
            or lower:find("cannot send a trade request while in a trade", 1, true) then

                TransferMarkRequestBlocked(
                    text
                )
            end
        end)
    end
end

function TransferWaitForTradeOpen(timeout)

    timeout =
        tonumber(timeout)
        or 20

    local started =
        os.clock()

    local lastStatusAt =
        0

    TransferSetStatus(
        "Waiting Trade",
        "Waiting for real trade UI/data."
    )

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferState.TradeDeclined == true then
            return false
        end

        if TransferState.RequestBlocked == true then
            return false
        end

        local actualOpen, reason =
            TransferActualTradeOpen()

        if actualOpen == true then

            TransferState.TradeOpen =
                true

            TransferState.LastTradeUpdate =
                os.clock()

            print(
                "[TRANSFER OPEN]",
                "Real trade detected:",
                tostring(reason),
                "| tradeId:",
                tostring(TransferState.TradeId),
                "| localSide:",
                tostring(TransferState.LocalTradeSide),
                "| otherSide:",
                tostring(TransferState.OtherTradeSide),
                "| button:",
                tostring(TransferGetTradeButtonText())
            )

            return true
        end

        if os.clock() - started >= timeout then
            return false
        end

        if os.clock() - lastStatusAt >= 0.35 then

            lastStatusAt =
                os.clock()

            TransferSetStatus(
                "Waiting Trade",
                "Waiting real trade. "
                    .. tostring(reason)
            )
        end

        task.wait(0.03)
    end

    return false
end

function TransferWaitForOwnOfferCountAtLeast(expectedCount, timeout)

    expectedCount =
        tonumber(expectedCount)
        or 0

    timeout =
        tonumber(timeout)
        or 4

    local started =
        os.clock()

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        local currentCount =
            tonumber(TransferState.TradeOwnItemCount)
            or 0

        if currentCount >= expectedCount then
            return true
        end

        if os.clock() - started >= timeout then
            return false
        end

        task.wait(0.1)
    end

    return false
end

function TransferWaitForOwnOfferCountAtLeastOrSettled(startingCount, expectedCount, timeout, settleWindow)

    startingCount =
        tonumber(startingCount)
        or 0

    expectedCount =
        tonumber(expectedCount)
        or startingCount

    timeout =
        tonumber(timeout)
        or 2

    settleWindow =
        tonumber(settleWindow)
        or 0.35

    local started =
        os.clock()

    local lastSeen =
        tonumber(TransferState.TradeOwnItemCount)
        or startingCount

    local lastChanged =
        os.clock()

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        local currentCount =
            tonumber(TransferState.TradeOwnItemCount)
            or 0

        if currentCount >= expectedCount then
            return currentCount, true
        end

        if currentCount ~= lastSeen then

            lastSeen =
                currentCount

            lastChanged =
                os.clock()
        end

        if currentCount > startingCount
        and os.clock() - lastChanged >= settleWindow then
            return currentCount, false
        end

        if os.clock() - started >= timeout then
            return currentCount, false
        end

        task.wait(0.05)
    end

    return tonumber(TransferState.TradeOwnItemCount) or startingCount, false
end

function TransferWaitForTradeCompleted(timeout)

    timeout =
        tonumber(timeout)
        or 25

    local started =
        os.clock()

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferState.TradeCompleted == true
        or TransferState.TradeResult == "Completed"
        or TransferGetLocalTradeState() == "Processing" then
            return true
        end

        if os.clock() - started >= timeout then
            return false
        end

        task.wait(0.2)
    end

    return false
end

TransferParseCooldownText =
    nil

TransferGuiHasPositiveTradeValue =
    nil

TransferGetTradeButtonText =
    nil

TransferGuiWaitingForSpecificPlayer =
    nil

TransferLocalAcceptLocked =
    nil

TransferAcceptLikelyLockedFromButtonPhase =
    nil

TransferReceiverAcceptedAfterLocal =
    nil

TransferIsGuiObjectVisible =
    nil

TransferGetTradeButtonText = function()

    local liveTrade =
        TransferGetLiveTradeFrame()

    local label =
        liveTrade
        and liveTrade:FindFirstChild("Options")
        and liveTrade.Options:FindFirstChild("Accept")
        and liveTrade.Options.Accept:FindFirstChild("Label")

    if label
    and label:IsA("TextLabel")
    and TransferIsGuiObjectVisible(label) == true then
        return CleanText(label.Text)
    end

    return ""
end

function TransferIsLiveTradeOpen()

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    local tradingUI =
        playerGui
        and playerGui:FindFirstChild("TradingUI")

    local liveTrade =
        tradingUI
        and tradingUI:FindFirstChild("LiveTrade")

    if not liveTrade then
        return false
    end

    if liveTrade:IsA("GuiObject")
    and liveTrade.Visible ~= true then
        return false
    end

    local buttonText =
        TransferGetTradeButtonText()

    -- Completed/processing means the trade is already finishing.
    -- Do not block the next batch forever on stale UI.
    if TransferState.TradeCompleted == true
    or TransferState.TradeResult == "Completed"
    or TransferGetLocalTradeState() == "Processing" then
        return false
    end

    -- Only treat it as active if the trade button still has active trade text.
    if buttonText == "Accept"
    or buttonText == "Accepted"
    or buttonText == "Confirm"
    or buttonText == "Confirmed"
    or TransferParseCooldownText(buttonText) ~= nil then
        return true
    end

    return false
end

function TransferMarkClosedIfLiveTradeGone(reason)

    if TransferState.TradeOpen ~= true then
        return false
    end

    if TransferState.TradeCompleted == true
    or TransferState.TradeResult == "Completed" then
        return false
    end

    if TransferState.TradeDeclined == true then
        return true
    end

    if TransferIsLiveTradeOpen() == true then
        return false
    end

    TransferMarkTradeDeclined(
        tostring(reason or "LiveTrade closed.")
    )

    print(
        "[TRANSFER SEND TIMING]",
        "Detected trade closed locally",
        "| reason:",
        tostring(reason),
        "| tradeId:",
        tostring(TransferState.TradeId)
    )

    return true
end

function TransferWaitForLiveTradeClosed(timeout)

    timeout =
        tonumber(timeout)
        or 4

    local started =
        os.clock()

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferRawLiveTradeVisible() ~= true then
            return true
        end

        if os.clock() - started >= timeout then

            print(
                "[TRANSFER CLOSE]",
                "LiveTrade still visibly open after timeout.",
                "| timeout:",
                tostring(timeout),
                "| button:",
                tostring(TransferGetTradeButtonText()),
                "| local:",
                tostring(TransferGetLocalTradeState()),
                "| other:",
                tostring(TransferGetOtherTradeState()),
                "| completed:",
                tostring(TransferState.TradeCompleted),
                "| result:",
                tostring(TransferState.TradeResult)
            )

            return false
        end

        TransferSetStatus(
            "Waiting Close",
            "Waiting visible old trade UI to close. Button="
                .. tostring(TransferGetTradeButtonText())
        )

        task.wait(0.10)
    end

    return false
end

function TransferStateIsInTradeLike(state)

    state =
        tostring(state or "")

    return state == "Accepted"
        or state == "Confirmed"
        or state == "Processing"
end

function TransferIsInTradeHard()

    if TransferIsLiveTradeOpen() == true then
        return true, "LiveTrade open"
    end

    if TransferState.TradeCompleted == true
    or TransferState.TradeResult == "Completed" then
        return false, "Completed"
    end

    local localState =
        TransferGetLocalTradeState()

    local otherState =
        TransferGetOtherTradeState()

    if TransferStateIsInTradeLike(localState) then
        return true, "Local state " .. tostring(localState)
    end

    if TransferStateIsInTradeLike(otherState) then
        return true, "Other state " .. tostring(otherState)
    end

    if TransferState.TradeOpen == true then

        if TransferState.TradeDeclined == true then

            local age =
                os.clock()
                - (
                    tonumber(TransferState.LastTradeUpdate)
                    or os.clock()
                )

            if age >= 0.75 then
                return false, "Declined settled"
            end

            return true, "Decline settling"
        end

        return true, "TradeOpen true"
    end

    if TransferState.TradeDeclined == true then

        local age =
            os.clock()
            - (
                tonumber(TransferState.LastTradeUpdate)
                or os.clock()
            )

        if age < 0.75 then
            return true, "Decline settling"
        end

        return false, "Declined settled"
    end

    return false, "Safe"
end

function TransferWaitUntilSafeToSendTicket(timeout)

    timeout =
        tonumber(timeout)
        or 10

    local started =
        os.clock()

    local lastStatusAt =
        0

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        local inTrade, reason =
            TransferIsInTradeHard()

        if inTrade ~= true then

            -- Small settle window so Roblox/server finishes clearing the old trade.
            task.wait(0.25)

            local stillInTrade, secondReason =
                TransferIsInTradeHard()

            if stillInTrade ~= true then

                print(
                    "[TRANSFER SEND GATE]",
                    "Safe to send ticket.",
                    "| waited:",
                    string.format("%.3fs", os.clock() - started),
                    "| reason:",
                    tostring(reason),
                    "| second:",
                    tostring(secondReason)
                )

                return true
            end

            reason =
                secondReason
        end

        if os.clock() - started >= timeout then

            TransferSetStatus(
                "Still In Trade",
                tostring(reason)
            )

            print(
                "[TRANSFER SEND GATE]",
                "Blocked send ticket.",
                "| timeout:",
                tostring(timeout),
                "| reason:",
                tostring(reason),
                "| liveOpen:",
                tostring(TransferIsLiveTradeOpen()),
                "| tradeOpen:",
                tostring(TransferState.TradeOpen),
                "| local:",
                tostring(TransferGetLocalTradeState()),
                "| other:",
                tostring(TransferGetOtherTradeState())
            )

            return false, tostring(reason)
        end

        if os.clock() - lastStatusAt >= 0.35 then

            lastStatusAt =
                os.clock()

            TransferSetStatus(
                "Waiting Safe",
                "Still in trade: " .. tostring(reason)
            )
        end

        task.wait(0.1)
    end

    return false, "Transfer disabled"
end

function TransferHideTradeRequestPopup(playerName)

    playerName =
        CleanText(playerName)

    if playerName == "" then
        return false
    end

    local lowerName =
        playerName:lower()

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    if not playerGui then
        return false
    end

    local hidden =
        0

    for _, obj in ipairs(playerGui:GetDescendants()) do

        if obj:IsA("TextLabel")
        or obj:IsA("TextButton")
        or obj:IsA("TextBox") then

            local text =
                tostring(obj.Text or "")
                    :lower()

            if text:find(lowerName, 1, true)
            and text:find("trade request", 1, true) then

                local container =
                    obj

                for _ = 1, 6 do

                    if not container
                    or container == playerGui then
                        break
                    end

                    local hasAccept =
                        false

                    local hasDecline =
                        false

                    for _, child in ipairs(container:GetDescendants()) do

                        if child:IsA("TextLabel")
                        or child:IsA("TextButton")
                        or child:IsA("TextBox") then

                            local childText =
                                tostring(child.Text or "")
                                    :lower()

                            if childText == "accept" then
                                hasAccept =
                                    true
                            end

                            if childText == "decline" then
                                hasDecline =
                                    true
                            end
                        end
                    end

                    if hasAccept == true
                    and hasDecline == true
                    and container:IsA("GuiObject") then

                        pcall(function()
                            container.Visible =
                                false
                        end)

                        hidden =
                            hidden + 1

                        break
                    end

                    container =
                        container.Parent
                end
            end
        end
    end

    if hidden > 0 then

        print(
            "[TRANSFER] Hid stale request popup:",
            tostring(playerName),
            "| count:",
            tostring(hidden)
        )

        return true
    end

    return false
end

TransferGuiWaitingForSpecificPlayer = function()

    local targetName =
        CleanText(TransferState.TargetPlayerName)

    if targetName == "" then
        return false
    end

    local lowerTarget =
        targetName:lower()

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    local tradingUI =
        playerGui
        and playerGui:FindFirstChild("TradingUI")

    if not tradingUI then
        return false
    end

    for _, obj in ipairs(tradingUI:GetDescendants()) do

        if obj:IsA("TextLabel")
        or obj:IsA("TextButton")
        or obj:IsA("TextBox") then

            local text =
                tostring(obj.Text or "")
                    :lower()

            if text:find("waiting for", 1, true)
            and text:find(lowerTarget, 1, true) then
                return true
            end
        end
    end

    return false
end

function TransferGuiPlayerHasAccepted(playerName)

    playerName =
        CleanText(playerName)

    if playerName == "" then
        return false
    end

    local lowerName =
        playerName:lower()

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    local tradingUI =
        playerGui
        and playerGui:FindFirstChild("TradingUI")

    if not tradingUI then
        return false
    end

    for _, obj in ipairs(tradingUI:GetDescendants()) do

        if obj:IsA("TextLabel")
        or obj:IsA("TextButton")
        or obj:IsA("TextBox") then

            local text =
                tostring(obj.Text or "")
                    :lower()

            if text:find(lowerName, 1, true)
            and text:find("has accepted", 1, true) then
                return true
            end
        end
    end

    return false
end

function TransferGuiPlayerHasConfirmed(playerName)

    playerName =
        CleanText(playerName)

    if playerName == "" then
        return false
    end

    local lowerName =
        playerName:lower()

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    local tradingUI =
        playerGui
        and playerGui:FindFirstChild("TradingUI")

    if not tradingUI then
        return false
    end

    for _, obj in ipairs(tradingUI:GetDescendants()) do

        if obj:IsA("TextLabel")
        or obj:IsA("TextButton")
        or obj:IsA("TextBox") then

            local text =
                tostring(obj.Text or "")
                    :lower()

            if text:find(lowerName, 1, true)
            and text:find("confirmed", 1, true) then
                return true
            end
        end
    end

    return false
end

function TransferGetReadyLabelText(sideName)

    sideName =
        tostring(sideName or "")

    local liveTrade =
        TransferGetLiveTradeFrame()

    local label =
        liveTrade
        and liveTrade:FindFirstChild(sideName)
        and liveTrade[sideName]:FindFirstChild("Ready")
        and liveTrade[sideName].Ready:FindFirstChild("Label")

    if label
    and label:IsA("TextLabel")
    and TransferIsGuiObjectVisible(label) == true then
        return CleanText(label.Text)
    end

    return ""
end

function TransferReadyLabelIsAccepted(sideName)

    local text =
        TransferGetReadyLabelText(sideName)

    return text == "Accepted"
        or text == "Confirmed"
        or text == "Processing"
end

function TransferReadyLabelIsConfirmed(sideName)

    local text =
        TransferGetReadyLabelText(sideName)

    return text == "Confirmed"
        or text == "Processing"
end

function TransferCountStatesWithValue(wantedState)

    wantedState =
        tostring(wantedState or "")

    local count =
        0

    for _, state in pairs(TransferState.TradeStates or {}) do

        if tostring(state) == wantedState then
            count =
                count + 1
        end
    end

    return count
end

function TransferBothPlayersAccepted()

    if TransferCountStatesWithValue("Accepted") >= 2 then
        return true
    end

    if TransferGetLocalTradeState() == "Accepted"
    and TransferGetOtherTradeState() == "Accepted" then
        return true
    end

    local buttonText =
        TransferGetTradeButtonText()

    if buttonText == "Confirm"
    or buttonText == "Confirmed" then
        return true
    end

    return false
end

function TransferGetTradeStatusText()

    local liveTrade =
        TransferGetLiveTradeFrame()

    local statusLabel =
        liveTrade
        and liveTrade:FindFirstChild("Status")

    if statusLabel
    and statusLabel:IsA("TextLabel")
    and TransferIsGuiObjectVisible(statusLabel) == true then
        return CleanText(statusLabel.Text)
    end

    return ""
end

function TransferIsConfirmPhase()

    if TransferBothPlayersAccepted() == true then
        return true
    end

    if TransferReadyLabelIsAccepted("MyPlr") == true
    and TransferReadyLabelIsAccepted("OtherPlr") == true then
        return true
    end

    local statusText =
        TransferGetTradeStatusText():lower()

    if statusText:find("confirm", 1, true) then
        return true
    end

    return false
end

function TransferOtherFinalConfirmedLike()

    local otherState =
        TransferGetOtherTradeState()

    if otherState == "Confirmed"
    or otherState == "Processing" then
        return true
    end

    if TransferReadyLabelIsConfirmed("OtherPlr") == true then
        return true
    end

    if TransferGuiPlayerHasConfirmed(
        TransferState.TargetPlayerName
    ) then
        return true
    end

    local statusText =
        tostring(
            TransferGetTradeStatusText()
            or ""
        ):lower()

    local targetName =
        CleanText(
            TransferState.TargetPlayerName
        ):lower()

    if targetName ~= ""
    and statusText:find(targetName, 1, true)
    and statusText:find("confirmed", 1, true) then
        return true
    end

    return false
end

function TransferConfirmWindowReady()

    local buttonText =
        TransferGetTradeButtonText()

    if buttonText == "Confirm"
    or buttonText == "Confirmed" then
        return true
    end

    local seconds =
        TransferParseCooldownText(buttonText)

    if TransferIsConfirmPhase() == true
    and seconds ~= nil
    and seconds <= 0.20 then
        return true
    end

    if TransferLocalAcceptLocked() == true
    and TransferOtherFinalConfirmedLike() == true then
        return true
    end

    return false
end

function TransferTradeStateIsAcceptedLike(state)

    state =
        tostring(state or "")

    return state == "Accepted"
        or state == "Confirmed"
        or state == "Processing"
end

TransferLocalAcceptLocked = function()

    local buttonText =
        TransferGetTradeButtonText()

    if buttonText == "Accepted"
    or buttonText == "Confirm"
    or buttonText == "Confirmed" then
        return true
    end

    if TransferReadyLabelIsAccepted("MyPlr") == true then
        return true
    end

    if TransferTradeStateIsAcceptedLike(
        TransferGetLocalTradeState()
    ) then
        return true
    end

    return false
end

TransferAcceptLikelyLockedFromButtonPhase = function()

    if TransferLocalAcceptLocked() == true then

        TransferTimingMark(
            "AcceptLockedAt"
        )

        return true
    end

    local timing =
        TransferState.Timing

    if type(timing) ~= "table" then
        return false
    end

    if timing.FirstAcceptAt == nil then
        return false
    end

    if tonumber(timing.Attempts) == nil
    or tonumber(timing.Attempts) < 3 then
        return false
    end

    local buttonText =
        TransferGetTradeButtonText()

    -- Do NOT trust plain countdown text here.
    -- The same countdown also appears before Accept is actually locked.
    if buttonText == "Accepted"
    or buttonText == "Confirm"
    or buttonText == "Confirmed" then

        TransferTimingMark(
            "AcceptLockedAt"
        )

        return true
    end

    if TransferTradeStateIsAcceptedLike(
        TransferGetLocalTradeState()
    ) then

        TransferTimingMark(
            "AcceptLockedAt"
        )

        return true
    end

    -- GUI fallback only if the UI explicitly says our own player accepted.
    if TransferGuiPlayerHasAccepted(
        LocalPlayer.Name
    ) then

        TransferTimingMark(
            "AcceptLockedAt"
        )

        return true
    end

    return false
end

TransferReceiverAcceptedAfterLocal = function()

    local buttonText =
        TransferGetTradeButtonText()

    -- If Confirm is visible, both players have passed accept.
    if buttonText == "Confirm"
    or buttonText == "Confirmed" then
        return true
    end

    if TransferReadyLabelIsAccepted("OtherPlr") == true then
        return true
    end

    -- Real state from DataStream2.
    if TransferTradeStateIsAcceptedLike(
        TransferGetOtherTradeState()
    ) then
        return true
    end

    -- If both states are accepted, receiver accepted.
    if TransferBothPlayersAccepted() == true then
        return true
    end

    -- Do NOT trust plain cooldown text.
    -- The dump proved cooldown is also shown before Accept is actually locked.
    return false
end

function TransferWaitForReceiverAccepted(timeout)

    timeout =
        tonumber(timeout)
        or 45

    local started =
        os.clock()

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferState.TradeDeclined == true
        or TransferMarkClosedIfLiveTradeGone("Trade UI closed while waiting receiver.") == true then
            return false
        end

        if TransferReceiverAcceptedAfterLocal() then
            return true
        end

        TransferUpdateTradeStatusText(
            "Waiting Receiver",
            "Waiting receiver to accept."
        )

        if os.clock() - started >= timeout then
            return false
        end

        task.wait(0.2)
    end

    return false
end

function TransferSenderReadyForReceiverAccept()

    local otherState =
        TransferGetOtherTradeState()

    -- DataStream state.
    if TransferTradeStateIsAcceptedLike(otherState) then
        return true
    end

    -- Visible side label. Receiver sees sender on OtherPlr.
    if TransferReadyLabelIsAccepted("OtherPlr") == true then
        return true
    end

    -- Visible status text fallback: "@Sender has accepted".
    if TransferGuiPlayerHasAccepted(
        TransferState.TargetPlayerName
    ) then
        return true
    end

    local statusText =
        tostring(
            TransferGetTradeStatusText()
            or ""
        ):lower()

    local targetName =
        CleanText(
            TransferState.TargetPlayerName
        ):lower()

    if targetName ~= ""
    and statusText:find(targetName, 1, true)
    and statusText:find("has accepted", 1, true) then
        return true
    end

    return false
end

function TransferWaitForSenderReadyForReceiverAccept(timeout)

    timeout =
        tonumber(timeout)
        or 120

    local started =
        os.clock()

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferState.TradeDeclined == true then
            return false
        end

        if TransferSenderReadyForReceiverAccept() then
            return true
        end

        TransferUpdateTradeStatusText(
            "Waiting Sender",
            "Waiting sender to accept."
        )

        if os.clock() - started >= timeout then
            return false
        end

        task.wait(0.2)
    end

    return false
end

function TransferTryInstantFinalConfirm(reason)

    if TransferState.AutoConfirm ~= true then
        return false
    end

    if TransferState.TradeDeclined == true then
        return false
    end

    if TransferState.TradeCompleted == true
    or TransferState.TradeResult == "Completed" then
        return true
    end

    local buttonText =
        TransferGetTradeButtonText()

    local ready =
        buttonText == "Confirm"
        or buttonText == "Confirmed"
        or TransferOtherFinalConfirmedLike() == true
        or TransferConfirmWindowReady() == true

    if ready ~= true then
        return false
    end

    TransferTimingMark(
        "ConfirmSeenAt"
    )

    TransferUpdateTradeStatusText(
        "Instant Confirm",
        tostring(reason or "Confirm ready.")
            .. " | Button="
            .. tostring(buttonText)
    )

    for attempt = 1, 10 do

        if TransferState.TradeCompleted == true
        or TransferState.TradeResult == "Completed"
        or TransferGetLocalTradeState() == "Processing" then

            TransferTimingMark(
                "CompletedAt"
            )

            return true
        end

        local currentButton =
            TransferGetTradeButtonText()

        if currentButton ~= "Confirm"
        and currentButton ~= "Confirmed"
        and TransferOtherFinalConfirmedLike() ~= true then
            break
        end

        local ok, msg =
            TransferFireTradeRemote("Confirm")

        print(
            "[TRANSFER] Instant Confirm:",
            tostring(attempt),
            tostring(ok),
            tostring(msg),
            "| reason:",
            tostring(reason),
            "| button:",
            tostring(currentButton),
            "| local:",
            tostring(TransferGetLocalTradeState()),
            "| other:",
            tostring(TransferGetOtherTradeState()),
            "| status:",
            tostring(TransferGetTradeStatusText())
        )

        task.wait(0.08)
    end

    return TransferState.TradeCompleted == true
        or TransferState.TradeResult == "Completed"
        or TransferGetLocalTradeState() == "Processing"
end


function TransferWaitForConfirmReady(timeout)

    timeout =
        tonumber(timeout)
        or 8

    local started =
        os.clock()

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferState.TradeDeclined == true
        or TransferMarkClosedIfLiveTradeGone("Trade UI closed while waiting confirm.") == true then
            return false
        end

        local text =
            TransferGetTradeButtonText()

        local seconds =
            TransferParseCooldownText(text)

        if TransferState.Mode == "Receiver"
        and text == "Accept"
        and TransferSenderReadyForReceiverAccept() == true then

            local receiverOfferReady =
                TransferSideOfferReady(
                    "OtherPlr",
                    1,
                    TransferState.TradeOtherItemCount
                )

            if receiverOfferReady == true then

                TransferUpdateTradeStatusText(
                    "Instant Accept",
                    "Sender accepted. Receiver firing Accept now."
                )

                for _ = 1, 8 do

                    if TransferLocalAcceptLocked() == true then
                        break
                    end

                    TransferFireTradeRemote("Accept")

                    TransferTimingBumpAttempts(1)

                    task.wait()
                end

                task.wait(0.04)

                if TransferLocalAcceptLocked() == true then

                    TransferTimingMark(
                        "AcceptLockedAt"
                    )
                end
            end
        end

        if TransferConfirmWindowReady() == true then

            TransferTimingMark(
                "ConfirmSeenAt"
            )

            if TransferState.AutoConfirm == true then

                local instantConfirmed =
                    TransferTryInstantFinalConfirm(
                        "Confirm window became ready."
                    )

                if instantConfirmed == true then
                    return true
                end

                -- Even if the first instant confirm did not complete yet,
                -- return true so TransferConfirmAndWait starts hammering Confirm now.
                return true
            end

            return true
        end

        if TransferIsConfirmPhase() == true then

            TransferUpdateTradeStatusText(
                "Waiting Confirm",
                seconds
                    and (
                        "Confirm cooldown "
                        .. string.format("%.1f", seconds)
                        .. "s"
                    )
                    or (
                        "Confirm phase. Button="
                        .. tostring(text)
                    )
            )

        else

            TransferUpdateTradeStatusText(
                "Waiting Accept",
                "Waiting states before confirm. Button="
                    .. tostring(text)
                    .. " | Status="
                    .. tostring(TransferGetTradeStatusText())
            )
        end

        if os.clock() - started >= timeout then
            return false
        end

        task.wait(0.03)
    end

    return false
end

function TransferReceiverDrainOpenTrade(timeout)

    timeout =
        tonumber(timeout)
        or 25

    if TransferState.Mode ~= "Receiver" then
        return true
    end

    local started =
        os.clock()

    local lastAcceptAt =
        0

    local lastConfirmAt =
        0

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferState.TradeDeclined == true then
            return false
        end

        if TransferState.TradeCompleted == true
        or TransferState.TradeResult == "Completed"
        or TransferGetLocalTradeState() == "Processing" then
            return true
        end

        if TransferIsLiveTradeOpen() ~= true then
            return true
        end

        if os.clock() - started >= timeout then

            TransferSetStatus(
                "Drain Timeout",
                "Receiver still has open trade UI."
            )

            return false
        end

        local buttonText =
            TransferGetTradeButtonText()

        local otherItems =
            TransferGuiCountVisibleSideItems("OtherPlr")

        local otherValue =
            TransferGuiGetSidePriceAmount("OtherPlr")

        local otherReady =
            TransferReadyLabelIsAccepted("OtherPlr")

        local senderReady =
            TransferSenderReadyForReceiverAccept()

        local otherFinal =
            TransferOtherFinalConfirmedLike()

        if buttonText == "Confirm"
        or buttonText == "Confirmed"
        or otherFinal == true
        or TransferConfirmWindowReady() == true then

            if os.clock() - lastConfirmAt >= 0.10 then

                lastConfirmAt =
                    os.clock()

                TransferSetStatus(
                    "Drain Confirm",
                    "Open trade still active. Confirming now."
                )

                TransferTryInstantFinalConfirm(
                    "Receiver drain found open confirm-stage trade."
                )

                TransferConfirmAndWait(
                    "Drain Confirm",
                    6
                )
            end

        elseif buttonText == "Accept"
        and senderReady == true
        and (
            otherItems > 0
            or otherValue > 0
            or otherReady == true
        ) then

            if os.clock() - lastAcceptAt >= 0.10 then

                lastAcceptAt =
                    os.clock()

                TransferSetStatus(
                    "Drain Accept",
                    "Open trade still active. Accepting now."
                )

                for _ = 1, 8 do

                    if TransferLocalAcceptLocked() == true then
                        break
                    end

                    TransferFireTradeRemote("Accept")

                    TransferTimingBumpAttempts(1)

                    task.wait()
                end
            end

        else

            TransferSetStatus(
                "Drain Trade",
                "Finishing open trade before waiting request. Button="
                    .. tostring(buttonText)
                    .. " | OtherItems="
                    .. tostring(otherItems)
                    .. " | OtherValue="
                    .. tostring(otherValue)
                    .. " | SenderReady="
                    .. tostring(senderReady)
            )
        end

        task.wait(0.05)
    end

    return false
end


function TransferWaitForTrustedIncomingRequest(timeout)

    timeout =
        tonumber(timeout)
        or 60

    local started =
        os.clock()

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferState.Mode == "Receiver"
        and TransferRawLiveTradeVisible() == true then

            if TransferState.TradeCompleted == true
            or TransferState.TradeResult == "Completed"
            or TransferGetLocalTradeState() == "Processing" then

                TransferSetStatus(
                    "Waiting Close",
                    "Old completed trade UI still closing before next request."
                )

                TransferWaitForLiveTradeClosed(8)

                if TransferRawLiveTradeVisible() ~= true then
                    TransferResetTradeRuntime()
                end

            else

                TransferReceiverDrainOpenTrade(
                    25
                )
            end
        end

        local trusted =
            CleanText(TransferState.TargetPlayerName)

        if trusted ~= ""
        and TransferState.IncomingRequestPlayerName == trusted
        and os.clock() - TransferState.IncomingRequestAt <= 30 then
            return true
        end

        TransferSetStatus(
            "Waiting Request",
            trusted ~= ""
                and ("Waiting for " .. trusted)
                or "Choose a player."
        )

        if os.clock() - started >= timeout then
            return false
        end

        task.wait(0.05)
    end

    return false
end

function TransferStopWorker(reason)

    TransferState.TransferEnabled =
        false

    TransferState.IsTransferRunning =
        false

    if TransferState.TransferEnabledToggle
    and type(TransferState.TransferEnabledToggle.SetValue) == "function" then

        pcall(function()
            TransferState.TransferEnabledToggle:SetValue(false)
        end)
    end

    TransferSetStatus(
        "Stopped",
        tostring(reason or "Transfer stopped.")
    )
end

function TransferResetWorkerForModeSwitch(newMode)

    TransferState.TransferEnabled =
        false

    TransferState.IsTransferRunning =
        false

    TransferState.IsAddingPets =
        false

    TransferState.TradeOpen =
        false

    TransferState.TradeId =
        ""

    TransferState.TradePlayers =
        {}

    TransferState.TradeStates =
        {}

    TransferState.TradeOfferCounts =
        {}

    TransferState.LocalTradeSide =
        nil

    TransferState.OtherTradeSide =
        nil

    TransferState.TradeOwnItemCount =
        0

    TransferState.TradeOtherItemCount =
        0

    TransferState.TradeCompleted =
        false

    TransferState.TradeResult =
        ""

    TransferState.TradeDeclined =
        false

    TransferState.TradeDeclineReason =
        ""

    TransferState.RequestBlocked =
        false

    TransferState.RequestBlockedReason =
        ""

    TransferState.IncomingRequestId =
        ""

    TransferState.IncomingRequestPlayerName =
        ""

    TransferState.IncomingRequestAt =
        0

    TransferState.LastTradeUpdate =
        0

    if TransferState.TransferEnabledToggle
    and type(TransferState.TransferEnabledToggle.SetValue) == "function" then

        pcall(function()
            TransferState.TransferEnabledToggle:SetValue(false)
        end)
    end

    TransferSetStatus(
        "Mode Switched",
        "Switched to "
            .. tostring(newMode)
            .. ". Enable transfer again."
    )
end

function TransferTryAddPetToTrade(pet)

    if type(pet) ~= "table" then
        return false, "Invalid pet"
    end

    local attempts = {}

    if tostring(pet.UUID or "") ~= "" then

        table.insert(attempts, {
            Label = "UUIDWithBraces",
            Args = {
                "Pet",
                pet.UUID,
            },
        })

        table.insert(attempts, {
            Label = "UUIDNoBraces",
            Args = {
                "Pet",
                TransferNormalizeUUIDNoBraces(pet.UUID),
            },
        })
    end

    if pet.Tool
    and pet.Tool:IsA("Tool") then

        table.insert(attempts, {
            Label = "ToolWithType",
            Args = {
                "Pet",
                pet.Tool,
            },
        })

        table.insert(attempts, {
            Label = "ToolOnly",
            Args = {
                pet.Tool,
            },
        })
    end

    local lastError =
        "No AddItem attempts available"

    for _, attempt in ipairs(attempts) do

        if not IsHolyLiteCurrentRun() then
            return false, "Runtime stopped"
        end

        local beforeCount =
            tonumber(TransferState.TradeOwnItemCount)
            or 0

        local expectedCount =
            beforeCount + 1

        print(
            "[TRANSFER] Trying AddItem:",
            tostring(attempt.Label),
            "| Before:",
            tostring(beforeCount),
            "| Pet:",
            tostring(pet.PetName),
            tostring(pet.UUID)
        )

        local fired, msg =
            TransferFireTradeRemote(
                "AddItem",
                TransferUnpack(attempt.Args)
            )

        if fired == true then

            local confirmed =
                TransferWaitForOwnOfferCountAtLeast(
                    expectedCount,
                    3.5
                )

            if confirmed == true then

                return true,
                    "Confirmed via "
                        .. tostring(attempt.Label)
            end

            lastError =
                "Fired "
                    .. tostring(attempt.Label)
                    .. " but offer count did not increase."

        else

            lastError =
                tostring(msg)
        end

        task.wait(0.2)
    end

    return false, lastError
end

function TransferFirePetAddNoWait(pet)

    if type(pet) ~= "table" then
        return false, "Invalid pet"
    end

    if tostring(pet.UUID or "") ~= "" then

        local ok, msg =
            TransferFireTradeRemote(
                "AddItem",
                "Pet",
                pet.UUID
            )

        return ok,
            ok == true
            and "Fired UUIDWithBraces"
            or tostring(msg)
    end

    if pet.Tool
    and pet.Tool:IsA("Tool") then

        local ok, msg =
            TransferFireTradeRemote(
                "AddItem",
                "Pet",
                pet.Tool
            )

        return ok,
            ok == true
            and "Fired ToolWithType"
            or tostring(msg)
    end

    return false, "Missing UUID/tool"
end

function TransferSendTicket()

    if TransferRawLiveTradeVisible() == true then

        TransferSetStatus(
            "Existing Trade",
            "Visible LiveTrade still open before sending ticket."
        )

        if TransferState.TradeCompleted ~= true
        and TransferState.TradeResult ~= "Completed"
        and TransferGetLocalTradeState() ~= "Processing"
        and (
            TransferConfirmWindowReady() == true
            or TransferGetTradeButtonText() == "Confirm"
            or TransferGetTradeButtonText() == "Confirmed"
        ) then

            TransferTryInstantFinalConfirm(
                "Sender found existing confirm-stage trade before sending ticket."
            )

            TransferConfirmAndWait(
                "Existing Confirm",
                10
            )
        end

        TransferWaitForLiveTradeClosed(8)

        if TransferRawLiveTradeVisible() == true then

            TransferSetStatus(
                "Ticket Blocked",
                "Old visible trade UI still open. Not sending a new request."
            )

            return false
        end

        TransferResetTradeRuntime()
    end

    local target =
        TransferResolveTargetPlayer()

    if not target then

        TransferSetStatus(
            "No Target",
            "Choose a target player."
        )

        return false
    end

    local equipped =
        TransferEquipTradeTicket()

    if equipped ~= true then
        return false
    end

    task.wait(0.15)

    local ok, msg =
        TransferFireTradeRemote(
            "SendRequest",
            target
        )

    TransferSetStatus(
        ok and "Ticket Sent" or "Ticket Failed",
        msg .. " -> " .. tostring(target.Name)
    )

    print(
        "[TRANSFER] SendRequest:",
        tostring(ok),
        tostring(msg),
        tostring(target.Name)
    )

    return ok
end

function TransferRespondRequest(accept)

    local requestId =
        CleanText(TransferState.IncomingRequestId)

    if requestId == "" then

        TransferSetStatus(
            "Request Failed",
            "Missing incoming request id."
        )

        return false
    end

    local remote =
        TransferGetTradeRemote("RespondRequest")

    if not remote
    or not remote:IsA("RemoteEvent") then

        TransferSetStatus(
            "Request Failed",
            "Missing RespondRequest remote."
        )

        return false
    end

    -- Grow a Garden uses false for accepting the ticket request.
    -- Remote spy:
    -- RespondRequest:FireServer(requestId, false)
    local responseValue =
        accept == true
        and false
        or true

    local ok, err =
        pcall(function()

            remote:FireServer(
                requestId,
                responseValue
            )
        end)

    if ok == true then

        TransferState.IncomingRequestHandled[requestId] =
            true

        if accept == true then

            TransferHideTradeRequestPopup(
                TransferState.IncomingRequestPlayerName
            )
        end

        TransferState.IncomingRequestId =
            ""

        TransferState.IncomingRequestPlayerName =
            ""

        TransferState.IncomingRequestAt =
            0
    end

    local msg =
        ok
        and (
            accept == true
            and "Accepted request"
            or "Declined request"
        )
        or tostring(err)

    TransferSetStatus(
        ok
            and (
                accept == true
                and "Request Accepted"
                or "Request Declined"
            )
            or "Request Failed",
        msg
    )

    print(
        "[TRANSFER] RespondRequest:",
        tostring(ok),
        "| accept:",
        tostring(accept),
        "| requestId:",
        tostring(requestId),
        "| value:",
        tostring(responseValue),
        "|",
        tostring(msg)
    )

    return ok
end

function TransferAcceptIncomingRequest()

    return TransferRespondRequest(true)
end

function TransferDeclineIncomingRequest()

    return TransferRespondRequest(false)
end

function TransferDeclineTrade()

    local firstOk, firstMsg =
        TransferFireTradeRemote("Decline")

    task.wait(0.08)

    local secondOk, secondMsg =
        TransferFireTradeRemote("Decline")

    local ok =
        firstOk == true
        or secondOk == true

    local msg =
        "First: "
        .. tostring(firstMsg)
        .. " | Second: "
        .. tostring(secondMsg)

    TransferSetStatus(
        ok and "Declined" or "Decline Failed",
        msg
    )

    print(
        "[TRANSFER] Decline:",
        tostring(ok),
        "| first:",
        tostring(firstOk),
        tostring(firstMsg),
        "| second:",
        tostring(secondOk),
        tostring(secondMsg)
    )

    if ok == true then

        TransferMarkTradeDeclined(
            "Local decline requested."
        )

        -- Give Roblox/server time to actually clear the old trade.
        TransferWaitForLiveTradeClosed(3)
    end

    return ok
end

function TransferConfirmTrade()

    local ok, msg =
        TransferFireTradeRemote("Confirm")

    TransferSetStatus(
        ok and "Confirmed" or "Confirm Failed",
        msg
    )

    print("[TRANSFER] Confirm:", tostring(ok), tostring(msg))

    return ok
end

TransferIsGuiObjectVisible = function(obj)

    local current =
        obj

    while current
    and current ~= LocalPlayer:FindFirstChild("PlayerGui") do

        if current:IsA("GuiObject")
        and current.Visible == false then
            return false
        end

        current =
            current.Parent
    end

    return true
end

function TransferExtractPositiveTradeValueFromText(text)

    text =
        CleanText(text)

    if text == "" then
        return nil
    end

    local lower =
        text:lower()

    -- Ignore cooldowns/timers/buttons/non-value labels.
    if lower:match("^%d+%.?%d*s$")
    or lower:find("¢", 1, true)
    or lower:find("add", 1, true)
    or lower:find("accept", 1, true)
    or lower:find("confirm", 1, true)
    or lower:find("decline", 1, true)
    or lower:find("waiting", 1, true)
    or lower:find("trade", 1, true)
    or lower:find("token", 1, true) == nil and lower:find("value", 1, true) == nil and not lower:match("^%d+[,%d]*$")
    or text:find(":", 1, true) then
        return nil
    end

    local numberText =
        text:gsub(",", ""):match("(%d+%.?%d*)")

    local number =
        tonumber(numberText)

    if not number
    or number <= 0 then
        return nil
    end

    return number
end

TransferGuiHasPositiveTradeValue = function()

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    local tradingUI =
        playerGui
        and playerGui:FindFirstChild("TradingUI")

    if not tradingUI then
        return false, 0
    end

    local bestValue =
        0

    for _, obj in ipairs(tradingUI:GetDescendants()) do

        if obj:IsA("TextLabel")
        or obj:IsA("TextButton")
        or obj:IsA("TextBox") then

            if TransferIsGuiObjectVisible(obj) then

                local value =
                    TransferExtractPositiveTradeValueFromText(obj.Text)

                if value
                and value > bestValue then

                    bestValue =
                        value
                end
            end
        end
    end

    return bestValue > 0,
        bestValue
end

function TransferWaitForVisibleTradeValue(timeout)

    timeout =
        tonumber(timeout)
        or 10

    local started =
        os.clock()

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferState.TradeDeclined == true then
            return false
        end

        local hasValue =
            TransferGuiHasPositiveTradeValue()

        if hasValue == true then
            return true
        end

        if os.clock() - started >= timeout then
            return false
        end

        task.wait()
    end

    return false
end

function TransferGetLiveTradeFrame()

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    local tradingUI =
        playerGui
        and playerGui:FindFirstChild("TradingUI")

    local liveTrade =
        tradingUI
        and tradingUI:FindFirstChild("LiveTrade")

    if not liveTrade then
        return nil
    end

    if liveTrade:IsA("GuiObject")
    and liveTrade.Visible ~= true then
        return nil
    end

    return liveTrade
end

function TransferRawLiveTradeVisible()

    return TransferGetLiveTradeFrame() ~= nil
end


function TransferActualTradeOpen()

    local liveTrade =
        TransferGetLiveTradeFrame()

    if liveTrade then

        if TransferState.TradeCompleted == true
        or TransferState.TradeResult == "Completed"
        or TransferGetLocalTradeState() == "Processing" then

            return false, "Completed LiveTrade still closing"
        end

        return true, "Visible LiveTrade"
    end

    local hasSides =
        TransferState.LocalTradeSide ~= nil
        and TransferState.OtherTradeSide ~= nil

    if hasSides == true then
        return true, "TradeSides"
    end

    local ownCount =
        tonumber(TransferState.TradeOwnItemCount)
        or 0

    local otherCount =
        tonumber(TransferState.TradeOtherItemCount)
        or 0

    if ownCount > 0
    or otherCount > 0 then
        return true, "OfferCounts"
    end

    return false, "No real trade UI/data yet"
end

function TransferGetTradeSideFrame(sideName)

    sideName =
        tostring(sideName or "")

    local liveTrade =
        TransferGetLiveTradeFrame()

    return liveTrade
        and liveTrade:FindFirstChild(sideName)
end

function TransferGuiGetSidePriceAmount(sideName)

    local sideFrame =
        TransferGetTradeSideFrame(sideName)

    local amountLabel =
        sideFrame
        and sideFrame:FindFirstChild("Price")
        and sideFrame.Price:FindFirstChild("Amount")

    if amountLabel
    and amountLabel:IsA("TextLabel")
    and TransferIsGuiObjectVisible(amountLabel) then

        return TransferToNumber(
            amountLabel.Text,
            0
        )
    end

    return 0
end

function TransferGuiCountVisibleSideItems(sideName)

    local sideFrame =
        TransferGetTradeSideFrame(sideName)

    local scrollingFrame =
        sideFrame
        and sideFrame:FindFirstChild("ScrollingFrame")

    if not scrollingFrame then
        return 0
    end

    local count =
        0

    for _, child in ipairs(scrollingFrame:GetChildren()) do

        if child:IsA("GuiObject")
        and child.Visible == true
        and TransferIsGuiObjectVisible(child) then

            local childName =
                tostring(child.Name or "")

            if childName ~= "AddItemButtom"
            and childName ~= "HoverDelTemplate"
            and childName ~= "Template" then

                local title =
                    child:FindFirstChild("Title", true)

                local titleText =
                    title
                    and title:IsA("TextLabel")
                    and CleanText(title.Text)
                    or ""

                if titleText ~= "" then
                    count =
                        count + 1
                end
            end
        end
    end

    return count
end

function TransferSideOfferReady(sideName, requiredCount, dataCount)

    requiredCount =
        math.max(
            1,
            math.floor(
                tonumber(requiredCount)
                or 1
            )
        )

    dataCount =
        tonumber(dataCount)
        or 0

    local guiItemCount =
        TransferGuiCountVisibleSideItems(sideName)

    local guiValue =
        TransferGuiGetSidePriceAmount(sideName)

    if dataCount >= requiredCount then
        return true, "data_count", dataCount
    end

    if guiItemCount >= requiredCount then
        return true, "gui_items", guiItemCount
    end

    if guiValue > 0 then
        return true, "gui_value", guiValue
    end

    return false,
        "waiting_"
            .. tostring(sideName)
            .. "_offer"
            .. " data="
            .. tostring(dataCount)
            .. " guiItems="
            .. tostring(guiItemCount)
            .. " guiValue="
            .. tostring(guiValue),
        0
end

function TransferOfferReadyForAccept(requiredOwnCount, requiredOtherCount)

    requiredOwnCount =
        tonumber(requiredOwnCount)
        or 0

    requiredOtherCount =
        tonumber(requiredOtherCount)
        or 0

    local ownCount =
        tonumber(TransferState.TradeOwnItemCount)
        or 0

    local otherCount =
        tonumber(TransferState.TradeOtherItemCount)
        or 0

    if TransferState.Mode == "Receiver" then

        return TransferSideOfferReady(
            "OtherPlr",
            math.max(1, requiredOtherCount),
            otherCount
        )
    end

    return TransferSideOfferReady(
        "MyPlr",
        math.max(1, requiredOwnCount),
        ownCount
    )
end

function TransferWaitForReceiverOfferReady(timeout)

    timeout =
        tonumber(timeout)
        or 120

    local started =
        os.clock()

    local lastStatusAt =
        0

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferState.TradeDeclined == true then
            return false
        end

        if TransferState.TradeCompleted == true
        or TransferState.TradeResult == "Completed"
        or TransferGetLocalTradeState() == "Processing" then
            return true
        end

        local ready, reason, metric =
            TransferSideOfferReady(
                "OtherPlr",
                1,
                TransferState.TradeOtherItemCount
            )

        if ready == true then

            print(
                "[TRANSFER] Receiver offer ready:",
                tostring(reason),
                "| metric:",
                tostring(metric),
                "| OtherItems:",
                tostring(TransferState.TradeOtherItemCount),
                "| OtherValue:",
                tostring(TransferGuiGetSidePriceAmount("OtherPlr")),
                "| OtherGuiItems:",
                tostring(TransferGuiCountVisibleSideItems("OtherPlr"))
            )

            return true
        end

        if os.clock() - started >= timeout then
            return false
        end

        if os.clock() - lastStatusAt >= 0.35 then

            lastStatusAt =
                os.clock()

            TransferUpdateTradeStatusText(
                "Waiting Sender",
                tostring(reason)
            )
        end

        task.wait(0.05)
    end

    return false
end

function TransferHasTrustedIncomingRequest()

    local trusted =
        CleanText(TransferState.TargetPlayerName)

    if trusted == "" then
        return false
    end

    if CleanText(TransferState.IncomingRequestId) == "" then
        return false
    end

    if TransferState.IncomingRequestPlayerName ~= trusted then
        return false
    end

    local requestAge =
        os.clock()
        - (
            tonumber(TransferState.IncomingRequestAt)
            or 0
        )

    return requestAge >= 0
        and requestAge <= 30
end


function TransferReceiverHasRecoverableLiveTrade()

    if TransferState.Mode ~= "Receiver" then
        return false
    end

    -- Incoming request has priority over stale LiveTrade recovery.
    -- Do not reattach if a fresh trusted request is waiting.
    if TransferHasTrustedIncomingRequest() == true then
        return false
    end

    if TransferState.TradeDeclined == true then
        return false
    end

    if TransferState.TradeCompleted == true
    or TransferState.TradeResult == "Completed" then
        return false
    end

    local liveTrade =
        TransferGetLiveTradeFrame()

    if not liveTrade then
        return false
    end

    if liveTrade:IsA("GuiObject")
    and liveTrade.Visible ~= true then
        return false
    end

    local buttonText =
        TransferGetTradeButtonText()

    local cooldown =
        TransferParseCooldownText(buttonText)

    local statusText =
        tostring(
            TransferGetTradeStatusText()
            or ""
        ):lower()

    local otherItems =
        TransferGuiCountVisibleSideItems("OtherPlr")

    local otherValue =
        TransferGuiGetSidePriceAmount("OtherPlr")

    local myReady =
        TransferReadyLabelIsAccepted("MyPlr")

    local otherReady =
        TransferReadyLabelIsAccepted("OtherPlr")

    local hasSenderOffer =
        otherItems > 0
        or otherValue > 0

    local hasAcceptedOrConfirmStatus =
        statusText:find("has accepted", 1, true) ~= nil
        or statusText:find("has confirmed", 1, true) ~= nil
        or statusText:find("confirm", 1, true) ~= nil

    -- This is the stale state from your screenshot:
    -- button countdown + "Waiting for both players to accept" + no items/value/ready labels.
    -- Never recover/reattach to this.
    if cooldown ~= nil
    and hasSenderOffer ~= true
    and myReady ~= true
    and otherReady ~= true
    and hasAcceptedOrConfirmStatus ~= true then

        print(
            "[TRANSFER RECOVERY]",
            "Rejected stale empty LiveTrade.",
            "| button:",
            tostring(buttonText),
            "| status:",
            tostring(TransferGetTradeStatusText()),
            "| myReady:",
            tostring(TransferGetReadyLabelText("MyPlr")),
            "| otherReady:",
            tostring(TransferGetReadyLabelText("OtherPlr")),
            "| otherItems:",
            tostring(otherItems),
            "| otherValue:",
            tostring(otherValue)
        )

        return false
    end

    if buttonText == "Confirm"
    or buttonText == "Confirmed" then
        return true
    end

    if hasSenderOffer == true then
        return true
    end

    if otherReady == true then
        return true
    end

    if hasAcceptedOrConfirmStatus == true then
        return true
    end

    return false
end

function TransferReattachReceiverLiveTrade(reason)

    TransferState.TradeOpen =
        true

    TransferState.TradeCompleted =
        false

    TransferState.TradeResult =
        ""

    TransferState.TradeDeclined =
        false

    TransferState.TradeDeclineReason =
        ""

    TransferState.RequestBlocked =
        false

    TransferState.RequestBlockedReason =
        ""

    TransferState.IncomingRequestId =
        ""

    TransferState.IncomingRequestPlayerName =
        ""

    TransferState.IncomingRequestAt =
        0

    TransferState.TradeOtherItemCount =
        math.max(
            tonumber(TransferState.TradeOtherItemCount) or 0,
            TransferGuiCountVisibleSideItems("OtherPlr")
        )

    TransferState.TradeOwnItemCount =
        math.max(
            tonumber(TransferState.TradeOwnItemCount) or 0,
            TransferGuiCountVisibleSideItems("MyPlr")
        )

    TransferState.LastTradeUpdate =
        os.clock()

    TransferSetStatus(
        "Reattached",
        tostring(reason or "Recovered active LiveTrade.")
            .. " | Button="
            .. tostring(TransferGetTradeButtonText())
            .. " | OtherItems="
            .. tostring(TransferState.TradeOtherItemCount)
            .. " | OtherValue="
            .. tostring(TransferGuiGetSidePriceAmount("OtherPlr"))
    )

    print(
        "[TRANSFER RECOVERY]",
        "Receiver reattached to active LiveTrade.",
        "| reason:",
        tostring(reason),
        "| button:",
        tostring(TransferGetTradeButtonText()),
        "| status:",
        tostring(TransferGetTradeStatusText()),
        "| myReady:",
        tostring(TransferGetReadyLabelText("MyPlr")),
        "| otherReady:",
        tostring(TransferGetReadyLabelText("OtherPlr")),
        "| otherItems:",
        tostring(TransferGuiCountVisibleSideItems("OtherPlr")),
        "| otherValue:",
        tostring(TransferGuiGetSidePriceAmount("OtherPlr"))
    )

    return true
end

TransferParseCooldownText = function(text)

    text =
        tostring(text or "")
            :gsub("^%s+", "")
            :gsub("%s+$", "")
            :lower()

    local numberText =
        text:match("^(%d+%.?%d*)s$")

    if not numberText then
        return nil
    end

    local seconds =
        tonumber(numberText)

    if not seconds then
        return nil
    end

    -- Trade add-item cooldown is around 5 seconds.
    -- Ignore unrelated long timers.
    if seconds < 0
    or seconds > 6.5 then
        return nil
    end

    return seconds
end

function TransferCanUseTradeValueForAccept()

    if TransferState.TradeOpen ~= true then
        return false
    end

    if TransferState.TradeDeclined == true then
        return false
    end

    if TransferState.TradeCompleted == true
    or TransferState.TradeResult == "Completed" then
        return false
    end

    local buttonText =
        TransferGetTradeButtonText()

    if buttonText == "" then
        return false
    end

    if buttonText == "Confirm"
    or buttonText == "Confirmed" then
        return true
    end

    if buttonText == "Accept"
    or TransferParseCooldownText(buttonText) ~= nil then
        return true
    end

    return false
end

function TransferStartFastAcceptPump(label, requiredOwnCount, requiredOtherCount, maxDuration)

    label =
        tostring(label or "Value Accept")

    maxDuration =
        tonumber(maxDuration)
        or 12

    task.spawn(function()

        local started =
            os.clock()

        local connections = {}

        local stopped =
            false

        local valueDetected =
            false

        local lastFireAt =
            0

        local nextCooldownPulseAt =
            0

        local lastStatusAt =
            0

        local function ShouldStop()

            if stopped == true then
                return true
            end

            if not IsHolyLiteCurrentRun()
            or TransferState.TransferEnabled ~= true then
                return true
            end

            if TransferState.TradeDeclined == true then
                return true
            end

            if TransferState.TradeCompleted == true
            or TransferState.TradeResult == "Completed" then

                TransferTimingMark("CompletedAt")
                return true
            end

            if TransferGetTradeButtonText() == "Confirm" then

                TransferTimingMark("ConfirmSeenAt")
                return true
            end

            if os.clock() - started >= maxDuration then
                return true
            end

            return false
        end

        local function Cleanup(reason)

            if stopped == true then
                return
            end

            stopped =
                true

            for _, connection in ipairs(connections) do

                pcall(function()
                    connection:Disconnect()
                end)
            end

            table.clear(connections)

            TransferTimingReport(
                reason or label
            )
        end

        local function FireAcceptBurst(reason, value, count)

            if ShouldStop() then
                Cleanup(reason)
                return
            end

            if TransferAcceptLikelyLockedFromButtonPhase() == true then

                TransferTimingMark("AcceptLockedAt")
                Cleanup("accept locked")
                return
            end

            count =
                math.clamp(
                    math.floor(tonumber(count) or 1),
                    1,
                    8
                )

            local now =
                os.clock()

            if now - lastFireAt < 0.006 then
                return
            end

            lastFireAt =
                now

            if TransferState.Timing.FirstAcceptAt == nil then
                TransferTimingMark("FirstAcceptAt")
            end

            local buttonText =
                TransferGetTradeButtonText()

            if TransferState.Timing.FirstButton == "" then
                TransferTimingSet("FirstButton", buttonText)
            end

            TransferTimingSet("LastButton", buttonText)
            TransferTimingSet("LastValue", value or 0)

            for _ = 1, count do

                if ShouldStop()
                or TransferAcceptLikelyLockedFromButtonPhase() == true then
                    break
                end

                TransferFireTradeRemote("Accept")

                TransferTimingBumpAttempts(1)

                task.wait()
            end

            TransferDebugPrint(
                "[TRANSFER DEBUG] Accept burst:",
                tostring(label),
                "| reason:",
                tostring(reason),
                "| count:",
                tostring(count),
                "| value:",
                tostring(value),
                "| button:",
                tostring(buttonText)
            )
        end

        local function OnValueSeen(reason, value)

            if ShouldStop() then
                Cleanup(reason)
                return
            end

            value =
                tonumber(value)
                or 0

            if value <= 0 then
                return
            end

            if TransferCanUseTradeValueForAccept() ~= true then
                return
            end

            if valueDetected ~= true then

                valueDetected =
                    true

                TransferTimingMark("ValueSeenAt")
                TransferTimingSet("LastValue", value)

                TransferSetStatus(
                    "Value Detected",
                    tostring(label)
                        .. " value "
                        .. tostring(value)
                )

                -- First instant fire as soon as value appears.
                FireAcceptBurst(
                    reason .. "_first_value",
                    value,
                    2
                )
            end
        end

        local function CheckTextObject(obj, reason)

            if ShouldStop() then
                Cleanup(reason)
                return
            end

            if not obj
            or not obj.Parent then
                return
            end

            if not TransferIsGuiObjectVisible(obj) then
                return
            end

            local value =
                TransferExtractPositiveTradeValueFromText(obj.Text)

            if value then
                OnValueSeen(reason, value)
            end
        end

        local function AttachTextObject(obj)

            if not obj
            or not obj.Parent then
                return
            end

            if not (
                obj:IsA("TextLabel")
                or obj:IsA("TextButton")
                or obj:IsA("TextBox")
            ) then
                return
            end

            CheckTextObject(
                obj,
                "initial"
            )

            local ok, connection =
                pcall(function()

                    return obj:GetPropertyChangedSignal("Text"):Connect(function()

                        CheckTextObject(
                            obj,
                            "text_changed"
                        )
                    end)
                end)

            if ok == true
            and connection then

                table.insert(
                    connections,
                    connection
                )
            end
        end

        local playerGui =
            LocalPlayer:FindFirstChild("PlayerGui")

        local tradingUI =
            playerGui
            and playerGui:FindFirstChild("TradingUI")

        if tradingUI then

            for _, obj in ipairs(tradingUI:GetDescendants()) do
                AttachTextObject(obj)
            end

            local okDesc, descConnection =
                pcall(function()

                    return tradingUI.DescendantAdded:Connect(function(obj)

                        task.defer(function()
                            AttachTextObject(obj)
                        end)
                    end)
                end)

            if okDesc == true
            and descConnection then

                table.insert(
                    connections,
                    descConnection
                )
            end
        end

        while ShouldStop() ~= true do

            local hasValue, value =
                TransferGuiHasPositiveTradeValue()

            if hasValue == true
            and TransferCanUseTradeValueForAccept() == true then
                OnValueSeen("frame_scan", value)
            end

            local ownCount =
                tonumber(TransferState.TradeOwnItemCount)
                or 0

            local otherCount =
                tonumber(TransferState.TradeOtherItemCount)
                or 0

            local offerReady, offerReason, offerMetric =
                TransferOfferReadyForAccept(
                    requiredOwnCount,
                    requiredOtherCount
                )

            local countReady =
                offerReady == true

            if valueDetected == true
            or offerReady == true then

                local buttonText =
                    TransferGetTradeButtonText()

                local seconds =
                    TransferParseCooldownText(buttonText)

                TransferTimingSet("LastButton", buttonText)

                if TransferAcceptLikelyLockedFromButtonPhase() == true then

                    TransferTimingMark("AcceptLockedAt")
                    Cleanup("accept locked")
                    return

                elseif buttonText == "Accept"
                or buttonText == "" then

                    -- No visible cooldown. Burst hard.
                    FireAcceptBurst(
                        countReady == true
                            and "count_ready"
                            or "button_ready",
                        value or ownCount,
                        4
                    )

                elseif seconds ~= nil then

                    if seconds <= 0.25 then

                        -- Only fire at the real useful server-ready window.
                        FireAcceptBurst(
                            countReady == true
                                and "count_ready_cooldown_final"
                                or "cooldown_final",
                            value or ownCount,
                            8
                        )

                    elseif os.clock() - lastStatusAt >= 0.35 then

                        TransferSetStatus(
                            "Accept Cooldown",
                            "Value="
                                .. tostring(value)
                                .. " | Ready in "
                                .. string.format("%.1f", seconds)
                                .. "s"
                        )
                    end
                end

                if os.clock() - lastStatusAt >= 0.35 then

                    lastStatusAt =
                        os.clock()

                    TransferSetStatus(
                        "Fast Accept",
                        "Reason="
                            .. tostring(offerReason)
                            .. " | Metric="
                            .. tostring(offerMetric or value)
                            .. " | Button="
                            .. tostring(buttonText)
                    )
                end
            end

            task.wait()
        end

        Cleanup("pump ended")
    end)
end

function TransferAcceptAndWait(label, timeout, requiredOwnCount, requiredOtherCount)

    label =
        tostring(label or "Accepting")

    timeout =
        tonumber(timeout)
        or 14

    requiredOwnCount =
        tonumber(requiredOwnCount)
        or 0

    requiredOtherCount =
        tonumber(requiredOtherCount)
        or 0

    local started =
        os.clock()

    local lastFireAt =
        0

    local nextCooldownPulseAt =
        0

    local lastStatusAt =
        0

    local function FireAcceptBurst(reason, value, count)

        if TransferAcceptLikelyLockedFromButtonPhase() == true then
            TransferTimingMark("AcceptLockedAt")
            return true
        end

        count =
            math.clamp(
                math.floor(tonumber(count) or 1),
                1,
                8
            )

        if os.clock() - lastFireAt < 0.006 then
            return false
        end

        lastFireAt =
            os.clock()

        if TransferState.Timing.FirstAcceptAt == nil then
            TransferTimingMark("FirstAcceptAt")
        end

        for _ = 1, count do

            if TransferAcceptLikelyLockedFromButtonPhase() == true then
                TransferTimingMark("AcceptLockedAt")
                return true
            end

            TransferFireTradeRemote("Accept")

            TransferTimingBumpAttempts(1)

            task.wait()
        end

        TransferDebugPrint(
            "[TRANSFER DEBUG] Fallback accept burst:",
            tostring(label),
            "| reason:",
            tostring(reason),
            "| count:",
            tostring(count),
            "| value:",
            tostring(value),
            "| button:",
            tostring(TransferGetTradeButtonText())
        )

        return TransferAcceptLikelyLockedFromButtonPhase()
    end

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferState.TradeDeclined == true then
            TransferTimingReport("declined during accept")
            return false
        end

        if TransferAcceptLikelyLockedFromButtonPhase() then
            TransferTimingMark("AcceptLockedAt")
            return true
        end

        if os.clock() - started >= timeout then
            TransferTimingReport("accept timeout")
            return false
        end

        local hasValue, value =
            TransferGuiHasPositiveTradeValue()

        local buttonText =
            TransferGetTradeButtonText()

        local seconds =
            TransferParseCooldownText(buttonText)

        local ownCount =
            tonumber(TransferState.TradeOwnItemCount)
            or 0

        local otherCount =
            tonumber(TransferState.TradeOtherItemCount)
            or 0

        local offerReady, offerReason, offerMetric =
            TransferOfferReadyForAccept(
                requiredOwnCount,
                requiredOtherCount
            )

        local countReady =
            offerReady == true

        local senderAcceptedReady =
            false

        if TransferState.Mode == "Receiver" then

            senderAcceptedReady =
                TransferSenderReadyForReceiverAccept() == true
                and offerReady == true
        end

        local ready =
            offerReady == true
            or senderAcceptedReady == true

        TransferTimingSet("LastButton", buttonText)

        if ready == true then

            if hasValue == true
            and TransferState.Timing.ValueSeenAt == nil then
                TransferTimingMark("ValueSeenAt")
            end

            TransferTimingSet("LastValue", value or 0)

            local acceptReason =
                senderAcceptedReady == true
                and "sender_accepted_ready"
                or tostring(offerReason or "offer_ready")

            if buttonText == "Accept"
            or buttonText == "" then

                print(
                    "[TRANSFER] Receiver/Sender Accept Attempt:",
                    tostring(acceptReason),
                    "| hasValue:",
                    tostring(hasValue),
                    "| value:",
                    tostring(value),
                    "| countReady:",
                    tostring(countReady),
                    "| senderAcceptedReady:",
                    tostring(senderAcceptedReady),
                    "| Own:",
                    tostring(ownCount),
                    "/",
                    tostring(requiredOwnCount),
                    "| Other:",
                    tostring(otherCount),
                    "/",
                    tostring(requiredOtherCount),
                    "| Button:",
                    tostring(buttonText),
                    "| Local:",
                    TransferGetLocalTradeState(),
                    "| OtherState:",
                    TransferGetOtherTradeState()
                )

                if FireAcceptBurst(
                    "fallback_" .. tostring(acceptReason),
                    offerMetric or value,
                    8
                ) then
                    return true
                end

            elseif seconds ~= nil then

                if seconds <= 0.25 then

                    print(
                        "[TRANSFER] Receiver/Sender Accept Attempt:",
                        tostring(acceptReason),
                        "| hasValue:",
                        tostring(hasValue),
                        "| value:",
                        tostring(value),
                        "| countReady:",
                        tostring(countReady),
                        "| senderAcceptedReady:",
                        tostring(senderAcceptedReady),
                        "| Own:",
                        tostring(ownCount),
                        "/",
                        tostring(requiredOwnCount),
                        "| Other:",
                        tostring(otherCount),
                        "/",
                        tostring(requiredOtherCount),
                        "| Button:",
                        tostring(buttonText),
                        "| Local:",
                        TransferGetLocalTradeState(),
                        "| OtherState:",
                        TransferGetOtherTradeState()
                    )

                    if FireAcceptBurst(
                        "fallback_cooldown_" .. tostring(acceptReason),
                        offerMetric or value,
                        8
                    ) then
                        return true
                    end

                elseif os.clock() >= nextCooldownPulseAt then

                    nextCooldownPulseAt =
                        os.clock() + 0.35

                    TransferUpdateTradeStatusText(
                        label,
                        "Accept cooldown "
                            .. string.format("%.1f", seconds)
                            .. "s | "
                            .. tostring(acceptReason)
                    )
                end

            else

                if FireAcceptBurst(
                    "fallback_unknown_" .. tostring(acceptReason),
                    offerMetric or value,
                    2
                ) then
                    return true
                end
            end

            if os.clock() - lastStatusAt >= 0.35 then

                lastStatusAt =
                    os.clock()

                TransferUpdateTradeStatusText(
                    label,
                    "Fast accept | Reason="
                        .. tostring(acceptReason)
                        .. " | Metric="
                        .. tostring(offerMetric or value)
                        .. " | Button="
                        .. tostring(buttonText)
                )
            end

        else

            if os.clock() - lastStatusAt >= 0.45 then

                lastStatusAt =
                    os.clock()

                TransferUpdateTradeStatusText(
                    label,
                    "Waiting accept trigger. Button="
                        .. tostring(buttonText)
                        .. " | OtherState="
                        .. tostring(TransferGetOtherTradeState())
                        .. " | OtherItems="
                        .. tostring(otherCount)
                )
            end
        end

        task.wait()
    end

    TransferTimingReport("accept stopped")

    return false
end

function TransferConfirmAndWait(label, timeout)

    label =
        tostring(label or "Confirming")

    timeout =
        tonumber(timeout)
        or 30

    local started =
        os.clock()

    local attempts =
        0

    local nextRetryAt =
        0

    local bothConfirmedSince =
        nil

    while IsHolyLiteCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferState.TradeDeclined == true
        or TransferMarkClosedIfLiveTradeGone("Trade UI closed while confirming.") == true then
            return false
        end

        if TransferState.TradeCompleted == true
        or TransferState.TradeResult == "Completed"
        or TransferGetLocalTradeState() == "Processing" then

            TransferTimingMark("CompletedAt")
            TransferTimingReport("completed")

            return true
        end

        if os.clock() - started >= timeout then
            return false
        end

        local buttonText =
            TransferGetTradeButtonText()

        local confirmWindowReady =
            TransferConfirmWindowReady()

        local otherFinalConfirmed =
            TransferOtherFinalConfirmedLike()

        local localAccepted =
            TransferLocalAcceptLocked()

        local localFinalConfirmed =
            buttonText == "Confirmed"
            or TransferReadyLabelIsConfirmed("MyPlr") == true
            or TransferGetLocalTradeState() == "Confirmed"

        local bothGuiConfirmed =
            localFinalConfirmed == true
            and otherFinalConfirmed == true

        if confirmWindowReady == true
        or otherFinalConfirmed == true
        or bothGuiConfirmed == true then

            TransferTimingMark(
                "ConfirmSeenAt"
            )
        end

        if bothGuiConfirmed == true then

            if bothConfirmedSince == nil then
                bothConfirmedSince =
                    os.clock()
            end

            TransferUpdateTradeStatusText(
                label,
                "Both sides confirmed. Waiting server completion."
            )

            -- If both visible sides are confirmed but the server is slow to close UI,
            -- treat it as completed after a short settle window.
            if os.clock() - bothConfirmedSince >= 0.65 then

                TransferMarkTradeCompleted(
                    "Both visible trade sides confirmed."
                )

                TransferTimingMark("CompletedAt")
                TransferTimingReport("both confirmed")

                return true
            end

            task.wait(0.05)

        elseif buttonText == "Confirmed" then

            TransferUpdateTradeStatusText(
                label,
                "Local confirmed. Waiting other final confirm."
            )

            task.wait(0.08)

        elseif (
            buttonText == "Confirm"
            or confirmWindowReady == true
            or (
                otherFinalConfirmed == true
                and localAccepted == true
            )
        )
        and (
            attempts == 0
            or os.clock() >= nextRetryAt
        ) then

            attempts =
                attempts + 1

            nextRetryAt =
                os.clock() + 0.10

            TransferUpdateTradeStatusText(
                label,
                "Final confirm attempt "
                    .. tostring(attempts)
            )

            local ok, msg =
                TransferFireTradeRemote("Confirm")

            print(
                "[TRANSFER] Auto Confirm Attempt:",
                tostring(attempts),
                tostring(ok),
                tostring(msg),
                "| Button:",
                tostring(buttonText),
                "| Local:",
                tostring(TransferGetLocalTradeState()),
                "| Other:",
                tostring(TransferGetOtherTradeState()),
                "| MyReady:",
                tostring(TransferGetReadyLabelText("MyPlr")),
                "| OtherReady:",
                tostring(TransferGetReadyLabelText("OtherPlr")),
                "| Status:",
                tostring(TransferGetTradeStatusText())
            )

            task.wait(0.04)

        else

            TransferUpdateTradeStatusText(
                label,
                "Waiting final confirm result. Button="
                    .. tostring(buttonText)
                    .. " | OtherFinal="
                    .. tostring(otherFinalConfirmed)
                    .. " | MyReady="
                    .. tostring(TransferGetReadyLabelText("MyPlr"))
                    .. " | OtherReady="
                    .. tostring(TransferGetReadyLabelText("OtherPlr"))
            )

            task.wait(0.08)
        end
    end

    return false
end

function TransferSendFilteredPets()

    local matches =
        TransferBuildMatches()

    local limit =
        TransferGetMaxPetsPerTrade()

    local sendCount =
        math.min(
            #matches,
            limit
        )

    if sendCount <= 0 then

        TransferSetStatus(
            "No Matches",
            "No pets matched your current filters."
        )

        return false, 0
    end

    TransferState.IsAddingPets =
        true

    TransferState.AddedThisBatch =
        0

    TransferSetStatus(
        "Sending Pets",
        "Adding "
            .. tostring(sendCount)
            .. "/"
            .. tostring(#matches)
            .. " matching pets.",
        true
    )

    local added = 0
    local failed = 0
    local lastError = ""

    local burstCount =
        TransferGetAddBurstCount()

    if burstCount <= 1 then

        for index, pet in ipairs(matches) do

            if not IsHolyLiteCurrentRun()
            or TransferState.TransferEnabled ~= true then

                TransferState.IsAddingPets =
                    false

                return false, added
            end

            if index > sendCount then
                break
            end

            TransferSetStatus(
                "Sending Pets",
                "Adding "
                    .. tostring(index)
                    .. "/"
                    .. tostring(sendCount)
                    .. ": "
                    .. tostring(pet.PetName)
                    .. " "
                    .. tostring(TransferFormatNumber(pet.DisplayWeight))
                    .. " KG"
            )

            local beforeCount =
                tonumber(TransferState.TradeOwnItemCount)
                or 0

            local confirmed, msg =
                TransferTryAddPetToTrade(pet)

            if confirmed == true then

                added =
                    added + 1

                TransferState.AddedThisBatch =
                    added

                print(
                    "[TRANSFER] AddItem confirmed:",
                    tostring(added)
                        .. "/"
                        .. tostring(sendCount),
                    tostring(pet.PetName),
                    tostring(pet.UUID),
                    "BaseWeight:",
                    tostring(pet.BaseWeight),
                    "KG:",
                    tostring(pet.DisplayWeight),
                    "| OfferCount:",
                    tostring(TransferState.TradeOwnItemCount),
                    "|",
                    tostring(msg)
                )

            else

                failed =
                    failed + 1

                lastError =
                    tostring(msg)

                warn(
                    "[TRANSFER] AddItem rejected/unconfirmed:",
                    tostring(index)
                        .. "/"
                        .. tostring(sendCount),
                    tostring(pet.PetName),
                    tostring(pet.UUID),
                    tostring(lastError),
                    "| Before:",
                    tostring(beforeCount),
                    "| Current:",
                    tostring(TransferState.TradeOwnItemCount)
                )

                TransferSetStatus(
                    "Add Failed",
                    tostring(pet.PetName)
                        .. " was not accepted by trade."
                )

                break
            end

            TransferState.Sent =
                TransferState.Sent + (confirmed and 1 or 0)

            if index < sendCount then

                local addDelay =
                    TransferGetAddPetDelay()

                TransferSetStatus(
                    "Adding Next",
                    tostring(added)
                        .. " added | next pet in "
                        .. string.format("%.2f", addDelay)
                        .. "s"
                )

                task.wait(addDelay)
            end
        end

    else

        local index =
            1

        local stuckRounds =
            0

        while index <= sendCount do

            if not IsHolyLiteCurrentRun()
            or TransferState.TransferEnabled ~= true then

                TransferState.IsAddingPets =
                    false

                return false, added
            end

            local burstEnd =
                math.min(
                    index + burstCount - 1,
                    sendCount
                )

            local beforeCount =
                tonumber(TransferState.TradeOwnItemCount)
                or 0

            local firedCount =
                0

            TransferSetStatus(
                "Burst Adding",
                "Firing "
                    .. tostring(index)
                    .. "-"
                    .. tostring(burstEnd)
                    .. "/"
                    .. tostring(sendCount)
                    .. " all at once"
            )

            for burstIndex = index, burstEnd do

                local pet =
                    matches[burstIndex]

                local fired, msg =
                    TransferFirePetAddNoWait(pet)

                if fired == true then

                    firedCount =
                        firedCount + 1

                    TransferDebugPrint(
                        "[TRANSFER DEBUG] Burst AddItem fired:",
                        tostring(burstIndex)
                            .. "/"
                            .. tostring(sendCount),
                        tostring(pet.PetName),
                        tostring(pet.UUID),
                        "|",
                        tostring(msg)
                    )

                else

                    failed =
                        failed + 1

                    lastError =
                        tostring(msg)

                    warn(
                        "[TRANSFER] Burst AddItem failed to fire:",
                        tostring(burstIndex)
                            .. "/"
                            .. tostring(sendCount),
                        tostring(pet and pet.PetName),
                        tostring(lastError)
                    )
                end
            end

            if firedCount <= 0 then

                stuckRounds =
                    stuckRounds + 1

                if stuckRounds >= 3 then
                    break
                end

                task.wait(0.25)

                continue
            end

            local expectedCount =
                beforeCount + firedCount

            local afterCount =
                TransferWaitForOwnOfferCountAtLeastOrSettled(
                    beforeCount,
                    expectedCount,
                    math.max(
                        1.5,
                        0.45 + firedCount * 0.18
                    ),
                    0.28
                )

            local gained =
                math.clamp(
                    afterCount - beforeCount,
                    0,
                    firedCount
                )

            if gained > 0 then

                added =
                    added + gained

                TransferState.Sent =
                    TransferState.Sent + gained

                TransferState.AddedThisBatch =
                    added

                stuckRounds =
                    0

                TransferDebugPrint(
                    "[TRANSFER DEBUG] Burst accepted:",
                    tostring(gained)
                        .. "/"
                        .. tostring(firedCount),
                    "| Added:",
                    tostring(added)
                        .. "/"
                        .. tostring(sendCount),
                    "| OfferCount:",
                    tostring(TransferState.TradeOwnItemCount)
                )

                index =
                    index + gained

            else

                stuckRounds =
                    stuckRounds + 1

                lastError =
                    "Burst fired but offer count did not increase."

                warn(
                    "[TRANSFER] Burst stalled:",
                    tostring(lastError),
                    "| Before:",
                    tostring(beforeCount),
                    "| After:",
                    tostring(afterCount),
                    "| Fired:",
                    tostring(firedCount)
                )

                if stuckRounds >= 3 then
                    break
                end

                task.wait(0.25)
            end

            if index <= sendCount then

                local addDelay =
                    TransferGetAddPetDelay()

                TransferSetStatus(
                    "Adding Next",
                    tostring(added)
                        .. " added | next instant burst in "
                        .. string.format("%.2f", addDelay)
                        .. "s"
                )

                task.wait(addDelay)
            end
        end
    end

    TransferState.IsAddingPets =
        false

    TransferSetStatus(
        "Pets Added",
        tostring(added)
            .. "/"
            .. tostring(sendCount)
            .. " added"
            .. (
                failed > 0
                and (", " .. tostring(failed) .. " failed")
                or ""
            )
            .. (
                lastError ~= ""
                and (" | " .. lastError)
                or ""
            ),
        true
    )

    return added > 0, added
end

function TransferRunSenderBatch()

    TransferResetTradeRuntime()

    TransferTimingReset("Sender Batch")

    local matches =
        TransferBuildMatches()

    if #matches <= 0 then

        TransferSetStatus(
            "Done",
            "No matching pets left."
        )

        return false, "No matches"
    end

    TransferSetStatus(
        "Preparing",
        "Preparing "
            .. tostring(math.min(#matches, TransferGetMaxPetsPerTrade()))
            .. " pets."
    )

    local unfavoriteOk, unfavoriteMsg =
        TransferUnfavoriteMatchingPetsBeforeTrade(matches)

    if unfavoriteOk ~= true then

        TransferSetStatus(
            "Unfavorite Failed",
            tostring(unfavoriteMsg)
        )

        return false, tostring(unfavoriteMsg)
    end

    TransferRefreshDropdowns()

    matches =
        TransferBuildMatches()

    if #matches <= 0 then

        TransferSetStatus(
            "Done",
            "No matching pets after refresh."
        )

        return false, "No matches"
    end

    -- Optional user delay before sending the next trade request.
    -- Batch 1 sends immediately; later batches/retries respect this delay.
    if tonumber(TransferState.Batch) > 1 then
        TransferWaitBeforeNextTicket()
    end

    local ticketOk =
        TransferSendTicket()

    if not ticketOk then
        return false, "Ticket failed"
    end

    TransferStartFastAcceptPump(
        "Sender PreOpen",
        0,
        0,
        30
    )
    -- Do not count a batch until the trade actually opens.
    local tradeOpen =
        TransferWaitForTradeOpen(25)

    if tradeOpen ~= true then

        if TransferState.TradeDeclined == true then
            return false, "Trade declined"
        end

        if TransferState.RequestBlocked == true then
            return false, "Request blocked"
        end

        TransferSetStatus(
            "Trade Timeout",
            "Target did not accept/open trade in time."
        )

        return false, "Trade timeout"
    end

    local openedButtonText =
        TransferGetTradeButtonText()

    if openedButtonText == "Confirm"
    or openedButtonText == "Confirmed"
    or TransferConfirmWindowReady() == true then

        TransferUpdateTradeStatusText(
            "Recover Confirm",
            "Trade opened already in confirm phase. Confirming before adding pets."
        )

        TransferTryInstantFinalConfirm(
            "Sender opened already-confirm-stage trade."
        )

        local recoveredCompleted =
            TransferConfirmAndWait(
                "Recover Confirm",
                12
            )

        if recoveredCompleted == true then

            TransferWaitForLiveTradeClosed(5)

            return true, "Recovered pending confirm"
        end

        return false, "Complete timeout"
    end

    TransferState.Batch =
        TransferState.Batch + 1

    TransferUpdateTradeStatusText(
        "Trade Open",
        "Batch "
            .. tostring(TransferState.Batch)
            .. " opened. Adding pets + pre-accepting."
    )

    -- Sender PreOpen pump is already watching the value label.

    local sentPets, added =
        TransferSendFilteredPets()

    if sentPets ~= true
    or added <= 0 then
        return false, "No pets added"
    end

    TransferUpdateTradeStatusText(
        "Accepting",
        "Pets added. Instant accepting trade."
    )

    TransferStartFastAcceptPump(
        "Sender Added",
        added,
        0,
        14
    )

    local acceptOk =
        TransferAcceptAndWait(
            "Accepting",
            14,
            added,
            0
        )

    if acceptOk ~= true then

        TransferSetStatus(
            "Accept Failed",
            "Accept did not lock in."
        )

        return false, "Accept failed"
    end

    TransferUpdateTradeStatusText(
        "Waiting Receiver",
        "Waiting receiver to accept."
    )

    local receiverAccepted =
        TransferWaitForReceiverAccepted(45)

    if receiverAccepted ~= true then

        if TransferState.TradeDeclined == true then
            return false, "Trade declined"
        end

        TransferSetStatus(
            "Receiver Timeout",
            "Receiver did not accept."
        )

        return false, "Receiver accept timeout"
    end

    TransferUpdateTradeStatusText(
        "Waiting Confirm",
        "Waiting final confirm button."
    )

    local confirmReady =
        TransferWaitForConfirmReady(45)

    if confirmReady ~= true then

        if TransferState.TradeDeclined == true then
            return false, "Trade declined"
        end

        TransferSetStatus(
            "Confirm Timeout",
            "Final confirm button was not ready."
        )

        return false, "Confirm timeout"
    end

    TransferUpdateTradeStatusText(
        "Confirming",
        "Final confirm."
    )

    local completed =
        TransferConfirmAndWait(
            "Confirming",
            30
        )

    if completed ~= true then

        if TransferState.TradeDeclined == true then
            return false, "Trade declined"
        end

        TransferSetStatus(
            "Complete Timeout",
            "Trade did not complete in time."
        )

        return false, "Complete timeout"
    end

    TransferSetStatus(
        "Trade Done",
        "Batch "
            .. tostring(TransferState.Batch)
            .. " sent "
            .. tostring(added)
            .. " pets."
    )

    return true, "Batch completed"
end

function TransferRunReceiverBatch()

    local recoveredLiveTrade =
        false

    if TransferHasTrustedIncomingRequest() ~= true then

        recoveredLiveTrade =
            TransferReceiverHasRecoverableLiveTrade()
    end

    if recoveredLiveTrade == true then

        TransferReattachReceiverLiveTrade(
            "Receiver worker found already-open trade."
        )

        TransferTimingReset("Receiver Reattach")

    else

        TransferResetTradeRuntime()

        TransferTimingReset("Receiver Batch")

        local requestOk =
            TransferWaitForTrustedIncomingRequest(90)

        if requestOk ~= true then
            return false, "No trusted request"
        end

        if TransferRawLiveTradeVisible() == true
        and (
            TransferState.TradeCompleted == true
            or TransferState.TradeResult == "Completed"
            or TransferGetLocalTradeState() == "Processing"
        ) then

            TransferSetStatus(
                "Waiting Close",
                "Incoming request found, but old completed trade UI is still closing."
            )

            TransferWaitForLiveTradeClosed(8)

            if TransferRawLiveTradeVisible() ~= true then
                TransferResetTradeRuntime()
            end
        end

        TransferSetStatus(
            "Ticket Found",
            "Incoming from "
                .. tostring(TransferState.IncomingRequestPlayerName)
        )

        if TransferState.AutoAcceptTicket == true then

            TransferSetStatus(
                "Accepting Ticket",
                "Accepting "
                    .. tostring(TransferState.IncomingRequestPlayerName)
            )

            local acceptRequestOk =
                TransferAcceptIncomingRequest()

            if acceptRequestOk ~= true then
                return false, "Request accept failed"
            end

        else

            TransferSetStatus(
                "Manual Ticket",
                "Waiting for you to accept the ticket."
            )
        end

        TransferStartFastAcceptPump(
            "Receiver PreOpen",
            0,
            0,
            120
        )

        local tradeOpen =
            TransferWaitForTradeOpen(
                TransferState.AutoAcceptTicket == true
                    and 25
                    or 90
            )

        if tradeOpen ~= true then

            if TransferState.TradeDeclined == true then
                return false, "Trade declined"
            end

            return false, "Trade did not open"
        end
    end

    TransferUpdateTradeStatusText(
        "Waiting Sender",
        "Waiting sender OtherPlr items/value."
    )

    local offerReady =
        TransferWaitForReceiverOfferReady(120)

    if offerReady ~= true then

        if TransferState.TradeDeclined == true then
            return false, "Trade declined"
        end

        TransferSetStatus(
            "Offer Timeout",
            "Sender offer never appeared on OtherPlr."
        )

        return false, "No sender items"
    end

    print(
        "[TRANSFER] Sender value/items detected:",
        "| OtherState:",
        tostring(TransferGetOtherTradeState()),
        "| OtherItems:",
        tostring(TransferState.TradeOtherItemCount),
        "| Button:",
        tostring(TransferGetTradeButtonText())
    )

    if TransferState.AutoConfirm == true then

        TransferUpdateTradeStatusText(
            "Accepting",
            "Sender items detected. Receiver accepting trade."
        )

        TransferStartFastAcceptPump(
            "Receiver Items Ready",
            0,
            1,
            20
        )

        local acceptOk =
            TransferAcceptAndWait(
                "Accepting",
                20,
                0,
                1
            )

        if acceptOk ~= true then
            return false, "Accept failed"
        end

    else

        TransferUpdateTradeStatusText(
            "Manual Accept",
            "Waiting for you to press Accept."
        )
    end

    if TransferState.AutoConfirm == true then

        TransferTryInstantFinalConfirm(
            "Receiver pre-check before confirm wait."
        )
    end

    local confirmReady =
        TransferWaitForConfirmReady(45)

    if confirmReady ~= true then

        if TransferState.TradeDeclined == true then
            return false, "Trade declined"
        end

        return false, "Confirm not ready"
    end

    if TransferState.AutoConfirm == true then

        TransferUpdateTradeStatusText(
            "Confirming",
            "Final confirm."
        )

        TransferTryInstantFinalConfirm(
            "Receiver reached final confirm stage."
        )

        local completed =
            TransferConfirmAndWait(
                "Confirming",
                30
            )

        if completed ~= true then

            if TransferState.TradeDeclined == true then
                return false, "Trade declined"
            end

            return false, "Trade did not complete"
        end

    else

        TransferUpdateTradeStatusText(
            "Manual Confirm",
            "Waiting for you to press Confirm."
        )

        local completed =
            TransferWaitForTradeCompleted(90)

        if completed ~= true then

            if TransferState.TradeDeclined == true then
                return false, "Trade declined"
            end

            return false, "Manual confirm timeout"
        end
    end

    TransferState.Batch =
        TransferState.Batch + 1

    TransferSetStatus(
        "Trade Done",
        "Received batch "
            .. tostring(TransferState.Batch)
            .. "."
    )

    return true, "Received batch"
end

function TransferSenderCanRetryAfterFailure(message)

    message =
        tostring(message or "")

    return message == "Trade declined"
        or message == "Trade timeout"
        or message == "Receiver accept timeout"
        or message == "Confirm timeout"
        or message == "Complete timeout"
        or message == "Accept failed"
        or message == "No pets added"
        or message == "Ticket failed"
        or message == "Request blocked"
end

function TransferWorkerLoop()

    TransferState.WorkerToken =
        (
            tonumber(TransferState.WorkerToken)
            or 0
        )
        + 1

    local workerToken =
        TransferState.WorkerToken

    TransferState.IsTransferRunning =
        true

    TransferState.Batch =
        0

    TransferState.AddedThisBatch =
        0

    TransferSetStatus(
        "Enabled",
        "Transfer worker restarted."
    )

    task.spawn(function()

        while IsHolyLiteCurrentRun()
        and TransferState.TransferEnabled == true
        and TransferState.WorkerToken == workerToken do

            local ok, msg

            if TransferState.Mode == "Receiver" then

                ok, msg =
                    TransferRunReceiverBatch()

            else

                ok, msg =
                    TransferRunSenderBatch()
            end

            if ok ~= true then

                if tostring(msg) == "No matches" then

                    TransferStopWorker(
                        "No matching pets left."
                    )

                    break
                end

                if TransferState.KeepGoing == true
                and TransferState.Mode == "Receiver" then

                    if TransferIsLiveTradeOpen() == true then

                        TransferReceiverDrainOpenTrade(
                            25
                        )
                    end

                    if TransferState.TradeDeclined ~= true
                    and TransferState.TradeCompleted ~= true
                    and TransferState.TradeResult ~= "Completed"
                    and TransferReceiverHasRecoverableLiveTrade() == true then

                        TransferSetStatus(
                            "Recovering",
                            "Active trade still open. Reattaching instead of waiting for new ticket."
                        )

                        task.wait(0.15)

                        continue
                    end

                    TransferResetTradeRuntime()

                    TransferSetStatus(
                        "Waiting",
                        "Ready for next ticket. Last: "
                            .. tostring(msg)
                    )

                    task.wait(0.35)

                    continue
                end

                if TransferState.KeepGoing == true
                and TransferState.Mode == "Sender"
                and TransferSenderCanRetryAfterFailure(msg) == true then

                    TransferSetStatus(
                        "Retrying",
                        "Preparing next ticket. Last: "
                            .. tostring(msg)
                    )

                    local retryStarted =
                        os.clock()

                    local retryMsg =
                        tostring(msg)

                    if retryMsg == "Trade declined" then

                        -- Force cleanup because one decline can leave server/UI briefly stuck.
                        TransferFireTradeRemote("Decline")
                        task.wait(0.08)
                        TransferFireTradeRemote("Decline")

                        TransferWaitForLiveTradeClosed(3)
                        TransferWaitUntilSafeToSendTicket(12)

                    elseif retryMsg == "Request blocked" then

                        TransferSetStatus(
                            "Blocked",
                            "Still inside previous trade. Waiting for cleanup instead of spamming tickets."
                        )

                        local blockedStarted =
                            os.clock()

                        while IsHolyLiteCurrentRun()
                        and TransferState.TransferEnabled == true
                        and os.clock() - blockedStarted < 12 do

                            if TransferState.TradeCompleted == true
                            or TransferState.TradeResult == "Completed"
                            or TransferGetLocalTradeState() == "Processing"
                            or TransferGetOtherTradeState() == "Processing" then
                                break
                            end

                            if TransferConfirmWindowReady() == true
                            or TransferGetTradeButtonText() == "Confirm"
                            or TransferGetTradeButtonText() == "Confirmed" then

                                TransferTryInstantFinalConfirm(
                                    "Request blocked while confirm was ready."
                                )

                                TransferConfirmAndWait(
                                    "Blocked Confirm Recovery",
                                    10
                                )

                                break
                            end

                            if TransferGetTradeButtonText() == "Accept" then

                                TransferAcceptAndWait(
                                    "Blocked Accept Recovery",
                                    8,
                                    TransferState.AddedThisBatch,
                                    0
                                )
                            end

                            TransferSetStatus(
                                "Blocked",
                                "Waiting previous trade. Button="
                                    .. tostring(TransferGetTradeButtonText())
                            )

                            task.wait(0.25)
                        end

                        TransferWaitForLiveTradeClosed(4)

                        task.wait(1.0)

                    else

                        task.wait(0.18)
                    end

                    if TransferIsInTradeHard() ~= true then
                        TransferResetTradeRuntime()
                    end

                    print(
                        "[TRANSFER SEND TIMING]",
                        "Retry ready",
                        "| last:",
                        tostring(retryMsg),
                        "| waited:",
                        string.format("%.3fs", os.clock() - retryStarted),
                        "| liveOpen:",
                        tostring(TransferIsLiveTradeOpen())
                    )

                    if #TransferBuildMatches() <= 0 then

                        TransferStopWorker(
                            "No matching pets left."
                        )

                        break
                    end

                    TransferSetStatus(
                        "Retrying",
                        "Sending new ticket."
                    )

                    continue
                end

                TransferStopWorker(
                    tostring(msg)
                )

                break
            end

            if TransferState.KeepGoing ~= true then

                TransferStopWorker(
                    "Finished one trade."
                )

                break
            end

            TransferSetStatus(
                "Waiting",
                "Next batch soon."
            )

            if TransferState.Mode == "Receiver" then

                TransferReceiverDrainOpenTrade(
                    25
                )
            end

            if TransferState.Mode == "Sender" then

                TransferWaitForLiveTradeClosed(8)

                if TransferRawLiveTradeVisible() ~= true then
                    TransferResetTradeRuntime()
                end

                task.wait(0.35)

                if #TransferBuildMatches() <= 0 then

                    TransferStopWorker(
                        "No matching pets left."
                    )

                    break
                end

            else

                task.wait(0.75)
            end
        end

        if TransferState.WorkerToken == workerToken then

            TransferState.IsTransferRunning =
                false
        end
    end)
end
---12.6 Transfer end--

--==================================================
-- [14.5] TRANSFER TAB
--==================================================

if Tabs.Transfer
and IsGardenWorld() then

    TransferStartTradeWatchers()

    local InitialTransferPetChoices =
        TransferBuildPetChoices()

    local InitialTransferMutationChoices =
        TransferBuildMutationChoices()

    local InitialTransferTargetChoices =
        TransferBuildTargetChoices()

        EnsureTransferDropdownChoice(
        InitialTransferTargetChoices,
        TransferState.TargetPlayerName
    )

    local TransferPetBox =
        AddTransferLeftBox(
            Tabs.Transfer,
            "Pet Filters",
            "sliders-horizontal"
        )

    local TransferTargetBox =
        AddTransferRightBox(
            Tabs.Transfer,
            "Trade Setup",
            "users"
        )

    local TransferActionsBox =
        AddTransferRightBox(
            Tabs.Transfer,
            "Automation",
            "gift"
        )

    local TransferStatusBox =
        AddTransferRightBox(
            Tabs.Transfer,
            "Status",
            "activity"
        )

    TransferState.SourceLabel =
        TransferStatusBox:AddLabel({
            Text = "Inventory Parsed: ...",
            DoesWrap = true,
            Size = 12,
        })

    TransferState.StatusLabel =
        TransferStatusBox:AddLabel({
            Text = "Mode: Idle",
            DoesWrap = true,
            Size = 12,
        })

    TransferState.TargetLabel =
        TransferStatusBox:AddLabel({
            Text = "Player: None",
            DoesWrap = true,
            Size = 12,
        })

    TransferState.MatchLabel =
        TransferStatusBox:AddLabel({
            Text = "Matched: 0 | Added: 0",
            DoesWrap = true,
            Size = 12,
        })

    TransferState.ResultLabel =
        TransferStatusBox:AddLabel({
            Text = "Batch: 0 | Sent: 0 | Result: None",
            DoesWrap = true,
            Size = 12,
        })

    TransferState.PetDropdown =
        TransferPetBox:AddDropdown(
            "HolyFreshTransferPets",
            {
                Text = "Pets",
                Values = InitialTransferPetChoices,
                Default = CopyTransferBoolMap(TransferState.SelectedPets),
                Searchable = true,
                Multi = true,
            }
        )

    TransferState.PetDropdown:OnChanged(function(value)

        TransferState.SelectedPets =
            TransferBuildMapFromDropdown(value)

        TransferBuildMatches()

        TransferSetStatus(
            "Filter Updated",
            "Selected pets updated."
        )
    end)

    TransferPetBox:AddButton({
        Text = "Remove All Pets",
        Tooltip = "Clear selected transfer pets.",
        Func = function()

            TransferState.SelectedPets =
                {}

            if TransferState.PetDropdown
            and type(TransferState.PetDropdown.SetValue) == "function" then
                TransferState.PetDropdown:SetValue({})
            end

            TransferBuildMatches()

            TransferSetStatus(
                "Filter Cleared",
                "Selected pets cleared."
            )
        end,
    })

    TransferState.MutationDropdown =
        TransferPetBox:AddDropdown(
            "HolyFreshTransferMutations",
            {
                Text = "Mutations",
                Values = InitialTransferMutationChoices,
                Default = CopyTransferBoolMap(TransferState.SelectedMutations),
                Searchable = true,
                Multi = true,
            }
        )

    TransferState.MutationDropdown:OnChanged(function(value)

        TransferState.SelectedMutations =
            TransferBuildMapFromDropdown(value)

        TransferBuildMatches()

        TransferSetStatus(
            "Filter Updated",
            "Selected mutations updated."
        )
    end)

    TransferPetBox:AddInput(
        "HolyFreshTransferMinLevel",
        {
            Text = "Min Level",
            Default = tostring(TransferState.MinLevel),
            Numeric = false,
            Finished = false,
            ClearTextOnFocus = false,
        }
    ):OnChanged(function(value)

        TransferState.MinLevel =
            math.max(
                1,
                math.floor(
                    TransferToNumber(value, 1)
                )
            )

        TransferBuildMatches()

        TransferSetStatus(
            "Filter Updated",
            "Min Level = "
                .. tostring(TransferState.MinLevel)
        )
    end)

    TransferPetBox:AddInput(
        "HolyFreshTransferMaxLevel",
        {
            Text = "Max Level",
            Default = tostring(TransferState.MaxLevel),
            Numeric = false,
            Finished = false,
            ClearTextOnFocus = false,
        }
    ):OnChanged(function(value)

        TransferState.MaxLevel =
            math.max(
                TransferState.MinLevel,
                math.floor(
                    TransferToNumber(value, 100)
                )
            )

        TransferBuildMatches()

        TransferSetStatus(
            "Filter Updated",
            "Max Level = "
                .. tostring(TransferState.MaxLevel)
        )
    end)

    TransferPetBox:AddInput(
        "HolyFreshTransferMinBaseWeight",
        {
            Text = "Min BaseWeight",
            Default = tostring(TransferState.MinBaseWeight),
            Numeric = false,
            Finished = false,
            ClearTextOnFocus = false,
        }
    ):OnChanged(function(value)

        TransferState.MinBaseWeight =
            math.max(
                0,
                TransferToNumber(value, 0)
            )

        TransferBuildMatches()

        TransferSetStatus(
            "Filter Updated",
            "Min BaseWeight = "
                .. tostring(TransferState.MinBaseWeight)
        )
    end)

    TransferPetBox:AddInput(
        "HolyFreshTransferMaxBaseWeight",
        {
            Text = "Max BaseWeight",
            Default = tostring(TransferState.MaxBaseWeight),
            Numeric = false,
            Finished = false,
            ClearTextOnFocus = false,
        }
    ):OnChanged(function(value)

        TransferState.MaxBaseWeight =
            math.max(
                0,
                TransferToNumber(value, 999)
            )

        TransferBuildMatches()

        TransferSetStatus(
            "Filter Updated",
            "Max BaseWeight = "
                .. tostring(TransferState.MaxBaseWeight)
        )
    end)

    TransferPetBox:AddButton({
        Text = "Reload Pets / Mutations",
        Tooltip = "Refresh full pet and mutation dropdowns.",
        Func = function()

            TransferState.AllPetChoices =
                {}

            TransferState.AllMutationChoices =
                {}

            TransferRefreshDropdowns()
        end,
    })

    TransferState.ModeDropdown =
        TransferTargetBox:AddDropdown(
            "HolyFreshTransferMode",
            {
                Text = "Mode",
                Values = {
                    "Sender",
                    "Receiver",
                },
                Default = TransferState.Mode,
                Searchable = false,
            }
        )

    TransferState.ModeDropdown:OnChanged(function(value)

        value =
            CleanText(value)

        if value ~= "Receiver" then
            value =
                "Sender"
        end

        local oldMode =
            tostring(TransferState.Mode or "Sender")

        TransferState.Mode =
            value

        TransferApplyModeUI()

        if oldMode ~= value then

            TransferResetWorkerForModeSwitch(
                value
            )

            return
        end

        TransferSetStatus(
            "Mode Updated",
            "Mode = "
                .. tostring(TransferState.Mode)
        )
    end)

    TransferState.TargetDropdown =
        TransferTargetBox:AddDropdown(
            "HolyFreshTransferTarget",
            {
                Text = "Player",
                Values = InitialTransferTargetChoices,
                Default = TransferState.TargetPlayerName,
                Searchable = true,
            }
        )

    TransferState.TargetDropdown:OnChanged(function(value)

        TransferState.TargetPlayerName =
            CleanText(value)

        TransferSetStatus(
            "Player Updated",
            TransferState.TargetPlayerName ~= ""
                and ("Player = " .. TransferState.TargetPlayerName)
                or "Player cleared."
        )
    end)

    TransferTargetBox:AddButton({
        Text = "Reload Players",
        Func = function()

            local targetChoices =
                TransferBuildTargetChoices()

            if TransferState.TargetDropdown
            and type(TransferState.TargetDropdown.SetValues) == "function" then

                TransferState.TargetDropdown:SetValues(
                    targetChoices
                )
            end

            print(
                "[TRANSFER TARGETS]",
                "targets:",
                tostring(#targetChoices)
            )

            TransferSetStatus(
                TransferState.Status,
                TransferState.LastResult
            )
        end,
    })

    TransferTargetBox:AddButton({
        Text = "Copy Trade Debug",
        Tooltip = "Copies live trade UI/remotes/state debug info to clipboard.",
        Func = function()

            local dump =
                TransferBuildTradeDebugDump()

            if CopyLiteTransferText(dump) then

                TransferSetStatus(
                    "Debug Copied",
                    "Trade debug dump copied to clipboard."
                )

                print(
                    "[TRANSFER DEBUG] Trade dump copied. Length:",
                    tostring(#dump)
                )

            else

                TransferSetStatus(
                    "Debug Failed",
                    "Clipboard unsupported."
                )
            end
        end,
    })

    TransferState.TransferEnabledToggle =
        TransferActionsBox:AddToggle(
            "HolyFreshTransferEnabled",
            {
                Text = "Transfer Enabled",
                Default = false,
                Tooltip = "Starts or stops the transfer worker.",
            }
        )

    TransferState.TransferEnabledToggle:OnChanged(function(value)

        local wantsEnabled =
            value == true

        -- Always invalidate the old worker first.
        TransferState.WorkerToken =
            (
                tonumber(TransferState.WorkerToken)
                or 0
            )
            + 1

        local restartToken =
            TransferState.WorkerToken

        TransferState.TransferEnabled =
            false

        TransferState.IsTransferRunning =
            false

        TransferState.IsAddingPets =
            false

        TransferResetTradeRuntime()

        if wantsEnabled ~= true then

            QueueSaveTransferSettings(
                "transfer disabled"
            )

            TransferSetStatus(
                "Disabled",
                "Transfer stopped and runtime reset."
            )

            return
        end

        TransferSetStatus(
            "Restarting",
            "Resetting old transfer worker..."
        )

        task.spawn(function()

            task.wait(0.20)

            if not IsHolyLiteCurrentRun() then
                return
            end

            if TransferState.WorkerToken ~= restartToken then
                return
            end

            TransferResetTradeRuntime()

            TransferState.Batch =
                0

            TransferState.AddedThisBatch =
                0

            TransferState.TransferEnabled =
                true

            QueueSaveTransferSettings(
                "transfer restarted"
            )

            TransferWorkerLoop()
        end)
    end)

    TransferState.AutoAcceptTicketToggle =
        TransferActionsBox:AddToggle(
            "HolyFreshTransferAutoAcceptTicket",
            {
                Text = "Auto Accept Ticket",
                Default = TransferState.AutoAcceptTicket == true,
                Tooltip = "Receiver mode: automatically accepts incoming trade tickets from the selected player.",
            }
        )

    TransferState.AutoAcceptTicketToggle:OnChanged(function(value)

        TransferState.AutoAcceptTicket =
            value == true

        TransferSetStatus(
            "Option Updated",
            "Auto Accept Ticket = "
                .. tostring(TransferState.AutoAcceptTicket)
        )
    end)

    TransferState.AutoConfirmToggle =
        TransferActionsBox:AddToggle(
            "HolyFreshTransferAutoConfirm",
            {
                Text = "Auto Confirm",
                Default = TransferState.AutoConfirm == true,
                Tooltip = "Receiver mode: automatically accepts the trade and final confirms.",
            }
        )

    TransferState.AutoConfirmToggle:OnChanged(function(value)

        TransferState.AutoConfirm =
            value == true

        TransferSetStatus(
            "Option Updated",
            "Auto Confirm = "
                .. tostring(TransferState.AutoConfirm)
        )
    end)

    TransferState.AutoAcceptGiftToggle =
        TransferActionsBox:AddToggle(
            "HolyFreshTransferAutoAcceptGift",
            {
                Text = "Auto Accept Gift",
                Default = TransferState.AutoAcceptGift == true,
                Tooltip = "Automatically accepts incoming pet gifts. If a player is selected, only accepts gifts from that player.",
            }
        )

    TransferState.AutoAcceptGiftToggle:OnChanged(function(value)

        TransferState.AutoAcceptGift =
            value == true

        TransferSetStatus(
            "Option Updated",
            "Auto Accept Gift = "
                .. tostring(TransferState.AutoAcceptGift)
        )
    end)

    TransferState.AutoUnfavoriteToggle =
        TransferActionsBox:AddToggle(
            "HolyFreshTransferAutoUnfavorite",
            {
                Text = "Auto Unfavorite",
                Default = TransferState.AutoUnfavorite == true,
                Tooltip = "Sender mode: unfavorites matching pets before adding them to trade.",
            }
        )

    TransferState.AutoUnfavoriteToggle:OnChanged(function(value)

        TransferState.AutoUnfavorite =
            value == true

        TransferSetStatus(
            "Option Updated",
            "Auto Unfavorite = "
                .. tostring(TransferState.AutoUnfavorite)
        )
    end)

    TransferState.KeepGoingToggle =
        TransferActionsBox:AddToggle(
            "HolyFreshTransferKeepGoing",
            {
                Text = "Keep Going",
                Default = TransferState.KeepGoing == true,
                Tooltip = "Sender: keep sending batches. Receiver: keep accepting next tickets.",
            }
        )

    TransferState.KeepGoingToggle:OnChanged(function(value)

        TransferState.KeepGoing =
            value == true

        TransferSetStatus(
            "Option Updated",
            "Keep Going = "
                .. tostring(TransferState.KeepGoing)
        )
    end)

    TransferActionsBox:AddToggle(
        "HolyFreshTransferDebugPrints",
        {
            Text = "Debug Prints",
            Default = TransferState.DebugPrints == true,
            Tooltip = "Only enable while testing. OFF removes console spam for faster transfer.",
        }
    ):OnChanged(function(value)

        TransferState.DebugPrints =
            value == true

        TransferSetStatus(
            "Option Updated",
            "Debug Prints = "
                .. tostring(TransferState.DebugPrints)
        )
    end)

    TransferState.MaxPetsInput =
        TransferActionsBox:AddInput(
            "HolyFreshTransferMaxPets",
            {
                Text = "Max Pets",
                Default = tostring(TransferState.MaxPetsPerTrade),
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                Tooltip = "Sender mode: maximum matched pets to add per trade ticket.",
            }
        )

    TransferState.MaxPetsInput:OnChanged(function(value)

        local tradeLimit =
            TransferGetTradeItemLimit()

        TransferState.MaxPetsPerTrade =
            math.clamp(
                math.floor(
                    TransferToNumber(value, 12)
                ),
                1,
                tradeLimit
            )

        TransferBuildMatches()

        QueueSaveTransferSettings(
            "max pets changed"
        )

        TransferSetStatus(
            "Option Updated",
            "Max Pets = "
                .. tostring(TransferState.MaxPetsPerTrade)
        )
    end)

    TransferState.AddPetDelayInput =
        TransferActionsBox:AddInput(
            "HolyFreshTransferAddPetDelay",
            {
                Text = "Add Delay",
                Default = tostring(TransferState.AddPetDelay),
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                Tooltip = "Sender mode: seconds to wait before adding the next pet.",
            }
        )

    TransferState.AddPetDelayInput:OnChanged(function(value)

        TransferState.AddPetDelay =
            math.clamp(
                TransferToNumber(value, 0.5),
                0.01,
                3
            )

        QueueSaveTransferSettings(
            "add delay changed"
        )

        TransferSetStatus(
            "Option Updated",
            "Add Delay = "
                .. string.format("%.2f", TransferState.AddPetDelay)
                .. "s"
        )
    end)

    TransferState.AddBurstInput =
        TransferActionsBox:AddInput(
            "HolyFreshTransferAddBurst",
            {
                Text = "Add Burst",
                Default = tostring(TransferState.AddBurstCount),
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                Tooltip = "Sender mode: how many pets to fire into the trade before waiting for confirmation.",
            }
        )

    TransferState.AddBurstInput:OnChanged(function(value)

        TransferState.AddBurstCount =
            math.clamp(
                math.floor(
                    TransferToNumber(value, 1)
                ),
                1,
                TransferGetMaxPetsPerTrade()
            )

        QueueSaveTransferSettings(
            "add burst changed"
        )

        TransferSetStatus(
            "Option Updated",
            "Add Burst = "
                .. tostring(TransferState.AddBurstCount)
        )
    end)

    TransferState.NextTicketDelayInput =
        TransferActionsBox:AddInput(
            "HolyFreshTransferNextTicketDelay",
            {
                Text = "Next Ticket Delay",
                Default = tostring(TransferState.NextTicketDelay),
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                Tooltip = "Sender mode: seconds to wait before sending the next trade request. 0 = instant.",
            }
        )

    TransferState.NextTicketDelayInput:OnChanged(function(value)

        TransferState.NextTicketDelay =
            math.clamp(
                TransferToNumber(value, 0),
                0,
                60
            )

        QueueSaveTransferSettings(
            "next ticket delay changed"
        )

        TransferSetStatus(
            "Option Updated",
            "Next Ticket Delay = "
                .. string.format("%.2f", TransferState.NextTicketDelay)
                .. "s"
        )
    end)

    TransferApplyModeUI()

    TransferConfigState.Loading =
        false

    local TransferDeclineButton =
        TransferActionsBox:AddButton({
            Text = "Decline",
            Tooltip = "Decline the current trade or pending request.",
            Func = function()

                if TransferState.Mode == "Receiver"
                and CleanText(TransferState.IncomingRequestId) ~= ""
                and TransferState.TradeOpen ~= true then

                    TransferDeclineIncomingRequest()

                else

                    TransferDeclineTrade()
                end
            end,
        })

    TransferDeclineButton:AddButton({
        Text = "Confirm",
        Tooltip = "Manual final confirm.",
        Func = function()

            TransferConfirmTrade()
        end,
    })

    task.defer(function()

        if not IsHolyLiteCurrentRun() then
            return
        end

        TransferBuildMatches()

        TransferSetStatus(
            TransferState.Status,
            TransferState.LastResult,
            true
        )
    end)

    Players.PlayerAdded:Connect(function()

        task.wait(0.05)

        if IsHolyLiteCurrentRun() then
            TransferRefreshDropdowns()
        end
    end)

    Players.PlayerRemoving:Connect(function()

        task.wait(0.03)

        if IsHolyLiteCurrentRun() then
            TransferRefreshDropdowns()
        end
    end)
end


function ClearLiteTable(source)

    if type(source) ~= "table" then
        return
    end

    for key in pairs(source) do
        source[key] =
            nil
    end
end

function NormalizeLiteSniperMode(value)

    value =
        CleanText(value)

    if value == "Rush"
    or value == "Overdrive"
    or value == "Custom" then
        return value
    end

    return "Standard"
end

function GetLiteSniperModeConfig()

    local mode =
        NormalizeLiteSniperMode(
            RuntimeState.SniperMode
        )

    RuntimeState.SniperMode =
        mode

    if mode == "Rush" then

        return {
            Mode = "Rush",
            OpeningStrike = true,
            ChainStrike = true,
            StrikeLimit = 3,
            SilentBuyPath = true,
            Status = "Rush · opening strike + chain · 3 strikes",
        }
    end

    if mode == "Overdrive" then

        return {
            Mode = "Overdrive",
            OpeningStrike = true,
            ChainStrike = true,
            StrikeLimit = 5,
            SilentBuyPath = true,
            Status = "Overdrive · max pressure · 5 strikes",
        }
    end

    if mode == "Custom" then

        return {
            Mode = "Custom",
            OpeningStrike = RuntimeState.CustomOpeningStrike == true,
            ChainStrike = RuntimeState.CustomChainStrike == true,

            StrikeLimit =
                math.clamp(
                    tonumber(RuntimeState.CustomStrikeLimit) or 3,
                    1,
                    5
                ),

            SilentBuyPath = RuntimeState.CustomSilentBuyPath == true,

            Status =
                "Custom · "
                .. (
                    RuntimeState.CustomOpeningStrike == true
                    and "opening"
                    or "no opening"
                )
                .. " · "
                .. (
                    RuntimeState.CustomChainStrike == true
                    and "chain"
                    or "single"
                )
                .. " · "
                .. tostring(
                    math.clamp(
                        tonumber(RuntimeState.CustomStrikeLimit) or 3,
                        1,
                        5
                    )
                )
                .. " strikes",
        }
    end

    return {
        Mode = "Standard",
        OpeningStrike = false,
        ChainStrike = false,
        StrikeLimit = 1,
        SilentBuyPath = false,
        Status = "Standard · stable matching · 1 strike",
    }
end

function RefreshLiteSniperModeVisuals()

    local config =
        GetLiteSniperModeConfig()

    SetControlText(
        SniperModeStatusLabel,
        '<font color="rgb(125,116,145)"><b>MODE</b></font>\n'
            .. '<font color="rgb(232,230,240)">'
            .. EscapeLiteRichText(config.Status)
            .. '</font>'
    )

    local customVisible =
        RuntimeState.SniperMode == "Custom"

    SetControlVisible(
        CustomOpeningStrikeToggle,
        customVisible
    )

    SetControlVisible(
        CustomChainStrikeToggle,
        customVisible
    )

    SetControlVisible(
        CustomStrikeLimitInput,
        customVisible
    )

    SetControlVisible(
        CustomSilentBuyPathToggle,
        customVisible
    )
end

function BuildLiteHardcodedCandidate(listing, config)

    if type(listing) ~= "table"
    or type(config) ~= "table" then
        return nil
    end

    return {
        WatchlistId = 0,
        PetName = listing.PetName,
        Listing = listing,

        Filter = {
            MaxPrice = config.MaxPrice,
            MinWeight = 0,
            WeightMode = "Base Weight",
            Priority = "Hardcoded",
            MutationMode = "Off",
            Mutations = {},
        },

        Reason = "OpeningStrike",
        IsHardcodedPriority = true,
        IsOpeningStrike = true,
    }
end

function TryLiteOpeningStrike(listings, modeConfig, cycleStartedAt)

    if type(modeConfig) ~= "table"
    or modeConfig.OpeningStrike ~= true then
        return false
    end

    if type(listings) ~= "table"
    or #listings <= 0 then
        return false
    end

    for _, listing in ipairs(listings) do

        if type(listing) == "table"
        and listing.IsFavorite ~= true
        and not IsLiteListingLocked(listing) then

            local passed, priorityConfig =
                LiteListingMatchesHardcodedPriority(
                    listing
                )

            if passed == true
            and type(priorityConfig) == "table" then

                local candidate =
                    BuildLiteHardcodedCandidate(
                        listing,
                        priorityConfig
                    )

                if candidate then

                    RuntimeState.Status =
                        "Opening strike"

                    RuntimeState.BestText =
                        tostring(listing.PetName or "Unknown")

                    RuntimeState.BestPrice =
                        tonumber(listing.Price)
                        or 0

                    RuntimeState.BestBooth =
                        tostring(listing.BoothId or "None")

                    RuntimeState.PriorityTarget =
                        tostring(listing.PetName or "Unknown")
                        .. " · Opening Strike"

                    print(
                        "[HOLY SNIPER LITE] Opening Strike:",
                        BuildLiteMatchRow(candidate)
                    )

                    BuyLiteCandidateQuiet(
                        candidate,
                        {
                            SilentBuyPath =
                                modeConfig.SilentBuyPath == true,

                            Path =
                                "Opening Strike",

                            CycleStartedAt =
                                cycleStartedAt,

                            DetectMs =
                                cycleStartedAt
                                and ((os.clock() - cycleStartedAt) * 1000)
                                or nil,

                            StrikeIndex =
                                1,

                            StrikeLimit =
                                math.clamp(
                                    tonumber(modeConfig.StrikeLimit) or 1,
                                    1,
                                    5
                                ),

                            MatchSkipped =
                                true,
                        }
                    )

                    return true
                end
            end
        end
    end

    return false
end

function ApplyLiteBestCandidateState(candidate)

    if type(candidate) ~= "table"
    or type(candidate.Listing) ~= "table" then
        return false
    end

    LatestBestCandidate =
        candidate

    local listing =
        candidate.Listing

    RuntimeState.Status =
        "Candidate found"

    RuntimeState.BestText =
        tostring(listing.PetName or "Unknown")

    RuntimeState.BestPrice =
        tonumber(listing.Price)
        or 0

    RuntimeState.BestBooth =
        tostring(listing.BoothId or "None")

    if candidate.IsHardcodedPriority == true then

        RuntimeState.PriorityTarget =
            tostring(listing.PetName or "Unknown")
            .. " · Max "
            .. FormatCompactPrice(
                candidate.Filter
                and candidate.Filter.MaxPrice
            )

    else

        RuntimeState.PriorityTarget =
            "None"
    end

    return true
end

function WatchlistName(watchlistId)

    watchlistId =
        tonumber(watchlistId)
        or 1

    if watchlistId == 0 then
        return "Priority"
    end

    if watchlistId == 3 then
        return "Eggs"
    end

    if watchlistId == 2 then
        return "W2 Alt"
    end

    return "W1 Main"
end

local FilterSaveButtons = {}

function FormatSaveTargetButton(watchlistId)

    local selected =
        FilterState.SaveTarget == watchlistId

    return selected
        and ("● " .. WatchlistName(watchlistId))
        or WatchlistName(watchlistId)
end

function RefreshSaveTargetButtons()

    for watchlistId, button in pairs(FilterSaveButtons) do

        SetControlText(
            button,
            FormatSaveTargetButton(watchlistId)
        )
    end
end

function SetFilterSaveTarget(watchlistId)

    FilterState.SaveTarget =
        tonumber(watchlistId)
        or 1

    RefreshSaveTargetButtons()

    MarkConfigDirty()
end

function ShouldShowMutationDropdown()

    return CleanText(FilterState.MutationMode) ~= "Off"
end

function RefreshLiteFilterInputLabels()

    if MaxPriceInput then

        local maxPriceText =
            "Max Price"

        if FilterState.MaxPriceWasEntered == true
        and tonumber(FilterState.MaxPrice)
        and tonumber(FilterState.MaxPrice) > 0 then

            maxPriceText =
                "Max Price: "
                .. FormatCompactPrice(
                    FilterState.MaxPrice
                )
        end

        SetControlText(
            MaxPriceInput,
            maxPriceText
        )
    end

    if MinWeightInput then

        local minWeightText =
            "Min Weight"

        if FilterState.MinWeightWasEntered == true
        and tonumber(FilterState.MinWeight)
        and tonumber(FilterState.MinWeight) >= 0 then

            minWeightText =
                "Min Weight: "
                .. tostring(FilterState.MinWeight)
        end

        SetControlText(
            MinWeightInput,
            minWeightText
        )
    end
end

function CopyMap(source)

    local output = {}

    if type(source) ~= "table" then
        return output
    end

    for key, value in pairs(source) do

        if value == true then
            output[tostring(key)] =
                true
        end
    end

    return output
end

function GetSelectedPetNamesForSave()

    local pets = {}
    local seen = {}

    if FilterState.AllowMultiSelectPets == true then

        for petName, selected in pairs(FilterState.SelectedPets or {}) do

            petName =
                CleanText(petName)

            if selected == true
            and petName ~= ""
            and petName ~= "None"
            and seen[petName] ~= true then

                seen[petName] =
                    true

                table.insert(
                    pets,
                    petName
                )
            end
        end

    else

        local petName =
            CleanText(FilterState.SelectedPet)

        if petName ~= ""
        and petName ~= "None" then

            table.insert(
                pets,
                petName
            )
        end
    end

    table.sort(pets)

    return pets
end

function GetSelectedEggNamesForImport()

    local eggs = {}
    local seen = {}

    if FilterState.AllowMultiSelectPets == true then

        for eggName, selected in pairs(FilterState.SelectedEggs or {}) do

            eggName =
                CleanText(eggName)

            if selected == true
            and eggName ~= ""
            and eggName ~= "None"
            and seen[eggName] ~= true then

                seen[eggName] =
                    true

                table.insert(
                    eggs,
                    eggName
                )
            end
        end

    else

        local eggName =
            CleanText(FilterState.SelectedEgg)

        if eggName ~= ""
        and eggName ~= "None" then

            table.insert(
                eggs,
                eggName
            )
        end
    end

    table.sort(eggs)

    return eggs
end

function SaveFilterForPet(watchlistId, petName)

    watchlistId =
        tonumber(watchlistId)
        or 1

    if not SniperFilterSets[watchlistId] then
        SniperFilterSets[watchlistId] =
            {}
    end

    petName =
        CleanText(petName)

    if petName == ""
    or petName == "None" then
        return false
    end

    SniperFilterSets[watchlistId][petName] = {
        MaxPrice =
            math.floor(
                tonumber(FilterState.MaxPrice)
                or 0
            ),

        MinWeight =
            math.max(
                0,
                tonumber(FilterState.MinWeight)
                or 0
            ),

        WeightMode =
            tostring(FilterState.WeightMode or "Base Weight"),

        Priority =
            tostring(FilterState.Priority or "Normal"),

        MutationMode =
            tostring(FilterState.MutationMode or "Off"),

        Mutations =
            CopyMap(FilterState.SelectedMutations),
    }

    return true
end

function SaveEggFiltersToEggWatchlist(eggName)

    eggName =
        CleanText(eggName)

    if eggName == ""
    or eggName == "None" then
        return 0, 0
    end

    local pets =
        GetLiteEggPets(eggName)

    if type(pets) ~= "table"
    or #pets <= 0 then
        return 0, 0
    end

    local watchlistId =
        3

    if not SniperFilterSets[watchlistId] then
        SniperFilterSets[watchlistId] =
            {}
    end

    local adds =
        0

    local updates =
        0

    for _, petName in ipairs(pets) do

        petName =
            CleanText(petName)

        if petName ~= ""
        and petName ~= "None" then

            if SniperFilterSets[watchlistId][petName] then
                updates =
                    updates + 1
            else
                adds =
                    adds + 1
            end

            SniperFilterSets[watchlistId][petName] = {
                MaxPrice =
                    math.floor(
                        tonumber(FilterState.MaxPrice)
                        or 0
                    ),

                MinWeight =
                    math.max(
                        0,
                        tonumber(FilterState.MinWeight)
                        or 0
                    ),

                WeightMode =
                    tostring(FilterState.WeightMode or "Base Weight"),

                Priority =
                    tostring(FilterState.Priority or "Normal"),

                MutationMode =
                    tostring(FilterState.MutationMode or "Off"),

                Mutations =
                    CopyMap(FilterState.SelectedMutations),

                Source =
                    "Egg Import",

                SourceEgg =
                    eggName,

                ImportedAt =
                    os.time(),
            }
        end
    end

    return adds, updates
end

function CountFiltersInWatchlist(watchlistId)

    watchlistId =
        tonumber(watchlistId)
        or 1

    local filters =
        SniperFilterSets[watchlistId]

    if type(filters) ~= "table" then
        return 0
    end

    local count =
        0

    for _ in pairs(filters) do
        count =
            count + 1
    end

    return count
end

function PrintWatchlistFilters(watchlistId)

    watchlistId =
        tonumber(watchlistId)
        or 1

    local filters =
        SniperFilterSets[watchlistId]

    print(
        "========== HOLY LITE "
            .. WatchlistName(watchlistId)
            .. " FILTERS =========="
    )

    if type(filters) ~= "table"
    or next(filters) == nil then

        print("No filters saved.")

        print("========================================")

        return
    end

    local names = {}

    for petName in pairs(filters) do
        table.insert(names, petName)
    end

    table.sort(names)

    for index, petName in ipairs(names) do

        local filter =
            filters[petName]

        print(
            tostring(index)
                .. ". "
                .. tostring(petName)
                .. " | Max "
                .. tostring(filter.MaxPrice)
                .. " | Min "
                .. tostring(filter.MinWeight)
                .. " | "
                .. tostring(filter.WeightMode)
                .. " | "
                .. tostring(filter.Priority)
                .. " | "
                .. tostring(filter.MutationMode)
        )
    end

    print("========================================")
end

function ValidateCurrentFilterBeforeSave()

    local maxPrice =
        tonumber(FilterState.MaxPrice)

    if not maxPrice
    or maxPrice <= 0
    or FilterState.MaxPriceWasEntered ~= true then

        warn("[HOLY SNIPER LITE] Add Filter failed: enter a valid Max Price first.")

        return false
    end

    FilterState.MaxPrice =
        math.floor(maxPrice)

    local minWeight =
        tonumber(FilterState.MinWeight)

    if not minWeight
    or minWeight < 0 then
        FilterState.MinWeight =
            0
    else
        FilterState.MinWeight =
            minWeight
    end

    return true
end

function SaveCurrentFilter()

    if not ValidateCurrentFilterBeforeSave() then
        return false
    end

    local watchlistId =
        tonumber(FilterState.SaveTarget)
        or 1

    local pets =
        GetSelectedPetNamesForSave()

    if #pets <= 0 then

        warn("[HOLY SNIPER LITE] Add Filter failed: no pet selected.")

        return false
    end

    local savedCount =
        0

    for _, petName in ipairs(pets) do

        if SaveFilterForPet(watchlistId, petName) then
            savedCount =
                savedCount + 1
        end
    end

    if savedCount <= 0 then

        warn("[HOLY SNIPER LITE] Add Filter failed: nothing saved.")

        return false
    end

    MarkConfigDirty()

    if type(SaveSniperFiltersNow) == "function" then
        SaveSniperFiltersNow("filter saved")
    end

    print(
        "[HOLY SNIPER LITE] Added "
            .. tostring(savedCount)
            .. " filter(s) to "
            .. WatchlistName(watchlistId)
            .. ". Total: "
            .. tostring(CountFiltersInWatchlist(watchlistId))
    )

    PrintWatchlistFilters(watchlistId)

    if type(RefreshWatchlist) == "function" then
        RefreshWatchlist()
    end

    return true
end

function SaveCurrentEggImport()

    if not ValidateCurrentFilterBeforeSave() then
        return false
    end

    local eggs =
        GetSelectedEggNamesForImport()

    if #eggs <= 0 then

        warn("[HOLY SNIPER LITE] Add Eggs failed: no egg selected.")

        return false
    end

    local totalAdds =
        0

    local totalUpdates =
        0

    for _, eggName in ipairs(eggs) do

        local adds, updates =
            SaveEggFiltersToEggWatchlist(
                eggName
            )

        totalAdds =
            totalAdds + adds

        totalUpdates =
            totalUpdates + updates
    end

    if totalAdds <= 0
    and totalUpdates <= 0 then

        warn("[HOLY SNIPER LITE] Add Eggs failed: no pets found in selected egg(s).")

        return false
    end

    FilterState.SaveTarget =
        3

    WatchlistState.ViewTarget =
        3

    WatchlistState.Page =
        1

    RefreshSaveTargetButtons()
    RefreshWatchlistViewButtons()

    MarkConfigDirty()

    if type(SaveSniperFiltersNow) == "function" then
        SaveSniperFiltersNow("egg filters saved")
    end

    print(
        "[HOLY SNIPER LITE] Egg import saved to Eggs:",
        tostring(totalAdds),
        "added,",
        tostring(totalUpdates),
        "updated."
    )

    PrintWatchlistFilters(3)

    if type(RefreshWatchlist) == "function" then
        RefreshWatchlist()
    end

    return true
end


function FormatLiteNumber(value, decimals)

    local number =
        tonumber(value)

    if not number then
        return "0"
    end

    decimals =
        tonumber(decimals)
        or 2

    local multiplier =
        10 ^ decimals

    number =
        math.floor(number * multiplier + 0.5) / multiplier

    return tostring(number)
end

function FormatCompactPrice(value)

    local number =
        tonumber(value)

    if not number then
        return "0"
    end

    number =
        math.floor(number)

    if number >= 1000000 then
        return tostring(math.floor(number / 100000) / 10) .. "m"
    end

    if number >= 1000 then
        return tostring(math.floor(number / 100) / 10) .. "k"
    end

    return tostring(number)
end

function FormatWatchlistWeightMode(value)

    value =
        tostring(value or "Base Weight")

    if value == "BaseWeight"
    or value == "Base Weight" then
        return "BW"
    end

    return "DW"
end

function CountMapValues(map)

    if type(map) ~= "table" then
        return 0
    end

    local count =
        0

    for _, enabled in pairs(map) do

        if enabled == true then
            count =
            count + 1
        end
    end

    return count
end

function FirstMapValues(map, limit)

    local values =
        {}

    limit =
        tonumber(limit)
        or 2

    if type(map) ~= "table" then
        return values
    end

    for key, enabled in pairs(map) do

        if enabled == true then

            table.insert(
                values,
                tostring(key)
            )
        end
    end

    table.sort(values)

    while #values > limit do
        table.remove(values)
    end

    return values
end

function FormatWatchlistMutation(filter)

    if type(filter) ~= "table" then
        return "Off"
    end

    local mode =
        tostring(filter.MutationMode or "Off")

    if mode == "Off"
    or mode == "" then
        return "Off"
    end

    if mode == "Mutated Only" then
        return "Mutated"
    end

    local mutationCount =
        CountMapValues(filter.Mutations)

    if mode == "Specific Mutations" then

        if mutationCount <= 0 then
            return "Specific: None"
        end

        local names =
            FirstMapValues(filter.Mutations, 2)

        if mutationCount <= 2 then
            return "Specific: " .. table.concat(names, ", ")
        end

        return "Specific: " .. tostring(mutationCount)
    end

    if mode == "Exclude Mutations" then

        if mutationCount <= 0 then
            return "Exclude: None"
        end

        local names =
            FirstMapValues(filter.Mutations, 2)

        if mutationCount <= 2 then
            return "Exclude: " .. table.concat(names, ", ")
        end

        return "Exclude: " .. tostring(mutationCount)
    end

    return mode
end

function FormatWatchlistListRow(entry)

    if type(entry) ~= "table" then
        return nil
    end

    local filter =
        entry.Filter

    if type(filter) ~= "table" then
        return nil
    end

    local priority =
        tostring(filter.Priority or "Normal")

    if priority == "Normal" then
        priority =
            "Norm"
    end

    return {
        Pet =
            tostring(entry.PetName or "Unknown"),

        Max =
            FormatCompactPrice(
                tonumber(filter.MaxPrice)
                or 0
            ),

        Weight =
            tostring(
                tonumber(filter.MinWeight)
                or 0
            ),

        Priority =
            priority,

        Entry =
            entry,
    }
end

function FormatWatchlistViewButton(watchlistId)

    local selected =
        WatchlistState.ViewTarget == watchlistId

    return selected
        and ("● " .. WatchlistName(watchlistId))
        or WatchlistName(watchlistId)
end

function RefreshWatchlistViewButtons()

    for watchlistId, button in pairs(WatchlistViewButtons) do

        SetControlText(
            button,
            FormatWatchlistViewButton(watchlistId)
        )
    end
end

function SetWatchlistViewTarget(watchlistId)

    WatchlistState.ViewTarget =
        tonumber(watchlistId)
        or 1

    WatchlistState.Page =
        1

    RefreshWatchlistViewButtons()

    if type(RefreshWatchlist) == "function" then
        RefreshWatchlist()
    end

    MarkConfigDirty()
end

function BuildWatchlistEntries()

    local entries =
        {}

    local watchlistId =
        tonumber(WatchlistState.ViewTarget)
        or 1

    local filters =
        SniperFilterSets[watchlistId]

    if type(filters) ~= "table" then
        return entries
    end

    local search =
        CleanText(WatchlistState.SearchText):lower()

    for petName, filter in pairs(filters) do

        petName =
            CleanText(petName)

        if petName ~= ""
        and type(filter) == "table" then

            local rowText =
                petName
                    .. " "
                    .. tostring(filter.MaxPrice or "")
                    .. " "
                    .. tostring(filter.MinWeight or "")
                    .. " "
                    .. tostring(filter.WeightMode or "")
                    .. " "
                    .. tostring(filter.Priority or "")
                    .. " "
                    .. tostring(filter.MutationMode or "")

            local passesSearch =
                search == ""
                or rowText:lower():find(search, 1, true) ~= nil

            if passesSearch then

                table.insert(entries, {
                    WatchlistId = watchlistId,
                    PetName = petName,
                    Filter = filter,
                })
            end
        end
    end

    table.sort(entries, function(a, b)

    local aPrice =
        tonumber(a.Filter and a.Filter.MaxPrice)
        or 0

    local bPrice =
        tonumber(b.Filter and b.Filter.MaxPrice)
        or 0

    if aPrice ~= bPrice then
        return aPrice > bPrice
    end

    return tostring(a.PetName or ""):lower()
        < tostring(b.PetName or ""):lower()
end)

    return entries
end

function FormatWatchlistRow(entry)

    if type(entry) ~= "table"
    or type(entry.Filter) ~= "table" then
        return " "
    end

    local filter =
        entry.Filter

    local selected =
        WatchlistState.SelectedWatchlistId == entry.WatchlistId
        and WatchlistState.SelectedPet == entry.PetName

    local marker =
        selected and "● " or "  "

    local weightMode =
        FormatWatchlistWeightMode(
            filter.WeightMode
        )

    local minWeight =
        tonumber(filter.MinWeight)
        or 0

    return marker
        .. tostring(entry.PetName)
        .. " | Max "
        .. FormatCompactPrice(filter.MaxPrice)
        .. " | "
        .. weightMode
        .. "≥"
        .. tostring(minWeight)
        .. " | "
        .. tostring(filter.Priority or "Normal")
        .. " | "
        .. FormatWatchlistMutation(filter)
end

function SelectWatchlistRow(rowIndex)

    rowIndex =
        tonumber(rowIndex)
        or 0

    local entry =
        WatchlistVisibleEntries[rowIndex]

    if type(entry) ~= "table" then
        return
    end

    WatchlistState.SelectedWatchlistId =
        entry.WatchlistId

    WatchlistState.SelectedPet =
        entry.PetName

    if type(RefreshWatchlist) == "function" then
        RefreshWatchlist()
    end

    print(
        "[HOLY SNIPER LITE] Selected filter:",
        WatchlistName(entry.WatchlistId),
        tostring(entry.PetName)
    )
end

function GetSelectedWatchlistEntry()

    local watchlistId =
        tonumber(WatchlistState.SelectedWatchlistId)

    local petName =
        CleanText(WatchlistState.SelectedPet)

    if not watchlistId
    or petName == "" then
        return nil
    end

    local filters =
        SniperFilterSets[watchlistId]

    if type(filters) ~= "table" then
        return nil
    end

    local filter =
        filters[petName]

    if type(filter) ~= "table" then
        return nil
    end

    return {
        WatchlistId = watchlistId,
        PetName = petName,
        Filter = filter,
    }
end

function LoadSelectedWatchlistFilter()

    local entry =
        GetSelectedWatchlistEntry()

    if not entry then
        warn("[HOLY SNIPER LITE] Load failed: select a filter first.")
        return false
    end

    local filter =
        entry.Filter

    FilterState.SaveTarget =
        entry.WatchlistId

    FilterState.AllowMultiSelectPets =
        false

    FilterState.SelectedPet =
        entry.PetName

    FilterState.SelectedPets =
        {}

    FilterState.SelectedPets[entry.PetName] =
        true

    FilterState.MaxPrice =
        tonumber(filter.MaxPrice)

    FilterState.MaxPriceWasEntered =
        FilterState.MaxPrice ~= nil
        and FilterState.MaxPrice > 0

    FilterState.MinWeight =
        tonumber(filter.MinWeight)
        or 0

    FilterState.MinWeightWasEntered =
        true

    FilterState.WeightMode =
        tostring(filter.WeightMode or "Base Weight")

    FilterState.Priority =
        tostring(filter.Priority or "Normal")

    FilterState.MutationMode =
        tostring(filter.MutationMode or "Off")

    FilterState.SelectedMutations =
        CopyMap(filter.Mutations)

    RefreshSaveTargetButtons()

    SetControlValue(
        LiteAllowMultiSelectToggle,
        false
    )

    SetControlVisible(
        SinglePetDropdown,
        true
    )

    SetControlVisible(
        MultiPetDropdown,
        false
    )

    SetControlValue(
        SinglePetDropdown,
        FilterState.SelectedPet
    )

    SetControlValue(
        MultiPetDropdown,
        {}
    )

    SetControlValue(
        MaxPriceInput,
        FilterState.MaxPriceWasEntered
            and tostring(FilterState.MaxPrice)
            or ""
    )

    SetControlValue(
        MinWeightInput,
        tostring(FilterState.MinWeight)
    )

    SetControlValue(
        WeightModeDropdown,
        FilterState.WeightMode
    )

    SetControlValue(
        PriorityDropdown,
        FilterState.Priority
    )

    SetControlValue(
        MutationModeDropdown,
        FilterState.MutationMode
    )

    SetControlValue(
        MutationDropdown,
        FilterState.SelectedMutations
    )

    SetControlVisible(
        MutationDropdown,
        ShouldShowMutationDropdown()
    )

    RefreshLiteFilterInputLabels()

    MarkConfigDirty()

    print(
        "[HOLY SNIPER LITE] Loaded filter:",
        WatchlistName(entry.WatchlistId),
        tostring(entry.PetName)
    )

    return true
end

function RemoveSelectedWatchlistFilter()

    local entry =
        GetSelectedWatchlistEntry()

    if not entry then
        warn("[HOLY SNIPER LITE] Remove failed: select a filter first.")
        return false
    end

    local filters =
        SniperFilterSets[entry.WatchlistId]

    if type(filters) ~= "table" then
        return false
    end

    filters[entry.PetName] =
        nil

    WatchlistState.SelectedWatchlistId =
        nil

    WatchlistState.SelectedPet =
        nil

    if type(SaveSniperFiltersNow) == "function" then
        SaveSniperFiltersNow("filter removed")
    end

    if type(RefreshWatchlist) == "function" then
        RefreshWatchlist()
    end

    print(
        "[HOLY SNIPER LITE] Removed filter:",
        WatchlistName(entry.WatchlistId),
        tostring(entry.PetName)
    )

    return true
end

function ClearCurrentWatchlist()

    local watchlistId =
        tonumber(WatchlistState.ViewTarget)
        or 1

    SniperFilterSets[watchlistId] =
        {}

    WatchlistState.SelectedWatchlistId =
        nil

    WatchlistState.SelectedPet =
        nil

    WatchlistState.Page =
        1

    if type(SaveSniperFiltersNow) == "function" then
        SaveSniperFiltersNow("watchlist cleared")
    end

    if type(RefreshWatchlist) == "function" then
        RefreshWatchlist()
    end

    warn(
        "[HOLY SNIPER LITE] Cleared watchlist:",
        WatchlistName(watchlistId)
    )

    return true
end

RefreshWatchlist = function()

    if not SniperWatchlistBox then
        return
    end

    RefreshWatchlistViewButtons()

    local entries =
        BuildWatchlistEntries()

    local perPage =
        math.clamp(
            tonumber(WatchlistState.PerPage) or 8,
            1,
            20
        )

    local pageCount =
        math.max(
            1,
            math.ceil(#entries / perPage)
        )

    WatchlistState.Page =
        math.clamp(
            tonumber(WatchlistState.Page) or 1,
            1,
            pageCount
        )

    local startIndex =
        ((WatchlistState.Page - 1) * perPage) + 1

    local endIndex =
        math.min(
            startIndex + perPage - 1,
            #entries
        )

    local statusText =
        WatchlistName(WatchlistState.ViewTarget)
        .. " · "
        .. tostring(#entries)
        .. " filter"
        .. (#entries == 1 and "" or "s")
        .. " · Page "
        .. tostring(WatchlistState.Page)
        .. "/"
        .. tostring(pageCount)

    SetControlText(
        WatchlistStatusLabel,
        statusText
    )

    ClearLiteTable(
        WatchlistVisibleEntries
    )

    local listRows =
        {}

    local selectedRowIndex =
        nil

    for rowIndex = 1, perPage do

        local absoluteIndex =
            startIndex + rowIndex - 1

        local entry =
            entries[absoluteIndex]

        WatchlistVisibleEntries[rowIndex] =
            entry

        if entry then

            listRows[rowIndex] =
                FormatWatchlistListRow(
                    entry
                )

            if WatchlistState.SelectedWatchlistId == entry.WatchlistId
            and WatchlistState.SelectedPet == entry.PetName then

                selectedRowIndex =
                    rowIndex
            end
        end
    end

    if WatchlistFilterList
    and type(WatchlistFilterList.SetRows) == "function" then

        WatchlistFilterList:SetRows(
            listRows
        )

        WatchlistFilterList:SetSelected(
            selectedRowIndex
        )

    else

        for rowIndex = 1, perPage do

            local entry =
                WatchlistVisibleEntries[rowIndex]

            local rowText =
                " "

            if entry then
                rowText =
                    FormatWatchlistRow(
                        entry
                    )
            end

            SetControlText(
                WatchlistRowButtons[rowIndex],
                rowText
            )
        end
    end
end

function CanUseHolyLiteFileIO()

    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

function EnsureHolyLiteSaveFolder()

    if type(makefolder) ~= "function"
    or type(isfolder) ~= "function" then
        return false
    end

    local ok =
        pcall(function()

            if not isfolder(SNIPER_FILTER_SAVE_FOLDER) then
                makefolder(SNIPER_FILTER_SAVE_FOLDER)
            end
        end)

    return ok == true
end

function CloneMutationMapForSave(source)

    local output = {}

    if type(source) ~= "table" then
        return output
    end

    for mutationName, enabled in pairs(source) do

        mutationName =
            CleanText(mutationName)

        if enabled == true
        and mutationName ~= ""
        and mutationName ~= "None"
        and mutationName ~= "Normal"
        and mutationName ~= "Unknown" then

            output[mutationName] =
                true
        end
    end

    return output
end

function NormalizeLiteSavedFilter(filter)

    if type(filter) ~= "table" then
        return nil
    end

    local maxPrice =
        tonumber(filter.MaxPrice)
        or 0

    local minWeight =
        tonumber(filter.MinWeight)
        or 0

    local weightMode =
        tostring(filter.WeightMode or "Base Weight")

    if weightMode ~= "Base Weight"
    and weightMode ~= "Display Weight" then
        weightMode =
            "Base Weight"
    end

    local priority =
        tostring(filter.Priority or "Normal")

    if priority ~= "Low"
    and priority ~= "Normal"
    and priority ~= "High" then
        priority =
            "Normal"
    end

    local mutationMode =
        tostring(filter.MutationMode or "Off")

    if mutationMode ~= "Off"
    and mutationMode ~= "Mutated Only"
    and mutationMode ~= "Specific Mutations"
    and mutationMode ~= "Exclude Mutations" then
        mutationMode =
            "Off"
    end

    return {
        MaxPrice =
            maxPrice,

        MinWeight =
            minWeight,

        WeightMode =
            weightMode,

        Priority =
            priority,

        MutationMode =
            mutationMode,

        Mutations =
            CloneMutationMapForSave(filter.Mutations),
    }
end

function BuildSniperFilterSavePayload()

    local payload = {
        Format = "HOLY_SNIPER_LITE_FILTERS",
        Version = 1,
        SavedAt = os.time(),

        Watchlists = {
            ["1"] = {},
            ["2"] = {},
            ["3"] = {},
        },
    }

    for watchlistId = 1, 3 do

        local filters =
            SniperFilterSets[watchlistId]

        local target =
            payload.Watchlists[tostring(watchlistId)]

        if type(filters) == "table" then

            for petName, filter in pairs(filters) do

                petName =
                    CleanText(petName)

                local normalized =
                    NormalizeLiteSavedFilter(filter)

                if petName ~= ""
                and normalized then

                    target[petName] =
                        normalized
                end
            end
        end
    end

    return payload
end

SaveSniperFiltersNow = function(reason)

    if not CanUseHolyLiteFileIO() then
        warn("[HOLY SNIPER LITE] File save unsupported by this executor.")
        return false
    end

    EnsureHolyLiteSaveFolder()

    local payload =
        BuildSniperFilterSavePayload()

    local ok, encoded =
        pcall(function()
            return HttpService:JSONEncode(payload)
        end)

    if not ok
    or type(encoded) ~= "string"
    or encoded == "" then

        warn("[HOLY SNIPER LITE] Filter save encode failed.")
        return false
    end

    local writeOk, writeErr =
        pcall(function()
            writefile(
                SNIPER_FILTER_SAVE_FILE,
                encoded
            )
        end)

    if not writeOk then

        warn(
            "[HOLY SNIPER LITE] Filter save failed:",
            tostring(writeErr)
        )

        return false
    end

    print(
        "[HOLY SNIPER LITE] Filters saved:",
        tostring(reason or "manual")
    )

    return true
end

LoadSniperFiltersNow = function()

    if not CanUseHolyLiteFileIO() then
        warn("[HOLY SNIPER LITE] File load unsupported by this executor.")
        return false
    end

    local exists =
        false

    local existsOk =
        pcall(function()
            exists =
                isfile(SNIPER_FILTER_SAVE_FILE)
        end)

    if not existsOk
    or exists ~= true then
        return false
    end

    local readOk, raw =
        pcall(function()
            return readfile(SNIPER_FILTER_SAVE_FILE)
        end)

    if not readOk
    or type(raw) ~= "string"
    or raw == "" then
        return false
    end

    local decodeOk, payload =
        pcall(function()
            return HttpService:JSONDecode(raw)
        end)

    if not decodeOk
    or type(payload) ~= "table"
    or payload.Format ~= "HOLY_SNIPER_LITE_FILTERS"
    or type(payload.Watchlists) ~= "table" then

        warn("[HOLY SNIPER LITE] Saved filters invalid.")
        return false
    end

    SniperFilterSets[1] = {}
    SniperFilterSets[2] = {}
    SniperFilterSets[3] = {}

    local loaded =
        0

    for watchlistId = 1, 3 do

        local source =
            payload.Watchlists[tostring(watchlistId)]
            or payload.Watchlists[watchlistId]

        if type(source) == "table" then

            for petName, filter in pairs(source) do

                petName =
                    CleanText(petName)

                local normalized =
                    NormalizeLiteSavedFilter(filter)

                if petName ~= ""
                and normalized then

                    SniperFilterSets[watchlistId][petName] =
                        normalized

                    loaded =
                        loaded + 1
                end
            end
        end
    end

    print(
        "[HOLY SNIPER LITE] Loaded saved filters:",
        tostring(loaded)
    )

    return loaded > 0
end

LoadSniperFiltersNow()

function LitePriorityToCompactValue(priority)

    priority =
        CleanText(priority)

    if priority == "High" then
        return 9
    end

    if priority == "Low" then
        return 1
    end

    return 5
end

function CompactPriorityToLitePriority(priority)

    local number =
        tonumber(priority)

    if number then

        if number >= 8 then
            return "High"
        end

        if number <= 3 then
            return "Low"
        end

        return "Normal"
    end

    priority =
        CleanText(priority)

    if priority == "High"
    or priority == "Low"
    or priority == "Normal" then
        return priority
    end

    return "Normal"
end

function LiteWeightModeToCompactValue(weightMode)

    weightMode =
        CleanText(weightMode)

    if weightMode == "Display Weight"
    or weightMode == "DisplayWeight"
    or weightMode == "D" then
        return "D"
    end

    return "B"
end

function CompactWeightModeToLiteWeightMode(weightMode)

    weightMode =
        CleanText(weightMode)

    if weightMode == "D"
    or weightMode == "Display Weight"
    or weightMode == "DisplayWeight" then
        return "Display Weight"
    end

    return "Base Weight"
end

function LiteMutationMapToArray(map)

    local output =
        {}

    if type(map) ~= "table" then
        return output
    end

    for mutationName, enabled in pairs(map) do

        mutationName =
            CleanText(mutationName)

        if enabled == true
        and mutationName ~= ""
        and mutationName ~= "None"
        and mutationName ~= "Normal"
        and mutationName ~= "Unknown" then

            table.insert(
                output,
                mutationName
            )
        end
    end

    table.sort(output)

    return output
end

function LiteArrayToMutationMap(array)

    local output =
        {}

    if type(array) ~= "table" then
        return output
    end

    for _, mutationName in ipairs(array) do

        mutationName =
            CleanText(mutationName)

        if mutationName ~= ""
        and mutationName ~= "None"
        and mutationName ~= "Normal"
        and mutationName ~= "Unknown" then

            output[mutationName] =
                true
        end
    end

    return output
end

function BuildLiteWatchlistExportPayload()

    local payload = {
        F = "HOLY_WL",
        V = 3,
        T = os.time(),

        W = {
            ["1"] = {},
            ["2"] = {},
            ["3"] = {},
        },
    }

    for watchlistId = 1, 3 do

        local filters =
            SniperFilterSets[watchlistId]

        local target =
            payload.W[tostring(watchlistId)]

        if type(filters) == "table" then

            local petNames =
                {}

            for petName in pairs(filters) do

                petName =
                    CleanText(petName)

                if petName ~= "" then

                    table.insert(
                        petNames,
                        petName
                    )
                end
            end

            table.sort(petNames)

            for _, petName in ipairs(petNames) do

                local filter =
                    filters[petName]

                if type(filter) == "table" then

                    local mutationMode =
                        CleanText(filter.MutationMode)

                    if mutationMode == "" then
                        mutationMode =
                            "Off"
                    end

                    local specificMutations =
                        {}

                    local excludedMutations =
                        {}

                    if mutationMode == "Specific Mutations" then
                        specificMutations =
                            LiteMutationMapToArray(
                                filter.Mutations
                            )

                    elseif mutationMode == "Exclude Mutations" then
                        excludedMutations =
                            LiteMutationMapToArray(
                                filter.Mutations
                            )
                    end

                    table.insert(target, {
                        petName,
                        math.floor(tonumber(filter.MaxPrice) or 0),
                        tonumber(filter.MinWeight) or 0,
                        LiteWeightModeToCompactValue(filter.WeightMode),
                        LitePriorityToCompactValue(filter.Priority),
                        mutationMode,
                        specificMutations,
                        excludedMutations,
                        filter.Source,
                        filter.SourceEgg,
                    })
                end
            end
        end
    end

    return payload
end

function EncodeLiteWatchlistExport()

    local payload =
        BuildLiteWatchlistExportPayload()

    local ok, encoded =
        pcall(function()
            return HttpService:JSONEncode(payload)
        end)

    if not ok
    or type(encoded) ~= "string"
    or encoded == "" then
        return nil
    end

    return encoded
end

function CopyLiteWatchlistExport()

    local encoded =
        EncodeLiteWatchlistExport()

    if not encoded then

        warn("[HOLY SNIPER LITE] Copy Watchlist failed: encode failed.")

        return false
    end

    local clipboard =
        setclipboard
        or toclipboard
        or set_clipboard

    if type(clipboard) ~= "function" then

        warn("[HOLY SNIPER LITE] Copy Watchlist failed: clipboard unsupported.")

        return false
    end

    pcall(function()
        clipboard(encoded)
    end)

    local counts =
        CountLiteWatchlistImportPayload(
            BuildLiteWatchlistExportPayload()
        )

    WatchlistTransferState.PreviewText =
        "Copied · "
        .. tostring(counts.Total)
        .. " filters\nW1 Main: "
        .. tostring(counts[1])
        .. " · W2 Alt: "
        .. tostring(counts[2])
        .. " · Eggs: "
        .. tostring(counts[3])

    RefreshLiteWatchlistImportPreview()

    print(
        "[HOLY SNIPER LITE] Copied watchlist export:",
        tostring(counts.Total),
        "filters."
    )

    return true
end

function DecodeLiteWatchlistImportText(text)

    text =
        tostring(text or "")

    text =
        text:gsub("^%s+", "")
            :gsub("%s+$", "")

    if text == "" then
        return nil, "Paste watchlist code."
    end

    local ok, payload =
        pcall(function()
            return HttpService:JSONDecode(text)
        end)

    if not ok
    or type(payload) ~= "table" then
        return nil, "Invalid watchlist code."
    end

    if payload.F == "HOLY_WL"
    and type(payload.W) == "table" then
        return payload, nil
    end

    if payload.Format == "HOLY_SNIPER_LITE_FILTERS"
    and type(payload.Watchlists) == "table" then

        local converted = {
            F = "HOLY_WL",
            V = 3,
            T = os.time(),

            W = {
                ["1"] = {},
                ["2"] = {},
                ["3"] = {},
            },
        }

        for watchlistId = 1, 3 do

            local source =
                payload.Watchlists[tostring(watchlistId)]
                or payload.Watchlists[watchlistId]

            if type(source) == "table" then

                for petName, filter in pairs(source) do

                    petName =
                        CleanText(petName)

                    if petName ~= ""
                    and type(filter) == "table" then

                        local mutationMode =
                            CleanText(filter.MutationMode)

                        if mutationMode == "" then
                            mutationMode =
                                "Off"
                        end

                        local specificMutations =
                            {}

                        local excludedMutations =
                            {}

                        if mutationMode == "Specific Mutations" then
                            specificMutations =
                                LiteMutationMapToArray(
                                    filter.Mutations
                                )

                        elseif mutationMode == "Exclude Mutations" then
                            excludedMutations =
                                LiteMutationMapToArray(
                                    filter.Mutations
                                )
                        end

                        table.insert(converted.W[tostring(watchlistId)], {
                            petName,
                            math.floor(tonumber(filter.MaxPrice) or 0),
                            tonumber(filter.MinWeight) or 0,
                            LiteWeightModeToCompactValue(filter.WeightMode),
                            LitePriorityToCompactValue(filter.Priority),
                            mutationMode,
                            specificMutations,
                            excludedMutations,
                            filter.Source,
                            filter.SourceEgg,
                        })
                    end
                end
            end
        end

        return converted, nil
    end

    return nil, "Unsupported watchlist format."
end

function CountLiteWatchlistImportPayload(payload)

    local counts = {
        [1] = 0,
        [2] = 0,
        [3] = 0,

        Total = 0,
    }

    if type(payload) ~= "table"
    or type(payload.W) ~= "table" then
        return counts
    end

    for watchlistId = 1, 3 do

        local rows =
            payload.W[tostring(watchlistId)]
            or payload.W[watchlistId]

        if type(rows) == "table" then

            for _, row in ipairs(rows) do

                if type(row) == "table" then

                    local petName =
                        CleanText(row[1])

                    local maxPrice =
                        tonumber(row[2])
                        or 0

                    if petName ~= ""
                    and maxPrice > 0 then

                        counts[watchlistId] =
                            counts[watchlistId] + 1

                        counts.Total =
                            counts.Total + 1
                    end
                end
            end
        end
    end

    return counts
end

function FormatLiteWatchlistImportPreview(payload, errorText)

    if errorText then
        return tostring(errorText)
    end

    local counts =
        CountLiteWatchlistImportPayload(payload)

    if counts.Total <= 0 then
        return "No valid filters detected."
    end

    return "Ready · "
        .. tostring(counts.Total)
        .. " filters detected\nW1 Main: "
        .. tostring(counts[1])
        .. " · W2 Alt: "
        .. tostring(counts[2])
        .. " · Eggs: "
        .. tostring(counts[3])
end

function RefreshLiteWatchlistImportPreview()

    SetControlText(
        WatchlistImportPreviewLabel,
        WatchlistTransferState.PreviewText
            or "Paste watchlist code."
    )
end

function PreviewLiteWatchlistImport()

    local payload, errorText =
        DecodeLiteWatchlistImportText(
            WatchlistTransferState.ImportText
        )

    WatchlistTransferState.PreviewText =
        FormatLiteWatchlistImportPreview(
            payload,
            errorText
        )

    RefreshLiteWatchlistImportPreview()

    return payload ~= nil, payload
end

function NormalizeLiteImportedCompactRow(row)

    if type(row) ~= "table" then
        return nil, nil
    end

    local petName =
        CleanText(row[1])

    if petName == ""
    or petName == "None" then
        return nil, nil
    end

    local maxPrice =
        math.floor(
            tonumber(row[2])
            or 0
        )

    if maxPrice <= 0 then
        return nil, nil
    end

    local minWeight =
        tonumber(row[3])
        or 0

    if minWeight < 0 then
        minWeight =
            0
    end

    local weightMode =
        CompactWeightModeToLiteWeightMode(
            row[4]
        )

    local priority =
        CompactPriorityToLitePriority(
            row[5]
        )

    local mutationMode =
        CleanText(row[6])

    if mutationMode == "" then
        mutationMode =
            "Off"
    end

    if mutationMode ~= "Off"
    and mutationMode ~= "Mutated Only"
    and mutationMode ~= "Specific Mutations"
    and mutationMode ~= "Exclude Mutations" then
        mutationMode =
            "Off"
    end

    local mutations =
        {}

    if mutationMode == "Specific Mutations" then
        mutations =
            LiteArrayToMutationMap(
                row[7]
            )

    elseif mutationMode == "Exclude Mutations" then
        mutations =
            LiteArrayToMutationMap(
                row[8]
            )
    end

    local filter = {
        MaxPrice =
            maxPrice,

        MinWeight =
            minWeight,

        WeightMode =
            weightMode,

        Priority =
            priority,

        MutationMode =
            mutationMode,

        Mutations =
            mutations,
    }

    local source =
        CleanText(row[9])

    if source ~= "" then
        filter.Source =
            source
    end

    local sourceEgg =
        CleanText(row[10])

    if sourceEgg ~= "" then
        filter.SourceEgg =
            sourceEgg
    end

    return petName, filter
end

function ClearLiteWatchlistImportPaste()

    WatchlistTransferState.ImportText =
        ""

    WatchlistTransferState.PreviewText =
        "Paste watchlist code."

    SetControlValue(
        WatchlistImportPasteInput,
        ""
    )

    RefreshLiteWatchlistImportPreview()

    print("[HOLY SNIPER LITE] Watchlist paste cleared.")
end

function ApplyLiteWatchlistImport(payload, mode)

    if type(payload) ~= "table"
    or type(payload.W) ~= "table" then

        warn("[HOLY SNIPER LITE] Import failed: invalid payload.")

        return false
    end

    mode =
        CleanText(mode)

    if mode ~= "Merge" then
        mode =
            "Replace"
    end

    if mode == "Replace" then

        SniperFilterSets[1] =
            {}

        SniperFilterSets[2] =
            {}

        SniperFilterSets[3] =
            {}
    end

    local importedCounts = {
        [1] = 0,
        [2] = 0,
        [3] = 0,

        Total = 0,
    }

    for watchlistId = 1, 3 do

        if type(SniperFilterSets[watchlistId]) ~= "table" then
            SniperFilterSets[watchlistId] =
                {}
        end

        local rows =
            payload.W[tostring(watchlistId)]
            or payload.W[watchlistId]

        if type(rows) == "table" then

            for _, row in ipairs(rows) do

                local petName, filter =
                    NormalizeLiteImportedCompactRow(
                        row
                    )

                if petName
                and filter then

                    SniperFilterSets[watchlistId][petName] =
                        filter

                    importedCounts[watchlistId] =
                        importedCounts[watchlistId] + 1

                    importedCounts.Total =
                        importedCounts.Total + 1
                end
            end
        end
    end

    if importedCounts.Total <= 0 then

        WatchlistTransferState.PreviewText =
            "No valid filters imported."

        RefreshLiteWatchlistImportPreview()

        warn("[HOLY SNIPER LITE] Import failed: no valid filters.")

        return false
    end

    WatchlistState.Page =
        1

    WatchlistState.SelectedWatchlistId =
        nil

    WatchlistState.SelectedPet =
        nil

    if type(SaveSniperFiltersNow) == "function" then
        SaveSniperFiltersNow("watchlist import")
    end

    if type(RefreshWatchlist) == "function" then
        RefreshWatchlist()
    end

    MarkConfigDirty()

    WatchlistTransferState.PreviewText =
        "Imported · "
        .. tostring(importedCounts.Total)
        .. " filters\nW1 Main: "
        .. tostring(importedCounts[1])
        .. " · W2 Alt: "
        .. tostring(importedCounts[2])
        .. " · Eggs: "
        .. tostring(importedCounts[3])

    WatchlistTransferState.ImportText =
        ""

    SetControlValue(
        WatchlistImportPasteInput,
        ""
    )

    RefreshLiteWatchlistImportPreview()

    print(
        "[HOLY SNIPER LITE] Watchlist import",
        mode,
        "| total:",
        tostring(importedCounts.Total),
        "| W1:",
        tostring(importedCounts[1]),
        "| W2:",
        tostring(importedCounts[2]),
        "| Eggs:",
        tostring(importedCounts[3])
    )

    return true
end

function ImportLiteWatchlistsFromPaste(mode)

    local payload, errorText =
        DecodeLiteWatchlistImportText(
            WatchlistTransferState.ImportText
        )

    if not payload then

        WatchlistTransferState.PreviewText =
            tostring(errorText or "Invalid watchlist code.")

        RefreshLiteWatchlistImportPreview()

        warn(
            "[HOLY SNIPER LITE] Import failed:",
            tostring(errorText or "invalid")
        )

        return false
    end

    return ApplyLiteWatchlistImport(
        payload,
        mode
    )
end

function CountDictionaryEntries(source)

    if type(source) ~= "table" then
        return 0
    end

    local count =
        0

    for _ in pairs(source) do
        count =
            count + 1
    end

    return count
end

function FormatRuntimeBoothAge()

    if not LatestBoothData
    or LatestBoothUpdate <= 0 then
        return "Not ready"
    end

    local age =
        os.clock() - LatestBoothUpdate

    return string.format(
        "%.2fs ago",
        age
    )
end

function EscapeLiteRichText(value)

    local text =
        tostring(value or "")

    text =
        text:gsub("&", "&amp;")

    text =
        text:gsub("<", "&lt;")

    text =
        text:gsub(">", "&gt;")

    text =
        text:gsub('"', "&quot;")

    return text
end

function LitePresenceValueText(value)

    return '<font color="rgb(232,230,240)">'
        .. EscapeLiteRichText(value)
        .. '</font>'
end

function LitePresenceKeyText(value)

    return '<font color="rgb(125,116,145)">'
        .. EscapeLiteRichText(value)
        .. '</font>'
end

function FormatLitePresenceStatusText(status)

    status =
        CleanText(status)

    if status == "" then
        return "IDLE"
    end

    if status == "Idle" then
        return "IDLE"
    end

    if status == "Starting" then
        return "STARTING"
    end

    if status == "Stopping" then
        return "STOPPING"
    end

    if status == "Scanning" then
        return "SCANNING"
    end

    if status == "Candidate found" then
        return "TARGET FOUND"
    end

    if status == "Bought" then
        return "SNIPED"
    end

    if status == "Only favorite matches" then
        return "FAVORITE LOCKED"
    end

    if status == "Hopping" then
        return "HOPPING"
    end

    if status == "Hop failed"
    or status == "Teleport failed"
    or status == "Hop retry failed"
    or status == "Loop error" then
        return "ERROR"
    end

    if status == "Waiting for booth data"
    or status == "Waiting for fresh booth data" then
        return "WAITING"
    end

    return string.upper(status)
end

function GetLitePresenceStatusColor(status)

    status =
        CleanText(status)

    if status == "Bought" then
        return "73,230,133"
    end

    if status == "Candidate found" then
        return "103,232,249"
    end

    if status == "Only favorite matches" then
        return "250,204,21"
    end

    if status == "Hopping"
    or status == "Starting" then
        return "147,197,253"
    end

    if status == "Hop failed"
    or status == "Teleport failed"
    or status == "Hop retry failed"
    or status == "Loop error" then
        return "248,113,113"
    end

    if status == "Scanning" then
        return "168,139,250"
    end

    return "180,165,255"
end

function FormatLitePresenceRow(key, value)

    key =
        tostring(key or "")

    value =
        tostring(value or "")

    local keyWidth =
        11

    local padding =
        math.max(
            1,
            keyWidth - #key
        )

    local paddedKey =
        EscapeLiteRichText(key)
        .. string.rep(" ", padding)

    return '<font color="rgb(125,116,145)">'
        .. paddedKey
        .. '</font>'
        .. '<font color="rgb(232,230,240)">'
        .. EscapeLiteRichText(value)
        .. '</font>'
end

function FormatLiteSessionTime()

    local startedAt =
        tonumber(RuntimeState.SessionStartedAt)
        or os.clock()

    local elapsed =
        math.max(
            0,
            math.floor(os.clock() - startedAt)
        )

    local hours =
        math.floor(elapsed / 3600)

    local minutes =
        math.floor((elapsed % 3600) / 60)

    local seconds =
        elapsed % 60

    if hours > 0 then

        return string.format(
            "%02d:%02d:%02d",
            hours,
            minutes,
            seconds
        )
    end

    return string.format(
        "%02d:%02d",
        minutes,
        seconds
    )
end

function FormatLitePresenceServerText()

    local boothStatus =
        CleanText(RuntimeState.BoothStatus)

    if boothStatus == ""
    or boothStatus == "Not ready" then
        return "Ready"
    end

    local cleanStatus =
        boothStatus:gsub(" · .+$", "")

    if cleanStatus == "" then
        cleanStatus =
            "Ready"
    end

    return cleanStatus
end

function FormatLiteRecentSnipeLine(entry, index)

    if type(entry) ~= "table" then
        return nil
    end

    local petName =
        CleanText(entry.PetName)

    if petName == "" then
        petName =
            "Unknown"
    end

    local price =
        FormatCompactPrice(
            entry.Price
        )

    local weight =
        FormatLiteNumber(
            entry.DisplayWeight,
            2
        )

    return tostring(index)
        .. ". "
        .. petName
        .. " · "
        .. tostring(price)
        .. " · "
        .. tostring(weight)
        .. " KG"
end

function FormatLiteRecentSnipesText()

    local rows =
        {}

    if type(RuntimeState.RecentSnipes) == "table" then

        for index, entry in ipairs(RuntimeState.RecentSnipes) do

            local line =
                FormatLiteRecentSnipeLine(
                    entry,
                    index
                )

            if line then
                table.insert(
                    rows,
                    line
                )
            end
        end
    end

    if #rows <= 0 then
        return '<font color="rgb(125,116,145)"><b>RECENT SNIPES</b></font>\nNone'
    end

    return '<font color="rgb(125,116,145)"><b>RECENT SNIPES</b></font>\n'
        .. EscapeLiteRichText(
            table.concat(
                rows,
                "\n"
            )
        )
end

function RefreshLiteRecentSnipesLabel()

    SetControlText(
        RecentSnipesLabel,
        FormatLiteRecentSnipesText()
    )
end

function PushLiteRecentSnipe(candidate)

    if type(candidate) ~= "table"
    or type(candidate.Listing) ~= "table" then
        return false
    end

    if type(RuntimeState.RecentSnipes) ~= "table" then
        RuntimeState.RecentSnipes =
            {}
    end

    local listing =
        candidate.Listing

    table.insert(
        RuntimeState.RecentSnipes,
        1,
        {
            PetName =
                tostring(listing.PetName or "Unknown"),

            Price =
                tonumber(listing.Price)
                or 0,

            DisplayWeight =
                tonumber(listing.DisplayWeight)
                or 0,

            BaseWeight =
                tonumber(listing.BaseWeight)
                or 0,

            Age =
                listing.Age,

            MutationText =
                listing.MutationText,

            At =
                os.time(),
        }
    )

    while #RuntimeState.RecentSnipes > 5 do
        table.remove(RuntimeState.RecentSnipes)
    end

    RefreshLiteRecentSnipesLabel()

    return true
end

function RefreshLitePresenceLabels()

    local rawStatus =
        tostring(RuntimeState.Status or "Idle")

    local displayStatus =
        FormatLitePresenceStatusText(
            rawStatus
        )

    local statusColor =
        GetLitePresenceStatusColor(
            rawStatus
        )

    SetControlText(
        PresenceStateLabel,
        '<font color="rgb('
            .. statusColor
            .. ')"><b>● '
            .. EscapeLiteRichText(displayStatus)
            .. '</b></font>'
    )

    local autoHopText =
        "Off"

    if type(FormatLiteAutoHopText) == "function" then

        local ok, result =
            pcall(function()
                return FormatLiteAutoHopText()
            end)

        if ok
        and result ~= nil then
            autoHopText =
                tostring(result)
        end
    end

    if PresenceStatsList
    and type(PresenceStatsList.SetRow) == "function" then

        PresenceStatsList:SetRow(
            "SERVER",
            FormatLitePresenceServerText()
        )

        PresenceStatsList:SetRow(
            "AUTO HOP",
            autoHopText
        )

        PresenceStatsList:SetRow(
            "BOOTHS",
            tostring(RuntimeState.BoothCount or 0)
        )

        PresenceStatsList:SetRow(
            "LISTINGS",
            tostring(RuntimeState.ListingsCount or 0)
        )

        PresenceStatsList:SetRow(
            "MATCHES",
            tostring(RuntimeState.MatchesCount or 0)
        )

        PresenceStatsList:SetRow(
            "BUY",
            tostring(RuntimeState.BuyStatus or "Idle")
        )

        PresenceStatsList:SetRow(
            "LAST ERROR",
            tostring(RuntimeState.LastErrorText or "None")
        )

        PresenceStatsList:SetRow(
            "SESSION",
            FormatLiteSessionTime()
        )

        PresenceStatsList:SetRow(
            "BOUGHT",
            tostring(RuntimeState.BoughtCount or 0)
        )

        PresenceStatsList:SetRow(
            "LAST",
            tostring(RuntimeState.LastSnipeText or "None")
        )
    end

    RefreshLiteRecentSnipesLabel()
end

function RefreshLiteRuntimeLabels()

    SetControlText(
        RuntimeStatusLabel,
        "Status: " .. tostring(RuntimeState.Status or "Idle")
    )

    SetControlText(
        RuntimeBoothDataLabel,
        "Booth Data: " .. tostring(RuntimeState.BoothStatus or "Not ready")
    )

    SetControlText(
        RuntimeBoothCountLabel,
        "Booths: " .. tostring(RuntimeState.BoothCount or 0)
    )

    SetControlText(
        RuntimePlayerCountLabel,
        "Player Data: " .. tostring(RuntimeState.PlayerDataCount or 0)
    )

    SetControlText(
        RuntimeListingsLabel,
        "Listings: " .. tostring(RuntimeState.ListingsCount or 0)
    )

    SetControlText(
        RuntimeScannedLabel,
        "Scanned: " .. tostring(RuntimeState.ScannedListingCount or 0)
    )

    SetControlText(
        RuntimeExtractLabel,
        "Extract: "
            .. string.format(
                "%.2fms",
                tonumber(RuntimeState.LastExtractMs) or 0
            )
    )

    SetControlText(
        RuntimeMatchesLabel,
        "Matches: " .. tostring(RuntimeState.MatchesCount or 0)
    )

    SetControlText(
        RuntimeMatchTimeLabel,
        "Match: "
            .. string.format(
                "%.2fms",
                tonumber(RuntimeState.LastMatchMs) or 0
            )
    )

    SetControlText(
        RuntimeLastMatchLabel,
        "Last Match: " .. tostring(RuntimeState.LastMatchText or "None")
    )

    SetControlText(
        RuntimeBestLabel,
        "Best: " .. tostring(RuntimeState.BestText or "None")
    )

    SetControlText(
        RuntimeBestPriceLabel,
        "Best Price: " .. tostring(RuntimeState.BestPrice or 0)
    )

    SetControlText(
        RuntimeBestBoothLabel,
        "Best Booth: " .. tostring(RuntimeState.BestBooth or "None")
    )

    SetControlText(
        RuntimePriorityTargetLabel,
        "Priority Target: " .. tostring(RuntimeState.PriorityTarget or "None")
    )

    SetControlText(
        RuntimeBuyRemoteLabel,
        "Buy Remote: " .. tostring(RuntimeState.BuyRemotePath or "Not resolved")
    )

    SetControlText(
        RuntimeBuyStatusLabel,
        "Buy Status: " .. tostring(RuntimeState.BuyStatus or "Idle")
    )

    RefreshLitePresenceLabels()
end

function ResolveLiteGetUpvalues(fn)

    local reader =
        type(getupvalues) == "function"
        and getupvalues
        or (
            debug
            and type(debug.getupvalues) == "function"
            and debug.getupvalues
        )

    if type(reader) ~= "function"
    or type(fn) ~= "function" then
        return nil
    end

    local ok, upvalues =
        pcall(function()
            return reader(fn)
        end)

    if not ok
    or type(upvalues) ~= "table" then
        return nil
    end

    return upvalues
end

function GetLiteTradeBoothController()

    if LiteTradeBoothController then
        return LiteTradeBoothController
    end

    local ok, result =
        pcall(function()

            local modules =
                ReplicatedStorage:FindFirstChild("Modules")
                or ReplicatedStorage:WaitForChild("Modules", 5)

            if not modules then
                return nil
            end

            local controllers =
                modules:FindFirstChild("TradeBoothControllers")
                or modules:WaitForChild("TradeBoothControllers", 5)

            if not controllers then
                return nil
            end

            local controllerModule =
                controllers:FindFirstChild("TradeBoothController")
                or controllers:WaitForChild("TradeBoothController", 5)

            if not controllerModule then
                return nil
            end

            return require(controllerModule)
        end)

    if ok
    and result then

        LiteTradeBoothController =
            result

        return LiteTradeBoothController
    end

    return nil
end

function PrimeLiteBoothControllerData()

    if not CanRunTradeSniper() then
        return false
    end

    local controller =
        GetLiteTradeBoothController()

    if not controller then
        return false
    end

    if type(controller.GetPlayerBoothData) == "function" then

        pcall(function()
            controller:GetPlayerBoothData()
        end)

        pcall(function()
            controller.GetPlayerBoothData(controller)
        end)

        return true
    end

    return false
end

function GetLiteBoothStore()

    if LiteBoothStore
    and type(LiteBoothStore.GetDataAsync) == "function" then
        return LiteBoothStore
    end

    local controller =
        GetLiteTradeBoothController()

    if not controller
    or type(controller.GetPlayerBoothData) ~= "function" then
        return nil
    end

    PrimeLiteBoothControllerData()

    local upvalues =
        ResolveLiteGetUpvalues(
            controller.GetPlayerBoothData
        )

    if type(upvalues) ~= "table" then
        return nil
    end

    for _, value in ipairs(upvalues) do

        if type(value) == "table"
        and type(value.GetDataAsync) == "function" then

            LiteBoothStore =
                value

            return LiteBoothStore
        end
    end

    return nil
end

function RefreshLatestBoothDataNow(reason, silent)

    if not CanRunTradeSniper() then

        RuntimeState.Status =
            "Garden World"

        RuntimeState.BoothStatus =
            "Trade World only"

        RefreshLiteRuntimeLabels()

        return nil, "Not in Trade World"
    end

    if silent ~= true then

        RuntimeState.Status =
            "Refreshing booth data"

        RuntimeState.BoothStatus =
            "Fetching..."

        RefreshLiteRuntimeLabels()
    end

    PrimeLiteBoothControllerData()

    local store =
        GetLiteBoothStore()

    if not store
    or type(store.GetDataAsync) ~= "function" then

        if silent ~= true then

            RuntimeState.Status =
                "Booth store missing"

            RuntimeState.BoothStatus =
                "Store missing"

            RefreshLiteRuntimeLabels()
        end

        return nil, "Booth store missing"
    end

    local ok, data =
        pcall(function()
            return store:GetDataAsync()
        end)

    if not ok
    or type(data) ~= "table" then

        if silent ~= true then

            RuntimeState.Status =
                "Booth data failed"

            RuntimeState.BoothStatus =
                "Fetch failed"

            RefreshLiteRuntimeLabels()
        end

        return nil, "Booth data fetch failed"
    end

    if type(data.Booths) ~= "table" then

        if silent ~= true then

            RuntimeState.Status =
                "Booth data invalid"

            RuntimeState.BoothStatus =
                "Missing Booths"

            RefreshLiteRuntimeLabels()
        end

        return nil, "Booth data missing Booths"
    end

    LatestBoothData =
        data

    LatestBoothUpdate =
        os.clock()

    RuntimeState.LastBoothRefreshAt =
        LatestBoothUpdate

    RuntimeState.BoothCount =
        CountDictionaryEntries(data.Booths)

    RuntimeState.PlayerDataCount =
        CountDictionaryEntries(data.Players)

    RuntimeState.BoothStatus =
        "Ready · " .. FormatRuntimeBoothAge()

    if silent ~= true then

        RuntimeState.Status =
            "Booth data ready"

        RefreshLiteRuntimeLabels()
    end

    if silent ~= true then

        print(
            "[HOLY SNIPER LITE] Booth data ready | booths:",
            tostring(RuntimeState.BoothCount),
            "| players:",
            tostring(RuntimeState.PlayerDataCount),
            "| reason:",
            tostring(reason or "manual")
        )
    end

    return data, "Fetched"
end

function StartLiteBoothRefreshWorker()

    if LiteBoothRefreshWorkerRunning == true then
        return
    end

    if not CanRunTradeSniper() then
        return
    end

    LiteBoothRefreshWorkerRunning =
        true

    task.spawn(function()

        print("[HOLY SNIPER LITE] Booth refresh worker started.")

        while IsHolyLiteCurrentRun()
        and LiteBoothRefreshWorkerRunning == true do

            if CanRunTradeSniper() then

                pcall(function()

                    RefreshLatestBoothDataNow(
                        "worker",
                        true
                    )
                end)
            end

            task.wait(
                LITE_BOOTH_REFRESH_INTERVAL
            )
        end

        print("[HOLY SNIPER LITE] Booth refresh worker stopped.")
    end)
end

function BuildLiteActiveBoothMap()

    local active =
        {}

    local tradeWorld =
        workspace:FindFirstChild("TradeWorld")

    if not tradeWorld then
        return active
    end

    local booths =
        tradeWorld:FindFirstChild("Booths")

    if not booths then
        return active
    end

    for _, booth in ipairs(booths:GetChildren()) do

        active[tostring(booth.Name)] =
            true
    end

    return active
end

function ReadLiteNumberFromSources(sources, keys)

    if type(sources) ~= "table"
    or type(keys) ~= "table" then
        return nil
    end

    for _, source in ipairs(sources) do

        if type(source) == "table" then

            for _, key in ipairs(keys) do

                local value =
                    rawget(source, key)

                local number =
                    tonumber(value)

                if number then
                    return number
                end
            end
        end
    end

    return nil
end

function ResolveLiteListingAge(petData, itemData, listingData)

    local age =
        ReadLiteNumberFromSources(
            {
                petData,
                itemData,
                listingData,
            },
            {
                "Level",
                "level",
                "Age",
                "age",
                "PetLevel",
                "petLevel",
                "PetAge",
                "petAge",
            }
        )

    if not age then
        return nil
    end

    age =
        math.floor(age)

    if age <= 0
    or age > 10000 then
        return nil
    end

    return age
end

function ResolveLiteAgeOneBaseWeight(rawBaseWeight)

    rawBaseWeight =
        tonumber(rawBaseWeight)

    if not rawBaseWeight then
        return nil
    end

    local ageOneBaseWeight =
        rawBaseWeight * 1.1

    ageOneBaseWeight =
        math.floor(ageOneBaseWeight * 100 + 0.5) / 100

    return ageOneBaseWeight
end

function ResolveLiteActualDisplayWeight(rawBaseWeight, age)

    rawBaseWeight =
        tonumber(rawBaseWeight)

    if not rawBaseWeight then
        return 0, "Missing"
    end

    age =
        tonumber(age)
        or 1

    age =
        math.clamp(
            age,
            1,
            125
        )

    local displayWeight =
        rawBaseWeight * (1 + (0.1 * age))

    displayWeight =
        math.floor(displayWeight * 100 + 0.5) / 100

    return displayWeight, "ActualRawBase"
end

function ResolveLiteDisplayWeight(baseWeight, age)

    return ResolveLiteActualDisplayWeight(
        baseWeight,
        age
    )
end

local LiteMutationNameCache =
    nil

local LiteMutationCodeCache =
    nil

function IsLiteInvalidMutationText(value)

    local text =
        CleanText(value)

    if text == ""
    or text == "---"
    or text == "None"
    or text == "Normal"
    or text == "Unknown"
    or text == "nil"
    or text == "false"
    or text == "0" then
        return true
    end

    if tonumber(text) then
        return true
    end

    if text:match("^%p+$") then
        return true
    end

    return false
end

function BuildLiteMutationNameAndCodeCache()

    if type(LiteMutationNameCache) == "table"
    and type(LiteMutationCodeCache) == "table" then
        return LiteMutationNameCache, LiteMutationCodeCache
    end

    local nameSet =
        {}

    local codeToName =
        {}

    local function AddName(name)

        name =
            CleanText(name)

        if IsLiteInvalidMutationText(name) then
            return
        end

        -- Names can be case-insensitive.
        nameSet[name:lower()] =
            name
    end

    local function AddCode(code, name)

        code =
            CleanText(code)

        name =
            CleanText(name)

        if IsLiteInvalidMutationText(code)
        or IsLiteInvalidMutationText(name) then
            return
        end

        -- IMPORTANT:
        -- Codes are case-sensitive.
        -- Do not add lower/upper aliases.
        codeToName[code] =
            name

        AddName(name)
    end

    for _, mutationName in ipairs(DynamicMutationList or {}) do
        AddName(mutationName)
    end

    local registry =
        GetPetRegistry()

    local mutationRoot =
        type(registry) == "table"
        and rawget(registry, "PetMutationRegistry")
        or nil

    if type(mutationRoot) ~= "table"
    and type(registry) == "table" then
        mutationRoot =
            registry
    end

    if type(mutationRoot) == "table" then

        local enumToPetMutation =
            rawget(mutationRoot, "EnumToPetMutation")

        if type(enumToPetMutation) == "table" then

            for code, mutationName in pairs(enumToPetMutation) do
                AddCode(code, mutationName)
            end
        end

        local petMutationToEnum =
            rawget(mutationRoot, "PetMutationToEnum")

        if type(petMutationToEnum) == "table" then

            for mutationName, code in pairs(petMutationToEnum) do
                AddName(mutationName)
                AddCode(code, mutationName)
            end
        end

        local petMutationRegistry =
            rawget(mutationRoot, "PetMutationRegistry")

        if type(petMutationRegistry) == "table" then

            for mutationName, mutationData in pairs(petMutationRegistry) do

                AddName(mutationName)

                if type(mutationData) == "table" then

                    local enum =
                        rawget(mutationData, "Enum")
                        or rawget(mutationData, "Code")
                        or rawget(mutationData, "Id")
                        or rawget(mutationData, "ID")
                        or rawget(mutationData, "MutationEnum")
                        or rawget(mutationData, "MutationId")

                    if enum then
                        AddCode(enum, mutationName)
                    end

                elseif type(mutationData) == "string"
                or type(mutationData) == "number" then

                    AddCode(mutationData, mutationName)
                end
            end
        end

        local machineMutationTypes =
            rawget(mutationRoot, "MachineMutationTypes")

        if type(machineMutationTypes) == "table" then

            for mutationName, mutationData in pairs(machineMutationTypes) do

                AddName(mutationName)

                if type(mutationData) == "table" then

                    local enum =
                        rawget(mutationData, "Enum")
                        or rawget(mutationData, "Code")
                        or rawget(mutationData, "Id")
                        or rawget(mutationData, "ID")
                        or rawget(mutationData, "MutationEnum")
                        or rawget(mutationData, "MutationId")

                    if enum then
                        AddCode(enum, mutationName)
                    end

                elseif type(mutationData) == "string"
                or type(mutationData) == "number" then

                    AddCode(mutationData, mutationName)
                end
            end
        end
    end

    LiteMutationNameCache =
        nameSet

    LiteMutationCodeCache =
        codeToName

    return LiteMutationNameCache, LiteMutationCodeCache
end

function ResolveLiteMutationCodeOrName(value)

    local nameSet, codeToName =
        BuildLiteMutationNameAndCodeCache()

    local text =
        CleanText(value)

    if IsLiteInvalidMutationText(text) then
        return nil
    end

    -- Exact-case code lookup only.
    -- A and a can mean different mutations.
    if type(codeToName) == "table" then

        local fromCode =
            codeToName[text]

        if fromCode then
            return fromCode
        end
    end

    if type(nameSet) == "table"
    and nameSet[text:lower()] then
        return nameSet[text:lower()]
    end

    -- Do not accept one/two-letter enum-looking values unless mapped.
    if #text <= 2 then
        return nil
    end

    return text
end

function BuildLiteMutationTextFromMap(map)

    if type(map) ~= "table" then
        return "Normal"
    end

    local names =
        {}

    for mutationName, enabled in pairs(map) do

        mutationName =
            CleanText(mutationName)

        if enabled == true
        and not IsLiteInvalidMutationText(mutationName) then

            table.insert(
                names,
                mutationName
            )
        end
    end

    table.sort(names)

    if #names <= 0 then
        return "Normal"
    end

    return table.concat(
        names,
        " "
    )
end

function ResolveLiteListingMutation(petData, itemData, listingData)

    local mutationMap =
        {}

    local sources = {
        petData,
        itemData,
        listingData,
    }

    local directMutationKeys = {
        "MutationText",
        "mutationText",

        "MutationName",
        "mutationName",

        "Mutation",
        "mutation",

        "MutationType",
        "mutationType",

        "PetMutation",
        "petMutation",

        "Variant",
        "variant",
    }

    -- 1. Actual direct mutation fields first.
    for _, source in ipairs(sources) do

        if type(source) == "table" then

            for _, key in ipairs(directMutationKeys) do

                local mutation =
                    ResolveLiteMutationCodeOrName(
                        rawget(source, key)
                    )

                if mutation then

                    mutationMap[mutation] =
                        true

                    return mutation, mutationMap
                end
            end
        end
    end

    -- 2. Trusted mutation containers only.
    local mutationContainers = {
        petData and rawget(petData, "Mutations"),
        petData and rawget(petData, "mutations"),

        itemData and rawget(itemData, "Mutations"),
        itemData and rawget(itemData, "mutations"),

        listingData and rawget(listingData, "Mutations"),
        listingData and rawget(listingData, "mutations"),
    }

    for _, container in ipairs(mutationContainers) do

        if type(container) == "table" then

            for key, value in pairs(container) do

                local rawMutation =
                    nil

                if value == true then
                    rawMutation =
                        key

                elseif type(value) == "string"
                or type(value) == "number" then
                    rawMutation =
                        value
                end

                local mutation =
                    ResolveLiteMutationCodeOrName(
                        rawMutation
                    )

                if mutation then
                    mutationMap[mutation] =
                        true
                end
            end
        end
    end

    local mutationText =
        BuildLiteMutationTextFromMap(
            mutationMap
        )

    return mutationText, mutationMap
end

function ExtractLiteListings(silent)

    local startedAt =
        os.clock()

    if not LatestBoothData then

        RuntimeState.Status =
            "Waiting for booth data"

        RuntimeState.ListingsCount =
            0

        RuntimeState.ScannedListingCount =
            0

        if silent ~= true then
            RefreshLiteRuntimeLabels()
        end

        return {}
    end

    local data =
        LatestBoothData

    if type(data) ~= "table"
    or type(data.Booths) ~= "table"
    or type(data.Players) ~= "table" then

        RuntimeState.Status =
            "Extract failed"

        RefreshLiteRuntimeLabels()

        warn("[HOLY SNIPER LITE] Extract failed: invalid booth data.")

        return {}
    end

    local activeBooths =
        BuildLiteActiveBoothMap()

    local listings =
        {}

    local scanned =
        0

    local localUserId =
        LocalPlayer
        and LocalPlayer.UserId
        or 0

    for boothId, boothData in pairs(data.Booths) do

        boothId =
            tostring(boothId)

        if activeBooths[boothId] ~= true then
            continue
        end

        if type(boothData) ~= "table" then
            continue
        end

        local owner =
            boothData.Owner
            or boothData.UserId
            or boothData.Player
            or boothData.PlayerId

        if not owner then
            continue
        end

        local playerData =
            data.Players[owner]

        if type(playerData) ~= "table" then
            playerData =
                data.Players[tostring(owner)]
        end

        if type(playerData) ~= "table" then
            continue
        end

        local listingsTable =
            playerData.Listings

        local itemsTable =
            playerData.Items

        if type(listingsTable) ~= "table"
        or type(itemsTable) ~= "table" then
            continue
        end

        local sellerInventoryPets =
            CountLiteSellerInventoryPets(
                itemsTable
            )

        for uid, listingData in pairs(listingsTable) do

            if type(listingData) ~= "table" then
                continue
            end

            if listingData.ItemType ~= "Pet" then
                continue
            end

            local itemId =
                listingData.ItemId

            local itemData =
                itemsTable[itemId]

            if type(itemData) ~= "table" then
                itemData =
                    itemsTable[tostring(itemId)]
            end

            if type(itemData) ~= "table" then
                continue
            end

            local petData =
                itemData.PetData

            if type(petData) ~= "table" then
                continue
            end

            local petName =
                CleanText(
                    itemData.PetType
                    or itemData.PetName
                    or itemData.Name
                    or petData.PetType
                    or petData.PetName
                    or ""
                )

            if petName == ""
            or petName == "Unknown" then
                continue
            end

            local price =
                tonumber(listingData.Price)
                or 0

            local rawBaseWeight =
                tonumber(
                    petData.BaseWeight
                    or petData.baseWeight
                    or itemData.BaseWeight
                    or itemData.baseWeight
                )

            if not rawBaseWeight then
                continue
            end

            local baseWeight =
                ResolveLiteAgeOneBaseWeight(
                    rawBaseWeight
                )

            if not baseWeight then
                continue
            end

            local sellerUserId =
                tonumber(
                    tostring(owner):match("_(%d+)$")
                )
                or tonumber(owner)
                or 0

            if sellerUserId == localUserId then
                continue
            end

            local age =
                ResolveLiteListingAge(
                    petData,
                    itemData,
                    listingData
                )

            local displayWeight, weightSource =
                ResolveLiteActualDisplayWeight(
                    rawBaseWeight,
                    age
                )

            local mutationText, mutationMap =
                ResolveLiteListingMutation(
                    petData,
                    itemData,
                    listingData
                )

            scanned =
                scanned + 1

            table.insert(listings, {
                BoothId = boothId,
                UID = tostring(uid),

                SellerUserId = sellerUserId,

                SellerInventoryPets =
                    sellerInventoryPets,

                PetName = petName,
                Price = price,

                RawBaseWeight = rawBaseWeight,

                BaseWeight = baseWeight,
                AgeOneBaseWeight = baseWeight,

                DisplayWeight = displayWeight,
                WeightSource = weightSource,

                Age = age,

                MutationText = mutationText,

                MutationMap =
                    mutationMap,

                IsFavorite =
                    petData.IsFavorite == true,

                SeenAt =
                    os.clock(),
            })
        end
    end

    LatestLiteListings =
        listings

    RuntimeState.ListingsCount =
        #listings

    RuntimeState.ScannedListingCount =
        scanned

    RuntimeState.LastExtractMs =
        (os.clock() - startedAt) * 1000

    RuntimeState.LastExtractAt =
        os.clock()

    RuntimeState.Status =
        "Listings extracted"

    if silent ~= true then
        RefreshLiteRuntimeLabels()
    end

    if silent ~= true then

        print(
            "[HOLY SNIPER LITE] Extracted listings:",
            tostring(#listings),
            "| scanned:",
            tostring(scanned),
            "|",
            string.format("%.2fms", RuntimeState.LastExtractMs)
        )
    end

    return listings
end

function GetLiteFilterWeight(listing, filter)

    if type(listing) ~= "table"
    or type(filter) ~= "table" then
        return 0
    end

    local mode =
        tostring(filter.WeightMode or "Base Weight")

    if mode == "Display Weight" then
        return tonumber(listing.DisplayWeight) or 0
    end

    return tonumber(listing.BaseWeight) or 0
end

function IsLiteNormalMutation(mutationText)

    mutationText =
        CleanText(mutationText)

    return mutationText == ""
        or mutationText == "Normal"
        or mutationText == "None"
        or mutationText == "---"
end

function LiteMutationMapIsEmpty(map)

    if type(map) ~= "table" then
        return true
    end

    for mutationName, enabled in pairs(map) do

        if enabled == true
        and not IsLiteInvalidMutationText(mutationName) then
            return false
        end
    end

    return true
end

function LiteMutationMapHasAny(source, selected)

    if type(source) ~= "table"
    or type(selected) ~= "table" then
        return false
    end

    for mutationName, selectedEnabled in pairs(selected) do

        if selectedEnabled == true
        and source[mutationName] == true then
            return true
        end
    end

    return false
end

function LiteMutationPassesFilter(listing, filter)

    if type(filter) ~= "table" then
        return true
    end

    local mode =
        CleanText(filter.MutationMode)

    if mode == ""
    or mode == "Off" then
        return true
    end

    local listingMutations =
        type(listing) == "table"
        and listing.MutationMap
        or nil

    if type(listingMutations) ~= "table" then
        listingMutations =
            {}
    end

    local hasMutation =
        not LiteMutationMapIsEmpty(
            listingMutations
        )

    if mode == "Mutated Only" then
        return hasMutation
    end

    local selectedMutations =
        type(filter.Mutations) == "table"
        and filter.Mutations
        or {}

    if mode == "Specific Mutations" then

        if not hasMutation then
            return false
        end

        if LiteMutationMapIsEmpty(selectedMutations) then
            return false
        end

        return LiteMutationMapHasAny(
            listingMutations,
            selectedMutations
        )
    end

    if mode == "Exclude Mutations" then

        if LiteMutationMapIsEmpty(selectedMutations) then
            return true
        end

        return not LiteMutationMapHasAny(
            listingMutations,
            selectedMutations
        )
    end

    return true
end

function LiteListingMatchesFilter(listing, filter)

    if type(listing) ~= "table"
    or type(filter) ~= "table" then
        return false, "Invalid"
    end

    local price =
        tonumber(listing.Price)
        or math.huge

    local maxPrice =
        tonumber(filter.MaxPrice)
        or 0

    if maxPrice <= 0 then
        return false, "BadMaxPrice"
    end

    if price > maxPrice then
        return false, "Price"
    end

    local minWeight =
        tonumber(filter.MinWeight)
        or 0

    local testWeight =
        GetLiteFilterWeight(
            listing,
            filter
        )

    if testWeight < minWeight then
        return false, "Weight"
    end

    if not LiteMutationPassesFilter(listing, filter) then
        return false, "Mutation"
    end

    return true, "Pass"
end

function GetLitePriorityRank(priority)

    priority =
        tostring(priority or "Normal")

    if priority == "High" then
        return 3
    end

    if priority == "Low" then
        return 1
    end

    return 2
end

function GetLiteHardcodedPriorityConfig(petName)

    petName =
        CleanText(petName)

    if petName == "" then
        return nil
    end

    local config =
        HardcodedPriorityPets[petName]

    if type(config) ~= "table" then
        return nil
    end

    local maxPrice =
        tonumber(config.MaxPrice)
        or 0

    if maxPrice <= 0 then
        return nil
    end

    return config
end

function LiteListingMatchesHardcodedPriority(listing)

    if type(listing) ~= "table" then
        return false, nil
    end

    local config =
        GetLiteHardcodedPriorityConfig(
            listing.PetName
        )

    if not config then
        return false, nil
    end

    local price =
        tonumber(listing.Price)
        or math.huge

    local maxPrice =
        tonumber(config.MaxPrice)
        or 0

    if price > maxPrice then
        return false, config
    end

    return true, config
end

function HasLiteHardcodedPriorityPets()

    for petName, config in pairs(HardcodedPriorityPets) do

        if CleanText(petName) ~= ""
        and type(config) == "table"
        and tonumber(config.MaxPrice)
        and tonumber(config.MaxPrice) > 0 then
            return true
        end
    end

    return false
end

function CountLiteSellerInventoryPets(itemsTable)

    if type(itemsTable) ~= "table" then
        return 0
    end

    local count =
        0

    for _, itemData in pairs(itemsTable) do

        if type(itemData) == "table"
        and type(itemData.PetData) == "table" then

            count =
            count + 1
        end
    end

    return count
end

function CountLiteLocalInventoryPets()

    local player =
        LocalPlayer
        or Players.LocalPlayer

    if not player then
        return 0
    end

    local containers = {
        player.Character,
        player:FindFirstChild("Backpack"),
    }

    local count =
        0

    local seen =
        {}

    for _, container in ipairs(containers) do

        if container then

            for _, child in ipairs(container:GetChildren()) do

                if child:IsA("Tool") then

                    local isPetTool =
                        false

                    local stableKey =
                        tostring(
                            child:GetAttribute("PET_UUID")
                            or child:GetAttribute("UUID")
                            or child:GetAttribute("uid")
                            or child:GetAttribute("ID")
                            or child.Name
                        )

                    if type(ParsePetTool) == "function" then

                        local okParsed, parsed =
                            pcall(function()
                                return ParsePetTool(child)
                            end)

                        if okParsed == true
                        and type(parsed) == "table" then

                            isPetTool =
                                true

                            stableKey =
                                tostring(
                                    parsed.StableKey
                                    or parsed.UID
                                    or stableKey
                                )
                        end
                    end

                    if isPetTool ~= true then

                        local toolName =
                            tostring(child.Name or "")

                        if child:GetAttribute("f")
                        or child:GetAttribute("PetType")
                        or child:GetAttribute("PetName")
                        or toolName:find("%[")
                        or toolName:find("KG") then

                            isPetTool =
                                true
                        end
                    end

                    if isPetTool == true
                    and seen[stableKey] ~= true then

                        seen[stableKey] =
                            true

                        count =
            count + 1
                    end
                end
            end
        end
    end

    return count
end

function FormatLiteTopSnipeWeightKG(value)

    local number =
        tonumber(value)

    if not number then
        return "Unknown KG"
    end

    return FormatLiteNumber(number, 2)
        .. " KG"
end

function FormatLiteTopSnipeBaseWeight(value)

    local number =
        tonumber(value)

    if not number then
        return "Unknown"
    end

    return FormatLiteNumber(number, 2)
end

function ResolveLiteTopSnipeThumbnailUrl(petName)

    petName =
        CleanText(petName)

    if petName == "" then
        return nil
    end

    local overrides = {

        ["Ghostly Spider"] =
            "https://static.wikia.nocookie.net/growagarden/images/a/a3/GhostlySpider.png/revision/latest?cb=20251014124843",

        ["Albino Peacock"] =
            "https://static.wikia.nocookie.net/growagarden/images/9/92/AlbinoPeacock.png/revision/latest?cb=20251227043649",

        ["Blue Whale"] =
            "https://static.wikia.nocookie.net/growagarden/images/c/c5/BlueWhale.png/revision/latest?cb=20251227044221",

        ["Ghostly Headless Horseman"] =
            "https://static.wikia.nocookie.net/growagarden/images/c/c0/GhostlyHeadlessHorseman.png/revision/latest?cb=20251014124925",

        ["Rainbow Elephant"] =
            "https://static.wikia.nocookie.net/growagarden/images/0/06/RainbowElephant.png/revision/latest?cb=20251101093454",

        ["Rainbow Birb"] =
            "https://static.wikia.nocookie.net/growagarden/images/1/13/RainbowBirb.png/revision/latest?cb=20260117041633",

        ["Rainbow Dilophosaurus"] =
            "https://static.wikia.nocookie.net/growagarden/images/d/d8/RainbowDilophosaurus.png/revision/latest?cb=20250806131700",

        ["Giant Scorpion"] =
            "https://static.wikia.nocookie.net/growagarden/images/b/b2/GiantScorpion.png/revision/latest?cb=20251227045639",

        ["Rainbow Fire Wisp"] =
            "https://static.wikia.nocookie.net/growagarden/images/d/d6/RainbowFireWisp.png/revision/latest?cb=20260605110532",
    }

    return overrides[petName]
end

function ApplyLiteTopSnipeThumbnail(embed, petName)

    if type(embed) ~= "table" then
        return false
    end

    local imageUrl =
        ResolveLiteTopSnipeThumbnailUrl(
            petName
        )

    if type(imageUrl) ~= "string"
    or imageUrl == "" then
        return false
    end

    embed.thumbnail = {
        url = imageUrl,
    }

    return true
end

function IsLiteTopSnipesTarget(listing)

    if LITE_TOP_SNIPES_WEBHOOK_ENABLED ~= true then
        return false
    end

    if type(LiteTopSnipesTargets) ~= "table" then
        return false
    end

    if type(listing) ~= "table" then
        return false
    end

    local petName =
        CleanText(
            listing.PetName
        )

    if petName == "" then
        return false
    end

    return LiteTopSnipesTargets[petName] == true
end

function BuildLiteMatchRow(match)

    if type(match) ~= "table"
    or type(match.Listing) ~= "table"
    or type(match.Filter) ~= "table" then
        return "Invalid match"
    end

    local listing =
        match.Listing

    local filter =
        match.Filter

    local sourceName =
        match.IsHardcodedPriority == true
        and "Priority"
        or WatchlistName(match.WatchlistId)

    return sourceName
        .. " "
        .. tostring(listing.PetName)
        .. " | Price "
        .. tostring(listing.Price)
        .. " | KG "
        .. FormatLiteNumber(listing.DisplayWeight, 2)
        .. " | BW "
        .. FormatLiteNumber(listing.BaseWeight, 2)
        .. " | Age "
        .. tostring(listing.Age or "?")
        .. " | Mut "
        .. (
            IsLiteNormalMutation(listing.MutationText)
            and "Normal"
            or CleanText(listing.MutationText)
        )
        .. " | "
        .. tostring(filter.Priority or "Normal")
        .. (
            listing.IsFavorite == true
            and " | Favorite"
            or ""
        )
end

local LITE_MARKET_SNIPE_WEBHOOK_ENABLED =
    true

local LITE_MARKET_SNIPE_WEBHOOK_URL =
    "https://discord.com/api/webhooks/1512020654394839121/40Pq5-i_zzfxN6Zt6Ot7NCCbFeMtcXj6vEXwKFiH8hlaerT_n767AkD0Xfsu2H9gey0E"

local LITE_TOP_SNIPES_WEBHOOK_ENABLED =
    true

local LITE_TOP_SNIPES_WEBHOOK_URL =
    "https://discord.com/api/webhooks/1507833081560829982/O5fpEqFLTqNnSOcdjPIhxXrBxASJTVRn1YLl_NHrElApUXGynUBgaoYAsKanVHn6Wdbj"

local LITE_TOP_SNIPES_WEBHOOK_COLOR =
    0xC4B5FD

local LiteTopSnipesTargets = {

    ["Rainbow Elephant"] = true,
    ["Rainbow Dilophosaurus"] = true,
    ["Rainbow Birb"] = true,
    ["Rainbow Hotdog Daschund"] = true,
    ["Ghostly Spider"] = true,
    ["Albino Peacock"] = true,
    ["Giant Scorpion"] = true,
    ["Blue Whale"] = true,
    ["Ghostly Headless Horseman"] = true,
    ["Rainbow Fire Wisp"] = true,
}

--==================================================
-- LITE MARKET TRACKER
-- Passive read-only tracker.
-- Does not buy, match, hop, or touch sniper webhook state.
--==================================================

local LITE_MARKET_TRACKER_ENABLED =
    true

local LITE_MARKET_TRACKER_WEBHOOK_URL =
    "https://discord.com/api/webhooks/1512583589580112032/FvMoKSGoT3LZZn7p_Xfz_ixF3x6qnrbESXmNG2XOiXaAMeVprx0A8a5KdwIQefBmnWCd"

local LITE_MARKET_TRACKER_PING_WEBHOOK_URL =
    "https://discord.com/api/webhooks/1513039097193697281/y0EDnEZa9wlPXb4goOZW0EgbsCm1_iRMsiLaeRutJ_iL51BvlkWF10VwGSFXTV6Zk4_b"

local LiteMarketTrackerPetColors = {

    ["Albino Peacock"] =
        0xF8FAFC,

    ["Rainbow Elephant"] =
        0xEF4444,

    ["Rainbow Dilophosaurus"] =
        0x3B82F6,

    ["Rainbow Birb"] =
        0xFF4FD8,

    ["Rainbow Hotdog Daschund"] =
        0xF97316,

    ["Ghostly Spider"] =
        0xC7F9FF,

    ["Giant Scorpion"] =
        0x374151,

    ["Blue Whale"] =
        0x2563EB,

    ["Ghostly Headless Horseman"] =
        0xC7F9FF,

    ["Rainbow Fire Wisp"] =
        0xE40E04,
}

local LITE_MARKET_TRACKER_INTERVAL =
    2.0

local LITE_MARKET_TRACKER_MAX_SENDS_PER_CYCLE =
    3

local LITE_MARKET_TRACKER_DEDUPE_SECONDS =
    600

local LITE_MARKET_TRACKER_PASSIVE_REFRESH_SECONDS =
    4.0

local LiteMarketTrackerSentLocks =
    {}

local LiteMarketTrackerState = {
    LastSend = 0,
    SendDelay = 0.35,
    LastPassiveRefresh = 0,
}

local LiteMarketTrackerTargets = {

    ["Rainbow Elephant"] = {
        PingBelow = 100000,
    },

    ["Rainbow Dilophosaurus"] = {
        PingBelow = 20000,
    },

    ["Rainbow Birb"] = {
        PingBelow = 20000,
    },

    ["Rainbow Hotdog Daschund"] = {
        PingBelow = 10000,
    },

    ["Ghostly Spider"] = {
        PingBelow = 10000,
    },

    ["Albino Peacock"] = {
        PingBelow = 50000,
    },

    ["Giant Scorpion"] = {
        PingBelow = 30000,
    },

    ["Blue Whale"] = {
        PingBelow = 15000,
    },

    ["Ghostly Headless Horseman"] = {
        PingBelow = 10000,
    },

    ["Rainbow Fire Wisp"] = {
        PingBelow = 10000,
    },
}

local LITE_MARKET_TRACKER_PING_TEXT =
    "<@&1512593489601368155>"

local LiteWebhookNameCache =
    {}

local LiteWebhookUserInfoCache =
    {}

function MaskLiteWebhookName(name)

    name =
        CleanText(name)

    if name == "" then
        return "Unknown"
    end

    local length =
        #name

    if length <= 1 then
        return name
    end

    if length == 2 then
        return name:sub(1, 1) .. "*"
    end

    return name:sub(1, 1)
        .. string.rep("*", math.max(1, length - 2))
        .. name:sub(length, length)
end

function ResolveLiteUsername(userId)

    userId =
        tonumber(userId)

    if not userId
    or userId <= 0 then
        return "Unknown"
    end

    if LiteWebhookNameCache[userId] then
        return LiteWebhookNameCache[userId]
    end

    local player =
        Players:GetPlayerByUserId(userId)

    if player
    and player.Name then

        LiteWebhookNameCache[userId] =
            player.Name

        return player.Name
    end

    local ok, result =
        pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)

    if ok
    and type(result) == "string"
    and result ~= "" then

        LiteWebhookNameCache[userId] =
            result

        return result
    end

    return tostring(userId)
end

function FormatLiteCommaNumber(value)

    local number =
        tonumber(value)

    if not number then
        return "0"
    end

    number =
        math.floor(number)

    local sign =
        ""

    if number < 0 then

        sign =
            "-"

        number =
            math.abs(number)
    end

    local text =
        tostring(number)

    while true do

        local changed = nil

        text, changed =
            text:gsub(
                "^(-?%d+)(%d%d%d)",
                "%1,%2"
            )

        if changed == 0 then
            break
        end
    end

    return sign .. text
end

function ResolveLiteUserDisplayTag(userId)

    userId =
        tonumber(userId)

    if not userId
    or userId <= 0 then
        return "Unknown"
    end

    if LiteWebhookUserInfoCache[userId] then
        return LiteWebhookUserInfoCache[userId]
    end

    local player =
        Players:GetPlayerByUserId(userId)

    if player then

        local username =
            CleanText(player.Name)

        local displayName =
            CleanText(player.DisplayName)

        local text =
            username

        if displayName ~= ""
        and username ~= ""
        and displayName ~= username then

            text =
                displayName
                .. " (@"
                .. username
                .. ")"
        end

        if text ~= "" then

            LiteWebhookUserInfoCache[userId] =
                text

            LiteWebhookNameCache[userId] =
                username

            return text
        end
    end

    local username =
        ResolveLiteUsername(userId)

    local okInfo, infoResult =
        pcall(function()

            return Players:GetUserInfosByUserIdsAsync({
                userId,
            })
        end)

    if okInfo == true
    and type(infoResult) == "table"
    and type(infoResult[1]) == "table" then

        local info =
            infoResult[1]

        local infoUsername =
            CleanText(
                info.Username
                or username
            )

        local displayName =
            CleanText(
                info.DisplayName
            )

        local text =
            infoUsername

        if displayName ~= ""
        and infoUsername ~= ""
        and displayName ~= infoUsername then

            text =
                displayName
                .. " (@"
                .. infoUsername
                .. ")"
        end

        if text ~= "" then

            LiteWebhookUserInfoCache[userId] =
                text

            LiteWebhookNameCache[userId] =
                infoUsername

            return text
        end
    end

    LiteWebhookUserInfoCache[userId] =
        username

    return username
end

function GetLiteMarketTrackerTargetConfig(petName)

    petName =
        CleanText(petName)

    if petName == "" then
        return nil
    end

    local config =
        LiteMarketTrackerTargets[petName]

    if config == true then
        return {
            PingBelow = nil,
        }
    end

    if type(config) == "table" then
        return config
    end

    return nil
end

function IsLiteMarketTrackerTarget(listing)

    if LITE_MARKET_TRACKER_ENABLED ~= true then
        return false
    end

    if type(listing) ~= "table" then
        return false
    end

    local petName =
        CleanText(
            listing.PetName
        )

    if petName == "" then
        return false
    end

    return GetLiteMarketTrackerTargetConfig(petName) ~= nil
end

function ShouldLiteMarketTrackerPing(listing)

    if type(listing) ~= "table" then
        return false
    end

    local config =
        GetLiteMarketTrackerTargetConfig(
            listing.PetName
        )

    if type(config) ~= "table" then
        return false
    end

    local pingBelow =
        tonumber(config.PingBelow)

    if not pingBelow
    or pingBelow <= 0 then
        return false
    end

    local price =
        tonumber(listing.Price)
        or math.huge

    return price <= pingBelow
end

function CleanupLiteMarketTrackerLocks()

    local now =
        os.clock()

    for key, expiresAt in pairs(LiteMarketTrackerSentLocks) do

        if tonumber(expiresAt)
        and now >= tonumber(expiresAt) then

            LiteMarketTrackerSentLocks[key] =
                nil
        end
    end
end

function BuildLiteMarketTrackerListingKey(listing)

    if type(listing) ~= "table" then
        return "nil"
    end

    return tostring(game.PlaceId)
        .. ":"
        .. tostring(game.JobId)
        .. ":"
        .. tostring(listing.BoothId or "None")
        .. ":"
        .. tostring(listing.UID or "None")
        .. ":"
        .. tostring(listing.Price or 0)
        .. ":"
        .. tostring(listing.PetName or "Unknown")
end

function IsLiteMarketTrackerLocked(listing)

    CleanupLiteMarketTrackerLocks()

    local key =
        BuildLiteMarketTrackerListingKey(
            listing
        )

    return LiteMarketTrackerSentLocks[key] ~= nil
end

function LockLiteMarketTrackerListing(listing)

    local key =
        BuildLiteMarketTrackerListingKey(
            listing
        )

    LiteMarketTrackerSentLocks[key] =
        os.clock()
        + (
            tonumber(LITE_MARKET_TRACKER_DEDUPE_SECONDS)
            or 600
        )

    return key
end

function BuildLiteMarketTrackerAppLink()

    return "roblox://experiences/start?placeId="
        .. tostring(game.PlaceId)
        .. "&gameInstanceId="
        .. tostring(game.JobId)
end

function FormatLiteMarketTrackerHugeText(listing)

    local weight =
        tonumber(
            listing
            and listing.DisplayWeight
        )
        or 0

    if weight >= 60 then
        return " (Huge)"
    end

    return ""
end

function ResolveLiteMarketTrackerColor(petName)

    petName =
        CleanText(petName)

    if petName ~= ""
    and type(LiteMarketTrackerPetColors) == "table"
    and tonumber(LiteMarketTrackerPetColors[petName]) then

        return tonumber(
            LiteMarketTrackerPetColors[petName]
        )
    end

    return tonumber(LITE_MARKET_TRACKER_COLOR)
        or 0x67E8F9
end

function SendLiteMarketTrackerWebhook(listing)

    if LITE_MARKET_TRACKER_ENABLED ~= true then
        return false
    end

    local shouldPing =
        ShouldLiteMarketTrackerPing(
            listing
        )

    local normalWebhookUrl =
        CleanText(
            LITE_MARKET_TRACKER_WEBHOOK_URL
        )

    local pingWebhookUrl =
        CleanText(
            LITE_MARKET_TRACKER_PING_WEBHOOK_URL
        )

    local webhookUrl =
        shouldPing == true
        and pingWebhookUrl
        or normalWebhookUrl

    if webhookUrl == ""
    or webhookUrl == "PASTE_MARKET_VALUE_WEBHOOK_HERE"
    or webhookUrl == "PASTE_MARKET_TRACKER_PING_WEBHOOK_HERE" then
        return false
    end

    if type(listing) ~= "table" then
        return false
    end

    if not IsLiteMarketTrackerTarget(listing) then
        return false
    end

    local requestFunction =
        request
        or http_request
        or (
            syn
            and syn.request
        )
        or (
            http
            and http.request
        )

    if type(requestFunction) ~= "function" then

        warn("[HOLY SNIPER LITE] Market Tracker failed: request unsupported.")

        return false
    end

    local now =
        os.clock()

    local waitTime =
        (
            tonumber(LiteMarketTrackerState.LastSend)
            or 0
        )
        + (
            tonumber(LiteMarketTrackerState.SendDelay)
            or 0.35
        )
        - now

    if waitTime > 0 then
        task.wait(waitTime)
    end

    LiteMarketTrackerState.LastSend =
        os.clock()

    local petName =
        tostring(
            listing.PetName
            or "Unknown"
        )

    local displayWeight =
        FormatLiteNumber(
            listing.DisplayWeight,
            2
        )

    local baseWeight =
        FormatLiteNumber(
            listing.BaseWeight,
            2
        )

    local ageText =
        tostring(
            listing.Age
            or "?"
        )

    local mutationText =
        IsLiteNormalMutation(listing.MutationText)
        and "Normal"
        or CleanText(listing.MutationText)

    if mutationText == ""
    or mutationText == "---"
    or mutationText == "Unknown" then
        mutationText =
            "Normal"
    end

    local sellerName =
        ResolveLiteUserDisplayTag(
            listing.SellerUserId
        )

    local favoritedText =
        listing.IsFavorite == true
        and "Yes"
        or "No"

    local dealText =
        shouldPing == true
        and "Tracked · Ping"
        or "Tracked"

    local appLink =
        BuildLiteMarketTrackerAppLink()

    local webLink =
        "https://www.roblox.com/games/start?placeId="
        .. tostring(game.PlaceId)
        .. "&gameInstanceId="
        .. tostring(game.JobId)

    local serverText =
        tostring(game.PlaceId)
        .. ":"
        .. tostring(game.JobId)

    local title =
        petName
        .. " [Age "
        .. ageText
        .. "] ["
        .. displayWeight
        .. " KG]"
        .. FormatLiteMarketTrackerHugeText(listing)

    local embed = {

        title =
            title,

        color =
            ResolveLiteMarketTrackerColor(
                petName
            ),

        fields = {

            {
                name = "Seller",
                value = tostring(sellerName),
                inline = false,
            },

            {
                name = "Price",
                value =
                    FormatLiteCommaNumber(
                        listing.Price
                    )
                    .. " tokens",
                inline = true,
            },

            {
                name = "Deal",
                value = dealText,
                inline = true,
            },

            {
                name = "Mutation",
                value = mutationText,
                inline = true,
            },

            {
                name = "Weight",
                value = displayWeight .. " KG",
                inline = true,
            },

            {
                name = "BaseWeight",
                value = baseWeight .. " BW",
                inline = true,
            },

            {
                name = "Favorited",
                value = favoritedText,
                inline = true,
            },

            {
                name = "Server",
                value =
                    "[Open Trade World]("
                    .. webLink
                    .. ")",
                inline = false,
            },

            {
                name = "Copy App Link",
                value =
                    "```text\n"
                    .. appLink
                    .. "\n```",
                inline = false,
            },

            {
                name = "Copy Server",
                value =
                    "```text\n"
                    .. serverText
                    .. "\n```",
                inline = false,
            },
        },

        footer = {
            text = "Holy Lite Market Tracker",
        },

        timestamp =
            DateTime.now():ToIsoDate(),
    }

    ApplyLiteTopSnipeThumbnail(
        embed,
        petName
    )

    local payload = {
        username =
            "Holy Lite Market Tracker",

        embeds = {
            embed,
        },
    }

    if shouldPing == true then

        local pingText =
            CleanText(
                LITE_MARKET_TRACKER_PING_TEXT
            )

        if pingText ~= ""
        and pingText ~= "<@&PASTE_ROLE_ID_HERE>" then

            payload.content =
                pingText
        end
    end

    local ok, response =
        pcall(function()

            return requestFunction({
                Url = webhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                },
                Body = HttpService:JSONEncode(payload),
            })
        end)

    if not ok then

        warn(
            "[HOLY SNIPER LITE] Market Tracker failed:",
            tostring(response)
        )

        return false
    end

    if type(response) == "table" then

        local statusCode =
            tonumber(
                response.StatusCode
                or response.status_code
            )

        if statusCode
        and statusCode ~= 200
        and statusCode ~= 204 then

            warn(
                "[HOLY SNIPER LITE] Market Tracker bad status:",
                tostring(statusCode),
                tostring(response.Body or response.body or "")
            )

            return false
        end
    end

    print(
        shouldPing == true
            and "[HOLY SNIPER LITE] Market Tracker ping sent:"
            or "[HOLY SNIPER LITE] Market Tracker normal sent:",
        title
    )

    return true
end

function GetLiteMarketTrackerListingsPassive()

    local listings =
        LatestLiteListings

    if type(listings) == "table"
    and #listings > 0 then
        return listings
    end

    if RuntimeState.SniperEnabled == true then
        return {}
    end

    local now =
        os.clock()

    if now - tonumber(LiteMarketTrackerState.LastPassiveRefresh or 0)
        < tonumber(LITE_MARKET_TRACKER_PASSIVE_REFRESH_SECONDS or 4.0) then

        return {}
    end

    LiteMarketTrackerState.LastPassiveRefresh =
        now

    local ok =
        pcall(function()

            RefreshLatestBoothDataNow(
                "market tracker passive",
                true
            )

            ExtractLiteListings(
                true
            )
        end)

    if ok ~= true then
        return {}
    end

    if type(LatestLiteListings) == "table" then
        return LatestLiteListings
    end

    return {}
end

function StartLiteMarketTrackerWorker()

    if LITE_MARKET_TRACKER_ENABLED ~= true then
        return false
    end

    if not CanRunTradeSniper() then
        return false
    end

    local root =
        type(getgenv) == "function"
        and getgenv()
        or _G

    if root.HOLY_LITE_MARKET_TRACKER_WORKER then
        return false
    end

    root.HOLY_LITE_MARKET_TRACKER_WORKER =
        true

    task.spawn(function()

        print("[HOLY SNIPER LITE] Market Tracker worker started.")

        while IsHolyLiteCurrentRun() do

            task.wait(
                tonumber(LITE_MARKET_TRACKER_INTERVAL)
                or 2.0
            )

            if LITE_MARKET_TRACKER_ENABLED ~= true then
                continue
            end

            if not CanRunTradeSniper() then
                continue
            end

            local listings =
                GetLiteMarketTrackerListingsPassive()

            if type(listings) ~= "table"
            or #listings <= 0 then
                continue
            end

            CleanupLiteMarketTrackerLocks()

            local sentThisCycle =
                0

            for _, listing in ipairs(listings) do

                if sentThisCycle >= (
                    tonumber(LITE_MARKET_TRACKER_MAX_SENDS_PER_CYCLE)
                    or 3
                ) then
                    break
                end

                if IsLiteMarketTrackerTarget(listing)
                and not IsLiteMarketTrackerLocked(listing) then

                    LockLiteMarketTrackerListing(
                        listing
                    )

                    sentThisCycle =
                        sentThisCycle + 1

                    task.spawn(function()

                        local okSend, sendResult =
                            pcall(function()
                                return SendLiteMarketTrackerWebhook(
                                    listing
                                )
                            end)

                        if okSend ~= true then

                            warn(
                                "[HOLY SNIPER LITE] Market Tracker crashed:",
                                tostring(sendResult)
                            )
                        end
                    end)
                end
            end
        end

        root.HOLY_LITE_MARKET_TRACKER_WORKER =
            false

        print("[HOLY SNIPER LITE] Market Tracker worker stopped.")
    end)

    return true
end

function ResolveLiteBuyerName()

    if LocalPlayer
    and LocalPlayer.Name then
        return LocalPlayer.Name
    end

    return "Unknown"
end

function ResolveLiteBuyerDisplayTag()

    if not LocalPlayer then
        return "Unknown"
    end

    local username =
        CleanText(LocalPlayer.Name)

    local displayName =
        CleanText(LocalPlayer.DisplayName)

    if displayName ~= ""
    and username ~= ""
    and displayName ~= username then

        return displayName
            .. " (@"
            .. username
            .. ")"
    end

    if username ~= "" then
        return username
    end

    return "Unknown"
end

function FormatLiteDiscordSpoilerText(value)

    local text =
        CleanText(value)

    if text == "" then
        text =
            "Unknown"
    end

    text =
        text:gsub("\n", " ")
            :gsub("\r", " ")
            :gsub("|", "¦")

    return "||"
        .. text
        .. "||"
end

--==================================================
-- LITE BUY REJECT REASON CAPTURE
--==================================================

LiteBuyRejectState =
    LiteBuyRejectState
    or {
        LastReason = "",
        LastMessage = "",
        LastAt = 0,
        MatchWindow = 2.0,
    }

function RegisterLiteBuyRejectNotification(message)

    if type(message) ~= "string" then
        return false
    end

    local lower =
        string.lower(message)

    local reason =
        nil

    if string.find(lower, "not enough tokens", 1, true)
    or string.find(lower, "don't have enough tokens", 1, true)
    or string.find(lower, "do not have enough tokens", 1, true) then

        reason =
            "No tokens"

    elseif string.find(lower, "pending sale", 1, true)
    or string.find(lower, "seller has a pending", 1, true)
    or string.find(lower, "pending", 1, true) then

        reason =
            "Pending sale"

    elseif string.find(lower, "favorite", 1, true)
    or string.find(lower, "favorited", 1, true)
    or string.find(lower, "favourited", 1, true) then

        reason =
            "Favorite locked"

    elseif string.find(lower, "already sold", 1, true)
    or string.find(lower, "no longer available", 1, true)
    or string.find(lower, "unavailable", 1, true) then

        reason =
            "Already sold"
    end

    if not reason then
        return false
    end

    LiteBuyRejectState.LastReason =
        reason

    LiteBuyRejectState.LastMessage =
        message

    LiteBuyRejectState.LastAt =
        os.clock()

    print(
        "[HOLY SNIPER LITE] Buy reject notification:",
        reason,
        "|",
        message
    )

    return true
end

function StartLiteBuyRejectNotificationCapture()

    local root =
        type(getgenv) == "function"
        and getgenv()
        or _G

    if root.HOLY_LITE_REJECT_NOTIFICATION_CONNECTION then

        pcall(function()
            root.HOLY_LITE_REJECT_NOTIFICATION_CONNECTION:Disconnect()
        end)

        root.HOLY_LITE_REJECT_NOTIFICATION_CONNECTION =
            nil
    end

    task.spawn(function()

        local gameEvents =
            ReplicatedStorage:WaitForChild(
                "GameEvents",
                10
            )

        if not gameEvents then
            return
        end

        local notificationRemote =
            gameEvents:WaitForChild(
                "Notification",
                10
            )

        if not notificationRemote
        or not notificationRemote:IsA("RemoteEvent") then
            return
        end

        root.HOLY_LITE_REJECT_NOTIFICATION_CONNECTION =
            notificationRemote.OnClientEvent:Connect(function(message)

                RegisterLiteBuyRejectNotification(
                    message
                )
            end)

        print("[HOLY SNIPER LITE] Buy reject notification capture ready.")
    end)
end

function ResolveLiteBuyRejectReason(result)

    local now =
        os.clock()

    if LiteBuyRejectState
    and LiteBuyRejectState.LastReason ~= ""
    and now - tonumber(LiteBuyRejectState.LastAt or 0)
        <= tonumber(LiteBuyRejectState.MatchWindow or 2.0) then

        return LiteBuyRejectState.LastReason,
            LiteBuyRejectState.LastMessage
    end

    local resultText =
        tostring(result or "")

    local lower =
        string.lower(resultText)

    if string.find(lower, "seller", 1, true)
    and (
        string.find(lower, "left", 1, true)
        or string.find(lower, "not in server", 1, true)
        or string.find(lower, "missing", 1, true)
    ) then

        return "Seller left", resultText
    end

    if string.find(lower, "remote", 1, true)
    or string.find(lower, "invoke", 1, true)
    or string.find(lower, "missing", 1, true) then

        return "Remote failed", resultText
    end

    if result == false then
        return "Rejected by game", "BuyListing returned false."
    end

    if result == nil then
        return "No response", "BuyListing returned nil."
    end

    if resultText ~= "" then
        return "Rejected by game", resultText
    end

    return "Unknown reject", "No reject detail captured."
end

StartLiteBuyRejectNotificationCapture()

_G.HOLY_LITE_SEND_SNIPE_WEBHOOK = function(candidate)

    if RuntimeState.WebhookEnabled ~= true then
        return false
    end

    if RuntimeState.WebhookSuccessfulSnipes ~= true then
        return false
    end

    local webhookUrl =
        CleanText(RuntimeState.WebhookURL)

    if webhookUrl == "" then
        return false
    end

    if type(candidate) ~= "table"
    or type(candidate.Listing) ~= "table" then
        return false
    end

    local listing =
        candidate.Listing

    local filter =
        candidate.Filter
        or {}

    local requestFunction =
        request
        or http_request
        or (
            syn
            and syn.request
        )
        or (
            http
            and http.request
        )

    if type(requestFunction) ~= "function" then

        warn("[HOLY SNIPER LITE] Webhook failed: request function unsupported.")

        return false
    end

    local petName =
        tostring(
            listing.PetName
            or "Unknown"
        )

    local displayWeight =
        FormatLiteNumber(
            listing.DisplayWeight,
            2
        )

    local baseWeight =
        FormatLiteNumber(
            listing.BaseWeight,
            2
        )

    local ageText =
        tostring(
            listing.Age
            or "?"
        )

    local mutationText =
        IsLiteNormalMutation(listing.MutationText)
        and "Normal"
        or CleanText(listing.MutationText)

    local buyerName =
        FormatLiteDiscordSpoilerText(
            ResolveLiteBuyerDisplayTag()
        )

    local sellerName =
        FormatLiteDiscordSpoilerText(
            ResolveLiteUserDisplayTag(
                listing.SellerUserId
            )
        )

    local serverText =
        tostring(game.PlaceId)
        .. ":"
        .. tostring(game.JobId)

    local title =
        petName
        .. " [Age "
        .. ageText
        .. "] ["
        .. displayWeight
        .. " KG]"

    local payload = {
        username =
            "Holy Lite",

        embeds = {
            {
                title =
                    title,

                color =
                    0x67E8F9,

                fields = {
                    {
                        name = "Price",
                        value = tostring(listing.Price or 0),
                        inline = true,
                    },

                    {
                        name = "Mutation",
                        value = mutationText,
                        inline = true,
                    },

                    {
                        name = "Watchlist",
                        value = WatchlistName(candidate.WatchlistId),
                        inline = true,
                    },

                    {
                        name = "Weight",
                        value = displayWeight .. " KG",
                        inline = true,
                    },

                    {
                        name = "Base Weight",
                        value = baseWeight .. " BW",
                        inline = true,
                    },

                    {
                        name = "Priority",
                        value = tostring(filter.Priority or "Normal"),
                        inline = true,
                    },

                    {
                        name = "Trade",
                        value =
                            "Buyer: "
                            .. buyerName
                            .. "\nSeller: "
                            .. sellerName,
                        inline = false,
                    },

                    {
                        name = "Server",
                        value =
                            "```text\n"
                            .. serverText
                            .. "\n```",
                        inline = false,
                    },
                },

                footer = {
                    text = "Holy Lite",
                },

                timestamp =
                    DateTime.now():ToIsoDate(),
            },
        },
    }

    local ok, response =
        pcall(function()

            return requestFunction({
                Url = webhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                },
                Body = HttpService:JSONEncode(payload),
            })
        end)

    if not ok then

        warn(
            "[HOLY SNIPER LITE] Webhook failed:",
            tostring(response)
        )

        return false
    end

    if type(response) == "table" then

        local statusCode =
            tonumber(
                response.StatusCode
                or response.status_code
            )

        if statusCode
        and statusCode ~= 200
        and statusCode ~= 204 then

            warn(
                "[HOLY SNIPER LITE] Webhook bad status:",
                tostring(statusCode),
                tostring(response.Body or response.body or "")
            )

            return false
        end
    end

    print(
        "[HOLY SNIPER LITE] Successful snipe webhook sent:",
        title
    )

    return true
end

_G.HOLY_LITE_SEND_REJECT_WEBHOOK = function(candidate, reason, rawResult, notificationMessage)

    if RuntimeState.WebhookEnabled ~= true then
        return false
    end

    if RuntimeState.WebhookRejectedBuys ~= true then
        return false
    end

    local webhookUrl =
        CleanText(RuntimeState.WebhookURL)

    if webhookUrl == "" then
        return false
    end

    if type(candidate) ~= "table"
    or type(candidate.Listing) ~= "table" then
        return false
    end

    local listing =
        candidate.Listing

    local filter =
        candidate.Filter
        or {}

    local requestFunction =
        request
        or http_request
        or (
            syn
            and syn.request
        )
        or (
            http
            and http.request
        )

    if type(requestFunction) ~= "function" then

        warn("[HOLY SNIPER LITE] Reject webhook failed: request function unsupported.")

        return false
    end

    local petName =
        tostring(
            listing.PetName
            or "Unknown"
        )

    local displayWeight =
        FormatLiteNumber(
            listing.DisplayWeight,
            2
        )

    local baseWeight =
        FormatLiteNumber(
            listing.BaseWeight,
            2
        )

    local ageText =
        tostring(
            listing.Age
            or "?"
        )

    local mutationText =
        IsLiteNormalMutation(listing.MutationText)
        and "Normal"
        or CleanText(listing.MutationText)

    local buyerName =
        FormatLiteDiscordSpoilerText(
            ResolveLiteBuyerDisplayTag()
        )

    local sellerName =
        FormatLiteDiscordSpoilerText(
            ResolveLiteUserDisplayTag(
                listing.SellerUserId
            )
        )

    local reasonText =
        tostring(reason or "Unknown reject")

    local detailText =
        tostring(notificationMessage or "")

    if detailText == "" then
        detailText =
            tostring(rawResult or "No message")
    end

    detailText =
        detailText:sub(1, 900)

    local serverText =
        tostring(game.PlaceId)
        .. ":"
        .. tostring(game.JobId)

    local title =
        petName
        .. " [Age "
        .. ageText
        .. "] ["
        .. displayWeight
        .. " KG]"

    local payload = {
        username =
            "Holy Lite",

        embeds = {
            {
                title =
                    title,

                description =
                    "Buy rejected · Lite build",

                color =
                    0xF59E0B,

                fields = {
                    {
                        name = "Reason",
                        value = reasonText,
                        inline = true,
                    },

                    {
                        name = "Price",
                        value = tostring(listing.Price or 0),
                        inline = true,
                    },

                    {
                        name = "Watchlist",
                        value = WatchlistName(candidate.WatchlistId),
                        inline = true,
                    },

                    {
                        name = "Mutation",
                        value = mutationText,
                        inline = true,
                    },

                    {
                        name = "Weight",
                        value = displayWeight .. " KG",
                        inline = true,
                    },

                    {
                        name = "Base Weight",
                        value = baseWeight .. " BW",
                        inline = true,
                    },

                    {
                        name = "Priority",
                        value = tostring(filter.Priority or "Normal"),
                        inline = true,
                    },

                    {
                        name = "Trade",
                        value =
                            "Buyer: "
                            .. buyerName
                            .. "\nSeller: "
                            .. sellerName,
                        inline = false,
                    },

                    {
                        name = "Details",
                        value =
                            "```text\n"
                            .. detailText
                            .. "\n```",
                        inline = false,
                    },

                    {
                        name = "Server",
                        value =
                            "```text\n"
                            .. serverText
                            .. "\n```",
                        inline = false,
                    },
                },

                footer = {
                    text = "Holy Lite · rejected buy",
                },

                timestamp =
                    DateTime.now():ToIsoDate(),
            },
        },
    }

    local ok, response =
        pcall(function()

            return requestFunction({
                Url = webhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                },
                Body = HttpService:JSONEncode(payload),
            })
        end)

    if not ok then

        warn(
            "[HOLY SNIPER LITE] Reject webhook failed:",
            tostring(response)
        )

        return false
    end

    if type(response) == "table" then

        local statusCode =
            tonumber(
                response.StatusCode
                or response.status_code
            )

        if statusCode
        and statusCode ~= 200
        and statusCode ~= 204 then

            warn(
                "[HOLY SNIPER LITE] Reject webhook bad status:",
                tostring(statusCode),
                tostring(response.Body or response.body or "")
            )

            return false
        end
    end

    print(
        "[HOLY SNIPER LITE] Rejected buy webhook sent:",
        reasonText
    )

    return true
end

_G.HOLY_LITE_SEND_MARKET_SNIPE_WEBHOOK = function(candidate)

    if LITE_MARKET_SNIPE_WEBHOOK_ENABLED ~= true then
        return false
    end

    local webhookUrl =
        CleanText(
            LITE_MARKET_SNIPE_WEBHOOK_URL
        )

    if webhookUrl == "" then
        return false
    end

    if type(candidate) ~= "table"
    or type(candidate.Listing) ~= "table" then
        return false
    end

    local listing =
        candidate.Listing

    local filter =
        candidate.Filter
        or {}

    local requestFunction =
        request
        or http_request
        or (
            syn
            and syn.request
        )
        or (
            http
            and http.request
        )

    if type(requestFunction) ~= "function" then

        warn("[HOLY SNIPER LITE] Market webhook failed: request function unsupported.")

        return false
    end

    local petName =
        tostring(
            listing.PetName
            or "Unknown"
        )

    local displayWeight =
        FormatLiteNumber(
            listing.DisplayWeight,
            2
        )

    local baseWeight =
        FormatLiteNumber(
            listing.BaseWeight,
            2
        )

    local ageText =
        tostring(
            listing.Age
            or "?"
        )

    local mutationText =
        IsLiteNormalMutation(listing.MutationText)
        and "Normal"
        or CleanText(listing.MutationText)

    local inventoryCount =
        CountLiteLocalInventoryPets()

    local inventoryText =
        tostring(inventoryCount)
        .. " pets"

    local buyerName =
        MaskLiteWebhookName(
            ResolveLiteBuyerName()
        )

    local sellerName =
        MaskLiteWebhookName(
            ResolveLiteUsername(
                listing.SellerUserId
            )
        )

    local serverText =
        tostring(game.PlaceId)
        .. ":"
        .. tostring(game.JobId)

    local title =
        petName
        .. " [Age "
        .. ageText
        .. "] ["
        .. displayWeight
        .. " KG]"

    local payload = {
        username =
            "Holy Lite",

        embeds = {
            {
                title =
                    title,

                color =
                    0xFFFFFF,

                fields = {
                    {
                        name = "Price",
                        value = tostring(listing.Price or 0),
                        inline = true,
                    },

                    {
                        name = "Mutation",
                        value = mutationText,
                        inline = true,
                    },

                    {
                        name = "Inventory",
                        value = inventoryText,
                        inline = true,
                    },

                    {
                        name = "Weight",
                        value = displayWeight .. " KG",
                        inline = true,
                    },

                    {
                        name = "Base Weight",
                        value = baseWeight .. " BW",
                        inline = true,
                    },

                    {
                        name = "Priority",
                        value = tostring(filter.Priority or "Normal"),
                        inline = true,
                    },

                    {
                        name = "Trade",
                        value =
                            "Buyer: "
                            .. buyerName
                            .. "\nSeller: "
                            .. sellerName,
                        inline = false,
                    },

                    {
                        name = "Server",
                        value =
                            "```text\n"
                            .. serverText
                            .. "\n```",
                        inline = false,
                    },
                },

                footer = {
                    text = "Holy Lite",
                },

                timestamp =
                    DateTime.now():ToIsoDate(),
            },
        },
    }

    local ok, response =
        pcall(function()

            return requestFunction({
                Url = webhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                },
                Body = HttpService:JSONEncode(payload),
            })
        end)

    if not ok then

        warn(
            "[HOLY SNIPER LITE] Market webhook failed:",
            tostring(response)
        )

        return false
    end

    if type(response) == "table" then

        local statusCode =
            tonumber(
                response.StatusCode
                or response.status_code
            )

        if statusCode
        and statusCode ~= 200
        and statusCode ~= 204 then

            warn(
                "[HOLY SNIPER LITE] Market webhook bad status:",
                tostring(statusCode),
                tostring(response.Body or response.body or "")
            )

            return false
        end
    end

    print(
        "[HOLY SNIPER LITE] Market snipe webhook sent:",
        title
    )

    return true
end

_G.HOLY_LITE_SEND_TOP_SNIPE_WEBHOOK = function(candidate)

    if LITE_TOP_SNIPES_WEBHOOK_ENABLED ~= true then
        return false
    end

    local webhookUrl =
        CleanText(
            LITE_TOP_SNIPES_WEBHOOK_URL
        )

    if webhookUrl == ""
    or webhookUrl == "PASTE_TOP_SNIPES_WEBHOOK_HERE" then
        return false
    end

    if type(candidate) ~= "table"
    or type(candidate.Listing) ~= "table" then
        return false
    end

    local listing =
        candidate.Listing

    if not IsLiteTopSnipesTarget(listing) then
        return false
    end

    local requestFunction =
        request
        or http_request
        or (
            syn
            and syn.request
        )
        or (
            http
            and http.request
        )

    if type(requestFunction) ~= "function" then

        warn("[HOLY SNIPER LITE] Top Snipes webhook failed: request function unsupported.")

        return false
    end

    local petName =
        tostring(
            listing.PetName
            or "Unknown"
        )

    local ageText =
        tostring(
            listing.Age
            or "Unknown"
        )

    local weightText =
        FormatLiteTopSnipeWeightKG(
            listing.DisplayWeight
            or listing.Weight
        )

    local mutationText =
        IsLiteNormalMutation(listing.MutationText)
        and "Normal"
        or CleanText(listing.MutationText)

    if mutationText == ""
    or mutationText == "---"
    or mutationText == "Unknown" then
        mutationText =
            "Normal"
    end

    local title =
        "👑 HOLY LITE SNIPED • "
        .. petName
        .. " [Age "
        .. ageText
        .. "] ["
        .. weightText
        .. "]"

    local embed = {

        title =
            title,

        description =
            "Sniped By: Holy Lite",

        color =
            tonumber(LITE_TOP_SNIPES_WEBHOOK_COLOR)
            or 0xC4B5FD,

        fields = {

            {
                name = "💰 Bought For",
                value =
                    tostring(listing.Price or 0)
                    .. " Tokens",
                inline = true,
            },

            {
                name = "🧬 Mutation",
                value =
                    mutationText,
                inline = true,
            },

            {
                name = "⚖️ BaseWeight",
                value =
                    FormatLiteTopSnipeBaseWeight(
                        listing.BaseWeight
                    ),
                inline = true,
            },
        },

        footer = {
            text = "Holy LITE",
        },

        timestamp =
            DateTime.now():ToIsoDate(),
    }

    ApplyLiteTopSnipeThumbnail(
        embed,
        petName
    )

    local payload = {
        username =
            "Holy LITE",

        embeds = {
            embed,
        },
    }

    local ok, response =
        pcall(function()

            return requestFunction({
                Url = webhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                },
                Body = HttpService:JSONEncode(payload),
            })
        end)

    if not ok then

        warn(
            "[HOLY SNIPER LITE] Top Snipes webhook failed:",
            tostring(response)
        )

        return false
    end

    if type(response) == "table" then

        local statusCode =
            tonumber(
                response.StatusCode
                or response.status_code
            )

        if statusCode
        and statusCode ~= 200
        and statusCode ~= 204 then

            warn(
                "[HOLY SNIPER LITE] Top Snipes webhook bad status:",
                tostring(statusCode),
                tostring(response.Body or response.body or "")
            )

            return false
        end
    end

    print(
        "[HOLY SNIPER LITE] Top Snipes webhook sent:",
        title
    )

    return true
end

function FormatLiteTimingMs(value)

    local number =
        tonumber(value)

    if not number then
        return "N/A"
    end

    return string.format(
        "%.2fms",
        number
    )
end

function FormatLiteTimingBool(value)

    return value == true
        and "Yes"
        or "No"
end

function SendLiteTimingDebugWebhook(candidate, timing)

    if RuntimeState.TimingDebugEnabled ~= true then
        return false
    end

    local webhookUrl =
        CleanText(
            RuntimeState.TimingDebugURL
        )

    if webhookUrl == "" then
        return false
    end

    if type(candidate) ~= "table"
    or type(candidate.Listing) ~= "table" then
        return false
    end

    timing =
        timing
        or {}

    local requestFunction =
        request
        or http_request
        or (
            syn
            and syn.request
        )
        or (
            http
            and http.request
        )

    if type(requestFunction) ~= "function" then

        warn("[HOLY SNIPER LITE] Timing Debug failed: request unsupported.")

        return false
    end

    local listing =
        candidate.Listing

    local modeConfig =
        GetLiteSniperModeConfig()

    local petName =
        tostring(
            listing.PetName
            or "Unknown"
        )

    local resultText =
        tostring(
            timing.Result
            or "Unknown"
        )

    local reasonText =
        tostring(
            timing.Reason
            or "None"
        )

    local pathText =
        tostring(
            timing.Path
            or candidate.Reason
            or "Normal"
        )

    local modeText =
        tostring(
            timing.Mode
            or modeConfig.Mode
            or RuntimeState.SniperMode
            or "Standard"
        )

    local strikeText =
        tostring(
            timing.StrikeIndex
            or 1
        )
        .. "/"
        .. tostring(
            timing.StrikeLimit
            or 1
        )

    local timingText =
        "Cycle: "
        .. FormatLiteTimingMs(timing.CycleMs)
        .. "\nDetect: "
        .. FormatLiteTimingMs(timing.DetectMs)
        .. "\nExtract: "
        .. FormatLiteTimingMs(timing.ExtractMs)
        .. "\nMatch: "
        .. FormatLiteTimingMs(timing.MatchMs)
        .. "\nBuy Invoke: "
        .. FormatLiteTimingMs(timing.BuyInvokeMs)
        .. "\nSilent Buy Path: "
        .. FormatLiteTimingBool(timing.SilentBuyPath)

    local serverText =
        tostring(game.PlaceId)
        .. ":"
        .. tostring(game.JobId)

    local color =
        resultText == "Bought"
        and 0x22C55E
        or 0xF59E0B

    local embed = {
        title =
            "⏱ Holy Lite Timing · "
            .. petName,

        description =
            resultText
            .. " · "
            .. reasonText,

        color =
            color,

        fields = {
            {
                name = "Target",
                value =
                    tostring(petName)
                    .. "\nPrice: "
                    .. tostring(listing.Price or 0)
                    .. "\nWeight: "
                    .. FormatLiteNumber(listing.DisplayWeight, 2)
                    .. " KG",
                inline = true,
            },

            {
                name = "Mode",
                value =
                    modeText
                    .. "\nPath: "
                    .. pathText
                    .. "\nStrike: "
                    .. strikeText,
                inline = true,
            },

            {
                name = "Timing",
                value =
                    "```text\n"
                    .. timingText
                    .. "\n```",
                inline = false,
            },

            {
                name = "Server",
                value =
                    "```text\n"
                    .. serverText
                    .. "\n```",
                inline = false,
            },
        },

        footer = {
            text = "Holy Lite Timing Debug · post-buy only",
        },

        timestamp =
            DateTime.now():ToIsoDate(),
    }

    local payload = {
        username =
            "Holy Lite Timing",

        embeds = {
            embed,
        },
    }

    local ok, response =
        pcall(function()

            return requestFunction({
                Url = webhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                },
                Body = HttpService:JSONEncode(payload),
            })
        end)

    if not ok then

        warn(
            "[HOLY SNIPER LITE] Timing Debug webhook failed:",
            tostring(response)
        )

        return false
    end

    if type(response) == "table" then

        local statusCode =
            tonumber(
                response.StatusCode
                or response.status_code
            )

        if statusCode
        and statusCode ~= 200
        and statusCode ~= 204 then

            warn(
                "[HOLY SNIPER LITE] Timing Debug bad status:",
                tostring(statusCode),
                tostring(response.Body or response.body or "")
            )

            return false
        end
    end

    return true
end

function QueueLiteTimingDebugWebhook(candidate, timing)

    if RuntimeState.TimingDebugEnabled ~= true then

        print("[HOLY SNIPER LITE] Timing Debug skipped: disabled.")

        return false
    end

    if CleanText(RuntimeState.TimingDebugURL) == "" then

        warn("[HOLY SNIPER LITE] Timing Debug skipped: webhook URL empty.")

        return false
    end

    if type(candidate) ~= "table"
    or type(candidate.Listing) ~= "table" then

        warn("[HOLY SNIPER LITE] Timing Debug skipped: invalid candidate.")

        return false
    end

    task.spawn(function()

        local ok, result =
            pcall(function()

                return SendLiteTimingDebugWebhook(
                    candidate,
                    timing
                )
            end)

        if ok ~= true then

            warn(
                "[HOLY SNIPER LITE] Timing Debug crashed:",
                tostring(result)
            )

            return
        end

        if result ~= true then

            warn(
                "[HOLY SNIPER LITE] Timing Debug did not send:",
                tostring(result)
            )

            return
        end

        print("[HOLY SNIPER LITE] Timing Debug webhook sent.")
    end)

    return true
end

function TestLiteMatches()

    local startedAt =
        os.clock()

    local listings =
        LatestLiteListings

    if type(listings) ~= "table"
    or #listings <= 0 then

        RefreshLatestBoothDataNow(
            "match test refresh"
        )

        listings =
            ExtractLiteListings()
    end

    if type(listings) ~= "table" then
        listings =
            {}
    end

    local matches =
        {}

    for _, listing in ipairs(listings) do

        if type(listing) == "table" then

            local priorityPassed, priorityConfig =
                LiteListingMatchesHardcodedPriority(
                    listing
                )

            if priorityPassed == true then

                table.insert(matches, {
                    WatchlistId = 0,
                    PetName = listing.PetName,
                    Listing = listing,
                    Filter = {
                        MaxPrice = priorityConfig.MaxPrice,
                        MinWeight = 0,
                        WeightMode = "Base Weight",
                        Priority = "Hardcoded",
                        MutationMode = "Off",
                        Mutations = {},
                    },
                    Reason = "HardcodedPriority",
                    IsHardcodedPriority = true,
                })
            end

            for watchlistId = 1, 3 do

                local filters =
                    SniperFilterSets[watchlistId]

                if type(filters) == "table" then

                    local filter =
                        filters[listing.PetName]

                    if type(filter) == "table" then

                        local passed, reason =
                            LiteListingMatchesFilter(
                                listing,
                                filter
                            )

                        if passed == true then

                            table.insert(matches, {
                                WatchlistId = watchlistId,
                                PetName = listing.PetName,
                                Listing = listing,
                                Filter = filter,
                                Reason = reason,
                            })
                        end
                    end
                end
            end
        end
    end

    table.sort(matches, function(a, b)

        local aHardcoded =
            a.IsHardcodedPriority == true

        local bHardcoded =
            b.IsHardcodedPriority == true

        if aHardcoded ~= bHardcoded then
            return aHardcoded == true
        end

        local aPriority =
            GetLitePriorityRank(
                a.Filter and a.Filter.Priority
            )

        local bPriority =
            GetLitePriorityRank(
                b.Filter and b.Filter.Priority
            )

        if aPriority ~= bPriority then
            return aPriority > bPriority
        end

        local aPrice =
            tonumber(a.Listing and a.Listing.Price)
            or math.huge

        local bPrice =
            tonumber(b.Listing and b.Listing.Price)
            or math.huge

        if aPrice ~= bPrice then
            return aPrice < bPrice
        end

        local aWeight =
            GetLiteFilterWeight(
                a.Listing,
                a.Filter
            )

        local bWeight =
            GetLiteFilterWeight(
                b.Listing,
                b.Filter
            )

        if aWeight ~= bWeight then
            return aWeight > bWeight
        end

        return tostring(a.PetName or ""):lower()
            < tostring(b.PetName or ""):lower()
    end)

    LatestLiteMatches =
        matches

    RuntimeState.MatchesCount =
        #matches

    RuntimeState.LastMatchMs =
        (os.clock() - startedAt) * 1000

    RuntimeState.Status =
        "Match test done"

    if #matches > 0 then
        RuntimeState.LastMatchText =
            BuildLiteMatchRow(matches[1])
    else
        RuntimeState.LastMatchText =
            "None"
    end

    RefreshLiteRuntimeLabels()

    if #matches > 0 then
    print(
        "[HOLY SNIPER LITE] Best match:",
        BuildLiteMatchRow(matches[1])
    )
end

    print("========== HOLY LITE MATCHES ==========")

    local maxPrint =
        math.min(
            #matches,
            25
        )

    for index = 1, maxPrint do

        print(
            "#"
                .. tostring(index)
                .. " "
                .. BuildLiteMatchRow(matches[index])
        )
    end

    if #matches > maxPrint then
        print("... +" .. tostring(#matches - maxPrint) .. " more")
    end

    print(
        "[HOLY SNIPER LITE] Match test done | listings:",
        tostring(#listings),
        "| matches:",
        tostring(#matches),
        "|",
        string.format("%.2fms", RuntimeState.LastMatchMs)
    )

    print("=======================================")

    return matches
end

function GetFirstLiteBuyableMatch(matches)

    if type(matches) ~= "table" then
        return nil
    end

    for _, match in ipairs(matches) do

        if type(match) == "table"
        and type(match.Listing) == "table"
        and match.Listing.IsFavorite ~= true then

            return match
        end
    end

    return nil
end

function BuildLiteBestCandidateReason(match)

    if type(match) ~= "table"
    or type(match.Filter) ~= "table" then
        return "No candidate."
    end

    return "highest priority, lowest price, highest test weight"
end

function PreviewLiteBestCandidate()

    RefreshLatestBoothDataNow(
        "best candidate refresh"
    )

    ExtractLiteListings()

    local matches =
        TestLiteMatches()

    if type(matches) ~= "table"
    or #matches <= 0 then

        LatestBestCandidate =
            nil

        RuntimeState.Status =
            "No candidate"

        RuntimeState.BestText =
            "None"

        RuntimeState.BestPrice =
            0

        RuntimeState.BestBooth =
            "None"

        RefreshLiteRuntimeLabels()

        warn("[HOLY SNIPER LITE] Best candidate failed: no matching listings.")

        return nil
    end

    local best =
        GetFirstLiteBuyableMatch(
            matches
        )

    if not best then

        LatestBestCandidate =
            nil

        RuntimeState.Status =
            "Only favorite matches"

        RuntimeState.BestText =
            "None"

        RuntimeState.BestPrice =
            0

        RuntimeState.BestBooth =
            "None"

        RuntimeState.BuyStatus =
            "Skipped favorite"

        if matches[1] then
            RuntimeState.LastMatchText =
                BuildLiteMatchRow(matches[1])
        end

        RefreshLiteRuntimeLabels()

        warn("[HOLY SNIPER LITE] Best candidate skipped: all matches are favorited.")

        return nil
    end

    LatestBestCandidate =
        best

    local listing =
        best.Listing

    local filter =
        best.Filter

    RuntimeState.Status =
        "Best candidate ready"

    RuntimeState.BestText =
        tostring(listing.PetName)

    RuntimeState.BestPrice =
        tonumber(listing.Price)
        or 0

    RuntimeState.BestBooth =
        tostring(listing.BoothId or "None")

    if best.IsHardcodedPriority == true then

        RuntimeState.PriorityTarget =
            tostring(listing.PetName)
            .. " · Max "
            .. FormatCompactPrice(
                best.Filter
                and best.Filter.MaxPrice
            )

    else

        RuntimeState.PriorityTarget =
            "None"
    end

    RefreshLiteRuntimeLabels()

    print("========== HOLY LITE BEST CANDIDATE ==========")

    print(
        "WOULD BUY:",
        WatchlistName(best.WatchlistId),
        tostring(listing.PetName)
    )

    print(
        "Price:",
        tostring(listing.Price)
    )

    print(
        "KG:",
        FormatLiteNumber(listing.DisplayWeight, 2)
    )

    print(
        "BW:",
        FormatLiteNumber(listing.BaseWeight, 2)
    )

    print(
        "Age:",
        tostring(listing.Age or "?")
    )

    print(
        "Mutation:",
        (
            IsLiteNormalMutation(listing.MutationText)
            and "Normal"
            or CleanText(listing.MutationText)
        )
    )

    print(
        "Priority:",
        tostring(filter.Priority or "Normal")
    )

    print(
        "Booth:",
        tostring(listing.BoothId or "None")
    )

    print(
        "UID:",
        tostring(listing.UID or "None")
    )

    print(
        "Seller:",
        tostring(listing.SellerUserId or "Unknown")
    )

    print(
        "Reason:",
        BuildLiteBestCandidateReason(best)
    )

    print("==============================================")

    return best
end

function GetLiteFullName(instance)

    if not instance then
        return "nil"
    end

    local ok, result =
        pcall(function()
            return instance:GetFullName()
        end)

    if ok
    and type(result) == "string" then
        return result
    end

    return tostring(instance)
end

function FindLitePath(root, path)

    local current =
        root

    for part in tostring(path or ""):gmatch("[^%.]+") do

        if not current then
            return nil
        end

        current =
            current:FindFirstChild(part)
    end

    return current
end

function IsLiteBuyRemote(instance)

    if not instance then
        return false
    end

    return instance:IsA("RemoteFunction")
        or instance:IsA("RemoteEvent")
end

function ResolveLiteBuyListingRemote()

    if IsLiteBuyRemote(LiteBuyListingRemote) then
        return LiteBuyListingRemote
    end

    local gameEvents =
        ReplicatedStorage:FindFirstChild("GameEvents")

    if not gameEvents then

        RuntimeState.BuyRemotePath =
            "GameEvents missing"

        RuntimeState.BuyStatus =
            "Buy remote missing"

        RefreshLiteRuntimeLabels()

        warn("[HOLY SNIPER LITE] Buy remote resolve failed: GameEvents missing.")

        return nil
    end

    local candidatePaths = {
        "TradeEvents.BuyListing",
        "TradeEvents.TokenRAPs.BuyListing",
        "TradeEvents.PurchaseListing",
        "TradeEvents.TokenRAPs.PurchaseListing",
        "TradeEvents.TokenRAPs.Buy",
        "TradeEvents.Buy",
    }

    for _, path in ipairs(candidatePaths) do

        local instance =
            FindLitePath(
                gameEvents,
                path
            )

        if IsLiteBuyRemote(instance) then

            LiteBuyListingRemote =
                instance

            LiteBuyListingPath =
                "ReplicatedStorage.GameEvents." .. path

            RuntimeState.BuyRemotePath =
                LiteBuyListingPath

            RuntimeState.BuyStatus =
                "Buy remote ready"

            RefreshLiteRuntimeLabels()

            print(
                "[HOLY SNIPER LITE] Buy remote resolved:",
                LiteBuyListingPath,
                "| class:",
                instance.ClassName
            )

            return LiteBuyListingRemote
        end
    end

    local tradeEvents =
        gameEvents:FindFirstChild("TradeEvents")

    if tradeEvents then

        for _, descendant in ipairs(tradeEvents:GetDescendants()) do

            if IsLiteBuyRemote(descendant)
            and (
                descendant.Name == "BuyListing"
                or descendant.Name == "PurchaseListing"
                or descendant.Name == "Buy"
            ) then

                LiteBuyListingRemote =
                    descendant

                LiteBuyListingPath =
                    GetLiteFullName(descendant)

                RuntimeState.BuyRemotePath =
                    LiteBuyListingPath

                RuntimeState.BuyStatus =
                    "Buy remote ready"

                RefreshLiteRuntimeLabels()

                print(
                    "[HOLY SNIPER LITE] Buy remote resolved by scan:",
                    LiteBuyListingPath,
                    "| class:",
                    descendant.ClassName
                )

                return LiteBuyListingRemote
            end
        end
    end

    LiteBuyListingRemote =
        nil

    LiteBuyListingPath =
        nil

    RuntimeState.BuyRemotePath =
        "Not found"

    RuntimeState.BuyStatus =
        "Buy remote missing"

    RefreshLiteRuntimeLabels()

    warn("[HOLY SNIPER LITE] Buy remote missing. Need exact path from main script / Dex.")

    return nil
end

function BuildLiteListingKey(listing)

    if type(listing) ~= "table" then
        return "nil"
    end

    return tostring(listing.BoothId or "None")
        .. "_"
        .. tostring(listing.UID or "None")
end

function InvokeLiteBuyRemote(remote, listing)

    if not IsLiteBuyRemote(remote) then
        return false, "Invalid remote"
    end

    if type(listing) ~= "table" then
        return false, "Invalid listing"
    end

    local uid =
        tostring(listing.UID or "")

    if uid == ""
    or uid == "None" then
        return false, "Missing uid"
    end

    local sellerUserId =
        tonumber(listing.SellerUserId)

    if not sellerUserId
    or sellerUserId <= 0 then
        return false, "Missing seller user id"
    end

    local sellerPlayer =
        Players:GetPlayerByUserId(sellerUserId)

    if not sellerPlayer then
        return false, "Seller player not in server"
    end

    if remote:IsA("RemoteFunction") then

        local ok, result =
            pcall(function()
                return remote:InvokeServer(
                    sellerPlayer,
                    uid
                )
            end)

        if not ok then
            return false, result
        end

        return true, result
    end

    if remote:IsA("RemoteEvent") then

        local ok, result =
            pcall(function()
                remote:FireServer(
                    sellerPlayer,
                    uid
                )
            end)

        if not ok then
            return false, result
        end

        return true, result
    end

    return false, "Unsupported remote class"
end

function BuyLiteBestCandidate()

    if LiteBuyInFlight == true then

        warn("[HOLY SNIPER LITE] Buy blocked: already buying.")

        return false
    end

    local cycleStartedAt =
        os.clock()

    local candidate =
        LatestBestCandidate

    if type(candidate) ~= "table"
    or type(candidate.Listing) ~= "table" then

        candidate =
            PreviewLiteBestCandidate()
    end

    if type(candidate) ~= "table"
    or type(candidate.Listing) ~= "table" then

        RuntimeState.BuyStatus =
            "No best candidate"

        RefreshLiteRuntimeLabels()

        warn("[HOLY SNIPER LITE] Manual buy failed: no best candidate.")

        return false
    end

    return BuyLiteCandidateQuiet(
        candidate,
        {
            SilentBuyPath =
                false,

            Path =
                "Manual Buy",

            CycleStartedAt =
                cycleStartedAt,

            DetectMs =
                0,

            StrikeIndex =
                1,

            StrikeLimit =
                1,
        }
    )
end



function CountLiteTableEntries(source)

    if type(source) ~= "table" then
        return 0
    end

    local count =
        0

    for _ in pairs(source) do
        count =
            count + 1
    end

    return count
end

function CleanupLiteServerMemory()

    local now =
        os.time()

    for jobId, expiresAt in pairs(ServerState.BlockedServers) do

        if tonumber(expiresAt)
        and now >= expiresAt then
            ServerState.BlockedServers[jobId] =
                nil
        end
    end

    while #ServerState.RecentServers > 25 do
        table.remove(ServerState.RecentServers, 1)
    end
end

function IsLiteRecentServer(jobId)

    if ServerState.AvoidRecent ~= true then
        return false
    end

    jobId =
        tostring(jobId or "")

    if jobId == "" then
        return true
    end

    for _, recentJobId in ipairs(ServerState.RecentServers) do

        if tostring(recentJobId) == jobId then
            return true
        end
    end

    return false
end

function AddLiteRecentServer(jobId)

    jobId =
        tostring(jobId or "")

    if jobId == "" then
        return
    end

    for _, recentJobId in ipairs(ServerState.RecentServers) do

        if tostring(recentJobId) == jobId then
            return
        end
    end

    table.insert(
        ServerState.RecentServers,
        jobId
    )

    while #ServerState.RecentServers > 25 do
        table.remove(ServerState.RecentServers, 1)
    end
end

function BlockLiteServer(jobId, minutes)

    jobId =
        tostring(jobId or "")

    if jobId == "" then
        return false
    end

    minutes =
        tonumber(minutes)
        or ServerState.BlockDuration
        or 60

    ServerState.BlockedServers[jobId] =
        os.time() + (math.max(1, minutes) * 60)

    return true
end

function IsLiteBlockedServer(jobId)

    CleanupLiteServerMemory()

    jobId =
        tostring(jobId or "")

    if jobId == "" then
        return true
    end

    return ServerState.BlockedServers[jobId] ~= nil
end

function GetLiteExtraStayRemaining()

    local untilTime =
        tonumber(RuntimeState.ExtraStayUntil)
        or 0

    if untilTime <= 0 then
        return 0
    end

    return math.max(
        0,
        math.ceil(untilTime - os.clock())
    )
end

function RefreshLiteExtraStayInputLabel()

    if not ExtraStayInput then
        return
    end

    local seconds =
        math.clamp(
            tonumber(RuntimeState.ExtraStaySeconds) or 0,
            0,
            120
        )

    SetControlText(
        ExtraStayInput,
        "Extra Stay: " .. tostring(seconds)
    )
end

function AddLiteExtraStayAfterBuy()

    local seconds =
        math.clamp(
            tonumber(RuntimeState.ExtraStaySeconds) or 0,
            0,
            120
        )

    if seconds <= 0 then
        return 0
    end

    local now =
        os.clock()

    local currentUntil =
        tonumber(RuntimeState.ExtraStayUntil)
        or 0

    local baseTime =
        math.max(
            now,
            currentUntil
        )

    RuntimeState.ExtraStayUntil =
        baseTime + seconds

    RefreshLiteServerLabels()

    return math.max(
        0,
        math.ceil(RuntimeState.ExtraStayUntil - now)
    )
end

function FormatLiteAutoHopText()

    if RuntimeState.AutoHop ~= true then
        return "Off"
    end

    local duration =
        math.clamp(
            tonumber(RuntimeState.ScanDuration) or 30,
            1,
            300
        )

    local extraStayRemaining =
        GetLiteExtraStayRemaining()

    if RuntimeState.SniperEnabled == true
    and extraStayRemaining > 0 then

        return "Extra Stay "
            .. tostring(extraStayRemaining)
            .. "s"
    end

    local startedAt =
        tonumber(ServerState.ScanStartedAt)
        or 0

    if RuntimeState.SniperEnabled ~= true
    or startedAt <= 0 then
        return "Ready / " .. tostring(duration) .. "s"
    end

    local elapsed =
        math.max(
            0,
            math.floor(os.clock() - startedAt)
        )

    return tostring(math.min(elapsed, duration))
        .. "s / "
        .. tostring(duration)
        .. "s"
end

function RefreshLiteServerLabels()

    local playerCount =
        0

    pcall(function()
        playerCount =
            #Players:GetPlayers()
    end)

    local maxPlayers =
        tonumber(Players.MaxPlayers)
        or 0

    local autoHopText =
        "Off"

    if type(FormatLiteAutoHopText) == "function" then

        local ok, result =
            pcall(function()
                return FormatLiteAutoHopText()
            end)

        if ok
        and result ~= nil then
            autoHopText =
                tostring(result)
        end
    end

    local recentCount =
        0

    if type(ServerState) == "table"
    and type(ServerState.RecentServers) == "table" then
        recentCount =
            #ServerState.RecentServers
    end

    local blockedCount =
        0

    if type(ServerState) == "table"
    and type(ServerState.BlockedServers) == "table" then

        for _ in pairs(ServerState.BlockedServers) do
            blockedCount =
                blockedCount + 1
        end
    end

    SetControlText(
        ServerJobIdLabel,
        "JobId: " .. tostring(game.JobId)
    )

    SetControlText(
        ServerPlayersLabel,
        "Players: "
            .. tostring(playerCount)
            .. " / "
            .. tostring(maxPlayers)
    )

    SetControlText(
        ServerAutoHopLabel,
        "Auto Hop: " .. tostring(autoHopText)
    )

    SetControlText(
        ServerMemoryLabel,
        "Memory: Recent "
            .. tostring(recentCount)
            .. " · Blocked "
            .. tostring(blockedCount)
    )

    RefreshLitePresenceLabels()
end

function NormalizeLiteServerMode(value)

    value =
        tostring(value or "Fullest Under Max")

    if value == "Recommended"
    or value == "Most Players"
    or value == "Fullest"
    or value == "Fullest Under Max" then
        return "Fullest Under Max"
    end

    if value == "Balanced" then
        return "Balanced"
    end

    if value == "Least Players"
    or value == "Low Player"
    or value == "Low Players" then
        return "Low Player"
    end

    return "Fullest Under Max"
end

function GetLiteSearchPagesForHop()

    local pages =
        math.clamp(
            tonumber(ServerState.SearchPages) or 0,
            0,
            100
        )

    if pages <= 0 then
        return 3
    end

    return pages
end

function GetLiteHopCandidates()

    CleanupLiteServerMemory()

    local candidates =
        {}

    local maxAllowedPlayers =
        math.clamp(
            tonumber(ServerState.MaxPlayers) or 30,
            1,
            100
        )

    local pages =
        GetLiteSearchPagesForHop()

    local cursor =
        nil

    for _ = 1, pages do

        local url =
            "https://games.roblox.com/v1/games/"
            .. tostring(game.PlaceId)
            .. "/servers/Public?sortOrder=Desc&limit=100"

        if cursor then
            url =
                url
                .. "&cursor="
                .. HttpService:UrlEncode(cursor)
        end

        local ok, decoded =
            pcall(function()

                local raw =
                    game:HttpGet(url)

                return HttpService:JSONDecode(raw)
            end)

        if not ok
        or type(decoded) ~= "table"
        or type(decoded.data) ~= "table" then
            break
        end

        for _, server in ipairs(decoded.data) do

            if type(server) == "table"
            and server.id then

                local jobId =
                    tostring(server.id)

                local playing =
                    tonumber(server.playing)
                    or 0

                local maxPlayers =
                    tonumber(server.maxPlayers)
                    or Players.MaxPlayers
                    or 30

                local valid =
                    jobId ~= tostring(game.JobId)
                    and playing < maxPlayers
                    and playing <= maxAllowedPlayers
                    and not IsLiteBlockedServer(jobId)
                    and not IsLiteRecentServer(jobId)
                    and not (
                        TeleportRetryState
                        and TeleportRetryState.BlockedServers
                        and TeleportRetryState.BlockedServers[jobId] == true
                    )

                if valid then

                    table.insert(candidates, {
                        JobId = jobId,
                        Playing = playing,
                        MaxPlayers = maxPlayers,
                    })
                end
            end
        end

        cursor =
            decoded.nextPageCursor

        if not cursor
        or cursor == "" then
            break
        end
    end

    local mode =
        NormalizeLiteServerMode(
            ServerState.Mode
        )

    ServerState.Mode =
        mode

    if mode == "Balanced" then

        local targetPlayers =
            math.max(
                3,
                math.floor(maxAllowedPlayers * 0.70 + 0.5)
            )

        table.sort(candidates, function(a, b)

            local aDistance =
                math.abs(
                    (tonumber(a.Playing) or 0)
                    - targetPlayers
                )

            local bDistance =
                math.abs(
                    (tonumber(b.Playing) or 0)
                    - targetPlayers
                )

            if aDistance ~= bDistance then
                return aDistance < bDistance
            end

            if a.Playing ~= b.Playing then
                return a.Playing > b.Playing
            end

            return tostring(a.JobId) < tostring(b.JobId)
        end)

    elseif mode == "Low Player" then

        table.sort(candidates, function(a, b)

            local aPlaying =
                tonumber(a.Playing)
                or 0

            local bPlaying =
                tonumber(b.Playing)
                or 0

            local aRealServer =
                aPlaying >= 3

            local bRealServer =
                bPlaying >= 3

            if aRealServer ~= bRealServer then
                return aRealServer == true
            end

            if aPlaying ~= bPlaying then
                return aPlaying < bPlaying
            end

            return tostring(a.JobId) < tostring(b.JobId)
        end)

    else

        table.sort(candidates, function(a, b)

            local aPlaying =
                tonumber(a.Playing)
                or 0

            local bPlaying =
                tonumber(b.Playing)
                or 0

            if aPlaying ~= bPlaying then
                return aPlaying > bPlaying
            end

            return tostring(a.JobId) < tostring(b.JobId)
        end)
    end

    return candidates
end

function LiteHopToServer(reason)

    if ServerState.IsHopping == true then
        return false
    end

    local player =
        Players.LocalPlayer

    if not player then

        ServerState.LastError =
            "LocalPlayer missing"

        RefreshLiteServerLabels()

        warn("[HOLY SNIPER LITE] Hop failed: LocalPlayer missing.")

        return false
    end

    ServerState.IsHopping =
        true

    RuntimeState.Status =
        "Hopping"

    RefreshLiteRuntimeLabels()
    RefreshLiteServerLabels()

    task.spawn(function()

        AddLiteRecentServer(game.JobId)

        local candidates =
            GetLiteHopCandidates()

        local selected =
            candidates[1]

        if not selected then

            ServerState.IsHopping =
                false

            ServerState.ScanStartedAt =
                os.clock()

            ServerState.LastHop =
                "Failed"

            ServerState.LastTarget =
                "None"

            ServerState.LastError =
                "No valid server"

            RuntimeState.Status =
                "Hop failed"

            RefreshLiteRuntimeLabels()
            RefreshLiteServerLabels()

            warn("[HOLY SNIPER LITE] Hop failed: no valid server found.")

            return
        end

        AddLiteRecentServer(selected.JobId)

        ServerState.LastHop =
            tostring(reason or "manual")

        ServerState.LastTarget =
            tostring(selected.JobId)

        ServerState.LastError =
            "None"

        if TeleportRetryState then

            TeleportRetryState.LastTarget =
                tostring(selected.JobId)

            TeleportRetryState.BlockedServers[
                tostring(selected.JobId)
            ] =
                true
        end

        print(
            "[HOLY SNIPER LITE] Hopping | reason:",
            tostring(reason or "manual"),
            "| target:",
            tostring(selected.JobId),
            "| players:",
            tostring(selected.Playing) .. "/" .. tostring(selected.MaxPlayers)
        )

        local ok, err =
            pcall(function()

                TeleportService:TeleportToPlaceInstance(
                    game.PlaceId,
                    selected.JobId,
                    player
                )
            end)

        if not ok then

            ServerState.IsHopping =
                false

            ServerState.ScanStartedAt =
                os.clock()

            ServerState.LastHop =
                "Failed"

            ServerState.LastError =
                tostring(err)

            RuntimeState.Status =
                "Hop failed"

            RefreshLiteRuntimeLabels()
            RefreshLiteServerLabels()

            warn(
                "[HOLY SNIPER LITE] Hop failed:",
                tostring(err)
            )

            return
        end

        task.delay(8, function()

            if ServerState then

                ServerState.IsHopping =
                    false
            end

            RefreshLiteServerLabels()
        end)
    end)

    return true
end

function ForceLiteTeleportRetry(reason)

    if not TeleportRetryState then
        return false
    end

    if TeleportRetryState.Retrying == true then
        return false
    end

    TeleportRetryState.Retrying =
        true

    TeleportRetryState.Attempt =
        0

    task.spawn(function()

        local player =
            Players.LocalPlayer

        if not player then

            TeleportRetryState.Retrying =
                false

            return
        end

        ServerState.IsHopping =
            false

        if TeleportRetryState.LastTarget then

            TeleportRetryState.BlockedServers[
                tostring(TeleportRetryState.LastTarget)
            ] =
                true
        end

        while IsHolyLiteCurrentRun()
        and TeleportRetryState.Attempt
            < TeleportRetryState.MaxAttempts
        do

            TeleportRetryState.Attempt =
                TeleportRetryState.Attempt + 1

            local candidates =
                GetLiteHopCandidates()

            if type(candidates) ~= "table"
            or #candidates <= 0 then

                warn("[HOLY SNIPER LITE] Retry found no valid server. Clearing retry blocks.")

                ClearLiteTable(
                    TeleportRetryState.BlockedServers
                )

                task.wait(1)

                continue
            end

            local selected =
                candidates[1]

            if type(selected) ~= "table"
            or not selected.JobId then

                task.wait(1)

                continue
            end

            local target =
                tostring(selected.JobId)

            TeleportRetryState.LastTarget =
                target

            TeleportRetryState.BlockedServers[target] =
                true

            ServerState.IsHopping =
                true

            ServerState.LastHop =
                "Retry"

            ServerState.LastTarget =
                target

            ServerState.LastError =
                "Retrying: " .. tostring(reason or "Teleport failed")

            RuntimeState.Status =
                "Retrying hop"

            RefreshLiteRuntimeLabels()
            RefreshLiteServerLabels()

            print(
                string.format(
                    "[HOLY SNIPER LITE] Teleport retry %s/%s -> %s | %s",
                    tostring(TeleportRetryState.Attempt),
                    tostring(TeleportRetryState.MaxAttempts),
                    tostring(target),
                    tostring(reason or "Teleport failed")
                )
            )

            pcall(function()

                TeleportService:TeleportToPlaceInstance(
                    game.PlaceId,
                    target,
                    player
                )
            end)

            task.wait(
                tonumber(TeleportRetryState.RetryDelay)
                or 0.35
            )
        end

        ServerState.IsHopping =
            false

        ServerState.ScanStartedAt =
            os.clock()

        ServerState.LastHop =
            "Failed"

        ServerState.LastError =
            "Retry max attempts reached"

        RuntimeState.Status =
            "Hop retry failed"

        RefreshLiteRuntimeLabels()
        RefreshLiteServerLabels()

        warn("[HOLY SNIPER LITE] Teleport retry max attempts reached.")

        TeleportRetryState.Retrying =
            false
    end)

    return true
end

do
    local root =
        type(getgenv) == "function"
        and getgenv()
        or _G

    if root.HOLY_LITE_TELEPORT_FAILED_CONNECTION then

        pcall(function()
            root.HOLY_LITE_TELEPORT_FAILED_CONNECTION:Disconnect()
        end)
    end

    root.HOLY_LITE_TELEPORT_FAILED_CONNECTION =
        TeleportService.TeleportInitFailed:Connect(function(
            failedPlayer,
            teleportResult,
            errorMessage,
            placeId
        )

            if failedPlayer ~= LocalPlayer then
                return
            end

            local resultName =
                teleportResult
                and teleportResult.Name
                or "Unknown"

            warn(
                string.format(
                    "[HOLY SNIPER LITE] Teleport failed -> %s | %s",
                    tostring(resultName),
                    tostring(errorMessage)
                )
            )

            ServerState.IsHopping =
                false

            ServerState.LastHop =
                "Failed"

            ServerState.LastError =
                tostring(resultName)
                    .. " | "
                    .. tostring(errorMessage)

            RuntimeState.Status =
                "Teleport failed"

            RefreshLiteRuntimeLabels()
            RefreshLiteServerLabels()

            if GatewayState
            and tonumber(GatewayState.ExactOnlyUntil or 0)
            and os.clock() <= tonumber(GatewayState.ExactOnlyUntil or 0) then

                GatewayState.ExactOnlyUntil =
                    0

                GatewayState.StatusText =
                    "Join failed · " .. tostring(resultName)

                GatewayState.PreviewText =
                    "Exact server failed. No random fallback."

                if type(RefreshLiteGatewayVisuals) == "function" then
                    RefreshLiteGatewayVisuals()
                end

                warn(
                    "[HOLY SNIPER LITE] Exact gateway join failed. Random retry blocked:",
                    tostring(resultName),
                    "|",
                    tostring(errorMessage)
                )

                return
            end

            ForceLiteTeleportRetry(
                resultName
            )
        end)
end

--==================================================
-- [8.75] HARD-CODED SESSION PROTECTION
-- Anti-AFK + Roblox disconnect prompt recovery.
-- Isolated from sniper, listings, webhooks, and market tracker.
--==================================================

local LITE_SESSION_PROTECTION_ENABLED =
    true

local LiteSessionProtectionState = {
    AntiAfkLoaded = false,
    PromptWatcherLoaded = false,

    LastPromptText = "",
    LastPromptAt = 0,

    LastReconnectAt = 0,
    ReconnectCooldown = 8,

    LastFallbackTeleportAt = 0,
    FallbackTeleportCooldown = 12,
}

function DoLiteAntiAfkPulse()

    if LITE_SESSION_PROTECTION_ENABLED ~= true then
        return false
    end

    local ok, err =
        pcall(function()

            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(
                Vector2.new(0, 0)
            )
        end)

    if ok ~= true then

        warn(
            "[HOLY SNIPER LITE] Anti AFK pulse failed:",
            tostring(err)
        )

        return false
    end

    print("[HOLY SNIPER LITE] Anti AFK pulse.")

    return true
end

function StartLiteAntiAfkProtection()

    if LITE_SESSION_PROTECTION_ENABLED ~= true then
        return false
    end

    local root =
        type(getgenv) == "function"
        and getgenv()
        or _G

    if root.HOLY_LITE_ANTI_AFK_CONNECTION then

        pcall(function()
            root.HOLY_LITE_ANTI_AFK_CONNECTION:Disconnect()
        end)

        root.HOLY_LITE_ANTI_AFK_CONNECTION =
            nil
    end

    root.HOLY_LITE_ANTI_AFK_CONNECTION =
        LocalPlayer.Idled:Connect(function()

            DoLiteAntiAfkPulse()
        end)

    LiteSessionProtectionState.AntiAfkLoaded =
        true

    print("[HOLY SNIPER LITE] Anti AFK loaded.")

    return true
end

function GetLiteRobloxErrorPrompt()

    local robloxGui =
        CoreGui:FindFirstChild("RobloxPromptGui")

    if not robloxGui then
        return nil, nil
    end

    local promptOverlay =
        robloxGui:FindFirstChild("promptOverlay")

    if not promptOverlay then
        return nil, nil
    end

    local errorPrompt =
        promptOverlay:FindFirstChild("ErrorPrompt")

    if not errorPrompt then
        return nil, nil
    end

    local messageArea =
        errorPrompt:FindFirstChild("MessageArea")

    if not messageArea then
        return errorPrompt, nil
    end

    local errorFrame =
        messageArea:FindFirstChild("ErrorFrame")

    if not errorFrame then
        return errorPrompt, nil
    end

    local errorMessage =
        errorFrame:FindFirstChild("ErrorMessage")

    if errorMessage
    and errorMessage:IsA("TextLabel") then

        local text =
            CleanText(errorMessage.Text)

        if text ~= "" then
            return errorPrompt, text
        end
    end

    return errorPrompt, nil
end

function ClassifyLiteRobloxErrorPrompt(text)

    local lower =
        string.lower(
            tostring(text or "")
        )

    if lower == "" then
        return nil
    end

    if lower:find("error code: 278", 1, true)
    or lower:find("being idle", 1, true) then

        return "Idle disconnect"
    end

    if lower:find("error code: 288", 1, true)
    or lower:find("server has shut down", 1, true)
    or lower:find("disconnected from the experience", 1, true) then

        return "Server shutdown"
    end

    if lower:find("error code: 267", 1, true)
    or lower:find("you have been kicked", 1, true)
    or lower:find("moderators", 1, true) then

        return "Kick disconnect"
    end

    if lower:find("server is full", 1, true)
    or lower:find("error code: 772", 1, true)
    or lower:find("teleport failed", 1, true)
    or lower:find("please try again", 1, true) then

        return "Teleport failed"
    end

    if lower:find("reconnect", 1, true)
    and lower:find("disconnected", 1, true) then

        return "Disconnected"
    end

    return nil
end

function FindLiteReconnectButton(errorPrompt)

    if not errorPrompt then
        return nil
    end

    for _, descendant in ipairs(errorPrompt:GetDescendants()) do

        if descendant:IsA("GuiButton") then

            local buttonText =
                CleanText(
                    descendant.Text
                    or descendant.Name
                )

            local lower =
                string.lower(buttonText)

            if lower:find("reconnect", 1, true) then
                return descendant
            end
        end
    end

    return nil
end

function ClickLiteReconnectButton(errorPrompt)

    local button =
        FindLiteReconnectButton(
            errorPrompt
        )

    if not button then
        return false
    end

    local ok =
        pcall(function()
            button:Activate()
        end)

    if ok == true then
        return true
    end

    if type(firesignal) == "function" then

        local fireOk =
            pcall(function()
                firesignal(
                    button.MouseButton1Click
                )
            end)

        if fireOk == true then
            return true
        end
    end

    return false
end

function LiteFallbackTeleport(reason)

    if LITE_SESSION_PROTECTION_ENABLED ~= true then
        return false
    end

    local now =
        os.clock()

    if now - tonumber(LiteSessionProtectionState.LastFallbackTeleportAt or 0)
        < tonumber(LiteSessionProtectionState.FallbackTeleportCooldown or 12) then

        return false
    end

    LiteSessionProtectionState.LastFallbackTeleportAt =
        now

    local player =
        Players.LocalPlayer

    if not player then
        return false
    end

    print(
        "[HOLY SNIPER LITE] Session fallback teleport:",
        tostring(reason or "disconnect")
    )

    local ok, err =
        pcall(function()

            TeleportService:Teleport(
                game.PlaceId,
                player
            )
        end)

    if ok ~= true then

        warn(
            "[HOLY SNIPER LITE] Session fallback teleport failed:",
            tostring(err)
        )

        return false
    end

    return true
end

function HandleLiteRobloxErrorPrompt(errorPrompt, text)

    local reason =
        ClassifyLiteRobloxErrorPrompt(
            text
        )

    if not reason then
        return false
    end

    local now =
        os.clock()

    if text == LiteSessionProtectionState.LastPromptText
    and now - tonumber(LiteSessionProtectionState.LastPromptAt or 0) < 3 then

        return false
    end

    LiteSessionProtectionState.LastPromptText =
        text

    LiteSessionProtectionState.LastPromptAt =
        now

    if now - tonumber(LiteSessionProtectionState.LastReconnectAt or 0)
        < tonumber(LiteSessionProtectionState.ReconnectCooldown or 8) then

        return false
    end

    LiteSessionProtectionState.LastReconnectAt =
        now

    if ServerState then
        ServerState.IsHopping =
            false

        ServerState.LastHop =
            "Reconnect"

        ServerState.LastError =
            reason
    end

    if RuntimeState then
        RuntimeState.Status =
            "Reconnecting"
    end

    if type(RefreshLiteRuntimeLabels) == "function" then
        RefreshLiteRuntimeLabels()
    end

    if type(RefreshLiteServerLabels) == "function" then
        RefreshLiteServerLabels()
    end

    warn(
        "[HOLY SNIPER LITE] Roblox prompt detected:",
        reason,
        "|",
        tostring(text)
    )

    local clicked =
        ClickLiteReconnectButton(
            errorPrompt
        )

    if clicked == true then

        print(
            "[HOLY SNIPER LITE] Clicked Reconnect button:",
            reason
        )

        return true
    end

    if reason == "Teleport failed"
    and type(ForceLiteTeleportRetry) == "function" then

        ForceLiteTeleportRetry(
            reason
        )

        return true
    end

    LiteFallbackTeleport(
        reason
    )

    return true
end

function StartLiteDisconnectPromptWatcher()

    if LITE_SESSION_PROTECTION_ENABLED ~= true then
        return false
    end

    local root =
        type(getgenv) == "function"
        and getgenv()
        or _G

    if root.HOLY_LITE_DISCONNECT_PROMPT_WATCHER then
        return false
    end

    root.HOLY_LITE_DISCONNECT_PROMPT_WATCHER =
        true

    LiteSessionProtectionState.PromptWatcherLoaded =
        true

    task.spawn(function()

        print("[HOLY SNIPER LITE] Disconnect prompt watcher loaded.")

        while IsHolyLiteCurrentRun()
        and root.HOLY_LITE_DISCONNECT_PROMPT_WATCHER == true do

            task.wait(1)

            local errorPrompt, text =
                GetLiteRobloxErrorPrompt()

            if errorPrompt
            and text
            and text ~= "" then

                pcall(function()

                    HandleLiteRobloxErrorPrompt(
                        errorPrompt,
                        text
                    )
                end)
            end
        end

        root.HOLY_LITE_DISCONNECT_PROMPT_WATCHER =
            false

        print("[HOLY SNIPER LITE] Disconnect prompt watcher stopped.")
    end)

    return true
end

StartLiteAntiAfkProtection()
StartLiteDisconnectPromptWatcher()

--==================================================
-- [8.8] EXACT SERVER GATEWAY
--==================================================

function ShortLiteJobId(jobId)

    jobId =
        tostring(jobId or "")

    if #jobId <= 12 then
        return jobId
    end

    return jobId:sub(1, 8)
        .. "..."
        .. jobId:sub(#jobId - 3, #jobId)
end

function GetLitePlaceName(placeId)

    placeId =
        tonumber(placeId)

    if placeId == TRADING_WORLD_PLACE_ID then
        return "Trade World"
    end

    if placeId == GROW_A_GARDEN_PLACE_ID then
        return "Garden World"
    end

    if placeId == game.PlaceId then
        return "Current Place"
    end

    return "Place " .. tostring(placeId or "?")
end

function ParseLiteGatewayTarget(text)

    text =
        CleanText(text)

    if text == "" then
        return nil, "Paste a server link."
    end

    local placeId =
        text:match("[?&]placeId=(%d+)")

    local jobId =
        text:match("[?&]gameInstanceId=([^&%s]+)")
        or text:match("[?&]gameId=([^&%s]+)")

    if not placeId
    or not jobId then

        local colonPlaceId, colonJobId =
            text:match("^(%d+)%s*:%s*([%w%-]+)$")

        placeId =
            colonPlaceId

        jobId =
            colonJobId
    end

    placeId =
        tonumber(placeId)

    jobId =
        CleanText(jobId)

    if not placeId
    or placeId <= 0 then
        return nil, "Invalid input · missing placeId."
    end

    if jobId == ""
    or #jobId < 10 then
        return nil, "Invalid input · missing JobId."
    end

    return {
        PlaceId = placeId,
        JobId = jobId,
        Raw = text,
    }, nil
end

function FormatLiteGatewayPreview(parsed, errorText)

    if errorText then
        return tostring(errorText)
    end

    if type(parsed) ~= "table" then
        return "Paste a server link."
    end

    return "● Valid · "
        .. GetLitePlaceName(parsed.PlaceId)
        .. "\nJob: "
        .. ShortLiteJobId(parsed.JobId)
end

function RefreshLiteGatewayVisuals()

    local parsed, errorText =
        ParseLiteGatewayTarget(
            GatewayState.TargetText
        )

    if GatewayState.TargetText == "" then
        GatewayState.PreviewText =
            "Paste a server link."

    else

        GatewayState.PreviewText =
            FormatLiteGatewayPreview(
                parsed,
                errorText
            )
    end

    SetControlText(
        GatewayPreviewLabel,
        GatewayState.PreviewText
    )

    if GatewayHudInput
    and GatewayHudInput.Text ~= GatewayState.TargetText then

        pcall(function()
            GatewayHudInput.Text =
                GatewayState.TargetText
        end)
    end

    if GatewayHudStatusLabel then

        pcall(function()
            GatewayHudStatusLabel.Text =
                GatewayState.StatusText
                or GatewayState.PreviewText
                or "Ready"
        end)
    end
end

function SetLiteGatewayTargetText(text)

    GatewayState.TargetText =
        tostring(text or "")

    SetControlValue(
        GatewayTargetInput,
        GatewayState.TargetText
    )

    RefreshLiteGatewayVisuals()
end

function CopyLiteCurrentServerToClipboard()

    local clipboard =
        setclipboard
        or toclipboard
        or set_clipboard

    if type(clipboard) ~= "function" then

        GatewayState.StatusText =
            "Clipboard unsupported."

        RefreshLiteGatewayVisuals()

        warn("[HOLY SNIPER LITE] Gateway copy failed: clipboard unsupported.")

        return false
    end

    local payload =
        tostring(game.PlaceId)
        .. ":"
        .. tostring(game.JobId)

    pcall(function()
        clipboard(payload)
    end)

    GatewayState.LastTargetText =
        payload

    GatewayState.StatusText =
        "Copied current server."

    RefreshLiteGatewayVisuals()

    print("[HOLY SNIPER LITE] Gateway copied current server:", payload)

    return true
end

function ResetLiteGatewayTransientInputAfterLoad()

    if type(GatewayState) ~= "table" then
        return false
    end

    GatewayState.TargetText =
        ""

    GatewayState.LastTargetText =
        ""

    GatewayState.PreviewText =
        "Paste a server link."

    GatewayState.StatusText =
        "Paste a server link."

    SetControlValue(
        GatewayTargetInput,
        ""
    )

    if GatewayHudInput then

        pcall(function()
            GatewayHudInput.Text =
                ""
        end)
    end

    SetControlText(
        GatewayPreviewLabel,
        GatewayState.PreviewText
    )

    if GatewayHudStatusLabel then

        pcall(function()
            GatewayHudStatusLabel.Text =
                GatewayState.StatusText
        end)
    end

    print("[HOLY SNIPER LITE] Gateway transient input cleared after config load.")

    return true
end

function ClearLiteGatewayInputOnly(statusText)

    GatewayState.TargetText =
        ""

    GatewayState.PreviewText =
        "Paste a server link."

    GatewayState.StatusText =
        tostring(statusText or GatewayState.StatusText or "Ready")

    SetControlValue(
        GatewayTargetInput,
        ""
    )

    if GatewayHudInput then

        pcall(function()
            GatewayHudInput.Text =
                ""
        end)
    end

    SetControlText(
        GatewayPreviewLabel,
        GatewayState.PreviewText
    )

    if GatewayHudStatusLabel then

        pcall(function()
            GatewayHudStatusLabel.Text =
                GatewayState.StatusText
        end)
    end

    return true
end

function ClearLiteGatewayTarget()

    GatewayState.TargetText =
        ""

    GatewayState.StatusText =
        "Paste a server link."

    GatewayState.PreviewText =
        "Paste a server link."

    SetControlValue(
        GatewayTargetInput,
        ""
    )

    if GatewayHudInput then

        pcall(function()
            GatewayHudInput.Text =
                ""
        end)
    end

    RefreshLiteGatewayVisuals()

    print("[HOLY SNIPER LITE] Gateway target cleared.")
end

function UseLiteLastGatewayTarget()

    if CleanText(GatewayState.LastTargetText) == "" then

        GatewayState.StatusText =
            "No last target."

        RefreshLiteGatewayVisuals()

        warn("[HOLY SNIPER LITE] Gateway Use Last failed: no last target.")

        return false
    end

    SetLiteGatewayTargetText(
        GatewayState.LastTargetText
    )

    GatewayState.StatusText =
        "Loaded last target."

    RefreshLiteGatewayVisuals()

    return true
end

function JoinLiteExactGatewayTarget()

    local parsed, errorText =
        ParseLiteGatewayTarget(
            GatewayState.TargetText
        )

    if not parsed then

        GatewayState.StatusText =
            tostring(errorText or "Invalid input.")

        RefreshLiteGatewayVisuals()

        warn(
            "[HOLY SNIPER LITE] Gateway join blocked:",
            tostring(errorText or "invalid input")
        )

        return false
    end

    local player =
        Players.LocalPlayer

    if not player then

        GatewayState.StatusText =
            "LocalPlayer missing."

        RefreshLiteGatewayVisuals()

        warn("[HOLY SNIPER LITE] Gateway join failed: LocalPlayer missing.")

        return false
    end

    GatewayState.LastTargetText =
        tostring(parsed.PlaceId)
        .. ":"
        .. tostring(parsed.JobId)

    GatewayState.StatusText =
        "Joining exact server..."

    ClearLiteGatewayInputOnly(
        "Joining exact server..."
    )

    GatewayState.ExactOnlyUntil =
        os.clock() + 20

    ServerState.IsHopping =
        true

    ServerState.LastHop =
        "Gateway"

    ServerState.LastTarget =
        tostring(parsed.JobId)

    ServerState.LastError =
        "None"

    RuntimeState.Status =
        "Gateway joining"

    RefreshLiteRuntimeLabels()
    RefreshLiteServerLabels()

    print(
        "[HOLY SNIPER LITE] Gateway exact join:",
        tostring(parsed.PlaceId),
        tostring(parsed.JobId)
    )

    local ok, err =
        pcall(function()

            TeleportService:TeleportToPlaceInstance(
                parsed.PlaceId,
                parsed.JobId,
                player
            )
        end)

    if not ok then

        GatewayState.ExactOnlyUntil =
            0

        GatewayState.StatusText =
            "Join failed."

        GatewayState.PreviewText =
            "Exact server failed. No random fallback."

        ServerState.IsHopping =
            false

        ServerState.LastHop =
            "Gateway failed"

        ServerState.LastError =
            tostring(err)

        RuntimeState.Status =
            "Gateway failed"

        RefreshLiteGatewayVisuals()
        RefreshLiteRuntimeLabels()
        RefreshLiteServerLabels()

        warn(
            "[HOLY SNIPER LITE] Gateway exact join failed:",
            tostring(err)
        )

        return false
    end

    task.delay(8, function()

        if GatewayState
        and tonumber(GatewayState.ExactOnlyUntil or 0)
        and os.clock() > tonumber(GatewayState.ExactOnlyUntil or 0) then

            GatewayState.ExactOnlyUntil =
                0
        end

        if ServerState then
            ServerState.IsHopping =
                false
        end

        RefreshLiteServerLabels()
    end)

    return true
end

function RejoinLiteExactCurrentServer()

    GatewayState.LastTargetText =
        tostring(game.PlaceId)
        .. ":"
        .. tostring(game.JobId)

    ClearLiteGatewayInputOnly(
        "Rejoining exact server..."
    )

    local player =
        Players.LocalPlayer

    if not player then

        GatewayState.StatusText =
            "LocalPlayer missing."

        RefreshLiteGatewayVisuals()

        warn("[HOLY SNIPER LITE] Gateway rejoin failed: LocalPlayer missing.")

        return false
    end

    ServerState.IsHopping =
        true

    ServerState.LastHop =
        "Gateway Rejoin"

    ServerState.LastTarget =
        tostring(game.JobId)

    ServerState.LastError =
        "None"

    RuntimeState.Status =
        "Gateway rejoining"

    RefreshLiteRuntimeLabels()
    RefreshLiteServerLabels()

    local ok, err =
        pcall(function()

            TeleportService:TeleportToPlaceInstance(
                game.PlaceId,
                game.JobId,
                player
            )
        end)

    if not ok then

        GatewayState.StatusText =
            "Rejoin failed."

        ServerState.IsHopping =
            false

        ServerState.LastHop =
            "Gateway rejoin failed"

        ServerState.LastError =
            tostring(err)

        RuntimeState.Status =
            "Teleport failed"

        RefreshLiteGatewayVisuals()
        RefreshLiteRuntimeLabels()
        RefreshLiteServerLabels()

        warn(
            "[HOLY SNIPER LITE] Gateway rejoin failed:",
            tostring(err)
        )

        return false
    end

    return true
end

function DestroyLiteGatewayHud()

    if GatewayHudGui then

        pcall(function()
            GatewayHudGui:Destroy()
        end)
    end

    GatewayHudGui =
        nil

    GatewayHudFrame =
        nil

    GatewayHudInput =
        nil

    GatewayHudStatusLabel =
        nil
end

function CreateLiteGatewayHud()

    if GatewayHudGui then
        return GatewayHudGui
    end

    local playerGui =
        LocalPlayer
        and (
            LocalPlayer:FindFirstChildOfClass("PlayerGui")
            or LocalPlayer:WaitForChild("PlayerGui", 5)
        )

    if not playerGui then
        return nil
    end

    local gui =
        Instance.new("ScreenGui")

    gui.Name =
        "HolyLiteGatewayHud"

    gui.ResetOnSpawn =
        false

    gui.IgnoreGuiInset =
        true

    gui.Parent =
        playerGui

    local frame =
        Instance.new("Frame")

    frame.Name =
        "Gateway"

    frame.Size =
        UDim2.fromOffset(280, 118)

    frame.Position =
        UDim2.fromOffset(24, 180)

    frame.BackgroundColor3 =
        Color3.fromRGB(8, 8, 14)

    frame.BorderSizePixel =
        0

    frame.Active =
        true

    frame.Draggable =
        true

    frame.Parent =
        gui

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 8)

    corner.Parent =
        frame

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        Color3.fromRGB(88, 64, 140)

    stroke.Thickness =
        1

    stroke.Transparency =
        0.1

    stroke.Parent =
        frame

    local title =
        Instance.new("TextLabel")

    title.Name =
        "Title"

    title.BackgroundTransparency =
        1

    title.Position =
        UDim2.fromOffset(10, 6)

    title.Size =
        UDim2.fromOffset(220, 20)

    title.Font =
        Enum.Font.GothamBold

    title.TextSize =
        13

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.TextColor3 =
        Color3.fromRGB(232, 230, 240)

    title.Text =
        "Holy LITE Gateway"

    title.Parent =
        frame

    local close =
        Instance.new("TextButton")

    close.Name =
        "Close"

    close.BackgroundTransparency =
        1

    close.Position =
        UDim2.fromOffset(246, 4)

    close.Size =
        UDim2.fromOffset(28, 22)

    close.Font =
        Enum.Font.GothamBold

    close.TextSize =
        14

    close.TextColor3 =
        Color3.fromRGB(196, 181, 253)

    close.Text =
        "×"

    close.Parent =
        frame

    close.MouseButton1Click:Connect(function()

        GatewayState.HudEnabled =
            false

        SetControlValue(
            GatewayHudToggle,
            false
        )

        DestroyLiteGatewayHud()

        MarkConfigDirty()
    end)

    local input =
        Instance.new("TextBox")

    input.Name =
        "Target"

    input.Position =
        UDim2.fromOffset(10, 32)

    input.Size =
        UDim2.fromOffset(260, 26)

    input.BackgroundColor3 =
        Color3.fromRGB(15, 12, 24)

    input.BorderSizePixel =
        0

    input.ClearTextOnFocus =
        false

    input.Font =
        Enum.Font.GothamMedium

    input.TextSize =
        12

    input.TextXAlignment =
        Enum.TextXAlignment.Left

    input.TextColor3 =
        Color3.fromRGB(232, 230, 240)

    input.PlaceholderColor3 =
        Color3.fromRGB(125, 116, 145)

    input.PlaceholderText =
        "placeId:jobId or link..."

    input.Text =
        GatewayState.TargetText

    input.Parent =
        frame

    local inputCorner =
        Instance.new("UICorner")

    inputCorner.CornerRadius =
        UDim.new(0, 5)

    inputCorner.Parent =
        input

    input.FocusLost:Connect(function()

        GatewayState.TargetText =
            tostring(input.Text or "")

        SetControlValue(
            GatewayTargetInput,
            GatewayState.TargetText
        )

        GatewayState.StatusText =
            GatewayState.TargetText == ""
            and "Paste a server link."
            or "Target updated."

        RefreshLiteGatewayVisuals()
    end)

    local status =
        Instance.new("TextLabel")

    status.Name =
        "Status"

    status.BackgroundTransparency =
        1

    status.Position =
        UDim2.fromOffset(10, 62)

    status.Size =
        UDim2.fromOffset(260, 18)

    status.Font =
        Enum.Font.GothamMedium

    status.TextSize =
        12

    status.TextXAlignment =
        Enum.TextXAlignment.Left

    status.TextColor3 =
        Color3.fromRGB(196, 181, 253)

    status.Text =
        GatewayState.StatusText

    status.Parent =
        frame

    local join =
        Instance.new("TextButton")

    join.Name =
        "Join"

    join.Position =
        UDim2.fromOffset(10, 86)

    join.Size =
        UDim2.fromOffset(78, 22)

    join.BackgroundColor3 =
        Color3.fromRGB(24, 18, 38)

    join.BorderSizePixel =
        0

    join.Font =
        Enum.Font.GothamBold

    join.TextSize =
        12

    join.TextColor3 =
        Color3.fromRGB(232, 230, 240)

    join.Text =
        "Join"

    join.Parent =
        frame

    local copy =
        Instance.new("TextButton")

    copy.Name =
        "Copy"

    copy.Position =
        UDim2.fromOffset(101, 86)

    copy.Size =
        UDim2.fromOffset(78, 22)

    copy.BackgroundColor3 =
        Color3.fromRGB(24, 18, 38)

    copy.BorderSizePixel =
        0

    copy.Font =
        Enum.Font.GothamBold

    copy.TextSize =
        12

    copy.TextColor3 =
        Color3.fromRGB(232, 230, 240)

    copy.Text =
        "Copy"

    copy.Parent =
        frame

    local rejoin =
        Instance.new("TextButton")

    rejoin.Name =
        "Rejoin"

    rejoin.Position =
        UDim2.fromOffset(192, 86)

    rejoin.Size =
        UDim2.fromOffset(78, 22)

    rejoin.BackgroundColor3 =
        Color3.fromRGB(24, 18, 38)

    rejoin.BorderSizePixel =
        0

    rejoin.Font =
        Enum.Font.GothamBold

    rejoin.TextSize =
        12

    rejoin.TextColor3 =
        Color3.fromRGB(232, 230, 240)

    rejoin.Text =
        "Rejoin"

    rejoin.Parent =
        frame

    for _, button in ipairs({
        join,
        copy,
        rejoin,
    }) do

        local buttonCorner =
            Instance.new("UICorner")

        buttonCorner.CornerRadius =
            UDim.new(0, 5)

        buttonCorner.Parent =
            button
    end

    join.MouseButton1Click:Connect(function()

        GatewayState.TargetText =
            tostring(input.Text or "")

        SetControlValue(
            GatewayTargetInput,
            GatewayState.TargetText
        )

        JoinLiteExactGatewayTarget()
    end)

    copy.MouseButton1Click:Connect(function()

        CopyLiteCurrentServerToClipboard()
    end)

    rejoin.MouseButton1Click:Connect(function()

        RejoinLiteExactCurrentServer()
    end)

    GatewayHudGui =
        gui

    GatewayHudFrame =
        frame

    GatewayHudInput =
        input

    GatewayHudStatusLabel =
        status

    RefreshLiteGatewayVisuals()

    return gui
end

function SetLiteGatewayHudEnabled(enabled)

    GatewayState.HudEnabled =
        enabled == true

    if GatewayState.HudEnabled == true then

        CreateLiteGatewayHud()

    else

        DestroyLiteGatewayHud()
    end

    MarkConfigDirty()
end

--==================================================
-- [8.9] AVOID USERS
--==================================================

local LITE_AVOID_USERS_FILE =
    "HolySniperLite/AvoidUsers.json"

function RebuildLiteAvoidUserIdMap()

    AvoidUsersState.UserIds =
        {}

    if type(AvoidUsersState.Users) ~= "table" then
        AvoidUsersState.Users =
            {}
    end

    for _, entry in ipairs(AvoidUsersState.Users) do

        if type(entry) == "table" then

            local userId =
                tonumber(entry.UserId)

            if userId
            and userId > 0 then

                AvoidUsersState.UserIds[userId] =
                    entry
            end
        end
    end
end

function CountLiteAvoidUsers()

    if type(AvoidUsersState.Users) ~= "table" then
        return 0
    end

    local count =
        0

    for _, entry in ipairs(AvoidUsersState.Users) do

        if type(entry) == "table"
        and tonumber(entry.UserId) then
            count =
            count + 1
        end
    end

    return count
end

function SaveLiteAvoidUsersNow(reason)

    if type(writefile) ~= "function" then

        warn("[HOLY SNIPER LITE] Avoid Users save failed: writefile unsupported.")

        return false
    end

    if type(EnsureHolyLiteSaveFolder) == "function" then
        EnsureHolyLiteSaveFolder()
    end

    local payload = {
        Version = 1,

        Enabled =
            AvoidUsersState.Enabled == true,

        AutoHopOnMatch =
            AvoidUsersState.AutoHopOnMatch == true,

        Users =
            AvoidUsersState.Users,
    }

    local ok, encoded =
        pcall(function()
            return HttpService:JSONEncode(payload)
        end)

    if ok ~= true
    or type(encoded) ~= "string" then

        warn("[HOLY SNIPER LITE] Avoid Users save encode failed.")

        return false
    end

    local writeOk, writeErr =
        pcall(function()

            writefile(
                LITE_AVOID_USERS_FILE,
                encoded
            )
        end)

    if writeOk ~= true then

        warn(
            "[HOLY SNIPER LITE] Avoid Users save failed:",
            tostring(writeErr)
        )

        return false
    end

    print(
        "[HOLY SNIPER LITE] Avoid Users saved:",
        tostring(reason or "manual")
    )

    return true
end

function LoadLiteAvoidUsersNow()

    if type(readfile) ~= "function"
    or type(isfile) ~= "function" then

        warn("[HOLY SNIPER LITE] Avoid Users load failed: file IO unsupported.")

        return false
    end

    local exists =
        false

    local existsOk =
        pcall(function()
            exists =
                isfile(LITE_AVOID_USERS_FILE)
        end)

    if existsOk ~= true
    or exists ~= true then
        return false
    end

    local readOk, raw =
        pcall(function()
            return readfile(LITE_AVOID_USERS_FILE)
        end)

    if readOk ~= true
    or type(raw) ~= "string"
    or raw == "" then
        return false
    end

    local decodeOk, payload =
        pcall(function()
            return HttpService:JSONDecode(raw)
        end)

    if decodeOk ~= true
    or type(payload) ~= "table" then

        warn("[HOLY SNIPER LITE] Avoid Users file invalid.")

        return false
    end

    if type(payload.Enabled) == "boolean" then
        AvoidUsersState.Enabled =
            payload.Enabled
    end

    if type(payload.AutoHopOnMatch) == "boolean" then
        AvoidUsersState.AutoHopOnMatch =
            payload.AutoHopOnMatch
    end

    if type(payload.Users) == "table" then
        AvoidUsersState.Users =
            payload.Users
    end

    RebuildLiteAvoidUserIdMap()

    print(
        "[HOLY SNIPER LITE] Avoid Users loaded:",
        tostring(CountLiteAvoidUsers())
    )

    return true
end

function BuildLiteAvoidUsersVisibleRows(limit)

    limit =
        tonumber(limit)
        or 8

    local rows =
        {}

    if type(AvoidUsersState.Users) ~= "table" then
        return rows
    end

    for index, entry in ipairs(AvoidUsersState.Users) do

        if index > limit then
            break
        end

        table.insert(
            rows,
            {
                Index = index,
                Entry = entry,
            }
        )
    end

    return rows
end

function FormatLiteAvoidUserFilterListRow(rowData)

    if type(rowData) ~= "table"
    or type(rowData.Entry) ~= "table" then
        return nil
    end

    local entry =
        rowData.Entry

    local name =
        CleanText(
            entry.Name
            or entry.Username
            or entry.DisplayName
            or entry.User
        )

    local userId =
        tonumber(
            entry.UserId
            or entry.UserID
            or entry.Id
            or entry.ID
        )

    if name == "" then

        if userId then
            name =
                tostring(userId)
        else
            name =
                "Unknown"
        end
    end

    local userIdText =
        userId
        and tostring(userId)
        or "?"

    local shortName =
        name

    if #shortName > 24 then
        shortName =
            shortName:sub(1, 21)
            .. "..."
    end

    local shortUserId =
        userIdText

    if #shortUserId > 10 then
        shortUserId =
            shortUserId:sub(1, 4)
            .. "..."
            .. shortUserId:sub(#shortUserId - 2)
    end

    return {
        Pet =
            shortName,

        PetName =
            shortName,

        Max =
            shortUserId,

        MaxPrice =
            shortUserId,

        Weight =
            "Alt",

        BW =
            "Alt",

        MinWeight =
            "Alt",

        Priority =
            "Watched",

        Entry =
            entry,

        Index =
            rowData.Index,
    }
end

function RefreshLiteAvoidUsersTable()

    local rows =
        BuildLiteAvoidUsersVisibleRows(8)

    AvoidUsersVisibleRows =
        rows

    local listRows =
        {}

    local selectedRowIndex =
        nil

    for rowIndex, rowData in ipairs(rows) do

        local formatted =
            FormatLiteAvoidUserFilterListRow(
                rowData
            )

        if formatted then

            listRows[#listRows + 1] =
                formatted

            if AvoidUsersSelectedIndex == rowData.Index then
                selectedRowIndex =
                    #listRows
            end
        end
    end

    if AvoidUsersFilterList
    and type(AvoidUsersFilterList.SetRows) == "function" then

        AvoidUsersFilterList:SetRows(
            listRows
        )

        if type(AvoidUsersFilterList.SetSelected) == "function" then

            AvoidUsersFilterList:SetSelected(
                selectedRowIndex
            )
        end
    end

    if type(AvoidUsersState.Users) == "table"
    and #AvoidUsersState.Users > 8 then

        SetControlText(
            AvoidUsersListLabel,
            '<font color="rgb(125,116,145)">+'
                .. tostring(#AvoidUsersState.Users - 8)
                .. ' more watched users</font>'
        )

        SetControlVisible(
            AvoidUsersListLabel,
            true
        )

    else

        SetControlText(
            AvoidUsersListLabel,
            ""
        )

        SetControlVisible(
            AvoidUsersListLabel,
            false
        )
    end
end

function SelectLiteAvoidUserRow(rowIndex, rowData)

    rowIndex =
        tonumber(rowIndex)
        or 0

    if type(rowData) ~= "table" then
        rowData =
            AvoidUsersVisibleRows[rowIndex]
    end

    if type(rowData) ~= "table"
    or type(rowData.Entry) ~= "table" then
        return false
    end

    AvoidUsersSelectedIndex =
        tonumber(rowData.Index)
        or rowIndex

    RefreshLiteAvoidUsersTable()

    print(
        "[HOLY SNIPER LITE] Selected avoid user:",
        tostring(rowData.Entry.Name or "Unknown"),
        tostring(rowData.Entry.UserId or "?")
    )

    return true
end

function RemoveSelectedLiteAvoidUser()

    local selectedIndex =
        tonumber(AvoidUsersSelectedIndex)

    if not selectedIndex
    or type(AvoidUsersState.Users) ~= "table"
    or type(AvoidUsersState.Users[selectedIndex]) ~= "table" then

        warn("[HOLY SNIPER LITE] Remove Selected failed: select a watched user first.")

        return false
    end

    local removed =
        AvoidUsersState.Users[selectedIndex]

    table.remove(
        AvoidUsersState.Users,
        selectedIndex
    )

    AvoidUsersSelectedIndex =
        nil

    RebuildLiteAvoidUserIdMap()

    SaveLiteAvoidUsersNow("remove selected")

    AvoidUsersState.StatusText =
        "● Removed · "
        .. tostring(removed.Name or removed.UserId or "Unknown")

    RefreshLiteAvoidUsersVisuals()

    print(
        "[HOLY SNIPER LITE] Removed avoid user:",
        tostring(removed.Name or "Unknown"),
        tostring(removed.UserId or "?")
    )

    return true
end

function ClearAllLiteAvoidUsers()

    AvoidUsersState.Users =
        {}

    AvoidUsersState.UserIds =
        {}

    AvoidUsersSelectedIndex =
        nil

    SaveLiteAvoidUsersNow("clear all")

    AvoidUsersState.StatusText =
        "● Clear · 0 watched"

    RefreshLiteAvoidUsersVisuals()

    warn("[HOLY SNIPER LITE] Cleared all avoid users.")

    return true
end

function RefreshLiteAvoidUsersVisuals()

    local watched =
        CountLiteAvoidUsers()

    local statusText =
        AvoidUsersState.StatusText

    if CleanText(statusText) == "" then

        if AvoidUsersState.Enabled == true then
            statusText =
                "● Ready · "
                    .. tostring(watched)
                    .. " watched"
        else
            statusText =
                "● Off"
        end
    end

    if AvoidUsersState.Enabled == false then

        statusText =
            '<font color="rgb(125,116,145)"><b>● OFF</b></font>'
    elseif tostring(statusText):find("Detected", 1, true) then

        statusText =
            '<font color="rgb(250,204,21)"><b>'
                .. EscapeLiteRichText(statusText)
                .. '</b></font>'
    elseif tostring(statusText):find("Hopping", 1, true) then

        statusText =
            '<font color="rgb(248,113,113)"><b>'
                .. EscapeLiteRichText(statusText)
                .. '</b></font>'
    else

        statusText =
            '<font color="rgb(196,181,253)"><b>'
                .. EscapeLiteRichText(statusText)
                .. '</b></font>'
    end

    SetControlText(
        AvoidUsersStatusLabel,
        statusText
    )

    RefreshLiteAvoidUsersTable()
end

function ResolveLiteAvoidUserToken(token)

    token =
        CleanText(token)

    if token == "" then
        return nil, "Empty input"
    end

    local numericId =
        tonumber(token)

    if numericId
    and numericId > 0 then

        local resolvedName =
            tostring(numericId)

        local okName, nameResult =
            pcall(function()
                return Players:GetNameFromUserIdAsync(numericId)
            end)

        if okName
        and type(nameResult) == "string"
        and nameResult ~= "" then
            resolvedName =
                nameResult
        end

        return {
            UserId =
                math.floor(numericId),

            Name =
                resolvedName,

            AddedAt =
                os.time(),
        }, nil
    end

    local okUserId, userIdResult =
        pcall(function()
            return Players:GetUserIdFromNameAsync(token)
        end)

    if okUserId ~= true
    or not tonumber(userIdResult) then

        return nil,
            "Could not resolve user: "
            .. tostring(token)
    end

    return {
        UserId =
            tonumber(userIdResult),

        Name =
            token,

        AddedAt =
            os.time(),
    }, nil
end

function AddLiteAvoidUserEntry(entry)

    if type(entry) ~= "table" then
        return false
    end

    local userId =
        tonumber(entry.UserId)

    if not userId
    or userId <= 0 then
        return false
    end

    RebuildLiteAvoidUserIdMap()

    if AvoidUsersState.UserIds[userId] then

        AvoidUsersState.UserIds[userId].Name =
            CleanText(entry.Name) ~= ""
            and CleanText(entry.Name)
            or AvoidUsersState.UserIds[userId].Name

        return false
    end

    table.insert(
        AvoidUsersState.Users,
        {
            UserId =
                userId,

            Name =
                CleanText(entry.Name) ~= ""
                and CleanText(entry.Name)
                or tostring(userId),

            AddedAt =
                tonumber(entry.AddedAt)
                or os.time(),
        }
    )

    RebuildLiteAvoidUserIdMap()

    return true
end

function AddLiteAvoidUsersFromInput()

    local raw =
        CleanText(AvoidUsersState.RawInput)

    if raw == "" then

        AvoidUsersState.StatusText =
            "● Type a user first"

        RefreshLiteAvoidUsersVisuals()

        return false
    end

    local added =
        0

    local failed =
        {}

    for token in raw:gmatch("[^,%s]+") do

        local entry, err =
            ResolveLiteAvoidUserToken(token)

        if entry then

            if AddLiteAvoidUserEntry(entry) then
                added =
                    added + 1
            end

        elseif err then

            table.insert(
                failed,
                err
            )
        end
    end

    if added > 0 then

        AvoidUsersState.StatusText =
            "● Added · "
            .. tostring(added)
            .. " user"
            .. (added == 1 and "" or "s")

        AvoidUsersState.RawInput =
            ""

        SetControlValue(
            AvoidUsersInput,
            ""
        )

        SaveLiteAvoidUsersNow("add user")

        MarkConfigDirty()

    elseif #failed > 0 then

        AvoidUsersState.StatusText =
            "● "
            .. tostring(failed[1])

    else

        AvoidUsersState.StatusText =
            "● Already watched"
    end

    RefreshLiteAvoidUsersVisuals()

    return added > 0
end

function RemoveLiteAvoidUserFromInput()

    local raw =
        CleanText(AvoidUsersState.RawInput)

    if raw == "" then

        AvoidUsersState.StatusText =
            "● Type a user to remove"

        RefreshLiteAvoidUsersVisuals()

        return false
    end

    local lowerRaw =
        raw:lower()

    local removed =
        0

    local newList =
        {}

    for _, entry in ipairs(AvoidUsersState.Users) do

        local userId =
            tostring(entry.UserId or "")

        local name =
            CleanText(entry.Name)

        local shouldRemove =
            userId == raw
            or name:lower() == lowerRaw

        if shouldRemove then
            removed =
                removed + 1
        else
            table.insert(
                newList,
                entry
            )
        end
    end

    AvoidUsersState.Users =
        newList

    RebuildLiteAvoidUserIdMap()

    if removed > 0 then

        AvoidUsersState.StatusText =
            "● Removed · "
            .. tostring(removed)

        AvoidUsersState.RawInput =
            ""

        SetControlValue(
            AvoidUsersInput,
            ""
        )

        SaveLiteAvoidUsersNow("remove user")

        MarkConfigDirty()

    else

        AvoidUsersState.StatusText =
            "● Not found"
    end

    RefreshLiteAvoidUsersVisuals()

    return removed > 0
end

function ClearLiteAvoidUsers()

    AvoidUsersState.Users =
        {}

    AvoidUsersState.UserIds =
        {}

    AvoidUsersState.LastDetectedName =
        "None"

    AvoidUsersState.StatusText =
        "● Cleared"

    AvoidUsersState.RawInput =
        ""

    SetControlValue(
        AvoidUsersInput,
        ""
    )

    SaveLiteAvoidUsersNow("clear users")

    MarkConfigDirty()

    RefreshLiteAvoidUsersVisuals()

    warn("[HOLY SNIPER LITE] Avoid Users cleared.")

    return true
end

function FindLiteAvoidUserInServer()

    RebuildLiteAvoidUserIdMap()

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            local entry =
                AvoidUsersState.UserIds[
                    tonumber(player.UserId)
                ]

            if entry then

                return player,
                    entry
            end
        end
    end

    return nil, nil
end

function CheckLiteAvoidUsersNow(manual)

    local watched =
        CountLiteAvoidUsers()

    if watched <= 0 then

        AvoidUsersState.StatusText =
            AvoidUsersState.Enabled == true
            and "● Ready · 0 watched"
            or "● Off"

        RefreshLiteAvoidUsersVisuals()

        return false
    end

    local detectedPlayer, entry =
        FindLiteAvoidUserInServer()

    if not detectedPlayer then

        AvoidUsersState.StatusText =
            AvoidUsersState.Enabled == true
            and (
                "● Clear · "
                .. tostring(watched)
                .. " watched"
            )
            or "● Off"

        RefreshLiteAvoidUsersVisuals()

        return false
    end

    local detectedName =
        detectedPlayer.Name
        or entry.Name
        or tostring(detectedPlayer.UserId)

    AvoidUsersState.LastDetectedName =
        detectedName

    AvoidUsersState.StatusText =
        "● Detected · "
        .. tostring(detectedName)

    RefreshLiteAvoidUsersVisuals()

    if AvoidUsersState.Enabled == true
    and AvoidUsersState.AutoHopOnMatch == true
    and ServerState.IsHopping ~= true then

        AvoidUsersState.StatusText =
            "● Hopping · "
            .. tostring(detectedName)

        RefreshLiteAvoidUsersVisuals()

        if type(BlockLiteServer) == "function" then

            BlockLiteServer(
                game.JobId,
                ServerState.BlockDuration
            )
        end

        task.defer(function()

            LiteHopToServer(
                "avoid user"
            )
        end)

        return true
    end

    if manual == true then

        warn(
            "[HOLY SNIPER LITE] Avoid user detected:",
            tostring(detectedName),
            "| AutoHop:",
            tostring(AvoidUsersState.AutoHopOnMatch)
        )
    end

    return true
end

function StartLiteAvoidUsersWorker()

    local root =
        type(getgenv) == "function"
        and getgenv()
        or _G

    if root.HOLY_LITE_AVOID_USERS_WORKER then
        return
    end

    root.HOLY_LITE_AVOID_USERS_WORKER =
        true

    task.spawn(function()

        while IsHolyLiteCurrentRun() do

            task.wait(
                tonumber(AvoidUsersState.CheckInterval)
                or 2.5
            )

            if AvoidUsersState.Enabled == true then

                pcall(function()
                    CheckLiteAvoidUsersNow(false)
                end)
            end
        end

        root.HOLY_LITE_AVOID_USERS_WORKER =
            false
    end)
end

LoadLiteAvoidUsersNow()

RebuildLiteAvoidUserIdMap()

function ShouldLiteAutoHopNow()

    if RuntimeState.AutoHop ~= true then
        return false
    end

    if RuntimeState.SniperEnabled ~= true then
        return false
    end

    if ServerState.IsHopping == true then
        return false
    end

    if LiteBuyInFlight == true then
        return false
    end

    if GetLiteExtraStayRemaining() > 0 then
        return false
    end

    local duration =
        math.clamp(
            tonumber(RuntimeState.ScanDuration) or 30,
            1,
            300
        )

    local startedAt =
        tonumber(ServerState.ScanStartedAt)
        or 0

    if startedAt <= 0 then

        ServerState.ScanStartedAt =
            os.clock()

        return false
    end

    return (os.clock() - startedAt) >= duration
end

function ShowLiteConfirmDialog(index, title, description, confirmTitle, destructive, callback)

    if Window
    and type(Window.AddDialog) == "function" then

        Window:AddDialog(index, {
            Title = tostring(title or "Confirm"),
            Description = tostring(description or "Are you sure?"),
            AutoDismiss = true,
            OutsideClickDismiss = true,
            FooterButtons = {
                Cancel = {
                    Title = "Cancel",
                    Variant = "Ghost",
                    Order = 1,
                    Callback = function() end,
                },

                Confirm = {
                    Title = tostring(confirmTitle or "Confirm"),
                    Variant = destructive == true and "Destructive" or "Primary",
                    WaitTime = destructive == true and 2 or nil,
                    Order = 2,
                    Callback = function()

                        if type(callback) == "function" then
                            callback()
                        end
                    end,
                },
            },
        })

        return
    end

    if type(callback) == "function" then
        callback()
    end
end

function ShowEditWatchlistFilterDialog()

    local entry =
        GetSelectedWatchlistEntry()

    if not entry then
        warn("[HOLY SNIPER LITE] Edit failed: select a filter first.")
        return false
    end

    local filter =
        entry.Filter

    if type(filter) ~= "table" then
        warn("[HOLY SNIPER LITE] Edit failed: selected filter is invalid.")
        return false
    end

    local editMaxPrice =
        tostring(
            tonumber(filter.MaxPrice)
            or 0
        )

    local editMinWeight =
        tostring(
            tonumber(filter.MinWeight)
            or 0
        )

    local editWeightMode =
        tostring(
            filter.WeightMode
            or "Base Weight"
        )

    local editPriority =
        tostring(
            filter.Priority
            or "Normal"
        )

    local editMutationMode =
        tostring(
            filter.MutationMode
            or "Off"
        )

    local editMutations =
        CopyMap(
            filter.Mutations
        )

    local EditDialog =
        nil

    local EditMutationDropdown =
        nil

    EditDialog =
        Window:AddDialog(
            "LiteEditWatchlistFilter",
            {
                Title = "Edit Filter",
                Description =
                    WatchlistName(entry.WatchlistId)
                    .. " · "
                    .. tostring(entry.PetName),

                AutoDismiss = false,
                OutsideClickDismiss = true,

                FooterButtons = {
                    Cancel = {
                        Title = "Cancel",
                        Variant = "Ghost",
                        Order = 1,
                        Callback = function()

                            if EditDialog
                            and type(EditDialog.Dismiss) == "function" then
                                EditDialog:Dismiss()
                            end
                        end,
                    },

                    Save = {
                        Title = "Save Filter",
                        Variant = "Primary",
                        Order = 2,
                        Callback = function()

                            local maxPrice =
                                ParseOptionalNumberInput(
                                    editMaxPrice
                                )

                            if not maxPrice
                            or maxPrice <= 0 then
                                warn("[HOLY SNIPER LITE] Edit failed: Max Price must be above 0.")
                                return
                            end

                            local minWeight =
                                ParseOptionalNumberInput(
                                    editMinWeight
                                )

                            if not minWeight
                            or minWeight < 0 then
                                minWeight =
                                    0
                            end

                            editWeightMode =
                                tostring(
                                    filter.WeightMode
                                    or "Base Weight"
                                )

                            editPriority =
                                tostring(
                                    filter.Priority
                                    or "Normal"
                                )

                            editMutationMode =
                                tostring(
                                    filter.MutationMode
                                    or "Off"
                                )

                            editMutations =
                                CopyMap(
                                    filter.Mutations
                                )

                            if not SniperFilterSets[entry.WatchlistId] then
                                SniperFilterSets[entry.WatchlistId] =
                                    {}
                            end

                            SniperFilterSets[entry.WatchlistId][entry.PetName] = {
                                MaxPrice =
                                    math.floor(maxPrice),

                                MinWeight =
                                    minWeight,

                                WeightMode =
                                    editWeightMode,

                                Priority =
                                    editPriority,

                                MutationMode =
                                    editMutationMode,

                                Mutations =
                                    CopyMap(editMutations),
                            }

                            if type(SaveSniperFiltersNow) == "function" then
                                SaveSniperFiltersNow("filter edited")
                            end

                            MarkConfigDirty()

                            if type(RefreshWatchlist) == "function" then
                                RefreshWatchlist()
                            end

                            print(
                                "[HOLY SNIPER LITE] Edited filter:",
                                WatchlistName(entry.WatchlistId),
                                tostring(entry.PetName)
                            )

                            if EditDialog
                            and type(EditDialog.Dismiss) == "function" then
                                EditDialog:Dismiss()
                            end
                        end,
                    },
                },
            }
        )

    EditDialog:AddInput(
        "LiteEditMaxPrice",
        {
            Text = "Max Price",
            Default = editMaxPrice,
            Placeholder = "Example: 150000",
            Numeric = false,
            Finished = false,
            ClearTextOnFocus = false,
            ClearTextOnBlur = false,
            AllowEmpty = true,
            Tooltip = "Maximum price for this saved filter.",
        }
    ):OnChanged(function(value)

        editMaxPrice =
            tostring(value or "")
    end)

    EditDialog:AddInput(
        "LiteEditMinWeight",
        {
            Text = "Min Weight",
            Default = editMinWeight,
            Placeholder = "Example: 0.1",
            Numeric = false,
            Finished = false,
            ClearTextOnFocus = false,
            ClearTextOnBlur = false,
            AllowEmpty = true,
            Tooltip = "Minimum weight for this saved filter.",
        }
    ):OnChanged(function(value)

        editMinWeight =
            tostring(value or "")
    end)

    return true
end

function CountLiteActiveFilters()

    local count =
        0

    for watchlistId = 1, 3 do

        local filters =
            SniperFilterSets[watchlistId]

        if type(filters) == "table" then

            for _, filter in pairs(filters) do

                if type(filter) == "table" then
                    count =
            count + 1
                end
            end
        end
    end

    return count
end

function CleanupLiteListingLocks()

    local now =
        os.clock()

    for key, expiresAt in pairs(LiteFailedListingLocks) do

        if tonumber(expiresAt)
        and now >= expiresAt then
            LiteFailedListingLocks[key] =
                nil
        end
    end

    for key, expiresAt in pairs(LiteBoughtListingLocks) do

        if tonumber(expiresAt)
        and now >= expiresAt then
            LiteBoughtListingLocks[key] =
                nil
        end
    end
end

function IsLiteListingLocked(listing)

    local key =
        BuildLiteListingKey(listing)

    if key == "nil" then
        return true
    end

    CleanupLiteListingLocks()

    return LiteFailedListingLocks[key] ~= nil
        or LiteBoughtListingLocks[key] ~= nil
end

function LockLiteListing(listing, lockTable, seconds)

    local key =
        BuildLiteListingKey(listing)

    if key == "nil" then
        return
    end

    lockTable[key] =
        os.clock() + seconds
end

function MatchLiteListingsQuiet(listings)

    local startedAt =
        os.clock()

    if type(listings) ~= "table" then
        listings =
            {}
    end

    local matches =
        {}

    for _, listing in ipairs(listings) do

        if type(listing) == "table"
        and not IsLiteListingLocked(listing) then

            local priorityPassed, priorityConfig =
                LiteListingMatchesHardcodedPriority(
                    listing
                )

            if priorityPassed == true then

                table.insert(matches, {
                    WatchlistId = 0,
                    PetName = listing.PetName,
                    Listing = listing,
                    Filter = {
                        MaxPrice = priorityConfig.MaxPrice,
                        MinWeight = 0,
                        WeightMode = "Base Weight",
                        Priority = "Hardcoded",
                        MutationMode = "Off",
                        Mutations = {},
                    },
                    Reason = "HardcodedPriority",
                    IsHardcodedPriority = true,
                })
            end

            for watchlistId = 1, 3 do

                local filters =
                    SniperFilterSets[watchlistId]

                if type(filters) == "table" then

                    local filter =
                        filters[listing.PetName]

                    if type(filter) == "table" then

                        local passed =
                            LiteListingMatchesFilter(
                                listing,
                                filter
                            )

                        if passed == true then

                            table.insert(matches, {
                                WatchlistId = watchlistId,
                                PetName = listing.PetName,
                                Listing = listing,
                                Filter = filter,
                                Reason = "Pass",
                            })
                        end
                    end
                end
            end
        end
    end

    table.sort(matches, function(a, b)

        local aHardcoded =
            a.IsHardcodedPriority == true

        local bHardcoded =
            b.IsHardcodedPriority == true

        if aHardcoded ~= bHardcoded then
            return aHardcoded == true
        end

        local aPriority =
            GetLitePriorityRank(
                a.Filter and a.Filter.Priority
            )

        local bPriority =
            GetLitePriorityRank(
                b.Filter and b.Filter.Priority
            )

        if aPriority ~= bPriority then
            return aPriority > bPriority
        end

        local aPrice =
            tonumber(a.Listing and a.Listing.Price)
            or math.huge

        local bPrice =
            tonumber(b.Listing and b.Listing.Price)
            or math.huge

        if aPrice ~= bPrice then
            return aPrice < bPrice
        end

        local aWeight =
            GetLiteFilterWeight(
                a.Listing,
                a.Filter
            )

        local bWeight =
            GetLiteFilterWeight(
                b.Listing,
                b.Filter
            )

        if aWeight ~= bWeight then
            return aWeight > bWeight
        end

        return tostring(a.PetName or ""):lower()
            < tostring(b.PetName or ""):lower()
    end)

    LatestLiteMatches =
        matches

    RuntimeState.MatchesCount =
        #matches

    RuntimeState.LastMatchMs =
        (os.clock() - startedAt) * 1000

    if #matches > 0 then
        RuntimeState.LastMatchText =
            BuildLiteMatchRow(matches[1])
    else
        RuntimeState.LastMatchText =
            "None"
    end

    return matches
end

function BuildLiteBestCandidateQuiet()

    if CountLiteActiveFilters() <= 0
    and HasLiteHardcodedPriorityPets() ~= true then

        RuntimeState.Status =
            "No filters"

        RuntimeState.BestText =
            "None"

        RuntimeState.BestPrice =
            0

        RuntimeState.BestBooth =
            "None"

        RuntimeState.PriorityTarget =
            "None"

        RefreshLiteRuntimeLabels()

        return nil
    end

    if not LatestBoothData then

        RuntimeState.Status =
            "Waiting for booth data"

        RuntimeState.BestText =
            "None"

        RuntimeState.BestPrice =
            0

        RuntimeState.BestBooth =
            "None"

        RuntimeState.PriorityTarget =
            "None"

        RefreshLiteRuntimeLabels()

        return nil
    end

    local cacheAge =
        os.clock() - tonumber(LatestBoothUpdate or 0)

    if LatestBoothUpdate <= 0
    or cacheAge > LITE_MAX_BOOTH_CACHE_AGE then

        RuntimeState.Status =
            "Waiting for fresh booth data"

        RuntimeState.BestText =
            "None"

        RuntimeState.BestPrice =
            0

        RuntimeState.BestBooth =
            "None"

        RefreshLiteRuntimeLabels()

        return nil
    end

    local listings =
        ExtractLiteListings(true)

    local matches =
        MatchLiteListingsQuiet(
            listings
        )

    if type(matches) ~= "table"
    or #matches <= 0 then

        RuntimeState.Status =
            "Scanning"

        RuntimeState.BestText =
            "None"

        RuntimeState.BestPrice =
            0

        RuntimeState.BestBooth =
            "None"

        RuntimeState.PriorityTarget =
            "None"

        RefreshLiteRuntimeLabels()

        return nil
    end

    local best =
        GetFirstLiteBuyableMatch(
            matches
        )

    if not best then

        LatestBestCandidate =
            nil

        RuntimeState.Status =
            "Only favorite matches"

        RuntimeState.BestText =
            "None"

        RuntimeState.BestPrice =
            0

        RuntimeState.BestBooth =
            "None"

        RuntimeState.BuyStatus =
            "Skipped favorite"

        RuntimeState.PriorityTarget =
            "None"

        if matches[1] then
            RuntimeState.LastMatchText =
                BuildLiteMatchRow(matches[1])
        end

        RefreshLiteRuntimeLabels()

        return nil
    end

    LatestBestCandidate =
        best

    local listing =
        best.Listing

    RuntimeState.Status =
        "Candidate found"

    RuntimeState.BestText =
        tostring(listing.PetName)

    RuntimeState.BestPrice =
        tonumber(listing.Price)
        or 0

    RuntimeState.BestBooth =
        tostring(listing.BoothId or "None")

    if best.IsHardcodedPriority == true then

        RuntimeState.PriorityTarget =
            tostring(listing.PetName)
            .. " · Max "
            .. FormatCompactPrice(
                best.Filter
                and best.Filter.MaxPrice
            )

    else

        RuntimeState.PriorityTarget =
            "None"
    end

    RefreshLiteRuntimeLabels()

    return best
end

function BuyLiteCandidateQuiet(candidate, options)

    options =
        options
        or {}

    if LiteBuyInFlight == true then
        return false, "Buy in flight"
    end

    if type(candidate) ~= "table"
    or type(candidate.Listing) ~= "table" then
        return false, "Invalid candidate"
    end

    local remote =
        ResolveLiteBuyListingRemote()

    if not remote then
        return false, "Buy remote missing"
    end

    local listing =
        candidate.Listing

    LiteBuyInFlight =
        true

    if options.SilentBuyPath ~= true then

        RuntimeState.BuyStatus =
            "Buying..."

        RefreshLiteRuntimeLabels()
    end

    local startedAt =
        os.clock()

    local ok, result =
        InvokeLiteBuyRemote(
            remote,
            listing
        )

    LiteBuyInFlight =
        false

    local elapsedMs =
        (os.clock() - startedAt) * 1000

    if ok == true
    and result == true then

        LockLiteListing(
            listing,
            LiteBoughtListingLocks,
            LITE_BOUGHT_LOCK_SECONDS
        )

        local extraStayRemaining =
            AddLiteExtraStayAfterBuy()

        RuntimeState.BuyStatus =
            "Bought · "
            .. string.format("%.2fms", elapsedMs)

        if extraStayRemaining > 0 then

            RuntimeState.BuyStatus =
                RuntimeState.BuyStatus
                .. " · Extra Stay "
                .. tostring(extraStayRemaining)
                .. "s"
        end

        RuntimeState.Status =
            "Bought"

        RuntimeState.BoughtCount =
            (tonumber(RuntimeState.BoughtCount) or 0) + 1

        RuntimeState.LastSnipeText =
            tostring(listing.PetName or "Unknown")
            .. " · "
            .. tostring(listing.Price or 0)

        RuntimeState.LastErrorText =
            "None"

        PushLiteRecentSnipe(
            candidate
        )

        RefreshLiteRuntimeLabels()

        print(
            "[HOLY SNIPER LITE] BOUGHT:",
            BuildLiteMatchRow(candidate),
            "|",
            string.format("%.2fms", elapsedMs)
        )

        local isTopSnipe =
            type(IsLiteTopSnipesTarget) == "function"
            and IsLiteTopSnipesTarget(listing) == true

        if isTopSnipe == true then

            if type(_G.HOLY_LITE_SEND_TOP_SNIPE_WEBHOOK) == "function" then

                task.spawn(function()

                    local okTop, topResult =
                        pcall(function()
                            return _G.HOLY_LITE_SEND_TOP_SNIPE_WEBHOOK(candidate)
                        end)

                    if okTop ~= true then

                        warn(
                            "[HOLY SNIPER LITE] Top Snipes webhook crashed:",
                            tostring(topResult)
                        )

                    elseif topResult ~= true then

                        warn(
                            "[HOLY SNIPER LITE] Top Snipes webhook did not send:",
                            tostring(topResult)
                        )

                    else

                        print(
                            "[HOLY SNIPER LITE] Top Snipes webhook confirmed:",
                            tostring(listing.PetName or "Unknown")
                        )
                    end
                end)
            else

                warn("[HOLY SNIPER LITE] Top Snipes webhook function missing.")
            end

        else

            if type(_G.HOLY_LITE_SEND_MARKET_SNIPE_WEBHOOK) == "function" then

                task.spawn(function()

                    local okMarket, marketResult =
                        pcall(function()
                            return _G.HOLY_LITE_SEND_MARKET_SNIPE_WEBHOOK(candidate)
                        end)

                    if okMarket ~= true then

                        warn(
                            "[HOLY SNIPER LITE] Market webhook crashed:",
                            tostring(marketResult)
                        )

                    elseif marketResult ~= true then

                        warn(
                            "[HOLY SNIPER LITE] Market webhook did not send:",
                            tostring(marketResult)
                        )

                    else

                        print(
                            "[HOLY SNIPER LITE] Market webhook confirmed:",
                            tostring(listing.PetName or "Unknown")
                        )
                    end
                end)
            end
        end

        QueueLiteTimingDebugWebhook(
            candidate,
            {
                Result =
                    "Bought",

                Reason =
                    "Success",

                Path =
                    timingPath,

                Mode =
                    modeConfig.Mode,

                StrikeIndex =
                    options.StrikeIndex or 1,

                StrikeLimit =
                    options.StrikeLimit or 1,

                CycleMs =
                    cycleMs,

                DetectMs =
                    options.DetectMs,

                ExtractMs =
                    RuntimeState.LastExtractMs,

                MatchMs =
                    options.MatchSkipped == true
                    and nil
                    or RuntimeState.LastMatchMs,

                BuyInvokeMs =
                    elapsedMs,

                SilentBuyPath =
                    options.SilentBuyPath == true,
            }
        )

        return true, result
    end

    LockLiteListing(
        listing,
        LiteFailedListingLocks,
        LITE_FAILED_LOCK_SECONDS
    )

    local rejectReason, rejectMessage =
        ResolveLiteBuyRejectReason(
            result
        )

    RuntimeState.BuyStatus =
        "Rejected · "
        .. tostring(rejectReason)
        .. " · "
        .. string.format("%.2fms", elapsedMs)

    RuntimeState.LastErrorText =
        tostring(rejectReason or "Unknown reject")

    RefreshLiteRuntimeLabels()

    warn(
        "[HOLY SNIPER LITE] Buy rejected:",
        BuildLiteMatchRow(candidate),
        "| reason:",
        tostring(rejectReason),
        "| result:",
        tostring(result)
    )

    if type(_G.HOLY_LITE_SEND_REJECT_WEBHOOK) == "function" then

        task.spawn(function()

            _G.HOLY_LITE_SEND_REJECT_WEBHOOK(
                candidate,
                rejectReason,
                result,
                rejectMessage
            )
        end)
    end

    QueueLiteTimingDebugWebhook(
        candidate,
        {
            Result =
                "Rejected",

            Reason =
                tostring(rejectReason or "Unknown"),

            Path =
                timingPath,

            Mode =
                modeConfig.Mode,

            StrikeIndex =
                options.StrikeIndex or 1,

            StrikeLimit =
                options.StrikeLimit or 1,

            CycleMs =
                cycleMs,

            DetectMs =
                options.DetectMs,

            ExtractMs =
                RuntimeState.LastExtractMs,

            MatchMs =
                options.MatchSkipped == true
                and nil
                or RuntimeState.LastMatchMs,

            BuyInvokeMs =
                elapsedMs,

            SilentBuyPath =
                options.SilentBuyPath == true,
        }
    )

    return false, result
end

function RunLiteSniperCycle()

    if RuntimeState.SniperEnabled ~= true
    or RuntimeState.ForceStopped == true then
        return false
    end

    if LiteBuyInFlight == true then
        return false
    end

    local modeConfig =
        GetLiteSniperModeConfig()
    
        local cycleStartedAt =
        os.clock()

    if CountLiteActiveFilters() <= 0
    and HasLiteHardcodedPriorityPets() ~= true then

        RuntimeState.Status =
            "No filters"

        RuntimeState.BestText =
            "None"

        RuntimeState.BestPrice =
            0

        RuntimeState.BestBooth =
            "None"

        RuntimeState.MatchesCount =
            0

        RuntimeState.LastMatchText =
            "None"

        RefreshLiteRuntimeLabels()

        return false
    end

    RefreshLatestBoothDataNow(
        "sniper cycle",
        true
    )

    local listings =
        ExtractLiteListings(
            true
        )

    if TryLiteOpeningStrike(
        listings,
        modeConfig,
        cycleStartedAt
    ) == true then

        return true
    end

    local matches =
        MatchLiteListingsQuiet(
            listings
        )

    if type(matches) ~= "table"
    or #matches <= 0 then

        RuntimeState.Status =
            "Scanning"

        RuntimeState.BestText =
            "None"

        RuntimeState.BestPrice =
            0

        RuntimeState.BestBooth =
            "None"

        RefreshLiteRuntimeLabels()

        return false
    end

    ApplyLiteBestCandidateState(
        matches[1]
    )

    if modeConfig.ChainStrike ~= true then

        BuyLiteCandidateQuiet(
            matches[1],
            {
                SilentBuyPath =
                    modeConfig.SilentBuyPath == true,

                Path =
                    "Normal Match",

                CycleStartedAt =
                    cycleStartedAt,

                StrikeIndex =
                    1,

                StrikeLimit =
                    1,
            }
        )

        return true
    end

    local strikeLimit =
        math.clamp(
            tonumber(modeConfig.StrikeLimit) or 3,
            1,
            5
        )

    local attempted =
        0

    for _, candidate in ipairs(matches) do

        if attempted >= strikeLimit then
            break
        end

        if type(candidate) == "table"
        and type(candidate.Listing) == "table"
        and candidate.Listing.IsFavorite ~= true
        and not IsLiteListingLocked(candidate.Listing) then

            attempted =
                attempted + 1

            ApplyLiteBestCandidateState(
                candidate
            )

            local bought =
                BuyLiteCandidateQuiet(
                    candidate,
                    {
                        SilentBuyPath =
                            modeConfig.SilentBuyPath == true,

                        Path =
                            "Chain Strike",

                        CycleStartedAt =
                            cycleStartedAt,

                        StrikeIndex =
                            attempted,

                        StrikeLimit =
                            strikeLimit,
                    }
                )

            if bought == true then
                return true
            end
        end
    end

    return attempted > 0
end

function StartLiteSniperLoop()

    if LiteSniperLoopRunning == true then
        return
    end

    LiteSniperLoopRunning =
        true

    task.spawn(function()

        print("[HOLY SNIPER LITE] Sniper loop started.")

        while IsHolyLiteCurrentRun()
        and RuntimeState.SniperEnabled == true
        and RuntimeState.ForceStopped ~= true do

            local ok, err =
                pcall(function()
                    RunLiteSniperCycle()
                end)

            if not ok then

                RuntimeState.Status =
                    "Loop error"

                RuntimeState.BuyStatus =
                    "Error"

                RefreshLiteRuntimeLabels()

                warn(
                    "[HOLY SNIPER LITE] Sniper loop error:",
                    tostring(err)
                )

                task.wait(0.5)

            else

                if ShouldLiteAutoHopNow() then

                    ServerState.ScanStartedAt =
                        os.clock()

                    LiteHopToServer(
                        "scan duration"
                    )

                    task.wait(1)

                else

                    task.wait(LITE_SCAN_INTERVAL)
                end
            end
        end

        LiteSniperLoopRunning =
            false

        RuntimeState.Status =
            "Idle"

        RefreshLiteRuntimeLabels()

        print("[HOLY SNIPER LITE] Sniper loop stopped.")
    end)
end

function BuildDropdownSelectionMap(value)

    local output = {}

    if type(value) == "table" then

        for key, selected in pairs(value) do

            if selected == true then

                local name =
                    CleanText(key)

                if name ~= ""
                and name ~= "None" then
                    output[name] =
                        true
                end

            elseif type(selected) == "string" then

                local name =
                    CleanText(selected)

                if name ~= ""
                and name ~= "None" then
                    output[name] =
                        true
                end
            end
        end

    elseif type(value) == "string" then

        local name =
            CleanText(value)

        if name ~= ""
        and name ~= "None" then
            output[name] =
                true
        end
    end

    return output
end
--==================================================
-- [9] SANCTUM CONTROLS
--==================================================

if CanRunTradeSniper() then

    local ActivateSniperToggle =
        HomeLeftBox:AddToggle(
            "ActivateSniper",
            {
                Text = '<font color="rgb(190, 255, 176)"><b>ACTIVATE</b></font> <font color="rgb(196,181,253)"><b>SNIPER</b></font>',
                Default = RuntimeState.SniperEnabled == true,
                Tooltip = "Enables the sniper system. Optional keybind starts as None.",
            }
        )

    ActivateSniperToggle:OnChanged(function(value)

        RuntimeState.SniperEnabled =
            value == true

        if RuntimeState.SniperEnabled == true then

            RuntimeState.ForceStopped =
                false

            RuntimeState.Status =
                "Starting"

            RuntimeState.BuyStatus =
                "Ready"

            ServerState.ScanStartedAt =
                os.clock()

            RefreshLiteRuntimeLabels()
            RefreshLiteServerLabels()

            StartLiteBoothRefreshWorker()

            ResolveLiteBuyListingRemote()

            StartLiteSniperLoop()

        else

            RuntimeState.Status =
                "Stopping"

            RuntimeState.BuyStatus =
                "Idle"

            RefreshLiteRuntimeLabels()
        end

        MarkConfigDirty()
    end)

    ActivateSniperToggle:AddKeyPicker(
        "LiteActivateSniperKeybind",
        {
            Text = "Activate Sniper",
            Default = "None",
            Mode = "Toggle",
            Modes = {
                "Toggle",
            },
            SyncToggleState = true,
        }
    )

    local SniperAutoHopToggle =
        HomeLeftBox:AddToggle(
            "SniperAutoHop",
            {
                Text = '<font color="rgb(231, 240, 230)"><b>AUTO</b></font> <font color="rgb(196,181,253)"><b>HOP</b></font>',
                Default = RuntimeState.AutoHop == true,
                Tooltip = "Automatically hops after the selected scan duration. Optional keybind starts as None.",
            }
        )

    SniperAutoHopToggle:OnChanged(function(value)

        RuntimeState.AutoHop =
            value == true

        if RuntimeState.AutoHop == true then
            ServerState.ScanStartedAt =
                os.clock()
        end

        RefreshLiteServerLabels()

        MarkConfigDirty()
    end)

    SniperAutoHopToggle:AddKeyPicker(
        "LiteAutoHopKeybind",
        {
            Text = "Auto Hop",
            Default = "None",
            Mode = "Toggle",
            Modes = {
                "Toggle",
            },
            SyncToggleState = true,
        }
    )

    HomeLeftBox:AddInput(
        "SniperScanDuration",
        {
            Text = "Scan Duration",
            Default = tostring(RuntimeState.ScanDuration),
            Placeholder = "30",
            Numeric = true,
            Finished = true,
            ClearTextOnFocus = false,
            ClearTextOnBlur = false,
            AllowEmpty = false,
            EmptyReset = "30",
            MaxLength = 3,
            Tooltip = "Seconds to scan before auto hop. Press Enter to apply.",
            VerifyValue = function(value)

                local number =
                    tonumber(value)

                return number ~= nil
                    and number >= 1
                    and number <= 300
            end,
        }
    ):OnChanged(function(value)

        RuntimeState.ScanDuration =
            math.clamp(
                ParseNumberInput(value, 30),
                1,
                300
            )

        ServerState.ScanStartedAt =
            os.clock()

        RefreshLiteServerLabels()

        MarkConfigDirty()
    end)

    ExtraStayInput =
        HomeLeftBox:AddInput(
            "LiteExtraStay",
            {
                Text = "Extra Stay",
                Default = tostring(RuntimeState.ExtraStaySeconds),
                Placeholder = "10",
                Numeric = true,
                Finished = true,
                ClearTextOnFocus = false,
                ClearTextOnBlur = false,
                AllowEmpty = false,
                EmptyReset = "10",
                MaxLength = 3,
                Tooltip = "After every successful buy, this adds extra time before Auto Hop can continue. It stacks and never delays buying.",
                VerifyValue = function(value)

                    local number =
                        tonumber(value)

                    return number ~= nil
                        and number >= 0
                        and number <= 120
                end,
            }
        )

    ExtraStayInput:OnChanged(function(value)

        RuntimeState.ExtraStaySeconds =
            math.clamp(
                ParseNumberInput(value, 10),
                0,
                120
            )

        RefreshLiteExtraStayInputLabel()
        RefreshLiteServerLabels()

        MarkConfigDirty()
    end)

    RefreshLiteExtraStayInputLabel()


    SniperModeDropdown =
        HomeLeftBox:AddDropdown(
            "LiteSniperMode",
            {
                Text = "Sniper Mode",
                Values = {
                    "Standard",
                    "Rush",
                    "Overdrive",
                    "Custom",
                },
                Default = RuntimeState.SniperMode,
                Tooltip = "Controls how aggressively Lite attempts matching buys.",
            }
        )

    SniperModeDropdown:OnChanged(function(value)

        RuntimeState.SniperMode =
            NormalizeLiteSniperMode(
                value
            )

        RefreshLiteSniperModeVisuals()

        MarkConfigDirty()
    end)

    SniperModeStatusLabel =
        HomeLeftBox:AddLabel({
            Text = "",
            DoesWrap = true,
            Size = 12,
        })

    CustomOpeningStrikeToggle =
        HomeLeftBox:AddToggle(
            "LiteCustomOpeningStrike",
            {
                Text = '<font color="rgb(232,230,240)"><b>OPENING</b></font> <font color="rgb(196,181,253)"><b>STRIKE</b></font>',
                Default = RuntimeState.CustomOpeningStrike == true,
                Tooltip = "Custom only. Direct-buys hardcoded priority targets as soon as they are detected.",
            }
        )

    CustomOpeningStrikeToggle:OnChanged(function(value)

        RuntimeState.CustomOpeningStrike =
            value == true

        RefreshLiteSniperModeVisuals()

        MarkConfigDirty()
    end)

    CustomChainStrikeToggle =
        HomeLeftBox:AddToggle(
            "LiteCustomChainStrike",
            {
                Text = '<font color="rgb(232,230,240)"><b>CHAIN</b></font> <font color="rgb(196,181,253)"><b>STRIKE</b></font>',
                Default = RuntimeState.CustomChainStrike == true,
                Tooltip = "Custom only. If one buy is rejected, instantly tries the next matching listings.",
            }
        )

    CustomChainStrikeToggle:OnChanged(function(value)

        RuntimeState.CustomChainStrike =
            value == true

        RefreshLiteSniperModeVisuals()

        MarkConfigDirty()
    end)

    CustomStrikeLimitInput =
        HomeLeftBox:AddInput(
            "LiteCustomStrikeLimit",
            {
                Text = "Strike Limit",
                Default = tostring(RuntimeState.CustomStrikeLimit),
                Placeholder = "3",
                Numeric = true,
                Finished = true,
                ClearTextOnFocus = false,
                ClearTextOnBlur = false,
                AllowEmpty = false,
                EmptyReset = "3",
                MaxLength = 1,
                Tooltip = "Custom only. Max buy attempts per scan cycle. 1-5.",
                VerifyValue = function(value)

                    local number =
                        tonumber(value)

                    return number ~= nil
                        and number >= 1
                        and number <= 5
                end,
            }
        )

    CustomStrikeLimitInput:OnChanged(function(value)

        RuntimeState.CustomStrikeLimit =
            math.clamp(
                ParseNumberInput(value, 3),
                1,
                5
            )

        RefreshLiteSniperModeVisuals()

        MarkConfigDirty()
    end)

    CustomSilentBuyPathToggle =
        HomeLeftBox:AddToggle(
            "LiteCustomSilentBuyPath",
            {
                Text = '<font color="rgb(232,230,240)"><b>SILENT</b></font> <font color="rgb(196,181,253)"><b>BUY PATH</b></font>',
                Default = RuntimeState.CustomSilentBuyPath == true,
                Tooltip = "Custom only. Skips nonessential pre-buy UI refresh before sending BuyListing.",
            }
        )

    CustomSilentBuyPathToggle:OnChanged(function(value)

        RuntimeState.CustomSilentBuyPath =
            value == true

        RefreshLiteSniperModeVisuals()

        MarkConfigDirty()
    end)

    RefreshLiteSniperModeVisuals()

    local SanctumActionRow =
        HomeLeftBox:AddActionRow("SanctumActionRow", {
            Buttons = {
                {
                    Id = "Copy",
                    Text = "Copy",
                    Tooltip = "Copy current placeId:jobId.",

                    Callback = function()

                        local clipboard =
                            setclipboard
                            or toclipboard
                            or set_clipboard

                        if type(clipboard) ~= "function" then
                            warn("[HOLY SNIPER LITE] Clipboard unsupported.")
                            return
                        end

                        local payload =
                            tostring(game.PlaceId)
                            .. ":"
                            .. tostring(game.JobId)

                        pcall(function()
                            clipboard(payload)
                        end)

                        print("[HOLY SNIPER LITE] Copied server:", payload)
                    end,
                },

                {
                    Id = "Rejoin",
                    Text = "Rejoin",
                    Tooltip = "Rejoin this exact server.",

                    Callback = function()

                        local player =
                            Players.LocalPlayer

                        if not player then
                            warn("[HOLY SNIPER LITE] Rejoin failed: LocalPlayer missing.")
                            return
                        end

                        if type(ClearLiteGatewayInputOnly) == "function" then

                            ClearLiteGatewayInputOnly(
                                "Rejoining exact server..."
                            )
                        end

                        pcall(function()
                            TeleportService:TeleportToPlaceInstance(
                                game.PlaceId,
                                game.JobId,
                                player
                            )
                        end)
                    end,
                },

                {
                    Id = "Hop",
                    Text = "Hop",
                    Tooltip = "Hop using the Server tab route settings.",

                    Callback = function()

                        LiteHopToServer(
                            "manual"
                        )
                    end,
                },

                {
                    Id = "Stop",
                    Text = "STOP",
                    Tooltip = "Emergency stop sniper runtime.",
                    Risky = true,
                    DoubleClick = true,

                    Callback = function()

                        RuntimeState.ForceStopped =
                            true

                        RuntimeState.SniperEnabled =
                            false

                        RuntimeState.AutoHop =
                            false

                        RuntimeState.ExtraStayUntil =
                            0

                        RefreshLiteServerLabels()

                        MarkConfigDirty()

                        warn("[HOLY SNIPER LITE] STOP pressed.")
                    end,
                },
            },
        })

    AvoidUsersStatusLabel =
        AvoidUsersBox:AddLabel({
            Text = '<font color="rgb(125,116,145)"><b>● OFF</b></font>',
            DoesWrap = false,
            Size = 13,
        })

    AvoidUsersBox:AddToggle(
        "LiteAvoidUsersEnabled",
        {
            Text = '<font color="rgb(232,230,240)"><b>ENABLE</b></font> <font color="rgb(196,181,253)"><b>AVOID USERS</b></font>',
            Default = AvoidUsersState.Enabled == true,
            Tooltip = "Checks the current server for watched users.",
        }
    ):OnChanged(function(value)

        AvoidUsersState.Enabled =
            value == true

        AvoidUsersState.StatusText =
            AvoidUsersState.Enabled == true
            and (
                "● Ready · "
                .. tostring(CountLiteAvoidUsers())
                .. " watched"
            )
            or "● Off"

        SaveLiteAvoidUsersNow("toggle enabled")

        RefreshLiteAvoidUsersVisuals()

        if AvoidUsersState.Enabled == true then
            CheckLiteAvoidUsersNow(false)
        end

        MarkConfigDirty()
    end)

    AvoidUsersBox:AddToggle(
        "LiteAvoidUsersAutoHop",
        {
            Text = '<font color="rgb(232,230,240)"><b>AUTO</b></font> <font color="rgb(196,181,253)"><b>HOP ON MATCH</b></font>',
            Default = AvoidUsersState.AutoHopOnMatch == true,
            Tooltip = "If a watched user is found, block this server and hop away.",
        }
    ):OnChanged(function(value)

        AvoidUsersState.AutoHopOnMatch =
            value == true

        SaveLiteAvoidUsersNow("toggle auto hop")

        RefreshLiteAvoidUsersVisuals()

        MarkConfigDirty()
    end)

    AvoidUsersInput =
        AvoidUsersBox:AddInput(
            "LiteAvoidUsersTarget",
            {
                Text = "Target User",
                Default = "",
                Placeholder = "username or userId...",
                Numeric = false,
                Finished = true,
                ClearTextOnFocus = false,
                ClearTextOnBlur = false,
                AllowEmpty = true,
                Tooltip = "Type a username or UserId, then press Add.",
            }
        )

    AvoidUsersInput:OnChanged(function(value)

        AvoidUsersState.RawInput =
            tostring(value or "")

        MarkConfigDirty()
    end)

    local AvoidUsersActionRow =
        AvoidUsersBox:AddActionRow("AvoidUsersActionRow", {
            Buttons = {
                {
                    Id = "Add",
                    Text = "Add",
                    Tooltip = "Add typed username or UserId to the watched list.",

                    Callback = function()

                        AddLiteAvoidUsersFromInput()
                    end,
                },

                {
                    Id = "CheckNow",
                    Text = "Check Now",
                    Tooltip = "Check the current server for watched users.",

                    Callback = function()

                        CheckLiteAvoidUsersNow(true)
                    end,
                },
            },
        })

    AvoidUsersFilterList =
        AvoidUsersBox:AddFilterList("AvoidUsersFilterList", {
            Rows = 8,
            RowHeight = 22,
            HeaderHeight = 18,

            Callback = function(rowIndex, rowData)

                SelectLiteAvoidUserRow(
                    rowIndex,
                    rowData
                )
            end,
        })

    AvoidUsersListLabel =
        AvoidUsersBox:AddLabel({
            Text = "",
            DoesWrap = true,
            Size = 12,
        })

    local AvoidUsersManageRow =
        AvoidUsersBox:AddActionRow("AvoidUsersManageRow", {
            Buttons = {
                {
                    Id = "RemoveSelected",
                    Text = "Remove Selected",
                    Tooltip = "Remove the selected watched user.",

                    Callback = function()

                        RemoveSelectedLiteAvoidUser()

                        MarkConfigDirty()
                    end,
                },

                {
                    Id = "ClearAll",
                    Text = "Clear All",
                    Tooltip = "Clear all watched users.",
                    Risky = true,
                    DoubleClick = true,

                    Callback = function()

                        ClearAllLiteAvoidUsers()

                        MarkConfigDirty()
                    end,
                },
            },
        })

    RefreshLiteAvoidUsersVisuals()

    task.defer(function()

        RefreshLiteAvoidUsersVisuals()
    end)

    StartLiteAvoidUsersWorker()

else

    RuntimeState.SniperEnabled =
        false
end

--==================================================
-- [8.9] WEBHOOK CONTROLS
-- Successful snipe webhook only.
--==================================================

if WebhookConfigBox then

    WebhookConfigBox:AddToggle(
        "LiteWebhookEnabled",
        {
            Text = "Enable Webhook",
            Default = RuntimeState.WebhookEnabled == true,
            Tooltip = "Enables Discord webhook notifications.",
        }
    ):OnChanged(function(value)

        RuntimeState.WebhookEnabled =
            value == true

        MarkConfigDirty()
    end)

    WebhookConfigBox:AddToggle(
        "LiteWebhookSuccessfulSnipes",
        {
            Text = "Successful Snipes",
            Default = RuntimeState.WebhookSuccessfulSnipes == true,
            Tooltip = "Sends a webhook only after a confirmed successful snipe.",
        }
    ):OnChanged(function(value)

        RuntimeState.WebhookSuccessfulSnipes =
            value == true

        MarkConfigDirty()
    end)

    WebhookConfigBox:AddToggle(
        "LiteWebhookRejectedBuys",
        {
            Text = "Rejected Buys",
            Default = RuntimeState.WebhookRejectedBuys == true,
            Tooltip = "Sends a webhook when Holy Lite tried to buy a matched listing, but the game rejected it.",
        }
    ):OnChanged(function(value)

        RuntimeState.WebhookRejectedBuys =
            value == true

        MarkConfigDirty()
    end)

    WebhookConfigBox:AddInput(
        "LiteWebhookURL",
        {
            Text = "Main Webhook URL",
            Default = RuntimeState.WebhookURL,
            Placeholder = "Discord webhook URL",
            Numeric = false,
            Finished = true,
            ClearTextOnFocus = false,
            ClearTextOnBlur = false,
            AllowEmpty = true,
            Tooltip = "Paste your Discord webhook URL, then press Enter.",
        }
    ):OnChanged(function(value)

        RuntimeState.WebhookURL =
            tostring(value or "")

        MarkConfigDirty()
    end)

        TimingDebugWarningLabel =
        WebhookConfigBox:AddLabel({
            Text =
                '<font color="rgb(245,158,11)"><b>⚠ TIMING DEBUG WARNING</b></font>\n'
                .. '<font color="rgb(232,230,240)">Sends extra Discord requests after buy attempts. '
                .. 'Keep this OFF unless testing speed/rejects. It never sends before BuyListing, '
                .. 'but extra webhook traffic can still add load after attempts.</font>',
            DoesWrap = true,
            Size = 12,
        })

    WebhookConfigBox:AddToggle(
        "LiteTimingDebugEnabled",
        {
            Text = "Timing Debug",
            Default = RuntimeState.TimingDebugEnabled == true,
            Tooltip = "Debug-only. Sends post-buy timing reports to Discord. Keep OFF unless testing.",
        }
    ):OnChanged(function(value)

        RuntimeState.TimingDebugEnabled =
            value == true

        if value == true then

            warn(
                "[HOLY SNIPER LITE] Timing Debug enabled. This sends extra webhook requests after buy attempts. Keep OFF unless testing."
            )
        end

        MarkConfigDirty()
    end)

    TimingDebugURLInput =
        WebhookConfigBox:AddInput(
            "LiteTimingDebugURL",
            {
                Text = "Timing Webhook URL",
                Default = RuntimeState.TimingDebugURL,
                Placeholder = "Discord webhook URL",
                Numeric = false,
                Finished = true,
                ClearTextOnFocus = false,
                ClearTextOnBlur = false,
                AllowEmpty = true,
                Tooltip = "Optional debug webhook. Receives timing reports after buy attempts only.",
            }
        )

    TimingDebugURLInput:OnChanged(function(value)

        RuntimeState.TimingDebugURL =
            tostring(value or "")

        MarkConfigDirty()
    end)

        WebhookConfigBox:AddButton({
        Text = "Test Timing Webhook",
        Tooltip = "Sends a fake timing debug embed. Does not buy anything.",
        Func = function()

            if RuntimeState.TimingDebugEnabled ~= true then

                warn("[HOLY SNIPER LITE] Timing test failed: Timing Debug is OFF.")

                return
            end

            if CleanText(RuntimeState.TimingDebugURL) == "" then

                warn("[HOLY SNIPER LITE] Timing test failed: Timing Webhook URL is empty.")

                return
            end

            local fakeCandidate = {
                WatchlistId = 0,
                PetName = "Timing Test",

                Filter = {
                    Priority = "Debug",
                },

                Listing = {
                    PetName = "Timing Test",
                    Price = 1,
                    DisplayWeight = 0,
                    BaseWeight = 0,
                    Age = "?",
                    BoothId = "Debug",
                    UID = "Debug",
                    SellerUserId = 0,
                },

                Reason = "Debug Test",
            }

            QueueLiteTimingDebugWebhook(
                fakeCandidate,
                {
                    Result =
                        "Test",

                    Reason =
                        "Webhook check",

                    Path =
                        "Debug Test",

                    Mode =
                        tostring(RuntimeState.SniperMode or "Standard"),

                    StrikeIndex =
                        1,

                    StrikeLimit =
                        1,

                    CycleMs =
                        1.23,

                    DetectMs =
                        0.25,

                    ExtractMs =
                        0.40,

                    MatchMs =
                        0.20,

                    BuyInvokeMs =
                        0.38,

                    SilentBuyPath =
                        false,
                }
            )
        end,
    })
end

--==================================================
-- [9.0] SERVER CONTROLS
-- Route settings used by Sanctum Hop and Sniper Auto Hop.
--==================================================

if ServerRouteBox then

    ServerRouteBox:AddDropdown(
        "LiteServerMode",
        {
            Text = "Mode",
            Values = {
                "Fullest Under Max",
                "Balanced",
                "Low Player",
            },
            Default = NormalizeLiteServerMode(ServerState.Mode),
            Searchable = false,
            MaxVisibleDropdownItems = 3,
            Tooltip = "Controls how Hop and Auto Hop choose the next server.",
        }
    ):OnChanged(function(value)

        ServerState.Mode =
            NormalizeLiteServerMode(value)

        MarkConfigDirty()
    end)

    ServerRouteBox:AddInput(
        "LiteServerMaxPlayers",
        {
            Text = "Max Players",
            Default = tostring(ServerState.MaxPlayers),
            Placeholder = "30",
            Numeric = true,
            Finished = false,
            ClearTextOnFocus = false,
            AllowEmpty = false,
            EmptyReset = "30",
            MaxLength = 3,
            Tooltip = "Only hop to servers with this many players or fewer.",
            VerifyValue = function(value)

                local number =
                    tonumber(value)

                return number ~= nil
                    and number >= 1
                    and number <= 100
            end,
        }
    ):OnChanged(function(value)

        ServerState.MaxPlayers =
            math.clamp(
                ParseNumberInput(value, 30),
                1,
                100
            )

        MarkConfigDirty()
    end)

    ServerRouteBox:AddInput(
        "LiteServerSearchPages",
        {
            Text = "Search Pages",
            Default = tostring(ServerState.SearchPages),
            Placeholder = "0",
            Numeric = true,
            Finished = false,
            ClearTextOnFocus = false,
            AllowEmpty = false,
            EmptyReset = "0",
            MaxLength = 3,
            Tooltip = "0 uses default search. 1-100 checks that exact amount of server pages.",
            VerifyValue = function(value)

                local number =
                    tonumber(value)

                return number ~= nil
                    and number >= 0
                    and number <= 100
            end,
        }
    ):OnChanged(function(value)

        ServerState.SearchPages =
            math.clamp(
                ParseNumberInput(value, 0),
                0,
                100
            )

        MarkConfigDirty()
    end)

    ServerRouteBox:AddToggle(
        "LiteServerAvoidRecent",
        {
            Text = "Avoid Recent",
            Default = ServerState.AvoidRecent == true,
            Tooltip = "Avoids servers this client recently visited.",
        }
    ):OnChanged(function(value)

        ServerState.AvoidRecent =
            value == true

        MarkConfigDirty()
    end)
end

if ServerCurrentBox then

    ServerJobIdLabel =
        ServerCurrentBox:AddLabel(
            "JobId: " .. tostring(game.JobId),
            false
        )

    ServerPlayersLabel =
        ServerCurrentBox:AddLabel(
            "Players: " .. tostring(#Players:GetPlayers()) .. " / " .. tostring(Players.MaxPlayers),
            false
        )

    ServerAutoHopLabel =
        ServerCurrentBox:AddLabel(
            "Auto Hop: Off",
            false
        )

    ServerMemoryLabel =
        ServerCurrentBox:AddLabel(
            "Memory: Recent 0 · Blocked 0",
            false
        )

    RefreshLiteServerLabels()
end

if ServerGatewayBox then

    GatewayHudToggle =
        ServerGatewayBox:AddToggle(
            "LiteGatewayHudEnabled",
            {
                Text = "Enable Gateway HUD",
                Default = GatewayState.HudEnabled == true,
                Tooltip = "Shows a small draggable quick-join HUD.",
            }
        )

    GatewayHudToggle:OnChanged(function(value)

        SetLiteGatewayHudEnabled(
            value == true
        )
    end)

    GatewayTargetInput =
        ServerGatewayBox:AddInput(
            "LiteGatewayTargetServer",
            {
                Text = "Target Server",
                Default = GatewayState.TargetText,
                Placeholder = "placeId:jobId or roblox:// link...",
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                ClearTextOnBlur = false,
                AllowEmpty = true,
                Tooltip = "Only joins the exact server you paste. If it fails or is full, Lite will not random-hop.",
            }
        )

    GatewayTargetInput:OnChanged(function(value)

        GatewayState.TargetText =
            tostring(value or "")

        GatewayState.StatusText =
            GatewayState.TargetText == ""
            and "Paste a server link."
            or "Target updated."

        RefreshLiteGatewayVisuals()

        -- Do NOT MarkConfigDirty here.
        -- Gateway pasted links are temporary and should not autosave.
    end)

    GatewayPreviewLabel =
        ServerGatewayBox:AddLabel({
            Text = "Paste a server link.",
            DoesWrap = true,
            Size = 13,
        })

    ServerGatewayBox:AddButton({
        Text = "Join Server",
        Tooltip = "Join the exact pasted server only. No random fallback.",
        Func = function()

            JoinLiteExactGatewayTarget()
        end,
    })

    local GatewayCopyButton =
        ServerGatewayBox:AddButton({
            Text = "Copy Current",
            Tooltip = "Copy current placeId:jobId.",
            Func = function()

                CopyLiteCurrentServerToClipboard()
            end,
        })

    GatewayCopyButton:AddButton({
        Text = "Rejoin",
        Tooltip = "Rejoin this exact current server.",
        Func = function()

            RejoinLiteExactCurrentServer()
        end,
    })

    local GatewayClearButton =
        ServerGatewayBox:AddButton({
            Text = "Clear",
            Tooltip = "Clear the gateway input.",
            Func = function()

                ClearLiteGatewayTarget()
            end,
        })

    GatewayClearButton:AddButton({
        Text = "Use Last",
        Tooltip = "Load the last gateway target.",
        Func = function()

            UseLiteLastGatewayTarget()
        end,
    })

    RefreshLiteGatewayVisuals()
end

if ServerMemoryBox then

    ServerMemoryBox:AddInput(
        "LiteServerBlockDuration",
        {
            Text = "Block Duration",
            Default = tostring(ServerState.BlockDuration),
            Placeholder = "60",
            Numeric = true,
            Finished = false,
            ClearTextOnFocus = false,
            AllowEmpty = false,
            EmptyReset = "60",
            MaxLength = 4,
            Tooltip = "Minutes to keep a manually blocked server blocked.",
            VerifyValue = function(value)

                local number =
                    tonumber(value)

                return number ~= nil
                    and number >= 1
                    and number <= 1440
            end,
        }
    ):OnChanged(function(value)

        ServerState.BlockDuration =
            math.clamp(
                ParseNumberInput(value, 60),
                1,
                1440
            )

        MarkConfigDirty()
    end)

    local ServerCopyJobIdButton =
        ServerMemoryBox:AddButton({
            Text = "Copy JobId",
            Tooltip = "Copy only the current server JobId.",
            Func = function()

                local clipboard =
                    setclipboard
                    or toclipboard
                    or set_clipboard

                if type(clipboard) ~= "function" then
                    warn("[HOLY SNIPER LITE] Clipboard unsupported.")
                    return
                end

                pcall(function()
                    clipboard(tostring(game.JobId))
                end)

                print("[HOLY SNIPER LITE] Copied JobId:", tostring(game.JobId))
            end,
        })

    ServerCopyJobIdButton:AddButton({
        Text = "Block Server",
        Tooltip = "Block the current server from future hops.",
        Risky = true,
        Func = function()

            ShowLiteConfirmDialog(
                "LiteBlockCurrentServer",
                "Block Current Server",
                "This will block the current server for "
                    .. tostring(ServerState.BlockDuration)
                    .. " minutes. Hop and Auto Hop will avoid it.",
                "Block Server",
                true,
                function()

                    BlockLiteServer(
                        game.JobId,
                        ServerState.BlockDuration
                    )

                    RefreshLiteServerLabels()

                    warn(
                        "[HOLY SNIPER LITE] Blocked current server for",
                        tostring(ServerState.BlockDuration),
                        "minutes."
                    )
                end
            )
        end,
    })

    local ServerClearRecentButton =
        ServerMemoryBox:AddButton({
            Text = "Clear Recent",
            Tooltip = "Clear recent server memory.",
            Func = function()

                ShowLiteConfirmDialog(
                    "LiteClearRecentServers",
                    "Clear Recent Servers",
                    "This clears recent server memory. Hop may return to servers visited earlier.",
                    "Clear Recent",
                    false,
                    function()

                        ClearLiteTable(
                            ServerState.RecentServers
                        )

                        RefreshLiteServerLabels()

                        print("[HOLY SNIPER LITE] Cleared recent servers.")
                    end
                )
            end,
        })

    ServerClearRecentButton:AddButton({
        Text = "Clear Blocked",
        Tooltip = "Clear blocked server memory.",
        Risky = true,
        Func = function()

            ShowLiteConfirmDialog(
                "LiteClearBlockedServers",
                "Clear Blocked Servers",
                "This removes all manually blocked servers. Auto Hop can choose them again.",
                "Clear Blocked",
                true,
                function()

                    ClearLiteTable(
                        ServerState.BlockedServers
                    )

                    RefreshLiteServerLabels()

                    warn("[HOLY SNIPER LITE] Cleared blocked servers.")
                end
            )
        end,
    })
end

--==================================================
-- [9.1] SNIPER FILTER CONTROLS
-- Visual setup only. No filter saving/scanner logic yet.
--==================================================

if SniperFilterBox then

    FilterSaveButtons[1] =
        SniperFilterBox:AddButton({
            Text = FormatSaveTargetButton(1),
            Tooltip = "Save new filters into W1 Main.",
            Func = function()
                SetFilterSaveTarget(1)
            end,
        })

    FilterSaveButtons[2] =
        FilterSaveButtons[1]:AddButton({
            Text = FormatSaveTargetButton(2),
            Tooltip = "Save new filters into W2 Alt.",
            Func = function()
                SetFilterSaveTarget(2)
            end,
        })

    FilterSaveButtons[3] =
        FilterSaveButtons[1]:AddButton({
            Text = FormatSaveTargetButton(3),
            Tooltip = "Save new filters into Eggs.",
            Func = function()
                SetFilterSaveTarget(3)
            end,
        })

    RefreshSaveTargetButtons()

    LiteAllowMultiSelectToggle =
        SniperFilterBox:AddToggle(
            "LiteAllowMultiSelectPets",
            {
                Text = "Allow Multi Select",
                Default = FilterState.AllowMultiSelectPets == true,
                Tooltip = "Allows selecting multiple pets and applying the same filter settings to all of them later.",
            }
        )

    LiteAllowMultiSelectToggle:OnChanged(function(value)

        FilterState.AllowMultiSelectPets =
            value == true

        SetControlVisible(
            SinglePetDropdown,
            FilterState.AllowMultiSelectPets ~= true
        )

        SetControlVisible(
            MultiPetDropdown,
            FilterState.AllowMultiSelectPets == true
        )

        SetControlVisible(
            SingleEggDropdown,
            FilterState.AllowMultiSelectPets ~= true
        )

        SetControlVisible(
            MultiEggDropdown,
            FilterState.AllowMultiSelectPets == true
        )

        MarkConfigDirty()
    end)

    SinglePetDropdown =
        SniperFilterBox:AddDropdown(
            "LiteSinglePet",
            {
                Text = "Pet",
                Values = DynamicPetList,
                Default = FilterState.SelectedPet,
                Searchable = true,
                Multi = false,
                Visible = FilterState.AllowMultiSelectPets ~= true,
            }
        )

    SinglePetDropdown:OnChanged(function(value)

        local petName =
            CleanText(value)

        if petName == "" then
            petName =
                "None"
        end

        FilterState.SelectedPet =
            petName

        FilterState.SelectedPets =
            {}

        if petName ~= "None" then
            FilterState.SelectedPets[petName] =
                true
        end

        MarkConfigDirty()
    end)

    SingleEggDropdown =
        SniperFilterBox:AddDropdown(
            "LiteSingleEgg",
            {
                Text = "Egg",
                Values = DynamicEggList,
                Default = FilterState.SelectedEgg,
                Searchable = true,
                Multi = false,
                Visible = FilterState.AllowMultiSelectPets ~= true,
                Tooltip = "Imports all pets from this egg into the Eggs watchlist.",
            }
        )

    SingleEggDropdown:OnChanged(function(value)

        local eggName =
            CleanText(value)

        if eggName == "" then
            eggName =
                "None"
        end

        FilterState.SelectedEgg =
            eggName

        FilterState.SelectedEggs =
            {}

        if eggName ~= "None" then
            FilterState.SelectedEggs[eggName] =
                true
        end

        MarkConfigDirty()
    end)

    MultiPetDropdown =
        SniperFilterBox:AddDropdown(
            "LiteMultiPets",
            {
                Text = "Pets",
                Values = DynamicPetList,
                Default = {},
                Searchable = true,
                Multi = true,
                Visible = FilterState.AllowMultiSelectPets == true,
            }
        )

    MultiPetDropdown:OnChanged(function(value)

        FilterState.SelectedPets =
            BuildDropdownSelectionMap(value)

        MarkConfigDirty()
    end)

    MultiEggDropdown =
        SniperFilterBox:AddDropdown(
            "LiteMultiEggs",
            {
                Text = "Eggs",
                Values = DynamicEggList,
                Default = {},
                Searchable = true,
                Multi = true,
                Visible = FilterState.AllowMultiSelectPets == true,
                Tooltip = "Imports all pets from selected eggs into the Eggs watchlist.",
            }
        )

    MultiEggDropdown:OnChanged(function(value)

        FilterState.SelectedEggs =
            BuildDropdownSelectionMap(value)

        MarkConfigDirty()
    end)

    MaxPriceInput =
        SniperFilterBox:AddInput(
            "LiteMaxPrice",
            {
                Text = "Max Price",
                Default = "",
                Placeholder = "Example: 1000",
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
            }
        )

    MaxPriceInput:OnChanged(function(value)

        local number =
            ParseOptionalNumberInput(value)

        if not number
        or number <= 0 then

            FilterState.MaxPrice =
                nil

            FilterState.MaxPriceWasEntered =
                false

            RefreshLiteFilterInputLabels()

            MarkConfigDirty()

            return
        end

        FilterState.MaxPrice =
            math.floor(number)

        FilterState.MaxPriceWasEntered =
            true

        RefreshLiteFilterInputLabels()

        MarkConfigDirty()
    end)

    MinWeightInput =
        SniperFilterBox:AddInput(
            "LiteMinWeight",
            {
                Text = "Min Weight",
                Default = "0",
                Placeholder = "Example: 0.1",
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
            }
        )

    MinWeightInput:OnChanged(function(value)

        local number =
            ParseOptionalNumberInput(value)

        if not number
        or number < 0 then

            FilterState.MinWeight =
                0

            FilterState.MinWeightWasEntered =
                false

            RefreshLiteFilterInputLabels()

            MarkConfigDirty()

            return
        end

        FilterState.MinWeight =
            number

        FilterState.MinWeightWasEntered =
            true

        RefreshLiteFilterInputLabels()

        MarkConfigDirty()
    end)

    WeightModeDropdown =
        SniperFilterBox:AddDropdown(
        "LiteWeightMode",
        {
            Text = "Weight Mode",
            Values = {
                "Base Weight",
                "Display Weight",
            },
            Default = FilterState.WeightMode,
            Searchable = false,
        }
    ):OnChanged(function(value)

        FilterState.WeightMode =
            tostring(value or "Base Weight")

        MarkConfigDirty()
    end)

    PriorityDropdown =
        SniperFilterBox:AddDropdown(
        "LitePriority",
        {
            Text = "Priority",
            Values = {
                "Low",
                "Normal",
                "High",
            },
            Default = FilterState.Priority,
            Searchable = false,
        }
    ):OnChanged(function(value)

        FilterState.Priority =
            tostring(value or "Normal")

        MarkConfigDirty()
    end)

    MutationModeDropdown =
        SniperFilterBox:AddDropdown(
            "LiteMutationMode",
            {
                Text = "Mutation Filter",
                Values = {
                    "Off",
                    "Mutated Only",
                    "Specific Mutations",
                    "Exclude Mutations",
                },
                Default = FilterState.MutationMode,
                Searchable = false,
            }
        )

    MutationModeDropdown:OnChanged(function(value)

        FilterState.MutationMode =
            CleanText(value)

        if FilterState.MutationMode == "" then
            FilterState.MutationMode =
                "Off"
        end

        if FilterState.MutationMode == "Off" then

            FilterState.SelectedMutations =
                {}

            SetControlValue(
                MutationDropdown,
                {}
            )
        end

        SetControlVisible(
            MutationDropdown,
            ShouldShowMutationDropdown()
        )

        MarkConfigDirty()
    end)

    MutationDropdown =
        SniperFilterBox:AddDropdown(
            "LiteMutationSelection",
            {
                Text = "Mutations",
                Values = DynamicMutationList,
                Default = {},
                Searchable = true,
                Multi = true,
                Visible = ShouldShowMutationDropdown(),
            }
        )

    MutationDropdown:OnChanged(function(value)

        FilterState.SelectedMutations =
            BuildDropdownSelectionMap(value)

        MarkConfigDirty()
    end)

    SetControlVisible(
        MutationDropdown,
        ShouldShowMutationDropdown()
    )

    local AddUpdateFilterButton =
        SniperFilterBox:AddButton({
            Text = "Add / Update Filter",
            Tooltip = "Saves selected pet(s) into the selected watchlist.",
            Func = function()

                SaveCurrentFilter()
            end,
        })

    AddUpdateFilterButton:AddButton({
        Text = "Add Eggs",
        Tooltip = "Imports selected egg pet pools into the Eggs watchlist.",
        Func = function()

            SaveCurrentEggImport()
        end,
    })

    AddUpdateFilterButton:AddButton({
        Text = "Reset",
        Tooltip = "Reset current filter inputs.",
        Func = function()

            FilterState.AllowMultiSelectPets =
                false

            FilterState.SelectedPet =
                "None"

            FilterState.SelectedPets =
                {}

            FilterState.SelectedEgg =
                "None"

            FilterState.SelectedEggs =
                {}

            FilterState.MaxPrice =
                nil

            FilterState.MaxPriceWasEntered =
                false

            FilterState.MinWeight =
                0

            FilterState.MinWeightWasEntered =
                false

            FilterState.WeightMode =
                "Base Weight"

            FilterState.Priority =
                "Normal"

            FilterState.MutationMode =
                "Off"

            FilterState.SelectedMutations =
                {}

            SetControlValue(
                LiteAllowMultiSelectToggle,
                false
            )

            SetControlVisible(
                SinglePetDropdown,
                true
            )

            SetControlVisible(
                MultiPetDropdown,
                false
            )

            SetControlVisible(
                SingleEggDropdown,
                true
            )

            SetControlVisible(
                MultiEggDropdown,
                false
            )

            SetControlValue(
                SinglePetDropdown,
                "None"
            )

            ClearLiteMultiDropdown(
                MultiPetDropdown
            )

            SetControlValue(
                SingleEggDropdown,
                "None"
            )

            ClearLiteMultiDropdown(
                MultiEggDropdown
            )

            SetControlValue(
                MaxPriceInput,
                ""
            )

            SetControlValue(
                MinWeightInput,
                "0"
            )

            SetControlValue(
                WeightModeDropdown,
                "Base Weight"
            )

            SetControlValue(
                PriorityDropdown,
                "Normal"
            )

            SetControlValue(
                MutationModeDropdown,
                "Off"
            )

            ClearLiteMultiDropdown(
                MutationDropdown
            )

            SetControlVisible(
                MutationDropdown,
                false
            )

            RefreshLiteFilterInputLabels()

            MarkConfigDirty()

            print("[HOLY SNIPER LITE] Filter reset.")
        end,
    })

    RefreshLiteFilterInputLabels()
end

--==================================================
-- [9.2] SNIPER WATCHLIST CONTROLS
-- Compact visible watchlist rows only.
-- No load/remove/clear/scanner logic yet.
--==================================================

if SniperWatchlistBox then

    WatchlistViewButtons[1] =
        SniperWatchlistBox:AddButton({
            Text = FormatWatchlistViewButton(1),
            Tooltip = "View W1 Main filters.",
            Func = function()
                SetWatchlistViewTarget(1)
            end,
        })

    WatchlistViewButtons[2] =
        WatchlistViewButtons[1]:AddButton({
            Text = FormatWatchlistViewButton(2),
            Tooltip = "View W2 Alt filters.",
            Func = function()
                SetWatchlistViewTarget(2)
            end,
        })

    WatchlistViewButtons[3] =
        WatchlistViewButtons[1]:AddButton({
            Text = FormatWatchlistViewButton(3),
            Tooltip = "View Eggs filters.",
            Func = function()
                SetWatchlistViewTarget(3)
            end,
        })

    SniperWatchlistBox:AddInput(
        "LiteWatchlistSearch",
        {
            Text = "Search",
            Default = WatchlistState.SearchText,
            Placeholder = "Search filters...",
            Numeric = false,
            Finished = false,
            ClearTextOnFocus = false,
        }
    ):OnChanged(function(value)

        WatchlistState.SearchText =
            tostring(value or "")

        WatchlistState.Page =
            1

        if type(RefreshWatchlist) == "function" then
            RefreshWatchlist()
        end

        MarkConfigDirty()
    end)

    WatchlistStatusLabel =
        SniperWatchlistBox:AddLabel(
            "W1 Main · 0 filters · Page 1/1",
            false
        )

    if type(SniperWatchlistBox.AddFilterList) == "function" then

        WatchlistFilterList =
            SniperWatchlistBox:AddFilterList(
                "LiteWatchlistFilterList",
                {
                    Rows = WatchlistState.PerPage,
                    RowHeight = 24,
                    HeaderHeight = 20,
                    Callback = function(rowIndex)

                        SelectWatchlistRow(rowIndex)
                    end,
                }
            )

    else

        for rowIndex = 1, WatchlistState.PerPage do

            WatchlistRowButtons[rowIndex] =
                SniperWatchlistBox:AddButton({
                    Text = " ",
                    Tooltip = "Click to select this saved filter.",
                    Func = function()
                        SelectWatchlistRow(rowIndex)
                    end,
                })
        end
    end

    local WatchlistPrevButton =
        SniperWatchlistBox:AddButton({
            Text = "Prev",
            Tooltip = "Previous watchlist page.",
            Func = function()

                WatchlistState.Page =
                    math.max(
                        1,
                        (tonumber(WatchlistState.Page) or 1) - 1
                    )

                RefreshWatchlist()
            end,
        })

    WatchlistPrevButton:AddButton({
        Text = "Next",
        Tooltip = "Next watchlist page.",
        Func = function()

            WatchlistState.Page =
                (tonumber(WatchlistState.Page) or 1) + 1

            RefreshWatchlist()
        end,
    })

    local WatchlistEditButton =
        SniperWatchlistBox:AddButton({
            Text = "Edit",
            Tooltip = "Edit the selected saved filter in a popup.",
            Func = function()

                ShowEditWatchlistFilterDialog()
            end,
        })

    WatchlistEditButton:AddButton({
        Text = "Remove",
        Tooltip = "Remove the selected saved filter.",
        Func = function()
            RemoveSelectedWatchlistFilter()
        end,
    })

    SniperWatchlistBox:AddButton({
        Text = "Clear",
        Tooltip = "Clear the currently viewed watchlist.",
        Risky = true,
        DoubleClick = true,
        Func = function()
            ClearCurrentWatchlist()
        end,
    })

    SniperWatchlistBox:AddLabel({
        Text = '<font color="rgb(196,181,253)"><b>TRANSFER</b></font>',
        DoesWrap = false,
        Size = 13,
    })

    SniperWatchlistBox:AddButton({
        Text = "Copy Watchlist",
        Tooltip = "Copies all W1, W2, and Eggs filters in main-script compatible HOLY_WL format.",
        Func = function()

            CopyLiteWatchlistExport()
        end,
    })

    WatchlistImportPasteInput =
        SniperWatchlistBox:AddInput(
            "LiteWatchlistImportPaste",
            {
                Text = "Paste Watchlist Filters",
                Default = "",
                Placeholder = "Paste main/lite watchlist code...",
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                ClearTextOnBlur = false,
                AllowEmpty = true,
                Tooltip = "Paste a HOLY_WL watchlist export from main script or Lite.",
            }
        )

    WatchlistImportPasteInput:OnChanged(function(value)

        WatchlistTransferState.ImportText =
            tostring(value or "")

        if WatchlistTransferState.ImportText == "" then

            WatchlistTransferState.PreviewText =
                "Paste watchlist code."

            RefreshLiteWatchlistImportPreview()
        end
    end)

    local WatchlistClearPasteButton =
        SniperWatchlistBox:AddButton({
            Text = "Clear Paste",
            Tooltip = "Clears the pasted watchlist code without manually selecting text.",
            Func = function()

                ClearLiteWatchlistImportPaste()
            end,
        })

    WatchlistClearPasteButton:AddButton({
        Text = "Preview",
        Tooltip = "Checks the pasted watchlist code without importing it.",
        Func = function()

            PreviewLiteWatchlistImport()
        end,
    })

    WatchlistImportPreviewLabel =
        SniperWatchlistBox:AddLabel({
            Text = "Paste watchlist code.",
            DoesWrap = true,
            Size = 13,
        })

    local WatchlistReplaceImportButton =
        SniperWatchlistBox:AddButton({
            Text = "Replace",
            Tooltip = "Clears current Lite watchlists, then imports the pasted filters.",
            Risky = true,
            DoubleClick = true,
            Func = function()

                ImportLiteWatchlistsFromPaste(
                    "Replace"
                )
            end,
        })

    WatchlistReplaceImportButton:AddButton({
        Text = "Add / Merge",
        Tooltip = "Keeps current filters and adds or updates filters from the pasted code.",
        Func = function()

            ImportLiteWatchlistsFromPaste(
                "Merge"
            )
        end,
    })

    RefreshLiteWatchlistImportPreview()

    RefreshWatchlist()
end

--==================================================
-- [9.3] SNIPER RUNTIME CONTROLS
-- Read-only booth data test.
-- No extraction/matching/buying yet.
--==================================================

if SniperRuntimeBox then

    RuntimeStatusLabel =
        SniperRuntimeBox:AddLabel(
            "Status: Idle",
            false
        )

    RuntimeBoothDataLabel =
        SniperRuntimeBox:AddLabel(
            "Booth Data: Not ready",
            false
        )

    RuntimeBoothCountLabel =
        SniperRuntimeBox:AddLabel(
            "Booths: 0",
            false
        )

    RuntimePlayerCountLabel =
        SniperRuntimeBox:AddLabel(
            "Player Data: 0",
            false
        )

    RuntimeListingsLabel =
        SniperRuntimeBox:AddLabel(
            "Listings: 0",
            false
        )

    RuntimeScannedLabel =
        SniperRuntimeBox:AddLabel(
            "Scanned: 0",
            false
        )

    RuntimeExtractLabel =
        SniperRuntimeBox:AddLabel(
            "Extract: 0.00ms",
            false
        )

    RuntimeMatchesLabel =
        SniperRuntimeBox:AddLabel(
            "Matches: 0",
            false
        )

    RuntimeMatchTimeLabel =
        SniperRuntimeBox:AddLabel(
            "Match: 0.00ms",
            false
        )

    RuntimeLastMatchLabel =
        SniperRuntimeBox:AddLabel(
            "Last Match: None",
            false
        )

    RuntimeBestLabel =
        SniperRuntimeBox:AddLabel(
            "Best: None",
            false
        )

    RuntimeBestPriceLabel =
        SniperRuntimeBox:AddLabel(
            "Best Price: 0",
            false
        )

    RuntimeBestBoothLabel =
        SniperRuntimeBox:AddLabel(
            "Best Booth: None",
            false
        )

    RuntimePriorityTargetLabel =
        SniperRuntimeBox:AddLabel(
            "Priority Target: None",
            false
        )

    RuntimeBuyRemoteLabel =
        SniperRuntimeBox:AddLabel(
            "Buy Remote: Not resolved",
            false
        )

    RuntimeBuyStatusLabel =
        SniperRuntimeBox:AddLabel(
            "Buy Status: Idle",
            false
        )

    local RefreshBoothDataButton =
        SniperRuntimeBox:AddButton({
            Text = "Refresh Booth Data",
            Tooltip = "Fetch current Trade World booth data. Read-only.",
            Func = function()

                local data, result =
                    RefreshLatestBoothDataNow(
                        "manual button"
                    )

                if data then
                    print("[HOLY SNIPER LITE] Manual booth refresh OK.")
                else
                    warn(
                        "[HOLY SNIPER LITE] Manual booth refresh failed:",
                        tostring(result)
                    )
                end
            end,
        })

    RefreshBoothDataButton:AddButton({
        Text = "Extract Listings",
        Tooltip = "Extract current pet listings from booth data. Read-only.",
        Func = function()

            RefreshLatestBoothDataNow(
                "extract button refresh"
            )

            ExtractLiteListings()
        end,
    })

    RefreshBoothDataButton:AddButton({
        Text = "Test Matches",
        Tooltip = "Match current listings against saved filters. Read-only.",
        Func = function()

            RefreshLatestBoothDataNow(
                "match button refresh"
            )

            ExtractLiteListings()

            TestLiteMatches()
        end,
    })

    SniperRuntimeBox:AddButton({
        Text = "Preview Best Candidate",
        Tooltip = "Pick the best current match without buying.",
        Func = function()

            PreviewLiteBestCandidate()
        end,
    })

    local ResolveBuyRemoteButton =
        SniperRuntimeBox:AddButton({
            Text = "Resolve Buy Remote",
            Tooltip = "Find the game's listing purchase remote.",
            Func = function()

                ResolveLiteBuyListingRemote()
            end,
        })

    ResolveBuyRemoteButton:AddButton({
        Text = "Buy Best Candidate",
        Tooltip = "Manually buy the current best candidate.",
        Risky = true,
        DoubleClick = true,
        Func = function()

            BuyLiteBestCandidate()
        end,
    })
    RefreshLiteRuntimeLabels()
end

--==================================================
-- [9.34] DEV EXEC HELPERS
--==================================================

function SafeLiteDevExec(url, label)

    if not IsLiteDeveloper() then
        warn("[HOLY LITE DEV] Blocked: developer access required.")
        return false
    end

    if RuntimeState
    and RuntimeState.ForceStopped == true then
        warn("[HOLY LITE DEV] Blocked: ForceStopped is active.")
        return false
    end

    url =
        tostring(url or "")

    label =
        tostring(label or "Dev Tool")

    if url == "" then
        warn("[HOLY LITE DEV] Missing URL for", label)
        return false
    end

    task.spawn(function()

        print("[HOLY LITE DEV] Loading:", label)

        local okSource, source =
            pcall(function()
                return game:HttpGet(url)
            end)

        if okSource ~= true
        or type(source) ~= "string"
        or source == "" then
            warn("[HOLY LITE DEV] HttpGet failed:", label)
            return
        end

        local chunk, compileErr =
            loadstring(source)

        if type(chunk) ~= "function" then
            warn(
                "[HOLY LITE DEV] Compile failed:",
                label,
                tostring(compileErr)
            )

            return
        end

        local okRun, runErr =
            pcall(chunk)

        if okRun ~= true then
            warn(
                "[HOLY LITE DEV] Runtime failed:",
                label,
                tostring(runErr)
            )

            return
        end

        print("[HOLY LITE DEV] Loaded:", label)
    end)

    return true
end

--==================================================
-- [9.35] DEV CONTROLS
--==================================================

if DevToolsBox then

    DevToolsBox:AddLabel({
        Text = '<font color="rgb(196,181,253)"><b>DEVELOPER TOOLS</b></font>',
        DoesWrap = false,
        Size = 14,
    })

    DevToolsBox:AddButton({
        Text = "Remote Spy",
        Tooltip = "Open Remote Spy to inspect remote calls.",
        Func = function()

            SafeLiteDevExec(
                "https://raw.githubusercontent.com/Klinac/scripts/main/utopia_spy.lua",
                "Remote Spy"
            )
        end,
    })

    DevToolsBox:AddButton({
        Text = "Dex Explorer",
        Tooltip = "Open Dex Explorer to inspect the live game tree.",
        Func = function()

            SafeLiteDevExec(
                "https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua",
                "Dex Explorer"
            )
        end,
    })

    DevToolsBox:AddLabel({
        Text = '<font color="rgb(125,116,145)"><b>INFO</b></font>',
        DoesWrap = false,
        Size = 13,
    })

    DevToolsBox:AddLabel({
        Text = "Remote Spy logs remote calls.\nDex lets you inspect the live game tree.",
        DoesWrap = true,
        Size = 13,
    })
end

--==================================================
-- [9.4] SETTINGS CONTROLS
--==================================================

if SettingsInterfaceBox then

    SettingsInterfaceBox:AddToggle(
        "LiteShowUIOnLoad",
        {
            Text = "Show UI On Load",
            Default = LiteUIState.ShowUIOnLoad == true,
            Tooltip = "Shows Holy Lite automatically when the script executes. Turn off to keep it hidden until you press the toggle key.",
        }
    ):OnChanged(function(value)

        LiteUIState.ShowUIOnLoad =
            value == true

        SaveLiteUISettingsNow()

        MarkConfigDirty()

        print(
            "[HOLY SNIPER LITE] Show UI On Load:",
            tostring(LiteUIState.ShowUIOnLoad)
        )
    end)

    SettingsInterfaceBox:AddToggle(
        "LiteAutoTeleportTradeWorld",
        {
            Text = "Auto Teleport Trade World",
            Default = LiteUIState.AutoTeleportTradeWorld == true,
            Tooltip = "When enabled, Holy Lite waits 10 seconds after execution, then teleports to Trade World. Turn off during countdown to cancel.",
        }
    ):OnChanged(function(value)

        LiteUIState.AutoTeleportTradeWorld =
            value == true

        SaveLiteUISettingsNow()

        MarkConfigDirty()

        if LiteUIState.AutoTeleportTradeWorld == true then

            RequestLiteTradeWorldTeleportCountdown(
                "settings toggle"
            )

        else

            CancelLiteTradeWorldTeleportCountdown()
        end

        print(
            "[HOLY SNIPER LITE] Auto Teleport Trade World:",
            tostring(LiteUIState.AutoTeleportTradeWorld)
        )
    end)

    SettingsInterfaceBox:AddDropdown(
        "LiteDPIScale",
        {
            Text = "UI Scale",
            Values = {
                "30%",
                "40%",
                "50%",
                "60%",
                "70%",
                "80%",
                "90%",
                "100%",
                "110%",
            },
            Default = "100%",
            Searchable = false,
            MaxVisibleDropdownItems = 9,
            Tooltip = "Changes the size of the Holy Lite interface.",
        }
    ):OnChanged(function(value)

        local rawValue =
            tostring(value or "100%")

        local cleanedValue =
            rawValue:gsub("%%", "")

        local scale =
            tonumber(cleanedValue)

        if not scale then
            return
        end

        scale =
            math.clamp(
                math.floor(scale + 0.5),
                30,
                110
            )

        if Library
        and type(Library.SetDPIScale) == "function" then

            pcall(function()
                Library:SetDPIScale(scale)
            end)
        end

        MarkConfigDirty()

        print(
            "[HOLY SNIPER LITE] UI Scale:",
            tostring(scale) .. "%"
        )
    end)
end

--==================================================
-- [10] THEME / SAVE MANAGER
-- Silent autosave only.
-- No visible Configuration groupbox.
--==================================================

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

ThemeManager:SetFolder("HolySniperLite")
SaveManager:SetFolder("HolySniperLite")

SaveManager:IgnoreThemeSettings()
ThemeManager:ApplyTheme("Dark")

pcall(function()
    SaveManager:Load(ConfigState.AutosaveName)
end)

if type(ResetLiteGatewayTransientInputAfterLoad) == "function" then

    ResetLiteGatewayTransientInputAfterLoad()
end

ConfigState.Loading =
    false

RefreshLitePresenceLabels()

if CanRunTradeSniper() then

    StartLiteMarketTrackerWorker()
end

--==================================================
-- [11] AUTOSAVE WORKER
--==================================================

task.spawn(function()

    while IsHolyLiteCurrentRun() do

        task.wait(1)

        RefreshLiteServerLabels()
        RefreshLitePresenceLabels()

        if ConfigState.Dirty == true then

            ConfigState.Dirty =
                false

            pcall(function()
                SaveManager:Save(ConfigState.AutosaveName)
            end)
        end
    end
end)
print("[HOLY SNIPER LITE] Filter storage ready.")
print("[HOLY SNIPER LITE] Reset command: HOLY_LITE_RESET()")
print("[HOLY SNIPER LITE] UI shell loaded.")
