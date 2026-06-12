--==================================================
-- HOLY | GROW A GARDEN 2
-- Clean Obsidian UI Shell
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

local UserInputService =
    game:GetService("UserInputService")

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

local LIBRARY_URL =
    "https://raw.githubusercontent.com/bencapalot041/goons/main/librarylite.lua?v="
    .. tostring(os.time())

local SETTINGS_FOLDER =
    "HolyGAG2"

local SETTINGS_FILE =
    SETTINGS_FOLDER
    .. "/UISettings_"
    .. tostring(LOCAL_PLAYER.UserId)
    .. ".json"

local HOLY_GAG2_DEVELOPER_USER_IDS = {
    [78428093] = true,
}

local function IsHolyGAG2Developer()

    return LOCAL_PLAYER
        and HOLY_GAG2_DEVELOPER_USER_IDS[LOCAL_PLAYER.UserId] == true
end

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

local Library =
    nil

local function Notify(title, description, duration)

    if Library
    and type(Library.Notify) == "function" then

        Library:Notify({
            Title = tostring(title or "Holy"),
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

local function CanUseFiles()

    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

local function EnsureSettingsFolder()

    if type(makefolder) ~= "function"
    or type(isfolder) ~= "function" then
        return false
    end

    local ok =
        pcall(function()

            if not isfolder(SETTINGS_FOLDER) then
                makefolder(SETTINGS_FOLDER)
            end
        end)

    return ok == true
end

--==================================================
-- [3] SETTINGS
--==================================================

local UIState = {
    DPIScale = 100,

    ShopAutoBuySeeds = false,
    ShopAutoBuyGear = false,
    ShopAutoBuyCrates = false,

    ShopSeeds = {
        "Carrot",
    },

    ShopGear = {},
    ShopCrates = {},

    ShopBuyDelay = 0.35,
    ShopMaxBuysPerRestock = 1,

    SellAutoMaxBackpack = false,
    SellDelay = 0.5,
    SellDebug = false,

    FarmAutoPlant = false,
    FarmAutoCollect = false,
    FarmCollectDelay = 0.5,

    -- Empty = collect every plant.
    -- Selected values = only collect matching plant names.
    FarmCollectPlants = {},

    -- Legacy single seed field, kept for older saves/status fallback.
    FarmSelectedSeed = "Carrot",

    -- Real multi-select Farm seed list.
    FarmSelectedSeeds = {
        "Carrot",
    },

    FarmPlantDelay = 0.35,
    FarmRandomPosition = true,

    -- Saved relative to the current "Your Garden" plot.
    -- This is NOT a world position, so it still works after rejoin/new farm.
    FarmPlantLocalOffset = nil,
}

local function SettingsNormalizeStringList(value, fallback)

    local result =
        {}

    local function AddItem(itemName)

        itemName =
            CleanText(itemName)

        if itemName == "" then
            return
        end

        if table.find(result, itemName) ~= nil then
            return
        end

        table.insert(
            result,
            itemName
        )
    end

    if type(value) == "table" then

        for _, itemName in ipairs(value) do

            AddItem(
                itemName
            )
        end

        for itemName, enabled in pairs(value) do

            if enabled == true then

                AddItem(
                    itemName
                )
            end
        end

    elseif type(value) == "string" then

        AddItem(
            value
        )
    end

    if #result <= 0
    and type(fallback) == "table" then

        for _, itemName in ipairs(fallback) do

            AddItem(
                itemName
            )
        end
    end

    table.sort(result)

    return result
end

local function SettingsNormalizeNumber(value, defaultValue, minValue, maxValue)

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

local function LoadUISettings()

    if CanUseFiles() ~= true then
        return false
    end

    local exists =
        false

    pcall(function()
        exists =
            isfile(SETTINGS_FILE)
    end)

    if exists ~= true then
        return false
    end

    local ok, raw =
        pcall(function()
            return readfile(SETTINGS_FILE)
        end)

    if ok ~= true
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

    UIState.DPIScale =
        math.clamp(
            math.floor(
                tonumber(payload.DPIScale)
                or 100
            ),
            50,
            125
        )

    UIState.ShopAutoBuySeeds =
        payload.ShopAutoBuySeeds == true

    UIState.ShopAutoBuyGear =
        payload.ShopAutoBuyGear == true

    UIState.ShopAutoBuyCrates =
        payload.ShopAutoBuyCrates == true

    UIState.ShopSeeds =
        SettingsNormalizeStringList(
            payload.ShopSeeds,
            {
                "Carrot",
            }
        )

    UIState.ShopGear =
        SettingsNormalizeStringList(
            payload.ShopGear,
            {}
        )

    UIState.ShopCrates =
        SettingsNormalizeStringList(
            payload.ShopCrates,
            {}
        )

    UIState.ShopBuyDelay =
        SettingsNormalizeNumber(
            payload.ShopBuyDelay,
            0.35,
            0.1,
            10
        )

    UIState.ShopMaxBuysPerRestock =
        math.floor(
            SettingsNormalizeNumber(
                payload.ShopMaxBuysPerRestock,
                1,
                1,
                999
            )
        )

    if payload.SellAutoMaxBackpack ~= nil then
        UIState.SellAutoMaxBackpack =
            payload.SellAutoMaxBackpack == true
    end

    UIState.SellDelay =
        SettingsNormalizeNumber(
            payload.SellDelay,
            0.5,
            0.1,
            10
        )

    if payload.SellDebug ~= nil then
        UIState.SellDebug =
            payload.SellDebug == true
    end

    if payload.FarmAutoPlant ~= nil then
        UIState.FarmAutoPlant =
            payload.FarmAutoPlant == true
    end

    if payload.FarmAutoCollect ~= nil then
        UIState.FarmAutoCollect =
            payload.FarmAutoCollect == true
    end

    UIState.FarmCollectDelay =
        SettingsNormalizeNumber(
            payload.FarmCollectDelay,
            0.5,
            0.1,
            10
        )

    UIState.FarmCollectPlants =
        SettingsNormalizeStringList(
            payload.FarmCollectPlants,
            {}
        )

    local farmSeed =
        CleanText(payload.FarmSelectedSeed)

    if farmSeed ~= "" then
        UIState.FarmSelectedSeed =
            farmSeed
    end

    UIState.FarmSelectedSeeds =
        SettingsNormalizeStringList(
            payload.FarmSelectedSeeds,
            {
                CleanText(UIState.FarmSelectedSeed) ~= ""
                and CleanText(UIState.FarmSelectedSeed)
                or "Carrot",
            }
        )

    if #UIState.FarmSelectedSeeds > 0 then

        UIState.FarmSelectedSeed =
            UIState.FarmSelectedSeeds[1]
    end

    UIState.FarmPlantDelay =
        math.clamp(
            tonumber(payload.FarmPlantDelay)
            or tonumber(UIState.FarmPlantDelay)
            or 0.35,
            0.1,
            10
        )

    if payload.FarmRandomPosition ~= nil then
        UIState.FarmRandomPosition =
            payload.FarmRandomPosition == true
    end

    if type(payload.FarmPlantLocalOffset) == "table" then

        local x =
            tonumber(payload.FarmPlantLocalOffset.X)
            or tonumber(payload.FarmPlantLocalOffset.x)
            or tonumber(payload.FarmPlantLocalOffset[1])

        local y =
            tonumber(payload.FarmPlantLocalOffset.Y)
            or tonumber(payload.FarmPlantLocalOffset.y)
            or tonumber(payload.FarmPlantLocalOffset[2])

        local z =
            tonumber(payload.FarmPlantLocalOffset.Z)
            or tonumber(payload.FarmPlantLocalOffset.z)
            or tonumber(payload.FarmPlantLocalOffset[3])

        if x and y and z then

            UIState.FarmPlantLocalOffset = {
                X = x,
                Y = y,
                Z = z,
            }
        end
    end

    return true
end

local function SaveUISettings(reason)

    if CanUseFiles() ~= true then
        return false
    end

    EnsureSettingsFolder()

    local payload = {
        DPIScale =
            tonumber(UIState.DPIScale)
            or 100,

        ShopAutoBuySeeds =
            UIState.ShopAutoBuySeeds == true,

        ShopAutoBuyGear =
            UIState.ShopAutoBuyGear == true,

        ShopAutoBuyCrates =
            UIState.ShopAutoBuyCrates == true,

        ShopSeeds =
            SettingsNormalizeStringList(
                UIState.ShopSeeds,
                {
                    "Carrot",
                }
            ),

        ShopGear =
            SettingsNormalizeStringList(
                UIState.ShopGear,
                {}
            ),

        ShopCrates =
            SettingsNormalizeStringList(
                UIState.ShopCrates,
                {}
            ),

        ShopBuyDelay =
            SettingsNormalizeNumber(
                UIState.ShopBuyDelay,
                0.35,
                0.1,
                10
            ),

        ShopMaxBuysPerRestock =
            math.floor(
                SettingsNormalizeNumber(
                    UIState.ShopMaxBuysPerRestock,
                    1,
                    1,
                    999
                )
            ),

        SellAutoMaxBackpack =
            UIState.SellAutoMaxBackpack == true,

        SellDelay =
            SettingsNormalizeNumber(
                UIState.SellDelay,
                0.5,
                0.1,
                10
            ),

        SellDebug =
            UIState.SellDebug == true,

        FarmAutoPlant =
            UIState.FarmAutoPlant == true,

        FarmAutoCollect =
            UIState.FarmAutoCollect == true,

        FarmCollectDelay =
            SettingsNormalizeNumber(
                UIState.FarmCollectDelay,
                0.5,
                0.1,
                10
            ),

        FarmCollectPlants =
            SettingsNormalizeStringList(
                UIState.FarmCollectPlants,
                {}
            ),

        FarmSelectedSeed =
            CleanText(UIState.FarmSelectedSeed) ~= ""
            and CleanText(UIState.FarmSelectedSeed)
            or "Carrot",

        FarmSelectedSeeds =
            SettingsNormalizeStringList(
                UIState.FarmSelectedSeeds,
                {
                    CleanText(UIState.FarmSelectedSeed) ~= ""
                    and CleanText(UIState.FarmSelectedSeed)
                    or "Carrot",
                }
            ),

        FarmPlantDelay =
            math.clamp(
                tonumber(UIState.FarmPlantDelay)
                or 0.35,
                0.1,
                10
            ),

        FarmRandomPosition =
            UIState.FarmRandomPosition == true,

        FarmPlantLocalOffset =
            type(UIState.FarmPlantLocalOffset) == "table"
            and UIState.FarmPlantLocalOffset
            or nil,

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
                SETTINGS_FILE,
                encoded
            )
        end)

    return writeOk == true
end

LoadUISettings()

local function ScaleToChoice(scale)

    scale =
        math.clamp(
            math.floor(
                tonumber(scale)
                or 100
            ),
            50,
            125
        )

    return tostring(scale) .. "%"
end

local function ChoiceToScale(choice)

    local number =
        tonumber(
            tostring(choice or ""):match("(%d+)")
        )

    return math.clamp(
        math.floor(number or 100),
        50,
        125
    )
end

--==================================================
-- [4] LIBRARY LOAD
--==================================================

Library =
    loadstring(
        game:HttpGet(LIBRARY_URL)
    )()

getgenv().HOLY_GAG2_LIBRARY =
    Library

--==================================================
-- [5] SERVER HELPERS
--==================================================

local ServerState = {
    Hopping = false,
    LastStatus = "Ready",
}

local StatusLabel =
    nil

local function SetStatus(text)

    ServerState.LastStatus =
        tostring(text or "Ready")

    if StatusLabel
    and type(StatusLabel.SetText) == "function" then

        StatusLabel:SetText(
            '<font color="rgb(196,181,253)"><b>Status:</b></font> '
            .. ServerState.LastStatus
        )
    end
end

local function GetHttp(url)

    url =
        tostring(url or "")

    if url == "" then
        return nil
    end

    local ok, result =
        pcall(function()
            return game:HttpGet(url)
        end)

    if ok == true
    and type(result) == "string"
    and result ~= "" then
        return result
    end

    local httpRequest =
        (syn and syn.request)
        or http_request
        or request
        or (fluxus and fluxus.request)

    if type(httpRequest) ~= "function" then
        return nil
    end

    local requestOk, response =
        pcall(function()

            return httpRequest({
                Url = url,
                Method = "GET",
            })
        end)

    if requestOk ~= true
    or type(response) ~= "table" then
        return nil
    end

    return response.Body
end

local function FindHopServer()

    local placeId =
        game.PlaceId

    local cursor =
        ""

    local candidates =
        {}

    for _ = 1, 5 do

        local url =
            "https://games.roblox.com/v1/games/"
            .. tostring(placeId)
            .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"

        if cursor ~= "" then

            url =
                url
                .. "&cursor="
                .. HttpService:UrlEncode(cursor)
        end

        local body =
            GetHttp(url)

        if type(body) ~= "string"
        or body == "" then
            break
        end

        local decodeOk, data =
            pcall(function()
                return HttpService:JSONDecode(body)
            end)

        if decodeOk ~= true
        or type(data) ~= "table" then
            break
        end

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

                table.insert(
                    candidates,
                    server
                )
            end
        end

        if #candidates > 0 then
            break
        end

        cursor =
            CleanText(data.nextPageCursor)

        if cursor == "" then
            break
        end
    end

    if #candidates <= 0 then
        return nil
    end

    return candidates[
        math.random(1, #candidates)
    ]
end

local function RejoinServer()

    SetStatus("Rejoining current place...")

    Notify(
        "Holy",
        "Rejoining Grow a Garden 2...",
        3
    )

    local ok, err =
        pcall(function()

            TeleportService:Teleport(
                game.PlaceId,
                LOCAL_PLAYER
            )
        end)

    if ok ~= true then

        SetStatus("Rejoin failed.")

        Notify(
            "Teleport Failed",
            tostring(err),
            5
        )
    end
end

local function HopServer()

    if ServerState.Hopping == true then
        return
    end

    ServerState.Hopping =
        true

    SetStatus("Finding server...")

    local server =
        FindHopServer()

    if not server
    or CleanText(server.id) == "" then

        ServerState.Hopping =
            false

        SetStatus("No server found.")

        Notify(
            "Server Hop",
            "Could not find a valid public server.",
            5
        )

        return
    end

    SetStatus(
        "Hopping to "
        .. tostring(server.playing or "?")
        .. "/"
        .. tostring(server.maxPlayers or "?")
        .. " server..."
    )

    Notify(
        "Server Hop",
        "Joining another Grow a Garden 2 server...",
        3
    )

    local ok, err =
        pcall(function()

            TeleportService:TeleportToPlaceInstance(
                game.PlaceId,
                tostring(server.id),
                LOCAL_PLAYER
            )
        end)

    if ok ~= true then

        ServerState.Hopping =
            false

        SetStatus("Hop failed.")

        Notify(
            "Hop Failed",
            tostring(err),
            5
        )
    end
end

local function CopyJobId()

    local clipboard =
        setclipboard
        or toclipboard
        or set_clipboard

    if type(clipboard) ~= "function" then

        Notify(
            "Clipboard",
            "Clipboard is not supported by this executor.",
            4
        )

        return false
    end

    clipboard(
        tostring(game.JobId)
    )

    Notify(
        "Copied",
        "JobId copied to clipboard.",
        3
    )

    return true
end

--==================================================
-- [5.5] SHOP AUTOMATION HELPERS
--==================================================

local ShopStatusLabel =
    nil

local ShopStockLabel =
    nil

local ShopConfig = {
    AutoBuySeeds =
        UIState.ShopAutoBuySeeds == true,

    AutoBuyGear =
        UIState.ShopAutoBuyGear == true,

    AutoBuyCrates =
        UIState.ShopAutoBuyCrates == true,

    Seeds =
        SettingsNormalizeStringList(
            UIState.ShopSeeds,
            {
                "Carrot",
            }
        ),

    Gear =
        SettingsNormalizeStringList(
            UIState.ShopGear,
            {}
        ),

    Crates =
        SettingsNormalizeStringList(
            UIState.ShopCrates,
            {}
        ),

    BuyDelay =
        SettingsNormalizeNumber(
            UIState.ShopBuyDelay,
            0.35,
            0.1,
            10
        ),

    MaxBuysPerRestock =
        math.floor(
            SettingsNormalizeNumber(
                UIState.ShopMaxBuysPerRestock,
                1,
                1,
                999
            )
        ),
}

local ShopAutomationState = {
    Running = false,
    Packets = nil,
    PacketSource = "not loaded",
    LastSheckles = nil,

    LocalBuys = {
        Seeds = {},
        Gears = {},
        Crates = {},
    },

    LastRestockKeys = {
        SeedShop = nil,
        GearShop = nil,
        CrateShop = nil,
    },
}

local function NormalizeShopList(value, fallback)

    local result =
        {}

    if type(value) == "table" then

        for _, item in ipairs(value) do

            item =
                CleanText(item)

            if item ~= ""
            and table.find(result, item) == nil then

                table.insert(
                    result,
                    item
                )
            end
        end

        for key, enabled in pairs(value) do

            if enabled == true then

                local item =
                    CleanText(key)

                if item ~= ""
                and table.find(result, item) == nil then

                    table.insert(
                        result,
                        item
                    )
                end
            end
        end
    end

    if #result <= 0
    and type(fallback) == "table" then

        for _, item in ipairs(fallback) do

            item =
                CleanText(item)

            if item ~= ""
            and table.find(result, item) == nil then

                table.insert(
                    result,
                    item
                )
            end
        end
    end

    table.sort(result)

    return result
end

local function NormalizeShopNumber(value, defaultValue, minValue, maxValue)

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

local function SetShopStatus(text)

    local status =
        tostring(text or "Ready")

    if ShopStatusLabel
    and type(ShopStatusLabel.SetText) == "function" then

        ShopStatusLabel:SetText(
            '<font color="rgb(196,181,253)"><b>Shop Status:</b></font> '
            .. status
        )
    end
end

local function SafePairsSnapshot(value)

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

local function SafeRawGet(value, key)

    if type(value) ~= "table" then
        return nil
    end

    local ok, result =
        pcall(function()
            return rawget(value, key)
        end)

    if ok == true then
        return result
    end

    return nil
end

local function IsPacketObject(value)

    if type(value) ~= "table" then
        return false
    end

    return type(SafeRawGet(value, "Name")) == "string"
        and SafeRawGet(value, "Id") ~= nil
        and type(SafeRawGet(value, "Writes")) == "table"
end

local function HasShopPackets(candidate)

    if type(candidate) ~= "table" then
        return false
    end

    local seedShop =
        SafeRawGet(candidate, "SeedShop")

    local gearShop =
        SafeRawGet(candidate, "GearShop")

    local crateShop =
        SafeRawGet(candidate, "CrateShop")

    return type(seedShop) == "table"
        and type(gearShop) == "table"
        and type(crateShop) == "table"
        and IsPacketObject(SafeRawGet(seedShop, "PurchaseSeed"))
        and IsPacketObject(SafeRawGet(gearShop, "PurchaseGear"))
        and IsPacketObject(SafeRawGet(crateShop, "PurchaseCrate"))
end

local function SearchPacketTable(candidate, seen, depth)

    if type(candidate) ~= "table" then
        return nil
    end

    if depth > 5 then
        return nil
    end

    if seen[candidate] == true then
        return nil
    end

    seen[candidate] =
        true

    if HasShopPackets(candidate) == true then
        return candidate
    end

    for _, row in ipairs(SafePairsSnapshot(candidate)) do

        if type(row.Value) == "table" then

            local found =
                SearchPacketTable(
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

local function FindHolyGAG2Packets()

    if HasShopPackets(ShopAutomationState.Packets) == true then
        return ShopAutomationState.Packets
    end

    if type(getloadedmodules) ~= "function" then

        ShopAutomationState.PacketSource =
            "getloadedmodules unsupported"

        return nil
    end

    local okModules, modules =
        pcall(getloadedmodules)

    if okModules ~= true
    or type(modules) ~= "table" then

        ShopAutomationState.PacketSource =
            "getloadedmodules failed"

        return nil
    end

    for _, module in ipairs(modules) do

        if typeof(module) == "Instance"
        and module:IsA("ModuleScript") then

            local okRequire, result =
                pcall(function()
                    return require(module)
                end)

            if okRequire == true then

                local found =
                    SearchPacketTable(
                        result,
                        {},
                        0
                    )

                if found then

                    ShopAutomationState.Packets =
                        found

                    ShopAutomationState.PacketSource =
                        "require: " .. module:GetFullName()

                    return found
                end

                if type(result) == "table"
                and type(debug) == "table"
                and type(debug.getupvalues) == "function" then

                    for _, row in ipairs(SafePairsSnapshot(result)) do

                        if type(row.Value) == "function" then

                            local okUpvalues, upvalues =
                                pcall(function()
                                    return debug.getupvalues(row.Value)
                                end)

                            if okUpvalues == true
                            and type(upvalues) == "table" then

                                for upKey, upValue in pairs(upvalues) do

                                    found =
                                        SearchPacketTable(
                                            upValue,
                                            {},
                                            0
                                        )

                                    if found then

                                        ShopAutomationState.Packets =
                                            found

                                        ShopAutomationState.PacketSource =
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

    ShopAutomationState.PacketSource =
        "packet table not found"

    return nil
end

local function GetStockFolder(shopName)

    local stockRoot =
        ReplicatedStorage:FindFirstChild("StockValues")

    local shopFolder =
        stockRoot
        and stockRoot:FindFirstChild(shopName)

    return shopFolder
        and shopFolder:FindFirstChild("Items")
end

local function GetShopItemNames(shopName)

    local itemsFolder =
        GetStockFolder(shopName)

    local names =
        {}

    if itemsFolder then

        for _, child in ipairs(itemsFolder:GetChildren()) do

            if child:IsA("ValueBase") then

                table.insert(
                    names,
                    child.Name
                )
            end
        end
    end

    table.sort(names)

    return names
end

local function GetShopItemStock(shopName, itemName)

    local itemsFolder =
        GetStockFolder(shopName)

    local item =
        itemsFolder
        and itemsFolder:FindFirstChild(itemName)

    if item
    and item:IsA("ValueBase") then
        return tonumber(item.Value)
    end

    return nil
end

local function GetRestockKey(shopName)

    local stockRoot =
        ReplicatedStorage:FindFirstChild("StockValues")

    local shopFolder =
        stockRoot
        and stockRoot:FindFirstChild(shopName)

    local keyValue =
        shopFolder
        and shopFolder:FindFirstChild("UnixLastRestock")

    if keyValue
    and keyValue:IsA("ValueBase") then
        return tostring(keyValue.Value)
    end

    return "0"
end

local function ResetLocalBuysIfRestocked()

    local shopToCategory = {
        SeedShop = "Seeds",
        GearShop = "Gears",
        CrateShop = "Crates",
    }

    for shopName, category in pairs(shopToCategory) do

        local key =
            GetRestockKey(shopName)

        if ShopAutomationState.LastRestockKeys[shopName] ~= key then

            ShopAutomationState.LastRestockKeys[shopName] =
                key

            ShopAutomationState.LocalBuys[category] =
                {}
        end
    end
end

local function GetLocalBuyCount(category, itemName)

    local categoryTable =
        ShopAutomationState.LocalBuys[category]

    if type(categoryTable) ~= "table" then
        return 0
    end

    return tonumber(categoryTable[itemName])
        or 0
end

local function MarkLocalBuy(category, itemName)

    ShopAutomationState.LocalBuys[category] =
        ShopAutomationState.LocalBuys[category]
        or {}

    ShopAutomationState.LocalBuys[category][itemName] =
        GetLocalBuyCount(category, itemName)
        + 1
end

local function GetPurchasePacket(category)

    local packets =
        FindHolyGAG2Packets()

    if not packets then
        return nil, ShopAutomationState.PacketSource
    end

    if category == "Seeds" then

        local group =
            SafeRawGet(packets, "SeedShop")

        return SafeRawGet(group, "PurchaseSeed"),
            ShopAutomationState.PacketSource
    end

    if category == "Gears" then

        local group =
            SafeRawGet(packets, "GearShop")

        return SafeRawGet(group, "PurchaseGear"),
            ShopAutomationState.PacketSource
    end

    if category == "Crates" then

        local group =
            SafeRawGet(packets, "CrateShop")

        return SafeRawGet(group, "PurchaseCrate"),
            ShopAutomationState.PacketSource
    end

    return nil, "unknown category"
end

local function FirePurchasePacket(category, itemName)

    local packet, source =
        GetPurchasePacket(category)

    if not packet then
        return false, "missing packet: " .. tostring(source)
    end

    local okFireLookup, fireFunction =
        pcall(function()
            return packet.Fire
        end)

    if okFireLookup ~= true
    or type(fireFunction) ~= "function" then
        return false, "packet.Fire missing"
    end

    local okFire, err =
        pcall(function()

            fireFunction(
                packet,
                itemName
            )
        end)

    if okFire ~= true then
        return false, tostring(err)
    end

    return true, "fired"
end

local function AnyShopAutomationEnabled()

    return ShopConfig.AutoBuySeeds == true
        or ShopConfig.AutoBuyGear == true
        or ShopConfig.AutoBuyCrates == true
end

local function BuildShopStockPreviewText()

    local lines = {
        '<font color="rgb(196,181,253)"><b>Selected Stock Preview</b></font>',
        "Packet: " .. tostring(ShopAutomationState.PacketSource),
    }

    local groups = {
        {
            Title = "Seeds",
            Shop = "SeedShop",
            Items = ShopConfig.Seeds,
        },
        {
            Title = "Gear",
            Shop = "GearShop",
            Items = ShopConfig.Gear,
        },
        {
            Title = "Crates",
            Shop = "CrateShop",
            Items = ShopConfig.Crates,
        },
    }

    for _, group in ipairs(groups) do

        table.insert(
            lines,
            "\n" .. group.Title .. ":"
        )

        if type(group.Items) ~= "table"
        or #group.Items <= 0 then

            table.insert(
                lines,
                "  none selected"
            )
        else

            for _, itemName in ipairs(group.Items) do

                table.insert(
                    lines,
                    "  "
                    .. tostring(itemName)
                    .. " = "
                    .. tostring(GetShopItemStock(group.Shop, itemName) or "?")
                    .. " stock"
                )
            end
        end
    end

    if ShopAutomationState.LastSheckles ~= nil then

        table.insert(
            lines,
            "\nSheckles: " .. tostring(ShopAutomationState.LastSheckles)
        )
    end

    return table.concat(lines, "\n")
end

local function RefreshShopStockPreview()

    if ShopStockLabel
    and type(ShopStockLabel.SetText) == "function" then

        ShopStockLabel:SetText(
            BuildShopStockPreviewText()
        )
    end
end

local function ProcessShopCategory(category, shopName, selectedItems)

    if type(selectedItems) ~= "table"
    or #selectedItems <= 0 then
        return false
    end

    local maxBuys =
        math.max(
            1,
            math.floor(
                tonumber(ShopConfig.MaxBuysPerRestock)
                or 1
            )
        )

    local delay =
        NormalizeShopNumber(
            ShopConfig.BuyDelay,
            0.35,
            0.1,
            10
        )

    local attempted =
        false

    for _, itemName in ipairs(selectedItems) do

        if AnyShopAutomationEnabled() ~= true then
            return attempted
        end

        itemName =
            CleanText(itemName)

        if itemName ~= "" then

            local stock =
                GetShopItemStock(shopName, itemName)

            local localBought =
                GetLocalBuyCount(category, itemName)

            if stock ~= nil
            and stock <= 0 then

                -- no stock

            elseif localBought >= maxBuys then

                -- local cap reached for this restock

            else

                SetShopStatus(
                    "Buying "
                    .. itemName
                    .. " ("
                    .. category
                    .. ")..."
                )

                local ok, err =
                    FirePurchasePacket(
                        category,
                        itemName
                    )

                attempted =
                    true

                if ok == true then

                    MarkLocalBuy(
                        category,
                        itemName
                    )

                    SetShopStatus(
                        "Fired buy: "
                        .. itemName
                        .. " ("
                        .. category
                        .. ")"
                    )
                else

                    SetShopStatus(
                        "Buy failed: "
                        .. itemName
                        .. " | "
                        .. tostring(err)
                    )
                end

                RefreshShopStockPreview()

                task.wait(delay)
            end
        end
    end

    return attempted
end

local function StartShopAutomationLoop()

    if ShopAutomationState.Running == true then
        return
    end

    ShopAutomationState.Running =
        true

    task.spawn(function()

        SetShopStatus("Auto-buy loop started.")

        while AnyShopAutomationEnabled() == true do

            ResetLocalBuysIfRestocked()

            local attempted =
                false

            if ShopConfig.AutoBuySeeds == true then

                attempted =
                    ProcessShopCategory(
                        "Seeds",
                        "SeedShop",
                        ShopConfig.Seeds
                    )
                    or attempted
            end

            if ShopConfig.AutoBuyGear == true then

                attempted =
                    ProcessShopCategory(
                        "Gears",
                        "GearShop",
                        ShopConfig.Gear
                    )
                    or attempted
            end

            if ShopConfig.AutoBuyCrates == true then

                attempted =
                    ProcessShopCategory(
                        "Crates",
                        "CrateShop",
                        ShopConfig.Crates
                    )
                    or attempted
            end

            if attempted == false then

                SetShopStatus(
                    "Waiting for stock / selections / restock..."
                )

                RefreshShopStockPreview()

                task.wait(1)
            else
                task.wait(0.25)
            end
        end

        ShopAutomationState.Running =
            false

        SetShopStatus("Auto-buy stopped.")
    end)
end

local function StopAllShopAutomation(seedToggle, gearToggle, crateToggle)

    ShopConfig.AutoBuySeeds =
        false

    ShopConfig.AutoBuyGear =
        false

    ShopConfig.AutoBuyCrates =
        false

    UIState.ShopAutoBuySeeds =
        false

    UIState.ShopAutoBuyGear =
        false

    UIState.ShopAutoBuyCrates =
        false

    SaveUISettings(
        "shop automation stopped"
    )

    local toggles = {
        seedToggle,
        gearToggle,
        crateToggle,
    }

    for _, toggle in ipairs(toggles) do

        if toggle
        and type(toggle.SetValue) == "function" then

            toggle:SetValue(false)
        end
    end

    SetShopStatus("Auto-buy stopped.")
end

local function ConnectShopReplicaWatcher()

    local remoteEvents =
        ReplicatedStorage:FindFirstChild("RemoteEvents")

    local replicaSet =
        remoteEvents
        and remoteEvents:FindFirstChild("ReplicaSet")

    if not replicaSet
    or not replicaSet:IsA("RemoteEvent") then
        return
    end

    replicaSet.OnClientEvent:Connect(function(_, pathArray, value)

        if type(pathArray) ~= "table" then
            return
        end

        if pathArray[1] == "Sheckles" then

            ShopAutomationState.LastSheckles =
                value

            RefreshShopStockPreview()

            return
        end

        if pathArray[1] == "Inventory"
        or pathArray[1] == "PurchasedThisRestock" then

            local category =
                tostring(pathArray[2] or "")

            local itemName =
                tostring(pathArray[3] or "")

            if itemName ~= "" then

                SetShopStatus(
                    tostring(pathArray[1])
                    .. ": "
                    .. category
                    .. " > "
                    .. itemName
                    .. " = "
                    .. tostring(value)
                )

                RefreshShopStockPreview()
            end
        end
    end)
end

ConnectShopReplicaWatcher()

--==================================================
-- [5.55] SELL AUTOMATION HELPERS
--==================================================

local SellStatusLabel =
    nil

local SellInfoLabel =
    nil

local SellAutoToggle =
    nil

local SellConfig = {
    AutoMaxBackpack =
        UIState.SellAutoMaxBackpack == true,

    Delay =
        SettingsNormalizeNumber(
            UIState.SellDelay,
            0.5,
            0.1,
            10
        ),

    Debug =
        UIState.SellDebug == true,
}

local SellState = {
    Running = false,
    SellPacket = nil,
    PacketSource = "not loaded",
    LastFullInventoryAt = 0,
    LastSellAt = 0,
    LastSellResult = "not started",
    LastSheckles = nil,
    WatchedTextObjects = {},
}

local function SellPathOf(instance)

    if typeof(instance) ~= "Instance" then
        return tostring(instance)
    end

    local ok, result =
        pcall(function()
            return instance:GetFullName()
        end)

    if ok == true
    and type(result) == "string" then
        return result
    end

    return tostring(instance)
end

local function SellDebugPrint(...)

    if SellConfig.Debug ~= true then
        return
    end

    print(
        "[HOLY GAG2 SELL]",
        ...
    )
end

local function SetSellStatus(text)

    SellState.LastSellResult =
        tostring(text or "Ready")

    if SellStatusLabel
    and type(SellStatusLabel.SetText) == "function" then

        SellStatusLabel:SetText(
            '<font color="rgb(196,181,253)"><b>Sell Status:</b></font> '
            .. SellState.LastSellResult
        )
    end
end

local function BuildSellInfoText()

    local fullAgo =
        "never"

    if tonumber(SellState.LastFullInventoryAt) ~= nil
    and SellState.LastFullInventoryAt > 0 then

        fullAgo =
            string.format(
                "%.1fs ago",
                os.clock() - SellState.LastFullInventoryAt
            )
    end

    local lastSellAgo =
        "never"

    if tonumber(SellState.LastSellAt) ~= nil
    and SellState.LastSellAt > 0 then

        lastSellAgo =
            string.format(
                "%.1fs ago",
                os.clock() - SellState.LastSellAt
            )
    end

    return
        '<font color="rgb(196,181,253)"><b>Sell Info</b></font>'
        .. '\nAuto Sell Max Backpack: '
        .. tostring(SellConfig.AutoMaxBackpack == true and "ON" or "OFF")
        .. '\nDelay: '
        .. tostring(SellConfig.Delay)
        .. 's'
        .. '\nPacket: '
        .. tostring(SellState.PacketSource)
        .. '\nLast Full Inventory: '
        .. tostring(fullAgo)
        .. '\nLast Sell: '
        .. tostring(lastSellAgo)
        .. '\nLast Result: '
        .. tostring(SellState.LastSellResult)
        .. (
            SellState.LastSheckles ~= nil
            and (
                '\nSheckles: '
                .. tostring(SellState.LastSheckles)
            )
            or ""
        )
end

local function RefreshSellInfo()

    if SellInfoLabel
    and type(SellInfoLabel.SetText) == "function" then

        SellInfoLabel:SetText(
            BuildSellInfoText()
        )
    end
end

local function SellTextIndicatesFullInventory(text)

    text =
        tostring(text or "")
            :lower()

    return text:find("inventory is full", 1, true) ~= nil
        or text:find("your inventory is full", 1, true) ~= nil
        or text:find("backpack is full", 1, true) ~= nil
end

local function SellMarkFullInventory(source)

    SellState.LastFullInventoryAt =
        os.clock()

    SellDebugPrint(
        "Full inventory detected",
        "| source:",
        tostring(source),
        "| time:",
        tostring(SellState.LastFullInventoryAt)
    )

    SetSellStatus(
        "Detected max backpack."
    )

    RefreshSellInfo()
end

local function SellWatchTextObject(object)

    if typeof(object) ~= "Instance" then
        return
    end

    if object:IsA("TextLabel") ~= true
    and object:IsA("TextButton") ~= true
    and object:IsA("TextBox") ~= true then
        return
    end

    if SellState.WatchedTextObjects[object] == true then
        return
    end

    SellState.WatchedTextObjects[object] =
        true

    local function CheckText()

        local ok, text =
            pcall(function()
                return object.Text
            end)

        if ok == true
        and SellTextIndicatesFullInventory(text) == true then

            SellMarkFullInventory(
                SellPathOf(object)
            )
        end
    end

    CheckText()

    pcall(function()

        object:GetPropertyChangedSignal("Text"):Connect(function()

            CheckText()
        end)
    end)
end

local function SellConnectInventoryFullWatcher()

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if not playerGui then
        return
    end

    for _, descendant in ipairs(playerGui:GetDescendants()) do

        SellWatchTextObject(
            descendant
        )
    end

    playerGui.DescendantAdded:Connect(function(descendant)

        task.defer(function()

            SellWatchTextObject(
                descendant
            )
        end)
    end)
end

local function SellScanInventoryFullText()

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if not playerGui then
        return false
    end

    for _, descendant in ipairs(playerGui:GetDescendants()) do

        if descendant:IsA("TextLabel")
        or descendant:IsA("TextButton")
        or descendant:IsA("TextBox") then

            local ok, text =
                pcall(function()
                    return descendant.Text
                end)

            if ok == true
            and SellTextIndicatesFullInventory(text) == true then

                SellMarkFullInventory(
                    SellPathOf(descendant)
                )

                return true
            end
        end
    end

    return false
end

local function SellInventoryIsFull()

    SellScanInventoryFullText()

    return SellState.LastFullInventoryAt > 0
        and (os.clock() - SellState.LastFullInventoryAt) <= 8
end

local function SellPacketScore(packetName)

    packetName =
        tostring(packetName or "")
            :lower()

    local score =
        0

    if packetName:find("sellall", 1, true) then
        score += 100
    end

    if packetName:find("sellinventory", 1, true) then
        score += 90
    end

    if packetName:find("sellfruit", 1, true) then
        score += 80
    end

    if packetName:find("sellfruits", 1, true) then
        score += 80
    end

    if packetName:find("sell", 1, true) then
        score += 60
    end

    if packetName:find("fruit", 1, true) then
        score += 10
    end

    if packetName:find("shop", 1, true) then
        score -= 15
    end

    if packetName:find("purchase", 1, true) then
        score -= 30
    end

    return score
end

local function SellSearchPacketCandidates(candidate, seen, depth, path, results)

    if type(candidate) ~= "table" then
        return
    end

    if depth > 8 then
        return
    end

    if seen[candidate] == true then
        return
    end

    seen[candidate] =
        true

    if IsPacketObject(candidate) == true then

        local packetName =
            tostring(SafeRawGet(candidate, "Name") or "")

        local score =
            SellPacketScore(packetName)

        if score > 0 then

            table.insert(results, {
                Packet = candidate,
                Name = packetName,
                Path = path,
                Score = score,
            })
        end
    end

    for _, row in ipairs(SafePairsSnapshot(candidate)) do

        if type(row.Value) == "table" then

            SellSearchPacketCandidates(
                row.Value,
                seen,
                depth + 1,
                path .. "." .. tostring(row.Key),
                results
            )
        end
    end
end

local function FindSellPacket()

    if SellState.SellPacket
    and type(SellState.SellPacket.Fire) == "function" then
        return SellState.SellPacket
    end

    local packets =
        FindHolyGAG2Packets()

    if not packets then

        SellState.PacketSource =
            "packet table missing: "
            .. tostring(ShopAutomationState.PacketSource)

        RefreshSellInfo()

        return nil
    end

    local results =
        {}

    SellSearchPacketCandidates(
        packets,
        {},
        0,
        "Packets",
        results
    )

    table.sort(results, function(a, b)

        return tonumber(a.Score or 0) > tonumber(b.Score or 0)
    end)

    if #results <= 0 then

        SellState.PacketSource =
            "no sell packet candidate found"

        SellDebugPrint(
            "No sell packet candidates found."
        )

        RefreshSellInfo()

        return nil
    end

    local best =
        results[1]

    SellState.SellPacket =
        best.Packet

    SellState.PacketSource =
        tostring(best.Name)
        .. " @ "
        .. tostring(best.Path)

    SellDebugPrint(
        "Selected sell packet:",
        SellState.PacketSource,
        "score:",
        tostring(best.Score)
    )

    if SellConfig.Debug == true then

        for index, row in ipairs(results) do

            print(
                "[HOLY GAG2 SELL]",
                "candidate",
                tostring(index),
                "name:",
                tostring(row.Name),
                "score:",
                tostring(row.Score),
                "path:",
                tostring(row.Path)
            )

            if index >= 15 then
                break
            end
        end
    end

    RefreshSellInfo()

    return SellState.SellPacket
end

local function FireSellPacket()

    local packet =
        FindSellPacket()

    if not packet then
        return false, SellState.PacketSource
    end

    local okFireLookup, fireFunction =
        pcall(function()
            return packet.Fire
        end)

    if okFireLookup ~= true
    or type(fireFunction) ~= "function" then
        return false, "packet.Fire missing"
    end

    SellDebugPrint(
        "Firing sell packet",
        tostring(SellState.PacketSource)
    )

    local okFire, err =
        pcall(function()

            fireFunction(
                packet
            )
        end)

    if okFire ~= true then

        SellDebugPrint(
            "Sell packet failed",
            tostring(err)
        )

        return false, tostring(err)
    end

    SellState.LastSellAt =
        os.clock()

    SellDebugPrint(
        "Sell packet fired OK",
        tostring(SellState.PacketSource)
    )

    return true, "fired " .. tostring(SellState.PacketSource)
end

local function SellOnce(reason)

    reason =
        tostring(reason or "manual")

    local ok, info =
        FireSellPacket()

    if ok == true then

        SetSellStatus(
            "Sell fired: "
            .. reason
        )

    else

        SetSellStatus(
            "Sell failed: "
            .. tostring(info)
        )
    end

    SellDebugPrint(
        "SellOnce",
        "reason:",
        reason,
        "ok:",
        tostring(ok),
        "info:",
        tostring(info)
    )

    RefreshSellInfo()

    return ok
end

local function StartSellAutomationLoop()

    if SellState.Running == true then
        return
    end

    SellState.Running =
        true

    task.spawn(function()

        SetSellStatus("Auto sell loop started.")

        while SellConfig.AutoMaxBackpack == true do

            local full =
                SellInventoryIsFull()

            if full == true then

                local sinceLastSell =
                    os.clock() - tonumber(SellState.LastSellAt or 0)

                if sinceLastSell >= 2 then

                    SellOnce(
                        "max backpack"
                    )

                    task.wait(1.25)

                else

                    SetSellStatus(
                        "Inventory full, waiting sell cooldown..."
                    )
                end

            else

                SetSellStatus(
                    "Waiting for max backpack..."
                )
            end

            RefreshSellInfo()

            task.wait(
                SettingsNormalizeNumber(
                    SellConfig.Delay,
                    0.5,
                    0.1,
                    10
                )
            )
        end

        SellState.Running =
            false

        SetSellStatus("Auto sell stopped.")
    end)
end

local function StopSellAutomation()

    SellConfig.AutoMaxBackpack =
        false

    UIState.SellAutoMaxBackpack =
        false

    SaveUISettings(
        "sell auto max backpack stopped"
    )

    if SellAutoToggle
    and type(SellAutoToggle.SetValue) == "function" then

        SellAutoToggle:SetValue(false)
    end

    SetSellStatus("Auto sell stopped.")
    RefreshSellInfo()
end

local function SellConnectReplicaWatcher()

    local remoteEvents =
        ReplicatedStorage:FindFirstChild("RemoteEvents")

    local replicaSet =
        remoteEvents
        and remoteEvents:FindFirstChild("ReplicaSet")

    if not replicaSet
    or not replicaSet:IsA("RemoteEvent") then
        return
    end

    replicaSet.OnClientEvent:Connect(function(_, pathArray, value)

        if type(pathArray) ~= "table" then
            return
        end

        if pathArray[1] == "Sheckles" then

            SellState.LastSheckles =
                value

            RefreshSellInfo()
        end
    end)
end

SellConnectInventoryFullWatcher()
SellConnectReplicaWatcher()

--==================================================
-- [5.6] FARM AUTOMATION HELPERS
--==================================================

local FarmStatusLabel =
    nil

local FarmPositionLabel =
    nil

local FarmAutomationToggle =
    nil

local FarmCollectToggle =
    nil

local FarmCollectPlantsDropdown =
    nil

local FarmSeedDropdown =
    nil

local FarmPositionPickerConnection =
    nil

local FarmAutomationState = {
    Running = false,
    CollectRunning = false,
    PlantSeedPacket = nil,
    PacketSource = "not loaded",
    LastCollectCount = 0,
    LastCollectSource = "not started",
}

local function FarmVectorFromPayload(payload)

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

    if not x
    or not y
    or not z then
        return nil
    end

    return Vector3.new(
        x,
        y,
        z
    )
end

local function FarmVectorToPayload(vector)

    return {
        X = vector.X,
        Y = vector.Y,
        Z = vector.Z,
    }
end

local FarmConfig = {
    AutoPlant =
        UIState.FarmAutoPlant == true,

    AutoCollect =
        UIState.FarmAutoCollect == true,

    CollectDelay =
        SettingsNormalizeNumber(
            UIState.FarmCollectDelay,
            0.5,
            0.1,
            10
        ),

    CollectPlants =
        SettingsNormalizeStringList(
            UIState.FarmCollectPlants,
            {}
        ),

    CollectDebug =
        false,

    SelectedSeed =
        CleanText(UIState.FarmSelectedSeed) ~= ""
        and CleanText(UIState.FarmSelectedSeed)
        or "Carrot",

    SelectedSeeds =
        SettingsNormalizeStringList(
            UIState.FarmSelectedSeeds,
            {
                CleanText(UIState.FarmSelectedSeed) ~= ""
                and CleanText(UIState.FarmSelectedSeed)
                or "Carrot",
            }
        ),

    PlantDelay =
        math.clamp(
            tonumber(UIState.FarmPlantDelay)
            or 0.35,
            0.1,
            10
        ),

    RandomPosition =
        UIState.FarmRandomPosition == true,

    PlantLocalOffset =
        FarmVectorFromPayload(
            UIState.FarmPlantLocalOffset
        ),
}

local function FarmPathOf(instance)

    if typeof(instance) ~= "Instance" then
        return tostring(instance)
    end

    local ok, result =
        pcall(function()
            return instance:GetFullName()
        end)

    return ok and result or tostring(instance)
end

local function FarmStripRichText(value)

    return tostring(value or "")
        :gsub("<[^>]->", "")
        :gsub("<.->", "")
end

local function FarmSafeRawGet(value, key)

    if type(value) ~= "table" then
        return nil
    end

    local ok, result =
        pcall(function()
            return rawget(value, key)
        end)

    if ok == true then
        return result
    end

    return nil
end

local function FarmVectorText(vector)

    if typeof(vector) ~= "Vector3" then
        return "not set"
    end

    return string.format(
        "Vector3.new(%.3f, %.3f, %.3f)",
        vector.X,
        vector.Y,
        vector.Z
    )
end

local function FarmGetSelectedSeeds()

    FarmConfig.SelectedSeeds =
        SettingsNormalizeStringList(
            FarmConfig.SelectedSeeds,
            {
                CleanText(FarmConfig.SelectedSeed) ~= ""
                and CleanText(FarmConfig.SelectedSeed)
                or "Carrot",
            }
        )

    if #FarmConfig.SelectedSeeds > 0 then

        FarmConfig.SelectedSeed =
            FarmConfig.SelectedSeeds[1]
    end

    return FarmConfig.SelectedSeeds
end

local function FarmSelectedSeedsText()

    local seeds =
        FarmGetSelectedSeeds()

    if #seeds <= 0 then
        return "none selected"
    end

    return table.concat(
        seeds,
        ", "
    )
end

local function FarmSetStatus(text)

    local status =
        tostring(text or "Ready")

    if FarmStatusLabel
    and type(FarmStatusLabel.SetText) == "function" then

        FarmStatusLabel:SetText(
            '<font color="rgb(196,181,253)"><b>Farm Status:</b></font> '
            .. status
        )
    end
end

local function FarmResolveOwnPlot()

    local gardens =
        workspace:FindFirstChild("Gardens")

    local playerGui =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChildOfClass("PlayerGui")

    if not gardens
    or not playerGui then
        return nil, "missing Gardens or PlayerGui"
    end

    for _, gui in ipairs(playerGui:GetChildren()) do

        if gui:IsA("BillboardGui")
        and tostring(gui.Name):match("^Plot%d+$") then

            for _, descendant in ipairs(gui:GetDescendants()) do

                if descendant:IsA("TextLabel")
                or descendant:IsA("TextButton") then

                    local text =
                        FarmStripRichText(
                            descendant.Text
                        ):lower()

                    if text:find("your garden", 1, true) then

                        local plot =
                            gardens:FindFirstChild(gui.Name)

                        if plot then
                            return plot, "billboard: " .. gui.Name
                        end
                    end
                end
            end
        end
    end

    return nil, "no Your Garden billboard found"
end

local function FarmGetPlotFrame(plot)

    if not plot
    or not plot:IsA("Model") then
        return nil
    end

    local ok, cf =
        pcall(function()
            return plot:GetBoundingBox()
        end)

    if ok == true
    and typeof(cf) == "CFrame" then
        return cf
    end

    return nil
end

local function FarmGetWorldPlantPosition()

    if typeof(FarmConfig.PlantLocalOffset) ~= "Vector3" then
        return nil, nil, "plant position not selected"
    end

    local ownPlot, plotReason =
        FarmResolveOwnPlot()

    if not ownPlot then
        return nil, nil, plotReason
    end

    local plotFrame =
        FarmGetPlotFrame(ownPlot)

    if not plotFrame then
        return nil, ownPlot, "could not get plot frame"
    end

    return plotFrame:PointToWorldSpace(
        FarmConfig.PlantLocalOffset
    ),
    ownPlot,
    "resolved in " .. FarmPathOf(ownPlot)
end

local function FarmRaycastPlantPosition(position)

    if typeof(position) ~= "Vector3" then
        return nil
    end

    local params =
        RaycastParams.new()

    params.FilterType =
        Enum.RaycastFilterType.Exclude

    params.FilterDescendantsInstances =
        {
            LOCAL_PLAYER.Character,
        }

    params.IgnoreWater =
        true

    return workspace:Raycast(
        position + Vector3.new(0, 15, 0),
        Vector3.new(0, -60, 0),
        params
    )
end

local function FarmValidateRayHit(rayResult, ownPlot)

    if not rayResult
    or not rayResult.Instance
    or not ownPlot then
        return false, "missing ray hit or own plot"
    end

    if rayResult.Instance:IsDescendantOf(ownPlot) ~= true then
        return false, "point is not inside your current garden"
    end

    local hitPath =
        FarmPathOf(rayResult.Instance)

    if hitPath:find(".Plants.", 1, true) then
        return false, "clicked existing plant, not soil"
    end

    if hitPath:find("GardenZonePart", 1, true) then
        return false, "clicked garden wall/zone"
    end

    if hitPath:find("PlantArea", 1, true)
    or hitPath:find("BedSection", 1, true) then
        return true, "valid plant area"
    end

    return false, "inside garden but not recognized plant bed"
end

local function FarmValidateCurrentPlantPoint()

    local worldPosition, ownPlot, reason =
        FarmGetWorldPlantPosition()

    if not worldPosition then
        return false, reason
    end

    local rayResult =
        FarmRaycastPlantPosition(
            worldPosition
        )

    local valid, validReason =
        FarmValidateRayHit(
            rayResult,
            ownPlot
        )

    if valid ~= true then
        return false, validReason
    end

    return true,
        "valid: "
        .. FarmPathOf(rayResult.Instance),
        worldPosition
end

local function FarmIsPlantAreaPart(part)

    if not part
    or not part:IsA("BasePart") then
        return false
    end

    local fullPath =
        FarmPathOf(part)

    if fullPath:find("GardenZonePart", 1, true) then
        return false
    end

    if fullPath:find(".Plants.", 1, true) then
        return false
    end

    return fullPath:find("PlantArea", 1, true) ~= nil
        or fullPath:find("BedSection", 1, true) ~= nil
end

local function FarmGetPlantAreaParts(ownPlot)

    local parts =
        {}

    if not ownPlot then
        return parts
    end

    for _, descendant in ipairs(ownPlot:GetDescendants()) do

        if FarmIsPlantAreaPart(descendant) == true then

            table.insert(
                parts,
                descendant
            )
        end
    end

    return parts
end

local function FarmRaycastRandomPlantPosition(position, ownPlot)

    if typeof(position) ~= "Vector3" then
        return nil
    end

    local ignoreList = {
        LOCAL_PLAYER.Character,
    }

    if ownPlot then

        local plantsFolder =
            ownPlot:FindFirstChild("Plants")

        if plantsFolder then

            table.insert(
                ignoreList,
                plantsFolder
            )
        end
    end

    local params =
        RaycastParams.new()

    params.FilterType =
        Enum.RaycastFilterType.Exclude

    params.FilterDescendantsInstances =
        ignoreList

    params.IgnoreWater =
        true

    return workspace:Raycast(
        position + Vector3.new(0, 25, 0),
        Vector3.new(0, -80, 0),
        params
    )
end

local function FarmRandomPointOnPart(part)

    local size =
        part.Size

    local marginX =
        math.min(
            size.X * 0.2,
            1.5
        )

    local marginZ =
        math.min(
            size.Z * 0.2,
            1.5
        )

    local halfX =
        math.max(
            0.05,
            (size.X * 0.5) - marginX
        )

    local halfZ =
        math.max(
            0.05,
            (size.Z * 0.5) - marginZ
        )

    local localPoint =
        Vector3.new(
            (math.random() * 2 - 1) * halfX,
            (size.Y * 0.5) + 0.05,
            (math.random() * 2 - 1) * halfZ
        )

    return part.CFrame:PointToWorldSpace(
        localPoint
    )
end

local function FarmGetRandomPlantPosition()

    local ownPlot, plotReason =
        FarmResolveOwnPlot()

    if not ownPlot then
        return nil, "no own plot: " .. tostring(plotReason)
    end

    local plantParts =
        FarmGetPlantAreaParts(
            ownPlot
        )

    if #plantParts <= 0 then
        return nil, "no plant area parts found"
    end

    local lastReason =
        "no valid random point found"

    for _ = 1, 60 do

        local part =
            plantParts[
                math.random(1, #plantParts)
            ]

        local candidate =
            FarmRandomPointOnPart(
                part
            )

        local rayResult =
            FarmRaycastRandomPlantPosition(
                candidate,
                ownPlot
            )

        local valid, reason =
            FarmValidateRayHit(
                rayResult,
                ownPlot
            )

        if valid == true then

            return rayResult.Position,
                "random: " .. FarmPathOf(rayResult.Instance)
        end

        lastReason =
            reason
    end

    return nil, lastReason
end

local function FarmRefreshPositionLabel()

    if FarmPositionLabel
    and type(FarmPositionLabel.SetText) == "function" then

        local valid =
            false

        local reason =
            "not checked"

        local worldPosition =
            nil

        if FarmConfig.RandomPosition == true then

            worldPosition, reason =
                FarmGetRandomPlantPosition()

            valid =
                worldPosition ~= nil

        else

            valid, reason, worldPosition =
                FarmValidateCurrentPlantPoint()
        end

        local offsetText =
            FarmConfig.PlantLocalOffset
            and FarmVectorText(FarmConfig.PlantLocalOffset)
            or "not set"

        local worldText =
            worldPosition
            and FarmVectorText(worldPosition)
            or "not resolved"

        FarmPositionLabel:SetText(
            '<font color="rgb(196,181,253)"><b>Farm Settings</b></font>'
            .. '\nSeeds: '
            .. FarmSelectedSeedsText()
            .. '\nPlant Delay: '
            .. tostring(FarmConfig.PlantDelay)
            .. 's'
            .. '\nAuto Collect: '
            .. tostring(FarmConfig.AutoCollect == true and "ON" or "OFF")
            .. '\nCollect Delay: '
            .. tostring(FarmConfig.CollectDelay)
            .. 's'
            .. '\nCollect Plants: '
            .. (
                type(FarmSelectedCollectPlantsText) == "function"
                and FarmSelectedCollectPlantsText()
                or (
                    type(FarmConfig.CollectPlants) == "table"
                    and #FarmConfig.CollectPlants > 0
                    and table.concat(FarmConfig.CollectPlants, ", ")
                    or "all plants"
                )
            )
            .. '\nLast Collect: '
            .. tostring(FarmAutomationState.LastCollectCount or 0)
            .. ' via '
            .. tostring(FarmAutomationState.LastCollectSource or "none")
            .. '\nRandom Position: '
            .. tostring(FarmConfig.RandomPosition == true and "ON" or "OFF")
            .. '\nRelative Offset: '
            .. offsetText
            .. '\nCurrent World Point: '
            .. worldText
            .. '\nPosition: '
            .. (valid == true and "VALID" or "INVALID")
            .. ' | '
            .. tostring(reason)
            .. '\nPacket: '
            .. tostring(FarmAutomationState.PacketSource)
        )
    end
end

local function FarmGetOwnedSeedTools()

    local results =
        {}

    local containers = {
        LOCAL_PLAYER and LOCAL_PLAYER:FindFirstChildOfClass("Backpack"),
        LOCAL_PLAYER and LOCAL_PLAYER.Character,
    }

    for _, container in ipairs(containers) do

        if container then

            for _, child in ipairs(container:GetChildren()) do

                if child:IsA("Tool")
                and child:GetAttribute("SeedTool") then

                    table.insert(
                        results,
                        child
                    )
                end
            end
        end
    end

    return results
end

local function FarmGetOwnedSeedNames()

    local names =
        {}

    local function AddSeedName(seedName)

        seedName =
            CleanText(seedName)

        if seedName == "" then
            return
        end

        if table.find(names, seedName) ~= nil then
            return
        end

        table.insert(
            names,
            seedName
        )
    end

    -- Main source: full seed shop item list.
    -- This lets you select seeds before you own them,
    -- so Auto Plant can wait until Auto Buy gives you the tool.
    for _, seedName in ipairs(GetShopItemNames("SeedShop")) do

        AddSeedName(
            seedName
        )
    end

    -- Backup/extra source: actual owned seed tools.
    -- Keeps event/special seeds visible if they are not inside StockValues.
    for _, tool in ipairs(FarmGetOwnedSeedTools()) do

        AddSeedName(
            tool:GetAttribute("SeedTool")
        )
    end

    -- Preserve saved selected seeds even if the game has not loaded StockValues yet.
    for _, selectedSeed in ipairs(FarmGetSelectedSeeds()) do

        AddSeedName(
            selectedSeed
        )
    end

    if #names <= 0 then

        AddSeedName(
            "Carrot"
        )
    end

    table.sort(names)

    return names
end

local function FarmFindSeedTool(seedName)

    seedName =
        CleanText(seedName)

    if seedName == "" then
        return nil
    end

    for _, tool in ipairs(FarmGetOwnedSeedTools()) do

        if CleanText(tool:GetAttribute("SeedTool")) == seedName then
            return tool
        end
    end

    return nil
end

local function FarmGetSeedCount(seedName)

    local tool =
        FarmFindSeedTool(seedName)

    if not tool then
        return 0
    end

    return tonumber(tool:GetAttribute("Count"))
        or 1
end

local function FarmEquipSeedTool(seedName)

    local tool =
        FarmFindSeedTool(seedName)

    if not tool then
        return false, "seed tool missing"
    end

    local character =
        LOCAL_PLAYER.Character

    local humanoid =
        character
        and character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return false, "humanoid missing"
    end

    local ok, err =
        pcall(function()
            humanoid:EquipTool(tool)
        end)

    if ok ~= true then
        return false, tostring(err)
    end

    task.wait(0.15)

    return true, FarmPathOf(tool)
end

local function FarmFindPlantSeedPacket()

    if FarmAutomationState.PlantSeedPacket
    and type(FarmAutomationState.PlantSeedPacket.Fire) == "function" then
        return FarmAutomationState.PlantSeedPacket
    end

    local playerScripts =
        LOCAL_PLAYER
        and LOCAL_PLAYER:FindFirstChild("PlayerScripts")

    local controller =
        playerScripts
        and playerScripts:FindFirstChild("Controllers")
        and playerScripts.Controllers:FindFirstChild("PlantController")

    if not controller then

        FarmAutomationState.PacketSource =
            "PlantController missing"

        return nil
    end

    local okRequire, plantController =
        pcall(function()
            return require(controller)
        end)

    if okRequire ~= true
    or type(plantController) ~= "table" then

        FarmAutomationState.PacketSource =
            "PlantController require failed"

        return nil
    end

    local tryPlant =
        plantController.TryPlantWithRay

    if type(tryPlant) ~= "function" then

        FarmAutomationState.PacketSource =
            "TryPlantWithRay missing"

        return nil
    end

    if type(debug) ~= "table"
    or type(debug.getupvalues) ~= "function" then

        FarmAutomationState.PacketSource =
            "debug.getupvalues unsupported"

        return nil
    end

    local okUpvalues, upvalues =
        pcall(function()
            return debug.getupvalues(tryPlant)
        end)

    if okUpvalues ~= true
    or type(upvalues) ~= "table" then

        FarmAutomationState.PacketSource =
            "getupvalues failed"

        return nil
    end

    for index, value in pairs(upvalues) do

        if type(value) == "table" then

            local plantGroup =
                FarmSafeRawGet(
                    value,
                    "Plant"
                )

            local plantSeed =
                plantGroup
                and FarmSafeRawGet(
                    plantGroup,
                    "PlantSeed"
                )

            if type(plantSeed) == "table"
            and FarmSafeRawGet(plantSeed, "Name") == "PlantSeed"
            and type(plantSeed.Fire) == "function" then

                FarmAutomationState.PlantSeedPacket =
                    plantSeed

                FarmAutomationState.PacketSource =
                    "PlantController.TryPlantWithRay upvalue #"
                    .. tostring(index)

                FarmRefreshPositionLabel()

                return plantSeed
            end
        end
    end

    FarmAutomationState.PacketSource =
        "PlantSeed packet not found"

    FarmRefreshPositionLabel()

    return nil
end

local function FarmFirePlant(seedName, worldPosition)

    local packet =
        FarmFindPlantSeedPacket()

    if not packet then
        return false, FarmAutomationState.PacketSource
    end

    seedName =
        CleanText(seedName)

    if seedName == "" then
        return false, "missing seed name"
    end

    if typeof(worldPosition) ~= "Vector3" then
        return false, "missing world position"
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
        return false, tostring(err)
    end

    return true, "fired"
end

local function FarmSetSelectedSeed(value)

    local selectedSeeds =
        SettingsNormalizeStringList(
            value,
            {}
        )

    FarmConfig.SelectedSeeds =
        selectedSeeds

    if #selectedSeeds > 0 then

        FarmConfig.SelectedSeed =
            selectedSeeds[1]

        UIState.FarmSelectedSeed =
            selectedSeeds[1]

    else

        FarmConfig.SelectedSeed =
            ""

        UIState.FarmSelectedSeed =
            ""
    end

    UIState.FarmSelectedSeeds =
        selectedSeeds

    SaveUISettings(
        "farm seeds changed"
    )

    FarmRefreshPositionLabel()
end

local function FarmSetPlantLocalOffset(localOffset)

    if typeof(localOffset) ~= "Vector3" then
        return
    end

    FarmConfig.PlantLocalOffset =
        localOffset

    UIState.FarmPlantLocalOffset =
        FarmVectorToPayload(localOffset)

    SaveUISettings(
        "farm position changed"
    )

    FarmRefreshPositionLabel()
end

local function FarmSetRandomPosition(value)

    FarmConfig.RandomPosition =
        value == true

    UIState.FarmRandomPosition =
        FarmConfig.RandomPosition

    SaveUISettings(
        "farm random position changed"
    )

    FarmRefreshPositionLabel()

    if FarmConfig.RandomPosition == true then

        FarmSetStatus(
            "Random plant position enabled."
        )

    else

        FarmSetStatus(
            "Random plant position disabled."
        )
    end
end

local function FarmSetPlantDelay(value)

    FarmConfig.PlantDelay =
        math.clamp(
            tonumber(value)
            or 0.35,
            0.1,
            10
        )

    UIState.FarmPlantDelay =
        FarmConfig.PlantDelay

    SaveUISettings(
        "farm delay changed"
    )

    FarmRefreshPositionLabel()
end

local function FarmSetCollectDelay(value)

    FarmConfig.CollectDelay =
        SettingsNormalizeNumber(
            value,
            0.5,
            0.1,
            10
        )

    UIState.FarmCollectDelay =
        FarmConfig.CollectDelay

    SaveUISettings(
        "farm collect delay changed"
    )

    FarmRefreshPositionLabel()
end

local function FarmGetCollectRoot(ownPlot)

    if not ownPlot then
        return nil
    end

    local plantsFolder =
        ownPlot:FindFirstChild("Plants")

    if plantsFolder then
        return plantsFolder
    end

    return ownPlot
end

local function FarmNormalizeCollectPlantName(value)

    local text =
        CleanText(value)

    text =
        text:gsub("%s+[Ss]eed$", "")

    text =
        text:gsub("%s+", " ")

    return CleanText(text)
end

local function FarmCollectPlantKey(value)

    return FarmNormalizeCollectPlantName(value)
        :lower()
        :gsub("%s+", "")
        :gsub("[^%w_]", "")
end

local function FarmGetSelectedCollectPlants()

    FarmConfig.CollectPlants =
        SettingsNormalizeStringList(
            FarmConfig.CollectPlants,
            {}
        )

    return FarmConfig.CollectPlants
end

local function FarmSelectedCollectPlantsText()

    local plants =
        FarmGetSelectedCollectPlants()

    if #plants <= 0 then
        return "all plants"
    end

    return table.concat(
        plants,
        ", "
    )
end

local function FarmSetCollectPlants(value)

    local plants =
        SettingsNormalizeStringList(
            value,
            {}
        )

    FarmConfig.CollectPlants =
        plants

    UIState.FarmCollectPlants =
        plants

    SaveUISettings(
        "farm collect plants changed"
    )

    FarmRefreshPositionLabel()
end

local function FarmAddUniqueCollectPlantName(names, plantName)

    plantName =
        FarmNormalizeCollectPlantName(plantName)

    if plantName == "" then
        return
    end

    if table.find(names, plantName) ~= nil then
        return
    end

    table.insert(
        names,
        plantName
    )
end

local function FarmGetCollectPlantNames()

    local names =
        {}

    -- Main full-list source: seed shop names usually match plant/crop names.
    for _, seedName in ipairs(FarmGetOwnedSeedNames()) do

        FarmAddUniqueCollectPlantName(
            names,
            seedName
        )
    end

    local ownPlot =
        FarmResolveOwnPlot()

    local collectRoot =
        FarmGetCollectRoot(
            ownPlot
        )

    if collectRoot then

        for _, child in ipairs(collectRoot:GetChildren()) do

            FarmAddUniqueCollectPlantName(
                names,
                child:GetAttribute("PlantName")
                    or child:GetAttribute("SeedName")
                    or child:GetAttribute("CropName")
                    or child:GetAttribute("ItemName")
                    or child.Name
            )
        end
    end

    -- Preserve saved selected filters even if the plot has not loaded yet.
    for _, selectedPlant in ipairs(FarmGetSelectedCollectPlants()) do

        FarmAddUniqueCollectPlantName(
            names,
            selectedPlant
        )
    end

    table.sort(names)

    return names
end

local function FarmRefreshCollectPlantsDropdown()

    local names =
        FarmGetCollectPlantNames()

    if FarmCollectPlantsDropdown then

        if type(FarmCollectPlantsDropdown.SetValues) == "function" then

            FarmCollectPlantsDropdown:SetValues(names)

        elseif type(FarmCollectPlantsDropdown.SetItems) == "function" then

            FarmCollectPlantsDropdown:SetItems(names)
        end

        if type(FarmCollectPlantsDropdown.SetValue) == "function" then

            FarmCollectPlantsDropdown:SetValue(
                FarmGetSelectedCollectPlants()
            )
        end
    end

    FarmRefreshPositionLabel()
end

local function FarmCollectDebugPrint(...)

    if FarmConfig.CollectDebug ~= true then
        return
    end

    print(
        "[HOLY GAG2 COLLECT]",
        ...
    )
end

local function FarmCollectAddCandidate(candidates, value)

    local text =
        FarmNormalizeCollectPlantName(value)

    if text == "" then
        return
    end

    if table.find(candidates, text) ~= nil then
        return
    end

    table.insert(
        candidates,
        text
    )
end

local function FarmCollectAddInstanceCandidates(candidates, instance)

    if typeof(instance) ~= "Instance" then
        return
    end

    FarmCollectAddCandidate(
        candidates,
        instance.Name
    )

    local attributeNames = {
        "PlantName",
        "SeedName",
        "CropName",
        "ItemName",
        "FruitName",
        "CollectName",
        "DisplayName",
    }

    for _, attributeName in ipairs(attributeNames) do

        local ok, value =
            pcall(function()
                return instance:GetAttribute(attributeName)
            end)

        if ok == true then

            FarmCollectAddCandidate(
                candidates,
                value
            )
        end
    end

    if instance:IsA("TextLabel")
    or instance:IsA("TextButton") then

        FarmCollectAddCandidate(
            candidates,
            FarmStripRichText(instance.Text)
        )
    end

    if instance:IsA("ProximityPrompt") then

        FarmCollectAddCandidate(
            candidates,
            instance.ActionText
        )

        FarmCollectAddCandidate(
            candidates,
            instance.ObjectText
        )
    end
end

local function FarmFindCollectPlantModel(instance, collectRoot, ownPlot)

    if typeof(instance) ~= "Instance" then
        return nil
    end

    local current =
        instance

    local topChild =
        nil

    local bestModel =
        nil

    while current
    and current ~= collectRoot
    and current ~= ownPlot
    and current ~= workspace do

        if current.Parent == collectRoot then
            topChild =
                current
        end

        if current:IsA("Model")
        or current:IsA("Folder") then
            bestModel =
                current
        end

        current =
            current.Parent
    end

    return topChild
        or bestModel
end

local function FarmGetCollectPlantNameCandidates(instance, collectRoot, ownPlot)

    local candidates =
        {}

    FarmCollectAddCandidate(
        candidates,
        FarmPathOf(instance)
    )

    local current =
        instance

    while current
    and current ~= collectRoot
    and current ~= ownPlot
    and current ~= workspace do

        FarmCollectAddInstanceCandidates(
            candidates,
            current
        )

        current =
            current.Parent
    end

    local plantModel =
        FarmFindCollectPlantModel(
            instance,
            collectRoot,
            ownPlot
        )

    if plantModel then

        FarmCollectAddInstanceCandidates(
            candidates,
            plantModel
        )

        local scanned =
            0

        for _, descendant in ipairs(plantModel:GetDescendants()) do

            scanned += 1

            if scanned > 120 then
                break
            end

            FarmCollectAddInstanceCandidates(
                candidates,
                descendant
            )
        end
    end

    return candidates
end

local function FarmGetCollectPlantName(instance, collectRoot, ownPlot)

    local candidates =
        FarmGetCollectPlantNameCandidates(
            instance,
            collectRoot,
            ownPlot
        )

    return candidates[1]
        or ""
end

local function FarmCollectPlantMatchesFilter(instance, collectRoot, ownPlot)

    local selectedPlants =
        FarmGetSelectedCollectPlants()

    if #selectedPlants <= 0 then
        return true, "all plants"
    end

    local candidates =
        FarmGetCollectPlantNameCandidates(
            instance,
            collectRoot,
            ownPlot
        )

    local fallbackName =
        candidates[1]
        or "unknown plant"

    for _, selectedPlant in ipairs(selectedPlants) do

        local selectedKey =
            FarmCollectPlantKey(selectedPlant)

        if selectedKey ~= "" then

            for _, candidate in ipairs(candidates) do

                local candidateKey =
                    FarmCollectPlantKey(candidate)

                if candidateKey ~= ""
                and (
                    candidateKey == selectedKey
                    or candidateKey:find(selectedKey, 1, true) ~= nil
                    or selectedKey:find(candidateKey, 1, true) ~= nil
                ) then

                    return true, candidate
                end
            end
        end
    end

    return false, fallbackName
end

local function FarmCanCollectInstance(instance, ownPlot)

    if typeof(instance) ~= "Instance"
    or not ownPlot then
        return false
    end

    if instance:IsDescendantOf(ownPlot) ~= true then
        return false
    end

    local path =
        FarmPathOf(instance)

    if path:find("GardenZonePart", 1, true) then
        return false
    end

    if path:find("Workspace.Map.", 1, true) then
        return false
    end

    return true
end

local function FarmTryFireProximityPrompt(prompt, ownPlot)

    if typeof(prompt) ~= "Instance"
    or prompt:IsA("ProximityPrompt") ~= true then
        return false
    end

    if FarmCanCollectInstance(prompt, ownPlot) ~= true then
        return false
    end

    if prompt.Enabled == false then
        return false
    end

    if type(fireproximityprompt) ~= "function" then
        return false
    end

    local ok =
        pcall(function()

            fireproximityprompt(
                prompt
            )
        end)

    return ok == true
end

local function FarmTryFireClickDetector(clickDetector, ownPlot)

    if typeof(clickDetector) ~= "Instance"
    or clickDetector:IsA("ClickDetector") ~= true then
        return false
    end

    if FarmCanCollectInstance(clickDetector, ownPlot) ~= true then
        return false
    end

    if type(fireclickdetector) ~= "function" then
        return false
    end

    local ok =
        pcall(function()

            fireclickdetector(
                clickDetector
            )
        end)

    return ok == true
end

local function FarmTryFireTouchTransmitter(touchTransmitter, ownPlot)

    if typeof(touchTransmitter) ~= "Instance"
    or touchTransmitter:IsA("TouchTransmitter") ~= true then
        return false
    end

    if FarmCanCollectInstance(touchTransmitter, ownPlot) ~= true then
        return false
    end

    if type(firetouchinterest) ~= "function" then
        return false
    end

    local character =
        LOCAL_PLAYER.Character

    local rootPart =
        character
        and character:FindFirstChild("HumanoidRootPart")

    local touchPart =
        touchTransmitter.Parent

    if not rootPart
    or not touchPart
    or touchPart:IsA("BasePart") ~= true then
        return false
    end

    local ok =
        pcall(function()

            firetouchinterest(
                rootPart,
                touchPart,
                0
            )

            task.wait()

            firetouchinterest(
                rootPart,
                touchPart,
                1
            )
        end)

    return ok == true
end

local function FarmCollectOnce(forceCollect, debugScan)

    forceCollect =
        forceCollect == true

    debugScan =
        debugScan == true

    local ownPlot, plotReason =
        FarmResolveOwnPlot()

    if not ownPlot then

        FarmAutomationState.LastCollectCount =
            0

        FarmAutomationState.LastCollectSource =
            "no plot: " .. tostring(plotReason)

        FarmSetStatus(
            "Collect failed: "
            .. tostring(plotReason)
        )

        FarmRefreshPositionLabel()

        return 0
    end

    local collectRoot =
        FarmGetCollectRoot(
            ownPlot
        )

    if not collectRoot then

        FarmAutomationState.LastCollectCount =
            0

        FarmAutomationState.LastCollectSource =
            "no collect root"

        FarmSetStatus(
            "Collect failed: no Plants/root folder."
        )

        FarmRefreshPositionLabel()

        return 0
    end

    local selectedText =
        FarmSelectedCollectPlantsText()

    local debugEnabled =
        debugScan == true
        or FarmConfig.CollectDebug == true

    if debugEnabled == true then

        print(
            "[HOLY GAG2 COLLECT]",
            "SCAN START",
            "| force:",
            tostring(forceCollect),
            "| selected:",
            tostring(selectedText),
            "| plot:",
            FarmPathOf(ownPlot),
            "| root:",
            FarmPathOf(collectRoot)
        )
    end

    local collected =
        0

    local source =
        "none"

    local targetSeen =
        0

    local targetAllowed =
        0

    local targetDenied =
        0

    for _, descendant in ipairs(collectRoot:GetDescendants()) do

        if FarmConfig.AutoCollect ~= true
        and forceCollect ~= true then
            break
        end

        local isTarget =
            descendant:IsA("ProximityPrompt")
            or descendant:IsA("ClickDetector")
            or descendant:IsA("TouchTransmitter")

        if isTarget == true then

            targetSeen += 1

            local allowedPlant, plantName =
                FarmCollectPlantMatchesFilter(
                    descendant,
                    collectRoot,
                    ownPlot
                )

            if allowedPlant == true then
                targetAllowed += 1
            else
                targetDenied += 1
            end

            if debugEnabled == true then

                local extra =
                    ""

                if descendant:IsA("ProximityPrompt") then

                    extra =
                        " | enabled="
                        .. tostring(descendant.Enabled)
                        .. " | action="
                        .. tostring(descendant.ActionText)
                        .. " | object="
                        .. tostring(descendant.ObjectText)
                end

                print(
                    "[HOLY GAG2 COLLECT]",
                    "TARGET",
                    tostring(targetSeen),
                    "| class:",
                    descendant.ClassName,
                    "| allowed:",
                    tostring(allowedPlant),
                    "| resolved:",
                    tostring(plantName),
                    "| selected:",
                    tostring(selectedText),
                    extra,
                    "| path:",
                    FarmPathOf(descendant)
                )
            end

            if allowedPlant == true then

                local didCollect =
                    false

                if descendant:IsA("ProximityPrompt") then

                    didCollect =
                        FarmTryFireProximityPrompt(
                            descendant,
                            ownPlot
                        )

                    if didCollect == true then
                        source = "ProximityPrompt"
                    end

                elseif descendant:IsA("ClickDetector") then

                    didCollect =
                        FarmTryFireClickDetector(
                            descendant,
                            ownPlot
                        )

                    if didCollect == true then
                        source = "ClickDetector"
                    end

                elseif descendant:IsA("TouchTransmitter") then

                    didCollect =
                        FarmTryFireTouchTransmitter(
                            descendant,
                            ownPlot
                        )

                    if didCollect == true then
                        source = "TouchTransmitter"
                    end
                end

                if debugEnabled == true then

                    print(
                        "[HOLY GAG2 COLLECT]",
                        "FIRE RESULT",
                        "| success:",
                        tostring(didCollect),
                        "| class:",
                        descendant.ClassName,
                        "| resolved:",
                        tostring(plantName)
                    )
                end

                if didCollect == true then

                    collected += 1

                    if CleanText(plantName) ~= "" then

                        source =
                            source
                            .. " / "
                            .. tostring(plantName)
                    end

                    if collected >= 40 then
                        break
                    end

                    task.wait(0.03)
                end
            end
        end
    end

    FarmAutomationState.LastCollectCount =
        collected

    FarmAutomationState.LastCollectSource =
        source
        .. " | seen "
        .. tostring(targetSeen)
        .. " allowed "
        .. tostring(targetAllowed)
        .. " denied "
        .. tostring(targetDenied)

    if debugEnabled == true then

        print(
            "[HOLY GAG2 COLLECT]",
            "SCAN END",
            "| collected:",
            tostring(collected),
            "| seen:",
            tostring(targetSeen),
            "| allowed:",
            tostring(targetAllowed),
            "| denied:",
            tostring(targetDenied),
            "| source:",
            tostring(source)
        )
    end

    if collected > 0 then

        FarmSetStatus(
            "Auto collected "
            .. tostring(collected)
            .. " target(s)."
        )

    else

        FarmSetStatus(
            "No collect targets found. Seen "
            .. tostring(targetSeen)
            .. ", allowed "
            .. tostring(targetAllowed)
            .. ", denied "
            .. tostring(targetDenied)
            .. "."
        )
    end

    FarmRefreshPositionLabel()

    return collected
end

local function FarmStartCollectLoop()

    if FarmAutomationState.CollectRunning == true then
        return
    end

    FarmAutomationState.CollectRunning =
        true

    task.spawn(function()

        FarmSetStatus("Auto collect loop started.")

        while FarmConfig.AutoCollect == true do

            FarmCollectOnce(
                false,
                false
            )

            task.wait(
                SettingsNormalizeNumber(
                    FarmConfig.CollectDelay,
                    0.5,
                    0.1,
                    10
                )
            )
        end

        FarmAutomationState.CollectRunning =
            false

        FarmSetStatus("Auto collect stopped.")
    end)
end

local function FarmStopCollect()

    FarmConfig.AutoCollect =
        false

    UIState.FarmAutoCollect =
        false

    SaveUISettings(
        "farm auto collect stopped"
    )

    if FarmCollectToggle
    and type(FarmCollectToggle.SetValue) == "function" then

        FarmCollectToggle:SetValue(false)
    end

    FarmSetStatus("Auto collect stopped.")
end

local function FarmStopAutomation()

    FarmConfig.AutoPlant =
        false

    UIState.FarmAutoPlant =
        false

    SaveUISettings(
        "farm auto plant stopped"
    )

    if FarmAutomationToggle
    and type(FarmAutomationToggle.SetValue) == "function" then

        FarmAutomationToggle:SetValue(false)
    end

    FarmSetStatus("Auto plant stopped.")
end

local function FarmStartAutomationLoop()

    if FarmAutomationState.Running == true then
        return
    end

    FarmAutomationState.Running =
        true

    task.spawn(function()

        FarmSetStatus("Auto plant loop started.")

        while FarmConfig.AutoPlant == true do

            local selectedSeeds =
                FarmGetSelectedSeeds()

            if #selectedSeeds <= 0 then

                FarmSetStatus("Select at least one seed first.")
                task.wait(1)

            else

                local plantedAny =
                    false

                for _, seedName in ipairs(selectedSeeds) do

                    if FarmConfig.AutoPlant ~= true then
                        break
                    end

                    seedName =
                        CleanText(seedName)

                    local validPoint =
                        false

                    local pointReason =
                        "not checked"

                    local worldPosition =
                        nil

                    if FarmConfig.RandomPosition == true then

                        worldPosition, pointReason =
                            FarmGetRandomPlantPosition()

                        validPoint =
                            worldPosition ~= nil

                    else

                        validPoint, pointReason, worldPosition =
                            FarmValidateCurrentPlantPoint()
                    end

                    if seedName == "" then

                        FarmSetStatus("Skipped blank seed selection.")

                    elseif validPoint ~= true then

                        FarmSetStatus(
                            "Invalid plant point for "
                            .. seedName
                            .. ": "
                            .. tostring(pointReason)
                        )

                    elseif FarmGetSeedCount(seedName) <= 0 then

                        FarmSetStatus(
                            "Waiting for "
                            .. seedName
                            .. " seed tool from Backpack/auto-buy..."
                        )

                        FarmRefreshPositionLabel()

                    else

                        local equipOk, equipInfo =
                            FarmEquipSeedTool(seedName)

                        if equipOk ~= true then

                            FarmSetStatus(
                                "Equip failed for "
                                .. seedName
                                .. ": "
                                .. tostring(equipInfo)
                            )

                        else

                            local okPlant, plantInfo =
                                FarmFirePlant(
                                    seedName,
                                    worldPosition
                                )

                            if okPlant == true then

                                plantedAny =
                                    true

                                FarmSetStatus(
                                    "Planted "
                                    .. seedName
                                    .. (
                                        FarmConfig.RandomPosition == true
                                        and " at random garden point."
                                        or " at saved garden point."
                                    )
                                )

                            else

                                FarmSetStatus(
                                    "Plant failed for "
                                    .. seedName
                                    .. ": "
                                    .. tostring(plantInfo)
                                )
                            end

                            FarmRefreshPositionLabel()

                            task.wait(
                                math.clamp(
                                    tonumber(FarmConfig.PlantDelay)
                                    or 0.35,
                                    0.1,
                                    10
                                )
                            )
                        end
                    end

                    if plantedAny ~= true then

                        task.wait(0.25)
                    end
                end
            end

            task.wait(0.05)
        end

        FarmAutomationState.Running =
            false

        FarmSetStatus("Auto plant stopped.")
    end)
end

local function FarmRaycastFromMouse()

    local camera =
        workspace.CurrentCamera

    if not camera then
        return nil
    end

    local mouse =
        LOCAL_PLAYER:GetMouse()

    local unitRay =
        camera:ScreenPointToRay(
            mouse.X,
            mouse.Y
        )

    local params =
        RaycastParams.new()

    params.FilterType =
        Enum.RaycastFilterType.Exclude

    params.FilterDescendantsInstances =
        {
            LOCAL_PLAYER.Character,
        }

    params.IgnoreWater =
        true

    return workspace:Raycast(
        unitRay.Origin,
        unitRay.Direction * 500,
        params
    )
end

local function FarmStartPositionPicker()

    if FarmPositionPickerConnection then

        FarmPositionPickerConnection:Disconnect()

        FarmPositionPickerConnection =
            nil
    end

    FarmSetStatus("Position picker active. Click your plant bed.")

    Notify(
        "Farm Settings",
        "Click a valid plant bed inside your current garden.",
        4
    )

    FarmPositionPickerConnection =
        UserInputService.InputBegan:Connect(function(input, gameProcessed)

            if gameProcessed == true then
                return
            end

            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end

            local ownPlot, plotReason =
                FarmResolveOwnPlot()

            if not ownPlot then

                FarmSetStatus(
                    "Could not resolve own plot: "
                    .. tostring(plotReason)
                )

                return
            end

            local rayResult =
                FarmRaycastFromMouse()

            local valid, reason =
                FarmValidateRayHit(
                    rayResult,
                    ownPlot
                )

            if valid ~= true then

                FarmSetStatus(
                    "Rejected position: "
                    .. tostring(reason)
                )

                Notify(
                    "Farm Settings",
                    "Rejected: " .. tostring(reason),
                    4
                )

                return
            end

            local plotFrame =
                FarmGetPlotFrame(ownPlot)

            if not plotFrame then

                FarmSetStatus("Could not get plot frame.")
                return
            end

            local localOffset =
                plotFrame:PointToObjectSpace(
                    rayResult.Position
                )

            FarmSetPlantLocalOffset(
                localOffset
            )

            FarmSetStatus(
                "Saved relative plant position for future farms."
            )

            Notify(
                "Farm Settings",
                "Plant position saved relative to your garden.",
                3
            )

            if FarmPositionPickerConnection then

                FarmPositionPickerConnection:Disconnect()

                FarmPositionPickerConnection =
                    nil
            end
        end)
end

local function FarmAutoPickPlantArea()

    local ownPlot, plotReason =
        FarmResolveOwnPlot()

    if not ownPlot then

        FarmSetStatus(
            "Auto pick failed: "
            .. tostring(plotReason)
        )

        return false
    end

    local plotFrame =
        FarmGetPlotFrame(ownPlot)

    if not plotFrame then

        FarmSetStatus("Auto pick failed: no plot frame.")
        return false
    end

    local bestPart =
        nil

    for _, descendant in ipairs(ownPlot:GetDescendants()) do

        if descendant:IsA("BasePart") then

            local fullPath =
                FarmPathOf(descendant)

            if not fullPath:find("GardenZonePart", 1, true)
            and (
                fullPath:find("PlantAreaColumn1", 1, true)
                or fullPath:find("PlantArea", 1, true)
                or fullPath:find("BedSection", 1, true)
            ) then

                bestPart =
                    descendant

                break
            end
        end
    end

    if not bestPart then

        FarmSetStatus("Auto pick failed: no plant area found.")
        return false
    end

    local worldPosition =
        bestPart.Position

    local localOffset =
        plotFrame:PointToObjectSpace(
            worldPosition
        )

    FarmSetPlantLocalOffset(
        localOffset
    )

    FarmSetStatus(
        "Auto picked plant area: "
        .. bestPart.Name
    )

    return true
end

local function FarmRefreshSeedDropdown()

    local names =
        FarmGetOwnedSeedNames()

    if FarmSeedDropdown then

        if type(FarmSeedDropdown.SetValues) == "function" then

            FarmSeedDropdown:SetValues(names)

        elseif type(FarmSeedDropdown.SetItems) == "function" then

            FarmSeedDropdown:SetItems(names)
        end

        local selectedSeeds =
            {}

        for _, seedName in ipairs(FarmGetSelectedSeeds()) do

            if table.find(names, seedName) ~= nil then

                table.insert(
                    selectedSeeds,
                    seedName
                )
            end
        end

        if #selectedSeeds <= 0
        and #names > 0 then

            selectedSeeds = {
                names[1],
            }

            FarmSetSelectedSeed(
                selectedSeeds
            )
        end

        if type(FarmSeedDropdown.SetValue) == "function" then

            FarmSeedDropdown:SetValue(
                selectedSeeds
            )
        end
    end

    FarmRefreshPositionLabel()
end

local function FarmConnectReplicaWatcher()

    local remoteEvents =
        ReplicatedStorage:FindFirstChild("RemoteEvents")

    local replicaSet =
        remoteEvents
        and remoteEvents:FindFirstChild("ReplicaSet")

    if not replicaSet
    or not replicaSet:IsA("RemoteEvent") then
        return
    end

    replicaSet.OnClientEvent:Connect(function(_, pathArray, value)

        if type(pathArray) ~= "table" then
            return
        end

        if pathArray[1] == "Inventory"
        and pathArray[2] == "Seeds" then

            local seedName =
                tostring(pathArray[3] or "")

            if table.find(FarmGetSelectedSeeds(), seedName) ~= nil then

                FarmSetStatus(
                    "Seed count update: "
                    .. seedName
                    .. " = "
                    .. tostring(value)
                )

                FarmRefreshPositionLabel()
            end
        end
    end)
end

FarmConnectReplicaWatcher()

--==================================================
-- [6] UI HELPERS
--==================================================

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

local function SafeHolyGAG2DevExec(url, label)

    if IsHolyGAG2Developer() ~= true then

        warn("[HOLY GAG2 DEV] Blocked: developer access required.")

        Notify(
            "Dev Tool",
            "Developer access required.",
            4
        )

        return false
    end

    if type(loadstring) ~= "function" then

        warn("[HOLY GAG2 DEV] loadstring unsupported.")

        Notify(
            "Dev Tool",
            "loadstring is not supported by this executor.",
            4
        )

        return false
    end

    url =
        tostring(url or "")

    label =
        tostring(label or "Dev Tool")

    if url == "" then

        warn("[HOLY GAG2 DEV] Missing URL for", label)

        Notify(
            "Dev Tool",
            "Missing URL for " .. label .. ".",
            4
        )

        return false
    end

    task.spawn(function()

        print(
            "[HOLY GAG2 DEV]",
            "Loading:",
            label
        )

        Notify(
            "Dev Tool",
            "Loading " .. label .. "...",
            3
        )

        local okSource, source =
            pcall(function()

                return game:HttpGet(
                    url
                )
            end)

        if okSource ~= true
        or type(source) ~= "string"
        or source == "" then

            warn(
                "[HOLY GAG2 DEV]",
                "HttpGet failed:",
                label
            )

            Notify(
                "Dev Tool",
                "Failed to download " .. label .. ".",
                5
            )

            return
        end

        local chunk, compileErr =
            loadstring(source)

        if type(chunk) ~= "function" then

            warn(
                "[HOLY GAG2 DEV]",
                "Compile failed:",
                label,
                tostring(compileErr)
            )

            Notify(
                "Dev Tool",
                "Compile failed for " .. label .. ".",
                5
            )

            return
        end

        local okRun, runErr =
            pcall(chunk)

        if okRun ~= true then

            warn(
                "[HOLY GAG2 DEV]",
                "Runtime failed:",
                label,
                tostring(runErr)
            )

            Notify(
                "Dev Tool",
                "Runtime failed for " .. label .. ".",
                5
            )

            return
        end

        print(
            "[HOLY GAG2 DEV]",
            "Loaded:",
            label
        )

        Notify(
            "Dev Tool",
            label .. " loaded.",
            3
        )
    end)

    return true
end

--==================================================
-- [7] WINDOW
--==================================================

local Window =
    Library:CreateWindow({
        Title =
            '<font color="rgb(232,230,240)">Holy</font> '
            .. '<font color="rgb(196,181,253)"><b>GAG 2</b></font>',

        Footer =
            "holy · grow a garden 2",

        ToggleKeybind =
            Enum.KeyCode.LeftAlt,

        Font =
            Enum.Font.Code,

        Center =
            true,

        AutoShow =
            true,

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

Library:SetDPIScale(
    UIState.DPIScale
)

--==================================================
-- [8] TABS
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
            Description = "Shop tools.",
        }),

    Sell =
        Window:AddTab({
            Name = "Sell",
            Icon = "coins",
            Description = "Fruit selling tools.",
        }),

    Farm =
        Window:AddTab({
            Name = "Farm",
            Icon = "sprout",
            Description = "Farm tools.",
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
            Icon = "terminal",
            Description = "Developer tools.",
        })
end

--==================================================
-- [9] HOME TAB
--==================================================

local HomeMainBox =
    AddLeftBox(
        Tabs.Home,
        "Main",
        "sparkles"
    )

local HomeServerBox =
    AddRightBox(
        Tabs.Home,
        "Server",
        "server"
    )

HomeMainBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Holy for Grow a Garden 2</b></font>'
        .. '\nClean Obsidian shell. No game automation added yet.',
    DoesWrap = true,
    Size = 13,
})

HomeMainBox:AddDivider(
    "Actions"
)

HomeMainBox:AddButton({
    Text = "Rejoin",
    Tooltip = "Rejoin the current Grow a Garden 2 place.",
    Func = function()

        RejoinServer()
    end,
}):AddButton({
    Text = "Server Hop",
    Tooltip = "Join a different public server.",
    Func = function()

        HopServer()
    end,
})

HomeMainBox:AddButton({
    Text = "Copy JobId",
    Tooltip = "Copy the current server JobId.",
    Func = function()

        CopyJobId()
    end,
})

StatusLabel =
    HomeMainBox:AddLabel({
        Text =
            '<font color="rgb(196,181,253)"><b>Status:</b></font> Ready',
        DoesWrap = true,
        Size = 12,
    })

HomeServerBox:AddLabel({
    Text =
        '<font color="rgb(148,163,184)"><b>Current Server</b></font>'
        .. '\nPlaceId: '
        .. tostring(game.PlaceId)
        .. '\nJobId: '
        .. tostring(game.JobId)
        .. '\nPlayers: '
        .. tostring(#Players:GetPlayers()),
    DoesWrap = true,
    Size = 12,
})

if game.PlaceId ~= GROW_A_GARDEN_2_PLACE_ID then

    HomeServerBox:AddLabel({
        Text =
            '<font color="rgb(248,113,113)"><b>Wrong Place Warning</b></font>'
            .. '\nThis shell is made for Grow a Garden 2.'
            .. '\nExpected PlaceId: '
            .. tostring(GROW_A_GARDEN_2_PLACE_ID),
        DoesWrap = true,
        Size = 12,
    })
end

--==================================================
-- [10] SHOPS TAB
--==================================================

local ShopsMainBox =
    AddLeftBox(
        Tabs.Shops,
        "Shop Controls",
        "shopping-cart"
    )

local ShopsStatusBox =
    AddRightBox(
        Tabs.Shops,
        "Shop Status",
        "activity"
    )

ShopsMainBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Auto Buy</b></font>'
        .. '\nUses the real GAG2 packet shop system.'
        .. '\nSeeds, gear, and crates are stock-aware with a per-restock cap.',
    DoesWrap = true,
    Size = 13,
})

ShopsMainBox:AddDivider(
    "Selections"
)

local SeedDropdown =
    ShopsMainBox:AddDropdown(
        "HolyGAG2ShopSeeds",
        {
            Text = "Seeds",
            Values = GetShopItemNames("SeedShop"),
            Default = ShopConfig.Seeds,
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Seeds to buy from Seed Shop.",
        }
    )

local GearDropdown =
    ShopsMainBox:AddDropdown(
        "HolyGAG2ShopGear",
        {
            Text = "Gear",
            Values = GetShopItemNames("GearShop"),
            Default = ShopConfig.Gear,
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Gear to buy from Gear Shop.",
        }
    )

local CrateDropdown =
    ShopsMainBox:AddDropdown(
        "HolyGAG2ShopCrates",
        {
            Text = "Crates",
            Values = GetShopItemNames("CrateShop"),
            Default = ShopConfig.Crates,
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Crates to buy from Crate Shop.",
        }
    )

local function BindShopDropdown(dropdown, key)

    if dropdown
    and type(dropdown.OnChanged) == "function" then

        dropdown:OnChanged(function(value)

            local normalized =
                NormalizeShopList(
                    value,
                    {}
                )

            ShopConfig[key] =
                normalized

            if key == "Seeds" then

                UIState.ShopSeeds =
                    normalized

            elseif key == "Gear" then

                UIState.ShopGear =
                    normalized

            elseif key == "Crates" then

                UIState.ShopCrates =
                    normalized
            end

            SaveUISettings(
                "shop " .. tostring(key) .. " changed"
            )

            RefreshShopStockPreview()
        end)
    end
end

BindShopDropdown(
    SeedDropdown,
    "Seeds"
)

BindShopDropdown(
    GearDropdown,
    "Gear"
)

BindShopDropdown(
    CrateDropdown,
    "Crates"
)

ShopsMainBox:AddDivider(
    "Automation"
)

local SeedToggle =
    ShopsMainBox:AddToggle(
        "HolyGAG2AutoBuySeeds",
        {
            Text = "Auto Buy Seeds",
            Default = ShopConfig.AutoBuySeeds == true,
            Tooltip = "Automatically buys selected seeds when stock is available.",
        }
    )

local GearToggle =
    ShopsMainBox:AddToggle(
        "HolyGAG2AutoBuyGear",
        {
            Text = "Auto Buy Gear",
            Default = ShopConfig.AutoBuyGear == true,
            Tooltip = "Automatically buys selected gear when stock is available.",
        }
    )

local CrateToggle =
    ShopsMainBox:AddToggle(
        "HolyGAG2AutoBuyCrates",
        {
            Text = "Auto Buy Crates",
            Default = ShopConfig.AutoBuyCrates == true,
            Tooltip = "Automatically buys selected crates when stock is available.",
        }
    )

local function BindShopToggle(toggle, key)

    if toggle
    and type(toggle.OnChanged) == "function" then

        toggle:OnChanged(function(value)

            local enabled =
                value == true

            ShopConfig[key] =
                enabled

            if key == "AutoBuySeeds" then

                UIState.ShopAutoBuySeeds =
                    enabled

            elseif key == "AutoBuyGear" then

                UIState.ShopAutoBuyGear =
                    enabled

            elseif key == "AutoBuyCrates" then

                UIState.ShopAutoBuyCrates =
                    enabled
            end

            SaveUISettings(
                "shop " .. tostring(key) .. " changed"
            )

            if enabled == true then
                StartShopAutomationLoop()
            end

            RefreshShopStockPreview()
        end)
    end
end

BindShopToggle(
    SeedToggle,
    "AutoBuySeeds"
)

BindShopToggle(
    GearToggle,
    "AutoBuyGear"
)

BindShopToggle(
    CrateToggle,
    "AutoBuyCrates"
)

if type(ShopsMainBox.AddInput) == "function" then

    local BuyDelayInput =
        ShopsMainBox:AddInput(
            "HolyGAG2ShopBuyDelay",
            {
                Text = "Buy Delay",
                Default = tostring(ShopConfig.BuyDelay),
                Numeric = true,
                Finished = true,
                Tooltip = "Seconds between buy packet fires. Minimum 0.1.",
            }
        )

    if BuyDelayInput
    and type(BuyDelayInput.OnChanged) == "function" then

        BuyDelayInput:OnChanged(function(value)

            ShopConfig.BuyDelay =
                NormalizeShopNumber(
                    value,
                    0.35,
                    0.1,
                    10
                )

            UIState.ShopBuyDelay =
                ShopConfig.BuyDelay

            SaveUISettings(
                "shop buy delay changed"
            )
        end)
    end

    local MaxBuysInput =
        ShopsMainBox:AddInput(
            "HolyGAG2ShopMaxBuysPerRestock",
            {
                Text = "Max Buys / Restock",
                Default = tostring(ShopConfig.MaxBuysPerRestock),
                Numeric = true,
                Finished = true,
                Tooltip = "Local cap per selected item per restock. Default is 1 for safety.",
            }
        )

    if MaxBuysInput
    and type(MaxBuysInput.OnChanged) == "function" then

        MaxBuysInput:OnChanged(function(value)

            ShopConfig.MaxBuysPerRestock =
                math.floor(
                    NormalizeShopNumber(
                        value,
                        1,
                        1,
                        999
                    )
                )

            UIState.ShopMaxBuysPerRestock =
                ShopConfig.MaxBuysPerRestock

            SaveUISettings(
                "shop max buys changed"
            )
        end)
    end
end

ShopsMainBox:AddDivider(
    "Actions"
)

ShopsMainBox:AddButton({
    Text = "Refresh Stock",
    Tooltip = "Refresh selected item stock preview.",
    Func = function()

        FindHolyGAG2Packets()
        RefreshShopStockPreview()
        SetShopStatus("Stock preview refreshed.")
    end,
}):AddButton({
    Text = "Stop Auto Buy",
    Risky = true,
    Tooltip = "Turn off all shop auto-buy toggles.",
    Func = function()

        StopAllShopAutomation(
            SeedToggle,
            GearToggle,
            CrateToggle
        )
    end,
})

ShopsStatusBox:AddLabel({
    Text =
        '<font color="rgb(148,163,184)"><b>Packet Calls</b></font>'
        .. '\nSeeds: SeedShop.PurchaseSeed:Fire(item)'
        .. '\nGear: GearShop.PurchaseGear:Fire(item)'
        .. '\nCrates: CrateShop.PurchaseCrate:Fire(item)',
    DoesWrap = true,
    Size = 12,
})

ShopStatusLabel =
    ShopsStatusBox:AddLabel({
        Text =
            '<font color="rgb(196,181,253)"><b>Shop Status:</b></font> Ready',
        DoesWrap = true,
        Size = 12,
    })

ShopStockLabel =
    ShopsStatusBox:AddLabel({
        Text = BuildShopStockPreviewText(),
        DoesWrap = true,
        Size = 12,
    })

FindHolyGAG2Packets()
RefreshShopStockPreview()

if AnyShopAutomationEnabled() == true then

    StartShopAutomationLoop()

    SetShopStatus(
        "Auto-buy restored from saved settings."
    )
end

--==================================================
-- [10.5] SELL TAB
--==================================================

local SellMainBox =
    AddLeftBox(
        Tabs.Sell,
        "Sell Controls",
        "coins"
    )

local SellStatusBox =
    AddRightBox(
        Tabs.Sell,
        "Sell Status",
        "activity"
    )

SellMainBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Auto Sell</b></font>'
        .. '\nAuto Sell Max Backpack waits until the game shows "Your inventory is full", then fires the discovered sell packet.',
    DoesWrap = true,
    Size = 13,
})

