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

    return "Players: "
        .. tostring(#Players:GetPlayers())
        .. " | Code ready"
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
        "Holy GAG2 Joiner"

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

            table.sort(servers, function(a, b)

                return tonumber(a.FreeSlots or 0)
                    > tonumber(b.FreeSlots or 0)
            end)

            local target =
                servers[
                    math.random(
                        1,
                        math.min(#servers, 10)
                    )
                ]

            SetStatus(
                "Hopping to "
                .. tostring(target.playing)
                .. "/"
                .. tostring(target.maxPlayers)
                .. " server..."
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

    -- Loading-screen logic removed.
    -- Sniper readiness is now based only on character + pet folders in SniperReadyToBuy().

    if type(SniperState) == "table"
    and tonumber(SniperState.PlayScreenClearAt or 0) <= 0 then

        SniperState.PlayScreenClearAt =
            os.clock()
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
-- [4.55] AUTO TP MIDDLE FARM
--==================================================

local function GAG2FarmStripRichText(value)

    return CleanText(
        tostring(value or "")
            :gsub("<[^>]->", "")
            :gsub("<.->", "")
    )
end

local function GAG2ResolveOwnFarmPlot()

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
                                "billboard: "
                                .. tostring(gui.Name)
                        end
                    end
                end
            end
        end
    end

    return nil, "own garden billboard not found"
end

local function GAG2IsMiddleFarmPart(part)

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

local function GAG2GetOwnFarmMiddlePosition()

    local ownPlot, plotReason =
        GAG2ResolveOwnFarmPlot()

    if not ownPlot then
        return nil, plotReason
    end

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

    local rayParams =
        RaycastParams.new()

    rayParams.FilterType =
        Enum.RaycastFilterType.Exclude

    rayParams.FilterDescendantsInstances = {
        LOCAL_PLAYER.Character,
    }

    rayParams.IgnoreWater =
        true

    local rayResult =
        workspace:Raycast(
            center + Vector3.new(0, 80, 0),
            Vector3.new(0, -180, 0),
            rayParams
        )

    if rayResult
    and rayResult.Position then

        return rayResult.Position
            + Vector3.new(0, 5, 0),
            "middle: "
            .. PathOf(ownPlot)
    end

    return center + Vector3.new(0, 7, 0),
        "middle fallback: "
        .. PathOf(ownPlot)
end

local function GAG2WaitForCharacterRoot(timeout)

    local started =
        os.clock()

    timeout =
        tonumber(timeout)
        or 10

    while os.clock() - started < timeout do

        local character, root =
            SniperGetCharacterRoot()

        if character
        and root then

            return character,
                root
        end

        task.wait(
            0.15
        )
    end

    return nil,
        nil
end

function GAG2TeleportToMiddleFarmOnce(reason)

    local character, root =
        GAG2WaitForCharacterRoot(
            12
        )

    if not character
    or not root then

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastResult =
            "missing character"

        return false,
            "missing character"
    end

    local position, positionReason =
        GAG2GetOwnFarmMiddlePosition()

    if typeof(position) ~= "Vector3" then

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastResult =
            tostring(positionReason)

        return false,
            tostring(positionReason)
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

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastResult =
            "tp failed: "
            .. tostring(err)

        return false,
            tostring(err)
    end

    task.wait(
        0.05
    )

    local _, newRoot =
        SniperGetCharacterRoot()

    if newRoot then

        SniperStopCharacterMotion(
            newRoot
        )
    end

    GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastTeleportAt =
        os.clock()

    GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastResult =
        "teleported: "
        .. tostring(positionReason)

    print(
        "[HOLY GAG2]",
        "Auto TP Middle Farm",
        "| reason:",
        tostring(reason or "manual"),
        "|",
        tostring(positionReason)
    )

    return true,
        positionReason
end

function GAG2StartAutoTpMiddleFarm(reason)

    if GAG2_AUTO_TP_MIDDLE_FARM_STATE.Running == true then
        return
    end

    GAG2_AUTO_TP_MIDDLE_FARM_STATE.Running =
        true

    task.spawn(function()

        local started =
            os.clock()

        local position =
            nil

        local positionReason =
            "not resolved"

        local lastResolveAt =
            0

        task.wait(
            0.05
        )

        while os.clock() - started < 18 do

            if Toggles.HolyGAG2AutoTpMiddleFarm
            and Toggles.HolyGAG2AutoTpMiddleFarm.Value ~= true then

                GAG2_AUTO_TP_MIDDLE_FARM_STATE.Running =
                    false

                return
            end

            -- Loading-screen automation removed.
            -- Do not call GAG2AutoPlayLoadingStep() from farm teleport.

            if typeof(position) ~= "Vector3"
            or os.clock() - lastResolveAt >= 0.75 then

                lastResolveAt =
                    os.clock()

                local resolvedPosition, resolvedReason =
                    GAG2GetOwnFarmMiddlePosition()

                if typeof(resolvedPosition) == "Vector3" then

                    position =
                        resolvedPosition

                    positionReason =
                        tostring(resolvedReason)
                end
            end

            local ready, readyReason =
                GAG2ReadyForFarmTeleport()

            GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastResult =
                tostring(readyReason)

            if typeof(position) == "Vector3"
            and ready == true then

                break
            end

            if typeof(position) == "Vector3"
            and os.clock() - started >= 7 then

                local loadingActive, loadingDone =
                    GAG2ReadLoadingAttributes()

                if loadingDone == true
                and loadingActive ~= true then

                    positionReason =
                        tostring(positionReason)
                        .. " | loading done fallback"

                    break
                end
            end

            task.wait(
                0.08
            )
        end

        if typeof(position) ~= "Vector3" then

            local resolvedPosition, resolvedReason =
                GAG2GetOwnFarmMiddlePosition()

            position =
                resolvedPosition

            positionReason =
                tostring(resolvedReason)
        end

        if typeof(position) ~= "Vector3" then

            GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastResult =
                tostring(positionReason)

            GAG2_AUTO_TP_MIDDLE_FARM_STATE.Running =
                false

            return
        end

        local lockStarted =
            os.clock()

        local lockDuration =
            3.0

        local didTeleport =
            false

        while os.clock() - lockStarted < lockDuration do

            if Toggles.HolyGAG2AutoTpMiddleFarm
            and Toggles.HolyGAG2AutoTpMiddleFarm.Value ~= true then

                break
            end

            local character, root =
                SniperGetCharacterRoot()

            if character
            and root then

                local distance =
                    (root.Position - position).Magnitude

                if didTeleport ~= true
                or distance > 4 then

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

                    local ok =
                        pcall(function()

                            character:PivotTo(
                                targetCFrame
                            )
                        end)

                    if ok ~= true then

                        pcall(function()

                            root.CFrame =
                                targetCFrame
                        end)
                    end

                    didTeleport =
                        true

                    GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastTeleportAt =
                        os.clock()

                    GAG2_AUTO_TP_MIDDLE_FARM_STATE.LastResult =
                        "locked: "
                        .. tostring(positionReason)

                    print(
                        "[HOLY GAG2]",
                        "Auto TP Middle Farm lock",
                        "| reason:",
                        tostring(reason or "auto"),
                        "| distance:",
                        tostring(math.floor(distance + 0.5)),
                        "|",
                        tostring(positionReason)
                    )
                end

                SniperStopCharacterMotion(
                    root
                )
            end

            task.wait(
                0.12
            )
        end

        if didTeleport == true then

            print(
                "[HOLY GAG2]",
                "Auto TP Middle Farm lock finished",
                "|",
                tostring(positionReason)
            )
        end

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.Running =
            false
    end)
end

function GAG2SetAutoTpMiddleFarmEnabled(value)

    local enabled =
        value == true

    if enabled == true then

        GAG2StartAutoTpMiddleFarm(
            "toggle"
        )
    end

    MarkConfigDirty()
end

function GAG2RestoreAutoTpMiddleFarmState()

    if GAG2_AUTO_TP_MIDDLE_FARM_STATE.CharacterConnection == nil then

        GAG2_AUTO_TP_MIDDLE_FARM_STATE.CharacterConnection =
            LOCAL_PLAYER.CharacterAdded:Connect(function()

                task.wait(
                    0.65
                )

                if Toggles.HolyGAG2AutoTpMiddleFarm
                and Toggles.HolyGAG2AutoTpMiddleFarm.Value == true then

                    GAG2StartAutoTpMiddleFarm(
                        "respawn"
                    )
                end
            end)
    end

    task.defer(function()

        if Toggles.HolyGAG2AutoTpMiddleFarm
        and Toggles.HolyGAG2AutoTpMiddleFarm.Value == true then

            GAG2StartAutoTpMiddleFarm(
                "autosave"
            )
        end
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

    if mutation == ""
    and typeof(plant) == "Instance" then

        mutation =
            GAG2ACFClean(
                plant:GetAttribute("Mutation")
            )
    end

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

    for _, plant in ipairs(plants:GetChildren()) do

        local fruits =
            plant:FindFirstChild("Fruits")

        if fruits then

            for _, fruit in ipairs(fruits:GetChildren()) do

                if fruit:IsA("Model") then

                    local entry =
                        GAG2ACFBuildEntry(
                            plant,
                            fruit
                        )

                    if entry then

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
                end
            end
        end
    end

    GAG2ACFSortQueue(
        queue
    )

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
            Description = "Main controls.",
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
}

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

local HomeMainBox =
    Tabs.Home:AddLeftGroupbox(
        "Quick Actions",
        "sparkles"
    )

local HomeServerBox =
    Tabs.Home:AddRightGroupbox(
        "Live Pets",
        "radar"
    )

local ShopsMainBox =
    Tabs.Shops:AddLeftGroupbox(
        "Shop Controls",
        "shopping-cart"
    )

local ShopsStatusBox =
    Tabs.Shops:AddRightGroupbox(
        "Current Stock",
        "activity"
    )

local SellMainBox =
    Tabs.Sell:AddLeftGroupbox(
        "Controls",
        "coins"
    )

local SellStatusBox =
    Tabs.Sell:AddRightGroupbox(
        "Status",
        "receipt"
    )

local ExperimentMainBox =
    Tabs.Experiment:AddLeftGroupbox(
        "Controls",
        "flask-conical"
    )

local ExperimentStatusBox =
    Tabs.Experiment:AddRightGroupbox(
        "Status",
        "activity"
    )

local FarmMainBox =
    Tabs.Farm:AddLeftGroupbox(
        "Controls",
        "sprout"
    )

local FarmStatusBox =
    Tabs.Farm:AddRightGroupbox(
        "Status",
        "leaf"
    )

local VisualsMainBox =
    Tabs.Visuals:AddLeftGroupbox(
        "Research",
        "eye"
    )

local VisualsStatusBox =
    Tabs.Visuals:AddRightGroupbox(
        "Status",
        "scan-eye"
    )

local SniperMainBox =
    Tabs.Sniper:AddLeftGroupbox(
        "Wild Pet Sniper",
        "crosshair"
    )

local SniperStatusBox =
    Tabs.Sniper:AddRightGroupbox(
        "Sniper Status",
        "radar"
    )

local SettingsUIBox =
    Tabs.Settings:AddLeftGroupbox(
        "Interface",
        "sliders-horizontal"
    )

local DevToolsBox =
    nil

local DevInfoBox =
    nil

if Tabs.Dev then

    DevToolsBox =
        Tabs.Dev:AddLeftGroupbox(
            "Tools",
            "terminal"
        )

    DevInfoBox =
        Tabs.Dev:AddRightGroupbox(
            "Info",
            "info"
        )
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
-- [8.75] EXPERIMENT TAB
--==================================================

ExperimentMainBox:AddLabel({
    Text = "Ready.",
    DoesWrap = true,
    Size = 13,
})

ExperimentStatusBox:AddLabel("HolyGAG2ExperimentStatus", {
    Text = "Idle.",
    DoesWrap = true,
})

--==================================================
-- [8.9] FARM TAB
--==================================================

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

SettingsUIBox:AddToggle("HolyGAG2AutoTpMiddleFarm", {
    Text = "Auto TP Middle Farm",
    Default = false,
    Tooltip = "When enabled, teleports to the middle of your own farm after join/spawn.",
    Callback = function(value)

        GAG2SetAutoTpMiddleFarmEnabled(
            value == true
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
        Tooltip = "Open Remote Spy.",
        Func = function()

            LoadDevTool(
                "https://raw.githubusercontent.com/Klinac/scripts/main/utopia_spy.lua",
                "Remote Spy"
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

if GAG2_EXACT_JOIN_PENDING_ON_LOAD ~= true then

    GAG2RestoreAutoTpMiddleFarmState()
    GAG2RestoreAutoCollectFruitState()
    GAG2RestoreAutoSellState()
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
