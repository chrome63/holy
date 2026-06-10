
local Players =
    game:GetService("Players")

local TeleportService =
    game:GetService("TeleportService")

local HttpService =
    game:GetService("HttpService")

local ReplicatedStorage =
    game:GetService("ReplicatedStorage")

--==================================================
-- [1] CONSTANTS
--==================================================

local GROW_A_GARDEN_PLACE_ID =
    126884695634066

local TRADING_WORLD_PLACE_ID =
    129954712878723

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

local SAVE_FOLDER =
    "HolyFresh"

local UI_SETTINGS_FILE =
    SAVE_FOLDER .. "/UISettings.json"

--==================================================
-- [2] BASIC LOAD
--==================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local LocalPlayer =
    Players.LocalPlayer

if not LocalPlayer then
    warn("[HOLY FRESH] LocalPlayer missing.")
    return
end

--==================================================
-- [3] RUNTIME ROOT
--==================================================

local RuntimeRoot =
    (
        type(getgenv) == "function"
        and getgenv()
        or _G
    ).HOLY_FRESH_RUNTIME_ROOT
    or {}

if type(getgenv) == "function" then

    getgenv().HOLY_FRESH_RUNTIME_ROOT =
        RuntimeRoot

else

    _G.HOLY_FRESH_RUNTIME_ROOT =
        RuntimeRoot
end

local RunId =
    tostring(os.clock())
    .. "_"
    .. tostring(math.random(100000, 999999))

RuntimeRoot.RunId =
    RunId

local function IsCurrentRun()

    return RuntimeRoot
        and RuntimeRoot.RunId == RunId
end

--==================================================
-- [4] STATE
--==================================================

local State = {
    Status = "Loading",
    LastAction = "Starting",
    UIScalePercent = 100,
    ShowUIOnLoad = true,

    IsHopping = false,
    LastHop = "None",
    LastError = "None",

    ServerMode = "Fullest Under Max",
    MaxPlayers = 30,
    SearchPages = 3,

    RecentServers = {},
}

--==================================================
-- [5] HELPERS
--==================================================

local function CleanText(value)

    return tostring(value or "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

local function GetWorldName()

    if game.PlaceId == GROW_A_GARDEN_PLACE_ID then
        return "Garden World"
    end

    if game.PlaceId == TRADING_WORLD_PLACE_ID then
        return "Trade World"
    end

    return "Unknown Place"
end

local function CanUseFiles()

    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

local function EnsureFolder()

    if type(makefolder) ~= "function"
    or type(isfolder) ~= "function" then
        return false
    end

    local ok =
        pcall(function()

            if not isfolder(SAVE_FOLDER) then
                makefolder(SAVE_FOLDER)
            end
        end)

    return ok == true
end

local function SaveUISettings()

    if not CanUseFiles() then
        return false
    end

    EnsureFolder()

    local payload = {
        UIScalePercent =
            tonumber(State.UIScalePercent)
            or 100,

        ShowUIOnLoad =
            State.ShowUIOnLoad == true,
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
                UI_SETTINGS_FILE,
                encoded
            )
        end)

    return writeOk == true
end

local function LoadUISettings()

    if not CanUseFiles() then
        return false
    end

    local exists =
        false

    local existsOk =
        pcall(function()
            exists =
                isfile(UI_SETTINGS_FILE)
        end)

    if existsOk ~= true
    or exists ~= true then
        return false
    end

    local readOk, raw =
        pcall(function()
            return readfile(UI_SETTINGS_FILE)
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

    if tonumber(payload.UIScalePercent) then

        State.UIScalePercent =
            math.clamp(
                math.floor(tonumber(payload.UIScalePercent)),
                30,
                110
            )
    end

    if type(payload.ShowUIOnLoad) == "boolean" then
        State.ShowUIOnLoad =
            payload.ShowUIOnLoad
    end

    return true
end

local function CopyToClipboard(text)

    local clipboard =
        setclipboard
        or toclipboard
        or set_clipboard

    if type(clipboard) ~= "function" then
        warn("[HOLY FRESH] Clipboard unsupported.")
        return false
    end

    pcall(function()
        clipboard(tostring(text or ""))
    end)

    return true
end

local function SetControlText(control, text)

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
        control.Text =
            tostring(text or "")
    end)
end

local function SetControlVisible(control, visible)

    if not control then
        return
    end

    visible =
        visible == true

    if type(control.SetVisible) == "function" then

        pcall(function()
            control:SetVisible(visible)
        end)

        return
    end

    if type(control.SetVisibility) == "function" then

        pcall(function()
            control:SetVisibility(visible)
        end)

        return
    end

    pcall(function()
        control.Visible =
            visible
    end)
end

local function AddLeftBox(tab, title, icon)

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

local function AddRightBox(tab, title, icon)

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

--==================================================
-- [6] LOAD SETTINGS BEFORE UI
--==================================================

LoadUISettings()

--==================================================
-- [7] LOAD UI LIBRARY
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
-- [8] WINDOW
--==================================================

local Window =
    Library:CreateWindow({
        Title =
            '<font color="rgb(232,230,240)">Holy</font> '
            .. '<font color="rgb(255,221,128)"><b>Fresh</b></font>',

        Footer =
            "holy fresh · garden + trade foundation",

        ToggleKeybind =
            Enum.KeyCode.LeftAlt,

        Font =
            Enum.Font.GothamMedium,

        Center =
            true,

        AutoShow =
            State.ShowUIOnLoad == true,

        Size =
            UDim2.fromOffset(820, 540),

        CornerRadius =
            6,

        GlobalSearch =
            true,

        EnableCompacting =
            true,

        EnableSidebarResize =
            true,

        MinSidebarWidth =
            170,
    })

--==================================================
-- [9] TABS
--==================================================