SellMainBox:AddDivider(
    "Automation"
)

SellAutoToggle =
    SellMainBox:AddToggle(
        "HolyGAG2SellAutoMaxBackpack",
        {
            Text = "Auto Sell Max Backpack",
            Default = SellConfig.AutoMaxBackpack == true,
            Tooltip = "Only sells after the game says your inventory/backpack is full.",
        }
    )

if SellAutoToggle
and type(SellAutoToggle.OnChanged) == "function" then

    SellAutoToggle:OnChanged(function(value)

        SellConfig.AutoMaxBackpack =
            value == true

        UIState.SellAutoMaxBackpack =
            SellConfig.AutoMaxBackpack == true

        SaveUISettings(
            "sell auto max backpack changed"
        )

        if SellConfig.AutoMaxBackpack == true then
            StartSellAutomationLoop()
        else
            SetSellStatus("Auto sell disabled.")
        end

        RefreshSellInfo()
    end)
end

local SellDebugToggle =
    SellMainBox:AddToggle(
        "HolyGAG2SellDebug",
        {
            Text = "Sell Debug",
            Default = SellConfig.Debug == true,
            Tooltip = "Prints sell packet candidates and sell attempts to console.",
        }
    )

if SellDebugToggle
and type(SellDebugToggle.OnChanged) == "function" then

    SellDebugToggle:OnChanged(function(value)

        SellConfig.Debug =
            value == true

        UIState.SellDebug =
            SellConfig.Debug == true

        SaveUISettings(
            "sell debug changed"
        )

        SetSellStatus(
            SellConfig.Debug == true
            and "Sell debug enabled."
            or "Sell debug disabled."
        )

        RefreshSellInfo()
    end)
