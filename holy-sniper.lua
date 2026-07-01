--==================================================
-- HOLY PUBLIC SNIPER
-- CLEAN PUBLIC SNIPER UI SHELL
--==================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

if not game:IsLoaded() then
    game.Loaded:Wait()
end

--==================================================
-- CLEAN OLD TEST UI IF RE-EXECUTED
--==================================================

pcall(function()
    if getgenv().HOLY_PUBLIC_SNIPER_UI_LIBRARY then
        getgenv().HOLY_PUBLIC_SNIPER_UI_LIBRARY:Unload()
    end
end)

--==================================================
-- LOAD OBSIDIAN
-- Replace this with your own new repo link later.
--==================================================

local OBSIDIAN_REPO =
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local Library =
    loadstring(game:HttpGet(OBSIDIAN_REPO .. "Library.lua"))()

getgenv().HOLY_PUBLIC_SNIPER_UI_LIBRARY = Library

--==================================================
-- STATE
--==================================================

local State = {
    Activated = false,
    AutoHop = false,
    AutoJoinMode = "Off",

    SelectedPet = "Raccoon",
    SelectedSizes = { "Any" },
    SelectedVariants = { "Any" },
    MaxPrice = "0",
    Priority = "High",

    JoinPet = "Raccoon",
    JoinSizes = { "Any" },
    JoinVariants = { "Any" },
    JoinPriority = "High",

    MovementMode = "Teleport",
    BuyMode = "Instant",
    HopDelay = "3",
    AutoHopTiming = "Safe - After Loading",

    DefendBoughtPets = true,
    DefendGear = "Strawberry Sniper",
    RebuyIfStolen = true,

    ReturnAfterBuy = false,
    ReturnMode = "Teleport",

    ShowUIOnLoad = true,
    UIScale = 80,
    Accent = "Red",

    Watchlist = {},
    AutoJoinTargets = {},

    ServerRows = {},
    AutoJoinTeleporting = false,
    AutoJoinLastAttemptAt = 0,
    AutoJoinLastMatch = "None",
    AutoJoinCooldown = 10,
    AutoJoinMinTimeLeft = 10,
    AutoJoinFreshSeconds = 45,
    AutoJoinFailedJobs = {},

    ServerRefreshRunning = false,
    ServerRefreshToken = nil,
    ServerRefreshBusy = false,
    ServerLastRefreshAt = 0,
    ServerLastRefreshCount = 0,
    ServerLastRefreshError = "",
    ServerRefreshSeconds = 5,

    Status = "Ready",
    LastAction = "None",
    LoadedAt = os.clock(),
}

getgenv().HOLY_PUBLIC_SNIPER_UI_STATE = State

--==================================================
-- SETTINGS / AUTOSAVE
--==================================================

HOLY_PUBLIC_SNIPER_FOLDER =
    "HolyPublicSniper"

HOLY_PUBLIC_SNIPER_SETTINGS_FILE =
    HOLY_PUBLIC_SNIPER_FOLDER
    .. "/settings.json"

HOLY_PUBLIC_SCALE_MIN =
    60

HOLY_PUBLIC_SCALE_MAX =
    110

HOLY_PUBLIC_SCALE_VALUES = {
    "60%",
    "70%",
    "80%",
    "90%",
    "100%",
    "110%",
}

HOLY_PUBLIC_SERVER_API_BASE =
    "https://holy-server-finder-api.benjicapalot041.workers.dev"

HOLY_PUBLIC_SERVER_READ_KEY =
    (
        type(getgenv) == "function"
        and getgenv().HOLY_PUBLIC_SERVER_READ_KEY
    )
    or _G.HOLY_PUBLIC_SERVER_READ_KEY
    or "holy_read_20260701"

HOLY_PUBLIC_SERVER_REFRESH_SECONDS =
    5

HOLY_PUBLIC_SERVER_MAX_AGE_SECONDS =
    45

HOLY_PUBLIC_SERVER_ROW_LIMIT =
    150

ScaleDropdown =
    nil

ScaleApplying =
    false

HolyPublicSaveQueued =
    false

HolyPublicLoadingSettings =
    false

HolyPublicSyncingUI =
    false

Controls =
    {}

function HolyPublicCanUseFiles()

    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

function HolyPublicEnsureFolder()

    if type(makefolder) ~= "function"
    or type(isfolder) ~= "function" then

        return false
    end

    local ok =
        pcall(function()

            if not isfolder(HOLY_PUBLIC_SNIPER_FOLDER) then

                makefolder(
                    HOLY_PUBLIC_SNIPER_FOLDER
                )
            end
        end)

    return ok == true
end

