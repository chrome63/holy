--==================================================
-- HOLY SCANNER
-- Scanner + Auto Buy Seeds/Gear + Optional Auto Hop
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

local UserInputService =
    game:GetService("UserInputService")

local LocalPlayer =
    Players.LocalPlayer
    or Players.PlayerAdded:Wait()

if not game:IsLoaded() then

    game.Loaded:Wait()
end

--==================================================
-- [1] CLEAN OLD RUN
--==================================================

local HolyScannerEnv =
    type(getgenv) == "function"
    and getgenv()
    or _G

pcall(function()

    if type(HolyScannerEnv.HOLY_SCANNER_STOP) == "function" then

        HolyScannerEnv.HOLY_SCANNER_STOP(
            "reload"
        )
    end

    if type(HolyScannerEnv.HOLY_WORKER_STOP) == "function" then

        HolyScannerEnv.HOLY_WORKER_STOP(
            "scanner reload"
        )
    end
end)

HOLY_SCANNER_RUNNING =
    true

HOLY_SCANNER_CONNECTIONS =
    {}

--==================================================
-- [2] CONSTANTS
--==================================================

local REPO_URL =
    "https://raw.githubusercontent.com/bencapalot041/goons/main/"

local REMOTE_SOURCE_VERSION =
    "holy-scanner-20260630-hop_fix_autohide_v1"

local LIBRARY_URL =
    REPO_URL
    .. "libraryholy5.lua?v="
    .. REMOTE_SOURCE_VERSION

local UI_SETTINGS_FOLDER =
    "HolyGAG2"

local SCANNER_SETTINGS_FILE =
    UI_SETTINGS_FOLDER
    .. "/HolyScannerSettings.json"

local SERVER_FINDER_API_BASE =
    "https://holy-server-finder-api.benjicapalot041.workers.dev"

local SERVER_FINDER_API_KEY =
    "holy_write_9Keb90_IL1br3x81ROQPxJS3fdJlAEvf1a8MECc1PNs"

local SCANNER_ACCOUNT_LABEL =
    HolyScannerEnv.HOLY_SCANNER_ACCOUNT_LABEL
    or ""

local SCANNER_VPS_LABEL =
    HolyScannerEnv.HOLY_SCANNER_VPS_LABEL
    or ""

local REPORT_INTERVAL =
    5

local CLIENT_HEARTBEAT_INTERVAL =
    5

local CLIENT_HEARTBEAT_BACKOFF =
    15

local RARE_SCAN_INTERVAL =
    0.85

local HUNT_GONE_CONFIRM_DEFAULT =
    1

local SERVER_MIN_PLAYERS =
    1

local SERVER_MAX_PLAYERS =
    8

local SERVER_TARGET_MAX_PLAYERS =
    5

local FLEET_HOP_ENABLED =
    true

local FLEET_TARGET_MAX_PLAYERS =
    5

local FLEET_SEARCH_PAGES =
    6

local FLEET_REQUEST_BACKOFF =
    8

local FLEET_JOIN_REPORT_MAX_AGE =
    180

local FLEET_JOIN_FILE =
    UI_SETTINGS_FOLDER
    .. "/HolyScannerFleetJoin.json"

local SERVER_DEFAULT_SEARCH_PAGES =
    5

local SERVER_RECENT_COOLDOWN =
    600

local SERVER_FAILED_COOLDOWN =
    120

local SERVER_RETRY_DELAY =
    1.75

local SERVER_TELEPORT_TIMEOUT =
    6

local SERVER_JOIN_BACKOFF_MIN =
    3

local SERVER_JOIN_BACKOFF_MAX =
    22

local SERVER_MIN_FREE_SLOTS =
    2

local SERVER_PICK_TOP_RANDOM =
    12

local SERVER_POOL_TARGET =
    32

local SHOP_MAX_BURST_FIRES =
    120

local SHOP_YIELD_EVERY =
    24

local Library =
    nil

local Options =
    nil

local Toggles =
    nil

--==================================================
-- [3] STATES
--==================================================

HOLY_SCANNER_STATE = {
    AutoBuySeeds = false,

    SelectedSeeds = {
        "All",
    },

    AutoBuyGear = false,

    SelectedGear = {
        "All",
    },

    HuntMode = true,

    -- Legacy setting name. Kept only so old saved settings migrate safely.
    AutoHop = true,

    SearchPages = 5,

    -- No target in server -> hop after this many seconds.
    HopDelay = 3,

    -- Watched target disappeared -> confirm gone for this many seconds, then hop.
    GoneConfirmDelay = 1,
}

HOLY_SCANNER_SHOP_STATE = {
    WorkerRunning = false,
    PendingCategories = {},
    BurstAttempts = {},
    PacketCache = {},
    ItemCache = {},
    StockConnected = false,
    MaxBurstFires = SHOP_MAX_BURST_FIRES,
    YieldEvery = SHOP_YIELD_EVERY,
}

HOLY_SCANNER_SERVER_STATE = {
    Hopping = false,
    HopToken = 0,
    HopAttempt = 0,
    LastHopAt = 0,

    HoldTargets = {},
    NoTargetSince = 0,
    GoneSince = 0,
    LastTargetSeenAt = 0,
    LastTargetText = "None",
    LastStatus = "Starting",

    LastTeleportError = "",
    LastTeleportFailAt = 0,
    LastTargetServer = "",
    LastTargetPlayers = "",

    LastFleetError = "",
    LastFleetAt = 0,
    FleetBackoffUntil = 0,
    FleetLastAssignedJobId = "",
    FleetLastAssignedText = "",

    TeleportBackoffUntil = 0,
    TeleportFailCount = 0,
    TeleportErrorWatcherStarted = false,

    RecentServers = {},
    FailedServers = {},
}

HOLY_SCANNER_REPORT_STATE = {
    Running = false,
    Token = nil,
    Sent = {},
    LastRareAt = 0,
    LastRareScanAt = 0,
    LastRareReportAt = 0,
    LastScannerReportAt = 0,
    LastClientHeartbeatAt = 0,
    ScannerBackoffUntil = 0,
    ClientHeartbeatBackoffUntil = 0,
    StartedAt = os.time(),
    LastError = "",
}

HOLY_SCANNER_LOADING_STATE = {
    Running = false,
    Token = nil,
    Connections = {},
    ClickedSkip = false,
    PressedFinal = false,
    LogsPrinted = 0,
    Ready = false,
}

HOLY_SCANNER_ANTI_AFK_STATE = {
    Running = false,
    Token = nil,
}

HOLY_SCANNER_PERFORMANCE_STATE = {
    Running = false,
    Token = nil,
    RemovedCount = 0,
}

HOLY_SCANNER_DATA_STATE = {
    Modules = {},
    PetDisplayToKey = {},
    PetKeyToDisplay = {},
}

HOLY_SCANNER_UI = {
    SeedDropdown = nil,
    GearDropdown = nil,
    StatusLabel = nil,
}

HolyScannerEnv.HOLY_SCANNER_STATE =
    HOLY_SCANNER_STATE

HolyScannerEnv.HOLY_SCANNER_SHOP_STATE =
    HOLY_SCANNER_SHOP_STATE

HolyScannerEnv.HOLY_SCANNER_REPORT_STATE =
    HOLY_SCANNER_REPORT_STATE

--==================================================
-- [4] BASIC HELPERS
--==================================================

function HolyScannerTrackConnection(connection)

    if connection then

        table.insert(
            HOLY_SCANNER_CONNECTIONS,
            connection
        )
    end

    return connection
end

function HolyScannerCleanText(value)

    local text =
        tostring(value or "")

    text =
        text:gsub(
            "^%s+",
            ""
        )

    text =
        text:gsub(
            "%s+$",
            ""
        )

    return text
end

function HolyScannerGetRequestFunction()

    if type(syn) == "table"
    and type(syn.request) == "function" then

        return syn.request
    end

    if type(http_request) == "function" then
        return http_request
    end

    if type(request) == "function" then
        return request
    end

    if type(fluxus) == "table"
    and type(fluxus.request) == "function" then

        return fluxus.request
    end

    if type(HolyScannerEnv) == "table" then

        if type(HolyScannerEnv.request) == "function" then
            return HolyScannerEnv.request
        end

        if type(HolyScannerEnv.http_request) == "function" then
            return HolyScannerEnv.http_request
        end
    end

    return nil
end

function HolyScannerValidateSource(body)

    if type(body) ~= "string"
    or body == "" then

        return nil,
            "empty response"
    end

    if body:sub(1, 3) == "\239\187\191" then

        body =
            body:sub(4)
    end

    local preview =
        body:sub(1, 220):lower()

    if preview:find("<!doctype html", 1, true)
    or preview:find("<html", 1, true)
    or preview:find("rate limit", 1, true) then

        return nil,
            "response was HTML/rate-limit page"
    end

    if body:find("\0", 1, true) then

        return nil,
            "response contains binary null bytes"
    end

    return body,
        nil
end

function HolyScannerHttpGet(url)

    url =
        HolyScannerCleanText(url)

    if url == "" then
        return nil, "empty URL"
    end

    local failures =
        {}

    local ok,
        result =
        pcall(function()

            return game:HttpGet(
                url,
                true
            )
        end)

    if ok == true then

        local source,
            sourceError =
            HolyScannerValidateSource(
                result
            )

        if source then
            return source, nil
        end

        table.insert(
            failures,
            "game:HttpGet: "
            .. tostring(sourceError)
        )

    else

        table.insert(
            failures,
            "game:HttpGet failed: "
            .. tostring(result)
        )
    end

    local requestFunction =
        HolyScannerGetRequestFunction()

    if type(requestFunction) == "function" then

        local requestOk,
            response =
            pcall(function()

                return requestFunction({
                    Url = url,
                    Method = "GET",
                    Headers = {
                        ["Accept"] = "text/plain",
                        ["Accept-Encoding"] = "identity",
                        ["Cache-Control"] = "no-cache",
                    },
                })
            end)

        if requestOk == true then

            local body =
                nil

            if type(response) == "string" then

                body =
                    response

            elseif type(response) == "table" then

                body =
                    response.Body
                    or response.body
                    or response.ResponseBody
                    or response.responseBody
            end

            local source,
                sourceError =
                HolyScannerValidateSource(
                    body
                )

            if source then
                return source, nil
            end

            table.insert(
                failures,
                "request: "
                .. tostring(sourceError)
            )

        else

            table.insert(
                failures,
                "request failed: "
                .. tostring(response)
            )
        end
    end

    return nil,
        table.concat(
            failures,
            " | "
        )
end

function HolyScannerDecodeJsonBody(body, label)

    if type(body) ~= "string" then

        return nil,
            tostring(label or "request")
            .. " returned no body"
    end

    if body:sub(1, 3) == "\239\187\191" then

        body =
            body:sub(4)
    end

    local decodeOk,
        decoded =
        pcall(function()

            return HttpService:JSONDecode(
                body
            )
        end)

    if decodeOk == true
    and type(decoded) == "table" then

        return decoded,
            nil
    end

    local lower =
        body:sub(1, 400):lower()

    if lower:find("<!doctype html", 1, true)
    or lower:find("<html", 1, true) then

        return nil,
            tostring(label or "request")
            .. " returned HTML"
    end

    return nil,
        tostring(label or "request")
        .. " invalid JSON"
end

function HolyScannerRequestJson(method, url, payload)

    local requestFunction =
        HolyScannerGetRequestFunction()

    local encoded =
        nil

    if payload ~= nil then

        local encodeOk,
            result =
            pcall(function()

                return HttpService:JSONEncode(
                    payload
                )
            end)

        if encodeOk ~= true
        or type(result) ~= "string" then

            return nil,
                "json encode failed"
        end

        encoded =
            result
    end

    if type(requestFunction) == "function" then

        local options = {
            Url =
                tostring(url),

            Method =
                tostring(method or "GET"),

            Headers = {
                ["Accept"] =
                    "application/json",

                ["Cache-Control"] =
                    "no-cache",
            },

            Redirect =
                true,
        }

        if encoded ~= nil then

            options.Headers["Content-Type"] =
                "application/json"

            options.Body =
                encoded
        end

        local ok,
            response =
            pcall(
                requestFunction,
                options
            )

        if ok ~= true then

            return nil,
                tostring(response)
        end

        local body =
            ""

        if type(response) == "string" then

            body =
                response

        elseif type(response) == "table" then

            body =
                response.Body
                or response.body
                or response.ResponseBody
                or response.responseBody
                or ""
        end

        return HolyScannerDecodeJsonBody(
            tostring(body or ""),
            url
        )
    end

    if encoded ~= nil then

        local ok,
            body =
            pcall(function()

                return HttpService:PostAsync(
                    url,
                    encoded,
                    Enum.HttpContentType.ApplicationJson,
                    false
                )
            end)

        if ok == true then

            return HolyScannerDecodeJsonBody(
                tostring(body or ""),
                url
            )
        end

        return nil,
            tostring(body)
    end

    return nil,
        "request function unavailable"
end

function HolyScannerGetCompiler()

    if type(loadstring) == "function" then
        return loadstring
    end

    if type(load) == "function" then
        return load
    end

    if type(HolyScannerEnv) == "table" then

        if type(HolyScannerEnv.loadstring) == "function" then
            return HolyScannerEnv.loadstring
        end

        if type(HolyScannerEnv.load) == "function" then
            return HolyScannerEnv.load
        end
    end

    return nil
end

function HolyScannerLoadUrl(url, name)

    name =
        tostring(name or "remote script")

    local source,
        downloadError =
        HolyScannerHttpGet(url)

    if type(source) ~= "string"
    or source == "" then

        error(
            "[HOLY SCANNER] Failed to download "
            .. name
            .. ": "
            .. tostring(downloadError),
            0
        )
    end

    local compiler =
        HolyScannerGetCompiler()

    if type(compiler) ~= "function" then

        error(
            "[HOLY SCANNER] loadstring/load is missing.",
            0
        )
    end

    local compileOk,
        chunk,
        compileError =
        pcall(
            compiler,
            source
        )

    if compileOk ~= true
    or type(chunk) ~= "function" then

        error(
            "[HOLY SCANNER] Failed to compile "
            .. name
            .. ": "
            .. tostring(compileError or chunk),
            0
        )
    end

    local runOk,
        result =
        pcall(chunk)

    if runOk ~= true then

        error(
            "[HOLY SCANNER] Failed to run "
            .. name
            .. ": "
            .. tostring(result),
            0
        )
    end

    return result
end

function HolyScannerCanUseFiles()

    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

function HolyScannerEnsureFolder()

    if type(makefolder) ~= "function"
    or type(isfolder) ~= "function" then

        return false
    end

    local ok =
        pcall(function()

            if not isfolder(UI_SETTINGS_FOLDER) then

                makefolder(
                    UI_SETTINGS_FOLDER
                )
            end
        end)

    return ok == true
end

function HolyScannerNotify(title, description, duration)

    if Library
    and type(Library.Notify) == "function" then

        Library:Notify({
            Title =
                tostring(title or "HOLY Scanner"),

            Description =
                tostring(description or ""),

            Time =
                tonumber(duration)
                or 4,
        })

        return true
    end

    print(
        "[HOLY SCANNER]",
        tostring(title or ""),
        tostring(description or "")
    )

    return false
end

function HolyScannerBackendUrl(path)

    path =
        tostring(path or "")

    if path:sub(1, 1) ~= "/" then

        path =
            "/"
            .. path
    end

    return SERVER_FINDER_API_BASE
        .. path
end

function HolyScannerGetPlayerCounts()

    local playing =
        #Players:GetPlayers()

    local maxPlayers =
        8

    pcall(function()

        maxPlayers =
            tonumber(
                Players.MaxPlayers
            )
            or 8
    end)

    if maxPlayers <= 0 then
        maxPlayers = 8
    end

    return playing,
        maxPlayers
end

function HolyScannerReadServerVersion()

    local candidates = {
        ReplicatedStorage:FindFirstChild("ServerVersion", true),
        ReplicatedStorage:FindFirstChild("Version", true),
        workspace:FindFirstChild("ServerVersion", true),
        workspace:FindFirstChild("Version", true),
    }

    for _, instance in ipairs(candidates) do

        if typeof(instance) == "Instance" then

            if instance:IsA("ValueBase") then

                local ok,
                    value =
                    pcall(function()

                        return instance.Value
                    end)

                value =
                    HolyScannerCleanText(
                        ok == true
                        and value
                        or ""
                    )

                if value ~= "" then
                    return value
                end
            end

            local ok,
                attr =
                pcall(function()

                    return instance:GetAttribute(
                        "Version"
                    )
                end)

            attr =
                HolyScannerCleanText(
                    ok == true
                    and attr
                    or ""
                )

            if attr ~= "" then
                return attr
            end
        end
    end

    for _, root in ipairs({
        ReplicatedStorage,
        workspace,
        game,
    }) do

        if typeof(root) == "Instance" then

            for _, attrName in ipairs({
                "ServerVersion",
                "Version",
                "GameVersion",
            }) do

                local ok,
                    attr =
                    pcall(function()

                        return root:GetAttribute(
                            attrName
                        )
                    end)

                attr =
                    HolyScannerCleanText(
                        ok == true
                        and attr
                        or ""
                    )

                if attr ~= "" then
                    return attr
                end
            end
        end
    end

    return ""
end

function HolyScannerSelectionArray(value)

    local output =
        {}

    local seen =
        {}

    local functionAdd =
        function(itemName)

            itemName =
                HolyScannerCleanText(itemName)

            if itemName == ""
            or seen[itemName] == true then
                return
            end

            seen[itemName] =
                true

            table.insert(
                output,
                itemName
            )
        end

    if type(value) == "table" then

        for key, enabled in pairs(value) do

            if type(key) == "number" then

                functionAdd(
                    enabled
                )

            elseif enabled == true then

                functionAdd(
                    key
                )
            end
        end

    elseif type(value) == "string" then

        functionAdd(
            value
        )
    end

    table.sort(output, function(a, b)

        if a == "All" then
            return true
        end

        if b == "All" then
            return false
        end

        return tostring(a) < tostring(b)
    end)

    return output
end

function HolyScannerReadInteger(value, fallback)

    local number =
        tonumber(
            tostring(value or "")
                :match("%-?%d+")
        )

    if not number then

        number =
            tonumber(fallback)
            or 0
    end

    return math.floor(number)
end

function HolyScannerReadNumber(value, fallback)

    local number =
        tonumber(
            tostring(value or "")
                :match("%-?%d+%.?%d*")
        )

    if not number then

        number =
            tonumber(fallback)
            or 0
    end

    return number
end

--==================================================
-- [5] SETTINGS
--==================================================