end

if type(SellMainBox.AddInput) == "function" then

    local SellDelayInput =
        SellMainBox:AddInput(
            "HolyGAG2SellDelay",
            {
                Text = "Sell Delay",
                Default = tostring(SellConfig.Delay),
                Numeric = true,
                Finished = true,
                Tooltip = "Seconds between max-backpack checks. Minimum 0.1.",
            }
        )

    if SellDelayInput
    and type(SellDelayInput.OnChanged) == "function" then

        SellDelayInput:OnChanged(function(value)

            SellConfig.Delay =
                SettingsNormalizeNumber(
                    value,
                    0.5,
                    0.1,
                    10
                )

            UIState.SellDelay =
                SellConfig.Delay

            SaveUISettings(
                "sell delay changed"
            )

            RefreshSellInfo()
        end)
    end
end

SellMainBox:AddDivider(
    "Actions"
)

SellMainBox:AddButton({
    Text = "Find Sell Packet",
    Tooltip = "Find the best sell packet candidate from the loaded packet table.",
    Func = function()

        SellState.SellPacket =
            nil

        local packet =
            FindSellPacket()

        if packet then

            SetSellStatus(
                "Found sell packet."
            )

            Notify(
                "Sell",
                "Found: " .. tostring(SellState.PacketSource),
                4
            )

        else

            SetSellStatus(
                "Sell packet not found."
            )

            Notify(
                "Sell",
                tostring(SellState.PacketSource),
                5
            )
        end

        RefreshSellInfo()
    end,
}):AddButton({
    Text = "Sell Once",
    Tooltip = "Fire the sell packet once for testing.",
    Func = function()

        SellOnce(
            "manual"
        )
    end,
})