function CleanText(value)

    return tostring(value or "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

function SelectionAdd(output, seen, item)

    item =
        CleanText(item)

    if item == ""
    or seen[item] == true then

        return false
    end

    seen[item] =
        true

    table.insert(
        output,
        item
    )

    return true
end

function SelectionArray(value)

    local output =
        {}

    local seen =
        {}

    if type(value) == "table" then

        for key, enabled in pairs(value) do

            if type(key) == "number" then

                SelectionAdd(
                    output,
                    seen,
                    enabled
                )

            elseif enabled == true then

                SelectionAdd(
                    output,
                    seen,
                    key
                )
            end
        end

    elseif type(value) == "string" then

        SelectionAdd(
            output,
            seen,
            value
        )
    end

    table.sort(output)

    return output
end

function ArrayText(value, fallback)

    local array =
        SelectionArray(value)

    if #array <= 0 then

        return fallback or "Any"
    end

    for _, item in ipairs(array) do

        if item == "Any" then
            return fallback or "Any"
        end
    end

    return table.concat(
        array,
        "+"
    )
end

function ReadPrice(value)

    local text =
        CleanText(value)
            :lower()
            :gsub("¢", "")
            :gsub("%$", "")
            :gsub(",", "")
            :gsub("%s+", "")

    if text == ""
    or text == "0"
    or text == "none"
    or text == "off" then

        return 0
    end

    local multiplier =
        1

    if text:find("b", 1, true) then

        multiplier =
            1000000000

    elseif text:find("m", 1, true) then

        multiplier =
            1000000

    elseif text:find("k", 1, true) then

        multiplier =
            1000
    end

    local number =
        tonumber(
            text:match("%d+%.?%d*")
        )
        or 0

    return math.max(
        0,
        math.floor(number * multiplier + 0.5)
    )
end

function FormatPrice(value)

    local number =
        ReadPrice(value)

    if number <= 0 then
        return "No Cap"
    end

    if number >= 1000000000 then
        return string.format("%.2fB", number / 1000000000)
    end

    if number >= 1000000 then
        return string.format("%.2fM", number / 1000000)
    end

    if number >= 1000 then
        return string.format("%.0fK", number / 1000)
    end

    return tostring(number)
end

function Notify(title, description)

    pcall(function()

        Library:Notify({
            Title =
                tostring(title or "HOLY"),

            Description =
                tostring(description or ""),

            Time =
                3,

            Icon =
                "bell",
        })
    end)
end

function ShortJobId()

    local jobId =
        tostring(game.JobId or "")

    if jobId == "" then
        return "Unknown"
    end

    if #jobId <= 12 then
        return jobId
    end

    return jobId:sub(1, 8)
        .. "..."
end

function ReadScale(value)

    local text =
        CleanText(value)

    local number =
        tonumber(
            text:gsub("%%", "")
                :match("%d+")
        )

    if not number then

        number =
            tonumber(State.UIScale)
            or 100
    end

    return math.clamp(
        math.floor(number + 0.5),
        HOLY_PUBLIC_SCALE_MIN,
        HOLY_PUBLIC_SCALE_MAX
    )
end

function FormatScale(value)

    return tostring(
        ReadScale(value)
    )
        .. "%"
end

function HolyPublicTextKey(value)

    return CleanText(value)
        :lower()
        :gsub("[%s_%-%[%]%(%)%.'\"_/{}:]", "")
end

function HolyPublicPriorityRank(value)

    value =
        CleanText(value)
            :lower()

    if value:find("high", 1, true) then
        return 1
    end

    if value:find("medium", 1, true) then
        return 2
    end

    return 3
end

function HolyPublicSizeRank(value)

    value =
        CleanText(value)
            :lower()

    if value == "mega"
    or value == "huge" then

        return 3
    end

    if value == "big" then
        return 2
    end

    return 1
end

function HolyPublicVariantRank(value)

    value =
        CleanText(value)
            :lower()

    if value == "rainbow" then
        return 2
    end

    return 1
end

function HolyPublicSelectionHasAny(value)

    local array =
        SelectionArray(value)

    if #array <= 0 then
        return true
    end

    for _, item in ipairs(array) do

        local key =
            HolyPublicTextKey(item)

        if key == "any"
        or key == "all"
        or key == "anypet"
        or key == "*" then

            return true
        end
    end

    return false
end

function HolyPublicSelectionContains(value, wanted)

    wanted =
        HolyPublicTextKey(wanted)

    if wanted == "" then
        return false
    end

    local array =
        SelectionArray(value)

    for _, item in ipairs(array) do

        if HolyPublicTextKey(item) == wanted then
            return true
        end
    end

    return false
end

function HolyPublicSplitPlusText(value, fallback)

    local text =
        CleanText(value)

    if text == "" then

        return {
            fallback or "Any",
        }
    end

    local output =
        {}

    local seen =
        {}

    for part in text:gmatch("[^%+,%|/;]+") do

        part =
            CleanText(part)

        if part ~= ""
        and seen[part] ~= true then

            seen[part] =
                true

            table.insert(
                output,
                part
            )
        end
    end

    if #output <= 0 then

        table.insert(
            output,
            fallback or "Any"
        )
    end

    return output
end

function HolyPublicNormalizeAutoJoinMode(value)

    local text =
        CleanText(value)

    local lower =
        text:lower()

    if lower:find("notify", 1, true) then
        return "Notify"
    end

    if lower:find("first", 1, true) then
        return "Join First"
    end

    if lower:find("best", 1, true)
    or lower:find("join", 1, true) then

        return "Join Best"
    end

    return "Off"
end

function HolyPublicGetRowJobId(row)

    row =
        type(row) == "table"
        and row
        or {}

    return CleanText(
        row.JobId
        or row.jobId
        or row.id
        or row.ServerId
        or row.Server
        or ""
    )
end

function HolyPublicGetRowPet(row)

    row =
        type(row) == "table"
        and row
        or {}

    return CleanText(
        row.Pet
        or row.BestPet
        or row.PetName
        or row.DisplayPet
        or row.Name
        or ""
    )
end

function HolyPublicGetRowSize(row)

    row =
        type(row) == "table"
        and row
        or {}

    local size =
        CleanText(
            row.Size
            or row.PetSize
            or row.DisplaySize
            or row.ScaleType
            or ""
        )

    if size == "Mega" then
        size = "Huge"
    end

    if size == "" then
        size = "Normal"
    end

    return size
end

function HolyPublicGetRowVariant(row)

    row =
        type(row) == "table"
        and row
        or {}

    local variant =
        CleanText(
            row.Variant
            or row.Mutation
            or row.PetType
            or row.Type
            or ""
        )

    local lower =
        variant:lower()

    if lower == ""
    or lower == "regular"
    or lower == "normal" then

        return "Normal"
    end

    if lower == "rainbow" then
        return "Rainbow"
    end

    return variant
end

function HolyPublicGetRowPlaying(row)

    row =
        type(row) == "table"
        and row
        or {}

    return tonumber(
        row.Playing
        or row.playing
        or row.Players
        or row.PlayerCount
        or 0
    )
    or 0
end

function HolyPublicGetRowMaxPlayers(row)

    row =
        type(row) == "table"
        and row
        or {}

    local maxPlayers =
        tonumber(
            row.MaxPlayers
            or row.maxPlayers
            or row.Max
            or Players.MaxPlayers
            or 8
        )
        or 8

    return math.max(
        1,
        maxPlayers
    )
end

function HolyPublicGetRowTimeLeft(row)

    row =
        type(row) == "table"
        and row
        or {}

    local timeLeft =
        tonumber(
            row.TimeLeft
            or row.timeLeft
            or row.Left
            or row.SecondsLeft
            or 0
        )
        or 0

    local expiresAt =
        tonumber(
            row.ExpiresAt
            or row.expiresAt
            or 0
        )
        or 0

    if timeLeft <= 0
    and expiresAt > 0 then

        timeLeft =
            expiresAt - os.time()
    end

    return math.floor(
        timeLeft
    )
end

function HolyPublicGetRowFreshAge(row)

    row =
        type(row) == "table"
        and row
        or {}

    local reportedAt =
        tonumber(
            row.ReportedAt
            or row.reportedAt
            or row.UpdatedAt
            or row.updatedAt
            or row.CreatedAt
            or row.createdAt
            or 0
        )
        or 0

    if reportedAt <= 0 then
        return 0
    end

    return math.max(
        0,
        os.time() - reportedAt
    )
end

function HolyPublicNormalizeServerRow(row)

    row =
        type(row) == "table"
        and row
        or {}

    local jobId =
        HolyPublicGetRowJobId(row)

    local pet =
        HolyPublicGetRowPet(row)

    local size =
        HolyPublicGetRowSize(row)

    local variant =
        HolyPublicGetRowVariant(row)

    local playing =
        HolyPublicGetRowPlaying(row)

    local maxPlayers =
        HolyPublicGetRowMaxPlayers(row)

    local timeLeft =
        HolyPublicGetRowTimeLeft(row)

    local reportedAt =
        tonumber(
            row.ReportedAt
            or row.reportedAt
            or row.UpdatedAt
            or row.updatedAt
            or os.time()
        )
        or os.time()

    return {
        JobId =
            jobId,

        PlaceId =
            tonumber(row.PlaceId or row.placeId)
            or game.PlaceId,

        Pet =
            pet,

        Size =
            size,

        Variant =
            variant,

        Rarity =
            CleanText(row.Rarity or row.rarity or ""),

        Playing =
            playing,

        MaxPlayers =
            maxPlayers,

        FreeSlots =
            math.max(
                0,
                maxPlayers - playing
            ),

        TimeLeft =
            timeLeft,

        ReportedAt =
            reportedAt,

        Source =
            CleanText(row.Source or row.source or "Unknown"),

        Preview =
            row.Preview == true,

        Raw =
            row,
    }
end

function HolyPublicGetServerReadKey()

    return CleanText(
        (
            type(getgenv) == "function"
            and getgenv().HOLY_PUBLIC_SERVER_READ_KEY
        )
        or _G.HOLY_PUBLIC_SERVER_READ_KEY
        or HOLY_PUBLIC_SERVER_READ_KEY
        or ""
    )
end

function HolyPublicGetRequestFunction()

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

    local env =
        type(getgenv) == "function"
        and getgenv()
        or _G

    if type(env) == "table" then

        if type(env.request) == "function" then
            return env.request
        end

        if type(env.http_request) == "function" then
            return env.http_request
        end
    end

    return nil
end

function HolyPublicAppendQuery(url, key, value)

    url =
        tostring(url or "")

    key =
        tostring(key or "")

    value =
        tostring(value or "")

    if key == "" then
        return url
    end

    local separator =
        url:find("?", 1, true)
        and "&"
        or "?"

    return url
        .. separator
        .. HttpService:UrlEncode(key)
        .. "="
        .. HttpService:UrlEncode(value)
end

function HolyPublicHttpGetJson(url, headers)

    url =
        CleanText(url)

    headers =
        type(headers) == "table"
        and headers
        or {}

    if url == "" then
        return nil, "empty url"
    end

    local requestFunction =
        HolyPublicGetRequestFunction()

    if type(requestFunction) == "function" then

        local ok,
            response =
            pcall(function()

                return requestFunction({
                    Url =
                        url,

                    Method =
                        "GET",

                    Headers =
                        headers,
                })
            end)

        if ok ~= true then

            return nil,
                "request failed: "
                .. tostring(response)
        end

        local body =
            nil

        local status =
            200

        if type(response) == "string" then

            body =
                response

        elseif type(response) == "table" then

            body =
                response.Body
                or response.body
                or response.ResponseBody
                or response.responseBody

            status =
                tonumber(
                    response.StatusCode
                    or response.statusCode
                    or response.Status
                    or response.status
                    or 200
                )
                or 200
        end

        if status < 200
        or status >= 300 then

            return nil,
                "http "
                .. tostring(status)
        end

        if type(body) ~= "string"
        or body == "" then

            return nil,
                "empty response"
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

            return nil,
                "json decode failed"
        end

        return data,
            "ok"
    end

    local fallbackUrl =
        url

    local key =
        headers["x-api-key"]
        or headers["X-API-Key"]
        or ""

    if key ~= "" then

        fallbackUrl =
            HolyPublicAppendQuery(
                fallbackUrl,
                "key",
                key
            )
    end

    local ok,
        body =
        pcall(function()

            return game:HttpGet(
                fallbackUrl,
                true
            )
        end)

    if ok ~= true then

        return nil,
            "HttpGet failed: "
            .. tostring(body)
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

        return nil,
            "json decode failed"
    end

    return data,
        "ok"
end

function HolyPublicBuildServerListUrl()

    local base =
        CleanText(
            HOLY_PUBLIC_SERVER_API_BASE
        )

    if base == "" then
        return ""
    end

    base =
        base:gsub(
            "/+$",
            ""
        )

    local url =
        base
        .. "/servers"

    url =
        HolyPublicAppendQuery(
            url,
            "placeId",
            tostring(game.PlaceId)
        )

    url =
        HolyPublicAppendQuery(
            url,
            "hideFull",
            "1"
        )

    url =
        HolyPublicAppendQuery(
            url,
            "maxAge",
            tostring(HOLY_PUBLIC_SERVER_MAX_AGE_SECONDS)
        )

    url =
        HolyPublicAppendQuery(
            url,
            "limit",
            tostring(HOLY_PUBLIC_SERVER_ROW_LIMIT)
        )

    return url
end

function HolyPublicBackendPetToServerRow(server, pet)

    server =
        type(server) == "table"
        and server
        or {}

    pet =
        type(pet) == "table"
        and pet
        or {}

    local now =
        os.time()

    local expiresAt =
        tonumber(
            pet.ExpiresAt
            or pet.expiresAt
            or server.ExpiresAt
            or server.expiresAt
            or 0
        )
        or 0

    local timeLeft =
        tonumber(
            pet.TimeLeft
            or pet.TimeLeftNumber
            or pet.timeLeft
            or 0
        )
        or 0

    if timeLeft <= 0
    and expiresAt > 0 then

        timeLeft =
            expiresAt - now
    end

    local petName =
        CleanText(
            pet.Pet
            or pet.PetName
            or pet.Name
            or server.BestPet
            or server.bestPet
            or ""
        )

    if petName == "" then
        return nil
    end

    local variant =
        CleanText(
            pet.Variant
            or pet.variant
            or pet.Mutation
            or pet.mutation
            or "Normal"
        )

    if variant == "Regular" then
        variant = "Normal"
    end

    local size =
        CleanText(
            pet.Size
            or pet.size
            or "Normal"
        )

    if size == "Mega" then
        size = "Huge"
    end

    return HolyPublicNormalizeServerRow({
        JobId =
            server.JobId
            or server.jobId
            or server.Id
            or server.id
            or server.Key
            or server.key,

        PlaceId =
            server.PlaceId
            or server.placeId
            or game.PlaceId,

        Pet =
            petName,

        Size =
            size,

        Variant =
            variant,

        Rarity =
            pet.Rarity
            or pet.rarity
            or server.Rarity
            or server.rarity
            or "",

        Playing =
            server.Playing
            or server.playing
            or 0,

        MaxPlayers =
            server.MaxPlayers
            or server.maxPlayers
            or Players.MaxPlayers
            or 8,

        TimeLeft =
            timeLeft,

        ExpiresAt =
            expiresAt,

        ReportedAt =
            server.ReportedAt
            or server.reportedAt
            or server.UpdatedAt
            or server.updatedAt
            or now,

        Source =
            server.Source
            or server.source
            or "Cloudflare",
    })
end

function HolyPublicConvertBackendServer(server)

    server =
        type(server) == "table"
        and server
        or {}

    local rows =
        {}

    local pets =
        type(server.Pets) == "table"
        and server.Pets
        or type(server.pets) == "table"
        and server.pets
        or {}

    for _, pet in ipairs(pets) do

        local row =
            HolyPublicBackendPetToServerRow(
                server,
                pet
            )

        if type(row) == "table"
        and row.JobId ~= ""
        and row.Pet ~= "" then

            table.insert(
                rows,
                row
            )
        end
    end

    if #rows <= 0 then

        local fallbackPet =
            CleanText(
                server.BestPet
                or server.bestPet
                or ""
            )

        if fallbackPet ~= "" then

            local row =
                HolyPublicBackendPetToServerRow(
                    server,
                    {
                        Pet =
                            fallbackPet,

                        Size =
                            "Normal",

                        Variant =
                            "Normal",

                        Rarity =
                            server.Rarity
                            or "",
                    }
                )

            if type(row) == "table"
            and row.JobId ~= "" then

                table.insert(
                    rows,
                    row
                )
            end
        end
    end

    return rows
end

function HolyPublicConvertBackendServers(data)

    data =
        type(data) == "table"
        and data
        or {}

    local servers =
        type(data.servers) == "table"
        and data.servers
        or type(data.Servers) == "table"
        and data.Servers
        or type(data.data) == "table"
        and data.data
        or {}

    local output =
        {}

    local seen =
        {}

    for _, server in ipairs(servers) do

        local rows =
            HolyPublicConvertBackendServer(
                server
            )

        for _, row in ipairs(rows) do

            local key =
                tostring(row.JobId)
                .. "|"
                .. HolyPublicTextKey(row.Pet)
                .. "|"
                .. HolyPublicTextKey(row.Size)
                .. "|"
                .. HolyPublicTextKey(row.Variant)

            if seen[key] ~= true then

                seen[key] =
                    true

                table.insert(
                    output,
                    row
                )
            end
        end
    end

    return output
end

function HolyPublicShouldRefreshServers()

    return State.AutoJoinMode ~= "Off"
        or State.Activated == true
end

function HolyPublicRefreshServerRows(allowTeleport)

    if State.ServerRefreshBusy == true then
        return false, "Refresh already running"
    end

    local readKey =
        HolyPublicGetServerReadKey()

    if readKey == "" then

        State.ServerLastRefreshError =
            "Server access missing"

        State.LastAction =
            "Server scan unavailable"

        RefreshStatus()

        Notify(
            "Server Scan",
            "Server access is not configured."
        )

        return false,
            "Server access missing"
    end

    local url =
        HolyPublicBuildServerListUrl()

    if url == "" then

        State.ServerLastRefreshError =
            "Missing API base"

        State.LastAction =
            "Server scan missing API base"

        RefreshStatus()

        return false,
            "Missing API base"
    end

    State.ServerRefreshBusy =
        true

    State.LastAction =
        "Refreshing servers..."

    RefreshStatus()

    local data,
        reason =
        HolyPublicHttpGetJson(
            url,
            {
                ["accept"] =
                    "application/json",

                ["cache-control"] =
                    "no-cache",

                ["x-api-key"] =
                    readKey,
            }
        )

    State.ServerRefreshBusy =
        false

    if type(data) ~= "table" then

        State.ServerLastRefreshError =
            tostring(reason or "request failed")

        State.LastAction =
            "Server refresh failed: "
            .. State.ServerLastRefreshError

        RefreshStatus()

        return false,
            State.ServerLastRefreshError
    end

    if data.ok ~= true then

        State.ServerLastRefreshError =
            tostring(
                data.error
                or data.message
                or "backend error"
            )

        State.LastAction =
            "Server refresh failed: "
            .. State.ServerLastRefreshError

        RefreshStatus()

        return false,
            State.ServerLastRefreshError
    end

    local rows =
        HolyPublicConvertBackendServers(
            data
        )

    State.ServerLastRefreshAt =
        os.clock()

    State.ServerLastRefreshCount =
        #rows

    State.ServerLastRefreshError =
        ""

    local matched,
        matchReason =
        HolyPublicAutoJoinUpdateServerRows(
            rows,
            allowTeleport == true
        )

    if matched ~= true then

        State.LastAction =
            "Server scan: "
            .. tostring(#rows)
            .. " rows · "
            .. tostring(matchReason)

        RefreshStatus()
    end

    return matched,
        matchReason
end

function HolyPublicStartServerRefresh()

    if State.ServerRefreshRunning == true then
        return false
    end

    State.ServerRefreshRunning =
        true

    State.ServerRefreshToken =
        {}

    local token =
        State.ServerRefreshToken

    task.spawn(function()

        while State.ServerRefreshRunning == true
        and State.ServerRefreshToken == token do

            if HolyPublicShouldRefreshServers() == true then

                pcall(function()

                    HolyPublicRefreshServerRows(
                        true
                    )
                end)

                task.wait(
                    math.max(
                        2,
                        tonumber(State.ServerRefreshSeconds)
                        or HOLY_PUBLIC_SERVER_REFRESH_SECONDS
                    )
                )

            else

                task.wait(
                    1
                )
            end
        end

        if State.ServerRefreshToken == token then

            State.ServerRefreshRunning =
                false
        end
    end)

    return true
end

function HolyPublicStopServerRefresh(reason)

    State.ServerRefreshToken =
        nil

    State.ServerRefreshRunning =
        false

    State.ServerRefreshBusy =
        false

    State.LastAction =
        tostring(reason or "Server refresh stopped")

    RefreshStatus()

    return true
end

function HolyPublicScanServers()

    local matched,
        reason =
        HolyPublicRefreshServerRows(
            false
        )

    Notify(
        "Server Scan",
        matched == true
        and (
            "Matched "
            .. tostring(State.AutoJoinLastMatch)
        )
        or tostring(reason)
    )

    return matched,
        reason
end

function HolyPublicNormalizeState()

    State.Activated =
        State.Activated == true

    State.AutoHop =
        State.AutoHop == true

    State.AutoJoinMode =
        HolyPublicNormalizeAutoJoinMode(
            State.AutoJoinMode
        )

    State.SelectedPet =
        CleanText(State.SelectedPet)

    if State.SelectedPet == "" then
        State.SelectedPet = "Raccoon"
    end

    State.SelectedSizes =
        SelectionArray(State.SelectedSizes)

    if #State.SelectedSizes <= 0 then
        State.SelectedSizes = { "Any" }
    end

    State.SelectedVariants =
        SelectionArray(State.SelectedVariants)

    if #State.SelectedVariants <= 0 then
        State.SelectedVariants = { "Any" }
    end

    State.MaxPrice =
        tostring(ReadPrice(State.MaxPrice))

    State.Priority =
        CleanText(State.Priority)

    if State.Priority == "" then
        State.Priority = "High"
    end

    State.MovementMode =
        CleanText(State.MovementMode)

    if State.MovementMode ~= "Walk" then
        State.MovementMode = "Teleport"
    end

    State.BuyMode =
        CleanText(State.BuyMode)

    if State.BuyMode ~= "Hold" then
        State.BuyMode = "Instant"
    end

    State.HopDelay =
        tostring(
            math.max(
                0,
                tonumber(tostring(State.HopDelay):match("%d+%.?%d*"))
                or 3
            )
        )

    State.AutoHopTiming =
        CleanText(State.AutoHopTiming)

    if State.AutoHopTiming ~= "Fast - During Loading" then
        State.AutoHopTiming = "Safe - After Loading"
    end

    State.DefendBoughtPets =
        State.DefendBoughtPets == true

    State.DefendGear =
        CleanText(State.DefendGear)

    if State.DefendGear ~= "Shovel" then
        State.DefendGear = "Strawberry Sniper"
    end

    State.RebuyIfStolen =
        State.RebuyIfStolen == true

    State.ReturnAfterBuy =
        State.ReturnAfterBuy == true

    State.ReturnMode =
        CleanText(State.ReturnMode)

    if State.ReturnMode ~= "Walk" then
        State.ReturnMode = "Teleport"
    end

    State.ShowUIOnLoad =
        State.ShowUIOnLoad ~= false

    State.UIScale =
        ReadScale(State.UIScale)

    State.Accent =
        CleanText(State.Accent)

    if State.Accent == "" then
        State.Accent = "Red"
    end

    State.JoinPet =
        CleanText(State.JoinPet)

    if State.JoinPet == "" then
        State.JoinPet = "Raccoon"
    end

    State.JoinSizes =
        SelectionArray(State.JoinSizes)

    if #State.JoinSizes <= 0 then
        State.JoinSizes = { "Any" }
    end

    State.JoinVariants =
        SelectionArray(State.JoinVariants)

    if #State.JoinVariants <= 0 then
        State.JoinVariants = { "Any" }
    end

    State.JoinPriority =
        CleanText(State.JoinPriority)

    if State.JoinPriority == "" then
        State.JoinPriority = "High"
    end

    State.Watchlist =
        type(State.Watchlist) == "table"
        and State.Watchlist
        or {}

    State.AutoJoinTargets =
        type(State.AutoJoinTargets) == "table"
        and State.AutoJoinTargets
        or {}

    State.Status =
        CleanText(State.Status)

    if State.Status == "" then
        State.Status = "Ready"
    end

    State.LastAction =
        CleanText(State.LastAction)

    if State.LastAction == "" then
        State.LastAction = "None"
    end

    State.LoadedAt =
        tonumber(State.LoadedAt)
        or os.clock()

    return State
end

function HolyPublicBuildSavePayload()

    HolyPublicNormalizeState()

    return {
        Activated =
            State.Activated == true,

        AutoHop =
            State.AutoHop == true,

        AutoJoinMode =
            State.AutoJoinMode,

        SelectedPet =
            State.SelectedPet,

        SelectedSizes =
            State.SelectedSizes,

        SelectedVariants =
            State.SelectedVariants,

        MaxPrice =
            State.MaxPrice,

        Priority =
            State.Priority,

        JoinPet =
            State.JoinPet,

        JoinSizes =
            State.JoinSizes,

        JoinVariants =
            State.JoinVariants,

        JoinPriority =
            State.JoinPriority,

        MovementMode =
            State.MovementMode,

        BuyMode =
            State.BuyMode,

        HopDelay =
            State.HopDelay,

        AutoHopTiming =
            State.AutoHopTiming,

        DefendBoughtPets =
            State.DefendBoughtPets == true,

        DefendGear =
            State.DefendGear,

        RebuyIfStolen =
            State.RebuyIfStolen == true,

        ReturnAfterBuy =
            State.ReturnAfterBuy == true,

        ReturnMode =
            State.ReturnMode,

        ShowUIOnLoad =
            State.ShowUIOnLoad == true,

        UIScale =
            State.UIScale,

        Accent =
            State.Accent,

        Watchlist =
            State.Watchlist,

        AutoJoinTargets =
            State.AutoJoinTargets,
    }
end

function HolyPublicApplyLoadedSettings(data)

    if type(data) ~= "table" then
        return false
    end

    if type(data.Activated) == "boolean" then
        State.Activated = data.Activated
    end

    if type(data.AutoHop) == "boolean" then
        State.AutoHop = data.AutoHop
    end

    if data.AutoJoinMode ~= nil then
        State.AutoJoinMode = tostring(data.AutoJoinMode)
    end

    if data.SelectedPet ~= nil then
        State.SelectedPet = tostring(data.SelectedPet)
    end

    if type(data.SelectedSizes) == "table" then
        State.SelectedSizes = data.SelectedSizes
    end

    if type(data.SelectedVariants) == "table" then
        State.SelectedVariants = data.SelectedVariants
    end

    if data.MaxPrice ~= nil then
        State.MaxPrice = tostring(data.MaxPrice)
    end

    if data.Priority ~= nil then
        State.Priority = tostring(data.Priority)
    end

    if data.JoinPet ~= nil then
        State.JoinPet = tostring(data.JoinPet)
    end

    if type(data.JoinSizes) == "table" then
        State.JoinSizes = data.JoinSizes
    end

    if type(data.JoinVariants) == "table" then
        State.JoinVariants = data.JoinVariants
    end

    if data.JoinPriority ~= nil then
        State.JoinPriority = tostring(data.JoinPriority)
    end

    if data.MovementMode ~= nil then
        State.MovementMode = tostring(data.MovementMode)
    end

    if data.BuyMode ~= nil then
        State.BuyMode = tostring(data.BuyMode)
    end

    if data.HopDelay ~= nil then
        State.HopDelay = tostring(data.HopDelay)
    end

    if data.AutoHopTiming ~= nil then
        State.AutoHopTiming = tostring(data.AutoHopTiming)
    end

    if type(data.DefendBoughtPets) == "boolean" then
        State.DefendBoughtPets = data.DefendBoughtPets
    end

    if data.DefendGear ~= nil then
        State.DefendGear = tostring(data.DefendGear)
    end

    if type(data.RebuyIfStolen) == "boolean" then
        State.RebuyIfStolen = data.RebuyIfStolen
    end

    if type(data.ReturnAfterBuy) == "boolean" then
        State.ReturnAfterBuy = data.ReturnAfterBuy
    end

    if data.ReturnMode ~= nil then
        State.ReturnMode = tostring(data.ReturnMode)
    end

    if type(data.ShowUIOnLoad) == "boolean" then
        State.ShowUIOnLoad = data.ShowUIOnLoad
    end

    if data.UIScale ~= nil then
        State.UIScale = data.UIScale
    end

    if data.Accent ~= nil then
        State.Accent = tostring(data.Accent)
    end

    if type(data.Watchlist) == "table" then
        State.Watchlist = data.Watchlist
    end

    if type(data.AutoJoinTargets) == "table" then
        State.AutoJoinTargets = data.AutoJoinTargets
    end

    HolyPublicNormalizeState()

    return true
end

function HolyPublicLoadSettings()

    if HolyPublicCanUseFiles() ~= true then
        return false
    end

    local exists =
        false

    pcall(function()

        exists =
            isfile(
                HOLY_PUBLIC_SNIPER_SETTINGS_FILE
            )
    end)

    if exists ~= true then
        return false
    end

    local ok,
        raw =
        pcall(function()

            return readfile(
                HOLY_PUBLIC_SNIPER_SETTINGS_FILE
            )
        end)

    if ok ~= true
    or type(raw) ~= "string"
    or raw == "" then

        return false
    end

    local decodeOk,
        data =
        pcall(function()

            return HttpService:JSONDecode(raw)
        end)

    if decodeOk ~= true
    or type(data) ~= "table" then

        return false
    end

    HolyPublicLoadingSettings =
        true

    HolyPublicApplyLoadedSettings(
        data
    )

    HolyPublicLoadingSettings =
        false

    return true
end

function HolyPublicSaveSettings()

    if HolyPublicCanUseFiles() ~= true then
        return false
    end

    HolyPublicEnsureFolder()

    local payload =
        HolyPublicBuildSavePayload()

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
                HOLY_PUBLIC_SNIPER_SETTINGS_FILE,
                encoded
            )
        end)

    return writeOk == true