function HolyScannerNormalizeState()

    HOLY_SCANNER_STATE.AutoBuySeeds =
        HOLY_SCANNER_STATE.AutoBuySeeds == true

    HOLY_SCANNER_STATE.AutoBuyGear =
        HOLY_SCANNER_STATE.AutoBuyGear == true

    local huntMode =
        HOLY_SCANNER_STATE.HuntMode

    if huntMode == nil then

        huntMode =
            HOLY_SCANNER_STATE.AutoHop
    end

    HOLY_SCANNER_STATE.HuntMode =
        huntMode == true

    -- Keep legacy field synced for old settings/users.
    HOLY_SCANNER_STATE.AutoHop =
        HOLY_SCANNER_STATE.HuntMode == true

    HOLY_SCANNER_STATE.SearchPages =
        math.clamp(
            HolyScannerReadInteger(
                HOLY_SCANNER_STATE.SearchPages,
                SERVER_DEFAULT_SEARCH_PAGES
            ),
            1,
            10
        )

    HOLY_SCANNER_STATE.HopDelay =
        math.clamp(
            HolyScannerReadNumber(
                HOLY_SCANNER_STATE.HopDelay,
                3
            ),
            1,
            300
        )

    HOLY_SCANNER_STATE.GoneConfirmDelay =
        math.clamp(
            HolyScannerReadNumber(
                HOLY_SCANNER_STATE.GoneConfirmDelay,
                HUNT_GONE_CONFIRM_DEFAULT
            ),
            0.25,
            10
        )

    HOLY_SCANNER_STATE.SelectedSeeds =
        HolyScannerSelectionArray(
            HOLY_SCANNER_STATE.SelectedSeeds
        )

    if #HOLY_SCANNER_STATE.SelectedSeeds <= 0 then

        HOLY_SCANNER_STATE.SelectedSeeds = {
            "All",
        }
    end

    HOLY_SCANNER_STATE.SelectedGear =
        HolyScannerSelectionArray(
            HOLY_SCANNER_STATE.SelectedGear
        )

    if #HOLY_SCANNER_STATE.SelectedGear <= 0 then

        HOLY_SCANNER_STATE.SelectedGear = {
            "All",
        }
    end

    return HOLY_SCANNER_STATE
end

function HolyScannerSaveSettings()

    if HolyScannerCanUseFiles() ~= true then
        return false
    end

    HolyScannerEnsureFolder()

    HolyScannerNormalizeState()

    local payload = {
        AutoBuySeeds =
            HOLY_SCANNER_STATE.AutoBuySeeds == true,

        SelectedSeeds =
            HolyScannerSelectionArray(
                HOLY_SCANNER_STATE.SelectedSeeds
            ),

        AutoBuyGear =
            HOLY_SCANNER_STATE.AutoBuyGear == true,

        SelectedGear =
            HolyScannerSelectionArray(
                HOLY_SCANNER_STATE.SelectedGear
            ),

        HuntMode =
            HOLY_SCANNER_STATE.HuntMode == true,

        -- Legacy compatibility.
        AutoHop =
            HOLY_SCANNER_STATE.HuntMode == true,

        SearchPages =
            HOLY_SCANNER_STATE.SearchPages,

        HopDelay =
            HOLY_SCANNER_STATE.HopDelay,

        GoneConfirmDelay =
            HOLY_SCANNER_STATE.GoneConfirmDelay,
    }

    local encodeOk,
        encoded =
        pcall(function()

            return HttpService:JSONEncode(
                payload
            )
        end)

    if encodeOk ~= true
    or type(encoded) ~= "string" then

        return false
    end

    local writeOk =
        pcall(function()

            writefile(
                SCANNER_SETTINGS_FILE,
                encoded
            )
        end)

    return writeOk == true
end

function HolyScannerLoadSettings()

    if HolyScannerCanUseFiles() ~= true then
        return false
    end

    local exists =
        false

    pcall(function()

        exists =
            isfile(
                SCANNER_SETTINGS_FILE
            )
    end)

    if exists ~= true then
        return false
    end

    local readOk,
        raw =
        pcall(function()

            return readfile(
                SCANNER_SETTINGS_FILE
            )
        end)

    if readOk ~= true
    or type(raw) ~= "string"
    or raw == "" then

        return false
    end

    local decodeOk,
        data =
        pcall(function()

            return HttpService:JSONDecode(
                raw
            )
        end)

    if decodeOk ~= true
    or type(data) ~= "table" then
        return false
    end

    HOLY_SCANNER_STATE.AutoBuySeeds =
        data.AutoBuySeeds == true

    HOLY_SCANNER_STATE.SelectedSeeds =
        HolyScannerSelectionArray(
            data.SelectedSeeds
        )

    HOLY_SCANNER_STATE.AutoBuyGear =
        data.AutoBuyGear == true

    HOLY_SCANNER_STATE.SelectedGear =
        HolyScannerSelectionArray(
            data.SelectedGear
        )

    if type(data.HuntMode) == "boolean" then

        HOLY_SCANNER_STATE.HuntMode =
            data.HuntMode

    elseif type(data.AutoHop) == "boolean" then

        HOLY_SCANNER_STATE.HuntMode =
            data.AutoHop

    else

        HOLY_SCANNER_STATE.HuntMode =
            true
    end

    HOLY_SCANNER_STATE.AutoHop =
        HOLY_SCANNER_STATE.HuntMode == true

    HOLY_SCANNER_STATE.SearchPages =
        data.SearchPages
        or HOLY_SCANNER_STATE.SearchPages

    HOLY_SCANNER_STATE.HopDelay =
        data.HopDelay
        or HOLY_SCANNER_STATE.HopDelay

    HOLY_SCANNER_STATE.GoneConfirmDelay =
        data.GoneConfirmDelay
        or HOLY_SCANNER_STATE.GoneConfirmDelay

    HolyScannerNormalizeState()

    return true
end

HOLY_SCANNER_SAVE_TOKEN =
    0

function HolyScannerQueueSaveSettings()

    HOLY_SCANNER_SAVE_TOKEN =
        (
            tonumber(HOLY_SCANNER_SAVE_TOKEN)
            or 0
        )
        + 1

    local token =
        HOLY_SCANNER_SAVE_TOKEN

    task.delay(0.25, function()

        if token ~= HOLY_SCANNER_SAVE_TOKEN then
            return
        end

        HolyScannerSaveSettings()
    end)
end

--==================================================
-- [6] INPUT / LOADING SKIP
--==================================================

function HolyScannerLoadingLog(...)

    HOLY_SCANNER_LOADING_STATE =
        type(HOLY_SCANNER_LOADING_STATE) == "table"
        and HOLY_SCANNER_LOADING_STATE
        or {}

    HOLY_SCANNER_LOADING_STATE.LogsPrinted =
        tonumber(HOLY_SCANNER_LOADING_STATE.LogsPrinted)
        or 0

    if HOLY_SCANNER_LOADING_STATE.LogsPrinted >= 8 then
        return
    end

    HOLY_SCANNER_LOADING_STATE.LogsPrinted =
        HOLY_SCANNER_LOADING_STATE.LogsPrinted + 1

    print(
        "[HOLY SCANNER LOADING]",
        ...
    )
end

function HolyScannerInputManager()

    local ok,
        service =
        pcall(function()

            return game:GetService(
                "VirtualInputManager"
            )
        end)

    if ok == true then
        return service
    end

    return nil
end

function HolyScannerLoadingPathOf(instance)

    if typeof(instance) ~= "Instance" then
        return tostring(instance)
    end

    local ok,
        result =
        pcall(function()

            return instance:GetFullName()
        end)

    if ok == true then
        return tostring(result)
    end

    return tostring(instance)
end

function HolyScannerLoadingGetText(instance)

    if typeof(instance) ~= "Instance" then
        return ""
    end

    if instance:IsA("TextLabel")
    or instance:IsA("TextButton")
    or instance:IsA("TextBox") then

        local ok,
            text =
            pcall(function()

                return instance.Text
            end)

        if ok == true then

            return HolyScannerCleanText(
                text
            )
        end
    end

    return ""
end

function HolyScannerLoadingGetTextTransparency(instance)

    local value =
        nil

    if typeof(instance) ~= "Instance" then
        return nil
    end

    pcall(function()

        if instance:IsA("TextLabel")
        or instance:IsA("TextButton")
        or instance:IsA("TextBox") then

            value =
                instance.TextTransparency
        end
    end)

    return tonumber(value)
end

function HolyScannerVisibleChainReady(instance)

    if typeof(instance) ~= "Instance" then
        return false
    end

    local current =
        instance

    while current
    and current ~= game do

        if current:IsA("GuiObject") then

            local visible =
                false

            local absSize =
                Vector2.zero

            pcall(function()

                visible =
                    current.Visible == true

                absSize =
                    current.AbsoluteSize
            end)

            if visible ~= true then
                return false
            end

            if current == instance
            and (
                typeof(absSize) ~= "Vector2"
                or absSize.X <= 2
                or absSize.Y <= 2
            ) then

                return false
            end
        end

        if current:IsA("LayerCollector") then

            local enabled =
                false

            pcall(function()

                enabled =
                    current.Enabled == true
            end)

            if enabled ~= true then
                return false
            end
        end

        if current == workspace then
            break
        end

        current =
            current.Parent
    end

    return true
end

function HolyScannerLoadingGetGuiCenter(instance)

    if typeof(instance) ~= "Instance"
    or instance:IsA("GuiObject") ~= true then

        return nil
    end

    local position =
        nil

    local size =
        nil

    pcall(function()

        position =
            instance.AbsolutePosition

        size =
            instance.AbsoluteSize
    end)

    if typeof(position) ~= "Vector2"
    or typeof(size) ~= "Vector2" then

        return nil
    end

    return Vector2.new(
        position.X + size.X / 2,
        position.Y + size.Y / 2
    )
end

function HolyScannerLoadingGetScreenCenter()

    local camera =
        workspace.CurrentCamera

    local viewport =
        camera
        and camera.ViewportSize
        or Vector2.new(
            1280,
            720
        )

    return Vector2.new(
        viewport.X / 2,
        viewport.Y / 2
    )
end

function HolyScannerClickAt(position)

    if typeof(position) ~= "Vector2" then
        return false
    end

    local inputManager =
        HolyScannerInputManager()

    if not inputManager then
        return false
    end

    pcall(function()

        inputManager:SendMouseMoveEvent(
            position.X,
            position.Y,
            game
        )
    end)

    task.wait(
        0.025
    )

    pcall(function()

        inputManager:SendMouseButtonEvent(
            position.X,
            position.Y,
            0,
            true,
            game,
            0
        )
    end)

    task.wait(
        0.055
    )

    pcall(function()

        inputManager:SendMouseButtonEvent(
            position.X,
            position.Y,
            0,
            false,
            game,
            0
        )
    end)

    return true
end

function HolyScannerPressKey(keyCode)

    local inputManager =
        HolyScannerInputManager()

    if not inputManager then
        return false
    end

    pcall(function()

        inputManager:SendKeyEvent(
            true,
            keyCode,
            false,
            game
        )
    end)

    task.wait(
        0.055
    )

    pcall(function()

        inputManager:SendKeyEvent(
            false,
            keyCode,
            false,
            game
        )
    end)

    return true
end

function HolyScannerLoadingGetWorkspaceLoadingGui()

    local menu =
        workspace:FindFirstChild(
            "LoadingScreenMenu"
        )

    if not menu then

        menu =
            workspace:FindFirstChild(
                "LoadingScreenMenu",
                true
            )
    end

    if not menu then
        return nil
    end

    local loadingGui =
        menu:FindFirstChild(
            "LoadingGui"
        )

    if not loadingGui then

        loadingGui =
            menu:FindFirstChild(
                "LoadingGui",
                true
            )
    end

    return loadingGui
end

function HolyScannerLoadingGetWorkspaceGui()

    return HolyScannerLoadingGetWorkspaceLoadingGui()
end

function HolyScannerLoadingGetInnerFrame()

    local loadingGui =
        HolyScannerLoadingGetWorkspaceLoadingGui()

    if not loadingGui then
        return nil
    end

    local variant =
        loadingGui:FindFirstChild(
            "Variant1Frame",
            true
        )

    if not variant then
        return nil
    end

    return variant:FindFirstChild(
        "InnerFrame",
        true
    )
end

function HolyScannerLoadingGetSkipPrompt()

    local innerFrame =
        HolyScannerLoadingGetInnerFrame()

    if not innerFrame then
        return nil
    end

    return innerFrame:FindFirstChild(
        "SkipTxt",
        true
    )
end

function HolyScannerLoadingGetCounterPrompt()

    local innerFrame =
        HolyScannerLoadingGetInnerFrame()

    if not innerFrame then
        return nil
    end

    return innerFrame:FindFirstChild(
        "CounterTxt",
        true
    )
end

function HolyScannerLoadingSkipPromptReady(skipPrompt)

    if typeof(skipPrompt) ~= "Instance" then
        return false
    end

    if HolyScannerVisibleChainReady(skipPrompt) ~= true then
        return false
    end

    local transparency =
        HolyScannerLoadingGetTextTransparency(
            skipPrompt
        )

    if transparency ~= nil
    and transparency >= 0.95 then

        return false
    end

    return true
end

function HolyScannerLoadingFullyLoaded(counterPrompt)

    if typeof(counterPrompt) ~= "Instance" then
        return false
    end

    if HolyScannerVisibleChainReady(counterPrompt) ~= true then
        return false
    end

    local text =
        HolyScannerLoadingGetText(
            counterPrompt
        )
        :lower()

    return text:find(
        "fully loaded",
        1,
        true
    ) ~= nil
end

function HolyScannerLoadingClickSkip(skipPrompt)

    HOLY_SCANNER_LOADING_STATE.ClickedSkip =
        true

    HolyScannerLoadingLog(
        "skip ready",
        "text="
            .. HolyScannerLoadingGetText(skipPrompt),
        "transparency="
            .. tostring(
                HolyScannerLoadingGetTextTransparency(
                    skipPrompt
                )
            )
    )

    local promptCenter =
        HolyScannerLoadingGetGuiCenter(
            skipPrompt
        )

    if promptCenter then

        HolyScannerClickAt(
            promptCenter
        )

        task.wait(
            0.08
        )
    end

    HolyScannerClickAt(
        HolyScannerLoadingGetScreenCenter()
    )

    task.wait(
        0.12
    )

    HolyScannerClickAt(
        HolyScannerLoadingGetScreenCenter()
    )

    HolyScannerLoadingLog(
        "clicked skip prompt"
    )
end

function HolyScannerLoadingPressFinal(counterPrompt)

    HOLY_SCANNER_LOADING_STATE.PressedFinal =
        true

    HOLY_SCANNER_LOADING_STATE.Ready =
        true

    HolyScannerLoadingLog(
        "fully loaded",
        HolyScannerLoadingGetText(counterPrompt),
        HolyScannerLoadingPathOf(counterPrompt)
    )

    HolyScannerPressKey(
        Enum.KeyCode.Space
    )

    task.wait(
        0.10
    )

    HolyScannerPressKey(
        Enum.KeyCode.Return
    )

    task.wait(
        0.10
    )

    HolyScannerClickAt(
        HolyScannerLoadingGetScreenCenter()
    )

    HolyScannerLoadingLog(
        "sent final play input"
    )
end

function HolyScannerStopLoadingSkip(reason)

    HOLY_SCANNER_LOADING_STATE =
        type(HOLY_SCANNER_LOADING_STATE) == "table"
        and HOLY_SCANNER_LOADING_STATE
        or {}

    HOLY_SCANNER_LOADING_STATE.Token =
        nil

    HOLY_SCANNER_LOADING_STATE.Running =
        false

    local connections =
        HOLY_SCANNER_LOADING_STATE.Connections

    if type(connections) == "table" then

        for _, connection in ipairs(connections) do

            pcall(function()

                connection:Disconnect()
            end)
        end
    end

    HOLY_SCANNER_LOADING_STATE.Connections =
        {}

    HolyScannerLoadingLog(
        "stopped",
        tostring(reason or "manual")
    )
end

function HolyScannerStartLoadingSkip(reason)

    HOLY_SCANNER_LOADING_STATE =
        type(HOLY_SCANNER_LOADING_STATE) == "table"
        and HOLY_SCANNER_LOADING_STATE
        or {}

    if HOLY_SCANNER_LOADING_STATE.Running == true then
        return false
    end

    HOLY_SCANNER_LOADING_STATE.Running =
        true

    HOLY_SCANNER_LOADING_STATE.ClickedSkip =
        false

    HOLY_SCANNER_LOADING_STATE.PressedFinal =
        false

    HOLY_SCANNER_LOADING_STATE.Ready =
        false

    HOLY_SCANNER_LOADING_STATE.LogsPrinted =
        0

    HOLY_SCANNER_LOADING_STATE.Connections =
        type(HOLY_SCANNER_LOADING_STATE.Connections) == "table"
        and HOLY_SCANNER_LOADING_STATE.Connections
        or {}

    local token =
        {}

    HOLY_SCANNER_LOADING_STATE.Token =
        token

    local startedAt =
        os.clock()

    HolyScannerLoadingLog(
        "started",
        tostring(reason or "startup")
    )

    task.spawn(function()

        while HOLY_SCANNER_LOADING_STATE.Token == token
        and os.clock() - startedAt <= 75 do

            local skipPrompt =
                HolyScannerLoadingGetSkipPrompt()

            if HOLY_SCANNER_LOADING_STATE.ClickedSkip ~= true
            and HolyScannerLoadingSkipPromptReady(skipPrompt) == true then

                HolyScannerLoadingClickSkip(
                    skipPrompt
                )
            end

            local counterPrompt =
                HolyScannerLoadingGetCounterPrompt()

            if HolyScannerLoadingFullyLoaded(counterPrompt) == true then

                if HOLY_SCANNER_LOADING_STATE.PressedFinal ~= true then

                    HolyScannerLoadingPressFinal(
                        counterPrompt
                    )
                end

                task.wait(
                    1
                )

                HOLY_SCANNER_LOADING_STATE.Token =
                    nil

                break
            end

            if HOLY_SCANNER_LOADING_STATE.ClickedSkip == true
            and HolyScannerLoadingGetWorkspaceLoadingGui() == nil then

                HOLY_SCANNER_LOADING_STATE.Ready =
                    true

                HOLY_SCANNER_LOADING_STATE.Token =
                    nil

                break
            end

            task.wait(
                0.05
            )
        end

        if HOLY_SCANNER_LOADING_STATE.Token == token then

            HOLY_SCANNER_LOADING_STATE.Token =
                nil

            HolyScannerLoadingLog(
                "timeout",
                "clickedSkip="
                    .. tostring(HOLY_SCANNER_LOADING_STATE.ClickedSkip),
                "pressedFinal="
                    .. tostring(HOLY_SCANNER_LOADING_STATE.PressedFinal)
            )
        end

        HOLY_SCANNER_LOADING_STATE.Running =
            false
    end)

    return true
end

HOLY_SCANNER_LOADING_STATE.Stop =
    HolyScannerStopLoadingSkip

function HolyScannerLoadingReady()

    if type(HOLY_SCANNER_LOADING_STATE) == "table"
    and HOLY_SCANNER_LOADING_STATE.PressedFinal == true then

        return true
    end

    if HolyScannerLoadingGetWorkspaceLoadingGui() == nil then
        return true
    end

    if type(HOLY_SCANNER_LOADING_STATE) == "table"
    and HOLY_SCANNER_LOADING_STATE.Ready == true then

        return true
    end

    return false
end

function HolyScannerWaitForLoadingReady(timeout)

    timeout =
        tonumber(timeout)
        or 80

    local startedAt =
        os.clock()

    while HOLY_SCANNER_RUNNING == true
    and os.clock() - startedAt <= timeout do

        if HolyScannerLoadingReady() == true then
            return true
        end

        task.wait(
            0.10
        )
    end

    return false
end

--==================================================
-- [7] ANTI AFK
--==================================================

function HolyScannerAntiAfkSetOverride()

    if not LocalPlayer then
        return false
    end

    local ok =
        pcall(function()

            LocalPlayer:SetAttribute(
                "AntiAfkIdleOverride",
                999999999
            )
        end)

    return ok == true
end

function HolyScannerAntiAfkPulse()

    HolyScannerAntiAfkSetOverride()

    local inputManager =
        HolyScannerInputManager()

    if not inputManager then
        return false
    end

    pcall(function()

        inputManager:SendKeyEvent(
            true,
            Enum.KeyCode.RightControl,
            false,
            game
        )
    end)

    task.wait(
        0.055
    )

    pcall(function()

        inputManager:SendKeyEvent(
            false,
            Enum.KeyCode.RightControl,
            false,
            game
        )
    end)

    return true