SellMainBox:AddButton({
    Text = "Stop Auto Sell",
    Risky = true,
    Tooltip = "Turns off Auto Sell Max Backpack.",
    Func = function()

        StopSellAutomation()
    end,
})

SellStatusBox:AddLabel({
    Text =
        '<font color="rgb(148,163,184)"><b>How It Works</b></font>'
        .. '\n1. Watches PlayerGui text for "Your inventory is full".'
        .. '\n2. Finds a sell packet from the packet table.'
        .. '\n3. Fires sell only when max backpack was detected recently.',
    DoesWrap = true,
    Size = 12,
})

SellStatusLabel =
    SellStatusBox:AddLabel({
        Text =
            '<font color="rgb(196,181,253)"><b>Sell Status:</b></font> Ready',
        DoesWrap = true,
        Size = 12,
    })

SellInfoLabel =
    SellStatusBox:AddLabel({
        Text = BuildSellInfoText(),
        DoesWrap = true,
        Size = 12,
    })

FindSellPacket()
RefreshSellInfo()

if SellConfig.AutoMaxBackpack == true then

    StartSellAutomationLoop()

    SetSellStatus(
        "Auto sell restored from saved settings."
    )
end

--==================================================
-- [11] FARM TAB
--==================================================

local FarmSettingsBox =
    AddLeftBox(
        Tabs.Farm,
        "Farm Settings",
        "sliders-horizontal"
    )