end

function HolyPublicQueueSave()

    if HolyPublicLoadingSettings == true
    or HolyPublicSyncingUI == true then

        return false
    end

    if HolyPublicSaveQueued == true then
        return false
    end

    HolyPublicSaveQueued =
        true

    task.delay(0.25, function()

        HolyPublicSaveQueued =
            false

        HolyPublicSaveSettings()
    end)

    return true
end

function EncodeConfig()

    local ok,
        encoded =
        pcall(function()

            return HttpService:JSONEncode(
                HolyPublicBuildSavePayload()
            )
        end)

    if ok == true
    and type(encoded) == "string" then

        return encoded
    end

    return "{}"
end

function CopyText(text)

    local fn =
        setclipboard
        or toclipboard
        or set_clipboard

    if type(fn) ~= "function" then

        Notify(
            "Clipboard",
            "Clipboard is not supported by this executor."
        )

        return false
    end

    pcall(function()

        fn(
            tostring(text or "")
        )
    end)

    Notify(
        "Clipboard",
        "Copied."
    )

    return true
end

function ApplyUIScale(value, silent)

    local scale =
        ReadScale(value)

    State.UIScale =
        scale

    local ok,
        err =
        pcall(function()

            Library:SetDPIScale(
                scale
            )
        end)

    if ScaleDropdown
    and ScaleApplying ~= true
    and type(ScaleDropdown.SetValue) == "function" then

        ScaleApplying =
            true

        pcall(function()

            ScaleDropdown:SetValue(
                FormatScale(scale)
            )
        end)

        ScaleApplying =
            false
    end

    if silent ~= true then

        if ok == true then

            Notify(
                "UI Scale",
                "Set to "
                    .. FormatScale(scale)
                    .. "."
            )

        else

            Notify(
                "UI Scale",
                "Failed to apply scale: "
                    .. tostring(err)
            )
        end
    end

    HolyPublicQueueSave()

    return ok == true