end

function HolyScannerStartAntiAfk()

    if HOLY_SCANNER_ANTI_AFK_STATE.Running == true then
        return false
    end

    HOLY_SCANNER_ANTI_AFK_STATE.Running =
        true

    local token =
        {}

    HOLY_SCANNER_ANTI_AFK_STATE.Token =
        token

    HolyScannerAntiAfkSetOverride()

    task.spawn(function()

        local nextPulseAt =
            os.clock() + 15

        while HOLY_SCANNER_RUNNING == true
        and HOLY_SCANNER_ANTI_AFK_STATE.Token == token do

            HolyScannerAntiAfkSetOverride()

            if os.clock() >= nextPulseAt then

                HolyScannerAntiAfkPulse()

                nextPulseAt =
                    os.clock() + 75
            end

            task.wait(
                1
            )
        end

        HOLY_SCANNER_ANTI_AFK_STATE.Running =
            false
    end)

    return true
end

--==================================================
-- [8] PERFORMANCE DELETE
--==================================================

function HolyScannerIsNpcTree(instance)

    if typeof(instance) ~= "Instance" then
        return false
    end

    local current =
        instance

    while current
    and current ~= game do

        if tostring(current.Name) == "NPCS" then
            return true
        end

        current =
            current.Parent
    end

    return false
end

function HolyScannerShouldKeepChild(child)

    if typeof(child) ~= "Instance" then
        return false
    end

    local name =
        tostring(child.Name)

    if name == "WildPetSpawns"
    or name == "WildPetRef" then

        return true
    end

    if name == "Steven" then
        return true
    end

    if HolyScannerIsNpcTree(child) == true then
        return true
    end

    return false
end

function HolyScannerRemoveChildLocal(child)

    if typeof(child) ~= "Instance" then
        return false
    end

    if HolyScannerShouldKeepChild(child) == true then
        return false
    end

    local ok =
        pcall(function()

            child.Parent =
                nil
        end)

    if ok == true then

        HOLY_SCANNER_PERFORMANCE_STATE.RemovedCount =
            (
                tonumber(
                    HOLY_SCANNER_PERFORMANCE_STATE.RemovedCount
                )
                or 0
            )
            + 1

        return true
    end

    return false
end

function HolyScannerGetGardensRoot()

    local root =
        workspace:FindFirstChild(
            "Gardens"
        )

    if typeof(root) == "Instance" then
        return root
    end

    root =
        workspace:FindFirstChild(
            "Gardens",
            true
        )

    if typeof(root) == "Instance" then
        return root
    end

    return nil
end

function HolyScannerGetMapRoot()

    local root =
        workspace:FindFirstChild(
            "Map"
        )

    if typeof(root) == "Instance" then
        return root
    end

    root =
        workspace:FindFirstChild(
            "Map",
            true
        )

    if typeof(root) == "Instance" then
        return root
    end

    return nil
end

function HolyScannerGetMiddleRoot()

    local map =
        HolyScannerGetMapRoot()

    if typeof(map) ~= "Instance" then
        return nil
    end

    local middle =
        map:FindFirstChild(
            "Middle"
        )

    if typeof(middle) == "Instance" then
        return middle
    end

    return nil
end

function HolyScannerGetStandsRoot()

    local map =
        HolyScannerGetMapRoot()

    if typeof(map) ~= "Instance" then
        return nil
    end

    local stands =
        map:FindFirstChild(
            "Stands"
        )

    if typeof(stands) == "Instance" then
        return stands
    end

    return nil
end

function HolyScannerGetNpcsRoot()

    local npcs =
        workspace:FindFirstChild(
            "NPCS"
        )

    if typeof(npcs) == "Instance" then
        return npcs
    end

    npcs =
        workspace:FindFirstChild(
            "NPCS",
            true
        )

    if typeof(npcs) == "Instance" then
        return npcs
    end

    return nil
end

function HolyScannerRemoveAllChildren(root)

    if typeof(root) ~= "Instance" then
        return 0
    end

    local children =
        {}

    pcall(function()

        children =
            root:GetChildren()
    end)

    local removed =
        0

    for _, child in ipairs(children) do

        if typeof(child) == "Instance"
        and child.Parent == root then

            if HolyScannerRemoveChildLocal(child) == true then

                removed =
                    removed + 1
            end
        end
    end

    return removed
end

function HolyScannerDeleteLagOnce()

    local removed =
        0

    removed =
        removed
        + HolyScannerRemoveAllChildren(
            HolyScannerGetGardensRoot()
        )

    removed =
        removed
        + HolyScannerRemoveAllChildren(
            HolyScannerGetMiddleRoot()
        )

    removed =
        removed
        + HolyScannerRemoveAllChildren(
            HolyScannerGetStandsRoot()
        )

    return removed
end

function HolyScannerWatchRemoveChildren(root)

    if typeof(root) ~= "Instance" then
        return false
    end

    if HolyScannerIsNpcTree(root) == true then
        return false
    end

    HOLY_SCANNER_PERFORMANCE_STATE.Watched =
        type(HOLY_SCANNER_PERFORMANCE_STATE.Watched) == "table"
        and HOLY_SCANNER_PERFORMANCE_STATE.Watched
        or {}

    if HOLY_SCANNER_PERFORMANCE_STATE.Watched[root] == true then
        return true
    end

    HOLY_SCANNER_PERFORMANCE_STATE.Watched[root] =
        true

    HolyScannerTrackConnection(
        root.ChildAdded:Connect(function(child)

            task.defer(function()

                if HOLY_SCANNER_RUNNING ~= true then
                    return
                end

                if typeof(child) == "Instance"
                and child.Parent == root then

                    HolyScannerRemoveChildLocal(
                        child
                    )
                end
            end)
        end)
    )

    return true
end

function HolyScannerStartDeleteLag()

    if HOLY_SCANNER_PERFORMANCE_STATE.Running == true then
        return false
    end

    HOLY_SCANNER_PERFORMANCE_STATE.Running =
        true

    HOLY_SCANNER_PERFORMANCE_STATE.Watched =
        {}

    local token =
        {}

    HOLY_SCANNER_PERFORMANCE_STATE.Token =
        token

    task.spawn(function()

        local deadline =
            os.clock() + 30

        while HOLY_SCANNER_RUNNING == true
        and HOLY_SCANNER_PERFORMANCE_STATE.Token == token
        and os.clock() <= deadline do

            HolyScannerDeleteLagOnce()

            HolyScannerWatchRemoveChildren(
                HolyScannerGetGardensRoot()
            )

            HolyScannerWatchRemoveChildren(
                HolyScannerGetMiddleRoot()
            )

            HolyScannerWatchRemoveChildren(
                HolyScannerGetStandsRoot()
            )

            task.wait(
                0.10
            )
        end
    end)

    HolyScannerTrackConnection(
        workspace.ChildAdded:Connect(function(child)

            task.defer(function()

                if HOLY_SCANNER_RUNNING ~= true then
                    return
                end

                if child.Name == "Gardens" then

                    HolyScannerRemoveAllChildren(
                        child
                    )

                    HolyScannerWatchRemoveChildren(
                        child
                    )

                    return
                end

                if child.Name == "NPCS" then
                    return
                end

                if child.Name == "Map" then

                    task.wait(
                        0.15
                    )

                    HolyScannerDeleteLagOnce()

                    HolyScannerWatchRemoveChildren(
                        HolyScannerGetMiddleRoot()
                    )

                    HolyScannerWatchRemoveChildren(
                        HolyScannerGetStandsRoot()
                    )
                end
            end)
        end)
    )

    task.spawn(function()

        while HOLY_SCANNER_RUNNING == true
        and HOLY_SCANNER_PERFORMANCE_STATE.Token == token do

            local map =
                HolyScannerGetMapRoot()

            if typeof(map) == "Instance"
            and HOLY_SCANNER_PERFORMANCE_STATE.MapWatcher ~= map then

                HOLY_SCANNER_PERFORMANCE_STATE.MapWatcher =
                    map

                HolyScannerTrackConnection(
                    map.ChildAdded:Connect(function(child)

                        task.defer(function()

                            if HOLY_SCANNER_RUNNING ~= true then
                                return
                            end

                            if child.Name == "Middle"
                            or child.Name == "Stands" then

                                task.wait(
                                    0.05
                                )

                                HolyScannerRemoveAllChildren(
                                    child
                                )

                                HolyScannerWatchRemoveChildren(
                                    child
                                )
                            end
                        end)
                    end)
                )
            end

            HolyScannerDeleteLagOnce()

            task.wait(
                0.50
            )
        end
    end)

    return true
end

--==================================================
-- [9] SHOP CORE
--==================================================

HOLY_SCANNER_SHOP_CATEGORIES = {
    Seeds = {
        ShopName = "SeedShop",
        PacketShop = "SeedShop",
        PacketName = "PurchaseSeed",
    },

    Gear = {
        ShopName = "GearShop",
        PacketShop = "GearShop",
        PacketName = "PurchaseGear",
    },
}

function HolyScannerShopRequireModule(path)

    local current =
        ReplicatedStorage

    for part in tostring(path or ""):gmatch("[^%.]+") do

        current =
            current
            and current:FindFirstChild(part)
            or nil
    end

    if typeof(current) ~= "Instance"
    or current:IsA("ModuleScript") ~= true then

        return nil
    end

    local ok,
        result =
        pcall(function()

            return require(
                current
            )
        end)

    if ok ~= true then
        return nil
    end

    return result
end

function HolyScannerShopAddItemRow(rows, name, price)

    name =
        HolyScannerCleanText(name)

    if name == "" then
        return
    end

    rows[name] =
        rows[name]
        or {
            Name = name,
            Price = 0,
        }

    rows[name].Price =
        math.max(
            tonumber(rows[name].Price)
            or 0,
            tonumber(price)
            or 0
        )
end

function HolyScannerShopModuleEnabled(modulePath, functionName, itemName, fallback)

    local module =
        HolyScannerShopRequireModule(
            modulePath
        )

    local callback =
        type(module) == "table"
        and module[functionName]
        or nil

    if type(callback) ~= "function" then
        return fallback ~= false
    end

    local ok,
        result =
        pcall(
            callback,
            itemName
        )

    if ok ~= true then

        ok,
            result =
            pcall(
                callback,
                module,
                itemName
            )
    end

    if ok == true
    and type(result) == "boolean" then

        return result
    end

    return fallback ~= false
end

function HolyScannerShopFlagEnabled(modulePath, itemName, fallback)

    local module =
        HolyScannerShopRequireModule(
            modulePath
        )

    local enabledOverrides =
        type(module) == "table"
        and module.EnabledOverrides
        or nil

    local valueTable =
        type(enabledOverrides) == "table"
        and enabledOverrides.Value
        or nil

    if type(valueTable) == "table"
    and valueTable[itemName] ~= nil then

        return valueTable[itemName] == true
    end

    return fallback ~= false
end

function HolyScannerShopBuildSeedRows()

    local rows =
        {}

    local data =
        HolyScannerShopRequireModule(
            "SharedModules.SeedData"
        )

    if type(data) == "table" then

        for _, row in pairs(data) do

            if type(row) == "table" then

                local seedName =
                    HolyScannerCleanText(
                        row.SeedName
                        or row.Name
                    )

                if seedName ~= ""
                and row.RestockShop == true
                and HolyScannerShopModuleEnabled(
                    "SharedModules.SeedShopEnabled",
                    "IsSeedEnabled",
                    seedName,
                    true
                ) == true then

                    HolyScannerShopAddItemRow(
                        rows,
                        seedName,
                        row.PurchasePrice
                        or row.Cost
                        or row.Price
                    )
                end
            end
        end
    end

    return rows
end

function HolyScannerShopBuildGearRows()

    local rows =
        {}

    local module =
        HolyScannerShopRequireModule(
            "SharedModules.GearShopData"
        )

    local data =
        type(module) == "table"
        and (
            module.Data
            or module
        )
        or nil

    if type(data) == "table" then

        for _, row in pairs(data) do

            if type(row) == "table" then

                local itemName =
                    HolyScannerCleanText(
                        row.ItemName
                        or row.Name
                    )

                if itemName ~= ""
                and row.HideFromShop ~= true
                and HolyScannerShopModuleEnabled(
                    "SharedModules.GearShopABTest",
                    "IsGearEnabled",
                    itemName,
                    true
                ) == true
                and HolyScannerShopFlagEnabled(
                    "SharedModules.Flags.GearShopFlags",
                    itemName,
                    true
                ) == true then

                    HolyScannerShopAddItemRow(
                        rows,
                        itemName,
                        row.Cost
                        or row.Price
                    )
                end
            end
        end
    end

    return rows
end

function HolyScannerShopGetItemRows(category)

    HOLY_SCANNER_SHOP_STATE.ItemCache =
        type(HOLY_SCANNER_SHOP_STATE.ItemCache) == "table"
        and HOLY_SCANNER_SHOP_STATE.ItemCache
        or {}

    if type(HOLY_SCANNER_SHOP_STATE.ItemCache[category]) == "table" then

        return HOLY_SCANNER_SHOP_STATE.ItemCache[category]
    end

    local map =
        {}

    if category == "Seeds" then

        map =
            HolyScannerShopBuildSeedRows()

    elseif category == "Gear" then

        map =
            HolyScannerShopBuildGearRows()
    end

    local rows =
        {}

    for _, row in pairs(map) do

        table.insert(
            rows,
            row
        )
    end

    table.sort(rows, function(a, b)

        local priceA =
            tonumber(a.Price)
            or 0

        local priceB =
            tonumber(b.Price)
            or 0

        if priceA ~= priceB then
            return priceA > priceB
        end

        return tostring(a.Name) < tostring(b.Name)
    end)

    HOLY_SCANNER_SHOP_STATE.ItemCache[category] =
        rows

    return rows
end

function HolyScannerShopGetDropdownValues(category)

    local values = {
        "All",
    }

    for _, row in ipairs(HolyScannerShopGetItemRows(category)) do

        table.insert(
            values,
            row.Name
        )
    end

    return values
end

function HolyScannerShopNormalizeSelection(value)

    local output =
        {}

    if type(value) == "table" then

        for key, enabled in pairs(value) do

            if type(key) == "number" then

                local text =
                    HolyScannerCleanText(enabled)

                if text ~= "" then

                    output[text] =
                        true
                end

            elseif enabled == true then

                local text =
                    HolyScannerCleanText(key)

                if text ~= "" then

                    output[text] =
                        true
                end
            end
        end

    elseif type(value) == "string" then

        local text =
            HolyScannerCleanText(value)

        if text ~= "" then

            output[text] =
                true
        end
    end

    return output
end

function HolyScannerShopGetSelection(category)

    if category == "Seeds" then

        return HolyScannerShopNormalizeSelection(
            HOLY_SCANNER_STATE.SelectedSeeds
        )

    elseif category == "Gear" then

        return HolyScannerShopNormalizeSelection(
            HOLY_SCANNER_STATE.SelectedGear
        )
    end

    return {}
end

function HolyScannerShopCategoryEnabled(category)

    if category == "Seeds" then
        return HOLY_SCANNER_STATE.AutoBuySeeds == true
    end

    if category == "Gear" then
        return HOLY_SCANNER_STATE.AutoBuyGear == true
    end

    return false
end

function HolyScannerShopGetSelectedRows(category)

    local selection =
        HolyScannerShopGetSelection(category)

    local hasSelection =
        false

    for _ in pairs(selection) do

        hasSelection =
            true

        break
    end

    if hasSelection ~= true then
        return {}
    end

    local useAll =
        selection.All == true

    local rows =
        {}

    for _, row in ipairs(HolyScannerShopGetItemRows(category)) do

        if useAll == true
        or selection[row.Name] == true then

            table.insert(
                rows,
                row
            )
        end
    end

    return rows
end

function HolyScannerShopGetStockValue(category, itemName)

    local config =
        HOLY_SCANNER_SHOP_CATEGORIES[category]

    local stockValues =
        ReplicatedStorage:FindFirstChild(
            "StockValues"
        )

    local shop =
        stockValues
        and stockValues:FindFirstChild(
            config
            and config.ShopName
            or ""
        )
        or nil

    local items =
        shop
        and shop:FindFirstChild(
            "Items"
        )
        or nil

    local valueObject =
        items
        and items:FindFirstChild(
            itemName
        )
        or nil

    if typeof(valueObject) ~= "Instance"
    or valueObject:IsA("ValueBase") ~= true then

        return 0
    end

    local value =
        0

    pcall(function()

        value =
            valueObject.Value
    end)

    return math.max(
        0,
        math.floor(
            tonumber(value)
            or 0
        )
    )
end

function HolyScannerShopGetRestockKey(category)

    local config =
        HOLY_SCANNER_SHOP_CATEGORIES[category]

    local stockValues =
        ReplicatedStorage:FindFirstChild(
            "StockValues"
        )

    local shop =
        stockValues
        and stockValues:FindFirstChild(
            config
            and config.ShopName
            or ""
        )
        or nil

    local value =
        0

    if typeof(shop) == "Instance" then

        local last =
            shop:FindFirstChild(
                "UnixLastRestock"
            )

        if last
        and last:IsA("ValueBase") then

            pcall(function()

                value =
                    last.Value
            end)
        end
    end

    return tostring(value)
end

function HolyScannerShopResolvePacket(category)

    local config =
        HOLY_SCANNER_SHOP_CATEGORIES[category]

    if type(config) ~= "table" then
        return nil
    end

    HOLY_SCANNER_SHOP_STATE.PacketCache =
        type(HOLY_SCANNER_SHOP_STATE.PacketCache) == "table"
        and HOLY_SCANNER_SHOP_STATE.PacketCache
        or {}

    if HOLY_SCANNER_SHOP_STATE.PacketCache[category] ~= nil then

        return HOLY_SCANNER_SHOP_STATE.PacketCache[category]
    end

    local networking =
        HolyScannerShopRequireModule(
            "SharedModules.Networking"
        )

    local packet =
        type(networking) == "table"
        and networking[config.PacketShop]
        and networking[config.PacketShop][config.PacketName]
        or nil

    if type(packet) ~= "table"
    or type(packet.Fire) ~= "function" then

        HOLY_SCANNER_SHOP_STATE.PacketCache[category] =
            false

        return nil
    end

    HOLY_SCANNER_SHOP_STATE.PacketCache[category] =
        packet

    return packet
end

function HolyScannerShopFireBurst(category, itemName, amount)

    local packet =
        HolyScannerShopResolvePacket(category)

    if type(packet) ~= "table" then
        return 0
    end

    amount =
        math.clamp(
            math.floor(
                tonumber(amount)
                or 0
            ),
            0,
            tonumber(HOLY_SCANNER_SHOP_STATE.MaxBurstFires)
            or SHOP_MAX_BURST_FIRES
        )

    local fired =
        0

    local yieldEvery =
        math.max(
            1,
            math.floor(
                tonumber(HOLY_SCANNER_SHOP_STATE.YieldEvery)
                or SHOP_YIELD_EVERY
            )
        )

    for index = 1, amount do

        local ok =
            pcall(function()

                packet:Fire(
                    itemName
                )
            end)

        if ok == true then

            fired =
                fired + 1
        end

        if index % yieldEvery == 0 then

            task.wait()
        end
    end

    return fired
end