local FarmStatusBox =
    AddRightBox(
        Tabs.Farm,
        "Farm Status",
        "activity"
    )

FarmSettingsBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Auto Plant</b></font>'
        .. '\nSaves plant position relative to your current garden.'
        .. '\nOn rejoin, it scans your new "Your Garden" plot and plants at the same relative spot.',
    DoesWrap = true,
    Size = 13,
})

FarmSettingsBox:AddDivider(
    "Seed"
)

FarmSeedDropdown =
    FarmSettingsBox:AddDropdown(
        "HolyGAG2FarmSeed",
        {
            Text = "Seeds",
            Values = FarmGetOwnedSeedNames(),
            Default = FarmGetSelectedSeeds(),
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Seeds to plant. Multi-select, deselect, and search are enabled. Auto Plant waits until each seed tool exists.",
        }
    )

if FarmSeedDropdown
and type(FarmSeedDropdown.OnChanged) == "function" then

    FarmSeedDropdown:OnChanged(function(value)

        FarmSetSelectedSeed(
            value
        )
    end)
end

FarmSettingsBox:AddButton({
    Text = "Refresh Seeds",
    Tooltip = "Refresh full seed list from Seed Shop plus owned Backpack/Character seed tools.",
    Func = function()

        FarmRefreshSeedDropdown()

        FarmSetStatus(
            "Full seed list refreshed."
        )
    end,
})

