--==================================================
-- HOLY v3.3.7 — OBSIDIAN FOUNDATION GROW A GARDEN TRADE MARKET SCRIPT
-- Purpose: Deterministic, modular base (no features)
--==================================================

--==================================================
-- [0] GLOBAL CONSTANTS (ORDER CRITICAL)
--==================================================
HttpService =
    game:GetService("HttpService")

VirtualUser =
    game:GetService("VirtualUser")

UserInputService =
    game:GetService("UserInputService")


--==================================================
-- OBFUSCATION / RE-EXECUTION SAFETY
-- Stops old worker loops when the script is re-executed.
--==================================================

HOLY_RUNTIME_ROOT =
    (
        type(getgenv) == "function"
        and getgenv()
        or _G
    ).HOLY_RUNTIME_ROOT
    or {}

if type(getgenv) == "function" then
    getgenv().HOLY_RUNTIME_ROOT =
        HOLY_RUNTIME_ROOT
else
    _G.HOLY_RUNTIME_ROOT =
        HOLY_RUNTIME_ROOT
end

HOLY_RUN_ID =
    tostring(os.clock())
    .. "_"
    .. tostring(math.random(100000, 999999))

HOLY_RUNTIME_ROOT.RunId =
    HOLY_RUN_ID

function IsCurrentRun()

    return HOLY_RUNTIME_ROOT
        and HOLY_RUNTIME_ROOT.RunId == HOLY_RUN_ID
end

-- Early safe helpers.
-- These are defined again later, but must exist before early workers start.
function SafeNumber(value, fallback)

    local numberValue =
        tonumber(value)

    if numberValue == nil then
        return fallback or 0
    end

    return numberValue
end

function SafeElapsed(lastTime)

    return os.clock()
        - SafeNumber(lastTime, 0)
end

function SafeRemaining(targetTime)

    return SafeNumber(targetTime, 0)
        - os.clock()
end

function IsTradeWorld()

    return game.PlaceId == TRADING_WORLD_PLACE_ID
end

--==================================================
-- [1] BOOTSTRAP
--==================================================
if not game:IsLoaded() then
    game.Loaded:Wait()
end

TRADING_WORLD_PLACE_ID = 129954712878723
Players = game:GetService("Players")
ReplicatedStorage = game:GetService("ReplicatedStorage")

ServerInfoStartedAt = 0

function ResolveServerJoinClock()

    local player =
        Players.LocalPlayer

    if not player then
        return os.clock()
    end

    local storedJobId =
        player:GetAttribute("HolyServerJoinJobId")

    local storedClock =
        player:GetAttribute("HolyServerJoinClock")

    -- Only reuse the stored time if it belongs to this exact server.
    if storedJobId == game.JobId
    and type(storedClock) == "number" then
        return storedClock
    end

    local joinClock =
        os.clock()

    player:SetAttribute(
        "HolyServerJoinJobId",
        game.JobId
    )

    player:SetAttribute(
        "HolyServerJoinClock",
        joinClock
    )

    return joinClock
end

ServerInfoStartedAt =
    ResolveServerJoinClock()
--==================================================
-- VOICE CHAT REMOTE SINK
-- Prevents discarded event spam
--==================================================

task.spawn(function()

    local remote =
        ReplicatedStorage:WaitForChild(
            "SendLikelySpeakingUsers",
            10
        )

    if not remote
    or not remote:IsA("RemoteEvent") then
        return
    end

    remote.OnClientEvent:Connect(function()
        -- intentionally ignored
    end)

end)

TradeBoothController = nil
function GetController()
    if TradeBoothController then
        return TradeBoothController
    end

    local ok, result = pcall(function()
        return require(
            ReplicatedStorage
                .Modules
                .TradeBoothControllers
                .TradeBoothController
        )
    end)

    if ok and result then
        TradeBoothController = result
        return result
    end

    return nil
end


function GetTokenBalance()

    local playerGui =
        Players.LocalPlayer:FindFirstChild("PlayerGui")

    if not playerGui then
        return 0
    end

    local tokenUI =
        playerGui:FindFirstChild("TradeTokenCurrency_UI")

    if not tokenUI then
        return 0
    end

    local tradeTokens =
        tokenUI:FindFirstChild("TradeTokens")

    if not tradeTokens then
        return 0
    end

    local bestNumber = 0

    for _, obj in ipairs(tradeTokens:GetDescendants()) do

        if obj:IsA("TextLabel") then

            local text =
                tostring(obj.Text)

            local number =
                text:gsub(",", "")
                    :match("%d+")

            number = tonumber(number)

            if number
            and number > bestNumber then

                bestNumber = number
            end
        end
    end

    return bestNumber
end


--==================================================
-- [2] CLIENT READINESS GATE
--==================================================
function WaitForClientReady()
    local player = Players.LocalPlayer
    if not player then
        return false
    end

    local start = os.clock()

    -- Phase 1: player core
    while not (
        player:FindFirstChild("Backpack")
        and player:FindFirstChild("PlayerGui")
    ) do
        if os.clock() - start > 15 then
            warn("[BOOT] Player core timeout")
            return false
        end
        task.wait(0.1)
    end

    -- Phase 2: replication
    start = os.clock()
    while not ReplicatedStorage:FindFirstChild("GameEvents") do
        if os.clock() - start > 15 then
            warn("[BOOT] Replication timeout")
            return false
        end
        task.wait(0.1)
    end

    return true
end

-- Phase 3: Trade World (authoritative world objects)
if game.PlaceId == TRADING_WORLD_PLACE_ID then
    local start = os.clock()

    while not (
        workspace:FindFirstChild("TradeWorld")
        and workspace.TradeWorld:FindFirstChild("Booths")
    ) do
        if os.clock() - start > 20 then
            warn("[BOOT] Trade World timeout")
            return false
        end

        task.wait(0.2)
    end
end

if not WaitForClientReady() then
    warn("[HOLY] Boot failed")
    return
end

print("[HOLY] Client ready")
print("[DEBUG] Passed readiness gate")

--==================================================
-- VISUAL PATCH: BLACK TRADE WORLD TOP BASEPLATE
-- Keeps workspace.TradeWorld.TopBaseplate black client-side
--==================================================

function ApplyBlackTopBaseplate()

    local tradeWorld =
        workspace:FindFirstChild("TradeWorld")

    if not tradeWorld then
        return false
    end

    local topBaseplate =
        tradeWorld:FindFirstChild("TopBaseplate")

    if not topBaseplate then
        return false
    end

    if topBaseplate:IsA("BasePart") then

        topBaseplate.Color =
            Color3.fromRGB(17, 17, 17)

        topBaseplate.Material =
            Enum.Material.Plastic

        topBaseplate.Reflectance =
            0

        return true
    end

    return false
end

task.spawn(function()

    if game.PlaceId ~= TRADING_WORLD_PLACE_ID then
        return
    end

    for i = 1, 30 do

        local applied =
            ApplyBlackTopBaseplate()

        if applied then
            print("[VISUAL] TopBaseplate set to black")
            break
        end

        task.wait(0.5)
    end
end)
--==================================================
-- VISUAL PATCH: BLACK TRADE WORLD FLOOR / RING
-- Keeps selected TradeWorld parts black client-side
--==================================================

function ApplyBlackTradeWorldParts()

    local tradeWorld =
        workspace:FindFirstChild("TradeWorld")

    if not tradeWorld then
        return false
    end

    local applied = false

    local function PaintBlack(part)

        if not part
        or not part:IsA("BasePart") then
            return
        end

        part.Color =
            Color3.fromRGB(17, 17, 17)

        part.BrickColor =
            BrickColor.new("Really black")

        part.Material =
            Enum.Material.Plastic

        part.Reflectance =
            0

        applied = true
    end

    -- workspace.TradeWorld.TopBaseplate
    PaintBlack(
        tradeWorld:FindFirstChild("TopBaseplate")
    )

    -- workspace.TradeWorld.Ring.Union
    local ring =
        tradeWorld:FindFirstChild("Ring")

    if ring then
        PaintBlack(
            ring:FindFirstChild("Union")
        )
    end

    return applied
end

task.spawn(function()

    if game.PlaceId ~= TRADING_WORLD_PLACE_ID then
        return
    end

    for i = 1, 30 do

        local applied =
            ApplyBlackTradeWorldParts()

        if applied then
            print("[VISUAL] TradeWorld floor/ring set to black")
            break
        end

        task.wait(0.5)
    end
end)
--==================================================
-- BOOTH DATA ACCESS
--==================================================

BoothStore = nil
LatestBoothData = nil
LatestBoothUpdate = 0

function GetBoothStore()

    if BoothStore then
        return BoothStore
    end

    local Controller = GetController()

    if not Controller then
        return nil
    end

    local upvalues =
        getupvalues(
            Controller.GetPlayerBoothData
        )

    local store =
        upvalues
        and type(upvalues[2]) == "table"
        and upvalues[2]

    if not store then
        return nil
    end

    if type(store.GetDataAsync) ~= "function" then
        return nil
    end

    BoothStore = store

    return BoothStore
end
task.spawn(function()

    while IsCurrentRun() do

        if game.PlaceId ~= TRADING_WORLD_PLACE_ID then
            task.wait(1)
            continue
        end

        local store = GetBoothStore()

        if store then

            local ok, data = pcall(function()
                return store:GetDataAsync()
            end)

            if ok
            and data
            and data.Booths
            then
                LatestBoothData = data
                LatestBoothUpdate = os.clock()
            end
        end

        local refreshInterval =
            0.05

        if type(GetBoothDataRefreshInterval) == "function" then
            refreshInterval =
                GetBoothDataRefreshInterval()
        end

        task.wait(refreshInterval)
    end
end)

--==================================================
-- SNIPER RUNTIME STATE
--==================================================

SniperFilterSets = {
    [1] = {},
    [2] = {},
}
--==================================================
-- EGG FOCUS FILTERS
-- Simple egg-based sniper filters.
-- Example:
-- EggFocusFilterSets[1]["Paradise Egg"] = {
--     MaxPrice = 1000,
-- }
--==================================================

EggFocusFilterSets = {
    [1] = {},
    [2] = {},
}

EggFocusUIState = {
    SaveTarget = 1,
    ViewTarget = 1,
}
-- Legacy alias for compatibility with older code paths.
SniperFilters =
    SniperFilterSets[1]

SniperFilterUIState = {
    SaveTarget = 1,
    ViewTarget = 1,

    -- Per-filter default.
    -- DisplayWeight = shown KG value, BaseWeight = raw PetData.BaseWeight.
    WeightMode = "DisplayWeight",
    Priority = 5,

    -- Mutation Filter is OFF by default.
    -- Off = old sniper behavior: pet + price + weight only.
    SelectedMutation = "Off",

-- Shared UI selection.
-- Interpreted by SelectedMutation:
-- Specific Mutations = only selected mutations pass.
-- Exclude Mutations = selected mutations are skipped.
SelectedMutationSelection = {},

-- Saved/runtime compatibility fields.
SelectedSpecificMutations = {},
SelectedExcludedMutations = {},

}

function NormalizeWatchlistId(value)

    if value == 2
    or value == "2"
    or value == "Watchlist 2" then
        return 2
    end

    return 1
end

function NormalizeWeightMode(value)

    value =
        tostring(value or "DisplayWeight")

    if value == "BaseWeight"
    or value == "Base Weight"
    or value == "Raw BaseWeight"
    or value:lower() == "baseweight"
    or value:lower() == "base weight" then
        return "BaseWeight"
    end

    return "DisplayWeight"
end

--==================================================
-- SNIPER PRIORITY HELPERS
-- Priority is per-filter.
-- 10 = buy first, 1 = low priority.
--==================================================

function ClampSniperPriority(value)

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

function ResolveSniperFilterPriority(filter)

    if type(filter) ~= "table" then
        return 5
    end

    return ClampSniperPriority(
        filter.Priority
    )
end

function ResolveSniperDealScore(listing, filter)

    if type(listing) ~= "table"
    or type(filter) ~= "table" then
        return 0
    end

    local price =
        tonumber(listing.Price)
        or math.huge

    local maxPrice =
        tonumber(filter.MaxPrice)

    if not maxPrice
    or maxPrice == math.huge
    or maxPrice <= 0 then
        return 0
    end

    local score =
        1 - (price / maxPrice)

    return math.clamp(
        score,
        -1,
        1
    )
end

function ComparePriorityListings(a, b)

    if type(a) ~= "table" then
        return false
    end

    if type(b) ~= "table" then
        return true
    end

    local aPriority =
        ClampSniperPriority(
            a.MatchedPriority
            or a.Priority
            or 5
        )

    local bPriority =
        ClampSniperPriority(
            b.MatchedPriority
            or b.Priority
            or 5
        )

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
        or tonumber(a.DisplayWeight)
        or tonumber(a.Weight)
        or 0

    local bWeight =
        tonumber(b.MatchedWeight)
        or tonumber(b.DisplayWeight)
        or tonumber(b.Weight)
        or 0

    if aWeight ~= bWeight then
        return aWeight > bWeight
    end

    return tostring(a.UID or "") < tostring(b.UID or "")
end

function ResolveListingWeightForFilter(listing, filter)

    if type(listing) ~= "table" then
        return 0, "DisplayWeight"
    end

    local weightMode =
        NormalizeWeightMode(
            filter
            and filter.WeightMode
            or "DisplayWeight"
        )

    if weightMode == "BaseWeight" then
        return tonumber(listing.BaseWeight) or 0, weightMode
    end

    return tonumber(listing.DisplayWeight or listing.Weight) or 0, weightMode
end

function FormatFilterWeight(value, weightMode)

    local weight =
        tonumber(value)
        or 0

    if weight <= 0 then
        return "-"
    end

    weightMode =
        NormalizeWeightMode(weightMode)

    if weightMode == "BaseWeight" then
        return tostring(weight) .. "bw"
    end

    return tostring(weight) .. "kg"
end

--==================================================
-- SNIPER MUTATION FILTER HELPERS
-- Off = no mutation rule, old sniper behavior.
-- Mutated Only = must have any mutation.
-- Specific Mutations = must have one selected mutation.
-- Exclude Mutations = skip selected mutations.
--==================================================

function NormalizeSniperFilterMutation(value)

    value =
        tostring(value or "Off")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    if value == "" then
        return "Off"
    end

    -- New clear sniper labels.
    if value == "Off"
    or value == "Mutated Only"
    or value == "Specific Mutations"
    or value == "Exclude Mutations" then
        return value
    end

    -- Backwards compatibility with older planned labels.
    if value == "---"
    or value == "Any"
    or value == "Normal" then
        return "Off"
    end

    if value == "All" then
        return "Mutated Only"
    end

    if value == "All Except" then
        return "Exclude Mutations"
    end

    if value == "Specific" then
        return "Specific Mutations"
    end

    -- Specific mutation name, like Rainbow/Aromatic.
    return value
end

function IsSniperMutationMode(value)

    value =
        NormalizeSniperFilterMutation(value)

    return value == "Off"
        or value == "Mutated Only"
        or value == "Specific Mutations"
        or value == "Exclude Mutations"
end

function CloneSniperMutationMap(source)

    local output = {}

    if type(source) ~= "table" then
        return output
    end

    for mutationName, enabled in pairs(source) do

        if enabled == true then

            mutationName =
                tostring(mutationName or "")
                    :gsub("^%s+", "")
                    :gsub("%s+$", "")

            if mutationName ~= ""
            and mutationName ~= "---"
            and mutationName ~= "Off"
            and mutationName ~= "Normal"
            and mutationName ~= "Unknown" then

                output[mutationName] =
                    true
            end
        end
    end

    return output
end

function SerializeSniperMutationMap(source)

    local output = {}

    source =
        CloneSniperMutationMap(source)

    for mutationName, enabled in pairs(source) do

        if enabled == true then

            table.insert(
                output,
                tostring(mutationName)
            )
        end
    end

    table.sort(output)

    return output
end

function DeserializeSniperMutationMap(source)

    local output = {}

    if type(source) ~= "table" then
        return output
    end

    for key, value in pairs(source) do

        local mutationName = nil

        if value == true then
            mutationName = key

        elseif type(value) == "string" then
            mutationName = value
        end

        mutationName =
            tostring(mutationName or "")
                :gsub("^%s+", "")
                :gsub("%s+$", "")

        if mutationName ~= ""
        and mutationName ~= "---"
        and mutationName ~= "Off"
        and mutationName ~= "Normal"
        and mutationName ~= "Unknown" then

            output[mutationName] =
                true
        end
    end

    return output
end

function BuildSniperMutationMapFromDropdownValue(value)

    local output = {}

    if type(value) ~= "table" then
        return output
    end

    for key, selected in pairs(value) do

        local mutationName = nil

        if selected == true then
            mutationName = key

        elseif type(selected) == "string" then
            mutationName = selected
        end

        mutationName =
            tostring(mutationName or "")
                :gsub("^%s+", "")
                :gsub("%s+$", "")

        if mutationName ~= ""
        and mutationName ~= "---"
        and mutationName ~= "Off"
        and mutationName ~= "Normal"
        and mutationName ~= "Unknown" then

            output[mutationName] =
                true
        end
    end

    return output
end

function BuildSniperListingMutationMap(listing)

    local output = {}

    if type(listing) ~= "table" then
        return output
    end

    local mutationText =
        tostring(
            listing.MutationText
            or listing.Mutation
            or "Normal"
        )

    if mutationText == ""
    or mutationText == "---"
    or mutationText == "Normal"
    or mutationText == "Unknown" then
        return output
    end

    mutationText =
        mutationText:gsub("[,/;|]+", " ")

    for token in string.gmatch(mutationText, "%S+") do

        local mutationName =
            tostring(token or "")
                :gsub("^%s+", "")
                :gsub("%s+$", "")

        if mutationName ~= ""
        and mutationName ~= "---"
        and mutationName ~= "Off"
        and mutationName ~= "Normal"
        and mutationName ~= "Unknown" then

            output[mutationName] =
                true
        end
    end

    return output
end

function SniperMutationMapIsEmpty(map)

    if type(map) ~= "table" then
        return true
    end

    for _ in pairs(map) do
        return false
    end

    return true
end

function SniperMutationMapHasAny(source, selected)

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

function ResolveSniperMutationModeAndSpecifics(filter)

    local mutation =
        NormalizeSniperFilterMutation(
            filter
            and (
                filter.Mutation
                or filter.SelectedMutation
            )
            or "Off"
        )

    local specific =
        DeserializeSniperMutationMap(
            filter
            and (
                filter.SpecificMutations
                or filter.IncludedMutations
            )
            or nil
        )

    -- Migration support:
    -- If an old filter stored Mutation = "Rainbow",
    -- convert it to Specific Mutations with Rainbow selected.
    if not IsSniperMutationMode(mutation) then

        if mutation ~= ""
        and mutation ~= "Normal"
        and mutation ~= "Unknown"
        and mutation ~= "Off" then

            specific[mutation] =
                true
        end

        mutation =
            "Specific Mutations"
    end

    return mutation, specific
end

function ListingPassesSniperMutationFilter(listing, filter)

    if type(filter) ~= "table" then
        return true
    end

    local selectedMutation, specificMutations =
        ResolveSniperMutationModeAndSpecifics(
            filter
        )

    -- Off = no mutation rule.
    -- This preserves old sniper behavior.
    if selectedMutation == "Off" then
        return true
    end

    local listingMutations =
        BuildSniperListingMutationMap(listing)

    local hasMutation =
        not SniperMutationMapIsEmpty(
            listingMutations
        )

    -- Mutated Only = any mutation, but no normal pets.
    if selectedMutation == "Mutated Only" then
        return hasMutation
    end

    -- Exclude Mutations = buy anything except selected blocked mutations.
    -- Normal pets pass because they do not contain excluded mutations.
    if selectedMutation == "Exclude Mutations" then

        local excluded =
            DeserializeSniperMutationMap(
                filter.ExcludedMutations
            )

        if SniperMutationMapIsEmpty(excluded) then
            return true
        end

        return not SniperMutationMapHasAny(
            listingMutations,
            excluded
        )
    end

    -- Specific Mutations = must contain at least one selected mutation.
    -- Safety: no selected mutations = buy nothing.
    if selectedMutation == "Specific Mutations" then

        if not hasMutation then
            return false
        end

        if SniperMutationMapIsEmpty(specificMutations) then
            return false
        end

        return SniperMutationMapHasAny(
            listingMutations,
            specificMutations
        )
    end

    return true
end

function FormatSniperMutationFilter(filter)

    if type(filter) ~= "table" then
        return "Off"
    end

    local mutation, specificMutations =
        ResolveSniperMutationModeAndSpecifics(
            filter
        )

    if mutation == "Off" then
        return "Off"
    end

    if mutation == "Mutated Only" then
        return "Mutated"
    end

    if mutation == "Exclude Mutations" then

        local excluded =
            SerializeSniperMutationMap(
                filter.ExcludedMutations
            )

        if #excluded <= 0 then
            return "Exclude: None"
        end

        if #excluded <= 2 then
            return "Exclude: " .. table.concat(excluded, ", ")
        end

        return "Exclude: " .. tostring(#excluded)
    end

    if mutation == "Specific Mutations" then

        local specific =
            SerializeSniperMutationMap(
                specificMutations
            )

        if #specific <= 0 then
            return "Specific: None"
        end

        if #specific <= 2 then
            return "Specific: " .. table.concat(specific, ", ")
        end

        return "Specific: " .. tostring(#specific)
    end

    return tostring(mutation)
end

function GetSniperFilterSet(watchlistId)

    watchlistId =
        NormalizeWatchlistId(watchlistId)

    if not SniperFilterSets[watchlistId] then
        SniperFilterSets[watchlistId] = {}
    end

    return SniperFilterSets[watchlistId]
end

function GetEggFocusSet(watchlistId)

    watchlistId =
        NormalizeWatchlistId(watchlistId)

    if not EggFocusFilterSets[watchlistId] then
        EggFocusFilterSets[watchlistId] = {}
    end

    return EggFocusFilterSets[watchlistId]
end

function CountEggFocusSet(watchlistId)

    local filters =
        GetEggFocusSet(watchlistId)

    local count = 0

    for _ in pairs(filters) do
        count = count + 1
    end

    return count
end

function CountAllEggFocusFilters()

    local total = 0

    for watchlistId = 1, 2 do
        total =
            total
            + CountEggFocusSet(watchlistId)
    end

    return total
end

PetRegistry =
    PetRegistry
    or nil

function GetPetRegistry()

    if type(PetRegistry) == "table" then
        return PetRegistry
    end

    local ok, result =
        pcall(function()
            return require(
                ReplicatedStorage
                    :WaitForChild("Data")
                    :WaitForChild("PetRegistry")
            )
        end)

    if ok
    and type(result) == "table" then
        PetRegistry = result
        return PetRegistry
    end

    return nil
end

function GetEggFocusNames()

    local registry =
        GetPetRegistry()

    if type(registry) ~= "table"
    or type(registry.PetEggs) ~= "table" then
        return {}
    end

    local names = {}

    for eggName, eggData in pairs(registry.PetEggs) do

        if type(eggData) == "table"
        and type(eggData.RarityData) == "table"
        and type(eggData.RarityData.Items) == "table" then

            table.insert(
                names,
                tostring(eggName)
            )
        end
    end

    table.sort(names)

    return names
end

function GetEggFocusPets(eggName)

    local registry =
        GetPetRegistry()

    if type(registry) ~= "table"
    or type(registry.PetEggs) ~= "table" then
        return {}
    end

    local eggData =
        registry.PetEggs[tostring(eggName)]

    local items =
        eggData
        and eggData.RarityData
        and eggData.RarityData.Items

    if type(items) ~= "table" then
        return {}
    end

    local pets = {}

    for petName in pairs(items) do
        table.insert(
            pets,
            tostring(petName)
        )
    end

    table.sort(pets)

    return pets
end

function EggFocusContainsPet(eggName, petName)

    eggName =
        tostring(eggName or "")

    petName =
        tostring(petName or "")

    if eggName == ""
    or petName == "" then
        return false
    end

    local registry =
        GetPetRegistry()

    if type(registry) ~= "table"
    or type(registry.PetEggs) ~= "table" then
        return false
    end

    local eggData =
        registry.PetEggs[eggName]

    local items =
        eggData
        and eggData.RarityData
        and eggData.RarityData.Items

    if type(items) ~= "table" then
        return false
    end

    return items[petName] ~= nil
end
function CountSniperFilterSet(watchlistId)

    local filters =
        GetSniperFilterSet(watchlistId)

    local count = 0

    for _ in pairs(filters) do
        count = count + 1
    end

    return count
end

function CountAllSniperFilters()

    local total = 0

    for watchlistId = 1, 2 do
        total =
            total
            + CountSniperFilterSet(watchlistId)
    end

    return total
end

SniperMonitorState = {
    Status = "Idle",

    -- pets/listings found in the latest scan pass only
    PetsScanned = 0,

    -- optional debug counter, hidden from HUD unless needed
    ScanPasses = 0,
}

SniperState = {

    -- runtime
    Scanning = false,
    Buying = false,
    Hopping = false,

    -- inventory safety
    MaxPetInventory = 350,
    StopAtPetInventoryLimit = true,

        -- scan timing
    LastScan = 0,
    ScanInterval = 0.02,
    ScanSpeedMode = "Fast",

    -- booth-data refresh timing
    -- Controls how often LatestBoothData is refreshed from TradeBoothController data.
    -- Keep separate from ScanInterval because GetDataAsync is heavier than scanning an existing snapshot.
    BoothDataRefreshMode = "Fast",
    BoothDataRefreshInterval = 0.05,

    -- auto hop
    AutoHop = false,
    HopDelay = 10,
    LastHop = 0,

    -- duration-based hopping
    ScanDuration = 10,
    ScanStartedAt = 0,

    -- stay after snipe
    StayAfterSnipe = true,
    StayAfterSnipeSeconds = 5,
    StayAfterSnipeUntil = 0,

    -- server selection
    MaxServerPlayers = 30,
    ServerHopMode = "Fullest Under Max",

    -- How many Roblox server-list pages to fetch during server hop.
    -- 1 = fastest hop, smaller server pool.
    -- Higher = better selection, slower hop.
    ServerHopPages = 1,

    -- server history
    RecentServers = {},
}
--==================================================
-- SNIPER SCAN SPEED CONFIG
-- Controls how often HOLY scans booth listings.
--==================================================

function ResolveSniperScanInterval(mode)

    mode =
        tostring(mode or "Fast")

    if mode == "Max Speed" then
        return 0.01
    end

    if mode == "Fast" then
        return 0.02
    end

    if mode == "Balanced" then
        return 0.05
    end

    if mode == "Low CPU" then
        return 0.10
    end

    if mode == "Ultra Safe" then
        return 0.20
    end

    return 0.02
end

function SetSniperScanSpeedMode(mode)

    mode =
        tostring(mode or "Fast")

    local allowed = {
        ["Max Speed"] = true,
        ["Fast"] = true,
        ["Balanced"] = true,
        ["Low CPU"] = true,
        ["Ultra Safe"] = true,
    }

    if not allowed[mode] then
        mode =
            "Fast"
    end

    SniperState.ScanSpeedMode =
        mode

    SniperState.ScanInterval =
        ResolveSniperScanInterval(mode)

    return SniperState.ScanInterval
end

--==================================================
-- BOOTH DATA REFRESH SPEED CONFIG
-- Controls how often LatestBoothData is refreshed.
-- This is intentionally separate from Sniper Scan Speed.
--==================================================

function ResolveBoothDataRefreshInterval(mode)

    mode =
        tostring(mode or "Fast")

    if mode == "Aggressive" then
        return 0.01
    end

    if mode == "Fast" then
        return 0.03
    end

    if mode == "Balanced" then
        return 0.05
    end

    if mode == "Low CPU" then
        return 0.10
    end

    if mode == "Ultra Safe" then
        return 0.20
    end

    return 0.05
end

function SetBoothDataRefreshMode(mode)

    mode =
        tostring(mode or "Fast")

    local allowed = {
        ["Aggressive"] = true,
        ["Fast"] = true,
        ["Balanced"] = true,
        ["Low CPU"] = true,
        ["Ultra Safe"] = true,
    }

    if not allowed[mode] then
        mode =
            "Fast"
    end

    SniperState.BoothDataRefreshMode =
        mode

    SniperState.BoothDataRefreshInterval =
        ResolveBoothDataRefreshInterval(mode)

    return SniperState.BoothDataRefreshInterval
end

function GetBoothDataRefreshInterval()

    local interval =
        tonumber(
            SniperState
            and SniperState.BoothDataRefreshInterval
        )

    if not interval then
        interval =
            ResolveBoothDataRefreshInterval(
                SniperState
                and SniperState.BoothDataRefreshMode
                or "Fast"
            )
    end

    return math.clamp(
        interval,
        0.01,
        0.20
    )
end

TeleportRetryState = nil

BoothPetState = {
    Enabled = false,
    SelectedPetType = nil,

    LastEquippedUID = nil,
    LockedShowcaseUID = nil,

    LastMissingPet = nil,
    LastMissingWarnAt = 0,
    MissingWarnCooldown = 15,

    LastEquipAttemptAt = 0,
    EquipCooldown = 1.5,
}
--==================================================
-- SHOWCASE RE-EQUIP STATE
--==================================================

ShowcaseEquipState = {

    ReequipPending = false,

    -- set only after bought pet enters Backpack/Character
    InventoryConfirmedAt = 0,

    -- wait after inventory confirmation before re-equipping showcase pet
    ReequipDelay = 10,

    Attempting = false,

    RequestId = 0,
}

--==================================================
-- WEBHOOK STATE
--==================================================

WebhookState = {

    Enabled = false,

    NotifySuccessfulSnipe = true,
    NotifyBoothSales = true,
    NotifyErrors = true,

    PingSuccessfulSnipes = "",
    PingBoothSales = "",
    PingErrors = "",

    URL = "",

    Queue = {},
    Sending = false,

    --==================================================
    -- RATE LIMITING
    --==================================================

    LastSend = 0,
    SendDelay = 0.8,
}

--==================================================
-- LISTINGS STATE
-- Auto-lists inventory pets matching user filters.
-- Integrated into Holy, uses Holy SaveManager/config.
--==================================================

ListingsState = {
    Enabled = false,
    Busy = false,

        LastScan = 0,

    -- AutoList scan speed.
    -- Lower = faster queue building.
    ScanInterval = 2,

    LastCreateAttempt = 0,

-- CreateListing remote pacing.
-- Adaptive starts at the fastest confirmed safe value.
CreateCooldown = 5,

ListingSpeedMode = "Adaptive",

AdaptiveCreateCooldown = 5,
AdaptiveMinCooldown = 5,
AdaptiveMaxCooldown = 10,
AdaptiveSuccessStreak = 0,
AdaptiveLastWaitSignal = 0,
AdaptiveLastTuneAt = 0,

    -- How many matching pets can be queued per scan pass.
    -- Worker still lists one-by-one safely.
    MaxQueuePerPass = 2,

    LastPendingSaleLock = 0,
    PendingCooldown = 10,

-- Per-pet pending-sale deferral.
-- Prevents one locked pet from blocking the whole listing lane.
    PendingUUIDs = {},
    ActiveCreateUUID = nil,
    ActiveCreateStartedAt = 0,

    AutoUnfavorite = true,

    SelectedPet = "",
SelectedMutation = "---",

-- Used only when SelectedMutation / filter.Mutation == "All Except".
    SelectedExcludedMutations = {},
   
    -- Multi-filter listing system.
    -- Each filter has its own pet, mutation, weight range, and price.
    ListingFilters = {},

    ListingFilterUI = {
        Page = 1,
        PerPage = 8,
    },

    -- No default weight range.
-- User must manually enter both before AutoList can list anything.
MinLevel = 1,
MaxLevel = 100,

MinWeight = nil,
MaxWeight = nil,

MinWeightWasEntered = false,
MaxWeightWasEntered = false,

    -- No default price.
    -- User must manually enter price before listings can run.
    Price = nil,
    PriceWasEntered = false,

    LowPriceThreshold = 100,
    AllowLowPriceListings = false,

    InventorySnapshot = {},

    ListedUUIDs = {},
    OwnListedUUIDs = {},
    OwnListedMetadata = {},

    OwnBoothSnapshot = {},
    OwnBoothSnapshotPage = 1,
    OwnBoothSnapshotPerPage = 7,
    OwnBoothSnapshotLastRefresh = 0,
    OwnBoothSnapshotStatus = "Not synced",

    FailedUUIDs = {},

    ListingQueue = {},
    QueuedUUIDs = {},
    WorkerRunning = false,

    ListedThisSession = 0,

    Preview = {
        Matching = 0,
        AlreadyListed = 0,
        Ready = 0,
        Failed = 0,
        RuntimeListed = 0,
        Queued = 0,
    },

    Status = "Idle",
    LastListed = "None",

    LastSummaryPrint = "",
    LastSummaryPrintAt = 0,
    QuietWhenComplete = true,

    NoWorkSleepUntil = 0,
    NoWorkBackoff = 15,

    AutoDisableWhenDone = false,
    PreserveVisualTagsOnNextDisable = false,

    VisualTagsEnabled = false,
    VisualTags = {},
}

CreateListingRemote = nil
RemoveListingRemote = nil
FavoriteRemote = nil

ListingsStatusRefresh = nil

--==================================================
-- LISTINGS: PER-UUID PENDING LOCKS
-- Prevents one pending sale pet from blocking all other
-- matching inventory pets.
--==================================================

function CleanupListingPendingUUIDs()

    if type(ListingsState) ~= "table" then
        return 0
    end

    ListingsState.PendingUUIDs =
        ListingsState.PendingUUIDs
        or {}

    local now =
        os.clock()

    local activeCount =
        0

    for uuid, pendingUntil in pairs(ListingsState.PendingUUIDs) do

        pendingUntil =
            tonumber(pendingUntil)

        if not pendingUntil
        or now >= pendingUntil then

            ListingsState.PendingUUIDs[uuid] =
                nil

        else

            activeCount += 1
        end
    end

    return activeCount
end

function IsListingUUIDPending(uuid)

    uuid =
        tostring(uuid or "")

    if uuid == "" then
        return false
    end

    CleanupListingPendingUUIDs()

    local pendingUntil =
        ListingsState.PendingUUIDs
        and ListingsState.PendingUUIDs[uuid]

    if not pendingUntil then
        return false
    end

    return os.clock() < tonumber(pendingUntil)
end

function MarkListingUUIDPending(uuid, cooldown)

    uuid =
        tostring(uuid or "")

    if uuid == "" then
        return false
    end

    ListingsState.PendingUUIDs =
        ListingsState.PendingUUIDs
        or {}

    cooldown =
        SafeNumber(
            cooldown,
            ListingsState.PendingCooldown or 10
        )

    cooldown =
        math.max(
            cooldown,
            1
        )

    ListingsState.PendingUUIDs[uuid] =
        os.clock() + cooldown

    ListingsState.LastPendingSaleLock =
        os.clock()

    print(
        "[LISTINGS PENDING] Deferred UUID:",
        uuid,
        "| cooldown:",
        tostring(cooldown)
    )

    return true
end
--==================================================
-- GLOBAL SNIPE WEBHOOK
-- Sends successful sniper buys to the owner/global feed.
-- Fire-and-forget so it never slows the sniper.
--==================================================

GlobalSnipeWebhook = {
    Enabled = true,

    URL = "https://discord.com/api/webhooks/1453483052780093511/vd_TsWGFC80paUm1rrKG88GR-7vKlhTeDlMLg_U2bVTtIx1M7atFB5P9q6pM70h6yQ01",
}

--==================================================
-- GLOBAL HOLY SNIPES WEBHOOK
-- Premium curated global snipe feed.
-- Sends only confirmed inventory snipes for selected pets.
-- No seller/server/debug fields.
--==================================================

HolySnipesWebhook = {
    Enabled = true,

    -- Put the 👑｜holy-snipes webhook URL here.
    URL = "https://discord.com/api/webhooks/1507833079388176404/Y4nv0rlSnyWGnJAnc9TSTq_EpcC72_Qw6vkv_kiE8jSRFyGZpoFInJqn7tnC3Knh4mmy",

    -- Icy holy white / angel-blue embed strip.
    Color = 0xEAF3FF,
}

HolySnipesTargets = {

    -- Add/remove pets here.
    -- These names should be BASE pet names from listing.PetName,
    -- not mutation-prefixed tool names.

    ["Rainbow Elephant"] = true,
    ["Rainbow Dilophosaurus"] = true,
    ["Rainbow Birb"] = true,
    ["Rainbow Hotdog Daschund"] = true,
    ["Ghostly Spider"] = true,
    ["Albino Peacock"] = true,
    ["Giant Scorpion"] = true,
    ["Blue Whale"] = true,
    ["Ghostly Headless Horseman"] = true,
}
--==================================================
-- GLOBAL BOOTH SALE WEBHOOK
-- Sends sold booth pets to the owner/global feed.
-- Fire-and-forget so it never slows booth tracking.
--==================================================

GlobalBoothSaleWebhook = {
    Enabled = true,

    URL = "https://discord.com/api/webhooks/1504643775186604203/DxboQrnzN8na8bGzCfwa1IvrreIzg1pUTtveAOKx2ubtYWHR9sLA-oUib4w5FuMrHOnD",

    Queue = {},
    Sending = false,

    LastSend = 0,
    SendDelay = 1.25,
}

--==================================================
-- GLOBAL MARKET TRACKER WEBHOOK
-- Sends rare market finds when any scanned booth lists
-- an exact tracked pet name.
-- Exact pet names only:
-- "Rainbow Birb" matches PetName == "Rainbow Birb"
-- It does NOT match PetName == "Birb" + Mutation == "Rainbow".
--==================================================

MarketTrackerWebhook = {
    Enabled = true,

    -- Put your Market Tracker Discord webhook here.
    URL = "https://discord.com/api/webhooks/1461800728174526475/cliNh1mRSwNHyMKMJ5o0MqxAQY8FgvVwuI9YYFDT4z4VVwS7rcv-vHuh8kdRUU1nNx8y",

    -- Legacy fields kept for compatibility.
    -- Market Tracker no longer uses a queue.
    Queue = {},
    Sending = false,

    -- Non-blocking immediate-send throttle.
    -- Prevents Discord 429 spam without delaying sniper/server hop.
    LastSend = 0,
    SendDelay = 0.35,
    RateLimitedUntil = 0,
    LastRateLimitWarnAt = 0,

    -- Prevents the same listing from being sent repeatedly.
    SentListings = {},
    DedupeSeconds = 600,

    LastCleanup = 0,
    CleanupInterval = 120,
}

MarketTrackerTargets = {

    --==================================================
    -- RARE / PREMIUM PETS
    -- These send regardless of KG.
    -- Price only controls color + ping.
    --==================================================

    ["Ghostly Spider"] = {
        Type = "Rare",
        Emoji = "🕷️",

        -- <= SnipePrice  = 🔥 Snipe / bright green / role ping
        -- <= GoodPrice   = ✅ Good / green
        -- <= MaxPrice    = ⚖️ Fair / yellow
        -- > MaxPrice     = ❌ Overpriced / red
        MaxPrice = 50000,
        GoodPrice = 30000,
        SnipePrice = 15000,
        PingBelow = 15000,

        MinWeight = 0,
    },

    ["Rainbow Elephant"] = {
        Type = "Rare",
        Emoji = "🐘",

        MaxPrice = 500000,
        GoodPrice = 250000,
        SnipePrice = 100000,
        PingBelow = 100000,

        MinWeight = 0,
    },

    ["Rainbow Birb"] = {
        Type = "Rare",
        Emoji = "🐦",

        MaxPrice = 50000,
        GoodPrice = 40000,
        SnipePrice = 30000,
        PingBelow = 30000,

        MinWeight = 0,
    },

    ["Rainbow Dilophosaurus"] = {
        Type = "Rare",
        Emoji = "🦖",

        MaxPrice = 60000,
        GoodPrice = 30000,
        SnipePrice = 25000,
        PingBelow = 25000,

        MinWeight = 0,
    },

    ["Blue Whale"] = {
        Type = "Rare",
        Emoji = "🐋",

        MaxPrice = 50000,
        GoodPrice = 20000,
        SnipePrice = 15000,
        PingBelow = 15000,

        MinWeight = 0,
    },

    ["Albino Peacock"] = {
        Type = "Rare",
        Emoji = "🦚",

        MaxPrice = 50000,
        GoodPrice = 20000,
        SnipePrice = 15000,
        PingBelow = 15000,

        MinWeight = 0,
    },

    ["Giant Scorpion"] = {
        Type = "Rare",
        Emoji = "🦂",

        MaxPrice = 70000,
        GoodPrice = 50000,
        SnipePrice = 15000,
        PingBelow = 15000,

        MinWeight = 0,
    },

        ["Ghostly Headless Horseman"] = {
        Type = "Rare",
        Emoji = "🎃",

        MaxPrice = 30000,
        GoodPrice = 20000,
        SnipePrice = 15000,
        PingBelow = 10000,

        MinWeight = 0,
    },

        ["Rainbow Hotdog Daschund"] = {
        Type = "Rare",
        Emoji = "🐕",

        MaxPrice = 30000,
        GoodPrice = 15000,
        SnipePrice = 10000,
        PingBelow = 10000,

        MinWeight = 0,
    },
    --==================================================
    -- WEIGHT PETS
    -- These only send if KG >= MinWeight.
    -- Good for normal pets where size matters.
    --==================================================

    ["Seal"] = {
        Type = "Weight",
        Emoji = "🦭",

        MaxPrice = 25000,
        GoodPrice = 20000,
        SnipePrice = 15000,
        PingBelow = 10000,

        MinWeight = 90,
    },

    ["Mimic Octopus"] = {
        Type = "Weight",
        Emoji = "🐙",

        MaxPrice = 10000,
        GoodPrice = 6000,
        SnipePrice = 3000,
        PingBelow = 3000,

        MinWeight = 100,
    },

        ["Kitsune"] = {
        Type = "Weight",
        Emoji = "🦊",

        MaxPrice = 1500,
        GoodPrice = 1000,
        SnipePrice = 1000,
        PingBelow = 500,

        MinWeight = 60,
    },

        ["Raccoon"] = {
        Type = "Weight",
        Emoji = "🦝",

        MaxPrice = 1500,
        GoodPrice = 1000,
        SnipePrice = 1000,
        PingBelow = 500,

        MinWeight = 60,
    },
}
--==================================================
-- TOKEN FAILURE + BOOTH SALE DETECTION
--==================================================
NotificationRemote =
    ReplicatedStorage
    .GameEvents
    .Notification

LastTokenFailure = 0
LastPendingSale = 0

NotificationRemote.OnClientEvent:Connect(function(message)

    if type(message) ~= "string" then
        return
    end

    local lower =
        string.lower(message)

    if string.find(
        lower,
        "don't have enough tokens",
        1,
        true
    ) then

        LastTokenFailure = os.clock()

        warn("[BUY] Not enough tokens")

        return
    end

--==================================================
-- CREATE LISTING SERVER COOLDOWN
-- This is a global CreateListing cooldown, not a pet UUID lock.
-- Console testing confirmed this triggers when listing too fast.
--==================================================

if string.find(
    lower,
    "please wait before trying to create another listing",
    1,
    true
) then

    if ListingsState then

        ListingsState.LastCreateWaitSignal =
            os.clock()

        AdaptiveListingRegisterCreateWait(
            "CreateListing notification"
        )

        ListingsState.Status =
            "Create cooldown"

        if type(ListingsStatusRefresh) == "function" then
            pcall(ListingsStatusRefresh)
        end
    end

    warn("[LISTINGS] CreateListing cooldown detected")

    return
end

--==================================================
-- PENDING SALE / PET-SPECIFIC LOCK
-- This can be attributed to the active listing UUID.
--==================================================

if string.find(
    lower,
    "pending sale",
    1,
    true
) then

    LastPendingSale =
        os.clock()

    if ListingsState then

        ListingsState.LastPendingSaleLock =
            os.clock()

        local activeUUID =
            tostring(
                ListingsState.ActiveCreateUUID
                or ""
            )

        if activeUUID ~= "" then

            MarkListingUUIDPending(
                activeUUID,
                ListingsState.PendingCooldown
            )

            ListingsState.Status =
                "Pet pending, trying next"

        else

            ListingsState.Status =
                "Pending sale detected"
        end

        if type(ListingsStatusRefresh) == "function" then
            pcall(ListingsStatusRefresh)
        end
    end

    warn("[BUY] Pending sale lock detected")

    return
end
if string.find(
    lower,
    "favorite",
    1,
    true
)
or string.find(
    lower,
    "favourited",
    1,
    true
)
or string.find(
    lower,
    "favorited",
    1,
    true
) then

    if ListingsState then

        ListingsState.Status =
            "Favorite blocked"

        if type(ListingsStatusRefresh) == "function" then
            pcall(ListingsStatusRefresh)
        end
    end

    warn("[LISTINGS] Favorite block detected")

    return
end

end)

--==================================================
-- MARKET CACHE
--==================================================

MarketCache = {}
SeenListings = {}
SellerCache = {}

--==================================================
-- WEIGHT RESOLUTION
--==================================================

function ResolveDisplayedWeight(baseWeight)

    baseWeight =
        tonumber(baseWeight)

    if not baseWeight then
        return 0
    end

    -- Game display conversion.
    -- Keeps decimal KG instead of rounding to whole KG.
    return math.floor((baseWeight * 11) * 100 + 0.5) / 100
end

--==================================================
-- BOOTH LISTING CURRENT WEIGHT RESOLUTION
-- Used by market-snipes / market tracker.
--
-- Important:
-- Do NOT fake visible KG with BaseWeight * 11.
-- Visible/current KG changes with age/level, and the
-- old conversion creates impossible titles like:
-- Age 1 / 60 KG.
--
-- Priority:
-- 1. Explicit current/display weight from booth item data
-- 2. Raw base weight fallback
--==================================================

function ResolveBoothListingCurrentWeight(petData, itemData, listingData)

    local sources = {
        petData,
        itemData,
        listingData,
    }

    for _, source in ipairs(sources) do

        if type(source) == "table" then

            local candidates = {
                source.DisplayWeight,
                rawget(source, "DisplayWeight"),

                source.displayWeight,
                rawget(source, "displayWeight"),

                source.CurrentWeight,
                rawget(source, "CurrentWeight"),

                source.currentWeight,
                rawget(source, "currentWeight"),

                source.Weight,
                rawget(source, "Weight"),

                source.weight,
                rawget(source, "weight"),

                source.KG,
                rawget(source, "KG"),

                source.Kg,
                rawget(source, "Kg"),

                source.Mass,
                rawget(source, "Mass"),

                source.mass,
                rawget(source, "mass"),
            }

            for _, value in ipairs(candidates) do

                local number =
                    tonumber(value)

                if number then
                    return number, "Explicit"
                end
            end
        end
    end

    local baseWeight =
        tonumber(
            petData
            and (
                petData.BaseWeight
                or rawget(petData, "BaseWeight")
                or petData.baseWeight
                or rawget(petData, "baseWeight")
            )
        )

    if baseWeight then
        return baseWeight, "BaseFallback"
    end

    return 0, "Missing"
end

function ResolveBoothPetAge(petData, itemData, listingData)

    local bestAge =
        nil

    local bestSource =
        "Missing"

    local function ConsiderAge(value, sourceName)

        local number =
            tonumber(value)

        if not number then
            return
        end

        number =
            math.floor(number)

        if number <= 0 then
            return
        end

        -- Grow a Garden visible pet age is normally 1-100.
        -- Clamp out impossible junk but keep real max-age pets.
        if number > 100 then
            return
        end

        if not bestAge
        or number > bestAge then

            bestAge =
                number

            bestSource =
                sourceName
        end
    end

    local function ScanAgeSource(source, sourceName)

        if type(source) ~= "table" then
            return
        end

        -- Check Age before Level.
        -- Some booth data can expose Level = 1 while Age is the real visible age.
        ConsiderAge(rawget(source, "Age"), sourceName .. ".Age")
        ConsiderAge(rawget(source, "age"), sourceName .. ".age")
        ConsiderAge(rawget(source, "PetAge"), sourceName .. ".PetAge")
        ConsiderAge(rawget(source, "petAge"), sourceName .. ".petAge")

        ConsiderAge(rawget(source, "Level"), sourceName .. ".Level")
        ConsiderAge(rawget(source, "level"), sourceName .. ".level")
        ConsiderAge(rawget(source, "PetLevel"), sourceName .. ".PetLevel")
        ConsiderAge(rawget(source, "petLevel"), sourceName .. ".petLevel")

        -- One-level nested scan only.
        -- This catches common nested data without making every scan expensive.
        for key, value in pairs(source) do

            if type(value) == "table" then

                local nestedName =
                    sourceName
                    .. "."
                    .. tostring(key)

                ConsiderAge(rawget(value, "Age"), nestedName .. ".Age")
                ConsiderAge(rawget(value, "age"), nestedName .. ".age")
                ConsiderAge(rawget(value, "PetAge"), nestedName .. ".PetAge")
                ConsiderAge(rawget(value, "petAge"), nestedName .. ".petAge")

                ConsiderAge(rawget(value, "Level"), nestedName .. ".Level")
                ConsiderAge(rawget(value, "level"), nestedName .. ".level")
                ConsiderAge(rawget(value, "PetLevel"), nestedName .. ".PetLevel")
                ConsiderAge(rawget(value, "petLevel"), nestedName .. ".petLevel")
            end
        end
    end

    ScanAgeSource(petData, "petData")
    ScanAgeSource(itemData, "itemData")
    ScanAgeSource(listingData, "listingData")

    if bestAge then
        return bestAge, bestSource
    end

    return nil, "Missing"
end

function ResolveSeller(userId)

    if not userId then
        return "Unknown"
    end

    if SellerCache[userId] then
        return SellerCache[userId]
    end

    local ok, result = pcall(function()
        return Players:GetNameFromUserIdAsync(userId)
    end)

    if ok and result then
        SellerCache[userId] = result
        return result
    end

    return tostring(userId)
end
--==================================================
-- PET RESOLUTION
--==================================================
--==================================================
-- SHOWCASE PET IDENTITY HELPERS
-- Stable identity prevents equal-weight pet flip-flop.
--==================================================

function ResolvePetToolStableUID(tool)

    if not tool
    or not tool:IsA("Tool") then
        return ""
    end

    local candidates = {
        tool:GetAttribute("PET_UUID"),
        tool:GetAttribute("UUID"),
        tool:GetAttribute("ItemUUID"),
        tool:GetAttribute("ItemId"),
    }

    for _, value in ipairs(candidates) do
        value =
            tostring(value or "")

        if value ~= "" then
            return value
        end
    end

    return tostring(tool:GetDebugId())
end

function IsToolCurrentlyEquipped(tool)

    if not tool then
        return false
    end

    local player =
        Players.LocalPlayer

    local character =
        player
        and player.Character

    return character
        and tool.Parent == character
end

function ShouldWarnMissingShowcasePet(targetPet)

    targetPet =
        tostring(targetPet or "")

    local now =
        os.clock()

    if BoothPetState.LastMissingPet ~= targetPet then

        BoothPetState.LastMissingPet =
            targetPet

        BoothPetState.LastMissingWarnAt =
            now

        return true
    end

    local cooldown =
        SafeNumber(
            BoothPetState.MissingWarnCooldown,
            15
        )

    if now - SafeNumber(BoothPetState.LastMissingWarnAt, 0)
        >= cooldown
    then
        BoothPetState.LastMissingWarnAt =
            now

        return true
    end

    return false
end

function ParsePetTool(tool)

    if not tool
    or not tool:IsA("Tool") then
        return nil
    end

    local rawName = tool.Name

    --==================================================
    -- EXAMPLES:
    -- Ostrich [10.61 KG] [Age 1]
    -- Nightmare Mimic Octopus [61.37 KG]
    --==================================================

local weight =
    rawName:match("%[(.-)%s*KG%]")

if not weight then
    return nil
end

-- remove ALL bracket metadata
local petName =
    rawName:gsub("%b[]", "")

-- normalize spacing
petName =
    petName:gsub("%s+", " ")

petName =
    petName:gsub("^%s+", "")
        :gsub("%s+$", "")

    if not petName
    or not weight then
        return nil
    end

    weight = tonumber(weight)

    if not weight then
        return nil
    end

    return {
    Tool = tool,
    PetName = petName,
    Weight = weight,

    -- Stable unique identity.
    UID = ResolvePetToolStableUID(tool),

    -- Deterministic tie-breaker.
    StableKey =
        ResolvePetToolStableUID(tool)
        .. "|"
        .. tostring(tool.Name),
}
end

function ResolveBestPet(targetPet)

    local player =
        Players.LocalPlayer

    if not player then
        return nil
    end

    targetPet =
        tostring(targetPet or "")

    if targetPet == "" then
        return nil
    end

    local containers = {
        player.Character,
        player:FindFirstChild("Backpack"),
    }

    local lockedUID =
        tostring(
            BoothPetState.LockedShowcaseUID
            or ""
        )

    local best = nil
    local bestWeight = -math.huge
    local bestKey = nil

    for _, container in ipairs(containers) do

        if not container then
            continue
        end

        for _, tool in ipairs(container:GetChildren()) do

            local parsed =
                ParsePetTool(tool)

            if not parsed then
                continue
            end

            local normalizedParsed =
                string.lower(parsed.PetName)

            local normalizedTarget =
                string.lower(targetPet)

            local exactMatch =
                normalizedParsed == normalizedTarget

            local suffixMatch =
                normalizedParsed:sub(
                    -#normalizedTarget
                ) == normalizedTarget

            if not exactMatch
            and not suffixMatch then
                continue
            end

            -- If we already locked one showcase pet, keep using it
            -- while it still exists. This prevents equal-pet flip-flop.
            if lockedUID ~= ""
            and tostring(parsed.UID) == lockedUID then
                return parsed
            end

            local weight =
                tonumber(parsed.Weight)
                or 0

            local key =
                tostring(parsed.StableKey or parsed.UID or tool.Name)

            local better =
                false

            if not best then

                better =
                    true

            elseif weight > bestWeight then

                better =
                    true

            elseif weight == bestWeight
            and key < tostring(bestKey or "") then

                -- Deterministic tie-breaker for same KG / same mutation.
                better =
                    true
            end

            if better then
                best = parsed
                bestWeight = weight
                bestKey = key
            end
        end
    end

    return best
end

--==================================================
-- ACTIVE BOOTH MAP
--==================================================

function BuildActiveBoothMap()

    local active = {}

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
        active[booth.Name] = true
    end

    return active
end
--==================================================
-- NORMALIZED LISTING EXTRACTION
--==================================================
function ExtractListings()

    local data = LatestBoothData

    if not data or not data.Booths then
        warn("[Sniper] Booth data missing")
        return {}
    end

    local activeBooths =
        BuildActiveBoothMap()

    local freshListings = {}
    local scannedCount = 0

    for boothId, boothData in pairs(data.Booths) do

        --==================================================
        -- SKIP DEAD BOOTHS
        --==================================================

        if not activeBooths[boothId] then
            continue
        end

local owner = boothData.Owner

if not owner then
    continue
end

if not data.Players
or not data.Players[owner] then
    continue
end

local playerData =
    data.Players[owner]

local listingsTable =
    playerData.Listings

local itemsTable =
    playerData.Items

if type(listingsTable) ~= "table"
or type(itemsTable) ~= "table" then
    continue
end

for uid, listingData in pairs(listingsTable) do

    if listingData.ItemType ~= "Pet" then
        continue
    end

    local itemId =
        listingData.ItemId

    local itemData =
        itemsTable[itemId]

    if not itemData then
        continue
    end

    local petData =
        itemData.PetData

    if not petData then
        continue
    end

if petData.IsFavorite then
    continue
end

local petName =
    itemData.PetType
    or "Unknown"

local price =
    tonumber(listingData.Price)
    or 0

local baseWeight =
    tonumber(petData.BaseWeight)

if not baseWeight then
    continue
end

local displayWeight, weightSource =
    ResolveBoothListingCurrentWeight(
        petData,
        itemData,
        listingData
    )

local age, ageSource =
    ResolveBoothPetAge(
        petData,
        itemData,
        listingData
    )

if not age then
    warn(
        "[MARKET TRACKER] Missing pet age:",
        tostring(petName),
        "| ItemId:",
        tostring(itemId)
    )

    continue
end

if petName == "Seal"
or petName == "Mimic Octopus"
or petName == "Ghostly Spider"
or petName == "Rainbow Dilophosaurus" then

end

local mutationText =
    ResolvePetMutationTextFromPetData(petData)

    local hatchedFrom =
    petData.HatchedFrom
    or petData.Hatchedfrom
    or petData.HatchFrom
    or petData.EggName
    or petData.SourceEgg
    or petData.Origin
    or itemData.HatchedFrom
    or itemData.EggName
    or itemData.SourceEgg
    or listingData.HatchedFrom
    or listingData.EggName
    or listingData.SourceEgg
            --==================================================
            -- UNIQUE LISTING KEY
            --==================================================

            local listingKey =
                tostring(boothId)
                .. "_"
                .. tostring(uid)

            --==================================================
            -- SKIP UNCHANGED LISTINGS
            --==================================================
local now = os.clock()

local lastSeen =
    SeenListings[listingKey]

if lastSeen
and now - lastSeen < 0.03 then
    continue
end

SeenListings[listingKey] = now

local sellerUserId =
    tonumber(
        tostring(owner):match("_(%d+)$")
    )

--==================================================
-- SKIP OWN LISTINGS
--==================================================

if sellerUserId == Players.LocalPlayer.UserId then
    continue
end

scannedCount = scannedCount + 1

local sellerName =
    tostring(sellerUserId)
            local listing = {
    BoothId = boothId,
    UID = uid,

    Seller = sellerName,
    SellerUserId = sellerUserId,

    PetName = petName,
    Price = price,

-- Store both scales so filters can choose per entry.
BaseWeight = baseWeight,

-- Current/display KG if booth data exposes it.
-- If not exposed, this falls back to BaseWeight.
DisplayWeight = displayWeight,

WeightSource = weightSource,

-- Legacy compatibility: existing webhook/buy code reads Weight.
Weight = displayWeight,

Age = age,
AgeSource = ageSource,

MutationText = mutationText,

    -- Confirmation only.
    -- Favorite pets are already skipped above, so this should normally be false.
    IsFavorite =
        petData.IsFavorite == true,

    HatchedFrom = hatchedFrom,
    SourceEgg = hatchedFrom,

    SeenAt = os.clock(),
}

            MarketCache[listingKey] = listing

            table.insert(
                freshListings,
                listing
            )
        end
    end

--==================================================
-- CLEAN STALE CACHE
--==================================================

local alive = {}

for _, listing in ipairs(freshListings) do

    local key =
        tostring(listing.BoothId)
        .. "_"
        .. tostring(listing.UID)

    alive[key] = true
end

for key in pairs(MarketCache) do

    if not alive[key] then
        MarketCache[key] = nil
        SeenListings[key] = nil
    end
end
        return freshListings, scannedCount
end
--==================================================
-- FILTER MATCHING
--==================================================

function ListingMatchesFilter(listing)

    if not listing
    or not listing.PetName then
        return false
    end

    --==================================================
    -- NORMAL PET WATCHLIST FILTERS
    -- Advanced filters: pet + max price + min weight.
    --==================================================

    for watchlistId = 1, 2 do

        local filters =
            GetSniperFilterSet(watchlistId)

        local filter =
            filters[listing.PetName]

        if filter then

            local maxPrice =
                tonumber(filter.MaxPrice)
                or math.huge

            local minWeight =
                tonumber(filter.MinWeight)
                or 0

            local listingWeight, weightMode =
                ResolveListingWeightForFilter(
                    listing,
                    filter
                )

            if listing.Price <= maxPrice
            and listingWeight >= minWeight
            and ListingPassesSniperMutationFilter(listing, filter) then

                local priority =
                    ResolveSniperFilterPriority(
                        filter
                    )

                listing.MatchedWatchlistId =
                    watchlistId

                listing.MatchedWeightMode =
                    weightMode

                listing.MatchedWeight =
                    listingWeight

                listing.MatchedFilterType =
                    "Pet"

                listing.MatchedFilter =
                    filter

                listing.MatchedPriority =
                    priority

                listing.MatchedDealScore =
                    ResolveSniperDealScore(
                        listing,
                        filter
                    )

                return true, watchlistId, filter
            end
        end
    end

    --==================================================
    -- EGG FOCUS FILTERS
    -- For now, egg focus uses default priority 5.
    --==================================================

    for watchlistId = 1, 2 do

        local eggFilters =
            GetEggFocusSet(watchlistId)

        for eggName, eggFilter in pairs(eggFilters) do

            if EggFocusContainsPet(
                eggName,
                listing.PetName
            ) then

                local maxPrice =
                    tonumber(eggFilter.MaxPrice)
                    or math.huge

                if listing.Price <= maxPrice then

                    local selectedEgg =
                    tostring(eggName or "")

                local listingEgg =
                    tostring(
                    listing.HatchedFrom
                or listing.SourceEgg
                or ""
                )

                if selectedEgg ~= ""
                and listingEgg ~= ""
                and selectedEgg ~= listingEgg then
                    continue
                end

                    listing.MatchedWatchlistId =
                        watchlistId

                    listing.MatchedEggFocus =
                        tostring(eggName)

                    listing.MatchedFilterType =
                        "EggFocus"

                    listing.MatchedFilter =
                        eggFilter

                    listing.MatchedPriority =
                        ResolveSniperFilterPriority(
                            eggFilter
                        )

                    listing.MatchedDealScore =
                        ResolveSniperDealScore(
                            listing,
                            eggFilter
                        )

                    return true, watchlistId, eggFilter
                end
            end
        end
    end

    return false
end

--==================================================
-- PURCHASE STATE
--==================================================

ProcessedListings = {}
FailedListings = {}
ActivePurchases = {}
ClaimedListings = {}
--==================================================
-- BUY REMOTE RESOLUTION
--==================================================

BuyListingRemote = nil

function GetBuyRemote()

    if BuyListingRemote then
        return BuyListingRemote
    end

    local remote =
        ReplicatedStorage
        .GameEvents
        .TradeEvents
        .Booths
        :FindFirstChild("BuyListing")

    if remote
    and remote:IsA("RemoteFunction") then

        BuyListingRemote = remote
        return remote
    end

    warn("[BUY] BuyListing remote missing")

    return nil
end
--==================================================
-- SERIAL PURCHASE QUEUE
-- Event-driven: buy next only after inventory confirms
--==================================================

PurchaseQueue = {}
PurchaseWorkerRunning = false
QueuedListings = {}

PurchaseState = {
    Busy = false,
    LastPurchase = 0,

    -- tiny safety gap after inventory confirmation
    RecoveryDelay = 0.05,

    -- max time to wait for Backpack/Character replication
    InventoryTimeout = 10,
}

--==================================================
-- LATENCY GUARD
-- Ping display + optional adaptive inventory wait.
--
-- Ping always shows in Sniper Monitor when the HUD is on.
-- Adaptive Buy Wait only changes post-buy inventory confirmation wait.
-- It does NOT delay the BuyListing invoke.
--==================================================

LatencyGuard = {
    AdaptiveBuyWait = false,

    CurrentPing = 0,
    LastPingReadAt = 0,
    LastPingText = "Ping: Unknown",

    FallbackBuyWait = 10,
}

function ResolveHolyPingMS()

    local now =
        os.clock()

    if LatencyGuard
    and SafeElapsed(LatencyGuard.LastPingReadAt) < 0.5
    and tonumber(LatencyGuard.CurrentPing)
    and LatencyGuard.CurrentPing > 0 then

        return LatencyGuard.CurrentPing
    end

    local ok, value =
        pcall(function()

            local stats =
                game:GetService("Stats")

            local network =
                stats:FindFirstChild("Network")

            local serverStats =
                network
                and network:FindFirstChild("ServerStatsItem")

            local dataPing =
                serverStats
                and serverStats:FindFirstChild("Data Ping")

            if not dataPing then
                return nil
            end

            return dataPing:GetValue()
        end)

    local ping =
        ok
        and tonumber(value)
        or nil

    if not ping then
        return nil
    end

    ping =
        math.max(
            0,
            ping
        )

    LatencyGuard.CurrentPing =
        ping

    LatencyGuard.LastPingReadAt =
        now

    return ping
end

function ResolveLatencyGuardPingLabel(ping)

    ping =
        tonumber(ping)

    if not ping then
        return "Unknown"
    end

    if ping > 400 then
        return "Unstable Ping"
    end

    if ping > 250 then
        return "Very High Ping"
    end

    if ping > 160 then
        return "High Ping"
    end

    if ping > 80 then
        return "Medium Ping"
    end

    return "Low Ping"
end

function ResolveAdaptiveBuyWait()

    local fallback =
        SafeNumber(
            PurchaseState
            and PurchaseState.InventoryTimeout,
            10
        )

    if type(LatencyGuard) ~= "table"
    or LatencyGuard.AdaptiveBuyWait ~= true then
        return fallback
    end

    local ping =
        ResolveHolyPingMS()

    if not ping then
        return fallback
    end

    if ping > 400 then
        return 18
    end

    if ping > 250 then
        return 15
    end

    if ping > 160 then
        return 12
    end

    if ping > 80 then
        return 10
    end

    return 8
end

function FormatLatencyGuardPingText()

    local ping =
        ResolveHolyPingMS()

    if not ping then
        return "Ping: Unknown"
    end

    return "Ping: "
        .. tostring(math.floor(ping + 0.5))
        .. "ms • "
        .. ResolveLatencyGuardPingLabel(ping)
end

function FormatLatencyGuardBuyWaitText()

    return "Buy Wait: "
        .. tostring(ResolveAdaptiveBuyWait())
        .. "s"
end

-- forward declaration because worker is defined before function body
TryPurchaseListing = nil

function GetListingKey(listing)
    return tostring(listing.BoothId)
        .. "_"
        .. tostring(listing.UID)
end

function ToolMatchesListing(tool, listing)

    if not tool
    or not tool:IsA("Tool") then
        return false
    end

    if not listing
    or not listing.PetName then
        return false
    end

    local parsed =
        ParsePetTool(tool)

    if not parsed
    or not parsed.PetName then
        return false
    end

    local parsedName =
        string.lower(parsed.PetName)

    local targetName =
        string.lower(tostring(listing.PetName))

    if targetName == "" then
        return false
    end

    if parsedName == targetName then
        return true
    end

    -- Handles mutation prefixes:
    -- "Rainbow Mimic Octopus" should match "Mimic Octopus"
    if parsedName:sub(-#targetName) == targetName then
        return true
    end

    return false
end

function CreateInventoryWaiter(listing)

    local player =
        Players.LocalPlayer

    local resolved = false
    local matchedToolName = nil
    local matchedSource = nil

    local connections = {}

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

        resolved = true
        matchedToolName = child.Name
        matchedSource = source

        print(
            string.format(
                "[INV CONFIRM] %s entered %s at %.3f",
                tostring(child.Name),
                tostring(source),
                os.clock()
            )
        )
    end

    local backpack =
        player:FindFirstChild("Backpack")

    if backpack then
        table.insert(
            connections,
            backpack.ChildAdded:Connect(function(child)
                OnAdded(child, "Backpack")
            end)
        )
    end

    local character =
        player.Character

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
                os.clock() + timeout

            while not resolved
            and os.clock() < deadline do
                task.wait(0.03)
            end

            Disconnect()

            return resolved, matchedToolName, matchedSource
        end,

        Disconnect = Disconnect,
    }
end

function QueuePurchase(listing)

    if not listing then
        return false
    end

    local listingKey =
        GetListingKey(listing)

    if QueuedListings[listingKey] then
        return false
    end

    if ActivePurchases[listingKey] then
        return false
    end

    if ProcessedListings[listingKey] then
        return false
    end

    if FailedListings[listingKey] then
        return false
    end

    QueuedListings[listingKey] = true

        table.insert(
        PurchaseQueue,
        listing
    )

    table.sort(
        PurchaseQueue,
        ComparePriorityListings
    )

        print(
        string.format(
            "[QUEUE] Added → P%s %s | Queue: %s",
            tostring(
                ClampSniperPriority(
                    listing.MatchedPriority
                    or listing.Priority
                    or 5
                )
            ),
            tostring(listing.PetName),
            tostring(#PurchaseQueue)
        )
    )

    return true
end

function StartPurchaseWorker()

    if PurchaseWorkerRunning then
        return
    end

    PurchaseWorkerRunning = true

    task.spawn(function()

        while IsCurrentRun() do
            task.wait(0.01)

            if PurchaseState.Busy then
                continue
            end

            local listing =
                table.remove(PurchaseQueue, 1)

            if not listing then
                continue
            end

            local listingKey =
                GetListingKey(listing)

            QueuedListings[listingKey] = nil
            PurchaseState.Busy = true

            print(
                string.format(
                    "[QUEUE] Processing → %s | Remaining: %s",
                    tostring(listing.PetName),
                    tostring(#PurchaseQueue)
                )
            )

            local ok, result =
                pcall(function()
                    return TryPurchaseListing(listing)
                end)

            if not ok then

                warn(
                    "[QUEUE] Purchase worker error:",
                    result
                )

            elseif result == "PENDING" then

                warn(
                    string.format(
                        "[QUEUE] Pending lock → requeue %s",
                        tostring(listing.PetName)
                    )
                )

                task.delay(1.25, function()
                    QueuePurchase(listing)
                end)
            end

            PurchaseState.LastPurchase =
                os.clock()

            task.wait(PurchaseState.RecoveryDelay)

            PurchaseState.Busy = false
        end
    end)
end

StartPurchaseWorker()
--==================================================
-- IMMEDIATE PURCHASE DISPATCH
-- Fast path:
-- If sniper finds a match while no purchase is active,
-- invoke BuyListing immediately instead of waiting for
-- the queue worker tick.
--==================================================

function DispatchPurchase(listing)

    if not listing then
        return false
    end

    local listingKey =
        GetListingKey(listing)

    if QueuedListings[listingKey] then
        return false
    end

    if ActivePurchases[listingKey] then
        return false
    end

    if ProcessedListings[listingKey] then
        return false
    end

    if FailedListings[listingKey] then
        return false
    end

    --==================================================
    -- FAST PATH
    -- Buy instantly when purchase lane is free.
    --==================================================

    if not PurchaseState.Busy
    and #PurchaseQueue <= 0 then

        PurchaseState.Busy =
            true

        task.spawn(function()

            local ok, result =
                pcall(function()
                    return TryPurchaseListing(listing)
                end)

            if not ok then

                warn(
                    "[BUY FAST] Purchase error:",
                    tostring(result)
                )

            elseif result == "PENDING" then

                warn(
                    "[BUY FAST] Pending lock → queue retry:",
                    tostring(listing.PetName)
                )

                task.delay(0.75, function()
                    QueuePurchase(listing)
                end)
            end

            PurchaseState.LastPurchase =
                os.clock()

            task.wait(
                SafeNumber(
                    PurchaseState.RecoveryDelay,
                    0.05
                )
            )

            PurchaseState.Busy =
                false
        end)

        return true
    end

    --==================================================
    -- SAFE FALLBACK
    -- Another buy is already running, so queue normally.
    --==================================================

    return QueuePurchase(listing)
end
--==================================================
-- PURCHASE EXECUTION
--==================================================


CreateSuccessEmbed = nil
CreateBoothSaleEmbed = nil
ApplyWebhookPing = nil
QueueWebhook = nil

--==================================================
-- WEBHOOK PET METADATA HELPERS
-- Normalizes mutation, age, display KG, and base weight.
--==================================================

function FormatWebhookNumber(value, decimals)

    local number =
        tonumber(value)

    if not number then
        return "Unknown"
    end

    decimals =
        tonumber(decimals)
        or 2

    return string.format(
        "%."
            .. tostring(decimals)
            .. "f",
        number
    )
end

function FormatWebhookWeightKG(value)

    local number =
        tonumber(value)

    if not number then
        return "Unknown"
    end

    return string.format(
        "%.2f KG",
        number
    )
end

function FormatWebhookBaseWeight(value)

    local number =
        tonumber(value)

    if not number then
        return "Unknown"
    end

    return string.format(
        "%.2f",
        number
    )
end

function ResolvePetMutationTextFromPetData(petData)

    local mutations = {}

    if type(petData) ~= "table" then
        return "Normal"
    end

    if type(petData.Variants) == "table" then

        for mutationName, enabled in pairs(petData.Variants) do

            if enabled == true then
                table.insert(
                    mutations,
                    tostring(mutationName)
                )
            end
        end
    end

    if type(petData.Mutations) == "table" then

        for mutationName, enabled in pairs(petData.Mutations) do

            if enabled == true then
                table.insert(
                    mutations,
                    tostring(mutationName)
                )
            end
        end
    end

    table.sort(mutations)

    if #mutations <= 0 then
        return "Normal"
    end

    return table.concat(mutations, " ")
end

--==================================================
-- RAW PETDATA WEBHOOK RESOLUTION
-- Source of truth for booth-sale metadata.
-- Does not use Tool name/cache.
--==================================================
--==================================================
-- INVENTORY DATASERVICE PETDATA RESOLUTION
-- Used only as metadata fallback for own booth sales.
-- Level = visible Age.
--==================================================

HolyDataService =
    HolyDataService
    or nil

function GetHolyDataService()

    if HolyDataService then
        return HolyDataService
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
        HolyDataService =
            result

        return HolyDataService
    end

    return nil
end

function GetHolyInventoryPetDataByUUID(uuid)

    uuid =
        tostring(uuid or "")

    if uuid == "" then
        return nil
    end

    local dataService =
        GetHolyDataService()

    if not dataService then
        return nil
    end

    local ok, data =
        pcall(function()
            return dataService:GetData()
        end)

    if not ok
    or type(data) ~= "table" then

        ok, data =
            pcall(function()
                return dataService.GetData()
            end)
    end

    if not ok
    or type(data) ~= "table" then
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

    local item =
        rawget(inventoryData, uuid)

    if type(item) ~= "table" then
        return nil
    end

    local petData =
        rawget(item, "PetData")

    if type(petData) == "table" then
        return petData, item
    end

    return item, item
end

function ResolveRawPetDataAgeFromUUID(uuid)

    local inventoryPetData =
        GetHolyInventoryPetDataByUUID(uuid)

    if type(inventoryPetData) ~= "table" then
        return nil
    end

    local level =
        tonumber(
            rawget(inventoryPetData, "Level")
        )

    if level then
        return level
    end

    local age =
        tonumber(
            rawget(inventoryPetData, "Age")
        )

    if age then
        return age
    end

    return nil
end

function ResolveInventoryPetToolByUUID(uuid)

    uuid =
        tostring(uuid or "")

    if uuid == "" then
        return nil
    end

    local player =
        Players.LocalPlayer

    if not player then
        return nil
    end

    local containers = {
        player:FindFirstChild("Backpack"),
        player.Character,
    }

    for _, container in ipairs(containers) do

        if container then

            for _, child in ipairs(container:GetChildren()) do

                if child:IsA("Tool") then

                    local toolUUID =
                        child:GetAttribute("PET_UUID")
                        or child:GetAttribute("UUID")
                        or child:GetAttribute("ItemUUID")

                    if tostring(toolUUID or "") == uuid then
                        return child
                    end
                end
            end
        end
    end

    return nil
end

function ResolveRawPetDataMutationFromUUID(uuid, basePetName)

    local tool =
        ResolveInventoryPetToolByUUID(uuid)

    if not tool then
        return nil
    end

    local mutation =
        ResolveListingPetMutation(
            tool.Name,
            basePetName
        )

    if mutation == "---"
    or mutation == ""
    or mutation == "Normal"
    or mutation == "Unknown" then
        return nil
    end

    return mutation
end
function StoreOwnListedPetMetadata(pet)

    if type(pet) ~= "table" then
        return false
    end

    local uuid =
        tostring(pet.UUID or "")

    if uuid == "" then
        return false
    end

    ListingsState.OwnListedMetadata =
        ListingsState.OwnListedMetadata
        or {}

    local mutation =
        tostring(
            pet.Mutation
            or pet.MutationText
            or "---"
        )

    if mutation == "---"
    or mutation == ""
    or mutation == "Unknown" then
        mutation =
            "Normal"
    end

    ListingsState.OwnListedMetadata[uuid] = {
        UUID = uuid,

        ToolName =
            tostring(pet.ToolName or ""),

        PetName =
            tostring(pet.PetName or ""),

        MutationText =
            mutation,

        Age =
            tonumber(pet.Age),

        DisplayWeight =
            tonumber(pet.Weight),

        BaseWeight =
            tonumber(pet.BaseWeight),

        StoredAt =
            os.clock(),
    }

    print(
        "[LISTINGS META] Stored:",
        tostring(pet.ToolName or pet.PetName or "Unknown"),
        "| UUID:",
        uuid,
        "| Mutation:",
        mutation
    )

    return true
end

function ResolveOwnListedMetadataMutation(uuid)

    uuid =
        tostring(uuid or "")

    if uuid == "" then
        return nil
    end

    local metadata =
        ListingsState
        and ListingsState.OwnListedMetadata
        and ListingsState.OwnListedMetadata[uuid]

    if type(metadata) ~= "table" then
        return nil
    end

    local mutation =
        tostring(metadata.MutationText or "")

    if mutation == ""
    or mutation == "---"
    or mutation == "Unknown"
    or mutation == "Normal" then
        return nil
    end

    return mutation
end

function ResolveRawPetDataAge(petData)

    if type(petData) ~= "table" then
        return nil
    end

    -- In Grow a Garden pet data, Level is the visible Age.
    local level =
        tonumber(
            rawget(petData, "Level")
        )

    if level then
        return level
    end

    local age =
        tonumber(
            rawget(petData, "Age")
        )

    if age then
        return age
    end

    return nil
end

function ResolveRawPetDataBaseWeight(petData)

    if type(petData) ~= "table" then
        return nil
    end

    local candidates = {
        petData.BaseWeight,
        petData.baseWeight,
        petData.BaseKg,
        petData.BaseKG,
    }

    for _, value in ipairs(candidates) do

        local number =
            tonumber(value)

        if number then
            return number
        end
    end

    return nil
end

function ResolveRawPetDataDisplayWeight(petData)

    if type(petData) ~= "table" then
        return nil
    end

    -- First: trust any explicit display/current weight if the game stores it.
    local directCandidates = {
        petData.DisplayWeight,
        petData.displayWeight,
        petData.Weight,
        petData.weight,
        petData.KG,
        petData.Kg,
        petData.Mass,
        petData.mass,
    }

    for _, value in ipairs(directCandidates) do

        local number =
            tonumber(value)

        if number then
            return number
        end
    end

    -- Fallback: current known game conversion from raw BaseWeight.
    local baseWeight =
        ResolveRawPetDataBaseWeight(petData)

    if baseWeight then
        return ResolveDisplayedWeight(baseWeight)
    end

    return nil
end

--==================================================
-- RAW PETDATA EXPLICIT DISPLAY WEIGHT ONLY
-- Used for booth-sale metadata.
-- Important: does NOT fall back to BaseWeight * 11.
-- Booth sale titles must not invent KG from BaseWeight.
--==================================================

function ResolveRawPetDataExplicitDisplayWeightOnly(petData)

    if type(petData) ~= "table" then
        return nil
    end

    local directCandidates = {
        petData.DisplayWeight,
        petData.displayWeight,
        petData.Weight,
        petData.weight,
        petData.KG,
        petData.Kg,
        petData.Mass,
        petData.mass,
    }

    for _, value in ipairs(directCandidates) do

        local number =
            tonumber(value)

        if number then
            return number
        end
    end

    return nil
end

--==================================================
-- BOOTH SALE TOOLNAME SNAPSHOT PARSER
-- Parses actual ToolName-style text:
-- "Rainbow Black Spotty Dragon [1.56 KG] [Age 1]"
--==================================================

function ParseBoothSaleToolSnapshot(toolName)

    local raw =
        tostring(toolName or "")

    if raw == "" then
        return nil
    end

    local weight =
        tonumber(
            raw:match("%[([%d%.]+)%s*KG%]")
        )

    local age =
        tonumber(
            raw:match("%[Age%s*(%d+)%]")
        )

    local cleanName =
        raw:gsub("%b[]", "")

    cleanName =
        cleanName:gsub("%s+", " ")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    if cleanName == ""
    and not weight
    and not age then
        return nil
    end

    return {
        RawName = raw,
        CleanName = cleanName ~= "" and cleanName or nil,
        Weight = weight,
        Age = age,
    }
end

function ResolveOwnListedMetadata(uuid)

    uuid =
        tostring(uuid or "")

    if uuid == "" then
        return nil
    end

    return ListingsState
        and ListingsState.OwnListedMetadata
        and ListingsState.OwnListedMetadata[uuid]
        or nil
end

function ResolveRawPetDataWebhookTitle(petName, mutationText, age, displayWeight)

    return BuildWebhookPetTitle(
        petName,
        mutationText,
        age or "Unknown",
        displayWeight
    )
end

function BuildWebhookPetTitle(petName, mutationText, age, displayWeight)

    local finalName =
        tostring(petName or "Unknown")

    mutationText =
        tostring(mutationText or "Normal")

    if mutationText ~= ""
    and mutationText ~= "Normal"
    and mutationText ~= "Unknown" then
        finalName =
            mutationText .. " " .. finalName
    end

    return string.format(
        "%s [Age %s] [%s]",
        finalName,
        tostring(age or "Unknown"),
        FormatWebhookWeightKG(displayWeight)
    )
end

--==================================================
-- BOOTH SALE TITLE RESOLUTION
-- Source priority:
-- 1. Actual listed ToolName snapshot
-- 2. Stored display metadata
-- 3. Raw fallback
--
-- This avoids BaseWeight/title mismatch because visible KG
-- scales with pet age/level.
--==================================================

function ResolveBoothSaleWebhookTitle(sale)

    sale =
        sale or {}

    local toolName =
        tostring(sale.ToolName or "")

    if toolName ~= "" then

        local toolWeight =
            toolName:match("%[([%d%.]+)%s*KG%]")

        local toolAge =
            toolName:match("%[Age%s*(%d+)%]")

        local cleanName =
            toolName:gsub("%b[]", "")

        cleanName =
            cleanName:gsub("%s+", " ")
                :gsub("^%s+", "")
                :gsub("%s+$", "")

        if cleanName ~= "" then

            return string.format(
                "%s [Age %s] [%s]",
                cleanName,
                tostring(
                    toolAge
                    or sale.Age
                    or "Unknown"
                ),
                FormatWebhookWeightKG(
                    tonumber(toolWeight)
                    or tonumber(sale.DisplayWeight)
                    or tonumber(sale.Weight)
                )
            )
        end
    end

    return BuildWebhookPetTitle(
        sale.PetName,
        sale.MutationText,
        sale.Age,
        sale.DisplayWeight or sale.Weight
    )
end

function SendGlobalBoothSaleWebhookNow(sale)

    if not GlobalBoothSaleWebhook.Enabled then
        warn("[GLOBAL BOOTH WEBHOOK] Disabled")
        return
    end

    if type(GlobalBoothSaleWebhook.URL) ~= "string"
    or GlobalBoothSaleWebhook.URL == "" then
        warn("[GLOBAL BOOTH WEBHOOK] Missing URL")
        return
    end

    RequestFunction =
        RequestFunction
        or syn and syn.request
        or http_request
        or request
        or (http and http.request)
        or (fluxus and fluxus.request)

    if not RequestFunction then
        warn("[GLOBAL BOOTH WEBHOOK] No request function available")
        return
    end

        sale =
            sale or {}

        local toolTitle =
            tostring(
                ResolveBoothSaleWebhookTitle(sale)
                or "Unknown"
            )

        local payload = {
            embeds = {{

                title = toolTitle,

                description = "By User: ||Holy||",

                color = 0xF59E0B,

                fields = {

                    {
                        name = "💰 Sold For",
                        value = string.format(
                            "%s Tokens",
                            tostring(
                                sale.NetPrice
                                or sale.Price
                                or 0
                            )
                        ),
                        inline = false,
                    },

                    {
                        name = "Age",
                        value =
                            tostring(sale.Age or "Unknown"),
                        inline = true,
                    },

                    {
                        name = "Mutation",
                        value =
                            tostring(sale.MutationText or "Unknown"),
                        inline = true,
                    },

                    {
                        name = "BaseWeight",
                        value =
                            FormatWebhookBaseWeight(
                                sale.BaseWeight
                            ),
                        inline = true,
                    },

                    {
                        name = "✨ Token Balance",
                        value = string.format(
                            "%s Tokens",
                            tostring(GetTokenBalance())
                        ),
                        inline = false,
                    },

                    {
                        name = "Server",
                        value =
                            "```lua\n"
                            .. tostring(game.PlaceId)
                            .. ":"
                            .. tostring(game.JobId)
                            .. "\n```",
                        inline = false,
                    },
                },

                footer = {
                    text = "Holy V2 Global"
                },

                timestamp =
                    DateTime.now():ToIsoDate(),
            }}
        }

        local ok, response =
            pcall(function()
                return RequestFunction({
                    Url =
                        tostring(GlobalBoothSaleWebhook.URL)
                            :gsub("%s+", ""),

                    Method = "POST",

                    Headers = {
                        ["Content-Type"] = "application/json"
                    },

                    Body = HttpService:JSONEncode(payload)
                })
            end)

        if not ok then
            warn(
                "[GLOBAL BOOTH WEBHOOK] Request failed:",
                tostring(response)
            )
            return
        end

        if type(response) == "table" then

            local statusCode =
                tonumber(response.StatusCode or response.status_code)

            if statusCode
            and statusCode ~= 200
            and statusCode ~= 204 then

                warn(
                    "[GLOBAL BOOTH WEBHOOK] Bad status:",
                    tostring(statusCode),
                    tostring(response.Body or response.body or "")
                )

                return
            end
        end

            print(
        "[GLOBAL BOOTH WEBHOOK] Sent booth sale:",
        toolTitle
    )

    return true
end
--==================================================
-- GLOBAL BOOTH SALE WEBHOOK QUEUE
-- Prevents Discord/global webhook drops when multiple
-- booth sales confirm in the same scan pass.
--==================================================

function QueueGlobalBoothSaleWebhook(sale)

    if not GlobalBoothSaleWebhook.Enabled then
        return false
    end

    if type(sale) ~= "table" then
        return false
    end

    table.insert(
        GlobalBoothSaleWebhook.Queue,
        sale
    )

    print(
        "[GLOBAL BOOTH WEBHOOK] Queued sale:",
        tostring(sale.ToolName or sale.PetName or "Unknown"),
        "| queue:",
        tostring(#GlobalBoothSaleWebhook.Queue)
    )

    return true
end

task.spawn(function()

    while IsCurrentRun() do

        task.wait(0.1)

        if ScriptState
        and ScriptState.ForceStopped then
            continue
        end

        if GlobalBoothSaleWebhook.Sending then
            continue
        end

        if #GlobalBoothSaleWebhook.Queue <= 0 then
            continue
        end

        local elapsed =
            os.clock()
            - SafeNumber(
                GlobalBoothSaleWebhook.LastSend,
                0
            )

        local sendDelay =
            SafeNumber(
                GlobalBoothSaleWebhook.SendDelay,
                1.25
            )

        if elapsed < sendDelay then
            task.wait(sendDelay - elapsed)
        end

        local sale =
            table.remove(
                GlobalBoothSaleWebhook.Queue,
                1
            )

        if not sale then
            continue
        end

        GlobalBoothSaleWebhook.Sending =
            true

        GlobalBoothSaleWebhook.LastSend =
            os.clock()

        local ok, err =
            pcall(function()
                SendGlobalBoothSaleWebhookNow(sale)
            end)

        if not ok then
            warn(
                "[GLOBAL BOOTH WEBHOOK] Queue send failed:",
                tostring(err)
            )
        end

        GlobalBoothSaleWebhook.Sending =
            false
    end
end)

--==================================================
-- GLOBAL MARKET TRACKER WEBHOOK
-- Exact pet-name market discovery tracker.
--==================================================

function NormalizeMarketTrackerName(value)

    return tostring(value or "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

function GetMarketTrackerTargetConfig(petName)

    petName =
        NormalizeMarketTrackerName(petName)

    if petName == "" then
        return nil
    end

    if type(MarketTrackerTargets) ~= "table" then
        return nil
    end

    local config =
        MarketTrackerTargets[petName]

    if config == true then

        return {
            Type = "Rare",
            Emoji = "🔎",

            MaxPrice = nil,
            GoodPrice = nil,
            SnipePrice = nil,
            PingBelow = nil,

            MinWeight = 0,
        }
    end

    if type(config) == "table" then
        return config
    end

    return nil
end

function IsMarketTrackerTarget(listing)

    if type(listing) ~= "table" then
        return false, nil
    end

    local petName =
        NormalizeMarketTrackerName(
            listing.PetName
        )

    local config =
        GetMarketTrackerTargetConfig(
            petName
        )

    if type(config) ~= "table" then
        return false, nil
    end

    local targetType =
        tostring(config.Type or "Rare")

    local displayWeight =
        tonumber(listing.DisplayWeight)
        or tonumber(listing.Weight)
        or 0

    if targetType == "Weight" then

        local minWeight =
            SafeNumber(
                config.MinWeight,
                80
            )

        if displayWeight < minWeight then
            return false, config
        end
    end

    return true, config
end

function BuildMarketTrackerListingKey(listing)

    if type(listing) ~= "table" then
        return ""
    end

    return tostring(game.JobId)
        .. ":"
        .. tostring(listing.BoothId or "UnknownBooth")
        .. ":"
        .. tostring(listing.UID or "UnknownUID")
end

function CleanupMarketTrackerDedupe()

    if type(MarketTrackerWebhook) ~= "table" then
        return
    end

    MarketTrackerWebhook.SentListings =
        MarketTrackerWebhook.SentListings
        or {}

    local now =
        os.clock()

    local lastCleanup =
        SafeNumber(
            MarketTrackerWebhook.LastCleanup,
            0
        )

    local cleanupInterval =
        SafeNumber(
            MarketTrackerWebhook.CleanupInterval,
            120
        )

    if now - lastCleanup < cleanupInterval then
        return
    end

    MarketTrackerWebhook.LastCleanup =
        now

    local dedupeSeconds =
        SafeNumber(
            MarketTrackerWebhook.DedupeSeconds,
            600
        )

    for key, sentAt in pairs(MarketTrackerWebhook.SentListings) do

        sentAt =
            tonumber(sentAt)

        if not sentAt
        or now - sentAt > dedupeSeconds then
            MarketTrackerWebhook.SentListings[key] =
                nil
        end
    end
end

function HasMarketTrackerSentListing(listing)

    local key =
        BuildMarketTrackerListingKey(listing)

    if key == "" then
        return true
    end

    CleanupMarketTrackerDedupe()

    local sentAt =
        MarketTrackerWebhook.SentListings
        and MarketTrackerWebhook.SentListings[key]

    if not sentAt then
        return false
    end

    local dedupeSeconds =
        SafeNumber(
            MarketTrackerWebhook.DedupeSeconds,
            600
        )

    return os.clock() - SafeNumber(sentAt, 0)
        < dedupeSeconds
end

function MarkMarketTrackerListingSent(listing)

    local key =
        BuildMarketTrackerListingKey(listing)

    if key == "" then
        return false
    end

    MarketTrackerWebhook.SentListings =
        MarketTrackerWebhook.SentListings
        or {}

    MarketTrackerWebhook.SentListings[key] =
        os.clock()

    return true
end

function FormatMarketTrackerNumber(value)

    local number =
        tonumber(value)

    if not number then
        return "Unknown"
    end

    number =
        math.floor(number)

    local text =
        tostring(number)

    local left, num, right =
        string.match(
            text,
            "^([^%d]*%d)(%d*)(.-)$"
        )

    if not left then
        return text
    end

    return left
        .. (
            num:reverse()
                :gsub("(%d%d%d)", "%1,")
                :reverse()
        )
        .. right
end

function FormatMarketTrackerWeightKG(value)

    local number =
        tonumber(value)

    if not number then
        return "Unknown"
    end

    return string.format(
        "%.2f KG",
        number
    )
end

function FormatMarketTrackerBaseWeight(value)

    local number =
        tonumber(value)

    if not number then
        return "Unknown"
    end

    return string.format(
        "%.2f",
        number
    )
end

function ResolveMarketTrackerWeightClass(weight)

    weight =
        tonumber(weight)
        or 0

    if weight < 10 then
        return "Small"
    elseif weight < 30 then
        return "Normal"
    elseif weight < 50 then
        return "Semi Huge"
    elseif weight < 70 then
        return "Huge"
    elseif weight < 80 then
        return "Semi Titanic"
    elseif weight < 90 then
        return "Titanic"
    elseif weight < 100 then
        return "Godly"
    end

    return "Colossal"
end

function ResolveMarketTrackerDeal(config, price)

    price =
        tonumber(price)
        or math.huge

    if type(config) ~= "table" then

        return {
            Text = "🔎 Found",
            Color = 0x5865F2,
            ShouldPing = false,
        }
    end

    local snipePrice =
        tonumber(config.SnipePrice)

    local goodPrice =
        tonumber(config.GoodPrice)

    local maxPrice =
        tonumber(config.MaxPrice)

    local pingBelow =
        tonumber(config.PingBelow)

    local shouldPing =
        pingBelow ~= nil
        and price <= pingBelow

    if snipePrice
    and price <= snipePrice then

        return {
            Text = "🔥 Snipe",
            Color = 0x22C55E,
            ShouldPing = shouldPing,
        }
    end

    if goodPrice
    and price <= goodPrice then

        return {
            Text = "✅ Good",
            Color = 0x16A34A,
            ShouldPing = shouldPing,
        }
    end

    if maxPrice
    and price <= maxPrice then

        return {
            Text = "⚖️ Fair",
            Color = 0xFACC15,
            ShouldPing = shouldPing,
        }
    end

    if maxPrice then

        return {
            Text = "❌ Overpriced",
            Color = 0xEF4444,
            ShouldPing = shouldPing,
        }
    end

    return {
        Text = "🔎 Found",
        Color = 0x5865F2,
        ShouldPing = shouldPing,
    }
end

function BuildMarketTrackerTitle(petName, age, displayWeight, config)

    local emoji =
        type(config) == "table"
        and tostring(config.Emoji or "🔎")
        or "🔎"

    local ageText =
    tostring(
        tonumber(age)
        or 0
    )

    local weightText =
        FormatMarketTrackerWeightKG(
            displayWeight
        )

    local weightClass =
        ResolveMarketTrackerWeightClass(
            displayWeight
        )

    return emoji
        .. " "
        .. tostring(petName or "Unknown")
        .. " [Age "
        .. tostring(ageText)
        .. "] ["
        .. tostring(weightText)
        .. "] ("
        .. tostring(weightClass)
        .. ")"
end

function SendMarketTrackerWebhookNow(listing)

    if type(MarketTrackerWebhook) ~= "table"
    or MarketTrackerWebhook.Enabled ~= true then
        return false
    end

    if type(listing) ~= "table" then
        return false
    end

    local webhookUrl =
        tostring(MarketTrackerWebhook.URL or "")
            :gsub("%s+", "")

    if webhookUrl == ""
    or webhookUrl == "PUT_MARKET_TRACKER_WEBHOOK_HERE" then
        warn("[MARKET TRACKER] Webhook URL missing")
        return false
    end

    RequestFunction =
        RequestFunction
        or syn and syn.request
        or http_request
        or request
        or (http and http.request)
        or (fluxus and fluxus.request)

    if not RequestFunction then
        warn("[MARKET TRACKER] No request function available")
        return false
    end

    local petName =
        NormalizeMarketTrackerName(
            listing.PetName
        )

    if petName == "" then
        petName =
            "Unknown"
    end

    local config =
        GetMarketTrackerTargetConfig(
            petName
        )

    local sellerName =
        tostring(listing.Seller or "Unknown")

    if listing.SellerUserId then
        sellerName =
            ResolveSeller(listing.SellerUserId)
    end

    local price =
        tonumber(listing.Price)
        or 0

    local priceText =
        FormatMarketTrackerNumber(
            price
        )

    local displayWeight =
        tonumber(listing.DisplayWeight)
        or tonumber(listing.Weight)

    local baseWeight =
        tonumber(listing.BaseWeight)

    local age =
        tonumber(listing.Age)

    local deal =
        ResolveMarketTrackerDeal(
            config,
            price
        )

    local title =
        BuildMarketTrackerTitle(
            petName,
            age,
            displayWeight,
            config
        )

    local webJoinLink =
        "https://www.roblox.com/games/"
        .. tostring(TRADING_WORLD_PLACE_ID)
        .. "?gameInstanceId="
        .. tostring(game.JobId)

    local appLink =
        "roblox://experiences/start?placeId="
        .. tostring(TRADING_WORLD_PLACE_ID)
        .. "&gameInstanceId="
        .. tostring(game.JobId)

    local serverCopy =
        tostring(TRADING_WORLD_PLACE_ID)
        .. ":"
        .. tostring(game.JobId)

    local description =
        "**Seller:** "
        .. tostring(sellerName)
        .. "\n"
        .. "**Price:** "
        .. tostring(priceText)
        .. " tokens"
        .. "\n"
        .. "**Deal:** "
        .. tostring(deal.Text)
        .. "\n"
        .. "**BaseWeight:** "
        .. FormatMarketTrackerBaseWeight(baseWeight)
        .. " KG"
        .. "\n"
        .. "**Favorited:** "
        .. (
        listing.IsFavorite == true
        and "Yes"
        or "No"
        )
        .. "\n\n"
        .. "**Server:**\n"
        .. "[Open Game]("
        .. webJoinLink
        .. ")"
        .. "\n"
        .. "**Copy App Link:**\n"
        .. "```lua\n"
        .. appLink
        .. "\n```"
        .. "\n"
        .. "**Copy Server:**\n"
        .. "```lua\n"
        .. serverCopy
        .. "\n```"
        

    local payload = {
        embeds = {{

            title =
                title,

            description =
                description,

            color =
                deal.Color
                or 0x5865F2,

            footer = {
                text = "Holy Market Tracker"
            },

            timestamp =
                DateTime.now():ToIsoDate(),
        }}
    }

    if deal.ShouldPing == true then

    payload.content =
        "<@&1506753055050170559>"

    payload.allowed_mentions = {
        parse = {},
        roles = {
            "1506753055050170559",
        },
    }
else

    payload.allowed_mentions = {
        parse = {},
    }
end

    local ok, response =
        pcall(function()
            return RequestFunction({
                Url = webhookUrl,
                Method = "POST",

                Headers = {
                    ["Content-Type"] = "application/json"
                },

                Body = HttpService:JSONEncode(payload)
            })
        end)

    if not ok then
        warn(
            "[MARKET TRACKER] Request failed:",
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
                "[MARKET TRACKER] Bad status:",
                tostring(statusCode),
                tostring(response.Body or response.body or "")
            )

            return false
        end
    end

    print(
        "[MARKET TRACKER] Sent:",
        tostring(title),
        "|",
        tostring(priceText),
        "tokens",
        "|",
        tostring(deal.Text)
    )

    return true
end
function QueueMarketTrackerWebhook(listing)

    if type(MarketTrackerWebhook) ~= "table"
    or MarketTrackerWebhook.Enabled ~= true then
        return false
    end

    if type(listing) ~= "table" then
        return false
    end

    --==================================================
    -- NON-BLOCKING RATE GATE
    -- Do not queue and do not wait.
    -- If Discord is rate-limiting or one send is active,
    -- skip this attempt and let sniper/server hop continue.
    --==================================================

    local now =
        os.clock()

    MarketTrackerWebhook.RateLimitedUntil =
        SafeNumber(
            MarketTrackerWebhook.RateLimitedUntil,
            0
        )

    if now < MarketTrackerWebhook.RateLimitedUntil then
        return false
    end

    if MarketTrackerWebhook.Sending == true then
        return false
    end

    local sendDelay =
        SafeNumber(
            MarketTrackerWebhook.SendDelay,
            0.35
        )

    local elapsed =
        now - SafeNumber(
            MarketTrackerWebhook.LastSend,
            0
        )

    if elapsed < sendDelay then
        return false
    end

    if HasMarketTrackerSentListing(listing) then
        return false
    end

    -- Mark immediately so the same listing cannot spawn
    -- duplicate sends during fast scan passes.
    MarkMarketTrackerListingSent(listing)

    MarketTrackerWebhook.Sending =
        true

    MarketTrackerWebhook.LastSend =
        now

    task.spawn(function()

        local ok, err =
            pcall(function()
                SendMarketTrackerWebhookNow(listing)
            end)

        if not ok then
            warn(
                "[MARKET TRACKER] Immediate send failed:",
                tostring(err)
            )
        end

        MarketTrackerWebhook.Sending =
            false
    end)

    print(
        "[MARKET TRACKER] Instant send:",
        tostring(listing.PetName or "Unknown")
    )

    return true
end

function TrackMarketListings(listings)

    if type(MarketTrackerWebhook) ~= "table"
    or MarketTrackerWebhook.Enabled ~= true then
        return 0
    end

    if type(listings) ~= "table" then
        return 0
    end

    local sent =
        0

    for _, listing in ipairs(listings) do

        if type(listing) ~= "table" then
            continue
        end

        local isTarget =
    false

local config =
    nil

isTarget, config =
    IsMarketTrackerTarget(
        listing
    )

if isTarget then

    listing.MarketTrackerConfig =
        config

    local added =
        QueueMarketTrackerWebhook(
            listing
        )

    if added then
    sent += 1
    end
end
    end

if sent > 0 then

    print(
        "[MARKET TRACKER] Matches sent instantly:",
        tostring(sent)
    )
end

return sent
end

--==================================================
-- MARKET TRACKER QUEUE WORKER DISABLED
-- Market Tracker is live/time-sensitive.
-- It now sends immediately from QueueMarketTrackerWebhook().
-- Server hop must never wait for this system.
--==================================================
--==================================================
-- CONFIRMED TOOL SNAPSHOT PARSER
-- Source of truth after a successful snipe.
-- Parses actual inventory Tool name:
-- Example:
-- Shocked Mimic Octopus [3.14 KG] [Age 2]
-- Orangutan [1.29 KG] [Age 2]
-- Nightmare Mimic Octopus [61.37 KG]
--==================================================

function ParseConfirmedToolSnapshot(toolName)

    local raw =
        tostring(toolName or "")

    if raw == "" then
        return nil
    end

    local weight =
        raw:match("%[([%d%.]+)%s*KG%]")

    local age =
        raw:match("%[Age%s*(%d+)%]")

    local cleanName =
        raw:gsub("%b[]", "")

    cleanName =
        cleanName:gsub("%s+", " ")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    return {
        RawName = raw,
        CleanName = cleanName ~= "" and cleanName or raw,
        Weight = tonumber(weight),
        Age = tonumber(age),
    }
end
function ResolveMutationFromConfirmedToolName(toolName, basePetName)

    local snapshot =
        ParseConfirmedToolSnapshot(toolName)

    if not snapshot
    or not snapshot.CleanName then
        return "Normal"
    end

    local cleanName =
        tostring(snapshot.CleanName)

    basePetName =
        tostring(basePetName or "")

    if cleanName == ""
    or basePetName == ""
    or cleanName == basePetName then
        return "Normal"
    end

    local suffixStart =
        cleanName:find(basePetName, 1, true)

    if not suffixStart then
        return "Normal"
    end

    local mutation =
        cleanName:sub(1, suffixStart - 1)

    mutation =
        mutation:gsub("^%s+", "")
            :gsub("%s+$", "")

    if mutation == "" then
        return "Normal"
    end

    return mutation
end

--==================================================
-- HOLY SNIPES TARGET CHECK
-- Uses base listing pet name so mutation prefixes do not
-- break selected-pet routing.
--==================================================

function IsHolySnipesTarget(listing)

    if type(HolySnipesWebhook) ~= "table"
    or HolySnipesWebhook.Enabled ~= true then
        return false
    end

    if type(HolySnipesTargets) ~= "table" then
        return false
    end

    if type(listing) ~= "table" then
        return false
    end

    local petName =
        tostring(listing.PetName or "")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    if petName == "" then
        return false
    end

    return HolySnipesTargets[petName] == true
end

--==================================================
-- GLOBAL HOLY SNIPES WEBHOOK SEND
-- Premium public flex card.
-- Title uses confirmed display Tool data:
-- HOLY SNIPED • Pet [Age X] [Y KG]
--==================================================

function SendHolySnipesWebhookNow(listing, toolName, confirmedPetName, confirmedAge, confirmedWeight, mutationText)

    if not IsHolySnipesTarget(listing) then
        return false
    end

    if type(HolySnipesWebhook.URL) ~= "string"
    or HolySnipesWebhook.URL == ""
    or HolySnipesWebhook.URL == "PUT_HOLY_SNIPES_WEBHOOK_HERE" then
        warn("[HOLY SNIPES WEBHOOK] Missing URL")
        return false
    end

    RequestFunction =
        RequestFunction
        or syn and syn.request
        or http_request
        or request
        or (http and http.request)
        or (fluxus and fluxus.request)

    if not RequestFunction then
        warn("[HOLY SNIPES WEBHOOK] No request function available")
        return false
    end

    local title =
        string.format(
            "👑 HOLY SNIPED • %s [Age %s] [%s]",
            tostring(confirmedPetName or listing.PetName or "Unknown"),
            tostring(confirmedAge or "Unknown"),
            FormatWebhookWeightKG(confirmedWeight)
        )

    mutationText =
        tostring(mutationText or "Normal")

    if mutationText == ""
    or mutationText == "---"
    or mutationText == "Unknown" then
        mutationText =
            "Normal"
    end

    local payload = {
        username = "👑 HOLY",

        embeds = {{

            title = title,

            description = "Sniped By: Holy",

            color =
                tonumber(HolySnipesWebhook.Color)
                or 0xEAF3FF,

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
                        FormatWebhookBaseWeight(
                            listing.BaseWeight
                        ),
                    inline = true,
                },
            },

            footer = {
                text = "HOLY Crown"
            },

            timestamp =
                DateTime.now():ToIsoDate(),
        }}
    }

    local ok, response =
        pcall(function()
            return RequestFunction({
                Url =
                    tostring(HolySnipesWebhook.URL)
                        :gsub("%s+", ""),

                Method = "POST",

                Headers = {
                    ["Content-Type"] = "application/json"
                },

                Body = HttpService:JSONEncode(payload)
            })
        end)

    if not ok then
        warn(
            "[HOLY SNIPES WEBHOOK] Request failed:",
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

    local bodyText =
        tostring(response.Body or response.body or "")

    if statusCode == 429 then

        local retryAfter =
            0.5

        local okDecode, decoded =
            pcall(function()
                return HttpService:JSONDecode(bodyText)
            end)

        if okDecode
        and type(decoded) == "table" then
            retryAfter =
                tonumber(decoded.retry_after)
                or retryAfter
        end

        retryAfter =
            math.clamp(
                retryAfter + 0.15,
                0.35,
                5
            )

        MarketTrackerWebhook.RateLimitedUntil =
            os.clock() + retryAfter

        local lastWarn =
            SafeNumber(
                MarketTrackerWebhook.LastRateLimitWarnAt,
                0
            )

        if os.clock() - lastWarn > 2 then

            MarketTrackerWebhook.LastRateLimitWarnAt =
                os.clock()

            warn(
                "[MARKET TRACKER] Discord rate limit, pausing sends for:",
                tostring(retryAfter),
                "seconds"
            )
        end

        return false
    end

    warn(
        "[MARKET TRACKER] Bad status:",
        tostring(statusCode),
        bodyText
    )

    return false
end
    end

    print(
        "[HOLY SNIPES WEBHOOK] Sent:",
        tostring(title)
    )

    return true
end

function SendGlobalSnipeWebhook(listing, toolName, source)

    if not GlobalSnipeWebhook.Enabled then
        warn("[GLOBAL SNIPER WEBHOOK] Disabled")
        return
    end

    if type(GlobalSnipeWebhook.URL) ~= "string"
    or GlobalSnipeWebhook.URL == "" then
        warn("[GLOBAL SNIPER WEBHOOK] Missing URL")
        return
    end

RequestFunction =
    RequestFunction
    or syn and syn.request
    or http_request
    or request
    or (http and http.request)
    or (fluxus and fluxus.request)

if not RequestFunction then
    warn("[GLOBAL SNIPER WEBHOOK] No request function available")
    return
end

    task.spawn(function()

        local snapshot =
            ParseConfirmedToolSnapshot(toolName)

local confirmedPetName =
    snapshot
    and snapshot.CleanName
    or tostring(listing.PetName or "Unknown")

local confirmedWeight =
    snapshot
    and snapshot.Weight
    or tonumber(listing.DisplayWeight)
    or tonumber(listing.Weight)

local confirmedAge =
    snapshot
    and snapshot.Age
    or tonumber(listing.Age)

local mutationText =
    ResolveMutationFromConfirmedToolName(
        toolName,
        listing.PetName
    )

if mutationText == "Normal"
or mutationText == "Unknown"
or mutationText == "" then

    mutationText =
        tostring(
            listing.MutationText
            or listing.Mutation
            or "Normal"
        )
end

local confirmedTitle =
    string.format(
        "%s [Age %s] [%s]",
        tostring(confirmedPetName),
        tostring(confirmedAge or "Unknown"),
        FormatWebhookWeightKG(confirmedWeight)
    )

        local serverCopy =
            tostring(game.PlaceId)
            .. ":"
            .. tostring(game.JobId)

        local sellerName =
            tostring(listing.Seller or "Unknown")

        if listing.SellerUserId then
            sellerName =
                ResolveSeller(listing.SellerUserId)
        end

        local fields = {

            {
                name = "Price",
                value = tostring(listing.Price),
                inline = true,
            },

            {
                name = "Weight",
                value =
                    confirmedWeight
                    and (tostring(confirmedWeight) .. " KG")
                    or "Unknown",
                inline = true,
            },
        }

        if confirmedAge then
            table.insert(fields, {
                name = "Age",
                value = tostring(confirmedAge),
                inline = true,
            })
        end

        table.insert(fields, {
            name = "Seller",
            value = sellerName,
            inline = true,
        })

        table.insert(fields, {
            name = "Server",
            value =
                "```lua\n"
                .. serverCopy
                .. "\n```",
            inline = false,
        })

        local payload = {
            embeds = {{

                title =
                    string.format(
                        "**%s**",
                        confirmedTitle
                    ),

                color = 0x8B5CF6,

                fields = fields,

                footer = {
                    text = "Holy V2 Global"
                },

                timestamp = DateTime.now():ToIsoDate(),
            }}
        }

        local ok, response =
            pcall(function()
                return RequestFunction({
                    Url =
                        tostring(GlobalSnipeWebhook.URL)
                            :gsub("%s+", ""),

                    Method = "POST",

                    Headers = {
                        ["Content-Type"] = "application/json"
                    },

                    Body = HttpService:JSONEncode(payload)
                })
            end)

        if not ok then
            warn(
                "[GLOBAL SNIPER WEBHOOK] Request failed:",
                tostring(response)
            )
            return
        end

        if type(response) == "table" then

            local statusCode =
                tonumber(response.StatusCode or response.status_code)

            if statusCode
            and statusCode ~= 200
            and statusCode ~= 204 then

                warn(
                    "[GLOBAL SNIPER WEBHOOK] Bad status:",
                    tostring(statusCode),
                    tostring(response.Body or response.body or "")
                )

                return
            end
        end

        print(
            "[GLOBAL SNIPER WEBHOOK] Sent successful snipe:",
            confirmedTitle
        )

        --==================================================
        -- HOLY SNIPES WEBHOOK
        -- Premium global route. Fires only after confirmed
        -- inventory snipe and only for selected base pets.
        --==================================================

        pcall(function()
            SendHolySnipesWebhookNow(
                listing,
                toolName,
                confirmedPetName,
                confirmedAge,
                confirmedWeight,
                mutationText
            )
        end)
    end)
end
function TryPurchaseListing(listing)

    local listingKey =
        tostring(listing.BoothId)
        .. "_"
        .. tostring(listing.UID)

    local function ReleaseLock()
        ActivePurchases[listingKey] = nil
    end

    local now = os.clock()

    --==================================================
    -- FAILED LISTING LOCK
    --==================================================

    local failedAt =
        FailedListings[listingKey]

    if failedAt
    and now - failedAt < 999999 then
        ReleaseLock()
        return false
    end

    --==================================================
    -- GLOBAL BUY LOCK
    --==================================================

    ActivePurchases[listingKey] = true

    local remote =
        GetBuyRemote()

    if not remote then
        ReleaseLock()
        return false
    end

    local sellerPlayer =
        Players:GetPlayerByUserId(
            listing.SellerUserId
        )

    if not sellerPlayer then

        warn("[BUY] Seller player missing")

        FailedListings[listingKey] =
            os.clock()

        ReleaseLock()
        return false
    end

    print(
        string.format(
            "[BUYING] %s | %s tokens | %skg",
            tostring(listing.PetName),
            tostring(listing.Price),
            tostring(listing.Weight)
        )
    )

    --==================================================
    -- IMPORTANT:
    -- hook inventory BEFORE InvokeServer so we cannot miss
    -- fast replication
    --==================================================

    local inventoryWaiter =
        CreateInventoryWaiter(listing)

    local ok, result =
        pcall(function()

            return remote:InvokeServer(
                sellerPlayer,
                listing.UID
            )

        end)

    --==================================================
    -- TOKEN FAILURE
    --==================================================

        LastTokenFailure =
        SafeNumber(LastTokenFailure, 0)

    if SafeElapsed(LastTokenFailure) < 1 then

        inventoryWaiter.Disconnect()

        warn(
            string.format(
                "[BUY FAILED] Insufficient tokens → %s",
                tostring(listing.PetName)
            )
        )

        FailedListings[listingKey] =
            os.clock()

        ReleaseLock()
        return false
    end

    --==================================================
    -- HARD INVOKE FAILURE
    --==================================================

    if not ok then

        inventoryWaiter.Disconnect()

        warn("[BUY] Invoke failed:", result)

        FailedListings[listingKey] =
            os.clock()

        ReleaseLock()
        return false
    end

    --==================================================
    -- SERVER REJECTED PURCHASE
    --==================================================

    if result == false then

        inventoryWaiter.Disconnect()

                LastPendingSale =
            SafeNumber(LastPendingSale, 0)

        if SafeElapsed(LastPendingSale) < 1.25 then

            warn(
                string.format(
                    "[BUY PENDING] %s → will retry",
                    tostring(listing.PetName)
                )
            )

            ReleaseLock()
            return "PENDING"
        end

        warn(
            string.format(
                "[BUY FAILED] %s",
                tostring(listing.PetName)
            )
        )

        FailedListings[listingKey] =
            os.clock()

        ReleaseLock()
        return false
    end

    --==================================================
    -- SERVER ACCEPTED PURCHASE
    -- Now wait until matching Tool replicates into inventory
    --==================================================

    print(
        string.format(
            "[BUY ACCEPTED] Waiting for inventory → %s",
            tostring(listing.PetName)
        )
    )

    local inventoryWaitTime =
    ResolveAdaptiveBuyWait()

print(
    "[BUY WAIT]",
    tostring(inventoryWaitTime) .. "s",
    "| adaptive:",
    tostring(
        LatencyGuard
        and LatencyGuard.AdaptiveBuyWait == true
    ),
    "| ping:",
    tostring(
        LatencyGuard
        and math.floor(SafeNumber(LatencyGuard.CurrentPing, 0) + 0.5)
        or "Unknown"
    )
)

local confirmed, toolName, source =
    inventoryWaiter.Wait(
        inventoryWaitTime
    )

if confirmed then

local boughtMessage =
    string.format(
        "%s added via %s",
        tostring(toolName),
        tostring(source)
    )

print(
    "[BOUGHT CONFIRMED] "
    .. boughtMessage
)
--==================================================
-- STAY AFTER CONFIRMED SNIPE
-- Adds extra time to the auto-hop timer only after
-- the purchased pet is confirmed in inventory.
--==================================================

SniperState.StayAfterSnipeSeconds =
    SafeNumber(
        SniperState.StayAfterSnipeSeconds,
        5
    )

if SniperState.StayAfterSnipe == true
and SniperState.StayAfterSnipeSeconds > 0 then

    local extraStayUntil =
        os.clock()
        + SniperState.StayAfterSnipeSeconds

    SniperState.StayAfterSnipeUntil =
        math.max(
            SafeNumber(
                SniperState.StayAfterSnipeUntil,
                0
            ),
            extraStayUntil
        )

    print(
        string.format(
            "[SniperHop] Confirmed snipe stay added: %.1fs",
            SniperState.StayAfterSnipeSeconds
        )
    )

    HolyNotify(
        "Confirmed Snipe",
        "Auto hop delayed by "
            .. tostring(SniperState.StayAfterSnipeSeconds)
            .. " seconds.",
        "clock",
        3
    )
end

HolyNotify(
    "Snipe Confirmed",
    boughtMessage,
    "badge-check",
    5
)

    --==================================================
    -- GLOBAL SNIPE WEBHOOK
    -- Sends only after inventory confirmation.
    -- Does not depend on personal webhook toggle.
    --==================================================

    SendGlobalSnipeWebhook(
        listing,
        toolName,
        source
    )

    --==================================================
    -- EVENT-DRIVEN SHOWCASE RE-EQUIP
    -- Triggered only after bought pet reaches inventory
    --==================================================

    if BoothPetState.Enabled then

        ShowcaseEquipState.ReequipPending = true
        ShowcaseEquipState.InventoryConfirmedAt = os.clock()
        ShowcaseEquipState.RequestId =
        ShowcaseEquipState.RequestId + 1

        print(
            string.format(
                "[BoothPet] Re-equip scheduled in %.1fs",
                ShowcaseEquipState.ReequipDelay
            )
        )
    end

else

    warn(
        string.format(
            "[BUY WARNING] Inventory confirmation timeout → %s",
            tostring(listing.PetName)
        )
    )
end

    ProcessedListings[listingKey] = true

    --==================================================
    -- PERSONAL WEBHOOK
    --==================================================

    if WebhookState.Enabled
    and WebhookState.NotifySuccessfulSnipe then

        QueueWebhook(
        ApplyWebhookPing(
        CreateSuccessEmbed(
            listing,
            toolName,
            source
        ),
        WebhookState.PingSuccessfulSnipes
    )
)
    end

    ReleaseLock()
    return true
end
--==================================================
-- SNIPER SERVER RESOLUTION
-- Mode-aware paginated server search.
--
-- Fullest Under Max:
--   Fetches Desc pages and prefers high population under MaxServerPlayers.
--
-- Balanced:
--   Fetches Desc pages but picks from a wider mixed pool.
--
-- Low Player:
--   Fetches Asc pages so low-pop servers are actually discoverable.
--==================================================

function GetRandomTradeServer()

    local maxAllowedPlayers =
        tonumber(SniperState.MaxServerPlayers)
        or 24

    maxAllowedPlayers =
        math.clamp(
            math.floor(maxAllowedPlayers),
            1,
            30
        )

    local hopMode =
        tostring(
            SniperState.ServerHopMode
            or "Fullest Under Max"
        )

    local sortOrder =
        "Desc"

    if hopMode == "Low Player" then
        sortOrder =
            "Asc"
    end

    local valid = {}
    local cursor = nil

    local MAX_PAGES =
    math.clamp(
        math.floor(
            SafeNumber(
                SniperState.ServerHopPages,
                hopMode == "Low Player" and 8 or 4
            )
        ),
        1,
        10
    )

    local function AddServer(server, ignoreHistory)

        if type(server) ~= "table" then
            return
        end

        local id =
            server.id

        local playing =
            tonumber(server.playing)

        local maxPlayers =
            tonumber(server.maxPlayers)

        if not id
        or not playing
        or not maxPlayers then
            return
        end

        if id == game.JobId then
            return
        end

        if playing >= maxPlayers then
            return
        end

        if playing > maxAllowedPlayers then
            return
        end

        if not ignoreHistory
        and SniperState.RecentServers[id] then
            return
        end

        table.insert(valid, {
            Id = id,
            Playing = playing,
            MaxPlayers = maxPlayers,
            OpenSlots = maxPlayers - playing,
        })
    end

    local function FetchPages(ignoreHistory)

        cursor =
            nil

        for page = 1, MAX_PAGES do

            local url =
                "https://games.roblox.com/v1/games/"
                .. TRADING_WORLD_PLACE_ID
                .. "/servers/Public?sortOrder="
                .. sortOrder
                .. "&limit=100&excludeFullGames=true"

            if cursor then
                url =
                    url
                    .. "&cursor="
                    .. HttpService:UrlEncode(cursor)
            end

            local ok, body =
                pcall(function()
                    return game:HttpGet(url)
                end)

            if not ok
            or not body then

                HolyNotify(
                    "Server Hop Failed",
                    "Could not fetch public server list.",
                    "wifi-off",
                    3
                )

                break
            end

            local decoded

            ok, decoded =
                pcall(function()
                    return HttpService:JSONDecode(body)
                end)

            if not ok
            or not decoded
            or type(decoded.data) ~= "table" then

                HolyNotify(
                    "Server Hop Failed",
                    "Invalid server list response.",
                    "server-off",
                    3
                )

                break
            end

            for _, server in ipairs(decoded.data) do
                AddServer(server, ignoreHistory)
            end

            cursor =
                decoded.nextPageCursor

            if not cursor
            or cursor == "" then
                break
            end
        end
    end

    FetchPages(false)

    -- If recent-server history blocked everything, clear history and retry once.
    if #valid <= 0 then

        table.clear(SniperState.RecentServers)

        FetchPages(true)
    end

    if #valid <= 0 then

        HolyNotify(
            "No Server Found",
            "No public server found under "
                .. tostring(maxAllowedPlayers)
                .. " players. Try raising Max Server Players.",
            "server-off",
            4
        )

        warn(
            "[SniperHop] No valid servers found | max:",
            tostring(maxAllowedPlayers),
            "| mode:",
            tostring(hopMode),
            "| sort:",
            tostring(sortOrder)
        )

        return nil
    end

    --==================================================
    -- MODE SORTING
    --==================================================

    if hopMode == "Low Player" then

        table.sort(valid, function(a, b)

            if a.Playing ~= b.Playing then
                return a.Playing < b.Playing
            end

            return a.OpenSlots > b.OpenSlots
        end)

    elseif hopMode == "Balanced" then

        table.sort(valid, function(a, b)

            local target =
                math.max(
                    1,
                    math.floor(maxAllowedPlayers * 0.65)
                )

            local aDelta =
                math.abs(a.Playing - target)

            local bDelta =
                math.abs(b.Playing - target)

            if aDelta ~= bDelta then
                return aDelta < bDelta
            end

            return a.Playing > b.Playing
        end)

    else

        table.sort(valid, function(a, b)

            if a.Playing ~= b.Playing then
                return a.Playing > b.Playing
            end

            return a.OpenSlots > b.OpenSlots
        end)
    end

    local poolSize

    if hopMode == "Low Player" then
        poolSize =
            math.min(
                #valid,
                12
            )

    elseif hopMode == "Balanced" then
        poolSize =
            math.min(
                #valid,
                16
            )

    else
        poolSize =
            math.min(
                #valid,
                8
            )
    end

    local selected =
        valid[
            math.random(
                1,
                poolSize
            )
        ]

    if not selected then
        return nil
    end

    local selectedServerMessage =
        string.format(
            "%s/%s players • max %s • %s",
            tostring(selected.Playing),
            tostring(selected.MaxPlayers),
            tostring(maxAllowedPlayers),
            tostring(hopMode)
        )

    print(
    "[SniperHop] Selected server | "
    .. selectedServerMessage
    .. " | pages "
    .. tostring(MAX_PAGES)
    .. " | pool "
    .. tostring(#valid)
)

    HolyNotify(
        "Server Selected",
        selectedServerMessage,
        "server",
        3
    )

    return selected.Id
end
--==================================================
-- SNIPER SERVER HOP
--==================================================

function ExecuteSniperHop()

    if SniperState.Hopping then
        return
    end

    SniperState.Hopping = true

    SniperState.LastHop =
    SafeNumber(SniperState.LastHop, 0)

SniperState.HopDelay =
    SafeNumber(SniperState.HopDelay, 10)

local elapsed =
    SafeElapsed(SniperState.LastHop)

    if elapsed < SniperState.HopDelay then
        SniperState.Hopping = false
        return
    end

    local target =
        GetRandomTradeServer()

    if not target then
        SniperState.Hopping = false
        return
    end

SniperState.LastHop = os.clock()

SniperState.RecentServers[target] = true

if TeleportRetryState then
    TeleportRetryState.LastTarget = target
    TeleportRetryState.BlockedServers[target] = true
end

print(
    "[SniperHop] Joining:",
    target
)

HolyNotify(
    "Server Hop",
    "Joining selected Trade World server...",
    "send",
    3
)

    local TeleportService =
        game:GetService("TeleportService")

    local player =
        Players.LocalPlayer

    pcall(function()

        TeleportService:TeleportToPlaceInstance(
            TRADING_WORLD_PLACE_ID,
            target,
            player
        )

    end)

    task.delay(8, function()
        SniperState.Hopping = false
    end)
end
--==================================================
-- TEST SNIPER SCAN
--==================================================
function CountVisiblePetTools()

    local player =
        Players.LocalPlayer

    if not player then
        return 0
    end

    local total = 0

    local containers = {
        player:FindFirstChild("Backpack"),
        player.Character,
    }

    for _, container in ipairs(containers) do

        if container then

            for _, child in ipairs(container:GetChildren()) do

                if child:IsA("Tool") then

                    local name =
                        tostring(child.Name or "")

                    if name:find("%[.-KG%]")
                    or name:find("%[Age%s*%d+%]") then
                        total = total + 1
                    end
                end
            end
        end
    end

    return total
end

function IsHolyPetInventoryFull()

    if SniperState.StopAtPetInventoryLimit ~= true then
        return false
    end

    local maxPets =
        tonumber(SniperState.MaxPetInventory)
        or math.huge

    if maxPets <= 0 then
        return false
    end

    local currentPets =
        CountVisiblePetTools()

    return currentPets >= maxPets, currentPets, maxPets
end

function RunSniperScan()

    if SniperState.Scanning then
        return
    end

    SniperState.Scanning =
        true

    local ok, err =
        pcall(function()

            local listings, scannedCount =
                ExtractListings()

            if type(TrackMarketListings) == "function" then
                pcall(function()
                    TrackMarketListings(listings)
                end)
            end

            if SniperMonitorState then

                SniperMonitorState.PetsScanned =
                    tonumber(scannedCount)
                    or 0

                SniperMonitorState.ScanPasses =
                    (SniperMonitorState.ScanPasses or 0) + 1
            end

            local priorityMatches =
                {}

            local matches =
                0

            --==================================================
            -- FIRST PASS:
            -- collect all valid matches.
            -- Do NOT buy during booth scan order.
            --==================================================

            for i = 1, #listings do

                local listing =
                    listings[i]

                local matched =
                    ListingMatchesFilter(listing)

                if matched then

                    local inventoryFull, currentPets, maxPets =
                        IsHolyPetInventoryFull()

                    if inventoryFull then

                        warn(
                            string.format(
                                "[SNIPER] Inventory safety limit reached: %s/%s pets",
                                tostring(currentPets),
                                tostring(maxPets)
                            )
                        )

                        HolyNotify(
                            "Inventory Limit Reached",
                            tostring(currentPets)
                                .. "/"
                                .. tostring(maxPets)
                                .. " pets. Holy paused buying.",
                            "package-x",
                            5
                        )

                        continue
                    end

                    local listingKey =
                        tostring(listing.BoothId)
                        .. "_"
                        .. tostring(listing.UID)

                    if ClaimedListings[listingKey] then
                        continue
                    end

                    matches += 1

                    table.insert(
                        priorityMatches,
                        listing
                    )
                end
            end

            --==================================================
            -- PRIORITY SORT:
            -- 1. Filter priority
            -- 2. Better deal %
            -- 3. Lower price
            -- 4. Higher weight
            --==================================================

            table.sort(
                priorityMatches,
                ComparePriorityListings
            )

            --==================================================
            -- SECOND PASS:
            -- dispatch in priority order.
            --==================================================

            for index, listing in ipairs(priorityMatches) do

                local listingKey =
                    tostring(listing.BoothId)
                    .. "_"
                    .. tostring(listing.UID)

                if ClaimedListings[listingKey] then
                    continue
                end

                ClaimedListings[listingKey] =
                    true

                print(
                    string.format(
                        "[MATCH P%s #%s] %s | %s tokens | %skg | deal %.2f",
                        tostring(
                            ClampSniperPriority(
                                listing.MatchedPriority
                            )
                        ),
                        tostring(index),
                        tostring(listing.PetName),
                        tostring(listing.Price),
                        tostring(listing.Weight),
                        tonumber(listing.MatchedDealScore) or 0
                    )
                )

                local dispatched =
                    DispatchPurchase(listing)

                if dispatched then

                    task.delay(15, function()

                        ClaimedListings[listingKey] =
                            nil
                    end)

                else

                    ClaimedListings[listingKey] =
                        nil
                end
            end

            if matches > 0 then

                print(
                    "[SNIPER] Priority matches:",
                    tostring(matches),
                    "| dispatched:",
                    tostring(#priorityMatches)
                )

            else

                if SniperState.AutoHop then

                    SniperState.ScanStartedAt =
                        SafeNumber(
                            SniperState.ScanStartedAt,
                            os.clock()
                        )

                    local elapsed =
                        SafeElapsed(
                            SniperState.ScanStartedAt
                        )

                    if elapsed >= SniperState.ScanDuration then

                        SniperState.StayAfterSnipeUntil =
                            SafeNumber(
                                SniperState.StayAfterSnipeUntil,
                                0
                            )

                        local stayRemaining =
                            SafeRemaining(
                                SniperState.StayAfterSnipeUntil
                            )

                        if SniperState.StayAfterSnipe == true
                        and stayRemaining > 0 then

                            print(
                                string.format(
                                    "[SniperHop] Staying after snipe: %.1fs remaining",
                                    stayRemaining
                                )
                            )

                            return
                        end

                        SniperState.ScanStartedAt =
                            os.clock()

                        task.spawn(
                            ExecuteSniperHop
                        )
                    end
                end
            end

            SniperState.LastScan =
                os.clock()
        end)

    SniperState.Scanning =
        false

    if not ok then
        warn("[SNIPER] Scan failed:", err)
    end
end
--==================================================
-- BOOTH DATA WARMUP (NON-BLOCKING SAFETY)
--==================================================
if game.PlaceId == TRADING_WORLD_PLACE_ID then
    task.spawn(function()
        local data = LatestBoothData

        if data then
            print("[BOOT] Booth data ready")
        else
            warn("[BOOT] Booth data not ready (will resolve later)")
        end
    end)
end
--==================================================
-- [3] LOAD OBSIDIAN (ISOLATED)
--==================================================
repo = "https://raw.githubusercontent.com/bencapalot041/goons/main/"

function SafeLoad(url)
    local ok, src = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not ok or type(src) ~= "string" or #src < 100 then
        error("[Loader] HTTP failed: " .. tostring(url))
    end

    local fn, err = loadstring(src)
    if not fn then
        error("[Loader] Compile failed: " .. tostring(err))
    end

    local okRun, result = pcall(fn)
    if not okRun then
        error("[Loader] Runtime failed: " .. tostring(result))
    end

    return result
end

--==================================================
-- OBSIDIAN LOAD
-- TEST LIBRARY MODE
-- Uses library.test.lua so Library.lua stays safe.
--==================================================

Library =
    SafeLoad(
        repo
        .. "librarytest.lua?v="
        .. tostring(os.time())
    )

SaveManager =
    SafeLoad(
        repo
        .. "addons/SaveManager.lua?v="
        .. tostring(os.time())
    )

ThemeManager =
    SafeLoad(
        repo
        .. "addons/ThemeManager.lua?v="
        .. tostring(os.time())
    )
print(
    "[LIB TEST]",
    "Library loaded:",
    tostring(type(Library)),
    "| version file:",
    "librarytest.lua"
)
--==================================================
-- HOLY NOTIFICATION WRAPPER
-- User-facing Obsidian notifications only.
-- Console prints should stay for debug/dev-only logs.
--==================================================

function HolyNotify(title, description, icon, duration)

    if not Library
    or type(Library.Notify) ~= "function" then
        return false
    end

    local ok =
        pcall(function()
            Library:Notify({
                Title = tostring(title or "Holy"),
                Description = tostring(description or ""),
                Icon = tostring(icon or "info"),
                Time = tonumber(duration) or 4,
            })
        end)

    return ok
end

HolyLoading =
    Library:CreateLoading({
        Title = "Holy",
        Icon = "zap",
        TotalSteps = 6,
    })

HolyLoading:SetMessage("Initializing Holy...")
HolyLoading:SetDescription("Loading core services...")
HolyLoading:SetCurrentStep(1)
--==================================================
-- SERVICE REGISTRY
--==================================================

Services = {}

--==================================================
-- WORKER REGISTRY
--==================================================

RuntimeWorkers = {}

function StartWorker(name, fn)

    if RuntimeWorkers[name] then
        warn(
            string.format(
                "[WORKER] %s already running",
                tostring(name)
            )
        )

        return RuntimeWorkers[name]
    end

    local thread = task.spawn(function()

        local ok, err = pcall(fn)

        if not ok then
            warn(
                string.format(
                    "[WORKER] %s crashed: %s",
                    tostring(name),
                    tostring(err)
                )
            )
        end

        RuntimeWorkers[name] = nil
    end)

    RuntimeWorkers[name] = thread

    print(
        string.format(
            "[WORKER] Started → %s",
            tostring(name)
        )
    )

    return thread
end
--==================================================
-- TELEMETRY SERVICE
--==================================================

TelemetryService = {}

Services.Telemetry = TelemetryService

TelemetryService.Enabled = true

function TelemetryService:Push(category, message)

    if not self.Enabled then
        return
    end

    print(
        string.format(
            "[%s] %s",
            tostring(category),
            tostring(message)
        )
    )
end

function TelemetryService:Warn(category, message)

    warn(
        string.format(
            "[%s] %s",
            tostring(category),
            tostring(message)
        )
    )
end

function TelemetryService:Error(category, message)

    warn(
        string.format(
            "[%s ERROR] %s",
            tostring(category),
            tostring(message)
        )
    )
end
--==================================================
-- [4] GLOBAL STATE (AUTHORITATIVE)
--==================================================
ScriptState = {
    Loaded = false,
    ForceStopped = false,
}

RuntimeState = {
    Started = false,
}

BoothAuto = {
    Enabled = false,
    InProgress = false,

    -- Auto Teleport = soft return mode.
    AutoTeleport = false,

    -- Lock Behind Booth = intentional hard lock mode.
    LockBehindBooth = false,

    -- Distance behind booth placement.
    BoothDistance = 5,

    -- Distance allowed before soft-return teleports back.
    ReturnDistance = 8,

    LastBoothPosition = nil,
    LastBoothCFrame = nil,

    LastSoftReturnAt = 0,
    LastHardLockAt = 0,

    SoftReturnCooldown = 1.50,
    HardLockInterval = 0.15,

    AutoServerHop = false,
    ServerHopMinutes = 10,
    LastServerHop = 0,
}

function ClearBoothAnchor()
    if not BoothAuto then
        return
    end

    BoothAuto.LastBoothPosition = nil
    BoothAuto.LastBoothCFrame = nil
    BoothAuto.LastSoftReturnAt = 0
    BoothAuto.LastHardLockAt = 0
end

function RestoreCharacterMovement()
    local player =
        Players.LocalPlayer

    if not player then
        return false
    end

    local character =
        player.Character

    if not character then
        return false
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local root =
        character:FindFirstChild("HumanoidRootPart")

    if root then
        root.Anchored = false
    end

    if not humanoid then
        return false
    end

    humanoid.AutoRotate =
        true

    if humanoid.WalkSpeed <= 0 then
        humanoid.WalkSpeed = 16
    end

    if humanoid.JumpPower <= 0 then
        humanoid.JumpPower = 50
    end

    return true
end

function MoveCharacterToBoothCFrame(targetCFrame)
    if typeof(targetCFrame) ~= "CFrame" then
        return false
    end

    local player =
        Players.LocalPlayer

    if not player then
        return false
    end

    local character =
        player.Character

    if not character then
        return false
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if not humanoid
    or humanoid.Health <= 0 then
        return false
    end

    local root =
    character:FindFirstChild("HumanoidRootPart")

if root then
    root.Anchored = false
end

if humanoid.Sit then
    humanoid.Sit = false
    task.wait()
end

character:PivotTo(targetCFrame)

    return true
end

function SetBoothHardLockAnchored(enabled)
    local player =
        Players.LocalPlayer

    if not player then
        return false
    end

    local character =
        player.Character

    if not character then
        return false
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local root =
        character:FindFirstChild("HumanoidRootPart")

    if not root
    or not humanoid
    or humanoid.Health <= 0 then
        return false
    end

    if enabled then

        humanoid:Move(Vector3.zero, true)

        humanoid.WalkSpeed =
            0

        humanoid.JumpPower =
            0

        humanoid.AutoRotate =
            false

        root.AssemblyLinearVelocity =
            Vector3.zero

        root.AssemblyAngularVelocity =
            Vector3.zero

        local hardLockCFrame =
    GetBoothHardLockCFrame()

if hardLockCFrame then

    local needsCorrection =
        root.Anchored ~= true
        or (
            root.Position - hardLockCFrame.Position
        ).Magnitude > 0.05

    if needsCorrection then

        root.CFrame =
            hardLockCFrame

        root.AssemblyLinearVelocity =
            Vector3.zero

        root.AssemblyAngularVelocity =
            Vector3.zero
    end
end

root.Anchored =
    true

        return true
    end

    root.Anchored =
        false

    humanoid.AutoRotate =
        true

    RestoreCharacterMovement()

    return true
end

function GetBoothHardLockLift()
    return 0
end

function GetBoothHardLockCFrame()
    if typeof(BoothAuto.LastBoothCFrame) ~= "CFrame" then
        return nil
    end

    return BoothAuto.LastBoothCFrame
        + Vector3.new(
            0,
            GetBoothHardLockLift(),
            0
        )
end

function GetCharacterGroundOffset()
    local player =
        Players.LocalPlayer

    if not player then
        return 3
    end

    local character =
        player.Character

    if not character then
        return 3
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local root =
        character:FindFirstChild("HumanoidRootPart")

    local hipHeight =
        humanoid
        and tonumber(humanoid.HipHeight)
        or 2

    local rootHalfHeight =
        root
        and root.Size
        and (root.Size.Y * 0.5)
        or 1

    return math.clamp(
        hipHeight + rootHalfHeight + 0.05,
        2.75,
        5.5
    )
end

ConfigState = {
    IsHydrating = false,
    Dirty = false,
    LastMutation = 0,
    AutosaveName = "autosave",
}

UIState = {
    AutoMinimize = false,
    DPIScale = 90,
    PerformanceMode = false,
}

VisualState = {

    ExoticHUD = true,

    WatchlistHUD = false,

    -- Watchlist HUD sections.
    -- Both default ON because both watchlists are active for sniping.
    ShowWatchlist1HUD = true,
    ShowWatchlist2HUD = true,

    ServerInfoHUD = false,

    SniperMonitorHUD = false,
}


WorldState = {
    AutoJoinTradeWorld = false,
}
--==================================================
-- TRADE WORLD JOIN STATE
-- Manual join is instant.
-- Auto toggle waits 10 seconds before joining.
--==================================================

TradeWorldJoinState =
    TradeWorldJoinState
    or {
        Busy = false,
        LastAttempt = 0,
        Cooldown = 3,

        DelaySeconds = 10,
        PendingRequestId = 0,
    }

function RequestJoinTradeWorld(reason)

    if ScriptState.ForceStopped then
        return false
    end

    if IsTradeWorld() then

        HolyNotify(
            "Already in Trade World",
            "HOLY is already running in Trade World.",
            "check",
            3
        )

        return false
    end

    local now =
        os.clock()

    local lastAttempt =
        SafeNumber(
            TradeWorldJoinState.LastAttempt,
            0
        )

    local cooldown =
        SafeNumber(
            TradeWorldJoinState.Cooldown,
            3
        )

    if TradeWorldJoinState.Busy then
        return false
    end

    if now - lastAttempt < cooldown then
        return false
    end

    local player =
        Players.LocalPlayer

    if not player then
        warn("[WORLD] LocalPlayer missing")
        return false
    end

    TradeWorldJoinState.Busy =
        true

    TradeWorldJoinState.LastAttempt =
        now

    HolyNotify(
        "Joining Trade World",
        tostring(reason or "Teleporting to Trade World..."),
        "send",
        4
    )

    print("[WORLD] Joining Trade World")

    local TeleportService =
        game:GetService("TeleportService")

    local ok, err =
        pcall(function()

            TeleportService:Teleport(
                TRADING_WORLD_PLACE_ID,
                player
            )
        end)

    if not ok then

        TradeWorldJoinState.Busy =
            false

        warn(
            "[WORLD] Trade World teleport failed:",
            tostring(err)
        )

        HolyNotify(
            "Teleport Failed",
            tostring(err),
            "triangle-alert",
            4
        )

        return false
    end

    task.delay(8, function()

        TradeWorldJoinState.Busy =
            false
    end)

    return true
end

function CancelScheduledTradeWorldJoin()

    TradeWorldJoinState.PendingRequestId =
        SafeNumber(
            TradeWorldJoinState.PendingRequestId,
            0
        ) + 1

    print("[WORLD] Scheduled Trade World join cancelled")
end

function ScheduleJoinTradeWorld(reason)

    if ScriptState.ForceStopped then
        return false
    end

    if IsTradeWorld() then
        return false
    end

    TradeWorldJoinState.PendingRequestId =
        SafeNumber(
            TradeWorldJoinState.PendingRequestId,
            0
        ) + 1

    local requestId =
        TradeWorldJoinState.PendingRequestId

    local delaySeconds =
        SafeNumber(
            TradeWorldJoinState.DelaySeconds,
            10
        )

    delaySeconds =
        math.max(
            delaySeconds,
            1
        )

    HolyNotify(
        "Trade World Scheduled",
        "Teleporting in "
            .. tostring(delaySeconds)
            .. " seconds. Turn the toggle off to cancel.",
        "clock",
        5
    )

    print(
        "[WORLD] Trade World teleport scheduled in",
        tostring(delaySeconds),
        "seconds"
    )

    task.delay(delaySeconds, function()

        if ScriptState.ForceStopped then
            return
        end

        if requestId ~= TradeWorldJoinState.PendingRequestId then
            return
        end

        if WorldState.AutoJoinTradeWorld ~= true then

            HolyNotify(
                "Teleport Cancelled",
                "Auto Teleport Trade World was turned off.",
                "x",
                3
            )

            return
        end

        if IsTradeWorld() then
            return
        end

        RequestJoinTradeWorld(
            reason or "Auto Teleport Trade World delay finished."
        )
    end)

    return true
end

ReconnectState = {
    AutoReconnect = false,
    Busy = false,
    LastAttempt = 0,
    Cooldown = 5,
}

BoothCustomization = {
    SelectedSkin = "Default",
}

--==================================================
-- BOOTH SKIN OWNERSHIP
-- Source of truth:
-- DataService:GetData().TradeBoothSkinData.OwnedSkins
--==================================================

TradeBoothSkinRegistry =
    TradeBoothSkinRegistry
    or nil

BoothSkinList =
    {
        "Default",
    }

function GetTradeBoothSkinRegistry()

    if type(TradeBoothSkinRegistry) == "table" then
        return TradeBoothSkinRegistry
    end

    local dataFolder =
        ReplicatedStorage:FindFirstChild("Data")

    if not dataFolder then
        return nil
    end

    local module =
        dataFolder:FindFirstChild("TradeBoothSkinRegistry")

    if not module then
        return nil
    end

    local ok, result =
        pcall(function()
            return require(module)
        end)

    if ok
    and type(result) == "table" then
        TradeBoothSkinRegistry =
            result

        return TradeBoothSkinRegistry
    end

    return nil
end

function GetHolyPlayerData()

    local dataService =
        GetHolyDataService
        and GetHolyDataService()
        or nil

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

function GetOwnedBoothSkinMap()

    local data =
        GetHolyPlayerData()

    local skinData =
        type(data) == "table"
        and rawget(data, "TradeBoothSkinData")
        or nil

    local ownedSkins =
        type(skinData) == "table"
        and rawget(skinData, "OwnedSkins")
        or nil

    if type(ownedSkins) ~= "table" then
        return {
            Default = true,
        }
    end

    local owned = {
        Default = true,
    }

    for skinName, value in pairs(ownedSkins) do

        if value == true
        or tonumber(value) ~= nil then

            owned[tostring(skinName)] =
                true
        end
    end

    return owned
end

function RefreshBoothSkinList()

    local registry =
        GetTradeBoothSkinRegistry()

    local owned =
        GetOwnedBoothSkinMap()

    local names = {}
    local seen = {}

    local function AddSkinName(value)

        local name =
            tostring(value or "")
                :gsub("^%s+", "")
                :gsub("%s+$", "")

        if name == "" then
            return false
        end

        if seen[name] then
            return false
        end

        if not owned[name] then
            return false
        end

        if name ~= "Default" then

            if type(registry) ~= "table"
            or type(registry[name]) ~= "table" then
                return false
            end
        end

        seen[name] =
            true

        table.insert(
            names,
            name
        )

        return true
    end

    AddSkinName("Default")

    for skinName in pairs(owned) do
        AddSkinName(skinName)
    end

    table.sort(names, function(a, b)

        if a == "Default" then
            return true
        end

        if b == "Default" then
            return false
        end

        return a < b
    end)

    if #names <= 0 then
        names = {
            "Default",
        }
    end

    BoothSkinList =
        names

    print(
        "[BOOTH SKINS] Owned loaded:",
        tostring(#BoothSkinList)
    )

    return BoothSkinList
end

function IsOwnedBoothSkin(skinName)

    skinName =
        tostring(skinName or "")

    if skinName == "" then
        return false
    end

    local owned =
        GetOwnedBoothSkinMap()

    return owned[skinName] == true
end

function ResolveSelectedBoothSkin()

    local selected =
        tostring(
            BoothCustomization
            and BoothCustomization.SelectedSkin
            or "Default"
        )

    if IsOwnedBoothSkin(selected) then
        return selected
    end

    BoothCustomization.SelectedSkin =
        "Default"

    return "Default"
end
--==================================================
-- BEE EGG AUTO BUY STATE
-- Trade World remote-accessible event shop buyer.
--==================================================

BeeEggAuto = {
    Enabled = false,
    Buying = false,

    SelectedEggs = {
        ["Mythical Bee Egg"] = true,
    },

    EggList = {},

    BuyRemote = nil,

    LastAttempt = 0,
    BuyInterval = 1.5,
}
--==================================================
-- CONFIG AUTOSAVE (DEBOUNCED)
--==================================================
function MarkConfigDirty()
    if ConfigState.IsHydrating then
        return
    end

    ConfigState.Dirty = true
    ConfigState.LastMutation = os.clock()
end
--==================================================
-- SAFE NUMBER / TIMER HELPERS
-- Prevents obfuscator/minifier nil arithmetic crashes.
--==================================================

function SafeNumber(value, fallback)

    local numberValue =
        tonumber(value)

    if numberValue == nil then
        return fallback or 0
    end

    return numberValue
end

function SafeElapsed(lastTime)

    return os.clock()
        - SafeNumber(lastTime, 0)
end

function SafeRemaining(targetTime)

    return SafeNumber(targetTime, 0)
        - os.clock()
end

--==================================================
-- PLACE GATE
-- Core/UI can load everywhere.
-- Trade World automation may only execute in Trade World.
--==================================================

function IsTradeWorld()

    return game.PlaceId == TRADING_WORLD_PLACE_ID
end

FILTER_SAVE_FILE = "HolyV2/sniper_filters.json"

LISTING_FILTER_SAVE_FILE =
    "HolyV2/listing_filters.json"

LISTING_AUTOLIST_INTENT_SAVE_FILE =
    "HolyV2/listing_autolist_intent.json"
--==================================================
-- FILTER PERSISTENCE
-- Supports two active watchlists and migrates older single-list saves.
--==================================================

function SerializeFilterSet(filters)

    local serialized = {}

    if type(filters) ~= "table" then
        return serialized
    end

    for pet, data in pairs(filters) do

        if type(data) == "table" then

            serialized[tostring(pet)] = {
                MinWeight =
                    tonumber(data.MinWeight)
                    or 0,

                MaxPrice =
                    data.MaxPrice == math.huge
                    and "INF"
                    or tonumber(data.MaxPrice)
                    or math.huge,

                WeightMode =
    NormalizeWeightMode(data.WeightMode),

                Priority =
    ResolveSniperFilterPriority(data),

                Mutation =
                    select(
                        1,
                        ResolveSniperMutationModeAndSpecifics(data)
                    ),

                SpecificMutations =
                    SerializeSniperMutationMap(
                        select(
                            2,
                            ResolveSniperMutationModeAndSpecifics(data)
                        )
                    ),

                ExcludedMutations =
                    SerializeSniperMutationMap(
                        data.ExcludedMutations
                    ),
            }
        end
    end

    return serialized
end

function SerializeEggFocusSet(filters)

    local serialized = {}

    if type(filters) ~= "table" then
        return serialized
    end

    for eggName, data in pairs(filters) do

        if type(data) == "table" then

            serialized[tostring(eggName)] = {
                MaxPrice =
                    data.MaxPrice == math.huge
                    and "INF"
                    or tonumber(data.MaxPrice)
                    or math.huge,
            }
        end
    end

    return serialized
end
function SaveSniperFilters()

    if not writefile then
        warn("[Filters] writefile unsupported")
        return false
    end

    local ok, err = pcall(function()

        local serialized = {
    Version = 3,

    Watchlists = {
        ["1"] =
            SerializeFilterSet(
                GetSniperFilterSet(1)
            ),

        ["2"] =
            SerializeFilterSet(
                GetSniperFilterSet(2)
            ),
    },

    EggFocus = {
        ["1"] =
            SerializeEggFocusSet(
                GetEggFocusSet(1)
            ),

        ["2"] =
            SerializeEggFocusSet(
                GetEggFocusSet(2)
            ),
    },
}

        writefile(
            FILTER_SAVE_FILE,
            HttpService:JSONEncode(serialized)
        )
    end)

    if not ok then
        warn("[Filters] Save failed:", err)
        return false
    end

    print("[Filters] Saved")

    return true
end

function LoadFilterSetFromTable(target, source)

    if type(target) ~= "table"
    or type(source) ~= "table" then
        return
    end

    table.clear(target)

    for pet, data in pairs(source) do

        if pet ~= "Version"
        and pet ~= "Watchlists"
        and type(data) == "table" then

            target[tostring(pet)] = {
                MinWeight =
                    tonumber(data.MinWeight)
                    or 0,

                MaxPrice =
                    data.MaxPrice == "INF"
                    and math.huge
                    or tonumber(data.MaxPrice)
                    or math.huge,

                WeightMode =
    NormalizeWeightMode(data.WeightMode),

Priority =
    ClampSniperPriority(data.Priority),

Mutation =
    select(
        1,
        ResolveSniperMutationModeAndSpecifics(data)
    ),

SpecificMutations =
    select(
        2,
        ResolveSniperMutationModeAndSpecifics(data)
    ),

ExcludedMutations =
    DeserializeSniperMutationMap(
        data.ExcludedMutations
    ),
            }
        end
    end
end

function LoadEggFocusSetFromTable(target, source)

    if type(target) ~= "table"
    or type(source) ~= "table" then
        return
    end

    table.clear(target)

    for eggName, data in pairs(source) do

        if type(data) == "table" then

            target[tostring(eggName)] = {
                MaxPrice =
                    data.MaxPrice == "INF"
                    and math.huge
                    or tonumber(data.MaxPrice)
                    or math.huge,
            }
        end
    end
end

function LoadSniperFilters()

    if not isfile then
        warn("[Filters] isfile unsupported")
        return
    end

    if not readfile then
        warn("[Filters] readfile unsupported")
        return
    end

    if not isfile(FILTER_SAVE_FILE) then
        print("[Filters] No existing filter save")
        return
    end

    local ok, decoded = pcall(function()

        local raw =
            readfile(FILTER_SAVE_FILE)

        return HttpService:JSONDecode(raw)

    end)

    if not ok or type(decoded) ~= "table" then

        warn("[Filters] Corrupted filter file")

        if delfile then
            pcall(function()
                delfile(FILTER_SAVE_FILE)
            end)
        end

        return
    end

    table.clear(GetSniperFilterSet(1))
    table.clear(GetSniperFilterSet(2))

    if type(decoded.Watchlists) == "table" then

        LoadFilterSetFromTable(
            GetSniperFilterSet(1),
            decoded.Watchlists["1"]
                or decoded.Watchlists[1]
                or {}
        )

        LoadFilterSetFromTable(
            GetSniperFilterSet(2),
            decoded.Watchlists["2"]
                or decoded.Watchlists[2]
                or {}
        )

                if type(decoded.EggFocus) == "table" then

            LoadEggFocusSetFromTable(
                GetEggFocusSet(1),
                decoded.EggFocus["1"]
                    or decoded.EggFocus[1]
                    or {}
            )

            LoadEggFocusSetFromTable(
                GetEggFocusSet(2),
                decoded.EggFocus["2"]
                    or decoded.EggFocus[2]
                    or {}
            )
        else
            table.clear(GetEggFocusSet(1))
            table.clear(GetEggFocusSet(2))
        end

        print("[Filters] Loaded two watchlists")
        return
    end

    -- Legacy migration: old save format was a single pet-keyed table.
    LoadFilterSetFromTable(
        GetSniperFilterSet(1),
        decoded
    )

    print("[Filters] Loaded legacy watchlist into Watchlist 1")
end

--==================================================
-- LISTINGS: FILTER PERSISTENCE
-- Keeps AutoList filter presets after rejoin.
-- Saves separately from sniper watchlists.
--==================================================

function SerializeListingFilters()

    local output =
        {}

    if type(ListingsState) ~= "table" then
        return output
    end

    ListingsState.ListingFilters =
        ListingsState.ListingFilters
        or {}

    for _, filter in ipairs(ListingsState.ListingFilters) do

        if type(filter) == "table" then

            table.insert(output, {
                Pet =
                    tostring(filter.Pet or ""),

                Mutation =
    tostring(filter.Mutation or "---"),

ExcludedMutations =
    SerializeListingMutationMap(
        filter.ExcludedMutations
    ),

MinLevel =
    tonumber(filter.MinLevel)
    or 1,

MaxLevel =
    tonumber(filter.MaxLevel)
    or 100,

MinWeight =
    tonumber(filter.MinWeight),

                MaxWeight =
                    tonumber(filter.MaxWeight),

                Price =
                    tonumber(filter.Price),

                Enabled =
                    filter.Enabled ~= false,
            })
        end
    end

    return output
end

function SaveListingFilters()

    if not writefile then
        warn("[LISTINGS FILTERS] writefile unsupported")
        return false
    end

    local ok, err =
        pcall(function()

            if makefolder
            and not isfolder("HolyV2") then
                makefolder("HolyV2")
            end

            local payload = {
                Version = 1,
                Filters = SerializeListingFilters(),
            }

            writefile(
                LISTING_FILTER_SAVE_FILE,
                HttpService:JSONEncode(payload)
            )
        end)

    if not ok then

        warn(
            "[LISTINGS FILTERS] Save failed:",
            tostring(err)
        )

        return false
    end

    print(
        "[LISTINGS FILTERS] Saved:",
        tostring(
            ListingsState.ListingFilters
            and #ListingsState.ListingFilters
            or 0
        )
    )

    return true
end

function LoadListingFilters()

    if not isfile
    or not readfile then
        warn("[LISTINGS FILTERS] file API unsupported")
        return false
    end

    if not isfile(LISTING_FILTER_SAVE_FILE) then
        print("[LISTINGS FILTERS] No existing save")
        return false
    end

    local ok, decoded =
        pcall(function()

            local raw =
                readfile(LISTING_FILTER_SAVE_FILE)

            return HttpService:JSONDecode(raw)
        end)

    if not ok
    or type(decoded) ~= "table" then

        warn("[LISTINGS FILTERS] Corrupted save")

        if delfile then
            pcall(function()
                delfile(LISTING_FILTER_SAVE_FILE)
            end)
        end

        return false
    end

    local source =
        decoded.Filters

    if type(source) ~= "table" then
        source =
            decoded
    end

    ListingsState.ListingFilters =
        ListingsState.ListingFilters
        or {}

    table.clear(
        ListingsState.ListingFilters
    )

    for _, filter in ipairs(source) do

        if type(filter) == "table" then

            local restored = {
                Pet =
                    tostring(filter.Pet or ""),

                Mutation =
    NormalizeListingFilterMutation(
        filter.Mutation
    ),

ExcludedMutations =
    DeserializeListingMutationMap(
        filter.ExcludedMutations
    ),

MinLevel =
    tonumber(filter.MinLevel)
    or 1,

MaxLevel =
    tonumber(filter.MaxLevel)
    or 100,

MinWeight =
    tonumber(filter.MinWeight),

                MaxWeight =
                    tonumber(filter.MaxWeight),

                Price =
                    tonumber(filter.Price),

                Enabled =
                    filter.Enabled ~= false,
            }

            local valid =
                true

            if restored.Pet == "" then
                valid =
                    false
            end

            if not restored.MinWeight
            or not restored.MaxWeight
            or not restored.Price then
                valid =
                    false
            end

            if not restored.MinLevel
or not restored.MaxLevel
or restored.MaxLevel < restored.MinLevel then
    valid =
        false
end

            if restored.MinWeight
            and restored.MaxWeight
            and restored.MaxWeight < restored.MinWeight then
                valid =
                    false
            end

            if valid then

                table.insert(
                    ListingsState.ListingFilters,
                    restored
                )
            end
        end
    end

    ListingsState.ListingFilterUI =
        ListingsState.ListingFilterUI
        or {
            Page = 1,
            PerPage = 8,
        }

    ListingsState.ListingFilterUI.Page =
        1

    print(
    "[LISTINGS FILTERS] Loaded:",
    tostring(#ListingsState.ListingFilters)
)

return true
end

--==================================================
-- LISTINGS: AUTOLIST INTENT PERSISTENCE
-- Source of truth for whether AutoList should restore ON.
-- This does not depend on Obsidian option timing.
--==================================================

function SaveListingAutoListIntent(enabled)

    if not writefile then
        return false
    end

    local ok, err =
        pcall(function()

            if makefolder
            and not isfolder("HolyV2") then
                makefolder("HolyV2")
            end

            local payload = {
                Version = 1,
                Enabled = enabled == true,
                SavedAt = os.time(),
            }

            writefile(
                LISTING_AUTOLIST_INTENT_SAVE_FILE,
                HttpService:JSONEncode(payload)
            )
        end)

    if not ok then

        warn(
            "[LISTINGS INTENT] Save failed:",
            tostring(err)
        )

        return false
    end

    print(
        "[LISTINGS INTENT] Saved AutoList:",
        tostring(enabled == true)
    )

    return true
end

function LoadListingAutoListIntent()

    if not isfile
    or not readfile then
        return nil
    end

    if not isfile(LISTING_AUTOLIST_INTENT_SAVE_FILE) then
        return nil
    end

    local ok, decoded =
        pcall(function()

            local raw =
                readfile(LISTING_AUTOLIST_INTENT_SAVE_FILE)

            return HttpService:JSONDecode(raw)
        end)

    if not ok
    or type(decoded) ~= "table" then
        warn("[LISTINGS INTENT] Failed to load intent")
        return nil
    end

    return decoded.Enabled == true
end
--==================================================
-- [5] WINDOW INIT (SYNCHRONOUS)
--==================================================
Window = Library:CreateWindow({
    Title = "HOLY",
    Footer = "private build • made by ben",
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.LeftAlt,
})
--==================================================
-- HOLY PREMIUM BRAND PATCH
-- Searches PlayerGui, CoreGui, and gethui() because
-- executor/Obsidian UIs are often not parented to PlayerGui.
--==================================================

HolyBrandStyleState = {
    Passes = 0,
}

local HolyBrandGradientColors =
    ColorSequence.new({
        ColorSequenceKeypoint.new(
            0,
            Color3.fromRGB(255, 218, 120)
        ),

        ColorSequenceKeypoint.new(
            0.45,
            Color3.fromRGB(255, 120, 185)
        ),

        ColorSequenceKeypoint.new(
            1,
            Color3.fromRGB(155, 105, 255)
        ),
    })

local function HolyTrimText(value)

    return tostring(value or "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

local function IsHolyBrandText(value)

    value =
        HolyTrimText(value)

    return value == "Holy"
        or value == "HOLY"
        or value == "HOLY"
end

local function GetHolyGuiRoots()

    local roots = {}

    local player =
        Players.LocalPlayer

    if player then

        local playerGui =
            player:FindFirstChild("PlayerGui")

        if playerGui then
            table.insert(roots, playerGui)
        end
    end

    local okCoreGui, coreGui =
        pcall(function()
            return game:GetService("CoreGui")
        end)

    if okCoreGui
    and coreGui then
        table.insert(roots, coreGui)
    end

    if type(gethui) == "function" then

        local okHui, hui =
            pcall(function()
                return gethui()
            end)

        if okHui
        and hui then
            table.insert(roots, hui)
        end
    end

    return roots
end

function StyleHolyBrandObject(obj)

    if not obj then
        return false
    end

    if not obj:IsA("TextLabel")
    and not obj:IsA("TextButton") then
        return false
    end

    if not IsHolyBrandText(obj.Text) then
        return false
    end

    obj.Text =
        "HOLY"

    obj.Font =
        Enum.Font.GothamBlack

    obj.TextColor3 =
        Color3.fromRGB(255, 235, 170)

    obj.TextStrokeColor3 =
        Color3.fromRGB(10, 5, 20)

    obj.TextStrokeTransparency =
        0

    obj.RichText =
        false

    obj.TextXAlignment =
        Enum.TextXAlignment.Center

    if obj.TextSize < 17 then
        obj.TextSize =
            math.clamp(
                obj.TextSize + 2,
                15,
                20
            )
    end

    local gradient =
        obj:FindFirstChild("HolyPremiumGradient")

    if not gradient then

        gradient =
            Instance.new("UIGradient")

        gradient.Name =
            "HolyPremiumGradient"

        gradient.Parent =
            obj
    end

    gradient.Color =
        HolyBrandGradientColors

    gradient.Rotation =
        0

    local stroke =
        obj:FindFirstChild("HolyPremiumStroke")

    if not stroke then

        stroke =
            Instance.new("UIStroke")

        stroke.Name =
            "HolyPremiumStroke"

        stroke.ApplyStrokeMode =
            Enum.ApplyStrokeMode.Contextual

        stroke.Parent =
            obj
    end

    stroke.Color =
        Color3.fromRGB(150, 75, 255)

    stroke.Thickness =
        1.5

    stroke.Transparency =
        0.12

    if obj:IsA("TextButton") then

        obj.AutoButtonColor =
            true

        obj.BackgroundColor3 =
            Color3.fromRGB(12, 8, 24)

        obj.BackgroundTransparency =
            0.02

        local corner =
            obj:FindFirstChild("HolyPremiumCorner")

        if not corner then

            corner =
                Instance.new("UICorner")

            corner.Name =
                "HolyPremiumCorner"

                corner.Parent =
                    obj
        end

        corner.CornerRadius =
            UDim.new(0, 8)
    end

    obj:SetAttribute(
        "HolyPremiumStyled",
        true
    )

    return true
end

function StyleHolyToggleText()

    local styled =
        0

    for _, root in ipairs(GetHolyGuiRoots()) do

        for _, obj in ipairs(root:GetDescendants()) do

            if StyleHolyBrandObject(obj) then
                styled += 1
            end
        end
    end

    return styled
end

task.spawn(function()

    local styled =
        0

    -- Give Obsidian/executor UI time to fully create.
    for i = 1, 40 do

        pcall(function()
            styled =
                StyleHolyToggleText()
        end)

        if styled > 0 then
            break
        end

        task.wait(0.25)
    end

    -- One delayed final pass in case the toggle/title refreshes once after init.
    task.wait(2)

    pcall(function()
        StyleHolyToggleText()
    end)
end)
HolyLoading:SetCurrentStep(2)
HolyLoading:SetDescription("Creating Obsidian window...")
--==================================================
-- [6] TABS (EMPTY STRUCTURE)
--==================================================
Tabs = {
    Home = Window:AddTab({
        Name = "Home",
        Icon = "house",
        Description = "Runtime controls, inventory safety, and quick server actions.",
    }),

    Sniper = Window:AddTab({
        Name = "Sniper",
        Icon = "crosshair",
        Description = "Pet filters, watchlists, egg focus, server hopping, and purchase safety.",
    }),

    Booth = Window:AddTab({
        Name = "Booth",
        Icon = "store",
        Description = "Booth claiming, teleporting, skins, and listing promotion.",
    }),

    Listings = Window:AddTab({
        Name = "Listings",
        Icon = "tag",
        Description = "Auto-list inventory pets with price, mutation, and weight filters.",
    }),

    Events = Window:AddTab({
        Name = "Events",
        Icon = "calendar",
        Description = "Event shop automation and limited-time systems.",
    }),

    Visuals = Window:AddTab({
        Name = "Visuals",
        Icon = "eye",
        Description = "HUDs, overlays, and client-side visual tools.",
    }),

    Webhook = Window:AddTab({
        Name = "Webhook",
        Icon = "link",
        Description = "Personal and global Discord webhook delivery settings.",
    }),

    Settings = Window:AddTab({
        Name = "Settings",
        Icon = "settings",
        Description = "UI scale, performance, reconnect, and developer tools.",
    }),
}

print(
    "[TAB TEST]",
    "AddLeftGroupbox:",
    tostring(type(Tabs.Visuals.AddLeftGroupbox)),
    "| AddLeftCollapsibleGroupbox:",
    tostring(type(Tabs.Visuals.AddLeftCollapsibleGroupbox))
)

--==================================================
-- GARDEN MODE PLACEHOLDERS
-- Tabs stay visible and in the original order.
-- Real Trade World systems are not built in Garden.
--==================================================

function AddGardenModePlaceholder(tab, title, icon)

    if not tab then
        return
    end

    local box

    if type(tab.AddLeftCollapsibleGroupbox) == "function" then

        box =
            tab:AddLeftCollapsibleGroupbox(
                title,
                icon or "lock",
                true
            )

    else

        box =
            tab:AddLeftGroupbox(
                title,
                icon or "lock"
            )
    end

    box:AddLabel(
        "🌱 Garden Mode",
        false
    )

    box:AddLabel(
        "This system only works in Trade World.",
        true
    )

    box:AddButton({
        Text = "🌐 Join Trade World",
        Tooltip = "Teleport to Grow a Garden Trade World.",
        Func = function()

            RequestJoinTradeWorld(
                "Manual Trade World join requested."
            )
        end,
    })
end

function BuildGardenModeTradeTabs()

    AddGardenModePlaceholder(
        Tabs.Sniper,
        "Sniper",
        "crosshair"
    )

    AddGardenModePlaceholder(
        Tabs.Booth,
        "Booth",
        "store"
    )

    AddGardenModePlaceholder(
        Tabs.Listings,
        "Listings",
        "tag"
    )

    if not EventsBox then

        AddGardenModePlaceholder(
            Tabs.Events,
            "Events",
            "calendar"
        )
    end
end

HolyLoading:SetCurrentStep(3)
HolyLoading:SetDescription("Building tabs...")
--==================================================
-- EVENTS TAB
-- Trade World only.
-- Garden Mode gets a placeholder from BuildGardenModeTradeTabs().
--==================================================

EventsBox = nil

if IsTradeWorld() then

    if type(Tabs.Events.AddLeftCollapsibleGroupbox) == "function" then

        EventsBox =
            Tabs.Events:AddLeftCollapsibleGroupbox(
                "Events",
                "calendar",
                true
            )

    else

        warn("[LIB TEST] Collapsible Events unavailable, using normal groupbox")

        EventsBox =
            Tabs.Events:AddLeftGroupbox(
                "Events",
                "calendar"
            )
    end
end
--==================================================
-- VISUAL TAB
--==================================================
CreateWatchlistHUD = nil
RefreshWatchlistHUD = nil

CreateServerInfoHUD = nil
RefreshServerInfoHUD = nil

CreateSniperMonitorHUD = nil
RefreshSniperMonitorHUD = nil

WatchlistHUDGui = nil
WatchlistHUDFrame = nil
WatchlistHUDContainer = nil

ServerInfoHUDGui = nil
ServerInfoHUDFrame = nil
ServerInfoVersionLabel = nil
ServerInfoSessionLabel = nil

SniperMonitorHUDGui = nil
SniperMonitorHUDFrame = nil
SniperMonitorStatusLabel = nil
SniperMonitorScannedLabel = nil
SniperMonitorHopLabel = nil
SniperMonitorPingLabel = nil
SniperMonitorBuyWaitLabel = nil

InventoryDetailsLabel = nil
InventoryDetailsStatusLabel = nil
RefreshInventoryDetails = nil

function BuildVisualTab()

    local VisualBox

if type(Tabs.Visuals.AddLeftCollapsibleGroupbox) == "function" then

    VisualBox =
        Tabs.Visuals:AddLeftCollapsibleGroupbox(
            "Visual Settings",
            "eye",
            false
        )

else

    warn("[LIB TEST] Collapsible groupbox unavailable, using normal groupbox")

    VisualBox =
        Tabs.Visuals:AddLeftGroupbox(
            "Visual Settings",
            "eye"
        )
end

local WatchlistHUDToggle =
    VisualBox:AddToggle(
        "WatchlistHUD",
        {
            Text = "🔫 Sniper Watchlist HUD",
            Default = false,
        }
    )

WatchlistHUDToggle:OnChanged(function(v)

    VisualState.WatchlistHUD = v

    MarkConfigDirty()

    if not WatchlistHUDGui then
        if type(CreateWatchlistHUD) == "function" then
            CreateWatchlistHUD()
        end
    end

    if WatchlistHUDGui then
        WatchlistHUDGui.Enabled = v
    end

    if WatchlistHUDFrame then
        WatchlistHUDFrame.Visible = v
    end

    if v
    and type(RefreshWatchlistHUD) == "function" then
        RefreshWatchlistHUD()
    end
end)

local ShowWatchlist1HUDToggle =
    VisualBox:AddToggle(
        "ShowWatchlist1HUD",
        {
            Text = "Show Watchlist 1",
            Default = true,
        }
    )

ShowWatchlist1HUDToggle:OnChanged(function(v)

    VisualState.ShowWatchlist1HUD =
        v == true

    MarkConfigDirty()

    if type(RefreshWatchlistHUD) == "function" then
        RefreshWatchlistHUD()
    end
end)

local ShowWatchlist2HUDToggle =
    VisualBox:AddToggle(
        "ShowWatchlist2HUD",
        {
            Text = "Show Watchlist 2",
            Default = true,
        }
    )

ShowWatchlist2HUDToggle:OnChanged(function(v)

    VisualState.ShowWatchlist2HUD =
        v == true

    MarkConfigDirty()

    if type(RefreshWatchlistHUD) == "function" then
        RefreshWatchlistHUD()
    end
end)

local ServerInfoHUDToggle =
    VisualBox:AddToggle(
        "ServerInfoHUD",
        {
            Text = "🖥️ Server Info HUD",
            Default = false,
        }
    )

ServerInfoHUDToggle:OnChanged(function(v)

    VisualState.ServerInfoHUD = v

    MarkConfigDirty()

    if not ServerInfoHUDGui then
        CreateServerInfoHUD()
    end

    if ServerInfoHUDGui then
        ServerInfoHUDGui.Enabled = v
    end

    if ServerInfoHUDFrame then
        ServerInfoHUDFrame.Visible = v
    end

    if v then
        RefreshServerInfoHUD()
    end
end)

local SniperMonitorHUDToggle =
    VisualBox:AddToggle(
        "SniperMonitorHUD",
        {
            Text = "🎯 Sniper Monitor HUD",
            Default = false,
        }
    )

SniperMonitorHUDToggle:OnChanged(function(v)

    VisualState.SniperMonitorHUD = v

    MarkConfigDirty()

    if not SniperMonitorHUDGui then
        CreateSniperMonitorHUD()
    end

    if SniperMonitorHUDGui then
        SniperMonitorHUDGui.Enabled = v
    end

    if SniperMonitorHUDFrame then
        SniperMonitorHUDFrame.Visible = v
    end

    if v then
        RefreshSniperMonitorHUD()
    end
end)


--==================================================
-- ACTIVE WATCHLIST HUD
--==================================================


--==================================================
-- SERVER INFO HUD STATE
--==================================================

CreateWatchlistHUD = function()

    if WatchlistHUDGui then
        return
    end

    local playerGui =
        Players.LocalPlayer:WaitForChild("PlayerGui")

    local screenGui =
        Instance.new("ScreenGui")

    screenGui.Name =
        "HolyWatchlistHUD"

    screenGui.ResetOnSpawn =
        false

    screenGui.IgnoreGuiInset =
        true

    screenGui.Enabled =
        VisualState.WatchlistHUD

    screenGui.Parent =
        playerGui

    WatchlistHUDGui =
        screenGui

    --==================================================
    -- RIGHT SIDE PANEL
    -- Full-height clean HOLY HUD.
    --==================================================

    local frame =
        Instance.new("Frame")

    frame.Name =
        "Frame"

    frame.BackgroundTransparency =
        1

    frame.AnchorPoint =
        Vector2.new(1, 0)

    frame.Position =
        UDim2.new(1, -12, 0, 48)

        frame.Size =
        UDim2.new(0, 360, 1, -70)

    frame.Visible =
        VisualState.WatchlistHUD == true

    frame.Parent =
        screenGui

    WatchlistHUDFrame =
        frame

    --==================================================
    -- HOLY TITLE
    --==================================================

    local title =
        Instance.new("TextLabel")

    title.Name =
        "Title"

    title.BackgroundTransparency =
        1

    title.Position =
        UDim2.new(0, 0, 0, 0)

    title.Size =
        UDim2.new(1, 0, 0, 20)

    title.Font =
        Enum.Font.GothamBlack

    title.Text =
        "HOLY WATCHLIST"

    title.TextSize =
        14

    title.TextColor3 =
        Color3.fromRGB(235, 245, 255)

    title.TextStrokeTransparency =
        0.25

    title.TextStrokeColor3 =
        Color3.fromRGB(0, 0, 0)

    title.TextXAlignment =
        Enum.TextXAlignment.Right

    title.Parent =
        frame

    local underline =
        Instance.new("TextLabel")

    underline.Name =
        "Underline"

    underline.BackgroundTransparency =
        1

    underline.Position =
        UDim2.new(0, 0, 0, 17)

    underline.Size =
        UDim2.new(1, 0, 0, 12)

    underline.Font =
        Enum.Font.GothamBold

    underline.Text =
        "━━━━━━━━━━━━━━━━━━━━"

    underline.TextSize =
        9

    underline.TextColor3 =
        Color3.fromRGB(170, 205, 255)

    underline.TextStrokeTransparency =
        0.45

    underline.TextStrokeColor3 =
        Color3.fromRGB(0, 0, 0)

    underline.TextXAlignment =
        Enum.TextXAlignment.Right

    underline.Parent =
        frame

    --==================================================
    -- LIST HOLDER
    --==================================================

    local list =
        Instance.new("Frame")

    list.Name =
        "List"

    list.BackgroundTransparency =
        1

    list.Position =
        UDim2.new(0, 0, 0, 32)

    list.Size =
        UDim2.new(1, 0, 1, -32)

    list.Parent =
        frame

    WatchlistHUDContainer =
        list

    local layout =
        Instance.new("UIListLayout")

    layout.HorizontalAlignment =
        Enum.HorizontalAlignment.Right

    layout.SortOrder =
        Enum.SortOrder.LayoutOrder

    layout.Padding =
        UDim.new(0, 0)

    layout.Parent =
        list
end
--==================================================
-- SERVER INFO HUD
-- Shows only server version + session time
--==================================================

local function FormatServerInfoSessionTime(seconds)

    seconds =
        math.max(
            0,
            math.floor(seconds)
        )

    local hours =
        math.floor(seconds / 3600)

    local minutes =
        math.floor((seconds % 3600) / 60)

    local secs =
        seconds % 60

    if hours > 0 then
        return string.format(
            "%dh %02dm %02ds",
            hours,
            minutes,
            secs
        )
    end

    return string.format(
        "%dm %02ds",
        minutes,
        secs
    )
end

local function FindServerVersionText()

    local playerGui =
        Players.LocalPlayer:FindFirstChild("PlayerGui")

    if not playerGui then
        return "Server Version: Unknown"
    end

    local versionUI =
        playerGui:FindFirstChild("Version_UI")

    if not versionUI then
        return "Server Version: Unknown"
    end

    local versionLabel =
        versionUI:FindFirstChild("Version")

    if not versionLabel
    or not versionLabel:IsA("TextLabel") then
        return "Server Version: Unknown"
    end

    local text =
        tostring(versionLabel.Text or "")

    if text == "" then
        return "Server Version: Unknown"
    end

    -- Handles both:
    -- "1.09.0"
    -- "Server Version: 1.09.0"
    if string.lower(text):find("server version", 1, true) then
        return text
    end

    return "Server Version: " .. text
end

CreateServerInfoHUD = function()

    if ServerInfoHUDGui then
        return
    end

    local playerGui =
        Players.LocalPlayer:WaitForChild("PlayerGui")

    local screenGui =
        Instance.new("ScreenGui")

    screenGui.Name = "HolyServerInfoHUD"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Enabled = VisualState.ServerInfoHUD
    screenGui.Parent = playerGui

    ServerInfoHUDGui = screenGui

    local frame =
        Instance.new("Frame")

    frame.Name = "Frame"
    frame.BackgroundTransparency = 1
    frame.AnchorPoint = Vector2.new(0, 0)
    frame.Position = UDim2.new(0, 12, 0.18, 0)
    frame.Size = UDim2.new(0, 240, 0, 38)
    frame.Parent = screenGui

    ServerInfoHUDFrame = frame

    local versionLabel =
        Instance.new("TextLabel")

    versionLabel.Name = "ServerVersion"
    versionLabel.BackgroundTransparency = 1
    versionLabel.Position = UDim2.new(0, 0, 0, 0)
    versionLabel.Size = UDim2.new(1, 0, 0, 24)
    versionLabel.Font = Enum.Font.GothamBold
    versionLabel.TextSize = 12
    versionLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
    versionLabel.TextStrokeTransparency = 0.35
    versionLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.Text = "Server Version: Unknown"
    versionLabel.Parent = frame

    ServerInfoVersionLabel = versionLabel

    local sessionLabel =
        Instance.new("TextLabel")

    sessionLabel.Name = "SessionTime"
    sessionLabel.BackgroundTransparency = 1
    sessionLabel.Position = UDim2.new(0, 0, 0, 17)
    sessionLabel.Size = UDim2.new(1, 0, 0, 17)
    sessionLabel.Font = Enum.Font.GothamBold
    sessionLabel.TextSize = 12
    sessionLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
    sessionLabel.TextStrokeTransparency = 0.35
    sessionLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    sessionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sessionLabel.Text = "SessionTime: 0m 00s"
    sessionLabel.Parent = frame

    ServerInfoSessionLabel = sessionLabel
end

RefreshServerInfoHUD = function()

    if not ServerInfoHUDGui then
        return
    end

    if not VisualState.ServerInfoHUD then
        return
    end

    if ServerInfoVersionLabel then
        ServerInfoVersionLabel.Text =
            FindServerVersionText()
    end

    if ServerInfoSessionLabel then
        ServerInfoSessionLabel.Text =
            "SessionTime: "
            .. FormatServerInfoSessionTime(
                SafeElapsed(ServerInfoStartedAt)
            )
    end
end

--==================================================
-- SNIPER MONITOR HUD
-- Shows sniper status, scanned pets, and next hop timer
--==================================================

local function FormatSniperMonitorTime(seconds)

    seconds =
        math.max(
            0,
            tonumber(seconds) or 0
        )

    if seconds >= 60 then
        local minutes =
            math.floor(seconds / 60)

        local secs =
            math.floor(seconds % 60)

        return string.format(
            "%dm %02ds",
            minutes,
            secs
        )
    end

    return string.format(
        "%.1fs",
        seconds
    )
end

local function ResolveSniperMonitorStatus()

    if ScriptState.ForceStopped then
        return "Stopped"
    end

    if SniperState.Hopping then
        return "Hopping"
    end

    if PurchaseState
    and PurchaseState.Busy then
        return "Buying"
    end

    if RuntimeState.Started then
        return "Active"
    end

    return "Idle"
end

local function ResolveSniperMonitorHopText()

    if not SniperState.AutoHop then
        return "Off"
    end

    if not RuntimeState.Started then
        return "Paused"
    end

    if SniperState.Hopping then
        return "Now"
    end

    SniperState.ScanStartedAt =
        SafeNumber(SniperState.ScanStartedAt, os.clock())

    SniperState.ScanDuration =
        SafeNumber(SniperState.ScanDuration, 10)

    local elapsed =
        SafeElapsed(SniperState.ScanStartedAt)

    local remaining =
        SniperState.ScanDuration
        - elapsed

    return FormatSniperMonitorTime(
        remaining
    )
end

CreateSniperMonitorHUD = function()

    if SniperMonitorHUDGui then
        return
    end

    local playerGui =
        Players.LocalPlayer:WaitForChild("PlayerGui")

    local screenGui =
        Instance.new("ScreenGui")

    screenGui.Name = "HolySniperMonitorHUD"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Enabled = VisualState.SniperMonitorHUD
    screenGui.Parent = playerGui

    SniperMonitorHUDGui = screenGui

    local frame =
        Instance.new("Frame")

    frame.Name = "Frame"
    frame.BackgroundTransparency = 1
    frame.AnchorPoint = Vector2.new(0, 0)
    frame.Position = UDim2.new(0, 12, 0.26, 0)
    frame.Size = UDim2.new(0, 260, 0, 104)
    frame.Parent = screenGui

    SniperMonitorHUDFrame = frame

    local title =
        Instance.new("TextLabel")

    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Size = UDim2.new(1, 0, 0, 18)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = Color3.fromRGB(220, 0, 0)
    title.TextStrokeTransparency = 0.35
    title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "SNIPER MONITOR"
    title.Parent = frame

    local statusLabel =
        Instance.new("TextLabel")

    statusLabel.Name = "Status"
    statusLabel.BackgroundTransparency = 1
    statusLabel.Position = UDim2.new(0, 0, 0, 18)
    statusLabel.Size = UDim2.new(1, 0, 0, 16)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 12
    statusLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
    statusLabel.TextStrokeTransparency = 0.35
    statusLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Text = "Status: Idle"
    statusLabel.Parent = frame

    SniperMonitorStatusLabel = statusLabel

    local scannedLabel =
        Instance.new("TextLabel")

    scannedLabel.Name = "PetsScanned"
    scannedLabel.BackgroundTransparency = 1
    scannedLabel.Position = UDim2.new(0, 0, 0, 34)
    scannedLabel.Size = UDim2.new(1, 0, 0, 16)
    scannedLabel.Font = Enum.Font.GothamBold
    scannedLabel.TextSize = 12
    scannedLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
    scannedLabel.TextStrokeTransparency = 0.35
    scannedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    scannedLabel.TextXAlignment = Enum.TextXAlignment.Left
    scannedLabel.Text = "Pets Scanned: 0"
    scannedLabel.Parent = frame

    SniperMonitorScannedLabel = scannedLabel

    local hopLabel =
        Instance.new("TextLabel")

    hopLabel.Name = "NextHop"
    hopLabel.BackgroundTransparency = 1
    hopLabel.Position = UDim2.new(0, 0, 0, 50)
    hopLabel.Size = UDim2.new(1, 0, 0, 16)
    hopLabel.Font = Enum.Font.GothamBold
    hopLabel.TextSize = 12
    hopLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
    hopLabel.TextStrokeTransparency = 0.35
    hopLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    hopLabel.TextXAlignment = Enum.TextXAlignment.Left
    hopLabel.Text = "Next Hop: Off"
    hopLabel.Parent = frame

        SniperMonitorHopLabel = hopLabel

    local pingLabel =
        Instance.new("TextLabel")

    pingLabel.Name = "Ping"
    pingLabel.BackgroundTransparency = 1
    pingLabel.Position = UDim2.new(0, 0, 0, 66)
    pingLabel.Size = UDim2.new(1, 0, 0, 16)
    pingLabel.Font = Enum.Font.GothamBold
    pingLabel.TextSize = 12
    pingLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
    pingLabel.TextStrokeTransparency = 0.35
    pingLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.Text = "Ping: Unknown"
    pingLabel.Parent = frame

    SniperMonitorPingLabel = pingLabel

    local buyWaitLabel =
        Instance.new("TextLabel")

    buyWaitLabel.Name = "BuyWait"
    buyWaitLabel.BackgroundTransparency = 1
    buyWaitLabel.Position = UDim2.new(0, 0, 0, 82)
    buyWaitLabel.Size = UDim2.new(1, 0, 0, 16)
    buyWaitLabel.Font = Enum.Font.GothamBold
    buyWaitLabel.TextSize = 12
    buyWaitLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
    buyWaitLabel.TextStrokeTransparency = 0.35
    buyWaitLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    buyWaitLabel.TextXAlignment = Enum.TextXAlignment.Left
    buyWaitLabel.Text = "Buy Wait: 10s"
    buyWaitLabel.Visible =
        LatencyGuard
        and LatencyGuard.AdaptiveBuyWait == true

    buyWaitLabel.Parent = frame

    SniperMonitorBuyWaitLabel = buyWaitLabel
end

RefreshSniperMonitorHUD = function()

    if not SniperMonitorHUDGui then
        return
    end

    if not VisualState.SniperMonitorHUD then
        return
    end

    if SniperMonitorStatusLabel then
        SniperMonitorStatusLabel.Text =
            "Status: "
            .. ResolveSniperMonitorStatus()
    end

    if SniperMonitorScannedLabel then
        SniperMonitorScannedLabel.Text =
            "Pets Scanned: "
            .. tostring(SniperMonitorState.PetsScanned)
    end

        if SniperMonitorHopLabel then
        SniperMonitorHopLabel.Text =
            "Next Hop: "
            .. ResolveSniperMonitorHopText()
    end

    if SniperMonitorPingLabel then
        SniperMonitorPingLabel.Text =
            FormatLatencyGuardPingText()
    end

    if SniperMonitorBuyWaitLabel then

        local adaptiveEnabled =
            LatencyGuard
            and LatencyGuard.AdaptiveBuyWait == true

        SniperMonitorBuyWaitLabel.Visible =
            adaptiveEnabled

        if adaptiveEnabled then
            SniperMonitorBuyWaitLabel.Text =
                FormatLatencyGuardBuyWaitText()
        end
    end
end

end
--==================================================
-- [7] BASIC UI (CONTROL ONLY)
--==================================================

GatewayBusy = false

function BuildHomeTab()

local HomeBox

if type(Tabs.Home.AddLeftCollapsibleGroupbox) == "function" then

    HomeBox =
        Tabs.Home:AddLeftCollapsibleGroupbox(
            "Sniper Control",
            "crosshair",
            true
        )

else

    warn("[LIB TEST] Collapsible Sniper Control unavailable, using normal groupbox")

    HomeBox =
        Tabs.Home:AddLeftGroupbox(
            "Sniper Control",
            "crosshair"
        )
end

local DetailsBox

if type(Tabs.Home.AddRightCollapsibleGroupbox) == "function" then

    DetailsBox =
        Tabs.Home:AddRightCollapsibleGroupbox(
            "Details",
            "info",
            true
        )

else

    warn("[LIB TEST] Collapsible Details unavailable, using normal groupbox")

    DetailsBox =
        Tabs.Home:AddRightGroupbox(
            "Details",
            "info"
        )
end

--==================================================
-- DETAILS: INVENTORY TRACKER
--==================================================

InventoryDetailsLabel =
    DetailsBox:AddLabel(
        "📦 Pet Inventory: checking...",
        false
    )

InventoryDetailsStatusLabel =
    DetailsBox:AddLabel(
        "Status: waiting",
        false
    )

RefreshInventoryDetails = function()

    if not InventoryDetailsLabel
    or not InventoryDetailsStatusLabel then
        return
    end

    local currentPets =
        0

    if type(CountVisiblePetTools) == "function" then
        currentPets =
            CountVisiblePetTools()
    end

    local maxPets =
        tonumber(SniperState.MaxPetInventory)
        or 0

    local safetyEnabled =
        SniperState.StopAtPetInventoryLimit == true

    local inventoryText

    if maxPets > 0 then
        inventoryText =
            "📦 Pet Inventory: "
            .. tostring(currentPets)
            .. " / "
            .. tostring(maxPets)
    else
        inventoryText =
            "📦 Pet Inventory: "
            .. tostring(currentPets)
    end

    InventoryDetailsLabel:SetText(
        inventoryText
    )

    local statusText

    if not safetyEnabled then

        statusText =
            "Status: safety off"

    elseif maxPets <= 0 then

        statusText =
            "Status: no limit set"

    elseif currentPets >= maxPets then

        statusText =
            "Status: limit reached"

    else

        local remaining =
            maxPets - currentPets

        statusText =
            "Status: safe • "
            .. tostring(remaining)
            .. " slots left"
    end

    InventoryDetailsStatusLabel:SetText(
        statusText
    )
end

RefreshInventoryDetails()

task.spawn(function()

    while IsCurrentRun() do

        if type(RefreshInventoryDetails) == "function" then
            pcall(RefreshInventoryDetails)
        end

        task.wait(1)
    end
end)
--==================================================
-- SERVER GATEWAY
--==================================================

local LastServer = {
    Mode = "PublicInstance",
    PlaceId = game.PlaceId,
    JobId = game.JobId,
    Code = nil,
}

GatewayBusy = false

local GatewayBox

if type(Tabs.Home.AddLeftCollapsibleGroupbox) == "function" then

    GatewayBox =
        Tabs.Home:AddLeftCollapsibleGroupbox(
            "Join Server (Manual)",
            "radio",
            false
        )

else

    warn("[LIB TEST] Collapsible Gateway unavailable, using normal groupbox")

    GatewayBox =
        Tabs.Home:AddLeftGroupbox(
            "Join Server (Manual)",
            "radio"
        )
end

--==================================================
-- SESSION INFO
--==================================================



--==================================================
-- STATUS LABEL
--==================================================

local GatewayStatus = GatewayBox:AddLabel(
    "Gateway • Idle"
)

local function SetGatewayStatus(text)
    GatewayStatus:SetText(
        "Gateway • " .. tostring(text)
    )
end

--==================================================
-- INPUT
--==================================================

local GatewayInput = GatewayBox:AddInput("GatewayInput", {
    Text = "Target Server",
    Placeholder = "placeId:jobId or roblox://",
    Numeric = false,
    Finished = false,
})

--==================================================
-- PARSER
--==================================================

local function UrlDecode(value)

    value =
        tostring(value or "")

    value =
        value:gsub("+", " ")

    value =
        value:gsub("%%(%x%x)", function(hex)

            return string.char(
                tonumber(hex, 16)
            )
        end)

    return value
end

local function ParseServerInput(text)

    if not text
    or text == "" then
        return nil
    end

    local raw =
        tostring(text)

    local compact =
        raw:gsub("%s+", "")

    if compact == "" then
        return nil
    end

    --==================================================
    -- ROBLOX WEB SHARE PRIVATE SERVER LINK
    -- Example:
    -- https://www.roblox.com/share?code=xxxx&type=Server
    --==================================================

    local shareCode =
        compact:match("[?&]code=([^&]+)")

    local shareType =
        compact:match("[?&]type=([^&]+)")

    if shareCode
    and (
        not shareType
        or tostring(shareType):lower() == "server"
    ) then

        return {
            Mode = "PrivateLink",
            PlaceId = TRADING_WORLD_PLACE_ID,
            Code = UrlDecode(shareCode),
        }
    end

    --==================================================
    -- ROBLOX APP / DEEP LINK PRIVATE SERVER
    -- Example:
    -- roblox://experiences/start?placeId=123&linkCode=xxxx
    --==================================================

    local deepPlaceId =
        compact:match("placeId=(%d+)")

    local linkCode =
        compact:match("[?&]linkCode=([^&]+)")
        or compact:match("[?&]privateServerLinkCode=([^&]+)")

    if linkCode then

        return {
            Mode = "PrivateLink",
            PlaceId = tonumber(deepPlaceId) or TRADING_WORLD_PLACE_ID,
            Code = UrlDecode(linkCode),
        }
    end

    --==================================================
    -- ROBLOX APP / DEEP LINK PUBLIC INSTANCE
    -- Example:
    -- roblox://experiences/start?placeId=123&gameInstanceId=xxxx
    --==================================================

    local placeId, jobId =
        compact:match(
            "placeId=(%d+).-[%&%?]gameInstanceId=([%w%-]+)"
        )

    if placeId
    and jobId then

        return {
            Mode = "PublicInstance",
            PlaceId = tonumber(placeId),
            JobId = jobId,
        }
    end

    --==================================================
    -- placeId:jobId
    --==================================================

    placeId, jobId =
        compact:match(
            "^(%d+):([%w%-]+)$"
        )

    if placeId
    and jobId then

        return {
            Mode = "PublicInstance",
            PlaceId = tonumber(placeId),
            JobId = jobId,
        }
    end

    --==================================================
    -- RAW PUBLIC JOB ID
    --==================================================

    if compact:match("^[%w%-]+$")
    and #compact >= 30 then

        return {
            Mode = "PublicInstance",
            PlaceId = TRADING_WORLD_PLACE_ID,
            JobId = compact,
        }
    end

    --==================================================
    -- RAW PRIVATE SERVER SHARE CODE
    -- Example:
    -- e4ee60eb4af7a243b82dfb576bc75cdc
    --==================================================

    if compact:match("^[%w%-_]+$")
    and #compact >= 16
    and #compact < 80 then

        return {
            Mode = "PrivateLink",
            PlaceId = TRADING_WORLD_PLACE_ID,
            Code = compact,
        }
    end

    return nil
end

--==================================================
-- LIVE VALIDATION
--==================================================

GatewayInput:OnChanged(function(text)

    local parsed =
        ParseServerInput(text)

    if not parsed then
        SetGatewayStatus("Invalid input")
        return
    end

    if parsed.PlaceId ~= TRADING_WORLD_PLACE_ID then
        SetGatewayStatus("Blocked non-trade server")
        return
    end

    if parsed.Mode == "PrivateLink" then
        SetGatewayStatus("Valid private server link")
        return
    end

    if parsed.Mode == "PublicInstance" then
        SetGatewayStatus("Valid public server")
        return
    end

    SetGatewayStatus("Invalid input")
end)

--==================================================
-- TELEPORT
--==================================================

local function JoinParsedServer(parsed)

    if GatewayBusy then
        SetGatewayStatus("Busy")
        return
    end

    if type(parsed) ~= "table" then
        SetGatewayStatus("Invalid input")
        return
    end

    if parsed.PlaceId ~= TRADING_WORLD_PLACE_ID then
        SetGatewayStatus("Blocked non-trade server")
        return
    end

    GatewayBusy = true

    local TeleportService =
        game:GetService("TeleportService")

    local player =
        Players.LocalPlayer

    if not player then
        GatewayBusy = false
        SetGatewayStatus("LocalPlayer missing")
        return
    end

    LastServer.Mode =
        parsed.Mode

    LastServer.PlaceId =
        parsed.PlaceId

    LastServer.JobId =
        parsed.JobId

    LastServer.Code =
        parsed.Code

    if parsed.Mode == "PrivateLink" then

    SetGatewayStatus("Private link copied")

    local privateUrl =
        "https://www.roblox.com/share?code="
        .. tostring(parsed.Code)
        .. "&type=Server"

    if setclipboard then
        pcall(function()
            setclipboard(privateUrl)
        end)
    end

    warn(
        "[Gateway] Private server links cannot be joined with TeleportService from the client."
    )

    warn(
        "[Gateway] Link copied. Open it through browser / RoValra / Roblox app:",
        privateUrl
    )

    HolyNotify(
        "Private Link Copied",
        "Roblox blocks client-side TeleportToPrivateServer. Open the copied link through browser/RoValra.",
        "link",
        5
    )

    elseif parsed.Mode == "PublicInstance" then

        SetGatewayStatus("Connecting public server...")

        local ok, err =
            pcall(function()

                TeleportService:TeleportToPlaceInstance(
                    parsed.PlaceId,
                    parsed.JobId,
                    player
                )
            end)

        if not ok then

            warn(
                "[Gateway] Public server teleport failed:",
                tostring(err)
            )

            SetGatewayStatus("Public join failed")
        end

    else

        SetGatewayStatus("Invalid mode")
    end

    task.delay(5, function()
        GatewayBusy = false
    end)
end

--==================================================
-- BUTTONS
--==================================================

GatewayBox:AddButton({
    Text = "📎 Copy Current Server",
    Func = function()
        if ScriptState.ForceStopped then
            SetGatewayStatus(
                "Blocked (ForceStopped)"
            )
            return
        end

        if not setclipboard then
            SetGatewayStatus(
                "Clipboard unsupported"
            )
            return
        end

        local payload =
            tostring(game.PlaceId)
            .. ":"
            .. tostring(game.JobId)

        pcall(function()
            setclipboard(payload)
        end)

        SetGatewayStatus(
            "Current server copied"
        )
    end,
})

GatewayBox:AddButton({
    Text = "↺ Reconnect Last Server",
    Func = function()
        if ScriptState.ForceStopped then
            SetGatewayStatus(
                "Blocked (ForceStopped)"
            )
            return
        end

        if not LastServer.JobId then
            SetGatewayStatus(
                "No previous server"
            )
            return
        end

        JoinParsedServer(LastServer)
    end,
})

GatewayBox:AddButton({
    Text = "🚪 Connect",
    Tooltip = "Join target server instance",
    Func = function()
        if ScriptState.ForceStopped then
            SetGatewayStatus(
                "Blocked (ForceStopped)"
            )
            return
        end

local text =
    GatewayInput.Value

local parsed =
    ParseServerInput(text)

if not parsed then
    SetGatewayStatus("Invalid input")
    return
end

if parsed.PlaceId ~= TRADING_WORLD_PLACE_ID then
    SetGatewayStatus(
        "Blocked non-trade server"
    )
    return
end

JoinParsedServer(parsed)

GatewayInput:SetValue("")
    end,
})

GatewayInput:SetValue("")

--==================================================
-- GARDEN MODE HOME GATE
-- Keeps Home useful, but does not expose real sniper
-- runtime controls outside Trade World.
--==================================================

if not IsTradeWorld() then

    HomeBox:AddDivider({
        Text = "Garden Mode",
        MarginTop = 10,
        MarginBottom = 8,
    })

    HomeBox:AddLabel(
        "🌱 Trade World automation is disabled here.",
        true
    )

    HomeBox:AddButton({
        Text = "🌐 Join Trade World",
        Tooltip = "Teleport to Grow a Garden Trade World.",
        Func = function()

            RequestJoinTradeWorld(
                "Manual Trade World join requested."
            )
        end,
    })

    return
end
--==================================================
-- ISOLATED
--==================================================

local StartToggle = HomeBox:AddToggle("StartSystem", {
    Text = "⚡ Activate Sniper",
    Default = false,
})

StartToggle:OnChanged(function(enabled)

    RuntimeState.Started = enabled

if enabled then
    SniperMonitorState.Status = "Active"
    SniperMonitorState.PetsScanned = 0
    SniperMonitorState.ScanPasses = 0

    SniperState.ScanStartedAt =
        os.clock()

    HolyNotify(
        "Sniper Started",
        "Scanning Trade World listings.",
        "crosshair",
        4
    )
else
    SniperMonitorState.Status = "Idle"
    SniperMonitorState.PetsScanned = 0

    HolyNotify(
        "Sniper Stopped",
        "Scanning has been paused.",
        "pause",
        3
    )
end

    MarkConfigDirty()
end)

local SniperAutoHopToggle =
    HomeBox:AddToggle(
        "SniperAutoHop",
        {
            Text = "🚀 Sniper Auto Hop",
            Default = false,
        }
    )

SniperAutoHopToggle:OnChanged(function(v)

    SniperState.AutoHop = v

    SniperState.ScanStartedAt =
        os.clock()

    MarkConfigDirty()

    if v then
        HolyNotify(
            "Auto Hop Enabled",
            "Sniper will hop after the scan duration expires.",
            "refresh-cw",
            3
        )
    else
        HolyNotify(
            "Auto Hop Disabled",
            "Sniper will stay in the current server.",
            "pause",
            3
        )
    end
end)

local ScanDurationInput =
    HomeBox:AddInput(
        "SniperHopDuration",
        {
            Text = "Scan Duration (sec)",
            Default = "10",
            Numeric = true,
            Finished = true,
        }
    )

ScanDurationInput:OnChanged(function(v)

    local num = tonumber(v)

    if not num then
        return
    end

    SniperState.ScanDuration =
        math.clamp(num, 1, 3600)

    MarkConfigDirty()
end)

--==================================================
-- HOME: CLEAN SERVER ACTION ROW
-- Compact labels only. Sub-buttons render horizontally,
-- so long text will always look weak/cramped.
--==================================================

HomeBox:AddDivider({
    Text = "Quick Actions",
    MarginTop = 10,
    MarginBottom = 8,
})

local ServerActionButton =
    HomeBox:AddButton({
        Text = "Server",
        Tooltip = "Quick server controls.",
        Func = function()

            HolyNotify(
                "Server Actions",
                "Use Copy, Rejoin, Hop, or STOP.",
                "server",
                3
            )
        end,
    })

ServerActionButton:AddButton({
    Text = "Copy",
    Tooltip = "Copy current placeId:jobId.",
    Func = function()

        if not setclipboard then

            HolyNotify(
                "Clipboard Unsupported",
                "Your executor does not support setclipboard.",
                "clipboard-x",
                3
            )

            return
        end

        local payload =
            tostring(game.PlaceId)
            .. ":"
            .. tostring(game.JobId)

        pcall(function()
            setclipboard(payload)
        end)

        HolyNotify(
            "Server Copied",
            "Current server copied to clipboard.",
            "clipboard-check",
            3
        )
    end,
})

ServerActionButton:AddButton({
    Text = "Rejoin",
    Tooltip = "Reconnect to this exact server instance.",
    Func = function()

        if ScriptState.ForceStopped then
            warn("[Rejoin] Blocked (ForceStopped)")
            return
        end

        local TeleportService =
            game:GetService("TeleportService")

        local player =
            Players.LocalPlayer

        if not player then
            warn("[Rejoin] LocalPlayer missing")
            return
        end

        pcall(function()
            TeleportService:TeleportToPlaceInstance(
                game.PlaceId,
                game.JobId,
                player
            )
        end)
    end,
})

ServerActionButton:AddButton({
    Text = "Hop",
    Tooltip = "Join a different public Trade World server.",
    Func = function()

        if ScriptState.ForceStopped then
            warn("[Hop] Blocked (ForceStopped)")
            return
        end

        local TeleportService =
            game:GetService("TeleportService")

        local player =
            Players.LocalPlayer

        if not player then
            warn("[Hop] LocalPlayer missing")
            return
        end

        local target = nil

        if type(GetRandomTradeServer) == "function" then
            target = GetRandomTradeServer()
        end

        if not target then

    HolyNotify(
        "Hop Failed",
        "No valid server found. Raise Max Server Players or change hop mode.",
        "server-off",
        4
    )

    warn("[Hop] No valid target server found")

    return
end

        SniperState.RecentServers[target] =
            true

        if TeleportRetryState then
            TeleportRetryState.LastTarget =
                target

            TeleportRetryState.BlockedServers[target] =
                true
        end

        pcall(function()
            TeleportService:TeleportToPlaceInstance(
                TRADING_WORLD_PLACE_ID,
                target,
                player
            )
        end)
    end,
})

ServerActionButton:AddButton({
    Text = "STOP",
    Tooltip = "Hard stop all HOLY runtime systems.",
    Risky = true,
    DoubleClick = true,
    Func = function()

        ScriptState.ForceStopped =
            true

        RuntimeState.Started =
            false

        SniperState.Scanning =
            false

        SniperState.Buying =
            false

        SniperState.Hopping =
            false

        if PurchaseState then
            PurchaseState.Busy =
                false
        end

        if BoothAuto then
    BoothAuto.Enabled =
        false

    BoothAuto.InProgress =
        false

    BoothAuto.AutoTeleport =
        false

    BoothAuto.LockBehindBooth =
        false

    BoothAuto.AutoServerHop =
        false

    ClearBoothAnchor()
    RestoreCharacterMovement()
end

        HolyNotify(
            "Emergency Stop",
            "All active HOLY runtime systems were stopped.",
            "octagon-alert",
            5
        )
    end,
})
end
--==================================================
-- BEE EGG LIST RESOLUTION
-- Reads available egg names from ReplicatedStorage.Assets.Models.BeeEggs
--==================================================

function RefreshBeeEggList()

    table.clear(BeeEggAuto.EggList)

    local assets =
        ReplicatedStorage:FindFirstChild("Assets")

    if not assets then
        warn("[BEE EGG] Assets missing")
        return BeeEggAuto.EggList
    end

    local models =
        assets:FindFirstChild("Models")

    if not models then
        warn("[BEE EGG] Assets.Models missing")
        return BeeEggAuto.EggList
    end

    local beeEggs =
        models:FindFirstChild("BeeEggs")

    if not beeEggs then
        warn("[BEE EGG] Assets.Models.BeeEggs missing")
        return BeeEggAuto.EggList
    end

    for _, eggModel in ipairs(beeEggs:GetChildren()) do

        if eggModel.Name
        and eggModel.Name ~= "" then

            table.insert(
                BeeEggAuto.EggList,
                tostring(eggModel.Name)
            )
        end
    end

    table.sort(BeeEggAuto.EggList)

    return BeeEggAuto.EggList
end
--==================================================
-- BEE EGG SHOP REMOTE RESOLUTION
--==================================================

function GetBuyBeeEggRemote()

    if BeeEggAuto.BuyRemote then
        return BeeEggAuto.BuyRemote
    end

    local gameEvents =
        ReplicatedStorage:FindFirstChild("GameEvents")

    if not gameEvents then
        return nil
    end

    local service =
        gameEvents:FindFirstChild("BeeColonyEggShopService")

    if not service then
        return nil
    end

    local remote =
        service:FindFirstChild("BuyBeeEggStock")

    if remote
    and remote:IsA("RemoteFunction") then
        BeeEggAuto.BuyRemote = remote
        return remote
    end

    return nil
end

function TryBuyBeeEgg()

    if ScriptState.ForceStopped then
        return false
    end

    if game.PlaceId ~= TRADING_WORLD_PLACE_ID then
        return false
    end

    if BeeEggAuto.Buying then
        return false
    end

    local now =
        os.clock()

    BeeEggAuto.LastAttempt =
        SafeNumber(BeeEggAuto.LastAttempt, 0)

    BeeEggAuto.BuyInterval =
        SafeNumber(BeeEggAuto.BuyInterval, 1.5)

    if now - BeeEggAuto.LastAttempt
        < BeeEggAuto.BuyInterval
    then
        return false
    end

    BeeEggAuto.LastAttempt = now
    BeeEggAuto.Buying = true

    local remote =
        GetBuyBeeEggRemote()

    if not remote then
        BeeEggAuto.Buying = false
        warn("[BEE EGG] Buy remote missing")
        return false
    end

    local boughtAny = false

    for eggName, selected in pairs(BeeEggAuto.SelectedEggs) do

        if selected == true then

            local ok, result =
                pcall(function()
                    return remote:InvokeServer(
                        tostring(eggName)
                    )
                end)

            if ok then
                boughtAny = true

                -- Do not print every successful nil response.
                -- The Bee Egg remote commonly returns nil even when the call is valid.

            else

                warn(
                    "[BEE EGG] Buy failed:",
                    tostring(eggName),
                    tostring(result)
                )
            end

            task.wait(0.15)
        end
    end

    BeeEggAuto.Buying = false

    return boughtAny
end
function TeleportViaController()
    local Controller = GetController()

    if Controller and Controller.TeleportToBooth then
        local ok = pcall(function()
            Controller:TeleportToBooth()
        end)

        if ok then
            print("[Booth] Teleport via controller SUCCESS")
            return true
        end
    end

    warn("[Booth] Controller teleport failed")
    return false
end
--==================================================
-- TELEPORT TO OWNED BOOTH (ISOLATED, SAFE)
--==================================================
--==================================================
-- TRADE WORLD BOOTH CENTER / DIRECTION HELPERS
-- Used for skin-safe behind-booth positioning.
--==================================================

BoothPositionState =
    BoothPositionState
    or {
        LastPivotSource = nil,
        LastPivotPrintAt = 0,
        LastRepositionAt = 0,
    }

function ResolveBoothPriorityPointGlobal()

    local tradeWorld =
        workspace:FindFirstChild("TradeWorld")

    if not tradeWorld then
        return nil
    end

    local model =
        tradeWorld:FindFirstChild("Model")

    if not model then
        return nil
    end

    local children1 =
        model:GetChildren()

    local parent =
        children1[5]

    if not parent then
        return nil
    end

    local children2 =
        parent:GetChildren()

    local target =
        children2[8]

    if not target then
        return nil
    end

    if target:IsA("BasePart") then
        return target.Position
    end

    if target:IsA("Model") then
        return target:GetPivot().Position
    end

    if target:IsA("Attachment") then
        return target.WorldPosition
    end

    local ok, pivot =
        pcall(function()
            return target:GetPivot()
        end)

    if ok
    and pivot then
        return pivot.Position
    end

    return nil
end

function ResolveBoothBehindDirection(boothModel, standPosition, standPivot)

    standPosition =
        standPosition
        or (
            standPivot
            and standPivot.Position
        )

    if not standPosition then
        return Vector3.new(0, 0, -1), "Fallback"
    end

    -- Best direction:
    -- booths face inward toward the trade-world center/priority point.
    -- behind = away from that center/priority point.
    local priorityPosition =
        ResolveBoothPriorityPointGlobal()

    if priorityPosition then

        local away =
            Vector3.new(
                standPosition.X - priorityPosition.X,
                0,
                standPosition.Z - priorityPosition.Z
            )

        if away.Magnitude > 0.001 then
            return away.Unit, "AwayFromPriorityPoint"
        end
    end

    -- Fallback: use whole booth pivot, not skin stand pivot.
    -- Custom skin Stand pivots can be rotated sideways.
    if boothModel
    and boothModel:IsA("Model") then

        local ok, boothPivot =
            pcall(function()
                return boothModel:GetPivot()
            end)

        if ok
        and boothPivot then

            local direction =
                Vector3.new(
                    boothPivot.LookVector.X,
                    0,
                    boothPivot.LookVector.Z
                )

            if direction.Magnitude > 0.001 then
                return direction.Unit, "BoothModelLookVector"
            end
        end
    end

    if standPivot then

        local direction =
            Vector3.new(
                standPivot.LookVector.X,
                0,
                standPivot.LookVector.Z
            )

        if direction.Magnitude > 0.001 then
            return direction.Unit, "StandLookVectorFallback"
        end
    end

    return Vector3.new(0, 0, -1), "HardFallback"
end

function ResolveCenteredBehindBoothPlacement(boothModel, fallbackPosition, fallbackPivot)

    if not boothModel then
        return nil, nil, "NO_BOOTH_MODEL"
    end

    local boothCFrame = nil
    local boothSize = nil

    if boothModel:IsA("Model") then

        local ok, cf, size =
            pcall(function()
                return boothModel:GetBoundingBox()
            end)

        if ok
        and cf
        and size then

            boothCFrame =
                cf

            boothSize =
                size
        end
    end

    if not boothCFrame then

        local ok, pivot =
            pcall(function()
                return boothModel:GetPivot()
            end)

        if ok
        and pivot then

            boothCFrame =
                pivot

            boothSize =
                Vector3.new(12, 8, 12)
        end
    end

    if not boothCFrame then

        if fallbackPivot then
            boothCFrame =
                fallbackPivot

            boothSize =
                Vector3.new(12, 8, 12)

        elseif fallbackPosition then
            boothCFrame =
                CFrame.new(fallbackPosition)

            boothSize =
                Vector3.new(12, 8, 12)
        end
    end

    if not boothCFrame then
        return nil, nil, "NO_BOOTH_CFRAME"
    end

    boothSize =
        boothSize
        or Vector3.new(12, 8, 12)

    local boothCenter =
        boothCFrame.Position

    local behindDirection, directionSource =
        ResolveBoothBehindDirection(
            boothModel,
            boothCenter,
            fallbackPivot
        )

    behindDirection =
        Vector3.new(
            behindDirection.X,
            0,
            behindDirection.Z
        )

    if behindDirection.Magnitude <= 0.001 then
        behindDirection =
            Vector3.new(0, 0, -1)
    else
        behindDirection =
            behindDirection.Unit
    end

    local right =
        Vector3.new(
            boothCFrame.RightVector.X,
            0,
            boothCFrame.RightVector.Z
        )

    local look =
        Vector3.new(
            boothCFrame.LookVector.X,
            0,
            boothCFrame.LookVector.Z
        )

    if right.Magnitude <= 0.001 then
        right =
            Vector3.new(1, 0, 0)
    else
        right =
            right.Unit
    end

    if look.Magnitude <= 0.001 then
        look =
            Vector3.new(0, 0, -1)
    else
        look =
            look.Unit
    end

    -- Project the booth bounding box onto the behind direction.
    -- This places the player behind the center of the whole booth,
    -- not behind a custom skin's offset Stand pivot.
    local halfDepth =
        (
            math.abs(behindDirection:Dot(right)) * boothSize.X
            + math.abs(behindDirection:Dot(look)) * boothSize.Z
        ) * 0.5

    local distance =
        SafeNumber(
            BoothAuto.BoothDistance,
            20
        )

    -- Keep a small minimum spacing so large skins do not trap the player
    -- inside decorative geometry.
    distance =
        math.max(
            distance,
            4
        )

    local targetPosition =
        boothCenter
        + (
            behindDirection
            * (
                halfDepth
                + distance
            )
        )

    local lookTarget =
        Vector3.new(
            boothCenter.X,
            targetPosition.Y,
            boothCenter.Z
        )

    return targetPosition, lookTarget, directionSource
end
--==================================================
-- BOOTH GEOMETRY RESOLUTION
-- Skin-safe resolver for Default / custom booth skins.
--==================================================

function ResolveOwnedBoothStandPivot(boothModel)

    if not boothModel then
        return nil, "NO_BOOTH_MODEL"
    end

    local function TryGetPivot(instance)

        if not instance then
            return nil
        end

        if instance:IsA("Model") then

            local ok, pivot =
                pcall(function()
                    return instance:GetPivot()
                end)

            if ok and pivot then
                return pivot
            end
        end

        if instance:IsA("BasePart") then
            return instance.CFrame
        end

        return nil
    end

    --==================================================
    -- Priority 1:
    -- Existing default path:
    -- Any child -> Booth -> Stand -> Model
    --==================================================

    for _, child in ipairs(boothModel:GetChildren()) do

        local booth =
            child:FindFirstChild("Booth")

        local stand =
            booth
            and booth:FindFirstChild("Stand")

        local model =
            stand
            and stand:FindFirstChild("Model")

        local pivot =
            TryGetPivot(model)

        if pivot then
            return pivot, "Booth.Stand.Model"
        end
    end

    --==================================================
    -- Priority 2:
    -- Direct descendants named Stand.
    -- Custom skins often move Stand deeper.
    --==================================================

    for _, descendant in ipairs(boothModel:GetDescendants()) do

        if descendant.Name == "Stand" then

            local model =
                descendant:FindFirstChild("Model")

            local pivot =
                TryGetPivot(model)
                or TryGetPivot(descendant)

            if pivot then
                return pivot, "Descendant.Stand"
            end
        end
    end

    --==================================================
    -- Priority 3:
    -- Any descendant named Model under a Booth/Stand-like tree.
    --==================================================

    for _, descendant in ipairs(boothModel:GetDescendants()) do

        if descendant.Name == "Model" then

            local parent =
                descendant.Parent

            local grandparent =
                parent and parent.Parent

            local parentName =
                parent and tostring(parent.Name):lower() or ""

            local grandparentName =
                grandparent and tostring(grandparent.Name):lower() or ""

            if parentName:find("stand", 1, true)
            or parentName:find("booth", 1, true)
            or grandparentName:find("stand", 1, true)
            or grandparentName:find("booth", 1, true) then

                local pivot =
                    TryGetPivot(descendant)

                if pivot then
                    return pivot, "BoothLike.Model"
                end
            end
        end
    end

    --==================================================
    -- Priority 4:
    -- Fallback to booth model pivot.
    -- This prevents total failure if a skin has unknown structure.
    --==================================================

    local boothPivot =
        TryGetPivot(boothModel)

    if boothPivot then
        return boothPivot, "BoothModelFallback"
    end

    local firstPart =
        boothModel:FindFirstChildWhichIsA(
            "BasePart",
            true
        )

    local partPivot =
        TryGetPivot(firstPart)

    if partPivot then
        return partPivot, "FirstBasePartFallback"
    end

    return nil, "NO_VALID_PIVOT"
end
--==================================================
-- POSITION PLAYER BEHIND OWNED BOOTH
--==================================================
function PositionBehindOwnedBooth()
    local player = Players.LocalPlayer
    local character = player.Character

    if not character then
        return false
    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if not root then
        return false
    end

    --==================================================
    -- TRADE WORLD GATE
    --==================================================

    if game.PlaceId ~= TRADING_WORLD_PLACE_ID then
        return false
    end

local tradeWorld = workspace:FindFirstChild("TradeWorld")

if not tradeWorld then
    return false
end

local boothsFolder = tradeWorld:FindFirstChild("Booths")

if not boothsFolder then
    return false
end

    local data = LatestBoothData

    if not data or not data.Booths then
        warn("[Booth] Failed to resolve booth data")
        return false
    end

    local playerId = tostring(player.UserId)

    for boothId, boothInfo in pairs(data.Booths) do
        if boothInfo.Owner
            and tostring(boothInfo.Owner):find(playerId)
        then
            local boothModel = boothsFolder:FindFirstChild(boothId)

            if not boothModel then
                warn("[Booth] Booth model missing")
                return false
            end


            --==================================================
            -- GET REAL BOOTH GEOMETRY
            -- Skin-safe: supports Default and custom booth skins.
            --==================================================

            local standPivot, pivotSource =
                ResolveOwnedBoothStandPivot(
                    boothModel
                )

            if not standPivot then

                warn(
                    "[Booth] Failed to resolve booth pivot:",
                    tostring(pivotSource)
                )

                return false
            end

                        local now =
                os.clock()

            BoothPositionState =
                BoothPositionState
                or {}

            if BoothPositionState.LastPivotSource ~= pivotSource
            or now - SafeNumber(BoothPositionState.LastPivotPrintAt, 0) > 5 then

                BoothPositionState.LastPivotSource =
                    pivotSource

                BoothPositionState.LastPivotPrintAt =
                    now

                print(
                    "[Booth] Stand pivot source:",
                    tostring(pivotSource)
                )
            end

            local standPosition =
                standPivot.Position

            local distance =
                SafeNumber(
                    BoothAuto.BoothDistance,
                    20
                )

            local flatDirection, directionSource =
                ResolveBoothBehindDirection(
                    boothModel,
                    standPosition,
                    standPivot
                )

            if BoothPositionState.LastDirectionSource ~= directionSource
            or now - SafeNumber(BoothPositionState.LastDirectionPrintAt, 0) > 5 then

                BoothPositionState.LastDirectionSource =
                    directionSource

                BoothPositionState.LastDirectionPrintAt =
                    now

                print(
                    "[Booth] Behind direction source:",
                    tostring(directionSource)
                )
            end

                        --==================================================
            -- FINAL TARGET POSITION
            -- Centered behind whole booth model, not skin Stand pivot.
            --==================================================

            local targetPosition, lookTarget, placementSource =
                ResolveCenteredBehindBoothPlacement(
                    boothModel,
                    standPosition,
                    standPivot
                )

            if not targetPosition then

                warn(
                    "[Booth] Failed centered booth placement:",
                    tostring(placementSource)
                )

                return false
            end

            if BoothPositionState.LastPlacementSource ~= placementSource
            or now - SafeNumber(BoothPositionState.LastPlacementPrintAt, 0) > 5 then

                BoothPositionState.LastPlacementSource =
                    placementSource

                BoothPositionState.LastPlacementPrintAt =
                    now

                print(
                    "[Booth] Placement source:",
                    tostring(placementSource)
                )
            end

            --==================================================
            -- GROUND RESOLUTION
            --==================================================

            local rayOrigin =
                targetPosition + Vector3.new(0, 20, 0)

            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {
                character,
                boothModel
            }

            local rayResult = workspace:Raycast(
                rayOrigin,
                Vector3.new(0, -100, 0),
                rayParams
            )

            local groundOffset =
    GetCharacterGroundOffset()

local finalPosition

if rayResult then
    finalPosition =
        rayResult.Position
        + Vector3.new(0, groundOffset, 0)
else
    finalPosition =
        targetPosition
        + Vector3.new(0, groundOffset, 0)
end
--==================================================
-- FLAT LOOK TARGET (NO VERTICAL TILT)
-- Look at the booth center, not the custom Stand pivot.
--==================================================

local flatLookTarget =
    lookTarget
    or Vector3.new(
        standPosition.X,
        finalPosition.Y,
        standPosition.Z
    )

flatLookTarget =
    Vector3.new(
        flatLookTarget.X,
        finalPosition.Y,
        flatLookTarget.Z
    )

local finalCFrame =
    CFrame.lookAt(
        finalPosition,
        flatLookTarget
    )

BoothAuto.LastBoothPosition =
    finalPosition

BoothAuto.LastBoothCFrame =
    finalCFrame

MoveCharacterToBoothCFrame(finalCFrame)

            return true
        end
    end

    warn("[Booth] Failed to find owned booth")

    return false
end

function TeleportToOwnedBooth()
    if game.PlaceId ~= TRADING_WORLD_PLACE_ID then
        return
    end

    print("[Booth] Waiting for ownership (server)...")

    local start = os.clock()
    local timeout = 6
    local playerId = tostring(Players.LocalPlayer.UserId)

    while os.clock() - start < timeout do
        local data = LatestBoothData

        if data and data.Booths then
            for _, booth in pairs(data.Booths) do
                if booth.Owner and tostring(booth.Owner):find(playerId) then
                    print("[Booth] Ownership confirmed → teleporting")



task.wait(0.25)

TeleportViaController()

local success =
    false

for attempt = 1, 8 do

    task.wait(0.35)

    success =
        PositionBehindOwnedBooth()

    if success then

        print(
            "[Booth] Positioned behind booth on attempt:",
            tostring(attempt)
        )

        break
    end

    warn(
        "[Booth] Position retry:",
        tostring(attempt)
    )
end

if not success then
    warn("[Booth] Failed positioning behind booth")
end

return
                end
            end
        end

        task.wait(0.35)
    end

    warn("[Booth] Teleport failed (ownership timeout)")
end

--==================================================
-- CHARACTER RESPAWN SUPPORT
--==================================================
function OnCharacterAdded(character)
    if game.PlaceId ~= TRADING_WORLD_PLACE_ID then
        return
    end

    if not BoothAuto.AutoTeleport then
        return
    end

    task.wait(1)

    if not BoothAuto.LockBehindBooth then
        RestoreCharacterMovement()
    end

    PositionBehindOwnedBooth()
end

Players.LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
--==================================================
-- BOOTH POSITION SUPERVISOR
-- Auto Teleport = soft return
-- Lock Behind Booth = hard lock
--==================================================
function BoothPositionWatchdog()

    while IsCurrentRun() do

        task.wait(0.10)

        if ScriptState.ForceStopped then
            continue
        end

        if game.PlaceId ~= TRADING_WORLD_PLACE_ID then
            continue
        end

        if not BoothAuto.AutoTeleport then
            continue
        end

        if not BoothAuto.LastBoothPosition then
            continue
        end

        local player =
            Players.LocalPlayer

        if not player then
            continue
        end

        local character =
            player.Character

        if not character then
            continue
        end

        local root =
            character:FindFirstChild("HumanoidRootPart")

        local humanoid =
            character:FindFirstChildOfClass("Humanoid")

        if not root
        or not humanoid
        or humanoid.Health <= 0 then
            continue
        end

        local now =
            os.clock()

        local distance =
            (root.Position - BoothAuto.LastBoothPosition).Magnitude

        --==================================================
        -- HARD LOCK MODE
        -- Only active when Lock Behind Booth is enabled.
        --==================================================

        if BoothAuto.LockBehindBooth == true then

            if BoothAuto.LastBoothCFrame then

                SetBoothHardLockAnchored(true)

            else

                if now - SafeNumber(BoothAuto.LastHardLockAt, 0)
                    >= 1.00
                then
                    BoothAuto.LastHardLockAt =
                        now

                    PositionBehindOwnedBooth()
                end
            end

            continue
        end

        --==================================================
        -- SOFT RETURN MODE
        -- Auto Teleport keeps you near booth, but lets you move.
        --==================================================

        if root.Anchored == true then
            root.Anchored = false
        end

        RestoreCharacterMovement()

        local returnDistance =
            SafeNumber(
                BoothAuto.ReturnDistance,
                8
            )

        returnDistance =
            math.clamp(
                returnDistance,
                5,
                15
            )

        if distance < returnDistance then
            continue
        end

        if now - SafeNumber(BoothAuto.LastSoftReturnAt, 0)
            < SafeNumber(BoothAuto.SoftReturnCooldown, 1.50)
        then
            continue
        end

        BoothAuto.LastSoftReturnAt =
            now

        if BoothAuto.LastBoothCFrame then
            MoveCharacterToBoothCFrame(
                BoothAuto.LastBoothCFrame
            )
        else
            PositionBehindOwnedBooth()
        end
    end
end
--==================================================
-- BOOTH AUTO CLAIM
-- Retry-based, verified claim session.
-- If the first booth gets claimed by another player,
-- HOLY tries the next best free booth instead of going AFK.
--==================================================

function ExecuteBoothClaim()

    if BoothAuto.InProgress
    or not BoothAuto.Enabled then
        return
    end

    if game.PlaceId ~= TRADING_WORLD_PLACE_ID then

        warn("[Booth] Not in Trade World")

        BoothAuto.Enabled =
            false

        return
    end

    BoothAuto.InProgress =
        true

    print("[Booth] Claim session started")
    print("[Booth] Fetching booth data...")

    local GameEvents =
        ReplicatedStorage:FindFirstChild("GameEvents")

    if not GameEvents then

        warn("[Booth] GameEvents missing")

        BoothAuto.Enabled =
            false

        BoothAuto.InProgress =
            false

        return
    end

    local tradeEvents =
        GameEvents:FindFirstChild("TradeEvents")

    local boothsEvents =
        tradeEvents
        and tradeEvents:FindFirstChild("Booths")

    local ClaimBooth =
        boothsEvents
        and boothsEvents:FindFirstChild("ClaimBooth")

    local skinService =
        GameEvents:FindFirstChild("TradeBoothSkinService")

    local EquipSkin =
        skinService
        and skinService:FindFirstChild("Equip")

    if not ClaimBooth
    or not EquipSkin then

        warn("[Booth] ClaimBooth or EquipSkin remote missing")

        BoothAuto.Enabled =
            false

        BoothAuto.InProgress =
            false

        return
    end

    local tradeWorld =
        workspace:FindFirstChild("TradeWorld")

    local boothsFolder =
        tradeWorld
        and tradeWorld:FindFirstChild("Booths")

    if not boothsFolder then

        warn("[Booth] Booth folder missing")

        BoothAuto.Enabled =
            false

        BoothAuto.InProgress =
            false

        return
    end

    --==================================================
    -- LOCAL HELPERS
    --==================================================

    local function ResolveBoothPriorityPoint()

        local world =
            workspace:FindFirstChild("TradeWorld")

        if not world then
            return nil
        end

        local model =
            world:FindFirstChild("Model")

        if not model then
            return nil
        end

        local children1 =
            model:GetChildren()

        local parent =
            children1[5]

        if not parent then
            return nil
        end

        local children2 =
            parent:GetChildren()

        local target =
            children2[8]

        if not target then
            return nil
        end

        if target:IsA("BasePart") then
            return target.Position
        end

        if target:IsA("Model") then
            return target:GetPivot().Position
        end

        if target:IsA("Attachment") then
            return target.WorldPosition
        end

        local ok, pivot =
            pcall(function()
                return target:GetPivot()
            end)

        if ok
        and pivot then
            return pivot.Position
        end

        return nil
    end

    local function ResolveBoothPosition(boothModel)

        if not boothModel then
            return nil
        end

        if boothModel:IsA("Model") then

            local ok, pivot =
                pcall(function()
                    return boothModel:GetPivot()
                end)

            if ok
            and pivot then
                return pivot.Position
            end
        end

        if boothModel:IsA("BasePart") then
            return boothModel.Position
        end

        local primary =
            boothModel.PrimaryPart

        if primary then
            return primary.Position
        end

        local firstPart =
            boothModel:FindFirstChildWhichIsA(
                "BasePart",
                true
            )

        if firstPart then
            return firstPart.Position
        end

        return nil
    end

    local function BuildFreeBoothCandidates(triedBooths)

        local data =
            LatestBoothData

        if not data
        or type(data.Booths) ~= "table" then
            return {}
        end

        local priorityPosition =
            ResolveBoothPriorityPoint()

        if not priorityPosition then
            warn("[Booth] Priority point missing, using fallback booth order")
        end

        local candidates =
            {}

        for boothId, boothInfo in pairs(data.Booths) do

            if triedBooths[boothId] then
                continue
            end

            if boothInfo.Owner ~= nil then
                continue
            end

            local model =
                boothsFolder:FindFirstChild(boothId)

            if not model then
                continue
            end

            local distance =
                math.huge

            if priorityPosition then

                local boothPosition =
                    ResolveBoothPosition(model)

                if boothPosition then
                    distance =
                        (boothPosition - priorityPosition).Magnitude
                end
            end

            table.insert(candidates, {
                BoothId = boothId,
                Model = model,
                Distance = distance,
            })
        end

        table.sort(candidates, function(a, b)

            local aDistance =
                tonumber(a.Distance)
                or math.huge

            local bDistance =
                tonumber(b.Distance)
                or math.huge

            if aDistance ~= bDistance then
                return aDistance < bDistance
            end

            return tostring(a.BoothId) < tostring(b.BoothId)
        end)

        return candidates
    end

    local function IsOwnBoothId(boothId)

        local data =
            LatestBoothData

        if not data
        or type(data.Booths) ~= "table" then
            return false
        end

        local boothInfo =
            data.Booths[boothId]

        local owner =
            boothInfo
            and boothInfo.Owner

        if not owner then
            return false
        end

        local userId =
            tostring(Players.LocalPlayer.UserId)

        return tostring(owner):find(userId, 1, true) ~= nil
    end

    local function WaitForBoothOwnership(boothId, timeout)

        local start =
            os.clock()

        timeout =
            SafeNumber(timeout, 3)

        while os.clock() - start < timeout do

            if IsOwnBoothId(boothId) then
                return true
            end

            task.wait(0.20)
        end

        return false
    end

    local function FinishClaim(success)

        BoothAuto.InProgress =
            false

        BoothAuto.Enabled =
            false

        if Library
        and Library.Options
        and Library.Options.AutoClaimBooth then

            task.defer(function()

                pcall(function()
                    Library.Options.AutoClaimBooth:SetValue(false)
                end)
            end)
        end

        if success then
            print("[Booth] Claim session complete")
        else
            warn("[Booth] Claim session failed")
        end
    end

    --==================================================
    -- CLAIM SESSION CONFIG
    --==================================================

    local triedBooths =
        {}

    local maxAttempts =
        6

    local verifyTimeout =
        3

    local retryDelay =
        0.35

    local selectedSkin =
        ResolveSelectedBoothSkin()

    --==================================================
    -- CLAIM LOOP
    --==================================================

    for attempt = 1, maxAttempts do

        if ScriptState
        and ScriptState.ForceStopped then

            FinishClaim(false)
            return
        end

        local candidates =
            BuildFreeBoothCandidates(triedBooths)

        if #candidates <= 0 then

            warn("[Booth] No free booth candidates left")

            FinishClaim(false)
            return
        end

        local candidate =
            candidates[1]

        local boothId =
            tostring(candidate.BoothId)

        local targetBooth =
            candidate.Model

        triedBooths[boothId] =
            true

        if candidate.Distance ~= math.huge then

            print(
                "[Booth] Attempt "
                    .. tostring(attempt)
                    .. "/"
                    .. tostring(maxAttempts)
                    .. " -> "
                    .. tostring(boothId)
                    .. " | distance: "
                    .. tostring(math.floor(candidate.Distance))
            )

        else

            print(
                "[Booth] Attempt "
                    .. tostring(attempt)
                    .. "/"
                    .. tostring(maxAttempts)
                    .. " -> "
                    .. tostring(boothId)
            )
        end

        selectedSkin =
            ResolveSelectedBoothSkin()

        pcall(function()
            EquipSkin:FireServer(selectedSkin)
        end)

        task.wait(0.15)

        pcall(function()
            ClaimBooth:FireServer(targetBooth)
        end)

        task.wait(0.20)

        selectedSkin =
            ResolveSelectedBoothSkin()

        pcall(function()
            EquipSkin:FireServer(selectedSkin)
        end)

        print(
            "[Booth] Equipped skin:",
            tostring(selectedSkin)
        )

        print(
            "[Booth] Claim attempt sent:",
            tostring(boothId)
        )

        local owned =
            WaitForBoothOwnership(
                boothId,
                verifyTimeout
            )

        if owned then

            print(
                "[Booth] Ownership confirmed:",
                tostring(boothId)
            )

            if BoothAuto.AutoTeleport then

                -- Custom booth skins can rebuild the stand model after EquipSkin.
                task.spawn(function()

                    task.wait(1.25)

                    TeleportToOwnedBooth()
                end)
            end

            FinishClaim(true)

            return
        end

        warn(
            "[Booth] Claim verify failed, trying next booth:",
            tostring(boothId)
        )

        task.wait(retryDelay)
    end

    warn(
        "[Booth] Max claim attempts reached:",
        tostring(maxAttempts)
    )

    FinishClaim(false)
end
--==================================================
-- DYNAMIC PET LIST
-- Source of truth:
-- ReplicatedStorage.Data.PetRegistry.PetList
--==================================================

PetList =
    {}

function AddUniquePetName(target, seen, value)

    local name =
        tostring(value or "")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    if name == "" then
        return false
    end

    -- Defensive: never add egg pseudo-items to normal pet dropdowns.
    if name:sub(1, 4) == "Egg/" then
        return false
    end

    if seen[name] then
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

function BuildDynamicPetList()

    local registry =
        GetPetRegistry()

    local names = {}
    local seen = {}

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

    -- Fallback only: if PetRegistry.PetList ever fails,
    -- recover names from visible inventory tools.
    if #names <= 0 then

        local player =
            Players.LocalPlayer

        local containers = {
            player and player:FindFirstChild("Backpack"),
            player and player.Character,
        }

        for _, container in ipairs(containers) do

            if container then

                for _, child in ipairs(container:GetChildren()) do

                    if child:IsA("Tool") then

                        local petName =
                            child:GetAttribute("f")
                            or child:GetAttribute("PetType")
                            or child:GetAttribute("PetName")

                        if petName then
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
    end

    table.sort(names)

    return names
end

function RefreshDynamicPetList()

    local names =
        BuildDynamicPetList()

    if #names <= 0 then

        warn("[PET LIST] Dynamic pet list empty")

        return PetList
    end

    PetList =
        names

    print(
        "[PET LIST] Dynamic pets loaded:",
        tostring(#PetList)
    )

    return PetList
end

PetList =
    RefreshDynamicPetList()

--==================================================
-- LISTINGS: MUTATION LIST
-- Source of truth:
-- ReplicatedStorage.Data.PetRegistry.PetMutationRegistry
--==================================================

ListingMutationList =
    {
        "---",
    }

function AddUniqueListingMutationName(target, seen, value)

    local name =
        tostring(value or "")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    if name == "" then
        return false
    end

    if name == "---"
    or name == "Normal" then
        return false
    end

    -- Defensive: do not add internal registry table names.
    if name == "EnumToPetMutation"
    or name == "PetMutationToEnum"
    or name == "PetMutationRegistry"
    or name == "MachineMutationTypes"
    or name == "RollRandomMutation" then
        return false
    end

    if seen[name] then
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

function BuildDynamicListingMutationList()

    local names =
        {
            "---",
        }

    local seen =
        {
            ["---"] = true,
        }

    local registry =
        GetPetRegistry()

    local mutationRoot =
        type(registry) == "table"
        and rawget(registry, "PetMutationRegistry")
        or nil

    --==================================================
    -- Primary source:
    -- PetMutationRegistry.PetMutationRegistry
    --
    -- Example:
    -- Tranquil = table
    -- Inverted = table
    -- Radiant = table
    -- Fried = table
    -- Dreadbound = table
    -- Mega = table
    -- Shocked = table
    --==================================================

    local petMutationRegistry =
        type(mutationRoot) == "table"
        and rawget(mutationRoot, "PetMutationRegistry")
        or nil

    if type(petMutationRegistry) == "table" then

        for mutationName, mutationData in pairs(petMutationRegistry) do

            if type(mutationName) == "string" then

                AddUniqueListingMutationName(
                    names,
                    seen,
                    mutationName
                )

            elseif type(mutationData) == "string" then

                AddUniqueListingMutationName(
                    names,
                    seen,
                    mutationData
                )
            end
        end
    end

    --==================================================
    -- Secondary source:
    -- MachineMutationTypes
    --
    -- Includes machine/event mutation types like:
    -- Aurora, Ascended, Rainbow, Golden, Windy, etc.
    --==================================================

    local machineMutationTypes =
        type(mutationRoot) == "table"
        and rawget(mutationRoot, "MachineMutationTypes")
        or nil

    if type(machineMutationTypes) == "table" then

        for mutationName, mutationData in pairs(machineMutationTypes) do

            if type(mutationName) == "string" then

                AddUniqueListingMutationName(
                    names,
                    seen,
                    mutationName
                )

            elseif type(mutationData) == "string" then

                AddUniqueListingMutationName(
                    names,
                    seen,
                    mutationData
                )
            end
        end
    end

    --==================================================
    -- EnumToPetMutation:
    -- a = Shocked
    -- b = Golden
    -- c = Rainbow
    -- etc.
    --==================================================

    local enumToPetMutation =
        type(mutationRoot) == "table"
        and rawget(mutationRoot, "EnumToPetMutation")
        or nil

    if type(enumToPetMutation) == "table" then

        for _, mutationName in pairs(enumToPetMutation) do

            if type(mutationName) == "string" then

                AddUniqueListingMutationName(
                    names,
                    seen,
                    mutationName
                )
            end
        end
    end

    --==================================================
    -- PetMutationToEnum:
    -- Tranquil = o
    -- Inverted = g
    -- Everchanted = EV
    -- etc.
    --==================================================

    local petMutationToEnum =
        type(mutationRoot) == "table"
        and rawget(mutationRoot, "PetMutationToEnum")
        or nil

    if type(petMutationToEnum) == "table" then

        for mutationName, _ in pairs(petMutationToEnum) do

            if type(mutationName) == "string" then

                AddUniqueListingMutationName(
                    names,
                    seen,
                    mutationName
                )
            end
        end
    end

    --==================================================
    -- Fallback:
    -- If registry shape changes, recover mutation prefixes
    -- from visible inventory tools.
    --==================================================

    if #names <= 1 then

        local player =
            Players.LocalPlayer

        local containers = {
            player and player:FindFirstChild("Backpack"),
            player and player.Character,
        }

        for _, container in ipairs(containers) do

            if container then

                for _, child in ipairs(container:GetChildren()) do

                    if child:IsA("Tool") then

                        local basePetName =
                            child:GetAttribute("f")
                            or child:GetAttribute("PetType")
                            or child:GetAttribute("PetName")

                        if basePetName then

                            local mutation =
                                ResolveListingPetMutation(
                                    child.Name,
                                    tostring(basePetName)
                                )

                            AddUniqueListingMutationName(
                                names,
                                seen,
                                mutation
                            )
                        end
                    end
                end
            end
        end
    end

    table.sort(names, function(a, b)

        if a == "---" then
            return true
        end

        if b == "---" then
            return false
        end

        return a < b
    end)

    return names
end

function RefreshListingMutationList()

    local names =
        BuildDynamicListingMutationList()

    if #names <= 0 then
        names =
            {
                "---",
            }
    end

    ListingMutationList =
        names

    print(
        "[MUTATION LIST] Dynamic mutations loaded:",
        tostring(#ListingMutationList)
    )

    return ListingMutationList
end

--==================================================
-- LISTINGS: TOOL PARSING
--==================================================

function TrimListingText(text)

    return tostring(text or "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

function ParseListingDisplayWeight(toolName)

    return tonumber(
        tostring(toolName or "")
            :match("%[([%d%.]+)%s*KG%]")
    )
end

function ParseListingDisplayAge(toolName)

    return tonumber(
        tostring(toolName or "")
            :match("%[Age%s*(%d+)%]")
    )
end

function ResolveListingBaseWeightFromDisplay(displayWeight, displayAge)

    -- AutoList must never guess BaseWeight from visible KG.
    -- Visible KG changes with age, and reverse formulas can underprice pets.
    -- Returning nil forces AutoList to use raw PetData.BaseWeight only.
    return nil
end

function ResolveListingPetMutation(displayName, basePetName)

    displayName =
        TrimListingText(
            tostring(displayName or "")
                :gsub("%b[]", "")
                :gsub("%s+", " ")
        )

    basePetName =
        TrimListingText(basePetName)

    if displayName == basePetName then
        return "---"
    end

    local suffixStart =
        displayName:find(basePetName, 1, true)

    if not suffixStart then
        return "---"
    end

    local mutation =
        TrimListingText(
            displayName:sub(1, suffixStart - 1)
        )

    if mutation == "" then
        return "---"
    end

    return mutation
end

ListingMutationList =
    RefreshListingMutationList()

--==================================================
-- LISTINGS: OPTIMIZED RAW PETDATA RESOLVERS
-- BaseWeight = age-1/base/raw size.
-- Level/Age = current visible pet age.
-- No hidden caps. Filters control all limits.
--==================================================

function ResolveListingRawBaseWeight(petData, itemData)

    local sources = {
        petData,
        itemData,
    }

    for _, source in ipairs(sources) do

        if type(source) == "table" then

            local candidates = {
                source.BaseWeight,
                rawget(source, "BaseWeight"),

                source.baseWeight,
                rawget(source, "baseWeight"),

                source.Base_Weight,
                rawget(source, "Base_Weight"),

                source.BaseKg,
                rawget(source, "BaseKg"),

                source.BaseKG,
                rawget(source, "BaseKG"),

                source.Base,
                rawget(source, "Base"),
            }

            for _, value in ipairs(candidates) do

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

function ResolveListingRawLevel(petData, itemData, tool, fallbackAge)

    local sources = {
        petData,
        itemData,
    }

    for _, source in ipairs(sources) do

        if type(source) == "table" then

            local candidates = {
                source.Level,
                rawget(source, "Level"),

                source.level,
                rawget(source, "level"),

                source.Age,
                rawget(source, "Age"),

                source.age,
                rawget(source, "age"),
            }

            for _, value in ipairs(candidates) do

                local number =
                    tonumber(value)

                if number then
                    return math.floor(number)
                end
            end
        end
    end

    if tool then

        local attributeCandidates = {
            tool:GetAttribute("Level"),
            tool:GetAttribute("level"),
            tool:GetAttribute("Age"),
            tool:GetAttribute("age"),
        }

        for _, value in ipairs(attributeCandidates) do

            local number =
                tonumber(value)

            if number then
                return math.floor(number)
            end
        end
    end

    local fallback =
        tonumber(fallbackAge)

    if fallback then
        return math.floor(fallback)
    end

    return nil
end

function ResolveListingPetTool(tool, source)

    if not tool
    or not tool:IsA("Tool") then
        return nil
    end

    if tool:GetAttribute("ItemType") ~= "Pet" then
        return nil
    end

    local uuid =
        tool:GetAttribute("PET_UUID")

    if type(uuid) ~= "string"
    or uuid == "" then
        return nil
    end

    local basePetName =
        tool:GetAttribute("f")

    if type(basePetName) ~= "string"
    or basePetName == "" then
        return nil
    end

    local displayWeight =
        ParseListingDisplayWeight(tool.Name)

    if not displayWeight then
        return nil
    end

    local displayAge =
        ParseListingDisplayAge(tool.Name)

    local mutation =
        ResolveListingPetMutation(
            tool.Name,
            basePetName
        )

    --==================================================
    -- AUTHORITATIVE PETDATA RESOLUTION
    -- Source of truth for AutoList filters:
    -- PetData.BaseWeight = age-1/base/raw weight.
    -- PetData.Level      = visible age.
    --==================================================

    local petData =
        nil

    local itemData =
        nil

    if type(GetHolyInventoryPetDataByUUID) == "function" then

        local ok, resolvedPetData, resolvedItemData =
            pcall(function()
                return GetHolyInventoryPetDataByUUID(uuid)
            end)

        if ok then
            petData =
                resolvedPetData

            itemData =
                resolvedItemData
        end
    end

    local baseWeight =
        nil

    local age =
        displayAge

        baseWeight =
        ResolveListingRawBaseWeight(
            petData,
            itemData
        )

    age =
        ResolveListingRawLevel(
            petData,
            itemData,
            tool,
            displayAge
        )

    --==================================================
    -- STRICT BASEWEIGHT GUARD
    -- AutoList filters are based on age-1 raw BaseWeight only.
    -- Never derive BaseWeight from visible KG, because high-age pets
    -- can be underpriced incorrectly.
    --==================================================

    if not baseWeight then

        warn(
            "[LISTINGS] SKIP | raw PetData.BaseWeight missing:",
            tostring(tool.Name),
            "| DisplayKG:",
            tostring(displayWeight),
            "| Age:",
            tostring(age or displayAge or "Unknown"),
            "| UUID:",
            tostring(uuid)
        )

        return nil
    end

    if not age then
        age =
            displayAge
    end

    return {
        Tool = tool,
        Source = source,

        UUID = uuid,

        ToolName = tool.Name,
        PetName = basePetName,
        Mutation = mutation,

        Weight = displayWeight,

        -- This is now true age-1/base/raw weight from PetData when available.
        BaseWeight = baseWeight,

        Age = age,

        IsFavorite = tool:GetAttribute("d") == true,

        PetData = petData,
        ItemData = itemData,
    }
end

function GetListingInventoryPetSnapshot()

    local snapshot = {}

    local player =
        Players.LocalPlayer

    if not player then
        return snapshot
    end

    local containers = {
        {
            Source = "Backpack",
            Container = player:FindFirstChild("Backpack"),
        },

        {
            Source = "Character",
            Container = player.Character,
        },
    }

    for _, entry in ipairs(containers) do

        local container =
            entry.Container

        if container then

            for _, child in ipairs(container:GetChildren()) do

                local resolved =
                    ResolveListingPetTool(
                        child,
                        entry.Source
                    )

                if resolved then
                    table.insert(
                        snapshot,
                        resolved
                    )
                end
            end
        end
    end

    table.sort(snapshot, function(a, b)

        if a.PetName ~= b.PetName then
            return a.PetName < b.PetName
        end

        if a.Mutation ~= b.Mutation then
            return a.Mutation < b.Mutation
        end

        return a.Weight > b.Weight
    end)

    return snapshot
end

--==================================================
-- LISTINGS: REMOTES
--==================================================

function GetCreateListingRemote()

    if CreateListingRemote then
        return CreateListingRemote
    end

    local gameEvents =
        ReplicatedStorage:FindFirstChild("GameEvents")

    if not gameEvents then
        return nil
    end

    local tradeEvents =
        gameEvents:FindFirstChild("TradeEvents")

    if not tradeEvents then
        return nil
    end

    local booths =
        tradeEvents:FindFirstChild("Booths")

    if not booths then
        return nil
    end

    local remote =
        booths:FindFirstChild("CreateListing")

    if remote
    and remote:IsA("RemoteFunction") then

        CreateListingRemote = remote
        return remote
    end

    return nil
end

function GetRemoveListingRemote()

    if RemoveListingRemote then
        return RemoveListingRemote
    end

    local gameEvents =
        ReplicatedStorage:FindFirstChild("GameEvents")

    if not gameEvents then
        return nil
    end

    local tradeEvents =
        gameEvents:FindFirstChild("TradeEvents")

    if not tradeEvents then
        return nil
    end

    local booths =
        tradeEvents:FindFirstChild("Booths")

    if not booths then
        return nil
    end

    local remote =
        booths:FindFirstChild("RemoveListing")

    if remote
    and remote:IsA("RemoteFunction") then

        RemoveListingRemote = remote
        return remote
    end

    return nil
end

function GetFavoriteRemote()

    if FavoriteRemote then
        return FavoriteRemote
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

        FavoriteRemote = remote
        return remote
    end

    return nil
end

--==================================================
-- LISTINGS: BOOTH-LISTED UUID SYNC
-- Source of truth:
-- TradeBoothController.GetPlayerBoothData upvalue[2]
--
-- Purpose:
-- Prevent AutoList from relisting pets that are already
-- listed on your own booth after rejoin/server hop.
--==================================================

function FetchLatestBoothDataNow()

    if game.PlaceId ~= TRADING_WORLD_PLACE_ID then
        return nil, "Not in Trade World"
    end

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

    if type(data.Booths) ~= "table"
    or type(data.Players) ~= "table" then
        return nil, "Booth data incomplete"
    end

    LatestBoothData =
        data

    LatestBoothUpdate =
        os.clock()

    return data, "Fetched"
end

function RefreshOwnListedUUIDs(forceFetch)

    if type(ListingsState) ~= "table" then
        return 0, "ListingsState missing"
    end

    ListingsState.OwnListedUUIDs =
        ListingsState.OwnListedUUIDs
        or {}

    ListingsState.OwnListedMetadata =
        ListingsState.OwnListedMetadata
        or {}

    table.clear(
        ListingsState.OwnListedUUIDs
    )

    ListingsState.OwnBoothListedSyncReady =
        false

    ListingsState.OwnListedLastSync =
        0

    ListingsState.OwnListedLastCount =
        0

    local data =
        LatestBoothData

    if forceFetch == true
    or type(data) ~= "table"
    or type(data.Booths) ~= "table"
    or type(data.Players) ~= "table" then

        data =
            FetchLatestBoothDataNow()
    end

    if type(data) ~= "table"
    or type(data.Booths) ~= "table"
    or type(data.Players) ~= "table" then

        return 0, "Booth data missing"
    end

    local player =
        Players.LocalPlayer

    if not player then
        return 0, "LocalPlayer missing"
    end

    local localUserId =
        tonumber(player.UserId)

    local ownOwnerKey =
        nil

    for _, boothData in pairs(data.Booths) do

        local owner =
            boothData
            and boothData.Owner

        if owner then

            local ownerUserId =
                tonumber(
                    tostring(owner):match("_(%d+)$")
                )

            if ownerUserId == localUserId then

                ownOwnerKey =
                    owner

                break
            end
        end
    end

    if not ownOwnerKey then
        return 0, "Own booth not found"
    end

    local playerData =
        data.Players[ownOwnerKey]

    if type(playerData) ~= "table" then
        return 0, "Own booth playerData missing"
    end

    local listings =
        playerData.Listings

    -- Own booth exists, but has no listings yet.
    -- This is still a successful sync.
    if type(listings) ~= "table" then

        ListingsState.OwnBoothListedSyncReady =
            true

        ListingsState.OwnListedLastSync =
            os.clock()

        ListingsState.OwnListedLastCount =
            0

        return 0, "Own booth synced, no listings"
    end

    local count =
        0

    for _, listingData in pairs(listings) do

        if type(listingData) ~= "table" then
            continue
        end

        local itemId =
            listingData.ItemId

        if itemId then

            local uuid =
                tostring(itemId)

            ListingsState.OwnListedUUIDs[uuid] =
                true

            count += 1
        end
    end

    ListingsState.OwnBoothListedSyncReady =
        true

    ListingsState.OwnListedLastSync =
        os.clock()

    ListingsState.OwnListedLastCount =
        count

    ListingsState.OwnListedLastPrintAt =
    SafeNumber(
        ListingsState.OwnListedLastPrintAt,
        0
    )

ListingsState.OwnListedLastPrintedCount =
    tonumber(
        ListingsState.OwnListedLastPrintedCount
    )

local shouldPrintOwnListedSync =
    false

if ListingsState.OwnListedLastPrintedCount ~= count then

    shouldPrintOwnListedSync =
        true

elseif os.clock() - ListingsState.OwnListedLastPrintAt >= 30 then

    shouldPrintOwnListedSync =
        true
end

if shouldPrintOwnListedSync then

    ListingsState.OwnListedLastPrintAt =
        os.clock()

    ListingsState.OwnListedLastPrintedCount =
        count

    print(
        "[LISTINGS] Own listed UUID sync:",
        tostring(count)
    )
end

    return count, "Synced"
end

function WaitForOwnListedUUIDSync(timeout)

    timeout =
        SafeNumber(timeout, 12)

    local deadline =
        os.clock() + timeout

    while os.clock() < deadline do

        if ScriptState
        and ScriptState.ForceStopped then
            return false, "Force stopped"
        end

        if game.PlaceId ~= TRADING_WORLD_PLACE_ID then
            return false, "Not in Trade World"
        end

        local count, reason =
            RefreshOwnListedUUIDs(true)

        if ListingsState.OwnBoothListedSyncReady == true then

            return true,
                reason
                or (
                    "Synced "
                    .. tostring(count)
                    .. " own listings"
                )
        end

        ListingsState.Status =
            tostring(reason or "Waiting for own booth sync")

        if type(ListingsStatusRefresh) == "function" then
            pcall(ListingsStatusRefresh)
        end

        task.wait(0.25)
    end

    return false, "Own booth sync timeout"
end

--==================================================
-- LISTINGS: OWN BOOTH LISTING SNAPSHOT
-- UI-facing snapshot of pets currently listed in your booth.
-- Uses the same booth data source as OwnListedUUIDs.
--==================================================

function ShortenListingText(value, maxLength)

    value =
        tostring(value or "")

    maxLength =
        tonumber(maxLength)
        or 24

    if #value <= maxLength then
        return value
    end

    if maxLength <= 3 then
        return value:sub(1, maxLength)
    end

    return value:sub(1, maxLength - 3) .. "..."
end

function PadRightListingText(value, width)

    value =
        tostring(value or "")

    width =
        tonumber(width)
        or 1

    if #value >= width then
        return value
    end

    return value .. string.rep(" ", width - #value)
end

function PadLeftListingText(value, width)

    value =
        tostring(value or "")

    width =
        tonumber(width)
        or 1

    if #value >= width then
        return value
    end

    return string.rep(" ", width - #value) .. value
end

function FormatOwnBoothCompactPrice(value)

    local number =
        tonumber(value)
        or 0

    number =
        math.floor(number)

    local text =
        tostring(number)

    local left, num, right =
        string.match(text, "^([^%d]*%d)(%d*)(.-)$")

    if not left then
        return text
    end

    return left
        .. (
            num:reverse()
                :gsub("(%d%d%d)", "%1,")
                :reverse()
        )
        .. right
end

function FormatOwnBoothListedPetLine(index, item)

    if type(item) ~= "table" then

        return string.format(
    "%02d %-30s %9s %7s",
    tonumber(index) or 0,
    "-",
    "-",
    "-"
)
    end

    local petName =
        tostring(item.PetName or "Unknown")

    local mutation =
        tostring(item.MutationText or "Normal")

    local displayName =
        petName

    if mutation ~= ""
    and mutation ~= "Normal"
    and mutation ~= "Unknown"
    and mutation ~= "---" then

        displayName =
            mutation .. " " .. petName
    end

    displayName =
        ShortenListingText(
            displayName,
            30
        )

    local priceText =
        FormatOwnBoothCompactPrice(
            item.Price
        )

    local baseWeight =
        tonumber(item.BaseWeight)

    local weightText =
        baseWeight
        and (
            string.format("%.2f", baseWeight)
            .. "bw"
        )
        or "-"

    local age =
        tonumber(item.Age)

    local icon =
        age
        and age >= 100
        and "★"
        or "•"

    return string.format(
    "%s %-30s %9s %7s",
    icon,
    displayName,
    priceText,
    weightText
)
end

function ResolveBoothMutationTypeText(value)

    value =
        tostring(value or "")

    if value == ""
    or value == "nil"
    or value == "---"
    or value == "Normal" then
        return nil
    end

    local registry =
        type(GetPetRegistry) == "function"
        and GetPetRegistry()
        or nil

    local mutationRoot =
        type(registry) == "table"
        and rawget(registry, "PetMutationRegistry")
        or nil

    local enumToPetMutation =
        type(mutationRoot) == "table"
        and rawget(mutationRoot, "EnumToPetMutation")
        or nil

    if type(enumToPetMutation) == "table" then

        local direct =
            enumToPetMutation[value]

        if type(direct) == "string"
        and direct ~= "" then
            return direct
        end

        for enumValue, mutationName in pairs(enumToPetMutation) do

            if tostring(enumValue) == value
            and type(mutationName) == "string"
            and mutationName ~= "" then
                return mutationName
            end
        end
    end

    local petMutationToEnum =
        type(mutationRoot) == "table"
        and rawget(mutationRoot, "PetMutationToEnum")
        or nil

    if type(petMutationToEnum) == "table" then

        for mutationName, enumValue in pairs(petMutationToEnum) do

            if tostring(enumValue) == value
            and type(mutationName) == "string"
            and mutationName ~= "" then
                return mutationName
            end
        end
    end

    -- Fallback for known event codes if registry lookup is late.
    local hardFallback = {
        EV = "Everchanted",
    }

    if hardFallback[value] then
        return hardFallback[value]
    end

    -- Last fallback: show the raw code instead of hiding it.
    return value
end

function ResolveBoothListingMutationText(petData, itemData)

    local candidates = {}

    if type(petData) == "table" then

        table.insert(candidates, rawget(petData, "MutationType"))
        table.insert(candidates, rawget(petData, "Mutation"))
        table.insert(candidates, rawget(petData, "Variant"))
    end

    if type(itemData) == "table" then

        table.insert(candidates, rawget(itemData, "MutationType"))
        table.insert(candidates, rawget(itemData, "Mutation"))
        table.insert(candidates, rawget(itemData, "Variant"))
    end

    for _, value in ipairs(candidates) do

        local resolved =
            ResolveBoothMutationTypeText(value)

        if resolved
        and resolved ~= ""
        and resolved ~= "---"
        and resolved ~= "Normal" then
            return resolved
        end
    end

    if type(ResolvePetMutationTextFromPetData) == "function" then

        local fallback =
            ResolvePetMutationTextFromPetData(petData)

        if fallback
        and fallback ~= ""
        and fallback ~= "---"
        and fallback ~= "Normal"
        and fallback ~= "Unknown" then
            return fallback
        end
    end

    return "Normal"
end

function BuildOwnBoothListingSnapshot(forceFetch)

    if type(ListingsState) ~= "table" then
        return {}, "ListingsState missing"
    end

    ListingsState.OwnBoothSnapshot =
        ListingsState.OwnBoothSnapshot
        or {}

    table.clear(
        ListingsState.OwnBoothSnapshot
    )

    if game.PlaceId ~= TRADING_WORLD_PLACE_ID then

        ListingsState.OwnBoothSnapshotStatus =
            "Garden Mode"

        return ListingsState.OwnBoothSnapshot,
            ListingsState.OwnBoothSnapshotStatus
    end

    local data =
        LatestBoothData

    if forceFetch == true
    or type(data) ~= "table"
    or type(data.Booths) ~= "table"
    or type(data.Players) ~= "table" then

        data =
            FetchLatestBoothDataNow()
    end

    if type(data) ~= "table"
    or type(data.Booths) ~= "table"
    or type(data.Players) ~= "table" then

        ListingsState.OwnBoothSnapshotStatus =
            "Booth data missing"

        return ListingsState.OwnBoothSnapshot,
            ListingsState.OwnBoothSnapshotStatus
    end

    local player =
        Players.LocalPlayer

    if not player then

        ListingsState.OwnBoothSnapshotStatus =
            "LocalPlayer missing"

        return ListingsState.OwnBoothSnapshot,
            ListingsState.OwnBoothSnapshotStatus
    end

    local localUserId =
        tonumber(player.UserId)

    local ownOwnerKey =
        nil

    for _, boothData in pairs(data.Booths) do

        local owner =
            boothData
            and boothData.Owner

        if owner then

            local ownerUserId =
                tonumber(
                    tostring(owner):match("_(%d+)$")
                )

            if ownerUserId == localUserId then

                ownOwnerKey =
                    owner

                break
            end
        end
    end

    if not ownOwnerKey then

        ListingsState.OwnBoothSnapshotStatus =
            "Own booth not found"

        return ListingsState.OwnBoothSnapshot,
            ListingsState.OwnBoothSnapshotStatus
    end

    local playerData =
        data.Players[ownOwnerKey]

    if type(playerData) ~= "table" then

        ListingsState.OwnBoothSnapshotStatus =
            "Own booth data missing"

        return ListingsState.OwnBoothSnapshot,
            ListingsState.OwnBoothSnapshotStatus
    end

    local listings =
        playerData.Listings

    local items =
        playerData.Items

    if type(listings) ~= "table"
    or type(items) ~= "table" then

        ListingsState.OwnBoothSnapshotStatus =
            "No active listings"

        ListingsState.OwnBoothSnapshotLastRefresh =
            os.clock()

        return ListingsState.OwnBoothSnapshot,
            ListingsState.OwnBoothSnapshotStatus
    end

    for listingUid, listingData in pairs(listings) do

        if type(listingData) ~= "table" then
            continue
        end

        local itemId =
            listingData.ItemId

        if not itemId then
            continue
        end

        local itemData =
            items[itemId]

        if type(itemData) ~= "table" then
            continue
        end

        local petData =
            itemData.PetData

        local petName =
            tostring(
                itemData.PetType
                or "Unknown"
            )

        local price =
            tonumber(listingData.Price)
            or 0

        local baseWeight =
            type(petData) == "table"
            and tonumber(petData.BaseWeight)
            or nil

        local displayWeight =
            baseWeight
            and ResolveDisplayedWeight(baseWeight)
            or nil

        local age =
            type(petData) == "table"
            and (
                tonumber(petData.Level)
                or tonumber(petData.Age)
            )
            or nil

        local mutationText =
    ResolveBoothListingMutationText(
        petData,
        itemData
    )

        table.insert(
            ListingsState.OwnBoothSnapshot,
            {
                ListingUID =
                    tostring(listingUid),

                UUID =
                    tostring(itemId),

                PetName =
                    petName,

                MutationText =
                    mutationText,

                Price =
                    price,

                Age =
                    age,

                BaseWeight =
                    baseWeight,

                DisplayWeight =
                    displayWeight,
            }
        )
    end

    table.sort(
        ListingsState.OwnBoothSnapshot,
        function(a, b)

            local aPrice =
                tonumber(a.Price)
                or 0

            local bPrice =
                tonumber(b.Price)
                or 0

            if aPrice ~= bPrice then
                return aPrice > bPrice
            end

            return tostring(a.PetName) < tostring(b.PetName)
        end
    )

    ListingsState.OwnBoothSnapshotLastRefresh =
        os.clock()

    ListingsState.OwnBoothSnapshotStatus =
        "Synced"

    return ListingsState.OwnBoothSnapshot,
        ListingsState.OwnBoothSnapshotStatus
end

function RefreshOwnBoothListingSnapshotThrottled()

    if type(ListingsState) ~= "table" then
        return
    end

    local lastRefresh =
        SafeNumber(
            ListingsState.OwnBoothSnapshotLastRefresh,
            0
        )

    if os.clock() - lastRefresh < 3 then
        return
    end

    BuildOwnBoothListingSnapshot(false)
end

--==================================================
-- LISTINGS: REMOVE OWN BOOTH LISTINGS
-- RemoveListing confirmed by console:
-- RemoveListing:InvokeServer(listingUID)
--==================================================

function ClearAutoListRuntimeQueuesForRemoval()

    if type(ListingsState) ~= "table" then
        return
    end

    ListingsState.ListingQueue =
        ListingsState.ListingQueue
        or {}

    ListingsState.QueuedUUIDs =
        ListingsState.QueuedUUIDs
        or {}

    ListingsState.PendingUUIDs =
        ListingsState.PendingUUIDs
        or {}

    table.clear(ListingsState.ListingQueue)
    table.clear(ListingsState.QueuedUUIDs)

    ListingsState.ActiveCreateUUID =
        nil

    ListingsState.ActiveCreateStartedAt =
        0

    ListingsState.Busy =
        false

    ListingsState.NoWorkSleepUntil =
        os.clock() + 5
end

function PauseAutoListForBoothRemoval(reason)

    if type(ListingsState) ~= "table" then
        return
    end

    ListingsState.Enabled =
        false

    ListingsState.VisualTagsEnabled =
        false

    ListingsState.Status =
        tostring(reason or "Booth removal paused AutoList")

    ClearAutoListRuntimeQueuesForRemoval()

    if Library
and Library.Options then

    local autoListOption =
        Library.Options.EnableAutoList
        or Library.Options.StartAutoList

    if autoListOption
    and type(autoListOption.SetValue) == "function" then

        pcall(function()
            autoListOption:SetValue(false)
        end)
    end
end

    if type(ListingsStatusRefresh) == "function" then
        pcall(ListingsStatusRefresh)
    end
end

function RemoveOwnBoothListingByUID(listingUID, item)

    listingUID =
        tostring(listingUID or "")

    if listingUID == "" then
        return false, "Missing listing UID"
    end

    if ScriptState
    and ScriptState.ForceStopped then
        return false, "Force stopped"
    end

    if game.PlaceId ~= TRADING_WORLD_PLACE_ID then
        return false, "Not in Trade World"
    end

    local remote =
        GetRemoveListingRemote()

    if not remote then
        return false, "RemoveListing remote missing"
    end

    local ok, result =
        pcall(function()
            return remote:InvokeServer(listingUID)
        end)

    if not ok then
        return false, tostring(result)
    end

    if result == false then
        return false, "Server returned false"
    end

    if type(item) == "table" then

        local uuid =
            tostring(item.UUID or "")

        if uuid ~= "" then

            ListingsState.OwnListedUUIDs =
                ListingsState.OwnListedUUIDs
                or {}

            ListingsState.ListedUUIDs =
                ListingsState.ListedUUIDs
                or {}

            ListingsState.PendingUUIDs =
                ListingsState.PendingUUIDs
                or {}

            ListingsState.OwnListedUUIDs[uuid] =
                nil

            ListingsState.ListedUUIDs[uuid] =
                nil

            -- Short deferral so AutoList does not instantly relist
            -- before the user sees the booth refresh.
            MarkListingUUIDPending(
                uuid,
                30
            )
        end
    end

    print(
        "[LISTINGS] Removed booth listing:",
        tostring(listingUID),
        "|",
        item
        and tostring(item.PetName or "Unknown")
        or "Unknown"
    )

    return true, result
end

function GetOwnBoothSnapshotAbsoluteIndex(pageIndex)

    pageIndex =
        math.max(
            1,
            math.floor(
                SafeNumber(pageIndex, 1)
            )
        )

    local page =
        math.max(
            1,
            math.floor(
                SafeNumber(
                    ListingsState.OwnBoothSnapshotPage,
                    1
                )
            )
        )

    local perPage =
        math.max(
            1,
            math.floor(
                SafeNumber(
                    ListingsState.OwnBoothSnapshotPerPage,
                    7
                )
            )
        )

    return ((page - 1) * perPage) + pageIndex
end

function RemoveOwnBoothSnapshotPageIndex(pageIndex)

    if type(ListingsState) ~= "table" then
        return false, "ListingsState missing"
    end

    BuildOwnBoothListingSnapshot(true)

    local absoluteIndex =
        GetOwnBoothSnapshotAbsoluteIndex(pageIndex)

    local item =
        ListingsState.OwnBoothSnapshot
        and ListingsState.OwnBoothSnapshot[absoluteIndex]

    if type(item) ~= "table" then
        return false, "No listing at page index " .. tostring(pageIndex)
    end

    local listingUID =
        tostring(item.ListingUID or "")

    if listingUID == "" then
        return false, "Selected listing has no ListingUID"
    end

    local ok, reason =
        RemoveOwnBoothListingByUID(
            listingUID,
            item
        )

    task.wait(0.35)

    BuildOwnBoothListingSnapshot(true)
    RefreshOwnListedUUIDs(true)

    if type(ListingsStatusRefresh) == "function" then
        pcall(ListingsStatusRefresh)
    end

    return ok, reason
end

function RemoveAllOwnBoothListings()

    if type(ListingsState) ~= "table" then
        return 0, 0, "ListingsState missing"
    end

    PauseAutoListForBoothRemoval(
        "Removing all booth listings"
    )

    local removed =
        0

    local failed =
        0

    local seenListingUIDs =
        {}

    local maxPasses =
        8

    for pass = 1, maxPasses do

        local snapshot =
            BuildOwnBoothListingSnapshot(true)

        if type(snapshot) ~= "table"
        or #snapshot <= 0 then

            ListingsState.Status =
                "Booth empty"

            break
        end

        print(
            "[LISTINGS] Remove all pass:",
            tostring(pass),
            "| found:",
            tostring(#snapshot)
        )

        local removedThisPass =
            0

        for _, item in ipairs(snapshot) do

            if type(item) ~= "table" then
                failed += 1
                continue
            end

            local listingUID =
                tostring(item.ListingUID or "")

            if listingUID == "" then
                failed += 1
                continue
            end

            -- Prevent retrying the exact same listing forever if booth data lags.
            if seenListingUIDs[listingUID] then
                continue
            end

            seenListingUIDs[listingUID] =
                true

            local ok, reason =
                RemoveOwnBoothListingByUID(
                    listingUID,
                    item
                )

            if ok then

                removed += 1
                removedThisPass += 1

            else

                failed += 1

                warn(
                    "[LISTINGS] Remove all failed:",
                    tostring(listingUID),
                    tostring(reason)
                )
            end

            task.wait(0.18)
        end

        task.wait(0.75)

        BuildOwnBoothListingSnapshot(true)
        RefreshOwnListedUUIDs(true)

        if type(ListingsStatusRefresh) == "function" then
            pcall(ListingsStatusRefresh)
        end

        -- If this pass could not remove anything new, stop instead of looping forever.
        if removedThisPass <= 0 then
            break
        end
    end

    task.wait(0.50)

    local finalSnapshot =
        BuildOwnBoothListingSnapshot(true)

    RefreshOwnListedUUIDs(true)

    local remaining =
        type(finalSnapshot) == "table"
        and #finalSnapshot
        or 0

    if remaining > 0 then

        ListingsState.Status =
            "Remove all partial: "
            .. tostring(remaining)
            .. " remaining"

    else

        ListingsState.Status =
            "Removed all booth listings"
    end

    ListingsState.OwnBoothSnapshotPage =
        1

    if type(ListingsStatusRefresh) == "function" then
        pcall(ListingsStatusRefresh)
    end

    return removed, failed, remaining > 0
        and ("Remaining: " .. tostring(remaining))
        or "Done"
end
--==================================================
-- LISTINGS: PRICE SAFETY
--==================================================

function SyncListingRequiredFlagsFromValues()

    if type(ListingsState) ~= "table" then
        return
    end

    local price =
        tonumber(ListingsState.Price)

    ListingsState.PriceWasEntered =
        price ~= nil
        and price > 0

    if ListingsState.PriceWasEntered then
        ListingsState.Price =
            math.floor(price)
    end

    local minWeight =
        tonumber(ListingsState.MinWeight)

    ListingsState.MinWeightWasEntered =
        minWeight ~= nil
        and minWeight >= 0

    if ListingsState.MinWeightWasEntered then
        ListingsState.MinWeight =
            minWeight
    end

    local maxWeight =
        tonumber(ListingsState.MaxWeight)

    ListingsState.MaxWeightWasEntered =
        maxWeight ~= nil
        and maxWeight >= 0

    if ListingsState.MaxWeightWasEntered then
        ListingsState.MaxWeight =
            maxWeight
    end
end

function IsListingPriceAllowed()

    if type(ListingsState) ~= "table" then
        return false, "ListingsState missing"
    end

    SyncListingRequiredFlagsFromValues()

    local price =
        tonumber(ListingsState.Price)

    if not price
    or price <= 0 then
        return false, "Price required"
    end

    ListingsState.LowPriceThreshold =
        tonumber(ListingsState.LowPriceThreshold)
        or 10

    if price < ListingsState.LowPriceThreshold
    and ListingsState.AllowLowPriceListings ~= true then
        return false, "Low price blocked"
    end

    return true, "OK"
end

function IsListingConfigurationAllowed()

    if type(ListingsState) ~= "table" then
        return false, "ListingsState missing"
    end

    -- Multi-filter mode:
    -- If filters exist, at least one valid active filter is enough.
    if CountListingFilters() > 0 then

        local activeValid =
            0

        for _, filter in ipairs(EnsureListingFilters()) do

            if filter.Enabled ~= false then

                local allowed =
                    IsListingFilterAllowed(filter)

                if allowed then
                    activeValid += 1
                end
            end
        end

        if activeValid <= 0 then
            return false, "No valid listing filters"
        end

        return true, "OK"
    end

    -- Legacy single-filter mode.
    local filter =
        BuildCurrentListingFilter()

    return IsListingFilterAllowed(filter)
end

--==================================================
-- LISTINGS: FILTER / PREVIEW
--==================================================
--==================================================
-- LISTINGS: SPEED CONFIG
--==================================================

function ResolveListingSpeedConfig(mode)

    mode =
        tostring(mode or "Adaptive")

    --==================================================
    -- Adaptive:
    -- Starts at 5s because console testing confirmed:
    -- 1s / 2s / 3s / 4s = server rejected
    -- 5s / 6s = accepted
    --==================================================

    if mode == "Adaptive" then
        return {
            ScanInterval = 1,
            CreateCooldown = 5,
            MaxQueuePerPass = 2,
            Adaptive = true,
        }
    end

    if mode == "Safe" then
        return {
            ScanInterval = 4,
            CreateCooldown = 7,
            MaxQueuePerPass = 1,
            Adaptive = false,
        }
    end

    if mode == "Balanced" then
        return {
            ScanInterval = 2,
            CreateCooldown = 5,
            MaxQueuePerPass = 2,
            Adaptive = false,
        }
    end

    if mode == "Fast" then
        return {
            ScanInterval = 1,
            CreateCooldown = 5,
            MaxQueuePerPass = 3,
            Adaptive = false,
        }
    end

    if mode == "Aggressive" then
        return {
            ScanInterval = 0.5,
            CreateCooldown = 5,
            MaxQueuePerPass = 5,
            Adaptive = false,
        }
    end

    return {
        ScanInterval = 1,
        CreateCooldown = 5,
        MaxQueuePerPass = 2,
        Adaptive = true,
    }
end

function SetListingSpeedMode(mode)

    mode =
        tostring(mode or "Adaptive")

    local allowed = {
        Adaptive = true,
        Safe = true,
        Balanced = true,
        Fast = true,
        Aggressive = true,
    }

    if not allowed[mode] then
        mode =
            "Adaptive"
    end

    local config =
        ResolveListingSpeedConfig(mode)

    ListingsState.ListingSpeedMode =
        mode

    ListingsState.ScanInterval =
        config.ScanInterval

    ListingsState.CreateCooldown =
        config.CreateCooldown

    ListingsState.MaxQueuePerPass =
        config.MaxQueuePerPass

    if config.Adaptive == true then

        ListingsState.AdaptiveCreateCooldown =
            math.clamp(
                SafeNumber(
                    ListingsState.AdaptiveCreateCooldown,
                    config.CreateCooldown
                ),
                SafeNumber(ListingsState.AdaptiveMinCooldown, 5),
                SafeNumber(ListingsState.AdaptiveMaxCooldown, 10)
            )

    else

        ListingsState.AdaptiveCreateCooldown =
            config.CreateCooldown

        ListingsState.AdaptiveSuccessStreak =
            0
    end

    return config
end

function IsAdaptiveListingMode()

    return tostring(
        ListingsState
        and ListingsState.ListingSpeedMode
        or ""
    ) == "Adaptive"
end

function ResolveListingCreateCooldown()

    if not ListingsState then
        return 5
    end

    if IsAdaptiveListingMode() then

        return math.clamp(
            SafeNumber(
                ListingsState.AdaptiveCreateCooldown,
                5
            ),
            SafeNumber(
                ListingsState.AdaptiveMinCooldown,
                5
            ),
            SafeNumber(
                ListingsState.AdaptiveMaxCooldown,
                10
            )
        )
    end

    return math.max(
        SafeNumber(
            ListingsState.CreateCooldown,
            5
        ),
        5
    )
end

function AdaptiveListingRegisterCreateSuccess()

    if not IsAdaptiveListingMode() then
        return
    end

    ListingsState.AdaptiveSuccessStreak =
        SafeNumber(
            ListingsState.AdaptiveSuccessStreak,
            0
        ) + 1

    -- Keep 5s as the proven safe floor.
    -- After several clean successes, gently return toward 5s.
    if ListingsState.AdaptiveSuccessStreak >= 3 then

        ListingsState.AdaptiveCreateCooldown =
            math.max(
                SafeNumber(
                    ListingsState.AdaptiveMinCooldown,
                    5
                ),
                SafeNumber(
                    ListingsState.AdaptiveCreateCooldown,
                    5
                ) - 0.25
            )

        ListingsState.AdaptiveSuccessStreak =
            0

        print(
            "[LISTINGS ADAPTIVE] Success tune | cooldown:",
            tostring(ListingsState.AdaptiveCreateCooldown)
        )
    end
end

function AdaptiveListingRegisterCreateWait(reason)

    if not ListingsState then
        return
    end

    ListingsState.AdaptiveLastWaitSignal =
        os.clock()

    ListingsState.AdaptiveSuccessStreak =
        0

    if IsAdaptiveListingMode() then

        ListingsState.AdaptiveCreateCooldown =
            math.min(
                SafeNumber(
                    ListingsState.AdaptiveMaxCooldown,
                    10
                ),
                SafeNumber(
                    ListingsState.AdaptiveCreateCooldown,
                    5
                ) + 1
            )

        print(
            "[LISTINGS ADAPTIVE] Server wait detected | cooldown:",
            tostring(ListingsState.AdaptiveCreateCooldown),
            "| reason:",
            tostring(reason or "unknown")
        )
    end
end
--==================================================
-- LISTINGS: MULTI-FILTER ENGINE
--==================================================

function NormalizeListingFilterMutation(value)

    value =
        tostring(value or "---")

    if value == ""
    or value == "Normal"
    or value == "Any"
    or value == "All" then
        return "---"
    end

    if value == "All Except"
    or value == "AllExcept" then
        return "All Except"
    end

    return value
end

function NormalizeListingPetMutationValue(value)

    value =
        tostring(value or "---")

    if value == ""
    or value == "nil"
    or value == "Normal"
    or value == "Unknown" then
        return "---"
    end

    return value
end

function CloneListingMutationMap(source)

    local output =
        {}

    if type(source) ~= "table" then
        return output
    end

    for mutationName, enabled in pairs(source) do

        if enabled == true then

            mutationName =
                NormalizeListingFilterMutation(
                    mutationName
                )

            if mutationName ~= ""
            and mutationName ~= "---"
            and mutationName ~= "All Except" then
                output[mutationName] =
                    true
            end
        end
    end

    return output
end

function BuildListingMutationMapFromDropdownValue(value)

    local output =
        {}

    if type(value) ~= "table" then
        return output
    end

    for key, selected in pairs(value) do

        local mutationName =
            nil

        -- Common Obsidian multi-dropdown shape:
        -- { Golden = true, Rainbow = true }
        if selected == true then
            mutationName =
                key

        -- Fallback array shape:
        -- { "Golden", "Rainbow" }
        elseif type(selected) == "string" then
            mutationName =
                selected
        end

        mutationName =
            NormalizeListingFilterMutation(
                mutationName
            )

        if mutationName ~= ""
        and mutationName ~= "---"
        and mutationName ~= "All Except" then
            output[mutationName] =
                true
        end
    end

    return output
end

function SerializeListingMutationMap(source)

    local output =
        {}

    source =
        CloneListingMutationMap(source)

    for mutationName, enabled in pairs(source) do

        if enabled == true then
            table.insert(
                output,
                tostring(mutationName)
            )
        end
    end

    table.sort(output)

    return output
end

function DeserializeListingMutationMap(source)

    local output =
        {}

    if type(source) ~= "table" then
        return output
    end

    for key, value in pairs(source) do

        local mutationName =
            nil

        if value == true then
            mutationName =
                key

        elseif type(value) == "string" then
            mutationName =
                value
        end

        mutationName =
            NormalizeListingFilterMutation(
                mutationName
            )

        if mutationName ~= ""
        and mutationName ~= "---"
        and mutationName ~= "All Except" then
            output[mutationName] =
                true
        end
    end

    return output
end

function CountListingMutationMap(source)

    local count =
        0

    if type(source) ~= "table" then
        return 0
    end

    for _, enabled in pairs(source) do
        if enabled == true then
            count += 1
        end
    end

    return count
end

function FormatExcludedListingMutations(source)

    local names =
        SerializeListingMutationMap(source)

    if #names <= 0 then
        return "None"
    end

    if #names <= 3 then
        return table.concat(names, ", ")
    end

    return tostring(#names) .. " blocked"
end

function EnsureListingFilters()

    ListingsState.ListingFilters =
        ListingsState.ListingFilters
        or {}

    ListingsState.ListingFilterUI =
        ListingsState.ListingFilterUI
        or {
            Page = 1,
            PerPage = 8,
        }

    return ListingsState.ListingFilters
end

function CountListingFilters()

    local filters =
        EnsureListingFilters()

    return #filters
end

function CountActiveListingFilters()

    local filters =
        EnsureListingFilters()

    local count =
        0

    for _, filter in ipairs(filters) do

        if type(filter) == "table"
        and filter.Enabled ~= false then
            count += 1
        end
    end

    return count
end

function IsListingPriceAllowedValue(price)

    price =
        tonumber(price)

    if not price
    or price <= 0 then
        return false, "Price required"
    end

    ListingsState.LowPriceThreshold =
        tonumber(ListingsState.LowPriceThreshold)
        or 10

    if price < ListingsState.LowPriceThreshold
    and ListingsState.AllowLowPriceListings ~= true then
        return false, "Low price blocked"
    end

    return true, "OK"
end

function IsListingFilterAllowed(filter)

    if type(filter) ~= "table" then
        return false, "Filter missing"
    end

    local petName =
        tostring(filter.Pet or "")

    if petName == "" then
        return false, "Pet required"
    end

    local minLevel =
    tonumber(filter.MinLevel)
    or 1

local maxLevel =
    tonumber(filter.MaxLevel)
    or 100

if minLevel < 1 then
    return false, "Min Level required"
end

if maxLevel < minLevel then
    return false, "Max Level must be >= Min Level"
end

    local minWeight =
        tonumber(filter.MinWeight)

    local maxWeight =
        tonumber(filter.MaxWeight)

    if not minWeight
    or minWeight < 0 then
        return false, "Min BaseWeight required"
    end

    if not maxWeight
    or maxWeight < 0 then
        return false, "Max BaseWeight required"
    end

    if maxWeight < minWeight then
        return false, "Max must be >= Min"
    end

    local priceAllowed, priceReason =
        IsListingPriceAllowedValue(
            filter.Price
        )

    if not priceAllowed then
        return false, priceReason
    end

    return true, "OK"
end

function BuildCurrentListingFilter()

    SyncListingRequiredFlagsFromValues()

    return {
        Pet =
            tostring(ListingsState.SelectedPet or ""),

        Mutation =
    NormalizeListingFilterMutation(
        ListingsState.SelectedMutation
    ),

ExcludedMutations =
    CloneListingMutationMap(
        ListingsState.SelectedExcludedMutations
    ),

MinLevel =
    tonumber(ListingsState.MinLevel)
    or 1,

MaxLevel =
    tonumber(ListingsState.MaxLevel)
    or 100,

MinWeight =
    tonumber(ListingsState.MinWeight),

        MaxWeight =
            tonumber(ListingsState.MaxWeight),

        Price =
            tonumber(ListingsState.Price),

        Enabled =
            true,
    }
end

function GetListingFilterKey(filter)

    if type(filter) ~= "table" then
        return ""
    end

    local mutation =
        NormalizeListingFilterMutation(
            filter.Mutation
        )

    local excludedText =
        ""

    if mutation == "All Except" then
        excludedText =
            table.concat(
                SerializeListingMutationMap(
                    filter.ExcludedMutations
                ),
                ","
            )
    end

    return table.concat({
        tostring(filter.Pet or ""),
        tostring(mutation),
        tostring(excludedText),
        tostring(tonumber(filter.MinLevel) or 1),
        tostring(tonumber(filter.MaxLevel) or 100),
        tostring(tonumber(filter.MinWeight) or ""),
        tostring(tonumber(filter.MaxWeight) or ""),
        tostring(tonumber(filter.Price) or ""),
    }, "|")
end

function AddCurrentListingFilter()

    local filter =
        BuildCurrentListingFilter()

    local allowed, reason =
        IsListingFilterAllowed(filter)

    if not allowed then

        ListingsState.Status =
            reason

        if type(ListingsStatusRefresh) == "function" then
            ListingsStatusRefresh()
        end

        HolyNotify(
            "Filter Blocked",
            tostring(reason),
            "shield-alert",
            4
        )

        return false, reason
    end

    local filters =
        EnsureListingFilters()

    local newKey =
        GetListingFilterKey(filter)

    for _, existing in ipairs(filters) do

        if GetListingFilterKey(existing) == newKey then

            ListingsState.Status =
                "Filter already exists"

            HolyNotify(
                "Duplicate Filter",
                "This listing filter already exists.",
                "copy-x",
                3
            )

            return false, "Duplicate"
        end
    end

    table.insert(
        filters,
        filter
    )

    ListingsState.NoWorkSleepUntil =
        0

    BuildListingPreview()
    MarkConfigDirty()

    if type(SaveListingFilters) == "function" then
        SaveListingFilters()
    end

    if type(RefreshListingFilterUI) == "function" then
        RefreshListingFilterUI()
    end

    if type(ListingsStatusRefresh) == "function" then
        ListingsStatusRefresh()
    end

local mutationText =
    NormalizeListingFilterMutation(
        filter.Mutation
    )

if mutationText == "All Except" then

    mutationText =
        "except "
        .. FormatExcludedListingMutations(
            filter.ExcludedMutations
        )

elseif mutationText == "---" then

    mutationText =
        "All mutations"
end

HolyNotify(
    "Listing Filter Added",
    tostring(filter.Pet)
        .. " | "
        .. tostring(mutationText)
        .. " | Lv "
        .. tostring(filter.MinLevel or 1)
        .. "-"
        .. tostring(filter.MaxLevel or 100)
        .. " | BW "
        .. tostring(filter.MinWeight or "?")
        .. "-"
        .. tostring(filter.MaxWeight or "?")
        .. " | "
        .. tostring(filter.Price or "?")
        .. "T",
    "list-plus",
    4
)

    return true, filter
end

function ClearListingFilters()

    table.clear(
        EnsureListingFilters()
    )

    ListingsState.ListingFilterUI.Page =
        1

    ListingsState.NoWorkSleepUntil =
        0

    BuildListingPreview()
    MarkConfigDirty()

    if type(SaveListingFilters) == "function" then
        SaveListingFilters()
    end

    if type(RefreshListingFilterUI) == "function" then
        RefreshListingFilterUI()
    end

    if type(ListingsStatusRefresh) == "function" then
        ListingsStatusRefresh()
    end

    HolyNotify(
        "Listing Filters Cleared",
        "All listing filters were removed.",
        "trash",
        3
    )
end

function RemoveListingFilterAt(index)

    local filters =
        EnsureListingFilters()

    index =
        tonumber(index)

    if not index
    or not filters[index] then
        return false
    end

    table.remove(
        filters,
        index
    )

    local maxPage =
        math.max(
            1,
            math.ceil(
                #filters
                / SafeNumber(
                    ListingsState.ListingFilterUI.PerPage,
                    8
                )
            )
        )

    ListingsState.ListingFilterUI.Page =
        math.clamp(
            SafeNumber(
                ListingsState.ListingFilterUI.Page,
                1
            ),
            1,
            maxPage
        )

    BuildListingPreview()
    MarkConfigDirty()

    if type(SaveListingFilters) == "function" then
        SaveListingFilters()
    end

    if type(RefreshListingFilterUI) == "function" then
        RefreshListingFilterUI()
    end

    if type(ListingsStatusRefresh) == "function" then
        ListingsStatusRefresh()
    end

    return true
end
--==================================================
-- LISTINGS UI: FILTER DISPLAY FORMATTERS
-- UI-only. Does not affect matching/listing logic.
--==================================================

function FormatListingTokenAmount(value)

    local number =
        tonumber(value)
        or 0

    number =
        math.floor(number)

    local text =
        tostring(number)

    local left, num, right =
        string.match(
            text,
            "^([^%d]*%d)(%d*)(.-)$"
        )

    if not left then
        return text .. " tokens"
    end

    return left
        .. (
            num:reverse()
                :gsub("(%d%d%d)", "%1,")
                :reverse()
        )
        .. right
        .. " tokens"
end

function FormatListingNumber(value)

    local number =
        tonumber(value)

    if not number then
        return "?"
    end

    if number % 1 == 0 then
        return tostring(number)
    end

    return string.format("%.2f", number)
        :gsub("0+$", "")
        :gsub("%.$", "")
end

function FormatListingMutationDisplay(value)

    local mutation =
        NormalizeListingFilterMutation(
            value
        )

    if mutation == "---" then
        return "🧬 Any"
    end

    return "🧬 " .. tostring(mutation)
end

function FormatListingFilterLine(index, filter)

    if type(filter) ~= "table" then
        return string.format(
            "%02d -",
            tonumber(index) or 0
        )
    end

    local function FormatShortNumber(value)

        local number =
            tonumber(value)

        if not number then
            return "?"
        end

        if number % 1 == 0 then
            return tostring(number)
        end

        return string.format("%.2f", number)
            :gsub("0+$", "")
            :gsub("%.$", "")
    end

    local function FormatCompactTokens(value)

        local number =
            tonumber(value)
            or 0

        number =
            math.floor(number)

        if number >= 1000000 then

            return string.format(
                "%.1fm",
                number / 1000000
            ):gsub("%.0m", "m")
        end

        if number >= 1000 then

            return string.format(
                "%.1fk",
                number / 1000
            ):gsub("%.0k", "k")
        end

        return tostring(number)
    end

    local function ShortenText(text, maxLength)

        text =
            tostring(text or "")

        maxLength =
            tonumber(maxLength)
            or 18

        if #text <= maxLength then
            return text
        end

        return text:sub(1, maxLength - 1) .. "…"
    end

    local mutation =
    NormalizeListingFilterMutation(
        filter.Mutation
    )

local petName =
    tostring(filter.Pet or "?")

local nameText =
    petName

if mutation == "All Except" then

    nameText =
        petName
        .. " | except "
        .. FormatExcludedListingMutations(
            filter.ExcludedMutations
        )

elseif mutation ~= "---" then

    nameText =
        tostring(mutation)
        .. " "
        .. petName
end

    nameText =
        ShortenText(
            nameText,
            22
        )

    local minLevel =
        tonumber(filter.MinLevel)
        or 1

    local maxLevel =
        tonumber(filter.MaxLevel)
        or 100

    local minWeight =
        tonumber(filter.MinWeight)
        or 0

    local maxWeight =
        tonumber(filter.MaxWeight)
        or 0

    local price =
        tonumber(filter.Price)
        or 0

    return string.format(
        "%02d %s | L%s-%s | BW %s-%s | %s",
        tonumber(index) or 0,
        nameText,
        FormatShortNumber(minLevel),
        FormatShortNumber(maxLevel),
        FormatShortNumber(minWeight),
        FormatShortNumber(maxWeight),
        FormatCompactTokens(price)
    )
end

function ListingPetMatchesFilter(pet, filter)

    if type(pet) ~= "table"
    or type(filter) ~= "table" then
        return false
    end

    if filter.Enabled == false then
        return false
    end

    --==================================================
    -- PET IDENTITY
    -- Source of truth is pet.PetName, which comes from
    -- the tool attribute "f" / resolved true pet identity.
    --
    -- IMPORTANT:
    -- Never use visible-name suffix matching here.
    --
    -- Safe examples:
    -- Tiny Peryton -> PetName = Peryton
    -- Everchanted Gilded Choc Peryton -> PetName = Gilded Choc Peryton
    -- Rainbow Rainbow Dilophosaurus -> PetName = Rainbow Dilophosaurus
    -- Rainbow Dilophosaurus mutation on normal Dilophosaurus -> PetName = Dilophosaurus
    --==================================================

    local petName =
        tostring(pet.PetName or "")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    local wantedPet =
        tostring(filter.Pet or "")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    local petMutation =
        NormalizeListingPetMutationValue(
            pet.Mutation
        )

    if petName == ""
    or wantedPet == "" then
        return false
    end

    if string.lower(petName) ~= string.lower(wantedPet) then
        return false
    end

    --==================================================
    -- MUTATION
    -- "---" / "All" means any mutation.
    -- "All Except" means any mutation except selected blocked ones.
    --==================================================

    local wantedMutation =
        NormalizeListingFilterMutation(
            filter.Mutation
        )

    if wantedMutation == "All Except" then

        local excluded =
            filter.ExcludedMutations

        if type(excluded) == "table"
        and excluded[petMutation] == true then
            return false
        end

    elseif wantedMutation ~= "---"
    and petMutation ~= wantedMutation then

        return false
    end

    --==================================================
    -- LEVEL / AGE
    -- Fully controlled by filter.
    -- No hidden age cap.
    --==================================================

    local petLevel =
        tonumber(pet.Age)
        or tonumber(pet.Level)

    local minLevel =
        tonumber(filter.MinLevel)
        or 1

    local maxLevel =
        tonumber(filter.MaxLevel)
        or 100

    if not petLevel then

        warn(
            "[LISTINGS] SKIP | level missing:",
            tostring(pet.ToolName),
            "| BaseWeight:",
            tostring(pet.BaseWeight),
            "| DisplayKG:",
            tostring(pet.Weight),
            "| UUID:",
            tostring(pet.UUID)
        )

        return false
    end

    if petLevel < minLevel
    or petLevel > maxLevel then
        return false
    end

    --==================================================
    -- BASEWEIGHT
    -- Fully controlled by filter.
    -- No hidden BaseWeight cap.
    --==================================================

    local baseWeight =
        tonumber(pet.BaseWeight)

    local minWeight =
        tonumber(filter.MinWeight)

    local maxWeight =
        tonumber(filter.MaxWeight)

    if not baseWeight
    or not minWeight
    or not maxWeight then

        warn(
            "[LISTINGS] SKIP | baseweight invalid:",
            tostring(pet.ToolName),
            "| Level:",
            tostring(petLevel),
            "| BaseWeight:",
            tostring(baseWeight),
            "| Filter BW:",
            tostring(minWeight),
            "-",
            tostring(maxWeight),
            "| DisplayKG:",
            tostring(pet.Weight),
            "| UUID:",
            tostring(pet.UUID)
        )

        return false
    end

    if maxWeight < minWeight then
        return false
    end

    if baseWeight < minWeight
    or baseWeight > maxWeight then
        return false
    end

    return true
end
function ResolveListingFilterForPet(pet)

    local filters =
        EnsureListingFilters()

    if #filters > 0 then

        for _, filter in ipairs(filters) do

            if ListingPetMatchesFilter(pet, filter) then
                return filter
            end
        end

        return nil
    end

    -- Legacy fallback:
    -- If no multi-filters exist, use the current single setup values.
    local legacyFilter =
        BuildCurrentListingFilter()

    local allowed =
        IsListingFilterAllowed(legacyFilter)

    if allowed
    and ListingPetMatchesFilter(pet, legacyFilter) then
        return legacyFilter
    end

    return nil
end

function PetMatchesListingFilter(pet)

    local filter =
        ResolveListingFilterForPet(pet)

    if not filter then
        return false
    end

    return true, filter
end

function RefreshListingInventorySnapshot()

    if game.PlaceId == TRADING_WORLD_PLACE_ID then
        RefreshOwnListedUUIDs(true)
    else
        RefreshOwnListedUUIDs(false)
    end

    ListingsState.InventorySnapshot =
        GetListingInventoryPetSnapshot()

    return ListingsState.InventorySnapshot
end

function BuildListingPreview()

    ListingsState.ListedUUIDs =
        ListingsState.ListedUUIDs
        or {}

    ListingsState.OwnListedUUIDs =
        ListingsState.OwnListedUUIDs
        or {}

    ListingsState.OwnListedMetadata =
        ListingsState.OwnListedMetadata
        or {}

    ListingsState.FailedUUIDs =
        ListingsState.FailedUUIDs
        or {}

    ListingsState.QueuedUUIDs =
        ListingsState.QueuedUUIDs
        or {}

    local pets =
        RefreshListingInventorySnapshot()

    local preview = {
        Matching = 0,
        AlreadyListed = 0,
        Ready = 0,
        Failed = 0,
        RuntimeListed = 0,
        Queued = 0,
    }

    for _, pet in ipairs(pets) do

        if PetMatchesListingFilter(pet) then

            preview.Matching += 1

            if ListingsState.OwnListedUUIDs[pet.UUID] then
                preview.AlreadyListed += 1

            elseif IsListingUUIDPending(pet.UUID) then
    preview.Failed += 1

elseif ListingsState.FailedUUIDs[pet.UUID] then
    preview.Failed += 1

elseif ListingsState.QueuedUUIDs[pet.UUID] then
    preview.Queued += 1

else
    preview.Ready += 1
end
        end
    end

    ListingsState.Preview =
        preview

    return preview
end

function PrintListingPreview()

    local preview =
        BuildListingPreview()

    print("==================================================")
    print("[LISTINGS PREVIEW]")
    print("SelectedPet:", tostring(ListingsState.SelectedPet))
    print("SelectedMutation:", tostring(ListingsState.SelectedMutation))
    print("MinWeight:", tostring(ListingsState.MinWeight))
    print("MaxWeight:", tostring(ListingsState.MaxWeight))
    print("Price:", tostring(ListingsState.Price or "required"))
    print("Matching:", tostring(preview.Matching))
    print("Already listed:", tostring(preview.AlreadyListed))
    print("Runtime listed:", tostring(preview.RuntimeListed))
    print("Queued:", tostring(preview.Queued))
    print("Failed:", tostring(preview.Failed))
    print("Ready to list:", tostring(preview.Ready))
    print("==================================================")
end


function PrintDetailedListingPreview()

    local pets =
        RefreshListingInventorySnapshot()

    print("==================================================")
    print("[LISTINGS DETAILED PREVIEW]")

    local total =
        0

    local matched =
        0

    local ready =
        0

    for _, pet in ipairs(pets) do

        total += 1

        local matches, filter =
            PetMatchesListingFilter(pet)

        if matches then

            matched += 1

            local reason =
                "READY"

            if ListingsState.OwnListedUUIDs[pet.UUID] then
                reason =
                    "SKIP | already listed in booth"

            elseif ListingsState.ListedUUIDs[pet.UUID] then
                reason =
                    "SKIP | runtime listed"

            elseif IsListingUUIDPending(pet.UUID) then
                reason =
                    "SKIP | pending sale cooldown"

            elseif ListingsState.FailedUUIDs[pet.UUID] then
                reason =
                    "SKIP | failed UUID"

            elseif ListingsState.QueuedUUIDs[pet.UUID] then
                reason =
                    "SKIP | already queued"

            else
                ready += 1
            end

            print(
                "[LISTING MATCH]",
                tostring(reason),
                "| Pet:",
                tostring(pet.ToolName or pet.PetName),
                "| UUID:",
                tostring(pet.UUID),
                "| PetName:",
                tostring(pet.PetName),
                "| Mutation:",
                tostring(pet.Mutation),
                "| Age:",
                tostring(pet.Age or pet.Level),
                "| BW:",
                tostring(pet.BaseWeight),
                "| Price:",
                tostring(filter and filter.Price)
            )
        end
    end

    print(
        "[LISTINGS DETAILED PREVIEW] Total:",
        tostring(total),
        "| Matched:",
        tostring(matched),
        "| Ready:",
        tostring(ready)
    )

    print("==================================================")
end
--==================================================
-- LISTINGS: UNFAVORITE
--==================================================

function TryUnfavoriteListingPet(pet)

    if ListingsState.AutoUnfavorite ~= true then
        return true
    end

    if not pet
    or not pet.Tool then
        return false
    end

    if pet.Tool:GetAttribute("d") ~= true then
        return true
    end

    local remote =
        GetFavoriteRemote()

    if not remote then
        warn("[LISTINGS] Favorite_Item remote missing")
        return false
    end

    print(
        "[LISTINGS] Unfavoriting:",
        tostring(pet.ToolName)
    )

    pcall(function()
        remote:FireServer(pet.Tool)
    end)

    local timeout =
        os.clock() + 3

    while os.clock() < timeout do

        local favoriteState =
            pet.Tool:GetAttribute("d")

        if favoriteState == false then

            print(
                "[LISTINGS] Unfavorite confirmed:",
                tostring(pet.ToolName)
            )

            return true
        end

        task.wait(0.1)
    end

    warn(
        "[LISTINGS] Unfavorite timeout:",
        tostring(pet.ToolName)
    )

    return false
end

--==================================================
-- LISTINGS: CREATE LISTING
--==================================================

function CreatePetListing(pet, price)

    if not pet
    or not pet.UUID then
        return false
    end

    local uuid =
        tostring(pet.UUID)

    if IsListingUUIDPending(uuid) then
        return "PENDING_UUID"
    end

    price =
        tonumber(
            price
            or pet.ListingPrice
            or ListingsState.Price
        )

    local priceAllowed, priceReason =
        IsListingPriceAllowedValue(price)

    if not priceAllowed then

        ListingsState.Status =
            priceReason

        warn(
            "[LISTINGS] Blocked:",
            tostring(priceReason)
        )

        return "CONFIG_BLOCKED"
    end

    local now =
        os.clock()

    local createElapsed =
        now - SafeNumber(
            ListingsState.LastCreateAttempt,
            0
        )

    local requiredCooldown =
    ResolveListingCreateCooldown()

if createElapsed < requiredCooldown then

    ListingsState.Status =
        "Waiting create cooldown"

    return "COOLDOWN"
end

    local remote =
        GetCreateListingRemote()

    if not remote then
        warn("[LISTINGS] CreateListing remote missing")
        return false
    end

    local unfavorited =
        TryUnfavoriteListingPet(pet)

    if not unfavorited then

        ListingsState.Status =
            "Failed unfavorite"

        return "FAVORITE"
    end

    task.wait(0.2)

    print(
        string.format(
            "[LISTINGS] Creating: %s | UUID %s | %s tokens",
            tostring(pet.ToolName),
            tostring(uuid),
            tostring(price)
        )
    )

    StoreOwnListedPetMetadata(pet)

    ListingsState.LastCreateAttempt =
        os.clock()

    ListingsState.ActiveCreateUUID =
        uuid

    ListingsState.ActiveCreateStartedAt =
        os.clock()

    local ok, result =
        pcall(function()

            return remote:InvokeServer(
                "Pet",
                uuid,
                price
            )
        end)

    local activeUUID =
        ListingsState.ActiveCreateUUID

    ListingsState.ActiveCreateUUID =
        nil

    ListingsState.ActiveCreateStartedAt =
        0

    print(
        "[LISTINGS] Listing create:",
        tostring(pet.ToolName),
        "| result:",
        tostring(result)
    )

    if not ok then

        warn(
            "[LISTINGS] Invoke failed:",
            tostring(result)
        )

        return false
    end

    if IsListingUUIDPending(uuid) then
        return "PENDING_UUID"
    end

    if result == false then

    -- Give Notification.OnClientEvent a tiny window to report
    -- whether this was global CreateListing cooldown.
    task.wait(0.15)

    local sawCreateWait =
        ListingsState.LastCreateWaitSignal
        and (
            os.clock()
            - SafeNumber(
                ListingsState.LastCreateWaitSignal,
                0
            )
        ) < 1.5

    if sawCreateWait then

        AdaptiveListingRegisterCreateWait(
            "CreateListing returned false"
        )

        ListingsState.LastCreateAttempt =
            os.clock()

        return "CREATE_WAIT"
    end

    -- If it was not the global create cooldown, treat it as
    -- a pet-specific pending lock.
    MarkListingUUIDPending(
        uuid,
        ListingsState.PendingCooldown
    )

    return "PENDING_UUID"
end

AdaptiveListingRegisterCreateSuccess()

return true
end

--==================================================
-- LISTINGS: QUEUE WORKER
--==================================================

function QueueListingPet(pet, filter)

    if not pet
    or not pet.UUID then
        return false
    end

    local uuid =
        tostring(pet.UUID)

    if IsListingUUIDPending(uuid) then
        return false
    end

    if ListingsState.QueuedUUIDs[uuid] then
        return false
    end

    if ListingsState.OwnListedUUIDs[uuid] then
        return false
    end

    if ListingsState.ListedUUIDs[uuid] then
        return false
    end

    if ListingsState.FailedUUIDs[uuid] then
        return false
    end

    filter =
        filter
        or ResolveListingFilterForPet(pet)

    if not filter then
        return false
    end

    local filterAllowed, filterReason =
        IsListingFilterAllowed(filter)

    if not filterAllowed then

        ListingsState.Status =
            filterReason

        return false
    end

    pet.ListingFilter =
        filter

    pet.ListingPrice =
        tonumber(filter.Price)

    ListingsState.QueuedUUIDs[uuid] =
        true

    table.insert(
        ListingsState.ListingQueue,
        pet
    )

    print(
        string.format(
            "[LISTINGS QUEUE] Added → %s | %s tokens | Queue: %s",
            tostring(pet.ToolName),
            tostring(pet.ListingPrice),
            tostring(#ListingsState.ListingQueue)
        )
    )

    return true
end

function StartListingWorker()

    if ListingsState.WorkerRunning then
        return
    end

    ListingsState.WorkerRunning =
        true

    task.spawn(function()

        while IsCurrentRun() do

            task.wait(0.1)

            if ScriptState.ForceStopped then
                continue
            end

            if not ListingsState.Enabled then
                continue
            end

            if ListingsState.Busy then
                continue
            end

            local pet =
                table.remove(
                    ListingsState.ListingQueue,
                    1
                )

            if not pet then
                continue
            end

            ListingsState.QueuedUUIDs[pet.UUID] =
                nil

            ListingsState.Busy =
                true

            ListingsState.Status =
                "Listing queued pet"

            local ok, result =
                pcall(function()

                    return CreatePetListing(
                        pet,
                        pet.ListingPrice
                            or (
                                pet.ListingFilter
                                and pet.ListingFilter.Price
                            )
                            or ListingsState.Price
                    )
                end)

            if not ok then

                result =
                    false

                warn(
                    "[LISTINGS WORKER] Error:",
                    tostring(result)
                )
            end

            if result == true then

    ListingsState.ListedUUIDs[pet.UUID] =
        os.clock()

    ListingsState.OwnListedUUIDs[pet.UUID] =
        true

    ListingsState.ListedThisSession += 1

    ListingsState.LastListed =
        pet.ToolName

    ListingsState.Status =
        "Listed 1 pet"

    print(
        "[LISTINGS] Listed:",
        tostring(pet.ToolName),
        "| UUID:",
        tostring(pet.UUID)
    )

    --==================================================
    -- REFRESH OWN BOOTH DASHBOARD AFTER SUCCESS
    -- The server accepted the listing, so force-refresh
    -- the booth snapshot instead of waiting for the
    -- 3-second throttled UI refresh.
    --==================================================

    if type(BuildOwnBoothListingSnapshot) == "function" then

        pcall(function()
            BuildOwnBoothListingSnapshot(true)
        end)
    end

    if type(ListingsStatusRefresh) == "function" then

        pcall(ListingsStatusRefresh)
    end

            elseif result == "COOLDOWN"
or result == "CREATE_WAIT" then

    ListingsState.Status =
        "Waiting create cooldown"

    local retryDelay =
        ResolveListingCreateCooldown()

    task.delay(retryDelay, function()

        if ListingsState.Enabled then
            QueueListingPet(pet)
        end
    end)

            elseif result == "PENDING"
or result == "PENDING_UUID" then

    MarkListingUUIDPending(
        pet.UUID,
        ListingsState.PendingCooldown
    )

    ListingsState.Status =
        "Pet pending, trying next"

    print(
        "[LISTINGS] Pending UUID skipped:",
        tostring(pet.ToolName),
        "| UUID:",
        tostring(pet.UUID)
    )

            elseif result == "FAVORITE" then

                ListingsState.Status =
                    "Waiting unfavorite"

                task.delay(1, function()

                    if ListingsState.Enabled then
                        QueueListingPet(pet)
                    end
                end)

            elseif result == "CONFIG_BLOCKED" then

    ListingsState.Status =
        "Config blocked"

    ListingsState.FailedUUIDs[pet.UUID] =
        os.clock()

            else

                ListingsState.Status =
                    "Hard failure"

                ListingsState.FailedUUIDs[pet.UUID] =
                    os.clock()

                warn(
                    "[LISTINGS] Hard failure:",
                    tostring(pet.ToolName),
                    "| UUID:",
                    tostring(pet.UUID)
                )
            end

            if type(ListingsStatusRefresh) == "function" then
                pcall(ListingsStatusRefresh)
            end

            task.wait(
    ResolveListingCreateCooldown()
)

            ListingsState.Busy =
                false
        end
    end)
end

--==================================================
-- LISTINGS: POST-CONFIG RESTORE
-- Saved listing filters should restore only.
-- They must never start AutoList by themselves.
-- Start AutoList toggle is the only authority.
--==================================================

function ArmListingsAutostartFromSavedToggle()

    if type(ListingsState) ~= "table" then
        return false
    end

    if ScriptState
    and ScriptState.ForceStopped then
        return false
    end

    --==================================================
    -- SOURCE OF TRUTH:
    -- Prefer the independent intent file.
    -- Fall back to Obsidian option only if the file does not exist yet.
    --==================================================

    local savedIntent =
        LoadListingAutoListIntent()

    local option =
        Library
        and Library.Options
        and Library.Options.EnableAutoList

    local optionEnabled =
        false

    if option then

        optionEnabled =
            option.Value == true
            or option.CurrentValue == true
            or option.State == true
    end

    local shouldRestore =
        false

    if savedIntent ~= nil then
        shouldRestore =
            savedIntent == true
    else
        shouldRestore =
            optionEnabled == true
    end

    print(
        "[LISTINGS RESTORE] AutoList intent:",
        tostring(shouldRestore),
        "| intent file:",
        tostring(savedIntent),
        "| option exists:",
        tostring(option ~= nil),
        "| option:",
        tostring(optionEnabled)
    )

    --==================================================
    -- Reset unsafe runtime state.
    -- Do NOT clear OwnListedUUIDs here; booth sync owns it.
    --==================================================

    ListingsState.Busy =
        false

    ListingsState.LastScan =
        0

    ListingsState.NoWorkSleepUntil =
        0

    ListingsState.ActiveCreateUUID =
        nil

    ListingsState.ActiveCreateStartedAt =
        0

    ListingsState.AutoDisableWhenDone =
        false

    ListingsState.ListingQueue =
        ListingsState.ListingQueue
        or {}

    ListingsState.QueuedUUIDs =
        ListingsState.QueuedUUIDs
        or {}

    ListingsState.PendingUUIDs =
        ListingsState.PendingUUIDs
        or {}

    table.clear(ListingsState.ListingQueue)
    table.clear(ListingsState.QueuedUUIDs)
    table.clear(ListingsState.PendingUUIDs)

    --==================================================
    -- Saved OFF = stay off.
    --==================================================

    if shouldRestore ~= true then

        ListingsState.Enabled =
            false

        ListingsState.VisualTagsEnabled =
            false

        ListingsState.Status =
            "Disabled"

        if type(BuildListingPreview) == "function" then
            pcall(BuildListingPreview)
        end

        if type(RefreshListingFilterUI) == "function" then
            pcall(RefreshListingFilterUI)
        end

        if type(ListingsStatusRefresh) == "function" then
            pcall(ListingsStatusRefresh)
        end

        print(
            "[LISTINGS RESTORE] Start AutoList saved OFF; runtime disabled"
        )

        return false
    end

    --==================================================
    -- Saved ON = enable persistent AutoList.
    --==================================================

    if game.PlaceId ~= TRADING_WORLD_PLACE_ID then

        ListingsState.Enabled =
            false

        ListingsState.VisualTagsEnabled =
            false

        ListingsState.Status =
            "Not in Trade World"

        if type(ListingsStatusRefresh) == "function" then
            pcall(ListingsStatusRefresh)
        end

        return false
    end

    if type(EnsureListingFilters) == "function" then
        pcall(EnsureListingFilters)
    end

    if type(SyncListingRequiredFlagsFromValues) == "function" then
        pcall(SyncListingRequiredFlagsFromValues)
    end

    ListingsState.Enabled =
        true

    ListingsState.VisualTagsEnabled =
        true

    ListingsState.Status =
        "AutoList restored | watching"

    ListingsState.LastScan =
        0

    ListingsState.NoWorkSleepUntil =
        0

    ListingsState.ListedThisSession =
        0

    SaveListingAutoListIntent(true)

    -- Sync the UI toggle visually if it exists.
    task.defer(function()

        pcall(function()

            if Library
            and Library.Options
            and Library.Options.EnableAutoList
            and Library.Options.EnableAutoList.Value ~= true then

                Library.Options.EnableAutoList:SetValue(true)
            end
        end)
    end)

    if type(RefreshListingInventorySnapshot) == "function" then
        pcall(RefreshListingInventorySnapshot)
    end

    if type(BuildOwnBoothListingSnapshot) == "function" then
        pcall(function()
            BuildOwnBoothListingSnapshot(true)
        end)
    end

    if type(BuildListingPreview) == "function" then
        pcall(BuildListingPreview)
    end

    if type(RefreshListingFilterUI) == "function" then
        pcall(RefreshListingFilterUI)
    end

    if type(ListingsStatusRefresh) == "function" then
        pcall(ListingsStatusRefresh)
    end

    print(
        "[LISTINGS RESTORE] Start AutoList restored ON; runtime enabled"
    )

    -- Immediate first pass.
    task.spawn(function()

        task.wait(0.75)

        if ListingsState.Enabled ~= true then
            return
        end

        if ScriptState
        and ScriptState.ForceStopped then
            return
        end

        if type(WaitForOwnListedUUIDSync) == "function" then
            pcall(function()
                WaitForOwnListedUUIDSync(4)
            end)
        end

        if type(RefreshListingInventorySnapshot) == "function" then
            pcall(RefreshListingInventorySnapshot)
        end

        if type(BuildOwnBoothListingSnapshot) == "function" then
            pcall(function()
                BuildOwnBoothListingSnapshot(true)
            end)
        end

        if type(BuildListingPreview) == "function" then
            pcall(BuildListingPreview)
        end

        if type(RunAutoListingPass) == "function" then

            ListingsState.LastScan =
                0

            ListingsState.NoWorkSleepUntil =
                0

            ListingsState.Status =
                "AutoList running"

            pcall(RunAutoListingPass)
        end

        if type(ListingsStatusRefresh) == "function" then
            pcall(ListingsStatusRefresh)
        end
    end)

    return true
end
--==================================================
-- LISTINGS: SCANNER
--==================================================

function PrintListingSummaryOnce(summary)

    summary =
        tostring(summary or "")

    local now =
        os.clock()

    if summary == ListingsState.LastSummaryPrint
    and now - ListingsState.LastSummaryPrintAt < 15 then
        return
    end

    ListingsState.LastSummaryPrint =
        summary

    ListingsState.LastSummaryPrintAt =
        now

    print(summary)
end

function RunAutoListingPass()

    if ListingsState.Busy then
        return
    end

    ListingsState.Status =
        "Scanning"

    local ok, err =
        pcall(function()

            local configAllowed, configReason =
                IsListingConfigurationAllowed()

            if not configAllowed then

                ListingsState.Status =
                    configReason

                warn(
                    "[LISTINGS] Scan blocked:",
                    tostring(configReason)
                )

                return
            end

            local syncReady, syncReason =
                true,
                "Sync unavailable"

            if type(WaitForOwnListedUUIDSync) == "function" then

                syncReady, syncReason =
                    WaitForOwnListedUUIDSync(8)
            end

            if not syncReady then

                ListingsState.Status =
                    tostring(syncReason or "Waiting for own booth sync")

                warn(
                    "[LISTINGS] Scan delayed:",
                    tostring(syncReason)
                )

                if type(ListingsStatusRefresh) == "function" then
                    pcall(ListingsStatusRefresh)
                end

                return
            end

            local pets =
                RefreshListingInventorySnapshot()

            local filters =
                EnsureListingFilters()

            local activeFilters = {}

            if #filters > 0 then

                for _, filter in ipairs(filters) do

                    local allowed =
                        IsListingFilterAllowed(filter)

                    if allowed then
                        table.insert(
                            activeFilters,
                            filter
                        )
                    end
                end

            else

                local legacyFilter =
                    BuildCurrentListingFilter()

                local allowed =
                    IsListingFilterAllowed(legacyFilter)

                if allowed then
                    table.insert(
                        activeFilters,
                        legacyFilter
                    )
                end
            end

            local matched = 0
            local queued = 0
            local skippedBoothListed = 0
            local skippedRuntimeListed = 0
            local skippedFailed = 0
            local skippedQueued = 0
            local skippedPending = 0

            local countedMatchedUUIDs = {}

            local maxQueuePerPass =
                math.clamp(
                    math.floor(
                        SafeNumber(
                            ListingsState.MaxQueuePerPass,
                            2
                        )
                    ),
                    1,
                    10
                )

            --==================================================
            -- FILTER-FIRST QUEUE ORDER
            -- Example:
            -- Filter 1 Mimic runs through all matching Mimics first.
            -- Filter 2 Kitsune only starts after earlier filters have
            -- no queueable pets left, or after MaxQueuePerPass allows it.
            --==================================================

            for _, filter in ipairs(activeFilters) do

                if ScriptState.ForceStopped then
                    break
                end

                if not ListingsState.Enabled then
                    break
                end

                for _, pet in ipairs(pets) do

                    if ScriptState.ForceStopped then
                        break
                    end

                    if not ListingsState.Enabled then
                        break
                    end

                    if not ListingPetMatchesFilter(
                        pet,
                        filter
                    ) then
                        continue
                    end

                    local uuid =
                        tostring(pet.UUID or "")

                    if uuid ~= ""
                    and not countedMatchedUUIDs[uuid] then

                        countedMatchedUUIDs[uuid] =
                            true

                        matched += 1
                    end

                    if ListingsState.OwnListedUUIDs[pet.UUID] then

                        skippedBoothListed += 1

                        ListingsState.ListedUUIDs[pet.UUID] =
                            ListingsState.ListedUUIDs[pet.UUID]
                            or os.clock()

                        continue
                    end

                    if ListingsState.ListedUUIDs[pet.UUID] then
                        skippedRuntimeListed += 1
                        continue
                    end

                    if IsListingUUIDPending(pet.UUID) then
                        skippedPending += 1
                        continue
                    end

                    if ListingsState.FailedUUIDs[pet.UUID] then
                        skippedFailed += 1
                        continue
                    end

                    if ListingsState.QueuedUUIDs[pet.UUID] then
                        skippedQueued += 1
                        continue
                    end

                    print(
                        "[LISTINGS] Queue match:",
                        tostring(pet.ToolName),
                        "| Age:",
                        tostring(pet.Age or "Unknown"),
                        "| DisplayKG:",
                        tostring(pet.Weight or "Unknown"),
                        "| Mutation:",
                        tostring(pet.Mutation),
                        "| TRUE BaseWeight:",
                        string.format("%.2f", tonumber(pet.BaseWeight) or 0),
                        "| Filter:",
                        tostring(filter and filter.MinWeight or "?"),
                        "-",
                        tostring(filter and filter.MaxWeight or "?"),
                        "| Price:",
                        tostring(filter and filter.Price or ListingsState.Price),
                        "| UUID:",
                        tostring(pet.UUID)
                    )

                    local rawBaseWeight =
                        tonumber(pet.BaseWeight)

                    local minWeight =
                        tonumber(filter and filter.MinWeight)

                    local maxWeight =
                        tonumber(filter and filter.MaxWeight)

                    if not rawBaseWeight
                    or not minWeight
                    or not maxWeight then

                        warn(
                            "[LISTINGS] SKIP | invalid raw BaseWeight/filter:",
                            tostring(pet.ToolName),
                            "| RawBaseWeight:",
                            tostring(rawBaseWeight),
                            "| Filter:",
                            tostring(minWeight),
                            "-",
                            tostring(maxWeight)
                        )

                        continue
                    end

                    if rawBaseWeight < minWeight
                    or rawBaseWeight > maxWeight then

                        warn(
                            "[LISTINGS] SKIP | raw BaseWeight outside filter:",
                            tostring(pet.ToolName),
                            "| RawBaseWeight:",
                            string.format("%.2f", rawBaseWeight),
                            "| Filter:",
                            tostring(minWeight),
                            "-",
                            tostring(maxWeight),
                            "| DisplayKG:",
                            tostring(pet.Weight),
                            "| Age:",
                            tostring(pet.Age or "Unknown")
                        )

                        continue
                    end

                    if QueueListingPet(
                        pet,
                        filter
                    ) then
                        queued += 1
                    end

                    if queued >= maxQueuePerPass then
                        break
                    end
                end

                if queued >= maxQueuePerPass then
                    break
                end
            end

            if queued <= 0 then

                ListingsState.Status =
                    string.format(
                        "Matched %s | Queued 0",
                        tostring(matched)
                    )

                if matched > 0
                and matched == (
                    skippedBoothListed
                    + skippedRuntimeListed
                    + skippedFailed
                    + skippedQueued
                    + skippedPending
                ) then

                    ListingsState.NoWorkSleepUntil =
                        os.clock() + ListingsState.NoWorkBackoff

                    ListingsState.Status =
                        "Done | all filters listed or skipped"

                    -- Option A:
-- Do not turn AutoList off when current matching pets are handled.
-- Keep watching until the user manually turns Start AutoList OFF.
ListingsState.AutoDisableWhenDone =
    false

ListingsState.PreserveVisualTagsOnNextDisable =
    false
                end

            else

                ListingsState.Status =
                    "Queued "
                    .. tostring(queued)
                    .. " pet"
                    .. (
                        queued == 1
                        and ""
                        or "s"
                    )
            end

            BuildListingPreview()

            local summary =
                string.format(
                    "[LISTINGS] Pass complete | mode: filter-first | matched: %s | queued: %s | booth-skip: %s | runtime-skip: %s | failed-skip: %s | pending-skip: %s | queued-skip: %s | queue: %s",
                    tostring(matched),
                    tostring(queued),
                    tostring(skippedBoothListed),
                    tostring(skippedRuntimeListed),
                    tostring(skippedFailed),
                    tostring(skippedPending),
                    tostring(skippedQueued),
                    tostring(#ListingsState.ListingQueue)
                )

            if queued > 0
            or not ListingsState.QuietWhenComplete then

                PrintListingSummaryOnce(summary)

            else

                PrintListingSummaryOnce(
                    string.format(
                        "[LISTINGS] Idle | mode: filter-first | matched: %s | already listed: %s | runtime listed: %s | failed: %s | pending: %s | queue: %s",
                        tostring(matched),
                        tostring(skippedBoothListed),
                        tostring(skippedRuntimeListed),
                        tostring(skippedFailed),
                        tostring(skippedPending),
                        tostring(#ListingsState.ListingQueue)
                    )
                )
            end
        end)

    if not ok then

        ListingsState.Status =
            "Error"

        warn(
            "[LISTINGS] Pass failed:",
            tostring(err)
        )
    end
end
--==================================================
-- BOOTH TAB → AUTOMATION (UI ONLY)
--==================================================
function BuildBoothTab()

if type(Tabs.Booth.AddLeftCollapsibleGroupbox) == "function" then

    BoothBox =
        Tabs.Booth:AddLeftCollapsibleGroupbox(
            "Booth Automation",
            "zap",
            true
        )

else

    warn("[LIB TEST] Collapsible Booth Automation unavailable, using normal groupbox")

    BoothBox =
        Tabs.Booth:AddLeftGroupbox(
            "Booth Automation",
            "zap"
        )
end
BoothCustomizationBox = Tabs.Booth:AddRightGroupbox("Booth Customization", "wand")

local AutoClaimToggle = BoothBox:AddToggle("AutoClaimBooth", {
    Text = "🎪 Auto Claim Booth",
    Default = false,
})

AutoClaimToggle:OnChanged(function(enabled)
    BoothAuto.Enabled = enabled

    MarkConfigDirty()

if enabled then
    print("[Booth] Auto claim triggered")

    HolyNotify(
        "Booth Claim Started",
        "HOLY is searching for a free booth.",
        "store",
        4
    )

    task.spawn(function()
        task.wait(0.25) -- small replication buffer
        ExecuteBoothClaim()
    end)
end
end)

local EquipPetToggle = BoothBox:AddToggle("EquipPet", {
    Text = "🐶 Equip Pet",
    Tooltip = "Equips a pet from your inventory",
    Default = false,
})

EquipPetToggle:OnChanged(function(enabled)

    BoothPetState.Enabled =
        enabled == true

    -- Reset equip lifecycle whenever the user toggles this.
    -- This prevents stale UID locks from blocking re-enable.
    BoothPetState.LastEquippedUID =
        nil

    BoothPetState.LockedShowcaseUID =
        nil

    BoothPetState.LastMissingPet =
        nil

    BoothPetState.LastMissingWarnAt =
        0

    BoothPetState.LastEquipAttemptAt =
        0

    ShowcaseEquipState.ReequipPending =
        false

    MarkConfigDirty()

    if enabled == true then

        task.spawn(function()

            task.wait(0.15)

            if BoothPetState.Enabled ~= true then
                return
            end

            if type(EquipShowcasePet) == "function" then
                EquipShowcasePet(true)
            end
        end)
    end
end)

RefreshDynamicPetList()

local ShowcaseDropdown =
    BoothCustomizationBox:AddDropdown(
        "ShowcasePetSelect",
        {
            Text = "Showcase Pets",
            Values = PetList,
            Default = "",
            Searchable = true,
        }
    )

ShowcaseDropdown:OnChanged(function(value)

    BoothPetState.SelectedPetType = value

    BoothPetState.LastEquippedUID =
    nil

BoothPetState.LockedShowcaseUID =
    nil

BoothPetState.LastMissingPet =
    nil

BoothPetState.LastMissingWarnAt =
    0

    MarkConfigDirty()
end)

RefreshBoothSkinList()

local BoothSkinDropdown =
    BoothCustomizationBox:AddDropdown(
        "BoothSkinSelect",
        {
            Text = "Booth Skin",
            Values = BoothSkinList,
            Default = ResolveSelectedBoothSkin(),
            Searchable = true,
        }
    )

BoothSkinDropdown:OnChanged(function(value)

    local selected =
        tostring(value or "Default")

    if not IsOwnedBoothSkin(selected) then

        selected =
            "Default"

        HolyNotify(
            "Booth Skin Reset",
            "Selected skin is not owned. Using Default.",
            "shield-alert",
            3
        )
    end

    BoothCustomization.SelectedSkin =
        selected

    MarkConfigDirty()

    print(
        "[BOOTH SKIN] Selected:",
        BoothCustomization.SelectedSkin
    )
end)

local AutoTpToggle = BoothBox:AddToggle("AutoTpBooth", {
    Text = "📍 Auto Teleport Booth",
    Tooltip = "Teleports back only after you move too far from your booth.",
    Default = false,
})

AutoTpToggle:OnChanged(function(enabled)

    BoothAuto.AutoTeleport =
        enabled

    if not enabled then
        ClearBoothAnchor()
        RestoreCharacterMovement()
    end

    -- skip restore-time execution
    if ConfigState.IsHydrating then
        return
    end

    if enabled then

        RestoreCharacterMovement()

        task.spawn(function()
            task.wait(0.15)
            PositionBehindOwnedBooth()
        end)

    else

        RestoreCharacterMovement()
    end

    MarkConfigDirty()
end)

local LockBehindBoothToggle = BoothBox:AddToggle("LockBehindBooth", {
    Text = "🔒 Lock Behind Booth",
    Tooltip = "Hard-locks your character behind your booth. Requires Auto Teleport Booth.",
    Default = false,
})

LockBehindBoothToggle:OnChanged(function(enabled)

    BoothAuto.LockBehindBooth =
        enabled

    if not enabled then
        SetBoothHardLockAnchored(false)
        RestoreCharacterMovement()
    end

    if enabled
    and BoothAuto.AutoTeleport
    and not ConfigState.IsHydrating then

        task.spawn(function()
            task.wait(0.10)

            local success =
                PositionBehindOwnedBooth()

            if success then
                task.wait(0.10)
                SetBoothHardLockAnchored(true)
            end
        end)
    end

    MarkConfigDirty()
end)

local BoothDistanceSlider = BoothBox:AddSlider("BoothDistance", {
    Text = "Booth Distance",
    Default = 20,
    Min = 2,
    Max = 30,
    Rounding = 1,
    Compact = false,
})

BoothDistanceSlider:OnChanged(function(value)

    BoothAuto.BoothDistance = value

    MarkConfigDirty()

    -- prevent hydration restore calls
    if ConfigState.IsHydrating then
        return
    end

    if BoothAuto.AutoTeleport then
        task.spawn(function()
            task.wait(0.05)

            local success = PositionBehindOwnedBooth()

            if not success then
                warn("[Booth] Live reposition failed")
            end
        end)
    end
end)

local BoothReturnDistanceSlider = BoothBox:AddSlider("BoothReturnDistance", {
    Text = "Return Distance",
    Default = 8,
    Min = 5,
    Max = 15,
    Rounding = 0,
    Compact = false,
    Tooltip = "How far you can move from your booth before Auto Teleport returns you.",
})

BoothReturnDistanceSlider:OnChanged(function(value)

    BoothAuto.ReturnDistance =
        math.clamp(
            SafeNumber(value, 8),
            5,
            15
        )

    MarkConfigDirty()
end)

local ChatPromoteListings = BoothBox:AddToggle("AutoPromoteListings", {
    Text = "💬 Auto Promote Listings",
    Tooltip = "Sends chat promotion messages for your listings",
    Default = false,
})
ChatPromoteListings:OnChanged(function(enabled)
    BoothAuto.AutoPromote = enabled

    MarkConfigDirty()
end)

do
    RefreshBeeEggList()

    EventsBox:AddDropdown(
        "BeeEggSelect",
        {
            Text = "Bee Eggs",
            Values = BeeEggAuto.EggList,
            Default = BeeEggAuto.SelectedEggs,
            Multi = true,
            Searchable = true,
        }
    ):OnChanged(function(value)

        table.clear(BeeEggAuto.SelectedEggs)

        if type(value) == "table" then

            for eggName, selected in pairs(value) do

                if selected == true then
                    BeeEggAuto.SelectedEggs[
                        tostring(eggName)
                    ] = true
                end
            end

        elseif type(value) == "string"
        and value ~= "" then

            BeeEggAuto.SelectedEggs[
                tostring(value)
            ] = true
        end

        MarkConfigDirty()

        local selectedCount = 0

        for _ in pairs(BeeEggAuto.SelectedEggs) do
            selectedCount = selectedCount + 1
        end

        print(
            "[BEE EGG] Selected count:",
            tostring(selectedCount)
        )
    end)

    
    EventsBox:AddToggle(
        "AutoBuyBeeEgg",
        {
            Text = "🐝 Auto Buy Bee Eggs",
            Tooltip = "Buys selected Bee Eggs from Trade World",
            Default = false,
        }
    ):OnChanged(function(enabled)

        BeeEggAuto.Enabled = enabled

        MarkConfigDirty()

        if enabled then
            print("[BEE EGG] Auto buy enabled")
        else
            print("[BEE EGG] Auto buy disabled")
        end
    end)
end

--==================================================
-- AUTO PROMOTE CHAT SYSTEM
--==================================================

local ChatPromoteSessionId =
    HttpService:GenerateGUID(false)

_G.HolyPromoteSessionId =
    ChatPromoteSessionId

local ChatPromoteState = {
    LastMessage = "",
    LastSent = 0,
    NextAllowedAt = 0,

    -- Randomized spacing looks less bot-like and avoids chat filter pressure.
    MinInterval = 75,
    MaxInterval = 120,

    -- prevents console spam when Roblox chat / HTTP fails
    FailUntil = 0,
}

local PromoteMessages = {

    "%s at my booth",
    "%s listed at my booth",
    "%s in my booth",
    "%s available at my booth",
    "my booth has %s",
    "come check %s at my booth",
    "check my booth for %s",
    "booth has %s right now",
    "%s is up at my booth",
    "%s in booth right now",

    "new %s listing at my booth",
    "fresh %s listing at my booth",
    "got %s in my booth",
    "booth open with %s",
    "%s ready in booth",
    "%s waiting at my booth",
    "come see %s at my booth",
    "my booth got %s",
    "%s is listed now",
    "check booth if you want %s",

    "✨ %s at my booth",
    "👀 %s in my booth",
    "🌱 %s listed at my booth",
    "📦 booth has %s",
    "💎 %s up at my booth",
    "🛒 %s in booth now",
    "🔥 %s at booth",
    "⚡ %s listed now",
    "🎯 looking for %s? check booth",
    "🏪 booth has %s",

    "come look at %s",
    "come check out %s",
    "my booth is open with %s",
    "got a cheap %s listed",
    "%s listed if anyone wants it",
    "anyone looking for %s?",
    "anyone need %s?",
    "%s at booth if anyone wants",

    "✨ come see %s",
    "👀 anyone need %s?",
    "📦 got %s listed",
    "💎 %s at my booth now",
    "🔥 %s is up",
    "⚡ %s in booth",
    "🛒 check booth for %s",
    "🎯 %s listed here",
    "🏪 booth open with %s",
    "skibidi %s for sale🔥",
}

function GeneratePromoteMessage()

    local pet =
        BoothPetState.SelectedPetType

    if not pet
    or pet == "" then
        return nil
    end

local template

for i = 1, 10 do

    local candidate =
        PromoteMessages[
            math.random(
                1,
                #PromoteMessages
            )
        ]

    if candidate ~= ChatPromoteState.LastMessage then
        template = candidate
        break
    end
end

template =
    template
    or PromoteMessages[1]

    return string.format(
        template,
        pet
    )
end

local TextChatService =
    game:GetService("TextChatService")

function SendTextChatMessageSafely(message)

    message =
        tostring(message or "")

    if message == "" then
        return false, "empty message"
    end

    local textChannels =
        TextChatService:FindFirstChild("TextChannels")

    if not textChannels then
        return false, "TextChannels missing"
    end

    local targetChannel =
        nil

    local okTarget =
        pcall(function()

            local inputConfig =
                TextChatService.ChatInputBarConfiguration

            if inputConfig
            and inputConfig.TargetTextChannel then
                targetChannel =
                    inputConfig.TargetTextChannel
            end
        end)

    if not okTarget then
        targetChannel =
            nil
    end

    if not targetChannel then

        targetChannel =
            textChannels:FindFirstChild("RBXGeneral")
    end

    if not targetChannel
    or type(targetChannel.SendAsync) ~= "function" then
        return false, "No sendable TextChannel"
    end

    --==================================================
    -- TEMPORARY CHAT MIDDLEWARE BYPASS
    -- The game's ChatMiddleware can fail inside
    -- TextChatService.OnIncomingMessage when Roblox
    -- GetRankInGroup returns HTTP 503.
    --
    -- We disable only for this send attempt, then restore.
    --==================================================

    local hadOldCallback =
        false

    local oldCallback =
        nil

    pcall(function()
        oldCallback =
            TextChatService.OnIncomingMessage

        hadOldCallback =
            true
    end)

    pcall(function()

        TextChatService.OnIncomingMessage =
            function()
                return nil
            end
    end)

    local okSend, err =
        pcall(function()

            targetChannel:SendAsync(
                message
            )
        end)

    task.delay(0.35, function()

        if hadOldCallback then

            pcall(function()
                TextChatService.OnIncomingMessage =
                    oldCallback
            end)
        end
    end)

    if not okSend then
        return false, tostring(err)
    end

    return true, "sent"
end

function SendPromoteMessage()

    if not BoothAuto.AutoPromote then
        return
    end

    if ScriptState
    and ScriptState.ForceStopped then
        return
    end

    local now =
        os.clock()

    ChatPromoteState.LastSent =
        SafeNumber(ChatPromoteState.LastSent, 0)

    ChatPromoteState.Interval =
        SafeNumber(ChatPromoteState.Interval, 35)

    ChatPromoteState.FailUntil =
        SafeNumber(ChatPromoteState.FailUntil, 0)

    if now < ChatPromoteState.FailUntil then
        return
    end

    if now - ChatPromoteState.LastSent
        < ChatPromoteState.Interval
    then
        return
    end

    local message =
        GeneratePromoteMessage()

    if not message then
        warn("[PROMOTE] No message")
        return
    end

    ChatPromoteState.LastMessage =
        message

    print(
        "[PROMOTE] ATTEMPT:",
        message
    )

    local success =
        false

    local failureReason =
        nil

    --==================================================
    -- MODERN CHAT
    -- Uses safe sender because game ChatMiddleware can
    -- crash SendAsync through TextChatService.OnIncomingMessage.
    --==================================================

    local sent, sendReason =
        SendTextChatMessageSafely(
            message
        )

    if sent then

        success =
            true

    else

        failureReason =
            tostring(sendReason)

        warn(
            "[PROMOTE] Safe SendAsync failed:",
            failureReason
        )
    end

    --==================================================
    -- LEGACY FALLBACK — SAFE CHECK ONLY
    -- Prevents nil :WaitForChild crash.
    --==================================================

    if not success then

        local legacyFolder =
            ReplicatedStorage:FindFirstChild(
                "DefaultChatSystemChatEvents"
            )

        local legacyRemote =
            legacyFolder
            and legacyFolder:FindFirstChild(
                "SayMessageRequest"
            )

        if legacyRemote
        and legacyRemote:IsA("RemoteEvent") then

            local ok, err =
                pcall(function()
                    legacyRemote:FireServer(
                        message,
                        "All"
                    )
                end)

            if ok then
                success =
                    true
            else
                failureReason =
                    tostring(err)

                warn(
                    "[PROMOTE] Legacy send failed:",
                    failureReason
                )
            end
        end
    end

    if success then

        ChatPromoteState.LastSent =
            os.clock()

        ChatPromoteState.FailUntil =
            0

        print(
            "[PROMOTE] SENT:",
            message
        )

    else

        -- Roblox chat sometimes fails from HTTP 503 internally.
        -- Back off so Holy does not spam console every interval.
        ChatPromoteState.LastSent =
            os.clock()

        ChatPromoteState.FailUntil =
            os.clock() + 90

        warn(
            "[PROMOTE] TOTAL FAILURE | cooldown 90s |",
            tostring(failureReason or "unknown")
        )
    end
end
--------------------------------------------------
local AutoHopToggle = BoothBox:AddToggle("AutoServerHop", {
    Text = "🌍 Join New Server",
    Tooltip = "Joins new server every X min",
    Default = false,
})

AutoHopToggle:OnChanged(function(enabled)
    BoothAuto.AutoServerHop = enabled

    if enabled then
        BoothAuto.LastServerHop = os.clock()
    end

    MarkConfigDirty()
end)

local HopMinutesInput = BoothBox:AddInput("HopMinutes", {
    Text = "⌛ Minutes",
    Default = "10",
    Numeric = true,
    Finished = true,
})

HopMinutesInput:OnChanged(function(value)
    local num = tonumber(value)

    if not num then
        return
    end

    num = math.clamp(num, 1, 999)

    BoothAuto.ServerHopMinutes = num

    MarkConfigDirty()
end)

BoothBox:AddButton({
    Text = "Unclaim Booth",
    Tooltip = "Unclaim your current booth",
    Func = function()
        if ScriptState.ForceStopped then
            warn("[Booth] Blocked (ForceStopped)")
            return
        end

        local GameEvents = ReplicatedStorage:FindFirstChild("GameEvents")
        if not GameEvents then
            warn("[Booth] GameEvents missing")
            return
        end

        local RemoveBooth = GameEvents
            :WaitForChild("TradeEvents")
            :WaitForChild("Booths")
            :WaitForChild("RemoveBooth")

        local ok, err = pcall(function()
            RemoveBooth:FireServer()
        end)

        if not ok then
            warn("[Booth] Unclaim failed:", err)
        end
    end,
})
end
--==================================================
-- SNIPER FILTER STATE
--==================================================

WatchlistLabels = {}
WatchlistDropdown = nil
WatchlistSaveDropdown = nil

EggFocusLabels = {}
EggFocusInfoLabel = nil
RefreshEggFocus = nil

ITEMS_PER_PAGE = 7
WatchlistPage = 1
WatchlistInfoLabel = nil

RefreshWatchlist = nil

function BuildSniperTab()
--==================================================
-- SNIPER TAB → UI
--==================================================

--==================================================
-- SNIPER TAB → CLEAN TABBOX LAYOUT
-- Left side: Configuration + Add Filter
-- Right side: Watchlist + Egg Focus
--==================================================

local SniperConfigBox
local SniperFilterBox
local SniperWatchlistBox
local EggFocusBox

if type(Tabs.Sniper.AddLeftTabbox) == "function"
and type(Tabs.Sniper.AddRightTabbox) == "function" then

    local SniperLeftTabbox =
        Tabs.Sniper:AddLeftTabbox("SniperLeft")

    SniperConfigBox =
        SniperLeftTabbox:AddTab("Config", "settings")

    SniperFilterBox =
        SniperLeftTabbox:AddTab("Filter", "plus")

    local SniperRightTabbox =
        Tabs.Sniper:AddRightTabbox("SniperRight")

    SniperWatchlistBox =
        SniperRightTabbox:AddTab("Watchlist", "star")

    EggFocusBox =
        SniperRightTabbox:AddTab("Egg Focus", "egg")

else

    -- Fallback for older library versions.
    if type(Tabs.Sniper.AddLeftCollapsibleGroupbox) == "function" then

        SniperConfigBox =
            Tabs.Sniper:AddLeftCollapsibleGroupbox(
                "Sniper Configuration",
                "settings",
                true
            )

        SniperFilterBox =
            Tabs.Sniper:AddLeftCollapsibleGroupbox(
                "Add Filter",
                "plus",
                true
            )

        SniperWatchlistBox =
            Tabs.Sniper:AddRightCollapsibleGroupbox(
                "Active Watchlist",
                "star",
                true
            )

        EggFocusBox =
            Tabs.Sniper:AddRightCollapsibleGroupbox(
                "Egg Focus",
                "egg",
                false
            )

    else

        warn("[LIB TEST] Tabbox/collapsible unavailable, using normal groupboxes")

        SniperConfigBox =
            Tabs.Sniper:AddLeftGroupbox(
                "Sniper Configuration",
                "settings"
            )

        SniperFilterBox =
            Tabs.Sniper:AddLeftGroupbox(
                "Add Filter",
                "plus"
            )

        SniperWatchlistBox =
            Tabs.Sniper:AddRightGroupbox(
                "Active Watchlist",
                "star"
            )

        EggFocusBox =
            Tabs.Sniper:AddRightGroupbox(
                "Egg Focus",
                "egg"
            )
    end
end
--==================================================
-- SNIPER CONFIG CONTENT
-- Must be added before FILTER INPUTS so Config tab is not empty.
--==================================================
SniperConfigBox:AddDivider({
    Text = "Scan Speed",
    MarginTop = 4,
    MarginBottom = 8,
})

local ScanSpeedDropdown =
    SniperConfigBox:AddDropdown(
        "SniperScanSpeedMode",
        {
            Text = "⚡ Scan Speed",
            Tooltip = "Lower delay scans faster but can cause Server Shutdowns. Fast is recommended.",
            Values = {
                "Max Speed",
                "Fast",
                "Balanced",
                "Low CPU",
                "Ultra Safe",
            },
            Default = SniperState.ScanSpeedMode or "Fast",
            Searchable = false,
        }
    )

ScanSpeedDropdown:OnChanged(function(value)

    local interval =
        SetSniperScanSpeedMode(value)

    MarkConfigDirty()

    if ConfigState.IsHydrating then
        return
    end

    HolyNotify(
        "Scan Speed Updated",
        tostring(SniperState.ScanSpeedMode)
            .. " • "
            .. tostring(interval)
            .. "s interval",
        "zap",
        3
    )
end)

local BoothDataRefreshDropdown =
    SniperConfigBox:AddDropdown(
        "BoothDataRefreshMode",
        {
            Text = "📡 Booth Data Refresh",
            Tooltip = "How fast HOLY refreshes booth listings. Faster can snipe sooner but may cause lag. Recommended: Fast.",
            Values = {
                "Aggressive",
                "Fast",
                "Balanced",
                "Low CPU",
                "Ultra Safe",
            },
            Default = SniperState.BoothDataRefreshMode or "Fast",
            Searchable = false,
        }
    )

BoothDataRefreshDropdown:OnChanged(function(value)

    local interval =
        SetBoothDataRefreshMode(value)

    MarkConfigDirty()

    if ConfigState.IsHydrating then
        return
    end

    HolyNotify(
        "Booth Data Refresh Updated",
        tostring(SniperState.BoothDataRefreshMode)
            .. " • "
            .. tostring(interval)
            .. "s interval",
        "radio",
        3
    )
end)

SniperConfigBox:AddDivider({
    Text = "Server Hop",
    MarginTop = 4,
    MarginBottom = 8,
})

local MaxServerPlayersInput =
    SniperConfigBox:AddInput(
        "SniperMaxServerPlayers",
        {
            Text = "👥 Max Server Players",
            Default = tostring(SniperState.MaxServerPlayers),
            Numeric = true,
            Finished = true,
        }
    )

MaxServerPlayersInput:OnChanged(function(value)

    local num =
        tonumber(value)

    if not num then
        return
    end

    SniperState.MaxServerPlayers =
        math.clamp(
            math.floor(num),
            1,
            30
        )

    MarkConfigDirty()

    print(
        "[SniperHop] Max server players:",
        tostring(SniperState.MaxServerPlayers)
    )
end)

local ServerHopModeDropdown =
    SniperConfigBox:AddDropdown(
        "SniperServerHopMode",
        {
            Text = "⇄ Server Hop Mode",
            Values = {
                "Fullest Under Max",
                "Balanced",
                "Low Player",
            },
            Default = SniperState.ServerHopMode or "Fullest Under Max",
            Searchable = false,
        }
    )

ServerHopModeDropdown:OnChanged(function(value)

    SniperState.ServerHopMode =
        tostring(value or "Fullest Under Max")

    MarkConfigDirty()

    print(
        "[SniperHop] Mode:",
        tostring(SniperState.ServerHopMode)
    )
end)

local ServerHopPagesInput =
    SniperConfigBox:AddInput(
        "SniperServerHopPages",
        {
            Text = "📄 Server Hop Pages",
            Tooltip = "How many Roblox server-list pages to fetch. 1 is fastest; higher gives better server selection but slower hops.",
            Default = tostring(SniperState.ServerHopPages or 1),
            Numeric = true,
            Finished = true,
        }
    )

ServerHopPagesInput:OnChanged(function(value)

    local pages =
        tonumber(value)

    if not pages then
        return
    end

    SniperState.ServerHopPages =
        math.clamp(
            math.floor(pages),
            1,
            10
        )

    MarkConfigDirty()

    print(
        "[SniperHop] Server hop pages:",
        tostring(SniperState.ServerHopPages)
    )
end)

SniperConfigBox:AddDivider({
    Text = "After Snipe",
    MarginTop = 10,
    MarginBottom = 8,
})

local StayAfterSnipeToggle =
    SniperConfigBox:AddToggle(
        "StayAfterSnipe",
        {
            Text = "⏱️ Stay After Snipe",
            Tooltip = "Stay in the server a little longer after Holy snipes a pet.",
            Default = SniperState.StayAfterSnipe == true,
        }
    )

StayAfterSnipeToggle:OnChanged(function(enabled)

    SniperState.StayAfterSnipe =
        enabled == true

    MarkConfigDirty()

    if ConfigState.IsHydrating then
        return
    end

    HolyNotify(
        enabled and "Stay After Snipe Enabled" or "Stay After Snipe Disabled",
        enabled and "Holy will wait after a confirmed snipe before hopping." or "Holy will hop normally after the scan timer ends.",
        enabled and "clock" or "pause",
        3
    )
end)

local StayAfterSnipeDependencyBox =
    SniperConfigBox:AddDependencyBox()

local StayAfterSnipeInput =
    StayAfterSnipeDependencyBox:AddInput(
        "StayAfterSnipeSeconds",
        {
            Text = "Extra Stay (sec)",
            Tooltip = "Adds extra time only after Holy successfully confirms a snipe.",
            Default = tostring(SniperState.StayAfterSnipeSeconds or 5),
            Numeric = true,
            Finished = true,
        }
    )

StayAfterSnipeInput:OnChanged(function(value)

    local num =
        tonumber(value)

    if not num then
        return
    end

    SniperState.StayAfterSnipeSeconds =
        math.clamp(
            math.floor(num),
            0,
            60
        )

    MarkConfigDirty()

    if ConfigState.IsHydrating then
        return
    end

    HolyNotify(
        "Stay Time Updated",
        "Extra stay time set to "
            .. tostring(SniperState.StayAfterSnipeSeconds)
            .. " seconds.",
        "clock",
        3
    )
end)

StayAfterSnipeDependencyBox:SetupDependencies({
    {
        StayAfterSnipeToggle,
        true,
    },
})

SniperConfigBox:AddDivider({
    Text = "Inventory Safety",
    MarginTop = 10,
    MarginBottom = 8,
})

local InventoryLimitToggle =
    SniperConfigBox:AddToggle(
        "StopAtPetInventoryLimit",
        {
            Text = "📦 Stop At Pet Limit",
            Tooltip = "Stops Holy from buying when your visible pet inventory reaches the selected limit.",
            Default = SniperState.StopAtPetInventoryLimit == false,
        }
    )

InventoryLimitToggle:OnChanged(function(enabled)

    SniperState.StopAtPetInventoryLimit =
        enabled == true

    if type(RefreshInventoryDetails) == "function" then
        RefreshInventoryDetails()
    end

    MarkConfigDirty()

    if ConfigState.IsHydrating then
        return
    end

    HolyNotify(
        enabled and "Inventory Safety Enabled" or "Inventory Safety Disabled",
        enabled and "Holy will stop buying at your pet limit." or "Holy can buy even above the selected pet limit.",
        enabled and "package-check" or "package-x",
        3
    )
end)

local MaxPetInventoryInput =
    SniperConfigBox:AddInput(
        "MaxPetInventory",
        {
            Text = "Max Pet Inventory",
            Tooltip = "Holy stops queueing snipes when visible pets reach this number.",
            Default = tostring(SniperState.MaxPetInventory or 350),
            Numeric = true,
            Finished = true,
        }
    )

MaxPetInventoryInput:OnChanged(function(value)

    local num =
        tonumber(value)

    if not num then
        return
    end

    SniperState.MaxPetInventory =
        math.clamp(
            math.floor(num),
            1,
            9999
        )

    if type(RefreshInventoryDetails) == "function" then
        RefreshInventoryDetails()
    end

    MarkConfigDirty()

    if ConfigState.IsHydrating then
        return
    end

    HolyNotify(
        "Pet Limit Updated",
        "Holy will stop buying at "
            .. tostring(SniperState.MaxPetInventory)
            .. " visible pets.",
        "package",
        3
    )
end)
--==================================================
-- FILTER INPUTS
--==================================================

WatchlistSaveDropdown =
    SniperFilterBox:AddDropdown(
        "SniperFilterSaveTarget",
        {
            Text = "Save To",
            Values = {
                "Watchlist 1",
                "Watchlist 2",
            },
            Default = "Watchlist 1",
            Searchable = false,
        }
    )

WatchlistSaveDropdown:OnChanged(function(value)

    SniperFilterUIState.SaveTarget =
        NormalizeWatchlistId(value)

    MarkConfigDirty()
end)

local WeightModeDropdown =
    SniperFilterBox:AddDropdown(
        "SniperWeightMode",
        {
            Text = "Weight Mode",
            Tooltip = "Base Weight is best for accurate sniping. Display KG matches the in-game weight.",
            Values = {
                "Display KG",
                "Base Weight",
            },
            Default = "Display KG",
            Searchable = false,
        }
    )

WeightModeDropdown:OnChanged(function(value)

    SniperFilterUIState.WeightMode =
        NormalizeWeightMode(value)

    MarkConfigDirty()
end)

RefreshDynamicPetList()

local PetDropdown =
    SniperFilterBox:AddDropdown(
        "SniperPetSelectMultiV2",
        {
            Text = "Pets",
            Tooltip = "Select one or more pets. The same price, weight, priority, and mutation filter will be applied to every selected pet.",
            Values = PetList,
            Default = {},
            Searchable = true,
            Multi = true,
        }
    )

PetDropdown:OnChanged(function()
    MarkConfigDirty()
end)

local MinWeightInput =
    SniperFilterBox:AddInput(
        "SniperMinWeight",
        {
            Text = "Min Weight",
            Placeholder = "Display KG or BaseWeight",
        }
    )

local MaxPriceInput =
    SniperFilterBox:AddInput(
        "SniperMaxPrice",
        {
            Text = "Max Price",
            Placeholder = "empty = inf",
        }
    )

local PriorityInput =
    SniperFilterBox:AddInput(
        "SniperFilterPriority",
        {
            Text = "Priority",
            Tooltip = "1 = low priority, 10 = buy first.",
            Default = "5",
            Numeric = true,
            Finished = true,
        }
    )

PriorityInput:OnChanged(function(value)

    SniperFilterUIState.Priority =
        ClampSniperPriority(value)

    MarkConfigDirty()
end)

--==================================================
-- SNIPER MUTATION FILTER UI
-- Mutation filtering is optional.
-- Off = old sniper behavior.
--==================================================

if type(RefreshListingMutationList) == "function" then
    RefreshListingMutationList()
end

local SniperMutationValueList = {}

for _, mutationName in ipairs(ListingMutationList or {}) do

    mutationName =
        tostring(mutationName or "")

    if mutationName ~= ""
    and mutationName ~= "---"
    and mutationName ~= "Normal"
    and mutationName ~= "Unknown" then

        table.insert(
            SniperMutationValueList,
            mutationName
        )
    end
end

local SniperMutationModeList = {
    "Off",
    "Mutated Only",
    "Specific Mutations",
    "Exclude Mutations",
}

local SniperMutationSelectionDropdown = nil

local function ApplySniperMutationSelectionToState()

    local mode =
        NormalizeSniperFilterMutation(
            SniperFilterUIState.SelectedMutation
        )

    local selected =
        CloneSniperMutationMap(
            SniperFilterUIState.SelectedMutationSelection
        )

    if mode == "Specific Mutations" then

        SniperFilterUIState.SelectedSpecificMutations =
            CloneSniperMutationMap(selected)

        SniperFilterUIState.SelectedExcludedMutations =
            {}

        return
    end

    if mode == "Exclude Mutations" then

        SniperFilterUIState.SelectedSpecificMutations =
            {}

        SniperFilterUIState.SelectedExcludedMutations =
            CloneSniperMutationMap(selected)

        return
    end

    -- Off / Mutated Only do not use selected mutations.
    SniperFilterUIState.SelectedSpecificMutations =
        {}

    SniperFilterUIState.SelectedExcludedMutations =
        {}
end

local function RefreshSniperMutationSelectionVisibility()

    if not SniperMutationSelectionDropdown then
        return
    end

    local mode =
        NormalizeSniperFilterMutation(
            SniperFilterUIState.SelectedMutation
        )

    local shouldShow =
        mode == "Specific Mutations"
        or mode == "Exclude Mutations"

    if type(SniperMutationSelectionDropdown.SetVisible) == "function" then

        SniperMutationSelectionDropdown:SetVisible(
            shouldShow
        )
    end
end

local SniperMutationDropdown =
    SniperFilterBox:AddDropdown(
        "SniperMutationFilterMode",
        {
            Text = "Mutation Filter",
            Tooltip = "Off = no mutation rule; buys normal and mutated pets. Mutated Only = only pets with mutations. Specific Mutations = only selected mutations. Exclude Mutations = skip selected mutations.",
            Values = SniperMutationModeList,
            Default = "Off",
            Searchable = false,
        }
    )

SniperMutationDropdown:OnChanged(function(value)

    SniperFilterUIState.SelectedMutation =
        NormalizeSniperFilterMutation(value)

    ApplySniperMutationSelectionToState()
    RefreshSniperMutationSelectionVisibility()

    MarkConfigDirty()

    print(
        "[Sniper] Mutation filter:",
        SniperFilterUIState.SelectedMutation
    )
end)

SniperMutationSelectionDropdown =
    SniperFilterBox:AddDropdown(
        "SniperMutationSelectionMultiV3",
        {
            Text = "Select Mutations",
            Tooltip = "Only used when Mutation Filter is Specific Mutations or Exclude Mutations. Specific = only selected mutations. Exclude = skip selected mutations.",
            Values = SniperMutationValueList,
            Default = {},
            Searchable = true,
            Multi = true,
        }
    )

SniperMutationSelectionDropdown:OnChanged(function(value)

    SniperFilterUIState.SelectedMutationSelection =
        BuildSniperMutationMapFromDropdownValue(value)

    ApplySniperMutationSelectionToState()

    MarkConfigDirty()

    print(
        "[Sniper] Selected mutations:",
        table.concat(
            SerializeSniperMutationMap(
                SniperFilterUIState.SelectedMutationSelection
            ),
            ", "
        )
    )
end)

ApplySniperMutationSelectionToState()
RefreshSniperMutationSelectionVisibility()

--==================================================
-- WATCHLIST VIEW SELECTOR
-- Both watchlists are active for sniping; this only changes display/manage.
--==================================================

WatchlistDropdown =
    SniperWatchlistBox:AddDropdown(
        "SniperWatchlistView",
        {
            Text = "Viewing",
            Values = {
                "Watchlist 1",
                "Watchlist 2",
            },
            Default = "Watchlist 1",
            Searchable = false,
        }
    )

WatchlistDropdown:OnChanged(function(value)

    SniperFilterUIState.ViewTarget =
        NormalizeWatchlistId(value)

    WatchlistPage = 1

    if IsTradeWorld()
and type(RefreshWatchlist) == "function" then
    RefreshWatchlist()
end
    MarkConfigDirty()
end)
--==================================================
-- WATCHLIST LABEL POOL
-- Clean compact rows with aligned columns.
--==================================================

WatchlistInfoLabel =
    SniperWatchlistBox:AddLabel(
        "Watchlist 1 • 0 filters • Page 1/1",
        false
    )

for i = 1, ITEMS_PER_PAGE do

    local lbl =
        SniperWatchlistBox:AddLabel(" ", false)

    lbl:SetVisible(false)

    table.insert(
        WatchlistLabels,
        lbl
    )
end

--==================================================
-- PAGINATION
--==================================================

local PageButton =
    SniperWatchlistBox:AddButton({
        Text = "‹ Prev",

        Func = function()

            if WatchlistPage > 1 then
                WatchlistPage =
                    WatchlistPage - 1

                if IsTradeWorld()
and type(RefreshWatchlist) == "function" then
    RefreshWatchlist()
end
            end
        end,
    })

PageButton:AddButton({
    Text = "Next ›",

    Func = function()

        local total =
            CountSniperFilterSet(
                SniperFilterUIState.ViewTarget
            )

        local maxPages =
            math.max(
                1,
                math.ceil(total / ITEMS_PER_PAGE)
            )

        if WatchlistPage < maxPages then
            WatchlistPage =
                WatchlistPage + 1

            if IsTradeWorld()
and type(RefreshWatchlist) == "function" then
    RefreshWatchlist()
end
        end
    end,
})

--==================================================
-- WATCHLIST MANAGEMENT
--==================================================

SniperWatchlistBox:AddButton({
    Text = "Manage Watchlist",
    Tooltip = "Remove a filter from the currently viewed watchlist.",

    Func = function()

        local viewTarget =
            NormalizeWatchlistId(
                SniperFilterUIState.ViewTarget
            )

        local filters =
            GetSniperFilterSet(viewTarget)

        local total =
            CountSniperFilterSet(viewTarget)

        if total <= 0 then

            HolyNotify(
                "Watchlist Empty",
                "There are no filters to manage in Watchlist "
                    .. tostring(viewTarget)
                    .. ".",
                "info",
                3
            )

            return
        end

        local removeQuery = ""

        local ManageDialog = nil

        local function FindFilterByQuery(query)

            query =
                tostring(query or "")
                    :lower()
                    :gsub("^%s+", "")
                    :gsub("%s+$", "")

            if query == "" then
                return nil, "EMPTY"
            end

            local exactMatch = nil
            local partialMatches = {}

            for pet in pairs(filters) do

                local petText =
                    tostring(pet)

                local petLower =
                    petText:lower()

                if petLower == query then
                    exactMatch = petText
                    break
                end

                if petLower:find(query, 1, true) then
                    table.insert(
                        partialMatches,
                        petText
                    )
                end
            end

            if exactMatch then
                return exactMatch, "EXACT"
            end

            if #partialMatches == 1 then
                return partialMatches[1], "PARTIAL"
            end

            if #partialMatches > 1 then
                return nil, "MULTIPLE", partialMatches
            end

            return nil, "NONE"
        end

        ManageDialog =
            Window:AddDialog(
                "ManageWatchlistDialog",
                {
                    Title =
                        "Manage Watchlist "
                        .. tostring(viewTarget),

                    Description =
                        "Type a pet name to remove it from Watchlist "
                        .. tostring(viewTarget)
                        .. ".",

                    Icon = "star",
                    AutoDismiss = true,
                    OutsideClickDismiss = true,

                    FooterButtons = {
                        Cancel = {
                            Title = "Cancel",
                            Variant = "Ghost",
                            Order = 1,

                            Callback = function()

                                if ManageDialog then
                                    ManageDialog:Dismiss()
                                end
                            end,
                        },

                        Remove = {
                            Title = "Remove",
                            Variant = "Destructive",
                            Order = 2,

                            Callback = function()

                                local selectedPet, status, matches =
                                    FindFilterByQuery(removeQuery)

                                if status == "EMPTY" then

                                    HolyNotify(
                                        "No Filter Typed",
                                        "Type the pet name you want to remove.",
                                        "triangle-alert",
                                        3
                                    )

                                    return
                                end

                                if status == "MULTIPLE" then

                                    HolyNotify(
                                        "Too Many Matches",
                                        "Type more of the pet name.",
                                        "search",
                                        4
                                    )

                                    return
                                end

                                if status == "NONE"
                                or not selectedPet then

                                    HolyNotify(
                                        "Filter Not Found",
                                        "No watchlist filter matched that name.",
                                        "triangle-alert",
                                        3
                                    )

                                    return
                                end

                                filters[selectedPet] = nil

                                WatchlistPage = 1

                                if IsTradeWorld()
                            and type(RefreshWatchlist) == "function" then
                                RefreshWatchlist()
                            end

                                MarkConfigDirty()

                                SaveSniperFilters()

                                HolyNotify(
                                    "Filter Removed",
                                    tostring(selectedPet)
                                        .. " was removed from Watchlist "
                                        .. tostring(viewTarget)
                                        .. ".",
                                    "trash",
                                    3
                                )

                                if ManageDialog then
                                    ManageDialog:Dismiss()
                                end
                            end,
                        },
                    },
                }
            )

        ManageDialog:AddInput(
            "ManageWatchlistSearch",
            {
                Text = "Pet Name",
                Placeholder = "e.g. Rainbow Elephant",
                Numeric = false,
                Finished = false,

                Callback = function(value)

                    removeQuery =
                        tostring(value or "")
                end,
            }
        )
    end,
})

--==================================================
-- CLEAR WATCHLIST
-- Destructive action guarded by confirmation dialog.
--==================================================

SniperWatchlistBox:AddButton({
    Text = "🗑 Clear Watchlist",
    Tooltip = "Clear the currently viewed watchlist only.",

    Func = function()

        local viewTarget =
            NormalizeWatchlistId(
                SniperFilterUIState.ViewTarget
            )

        local filters =
            GetSniperFilterSet(viewTarget)

        local total =
            CountSniperFilterSet(viewTarget)

        if total <= 0 then

            HolyNotify(
                "Watchlist Empty",
                "There are no filters to clear in Watchlist "
                    .. tostring(viewTarget)
                    .. ".",
                "info",
                3
            )

            return
        end

        local ClearDialog = nil

        ClearDialog =
            Window:AddDialog(
                "ClearWatchlistDialog",
                {
                    Title =
                        "Clear Watchlist "
                        .. tostring(viewTarget)
                        .. "?",

                    Description =
                        "This will permanently remove all "
                        .. tostring(total)
                        .. " filters from Watchlist "
                        .. tostring(viewTarget)
                        .. ". The other watchlist will stay active.",

                    Icon = "triangle-alert",
                    AutoDismiss = true,
                    OutsideClickDismiss = true,

                    FooterButtons = {
                        Cancel = {
                            Title = "Cancel",
                            Variant = "Ghost",
                            Order = 1,

                            Callback = function()

                                if ClearDialog then
                                    ClearDialog:Dismiss()
                                end
                            end,
                        },

                        Delete = {
                            Title = "Clear All",
                            Variant = "Destructive",
                            WaitTime = 2,
                            Order = 2,

                            Callback = function()

                                table.clear(filters)

                                WatchlistPage = 1

                                if IsTradeWorld()
and type(RefreshWatchlist) == "function" then
    RefreshWatchlist()
end

                                MarkConfigDirty()

                                SaveSniperFilters()

                                HolyNotify(
                                    "Watchlist Cleared",
                                    "Watchlist "
                                        .. tostring(viewTarget)
                                        .. " was cleared.",
                                    "trash-2",
                                    4
                                )

                                if ClearDialog then
                                    ClearDialog:Dismiss()
                                end
                            end,
                        },
                    },
                }
            )
    end,
})

--==================================================
-- EGG FOCUS UI
-- Simple egg-based filters.
--==================================================

local EggFocusNames =
    GetEggFocusNames()


local EggFocusEggDropdown =
    EggFocusBox:AddDropdown(
        "EggFocusEggSelect",
        {
            Text = "Egg",
            Values = EggFocusNames,
            Default = "",
            Searchable = true,
        }
    )

local EggFocusMaxPriceInput =
    EggFocusBox:AddInput(
        "EggFocusMaxPrice",
        {
            Text = "Max Price",
            Placeholder = "required",
            Numeric = true,
            Finished = true,
        }
    )

EggFocusBox:AddButton({
    Text = "Add / Update Egg Focus",
    Tooltip = "Snipes any pet from the selected egg under the max price.",

    Func = function()

        local eggName =
            EggFocusEggDropdown.Value

        if not eggName
        or eggName == "" then

            HolyNotify(
                "No Egg Selected",
                "Choose an egg before adding an Egg Focus.",
                "egg",
                3
            )

            return
        end

        local pets =
            GetEggFocusPets(eggName)

        if #pets <= 0 then

            HolyNotify(
                "Egg Has No Pets",
                tostring(eggName)
                    .. " has no readable pet pool.",
                "triangle-alert",
                4
            )

            return
        end

local maxPriceText =
    tostring(EggFocusMaxPriceInput.Value or "")
        :gsub(",", "")
        :gsub("%s+", "")

local maxPrice =
    tonumber(maxPriceText)

if not maxPrice
or maxPrice <= 0 then

    HolyNotify(
        "Max Price Required",
        "Enter a max price before adding an Egg Focus.",
        "triangle-alert",
        4
    )

    return
end

maxPrice =
    math.floor(maxPrice)

        local saveTarget =
    1

local eggFilters =
    GetEggFocusSet(saveTarget)

        eggFilters[tostring(eggName)] = {
            MaxPrice = maxPrice,
        }

        EggFocusUIState.ViewTarget =
            saveTarget

        if type(RefreshEggFocus) == "function" then
            if IsTradeWorld()
and type(RefreshEggFocus) == "function" then
    RefreshEggFocus()
end
        end

        MarkConfigDirty()

        SaveSniperFilters()

        HolyNotify(
    "Egg Focus Updated",
    tostring(eggName)
        .. " added with "
        .. tostring(#pets)
        .. " pets.",
    "egg",
    4
)
    end,
})

EggFocusInfoLabel =
    EggFocusBox:AddLabel(
        "Watchlist 1 • 0 egg focuses",
        false
    )

for i = 1, 5 do

    local lbl =
        EggFocusBox:AddLabel(" ", false)

    lbl:SetVisible(false)

    table.insert(
        EggFocusLabels,
        lbl
    )
end

EggFocusBox:AddButton({
    Text = "Manage Egg Focus",
    Tooltip = "Remove an egg focus from the currently viewed watchlist.",

    Func = function()

        local viewTarget = 1

        local eggFilters =
            GetEggFocusSet(viewTarget)

        local total =
            CountEggFocusSet(viewTarget)

        if total <= 0 then

            HolyNotify(
                "Egg Focus Empty",
                "There are no egg focuses in Watchlist "
                    .. tostring(viewTarget)
                    .. ".",
                "info",
                3
            )

            return
        end

        local removeQuery = ""

        local ManageDialog = nil

        local function FindEggByQuery(query)

            query =
                tostring(query or "")
                    :lower()
                    :gsub("^%s+", "")
                    :gsub("%s+$", "")

            if query == "" then
                return nil, "EMPTY"
            end

            local exactMatch = nil
            local partialMatches = {}

            for eggName in pairs(eggFilters) do

                local eggText =
                    tostring(eggName)

                local eggLower =
                    eggText:lower()

                if eggLower == query then
                    exactMatch = eggText
                    break
                end

                if eggLower:find(query, 1, true) then
                    table.insert(
                        partialMatches,
                        eggText
                    )
                end
            end

            if exactMatch then
                return exactMatch, "EXACT"
            end

            if #partialMatches == 1 then
                return partialMatches[1], "PARTIAL"
            end

            if #partialMatches > 1 then
                return nil, "MULTIPLE", partialMatches
            end

            return nil, "NONE"
        end

        ManageDialog =
            Window:AddDialog(
                "ManageEggFocusDialog",
                {
                    Title =
                        "Manage Egg Focus "
                        .. tostring(viewTarget),

                    Description =
                        "Type an egg name to remove it from Watchlist "
                        .. tostring(viewTarget)
                        .. ".",

                    Icon = "egg",
                    AutoDismiss = true,
                    OutsideClickDismiss = true,

                    FooterButtons = {
                        Cancel = {
                            Title = "Cancel",
                            Variant = "Ghost",
                            Order = 1,

                            Callback = function()

                                if ManageDialog then
                                    ManageDialog:Dismiss()
                                end
                            end,
                        },

                        Remove = {
                            Title = "Remove",
                            Variant = "Destructive",
                            Order = 2,

                            Callback = function()

                                local selectedEgg, status =
                                    FindEggByQuery(removeQuery)

                                if status == "EMPTY" then

                                    HolyNotify(
                                        "No Egg Typed",
                                        "Type the egg name you want to remove.",
                                        "triangle-alert",
                                        3
                                    )

                                    return
                                end

                                if status == "MULTIPLE" then

                                    HolyNotify(
                                        "Too Many Matches",
                                        "Type more of the egg name.",
                                        "search",
                                        4
                                    )

                                    return
                                end

                                if status == "NONE"
                                or not selectedEgg then

                                    HolyNotify(
                                        "Egg Focus Not Found",
                                        "No egg focus matched that name.",
                                        "triangle-alert",
                                        3
                                    )

                                    return
                                end

                                eggFilters[selectedEgg] = nil

                                if IsTradeWorld()
and type(RefreshEggFocus) == "function" then
    RefreshEggFocus()
end

                                MarkConfigDirty()

                                SaveSniperFilters()

                                HolyNotify(
                                    "Egg Focus Removed",
                                    tostring(selectedEgg)
                                        .. " was removed from Watchlist "
                                        .. tostring(viewTarget)
                                        .. ".",
                                    "trash",
                                    3
                                )

                                if ManageDialog then
                                    ManageDialog:Dismiss()
                                end
                            end,
                        },
                    },
                }
            )

        ManageDialog:AddInput(
            "ManageEggFocusSearch",
            {
                Text = "Egg Name",
                Placeholder = "e.g. Paradise Egg",
                Numeric = false,
                Finished = false,

                Callback = function(value)

                    removeQuery =
                        tostring(value or "")
                end,
            }
        )
    end,
})
--==================================================
-- WATCHLIST HUD REFRESH
-- Shows both watchlists because both are active for sniping.
--==================================================

RefreshWatchlistHUD = function()

    if not WatchlistHUDContainer then
        return
    end

    for _, child in ipairs(
        WatchlistHUDContainer:GetChildren()
    ) do
        if child:IsA("Frame")
        or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local function ShortenText(text, maxLength)

        text =
            tostring(text or "")

        if #text <= maxLength then
            return text
        end

        return text:sub(1, maxLength - 3) .. "..."
    end

    local function FormatCompactPrice(value)

        if value == math.huge then
            return "∞"
        end

        local number =
            tonumber(value)

        if not number then
            return "0"
        end

        number =
            math.floor(number)

        if number >= 1000000 then
            return tostring(
                math.floor(number / 100000) / 10
            ) .. "M"
        end

        if number >= 1000 then
            return tostring(
                math.floor(number / 100) / 10
            ) .. "K"
        end

        return tostring(number)
    end

    local function FormatCompactWeight(value, weightMode)

        local number =
            tonumber(value)
            or 0

        if number <= 0 then
            return "any"
        end

        weightMode =
            NormalizeWeightMode(weightMode)

        local suffix =
            weightMode == "BaseWeight"
            and "bw"
            or "kg"

        local text

        if number % 1 == 0 then
            text =
                tostring(math.floor(number))
        else
            text =
                string.format("%.1f", number)
        end

        return "≥"
            .. text
            .. suffix
    end

    local function CreateHudLabel(text, height, textSize, color, font, order)

        local holder =
            Instance.new("Frame")

        holder.BackgroundTransparency =
            1

        holder.Size =
            UDim2.new(1, 0, 0, height)

        holder.LayoutOrder =
            order or 0

        holder.Parent =
            WatchlistHUDContainer

        local label =
            Instance.new("TextLabel")

        label.BackgroundTransparency =
            1

        label.Size =
            UDim2.new(1, 0, 1, 0)

        label.Font =
            font or Enum.Font.GothamBold

        label.TextSize =
            textSize

        label.TextXAlignment =
            Enum.TextXAlignment.Right

        label.TextYAlignment =
            Enum.TextYAlignment.Center

        label.TextStrokeTransparency =
            0.20

        label.TextStrokeColor3 =
            Color3.fromRGB(0, 0, 0)

        label.TextColor3 =
            color

        label.Text =
            text

        label.Parent =
            holder

        return label
    end

    local visibleRows =
        0

    local maxRows =
        math.floor(
            (
                workspace.CurrentCamera
                and workspace.CurrentCamera.ViewportSize.Y
                or 720
            ) / 15
        )

    maxRows =
        math.clamp(
            maxRows,
            24,
            54
        )

    local hiddenCount =
        0

    local function BuildEntries(watchlistId)

        local filters =
            GetSniperFilterSet(watchlistId)

        local entries = {}

        for pet, data in pairs(filters) do

            table.insert(entries, {
                Pet = tostring(pet),
                MaxPrice = data.MaxPrice,
                MinWeight = tonumber(data.MinWeight) or 0,
                WeightMode = data.WeightMode,
                Priority = ResolveSniperFilterPriority(data),
            })
        end

        table.sort(entries, function(a, b)

            if a.Priority ~= b.Priority then
                return a.Priority > b.Priority
            end

            local aPrice =
                a.MaxPrice == math.huge
                and math.huge
                or tonumber(a.MaxPrice)
                or 0

            local bPrice =
                b.MaxPrice == math.huge
                and math.huge
                or tonumber(b.MaxPrice)
                or 0

            if aPrice ~= bPrice then
                return aPrice > bPrice
            end

            return a.Pet < b.Pet
        end)

        return entries
    end

    local function RenderSection(watchlistId, labelText)

        if watchlistId == 1
        and VisualState.ShowWatchlist1HUD == false then
            return
        end

        if watchlistId == 2
        and VisualState.ShowWatchlist2HUD == false then
            return
        end

        local entries =
            BuildEntries(watchlistId)

        if #entries <= 0 then
            return
        end

        if visibleRows >= maxRows then
            hiddenCount += #entries
            return
        end

        CreateHudLabel(
            labelText,
            17,
            12,
            Color3.fromRGB(220, 235, 255),
            Enum.Font.GothamBlack,
            visibleRows
        )

        visibleRows += 1

        for _, entry in ipairs(entries) do

            if visibleRows >= maxRows then
                hiddenCount += 1
                continue
            end

            local petText =
                ShortenText(
                    entry.Pet,
                    21
                )

            local priceText =
                FormatCompactPrice(
                    entry.MaxPrice
                )

            local weightText =
                FormatCompactWeight(
                    entry.MinWeight,
                    entry.WeightMode
                )

            local rowText =
                tostring(petText)
                .. "   "
                .. tostring(priceText)
                .. "   "
                .. tostring(weightText)

            local color =
                Color3.fromRGB(225, 230, 240)

            if visibleRows <= 4 then
                color =
                    Color3.fromRGB(245, 248, 255)
            elseif visibleRows <= 10 then
                color =
                    Color3.fromRGB(210, 220, 235)
            else
                color =
                    Color3.fromRGB(175, 182, 195)
            end

            CreateHudLabel(
                rowText,
                15,
                11,
                color,
                Enum.Font.GothamBold,
                visibleRows
            )

            visibleRows += 1
        end
    end

    RenderSection(
        1,
        "Ⅰ  WATCHLIST 1"
    )

    if visibleRows > 0
    and VisualState.ShowWatchlist1HUD ~= false
    and VisualState.ShowWatchlist2HUD ~= false
    and CountSniperFilterSet(2) > 0 then

        CreateHudLabel(
            "",
            5,
            8,
            Color3.fromRGB(140, 160, 190),
            Enum.Font.GothamBold,
            visibleRows
        )

        visibleRows += 1
    end

    RenderSection(
        2,
        "Ⅱ  WATCHLIST 2"
    )

    if visibleRows <= 0 then

        CreateHudLabel(
            "No active watchlist filters",
            15,
            10,
            Color3.fromRGB(160, 170, 185),
            Enum.Font.GothamBold,
            1
        )

        return
    end

    if hiddenCount > 0 then

        CreateHudLabel(
            "+"
                .. tostring(hiddenCount)
                .. " more",
            14,
            10,
            Color3.fromRGB(150, 165, 185),
            Enum.Font.GothamBold,
            visibleRows + 1
        )
    end
end
--==================================================
-- EGG FOCUS REFRESH
--==================================================

RefreshEggFocus = function()

    local viewTarget =
        1

    local eggFilters =
        GetEggFocusSet(viewTarget)

    local entries = {}

    for eggName, data in pairs(eggFilters) do

        local pets =
            GetEggFocusPets(eggName)

        table.insert(entries, {
            EggName = tostring(eggName),
            MaxPrice = data.MaxPrice,
            PetCount = #pets,
        })
    end

    table.sort(entries, function(a, b)

        local aPrice =
            a.MaxPrice == math.huge
            and math.huge
            or tonumber(a.MaxPrice)
            or 0

        local bPrice =
            b.MaxPrice == math.huge
            and math.huge
            or tonumber(b.MaxPrice)
            or 0

        if aPrice ~= bPrice then
            return aPrice > bPrice
        end

        return a.EggName < b.EggName
    end)

    local function FormatPrice(value)

        if value == math.huge then
            return "∞"
        end

        local number =
            tonumber(value)

        if not number then
            return "0"
        end

        number =
            math.floor(number)

        local formatted =
            tostring(number)

        while true do

            local nextFormatted, changed =
                formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")

            formatted =
                nextFormatted

            if changed <= 0 then
                break
            end
        end

        return formatted
    end

    if EggFocusInfoLabel then
        EggFocusInfoLabel:SetText(
    "Egg Focus • "
        .. tostring(#entries)
        .. " eggs"
)
    end

    for i = 1, #EggFocusLabels do

        local label =
            EggFocusLabels[i]

        local entry =
            entries[i]

        if entry then

            label:SetText(
    "🥚 "
        .. tostring(entry.EggName)
        .. "  ≤"
        .. FormatPrice(entry.MaxPrice)
        .. "  • "
        .. tostring(entry.PetCount)
        .. " pets"
)

            label:SetVisible(true)

        else

            label:SetVisible(false)
        end
    end
end
--==================================================
-- WATCHLIST REFRESH
--==================================================

RefreshWatchlist = function()

    RefreshWatchlistHUD()

    local viewTarget =
        NormalizeWatchlistId(
            SniperFilterUIState.ViewTarget
        )

    local filters =
        GetSniperFilterSet(viewTarget)

    local entries = {}

    for pet, data in pairs(filters) do

        local maxPrice =
            data.MaxPrice

        local minWeight =
            tonumber(data.MinWeight)
            or 0

        table.insert(entries, {
    Pet = tostring(pet),
    MaxPrice = maxPrice,
    MinWeight = minWeight,
    WeightMode = data.WeightMode,
    Priority = ResolveSniperFilterPriority(data),
})
    end

    table.sort(entries, function(a, b)

        local aPrice =
            a.MaxPrice == math.huge
            and math.huge
            or tonumber(a.MaxPrice)
            or 0

        local bPrice =
            b.MaxPrice == math.huge
            and math.huge
            or tonumber(b.MaxPrice)
            or 0

        if aPrice ~= bPrice then
            return aPrice > bPrice
        end

        return a.Pet < b.Pet
    end)

    local function ShortenText(text, maxLength)

        text =
            tostring(text or "")

        if #text <= maxLength then
            return text
        end

        return text:sub(1, maxLength - 3) .. "..."
    end

    local function PadRight(text, width)

        text =
            tostring(text or "")

        if #text >= width then
            return text
        end

        return text .. string.rep(" ", width - #text)
    end

    local function PadLeft(text, width)

        text =
            tostring(text or "")

        if #text >= width then
            return text
        end

        return string.rep(" ", width - #text) .. text
    end

    local function FormatNumber(value)

        if value == math.huge then
            return "∞"
        end

        local number =
            tonumber(value)

        if not number then
            return "0"
        end

        number =
            math.floor(number)

        local formatted =
            tostring(number)

        while true do

            local nextFormatted, changed =
                formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")

            formatted =
                nextFormatted

            if changed <= 0 then
                break
            end
        end

        return formatted
    end

    local function FormatWeight(value, weightMode)
        return FormatFilterWeight(value, weightMode)
    end

    local total =
        #entries

    local maxPages =
        math.max(
            1,
            math.ceil(total / ITEMS_PER_PAGE)
        )

    WatchlistPage =
        math.clamp(
            SafeNumber(WatchlistPage, 1),
            1,
            maxPages
        )

    if WatchlistInfoLabel then
        WatchlistInfoLabel:SetText(
            "Watchlist "
                .. tostring(viewTarget)
                .. " • "
                .. tostring(total)
                .. " filters • Page "
                .. tostring(WatchlistPage)
                .. "/"
                .. tostring(maxPages)
                .. " • Total active: "
                .. tostring(CountAllSniperFilters())
        )
    end

    local startIndex =
        (WatchlistPage - 1)
        * ITEMS_PER_PAGE

    for i = 1, #WatchlistLabels do

        local label =
            WatchlistLabels[i]

        local entry =
            entries[startIndex + i]

        if entry then

            local globalIndex =
                startIndex + i

            local marker =
                globalIndex <= 2
                and "★"
                or "•"

            local petText =
                PadRight(
                    ShortenText(entry.Pet, 22),
                    22
                )

            local priceText =
                PadLeft(
                    FormatNumber(entry.MaxPrice),
                    7
                )

            local weightText =
                PadLeft(
                    FormatWeight(
                        entry.MinWeight,
                        entry.WeightMode
                    ),
                    8
                )

local priorityText =
    PadLeft(
        "P" .. tostring(
            ClampSniperPriority(entry.Priority)
        ),
        4
    )

local mutationText =
    PadRight(
        ShortenText(
            FormatSniperMutationFilter(entry),
            16
        ),
        16
    )

            label:SetText(
    marker
        .. " "
        .. petText
        .. " "
        .. priceText
        .. " "
        .. weightText
        .. " "
        .. priorityText
        .. " "
        .. mutationText
)

            label:SetVisible(true)

        else

            label:SetVisible(false)
        end
    end
end

--==================================================
-- ADD / UPDATE FILTER CONFIRMATION
-- The main button only builds a pending filter.
-- The dialog confirm button is the only place that saves.
--==================================================

local function FormatSniperConfirmPrice(value)

    if value == math.huge then
        return "No limit"
    end

    local number =
        tonumber(value)

    if not number then
        return "0 tokens"
    end

    number =
        math.floor(number)

    local formatted =
        tostring(number)

    while true do

        local nextFormatted, changed =
            formatted:gsub(
                "^(-?%d+)(%d%d%d)",
                "%1,%2"
            )

        formatted =
            nextFormatted

        if changed <= 0 then
            break
        end
    end

    return formatted .. " tokens"
end

local function FormatSniperConfirmWeight(value, weightMode)

    value =
        tonumber(value)
        or 0

    if value <= 0 then
        return "No minimum"
    end

    weightMode =
        NormalizeWeightMode(weightMode)

    if weightMode == "BaseWeight" then
        return tostring(value) .. " BaseWeight"
    end

    return tostring(value) .. " KG"
end

local function FormatSniperConfirmMutation(filter)

    if type(filter) ~= "table" then
        return "Off — buys normal and mutated pets"
    end

    local mutationText =
        type(FormatSniperMutationFilter) == "function"
        and FormatSniperMutationFilter(filter)
        or tostring(filter.Mutation or "Off")

    if mutationText == "Off" then
        return "Off — buys normal and mutated pets"
    end

    if mutationText == "Mutated" then
        return "Mutated Only — skips normal pets"
    end

    return mutationText
end

local function ClonePendingSniperFilter(filter)

    local output = {}

    if type(filter) ~= "table" then
        return output
    end

    output.MinWeight =
        filter.MinWeight

    output.MaxPrice =
        filter.MaxPrice

    output.WeightMode =
        filter.WeightMode

    output.Priority =
        filter.Priority

    output.Mutation =
        filter.Mutation

    if type(CloneSniperMutationMap) == "function" then

        output.SpecificMutations =
            CloneSniperMutationMap(
                filter.SpecificMutations
            )

        output.ExcludedMutations =
            CloneSniperMutationMap(
                filter.ExcludedMutations
            )
    else

        output.SpecificMutations =
            filter.SpecificMutations

        output.ExcludedMutations =
            filter.ExcludedMutations
    end

    return output
end

local function ClonePendingSniperFilter(filter)

    local output = {}

    if type(filter) ~= "table" then
        return output
    end

    output.MinWeight =
        filter.MinWeight

    output.MaxPrice =
        filter.MaxPrice

    output.WeightMode =
        filter.WeightMode

    output.Priority =
        filter.Priority

    output.Mutation =
        filter.Mutation

    if type(CloneSniperMutationMap) == "function" then

        output.SpecificMutations =
            CloneSniperMutationMap(
                filter.SpecificMutations
            )

        output.ExcludedMutations =
            CloneSniperMutationMap(
                filter.ExcludedMutations
            )
    else

        output.SpecificMutations =
            filter.SpecificMutations

        output.ExcludedMutations =
            filter.ExcludedMutations
    end

    return output
end

local function SaveConfirmedSniperFilter(pending)

    if type(pending) ~= "table"
    or type(pending.Filter) ~= "table"
    or type(pending.Pets) ~= "table"
    or #pending.Pets <= 0 then
        return false
    end

    local filters =
        GetSniperFilterSet(
            pending.WatchlistId
        )

    local savedCount =
        0

    for _, pet in ipairs(pending.Pets) do

        pet =
            tostring(pet or "")

        if pet ~= "" then

            filters[pet] =
                ClonePendingSniperFilter(
                    pending.Filter
                )

            savedCount += 1
        end
    end

    if savedCount <= 0 then
        return false
    end

    SniperFilterUIState.ViewTarget =
        pending.WatchlistId

    WatchlistPage =
        1

    if IsTradeWorld()
    and type(RefreshWatchlist) == "function" then
        RefreshWatchlist()
    end

    MarkConfigDirty()

    SaveSniperFilters()

    print(
        "[Sniper] Filters confirmed:",
        tostring(savedCount),
        "Watchlist:",
        tostring(pending.WatchlistId),
        "WeightMode:",
        tostring(pending.Filter.WeightMode),
        "Priority:",
        tostring(pending.Filter.Priority),
        "Mutation:",
        FormatSniperConfirmMutation(pending.Filter)
    )

    HolyNotify(
        "Filters Saved",
        tostring(savedCount)
            .. " pet filter"
            .. (savedCount == 1 and "" or "s")
            .. " saved to Watchlist "
            .. tostring(pending.WatchlistId)
            .. ".",
        "plus",
        3
    )

    return true
end

local function GetSelectedSniperPetsFromDropdown(value)

    local output = {}
    local seen = {}

    local function AddPet(petName)

        petName =
            tostring(petName or "")
                :gsub("^%s+", "")
                :gsub("%s+$", "")

        if petName == "" then
            return
        end

        if seen[petName] then
            return
        end

        seen[petName] =
            true

        table.insert(
            output,
            petName
        )
    end

    if type(value) == "string" then

        AddPet(value)

    elseif type(value) == "table" then

        for key, selected in pairs(value) do

            if selected == true then

                AddPet(key)

            elseif type(selected) == "string" then

                AddPet(selected)
            end
        end
    end

    table.sort(output)

    return output
end

local function FormatSniperPetListForDialog(pets)

    if type(pets) ~= "table"
    or #pets <= 0 then
        return "None"
    end

    local lines = {}
    local maxShown = 10

    for index, pet in ipairs(pets) do

        if index > maxShown then
            break
        end

        table.insert(
            lines,
            "- " .. tostring(pet)
        )
    end

    if #pets > maxShown then

        table.insert(
            lines,
            "+ "
                .. tostring(#pets - maxShown)
                .. " more"
        )
    end

    return table.concat(lines, "\n")
end

local function BuildPendingSniperFilterFromUI()

    local pets =
        GetSelectedSniperPetsFromDropdown(
            PetDropdown.Value
        )

    if #pets <= 0 then

        HolyNotify(
            "No Pets Selected",
            "Choose one or more pets before adding sniper filters.",
            "triangle-alert",
            4
        )

        return nil
    end

    local saveTarget =
        NormalizeWatchlistId(
            SniperFilterUIState.SaveTarget
        )

    local filters =
        GetSniperFilterSet(saveTarget)

    local minWeight =
        tonumber(MinWeightInput.Value)
        or 0

    local maxPrice

    if MaxPriceInput.Value == "" then

        maxPrice =
            math.huge

    else

        maxPrice =
            tonumber(MaxPriceInput.Value)

        if not maxPrice then

            HolyNotify(
                "Invalid Max Price",
                "Max Price must be empty or a valid number.",
                "triangle-alert",
                4
            )

            return nil
        end
    end

    local weightMode =
        NormalizeWeightMode(
            SniperFilterUIState.WeightMode
        )

    local priority =
        ClampSniperPriority(
            PriorityInput.Value
            or SniperFilterUIState.Priority
            or 5
        )

local mutationMode =
    type(NormalizeSniperFilterMutation) == "function"
    and NormalizeSniperFilterMutation(
        SniperFilterUIState.SelectedMutation
    )
    or "Off"

local selectedMutationMap =
    {}

if type(CloneSniperMutationMap) == "function" then

    selectedMutationMap =
        CloneSniperMutationMap(
            SniperFilterUIState.SelectedMutationSelection
        )
end

if mutationMode == "Specific Mutations"
and type(SniperMutationMapIsEmpty) == "function"
and SniperMutationMapIsEmpty(
    selectedMutationMap
) then

    HolyNotify(
        "No Mutations Selected",
        "Select at least one mutation, or turn Mutation Filter Off.",
        "triangle-alert",
        4
    )

    return nil
end

    local filter = {
        MinWeight =
            minWeight,

        MaxPrice =
            maxPrice,

        WeightMode =
            weightMode,

        Priority =
            priority,
    }

if type(CloneSniperMutationMap) == "function" then

    filter.Mutation =
        mutationMode

    if mutationMode == "Specific Mutations" then

        filter.SpecificMutations =
            CloneSniperMutationMap(
                selectedMutationMap
            )

        filter.ExcludedMutations =
            {}

    elseif mutationMode == "Exclude Mutations" then

        filter.SpecificMutations =
            {}

        filter.ExcludedMutations =
            CloneSniperMutationMap(
                selectedMutationMap
            )

    else

        filter.SpecificMutations =
            {}

        filter.ExcludedMutations =
            {}
    end
end

    local addCount =
        0

    local updateCount =
        0

    for _, pet in ipairs(pets) do

        if filters[pet] ~= nil then
            updateCount += 1
        else
            addCount += 1
        end
    end

    return {
        Pets =
            pets,

        -- Compatibility fallback for old prints/debug paths.
        Pet =
            pets[1],

        WatchlistId =
            saveTarget,

        Filter =
            filter,

        AddCount =
            addCount,

        UpdateCount =
            updateCount,

        IsUpdate =
            updateCount > 0
            and addCount <= 0,
    }
end

local function OpenSniperFilterConfirmDialog(pending)

    if type(pending) ~= "table"
    or type(pending.Filter) ~= "table"
    or type(pending.Pets) ~= "table"
    or #pending.Pets <= 0 then
        return
    end

    local totalPets =
        #pending.Pets

    local actionText

    if pending.AddCount > 0
    and pending.UpdateCount > 0 then

        actionText =
            "Save"

    elseif pending.UpdateCount > 0 then

        actionText =
            "Update"

    else

        actionText =
            "Add"
    end

    local summaryText =
        "Adds: "
        .. tostring(pending.AddCount or 0)
        .. " | Updates: "
        .. tostring(pending.UpdateCount or 0)

    local description =
        "Review these sniper filters before saving.\n\n"
        .. "Pets ("
        .. tostring(totalPets)
        .. "):\n"
        .. FormatSniperPetListForDialog(pending.Pets)
        .. "\n\n"
        .. "Watchlist: Watchlist "
        .. tostring(pending.WatchlistId)
        .. "\n"
        .. summaryText
        .. "\n"
        .. "Max Price: "
        .. FormatSniperConfirmPrice(pending.Filter.MaxPrice)
        .. "\n"
        .. "Min Weight: "
        .. FormatSniperConfirmWeight(
            pending.Filter.MinWeight,
            pending.Filter.WeightMode
        )
        .. "\n"
        .. "Weight Mode: "
        .. tostring(
            pending.Filter.WeightMode == "BaseWeight"
            and "Base Weight"
            or "Display KG"
        )
        .. "\n"
        .. "Priority: "
        .. tostring(
            ClampSniperPriority(
                pending.Filter.Priority
            )
        )
        .. "\n"
        .. "Mutation Filter: "
        .. FormatSniperConfirmMutation(pending.Filter)

    local ConfirmDialog = nil

    ConfirmDialog =
        Window:AddDialog(
            "SniperFilterConfirmDialog",
            {
                Title =
                    actionText .. " Sniper Filters",

                Description =
                    description,

                Icon =
                    actionText == "Update"
                    and "refresh-cw"
                    or "plus",

                AutoDismiss =
                    true,

                OutsideClickDismiss =
                    true,

                FooterButtons = {
                    Cancel = {
                        Title =
                            "Cancel",

                        Variant =
                            "Ghost",

                        Order =
                            1,

                        Callback = function()

                            if ConfirmDialog then
                                ConfirmDialog:Dismiss()
                            end
                        end,
                    },

                    Confirm = {
                        Title =
                            actionText .. " Filters",

                        Variant =
                            "Primary",

                        Order =
                            2,

                        Callback = function()

                            SaveConfirmedSniperFilter(
                                pending
                            )

                            if ConfirmDialog then
                                ConfirmDialog:Dismiss()
                            end
                        end,
                    },
                },
            }
        )
end

SniperFilterBox:AddButton({
    Text =
        "Add / Update Filters",

    Tooltip =
        "Review selected pet filters before saving them.",

    Func = function()

        local pending =
            BuildPendingSniperFilterFromUI()

        if not pending then
            return
        end

        OpenSniperFilterConfirmDialog(
            pending
        )
    end,
})

end
--==================================================
-- WEBHOOK TAB → CONFIGURATION (UI ONLY)
--==================================================
local WebhookBox

if type(Tabs.Webhook.AddLeftCollapsibleGroupbox) == "function" then

    WebhookBox =
        Tabs.Webhook:AddLeftCollapsibleGroupbox(
            "Webhook Configuration",
            "link",
            true
        )

else

    warn("[LIB TEST] Collapsible webhook unavailable, using normal groupbox")

    WebhookBox =
        Tabs.Webhook:AddLeftGroupbox(
            "Webhook Configuration",
            "link"
        )
end


--==================================================
-- WEBHOOK REQUEST RESOLUTION
--==================================================

RequestFunction =
    syn and syn.request
    or http_request
    or request
    or (http and http.request)
    or (fluxus and fluxus.request)
print("[WEBHOOK] RequestFunction:", RequestFunction)

function CanSendWebhook()

    if not WebhookState.Enabled then
        warn("[Webhook] Disabled")
        return false
    end

    if type(WebhookState.URL) ~= "string"
    or WebhookState.URL == "" then
        warn("[Webhook] Missing URL")
        return false
    end

    if not RequestFunction then
        warn("[Webhook] No request function available")
        return false
    end

    return true
end

--==================================================
-- WEBHOOK QUEUE
--==================================================
ApplyWebhookPing = function(payload, pingText)

    pingText =
        tostring(pingText or "")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    if pingText == "" then
        print("[WebhookPing] No ping")
        return payload
    end

    local allowedMentions = {}

    if pingText:lower() == "@everyone" then

        payload.content = "@everyone"

        allowedMentions.parse = {
            "everyone"
        }

    elseif pingText:lower() == "@here" then

        payload.content = "@here"

        allowedMentions.parse = {
            "everyone"
        }

    else

        local userId =
            pingText:match("<@!?(%d+)>")
            or pingText:match("@?(%d+)")

        if not userId then
            warn("[WebhookPing] Invalid ping:", pingText)
            return payload
        end

        payload.content =
            "<@" .. tostring(userId) .. ">"

        allowedMentions.users = {
            tostring(userId)
        }
    end

    payload.allowed_mentions =
        allowedMentions

    print(
        "[WebhookPing] Applied:",
        tostring(payload.content)
    )

    return payload
end

QueueWebhook = function(payload)

    if type(payload) ~= "table" then
        warn("[Webhook] Invalid payload")
        return false
    end

    if not CanSendWebhook() then
        return false
    end

    table.insert(
        WebhookState.Queue,
        payload
    )

    print(
        "[Webhook] Queued | Queue:",
        tostring(#WebhookState.Queue)
    )

    return true
end

--==================================================
-- WEBHOOK EMBED SEND
--==================================================

function SendWebhook(payload)

    local body =
        HttpService:JSONEncode(payload)

    local ok, response = pcall(function()

        return RequestFunction({

            Url =
                tostring(WebhookState.URL)
                    :gsub("%s+", ""),

            Method = "POST",

            Headers = {
                ["Content-Type"] = "application/json"
            },

            Body = body
        })

    end)

    if not ok then
        warn("[WEBHOOK] REQUEST FAILED:", response)
        return
    end

    if type(response) == "table" then

        local statusCode =
            tonumber(
                response.StatusCode
                or response.status_code
                or response.Status
            )

        if statusCode == 200
        or statusCode == 204 then
            print("[WEBHOOK] Sent successfully:", tostring(statusCode))
            return
        end

        warn(
            "[WEBHOOK] BAD STATUS:",
            tostring(statusCode),
            tostring(response.Body or response.body or "")
        )

        return
    end

    print("[WEBHOOK] Request completed")
end

--==================================================
-- WEBHOOK WORKER
--==================================================

task.spawn(function()

    while IsCurrentRun() do

        if #WebhookState.Queue <= 0 then
            task.wait(0.15)
            continue
        end

        if WebhookState.Sending then
            task.wait(0.05)
            continue
        end

        WebhookState.LastSend =
            SafeNumber(WebhookState.LastSend, 0)

        WebhookState.SendDelay =
            SafeNumber(WebhookState.SendDelay, 0.8)

        local elapsed =
            SafeElapsed(WebhookState.LastSend)

        if elapsed < WebhookState.SendDelay then

            task.wait(
                math.max(
                    0,
                    WebhookState.SendDelay - elapsed
                )
            )
        end

        WebhookState.Sending = true

        local payload =
            table.remove(
                WebhookState.Queue,
                1
            )

        WebhookState.LastSend =
            os.clock()

        task.spawn(function()

            pcall(function()

                SendWebhook(payload)

            end)

            WebhookState.Sending = false

        end)
    end
end)
--==================================================
-- WEBHOOK BUILDERS
--==================================================

CreateSuccessEmbed = function(listing, toolName, source)

    listing =
        listing or {}

    local sellerName =
        tostring(listing.Seller or "Unknown")

    if listing.SellerUserId then
        sellerName =
            ResolveSeller(listing.SellerUserId)
    end

    local snapshot =
        ParseConfirmedToolSnapshot(toolName)

    local confirmedPetName =
        snapshot
        and snapshot.CleanName
        or tostring(listing.PetName or "Unknown")

    local confirmedWeight =
        snapshot
        and snapshot.Weight
        or tonumber(listing.DisplayWeight)
        or tonumber(listing.Weight)

    local confirmedAge =
        snapshot
        and snapshot.Age
        or tonumber(listing.Age)
        or "Unknown"

    local mutationText =
        ResolveMutationFromConfirmedToolName(
            toolName,
            listing.PetName
        )

    if mutationText == "Normal"
    or mutationText == "Unknown"
    or mutationText == "" then

        mutationText =
            tostring(
                listing.MutationText
                or listing.Mutation
                or "Normal"
            )
    end

local title =
    string.format(
        "⚡ SNIPED • %s [Age %s] [%s]",
        tostring(confirmedPetName),
        tostring(confirmedAge or "Unknown"),
        FormatWebhookWeightKG(confirmedWeight)
    )

    return {
        embeds = {{

            title = title,

            description =
                "Sniped By: ||"
                .. tostring(Players.LocalPlayer.Name)
                .. "||",

            color = 0xFF4FD8,

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
                        tostring(mutationText or "Unknown"),
                    inline = true,
                },

                {
                    name = "⚖️ BaseWeight",
                    value =
                        FormatWebhookBaseWeight(
                            listing.BaseWeight
                        ),
                    inline = true,
                },

                {
                    name = "👤 Seller",
                    value =
                        tostring(sellerName),
                    inline = true,
                },

                {
                    name = "🌍 Server",
                    value =
                        "```lua\n"
                        .. tostring(game.PlaceId)
                        .. ":"
                        .. tostring(game.JobId)
                        .. "\n```",
                    inline = false,
                },
            },

            footer = {
                text = "Holy V2"
            },

            timestamp =
                DateTime.now():ToIsoDate(),
        }}
    }
end

CreateBoothSaleEmbed = function(sale)

    sale =
        sale or {}

    local toolTitle =
        tostring(
            ResolveBoothSaleWebhookTitle(sale)
            or "Unknown"
        )

    return {
        embeds = {{

            title = toolTitle,

            description =
                string.format(
                    "By User: ||%s||",
                    Players.LocalPlayer.Name
                ),

            color = 0xF59E0B,

            fields = {

                {
                    name = "💰 Sold For",
                    value = string.format(
                        "%s Tokens",
                        tostring(
                            sale.NetPrice
                            or sale.Price
                            or 0
                        )
                    ),
                    inline = false,
                },

                {
                    name = "Age",
                    value =
                        tostring(sale.Age or "Unknown"),
                    inline = true,
                },

                {
                    name = "Mutation",
                    value =
                        tostring(sale.MutationText or "Unknown"),
                    inline = true,
                },

                {
                    name = "BaseWeight",
                    value =
                        FormatWebhookBaseWeight(
                            sale.BaseWeight
                        ),
                    inline = true,
                },

                {
                    name = "✨ Token Balance",
                    value = string.format(
                        "%s Tokens",
                        tostring(GetTokenBalance())
                    ),
                    inline = false,
                },

                {
                    name = "Server",
                    value =
                        "```lua\n"
                        .. tostring(game.PlaceId)
                        .. ":"
                        .. tostring(game.JobId)
                        .. "\n```",
                    inline = false,
                },
            },

            footer = {
                text = "Holy V2"
            },

            timestamp =
                DateTime.now():ToIsoDate(),
        }}
    }
end
function CreateErrorEmbed(message)

    return {
        embeds = {{
            title = "Runtime Error",

            description = tostring(message),

            color = 0xEF4444,

            fields = {

                {
                    name = "PlaceId",
                    value = tostring(game.PlaceId),
                    inline = true,
                },

                {
                    name = "JobId",
                    value = tostring(game.JobId),
                    inline = false,
                },
            },

            footer = {
                text = "Holy V2"
            },

            timestamp = DateTime.now():ToIsoDate(),
        }}
    }
end

--==================================================
-- OWN BOOTH SALE TRACKER
-- Manual-unlist safe:
-- A missing listing is only treated as SOLD if token balance increases.
--
-- Multi-sale safe:
-- Multiple listings disappearing inside the same confirmation window
-- are confirmed from one shared token-gain budget.
--==================================================

OwnBoothTracker = {
    LastListings = {},
    PendingMissing = {},

    Initialized = false,

    -- Last observed token balance from the previous scan pass.
    LastTokenBalance = 0,

    -- Token balance checkpoint used for confirmed sale accounting.
    -- This is intentionally separate from LastTokenBalance so multiple
    -- simultaneous sales can be confirmed from the same token increase.
    SaleTokenCheckpoint = 0,

    ConfirmDelay = 1.75,
    MaxConfirmDelay = 12,

    ScanInterval = 0.35,

    -- Allows tiny UI/replication mismatch but still blocks manual unlisting.
    MinSaleRatio = 0.5,
}
--==================================================
-- TRADE BOOTH FEE RESOLVER
-- Source of truth for booth sale webhook payouts.
-- Uses the game's own TradeBoothsData.applyFee().
--==================================================

TradeBoothsData =
    TradeBoothsData
    or nil

if not TradeBoothsData then
    pcall(function()
        TradeBoothsData =
            require(
                ReplicatedStorage
                    :WaitForChild("Data")
                    :WaitForChild("TradeBoothsData")
            )
    end)
end

function ResolveBoothNetTokens(grossPrice)

    local price =
        tonumber(grossPrice)

    if not price
    or price <= 0 then
        return 0
    end

    if type(TradeBoothsData) == "table"
    and type(TradeBoothsData.applyFee) == "function" then

        local ok, result =
            pcall(function()
                return TradeBoothsData.applyFee(price)
            end)

        if ok
        and tonumber(result) then
            return math.max(
                1,
                math.floor(tonumber(result))
            )
        end
    end

    -- Fallback confirmed from your test:
    -- 1000 -> 990, so booth fee is 1%.
    return math.max(
        1,
        math.floor(price * 0.99)
    )
end

function BuildOwnListingSnapshot()

    local snapshot = {}

    local data = LatestBoothData

    if not data
    or not data.Booths
    or not data.Players then
        return snapshot
    end

    local localUserId =
        Players.LocalPlayer.UserId

    for boothId, boothData in pairs(data.Booths) do

        local owner =
            boothData.Owner

        if not owner then
            continue
        end

        local ownerId =
            tonumber(
                tostring(owner):match("_(%d+)$")
            )

        if ownerId ~= localUserId then
            continue
        end

        local playerData =
            data.Players[owner]

        if not playerData then
            continue
        end

        local listings =
            playerData.Listings

        local items =
            playerData.Items

        if type(listings) ~= "table"
        or type(items) ~= "table" then
            continue
        end

        for uid, listingData in pairs(listings) do

            if type(listingData) ~= "table" then
                continue
            end

            local item =
                items[listingData.ItemId]

            if not item then
                continue
            end

            local petData =
                item.PetData

            if not petData then
                continue
            end

local itemUUID =
    tostring(
        listingData.ItemId
        or uid
        or ""
    )

local rawPetName =
    tostring(item.PetType or "Unknown")

local listedMetadata =
    ResolveOwnListedMetadata(
        itemUUID
    )

local liveTool =
    ResolveInventoryPetToolByUUID(
        itemUUID
    )

local liveToolSnapshot =
    liveTool
    and ParseBoothSaleToolSnapshot(
        liveTool.Name
    )
    or nil

local storedToolSnapshot =
    type(listedMetadata) == "table"
    and ParseBoothSaleToolSnapshot(
        listedMetadata.ToolName
    )
    or nil

local bestToolSnapshot =
    liveToolSnapshot
    or storedToolSnapshot

local rawAge =
    ResolveRawPetDataAge(
        petData
    )
    or ResolveRawPetDataAgeFromUUID(
        itemUUID
    )

local age =
    bestToolSnapshot
    and bestToolSnapshot.Age
    or (
        type(listedMetadata) == "table"
        and tonumber(listedMetadata.Age)
    )
    or rawAge

local baseWeight =
    ResolveRawPetDataBaseWeight(
        petData
    )

local explicitDisplayWeight =
    ResolveRawPetDataExplicitDisplayWeightOnly(
        petData
    )

local displayWeight =
    bestToolSnapshot
    and bestToolSnapshot.Weight
    or (
        type(listedMetadata) == "table"
        and tonumber(listedMetadata.DisplayWeight)
    )
    or explicitDisplayWeight
    or baseWeight

local mutationText =
    ResolvePetMutationTextFromPetData(
        petData
    )

if mutationText == "Normal"
or mutationText == "Unknown"
or mutationText == "" then

    mutationText =
        ResolveOwnListedMetadataMutation(
            itemUUID
        )
        or ResolveRawPetDataMutationFromUUID(
            itemUUID,
            rawPetName
        )
        or mutationText
end

local finalName =
    rawPetName

if bestToolSnapshot
and bestToolSnapshot.CleanName
and bestToolSnapshot.CleanName ~= "" then

    finalName =
        bestToolSnapshot.CleanName

elseif mutationText ~= "Normal"
and mutationText ~= "Unknown"
and mutationText ~= "" then

    finalName =
        tostring(mutationText)
        .. " "
        .. rawPetName
end

local toolName =
    string.format(
        "%s [Age %s] [%s]",
        tostring(finalName),
        tostring(age or "Unknown"),
        FormatWebhookWeightKG(displayWeight)
    )

            local listingKey =
                tostring(boothId)
                .. "_"
                .. tostring(uid)

local grossPrice =
    tonumber(listingData.Price)
    or 0

local netPrice =
    ResolveBoothNetTokens(grossPrice)

snapshot[listingKey] = {
    UID = tostring(uid),
    ListingKey = listingKey,
    BoothId = tostring(boothId),

    PetName = rawPetName,
    DisplayName = finalName,
    ToolName = toolName,

    -- Raw pet metadata from booth data.
    MetadataSource = "RawPetData",

    RawPetData = petData,

    Age = age,
    MutationText = mutationText,
    BaseWeight = baseWeight,
    DisplayWeight = displayWeight,

    -- Legacy compatibility.
    Weight = displayWeight,

    -- Gross listing price shown in the booth input.
    GrossPrice = grossPrice,

    -- Net tokens actually received after booth tax.
    NetPrice = netPrice,

    -- Keep Price as net payout so existing webhook builders
    -- and sale confirmation logic display the correct received value.
    Price = netPrice,
}
        end
    end

    return snapshot
end

function ResolveRequiredSaleGain(listing)

    if not listing then
        return math.huge
    end

    local netPrice =
        tonumber(listing.NetPrice)
        or tonumber(listing.Price)
        or 0

    if netPrice <= 0 then
        return 1
    end

    return math.max(
        1,
        math.floor(
            netPrice * OwnBoothTracker.MinSaleRatio
        )
    )
end

function FireConfirmedBoothSale(oldListing)

    print(
        "[BOOTH SALE CONFIRMED]",
        tostring(oldListing.PetName),
        "| source:",
        tostring(oldListing.MetadataSource or "Unknown"),
        "| age:",
        tostring(oldListing.Age),
        "| displayKG:",
        tostring(oldListing.DisplayWeight or oldListing.Weight),
        "| baseWeight:",
        tostring(oldListing.BaseWeight)
    )

    QueueGlobalBoothSaleWebhook(oldListing)

    if WebhookState.Enabled
    and WebhookState.NotifyBoothSales then

        QueueWebhook(
            ApplyWebhookPing(
                CreateBoothSaleEmbed(oldListing),
                WebhookState.PingBoothSales
            )
        )

        print("[WEBHOOK] Booth sale queued")
    end
end

task.spawn(function()

    while IsCurrentRun() do
        task.wait(OwnBoothTracker.ScanInterval)

        if game.PlaceId ~= TRADING_WORLD_PLACE_ID then
            continue
        end

        local current =
            BuildOwnListingSnapshot()

        local now =
            os.clock()

        local tokenBalance =
            GetTokenBalance()

        -- First pass only initializes state.
        -- This prevents startup / teleport / booth-load false sales.
        if not OwnBoothTracker.Initialized then

            OwnBoothTracker.LastListings =
                current

            OwnBoothTracker.LastTokenBalance =
                tokenBalance

            OwnBoothTracker.SaleTokenCheckpoint =
                tokenBalance

            OwnBoothTracker.Initialized =
                true

            continue
        end

        local previous =
            OwnBoothTracker.LastListings

        --==================================================
        -- MARK MISSING LISTINGS AS PENDING
        -- Do NOT instantly call them sales.
        --==================================================

        for listingKey, oldListing in pairs(previous) do

            listingKey =
                tostring(listingKey)

            if not current[listingKey]
            and not OwnBoothTracker.PendingMissing[listingKey] then

                OwnBoothTracker.PendingMissing[listingKey] = {
                    Listing = oldListing,
                    MissingAt = now,

                    -- Keep the original removal-time balance for diagnostics.
                    TokenBefore = OwnBoothTracker.LastTokenBalance,
                }

                print(
                    "[BOOTH LISTING REMOVED/PENDING]",
                    oldListing.PetName
                )
            end
        end

        --==================================================
        -- REMOVE RETURNED LISTINGS FROM PENDING
        -- Listing came back, so it was not sold.
        --==================================================

        for listingKey in pairs(OwnBoothTracker.PendingMissing) do

            listingKey =
                tostring(listingKey)

            if current[listingKey] then
                OwnBoothTracker.PendingMissing[listingKey] = nil
            end
        end

        --==================================================
        -- BUILD CONFIRMATION BATCH
        -- Multiple sales can share the same token increase.
        --==================================================

        local confirmBatch = {}

        for listingKey, pending in pairs(OwnBoothTracker.PendingMissing) do

            local elapsed =
                now - pending.MissingAt

            if elapsed >= OwnBoothTracker.ConfirmDelay then

                table.insert(confirmBatch, {
                    ListingKey = tostring(listingKey),
                    Pending = pending,
                    Elapsed = elapsed,
                })
            end
        end

        table.sort(confirmBatch, function(a, b)

            local aTime =
                a.Pending
                and a.Pending.MissingAt
                or 0

            local bTime =
                b.Pending
                and b.Pending.MissingAt
                or 0

            if aTime ~= bTime then
                return aTime < bTime
            end

            return tostring(a.ListingKey) < tostring(b.ListingKey)
        end)

        --==================================================
        -- TOKEN-GAIN BUDGET
        -- This is what fixes same-server / same-time multi-sales.
        -- Example:
        -- 2 Mimics sold at 180 each = +360 token gain.
        -- The tracker confirms both and consumes 180 + 180.
        --==================================================

        local tokenGainBudget =
            tokenBalance
            - (
                tonumber(OwnBoothTracker.SaleTokenCheckpoint)
                or tokenBalance
            )

        local consumedBudget = 0
        local confirmedCount = 0

        if tokenGainBudget > 0
        and #confirmBatch > 0 then

            for _, entry in ipairs(confirmBatch) do

                local listingKey =
                    entry.ListingKey

                local pending =
                    entry.Pending

                local oldListing =
                    pending
                    and pending.Listing

                if not oldListing then
                    OwnBoothTracker.PendingMissing[listingKey] = nil
                    continue
                end

                local requiredGain =
                    ResolveRequiredSaleGain(oldListing)

                local availableBudget =
                    tokenGainBudget - consumedBudget

                if availableBudget >= requiredGain then

                    FireConfirmedBoothSale(oldListing)

                    consumedBudget =
                    consumedBudget + requiredGain
                    confirmedCount =
                    confirmedCount + 1

                    OwnBoothTracker.PendingMissing[listingKey] = nil
                end
            end
        end

        -- Advance sale checkpoint only by budget we actually consumed.
        -- Do not jump it to tokenBalance blindly, or later pending removals
        -- can lose their token evidence.
        if consumedBudget > 0 then
            OwnBoothTracker.SaleTokenCheckpoint =
                OwnBoothTracker.SaleTokenCheckpoint + consumedBudget
        end

        -- If tokens dropped or reset, resync safely.
        if tokenBalance < OwnBoothTracker.SaleTokenCheckpoint then
            OwnBoothTracker.SaleTokenCheckpoint = tokenBalance
        end

        --==================================================
        -- DISCARD EXPIRED NON-SALES
        -- Manual unlisting reaches this path.
        --==================================================

        for listingKey, pending in pairs(OwnBoothTracker.PendingMissing) do

            local elapsed =
                now - pending.MissingAt

            if elapsed >= OwnBoothTracker.MaxConfirmDelay then

                local oldListing =
                    pending.Listing

                print(
                    "[BOOTH REMOVE IGNORED]",
                    oldListing
                    and oldListing.PetName
                    or tostring(listingKey)
                )

                OwnBoothTracker.PendingMissing[listingKey] = nil
            end
        end

        -- If there are no unresolved pending removals, keep checkpoint aligned.
        -- This prevents stale token gain from confirming future manual removals.
        local hasPending = false

        for _ in pairs(OwnBoothTracker.PendingMissing) do
            hasPending = true
            break
        end

        if not hasPending then
            OwnBoothTracker.SaleTokenCheckpoint =
                tokenBalance
        end

        OwnBoothTracker.LastListings =
            current

        OwnBoothTracker.LastTokenBalance =
            tokenBalance

        if confirmedCount > 1 then
            print(
                "[BOOTH MULTI-SALE CONFIRMED]",
                tostring(confirmedCount)
            )
        end
    end
end)

--==================================================
-- LISTINGS TAB
--==================================================

function BuildListingsTab()

    --==================================================
    -- LISTINGS UI: CLEAN TABBOX LAYOUT
    -- Left: Setup / Safety / Actions
    -- Right: Status / Preview / History
    --==================================================

    local ListingSetupBox
    local ListingSafetyBox
    local ListingActionsBox

    local ListingStatusBox
    local ListingPreviewBox
    local ListingFiltersBox
    local ListingHistoryBox
    local ListingBoothBox

    --==================================================
    -- LEFT SIDE
    --==================================================

    if type(Tabs.Listings.AddLeftTabbox) == "function" then

        local LeftTabbox =
            Tabs.Listings:AddLeftTabbox("Listing Engine")

        ListingSetupBox =
            LeftTabbox:AddTab(
                "Setup",
                "sliders-horizontal"
            )

        ListingSafetyBox =
            LeftTabbox:AddTab(
                "Safety",
                "shield-check"
            )

        ListingActionsBox =
            LeftTabbox:AddTab(
                "Actions",
                "zap"
            )

    else

        warn("[LISTINGS UI] Tabbox unavailable, using groupboxes")

        ListingSetupBox =
            Tabs.Listings:AddLeftGroupbox(
                "Setup",
                "sliders-horizontal"
            )

        ListingSafetyBox =
            Tabs.Listings:AddLeftGroupbox(
                "Safety",
                "shield-check"
            )

        ListingActionsBox =
            Tabs.Listings:AddLeftGroupbox(
                "Actions",
                "zap"
            )
    end

    --==================================================
    -- RIGHT SIDE
    --==================================================

    if type(Tabs.Listings.AddRightTabbox) == "function" then

        local RightTabbox =
            Tabs.Listings:AddRightTabbox("Listing Data")

        ListingStatusBox =
            RightTabbox:AddTab(
                "Status",
                "activity"
            )

        ListingPreviewBox =
            RightTabbox:AddTab(
                "Preview",
                "search"
            )

        ListingFiltersBox =
            RightTabbox:AddTab(
                "Filters",
                "list-filter"
            )

        ListingHistoryBox =
            RightTabbox:AddTab(
                "History",
                "history"
            )

    else

        warn("[LISTINGS UI] Right tabbox unavailable, using groupboxes")

        ListingStatusBox =
            Tabs.Listings:AddRightGroupbox(
                "Status",
                "activity"
            )

        ListingPreviewBox =
            Tabs.Listings:AddRightGroupbox(
                "Preview",
                "search"
            )

        ListingFiltersBox =
            Tabs.Listings:AddRightGroupbox(
                "Filters",
                "list-filter"
            )

        ListingHistoryBox =
            Tabs.Listings:AddRightGroupbox(
                "History",
                "history"
            )
    end

    --==================================================
    -- RIGHT SIDE BOTTOM
    -- Always-visible booth listings panel.
    -- This is intentionally outside the Status/Preview/
    -- Filters/History tabbox so users can always see it.
    --==================================================

    if type(Tabs.Listings.AddRightCollapsibleGroupbox) == "function" then

        ListingBoothBox =
            Tabs.Listings:AddRightCollapsibleGroupbox(
                "Listed In Booth",
                "package",
                true
            )

    else

        ListingBoothBox =
            Tabs.Listings:AddRightGroupbox(
                "Listed In Booth",
                "package"
            )
    end
    --==================================================
    -- SETUP TAB
    --==================================================

    ListingSetupBox:AddLabel(
    "⚠️ Review Preview before adding.",
    false
)

ListingSetupBox:AddLabel(
    "Saved filters WILL auto-list matching pets.",
    true
)

RefreshDynamicPetList()
RefreshListingMutationList()

local ListingMutationModeList =
    {}

local seenListingMutationMode =
    {}

local function AddListingMutationMode(value)

    value =
        tostring(value or "")

    if value == "" then
        return
    end

    if seenListingMutationMode[value] then
        return
    end

    seenListingMutationMode[value] =
        true

    table.insert(
        ListingMutationModeList,
        value
    )
end

AddListingMutationMode("---")
AddListingMutationMode("All")
AddListingMutationMode("All Except")

for _, mutationName in ipairs(ListingMutationList or {}) do
    AddListingMutationMode(mutationName)
end

        local ListingPetDropdown =
        ListingSetupBox:AddDropdown(
            "ListingPetSelect",
            {
                Text = "Pet",
                Values = PetList,
                Default = "",
                Searchable = true,
            }
        )

    ListingPetDropdown:OnChanged(function(value)

        ListingsState.SelectedPet =
            tostring(value or "")

        ListingsState.NoWorkSleepUntil =
            0

        BuildListingPreview()
        MarkConfigDirty()
        ListingsStatusRefresh()

        print(
            "[LISTINGS] Selected pet:",
            ListingsState.SelectedPet
        )
    end)

    local ListingMutationDropdown =
    ListingSetupBox:AddDropdown(
        "ListingMutationSelect",
        {
            Text = "Mutation",
            Values = ListingMutationModeList,
            Default = "---",
            Searchable = true,
        }
    )

ListingMutationDropdown:OnChanged(function(value)

    ListingsState.SelectedMutation =
        NormalizeListingFilterMutation(
            value
        )

    ListingsState.NoWorkSleepUntil =
        0

    BuildListingPreview()
    MarkConfigDirty()
    ListingsStatusRefresh()

    print(
        "[LISTINGS] Selected mutation:",
        ListingsState.SelectedMutation
    )
end)

local ListingExcludeMutationsDropdown =
    ListingSetupBox:AddDropdown(
        "ListingExcludeMutations",
        {
            Text = "Exclude Mutations",
            Tooltip = "Only used when Mutation is set to All Except.",
            Values = ListingMutationList,
            Default = {},
            Searchable = true,
            Multi = true,
        }
    )

ListingExcludeMutationsDropdown:OnChanged(function(value)

    ListingsState.SelectedExcludedMutations =
        BuildListingMutationMapFromDropdownValue(
            value
        )

    ListingsState.NoWorkSleepUntil =
        0

    BuildListingPreview()
    MarkConfigDirty()
    ListingsStatusRefresh()

    print(
        "[LISTINGS] Excluded mutations:",
        FormatExcludedListingMutations(
            ListingsState.SelectedExcludedMutations
        )
    )
end)

local function FormatListingSetupValue(value, fallback)

    if value == nil then
        return tostring(fallback or "-")
    end

    local number =
        tonumber(value)

    if not number then
        return tostring(value)
    end

    if number % 1 == 0 then
        return tostring(math.floor(number))
    end

    return tostring(number)
end

local function RefreshListingSetupInputLabels()

    if ListingMinLevelInput then
        ListingMinLevelInput:SetText(
            "Min Level  "
            .. FormatListingSetupValue(
                ListingsState.MinLevel,
                1
            )
        )
    end

    if ListingMaxLevelInput then
        ListingMaxLevelInput:SetText(
            "Max Level  "
            .. FormatListingSetupValue(
                ListingsState.MaxLevel,
                100
            )
        )
    end

    if ListingMinWeightInput then
        ListingMinWeightInput:SetText(
            "Min BaseWeight  "
            .. FormatListingSetupValue(
                ListingsState.MinWeight,
                "-"
            )
        )
    end

    if ListingMaxWeightInput then
        ListingMaxWeightInput:SetText(
            "Max BaseWeight  "
            .. FormatListingSetupValue(
                ListingsState.MaxWeight,
                "-"
            )
        )
    end

    if ListingPriceInput then
        ListingPriceInput:SetText(
            "🟢 Tokens  "
            .. FormatListingSetupValue(
                ListingsState.Price,
                "-"
            )
        )
    end
end

    ListingMinLevelInput =
    ListingSetupBox:AddInput(
        "ListingMinLevel",
        {
            Text = "Min Level",
            Placeholder = "1",
            Default = tostring(ListingsState.MinLevel or 1),
            Numeric = false,
            Finished = false,
        }
    )

ListingMinLevelInput:OnChanged(function(value)

    local text =
        tostring(value or "")
            :gsub(",", "")
            :gsub("%s+", "")

    local num =
        tonumber(text)

    if not num
    or num < 1 then
        num = 1
    end

    ListingsState.MinLevel =
        math.clamp(
            math.floor(num),
            1,
            999
        )

    ListingsState.NoWorkSleepUntil =
        0

    BuildListingPreview()
MarkConfigDirty()
ListingsStatusRefresh()
RefreshListingSetupInputLabels()

        print(
        "[LISTINGS] Min Level:",
        tostring(ListingsState.MinLevel)
    )
end)

ListingMaxLevelInput =
    ListingSetupBox:AddInput(
        "ListingMaxLevel",
        {
            Text = "Max Level",
            Placeholder = "100",
            Default = tostring(ListingsState.MaxLevel or 100),
            Numeric = false,
            Finished = false,
        }
    )

ListingMaxLevelInput:OnChanged(function(value)

    local text =
        tostring(value or "")
            :gsub(",", "")
            :gsub("%s+", "")

    local num =
        tonumber(text)

    if not num
    or num < 1 then
        num = 100
    end

    ListingsState.MaxLevel =
        math.clamp(
            math.floor(num),
            1,
            999
        )

    ListingsState.NoWorkSleepUntil =
        0

    BuildListingPreview()
    MarkConfigDirty()
    ListingsStatusRefresh()
    RefreshListingSetupInputLabels()

    print(
        "[LISTINGS] Max Level:",
        tostring(ListingsState.MaxLevel)
    )
end)

    ListingMinWeightInput =
    ListingSetupBox:AddInput(
            "ListingMinWeight",
            {
                Text = "Min BaseWeight",
                Placeholder = "required",
                Default = "",
                Numeric = true,
                Finished = false,
            }
        )

    ListingMinWeightInput:OnChanged(function(value)

        local text =
            tostring(value or "")
                :gsub(",", "")
                :gsub("%s+", "")

        local num =
            tonumber(text)

        if not num
        or num < 0 then

            ListingsState.MinWeight =
                nil

            ListingsState.MinWeightWasEntered =
                false

            ListingsState.NoWorkSleepUntil =
                0

            BuildListingPreview()
            MarkConfigDirty()
            ListingsStatusRefresh()
            RefreshListingSetupInputLabels()

            return
        end

        ListingsState.MinWeight =
            num

        ListingsState.MinWeightWasEntered =
            true

        ListingsState.NoWorkSleepUntil =
            0

        BuildListingPreview()
        MarkConfigDirty()
        ListingsStatusRefresh()
        RefreshListingSetupInputLabels()

        print(
            "[LISTINGS] Min BaseWeight:",
            tostring(ListingsState.MinWeight)
        )
    end)

    ListingMaxWeightInput =
    ListingSetupBox:AddInput(
            "ListingMaxWeight",
            {
                Text = "Max BaseWeight",
                Placeholder = "required",
                Default = "",
                Numeric = true,
                Finished = false,
            }
        )

    ListingMaxWeightInput:OnChanged(function(value)

        local text =
            tostring(value or "")
                :gsub(",", "")
                :gsub("%s+", "")

        local num =
            tonumber(text)

        if not num
        or num < 0 then

            ListingsState.MaxWeight =
                nil

            ListingsState.MaxWeightWasEntered =
                false

            ListingsState.NoWorkSleepUntil =
                0

            BuildListingPreview()
            MarkConfigDirty()
            ListingsStatusRefresh()
            RefreshListingSetupInputLabels()
            return
        end

        ListingsState.MaxWeight =
            num

        ListingsState.MaxWeightWasEntered =
            true

        ListingsState.NoWorkSleepUntil =
            0

        BuildListingPreview()
        MarkConfigDirty()
        ListingsStatusRefresh()
        RefreshListingSetupInputLabels()

        print(
            "[LISTINGS] Max BaseWeight:",
            tostring(ListingsState.MaxWeight)
        )
    end)

    ListingPriceInput =
    ListingSetupBox:AddInput(
            "ListingPrice",
            {
                Text = "🟢 Tokens",
                Placeholder = "required",
                Default = "",
                Numeric = true,
                Finished = false,
            }
        )

    ListingPriceInput:OnChanged(function(value)

        local text =
            tostring(value or "")
                :gsub(",", "")
                :gsub("%s+", "")

        local num =
            tonumber(text)

        if not num
        or num <= 0 then

            ListingsState.Price =
    nil

ListingsState.PriceWasEntered =
    false

ListingsState.NoWorkSleepUntil =
    0

BuildListingPreview()
MarkConfigDirty()
ListingsStatusRefresh()
RefreshListingSetupInputLabels()

return
        end

        ListingsState.Price =
    math.floor(num)

ListingsState.PriceWasEntered =
    true

ListingsState.NoWorkSleepUntil =
    0

BuildListingPreview()
MarkConfigDirty()
ListingsStatusRefresh()
RefreshListingSetupInputLabels()

print(
            "[LISTINGS] Price:",
            tostring(ListingsState.Price)
        )
    end)

    RefreshListingSetupInputLabels()

        ListingSetupBox:AddDivider({
        Text = "Filter Preset",
        MarginTop = 8,
        MarginBottom = 8,
    })

    local FilterButton =
        ListingSetupBox:AddButton({
            Text = "Filter",
            Tooltip = "Add the current setup as a reusable listing filter.",
            Func = function()

                AddCurrentListingFilter()
            end,
        })

    FilterButton:AddButton({
        Text = "Add",
        Tooltip = "Add current pet/mutation/weight/price as a filter.",
        Func = function()

            AddCurrentListingFilter()
        end,
    })

    FilterButton:AddButton({
        Text = "Clear",
        Tooltip = "Clear all listing filters.",
        Risky = true,
        DoubleClick = true,
        Func = function()

            ClearListingFilters()
        end,
    })
    --==================================================
    -- SAFETY TAB
    --==================================================

    ListingSafetyBox:AddLabel(
        "Safety rules before creating booth listings.",
        false
    )

    local AllowLowPriceToggle =
        ListingSafetyBox:AddToggle(
            "ListingAllowLowPrice",
            {
                Text = "⚠️ Allow Low Price",
                Tooltip = "Required before Holy can list pets below 100 tokens.",
                Default = false,
            }
        )

    AllowLowPriceToggle:OnChanged(function(value)

        ListingsState.AllowLowPriceListings =
            value == true

        MarkConfigDirty()
        ListingsStatusRefresh()

        print(
            "[LISTINGS] Allow low price:",
            tostring(ListingsState.AllowLowPriceListings)
        )
    end)

    local AutoUnfavToggle =
        ListingSafetyBox:AddToggle(
            "ListingAutoUnfavorite",
            {
                Text = "❤️ Auto Unfavorite",
                Default = false,
            }
        )

    AutoUnfavToggle:OnChanged(function(value)

        ListingsState.AutoUnfavorite =
            value == true

        MarkConfigDirty()

        print(
            "[LISTINGS] Auto Unfav:",
            tostring(ListingsState.AutoUnfavorite)
        )
    end)

local KeepRunningToggle =
    ListingSafetyBox:AddToggle(
        "ListingKeepRunning",
        {
            Text = "♾️ Keep Running",
            Tooltip = "ON = AutoList keeps watching. OFF = AutoList stops when all current matching pets are handled.",
            Default = false,
        }
    )

KeepRunningToggle:OnChanged(function(value)

    local keepRunning =
        value == true

    -- Keep Running ON  = never auto-disable when done.
    -- Keep Running OFF = old Stop When Done behavior.
    ListingsState.AutoDisableWhenDone =
        not keepRunning

    ListingsState.NoWorkSleepUntil =
        0

    MarkConfigDirty()

    if type(ListingsStatusRefresh) == "function" then
        ListingsStatusRefresh()
    end

    print(
        "[LISTINGS] Keep Running:",
        tostring(keepRunning),
        "| AutoDisableWhenDone:",
        tostring(ListingsState.AutoDisableWhenDone)
    )
end)

    --==================================================
    -- ACTIONS TAB
    --==================================================

    ListingActionsBox:AddLabel(
        "Runtime controls for the listing worker.",
        false
    )
        local ListingSpeedDropdown =
        ListingActionsBox:AddDropdown(
            "ListingSpeedMode",
            {
                Text = "⚡ Listing Speed",
                Tooltip = "Controls AutoList scan and CreateListing cooldown.",
                Values = {
                "Adaptive",
                "Safe",
                "Balanced",
                "Fast",
                "Aggressive",
                },
                Default = ListingsState.ListingSpeedMode or "Adaptive",
                Searchable = false,
            }
        )

    ListingSpeedDropdown:OnChanged(function(value)

        local config =
            SetListingSpeedMode(value)

        ListingsState.NoWorkSleepUntil =
            0

        MarkConfigDirty()

        if ConfigState.IsHydrating then
            return
        end

        HolyNotify(
            "Listing Speed Updated",
            tostring(ListingsState.ListingSpeedMode)
                .. " • cooldown "
                .. tostring(ResolveListingCreateCooldown())
                .. "s",
            "zap",
            3
        )

        if type(ListingsStatusRefresh) == "function" then
            ListingsStatusRefresh()
        end
    end)

    local MaxQueueInput =
        ListingActionsBox:AddInput(
            "ListingMaxQueuePerPass",
            {
                Text = "Max Queue / Pass",
                Default = tostring(ListingsState.MaxQueuePerPass or 2),
                Numeric = true,
                Finished = false,
            }
        )

    MaxQueueInput:OnChanged(function(value)

        local num =
            tonumber(value)

        if not num then
            return
        end

        ListingsState.MaxQueuePerPass =
            math.clamp(
                math.floor(num),
                1,
                10
            )

        ListingsState.NoWorkSleepUntil =
            0

        MarkConfigDirty()

        if type(ListingsStatusRefresh) == "function" then
            ListingsStatusRefresh()
        end
    end)

    ListingActionsBox:AddDivider({
        Text = "Runtime",
        MarginTop = 8,
        MarginBottom = 8,
    })

    local AutoListToggle =
        ListingActionsBox:AddToggle(
            "EnableAutoList",
            {
                Text = "⚡ Start AutoList",
                Default = false,
            }
        )

AutoListToggle:OnChanged(function(value)

    ListingsState.Enabled =
        value == true

    ListingsState.VisualTagsEnabled =
        ListingsState.Enabled

    ListingsState.AutoDisableWhenDone =
        false

    ListingsState.LastScan =
        0

    ListingsState.NoWorkSleepUntil =
        0

    -- Save the user's real intent separately from Obsidian timing.
    -- This is what restore reads after rejoin.
    SaveListingAutoListIntent(
        ListingsState.Enabled
    )

    --==================================================
    -- During SaveManager hydration, do not validate.
    -- Saved filters/dropdowns may still be restoring.
    --==================================================

    if ConfigState
    and ConfigState.IsHydrating then

        if ListingsState.Enabled then
            ListingsState.Status =
                "Restore pending"
        else
            ListingsState.Status =
                "Disabled"
        end

        if type(ListingsStatusRefresh) == "function" then
            pcall(ListingsStatusRefresh)
        end

        return
    end

    --==================================================
    -- Manual user toggle ON.
    -- Validate after hydration only.
    --==================================================

    if ListingsState.Enabled then

        if type(EnsureListingFilters) == "function" then
            pcall(EnsureListingFilters)
        end

        if type(SyncListingRequiredFlagsFromValues) == "function" then
            pcall(SyncListingRequiredFlagsFromValues)
        end

        local configAllowed, configReason =
            true,
            "OK"

        if type(IsListingConfigurationAllowed) == "function" then
            configAllowed, configReason =
                IsListingConfigurationAllowed()
        end

        if not configAllowed then

            ListingsState.Enabled =
                false

            ListingsState.VisualTagsEnabled =
                false

            ListingsState.Status =
                tostring(configReason or "Config blocked")

            SaveListingAutoListIntent(false)

            task.defer(function()

                pcall(function()

                    if Library
                    and Library.Options
                    and Library.Options.EnableAutoList then

                        Library.Options.EnableAutoList:SetValue(false)
                    end
                end)
            end)

            warn(
                "[LISTINGS] AutoList blocked:",
                tostring(configReason)
            )

            if type(ListingsStatusRefresh) == "function" then
                ListingsStatusRefresh()
            end

            return
        end
    end

    if ListingsState.Enabled then

        ListingsState.ListedUUIDs =
            ListingsState.ListedUUIDs
            or {}

        ListingsState.FailedUUIDs =
            ListingsState.FailedUUIDs
            or {}

        ListingsState.ListingQueue =
            ListingsState.ListingQueue
            or {}

        ListingsState.QueuedUUIDs =
            ListingsState.QueuedUUIDs
            or {}

        ListingsState.OwnListedUUIDs =
            ListingsState.OwnListedUUIDs
            or {}

        ListingsState.PendingUUIDs =
            ListingsState.PendingUUIDs
            or {}

        table.clear(ListingsState.ListedUUIDs)
        table.clear(ListingsState.FailedUUIDs)
        table.clear(ListingsState.ListingQueue)
        table.clear(ListingsState.QueuedUUIDs)
        table.clear(ListingsState.OwnListedUUIDs)
        table.clear(ListingsState.PendingUUIDs)

        ListingsState.ActiveCreateUUID =
            nil

        ListingsState.ActiveCreateStartedAt =
            0

        ListingsState.ListedThisSession =
            0

        ListingsState.LastScan =
            0

        ListingsState.NoWorkSleepUntil =
            0

        ListingsState.Status =
            "Enabled | watching"

        print("[LISTINGS] AutoList enabled | runtime cache cleared")

        if type(BuildListingPreview) == "function" then
            pcall(BuildListingPreview)
        end

        -- Run one immediate pass instead of waiting for the scan timer.
        task.defer(function()

            if ListingsState.Enabled ~= true then
                return
            end

            if ScriptState
            and ScriptState.ForceStopped then
                return
            end

            if type(RunAutoListingPass) == "function" then
                pcall(RunAutoListingPass)
            end

            if type(ListingsStatusRefresh) == "function" then
                pcall(ListingsStatusRefresh)
            end
        end)

    else

        ListingsState.Status =
            "Disabled"
    end

    MarkConfigDirty()

    if type(ListingsStatusRefresh) == "function" then
        ListingsStatusRefresh()
    end
end)

    ListingActionsBox:AddDivider({
        Text = "Queue",
        MarginTop = 8,
        MarginBottom = 8,
    })

    local QueueButton =
        ListingActionsBox:AddButton({
            Text = "Queue",
            Tooltip = "Listing queue controls.",
            Func = function()

                HolyNotify(
                    "Listing Queue",
                    "Use Preview, Refresh, Clear, or STOP.",
                    "list",
                    3
                )
            end,
        })

    QueueButton:AddButton({
        Text = "Preview",
        Tooltip = "Preview matching inventory pets.",
        Func = function()

            PrintListingPreview()
            ListingsStatusRefresh()
        end,
    })

    ListingActionsBox:AddButton({
    Text = "Debug Preview",
    Tooltip = "Print every matching listing pet and why it is ready/skipped.",
    Func = function()

        if type(PrintDetailedListingPreview) == "function" then
            PrintDetailedListingPreview()
        end
    end,
})

    QueueButton:AddButton({
    Text = "Refresh",
    Tooltip = "Refresh inventory, preview, and own booth listings.",
    Func = function()

        RefreshListingInventorySnapshot()
        BuildOwnBoothListingSnapshot(true)
        BuildListingPreview()
        ListingsStatusRefresh()
    end,
})

    QueueButton:AddButton({
        Text = "Clear",
        Tooltip = "Clear pending listing queue.",
        Func = function()

            table.clear(ListingsState.ListingQueue)
table.clear(ListingsState.QueuedUUIDs)

ListingsState.PendingUUIDs =
    ListingsState.PendingUUIDs
    or {}

table.clear(ListingsState.PendingUUIDs)

ListingsState.ActiveCreateUUID =
    nil

ListingsState.ActiveCreateStartedAt =
    0

ListingsState.Status =
    "Queue cleared"

            BuildListingPreview()
            ListingsStatusRefresh()
        end,
    })

    QueueButton:AddButton({
        Text = "STOP",
        Tooltip = "Hard stop listings and script runtime.",
        Risky = true,
        DoubleClick = true,
        Func = function()

            ScriptState.ForceStopped =
                true

            ListingsState.Enabled =
                false

            ListingsState.Status =
                "ForceStopped"

            table.clear(ListingsState.ListingQueue)
            table.clear(ListingsState.QueuedUUIDs)

            if Library.Options.EnableAutoList then
                Library.Options.EnableAutoList:SetValue(false)
            end

            ListingsStatusRefresh()

            warn("[LISTINGS] Emergency stop")
        end,
    })

    --==================================================
    -- STATUS TAB
    --==================================================

    local StatusLabel =
        ListingStatusBox:AddLabel("Status: Idle", false)

    local InventoryLabel =
        ListingStatusBox:AddLabel("Pets: 0", false)

    local QueueLabel =
        ListingStatusBox:AddLabel("Queue: 0", false)

    local SessionListedLabel =
        ListingStatusBox:AddLabel("Listed Session: 0", false)

    local LastListedLabel =
        ListingStatusBox:AddLabel("Last Listed: None", false)

    
    --==================================================
    -- STATUS SUMMARY ONLY
    -- Keep Status clean. The full booth list is rendered
    -- in the always-visible bottom groupbox.
    --==================================================

    local BoothListedSummaryLabel =
        ListingStatusBox:AddLabel(
            "Booth Listed: syncing...",
            false
        )

    --==================================================
    -- ALWAYS-VISIBLE BOOTH LIST PANEL
    -- Watchlist-style compact rows.
    --==================================================

    local BoothListedHeaderLabel =
        ListingBoothBox:AddLabel(
            "0 listings • Page 1/1 • Not synced",
            false
        )

--==================================================
-- CUSTOM BOOTH LIST TABLE
-- Clean clickable table rendered through Obsidian UIPassthrough.
--==================================================

local BoothListUI =
{
    Rows = {},
    BusyRows = {},
}

local BoothListContainer =
    Instance.new("Frame")

BoothListContainer.Name =
    "HolyBoothListedTable"

BoothListContainer.BackgroundTransparency =
    1

BoothListContainer.Size =
    UDim2.new(1, 0, 0, 190)

local BoothTableHeader =
    Instance.new("Frame")

BoothTableHeader.Name =
    "Header"

BoothTableHeader.BackgroundTransparency =
    1

BoothTableHeader.Position =
    UDim2.fromOffset(0, 0)

BoothTableHeader.Size =
    UDim2.new(1, 0, 0, 20)

BoothTableHeader.Parent =
    BoothListContainer

local function CreateTableTextLabel(name, parent, position, size, text, alignment)

    local label =
        Instance.new("TextLabel")

    label.Name =
        name

    label.BackgroundTransparency =
        1

    label.Position =
        position

    label.Size =
        size

    label.Font =
        Enum.Font.Code

    label.Text =
        tostring(text or "")

    label.TextSize =
        14

    label.TextColor3 =
        Color3.fromRGB(205, 205, 205)

    label.TextTransparency =
        0.25

    label.TextXAlignment =
        alignment or Enum.TextXAlignment.Left

    label.TextYAlignment =
        Enum.TextYAlignment.Center

    label.TextTruncate =
        Enum.TextTruncate.AtEnd

    label.RichText =
        false

    label.Parent =
        parent

    return label
end

CreateTableTextLabel(
    "PetHeader",
    BoothTableHeader,
    UDim2.fromOffset(10, 0),
    UDim2.new(1, -170, 1, 0),
    "Pet",
    Enum.TextXAlignment.Left
)

CreateTableTextLabel(
    "PriceHeader",
    BoothTableHeader,
    UDim2.new(1, -160, 0, 0),
    UDim2.fromOffset(70, 20),
    "Price",
    Enum.TextXAlignment.Right
)

CreateTableTextLabel(
    "BWHeader",
    BoothTableHeader,
    UDim2.new(1, -84, 0, 0),
    UDim2.fromOffset(42, 20),
    "BW",
    Enum.TextXAlignment.Right
)

CreateTableTextLabel(
    "RemoveHeader",
    BoothTableHeader,
    UDim2.new(1, -35, 0, 0),
    UDim2.fromOffset(30, 20),
    "",
    Enum.TextXAlignment.Center
)

local function ResolveBoothTableDisplayName(item)

    if type(item) ~= "table" then
        return "-"
    end

    local petName =
        tostring(item.PetName or "Unknown")

    local mutation =
        tostring(item.MutationText or "Normal")

    if mutation ~= ""
    and mutation ~= "Normal"
    and mutation ~= "---"
    and mutation ~= "Unknown" then
        return mutation .. " " .. petName
    end

    return petName
end

local function RemoveVisibleBoothListingRow(rowIndex)

    rowIndex =
        math.max(
            1,
            math.floor(
                SafeNumber(rowIndex, 1)
            )
        )

    if BoothListUI.BusyRows[rowIndex] then
        return
    end

    if ScriptState
    and ScriptState.ForceStopped then
        return
    end

    BoothListUI.BusyRows[rowIndex] =
        true

    task.spawn(function()

        local absoluteIndex =
            GetOwnBoothSnapshotAbsoluteIndex(rowIndex)

        local item =
            ListingsState.OwnBoothSnapshot
            and ListingsState.OwnBoothSnapshot[absoluteIndex]

        if type(item) ~= "table" then

            HolyNotify(
                "No Listing",
                "There is no booth listing on row "
                    .. tostring(rowIndex)
                    .. ".",
                "info",
                3
            )

            BoothListUI.BusyRows[rowIndex] =
                nil

            return
        end

        local displayName =
            ResolveBoothTableDisplayName(item)

        local ok, reason =
            RemoveOwnBoothSnapshotPageIndex(rowIndex)

        if ok then

            HolyNotify(
                "Listing Removed",
                displayName,
                "check",
                3
            )

        else

            HolyNotify(
                "Remove Failed",
                tostring(reason or "Could not remove listing."),
                "triangle-alert",
                4
            )

            warn(
                "[LISTINGS] Click-remove failed:",
                tostring(reason)
            )
        end

        BoothListUI.BusyRows[rowIndex] =
            nil
    end)
end

local function CreateBoothTableRow(rowIndex)

    local row =
        Instance.new("TextButton")

    row.Name =
        "Row" .. tostring(rowIndex)

    row.AutoButtonColor =
        false

    row.BackgroundColor3 =
        Color3.fromRGB(22, 22, 22)

    row.BackgroundTransparency =
        0.28

    row.BorderSizePixel =
        0

    row.Position =
        UDim2.fromOffset(
            0,
            22 + ((rowIndex - 1) * 22)
        )

    row.Size =
        UDim2.new(1, 0, 0, 20)

    row.Text =
        ""

    row.Parent =
        BoothListContainer

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 3)

    corner.Parent =
        row

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        Color3.fromRGB(48, 48, 48)

    stroke.Transparency =
        0.45

    stroke.Thickness =
        1

    stroke.Parent =
        row

    local petLabel =
        CreateTableTextLabel(
            "Pet",
            row,
            UDim2.fromOffset(10, 0),
            UDim2.new(1, -178, 1, 0),
            "• -",
            Enum.TextXAlignment.Left
        )

    local priceLabel =
        CreateTableTextLabel(
            "Price",
            row,
            UDim2.new(1, -160, 0, 0),
            UDim2.fromOffset(70, 20),
            "-",
            Enum.TextXAlignment.Right
        )

    local bwLabel =
        CreateTableTextLabel(
            "BW",
            row,
            UDim2.new(1, -84, 0, 0),
            UDim2.fromOffset(42, 20),
            "-",
            Enum.TextXAlignment.Right
        )

    local removeLabel =
        CreateTableTextLabel(
            "Remove",
            row,
            UDim2.new(1, -35, 0, 0),
            UDim2.fromOffset(30, 20),
            "×",
            Enum.TextXAlignment.Center
        )

    removeLabel.TextColor3 =
        Color3.fromRGB(255, 80, 80)

    removeLabel.TextTransparency =
        0.15

    row.MouseEnter:Connect(function()

        row.BackgroundTransparency =
            0.08

        stroke.Transparency =
            0.15

        petLabel.TextTransparency =
            0

        priceLabel.TextTransparency =
            0

        bwLabel.TextTransparency =
            0

        removeLabel.TextTransparency =
            0
    end)

    row.MouseLeave:Connect(function()

        row.BackgroundTransparency =
            0.28

        stroke.Transparency =
            0.45

        petLabel.TextTransparency =
            0.25

        priceLabel.TextTransparency =
            0.25

        bwLabel.TextTransparency =
            0.25

        removeLabel.TextTransparency =
            0.15
    end)

    row.MouseButton1Click:Connect(function()
        RemoveVisibleBoothListingRow(rowIndex)
    end)

    BoothListUI.Rows[rowIndex] =
    {
        Button = row,
        Pet = petLabel,
        Price = priceLabel,
        BW = bwLabel,
        Remove = removeLabel,
        Stroke = stroke,
    }
end

for i = 1, 7 do
    CreateBoothTableRow(i)
end

ListingBoothBox:AddUIPassthrough(
    "BoothListedTable",
    {
        Instance = BoothListContainer,
        Height = 190,
    }
)

local function FormatBoothTablePrice(value)

    local numberValue =
        tonumber(value)

    if not numberValue then
        return "-"
    end

    numberValue =
        math.floor(numberValue)

    local text =
        tostring(numberValue)

    local left, num, right =
        string.match(
            text,
            "^([^%d]*%d)(%d*)(.-)$"
        )

    if not left then
        return text
    end

    return left
        .. (
            num:reverse()
                :gsub("(%d%d%d)", "%1,")
                :reverse()
        )
        .. right
end

local function FormatBoothTableWeight(value)

    local numberValue =
        tonumber(value)

    if not numberValue then
        return "-"
    end

    return string.format("%.2fbw", numberValue)
end

local function RenderBoothListedTable()

    local snapshot =
        ListingsState.OwnBoothSnapshot
        or {}

    local page =
        math.max(
            1,
            math.floor(
                SafeNumber(
                    ListingsState.OwnBoothSnapshotPage,
                    1
                )
            )
        )

    local perPage =
        math.max(
            1,
            math.floor(
                SafeNumber(
                    ListingsState.OwnBoothSnapshotPerPage,
                    7
                )
            )
        )

    for i = 1, 7 do

        local row =
            BoothListUI.Rows[i]

        if not row then
            continue
        end

        local index =
            ((page - 1) * perPage)
            + i

        local item =
            snapshot[index]

        if type(item) == "table" then

            local prefix =
                item.Favorite
                and "★ "
                or "• "

            row.Pet.Text =
                prefix
                .. ResolveBoothTableDisplayName(item)

            row.Price.Text =
                FormatBoothTablePrice(item.Price)

            row.BW.Text =
    FormatBoothTableWeight(
        item.BaseWeight
        or item.DisplayWeight
        or item.Weight
    )

            row.Remove.Text =
                "×"

            row.Button.Active =
                true

            row.Button.AutoButtonColor =
                false

            row.Button.BackgroundTransparency =
                0.28

            row.Stroke.Transparency =
                0.45

            row.Pet.TextTransparency =
                0.25

            row.Price.TextTransparency =
                0.25

            row.BW.TextTransparency =
                0.25

            row.Remove.TextTransparency =
                0.15

        else

            row.Pet.Text =
                "• -"

            row.Price.Text =
                "-"

            row.BW.Text =
                "-"

            row.Remove.Text =
                ""

            row.Button.Active =
                false

            row.Button.BackgroundTransparency =
                0.72

            row.Stroke.Transparency =
                0.85

            row.Pet.TextTransparency =
                0.65

            row.Price.TextTransparency =
                0.65

            row.BW.TextTransparency =
                0.65

            row.Remove.TextTransparency =
                1
        end
    end
end

    local BoothListedPageButton =
        ListingBoothBox:AddButton({
            Text = "‹ Prev",
            Tooltip = "Previous booth listing page.",
            Func = function()

                ListingsState.OwnBoothSnapshotPage =
                    math.max(
                        1,
                        SafeNumber(
                            ListingsState.OwnBoothSnapshotPage,
                            1
                        ) - 1
                    )

                if type(ListingsStatusRefresh) == "function" then
                    ListingsStatusRefresh()
                end
            end,
        })

    BoothListedPageButton:AddButton({
        Text = "Next ›",
        Tooltip = "Next booth listing page.",
        Func = function()

            local total =
                ListingsState.OwnBoothSnapshot
                and #ListingsState.OwnBoothSnapshot
                or 0

            local perPage =
                SafeNumber(
                    ListingsState.OwnBoothSnapshotPerPage,
                    7
                )

            local maxPage =
                math.max(
                    1,
                    math.ceil(total / perPage)
                )

            ListingsState.OwnBoothSnapshotPage =
                math.min(
                    maxPage,
                    SafeNumber(
                        ListingsState.OwnBoothSnapshotPage,
                        1
                    ) + 1
                )

            if type(ListingsStatusRefresh) == "function" then
                ListingsStatusRefresh()
            end
        end,
    })

    ListingBoothBox:AddButton({
        Text = "Refresh Booth",
        Tooltip = "Force-refresh pets currently listed in your booth.",
        Func = function()

            BuildOwnBoothListingSnapshot(true)

            if type(ListingsStatusRefresh) == "function" then
                ListingsStatusRefresh()
            end
        end,
    })
    
        ListingBoothBox:AddDivider({
        Text = "Remove Listings",
        MarginTop = 8,
        MarginBottom = 8,
    })

    local SelectedBoothRemoveIndex =
        1

    local BoothRemoveIndexInput =
        ListingBoothBox:AddInput(
            "BoothRemoveListingIndex",
            {
                Text = "Remove Page Pet",
                Placeholder = "1-7 on current page",
                Default = "1",
                Numeric = false,
                Finished = true,
            }
        )

    BoothRemoveIndexInput:OnChanged(function(value)

        local text =
            tostring(value or "")
                :gsub(",", "")
                :gsub("%s+", "")

        local index =
            tonumber(text)

        if not index then
            return
        end

        SelectedBoothRemoveIndex =
            math.max(
                1,
                math.floor(index)
            )
    end)

    local RemoveSelectedBoothListingButton =
        ListingBoothBox:AddButton({
            Text = "Remove Selected",
            Tooltip = "Removes the selected listed pet from the current booth page.",
            Func = function()

                if ScriptState
                and ScriptState.ForceStopped then
                    return
                end

                local index =
                    math.max(
                        1,
                        math.floor(
                            SafeNumber(
                                SelectedBoothRemoveIndex,
                                1
                            )
                        )
                    )

                local ok, reason =
                    RemoveOwnBoothSnapshotPageIndex(index)

                if ok then

                    HolyNotify(
                        "Listing Removed",
                        "Removed booth listing at page slot "
                            .. tostring(index)
                            .. ".",
                        "check",
                        3
                    )

                else

                    HolyNotify(
                        "Remove Failed",
                        tostring(reason or "Could not remove selected listing."),
                        "triangle-alert",
                        4
                    )

                    warn(
                        "[LISTINGS] Remove selected failed:",
                        tostring(reason)
                    )
                end
            end,
        })

    RemoveSelectedBoothListingButton:AddButton({
        Text = "Remove All",
        Tooltip = "Removes every pet currently listed in your booth. AutoList is paused first.",
        Risky = true,
        DoubleClick = true,
        Func = function()

            if ScriptState
            and ScriptState.ForceStopped then
                return
            end

            task.spawn(function()

                local removed, failed, reason =
                    RemoveAllOwnBoothListings()

                HolyNotify(
                    "Remove All Complete",
                    "Removed: "
                        .. tostring(removed)
                        .. " | Failed: "
                        .. tostring(failed),
                    failed > 0 and "triangle-alert" or "check",
                    5
                )

                print(
                    "[LISTINGS] Remove all complete | removed:",
                    tostring(removed),
                    "| failed:",
                    tostring(failed),
                    "| reason:",
                    tostring(reason)
                )
            end)
        end,
    })
--==================================================
-- PREVIEW TAB
-- Purpose:
-- Clear safety summary of what the current setup will do.
--==================================================

local PreviewVerdictLabel =
    ListingPreviewBox:AddLabel("⚠️ Not Ready", false)

local PreviewFilterLabel =
    ListingPreviewBox:AddLabel("Pet: -", false)

local PreviewMutationLabel =
    ListingPreviewBox:AddLabel("Mutation: -", false)

local PreviewLevelLabel =
    ListingPreviewBox:AddLabel("Level: -", false)

local PreviewWeightLabel =
    ListingPreviewBox:AddLabel("BaseWeight: required", false)

local PreviewPriceLabel =
    ListingPreviewBox:AddLabel("Tokens: required", false)

ListingPreviewBox:AddDivider({
    Text = "Inventory Check",
    MarginTop = 8,
    MarginBottom = 8,
})

local PreviewCountsLabel =
    ListingPreviewBox:AddLabel("Matching: 0 | Ready: 0", false)

local PreviewHandledLabel =
    ListingPreviewBox:AddLabel("Already Listed: 0 | Queued: 0", false)

local PreviewFailedLabel =
    ListingPreviewBox:AddLabel("Failed: 0 | Runtime: 0", false)

ListingPreviewBox:AddDivider({
    Text = "Result",
    MarginTop = 8,
    MarginBottom = 8,
})

local PreviewResultLabel =
    ListingPreviewBox:AddLabel("Set pet, weight, and price to preview.", true)

    --==================================================
    -- FILTERS TAB
    -- Purpose:
    -- Make active listing filters readable and obvious.
    -- This is display/control UI only. Listing logic is unchanged.
    --==================================================

    ListingsState.ListingFilterUI =
        ListingsState.ListingFilterUI
        or {
            Page = 1,
            PerPage = 8,
        }

    ListingsState.ListingFilterUI.PerPage =
        8

    local SelectedListingFilterIndex =
        1

local FilterHeaderLabel =
    ListingFiltersBox:AddLabel(
        "Active Filters: 0",
        false
    )

local FilterHelpLabel =
    ListingFiltersBox:AddLabel(
        "Only pets matching active filters can be listed.",
        false
    )

    local FilterLineLabels =
        {}

    for i = 1, 8 do

        FilterLineLabels[i] =
            ListingFiltersBox:AddLabel(
                tostring(i) .. ". -",
                false
            )
    end

    ListingFiltersBox:AddDivider({
        Text = "Manage Filters",
        MarginTop = 8,
        MarginBottom = 8,
    })

    local RemoveIndexInput =
        ListingFiltersBox:AddInput(
            "ListingRemoveFilterIndex",
            {
                Text = "Remove Index",
                Placeholder = "Filter number",
                Default = "1",
                Numeric = false,
                Finished = true,
            }
        )

    RemoveIndexInput:OnChanged(function(value)

        local text =
            tostring(value or "")
                :gsub(",", "")
                :gsub("%s+", "")

        local index =
            tonumber(text)

        if not index then
            return
        end

        SelectedListingFilterIndex =
            math.max(
                1,
                math.floor(index)
            )
    end)

    local FilterPageButton =
        ListingFiltersBox:AddButton({
            Text = "Page Controls",
            Tooltip = "Move through active listing filter pages.",
            Func = function()

                HolyNotify(
                    "Active Listing Filters",
                    "Use Prev/Next to change pages. Use Remove Selected to delete by index.",
                    "list-filter",
                    4
                )
            end,
        })

    FilterPageButton:AddButton({
        Text = "Prev",
        Func = function()

            ListingsState.ListingFilterUI.Page =
                math.max(
                    1,
                    SafeNumber(
                        ListingsState.ListingFilterUI.Page,
                        1
                    ) - 1
                )

            RefreshListingFilterUI()
        end,
    })

    FilterPageButton:AddButton({
        Text = "Next",
        Func = function()

            local filters =
                EnsureListingFilters()

            local perPage =
                SafeNumber(
                    ListingsState.ListingFilterUI.PerPage,
                    8
                )

            local maxPage =
                math.max(
                    1,
                    math.ceil(#filters / perPage)
                )

            ListingsState.ListingFilterUI.Page =
                math.min(
                    maxPage,
                    SafeNumber(
                        ListingsState.ListingFilterUI.Page,
                        1
                    ) + 1
                )

            RefreshListingFilterUI()
        end,
    })

    local RemoveSelectedButton =
        ListingFiltersBox:AddButton({
            Text = "Remove Selected Filter",
            Tooltip = "Removes the filter number typed above.",
            Risky = true,
            DoubleClick = true,
            Func = function()

                local filters =
                    EnsureListingFilters()

                local index =
                    tonumber(SelectedListingFilterIndex)

                if not index
                or not filters[index] then

                    HolyNotify(
                        "Remove Failed",
                        "No listing filter exists at index "
                            .. tostring(index or "?"),
                        "circle-alert",
                        4
                    )

                    return
                end

                local removed =
                    filters[index]

                RemoveListingFilterAt(index)

                HolyNotify(
                    "Listing Filter Removed",
                    tostring(removed.Pet or "Unknown")
                        .. " removed from AutoList filters.",
                    "trash",
                    4
                )
            end,
        })

    local ClearFiltersButton =
        ListingFiltersBox:AddButton({
            Text = "Clear All Filters",
            Tooltip = "Removes every active listing filter.",
            Risky = true,
            DoubleClick = true,
            Func = function()

                ClearListingFilters()
            end,
        })

    RefreshListingFilterUI = function()

        local filters =
            EnsureListingFilters()

        ListingsState.ListingFilterUI =
            ListingsState.ListingFilterUI
            or {
                Page = 1,
                PerPage = 8,
            }

        ListingsState.ListingFilterUI.PerPage =
            8

        local perPage =
            SafeNumber(
                ListingsState.ListingFilterUI.PerPage,
                8
            )

        local page =
            SafeNumber(
                ListingsState.ListingFilterUI.Page,
                1
            )

        local maxPage =
            math.max(
                1,
                math.ceil(#filters / perPage)
            )

        page =
            math.clamp(
                page,
                1,
                maxPage
            )

        ListingsState.ListingFilterUI.Page =
            page

        if FilterHeaderLabel then

            FilterHeaderLabel:SetText(
    "Active Filters: "
    .. tostring(#filters)
    .. "  •  Page "
    .. tostring(page)
    .. "/"
    .. tostring(maxPage)
)
        end

        local startIndex =
            ((page - 1) * perPage) + 1

        for slot = 1, perPage do

            local label =
                FilterLineLabels[slot]

            local filterIndex =
                startIndex + slot - 1

            local filter =
                filters[filterIndex]

            if label then

                if filter then

                    label:SetText(
                        FormatListingFilterLine(
                            filterIndex,
                            filter
                        )
                    )

                else

                label:SetText(
    string.format(
        "%02d  -",
        filterIndex
    )
)
                end
            end
        end
    end

    RefreshListingFilterUI()
    --==================================================
    -- HISTORY TAB
    --==================================================

    local HistoryRuntimeLabel =
        ListingHistoryBox:AddLabel("Runtime Listed: 0", false)

    local HistoryQueuedLabel =
        ListingHistoryBox:AddLabel("Queued: 0", false)

    local HistoryFailedLabel =
        ListingHistoryBox:AddLabel("Failed: 0", false)

    local HistoryLastLabel =
        ListingHistoryBox:AddLabel("Last: None", false)

    --==================================================
    -- STATUS REFRESH
    --==================================================

    ListingsStatusRefresh = function()

        if IsTradeWorld()
        and type(RefreshOwnBoothListingSnapshotThrottled) == "function" then
            pcall(RefreshOwnBoothListingSnapshotThrottled)
        end

        if StatusLabel then

            local displayStatus =
                tostring(ListingsState.Status or "Idle")

            local configAllowed, configReason =
                IsListingConfigurationAllowed()

            if not configAllowed then

                displayStatus =
                    configReason

            elseif displayStatus == "Price required"
            or displayStatus == "Min BaseWeight required"
            or displayStatus == "Max BaseWeight required"
            or displayStatus == "Max must be >= Min" then

                if ListingsState.Enabled then
                    displayStatus =
                        "Enabled"
                else
                    displayStatus =
                        "Ready"
                end
            end

            StatusLabel:SetText(
                "Status: "
                .. displayStatus
            )
        end

        if InventoryLabel then
            InventoryLabel:SetText(
                "Pets: "
                .. tostring(#ListingsState.InventorySnapshot)
            )
        end

        if QueueLabel then
            QueueLabel:SetText(
                "Queue: "
                .. tostring(#ListingsState.ListingQueue)
            )
        end

        if SessionListedLabel then
            SessionListedLabel:SetText(
                "Listed Session: "
                .. tostring(ListingsState.ListedThisSession)
            )
        end

                local snapshot =
            ListingsState.OwnBoothSnapshot
            or {}

        local listedCount =
            #snapshot

        local boothStatus =
            tostring(
                ListingsState.OwnBoothSnapshotStatus
                or "Unknown"
            )

        if BoothListedSummaryLabel then

            BoothListedSummaryLabel:SetText(
                "Booth Listed: "
                .. tostring(listedCount)
                .. " pets"
                .. " | "
                .. boothStatus
            )
        end

        local perPage =
            SafeNumber(
                ListingsState.OwnBoothSnapshotPerPage,
                7
            )

        local total =
            #snapshot

        local maxPage =
            math.max(
                1,
                math.ceil(total / perPage)
            )

        ListingsState.OwnBoothSnapshotPage =
            math.clamp(
                SafeNumber(
                    ListingsState.OwnBoothSnapshotPage,
                    1
                ),
                1,
                maxPage
            )

        local page =
            ListingsState.OwnBoothSnapshotPage

        if BoothListedHeaderLabel then

            BoothListedHeaderLabel:SetText(
                tostring(total)
                .. " listings"
                .. " • Page "
                .. tostring(page)
                .. "/"
                .. tostring(maxPage)
                .. " • "
                .. boothStatus
            )
        end

RenderBoothListedTable()

local preview =
    ListingsState.Preview
    or {}

local function FormatPreviewNumber(value, fallback)

    if value == nil then
        return tostring(fallback or "-")
    end

    local number =
        tonumber(value)

    if not number then
        return tostring(value)
    end

    if number % 1 == 0 then
        return tostring(math.floor(number))
    end

    return tostring(number)
end

local priceAllowed, priceReason =
    IsListingPriceAllowed()

local minWeight =
    tonumber(ListingsState.MinWeight)

local maxWeight =
    tonumber(ListingsState.MaxWeight)

local weightAllowed =
    true

local weightReason =
    "OK"

if ListingsState.MinWeightWasEntered ~= true then

    weightAllowed =
        false

    weightReason =
        "Min required"

elseif ListingsState.MaxWeightWasEntered ~= true then

    weightAllowed =
        false

    weightReason =
        "Max required"

elseif not minWeight
or not maxWeight then

    weightAllowed =
        false

    weightReason =
        "Invalid"

elseif maxWeight < minWeight then

    weightAllowed =
        false

    weightReason =
        "Max < Min"
end

local minLevel =
    SafeNumber(
        ListingsState.MinLevel,
        1
    )

local maxLevel =
    SafeNumber(
        ListingsState.MaxLevel,
        100
    )

local levelAllowed =
    maxLevel >= minLevel

local levelReason =
    levelAllowed
    and "OK"
    or "Max < Min"

local petName =
    tostring(
        ListingsState.SelectedPet
        or ""
    )

local petAllowed =
    petName ~= ""

local mutationText =
    tostring(
        ListingsState.SelectedMutation
        or "---"
    )

if mutationText == "All Except" then

    mutationText =
        "All Except "
        .. FormatExcludedListingMutations(
            ListingsState.SelectedExcludedMutations
        )
end

local readyCount =
    SafeNumber(
        preview.Ready,
        0
    )

local matchingCount =
    SafeNumber(
        preview.Matching,
        0
    )

local alreadyListed =
    SafeNumber(
        preview.AlreadyListed,
        0
    )

local queuedCount =
    SafeNumber(
        preview.Queued,
        0
    )

local failedCount =
    SafeNumber(
        preview.Failed,
        0
    )

local runtimeListed =
    SafeNumber(
        preview.RuntimeListed,
        0
    )

local setupAllowed =
    petAllowed
    and priceAllowed
    and weightAllowed
    and levelAllowed

local verdictText =
    "⚠️ Not Ready"

local resultText =
    "Fix required fields before adding this filter."

if setupAllowed then

    if readyCount > 0 then

        verdictText =
            "✅ Ready To List"

        resultText =
            "AutoList can queue "
            .. tostring(readyCount)
            .. " matching pet"
            .. (
                readyCount == 1
                and "."
                or "s."
            )

    elseif matchingCount > 0
    and alreadyListed >= matchingCount then

        verdictText =
            "✅ Already Handled"

        resultText =
            "All matching pets are already listed in your booth."

    elseif matchingCount > 0 then

        verdictText =
            "✅ Filter Valid"

        resultText =
            "Filter is valid, but no new pets are ready right now."

    else

        verdictText =
            "✅ Filter Valid"

        resultText =
            "No inventory pets currently match this setup."
    end

else

    if not petAllowed then

        resultText =
            "Select a pet before adding this filter."

    elseif not priceAllowed then

        resultText =
            "Price blocked: "
            .. tostring(priceReason or "Invalid price")

    elseif not weightAllowed then

        resultText =
            "BaseWeight blocked: "
            .. tostring(weightReason)

    elseif not levelAllowed then

        resultText =
            "Level blocked: "
            .. tostring(levelReason)
    end
end

if PreviewVerdictLabel then

    PreviewVerdictLabel:SetText(
        verdictText
    )
end

if PreviewFilterLabel then

    PreviewFilterLabel:SetText(
        "Pet: "
        .. (
            petAllowed
            and petName
            or "-"
        )
    )
end

if PreviewMutationLabel then

    PreviewMutationLabel:SetText(
        "Mutation: "
        .. tostring(mutationText)
    )
end

if PreviewLevelLabel then

    PreviewLevelLabel:SetText(
        "Level: "
        .. FormatPreviewNumber(minLevel, 1)
        .. " - "
        .. FormatPreviewNumber(maxLevel, 100)
        .. " | "
        .. tostring(levelReason)
    )
end

if PreviewWeightLabel then

    local minText =
        ListingsState.MinWeightWasEntered == true
        and FormatPreviewNumber(ListingsState.MinWeight, "-")
        or "required"

    local maxText =
        ListingsState.MaxWeightWasEntered == true
        and FormatPreviewNumber(ListingsState.MaxWeight, "-")
        or "required"

    PreviewWeightLabel:SetText(
        "BaseWeight: "
        .. tostring(minText)
        .. " - "
        .. tostring(maxText)
        .. " | "
        .. tostring(weightReason)
    )
end

if PreviewPriceLabel then

    PreviewPriceLabel:SetText(
        "Tokens: "
        .. FormatPreviewNumber(
            ListingsState.Price,
            "required"
        )
        .. " | "
        .. tostring(
            priceAllowed
            and "OK"
            or priceReason
        )
    )
end

if PreviewCountsLabel then

    PreviewCountsLabel:SetText(
        "Matching: "
        .. tostring(matchingCount)
        .. " | Ready: "
        .. tostring(readyCount)
    )
end

if PreviewHandledLabel then

    PreviewHandledLabel:SetText(
        "Already Listed: "
        .. tostring(alreadyListed)
        .. " | Queued: "
        .. tostring(queuedCount)
    )
end

if PreviewFailedLabel then

    PreviewFailedLabel:SetText(
        "Failed: "
        .. tostring(failedCount)
        .. " | Runtime: "
        .. tostring(runtimeListed)
    )
end

if PreviewResultLabel then

    PreviewResultLabel:SetText(
        "Result: "
        .. tostring(resultText)
    )
end

        if type(RefreshListingFilterUI) == "function" then
            RefreshListingFilterUI()
        end

        if HistoryRuntimeLabel then
            HistoryRuntimeLabel:SetText(
                "Runtime Listed: "
                .. tostring(preview.RuntimeListed or 0)
            )
        end

        if HistoryQueuedLabel then
            HistoryQueuedLabel:SetText(
                "Queued: "
                .. tostring(preview.Queued or 0)
            )
        end

        if HistoryFailedLabel then
            HistoryFailedLabel:SetText(
                "Failed: "
                .. tostring(preview.Failed or 0)
            )
        end

        if HistoryLastLabel then
            HistoryLastLabel:SetText(
                "Last: "
                .. tostring(ListingsState.LastListed or "None")
            )
        end
    end

    ListingsStatusRefresh()
end
--==================================================
-- WEBHOOK UI
--==================================================
function BuildWebhookTab()

    --==================================================
    -- MASTER TOGGLE
    --==================================================

    local EnableWebhookToggle =
        WebhookBox:AddToggle(
            "EnableWebhook",
            {
                Text = "🔗 Enable Webhook",
                Tooltip = "Master switch for all personal webhook notifications.",
                Default = false,
            }
        )

    EnableWebhookToggle:OnChanged(function(v)

        WebhookState.Enabled = v

        MarkConfigDirty()
    end)

    --==================================================
    -- DEPENDENCY GROUPBOX
    -- Everything below only matters when webhooks are enabled.
    --==================================================

    local WebhookDependencyBox =
        WebhookBox:AddDependencyGroupbox()

    WebhookDependencyBox:SetupDependencies({
    {
        Library.Toggles.EnableWebhook,
        true,
    },
})

    --==================================================
    -- NOTIFICATION TYPES
    --==================================================

    WebhookDependencyBox:AddDivider({
        Text = "Notifications",
        MarginTop = 6,
        MarginBottom = 8,
    })

    local SuccessfulToggle =
        WebhookDependencyBox:AddToggle(
            "WebhookSuccessfulSnipes",
            {
                Text = "⚡ Successful Snipes",
                Tooltip = "Send a webhook when Holy successfully snipes a pet.",
                Default = true,
            }
        )

    SuccessfulToggle:OnChanged(function(v)

        WebhookState.NotifySuccessfulSnipe = v

        MarkConfigDirty()
    end)

    local BoothSalesToggle =
        WebhookDependencyBox:AddToggle(
            "WebhookBoothSales",
            {
                Text = "💰 Booth Sales",
                Tooltip = "Send a webhook when one of your booth pets sells.",
                Default = true,
            }
        )

    BoothSalesToggle:OnChanged(function(v)

        WebhookState.NotifyBoothSales = v

        MarkConfigDirty()
    end)

    local ErrorToggle =
        WebhookDependencyBox:AddToggle(
            "WebhookErrors",
            {
                Text = "⚠️ Game Errors",
                Tooltip = "Send a webhook when Holy detects an error, disconnect, or teleport issue.",
                Default = true,
            }
        )

    ErrorToggle:OnChanged(function(v)

        WebhookState.NotifyErrors = v

        MarkConfigDirty()
    end)

    --==================================================
    -- PINGS
    --==================================================

    WebhookDependencyBox:AddDivider({
        Text = "Mentions",
        MarginTop = 10,
        MarginBottom = 8,
    })

    local PingSuccessfulInput =
        WebhookDependencyBox:AddInput(
            "WebhookPingSuccessfulSnipes",
            {
                Text = "📣 Snipe Ping",
                Placeholder = "@everyone | @here | <@userid> | empty = no ping",
                Numeric = false,
                Finished = false,
            }
        )

    PingSuccessfulInput:OnChanged(function(v)

        WebhookState.PingSuccessfulSnipes =
            tostring(v or "")

        MarkConfigDirty()
    end)

    local PingBoothSalesInput =
        WebhookDependencyBox:AddInput(
            "WebhookPingBoothSales",
            {
                Text = "🛒 Booth Sale Ping",
                Placeholder = "@everyone | @here | <@userid> | empty = no ping",
                Numeric = false,
                Finished = false,
            }
        )

    PingBoothSalesInput:OnChanged(function(v)

        WebhookState.PingBoothSales =
            tostring(v or "")

        MarkConfigDirty()
    end)

    local PingErrorsInput =
        WebhookDependencyBox:AddInput(
            "WebhookPingErrors",
            {
                Text = "🚨 Error Ping",
                Placeholder = "@everyone | @here | <@userid> | empty = no ping",
                Numeric = false,
                Finished = false,
            }
        )

    PingErrorsInput:OnChanged(function(v)

        WebhookState.PingErrors =
            tostring(v or "")

        MarkConfigDirty()
    end)

    --==================================================
    -- DELIVERY
    --==================================================

    WebhookDependencyBox:AddDivider({
        Text = "Delivery",
        MarginTop = 10,
        MarginBottom = 8,
    })

    local WebhookInput =
        WebhookDependencyBox:AddInput(
            "WebhookURL",
            {
                Text = "🌐 Webhook URL",
                Placeholder = "Discord webhook URL",
                Numeric = false,
                Finished = true,
            }
        )

    WebhookInput:OnChanged(function(v)

        WebhookState.URL =
            tostring(v or "")

        MarkConfigDirty()
    end)

    WebhookDependencyBox:AddButton({

        Text = "🧪 Test Webhook",

        Func = function()

            if not CanSendWebhook() then

                warn("[Webhook] Invalid configuration")

                HolyNotify(
                    "Webhook Test Failed",
                    "Enable webhook and enter a valid Discord webhook URL.",
                    "triangle-alert",
                    4
                )

                return
            end

            local payload =
                ApplyWebhookPing(
                    {
                        embeds = {{
                            title = "⚡ Holy Webhook Connected",

                            description =
                                "Personal webhook delivery is working.",

                            color = 0xFF4FD8,

                            fields = {
                                {
                                    name = "Account",
                                    value =
                                        "||"
                                        .. tostring(Players.LocalPlayer.Name)
                                        .. "||",
                                    inline = true,
                                },

                                {
                                    name = "Server",
                                    value =
                                        "```lua\n"
                                        .. tostring(game.PlaceId)
                                        .. ":"
                                        .. tostring(game.JobId)
                                        .. "\n```",
                                    inline = false,
                                },
                            },

                            footer = {
                                text = "Holy V2"
                            },

                            timestamp =
                                DateTime.now():ToIsoDate(),
                        }}
                    },
                    WebhookState.PingSuccessfulSnipes
                )

            local queued =
                QueueWebhook(payload)

            if queued then

                print("[Webhook] Test queued")

                HolyNotify(
                    "Webhook Test Queued",
                    "A test webhook has been added to the send queue.",
                    "send",
                    4
                )

            else

                warn("[Webhook] Test failed to queue")

                HolyNotify(
                    "Webhook Test Failed",
                    "Holy could not queue the webhook test.",
                    "triangle-alert",
                    5
                )
            end
        end,
    })
end
--==================================================
-- GLOBAL ERROR / DISCONNECT TELEMETRY
--==================================================

TeleportService =
    game:GetService("TeleportService")

GuiService =
    game:GetService("GuiService")

CoreGui =
    game:GetService("CoreGui")

function SendRuntimeError(title, message)

    warn("[RUNTIME]", title, message)

    if not WebhookState.Enabled
    or not WebhookState.NotifyErrors then
        return
    end

QueueWebhook(
    ApplyWebhookPing(
        {
            embeds = {{
                title = tostring(title),

                description =
                    "```lua\n"
                    .. tostring(message)
                    .. "\n```",

                color = 0xEF4444,

                fields = {

                    {
                        name = "PlaceId",
                        value = tostring(game.PlaceId),
                        inline = true,
                    },

                    {
                        name = "JobId",
                        value = tostring(game.JobId),
                        inline = false,
                    },

                    {
                        name = "Player",
                        value = Players.LocalPlayer.Name,
                        inline = true,
                    },
                },

                footer = {
                    text = "Holy V2 Runtime"
                },

                timestamp =
                    DateTime.now():ToIsoDate(),
            }}
        },
        WebhookState.PingErrors
    )
)
end

--==================================================
-- TELEPORT FAILURES + IMMEDIATE RETRY CONTROLLER
--==================================================

TeleportRetryState = {
    Retrying = false,
    Attempt = 0,
    MaxAttempts = 8,

    LastTarget = nil,
    BlockedServers = {},

    RetryDelay = 0.35,
}

function GetRetryPlaceId()
    if game.PlaceId == TRADING_WORLD_PLACE_ID then
        return TRADING_WORLD_PLACE_ID
    end

    return game.PlaceId
end

function GetFreshRetryServer(placeId)

    local url =
        "https://games.roblox.com/v1/games/"
        .. tostring(placeId)
        .. "/servers/Public?sortOrder=Desc&limit=100"

    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or not body then
        warn("[TeleportRetry] Server fetch failed")
        return nil
    end

    local decoded

    ok, decoded = pcall(function()
        return HttpService:JSONDecode(body)
    end)

    if not ok
    or not decoded
    or type(decoded.data) ~= "table" then
        warn("[TeleportRetry] Decode failed")
        return nil
    end

    local candidates = {}

    for _, server in ipairs(decoded.data) do

        local id =
            server.id

        local playing =
            tonumber(server.playing)

        local maxPlayers =
            tonumber(server.maxPlayers)

        if id
        and playing
        and maxPlayers
        and playing < maxPlayers
        and id ~= game.JobId
        and not TeleportRetryState.BlockedServers[id]
        then
            table.insert(candidates, id)
        end
    end

    if #candidates <= 0 then
        warn("[TeleportRetry] Server pool exhausted → clearing blacklist")

        table.clear(TeleportRetryState.BlockedServers)

        for _, server in ipairs(decoded.data) do

            local id =
                server.id

            local playing =
                tonumber(server.playing)

            local maxPlayers =
                tonumber(server.maxPlayers)

            if id
            and playing
            and maxPlayers
            and playing < maxPlayers
            and id ~= game.JobId
            then
                table.insert(candidates, id)
            end
        end
    end

    if #candidates <= 0 then
        return nil
    end

    return candidates[math.random(1, #candidates)]
end

function ForceRetryTeleport(reason)

    if TeleportRetryState.Retrying then
        return
    end

    TeleportRetryState.Retrying = true
    TeleportRetryState.Attempt = 0

    task.spawn(function()

        local placeId =
            GetRetryPlaceId()

        local player =
            Players.LocalPlayer

        if not player then
            TeleportRetryState.Retrying = false
            return
        end

        -- release any hop locks immediately
        SniperState.Hopping = false
        GatewayBusy = false

        if TeleportRetryState.LastTarget then
            TeleportRetryState.BlockedServers[
                TeleportRetryState.LastTarget
            ] = true
        end

        while TeleportRetryState.Attempt
            < TeleportRetryState.MaxAttempts
        do
            TeleportRetryState.Attempt =
            TeleportRetryState.Attempt + 1

            local target =
                GetFreshRetryServer(placeId)

            if not target then
                warn("[TeleportRetry] No valid target")
                task.wait(1)
                continue
            end

            TeleportRetryState.LastTarget = target
            TeleportRetryState.BlockedServers[target] = true

            print(
                string.format(
                    "[TeleportRetry] Attempt %s/%s → %s | %s",
                    tostring(TeleportRetryState.Attempt),
                    tostring(TeleportRetryState.MaxAttempts),
                    tostring(target),
                    tostring(reason)
                )
            )

            pcall(function()
                TeleportService:TeleportToPlaceInstance(
                    placeId,
                    target,
                    player
                )
            end)

            task.wait(TeleportRetryState.RetryDelay)
        end

        warn("[TeleportRetry] Max attempts reached")

        TeleportRetryState.Retrying = false
    end)
end

TeleportService.TeleportInitFailed:Connect(function(
    player,
    teleportResult,
    errorMessage,
    placeId
)

    local resultName =
        teleportResult
        and teleportResult.Name
        or "Unknown"

    SendRuntimeError(
        "Teleport Failed",
        string.format(
            "Result: %s\nMessage: %s\nTarget PlaceId: %s",
            resultName,
            tostring(errorMessage),
            tostring(placeId)
        )
    )

    warn(
        string.format(
            "[Teleport] Failed → %s | %s",
            tostring(resultName),
            tostring(errorMessage)
        )
    )

    ForceRetryTeleport(resultName)
end)
--==================================================
-- CLIENT DISCONNECT / KICK DETECTION
--==================================================

NetworkClient =
    game:GetService("NetworkClient")

NetworkClient.ChildRemoved:Connect(function(child)

    if child.Name == "ClientReplicator" then

        SendRuntimeError(
            "Disconnected",
            "Lost connection to server / shutdown detected."
        )

        ForceReconnectFromTerminalPrompt(
            "ClientReplicator removed"
        )
    end
end)

--==================================================
-- GUI ERROR DETECTION
-- catches Roblox disconnect / teleport popups
--==================================================
function ForceReconnectFromTerminalPrompt(reason)

    print(
        "[AutoReconnect] Terminal prompt → immediate server retry:",
        tostring(reason)
    )

    RuntimeState.Started =
        false

    SniperState.Hopping =
        false

    GatewayBusy =
        false

    if ReconnectState then
        ReconnectState.Busy =
            false
    end

    if TeleportRetryState then
        TeleportRetryState.Retrying =
            false
    end

    ForceRetryTeleport(
        tostring(reason or "TerminalPrompt")
    )

    return true
end


function TryAutoReconnectFromPrompt(reason)

    if not ReconnectState.AutoReconnect then
        return
    end

    if ReconnectState.Busy then
        return
    end

    local now =
        os.clock()

    ReconnectState.LastAttempt =
    SafeNumber(ReconnectState.LastAttempt, 0)

ReconnectState.Cooldown =
    SafeNumber(ReconnectState.Cooldown, 5)

if now - ReconnectState.LastAttempt < ReconnectState.Cooldown then
    return
end

    ReconnectState.Busy = true
    ReconnectState.LastAttempt = now

    print(
        "[AutoReconnect] Attempting reconnect:",
        tostring(reason)
    )

    task.spawn(function()

        local player =
            Players.LocalPlayer

        if not player then
            ReconnectState.Busy = false
            return
        end

        --==================================================
        -- METHOD 1:
        -- Fire the Roblox Reconnect button safely.
        -- No real mouse click.
        --==================================================

        local clickedReconnect = false

        pcall(function()

            local robloxGui =
                CoreGui:FindFirstChild("RobloxPromptGui")

            if not robloxGui then
                return
            end

            for _, obj in ipairs(robloxGui:GetDescendants()) do

                if obj:IsA("TextButton")
                or obj:IsA("ImageButton") then

                    local text =
                        ""

                    if obj:IsA("TextButton") then
                        text =
                            tostring(obj.Text or ""):lower()
                    end

                    for _, child in ipairs(obj:GetDescendants()) do

                        if child:IsA("TextLabel")
                        or child:IsA("TextButton") then
                            text =
                            text
                            .. " "
                            .. tostring(child.Text or ""):lower()
                        end
                    end

                    if text:find("reconnect", 1, true) then

                        print(
                            "[AutoReconnect] Reconnect button found:",
                            obj:GetFullName()
                        )

                        if getconnections then

                            for _, connection in ipairs(
                                getconnections(obj.Activated)
                            ) do
                                if connection.Enabled ~= false then

                                    local fn =
                                        connection.Function
                                        or connection.func
                                        or connection._function

                                    if type(fn) == "function" then
                                        pcall(fn)
                                        clickedReconnect = true
                                    end
                                end
                            end
                        end

                        if firesignal then
                            pcall(function()
                                firesignal(obj.Activated)
                                clickedReconnect = true
                            end)
                        end

                        pcall(function()
                            obj:Activate()
                            clickedReconnect = true
                        end)

                        break
                    end
                end
            end
        end)

        if clickedReconnect then
            print("[AutoReconnect] Reconnect button activated")

            task.delay(8, function()
                ReconnectState.Busy = false
            end)

            return
        end

        --==================================================
        -- METHOD 2:
        -- Teleport fallback.
        -- For shutdowns, same JobId is dead, so join same place.
        --==================================================

        warn("[AutoReconnect] Reconnect button unavailable, teleport fallback")

        local targetPlaceId =
            game.PlaceId

        if game.PlaceId == TRADING_WORLD_PLACE_ID then
            targetPlaceId = TRADING_WORLD_PLACE_ID
        end

        pcall(function()
            TeleportService:Teleport(
                targetPlaceId,
                player
            )
        end)

        task.delay(8, function()
            ReconnectState.Busy = false
        end)
    end)
end
task.spawn(function()

    local lastPromptText = ""
    local lastPromptAt = 0

    -- Prevents webhook/reconnect spam for terminal Roblox prompts.
    local handledTerminalPrompts = {}

    while IsCurrentRun() do
        task.wait(0.25)

        local robloxGui =
            CoreGui:FindFirstChild("RobloxPromptGui")

        if not robloxGui then
            continue
        end

        local promptOverlay =
            robloxGui:FindFirstChild("promptOverlay")

        if not promptOverlay then
            continue
        end

        local errorPrompt =
            promptOverlay:FindFirstChild("ErrorPrompt")

        if not errorPrompt then
            continue
        end

        local messageArea =
            errorPrompt:FindFirstChild("MessageArea")

        if not messageArea then
            continue
        end

        local errorFrame =
            messageArea:FindFirstChild("ErrorFrame")

        if not errorFrame then
            continue
        end

        local errorMessage =
            errorFrame:FindFirstChild("ErrorMessage")

        if not errorMessage
        or not errorMessage:IsA("TextLabel") then
            continue
        end

        local text =
            tostring(errorMessage.Text)

        if text == "" then
            continue
        end

        local now =
            os.clock()

        if text == lastPromptText
        and now - lastPromptAt < 3 then
            continue
        end

        lastPromptText = text
        lastPromptAt = now

                local lower =
            string.lower(text)

        local isKickPrompt =
            lower:find("error code: 267", 1, true)
            or lower:find("you have been kicked", 1, true)
            or lower:find("moderators", 1, true)

        local isShutdownPrompt =
            lower:find("server has shut down", 1, true)
            or lower:find("error code: 288", 1, true)
            or lower:find("disconnected from the experience", 1, true)

        local isTeleportFailurePrompt =
            lower:find("server is full", 1, true)
            or lower:find("error code: 772", 1, true)
            or lower:find("teleport failed", 1, true)
            or lower:find("please try again", 1, true)

        local terminalPromptKey =
            tostring(text)

        if isKickPrompt
        or isShutdownPrompt
        or isTeleportFailurePrompt then

            if handledTerminalPrompts[terminalPromptKey] then
                continue
            end

            handledTerminalPrompts[terminalPromptKey] =
                true
        end

                local lower =
            string.lower(text)

        local isKickPrompt =
            lower:find("error code: 267", 1, true)
            or lower:find("you have been kicked", 1, true)
            or lower:find("moderators", 1, true)

        local isShutdownPrompt =
            lower:find("server has shut down", 1, true)
            or lower:find("error code: 288", 1, true)
            or lower:find("disconnected from the experience", 1, true)

        local isTeleportFailurePrompt =
            lower:find("server is full", 1, true)
            or lower:find("error code: 772", 1, true)
            or lower:find("teleport failed", 1, true)
            or lower:find("please try again", 1, true)

        SendRuntimeError(
            "Roblox Error Prompt",
            text
        )

        if isKickPrompt then

            warn("[AutoReconnect] Kick / Error 267 prompt detected")

            ForceReconnectFromTerminalPrompt(
                "Kick / Error 267"
            )

        elseif isShutdownPrompt then

            warn("[AutoReconnect] Shutdown / disconnect prompt detected")

            ForceReconnectFromTerminalPrompt(
                "Shutdown / Error 288"
            )

        elseif isTeleportFailurePrompt then

            warn("[TeleportRetry] GUI teleport failure detected")

            SniperState.Hopping =
                false

            GatewayBusy =
                false

            ForceRetryTeleport(
                "GUI ErrorPrompt"
            )
        end
    end
end)
--==================================================
-- SETTINGS / DEV TOOLS UI BUILDER
--==================================================
--==================================================
-- PERFORMANCE MODE
-- Client-side visual reducer for better FPS.
-- Safe: stores original values and can restore them.
--==================================================

PerformanceModeState = {
    Applied = false,
    Original = {},
}

function StoreOriginalPerformanceValue(obj, property, value)

    if not obj then
        return
    end

    PerformanceModeState.Original[obj] =
        PerformanceModeState.Original[obj]
        or {}

    if PerformanceModeState.Original[obj][property] == nil then
        PerformanceModeState.Original[obj][property] = value
    end
end

function ApplyPerformanceMode()

    if PerformanceModeState.Applied then
        return
    end

    PerformanceModeState.Applied = true

    local lighting =
        game:GetService("Lighting")

    --==================================================
    -- LIGHTING
    --==================================================

    StoreOriginalPerformanceValue(
        lighting,
        "GlobalShadows",
        lighting.GlobalShadows
    )

    lighting.GlobalShadows = false

    StoreOriginalPerformanceValue(
        lighting,
        "FogEnd",
        lighting.FogEnd
    )

    lighting.FogEnd = 100000

    for _, obj in ipairs(lighting:GetChildren()) do

        if obj:IsA("PostEffect") then

            StoreOriginalPerformanceValue(
                obj,
                "Enabled",
                obj.Enabled
            )

            obj.Enabled = false
        end
    end

    --==================================================
    -- WORLD VISUALS
    --==================================================

    for _, obj in ipairs(workspace:GetDescendants()) do

        if obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam")
        or obj:IsA("Smoke")
        or obj:IsA("Fire")
        or obj:IsA("Sparkles") then

            StoreOriginalPerformanceValue(
                obj,
                "Enabled",
                obj.Enabled
            )

            obj.Enabled = false
        end

        if obj:IsA("PointLight")
        or obj:IsA("SpotLight")
        or obj:IsA("SurfaceLight") then

            StoreOriginalPerformanceValue(
                obj,
                "Enabled",
                obj.Enabled
            )

            obj.Enabled = false
        end

        if obj:IsA("Decal")
        or obj:IsA("Texture") then

            StoreOriginalPerformanceValue(
                obj,
                "Transparency",
                obj.Transparency
            )

            obj.Transparency = 1
        end

        if obj:IsA("BasePart") then

            StoreOriginalPerformanceValue(
                obj,
                "Material",
                obj.Material
            )

            StoreOriginalPerformanceValue(
                obj,
                "Reflectance",
                obj.Reflectance
            )

            StoreOriginalPerformanceValue(
                obj,
                "CastShadow",
                obj.CastShadow
            )

            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false
        end
    end

    --==================================================
    -- OPTIONAL MAP REMOVALS
    -- Add Dex paths here later.
    -- These are hidden, not destroyed.
    --==================================================

    local function HidePath(path)

        local current =
            workspace

        for part in tostring(path):gmatch("[^%.]+") do

            if part ~= "workspace" then
                current =
                    current and current:FindFirstChild(part)
            end
        end

        if not current then
            return
        end

        for _, obj in ipairs(current:GetDescendants()) do

            if obj:IsA("BasePart") then

                StoreOriginalPerformanceValue(
                    obj,
                    "Transparency",
                    obj.Transparency
                )

                StoreOriginalPerformanceValue(
                    obj,
                    "CanCollide",
                    obj.CanCollide
                )

                StoreOriginalPerformanceValue(
                    obj,
                    "CastShadow",
                    obj.CastShadow
                )

                obj.Transparency = 1
                obj.CanCollide = false
                obj.CastShadow = false
            end

            if obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Beam") then

                StoreOriginalPerformanceValue(
                    obj,
                    "Enabled",
                    obj.Enabled
                )

                obj.Enabled = false
            end
        end
    end

    -- Add specific Dex paths here later:
    -- HidePath("workspace.TradeWorld.SomeLaggyModel")
    -- HidePath("workspace.TradeWorld.Decorations")
    -- HidePath("workspace.TradeWorld.Effects")
local PerformanceHidePaths = {
    "workspace.Visuals",
    "workspace.WeatherVisuals",
    "workspace.Water_Effect",
    "workspace.WeatherObjects",
    "workspace.TradeWorld.PortalPetePlatform",
}

for _, path in ipairs(PerformanceHidePaths) do
    HidePath(path)
end

    HolyNotify(
        "Performance Mode Enabled",
        "Extra visuals were reduced to improve FPS.",
        "zap",
        4
    )
end

function RestorePerformanceMode()

    for obj, properties in pairs(PerformanceModeState.Original) do

        if obj and obj.Parent then

            for property, value in pairs(properties) do

                pcall(function()
                    obj[property] = value
                end)
            end
        end
    end

    table.clear(
        PerformanceModeState.Original
    )

    PerformanceModeState.Applied = false

    HolyNotify(
        "Performance Mode Disabled",
        "Visual settings were restored.",
        "refresh-cw",
        4
    )
end

function SetPerformanceMode(enabled)

    UIState.PerformanceMode =
        enabled == true

    if UIState.PerformanceMode then
        ApplyPerformanceMode()
    else
        RestorePerformanceMode()
    end
end

function BuildSettingsTab()

local SettingsBox =
    Tabs.Settings:AddLeftGroupbox(
        "Settings",
        "settings"
    )

local DevBox =
    Tabs.Settings:AddRightGroupbox(
        "Dev Tools",
        "terminal"
    )
--==================================================
-- SAFE LOADER (REUSED)
--==================================================
local function SafeExec(url)
    local ok, src = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not ok or type(src) ~= "string" or #src < 100 then
        warn("[DevTools] HTTP failed:", url)
        return
    end

    local fn, compileErr = loadstring(src)
    if not fn then
        warn("[DevTools] Compile failed:", compileErr)
        return
    end

    local okRun, runtimeErr = pcall(fn)
    if not okRun then
        warn("[DevTools] Runtime failed:", runtimeErr)
        return
    end
end
--==================================================
-- UI DPI SCALE
-- Controls Obsidian library scale.
-- 90% = normal size.
--==================================================

local function ResolveDPIScaleDropdownDefault()

    local scale =
        math.clamp(
            math.floor(SafeNumber(UIState.DPIScale, 100) + 0.5),
            50,
            150
        )

    local allowed = {
        50,
        75,
        90,
        100,
        110,
        125,
        150,
    }

    local closestIndex = 4
    local closestDistance = math.huge

    for index, value in ipairs(allowed) do

        local distance =
            math.abs(scale - value)

        if distance < closestDistance then
            closestDistance = distance
            closestIndex = index
        end
    end

    return closestIndex
end

local DPIScaleDropdown =
    SettingsBox:AddDropdown(
        "HolyDPIScale",
        {
            Text = "UI Scale",
            Tooltip = "Adjusts the size of the Holy interface.",
            Values = {
                "50%",
                "75%",
                "90%",
                "100%",
                "110%",
                "125%",
                "150%",
            },
            Default = ResolveDPIScaleDropdownDefault(),
            Searchable = false,
        }
    )

DPIScaleDropdown:OnChanged(function(value)

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
            50,
            150
        )

    UIState.DPIScale =
        scale

    if Library
    and type(Library.SetDPIScale) == "function" then

        pcall(function()
            Library:SetDPIScale(scale)
        end)
    end

    MarkConfigDirty()

    if ConfigState.IsHydrating then
        return
    end

    HolyNotify(
        "UI Scale Updated",
        "Holy UI scale set to "
            .. tostring(scale)
            .. "%.",
        "maximize",
        3
    )
end)
local PerformanceModeToggle =
    SettingsBox:AddToggle(
        "PerformanceMode",
        {
            Text = "Performance Mode",
            Tooltip = "Removes extra visual effects client-side to improve FPS. Safe for AFK/sniping.",
            Default = false,
        }
    )

PerformanceModeToggle:OnChanged(function(enabled)

    UIState.PerformanceMode =
        enabled == true

    MarkConfigDirty()

    if ConfigState.IsHydrating then
        return
    end

    SetPerformanceMode(enabled)
end)

--==================================================
-- LATENCY GUARD
-- Adaptive Buy Wait changes only the post-buy
-- inventory confirmation wait. Ping still shows
-- in Sniper Monitor whenever Sniper Monitor is enabled.
--==================================================

SettingsBox:AddDivider({
    Text = "Latency Guard",
    MarginTop = 10,
    MarginBottom = 8,
})

local AdaptiveBuyWaitToggle =
    SettingsBox:AddToggle(
        "AdaptiveBuyWait",
        {
            Text = "Adaptive Buy Wait",
            Tooltip = "Adjusts inventory confirmation wait based on ping. The buy itself still fires instantly.",
            Default = false,
        }
    )

AdaptiveBuyWaitToggle:OnChanged(function(enabled)

    LatencyGuard.AdaptiveBuyWait =
        enabled == true

    MarkConfigDirty()

    if type(RefreshSniperMonitorHUD) == "function" then
        pcall(RefreshSniperMonitorHUD)
    end

    if ConfigState.IsHydrating then
        return
    end

    if enabled then

        HolyNotify(
            "Latency Guard Enabled",
            "Adaptive Buy Wait is now active.",
            "wifi",
            3
        )

    else

        HolyNotify(
            "Latency Guard Disabled",
            "Using normal fixed buy wait.",
            "wifi-off",
            3
        )
    end
end)
--==================================================
-- AUTO CLOSE UI
-- Saves preference only during config hydration.
-- Actually closes only after boot is complete.
--==================================================

function RequestHolyAutoClose(reason)
    UIState.PendingAutoClose =
        true

    UIState.PendingAutoCloseReason =
        tostring(reason or "Auto Close UI")
end

function CloseHolyWindowSafe()
    if not Library then
        return false
    end

    -- Do not close while the loading screen is still running.
    if ScriptState
    and ScriptState.BootComplete ~= true then
        RequestHolyAutoClose("waiting for boot complete")
        return false
    end

    local ok = false

    -- Preferred: use library toggle key behavior only once after boot.
    if type(Library.Toggle) == "function" then
        ok =
            pcall(function()
                Library:Toggle()
            end)

        return ok
    end

    if Window and type(Window.Hide) == "function" then
        ok =
            pcall(function()
                Window:Hide()
            end)

        return ok
    end

    if Window and type(Window.SetVisible) == "function" then
        ok =
            pcall(function()
                Window:SetVisible(false)
            end)

        return ok
    end

    return false
end

local UIToggle = SettingsBox:AddToggle("AutoMinimizeUI", {
    Text = "Auto Close UI",
    Tooltip = "Closes the Holy UI after loading finishes. Reopen with LeftAlt.",
    Default = false,
})

UIToggle:OnChanged(function(enabled)

    UIState.AutoMinimize =
        enabled == true

    MarkConfigDirty()

    if ConfigState.IsHydrating then
        return
    end

    if enabled == true then
        RequestHolyAutoClose("toggle enabled")

        task.defer(function()
            task.wait(0.25)
            CloseHolyWindowSafe()
        end)
    end
end)

local TradeWorldToggle = SettingsBox:AddToggle("Auto Trade World", {
    Text = "Auto Teleport Trade World",
    Default = false,
})

TradeWorldToggle:OnChanged(function(enabled)

    WorldState.AutoJoinTradeWorld =
        enabled == true

    MarkConfigDirty()

    TradeWorldToggle:OnChanged(function(enabled)

    WorldState.AutoJoinTradeWorld =
        enabled == true

    MarkConfigDirty()

    if ConfigState.IsHydrating then
        return
    end

    if enabled ~= true then

        CancelScheduledTradeWorldJoin()

        HolyNotify(
            "Auto Teleport Disabled",
            "Pending Trade World teleport cancelled.",
            "x",
            3
        )

        return
    end

    if not IsTradeWorld() then

        ScheduleJoinTradeWorld(
            "Auto Teleport Trade World enabled."
        )
    end
end)

    if not IsTradeWorld() then

        ScheduleJoinTradeWorld(
            "Auto Teleport Trade World enabled."
        )
    end
end)

task.spawn(function()

    task.wait(2)

    if WorldState.AutoJoinTradeWorld == true
    and not IsTradeWorld() then

        ScheduleJoinTradeWorld(
            "Auto Teleport Trade World restored from config."
        )
    end
end)

local AutoReconnectToggle = SettingsBox:AddToggle("AutoReconnect", {
    Text = "Auto Reconnect",
    Tooltip = "Automatically reconnects when Roblox shows a disconnect / shutdown prompt",
    Default = false,
})

AutoReconnectToggle:OnChanged(function(enabled)
    ReconnectState.AutoReconnect = enabled
    MarkConfigDirty()
end)
--==================================================
-- REMOTE SPY
--==================================================
DevBox:AddButton({
    Text = "Open Remote Spy",
    Tooltip = "",
    Func = function()
        if ScriptState.ForceStopped then
            warn("[DevTools] Blocked (ForceStopped)")
            return
        end

        SafeExec("https://raw.githubusercontent.com/Klinac/scripts/main/utopia_spy.lua")
    end,
})

--==================================================
-- DEX EXPLORER
--==================================================
DevBox:AddButton({
    Text = "Open Dex Explorer",
    Tooltip = "",
    Func = function()
        if ScriptState.ForceStopped then
            warn("[DevTools] Blocked (ForceStopped)")
            return
        end

        SafeExec("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua")
    end,
})
end

--==================================================
-- CONFIG WRITE GATE
-- SaveManager only knows options that currently exist.
-- In Garden Mode, Trade World tabs/options are not built,
-- so saving would overwrite autosave with a partial config.
--==================================================

function CanWriteFullHolyConfig()

    return IsTradeWorld() == true
end
--==================================================
-- SAVE / CONFIG BOOTSTRAP
-- Isolated so obfuscators do not overload main-scope locals.
--==================================================

function InitializeSaveAndConfig()
--==================================================
-- [8] SETTINGS (MINIMAL)
--==================================================
SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)

SaveManager:SetFolder("HolyV2")
ThemeManager:SetFolder("HolyV2")

ThemeManager:ApplyTheme("Dark")

--==================================================
-- SAVE MANAGER SETUP
--==================================================
SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({})

--==================================================
-- BUILD UI
--==================================================


-- Autosave worker
task.spawn(function()
    while IsCurrentRun() do
        task.wait(0.25)

        if not ConfigState.Dirty then
            continue
        end

        -- debounce window
        ConfigState.LastMutation =
            SafeNumber(ConfigState.LastMutation, 0)

        if SafeElapsed(ConfigState.LastMutation) < 0.5 then
            continue
        end

ConfigState.Dirty = false

if not CanWriteFullHolyConfig() then

    print(
        "[Config] Autosave skipped in Garden Mode to protect Trade World settings"
    )

    continue
end

local ok, err = pcall(function()
    SaveManager:Save(ConfigState.AutosaveName)
end)

if ok then

    HolyNotify(
        "Config Saved",
        "Your Holy settings were autosaved.",
        "save",
        3
    )

else

    warn("[Config] Autosave failed:", err)
end
    end
end)
--==================================================
-- LOAD AUTOCONFIG
--==================================================
ConfigState.IsHydrating = true

local ok, err = pcall(function()
    SaveManager:Load(ConfigState.AutosaveName)
end)

ConfigState.IsHydrating = false

UIState.DPIScale =
    SafeNumber(UIState.DPIScale, 100)

UIState.DPIScale =
    math.clamp(
        math.floor(UIState.DPIScale + 0.5),
        50,
        150
    )

if Library
and type(Library.SetDPIScale) == "function" then

    pcall(function()
        Library:SetDPIScale(UIState.DPIScale)
    end)
end

UIState.PerformanceMode =
    UIState.PerformanceMode == true

if UIState.PerformanceMode then
    task.spawn(function()
        task.wait(1)
        SetPerformanceMode(true)
    end)
end

if not ok then

    warn("[Config] Corrupted config detected:", err)

    if CanWriteFullHolyConfig() then

        pcall(function()
            SaveManager:Save(ConfigState.AutosaveName)
        end)

        warn("[Config] Autosave reset complete")

    else

        warn(
            "[Config] Reset skipped in Garden Mode to protect Trade World settings"
        )
    end

else

    print("[Config] Autoload complete")
end

LoadSniperFilters()

if type(LoadListingFilters) == "function" then
    LoadListingFilters()
end

if IsTradeWorld()
and type(RefreshWatchlist) == "function" then
    RefreshWatchlist()
end

if type(SyncListingRequiredFlagsFromValues) == "function" then
    SyncListingRequiredFlagsFromValues()
end


if IsTradeWorld() then

    --==================================================
    -- LISTINGS RESTORE AFTER UI OPTIONS EXIST
    -- Wait for EnableAutoList to exist before deciding
    -- whether AutoList should restore ON or stay OFF.
    --==================================================

    task.spawn(function()

        local startedAt =
            os.clock()

        while os.clock() - startedAt < 10 do

            if Library
            and Library.Options
            and Library.Options.EnableAutoList then
                break
            end

            task.wait(0.15)
        end

        task.wait(0.75)

        if ScriptState
        and ScriptState.ForceStopped then
            return
        end

        if type(RefreshListingInventorySnapshot) == "function" then
            pcall(RefreshListingInventorySnapshot)
        end

        if type(BuildListingPreview) == "function" then
            pcall(BuildListingPreview)
        end

        if type(RefreshListingFilterUI) == "function" then
            pcall(RefreshListingFilterUI)
        end

        if type(ListingsStatusRefresh) == "function" then
            pcall(ListingsStatusRefresh)
        end

        if type(ArmListingsAutostartFromSavedToggle) == "function" then

            local okRestore, restoreErr =
                pcall(ArmListingsAutostartFromSavedToggle)

            if not okRestore then
                warn(
                    "[LISTINGS] AutoList restore failed:",
                    tostring(restoreErr)
                )
            end

        else

            warn(
                "[LISTINGS] ArmListingsAutostartFromSavedToggle missing at config restore"
            )
        end

        if type(RefreshEggFocus) == "function" then
            pcall(RefreshEggFocus)
        end
    end)
end

--==================================================
-- RESTORE AUTO TELEPORT STATE
--==================================================

task.spawn(function()

    if not BoothAuto.AutoTeleport then
        return
    end

    if game.PlaceId ~= TRADING_WORLD_PLACE_ID then
        return
    end

    local playerId =
        tostring(Players.LocalPlayer.UserId)

    local timeout = os.clock() + 15

    while os.clock() < timeout do

        local data = LatestBoothData

        if data and data.Booths then

            for _, booth in pairs(data.Booths) do

                if booth.Owner
                and tostring(booth.Owner):find(playerId)
                then

                    print(
                        "[BOOT] Restoring booth auto teleport"
                    )

                    local character =
                        Players.LocalPlayer.Character
                        or Players.LocalPlayer.CharacterAdded:Wait()

                    local humanoid =
                        character:FindFirstChildOfClass("Humanoid")

                    if not BoothAuto.LockBehindBooth then
    RestoreCharacterMovement()
end

task.wait(0.5)

local success =
    PositionBehindOwnedBooth()

                    if not success then
                        warn(
                            "[BOOT] Booth restore failed"
                        )
                    end

                    return
                end
            end
        end

        task.wait(0.25)
    end

end)

end
--==================================================
-- [9] RUNTIME LOOP (EMPTY, DETERMINISTIC)
--==================================================
function MainLoop()
    while IsCurrentRun() do
        task.wait(0.1)

        if ScriptState.ForceStopped then
            continue
        end

        --==================================================
-- LISTINGS LOOP
-- Independent from sniper activation.
-- Controlled only by EnableAutoList.
--==================================================

if ListingsState
and ListingsState.Enabled then

    if game.PlaceId ~= TRADING_WORLD_PLACE_ID then

        ListingsState.Status =
            "Not in Trade World"

    else

        local now =
            os.clock()

        ListingsState.NoWorkSleepUntil =
            SafeNumber(
                ListingsState.NoWorkSleepUntil,
                0
            )

        ListingsState.LastScan =
            SafeNumber(
                ListingsState.LastScan,
                0
            )

        ListingsState.ScanInterval =
            SafeNumber(
                ListingsState.ScanInterval,
                6
            )

        if now >= ListingsState.NoWorkSleepUntil then

            local elapsed =
                now - ListingsState.LastScan

            if elapsed >= ListingsState.ScanInterval then

                ListingsState.LastScan =
                    os.clock()

                pcall(function()
                    RunAutoListingPass()
                end)

                if type(ListingsStatusRefresh) == "function" then
                    pcall(ListingsStatusRefresh)
                end
            end
        end
    end
end

        if not RuntimeState.Started then
            continue
        end

--==================================================
-- SNIPER SCAN
--==================================================

if game.PlaceId == TRADING_WORLD_PLACE_ID then

    SniperState.LastScan =
        SafeNumber(SniperState.LastScan, 0)

    local elapsed =
        SafeElapsed(SniperState.LastScan)

    if elapsed >= SniperState.ScanInterval then

        -- prevent overlapping scans
        if not SniperState.Scanning
        and not SniperState.Hopping then

    RunSniperScan()
        end
    end
end

    end
end

--==================================================
-- ANTI AFK
--==================================================

LocalPlayer =
    Players.LocalPlayer

LocalPlayer.Idled:Connect(function()

    pcall(function()

        VirtualUser:CaptureController()

        VirtualUser:ClickButton2(
            Vector2.new(0, 0)
        )

    end)

end)

--==================================================
-- AUTO EQUIP SHOWCASE PET
--==================================================

function EquipShowcasePet(force)

    if not IsTradeWorld() then
        return
    end

    if not BoothPetState.Enabled then
        return
    end

    local targetPet =
        BoothPetState.SelectedPetType

    if not targetPet
    or targetPet == "" then
        return
    end

    local now =
        os.clock()

    if not force then

        local elapsed =
            now - SafeNumber(
                BoothPetState.LastEquipAttemptAt,
                0
            )

        if elapsed < SafeNumber(BoothPetState.EquipCooldown, 1.5) then
            return
        end
    end

    BoothPetState.LastEquipAttemptAt =
        now

    local bestPet =
        ResolveBestPet(targetPet)

    if not bestPet then

        BoothPetState.LastEquippedUID =
            nil

        BoothPetState.LockedShowcaseUID =
            nil

        if ShouldWarnMissingShowcasePet(targetPet) then
            warn(
                "[BoothPet] No matching pet:",
                targetPet
            )
        end

        return
    end

    BoothPetState.LastMissingPet =
        nil

    -- Lock onto this exact pet until it disappears or user changes selection.
    if not BoothPetState.LockedShowcaseUID then
        BoothPetState.LockedShowcaseUID =
            bestPet.UID
    end

    -- Already holding the selected showcase pet.
    if IsToolCurrentlyEquipped(bestPet.Tool) then

        BoothPetState.LastEquippedUID =
            bestPet.UID

        BoothPetState.LockedShowcaseUID =
            bestPet.UID

        return
    end

    if not force
    and BoothPetState.LastEquippedUID == bestPet.UID then
        return
    end

    local character =
        Players.LocalPlayer.Character

    if not character then
        return
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    if not humanoid
    or humanoid.Health <= 0 then
        return
    end

    BoothPetState.LastEquippedUID =
        bestPet.UID

    BoothPetState.LockedShowcaseUID =
        bestPet.UID

    print(
        string.format(
            "[BoothPet] Equipping → %s | %.2f KG | UID %s",
            tostring(bestPet.PetName),
            tonumber(bestPet.Weight) or 0,
            tostring(bestPet.UID)
        )
    )

    humanoid:EquipTool(bestPet.Tool)
end
--==================================================
-- [10] LIFECYCLE START
--==================================================
ScriptState.Loaded = true

AutoServerHopWorker = function()
    while IsCurrentRun() do
        task.wait(1)

        if ScriptState.ForceStopped then
            continue
        end

        if not BoothAuto.AutoServerHop then
            continue
        end

                BoothAuto.LastServerHop =
            SafeNumber(BoothAuto.LastServerHop, 0)

        BoothAuto.ServerHopMinutes =
            SafeNumber(BoothAuto.ServerHopMinutes, 10)

        local elapsed =
            SafeElapsed(BoothAuto.LastServerHop)

        local targetSeconds =
            BoothAuto.ServerHopMinutes * 60
        if elapsed < targetSeconds then
            continue
        end

        BoothAuto.LastServerHop = os.clock()

        print("[Hop] Auto joining new server")

        local TeleportService =
    game:GetService("TeleportService")
        local player = Players.LocalPlayer

        if not player then
            continue
        end

        local url =
            "https://games.roblox.com/v1/games/"
            .. game.PlaceId
            .. "/servers/Public?sortOrder=Desc&limit=100"

        local ok, body = pcall(function()
            return game:HttpGet(url)
        end)

        if not ok or not body then
            warn("[Hop] Server fetch failed")
            continue
        end

        local decoded

        ok, decoded = pcall(function()
            return HttpService:JSONDecode(body)
        end)

        if not ok or not decoded or not decoded.data then
            warn("[Hop] Decode failed")
            continue
        end

        local servers = {}

        for _, server in ipairs(decoded.data) do
            if server.id
                and server.playing
                and server.maxPlayers
                and server.playing < server.maxPlayers
                and server.id ~= game.JobId
            then
                table.insert(servers, server.id)
            end
        end

        if #servers == 0 then
            warn("[Hop] No servers available")
            continue
        end

        local target =
            servers[math.random(#servers)]

        pcall(function()
            TeleportService:TeleportToPlaceInstance(
                game.PlaceId,
                target,
                player
            )
        end)
    end
end
--==================================================
-- CUSTOMIZE TRADE PLAZA BUTTONS
--==================================================

task.spawn(function()
    task.wait(3)

    local playerGui =
        Players.LocalPlayer:WaitForChild("PlayerGui")

    local tradePlaza =
        playerGui
        :WaitForChild("Teleport_UI")
        :WaitForChild("TradePlaza")

    local buttons = {
        "Booth",
        "Index",
        "Tokens"
    }

    for _, name in ipairs(buttons) do
        local button =
            tradePlaza:FindFirstChild(name)

        if button then

            --==================================================
            -- MAIN BUTTON SIZE
            --==================================================

            button.Size = UDim2.new(
                0,
                70, -- width
                0,
                28  -- height
            )

            --==================================================
            -- POSITION OFFSET (OPTIONAL)
            --==================================================

            button.Position = button.Position + UDim2.new(
                0,
                0,
                0,
                -10
            )

            --==================================================
            -- BACKGROUND
            --==================================================

            button.BackgroundTransparency = 0.2

            --==================================================
            -- CORNERS
            --==================================================

            local corner =
                button:FindFirstChildOfClass("UICorner")

            if corner then
                corner.CornerRadius = UDim.new(0, 6)
            end
--==================================================
-- TEXT
--==================================================

local title =
    button:FindFirstChild("Title")

if title and title:IsA("TextLabel") then

    title.TextScaled = true
    title.TextWrapped = false

    title.Size = UDim2.new(
        1,
        -4,
        1,
        -2
    )

    title.Position = UDim2.new(
        0,
        2,
        0,
        0
    )

    title.AnchorPoint = Vector2.new(0, 0)

    title.BackgroundTransparency = 1

    title.TextXAlignment =
        Enum.TextXAlignment.Center

    title.TextYAlignment =
        Enum.TextYAlignment.Center

    title.Font = Enum.Font.GothamBold

    title.TextStrokeTransparency = 0.5
end
            --==================================================
            -- ICONS
            --==================================================

            for _, obj in ipairs(button:GetDescendants()) do
                if obj:IsA("ImageLabel")
                or obj:IsA("ImageButton") then

                    obj.Size = UDim2.new(
                        0,
                        16,
                        0,
                        16
                    )
                end
            end
        end
    end
end)


task.spawn(function()

    task.wait(2)

    local playerGui =
        Players.LocalPlayer:WaitForChild("PlayerGui")

    local sideBtns =
        playerGui
        :WaitForChild("Hud_UI")
        :WaitForChild("SideBtns")

    local buttons = {
        "Shop",
        "Trade"
    }

    for _, name in ipairs(buttons) do

        local button =
            sideBtns:FindFirstChild(name)

        if not button then
            continue
        end

        button.Size = UDim2.new(
            0,
            50,
            0,
            26
        )
    end
end)

--==================================================
-- REMOVE EVENT NOTIFY (PERSISTENT)
--==================================================

task.spawn(function()
    while IsCurrentRun() do
        task.wait(0.5)

        local playerGui =
            Players.LocalPlayer:FindFirstChild("PlayerGui")

        if not playerGui then
            continue
        end

        local topbar =
            playerGui:FindFirstChild("TopbarStandard")

        if not topbar then
            continue
        end

        local holders =
            topbar:FindFirstChild("Holders")

        if not holders then
            continue
        end

        local right =
            holders:FindFirstChild("Right")

        if not right then
            continue
        end

        local notify =
            right:FindFirstChild("EVENT NOTIFY")

        if notify then
            notify.Visible = false
            notify:Destroy()

            print("[UI] EVENT NOTIFY removed")
        end
    end
end)
task.spawn(function()

    while IsCurrentRun() do
        task.wait(0.25)

        if ScriptState.ForceStopped then
            continue
        end

        if not IsTradeWorld() then
    continue
end

if not BeeEggAuto.Enabled then
    continue
end

pcall(function()
    TryBuyBeeEgg()
end)
    end
end)
task.spawn(AutoServerHopWorker)
task.spawn(BoothPositionWatchdog)

--==================================================
-- AUTO EQUIP WORKER
-- Event-driven post-snipe showcase re-equip
--==================================================

task.spawn(function()

    while IsCurrentRun() do
        task.wait(0.15)

        if ScriptState.ForceStopped then
            continue
        end

if not IsTradeWorld() then

    if BoothPetState.Enabled
    or ShowcaseEquipState.ReequipPending
    or ShowcaseEquipState.Attempting then

        BoothPetState.Enabled =
            false

        BoothPetState.LastEquippedUID =
            nil

        ShowcaseEquipState.ReequipPending =
            false

        ShowcaseEquipState.Attempting =
            false

        ShowcaseEquipState.InventoryConfirmedAt =
            0
    end

    continue
end
        --==================================================
        -- NORMAL MAINTENANCE EQUIP
        -- Keeps selected showcase pet equipped during idle
        --==================================================

        -- Do not auto re-equip showcase pet during post-snipe delay window
if not ShowcaseEquipState.ReequipPending
and not ShowcaseEquipState.Attempting then
    pcall(EquipShowcasePet)
end

        --==================================================
        -- POST-SNIPE RE-EQUIP
        -- Runs 10 after inventory confirmation
        --==================================================

        if not ShowcaseEquipState.ReequipPending then
            continue
        end

        if ShowcaseEquipState.Attempting then
            continue
        end

        if not BoothPetState.Enabled then
            ShowcaseEquipState.ReequipPending = false
            continue
        end

        local targetPet =
            BoothPetState.SelectedPetType

        if not targetPet
        or targetPet == "" then
            ShowcaseEquipState.ReequipPending = false
            continue
        end

        ShowcaseEquipState.InventoryConfirmedAt =
            SafeNumber(ShowcaseEquipState.InventoryConfirmedAt, 0)

        local elapsed =
            SafeElapsed(ShowcaseEquipState.InventoryConfirmedAt)

        if elapsed < ShowcaseEquipState.ReequipDelay then
            continue
        end

        ShowcaseEquipState.ReequipPending = false
        ShowcaseEquipState.Attempting = true

        local requestId =
            ShowcaseEquipState.RequestId

        task.spawn(function()

            print(
                string.format(
                    "[BoothPet] Post-snipe re-equip → %s",
                    tostring(targetPet)
                )
            )

            pcall(function()

                --==================================================
                -- FORCE EQUIP BURST
                -- This wins against purchase/tool replication swaps
                --==================================================

                for i = 1, 5 do

                    if ScriptState.ForceStopped then
                        break
                    end

                    if requestId ~= ShowcaseEquipState.RequestId then
                        break
                    end

                    EquipShowcasePet(true)

                    task.wait(0.2)
                end
            end)

            ShowcaseEquipState.Attempting = false
        end)
    end
end)
--==================================================
-- AUTO PROMOTE WORKER
-- Trade World only.
--==================================================

if IsTradeWorld() then

    StartWorker("AutoPromoteWorker", function()

        while IsCurrentRun() do
            task.wait(3)

            if ScriptState.ForceStopped then
                continue
            end

            if not IsTradeWorld() then
                continue
            end

            pcall(function()
                SendPromoteMessage()
            end)
        end
    end)
end

--==================================================
-- UI BUILD
-- Keep original tab order.
-- Build real systems only in Trade World.
--==================================================

BuildHomeTab()

if IsTradeWorld() then

    BuildBoothTab()
    BuildSniperTab()
    BuildListingsTab()

else

    BuildGardenModeTradeTabs()

    RuntimeState.Started =
        false

    SniperState.AutoHop =
        false

    BoothAuto.Enabled =
        false

    BoothAuto.AutoTeleport =
        false

    BoothPetState.Enabled =
        false

    BeeEggAuto.Enabled =
        false

    ListingsState.Enabled =
        false

    ListingsState.VisualTagsEnabled =
        false

    ListingsState.Status =
        "Garden Mode"

    print(
        "[BOOT] Garden mode active - Trade World logic disabled"
    )
end

BuildWebhookTab()
BuildSettingsTab()
BuildVisualTab()

if IsTradeWorld() then
    StartListingWorker()
end
--==================================================
-- LISTINGS WORKER START
--==================================================

HolyLoading:SetCurrentStep(4)
HolyLoading:SetDescription("Loading saved configuration...")

local configOk, configErr =
    pcall(function()
        InitializeSaveAndConfig()
    end)

if not configOk then
    warn(
        "[CONFIG] InitializeSaveAndConfig failed:",
        tostring(configErr)
    )

    HolyNotify(
        "Config Load Failed",
        "Holy skipped saved config because it errored. Check console.",
        "triangle-alert",
        5
    )
end

HolyLoading:SetCurrentStep(5)
HolyLoading:SetDescription("Starting workers...")

--==================================================
-- SAFE HUD STARTUP
-- Garden Mode may not build every Trade World UI/HUD.
-- Only call constructors that actually exist.
--==================================================

if type(CreateWatchlistHUD) == "function" then

    pcall(CreateWatchlistHUD)

    if WatchlistHUDGui then
        WatchlistHUDGui.Enabled =
            VisualState.WatchlistHUD == true
    end

    if type(RefreshWatchlistHUD) == "function" then
        pcall(RefreshWatchlistHUD)
    end
end

if type(CreateServerInfoHUD) == "function" then

    pcall(CreateServerInfoHUD)

    if ServerInfoHUDGui then
        ServerInfoHUDGui.Enabled =
            VisualState.ServerInfoHUD == true
    end

    if type(RefreshServerInfoHUD) == "function" then
        pcall(RefreshServerInfoHUD)
    end
end

if IsTradeWorld()
and type(CreateSniperMonitorHUD) == "function" then

    pcall(CreateSniperMonitorHUD)

    if SniperMonitorHUDGui then
        SniperMonitorHUDGui.Enabled =
            VisualState.SniperMonitorHUD == true
    end

    if type(RefreshSniperMonitorHUD) == "function" then
        pcall(RefreshSniperMonitorHUD)
    end
end

task.spawn(function()

    while IsCurrentRun() do
        task.wait(0.25)

        pcall(function()

    if type(RefreshServerInfoHUD) == "function" then
        RefreshServerInfoHUD()
    end

    if IsTradeWorld()
    and type(RefreshSniperMonitorHUD) == "function" then
        RefreshSniperMonitorHUD()
    end
end)
    end
end)

--==================================================
-- LISTINGS STATUS REFRESH LOOP
-- Keeps Listings tab counters current even when
-- no listing action is currently happening.
--==================================================

task.spawn(function()

    local lastErrorAt =
        0

    while IsCurrentRun() do

        task.wait(2)

        if ScriptState.ForceStopped then
            continue
        end

        if not IsTradeWorld() then
            continue
        end

        local ok, err =
            pcall(function()

                if type(BuildListingPreview) == "function" then
                    BuildListingPreview()
                end

                if type(ListingsStatusRefresh) == "function" then
                    ListingsStatusRefresh()
                end

            end)

        if not ok then

            local now =
                os.clock()

            if now - lastErrorAt > 10 then

                lastErrorAt =
                    now

                warn(
                    "[LISTINGS STATUS] Refresh failed:",
                    tostring(err)
                )
            end
        end
    end
end)

--==================================================
-- LISTINGS INVENTORY EVENT REFRESH
-- Updates Listings preview when Backpack/Character changes.
-- This avoids heavy constant inventory scans.
--==================================================

do
    local function ScheduleListingInventoryRefresh()

    if not IsTradeWorld() then
        return
    end

    task.defer(function()

            pcall(function()

                if type(RefreshListingInventorySnapshot) == "function" then
                    RefreshListingInventorySnapshot()
                end

                if type(BuildListingPreview) == "function" then
                    BuildListingPreview()
                end

                if type(ListingsStatusRefresh) == "function" then
                    ListingsStatusRefresh()
                end
            end)
        end)
    end

    local player =
        Players.LocalPlayer

    if player then

        local backpack =
            player:FindFirstChild("Backpack")

        if backpack then

            backpack.ChildAdded:Connect(function()
                ScheduleListingInventoryRefresh()
            end)

            backpack.ChildRemoved:Connect(function()
                ScheduleListingInventoryRefresh()
            end)
        end

        if player.Character then

            player.Character.ChildAdded:Connect(function()
                ScheduleListingInventoryRefresh()
            end)

            player.Character.ChildRemoved:Connect(function()
                ScheduleListingInventoryRefresh()
            end)
        end

        player.CharacterAdded:Connect(function(character)

            task.wait(1)

            character.ChildAdded:Connect(function()
                ScheduleListingInventoryRefresh()
            end)

            character.ChildRemoved:Connect(function()
                ScheduleListingInventoryRefresh()
            end)

            ScheduleListingInventoryRefresh()
        end)
    end
end
--==================================================
-- AUTO PLAY SCREEN ACTIVATOR - REAL INPUT PATH
-- Purpose:
-- Automatically passes Grow a Garden's "Click Anywhere to Play"
-- screen by sending the same input the player would manually send.
--
-- Important:
-- Do NOT destroy LoadingGui.
-- Do NOT hide LoadingGui before the click.
-- The game needs the local click path to unlock camera/player state.
--==================================================

AutoPlayState = {
    Started = false,
    Finished = false,
    LastClick = 0,
    Attempts = 0,
}

function GetLoadingGui()

    local player =
        Players.LocalPlayer

    if not player then
        return nil
    end

    local playerGui =
        player:FindFirstChild("PlayerGui")

    if not playerGui then
        return nil
    end

    return playerGui:FindFirstChild("LoadingGui")
end

function IsLoadingPlayScreenVisible()

    local loadingGui =
        GetLoadingGui()

    if not loadingGui then
        return false
    end

    if loadingGui:IsA("ScreenGui")
    and loadingGui.Enabled == false then
        return false
    end

    for _, obj in ipairs(loadingGui:GetDescendants()) do

        if obj:IsA("TextLabel")
        or obj:IsA("TextButton") then

            local text =
                tostring(obj.Text or ""):lower()

            if text:find("click anywhere", 1, true)
            or text:find("tap anywhere", 1, true)
            or text:find("press any", 1, true)
            or text:find("play", 1, true) then
                return true
            end
        end
    end

    -- If LoadingGui exists but text is not found, still treat it as active.
    return true
end

function SendLoadingScreenClick()

    local VirtualInputManager =
        game:GetService("VirtualInputManager")

    local camera =
        workspace.CurrentCamera

    if not camera then
        return false
    end

    local viewport =
        camera.ViewportSize

    if viewport.X <= 0
    or viewport.Y <= 0 then
        return false
    end

    -- Safe center-screen click.
    -- Avoids Roblox topbar, Holy toggle, shop/trade side buttons.
    local x =
        math.floor(viewport.X * 0.50)

    local y =
        math.floor(viewport.Y * 0.55)

    local ok =
        pcall(function()

            VirtualInputManager:SendMouseButtonEvent(
                x,
                y,
                0,
                true,
                game,
                0
            )

            task.wait(0.08)

            VirtualInputManager:SendMouseButtonEvent(
                x,
                y,
                0,
                false,
                game,
                0
            )
        end)

    return ok
end

function FireFinishLoadingRemoteSafe()

    local gameEvents =
        ReplicatedStorage:FindFirstChild("GameEvents")

    if not gameEvents then
        return false
    end

    local finishLoading =
        gameEvents:FindFirstChild("Finish_Loading")

    if not finishLoading
    or not finishLoading:IsA("RemoteEvent") then
        return false
    end

    finishLoading:FireServer()

    return true
end

function RestoreCameraSoft()

    local player =
        Players.LocalPlayer

    if not player then
        return false
    end

    local character =
        player.Character

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

    camera.CameraType =
        Enum.CameraType.Custom

    camera.CameraSubject =
        humanoid

    return true
end

function CleanupLoadingGuiVisualOnly()

    local loadingGui =
        GetLoadingGui()

    if not loadingGui then
        return true
    end

    -- Do not destroy. The game loading module may still reference children.
    pcall(function()
        loadingGui.Enabled = false
    end)

    return true
end

task.spawn(function()

    if AutoPlayState.Started then
        return
    end

    AutoPlayState.Started = true

    local player =
        Players.LocalPlayer

    if not player then
        return
    end

    local playerGui =
        player:WaitForChild("PlayerGui", 20)

    if not playerGui then
        return
    end

    -- Let the game's LoadingScreenHandler create UI and connect input first.
    task.wait(2)

    for attempt = 1, 20 do

        if AutoPlayState.Finished then
            break
        end

        local loadingGui =
            GetLoadingGui()

        if not loadingGui then
            AutoPlayState.Finished = true
            break
        end

        AutoPlayState.Attempts =
            attempt

        -- Fire server finish too, but do not rely on it alone.
        pcall(function()
            FireFinishLoadingRemoteSafe()
        end)

        task.wait(0.15)

        -- This is the important part.
        -- It triggers the same local path as your manual click.
        if IsLoadingPlayScreenVisible() then

            pcall(function()
                SendLoadingScreenClick()
            end)

            AutoPlayState.LastClick =
                os.clock()
        end

        task.wait(0.75)

        pcall(function()
            RestoreCameraSoft()
        end)

        -- If the game removed/disabled LoadingGui after the click, done.
        local stillLoading =
            GetLoadingGui()

        if not stillLoading
        or (
            stillLoading:IsA("ScreenGui")
            and stillLoading.Enabled == false
        ) then

            AutoPlayState.Finished = true
            break
        end

        task.wait(0.25)
    end

    -- Final cleanup after all activation attempts.
    -- Hide only, never destroy.
    task.wait(1)

    pcall(function()
        RestoreCameraSoft()
    end)

    pcall(function()
        CleanupLoadingGuiVisualOnly()
    end)
end)
--==================================================
-- FINAL TIMER DEFAULTS
-- Must run before MainLoop starts.
--==================================================

ServerInfoStartedAt =
    SafeNumber(ServerInfoStartedAt, os.clock())

LatestBoothUpdate =
    SafeNumber(LatestBoothUpdate, 0)

LastTokenFailure =
    SafeNumber(LastTokenFailure, 0)

LastPendingSale =
    SafeNumber(LastPendingSale, 0)

if ConfigState then
    ConfigState.LastMutation =
        SafeNumber(ConfigState.LastMutation, 0)
end

if SniperState then
    SniperState.LastScan =
        SafeNumber(SniperState.LastScan, 0)

    SniperState.LastHop =
        SafeNumber(SniperState.LastHop, 0)

    SniperState.ScanStartedAt =
        SafeNumber(SniperState.ScanStartedAt, os.clock())

    SniperState.ScanDuration =
        SafeNumber(SniperState.ScanDuration, 10)

    SniperState.ScanInterval =
        SafeNumber(SniperState.ScanInterval, 0.25)

    SniperState.StayAfterSnipe =
    SniperState.StayAfterSnipe == true

    SniperState.StayAfterSnipeSeconds =
    SafeNumber(SniperState.StayAfterSnipeSeconds, 5)

    SniperState.StayAfterSnipeUntil =
    SafeNumber(SniperState.StayAfterSnipeUntil, 0)
end

if BoothAuto then
    BoothAuto.LastServerHop =
        SafeNumber(BoothAuto.LastServerHop, 0)

    BoothAuto.ServerHopMinutes =
        SafeNumber(BoothAuto.ServerHopMinutes, 10)
end

if BeeEggAuto then
    BeeEggAuto.LastAttempt =
        SafeNumber(BeeEggAuto.LastAttempt, 0)

    BeeEggAuto.BuyInterval =
        SafeNumber(BeeEggAuto.BuyInterval, 1.5)
end

if WebhookState then
    WebhookState.LastSend =
        SafeNumber(WebhookState.LastSend, 0)

    WebhookState.SendDelay =
        SafeNumber(WebhookState.SendDelay, 0.8)
end

if ShowcaseEquipState then
    ShowcaseEquipState.InventoryConfirmedAt =
        SafeNumber(ShowcaseEquipState.InventoryConfirmedAt, 0)

    ShowcaseEquipState.ReequipDelay =
        SafeNumber(ShowcaseEquipState.ReequipDelay, 10)
end

if ReconnectState then
    ReconnectState.LastAttempt =
        SafeNumber(ReconnectState.LastAttempt, 0)

    ReconnectState.Cooldown =
        SafeNumber(ReconnectState.Cooldown, 5)
end
HolyLoading:SetCurrentStep(6)
HolyLoading:SetDescription("Ready.")

task.wait(0.25)

HolyLoading:Continue()

ScriptState.BootComplete =
    true

if UIState.AutoMinimize == true
or UIState.PendingAutoClose == true then

    task.defer(function()
        task.wait(0.35)
        CloseHolyWindowSafe()
    end)
end

task.spawn(MainLoop)