function HolyScannerShopRunCategory(category)

    if HolyScannerShopCategoryEnabled(category) ~= true then
        return false
    end

    local rows =
        HolyScannerShopGetSelectedRows(category)

    if #rows <= 0 then
        return false
    end

    HOLY_SCANNER_SHOP_STATE.BurstAttempts =
        type(HOLY_SCANNER_SHOP_STATE.BurstAttempts) == "table"
        and HOLY_SCANNER_SHOP_STATE.BurstAttempts
        or {}

    local restockKey =
        HolyScannerShopGetRestockKey(category)

    for _, row in ipairs(rows) do

        if HolyScannerShopCategoryEnabled(category) ~= true then
            return true
        end

        local stock =
            HolyScannerShopGetStockValue(
                category,
                row.Name
            )

        if stock > 0 then

            local attemptKey =
                tostring(category)
                .. "|"
                .. tostring(row.Name)
                .. "|"
                .. tostring(restockKey)
                .. "|"
                .. tostring(stock)

            if HOLY_SCANNER_SHOP_STATE.BurstAttempts[attemptKey] ~= true then

                HOLY_SCANNER_SHOP_STATE.BurstAttempts[attemptKey] =
                    true

                HolyScannerShopFireBurst(
                    category,
                    row.Name,
                    stock
                )
            end
        end
    end

    return true
end

function HolyScannerShopQueueCategory(category)

    HOLY_SCANNER_SHOP_STATE.PendingCategories =
        type(HOLY_SCANNER_SHOP_STATE.PendingCategories) == "table"
        and HOLY_SCANNER_SHOP_STATE.PendingCategories
        or {}

    HOLY_SCANNER_SHOP_STATE.PendingCategories[category] =
        true

    if HOLY_SCANNER_SHOP_STATE.WorkerRunning == true then
        return
    end

    HOLY_SCANNER_SHOP_STATE.WorkerRunning =
        true

    task.spawn(function()

        while HOLY_SCANNER_RUNNING == true do

            local pending =
                HOLY_SCANNER_SHOP_STATE.PendingCategories

            HOLY_SCANNER_SHOP_STATE.PendingCategories =
                {}

            local hasPending =
                false

            for _ in pairs(pending) do

                hasPending =
                    true

                break
            end

            if hasPending ~= true then
                break
            end

            if pending.Seeds == true then

                HolyScannerShopRunCategory(
                    "Seeds"
                )
            end

            if pending.Gear == true then

                HolyScannerShopRunCategory(
                    "Gear"
                )
            end

            task.wait()
        end

        HOLY_SCANNER_SHOP_STATE.WorkerRunning =
            false
    end)
end

function HolyScannerShopQueueAll()

    if HOLY_SCANNER_STATE.AutoBuySeeds == true then

        HolyScannerShopQueueCategory(
            "Seeds"
        )
    end

    if HOLY_SCANNER_STATE.AutoBuyGear == true then

        HolyScannerShopQueueCategory(
            "Gear"
        )
    end
end

function HolyScannerShopConnectStockSignals()

    if HOLY_SCANNER_SHOP_STATE.StockConnected == true then
        return true
    end

    local connectedAny =
        false

    for category, config in pairs(HOLY_SCANNER_SHOP_CATEGORIES) do

        local stockValues =
            ReplicatedStorage:FindFirstChild(
                "StockValues"
            )

        local shop =
            stockValues
            and stockValues:FindFirstChild(
                config.ShopName
            )
            or nil

        local items =
            shop
            and shop:FindFirstChild(
                "Items"
            )
            or nil

        if typeof(items) == "Instance" then

            connectedAny =
                true

            for _, child in ipairs(items:GetChildren()) do

                if child:IsA("ValueBase") then

                    HolyScannerTrackConnection(
                        child.Changed:Connect(function()

                            HolyScannerShopQueueCategory(
                                category
                            )
                        end)
                    )
                end
            end

            HolyScannerTrackConnection(
                items.ChildAdded:Connect(function(child)

                    if child:IsA("ValueBase") then

                        task.defer(function()

                            HolyScannerShopQueueCategory(
                                category
                            )
                        end)
                    end
                end)
            )
        end
    end

    if connectedAny == true then

        HOLY_SCANNER_SHOP_STATE.StockConnected =
            true

        HolyScannerShopQueueAll()

        return true
    end

    return false
end

function HolyScannerStartShopSignalWatcher()

    task.spawn(function()

        local startedAt =
            os.clock()

        while HOLY_SCANNER_RUNNING == true
        and HOLY_SCANNER_SHOP_STATE.StockConnected ~= true do

            HolyScannerShopConnectStockSignals()

            HolyScannerShopQueueAll()

            if HOLY_SCANNER_SHOP_STATE.StockConnected == true then
                break
            end

            task.wait(
                os.clock() - startedAt < 15
                and 0.50
                or 2.00
            )
        end
    end)

    return true
end

function HolyScannerShopRefreshDropdowns()

    HOLY_SCANNER_SHOP_STATE.ItemCache =
        {}

    if HOLY_SCANNER_UI.SeedDropdown then

        pcall(function()

            if type(HOLY_SCANNER_UI.SeedDropdown.SetValues) == "function" then

                HOLY_SCANNER_UI.SeedDropdown:SetValues(
                    HolyScannerShopGetDropdownValues(
                        "Seeds"
                    )
                )

            elseif type(HOLY_SCANNER_UI.SeedDropdown.SetItems) == "function" then

                HOLY_SCANNER_UI.SeedDropdown:SetItems(
                    HolyScannerShopGetDropdownValues(
                        "Seeds"
                    )
                )
            end
        end)
    end

    if HOLY_SCANNER_UI.GearDropdown then

        pcall(function()

            if type(HOLY_SCANNER_UI.GearDropdown.SetValues) == "function" then

                HOLY_SCANNER_UI.GearDropdown:SetValues(
                    HolyScannerShopGetDropdownValues(
                        "Gear"
                    )
                )

            elseif type(HOLY_SCANNER_UI.GearDropdown.SetItems) == "function" then

                HOLY_SCANNER_UI.GearDropdown:SetItems(
                    HolyScannerShopGetDropdownValues(
                        "Gear"
                    )
                )
            end
        end)
    end

    return true
end

--==================================================
-- [10] PET SCAN DATA
--==================================================

function HolyScannerDataFindSharedModule(moduleName)

    local sharedData =
        ReplicatedStorage:FindFirstChild(
            "SharedData"
        )

    if typeof(sharedData) ~= "Instance" then
        return nil
    end

    local module =
        sharedData:FindFirstChild(
            moduleName
        )

    if typeof(module) == "Instance"
    and module:IsA("ModuleScript") then

        return module
    end

    return nil
end

function HolyScannerDataGetModule(moduleName)

    HOLY_SCANNER_DATA_STATE.Modules =
        type(HOLY_SCANNER_DATA_STATE.Modules) == "table"
        and HOLY_SCANNER_DATA_STATE.Modules
        or {}

    if type(HOLY_SCANNER_DATA_STATE.Modules[moduleName]) == "table" then

        return HOLY_SCANNER_DATA_STATE.Modules[moduleName]
    end

    local module =
        HolyScannerDataFindSharedModule(
            moduleName
        )

    if typeof(module) ~= "Instance" then
        return nil
    end

    local ok,
        result =
        pcall(function()

            return require(
                module
            )
        end)

    if ok ~= true
    or type(result) ~= "table" then

        return nil
    end

    HOLY_SCANNER_DATA_STATE.Modules[moduleName] =
        result

    return result
end

function HolyScannerGetPetData()

    local data =
        HolyScannerDataGetModule(
            "PetData"
        )

    return type(data) == "table"
        and data
        or {}
end

function HolyScannerGetPetSizes()

    local data =
        HolyScannerDataGetModule(
            "PetSizes"
        )

    return type(data) == "table"
        and data
        or {}
end

function HolyScannerGetPetTypes()

    local data =
        HolyScannerDataGetModule(
            "PetTypes"
        )

    return type(data) == "table"
        and data
        or {}
end

function HolyScannerIsPetDataRow(key, row)

    if type(key) ~= "string" then
        return false
    end

    if type(row) ~= "table" then
        return false
    end

    return type(row.DisplayName) == "string"
        or type(row.BasePrice) == "number"
        or type(row.Rarity) == "string"
        or type(row.SpawnChance) == "number"
end

function HolyScannerPetAliasKey(value)

    return HolyScannerCleanText(
        value
    )
        :lower()
        :gsub("[%s_%-%[%]%(%)%.]", "")
end

function HolyScannerBuildPetMaps()

    local values =
        {}

    local seen =
        {}

    local displayToKey =
        {}

    local keyToDisplay =
        {}

    local petData =
        HolyScannerGetPetData()

    for key, row in pairs(petData) do

        if HolyScannerIsPetDataRow(
            key,
            row
        ) == true then

            local internalKey =
                HolyScannerCleanText(
                    key
                )

            local displayName =
                HolyScannerCleanText(
                    row.DisplayName
                    or row.PetName
                    or row.Name
                    or key
                )

            if internalKey ~= ""
            and displayName ~= "" then

                if seen[displayName] ~= true then

                    seen[displayName] =
                        true

                    table.insert(
                        values,
                        displayName
                    )
                end

                displayToKey[displayName] =
                    internalKey

                keyToDisplay[internalKey] =
                    displayName
            end
        end
    end

    table.sort(values, function(a, b)

        return tostring(a) < tostring(b)
    end)

    HOLY_SCANNER_DATA_STATE.PetDisplayToKey =
        displayToKey

    HOLY_SCANNER_DATA_STATE.PetKeyToDisplay =
        keyToDisplay

    return values,
        displayToKey,
        keyToDisplay
end

function HolyScannerResolvePetDisplay(value)

    local text =
        HolyScannerCleanText(
            value
        )

    if text == "" then
        return ""
    end

    HolyScannerBuildPetMaps()

    local displayToKey =
        HOLY_SCANNER_DATA_STATE.PetDisplayToKey
        or {}

    local keyToDisplay =
        HOLY_SCANNER_DATA_STATE.PetKeyToDisplay
        or {}

    if displayToKey[text] then
        return text
    end

    if keyToDisplay[text] then
        return keyToDisplay[text]
    end

    local wantedAlias =
        HolyScannerPetAliasKey(
            text
        )

    for internalKey, displayName in pairs(keyToDisplay) do

        if HolyScannerPetAliasKey(internalKey) == wantedAlias
        or HolyScannerPetAliasKey(displayName) == wantedAlias then

            return displayName
        end
    end

    return text
end

function HolyScannerResolvePetKey(value)

    local text =
        HolyScannerCleanText(
            value
        )

    if text == "" then
        return ""
    end

    HolyScannerBuildPetMaps()

    local displayToKey =
        HOLY_SCANNER_DATA_STATE.PetDisplayToKey
        or {}

    local keyToDisplay =
        HOLY_SCANNER_DATA_STATE.PetKeyToDisplay
        or {}

    if displayToKey[text] then
        return displayToKey[text]
    end

    if keyToDisplay[text] then
        return text
    end

    local wantedAlias =
        HolyScannerPetAliasKey(
            text
        )

    for internalKey, displayName in pairs(keyToDisplay) do

        if HolyScannerPetAliasKey(internalKey) == wantedAlias
        or HolyScannerPetAliasKey(displayName) == wantedAlias then

            return internalKey
        end
    end

    return text
end

function HolyScannerNormalizeSizeName(value)

    local text =
        HolyScannerCleanText(
            value
        )

    local lower =
        text:lower()

    if lower == ""
    or lower == "none"
    or lower == "nil"
    or lower == "normal"
    or lower == "regular" then

        return "Normal"
    end

    if lower == "mega"
    or lower == "huge" then

        return "Huge"
    end

    local petSizes =
        HolyScannerGetPetSizes()

    if type(petSizes.Normalize) == "function" then

        local ok,
            result =
            pcall(function()

                return petSizes.Normalize(
                    text
                )
            end)

        result =
            HolyScannerCleanText(
                ok == true
                and result
                or ""
            )

        if result ~= "" then

            if result == "Mega" then
                return "Huge"
            end

            return result
        end
    end

    return text
end

function HolyScannerPetTypeIsValid(typeName)

    typeName =
        HolyScannerCleanText(
            typeName
        )

    if typeName == "" then
        return false
    end

    if typeName == "Normal" then
        return true
    end

    local petTypes =
        HolyScannerGetPetTypes()

    if type(petTypes.IsValid) == "function" then

        local ok,
            result =
            pcall(function()

                return petTypes.IsValid(
                    typeName
                )
            end)

        if ok == true then
            return result == true
        end
    end

    return false
end

function HolyScannerNormalizeVariantName(value)

    local text =
        HolyScannerCleanText(
            value
        )

    local lower =
        text:lower()

    if lower == ""
    or lower == "none"
    or lower == "nil"
    or lower == "normal"
    or lower == "regular" then

        return "Normal"
    end

    return text
end

function HolyScannerGetBasePrice(petName)

    local petKey =
        HolyScannerResolvePetKey(
            petName
        )

    if petKey == "" then
        return 0
    end

    local petData =
        HolyScannerGetPetData()

    local row =
        petData[petKey]

    if type(row) ~= "table" then
        return 0
    end

    return tonumber(row.BasePrice)
        or tonumber(row.Price)
        or 0
end

function HolyScannerGetWildPetRoot()

    local map =
        workspace:FindFirstChild(
            "Map"
        )

    local root =
        map
        and map:FindFirstChild(
            "WildPetSpawns"
        )
        or nil

    if typeof(root) == "Instance" then
        return root
    end

    root =
        workspace:FindFirstChild(
            "WildPetSpawns",
            true
        )

    if typeof(root) == "Instance" then
        return root
    end

    return nil
end

function HolyScannerGetWildPetRefRoot()

    local map =
        workspace:FindFirstChild(
            "Map"
        )

    local root =
        map
        and map:FindFirstChild(
            "WildPetRef"
        )
        or nil

    if typeof(root) == "Instance" then
        return root
    end

    root =
        workspace:FindFirstChild(
            "WildPetRef",
            true
        )

    if typeof(root) == "Instance" then
        return root
    end

    return nil
end

function HolyScannerReadAttr(instance, names)

    if typeof(instance) ~= "Instance" then
        return ""
    end

    for _, name in ipairs(names or {}) do

        local ok,
            value =
            pcall(function()

                return instance:GetAttribute(
                    name
                )
            end)

        value =
            HolyScannerCleanText(
                ok == true
                and value
                or ""
            )

        if value ~= "" then
            return value
        end
    end

    return ""
end

function HolyScannerReadNumber(instance, names)

    local value =
        HolyScannerReadAttr(
            instance,
            names
        )

    return tonumber(value)
        or 0
end

function HolyScannerUuidFromRef(ref)

    if typeof(ref) ~= "Instance" then
        return ""
    end

    return tostring(ref.Name):match(
        "^WildPet_([%w%-]+)$"
    )
    or ""
end

function HolyScannerFindModelForRef(ref)

    local uuid =
        HolyScannerUuidFromRef(
            ref
        )

    if uuid == "" then
        return nil
    end

    local root =
        HolyScannerGetWildPetRoot()

    if typeof(root) ~= "Instance" then
        return nil
    end

    for _, child in ipairs(root:GetChildren()) do

        if child:IsA("Model")
        and tostring(child.Name):find(
            uuid,
            1,
            true
        ) then

            return child
        end
    end

    return nil
end

function HolyScannerGetModelPosition(model)

    if typeof(model) ~= "Instance" then
        return nil
    end

    local rootPart =
        model:FindFirstChild(
            "RootPart"
        )
        or model:FindFirstChild(
            "RigPart"
        )
        or model.PrimaryPart

    if typeof(rootPart) == "Instance"
    and rootPart:IsA("BasePart") then

        return rootPart.Position
    end

    local ok,
        pivot =
        pcall(function()

            return model:GetPivot()
        end)

    if ok == true
    and typeof(pivot) == "CFrame" then

        return pivot.Position
    end

    return nil
end

function HolyScannerGetCharacterRoot()

    local character =
        LocalPlayer
        and LocalPlayer.Character
        or nil

    if typeof(character) ~= "Instance" then
        return nil
    end

    return character:FindFirstChild(
        "HumanoidRootPart"
    )
    or character:FindFirstChild(
        "RootPart"
    )
    or character.PrimaryPart
end

function HolyScannerReadDistance(position)

    local root =
        HolyScannerGetCharacterRoot()

    if typeof(position) ~= "Vector3"
    or typeof(root) ~= "Instance"
    or root:IsA("BasePart") ~= true then

        return nil
    end

    return (
        root.Position
        - position
    ).Magnitude
end

function HolyScannerReadLiveSize(ref, model)

    local raw =
        HolyScannerReadAttr(
            ref,
            {
                "PetSize",
                "Size",
                "DisplaySize",
                "ScaleType",
                "WildPetSize",
            }
        )

    if raw ~= "" then
        return HolyScannerNormalizeSizeName(
            raw
        )
    end

    raw =
        HolyScannerReadAttr(
            model,
            {
                "PetSize",
                "Size",
                "DisplaySize",
                "ScaleType",
                "WildPetSize",
            }
        )

    if raw ~= "" then
        return HolyScannerNormalizeSizeName(
            raw
        )
    end

    if typeof(model) == "Instance" then

        local scale =
            1

        pcall(function()

            scale =
                model:GetScale()
        end)

        scale =
            tonumber(scale)
            or 1

        if scale >= 3.25 then
            return "Huge"
        end

        if scale >= 1.50 then
            return "Big"
        end
    end

    return "Normal"
end

function HolyScannerReadLiveVariant(ref, model)

    local raw =
        HolyScannerReadAttr(
            ref,
            {
                "PetType",
                "Type",
                "Variant",
                "PetVariant",
                "Mutation",
                "WildPetType",
            }
        )

    if raw == "" then

        raw =
            HolyScannerReadAttr(
                model,
                {
                    "PetType",
                    "Type",
                    "Variant",
                    "PetVariant",
                    "Mutation",
                    "WildPetType",
                }
            )
    end

    if raw ~= "" then

        raw =
            HolyScannerNormalizeVariantName(
                raw
            )

        if raw ~= "Normal"
        and HolyScannerPetTypeIsValid(raw) == true then

            return raw
        end

        return "Normal"
    end

    local modelName =
        tostring(
            model
            and model.Name
            or ""
        ):lower()

    if modelName:find("rainbow", 1, true) then
        return "Rainbow"
    end

    return "Normal"
end

function HolyScannerRarityRank(rarity)

    rarity =
        HolyScannerCleanText(
            rarity
        )

    local ranks = {
        Super = 7,
        Mythic = 6,
        Legendary = 5,
        Epic = 4,
        Rare = 3,
        Uncommon = 2,
        Common = 1,
    }

    return ranks[rarity]
        or 0
end

