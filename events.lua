--==================================================
-- HOLY EVENTS
-- v0.1
-- Campfire Egg Crafting Only
-- Trade World + Normal Garden UI
--==================================================

--==================================================
-- [0] SERVICES
--==================================================

local Players =
    game:GetService("Players")

local ReplicatedStorage =
    game:GetService("ReplicatedStorage")

local TeleportService =
    game:GetService("TeleportService")

local HttpService =
    game:GetService("HttpService")

--==================================================
-- [0.1] PLACE IDS
--==================================================

local TRADING_WORLD_PLACE_ID =
    129954712878723

local GROW_A_GARDEN_PLACE_ID =
    126884695634066

--==================================================
-- [1] URLS
--==================================================

local REPO_URL =
    "https://raw.githubusercontent.com/bencapalot041/goons/main/"

local OBSIDIAN_URL =
    REPO_URL
    .. "lite.lua?v="
    .. tostring(os.time())

local THEME_MANAGER_URL =
    REPO_URL
    .. "addons/ThemeManager.lua?v="
    .. tostring(os.time())

local SAVE_MANAGER_URL =
    REPO_URL
    .. "addons/SaveManager.lua?v="
    .. tostring(os.time())

--==================================================
-- [2] LOAD GATES
--==================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local LocalPlayer =
    Players.LocalPlayer

if not LocalPlayer then
    warn("[HOLY EVENTS] LocalPlayer missing.")
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
    ).HOLY_EVENTS_RUNTIME_ROOT
    or {}

if type(getgenv) == "function" then
    getgenv().HOLY_EVENTS_RUNTIME_ROOT =
        RuntimeRoot
else
    _G.HOLY_EVENTS_RUNTIME_ROOT =
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
-- [4] BASIC HELPERS
--==================================================

local function CleanText(value)

    return tostring(value or "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

local function IsGardenWorld()

    return game.PlaceId == GROW_A_GARDEN_PLACE_ID
end

local function IsTradeWorld()

    return game.PlaceId == TRADING_WORLD_PLACE_ID
end

local function GetWorldName()

    if IsGardenWorld() then
        return "Normal Garden"
    end

    if IsTradeWorld() then
        return "Trade World"
    end

    return "Unknown Place"
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

local function CopyToClipboard(text)

    local clipboard =
        setclipboard
        or toclipboard
        or set_clipboard

    if type(clipboard) ~= "function" then
        warn("[HOLY EVENTS] Clipboard unsupported.")
        return false
    end

    pcall(function()
        clipboard(tostring(text or ""))
    end)

    return true
end

local function FormatTime(startedAt)

    local elapsed =
        math.max(
            0,
            math.floor(os.clock() - startedAt)
        )

    local minutes =
        math.floor(elapsed / 60)

    local seconds =
        elapsed % 60

    return string.format(
        "%02d:%02d",
        minutes,
        seconds
    )
end

--==================================================
-- [5] UI LOAD
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
-- [6] STATE
--==================================================

local State = {
    StartedAt = os.clock(),

    Status = "Ready",
    LastAction = "Loaded",

    Recipes = {},
    RecipeNames = {},

    SlotRecipes = {
        [1] = "Campfire Egg",
        [2] = "Paradise Egg",
        [3] = "Energy Chew",
    },

    AutoClaim = false,
    AutoClaimDelay = 1.5,

    AutoStart = false,
    AutoStartDelay = 5,
    AutoStartCooldown = false,
    AutoStartCycleDone = false,

    SlotReservations = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
    },

    LastStartedRecipeBySlot = {
        [1] = "",
        [2] = "",
        [3] = "",
    },

    CosmeticMaterialTokens = {
        ["Gold Ingot"] = "Cosmetic:huUCI",
    },

    TimerSpeed = 5,
    TimerProbeRunning = false,

    AutoSubmitFire = false,
    AutoSubmitDelay = 2.5,
    AutoSubmitEmberCap = 78000,
    AutoSubmitBusy = false,

    AutoCollectFruits = false,
    AutoCollectDelay = 0.35,
    AutoCollectBatchSize = 25,
    AutoCollectMaxToolCount = 1300,
    AutoCollectBusy = false,
    CachedOwnFarm = nil,
    CachedOwnPlantsPhysical = nil,
    LastOwnFarmResolveAt = 0,
    CollectPlantNames = {},
    CollectPlantNameList = {
        "Alien Apple",
    },

    CachedEmberTextObject = nil,
    CachedEmberCurrent = nil,
    CachedEmberMax = nil,
    CachedEmberRawText = "",
    LastEmberReadAt = 0,

    LastStatusUpdateAt = 0,
    LastRecipeSummaryAt = 0,
    CachedRecipeSummary = "Selected Recipe:\n-",
    SubmitPlantNames = {
        ["Alien Apple"] = true,
    },
    SubmitPlantNameList = {
        "Alien Apple",
    },

    UIScalePercent = 100,
}


local ConfigState = {
    AutosaveName = "autosave_v1",
    Dirty = false,
    Loading = true,

    Folder = "HolyEvents",
    CustomFile = "HolyEvents/autosave_v1_custom.json",
    LastSavedSnapshot = "",
}

local function MarkConfigDirty()

    if ConfigState.Loading == true then
        return
    end

    ConfigState.Dirty =
        true
end

local function CanUseHolyEventsFileIO()

    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

local function EnsureHolyEventsFolder()

    if type(makefolder) ~= "function"
    or type(isfolder) ~= "function" then
        return false
    end

    local ok =
        pcall(function()

            if not isfolder(ConfigState.Folder) then
                makefolder(ConfigState.Folder)
            end
        end)

    return ok == true
end

local function CopyEnabledMap(source)

    local output = {}

    if type(source) ~= "table" then
        return output
    end

    for key, value in pairs(source) do

        if value == true then
            output[tostring(key)] = true
        end
    end

    return output
end

local function BuildHolyEventsCustomSavePayload()

    return {
        Format = "HOLY_EVENTS_AUTOSAVE",
        Version = 1,
        SavedAt = os.time(),

        State = {
            AutoClaim =
                State.AutoClaim == true,

            AutoClaimDelay =
                tonumber(State.AutoClaimDelay) or 1.5,

            AutoStart =
                State.AutoStart == true,

            AutoStartDelay =
                tonumber(State.AutoStartDelay) or 5,

            SlotRecipes = {
                [1] = CleanText(State.SlotRecipes[1]),
                [2] = CleanText(State.SlotRecipes[2]),
                [3] = CleanText(State.SlotRecipes[3]),
            },

            TimerSpeed =
                tonumber(State.TimerSpeed) or 5,

            AutoSubmitFire =
                State.AutoSubmitFire == true,

            AutoSubmitDelay =
                tonumber(State.AutoSubmitDelay) or 2.5,

            AutoSubmitEmberCap =
                tonumber(State.AutoSubmitEmberCap) or 78000,

            SubmitPlantNames =
                CopyEnabledMap(State.SubmitPlantNames),

            AutoCollectFruits =
                State.AutoCollectFruits == true,

            AutoCollectDelay =
                tonumber(State.AutoCollectDelay) or 0.35,

            AutoCollectBatchSize =
                tonumber(State.AutoCollectBatchSize) or 25,

            AutoCollectMaxToolCount =
                tonumber(State.AutoCollectMaxToolCount) or 1300,

            CollectPlantNames =
                CopyEnabledMap(State.CollectPlantNames),

            UIScalePercent =
                tonumber(State.UIScalePercent) or 100,
        },
    }
end

local function ApplyHolyEventsCustomSavePayload(payload)

    if type(payload) ~= "table"
    or payload.Format ~= "HOLY_EVENTS_AUTOSAVE"
    or type(payload.State) ~= "table" then
        return false
    end

    local saved =
        payload.State

    if type(saved.AutoClaim) == "boolean" then
        State.AutoClaim =
            saved.AutoClaim
    end

    if tonumber(saved.AutoClaimDelay) then
        State.AutoClaimDelay =
            math.clamp(
                tonumber(saved.AutoClaimDelay),
                0.5,
                30
            )
    end

    if type(saved.AutoStart) == "boolean" then
        State.AutoStart =
            saved.AutoStart
    end

    if tonumber(saved.AutoStartDelay) then
        State.AutoStartDelay =
            math.clamp(
                tonumber(saved.AutoStartDelay),
                1,
                60
            )
    end

    if type(saved.SlotRecipes) == "table" then

        for slot = 1, 3 do

            local recipeName =
                CleanText(
                    saved.SlotRecipes[tostring(slot)]
                    or saved.SlotRecipes[slot]
                )

            if recipeName ~= "" then
                State.SlotRecipes[slot] =
                    recipeName
            end
        end
    end

    if tonumber(saved.TimerSpeed) then
        State.TimerSpeed =
            math.max(
                0.01,
                tonumber(saved.TimerSpeed)
            )
    end

    if type(saved.AutoSubmitFire) == "boolean" then
        State.AutoSubmitFire =
            saved.AutoSubmitFire
    end

    if tonumber(saved.AutoSubmitDelay) then
        State.AutoSubmitDelay =
            math.clamp(
                tonumber(saved.AutoSubmitDelay),
                1.5,
                15
            )
    end

    if tonumber(saved.AutoSubmitEmberCap) then
        State.AutoSubmitEmberCap =
            math.clamp(
                tonumber(saved.AutoSubmitEmberCap),
                0,
                80000
            )
    end

    if type(saved.SubmitPlantNames) == "table" then
        State.SubmitPlantNames =
            CopyEnabledMap(saved.SubmitPlantNames)
    end

    if type(saved.AutoCollectFruits) == "boolean" then
        State.AutoCollectFruits =
            saved.AutoCollectFruits
    end

    if tonumber(saved.AutoCollectDelay) then
        State.AutoCollectDelay =
            math.clamp(
                tonumber(saved.AutoCollectDelay),
                0.25,
                10
            )
    end

    if tonumber(saved.AutoCollectBatchSize) then
        State.AutoCollectBatchSize =
            math.clamp(
                tonumber(saved.AutoCollectBatchSize),
                1,
                100
            )
    end

    if tonumber(saved.AutoCollectMaxToolCount) then
        State.AutoCollectMaxToolCount =
            math.clamp(
                tonumber(saved.AutoCollectMaxToolCount),
                0,
                5000
            )
    end

    if type(saved.CollectPlantNames) == "table" then
        State.CollectPlantNames =
            CopyEnabledMap(saved.CollectPlantNames)
    end

    if tonumber(saved.UIScalePercent) then
        State.UIScalePercent =
            math.clamp(
                math.floor(tonumber(saved.UIScalePercent)),
                50,
                100
            )
    end

    return true
end

local function EncodeHolyEventsCustomSavePayload()

    local ok, encoded =
        pcall(function()

            return HttpService:JSONEncode(
                BuildHolyEventsCustomSavePayload()
            )
        end)

    if ok ~= true
    or type(encoded) ~= "string" then
        return ""
    end

    return encoded
end