FarmSettingsBox:AddDivider(
    "Plant Position"
)

FarmSettingsBox:AddButton({
    Text = "Pick Position",
    Tooltip = "Click this, then click a valid plant bed in your current garden.",
    Func = function()

        FarmStartPositionPicker()
    end,
}):AddButton({
    Text = "Auto Pick",
    Tooltip = "Automatically choose a plant area inside your current garden.",
    Func = function()

        if FarmAutoPickPlantArea() == true then

            Notify(
                "Farm Settings",
                "Auto picked a valid plant position.",
                3
            )
        else

            Notify(
                "Farm Settings",
                "Could not auto pick a plant position.",
                4
            )
        end
    end,
})

FarmSettingsBox:AddButton({
    Text = "Validate Position",
    Tooltip = "Checks saved relative position against your current garden.",
    Func = function()

        local valid, reason =
            FarmValidateCurrentPlantPoint()

        if valid == true then

            FarmSetStatus(
                "Position valid: "
                .. tostring(reason)
            )

            Notify(
                "Farm Settings",
                "Plant position is valid for this farm.",
                3
            )

        else

            FarmSetStatus(
                "Position invalid: "
                .. tostring(reason)
            )

            Notify(
                "Farm Settings",
                "Position invalid: " .. tostring(reason),
                4
            )
        end

                FarmRefreshPositionLabel()
    end,
})

