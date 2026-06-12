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
}

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
    AutoBuySeeds = false,
    AutoBuyGear = false,
    AutoBuyCrates = false,

    Seeds = {
        "Carrot",
    },

    Gear = {},
    Crates = {},

    BuyDelay = 0.35,
    MaxBuysPerRestock = 1,
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

            ShopConfig[key] =
                NormalizeShopList(
                    value,
                    {}
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
            Default = false,
            Tooltip = "Automatically buys selected seeds when stock is available.",
        }
    )

local GearToggle =
    ShopsMainBox:AddToggle(
        "HolyGAG2AutoBuyGear",
        {
            Text = "Auto Buy Gear",
            Default = false,
            Tooltip = "Automatically buys selected gear when stock is available.",
        }
    )

local CrateToggle =
    ShopsMainBox:AddToggle(
        "HolyGAG2AutoBuyCrates",
        {
            Text = "Auto Buy Crates",
            Default = false,
            Tooltip = "Automatically buys selected crates when stock is available.",
        }
    )

local function BindShopToggle(toggle, key)

    if toggle
    and type(toggle.OnChanged) == "function" then

        toggle:OnChanged(function(value)

            ShopConfig[key] =
                value == true

            if value == true then
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

--==================================================
-- [11] FARM TAB
--==================================================

local FarmMainBox =
    AddLeftBox(
        Tabs.Farm,
        "Farm Controls",
        "sprout"
    )

local FarmStatusBox =
    AddRightBox(
        Tabs.Farm,
        "Farm Status",
        "activity"
    )

FarmMainBox:AddLabel({
    Text =
        '<font color="rgb(196,181,253)"><b>Farm</b></font>'
        .. '\nPlaceholder tab for planting, collecting, and farm helpers.',
    DoesWrap = true,
    Size = 13,
})

FarmMainBox:AddToggle(
    "HolyGAG2AutoCollect",
    {
        Text = "Auto Collect",
        Default = false,
        Disabled = true,
        Tooltip = "Coming later after we inspect Grow a Garden 2 farm systems.",
    }
)

FarmMainBox:AddToggle(
    "HolyGAG2AutoPlant",
    {
        Text = "Auto Plant",
        Default = false,
        Disabled = true,
        Tooltip = "Coming later after we inspect Grow a Garden 2 farm systems.",
    }
)

FarmStatusBox:AddLabel({
    Text =
        "No farm logic is connected yet."
        .. "\nThis is only the clean UI shell.",
    DoesWrap = true,
    Size = 12,
})

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
