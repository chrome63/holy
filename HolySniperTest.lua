--==================================================
-- HOLY SNIPER TEST
-- Fresh isolated sniper-only script
-- Purpose: test booth scan -> match -> buy -> inventory confirm
-- No UI, no key system, no webhooks, no listings, no age breaker.
--==================================================

--==================================================
-- [0] CONFIG
--==================================================

local CONFIG = {
    Enabled = false,

    Debug = true,
    DebugListings = false,
    DebugNoMatches = false,

    TradeWorldPlaceId = 129954712878723,

    ScanInterval = 0.02,
    BoothRefreshInterval = 0.05,

    InventoryConfirmTimeout = 10,
    RecoveryDelay = 0.05,

    FailedListingTTL = 12,

    -- false = only attempt one best listing at a time.
    QueueWhileBuying = false,

    -- Filter format:
    -- MaxPrice = max token price
    -- MinBaseWeight = raw BaseWeight minimum
    -- MinDisplayWeight = current shown KG minimum
    -- WeightMode = "BaseWeight" or "DisplayWeight"
    -- Priority = 1-10, higher buys first
    -- Mutation = "Off", "Mutated Only", "Specific", "Exclude"
    -- SpecificMutations = { ["Rainbow"] = true }
    -- ExcludedMutations = { ["Shocked"] = true }
    Watchlist = {
        ["Seal"] = {
            MaxPrice = 100000,
            MinBaseWeight = 0,
            MinDisplayWeight = 0,
            WeightMode = "BaseWeight",
            Priority = 10,
            Mutation = "Off",
            SpecificMutations = {},
            ExcludedMutations = {},
        },

        ["Toucan"] = {
            MaxPrice = 100000,
            MinBaseWeight = 0,
            MinDisplayWeight = 0,
            WeightMode = "BaseWeight",
            Priority = 10,
            Mutation = "Off",
            SpecificMutations = {},
            ExcludedMutations = {},
        },
    },
}

--==================================================
-- [1] SERVICES / RUNTIME
--==================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players =
    game:GetService("Players")

local ReplicatedStorage =
    game:GetService("ReplicatedStorage")

local RunService =
    game:GetService("RunService")

local LocalPlayer =
    Players.LocalPlayer

local ROOT =
    type(getgenv) == "function"
    and getgenv()
    or _G

ROOT.HOLY_SNIPER_TEST_RUNTIME =
    ROOT.HOLY_SNIPER_TEST_RUNTIME
    or {}

local RUNTIME =
    ROOT.HOLY_SNIPER_TEST_RUNTIME

local RUN_ID =
    tostring(os.clock())
    .. "_"
    .. tostring(math.random(100000, 999999))

RUNTIME.RunId =
    RUN_ID

local function IsCurrentRun()
    return RUNTIME
        and RUNTIME.RunId == RUN_ID
end

local function SafeNumber(value, fallback)
    local number =
        tonumber(value)

    if number == nil then
        return fallback or 0
    end

    return number
end

local function SafeElapsed(lastTime)
    return os.clock() - SafeNumber(lastTime, 0)
end

local function Log(...)
    if CONFIG.Debug == true then
        print("[SNIPER TEST]", ...)
    end
end

local function Warn(...)
    warn("[SNIPER TEST]", ...)
end

--==================================================
-- [2] PLACE / READINESS GATE
--==================================================

if game.PlaceId ~= CONFIG.TradeWorldPlaceId then
    Warn(
        "Wrong place. Join Trade World first. Current PlaceId:",
        tostring(game.PlaceId)
    )
    return
end