local FarmRandomPositionToggle =
    FarmSettingsBox:AddToggle(
        "HolyGAG2FarmRandomPosition",
        {
            Text = "Random Position",
            Default = FarmConfig.RandomPosition == true,
            Tooltip = "Randomly picks a valid plant bed point inside your current garden every plant.",
        }
    )

if FarmRandomPositionToggle
and type(FarmRandomPositionToggle.OnChanged) == "function" then

    FarmRandomPositionToggle:OnChanged(function(value)

        FarmSetRandomPosition(
            value == true
        )
    end)
end

FarmSettingsBox:AddDivider(
    "Automation"
)

FarmAutomationToggle =
    FarmSettingsBox:AddToggle(
        "HolyGAG2AutoPlant",
        {
            Text = "Auto Plant",
            Default = FarmConfig.AutoPlant == true,
            Tooltip = "Automatically plants selected seed at saved relative garden position.",
        }
    )

if FarmAutomationToggle
and type(FarmAutomationToggle.OnChanged) == "function" then

    FarmAutomationToggle:OnChanged(function(value)

        FarmConfig.AutoPlant =
            value == true

        UIState.FarmAutoPlant =
            FarmConfig.AutoPlant == true

        SaveUISettings(
            "farm auto plant changed"
        )

        if FarmConfig.AutoPlant == true then
            FarmStartAutomationLoop()
        else
            FarmSetStatus("Auto plant disabled.")
        end
    end)