end

function ApplyAccent(value, silent)

    local accent =
        CleanText(value)

    if accent == "" then
        accent = "Red"
    end

    State.Accent =
        accent

    local accentMap = {
        Red = Color3.fromRGB(232, 45, 67),
        Blue = Color3.fromRGB(80, 155, 255),
        Purple = Color3.fromRGB(170, 90, 255),
        Green = Color3.fromRGB(80, 220, 120),
        Gold = Color3.fromRGB(255, 208, 74),
        White = Color3.fromRGB(245, 245, 245),
    }

    local color =
        accentMap[accent]
        or accentMap.Red

    pcall(function()

        Library.Scheme.AccentColor =
            color

        Library:UpdateColorsUsingRegistry()
    end)

    if silent ~= true then

        Notify(
            "Theme",
            "Accent set to "
                .. accent
                .. "."
        )
    end

    HolyPublicQueueSave()

    return true
end

function HolyPublicSetPet(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.SelectedPet =
        tostring(value or "Raccoon")

    State.LastAction =
        "Selected pet: "
        .. State.SelectedPet

    RefreshStatus()
end

function HolyPublicSetSizes(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.SelectedSizes =
        SelectionArray(value)

    if #State.SelectedSizes <= 0 then
        State.SelectedSizes = { "Any" }
    end

    State.LastAction =
        "Updated size filter"

    RefreshStatus()
end

function HolyPublicSetVariants(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.SelectedVariants =
        SelectionArray(value)

    if #State.SelectedVariants <= 0 then
        State.SelectedVariants = { "Any" }
    end

    State.LastAction =
        "Updated variant filter"

    RefreshStatus()
end

function HolyPublicSetMaxPrice(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.MaxPrice =
        tostring(
            ReadPrice(value)
        )

    State.LastAction =
        "Max price: "
        .. FormatPrice(State.MaxPrice)

    RefreshStatus()
end

function HolyPublicSetPriority(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.Priority =
        tostring(value or "High")

    State.LastAction =
        "Priority: "
        .. State.Priority

    RefreshStatus()
end

function HolyPublicSetJoinPet(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.JoinPet =
        tostring(value or "Raccoon")

    State.LastAction =
        "Auto join pet: "
        .. State.JoinPet

    RefreshStatus()
end

function HolyPublicSetJoinSizes(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.JoinSizes =
        SelectionArray(value)

    if #State.JoinSizes <= 0 then
        State.JoinSizes = { "Any" }
    end

    State.LastAction =
        "Updated auto join size"

    RefreshStatus()
end

function HolyPublicSetJoinVariants(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.JoinVariants =
        SelectionArray(value)

    if #State.JoinVariants <= 0 then
        State.JoinVariants = { "Any" }
    end

    State.LastAction =
        "Updated auto join mutation"

    RefreshStatus()
end

function HolyPublicSetJoinPriority(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.JoinPriority =
        tostring(value or "High")

    State.LastAction =
        "Auto join priority: "
        .. State.JoinPriority

    RefreshStatus()
end

function HolyPublicBuildAutoJoinTarget(rawTarget)

    rawTarget =
        type(rawTarget) == "table"
        and rawTarget
        or {}

    local pet =
        CleanText(
            rawTarget.Pet
            or rawTarget.JoinPet
            or "Any Pet"
        )

    if pet == "" then
        pet = "Any Pet"
    end

    local sizes =
        rawTarget.Sizes
        or rawTarget.Size
        or rawTarget.JoinSizes
        or {
            "Any",
        }

    if type(sizes) == "string" then
        sizes =
            HolyPublicSplitPlusText(
                sizes,
                "Any"
            )
    end

    sizes =
        SelectionArray(sizes)

    if #sizes <= 0 then
        sizes = { "Any" }
    end

    local variants =
        rawTarget.Variants
        or rawTarget.Variant
        or rawTarget.Mutation
        or rawTarget.JoinVariants
        or {
            "Any",
        }

    if type(variants) == "string" then
        variants =
            HolyPublicSplitPlusText(
                variants,
                "Any"
            )
    end

    variants =
        SelectionArray(variants)

    if #variants <= 0 then
        variants = { "Any" }
    end

    local priority =
        CleanText(
            rawTarget.Priority
            or rawTarget.JoinPriority
            or "High"
        )

    if priority == "" then
        priority = "High"
    end

    return {
        Pet =
            pet,

        Sizes =
            sizes,

        Variants =
            variants,

        Priority =
            priority,

        PriorityRank =
            HolyPublicPriorityRank(
                priority
            ),
    }
end

function HolyPublicBuildAutoJoinTargets()

    local output =
        {}

    State.AutoJoinTargets =
        type(State.AutoJoinTargets) == "table"
        and State.AutoJoinTargets
        or {}

    for _, rawTarget in ipairs(State.AutoJoinTargets) do

        local target =
            HolyPublicBuildAutoJoinTarget(
                rawTarget
            )

        if target.Pet ~= "" then

            table.insert(
                output,
                target
            )
        end
    end

    table.sort(output, function(a, b)

        if a.PriorityRank ~= b.PriorityRank then
            return a.PriorityRank < b.PriorityRank
        end

        return tostring(a.Pet) < tostring(b.Pet)
    end)

    return output
end

function HolyPublicRowMatchesAutoJoinTarget(row, target)

    row =
        HolyPublicNormalizeServerRow(row)

    target =
        HolyPublicBuildAutoJoinTarget(target)

    if row.JobId == ""
    or row.JobId == tostring(game.JobId) then

        return false
    end

    if row.Playing >= row.MaxPlayers then
        return false
    end

    local timeLeft =
        tonumber(row.TimeLeft)
        or 0

    local minTimeLeft =
        tonumber(State.AutoJoinMinTimeLeft)
        or 0

    if timeLeft > 0
    and minTimeLeft > 0
    and timeLeft < minTimeLeft then

        return false
    end

    local freshAge =
        HolyPublicGetRowFreshAge(row)

    local freshSeconds =
        tonumber(State.AutoJoinFreshSeconds)
        or 45

    if freshAge > freshSeconds then
        return false
    end

    local failed =
        type(State.AutoJoinFailedJobs) == "table"
        and State.AutoJoinFailedJobs
        or {}

    local failedUntil =
        tonumber(
            failed[row.JobId]
        )
        or 0

    if failedUntil > os.clock() then
        return false
    end

    local targetPet =
        HolyPublicTextKey(target.Pet)

    local rowPet =
        HolyPublicTextKey(row.Pet)

    if targetPet ~= "anypet"
    and targetPet ~= "any"
    and targetPet ~= "all"
    and targetPet ~= "*"
    and targetPet ~= rowPet then

        return false
    end

    if HolyPublicSelectionHasAny(target.Sizes) ~= true
    and HolyPublicSelectionContains(target.Sizes, row.Size) ~= true then

        return false
    end

    if HolyPublicSelectionHasAny(target.Variants) ~= true
    and HolyPublicSelectionContains(target.Variants, row.Variant) ~= true then

        return false
    end

    return true
end

function HolyPublicScoreAutoJoinRow(row, target)

    row =
        HolyPublicNormalizeServerRow(row)

    target =
        HolyPublicBuildAutoJoinTarget(target)

    local score =
        0

    score =
        score
        + ((4 - HolyPublicPriorityRank(target.Priority)) * 100000)

    score =
        score
        + HolyPublicVariantRank(row.Variant) * 10000

    score =
        score
        + HolyPublicSizeRank(row.Size) * 5000

    local timeLeft =
        tonumber(row.TimeLeft)
        or 0

    score =
        score
        + math.clamp(
            timeLeft,
            0,
            300
        ) * 8

    local freeSlots =
        tonumber(row.FreeSlots)
        or math.max(
            0,
            row.MaxPlayers - row.Playing
        )

    score =
        score
        + math.clamp(
            freeSlots,
            0,
            8
        ) * 50

    local age =
        HolyPublicGetRowFreshAge(row)

    score =
        score
        - math.clamp(
            age,
            0,
            120
        ) * 10

    return score
end

function HolyPublicDescribeAutoJoinRow(row)

    row =
        HolyPublicNormalizeServerRow(row)

    local parts =
        {}

    if row.Size ~= ""
    and row.Size ~= "Normal"
    and row.Size ~= "Any" then

        table.insert(
            parts,
            row.Size
        )
    end

    if row.Variant ~= ""
    and row.Variant ~= "Normal"
    and row.Variant ~= "Any" then

        table.insert(
            parts,
            row.Variant
        )
    end

    table.insert(
        parts,
        row.Pet ~= ""
        and row.Pet
        or "Unknown Pet"
    )

    return table.concat(
        parts,
        " "
    )
        .. " · "
        .. tostring(row.Playing)
        .. "/"
        .. tostring(row.MaxPlayers)
end

function HolyPublicFindAutoJoinServer(rows)

    rows =
        type(rows) == "table"
        and rows
        or State.ServerRows
        or {}

    local targets =
        HolyPublicBuildAutoJoinTargets()

    if #targets <= 0 then
        return nil, "No auto join targets"
    end

    local mode =
        HolyPublicNormalizeAutoJoinMode(
            State.AutoJoinMode
        )

    if mode == "Off" then
        return nil, "Auto join off"
    end

    local best =
        nil

    local bestScore =
        -math.huge

    for rowIndex, rawRow in ipairs(rows) do

        local row =
            HolyPublicNormalizeServerRow(rawRow)

        for targetIndex, target in ipairs(targets) do

            if HolyPublicRowMatchesAutoJoinTarget(
                row,
                target
            ) == true then

                local score =
                    HolyPublicScoreAutoJoinRow(
                        row,
                        target
                    )

                if mode == "Join First" then

                    return {
                        Row =
                            row,

                        Target =
                            target,

                        Score =
                            score,

                        RowIndex =
                            rowIndex,

                        TargetIndex =
                            targetIndex,
                    },
                    "first"
                end

                if score > bestScore then

                    bestScore =
                        score

                    best = {
                        Row =
                            row,

                        Target =
                            target,

                        Score =
                            score,

                        RowIndex =
                            rowIndex,

                        TargetIndex =
                            targetIndex,
                    }
                end
            end
        end
    end

    if best == nil then
        return nil, "No matching server"
    end

    return best, "best"
end

function HolyPublicJoinServerRow(row)

    row =
        HolyPublicNormalizeServerRow(row)

    if row.JobId == "" then
        return false, "Missing JobId"
    end

    if row.JobId == tostring(game.JobId) then
        return false, "Already in server"
    end

    if row.Preview == true then
        return false, "Preview row"
    end

    if State.AutoJoinTeleporting == true then
        return false, "Already joining"
    end

    local now =
        os.clock()

    local cooldown =
        tonumber(State.AutoJoinCooldown)
        or 10

    if now - (
        tonumber(State.AutoJoinLastAttemptAt)
        or 0
    ) < cooldown then

        return false, "Cooldown"
    end

    State.AutoJoinTeleporting =
        true

    State.AutoJoinLastAttemptAt =
        now

    State.LastAction =
        "Joining server for "
        .. HolyPublicDescribeAutoJoinRow(row)

    RefreshStatus()

    local ok,
        err =
        pcall(function()

            TeleportService:TeleportToPlaceInstance(
                row.PlaceId or game.PlaceId,
                row.JobId,
                LocalPlayer
            )
        end)

    if ok ~= true then

        State.AutoJoinTeleporting =
            false

        State.AutoJoinFailedJobs =
            type(State.AutoJoinFailedJobs) == "table"
            and State.AutoJoinFailedJobs
            or {}

        State.AutoJoinFailedJobs[row.JobId] =
            os.clock() + 45

        State.LastAction =
            "Join failed: "
            .. tostring(err)

        RefreshStatus()

        return false,
            tostring(err)
    end

    Notify(
        "Auto Join",
        "Joining "
            .. HolyPublicDescribeAutoJoinRow(row)
    )

    return true,
        "queued"
end

function HolyPublicEvaluateAutoJoin(rows, allowTeleport)

    rows =
        type(rows) == "table"
        and rows
        or State.ServerRows
        or {}

    local mode =
        HolyPublicNormalizeAutoJoinMode(
            State.AutoJoinMode
        )

    State.AutoJoinMode =
        mode

    if mode == "Off" then
        return false, "Auto join off"
    end

    local match,
        reason =
        HolyPublicFindAutoJoinServer(
            rows
        )

    if type(match) ~= "table" then

        State.AutoJoinLastMatch =
            "None"

        State.LastAction =
            "Auto join: "
            .. tostring(reason)

        RefreshStatus()

        return false,
            reason
    end

    local row =
        match.Row

    State.AutoJoinLastMatch =
        HolyPublicDescribeAutoJoinRow(
            row
        )

    if mode == "Notify"
    or allowTeleport ~= true
    or row.Preview == true then

        State.LastAction =
            "Auto join match: "
            .. State.AutoJoinLastMatch

        RefreshStatus()

        Notify(
            "Auto Join Match",
            State.AutoJoinLastMatch
        )

        return true,
            "notify"
    end

    return HolyPublicJoinServerRow(
        row
    )
end

function HolyPublicAutoJoinUpdateServerRows(rows, allowTeleport)

    rows =
        type(rows) == "table"
        and rows
        or {}

    local normalized =
        {}

    for _, row in ipairs(rows) do

        local cleanRow =
            HolyPublicNormalizeServerRow(
                row
            )

        if cleanRow.JobId ~= "" then

            table.insert(
                normalized,
                cleanRow
            )
        end
    end

    State.ServerRows =
        normalized

    State.LastAction =
        "Server rows updated: "
        .. tostring(#normalized)

    RefreshStatus()

    return HolyPublicEvaluateAutoJoin(
        normalized,
        allowTeleport == true
    )
end

function HolyPublicBuildPreviewServerRows()

    local now =
        os.time()

    return {
        {
            JobId =
                "preview-raccoon-rainbow",

            PlaceId =
                game.PlaceId,

            Pet =
                "Raccoon",

            Size =
                "Normal",

            Variant =
                "Rainbow",

            Playing =
                5,

            MaxPlayers =
                8,

            TimeLeft =
                75,

            ReportedAt =
                now,

            Source =
                "Preview",

            Preview =
                true,
        },

        {
            JobId =
                "preview-unicorn-huge",

            PlaceId =
                game.PlaceId,

            Pet =
                "Unicorn",

            Size =
                "Huge",

            Variant =
                "Normal",

            Playing =
                4,

            MaxPlayers =
                8,

            TimeLeft =
                92,

            ReportedAt =
                now,

            Source =
                "Preview",

            Preview =
                true,
        },

        {
            JobId =
                "preview-dragonfly-big-rainbow",

            PlaceId =
                game.PlaceId,

            Pet =
                "Golden Dragonfly",

            Size =
                "Big",

            Variant =
                "Rainbow",

            Playing =
                6,

            MaxPlayers =
                8,

            TimeLeft =
                51,

            ReportedAt =
                now,

            Source =
                "Preview",

            Preview =
                true,
        },
    }
end

function HolyPublicAddJoinTarget()

    State.AutoJoinTargets =
        type(State.AutoJoinTargets) == "table"
        and State.AutoJoinTargets
        or {}

    local row = {
        Pet =
            State.JoinPet,

        Size =
            ArrayText(
                State.JoinSizes,
                "Any"
            ),

        Variant =
            ArrayText(
                State.JoinVariants,
                "Any"
            ),

        Priority =
            State.JoinPriority,
    }

    table.insert(
        State.AutoJoinTargets,
        row
    )

    State.LastAction =
        "Added auto join target: "
        .. row.Pet

    RefreshAutoJoinTargets()
    RefreshStatus()

    Notify(
        "Auto Join Target Added",
        row.Pet
            .. " added."
    )

    if State.AutoJoinMode ~= "Off"
    and type(State.ServerRows) == "table"
    and #State.ServerRows > 0 then

        HolyPublicEvaluateAutoJoin(
            State.ServerRows,
            true
        )
    end
end

function HolyPublicClearJoinTargets()

    State.AutoJoinTargets =
        {}

    State.LastAction =
        "Cleared auto join targets"

    RefreshAutoJoinTargets()
    RefreshStatus()

    Notify(
        "Auto Join Targets",
        "Cleared."
    )
end

function HolyPublicAddTarget()

    local row = {
        Pet =
            State.SelectedPet,

        Size =
            ArrayText(
                State.SelectedSizes,
                "Any"
            ),

        Variant =
            ArrayText(
                State.SelectedVariants,
                "Any"
            ),

        MaxPrice =
            FormatPrice(
                State.MaxPrice
            ),

        Priority =
            State.Priority,
    }

    table.insert(
        State.Watchlist,
        row
    )

    State.LastAction =
        "Added target: "
        .. row.Pet

    RefreshWatchlist()
    RefreshStatus()

    Notify(
        "Target Added",
        row.Pet
            .. " added to watchlist."
    )
end

function HolyPublicClearWatchlist()

    table.clear(
        State.Watchlist
    )

    State.LastAction =
        "Cleared watchlist"

    RefreshWatchlist()
    RefreshStatus()

    Notify(
        "Watchlist",
        "Cleared."
    )
end

function HolyPublicPreviewScan()

    return HolyPublicScanServers()
end

function HolyPublicPreviewBuy()

    if #State.Watchlist <= 0 then

        Notify(
            "Preview Buy",
            "Add a target first."
        )

        return
    end

    State.LastAction =
        "Preview buy: "
        .. tostring(State.Watchlist[1].Pet)

    RefreshStatus()

    Notify(
        "Preview Buy",
        "Buy preview completed."
    )
end

function HolyPublicStopAll()

    State.Activated =
        false

    State.AutoHop =
        false

    State.AutoJoinMode =
        "Off"

    State.AutoJoinTeleporting =
        false

    State.AutoJoinLastMatch =
        "None"

    State.LastAction =
        "Stopped all modes"

    HolyPublicStopServerRefresh(
        "Stopped all modes"
    )

    HolyPublicSyncControls()

    RefreshStatus()

    Notify(
        "Stopped",
        "All modes stopped."
    )
end

function HolyPublicSetActivated(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.Activated =
        value == true

    State.LastAction =
        State.Activated
        and "Sniper enabled"
        or "Sniper disabled"

    RefreshStatus()

    if State.Activated == true then

        HolyPublicStartServerRefresh()

        if State.AutoJoinMode ~= "Off" then

            HolyPublicRefreshServerRows(
                true
            )
        end

    elseif State.AutoJoinMode == "Off" then

        HolyPublicStopServerRefresh(
            "Sniper disabled"
        )
    end
end

function HolyPublicSetAutoJoinMode(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.AutoJoinMode =
        HolyPublicNormalizeAutoJoinMode(
            value
        )

    State.LastAction =
        "Auto join: "
        .. State.AutoJoinMode

    RefreshStatus()

    if State.AutoJoinMode ~= "Off" then

        HolyPublicStartServerRefresh()

        HolyPublicRefreshServerRows(
            true
        )

        return
    end

    if State.Activated ~= true then

        HolyPublicStopServerRefresh(
            "Auto join off"
        )
    end
end

function HolyPublicSetMovement(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.MovementMode =
        tostring(value or "Teleport")

    State.LastAction =
        "Movement: "
        .. State.MovementMode

    RefreshStatus()
end

function HolyPublicSetAutoHop(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.AutoHop =
        value == true

    State.LastAction =
        State.AutoHop
        and "Auto hop enabled"
        or "Auto hop disabled"

    RefreshStatus()
end

function HolyPublicSetHopDelay(value)

    if HolyPublicSyncingUI == true then
        return
    end

    local number =
        tonumber(
            tostring(value):match("%d+%.?%d*")
        )
        or 3

    number =
        math.max(
            0,
            number
        )

    State.HopDelay =
        tostring(number)

    State.LastAction =
        "Hop delay: "
        .. State.HopDelay
        .. "s"

    RefreshStatus()
end

function HolyPublicSetHopTiming(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.AutoHopTiming =
        tostring(value or "Safe - After Loading")

    State.LastAction =
        "Hop timing: "
        .. State.AutoHopTiming

    RefreshStatus()
end

function HolyPublicSetBuyMode(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.BuyMode =
        tostring(value or "Instant")

    State.LastAction =
        "Buy mode: "
        .. State.BuyMode

    RefreshStatus()
end

function HolyPublicSetReturnAfterBuy(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.ReturnAfterBuy =
        value == true

    State.LastAction =
        State.ReturnAfterBuy
        and "Return enabled"
        or "Return disabled"

    RefreshStatus()
end

function HolyPublicSetReturnMode(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.ReturnMode =
        tostring(value or "Teleport")

    State.LastAction =
        "Return mode: "
        .. State.ReturnMode

    RefreshStatus()
end

function HolyPublicSetDefendBoughtPets(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.DefendBoughtPets =
        value == true

    State.LastAction =
        State.DefendBoughtPets
        and "Defense enabled"
        or "Defense disabled"

    RefreshStatus()
end

function HolyPublicSetDefendGear(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.DefendGear =
        tostring(value or "Strawberry Sniper")

    State.LastAction =
        "Defense gear: "
        .. State.DefendGear

    RefreshStatus()
end

function HolyPublicSetRebuyIfStolen(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.RebuyIfStolen =
        value == true

    State.LastAction =
        State.RebuyIfStolen
        and "Rebuy enabled"
        or "Rebuy disabled"

    RefreshStatus()
end

function HolyPublicSetShowUIOnLoad(value)

    if HolyPublicSyncingUI == true then
        return
    end

    State.ShowUIOnLoad =
        value == true

    State.LastAction =
        "Show UI on load: "
        .. tostring(State.ShowUIOnLoad)

    RefreshStatus()
end

function HolyPublicSetScale(value)

    if HolyPublicSyncingUI == true
    or ScaleApplying == true then

        return
    end

    ApplyUIScale(
        value,
        false
    )
end

function HolyPublicSetAccent(value)

    if HolyPublicSyncingUI == true then
        return
    end

    ApplyAccent(
        value,
        false
    )
end

function HolyPublicTestNotification()

    Notify(
        "HOLY Sniper",
        "Notification test worked."
    )
end

function HolyPublicCopyConfig()

    CopyText(
        EncodeConfig()
    )
end

function HolyPublicPrintConfig()

    print(
        "========== HOLY PUBLIC SNIPER CONFIG =========="
    )

    print(
        EncodeConfig()
    )
end

function HolyPublicSyncControls()

    HolyPublicSyncingUI =
        true

    pcall(function()
        if Controls.Pet then
            Controls.Pet:SetValue(State.SelectedPet)
        end
    end)

    pcall(function()
        if Controls.Size then
            Controls.Size:SetValue(State.SelectedSizes)
        end
    end)

    pcall(function()
        if Controls.Variant then
            Controls.Variant:SetValue(State.SelectedVariants)
        end
    end)

    pcall(function()
        if Controls.MaxPrice then
            Controls.MaxPrice:SetValue(State.MaxPrice)
        end
    end)

    pcall(function()
        if Controls.Priority then
            Controls.Priority:SetValue(State.Priority)
        end
    end)

    pcall(function()
        if Controls.JoinPet then
            Controls.JoinPet:SetValue(State.JoinPet)
        end
    end)

    pcall(function()
        if Controls.JoinSize then
            Controls.JoinSize:SetValue(State.JoinSizes)
        end
    end)

    pcall(function()
        if Controls.JoinVariant then
            Controls.JoinVariant:SetValue(State.JoinVariants)
        end
    end)

    pcall(function()
        if Controls.JoinPriority then
            Controls.JoinPriority:SetValue(State.JoinPriority)
        end
    end)

    pcall(function()
        if Controls.ActivateSniper then
            Controls.ActivateSniper:SetValue(State.Activated)
        end
    end)

    pcall(function()
        if Controls.AutoJoinMode then
            Controls.AutoJoinMode:SetValue(State.AutoJoinMode)
        end
    end)

    pcall(function()
        if Controls.Movement then
            Controls.Movement:SetValue(State.MovementMode)
        end
    end)

    pcall(function()
        if Controls.AutoHop then
            Controls.AutoHop:SetValue(State.AutoHop)
        end
    end)

    pcall(function()
        if Controls.HopDelay then
            Controls.HopDelay:SetValue(State.HopDelay)
        end
    end)

    pcall(function()
        if Controls.HopTiming then
            Controls.HopTiming:SetValue(State.AutoHopTiming)
        end
    end)

    pcall(function()
        if Controls.BuyMode then
            Controls.BuyMode:SetValue(State.BuyMode)
        end
    end)

    pcall(function()
        if Controls.ReturnAfterBuy then
            Controls.ReturnAfterBuy:SetValue(State.ReturnAfterBuy)
        end
    end)

    pcall(function()
        if Controls.ReturnMode then
            Controls.ReturnMode:SetValue(State.ReturnMode)
        end
    end)

    pcall(function()
        if Controls.DefendBoughtPets then
            Controls.DefendBoughtPets:SetValue(State.DefendBoughtPets)
        end
    end)

    pcall(function()
        if Controls.DefendGear then
            Controls.DefendGear:SetValue(State.DefendGear)
        end
    end)

    pcall(function()
        if Controls.RebuyIfStolen then
            Controls.RebuyIfStolen:SetValue(State.RebuyIfStolen)
        end
    end)

    pcall(function()
        if Controls.UIScale then
            Controls.UIScale:SetValue(FormatScale(State.UIScale))
        end
    end)

    pcall(function()
        if Controls.ShowUIOnLoad then
            Controls.ShowUIOnLoad:SetValue(State.ShowUIOnLoad)
        end
    end)

    pcall(function()
        if Controls.Accent then
            Controls.Accent:SetValue(State.Accent)
        end
    end)

    HolyPublicSyncingUI =
        false
end

function HolyPublicResetState()

    State.Activated =
        false

    State.AutoHop =
        false

    State.AutoJoinMode =
        "Off"

    State.SelectedPet =
        "Raccoon"

    State.SelectedSizes =
        { "Any" }

    State.SelectedVariants =
        { "Any" }

    State.MaxPrice =
        "0"

    State.Priority =
        "High"

    State.JoinPet =
        "Raccoon"

    State.JoinSizes =
        { "Any" }

    State.JoinVariants =
        { "Any" }

    State.JoinPriority =
        "High"

    State.MovementMode =
        "Teleport"

    State.BuyMode =
        "Instant"

    State.HopDelay =
        "3"

    State.AutoHopTiming =
        "Safe - After Loading"

    State.DefendBoughtPets =
        true

    State.DefendGear =
        "Strawberry Sniper"

    State.RebuyIfStolen =
        true

    State.ReturnAfterBuy =
        false

    State.ReturnMode =
        "Teleport"

    State.ShowUIOnLoad =
        true

    State.UIScale =
        80

    State.Accent =
        "Red"

    State.Watchlist =
        {}

    State.AutoJoinTargets =
        {}

    State.ServerRows =
        {}

    State.AutoJoinTeleporting =
        false

    State.AutoJoinLastAttemptAt =
        0

    State.AutoJoinLastMatch =
        "None"

    State.AutoJoinFailedJobs =
        {}

    State.ServerRefreshRunning =
        false

    State.ServerRefreshToken =
        nil

    State.ServerRefreshBusy =
        false

    State.ServerLastRefreshAt =
        0

    State.ServerLastRefreshCount =
        0

    State.ServerLastRefreshError =
        ""

    State.Status =
        "Ready"

    State.LastAction =
        "Reset config"

    HolyPublicNormalizeState()
    HolyPublicSyncControls()

    ApplyUIScale(
        State.UIScale,
        true
    )

    ApplyAccent(
        State.Accent,
        true
    )

    RefreshWatchlist()
    RefreshAutoJoinTargets()
    RefreshStatus()

    HolyPublicSaveSettings()

    Notify(
        "Reset",
        "Config reset."
    )
end

HolyPublicLoadSettings()

--==================================================
-- WINDOW
--==================================================

local Window =
    Library:CreateWindow({
        Title =
            '<font color="rgb(255, 60, 75)"><b>HOLY</b></font> <b>SNIPER</b>',

        Footer =
            "Public Sniper",

        Icon =
            "crosshair",

        ToggleKeybind =
            Enum.KeyCode.LeftAlt,

        Font =
            Enum.Font.GothamMedium,

        Center =
            true,

        AutoShow =
            State.ShowUIOnLoad == true,

        Size =
            UDim2.fromOffset(660, 455),

        CornerRadius =
            8,

        GlobalSearch =
            true,

        NotifySide =
            "Right",

        ShowCustomCursor =
            true,

        EnableCompacting =
            true,

        EnableSidebarResize =
            true,

        MinSidebarWidth =
            145,

        SidebarCompactWidth =
            50,
    })

--==================================================
-- TABS
--==================================================

local Tabs = {
    Sniper =
        Window:AddTab({
            Name = "Sniper",
            Icon = "crosshair",
            Description = "Targets, watchlist, and live sniper status.",
        }),

    Settings =
        Window:AddTab({
            Name = "Settings",
            Icon = "sliders-horizontal",
            Description = "Movement, auto hop, defense, and buy behavior.",
        }),

    UI =
        Window:AddTab({
            Name = "UI",
            Icon = "settings",
            Description = "Interface, theme, and config tools.",
        }),
}

--==================================================
-- SNIPER TAB
--==================================================

local TargetBox =
    Tabs.Sniper:AddLeftGroupbox("Buy Setup", "list-plus")

local AutoJoinBox =
    Tabs.Sniper:AddLeftGroupbox("Auto Join Setup", "radar")

local WatchlistBox =
    Tabs.Sniper:AddRightGroupbox("Buy Targets", "list-checks")

local AutoJoinTargetsBox =
    Tabs.Sniper:AddRightGroupbox("Auto Join Targets", "server")

local StatusBox =
    Tabs.Sniper:AddRightGroupbox("Live Status", "activity")

local StatusLabel =
    StatusBox:AddLabel({
        Text = "Status: Ready",
        DoesWrap = true,
    })

local RuntimeLabel =
    StatusBox:AddLabel({
        Text = "Runtime: 0s",
        DoesWrap = false,
    })

local ServerLabel =
    StatusBox:AddLabel({
        Text = "Server: " .. ShortJobId(),
        DoesWrap = false,
    })

local LastActionLabel =
    StatusBox:AddLabel({
        Text = "Last Action: None",
        DoesWrap = true,
    })

local WatchlistLabel =
    WatchlistBox:AddLabel({
        Text = "No buy targets added.",
        DoesWrap = true,
    })

local AutoJoinTargetsLabel =
    AutoJoinTargetsBox:AddLabel({
        Text = "No auto join targets added.",
        DoesWrap = true,
    })

function RefreshStatus()
    State.Status =
        State.Activated
        and "Scanning"
        or "Ready"

    local serverRowCount =
        type(State.ServerRows) == "table"
        and #State.ServerRows
        or 0

    local refreshText =
        "Never"

    if tonumber(State.ServerLastRefreshAt) ~= nil
    and tonumber(State.ServerLastRefreshAt) > 0 then

        refreshText =
            tostring(
                math.floor(
                    os.clock() - State.ServerLastRefreshAt
                )
            )
            .. "s ago"
    end

    local refreshError =
        CleanText(
            State.ServerLastRefreshError
            or ""
        )

    StatusLabel:SetText(
        "Status: "
            .. State.Status
            .. "\nMode: "
            .. State.MovementMode
            .. " / "
            .. State.BuyMode
            .. "\nAuto Hop: "
            .. (State.AutoHop and "ON" or "OFF")
            .. " · Auto Join: "
            .. State.AutoJoinMode
            .. "\nJoin Targets: "
            .. tostring(
                type(State.AutoJoinTargets) == "table"
                and #State.AutoJoinTargets
                or 0
            )
            .. " · Server Rows: "
            .. tostring(serverRowCount)
            .. "\nBest Match: "
            .. tostring(State.AutoJoinLastMatch or "None")
            .. "\nRefresh: "
            .. refreshText
            .. (
                refreshError ~= ""
                and (
                    "\nError: "
                    .. refreshError
                )
                or ""
            )
    )

    LastActionLabel:SetText(
        "Last Action: "
            .. tostring(State.LastAction or "None")
    )

    HolyPublicQueueSave()
end

function RefreshWatchlist()
    if #State.Watchlist <= 0 then

        WatchlistLabel:SetText(
            "No buy targets added."
        )

        HolyPublicQueueSave()

        return
    end

    local lines =
        {}

    for index, row in ipairs(State.Watchlist) do

        lines[#lines + 1] =
            tostring(index)
            .. ". "
            .. tostring(row.Priority)
            .. " · "
            .. tostring(row.Pet)
            .. " · "
            .. tostring(row.Size)
            .. " · "
            .. tostring(row.Variant)
            .. " · "
            .. tostring(row.MaxPrice)
    end

    WatchlistLabel:SetText(
        table.concat(
            lines,
            "\n"
        )
    )

    HolyPublicQueueSave()
end

function RefreshAutoJoinTargets()
    State.AutoJoinTargets =
        type(State.AutoJoinTargets) == "table"
        and State.AutoJoinTargets
        or {}

    if #State.AutoJoinTargets <= 0 then

        AutoJoinTargetsLabel:SetText(
            "No auto join targets added."
        )

        HolyPublicQueueSave()

        return
    end

    local lines =
        {}

    for index, row in ipairs(State.AutoJoinTargets) do

        lines[#lines + 1] =
            tostring(index)
            .. ". "
            .. tostring(row.Priority)
            .. " · "
            .. tostring(row.Pet)
            .. " · "
            .. tostring(row.Size)
            .. " · "
            .. tostring(row.Variant)
    end

    AutoJoinTargetsLabel:SetText(
        table.concat(
            lines,
            "\n"
        )
    )

    HolyPublicQueueSave()
end

Controls.Pet =
    TargetBox:AddDropdown(
        "HolyPublicPet",
        {
            Text = "Pet",
            Values = {
                "Raccoon",
                "Unicorn",
                "Golden Dragonfly",
                "Ice Serpent",
                "Monkey",
                "Owl",
                "Frog",
                "Bunny",
                "Bee",
                "Deer",
                "Robin",
                "Any Pet",
            },
            Default = State.SelectedPet,
            Multi = false,
            Searchable = true,
            MaxVisibleDropdownItems = 8,
        }
    )

Controls.Pet:OnChanged(
    HolyPublicSetPet
)

Controls.Size =
    TargetBox:AddDropdown(
        "HolyPublicSize",
        {
            Text = "Size",
            Values = {
                "Any",
                "Normal",
                "Big",
                "Huge",
            },
            Default = State.SelectedSizes,
            Multi = true,
            Searchable = false,
            MaxVisibleDropdownItems = 4,
        }
    )

Controls.Size:OnChanged(
    HolyPublicSetSizes
)

Controls.Variant =
    TargetBox:AddDropdown(
        "HolyPublicVariant",
        {
            Text = "Mutation / Variant",
            Values = {
                "Any",
                "Normal",
                "Rainbow",
            },
            Default = State.SelectedVariants,
            Multi = true,
            Searchable = false,
            MaxVisibleDropdownItems = 3,
        }
    )

Controls.Variant:OnChanged(
    HolyPublicSetVariants
)

Controls.MaxPrice =
    TargetBox:AddInput(
        "HolyPublicMaxPrice",
        {
            Text = "Max Price",
            Default = State.MaxPrice,
            Numeric = false,
            Finished = true,
            ClearTextOnFocus = false,
            Placeholder = "0 / 100k / 2.5m",
            Tooltip = "0 or blank = no price cap.",
        }
    )

Controls.MaxPrice:OnChanged(
    HolyPublicSetMaxPrice
)

Controls.Priority =
    TargetBox:AddDropdown(
        "HolyPublicPriority",
        {
            Text = "Priority",
            Values = {
                "High",
                "Medium",
                "Low",
            },
            Default = State.Priority,
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 3,
        }
    )

Controls.Priority:OnChanged(
    HolyPublicSetPriority
)

TargetBox:AddButton({
    Text =
        "Add Target",

    Func =
        HolyPublicAddTarget,
})

TargetBox:AddButton({
    Text =
        "Clear Watchlist",

    DoubleClick =
        true,

    Func =
        HolyPublicClearWatchlist,
})

Controls.JoinPet =
    AutoJoinBox:AddDropdown(
        "HolyPublicJoinPet",
        {
            Text = "Pet",
            Values = {
                "Raccoon",
                "Unicorn",
                "Golden Dragonfly",
                "Ice Serpent",
                "Monkey",
                "Owl",
                "Frog",
                "Bunny",
                "Bee",
                "Deer",
                "Robin",
                "Any Pet",
            },
            Default = State.JoinPet,
            Multi = false,
            Searchable = true,
            MaxVisibleDropdownItems = 8,
        }
    )

Controls.JoinPet:OnChanged(
    HolyPublicSetJoinPet
)

Controls.JoinSize =
    AutoJoinBox:AddDropdown(
        "HolyPublicJoinSize",
        {
            Text = "Size",
            Values = {
                "Any",
                "Normal",
                "Big",
                "Huge",
            },
            Default = State.JoinSizes,
            Multi = true,
            Searchable = false,
            MaxVisibleDropdownItems = 4,
        }
    )

Controls.JoinSize:OnChanged(
    HolyPublicSetJoinSizes
)

Controls.JoinVariant =
    AutoJoinBox:AddDropdown(
        "HolyPublicJoinVariant",
        {
            Text = "Mutation",
            Values = {
                "Any",
                "Normal",
                "Rainbow",
            },
            Default = State.JoinVariants,
            Multi = true,
            Searchable = false,
            MaxVisibleDropdownItems = 3,
        }
    )

Controls.JoinVariant:OnChanged(
    HolyPublicSetJoinVariants
)

Controls.JoinPriority =
    AutoJoinBox:AddDropdown(
        "HolyPublicJoinPriority",
        {
            Text = "Priority",
            Values = {
                "High",
                "Medium",
                "Low",
            },
            Default = State.JoinPriority,
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 3,
        }
    )

Controls.JoinPriority:OnChanged(
    HolyPublicSetJoinPriority
)

AutoJoinBox:AddButton({
    Text =
        "Add Join Target",

    Func =
        HolyPublicAddJoinTarget,
})

AutoJoinBox:AddButton({
    Text =
        "Clear Join Targets",

    DoubleClick =
        true,

    Func =
        HolyPublicClearJoinTargets,
})

StatusBox:AddButton({
    Text =
        "Scan Servers",

    Func =
        HolyPublicPreviewScan,
})

StatusBox:AddButton({
    Text =
        "Preview Buy",

    Func =
        HolyPublicPreviewBuy,
})

StatusBox:AddButton({
    Text =
        "Stop All",

    Func =
        HolyPublicStopAll,
})

--==================================================
-- SETTINGS TAB
--==================================================

local MainLogicBox =
    Tabs.Settings:AddLeftGroupbox("Main Logic", "cpu")

local HopBox =
    Tabs.Settings:AddLeftGroupbox("Auto Hop", "refresh-cw")

local BuyBox =
    Tabs.Settings:AddRightGroupbox("Buy Behavior", "zap")

local DefenseBox =
    Tabs.Settings:AddRightGroupbox("Defense", "shield")

Controls.ActivateSniper =
    MainLogicBox:AddToggle(
        "HolyPublicActivateSniper",
        {
            Text = "Activate Sniper",
            Default = State.Activated,
            Tooltip = "Starts or stops the sniper loop when real logic is wired.",
        }
    )

Controls.ActivateSniper:OnChanged(
    HolyPublicSetActivated
)

Controls.AutoJoinMode =
    MainLogicBox:AddDropdown(
        "HolyPublicAutoJoinMode",
        {
            Text = "Auto Join Mode",
            Values = {
                "Off",
                "Notify",
                "Join Best",
                "Join First",
            },
            Default = State.AutoJoinMode,
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 4,
        }
    )

Controls.AutoJoinMode:OnChanged(
    HolyPublicSetAutoJoinMode
)

Controls.Movement =
    MainLogicBox:AddDropdown(
        "HolyPublicMovement",
        {
            Text = "Movement",
            Values = {
                "Teleport",
                "Walk",
            },
            Default = State.MovementMode,
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 2,
        }
    )

Controls.Movement:OnChanged(
    HolyPublicSetMovement
)

Controls.AutoHop =
    HopBox:AddToggle(
        "HolyPublicAutoHop",
        {
            Text = "Auto Hop",
            Default = State.AutoHop,
            Tooltip = "Server hops when no target match is found.",
        }
    )

Controls.AutoHop:OnChanged(
    HolyPublicSetAutoHop
)

Controls.HopDelay =
    HopBox:AddInput(
        "HolyPublicHopDelay",
        {
            Text = "Hop Delay",
            Default = State.HopDelay,
            Numeric = false,
            Finished = true,
            ClearTextOnFocus = false,
            Placeholder = "3",
        }
    )

Controls.HopDelay:OnChanged(
    HolyPublicSetHopDelay
)

Controls.HopTiming =
    HopBox:AddDropdown(
        "HolyPublicHopTiming",
        {
            Text = "Hop Timing",
            Values = {
                "Safe - After Loading",
                "Fast - During Loading",
            },
            Default = State.AutoHopTiming,
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 2,
        }
    )

Controls.HopTiming:OnChanged(
    HolyPublicSetHopTiming
)

Controls.BuyMode =
    BuyBox:AddDropdown(
        "HolyPublicBuyMode",
        {
            Text = "Buy Mode",
            Values = {
                "Instant",
                "Hold",
            },
            Default = State.BuyMode,
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 2,
        }
    )

Controls.BuyMode:OnChanged(
    HolyPublicSetBuyMode
)

Controls.ReturnAfterBuy =
    BuyBox:AddToggle(
        "HolyPublicReturnAfterBuy",
        {
            Text = "Return After Buy",
            Default = State.ReturnAfterBuy,
            Tooltip = "Returns after a successful buy when real logic is wired.",
        }
    )

Controls.ReturnAfterBuy:OnChanged(
    HolyPublicSetReturnAfterBuy
)

Controls.ReturnMode =
    BuyBox:AddDropdown(
        "HolyPublicReturnMode",
        {
            Text = "Return Mode",
            Values = {
                "Teleport",
                "Walk",
            },
            Default = State.ReturnMode,
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 2,
        }
    )

Controls.ReturnMode:OnChanged(
    HolyPublicSetReturnMode
)

Controls.DefendBoughtPets =
    DefenseBox:AddToggle(
        "HolyPublicDefendBoughtPets",
        {
            Text = "Defend Bought Pets",
            Default = State.DefendBoughtPets,
            Tooltip = "Defends bought pets when real logic is wired.",
        }
    )

Controls.DefendBoughtPets:OnChanged(
    HolyPublicSetDefendBoughtPets
)

Controls.DefendGear =
    DefenseBox:AddDropdown(
        "HolyPublicDefendGear",
        {
            Text = "Defense Gear",
            Values = {
                "Strawberry Sniper",
                "Shovel",
            },
            Default = State.DefendGear,
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 2,
        }
    )

Controls.DefendGear:OnChanged(
    HolyPublicSetDefendGear
)

Controls.RebuyIfStolen =
    DefenseBox:AddToggle(
        "HolyPublicRebuyIfStolen",
        {
            Text = "Rebuy If Stolen",
            Default = State.RebuyIfStolen,
            Tooltip = "Uses Max Price later when real logic is added.",
        }
    )

Controls.RebuyIfStolen:OnChanged(
    HolyPublicSetRebuyIfStolen
)

--==================================================
-- UI TAB
--==================================================

local InterfaceBox =
    Tabs.UI:AddLeftGroupbox("Interface", "monitor-cog")

local ThemeBox =
    Tabs.UI:AddLeftGroupbox("Theme", "palette")

local ConfigBox =
    Tabs.UI:AddRightGroupbox("Config", "file-json")

local InfoBox =
    Tabs.UI:AddRightGroupbox("Release Notes", "info")

Controls.UIScale =
    InterfaceBox:AddDropdown(
        "HolyPublicUIScale",
        {
            Text = "UI Scale",
            Values = HOLY_PUBLIC_SCALE_VALUES,
            Default = FormatScale(State.UIScale),
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = #HOLY_PUBLIC_SCALE_VALUES,
        }
    )

ScaleDropdown =
    Controls.UIScale

Controls.UIScale:OnChanged(
    HolyPublicSetScale
)

Controls.ShowUIOnLoad =
    InterfaceBox:AddToggle(
        "HolyPublicAutoShow",
        {
            Text = "Show UI On Load",
            Default = State.ShowUIOnLoad,
        }
    )

Controls.ShowUIOnLoad:OnChanged(
    HolyPublicSetShowUIOnLoad
)

InterfaceBox:AddButton({
    Text =
        "Test Notification",

    Func =
        HolyPublicTestNotification,
})

Controls.Accent =
    ThemeBox:AddDropdown(
        "HolyPublicAccent",
        {
            Text = "Accent",
            Values = {
                "Red",
                "Blue",
                "Purple",
                "Green",
                "Gold",
                "White",
            },
            Default = State.Accent,
            Multi = false,
            Searchable = false,
            MaxVisibleDropdownItems = 6,
        }
    )

Controls.Accent:OnChanged(
    HolyPublicSetAccent
)

ConfigBox:AddButton({
    Text =
        "Copy Config",

    Func =
        HolyPublicCopyConfig,
})

ConfigBox:AddButton({
    Text =
        "Print Config",

    Func =
        HolyPublicPrintConfig,
})

ConfigBox:AddButton({
    Text =
        "Reset Config",

    DoubleClick =
        true,

    Func =
        HolyPublicResetState,
})

InfoBox:AddLabel({
    Text =
        "HOLY Sniper public build.\n\n"
        .. "Buy Targets = pets to buy in this server.\n"
        .. "Auto Join Targets = pets to join servers for.\n"
        .. "Preview Scan tests Auto Join matching.\n"
        .. "Config autosaves automatically.",

    DoesWrap =
        true,
})

--==================================================
-- LIVE UI LOOP
--==================================================

task.spawn(function()
    while Library and Library.Unloaded ~= true do
        local runtime =
            math.floor(os.clock() - State.LoadedAt)

        pcall(function()
            RuntimeLabel:SetText("Runtime: " .. tostring(runtime) .. "s")
            ServerLabel:SetText("Server: " .. ShortJobId())
        end)

        task.wait(1)
    end
end)

HolyPublicSyncControls()

RefreshWatchlist()
RefreshAutoJoinTargets()
RefreshStatus()

HolyPublicStartServerRefresh()

ApplyUIScale(
    State.UIScale,
    true
)

ApplyAccent(
    State.Accent,
    true
)

HolyPublicSaveSettings()

Notify(
    "HOLY Sniper",
    "Loaded. Toggle with LeftAlt."
)