local Tabs = {
    Home =
        Window:AddTab({
            Name = "Home",
            Icon = "house",
            Description = "Session controls and server actions.",
        }),

    Garden =
        Window:AddTab({
            Name = "Garden",
            Icon = "leaf",
            Description = "Garden world systems.",
        }),

    Transfer =
        game.PlaceId == GROW_A_GARDEN_PLACE_ID
        and Window:AddTab({
            Name = "Transfer",
            Icon = "gift",
            Description = "Garden World filtered pet transfer tester.",
        })
        or nil,

    Trade =
        Window:AddTab({
            Name = "Trade",
            Icon = "badge-dollar-sign",
            Description = "Trade world systems.",
        }),

    Settings =
        Window:AddTab({
            Name = "Settings",
            Icon = "settings",
            Description = "UI scaling and developer tools.",
        }),
}

--==================================================
-- [10] UI SCALE
-- Lite-style DPI scaling.
-- Uses Obsidian Library:SetDPIScale so buttons/dropdowns scale correctly.
--==================================================

local ScaleStatusLabel =
    nil

local function ResolveUIScaleDropdownDefault()

    local scale =
        math.clamp(
            math.floor(
                tonumber(State.UIScalePercent)
                or 100
            ),
            30,
            110
        )

    local values = {
        30,
        40,
        50,
        60,
        70,
        80,
        90,
        100,
        110,
    }

    local closest =
        "100%"

    local closestDistance =
        math.huge

    for _, value in ipairs(values) do

        local distance =
            math.abs(scale - value)

        if distance < closestDistance then

            closestDistance =
                distance

            closest =
                tostring(value) .. "%"
        end
    end

    return closest
end

local function ApplyUIScalePercent(percent)

    percent =
        tonumber(percent)
        or State.UIScalePercent
        or 100

    percent =
        math.clamp(
            math.floor(percent + 0.5),
            30,
            110
        )

    State.UIScalePercent =
        percent

    local applied =
        false

    if Library
    and type(Library.SetDPIScale) == "function" then

        local ok, err =
            pcall(function()
                Library:SetDPIScale(percent)
            end)

        applied =
            ok == true

        if not ok then

            warn(
                "[HOLY FRESH] Library:SetDPIScale failed:",
                tostring(err)
            )
        end
    end

    State.Status =
        "UI scale "
        .. tostring(percent)
        .. "%"

    State.LastAction =
        "UI scale set to "
        .. tostring(percent)
        .. "%"

    SaveUISettings()

    SetControlText(
        ScaleStatusLabel,
        "Current Scale: "
            .. tostring(percent)
            .. "%"
    )

    print(
        "[HOLY FRESH] UI scale set:",
        tostring(percent) .. "%",
        "| SetDPIScale:",
        tostring(applied)
    )

    return applied
end

task.delay(0.25, function()

    if not IsCurrentRun() then
        return
    end

    ApplyUIScalePercent(
        State.UIScalePercent
    )
end)

--==================================================
-- [11] SERVER / TELEPORT HELPERS
--==================================================

local function AddRecentServer(jobId)

    jobId =
        tostring(jobId or "")

    if jobId == "" then
        return
    end

    for _, existing in ipairs(State.RecentServers) do

        if tostring(existing) == jobId then
            return
        end
    end

    table.insert(
        State.RecentServers,
        jobId
    )

    while #State.RecentServers > 25 do
        table.remove(State.RecentServers, 1)
    end
end

local function IsRecentServer(jobId)

    jobId =
        tostring(jobId or "")

    if jobId == "" then
        return true
    end

    for _, existing in ipairs(State.RecentServers) do

        if tostring(existing) == jobId then
            return true
        end
    end

    return false
end