end

FarmCollectToggle =
    FarmSettingsBox:AddToggle(
        "HolyGAG2AutoCollect",
        {
            Text = "Auto Collect",
            Default = FarmConfig.AutoCollect == true,
            Tooltip = "Automatically collects harvest prompts/clicks/touch targets inside your current garden.",
        }
    )

if FarmCollectToggle
and type(FarmCollectToggle.OnChanged) == "function" then

    FarmCollectToggle:OnChanged(function(value)

        FarmConfig.AutoCollect =
            value == true

        UIState.FarmAutoCollect =
            FarmConfig.AutoCollect == true

        SaveUISettings(
            "farm auto collect changed"
        )

        if FarmConfig.AutoCollect == true then
            FarmStartCollectLoop()
        else
            FarmSetStatus("Auto collect disabled.")
        end

        FarmRefreshPositionLabel()
    end)
end

FarmCollectPlantsDropdown =
    FarmSettingsBox:AddDropdown(
        "HolyGAG2CollectPlants",
        {
            Text = "Collect Plants",
            Values = FarmGetCollectPlantNames(),
            Default = FarmGetSelectedCollectPlants(),
            Multi = true,
            Searchable = true,
            AllowNull = true,
            MaxVisibleDropdownItems = 10,
            Tooltip = "Plants to collect. Empty selection means collect all plants.",
        }
    )

if FarmCollectPlantsDropdown
and type(FarmCollectPlantsDropdown.OnChanged) == "function" then

    FarmCollectPlantsDropdown:OnChanged(function(value)

        FarmSetCollectPlants(
            value
        )
    end)
end

local FarmCollectDebugToggle =
    FarmSettingsBox:AddToggle(
        "HolyGAG2CollectDebug",
        {
            Text = "Collect Debug",
            Default = false,
            Tooltip = "Prints collect target paths, resolved plant names, and fire results to console.",
        }
    )

if FarmCollectDebugToggle
and type(FarmCollectDebugToggle.OnChanged) == "function" then

    FarmCollectDebugToggle:OnChanged(function(value)

        FarmConfig.CollectDebug =
            value == true

        FarmSetStatus(
            FarmConfig.CollectDebug == true
            and "Collect debug enabled."
            or "Collect debug disabled."
        )
    end)
end

if type(FarmSettingsBox.AddInput) == "function" then

    local PlantDelayInput =
        FarmSettingsBox:AddInput(
            "HolyGAG2PlantDelay",
            {
                Text = "Plant Delay",
                Default = tostring(FarmConfig.PlantDelay),
                Numeric = true,
                Finished = true,
                Tooltip = "Seconds between plant packet fires. Minimum 0.1.",
            }
        )

    if PlantDelayInput
    and type(PlantDelayInput.OnChanged) == "function" then

        PlantDelayInput:OnChanged(function(value)

            FarmSetPlantDelay(
                value
            )
        end)
    end

    local CollectDelayInput =
        FarmSettingsBox:AddInput(
            "HolyGAG2CollectDelay",
            {
                Text = "Collect Delay",
                Default = tostring(FarmConfig.CollectDelay),
                Numeric = true,
                Finished = true,
                Tooltip = "Seconds between collect scans. Minimum 0.1.",
            }
        )

    if CollectDelayInput
    and type(CollectDelayInput.OnChanged) == "function" then

        CollectDelayInput:OnChanged(function(value)

            FarmSetCollectDelay(
                value
            )
        end)
    end
end

FarmSettingsBox:AddButton({
    Text = "Refresh Collect Plants",
    Tooltip = "Refresh collect plant filter list from Seed Shop and your current garden.",
    Func = function()

        FarmRefreshCollectPlantsDropdown()

        FarmSetStatus(
            "Collect plant list refreshed."
        )
    end,
})

FarmSettingsBox:AddButton({
    Text = "Collect Once",
    Tooltip = "Runs one forced debug collect scan inside your current garden.",
    Func = function()

        FarmCollectOnce(
            true,
            true
        )
    end,
}):AddButton({
    Text = "Stop Auto Collect",
    Risky = true,
    Tooltip = "Turns off Auto Collect.",
    Func = function()

        FarmStopCollect()
    end,
})

FarmSettingsBox:AddButton({
    Text = "Stop Auto Plant",
    Risky = true,
    Tooltip = "Turns off Auto Plant.",
    Func = function()

        FarmStopAutomation()
    end,
})

FarmStatusBox:AddLabel({
    Text =
        '<font color="rgb(148,163,184)"><b>Dynamic Farm Logic</b></font>'
        .. '\nThe saved position is relative, not world-based.'
        .. '\nEvery rejoin it scans PlayerGui plot billboards for "Your Garden", resolves Workspace.Gardens.Plot#, then converts the saved offset into the new farm.',
    DoesWrap = true,
    Size = 12,
})

FarmStatusLabel =
    FarmStatusBox:AddLabel({
        Text =
            '<font color="rgb(196,181,253)"><b>Farm Status:</b></font> Ready',
        DoesWrap = true,
        Size = 12,
    })

FarmPositionLabel =
    FarmStatusBox:AddLabel({
        Text =
            '<font color="rgb(196,181,253)"><b>Farm Settings</b></font>',
        DoesWrap = true,
        Size = 12,
    })

FarmFindPlantSeedPacket()
FarmRefreshSeedDropdown()
FarmRefreshPositionLabel()

if FarmConfig.AutoPlant == true then

    FarmStartAutomationLoop()

    FarmSetStatus(
        "Auto plant restored from saved settings."
    )
end

if FarmConfig.AutoCollect == true then

    FarmStartCollectLoop()

    FarmSetStatus(
        "Auto collect restored from saved settings."
    )
end

--==================================================
-- [12] SETTINGS TAB
--==================================================

local SettingsUIBox =
    AddLeftBox(
        Tabs.Settings,
        "Interface",
        "settings"
    )

SettingsUIBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Interface</b></font>'
        .. '\nAdjust UI scale for cloud phones, mobile, or desktop.',
    DoesWrap = true,
    Size = 13,
})

local ScaleDropdown =
    SettingsUIBox:AddDropdown(
        "HolyGAG2UIScale",
        {
            Text = "UI Scaling",
            Values = {
                "125%",
                "110%",
                "100%",
                "90%",
                "80%",
                "75%",
                "70%",
                "65%",
                "60%",
                "55%",
                "50%",
            },
            Default =
                ScaleToChoice(
                    UIState.DPIScale
                ),
            Searchable = false,
            Multi = false,
            AllowNull = false,
            MaxVisibleDropdownItems = 8,
            Tooltip = "Changes Obsidian UI DPI scale.",
        }
    )

ScaleDropdown:OnChanged(function(value)

    local scale =
        ChoiceToScale(value)

    UIState.DPIScale =
        scale

    Library:SetDPIScale(
        scale
    )

    SaveUISettings(
        "dpi changed"
    )

    Notify(
        "UI Scaling",
        "Scale set to "
            .. tostring(scale)
            .. "%.",
        3
    )
end)

SettingsUIBox:AddButton({
    Text = "Reset UI Scale",
    Tooltip = "Reset UI scale back to 100%.",
    Func = function()

        UIState.DPIScale =
            100

        Library:SetDPIScale(
            100
        )

        if ScaleDropdown
        and type(ScaleDropdown.SetValue) == "function" then

            ScaleDropdown:SetValue(
                "100%"
            )
        end

        SaveUISettings(
            "dpi reset"
        )

        Notify(
            "UI Scaling",
            "Scale reset to 100%.",
            3
        )
    end,
})

SettingsUIBox:AddButton({
    Text = "Unload UI",
    Risky = true,
    DoubleClick = true,
    Tooltip = "Unload the Holy UI.",
    Func = function()

        if Library
        and type(Library.Unload) == "function" then
            Library:Unload()
        end
    end,
})

--==================================================
-- [12.5] DEV TAB
--==================================================

if Tabs.Dev then

    local DevToolsBox =
        AddLeftBox(
            Tabs.Dev,
            "Tools",
            "terminal"
        )

    local DevInfoBox =
        AddRightBox(
            Tabs.Dev,
            "Info",
            "info"
        )

    DevToolsBox:AddLabel({
        Text =
            '<font color="rgb(196,181,253)"><b>DEVELOPER TOOLS</b></font>'
            .. '\nSame dev tools as Holy Lite.',
        DoesWrap = true,
        Size = 13,
    })

    DevToolsBox:AddButton({
        Text = "Remote Spy",
        Tooltip = "Open Remote Spy to inspect remote calls.",
        Func = function()

            SafeHolyGAG2DevExec(
                "https://raw.githubusercontent.com/Klinac/scripts/main/utopia_spy.lua",
                "Remote Spy"
            )
        end,
    })

    DevToolsBox:AddButton({
        Text = "Dex Explorer",
        Tooltip = "Open Dex Explorer to inspect the live game tree.",
        Func = function()

            SafeHolyGAG2DevExec(
                "https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua",
                "Dex Explorer"
            )
        end,
    })

    DevInfoBox:AddLabel({
        Text =
            '<font color="rgb(125,116,145)"><b>DEV ACCESS</b></font>'
            .. '\nUserId: '
            .. tostring(LOCAL_PLAYER.UserId)
            .. '\nRemote Spy: Utopia Spy'
            .. '\nDex: Dex++'
            .. '\nAccess: Developer only',
        DoesWrap = true,
        Size = 12,
    })

    DevInfoBox:AddLabel({
        Text =
            "Remote Spy logs client remote calls."
            .. "\nDex lets you inspect the live game tree."
            .. "\nUse this only while researching Grow a Garden 2 remotes/UI.",
        DoesWrap = true,
        Size = 12,
    })
end


--==================================================
-- [13] FINISH
--==================================================

SetStatus(
    "Ready"
)

Notify(
    "Holy GAG 2",
    "UI loaded. Toggle with LeftAlt.",
    4
)

print(
    "[HOLY GAG2]",
    "Loaded.",
    "| place:",
    tostring(game.PlaceId),
    "| job:",
    tostring(game.JobId),
    "| scale:",
    tostring(UIState.DPIScale)
)
