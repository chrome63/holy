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

--==================================================
-- [1] CONSTANTS
--==================================================

local LOCAL_PLAYER =
    Players.LocalPlayer
    or Players.PlayerAdded:Wait()

local GROW_A_GARDEN_2_PLACE_ID =
    97598239454123

local REPO_URL =
    "https://raw.githubusercontent.com/bencapalot041/goons/main/"

local LIBRARY_URL =
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

GAG2_RARE_PET_WEBHOOK_TARGETS = {
    raccoon = true,
    goldendragonfly = true,
    unicorn = true,
}

GAG2_RARE_PET_WEBHOOK_SENT =
    {}

GAG2_SERVER_HOP_RETRYING =
    false

GAG2_SERVER_HOP_ATTEMPT =
    0

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

    return game.PlaceId == GROW_A_GARDEN_2_PLACE_ID
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

    return
        '<font color="rgb(148,163,184)"><b>Current Server</b></font>'
        .. '\nPlaceId: '
        .. tostring(game.PlaceId)
        .. '\nJobId: '
        .. tostring(game.JobId)
        .. '\nPlayers: '
        .. tostring(#Players:GetPlayers())
        .. '\nGAG2 Place: '
        .. BoolText(IsGAG2World())
end

local function RefreshServerInfo()

    if Options.HolyGAG2ServerInfo then

        Options.HolyGAG2ServerInfo:SetText(
            BuildServerInfoText()
        )
    end
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
    ReturnAfterTame = true,

    Taming = false,
    LastTameAt = 0,
    RecentTameAttempts = {},
    HandledWildPets = {},
    PendingWildPets = {},

    BuyValidationHoldDelay = 1.65,
    StartupBuyDelay = 8,
    StartedAt = os.clock(),

    WaitingForClaim = false,
    WaitingForClaimKey = "",
    ClaimWaitTimeout = 90,
    ClaimDisappearConfirmTime = 1.25,
    HandledPetCooldown = 120,

    PacketTable = nil,
    PacketSource = "not loaded",

    BuyPacket = nil,
    BuyPacketSource = "not loaded",

    ScanDelay = 0.5,
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

    task.spawn(function()

        local confirmed =
            SniperWaitForClaimConfirmation(
                entry
            )

        SniperState.PendingWildPets[key] =
            nil

        if confirmed == true then

            SetSniperStatus(
                "Bought: "
                .. tostring(entry.Name)
            )

            Notify(
                "Sniper",
                "Bought "
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

    if #matches > 0 then

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
    and hasHandledActiveTarget ~= true
    and SniperReadyToBuy() == true then

        local sinceHop =
            os.clock() - tonumber(SniperState.LastHopAt or 0)

        if sinceHop >= SniperState.HopDelay then

            SniperState.LastHopAt =
                os.clock()

            SetSniperStatus(
                "Hopping..."
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

        SniperScan(
            false
        )

        MarkConfigDirty()

        SniperStartLoop()

    else

        SetSniperStatus(
            "Sniper disabled."
        )
    end
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

        SniperState.AutoHop =
            autoHop == true

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

local HomeActivePetsLabel =
    nil

local HomeActivePetsLoopRunning =
    false

local function BuildHomeActivePetsText()

    local entries, reason =
        SniperGetActiveEntries()

    local lines = {
        '<font color="rgb(196,181,253)"><b>Active Pets</b></font>',
    }

    if reason ~= "ok" then

        table.insert(
            lines,
            "Loading..."
        )

        return table.concat(
            lines,
            "\n"
        )
    end

    if #entries <= 0 then

        table.insert(
            lines,
            "None"
        )

        return table.concat(
            lines,
            "\n"
        )
    end

    table.insert(
        lines,
        "Count: "
        .. tostring(#entries)
    )

    for index, entry in ipairs(entries) do

        if index > 14 then

            table.insert(
                lines,
                "+ "
                .. tostring(#entries - 14)
                .. " more"
            )

            break
        end

        local suffix =
            ""

        if SniperIsEntryHandled(entry) == true then
            suffix = " | Sent"
        end

        local distanceText =
            tostring(entry.Distance or "?")
                :gsub("%s*studs", "")
                :gsub("%s+$", "")

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
            .. distanceText
            .. suffix
        )
    end

    return table.concat(
        lines,
        "\n"
    )
end

local function RefreshHomeActivePets()

    if HomeActivePetsLabel
    and type(HomeActivePetsLabel.SetText) == "function" then

        pcall(function()

            HomeActivePetsLabel:SetText(
                BuildHomeActivePetsText()
            )
        end)
    end
end

local function StartHomeActivePetsLoop()

    if HomeActivePetsLoopRunning == true then
        return
    end

    HomeActivePetsLoopRunning =
        true

    task.spawn(function()

        while HomeActivePetsLoopRunning == true do

            RefreshHomeActivePets()
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

    local embed = {

        title =
            "🌟 GAG2 Rare Wild Pet Found • "
            .. petName,

        description =
            "A target wild pet is active in this server.",

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

    local payload = {
        username =
            "Holy GAG2",

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
                    HttpService:JSONEncode(
                        payload
                    ),
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
            Icon = "settings",
            Description = "Main controls.",
        }),

    Shops =
        Window:AddTab({
            Name = "Shops",
            Icon = "settings",
            Description = "Shop systems.",
        }),

    Sell =
        Window:AddTab({
            Name = "Sell",
            Icon = "settings",
            Description = "Sell systems.",
        }),

    Experiment =
        Window:AddTab({
            Name = "Experiment",
            Icon = "settings",
            Description = "Safe experiments.",
        }),

    Farm =
        Window:AddTab({
            Name = "Farm",
            Icon = "settings",
            Description = "Farm systems.",
        }),

    Visuals =
        Window:AddTab({
            Name = "Visuals",
            Icon = "settings",
            Description = "GAG2 research and visual tools.",
        }),

    Sniper =
        Window:AddTab({
            Name = "Sniper",
            Icon = "settings",
            Description = "Wild pet sniper scanner.",
        }),

    Settings =
        Window:AddTab({
            Name = "Settings",
            Icon = "settings",
            Description = "UI settings.",
        }),
}

if IsHolyGAG2Developer() then

    Tabs.Dev =
        Window:AddTab({
            Name = "Dev",
            Icon = "settings",
            Description = "Developer tools.",
        })
end

--==================================================
-- [7] GROUPBOXES
--==================================================

local HomeMainBox =
    Tabs.Home:AddLeftGroupbox(
        "Main",
        "settings"
    )

local HomeServerBox =
    Tabs.Home:AddRightGroupbox(
        "Server",
        "settings"
    )

local ShopsMainBox =
    Tabs.Shops:AddLeftGroupbox(
        "Controls",
        "settings"
    )

local ShopsStatusBox =
    Tabs.Shops:AddRightGroupbox(
        "Status",
        "settings"
    )

local SellMainBox =
    Tabs.Sell:AddLeftGroupbox(
        "Controls",
        "settings"
    )

local SellStatusBox =
    Tabs.Sell:AddRightGroupbox(
        "Status",
        "settings"
    )

local ExperimentMainBox =
    Tabs.Experiment:AddLeftGroupbox(
        "Controls",
        "settings"
    )

local ExperimentStatusBox =
    Tabs.Experiment:AddRightGroupbox(
        "Status",
        "settings"
    )

local FarmMainBox =
    Tabs.Farm:AddLeftGroupbox(
        "Controls",
        "settings"
    )

local FarmStatusBox =
    Tabs.Farm:AddRightGroupbox(
        "Status",
        "settings"
    )

local VisualsMainBox =
    Tabs.Visuals:AddLeftGroupbox(
        "Research",
        "settings"
    )

local VisualsStatusBox =
    Tabs.Visuals:AddRightGroupbox(
        "Status",
        "settings"
    )

local SniperMainBox =
    Tabs.Sniper:AddLeftGroupbox(
        "Wild Pet Sniper",
        "settings"
    )

local SniperStatusBox =
    Tabs.Sniper:AddRightGroupbox(
        "Sniper Status",
        "settings"
    )

local SettingsUIBox =
    Tabs.Settings:AddLeftGroupbox(
        "Interface",
        "settings"
    )

local DevToolsBox =
    nil

local DevInfoBox =
    nil

if Tabs.Dev then

    DevToolsBox =
        Tabs.Dev:AddLeftGroupbox(
            "Tools",
            "settings"
        )

    DevInfoBox =
        Tabs.Dev:AddRightGroupbox(
            "Info",
            "settings"
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
    Text = "Copy JobId",
    Tooltip = "Copy current server JobId.",
    Func = function()

        if CopyText(game.JobId) == true then

            Notify(
                "Copied",
                "JobId copied.",
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

HomeMainBox:AddLabel("HolyGAG2Status", {
    Text =
        '<font color="rgb(196,181,253)"><b>Status:</b></font> Ready',
    DoesWrap = true,
})

HomeServerBox:AddLabel("HolyGAG2ServerInfo", {
    Text =
        BuildServerInfoText(),
    DoesWrap = true,
})

HomeActivePetsLabel =
    HomeServerBox:AddLabel("HolyGAG2HomeActivePets", {
        Text =
            '<font color="rgb(196,181,253)"><b>Active Pets</b></font>'
            .. '\nLoading...',
        DoesWrap = true,
    })

if IsGAG2World() ~= true then

    HomeServerBox:AddLabel({
        Text =
            '<font color="rgb(248,113,113)"><b>Wrong Place Warning</b></font>'
            .. '\nExpected PlaceId: '
            .. tostring(GROW_A_GARDEN_2_PLACE_ID)
            .. '\nCurrent PlaceId: '
            .. tostring(game.PlaceId),
        DoesWrap = true,
    })
end

--==================================================
-- [8.25] SHOPS TAB
--==================================================

ShopsMainBox:AddLabel({
    Text = "Ready.",
    DoesWrap = true,
    Size = 13,
})

ShopsStatusBox:AddLabel("HolyGAG2ShopsStatus", {
    Text = "Idle.",
    DoesWrap = true,
})

--==================================================
-- [8.5] SELL TAB
--==================================================

SellMainBox:AddLabel({
    Text = "Ready.",
    DoesWrap = true,
    Size = 13,
})

SellStatusBox:AddLabel("HolyGAG2SellStatus", {
    Text = "Idle.",
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
    Text = "Ready.",
    DoesWrap = true,
    Size = 13,
})

FarmStatusBox:AddLabel("HolyGAG2FarmStatus", {
    Text = "Idle.",
    DoesWrap = true,
})

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

SniperMainBox:AddToggle("HolyGAG2SniperEnabled", {
    Text = "Activate Sniper",
    Default = false,
    Tooltip = "Start looking for selected pets.",
    Callback = function(value)

        SniperSetEnabled(
            value == true
        )

        MarkConfigDirty()
    end,
})

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

SettingsUIBox:AddLabel({
    Text = "Interface",
    DoesWrap = true,
    Size = 13,
})

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

RestoreSniperAutosaveState()

ConfigState.Loading =
    false

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

    TeleportService.TeleportInitFailed:Connect(function(player)

        if player ~= LOCAL_PLAYER then
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

RefreshServerInfo()
RefreshHomeActivePets()
StartHomeActivePetsLoop()
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