function HolyScannerScanLivePetRows()

    local rows =
        {}

    local refRoot =
        HolyScannerGetWildPetRefRoot()

    if typeof(refRoot) ~= "Instance" then
        return rows
    end

    for _, ref in ipairs(refRoot:GetChildren()) do

        local petName =
            HolyScannerReadAttr(
                ref,
                {
                    "PetName",
                    "Pet",
                    "DisplayName",
                    "Name",
                }
            )

        if petName ~= "" then

            petName =
                HolyScannerResolvePetDisplay(
                    petName
                )

            local petKey =
                HolyScannerResolvePetKey(
                    petName
                )

            local uuid =
                HolyScannerUuidFromRef(
                    ref
                )

            if uuid == "" then
                uuid =
                    tostring(ref.Name)
            end

            local spawnedAt =
                HolyScannerReadNumber(
                    ref,
                    {
                        "SpawnedAt",
                        "SpawnTime",
                        "CreatedAt",
                    }
                )

            local lifetime =
                HolyScannerReadNumber(
                    ref,
                    {
                        "Lifetime",
                        "LifeTime",
                        "Duration",
                    }
                )

            local timeLeft =
                lifetime > 0
                and spawnedAt > 0
                and (
                    spawnedAt
                    + lifetime
                    - os.time()
                )
                or 0

            if lifetime <= 0
            or timeLeft > -4 then

                local ownerUserId =
                    HolyScannerReadNumber(
                        ref,
                        {
                            "OwnerUserId",
                            "OwnerUserID",
                            "Owner",
                            "UserId",
                            "UserID",
                        }
                    )

                local ownerName =
                    HolyScannerReadAttr(
                        ref,
                        {
                            "OwnerName",
                            "OwnerDisplayName",
                        }
                    )

                local rawState =
                    HolyScannerReadAttr(
                        ref,
                        {
                            "State",
                            "PetState",
                        }
                    )

                local lowerState =
                    rawState:lower()

                local owned =
                    ownerUserId ~= 0
                    or ownerName ~= ""

                local gone =
                    lowerState:find("owned", 1, true)
                    or lowerState:find("collected", 1, true)
                    or lowerState:find("tamed", 1, true)

                if owned ~= true
                and gone == nil then

                    local model =
                        HolyScannerFindModelForRef(
                            ref
                        )

                    local size =
                        HolyScannerReadLiveSize(
                            ref,
                            model
                        )

                    local variant =
                        HolyScannerReadLiveVariant(
                            ref,
                            model
                        )

                    local rarity =
                        HolyScannerReadAttr(
                            ref,
                            {
                                "Rarity",
                                "PetRarity",
                            }
                        )

                    local price =
                        HolyScannerReadNumber(
                            ref,
                            {
                                "Price",
                                "Cost",
                                "TameCost",
                            }
                        )

                    if price <= 0 then

                        price =
                            HolyScannerGetBasePrice(
                                petName
                            )
                    end

                    local position =
                        nil

                    if typeof(ref) == "Instance"
                    and ref:IsA("BasePart") then

                        position =
                            ref.Position

                    else

                        position =
                            HolyScannerGetModelPosition(
                                model
                            )
                    end

                    local distance =
                        HolyScannerReadDistance(
                            position
                        )

                    local displayName =
                        petName

                    if size ~= ""
                    and size ~= "Normal" then

                        displayName =
                            size
                            .. " "
                            .. displayName
                    end

                    if variant ~= ""
                    and variant ~= "Normal" then

                        displayName =
                            variant
                            .. " "
                            .. displayName
                    end

                    table.insert(
                        rows,
                        {
                            Key =
                                uuid,

                            UUID =
                                uuid,

                            Pet =
                                petName,

                            PetKey =
                                petKey,

                            DisplayName =
                                displayName,

                            Size =
                                size,

                            Variant =
                                variant,

                            Mutation =
                                variant,

                            Rarity =
                                rarity,

                            RarityRank =
                                HolyScannerRarityRank(
                                    rarity
                                ),

                            PriceNumber =
                                tonumber(price)
                                or 0,

                            SpawnedAt =
                                tonumber(spawnedAt)
                                or 0,

                            Lifetime =
                                tonumber(lifetime)
                                or 0,

                            TimeLeftNumber =
                                tonumber(timeLeft)
                                or 0,

                            DistanceNumber =
                                tonumber(distance)
                                or 999999,

                            RawState =
                                rawState,
                        }
                    )
                end
            end
        end
    end

    table.sort(rows, function(a, b)

        if a.RarityRank ~= b.RarityRank then
            return a.RarityRank > b.RarityRank
        end

        if a.PriceNumber ~= b.PriceNumber then
            return a.PriceNumber > b.PriceNumber
        end

        if a.TimeLeftNumber ~= b.TimeLeftNumber then
            return a.TimeLeftNumber < b.TimeLeftNumber
        end

        return a.DistanceNumber < b.DistanceNumber
    end)

    return rows
end

--==================================================
-- [11] REPORTING
--==================================================

function HolyScannerRareAlias(value)

    return HolyScannerCleanText(
        value
    )
        :lower()
        :gsub("[%s_%-%[%]%(%)%.]", "")
end

function HolyScannerRareNormalizeSize(value)

    local text =
        HolyScannerNormalizeSizeName(
            value
        )

    if text == "" then
        return "Normal"
    end

    if text == "Mega" then
        return "Huge"
    end

    return text
end

function HolyScannerRareNormalizeVariant(value)

    local text =
        HolyScannerNormalizeVariantName(
            value
        )

    if text == "Regular" then
        return "Normal"
    end

    if text == "" then
        return "Normal"
    end

    return text
end

function HolyScannerRareIsSpecificPet(row)

    row =
        type(row) == "table"
        and row
        or {}

    local key =
        HolyScannerRareAlias(
            row.Pet
            or row.PetName
            or row.DisplayName
        )

    return key == "raccoon"
        or key == "unicorn"
        or key == "goldendragonfly"
        or key == "dragonfly"
end

function HolyScannerRareIsVariantPet(row)

    row =
        type(row) == "table"
        and row
        or {}

    local size =
        HolyScannerRareNormalizeSize(
            row.Size
        )

    local variant =
        HolyScannerRareNormalizeVariant(
            row.Variant
            or row.Mutation
        )

    if size == "Big"
    or size == "Huge" then

        return true
    end

    if variant ~= ""
    and variant ~= "Normal"
    and variant ~= "Regular"
    and variant ~= "Any" then

        return true
    end

    return false
end

function HolyScannerRareShouldReportRow(row)

    if type(row) ~= "table" then
        return false
    end

    local lifetime =
        tonumber(
            row.Lifetime
        )
        or 0

    local timeLeft =
        tonumber(
            row.TimeLeftNumber
            or row.TimeLeft
        )
        or 0

    if lifetime > 0
    and timeLeft <= 0 then

        return false
    end

    return HolyScannerRareIsSpecificPet(row) == true
        or HolyScannerRareIsVariantPet(row) == true
end

function HolyScannerRareRowExpiresAt(row)

    row =
        type(row) == "table"
        and row
        or {}

    local expiresAt =
        tonumber(row.ExpiresAt)
        or 0

    if expiresAt > 0 then
        return expiresAt
    end

    local spawnedAt =
        tonumber(row.SpawnedAt)
        or 0

    local lifetime =
        tonumber(row.Lifetime)
        or 0

    if spawnedAt > 0
    and lifetime > 0 then

        return spawnedAt + lifetime
    end

    return os.time() + 300
end

function HolyScannerRareRowKey(row)

    row =
        type(row) == "table"
        and row
        or {}

    return table.concat({
        tostring(game.JobId),
        HolyScannerCleanText(row.UUID or row.Key),
        HolyScannerCleanText(row.Pet),
        HolyScannerRareNormalizeSize(row.Size),
        HolyScannerRareNormalizeVariant(row.Variant or row.Mutation),
    }, "|")
end

function HolyScannerRareBuildPetPayload(row)

    row =
        type(row) == "table"
        and row
        or {}

    local expiresAt =
        HolyScannerRareRowExpiresAt(
            row
        )

    local timeLeft =
        math.max(
            0,
            expiresAt - os.time()
        )

    if tonumber(row.TimeLeftNumber)
    and tonumber(row.TimeLeftNumber) > 0 then

        timeLeft =
            tonumber(row.TimeLeftNumber)
    end

    return {
        Key =
            HolyScannerCleanText(
                row.Key
                or row.UUID
            ),

        UUID =
            HolyScannerCleanText(
                row.UUID
                or row.Key
            ),

        Pet =
            HolyScannerCleanText(
                row.Pet
            ),

        PetName =
            HolyScannerCleanText(
                row.Pet
            ),

        DisplayName =
            HolyScannerCleanText(
                row.DisplayName
                or row.Pet
            ),

        Rarity =
            HolyScannerCleanText(
                row.Rarity
            ),

        Size =
            HolyScannerRareNormalizeSize(
                row.Size
            ),

        Variant =
            HolyScannerRareNormalizeVariant(
                row.Variant
                or row.Mutation
            ),

        Mutation =
            HolyScannerRareNormalizeVariant(
                row.Variant
                or row.Mutation
            ),

        SpawnedAt =
            tonumber(row.SpawnedAt)
            or 0,

        Lifetime =
            tonumber(row.Lifetime)
            or 0,

        ExpiresAt =
            expiresAt,

        TimeLeft =
            timeLeft,

        Price =
            tonumber(
                row.PriceNumber
                or row.Price
            )
            or 0,
    }
end

function HolyScannerRarePruneSent()

    HOLY_SCANNER_REPORT_STATE.Sent =
        type(HOLY_SCANNER_REPORT_STATE.Sent) == "table"
        and HOLY_SCANNER_REPORT_STATE.Sent
        or {}

    local now =
        os.time()

    for key, expiresAt in pairs(HOLY_SCANNER_REPORT_STATE.Sent) do

        if tonumber(expiresAt) == nil
        or tonumber(expiresAt) <= now then

            HOLY_SCANNER_REPORT_STATE.Sent[key] =
                nil
        end
    end
end

function HolyScannerBuildRarePayload(rows)

    HolyScannerRarePruneSent()

    rows =
        type(rows) == "table"
        and rows
        or HolyScannerScanLivePetRows()

    local pets =
        {}

    local sentKeys =
        {}

    for _, row in ipairs(rows) do

        if HolyScannerRareShouldReportRow(row) == true then

            local rowKey =
                HolyScannerRareRowKey(
                    row
                )

            if HOLY_SCANNER_REPORT_STATE.Sent[rowKey] == nil then

                table.insert(
                    pets,
                    HolyScannerRareBuildPetPayload(
                        row
                    )
                )

                table.insert(
                    sentKeys,
                    {
                        Key =
                            rowKey,

                        ExpiresAt =
                            HolyScannerRareRowExpiresAt(
                                row
                            ),
                    }
                )
            end
        end
    end

    if #pets <= 0 then
        return nil,
            sentKeys
    end

    local playing,
        maxPlayers =
        HolyScannerGetPlayerCounts()

    return {
        Key =
            tostring(
                SERVER_FINDER_API_KEY
                or ""
            ),

        PlaceId =
            game.PlaceId,

        JobId =
            tostring(
                game.JobId
            ),

        Playing =
            playing,

        MaxPlayers =
            maxPlayers,

        ServerVersion =
            HolyScannerReadServerVersion(),

        Reporter =
            tostring(
                LocalPlayer
                and LocalPlayer.Name
                or "unknown"
            ),

        Pets =
            pets,
    },
        sentKeys
end

function HolyScannerSendRarePayload(payload, sentKeys)

    if type(payload) ~= "table" then
        return false,
            "empty"
    end

    local data,
        reason =
        HolyScannerRequestJson(
            "POST",
            HolyScannerBackendUrl(
                "/rare-alert"
            ),
            payload
        )

    if type(data) == "table"
    and data.ok == true then

        HOLY_SCANNER_REPORT_STATE.LastRareReportAt =
            os.time()

        HOLY_SCANNER_REPORT_STATE.LastRareAt =
            os.clock()

        for _, row in ipairs(sentKeys or {}) do

            local key =
                HolyScannerCleanText(
                    row.Key
                )

            if key ~= "" then

                HOLY_SCANNER_REPORT_STATE.Sent[key] =
                    tonumber(row.ExpiresAt)
                    or (
                        os.time() + 300
                    )
            end
        end

        return true,
            "ok"
    end

    return false,
        tostring(reason or "request failed")
end

function HolyScannerBuildScannerExpiresAt(row)

    row =
        type(row) == "table"
        and row
        or {}

    local now =
        os.time()

    local expiresAt =
        tonumber(row.ExpiresAt)
        or 0

    if expiresAt > now then

        return math.floor(
            expiresAt
        )
    end

    local spawnedAt =
        tonumber(row.SpawnedAt)
        or 0

    local lifetime =
        tonumber(row.Lifetime)
        or 0

    if spawnedAt > 0
    and lifetime > 0 then

        expiresAt =
            spawnedAt + lifetime

        if expiresAt > now then

            return math.floor(
                expiresAt
            )
        end
    end

    local timeLeft =
        tonumber(
            row.TimeLeftNumber
            or row.TimeLeft
        )
        or 0

    if timeLeft > 0 then

        return now
            + math.floor(
                timeLeft
            )
    end

    -- Fallback for active pets where the game does not expose spawned/lifetime.
    -- The scanner refreshes every few seconds, so this stays accurate enough.
    return now + 300
end

function HolyScannerBuildScannerPetPayload(row)

    row =
        type(row) == "table"
        and row
        or {}

    local expiresAt =
        HolyScannerBuildScannerExpiresAt(
            row
        )

    local timeLeft =
        math.max(
            0,
            expiresAt - os.time()
        )

    return {
        Key =
            HolyScannerCleanText(
                row.Key
                or row.UUID
            ),

        UUID =
            HolyScannerCleanText(
                row.UUID
                or row.Key
            ),

        Pet =
            HolyScannerCleanText(
                row.Pet
            ),

        DisplayName =
            HolyScannerCleanText(
                row.DisplayName
                or row.Pet
            ),

        Rarity =
            HolyScannerCleanText(
                row.Rarity
            ),

        Size =
            HolyScannerRareNormalizeSize(
                row.Size
            ),

        Variant =
            HolyScannerRareNormalizeVariant(
                row.Variant
                or row.Mutation
            ),

        Mutation =
            HolyScannerRareNormalizeVariant(
                row.Variant
                or row.Mutation
            ),

        SpawnedAt =
            tonumber(row.SpawnedAt)
            or 0,

        Lifetime =
            tonumber(row.Lifetime)
            or 0,

        ExpiresAt =
            expiresAt,

        TimeLeft =
            timeLeft,

        Price =
            tonumber(row.PriceNumber)
            or 0,
    }
end

function HolyScannerBuildScannerPayload(rows)

    rows =
        type(rows) == "table"
        and rows
        or HolyScannerScanLivePetRows()

    local pets =
        {}

    for _, row in ipairs(rows) do

        table.insert(
            pets,
            HolyScannerBuildScannerPetPayload(
                row
            )
        )
    end

    local playing,
        maxPlayers =
        HolyScannerGetPlayerCounts()

    return {
        Key =
            tostring(
                SERVER_FINDER_API_KEY
                or ""
            ),

        Type =
            "scanner_report",

        ScannerId =
            tostring(
                LocalPlayer
                and LocalPlayer.Name
                or "unknown"
            )
            .. "-"
            .. tostring(
                LocalPlayer
                and LocalPlayer.UserId
                or 0
            ),

        PlaceId =
            game.PlaceId,

        JobId =
            tostring(
                game.JobId
            ),

        Playing =
            playing,

        MaxPlayers =
            maxPlayers,

        ServerVersion =
            HolyScannerReadServerVersion(),

        Reporter =
            tostring(
                LocalPlayer
                and LocalPlayer.Name
                or "unknown"
            ),

        ReportedAt =
            os.time(),

        Pets =
            pets,
    }
end

function HolyScannerSendScannerPayload(payload)

    if type(payload) ~= "table" then
        return false,
            "empty"
    end

    if os.clock() < (
        tonumber(HOLY_SCANNER_REPORT_STATE.ScannerBackoffUntil)
        or 0
    ) then

        return false,
            "backoff"
    end

    local data,
        reason =
        HolyScannerRequestJson(
            "POST",
            HolyScannerBackendUrl(
                "/scanner-report"
            ),
            payload
        )

    if type(data) == "table"
    and data.ok == true then

        HOLY_SCANNER_REPORT_STATE.LastScannerReportAt =
            os.time()

        return true,
            "ok"
    end

    HOLY_SCANNER_REPORT_STATE.ScannerBackoffUntil =
        os.clock() + 30

    HOLY_SCANNER_REPORT_STATE.LastError =
        tostring(reason or "scanner report failed")

    return false,
        tostring(reason or "request failed")
end

function HolyScannerGetScannerId()

    return tostring(
        LocalPlayer
        and LocalPlayer.Name
        or "unknown"
    )
        .. "-"
        .. tostring(
            LocalPlayer
            and LocalPlayer.UserId
            or 0
        )
end

function HolyScannerGetAccountLabel()

    local label =
        HolyScannerCleanText(
            SCANNER_ACCOUNT_LABEL
        )

    if label ~= "" then
        return label
    end

    return tostring(
        LocalPlayer
        and LocalPlayer.Name
        or "unknown"
    )
end

function HolyScannerGetVpsLabel()

    return HolyScannerCleanText(
        SCANNER_VPS_LABEL
    )
end

function HolyScannerBuildClientHeartbeatPayload(rows)

    rows =
        type(rows) == "table"
        and rows
        or {}

    local targetRows =
        {}

    for _, row in ipairs(rows) do

        local ok,
            isTarget =
            pcall(function()

                return HolyScannerHuntIsTargetRow(
                    row
                )
            end)

        if ok == true
        and isTarget == true then

            table.insert(
                targetRows,
                row
            )
        end
    end

    local targetSummary =
        ""

    if #targetRows > 0 then

        local ok,
            summary =
            pcall(function()

                return HolyScannerHuntBuildSummary(
                    targetRows
                )
            end)

        if ok == true then

            targetSummary =
                HolyScannerCleanText(
                    summary
                )
        end
    end

    local bestPet =
        ""

    if type(rows[1]) == "table" then

        bestPet =
            HolyScannerCleanText(
                rows[1].DisplayName
                or rows[1].Pet
                or ""
            )
    end

    local playing,
        maxPlayers =
        HolyScannerGetPlayerCounts()

    return {
        Key =
            tostring(
                SERVER_FINDER_API_KEY
                or ""
            ),

        Type =
            "client_heartbeat",

        ScannerId =
            HolyScannerGetScannerId(),

        Reporter =
            tostring(
                LocalPlayer
                and LocalPlayer.Name
                or "unknown"
            ),

        UserId =
            tonumber(
                LocalPlayer
                and LocalPlayer.UserId
            )
            or 0,

        AccountLabel =
            HolyScannerGetAccountLabel(),

        VpsLabel =
            HolyScannerGetVpsLabel(),

        PlaceId =
            game.PlaceId,

        JobId =
            tostring(
                game.JobId
            ),

        Playing =
            playing,

        MaxPlayers =
            maxPlayers,

        ServerVersion =
            HolyScannerReadServerVersion(),

        HuntMode =
            HOLY_SCANNER_STATE.HuntMode == true,

        Hopping =
            HOLY_SCANNER_SERVER_STATE.Hopping == true,

        Status =
            tostring(
                HOLY_SCANNER_SERVER_STATE.LastStatus
                or ""
            ),

        TargetCount =
            #targetRows,

        TargetSummary =
            targetSummary,

        PetCount =
            #rows,

        BestPet =
            bestPet,

        LastError =
            tostring(
                HOLY_SCANNER_REPORT_STATE.LastError
                or ""
            ),

        StartedAt =
            tonumber(
                HOLY_SCANNER_REPORT_STATE.StartedAt
            )
            or os.time(),

        ReportedAt =
            os.time(),
    }
end

