--==================================================
-- HOLY | GROW A GARDEN 2
-- Clean LibraryLite Shell
-- Game: https://www.roblox.com/games/97598239454123/Grow-a-Garden-2
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
    nil

pcall(function()

    VirtualUser =
        game:GetService("VirtualUser")
end)

local VirtualInputManager =
    nil

pcall(function()

    VirtualInputManager =
        game:GetService("VirtualInputManager")
end)

--==================================================
-- [1] CONSTANTS
--==================================================

local LOCAL_PLAYER =
    Players.LocalPlayer
    or Players.PlayerAdded:Wait()

local GROW_A_GARDEN_2_PLACE_ID =
    97598239454123

local GROW_A_GARDEN_2_KNOWN_PLACE_IDS = {
    [77085202503540] = true,
    [97598239454123] = true,
    [133438856880402] = true,
}

local function IsGAG2KnownPlace(placeId)

    return GROW_A_GARDEN_2_KNOWN_PLACE_IDS[
        tonumber(placeId)
    ] == true
end

local function GAG2BuildJoinCode(placeId, jobId)

    local resolvedPlaceId =
        tonumber(placeId)
        or tonumber(game.PlaceId)
        or GROW_A_GARDEN_2_PLACE_ID

    local resolvedJobId =
        tostring(
            jobId
            or game.JobId
            or ""
        )
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    return tostring(resolvedPlaceId)
        .. ":"
        .. tostring(resolvedJobId)
end

local function GAG2KnownPlaceIdsText()

    local ids =
        {}

    for placeId in pairs(GROW_A_GARDEN_2_KNOWN_PLACE_IDS) do

        table.insert(
            ids,
            tostring(placeId)
        )
    end

    table.sort(
        ids
    )

    return table.concat(
        ids,
        ", "
    )
end

local REPO_URL =
    "https://raw.githubusercontent.com/bencapalot041/goons/main/"

local LIBRARY_URL =
    REPO_URL
    .. "librarygag2.lua?v="
    .. tostring(os.time())

local THEME_MANAGER_URL =
    REPO_URL
    .. "addons/ThemeManager.lua?v="
    .. tostring(os.time())

local SAVE_MANAGER_URL =
    REPO_URL
    .. "addons/SaveManager.lua?v="
    .. tostring(os.time())

local UI_SETTINGS_FOLDER =
    "HolyGAG2"

local UI_SETTINGS_FILE =
    UI_SETTINGS_FOLDER
    .. "/UISettings.json"

GAG2_GROUPBOX_ORDER_FILE =
    UI_SETTINGS_FOLDER
    .. "/GroupboxOrder.json"

local HOLY_GAG2_DEVELOPER_USER_IDS = {
    [78428093] = true,
}

GAG2_RARE_PET_WEBHOOK_URL =
    "https://discord.com/api/webhooks/1515303541718253599/9YlEfcONg8Kkn4om9gZKL8HYYGYVeOeLKyaJJbQGd-grIqxme_2PH5QkmmKZZBI8ESjc"

GAG2_RARE_PET_WEBHOOK_ROLE_ID =
    "1515584233811345499"

GAG2_RARE_PET_WEBHOOK_TARGETS = {
    raccoon = true,
    goldendragonfly = true,
    unicorn = true,

}

GAG2_RARE_PET_WEBHOOK_IMAGES = {
    raccoon =
        "https://static.wikia.nocookie.net/growagarden27847/images/7/7c/Raccoon.png/revision/latest?cb=20260612232005",

    unicorn =
        "https://static.wikia.nocookie.net/growagarden27847/images/7/7e/Unicorn.png/revision/latest?cb=20260612212539",

    goldendragonfly =
        "https://static.wikia.nocookie.net/growagarden27847/images/e/ee/GoldenDragonfly.png/revision/latest?cb=20260612231815",

    monkey =
        "https://static.wikia.nocookie.net/growagarden27847/images/2/27/Monkey.png/revision/latest?cb=20260612231816",

    iceserpent =
        "https://static.wikia.nocookie.net/growagarden27847/images/5/51/IceSerpent.png/revision/latest?cb=20260612231814",
}

GAG2_RARE_PET_WEBHOOK_SENT =
    {}

GAG2_SERVER_HOP_RETRYING =
    false

GAG2_SERVER_HOP_ATTEMPT =
    0

GAG2_EXACT_JOIN_TARGET_FILE =
    UI_SETTINGS_FOLDER
    .. "/ExactJoinTarget.json"

GAG2_EXACT_JOIN_STATE = {
    Retrying = false,
    MaxAttempts = 3,
    Target = nil,
}

GAG2_SNIPER_TOGGLE_CONTROL =
    nil

GAG2_SNIPER_KEYBIND_CONTROL =
    nil

GAG2_SNIPER_STOPPING =
    false

GAG2_MANUAL_JOIN_STATE = {
    HudEnabled = false,
    TargetText = "",
    LastTargetText = "",
    StatusText = "Paste full placeId:JobId.",
    PreviewText = "Paste full placeId:JobId.",
    Refreshing = false,
}

GAG2_MANUAL_JOIN_INPUT_CONTROL =
    nil

GAG2_MANUAL_JOIN_HUD_TOGGLE =
    nil

GAG2_MANUAL_JOIN_HUD_GUI =
    nil

GAG2_MANUAL_JOIN_HUD_INPUT =
    nil

GAG2_MANUAL_JOIN_HUD_STATUS =
    nil

GAG2_PANIC_HUD_GUI =
    nil

GAG2_PANIC_HUD_STATUS =
    nil

GAG2_PANIC_HUD_CREATED =
    false

GAG2_LOADING_GUI_CLEANER_RUNNING =
    false

GAG2_AUTO_PLAY_STATE = {
    Started = false,
    Finished = false,
    LastClick = 0,
    Attempts = 0,
}

GAG2_AUTO_TP_MIDDLE_FARM_STATE = {
    Running = false,
    CharacterConnection = nil,

    LastTeleportAt = 0,
    LastResult = "not started",
    LastTarget = nil,
    LastTargetReason = "not resolved",

    SkipStarted = false,
    SkipSucceeded = false,
    SkipAttempts = 0,
    SkipSuccessReason = "",

    HoldingSkip = false,
    HoldStartAt = 0,
    HoldMaxSeconds = 0,
    HoldX = 0,
    HoldY = 0,

    PostLoadRepairDistance = 25,
    MaxRunSeconds = 18,
}

--==================================================
-- [2] BASIC HELPERS
--==================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local function CleanText(value)

    return tostring(value or "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

local function IsHolyGAG2Developer()

    return LOCAL_PLAYER
        and HOLY_GAG2_DEVELOPER_USER_IDS[LOCAL_PLAYER.UserId] == true
end

local function IsGAG2World()

    return IsGAG2KnownPlace(
        game.PlaceId
    )
end

local function BoolText(value)

    return value == true
        and "YES"
        or "NO"
end

local function PathOf(instance)

    if typeof(instance) ~= "Instance" then
        return tostring(instance)
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

local function CopyText(text)

    local clipboard =
        setclipboard
        or toclipboard
        or set_clipboard

    if type(clipboard) ~= "function" then
        return false
    end

    local ok =
        pcall(function()

            clipboard(
                tostring(text or "")
            )
        end)

    return ok == true
end

local UIState = {
    ShowUIOnLoad = true,
    DPIScale = 100,
}

local ConfigState = {
    AutosaveName = "autosave",
    Dirty = false,
    Loading = true,
}

local function CanUseUISettingsFile()

    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

local function EnsureUISettingsFolder()

    if type(makefolder) ~= "function"
    or type(isfolder) ~= "function" then
        return false
    end

    local ok =
        pcall(function()

            if not isfolder(UI_SETTINGS_FOLDER) then
                makefolder(UI_SETTINGS_FOLDER)
            end
        end)

    return ok == true
end

local function SaveUISettingsNow()

    if CanUseUISettingsFile() ~= true then
        return false
    end

    EnsureUISettingsFolder()

    local payload = {
        ShowUIOnLoad =
            UIState.ShowUIOnLoad == true,

        AutoCloseUI =
            UIState.ShowUIOnLoad ~= true,

        DPIScale =
            tonumber(UIState.DPIScale)
            or 100,
    }

    local ok, encoded =
        pcall(function()

            return HttpService:JSONEncode(
                payload
            )
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

local function LoadUISettingsEarly()

    if CanUseUISettingsFile() ~= true then
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

            return HttpService:JSONDecode(
                raw
            )
        end)

    if decodeOk ~= true
    or type(payload) ~= "table" then
        return false
    end

    if type(payload.AutoCloseUI) == "boolean" then

        UIState.ShowUIOnLoad =
            payload.AutoCloseUI ~= true

    elseif type(payload.ShowUIOnLoad) == "boolean" then

        UIState.ShowUIOnLoad =
            payload.ShowUIOnLoad
    end

    local scale =
        tonumber(payload.DPIScale)

    if scale then

        UIState.DPIScale =
            math.clamp(
                math.floor(scale + 0.5),
                30,
                110
            )
    end

    return true
end

local function MarkConfigDirty()

    if ConfigState.Loading == true then
        return
    end

    ConfigState.Dirty =
        true
end

local function FormatDPIScale(value)

    local scale =
        math.clamp(
            math.floor(
                tonumber(value)
                or 100
            ),
            30,
            110
        )

    return tostring(scale) .. "%"
end

local function ParseDPIScale(value)

    local rawValue =
        tostring(value or "100%")

    local cleanedValue =
        rawValue:gsub("%%", "")

    local scale =
        tonumber(cleanedValue)

    if not scale then
        scale =
            100
    end

    return math.clamp(
        math.floor(scale + 0.5),
        30,
        110
    )
end

LoadUISettingsEarly()

--==================================================
-- [3] LIBRARY LOAD
--==================================================

local Library =
    loadstring(
        game:HttpGet(LIBRARY_URL)
    )()

local ThemeManager =
    loadstring(
        game:HttpGet(THEME_MANAGER_URL)
    )()

local SaveManager =
    loadstring(
        game:HttpGet(SAVE_MANAGER_URL)
    )()

local Options =
    Library.Options

local Toggles =
    Library.Toggles

Library.ForceCheckbox =
    false

Library.ShowToggleFrameInKeybinds =
    true

getgenv().HOLY_GAG2_LIBRARY =
    Library

function GAG2LoadGroupboxOrders()

    if CanUseUISettingsFile() ~= true then
        return {}
    end

    local exists =
        false

    local existsOk =
        pcall(function()

            exists =
                isfile(
                    GAG2_GROUPBOX_ORDER_FILE
                )
        end)

    if existsOk ~= true
    or exists ~= true then
        return {}
    end

    local readOk, raw =
        pcall(function()

            return readfile(
                GAG2_GROUPBOX_ORDER_FILE
            )
        end)

    if readOk ~= true
    or type(raw) ~= "string"
    or raw == "" then
        return {}
    end

    local decodeOk, payload =
        pcall(function()

            return HttpService:JSONDecode(
                raw
            )
        end)

    if decodeOk == true
    and type(payload) == "table" then
        return payload
    end

    return {}
end

function GAG2SaveGroupboxOrders(orderTable)

    if CanUseUISettingsFile() ~= true then
        return false
    end

    EnsureUISettingsFolder()

    local encodeOk, encoded =
        pcall(function()

            return HttpService:JSONEncode(
                type(orderTable) == "table"
                and orderTable
                or {}
            )
        end)

    if encodeOk ~= true
    or type(encoded) ~= "string" then
        return false
    end

    local writeOk =
        pcall(function()

            writefile(
                GAG2_GROUPBOX_ORDER_FILE,
                encoded
            )
        end)

    return writeOk == true
end

Library.GroupboxDragEnabled =
    true

Library.GroupboxOrders =
    GAG2LoadGroupboxOrders()

Library.GroupboxOrderChanged =
    function(orderTable)

        GAG2SaveGroupboxOrders(
            orderTable
        )
    end

local function Notify(title, description, duration)

    if Library
    and type(Library.Notify) == "function" then

        Library:Notify({
            Title = tostring(title or "Holy GAG2"),
            Description = tostring(description or ""),
            Time = tonumber(duration) or 4,
        })

        return
    end

    print(
        "[HOLY GAG2]",
        tostring(title),
        tostring(description)
    )
end

--==================================================
-- [4] LOGIC HELPERS
--==================================================

local function SetStatus(text)

    if Options.HolyGAG2Status then

        Options.HolyGAG2Status:SetText(
            '<font color="rgb(196,181,253)"><b>Status:</b></font> '
            .. tostring(text or "Ready")
        )
    end
end

local function BuildServerInfoText()

    local lines = {
        "Players: "
            .. tostring(#Players:GetPlayers())
            .. " | Code ready",
    }

    if type(GAG2VersionHopBuildHomeText) == "function" then

        table.insert(
            lines,
            GAG2VersionHopBuildHomeText()
        )
    end

    return table.concat(
        lines,
        "\n"
    )
end

local function RefreshServerInfo()

    if Options.HolyGAG2ServerInfo then

        Options.HolyGAG2ServerInfo:SetText(
            BuildServerInfoText()
        )
    end
end

--==================================================
-- [4.1] EXACT SERVER JOIN GUARD
--==================================================

function GAG2ClearExactJoinTarget(reason)

    GAG2_EXACT_JOIN_STATE.Target =
        nil

    if type(isfile) == "function"
    and type(delfile) == "function" then

        pcall(function()

            if isfile(GAG2_EXACT_JOIN_TARGET_FILE) then

                delfile(
                    GAG2_EXACT_JOIN_TARGET_FILE
                )
            end
        end)
    end

    if reason then

        print(
            "[HOLY GAG2 EXACT JOIN]",
            "cleared target:",
            tostring(reason)
        )
    end
end

function GAG2SaveExactJoinTarget(placeId, jobId, attempts, reason)

    local payload = {
        PlaceId =
            tonumber(placeId),

        JobId =
            CleanText(jobId),

        Attempts =
            math.max(
                0,
                math.floor(
                    tonumber(attempts)
                    or 0
                )
            ),

        CreatedAt =
            os.time(),

        Reason =
            tostring(reason or "manual"),
    }

    if not payload.PlaceId
    or payload.PlaceId <= 0
    or payload.JobId == "" then

        return false
    end

    GAG2_EXACT_JOIN_STATE.Target =
        payload

    if CanUseUISettingsFile() ~= true then
        return false
    end

    EnsureUISettingsFolder()

    local ok, encoded =
        pcall(function()

            return HttpService:JSONEncode(
                payload
            )
        end)

    if ok ~= true
    or type(encoded) ~= "string" then
        return false
    end

    local writeOk =
        pcall(function()

            writefile(
                GAG2_EXACT_JOIN_TARGET_FILE,
                encoded
            )
        end)

    return writeOk == true
end

function GAG2ReadExactJoinTarget()

    if type(GAG2_EXACT_JOIN_STATE) == "table"
    and type(GAG2_EXACT_JOIN_STATE.Target) == "table" then

        return GAG2_EXACT_JOIN_STATE.Target
    end

    if CanUseUISettingsFile() ~= true then
        return nil
    end

    local exists =
        false

    local existsOk =
        pcall(function()

            exists =
                isfile(
                    GAG2_EXACT_JOIN_TARGET_FILE
                )
        end)

    if existsOk ~= true
    or exists ~= true then
        return nil
    end

    local readOk, raw =
        pcall(function()

            return readfile(
                GAG2_EXACT_JOIN_TARGET_FILE
            )
        end)

    if readOk ~= true
    or type(raw) ~= "string"
    or raw == "" then
        return nil
    end

    local decodeOk, payload =
        pcall(function()

            return HttpService:JSONDecode(
                raw
            )
        end)

    if decodeOk ~= true
    or type(payload) ~= "table" then

        GAG2ClearExactJoinTarget(
            "bad json"
        )

        return nil
    end

    payload.PlaceId =
        tonumber(payload.PlaceId)

    payload.JobId =
        CleanText(payload.JobId)

    payload.Attempts =
        math.max(
            0,
            math.floor(
                tonumber(payload.Attempts)
                or 0
            )
        )

    payload.CreatedAt =
        tonumber(payload.CreatedAt)
        or os.time()

    if not payload.PlaceId
    or payload.PlaceId <= 0
    or payload.JobId == "" then

        GAG2ClearExactJoinTarget(
            "bad target"
        )

        return nil
    end

    if os.time() - payload.CreatedAt > 180 then

        GAG2ClearExactJoinTarget(
            "expired"
        )

        return nil
    end

    GAG2_EXACT_JOIN_STATE.Target =
        payload

    return payload
end

function GAG2ExactJoinMatchesCurrent(target)

    if type(target) ~= "table" then
        return false
    end

    return tonumber(target.PlaceId) == tonumber(game.PlaceId)
        and tostring(target.JobId) == tostring(game.JobId)
end

function GAG2QueueExactJoin(placeId, jobId, reason)

    placeId =
        tonumber(placeId)

    jobId =
        CleanText(jobId)

    if not placeId
    or placeId <= 0
    or jobId == "" then
        return false, "bad exact join target"
    end

    GAG2_SERVER_HOP_RETRYING =
        false

    GAG2_SERVER_HOP_ATTEMPT =
        0

    SetStatus(
        "Exact joining: "
        .. tostring(placeId)
        .. ":"
        .. tostring(jobId)
    )

    print(
        "[HOLY GAG2 EXACT JOIN]",
        "TeleportToPlaceInstance",
        "| place:",
        tostring(placeId),
        "| job:",
        tostring(jobId),
        "| reason:",
        tostring(reason or "manual")
    )

    local ok, err =
        pcall(function()

            TeleportService:TeleportToPlaceInstance(
                placeId,
                jobId,
                LOCAL_PLAYER
            )
        end)

    if ok ~= true then

        SetStatus(
            "Exact join failed: "
            .. tostring(err)
        )

        warn(
            "[HOLY GAG2 EXACT JOIN]",
            "call failed:",
            tostring(err)
        )

        return false,
            tostring(err)
    end

    return true,
        "queued"
end

function GAG2RetryExactJoinTarget(target, reason)

    if type(target) ~= "table" then
        return false
    end

    if GAG2_EXACT_JOIN_STATE.Retrying == true then
        return true
    end

    local attempts =
        math.max(
            0,
            math.floor(
                tonumber(target.Attempts)
                or 0
            )
        )

    local maxAttempts =
        math.max(
            1,
            math.floor(
                tonumber(GAG2_EXACT_JOIN_STATE.MaxAttempts)
                or 3
            )
        )

    if attempts >= maxAttempts then

        local wanted =
            tostring(target.PlaceId)
            .. ":"
            .. tostring(target.JobId)

        local current =
            tostring(game.PlaceId)
            .. ":"
            .. tostring(game.JobId)

        GAG2ClearExactJoinTarget(
            "max attempts"
        )

        SetStatus(
            "Exact join failed. Target closed/full?"
        )

        GAG2SetManualJoinStatus(
            "Exact failed. Wanted "
            .. wanted
            .. " got "
            .. current
        )

        warn(
            "[HOLY GAG2 EXACT JOIN]",
            "max attempts reached",
            "| wanted:",
            wanted,
            "| current:",
            current
        )

        return false
    end

    attempts += 1

    target.Attempts =
        attempts

    GAG2SaveExactJoinTarget(
        target.PlaceId,
        target.JobId,
        attempts,
        reason or "retry"
    )

    GAG2_EXACT_JOIN_STATE.Retrying =
        true

    GAG2_SERVER_HOP_RETRYING =
        false

    GAG2_SERVER_HOP_ATTEMPT =
        0

    SetStatus(
        "Wrong server. Retrying exact "
        .. tostring(attempts)
        .. "/"
        .. tostring(maxAttempts)
    )

    GAG2SetManualJoinStatus(
        "Retrying exact "
        .. tostring(attempts)
        .. "/"
        .. tostring(maxAttempts)
        .. ": "
        .. tostring(target.PlaceId)
        .. ":"
        .. tostring(target.JobId)
    )

    task.delay(0.35, function()

        GAG2QueueExactJoin(
            target.PlaceId,
            target.JobId,
            reason or "exact retry"
        )

        task.delay(2, function()

            GAG2_EXACT_JOIN_STATE.Retrying =
                false
        end)
    end)

    return true
end

function GAG2HandlePendingExactJoinOnLoad()

    local target =
        GAG2ReadExactJoinTarget()

    if not target then
        return false
    end

    if GAG2ExactJoinMatchesCurrent(target) == true then

        GAG2ClearExactJoinTarget(
            "verified"
        )

        SetStatus(
            "Exact server verified."
        )

        GAG2SetManualJoinStatus(
            "Exact server verified."
        )

        print(
            "[HOLY GAG2 EXACT JOIN]",
            "verified exact server:",
            tostring(game.PlaceId),
            tostring(game.JobId)
        )

        return false
    end

    local wanted =
        tostring(target.PlaceId)
        .. ":"
        .. tostring(target.JobId)

    local current =
        tostring(game.PlaceId)
        .. ":"
        .. tostring(game.JobId)

    warn(
        "[HOLY GAG2 EXACT JOIN]",
        "landed in wrong server",
        "| wanted:",
        wanted,
        "| current:",
        current
    )

    return GAG2RetryExactJoinTarget(
        target,
        "arrival mismatch"
    )
end

local function RejoinServer()

    SetStatus("Rejoining...")

    local ok, err =
        pcall(function()

            TeleportService:Teleport(
                game.PlaceId,
                LOCAL_PLAYER
            )
        end)

    if ok ~= true then

        SetStatus(
            "Rejoin failed: "
            .. tostring(err)
        )

        Notify(
            "Rejoin Failed",
            tostring(err),
            5
        )
    end
end

function GAG2ParseManualJoinTarget(text)

    text =
        tostring(text or "")
            :gsub("`", "")
            :gsub("\n", " ")
            :gsub("\r", " ")
            :gsub("−", "-")
            :gsub("–", "-")
            :gsub("—", "-")

    text =
        CleanText(
            text
        )

    if text == "" then
        return nil, "Paste full placeId:JobId."
    end

    local placeId =
        nil

    local jobId =
        nil

    local placeFromPair, jobFromPair =
        text:match("(%d+)%s*[:|,]%s*([%w%-]+)")

    if placeFromPair
    and jobFromPair then

        placeId =
            tonumber(placeFromPair)

        jobId =
            jobFromPair
    end

    if not placeId then

        placeId =
            tonumber(
                text:match("[Pp]lace[Ii][Dd][%s:=]+(%d+)")
            )
            or tonumber(
                text:match("[Pp]lace%s*[Ii][Dd][%s:=]+(%d+)")
            )
            or tonumber(
                text:match("placeId=(%d+)")
            )
            or tonumber(
                text:match("PlaceId=(%d+)")
            )
    end

    if not jobId
    or jobId == "" then

        jobId =
            text:match("[Gg]ame[Ii]nstance[Ii][Dd][%s=:/]+([%w%-]+)")
            or text:match("gameInstanceId=([%w%-]+)")
            or text:match("GameInstanceId=([%w%-]+)")
            or text:match("[Jj]ob[Ii][Dd][%s=:/]+([%w%-]+)")
            or text:match("jobId=([%w%-]+)")
            or text:match("JobId=([%w%-]+)")
            or text:match("([%w]+%-%w+%-%w+%-%w+%-%w+)")
            or ""
    end

    jobId =
        CleanText(jobId)
            :gsub("[^%w%-]", "")

    if not placeId
    or placeId <= 0 then

        return nil,
            "JobId-only blocked. Paste full placeId:JobId from Discord."
    end

    if jobId == ""
    or #jobId < 10 then
        return nil, "Invalid JobId."
    end

    return {
        PlaceId = placeId,
        JobId = jobId,
        JoinCode =
            GAG2BuildJoinCode(
                placeId,
                jobId
            ),
        PlaceWasInferred =
            false,
        KnownPlace =
            IsGAG2KnownPlace(
                placeId
            ),
    },
    nil
end

function GAG2SetManualJoinStatus(text)

    GAG2_MANUAL_JOIN_STATE.StatusText =
        tostring(text or "Ready.")

    GAG2RefreshManualJoinVisuals()
end

function GAG2SetManualJoinTargetText(text)

    GAG2_MANUAL_JOIN_STATE.TargetText =
        tostring(text or "")

    local parsed, errorText =
        GAG2ParseManualJoinTarget(
            GAG2_MANUAL_JOIN_STATE.TargetText
        )

    if parsed then

        local previewText =
            "Ready: "
            .. tostring(parsed.JoinCode)

        if parsed.PlaceWasInferred == true then

            previewText =
                previewText
                .. " (current place inferred)"
        end

        if parsed.KnownPlace ~= true then

            previewText =
                previewText
                .. " (unknown place)"
        end

        GAG2_MANUAL_JOIN_STATE.PreviewText =
            previewText

        GAG2_MANUAL_JOIN_STATE.StatusText =
            previewText

    else

        GAG2_MANUAL_JOIN_STATE.PreviewText =
            tostring(errorText or "Invalid input.")

        if CleanText(GAG2_MANUAL_JOIN_STATE.TargetText) == "" then

            GAG2_MANUAL_JOIN_STATE.StatusText =
                "Paste full placeId:JobId."

        else

            GAG2_MANUAL_JOIN_STATE.StatusText =
                tostring(errorText or "Invalid input.")
        end
    end

    GAG2RefreshManualJoinVisuals()
end

function GAG2CopyCurrentJoinCode()

    local payload =
        tostring(game.PlaceId)
        .. ":"
        .. tostring(game.JobId)

    if CopyText(payload) == true then

        GAG2_MANUAL_JOIN_STATE.LastTargetText =
            payload

        GAG2SetManualJoinStatus(
            "Copied current server code."
        )

        Notify(
            "Copied",
            "Current server code copied.",
            3
        )

        return true
    end

    GAG2SetManualJoinStatus(
        "Clipboard unsupported."
    )

    Notify(
        "Clipboard",
        "Clipboard unsupported.",
        4
    )

    return false
end

function GAG2ManualJoinServer()

    local parsed, errorText =
        GAG2ParseManualJoinTarget(
            GAG2_MANUAL_JOIN_STATE.TargetText
        )

    if not parsed then

        GAG2SetManualJoinStatus(
            tostring(errorText or "Invalid input.")
        )

        Notify(
            "Join Server",
            tostring(errorText or "Invalid input."),
            4
        )

        return false
    end

    if parsed.KnownPlace ~= true then

        GAG2SetManualJoinStatus(
            "Unknown PlaceId: "
            .. tostring(parsed.PlaceId)
        )

        Notify(
            "Join Server",
            "Unknown GAG2 PlaceId. Add it to known places first.",
            5
        )

        return false
    end

    if tonumber(parsed.PlaceId) == tonumber(game.PlaceId)
    and tostring(parsed.JobId) == tostring(game.JobId) then

        GAG2SetManualJoinStatus(
            "Already in this server."
        )

        Notify(
            "Join Server",
            "Already in this server.",
            3
        )

        return false
    end

    if type(GAG2CancelServerHop) == "function" then

        GAG2CancelServerHop(
            nil
        )

    else

        GAG2_SERVER_HOP_RETRYING =
            false

        GAG2_SERVER_HOP_ATTEMPT =
            0
    end

    GAG2_MANUAL_JOIN_STATE.LastTargetText =
        parsed.JoinCode

    GAG2SaveExactJoinTarget(
        parsed.PlaceId,
        parsed.JobId,
        0,
        "manual join"
    )

    GAG2SetManualJoinStatus(
        "Exact joining: "
        .. tostring(parsed.JoinCode)
    )

    SetStatus(
        "Exact joining: "
        .. tostring(parsed.JoinCode)
    )

    local ok, err =
        GAG2QueueExactJoin(
            parsed.PlaceId,
            parsed.JobId,
            "manual join"
        )

    if ok ~= true then

        GAG2ClearExactJoinTarget(
            "manual join call failed"
        )

        GAG2SetManualJoinStatus(
            "Exact join failed."
        )

        SetStatus(
            "Exact join failed: "
            .. tostring(err)
        )

        Notify(
            "Join Failed",
            tostring(err),
            5
        )

        return false
    end

    return true
end

function GAG2GetManualJoinHudParent()

    local ok =
        pcall(function()

            if CoreGui then
                return CoreGui.Name
            end
        end)

    if ok == true
    and CoreGui then
        return CoreGui
    end

    return LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")
        or nil
end

function GAG2DestroyManualJoinHud()

    if GAG2_MANUAL_JOIN_HUD_GUI then

        pcall(function()

            GAG2_MANUAL_JOIN_HUD_GUI:Destroy()
        end)
    end

    GAG2_MANUAL_JOIN_HUD_GUI =
        nil

    GAG2_MANUAL_JOIN_HUD_INPUT =
        nil

    GAG2_MANUAL_JOIN_HUD_STATUS =
        nil
end

function GAG2StyleManualJoinButton(button)

    if typeof(button) ~= "Instance" then
        return
    end

    button.BackgroundColor3 =
        Color3.fromRGB(24, 18, 38)

    button.BorderSizePixel =
        0

    button.Font =
        Enum.Font.Code

    button.TextSize =
        12

    button.TextColor3 =
        Color3.fromRGB(232, 230, 240)

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 5)

    corner.Parent =
        button
end

function GAG2CreateManualJoinHud()

    if GAG2_MANUAL_JOIN_HUD_GUI then
        return GAG2_MANUAL_JOIN_HUD_GUI
    end

    local parent =
        GAG2GetManualJoinHudParent()

    if not parent then

        GAG2SetManualJoinStatus(
            "HUD parent missing."
        )

        return nil
    end

    local gui =
        Instance.new("ScreenGui")

    gui.Name =
        "HolyGAG2ManualJoinHud"

    gui.ResetOnSpawn =
        false

    gui.IgnoreGuiInset =
        true

    gui.ZIndexBehavior =
        Enum.ZIndexBehavior.Sibling

    gui.Parent =
        parent

    local frame =
        Instance.new("Frame")

    frame.Name =
        "Frame"

    frame.Position =
        UDim2.new(
            1,
            -318,
            0,
            130
        )

    frame.Size =
        UDim2.fromOffset(
            300,
            130
        )

    frame.BackgroundColor3 =
        Color3.fromRGB(9, 7, 15)

    frame.BorderSizePixel =
        0

    frame.Active =
        true

    frame.Draggable =
        true

    frame.Parent =
        gui

    local frameCorner =
        Instance.new("UICorner")

    frameCorner.CornerRadius =
        UDim.new(0, 8)

    frameCorner.Parent =
        frame

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        Color3.fromRGB(88, 64, 145)

    stroke.Thickness =
        1

    stroke.Transparency =
        0.15

    stroke.Parent =
        frame

    local title =
        Instance.new("TextLabel")

    title.Name =
        "Title"

    title.BackgroundTransparency =
        1

    title.Position =
        UDim2.fromOffset(
            10,
            5
        )

    title.Size =
        UDim2.fromOffset(
            245,
            22
        )

    title.Font =
        Enum.Font.Code

    title.TextSize =
        14

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.TextColor3 =
        Color3.fromRGB(232, 230, 240)

    title.Text =
        "Server Joiner"

    title.Parent =
        frame

    local close =
        Instance.new("TextButton")

    close.Name =
        "Close"

    close.BackgroundTransparency =
        1

    close.Position =
        UDim2.fromOffset(
            265,
            4
        )

    close.Size =
        UDim2.fromOffset(
            28,
            22
        )

    close.Font =
        Enum.Font.Code

    close.TextSize =
        16

    close.TextColor3 =
        Color3.fromRGB(196, 181, 253)

    close.Text =
        "×"

    close.Parent =
        frame

    close.MouseButton1Click:Connect(function()

        GAG2_MANUAL_JOIN_STATE.HudEnabled =
            false

        if GAG2_MANUAL_JOIN_HUD_TOGGLE
        and type(GAG2_MANUAL_JOIN_HUD_TOGGLE.SetValue) == "function" then

            pcall(function()

                GAG2_MANUAL_JOIN_HUD_TOGGLE:SetValue(
                    false
                )
            end)
        end

        GAG2DestroyManualJoinHud()

        MarkConfigDirty()
    end)

    local input =
        Instance.new("TextBox")

    input.Name =
        "Target"

    input.Position =
        UDim2.fromOffset(
            10,
            32
        )

    input.Size =
        UDim2.fromOffset(
            280,
            26
        )

    input.BackgroundColor3 =
        Color3.fromRGB(15, 12, 24)

    input.BorderSizePixel =
        0

    input.ClearTextOnFocus =
        false

    input.Font =
        Enum.Font.Code

    input.TextSize =
        12

    input.TextXAlignment =
        Enum.TextXAlignment.Left

    input.TextColor3 =
        Color3.fromRGB(232, 230, 240)

    input.PlaceholderColor3 =
        Color3.fromRGB(125, 116, 145)

    input.PlaceholderText =
        "required: placeId:JobId..."

    input.Text =
        GAG2_MANUAL_JOIN_STATE.TargetText

    input.Parent =
        frame

    local inputCorner =
        Instance.new("UICorner")

    inputCorner.CornerRadius =
        UDim.new(0, 5)

    inputCorner.Parent =
        input

    input.FocusLost:Connect(function()

        GAG2SetManualJoinTargetText(
            input.Text
        )
    end)

    local status =
        Instance.new("TextLabel")

    status.Name =
        "Status"

    status.BackgroundTransparency =
        1

    status.Position =
        UDim2.fromOffset(
            10,
            62
        )

    status.Size =
        UDim2.fromOffset(
            280,
            18
        )

    status.Font =
        Enum.Font.Code

    status.TextSize =
        12

    status.TextXAlignment =
        Enum.TextXAlignment.Left

    status.TextColor3 =
        Color3.fromRGB(196, 181, 253)

    status.Text =
        GAG2_MANUAL_JOIN_STATE.StatusText

    status.Parent =
        frame

    local join =
        Instance.new("TextButton")

    join.Name =
        "Join"

    join.Position =
        UDim2.fromOffset(
            10,
            88
        )

    join.Size =
        UDim2.fromOffset(
            82,
            24
        )

    join.Text =
        "Join"

    join.Parent =
        frame

    GAG2StyleManualJoinButton(
        join
    )

    join.MouseButton1Click:Connect(function()

        GAG2SetManualJoinTargetText(
            input.Text
        )

        GAG2ManualJoinServer()
    end)

    local copy =
        Instance.new("TextButton")

    copy.Name =
        "CopyCurrent"

    copy.Position =
        UDim2.fromOffset(
            101,
            88
        )

    copy.Size =
        UDim2.fromOffset(
            88,
            24
        )

    copy.Text =
        "Current"

    copy.Parent =
        frame

    GAG2StyleManualJoinButton(
        copy
    )

    copy.MouseButton1Click:Connect(function()

        GAG2CopyCurrentJoinCode()
    end)

    local rejoin =
        Instance.new("TextButton")

    rejoin.Name =
        "Rejoin"

    rejoin.Position =
        UDim2.fromOffset(
            198,
            88
        )

    rejoin.Size =
        UDim2.fromOffset(
            92,
            24
        )

    rejoin.Text =
        "Rejoin"

    rejoin.Parent =
        frame

    GAG2StyleManualJoinButton(
        rejoin
    )

    rejoin.MouseButton1Click:Connect(function()

        GAG2SetManualJoinTargetText(
            tostring(game.PlaceId)
            .. ":"
            .. tostring(game.JobId)
        )

        GAG2ManualJoinServer()
    end)

    GAG2_MANUAL_JOIN_HUD_GUI =
        gui

    GAG2_MANUAL_JOIN_HUD_INPUT =
        input

    GAG2_MANUAL_JOIN_HUD_STATUS =
        status

    GAG2RefreshManualJoinVisuals()

    return gui
end

function GAG2SetManualJoinHudEnabled(value)

    GAG2_MANUAL_JOIN_STATE.HudEnabled =
        value == true

    if GAG2_MANUAL_JOIN_STATE.HudEnabled == true then

        GAG2CreateManualJoinHud()

    else

        GAG2DestroyManualJoinHud()
    end

    MarkConfigDirty()
end

function GAG2RefreshManualJoinVisuals()

    if type(GAG2_MANUAL_JOIN_STATE) ~= "table" then
        return
    end

    if GAG2_MANUAL_JOIN_STATE.Refreshing == true then
        return
    end

    GAG2_MANUAL_JOIN_STATE.Refreshing =
        true

    if GAG2_MANUAL_JOIN_INPUT_CONTROL
    and type(GAG2_MANUAL_JOIN_INPUT_CONTROL.SetValue) == "function" then

        pcall(function()

            GAG2_MANUAL_JOIN_INPUT_CONTROL:SetValue(
                GAG2_MANUAL_JOIN_STATE.TargetText
            )
        end)
    end

    if GAG2_MANUAL_JOIN_HUD_INPUT
    and GAG2_MANUAL_JOIN_HUD_INPUT.Text ~= GAG2_MANUAL_JOIN_STATE.TargetText then

        pcall(function()

            GAG2_MANUAL_JOIN_HUD_INPUT.Text =
                GAG2_MANUAL_JOIN_STATE.TargetText
        end)
    end

    if GAG2_MANUAL_JOIN_HUD_STATUS then

        pcall(function()

            GAG2_MANUAL_JOIN_HUD_STATUS.Text =
                GAG2_MANUAL_JOIN_STATE.StatusText
                or GAG2_MANUAL_JOIN_STATE.PreviewText
                or "Ready."
        end)
    end

    GAG2_MANUAL_JOIN_STATE.Refreshing =
        false
end

local function GetHttp(url)

    local ok, body =
        pcall(function()

            return game:HttpGet(
                tostring(url or "")
            )
        end)

    if ok == true
    and type(body) == "string"
    and body ~= "" then
        return body
    end

    local requestFunction =
        (syn and syn.request)
        or http_request
        or request
        or (fluxus and fluxus.request)

    if type(requestFunction) ~= "function" then
        return nil
    end

    local requestOk, response =
        pcall(function()

            return requestFunction({
                Url = tostring(url or ""),
                Method = "GET",
            })
        end)

    if requestOk == true
    and type(response) == "table" then
        return response.Body
    end

    return nil
end

--==================================================
-- [4.12] SERVER SELECTION MODE
-- Used by manual hop, version hopper, and sniper auto-hop.
--==================================================

GAG2_SERVER_SELECTION_MODES =
    GAG2_SERVER_SELECTION_MODES
    or {
        "Most Empty",
        "Random",
        "Most Full",
        "Balanced",
    }

GAG2_SERVER_SELECTION_STATE =
    GAG2_SERVER_SELECTION_STATE
    or {
        Mode = "Most Empty",
        LastStatus = "Ready.",
        LastTarget = "",
    }

function GAG2ServerSelectionClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2ServerSelectionModeValid(mode)

    mode =
        GAG2ServerSelectionClean(mode)

    return table.find(
        GAG2_SERVER_SELECTION_MODES,
        mode
    ) ~= nil
end

function GAG2ServerSelectionGetMode()

    local state =
        GAG2_SERVER_SELECTION_STATE

    local mode =
        GAG2ServerSelectionClean(
            state.Mode
        )

    if GAG2ServerSelectionModeValid(mode) ~= true then
        mode =
            "Most Empty"
    end

    state.Mode =
        mode

    return mode
end

function GAG2ServerSelectionBuildStatus()

    local state =
        GAG2_SERVER_SELECTION_STATE

    return '<font color="rgb(196,181,253)"><b>Server Selection</b></font>'
        .. '\nMode: '
        .. tostring(GAG2ServerSelectionGetMode())
        .. '\nLast: '
        .. tostring(state.LastStatus or "Ready.")
        .. '\nTarget: '
        .. tostring(state.LastTarget or "None")
end

function GAG2ServerSelectionRefreshStatus()

    if Options.HolyGAG2ServerSelectionStatus then

        Options.HolyGAG2ServerSelectionStatus:SetText(
            GAG2ServerSelectionBuildStatus()
        )
    end
end

function GAG2ServerSelectionSetStatus(text)

    GAG2_SERVER_SELECTION_STATE.LastStatus =
        tostring(text or "Ready.")

    GAG2ServerSelectionRefreshStatus()
end

function GAG2ServerSelectionSetMode(value)

    local mode =
        GAG2ServerSelectionClean(value)

    if GAG2ServerSelectionModeValid(mode) ~= true then
        mode =
            "Most Empty"
    end

    GAG2_SERVER_SELECTION_STATE.Mode =
        mode

    GAG2ServerSelectionSetStatus(
        "Mode set to "
        .. tostring(mode)
        .. "."
    )

    MarkConfigDirty()
end

function GAG2ServerSelectionGetOccupancy(server)

    local playing =
        tonumber(server and server.playing)
        or 0

    local maxPlayers =
        tonumber(server and server.maxPlayers)
        or 0

    if maxPlayers <= 0 then
        return 0
    end

    return playing / maxPlayers
end

function GAG2ServerSelectionPickFromTop(servers, limit)

    limit =
        math.min(
            #servers,
            math.max(
                1,
                math.floor(
                    tonumber(limit)
                    or 10
                )
            )
        )

    return servers[
        math.random(
            1,
            limit
        )
    ]
end

function GAG2ServerSelectionPickTarget(servers)

    if type(servers) ~= "table"
    or #servers <= 0 then
        return nil
    end

    local mode =
        GAG2ServerSelectionGetMode()

    if mode == "Random" then

        return servers[
            math.random(
                1,
                #servers
            )
        ]
    end

    if mode == "Most Full" then

        table.sort(servers, function(a, b)

            return tonumber(a.playing or 0)
                > tonumber(b.playing or 0)
        end)

        return GAG2ServerSelectionPickFromTop(
            servers,
            10
        )
    end

    if mode == "Balanced" then

        local balanced =
            {}

        for _, server in ipairs(servers) do

            local occupancy =
                GAG2ServerSelectionGetOccupancy(
                    server
                )

            if occupancy >= 0.25
            and occupancy <= 0.85 then

                table.insert(
                    balanced,
                    server
                )
            end
        end

        if #balanced <= 0 then
            balanced = servers
        end

        table.sort(balanced, function(a, b)

            local aDistance =
                math.abs(
                    GAG2ServerSelectionGetOccupancy(a) - 0.50
                )

            local bDistance =
                math.abs(
                    GAG2ServerSelectionGetOccupancy(b) - 0.50
                )

            return aDistance < bDistance
        end)

        return GAG2ServerSelectionPickFromTop(
            balanced,
            10
        )
    end

    -- Default / old behavior: Most Empty.
    table.sort(servers, function(a, b)

        return tonumber(a.FreeSlots or 0)
            > tonumber(b.FreeSlots or 0)
    end)

    return GAG2ServerSelectionPickFromTop(
        servers,
        10
    )
end

function GAG2ServerSelectionRememberTarget(target)

    if type(target) ~= "table" then
        return
    end

    GAG2_SERVER_SELECTION_STATE.LastTarget =
        tostring(target.playing)
        .. "/"
        .. tostring(target.maxPlayers)
        .. " | "
        .. tostring(target.id or "?")

    GAG2ServerSelectionRefreshStatus()
end

function GAG2RestoreServerSelectionState()

    task.defer(function()

        if Options.HolyGAG2ServerSelectionMode then

            GAG2_SERVER_SELECTION_STATE.Mode =
                GAG2ServerSelectionClean(
                    Options.HolyGAG2ServerSelectionMode.Value
                )
        end

        if GAG2ServerSelectionModeValid(
            GAG2_SERVER_SELECTION_STATE.Mode
        ) ~= true then

            GAG2_SERVER_SELECTION_STATE.Mode =
                "Most Empty"
        end

        GAG2ServerSelectionSetStatus(
            "Ready."
        )
    end)
end

function HopServerOnce()

    if GAG2_SERVER_HOP_RETRYING == true then

        SetStatus(
            "Server hop already retrying..."
        )

        return false
    end

    GAG2_SERVER_HOP_RETRYING =
        true

    task.spawn(function()

        while GAG2_SERVER_HOP_RETRYING == true do

            GAG2_SERVER_HOP_ATTEMPT =
                tonumber(GAG2_SERVER_HOP_ATTEMPT)
                or 0

            GAG2_SERVER_HOP_ATTEMPT =
                GAG2_SERVER_HOP_ATTEMPT
                + 1

            SetStatus(
                "Finding server..."
                .. " attempt "
                .. tostring(GAG2_SERVER_HOP_ATTEMPT)
            )

            local url =
                "https://games.roblox.com/v1/games/"
                .. tostring(game.PlaceId)
                .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"

            local body =
                GetHttp(url)

            if type(body) ~= "string"
            or body == "" then

                SetStatus(
                    "Server list failed. Retrying..."
                )

                task.wait(
                    2
                )

                continue
            end

            local decodeOk, data =
                pcall(function()

                    return HttpService:JSONDecode(
                        body
                    )
                end)

            if decodeOk ~= true
            or type(data) ~= "table" then

                SetStatus(
                    "Server decode failed. Retrying..."
                )

                task.wait(
                    2
                )

                continue
            end

            local servers =
                {}

            for _, server in ipairs(data.data or {}) do

                local serverId =
                    CleanText(server.id)

                local playing =
                    tonumber(server.playing)
                    or 0

                local maxPlayers =
                    tonumber(server.maxPlayers)
                    or 0

                if serverId ~= ""
                and serverId ~= game.JobId
                and maxPlayers > 0
                and playing < maxPlayers then

                    server.FreeSlots =
                        maxPlayers - playing

                    table.insert(
                        servers,
                        server
                    )
                end
            end

            if #servers <= 0 then

                SetStatus(
                    "No valid server. Retrying..."
                )

                task.wait(
                    2
                )

                continue
            end

            if GAG2_SERVER_HOP_RETRYING ~= true then
                return
            end

            local target =
                GAG2ServerSelectionPickTarget(
                    servers
                )

            if not target then

                SetStatus(
                    "No server target selected. Retrying..."
                )

                GAG2ServerSelectionSetStatus(
                    "No target selected."
                )

                task.wait(
                    2
                )

                continue
            end

            GAG2ServerSelectionRememberTarget(
                target
            )

            SetStatus(
                "Hopping "
                .. tostring(GAG2ServerSelectionGetMode())
                .. " to "
                .. tostring(target.playing)
                .. "/"
                .. tostring(target.maxPlayers)
                .. " server..."
            )

            GAG2ServerSelectionSetStatus(
                "Teleporting using "
                .. tostring(GAG2ServerSelectionGetMode())
                .. "."
            )

                        if GAG2_SERVER_HOP_RETRYING ~= true then
                return
            end

            local ok, err =
                pcall(function()

                    TeleportService:TeleportToPlaceInstance(
                        game.PlaceId,
                        target.id,
                        LOCAL_PLAYER
                    )
                end)

            if ok == true then

                SetStatus(
                    "Teleport queued."
                )

                return
            end

            SetStatus(
                "Hop failed. Retrying..."
            )

            warn(
                "[HOLY GAG2]",
                "server hop failed",
                tostring(err)
            )

            task.wait(
                1.5
            )
        end
    end)

    return true
end

local function BuildSnapshot()

    local map =
        workspace:FindFirstChild("Map")

    local wildPetSpawns =
        map
        and map:FindFirstChild("WildPetSpawns")

    local wildPetRef =
        map
        and map:FindFirstChild("WildPetRef")

    local stockValues =
        ReplicatedStorage:FindFirstChild("StockValues")

    local remoteEvents =
        ReplicatedStorage:FindFirstChild("RemoteEvents")

    local replicaSet =
        remoteEvents
        and remoteEvents:FindFirstChild("ReplicaSet")

    local sharedModules =
        ReplicatedStorage:FindFirstChild("SharedModules")

    local packetFolder =
        sharedModules
        and sharedModules:FindFirstChild("Packet")

    local packetRemote =
        packetFolder
        and packetFolder:FindFirstChild("RemoteEvent")

    local lines = {
        "========== HOLY GAG2 SNAPSHOT ==========",
        "Player: " .. tostring(LOCAL_PLAYER.Name),
        "PlaceId: " .. tostring(game.PlaceId),
        "JobId: " .. tostring(game.JobId),
        "GAG2 Place: " .. BoolText(IsGAG2World()),
        "",
        "---- ROOTS ----",
        "workspace.Map: " .. BoolText(map ~= nil),
        "WildPetSpawns: " .. BoolText(wildPetSpawns ~= nil) .. " | count: " .. tostring(wildPetSpawns and #wildPetSpawns:GetChildren() or 0),
        "WildPetRef: " .. BoolText(wildPetRef ~= nil) .. " | count: " .. tostring(wildPetRef and #wildPetRef:GetChildren() or 0),
        "StockValues: " .. BoolText(stockValues ~= nil) .. " | count: " .. tostring(stockValues and #stockValues:GetChildren() or 0),
        "RemoteEvents.ReplicaSet: " .. BoolText(replicaSet ~= nil),
        "SharedModules.Packet.RemoteEvent: " .. BoolText(packetRemote ~= nil),
        "",
        "---- ACTIVE WILD PET SPAWNS ----",
    }

    if wildPetSpawns then

        local children =
            wildPetSpawns:GetChildren()

        table.sort(children, function(a, b)
            return tostring(a.Name) < tostring(b.Name)
        end)

        if #children <= 0 then

            table.insert(
                lines,
                "none"
            )

        else

            for index, child in ipairs(children) do

                if index > 25 then

                    table.insert(
                        lines,
                        "... +" .. tostring(#children - 25) .. " more"
                    )

                    break
                end

                table.insert(
                    lines,
                    tostring(index)
                    .. ". "
                    .. tostring(child.Name)
                    .. " | "
                    .. tostring(child.ClassName)
                    .. " | "
                    .. PathOf(child)
                )
            end
        end

    else

        table.insert(
            lines,
            "missing workspace.Map.WildPetSpawns"
        )
    end

    table.insert(lines, "")
    table.insert(lines, "---- STOCK VALUES ----")

    if stockValues then

        local children =
            stockValues:GetChildren()

        table.sort(children, function(a, b)
            return tostring(a.Name) < tostring(b.Name)
        end)

        if #children <= 0 then

            table.insert(
                lines,
                "none"
            )

        else

            for _, child in ipairs(children) do

                table.insert(
                    lines,
                    tostring(child.Name)
                    .. " | "
                    .. tostring(child.ClassName)
                    .. " | "
                    .. PathOf(child)
                )
            end
        end

    else

        table.insert(
            lines,
            "missing ReplicatedStorage.StockValues"
        )
    end

    table.insert(
        lines,
        "========================================="
    )

    return table.concat(
        lines,
        "\n"
    )
end

local function PrintSnapshot(copyToClipboard)

    local snapshot =
        BuildSnapshot()

    print(snapshot)

    if Options.HolyGAG2SnapshotStatus then

        Options.HolyGAG2SnapshotStatus:SetText(
            copyToClipboard == true
            and "Snapshot copied."
            or "Snapshot printed."
        )
    end

    if copyToClipboard == true then

        if CopyText(snapshot) == true then

            Notify(
                "Snapshot",
                "Copied to clipboard.",
                3
            )

        else

            Notify(
                "Snapshot",
                "Printed, but clipboard is unsupported.",
                4
            )
        end
    end
end

local function LoadDevTool(url, label)

    if IsHolyGAG2Developer() ~= true then

        Notify(
            "Dev",
            "Developer access required.",
            4
        )

        return
    end

    task.spawn(function()

        local ok, err =
            pcall(function()

                loadstring(
                    game:HttpGet(url)
                )()
            end)

        if ok == true then

            Notify(
                "Dev",
                tostring(label) .. " loaded.",
                3
            )

        else

            Notify(
                "Dev Error",
                tostring(err),
                5
            )
        end
    end)
end

--==================================================
-- [4.5] SNIPER HELPERS
-- Scanner + target matcher only. No buy/tame remotes yet.
--==================================================

SniperTargetDropdown =
    nil

SniperDropdownRefreshing =
    false

SniperPriorityDropdowns =
    {}

SniperPriorityRefreshing =
    false

local SniperState = {
    Enabled = false,
    Running = false,

    Targets = {},
    PriorityPets = {
        "",
        "",
        "",
        "",
        "",
    },
    KnownPetNames = {},
    AutoHop = false,
    InstantFirstHop = false,
    FirstHopUsed = false,
    EnabledAt = 0,
    InstantHopGrace = 0,
    ReturnAfterTame = true,

    Taming = false,
    LastTameAt = 0,
    RecentTameAttempts = {},
    HandledWildPets = {},
    PendingWildPets = {},

    ConfirmingBuy = false,
    ConfirmingBuyKey = "",

    BuyValidationHoldDelay = 0.25,
    StartupBuyDelay = 8,
    StartedAt = os.clock(),

    LastPlayScreenPressAt = 0,
    PlayScreenClickAttempts = 0,
    PlayScreenMaxClickAttempts = 80,
    AutoPlayClickInterval = 0.09,
    AutoPlayTimeout = 45,
    PlayScreenClearAt = 0,
    PlayScreenClearGrace = 0.35,
    LoadingGuiClearAt = 0,
    LoadingGuiForceClear = true,

    WaitingForClaim = false,
    WaitingForClaimKey = "",
    ClaimWaitTimeout = 90,
    ClaimDisappearConfirmTime = 1.25,
    HandledPetCooldown = 120,

    PacketTable = nil,
    PacketSource = "not loaded",

    BuyPacket = nil,
    BuyPacketSource = "not loaded",

    ScanDelay = 0.25,
    HopDelay = 20,

    LastHopAt = 0,
    LastScanAt = 0,

    LastStatus = "Ready",
    LastMatchText = "No scan yet.",
    LastMatchCount = 0,
}

local function SetSniperStatus(text)

    SniperState.LastStatus =
        tostring(text or "Ready")

    if Options.HolyGAG2SniperStatus then

        Options.HolyGAG2SniperStatus:SetText(
            SniperState.LastStatus
        )
    end
end

local function RefreshSniperLabels()

    if Options.HolyGAG2SniperMatches then

        Options.HolyGAG2SniperMatches:SetText(
            SniperState.LastMatchText
        )
    end
end

local function SniperNormalizeName(value)

    return CleanText(value)
        :lower()
        :gsub("%s+", " ")
end

local function SniperNormalizeList(value)

    local result =
        {}

    local function add(item)

        item =
            CleanText(item)

        if item == "" then
            return
        end

        if table.find(result, item) ~= nil then
            return
        end

        table.insert(
            result,
            item
        )
    end

    if type(value) == "table" then

        for _, item in ipairs(value) do
            add(item)
        end

        for item, enabled in pairs(value) do

            if enabled == true then
                add(item)
            end
        end

    elseif type(value) == "string" then

        add(value)
    end

    table.sort(result)

    return result
end

local function SniperSetTargets(value)

    SniperState.Targets =
        SniperNormalizeList(value)

    MarkConfigDirty()
end

local function SniperTargetsText()

    if type(SniperState.Targets) ~= "table"
    or #SniperState.Targets <= 0 then
        return "None"
    end

    return table.concat(
        SniperState.Targets,
        ", "
    )
end

local function SniperRememberPetName(name)

    name =
        CleanText(name)

    if name == ""
    or name == "Unknown" then
        return
    end

    SniperState.KnownPetNames =
        SniperState.KnownPetNames
        or {}

    if table.find(SniperState.KnownPetNames, name) ~= nil then
        return
    end

    table.insert(
        SniperState.KnownPetNames,
        name
    )

    table.sort(
        SniperState.KnownPetNames
    )
end

local SniperPetRegistryBlacklist = {
    Behaviors = true,
    Breathe = true,
    DefendGarden = true,
    FireBreath = true,
    Fly = true,
    FlyIdle = true,
    GroundIdle = true,
    Idle = true,
    Land = true,
    PickFruit = true,
    StealFruit = true,
    TurnHopCountWeights = true,
    Walk = true,

    BlackDragonDefend = true,
    IceSerpentDefend = true,
}

local function SniperIsValidRegistryPetName(name)

    name =
        CleanText(name)

    if name == "" then
        return false
    end

    if SniperPetRegistryBlacklist[name] == true then
        return false
    end

    if name:find("Defend", 1, true) then
        return false
    end

    if name:find("Behavior", 1, true) then
        return false
    end

    if name:match("^%d+$") then
        return false
    end

    return true
end

function GAG2CancelServerHop(reason)

    GAG2_SERVER_HOP_RETRYING =
        false

    GAG2_SERVER_HOP_ATTEMPT =
        0

    if reason ~= nil
    and tostring(reason) ~= "" then

        SetStatus(
            tostring(reason)
        )
    end
end

local function SniperGetPetModulesRoot()

    local sharedModules =
        ReplicatedStorage:FindFirstChild("SharedModules")

    return sharedModules
        and sharedModules:FindFirstChild("PetModules")
        or nil
end

local function SniperAddRegistryName(names, name)

    name =
        CleanText(name)

    if SniperIsValidRegistryPetName(name) ~= true then
        return
    end

    if table.find(names, name) ~= nil then
        return
    end

    table.insert(
        names,
        name
    )
end

local function SniperCollectRegistryTableNames(value, names, depth, seen)

    if type(value) ~= "table" then
        return
    end

    if depth > 3 then
        return
    end

    if seen[value] == true then
        return
    end

    seen[value] =
        true

    for key, child in pairs(value) do

        if type(key) == "string"
        and type(child) == "table" then

            SniperAddRegistryName(
                names,
                key
            )
        end

        if type(key) == "string"
        and (
            key == "Name"
            or key == "DisplayName"
            or key == "PetName"
        )
        and type(child) == "string" then

            SniperAddRegistryName(
                names,
                child
            )
        end

        if type(child) == "table" then

            SniperCollectRegistryTableNames(
                child,
                names,
                depth + 1,
                seen
            )
        end
    end
end

local function SniperGetRegistryPetNames()

    local names =
        {}

    local root =
        SniperGetPetModulesRoot()

    if root then

        for _, child in ipairs(root:GetChildren()) do

            if child:IsA("ModuleScript") then

                SniperAddRegistryName(
                    names,
                    child.Name
                )
            end
        end

        if root:IsA("ModuleScript") then

            local ok, result =
                pcall(function()

                    return require(
                        root
                    )
                end)

            if ok == true
            and type(result) == "table" then

                SniperCollectRegistryTableNames(
                    result,
                    names,
                    0,
                    {}
                )
            end
        end
    end

    table.sort(
        names
    )

    return names
end

local function SniperBuildTargets()

    local targets =
        {}

    local ordered =
        SniperNormalizeList(
            SniperState.Targets
        )

    for _, targetName in ipairs(ordered) do

        local key =
            SniperNormalizeName(targetName)

        if key ~= "" then
            targets[key] = true
        end
    end

    return targets, ordered
end

local function SniperGetSpawnsFolder()

    local map =
        workspace:FindFirstChild("Map")

    return map
        and map:FindFirstChild("WildPetSpawns")
end

local function SniperGetRefFolder()

    local map =
        workspace:FindFirstChild("Map")

    return map
        and map:FindFirstChild("WildPetRef")
end

local function SniperGetUuid(instanceName)

    instanceName =
        CleanText(instanceName)

    return instanceName:match("_WildPet_([%w%-]+)$")
        or instanceName:match("WildPet_([%w%-]+)$")
        or ""
end

local function SniperGetPetName(spawn)

    if typeof(spawn) ~= "Instance" then
        return "Unknown"
    end

    local attrNames = {
        "PetName",
        "WildPetName",
        "AnimalName",
        "DisplayName",
        "Name",
    }

    for _, attrName in ipairs(attrNames) do

        local ok, value =
            pcall(function()

                return spawn:GetAttribute(
                    attrName
                )
            end)

        local cleaned =
            ok == true
            and CleanText(value)
            or ""

        if cleaned ~= "" then
            return cleaned
        end
    end

    local fromName =
        CleanText(spawn.Name):match("^WildPet_(.-)_WildPet_")

    if fromName
    and fromName ~= "" then

        return CleanText(
            fromName:gsub("_", " ")
        )
    end

    return CleanText(
        tostring(spawn.Name):gsub("_", " ")
    )
end

local function SniperGetPosition(instance)

    if typeof(instance) ~= "Instance" then
        return nil
    end

    if instance:IsA("BasePart") then
        return instance.Position
    end

    if instance:IsA("Model") then

        if instance.PrimaryPart then
            return instance.PrimaryPart.Position
        end

        local ok, cf =
            pcall(function()

                return instance:GetBoundingBox()
            end)

        if ok == true
        and typeof(cf) == "CFrame" then
            return cf.Position
        end
    end

    for _, descendant in ipairs(instance:GetDescendants()) do

        if descendant:IsA("BasePart") then
            return descendant.Position
        end
    end

    return nil
end

local function SniperDistanceText(position)

    if typeof(position) ~= "Vector3" then
        return "? studs"
    end

    local character =
        LOCAL_PLAYER.Character

    local root =
        character
        and character:FindFirstChild("HumanoidRootPart")

    if not root then
        return "? studs"
    end

    return tostring(
        math.floor(
            (root.Position - position).Magnitude + 0.5
        )
    )
    .. " studs"
end

local function SniperFindRef(uuid)

    uuid =
        CleanText(uuid)

    if uuid == "" then
        return nil
    end

    local refFolder =
        SniperGetRefFolder()

    return refFolder
        and refFolder:FindFirstChild("WildPet_" .. uuid)
        or nil
end

function SniperCleanRichText(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function SniperGetTextRows(root)

    local rows =
        {}

    if typeof(root) ~= "Instance" then
        return rows
    end

    local scanned =
        0

    for _, descendant in ipairs(root:GetDescendants()) do

        scanned =
            scanned + 1

        if scanned > 180 then
            break
        end

        if descendant:IsA("TextLabel")
        or descendant:IsA("TextButton")
        or descendant:IsA("TextBox") then

            local ok, text =
                pcall(function()

                    return descendant.Text
                end)

            text =
                ok == true
                and SniperCleanRichText(text)
                or ""

            if text ~= "" then

                table.insert(rows, {
                    Text = text,
                    Path = PathOf(descendant),
                })
            end
        end
    end

    return rows
end

function SniperBuildTextRows(spawn, ref)

    local rows =
        {}

    if typeof(spawn) == "Instance" then

        for _, row in ipairs(SniperGetTextRows(spawn)) do

            table.insert(
                rows,
                row
            )
        end
    end

    if typeof(ref) == "Instance" then

        for _, row in ipairs(SniperGetTextRows(ref)) do

            table.insert(
                rows,
                row
            )
        end
    end

    return rows
end

function SniperReadAttributeAny(instance, attrNames)

    if typeof(instance) ~= "Instance" then
        return nil
    end

    for _, attrName in ipairs(attrNames or {}) do

        local ok, value =
            pcall(function()

                return instance:GetAttribute(
                    attrName
                )
            end)

        if ok == true
        and value ~= nil
        and tostring(value) ~= "" then
            return value
        end
    end

    return nil
end

function SniperFormatSeconds(seconds)

    seconds =
        math.max(
            0,
            math.floor(
                tonumber(seconds)
                or 0
            )
        )

    local minutes =
        math.floor(seconds / 60)

    local remain =
        seconds % 60

    if minutes > 0 then

        return tostring(minutes)
            .. "m "
            .. tostring(remain)
            .. "s"
    end

    return tostring(remain)
        .. "s"
end

function SniperFormatMoney(value)

    local number =
        tonumber(value)

    if not number then

        local text =
            SniperCleanRichText(value)

        if text == "" then
            return "?"
        end

        return text
    end

    local text =
        tostring(
            math.floor(number + 0.5)
        )

    text =
        text:reverse()
            :gsub("(%d%d%d)", "%1,")
            :reverse()
            :gsub("^,", "")

    return "¢" .. text
end

function SniperExtractTimer(textRows)

    for _, row in ipairs(textRows or {}) do

        local text =
            tostring(row.Text or "")

        local timer =
            text:match("(%d+%s*m%s*%d+%s*s)")
            or text:match("(%d+%s*:%s*%d+)")
            or text:match("(%d+%s*s)")

        if timer then

            return SniperCleanRichText(
                timer:gsub("%s+", " ")
            )
        end
    end

    return "?"
end

function SniperExtractPrice(textRows)

    for _, row in ipairs(textRows or {}) do

        local text =
            tostring(row.Text or "")

        if text:find("¢", 1, true)
        or text:find("$", 1, true)
        or text:lower():find("sheckle", 1, true) then

            return SniperCleanRichText(
                text:match("¢%s*[%d,%.]+")
                or text:match("%$%s*[%d,%.]+")
                or text:match("[%d,%.]+%s*[Ss]heckles?")
                or text
            )
        end
    end

    return "?"
end

function SniperGetEntryTimer(spawn, ref, textRows)

    local value =
        SniperReadAttributeAny(
            spawn,
            {
                "TimeLeft",
                "Timer",
                "Remaining",
                "RemainingTime",
                "DespawnTime",
                "ExpiresAt",
                "EndTime",
                "Duration",
            }
        )

    if value == nil
    and typeof(ref) == "Instance" then

        value =
            SniperReadAttributeAny(
                ref,
                {
                    "TimeLeft",
                    "Timer",
                    "Remaining",
                    "RemainingTime",
                    "DespawnTime",
                    "ExpiresAt",
                    "EndTime",
                    "Duration",
                }
            )
    end

    if typeof(value) == "number"
    or tonumber(value) ~= nil then

        local number =
            tonumber(value)

        if number > os.time() then

            return SniperFormatSeconds(
                number - os.time()
            )
        end

        return SniperFormatSeconds(
            number
        )
    end

    if value ~= nil
    and tostring(value) ~= "" then

        return SniperCleanRichText(
            value
        )
    end

    return SniperExtractTimer(
        textRows
    )
end

function SniperGetEntryPrice(spawn, ref, textRows)

    local value =
        SniperReadAttributeAny(
            spawn,
            {
                "Price",
                "Cost",
                "Sheckles",
                "BuyPrice",
                "PurchasePrice",
                "TamePrice",
            }
        )

    if value == nil
    and typeof(ref) == "Instance" then

        value =
            SniperReadAttributeAny(
                ref,
                {
                    "Price",
                    "Cost",
                    "Sheckles",
                    "BuyPrice",
                    "PurchasePrice",
                    "TamePrice",
                }
            )
    end

    if value ~= nil
    and tostring(value) ~= "" then

        return SniperFormatMoney(
            value
        )
    end

    return SniperExtractPrice(
        textRows
    )
end

local function SniperSafePairsSnapshot(value)

    if type(value) ~= "table" then
        return {}
    end

    local ok, result =
        pcall(function()

            local rows =
                {}

            for key, child in pairs(value) do

                table.insert(rows, {
                    Key = key,
                    Value = child,
                })
            end

            return rows
        end)

    if ok == true
    and type(result) == "table" then
        return result
    end

    return {}
end

local function SniperSafeRawGet(value, key)

    if type(value) ~= "table" then
        return nil
    end

    local ok, result =
        pcall(function()

            return rawget(
                value,
                key
            )
        end)

    if ok == true then
        return result
    end

    return nil
end

local function SniperIsPacketObject(value)

    if type(value) ~= "table" then
        return false
    end

    return type(SniperSafeRawGet(value, "Name")) == "string"
        and SniperSafeRawGet(value, "Id") ~= nil
        and type(SniperSafeRawGet(value, "Writes")) == "table"
end

local function SniperWildPacketScore(packetName, path)

    local text =
        (
            tostring(packetName or "")
            .. " "
            .. tostring(path or "")
        ):lower()

    if text:find("wild", 1, true) == nil then
        return 0
    end

    local score =
        0

    if text:find("wildpet", 1, true) then
        score += 400
    end

    if text:find("wild_pet", 1, true) then
        score += 400
    end

    if text:find("wild", 1, true) then
        score += 250
    end

    if text:find("pet", 1, true) then
        score += 80
    end

    if text:find("buy", 1, true) then
        score += 120
    end

    if text:find("purchase", 1, true) then
        score += 120
    end

    if text:find("tame", 1, true) then
        score += 160
    end

    if text:find("adopt", 1, true) then
        score += 100
    end

    if text:find("claim", 1, true) then
        score += 30
    end

    if text:find("seed", 1, true) then
        score -= 500
    end

    if text:find("gear", 1, true) then
        score -= 500
    end

    if text:find("crate", 1, true) then
        score -= 500
    end

    if text:find("sell", 1, true) then
        score -= 500
    end

    if text:find("trade", 1, true) then
        score -= 500
    end

    if text:find("plant", 1, true) then
        score -= 500
    end

    if text:find("inventory", 1, true) then
        score -= 250
    end

    if text:find("equip", 1, true) then
        score -= 250
    end

    return score
end

local function SniperSearchWildPackets(candidate, seen, depth, path, results)

    if type(candidate) ~= "table" then
        return
    end

    if depth > 9 then
        return
    end

    if seen[candidate] == true then
        return
    end

    seen[candidate] =
        true

    if SniperIsPacketObject(candidate) == true then

        local packetName =
            tostring(
                SniperSafeRawGet(candidate, "Name")
                or ""
            )

        local score =
            SniperWildPacketScore(
                packetName,
                path
            )

        if score >= 300 then

            table.insert(results, {
                Packet = candidate,
                Name = packetName,
                Path = path,
                Score = score,
            })
        end
    end

    for _, row in ipairs(SniperSafePairsSnapshot(candidate)) do

        if type(row.Value) == "table" then

            SniperSearchWildPackets(
                row.Value,
                seen,
                depth + 1,
                path .. "." .. tostring(row.Key),
                results
            )
        end
    end
end

local function SniperHasShopPacketTable(candidate)

    if type(candidate) ~= "table" then
        return false
    end

    local seedShop =
        SniperSafeRawGet(candidate, "SeedShop")

    local gearShop =
        SniperSafeRawGet(candidate, "GearShop")

    local crateShop =
        SniperSafeRawGet(candidate, "CrateShop")

    if type(seedShop) ~= "table"
    or type(gearShop) ~= "table"
    or type(crateShop) ~= "table" then
        return false
    end

    return SniperIsPacketObject(
        SniperSafeRawGet(seedShop, "PurchaseSeed")
    )
    and SniperIsPacketObject(
        SniperSafeRawGet(gearShop, "PurchaseGear")
    )
    and SniperIsPacketObject(
        SniperSafeRawGet(crateShop, "PurchaseCrate")
    )
end

local function SniperPacketTableHasWildPacket(candidate)

    if type(candidate) ~= "table" then
        return false
    end

    local results =
        {}

    SniperSearchWildPackets(
        candidate,
        {},
        0,
        "Packets",
        results
    )

    return #results > 0
end

local function SniperSearchPacketTable(candidate, seen, depth)

    if type(candidate) ~= "table" then
        return nil
    end

    if depth > 6 then
        return nil
    end

    if seen[candidate] == true then
        return nil
    end

    seen[candidate] =
        true

    if SniperHasShopPacketTable(candidate) == true then
        return candidate
    end

    if SniperPacketTableHasWildPacket(candidate) == true then
        return candidate
    end

    for _, row in ipairs(SniperSafePairsSnapshot(candidate)) do

        if type(row.Value) == "table" then

            local found =
                SniperSearchPacketTable(
                    row.Value,
                    seen,
                    depth + 1
                )

            if found then
                return found
            end
        end
    end

    return nil
end

local function SniperFindPacketTable()

    if type(SniperState.PacketTable) == "table"
    and (
        SniperHasShopPacketTable(SniperState.PacketTable) == true
        or SniperPacketTableHasWildPacket(SniperState.PacketTable) == true
    ) then

        return SniperState.PacketTable
    end

    if type(getloadedmodules) ~= "function" then

        SniperState.PacketSource =
            "getloadedmodules unsupported"

        return nil
    end

    local okModules, modules =
        pcall(getloadedmodules)

    if okModules ~= true
    or type(modules) ~= "table" then

        SniperState.PacketSource =
            "getloadedmodules failed"

        return nil
    end

    for _, module in ipairs(modules) do

        if typeof(module) == "Instance"
        and module:IsA("ModuleScript") then

            local okRequire, result =
                pcall(function()

                    return require(
                        module
                    )
                end)

            if okRequire == true then

                local found =
                    SniperSearchPacketTable(
                        result,
                        {},
                        0
                    )

                if found then

                    SniperState.PacketTable =
                        found

                    SniperState.PacketSource =
                        "require: "
                        .. module:GetFullName()

                    return found
                end

                if type(result) == "table"
                and type(debug) == "table"
                and type(debug.getupvalues) == "function" then

                    for _, row in ipairs(SniperSafePairsSnapshot(result)) do

                        if type(row.Value) == "function" then

                            local okUpvalues, upvalues =
                                pcall(function()

                                    return debug.getupvalues(
                                        row.Value
                                    )
                                end)

                            if okUpvalues == true
                            and type(upvalues) == "table" then

                                for upKey, upValue in pairs(upvalues) do

                                    found =
                                        SniperSearchPacketTable(
                                            upValue,
                                            {},
                                            0
                                        )

                                    if found then

                                        SniperState.PacketTable =
                                            found

                                        SniperState.PacketSource =
                                            "upvalue: "
                                            .. module:GetFullName()
                                            .. "."
                                            .. tostring(row.Key)
                                            .. " -> "
                                            .. tostring(upKey)

                                        return found
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    SniperState.PacketSource =
        "packet table not found"

    return nil
end

--==================================================
-- [4.52] SHOP AUTO BUY
--==================================================

local GAG2_SHOP_CATEGORIES = {
    Seeds = {
        ShopName = "SeedShop",
        ItemsFolderName = "Items",
        PacketShop = "SeedShop",
        PacketName = "PurchaseSeed",
        DisplayName = "Seeds",
    },

    Gear = {
        ShopName = "GearShop",
        ItemsFolderName = "Items",
        PacketShop = "GearShop",
        PacketName = "PurchaseGear",
        DisplayName = "Gear",
    },

    Crates = {
        ShopName = "CrateShop",
        ItemsFolderName = "Items",
        PacketShop = "CrateShop",
        PacketName = "PurchaseCrate",
        DisplayName = "Crates",
    },
}

local GAG2_SHOP_STATE = {
    Started = false,
    UiLoopRunning = false,
    WorkerRunning = false,

    Enabled = {
        Seeds = false,
        Gear = false,
        Crates = false,
    },

    Selected = {
        Seeds = {},
        Gear = {},
        Crates = {},
    },

    BurstAttempts = {
        Seeds = {},
        Gear = {},
        Crates = {},
    },

    Queue = {},
    QueuedKeys = {},

    Connections = {},
    ItemConnections = {},

    PacketCache = {},
    LastPacketResolveAt = {},

    HiddenBurstDelay = 0,
    HiddenMaxBurstFires = 120,

    LastStockText = "Loading stock...",
}

local GAG2_SHOP_DROPDOWNS = {
    Seeds = nil,
    Gear = nil,
    Crates = nil,
}

local function GAG2ShopGetStockRoot()

    return ReplicatedStorage:FindFirstChild("StockValues")
end

local function GAG2ShopGetShopFolder(category)

    local info =
        GAG2_SHOP_CATEGORIES[category]

    if not info then
        return nil
    end

    local root =
        GAG2ShopGetStockRoot()

    return root
        and root:FindFirstChild(info.ShopName)
        or nil
end

local function GAG2ShopGetItemsFolder(category)

    local info =
        GAG2_SHOP_CATEGORIES[category]

    local shop =
        GAG2ShopGetShopFolder(category)

    if not info
    or not shop then
        return nil
    end

    return shop:FindFirstChild(
        info.ItemsFolderName
    )
end

local function GAG2ShopCleanItemName(itemName)

    itemName =
        CleanText(itemName)

    if itemName == ""
    or itemName == "---" then
        return ""
    end

    local beforePipe =
        itemName:match("^(.-)%s+|%s+")

    if beforePipe
    and CleanText(beforePipe) ~= "" then

        itemName =
            CleanText(beforePipe)
    end

    return itemName
end

local function GAG2ShopGetStockValueObject(category, itemName)

    local items =
        GAG2ShopGetItemsFolder(category)

    if not items then
        return nil
    end

    itemName =
        GAG2ShopCleanItemName(itemName)

    if itemName == "" then
        return nil
    end

    return items:FindFirstChild(itemName)
end

local function GAG2ShopReadStock(category, itemName)

    local object =
        GAG2ShopGetStockValueObject(
            category,
            itemName
        )

    if not object
    or object:IsA("ValueBase") ~= true then

        return nil
    end

    return tonumber(object.Value)
end

local function GAG2ShopGetRestockKey(category)

    local shop =
        GAG2ShopGetShopFolder(category)

    if not shop then
        return "0"
    end

    local nextRestock =
        shop:FindFirstChild("UnixNextRestock")

    local lastRestock =
        shop:FindFirstChild("UnixLastRestock")

    if nextRestock
    and nextRestock:IsA("ValueBase") then

        return tostring(nextRestock.Value)
    end

    if lastRestock
    and lastRestock:IsA("ValueBase") then

        return tostring(lastRestock.Value)
    end

    return "0"
end

local function GAG2ShopGetNextRestockTime()

    local best =
        nil

    for category in pairs(GAG2_SHOP_CATEGORIES) do

        local shop =
            GAG2ShopGetShopFolder(category)

        local nextRestock =
            shop
            and shop:FindFirstChild("UnixNextRestock")

        if nextRestock
        and nextRestock:IsA("ValueBase") then

            local value =
                tonumber(nextRestock.Value)

            if value
            and value > 0
            and (
                best == nil
                or value < best
            ) then

                best =
                    value
            end
        end
    end

    return best
end

local function GAG2ShopFormatRestockTime()

    local nextRestock =
        GAG2ShopGetNextRestockTime()

    if not nextRestock then
        return "?"
    end

    return SniperFormatSeconds(
        math.max(
            0,
            nextRestock - os.time()
        )
    )
end

local function GAG2ShopNormalizeSelection(value)

    local selected =
        {}

    local function add(itemName)

        itemName =
            GAG2ShopCleanItemName(itemName)

        if itemName == "" then
            return
        end

        selected[itemName] =
            true
    end

    if type(value) == "table" then

        for _, itemName in ipairs(value) do
            add(itemName)
        end

        for itemName, enabled in pairs(value) do

            if enabled == true then
                add(itemName)
            end
        end

    elseif type(value) == "string" then

        add(value)
    end

    return selected
end

local GAG2_SHOP_PRICE_CACHE = {
    Built = false,
    LastGuiScanAt = 0,
    Prices = {
        Seeds = {},
        Gear = {},
        Crates = {},
    },
}

local GAG2ShopReadPrice =
    nil

local function GAG2ShopGetSortScore(category, itemName)

    if type(GAG2ShopReadPrice) ~= "function" then
        return nil, false
    end

    local price =
        GAG2ShopReadPrice(
            category,
            itemName
        )

    if price then

        return tonumber(price),
            true
    end

    return nil,
        false
end

local function GAG2ShopParsePriceNumber(value)

    local text =
        CleanText(
            tostring(value or "")
                :gsub("<[^>]->", "")
                :gsub("<.->", "")
        )

    if text == "" then
        return nil
    end

    local lowerText =
        text:lower()

    if lowerText:find("robux", 1, true)
    or lowerText:find("r$", 1, true) then
        return nil
    end

    if not text:find("¢", 1, true)
    and not lowerText:find("sheck", 1, true)
    and not lowerText:find("cost", 1, true) then

        return nil
    end

    local numberText =
        text:match("([%d,%.]+)%s*¢")
        or text:match("¢%s*([%d,%.]+)")
        or text:match("([%d,%.]+)%s*[Ss]heckles?")
        or text:match("[Cc]ost[%s:]+([%d,%.]+)")

    if not numberText then
        return nil
    end

    numberText =
        tostring(numberText)
            :gsub(",", "")
            :gsub("%s+", "")

    return tonumber(numberText)
end

local function GAG2ShopBuildNameToCategoryMap()

    local map =
        {}

    for category in pairs(GAG2_SHOP_CATEGORIES) do

        local items =
            GAG2ShopGetItemsFolder(category)

        if items then

            for _, child in ipairs(items:GetChildren()) do

                if child:IsA("ValueBase") then

                    map[child.Name] =
                        category
                end
            end
        end
    end

    return map
end

local function GAG2ShopCachePrice(category, itemName, price)

    category =
        CleanText(category)

    itemName =
        GAG2ShopCleanItemName(itemName)

    price =
        tonumber(price)

    if not GAG2_SHOP_CATEGORIES[category]
    or itemName == ""
    or not price
    or price <= 0 then
        return
    end

    GAG2_SHOP_PRICE_CACHE.Prices[category] =
        GAG2_SHOP_PRICE_CACHE.Prices[category]
        or {}

    GAG2_SHOP_PRICE_CACHE.Prices[category][itemName] =
        price
end

local function GAG2ShopSafePairs(value)

    if type(value) ~= "table" then
        return {}
    end

    local ok, rows =
        pcall(function()

            local result =
                {}

            for key, child in pairs(value) do

                table.insert(result, {
                    Key = key,
                    Value = child,
                })
            end

            return result
        end)

    if ok == true
    and type(rows) == "table" then
        return rows
    end

    return {}
end

local function GAG2ShopLooksLikePriceKey(key)

    local lowerKey =
        tostring(key or ""):lower()

    if lowerKey:find("robux", 1, true) then
        return false
    end

    return lowerKey == "cost"
        or lowerKey == "price"
        or lowerKey == "sheckles"
        or lowerKey == "buyprice"
        or lowerKey == "purchaseprice"
        or lowerKey:find("cost", 1, true) ~= nil
        or lowerKey:find("price", 1, true) ~= nil
end

local function GAG2ShopFindModulePrices(value, nameToCategory, depth, seen)

    if type(value) ~= "table" then
        return
    end

    if depth > 7 then
        return
    end

    if seen[value] == true then
        return
    end

    seen[value] =
        true

    local possibleName =
        nil

    for _, row in ipairs(GAG2ShopSafePairs(value)) do

        if type(row.Key) == "string"
        and (
            row.Key == "Name"
            or row.Key == "DisplayName"
            or row.Key == "ItemName"
            or row.Key == "SeedName"
            or row.Key == "GearName"
            or row.Key == "CrateName"
            or row.Key == "PlantName"
        )
        and type(row.Value) == "string" then

            possibleName =
                CleanText(row.Value)
        end
    end

    if possibleName
    and nameToCategory[possibleName] then

        for _, row in ipairs(GAG2ShopSafePairs(value)) do

            if GAG2ShopLooksLikePriceKey(row.Key)
            and tonumber(row.Value) then

                GAG2ShopCachePrice(
                    nameToCategory[possibleName],
                    possibleName,
                    row.Value
                )
            end
        end
    end

    for _, row in ipairs(GAG2ShopSafePairs(value)) do

        if type(row.Key) == "string"
        and nameToCategory[row.Key]
        and type(row.Value) == "table" then

            for _, childRow in ipairs(GAG2ShopSafePairs(row.Value)) do

                if GAG2ShopLooksLikePriceKey(childRow.Key)
                and tonumber(childRow.Value) then

                    GAG2ShopCachePrice(
                        nameToCategory[row.Key],
                        row.Key,
                        childRow.Value
                    )
                end
            end
        end

        if type(row.Value) == "table" then

            GAG2ShopFindModulePrices(
                row.Value,
                nameToCategory,
                depth + 1,
                seen
            )
        end
    end
end

local function GAG2ShopBuildModulePriceCache()

    if GAG2_SHOP_PRICE_CACHE.Built == true then
        return
    end

    GAG2_SHOP_PRICE_CACHE.Built =
        true

    local nameToCategory =
        GAG2ShopBuildNameToCategoryMap()

    local sharedModules =
        ReplicatedStorage:FindFirstChild("SharedModules")

    if not sharedModules then
        return
    end

    local preferredModules = {
        "CrateData",
        "GearShopData",
        "SeedShopData",
        "SeedData",
        "SeedsData",
        "PlantData",
        "CropData",
        "ShopData",
        "ItemData",
        "EconomyData",
        "ProductData",
        "StoreData",
    }

    local scanned =
        {}

    for _, moduleName in ipairs(preferredModules) do

        local module =
            sharedModules:FindFirstChild(
                moduleName,
                true
            )

        if module
        and module:IsA("ModuleScript")
        and scanned[module] ~= true then

            scanned[module] =
                true

            local ok, result =
                pcall(function()

                    return require(module)
                end)

            if ok == true
            and type(result) == "table" then

                GAG2ShopFindModulePrices(
                    result,
                    nameToCategory,
                    0,
                    {}
                )
            end
        end
    end
end

local function GAG2ShopScanGuiPrices()

    -- Disabled for performance.
    -- Scanning PlayerGui descendants for prices causes client stutter on low-end/cloud devices.
    -- Prices now come from replicated module data, attributes, or cached values only.

    return
end

GAG2ShopReadPrice = function(category, itemName)

    category =
        CleanText(category)

    itemName =
        GAG2ShopCleanItemName(itemName)

    if itemName == "" then
        return nil
    end

    local cachedBucket =
        GAG2_SHOP_PRICE_CACHE.Prices[category]

    if cachedBucket
    and tonumber(cachedBucket[itemName]) then

        return tonumber(
            cachedBucket[itemName]
        )
    end

    local object =
        GAG2ShopGetStockValueObject(
            category,
            itemName
        )

    if object then

        local attrNames = {
            "Price",
            "Cost",
            "Sheckles",
            "BuyPrice",
            "PurchasePrice",
        }

        for _, attrName in ipairs(attrNames) do

            local ok, value =
                pcall(function()

                    return object:GetAttribute(attrName)
                end)

            if ok == true
            and tonumber(value) then

                GAG2ShopCachePrice(
                    category,
                    itemName,
                    value
                )

                return tonumber(value)
            end
        end

        for _, child in ipairs(object:GetChildren()) do

            local childName =
                tostring(child.Name):lower()

            if child:IsA("ValueBase")
            and not childName:find("robux", 1, true)
            and (
                childName:find("price", 1, true)
                or childName:find("cost", 1, true)
                or childName:find("sheckle", 1, true)
            )
            and tonumber(child.Value) then

                GAG2ShopCachePrice(
                    category,
                    itemName,
                    child.Value
                )

                return tonumber(child.Value)
            end
        end
    end

    GAG2ShopBuildModulePriceCache()

    cachedBucket =
        GAG2_SHOP_PRICE_CACHE.Prices[category]

    return cachedBucket
        and tonumber(cachedBucket[itemName])
        or nil
end

local function GAG2ShopFormatPrice(category, itemName)

    local price =
        GAG2ShopReadPrice(
            category,
            itemName
        )

    if not price then
        return "¢?"
    end

    return SniperFormatMoney(
        price
    )
end

local function GAG2ShopGetSortedItemRows(category)

    local rows =
        {}

    local items =
        GAG2ShopGetItemsFolder(category)

    if not items then
        return rows
    end

    for _, child in ipairs(items:GetChildren()) do

        if child:IsA("ValueBase") then

            local price =
                GAG2ShopReadPrice(
                    category,
                    child.Name
                )

            table.insert(rows, {
                Name = child.Name,
                Price = price,
            })
        end
    end

    table.sort(rows, function(a, b)

        local aPrice =
            tonumber(a.Price)

        local bPrice =
            tonumber(b.Price)

        if aPrice
        and bPrice
        and aPrice ~= bPrice then

            return aPrice > bPrice
        end

        if aPrice
        and not bPrice then
            return true
        end

        if bPrice
        and not aPrice then
            return false
        end

        return tostring(a.Name)
            < tostring(b.Name)
    end)

    return rows
end

local function GAG2ShopMakeDropdownDisplayName(category, itemName)

    itemName =
        GAG2ShopCleanItemName(itemName)

    if itemName == "" then
        return ""
    end

    return itemName
        .. " | "
        .. GAG2ShopFormatPrice(
            category,
            itemName
        )
end

local function GAG2ShopGetItemNames(category)

    local values =
        {}

    for _, row in ipairs(GAG2ShopGetSortedItemRows(category)) do

        local displayName =
            GAG2ShopMakeDropdownDisplayName(
                category,
                row.Name
            )

        if displayName ~= "" then

            table.insert(
                values,
                displayName
            )
        end
    end

    return values
end

local function GAG2ShopBuildCurrentStockText()

    local lines = {
        '<font color="rgb(196,181,253)"><b>Current Stock</b></font>',
        "Restock in: " .. GAG2ShopFormatRestockTime(),
    }

    for _, category in ipairs({
        "Seeds",
        "Gear",
        "Crates",
    }) do

        local info =
            GAG2_SHOP_CATEGORIES[category]

        table.insert(lines, "")
        table.insert(
            lines,
            '<font color="rgb(196,181,253)"><b>'
            .. tostring(info.DisplayName)
            .. '</b></font>'
        )

        local rows =
            {}

        local items =
            GAG2ShopGetItemsFolder(category)

        if items then

            for _, child in ipairs(items:GetChildren()) do

                if child:IsA("ValueBase") then

                    local stock =
                        tonumber(child.Value)
                        or 0

                    if stock > 0 then

                        table.insert(rows, {
                            Name = child.Name,
                            Stock = stock,
                            Price =
                                GAG2ShopReadPrice(
                                    category,
                                    child.Name
                                ),
                        })
                    end
                end
            end
        end

        table.sort(rows, function(a, b)

            local aPrice =
                tonumber(a.Price)

            local bPrice =
                tonumber(b.Price)

            if aPrice
            and bPrice
            and aPrice ~= bPrice then

                return aPrice > bPrice
            end

            if aPrice
            and not bPrice then
                return true
            end

            if bPrice
            and not aPrice then
                return false
            end

            return tostring(a.Name)
                < tostring(b.Name)
        end)

        if #rows <= 0 then

            table.insert(
                lines,
                "None"
            )

        else

            for index, row in ipairs(rows) do

                if index > 14 then

                    table.insert(
                        lines,
                        "+ "
                        .. tostring(#rows - 14)
                        .. " more"
                    )

                    break
                end

                table.insert(
                    lines,
                    tostring(row.Name)
                    .. " x"
                    .. tostring(row.Stock)
                    .. " | "
                    .. (
                        row.Price
                        and SniperFormatMoney(
                            row.Price
                        )
                        or "¢?"
                    )
                )
            end
        end
    end

    return table.concat(
        lines,
        "\n"
    )
end

local function GAG2ShopRefreshStockLabel()

    GAG2_SHOP_STATE.LastStockText =
        GAG2ShopBuildCurrentStockText()

    if Options.HolyGAG2ShopCurrentStock then

        Options.HolyGAG2ShopCurrentStock:SetText(
            GAG2_SHOP_STATE.LastStockText
        )
    end
end

local function GAG2ShopRefreshDropdown(category)

    local dropdown =
        GAG2_SHOP_DROPDOWNS[category]

    if not dropdown then
        return
    end

    local values =
        GAG2ShopGetItemNames(category)

    pcall(function()

        if type(dropdown.SetValues) == "function" then

            dropdown:SetValues(
                values
            )

        elseif type(dropdown.SetItems) == "function" then

            dropdown:SetItems(
                values
            )
        end
    end)
end

local function GAG2ShopRefreshAllDropdowns()

    for category in pairs(GAG2_SHOP_CATEGORIES) do

        GAG2ShopRefreshDropdown(
            category
        )
    end
end

local function GAG2ShopResolvePacket(category)

    local cached =
        GAG2_SHOP_STATE.PacketCache[category]

    if cached ~= nil then
        return cached
    end

    local lastResolve =
        tonumber(
            GAG2_SHOP_STATE.LastPacketResolveAt[category]
        )
        or 0

    if os.clock() - lastResolve < 10 then
        return nil
    end

    GAG2_SHOP_STATE.LastPacketResolveAt[category] =
        os.clock()

    local info =
        GAG2_SHOP_CATEGORIES[category]

    if not info then
        return nil
    end

    local packets =
        SniperFindPacketTable()

    if type(packets) ~= "table" then
        return nil
    end

    local shopTable =
        SniperSafeRawGet(
            packets,
            info.PacketShop
        )

    if type(shopTable) ~= "table" then
        return nil
    end

    local packet =
        SniperSafeRawGet(
            shopTable,
            info.PacketName
        )

    local ok, fireFunction =
        pcall(function()

            return packet.Fire
        end)

    if ok == true
    and type(fireFunction) == "function" then

        GAG2_SHOP_STATE.PacketCache[category] =
            packet

        return packet
    end

    return nil
end

local function GAG2ShopFirePurchase(category, itemName)

    itemName =
        GAG2ShopCleanItemName(itemName)

    if itemName == "" then
        return false
    end

    local packet =
        GAG2ShopResolvePacket(
            category
        )

    if not packet then
        return false
    end

    local ok =
        pcall(function()

            packet:Fire(
                itemName
            )
        end)

    if ok ~= true then

        ok =
            pcall(function()

                packet.Fire(
                    packet,
                    itemName
                )
            end)
    end

    return ok == true
end

local function GAG2ShopGetBurstBucket(category)

    GAG2_SHOP_STATE.BurstAttempts =
        type(GAG2_SHOP_STATE.BurstAttempts) == "table"
        and GAG2_SHOP_STATE.BurstAttempts
        or {}

    GAG2_SHOP_STATE.BurstAttempts[category] =
        type(GAG2_SHOP_STATE.BurstAttempts[category]) == "table"
        and GAG2_SHOP_STATE.BurstAttempts[category]
        or {}

    return GAG2_SHOP_STATE.BurstAttempts[category]
end

local function GAG2ShopGetBurstKey(category, itemName, stock)

    return tostring(category)
        .. ":"
        .. CleanText(itemName)
        .. ":"
        .. tostring(GAG2ShopGetRestockKey(category))
        .. ":stock:"
        .. tostring(math.floor(tonumber(stock) or 0))
end

local function GAG2ShopBurstAlreadyAttempted(category, itemName, stock)

    local bucket =
        GAG2ShopGetBurstBucket(
            category
        )

    local burstKey =
        GAG2ShopGetBurstKey(
            category,
            itemName,
            stock
        )

    return bucket[itemName] == burstKey
end

local function GAG2ShopMarkBurstAttempt(category, itemName, stock)

    local bucket =
        GAG2ShopGetBurstBucket(
            category
        )

    bucket[itemName] =
        GAG2ShopGetBurstKey(
            category,
            itemName,
            stock
        )
end

local function GAG2ShopClearBurstAttempt(category, itemName)

    local bucket =
        GAG2ShopGetBurstBucket(
            category
        )

    if itemName then

        bucket[itemName] =
            nil

    else

        GAG2_SHOP_STATE.BurstAttempts[category] =
            {}
    end
end

local function GAG2ShopCanBuy(category, itemName)

    if GAG2_SHOP_STATE.Enabled[category] ~= true then
        return false
    end

    if type(GAG2_SHOP_STATE.Selected[category]) ~= "table"
    or GAG2_SHOP_STATE.Selected[category][itemName] ~= true then
        return false
    end

    local stock =
        GAG2ShopReadStock(
            category,
            itemName
        )

    if stock == nil
    or stock <= 0 then
        return false
    end

    if GAG2ShopBurstAlreadyAttempted(
        category,
        itemName,
        stock
    ) == true then

        return false
    end

    return true
end

local function GAG2ShopEnqueue(category, itemName)

    itemName =
        GAG2ShopCleanItemName(itemName)

    if itemName == "" then
        return
    end

    if GAG2ShopCanBuy(category, itemName) ~= true then
        return
    end

    local key =
        tostring(category)
        .. ":"
        .. itemName

    if GAG2_SHOP_STATE.QueuedKeys[key] == true then
        return
    end

    GAG2_SHOP_STATE.QueuedKeys[key] =
        true

    table.insert(GAG2_SHOP_STATE.Queue, {
        Category = category,
        ItemName = itemName,
        Key = key,
    })

    GAG2ShopStartWorker()
end

function GAG2ShopStartWorker()

    if GAG2_SHOP_STATE.WorkerRunning == true then
        return
    end

    GAG2_SHOP_STATE.WorkerRunning =
        true

    task.spawn(function()

        while #GAG2_SHOP_STATE.Queue > 0 do

            local job =
                table.remove(
                    GAG2_SHOP_STATE.Queue,
                    1
                )

            if job
            and job.Key then

                GAG2_SHOP_STATE.QueuedKeys[job.Key] =
                    nil
            end

            if job
            and GAG2ShopCanBuy(
                job.Category,
                job.ItemName
            ) == true then

                local stock =
                    GAG2ShopReadStock(
                        job.Category,
                        job.ItemName
                    )

                stock =
                    math.max(
                        0,
                        math.floor(
                            tonumber(stock)
                            or 0
                        )
                    )

                if stock > 0 then

                    GAG2ShopMarkBurstAttempt(
                        job.Category,
                        job.ItemName,
                        stock
                    )

                    local fireCount =
                        math.min(
                            stock,
                            math.floor(
                                tonumber(GAG2_SHOP_STATE.HiddenMaxBurstFires)
                                or 120
                            )
                        )

                    for fireIndex = 1, fireCount do

                        if GAG2_SHOP_STATE.Enabled[job.Category] ~= true then
                            break
                        end

                        if type(GAG2_SHOP_STATE.Selected[job.Category]) ~= "table"
                        or GAG2_SHOP_STATE.Selected[job.Category][job.ItemName] ~= true then
                            break
                        end

                        GAG2ShopFirePurchase(
                            job.Category,
                            job.ItemName
                        )

                        local burstDelay =
                            tonumber(GAG2_SHOP_STATE.HiddenBurstDelay)
                            or 0

                        if burstDelay > 0 then

                            task.wait(
                                burstDelay
                            )

                        elseif fireIndex % 24 == 0 then

                            task.wait()
                        end
                    end

                    GAG2ShopRefreshStockLabel()
                end
            end

            task.wait(
                0.01
            )
        end

        GAG2_SHOP_STATE.WorkerRunning =
            false
    end)
end

local function GAG2ShopEnqueueSelectedInStock(category)

    local selected =
        GAG2_SHOP_STATE.Selected[category]

    if type(selected) ~= "table" then
        return
    end

    for itemName, enabled in pairs(selected) do

        if enabled == true then

            GAG2ShopEnqueue(
                category,
                itemName
            )
        end
    end
end

local function GAG2ShopEnqueueAllSelectedInStock()

    for category in pairs(GAG2_SHOP_CATEGORIES) do

        GAG2ShopEnqueueSelectedInStock(
            category
        )
    end
end

local function GAG2ShopClearRestockBuys(category)

    if category then

        GAG2_SHOP_STATE.BurstAttempts[category] =
            {}

        return
    end

    for key in pairs(GAG2_SHOP_CATEGORIES) do

        GAG2_SHOP_STATE.BurstAttempts[key] =
            {}
    end
end

local function GAG2ShopTrackItem(category, itemObject)

    if typeof(itemObject) ~= "Instance"
    or itemObject:IsA("ValueBase") ~= true then
        return
    end

    local itemKey =
        tostring(category)
        .. ":"
        .. tostring(itemObject.Name)

    if GAG2_SHOP_STATE.ItemConnections[itemKey] then
        return
    end

    GAG2_SHOP_STATE.ItemConnections[itemKey] =
        itemObject.Changed:Connect(function()

            local itemName =
                itemObject.Name

            local currentStock =
                tonumber(itemObject.Value)
                or 0

            GAG2ShopClearBurstAttempt(
                category,
                itemName
            )

            GAG2ShopRefreshStockLabel()

            if currentStock > 0 then

                GAG2ShopEnqueue(
                    category,
                    itemName
                )
            end
        end)
end

local function GAG2ShopTrackCategory(category)

    local shop =
        GAG2ShopGetShopFolder(category)

    local items =
        GAG2ShopGetItemsFolder(category)

    if not shop
    or not items then
        return
    end

    for _, child in ipairs(items:GetChildren()) do

        GAG2ShopTrackItem(
            category,
            child
        )
    end

    table.insert(
        GAG2_SHOP_STATE.Connections,
        items.ChildAdded:Connect(function(child)

            task.wait(
                0.05
            )

            GAG2ShopTrackItem(
                category,
                child
            )

            GAG2ShopRefreshDropdown(
                category
            )

            GAG2ShopRefreshStockLabel()

            GAG2ShopEnqueue(
                category,
                child.Name
            )
        end)
    )

    table.insert(
        GAG2_SHOP_STATE.Connections,
        items.ChildRemoved:Connect(function()

            GAG2ShopRefreshDropdown(
                category
            )

            GAG2ShopRefreshStockLabel()
        end)
    )

    local lastRestock =
        shop:FindFirstChild("UnixLastRestock")

    if lastRestock
    and lastRestock:IsA("ValueBase") then

        table.insert(
            GAG2_SHOP_STATE.Connections,
            lastRestock.Changed:Connect(function()

                GAG2ShopClearRestockBuys(
                    category
                )

                task.wait(
                    0.15
                )

                GAG2ShopRefreshStockLabel()

                GAG2ShopEnqueueSelectedInStock(
                    category
                )
            end)
        )
    end

    local nextRestock =
        shop:FindFirstChild("UnixNextRestock")

    if nextRestock
    and nextRestock:IsA("ValueBase") then

        table.insert(
            GAG2_SHOP_STATE.Connections,
            nextRestock.Changed:Connect(function()

                GAG2ShopClearRestockBuys(
                    category
                )

                task.wait(
                    0.15
                )

                GAG2ShopRefreshStockLabel()

                GAG2ShopEnqueueSelectedInStock(
                    category
                )
            end)
        )
    end
end

function GAG2ShopStartUiLoop()

    if GAG2_SHOP_STATE.UiLoopRunning == true then
        return
    end

    GAG2_SHOP_STATE.UiLoopRunning =
        true

    task.spawn(function()

        local lastBackupScan =
            0

        while GAG2_SHOP_STATE.UiLoopRunning == true do

            GAG2ShopRefreshStockLabel()

            if os.clock() - lastBackupScan >= 45 then

                lastBackupScan =
                    os.clock()

                GAG2ShopRefreshAllDropdowns()
                GAG2ShopEnqueueAllSelectedInStock()
            end

            task.wait(
                1
            )
        end
    end)
end

function GAG2ShopStart()

    if GAG2_SHOP_STATE.Started == true then

        GAG2ShopRefreshStockLabel()

        return
    end

    GAG2_SHOP_STATE.Started =
        true

    task.spawn(function()

        local started =
            os.clock()

        while os.clock() - started < 12 do

            local root =
                GAG2ShopGetStockRoot()

            if root then
                break
            end

            task.wait(
                0.25
            )
        end

        for category in pairs(GAG2_SHOP_CATEGORIES) do

            GAG2ShopTrackCategory(
                category
            )
        end

        GAG2ShopRefreshAllDropdowns()
        GAG2ShopRefreshStockLabel()
        GAG2ShopEnqueueAllSelectedInStock()
        GAG2ShopStartUiLoop()
    end)
end

function GAG2ShopSetSelected(category, value)

    GAG2_SHOP_STATE.Selected[category] =
        GAG2ShopNormalizeSelection(
            value
        )

    GAG2ShopEnqueueSelectedInStock(
        category
    )

    MarkConfigDirty()
end

function GAG2ShopSetEnabled(category, value)

    GAG2_SHOP_STATE.Enabled[category] =
        value == true

    GAG2ShopStart()

    if value == true then

        GAG2ShopClearRestockBuys(
            category
        )

        GAG2ShopEnqueueSelectedInStock(
            category
        )
    end

    MarkConfigDirty()
end

function GAG2RestoreShopAutosaveState()

    task.defer(function()

        for category in pairs(GAG2_SHOP_CATEGORIES) do

            local toggleName =
                "HolyGAG2AutoBuy"
                .. tostring(category)

            local dropdownName =
                "HolyGAG2Shop"
                .. tostring(category)

            if Toggles[toggleName] then

                GAG2_SHOP_STATE.Enabled[category] =
                    Toggles[toggleName].Value == true
            end

            if Options[dropdownName] then

                GAG2_SHOP_STATE.Selected[category] =
                    GAG2ShopNormalizeSelection(
                        Options[dropdownName].Value
                    )
            end
        end

        GAG2ShopStart()

        task.wait(
            0.5
        )

        GAG2ShopEnqueueAllSelectedInStock()
    end)
end

local function SniperFindWildBuyPacket()

    if SniperState.BuyPacket then

        local ok, fireFunction =
            pcall(function()

                return SniperState.BuyPacket.Fire
            end)

        if ok == true
        and type(fireFunction) == "function" then
            return SniperState.BuyPacket
        end
    end

    local packets =
        SniperFindPacketTable()

    if not packets then

        SniperState.BuyPacket =
            nil

        SniperState.BuyPacketSource =
            tostring(SniperState.PacketSource)

        return nil
    end

    local results =
        {}

    SniperSearchWildPackets(
        packets,
        {},
        0,
        "Packets",
        results
    )

    table.sort(results, function(a, b)

        return tonumber(a.Score or 0)
            > tonumber(b.Score or 0)
    end)

    if #results <= 0 then

        SniperState.BuyPacket =
            nil

        SniperState.BuyPacketSource =
            "wild pet packet not found"

        return nil
    end

    local best =
        results[1]

    SniperState.BuyPacket =
        best.Packet

    SniperState.BuyPacketSource =
        tostring(best.Name)
        .. " @ "
        .. tostring(best.Path)
        .. " | "
        .. tostring(SniperState.PacketSource)

    return SniperState.BuyPacket
end

local function SniperGetCharacterRoot()

    local character =
        LOCAL_PLAYER
        and LOCAL_PLAYER.Character

    local root =
        character
        and character:FindFirstChild("HumanoidRootPart")

    if not character
    or not root
    or root:IsA("BasePart") ~= true then
        return nil, nil
    end

    return character, root
end

function GAG2GuiObjectVisible(instance)

    if typeof(instance) ~= "Instance" then
        return false
    end

    local current =
        instance

    while current
    and current ~= game do

        if current:IsA("ScreenGui") then

            local enabled =
                true

            local ok =
                pcall(function()

                    enabled =
                        current.Enabled == true
                end)

            if ok == true
            and enabled ~= true then
                return false
            end
        end

        if current:IsA("GuiObject") then

            local visible =
                true

            local ok =
                pcall(function()

                    visible =
                        current.Visible == true
                end)

            if ok == true
            and visible ~= true then
                return false
            end
        end

        current =
            current.Parent
    end

    return true
end

local function GAG2FindVisibleTextObjectByKeywords(keywords, maxScan)

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if not playerGui then
        return nil, "", ""
    end

    local scanned =
        0

    for _, descendant in ipairs(playerGui:GetDescendants()) do

        scanned += 1

        if scanned > (
            tonumber(maxScan)
            or 9000
        ) then
            break
        end

        if descendant:IsA("TextLabel")
        or descendant:IsA("TextButton")
        or descendant:IsA("TextBox") then

            local ok, rawText =
                pcall(function()

                    return descendant.Text
                end)

            local text =
                ok == true
                and CleanText(rawText)
                or ""

            local lowerText =
                text:lower()

            if text ~= ""
            and GAG2GuiObjectVisible(descendant) == true then

                for _, keyword in ipairs(keywords or {}) do

                    local lowerKeyword =
                        tostring(keyword or ""):lower()

                    if lowerKeyword ~= ""
                    and lowerText:find(lowerKeyword, 1, true) then

                        return descendant,
                            text,
                            lowerText
                    end
                end
            end
        end
    end

    return nil, "", ""
end

local function GAG2IsFullyLoadedTextVisible()

    local object, text =
        GAG2FindVisibleTextObjectByKeywords(
            {
                "fully loaded",
            },
            9000
        )

    return object ~= nil,
        text,
        object
end

function GAG2GetPlayScreenTextObject()

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if not playerGui then
        return nil, ""
    end

    local bestObject =
        nil

    local bestText =
        ""

    local scanned =
        0

    for _, descendant in ipairs(playerGui:GetDescendants()) do

        scanned += 1

        if scanned > 12000 then
            break
        end

        if descendant:IsA("TextLabel")
        or descendant:IsA("TextButton")
        or descendant:IsA("TextBox") then

            local ok, rawText =
                pcall(function()

                    return descendant.Text
                end)

            local textValue =
                ok == true
                and CleanText(
                    tostring(rawText or "")
                        :gsub("<[^>]->", "")
                        :gsub("<.->", "")
                )
                or ""

            local lowerText =
                textValue:lower()

            if textValue ~= "" then

                local isLoadingText =
                    lowerText:find("press any key", 1, true)
                    or lowerText:find("key to play", 1, true)
                    or lowerText:find("click to skip", 1, true)
                    or lowerText:find("click to skip!", 1, true)
                    or lowerText:find("fully loaded", 1, true)
                    or lowerText:find("loading player data", 1, true)
                    or (
                        lowerText:find("press", 1, true)
                        and lowerText:find("play", 1, true)
                    )

                if isLoadingText then

                    bestObject =
                        descendant

                    bestText =
                        textValue

                    if GAG2GuiObjectVisible(descendant) == true then

                        return descendant,
                            textValue
                    end
                end
            end
        end
    end

    return bestObject,
        bestText
end

function GAG2IsPlayScreenBlocking()

    local object, text =
        GAG2GetPlayScreenTextObject()

    if object then
        return true, text, object
    end

    return false, "", nil
end

function GAG2GetPlayScreenClickPoint(object)

    local camera =
        workspace.CurrentCamera

    local viewport =
        camera
        and camera.ViewportSize
        or Vector2.new(
            1280,
            720
        )

    local x =
        math.floor(viewport.X / 2)

    local y =
        math.floor(viewport.Y / 2)

    if typeof(object) == "Instance"
    and object:IsA("GuiObject") then

        local ok =
            pcall(function()

                local position =
                    object.AbsolutePosition

                local size =
                    object.AbsoluteSize

                if typeof(position) == "Vector2"
                and typeof(size) == "Vector2"
                and size.X > 0
                and size.Y > 0 then

                    x =
                        math.floor(
                            position.X + (size.X / 2)
                        )

                    y =
                        math.floor(
                            position.Y + (size.Y / 2)
                        )
                end
            end)

        if ok ~= true then

            x =
                math.floor(viewport.X / 2)

            y =
                math.floor(viewport.Y * 0.70)
        end
    end

    return x,
        y
end

function GAG2PressPlayScreen()

    -- Disabled on purpose.
    -- Physical key/mouse input is unsafe during GAG2 loading because it can hit
    -- normal UI after the overlay changes.

    if type(GAG2FireFinishLoadingRemoteSafe) == "function" then

        return GAG2FireFinishLoadingRemoteSafe()
    end

    return false
end

function GAG2GetLoadingGui()

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if not playerGui then
        return nil
    end

    return playerGui:FindFirstChild("LoadingGui")
end

function GAG2ReadLoadingAttributes()

    -- Loading-screen logic removed.
    -- Never block sniper/shop/farm systems based on loading attributes.

    return false,
        true
end

function GAG2IsLoadingPlayScreenVisible()

    -- Loading-screen logic removed.
    -- Do not scan PlayerGui and do not block sniper buying.

    return false
end

local function GAG2GetClickableGuiAncestor(object)

    local current =
        object

    while typeof(current) == "Instance"
    and current ~= game do

        if current:IsA("TextButton")
        or current:IsA("ImageButton") then

            return current
        end

        current =
            current.Parent
    end

    return nil
end

local function GAG2ActivateLoadingGuiObject(object)

    local button =
        GAG2GetClickableGuiAncestor(
            object
        )

    if not button then
        return false
    end

    local activated =
        false

    pcall(function()

        button:Activate()

        activated =
            true
    end)

    if type(firesignal) == "function" then

        pcall(function()

            firesignal(
                button.MouseButton1Click
            )

            activated =
                true
        end)

        pcall(function()

            firesignal(
                button.Activated
            )

            activated =
                true
        end)
    end

    return activated
end

function GAG2SendLoadingScreenClick()

    -- Loading-screen automation removed.
    -- Do not send input, do not click UI, do not touch camera.

    return false
end

function GAG2FireFinishLoadingRemoteSafe()

    -- Loading-screen automation removed.
    -- Do not spoof Finish_Loading anymore.

    return false
end

function GAG2RestoreCameraSoft()

    local character =
        LOCAL_PLAYER
        and LOCAL_PLAYER.Character

    if not character then
        return false
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local camera =
        workspace.CurrentCamera

    if not camera
    or not humanoid then
        return false
    end

    pcall(function()

        camera.CameraType =
            Enum.CameraType.Custom

        camera.CameraSubject =
            humanoid
    end)

    return true
end

function GAG2CleanupLoadingGuiVisualOnly()

    -- Loading-screen cleanup removed.
    -- Do not disable LoadingGui because it can desync camera/game state.

    return false
end

function GAG2ForceClearLoadingGui()

    -- Loading-screen cleanup removed.

    return false
end

function GAG2HardFinishLoading(reason)

    -- Loading-screen hard finish removed.
    -- Do not set loading attributes, do not fire remotes, do not disable GUI.

    GAG2_AUTO_PLAY_STATE =
        type(GAG2_AUTO_PLAY_STATE) == "table"
        and GAG2_AUTO_PLAY_STATE
        or {}

    GAG2_AUTO_PLAY_STATE.Finished =
        true

    GAG2_AUTO_PLAY_STATE.HardFinished =
        true

    if type(SniperState) == "table" then

        SniperState.PlayScreenClearAt =
            os.clock()
    end

    return false
end

function GAG2AutoPlayLoadingStep()

    -- Loading-screen automation removed.
    -- This function is kept only so old calls do not error.

    GAG2_AUTO_PLAY_STATE =
        type(GAG2_AUTO_PLAY_STATE) == "table"
        and GAG2_AUTO_PLAY_STATE
        or {}

    GAG2_AUTO_PLAY_STATE.Finished =
        true

    if type(SniperState) == "table" then

        SniperState.PlayScreenClearAt =
            os.clock()
    end

    return true
end

function GAG2ClientReadyForBuy()

    local loadingActive =
        false

    local loadingDone =
        false

    pcall(function()

        loadingActive =
            LOCAL_PLAYER:GetAttribute("LoadingScreenActive") == true

        loadingDone =
            LOCAL_PLAYER:GetAttribute("LoadingScreenDone") == true
    end)

    local camera =
        workspace.CurrentCamera

    local cameraCustom =
        camera
        and camera.CameraType == Enum.CameraType.Custom

    local cameraScriptable =
        camera
        and camera.CameraType == Enum.CameraType.Scriptable

    local loadingCleared =
        loadingActive ~= true
        and (
            loadingDone == true
            or cameraCustom == true
        )

    if loadingCleared ~= true then

        if type(SniperState) == "table" then

            SniperState.PlayScreenClearAt =
                0
        end

        return false,
            "Waiting for loading..."
            .. " active="
            .. tostring(loadingActive)
            .. " done="
            .. tostring(loadingDone)
            .. " camera="
            .. (
                cameraScriptable == true
                and "Scriptable"
                or cameraCustom == true
                and "Custom"
                or "Other"
            )
    end

    if type(SniperState) == "table"
    and tonumber(SniperState.PlayScreenClearAt or 0) <= 0 then

        SniperState.PlayScreenClearAt =
            os.clock()

        return false,
            "Loading done. Settling..."
    end

    local grace =
        tonumber(
            SniperState
            and SniperState.PlayScreenClearGrace
            or 0.35
        )
        or 0.35

    if os.clock() - tonumber(SniperState.PlayScreenClearAt or 0) < grace then

        return false,
            "Loading done. Settling..."
    end

    return true,
        "Ready."
end

function GAG2ReadyForFarmTeleport()

    local character, root =
        SniperGetCharacterRoot()

    if not character
    or not root then

        return false,
            "missing character"
    end

    return true,
        "character ready"
end

function GAG2StartLoadingGuiCleaner()

    -- Loading-screen cleaner removed.
    -- Do not run background loops, camera restores, GUI cleanup, or finish remotes.

    GAG2_LOADING_GUI_CLEANER_RUNNING =
        false

    return false
end

local function SniperReadyToHop()

    if not SniperGetSpawnsFolder()
    or not SniperGetRefFolder() then

        return false,
            "Waiting for pets..."
    end

    return true,
        "Ready."
end

local function SniperReadyToBuy()

    local elapsed =
        os.clock()
        - (
            tonumber(SniperState.StartedAt)
            or os.clock()
        )

    local startupDelay =
        tonumber(SniperState.StartupBuyDelay)
        or 8

    if elapsed < startupDelay then

        return false,
            "Starting..."
    end

    local _, root =
        SniperGetCharacterRoot()

    if not root then

        return false,
            "Waiting for character..."
    end

    if not SniperGetSpawnsFolder()
    or not SniperGetRefFolder() then

        return false,
            "Waiting for pets..."
    end

    return true,
        "Ready."
end

local function SniperGetEntryTamePosition(entry)

    if type(entry) ~= "table" then
        return nil
    end

    local ref =
        entry.Ref

    if typeof(ref) ~= "Instance"
    or ref.Parent == nil then

        local uuid =
            CleanText(entry.UUID)

        if uuid ~= "" then

            ref =
                SniperFindRef(
                    uuid
                )
        end
    end

    local refPosition =
        SniperGetPosition(
            ref
        )

    if typeof(refPosition) == "Vector3" then
        return refPosition
    end

    if typeof(entry.Position) == "Vector3" then
        return entry.Position
    end

    local spawn =
        entry.Spawn

    if typeof(spawn) == "Instance" then

        local spawnPosition =
            SniperGetPosition(
                spawn
            )

        if typeof(spawnPosition) == "Vector3" then
            return spawnPosition
        end
    end

    return SniperGetPosition(
        entry.Instance
    )
end

local function SniperGetSafeTameCFrame(targetPosition)

    if typeof(targetPosition) ~= "Vector3" then
        return nil
    end

    local character, root =
        SniperGetCharacterRoot()

    local ignoreList =
        {}

    if character then
        table.insert(
            ignoreList,
            character
        )
    end

    local rayParams =
        RaycastParams.new()

    rayParams.FilterType =
        Enum.RaycastFilterType.Exclude

    rayParams.FilterDescendantsInstances =
        ignoreList

    rayParams.IgnoreWater =
        true

    local offsets = {
        Vector3.new(5, 0, 0),
        Vector3.new(-5, 0, 0),
        Vector3.new(0, 0, 5),
        Vector3.new(0, 0, -5),
        Vector3.new(7, 0, 7),
        Vector3.new(-7, 0, 7),
        Vector3.new(7, 0, -7),
        Vector3.new(-7, 0, -7),
        Vector3.new(0, 0, 0),
    }

    local bestPosition =
        nil

    for _, offset in ipairs(offsets) do

        local rayOrigin =
            targetPosition
            + offset
            + Vector3.new(
                0,
                60,
                0
            )

        local rayDirection =
            Vector3.new(
                0,
                -140,
                0
            )

        local result =
            workspace:Raycast(
                rayOrigin,
                rayDirection,
                rayParams
            )

        if result
        and result.Position then

            local candidatePosition =
                result.Position
                + Vector3.new(
                    0,
                    4.75,
                    0
                )

            bestPosition =
                candidatePosition

            break
        end
    end

    if typeof(bestPosition) ~= "Vector3" then

        bestPosition =
            targetPosition
            + Vector3.new(
                0,
                7,
                0
            )
    end

    local lookTarget =
        Vector3.new(
            targetPosition.X,
            bestPosition.Y,
            targetPosition.Z
        )

    if (bestPosition - lookTarget).Magnitude < 0.1 then

        lookTarget =
            bestPosition
            + Vector3.new(
                0,
                0,
                -1
            )
    end

    return CFrame.new(
        bestPosition,
        lookTarget
    ),
    bestPosition
end

local function SniperStopCharacterMotion(root)

    if typeof(root) ~= "Instance" then
        return
    end

    pcall(function()

        root.AssemblyLinearVelocity =
            Vector3.zero

        root.AssemblyAngularVelocity =
            Vector3.zero
    end)
end

--==================================================
-- [4.55] AUTO SKIP LOADING + AUTO TP MIDDLE FARM
-- Settings-tab controlled. No GUI scanning. No remote spoofing.
--==================================================

function GAG2FarmStripRichText(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2FarmVecText(position)

    if typeof(position) ~= "Vector3" then
        return "nil"
    end

    return string.format(
        "%.1f, %.1f, %.1f",
        position.X,
        position.Y,
        position.Z
    )
end

function GAG2ResolveOwnFarmPlot()

    local gardens =
        workspace:FindFirstChild("Gardens")

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if not gardens then
        return nil, "workspace.Gardens missing"
    end

    if not playerGui then
        return nil, "PlayerGui missing"
    end

    for _, gui in ipairs(playerGui:GetChildren()) do

        if gui:IsA("BillboardGui")
        and tostring(gui.Name):match("^Plot%d+$") then

            for _, descendant in ipairs(gui:GetDescendants()) do

                if descendant:IsA("TextLabel")
                or descendant:IsA("TextButton") then

                    local text =
                        GAG2FarmStripRichText(
                            descendant.Text
                        ):lower()

                    if text:find("your garden", 1, true) then

                        local plot =
                            gardens:FindFirstChild(
                                gui.Name
                            )

                        if plot then

                            return plot,
                                "billboard "
                                .. tostring(gui.Name)
                        end
                    end
                end
            end
        end
    end

    return nil, "own garden billboard not found"
end

function GAG2IsMiddleFarmPart(part)

    if typeof(part) ~= "Instance"
    or part:IsA("BasePart") ~= true then
        return false
    end

    local path =
        PathOf(part)

    if path:find("GardenZonePart", 1, true) then
        return false
    end

    if path:find(".Plants.", 1, true) then
        return false
    end

    if path:find("PlantAreaColumn", 1, true) then
        return true
    end

    if path:find("PlantArea", 1, true) then
        return true
    end

    if path:find("BedSection", 1, true) then
        return true
    end

    return false
end

function GAG2MiddleFarmGetStandOffset(root, humanoid)

    local rootHalf =
        1.0

    if root
    and root:IsA("BasePart") then

        rootHalf =
            math.max(
                0.75,
                root.Size.Y / 2
            )
    end

    local hipHeight =
        humanoid
        and tonumber(humanoid.HipHeight)
        or 0

    return math.clamp(
        rootHalf + math.max(hipHeight, 0) + 1.15,
        2.35,
        3.10
    )
end

function GAG2GetOwnFarmMiddlePosition()

    local ownPlot, plotReason =
        GAG2ResolveOwnFarmPlot()

    if not ownPlot then
        return nil, plotReason
    end

    local character, root =
        SniperGetCharacterRoot()

    local humanoid =
        character
        and character:FindFirstChildOfClass("Humanoid")

    local standOffset =
        GAG2MiddleFarmGetStandOffset(
            root,
            humanoid
        )

    local points =
        {}

    for _, descendant in ipairs(ownPlot:GetDescendants()) do

        if GAG2IsMiddleFarmPart(descendant) == true then

            table.insert(
                points,
                descendant.Position
            )
        end
    end

    local center =
        nil

    if #points > 0 then

        local total =
            Vector3.zero

        for _, point in ipairs(points) do

            total += point
        end

        center =
            total / #points

    else

        local ok, cf =
            pcall(function()

                return ownPlot:GetBoundingBox()
            end)

        if ok == true
        and typeof(cf) == "CFrame" then

            center =
                cf.Position

        else

            return nil, "farm middle failed"
        end
    end

    local excludeList =
        {}

    if character then

        table.insert(
            excludeList,
            character
        )
    end

    local plants =
        ownPlot:FindFirstChild("Plants")

    if plants then

        table.insert(
            excludeList,
            plants
        )
    end

    local rayParams =
        RaycastParams.new()

    rayParams.FilterType =
        Enum.RaycastFilterType.Exclude

    rayParams.FilterDescendantsInstances =
        excludeList

    rayParams.IgnoreWater =
        true

    local rayResult =
        workspace:Raycast(
            center + Vector3.new(0, 90, 0),
            Vector3.new(0, -220, 0),
            rayParams
        )

    if rayResult
    and rayResult.Position
    and typeof(rayResult.Instance) == "Instance"
    and rayResult.Instance:IsDescendantOf(ownPlot) then

        local hitPath =
            PathOf(rayResult.Instance)

        if not hitPath:find(".Plants.", 1, true)
        and not hitPath:find("GardenZonePart", 1, true) then

            return rayResult.Position
                + Vector3.new(0, standOffset, 0),
                "ground | "
                .. tostring(plotReason)
                .. " | hit "
                .. hitPath
        end
    end

    return center + Vector3.new(0, standOffset, 0),
        "fallback | "
        .. tostring(plotReason)
end

function GAG2MiddleFarmLoadingSnapshot()

    local active =
        false

    local done =
        false

    pcall(function()

        active =
            LOCAL_PLAYER:GetAttribute("LoadingScreenActive") == true

        done =
            LOCAL_PLAYER:GetAttribute("LoadingScreenDone") == true
    end)

    local camera =
        workspace.CurrentCamera

    local cameraType =
        camera
        and tostring(camera.CameraType)
        or "nil"

    local cameraScriptable =
        camera
        and camera.CameraType == Enum.CameraType.Scriptable

    local cameraCustom =
        camera
        and camera.CameraType == Enum.CameraType.Custom

    return {
        Active = active,
        Done = done,
        CameraType = cameraType,
        CameraScriptable = cameraScriptable,
        CameraCustom = cameraCustom,
    }
end

function GAG2AutoSkipLoadingEnabled()

    if Toggles.HolyGAG2AutoSkipLoading then

        return Toggles.HolyGAG2AutoSkipLoading.Value == true
    end

    -- Default ON before SaveManager/controls fully settle.
    return true
end

function GAG2AutoTpMiddleFarmEnabled()

    return Toggles.HolyGAG2AutoTpMiddleFarm
        and Toggles.HolyGAG2AutoTpMiddleFarm.Value == true
end

function GAG2MiddleFarmWorkerShouldContinue(forceTp)

    if forceTp == true then
        return true
    end

    return GAG2AutoSkipLoadingEnabled() == true
        or GAG2AutoTpMiddleFarmEnabled() == true
end

function GAG2MiddleFarmPivotTo(position)

    local character, root =
        SniperGetCharacterRoot()

    if not character
    or not root then
        return false, "missing character/root"
    end

    if typeof(position) ~= "Vector3" then
        return false, "bad target"
    end

    local lookVector =
        root.CFrame.LookVector

    if typeof(lookVector) ~= "Vector3"
    or lookVector.Magnitude <= 0 then

        lookVector =
            Vector3.new(0, 0, -1)
    end

    local targetCFrame =
        CFrame.new(
            position,
            position + lookVector
        )

    local ok, err =
        pcall(function()

            character:PivotTo(
                targetCFrame
            )
        end)

    if ok ~= true then

        ok, err =
            pcall(function()

                root.CFrame =
                    targetCFrame
            end)
    end

    if ok ~= true then
        return false, tostring(err)
    end

    SniperStopCharacterMotion(
        root
    )

    return true, "teleported"
end

function GAG2MiddleFarmGetHoldPoint()

    local camera =
        workspace.CurrentCamera

    local viewport =
        camera
        and camera.ViewportSize
        or Vector2.new(1280, 720)

    local x =
        math.floor(viewport.X * 0.52)

    local y =
        math.floor(viewport.Y * 0.58)

    return x,
        y,
        viewport
end

function GAG2MiddleFarmReleaseSkipHold(reason)

    local state =
        GAG2_AUTO_TP_MIDDLE_FARM_STATE

    if state.HoldingSkip ~= true then
        return
    end

    state.HoldingSkip =
        false

    if VirtualInputManager then

        pcall(function()

            VirtualInputManager:SendMouseButtonEvent(
                tonumber(state.HoldX) or 0,
                tonumber(state.HoldY) or 0,
                0,
                false,
                game,
                1
            )
        end)
    end

    print(
        "[HOLY GAG2 LOADING]",
        "mouse released",
        "| reason:",
        tostring(reason),
        "| held:",
        string.format(
            "%.2fs",
            os.clock() - tonumber(state.HoldStartAt or os.clock())
        )
    )
end

function GAG2MiddleFarmPressSkipHold()

    local state =
        GAG2_AUTO_TP_MIDDLE_FARM_STATE

    if not VirtualInputManager then

        state.LastResult =
            "VirtualInputManager missing"

        return false,
            "VirtualInputManager missing"
    end

    if state.HoldingSkip == true then

        return true,
            "already holding"
    end

    local x, y, viewport =
        GAG2MiddleFarmGetHoldPoint()

    local ok, err =
        pcall(function()

            VirtualInputManager:SendMouseButtonEvent(
                x,
                y,
                0,
                true,
                game,
                1
            )
        end)

    if ok ~= true then

        return false,
            tostring(err)
    end

    state.HoldingSkip =
        true

    state.HoldStartAt =
        os.clock()

    state.HoldX =
        x

    state.HoldY =
        y

    return true,
        "mouse down at "
        .. tostring(x)
        .. ","
        .. tostring(y)
        .. " viewport "
        .. tostring(math.floor(viewport.X))
        .. "x"
        .. tostring(math.floor(viewport.Y))
end

function GAG2TeleportToMiddleFarmOnce(reason)

    local started =
        os.clock()

    local position =
        nil

    local positionReason =
        "not resolved"

    while os.clock() - started < 12 do

        local character, root =
            SniperGetCharacterRoot()

        local resolvedPosition, resolvedReason =
            GAG2GetOwnFarmMiddlePosition()

        if character
        and root
        and typeof(resolvedPosition) == "Vector3" then

            position =
                resolvedPosition

            positionReason =
                tostring(resolvedReason)

            break
        end

        positionReason =
            tostring(resolvedReason)

        task.wait(
            0.08
        )
    end

    if typeof(position) ~= "Vector3" then

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastResult =
            tostring(positionReason)

        return false,
            tostring(positionReason)
    end

    local ok, err =
        GAG2MiddleFarmPivotTo(
            position
        )

    if ok ~= true then

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastResult =
            "tp failed: "
            .. tostring(err)

        return false,
            tostring(err)
    end

    GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastTeleportAt =
        os.clock()

    GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastTarget =
        position

    GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastTargetReason =
        positionReason

    GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastResult =
        "teleported: "
        .. tostring(positionReason)

    print(
        "[HOLY GAG2]",
        "TP Middle Farm",
        "| reason:",
        tostring(reason or "manual"),
        "| target:",
        GAG2FarmVecText(position),
        "|",
        tostring(positionReason)
    )

    return true,
        positionReason
end

function GAG2StartMiddleFarmLoadingWorker(reason, forceTp)

    local state =
        GAG2_AUTO_TP_MIDDLE_FARM_STATE

    if state.Running == true then
        return false
    end

    if GAG2MiddleFarmWorkerShouldContinue(forceTp) ~= true then
        return false
    end

    state.Running =
        true

    task.spawn(function()

        local started =
            os.clock()

        local targetPosition =
            nil

        local targetReason =
            "not resolved"

        local lastTargetRefresh =
            0

        local didEarlyTeleport =
            false

        local didPostLoadRepair =
            false

        local postLoadSeenAt =
            nil

        state.SkipStarted =
            false

        state.SkipSucceeded =
            false

        state.SkipAttempts =
            0

        state.SkipSuccessReason =
            ""

        state.HoldingSkip =
            false

        state.HoldStartAt =
            0

        state.HoldMaxSeconds =
            0

        state.LastResult =
            "worker started"

        print(
            "[HOLY GAG2 LOADING]",
            "worker started",
            "| reason:",
            tostring(reason or "auto"),
            "| forceTp:",
            tostring(forceTp == true),
            "| autoSkip:",
            tostring(GAG2AutoSkipLoadingEnabled()),
            "| autoTp:",
            tostring(GAG2AutoTpMiddleFarmEnabled())
        )

        local function resolveTargetStep()

            if forceTp ~= true
            and GAG2AutoTpMiddleFarmEnabled() ~= true then
                return
            end

            local now =
                os.clock()

            if typeof(targetPosition) == "Vector3"
            and now - lastTargetRefresh < 0.35 then
                return
            end

            lastTargetRefresh =
                now

            local resolvedPosition, resolvedReason =
                GAG2GetOwnFarmMiddlePosition()

            if typeof(resolvedPosition) == "Vector3" then

                if typeof(targetPosition) ~= "Vector3" then

                    print(
                        "[HOLY GAG2 MIDDLE]",
                        "target resolved:",
                        GAG2FarmVecText(resolvedPosition),
                        "|",
                        tostring(resolvedReason)
                    )
                end

                targetPosition =
                    resolvedPosition

                targetReason =
                    tostring(resolvedReason)

                state.LastTarget =
                    targetPosition

                state.LastTargetReason =
                    targetReason

            else

                targetReason =
                    tostring(resolvedReason)

                state.LastTargetReason =
                    targetReason
            end
        end

        local function earlyTpStep()

            if didEarlyTeleport == true then
                return
            end

            if forceTp ~= true
            and GAG2AutoTpMiddleFarmEnabled() ~= true then
                return
            end

            local _, root =
                SniperGetCharacterRoot()

            if not root
            or typeof(targetPosition) ~= "Vector3" then
                return
            end

            local distance =
                (root.Position - targetPosition).Magnitude

            local before =
                root.Position

            local ok, err =
                GAG2MiddleFarmPivotTo(
                    targetPosition
                )

            local _, newRoot =
                SniperGetCharacterRoot()

            if ok == true then

                didEarlyTeleport =
                    true

                state.LastTeleportAt =
                    os.clock()

                state.LastResult =
                    "early tp done"

                print(
                    "[HOLY GAG2 MIDDLE]",
                    "early tp",
                    "| distance:",
                    tostring(math.floor(distance + 0.5)),
                    "| from:",
                    GAG2FarmVecText(before),
                    "| to:",
                    newRoot and GAG2FarmVecText(newRoot.Position) or "nil",
                    "| target:",
                    GAG2FarmVecText(targetPosition)
                )

            else

                state.LastResult =
                    "early tp failed: "
                    .. tostring(err)

                print(
                    "[HOLY GAG2 MIDDLE]",
                    "early tp failed:",
                    tostring(err)
                )
            end
        end

        local function postLoadRepairStep(stepReason)

            if didPostLoadRepair == true then
                return
            end

            if forceTp ~= true
            and GAG2AutoTpMiddleFarmEnabled() ~= true then
                return
            end

            local snap =
                GAG2MiddleFarmLoadingSnapshot()

            if postLoadSeenAt == nil
            and snap.Active ~= true
            and (
                snap.Done == true
                or snap.CameraCustom == true
            ) then

                postLoadSeenAt =
                    os.clock()

                print(
                    "[HOLY GAG2 MIDDLE]",
                    "post-load detected",
                    "| active:",
                    tostring(snap.Active),
                    "| done:",
                    tostring(snap.Done),
                    "| camera:",
                    snap.CameraType
                )
            end

            if not postLoadSeenAt then
                return
            end

            local _, root =
                SniperGetCharacterRoot()

            if not root
            or typeof(targetPosition) ~= "Vector3" then
                return
            end

            local distance =
                (root.Position - targetPosition).Magnitude

            if distance < tonumber(state.PostLoadRepairDistance or 25) then

                didPostLoadRepair =
                    true

                state.LastResult =
                    "post-load near target"

                print(
                    "[HOLY GAG2 MIDDLE]",
                    "post-load near target, no repair needed",
                    "| distance:",
                    tostring(math.floor(distance + 0.5)),
                    "| reason:",
                    tostring(stepReason or "normal")
                )

                return
            end

            local before =
                root.Position

            local ok, err =
                GAG2MiddleFarmPivotTo(
                    targetPosition
                )

            local _, newRoot =
                SniperGetCharacterRoot()

            if ok == true then

                didPostLoadRepair =
                    true

                state.LastTeleportAt =
                    os.clock()

                state.LastResult =
                    "post-load repair done"

                print(
                    "[HOLY GAG2 MIDDLE]",
                    "POST-LOAD REPAIR TP",
                    "| distance:",
                    tostring(math.floor(distance + 0.5)),
                    "| from:",
                    GAG2FarmVecText(before),
                    "| to:",
                    newRoot and GAG2FarmVecText(newRoot.Position) or "nil",
                    "| reason:",
                    tostring(stepReason or "normal"),
                    "| target:",
                    GAG2FarmVecText(targetPosition)
                )

            else

                state.LastResult =
                    "post-load repair failed: "
                    .. tostring(err)

                print(
                    "[HOLY GAG2 MIDDLE]",
                    "post-load repair failed:",
                    tostring(err)
                )
            end
        end

        local function detectSkipSuccessStep()

            if state.SkipSucceeded == true then
                return
            end

            local snap =
                GAG2MiddleFarmLoadingSnapshot()

            if snap.Active ~= true
            and (
                snap.Done == true
                or snap.CameraCustom == true
            ) then

                state.SkipSucceeded =
                    true

                state.SkipSuccessReason =
                    "loading cleared during monitored hold"

                GAG2MiddleFarmReleaseSkipHold(
                    "skip success"
                )

                state.LastResult =
                    "skip success"

                print(
                    "[HOLY GAG2 LOADING]",
                    "SKIP SUCCESS",
                    "| attempts:",
                    tostring(state.SkipAttempts),
                    "| reason:",
                    state.SkipSuccessReason,
                    "| state:",
                    "active="
                    .. tostring(snap.Active)
                    .. " done="
                    .. tostring(snap.Done)
                    .. " camera="
                    .. tostring(snap.CameraType)
                )

                resolveTargetStep()

                postLoadRepairStep(
                    "same tick after skip success"
                )
            end
        end

        local function skipStep()

            if GAG2AutoSkipLoadingEnabled() ~= true then
                return
            end

            if state.SkipSucceeded == true then
                return
            end

            local snap =
                GAG2MiddleFarmLoadingSnapshot()

            if snap.Active ~= true
            or snap.Done == true
            or snap.CameraScriptable ~= true then
                return
            end

            if state.SkipAttempts >= 2 then
                return
            end

            if state.HoldingSkip ~= true then

                state.SkipStarted =
                    true

                state.SkipAttempts += 1

                state.HoldMaxSeconds =
                    state.SkipAttempts == 1
                    and 3.60
                    or 4.20

                local ok, method =
                    GAG2MiddleFarmPressSkipHold()

                print(
                    "[HOLY GAG2 LOADING]",
                    "skip hold started",
                    "| attempt:",
                    tostring(state.SkipAttempts),
                    "| maxHold:",
                    tostring(state.HoldMaxSeconds),
                    "| method:",
                    tostring(method),
                    "| active:",
                    tostring(snap.Active),
                    "| done:",
                    tostring(snap.Done),
                    "| camera:",
                    snap.CameraType
                )

                if ok ~= true then

                    state.LastResult =
                        "skip hold failed: "
                        .. tostring(method)
                end

                return
            end

            local heldFor =
                os.clock() - tonumber(state.HoldStartAt or os.clock())

            if heldFor >= tonumber(state.HoldMaxSeconds or 3.60) then

                GAG2MiddleFarmReleaseSkipHold(
                    "max hold reached"
                )

                print(
                    "[HOLY GAG2 LOADING]",
                    "skip not confirmed after hold",
                    "| attempt:",
                    tostring(state.SkipAttempts)
                )
            end
        end

        while os.clock() - started < tonumber(state.MaxRunSeconds or 18) do

            if GAG2MiddleFarmWorkerShouldContinue(forceTp) ~= true then

                GAG2MiddleFarmReleaseSkipHold(
                    "disabled"
                )

                state.LastResult =
                    "stopped: disabled"

                state.Running =
                    false

                return
            end

            resolveTargetStep()
            earlyTpStep()

            detectSkipSuccessStep()
            postLoadRepairStep("normal loop")
            skipStep()

            local autoTpNeeded =
                forceTp == true
                or GAG2AutoTpMiddleFarmEnabled() == true

            local autoSkipNeeded =
                GAG2AutoSkipLoadingEnabled() == true

            local skipDone =
                autoSkipNeeded ~= true
                or state.SkipSucceeded == true
                or state.SkipAttempts >= 2
                or GAG2MiddleFarmLoadingSnapshot().Done == true

            local tpDone =
                autoTpNeeded ~= true
                or (
                    didEarlyTeleport == true
                    and didPostLoadRepair == true
                )

            if skipDone == true
            and tpDone == true then

                GAG2MiddleFarmReleaseSkipHold(
                    "done"
                )

                state.LastResult =
                    "done"

                print(
                    "[HOLY GAG2 LOADING]",
                    "worker finished",
                    "| skip:",
                    tostring(state.SkipSucceeded),
                    "| attempts:",
                    tostring(state.SkipAttempts),
                    "| earlyTp:",
                    tostring(didEarlyTeleport),
                    "| repair:",
                    tostring(didPostLoadRepair)
                )

                state.Running =
                    false

                return
            end

            task.wait(
                0.02
            )
        end

        GAG2MiddleFarmReleaseSkipHold(
            "timeout"
        )

        state.LastResult =
            "timeout"

        print(
            "[HOLY GAG2 LOADING]",
            "worker timeout",
            "| skip:",
            tostring(state.SkipSucceeded),
            "| attempts:",
            tostring(state.SkipAttempts),
            "| target:",
            GAG2FarmVecText(targetPosition),
            "| reason:",
            tostring(targetReason)
        )

        state.Running =
            false
    end)

    return true
end

function GAG2StartAutoTpMiddleFarm(reason)

    return GAG2StartMiddleFarmLoadingWorker(
        reason or "auto tp",
        true
    )
end

function GAG2StartAutoSkipLoading(reason)

    return GAG2StartMiddleFarmLoadingWorker(
        reason or "auto skip",
        false
    )
end

function GAG2SetAutoTpMiddleFarmEnabled(value)

    if ConfigState.Loading == true then
        return
    end

    local enabled =
        value == true

    if enabled == true then

        if type(GAG2StartAutoTpMiddleFarm) == "function" then

            GAG2StartAutoTpMiddleFarm(
                "toggle"
            )
        end
    end

    if enabled ~= true
    and type(GAG2AutoSkipLoadingEnabled) == "function"
    and GAG2AutoSkipLoadingEnabled() ~= true then

        if type(GAG2MiddleFarmReleaseSkipHold) == "function" then

            GAG2MiddleFarmReleaseSkipHold(
                "auto tp off"
            )
        end
    end

    MarkConfigDirty()

    task.defer(function()

        if ConfigState.Loading == true then
            return
        end

        if SaveManager
        and type(SaveManager.Save) == "function" then

            pcall(function()

                SaveManager:Save(
                    ConfigState.AutosaveName
                )
            end)
        end
    end)
end

function GAG2SetAutoSkipLoadingEnabled(value)

    if ConfigState.Loading == true then
        return
    end

    local enabled =
        value == true

    if enabled == true then

        if type(GAG2StartAutoSkipLoading) == "function" then

            GAG2StartAutoSkipLoading(
                "toggle"
            )
        end

    elseif type(GAG2AutoTpMiddleFarmEnabled) == "function"
    and GAG2AutoTpMiddleFarmEnabled() ~= true then

        if type(GAG2MiddleFarmReleaseSkipHold) == "function" then

            GAG2MiddleFarmReleaseSkipHold(
                "auto skip off"
            )
        end
    end

    MarkConfigDirty()
end

function GAG2RestoreAutoTpMiddleFarmState()

    if GAG2_AUTO_TP_MIDDLE_FARM_STATE.CharacterConnection == nil then

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.CharacterConnection =
            LOCAL_PLAYER.CharacterAdded:Connect(function()

                task.wait(
                    0.15
                )

                if GAG2AutoSkipLoadingEnabled() == true
                or GAG2AutoTpMiddleFarmEnabled() == true then

                    GAG2StartMiddleFarmLoadingWorker(
                        "respawn",
                        false
                    )
                end
            end)
    end

    task.defer(function()

        if GAG2AutoSkipLoadingEnabled() == true
        or GAG2AutoTpMiddleFarmEnabled() == true then

            GAG2StartMiddleFarmLoadingWorker(
                "autosave",
                false
            )
        end
    end)
end

--==================================================
-- [4.555] PERFORMANCE / HIDE OTHER GARDENS
-- Client-side render reduction. Never hides own garden.
--==================================================

GAG2_PERFORMANCE_STATE =
    GAG2_PERFORMANCE_STATE
    or {
        HideOtherGardens = false,
        HiddenGardens = {},
        Connections = {},
        LastStatus = "Idle.",
    }

function GAG2PerformanceSetStatus(text)

    local state =
        GAG2_PERFORMANCE_STATE

    state.LastStatus =
        tostring(text or "Idle.")

    print(
        "[HOLY GAG2 PERFORMANCE]",
        state.LastStatus
    )
end

function GAG2PerformanceGetGardensRoot()

    return workspace:FindFirstChild(
        "Gardens"
    )
end

function GAG2PerformanceIsGardenPlot(instance)

    if typeof(instance) ~= "Instance" then
        return false
    end

    if instance:IsA("Model") ~= true
    and instance:IsA("Folder") ~= true then
        return false
    end

    if tostring(instance.Name):match("^Plot%d+$") then
        return true
    end

    return false
end

function GAG2PerformanceResolveOwnGarden()

    if type(GAG2ResolveOwnFarmPlot) == "function" then

        local ok, plot, reason =
            pcall(
                GAG2ResolveOwnFarmPlot
            )

        if ok == true
        and typeof(plot) == "Instance" then

            return plot,
                tostring(reason or "resolved")
        end

        return nil,
            tostring(plot or reason or "own garden unresolved")
    end

    return nil,
        "GAG2ResolveOwnFarmPlot missing"
end

function GAG2PerformanceRestoreHiddenGardens(reason)

    local state =
        GAG2_PERFORMANCE_STATE

    local restored =
        0

    for garden, originalParent in pairs(state.HiddenGardens) do

        if typeof(garden) == "Instance"
        and garden.Parent == nil
        and typeof(originalParent) == "Instance" then

            local ok =
                pcall(function()

                    garden.Parent =
                        originalParent
                end)

            if ok == true then
                restored += 1
            end
        end

        state.HiddenGardens[garden] =
            nil
    end

    GAG2PerformanceSetStatus(
        "Restored "
        .. tostring(restored)
        .. " hidden garden(s)."
        .. (
            reason
            and " Reason: " .. tostring(reason)
            or ""
        )
    )

    return restored
end

function GAG2PerformanceHideGarden(garden, ownGarden, gardensRoot)

    local state =
        GAG2_PERFORMANCE_STATE

    if typeof(garden) ~= "Instance" then
        return false
    end

    if typeof(gardensRoot) ~= "Instance" then
        return false
    end

    if GAG2PerformanceIsGardenPlot(garden) ~= true then
        return false
    end

    if typeof(ownGarden) == "Instance" then

        if garden == ownGarden then
            return false
        end

        if tostring(garden.Name) == tostring(ownGarden.Name) then
            return false
        end
    end

    if state.HiddenGardens[garden] ~= nil then
        return false
    end

    state.HiddenGardens[garden] =
        garden.Parent

    local ok =
        pcall(function()

            garden.Parent =
                nil
        end)

    if ok ~= true then

        state.HiddenGardens[garden] =
            nil

        return false
    end

    return true
end

function GAG2PerformanceApplyHideOtherGardens(reason)

    local state =
        GAG2_PERFORMANCE_STATE

    local gardensRoot =
        GAG2PerformanceGetGardensRoot()

    if not gardensRoot then

        GAG2PerformanceSetStatus(
            "Workspace.Gardens missing."
        )

        return false
    end

    local ownGarden, ownReason =
        GAG2PerformanceResolveOwnGarden()

    if not ownGarden then

        GAG2PerformanceSetStatus(
            "Cannot hide gardens yet: "
            .. tostring(ownReason)
        )

        return false
    end

    local hidden =
        0

    for _, garden in ipairs(gardensRoot:GetChildren()) do

        if GAG2PerformanceHideGarden(
            garden,
            ownGarden,
            gardensRoot
        ) == true then

            hidden += 1
        end
    end

    if state.Connections.GardensChildAdded == nil then

        state.Connections.GardensChildAdded =
            gardensRoot.ChildAdded:Connect(function(child)

                if GAG2_PERFORMANCE_STATE.HideOtherGardens ~= true then
                    return
                end

                task.wait(
                    0.25
                )

                GAG2PerformanceApplyHideOtherGardens(
                    "garden added"
                )
            end)
    end

    GAG2PerformanceSetStatus(
        "Hide Other Gardens ON. Hidden: "
        .. tostring(hidden)
        .. " | Own: "
        .. tostring(ownGarden.Name)
        .. (
            reason
            and " | " .. tostring(reason)
            or ""
        )
    )

    return true
end

function GAG2PerformanceSetHideOtherGardensEnabled(value)

    local state =
        GAG2_PERFORMANCE_STATE

    state.HideOtherGardens =
        value == true

    if state.HideOtherGardens == true then

        GAG2PerformanceApplyHideOtherGardens(
            "toggle"
        )

    else

        GAG2PerformanceRestoreHiddenGardens(
            "toggle off"
        )
    end

    MarkConfigDirty()
end

function GAG2RestorePerformanceState()

    task.defer(function()

        if Toggles.HolyGAG2HideOtherGardens then

            GAG2_PERFORMANCE_STATE.HideOtherGardens =
                Toggles.HolyGAG2HideOtherGardens.Value == true
        end

        if GAG2_PERFORMANCE_STATE.HideOtherGardens == true then

            task.wait(
                0.75
            )

            GAG2PerformanceApplyHideOtherGardens(
                "autosave"
            )
        end
    end)
end

--==================================================
-- [4.559] ANTI AFK
-- Silent Roblox idle-signal responder. No loops. No remotes. No console output.
--==================================================

if type(GAG2_ANTI_AFK_STATE) == "table"
and GAG2_ANTI_AFK_STATE.Connection then

    pcall(function()

        GAG2_ANTI_AFK_STATE.Connection:Disconnect()
    end)
end

GAG2_ANTI_AFK_STATE = {
    Enabled = true,
    Connection = nil,
    LastActionAt = 0,
    LastIdleSeconds = 0,
    LastError = "",
}

function GAG2AntiAfkDisconnect()

    local state =
        GAG2_ANTI_AFK_STATE

    if state.Connection then

        pcall(function()

            state.Connection:Disconnect()
        end)
    end

    state.Connection =
        nil
end

function GAG2AntiAfkPulse(idleSeconds)

    local state =
        GAG2_ANTI_AFK_STATE

    if state.Enabled ~= true then
        return
    end

    if VirtualUser == nil then

        state.LastError =
            "VirtualUser missing"

        return
    end

    local now =
        os.clock()

    if now - tonumber(state.LastActionAt or 0) < 10 then
        return
    end

    state.LastActionAt =
        now

    state.LastIdleSeconds =
        tonumber(idleSeconds)
        or 0

    local ok, err =
        pcall(function()

            VirtualUser:CaptureController()

            VirtualUser:ClickButton2(
                Vector2.new(
                    0,
                    0
                )
            )
        end)

    if ok == true then

        state.LastError =
            ""

    else

        state.LastError =
            tostring(err)
    end
end

function GAG2AntiAfkConnect()

    local state =
        GAG2_ANTI_AFK_STATE

    if state.Connection then
        return
    end

    if not LOCAL_PLAYER
    or not LOCAL_PLAYER.Idled then

        state.LastError =
            "LocalPlayer.Idled missing"

        return
    end

    local ok, connection =
        pcall(function()

            return LOCAL_PLAYER.Idled:Connect(function(idleSeconds)

                GAG2AntiAfkPulse(
                    idleSeconds
                )
            end)
        end)

    if ok == true
    and connection then

        state.Connection =
            connection

        state.LastError =
            ""

    else

        state.LastError =
            tostring(connection)
    end
end

function GAG2AntiAfkSetEnabled(value, skipDirty)

    local state =
        GAG2_ANTI_AFK_STATE

    state.Enabled =
        value == true

    if state.Enabled == true then

        GAG2AntiAfkConnect()

    else

        GAG2AntiAfkDisconnect()
    end

    if skipDirty ~= true then

        MarkConfigDirty()
    end
end

function GAG2RestoreAntiAfkState()

    task.defer(function()

        local enabled =
            true

        if Toggles.HolyGAG2AntiAfk then

            enabled =
                Toggles.HolyGAG2AntiAfk.Value ~= false
        end

        GAG2AntiAfkSetEnabled(
            enabled,
            true
        )
    end)
end

--==================================================
-- [4.56] AUTO COLLECT FRUITS
-- Priority harvest queue using ready HarvestPrompt fruits.
-- V1 note: Size/Weight uses SizeMulti because exact pre-harvest KG is not stored.
--==================================================

GAG2_AUTO_COLLECT_FRUIT_STATE =
    GAG2_AUTO_COLLECT_FRUIT_STATE
    or {
        Enabled = false,
        Running = false,

        StopIfFull = true,
        Delay = 0,
        BurstAmount = 8,
        CollectionSpeed = "Normal",

        PauseDuringWeather = false,
        PauseWeatherMode = "Any Weather",
        PauseWeathers = {
            Rain = true,
            Lightning = true,
            Rainbow = true,
            Snowfall = true,
            Starfall = true,
        },
        ActiveWeather = "Day",
        ActivePhase = "Day",
        WeatherWatcherStarted = false,
        WeatherConnections = {},

        CollectMode = "All",

        SelectedFruits = {},
        SelectedRarities = {},
        SelectedMutations = {},

        ExcludeFruits = {},
        ExcludeRarities = {},
        ExcludeMutations = {},

        ExcludeSizeMode = "Off",
        ExcludeSizeThreshold = 0,

        Priority1 = "Rarity",
        Priority2 = "Weight",
        Priority3 = "Mutation",

        Recent = {},
        Modules = {},
        SeedMap = {},
        FruitNames = {},
        RarityNames = {},
        MutationNames = {},

        LastStatus = "Idle.",
        LastReadyCount = 0,
        LastMatchingCount = 0,
        LastExcludedCount = 0,
        LastFiredCount = 0,
        LastNextText = "None",
        LastRefreshAt = 0,
    }

GAG2_AUTO_COLLECT_FRUIT_CONTROLS =
    GAG2_AUTO_COLLECT_FRUIT_CONTROLS
    or {}

GAG2_ACF_PRIORITY_VALUES = {
    "None",
    "Rarity",
    "Weight",
    "Mutation",
    "Sell Worth",
    "Fruit",
}

GAG2_ACF_COLLECT_MODES = {
    "All",
    "Only Selected",
}

GAG2_ACF_SPEED_VALUES = {
    "Normal",
    "Fast",
    "Ultra",
}

GAG2_ACF_SPEED_PRESETS = {
    Normal = {
        Name = "Normal",
        MinBurst = 1,
        MaxBurst = 40,
        RecentCooldown = 1.25,
        PromptDelayOverride = nil,
        YieldEvery = 6,
        LoopWaitAfterFire = 0.03,
        LoopWaitIdle = 0.35,
    },

    Fast = {
        Name = "Fast",
        MinBurst = 24,
        MaxBurst = 90,
        RecentCooldown = 0.25,
        PromptDelayOverride = 0,
        YieldEvery = 24,
        LoopWaitAfterFire = 0.005,
        LoopWaitIdle = 0.12,
    },

    Ultra = {
        Name = "Ultra",
        MinBurst = 60,
        MaxBurst = 160,
        RecentCooldown = 0.04,
        PromptDelayOverride = 0,
        YieldEvery = 60,
        LoopWaitAfterFire = 0,
        LoopWaitIdle = 0.025,
    },
}

GAG2_ACF_SIZE_MODES = {
    "Off",
    "Above",
    "Below",
}

GAG2_ACF_WEATHER_MODE_VALUES = {
    "Any Weather",
    "Selected",
}

GAG2_ACF_WEATHER_VALUES = {
    "Rain",
    "Lightning",
    "Rainbow",
    "Snowfall",
    "Starfall",
}

GAG2_ACF_REAL_WEATHER_SET = {
    Rain = true,
    Lightning = true,
    Rainbow = true,
    Snowfall = true,
    Starfall = true,
}

GAG2_ACF_NORMAL_WEATHER_SET = {
    Day = true,
    Night = true,
    Dawn = true,
    Dusk = true,
    Morning = true,
    Evening = true,
}

GAG2_ACF_DEFAULT_RARITIES = {
    "Common",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythic",
    "Mythical",
    "Super",
    "Divine",
    "Prismatic",
}

GAG2_ACF_DEFAULT_MUTATIONS = {
    "None",
    "Gold",
    "Rainbow",
    "Bloodlit",
    "Starstruck",
    "Electric",
    "Frozen",
    "Chained",
    "Solarflare",
    "Pizza",
}

GAG2_ACF_RARITY_SCORE = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythic = 6,
    Mythical = 6,
    Super = 7,
    Divine = 8,
    Prismatic = 9,
}

function GAG2ACFSetStatus(text)

    local statusText =
        tostring(text or "Idle.")

    GAG2_AUTO_COLLECT_FRUIT_STATE.LastStatus =
        statusText

    if Options.HolyGAG2FarmStatus then

        Options.HolyGAG2FarmStatus:SetText(
            statusText
        )
    end
end

function GAG2ACFFormatNumber(value)

    local number =
        tonumber(value)

    if not number then
        return "?"
    end

    local text =
        tostring(
            math.floor(number + 0.5)
        )

    text =
        text:reverse()
            :gsub("(%d%d%d)", "%1,")
            :reverse()
            :gsub("^,", "")

    return text
end

function GAG2ACFFormatSize(value)

    local number =
        tonumber(value)
        or 0

    return string.format(
        "%.2fx",
        number
    )
end

function GAG2ACFClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2ACFTableCount(map)

    if type(map) ~= "table" then
        return 0
    end

    local count =
        0

    for _, enabled in pairs(map) do

        if enabled == true then
            count += 1
        end
    end

    return count
end

function GAG2ACFNormalizeSelection(value)

    local result =
        {}

    local function add(item)

        item =
            GAG2ACFClean(item)

        if item == ""
        or item == "Select Options" then
            return
        end

        result[item] =
            true
    end

    if type(value) == "table" then

        for _, item in ipairs(value) do
            add(item)
        end

        for item, enabled in pairs(value) do

            if enabled == true then
                add(item)
            end
        end

    elseif type(value) == "string" then

        add(value)
    end

    return result
end

function GAG2ACFSelectionHas(map, value)

    value =
        GAG2ACFClean(value)

    if value == "" then
        value =
            "None"
    end

    return type(map) == "table"
        and map[value] == true
end

function GAG2ACFGetActiveWeather()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local weather =
        GAG2ACFClean(
            workspace:GetAttribute("ActiveWeather")
        )

    local phase =
        GAG2ACFClean(
            workspace:GetAttribute("ActivePhase")
        )

    if weather == "" then
        weather =
            "Day"
    end

    if phase == "" then
        phase =
            weather
    end

    state.ActiveWeather =
        weather

    state.ActivePhase =
        phase

    return weather,
        phase
end

function GAG2ACFIsRealWeatherName(weather)

    weather =
        GAG2ACFClean(weather)

    return GAG2_ACF_REAL_WEATHER_SET[weather] == true
end

function GAG2ACFShouldPauseForWeather()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local weather =
        GAG2ACFGetActiveWeather()

    if state.PauseDuringWeather ~= true then
        return false,
            weather
    end

    if GAG2ACFIsRealWeatherName(weather) ~= true then
        return false,
            weather
    end

    if state.PauseWeatherMode == "Selected" then

        return type(state.PauseWeathers) == "table"
            and state.PauseWeathers[weather] == true,
            weather
    end

    return true,
        weather
end

function GAG2ACFWeatherStatusText()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local weather, phase =
        GAG2ACFGetActiveWeather()

    local paused =
        GAG2ACFShouldPauseForWeather()

    local text =
        tostring(weather)

    if phase ~= ""
    and phase ~= weather then

        text =
            text
            .. " / "
            .. tostring(phase)
    end

    if state.PauseDuringWeather == true then

        text =
            text
            .. (
                paused == true
                and " | PAUSED"
                or " | watching"
            )

    else

        text =
            text
            .. " | ignore"
    end

    return text
end

function GAG2ACFStartWeatherWatcher()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    if state.WeatherWatcherStarted == true then
        return
    end

    state.WeatherWatcherStarted =
        true

    state.WeatherConnections =
        type(state.WeatherConnections) == "table"
        and state.WeatherConnections
        or {}

    GAG2ACFGetActiveWeather()

    local function connectAttribute(attributeName)

        local ok, connection =
            pcall(function()

                return workspace:GetAttributeChangedSignal(attributeName):Connect(function()

                    local weather =
                        GAG2ACFGetActiveWeather()

                    local paused =
                        GAG2ACFShouldPauseForWeather()

                    if GAG2_AUTO_COLLECT_FRUIT_STATE.Enabled == true then

                        if paused == true then

                            GAG2ACFSetStatus(
                                GAG2ACFBuildStatusText(
                                    {},
                                    GAG2_AUTO_COLLECT_FRUIT_STATE.LastReadyCount or 0,
                                    GAG2_AUTO_COLLECT_FRUIT_STATE.LastExcludedCount or 0,
                                    "Paused for weather: "
                                    .. tostring(weather)
                                )
                            )

                        else

                            GAG2ACFSetStatus(
                                "Weather changed: "
                                .. tostring(weather)
                                .. ". Auto Collect can run."
                            )
                        end
                    end
                end)
            end)

        if ok == true
        and connection then

            table.insert(
                state.WeatherConnections,
                connection
            )
        end
    end

    connectAttribute(
        "ActiveWeather"
    )

    connectAttribute(
        "ActivePhase"
    )
end

function GAG2ACFSafeRequire(moduleName)

    local sharedModules =
        ReplicatedStorage:FindFirstChild("SharedModules")

    local module =
        sharedModules
        and sharedModules:FindFirstChild(
            moduleName,
            true
        )

    if not module
    or module:IsA("ModuleScript") ~= true then
        return nil
    end

    local ok, result =
        pcall(function()

            return require(
                module
            )
        end)

    if ok == true then
        return result
    end

    return nil
end

function GAG2ACFRememberChoice(bucketName, value)

    value =
        GAG2ACFClean(value)

    if value == "" then
        return
    end

    local bucket =
        GAG2_AUTO_COLLECT_FRUIT_STATE[bucketName]

    if type(bucket) ~= "table" then

        bucket = {}

        GAG2_AUTO_COLLECT_FRUIT_STATE[bucketName] =
            bucket
    end

    if table.find(bucket, value) ~= nil then
        return
    end

    table.insert(
        bucket,
        value
    )

    table.sort(
        bucket
    )
end

function GAG2ACFEnsureModules()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local now =
        os.clock()

    if tonumber(state.LastModuleRefreshAt)
    and now - state.LastModuleRefreshAt < 5 then
        return state.Modules
    end

    state.LastModuleRefreshAt =
        now

    state.Modules =
        state.Modules
        or {}

    state.Modules.SeedData =
        state.Modules.SeedData
        or GAG2ACFSafeRequire("SeedData")

    state.Modules.SellValueData =
        state.Modules.SellValueData
        or GAG2ACFSafeRequire("SellValueData")

    state.Modules.MutationData =
        state.Modules.MutationData
        or GAG2ACFSafeRequire("MutationData")

    state.Modules.FruitValueCalc =
        state.Modules.FruitValueCalc
        or GAG2ACFSafeRequire("FruitValueCalc")

    state.SeedMap =
        {}

    if type(state.Modules.SeedData) == "table" then

        for _, row in pairs(state.Modules.SeedData) do

            if type(row) == "table"
            and type(row.SeedName) == "string" then

                state.SeedMap[row.SeedName] =
                    row

                GAG2ACFRememberChoice(
                    "FruitNames",
                    row.SeedName
                )

                if row.Rarity then

                    GAG2ACFRememberChoice(
                        "RarityNames",
                        tostring(row.Rarity)
                    )
                end
            end
        end
    end

    for _, rarity in ipairs(GAG2_ACF_DEFAULT_RARITIES) do

        GAG2ACFRememberChoice(
            "RarityNames",
            rarity
        )
    end

    for _, mutation in ipairs(GAG2_ACF_DEFAULT_MUTATIONS) do

        GAG2ACFRememberChoice(
            "MutationNames",
            mutation
        )
    end

    return state.Modules
end

function GAG2ACFGetOwnGarden()

    if type(GAG2ResolveOwnFarmPlot) == "function" then

        local plot =
            nil

        pcall(function()

            plot =
                GAG2ResolveOwnFarmPlot()
        end)

        if typeof(plot) == "Instance" then
            return plot
        end
    end

    local gardens =
        workspace:FindFirstChild("Gardens")

    if not gardens then
        return nil
    end

    local playerName =
        tostring(LOCAL_PLAYER and LOCAL_PLAYER.Name or "")

    local userId =
        tostring(LOCAL_PLAYER and LOCAL_PLAYER.UserId or "")

    for _, garden in ipairs(gardens:GetChildren()) do

        local attrs =
            garden:GetAttributes()

        if tostring(attrs.Owner or "") == playerName
        or tostring(attrs.OwnerUserId or "") == userId then
            return garden
        end
    end

    return nil
end

function GAG2ACFGetHarvestPrompt(fruit)

    if typeof(fruit) ~= "Instance" then
        return nil
    end

    local harvestPart =
        fruit:FindFirstChild("HarvestPart")

    local prompt =
        harvestPart
        and harvestPart:FindFirstChild("HarvestPrompt")

    if prompt
    and prompt:IsA("ProximityPrompt")
    and prompt.Enabled == true then

        return prompt
    end

    local scanned =
        0

    for _, descendant in ipairs(fruit:GetDescendants()) do

        scanned += 1

        if scanned > 350 then
            break
        end

        if descendant:IsA("ProximityPrompt")
        and descendant.Enabled == true then

            local promptName =
                tostring(descendant.Name or ""):lower()

            local parentName =
                descendant.Parent
                and tostring(descendant.Parent.Name or ""):lower()
                or ""

            if promptName == "harvestprompt"
            or promptName:find("harvest", 1, true)
            or parentName:find("harvest", 1, true) then

                return descendant
            end
        end
    end

    return nil
end

function GAG2ACFReadFruitName(fruit, plant)

    local name =
        ""

    if typeof(fruit) == "Instance" then

        name =
            GAG2ACFClean(
                fruit:GetAttribute("CorePartName")
            )
    end

    if name == ""
    and typeof(plant) == "Instance" then

        name =
            GAG2ACFClean(
                plant:GetAttribute("SeedName")
            )
    end

    if name == ""
    and typeof(fruit) == "Instance" then

        name =
            GAG2ACFClean(
                fruit.Name
            )
    end

    return name
end

function GAG2ACFReadMutation(fruit, plant)

    local mutation =
        ""

    if typeof(fruit) == "Instance" then

        mutation =
            GAG2ACFClean(
                fruit:GetAttribute("Mutation")
            )
    end

    -- Important:
    -- Do NOT fall back to plant:GetAttribute("Mutation").
    -- A Rainbow/Gold/etc plant can still grow normal fruits.
    -- Exclude Mutations should only block the fruit's own mutation.

    return mutation
end

function GAG2ACFGetMutationScore(mutation)

    mutation =
        GAG2ACFClean(mutation)

    if mutation == ""
    or mutation == "None" then
        return 1
    end

    local modules =
        GAG2ACFEnsureModules()

    local mutationData =
        modules
        and modules.MutationData

    if type(mutationData) == "table"
    and type(mutationData.ReturnPriceMultiplier) == "function" then

        local ok, result =
            pcall(
                mutationData.ReturnPriceMultiplier,
                mutation
            )

        if ok == true
        and tonumber(result) then

            return tonumber(result)
        end
    end

    return 1
end

function GAG2ACFGetSellWorth(name, sizeMulti, mutation, fruit)

    local modules =
        GAG2ACFEnsureModules()

    local fruitValueCalc =
        modules
        and modules.FruitValueCalc

    if type(fruitValueCalc) == "function" then

        local ok, result =
            pcall(
                fruitValueCalc,
                name,
                sizeMulti,
                mutation,
                fruit
            )

        if ok == true
        and tonumber(result) then

            return tonumber(result)
        end
    end

    local base =
        modules
        and type(modules.SellValueData) == "table"
        and tonumber(modules.SellValueData[name])
        or 0

    local mutationScore =
        GAG2ACFGetMutationScore(
            mutation
        )

    return math.floor(
        base
        * math.max(1, tonumber(sizeMulti) or 1)
        * math.max(1, mutationScore)
    )
end

function GAG2ACFBuildEntry(plant, fruit)

    local prompt =
        GAG2ACFGetHarvestPrompt(
            fruit
        )

    if not prompt then
        return nil
    end

    local name =
        GAG2ACFReadFruitName(
            fruit,
            plant
        )

    if name == "" then
        return nil
    end

    local mutation =
        GAG2ACFReadMutation(
            fruit,
            plant
        )

    local sizeMulti =
        tonumber(
            fruit:GetAttribute("SizeMulti")
        )
        or 1

    local modules =
        GAG2ACFEnsureModules()

    local seedRow =
        GAG2_AUTO_COLLECT_FRUIT_STATE.SeedMap[name]

    local rarity =
        seedRow
        and GAG2ACFClean(seedRow.Rarity)
        or "?"

    local rarityScore =
        GAG2_ACF_RARITY_SCORE[rarity]
        or 0

    local mutationScore =
        GAG2ACFGetMutationScore(
            mutation
        )

    local sellWorth =
        GAG2ACFGetSellWorth(
            name,
            sizeMulti,
            mutation,
            fruit
        )

    local fruitId =
        GAG2ACFClean(
            fruit:GetAttribute("FruitId")
        )

    local key =
        fruitId ~= ""
        and fruitId
        or PathOf(fruit)

    GAG2ACFRememberChoice(
        "FruitNames",
        name
    )

    if rarity ~= "?" then

        GAG2ACFRememberChoice(
            "RarityNames",
            rarity
        )
    end

    if mutation ~= "" then

        GAG2ACFRememberChoice(
            "MutationNames",
            mutation
        )
    end

    return {
        Plant = plant,
        Fruit = fruit,
        Prompt = prompt,
        Key = key,
        FruitId = fruitId,

        Name = name,
        Rarity = rarity,
        RarityScore = rarityScore,

        Mutation = mutation,
        MutationLabel =
            mutation ~= ""
            and mutation
            or "None",

        MutationScore = mutationScore,
        SizeMulti = sizeMulti,
        SellWorth = sellWorth,
    }
end

function GAG2ACFPassesCollectRules(entry)

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    if state.CollectMode == "Only Selected"
    and GAG2ACFTableCount(state.SelectedFruits) > 0
    and GAG2ACFSelectionHas(state.SelectedFruits, entry.Name) ~= true then

        return false
    end

    if state.CollectMode == "Only Selected"
    and GAG2ACFTableCount(state.SelectedFruits) <= 0 then

        return false
    end

    if GAG2ACFTableCount(state.SelectedRarities) > 0
    and GAG2ACFSelectionHas(state.SelectedRarities, entry.Rarity) ~= true then

        return false
    end

    if GAG2ACFTableCount(state.SelectedMutations) > 0
    and GAG2ACFSelectionHas(state.SelectedMutations, entry.MutationLabel) ~= true then

        return false
    end

    return true
end

function GAG2ACFPassesExclusions(entry)

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    if GAG2ACFSelectionHas(state.ExcludeFruits, entry.Name) == true then
        return false
    end

    if GAG2ACFSelectionHas(state.ExcludeRarities, entry.Rarity) == true then
        return false
    end

    if GAG2ACFSelectionHas(state.ExcludeMutations, entry.MutationLabel) == true then
        return false
    end

    local threshold =
        tonumber(state.ExcludeSizeThreshold)
        or 0

    if threshold > 0 then

        if state.ExcludeSizeMode == "Above"
        and tonumber(entry.SizeMulti or 0) > threshold then
            return false
        end

        if state.ExcludeSizeMode == "Below"
        and tonumber(entry.SizeMulti or 0) < threshold then
            return false
        end
    end

    return true
end

function GAG2ACFEntryAllowed(entry)

    if type(entry) ~= "table" then
        return false
    end

    if GAG2ACFPassesCollectRules(entry) ~= true then
        return false
    end

    if GAG2ACFPassesExclusions(entry) ~= true then
        return false
    end

    return true
end

function GAG2ACFPriorityValue(entry, priorityName)

    priorityName =
        GAG2ACFClean(priorityName)

    if priorityName == "Rarity" then
        return tonumber(entry.RarityScore) or 0
    end

    if priorityName == "Weight" then
        return tonumber(entry.SizeMulti) or 0
    end

    if priorityName == "Mutation" then
        return tonumber(entry.MutationScore) or 1
    end

    if priorityName == "Sell Worth" then
        return tonumber(entry.SellWorth) or 0
    end

    if priorityName == "Fruit" then
        return tostring(entry.Name or "")
    end

    return nil
end

function GAG2ACFComparePriority(a, b, priorityName)

    priorityName =
        GAG2ACFClean(priorityName)

    if priorityName == ""
    or priorityName == "None" then
        return nil
    end

    local aValue =
        GAG2ACFPriorityValue(
            a,
            priorityName
        )

    local bValue =
        GAG2ACFPriorityValue(
            b,
            priorityName
        )

    if aValue == nil
    or bValue == nil
    or aValue == bValue then
        return nil
    end

    if priorityName == "Fruit" then
        return tostring(aValue) < tostring(bValue)
    end

    return tonumber(aValue or 0) > tonumber(bValue or 0)
end

function GAG2ACFSortQueue(queue)

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    table.sort(queue, function(a, b)

        local result =
            GAG2ACFComparePriority(
                a,
                b,
                state.Priority1
            )

        if result ~= nil then
            return result
        end

        result =
            GAG2ACFComparePriority(
                a,
                b,
                state.Priority2
            )

        if result ~= nil then
            return result
        end

        result =
            GAG2ACFComparePriority(
                a,
                b,
                state.Priority3
            )

        if result ~= nil then
            return result
        end

        if tonumber(a.SellWorth or 0) ~= tonumber(b.SellWorth or 0) then

            return tonumber(a.SellWorth or 0)
                > tonumber(b.SellWorth or 0)
        end

        if tonumber(a.SizeMulti or 0) ~= tonumber(b.SizeMulti or 0) then

            return tonumber(a.SizeMulti or 0)
                > tonumber(b.SizeMulti or 0)
        end

        return tostring(a.Name or "")
            < tostring(b.Name or "")
    end)
end

function GAG2ACFScanQueue()

    GAG2ACFEnsureModules()

    local garden =
        GAG2ACFGetOwnGarden()

    local queue =
        {}

    local readyCount =
        0

    local excludedCount =
        0

    if not garden then

        return queue,
            0,
            0,
            "own garden missing"
    end

    local plants =
        garden:FindFirstChild("Plants")

    if not plants then

        return queue,
            0,
            0,
            "plants folder missing"
    end

    local seenPrompts =
        {}

    local function resolveFruitFromPrompt(plant, prompt)

        if typeof(plant) ~= "Instance"
        or typeof(prompt) ~= "Instance" then

            return nil
        end

        local current =
            prompt.Parent

        while typeof(current) == "Instance"
        and current ~= plants
        and current ~= garden
        and current ~= game do

            if current:IsA("Model") then

                return current
            end

            if current == plant then
                break
            end

            current =
                current.Parent
        end

        if plant:IsA("Model") then

            return plant
        end

        return nil
    end

    local function addPromptEntry(plant, prompt)

        if typeof(prompt) ~= "Instance"
        or prompt:IsA("ProximityPrompt") ~= true then

            return
        end

        if prompt.Enabled ~= true then
            return
        end

        if seenPrompts[prompt] == true then
            return
        end

        seenPrompts[prompt] =
            true

        local fruit =
            resolveFruitFromPrompt(
                plant,
                prompt
            )

        if typeof(fruit) ~= "Instance" then
            return
        end

        local entry =
            GAG2ACFBuildEntry(
                plant,
                fruit
            )

        if not entry then
            return
        end

        entry.Prompt =
            prompt

        if entry.FruitId == "" then

            entry.Key =
                PathOf(prompt)
        end

        readyCount += 1

        if GAG2ACFEntryAllowed(entry) == true then

            table.insert(
                queue,
                entry
            )

        else

            excludedCount += 1
        end
    end

    for _, plant in ipairs(plants:GetChildren()) do

        if plant:IsA("Model")
        or plant:IsA("Folder") then

            -- Old structure:
            -- Plant -> Fruits -> FruitModel -> HarvestPart -> HarvestPrompt
            local fruits =
                plant:FindFirstChild("Fruits")

            if fruits then

                for _, fruit in ipairs(fruits:GetChildren()) do

                    if fruit:IsA("Model") then

                        local prompt =
                            GAG2ACFGetHarvestPrompt(
                                fruit
                            )

                        if prompt then

                            addPromptEntry(
                                plant,
                                prompt
                            )
                        end
                    end
                end
            end

            -- New/fallback structure:
            -- Plant can expose HarvestPrompt directly, or under a different descendant path.
            local scanned =
                0

            for _, descendant in ipairs(plant:GetDescendants()) do

                scanned += 1

                if scanned > 1800 then
                    break
                end

                if descendant:IsA("ProximityPrompt")
                and descendant.Enabled == true then

                    local promptName =
                        tostring(descendant.Name or ""):lower()

                    local parentName =
                        descendant.Parent
                        and tostring(descendant.Parent.Name or ""):lower()
                        or ""

                    if promptName == "harvestprompt"
                    or promptName:find("harvest", 1, true)
                    or parentName:find("harvest", 1, true) then

                        addPromptEntry(
                            plant,
                            descendant
                        )
                    end
                end
            end
        end
    end

    GAG2ACFSortQueue(
        queue
    )

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local now =
        os.clock()

    if now - tonumber(state.LastRefreshAt or 0) >= 5 then

        state.LastRefreshAt =
            now

        task.defer(function()

            if type(GAG2ACFRefreshDropdownValues) == "function" then

                GAG2ACFRefreshDropdownValues()
            end
        end)
    end

    return queue,
        readyCount,
        excludedCount,
        "ok"
end

function GAG2ACFBuildStatusText(queue, readyCount, excludedCount, note)

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local matching =
        #queue

    local nextText =
        "None"

    if queue[1] then

        nextText =
            tostring(queue[1].Name)
            .. " | "
            .. tostring(queue[1].Rarity)
            .. " | "
            .. tostring(queue[1].MutationLabel)
            .. " | size "
            .. GAG2ACFFormatSize(queue[1].SizeMulti)
            .. " | worth "
            .. GAG2ACFFormatNumber(queue[1].SellWorth)
    end

    state.LastReadyCount =
        readyCount

    state.LastMatchingCount =
        matching

    state.LastExcludedCount =
        excludedCount

    state.LastNextText =
        nextText

    return '<font color="rgb(196,181,253)"><b>Auto Collect Fruits</b></font>'
        .. '\nState: '
        .. (
            state.Enabled == true
            and "ON"
            or "OFF"
        )
        .. '\nReady: '
        .. tostring(readyCount)
        .. ' | Matching: '
        .. tostring(matching)
        .. ' | Excluded: '
        .. tostring(excludedCount)
        .. '\nNext: '
        .. tostring(nextText)
        .. '\nPriority: '
        .. tostring(state.Priority1)
        .. ' > '
        .. tostring(state.Priority2)
        .. ' > '
        .. tostring(state.Priority3)
        .. '\nSpeed: '
        .. tostring(state.CollectionSpeed or "Normal")
        .. ' | Burst: '
        .. tostring(
            type(GAG2ACFGetEffectiveBurstAmount) == "function"
            and GAG2ACFGetEffectiveBurstAmount()
            or state.BurstAmount
        )
        .. ' | Cooldown: '
        .. tostring(
            type(GAG2ACFGetEffectiveRecentCooldown) == "function"
            and GAG2ACFGetEffectiveRecentCooldown()
            or 1.25
        )
        .. 's'
        .. '\nWeather: '
        .. GAG2ACFWeatherStatusText()
        .. '\nNote: '
        .. tostring(note or "Weight uses SizeMulti until exact KG is found.")
end

function GAG2ACFBackpackLooksFull()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    if state.StopIfFull ~= true then
        return false
    end

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    local backpackGui =
        playerGui
        and playerGui:FindFirstChild("BackpackGui")

    if not backpackGui then
        return false
    end

    local scanned =
        0

    for _, descendant in ipairs(backpackGui:GetDescendants()) do

        scanned += 1

        if scanned > 2500 then
            break
        end

        if descendant:IsA("TextLabel")
        or descendant:IsA("TextButton")
        or descendant:IsA("TextBox") then

            local text =
                GAG2ACFClean(
                    descendant.Text
                ):lower()

            if text:find("backpack", 1, true)
            and (
                text:find("full", 1, true)
                or text:find("max", 1, true)
            ) then

                return true
            end
        end
    end

    return false
end

function GAG2ACFFirePrompt(prompt)

    if typeof(prompt) ~= "Instance"
    or prompt:IsA("ProximityPrompt") ~= true then
        return false, "bad prompt"
    end

    if prompt.Enabled ~= true then
        return false, "prompt disabled"
    end

    if type(fireproximityprompt) ~= "function" then
        return false, "fireproximityprompt unsupported"
    end

    local ok, err =
        pcall(
            fireproximityprompt,
            prompt
        )

    if ok ~= true then
        return false, tostring(err)
    end

    return true, "fired"
end

function GAG2ACFCollectBatch()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local pausedForWeather, weather =
        GAG2ACFShouldPauseForWeather()

    if pausedForWeather == true then

        GAG2ACFSetStatus(
            GAG2ACFBuildStatusText(
                {},
                state.LastReadyCount or 0,
                state.LastExcludedCount or 0,
                "Paused for weather: "
                .. tostring(weather)
            )
        )

        return -1
    end

    local queue, readyCount, excludedCount, reason =
        GAG2ACFScanQueue()

    if reason ~= "ok" then

        GAG2ACFSetStatus(
            GAG2ACFBuildStatusText(
                {},
                readyCount,
                excludedCount,
                reason
            )
        )

        return 0
    end

    if #queue <= 0 then

        GAG2ACFSetStatus(
            GAG2ACFBuildStatusText(
                queue,
                readyCount,
                excludedCount,
                "No matching fruit."
            )
        )

        return 0
    end

    local burstAmount =
        GAG2ACFGetEffectiveBurstAmount()

    local recentCooldown =
        GAG2ACFGetEffectiveRecentCooldown()

    local promptDelay =
        GAG2ACFGetEffectivePromptDelay()

    local yieldEvery =
        GAG2ACFGetEffectiveYieldEvery()

    local fired =
        0

    for _, entry in ipairs(queue) do

        if fired >= burstAmount then
            break
        end

        if state.Enabled ~= true then
            break
        end

        local recentAt =
            tonumber(
                state.Recent[entry.Key]
            )
            or 0

        if os.clock() - recentAt >= recentCooldown then

            local ok =
                GAG2ACFFirePrompt(
                    entry.Prompt
                )

            state.Recent[entry.Key] =
                os.clock()

            if ok == true then

                fired += 1

                state.LastFiredCount =
                    fired

                if type(GAG2AutoSellHandleCollectedFruit) == "function" then

                    GAG2AutoSellHandleCollectedFruit(
                        entry
                    )
                end
            end

            if promptDelay > 0 then

                task.wait(
                    promptDelay
                )

            elseif yieldEvery > 0
            and fired % yieldEvery == 0 then

                task.wait()
            end
        end
    end

    GAG2ACFSetStatus(
        GAG2ACFBuildStatusText(
            queue,
            readyCount,
            excludedCount,
            fired > 0
            and (
                "Collected "
                .. tostring(fired)
                .. " this batch."
            )
            or "No prompt fired."
        )
    )

    return fired
end

function GAG2ACFStartLoop()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    if state.Running == true then
        return
    end

    state.Running =
        true

    task.spawn(function()

        while state.Enabled == true do

            if GAG2ACFBackpackLooksFull() == true then

                if type(GAG2AutoSellIsEnabled) == "function"
                and GAG2AutoSellIsEnabled() == true then

                    if type(GAG2AutoSellScanExistingFruitTools) == "function" then

                        GAG2AutoSellScanExistingFruitTools(
                            "backpack full"
                        )
                    end

                    if type(GAG2AutoSellScheduleSellAll) == "function"
                    and GAG2_AUTO_SELL_FRUIT_STATE
                    and GAG2_AUTO_SELL_FRUIT_STATE.Method == "SellAll" then

                        GAG2AutoSellScheduleSellAll(
                            "backpack full"
                        )
                    end

                    GAG2ACFSetStatus(
                        '<font color="rgb(196,181,253)"><b>Auto Collect:</b></font>'
                        .. '\nBackpack full/max detected.'
                        .. '\nAuto Sell is ON, selling and continuing.'
                    )

                    task.wait(
                        0.15
                    )

                else

                    state.Enabled =
                        false

                    if Toggles.HolyGAG2AutoCollectFruits
                    and type(Toggles.HolyGAG2AutoCollectFruits.SetValue) == "function" then

                        pcall(function()

                            Toggles.HolyGAG2AutoCollectFruits:SetValue(
                                false
                            )
                        end)
                    end

                    GAG2ACFSetStatus(
                        '<font color="rgb(248,113,113)"><b>Auto Collect stopped:</b></font>'
                        .. '\nBackpack looks full/max.'
                    )

                    break
                end
            end

            local fired =
                GAG2ACFCollectBatch()

            if fired == -1 then

                task.wait(
                    0.75
                )

            elseif fired > 0 then

                local fireWait =
                    GAG2ACFGetLoopWaitAfterFire()

                if fireWait > 0 then

                    task.wait(
                        fireWait
                    )

                else

                    task.wait()
                end

            else

                task.wait(
                    GAG2ACFGetLoopWaitIdle()
                )
            end
        end

        state.Running =
            false

        if state.Enabled ~= true then

            GAG2ACFSetStatus(
                GAG2ACFBuildStatusText(
                    {},
                    state.LastReadyCount or 0,
                    state.LastExcludedCount or 0,
                    "Stopped."
                )
            )
        end
    end)
end

function GAG2ACFSetEnabled(value)

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    state.Enabled =
        value == true

    if state.Enabled == true then

        GAG2ACFSetStatus(
            "Auto Collect Fruits starting..."
        )

        if ConfigState.Loading ~= true then

            GAG2ACFStartLoop()
        end

    else

        GAG2ACFSetStatus(
            GAG2ACFBuildStatusText(
                {},
                state.LastReadyCount or 0,
                state.LastExcludedCount or 0,
                "Stopped."
            )
        )
    end

    MarkConfigDirty()
end

function GAG2ACFSetStopIfFull(value)

    GAG2_AUTO_COLLECT_FRUIT_STATE.StopIfFull =
        value == true

    MarkConfigDirty()
end

function GAG2ACFGetSpeedPreset()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local speed =
        GAG2ACFClean(
            state.CollectionSpeed
        )

    local preset =
        GAG2_ACF_SPEED_PRESETS[speed]
        or GAG2_ACF_SPEED_PRESETS.Normal

    state.CollectionSpeed =
        preset.Name

    return preset
end

function GAG2ACFSetCollectionSpeed(value)

    value =
        GAG2ACFClean(value)

    if GAG2_ACF_SPEED_PRESETS[value] == nil then
        value =
            "Normal"
    end

    GAG2_AUTO_COLLECT_FRUIT_STATE.CollectionSpeed =
        value

    MarkConfigDirty()
end

function GAG2ACFGetEffectiveBurstAmount()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local preset =
        GAG2ACFGetSpeedPreset()

    local inputBurst =
        math.clamp(
            math.floor(
                tonumber(state.BurstAmount)
                or 8
            ),
            1,
            160
        )

    return math.clamp(
        math.max(
            inputBurst,
            tonumber(preset.MinBurst) or inputBurst
        ),
        1,
        tonumber(preset.MaxBurst) or 160
    )
end

function GAG2ACFGetEffectiveRecentCooldown()

    local preset =
        GAG2ACFGetSpeedPreset()

    return math.clamp(
        tonumber(preset.RecentCooldown)
        or 1.25,
        0,
        2
    )
end

function GAG2ACFGetEffectivePromptDelay()

    local state =
        GAG2_AUTO_COLLECT_FRUIT_STATE

    local preset =
        GAG2ACFGetSpeedPreset()

    if preset.PromptDelayOverride ~= nil then

        return math.clamp(
            tonumber(preset.PromptDelayOverride)
            or 0,
            0,
            2
        )
    end

    return math.clamp(
        tonumber(state.Delay)
        or 0,
        0,
        2
    )
end

function GAG2ACFGetEffectiveYieldEvery()

    local preset =
        GAG2ACFGetSpeedPreset()

    return math.max(
        1,
        math.floor(
            tonumber(preset.YieldEvery)
            or 6
        )
    )
end

function GAG2ACFGetLoopWaitAfterFire()

    local preset =
        GAG2ACFGetSpeedPreset()

    return math.clamp(
        tonumber(preset.LoopWaitAfterFire)
        or 0.03,
        0,
        1
    )
end

function GAG2ACFGetLoopWaitIdle()

    local preset =
        GAG2ACFGetSpeedPreset()

    return math.clamp(
        tonumber(preset.LoopWaitIdle)
        or 0.35,
        0.02,
        2
    )
end

function GAG2ACFSetPauseDuringWeather(value)

    GAG2_AUTO_COLLECT_FRUIT_STATE.PauseDuringWeather =
        value == true

    GAG2ACFStartWeatherWatcher()

    MarkConfigDirty()
end

function GAG2ACFSetPauseWeatherMode(value)

    value =
        GAG2ACFClean(value)

    if value ~= "Selected" then
        value =
            "Any Weather"
    end

    GAG2_AUTO_COLLECT_FRUIT_STATE.PauseWeatherMode =
        value

    GAG2ACFStartWeatherWatcher()

    MarkConfigDirty()
end

function GAG2ACFSetPauseWeathers(value)

    local selected =
        GAG2ACFNormalizeSelection(
            value
        )

    GAG2_AUTO_COLLECT_FRUIT_STATE.PauseWeathers =
        selected

    GAG2ACFStartWeatherWatcher()

    MarkConfigDirty()
end

function GAG2ACFSetDelay(value)

    GAG2_AUTO_COLLECT_FRUIT_STATE.Delay =
        math.clamp(
            tonumber(value)
            or 0,
            0,
            2
        )

    MarkConfigDirty()
end

function GAG2ACFSetBurst(value)

    GAG2_AUTO_COLLECT_FRUIT_STATE.BurstAmount =
        math.clamp(
            math.floor(
                tonumber(value)
                or 8
            ),
            1,
            160
        )

    MarkConfigDirty()
end

function GAG2ACFSetCollectMode(value)

    value =
        GAG2ACFClean(value)

    if value ~= "Only Selected" then
        value =
            "All"
    end

    GAG2_AUTO_COLLECT_FRUIT_STATE.CollectMode =
        value

    MarkConfigDirty()
end

function GAG2ACFSetDropdownMap(key, value)

    GAG2_AUTO_COLLECT_FRUIT_STATE[key] =
        GAG2ACFNormalizeSelection(
            value
        )

    MarkConfigDirty()
end

function GAG2ACFSetExcludeSizeMode(value)

    value =
        GAG2ACFClean(value)

    if value ~= "Above"
    and value ~= "Below" then
        value =
            "Off"
    end

    GAG2_AUTO_COLLECT_FRUIT_STATE.ExcludeSizeMode =
        value

    MarkConfigDirty()
end

function GAG2ACFSetExcludeSizeThreshold(value)

    GAG2_AUTO_COLLECT_FRUIT_STATE.ExcludeSizeThreshold =
        math.max(
            0,
            tonumber(value)
            or 0
        )

    MarkConfigDirty()
end

function GAG2ACFSetPriority(slot, value)

    slot =
        tonumber(slot)

    if not slot
    or slot < 1
    or slot > 3 then
        return
    end

    value =
        GAG2ACFClean(value)

    if table.find(GAG2_ACF_PRIORITY_VALUES, value) == nil then
        value =
            "None"
    end

    GAG2_AUTO_COLLECT_FRUIT_STATE[
        "Priority"
        .. tostring(slot)
    ] =
        value

    MarkConfigDirty()
end

function GAG2ACFGetFruitDropdownValues()

    GAG2ACFEnsureModules()

    local names =
        {}

    local function add(name)

        name =
            GAG2ACFClean(name)

        if name == "" then
            return
        end

        if table.find(names, name) ~= nil then
            return
        end

        table.insert(
            names,
            name
        )
    end

    for _, name in ipairs(GAG2_AUTO_COLLECT_FRUIT_STATE.FruitNames or {}) do
        add(name)
    end

    local garden =
        GAG2ACFGetOwnGarden()

    local plants =
        garden
        and garden:FindFirstChild("Plants")

    if plants then

        for _, plant in ipairs(plants:GetChildren()) do

            add(
                plant:GetAttribute("SeedName")
            )

            local fruits =
                plant:FindFirstChild("Fruits")

            if fruits then

                for _, fruit in ipairs(fruits:GetChildren()) do

                    add(
                        fruit:GetAttribute("CorePartName")
                    )
                end
            end
        end
    end

    table.sort(
        names
    )

    return names
end

function GAG2ACFGetRarityDropdownValues()

    GAG2ACFEnsureModules()

    local values =
        {}

    local function add(value)

        value =
            GAG2ACFClean(value)

        if value == "" then
            return
        end

        if table.find(values, value) ~= nil then
            return
        end

        table.insert(
            values,
            value
        )
    end

    for _, rarity in ipairs(GAG2_AUTO_COLLECT_FRUIT_STATE.RarityNames or {}) do
        add(rarity)
    end

    table.sort(values, function(a, b)

        return (GAG2_ACF_RARITY_SCORE[a] or 0)
            > (GAG2_ACF_RARITY_SCORE[b] or 0)
    end)

    return values
end

function GAG2ACFGetMutationDropdownValues()

    GAG2ACFEnsureModules()

    local values =
        {}

    local function add(value)

        value =
            GAG2ACFClean(value)

        if value == "" then
            value =
                "None"
        end

        if table.find(values, value) ~= nil then
            return
        end

        table.insert(
            values,
            value
        )
    end

    for _, mutation in ipairs(GAG2_AUTO_COLLECT_FRUIT_STATE.MutationNames or {}) do
        add(mutation)
    end

    table.sort(values, function(a, b)

        if a == "None" then
            return true
        end

        if b == "None" then
            return false
        end

        return tostring(a) < tostring(b)
    end)

    return values
end

function GAG2ACFRefreshOneDropdown(dropdown, values)

    if not dropdown then
        return
    end

    pcall(function()

        if type(dropdown.SetValues) == "function" then

            dropdown:SetValues(
                values
            )

        elseif type(dropdown.SetItems) == "function" then

            dropdown:SetItems(
                values
            )
        end
    end)
end

function GAG2ACFRefreshDropdownValues()

    local controls =
        GAG2_AUTO_COLLECT_FRUIT_CONTROLS

    GAG2ACFRefreshOneDropdown(
        controls.SelectedFruits,
        GAG2ACFGetFruitDropdownValues()
    )

    GAG2ACFRefreshOneDropdown(
        controls.ExcludeFruits,
        GAG2ACFGetFruitDropdownValues()
    )

    GAG2ACFRefreshOneDropdown(
        controls.SelectedRarities,
        GAG2ACFGetRarityDropdownValues()
    )

    GAG2ACFRefreshOneDropdown(
        controls.ExcludeRarities,
        GAG2ACFGetRarityDropdownValues()
    )

    GAG2ACFRefreshOneDropdown(
        controls.SelectedMutations,
        GAG2ACFGetMutationDropdownValues()
    )

    GAG2ACFRefreshOneDropdown(
        controls.ExcludeMutations,
        GAG2ACFGetMutationDropdownValues()
    )
end

function GAG2RestoreAutoCollectFruitState()

    task.defer(function()

        local state =
            GAG2_AUTO_COLLECT_FRUIT_STATE

        if Toggles.HolyGAG2AutoCollectFruits then

            state.Enabled =
                Toggles.HolyGAG2AutoCollectFruits.Value == true
        end

        GAG2ACFStartWeatherWatcher()

        if Toggles.HolyGAG2ACFStopIfFull then

            state.StopIfFull =
                Toggles.HolyGAG2ACFStopIfFull.Value == true
        end

        if Toggles.HolyGAG2ACFPauseDuringWeather then

            state.PauseDuringWeather =
                Toggles.HolyGAG2ACFPauseDuringWeather.Value == true
        end

        if Options.HolyGAG2ACFPauseWeatherMode then

            GAG2ACFSetPauseWeatherMode(
                Options.HolyGAG2ACFPauseWeatherMode.Value
            )
        end

        if Options.HolyGAG2ACFPauseWeathers then

            GAG2ACFSetPauseWeathers(
                Options.HolyGAG2ACFPauseWeathers.Value
            )
        end

        if Options.HolyGAG2ACFCollectionSpeed then

            GAG2ACFSetCollectionSpeed(
                Options.HolyGAG2ACFCollectionSpeed.Value
            )
        end

        if Options.HolyGAG2ACFDelay then

            GAG2ACFSetDelay(
                Options.HolyGAG2ACFDelay.Value
            )
        end

        if Options.HolyGAG2ACFBurst then

            GAG2ACFSetBurst(
                Options.HolyGAG2ACFBurst.Value
            )
        end

        if Options.HolyGAG2ACFCollectMode then

            GAG2ACFSetCollectMode(
                Options.HolyGAG2ACFCollectMode.Value
            )
        end

        if Options.HolyGAG2ACFSelectedFruits then

            GAG2ACFSetDropdownMap(
                "SelectedFruits",
                Options.HolyGAG2ACFSelectedFruits.Value
            )
        end

        if Options.HolyGAG2ACFSelectedRarities then

            GAG2ACFSetDropdownMap(
                "SelectedRarities",
                Options.HolyGAG2ACFSelectedRarities.Value
            )
        end

        if Options.HolyGAG2ACFSelectedMutations then

            GAG2ACFSetDropdownMap(
                "SelectedMutations",
                Options.HolyGAG2ACFSelectedMutations.Value
            )
        end

        if Options.HolyGAG2ACFExcludeFruits then

            GAG2ACFSetDropdownMap(
                "ExcludeFruits",
                Options.HolyGAG2ACFExcludeFruits.Value
            )
        end

        if Options.HolyGAG2ACFExcludeRarities then

            GAG2ACFSetDropdownMap(
                "ExcludeRarities",
                Options.HolyGAG2ACFExcludeRarities.Value
            )
        end

        if Options.HolyGAG2ACFExcludeMutations then

            GAG2ACFSetDropdownMap(
                "ExcludeMutations",
                Options.HolyGAG2ACFExcludeMutations.Value
            )
        end

        if Options.HolyGAG2ACFExcludeSizeMode then

            GAG2ACFSetExcludeSizeMode(
                Options.HolyGAG2ACFExcludeSizeMode.Value
            )
        end

        if Options.HolyGAG2ACFExcludeSizeThreshold then

            GAG2ACFSetExcludeSizeThreshold(
                Options.HolyGAG2ACFExcludeSizeThreshold.Value
            )
        end

        for slot = 1, 3 do

            local option =
                Options[
                    "HolyGAG2ACFPriority"
                    .. tostring(slot)
                ]

            if option then

                GAG2ACFSetPriority(
                    slot,
                    option.Value
                )
            end
        end

        GAG2ACFRefreshDropdownValues()

        if state.Enabled == true then

            GAG2ACFStartLoop()

        else

            local queue, readyCount, excludedCount =
                GAG2ACFScanQueue()

            GAG2ACFSetStatus(
                GAG2ACFBuildStatusText(
                    queue,
                    readyCount,
                    excludedCount,
                    "Ready."
                )
            )
        end
    end)
end

--==================================================
-- [4.57] AUTO SELL FRUITS
-- Event-based instant fruit selling.
-- Packets confirmed:
-- NPCS.SellAll:Fire()
-- NPCS.SellFruit:Fire(fruitId)
--==================================================

GAG2_AUTO_SELL_FRUIT_STATE =
    GAG2_AUTO_SELL_FRUIT_STATE
    or {
        Enabled = false,
        Started = false,
        Running = false,

        Method = "SellAll",
        Speed = "Fast",
        RepeatCount = 1,

        Queue = {},
        QueueMap = {},
        RecentFruitIds = {},

        SellAllPending = false,
        LastSellAllAt = 0,
        LastSellFruitAt = 0,
        LastTriggerAt = 0,

        Packets = {},
        Connections = {},

        LastStatus = "Idle.",
        LastMethod = "None",
        LastFruitId = "",
        LastFruitName = "",
    }

GAG2_AUTO_SELL_METHOD_VALUES = {
    "SellAll",
    "SellFruit",
}

GAG2_AUTO_SELL_SPEED_VALUES = {
    "Normal",
    "Fast",
    "Ultra",
}

GAG2_AUTO_SELL_SPEED_PRESETS = {
    Normal = {
        SellAllDebounce = 0.18,
        SellFruitBurst = 8,
        SellFruitCycleWait = 0.04,
        YieldEvery = 8,
    },

    Fast = {
        SellAllDebounce = 0.07,
        SellFruitBurst = 25,
        SellFruitCycleWait = 0.015,
        YieldEvery = 18,
    },

    Ultra = {
        SellAllDebounce = 0.03,
        SellFruitBurst = 60,
        SellFruitCycleWait = 0,
        YieldEvery = 45,
    },
}

function GAG2AutoSellSetStatus(text)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    state.LastStatus =
        tostring(text or "Idle.")

    if Options.HolyGAG2SellStatus then

        Options.HolyGAG2SellStatus:SetText(
            '<font color="rgb(196,181,253)"><b>Auto Sell</b></font>'
            .. '\n'
            .. state.LastStatus
            .. '\nMethod: '
            .. tostring(state.Method or "SellAll")
            .. ' | Speed: '
            .. tostring(state.Speed or "Fast")
            .. ' | Repeat: '
            .. tostring(state.RepeatCount or 1)
        )
    end
end

function GAG2AutoSellClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2AutoSellGetPreset()

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    local speed =
        GAG2AutoSellClean(
            state.Speed
        )

    local preset =
        GAG2_AUTO_SELL_SPEED_PRESETS[speed]
        or GAG2_AUTO_SELL_SPEED_PRESETS.Fast

    state.Speed =
        speed ~= ""
        and GAG2_AUTO_SELL_SPEED_PRESETS[speed] ~= nil
        and speed
        or "Fast"

    return preset
end

function GAG2AutoSellGetRepeatCount()

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    local count =
        math.floor(
            tonumber(state.RepeatCount)
            or 1
        )

    return math.clamp(
        count,
        1,
        500
    )
end

function GAG2AutoSellSetRepeatCount(value)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    state.RepeatCount =
        math.clamp(
            math.floor(
                tonumber(value)
                or 1
            ),
            1,
            500
        )

    GAG2AutoSellSetStatus(
        "Repeat Count set: "
        .. tostring(state.RepeatCount)
    )

    MarkConfigDirty()
end

function GAG2AutoSellGetNPCSRoot()

    local sharedModules =
        ReplicatedStorage:FindFirstChild("SharedModules")

    local networking =
        sharedModules
        and sharedModules:FindFirstChild("Networking")

    local npcs =
        networking
        and networking:FindFirstChild("NPCS")

    return npcs
end

function GAG2AutoSellResolvePacket(packetName)

    packetName =
        GAG2AutoSellClean(packetName)

    if packetName == "" then
        return nil,
            "missing packet name"
    end

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    state.Packets =
        type(state.Packets) == "table"
        and state.Packets
        or {}

    if state.Packets[packetName] then
        return state.Packets[packetName],
            "cached"
    end

    -- Primary path:
    -- Use the already-working packet table scanner from the shop/sniper systems.
    local packets =
        nil

    if type(SniperFindPacketTable) == "function" then

        packets =
            SniperFindPacketTable()
    end

    if type(packets) == "table"
    and type(SniperSafeRawGet) == "function" then

        local npcs =
            SniperSafeRawGet(
                packets,
                "NPCS"
            )

        if type(npcs) == "table" then

            local packet =
                SniperSafeRawGet(
                    npcs,
                    packetName
                )

            local okFire, fireFunction =
                pcall(function()

                    return packet.Fire
                end)

            if okFire == true
            and type(fireFunction) == "function" then

                state.Packets[packetName] =
                    packet

                return packet,
                    "packet table NPCS."
                    .. tostring(packetName)
            end
        end
    end

    -- Backup path:
    -- Some sessions expose the module directly as a descendant, not direct NPCS child.
    local sharedModules =
        ReplicatedStorage:FindFirstChild("SharedModules")

    local module =
        nil

    if sharedModules then

        for _, descendant in ipairs(sharedModules:GetDescendants()) do

            if descendant:IsA("ModuleScript")
            and descendant.Name == packetName
            and PathOf(descendant):find("NPCS", 1, true) then

                module =
                    descendant

                break
            end
        end
    end

    if not module then

        return nil,
            "NPCS packet not found: "
            .. tostring(packetName)
            .. " | source: "
            .. tostring(
                SniperState
                and SniperState.PacketSource
                or "no packet source"
            )
    end

    local okRequire, packet =
        pcall(function()

            return require(
                module
            )
        end)

    if okRequire ~= true
    or type(packet) ~= "table" then

        return nil,
            "packet require failed: "
            .. PathOf(module)
    end

    local okFire, fireFunction =
        pcall(function()

            return packet.Fire
        end)

    if okFire ~= true
    or type(fireFunction) ~= "function" then

        return nil,
            "packet Fire missing: "
            .. PathOf(module)
    end

    state.Packets[packetName] =
        packet

    return packet,
        "module descendant: "
        .. PathOf(module)
end

function GAG2AutoSellFirePacket(packetName, ...)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    local packet, reason =
        GAG2AutoSellResolvePacket(
            packetName
        )

    if not packet then

        GAG2AutoSellSetStatus(
            "Sell packet missing: "
            .. tostring(reason)
        )

        warn(
            "[HOLY GAG2 AUTO SELL]",
            "packet missing",
            tostring(packetName),
            tostring(reason)
        )

        return false,
            reason
    end

    local args =
        {
            ...
        }

    local repeatCount =
        GAG2AutoSellGetRepeatCount()

    local fired =
        0

    local lastError =
        nil

    for index = 1, repeatCount do

        local ok, err =
            pcall(function()

                packet:Fire(
                    table.unpack(args)
                )
            end)

        if ok ~= true then

            ok, err =
                pcall(function()

                    packet.Fire(
                        packet,
                        table.unpack(args)
                    )
                end)
        end

        if ok == true then

            fired += 1

        else

            lastError =
                err
        end
    end

    if fired <= 0 then

        GAG2AutoSellSetStatus(
            "Sell failed: "
            .. tostring(lastError)
        )

        warn(
            "[HOLY GAG2 AUTO SELL]",
            "fire failed",
            tostring(packetName),
            tostring(lastError)
        )

        return false,
            tostring(lastError)
    end

    local now =
        os.clock()

    if packetName == "SellAll" then

        state.LastSellAllAt =
            now

    elseif packetName == "SellFruit" then

        state.LastSellFruitAt =
            now
    end

    state.LastMethod =
        tostring(packetName)
        .. " x"
        .. tostring(fired)

    GAG2AutoSellSetStatus(
        "Fired "
        .. tostring(packetName)
        .. " x"
        .. tostring(fired)
        .. " | "
        .. tostring(reason)
    )

    return true,
        "fired x"
        .. tostring(fired)
end

function GAG2AutoSellIsFruitTool(tool)

    if typeof(tool) ~= "Instance"
    or tool:IsA("Tool") ~= true then
        return false,
            "",
            ""
    end

    local harvested =
        tool:GetAttribute("HarvestedFruit")

    local fruitId =
        GAG2AutoSellClean(
            tool:GetAttribute("Id")
        )

    local fruitName =
        GAG2AutoSellClean(
            tool:GetAttribute("FruitName")
            or tool:GetAttribute("Fruit")
        )

    if harvested == true
    and fruitId ~= "" then

        return true,
            fruitId,
            fruitName
    end

    return false,
        "",
        fruitName
end

function GAG2AutoSellScheduleSellAll(reason)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    if state.Enabled ~= true then
        return
    end

    if state.Method ~= "SellAll" then
        return
    end

    if state.SellAllPending == true then
        return
    end

    state.SellAllPending =
        true

    local preset =
        GAG2AutoSellGetPreset()

    local debounce =
        math.clamp(
            tonumber(preset.SellAllDebounce)
            or 0.07,
            0.01,
            1
        )

    task.delay(debounce, function()

        state.SellAllPending =
            false

        if state.Enabled ~= true then
            return
        end

        if state.Method ~= "SellAll" then
            return
        end

        GAG2AutoSellFirePacket(
            "SellAll"
        )
    end)

    GAG2AutoSellSetStatus(
        "SellAll queued: "
        .. tostring(reason or "fruit")
    )
end

function GAG2AutoSellQueueFruitId(fruitId, fruitName)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    fruitId =
        GAG2AutoSellClean(fruitId)

    fruitName =
        GAG2AutoSellClean(fruitName)

    if fruitId == "" then
        return
    end

    state.Queue =
        type(state.Queue) == "table"
        and state.Queue
        or {}

    state.QueueMap =
        type(state.QueueMap) == "table"
        and state.QueueMap
        or {}

    if state.QueueMap[fruitId] == true then
        return
    end

    state.QueueMap[fruitId] =
        true

    table.insert(state.Queue, {
        Id = fruitId,
        Name = fruitName,
    })

    state.LastFruitId =
        fruitId

    state.LastFruitName =
        fruitName

    GAG2AutoSellStartWorker()
end

function GAG2AutoSellStartWorker()

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    if state.Running == true then
        return
    end

    state.Running =
        true

    task.spawn(function()

        while state.Enabled == true
        and state.Method == "SellFruit"
        and type(state.Queue) == "table"
        and #state.Queue > 0 do

            local preset =
                GAG2AutoSellGetPreset()

            local burst =
                math.clamp(
                    math.floor(
                        tonumber(preset.SellFruitBurst)
                        or 25
                    ),
                    1,
                    100
                )

            local yieldEvery =
                math.max(
                    1,
                    math.floor(
                        tonumber(preset.YieldEvery)
                        or 18
                    )
                )

            local fired =
                0

            while fired < burst
            and #state.Queue > 0
            and state.Enabled == true
            and state.Method == "SellFruit" do

                local item =
                    table.remove(
                        state.Queue,
                        1
                    )

                if item
                and item.Id then

                    state.QueueMap[item.Id] =
                        nil

                    GAG2AutoSellFirePacket(
                        "SellFruit",
                        item.Id
                    )

                    state.LastFruitId =
                        item.Id

                    state.LastFruitName =
                        tostring(item.Name or "")

                    fired += 1

                    if fired % yieldEvery == 0 then
                        task.wait()
                    end
                end
            end

            local waitTime =
                math.clamp(
                    tonumber(preset.SellFruitCycleWait)
                    or 0.015,
                    0,
                    1
                )

            if waitTime > 0 then

                task.wait(
                    waitTime
                )

            else

                task.wait()
            end
        end

        state.Running =
            false
    end)
end

function GAG2AutoSellHandleFruitTool(tool, reason)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    if state.Enabled ~= true then
        return false
    end

    local isFruit, fruitId, fruitName =
        GAG2AutoSellIsFruitTool(
            tool
        )

    if isFruit ~= true then
        return false
    end

    local now =
        os.clock()

    local recent =
        tonumber(
            state.RecentFruitIds[fruitId]
        )
        or 0

    if now - recent < 0.18 then
        return false
    end

    state.RecentFruitIds[fruitId] =
        now

    state.LastTriggerAt =
        now

    state.LastFruitId =
        fruitId

    state.LastFruitName =
        fruitName

    if state.Method == "SellFruit" then

        GAG2AutoSellQueueFruitId(
            fruitId,
            fruitName
        )

    else

        GAG2AutoSellScheduleSellAll(
            reason or fruitName or "fruit"
        )
    end

    return true
end

function GAG2AutoSellScanExistingFruitTools(reason)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    if state.Enabled ~= true then
        return 0
    end

    local found =
        0

    local function scanContainer(container)

        if typeof(container) ~= "Instance" then
            return
        end

        for _, child in ipairs(container:GetChildren()) do

            if child:IsA("Tool") then

                if GAG2AutoSellHandleFruitTool(
                    child,
                    reason or "scan"
                ) == true then

                    found += 1
                end
            end
        end
    end

    local backpack =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChild("Backpack")

    scanContainer(
        backpack
    )

    scanContainer(
        LOCAL_PLAYER and LOCAL_PLAYER.Character
    )

    if found > 0 then

        GAG2AutoSellSetStatus(
            "Detected "
            .. tostring(found)
            .. " fruit tool(s)."
        )
    end

    return found
end

function GAG2AutoSellHookCharacter(character)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    if typeof(character) ~= "Instance" then
        return
    end

    local connection =
        character.ChildAdded:Connect(function(child)

            if state.Enabled ~= true then
                return
            end

            if child:IsA("Tool") then

                task.defer(function()

                    GAG2AutoSellHandleFruitTool(
                        child,
                        "character"
                    )
                end)
            end
        end)

    table.insert(
        state.Connections,
        connection
    )
end

function GAG2AutoSellStartWatcher()

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    if state.Started == true then
        return
    end

    state.Started =
        true

    state.Connections =
        type(state.Connections) == "table"
        and state.Connections
        or {}

    local backpack =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChild("Backpack")
        or LOCAL_PLAYER
        and LOCAL_PLAYER:WaitForChild("Backpack", 10)

    if backpack then

        table.insert(
            state.Connections,
            backpack.ChildAdded:Connect(function(child)

                if state.Enabled ~= true then
                    return
                end

                if child:IsA("Tool") then

                    task.defer(function()

                        GAG2AutoSellHandleFruitTool(
                            child,
                            "backpack"
                        )
                    end)
                end
            end)
        )
    end

    GAG2AutoSellHookCharacter(
        LOCAL_PLAYER.Character
    )

    table.insert(
        state.Connections,
        LOCAL_PLAYER.CharacterAdded:Connect(function(character)

            task.wait(
                0.35
            )

            GAG2AutoSellHookCharacter(
                character
            )

            if state.Enabled == true then

                GAG2AutoSellScanExistingFruitTools(
                    "respawn"
                )
            end
        end)
    )
end

function GAG2AutoSellSetEnabled(value)

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    state.Enabled =
        value == true

    GAG2AutoSellStartWatcher()

    if state.Enabled == true then

        GAG2AutoSellSetStatus(
            "Auto Sell enabled."
        )

        task.defer(function()

            GAG2AutoSellScanExistingFruitTools(
                "enable"
            )
        end)

    else

        GAG2AutoSellSetStatus(
            "Auto Sell disabled."
        )
    end

    MarkConfigDirty()
end

function GAG2AutoSellSetMethod(value)

    value =
        GAG2AutoSellClean(value)

    if table.find(GAG2_AUTO_SELL_METHOD_VALUES, value) == nil then
        value =
            "SellAll"
    end

    GAG2_AUTO_SELL_FRUIT_STATE.Method =
        value

    GAG2_AUTO_SELL_FRUIT_STATE.Queue =
        {}

    GAG2_AUTO_SELL_FRUIT_STATE.QueueMap =
        {}

    if GAG2_AUTO_SELL_FRUIT_STATE.Enabled == true then

        task.defer(function()

            GAG2AutoSellScanExistingFruitTools(
                "method changed"
            )
        end)
    end

    GAG2AutoSellSetStatus(
        "Method set: "
        .. tostring(value)
    )

    MarkConfigDirty()
end

function GAG2AutoSellSetSpeed(value)

    value =
        GAG2AutoSellClean(value)

    if GAG2_AUTO_SELL_SPEED_PRESETS[value] == nil then
        value =
            "Fast"
    end

    GAG2_AUTO_SELL_FRUIT_STATE.Speed =
        value

    GAG2AutoSellSetStatus(
        "Speed set: "
        .. tostring(value)
    )

    MarkConfigDirty()
end

function GAG2AutoSellStop()

    GAG2_AUTO_SELL_FRUIT_STATE.Enabled =
        false

    GAG2_AUTO_SELL_FRUIT_STATE.Queue =
        {}

    GAG2_AUTO_SELL_FRUIT_STATE.QueueMap =
        {}

    if Toggles.HolyGAG2AutoSellFruits
    and type(Toggles.HolyGAG2AutoSellFruits.SetValue) == "function" then

        pcall(function()

            Toggles.HolyGAG2AutoSellFruits:SetValue(
                false
            )
        end)
    end

    GAG2AutoSellSetStatus(
        "Auto Sell stopped."
    )

    MarkConfigDirty()
end

function GAG2AutoSellIsEnabled()

    return type(GAG2_AUTO_SELL_FRUIT_STATE) == "table"
        and GAG2_AUTO_SELL_FRUIT_STATE.Enabled == true
end

function GAG2AutoSellHandleCollectedFruit(entry)

    if type(entry) ~= "table" then
        return false
    end

    if type(GAG2AutoSellIsEnabled) ~= "function"
    or GAG2AutoSellIsEnabled() ~= true then
        return false
    end

    local state =
        GAG2_AUTO_SELL_FRUIT_STATE

    local method =
        tostring(state.Method or "SellAll")

    if method == "SellFruit" then

        local fruitId =
            GAG2AutoSellClean(
                entry.FruitId
                or entry.Key
            )

        if fruitId == ""
        or fruitId:find("%.") then
            return false
        end

        task.delay(0.05, function()

            if GAG2AutoSellIsEnabled() == true
            and GAG2_AUTO_SELL_FRUIT_STATE.Method == "SellFruit" then

                GAG2AutoSellQueueFruitId(
                    fruitId,
                    tostring(entry.Name or "")
                )
            end
        end)

        return true
    end

    if method == "SellAll" then

        GAG2AutoSellScheduleSellAll(
            "collected "
            .. tostring(entry.Name or "fruit")
        )

        return true
    end

    return false
end

function GAG2AutoSellExposeDebug()

    getgenv().HOLY_GAG2_AUTO_SELL_STATE =
        GAG2_AUTO_SELL_FRUIT_STATE

    getgenv().HOLY_GAG2_AUTO_SELL_FIRE_ALL =
        function()

            return GAG2AutoSellFirePacket(
                "SellAll"
            )
        end

    getgenv().HOLY_GAG2_AUTO_SELL_FIRE_FRUIT =
        function(fruitId)

            return GAG2AutoSellFirePacket(
                "SellFruit",
                fruitId
            )
        end

    getgenv().HOLY_GAG2_AUTO_SELL_ENABLE =
        function(value)

            return GAG2AutoSellSetEnabled(
                value ~= false
            )
        end

    getgenv().HOLY_GAG2_AUTO_SELL_RESOLVE =
        function(packetName)

            return GAG2AutoSellResolvePacket(
                packetName or "SellAll"
            )
        end
end

function GAG2RestoreAutoSellState()

    task.defer(function()

        local state =
            GAG2_AUTO_SELL_FRUIT_STATE

        GAG2AutoSellExposeDebug()

        GAG2AutoSellStartWatcher()

        if Options.HolyGAG2AutoSellMethod then

            GAG2AutoSellSetMethod(
                Options.HolyGAG2AutoSellMethod.Value
            )
        end

        if Options.HolyGAG2AutoSellSpeed then

            GAG2AutoSellSetSpeed(
                Options.HolyGAG2AutoSellSpeed.Value
            )
        end

        if Options.HolyGAG2AutoSellRepeatCount then

            GAG2AutoSellSetRepeatCount(
                Options.HolyGAG2AutoSellRepeatCount.Value
            )
        end

        if Toggles.HolyGAG2AutoSellFruits then

            state.Enabled =
                Toggles.HolyGAG2AutoSellFruits.Value == true
        end

        if state.Enabled == true then

            GAG2AutoSellSetStatus(
                "Auto Sell restored."
            )

            GAG2AutoSellScanExistingFruitTools(
                "restore"
            )

        else

            GAG2AutoSellSetStatus(
                "Idle."
            )
        end
    end)
end

--==================================================
-- [4.58] SEED PLANTING
-- Continuous stack/grid seed planting.
--==================================================

GAG2_SEED_PLANTING_STATE =
    GAG2_SEED_PLANTING_STATE
    or {
        Enabled = false,
        Running = false,

        SelectedSeeds = {},

        Layout = "Stack",
        Direction = "Down",

        Amount = 20,
        LayerSpacing = 0.35,
        PlantDelay = 0.1,

        GridWidth = 5,
        GridDepth = 4,
        GridLayers = 1,
        GridSpacing = 1.25,

        CycleDelay = 0.1,

        PlantLocalOffset = nil,
        PointLoaded = false,

        PlantSeedPacket = nil,
        PacketSource = "not loaded",

        LastStatus = "Idle.",
        LastFired = 0,
        LastSeed = "",
        LastFailure = "",
    }

GAG2_SEED_PLANTING_CONTROLS =
    GAG2_SEED_PLANTING_CONTROLS
    or {}

GAG2_SEED_PLANTING_POINT_FILE =
    UI_SETTINGS_FOLDER
    .. "/SeedPlantPoint_"
    .. tostring(LOCAL_PLAYER.UserId)
    .. ".json"

GAG2_SEED_PLANTING_LAYOUT_VALUES = {
    "Stack",
    "Grid",
}

GAG2_SEED_PLANTING_DIRECTION_VALUES = {
    "Up",
    "Down",
    "Both",
}

function GAG2SeedPlantClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2SeedPlantGetSeedData()

    if type(GAG2ACFSafeRequire) == "function" then

        local seedData =
            GAG2ACFSafeRequire(
                "SeedData"
            )

        if type(seedData) == "table" then
            return seedData
        end
    end

    local sharedModules =
        ReplicatedStorage:FindFirstChild(
            "SharedModules"
        )

    local seedModule =
        sharedModules
        and sharedModules:FindFirstChild(
            "SeedData",
            true
        )

    if not seedModule
    or seedModule:IsA("ModuleScript") ~= true then

        return nil
    end

    local ok, result =
        pcall(function()

            return require(
                seedModule
            )
        end)

    if ok == true
    and type(result) == "table" then

        return result
    end

    return nil
end

function GAG2SeedPlantBuildValidSeedMap()

    local seedMap =
        {}

    local lowerMap =
        {}

    local ordered =
        {}

    local seedData =
        GAG2SeedPlantGetSeedData()

    if type(seedData) ~= "table" then

        return seedMap,
            ordered,
            lowerMap
    end

    for _, row in pairs(seedData) do

        if type(row) == "table"
        and type(row.SeedName) == "string" then

            local seedName =
                GAG2SeedPlantClean(
                    row.SeedName
                )

            if seedName ~= ""
            and seedMap[seedName] ~= true then

                seedMap[seedName] =
                    true

                lowerMap[seedName:lower()] =
                    seedName

                table.insert(
                    ordered,
                    seedName
                )
            end
        end
    end

    table.sort(
        ordered,
        function(a, b)

            return tostring(a):lower()
                < tostring(b):lower()
        end
    )

    return seedMap,
        ordered,
        lowerMap
end

function GAG2SeedPlantResolveValidSeedName(seedName)

    seedName =
        GAG2ShopCleanItemName(
            seedName
        )

    seedName =
        GAG2SeedPlantClean(
            seedName
        )

    if seedName == "" then
        return ""
    end

    local seedMap, _, lowerMap =
        GAG2SeedPlantBuildValidSeedMap()

    if seedMap[seedName] == true then
        return seedName
    end

    local resolved =
        lowerMap[
            seedName:lower()
        ]

    if resolved then
        return resolved
    end

    return ""
end

function GAG2SeedPlantIsValidSeedName(seedName)

    return GAG2SeedPlantResolveValidSeedName(
        seedName
    ) ~= ""
end

function GAG2SeedPlantReadRealSeedNameFromTool(tool)

    if typeof(tool) ~= "Instance"
    or tool:IsA("Tool") ~= true then

        return ""
    end

    local mainCategory =
        GAG2SeedPlantClean(
            tool:GetAttribute("MainCategory")
        )

    if mainCategory:lower() ~= "seed" then
        return ""
    end

    local seedTool =
        GAG2SeedPlantClean(
            tool:GetAttribute("SeedTool")
        )

    if seedTool == "" then
        return ""
    end

    return GAG2SeedPlantResolveValidSeedName(
        seedTool
    )
end

function GAG2SeedPlantIsRealSeedTool(tool, seedName)

    local wantedSeed =
        GAG2SeedPlantResolveValidSeedName(
            seedName
        )

    if wantedSeed == "" then
        return false
    end

    local toolSeed =
        GAG2SeedPlantReadRealSeedNameFromTool(
            tool
        )

    return toolSeed == wantedSeed
end

function GAG2SeedPlantClampInt(value, defaultValue, minValue, maxValue)

    local number =
        math.floor(
            tonumber(value)
            or tonumber(defaultValue)
            or 0
        )

    return math.clamp(
        number,
        tonumber(minValue) or number,
        tonumber(maxValue) or number
    )
end

function GAG2SeedPlantClampNumber(value, defaultValue, minValue, maxValue)

    local number =
        tonumber(value)
        or tonumber(defaultValue)
        or 0

    return math.clamp(
        number,
        tonumber(minValue) or number,
        tonumber(maxValue) or number
    )
end

function GAG2SeedPlantSetStatus(text)

    local state =
        GAG2_SEED_PLANTING_STATE

    state.LastStatus =
        tostring(text or "Idle.")

    local statusText =
        '<font color="rgb(196,181,253)"><b>Status:</b></font> '
        .. state.LastStatus
        .. '\n'
        .. '<font color="rgb(148,163,184)">'
        .. tostring(state.Layout or "Stack")
        .. ' / '
        .. tostring(state.Direction or "Down")
        .. ' | Amount: '
        .. tostring(state.Amount or 20)
        .. ' | Delay: '
        .. tostring(state.PlantDelay or 0.1)
        .. 's'
        .. '</font>'

    if GAG2_SEED_PLANTING_CONTROLS
    and GAG2_SEED_PLANTING_CONTROLS.Status
    and type(GAG2_SEED_PLANTING_CONTROLS.Status.SetText) == "function" then

        GAG2_SEED_PLANTING_CONTROLS.Status:SetText(
            statusText
        )

        return
    end

    if Options.HolyGAG2FarmStatus then

        Options.HolyGAG2FarmStatus:SetText(
            '<font color="rgb(196,181,253)"><b>Seed Planting</b></font>'
            .. '\n'
            .. state.LastStatus
            .. '\nLayout: '
            .. tostring(state.Layout)
            .. ' | Direction: '
            .. tostring(state.Direction)
            .. ' | Amount/Cycle: '
            .. tostring(state.Amount)
            .. ' | Delay: '
            .. tostring(state.PlantDelay or 0.1)
            .. 's'
            .. '\nPacket: '
            .. tostring(state.PacketSource or "not loaded")
        )
    end
end

function GAG2SeedPlantBuildValidSeedMap()

    local seedMap =
        {}

    local ordered =
        {}

    local function add(seedName)

        seedName =
            GAG2SeedPlantClean(
                seedName
            )

        if seedName == "" then
            return
        end

        if seedMap[seedName] == true then
            return
        end

        seedMap[seedName] =
            true

        table.insert(
            ordered,
            seedName
        )
    end

    local seedData =
        GAG2ACFSafeRequire
        and GAG2ACFSafeRequire("SeedData")
        or nil

    if type(seedData) == "table" then

        for _, row in pairs(seedData) do

            if type(row) == "table"
            and type(row.SeedName) == "string" then

                add(
                    row.SeedName
                )
            end
        end
    end

    -- Safe fallback only. These are real seeds, not gear.
    add("Carrot")
    add("Strawberry")
    add("Blueberry")
    add("Tulip")
    add("Tomato")
    add("Apple")
    add("Bamboo")
    add("Corn")
    add("Cactus")
    add("Pineapple")
    add("Mushroom")
    add("Green Bean")
    add("Banana")
    add("Grape")
    add("Coconut")
    add("Mango")
    add("Dragon Fruit")
    add("Acorn")
    add("Cherry")
    add("Sunflower")
    add("Venus Fly Trap")
    add("Pomegranate")
    add("Poison Apple")
    add("Moon Bloom")
    add("Dragon's Breath")
    add("Ghost Pepper")
    add("Poison Ivy")
    add("Baby Cactus")
    add("Glow Mushroom")
    add("Romanesco")
    add("Horned Melon")
    add("Gold")
    add("Rainbow")

    table.sort(
        ordered,
        function(a, b)

            return tostring(a):lower()
                < tostring(b):lower()
        end
    )

    return seedMap,
        ordered
end

function GAG2SeedPlantIsValidSeedName(seedName)

    seedName =
        GAG2SeedPlantClean(
            seedName
        )

    if seedName == "" then
        return false
    end

    local seedMap =
        GAG2SeedPlantBuildValidSeedMap()

    return seedMap[seedName] == true
end

function GAG2SeedPlantReadRealSeedNameFromTool(tool)

    if typeof(tool) ~= "Instance"
    or tool:IsA("Tool") ~= true then

        return ""
    end

    local mainCategory =
        GAG2SeedPlantClean(
            tool:GetAttribute("MainCategory")
        )

    local seedTool =
        GAG2SeedPlantClean(
            tool:GetAttribute("SeedTool")
        )

    -- Strict rule:
    -- Real plantable seed tools must expose MainCategory = Seed and SeedTool.
    -- This blocks Supersize Mushroom, Speed Mushroom, Gnome, Sprinklers, Trowel, etc.
    if mainCategory:lower() ~= "seed" then
        return ""
    end

    if seedTool == "" then
        return ""
    end

    if GAG2SeedPlantIsValidSeedName(seedTool) ~= true then
        return ""
    end

    return seedTool
end

function GAG2SeedPlantIsRealSeedTool(tool, seedName)

    seedName =
        GAG2SeedPlantClean(
            seedName
        )

    if seedName == "" then
        return false
    end

    return GAG2SeedPlantReadRealSeedNameFromTool(tool) == seedName
end

function GAG2SeedPlantNormalizeSelection(value)

    local result =
        {}

    local function add(itemName)

        local seedName =
            GAG2SeedPlantResolveValidSeedName(
                itemName
            )

        if seedName == "" then
            return
        end

        if table.find(result, seedName) ~= nil then
            return
        end

        table.insert(
            result,
            seedName
        )
    end

    if type(value) == "table" then

        for _, itemName in ipairs(value) do
            add(itemName)
        end

        for itemName, enabled in pairs(value) do

            if enabled == true then
                add(itemName)
            end
        end

    elseif type(value) == "string" then

        add(value)
    end

    table.sort(
        result
    )

    return result
end

function GAG2SeedPlantGetSeedValues()

    local seedMap, orderedSeeds =
        GAG2SeedPlantBuildValidSeedMap()

    local values =
        {}

    local seen =
        {}

    local function addValue(seedName, displayName)

        seedName =
            GAG2SeedPlantResolveValidSeedName(
                seedName
            )

        if seedName == "" then
            return
        end

        if seedMap[seedName] ~= true then
            return
        end

        if seen[seedName] == true then
            return
        end

        seen[seedName] =
            true

        table.insert(
            values,
            tostring(displayName or seedName)
        )
    end

    local shopSeedValues =
        GAG2ShopGetItemNames(
            "Seeds"
        )

    if type(shopSeedValues) == "table" then

        for _, displayName in ipairs(shopSeedValues) do

            local seedName =
                GAG2ShopCleanItemName(
                    displayName
                )

            addValue(
                seedName,
                displayName
            )
        end
    end

    for _, seedName in ipairs(orderedSeeds or {}) do

        addValue(
            seedName,
            seedName
        )
    end

    table.sort(
        values,
        function(a, b)

            return tostring(a):lower()
                < tostring(b):lower()
        end
    )

    return values
end

function GAG2SeedPlantGetSelectedSeeds()

    local state =
        GAG2_SEED_PLANTING_STATE

    local selected =
        GAG2SeedPlantNormalizeSelection(
            state.SelectedSeeds
        )

    if #selected > 0 then
        return selected
    end

    local shopSelected =
        GAG2_SHOP_STATE
        and GAG2_SHOP_STATE.Selected
        and GAG2_SHOP_STATE.Selected.Seeds

    if type(shopSelected) == "table" then

        selected =
            GAG2SeedPlantNormalizeSelection(
                shopSelected
            )

        if #selected > 0 then
            return selected
        end
    end

    return {}
end

function GAG2SeedPlantSetSelectedSeeds(value)

    GAG2_SEED_PLANTING_STATE.SelectedSeeds =
        GAG2SeedPlantNormalizeSelection(
            value
        )

    GAG2SeedPlantSetStatus(
        "Selected seeds: "
        .. (
            #GAG2_SEED_PLANTING_STATE.SelectedSeeds > 0
            and table.concat(
                GAG2_SEED_PLANTING_STATE.SelectedSeeds,
                ", "
            )
            or "None"
        )
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetLayout(value)

    value =
        GAG2SeedPlantClean(
            value
        )

    if table.find(GAG2_SEED_PLANTING_LAYOUT_VALUES, value) == nil then
        value = "Stack"
    end

    GAG2_SEED_PLANTING_STATE.Layout =
        value

    GAG2SeedPlantSetStatus(
        "Layout set: "
        .. value
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetDirection(value)

    value =
        GAG2SeedPlantClean(
            value
        )

    if table.find(GAG2_SEED_PLANTING_DIRECTION_VALUES, value) == nil then
        value = "Down"
    end

    GAG2_SEED_PLANTING_STATE.Direction =
        value

    GAG2SeedPlantSetStatus(
        "Direction set: "
        .. value
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetAmount(value)

    GAG2_SEED_PLANTING_STATE.Amount =
        GAG2SeedPlantClampInt(
            value,
            20,
            1,
            500
        )

    GAG2SeedPlantSetStatus(
        "Plant amount per cycle: "
        .. tostring(GAG2_SEED_PLANTING_STATE.Amount)
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetLayerSpacing(value)

    GAG2_SEED_PLANTING_STATE.LayerSpacing =
        GAG2SeedPlantClampNumber(
            value,
            0.35,
            0.01,
            10
        )

    GAG2SeedPlantSetStatus(
        "Layer spacing: "
        .. tostring(GAG2_SEED_PLANTING_STATE.LayerSpacing)
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetPlantDelay(value)

    GAG2_SEED_PLANTING_STATE.PlantDelay =
        GAG2SeedPlantClampNumber(
            value,
            0.1,
            0,
            5
        )

    GAG2SeedPlantSetStatus(
        "Plant delay: "
        .. tostring(GAG2_SEED_PLANTING_STATE.PlantDelay)
        .. "s"
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetGridWidth(value)

    GAG2_SEED_PLANTING_STATE.GridWidth =
        GAG2SeedPlantClampInt(
            value,
            5,
            1,
            50
        )

    GAG2SeedPlantSetStatus(
        "Grid width: "
        .. tostring(GAG2_SEED_PLANTING_STATE.GridWidth)
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetGridDepth(value)

    GAG2_SEED_PLANTING_STATE.GridDepth =
        GAG2SeedPlantClampInt(
            value,
            4,
            1,
            50
        )

    GAG2SeedPlantSetStatus(
        "Grid depth: "
        .. tostring(GAG2_SEED_PLANTING_STATE.GridDepth)
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetGridLayers(value)

    GAG2_SEED_PLANTING_STATE.GridLayers =
        GAG2SeedPlantClampInt(
            value,
            1,
            1,
            100
        )

    GAG2SeedPlantSetStatus(
        "Grid layers: "
        .. tostring(GAG2_SEED_PLANTING_STATE.GridLayers)
    )

    MarkConfigDirty()
end

function GAG2SeedPlantSetGridSpacing(value)

    GAG2_SEED_PLANTING_STATE.GridSpacing =
        GAG2SeedPlantClampNumber(
            value,
            1.25,
            0.1,
            30
        )

    GAG2SeedPlantSetStatus(
        "Grid spacing: "
        .. tostring(GAG2_SEED_PLANTING_STATE.GridSpacing)
    )

    MarkConfigDirty()
end

function GAG2SeedPlantVectorToPayload(vector)

    if typeof(vector) ~= "Vector3" then
        return nil
    end

    return {
        X = vector.X,
        Y = vector.Y,
        Z = vector.Z,
    }
end

function GAG2SeedPlantVectorFromPayload(payload)

    if type(payload) ~= "table" then
        return nil
    end

    local x =
        tonumber(payload.X)
        or tonumber(payload.x)
        or tonumber(payload[1])

    local y =
        tonumber(payload.Y)
        or tonumber(payload.y)
        or tonumber(payload[2])

    local z =
        tonumber(payload.Z)
        or tonumber(payload.z)
        or tonumber(payload[3])

    if x
    and y
    and z then

        return Vector3.new(
            x,
            y,
            z
        )
    end

    return nil
end

function GAG2SeedPlantSavePoint(localOffset)

    if typeof(localOffset) ~= "Vector3" then
        return false
    end

    GAG2_SEED_PLANTING_STATE.PlantLocalOffset =
        localOffset

    GAG2_SEED_PLANTING_STATE.PointLoaded =
        true

    if CanUseUISettingsFile() ~= true then
        return false
    end

    EnsureUISettingsFolder()

    local payload = {
        LocalOffset =
            GAG2SeedPlantVectorToPayload(
                localOffset
            ),

        SavedAt =
            os.time(),
    }

    local ok, encoded =
        pcall(function()

            return HttpService:JSONEncode(
                payload
            )
        end)

    if ok ~= true
    or type(encoded) ~= "string" then
        return false
    end

    local writeOk =
        pcall(function()

            writefile(
                GAG2_SEED_PLANTING_POINT_FILE,
                encoded
            )
        end)

    return writeOk == true
end

function GAG2SeedPlantLoadPoint()

    local state =
        GAG2_SEED_PLANTING_STATE

    if state.PointLoaded == true then
        return typeof(state.PlantLocalOffset) == "Vector3"
    end

    state.PointLoaded =
        true

    if CanUseUISettingsFile() ~= true then
        return false
    end

    local exists =
        false

    pcall(function()

        exists =
            isfile(
                GAG2_SEED_PLANTING_POINT_FILE
            )
    end)

    if exists ~= true then
        return false
    end

    local readOk, raw =
        pcall(function()

            return readfile(
                GAG2_SEED_PLANTING_POINT_FILE
            )
        end)

    if readOk ~= true
    or type(raw) ~= "string"
    or raw == "" then
        return false
    end

    local decodeOk, payload =
        pcall(function()

            return HttpService:JSONDecode(
                raw
            )
        end)

    if decodeOk ~= true
    or type(payload) ~= "table" then
        return false
    end

    local localOffset =
        GAG2SeedPlantVectorFromPayload(
            payload.LocalOffset
        )

    if typeof(localOffset) ~= "Vector3" then
        return false
    end

    state.PlantLocalOffset =
        localOffset

    return true
end

function GAG2SeedPlantGetPlotFrame(plot)

    if typeof(plot) ~= "Instance" then
        return nil
    end

    local okPivot, pivot =
        pcall(function()

            return plot:GetPivot()
        end)

    if okPivot == true
    and typeof(pivot) == "CFrame" then
        return pivot
    end

    local okBox, cframe =
        pcall(function()

            return plot:GetBoundingBox()
        end)

    if okBox == true
    and typeof(cframe) == "CFrame" then
        return cframe
    end

    return nil
end

function GAG2SeedPlantBuildRaycastParams(ownPlot)

    local filter =
        {}

    if LOCAL_PLAYER
    and LOCAL_PLAYER.Character then

        table.insert(
            filter,
            LOCAL_PLAYER.Character
        )
    end

    local plantsFolder =
        ownPlot
        and ownPlot:FindFirstChild("Plants")

    if plantsFolder then

        table.insert(
            filter,
            plantsFolder
        )
    end

    local params =
        RaycastParams.new()

    params.FilterType =
        Enum.RaycastFilterType.Exclude

    params.FilterDescendantsInstances =
        filter

    params.IgnoreWater =
        true

    return params
end

function GAG2SeedPlantIsValidPlotHit(result, ownPlot)

    if typeof(result) ~= "RaycastResult" then
        return false,
            "no raycast result"
    end

    if typeof(ownPlot) ~= "Instance" then
        return false,
            "own plot missing"
    end

    local hit =
        result.Instance

    if typeof(hit) ~= "Instance" then
        return false,
            "hit missing"
    end

    if hit:IsDescendantOf(ownPlot) ~= true then

        return false,
            "outside own plot: "
            .. PathOf(hit)
    end

    local path =
        PathOf(hit)

    if path:find("%.Plants%.") then

        return false,
            "hit plant: "
            .. path
    end

    if hit.Name == "GardenZonePart" then
        return false,
            "GardenZonePart"
    end

    return true,
        path
end

function GAG2SeedPlantRaycastGround(roughPosition, ownPlot)

    if typeof(roughPosition) ~= "Vector3" then
        return nil,
            "missing rough position"
    end

    local result =
        workspace:Raycast(
            roughPosition + Vector3.new(0, 18, 0),
            Vector3.new(0, -120, 0),
            GAG2SeedPlantBuildRaycastParams(
                ownPlot
            )
        )

    local valid, reason =
        GAG2SeedPlantIsValidPlotHit(
            result,
            ownPlot
        )

    if valid ~= true then
        return nil,
            reason
    end

    return result.Position,
        reason
end

function GAG2SeedPlantSetPointFromCurrentPosition()

    local ownPlot, plotReason =
        GAG2ResolveOwnFarmPlot()

    if not ownPlot then

        GAG2SeedPlantSetStatus(
            "Could not resolve own garden: "
            .. tostring(plotReason)
        )

        Notify(
            "Seed Planting",
            "Could not resolve your garden.",
            4
        )

        return false
    end

    local plotFrame =
        GAG2SeedPlantGetPlotFrame(
            ownPlot
        )

    if typeof(plotFrame) ~= "CFrame" then

        GAG2SeedPlantSetStatus(
            "Could not resolve plot frame."
        )

        Notify(
            "Seed Planting",
            "Could not resolve plot frame.",
            4
        )

        return false
    end

    local _, root =
        SniperGetCharacterRoot()

    if not root then

        GAG2SeedPlantSetStatus(
            "Character root missing."
        )

        Notify(
            "Seed Planting",
            "Character root missing.",
            4
        )

        return false
    end

    local groundPosition, groundReason =
        GAG2SeedPlantRaycastGround(
            root.Position,
            ownPlot
        )

    if typeof(groundPosition) ~= "Vector3" then

        GAG2SeedPlantSetStatus(
            "Invalid plant point: "
            .. tostring(groundReason)
        )

        Notify(
            "Seed Planting",
            "Stand inside your garden before setting point.",
            4
        )

        return false
    end

    local localOffset =
        plotFrame:PointToObjectSpace(
            groundPosition
        )

    GAG2SeedPlantSavePoint(
        localOffset
    )

    GAG2SeedPlantSetStatus(
        "Plant point saved: "
        .. tostring(groundReason)
    )

    Notify(
        "Seed Planting",
        "Plant point saved.",
        3
    )

    return true
end

function GAG2SeedPlantGetBasePosition()

    GAG2SeedPlantLoadPoint()

    local localOffset =
        GAG2_SEED_PLANTING_STATE.PlantLocalOffset

    if typeof(localOffset) ~= "Vector3" then
        return nil,
            nil,
            "Set Plant Point first."
    end

    local ownPlot, plotReason =
        GAG2ResolveOwnFarmPlot()

    if not ownPlot then
        return nil,
            nil,
            tostring(plotReason)
    end

    local plotFrame =
        GAG2SeedPlantGetPlotFrame(
            ownPlot
        )

    if typeof(plotFrame) ~= "CFrame" then
        return nil,
            nil,
            "plot frame missing"
    end

    return plotFrame:PointToWorldSpace(
        localOffset
    ),
    ownPlot,
    "ok"
end

function GAG2SeedPlantSearchPacket(candidate, seen, depth)

    if type(candidate) ~= "table" then
        return nil
    end

    if depth > 9 then
        return nil
    end

    if seen[candidate] == true then
        return nil
    end

    seen[candidate] =
        true

    local packetName =
        tostring(
            SniperSafeRawGet(candidate, "Name")
            or ""
        )

    local okFire, fireFunction =
        pcall(function()

            return candidate.Fire
        end)

    if packetName == "PlantSeed"
    and okFire == true
    and type(fireFunction) == "function" then

        return candidate
    end

    for _, row in ipairs(SniperSafePairsSnapshot(candidate)) do

        if type(row.Value) == "table" then

            local found =
                GAG2SeedPlantSearchPacket(
                    row.Value,
                    seen,
                    depth + 1
                )

            if found then
                return found
            end
        end
    end

    return nil
end

function GAG2SeedPlantResolvePacketFromController()

    local playerScripts =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChild("PlayerScripts")

    local controller =
        playerScripts
        and playerScripts:FindFirstChild("Controllers")
        and playerScripts.Controllers:FindFirstChild("PlantController")

    if not controller then
        return nil,
            "PlantController missing"
    end

    local okRequire, plantController =
        pcall(function()

            return require(
                controller
            )
        end)

    if okRequire ~= true
    or type(plantController) ~= "table" then

        return nil,
            "PlantController require failed"
    end

    local tryPlant =
        plantController.TryPlantWithRay

    if type(tryPlant) ~= "function" then
        return nil,
            "TryPlantWithRay missing"
    end

    if type(debug) ~= "table"
    or type(debug.getupvalues) ~= "function" then

        return nil,
            "debug.getupvalues unsupported"
    end

    local okUpvalues, upvalues =
        pcall(function()

            return debug.getupvalues(
                tryPlant
            )
        end)

    if okUpvalues ~= true
    or type(upvalues) ~= "table" then

        return nil,
            "getupvalues failed"
    end

    for index, value in pairs(upvalues) do

        if type(value) == "table" then

            local plantGroup =
                SniperSafeRawGet(
                    value,
                    "Plant"
                )

            local plantSeed =
                plantGroup
                and SniperSafeRawGet(
                    plantGroup,
                    "PlantSeed"
                )

            local okFire, fireFunction =
                pcall(function()

                    return plantSeed.Fire
                end)

            if type(plantSeed) == "table"
            and SniperSafeRawGet(plantSeed, "Name") == "PlantSeed"
            and okFire == true
            and type(fireFunction) == "function" then

                return plantSeed,
                    "PlantController.TryPlantWithRay upvalue #"
                    .. tostring(index)
            end
        end
    end

    return nil,
        "PlantSeed packet not found in controller"
end

function GAG2SeedPlantFindPacket()

    local state =
        GAG2_SEED_PLANTING_STATE

    if type(state.PlantSeedPacket) == "table" then

        local okFire, fireFunction =
            pcall(function()

                return state.PlantSeedPacket.Fire
            end)

        if okFire == true
        and type(fireFunction) == "function" then

            return state.PlantSeedPacket
        end
    end

    local packets =
        SniperFindPacketTable()

    if type(packets) == "table" then

        local plantGroup =
            SniperSafeRawGet(
                packets,
                "Plant"
            )

        local plantSeed =
            plantGroup
            and SniperSafeRawGet(
                plantGroup,
                "PlantSeed"
            )

        local okFire, fireFunction =
            pcall(function()

                return plantSeed.Fire
            end)

        if type(plantSeed) == "table"
        and SniperSafeRawGet(plantSeed, "Name") == "PlantSeed"
        and okFire == true
        and type(fireFunction) == "function" then

            state.PlantSeedPacket =
                plantSeed

            state.PacketSource =
                "packet table Plant.PlantSeed"

            return plantSeed
        end

        local found =
            GAG2SeedPlantSearchPacket(
                packets,
                {},
                0
            )

        if found then

            state.PlantSeedPacket =
                found

            state.PacketSource =
                "packet table recursive PlantSeed"

            return found
        end
    end

    local controllerPacket, controllerSource =
        GAG2SeedPlantResolvePacketFromController()

    if controllerPacket then

        state.PlantSeedPacket =
            controllerPacket

        state.PacketSource =
            tostring(controllerSource)

        return controllerPacket
    end

    state.PacketSource =
        tostring(controllerSource or "PlantSeed packet missing")

    return nil
end

function GAG2SeedPlantFire(seedName, worldPosition)

    local packet =
        GAG2SeedPlantFindPacket()

    if not packet then
        return false,
            GAG2_SEED_PLANTING_STATE.PacketSource
    end

    seedName =
        GAG2SeedPlantResolveValidSeedName(
            seedName
        )

    if seedName == "" then
        return false,
            "blocked non-seed or missing SeedData entry"
    end

    if typeof(worldPosition) ~= "Vector3" then
        return false,
            "missing world position"
    end

    local ok, err =
        pcall(function()

            packet:Fire(
                worldPosition,
                seedName,
                Enum.NormalId.Top.Value
            )
        end)

    if ok ~= true then

        ok, err =
            pcall(function()

                packet.Fire(
                    packet,
                    worldPosition,
                    seedName,
                    Enum.NormalId.Top.Value
                )
            end)
    end

    if ok ~= true then
        return false,
            tostring(err)
    end

    return true,
        "fired"
end

function GAG2SeedPlantFindSeedTool(seedName)

    seedName =
        GAG2SeedPlantResolveValidSeedName(
            seedName
        )

    if seedName == "" then
        return nil
    end

    local containers = {
        LOCAL_PLAYER and LOCAL_PLAYER.Character,
        LOCAL_PLAYER and LOCAL_PLAYER:FindFirstChildOfClass("Backpack"),
    }

    for _, container in ipairs(containers) do

        if typeof(container) == "Instance" then

            for _, child in ipairs(container:GetChildren()) do

                if GAG2SeedPlantIsRealSeedTool(
                    child,
                    seedName
                ) == true then

                    return child
                end
            end
        end
    end

    return nil
end

function GAG2SeedPlantReadSeedCount(seedName)

    local tool =
        GAG2SeedPlantFindSeedTool(
            seedName
        )

    if not tool then
        return 0,
            "tool missing"
    end

    local attrNames = {
        "Count",
        "Quantity",
        "Amount",
        "Stock",
    }

    for _, attrName in ipairs(attrNames) do

        local value =
            tonumber(
                tool:GetAttribute(attrName)
            )

        if value then
            return math.max(
                0,
                math.floor(value)
            ),
            PathOf(tool)
        end
    end

    return 1,
        PathOf(tool)
end

function GAG2SeedPlantEquip(seedName)

    local tool =
        GAG2SeedPlantFindSeedTool(
            seedName
        )

    if not tool then
        return false,
            "seed tool missing"
    end

    local character =
        LOCAL_PLAYER
        and LOCAL_PLAYER.Character

    local humanoid =
        character
        and character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return false,
            "humanoid missing"
    end

    local ok, err =
        pcall(function()

            humanoid:EquipTool(
                tool
            )
        end)

    if ok ~= true then
        return false,
            tostring(err)
    end

    task.wait(
        0.05
    )

    return true,
        PathOf(tool)
end

function GAG2SeedPlantBuildLayerOffsets(count, spacing, direction)

    count =
        GAG2SeedPlantClampInt(
            count,
            1,
            1,
            500
        )

    spacing =
        GAG2SeedPlantClampNumber(
            spacing,
            0.35,
            0.01,
            10
        )

    direction =
        GAG2SeedPlantClean(
            direction
        )

    if table.find(GAG2_SEED_PLANTING_DIRECTION_VALUES, direction) == nil then
        direction = "Down"
    end

    local offsets = {
        0,
    }

    if count <= 1 then
        return offsets
    end

    if direction == "Both" then

        local step =
            1

        while #offsets < count do

            table.insert(
                offsets,
                spacing * step
            )

            if #offsets >= count then
                break
            end

            table.insert(
                offsets,
                -spacing * step
            )

            step += 1
        end

        return offsets
    end

    local sign =
        direction == "Up"
        and 1
        or -1

    for index = 1, count - 1 do

        table.insert(
            offsets,
            spacing * index * sign
        )
    end

    return offsets
end

function GAG2SeedPlantBuildStackPositions(basePosition)

    local state =
        GAG2_SEED_PLANTING_STATE

    local amount =
        GAG2SeedPlantClampInt(
            state.Amount,
            20,
            1,
            500
        )

    local offsets =
        GAG2SeedPlantBuildLayerOffsets(
            amount,
            state.LayerSpacing,
            state.Direction
        )

    local positions =
        {}

    for _, yOffset in ipairs(offsets) do

        table.insert(
            positions,
            basePosition
            + Vector3.new(
                0,
                yOffset,
                0
            )
        )

        if #positions >= amount then
            break
        end
    end

    return positions
end

function GAG2SeedPlantBuildGridPositions(basePosition, ownPlot)

    local state =
        GAG2_SEED_PLANTING_STATE

    local amount =
        GAG2SeedPlantClampInt(
            state.Amount,
            20,
            1,
            500
        )

    local width =
        GAG2SeedPlantClampInt(
            state.GridWidth,
            5,
            1,
            50
        )

    local depth =
        GAG2SeedPlantClampInt(
            state.GridDepth,
            4,
            1,
            50
        )

    local layers =
        GAG2SeedPlantClampInt(
            state.GridLayers,
            1,
            1,
            100
        )

    local gridSpacing =
        GAG2SeedPlantClampNumber(
            state.GridSpacing,
            1.25,
            0.1,
            30
        )

    local layerOffsets =
        GAG2SeedPlantBuildLayerOffsets(
            layers,
            state.LayerSpacing,
            state.Direction
        )

    local positions =
        {}

    local xStart =
        -((width - 1) * gridSpacing) / 2

    local zStart =
        -((depth - 1) * gridSpacing) / 2

    for _, layerOffset in ipairs(layerOffsets) do

        for zIndex = 1, depth do

            for xIndex = 1, width do

                if #positions >= amount then
                    return positions
                end

                local roughPosition =
                    basePosition
                    + Vector3.new(
                        xStart + ((xIndex - 1) * gridSpacing),
                        0,
                        zStart + ((zIndex - 1) * gridSpacing)
                    )

                local groundPosition =
                    GAG2SeedPlantRaycastGround(
                        roughPosition,
                        ownPlot
                    )

                if typeof(groundPosition) == "Vector3" then

                    table.insert(
                        positions,
                        groundPosition
                        + Vector3.new(
                            0,
                            layerOffset,
                            0
                        )
                    )
                end
            end
        end
    end

    return positions
end

function GAG2SeedPlantBuildPositions()

    local state =
        GAG2_SEED_PLANTING_STATE

    local basePosition, ownPlot, reason =
        GAG2SeedPlantGetBasePosition()

    if typeof(basePosition) ~= "Vector3" then
        return {},
            tostring(reason)
    end

    if state.Layout == "Grid" then

        local positions =
            GAG2SeedPlantBuildGridPositions(
                basePosition,
                ownPlot
            )

        if #positions <= 0 then
            return {},
                "no valid grid positions"
        end

        return positions,
            "grid"
    end

    return GAG2SeedPlantBuildStackPositions(
        basePosition
    ),
    "stack"
end

function GAG2SeedPlantFireCycle()

    local state =
        GAG2_SEED_PLANTING_STATE

    local selectedSeeds =
        GAG2SeedPlantGetSelectedSeeds()

    if #selectedSeeds <= 0 then

        GAG2SeedPlantSetStatus(
            "Select seeds to plant, or select Auto Buy seed items."
        )

        return 0
    end

    local positions, positionReason =
        GAG2SeedPlantBuildPositions()

    if #positions <= 0 then

        GAG2SeedPlantSetStatus(
            "No valid positions: "
            .. tostring(positionReason)
        )

        return 0
    end

    local amount =
        GAG2SeedPlantClampInt(
            state.Amount,
            20,
            1,
            500
        )

    local fired =
        0

    local waitingSeed =
        ""

    for _, seedName in ipairs(selectedSeeds) do

        if state.Enabled ~= true then
            break
        end

        if fired >= amount then
            break
        end

        seedName =
            GAG2SeedPlantClean(
                seedName
            )

        if seedName ~= "" then

            local count =
                GAG2SeedPlantReadSeedCount(
                    seedName
                )

            if count <= 0 then

                if waitingSeed == "" then
                    waitingSeed = seedName
                end

            else

                local equipOk, equipInfo =
                    GAG2SeedPlantEquip(
                        seedName
                    )

                if equipOk ~= true then

                    state.LastFailure =
                        tostring(equipInfo)

                    GAG2SeedPlantSetStatus(
                        "Equip failed for "
                        .. seedName
                        .. ": "
                        .. tostring(equipInfo)
                    )

                else

                    for _, worldPosition in ipairs(positions) do

                        if state.Enabled ~= true then
                            break
                        end

                        if fired >= amount then
                            break
                        end

                        local liveCount =
                            GAG2SeedPlantReadSeedCount(
                                seedName
                            )

                        if liveCount <= 0 then
                            break
                        end

                        local okPlant, plantInfo =
                            GAG2SeedPlantFire(
                                seedName,
                                worldPosition
                            )

                        if okPlant == true then

                            fired += 1

                            state.LastSeed =
                                seedName

                            state.LastFired =
                                fired

                            local plantDelay =
                                GAG2SeedPlantClampNumber(
                                    state.PlantDelay,
                                    0.1,
                                    0,
                                    5
                                )

                            if plantDelay > 0 then

                                task.wait(
                                    plantDelay
                                )

                            elseif fired % 12 == 0 then

                                task.wait()
                            end

                        else

                            state.LastFailure =
                                tostring(plantInfo)

                            GAG2SeedPlantSetStatus(
                                "Plant failed for "
                                .. seedName
                                .. ": "
                                .. tostring(plantInfo)
                            )

                            task.wait(
                                0.15
                            )
                        end
                    end
                end
            end
        end
    end

    if fired > 0 then

        GAG2SeedPlantSetStatus(
            "Fired "
            .. tostring(fired)
            .. " plant packet(s). Waiting next cycle."
        )

    elseif waitingSeed ~= "" then

        GAG2SeedPlantSetStatus(
            "Waiting for "
            .. waitingSeed
            .. " seeds from Backpack / Auto Buy..."
        )

    else

        GAG2SeedPlantSetStatus(
            "No selected seed tools available."
        )
    end

    return fired
end

function GAG2SeedPlantStartLoop()

    local state =
        GAG2_SEED_PLANTING_STATE

    if state.Running == true then
        return
    end

    state.Running =
        true

    task.spawn(function()

        GAG2SeedPlantSetStatus(
            "Loop started. Plant Amount is per cycle."
        )

        while state.Enabled == true do

            local fired =
                GAG2SeedPlantFireCycle()

            if fired > 0 then

                task.wait(
                    GAG2SeedPlantClampNumber(
                        state.CycleDelay,
                        0.1,
                        0.03,
                        5
                    )
                )

            else

                task.wait(
                    0.75
                )
            end
        end

        state.Running =
            false

        if state.Enabled ~= true then

            GAG2SeedPlantSetStatus(
                "Stopped."
            )
        end
    end)
end

function GAG2SeedPlantSetEnabled(value)

    local state =
        GAG2_SEED_PLANTING_STATE

    state.Enabled =
        value == true

    if state.Enabled == true then

        if Toggles
        and Toggles.HolyGAG2AutoPlant
        and type(Toggles.HolyGAG2AutoPlant.SetValue) == "function"
        and Toggles.HolyGAG2AutoPlant.Value == true then

            pcall(function()

                Toggles.HolyGAG2AutoPlant:SetValue(
                    false
                )
            end)
        end

        GAG2SeedPlantSetStatus(
            "Enabled. Plant Amount is per cycle."
        )

        if ConfigState.Loading ~= true then

            GAG2SeedPlantStartLoop()
        end

    else

        GAG2SeedPlantSetStatus(
            "Disabled."
        )
    end

    MarkConfigDirty()
end

function GAG2SeedPlantRefreshDropdown()

    local dropdown =
        GAG2_SEED_PLANTING_CONTROLS.Seeds

    if not dropdown then
        return
    end

    local values =
        GAG2SeedPlantGetSeedValues()

    pcall(function()

        if type(dropdown.SetValues) == "function" then

            dropdown:SetValues(
                values
            )

        elseif type(dropdown.SetItems) == "function" then

            dropdown:SetItems(
                values
            )
        end
    end)
end

function GAG2RestoreSeedPlantingState()

    task.defer(function()

        local state =
            GAG2_SEED_PLANTING_STATE

        GAG2SeedPlantLoadPoint()

        if Options.HolyGAG2SeedPlantSeeds then

            GAG2SeedPlantSetSelectedSeeds(
                Options.HolyGAG2SeedPlantSeeds.Value
            )
        end

        if Options.HolyGAG2SeedPlantLayout then

            GAG2SeedPlantSetLayout(
                Options.HolyGAG2SeedPlantLayout.Value
            )
        end

        if Options.HolyGAG2SeedPlantDirection then

            GAG2SeedPlantSetDirection(
                Options.HolyGAG2SeedPlantDirection.Value
            )
        end

        if Options.HolyGAG2SeedPlantAmount then

            GAG2SeedPlantSetAmount(
                Options.HolyGAG2SeedPlantAmount.Value
            )
        end

        if Options.HolyGAG2SeedPlantDelay then

            GAG2SeedPlantSetPlantDelay(
                Options.HolyGAG2SeedPlantDelay.Value
            )
        end

        if Options.HolyGAG2SeedPlantLayerSpacing then

            GAG2SeedPlantSetLayerSpacing(
                Options.HolyGAG2SeedPlantLayerSpacing.Value
            )
        end

        if Options.HolyGAG2SeedPlantGridWidth then

            GAG2SeedPlantSetGridWidth(
                Options.HolyGAG2SeedPlantGridWidth.Value
            )
        end

        if Options.HolyGAG2SeedPlantGridDepth then

            GAG2SeedPlantSetGridDepth(
                Options.HolyGAG2SeedPlantGridDepth.Value
            )
        end

        if Options.HolyGAG2SeedPlantGridLayers then

            GAG2SeedPlantSetGridLayers(
                Options.HolyGAG2SeedPlantGridLayers.Value
            )
        end

        if Options.HolyGAG2SeedPlantGridSpacing then

            GAG2SeedPlantSetGridSpacing(
                Options.HolyGAG2SeedPlantGridSpacing.Value
            )
        end

        if Toggles.HolyGAG2SeedPlanting then

            state.Enabled =
                Toggles.HolyGAG2SeedPlanting.Value == true
        end

        GAG2SeedPlantRefreshDropdown()

        if state.Enabled == true then

            GAG2SeedPlantSetEnabled(
                true
            )

        else

            GAG2SeedPlantSetStatus(
                "Ready."
            )
        end
    end)
end

local function SniperMoveCloseForTame(entry)

    local character, root =
        SniperGetCharacterRoot()

    if not character
    or not root then
        return nil, "missing character"
    end

    local targetPosition =
        SniperGetEntryTamePosition(
            entry
        )

    if typeof(targetPosition) ~= "Vector3" then
        return nil, "missing pet position"
    end

    local oldCFrame =
        root.CFrame

    local distance =
        (root.Position - targetPosition).Magnitude

    if distance <= 10 then

        SniperStopCharacterMotion(
            root
        )

        return {
            Character = character,
            OldCFrame = oldCFrame,
            ClosePosition = root.Position,
            Moved = false,
        },
        "already close"
    end

    local closeCFrame, closePosition =
        SniperGetSafeTameCFrame(
            targetPosition
        )

    if typeof(closeCFrame) ~= "CFrame"
    or typeof(closePosition) ~= "Vector3" then
        return nil, "safe position failed"
    end

    local ok, err =
        pcall(function()

            character:PivotTo(
                closeCFrame
            )
        end)

    if ok ~= true then

        ok, err =
            pcall(function()

                root.CFrame =
                    closeCFrame
            end)
    end

    if ok ~= true then
        return nil, tostring(err)
    end

    task.wait(
        0.08
    )

    local _, newRoot =
        SniperGetCharacterRoot()

    if newRoot then

        SniperStopCharacterMotion(
            newRoot
        )
    end

    task.wait(
        0.18
    )

    return {
        Character = character,
        OldCFrame = oldCFrame,
        ClosePosition = closePosition,
        Moved = true,
    },
    "moved"
end

local function SniperRestoreAfterTame(moveState)

    if SniperState.ReturnAfterTame ~= true then
        return
    end

    if type(moveState) ~= "table" then
        return
    end

    if moveState.Moved ~= true then
        return
    end

    local character =
        moveState.Character

    local oldCFrame =
        moveState.OldCFrame

    local closePosition =
        moveState.ClosePosition

    if typeof(oldCFrame) ~= "CFrame" then
        return
    end

    local currentCharacter, currentRoot =
        SniperGetCharacterRoot()

    if not currentCharacter
    or not currentRoot then
        return
    end

    if typeof(closePosition) == "Vector3" then

        local movedAwayDistance =
            (currentRoot.Position - closePosition).Magnitude

        if movedAwayDistance > 18 then
            return
        end
    end

    pcall(function()

        if typeof(character) == "Instance"
        and character.Parent then

            character:PivotTo(
                oldCFrame
            )
        end
    end)
end

local function SniperGetEntryKey(entry)

    if type(entry) ~= "table" then
        return ""
    end

    local uuid =
        CleanText(entry.UUID)

    if uuid ~= "" then
        return uuid
    end

    return CleanText(entry.Name)
end

local function SniperHasPendingBuy()

    if type(SniperState.PendingWildPets) ~= "table" then
        return false
    end

    for _, value in pairs(SniperState.PendingWildPets) do

        if value == true then
            return true
        end
    end

    return false
end

local function SniperIsEntryHandled(entry)

    local key =
        SniperGetEntryKey(entry)

    if key == "" then
        return false
    end

    local untilTime =
        tonumber(
            SniperState.HandledWildPets[key]
        )
        or 0

    if untilTime <= 0 then
        return false
    end

    if os.clock() >= untilTime then

        SniperState.HandledWildPets[key] =
            nil

        return false
    end

    return true
end

local function SniperMarkEntryHandled(entry, seconds)

    local key =
        SniperGetEntryKey(entry)

    if key == "" then
        return
    end

    SniperState.HandledWildPets[key] =
        os.clock()
        + (
            tonumber(seconds)
            or SniperState.HandledPetCooldown
            or 60
        )
end

local function SniperFindSpawnByUuid(uuid)

    uuid =
        CleanText(uuid)

    if uuid == "" then
        return nil
    end

    local folder =
        SniperGetSpawnsFolder()

    if not folder then
        return nil
    end

    for _, child in ipairs(folder:GetChildren()) do

        local childUuid =
            SniperGetUuid(
                child.Name
            )

        if childUuid == uuid then
            return child
        end
    end

    return nil
end

local function SniperEntryStillActive(entry)

    if type(entry) ~= "table" then
        return false
    end

    local uuid =
        CleanText(entry.UUID)

    if uuid ~= "" then

        local ref =
            SniperFindRef(
                uuid
            )

        local spawn =
            SniperFindSpawnByUuid(
                uuid
            )

        if typeof(ref) == "Instance"
        and ref.Parent ~= nil then
            return true
        end

        if typeof(spawn) == "Instance"
        and spawn.Parent ~= nil then
            return true
        end

        return false
    end

    local instance =
        entry.Instance

    if typeof(instance) == "Instance"
    and instance.Parent ~= nil then
        return true
    end

    return false
end

local function SniperWaitForClaimConfirmation(entry)

    local started =
        os.clock()

    local missingSince =
        nil

    local timeout =
        math.clamp(
            tonumber(SniperState.ClaimWaitTimeout)
            or 90,
            15,
            180
        )

    local confirmTime =
        math.clamp(
            tonumber(SniperState.ClaimDisappearConfirmTime)
            or 1.25,
            0.5,
            5
        )

    while os.clock() - started < timeout do

        if SniperEntryStillActive(entry) == true then

            missingSince =
                nil

        else

            if missingSince == nil then

                missingSince =
                    os.clock()
            end

            if os.clock() - missingSince >= confirmTime then
                return true
            end
        end

        task.wait(
            0.35
        )
    end

    return false
end

local function SniperHoldCloseForServerValidation(moveState)

    local waitTime =
        math.clamp(
            tonumber(SniperState.BuyValidationHoldDelay)
            or 0.85,
            0.25,
            2
        )

    local started =
        os.clock()

    while os.clock() - started < waitTime do

        local _, root =
            SniperGetCharacterRoot()

        if root
        and typeof(moveState) == "table"
        and typeof(moveState.ClosePosition) == "Vector3" then

            local distanceFromBuyPoint =
                (root.Position - moveState.ClosePosition).Magnitude

            if distanceFromBuyPoint > 22 then
                break
            end
        end

        task.wait(
            0.05
        )
    end
end

local function SniperStartBuyConfirmation(entry)

    local key =
        SniperGetEntryKey(
            entry
        )

    if key == "" then
        return
    end

    if SniperState.PendingWildPets[key] == true then
        return
    end

    SniperState.PendingWildPets[key] =
        true

    SniperState.ConfirmingBuy =
        true

    SniperState.ConfirmingBuyKey =
        key

    GAG2CancelServerHop(
        nil
    )

    task.spawn(function()

        local confirmed =
            SniperWaitForClaimConfirmation(
                entry
            )

        SniperState.PendingWildPets[key] =
            nil

        if SniperHasPendingBuy() == true then

            SniperState.ConfirmingBuy =
                true

            SniperState.ConfirmingBuyKey =
                ""

        else

            SniperState.ConfirmingBuy =
                false

            SniperState.ConfirmingBuyKey =
                ""
        end

        if confirmed == true then

            SetSniperStatus(
                "Confirmed: "
                .. tostring(entry.Name)
            )

            Notify(
                "Sniper",
                "Confirmed "
                .. tostring(entry.Name)
                .. ".",
                3
            )

        else

            SniperState.HandledWildPets[key] =
                nil

            SetSniperStatus(
                "Buy not confirmed."
            )

            warn(
                "[HOLY GAG2 SNIPER]",
                "Buy was sent but not confirmed",
                "| pet:",
                tostring(entry.Name),
                "| uuid:",
                tostring(entry.UUID)
            )
        end
    end)
end

local function SniperFireWildBuyPacket(entry)

    if type(entry) ~= "table" then
        return false, "missing entry"
    end

    local uuid =
        CleanText(entry.UUID)

    if uuid == "" then
        return false, "missing pet id"
    end

    local ref =
        entry.Ref

    if typeof(ref) ~= "Instance"
    or ref.Parent == nil then

        ref =
            SniperFindRef(
                uuid
            )
    end

    if typeof(ref) ~= "Instance"
    or ref.Parent == nil then

        return false,
            "missing pet ref"
    end

    local packet =
        SniperFindWildBuyPacket()

    if not packet then
        return false, SniperState.BuyPacketSource
    end

    local sourceText =
        tostring(SniperState.BuyPacketSource or ""):lower()

    if sourceText:find("wild", 1, true) == nil then

        SniperState.BuyPacket =
            nil

        return false,
            "blocked packet"
    end

    local okFire, err =
        pcall(function()

            packet:Fire(
                ref
            )
        end)

    if okFire ~= true then

        okFire, err =
            pcall(function()

                packet.Fire(
                    packet,
                    ref
                )
            end)
    end

    if okFire ~= true then

        warn(
            "[HOLY GAG2 SNIPER]",
            "buy fire failed",
            "| pet:",
            tostring(entry.Name),
            "| uuid:",
            tostring(uuid),
            "| ref:",
            PathOf(ref),
            "| packet:",
            tostring(SniperState.BuyPacketSource),
            "| err:",
            tostring(err)
        )

        return false, tostring(err)
    end

    print(
        "[HOLY GAG2 SNIPER]",
        "buy fired",
        "| pet:",
        tostring(entry.Name),
        "| uuid:",
        tostring(uuid),
        "| ref:",
        PathOf(ref),
        "| packet:",
        tostring(SniperState.BuyPacketSource)
    )

    return true, "fired"
end

local function SniperAttemptBuyEntry(entry)

    if type(entry) ~= "table" then
        return false
    end

    if SniperState.Taming == true then
        return false
    end

    local readyToBuy, readyText =
        SniperReadyToBuy()

    if readyToBuy ~= true then

        SetSniperStatus(
            readyText
        )

        return false
    end

    local uuid =
        CleanText(entry.UUID)

    local attemptKey =
        uuid ~= ""
        and uuid
        or tostring(entry.Name or "unknown")

    if SniperIsEntryHandled(entry) == true then
        return false
    end

    local lastAttempt =
        tonumber(
            SniperState.RecentTameAttempts[attemptKey]
        )
        or 0

    if os.clock() - lastAttempt < 8 then
        return false
    end

    if os.clock() - tonumber(SniperState.LastTameAt or 0) < 0.75 then
        return false
    end

    SniperState.Taming =
        true

    SniperState.LastTameAt =
        os.clock()

    SniperState.RecentTameAttempts[attemptKey] =
        os.clock()

    SetSniperStatus(
        "Buying "
        .. tostring(entry.Name)
        .. "..."
    )

    task.spawn(function()

        local moveState, moveInfo =
            SniperMoveCloseForTame(
                entry
            )

        if not moveState then

            SetSniperStatus(
                "Move failed."
            )

            SniperState.Taming =
                false

            return
        end

        local ok, info =
            SniperFireWildBuyPacket(
                entry
            )

        if ok == true then

            SniperMarkEntryHandled(
                entry,
                SniperState.HandledPetCooldown
            )

            SetSniperStatus(
                "Buy sent: "
                .. tostring(entry.Name)
            )

            SniperHoldCloseForServerValidation(
                moveState
            )

            SniperRestoreAfterTame(
                moveState
            )

            SniperStartBuyConfirmation(
                entry
            )

        else

            SniperRestoreAfterTame(
                moveState
            )

            SetSniperStatus(
                "Buy failed."
            )

            warn(
                "[HOLY GAG2 SNIPER]",
                "Buy failed",
                "| pet:",
                tostring(entry.Name),
                "| info:",
                tostring(info),
                "| packet:",
                tostring(SniperState.BuyPacketSource)
            )
        end

        SniperState.Taming =
            false
    end)

    return true
end

local function SniperGetDropdownPetNames()

    local names =
        {}

    local function add(name)

        name =
            CleanText(name)

        if name == "" then
            return
        end

        if table.find(names, name) ~= nil then
            return
        end

        table.insert(
            names,
            name
        )
    end

    for _, selectedName in ipairs(SniperState.Targets or {}) do
        add(selectedName)
    end

    for _, registryName in ipairs(SniperGetRegistryPetNames()) do
        add(registryName)
    end

    if #names <= 0 then

        for _, knownName in ipairs(SniperState.KnownPetNames or {}) do
            add(knownName)
        end

        local folder =
            SniperGetSpawnsFolder()

        if folder then

            for _, child in ipairs(folder:GetChildren()) do

                if child.Name:find("WildPet", 1, true) then

                    add(
                        SniperGetPetName(child)
                    )
                end
            end
        end
    end

    table.sort(
        names
    )

    return names
end

local function SniperRefreshTargetDropdown()

    if not SniperTargetDropdown then
        return
    end

    if SniperDropdownRefreshing == true then
        return
    end

    SniperDropdownRefreshing =
        true

    local values =
        SniperGetDropdownPetNames()

    pcall(function()

        if type(SniperTargetDropdown.SetValues) == "function" then

            SniperTargetDropdown:SetValues(
                values
            )

        elseif type(SniperTargetDropdown.SetItems) == "function" then

            SniperTargetDropdown:SetItems(
                values
            )
        end
    end)

    SniperDropdownRefreshing =
        false
end

function SniperPriorityCleanValue(value)

    value =
        CleanText(value)

    if value == ""
    or value == "None"
    or value == "-" then
        return ""
    end

    return value
end

function SniperGetPriorityDropdownValues()

    local values = {
        "None",
    }

    local function add(name)

        name =
            SniperPriorityCleanValue(
                name
            )

        if name == "" then
            return
        end

        if table.find(values, name) ~= nil then
            return
        end

        table.insert(
            values,
            name
        )
    end

    for _, selectedName in ipairs(SniperState.Targets or {}) do

        add(
            selectedName
        )
    end

    for _, registryName in ipairs(SniperGetRegistryPetNames()) do

        add(
            registryName
        )
    end

    table.sort(values, function(a, b)

        if a == "None" then
            return true
        end

        if b == "None" then
            return false
        end

        return tostring(a) < tostring(b)
    end)

    return values
end

function SniperSetPriorityPet(slot, value)

    slot =
        tonumber(slot)

    if not slot
    or slot < 1
    or slot > 5 then
        return
    end

    SniperState.PriorityPets =
        SniperState.PriorityPets
        or {
            "",
            "",
            "",
            "",
            "",
        }

    SniperState.PriorityPets[slot] =
        SniperPriorityCleanValue(
            value
        )

    MarkConfigDirty()
end

function SniperGetPriorityRank(petName)

    local petKey =
        SniperNormalizeName(
            petName
        )

    if petKey == "" then
        return 999
    end

    for index = 1, 5 do

        local priorityName =
            SniperState.PriorityPets
            and SniperState.PriorityPets[index]
            or ""

        local priorityKey =
            SniperNormalizeName(
                priorityName
            )

        if priorityKey ~= ""
        and petKey == priorityKey then
            return index
        end
    end

    return 999
end

function SniperGetEntryDistanceValue(entry)

    if type(entry) ~= "table" then
        return math.huge
    end

    local position =
        entry.Position

    if typeof(position) ~= "Vector3" then
        return math.huge
    end

    local character =
        LOCAL_PLAYER.Character

    local root =
        character
        and character:FindFirstChild("HumanoidRootPart")

    if not root then
        return math.huge
    end

    return (root.Position - position).Magnitude
end

function SniperSortMatches(matches)

    if type(matches) ~= "table" then
        return
    end

    table.sort(matches, function(a, b)

        local aRank =
            SniperGetPriorityRank(
                a and a.Name
            )

        local bRank =
            SniperGetPriorityRank(
                b and b.Name
            )

        if aRank ~= bRank then
            return aRank < bRank
        end

        local aDistance =
            SniperGetEntryDistanceValue(
                a
            )

        local bDistance =
            SniperGetEntryDistanceValue(
                b
            )

        if aDistance ~= bDistance then
            return aDistance < bDistance
        end

        return tostring(a and a.Name or "")
            < tostring(b and b.Name or "")
    end)
end

function SniperPriorityText()

    local rows =
        {}

    for index = 1, 5 do

        local value =
            SniperPriorityCleanValue(
                SniperState.PriorityPets
                and SniperState.PriorityPets[index]
                or ""
            )

        if value ~= "" then

            table.insert(
                rows,
                tostring(index)
                .. ". "
                .. value
            )
        end
    end

    if #rows <= 0 then
        return "None"
    end

    return table.concat(
        rows,
        " > "
    )
end

function SniperRefreshPriorityDropdowns()

    if SniperPriorityRefreshing == true then
        return
    end

    SniperPriorityRefreshing =
        true

    local values =
        SniperGetPriorityDropdownValues()

    for index = 1, 5 do

        local dropdown =
            SniperPriorityDropdowns
            and SniperPriorityDropdowns[index]

        if dropdown then

            pcall(function()

                if type(dropdown.SetValues) == "function" then

                    dropdown:SetValues(
                        values
                    )

                elseif type(dropdown.SetItems) == "function" then

                    dropdown:SetItems(
                        values
                    )
                end
            end)
        end
    end

    SniperPriorityRefreshing =
        false
end

local function SniperGetActiveEntries()

    local spawnFolder =
        SniperGetSpawnsFolder()

    local refFolder =
        SniperGetRefFolder()

    local entries =
        {}

    local usedKeys =
        {}

    local function addEntry(spawn, ref, fallbackUuid)

        local uuid =
            CleanText(fallbackUuid)

        if uuid == ""
        and typeof(spawn) == "Instance" then

            uuid =
                SniperGetUuid(
                    spawn.Name
                )
        end

        if uuid == ""
        and typeof(ref) == "Instance" then

            uuid =
                SniperGetUuid(
                    ref.Name
                )
        end

        local key =
            uuid

        if key == "" then

            key =
                typeof(spawn) == "Instance"
                and PathOf(spawn)
                or PathOf(ref)
        end

        if key == ""
        or usedKeys[key] == true then
            return
        end

        local petName =
            "Unknown"

        if typeof(spawn) == "Instance" then

            petName =
                SniperGetPetName(
                    spawn
                )
        end

        if (
            petName == ""
            or petName == "Unknown"
            or petName:match("^WildPet[%s_]")
        )
        and typeof(ref) == "Instance" then

            local refName =
                SniperGetPetName(
                    ref
                )

            if refName ~= ""
            and refName ~= "Unknown"
            and not refName:match("^WildPet[%s_]") then

                petName =
                    refName
            end
        end

        if petName == ""
        or petName == "Unknown" then
            return
        end

        local position =
            nil

        if typeof(spawn) == "Instance" then

            position =
                SniperGetPosition(
                    spawn
                )
        end

        if typeof(position) ~= "Vector3"
        and typeof(ref) == "Instance" then

            position =
                SniperGetPosition(
                    ref
                )
        end

        usedKeys[key] =
            true

        local textRows =
            SniperBuildTextRows(
                spawn,
                ref
            )

        local timerText =
            SniperGetEntryTimer(
                spawn,
                ref,
                textRows
            )

        local priceText =
            SniperGetEntryPrice(
                spawn,
                ref,
                textRows
            )

        SniperRememberPetName(
            petName
        )

        table.insert(entries, {
            Instance = spawn or ref,
            Spawn = spawn,
            Name = petName,
            Key = SniperNormalizeName(petName),
            UUID = uuid,
            Ref = ref,
            Position = position,
            Distance = SniperDistanceText(position),
            Timer = timerText,
            Price = priceText,
            Path = PathOf(spawn or ref),
        })
    end

    if spawnFolder then

        for _, child in ipairs(spawnFolder:GetChildren()) do

            if child.Name:find("WildPet", 1, true) then

                local uuid =
                    SniperGetUuid(
                        child.Name
                    )

                local ref =
                    uuid ~= ""
                    and SniperFindRef(
                        uuid
                    )
                    or nil

                addEntry(
                    child,
                    ref,
                    uuid
                )
            end
        end
    end

    if refFolder then

        for _, ref in ipairs(refFolder:GetChildren()) do

            if ref.Name:find("WildPet", 1, true) then

                local uuid =
                    SniperGetUuid(
                        ref.Name
                    )

                local spawn =
                    uuid ~= ""
                    and SniperFindSpawnByUuid(
                        uuid
                    )
                    or nil

                addEntry(
                    spawn,
                    ref,
                    uuid
                )
            end
        end
    end

    table.sort(entries, function(a, b)

        local aPosition =
            a.Position

        local bPosition =
            b.Position

        local character =
            LOCAL_PLAYER.Character

        local root =
            character
            and character:FindFirstChild("HumanoidRootPart")

        if root
        and typeof(aPosition) == "Vector3"
        and typeof(bPosition) == "Vector3" then

            return (root.Position - aPosition).Magnitude
                < (root.Position - bPosition).Magnitude
        end

        if typeof(aPosition) == "Vector3"
        and typeof(bPosition) ~= "Vector3" then
            return true
        end

        if typeof(aPosition) ~= "Vector3"
        and typeof(bPosition) == "Vector3" then
            return false
        end

        return tostring(a.Name) < tostring(b.Name)
    end)

    if not spawnFolder
    and not refFolder then
        return entries, "missing wild pet data"
    end

    return entries, "ok"
end

local function SniperEntryMatchesTargets(entry, targets)

    if type(entry) ~= "table"
    or type(targets) ~= "table" then
        return false
    end

    local petKey =
        SniperNormalizeName(entry.Name)

    if petKey == "" then
        return false
    end

    for targetKey in pairs(targets) do

        if targetKey ~= ""
        and (
            petKey == targetKey
            or petKey:find(targetKey, 1, true) ~= nil
            or targetKey:find(petKey, 1, true) ~= nil
        ) then

            return true
        end
    end

    return false
end

function SniperBuildMatchText(entries, matches, orderedTargets, reason)

    local lines = {
        '<font color="rgb(196,181,253)"><b>Selected Targets</b></font>',
        SniperTargetsText(),
        "",
        '<font color="rgb(196,181,253)"><b>Priority</b></font>',
        SniperPriorityText(),
        "",
        '<font color="rgb(196,181,253)"><b>Result</b></font>',
    }

    if reason ~= "ok" then

        table.insert(
            lines,
            "Waiting for pets..."
        )

        return table.concat(
            lines,
            "\n"
        )
    end

    if #orderedTargets <= 0 then

        table.insert(
            lines,
            "Select target pets first."
        )

        return table.concat(
            lines,
            "\n"
        )
    end

    if #matches <= 0 then

        table.insert(
            lines,
            "No target found."
        )

        table.insert(
            lines,
            "Active pets: " .. tostring(#entries)
        )

        return table.concat(
            lines,
            "\n"
        )
    end

    table.insert(
        lines,
        "Target found."
    )

    for index, entry in ipairs(matches) do

        if index > 6 then

            table.insert(
                lines,
                "+" .. tostring(#matches - 6) .. " more"
            )

            break
        end

        table.insert(
            lines,
            tostring(index)
            .. ". "
            .. tostring(entry.Name)
            .. " | Time: "
            .. tostring(entry.Timer or "?")
            .. " | Price: "
            .. tostring(entry.Price or "?")
            .. " | "
            .. tostring(entry.Distance)
        )
    end

    return table.concat(
        lines,
        "\n"
    )
end

function SniperScan(allowAutoHop)

    SniperState.LastScanAt =
        os.clock()

    local targets, orderedTargets =
        SniperBuildTargets()

    local entries, reason =
        SniperGetActiveEntries()

    local matches =
        {}

    for _, entry in ipairs(entries) do

        if SniperIsEntryHandled(entry) ~= true
        and SniperEntryMatchesTargets(entry, targets) == true then

            table.insert(
                matches,
                entry
            )
        end
    end

        SniperSortMatches(
        matches
    )

    SniperState.LastMatchCount =
        #matches

    SniperState.LastMatchText =
        SniperBuildMatchText(
            entries,
            matches,
            orderedTargets,
            reason
        )

    RefreshSniperLabels()

    if reason ~= "ok" then

        SetSniperStatus(
            "Waiting for pets..."
        )

        return matches
    end

    if #orderedTargets <= 0 then

        SetSniperStatus(
            "Select target pets."
        )

        return matches
    end

    if SniperState.WaitingForClaim == true then

        SniperState.WaitingForClaim =
            false

        SniperState.WaitingForClaimKey =
            ""
    end

    if SniperHasPendingBuy() == true then

        GAG2CancelServerHop(
            nil
        )
    end

    if #matches > 0 then

        GAG2CancelServerHop(
            nil
        )

        SetSniperStatus(
            "Found: "
            .. tostring(matches[1].Name)
        )

        if allowAutoHop == true
        and SniperState.Enabled == true then

            local readyToBuy, readyText =
                SniperReadyToBuy()

            if readyToBuy == true then

                SniperAttemptBuyEntry(
                    matches[1]
                )

            else

                SetSniperStatus(
                    readyText
                )
            end
        end

        return matches
    end

    SetSniperStatus(
        "No target found."
    )

    local hasHandledActiveTarget =
        false

    for _, entry in ipairs(entries) do

        if SniperIsEntryHandled(entry) == true
        and SniperEntryMatchesTargets(entry, targets) == true then

            hasHandledActiveTarget =
                true

            break
        end
    end

    if allowAutoHop == true
    and SniperState.AutoHop == true
    and SniperState.Enabled == true
    and SniperState.Taming ~= true
    and SniperHasPendingBuy() ~= true
    and hasHandledActiveTarget ~= true
    and SniperReadyToHop() == true then

        local sinceHop =
            os.clock() - tonumber(SniperState.LastHopAt or 0)

        local instantWanted =
            SniperState.InstantFirstHop == true
            and SniperState.FirstHopUsed ~= true
            and SniperState.LastHopAt <= 0

        local shouldInstantHop =
            instantWanted == true

        if shouldInstantHop == true then

            SetSniperStatus(
                "Instant hopping..."
            )

            GAG2SetPanicHudStatus(
                "STOP / INSTANT HOP"
            )

        elseif sinceHop < SniperState.HopDelay then

            local remaining =
                math.max(
                    1,
                    math.ceil(
                        SniperState.HopDelay - sinceHop
                    )
                )

            SetSniperStatus(
                "Hop in "
                .. tostring(remaining)
                .. "s"
            )

            GAG2SetPanicHudStatus(
                "STOP? "
                .. tostring(remaining)
                .. "s"
            )

            return matches
        end

        if shouldInstantHop == true
        or sinceHop >= SniperState.HopDelay then

            SniperState.FirstHopUsed =
                true

            SniperState.LastHopAt =
                os.clock()

            SetSniperStatus(
                shouldInstantHop == true
                and "Instant hopping..."
                or "Hopping..."
            )

            HopServerOnce()
        end
    end

    return matches
end

function SniperStartLoop()

    if SniperState.Running == true then
        return
    end

    SniperState.Running =
        true

    task.spawn(function()

        SetSniperStatus(
            "Sniper scanner started."
        )

        while SniperState.Enabled == true do

            SniperScan(
                true
            )

            task.wait(
                math.clamp(
                    tonumber(SniperState.ScanDelay)
                    or 0.5,
                    0.2,
                    3
                )
            )
        end

        SniperState.Running =
            false

        SetSniperStatus(
            "Sniper scanner stopped."
        )
    end)
end

function SniperSetEnabled(value)

    SniperState.Enabled =
        value == true

    if SniperState.Enabled == true then

        SniperState.EnabledAt =
            os.clock()

        if SniperState.AutoHop == true
        and SniperState.InstantFirstHop == true then

            GAG2SetPanicHudStatus(
                "STOP READY"
            )

        else

            GAG2SetPanicHudStatus(
                "Sniper ON"
            )
        end

        GAG2_SERVER_HOP_RETRYING =
            false

        GAG2_SERVER_HOP_ATTEMPT =
            0

        SniperState.FirstHopUsed =
            false

        SniperScan(
            false
        )

        MarkConfigDirty()

        SniperStartLoop()

    else

        GAG2_SERVER_HOP_RETRYING =
            false

        GAG2_SERVER_HOP_ATTEMPT =
            0

        SniperState.FirstHopUsed =
            false

        SniperState.EnabledAt =
            0

        GAG2SetPanicHudStatus(
            "Sniper OFF"
        )

        SetSniperStatus(
            "Sniper disabled."
        )

        MarkConfigDirty()
    end
end

function GAG2SetSniperToggleValue(value)

    if GAG2_SNIPER_TOGGLE_CONTROL
    and type(GAG2_SNIPER_TOGGLE_CONTROL.SetValue) == "function" then

        pcall(function()

            GAG2_SNIPER_TOGGLE_CONTROL:SetValue(
                value == true
            )
        end)

        return
    end

    if Toggles.HolyGAG2SniperEnabled
    and type(Toggles.HolyGAG2SniperEnabled.SetValue) == "function" then

        pcall(function()

            Toggles.HolyGAG2SniperEnabled:SetValue(
                value == true
            )
        end)

        return
    end

    SniperSetEnabled(
        value == true
    )
end

function StopGAG2SniperNow(reason)

    if GAG2_SNIPER_STOPPING == true then
        return
    end

    GAG2_SNIPER_STOPPING =
        true

    GAG2_SERVER_HOP_RETRYING =
        false

    GAG2_SERVER_HOP_ATTEMPT =
        0

    SniperState.Enabled =
        false

    SniperState.Running =
        false

    SniperState.FirstHopUsed =
        false

    SetSniperStatus(
        tostring(reason or "Sniper stopped.")
    )

    GAG2SetSniperToggleValue(
        false
    )

    MarkConfigDirty()

    GAG2_SNIPER_STOPPING =
        false
end

getgenv().HOLY_GAG2_STOP_SNIPER =
    StopGAG2SniperNow

function GAG2SetPanicHudStatus(text)

    if GAG2_PANIC_HUD_STATUS then

        pcall(function()

            GAG2_PANIC_HUD_STATUS.Text =
                tostring(text or "Ready.")
        end)
    end
end

function GAG2PanicStopNow(reason)

    GAG2_SERVER_HOP_RETRYING =
        false

    GAG2_SERVER_HOP_ATTEMPT =
        0

    if type(SniperState) == "table" then

        SniperState.Enabled =
            false

        SniperState.Running =
            false

        SniperState.AutoHop =
            false

        SniperState.InstantFirstHop =
            false

        SniperState.FirstHopUsed =
            false

        SniperState.EnabledAt =
            0

        SniperState.Taming =
            false

        SniperState.ConfirmingBuy =
            false

        SniperState.ConfirmingBuyKey =
            ""
    end

    if GAG2_SNIPER_TOGGLE_CONTROL
    and type(GAG2_SNIPER_TOGGLE_CONTROL.SetValue) == "function" then

        pcall(function()

            GAG2_SNIPER_TOGGLE_CONTROL:SetValue(
                false
            )
        end)
    end

    if Toggles.HolyGAG2SniperAutoHop
    and type(Toggles.HolyGAG2SniperAutoHop.SetValue) == "function" then

        pcall(function()

            Toggles.HolyGAG2SniperAutoHop:SetValue(
                false
            )
        end)
    end

    if Toggles.HolyGAG2SniperInstantFirstHop
    and type(Toggles.HolyGAG2SniperInstantFirstHop.SetValue) == "function" then

        pcall(function()

            Toggles.HolyGAG2SniperInstantFirstHop:SetValue(
                false
            )
        end)
    end

    SetSniperStatus(
        tostring(reason or "Emergency stopped.")
    )

    SetStatus(
        "Emergency stopped."
    )

    GAG2SetPanicHudStatus(
        "STOPPED"
    )

    MarkConfigDirty()

    pcall(function()

        SaveManager:Save(
            ConfigState.AutosaveName
        )
    end)
end

getgenv().HOLY_GAG2_PANIC_STOP =
    GAG2PanicStopNow

function GAG2CreatePanicHud()

    if GAG2_PANIC_HUD_GUI then
        return GAG2_PANIC_HUD_GUI
    end

    local parent =
        CoreGui

    if not parent then

        parent =
            LOCAL_PLAYER
            and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")
            or nil
    end

    if not parent then
        return nil
    end

    local gui =
        Instance.new("ScreenGui")

    gui.Name =
        "HolyGAG2PanicHud"

    gui.ResetOnSpawn =
        false

    gui.IgnoreGuiInset =
        true

    gui.ZIndexBehavior =
        Enum.ZIndexBehavior.Sibling

    gui.Parent =
        parent

    local frame =
        Instance.new("Frame")

    frame.Name =
        "Frame"

    frame.Position =
        UDim2.fromOffset(
            14,
            155
        )

    frame.Size =
        UDim2.fromOffset(
            174,
            92
        )

    frame.BackgroundColor3 =
        Color3.fromRGB(9, 7, 15)

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
        Color3.fromRGB(248, 113, 113)

    stroke.Thickness =
        1

    stroke.Transparency =
        0.05

    stroke.Parent =
        frame

    local title =
        Instance.new("TextLabel")

    title.Name =
        "Title"

    title.BackgroundTransparency =
        1

    title.Position =
        UDim2.fromOffset(
            8,
            4
        )

    title.Size =
        UDim2.fromOffset(
            158,
            18
        )

    title.Font =
        Enum.Font.Code

    title.TextSize =
        12

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.TextColor3 =
        Color3.fromRGB(232, 230, 240)

    title.Text =
        "GAG2 Safety"

    title.Parent =
        frame

    local stop =
        Instance.new("TextButton")

    stop.Name =
        "Stop"

    stop.Position =
        UDim2.fromOffset(
            8,
            26
        )

    stop.Size =
        UDim2.fromOffset(
            158,
            32
        )

    stop.BackgroundColor3 =
        Color3.fromRGB(127, 29, 29)

    stop.BorderSizePixel =
        0

    stop.Font =
        Enum.Font.Code

    stop.TextSize =
        18

    stop.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    stop.Text =
        "STOP"

    stop.Parent =
        frame

    local stopCorner =
        Instance.new("UICorner")

    stopCorner.CornerRadius =
        UDim.new(0, 6)

    stopCorner.Parent =
        stop

    stop.MouseButton1Click:Connect(function()

        GAG2PanicStopNow(
            "Emergency stopped."
        )

        Notify(
            "Safety",
            "Sniper and auto-hop stopped.",
            3
        )
    end)

    local status =
        Instance.new("TextLabel")

    status.Name =
        "Status"

    status.BackgroundTransparency =
        1

    status.Position =
        UDim2.fromOffset(
            8,
            62
        )

    status.Size =
        UDim2.fromOffset(
            158,
            20
        )

    status.Font =
        Enum.Font.Code

    status.TextSize =
        11

    status.TextXAlignment =
        Enum.TextXAlignment.Left

    status.TextColor3 =
        Color3.fromRGB(196, 181, 253)

    status.Text =
        "Ready."

    status.Parent =
        frame

    GAG2_PANIC_HUD_GUI =
        gui

    GAG2_PANIC_HUD_STATUS =
        status

    GAG2_PANIC_HUD_CREATED =
        true

    return gui
end

GAG2CreatePanicHud()

function StartGAG2SniperHotkey()
    return
end

function RestoreSniperAutosaveState()

    task.defer(function()

        local enabled =
            Toggles.HolyGAG2SniperEnabled
            and Toggles.HolyGAG2SniperEnabled.Value == true

        local autoHop =
            Toggles.HolyGAG2SniperAutoHop
            and Toggles.HolyGAG2SniperAutoHop.Value == true

        local returnAfterTame =
            Toggles.HolyGAG2SniperReturnAfterTame

        local instantFirstHop =
            Toggles.HolyGAG2SniperInstantFirstHop

        SniperState.AutoHop =
            autoHop == true

        if instantFirstHop then

            SniperState.InstantFirstHop =
                instantFirstHop.Value == true

        else

            SniperState.InstantFirstHop =
                false
        end

        if returnAfterTame then

            SniperState.ReturnAfterTame =
                returnAfterTame.Value == true

        else

            SniperState.ReturnAfterTame =
                true
        end

        if Options.HolyGAG2SniperTargetsList
        and Options.HolyGAG2SniperTargetsList.Value ~= nil then

            SniperState.Targets =
                SniperNormalizeList(
                    Options.HolyGAG2SniperTargetsList.Value
                )
        end

        if Options.HolyGAG2SniperHopDelay
        and Options.HolyGAG2SniperHopDelay.Value ~= nil then

            SniperState.HopDelay =
                math.clamp(
                    tonumber(Options.HolyGAG2SniperHopDelay.Value)
                    or SniperState.HopDelay
                    or 20,
                    5,
                    120
                )
        end

        for priorityIndex = 1, 5 do

            local option =
                Options[
                    "HolyGAG2SniperPriority"
                    .. tostring(priorityIndex)
                ]

            if option
            and option.Value ~= nil then

                SniperSetPriorityPet(
                    priorityIndex,
                    option.Value
                )
            end
        end

        SniperRefreshTargetDropdown()
        SniperRefreshPriorityDropdowns()

        if enabled == true then

            SniperSetEnabled(
                true
            )

        else

            SetSniperStatus(
                "Ready."
            )

            SniperScan(
                false
            )
        end
    end)
end

--// [GAG2 VISUALS] Active Wild Pet HUD Helpers
local ActiveWildPetHudEnabled = false
local ActiveWildPetHudLabel = nil
local ActiveWildPetHudLoopRunning = false
local ActiveWildPetHudLastDebug = 0

local function ActiveWildPetHudDebug(message)
    if tick() - ActiveWildPetHudLastDebug < 3 then
        return
    end

    ActiveWildPetHudLastDebug = tick()
    print("[HOLY GAG2][Active Wild Pets] " .. tostring(message))
end

local function ActiveWildPetHudGetRoot()
    local map = workspace:FindFirstChild("Map")
    if not map then
        return nil
    end

    return map:FindFirstChild("WildPetSpawns")
end

local function ActiveWildPetHudGetDistanceText(spawnObject)
    local player = game:GetService("Players").LocalPlayer
    local character = player and player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if not hrp then
        return "?"
    end

    local spawnPosition = nil

    if spawnObject:IsA("BasePart") then
        spawnPosition = spawnObject.Position
    elseif spawnObject:IsA("Model") then
        local ok, pivot = pcall(function()
            return spawnObject:GetPivot()
        end)

        if ok and pivot then
            spawnPosition = pivot.Position
        end
    else
        local part = spawnObject:FindFirstChildWhichIsA("BasePart", true)
        if part then
            spawnPosition = part.Position
        end
    end

    if not spawnPosition then
        return "?"
    end

    local distance = (hrp.Position - spawnPosition).Magnitude
    return tostring(math.floor(distance + 0.5)) .. "m"
end

local function ActiveWildPetHudCleanPetName(spawnObject)
    local attrNames = {
        "PetName",
        "Name",
        "DisplayName",
        "WildPetName",
        "AnimalName",
    }

    for _, attrName in ipairs(attrNames) do
        local value = spawnObject:GetAttribute(attrName)
        if value ~= nil and tostring(value) ~= "" then
            return tostring(value)
        end
    end

    local rawName = tostring(spawnObject.Name or "Unknown")

    local fromPattern = rawName:match("^WildPet_(.-)_WildPet")
    if fromPattern and fromPattern ~= "" then
        return fromPattern:gsub("_", " ")
    end

    rawName = rawName:gsub("^WildPet_", "")
    rawName = rawName:gsub("_WildPet.*$", "")
    rawName = rawName:gsub("_", " ")

    if rawName == "" then
        return "Unknown"
    end

    return rawName
end

local function ActiveWildPetHudReadAttributeByKeywords(root, keywords)
    for _, keyword in ipairs(keywords) do
        local direct = root:GetAttribute(keyword)
        if direct ~= nil and tostring(direct) ~= "" then
            return tostring(direct)
        end
    end

    for attrName, attrValue in pairs(root:GetAttributes()) do
        local lowerName = string.lower(tostring(attrName))

        for _, keyword in ipairs(keywords) do
            if string.find(lowerName, string.lower(keyword), 1, true) and attrValue ~= nil and tostring(attrValue) ~= "" then
                return tostring(attrValue)
            end
        end
    end

    return nil
end

local function ActiveWildPetHudReadDescendantValueByKeywords(root, keywords)
    for _, descendant in ipairs(root:GetDescendants()) do
        local lowerName = string.lower(tostring(descendant.Name))

        for _, keyword in ipairs(keywords) do
            if string.find(lowerName, string.lower(keyword), 1, true) then
                if descendant:IsA("StringValue") or descendant:IsA("NumberValue") or descendant:IsA("IntValue") then
                    if descendant.Value ~= nil and tostring(descendant.Value) ~= "" then
                        return tostring(descendant.Value)
                    end
                elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                    if descendant.Text ~= nil and tostring(descendant.Text) ~= "" then
                        return tostring(descendant.Text)
                    end
                end
            end
        end
    end

    return nil
end

local function ActiveWildPetHudReadTextPattern(root, pattern)
    for _, descendant in ipairs(root:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
            local text = tostring(descendant.Text or "")
            if text ~= "" and text:match(pattern) then
                return text
            end
        end
    end

    return nil
end

local function ActiveWildPetHudReadTimer(root)
    local value =
        ActiveWildPetHudReadAttributeByKeywords(root, { "Timer", "Time", "Expire", "Expires", "Duration", "Remaining" })
        or ActiveWildPetHudReadDescendantValueByKeywords(root, { "Timer", "Time", "Expire", "Expires", "Duration", "Remaining" })
        or ActiveWildPetHudReadTextPattern(root, "%d+:%d+")
        or ActiveWildPetHudReadTextPattern(root, "%d+%s*[sSmMhH]")

    if value == nil or tostring(value) == "" then
        ActiveWildPetHudDebug("Timer unreadable for " .. tostring(root:GetFullName()))
        return "?"
    end

    return tostring(value)
end

local function ActiveWildPetHudReadPrice(root)
    local value =
        ActiveWildPetHudReadAttributeByKeywords(root, { "Price", "Cost", "Coins", "Money", "Token", "Tokens" })
        or ActiveWildPetHudReadDescendantValueByKeywords(root, { "Price", "Cost", "Coins", "Money", "Token", "Tokens" })
        or ActiveWildPetHudReadTextPattern(root, "%$%s*[%d,]+")
        or ActiveWildPetHudReadTextPattern(root, "[%d,]+%s*[¢cC]")

    if value == nil or tostring(value) == "" then
        ActiveWildPetHudDebug("Price unreadable for " .. tostring(root:GetFullName()))
        return "?"
    end

    return tostring(value)
end

local function ActiveWildPetHudIsActiveSpawn(spawnObject)
    if not spawnObject then
        return false
    end

    if not spawnObject.Parent then
        return false
    end

    if not tostring(spawnObject.Name):find("WildPet") then
        return false
    end

    if spawnObject:IsA("Model") or spawnObject:IsA("Folder") or spawnObject:IsA("BasePart") then
        return true
    end

    return false
end

local function ActiveWildPetHudBuildText()
    local root = ActiveWildPetHudGetRoot()

    if not root then
        ActiveWildPetHudDebug("workspace.Map.WildPetSpawns was not found.")
        return "Active wild pets:\nWildPetSpawns not found."
    end

    local rows = {}

    for _, spawnObject in ipairs(root:GetChildren()) do
        if ActiveWildPetHudIsActiveSpawn(spawnObject) then
            local petName = ActiveWildPetHudCleanPetName(spawnObject)
            local timerText = ActiveWildPetHudReadTimer(spawnObject)
            local priceText = ActiveWildPetHudReadPrice(spawnObject)
            local distanceText = ActiveWildPetHudGetDistanceText(spawnObject)

            table.insert(rows, {
                Pet = petName,
                Timer = timerText,
                Price = priceText,
                Distance = distanceText,
            })
        end
    end

    table.sort(rows, function(a, b)
        return tostring(a.Pet) < tostring(b.Pet)
    end)

    if #rows <= 0 then
        return "Active wild pets:\nNone found."
    end

    local lines = {
        "Active wild pets: " .. tostring(#rows),
    }

    for index, row in ipairs(rows) do
        if index > 8 then
            table.insert(lines, "... +" .. tostring(#rows - 8) .. " more")
            break
        end

        table.insert(
            lines,
            tostring(index)
                .. ". "
                .. tostring(row.Pet)
                .. " | Time: "
                .. tostring(row.Timer)
                .. " | Price: "
                .. tostring(row.Price)
                .. " | Dist: "
                .. tostring(row.Distance)
        )
    end

    return table.concat(lines, "\n")
end

local function ActiveWildPetHudRefresh(forceDebug)
    local text = ActiveWildPetHudBuildText()

    if ActiveWildPetHudLabel and ActiveWildPetHudLabel.SetText then
        ActiveWildPetHudLabel:SetText(text)
    end

    if forceDebug then
        print("[HOLY GAG2][Active Wild Pets] Manual scan result:")
        print(text)
    end
end

local function ActiveWildPetHudStartLoop()
    if ActiveWildPetHudLoopRunning then
        return
    end

    ActiveWildPetHudLoopRunning = true

    task.spawn(function()
        while ActiveWildPetHudEnabled do
            ActiveWildPetHudRefresh(false)
            task.wait(1)
        end

        ActiveWildPetHudLoopRunning = false

        if ActiveWildPetHudLabel and ActiveWildPetHudLabel.SetText then
            ActiveWildPetHudLabel:SetText("Active wild pets:\nOFF")
        end
    end)
end

HomeLivePetsSummaryLabel =
    nil

HomeActivePetsLoopRunning =
    false

HomeLivePetButtons =
    {}

HomeLivePetButtonEntries =
    {}

HomeLivePetsList =
    nil

HomeLivePetMaxButtons =
    8

RefreshHomeActivePets =
    nil

function GAG2HomeCompactDistanceText(value)

    return tostring(value or "?")
        :gsub("%s*studs", "")
        :gsub("%s+$", "")
end

function GAG2HomeBuildPetButtonText(index, entry)

    if type(entry) ~= "table" then
        return "---"
    end

    local suffix =
        ""

    if SniperIsEntryHandled(entry) == true then
        suffix = " | Sent"
    end

    return tostring(index)
        .. ". "
        .. tostring(entry.Name or "?")
        .. " | "
        .. tostring(entry.Timer or "?")
        .. " | "
        .. tostring(entry.Price or "?")
        .. " | "
        .. GAG2HomeCompactDistanceText(
            entry.Distance
        )
        .. suffix
end

function GAG2HomeSetPetButtonText(button, text)

    text =
        tostring(text or "---")

    if not button then
        return
    end

    pcall(function()

        if type(button.SetText) == "function" then

            button:SetText(
                text
            )

            return
        end

        if type(button.SetTitle) == "function" then

            button:SetTitle(
                text
            )

            return
        end

        if typeof(button) == "Instance"
        and button:IsA("TextButton") then

            button.Text =
                text

            return
        end

        if type(button) == "table" then

            if typeof(button.Button) == "Instance"
            and button.Button:IsA("TextButton") then

                button.Button.Text =
                    text

                return
            end

            if typeof(button.Main) == "Instance" then

                local textButton =
                    button.Main:FindFirstChildWhichIsA(
                        "TextButton",
                        true
                    )

                if textButton then

                    textButton.Text =
                        text
                    return
                end

                local textLabel =
                    button.Main:FindFirstChildWhichIsA(
                        "TextLabel",
                        true
                    )

                if textLabel then

                    textLabel.Text =
                        text
                    return
                end
            end
        end
    end)
end

function GAG2HomeFindFreshEntry(cachedEntry)

    if type(cachedEntry) ~= "table" then
        return nil
    end

    local wantedKey =
        SniperGetEntryKey(
            cachedEntry
        )

    if wantedKey == "" then
        return cachedEntry
    end

    local entries, reason =
        SniperGetActiveEntries()

    if reason ~= "ok" then
        return cachedEntry
    end

    for _, entry in ipairs(entries) do

        if SniperGetEntryKey(entry) == wantedKey then
            return entry
        end
    end

    return nil
end

function GAG2HomeManualBuyPetIndex(index)

    index =
        tonumber(index)

    if not index then
        return false
    end

    local cachedEntry =
        HomeLivePetButtonEntries[index]

    if type(cachedEntry) ~= "table" then

        Notify(
            "Live Pets",
            "No pet on this row.",
            3
        )

        return false
    end

    local entry =
        GAG2HomeFindFreshEntry(
            cachedEntry
        )

    if type(entry) ~= "table"
    or SniperEntryStillActive(entry) ~= true then

        Notify(
            "Live Pets",
            "That pet is no longer active.",
            3
        )

        if type(RefreshHomeActivePets) == "function" then

            RefreshHomeActivePets()
        end

        return false
    end

    if SniperState.Taming == true then

        Notify(
            "Live Pets",
            "Already buying another pet.",
            3
        )

        return false
    end

    if HomeLivePetsList
    and type(HomeLivePetsList.SetState) == "function" then

        HomeLivePetsList:SetState(
            index,
            "buying"
        )
    end

    local started =
        SniperAttemptBuyEntry(
            entry
        )

    if started == true then

        SetSniperStatus(
            "Manual buy: "
            .. tostring(entry.Name)
        )

        Notify(
            "Live Pets",
            "Buying "
            .. tostring(entry.Name)
            .. ".",
            3
        )

        if type(RefreshHomeActivePets) == "function" then

            RefreshHomeActivePets()
        end

        return true
    end

    if HomeLivePetsList
    and type(HomeLivePetsList.SetState) == "function" then

        HomeLivePetsList:SetState(
            index,
            "ready"
        )
    end

    Notify(
        "Live Pets",
        "Could not start buy. It may already be handled.",
        3
    )

    RefreshHomeActivePets()

    return false
end

function BuildHomeActivePetsText()

    local entries, reason =
        SniperGetActiveEntries()

    if reason ~= "ok" then

        return '<font color="rgb(196,181,253)"><b>Live Pets</b></font>'
            .. '\nLoading pet data...'
    end

    if #entries <= 0 then

        return '<font color="rgb(196,181,253)"><b>Live Pets</b></font>'
            .. '\nPlayers: '
            .. tostring(#Players:GetPlayers())
            .. ' | Pets: 0'
            .. '\nNo active pets.'
    end

    return '<font color="rgb(196,181,253)"><b>Live Pets</b></font>'
        .. '\nPlayers: '
        .. tostring(#Players:GetPlayers())
        .. ' | Pets: '
        .. tostring(#entries)
        .. '\nClick a row to buy.'
end

RefreshHomeActivePets = function()

    local entries, reason =
        SniperGetActiveEntries()

    for key in pairs(HomeLivePetButtonEntries) do

        HomeLivePetButtonEntries[key] =
            nil
    end

    if not HomeLivePetsList
    or type(HomeLivePetsList.SetRows) ~= "function" then
        return
    end

    if reason ~= "ok" then

        HomeLivePetsList:SetSummary(
            '<font color="rgb(196,181,253)"><b>Live Pets</b></font>'
            .. '\nLoading pet data...'
        )

        HomeLivePetsList:SetRows({})

        return
    end

    local rows =
        {}

    local maxRows =
        tonumber(HomeLivePetMaxButtons)
        or 8

    for index, entry in ipairs(entries) do

        if index > maxRows then
            break
        end

        HomeLivePetButtonEntries[index] =
            entry

        local state =
            "ready"

        if SniperIsEntryHandled(entry) == true then
            state =
                "sent"
        end

        table.insert(rows, {
            Pet =
                tostring(entry.Name or "?"),

            Timer =
                tostring(entry.Timer or "?"),

            Price =
                tostring(entry.Price or "?"),

            Distance =
                GAG2HomeCompactDistanceText(
                    entry.Distance
                ),

            State =
                state,
        })
    end

    HomeLivePetsList:SetSummary(
        '<font color="rgb(196,181,253)"><b>Live Pets</b></font>'
        .. '\n'
        .. tostring(#Players:GetPlayers())
        .. ' players · '
        .. tostring(#entries)
        .. ' pets found'
    )

    HomeLivePetsList:SetRows(
        rows
    )
end

function StartHomeActivePetsLoop()

    if HomeActivePetsLoopRunning == true then
        return
    end

    HomeActivePetsLoopRunning =
        true

    task.spawn(function()

        while HomeActivePetsLoopRunning == true do

            if type(RefreshHomeActivePets) == "function" then

            RefreshHomeActivePets()
        end
            GAG2RareWebhookScan()

            task.wait(
                1
            )
        end
    end)
end

function GAG2RareWebhookPetKey(name)

    return CleanText(name)
        :lower()
        :gsub("[_%s]+", "")
        :gsub("[^%w]", "")
end

function GAG2RareWebhookIsTarget(entry)

    if type(entry) ~= "table" then
        return false
    end

    local key =
        GAG2RareWebhookPetKey(
            entry.Name
        )

    return GAG2_RARE_PET_WEBHOOK_TARGETS[key] == true
end

function GAG2RareWebhookGetEntryKey(entry)

    if type(entry) ~= "table" then
        return ""
    end

    local uuid =
        CleanText(entry.UUID)

    if uuid ~= "" then
        return uuid
    end

    return GAG2RareWebhookPetKey(
        entry.Name
    )
end

function GAG2RareWebhookGetImageUrl(entry)

    if type(entry) ~= "table" then
        return ""
    end

    local petKey =
        GAG2RareWebhookPetKey(
            entry.Name
        )

    return CleanText(
        GAG2_RARE_PET_WEBHOOK_IMAGES[petKey]
    )
end

function GAG2RareWebhookGetRequestFunction()

    return request
        or http_request
        or (
            syn
            and syn.request
        )
        or (
            http
            and http.request
        )
        or (
            fluxus
            and fluxus.request
        )
end

function GAG2RareWebhookSend(entry)

    if type(entry) ~= "table" then
        return false
    end

    local webhookUrl =
        CleanText(
            GAG2_RARE_PET_WEBHOOK_URL
        )

    if webhookUrl == "" then
        return false
    end

    local requestFunction =
        GAG2RareWebhookGetRequestFunction()

    if type(requestFunction) ~= "function" then

        warn(
            "[HOLY GAG2 WEBHOOK]",
            "request function unsupported"
        )

        return false
    end

    local petName =
        CleanText(entry.Name)

    local priceText =
        CleanText(entry.Price)

    if priceText == "" then
        priceText = "?"
    end

    local timerText =
        CleanText(entry.Timer)

    if timerText == "" then
        timerText = "?"
    end

    local distanceText =
        CleanText(entry.Distance)

    if distanceText == "" then
        distanceText = "?"
    end

    local imageUrl =
        GAG2RareWebhookGetImageUrl(
            entry
        )

    local joinCode =
        GAG2BuildJoinCode(
            game.PlaceId,
            game.JobId
        )

    local embed = {

        title =
            "🌟 Rare Pet Found • "
            .. petName,

        color =
            0xC4B5FD,

        fields = {

            {
                name = "Pet",
                value = petName,
                inline = true,
            },

            {
                name = "Price",
                value = priceText,
                inline = true,
            },

            {
                name = "Timer",
                value = timerText,
                inline = true,
            },

            {
                name = "Distance",
                value = distanceText,
                inline = true,
            },

            {
                name = "Players",
                value =
                    tostring(#Players:GetPlayers()),
                inline = true,
            },

            {
                name = "PlaceId",
                value =
                    tostring(game.PlaceId),
                inline = true,
            },

            {
                name = "Join Code",
                value =
                    "```"
                    .. tostring(joinCode)
                    .. "```",
                inline = false,
            },

            {
                name = "JobId",
                value =
                    "```"
                    .. tostring(game.JobId)
                    .. "```",
                inline = false,
            },
        },

        footer = {
            text = "Holy GAG2",
        },

        timestamp =
            DateTime.now():ToIsoDate(),
    }

    if imageUrl ~= "" then

        embed.image = {
            url = imageUrl,
        }
    end

    local roleId =
        CleanText(
            GAG2_RARE_PET_WEBHOOK_ROLE_ID
        ):gsub("%D", "")

    local pingContent =
        roleId ~= ""
        and (
            "<@&"
            .. roleId
            .. "> 🌟 Rare pet found: **"
            .. petName
            .. "**"
            .. "\n`"
            .. tostring(joinCode)
            .. "`"
        )
        or (
            "🌟 Rare pet found: **"
            .. petName
            .. "**"
            .. "\n`"
            .. tostring(joinCode)
            .. "`"
        )

    local payload = {
        username =
            "Holy GAG2",

        content =
            pingContent,

        allowed_mentions =
            roleId ~= ""
            and {
                parse = {
                    "roles",
                },
            }
            or {
                parse = {},
            },

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
                Body =
                    (function()

                        print(
                            "[HOLY GAG2 WEBHOOK]",
                            "payload content:",
                            tostring(payload.content)
                        )

                        return HttpService:JSONEncode(
                            payload
                        )
                    end)(),
            })
        end)

    if ok ~= true then

        warn(
            "[HOLY GAG2 WEBHOOK]",
            "send failed",
            tostring(response)
        )

        return false
    end

    local statusCode =
        response
        and (
            response.StatusCode
            or response.statusCode
            or response.Status
            or response.status
        )

    if statusCode
    and (
        tonumber(statusCode) < 200
        or tonumber(statusCode) >= 300
    ) then

        warn(
            "[HOLY GAG2 WEBHOOK]",
            "bad status",
            tostring(statusCode),
            tostring(
                response.Body
                or response.body
                or ""
            )
        )

        return false
    end

    print(
        "[HOLY GAG2 WEBHOOK]",
        "sent rare pet alert:",
        petName
    )

    return true
end

function GAG2RareWebhookScan()

    local entries, reason =
        SniperGetActiveEntries()

    if reason ~= "ok" then
        return
    end

    for _, entry in ipairs(entries) do

        if GAG2RareWebhookIsTarget(entry) == true then

            local key =
                GAG2RareWebhookGetEntryKey(
                    entry
                )

            if key ~= ""
            and GAG2_RARE_PET_WEBHOOK_SENT[key] ~= true then

                GAG2_RARE_PET_WEBHOOK_SENT[key] =
                    true

                task.spawn(function()

                    local sent =
                        GAG2RareWebhookSend(
                            entry
                        )

                    if sent ~= true then

                        GAG2_RARE_PET_WEBHOOK_SENT[key] =
                            nil
                    end
                end)
            end
        end
    end
end

--==================================================
-- [4.58] MAILBOX
-- Sends pet batches through Mailbox.SendBatch.
-- Confirmed packet:
-- MailboxSendBatch(targetUserId, {{ItemKey = petId, Count = amount, Category = "Pets"}}, message)
--==================================================

GAG2_MAILBOX_STATE =
    GAG2_MAILBOX_STATE
    or {
        TargetText = "",
        PetId = "",
        PetChoice = "None",
        Amount = 500,
        Message = "",

        PetChoices = {
            "None",
        },

        ChoiceToPetId = {},
        PetCache = {},
        InventoryPets = {},

        Packets = {},
        LastStatus = "Idle.",
        LastTargetUserId = nil,
        LastPetId = "",
        LastAmount = 0,
    }

GAG2_MAILBOX_CONTROLS =
    GAG2_MAILBOX_CONTROLS
    or {}

function GAG2MailboxClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2MailboxSetStatus(text)

    local state =
        GAG2_MAILBOX_STATE

    state.LastStatus =
        tostring(text or "Idle.")

    if Options.HolyGAG2MailboxStatus then

        Options.HolyGAG2MailboxStatus:SetText(
            '<font color="rgb(196,181,253)"><b>Mailbox</b></font>'
            .. '\n'
            .. tostring(state.LastStatus)
            .. '\nTarget: '
            .. tostring(state.TargetText or "")
            .. '\nAmount: '
            .. tostring(state.Amount or 1)
        )
    end
end

function GAG2MailboxGetAmount()

    local state =
        GAG2_MAILBOX_STATE

    local amount =
        math.floor(
            tonumber(state.Amount)
            or 1
        )

    return math.clamp(
        amount,
        1,
        500
    )
end

function GAG2MailboxSetTarget(value)

    GAG2_MAILBOX_STATE.TargetText =
        GAG2MailboxClean(value)

    MarkConfigDirty()
end

function GAG2MailboxSetPetId(value)

    GAG2_MAILBOX_STATE.PetId =
        GAG2MailboxClean(value)

    MarkConfigDirty()
end

function GAG2MailboxSetAmount(value)

    GAG2_MAILBOX_STATE.Amount =
        math.clamp(
            math.floor(
                tonumber(value)
                or 1
            ),
            1,
            500
        )

    GAG2MailboxSetStatus(
        "Send Amount set: "
        .. tostring(GAG2_MAILBOX_STATE.Amount)
    )

    MarkConfigDirty()
end

function GAG2MailboxSetMessage(value)

    GAG2_MAILBOX_STATE.Message =
        tostring(value or "")

    MarkConfigDirty()
end

function GAG2MailboxSafeRawGet(tbl, key)

    if type(tbl) ~= "table" then
        return nil
    end

    local ok, result =
        pcall(function()

            return rawget(
                tbl,
                key
            )
        end)

    if ok == true then
        return result
    end

    return nil
end

function GAG2MailboxSafePairs(tbl)

    if type(tbl) ~= "table" then
        return {}
    end

    local ok, rows =
        pcall(function()

            local result =
                {}

            for key, value in pairs(tbl) do

                table.insert(result, {
                    Key = key,
                    Value = value,
                })
            end

            return result
        end)

    if ok == true
    and type(rows) == "table" then

        return rows
    end

    return {}
end

function GAG2MailboxIsUuid(value)

    value =
        GAG2MailboxClean(value):lower()

    return value:match(
        "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"
    ) ~= nil
end

function GAG2MailboxShortUuid(value)

    value =
        GAG2MailboxClean(value)

    if #value <= 8 then
        return value
    end

    return value:sub(
        1,
        8
    )
end

function GAG2MailboxReadPetName(petData, fallback)

    fallback =
        GAG2MailboxClean(fallback)

    if type(petData) == "table" then

        local keys = {
            "Name",
            "PetName",
            "PetType",
            "Type",
            "f",
        }

        for _, key in ipairs(keys) do

            local value =
                GAG2MailboxClean(
                    GAG2MailboxSafeRawGet(
                        petData,
                        key
                    )
                )

            if value ~= "" then
                return value
            end
        end
    end

    if fallback ~= "" then
        return fallback
    end

    return "Unknown Pet"
end

function GAG2MailboxReadPetExtra(petData)

    if type(petData) ~= "table" then
        return ""
    end

    local parts =
        {}

    local mutation =
        GAG2MailboxClean(
            GAG2MailboxSafeRawGet(
                petData,
                "Mutation"
            )
        )

    local level =
        GAG2MailboxClean(
            GAG2MailboxSafeRawGet(
                petData,
                "Level"
            )
            or GAG2MailboxSafeRawGet(
                petData,
                "Age"
            )
        )

    local equipped =
        GAG2MailboxSafeRawGet(
            petData,
            "Equipped"
        )

    if mutation ~= ""
    and mutation ~= "None"
    and mutation ~= "Normal" then

        table.insert(
            parts,
            mutation
        )
    end

    if level ~= "" then

        table.insert(
            parts,
            "Age "
            .. tostring(level)
        )
    end

    if equipped == true then

        table.insert(
            parts,
            "Equipped"
        )
    end

    return table.concat(
        parts,
        " · "
    )
end

function GAG2MailboxAddPetEntry(target, seen, uuid, petData, source)

    uuid =
        GAG2MailboxClean(uuid)

    if GAG2MailboxIsUuid(uuid) ~= true then
        return false
    end

    if seen[uuid] == true then
        return false
    end

    seen[uuid] =
        true

    local name =
        GAG2MailboxReadPetName(
            petData,
            "Unknown Pet"
        )

    local extra =
        GAG2MailboxReadPetExtra(
            petData
        )

    table.insert(target, {
        Id = uuid,
        Name = name,
        Extra = extra,
        Source = tostring(source or "unknown"),
        Raw = petData,
    })

    return true
end

function GAG2MailboxScanPetTable(petsTable, target, seen, source)

    if type(petsTable) ~= "table" then
        return 0
    end

    local added =
        0

    local scanned =
        0

    for _, row in ipairs(GAG2MailboxSafePairs(petsTable)) do

        scanned += 1

        if scanned > 3000 then
            break
        end

        local key =
            GAG2MailboxClean(row.Key)

        local value =
            row.Value

        local uuid =
            ""

        if GAG2MailboxIsUuid(key) == true then

            uuid =
                key

        elseif type(value) == "table" then

            uuid =
                GAG2MailboxClean(
                    GAG2MailboxSafeRawGet(value, "Id")
                    or GAG2MailboxSafeRawGet(value, "UUID")
                    or GAG2MailboxSafeRawGet(value, "Uuid")
                    or GAG2MailboxSafeRawGet(value, "ItemKey")
                )
        end

        if GAG2MailboxAddPetEntry(
            target,
            seen,
            uuid,
            value,
            source
        ) == true then

            added += 1
        end
    end

    return added
end

function GAG2MailboxScanGcInventoryPets(target, seen)

    if type(getgc) ~= "function" then
        return 0
    end

    local ok, gc =
        pcall(function()

            return getgc(true)
        end)

    if ok ~= true
    or type(gc) ~= "table" then

        return 0
    end

    local added =
        0

    local scanned =
        0

    for _, candidate in ipairs(gc) do

        scanned += 1

        if scanned > 30000 then
            break
        end

        if type(candidate) == "table" then

            local inventory =
                GAG2MailboxSafeRawGet(
                    candidate,
                    "Inventory"
                )

            if type(inventory) == "table" then

                local pets =
                    GAG2MailboxSafeRawGet(
                        inventory,
                        "Pets"
                    )

                added +=
                    GAG2MailboxScanPetTable(
                        pets,
                        target,
                        seen,
                        "Inventory.Pets"
                    )
            end

            local directPets =
                GAG2MailboxSafeRawGet(
                    candidate,
                    "Pets"
                )

            added +=
                GAG2MailboxScanPetTable(
                    directPets,
                    target,
                    seen,
                    "Pets"
                )
        end
    end

    return added
end

function GAG2MailboxScanToolPets(target, seen)

    local localPlayer =
        LOCAL_PLAYER
        or Players.LocalPlayer

    if not localPlayer then
        return 0
    end

    local containers = {
        localPlayer:FindFirstChildOfClass("Backpack"),
        localPlayer.Character,
    }

    local added =
        0

    for _, container in ipairs(containers) do

        if container then

            for _, child in ipairs(container:GetChildren()) do

                if child:IsA("Tool") then

                    local uuid =
                        GAG2MailboxClean(
                            child:GetAttribute("Id")
                            or child:GetAttribute("UUID")
                            or child:GetAttribute("Uuid")
                            or child:GetAttribute("PetId")
                            or child:GetAttribute("ItemKey")
                        )

                    local petName =
                        GAG2MailboxClean(
                            child:GetAttribute("Name")
                            or child:GetAttribute("PetName")
                            or child:GetAttribute("PetType")
                            or child:GetAttribute("f")
                            or child.Name
                        )

                    if GAG2MailboxAddPetEntry(
                        target,
                        seen,
                        uuid,
                        {
                            Name = petName,
                        },
                        "Tool"
                    ) == true then

                        added += 1
                    end
                end
            end
        end
    end

    return added
end

function GAG2MailboxBuildInventoryPets()

    local state =
        GAG2_MAILBOX_STATE

    local pets =
        {}

    local seen =
        {}

    if type(state.PetCache) == "table" then

        for uuid, petData in pairs(state.PetCache) do

            GAG2MailboxAddPetEntry(
                pets,
                seen,
                uuid,
                petData,
                "ReplicaSet cache"
            )
        end
    end

    GAG2MailboxScanGcInventoryPets(
        pets,
        seen
    )

    GAG2MailboxScanToolPets(
        pets,
        seen
    )

    table.sort(pets, function(a, b)

        local aName =
            tostring(a.Name or "")

        local bName =
            tostring(b.Name or "")

        if aName == bName then

            return tostring(a.Id or "")
                < tostring(b.Id or "")
        end

        return aName < bName
    end)

    state.InventoryPets =
        pets

    return pets
end

function GAG2MailboxBuildPetChoice(pet)

    local name =
        GAG2MailboxClean(
            pet
            and pet.Name
            or "Unknown Pet"
        )

    local uuid =
        GAG2MailboxClean(
            pet
            and pet.Id
            or ""
        )

    local extra =
        GAG2MailboxClean(
            pet
            and pet.Extra
            or ""
        )

    local text =
        name
        .. " · #"
        .. GAG2MailboxShortUuid(uuid)

    if extra ~= "" then

        text =
            text
            .. " · "
            .. extra
    end

    return text
end

function GAG2MailboxSetPetChoice(value)

    local state =
        GAG2_MAILBOX_STATE

    local choice =
        GAG2MailboxClean(value)

    if choice == "" then
        choice = "None"
    end

    state.PetChoice =
        choice

    local petId =
        state.ChoiceToPetId
        and state.ChoiceToPetId[choice]
        or ""

    state.PetId =
        GAG2MailboxClean(petId)

    if state.PetId ~= "" then

        GAG2MailboxSetStatus(
            "Selected pet: "
            .. tostring(choice)
        )

    else

        GAG2MailboxSetStatus(
            "No pet selected."
        )
    end

    MarkConfigDirty()
end

function GAG2MailboxRefreshPetDropdown()

    local state =
        GAG2_MAILBOX_STATE

    local dropdown =
        GAG2_MAILBOX_CONTROLS
        and GAG2_MAILBOX_CONTROLS.Pet

    local pets =
        GAG2MailboxBuildInventoryPets()

    local values = {
        "None",
    }

    local choiceToPetId =
        {}

    local usedChoices =
        {
            None = true,
        }

    local function addChoice(choice, uuid)

        choice =
            GAG2MailboxClean(choice)

        uuid =
            GAG2MailboxClean(uuid)

        if choice == ""
        or uuid == "" then
            return
        end

        local baseChoice =
            choice

        local suffix =
            2

        while usedChoices[choice] == true do

            choice =
                baseChoice
                .. " · "
                .. tostring(suffix)

            suffix += 1
        end

        usedChoices[choice] =
            true

        choiceToPetId[choice] =
            uuid

        table.insert(
            values,
            choice
        )
    end

    for _, pet in ipairs(pets) do

        addChoice(
            GAG2MailboxBuildPetChoice(pet),
            pet.Id
        )
    end

    local savedPetId =
        GAG2MailboxClean(
            state.PetId
        )

    if savedPetId ~= ""
    and GAG2MailboxIsUuid(savedPetId) == true then

        local alreadyVisible =
            false

        for _, uuid in pairs(choiceToPetId) do

            if uuid == savedPetId then
                alreadyVisible =
                    true
                break
            end
        end

        if alreadyVisible ~= true then

            addChoice(
                "Saved Pet"
                .. " · #"
                .. GAG2MailboxShortUuid(savedPetId),
                savedPetId
            )
        end
    end

    state.PetChoices =
        values

    state.ChoiceToPetId =
        choiceToPetId

    if dropdown then

        pcall(function()

            if type(dropdown.SetValues) == "function" then

                dropdown:SetValues(
                    values
                )

            elseif type(dropdown.SetItems) == "function" then

                dropdown:SetItems(
                    values
                )
            end
        end)

        local selected =
            GAG2MailboxClean(
                state.PetChoice
            )

        if selected == ""
        or selected == "None"
        or choiceToPetId[selected] == nil then

            selected =
                "None"
        end

        pcall(function()

            if type(dropdown.SetValue) == "function" then

                dropdown:SetValue(
                    selected
                )
            end
        end)
    end

    GAG2MailboxSetStatus(
        "Pets refreshed: "
        .. tostring(#pets)
    )

    return pets
end

function GAG2MailboxStartReplicaWatcher()

    local state =
        GAG2_MAILBOX_STATE

    if state.ReplicaWatching == true then
        return
    end

    local remoteEvents =
        ReplicatedStorage:FindFirstChild("RemoteEvents")

    local replicaSet =
        remoteEvents
        and remoteEvents:FindFirstChild("ReplicaSet")

    if not replicaSet then

        GAG2MailboxSetStatus(
            "ReplicaSet missing for pet cache."
        )

        return
    end

    state.ReplicaWatching =
        true

    replicaSet.OnClientEvent:Connect(function(_, path, value)

        if type(path) ~= "table" then
            return
        end

        if tostring(path[1]) ~= "Inventory" then
            return
        end

        if tostring(path[2]) ~= "Pets" then
            return
        end

        local uuid =
            GAG2MailboxClean(
                path[3]
            )

        if GAG2MailboxIsUuid(uuid) ~= true then
            return
        end

        state.PetCache =
            type(state.PetCache) == "table"
            and state.PetCache
            or {}

        if type(value) == "table" then

            state.PetCache[uuid] =
                value

        else

            state.PetCache[uuid] =
                nil
        end

        task.defer(function()

            GAG2MailboxRefreshPetDropdown()
        end)
    end)
end

function GAG2MailboxResolveTargetUserId(targetText)

    targetText =
        GAG2MailboxClean(targetText)

    if targetText == "" then
        return nil,
            "missing target"
    end

    local asNumber =
        tonumber(targetText)

    if asNumber
    and asNumber > 0 then

        return math.floor(asNumber),
            "user id"
    end

    targetText =
        targetText:gsub("^@", "")

    local localPlayerMatch =
        Players:FindFirstChild(targetText)

    if localPlayerMatch then

        return localPlayerMatch.UserId,
            "server player"
    end

    local ok, userId =
        pcall(function()

            return Players:GetUserIdFromNameAsync(
                targetText
            )
        end)

    if ok == true
    and tonumber(userId) then

        return tonumber(userId),
            "username lookup"
    end

    return nil,
        "target lookup failed"
end

function GAG2MailboxPacketHasFire(packet)

    if type(packet) ~= "table" then
        return false
    end

    local ok, fireFunction =
        pcall(function()

            return packet.Fire
        end)

    return ok == true
        and type(fireFunction) == "function"
end

function GAG2MailboxSearchPacketByName(candidate, packetName, seen, depth)

    if type(candidate) ~= "table" then
        return nil
    end

    if depth > 8 then
        return nil
    end

    if seen[candidate] == true then
        return nil
    end

    seen[candidate] =
        true

    if type(SniperSafeRawGet) == "function" then

        local name =
            SniperSafeRawGet(
                candidate,
                "Name"
            )

        if tostring(name) == tostring(packetName)
        and GAG2MailboxPacketHasFire(candidate) == true then

            return candidate
        end
    end

    if type(SniperSafePairsSnapshot) == "function" then

        for _, row in ipairs(SniperSafePairsSnapshot(candidate)) do

            if type(row.Value) == "table" then

                local found =
                    GAG2MailboxSearchPacketByName(
                        row.Value,
                        packetName,
                        seen,
                        depth + 1
                    )

                if found then
                    return found
                end
            end
        end

    else

        for _, child in pairs(candidate) do

            if type(child) == "table" then

                local found =
                    GAG2MailboxSearchPacketByName(
                        child,
                        packetName,
                        seen,
                        depth + 1
                    )

                if found then
                    return found
                end
            end
        end
    end

    return nil
end

function GAG2MailboxResolvePacket(keyName, packetName)

    keyName =
        GAG2MailboxClean(keyName)

    packetName =
        GAG2MailboxClean(packetName)

    if keyName == ""
    or packetName == "" then

        return nil,
            "bad mailbox packet request"
    end

    local state =
        GAG2_MAILBOX_STATE

    state.Packets =
        type(state.Packets) == "table"
        and state.Packets
        or {}

    if state.Packets[keyName] then
        return state.Packets[keyName],
            "cached"
    end

    local packets =
        nil

    if type(SniperFindPacketTable) == "function" then

        packets =
            SniperFindPacketTable()
    end

    if type(packets) == "table"
    and type(SniperSafeRawGet) == "function" then

        local mailbox =
            SniperSafeRawGet(
                packets,
                "Mailbox"
            )

        if type(mailbox) == "table" then

            local packet =
                SniperSafeRawGet(
                    mailbox,
                    keyName
                )

            if GAG2MailboxPacketHasFire(packet) == true then

                state.Packets[keyName] =
                    packet

                return packet,
                    "Mailbox."
                    .. tostring(keyName)
            end
        end

        local found =
            GAG2MailboxSearchPacketByName(
                packets,
                packetName,
                {},
                0
            )

        if found then

            state.Packets[keyName] =
                found

            return found,
                "search:"
                .. tostring(packetName)
        end
    end

    return nil,
        "packet not found: "
        .. tostring(packetName)
        .. " | source: "
        .. tostring(
            SniperState
            and SniperState.PacketSource
            or "no packet source"
        )
end

function GAG2MailboxFirePacket(keyName, packetName, ...)

    local packet, source =
        GAG2MailboxResolvePacket(
            keyName,
            packetName
        )

    if not packet then

        GAG2MailboxSetStatus(
            "Packet missing: "
            .. tostring(source)
        )

        warn(
            "[HOLY GAG2 MAILBOX]",
            "packet missing",
            tostring(keyName),
            tostring(packetName),
            tostring(source)
        )

        return false,
            source
    end

    local args =
        {
            ...
        }

    local ok, err =
        pcall(function()

            packet:Fire(
                table.unpack(args)
            )
        end)

    if ok ~= true then

        ok, err =
            pcall(function()

                packet.Fire(
                    packet,
                    table.unpack(args)
                )
            end)
    end

    if ok ~= true then

        GAG2MailboxSetStatus(
            "Fire failed: "
            .. tostring(err)
        )

        warn(
            "[HOLY GAG2 MAILBOX]",
            "fire failed",
            tostring(packetName),
            tostring(err)
        )

        return false,
            tostring(err)
    end

    return true,
        source
end

function GAG2MailboxOpenInbox()

    local ok, source =
        GAG2MailboxFirePacket(
            "OpenInbox",
            "MailboxOpenInbox"
        )

    if ok == true then

        GAG2MailboxSetStatus(
            "Opened inbox | "
            .. tostring(source)
        )
    end

    return ok,
        source
end

function GAG2MailboxSendPetBatchNow()

    local state =
        GAG2_MAILBOX_STATE

    local targetUserId, targetReason =
        GAG2MailboxResolveTargetUserId(
            state.TargetText
        )

    if not targetUserId then

        GAG2MailboxSetStatus(
            "Bad target: "
            .. tostring(targetReason)
        )

        return false,
            targetReason
    end

    local petId =
        GAG2MailboxClean(
            state.PetId
        )

    if petId == ""
    and state.ChoiceToPetId
    and state.PetChoice then

        petId =
            GAG2MailboxClean(
                state.ChoiceToPetId[state.PetChoice]
            )

        state.PetId =
            petId
    end

    if petId == "" then

        GAG2MailboxSetStatus(
            "Missing Pet UUID."
        )

        return false,
            "missing pet id"
    end

    if petId:find("%.") then

        GAG2MailboxSetStatus(
            "Bad Pet UUID. Paste only the raw UUID."
        )

        return false,
            "bad pet id"
    end

    local amount =
        GAG2MailboxGetAmount()

    local message =
        tostring(state.Message or "")

    local batch = {
        {
            ItemKey =
                petId,

            Count =
                amount,

            Category =
                "Pets",
        },
    }

    local ok, source =
        GAG2MailboxFirePacket(
            "SendBatch",
            "MailboxSendBatch",
            targetUserId,
            batch,
            message
        )

    if ok == true then

        state.LastTargetUserId =
            targetUserId

        state.LastPetId =
            petId

        state.LastAmount =
            amount

        GAG2MailboxSetStatus(
            "Sent pet batch."
            .. "\nUserId: "
            .. tostring(targetUserId)
            .. " ("
            .. tostring(targetReason)
            .. ")"
            .. "\nPet: "
            .. tostring(petId)
            .. "\nCount: "
            .. tostring(amount)
            .. "\nSource: "
            .. tostring(source)
        )

        print(
            "[HOLY GAG2 MAILBOX]",
            "MailboxSendBatch fired",
            "| userId:",
            tostring(targetUserId),
            "| petId:",
            tostring(petId),
            "| count:",
            tostring(amount),
            "| source:",
            tostring(source)
        )

        return true,
            source
    end

    return false,
        source
end

function GAG2MailboxExposeDebug()

    getgenv().HOLY_GAG2_MAILBOX_STATE =
        GAG2_MAILBOX_STATE

    getgenv().HOLY_GAG2_MAILBOX_SEND_PET_BATCH =
        function(targetUserId, petId, amount, message)

            GAG2_MAILBOX_STATE.TargetText =
                tostring(targetUserId or "")

            GAG2_MAILBOX_STATE.PetId =
                tostring(petId or "")

            GAG2_MAILBOX_STATE.Amount =
                math.clamp(
                    math.floor(
                        tonumber(amount)
                        or 1
                    ),
                    1,
                    500
                )

            GAG2_MAILBOX_STATE.Message =
                tostring(message or "")

            return GAG2MailboxSendPetBatchNow()
        end

    getgenv().HOLY_GAG2_MAILBOX_OPEN_INBOX =
        function()

            return GAG2MailboxOpenInbox()
        end
end

function GAG2RestoreMailboxState()

    task.defer(function()

        GAG2MailboxExposeDebug()
        GAG2MailboxStartReplicaWatcher()

        if Options.HolyGAG2MailboxTarget then

            GAG2MailboxSetTarget(
                Options.HolyGAG2MailboxTarget.Value
            )
        end

        if Options.HolyGAG2MailboxPetChoice then

            GAG2MailboxSetPetChoice(
                Options.HolyGAG2MailboxPetChoice.Value
            )
        end

        if Options.HolyGAG2MailboxAmount then

            GAG2MailboxSetAmount(
                Options.HolyGAG2MailboxAmount.Value
            )
        end

        if Options.HolyGAG2MailboxMessage then

            GAG2MailboxSetMessage(
                Options.HolyGAG2MailboxMessage.Value
            )
        end

        GAG2MailboxRefreshPetDropdown()

        GAG2MailboxSetStatus(
            "Ready."
        )
    end)
end

--==================================================
-- [4.59] EXPERIMENT AUTO DROP SEED
-- Real seed drop packet path.
-- Confirmed sequence:
-- 1. Equip seed tool
-- 2. 14 01 Seeds.<Seed>
-- 3. Shovel:Shovel + Seed:<Seed>
-- 4. 08 01 <uuid1> <uuid2> <position>
--==================================================

GAG2_AUTO_DROP_SEED_STATE =
    GAG2_AUTO_DROP_SEED_STATE
    or {
        Enabled = false,
        Running = false,

        Seed = "Rainbow",
        Amount = 1,
        Delay = 0.35,
        Burst = 1,

        Dropped = 0,
        LastStatus = "Idle.",
        LastError = "",
        LastSeed = "",
        LastPosition = nil,

        SeedSlots = {
            Rainbow = 2,
            Gold = 3,
        },
    }

function GAG2SeedDropClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2SeedDropSetStatus(text)

    local state =
        GAG2_AUTO_DROP_SEED_STATE

    state.LastStatus =
        tostring(text or "Idle.")

    if Options.HolyGAG2ExperimentStatus then

        Options.HolyGAG2ExperimentStatus:SetText(
            '<font color="rgb(196,181,253)"><b>Auto Drop Seed</b></font>'
            .. '\nState: '
            .. (
                state.Enabled == true
                and "ON"
                or "OFF"
            )
            .. ' | Running: '
            .. tostring(state.Running == true)
            .. '\nSeed: '
            .. tostring(state.Seed or "Rainbow")
            .. ' | Dropped: '
            .. tostring(state.Dropped or 0)
            .. '/'
            .. tostring(state.Amount or 1)
            .. '\nBurst: '
            .. tostring(state.Burst or 1)
            .. ' | Delay: '
            .. tostring(state.Delay or 0.35)
            .. 's'
            .. '\n'
            .. tostring(state.LastStatus)
        )
    end
end

function GAG2SeedDropWriteAscii(packet, offset, text)

    text =
        tostring(text or "")

    for index = 1, #text do

        buffer.writeu8(
            packet,
            offset + index - 1,
            string.byte(text, index)
        )
    end
end

function GAG2SeedDropBufferToHex(packet)

    local length =
        buffer.len(packet)

    local output =
        table.create(length)

    for index = 0, length - 1 do

        output[#output + 1] =
            string.format(
                "%02X",
                buffer.readu8(packet, index)
            )
    end

    return table.concat(
        output
    )
end

function GAG2SeedDropGetRemote()

    local sharedModules =
        ReplicatedStorage:FindFirstChild("SharedModules")

    local packetFolder =
        sharedModules
        and sharedModules:FindFirstChild("Packet")

    local remote =
        packetFolder
        and packetFolder:FindFirstChild("RemoteEvent")

    if remote
    and remote:IsA("RemoteEvent") then

        return remote
    end

    return nil
end

function GAG2SeedDropBuildSelectPacket(seedName)

    seedName =
        tostring(seedName or "Rainbow")

    local prefix =
        "Seeds"

    local packet =
        buffer.create(
            3
            + #prefix
            + 1
            + #seedName
        )

    local offset =
        0

    buffer.writeu8(packet, offset, 0x14)
    offset += 1

    buffer.writeu8(packet, offset, 0x01)
    offset += 1

    buffer.writeu8(packet, offset, #prefix)
    offset += 1

    GAG2SeedDropWriteAscii(
        packet,
        offset,
        prefix
    )

    offset += #prefix

    buffer.writeu8(packet, offset, #seedName)
    offset += 1

    GAG2SeedDropWriteAscii(
        packet,
        offset,
        seedName
    )

    return packet
end

function GAG2SeedDropBuildStatePacket(seedName, slotIndex)

    seedName =
        tostring(seedName or "Rainbow")

    slotIndex =
        tonumber(slotIndex)
        or 2

    local shovelText =
        "Shovel:Shovel"

    local seedText =
        "Seed:" .. seedName

    local packet =
        buffer.create(
            7
            + #shovelText
            + 4
            + #seedText
            + 1
        )

    local offset =
        0

    buffer.writeu8(packet, offset, 0x60)
    offset += 1

    buffer.writeu8(packet, offset, 0x00)
    offset += 1

    buffer.writeu8(packet, offset, 0x1C)
    offset += 1

    buffer.writeu8(packet, offset, 0x05)
    offset += 1

    buffer.writeu8(packet, offset, 0x01)
    offset += 1

    buffer.writeu8(packet, offset, 0x0B)
    offset += 1

    buffer.writeu8(packet, offset, #shovelText)
    offset += 1

    GAG2SeedDropWriteAscii(
        packet,
        offset,
        shovelText
    )

    offset += #shovelText

    buffer.writeu8(packet, offset, 0x05)
    offset += 1

    buffer.writeu8(packet, offset, slotIndex)
    offset += 1

    buffer.writeu8(packet, offset, 0x0B)
    offset += 1

    buffer.writeu8(packet, offset, #seedText)
    offset += 1

    GAG2SeedDropWriteAscii(
        packet,
        offset,
        seedText
    )

    offset += #seedText

    buffer.writeu8(packet, offset, 0x00)

    return packet
end

function GAG2SeedDropBuildRealDropPacket(position)

    if typeof(position) ~= "Vector3" then

        position =
            Vector3.zero
    end

    local uuid1 =
        HttpService:GenerateGUID(false):lower()

    local uuid2 =
        HttpService:GenerateGUID(false):lower()

    local packet =
        buffer.create(88)

    buffer.writeu8(packet, 0, 0x08)
    buffer.writeu8(packet, 1, 0x01)

    buffer.writeu8(packet, 2, 0x24)

    GAG2SeedDropWriteAscii(
        packet,
        3,
        uuid1
    )

    buffer.writeu8(packet, 39, 0x24)

    GAG2SeedDropWriteAscii(
        packet,
        40,
        uuid2
    )

    buffer.writef32(packet, 76, position.X)
    buffer.writef32(packet, 80, position.Y)
    buffer.writef32(packet, 84, position.Z)

    return packet,
        uuid1,
        uuid2
end

function GAG2SeedDropGetCharacter()

    return LOCAL_PLAYER.Character
        or LOCAL_PLAYER.CharacterAdded:Wait()
end

function GAG2SeedDropGetBackpack()

    return LOCAL_PLAYER:FindFirstChildOfClass("Backpack")
        or LOCAL_PLAYER:WaitForChild("Backpack")
end

function GAG2SeedDropIsRealSeedTool(tool, seedName)

    if typeof(tool) ~= "Instance"
    or not tool:IsA("Tool") then

        return false
    end

    seedName =
        GAG2SeedDropClean(seedName):lower()

    if seedName == "" then

        return false
    end

    local toolName =
        tostring(tool.Name or ""):lower()

    local seedTool =
        tostring(tool:GetAttribute("SeedTool") or ""):lower()

    local mainCategory =
        tostring(tool:GetAttribute("MainCategory") or ""):lower()

    -- Real confirmed seed tools look like:
    -- Name = Rainbow / Gold
    -- SeedTool = Rainbow / Gold
    -- MainCategory = Seed
    if seedTool ~= "" then

        return seedTool == seedName
            and mainCategory == "seed"
    end

    -- Fallback for seed tools that only expose MainCategory.
    if mainCategory == "seed"
    and toolName == seedName then

        return true
    end

    return false
end

function GAG2SeedDropFindTool(seedName)

    seedName =
        GAG2SeedDropClean(seedName)

    local character =
        GAG2SeedDropGetCharacter()

    local backpack =
        GAG2SeedDropGetBackpack()

    for _, item in ipairs(character:GetChildren()) do

        if GAG2SeedDropIsRealSeedTool(
            item,
            seedName
        ) then

            return item
        end
    end

    for _, item in ipairs(backpack:GetChildren()) do

        if GAG2SeedDropIsRealSeedTool(
            item,
            seedName
        ) then

            return item
        end
    end

    return nil
end

function GAG2SeedDropCleanSeedName(value)

    value =
        GAG2SeedDropClean(value)

    local beforePipe =
        value:match("^(.-)%s+|%s+")

    if beforePipe
    and GAG2SeedDropClean(beforePipe) ~= "" then

        value =
            GAG2SeedDropClean(beforePipe)
    end

    return value
end

function GAG2SeedDropAddSeedValue(values, seen, seedName)

    seedName =
        GAG2SeedDropCleanSeedName(
            seedName
        )

    if seedName == "" then
        return
    end

    local key =
        seedName:lower()

    if seen[key] == true then
        return
    end

    seen[key] =
        true

    values[#values + 1] =
        seedName
end

function GAG2SeedDropReadSeedNameFromTool(tool)

    if typeof(tool) ~= "Instance"
    or tool:IsA("Tool") ~= true then

        return ""
    end

    local mainCategory =
        GAG2SeedDropClean(
            tool:GetAttribute("MainCategory")
        )

    local seedTool =
        GAG2SeedDropClean(
            tool:GetAttribute("SeedTool")
        )

    if mainCategory:lower() ~= "seed" then
        return ""
    end

    if seedTool ~= "" then
        return seedTool
    end

    return GAG2SeedDropClean(
        tool.Name
    )
end

function GAG2SeedDropGetAllSeedValues()

    local values =
        {}

    local seen =
        {}

    -- Main source: all known shop seed names.
    if type(GAG2ShopGetItemNames) == "function" then

        local shopSeeds =
            GAG2ShopGetItemNames(
                "Seeds"
            )

        if type(shopSeeds) == "table" then

            for _, seedName in ipairs(shopSeeds) do

                GAG2SeedDropAddSeedValue(
                    values,
                    seen,
                    seedName
                )
            end
        end
    end

    -- Backup source: Seed Planting list, if available.
    if type(GAG2SeedPlantGetSeedValues) == "function" then

        local plantSeeds =
            GAG2SeedPlantGetSeedValues()

        if type(plantSeeds) == "table" then

            for _, seedName in ipairs(plantSeeds) do

                GAG2SeedDropAddSeedValue(
                    values,
                    seen,
                    seedName
                )
            end
        end
    end

    -- Include current saved selection.
    if GAG2_AUTO_DROP_SEED_STATE then

        GAG2SeedDropAddSeedValue(
            values,
            seen,
            GAG2_AUTO_DROP_SEED_STATE.Seed
        )
    end

    -- Include currently owned real seed tools too.
    local function scan(container)

        if typeof(container) ~= "Instance" then
            return
        end

        for _, child in ipairs(container:GetChildren()) do

            local seedName =
                GAG2SeedDropReadSeedNameFromTool(
                    child
                )

            if seedName ~= "" then

                GAG2SeedDropAddSeedValue(
                    values,
                    seen,
                    seedName
                )
            end
        end
    end

    scan(
        LOCAL_PLAYER.Character
    )

    scan(
        LOCAL_PLAYER:FindFirstChildOfClass("Backpack")
    )

    -- Confirmed manual-drop seed tools / fallback values.
    GAG2SeedDropAddSeedValue(values, seen, "Rainbow")
    GAG2SeedDropAddSeedValue(values, seen, "Gold")
    GAG2SeedDropAddSeedValue(values, seen, "Carrot")

    table.sort(
        values,
        function(a, b)

            return tostring(a):lower()
                < tostring(b):lower()
        end
    )

    return values
end

function GAG2SeedDropRefreshDropdown()

    local controls =
        GAG2_AUTO_DROP_SEED_CONTROLS

    local dropdown =
        controls
        and controls.Seed

    if not dropdown then
        return
    end

    local values =
        GAG2SeedDropGetAllSeedValues()

    pcall(function()

        if type(dropdown.SetValues) == "function" then

            dropdown:SetValues(
                values
            )

        elseif type(dropdown.SetItems) == "function" then

            dropdown:SetItems(
                values
            )
        end
    end)

    GAG2SeedDropSetStatus(
        "Loaded "
        .. tostring(#values)
        .. " known seed type(s)."
    )
end

function GAG2SeedDropEquipTool(seedName)

    local character =
        GAG2SeedDropGetCharacter()

    local tool =
        GAG2SeedDropFindTool(seedName)

    if not tool then

        return false,
            "missing seed tool: " .. tostring(seedName)
    end

    if tool.Parent == character then

        return true,
            tool
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if not humanoid then

        return false,
            "missing humanoid"
    end

    humanoid:EquipTool(
        tool
    )

    task.wait(
        0.22
    )

    if tool.Parent ~= character then

        return false,
            "equip failed: " .. tostring(tool.Name)
    end

    return true,
        tool
end

function GAG2SeedDropGetPosition(burstIndex)

    burstIndex =
        math.max(
            1,
            math.floor(
                tonumber(burstIndex)
                or 1
            )
        )

    local character =
        GAG2SeedDropGetCharacter()

    local root =
        character
        and character:FindFirstChild("HumanoidRootPart")

    if not root then

        return Vector3.zero
    end

    local row =
        math.floor((burstIndex - 1) / 5)

    local column =
        (burstIndex - 1) % 5

    local sideOffset =
        (column - 2) * 0.65

    local forwardOffset =
        row * 0.65

    local target =
        root.Position
        + (root.CFrame.LookVector * (5 + forwardOffset))
        + (root.CFrame.RightVector * sideOffset)

    local rayParams =
        RaycastParams.new()

    rayParams.FilterType =
        Enum.RaycastFilterType.Exclude

    rayParams.FilterDescendantsInstances =
        {
            character,
        }

    rayParams.IgnoreWater =
        true

    local result =
        workspace:Raycast(
            target + Vector3.new(0, 12, 0),
            Vector3.new(0, -80, 0),
            rayParams
        )

    if result
    and typeof(result.Position) == "Vector3" then

        return result.Position
            + Vector3.new(0, 0.65, 0)
    end

    return target
end

function GAG2SeedDropFire(packet, label)

    local remote =
        GAG2SeedDropGetRemote()

    if not remote then

        return false,
            "SharedModules.Packet.RemoteEvent missing"
    end

    local ok, err =
        pcall(function()

            remote:FireServer(
                packet
            )
        end)

    if ok ~= true then

        return false,
            tostring(err)
    end

    return true,
        tostring(label or "fired")
end

function GAG2SeedDropSetSeed(value)

    value =
        GAG2SeedDropCleanSeedName(
            value
        )

    if value == "" then

        value =
            "Rainbow"
    end

    GAG2_AUTO_DROP_SEED_STATE.Seed =
        value

    GAG2SeedDropSetStatus(
        "Seed set: "
        .. tostring(value)
    )

    MarkConfigDirty()
end

function GAG2SeedDropSetAmount(value)

    local amount =
        math.floor(
            tonumber(value)
            or 1
        )

    GAG2_AUTO_DROP_SEED_STATE.Amount =
        math.max(
            1,
            amount
        )

    GAG2SeedDropSetStatus(
        "Amount set: "
        .. tostring(GAG2_AUTO_DROP_SEED_STATE.Amount)
    )

    MarkConfigDirty()
end

function GAG2SeedDropSetDelay(value)

    local delaySeconds =
        tonumber(value)
        or 0.35

    GAG2_AUTO_DROP_SEED_STATE.Delay =
        math.clamp(
            delaySeconds,
            0,
            10
        )

    GAG2SeedDropSetStatus(
        "Delay set: "
        .. tostring(GAG2_AUTO_DROP_SEED_STATE.Delay)
        .. "s"
    )

    MarkConfigDirty()
end

function GAG2SeedDropSetBurst(value)

    local burst =
        math.floor(
            tonumber(value)
            or 1
        )

    GAG2_AUTO_DROP_SEED_STATE.Burst =
        math.clamp(
            burst,
            1,
            250
        )

    GAG2SeedDropSetStatus(
        "Burst set: "
        .. tostring(GAG2_AUTO_DROP_SEED_STATE.Burst)
    )

    MarkConfigDirty()
end

function GAG2SeedDropOnce(seedName, burstCount)

    local state =
        GAG2_AUTO_DROP_SEED_STATE

seedName =
    GAG2SeedDropCleanSeedName(
        seedName
        or state.Seed
        or "Rainbow"
    )

if seedName == "" then

    seedName =
        "Rainbow"
end

    burstCount =
        math.clamp(
            math.floor(
                tonumber(burstCount)
                or 1
            ),
            1,
            250
        )

local slotIndex =
    state.SeedSlots
    and state.SeedSlots[seedName]

    local equipped, toolOrReason =
        GAG2SeedDropEquipTool(
            seedName
        )

    if equipped ~= true then

        state.LastError =
            tostring(toolOrReason)

        GAG2SeedDropSetStatus(
            state.LastError
        )

        return 0,
            state.LastError
    end

    local selectPacket =
        GAG2SeedDropBuildSelectPacket(
            seedName
        )

local statePacket =
    nil

if slotIndex then

    statePacket =
        GAG2SeedDropBuildStatePacket(
            seedName,
            slotIndex
        )
end

    local okSelect, selectReason =
        GAG2SeedDropFire(
            selectPacket,
            "select"
        )

    if okSelect ~= true then

        state.LastError =
            tostring(selectReason)

        GAG2SeedDropSetStatus(
            state.LastError
        )

        return 0,
            state.LastError
    end

    task.wait(
        0.06
    )

if statePacket then

    local okState, stateReason =
        GAG2SeedDropFire(
            statePacket,
            "state"
        )

    if okState ~= true then

        state.LastError =
            tostring(stateReason)

        GAG2SeedDropSetStatus(
            state.LastError
        )

        return 0,
            state.LastError
    end
end

task.wait(
    0.04
)

    local fired =
        0

    for burstIndex = 1, burstCount do

        local dropPosition =
            GAG2SeedDropGetPosition(
                burstIndex
            )

        local realDropPacket =
            GAG2SeedDropBuildRealDropPacket(
                dropPosition
            )

        local okDrop, dropReason =
            GAG2SeedDropFire(
                realDropPacket,
                "real_drop"
            )

        if okDrop ~= true then

            state.LastError =
                tostring(dropReason)

            GAG2SeedDropSetStatus(
                state.LastError
            )

            break
        end

        fired += 1

        if type(GAG2DropPickupMarkSelfDrop) == "function" then

            GAG2DropPickupMarkSelfDrop(
                "auto drop seed"
            )
        end

        state.LastSeed =
            seedName

        state.LastPosition =
            dropPosition

        if burstIndex % 10 == 0 then

            task.wait()
        end
    end

    state.LastError =
        ""

    GAG2SeedDropSetStatus(
        "Fired "
        .. tostring(fired)
        .. " drop packet(s) for "
        .. tostring(seedName)
        .. "."
    )

    return fired,
        "ok"
end

function GAG2SeedDropStartLoop()

    local state =
        GAG2_AUTO_DROP_SEED_STATE

    if state.Running == true then
        return
    end

    state.Running =
        true

    task.spawn(function()

        state.Dropped =
            0

        GAG2SeedDropSetStatus(
            "Starting..."
        )

        while state.Enabled == true do

            local targetAmount =
                math.max(
                    1,
                    math.floor(
                        tonumber(state.Amount)
                        or 1
                    )
                )

            if state.Dropped >= targetAmount then

                GAG2SeedDropSetStatus(
                    "Target reached. Toggle stays ON. Waiting for picked-up seed cycle..."
                )

                while state.Enabled == true
                and GAG2SeedDropFindTool(state.Seed) ~= nil do

                    task.wait(
                        0.25
                    )
                end

                if state.Enabled ~= true then
                    break
                end

                GAG2SeedDropSetStatus(
                    "Seed left inventory. Waiting for it to return..."
                )

                while state.Enabled == true
                and GAG2SeedDropFindTool(state.Seed) == nil do

                    task.wait(
                        0.25
                    )
                end

                if state.Enabled ~= true then
                    break
                end

                state.Dropped =
                    0

                GAG2SeedDropSetStatus(
                    "Seed returned. Dropping again..."
                )

                task.wait(
                    0.08
                )

            else

                local remaining =
                    targetAmount - state.Dropped

                local burst =
                    math.min(
                        remaining,
                        math.clamp(
                            math.floor(
                                tonumber(state.Burst)
                                or 1
                            ),
                            1,
                            250
                        )
                    )

                local fired, reason =
                    GAG2SeedDropOnce(
                        state.Seed,
                        burst
                    )

                fired =
                    tonumber(fired)
                    or 0

                if fired <= 0 then

                    GAG2SeedDropSetStatus(
                        "Waiting: "
                        .. tostring(reason)
                    )

                    task.wait(
                        0.75
                    )

                else

                    state.Dropped += fired

                    GAG2SeedDropSetStatus(
                        "Dropped "
                        .. tostring(state.Dropped)
                        .. "/"
                        .. tostring(targetAmount)
                        .. ". Toggle remains ON."
                    )

                    local delaySeconds =
                        tonumber(state.Delay)
                        or 0.35

                    if delaySeconds > 0 then

                        task.wait(
                            delaySeconds
                        )

                    else

                        task.wait()
                    end
                end
            end
        end

        state.Running =
            false

        GAG2SeedDropSetStatus(
            "Stopped."
        )
    end)
end

function GAG2SeedDropSetEnabled(value)

    local state =
        GAG2_AUTO_DROP_SEED_STATE

    state.Enabled =
        value == true

    if state.Enabled == true then

        if ConfigState.Loading ~= true then

            GAG2SeedDropStartLoop()
        end

    else

        GAG2SeedDropSetStatus(
            "Stopping..."
        )
    end

    MarkConfigDirty()
end

function GAG2RestoreSeedDropState()

    task.defer(function()

        local state =
            GAG2_AUTO_DROP_SEED_STATE

        if Options.HolyGAG2SeedDropSeed then

            GAG2SeedDropSetSeed(
                Options.HolyGAG2SeedDropSeed.Value
            )
        end

        if Options.HolyGAG2SeedDropAmount then

            GAG2SeedDropSetAmount(
                Options.HolyGAG2SeedDropAmount.Value
            )
        end

        if Options.HolyGAG2SeedDropDelay then

            GAG2SeedDropSetDelay(
                Options.HolyGAG2SeedDropDelay.Value
            )
        end

        if Options.HolyGAG2SeedDropBurst then

            GAG2SeedDropSetBurst(
                Options.HolyGAG2SeedDropBurst.Value
            )
        end

        if Toggles.HolyGAG2AutoDropSeed then

            state.Enabled =
                Toggles.HolyGAG2AutoDropSeed.Value == true
        end

        GAG2SeedDropSetStatus(
            "Ready."
        )

        if state.Enabled == true then

            GAG2SeedDropStartLoop()
        end
    end)
end

--==================================================
-- [4.591] EXPERIMENT AUTO PICKUP DROPS
-- Prompt-only pickup for workspace.DroppedItems.
-- No packet replay. No remotes. No console spam.
--==================================================

GAG2_DROP_PICKUP_MODES =
    GAG2_DROP_PICKUP_MODES
    or {
        "All",
        "Seeds Only",
        "Pets Only",
        "Custom Contains",
    }

GAG2_DROP_PICKUP_STATE =
    GAG2_DROP_PICKUP_STATE
    or {
        Enabled = true,
        Running = false,

        Radius = 80,
        Delay = 0.15,
        Mode = "All",
        CustomText = "",

        IgnoreOwnDropSeconds = 1.75,
        SelfDropIgnoreUntil = 0,
        LastSelfDropReason = "",

        Found = 0,
        Picked = 0,
        LastPicked = "",
        LastStatus = "Ready.",
        LastError = "",

        Recent = {},
    }

function GAG2DropPickupClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2DropPickupSetStatus(text)

    local state =
        GAG2_DROP_PICKUP_STATE

    state.LastStatus =
        tostring(text or "Ready.")

    if Options.HolyGAG2DropPickupStatus then

        Options.HolyGAG2DropPickupStatus:SetText(
            '<font color="rgb(196,181,253)"><b>Auto Pickup Drops</b></font>'
            .. '\nState: '
            .. (
                state.Enabled == true
                and "ON"
                or "OFF"
            )
            .. ' | Running: '
            .. tostring(state.Running == true)
            .. '\nRadius: '
            .. tostring(state.Radius or 80)
            .. ' | Delay: '
            .. tostring(state.Delay or 0.15)
            .. 's'
            .. '\nMode: '
            .. tostring(state.Mode or "All")
            .. ' | Picked: '
            .. tostring(state.Picked or 0)
            .. ' | Found: '
            .. tostring(state.Found or 0)
            .. '\nLast: '
            .. tostring(state.LastPicked ~= "" and state.LastPicked or state.LastStatus)
        )
    end
end

function GAG2DropPickupGetRoot()

    return workspace:FindFirstChild(
        "DroppedItems"
    )
end

function GAG2DropPickupGetCharacterRoot()

    if type(SniperGetCharacterRoot) == "function" then

        local character, root =
            SniperGetCharacterRoot()

        if character
        and root then

            return character,
                root
        end
    end

    local character =
        LOCAL_PLAYER
        and LOCAL_PLAYER.Character

    local root =
        character
        and character:FindFirstChild("HumanoidRootPart")

    if character
    and root
    and root:IsA("BasePart") then

        return character,
            root
    end

    return nil,
        nil
end

function GAG2DropPickupGetPosition(instance)

    if typeof(instance) ~= "Instance" then
        return nil
    end

    if instance:IsA("BasePart") then

        return instance.Position
    end

    if instance:IsA("Model") then

        local ok, cframe =
            pcall(function()

                return instance:GetBoundingBox()
            end)

        if ok == true
        and typeof(cframe) == "CFrame" then

            return cframe.Position
        end
    end

    local scanned =
        0

    for _, descendant in ipairs(instance:GetDescendants()) do

        scanned += 1

        if scanned > 160 then
            break
        end

        if descendant:IsA("BasePart") then

            return descendant.Position
        end
    end

    return nil
end

function GAG2DropPickupFindPrompt(item)

    if typeof(item) ~= "Instance" then
        return nil
    end

    if item:IsA("ProximityPrompt")
    and item.Enabled == true then

        return item
    end

    local scanned =
        0

    for _, descendant in ipairs(item:GetDescendants()) do

        scanned += 1

        if scanned > 220 then
            break
        end

        if descendant:IsA("ProximityPrompt")
        and descendant.Enabled == true then

            return descendant
        end
    end

    return nil
end

function GAG2DropPickupReadDescriptor(item, prompt)

    local parts =
        {}

    local function add(value)

        value =
            GAG2DropPickupClean(value)

        if value ~= "" then

            table.insert(
                parts,
                value
            )
        end
    end

    if typeof(item) == "Instance" then

        add(item.Name)

        local ok, attrs =
            pcall(function()

                return item:GetAttributes()
            end)

        if ok == true
        and type(attrs) == "table" then

            for key, value in pairs(attrs) do

                add(key)
                add(value)
            end
        end
    end

    if typeof(prompt) == "Instance" then

        add(prompt.Name)

        pcall(function()
            add(prompt.ActionText)
            add(prompt.ObjectText)
        end)
    end

    if typeof(item) == "Instance" then

        local scanned =
            0

        for _, descendant in ipairs(item:GetDescendants()) do

            scanned += 1

            if scanned > 180 then
                break
            end

            add(descendant.Name)

            if descendant:IsA("TextLabel")
            or descendant:IsA("TextButton")
            or descendant:IsA("TextBox") then

                pcall(function()

                    add(descendant.Text)
                end)
            end

            if descendant:IsA("ProximityPrompt") then

                pcall(function()

                    add(descendant.ActionText)
                    add(descendant.ObjectText)
                end)
            end

            local ok, attrs =
                pcall(function()

                    return descendant:GetAttributes()
                end)

            if ok == true
            and type(attrs) == "table" then

                for key, value in pairs(attrs) do

                    add(key)
                    add(value)
                end
            end
        end
    end

    return table.concat(
        parts,
        " "
    )
end

function GAG2DropPickupSeedNameMatches(descriptor)

    descriptor =
        tostring(descriptor or ""):lower()

    if descriptor:find("seed", 1, true)
    or descriptor:find("seeds", 1, true) then

        return true
    end

    if type(GAG2SeedDropGetAllSeedValues) ~= "function" then
        return false
    end

    local values =
        GAG2SeedDropGetAllSeedValues()

    if type(values) ~= "table" then
        return false
    end

    for _, seedName in ipairs(values) do

        seedName =
            GAG2DropPickupClean(seedName)

        local beforePipe =
            seedName:match("^(.-)%s+|%s+")

        if beforePipe
        and GAG2DropPickupClean(beforePipe) ~= "" then

            seedName =
                GAG2DropPickupClean(beforePipe)
        end

        if seedName ~= ""
        and descriptor:find(seedName:lower(), 1, true) then

            return true
        end
    end

    return false
end

function GAG2DropPickupMatchesMode(item, prompt)

    local state =
        GAG2_DROP_PICKUP_STATE

    local mode =
        GAG2DropPickupClean(
            state.Mode
        )

    if mode == ""
    or mode == "All" then

        return true
    end

    local descriptor =
        GAG2DropPickupReadDescriptor(
            item,
            prompt
        )

    local lower =
        descriptor:lower()

    if mode == "Seeds Only" then

        return GAG2DropPickupSeedNameMatches(
            descriptor
        )
    end

    if mode == "Pets Only" then

        return lower:find("pet", 1, true) ~= nil
            or lower:find("pets", 1, true) ~= nil
            or lower:find("animal", 1, true) ~= nil
    end

    if mode == "Custom Contains" then

        local custom =
            GAG2DropPickupClean(
                state.CustomText
            ):lower()

        if custom == "" then
            return false
        end

        return lower:find(
            custom,
            1,
            true
        ) ~= nil
    end

    return true
end

function GAG2DropPickupCleanupRecent()

    local state =
        GAG2_DROP_PICKUP_STATE

    local now =
        os.clock()

    for key, seenAt in pairs(state.Recent) do

        if now - tonumber(seenAt or 0) > 6 then

            state.Recent[key] =
                nil
        end
    end
end

function GAG2DropPickupPromptKey(item, prompt)

    if typeof(prompt) == "Instance" then

        return PathOf(prompt)
    end

    if typeof(item) == "Instance" then

        return PathOf(item)
    end

    return tostring(item)
end

function GAG2DropPickupCanFire(item, prompt, rootPart)

    local state =
        GAG2_DROP_PICKUP_STATE

    if state.Enabled ~= true then
        return false, "disabled"
    end

    if os.clock() < tonumber(state.SelfDropIgnoreUntil or 0) then
        return false, "self drop pause"
    end

    if typeof(item) ~= "Instance"
    or item.Parent == nil then

        return false, "bad item"
    end

    if typeof(prompt) ~= "Instance"
    or prompt:IsA("ProximityPrompt") ~= true
    or prompt.Enabled ~= true then

        return false, "bad prompt"
    end

    if typeof(rootPart) ~= "Instance"
    or rootPart:IsA("BasePart") ~= true then

        return false, "missing root"
    end

    local position =
        GAG2DropPickupGetPosition(
            item
        )

    if typeof(position) ~= "Vector3" then

        return false, "no position"
    end

    local radius =
        math.clamp(
            tonumber(state.Radius)
            or 80,
            5,
            1000
        )

    local distance =
        (rootPart.Position - position).Magnitude

    if distance > radius then

        return false, "too far"
    end

    if GAG2DropPickupMatchesMode(
        item,
        prompt
    ) ~= true then

        return false, "filtered"
    end

    local key =
        GAG2DropPickupPromptKey(
            item,
            prompt
        )

    local last =
        tonumber(state.Recent[key])
        or 0

    if os.clock() - last < 0.65 then

        return false, "recent"
    end

    return true,
        key
end

function GAG2DropPickupFirePrompt(item, prompt, key)

    local state =
        GAG2_DROP_PICKUP_STATE

    if type(fireproximityprompt) ~= "function" then

        state.LastError =
            "fireproximityprompt unsupported"

        return false,
            state.LastError
    end

    local ok, err =
        pcall(function()

            fireproximityprompt(
                prompt
            )
        end)

    if ok ~= true then

        state.LastError =
            tostring(err)

        return false,
            state.LastError
    end

    state.Recent[key] =
        os.clock()

    state.Picked =
        tonumber(state.Picked)
        or 0

    state.Picked += 1

    state.LastPicked =
        tostring(item.Name)

    state.LastError =
        ""

    return true,
        "picked"
end

function GAG2DropPickupScanOnce(reason)

    local state =
        GAG2_DROP_PICKUP_STATE

    GAG2DropPickupCleanupRecent()

    if state.Enabled ~= true
    and reason ~= "manual" then

        GAG2DropPickupSetStatus(
            "Disabled."
        )

        return 0
    end

    if os.clock() < tonumber(state.SelfDropIgnoreUntil or 0) then

        GAG2DropPickupSetStatus(
            "Paused briefly after own drop."
        )

        return 0
    end

    local droppedRoot =
        GAG2DropPickupGetRoot()

    if not droppedRoot then

        state.Found =
            0

        GAG2DropPickupSetStatus(
            "workspace.DroppedItems missing."
        )

        return 0
    end

    local _, rootPart =
        GAG2DropPickupGetCharacterRoot()

    if not rootPart then

        GAG2DropPickupSetStatus(
            "Waiting for character."
        )

        return 0
    end

    local found =
        0

    local fired =
        0

    for _, item in ipairs(droppedRoot:GetChildren()) do

        local prompt =
            GAG2DropPickupFindPrompt(
                item
            )

        if prompt then

            local allowed, key =
                GAG2DropPickupCanFire(
                    item,
                    prompt,
                    rootPart
                )

            if allowed == true then

                found += 1

                local ok =
                    GAG2DropPickupFirePrompt(
                        item,
                        prompt,
                        key
                    )

                if ok == true then

                    fired += 1
                end

                if fired % 10 == 0 then
                    task.wait()
                end
            end
        end
    end

    state.Found =
        found

    if fired > 0 then

        GAG2DropPickupSetStatus(
            "Picked "
            .. tostring(fired)
            .. " drop(s)."
        )

    else

        GAG2DropPickupSetStatus(
            "Watching for drops."
        )
    end

    return fired
end

function GAG2DropPickupStartLoop()

    local state =
        GAG2_DROP_PICKUP_STATE

    if state.Running == true then
        return
    end

    state.Running =
        true

    task.spawn(function()

        GAG2DropPickupSetStatus(
            "Starting..."
        )

        while state.Enabled == true do

            GAG2DropPickupScanOnce(
                "loop"
            )

            local delaySeconds =
                math.clamp(
                    tonumber(state.Delay)
                    or 0.15,
                    0.03,
                    5
                )

            task.wait(
                delaySeconds
            )
        end

        state.Running =
            false

        GAG2DropPickupSetStatus(
            "Stopped."
        )
    end)
end

function GAG2DropPickupSetEnabled(value, skipDirty)

    local state =
        GAG2_DROP_PICKUP_STATE

    state.Enabled =
        value == true

    if state.Enabled == true then

        if ConfigState.Loading ~= true then

            GAG2DropPickupStartLoop()
        end

    else

        GAG2DropPickupSetStatus(
            "Stopping..."
        )
    end

    if skipDirty ~= true then

        MarkConfigDirty()
    end
end

function GAG2DropPickupSetRadius(value)

    GAG2_DROP_PICKUP_STATE.Radius =
        math.clamp(
            tonumber(value)
            or 80,
            5,
            1000
        )

    GAG2DropPickupSetStatus(
        "Radius set."
    )

    MarkConfigDirty()
end

function GAG2DropPickupSetDelay(value)

    GAG2_DROP_PICKUP_STATE.Delay =
        math.clamp(
            tonumber(value)
            or 0.15,
            0.03,
            5
        )

    GAG2DropPickupSetStatus(
        "Delay set."
    )

    MarkConfigDirty()
end

function GAG2DropPickupSetMode(value)

    value =
        GAG2DropPickupClean(value)

    if table.find(
        GAG2_DROP_PICKUP_MODES,
        value
    ) == nil then

        value =
            "All"
    end

    GAG2_DROP_PICKUP_STATE.Mode =
        value

    GAG2DropPickupSetStatus(
        "Mode set: "
        .. tostring(value)
    )

    MarkConfigDirty()
end

function GAG2DropPickupSetCustomText(value)

    GAG2_DROP_PICKUP_STATE.CustomText =
        GAG2DropPickupClean(
            value
        )

    GAG2DropPickupSetStatus(
        "Custom filter set."
    )

    MarkConfigDirty()
end

function GAG2DropPickupSetIgnoreOwnDropSeconds(value)

    GAG2_DROP_PICKUP_STATE.IgnoreOwnDropSeconds =
        math.clamp(
            tonumber(value)
            or 1.75,
            0,
            10
        )

    GAG2DropPickupSetStatus(
        "Self-drop pause set."
    )

    MarkConfigDirty()
end

function GAG2DropPickupMarkSelfDrop(reason)

    local state =
        GAG2_DROP_PICKUP_STATE

    local seconds =
        math.clamp(
            tonumber(state.IgnoreOwnDropSeconds)
            or 1.75,
            0,
            10
        )

    if seconds <= 0 then
        return
    end

    state.SelfDropIgnoreUntil =
        math.max(
            tonumber(state.SelfDropIgnoreUntil)
            or 0,
            os.clock() + seconds
        )

    state.LastSelfDropReason =
        tostring(reason or "own drop")
end

function GAG2RestoreDropPickupState()

    task.defer(function()

        local state =
            GAG2_DROP_PICKUP_STATE

        if Options.HolyGAG2PickupRadius then

            state.Radius =
                math.clamp(
                    tonumber(Options.HolyGAG2PickupRadius.Value)
                    or state.Radius
                    or 80,
                    5,
                    1000
                )
        end

        if Options.HolyGAG2PickupDelay then

            state.Delay =
                math.clamp(
                    tonumber(Options.HolyGAG2PickupDelay.Value)
                    or state.Delay
                    or 0.15,
                    0.03,
                    5
                )
        end

        if Options.HolyGAG2PickupMode then

            local mode =
                GAG2DropPickupClean(
                    Options.HolyGAG2PickupMode.Value
                )

            if table.find(
                GAG2_DROP_PICKUP_MODES,
                mode
            ) ~= nil then

                state.Mode =
                    mode
            end
        end

        if Options.HolyGAG2PickupCustomText then

            state.CustomText =
                GAG2DropPickupClean(
                    Options.HolyGAG2PickupCustomText.Value
                )
        end

        if Options.HolyGAG2PickupIgnoreOwnDropSeconds then

            state.IgnoreOwnDropSeconds =
                math.clamp(
                    tonumber(Options.HolyGAG2PickupIgnoreOwnDropSeconds.Value)
                    or state.IgnoreOwnDropSeconds
                    or 1.75,
                    0,
                    10
                )
        end

        local enabled =
            true

        if Toggles.HolyGAG2AutoPickupDrops then

            enabled =
                Toggles.HolyGAG2AutoPickupDrops.Value == true
        end

        state.Enabled =
            enabled

        GAG2DropPickupSetStatus(
            "Ready."
        )

        if state.Enabled == true then

            GAG2DropPickupStartLoop()
        end
    end)
end

--==================================================
-- [4.595] HOME AUTO HOP UNTIL SERVER VERSION
-- Reads Settings.Frame.Header.VersionLabel.Text, then hops until target version.
--==================================================

GAG2_VERSION_HOP_STATE =
    GAG2_VERSION_HOP_STATE
    or {
        Enabled = false,
        Running = false,

        TargetVersion = "v88",
        CurrentVersion = "unknown",
        HopDelay = 2,

        LastStatus = "Idle.",
        LastError = "",
        LastCheckAt = 0,
        LastHopAt = 0,
    }

function GAG2VersionHopClean(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

function GAG2VersionHopNormalizeVersion(value)

    value =
        GAG2VersionHopClean(value)
            :lower()
            :gsub("%s+", "")

    if value == "" then
        return ""
    end

    local number =
        value:match("^v(%d+)$")
        or value:match("^(%d+)$")
        or value:match("v(%d+)")
        or value:match("(%d+)")

    if not number then
        return ""
    end

    return "v" .. tostring(number)
end

function GAG2VersionHopGetLabelExact()

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    local settingsGui =
        playerGui
        and playerGui:FindFirstChild("Settings")

    local frame =
        settingsGui
        and settingsGui:FindFirstChild("Frame")

    local header =
        frame
        and frame:FindFirstChild("Header")

    local versionLabel =
        header
        and header:FindFirstChild("VersionLabel")

    if versionLabel
    and (
        versionLabel:IsA("TextLabel")
        or versionLabel:IsA("TextButton")
        or versionLabel:IsA("TextBox")
    ) then

        return versionLabel
    end

    return nil
end

function GAG2VersionHopReadCurrentVersion()

    local label =
        GAG2VersionHopGetLabelExact()

    if label then

        local ok, text =
            pcall(function()

                return label.Text
            end)

        local version =
            ok == true
            and GAG2VersionHopNormalizeVersion(text)
            or ""

        if version ~= "" then

            GAG2_VERSION_HOP_STATE.CurrentVersion =
                version

            return version,
                "exact"
        end
    end

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if not playerGui then

        return "",
            "PlayerGui missing"
    end

    local scanned =
        0

    for _, descendant in ipairs(playerGui:GetDescendants()) do

        scanned += 1

        if scanned > 10000 then
            break
        end

        if descendant.Name == "VersionLabel"
        and (
            descendant:IsA("TextLabel")
            or descendant:IsA("TextButton")
            or descendant:IsA("TextBox")
        ) then

            local ok, text =
                pcall(function()

                    return descendant.Text
                end)

            local version =
                ok == true
                and GAG2VersionHopNormalizeVersion(text)
                or ""

            if version ~= "" then

                GAG2_VERSION_HOP_STATE.CurrentVersion =
                    version

                return version,
                    "VersionLabel scan"
            end
        end
    end

    scanned =
        0

    for _, descendant in ipairs(playerGui:GetDescendants()) do

        scanned += 1

        if scanned > 10000 then
            break
        end

        if descendant:IsA("TextLabel")
        or descendant:IsA("TextButton")
        or descendant:IsA("TextBox") then

            local ok, text =
                pcall(function()

                    return descendant.Text
                end)

            local version =
                ok == true
                and GAG2VersionHopNormalizeVersion(text)
                or ""

            if version ~= "" then

                GAG2_VERSION_HOP_STATE.CurrentVersion =
                    version

                return version,
                    "text scan"
            end
        end
    end

    return "",
        "version label not found"
end

function GAG2VersionHopGetTarget()

    local state =
        GAG2_VERSION_HOP_STATE

    local target =
        GAG2VersionHopNormalizeVersion(
            state.TargetVersion
        )

    if target == "" then
        target = "v88"
    end

    state.TargetVersion =
        target

    return target
end

function GAG2VersionHopGetDelay()

    local state =
        GAG2_VERSION_HOP_STATE

    local delaySeconds =
        tonumber(state.HopDelay)
        or 2

    delaySeconds =
        math.clamp(
            delaySeconds,
            1,
            60
        )

    state.HopDelay =
        delaySeconds

    return delaySeconds
end

function GAG2VersionHopBuildHomeText()

    local state =
        GAG2_VERSION_HOP_STATE

    local current =
        GAG2VersionHopNormalizeVersion(
            state.CurrentVersion
        )

    if current == "" then

        local readVersion =
            GAG2VersionHopReadCurrentVersion()

        current =
            GAG2VersionHopNormalizeVersion(
                readVersion
            )
    end

    if current == "" then
        return "Server loading..."
    end

    return "Server "
        .. tostring(current)
end

function GAG2VersionHopBuildHomeHeaderText()

    local text =
        GAG2VersionHopBuildHomeText()

    if text == "" then
        text =
            "Server loading..."
    end

    return text
end

function GAG2VersionHopTrySetHomeDescriptionMethod(text)

    local tab =
        GAG2_HOME_TAB_CONTROL

    if type(tab) ~= "table" then
        return false
    end

    local methodNames = {
        "SetDescription",
        "SetSubtitle",
        "SetSubTitle",
        "SetDesc",
    }

    for _, methodName in ipairs(methodNames) do

        local method =
            tab[methodName]

        if type(method) == "function" then

            local ok =
                pcall(function()

                    method(
                        tab,
                        text
                    )
                end)

            if ok == true then
                return true
            end
        end
    end

    return false
end

function GAG2VersionHopRefreshHomeHeader()

    local text =
        GAG2VersionHopBuildHomeHeaderText()

    if GAG2VersionHopTrySetHomeDescriptionMethod(text) == true then
        return
    end

    local roots =
        {}

    if CoreGui then

        table.insert(
            roots,
            CoreGui
        )
    end

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if playerGui then

        table.insert(
            roots,
            playerGui
        )
    end

    local replacements = {
        ["Main controls."] = true,
        ["Server loading..."] = true,
    }

    for _, root in ipairs(roots) do

        local scanned =
            0

        for _, descendant in ipairs(root:GetDescendants()) do

            scanned += 1

            if scanned > 25000 then
                break
            end

            if descendant:IsA("TextLabel")
            or descendant:IsA("TextButton")
            or descendant:IsA("TextBox") then

                local ok, currentText =
                    pcall(function()

                        return descendant.Text
                    end)

                currentText =
                    ok == true
                    and tostring(currentText or "")
                    or ""

                local lowerText =
                    currentText:lower()

                if replacements[currentText] == true
                or lowerText:match("^server%s+v%d+$") then

                    pcall(function()

                        descendant.Text =
                            text
                    end)

                    return
                end
            end
        end
    end
end

function GAG2VersionHopStartHeaderLoop()

    local state =
        GAG2_VERSION_HOP_STATE

    if state.HeaderLoopRunning == true then
        return
    end

    state.HeaderLoopRunning =
        true

    task.spawn(function()

        local started =
            os.clock()

        while os.clock() - started < 20 do

            GAG2VersionHopReadCurrentVersion()
            GAG2VersionHopRefreshHomeHeader()

            task.wait(
                1
            )
        end

        state.HeaderLoopRunning =
            false
    end)
end

function GAG2VersionHopRefreshHome()

    if type(RefreshServerInfo) == "function" then

        RefreshServerInfo()
    end

    GAG2VersionHopRefreshHomeHeader()
end

function GAG2VersionHopSetStatus(text)

    local state =
        GAG2_VERSION_HOP_STATE

    state.LastStatus =
        tostring(text or "Idle.")

    GAG2VersionHopRefreshHome()

    print(
        "[HOLY GAG2 VERSION HOP]",
        state.LastStatus
    )
end

function GAG2VersionHopSetTarget(value)

    local state =
        GAG2_VERSION_HOP_STATE

    local version =
        GAG2VersionHopNormalizeVersion(value)

    if version == "" then
        version = "v88"
    end

    state.TargetVersion =
        version

    GAG2VersionHopSetStatus(
        "Target set to "
        .. tostring(version)
        .. "."
    )

    MarkConfigDirty()
end

function GAG2VersionHopSetDelay(value)

    local state =
        GAG2_VERSION_HOP_STATE

    state.HopDelay =
        math.clamp(
            tonumber(value)
            or 2,
            1,
            60
        )

    GAG2VersionHopSetStatus(
        "Hop delay set to "
        .. tostring(state.HopDelay)
        .. "s."
    )

    MarkConfigDirty()
end

function GAG2VersionHopStop(reason)

    local state =
        GAG2_VERSION_HOP_STATE

    state.Enabled =
        false

    state.Running =
        false

    GAG2_SERVER_HOP_RETRYING =
        false

    GAG2_SERVER_HOP_ATTEMPT =
        0

    GAG2VersionHopSetStatus(
        tostring(reason or "Stopped.")
    )

    MarkConfigDirty()
end

function GAG2VersionHopTurnToggleOff()

    if Toggles.HolyGAG2AutoHopUntilVersion
    and type(Toggles.HolyGAG2AutoHopUntilVersion.SetValue) == "function" then

        pcall(function()

            Toggles.HolyGAG2AutoHopUntilVersion:SetValue(
                false
            )
        end)
    end
end

function GAG2VersionHopQueueHop()

    local state =
        GAG2_VERSION_HOP_STATE

    state.LastHopAt =
        os.clock()

    GAG2_SERVER_HOP_RETRYING =
        false

    GAG2_SERVER_HOP_ATTEMPT =
        0

    if type(HopServerOnce) ~= "function" then

        GAG2VersionHopSetStatus(
            "HopServerOnce missing."
        )

        return false
    end

    GAG2VersionHopSetStatus(
        "Wrong version. Hopping now..."
    )

    return HopServerOnce()
end

function GAG2VersionHopStartLoop()

    local state =
        GAG2_VERSION_HOP_STATE

    if state.Running == true then
        return
    end

    state.Running =
        true

    task.spawn(function()

        task.wait(
            0.75
        )

        while state.Enabled == true do

            local target =
                GAG2VersionHopGetTarget()

            local current =
                ""

            local source =
                ""

            local started =
                os.clock()

            while state.Enabled == true
            and current == ""
            and os.clock() - started < 12 do

                current,
                source =
                    GAG2VersionHopReadCurrentVersion()

                if current == "" then

                    GAG2VersionHopSetStatus(
                        "Waiting for version label..."
                    )

                    task.wait(
                        0.35
                    )
                end
            end

            if state.Enabled ~= true then
                break
            end

            if current == "" then

                GAG2VersionHopSetStatus(
                    "Version missing. Waiting..."
                )

                task.wait(
                    1
                )

                continue
            end

            state.CurrentVersion =
                current

            state.LastCheckAt =
                os.clock()

            if current == target then

                GAG2VersionHopSetStatus(
                    "Found target "
                    .. tostring(target)
                    .. " via "
                    .. tostring(source)
                    .. "."
                )

                state.Enabled =
                    false

                state.Running =
                    false

                GAG2VersionHopTurnToggleOff()

                Notify(
                    "Version Found",
                    "Current server is "
                    .. tostring(current)
                    .. ".",
                    4
                )

                MarkConfigDirty()

                return
            end

            local delaySeconds =
                GAG2VersionHopGetDelay()

            GAG2VersionHopSetStatus(
                "Current "
                .. tostring(current)
                .. " != target "
                .. tostring(target)
                .. ". Hopping in "
                .. tostring(delaySeconds)
                .. "s."
            )

            local waited =
                0

            while state.Enabled == true
            and waited < delaySeconds do

                task.wait(
                    0.1
                )

                waited += 0.1
            end

            if state.Enabled ~= true then
                break
            end

            GAG2VersionHopQueueHop()

            -- Teleport should happen through HopServerOnce.
            -- Stop this local loop so it does not double-hop in the same server.
            break
        end

        state.Running =
            false

        if state.Enabled ~= true then

            GAG2VersionHopRefreshHome()
        end
    end)
end

function GAG2VersionHopSetEnabled(value)

    local state =
        GAG2_VERSION_HOP_STATE

    state.Enabled =
        value == true

    if state.Enabled == true then

        GAG2VersionHopSetStatus(
            "Checking version..."
        )

        if ConfigState.Loading ~= true then

            GAG2VersionHopStartLoop()
        end

    else

        GAG2VersionHopStop(
            "Stopped."
        )
    end

    MarkConfigDirty()
end

function GAG2RestoreVersionHopState()

    task.defer(function()

        local state =
            GAG2_VERSION_HOP_STATE

        if Options.HolyGAG2VersionHopTarget then

            state.TargetVersion =
                GAG2VersionHopNormalizeVersion(
                    Options.HolyGAG2VersionHopTarget.Value
                )

            if state.TargetVersion == "" then

                state.TargetVersion =
                    "v88"
            end
        end

        if Options.HolyGAG2VersionHopDelay then

            state.HopDelay =
                math.clamp(
                    tonumber(Options.HolyGAG2VersionHopDelay.Value)
                    or 2,
                    1,
                    60
                )
        end

        if Toggles.HolyGAG2AutoHopUntilVersion then

            state.Enabled =
                Toggles.HolyGAG2AutoHopUntilVersion.Value == true
        end

        local current =
            GAG2VersionHopReadCurrentVersion()

        if current ~= "" then

            state.CurrentVersion =
                current
        end

        GAG2VersionHopSetStatus(
            state.Enabled == true
            and "Restored. Checking version..."
            or "Ready."
        )

        GAG2VersionHopStartHeaderLoop()

        if state.Enabled == true then

            GAG2VersionHopStartLoop()
        end
    end)
end

--==================================================
-- [5] WINDOW
--==================================================



local Window =
    Library:CreateWindow({
        Title =
            '<font color="rgb(232,230,240)">Holy</font> '
            .. '<font color="rgb(196,181,253)"><b>GAG 2</b></font>',

        Footer =
            "holy · clean refresh",

        ToggleKeybind =
            Enum.KeyCode.LeftAlt,

        Font =
            Enum.Font.Code,

        Center =
            true,

        AutoShow =
            UIState.ShowUIOnLoad == true,

        Size =
            UDim2.fromOffset(780, 540),

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

pcall(function()

    Library:SetDPIScale(
        tonumber(UIState.DPIScale)
        or 100
    )
end)

--==================================================
-- [6] TABS
--==================================================

local Tabs = {
    Home =
        Window:AddTab({
            Name = "Home",
            Icon = "home",
            Description = "Server loading...",
        }),

    Server =
        Window:AddTab({
            Name = "Server",
            Icon = "server",
            Description = "Server selection.",
        }),

    Combat =
        Window:AddTab({
            Name = "Combat",
            Icon = "swords",
            Description = "Combat and defense systems.",
        }),

    Shops =
        Window:AddTab({
            Name = "Shops",
            Icon = "shopping-bag",
            Description = "Shop systems.",
        }),

    Sell =
        Window:AddTab({
            Name = "Sell",
            Icon = "coins",
            Description = "Sell systems.",
        }),

    Mailbox =
        Window:AddTab({
            Name = "Mailbox",
            Icon = "mail",
            Description = "Mailbox send and inbox tools.",
        }),

    Experiment =
        Window:AddTab({
            Name = "Experiment",
            Icon = "flask-conical",
            Description = "Safe experiments.",
        }),

    Farm =
        Window:AddTab({
            Name = "Farm",
            Icon = "sprout",
            Description = "Farm systems.",
        }),

    Visuals =
        Window:AddTab({
            Name = "Visuals",
            Icon = "eye",
            Description = "GAG2 research and visual tools.",
        }),

    Sniper =
        Window:AddTab({
            Name = "Sniper",
            Icon = "crosshair",
            Description = "Wild pet sniper scanner.",
        }),

    Settings =
        Window:AddTab({
            Name = "Settings",
            Icon = "sliders-horizontal",
            Description = "UI settings.",
        }),

    Webhook =
        Window:AddTab({
            Name = "Webhook",
            Icon = "webhook",
            Description = "Webhook alerts and Discord reporting.",
        }),
}

GAG2_HOME_TAB_CONTROL =
    Tabs.Home

if IsHolyGAG2Developer() then

    Tabs.Dev =
        Window:AddTab({
            Name = "Dev",
            Icon = "terminal",
            Description = "Developer tools.",
        })
end

--==================================================
-- [7] GROUPBOXES
--==================================================

local function AddLeftBox(tab, title, icon)

    if tab
    and type(tab.AddLeftCollapsibleGroupbox) == "function" then

        local ok, box =
            pcall(function()

                return tab:AddLeftCollapsibleGroupbox(
                    title,
                    icon,
                    true
                )
            end)

        if ok == true
        and box ~= nil then
            return box
        end

        return tab:AddLeftCollapsibleGroupbox(
            title,
            "settings",
            true
        )
    end

    return tab:AddLeftGroupbox(
        title,
        icon or "settings"
    )
end

local function AddRightBox(tab, title, icon)

    if tab
    and type(tab.AddRightCollapsibleGroupbox) == "function" then

        local ok, box =
            pcall(function()

                return tab:AddRightCollapsibleGroupbox(
                    title,
                    icon,
                    true
                )
            end)

        if ok == true
        and box ~= nil then
            return box
        end

        return tab:AddRightCollapsibleGroupbox(
            title,
            "settings",
            true
        )
    end

    return tab:AddRightGroupbox(
        title,
        icon or "settings"
    )
end

local HomeMainBox =
    AddLeftBox(
        Tabs.Home,
        "Quick Actions",
        "sparkles"
    )

local HomeServerBox =
    AddRightBox(
        Tabs.Home,
        "Live Pets",
        "radar"
    )

local ServerMainBox =
    AddLeftBox(
        Tabs.Server,
        "Server Selection",
        "server"
    )

local ServerStatusBox =
    AddRightBox(
        Tabs.Server,
        "Status",
        "activity"
    )

CombatMainBox =
    AddLeftBox(
        Tabs.Combat,
        "Combat Controls",
        "swords"
    )

CombatStatusBox =
    AddRightBox(
        Tabs.Combat,
        "Combat Status",
        "shield"
    )

local ShopsMainBox =
    AddLeftBox(
        Tabs.Shops,
        "Shop Controls",
        "shopping-cart"
    )

local ShopsStatusBox =
    AddRightBox(
        Tabs.Shops,
        "Current Stock",
        "activity"
    )

local SellMainBox =
    AddLeftBox(
        Tabs.Sell,
        "Controls",
        "coins"
    )

local SellStatusBox =
    AddRightBox(
        Tabs.Sell,
        "Status",
        "receipt"
    )

local MailboxMainBox =
    AddLeftBox(
        Tabs.Mailbox,
        "Send Pet Batch",
        "mail"
    )

local MailboxStatusBox =
    AddRightBox(
        Tabs.Mailbox,
        "Status",
        "inbox"
    )

local ExperimentMainBox =
    AddLeftBox(
        Tabs.Experiment,
        "Drops / Pickup",
        "flask-conical"
    )

local ExperimentStatusBox =
    AddRightBox(
        Tabs.Experiment,
        "Status",
        "activity"
    )

local FarmSeedPlantBox =
    AddLeftBox(
        Tabs.Farm,
        "Seed Planting",
        "sprout"
    )

local FarmMainBox =
    AddLeftBox(
        Tabs.Farm,
        "Farm Controls",
        "leaf"
    )

local FarmStatusBox =
    AddRightBox(
        Tabs.Farm,
        "Status",
        "activity"
    )

if FarmSeedPlantBox == nil then

    FarmSeedPlantBox =
        FarmMainBox
end

local VisualsMainBox =
    AddLeftBox(
        Tabs.Visuals,
        "Research",
        "eye"
    )

local VisualsStatusBox =
    AddRightBox(
        Tabs.Visuals,
        "Status",
        "scan-eye"
    )

local SniperMainBox =
    AddLeftBox(
        Tabs.Sniper,
        "Wild Pet Sniper",
        "crosshair"
    )

local SniperStatusBox =
    AddRightBox(
        Tabs.Sniper,
        "Sniper Status",
        "radar"
    )

local SettingsUIBox =
    AddLeftBox(
        Tabs.Settings,
        "Interface",
        "sliders-horizontal"
    )

WebhookMainBox =
    AddLeftBox(
        Tabs.Webhook,
        "Webhook Alerts",
        "webhook"
    )

WebhookStatusBox =
    AddRightBox(
        Tabs.Webhook,
        "Webhook Status",
        "activity"
    )

local DevToolsBox =
    nil

local DevInfoBox =
    nil

if Tabs.Dev then

    DevToolsBox =
        AddLeftBox(
            Tabs.Dev,
            "Tools",
            "terminal"
        )

    DevInfoBox =
        AddRightBox(
            Tabs.Dev,
            "Info",
            "info"
        )
end

--==================================================
-- [7.5] NEW TAB PLACEHOLDERS
--==================================================

if CombatMainBox then

    CombatMainBox:AddLabel("HolyGAG2CombatInfo", {
        Text =
            '<font color="rgb(196,181,253)"><b>Combat</b></font>'
            .. '\nCombat tools will be added here.',
        DoesWrap = true,
    })
end

if CombatStatusBox then

    CombatStatusBox:AddLabel("HolyGAG2CombatStatus", {
        Text =
            '<font color="rgb(196,181,253)"><b>Status</b></font>'
            .. '\nIdle.',
        DoesWrap = true,
    })
end

if WebhookMainBox then

    WebhookMainBox:AddLabel("HolyGAG2WebhookInfo", {
        Text =
            '<font color="rgb(196,181,253)"><b>Webhook</b></font>'
            .. '\nDiscord alert controls will be moved here.',
        DoesWrap = true,
    })
end

if WebhookStatusBox then

    WebhookStatusBox:AddLabel("HolyGAG2WebhookStatus", {
        Text =
            '<font color="rgb(196,181,253)"><b>Status</b></font>'
            .. '\nReady.',
        DoesWrap = true,
    })
end

--==================================================
-- [8] HOME TAB
--==================================================

HomeMainBox:AddButton({
    Text = "Rejoin",
    Tooltip = "Rejoin current server.",
    Func = function()

        RejoinServer()
    end,
}):AddButton({
    Text = "Server Hop",
    Tooltip = "Hop once to another public server.",
    Func = function()

        HopServerOnce()
    end,
})

HomeMainBox:AddButton({
    Text = "Copy Current Code",
    Tooltip = "Copy this server's current placeId:JobId.",
    Func = function()

        GAG2CopyCurrentJoinCode()
    end,
}):AddButton({
    Text = "Copy Raw JobId",
    Tooltip = "Copy only the current server JobId.",
    Func = function()

        if CopyText(game.JobId) == true then

            Notify(
                "Copied",
                "Raw JobId copied.",
                3
            )

        else

            Notify(
                "Clipboard",
                "Clipboard unsupported.",
                4
            )
        end
    end,
})

HomeMainBox:AddDivider()

if type(HomeMainBox.AddInput) == "function" then

    local VersionHopTargetInput =
        HomeMainBox:AddInput(
            "HolyGAG2VersionHopTarget",
            {
                Text = "Target Server Version",
                Default = "v88",
                Placeholder = "v88",
                Numeric = false,
                Finished = true,
                ClearTextOnFocus = false,
                Tooltip = "Accepts 88, v88, or V88. Exact normalized match only.",
            }
        )

    if VersionHopTargetInput
    and type(VersionHopTargetInput.OnChanged) == "function" then

        VersionHopTargetInput:OnChanged(function(value)

            GAG2VersionHopSetTarget(
                value
            )
        end)
    end

    local VersionHopDelayInput =
        HomeMainBox:AddInput(
            "HolyGAG2VersionHopDelay",
            {
                Text = "Hop Delay",
                Default = "2",
                Placeholder = "2",
                Numeric = false,
                Finished = true,
                ClearTextOnFocus = false,
                Tooltip = "Seconds to wait before hopping when current version does not match target. Min 1.",
            }
        )

    if VersionHopDelayInput
    and type(VersionHopDelayInput.OnChanged) == "function" then

        VersionHopDelayInput:OnChanged(function(value)

            GAG2VersionHopSetDelay(
                value
            )
        end)
    end
end

HomeMainBox:AddToggle("HolyGAG2AutoHopUntilVersion", {
    Text = "Auto Hop Until Server Version",
    Default = false,
    Tooltip = "Reads the current server version from Settings and hops until it matches the target.",
    Callback = function(value)

        GAG2VersionHopSetEnabled(
            value == true
        )
    end,
})

GAG2_MANUAL_JOIN_HUD_TOGGLE =
    HomeMainBox:AddToggle("HolyGAG2ManualJoinHud", {
        Text = "Pop Out Join HUD",
        Default = false,
        Tooltip = "Show a small draggable server join HUD.",
        Callback = function(value)

            GAG2SetManualJoinHudEnabled(
                value == true
            )
        end,
    })

HomeLivePetsList =
    HomeServerBox:AddPetMarketList(
        "HolyGAG2HomeLivePets",
        {
            Rows = 8,
            RowHeight = 38,
            EmptyText = "No active pets.",
            Summary =
                '<font color="rgb(196,181,253)"><b>Live Pets</b></font>'
                .. '\nLoading...',

            Callback = function(rowIndex, rowData)

                GAG2HomeManualBuyPetIndex(
                    rowIndex
                )
            end,
        }
    )

if IsGAG2World() ~= true then

    HomeServerBox:AddLabel({
        Text =
            '<font color="rgb(248,113,113)"><b>Unknown Place Warning</b></font>'
            .. '\nKnown GAG2 PlaceIds: '
            .. GAG2KnownPlaceIdsText()
            .. '\nCurrent PlaceId: '
            .. tostring(game.PlaceId),
        DoesWrap = true,
    })
end

--==================================================
-- [8.1] SERVER TAB
--==================================================

local ServerSelectionDropdown =
    ServerMainBox:AddDropdown(
        "HolyGAG2ServerSelectionMode",
        {
            Text = "Server Selection Mode",
            Values = GAG2_SERVER_SELECTION_MODES,
            Default = GAG2_SERVER_SELECTION_STATE.Mode or "Most Empty",
            Multi = false,
            Searchable = false,
            Tooltip = "Controls every HopServerOnce call: manual hop, version hop, and sniper auto-hop.",
        }
    )

if ServerSelectionDropdown
and type(ServerSelectionDropdown.OnChanged) == "function" then

    ServerSelectionDropdown:OnChanged(function(value)

        GAG2ServerSelectionSetMode(
            value
        )
    end)
end

ServerMainBox:AddButton({
    Text = "Server Hop",
    Tooltip = "Hop once using the selected server selection mode.",
    Func = function()

        HopServerOnce()
    end,
}):AddButton({
    Text = "Stop Hop",
    Tooltip = "Stop current server hop retry loop.",
    Func = function()

        GAG2CancelServerHop(
            "Server hop stopped."
        )

        GAG2ServerSelectionSetStatus(
            "Stopped."
        )
    end,
})

ServerStatusBox:AddLabel("HolyGAG2ServerSelectionStatus", {
    Text = GAG2ServerSelectionBuildStatus(),
    DoesWrap = true,
})

--==================================================
-- [8.25] SHOPS TAB
--==================================================

ShopsMainBox:AddToggle("HolyGAG2AutoBuySeeds", {
    Text = "Auto Buy Seeds",
    Default = false,
    Tooltip = "Buys selected seeds only when they are actually in stock.",
    Callback = function(value)

        GAG2ShopSetEnabled(
            "Seeds",
            value == true
        )
    end,
})

GAG2_SHOP_DROPDOWNS.Seeds =
    ShopsMainBox:AddDropdown(
        "HolyGAG2ShopSeeds",
        {
            Text = "Seeds",
            Values = GAG2ShopGetItemNames("Seeds"),
            Default = {},
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Selected seeds are bought while real stock is above 0.",
        }
    )

if GAG2_SHOP_DROPDOWNS.Seeds
and type(GAG2_SHOP_DROPDOWNS.Seeds.OnChanged) == "function" then

    GAG2_SHOP_DROPDOWNS.Seeds:OnChanged(function(value)

        GAG2ShopSetSelected(
            "Seeds",
            value
        )
    end)
end

ShopsMainBox:AddToggle("HolyGAG2AutoBuyGear", {
    Text = "Auto Buy Gear",
    Default = false,
    Tooltip = "Buys selected gear only when it is actually in stock.",
    Callback = function(value)

        GAG2ShopSetEnabled(
            "Gear",
            value == true
        )
    end,
})

GAG2_SHOP_DROPDOWNS.Gear =
    ShopsMainBox:AddDropdown(
        "HolyGAG2ShopGear",
        {
            Text = "Gear",
            Values = GAG2ShopGetItemNames("Gear"),
            Default = {},
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Selected gear is bought once per real restock when stock is above 0.",
        }
    )

if GAG2_SHOP_DROPDOWNS.Gear
and type(GAG2_SHOP_DROPDOWNS.Gear.OnChanged) == "function" then

    GAG2_SHOP_DROPDOWNS.Gear:OnChanged(function(value)

        GAG2ShopSetSelected(
            "Gear",
            value
        )
    end)
end

ShopsMainBox:AddToggle("HolyGAG2AutoBuyCrates", {
    Text = "Auto Buy Crates",
    Default = false,
    Tooltip = "Buys selected crates only when they are actually in stock.",
    Callback = function(value)

        GAG2ShopSetEnabled(
            "Crates",
            value == true
        )
    end,
})

GAG2_SHOP_DROPDOWNS.Crates =
    ShopsMainBox:AddDropdown(
        "HolyGAG2ShopCrates",
        {
            Text = "Crates",
            Values = GAG2ShopGetItemNames("Crates"),
            Default = {},
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Selected crates are bought once per real restock when stock is above 0.",
        }
    )

if GAG2_SHOP_DROPDOWNS.Crates
and type(GAG2_SHOP_DROPDOWNS.Crates.OnChanged) == "function" then

    GAG2_SHOP_DROPDOWNS.Crates:OnChanged(function(value)

        GAG2ShopSetSelected(
            "Crates",
            value
        )
    end)
end


--==================================================
-- [8.5] SELL TAB
--==================================================

SellMainBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Auto Sell</b></font>'
        .. '\nEvent-based fruit selling.'
        .. '\nSellAll is best for pure grinding. SellFruit sells each detected fruit by Id.',
    DoesWrap = true,
    Size = 13,
})

GAG2_AUTO_SELL_FRUIT_CONTROLS =
    GAG2_AUTO_SELL_FRUIT_CONTROLS
    or {}

GAG2_AUTO_SELL_FRUIT_CONTROLS.Method =
    SellMainBox:AddDropdown(
        "HolyGAG2AutoSellMethod",
        {
            Text = "Sell Method",
            Values = GAG2_AUTO_SELL_METHOD_VALUES,
            Default = "SellAll",
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 4,
            Tooltip = "SellAll fires one packet for all current fruit. SellFruit sells each fruit Id.",
        }
    )

if GAG2_AUTO_SELL_FRUIT_CONTROLS.Method
and type(GAG2_AUTO_SELL_FRUIT_CONTROLS.Method.OnChanged) == "function" then

    GAG2_AUTO_SELL_FRUIT_CONTROLS.Method:OnChanged(function(value)

        GAG2AutoSellSetMethod(
            value
        )
    end)
end

GAG2_AUTO_SELL_FRUIT_CONTROLS.Speed =
    SellMainBox:AddDropdown(
        "HolyGAG2AutoSellSpeed",
        {
            Text = "Sell Speed",
            Values = GAG2_AUTO_SELL_SPEED_VALUES,
            Default = "Fast",
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 4,
            Tooltip = "Normal is lightest. Fast is recommended. Ultra is fastest with tiny debounce.",
        }
    )

if GAG2_AUTO_SELL_FRUIT_CONTROLS.Speed
and type(GAG2_AUTO_SELL_FRUIT_CONTROLS.Speed.OnChanged) == "function" then

    GAG2_AUTO_SELL_FRUIT_CONTROLS.Speed:OnChanged(function(value)

        GAG2AutoSellSetSpeed(
            value
        )
    end)
end

GAG2_AUTO_SELL_FRUIT_CONTROLS.RepeatCount =
    SellMainBox:AddInput("HolyGAG2AutoSellRepeatCount", {
        Text = "Sell Repeat Count",
        Default = "1",
        Numeric = true,
        Finished = true,
        ClearTextOnFocus = false,
        Placeholder = "1 - 500",
        Tooltip = "How many times to fire the sell packet per trigger. Example: 500 fires packet:Fire(...) 500 times.",
        Callback = function(value)

            GAG2AutoSellSetRepeatCount(
                value
            )
        end,
    })

SellMainBox:AddToggle("HolyGAG2AutoSellFruits", {
    Text = "Auto Sell Fruits",
    Default = false,
    Tooltip = "Sells harvested fruit as soon as it appears in Backpack/Character.",
    Callback = function(value)

        GAG2AutoSellSetEnabled(
            value == true
        )
    end,
})

SellMainBox:AddDivider()

SellMainBox:AddButton({
    Text = "Sell All Now",
    Tooltip = "Fires NPCS.SellAll once.",
    Func = function()

        GAG2AutoSellFirePacket(
            "SellAll"
        )
    end,
}):AddButton({
    Text = "Stop Auto Sell",
    Risky = true,
    Tooltip = "Turns Auto Sell Fruits off.",
    Func = function()

        GAG2AutoSellStop()
    end,
})

SellStatusBox:AddLabel("HolyGAG2SellStatus", {
    Text =
        '<font color="rgb(196,181,253)"><b>Auto Sell</b></font>'
        .. '\nIdle.',
    DoesWrap = true,
})

--==================================================
-- [8.6] MAILBOX TAB
--==================================================

MailboxMainBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Mailbox Send Batch</b></font>'
        .. '\nSends one selected pet UUID with a custom Count value.'
        .. '\nConfirmed format: MailboxSendBatch(UserId, batch, message).',
    DoesWrap = true,
    Size = 13,
})

MailboxMainBox:AddDivider()

GAG2_MAILBOX_CONTROLS.Target =
    MailboxMainBox:AddInput("HolyGAG2MailboxTarget", {
        Text = "Target UserId / Username",
        Default = "",
        Numeric = false,
        Finished = true,
        ClearTextOnFocus = false,
        Placeholder = "5227153614 or Username",
        Tooltip = "Target mailbox recipient. UserId is fastest. Username lookup also works.",
        Callback = function(value)

            GAG2MailboxSetTarget(
                value
            )
        end,
    })

GAG2_MAILBOX_CONTROLS.Pet =
    MailboxMainBox:AddDropdown("HolyGAG2MailboxPetChoice", {
        Text = "Inventory Pet",
        Values = {
            "None",
        },
        Default = "None",
        Multi = false,
        Tooltip = "Select a pet from your Inventory.Pets data. The UUID is handled internally.",
    })

if GAG2_MAILBOX_CONTROLS.Pet
and type(GAG2_MAILBOX_CONTROLS.Pet.OnChanged) == "function" then

    GAG2_MAILBOX_CONTROLS.Pet:OnChanged(function(value)

        GAG2MailboxSetPetChoice(
            value
        )
    end)
end

MailboxMainBox:AddButton({
    Text = "Refresh Pets",
    Tooltip = "Re-scans Inventory.Pets and refreshes the pet dropdown.",
    Func = function()

        GAG2MailboxRefreshPetDropdown()
    end,
})

GAG2_MAILBOX_CONTROLS.Amount =
    MailboxMainBox:AddInput("HolyGAG2MailboxAmount", {
        Text = "Send Amount",
        Default = "500",
        Numeric = true,
        Finished = true,
        ClearTextOnFocus = false,
        Placeholder = "1 - 500",
        Tooltip = "Sets batch Count. Example: 500 sends Count = 500 in one MailboxSendBatch call.",
        Callback = function(value)

            GAG2MailboxSetAmount(
                value
            )
        end,
    })

GAG2_MAILBOX_CONTROLS.Message =
    MailboxMainBox:AddInput("HolyGAG2MailboxMessage", {
        Text = "Message",
        Default = "",
        Numeric = false,
        Finished = true,
        ClearTextOnFocus = false,
        Placeholder = "optional",
        Tooltip = "Optional mailbox message. Blank is allowed.",
        Callback = function(value)

            GAG2MailboxSetMessage(
                value
            )
        end,
    })

MailboxMainBox:AddDivider()

MailboxMainBox:AddButton({
    Text = "Send Pet Batch",
    Tooltip = "Fires MailboxSendBatch once using the selected Count amount.",
    Func = function()

        GAG2MailboxSendPetBatchNow()
    end,
}):AddButton({
    Text = "Open Inbox",
    Tooltip = "Fires MailboxOpenInbox.",
    Func = function()

        GAG2MailboxOpenInbox()
    end,
})

MailboxStatusBox:AddLabel("HolyGAG2MailboxStatus", {
    Text =
        '<font color="rgb(196,181,253)"><b>Mailbox</b></font>'
        .. '\nIdle.',
    DoesWrap = true,
})

MailboxStatusBox:AddLabel({
    Text =
        '<font color="rgb(148,163,184)"><b>Format</b></font>'
        .. '\nBatch item:'
        .. '\nCategory = Pets'
        .. '\nItemKey = Pet UUID'
        .. '\nCount = Send Amount',
    DoesWrap = true,
})

--==================================================
-- [8.75] EXPERIMENT TAB
--==================================================

ExperimentMainBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Dropped Items</b></font>'
        .. '\nAuto Pickup uses workspace.DroppedItems ProximityPrompts.'
        .. '\nDefault ON. Quiet, prompt-only, no packet replay.',
    DoesWrap = true,
    Size = 13,
})

ExperimentMainBox:AddToggle("HolyGAG2AutoPickupDrops", {
    Text = "Auto Pickup Drops",
    Default = true,
    Tooltip = "Automatically picks up nearby dropped items using fireproximityprompt.",
}):OnChanged(function(value)

    GAG2DropPickupSetEnabled(
        value == true
    )
end)

ExperimentMainBox:AddInput("HolyGAG2PickupRadius", {
    Text = "Pickup Radius",
    Default = "80",
    Numeric = true,
    Finished = true,
    ClearTextOnFocus = false,
    Placeholder = "80",
    Tooltip = "Maximum distance from your character to pickup dropped items.",
    Callback = function(value)

        GAG2DropPickupSetRadius(
            value
        )
    end,
})

ExperimentMainBox:AddInput("HolyGAG2PickupDelay", {
    Text = "Pickup Delay",
    Default = "0.15",
    Numeric = false,
    Finished = true,
    ClearTextOnFocus = false,
    Placeholder = "0.15",
    Tooltip = "Loop delay. Lower is faster but heavier.",
    Callback = function(value)

        GAG2DropPickupSetDelay(
            value
        )
    end,
})

ExperimentMainBox:AddDropdown("HolyGAG2PickupMode", {
    Text = "Pickup Mode",
    Values = GAG2_DROP_PICKUP_MODES,
    Default = GAG2_DROP_PICKUP_STATE.Mode or "All",
    Multi = false,
    Searchable = false,
    Tooltip = "All is safest because some dropped models do not expose clean category text.",
}):OnChanged(function(value)

    GAG2DropPickupSetMode(
        value
    )
end)

ExperimentMainBox:AddInput("HolyGAG2PickupCustomText", {
    Text = "Custom Contains",
    Default = "",
    Numeric = false,
    Finished = true,
    ClearTextOnFocus = false,
    Placeholder = "strawberry / seed / pet...",
    Tooltip = "Only used when Pickup Mode is Custom Contains.",
    Callback = function(value)

        GAG2DropPickupSetCustomText(
            value
        )
    end,
})

ExperimentMainBox:AddInput("HolyGAG2PickupIgnoreOwnDropSeconds", {
    Text = "Ignore Own Drop Seconds",
    Default = "1.75",
    Numeric = false,
    Finished = true,
    ClearTextOnFocus = false,
    Placeholder = "1.75",
    Tooltip = "Prevents this same account from instantly picking up its own auto-dropped seed.",
    Callback = function(value)

        GAG2DropPickupSetIgnoreOwnDropSeconds(
            value
        )
    end,
})

ExperimentMainBox:AddButton({
    Text = "Pickup Nearby Once",
    Tooltip = "Runs one pickup scan without changing the toggle.",
    Func = function()

        GAG2DropPickupScanOnce(
            "manual"
        )
    end,
})

ExperimentMainBox:AddDivider()

ExperimentMainBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Auto Drop Seed</b></font>'
        .. '\nExperimental real seed dropper.'
        .. '\nUses the confirmed seed drop packet path.'
        .. '\nAuto Pickup pauses briefly after your own drop to avoid same-account pickup loops.',
    DoesWrap = true,
    Size = 13,
})

GAG2_AUTO_DROP_SEED_CONTROLS =
    GAG2_AUTO_DROP_SEED_CONTROLS
    or {}

GAG2_AUTO_DROP_SEED_CONTROLS.Seed =
    ExperimentMainBox:AddDropdown("HolyGAG2SeedDropSeed", {
        Text = "Seed",
        Values = GAG2SeedDropGetAllSeedValues(),
        Default = GAG2_AUTO_DROP_SEED_STATE.Seed or "Rainbow",
        Multi = false,
        Searchable = true,
        MaxVisibleDropdownItems = 10,
        Tooltip = "All known seed drop candidates. It waits until the selected seed tool exists in Backpack / Character.",
    })

if GAG2_AUTO_DROP_SEED_CONTROLS.Seed
and type(GAG2_AUTO_DROP_SEED_CONTROLS.Seed.OnChanged) == "function" then

    GAG2_AUTO_DROP_SEED_CONTROLS.Seed:OnChanged(function(value)

        GAG2SeedDropSetSeed(
            value
        )
    end)
end

ExperimentMainBox:AddButton({
    Text = "Refresh Seed List",
    Tooltip = "Reloads seed names from shop data, planting data, Backpack, and Character.",
    Func = function()

        GAG2SeedDropRefreshDropdown()
    end,
})

GAG2_AUTO_DROP_SEED_CONTROLS.Amount =
    ExperimentMainBox:AddInput("HolyGAG2SeedDropAmount", {
        Text = "Drop Amount",
        Default = "1",
        Numeric = true,
        Finished = true,
        ClearTextOnFocus = false,
        Placeholder = "Any amount",
        Tooltip = "Total amount to drop. Not limited to 10.",
        Callback = function(value)

            GAG2SeedDropSetAmount(
                value
            )
        end,
    })

GAG2_AUTO_DROP_SEED_CONTROLS.Burst =
    ExperimentMainBox:AddInput("HolyGAG2SeedDropBurst", {
        Text = "Burst",
        Default = "1",
        Numeric = true,
        Finished = true,
        ClearTextOnFocus = false,
        Placeholder = "1 - 250",
        Tooltip = "How many real drop packets to fire per cycle.",
        Callback = function(value)

            GAG2SeedDropSetBurst(
                value
            )
        end,
    })

GAG2_AUTO_DROP_SEED_CONTROLS.Delay =
    ExperimentMainBox:AddInput("HolyGAG2SeedDropDelay", {
        Text = "Drop Delay",
        Default = "0.35",
        Numeric = false,
        Finished = true,
        ClearTextOnFocus = false,
        Placeholder = "0.35",
        Tooltip = "Delay between burst cycles. Use 0 for fastest loop.",
        Callback = function(value)

            GAG2SeedDropSetDelay(
                value
            )
        end,
    })

ExperimentMainBox:AddToggle("HolyGAG2AutoDropSeed", {
    Text = "Auto Drop Seed",
    Default = false,
    Tooltip = "Toggle ON to start auto dropping. Toggle OFF to stop after the current cycle.",
}):OnChanged(function(value)

    GAG2SeedDropSetEnabled(
        value == true
    )
end)

ExperimentMainBox:AddButton({
    Text = "Drop Once",
    Tooltip = "Drops one burst cycle without enabling the toggle.",
    Func = function()

        GAG2SeedDropOnce(
            GAG2_AUTO_DROP_SEED_STATE.Seed,
            GAG2_AUTO_DROP_SEED_STATE.Burst
        )
    end,
})

ExperimentStatusBox:AddLabel("HolyGAG2DropPickupStatus", {
    Text =
        '<font color="rgb(196,181,253)"><b>Auto Pickup Drops</b></font>'
        .. '\nState: ON | Running: false'
        .. '\nRadius: 80 | Delay: 0.15s'
        .. '\nMode: All | Picked: 0 | Found: 0'
        .. '\nLast: Ready.',
    DoesWrap = true,
})

ExperimentStatusBox:AddDivider()

ExperimentStatusBox:AddLabel("HolyGAG2ExperimentStatus", {
    Text =
        '<font color="rgb(196,181,253)"><b>Auto Drop Seed</b></font>'
        .. '\nState: OFF | Running: false'
        .. '\nSeed: Rainbow | Dropped: 0/1'
        .. '\nBurst: 1 | Delay: 0.35s'
        .. '\nReady.',
    DoesWrap = true,
})

--==================================================
-- [8.9] FARM TAB
--==================================================

if FarmSeedPlantBox == nil then

    if type(AddLeftBox) == "function" then

        FarmSeedPlantBox =
            AddLeftBox(
                Tabs.Farm,
                "Seed Planting",
                "sprout"
            )
    end
end

if FarmSeedPlantBox == nil then

    FarmSeedPlantBox =
        FarmMainBox
end

local FarmSeedAdvancedBox =
    nil

if Tabs.Farm
and type(Tabs.Farm.AddLeftCollapsibleGroupbox) == "function" then

    local okAdvanced, advancedBox =
        pcall(function()

            return Tabs.Farm:AddLeftCollapsibleGroupbox(
                "Seed Advanced",
                "sliders-horizontal",
                false
            )
        end)

    if okAdvanced == true
    and advancedBox ~= nil then

        FarmSeedAdvancedBox =
            advancedBox
    end
end

if FarmSeedAdvancedBox == nil then

    FarmSeedAdvancedBox =
        AddLeftBox(
            Tabs.Farm,
            "Seed Advanced",
            "sliders-horizontal"
        )
end

local function GAG2SeedPlantSetControlVisible(control, visible)

    if control
    and type(control.SetVisible) == "function" then

        pcall(function()

            control:SetVisible(
                visible == true
            )
        end)
    end
end

local function GAG2SeedPlantRefreshAdvancedVisibility()

    local isGrid =
        GAG2_SEED_PLANTING_STATE.Layout == "Grid"

    GAG2SeedPlantSetControlVisible(
        GAG2_SEED_PLANTING_CONTROLS.GridWidth,
        isGrid
    )

    GAG2SeedPlantSetControlVisible(
        GAG2_SEED_PLANTING_CONTROLS.GridDepth,
        isGrid
    )

    GAG2SeedPlantSetControlVisible(
        GAG2_SEED_PLANTING_CONTROLS.GridLayers,
        isGrid
    )

    GAG2SeedPlantSetControlVisible(
        GAG2_SEED_PLANTING_CONTROLS.GridSpacing,
        isGrid
    )
end

FarmSeedPlantBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Seed Planting</b></font>'
        .. '\nContinuous planting. Amount is per cycle.',
    DoesWrap = true,
    Size = 13,
})

FarmSeedPlantBox:AddButton({
    Text = "Set Point",
    Tooltip = "Stand inside your garden where planting should start, then click this.",
    Func = function()

        GAG2SeedPlantSetPointFromCurrentPosition()
    end,
}):AddButton({
    Text = "Refresh",
    Tooltip = "Refresh seed dropdown.",
    Func = function()

        GAG2SeedPlantRefreshDropdown()

        GAG2SeedPlantSetStatus(
            "Seed list refreshed."
        )
    end,
})

GAG2_SEED_PLANTING_CONTROLS.Seeds =
    FarmSeedPlantBox:AddDropdown(
        "HolyGAG2SeedPlantSeeds",
        {
            Text = "Seeds To Plant",
            Values = GAG2SeedPlantGetSeedValues(),
            Default = {},
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Selected seeds to plant.",
        }
    )

if GAG2_SEED_PLANTING_CONTROLS.Seeds
and type(GAG2_SEED_PLANTING_CONTROLS.Seeds.OnChanged) == "function" then

    GAG2_SEED_PLANTING_CONTROLS.Seeds:OnChanged(function(value)

        GAG2SeedPlantSetSelectedSeeds(
            value
        )
    end)
end

GAG2_SEED_PLANTING_CONTROLS.Layout =
    FarmSeedPlantBox:AddDropdown(
        "HolyGAG2SeedPlantLayout",
        {
            Text = "Plant Layout",
            Values = GAG2_SEED_PLANTING_LAYOUT_VALUES,
            Default = GAG2_SEED_PLANTING_STATE.Layout or "Stack",
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 2,
            Tooltip = "Stack plants vertically. Grid spreads around the plant point.",
        }
    )

if GAG2_SEED_PLANTING_CONTROLS.Layout
and type(GAG2_SEED_PLANTING_CONTROLS.Layout.OnChanged) == "function" then

    GAG2_SEED_PLANTING_CONTROLS.Layout:OnChanged(function(value)

        GAG2SeedPlantSetLayout(
            value
        )

        GAG2SeedPlantRefreshAdvancedVisibility()
    end)
end

GAG2_SEED_PLANTING_CONTROLS.Direction =
    FarmSeedPlantBox:AddDropdown(
        "HolyGAG2SeedPlantDirection",
        {
            Text = "Layer Direction",
            Values = GAG2_SEED_PLANTING_DIRECTION_VALUES,
            Default = GAG2_SEED_PLANTING_STATE.Direction or "Down",
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 3,
            Tooltip = "Up, Down, or Both. Grid uses this when Grid Layers is above 1.",
        }
    )

if GAG2_SEED_PLANTING_CONTROLS.Direction
and type(GAG2_SEED_PLANTING_CONTROLS.Direction.OnChanged) == "function" then

    GAG2_SEED_PLANTING_CONTROLS.Direction:OnChanged(function(value)

        GAG2SeedPlantSetDirection(
            value
        )
    end)
end

if type(FarmSeedPlantBox.AddInput) == "function" then

    local SeedPlantAmountInput =
        FarmSeedPlantBox:AddInput(
            "HolyGAG2SeedPlantAmount",
            {
                Text = "Plant Amount",
                Default = "20",
                Placeholder = "20",
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                Tooltip = "Max seeds to plant per cycle while Enable Seed Planting is ON.",
            }
        )

    if SeedPlantAmountInput
    and type(SeedPlantAmountInput.OnChanged) == "function" then

        SeedPlantAmountInput:OnChanged(function(value)

            GAG2SeedPlantSetAmount(
                value
            )
        end)
    end
end

GAG2_SEED_PLANTING_CONTROLS.Status =
    FarmSeedPlantBox:AddLabel({
        Text =
            '<font color="rgb(196,181,253)"><b>Status:</b></font> Ready.',
        DoesWrap = true,
        Size = 12,
    })

GAG2_SEED_PLANTING_CONTROLS.Toggle =
    FarmSeedPlantBox:AddToggle(
        "HolyGAG2SeedPlanting",
        {
            Text = "Enable Seed Planting",
            Default = false,
            Tooltip = "Continuously plants selected seeds. If seeds run out, waits for Auto Buy or backpack refill.",
            Callback = function(value)

                GAG2SeedPlantSetEnabled(
                    value == true
                )
            end,
        }
    )

FarmSeedAdvancedBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Advanced Seed Settings</b></font>'
        .. '\nTiming, spacing, and grid tuning.',
    DoesWrap = true,
    Size = 13,
})

if type(FarmSeedAdvancedBox.AddInput) == "function" then

    GAG2_SEED_PLANTING_CONTROLS.PlantDelay =
        FarmSeedAdvancedBox:AddInput(
            "HolyGAG2SeedPlantDelay",
            {
                Text = "Plant Delay",
                Default = "0.1",
                Placeholder = "0.1",
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                Tooltip = "Delay after each seed fire. Default 0.1. Lower is faster, but too low can make stacking only plant once.",
            }
        )

    if GAG2_SEED_PLANTING_CONTROLS.PlantDelay
    and type(GAG2_SEED_PLANTING_CONTROLS.PlantDelay.OnChanged) == "function" then

        GAG2_SEED_PLANTING_CONTROLS.PlantDelay:OnChanged(function(value)

            GAG2SeedPlantSetPlantDelay(
                value
            )
        end)
    end

    GAG2_SEED_PLANTING_CONTROLS.LayerSpacing =
        FarmSeedAdvancedBox:AddInput(
            "HolyGAG2SeedPlantLayerSpacing",
            {
                Text = "Layer Spacing",
                Default = "0.35",
                Placeholder = "0.35",
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                Tooltip = "Vertical distance between stack/grid layers.",
            }
        )

    if GAG2_SEED_PLANTING_CONTROLS.LayerSpacing
    and type(GAG2_SEED_PLANTING_CONTROLS.LayerSpacing.OnChanged) == "function" then

        GAG2_SEED_PLANTING_CONTROLS.LayerSpacing:OnChanged(function(value)

            GAG2SeedPlantSetLayerSpacing(
                value
            )
        end)
    end

    GAG2_SEED_PLANTING_CONTROLS.GridWidth =
        FarmSeedAdvancedBox:AddInput(
            "HolyGAG2SeedPlantGridWidth",
            {
                Text = "Grid Width",
                Default = "5",
                Placeholder = "5",
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                Tooltip = "Grid columns. Used only in Grid layout.",
            }
        )

    if GAG2_SEED_PLANTING_CONTROLS.GridWidth
    and type(GAG2_SEED_PLANTING_CONTROLS.GridWidth.OnChanged) == "function" then

        GAG2_SEED_PLANTING_CONTROLS.GridWidth:OnChanged(function(value)

            GAG2SeedPlantSetGridWidth(
                value
            )
        end)
    end

    GAG2_SEED_PLANTING_CONTROLS.GridDepth =
        FarmSeedAdvancedBox:AddInput(
            "HolyGAG2SeedPlantGridDepth",
            {
                Text = "Grid Depth",
                Default = "4",
                Placeholder = "4",
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                Tooltip = "Grid rows. Used only in Grid layout.",
            }
        )

    if GAG2_SEED_PLANTING_CONTROLS.GridDepth
    and type(GAG2_SEED_PLANTING_CONTROLS.GridDepth.OnChanged) == "function" then

        GAG2_SEED_PLANTING_CONTROLS.GridDepth:OnChanged(function(value)

            GAG2SeedPlantSetGridDepth(
                value
            )
        end)
    end

    GAG2_SEED_PLANTING_CONTROLS.GridLayers =
        FarmSeedAdvancedBox:AddInput(
            "HolyGAG2SeedPlantGridLayers",
            {
                Text = "Grid Layers",
                Default = "1",
                Placeholder = "1",
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                Tooltip = "Vertical layers per grid point. Plant Amount still caps total per cycle.",
            }
        )

    if GAG2_SEED_PLANTING_CONTROLS.GridLayers
    and type(GAG2_SEED_PLANTING_CONTROLS.GridLayers.OnChanged) == "function" then

        GAG2_SEED_PLANTING_CONTROLS.GridLayers:OnChanged(function(value)

            GAG2SeedPlantSetGridLayers(
                value
            )
        end)
    end

    GAG2_SEED_PLANTING_CONTROLS.GridSpacing =
        FarmSeedAdvancedBox:AddInput(
            "HolyGAG2SeedPlantGridSpacing",
            {
                Text = "Grid Spacing",
                Default = "1.25",
                Placeholder = "1.25",
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                Tooltip = "Horizontal distance between grid points.",
            }
        )

    if GAG2_SEED_PLANTING_CONTROLS.GridSpacing
    and type(GAG2_SEED_PLANTING_CONTROLS.GridSpacing.OnChanged) == "function" then

        GAG2_SEED_PLANTING_CONTROLS.GridSpacing:OnChanged(function(value)

            GAG2SeedPlantSetGridSpacing(
                value
            )
        end)
    end
end

GAG2SeedPlantRefreshAdvancedVisibility()

GAG2SeedDropRefreshDropdown()

GAG2SeedDropSetStatus(
    "Ready."
)

FarmMainBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Auto Collect Fruits</b></font>'
        .. '\nBuilds a ready-fruit queue, applies filters/exclusions, then collects by priority.'
        .. '\nWeight currently uses SizeMulti because exact pre-harvest KG is not stored.',
    DoesWrap = true,
    Size = 13,
})

GAG2_AUTO_COLLECT_FRUIT_CONTROLS.CollectionSpeed =
    FarmMainBox:AddDropdown(
        "HolyGAG2ACFCollectionSpeed",
        {
            Text = "Collection Speed",
            Values = GAG2_ACF_SPEED_VALUES,
            Default = "Normal",
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 4,
            Tooltip = "Normal is safe. Fast and Ultra override old slow delay and fire bigger batches.",
        }
    )

if GAG2_AUTO_COLLECT_FRUIT_CONTROLS.CollectionSpeed
and type(GAG2_AUTO_COLLECT_FRUIT_CONTROLS.CollectionSpeed.OnChanged) == "function" then

    GAG2_AUTO_COLLECT_FRUIT_CONTROLS.CollectionSpeed:OnChanged(function(value)

        GAG2ACFSetCollectionSpeed(
            value
        )
    end)
end

FarmMainBox:AddDivider()

GAG2_AUTO_COLLECT_FRUIT_CONTROLS.Toggle =
    FarmMainBox:AddToggle("HolyGAG2AutoCollectFruits", {
        Text = "Auto Collect Fruits",
        Default = false,
        Tooltip = "Collects ready fruits from your own garden using HarvestPrompt.",
        Callback = function(value)

            GAG2ACFSetEnabled(
                value == true
            )
        end,
    })

FarmMainBox:AddToggle("HolyGAG2ACFStopIfFull", {
    Text = "Stop If Backpack Is Full Max",
    Default = true,
    Tooltip = "Stops auto collect if backpack UI looks full/max.",
    Callback = function(value)

        GAG2ACFSetStopIfFull(
            value == true
        )
    end,
})

FarmMainBox:AddToggle("HolyGAG2ACFPauseDuringWeather", {
    Text = "Pause During Weather",
    Default = false,
    Tooltip = "Pauses Auto Collect during real weather events only. Day/Night will not pause.",
    Callback = function(value)

        GAG2ACFSetPauseDuringWeather(
            value == true
        )
    end,
})

GAG2_AUTO_COLLECT_FRUIT_CONTROLS.PauseWeatherMode =
    FarmMainBox:AddDropdown(
        "HolyGAG2ACFPauseWeatherMode",
        {
            Text = "Pause Weather Mode",
            Values = GAG2_ACF_WEATHER_MODE_VALUES,
            Default = "Any Weather",
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 4,
            Tooltip = "Any Weather pauses for all real weather. Selected pauses only chosen weather names.",
        }
    )

if GAG2_AUTO_COLLECT_FRUIT_CONTROLS.PauseWeatherMode
and type(GAG2_AUTO_COLLECT_FRUIT_CONTROLS.PauseWeatherMode.OnChanged) == "function" then

    GAG2_AUTO_COLLECT_FRUIT_CONTROLS.PauseWeatherMode:OnChanged(function(value)

        GAG2ACFSetPauseWeatherMode(
            value
        )
    end)
end

GAG2_AUTO_COLLECT_FRUIT_CONTROLS.PauseWeathers =
    FarmMainBox:AddDropdown(
        "HolyGAG2ACFPauseWeathers",
        {
            Text = "Pause Weathers",
            Values = GAG2_ACF_WEATHER_VALUES,
            Default = GAG2_ACF_WEATHER_VALUES,
            Multi = true,
            Searchable = false,
            AllowNull = true,
            MaxVisibleDropdownItems = 6,
            Tooltip = "Used only when Pause Weather Mode is Selected.",
        }
    )

if GAG2_AUTO_COLLECT_FRUIT_CONTROLS.PauseWeathers
and type(GAG2_AUTO_COLLECT_FRUIT_CONTROLS.PauseWeathers.OnChanged) == "function" then

    GAG2_AUTO_COLLECT_FRUIT_CONTROLS.PauseWeathers:OnChanged(function(value)

        GAG2ACFSetPauseWeathers(
            value
        )
    end)
end

if type(FarmMainBox.AddInput) == "function" then

    local CollectDelayInput =
        FarmMainBox:AddInput(
            "HolyGAG2ACFDelay",
            {
                Text = "Delay To Collect",
                Default = "0",
                Placeholder = "0",
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                Tooltip = "Delay between prompt fires. 0 is fastest safe mode.",
            }
        )

    if CollectDelayInput
    and type(CollectDelayInput.OnChanged) == "function" then

        CollectDelayInput:OnChanged(function(value)

            GAG2ACFSetDelay(
                value
            )
        end)
    end

    local BurstInput =
        FarmMainBox:AddInput(
            "HolyGAG2ACFBurst",
            {
                Text = "Collect Burst Amount",
                Default = "8",
                Placeholder = "8",
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                Tooltip = "How many ready fruits to fire per scan cycle.",
            }
        )

    if BurstInput
    and type(BurstInput.OnChanged) == "function" then

        BurstInput:OnChanged(function(value)

            GAG2ACFSetBurst(
                value
            )
        end)
    end
end

FarmMainBox:AddLabel({
    Text = '<font color="rgb(196,181,253)"><b>Collects</b></font>',
    DoesWrap = true,
    Size = 13,
})

GAG2_AUTO_COLLECT_FRUIT_CONTROLS.CollectMode =
    FarmMainBox:AddDropdown(
        "HolyGAG2ACFCollectMode",
        {
            Text = "Collect Mode",
            Values = GAG2_ACF_COLLECT_MODES,
            Default = "All",
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 4,
            Tooltip = "All ignores selected fruits. Only Selected requires selected fruits.",
        }
    )

if GAG2_AUTO_COLLECT_FRUIT_CONTROLS.CollectMode
and type(GAG2_AUTO_COLLECT_FRUIT_CONTROLS.CollectMode.OnChanged) == "function" then

    GAG2_AUTO_COLLECT_FRUIT_CONTROLS.CollectMode:OnChanged(function(value)

        GAG2ACFSetCollectMode(
            value
        )
    end)
end

GAG2_AUTO_COLLECT_FRUIT_CONTROLS.SelectedFruits =
    FarmMainBox:AddDropdown(
        "HolyGAG2ACFSelectedFruits",
        {
            Text = "Select Fruit",
            Values = GAG2ACFGetFruitDropdownValues(),
            Default = {},
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Used when Collect Mode is Only Selected.",
        }
    )

if GAG2_AUTO_COLLECT_FRUIT_CONTROLS.SelectedFruits
and type(GAG2_AUTO_COLLECT_FRUIT_CONTROLS.SelectedFruits.OnChanged) == "function" then

    GAG2_AUTO_COLLECT_FRUIT_CONTROLS.SelectedFruits:OnChanged(function(value)

        GAG2ACFSetDropdownMap(
            "SelectedFruits",
            value
        )
    end)
end

GAG2_AUTO_COLLECT_FRUIT_CONTROLS.SelectedRarities =
    FarmMainBox:AddDropdown(
        "HolyGAG2ACFSelectedRarities",
        {
            Text = "Select Rarity",
            Values = GAG2ACFGetRarityDropdownValues(),
            Default = {},
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Empty means any rarity.",
        }
    )

if GAG2_AUTO_COLLECT_FRUIT_CONTROLS.SelectedRarities
and type(GAG2_AUTO_COLLECT_FRUIT_CONTROLS.SelectedRarities.OnChanged) == "function" then

    GAG2_AUTO_COLLECT_FRUIT_CONTROLS.SelectedRarities:OnChanged(function(value)

        GAG2ACFSetDropdownMap(
            "SelectedRarities",
            value
        )
    end)
end

GAG2_AUTO_COLLECT_FRUIT_CONTROLS.SelectedMutations =
    FarmMainBox:AddDropdown(
        "HolyGAG2ACFSelectedMutations",
        {
            Text = "Select Mutation",
            Values = GAG2ACFGetMutationDropdownValues(),
            Default = {},
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Empty means any mutation.",
        }
    )

if GAG2_AUTO_COLLECT_FRUIT_CONTROLS.SelectedMutations
and type(GAG2_AUTO_COLLECT_FRUIT_CONTROLS.SelectedMutations.OnChanged) == "function" then

    GAG2_AUTO_COLLECT_FRUIT_CONTROLS.SelectedMutations:OnChanged(function(value)

        GAG2ACFSetDropdownMap(
            "SelectedMutations",
            value
        )
    end)
end

FarmMainBox:AddDivider()

FarmMainBox:AddLabel({
    Text = '<font color="rgb(196,181,253)"><b>Exclusions</b></font>',
    DoesWrap = true,
    Size = 13,
})

GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeFruits =
    FarmMainBox:AddDropdown(
        "HolyGAG2ACFExcludeFruits",
        {
            Text = "Exclude Fruits",
            Values = GAG2ACFGetFruitDropdownValues(),
            Default = {},
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Always skip these fruits.",
        }
    )

if GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeFruits
and type(GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeFruits.OnChanged) == "function" then

    GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeFruits:OnChanged(function(value)

        GAG2ACFSetDropdownMap(
            "ExcludeFruits",
            value
        )
    end)
end

GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeRarities =
    FarmMainBox:AddDropdown(
        "HolyGAG2ACFExcludeRarities",
        {
            Text = "Exclude Rarities",
            Values = GAG2ACFGetRarityDropdownValues(),
            Default = {},
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Always skip these rarities.",
        }
    )

if GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeRarities
and type(GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeRarities.OnChanged) == "function" then

    GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeRarities:OnChanged(function(value)

        GAG2ACFSetDropdownMap(
            "ExcludeRarities",
            value
        )
    end)
end

GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeMutations =
    FarmMainBox:AddDropdown(
        "HolyGAG2ACFExcludeMutations",
        {
            Text = "Exclude Mutations",
            Values = GAG2ACFGetMutationDropdownValues(),
            Default = {},
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Always skip these mutations.",
        }
    )

if GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeMutations
and type(GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeMutations.OnChanged) == "function" then

    GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeMutations:OnChanged(function(value)

        GAG2ACFSetDropdownMap(
            "ExcludeMutations",
            value
        )
    end)
end

GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeSizeMode =
    FarmMainBox:AddDropdown(
        "HolyGAG2ACFExcludeSizeMode",
        {
            Text = "Exclude Size/Weight Mode",
            Values = GAG2_ACF_SIZE_MODES,
            Default = "Off",
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 4,
            Tooltip = "Above 5 skips size above 5. Below 5 skips size below 5.",
        }
    )

if GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeSizeMode
and type(GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeSizeMode.OnChanged) == "function" then

    GAG2_AUTO_COLLECT_FRUIT_CONTROLS.ExcludeSizeMode:OnChanged(function(value)

        GAG2ACFSetExcludeSizeMode(
            value
        )
    end)
end

if type(FarmMainBox.AddInput) == "function" then

    local SizeThresholdInput =
        FarmMainBox:AddInput(
            "HolyGAG2ACFExcludeSizeThreshold",
            {
                Text = "Size/Weight Threshold",
                Default = "0",
                Placeholder = "Example: 5",
                Numeric = false,
                Finished = false,
                ClearTextOnFocus = false,
                Tooltip = "Uses SizeMulti in V1. 0 disables threshold.",
            }
        )

    if SizeThresholdInput
    and type(SizeThresholdInput.OnChanged) == "function" then

        SizeThresholdInput:OnChanged(function(value)

            GAG2ACFSetExcludeSizeThreshold(
                value
            )
        end)
    end
end

FarmMainBox:AddDivider()

FarmMainBox:AddLabel({
    Text = '<font color="rgb(196,181,253)"><b>Priority</b></font>',
    DoesWrap = true,
    Size = 13,
})

for priorityIndex = 1, 3 do

    GAG2_AUTO_COLLECT_FRUIT_CONTROLS[
        "Priority"
        .. tostring(priorityIndex)
    ] =
        FarmMainBox:AddDropdown(
            "HolyGAG2ACFPriority"
            .. tostring(priorityIndex),
            {
                Text =
                    tostring(priorityIndex)
                    .. (
                        priorityIndex == 1
                        and "st Collect Priority"
                        or priorityIndex == 2
                        and "nd Collect Priority"
                        or "rd Collect Priority"
                    ),

                Values = GAG2_ACF_PRIORITY_VALUES,

                Default =
                    priorityIndex == 1
                    and "Rarity"
                    or priorityIndex == 2
                    and "Weight"
                    or "Mutation",

                Multi = false,
                Searchable = false,
                MaxVisibleDropdownItems = 8,
                Tooltip = "Queue sorting order.",
            }
        )

    if GAG2_AUTO_COLLECT_FRUIT_CONTROLS[
        "Priority"
        .. tostring(priorityIndex)
    ]
    and type(
        GAG2_AUTO_COLLECT_FRUIT_CONTROLS[
            "Priority"
            .. tostring(priorityIndex)
        ].OnChanged
    ) == "function" then

        GAG2_AUTO_COLLECT_FRUIT_CONTROLS[
            "Priority"
            .. tostring(priorityIndex)
        ]:OnChanged(function(value)

            GAG2ACFSetPriority(
                priorityIndex,
                value
            )
        end)
    end
end

FarmMainBox:AddDivider()

FarmMainBox:AddButton({
    Text = "Refresh Lists",
    Tooltip = "Refresh fruit, rarity, and mutation dropdown choices.",
    Func = function()

        GAG2ACFRefreshDropdownValues()

        GAG2ACFSetStatus(
            "Auto Collect fruit lists refreshed."
        )
    end,
}):AddButton({
    Text = "Collect Once",
    Tooltip = "Runs one priority batch without enabling the loop.",
    Func = function()

        GAG2ACFCollectBatch()
    end,
})

FarmMainBox:AddButton({
    Text = "Stop Collect",
    Risky = true,
    Tooltip = "Turns Auto Collect Fruits off.",
    Func = function()

        GAG2ACFSetEnabled(
            false
        )

        if Toggles.HolyGAG2AutoCollectFruits
        and type(Toggles.HolyGAG2AutoCollectFruits.SetValue) == "function" then

            pcall(function()

                Toggles.HolyGAG2AutoCollectFruits:SetValue(
                    false
                )
            end)
        end
    end,
})

FarmStatusBox:AddLabel("HolyGAG2FarmStatus", {
    Text =
        '<font color="rgb(196,181,253)"><b>Auto Collect Fruits</b></font>'
        .. '\nIdle.',
    DoesWrap = true,
})

task.defer(function()

    GAG2ACFRefreshDropdownValues()
end)

--==================================================
-- [9] VISUALS TAB
--==================================================

VisualsMainBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>GAG2 Research</b></font>'
        .. '\nThis only reads the game tree.'
        .. '\nUse this before adding HUD, shop, farm, or sniper systems.',
    DoesWrap = true,
    Size = 13,
})

VisualsMainBox:AddDivider()

VisualsMainBox:AddButton({
    Text = "Print Snapshot",
    Tooltip = "Print GAG2 roots to console.",
    Func = function()

        PrintSnapshot(
            false
        )
    end,
}):AddButton({
    Text = "Copy Snapshot",
    Tooltip = "Copy GAG2 roots to clipboard.",
    Func = function()

        PrintSnapshot(
            true
        )
    end,
})

VisualsStatusBox:AddLabel({
    Text =
        '<font color="rgb(148,163,184)"><b>Snapshot Checks</b></font>'
        .. '\n- workspace.Map'
        .. '\n- WildPetSpawns'
        .. '\n- WildPetRef'
        .. '\n- StockValues'
        .. '\n- ReplicaSet'
        .. '\n- Packet RemoteEvent',
    DoesWrap = true,
})

VisualsStatusBox:AddLabel("HolyGAG2SnapshotStatus", {
    Text =
        "Snapshot: not scanned yet.",
    DoesWrap = true,
})

--==================================================
-- [9.5] SNIPER TAB
--==================================================

SniperMainBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Wild Pet Sniper</b></font>',
    DoesWrap = true,
    Size = 13,
})

SniperMainBox:AddDivider()

SniperTargetDropdown =
    SniperMainBox:AddDropdown(
        "HolyGAG2SniperTargetsList",
        {
            Text = "Target Pets",
            Values = SniperGetDropdownPetNames(),
            Default = {},
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Select pets to look for.",
        }
    )

if SniperTargetDropdown
and type(SniperTargetDropdown.OnChanged) == "function" then

    SniperTargetDropdown:OnChanged(function(value)

        if SniperDropdownRefreshing == true then
            return
        end

        SniperSetTargets(
            value
        )

        SniperScan(
            false
        )
    end)
end

SniperMainBox:AddButton({
    Text = "Refresh List",
    Tooltip = "Refresh available pet names.",
    Func = function()

        SniperRefreshTargetDropdown()
        SniperRefreshPriorityDropdowns()

        SetSniperStatus(
            "List refreshed."
        )
    end,
})

SniperMainBox:AddDivider()

SniperMainBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Buy Priority</b></font>',
    DoesWrap = true,
    Size = 13,
})

for priorityIndex = 1, 5 do

    SniperPriorityDropdowns[priorityIndex] =
        SniperMainBox:AddDropdown(
            "HolyGAG2SniperPriority"
                .. tostring(priorityIndex),
            {
                Text =
                    "Priority "
                    .. tostring(priorityIndex),
                Values =
                    SniperGetPriorityDropdownValues(),
                Default =
                    "None",
                Multi =
                    false,
                Searchable =
                    true,
                AllowNull =
                    false,
                MaxVisibleDropdownItems =
                    10,
                Tooltip =
                    "Higher priority pets are bought first.",
            }
        )

    if SniperPriorityDropdowns[priorityIndex]
    and type(SniperPriorityDropdowns[priorityIndex].OnChanged) == "function" then

        SniperPriorityDropdowns[priorityIndex]:OnChanged(function(value)

            if SniperPriorityRefreshing == true then
                return
            end

            SniperSetPriorityPet(
                priorityIndex,
                value
            )

            SniperScan(
                false
            )
        end)
    end
end

SniperMainBox:AddButton({
    Text = "Clear Priority",
    Tooltip = "Reset all priority slots.",
    Func = function()

        for priorityIndex = 1, 5 do

            SniperSetPriorityPet(
                priorityIndex,
                ""
            )

            local dropdown =
                SniperPriorityDropdowns[priorityIndex]

            if dropdown
            and type(dropdown.SetValue) == "function" then

                pcall(function()

                    dropdown:SetValue(
                        "None"
                    )
                end)
            end
        end

        SniperScan(
            false
        )
    end,
})

SniperMainBox:AddDivider()

GAG2_SNIPER_TOGGLE_CONTROL =
    SniperMainBox:AddToggle("HolyGAG2SniperEnabled", {
        Text = "Activate Sniper",
        Default = false,
        Tooltip = "Start looking for selected pets. Hotkey: F.",
        Callback = function(value)

            if GAG2_SNIPER_STOPPING == true then
                return
            end

            SniperSetEnabled(
                value == true
            )

            MarkConfigDirty()
        end,
    })

if GAG2_SNIPER_TOGGLE_CONTROL
and type(GAG2_SNIPER_TOGGLE_CONTROL.AddKeyPicker) == "function" then

    GAG2_SNIPER_KEYBIND_CONTROL =
        GAG2_SNIPER_TOGGLE_CONTROL:AddKeyPicker(
            "HolyGAG2SniperHotkey",
            {
                Text = "Sniper Key",
                Default = "F",
                Mode = "Toggle",
                SyncToggleState = true,
            }
        )
end

SniperMainBox:AddToggle("HolyGAG2SniperAutoHop", {
    Text = "Auto Hop If No Match",
    Default = false,
    Tooltip = "Hop when no selected pet is found.",
    Callback = function(value)

        SniperState.AutoHop =
            value == true

        SetSniperStatus(
            SniperState.AutoHop == true
            and "Auto hop enabled."
            or "Auto hop disabled."
        )

        MarkConfigDirty()
    end,
})

SniperMainBox:AddToggle("HolyGAG2SniperInstantFirstHop", {
    Text = "Instant Hop On Join",
    Default = SniperState.InstantFirstHop == true,
    Tooltip = "Aggressive mode. Hops immediately on first no-match while STOP HUD stays visible.",
    Callback = function(value)

        SniperState.InstantFirstHop =
            value == true

        MarkConfigDirty()
    end,
})

SniperMainBox:AddToggle("HolyGAG2SniperReturnAfterTame", {
    Text = "Return After Buy",
    Default = SniperState.ReturnAfterTame == true,
    Tooltip = "Return to your saved position after buying.",
    Callback = function(value)

        SniperState.ReturnAfterTame =
            value == true

        MarkConfigDirty()
    end,
})

SniperMainBox:AddInput("HolyGAG2SniperHopDelay", {
    Text = "Hop Delay",
    Default = tostring(SniperState.HopDelay),
    Numeric = true,
    Finished = true,
    ClearTextOnFocus = false,
    Placeholder = "20",
    Tooltip = "Minimum seconds between hop attempts.",
    Callback = function(value)

        SniperState.HopDelay =
            math.clamp(
                tonumber(value)
                or 20,
                5,
                120
            )

        SetSniperStatus(
            "Hop delay: "
            .. tostring(SniperState.HopDelay)
            .. "s"
        )

        MarkConfigDirty()
    end,
})

SniperMainBox:AddDivider()

SniperMainBox:AddButton({
    Text = "Scan Now",
    Tooltip = "Check once.",
    Func = function()

        SniperScan(
            false
        )
    end,
}):AddButton({
    Text = "Copy Results",
    Tooltip = "Copy last result.",
    Func = function()

        if CopyText(SniperState.LastMatchText) == true then

            Notify(
                "Sniper",
                "Results copied.",
                3
            )

        else

            Notify(
                "Clipboard",
                "Clipboard unsupported.",
                4
            )
        end
    end,
})

SniperStatusBox:AddLabel("HolyGAG2SniperStatus", {
    Text =
        "Ready.",
    DoesWrap = true,
})

SniperStatusBox:AddLabel("HolyGAG2SniperMatches", {
    Text =
        '<font color="rgb(196,181,253)"><b>Selected Targets</b></font>'
        .. '\nNone'
        .. '\n\n'
        .. '<font color="rgb(196,181,253)"><b>Result</b></font>'
        .. '\nNo scan yet.',
    DoesWrap = true,
})

SniperRefreshTargetDropdown()

task.delay(1, function()

    SniperRefreshTargetDropdown()
end)

task.delay(3, function()

    SniperRefreshTargetDropdown()
end)

SetSniperStatus(
    "Ready."
)

RefreshSniperLabels()

--==================================================
-- [10] SETTINGS TAB
--==================================================

SettingsUIBox:AddToggle(
    "HolyGAG2AutoCloseUI",
    {
        Text = "Auto Close UI",
        Default = UIState.ShowUIOnLoad ~= true,
        Tooltip = "When enabled, the UI starts closed on next execution. Press LeftAlt to open it.",
    }
):OnChanged(function(value)

    UIState.ShowUIOnLoad =
        value ~= true

    SaveUISettingsNow()
    MarkConfigDirty()
end)

SettingsUIBox:AddDropdown(
    "HolyGAG2DPI",
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
        Default =
            FormatDPIScale(
                UIState.DPIScale
            ),
        Multi = false,
        Searchable = false,
        MaxVisibleDropdownItems = 9,
        Tooltip = "Changes the size of the interface.",
    }
):OnChanged(function(value)

    local scale =
        ParseDPIScale(value)

    UIState.DPIScale =
        scale

    if Library
    and type(Library.SetDPIScale) == "function" then

        pcall(function()

            Library:SetDPIScale(
                scale
            )
        end)
    end

    SaveUISettingsNow()
    MarkConfigDirty()
end)

SettingsUIBox:AddDivider()

SettingsUIBox:AddToggle(
    "HolyGAG2AutoSkipLoading",
    {
        Text = "Auto Skip Loading",
        Default = true,
        Tooltip = "Safe monitored screen-hold during GAG2 loading. No GUI scanning, no firesignal, no remote spoofing.",
    }
):OnChanged(function(value)

    if ConfigState.Loading == true then
        return
    end

    if type(GAG2SetAutoSkipLoadingEnabled) == "function" then

        GAG2SetAutoSkipLoadingEnabled(
            value == true
        )
    end
end)

SettingsUIBox:AddToggle(
    "HolyGAG2AutoTpMiddleFarm",
    {
        Text = "Auto TP Middle Farm",
        Default = false,
        Tooltip = "Early TP once, then one post-load repair if GAG2 pulls you back.",
    }
):OnChanged(function(value)

    if ConfigState.Loading == true then
        return
    end

    if type(GAG2SetAutoTpMiddleFarmEnabled) == "function" then

        GAG2SetAutoTpMiddleFarmEnabled(
            value == true
        )
    end
end)

SettingsUIBox:AddDivider()

SettingsUIBox:AddToggle("HolyGAG2HideOtherGardens", {
    Text = "Hide Other Gardens",
    Default = false,
    Tooltip = "Locally hides other players gardens. Your own garden stays visible. Turn OFF to restore.",
    Callback = function(value)

        GAG2PerformanceSetHideOtherGardensEnabled(
            value == true
        )
    end,
})

SettingsUIBox:AddToggle("HolyGAG2AntiAfk", {
    Text = "Anti AFK",
    Default = true,
    Tooltip = "Default ON. Responds only when Roblox fires LocalPlayer.Idled. No remotes, no loop, no console output.",
    Callback = function(value)

        GAG2AntiAfkSetEnabled(
            value == true
        )
    end,
})

SettingsUIBox:AddButton({
    Text = "Restore Gardens",
    Tooltip = "Restores gardens hidden by Hide Other Gardens.",
    Func = function()

        GAG2_PERFORMANCE_STATE.HideOtherGardens =
            false

        if Toggles.HolyGAG2HideOtherGardens
        and type(Toggles.HolyGAG2HideOtherGardens.SetValue) == "function" then

            pcall(function()

                Toggles.HolyGAG2HideOtherGardens:SetValue(
                    false
                )
            end)
        end

        GAG2PerformanceRestoreHiddenGardens(
            "manual restore"
        )
    end,
})

SettingsUIBox:AddDivider()

SettingsUIBox:AddButton({
    Text = "Unload UI",
    Risky = true,
    DoubleClick = true,
    Tooltip = "Unload Holy GAG2 UI.",
    Func = function()

        Library:Unload()
    end,
})

--==================================================
-- [11] DEV TAB
--==================================================

if DevToolsBox
and DevInfoBox then

    DevToolsBox:AddLabel({
        Text =
            '<font color="rgb(196,181,253)"><b>Developer Tools</b></font>'
            .. '\nResearch tools only.',
        DoesWrap = true,
        Size = 13,
    })

    DevToolsBox:AddButton({
        Text = "Remote Spy",
        Tooltip = "Open Utopia Remote Spy.",
        Func = function()

            LoadDevTool(
                "https://raw.githubusercontent.com/Klinac/scripts/main/utopia_spy.lua",
                "Remote Spy"
            )
        end,
    })

    DevToolsBox:AddButton({
        Text = "Cobalt Spy",
        Tooltip = "Open Cobalt Remote Spy. Better for incoming/outgoing network traffic research.",
        Func = function()

            LoadDevTool(
                "https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau",
                "Cobalt Spy"
            )
        end,
    })

    DevToolsBox:AddButton({
        Text = "Dex Explorer",
        Tooltip = "Open Dex Explorer.",
        Func = function()

            LoadDevTool(
                "https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua",
                "Dex Explorer"
            )
        end,
    })

    DevInfoBox:AddLabel({
        Text =
            '<font color="rgb(148,163,184)"><b>Dev Info</b></font>'
            .. '\nUserId: '
            .. tostring(LOCAL_PLAYER.UserId)
            .. '\nPlaceId: '
            .. tostring(game.PlaceId)
            .. '\nJobId: '
            .. tostring(game.JobId),
        DoesWrap = true,
    })
end

--==================================================
-- [11.5] AUTOSAVE
--==================================================

ThemeManager:SetLibrary(
    Library
)

SaveManager:SetLibrary(
    Library
)

ThemeManager:SetFolder(
    "HolyGAG2"
)

SaveManager:SetFolder(
    "HolyGAG2"
)

SaveManager:IgnoreThemeSettings()

if type(SaveManager.SetIgnoreIndexes) == "function" then

    SaveManager:SetIgnoreIndexes({
        "HolyGAG2AutoCloseUI",
        "HolyGAG2DPI",
        "HolyGAG2ManualJoinTarget",

        -- Runtime/default-on helper.
        -- Auto Skip is intentionally ignored so it always defaults ON.
        "HolyGAG2AutoSkipLoading",
    })
end

pcall(function()

    ThemeManager:ApplyTheme(
        "Dark"
    )
end)

pcall(function()

    SaveManager:Load(
        ConfigState.AutosaveName
    )
end)

GAG2StartLoadingGuiCleaner()

local GAG2_EXACT_JOIN_PENDING_ON_LOAD =
    GAG2HandlePendingExactJoinOnLoad()

if GAG2_EXACT_JOIN_PENDING_ON_LOAD ~= true then

    RestoreSniperAutosaveState()
    GAG2RestoreShopAutosaveState()
end

ConfigState.Loading =
    false

if Toggles.HolyGAG2AutoSkipLoading
and type(Toggles.HolyGAG2AutoSkipLoading.SetValue) == "function" then

    pcall(function()

        Toggles.HolyGAG2AutoSkipLoading:SetValue(
            true
        )
    end)
end

if GAG2_EXACT_JOIN_PENDING_ON_LOAD ~= true then

    GAG2RestoreAntiAfkState()
    GAG2RestoreAutoTpMiddleFarmState()
    GAG2RestorePerformanceState()
    GAG2RestoreSeedPlantingState()
    GAG2RestoreAutoCollectFruitState()
    GAG2RestoreAutoSellState()
    GAG2RestoreMailboxState()
    GAG2RestoreSeedDropState()
    GAG2RestoreDropPickupState()
    GAG2RestoreServerSelectionState()
    GAG2RestoreVersionHopState()
end

task.spawn(function()

    while true do

        task.wait(1)

        if ConfigState.Dirty == true then

            ConfigState.Dirty =
                false

            pcall(function()

                SaveManager:Save(
                    ConfigState.AutosaveName
                )
            end)
        end
    end
end)

--==================================================
-- [12] FINISH
--==================================================

pcall(function()

    TeleportService.TeleportInitFailed:Connect(function(
        player,
        teleportResult,
        errorMessage,
        placeId
    )

        if player ~= LOCAL_PLAYER then
            return
        end

        local resultName =
            teleportResult
            and teleportResult.Name
            or "Unknown"

        local exactTarget =
            GAG2ReadExactJoinTarget()

        if exactTarget then

            warn(
                "[HOLY GAG2 EXACT JOIN]",
                "TeleportInitFailed",
                "| result:",
                tostring(resultName),
                "| error:",
                tostring(errorMessage),
                "| place:",
                tostring(placeId)
            )

            GAG2RetryExactJoinTarget(
                exactTarget,
                "TeleportInitFailed: "
                .. tostring(resultName)
            )

            return
        end

        if GAG2_SERVER_HOP_RETRYING ~= true then
            return
        end

        GAG2_SERVER_HOP_RETRYING =
            false

        task.delay(1, function()

            HopServerOnce()
        end)
    end)
end)

GAG2StartLoadingGuiCleaner()

GAG2ShopStart()
RefreshServerInfo()
RefreshHomeActivePets()
StartHomeActivePetsLoop()
StartGAG2SniperHotkey()
SetStatus("Ready")

Library:OnUnload(function()

    if type(GAG2AntiAfkSetEnabled) == "function" then

        GAG2AntiAfkSetEnabled(
            false,
            true
        )
    end

    if type(GAG2PerformanceRestoreHiddenGardens) == "function" then

        GAG2PerformanceRestoreHiddenGardens(
            "ui unload"
        )
    end

    print(
        "[HOLY GAG2]",
        "Unloaded."
    )
end)

Notify(
    "Holy GAG2",
    "Clean shell loaded. Toggle with LeftAlt.",
    4
)

print(
    "[HOLY GAG2]",
    "Clean shell loaded.",
    "| place:",
    tostring(game.PlaceId),
    "| job:",
    tostring(game.JobId)
)