local function WaitForClientReady()

    local player =
        Players.LocalPlayer

    if not player then
        return false, "LocalPlayer missing"
    end

    local start =
        os.clock()

    while IsCurrentRun() do

        if player:FindFirstChild("Backpack")
        and player:FindFirstChild("PlayerGui") then
            break
        end

        if os.clock() - start > 15 then
            return false, "Player core timeout"
        end

        task.wait(0.1)
    end

    start =
        os.clock()

    while IsCurrentRun() do

        if ReplicatedStorage:FindFirstChild("GameEvents") then
            break
        end

        if os.clock() - start > 15 then
            return false, "GameEvents timeout"
        end

        task.wait(0.1)
    end

    start =
        os.clock()

    while IsCurrentRun() do

        local tradeWorld =
            workspace:FindFirstChild("TradeWorld")

        if tradeWorld
        and tradeWorld:FindFirstChild("Booths") then
            break
        end

        if os.clock() - start > 20 then
            return false, "TradeWorld/Booths timeout"
        end

        task.wait(0.2)
    end

    return true, "Ready"
end

local ready, readyReason =
    WaitForClientReady()

if not ready then
    Warn("Boot failed:", tostring(readyReason))
    return
end

Log("Client ready")

--==================================================
-- [3] NOTIFICATION SIGNALS
--==================================================

local LastTokenFailure =
    0

local LastPendingSale =
    0

local function HookNotifications()

    local gameEvents =
        ReplicatedStorage:FindFirstChild("GameEvents")

    if not gameEvents then
        return false
    end

    local notificationRemote =
        gameEvents:FindFirstChild("Notification")

    if not notificationRemote
    or not notificationRemote:IsA("RemoteEvent") then
        return false
    end

    notificationRemote.OnClientEvent:Connect(function(message)

        if type(message) ~= "string" then
            return
        end

        local lower =
            message:lower()

        if lower:find("don't have enough tokens", 1, true) then
            LastTokenFailure =
                os.clock()

            Warn("Not enough tokens")
            return
        end

        if lower:find("pending sale", 1, true) then
            LastPendingSale =
                os.clock()

            Warn("Pending sale detected")
            return
        end
    end)

    return true
end

HookNotifications()

--==================================================
-- [4] BOOTH DATA ACCESS
--==================================================

local TradeBoothController =
    nil

local BoothStore =
    nil

local LatestBoothData =
    nil

local LatestBoothUpdate =
    0

local function GetController()

    if TradeBoothController then
        return TradeBoothController
    end

    local ok, result =
        pcall(function()
            return require(
                ReplicatedStorage
                    :WaitForChild("Modules", 10)
                    :WaitForChild("TradeBoothControllers", 10)
                    :WaitForChild("TradeBoothController", 10)
            )
        end)

    if ok and result then
        TradeBoothController =
            result

        return result
    end

    return nil
end

local function ResolveGetUpvalues(fn)

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

    if ok
    and type(upvalues) == "table" then
        return upvalues
    end

    return nil
end

local function PrimeBoothControllerData()

    local controller =
        GetController()

    if not controller
    or type(controller.GetPlayerBoothData) ~= "function" then
        return false
    end

    pcall(function()
        controller:GetPlayerBoothData()
    end)

    pcall(function()
        controller.GetPlayerBoothData(controller)
    end)

    return true
end

local function GetBoothStore()

    if BoothStore
    and type(BoothStore.GetDataAsync) == "function" then
        return BoothStore
    end

    local controller =
        GetController()

    if not controller
    or type(controller.GetPlayerBoothData) ~= "function" then
        return nil
    end

    PrimeBoothControllerData()

    local upvalues =
        ResolveGetUpvalues(
            controller.GetPlayerBoothData
        )

    if type(upvalues) ~= "table" then
        return nil
    end

    for _, value in ipairs(upvalues) do

        if type(value) == "table"
        and type(value.GetDataAsync) == "function" then

            BoothStore =
                value

            return BoothStore
        end
    end

    return nil
end

local function RefreshLatestBoothDataNow(reason)

    local store =
        GetBoothStore()

    if not store
    or type(store.GetDataAsync) ~= "function" then
        return nil, "Booth store missing"
    end

    local ok, data =
        pcall(function()
            return store:GetDataAsync()
        end)

    if not ok
    or type(data) ~= "table" then
        return nil, "Booth data fetch failed"
    end

    if type(data.Booths) ~= "table" then
        return nil, "Booth data missing Booths"
    end

    LatestBoothData =
        data

    LatestBoothUpdate =
        os.clock()

    return data, tostring(reason or "Fetched")