function HolyScannerSendClientHeartbeat(payload)

    if type(payload) ~= "table" then
        return false,
            "empty"
    end

    if os.clock() < (
        tonumber(HOLY_SCANNER_REPORT_STATE.ClientHeartbeatBackoffUntil)
        or 0
    ) then

        return false,
            "backoff"
    end

    local data,
        reason =
        HolyScannerRequestJson(
            "POST",
            HolyScannerBackendUrl(
                "/client-heartbeat"
            ),
            payload
        )

    if type(data) == "table"
    and data.ok == true then

        HOLY_SCANNER_REPORT_STATE.LastClientHeartbeatAt =
            os.time()

        HOLY_SCANNER_REPORT_STATE.LastError =
            ""

        return true,
            "ok"
    end

    HOLY_SCANNER_REPORT_STATE.ClientHeartbeatBackoffUntil =
        os.clock() + CLIENT_HEARTBEAT_BACKOFF

    HOLY_SCANNER_REPORT_STATE.LastError =
        tostring(reason or "client heartbeat failed")

    return false,
        tostring(reason or "request failed")
end

function HolyScannerFleetEnabled()

    return FLEET_HOP_ENABLED == true
        and HolyScannerCleanText(
            SERVER_FINDER_API_KEY
        ) ~= ""
end

function HolyScannerFleetBackoffLeft()

    local untilTime =
        tonumber(
            HOLY_SCANNER_SERVER_STATE.FleetBackoffUntil
        )
        or 0

    return math.max(
        0,
        untilTime - os.clock()
    )
end

function HolyScannerFleetSetBackoff(reason, seconds)

    reason =
        HolyScannerCleanText(
            reason
        )

    seconds =
        tonumber(seconds)
        or FLEET_REQUEST_BACKOFF

    seconds =
        math.clamp(
            seconds,
            2,
            45
        )

    HOLY_SCANNER_SERVER_STATE.FleetBackoffUntil =
        os.clock() + seconds

    HOLY_SCANNER_SERVER_STATE.LastFleetError =
        reason

    return seconds
end

function HolyScannerFleetBuildBasePayload(reason)

    return {
        Key =
            tostring(
                SERVER_FINDER_API_KEY
                or ""
            ),

        Type =
            "fleet",

        ScannerId =
            HolyScannerGetScannerId(),

        Reporter =
            tostring(
                LocalPlayer
                and LocalPlayer.Name
                or "unknown"
            ),

        UserId =
            tonumber(
                LocalPlayer
                and LocalPlayer.UserId
            )
            or 0,

        AccountLabel =
            HolyScannerGetAccountLabel(),

        VpsLabel =
            HolyScannerGetVpsLabel(),

        PlaceId =
            game.PlaceId,

        JobId =
            tostring(
                game.JobId
            ),

        CurrentJobId =
            tostring(
                game.JobId
            ),

        MaxPlayers =
            FLEET_TARGET_MAX_PLAYERS,

        Pages =
            FLEET_SEARCH_PAGES,

        Reason =
            tostring(reason or "hop"),

        ReportedAt =
            os.time(),
    }
end

function HolyScannerFleetNextServer(reason)

    if HolyScannerFleetEnabled() ~= true then

        return nil,
            "fleet disabled"
    end

    local backoff =
        HolyScannerFleetBackoffLeft()

    if backoff > 0 then

        return nil,
            "fleet backoff "
            .. tostring(
                math.ceil(backoff)
            )
            .. "s"
    end

    HOLY_SCANNER_SERVER_STATE.LastFleetAt =
        os.clock()

    local payload =
        HolyScannerFleetBuildBasePayload(
            reason
        )

    local data,
        requestError =
        HolyScannerRequestJson(
            "POST",
            HolyScannerBackendUrl(
                "/fleet/next-server"
            ),
            payload
        )

    if type(data) == "table"
    and data.ok == true
    and (
        data.assigned == true
        or data.Assigned == true
    ) then

        local jobId =
            HolyScannerCleanText(
                data.JobId
                or data.jobId
                or data.Id
                or data.id
            )

        if jobId ~= "" then

            local playing =
                tonumber(
                    data.Playing
                    or data.playing
                )
                or 0

            local maxPlayers =
                tonumber(
                    data.MaxPlayers
                    or data.maxPlayers
                )
                or 8

            local freeSlots =
                tonumber(
                    data.FreeSlots
                    or data.freeSlots
                )
                or math.max(
                    0,
                    maxPlayers - playing
                )

            HOLY_SCANNER_SERVER_STATE.FleetBackoffUntil =
                0

            HOLY_SCANNER_SERVER_STATE.LastFleetError =
                ""

            HOLY_SCANNER_SERVER_STATE.FleetLastAssignedJobId =
                jobId

            HOLY_SCANNER_SERVER_STATE.FleetLastAssignedText =
                tostring(playing)
                .. "/"
                .. tostring(maxPlayers)
                .. " · free "
                .. tostring(freeSlots)
                .. " · "
                .. jobId:sub(1, 8)

            return {
                id =
                    jobId,

                playing =
                    playing,

                maxPlayers =
                    maxPlayers,

                FreeSlots =
                    freeSlots,

                Source =
                    "fleet",
            },
                "fleet"
        end
    end

    local reasonText =
        "fleet no server"

    if type(data) == "table" then

        reasonText =
            tostring(
                data.error
                or data.reason
                or data.message
                or reasonText
            )

    elseif requestError then

        reasonText =
            tostring(
                requestError
            )
    end

    HolyScannerFleetSetBackoff(
        reasonText,
        FLEET_REQUEST_BACKOFF
    )

    return nil,
        reasonText
end

function HolyScannerFleetJoinResult(jobId, success, reason)

    if HolyScannerFleetEnabled() ~= true then
        return false,
            "fleet disabled"
    end

    jobId =
        HolyScannerCleanText(
            jobId
        )

    if jobId == "" then
        return false,
            "missing job"
    end

    local payload =
        HolyScannerFleetBuildBasePayload(
            reason
        )

    payload.JobId =
        jobId

    payload.TargetJobId =
        jobId

    payload.Success =
        success == true

    payload.Joined =
        success == true

    payload.Reason =
        tostring(
            reason
            or (
                success == true
                and "joined"
                or "failed"
            )
        )

    local data,
        requestError =
        HolyScannerRequestJson(
            "POST",
            HolyScannerBackendUrl(
                "/fleet/join-result"
            ),
            payload
        )

    if type(data) == "table"
    and data.ok == true then

        return true,
            "ok"
    end

    return false,
        tostring(
            requestError
            or "join-result failed"
        )
end

function HolyScannerFleetWritePendingJoin(jobId, source)

    if HolyScannerCanUseFiles() ~= true then
        return false
    end

    jobId =
        HolyScannerCleanText(
            jobId
        )

    if jobId == "" then
        return false
    end

    HolyScannerEnsureFolder()

    local payload = {
        JobId =
            jobId,

        PlaceId =
            game.PlaceId,

        ScannerId =
            HolyScannerGetScannerId(),

        Source =
            tostring(source or "fleet"),

        At =
            os.time(),
    }

    local encodeOk,
        encoded =
        pcall(function()

            return HttpService:JSONEncode(
                payload
            )
        end)

    if encodeOk ~= true
    or type(encoded) ~= "string" then
        return false
    end

    local writeOk =
        pcall(function()

            writefile(
                FLEET_JOIN_FILE,
                encoded
            )
        end)

    return writeOk == true
end

function HolyScannerFleetReadPendingJoin()

    if HolyScannerCanUseFiles() ~= true then
        return nil
    end

    local exists =
        false

    pcall(function()

        exists =
            isfile(
                FLEET_JOIN_FILE
            )
    end)

    if exists ~= true then
        return nil
    end

    local readOk,
        raw =
        pcall(function()

            return readfile(
                FLEET_JOIN_FILE
            )
        end)

    if readOk ~= true
    or type(raw) ~= "string"
    or raw == "" then

        return nil
    end

    local decodeOk,
        data =
        pcall(function()

            return HttpService:JSONDecode(
                raw
            )
        end)

    if decodeOk == true
    and type(data) == "table" then

        return data
    end

    return nil
end

function HolyScannerFleetClearPendingJoin()

    if type(delfile) ~= "function" then
        return false
    end

    local ok =
        pcall(function()

            if isfile(
                FLEET_JOIN_FILE
            ) then

                delfile(
                    FLEET_JOIN_FILE
                )
            end
        end)

    return ok == true
end

function HolyScannerFleetReportPendingJoin()

    local pending =
        HolyScannerFleetReadPendingJoin()

    if type(pending) ~= "table" then
        return false
    end

    local jobId =
        HolyScannerCleanText(
            pending.JobId
            or pending.jobId
        )

    if jobId == "" then

        HolyScannerFleetClearPendingJoin()

        return false
    end

    local createdAt =
        tonumber(
            pending.At
            or pending.at
        )
        or 0

    local age =
        os.time() - createdAt

    if age > FLEET_JOIN_REPORT_MAX_AGE then

        HolyScannerFleetClearPendingJoin()

        return false
    end

    local joined =
        tostring(game.JobId) == jobId

    local ok =
        false

    ok =
        select(
            1,
            HolyScannerFleetJoinResult(
                jobId,
                joined,
                joined == true
                and "joined"
                or "loaded different server"
            )
        )

    if ok == true
    or age > 45 then

        HolyScannerFleetClearPendingJoin()
    end

    return ok == true
end

function HolyScannerStartReporter()

    if HOLY_SCANNER_REPORT_STATE.Running == true then
        return false
    end

    HOLY_SCANNER_REPORT_STATE.Running =
        true

    HOLY_SCANNER_REPORT_STATE.Sent =
        type(HOLY_SCANNER_REPORT_STATE.Sent) == "table"
        and HOLY_SCANNER_REPORT_STATE.Sent
        or {}

    local token =
        {}

    HOLY_SCANNER_REPORT_STATE.Token =
        token

    task.spawn(function()

        task.wait(
            1.25
        )

        while HOLY_SCANNER_RUNNING == true
        and HOLY_SCANNER_REPORT_STATE.Token == token do

            local rows =
                {}

            local scanOk,
                scanResult =
                pcall(function()

                    return HolyScannerScanLivePetRows()
                end)

            if scanOk == true
            and type(scanResult) == "table" then

                rows =
                    scanResult
            end

            if os.clock() - (
                tonumber(
                    HOLY_SCANNER_REPORT_STATE.LastRareScanAt
                )
                or 0
            ) >= RARE_SCAN_INTERVAL then

                HOLY_SCANNER_REPORT_STATE.LastRareScanAt =
                    os.clock()

                local payload,
                    sentKeys =
                    HolyScannerBuildRarePayload(
                        rows
                    )

                if type(payload) == "table" then

                    pcall(function()

                        HolyScannerSendRarePayload(
                            payload,
                            sentKeys
                        )
                    end)
                end
            end

            if os.time() - (
                tonumber(
                    HOLY_SCANNER_REPORT_STATE.LastScannerReportAt
                )
                or 0
            ) >= REPORT_INTERVAL then

                local scannerPayload =
                    HolyScannerBuildScannerPayload(
                        rows
                    )

                pcall(function()

                    HolyScannerSendScannerPayload(
                        scannerPayload
                    )
                end)
            end

            if os.time() - (
                tonumber(
                    HOLY_SCANNER_REPORT_STATE.LastClientHeartbeatAt
                )
                or 0
            ) >= CLIENT_HEARTBEAT_INTERVAL then

                local clientPayload =
                    HolyScannerBuildClientHeartbeatPayload(
                        rows
                    )

                pcall(function()

                    HolyScannerSendClientHeartbeat(
                        clientPayload
                    )
                end)
            end

            task.wait(
                0.35
            )
        end

        HOLY_SCANNER_REPORT_STATE.Running =
            false
    end)

    return true
end

--==================================================
-- [11.5] HUNT MODE / HOLD TARGETS
--==================================================

function HolyScannerSetLabel(label, text)

    text =
        tostring(text or "")

    if type(label) == "table" then

        if type(label.SetText) == "function" then

            pcall(function()

                label:SetText(
                    text
                )
            end)

            return true
        end

        if label.TextLabel
        and typeof(label.TextLabel) == "Instance" then

            pcall(function()

                label.TextLabel.Text =
                    text
            end)

            return true
        end
    end

    if typeof(label) == "Instance" then

        pcall(function()

            label.Text =
                text
        end)

        return true
    end

    return false
end

function HolyScannerSetStatus(text)

    HOLY_SCANNER_SERVER_STATE.LastStatus =
        tostring(text or "Ready")

    HolyScannerSetLabel(
        HOLY_SCANNER_UI
        and HOLY_SCANNER_UI.StatusLabel
        or nil,
        "Status: "
            .. tostring(HOLY_SCANNER_SERVER_STATE.LastStatus)
    )

    return true
end

function HolyScannerHuntAlias(value)

    return HolyScannerCleanText(
        value
    )
        :lower()
        :gsub("[%s_%-%[%]%(%)%.'\"_/{}]", "")
end

function HolyScannerHuntRowKey(row)

    row =
        type(row) == "table"
        and row
        or {}

    return HolyScannerCleanText(
        row.UUID
        or row.Key
        or ""
    )
end

function HolyScannerHuntIsSpecificPet(row)

    row =
        type(row) == "table"
        and row
        or {}

    local key =
        HolyScannerHuntAlias(
            row.Pet
            or row.PetName
            or row.DisplayName
        )

    return key == "raccoon"
        or key == "unicorn"
        or key == "goldendragonfly"
        or key == "dragonfly"
end

function HolyScannerHuntIsTargetRow(row)

    if type(row) ~= "table" then
        return false
    end

    local size =
        HolyScannerRareNormalizeSize(
            row.Size
        )

    local variant =
        HolyScannerRareNormalizeVariant(
            row.Variant
            or row.Mutation
        )

    if size == "Big"
    or size == "Huge" then

        return true
    end

    if variant == "Rainbow" then
        return true
    end

    return HolyScannerHuntIsSpecificPet(
        row
    ) == true
end

function HolyScannerHuntFormatTimeLeft(row)

    row =
        type(row) == "table"
        and row
        or {}

    local timeLeft =
        tonumber(row.TimeLeftNumber)
        or tonumber(row.TimeLeft)
        or 0

    if timeLeft <= 0 then
        return "--"
    end

    timeLeft =
        math.max(
            0,
            math.floor(timeLeft)
        )

    local minutes =
        math.floor(
            timeLeft / 60
        )

    local seconds =
        timeLeft % 60

    return string.format(
        "%02d:%02d",
        minutes,
        seconds
    )
end

function HolyScannerHuntDisplay(row)

    row =
        type(row) == "table"
        and row
        or {}

    local name =
        HolyScannerCleanText(
            row.DisplayName
            or row.Pet
            or "Target"
        )

    local timer =
        HolyScannerHuntFormatTimeLeft(
            row
        )

    if timer ~= "--" then

        return name
            .. " ("
            .. timer
            .. ")"
    end

    return name
end

function HolyScannerHuntEnsureState()

    HOLY_SCANNER_SERVER_STATE =
        type(HOLY_SCANNER_SERVER_STATE) == "table"
        and HOLY_SCANNER_SERVER_STATE
        or {}

    HOLY_SCANNER_SERVER_STATE.HoldTargets =
        type(HOLY_SCANNER_SERVER_STATE.HoldTargets) == "table"
        and HOLY_SCANNER_SERVER_STATE.HoldTargets
        or {}

    HOLY_SCANNER_SERVER_STATE.NoTargetSince =
        tonumber(HOLY_SCANNER_SERVER_STATE.NoTargetSince)
        or 0

    HOLY_SCANNER_SERVER_STATE.GoneSince =
        tonumber(HOLY_SCANNER_SERVER_STATE.GoneSince)
        or 0

    HOLY_SCANNER_SERVER_STATE.LastTargetSeenAt =
        tonumber(HOLY_SCANNER_SERVER_STATE.LastTargetSeenAt)
        or 0

    HOLY_SCANNER_SERVER_STATE.LastTargetText =
        tostring(
            HOLY_SCANNER_SERVER_STATE.LastTargetText
            or "None"
        )

    return HOLY_SCANNER_SERVER_STATE
end