local function FetchHopCandidates()

    local candidates =
        {}

    local maxPlayers =
        math.clamp(
            tonumber(State.MaxPlayers) or 30,
            1,
            100
        )

    local pages =
        math.clamp(
            tonumber(State.SearchPages) or 3,
            1,
            25
        )

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

        if ok ~= true
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

                local serverMax =
                    tonumber(server.maxPlayers)
                    or Players.MaxPlayers
                    or 30

                local valid =
                    jobId ~= tostring(game.JobId)
                    and playing < serverMax
                    and playing <= maxPlayers
                    and not IsRecentServer(jobId)

                if valid then

                    table.insert(candidates, {
                        JobId = jobId,
                        Playing = playing,
                        MaxPlayers = serverMax,
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

    return candidates
end

local function RejoinCurrentServer()

    local player =
        Players.LocalPlayer

    if not player then
        warn("[HOLY FRESH] Rejoin failed: LocalPlayer missing.")
        return false
    end

    State.Status =
        "Rejoining"

    State.LastAction =
        "Rejoining current server"

    pcall(function()

        TeleportService:TeleportToPlaceInstance(
            game.PlaceId,
            game.JobId,
            player
        )
    end)

    return true
end

local function HopServer()

    if State.IsHopping == true then
        return false
    end

    local player =
        Players.LocalPlayer

    if not player then
        warn("[HOLY FRESH] Hop failed: LocalPlayer missing.")
        return false
    end

    State.IsHopping =
        true

    State.Status =
        "Finding server"

    State.LastAction =
        "Manual hop started"

    task.spawn(function()

        AddRecentServer(game.JobId)

        local candidates =
            FetchHopCandidates()

        local selected =
            candidates[1]

        if not selected then

            State.IsHopping =
                false

            State.Status =
                "Hop failed"

            State.LastError =
                "No valid server"

            warn("[HOLY FRESH] Hop failed: no valid server.")

            return
        end

        AddRecentServer(
            selected.JobId
        )

        State.Status =
            "Hopping"

        State.LastHop =
            tostring(selected.JobId)

        State.LastAction =
            "Hopping to "
            .. tostring(selected.Playing)
            .. "/"
            .. tostring(selected.MaxPlayers)

        print(
            "[HOLY FRESH] Hopping:",
            tostring(selected.JobId),
            "| players:",
            tostring(selected.Playing)
                .. "/"
                .. tostring(selected.MaxPlayers)
        )

        local ok, err =
            pcall(function()

                TeleportService:TeleportToPlaceInstance(
                    game.PlaceId,
                    selected.JobId,
                    player
                )
            end)

        if ok ~= true then

            State.IsHopping =
                false

            State.Status =
                "Hop failed"

            State.LastError =
                tostring(err)

            warn(
                "[HOLY FRESH] Hop failed:",
                tostring(err)
            )
        end
    end)

    return true
end

local function TeleportToPlace(placeId, label)

    local player =
        Players.LocalPlayer

    if not player then
        warn("[HOLY FRESH] Teleport failed: LocalPlayer missing.")
        return false
    end

    State.Status =
        "Teleporting"

    State.LastAction =
        "Teleporting to "
        .. tostring(label or placeId)

    pcall(function()

        TeleportService:Teleport(
            placeId,
            player
        )
    end)

    return true
end

--==================================================
-- [12] DEV TOOL EXEC
--==================================================

local function SafeToolExec(url, label)

    url =
        tostring(url or "")

    label =
        tostring(label or "Tool")

    if url == "" then
        warn("[HOLY FRESH] Missing tool URL:", label)
        return false
    end

    task.spawn(function()

        print("[HOLY FRESH] Loading:", label)

        local okSource, source =
            pcall(function()
                return game:HttpGet(url)
            end)

        if okSource ~= true
        or type(source) ~= "string"
        or source == "" then

            warn(
                "[HOLY FRESH] HttpGet failed:",
                label
            )

            return
        end

        local chunk, compileErr =
            loadstring(source)

        if type(chunk) ~= "function" then

            warn(
                "[HOLY FRESH] Compile failed:",
                label,
                tostring(compileErr)
            )

            return
        end

        local okRun, runErr =
            pcall(chunk)

        if okRun ~= true then

            warn(
                "[HOLY FRESH] Runtime failed:",
                label,
                tostring(runErr)
            )

            return
        end

        print("[HOLY FRESH] Loaded:", label)
    end)

    return true
end

--==================================================
-- [12.5] TRANSFER SYSTEM
-- Garden World only.
-- Uses DataService PetData.BaseWeight, not visible KG.
--==================================================

local TransferState = {
    SelectedPets = {},
    SelectedMutations = {},

    Mode = "Sender",
    TargetPlayerName = "",

    TransferEnabled = false,
    KeepGoing = false,
    IsTransferRunning = false,

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

local function TransferDebugPrint(...)

    if TransferState.DebugPrints == true then
        print(...)
    end
end

local function TransferTimingReset(label)

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

local function TransferTimingMark(key)

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

local function TransferTimingSet(key, value)

    local timing =
        TransferState.Timing

    if type(timing) ~= "table" then
        return
    end

    timing[key] =
        value
end

local function TransferTimingBumpAttempts(count)

    local timing =
        TransferState.Timing

    if type(timing) ~= "table" then
        return
    end

    timing.Attempts =
        (tonumber(timing.Attempts) or 0)
        + (tonumber(count) or 1)
end

local function TransferTimingFormat(value)

    value =
        tonumber(value)

    if not value then
        return "-"
    end

    return string.format("%.3fs", value)
end

local function TransferTimingReport(reason)

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

local TransferSetStatus =
    nil

local TransferAcceptPetGift =
    nil

local TransferDataService =
    nil

local TransferTradeData =
    nil

local TransferPetRegistry =
    nil

local function TransferGetTradeData()

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

local function TransferGetTradeItemLimit()

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

local function TransferGetMaxPetsPerTrade()

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

local function TransferGetAddPetDelay()

    local delay =
        tonumber(TransferState.AddPetDelay)
        or 0.5

    return math.clamp(
        delay,
        0.01,
        3
    )
end

local function TransferGetAddBurstCount()

    local burst =
        tonumber(TransferState.AddBurstCount)
        or 1

    return math.clamp(
        math.floor(burst),
        1,
        TransferGetMaxPetsPerTrade()
    )
end

local function TransferGetNextTicketDelay()

    local delay =
        tonumber(TransferState.NextTicketDelay)
        or 0

    return math.clamp(
        delay,
        0,
        60
    )
end

local function TransferWaitBeforeNextTicket()

    local delay =
        TransferGetNextTicketDelay()

    if delay <= 0 then
        return
    end

    local started =
        os.clock()

    while IsCurrentRun()
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

local function TransferToNumber(value, fallback)

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

local function TransferFormatNumber(value)

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

local function TransferUnpack(list)

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

local function TransferMapIsEmpty(map)

    if type(map) ~= "table" then
        return true
    end

    for _ in pairs(map) do
        return false
    end

    return true
end

local function TransferBuildMapFromDropdown(value)

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

local function TransferNormalizeUUID(value)

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

local function TransferNormalizeUUIDNoBraces(value)

    return tostring(TransferNormalizeUUID(value))
        :gsub("{", "")
        :gsub("}", "")
end

local function TransferGetDataService()

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

local function TransferGetDataServiceData()

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

local function TransferGetInventoryData()

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

local function TransferGetInventoryPetDataByUUID(uuid)

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

local function TransferResolveRawBaseWeight(petData, itemData, tool)

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

local function TransferResolveRawLevel(petData, itemData, tool, fallbackAge)

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

local function TransferResolvePetName(petData, itemData, tool, fallbackName)

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

local function TransferResolveFavorite(tool, petData, itemData)

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

local function TransferResolveMutation(toolName, basePetName, petData, itemData)

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

local function TransferParseDisplayWeight(toolName)

    return tonumber(
        tostring(toolName or "")
            :match("%[([%d%.]+)%s*KG%]")
    )
end

local function TransferParseDisplayAge(toolName)

    return tonumber(
        tostring(toolName or "")
            :match("%[Age%s*(%d+)%]")
    )
end

local function TransferResolveToolUUID(tool)

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

local function TransferParseInventoryTool(tool)

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

local function TransferBuildInventoryPets()

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

local function TransferAddUniquePetName(target, seen, value)

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

local function TransferGetPetRegistry()

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

local function TransferBuildAllGamePetChoices()

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

local function TransferBuildPetChoices()

    return TransferBuildAllGamePetChoices()
end

local function TransferAddUniqueMutationName(target, seen, value)

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

local function TransferBuildMutationChoices()

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

local function TransferBuildTargetChoices()

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

local function TransferResolveTargetPlayer()

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

local function TransferPetPassesFilters(pet)

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

local function TransferBuildMatches()

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
                    valid += 1
                else
                    missingBase += 1
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

local function TransferApplyModeUI()

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

local function TransferFindTradeTicketTool()

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

local function TransferEquipTradeTicket()

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

local TransferFavoriteRemote =
    nil

local function TransferGetFavoriteRemote()

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

local function TransferUnfavoritePetIfNeeded(pet)

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

        if not IsCurrentRun() then
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

local function TransferUnfavoriteMatchingPetsBeforeTrade(matches)

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

        if not IsCurrentRun() then
            return false, "Runtime stopped"
        end

        if type(pet) == "table"
        and pet.IsFavorite == true then

            totalFavorites += 1

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
                unfavorited += 1
            else

                failed += 1

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

local function TransferRefreshDropdowns()

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

local function TransferSafeFullName(instance)

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

local function TransferCompactValue(value, depth)

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

        count += 1

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

local function TransferBuildTradeDebugDump()

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

local function TransferGetTradeRemote(name)

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

local function TransferFireTradeRemote(name, ...)

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

local function TransferReadOfferCountFromOffers(offers, side)

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
                count += 1
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

local function TransferResolveTradeSidesFromPlayers(playersTable)

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

local function TransferGetTradeState(side)

    if side == nil then
        return "None"
    end

    return tostring(
        TransferState.TradeStates[side]
            or TransferState.TradeStates[tostring(side)]
            or "None"
    )
end

local function TransferGetLocalTradeState()

    return TransferGetTradeState(
        TransferState.LocalTradeSide
    )
end

local function TransferGetOtherTradeState()

    return TransferGetTradeState(
        TransferState.OtherTradeSide
    )
end

local function TransferResetTradeRuntime()

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

    TransferState.LastTradeUpdate =
        0
end

local function TransferUpdateTradeStatusText(status, result)

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

local function TransferMarkTradeDeclined(reason)

    reason =
        tostring(reason or "Trade declined.")

    TransferState.TradeDeclined =
        true

    TransferState.TradeDeclineReason =
        reason

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

local function TransferMarkRequestBlocked(reason)

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

local function TransferUpdateTradeTrackerFromPayload(payload)

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

local function TransferStartTradeWatchers()

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

                if TransferState.TradeOpen == true
                and TransferState.TradeCompleted ~= true
                and TransferState.TradeResult ~= "Completed" then

                    TransferMarkTradeDeclined(
                        "Trade closed before completion."
                    )
                end

                return
            end

            TransferState.TradeId =
                tostring(tradeId)

            TransferState.TradeOpen =
                true

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

            if lower:find("declined the trade", 1, true)
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

local function TransferWaitForTradeOpen(timeout)

    timeout =
        tonumber(timeout)
        or 20

    local started =
        os.clock()

    TransferSetStatus(
        "Waiting Trade",
        "Waiting for target to accept/open trade."
    )

    while IsCurrentRun() do

        if TransferState.TradeDeclined == true then
            return false
        end

        if TransferState.RequestBlocked == true then
            return false
        end

        if TransferState.TradeOpen == true then
            return true
        end

        if os.clock() - started >= timeout then
            return false
        end

        task.wait(0.03)
    end

    return false
end

local function TransferWaitForOwnOfferCountAtLeast(expectedCount, timeout)

    expectedCount =
        tonumber(expectedCount)
        or 0

    timeout =
        tonumber(timeout)
        or 4

    local started =
        os.clock()

    while IsCurrentRun()
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

local function TransferWaitForOwnOfferCountAtLeastOrSettled(startingCount, expectedCount, timeout, settleWindow)

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

    while IsCurrentRun()
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

local function TransferWaitForTradeCompleted(timeout)

    timeout =
        tonumber(timeout)
        or 25

    local started =
        os.clock()

    while IsCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferState.TradeCompleted == true
        or TransferState.TradeResult == "Completed"
        or TransferGetLocalTradeState() == "Processing"
        or TransferGetOtherTradeState() == "Processing" then
            return true
        end

        if os.clock() - started >= timeout then
            return false
        end

        task.wait(0.2)
    end

    return false
end

local TransferParseCooldownText
local TransferGuiHasPositiveTradeValue
local TransferGetTradeButtonText
local TransferGuiWaitingForSpecificPlayer
local TransferLocalAcceptLocked
local TransferAcceptLikelyLockedFromButtonPhase
local TransferReceiverAcceptedAfterLocal
local TransferIsGuiObjectVisible

TransferGetTradeButtonText = function()

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    local label =
        playerGui
        and playerGui:FindFirstChild("TradingUI")
        and playerGui.TradingUI:FindFirstChild("LiveTrade")
        and playerGui.TradingUI.LiveTrade:FindFirstChild("Options")
        and playerGui.TradingUI.LiveTrade.Options:FindFirstChild("Accept")
        and playerGui.TradingUI.LiveTrade.Options.Accept:FindFirstChild("Label")

    if label
    and label:IsA("TextLabel") then
        return CleanText(label.Text)
    end

    return ""
end

local function TransferIsLiveTradeOpen()

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
    or TransferGetLocalTradeState() == "Processing"
    or TransferGetOtherTradeState() == "Processing" then
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

local function TransferMarkClosedIfLiveTradeGone(reason)

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

local function TransferWaitForLiveTradeClosed(timeout)

    timeout =
        tonumber(timeout)
        or 4

    local started =
        os.clock()

    while IsCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferIsLiveTradeOpen() ~= true then
            return true
        end

        if os.clock() - started >= timeout then
            return false
        end

        TransferSetStatus(
            "Waiting Close",
            "Waiting old trade to close."
        )

        task.wait(0.15)
    end

    return false
end

local function TransferHideTradeRequestPopup(playerName)

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

                        hidden += 1

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

local function TransferGuiPlayerHasAccepted(playerName)

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

local function TransferGetReadyLabelText(sideName)

    sideName =
        tostring(sideName or "")

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    local liveTrade =
        playerGui
        and playerGui:FindFirstChild("TradingUI")
        and playerGui.TradingUI:FindFirstChild("LiveTrade")

    local label =
        liveTrade
        and liveTrade:FindFirstChild(sideName)
        and liveTrade[sideName]:FindFirstChild("Ready")
        and liveTrade[sideName].Ready:FindFirstChild("Label")

    if label
    and label:IsA("TextLabel") then
        return CleanText(label.Text)
    end

    return ""
end

local function TransferReadyLabelIsAccepted(sideName)

    local text =
        TransferGetReadyLabelText(sideName)

    return text == "Accepted"
        or text == "Confirmed"
        or text == "Processing"
end

local function TransferCountStatesWithValue(wantedState)

    wantedState =
        tostring(wantedState or "")

    local count =
        0

    for _, state in pairs(TransferState.TradeStates or {}) do

        if tostring(state) == wantedState then
            count += 1
        end
    end

    return count
end

local function TransferBothPlayersAccepted()

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

local function TransferGetTradeStatusText()

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    local statusLabel =
        playerGui
        and playerGui:FindFirstChild("TradingUI")
        and playerGui.TradingUI:FindFirstChild("LiveTrade")
        and playerGui.TradingUI.LiveTrade:FindFirstChild("Status")

    if statusLabel
    and statusLabel:IsA("TextLabel") then
        return CleanText(statusLabel.Text)
    end

    return ""
end

local function TransferIsConfirmPhase()

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

local function TransferConfirmWindowReady()

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

    return false
end

local function TransferTradeStateIsAcceptedLike(state)

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

local function TransferWaitForReceiverAccepted(timeout)

    timeout =
        tonumber(timeout)
        or 45

    local started =
        os.clock()

    while IsCurrentRun()
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

local function TransferSenderReadyForReceiverAccept()

    local otherState =
        TransferGetOtherTradeState()

    -- Strict rule:
    -- Receiver may only accept after sender has accepted/confirmed/processing.
    -- Added items alone are NOT enough, because sender may still be adding pets.
    if TransferTradeStateIsAcceptedLike(otherState) then
        return true
    end

    -- GUI fallback:
    -- Only trust visible "@Sender has accepted" text.
    if TransferGuiPlayerHasAccepted(
        TransferState.TargetPlayerName
    ) then
        return true
    end

    return false
end

local function TransferWaitForSenderReadyForReceiverAccept(timeout)

    timeout =
        tonumber(timeout)
        or 120

    local started =
        os.clock()

    while IsCurrentRun()
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

local function TransferWaitForConfirmReady(timeout)

    timeout =
        tonumber(timeout)
        or 8

    local started =
        os.clock()

    while IsCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferState.TradeDeclined == true
        or TransferMarkClosedIfLiveTradeGone("Trade UI closed while waiting confirm.") == true then
            return false
        end

        local text =
            TransferGetTradeButtonText()

        local seconds =
            TransferParseCooldownText(text)

        if TransferConfirmWindowReady() == true then

            TransferTimingMark(
                "ConfirmSeenAt"
            )

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

local function TransferWaitForTrustedIncomingRequest(timeout)

    timeout =
        tonumber(timeout)
        or 60

    local started =
        os.clock()

    while IsCurrentRun()
    and TransferState.TransferEnabled == true do

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

local function TransferStopWorker(reason)

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

local function TransferResetWorkerForModeSwitch(newMode)

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

local function TransferTryAddPetToTrade(pet)

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

        if not IsCurrentRun() then
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

local function TransferFirePetAddNoWait(pet)

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

local function TransferSendTicket()

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

local function TransferRespondRequest(accept)

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

local function TransferAcceptIncomingRequest()

    return TransferRespondRequest(true)
end

local function TransferDeclineIncomingRequest()

    return TransferRespondRequest(false)
end

local function TransferDeclineTrade()

    local ok, msg =
        TransferFireTradeRemote("Decline")

    TransferSetStatus(
        ok and "Declined" or "Decline Failed",
        msg
    )

    print("[TRANSFER] Decline:", tostring(ok), tostring(msg))

    if ok == true then

        TransferMarkTradeDeclined(
            "Local decline requested."
        )
    end

    return ok
end

local function TransferConfirmTrade()

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

local function TransferExtractPositiveTradeValueFromText(text)

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

local function TransferWaitForVisibleTradeValue(timeout)

    timeout =
        tonumber(timeout)
        or 10

    local started =
        os.clock()

    while IsCurrentRun()
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

local function TransferCanUseTradeValueForAccept()

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

local function TransferStartFastAcceptPump(label, requiredOwnCount, requiredOtherCount, maxDuration)

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

            if not IsCurrentRun()
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

            if valueDetected == true then

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
                        "button_ready",
                        value,
                        4
                    )

                elseif seconds ~= nil then

                    if seconds <= 0.25 then

                        -- Only fire at the real useful server-ready window.
                        FireAcceptBurst(
                            "cooldown_final",
                            value,
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
                        "Value="
                            .. tostring(value)
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

local function TransferAcceptAndWait(label, timeout, requiredOwnCount, requiredOtherCount)

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

    while IsCurrentRun()
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

        local countReady =
            (
                requiredOwnCount > 0
                or requiredOtherCount > 0
            )
            and ownCount >= requiredOwnCount
            and otherCount >= requiredOtherCount

        local senderAcceptedReady =
            false

        if TransferState.Mode == "Receiver" then

            local senderAccepted =
                TransferTradeStateIsAcceptedLike(
                    TransferGetOtherTradeState()
                )
                or TransferGuiPlayerHasAccepted(
                    TransferState.TargetPlayerName
                )

            senderAcceptedReady =
                senderAccepted == true
                and (
                    otherCount > 0
                    or hasValue == true
                )
        end

        local ready =
            hasValue == true
            or countReady == true
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
                or (
                    countReady == true
                    and "count_ready"
                    or "value_ready"
                )

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
                    value,
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
                        value,
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
                    value,
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
                        .. " | Value="
                        .. tostring(value)
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

local function TransferConfirmAndWait(label, timeout)

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

    while IsCurrentRun()
    and TransferState.TransferEnabled == true do

        if TransferState.TradeDeclined == true
        or TransferMarkClosedIfLiveTradeGone("Trade UI closed while confirming.") == true then
            return false
        end

        if TransferState.TradeCompleted == true
        or TransferState.TradeResult == "Completed"
        or TransferGetLocalTradeState() == "Processing"
        or TransferGetOtherTradeState() == "Processing" then

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

        if confirmWindowReady == true then
            TransferTimingMark("ConfirmSeenAt")
        end

        if buttonText == "Confirmed" then

            TransferUpdateTradeStatusText(
                label,
                "Waiting other final confirm."
            )

            task.wait(0.15)

        elseif confirmWindowReady == true
        and (
            attempts == 0
            or os.clock() >= nextRetryAt
        ) then

            attempts += 1

            nextRetryAt =
                os.clock() + 0.18

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
                TransferGetLocalTradeState(),
                "| Other:",
                TransferGetOtherTradeState()
            )

            task.wait(0.05)

        else

            TransferUpdateTradeStatusText(
                label,
                "Waiting final confirm result. Button="
                    .. tostring(buttonText)
            )

            task.wait(0.15)
        end
    end

    return false
end

local function TransferSendFilteredPets()

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

            if not IsCurrentRun()
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

                added += 1

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

                failed += 1

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

            TransferState.Sent += confirmed and 1 or 0

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

            if not IsCurrentRun()
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

                    firedCount += 1

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

                    failed += 1

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

                stuckRounds += 1

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

                added += gained

                TransferState.Sent += gained

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

                index += gained

            else

                stuckRounds += 1

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

local function TransferRunSenderBatch()

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

    TransferState.Batch += 1

    TransferSetStatus(
        "Batch "
            .. tostring(TransferState.Batch),
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

    TransferUpdateTradeStatusText(
        "Trade Open",
        "Adding pets + pre-accepting."
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

    local acceptOk =
        TransferAcceptAndWait(
            "Accepting",
            14,
            0,
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

local function TransferRunReceiverBatch()

    TransferResetTradeRuntime()

    TransferTimingReset("Receiver Batch")

    local requestOk =
        TransferWaitForTrustedIncomingRequest(90)

    if requestOk ~= true then
        return false, "No trusted request"
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

    TransferUpdateTradeStatusText(
        "Waiting Sender",
        "Waiting sender items/value."
    )

    local valueVisible =
        TransferWaitForVisibleTradeValue(120)

    if valueVisible ~= true then

        if TransferState.TradeDeclined == true then
            return false, "Trade declined"
        end

        TransferSetStatus(
            "Value Timeout",
            "Sender value never became visible."
        )

        return false, "No sender items"
    end

    if tonumber(TransferState.TradeOtherItemCount) <= 0
    and TransferGuiHasPositiveTradeValue() ~= true then

        TransferSetStatus(
            "No Items",
            "Sender accepted with no visible value/items."
        )

        return false, "No sender items"
    end

    local senderAccepted =
        TransferWaitForSenderReadyForReceiverAccept(120)

    if senderAccepted ~= true then

        if TransferState.TradeDeclined == true then
            return false, "Trade declined"
        end

        TransferSetStatus(
            "Sender Timeout",
            "Sender never reached Accepted state."
        )

        return false, "Sender did not accept"
    end

    print(
        "[TRANSFER] Sender accepted detected:",
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
            "Sender accepted. Receiver accepting trade."
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

    TransferState.Batch += 1

    TransferSetStatus(
        "Trade Done",
        "Received batch "
            .. tostring(TransferState.Batch)
            .. "."
    )

    return true, "Received batch"
end

local function TransferSenderCanRetryAfterFailure(message)

    message =
        tostring(message or "")

    return message == "Trade declined"
        or message == "Trade timeout"
        or message == "Receiver accept timeout"
        or message == "Confirm timeout"
        or message == "Complete timeout"
        or message == "Accept failed"
        or message == "No pets added"
        or message == "Still in trade"
        or message == "Ticket failed"
        or message == "Request blocked"
end

local function TransferWorkerLoop()

    if TransferState.IsTransferRunning == true then

        if TransferState.TransferEnabled ~= true then

            TransferState.IsTransferRunning =
                false

        else

            TransferSetStatus(
                "Already Running",
                "Transfer worker is already active."
            )

            return
        end
    end

    TransferState.IsTransferRunning =
        true

    TransferState.Batch =
        0

    TransferSetStatus(
        "Enabled",
        "Transfer started."
    )

    task.spawn(function()

        while IsCurrentRun()
        and TransferState.TransferEnabled == true do

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

                    TransferResetTradeRuntime()

                    TransferState.IncomingRequestId =
                        ""

                    TransferState.IncomingRequestPlayerName =
                        ""

                    TransferState.IncomingRequestAt =
                        0

                    TransferSetStatus(
                        "Waiting",
                        "Ready for next ticket. Last: "
                            .. tostring(msg)
                    )

                    task.wait(0.75)

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

                        TransferWaitForLiveTradeClosed(0.75)

                    elseif retryMsg == "Request blocked" then

                        task.wait(0.85)

                    else

                        task.wait(0.18)
                    end

                    TransferResetTradeRuntime()

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

            if TransferState.Mode == "Sender" then

                TransferWaitForLiveTradeClosed(4)

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

        TransferState.IsTransferRunning =
            false
    end)
end

--==================================================
-- [13] HOME TAB
--==================================================

local HomeActionsBox =
    AddLeftBox(
        Tabs.Home,
        "Actions",
        "zap"
    )

local HomeInfoBox =
    AddRightBox(
        Tabs.Home,
        "Session",
        "activity"
    )

HomeActionsBox:AddLabel({
    Text =
        '<font color="rgb(255,221,128)"><b>SERVER ACTIONS</b></font>',

    DoesWrap =
        false,

    Size =
        14,
})

local CopyServerButton =
    HomeActionsBox:AddButton({
        Text = "Copy Server",
        Tooltip = "Copy current placeId:jobId.",
        Func = function()

            local payload =
                tostring(game.PlaceId)
                .. ":"
                .. tostring(game.JobId)

            if CopyToClipboard(payload) then

                State.Status =
                    "Copied server"

                State.LastAction =
                    "Copied placeId:jobId"

                print("[HOLY FRESH] Copied server:", payload)
            end
        end,
    })

CopyServerButton:AddButton({
    Text = "Rejoin",
    Tooltip = "Rejoin this exact server.",
    Func = function()

        RejoinCurrentServer()
    end,
})

CopyServerButton:AddButton({
    Text = "Hop",
    Tooltip = "Hop to another public server in the current world.",
    Func = function()

        HopServer()
    end,
})

CopyServerButton:AddButton({
    Text = "Garden",
    Tooltip = "Teleport to normal Grow a Garden.",
    Func = function()

        TeleportToPlace(
            GROW_A_GARDEN_PLACE_ID,
            "Garden World"
        )
    end,
})

CopyServerButton:AddButton({
    Text = "Trade",
    Tooltip = "Teleport to Trade World.",
    Func = function()

        TeleportToPlace(
            TRADING_WORLD_PLACE_ID,
            "Trade World"
        )
    end,
})

HomeActionsBox:AddDivider()

HomeActionsBox:AddButton({
    Text = "STOP Runtime",
    Tooltip = "Stops this script run.",
    Risky = true,
    DoubleClick = true,
    Func = function()

        RuntimeRoot.RunId =
            tostring(os.clock())
            .. "_stopped"

        State.Status =
            "Stopped"

        State.LastAction =
            "Runtime stopped"

        warn("[HOLY FRESH] Runtime stopped.")
    end,
})

local WorldLabel =
    HomeInfoBox:AddLabel({
        Text =
            "World: "
            .. GetWorldName(),

        DoesWrap =
            false,

        Size =
            13,
    })

local PlaceLabel =
    HomeInfoBox:AddLabel({
        Text =
            "PlaceId: "
            .. tostring(game.PlaceId),

        DoesWrap =
            false,

        Size =
            13,
    })

local JobLabel =
    HomeInfoBox:AddLabel({
        Text =
            "JobId: "
            .. tostring(game.JobId),

        DoesWrap =
            true,

        Size =
            12,
    })

local StatusLabel =
    HomeInfoBox:AddLabel({
        Text =
            "Status: "
            .. tostring(State.Status),

        DoesWrap =
            true,

        Size =
            13,
    })

local ActionLabel =
    HomeInfoBox:AddLabel({
        Text =
            "Last Action: "
            .. tostring(State.LastAction),

        DoesWrap =
            true,

        Size =
            13,
    })

task.spawn(function()

    while IsCurrentRun() do

        task.wait(1)

        SetControlText(
            WorldLabel,
            "World: " .. GetWorldName()
        )

        SetControlText(
            PlaceLabel,
            "PlaceId: " .. tostring(game.PlaceId)
        )

        SetControlText(
            JobLabel,
            "JobId: " .. tostring(game.JobId)
        )

        SetControlText(
            StatusLabel,
            "Status: " .. tostring(State.Status)
        )

        SetControlText(
            ActionLabel,
            "Last Action: " .. tostring(State.LastAction)
        )
    end
end)

--==================================================
-- [14] GARDEN TAB
--==================================================

local GardenMainBox =
    AddLeftBox(
        Tabs.Garden,
        "Garden Systems",
        "leaf"
    )

local GardenInfoBox =
    AddRightBox(
        Tabs.Garden,
        "Garden Info",
        "info"
    )

GardenMainBox:AddLabel({
    Text =
        '<font color="rgb(134,239,172)"><b>READY FOR GARDEN FEATURES</b></font>',

    DoesWrap =
        false,

    Size =
        14,
})

GardenMainBox:AddLabel({
    Text =
        "This fresh build is intentionally empty.\n"
        .. "Add garden systems here one-by-one so we avoid lag and broken loops.",

    DoesWrap =
        true,

    Size =
        13,
})

GardenInfoBox:AddLabel({
    Text =
        "Current World:\n"
        .. GetWorldName(),

    DoesWrap =
        true,

    Size =
        13,
})

GardenInfoBox:AddLabel({
    Text =
        "Recommended next features:\n"
        .. "1. Own farm detection\n"
        .. "2. Safe fruit collector\n"
        .. "3. Campfire submit\n"
        .. "4. Simple HUD",

    DoesWrap =
        true,

    Size =
        13,
})

--==================================================
-- [14.5] TRANSFER TAB
--==================================================

if Tabs.Transfer then

    TransferStartTradeWatchers()

    local InitialTransferPetChoices =
        TransferBuildPetChoices()

    local InitialTransferMutationChoices =
        TransferBuildMutationChoices()

    local InitialTransferTargetChoices =
        TransferBuildTargetChoices()

    local TransferPetBox =
        AddLeftBox(
            Tabs.Transfer,
            "Pet Filters",
            "sliders-horizontal"
        )

    local TransferTargetBox =
        AddRightBox(
            Tabs.Transfer,
            "Trade Setup",
            "users"
        )

    local TransferActionsBox =
        AddRightBox(
            Tabs.Transfer,
            "Automation",
            "gift"
        )

    local TransferStatusBox =
        AddRightBox(
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
                Default = {},
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
                Default = {},
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
            Default = "1",
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
            Default = "100",
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
            Default = "0",
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
            Default = "999",
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
                Default = "Sender",
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
                Default = "",
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

            if CopyToClipboard(dump) then

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

        TransferState.TransferEnabled =
            value == true

        if TransferState.TransferEnabled == true then

            TransferWorkerLoop()

        else

            TransferSetStatus(
                "Disabled",
                "Transfer stopped."
            )
        end
    end)

    TransferState.AutoAcceptTicketToggle =
        TransferActionsBox:AddToggle(
            "HolyFreshTransferAutoAcceptTicket",
            {
                Text = "Auto Accept Ticket",
                Default = true,
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
                Default = true,
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
                Default = false,
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
                Default = true,
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
                Default = false,
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
            Default = false,
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
                Default = "12",
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
                Default = "0.5",
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
                Default = "1",
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
                Default = "0",
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

        TransferSetStatus(
            "Option Updated",
            "Next Ticket Delay = "
                .. string.format("%.2f", TransferState.NextTicketDelay)
                .. "s"
        )
    end)

    TransferApplyModeUI()

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

        if not IsCurrentRun() then
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

        if IsCurrentRun() then
            TransferRefreshDropdowns()
        end
    end)

    Players.PlayerRemoving:Connect(function()

        task.wait(0.03)

        if IsCurrentRun() then
            TransferRefreshDropdowns()
        end
    end)
end

--==================================================
-- [15] TRADE TAB
--==================================================

local TradeMainBox =
    AddLeftBox(
        Tabs.Trade,
        "Trade Systems",
        "badge-dollar-sign"
    )

local TradeInfoBox =
    AddRightBox(
        Tabs.Trade,
        "Trade Info",
        "info"
    )

TradeMainBox:AddLabel({
    Text =
        '<font color="rgb(103,232,249)"><b>READY FOR TRADE FEATURES</b></font>',

    DoesWrap =
        false,

    Size =
        14,
})

TradeMainBox:AddLabel({
    Text =
        "Trade systems are empty for now.\n"
        .. "This avoids the old sniper/market tracker loops kicking or lagging you.",

    DoesWrap =
        true,

    Size =
        13,
})

TradeInfoBox:AddLabel({
    Text =
        "Current World:\n"
        .. GetWorldName(),

    DoesWrap =
        true,

    Size =
        13,
})

TradeInfoBox:AddLabel({
    Text =
        "Recommended later:\n"
        .. "1. Read-only booth scanner\n"
        .. "2. Manual server gateway\n"
        .. "3. Optional sniper module",

    DoesWrap =
        true,

    Size =
        13,
})

--==================================================
-- [16] SETTINGS TAB
--==================================================

local SettingsBox =
    AddLeftBox(
        Tabs.Settings,
        "UI Settings",
        "settings"
    )

local ToolsBox =
    AddRightBox(
        Tabs.Settings,
        "Tools",
        "terminal"
    )

SettingsBox:AddLabel({
    Text =
        '<font color="rgb(255,221,128)"><b>UI SCALE</b></font>',

    DoesWrap =
        false,

    Size =
        14,
})

SettingsBox:AddLabel({
    Text =
        "Changes Obsidian DPI scale. Buttons, dropdowns, inputs, tabs, and labels scale together.",

    DoesWrap =
        true,

    Size =
        12,
})

ScaleStatusLabel =
    SettingsBox:AddLabel({
        Text =
            "Current Scale: "
            .. tostring(State.UIScalePercent)
            .. "%",

        DoesWrap =
            false,

        Size =
            13,
    })

local FreshScaleDropdown =
    SettingsBox:AddDropdown(
        "HolyFreshDPIScale",
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
            Default = ResolveUIScaleDropdownDefault(),
            Searchable = false,
            MaxVisibleDropdownItems = 9,
            Tooltip = "Changes the size of the Holy Fresh interface.",
        }
    )

FreshScaleDropdown:OnChanged(function(value)

    local rawValue =
        tostring(value or "100%")

    local cleanedValue =
        rawValue:gsub("%%", "")

    local scale =
        tonumber(cleanedValue)

    if not scale then
        return
    end

    ApplyUIScalePercent(scale)
end)

SettingsBox:AddDivider()

SettingsBox:AddButton({
    Text = "Save UI Settings",
    Tooltip = "Save current UI scale.",
    Func = function()

        if SaveUISettings() then

            State.Status =
                "Settings saved"

            State.LastAction =
                "UI settings saved"

            print("[HOLY FRESH] UI settings saved.")
        end
    end,
})

ToolsBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>DEV TOOLS</b></font>',

    DoesWrap =
        false,

    Size =
        14,
})

local RemoteSpyButton =
    ToolsBox:AddButton({
        Text = "Remote Spy",
        Tooltip = "Open UtopiaSpy to inspect remote calls.",
        Func = function()

            SafeToolExec(
                "https://raw.githubusercontent.com/Klinac/scripts/main/utopia_spy.lua",
                "Remote Spy"
            )
        end,
    })

RemoteSpyButton:AddButton({
    Text = "Dex Explorer",
    Tooltip = "Open Dex++ to inspect the live game tree.",
    Func = function()

        SafeToolExec(
            "https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua",
            "Dex Explorer"
        )
    end,
})

ToolsBox:AddLabel({
    Text =
        "Remote Spy logs remote calls.\n"
        .. "Dex Explorer lets you inspect PlayerGui, Workspace, ReplicatedStorage, and live attributes.",

    DoesWrap =
        true,

    Size =
        12,
})

ToolsBox:AddDivider()

ToolsBox:AddButton({
    Text = "Print Session",
    Tooltip = "Print current world, place, and job info.",
    Func = function()

        print("========== HOLY FRESH SESSION ==========")
        print("World:", GetWorldName())
        print("PlaceId:", game.PlaceId)
        print("JobId:", game.JobId)
        print("Player:", LocalPlayer.Name, LocalPlayer.UserId)
        print("========================================")
    end,
})

--==================================================
-- [17] FINALIZE
--==================================================

State.Status =
    "Ready"

State.LastAction =
    "Loaded"

print(
    "[HOLY FRESH] Loaded |",
    GetWorldName(),
    "| PlaceId:",
    tostring(game.PlaceId)
)