end

task.spawn(function()

    while IsCurrentRun() do

        local data, reason =
            RefreshLatestBoothDataNow("worker")

        if not data
        and CONFIG.Debug == true then
            Warn("Booth refresh failed:", tostring(reason))
        end

        task.wait(
            math.clamp(
                SafeNumber(CONFIG.BoothRefreshInterval, 0.05),
                0.01,
                1
            )
        )
    end
end)

--==================================================
-- [5] PET / WEIGHT / MUTATION HELPERS
--==================================================

local function NormalizeText(value)

    return tostring(value or "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

local function ResolveDisplayWeightFromBaseAge(baseWeight, age)

    baseWeight =
        tonumber(baseWeight)

    age =
        tonumber(age)

    if not baseWeight then
        return nil
    end

    if not age then
        age = 100
    end

    age =
        math.clamp(age, 0, 10000)

    local displayWeight =
        baseWeight * (1 + (0.1 * age))

    return math.floor(displayWeight * 100 + 0.5) / 100
end

local function ResolveAge(petData, itemData, listingData)

    local best =
        nil

    local function read(value)

        local number =
            tonumber(value)

        if not number then
            return
        end

        number =
            math.floor(number)

        if number <= 0
        or number > 10000 then
            return
        end

        if not best
        or number > best then
            best =
                number
        end
    end

    local sources = {
        petData,
        itemData,
        listingData,
    }

    for _, source in ipairs(sources) do

        if type(source) == "table" then

            read(rawget(source, "Level"))
            read(rawget(source, "level"))
            read(rawget(source, "Age"))
            read(rawget(source, "age"))
            read(rawget(source, "PetLevel"))
            read(rawget(source, "petLevel"))
            read(rawget(source, "PetAge"))
            read(rawget(source, "petAge"))

            local nested =
                rawget(source, "PetData")

            if type(nested) == "table" then
                read(rawget(nested, "Level"))
                read(rawget(nested, "Age"))
            end
        end
    end

    return best
end

local function ResolveCurrentWeight(petData, itemData, listingData, age)

    local baseWeight =
        tonumber(
            petData
            and (
                petData.BaseWeight
                or rawget(petData, "BaseWeight")
                or petData.baseWeight
            )
        )

    local sources = {
        petData,
        itemData,
        listingData,
    }

    for _, source in ipairs(sources) do

        if type(source) == "table" then

            local candidates = {
                rawget(source, "DisplayWeight"),
                rawget(source, "displayWeight"),
                rawget(source, "CurrentWeight"),
                rawget(source, "currentWeight"),
                rawget(source, "KG"),
                rawget(source, "Kg"),
                rawget(source, "Mass"),
                rawget(source, "mass"),
                rawget(source, "Weight"),
                rawget(source, "weight"),
            }

            for _, value in ipairs(candidates) do

                local number =
                    tonumber(value)

                if number then

                    if baseWeight
                    and math.abs(number - baseWeight) < 0.001 then
                        return ResolveDisplayWeightFromBaseAge(
                            baseWeight,
                            age
                        ) or number
                    end

                    return number
                end
            end
        end
    end

    if baseWeight then
        return ResolveDisplayWeightFromBaseAge(
            baseWeight,
            age
        ) or baseWeight
    end

    return 0
end

local function ResolveMutationText(petData, itemData, listingData)

    local sources = {
        petData,
        itemData,
        listingData,
    }

    local keys = {
        "MutationText",
        "MutationName",
        "Mutation",
        "MutationType",
        "Variant",
        "mutationText",
        "mutationName",
        "mutation",
        "mutationType",
        "variant",
    }

    for _, source in ipairs(sources) do

        if type(source) == "table" then

            for _, key in ipairs(keys) do

                local value =
                    rawget(source, key)

                local text =
                    NormalizeText(value)

                if text ~= ""
                and text ~= "---"
                and text ~= "nil"
                and text ~= "false"
                and text ~= "0"
                and text ~= "Normal"
                and text ~= "Unknown" then
                    return text
                end
            end
        end
    end

    return "Normal"
end

local function ParsePetTool(tool)

    if not tool
    or not tool:IsA("Tool") then
        return nil
    end

    local rawName =
        tostring(tool.Name or "")

    local weight =
        tonumber(
            rawName:match("%[(.-)%s*KG%]")
        )

    if not weight then
        return nil
    end

    local petName =
        rawName:gsub("%b[]", "")
            :gsub("%s+", " ")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    if petName == "" then
        return nil
    end

    return {
        Tool = tool,
        PetName = petName,
        Weight = weight,
    }
end

--==================================================
-- [6] ACTIVE BOOTH / LISTING EXTRACTION
--==================================================

local function BuildActiveBoothMap()

    local active =
        {}

    local tradeWorld =
        workspace:FindFirstChild("TradeWorld")

    local booths =
        tradeWorld
        and tradeWorld:FindFirstChild("Booths")

    if not booths then
        return active
    end

    for _, booth in ipairs(booths:GetChildren()) do
        active[booth.Name] =
            true
    end

    return active
end

local function ExtractListings()

    local data =
        LatestBoothData

    if type(data) ~= "table"
    or type(data.Booths) ~= "table"
    or type(data.Players) ~= "table" then
        return {}, 0
    end

    local activeBooths =
        BuildActiveBoothMap()

    local listings =
        {}

    local scanned =
        0

    for boothId, boothData in pairs(data.Booths) do

        if not activeBooths[boothId] then
            continue
        end

        if type(boothData) ~= "table" then
            continue
        end

        local owner =
            boothData.Owner

        if not owner then
            continue
        end

        local playerData =
            data.Players[owner]

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

        local sellerUserId =
            tonumber(
                tostring(owner):match("_(%d+)$")
            )

        if sellerUserId == LocalPlayer.UserId then
            continue
        end

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
                continue
            end

            local petData =
                itemData.PetData

            if type(petData) ~= "table" then
                continue
            end

            if petData.IsFavorite == true then
                continue
            end

            local petName =
                tostring(
                    itemData.PetType
                    or itemData.PetName
                    or itemData.Name
                    or "Unknown"
                )

            if petName == ""
            or petName == "Unknown" then
                continue
            end

            local price =
                tonumber(listingData.Price)
                or 0

            if price <= 0 then
                continue
            end

            local baseWeight =
                tonumber(petData.BaseWeight)

            if not baseWeight then
                continue
            end

            local age =
                ResolveAge(
                    petData,
                    itemData,
                    listingData
                )

            local displayWeight =
                ResolveCurrentWeight(
                    petData,
                    itemData,
                    listingData,
                    age
                )

            local mutationText =
                ResolveMutationText(
                    petData,
                    itemData,
                    listingData
                )

            scanned =
                scanned + 1

            table.insert(listings, {
                BoothId = tostring(boothId),
                UID = uid,

                SellerUserId = sellerUserId,

                PetName = petName,
                Price = price,

                BaseWeight = baseWeight,
                DisplayWeight = displayWeight,
                Weight = displayWeight,

                Age = age,
                MutationText = mutationText,

                SeenAt = os.clock(),
            })
        end
    end

    return listings, scanned
end

--==================================================
-- [7] FILTER MATCHING / PRIORITY
--==================================================

local function ClampPriority(value)

    local number =
        tonumber(value)

    if not number then
        return 5
    end

    return math.clamp(
        math.floor(number),
        1,
        10
    )
end

local function BuildMutationMap(text)

    local output =
        {}

    text =
        tostring(text or "Normal")

    if text == ""
    or text == "---"
    or text == "Normal"
    or text == "Unknown" then
        return output
    end

    text =
        text:gsub("[,/;|]+", " ")

    for token in string.gmatch(text, "%S+") do

        token =
            NormalizeText(token)

        if token ~= ""
        and token ~= "Normal"
        and token ~= "Unknown" then
            output[token] =
                true
        end
    end

    return output
end

local function MapIsEmpty(map)

    if type(map) ~= "table" then
        return true
    end

    for _ in pairs(map) do
        return false
    end

    return true
end

local function MapHasAny(source, selected)

    if type(source) ~= "table"
    or type(selected) ~= "table" then
        return false
    end

    for mutationName in pairs(selected) do

        if source[mutationName] == true then
            return true
        end
    end

    return false
end

local function ListingPassesMutationFilter(listing, filter)

    local mode =
        tostring(filter.Mutation or "Off")

    if mode == "Off"
    or mode == ""
    or mode == "---" then
        return true
    end

    local listingMap =
        BuildMutationMap(
            listing.MutationText
        )

    local hasMutation =
        not MapIsEmpty(listingMap)

    if mode == "Mutated Only" then
        return hasMutation
    end

    if mode == "Specific" then

        if not hasMutation then
            return false
        end

        if MapIsEmpty(filter.SpecificMutations) then
            return false
        end

        return MapHasAny(
            listingMap,
            filter.SpecificMutations
        )
    end

    if mode == "Exclude" then

        if MapIsEmpty(filter.ExcludedMutations) then
            return true
        end

        return not MapHasAny(
            listingMap,
            filter.ExcludedMutations
        )
    end

    return true
end

local function ResolveListingWeightForFilter(listing, filter)

    local weightMode =
        tostring(filter.WeightMode or "BaseWeight")

    if weightMode == "DisplayWeight" then
        return tonumber(listing.DisplayWeight)
            or tonumber(listing.Weight)
            or 0
    end

    return tonumber(listing.BaseWeight)
        or 0
end

local function ListingMatchesFilter(listing)

    if type(listing) ~= "table"
    or not listing.PetName then
        return false
    end

    local filter =
        CONFIG.Watchlist[listing.PetName]

    if type(filter) ~= "table" then
        return false
    end

    local maxPrice =
        tonumber(filter.MaxPrice)
        or math.huge

    if listing.Price > maxPrice then
        return false
    end

    local listingWeight =
        ResolveListingWeightForFilter(
            listing,
            filter
        )

    local minWeight =
        0

    if tostring(filter.WeightMode or "BaseWeight") == "DisplayWeight" then
        minWeight =
            tonumber(filter.MinDisplayWeight)
            or 0
    else
        minWeight =
            tonumber(filter.MinBaseWeight)
            or 0
    end

    if listingWeight < minWeight then
        return false
    end

    if not ListingPassesMutationFilter(listing, filter) then
        return false
    end

    listing.MatchedFilter =
        filter

    listing.MatchedPriority =
        ClampPriority(filter.Priority)

    listing.MatchedWeight =
        listingWeight

    local dealScore =
        0

    if maxPrice ~= math.huge
    and maxPrice > 0 then
        dealScore =
            1 - (listing.Price / maxPrice)
    end

    listing.MatchedDealScore =
        math.clamp(dealScore, -1, 1)

    return true
end

local function CompareListings(a, b)

    if not a then
        return false
    end

    if not b then
        return true
    end

    local aPriority =
        ClampPriority(a.MatchedPriority)

    local bPriority =
        ClampPriority(b.MatchedPriority)

    if aPriority ~= bPriority then
        return aPriority > bPriority
    end

    local aDeal =
        tonumber(a.MatchedDealScore)
        or 0

    local bDeal =
        tonumber(b.MatchedDealScore)
        or 0

    if aDeal ~= bDeal then
        return aDeal > bDeal
    end

    local aPrice =
        tonumber(a.Price)
        or math.huge

    local bPrice =
        tonumber(b.Price)
        or math.huge

    if aPrice ~= bPrice then
        return aPrice < bPrice
    end

    local aWeight =
        tonumber(a.MatchedWeight)
        or 0

    local bWeight =
        tonumber(b.MatchedWeight)
        or 0

    if aWeight ~= bWeight then
        return aWeight > bWeight
    end

    return tostring(a.UID or "")
        < tostring(b.UID or "")
end

local function BuildCandidates(listings)

    local candidates =
        {}

    for _, listing in ipairs(listings) do

        if ListingMatchesFilter(listing) then

            table.insert(
                candidates,
                listing
            )
        end
    end

    table.sort(
        candidates,
        CompareListings
    )

    return candidates
end

--==================================================
-- [8] BUY REMOTE / INVENTORY CONFIRM
--==================================================

local BuyListingRemote =
    nil

local function GetBuyRemote()

    if BuyListingRemote then
        return BuyListingRemote
    end

    local remote =
        ReplicatedStorage
            :WaitForChild("GameEvents", 10)
            :WaitForChild("TradeEvents", 10)
            :WaitForChild("Booths", 10)
            :FindFirstChild("BuyListing")

    if remote
    and remote:IsA("RemoteFunction") then
        BuyListingRemote =
            remote

        return remote
    end

    return nil
end

local function ToolMatchesListing(tool, listing)

    local parsed =
        ParsePetTool(tool)

    if not parsed then
        return false
    end

    local parsedName =
        tostring(parsed.PetName or ""):lower()

    local targetName =
        tostring(listing.PetName or ""):lower()

    if targetName == "" then
        return false
    end

    if parsedName == targetName then
        return true
    end

    -- Handles mutation prefix:
    -- "Rainbow Seal" can match base listing "Seal".
    if #parsedName >= #targetName
    and parsedName:sub(-#targetName) == targetName then
        return true
    end

    return false
end

local function CreateInventoryWaiter(listing)

    local resolved =
        false

    local matchedToolName =
        nil

    local matchedSource =
        nil

    local connections =
        {}

    local function Disconnect()

        for _, connection in ipairs(connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end

        table.clear(connections)
    end

    local function OnAdded(child, source)

        if resolved then
            return
        end

        if not ToolMatchesListing(child, listing) then
            return
        end

        resolved =
            true

        matchedToolName =
            tostring(child.Name)

        matchedSource =
            tostring(source)

        print(
            string.format(
                "[SNIPER TEST] [INV CONFIRM] %s entered %s at %.3f",
                tostring(matchedToolName),
                tostring(matchedSource),
                os.clock()
            )
        )
    end

    local backpack =
        LocalPlayer:FindFirstChild("Backpack")

    if backpack then
        table.insert(
            connections,
            backpack.ChildAdded:Connect(function(child)
                OnAdded(child, "Backpack")
            end)
        )
    end

    local character =
        LocalPlayer.Character

    if character then
        table.insert(
            connections,
            character.ChildAdded:Connect(function(child)
                OnAdded(child, "Character")
            end)
        )
    end

    return {
        Wait = function(timeout)

            local deadline =
                os.clock()
                + SafeNumber(timeout, 10)

            while IsCurrentRun()
            and not resolved
            and os.clock() < deadline do
                task.wait(0.03)
            end

            Disconnect()

            return resolved, matchedToolName, matchedSource
        end,

        Disconnect = Disconnect,
    }
end

--==================================================
-- [9] PURCHASE STATE
--==================================================

local PurchaseState = {
    Busy = false,
    LastPurchaseAt = 0,
    SuccessCount = 0,
    FailedCount = 0,
    LostRaceCount = 0,
}

local FailedListings =
    {}

local ProcessedListings =
    {}

local ActivePurchases =
    {}

local function GetListingKey(listing)

    return tostring(listing.BoothId)
        .. "_"
        .. tostring(listing.UID)
end

local function CleanupRuntimeLocks()

    local now =
        os.clock()

    local ttl =
        math.clamp(
            SafeNumber(CONFIG.FailedListingTTL, 12),
            3,
            120
        )

    for listingKey, failedAt in pairs(FailedListings) do

        if now - SafeNumber(failedAt, 0) >= ttl then
            FailedListings[listingKey] =
                nil
        end
    end
end

local function TryPurchaseListing(listing)

    if type(listing) ~= "table" then
        return false, "listing missing"
    end

    local listingKey =
        GetListingKey(listing)

    if listingKey == "" then
        return false, "listing key missing"
    end

    if ProcessedListings[listingKey] then
        return false, "already processed"
    end

    if FailedListings[listingKey] then
        return false, "failed locked"
    end

    if ActivePurchases[listingKey] then
        return false, "already active"
    end

    local remote =
        GetBuyRemote()

    if not remote then
        return false, "buy remote missing"
    end

    local sellerPlayer =
        Players:GetPlayerByUserId(
            listing.SellerUserId
        )

    if not sellerPlayer then

        FailedListings[listingKey] =
            os.clock()

        return false, "seller player missing"
    end

    ActivePurchases[listingKey] =
        true

    print(
        string.format(
            "[SNIPER TEST] [BUYING] P%s %s | %sT | BW %.2f | KG %.2f | Age %s | Mut %s",
            tostring(listing.MatchedPriority or 5),
            tostring(listing.PetName),
            tostring(listing.Price),
            tonumber(listing.BaseWeight) or 0,
            tonumber(listing.DisplayWeight) or 0,
            tostring(listing.Age or "?"),
            tostring(listing.MutationText or "Normal")
        )
    )

    local buyStartedAt =
        os.clock()

    local inventoryWaiter =
        CreateInventoryWaiter(listing)

    local ok, result =
        pcall(function()
            return remote:InvokeServer(
                sellerPlayer,
                listing.UID
            )
        end)

    LastTokenFailure =
        SafeNumber(LastTokenFailure, 0)

    if SafeElapsed(LastTokenFailure) < 1 then

        inventoryWaiter.Disconnect()

        FailedListings[listingKey] =
            os.clock()

        ActivePurchases[listingKey] =
            nil

        PurchaseState.FailedCount += 1

        Warn("Buy failed: not enough tokens:", tostring(listing.PetName))

        return false, "not enough tokens"
    end

    if not ok then

        inventoryWaiter.Disconnect()

        FailedListings[listingKey] =
            os.clock()

        ActivePurchases[listingKey] =
            nil

        PurchaseState.FailedCount += 1

        Warn("Buy invoke error:", tostring(result))

        return false, tostring(result)
    end

    if result == false then

        inventoryWaiter.Disconnect()

        LastPendingSale =
            SafeNumber(LastPendingSale, 0)

        if SafeElapsed(LastPendingSale) < 1.25 then

            ActivePurchases[listingKey] =
                nil

            Warn("Pending sale:", tostring(listing.PetName))

            return false, "pending sale"
        end

        FailedListings[listingKey] =
            os.clock()

        ActivePurchases[listingKey] =
            nil

        PurchaseState.LostRaceCount += 1

        Warn("Server rejected / lost race:", tostring(listing.PetName))

        return false, "server rejected"
    end

    print(
        string.format(
            "[SNIPER TEST] [BUY ACCEPTED] %s at %.3f",
            tostring(listing.PetName),
            os.clock()
        )
    )

    local confirmed, toolName, source =
        inventoryWaiter.Wait(
            CONFIG.InventoryConfirmTimeout
        )

    if not confirmed then

        FailedListings[listingKey] =
            os.clock()

        ActivePurchases[listingKey] =
            nil

        PurchaseState.FailedCount += 1

        Warn(
            "Inventory confirm timeout:",
            tostring(listing.PetName)
        )

        return false, "inventory timeout"
    end

    ProcessedListings[listingKey] =
        os.clock()

    ActivePurchases[listingKey] =
        nil

    PurchaseState.SuccessCount += 1

    local confirmDelay =
        os.clock() - buyStartedAt

    print(
        string.format(
            "[SNIPER TEST] [BOUGHT CONFIRMED] %s | tool: %s | source: %s | delay: %.3fs",
            tostring(listing.PetName),
            tostring(toolName),
            tostring(source),
            confirmDelay
        )
    )

    return true, "confirmed"
end

local function DispatchBestCandidate(candidate)

    if not candidate then
        return false
    end

    if PurchaseState.Busy == true then
        return false
    end

    PurchaseState.Busy =
        true

    local ok, success, reason =
        pcall(function()
            return TryPurchaseListing(candidate)
        end)

    if not ok then
        Warn("Purchase crashed:", tostring(success))
    else
        Log("Purchase result:", tostring(success), tostring(reason))
    end

    PurchaseState.LastPurchaseAt =
        os.clock()

    task.delay(
        math.clamp(
            SafeNumber(CONFIG.RecoveryDelay, 0.05),
            0.01,
            2
        ),
        function()
            PurchaseState.Busy =
                false
        end
    )

    return true
end

--==================================================
-- [10] MAIN SNIPER LOOP
--==================================================

local SniperStats = {
    ScanPasses = 0,
    ListingsScanned = 0,
    CandidatesFound = 0,
    LastBest = "None",
    LastStatus = "Booting",
}

local function RunSniperPass()

    CleanupRuntimeLocks()

    local listings, scanned =
        ExtractListings()

    SniperStats.ScanPasses += 1
    SniperStats.ListingsScanned =
        scanned or 0

    if CONFIG.DebugListings == true then
        print(
            "[SNIPER TEST] Listings:",
            tostring(#listings),
            "| scanned:",
            tostring(scanned)
        )
    end

    local candidates =
        BuildCandidates(listings)

    SniperStats.CandidatesFound =
        #candidates

    if #candidates <= 0 then

        SniperStats.LastStatus =
            "No matches"

        if CONFIG.DebugNoMatches == true then
            print(
                "[SNIPER TEST] No matches | scanned:",
                tostring(scanned)
            )
        end

        return false
    end

    local best =
        candidates[1]

    SniperStats.LastBest =
        tostring(best.PetName)
        .. " | "
        .. tostring(best.Price)
        .. "T | P"
        .. tostring(best.MatchedPriority)

    print(
        string.format(
            "[SNIPER TEST] [MATCH] best: P%s %s | %sT | BW %.2f | KG %.2f | candidates %s",
            tostring(best.MatchedPriority or 5),
            tostring(best.PetName),
            tostring(best.Price),
            tonumber(best.BaseWeight) or 0,
            tonumber(best.DisplayWeight) or 0,
            tostring(#candidates)
        )
    )

    if CONFIG.Enabled ~= true then

        SniperStats.LastStatus =
            "Matched but disabled"

        return false
    end

    if PurchaseState.Busy == true
    and CONFIG.QueueWhileBuying ~= true then

        SniperStats.LastStatus =
            "Buy lane busy"

        return false
    end

    SniperStats.LastStatus =
        "Dispatching"

    return DispatchBestCandidate(best)
end

task.spawn(function()

    while IsCurrentRun() do

        if CONFIG.Enabled == true then

            local ok, err =
                pcall(function()
                    RunSniperPass()
                end)

            if not ok then
                Warn("Scan pass error:", tostring(err))
            end
        end

        task.wait(
            math.clamp(
                SafeNumber(CONFIG.ScanInterval, 0.02),
                0.005,
                1
            )
        )
    end
end)

--==================================================
-- [11] SIMPLE STATUS PRINTER
--==================================================

task.spawn(function()

    while IsCurrentRun() do

        task.wait(5)

        print(
            string.format(
                "[SNIPER TEST] Status: %s | scans %s | scanned %s | matches %s | success %s | failed %s | lost %s | best %s",
                tostring(SniperStats.LastStatus),
                tostring(SniperStats.ScanPasses),
                tostring(SniperStats.ListingsScanned),
                tostring(SniperStats.CandidatesFound),
                tostring(PurchaseState.SuccessCount),
                tostring(PurchaseState.FailedCount),
                tostring(PurchaseState.LostRaceCount),
                tostring(SniperStats.LastBest)
            )
        )
    end
end)

print("==================================================")
print("HOLY SNIPER TEST LOADED")
print("Enabled:", tostring(CONFIG.Enabled))
print("ScanInterval:", tostring(CONFIG.ScanInterval))
print("BoothRefreshInterval:", tostring(CONFIG.BoothRefreshInterval))
print("Watchlist pets:")

for petName, filter in pairs(CONFIG.Watchlist) do
    print(
        "-",
        tostring(petName),
        "| Max",
        tostring(filter.MaxPrice),
        "| WeightMode",
        tostring(filter.WeightMode),
        "| Priority",
        tostring(filter.Priority)
    )
end

print("==================================================")