function HolyScannerHuntBuildSummary(rows)

    rows =
        type(rows) == "table"
        and rows
        or {}

    local parts =
        {}

    for _, row in ipairs(rows) do

        table.insert(
            parts,
            HolyScannerHuntDisplay(
                row
            )
        )

        if #parts >= 3 then
            break
        end
    end

    if #rows > 3 then

        table.insert(
            parts,
            "+"
                .. tostring(#rows - 3)
                .. " more"
        )
    end

    if #parts <= 0 then
        return "None"
    end

    return table.concat(
        parts,
        " | "
    )
end

function HolyScannerHuntUpdateTargets(rows, reason)

    local state =
        HolyScannerHuntEnsureState()

    rows =
        type(rows) == "table"
        and rows
        or {}

    local now =
        os.clock()

    local liveRows =
        {}

    local newTargetRows =
        {}

    for _, row in ipairs(rows) do

        local key =
            HolyScannerHuntRowKey(
                row
            )

        if key ~= "" then

            liveRows[key] =
                row

            if HolyScannerHuntIsTargetRow(row) == true then

                table.insert(
                    newTargetRows,
                    row
                )

                local existing =
                    state.HoldTargets[key]

                if type(existing) ~= "table" then

                    existing =
                        {
                            Key =
                                key,

                            FirstSeenAt =
                                now,
                        }

                    state.HoldTargets[key] =
                        existing
                end

                existing.Row =
                    row

                existing.Name =
                    HolyScannerHuntDisplay(
                        row
                    )

                existing.LastSeenAt =
                    now
            end
        end
    end

    local liveHeldRows =
        {}

    local removedAny =
        false

    for key, held in pairs(state.HoldTargets) do

        local liveRow =
            liveRows[key]

        if type(liveRow) == "table" then

            held.Row =
                liveRow

            held.LastSeenAt =
                now

            table.insert(
                liveHeldRows,
                liveRow
            )

        else

            state.HoldTargets[key] =
                nil

            removedAny =
                true
        end
    end

    table.sort(liveHeldRows, function(a, b)

        local priceA =
            tonumber(a.PriceNumber)
            or 0

        local priceB =
            tonumber(b.PriceNumber)
            or 0

        if priceA ~= priceB then
            return priceA > priceB
        end

        return tostring(a.DisplayName or a.Pet)
            < tostring(b.DisplayName or b.Pet)
    end)

    if #liveHeldRows > 0 then

        state.NoTargetSince =
            0

        state.GoneSince =
            0

        state.LastTargetSeenAt =
            now

        state.LastTargetText =
            HolyScannerHuntBuildSummary(
                liveHeldRows
            )

        if HOLY_SCANNER_SERVER_STATE.Hopping == true then

            HolyScannerCancelServerHop(
                "hunt target found"
            )
        end

        HolyScannerSetStatus(
            "Holding "
                .. tostring(#liveHeldRows)
                .. " target(s): "
                .. state.LastTargetText
        )

        return #liveHeldRows,
            liveHeldRows
    end

    if removedAny == true
    or state.LastTargetSeenAt > 0 then

        if state.GoneSince <= 0 then

            state.GoneSince =
                now
        end

        HolyScannerSetStatus(
            "Target gone: "
                .. tostring(state.LastTargetText or "None")
        )

    else

        if state.NoTargetSince <= 0 then

            state.NoTargetSince =
                now
        end

        HolyScannerSetStatus(
            "Searching: no hunt target"
        )
    end

    return 0,
        {}
end

function HolyScannerHuntShouldStayOnCurrentServer(forceScan)

    local rows =
        {}

    if forceScan == true then

        local ok,
            result =
            pcall(function()

                return HolyScannerScanLivePetRows()
            end)

        if ok == true
        and type(result) == "table" then

            rows =
                result
        end
    end

    local count =
        HolyScannerHuntUpdateTargets(
            rows,
            "pre-hop"
        )

    return tonumber(count)
        and tonumber(count) > 0
end

--==================================================
-- [12] SERVER HOP
--==================================================

function HolyScannerServerPruneRecent()

    local now =
        os.time()

    for jobId, expiresAt in pairs(HOLY_SCANNER_SERVER_STATE.RecentServers or {}) do

        if tonumber(expiresAt) == nil
        or tonumber(expiresAt) <= now then

            HOLY_SCANNER_SERVER_STATE.RecentServers[jobId] =
                nil
        end
    end
end

function HolyScannerServerIsRecent(jobId)

    jobId =
        HolyScannerCleanText(
            jobId
        )

    if jobId == "" then
        return false
    end

    HolyScannerServerPruneRecent()

    return tonumber(
        HOLY_SCANNER_SERVER_STATE.RecentServers[jobId]
    ) ~= nil
end

function HolyScannerServerRememberRecent(jobId)

    jobId =
        HolyScannerCleanText(
            jobId
        )

    if jobId == "" then
        return false
    end

    HOLY_SCANNER_SERVER_STATE.RecentServers[jobId] =
        os.time() + SERVER_RECENT_COOLDOWN

    return true
end

function HolyScannerServerPruneFailed()

    local now =
        os.time()

    for jobId, row in pairs(HOLY_SCANNER_SERVER_STATE.FailedServers or {}) do

        local expiresAt =
            0

        if type(row) == "table" then

            expiresAt =
                tonumber(row.ExpiresAt)
                or 0

        else

            expiresAt =
                tonumber(row)
                or 0
        end

        if expiresAt <= now then

            HOLY_SCANNER_SERVER_STATE.FailedServers[jobId] =
                nil
        end
    end
end

function HolyScannerServerIsFailed(jobId)

    jobId =
        HolyScannerCleanText(
            jobId
        )

    if jobId == "" then
        return false
    end

    HolyScannerServerPruneFailed()

    return HOLY_SCANNER_SERVER_STATE.FailedServers[jobId] ~= nil
end

function HolyScannerServerRememberFailed(jobId, reason)

    jobId =
        HolyScannerCleanText(
            jobId
        )

    if jobId == "" then
        return false
    end

    HOLY_SCANNER_SERVER_STATE.FailedServers[jobId] = {
        ExpiresAt =
            os.time() + SERVER_FAILED_COOLDOWN,

        Reason =
            tostring(reason or "failed"),
    }

    return true
end

function HolyScannerServerBackoffLeft()

    local untilTime =
        tonumber(
            HOLY_SCANNER_SERVER_STATE.TeleportBackoffUntil
        )
        or 0

    return math.max(
        0,
        untilTime - os.clock()
    )
end

function HolyScannerServerSetBackoff(reason)

    reason =
        HolyScannerCleanText(
            reason
        )

    if reason == "" then
        reason =
            "teleport failed"
    end

    HOLY_SCANNER_SERVER_STATE.TeleportFailCount =
        math.min(
            8,
            (
                tonumber(
                    HOLY_SCANNER_SERVER_STATE.TeleportFailCount
                )
                or 0
            )
            + 1
        )

    local failCount =
        tonumber(
            HOLY_SCANNER_SERVER_STATE.TeleportFailCount
        )
        or 1

    local lower =
        reason:lower()

    local delay =
        SERVER_JOIN_BACKOFF_MIN
        + (failCount * 2)
        + math.random(0, 3)

    if lower:find("529", 1, true)
    or lower:find("http", 1, true) then

        delay =
            math.max(
                delay,
                15
            )
    end

    if lower:find("772", 1, true)
    or lower:find("full", 1, true) then

        delay =
            math.max(
                delay,
                5
            )
    end

    delay =
        math.clamp(
            delay,
            SERVER_JOIN_BACKOFF_MIN,
            SERVER_JOIN_BACKOFF_MAX
        )

    HOLY_SCANNER_SERVER_STATE.TeleportBackoffUntil =
        os.clock() + delay

    HOLY_SCANNER_SERVER_STATE.LastTeleportError =
        reason

    HOLY_SCANNER_SERVER_STATE.LastTeleportFailAt =
        os.clock()

    HolyScannerSetStatus(
        "Teleport retry in "
            .. tostring(
                math.ceil(delay)
            )
            .. "s: "
            .. reason
    )

    return delay
end

function HolyScannerServerClearBackoff()

    HOLY_SCANNER_SERVER_STATE.TeleportBackoffUntil =
        0

    HOLY_SCANNER_SERVER_STATE.TeleportFailCount =
        0

    HOLY_SCANNER_SERVER_STATE.LastTeleportError =
        ""

    HOLY_SCANNER_SERVER_STATE.LastTeleportFailAt =
        0

    return true
end

function HolyScannerGetPlayerGui()

    if not LocalPlayer then
        return nil
    end

    return LocalPlayer:FindFirstChildOfClass(
        "PlayerGui"
    )
    or LocalPlayer:FindFirstChild(
        "PlayerGui"
    )
end

function HolyScannerFindTeleportErrorTextAndButton()

    local roots = {
        CoreGui,
        HolyScannerGetPlayerGui(),
    }

    local foundError =
        false

    local okButton =
        nil

    for _, root in ipairs(roots) do

        if typeof(root) == "Instance" then

            local ok,
                descendants =
                pcall(function()

                    return root:GetDescendants()
                end)

            if ok == true
            and type(descendants) == "table" then

                for _, descendant in ipairs(descendants) do

                    if descendant:IsA("TextLabel")
                    or descendant:IsA("TextButton")
                    or descendant:IsA("TextBox") then

                        local text =
                            HolyScannerCleanText(
                                pcall(function()

                                    return descendant.Text
                                end)
                            )

                        local readOk,
                            rawText =
                            pcall(function()

                                return descendant.Text
                            end)

                        if readOk == true then

                            text =
                                HolyScannerCleanText(
                                    rawText
                                )
                        end

                        local lower =
                            text:lower()

                        if lower:find("error code: 772", 1, true)
                        or lower:find("server is full", 1, true)
                        or lower:find("please try again later", 1, true)
                        or lower:find("join error", 1, true)
                        or lower:find("error code: 529", 1, true) then

                            foundError =
                                true
                        end

                        if descendant:IsA("TextButton") then

                            if lower == "ok"
                            or lower == "cancel" then

                                okButton =
                                    okButton
                                    or descendant
                            end
                        end
                    end
                end
            end
        end
    end

    return foundError,
        okButton
end

function HolyScannerDismissTeleportErrorPrompt()

    local foundError,
        button =
        HolyScannerFindTeleportErrorTextAndButton()

    if foundError ~= true then
        return false
    end

    if typeof(button) == "Instance"
    and button:IsA("GuiButton") then

        local center =
            HolyScannerLoadingGetGuiCenter(
                button
            )

        if center then

            HolyScannerClickAt(
                center
            )

            return true
        end
    end

    HolyScannerPressKey(
        Enum.KeyCode.Return
    )

    task.wait(
        0.08
    )

    HolyScannerPressKey(
        Enum.KeyCode.Escape
    )

    task.wait(
        0.08
    )

    HolyScannerClickAt(
        HolyScannerLoadingGetScreenCenter()
    )

    return true
end

function HolyScannerStartTeleportWatchers()

    if HOLY_SCANNER_SERVER_STATE.TeleportErrorWatcherStarted == true then
        return false
    end

    HOLY_SCANNER_SERVER_STATE.TeleportErrorWatcherStarted =
        true

    pcall(function()

        HolyScannerTrackConnection(
            TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)

                if player ~= LocalPlayer then
                    return
                end

                local reason =
                    tostring(teleportResult or "TeleportInitFailed")
                    .. " "
                    .. tostring(errorMessage or "")

                local targetServer =
                    HolyScannerCleanText(
                        HOLY_SCANNER_SERVER_STATE.LastTargetServer
                    )

                if targetServer ~= "" then

                    HolyScannerServerRememberFailed(
                        targetServer,
                        reason
                    )
                end

                HolyScannerServerSetBackoff(
                    reason
                )

                HOLY_SCANNER_SERVER_STATE.HopToken =
                    (
                        tonumber(
                            HOLY_SCANNER_SERVER_STATE.HopToken
                        )
                        or 0
                    )
                    + 1

                HOLY_SCANNER_SERVER_STATE.Hopping =
                    false

                task.defer(
                    HolyScannerDismissTeleportErrorPrompt
                )
            end)
        )
    end)

    task.spawn(function()

        while HOLY_SCANNER_RUNNING == true do

            local found =
                HolyScannerDismissTeleportErrorPrompt()

            if found == true then

                local targetServer =
                    HolyScannerCleanText(
                        HOLY_SCANNER_SERVER_STATE.LastTargetServer
                    )

                if targetServer ~= "" then

                    HolyScannerServerRememberFailed(
                        targetServer,
                        "join error popup"
                    )
                end

                HolyScannerServerSetBackoff(
                    "join error popup"
                )

                HOLY_SCANNER_SERVER_STATE.HopToken =
                    (
                        tonumber(
                            HOLY_SCANNER_SERVER_STATE.HopToken
                        )
                        or 0
                    )
                    + 1

                HOLY_SCANNER_SERVER_STATE.Hopping =
                    false
            end

            if HOLY_SCANNER_SERVER_STATE.Hopping == true then

                local lastHopAt =
                    tonumber(
                        HOLY_SCANNER_SERVER_STATE.LastHopAt
                    )
                    or 0

                if lastHopAt > 0
                and os.clock() - lastHopAt >= 18 then

                    local targetServer =
                        HolyScannerCleanText(
                            HOLY_SCANNER_SERVER_STATE.LastTargetServer
                        )

                    if targetServer ~= "" then

                        HolyScannerServerRememberFailed(
                            targetServer,
                            "teleport stuck"
                        )
                    end

                    HolyScannerServerSetBackoff(
                        "teleport stuck"
                    )

                    HOLY_SCANNER_SERVER_STATE.HopToken =
                        (
                            tonumber(
                                HOLY_SCANNER_SERVER_STATE.HopToken
                            )
                            or 0
                        )
                        + 1

                    HOLY_SCANNER_SERVER_STATE.Hopping =
                        false
                end
            end

            task.wait(
                1
            )
        end
    end)

    return true
end

function HolyScannerServerBuildPublicUrl(cursor, sortOrder)

    sortOrder =
        HolyScannerCleanText(
            sortOrder
        )

    if sortOrder ~= "Asc"
    and sortOrder ~= "Desc" then

        sortOrder =
            "Asc"
    end

    local url =
        "https://games.roblox.com/v1/games/"
        .. tostring(game.PlaceId)
        .. "/servers/Public?sortOrder="
        .. sortOrder
        .. "&limit=100&excludeFullGames=true"

    cursor =
        HolyScannerCleanText(
            cursor
        )

    if cursor ~= "" then

        url =
            url
            .. "&cursor="
            .. HttpService:UrlEncode(
                cursor
            )
    end

    return url
end

function HolyScannerServerRowAllowed(server, seenServers, allowRecent)

    if type(server) ~= "table" then
        return false
    end

    local serverId =
        HolyScannerCleanText(
            server.id
        )

    if serverId == ""
    or serverId == tostring(game.JobId) then

        return false
    end

    if type(seenServers) == "table"
    and seenServers[serverId] == true then

        return false
    end

    local playing =
        tonumber(server.playing)
        or 0

    local maxPlayers =
        tonumber(server.maxPlayers)
        or 0

    if maxPlayers <= 0 then
        return false
    end

    local freeSlots =
        maxPlayers - playing

    if playing < SERVER_MIN_PLAYERS then
        return false
    end

    if playing > SERVER_TARGET_MAX_PLAYERS then
        return false
    end

    if freeSlots < SERVER_MIN_FREE_SLOTS then
        return false
    end

    if playing >= maxPlayers then
        return false
    end

    if playing >= SERVER_MAX_PLAYERS then
        return false
    end

    if allowRecent ~= true
    and HolyScannerServerIsRecent(serverId) == true then

        return false
    end

    if HolyScannerServerIsFailed(serverId) == true then
        return false
    end

    return true
end

function HolyScannerServerFetchCandidates(allowRecent)

    local candidates =
        {}

    local seenServers =
        {}

    local pageLimit =
        math.clamp(
            HolyScannerReadInteger(
                HOLY_SCANNER_STATE.SearchPages,
                SERVER_DEFAULT_SEARCH_PAGES
            ),
            1,
            10
        )

    for _, sortOrder in ipairs({
        "Asc",
        "Desc",
    }) do

        local cursor =
            ""

        local seenCursors =
            {}

        local pagesThisSort =
            0

        while HOLY_SCANNER_RUNNING == true
        and HOLY_SCANNER_SERVER_STATE.Hopping == true
        and pagesThisSort < pageLimit do

            pagesThisSort =
                pagesThisSort + 1

            local body =
                nil

            body =
                select(
                    1,
                    HolyScannerHttpGet(
                        HolyScannerServerBuildPublicUrl(
                            cursor,
                            sortOrder
                        )
                    )
                )

            if type(body) ~= "string"
            or body == "" then
                break
            end

            local decodeOk,
                data =
                pcall(function()

                    return HttpService:JSONDecode(
                        body
                    )
                end)

            if decodeOk ~= true
            or type(data) ~= "table" then
                break
            end

            for _, server in ipairs(data.data or {}) do

                local serverId =
                    HolyScannerCleanText(
                        server.id
                    )

                if HolyScannerServerRowAllowed(
                    server,
                    seenServers,
                    allowRecent == true
                ) == true then

                    seenServers[serverId] =
                        true

                    local playing =
                        tonumber(server.playing)
                        or 0

                    local maxPlayers =
                        tonumber(server.maxPlayers)
                        or 0

                    server.FreeSlots =
                        math.max(
                            0,
                            maxPlayers - playing
                        )

                    server.HolyRandom =
                        math.random(
                            1,
                            1000000
                        )

                    table.insert(
                        candidates,
                        server
                    )

                    if #candidates >= SERVER_POOL_TARGET then

                        return candidates,
                            "ok"
                    end
                end
            end

            cursor =
                HolyScannerCleanText(
                    data.nextPageCursor
                )

            if cursor == "" then
                break
            end

            if seenCursors[cursor] == true then
                break
            end

            seenCursors[cursor] =
                true

            task.wait()
        end

        if #candidates > 0 then
            break
        end
    end

    if #candidates <= 0 then

        return {},
            "no servers"
    end

    return candidates,
        "ok"
end

function HolyScannerServerPickLowest(servers)

    if type(servers) ~= "table"
    or #servers <= 0 then

        return nil
    end

    local usable =
        {}

    for _, server in ipairs(servers) do

        local freeSlots =
            tonumber(server.FreeSlots)
            or (
                (
                    tonumber(server.maxPlayers)
                    or 0
                )
                -
                (
                    tonumber(server.playing)
                    or 0
                )
            )

        if freeSlots >= SERVER_MIN_FREE_SLOTS then

            table.insert(
                usable,
                server
            )
        end
    end

    if #usable <= 0 then

        usable =
            servers
    end

    for index = #usable, 2, -1 do

        local swap =
            math.random(
                1,
                index
            )

        usable[index],
            usable[swap] =
            usable[swap],
            usable[index]
    end

    table.sort(usable, function(a, b)

        local playingA =
            tonumber(a.playing)
            or 0

        local playingB =
            tonumber(b.playing)
            or 0

        if playingA ~= playingB then
            return playingA < playingB
        end

        local freeA =
            tonumber(a.FreeSlots)
            or 0

        local freeB =
            tonumber(b.FreeSlots)
            or 0

        if freeA ~= freeB then
            return freeA > freeB
        end

        return tonumber(a.HolyRandom or 0)
            > tonumber(b.HolyRandom or 0)
    end)

    local pickLimit =
        math.min(
            #usable,
            math.max(
                1,
                SERVER_PICK_TOP_RANDOM
            )
        )

    return usable[
        math.random(
            1,
            pickLimit
        )
    ]
end