local function LoadHolyEventsCustomConfigNow()

    if not CanUseHolyEventsFileIO() then
        return false
    end

    local exists =
        false

    local existsOk =
        pcall(function()
            exists =
                isfile(ConfigState.CustomFile)
        end)

    if existsOk ~= true
    or exists ~= true then
        return false
    end

    local readOk, raw =
        pcall(function()
            return readfile(ConfigState.CustomFile)
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

    local applied =
        ApplyHolyEventsCustomSavePayload(payload)

    if applied == true then

        ConfigState.LastSavedSnapshot =
            EncodeHolyEventsCustomSavePayload()

        print("[HOLY EVENTS] Custom autosave loaded.")
    end

    return applied
end

local function SaveHolyEventsCustomConfigNow(reason)

    if not CanUseHolyEventsFileIO() then
        return false
    end

    EnsureHolyEventsFolder()

    local encoded =
        EncodeHolyEventsCustomSavePayload()

    if encoded == "" then
        return false
    end

    local writeOk, writeErr =
        pcall(function()

            writefile(
                ConfigState.CustomFile,
                encoded
            )
        end)

    if writeOk ~= true then

        warn(
            "[HOLY EVENTS] Custom autosave failed:",
            tostring(writeErr)
        )

        return false
    end

    ConfigState.LastSavedSnapshot =
        encoded

    print(
        "[HOLY EVENTS] Custom autosaved:",
        tostring(reason or "auto")
    )

    return true
end

LoadHolyEventsCustomConfigNow()

--==================================================
-- [7] INVENTORY HELPERS
--==================================================

local function ReadItemUUID(item)

    if not item then
        return ""
    end

    local candidates = {
        item:GetAttribute("c"),
        item:GetAttribute("UUID"),
        item:GetAttribute("ItemUUID"),
        item:GetAttribute("ItemId"),
        item:GetAttribute("ItemID"),
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

local function ReadItemName(item)

    if not item then
        return ""
    end

    local attrName =
        item:GetAttribute("f")
        or item:GetAttribute("h")
        or item:GetAttribute("i")
        or item:GetAttribute("n")
        or item:GetAttribute("Seed")
        or item:GetAttribute("ItemName")

    attrName =
        CleanText(attrName)

    if attrName ~= "" then
        return attrName
    end

    local itemString =
        item:FindFirstChild("Item_String")

    if itemString
    and itemString:IsA("StringValue") then

        local value =
            CleanText(itemString.Value)

        if value ~= "" then
            return value
        end
    end

    local name =
        tostring(item.Name or "")

    name =
        name:gsub("%b[]", "")
            :gsub("%s+", " ")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    return name
end

local function NormalizeUUID(value)

    value =
        CleanText(value)

    if value == "" then
        return ""
    end

    value =
        value:gsub("{", "")
            :gsub("}", "")
            :gsub("^%s+", "")
            :gsub("%s+$", "")

    if value == "" then
        return ""
    end

    return "{"
        .. value
        .. "}"
end

local function FindExactInventoryUUID(exactName)

    exactName =
        CleanText(exactName)

    if exactName == "" then
        return ""
    end

    local containers = {
        LocalPlayer:FindFirstChild("Backpack"),
        LocalPlayer.Character,
    }

    for _, container in ipairs(containers) do

        if not container then
            continue
        end

        for _, item in ipairs(container:GetChildren()) do

            if not item:IsA("Tool") then
                continue
            end

            local itemName =
                ReadItemName(item)

            if itemName == exactName then

                local uuid =
                    NormalizeUUID(
                        ReadItemUUID(item)
                    )

                if uuid ~= "" then
                    return uuid
                end
            end
        end
    end

    return ""
end


local function FindInventoryUUIDsForItem(exactName, neededAmount)

    exactName =
        CleanText(exactName)

    neededAmount =
        tonumber(neededAmount)
        or 1

    local result = {}

    if exactName == "" then
        return result
    end

    local containers = {
        LocalPlayer:FindFirstChild("Backpack"),
        LocalPlayer.Character,
    }

    for _, container in ipairs(containers) do

        if not container then
            continue
        end

        for _, item in ipairs(container:GetChildren()) do

            if not item:IsA("Tool") then
                continue
            end

            local itemName =
                ReadItemName(item)

            if itemName == exactName then

                local uuid =
                    NormalizeUUID(
                        ReadItemUUID(item)
                    )

                if uuid ~= "" then

                    table.insert(
                        result,
                        uuid
                    )

                    if #result >= neededAmount then
                        return result
                    end
                end
            end
        end
    end

    return result
end

local function CountExactInventoryItem(exactName)

    exactName =
        CleanText(exactName)

    local count =
        0

    local containers = {
        LocalPlayer:FindFirstChild("Backpack"),
        LocalPlayer.Character,
    }

    for _, container in ipairs(containers) do

        if not container then
            continue
        end

        for _, item in ipairs(container:GetChildren()) do

            if not item:IsA("Tool") then
                continue
            end

            local itemName =
                ReadItemName(item)

            if itemName == exactName then

                local uses =
                    tonumber(
                        item:GetAttribute("e")
                        or item:GetAttribute("LocalUses")
                        or item:GetAttribute("Quantity")
                    )

                if uses and uses > 0 then
                    count =
                        count + uses
                else
                    count =
                        count + 1
                end
            end
        end
    end

    return count
end

--==================================================
-- [7.5] SUMMER FIRE SUBMIT
--==================================================


local function ParseSummerEmbersFromText(text)

    text =
        CleanText(text)

    if text == "" then
        return nil, nil
    end

    local currentText, maxText =
        text:match("([%d,]+)%s*/%s*([%d,]+)%s*Embers")

    if not currentText
    or not maxText then
        return nil, nil
    end

    currentText =
        currentText:gsub(",", "")

    maxText =
        maxText:gsub(",", "")

    local current =
        tonumber(currentText)

    local max =
        tonumber(maxText)

    return current, max
end

local function FindSummerEmberTextObject()

    local roots = {}

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    if playerGui then
        table.insert(roots, playerGui)
    end

    local summerFire =
        workspace:FindFirstChild("Interaction")
        and workspace.Interaction:FindFirstChild("UpdateItems")
        and workspace.Interaction.UpdateItems:FindFirstChild("SummerFire")

    if summerFire then
        table.insert(roots, summerFire)
    end

    for _, root in ipairs(roots) do

        for _, obj in ipairs(root:GetDescendants()) do

            if obj:IsA("TextLabel")
            or obj:IsA("TextButton")
            or obj:IsA("TextBox") then

                local text =
                    CleanText(obj.Text)

                if text:find("Embers", 1, true) then

                    local current, max =
                        ParseSummerEmbersFromText(text)

                    if current
                    and max then

                        print(
                            "[HOLY EVENTS] Ember text found:",
                            obj:GetFullName(),
                            text
                        )

                        return obj
                    end
                end
            end
        end
    end

    return nil
end

local function GetSummerEmberAmount(forceRefresh)

    local now =
        os.clock()

    if forceRefresh ~= true
    and State.CachedEmberCurrent ~= nil
    and now - (State.LastEmberReadAt or 0) < 1.25 then

        return
            State.CachedEmberCurrent,
            State.CachedEmberMax,
            State.CachedEmberRawText
    end

    local emberObject =
        State.CachedEmberTextObject

    if not emberObject
    or not emberObject.Parent then

        emberObject =
            FindSummerEmberTextObject()

        State.CachedEmberTextObject =
            emberObject
    end

    if emberObject then

        local text =
            CleanText(emberObject.Text)

        local current, max =
            ParseSummerEmbersFromText(text)

        if current
        and max then

            State.CachedEmberCurrent =
                current

            State.CachedEmberMax =
                max

            State.CachedEmberRawText =
                text

            State.LastEmberReadAt =
                now

            return current, max, text
        end
    end

    State.LastEmberReadAt =
        now

    return
        State.CachedEmberCurrent,
        State.CachedEmberMax,
        State.CachedEmberRawText or ""
end

local function IsSummerEmberCapReached()

    local cap =
        tonumber(State.AutoSubmitEmberCap)
        or 0

    if cap <= 0 then
        return false
    end

    local current =
        GetSummerEmberAmount(true)

    if current == nil then

        State.Status =
            "Embers unreadable"

        State.LastAction =
            "Submit blocked: ember count unknown"

        return true
    end

    return current >= cap
end

local function GetSummerEmberStatusText()

    local current, max, rawText =
        GetSummerEmberAmount()

    local cap =
        tonumber(State.AutoSubmitEmberCap)
        or 0

    if current == nil then

        return "Embers: unknown"
            .. "\nCap: "
            .. tostring(cap)
    end

    return "Embers: "
        .. tostring(current)
        .. " / "
        .. tostring(max or "?")
        .. "\nCap: "
        .. tostring(cap)
        .. "\nCap Reached: "
        .. tostring(IsSummerEmberCapReached())
end

local function GetSummerFireSubmitRemote()

    local gameEvents =
        ReplicatedStorage:FindFirstChild("GameEvents")

    local summerFire =
        gameEvents
        and gameEvents:FindFirstChild("SummerFire")

    local remote =
        summerFire
        and summerFire:FindFirstChild("Submit")

    if remote
    and remote:IsA("RemoteEvent") then
        return remote
    end

    return nil
end

local function IsSubmitSafePlantTool(tool, plantName)

    if not tool
    or not tool:IsA("Tool") then
        return false
    end

    plantName =
        CleanText(plantName)

    if plantName == "" then
        return false
    end

    if CleanText(tool:GetAttribute("f")) ~= plantName then
        return false
    end

    if tool:FindFirstChild("Weight") == nil then
        return false
    end

    if tool:FindFirstChild("Item_String") == nil then
        return false
    end

    -- Do not submit seeds.
    if tool:GetAttribute("Seed") ~= nil then
        return false
    end

    -- Do not submit pets.
    if tool:GetAttribute("ItemType") == "Pet"
    or tool:GetAttribute("PetType") == "Pet"
    or tool:GetAttribute("PET_UUID") ~= nil then
        return false
    end

    return true
end

local function GetHeldSubmitPlantTool()

    local character =
        LocalPlayer.Character

    if not character then
        return nil
    end

    for _, item in ipairs(character:GetChildren()) do

        if item:IsA("Tool") then

            for plantName, enabled in pairs(State.SubmitPlantNames) do

                if enabled == true
                and IsSubmitSafePlantTool(item, plantName) then
                    return item, plantName
                end
            end
        end
    end

    return nil
end

local function FindSubmitPlantTool()

    local containers = {
        LocalPlayer.Character,
        LocalPlayer:FindFirstChild("Backpack"),
    }

    for _, container in ipairs(containers) do

        if container then

            for _, item in ipairs(container:GetChildren()) do

                for plantName, enabled in pairs(State.SubmitPlantNames) do

                    if enabled == true
                    and IsSubmitSafePlantTool(item, plantName) then
                        return item, plantName
                    end
                end
            end
        end
    end

    return nil
end

local function EquipSubmitPlantTool(tool)

    if not tool then
        return false
    end

    local character =
        LocalPlayer.Character

    local humanoid =
        character
        and character:FindFirstChildWhichIsA("Humanoid")

    if not humanoid then
        return false
    end

    local ok, err =
        pcall(function()

            humanoid:UnequipTools()

            task.wait(0.15)

            humanoid:EquipTool(tool)
        end)

    if ok ~= true then

        warn(
            "[HOLY EVENTS] Equip submit plant failed:",
            tostring(err)
        )

        return false
    end

    task.wait(0.35)

    return tool.Parent == character
end

local function SubmitHeldPlantOnce()

    if State.AutoSubmitBusy == true then
        return false
    end

    State.AutoSubmitBusy =
        true

    local function finish(result)

        State.AutoSubmitBusy =
            false

        return result
    end

    if not IsGardenWorld() then

        State.Status =
            "Normal Garden only"

        State.LastAction =
            "Submit blocked: wrong world"

        return finish(false)
    end

    if IsSummerEmberCapReached() then

        local current, max =
            GetSummerEmberAmount(true)

        State.Status =
            "Ember cap reached"

        State.LastAction =
            "Submit stopped at "
            .. tostring(current or "?")
            .. " / "
            .. tostring(max or "?")

        return finish(false)
    end

    local remote =
        GetSummerFireSubmitRemote()

    if not remote then

        State.Status =
            "SummerFire.Submit missing"

        State.LastAction =
            "Submit remote missing"

        return finish(false)
    end

    local heldTool, heldPlant =
        GetHeldSubmitPlantTool()

    if not heldTool then

        local tool, plantName =
            FindSubmitPlantTool()

        if not tool then

            State.Status =
                "No selected fruit tool"

            State.LastAction =
                "No selected fruit in Backpack"

            return finish(false)
        end

        local equipped =
            EquipSubmitPlantTool(tool)

        if equipped ~= true then

            State.Status =
                "Fruit equip failed"

            State.LastAction =
                "Could not equip "
                .. tostring(plantName)

            return finish(false)
        end

        heldTool =
            tool

        heldPlant =
            plantName
    end

    local ok, err =
        pcall(function()

            remote:FireServer()
        end)

    if ok ~= true then

        State.Status =
            "Submit failed"

        State.LastAction =
            "Submit failed: "
            .. tostring(err)

        warn(
            "[HOLY EVENTS] SummerFire submit failed:",
            tostring(err)
        )

        return finish(false)
    end

    -- Force refresh ember cache after submit so cap/status updates correctly.
    task.defer(function()

        task.wait(0.35)

        GetSummerEmberAmount(true)
    end)

    State.Status =
        "Submitted "
        .. tostring(heldPlant)

    State.LastAction =
        "Burned "
        .. tostring(heldPlant)

    print(
        "[HOLY EVENTS] Submitted plant:",
        tostring(heldPlant),
        heldTool and heldTool.Name or "unknown"
    )

    return finish(true)
end

local function RefreshSubmitPlantListFromInventory()

    local found = {}

    local containers = {
        LocalPlayer.Character,
        LocalPlayer:FindFirstChild("Backpack"),
    }

    for _, container in ipairs(containers) do

        if container then

            for _, item in ipairs(container:GetChildren()) do

                if item:IsA("Tool")
                and item:FindFirstChild("Weight")
                and item:FindFirstChild("Item_String")
                and item:GetAttribute("Seed") == nil then

                    local plantName =
                        CleanText(
                            item:GetAttribute("f")
                        )

                    if plantName ~= "" then
                        found[plantName] = true
                    end
                end
            end
        end
    end

    local list = {}

    for plantName in pairs(found) do

        table.insert(
            list,
            plantName
        )
    end

    table.sort(list)

    if #list <= 0 then

        list = {
            "Alien Apple",
        }
    end

    State.SubmitPlantNameList =
        list

    State.Status =
        "Submit plants found: "
        .. tostring(#list)

    State.LastAction =
        "Submit plant list refreshed"

    print(
        "[HOLY EVENTS] Submit plants found:",
        table.concat(list, ", ")
    )

    return list
end

local function GetSelectedSubmitPlantText()

    local selected = {}

    for plantName, enabled in pairs(State.SubmitPlantNames) do

        if enabled == true then

            table.insert(
                selected,
                plantName
            )
        end
    end

    table.sort(selected)

    if #selected <= 0 then
        return "none"
    end

    return table.concat(
        selected,
        ", "
    )
end

--==================================================
-- [7.6] OWN FARM AUTO COLLECT
--==================================================

local function GetNotificationText()

    local playerGui =
        LocalPlayer
        and LocalPlayer:FindFirstChild("PlayerGui")

    local notification =
        playerGui
        and playerGui:FindFirstChild("x_NotificationGui")
        and playerGui.x_NotificationGui:FindFirstChild("NotificationDisplay")

    if notification
    and notification:IsA("TextLabel") then
        return CleanText(notification.Text)
    end

    return ""
end

local function IsBackpackFullFromNotification()

    local text =
        GetNotificationText():lower()

    return text:find("max backpack space", 1, true) ~= nil
        or text:find("go sell", 1, true) ~= nil
end

local function GetCurrentToolCount()

    local count = 0

    local containers = {
        LocalPlayer:FindFirstChild("Backpack"),
        LocalPlayer.Character,
    }

    for _, container in ipairs(containers) do

        if container then

            for _, item in ipairs(container:GetChildren()) do

                if item:IsA("Tool") then
                    count += 1
                end
            end
        end
    end

    return count
end

local function GetOwnFarm()

    local now =
        os.clock()

    if State.CachedOwnFarm
    and State.CachedOwnFarm.Parent
    and State.CachedOwnPlantsPhysical
    and State.CachedOwnPlantsPhysical.Parent then

        return State.CachedOwnFarm
    end

    -- Do not scan workspace every collect tick.
    -- Cache miss / invalid cache only.
    if now - (State.LastOwnFarmResolveAt or 0) < 2 then
        return State.CachedOwnFarm
    end

    State.LastOwnFarmResolveAt =
        now

    for _, obj in ipairs(workspace:GetDescendants()) do

        if obj:IsA("Folder")
        or obj:IsA("Model") then

            local important =
                obj:FindFirstChild("Important")

            local data =
                important
                and important:FindFirstChild("Data")

            local owner =
                data
                and data:FindFirstChild("Owner")

            local plants =
                important
                and important:FindFirstChild("Plants_Physical")

            if owner
            and owner:IsA("StringValue")
            and owner.Value == LocalPlayer.Name
            and plants then

                State.CachedOwnFarm =
                    obj

                State.CachedOwnPlantsPhysical =
                    plants

                print(
                    "[HOLY EVENTS] Own farm cached:",
                    obj:GetFullName()
                )

                return obj
            end
        end
    end

    State.CachedOwnFarm =
        nil

    State.CachedOwnPlantsPhysical =
        nil

    return nil
end

local function GetOwnPlantsPhysical()

    if State.CachedOwnPlantsPhysical
    and State.CachedOwnPlantsPhysical.Parent
    and State.CachedOwnFarm
    and State.CachedOwnFarm.Parent then

        return State.CachedOwnPlantsPhysical, State.CachedOwnFarm
    end

    local ownFarm =
        GetOwnFarm()

    local important =
        ownFarm
        and ownFarm:FindFirstChild("Important")

    local plants =
        important
        and important:FindFirstChild("Plants_Physical")

    State.CachedOwnFarm =
        ownFarm

    State.CachedOwnPlantsPhysical =
        plants

    return plants, ownFarm
end

local function RefreshCollectPlantListFromOwnFarm()

    local plants =
        GetOwnPlantsPhysical()

    local found = {}

    if plants then

        for _, plant in ipairs(plants:GetChildren()) do

            local fruits =
                plant:FindFirstChild("Fruits")

            if fruits
            and #fruits:GetChildren() > 0 then

                found[plant.Name] =
                    true
            end
        end
    end

    local list = {}

    for plantName in pairs(found) do
        table.insert(list, plantName)
    end

    table.sort(list)

    if #list <= 0 then

        list = {
            "Alien Apple",
        }
    end

    State.CollectPlantNameList =
        list

    State.Status =
        "Collect plants found: "
        .. tostring(#list)

    State.LastAction =
        "Own farm collect list refreshed"

    print(
        "[HOLY EVENTS] Own farm collect plants:",
        table.concat(list, ", ")
    )

    return list
end

local function GetSelectedCollectPlantText()

    local selected = {}

    for plantName, enabled in pairs(State.CollectPlantNames) do

        if enabled == true then
            table.insert(selected, plantName)
        end
    end

    table.sort(selected)

    if #selected <= 0 then
        return "none"
    end

    return table.concat(selected, ", ")
end

local function IsAutoCollectSafetyBlocked()

    if not IsGardenWorld() then

        State.Status =
            "Normal Garden only"

        State.LastAction =
            "Auto collect blocked: wrong world"

        return true
    end

    if IsBackpackFullFromNotification() then

        State.AutoCollectFruits =
            false

        State.Status =
            "Backpack full"

        State.LastAction =
            "Auto collect stopped: backpack full"

        return true
    end

    local maxToolCount =
        tonumber(State.AutoCollectMaxToolCount)
        or 0

    if maxToolCount > 0
    and GetCurrentToolCount() >= maxToolCount then

        State.AutoCollectFruits =
            false

        State.Status =
            "Tool cap reached"

        State.LastAction =
            "Auto collect stopped at tool cap"

        return true
    end

    return false
end

local function GetOwnFarmFruitBatch()

    local requestedBatchSize =
        math.clamp(
            tonumber(State.AutoCollectBatchSize) or 25,
            1,
            100
        )

    local maxToolCount =
        tonumber(State.AutoCollectMaxToolCount)
        or 0

    if maxToolCount > 0 then

        local currentTools =
            GetCurrentToolCount()

        local remaining =
            maxToolCount - currentTools

        if remaining <= 0 then

            State.AutoCollectFruits =
                false

            State.Status =
                "Tool cap reached"

            State.LastAction =
                "Auto collect stopped before batch"

            return {}
        end

        requestedBatchSize =
            math.min(
                requestedBatchSize,
                remaining
            )
    end

    local plants =
        GetOwnPlantsPhysical()

    if not plants then

        State.Status =
            "Own farm not found"

        State.LastAction =
            "Auto collect blocked: own farm missing"

        return {}
    end

    local batch = {}
    local used = {}

    local selectedPlants = {}

    for plantName, enabled in pairs(State.CollectPlantNames) do

        if enabled == true then
            table.insert(selectedPlants, plantName)
        end
    end

    table.sort(selectedPlants)

    for _, plantName in ipairs(selectedPlants) do

        local plant =
            plants:FindFirstChild(plantName)

        local fruits =
            plant
            and plant:FindFirstChild("Fruits")

        if fruits then

            for _, fruit in ipairs(fruits:GetChildren()) do

                if #batch >= requestedBatchSize then
                    return batch
                end

                if fruit:IsA("Model")
                and fruit:IsDescendantOf(plants)
                and not used[fruit] then

                    used[fruit] =
                        true

                    table.insert(batch, fruit)
                end
            end
        end
    end

    return batch
end

local function CollectOwnFarmBatchOnce()

    if State.AutoCollectBusy == true then
        return false
    end

    State.AutoCollectBusy =
        true

    local function finish(result)

        State.AutoCollectBusy =
            false

        return result
    end

    if IsAutoCollectSafetyBlocked() then
        return finish(false)
    end

    local batch =
        GetOwnFarmFruitBatch()

    if #batch <= 0 then

        State.Status =
            "No selected fruits ready"

        State.LastAction =
            "No own farm selected fruits found"

        return finish(false)
    end

    local remote =
        ReplicatedStorage
            :FindFirstChild("GameEvents")
            and ReplicatedStorage.GameEvents:FindFirstChild("Crops")
            and ReplicatedStorage.GameEvents.Crops:FindFirstChild("Collect")

    if not remote
    or not remote:IsA("RemoteEvent") then

        State.Status =
            "Crops.Collect missing"

        State.LastAction =
            "Collect remote missing"

        return finish(false)
    end

    local beforeCount =
        GetCurrentToolCount()

    local ok, err =
        pcall(function()

            remote:FireServer(batch)
        end)

    if ok ~= true then

        State.Status =
            "Collect failed"

        State.LastAction =
            "Collect failed: "
            .. tostring(err)

        warn(
            "[HOLY EVENTS] Collect failed:",
            tostring(err)
        )

        return finish(false)
    end

    task.wait(0.15)

    if IsBackpackFullFromNotification() then

        State.AutoCollectFruits =
            false

        State.Status =
            "Backpack full"

        State.LastAction =
            "Auto collect stopped after full warning"

        return finish(false)
    end

    local afterCount =
        GetCurrentToolCount()

    State.Status =
        "Collected "
        .. tostring(#batch)
        .. " fruit(s)"

    State.LastAction =
        "Tools: "
        .. tostring(beforeCount)
        .. " -> "
        .. tostring(afterCount)

    print(
        "[HOLY EVENTS] Collected own farm batch:",
        tostring(#batch),
        "tools:",
        tostring(beforeCount),
        "->",
        tostring(afterCount)
    )

    return finish(true)
end

--==================================================
-- [8] SUMMER CRAFTING
--==================================================

local function GetSummerCraftingService()

    local gameEvents =
        ReplicatedStorage:FindFirstChild("GameEvents")

    if not gameEvents then
        return nil
    end

    return gameEvents:FindFirstChild("SummerCraftingService")
end

local function GetStartCraftRemote()

    local service =
        GetSummerCraftingService()

    local remote =
        service
        and service:FindFirstChild("StartCraft")

    if remote
    and remote:IsA("RemoteEvent") then
        return remote
    end

    return nil
end

local function GetClaimCraftRemote()

    local service =
        GetSummerCraftingService()

    local remote =
        service
        and service:FindFirstChild("ClaimCraft")

    if remote
    and remote:IsA("RemoteEvent") then
        return remote
    end

    return nil
end

local function GetSummerRecipeScroller()

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    local summerGui =
        playerGui
        and playerGui:FindFirstChild("SummerCrafting")

    local crafting =
        summerGui
        and summerGui:FindFirstChild("Crafting")

    local main =
        crafting
        and crafting:FindFirstChild("Main")

    local clipper =
        main
        and main:FindFirstChild("Clipper")

    local scroller =
        clipper
        and clipper:FindFirstChild("Scroller")

    return scroller
end

local function ParseRecipeRequirementUUID(value)

    value =
        CleanText(value)

    if value == "" then
        return nil
    end

    local craftId, index, itemType, itemName, amount =
        value:match("^(%d+:%d+:.+)_REQ_(%d+)_([^_]+)_(.+)_(%d+)$")

    if not craftId then
        return nil
    end

    return {
        CraftId = craftId,
        Index = tonumber(index) or 1,
        Type = CleanText(itemType),
        Name = CleanText(itemName),
        Amount = tonumber(amount) or 1,
        Raw = value,
    }
end

local function GetFrameRecipeName(frame)

    if not frame then
        return ""
    end

    local name =
        tostring(frame.Name or "")

    local recipeName =
        name:match("^%d+:(.+)$")

    recipeName =
        CleanText(recipeName or name)

    return recipeName
end

local function IsRecipeFrame(obj)

    return obj
        and obj:IsA("GuiObject")
        and tostring(obj.Name):match("^%d+:.+") ~= nil
end

local function RefreshSummerRecipeDatabase()

    local scroller =
        GetSummerRecipeScroller()

    State.Recipes =
        {}

    State.RecipeNames =
        {}

    if not scroller then

        State.Status =
            "Recipe UI not found"

        State.LastAction =
            "Recipe scan failed"

        warn("[HOLY EVENTS] SummerCrafting recipe scroller missing.")

        return false
    end

    local frames = {}

    for _, child in ipairs(scroller:GetChildren()) do

        if IsRecipeFrame(child) then

            table.insert(
                frames,
                child
            )
        end
    end

    table.sort(frames, function(a, b)

        local aOrder =
            a.LayoutOrder or 0

        local bOrder =
            b.LayoutOrder or 0

        if aOrder == bOrder then
            return tostring(a.Name) < tostring(b.Name)
        end

        return aOrder < bOrder
    end)

    for _, frame in ipairs(frames) do

        local recipeName =
            GetFrameRecipeName(frame)

        local recipe = {
            Name = recipeName,
            FrameName = frame.Name,
            LayoutOrder = frame.LayoutOrder or 0,
            CraftId = "",
            Materials = {},
            Currency = {},
        }

        local requirements =
            frame:FindFirstChild("Inner")
            and frame.Inner:FindFirstChild("Requirements")

        if requirements then

            for _, obj in ipairs(requirements:GetDescendants()) do

                local raw =
                    obj:GetAttribute("UUID")

                local parsed =
                    ParseRecipeRequirementUUID(raw)

                if parsed then

                    recipe.CraftId =
                        parsed.CraftId

                    if parsed.Type == "Currency" then

                        table.insert(
                            recipe.Currency,
                            parsed
                        )
                    else

                        table.insert(
                            recipe.Materials,
                            parsed
                        )
                    end
                end
            end
        end

        table.sort(recipe.Materials, function(a, b)
            return a.Index < b.Index
        end)

        table.sort(recipe.Currency, function(a, b)
            return a.Index < b.Index
        end)

        if recipeName ~= ""
        and recipe.CraftId ~= ""
        and #recipe.Materials > 0 then

            State.Recipes[recipeName] =
                recipe

            table.insert(
                State.RecipeNames,
                recipeName
            )
        end
    end

    if #State.RecipeNames <= 0 then

        State.Status =
            "No recipes found"

        State.LastAction =
            "Recipe scan empty"

        warn("[HOLY EVENTS] No summer recipes parsed.")

        return false
    end

    State.Status =
        "Recipes found: "
        .. tostring(#State.RecipeNames)

    State.LastAction =
        "Recipe database refreshed"

    print(
        "[HOLY EVENTS] Recipes found:",
        tostring(#State.RecipeNames)
    )

    for _, recipeName in ipairs(State.RecipeNames) do

        local recipe =
            State.Recipes[recipeName]

        print(
            "[HOLY EVENTS] Recipe:",
            recipeName,
            "| CraftId:",
            recipe.CraftId,
            "| Materials:",
            tostring(#recipe.Materials)
        )
    end

    return true
end


local function GetCosmeticMaterialToken(materialName)

    materialName =
        CleanText(materialName)

    if materialName == "" then
        return ""
    end

    local tokens =
        State.CosmeticMaterialTokens

    if type(tokens) ~= "table" then
        return ""
    end

    return CleanText(
        tokens[materialName]
    )
end

local function BuildRecipePayload(recipe)

    if not recipe then
        return nil, "recipe missing"
    end

    local payload = {}

    for groupIndex, material in ipairs(recipe.Materials) do

        payload[groupIndex] =
            {}

        if material.Type == "Cosmetic" then

            local cosmeticToken =
                GetCosmeticMaterialToken(
                    material.Name
                )

            if cosmeticToken == "" then

                return nil,
                    "Missing cosmetic token for "
                    .. tostring(material.Name)
            end

            payload[groupIndex][1] =
                cosmeticToken
        else

            local uuids =
                FindInventoryUUIDsForItem(
                    material.Name,
                    material.Amount
                )

            if #uuids <= 0 then

                return nil,
                    "Missing "
                    .. tostring(material.Name)
            end

            -- Manual spy shows stacked requirements only send one stack UUID.
            -- Example: Paradise Egg needs Mythical Egg x2 and Grandmaster Sprinkler x3,
            -- but the real StartCraft call sends one UUID per material group.
            payload[groupIndex][1] =
                uuids[1]
        end
    end

    return payload, nil
end

local function GetRecipeMaterialSummary(recipeName)

    local recipe =
        State.Recipes[recipeName]

    if not recipe then
        return "Recipe not found"
    end

    local lines = {}

    table.insert(
        lines,
        recipe.Name
        .. "\n"
        .. recipe.CraftId
    )

    for _, material in ipairs(recipe.Materials) do

        if material.Type == "Cosmetic" then

            local cosmeticToken =
                GetCosmeticMaterialToken(
                    material.Name
                )

            local marker =
                cosmeticToken ~= ""
                and "✓"
                or "✗"

            table.insert(
                lines,
                marker
                    .. " "
                    .. material.Name
                    .. " x"
                    .. tostring(material.Amount)
                    .. " / cosmetic"
            )
        else

            local count =
                CountExactInventoryItem(
                    material.Name
                )

            local marker =
                count >= material.Amount
                and "✓"
                or "✗"

            table.insert(
                lines,
                marker
                    .. " "
                    .. material.Name
                    .. " x"
                    .. tostring(material.Amount)
                    .. " / have "
                    .. tostring(count)
            )
        end
    end

    for _, currency in ipairs(recipe.Currency) do

        table.insert(
            lines,
            "$ "
                .. currency.Name
                .. " "
                .. tostring(currency.Amount)
        )
    end

    return table.concat(
        lines,
        "\n"
    )
end

local function StartSummerRecipe(recipeName)

    if not IsGardenWorld() then

        State.Status =
            "Normal Garden only"

        State.LastAction =
            "Start blocked: wrong world"

        return false
    end

    recipeName =
        CleanText(recipeName)

    if recipeName == "" then

        State.Status =
            "No recipe selected"

        State.LastAction =
            "Start blocked: no recipe"

        return false
    end

    local remote =
        GetStartCraftRemote()

    if not remote then

        State.Status =
            "StartCraft missing"

        State.LastAction =
            "StartCraft remote missing"

        warn("[HOLY EVENTS] StartCraft remote missing.")

        return false
    end

    local recipe =
        State.Recipes[recipeName]

    if not recipe then

        RefreshSummerRecipeDatabase()

        recipe =
            State.Recipes[recipeName]
    end

    if not recipe then

        State.Status =
            "Recipe missing: "
            .. recipeName

        State.LastAction =
            "Recipe missing"

        warn(
            "[HOLY EVENTS] Recipe missing:",
            recipeName
        )

        return false
    end

    local payload, payloadError =
        BuildRecipePayload(recipe)

    if not payload then

        State.Status =
            tostring(payloadError)

        State.LastAction =
            "Missing material for "
            .. recipeName

        warn(
            "[HOLY EVENTS]",
            tostring(payloadError)
        )

        return false
    end

    print("========== HOLY START SUMMER RECIPE ==========")
    print("Recipe:", recipe.Name)
    print("CraftId:", recipe.CraftId)

    for groupIndex, group in pairs(payload) do
        print(
            "Group",
            tostring(groupIndex),
            table.concat(group, ", ")
        )
    end

    local ok, err =
        pcall(function()

            remote:FireServer(
                recipe.CraftId,
                payload
            )
        end)

    if ok ~= true then

        State.Status =
            "Start failed"

        State.LastAction =
            "Start failed: "
            .. recipeName

        warn(
            "[HOLY EVENTS] Start failed:",
            tostring(err)
        )

        return false
    end

    State.Status =
        "Started "
        .. recipeName

    State.LastAction =
        "Started "
        .. recipeName

    print(
        "[HOLY EVENTS] StartCraft fired:",
        recipeName
    )

    print("=============================================")

    return true
end


local GetSummerCraftSlotTimeText
local IsSummerCraftSlotEmpty
local GetFirstEmptySummerSlot


local function IsSlotReserved(slot)

    slot =
        tonumber(slot)
        or 1

    local expiresAt =
        State.SlotReservations
        and State.SlotReservations[slot]
        or 0

    return tonumber(expiresAt)
        and os.clock() < tonumber(expiresAt)
end

local function ReserveSummerSlot(slot, seconds)

    slot =
        tonumber(slot)
        or 1

    seconds =
        tonumber(seconds)
        or 12

    if type(State.SlotReservations) ~= "table" then
        State.SlotReservations = {}
    end

    State.SlotReservations[slot] =
        os.clock() + math.max(2, seconds)
end

local function IsSummerCraftSlotAvailableForStart(slot)

    if IsSlotReserved(slot) then
        return false
    end

    local text =
        CleanText(
            GetSummerCraftSlotTimeText(slot)
        )

    local upper =
        text:upper()

    if upper == "" then
        return true
    end

    if upper:find("EMPTY", 1, true) then
        return true
    end

    -- The game can show this while the slot is visually empty/available.
    -- We allow it, but reservation prevents repeating Slot 1 forever.
    if upper:find("PAUSED", 1, true) then
        return true
    end

    if upper:find("CLAIM", 1, true) then
        return false
    end

    if text:match("^%d+:%d+:%d+$")
    or text:match("^%d+:%d+$") then
        return false
    end

    return false
end

local function GetFirstAvailableSummerStartSlot()

    for slot = 1, 3 do

        if IsSummerCraftSlotAvailableForStart(slot) then
            return slot
        end
    end

    return nil
end

local function StartRecipeForPhysicalSlot(slot)

    slot =
        tonumber(slot)
        or 1

    local recipeName =
        CleanText(
            State.SlotRecipes[slot]
        )

    if recipeName == "" then

        State.Status =
            "Slot "
            .. tostring(slot)
            .. " has no recipe"

        State.LastAction =
            State.Status

        return false
    end

    State.Status =
        "Starting slot "
        .. tostring(slot)
        .. ": "
        .. recipeName

    State.LastAction =
        State.Status

    local ok =
        StartSummerRecipe(recipeName)

    if ok == true then

        ReserveSummerSlot(
            slot,
            math.max(
                10,
                tonumber(State.AutoStartDelay) or 5
            ) + 8
        )

        State.LastStartedRecipeBySlot[slot] =
            recipeName

        print(
            "[HOLY EVENTS] Reserved slot",
            tostring(slot),
            "after starting",
            recipeName
        )

        return true
    end

    return false
end

local function StartSelectedRecipesNow()

    local delaySeconds =
        math.clamp(
            tonumber(State.AutoStartDelay) or 5,
            1,
            60
        )

    for slot = 1, 3 do

        if IsSummerCraftSlotAvailableForStart(slot) ~= true then

            print(
                "[HOLY EVENTS] Manual start skipped slot",
                tostring(slot),
                "state:",
                GetSummerCraftSlotTimeText(slot)
            )

            continue
        end

        local ok =
            StartRecipeForPhysicalSlot(slot)

        if ok ~= true then

            State.Status =
                "Stopped at slot "
                .. tostring(slot)

            State.LastAction =
                "Slot "
                .. tostring(slot)
                .. " failed, sequence stopped"

            return false
        end

        task.wait(delaySeconds)
    end

    State.Status =
        "Selected available slots started"

    State.LastAction =
        "Selected available slots started"

    return true
end

local function ClaimCampfireSlot(slot)

    if not IsGardenWorld() then

        State.Status =
            "Normal Garden only"

        State.LastAction =
            "Claim blocked: wrong world"

        return false
    end

    slot =
        tonumber(slot)
        or 1

    local remote =
        GetClaimCraftRemote()

    if not remote then

        State.Status =
            "ClaimCraft missing"

        State.LastAction =
            "ClaimCraft remote missing"

        warn("[HOLY EVENTS] ClaimCraft remote missing.")

        return false
    end

    local ok, err =
        pcall(function()

            remote:FireServer(
                slot
            )
        end)

    if ok ~= true then

        State.Status =
            "Claim failed"

        State.LastAction =
            "Claim failed"

        warn(
            "[HOLY EVENTS] Claim failed:",
            tostring(err)
        )

        return false
    end

    State.Status =
        "Claim slot "
        .. tostring(slot)
        .. " fired"

    State.LastAction =
        "Claim slot "
        .. tostring(slot)
        .. " fired"

    print(
        "[HOLY EVENTS] ClaimCraft fired slot:",
        tostring(slot)
    )

    return true
end

local function IsGuiObjectVisible(obj)

    if not obj then
        return false
    end

    local current =
        obj

    while current do

        if current:IsA("GuiObject")
        and current.Visible == false then
            return false
        end

        current =
            current.Parent
    end

    return true
end

local function GetSummerCraftSlotFrame(slot)

    slot =
        tonumber(slot)
        or 1

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    local summerGui =
        playerGui
        and playerGui:FindFirstChild("SummerCrafting")

    local craftingGui =
        summerGui
        and summerGui:FindFirstChild("Crafting")

    local main =
        craftingGui
        and craftingGui:FindFirstChild("Main")

    local campfire =
        main
        and main:FindFirstChild("Campfire")

    local craftingSlots =
        campfire
        and campfire:FindFirstChild("Crafting")

    local slotFrame =
        craftingSlots
        and craftingSlots:FindFirstChild(
            "Craft" .. tostring(slot)
        )

    return slotFrame
end

GetSummerCraftSlotTimeText = function(slot)

    local slotFrame =
        GetSummerCraftSlotFrame(slot)

    local timeLeft =
        slotFrame
        and slotFrame:FindFirstChild("TimeLeft")

    if not timeLeft
    or not timeLeft:IsA("TextLabel") then
        return ""
    end

    if not IsGuiObjectVisible(timeLeft) then
        return ""
    end

    return CleanText(timeLeft.Text)
end


IsSummerCraftSlotEmpty = function(slot)

    local text =
        GetSummerCraftSlotTimeText(slot)

    text =
        CleanText(text)

    if text == "" then
        return true
    end

    local upper =
        text:upper()

    if upper:find("EMPTY", 1, true) then
        return true
    end

    if upper:find("CLAIM", 1, true) then
        return false
    end

    if text:match("^%d+:%d+:%d+$")
    or text:match("^%d+:%d+$") then
        return false
    end

    return true
end

GetFirstEmptySummerSlot = function()

    for slot = 1, 3 do

        if IsSummerCraftSlotEmpty(slot) == true then
            return slot
        end
    end

    return nil
end


local function ParseSummerTimerSeconds(text)

    text =
        CleanText(text)

    if text == "" then
        return nil
    end

    local upper =
        text:upper()

    if upper:find("CLAIM", 1, true) then
        return 0
    end

    local h, m, s =
        text:match("^(%d+):(%d+):(%d+)$")

    if h and m and s then

        return tonumber(h) * 3600
            + tonumber(m) * 60
            + tonumber(s)
    end

    local mm, ss =
        text:match("^(%d+):(%d+)$")

    if mm and ss then

        return tonumber(mm) * 60
            + tonumber(ss)
    end

    return nil
end

local function FormatTimerSeconds(seconds)

    seconds =
        math.max(
            0,
            math.floor(tonumber(seconds) or 0)
        )

    local hours =
        math.floor(seconds / 3600)

    local minutes =
        math.floor((seconds % 3600) / 60)

    local secs =
        seconds % 60

    if hours > 0 then

        return string.format(
            "%d:%02d:%02d",
            hours,
            minutes,
            secs
        )
    end

    return string.format(
        "%02d:%02d",
        minutes,
        secs
    )
end

local function GetSummerCraftSlotRealEta(slot)

    local text =
        GetSummerCraftSlotTimeText(slot)

    local seconds =
        ParseSummerTimerSeconds(text)

    if seconds == nil then
        return "unknown"
    end

    if seconds <= 0 then
        return "ready"
    end

    local speed =
        tonumber(State.TimerSpeed)
        or 1

    speed =
        math.max(
            speed,
            0.01
        )

    return FormatTimerSeconds(
        seconds / speed
    )
end

local function GetSummerTimerStatusText()

    local lines = {}

    table.insert(
        lines,
        "Timer Speed: "
            .. string.format(
                "%.2fx",
                tonumber(State.TimerSpeed) or 1
            )
    )

    for slot = 1, 3 do

        local gameText =
            GetSummerCraftSlotTimeText(slot)

        if gameText == "" then
            gameText = "empty/unknown"
        end

        table.insert(
            lines,
            "Slot "
                .. tostring(slot)
                .. ": "
                .. gameText
                .. " → real "
                .. GetSummerCraftSlotRealEta(slot)
        )
    end

    return table.concat(
        lines,
        "\n"
    )
end

local function CalibrateSummerTimerSpeed()

    if State.TimerProbeRunning == true then

        State.Status =
            "Timer calibration already running"

        State.LastAction =
            "Timer calibration already running"

        return
    end

    State.TimerProbeRunning =
        true

    State.Status =
        "Calibrating timer speed"

    State.LastAction =
        "Timer calibration started"

    task.spawn(function()

        local first = {}

        for slot = 1, 3 do

            first[slot] =
                ParseSummerTimerSeconds(
                    GetSummerCraftSlotTimeText(slot)
                )
        end

        task.wait(30)

        local bestSpeed =
            nil

        for slot = 1, 3 do

            local before =
                first[slot]

            local after =
                ParseSummerTimerSeconds(
                    GetSummerCraftSlotTimeText(slot)
                )

            if before
            and after
            and before > after then

                local dropped =
                    before - after

                local speed =
                    dropped / 30

                if speed > 0 then
                    bestSpeed =
                        speed
                end
            end
        end

        if bestSpeed then

            State.TimerSpeed =
                bestSpeed

            State.Status =
                "Timer speed: "
                .. string.format("%.2fx", bestSpeed)

            State.LastAction =
                "Timer calibrated to "
                .. string.format("%.2fx", bestSpeed)

            print(
                "[HOLY EVENTS] Timer speed calibrated:",
                string.format("%.2fx", bestSpeed)
            )
        else

            State.Status =
                "Timer calibration failed"

            State.LastAction =
                "Could not detect timer speed"

            warn("[HOLY EVENTS] Timer calibration failed.")
        end

        State.TimerProbeRunning =
            false
    end)
end

local function IsSummerCraftSlotReady(slot)

    local text =
        GetSummerCraftSlotTimeText(slot)

    local upper =
        text:upper()

    return upper == "CLAIM"
        or upper == "CLAIM!"
        or upper:find("CLAIM", 1, true) ~= nil
end

local function IsSummerCraftClaimReady()

    for slot = 1, 3 do

        if IsSummerCraftSlotReady(slot) then
            return true
        end
    end

    return false
end

local function ClaimAllCampfireSlots()

    local claimedAny =
        false

    for slot = 1, 3 do

        if IsSummerCraftSlotReady(slot) then

            ClaimCampfireSlot(slot)

            claimedAny =
                true

            task.wait(0.20)
        end
    end

    if claimedAny ~= true then

        State.Status =
            "No ready slots"

        State.LastAction =
            "Claim All skipped: no CLAIM slots"

        print("[HOLY EVENTS] Claim All skipped. No ready slots.")
    end

    return claimedAny
end

local function BuildRecipeDump()

    RefreshSummerRecipeDatabase()

    local lines = {}

    table.insert(lines, "-- HOLY EVENTS RECIPE DATABASE DUMP")
    table.insert(lines, "-- Recipes found: " .. tostring(#State.RecipeNames))
    table.insert(lines, "")

    for _, recipeName in ipairs(State.RecipeNames) do

        local recipe =
            State.Recipes[recipeName]

        table.insert(lines, "Recipe: " .. recipe.Name)
        table.insert(lines, "CraftId: " .. recipe.CraftId)

        for _, material in ipairs(recipe.Materials) do

            table.insert(
                lines,
                "  Material "
                    .. tostring(material.Index)
                    .. ": "
                    .. material.Type
                    .. " / "
                    .. material.Name
                    .. " x"
                    .. tostring(material.Amount)
            )
        end

        for _, currency in ipairs(recipe.Currency) do

            table.insert(
                lines,
                "  Currency: "
                    .. currency.Name
                    .. " "
                    .. tostring(currency.Amount)
            )
        end

        table.insert(lines, "")
    end

    local output =
        table.concat(lines, "\n")

    CopyToClipboard(output)

    if type(writefile) == "function" then
        pcall(function()
            writefile(
                "HOLY_ParsedSummerRecipes.txt",
                output
            )
        end)
    end

    State.Status =
        "Recipe dump copied"

    State.LastAction =
        "Recipe dump copied"

    print(output)

    return output
end
--==================================================
-- [9] UI SCALE
-- Fixed percent scaling: 100% to 50%.
--==================================================

local function FindHolyEventsScreenGui()

    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    if not playerGui then
        return nil
    end

    for _, gui in ipairs(playerGui:GetChildren()) do

        if gui:IsA("ScreenGui") then

            local guiName =
                tostring(gui.Name or ""):lower()

            if guiName:find("obsidian", 1, true)
            or guiName:find("holy", 1, true)
            or guiName:find("events", 1, true) then

                return gui
            end

            for _, obj in ipairs(gui:GetDescendants()) do

                if obj:IsA("TextLabel")
                or obj:IsA("TextButton") then

                    local text =
                        tostring(obj.Text or ""):lower()

                    if text:find("holy", 1, true)
                    or text:find("events", 1, true)
                    or text:find("campfire", 1, true) then

                        return gui
                    end
                end
            end
        end
    end

    return nil
end

local function ApplyUIScalePercent(percent)

    percent =
        tonumber(percent)
        or State.UIScalePercent
        or 100

    percent =
        math.clamp(
            math.floor(percent),
            50,
            100
        )

    State.UIScalePercent =
        percent

    MarkConfigDirty()

    local scale =
        percent / 100

    local gui =
        FindHolyEventsScreenGui()

    if not gui then

        State.Status =
            "UI scale stored"

        State.LastAction =
            "UI scale stored: "
            .. tostring(percent)
            .. "%"

        warn("[HOLY EVENTS] Could not find Holy Events ScreenGui yet.")

        return false
    end

    local uiScale =
        gui:FindFirstChild("HolyEventsUIScale")

    if not uiScale then

        uiScale =
            Instance.new("UIScale")

        uiScale.Name =
            "HolyEventsUIScale"

        uiScale.Parent =
            gui
    end

    uiScale.Scale =
        scale

    State.Status =
        "UI scale "
        .. tostring(percent)
        .. "%"

    State.LastAction =
        "UI scale set to "
        .. tostring(percent)
        .. "%"

    print(
        "[HOLY EVENTS] UI scale set:",
        tostring(percent) .. "%"
    )

    return true
end

--==================================================
-- [9.5] DEV TOOL LOADER
--==================================================

local function SafeHolyEventsToolExec(url, label)

    url =
        tostring(url or "")

    label =
        tostring(label or "Tool")

    if url == "" then

        State.Status =
            label .. " missing URL"

        State.LastAction =
            label .. " missing URL"

        warn("[HOLY EVENTS DEV] Missing URL for", label)

        return false
    end

    task.spawn(function()

        State.Status =
            "Loading "
            .. label

        State.LastAction =
            "Loading "
            .. label

        print("[HOLY EVENTS DEV] Loading:", label)

        local okSource, source =
            pcall(function()
                return game:HttpGet(url)
            end)

        if okSource ~= true
        or type(source) ~= "string"
        or source == "" then

            State.Status =
                label .. " HttpGet failed"

            State.LastAction =
                label .. " HttpGet failed"

            warn("[HOLY EVENTS DEV] HttpGet failed:", label)

            return
        end

        local chunk, compileErr =
            loadstring(source)

        if type(chunk) ~= "function" then

            State.Status =
                label .. " compile failed"

            State.LastAction =
                label .. " compile failed"

            warn(
                "[HOLY EVENTS DEV] Compile failed:",
                label,
                tostring(compileErr)
            )

            return
        end

        local okRun, runErr =
            pcall(chunk)

        if okRun ~= true then

            State.Status =
                label .. " runtime failed"

            State.LastAction =
                label .. " runtime failed"

            warn(
                "[HOLY EVENTS DEV] Runtime failed:",
                label,
                tostring(runErr)
            )

            return
        end

        State.Status =
            label .. " loaded"

        State.LastAction =
            label .. " loaded"

        print("[HOLY EVENTS DEV] Loaded:", label)
    end)

    return true
end

--==================================================
-- [10] WINDOW
--==================================================

local Window =
    Library:CreateWindow({
        Title = '<font color="rgb(255,146,79)">Holy</font> <font color="rgb(255,221,128)"><b>Events</b></font>',
        Footer = "holy events · v0.1",
        ToggleKeybind = Enum.KeyCode.LeftAlt,
        Font = Enum.Font.GothamMedium,
        Center = true,
        AutoShow = true,

        Size = UDim2.fromOffset(720, 460),
        CornerRadius = 6,

        GlobalSearch = true,
        EnableCompacting = true,
        EnableSidebarResize = true,
        MinSidebarWidth = 150,
    })

--==================================================
-- [11] TABS
--==================================================

local Tabs = {
    Home =
        Window:AddTab({
            Name = "Home",
            Icon = "home",
            Description = "Status.",
        }),

    Events =
        Window:AddTab({
            Name = "Events",
            Icon = "flame",
            Description = "Event crafting.",
        }),

    Settings =
        Window:AddTab({
            Name = "Settings",
            Icon = "settings",
            Description = "UI settings.",
        }),
}

--==================================================
-- [12] GROUPBOX HELPERS
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

--==================================================
-- [13] HOME TAB
--==================================================

local HomeBox =
    AddLeftBox(
        Tabs.Home,
        "Home",
        "sparkles"
    )

local HomeStatusBox =
    AddRightBox(
        Tabs.Home,
        "Status",
        "activity"
    )

HomeBox:AddLabel({
    Text = '<font color="rgb(255,221,128)"><b>Holy Events</b></font>',
    DoesWrap = false,
    Size = 16,
})

HomeBox:AddLabel({
    Text = "Fresh event-only script.\nOnly Campfire Egg crafting is included.",
    DoesWrap = true,
    Size = 13,
})

local HomeButtons =
    HomeBox:AddButton({
        Text = "Copy Server",
        Tooltip = "Copies placeId:jobId.",
        Func = function()

            local payload =
                tostring(game.PlaceId)
                .. ":"
                .. tostring(game.JobId)

            if CopyToClipboard(payload) then

                State.LastAction =
                    "Copied server"

                State.Status =
                    "Server copied"
            end
        end,
    })

HomeButtons:AddButton({
    Text = "Rejoin",
    Tooltip = "Rejoin current server.",
    Func = function()

        pcall(function()

            TeleportService:TeleportToPlaceInstance(
                game.PlaceId,
                game.JobId,
                LocalPlayer
            )
        end)

        State.LastAction =
            "Rejoin requested"
    end,
})

HomeButtons:AddButton({
    Text = "Garden",
    Tooltip = "Teleport to Normal Garden.",
    Func = function()

        pcall(function()

            TeleportService:Teleport(
                GROW_A_GARDEN_PLACE_ID,
                LocalPlayer
            )
        end)

        State.LastAction =
            "Garden teleport requested"
    end,
})

local WorldLabel =
    HomeStatusBox:AddLabel({
        Text = "World: " .. GetWorldName(),
        DoesWrap = false,
        Size = 13,
    })

local PlaceLabel =
    HomeStatusBox:AddLabel({
        Text = "PlaceId: " .. tostring(game.PlaceId),
        DoesWrap = false,
        Size = 13,
    })

local SessionLabel =
    HomeStatusBox:AddLabel({
        Text = "Session: 00:00",
        DoesWrap = false,
        Size = 13,
    })

local StatusLabel =
    HomeStatusBox:AddLabel({
        Text = "Status: Ready",
        DoesWrap = true,
        Size = 13,
    })

local ActionLabel =
    HomeStatusBox:AddLabel({
        Text = "Last Action: Loaded",
        DoesWrap = true,
        Size = 13,
    })

--==================================================
-- [14] EVENTS TAB
--==================================================

RefreshSummerRecipeDatabase()

local function GetRecipeDropdownValues()

    if #State.RecipeNames <= 0 then
        return {
            "Campfire Egg",
        }
    end

    return State.RecipeNames
end

local EventBox =
    AddLeftBox(
        Tabs.Events,
        "Event Crafter",
        "flame"
    )

local EventStatusBox =
    AddRightBox(
        Tabs.Events,
        "Status",
        "package"
    )

EventBox:AddLabel({
    Text = '<font color="rgb(255,146,79)"><b>AUTO START</b></font>',
    DoesWrap = false,
    Size = 15,
})

EventBox:AddToggle(
    "HolyEventsAutoStart",
    {
        Text = "Enable Auto Start",
        Default = false,
        Tooltip = "Repeatedly starts the selected Slot 1, Slot 2, Slot 3 recipes.",
    }
):OnChanged(function(value)

    State.AutoStart =
        value == true

    State.AutoStartCooldown =
        false

    State.AutoStartCycleDone =
        false

    State.Status =
        State.AutoStart and "Auto start watching empty slots" or "Auto start off"

    State.LastAction =
        State.Status
end)

EventBox:AddInput(
    "HolyEventsAutoStartDelay",
    {
        Text = "Start Delay",
        Default = tostring(State.AutoStartDelay),
        Placeholder = "5",
        Numeric = true,
        Finished = true,
        ClearTextOnFocus = false,
        ClearTextOnBlur = false,
        AllowEmpty = false,
        EmptyReset = "5",
        Tooltip = "Seconds between starting each selected recipe.",
    }
):OnChanged(function(value)

    State.AutoStartDelay =
        math.clamp(
            tonumber(value) or 5,
            1,
            60
        )
end)

EventBox:AddDivider()

EventBox:AddLabel({
    Text = '<font color="rgb(255,221,128)"><b>SLOT RECIPES</b></font>',
    DoesWrap = false,
    Size = 14,
})

local recipeValues =
    GetRecipeDropdownValues()

EventBox:AddDropdown(
    "HolyEventsSlot1Recipe",
    {
        Text = "Slot 1 Recipe",
        Values = recipeValues,
        Default = State.SlotRecipes[1],
        Multi = false,
        Tooltip = "Recipe to start first.",
    }
):OnChanged(function(value)

    State.SlotRecipes[1] =
        CleanText(value)
end)

EventBox:AddDropdown(
    "HolyEventsSlot2Recipe",
    {
        Text = "Slot 2 Recipe",
        Values = recipeValues,
        Default = State.SlotRecipes[2],
        Multi = false,
        Tooltip = "Recipe to start second.",
    }
):OnChanged(function(value)

    State.SlotRecipes[2] =
        CleanText(value)
end)

EventBox:AddDropdown(
    "HolyEventsSlot3Recipe",
    {
        Text = "Slot 3 Recipe",
        Values = recipeValues,
        Default = State.SlotRecipes[3],
        Multi = false,
        Tooltip = "Recipe to start third.",
    }
):OnChanged(function(value)

    State.SlotRecipes[3] =
        CleanText(value)
end)

local ActionButton =
    EventBox:AddButton({
        Text = "Start Selected Slots Now",
        Tooltip = "Strictly starts Slot 1, then Slot 2, then Slot 3. If one slot fails, the sequence stops.",
        Func = function()

            task.spawn(function()

                StartSelectedRecipesNow()
            end)
        end,
    })

ActionButton:AddButton({
    Text = "Refresh Recipes",
    Tooltip = "Rebuilds recipe database from SummerCrafting UI.",
    Func = function()

        RefreshSummerRecipeDatabase()
    end,
})

ActionButton:AddButton({
    Text = "Copy Recipe Dump",
    Tooltip = "Copies/writes parsed recipe database.",
    Func = function()

        BuildRecipeDump()
    end,
})


ActionButton:AddButton({
    Text = "Calibrate Timer",
    Tooltip = "Measures the campfire countdown speed over 30 seconds.",
    Func = function()

        CalibrateSummerTimerSpeed()
    end,
})


ActionButton:AddButton({
    Text = "Debug Selected Slots",
    Tooltip = "Prints exact recipe requirements and payload status for Slot 1, 2, and 3.",
    Func = function()

        print("========== HOLY SLOT RECIPE DEBUG ==========")

        for slot = 1, 3 do

            local recipeName =
                CleanText(
                    State.SlotRecipes[slot]
                )

            local recipe =
                State.Recipes[recipeName]

            print("------------------------------------------")
            print("Slot:", slot)
            print("Selected:", recipeName)
            print("Slot UI:", GetSummerCraftSlotTimeText(slot))
            print("Available:", IsSummerCraftSlotAvailableForStart(slot))
            print("Reserved:", IsSlotReserved(slot))

            if not recipe then

                print("ERROR: Recipe not found in database.")
                continue
            end

            print("CraftId:", recipe.CraftId)

            for _, material in ipairs(recipe.Materials) do

                if material.Type == "Cosmetic" then

                    local cosmeticToken =
                        GetCosmeticMaterialToken(
                            material.Name
                        )

                    print(
                        "Material:",
                        material.Type,
                        material.Name,
                        "x" .. tostring(material.Amount),
                        "| Token:",
                        cosmeticToken ~= "" and cosmeticToken or "MISSING"
                    )
                else

                    local count =
                        CountExactInventoryItem(material.Name)

                    local uuids =
                        FindInventoryUUIDsForItem(
                            material.Name,
                            material.Amount
                        )

                    print(
                        "Material:",
                        material.Type,
                        material.Name,
                        "x" .. tostring(material.Amount),
                        "| Count:",
                        tostring(count),
                        "| UUIDs:",
                        tostring(#uuids)
                    )

                    if #uuids > 0 then
                        print("First UUID:", uuids[1])
                    end
                end
            end

            for _, currency in ipairs(recipe.Currency) do

                print(
                    "Currency:",
                    currency.Name,
                    tostring(currency.Amount)
                )
            end

            local payload, payloadError =
                BuildRecipePayload(recipe)

            if payload then

                print("Payload: OK")

                for groupIndex, group in pairs(payload) do
                    print(
                        "Payload group",
                        tostring(groupIndex),
                        table.concat(group, ", ")
                    )
                end
            else

                print("Payload ERROR:", tostring(payloadError))
            end
        end

        print("============================================")
    end,
})

EventBox:AddDivider()

EventBox:AddLabel({
    Text = '<font color="rgb(255,146,79)"><b>FIRE KEEP ALIVE</b></font>',
    DoesWrap = false,
    Size = 14,
})

EventBox:AddToggle(
    "HolyEventsAutoSubmitFire",
    {
        Text = "Enable Auto Submit",
        Default = false,
        Tooltip = "Equips selected harvested fruits and burns them at the Summer Fire.",
    }
):OnChanged(function(value)

    State.AutoSubmitFire =
        value == true

    State.Status =
        State.AutoSubmitFire and "Auto submit on" or "Auto submit off"

    State.LastAction =
        State.Status
end)

EventBox:AddInput(
    "HolyEventsAutoSubmitDelay",
    {
        Text = "Submit Delay",
        Default = tostring(State.AutoSubmitDelay),
        Placeholder = "2.5",
        Numeric = true,
        Finished = true,
        ClearTextOnFocus = false,
        ClearTextOnBlur = false,
        AllowEmpty = false,
        EmptyReset = "2.5",
        Tooltip = "Seconds between burn submits.",
    }
):OnChanged(function(value)

    State.AutoSubmitDelay =
        math.clamp(
            tonumber(value) or 2.5,
            1.5,
            15
        )

    if tonumber(value) ~= State.AutoSubmitDelay then
        State.Status =
            "Submit delay clamped"

        State.LastAction =
            "Submit delay set to "
            .. tostring(State.AutoSubmitDelay)
    end
end)


EventBox:AddInput(
    "HolyEventsAutoSubmitEmberCap",
    {
        Text = "Ember Cap",
        Default = tostring(State.AutoSubmitEmberCap),
        Placeholder = "78000",
        Numeric = true,
        Finished = true,
        ClearTextOnFocus = false,
        ClearTextOnBlur = false,
        AllowEmpty = false,
        EmptyReset = "78000",
        Tooltip = "Auto Submit stops when current embers are at or above this number. Use 0 to disable cap.",
    }
):OnChanged(function(value)

    State.AutoSubmitEmberCap =
        math.clamp(
            tonumber(value) or 78000,
            0,
            80000
        )

    State.Status =
        "Ember cap set: "
        .. tostring(State.AutoSubmitEmberCap)

    State.LastAction =
        State.Status
end)

RefreshSubmitPlantListFromInventory()

EventBox:AddDropdown(
    "HolyEventsSubmitPlants",
    {
        Text = "Submit Plants",
        Values = State.SubmitPlantNameList,
        Default = {
            "Alien Apple",
        },
        Multi = true,
        Tooltip = "Only these harvested fruit tools will be submitted. Seeds are ignored.",
    }
):OnChanged(function(value)

    State.SubmitPlantNames =
        {}

    if type(value) == "table" then

        for plantName, enabled in pairs(value) do

            if enabled == true then

                State.SubmitPlantNames[
                    CleanText(plantName)
                ] = true
            end
        end
    elseif type(value) == "string" then

        local plantName =
            CleanText(value)

        if plantName ~= "" then
            State.SubmitPlantNames[plantName] = true
        end
    end

    State.Status =
        "Submit plants updated"

    State.LastAction =
        GetSelectedSubmitPlantText()
end)

local SubmitButton =
    EventBox:AddButton({
        Text = "Submit Once",
        Tooltip = "Equips one selected harvested fruit and burns it once.",
        Func = function()

            SubmitHeldPlantOnce()
        end,
    })

SubmitButton:AddButton({
    Text = "Refresh Submit Plants",
    Tooltip = "Rebuilds the submit plant dropdown from Backpack/Character fruit tools.",
    Func = function()

        RefreshSubmitPlantListFromInventory()
    end,
})


EventBox:AddDivider()

EventBox:AddLabel({
    Text = '<font color="rgb(132,204,22)"><b>AUTO COLLECT FRUITS</b></font>',
    DoesWrap = false,
    Size = 14,
})

EventBox:AddToggle(
    "HolyEventsAutoCollectFruits",
    {
        Text = "Enable Auto Collect",
        Default = false,
        Tooltip = "Collects selected fruits from your own garden only.",
    }
):OnChanged(function(value)

    State.AutoCollectFruits =
        value == true

    State.AutoCollectBusy =
        false

    State.Status =
        State.AutoCollectFruits and "Auto collect on" or "Auto collect off"

    State.LastAction =
        State.Status
end)

EventBox:AddInput(
    "HolyEventsAutoCollectDelay",
    {
        Text = "Collect Delay",
        Default = tostring(State.AutoCollectDelay),
        Placeholder = "0.35",
        Numeric = true,
        Finished = true,
        ClearTextOnFocus = false,
        ClearTextOnBlur = false,
        AllowEmpty = false,
        EmptyReset = "0.35",
        Tooltip = "Seconds between collect batches.",
    }
):OnChanged(function(value)

    State.AutoCollectDelay =
        math.clamp(
            tonumber(value) or 0.35,
            0.25,
            10
        )

    if tonumber(value) ~= State.AutoCollectDelay then

        State.Status =
            "Collect delay clamped"

        State.LastAction =
            "Collect delay set to "
            .. tostring(State.AutoCollectDelay)
    end
end)

EventBox:AddInput(
    "HolyEventsAutoCollectBatchSize",
    {
        Text = "Batch Size",
        Default = tostring(State.AutoCollectBatchSize),
        Placeholder = "25",
        Numeric = true,
        Finished = true,
        ClearTextOnFocus = false,
        ClearTextOnBlur = false,
        AllowEmpty = false,
        EmptyReset = "25",
        Tooltip = "How many unique fruits to collect per batch.",
    }
):OnChanged(function(value)

    State.AutoCollectBatchSize =
        math.clamp(
            tonumber(value) or 25,
            1,
            100
        )

    if tonumber(value) ~= State.AutoCollectBatchSize then

        State.Status =
            "Batch size clamped"

        State.LastAction =
            "Batch size set to "
            .. tostring(State.AutoCollectBatchSize)
    end
end)

EventBox:AddInput(
    "HolyEventsAutoCollectMaxTools",
    {
        Text = "Max Tool Count",
        Default = tostring(State.AutoCollectMaxToolCount),
        Placeholder = "1300",
        Numeric = true,
        Finished = true,
        ClearTextOnFocus = false,
        ClearTextOnBlur = false,
        AllowEmpty = false,
        EmptyReset = "1300",
        Tooltip = "Extra safety cap. Auto collect stops if Backpack + Character tools reaches this. Use 0 to disable.",
    }
):OnChanged(function(value)

    State.AutoCollectMaxToolCount =
        math.clamp(
            tonumber(value) or 1300,
            0,
            5000
        )
end)

RefreshCollectPlantListFromOwnFarm()

EventBox:AddDropdown(
    "HolyEventsCollectPlants",
    {
        Text = "Collect Plants",
        Values = State.CollectPlantNameList,
        Default = State.CollectPlantNameList,
        Multi = true,
        Tooltip = "Only these plants from your own garden will be collected.",
    }
):OnChanged(function(value)

    State.CollectPlantNames =
        {}

    if type(value) == "table" then

        for plantName, enabled in pairs(value) do

            if enabled == true then

                State.CollectPlantNames[
                    CleanText(plantName)
                ] = true
            end
        end
    elseif type(value) == "string" then

        local plantName =
            CleanText(value)

        if plantName ~= "" then
            State.CollectPlantNames[plantName] = true
        end
    end

    State.Status =
        "Collect plants updated"

    State.LastAction =
        GetSelectedCollectPlantText()
end)

local CollectButton =
    EventBox:AddButton({
        Text = "Collect Once",
        Tooltip = "Collects one safe batch from your own farm.",
        Func = function()

            CollectOwnFarmBatchOnce()
        end,
    })

CollectButton:AddButton({
    Text = "Refresh Collect Plants",
    Tooltip = "Refreshes the own-farm plant dropdown.",
    Func = function()

        RefreshCollectPlantListFromOwnFarm()
    end,
})

EventBox:AddDivider()

EventBox:AddLabel({
    Text = '<font color="rgb(196,181,253)"><b>CLAIMING</b></font>',
    DoesWrap = false,
    Size = 14,
})

local ClaimButton =
    EventBox:AddButton({
        Text = "Claim All",
        Tooltip = "Fires ClaimCraft for slots 1, 2, and 3.",
        Func = function()

            ClaimAllCampfireSlots()
        end,
    })

ClaimButton:AddButton({
    Text = "Slot 1",
    Tooltip = "Manual claim slot 1.",
    Func = function()

        ClaimCampfireSlot(1)
    end,
})

ClaimButton:AddButton({
    Text = "Slot 2",
    Tooltip = "Manual claim slot 2.",
    Func = function()

        ClaimCampfireSlot(2)
    end,
})

ClaimButton:AddButton({
    Text = "Slot 3",
    Tooltip = "Manual claim slot 3.",
    Func = function()

        ClaimCampfireSlot(3)
    end,
})

EventBox:AddToggle(
    "AutoClaimCampfireEgg",
    {
        Text = "Auto Claim When Ready",
        Default = false,
        Tooltip = "Only claims when the game UI shows CLAIM.",
    }
):OnChanged(function(value)

    State.AutoClaim =
        value == true

    State.Status =
        State.AutoClaim and "Auto claim on" or "Auto claim off"

    State.LastAction =
        State.Status
end)

EventBox:AddInput(
    "AutoClaimDelayInput",
    {
        Text = "Auto Claim Check Delay",
        Default = tostring(State.AutoClaimDelay),
        Placeholder = "1.5",
        Numeric = true,
        Finished = true,
        ClearTextOnFocus = false,
        ClearTextOnBlur = false,
        AllowEmpty = false,
        EmptyReset = "1.5",
        Tooltip = "Seconds between ready checks.",
    }
):OnChanged(function(value)

    State.AutoClaimDelay =
        math.clamp(
            tonumber(value) or 1.5,
            0.5,
            30
        )
end)

local RecipeDbLabel =
    EventStatusBox:AddLabel({
        Text = "Recipe DB: checking...",
        DoesWrap = true,
        Size = 13,
    })

local SlotStatusLabel =
    EventStatusBox:AddLabel({
        Text = "Slot 1: -\nSlot 2: -\nSlot 3: -",
        DoesWrap = true,
        Size = 13,
    })

local SelectedRecipeLabel =
    EventStatusBox:AddLabel({
        Text = "Selected Recipe:\n-",
        DoesWrap = true,
        Size = 12,
    })

local ClaimReadyLabel =
    EventStatusBox:AddLabel({
        Text = "Claim Ready: checking...",
        DoesWrap = true,
        Size = 13,
    })


local TimerEtaLabel =
    EventStatusBox:AddLabel({
        Text = "Timer ETA: checking...",
        DoesWrap = true,
        Size = 13,
    })


local FireSubmitLabel =
    EventStatusBox:AddLabel({
        Text = "Fire Submit: checking...",
        DoesWrap = true,
        Size = 13,
    })


local AutoCollectLabel =
    EventStatusBox:AddLabel({
        Text = "Auto Collect: checking...",
        DoesWrap = true,
        Size = 13,
    })
--==================================================
-- [15] SETTINGS TAB
--==================================================

local SettingsBox =
    AddLeftBox(
        Tabs.Settings,
        "UI Settings",
        "settings"
    )

local SettingsInfoBox =
    AddRightBox(
        Tabs.Settings,
        "Info",
        "info"
    )

SettingsBox:AddLabel({
    Text = '<font color="rgb(255,221,128)"><b>UI SCALE</b></font>',
    DoesWrap = false,
    Size = 14,
})

SettingsBox:AddLabel({
    Text = "Choose a fixed scale. 100% is default. 50% is smallest.",
    DoesWrap = true,
    Size = 12,
})

local ScaleButton =
    SettingsBox:AddButton({
        Text = "Scale 100%",
        Tooltip = "Default UI size.",
        Func = function()

            ApplyUIScalePercent(100)
        end,
    })

ScaleButton:AddButton({
    Text = "90%",
    Tooltip = "Slightly smaller UI.",
    Func = function()

        ApplyUIScalePercent(90)
    end,
})

ScaleButton:AddButton({
    Text = "80%",
    Tooltip = "Compact UI.",
    Func = function()

        ApplyUIScalePercent(80)
    end,
})

ScaleButton:AddButton({
    Text = "70%",
    Tooltip = "Small UI.",
    Func = function()

        ApplyUIScalePercent(70)
    end,
})

ScaleButton:AddButton({
    Text = "60%",
    Tooltip = "Very small UI.",
    Func = function()

        ApplyUIScalePercent(60)
    end,
})


SettingsBox:AddDivider()

SettingsBox:AddLabel({
    Text = '<font color="rgb(196,181,253)"><b>DEV TOOLS</b></font>',
    DoesWrap = false,
    Size = 14,
})

local DevToolButton =
    SettingsBox:AddButton({
        Text = "Remote Spy",
        Tooltip = "Open UtopiaSpy to inspect remote calls.",
        Func = function()

            SafeHolyEventsToolExec(
                "https://raw.githubusercontent.com/Klinac/scripts/main/utopia_spy.lua",
                "Remote Spy"
            )
        end,
    })

DevToolButton:AddButton({
    Text = "Dex Explorer",
    Tooltip = "Open Dex++ to inspect the live game tree.",
    Func = function()

        SafeHolyEventsToolExec(
            "https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua",
            "Dex Explorer"
        )
    end,
})

SettingsBox:AddLabel({
    Text = "Remote Spy logs remote calls.\nDex Explorer lets you inspect PlayerGui, Workspace, ReplicatedStorage, and live attributes.",
    DoesWrap = true,
    Size = 12,
})

ScaleButton:AddButton({
    Text = "50%",
    Tooltip = "Smallest UI scale.",
    Func = function()

        ApplyUIScalePercent(50)
    end,
})

SettingsBox:AddButton({
    Text = "Stop Runtime",
    Tooltip = "Stops loops for this script run.",
    Risky = true,
    DoubleClick = true,
    Func = function()

        RuntimeRoot.RunId =
            tostring(os.clock())
            .. "_stopped"

        State.AutoClaim =
            false

        State.Status =
            "Runtime stopped"

        State.LastAction =
            "Runtime stopped"

        warn("[HOLY EVENTS] Runtime stopped.")
    end,
})

SettingsInfoBox:AddLabel({
    Text = "This script is intentionally minimal.\nOnly Summer Campfire Egg crafting is included.",
    DoesWrap = true,
    Size = 13,
})

SettingsInfoBox:AddLabel({
    Text = "Remotes:\nSummerCraftingService.StartCraft\nSummerCraftingService.ClaimCraft",
    DoesWrap = true,
    Size = 12,
})

--==================================================
-- [16] LOOPS
--==================================================

task.spawn(function()

    while IsCurrentRun() do

        task.wait(0.75)

        SetControlText(
            WorldLabel,
            "World: " .. GetWorldName()
        )

        SetControlText(
            PlaceLabel,
            "PlaceId: " .. tostring(game.PlaceId)
        )

        SetControlText(
            SessionLabel,
            "Session: " .. FormatTime(State.StartedAt)
        )

        SetControlText(
            StatusLabel,
            "Status: " .. tostring(State.Status)
        )

        SetControlText(
            ActionLabel,
            "Last Action: " .. tostring(State.LastAction)
        )

        SetControlText(
            RecipeDbLabel,
            "Recipe DB: "
                .. tostring(#State.RecipeNames)
                .. " recipes"
        )

        local function FormatStartSlotLine(slot)

            local recipeName =
                tostring(State.SlotRecipes[slot] or "-")

            local stateText =
                GetSummerCraftSlotTimeText(slot)

            if stateText == "" then
                stateText = "blank"
            end

            local state =
                IsSummerCraftSlotAvailableForStart(slot)
                and "AVAILABLE"
                or "BUSY"

            if IsSlotReserved(slot) then
                state = "RESERVED"
            end

            return "Slot "
                .. tostring(slot)
                .. ": "
                .. recipeName
                .. " | "
                .. state
                .. " | "
                .. stateText
        end

        SetControlText(
            SlotStatusLabel,
            FormatStartSlotLine(1)
                .. "\n"
                .. FormatStartSlotLine(2)
                .. "\n"
                .. FormatStartSlotLine(3)
        )

        SetControlText(
            SelectedRecipeLabel,
            "Selected Recipe:\n"
                .. GetRecipeMaterialSummary(
                    State.SlotRecipes[1]
                )
        )

        SetControlText(
            ClaimReadyLabel,
            "Claim Ready: "
                .. tostring(IsSummerCraftClaimReady())
        )

        SetControlText(
            TimerEtaLabel,
            GetSummerTimerStatusText()
        )

        
        SetControlText(
            FireSubmitLabel,
            "Auto Submit: "
                .. tostring(State.AutoSubmitFire)
                .. "\nSelected: "
                .. GetSelectedSubmitPlantText()
                .. "\n"
                .. GetSummerEmberStatusText()
        )

    
        SetControlText(
            AutoCollectLabel,
            "Auto Collect: "
                .. tostring(State.AutoCollectFruits)
                .. "\nSelected: "
                .. GetSelectedCollectPlantText()
                .. "\nTools: "
                .. tostring(GetCurrentToolCount())
                .. " / "
                .. tostring(State.AutoCollectMaxToolCount)
                .. "\nBackpack Full: "
                .. tostring(IsBackpackFullFromNotification())
        )
    end
end)


task.spawn(function()

    while IsCurrentRun() do

        task.wait(
            math.clamp(
                tonumber(State.AutoCollectDelay) or 0.35,
                0.25,
                10
            )
        )

        if State.AutoCollectFruits == true
        and State.AutoCollectBusy ~= true then

            CollectOwnFarmBatchOnce()
        end
    end
end)

task.spawn(function()

    while IsCurrentRun() do

        task.wait(
            math.clamp(
                tonumber(State.AutoSubmitDelay) or 2.5,
                1.5,
                15
            )
        )

        if State.AutoSubmitFire == true
        and State.AutoSubmitBusy ~= true then

            SubmitHeldPlantOnce()
        end
    end
end)

task.spawn(function()

    while IsCurrentRun() do

        task.wait(1)

        if State.AutoStart == true
        and State.AutoStartCooldown ~= true then

            local slot =
                GetFirstAvailableSummerStartSlot()

            if slot then

                State.AutoStartCooldown =
                    true

                task.spawn(function()

                    local recipeName =
                        CleanText(
                            State.SlotRecipes[slot]
                        )

                    State.Status =
                        "Auto starting slot "
                        .. tostring(slot)
                        .. ": "
                        .. recipeName

                    State.LastAction =
                        State.Status

                    local ok =
                        StartRecipeForPhysicalSlot(slot)

                    if ok then

                        State.Status =
                            "Started slot "
                            .. tostring(slot)
                            .. ": "
                            .. recipeName

                        State.LastAction =
                            State.Status
                    else

                        State.Status =
                            "Auto start failed slot "
                            .. tostring(slot)

                        State.LastAction =
                            "Failed recipe: "
                            .. recipeName
                    end

                    task.wait(
                        math.clamp(
                            tonumber(State.AutoStartDelay) or 5,
                            2,
                            120
                        )
                    )

                    State.AutoStartCooldown =
                        false
                end)
            else

                State.Status =
                    "No available start slot"
            end
        end
    end
end)

task.spawn(function()

    while IsCurrentRun() do

        task.wait(
            math.clamp(
                tonumber(State.AutoClaimDelay) or 1.5,
                0.25,
                30
            )
        )

        if State.AutoClaim == true then

            local claimed =
                ClaimAllCampfireSlots()

            if claimed then

                State.Status =
                    "Auto claimed ready slot"

                State.LastAction =
                    "Auto claimed ready slot"

                task.wait(3)
            else

                State.Status =
                    "Waiting for ready slot"
            end
        end
    end
end)

--==================================================
-- [17] SAVE/THEME
-- Silent autosave.
--==================================================

pcall(function()

    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)

    SaveManager:IgnoreThemeSettings()

    ThemeManager:SetFolder("HolyEvents")
    SaveManager:SetFolder("HolyEvents")

    ThemeManager:ApplyTheme("Dark")

    SaveManager:Load(
        ConfigState.AutosaveName
    )
end)

ConfigState.Loading =
    false

RefreshSummerRecipeDatabase()

task.spawn(function()

    while IsCurrentRun() do

        task.wait(1)

        local snapshot =
            EncodeHolyEventsCustomSavePayload()

        if snapshot ~= ""
        and snapshot ~= ConfigState.LastSavedSnapshot then

            ConfigState.Dirty =
                true
        end

        if ConfigState.Dirty == true then

            ConfigState.Dirty =
                false

            pcall(function()

                SaveManager:Save(
                    ConfigState.AutosaveName
                )
            end)

            SaveHolyEventsCustomConfigNow(
                "auto"
            )
        end
    end
end)

task.defer(function()

    task.wait(0.5)

    ApplyUIScalePercent(
        State.UIScalePercent
    )
end)

print("[HOLY EVENTS] v0.2 dynamic recipes loaded in", GetWorldName())