function HolyScannerQueueServerHop(reason)

    local backoffLeft =
        HolyScannerServerBackoffLeft()

    if backoffLeft > 0 then

        HolyScannerSetStatus(
            "Teleport backoff "
                .. tostring(
                    math.ceil(backoffLeft)
                )
                .. "s"
        )

        return false,
            "backoff"
    end

    if HOLY_SCANNER_SERVER_STATE.Hopping == true then
        return false,
            "already hopping"
    end

    HOLY_SCANNER_SERVER_STATE.HopToken =
        (
            tonumber(HOLY_SCANNER_SERVER_STATE.HopToken)
            or 0
        )
        + 1

    local token =
        HOLY_SCANNER_SERVER_STATE.HopToken

    HOLY_SCANNER_SERVER_STATE.Hopping =
        true

    HOLY_SCANNER_SERVER_STATE.HopAttempt =
        0

    task.spawn(function()

        while HOLY_SCANNER_RUNNING == true
        and HOLY_SCANNER_SERVER_STATE.Hopping == true
        and HOLY_SCANNER_SERVER_STATE.HopToken == token do

            local backoff =
                HolyScannerServerBackoffLeft()

            if backoff > 0 then

                HolyScannerSetStatus(
                    "Teleport retry in "
                        .. tostring(
                            math.ceil(backoff)
                        )
                        .. "s"
                )

                task.wait(
                    math.min(
                        2,
                        backoff
                    )
                )

                continue
            end

            HOLY_SCANNER_SERVER_STATE.HopAttempt =
                (
                    tonumber(
                        HOLY_SCANNER_SERVER_STATE.HopAttempt
                    )
                    or 0
                )
                + 1

            HolyScannerSetStatus(
                "Fleet finding server · try "
                    .. tostring(
                        HOLY_SCANNER_SERVER_STATE.HopAttempt
                    )
            )

            local target =
                nil

            local fetchReason =
                ""

            local targetSource =
                "local"

            if HolyScannerFleetEnabled() == true then

                target,
                    fetchReason =
                    HolyScannerFleetNextServer(
                        reason
                    )

                if type(target) == "table"
                and HolyScannerCleanText(target.id) ~= "" then

                    targetSource =
                        "fleet"
                end
            end

            if type(target) ~= "table"
            or HolyScannerCleanText(target.id) == "" then

                HolyScannerSetStatus(
                    "Fleet fallback: "
                        .. tostring(fetchReason or "local search")
                )

                local servers =
                    nil

                servers,
                    fetchReason =
                    HolyScannerServerFetchCandidates(
                        false
                    )

                if (
                    type(servers) ~= "table"
                    or #servers <= 0
                ) then

                    servers,
                        fetchReason =
                        HolyScannerServerFetchCandidates(
                            true
                        )
                end

                if HOLY_SCANNER_SERVER_STATE.Hopping ~= true
                or HOLY_SCANNER_SERVER_STATE.HopToken ~= token then
                    return
                end

                if type(servers) ~= "table"
                or #servers <= 0 then

                    HolyScannerSetStatus(
                        "No servers found, retrying..."
                    )

                    HolyScannerServerSetBackoff(
                        tostring(fetchReason or "no servers")
                    )

                    task.wait(
                        SERVER_RETRY_DELAY
                    )

                    continue
                end

                target =
                    HolyScannerServerPickLowest(
                        servers
                    )

                targetSource =
                    "local"
            end

            if type(target) ~= "table"
            or HolyScannerCleanText(target.id) == "" then

                HolyScannerSetStatus(
                    "No target server, retrying..."
                )

                task.wait(
                    SERVER_RETRY_DELAY
                )

                continue
            end

            if HOLY_SCANNER_STATE.HuntMode == true
            and HolyScannerHuntShouldStayOnCurrentServer(true) == true then

                HolyScannerCancelServerHop(
                    "hunt target found before teleport"
                )

                return
            end

            local targetId =
                HolyScannerCleanText(
                    target.id
                    or target.JobId
                    or target.jobId
                )

            local playing =
                tonumber(
                    target.playing
                    or target.Playing
                )
                or 0

            local maxPlayers =
                tonumber(
                    target.maxPlayers
                    or target.MaxPlayers
                )
                or 8

            local freeSlots =
                tonumber(
                    target.FreeSlots
                    or target.freeSlots
                )
                or math.max(
                    0,
                    maxPlayers - playing
                )

            local targetText =
                tostring(playing)
                .. "/"
                .. tostring(maxPlayers)
                .. " · free "
                .. tostring(freeSlots)
                .. " · "
                .. tostring(targetSource)
                .. " · "
                .. targetId:sub(1, 8)

            HOLY_SCANNER_SERVER_STATE.LastTargetServer =
                targetId

            HOLY_SCANNER_SERVER_STATE.LastTargetPlayers =
                targetText

            HolyScannerServerRememberRecent(
                targetId
            )

            HolyScannerSetStatus(
                "Joining "
                    .. targetText
            )

            local startedJobId =
                tostring(game.JobId)

            if targetSource == "fleet" then

                HolyScannerFleetWritePendingJoin(
                    targetId,
                    "fleet"
                )
            end

            local ok,
                err =
                pcall(function()

                    TeleportService:TeleportToPlaceInstance(
                        game.PlaceId,
                        targetId,
                        LocalPlayer
                    )
                end)

            if ok == true then

                HOLY_SCANNER_SERVER_STATE.LastHopAt =
                    os.clock()

                local startedAt =
                    os.clock()

                while HOLY_SCANNER_RUNNING == true
                and HOLY_SCANNER_SERVER_STATE.Hopping == true
                and HOLY_SCANNER_SERVER_STATE.HopToken == token
                and os.clock() - startedAt < SERVER_TELEPORT_TIMEOUT do

                    if tostring(game.JobId) ~= startedJobId then
                        return
                    end

                    task.wait(
                        0.25
                    )
                end

                if HOLY_SCANNER_SERVER_STATE.Hopping ~= true
                or HOLY_SCANNER_SERVER_STATE.HopToken ~= token then

                    return
                end

                if tostring(game.JobId) == startedJobId then

                    local failReason =
                        "teleport timeout / possible full server"

                    HolyScannerServerRememberFailed(
                        targetId,
                        failReason
                    )

                    if targetSource == "fleet" then

                        HolyScannerFleetJoinResult(
                            targetId,
                            false,
                            failReason
                        )

                        HolyScannerFleetClearPendingJoin()
                    end

                    HolyScannerServerSetBackoff(
                        failReason
                    )

                    HolyScannerDismissTeleportErrorPrompt()

                    task.wait(
                        SERVER_RETRY_DELAY
                    )

                else

                    return
                end

            else

                local failReason =
                    "teleport failed: "
                    .. tostring(err)

                HolyScannerServerRememberFailed(
                    targetId,
                    failReason
                )

                if targetSource == "fleet" then

                    HolyScannerFleetJoinResult(
                        targetId,
                        false,
                        failReason
                    )

                    HolyScannerFleetClearPendingJoin()
                end

                HolyScannerServerSetBackoff(
                    failReason
                )

                HolyScannerDismissTeleportErrorPrompt()

                task.wait(
                    SERVER_RETRY_DELAY
                )
            end
        end

        if HOLY_SCANNER_SERVER_STATE.HopToken == token then

            HOLY_SCANNER_SERVER_STATE.Hopping =
                false
        end
    end)

    return true,
        "queued"
end

function HolyScannerCancelServerHop(reason)

    HOLY_SCANNER_SERVER_STATE.HopToken =
        (
            tonumber(HOLY_SCANNER_SERVER_STATE.HopToken)
            or 0
        )
        + 1

    HOLY_SCANNER_SERVER_STATE.Hopping =
        false

    HOLY_SCANNER_SERVER_STATE.HopAttempt =
        0

    return true
end

function HolyScannerStartAutoHopLoop()

    task.spawn(function()

        task.wait(
            0.25
        )

        while HOLY_SCANNER_RUNNING == true do

            HolyScannerNormalizeState()

            local refRoot =
                HolyScannerGetWildPetRefRoot()

            if HOLY_SCANNER_STATE.HuntMode == true
            and HOLY_SCANNER_SERVER_STATE.Hopping ~= true
            and typeof(refRoot) == "Instance" then

                local rows =
                    {}

                local scanOk,
                    scanResult =
                    pcall(function()

                        return HolyScannerScanLivePetRows()
                    end)

                if scanOk == true
                and type(scanResult) == "table" then

                    rows =
                        scanResult
                end

                local liveTargetCount =
                    HolyScannerHuntUpdateTargets(
                        rows,
                        "hunt loop"
                    )

                if tonumber(liveTargetCount) <= 0 then

                    local now =
                        os.clock()

                    local state =
                        HolyScannerHuntEnsureState()

                    local hadTargetBefore =
                        tonumber(state.LastTargetSeenAt)
                        and tonumber(state.LastTargetSeenAt) > 0

                    local waitFrom =
                        0

                    local requiredDelay =
                        0

                    if hadTargetBefore == true
                    and tonumber(state.GoneSince) > 0 then

                        waitFrom =
                            tonumber(state.GoneSince)
                            or now

                        requiredDelay =
                            math.clamp(
                                tonumber(HOLY_SCANNER_STATE.GoneConfirmDelay)
                                or HUNT_GONE_CONFIRM_DEFAULT,
                                0.25,
                                10
                            )

                    else

                        if tonumber(state.NoTargetSince) <= 0 then

                            state.NoTargetSince =
                                now
                        end

                        waitFrom =
                            tonumber(state.NoTargetSince)
                            or now

                        requiredDelay =
                            math.clamp(
                                tonumber(HOLY_SCANNER_STATE.HopDelay)
                                or 3,
                                1,
                                300
                            )
                    end

                    local remaining =
                        requiredDelay - (
                            now - waitFrom
                        )

                    if remaining <= 0 then

                        if HolyScannerHuntShouldStayOnCurrentServer(true) ~= true then

                            HolyScannerSetStatus(
                                hadTargetBefore == true
                                and "Hopping: watched target disappeared"
                                or "Hopping: no hunt target"
                            )

                            HolyScannerQueueServerHop(
                                hadTargetBefore == true
                                and "hunt target gone"
                                or "no hunt target"
                            )
                        end

                    else

                        HolyScannerSetStatus(
                            hadTargetBefore == true
                            and (
                                "Target gone, confirming "
                                .. tostring(
                                    math.max(
                                        0,
                                        math.floor(remaining + 0.5)
                                    )
                                )
                                .. "s"
                            )
                            or (
                                "No target, hopping in "
                                .. tostring(
                                    math.max(
                                        0,
                                        math.floor(remaining + 0.5)
                                    )
                                )
                                .. "s"
                            )
                        )
                    end
                end

            elseif HOLY_SCANNER_STATE.HuntMode == true then

                HolyScannerSetStatus(
                    "Waiting for Live Wild Pets"
                )

            elseif HOLY_SCANNER_SERVER_STATE.Hopping ~= true then

                HolyScannerSetStatus(
                    "Hunt Mode off"
                )
            end

            task.wait(
                0.35
            )
        end
    end)
end

--==================================================
-- [13] UI
--==================================================

function HolyScannerAddGroupbox(tab, side, title, icon)

    local sideName =
        tostring(side or "Left")

    local collapsibleMethod =
        sideName == "Right"
        and "AddRightCollapsibleGroupbox"
        or "AddLeftCollapsibleGroupbox"

    local fallbackMethod =
        sideName == "Right"
        and "AddRightGroupbox"
        or "AddLeftGroupbox"

    if tab
    and type(tab[collapsibleMethod]) == "function" then

        local ok,
            result =
            pcall(function()

                return tab[collapsibleMethod](
                    tab,
                    title,
                    icon,
                    true
                )
            end)

        if ok == true
        and result ~= nil then
            return result
        end
    end

    if tab
    and type(tab[fallbackMethod]) == "function" then

        return tab[fallbackMethod](
            tab,
            title,
            icon
        )
    end

    return nil
end

function HolyScannerCreateUI()

    Library =
        HolyScannerLoadUrl(
            LIBRARY_URL,
            "libraryholy5.lua"
        )

    if type(Library) ~= "table" then

        error(
            "[HOLY SCANNER] library did not return Library table.",
            0
        )
    end

    Options =
        Library.Options

    Toggles =
        Library.Toggles

    Library.ForceCheckbox =
        false

    Library.ShowToggleFrameInKeybinds =
        true

    local Window =
        Library:CreateWindow({
            Title =
                '<font color="rgb(245,245,247)"><b>HOLY</b></font> <font color="rgb(232,45,67)"><b>SCANNER</b></font>',

            Footer =
                "HOLY Scanner",

            ToggleKeybind =
                Enum.KeyCode.LeftAlt,

            Font =
                Enum.Font.GothamMedium,

            Center =
                true,

            AutoShow =
                false,

            Size =
                UDim2.fromOffset(
                    470,
                    315
                ),

            CornerRadius =
                7,

            GlobalSearch =
                false,

            EnableCompacting =
                true,

            EnableSidebarResize =
                false,

            MinSidebarWidth =
                120,
        })

    local Tabs = {
        Scanner =
            Window:AddTab({
                Name =
                    "Scanner",

                Icon =
                    "activity",

                Description =
                    "Scanner tools.",
            }),
    }

    local ShopBox =
        HolyScannerAddGroupbox(
            Tabs.Scanner,
            "Left",
            "Shop",
            "shopping-cart"
        )

    local ServerBox =
        HolyScannerAddGroupbox(
            Tabs.Scanner,
            "Right",
            "Server",
            "server"
        )

    if type(ShopBox) == "table" then

        ShopBox:AddToggle(
            "HolyScannerAutoBuySeeds",
            {
                Text =
                    "Auto Buy Seeds",

                Default =
                    HOLY_SCANNER_STATE.AutoBuySeeds == true,
            }
        ):OnChanged(function(value)

            HOLY_SCANNER_STATE.AutoBuySeeds =
                value == true

            HolyScannerQueueSaveSettings()

            if value == true then

                HolyScannerShopQueueCategory(
                    "Seeds"
                )
            end
        end)

        HOLY_SCANNER_UI.SeedDropdown =
            ShopBox:AddDropdown(
                "HolyScannerSelectedSeeds",
                {
                    Text =
                        "Seeds",

                    Values = {
                        "All",
                    },

                    Default =
                        HolyScannerSelectionArray(
                            HOLY_SCANNER_STATE.SelectedSeeds
                        ),

                    Multi =
                        true,

                    Searchable =
                        true,

                    MaxVisibleDropdownItems =
                        8,
                }
            )

        HOLY_SCANNER_UI.SeedDropdown:OnChanged(function(value)

            HOLY_SCANNER_STATE.SelectedSeeds =
                HolyScannerSelectionArray(
                    value
                )

            HolyScannerQueueSaveSettings()

            HolyScannerShopQueueCategory(
                "Seeds"
            )
        end)

        ShopBox:AddToggle(
            "HolyScannerAutoBuyGear",
            {
                Text =
                    "Auto Buy Gear",

                Default =
                    HOLY_SCANNER_STATE.AutoBuyGear == true,
            }
        ):OnChanged(function(value)

            HOLY_SCANNER_STATE.AutoBuyGear =
                value == true

            HolyScannerQueueSaveSettings()

            if value == true then

                HolyScannerShopQueueCategory(
                    "Gear"
                )
            end
        end)

        HOLY_SCANNER_UI.GearDropdown =
            ShopBox:AddDropdown(
                "HolyScannerSelectedGear",
                {
                    Text =
                        "Gear",

                    Values = {
                        "All",
                    },

                    Default =
                        HolyScannerSelectionArray(
                            HOLY_SCANNER_STATE.SelectedGear
                        ),

                    Multi =
                        true,

                    Searchable =
                        true,

                    MaxVisibleDropdownItems =
                        8,
                }
            )

        HOLY_SCANNER_UI.GearDropdown:OnChanged(function(value)

            HOLY_SCANNER_STATE.SelectedGear =
                HolyScannerSelectionArray(
                    value
                )

            HolyScannerQueueSaveSettings()

            HolyScannerShopQueueCategory(
                "Gear"
            )
        end)
    end

    if type(ServerBox) == "table" then

        ServerBox:AddToggle(
            "HolyScannerHuntMode",
            {
                Text =
                    "🎯 Hunt Mode",

                Default =
                    HOLY_SCANNER_STATE.HuntMode == true,

                Tooltip =
                    "Hops until a hunt target is found, then stays until that exact pet disappears from Live Wild Pets.",
            }
        ):OnChanged(function(value)

            HOLY_SCANNER_STATE.HuntMode =
                value == true

            HOLY_SCANNER_STATE.AutoHop =
                HOLY_SCANNER_STATE.HuntMode == true

            HolyScannerQueueSaveSettings()

            if value ~= true then

                HolyScannerCancelServerHop(
                    "hunt mode off"
                )

                HOLY_SCANNER_SERVER_STATE.HoldTargets =
                    {}

                HOLY_SCANNER_SERVER_STATE.NoTargetSince =
                    0

                HOLY_SCANNER_SERVER_STATE.GoneSince =
                    0

                HolyScannerSetStatus(
                    "Hunt Mode off"
                )

            else

                HOLY_SCANNER_SERVER_STATE.LastHopAt =
                    0

                HOLY_SCANNER_SERVER_STATE.NoTargetSince =
                    0

                HOLY_SCANNER_SERVER_STATE.GoneSince =
                    0

                HolyScannerSetStatus(
                    "Hunt Mode enabled"
                )
            end
        end)

        ServerBox:AddDropdown(
            "HolyScannerSearchPages",
            {
                Text =
                    "Search Pages",

                Values = {
                    "1",
                    "2",
                    "3",
                    "4",
                    "5",
                    "6",
                    "7",
                    "8",
                    "9",
                    "10",
                },

                Default =
                    tostring(
                        math.clamp(
                            HolyScannerReadInteger(
                                HOLY_SCANNER_STATE.SearchPages,
                                5
                            ),
                            1,
                            10
                        )
                    ),

                Multi =
                    false,

                Searchable =
                    false,

                MaxVisibleDropdownItems =
                    10,
            }
        ):OnChanged(function(value)

            HOLY_SCANNER_STATE.SearchPages =
                math.clamp(
                    HolyScannerReadInteger(
                        value,
                        5
                    ),
                    1,
                    10
                )

            HolyScannerQueueSaveSettings()
        end)

        ServerBox:AddInput(
            "HolyScannerHopDelay",
            {
                Text =
                    "No Target Hop Delay",

                Default =
                    tostring(
                        HOLY_SCANNER_STATE.HopDelay
                    ),

                Numeric =
                    true,

                Finished =
                    false,

                ClearTextOnFocus =
                    false,

                Placeholder =
                    "3",
            }
        ):OnChanged(function(value)

            HOLY_SCANNER_STATE.HopDelay =
                math.clamp(
                    HolyScannerReadNumber(
                        value,
                        3
                    ),
                    1,
                    300
                )

            HolyScannerQueueSaveSettings()
        end)

        ServerBox:AddInput(
            "HolyScannerGoneConfirmDelay",
            {
                Text =
                    "Gone Confirm Delay",

                Default =
                    tostring(
                        HOLY_SCANNER_STATE.GoneConfirmDelay
                        or HUNT_GONE_CONFIRM_DEFAULT
                    ),

                Numeric =
                    true,

                Finished =
                    false,

                ClearTextOnFocus =
                    false,

                Placeholder =
                    "1",
            }
        ):OnChanged(function(value)

            HOLY_SCANNER_STATE.GoneConfirmDelay =
                math.clamp(
                    HolyScannerReadNumber(
                        value,
                        HUNT_GONE_CONFIRM_DEFAULT
                    ),
                    0.25,
                    10
                )

            HolyScannerQueueSaveSettings()
        end)

        if type(ServerBox.AddLabel) == "function" then

            HOLY_SCANNER_UI.StatusLabel =
                ServerBox:AddLabel({
                    Text =
                        "Status: "
                            .. tostring(
                                HOLY_SCANNER_SERVER_STATE.LastStatus
                                or "Starting"
                            ),

                    DoesWrap =
                        true,
                })
        end

        ServerBox:AddButton({
            Text =
                "Hop Now",

            Func =
                function()

                    HolyScannerQueueServerHop(
                        "manual"
                    )
                end,
        })
    end

    task.delay(1, function()

        HolyScannerShopRefreshDropdowns()
    end)

    task.delay(3, function()

        HolyScannerShopRefreshDropdowns()
    end)

    return true
end

--==================================================
-- [14] STOP
--==================================================

function HolyScannerStop(reason)

    HOLY_SCANNER_RUNNING =
        false

    HOLY_SCANNER_LOADING_STATE.Token =
        nil

    HOLY_SCANNER_ANTI_AFK_STATE.Token =
        nil

    HOLY_SCANNER_REPORT_STATE.Token =
        nil

    HOLY_SCANNER_PERFORMANCE_STATE.Token =
        nil

    HolyScannerCancelServerHop(
        tostring(reason or "stopped")
    )

    for _, connection in ipairs(HOLY_SCANNER_CONNECTIONS) do

        pcall(function()

            connection:Disconnect()
        end)
    end

    HOLY_SCANNER_CONNECTIONS =
        {}

    if Library
    and type(Library.Unload) == "function" then

        pcall(function()

            Library:Unload()
        end)
    end

    return true
end

HolyScannerEnv.HOLY_SCANNER_STOP =
    HolyScannerStop

--==================================================
-- [15] STARTUP
--==================================================

pcall(function()

    local seed =
        os.time()
        + math.floor(os.clock() * 1000000)
        + (
            tonumber(
                LocalPlayer
                and LocalPlayer.UserId
            )
            or 0
        )

    math.randomseed(
        seed
    )

    math.random()
    math.random()
    math.random()
end)

HolyScannerLoadSettings()

HolyScannerNormalizeState()

HolyScannerFleetReportPendingJoin()

HolyScannerStartLoadingSkip(
    "startup"
)

HolyScannerStartTeleportWatchers()

HolyScannerStartAntiAfk()

HolyScannerStartDeleteLag()

-- Headless scanner starts immediately. UI is only a control panel.
HolyScannerStartReporter()

HolyScannerStartAutoHopLoop()

HolyScannerStartShopSignalWatcher()

HolyScannerShopQueueAll()

task.spawn(function()

    local ok,
        err =
        pcall(function()

            HolyScannerCreateUI()
        end)

    if ok == true then

        HolyScannerSetStatus(
            HOLY_SCANNER_STATE.HuntMode == true
            and "Hunt Mode starting"
            or "Scanner running"
        )

        HolyScannerNotify(
            "HOLY Scanner",
            "Loaded. Toggle UI with LeftAlt.",
            4
        )

    else

        warn(
            "[HOLY SCANNER UI]",
            tostring(err)
        )
    end
end)

task.spawn(function()

    HolyScannerWaitForLoadingReady(
        80
    )

    task.wait(
        0.35
    )

    HolyScannerDeleteLagOnce()

    HolyScannerShopConnectStockSignals()

    HolyScannerShopQueueAll()

    HolyScannerShopRefreshDropdowns()
end)

--==================================================
-- HOLY SCANNER END
--==================================================
