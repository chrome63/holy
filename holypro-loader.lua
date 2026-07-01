--==================================================
-- HOLY PUBLIC LOADER - OBSIDIAN VERSION
--==================================================

local Players =
    game:GetService("Players")

local HttpService =
    game:GetService("HttpService")

local CoreGui =
    game:GetService("CoreGui")

local LocalPlayer =
    Players.LocalPlayer
    or Players.PlayerAdded:Wait()

local HOLY_LOADER_API =
    "https://holy-loader-api.benjicapalot041.workers.dev"

local HOLY_OBSIDIAN_REPO =
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local HOLY_OBSIDIAN_LIBRARY_URL =
    HOLY_OBSIDIAN_REPO
    .. "Library.lua"

local HOLY_FOLDER =
    "HolyGAG2"

local HOLY_KEY_FILE =
    HOLY_FOLDER
    .. "/HolyAccessKey.txt"

local HOLY_SESSION_FILE =
    HOLY_FOLDER
    .. "/HolySession.json"

local HOLY_LOADER_VERSION =
    "holy-loader-obsidian-v1"

local HOLY_PUBLIC_LOADSTRING =
    [[loadstring(game:HttpGet("https://raw.githubusercontent.com/bencapalot041/holy/main/holy-loader.lua"))()]]

local HOLY_DISCORD_INVITE =
    ""

local HolyLoaderEnv =
    type(getgenv) == "function"
    and getgenv()
    or _G

pcall(function()

    if type(HolyLoaderEnv.HOLY_LOADER_STOP) == "function" then

        HolyLoaderEnv.HOLY_LOADER_STOP(
            "reload"
        )
    end
end)

local HOLY_LOADER_CONNECTIONS =
    {}

local HOLY_LOADER_GUI =
    nil

local HOLY_LOADER_LIBRARY =
    nil

local HOLY_LOADER_WINDOW =
    nil

local HOLY_LOADER_BUSY =
    false

local HOLY_LOADER_UI =
    {}

--==================================================
-- BASIC LOADER HELPERS
--==================================================

function HolyLoaderTrack(connection)

    if connection then

        table.insert(
            HOLY_LOADER_CONNECTIONS,
            connection
        )
    end

    return connection
end

function HolyLoaderStop(reason)

    for _, connection in ipairs(HOLY_LOADER_CONNECTIONS) do

        pcall(function()

            connection:Disconnect()
        end)
    end

    HOLY_LOADER_CONNECTIONS =
        {}

    if type(HOLY_LOADER_LIBRARY) == "table"
    and type(HOLY_LOADER_LIBRARY.Unload) == "function" then

        pcall(function()

            HOLY_LOADER_LIBRARY:Unload()
        end)
    end

    HOLY_LOADER_LIBRARY =
        nil

    HOLY_LOADER_WINDOW =
        nil

    if typeof(HOLY_LOADER_GUI) == "Instance" then

        pcall(function()

            HOLY_LOADER_GUI:Destroy()
        end)
    end

    HOLY_LOADER_GUI =
        nil

    HOLY_LOADER_UI =
        {}
end

HolyLoaderEnv.HOLY_LOADER_STOP =
    HolyLoaderStop

function HolyLoaderClean(value)

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

function HolyLoaderGetRequestFunction()

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

    if type(HolyLoaderEnv) == "table" then

        if type(HolyLoaderEnv.request) == "function" then

            return HolyLoaderEnv.request
        end

        if type(HolyLoaderEnv.http_request) == "function" then

            return HolyLoaderEnv.http_request
        end
    end

    return nil
end

function HolyLoaderCanUseFiles()

    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

function HolyLoaderEnsureFolder()

    if type(makefolder) ~= "function"
    or type(isfolder) ~= "function" then

        return false
    end

    local ok =
        pcall(function()

            if not isfolder(HOLY_FOLDER) then

                makefolder(
                    HOLY_FOLDER
                )
            end
        end)

    return ok == true
end

function HolyLoaderReadFile(path)

    if HolyLoaderCanUseFiles() ~= true then

        return ""
    end

    local exists =
        false

    pcall(function()

        exists =
            isfile(
                path
            )
    end)

    if exists ~= true then

        return ""
    end

    local ok,
        raw =
        pcall(function()

            return readfile(
                path
            )
        end)

    if ok == true then

        return HolyLoaderClean(
            raw
        )
    end

    return ""
end

function HolyLoaderWriteFile(path, text)

    if HolyLoaderCanUseFiles() ~= true then

        return false
    end

    HolyLoaderEnsureFolder()

    local ok =
        pcall(function()

            writefile(
                path,
                tostring(text or "")
            )
        end)

    return ok == true
end

function HolyLoaderDeleteFile(path)

    if type(delfile) ~= "function" then

        return false
    end

    local exists =
        false

    pcall(function()

        exists =
            isfile(
                path
            )
    end)

    if exists ~= true then

        return false
    end

    local ok =
        pcall(function()

            delfile(
                path
            )
        end)

    return ok == true
end

function HolyLoaderCopyText(text)

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

function HolyLoaderDecodeJson(body)

    if type(body) ~= "string" then

        return nil,
            "no body"
    end

    if body:sub(1, 3) == "\239\187\191" then

        body =
            body:sub(4)
    end

    local ok,
        data =
        pcall(function()

            return HttpService:JSONDecode(
                body
            )
        end)

    if ok == true
    and type(data) == "table" then

        return data,
            nil
    end

    return nil,
        "invalid json"
end

function HolyLoaderHttpGetRaw(url)

    url =
        HolyLoaderClean(
            url
        )

    if url == "" then

        return nil,
            "empty url"
    end

    local requestFunction =
        HolyLoaderGetRequestFunction()

    if type(requestFunction) == "function" then

        local ok,
            response =
            pcall(function()

                return requestFunction({
                    Url =
                        url,

                    Method =
                        "GET",

                    Headers = {
                        ["Accept"] =
                            "text/plain",

                        ["Cache-Control"] =
                            "no-cache",
                    },
                })
            end)

        if ok == true then

            if type(response) == "string" then

                return response,
                    nil
            end

            if type(response) == "table" then

                return tostring(
                    response.Body
                    or response.body
                    or response.ResponseBody
                    or response.responseBody
                    or ""
                ),
                    nil
            end
        end

        return nil,
            tostring(response)
    end

    local ok,
        body =
        pcall(function()

            return game:HttpGet(
                url,
                true
            )
        end)

    if ok == true then

        return tostring(body or ""),
            nil
    end

    return nil,
        tostring(body)
end

function HolyLoaderRequestJson(method, path, payload)

    local url =
        HOLY_LOADER_API
        .. path

    local encoded =
        nil

    if payload ~= nil then

        local ok,
            result =
            pcall(function()

                return HttpService:JSONEncode(
                    payload
                )
            end)

        if ok ~= true then

            return nil,
                "json encode failed"
        end

        encoded =
            result
    end

    local requestFunction =
        HolyLoaderGetRequestFunction()

    if type(requestFunction) == "function" then

        local options = {
            Url =
                url,

            Method =
                tostring(method or "GET"),

            Headers = {
                ["Accept"] =
                    "application/json",

                ["Cache-Control"] =
                    "no-cache",
            },
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

        return HolyLoaderDecodeJson(
            tostring(body or "")
        )
    end

    if method == "POST"
    and encoded ~= nil then

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

            return HolyLoaderDecodeJson(
                tostring(body or "")
            )
        end

        return nil,
            tostring(body)
    end

    local ok,
        body =
        pcall(function()

            return game:HttpGet(
                url,
                true
            )
        end)

    if ok == true then

        return HolyLoaderDecodeJson(
            tostring(body or "")
        )
    end

    return nil,
        tostring(body)
end

function HolyLoaderGetText(path)

    local url =
        HOLY_LOADER_API
        .. path

    local requestFunction =
        HolyLoaderGetRequestFunction()

    if type(requestFunction) == "function" then

        local ok,
            response =
            pcall(function()

                return requestFunction({
                    Url =
                        url,

                    Method =
                        "GET",

                    Headers = {
                        ["Accept"] =
                            "text/plain",

                        ["Cache-Control"] =
                            "no-cache",
                    },
                })
            end)

        if ok == true then

            if type(response) == "string" then

                return response,
                    nil
            end

            if type(response) == "table" then

                return tostring(
                    response.Body
                    or response.body
                    or response.ResponseBody
                    or response.responseBody
                    or ""
                ),
                    nil
            end
        end

        return nil,
            tostring(response)
    end

    local ok,
        body =
        pcall(function()

            return game:HttpGet(
                url,
                true
            )
        end)

    if ok == true then

        return tostring(body or ""),
            nil
    end

    return nil,
        tostring(body)
end

function HolyLoaderCompiler()

    if type(loadstring) == "function" then

        return loadstring
    end

    if type(load) == "function" then

        return load
    end

    return nil
end

function HolyLoaderFormatTime(seconds)

    seconds =
        math.max(
            0,
            math.floor(
                tonumber(seconds)
                or 0
            )
        )

    local days =
        math.floor(seconds / 86400)

    local hours =
        math.floor((seconds % 86400) / 3600)

    local minutes =
        math.floor((seconds % 3600) / 60)

    if days > 0 then

        return tostring(days)
            .. "d "
            .. tostring(hours)
            .. "h"
    end

    if hours > 0 then

        return tostring(hours)
            .. "h "
            .. tostring(minutes)
            .. "m"
    end

    return tostring(minutes)
        .. "m"
end

function HolyLoaderFeatureText(features)

    features =
        type(features) == "table"
        and features
        or {}

    if features.admin == true
    or features.dev_tools == true then

        return "Owner/Admin"
    end

    if features.pet_sniper == true
    or features.server_finder == true
    or features.pet_sniper_autobuy == true then

        return "Pet Finder Slot"
    end

    if features.basic == true then

        return "Basic"
    end

    return "Locked"
end

function HolyLoaderShortKey(key)

    key =
        HolyLoaderClean(
            key
        )

    if key == "" then

        return "None"
    end

    local first =
        key:match(
            "^(HOLY%-%w+)"
        )

    if first then

        return first
            .. "-..."
    end

    return key:sub(1, 12)
        .. "..."
end

--==================================================
-- OBSIDIAN UI HELPERS
--==================================================

function HolyLoaderSetStatus(label, text)

    text =
        tostring(text or "")

    if typeof(label) == "Instance" then

        pcall(function()

            label.Text =
                text
        end)

        return true
    end

    if type(label) == "table" then

        if type(label.SetText) == "function" then

            local ok =
                pcall(function()

                    label:SetText(
                        text
                    )
                end)

            if ok == true then

                return true
            end
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

    return false
end

function HolyLoaderNotify(title, description, time)

    title =
        tostring(title or "HOLY")

    description =
        tostring(description or "")

    time =
        tonumber(time)
        or 4

    if type(HOLY_LOADER_LIBRARY) == "table"
    and type(HOLY_LOADER_LIBRARY.Notify) == "function" then

        local ok =
            pcall(function()

                HOLY_LOADER_LIBRARY:Notify({
                    Title =
                        title,

                    Description =
                        description,

                    Time =
                        time,
                })
            end)

        if ok == true then

            return true
        end
    end

    print(
        "[HOLY LOADER]",
        title,
        description
    )

    return false
end

function HolyLoaderAddLabel(parent, text, wrap)

    if type(parent) ~= "table"
    or type(parent.AddLabel) ~= "function" then

        return nil
    end

    local label =
        nil

    local ok =
        false

    ok,
        label =
        pcall(function()

            return parent:AddLabel({
                Text =
                    tostring(text or ""),

                DoesWrap =
                    wrap == true,

                Size =
                    14,
            })
        end)

    if ok == true
    and label ~= nil then

        return label
    end

    ok,
        label =
        pcall(function()

            return parent:AddLabel(
                tostring(text or ""),
                wrap == true
            )
        end)

    if ok == true then

        return label
    end

    return nil
end

function HolyLoaderAddDivider(parent)

    if type(parent) ~= "table"
    or type(parent.AddDivider) ~= "function" then

        return false
    end

    pcall(function()

        parent:AddDivider()
    end)

    return true
end

function HolyLoaderAddButton(parent, text, callback, tooltip, doubleClick)

    if type(parent) ~= "table"
    or type(parent.AddButton) ~= "function" then

        return nil
    end

    local button =
        nil

    local ok =
        false

    ok,
        button =
        pcall(function()

            return parent:AddButton({
                Text =
                    tostring(text or "Button"),

                Func =
                    function()

                        if type(callback) == "function" then

                            callback()
                        end
                    end,

                Tooltip =
                    tostring(tooltip or ""),

                DoubleClick =
                    doubleClick == true,
            })
        end)

    if ok == true
    and button ~= nil then

        return button
    end

    ok,
        button =
        pcall(function()

            return parent:AddButton(
                tostring(text or "Button"),
                function()

                    if type(callback) == "function" then

                        callback()
                    end
                end
            )
        end)

    if ok == true then

        return button
    end

    return nil
end

function HolyLoaderAddGroupbox(tab, side, title, icon)

    if type(tab) ~= "table" then

        return nil
    end

    local method =
        side == "Right"
        and "AddRightGroupbox"
        or "AddLeftGroupbox"

    if type(tab[method]) == "function" then

        local ok,
            groupbox =
            pcall(function()

                return tab[method](
                    tab,
                    title,
                    icon
                )
            end)

        if ok == true
        and groupbox ~= nil then

            return groupbox
        end

        ok,
            groupbox =
            pcall(function()

                return tab[method](
                    tab,
                    title
                )
            end)

        if ok == true
        and groupbox ~= nil then

            return groupbox
        end
    end

    return nil
end

function HolyLoaderRefreshUiFromAuth(auth, message)

    auth =
        type(auth) == "table"
        and auth
        or HolyLoaderEnv.HOLY_AUTH
        or {}

    local features =
        type(auth.Features) == "table"
        and auth.Features
        or type(auth.features) == "table"
        and auth.features
        or {}

    local plan =
        tostring(
            auth.Plan
            or auth.plan
            or "--"
        )

    local keyPrefix =
        tostring(
            auth.KeyPrefix
            or auth.keyPrefix
            or "--"
        )

    local timeLeft =
        tonumber(
            auth.TimeLeft
            or auth.timeLeft
        )
        or 0

    local slots =
        auth.Slots
        or auth.slots
        or {}

    local slotActive =
        tonumber(slots.active)
        or 0

    local slotMax =
        tonumber(slots.max)
        or 3

    HolyLoaderSetStatus(
        HOLY_LOADER_UI.StatusLabel,
        tostring(message or "Waiting for key...")
    )

    HolyLoaderSetStatus(
        HOLY_LOADER_UI.AccountLabel,
        "Account: "
            .. tostring(LocalPlayer.Name)
            .. " | "
            .. tostring(LocalPlayer.UserId)
    )

    HolyLoaderSetStatus(
        HOLY_LOADER_UI.PlanLabel,
        "Plan: "
            .. plan
            .. " | "
            .. HolyLoaderFeatureText(features)
    )

    HolyLoaderSetStatus(
        HOLY_LOADER_UI.KeyLabel,
        "Key: "
            .. keyPrefix
    )

    HolyLoaderSetStatus(
        HOLY_LOADER_UI.TimeLabel,
        "Time Left: "
            .. HolyLoaderFormatTime(
                timeLeft
            )
    )

    HolyLoaderSetStatus(
        HOLY_LOADER_UI.SlotLabel,
        "Finder Slots: "
            .. tostring(slotActive)
            .. "/"
            .. tostring(slotMax)
    )

    local featureList =
        {}

    for key, value in pairs(features) do

        if value == true then

            table.insert(
                featureList,
                key
            )
        end
    end

    table.sort(
        featureList
    )

    HolyLoaderSetStatus(
        HOLY_LOADER_UI.FeaturesLabel,
        "Features: "
            .. (
                #featureList > 0
                and table.concat(
                    featureList,
                    ", "
                )
                or "None"
            )
    )
end

function HolyLoaderLoadObsidianLibrary()

    if type(HOLY_LOADER_LIBRARY) == "table" then

        return HOLY_LOADER_LIBRARY,
            nil
    end

    local source,
        sourceErr =
        HolyLoaderHttpGetRaw(
            HOLY_OBSIDIAN_LIBRARY_URL
        )

    if type(source) ~= "string"
    or source == "" then

        return nil,
            "Obsidian download failed: "
            .. tostring(sourceErr)
    end

    local lower =
        source:sub(1, 200):lower()

    if lower:find("<html", 1, true)
    or lower:find("<!doctype", 1, true) then

        return nil,
            "Obsidian returned HTML"
    end

    local compiler =
        HolyLoaderCompiler()

    if type(compiler) ~= "function" then

        return nil,
            "loadstring/load missing"
    end

    local compileOk,
        chunk,
        compileErr =
        pcall(
            compiler,
            source
        )

    if compileOk ~= true
    or type(chunk) ~= "function" then

        return nil,
            "Obsidian compile failed: "
            .. tostring(compileErr or chunk)
    end

    local runOk,
        library =
        pcall(chunk)

    if runOk ~= true
    or type(library) ~= "table" then

        return nil,
            "Obsidian run failed: "
            .. tostring(library)
    end

    HOLY_LOADER_LIBRARY =
        library

    return library,
        nil
end

--==================================================
-- BACKEND AUTH
--==================================================

function HolyLoaderVerifyKey(key)

    key =
        HolyLoaderClean(
            key
        )

    if key == "" then

        return nil,
            "Enter a key first."
    end

    local payload = {
        Key =
            key,

        UserId =
            LocalPlayer.UserId,

        Username =
            LocalPlayer.Name,

        PlaceId =
            game.PlaceId,

        JobId =
            tostring(game.JobId),

        LoaderVersion =
            HOLY_LOADER_VERSION,
    }

    local data,
        err =
        HolyLoaderRequestJson(
            "POST",
            "/verify",
            payload
        )

    if type(data) ~= "table" then

        return nil,
            tostring(err or "verify failed")
    end

    if data.ok ~= true
    or data.active ~= true then

        return nil,
            tostring(data.error or data.message or "key rejected")
    end

    return data,
        nil
end

function HolyLoaderApplyAuth(key, data)

    HolyLoaderEnv.HOLY_AUTH =
        {
            Valid =
                true,

            Key =
                key,

            SessionId =
                data.sessionId,

            KeyPrefix =
                data.keyPrefix,

            Plan =
                data.plan,

            Features =
                type(data.features) == "table"
                and data.features
                or {},

            ExpiresAt =
                tonumber(data.expiresAt)
                or 0,

            SlotExpiresAt =
                tonumber(data.slotExpiresAt)
                or 0,

            TimeLeft =
                tonumber(data.timeLeft)
                or 0,

            Slots =
                data.slots,

            VerifiedAt =
                os.time(),

            LoaderVersion =
                HOLY_LOADER_VERSION,
        }

    _G.HOLY_AUTH =
        HolyLoaderEnv.HOLY_AUTH

    HolyLoaderWriteFile(
        HOLY_KEY_FILE,
        key
    )

    local encoded =
        ""

    pcall(function()

        encoded =
            HttpService:JSONEncode(
                HolyLoaderEnv.HOLY_AUTH
            )
    end)

    if encoded ~= "" then

        HolyLoaderWriteFile(
            HOLY_SESSION_FILE,
            encoded
        )
    end
end

function HolyLoaderLoadPremium()

    local auth =
        HolyLoaderEnv.HOLY_AUTH

    if type(auth) ~= "table"
    or auth.Valid ~= true
    or HolyLoaderClean(auth.SessionId) == "" then

        return false,
            "not authorized"
    end

    local source,
        sourceErr =
        HolyLoaderGetText(
            "/source?sessionId="
            .. HttpService:UrlEncode(
                auth.SessionId
            )
        )

    if type(source) ~= "string"
    or source == "" then

        return false,
            tostring(sourceErr or "source empty")
    end

    local lower =
        source:sub(1, 300):lower()

    if lower:find("<html", 1, true)
    or lower:find("<!doctype", 1, true)
    or lower:find('"ok":false', 1, true) then

        return false,
            "source rejected: "
            .. source:sub(1, 160)
    end

    local compiler =
        HolyLoaderCompiler()

    if type(compiler) ~= "function" then

        return false,
            "loadstring/load missing"
    end

    local compileOk,
        chunk,
        compileErr =
        pcall(
            compiler,
            source
        )

    if compileOk ~= true
    or type(chunk) ~= "function" then

        return false,
            "compile failed: "
            .. tostring(compileErr or chunk)
    end

    local runOk,
        runErr =
        pcall(chunk)

    if runOk ~= true then

        return false,
            "run failed: "
            .. tostring(runErr)
    end

    HolyLoaderStop(
        "premium loaded"
    )

    return true,
        "loaded"
end

function HolyLoaderVerifyAndLoad(key)

    if HOLY_LOADER_BUSY == true then

        HolyLoaderNotify(
            "HOLY Loader",
            "Already checking a key.",
            3
        )

        return false
    end

    HOLY_LOADER_BUSY =
        true

    key =
        HolyLoaderClean(
            key
        )

    HolyLoaderSetStatus(
        HOLY_LOADER_UI.StatusLabel,
        "Checking key..."
    )

    HolyLoaderNotify(
        "HOLY Key System",
        "Checking key...",
        2
    )

    task.spawn(function()

        local data,
            verifyErr =
            HolyLoaderVerifyKey(
                key
            )

        if type(data) ~= "table" then

            HOLY_LOADER_BUSY =
                false

            HolyLoaderSetStatus(
                HOLY_LOADER_UI.StatusLabel,
                "Key failed: "
                    .. tostring(verifyErr)
            )

            HolyLoaderNotify(
                "Key Failed",
                tostring(verifyErr),
                5
            )

            return
        end

        HolyLoaderApplyAuth(
            key,
            data
        )

        local auth =
            HolyLoaderEnv.HOLY_AUTH

        HolyLoaderRefreshUiFromAuth(
            auth,
            "Verified. Loading HOLY Pro..."
        )

        HolyLoaderNotify(
            "Key Verified",
            HolyLoaderFeatureText(
                auth.Features
            )
            .. " | "
            .. HolyLoaderFormatTime(
                auth.TimeLeft
            )
            .. " left.",
            4
        )

        task.wait(
            0.35
        )

        local loaded,
            loadErr =
            HolyLoaderLoadPremium()

        HOLY_LOADER_BUSY =
            false

        if loaded ~= true then

            HolyLoaderSetStatus(
                HOLY_LOADER_UI.StatusLabel,
                "Load failed: "
                    .. tostring(loadErr)
            )

            HolyLoaderNotify(
                "Load Failed",
                tostring(loadErr),
                6
            )
        end
    end)

    return true
end

--==================================================
-- FALLBACK UI
--==================================================

function HolyLoaderCreateFallbackGui(savedKey, lastError)

    local gui =
        Instance.new(
            "ScreenGui"
        )

    gui.Name =
        "HOLY_Key_Loader_Fallback"

    gui.ResetOnSpawn =
        false

    gui.IgnoreGuiInset =
        true

    pcall(function()

        gui.ZIndexBehavior =
            Enum.ZIndexBehavior.Sibling
    end)

    pcall(function()

        gui.Parent =
            CoreGui
    end)

    if gui.Parent == nil then

        gui.Parent =
            LocalPlayer:WaitForChild(
                "PlayerGui"
            )
    end

    HOLY_LOADER_GUI =
        gui

    local frame =
        Instance.new(
            "Frame"
        )

    frame.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )

    frame.Position =
        UDim2.fromScale(
            0.5,
            0.5
        )

    frame.Size =
        UDim2.fromOffset(
            460,
            240
        )

    frame.BackgroundColor3 =
        Color3.fromRGB(
            12,
            12,
            16
        )

    frame.BorderSizePixel =
        0

    frame.Parent =
        gui

    local corner =
        Instance.new(
            "UICorner"
        )

    corner.CornerRadius =
        UDim.new(
            0,
            12
        )

    corner.Parent =
        frame

    local stroke =
        Instance.new(
            "UIStroke"
        )

    stroke.Color =
        Color3.fromRGB(
            239,
            51,
            64
        )

    stroke.Transparency =
        0.35

    stroke.Parent =
        frame

    local title =
        Instance.new(
            "TextLabel"
        )

    title.BackgroundTransparency =
        1

    title.Position =
        UDim2.fromOffset(
            22,
            18
        )

    title.Size =
        UDim2.new(
            1,
            -44,
            0,
            30
        )

    title.Font =
        Enum.Font.GothamBold

    title.TextSize =
        20

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.TextColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )

    title.Text =
        "HOLY Loader Fallback"

    title.Parent =
        frame

    local input =
        Instance.new(
            "TextBox"
        )

    input.BackgroundColor3 =
        Color3.fromRGB(
            20,
            21,
            28
        )

    input.BorderSizePixel =
        0

    input.Position =
        UDim2.fromOffset(
            22,
            72
        )

    input.Size =
        UDim2.new(
            1,
            -44,
            0,
            40
        )

    input.Font =
        Enum.Font.GothamMedium

    input.TextSize =
        13

    input.TextColor3 =
        Color3.fromRGB(
            245,
            245,
            247
        )

    input.PlaceholderText =
        "HOLY-XXXX-XXXX-XXXX..."

    input.ClearTextOnFocus =
        false

    input.Text =
        tostring(savedKey or "")

    input.Parent =
        frame

    local inputCorner =
        Instance.new(
            "UICorner"
        )

    inputCorner.CornerRadius =
        UDim.new(
            0,
            8
        )

    inputCorner.Parent =
        input

    local verify =
        Instance.new(
            "TextButton"
        )

    verify.BackgroundColor3 =
        Color3.fromRGB(
            239,
            51,
            64
        )

    verify.BorderSizePixel =
        0

    verify.Position =
        UDim2.fromOffset(
            22,
            126
        )

    verify.Size =
        UDim2.new(
            0.5,
            -28,
            0,
            38
        )

    verify.Font =
        Enum.Font.GothamBold

    verify.TextSize =
        14

    verify.TextColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )

    verify.Text =
        "Verify Key"

    verify.Parent =
        frame

    local verifyCorner =
        Instance.new(
            "UICorner"
        )

    verifyCorner.CornerRadius =
        UDim.new(
            0,
            8
        )

    verifyCorner.Parent =
        verify

    local reset =
        Instance.new(
            "TextButton"
        )

    reset.BackgroundColor3 =
        Color3.fromRGB(
            24,
            25,
            34
        )

    reset.BorderSizePixel =
        0

    reset.Position =
        UDim2.new(
            0.5,
            6,
            0,
            126
        )

    reset.Size =
        UDim2.new(
            0.5,
            -28,
            0,
            38
        )

    reset.Font =
        Enum.Font.GothamBold

    reset.TextSize =
        14

    reset.TextColor3 =
        Color3.fromRGB(
            245,
            245,
            247
        )

    reset.Text =
        "Reset Key"

    reset.Parent =
        frame

    local resetCorner =
        Instance.new(
            "UICorner"
        )

    resetCorner.CornerRadius =
        UDim.new(
            0,
            8
        )

    resetCorner.Parent =
        reset

    local status =
        Instance.new(
            "TextLabel"
        )

    status.BackgroundTransparency =
        1

    status.Position =
        UDim2.fromOffset(
            22,
            178
        )

    status.Size =
        UDim2.new(
            1,
            -44,
            0,
            48
        )

    status.Font =
        Enum.Font.GothamMedium

    status.TextSize =
        12

    status.TextWrapped =
        true

    status.TextXAlignment =
        Enum.TextXAlignment.Left

    status.TextYAlignment =
        Enum.TextYAlignment.Top

    status.TextColor3 =
        Color3.fromRGB(
            156,
            163,
            175
        )

    status.Text =
        tostring(
            lastError
            or "Obsidian failed to load. Fallback mode active."
        )

    status.Parent =
        frame

    HOLY_LOADER_UI.StatusLabel =
        status

    HolyLoaderTrack(
        verify.MouseButton1Click:Connect(function()

            HolyLoaderVerifyAndLoad(
                input.Text
            )
        end)
    )

    HolyLoaderTrack(
        reset.MouseButton1Click:Connect(function()

            HolyLoaderDeleteFile(
                HOLY_KEY_FILE
            )

            HolyLoaderDeleteFile(
                HOLY_SESSION_FILE
            )

            input.Text =
                ""

            status.Text =
                "Saved key reset."
        end)
    )

    return gui
end

--==================================================
-- OBSIDIAN UI
--==================================================

function HolyLoaderCreateObsidianGui(savedKey, lastError, lastData)

    HolyLoaderStop(
        "rebuild obsidian"
    )

    local Library,
        libraryErr =
        HolyLoaderLoadObsidianLibrary()

    if type(Library) ~= "table" then

        return HolyLoaderCreateFallbackGui(
            savedKey,
            libraryErr
                or lastError
                or "Obsidian failed to load."
        )
    end

    HOLY_LOADER_LIBRARY =
        Library

    pcall(function()

        Library.ShowToggleFrameInKeybinds =
            true
    end)

    local Window =
        nil

    local ok,
        result =
        pcall(function()

            return Library:CreateWindow({
                Title =
                    "HOLY HUB",

                Footer =
                    "loader v1.1",

                Center =
                    true,

                AutoShow =
                    true,

                Resizable =
                    true,

                NotifySide =
                    "Right",

                ShowCustomCursor =
                    true,

                Size =
                    UDim2.fromOffset(
                        620,
                        430
                    ),
            })
        end)

    if ok ~= true
    or type(result) ~= "table" then

        return HolyLoaderCreateFallbackGui(
            savedKey,
            "Obsidian window failed: "
                .. tostring(result)
        )
    end

    Window =
        result

    HOLY_LOADER_WINDOW =
        Window

    local Tabs =
        {}

    pcall(function()

        Tabs.Key =
            Window:AddKeyTab(
                "Key System"
            )
    end)

    if type(Tabs.Key) ~= "table" then

        pcall(function()

            Tabs.Key =
                Window:AddTab(
                    "Key System",
                    "key-round"
                )
        end)
    end

    pcall(function()

        Tabs.Status =
            Window:AddTab(
                "Status",
                "activity"
            )
    end)

    pcall(function()

        Tabs.Links =
            Window:AddTab(
                "Links",
                "link"
            )
    end)

    pcall(function()

        Tabs.UI =
            Window:AddTab(
                "UI",
                "settings"
            )
    end)

    -- KEY TAB

    if type(Tabs.Key) == "table" then

        HolyLoaderAddLabel(
            Tabs.Key,
            "HOLY Access",
            false
        )

        HolyLoaderAddLabel(
            Tabs.Key,
            "Enter your HOLY key below. Successful keys are saved locally and auto-loaded next time.",
            true
        )

        HolyLoaderAddDivider(
            Tabs.Key
        )

        HOLY_LOADER_UI.StatusLabel =
            HolyLoaderAddLabel(
                Tabs.Key,
                tostring(
                    lastError
                    or (
                        savedKey ~= ""
                        and "Saved key found. Use saved key or enter a new one."
                        or "Waiting for key..."
                    )
                ),
                true
            )

        HolyLoaderAddDivider(
            Tabs.Key
        )

        if type(Tabs.Key.AddKeyBox) == "function" then

            pcall(function()

                Tabs.Key:AddKeyBox(function(receivedKey)

                    HolyLoaderVerifyAndLoad(
                        receivedKey
                    )
                end)
            end)

        else

            local manualGroup =
                HolyLoaderAddGroupbox(
                    Tabs.Key,
                    "Left",
                    "Manual Key",
                    "key"
                )

            if type(manualGroup) == "table" then

                local typedKey =
                    ""

                if type(manualGroup.AddInput) == "function" then

                    pcall(function()

                        manualGroup:AddInput("HolyLoaderManualKey", {
                            Default =
                                tostring(savedKey or ""),

                            Numeric =
                                false,

                            Finished =
                                false,

                            ClearTextOnFocus =
                                false,

                            Text =
                                "Key",

                            Placeholder =
                                "HOLY-XXXX-XXXX-XXXX...",

                            Callback =
                                function(value)

                                    typedKey =
                                        tostring(value or "")
                                end,
                        })
                    end)
                end

                HolyLoaderAddButton(
                    manualGroup,
                    "Verify Key",
                    function()

                        HolyLoaderVerifyAndLoad(
                            typedKey ~= ""
                            and typedKey
                            or savedKey
                        )
                    end,
                    "Verify the typed key."
                )
            end
        end

        if savedKey ~= "" then

            HolyLoaderAddButton(
                Tabs.Key,
                "Use Saved Key",
                function()

                    HolyLoaderVerifyAndLoad(
                        HolyLoaderReadFile(
                            HOLY_KEY_FILE
                        )
                    )
                end,
                "Verify and load the saved key."
            )
        end

        HolyLoaderAddButton(
            Tabs.Key,
            "Reset Saved Key",
            function()

                HolyLoaderDeleteFile(
                    HOLY_KEY_FILE
                )

                HolyLoaderDeleteFile(
                    HOLY_SESSION_FILE
                )

                savedKey =
                    ""

                HolyLoaderSetStatus(
                    HOLY_LOADER_UI.StatusLabel,
                    "Saved key reset. Enter a new key."
                )

                HolyLoaderNotify(
                    "HOLY Key System",
                    "Saved key reset.",
                    3
                )
            end,
            "Deletes the local saved key.",
            true
        )
    end

    -- STATUS TAB

    if type(Tabs.Status) == "table" then

        local accountBox =
            HolyLoaderAddGroupbox(
                Tabs.Status,
                "Left",
                "Account",
                "user"
            )

        local licenseBox =
            HolyLoaderAddGroupbox(
                Tabs.Status,
                "Right",
                "License",
                "badge-check"
            )

        local finderBox =
            HolyLoaderAddGroupbox(
                Tabs.Status,
                "Left",
                "Finder Slot",
                "radar"
            )

        local featureBox =
            HolyLoaderAddGroupbox(
                Tabs.Status,
                "Right",
                "Features",
                "list-checks"
            )

        if type(accountBox) == "table" then

            HOLY_LOADER_UI.AccountLabel =
                HolyLoaderAddLabel(
                    accountBox,
                    "Account: "
                        .. tostring(LocalPlayer.Name)
                        .. " | "
                        .. tostring(LocalPlayer.UserId),
                    true
                )

            HolyLoaderAddLabel(
                accountBox,
                "PlaceId: "
                    .. tostring(game.PlaceId),
                true
            )
        end

        if type(licenseBox) == "table" then

            HOLY_LOADER_UI.KeyLabel =
                HolyLoaderAddLabel(
                    licenseBox,
                    "Key: "
                        .. (
                            savedKey ~= ""
                            and HolyLoaderShortKey(savedKey)
                            or "None"
                        ),
                    true
                )

            HOLY_LOADER_UI.PlanLabel =
                HolyLoaderAddLabel(
                    licenseBox,
                    "Plan: --",
                    true
                )

            HOLY_LOADER_UI.TimeLabel =
                HolyLoaderAddLabel(
                    licenseBox,
                    "Time Left: --",
                    true
                )
        end

        if type(finderBox) == "table" then

            HOLY_LOADER_UI.SlotLabel =
                HolyLoaderAddLabel(
                    finderBox,
                    "Finder Slots: --/3",
                    true
                )

            HolyLoaderAddLabel(
                finderBox,
                "Pet Finder/Sniper is slot-based. If your slot expires, the premium finder features lock.",
                true
            )
        end

        if type(featureBox) == "table" then

            HOLY_LOADER_UI.FeaturesLabel =
                HolyLoaderAddLabel(
                    featureBox,
                    "Features: --",
                    true
                )

            HolyLoaderAddButton(
                featureBox,
                "Refresh Saved Key",
                function()

                    local key =
                        HolyLoaderReadFile(
                            HOLY_KEY_FILE
                        )

                    if key == "" then

                        HolyLoaderNotify(
                            "HOLY Key System",
                            "No saved key found.",
                            3
                        )

                        return
                    end

                    HolyLoaderVerifyAndLoad(
                        key
                    )
                end,
                "Verify the saved key again."
            )
        end
    end

    -- LINKS TAB

    if type(Tabs.Links) == "table" then

        local actionsBox =
            HolyLoaderAddGroupbox(
                Tabs.Links,
                "Left",
                "Actions",
                "mouse-pointer-click"
            )

        local infoBox =
            HolyLoaderAddGroupbox(
                Tabs.Links,
                "Right",
                "Info",
                "info"
            )

        if type(actionsBox) == "table" then

            HolyLoaderAddButton(
                actionsBox,
                "Copy Public Loadstring",
                function()

                    if HolyLoaderCopyText(
                        HOLY_PUBLIC_LOADSTRING
                    ) == true then

                        HolyLoaderNotify(
                            "Copied",
                            "Public loadstring copied.",
                            3
                        )

                    else

                        HolyLoaderNotify(
                            "Clipboard Failed",
                            "Your executor does not support clipboard.",
                            4
                        )
                    end
                end,
                "Copies the public HOLY loader loadstring."
            )

            HolyLoaderAddButton(
                actionsBox,
                "Copy Discord Invite",
                function()

                    if HolyLoaderClean(HOLY_DISCORD_INVITE) == "" then

                        HolyLoaderNotify(
                            "Discord",
                            "Discord invite is not set in the loader yet.",
                            4
                        )

                        return
                    end

                    if HolyLoaderCopyText(
                        HOLY_DISCORD_INVITE
                    ) == true then

                        HolyLoaderNotify(
                            "Copied",
                            "Discord invite copied.",
                            3
                        )

                    else

                        HolyLoaderNotify(
                            "Clipboard Failed",
                            "Your executor does not support clipboard.",
                            4
                        )
                    end
                end,
                "Copies your Discord invite if set."
            )

            HolyLoaderAddButton(
                actionsBox,
                "Reset Saved Key",
                function()

                    HolyLoaderDeleteFile(
                        HOLY_KEY_FILE
                    )

                    HolyLoaderDeleteFile(
                        HOLY_SESSION_FILE
                    )

                    HolyLoaderSetStatus(
                        HOLY_LOADER_UI.StatusLabel,
                        "Saved key reset. Enter a new key."
                    )

                    HolyLoaderNotify(
                        "HOLY Key System",
                        "Saved key reset.",
                        3
                    )
                end,
                "Deletes local key/session files.",
                true
            )
        end

        if type(infoBox) == "table" then

            HolyLoaderAddLabel(
                infoBox,
                "Current public loader:",
                false
            )

            HolyLoaderAddLabel(
                infoBox,
                HOLY_PUBLIC_LOADSTRING,
                true
            )

            HolyLoaderAddDivider(
                infoBox
            )

            HolyLoaderAddLabel(
                infoBox,
                "Keys are saved locally in HolyGAG2/HolyAccessKey.txt after successful verification.",
                true
            )
        end
    end

    -- UI TAB

    if type(Tabs.UI) == "table" then

        local menuBox =
            HolyLoaderAddGroupbox(
                Tabs.UI,
                "Left",
                "Menu",
                "wrench"
            )

        if type(menuBox) == "table" then

            HolyLoaderAddLabel(
                menuBox,
                "Toggle keybind is controlled by Obsidian. Use this tab only for loader actions.",
                true
            )

            HolyLoaderAddButton(
                menuBox,
                "Unload Loader",
                function()

                    HolyLoaderStop(
                        "manual unload"
                    )
                end,
                "Closes the loader window."
            )
        end
    end

    if type(lastData) == "table" then

        HolyLoaderApplyAuth(
            savedKey,
            lastData
        )

        HolyLoaderRefreshUiFromAuth(
            HolyLoaderEnv.HOLY_AUTH,
            lastError or "Verified."
        )

    else

        HolyLoaderRefreshUiFromAuth(
            {
                KeyPrefix =
                    savedKey ~= ""
                    and HolyLoaderShortKey(savedKey)
                    or "None",

                Plan =
                    "--",

                Features =
                    {},

                TimeLeft =
                    0,

                Slots =
                    {
                        active =
                            0,

                        max =
                            3,
                    },
            },
            lastError
                or (
                    savedKey ~= ""
                    and "Saved key found. Use saved key or enter a new one."
                    or "Waiting for key..."
                )
        )
    end

    return Window
end

--==================================================
-- STARTUP
--==================================================

local savedKey =
    HolyLoaderReadFile(
        HOLY_KEY_FILE
    )

if savedKey ~= "" then

    local data,
        err =
        HolyLoaderVerifyKey(
            savedKey
        )

    if type(data) == "table" then

        HolyLoaderApplyAuth(
            savedKey,
            data
        )

        local loaded,
            loadErr =
            HolyLoaderLoadPremium()

        if loaded ~= true then

            HolyLoaderCreateObsidianGui(
                savedKey,
                "Saved key load failed: "
                    .. tostring(loadErr),
                data
            )
        end

    else

        HolyLoaderCreateObsidianGui(
            savedKey,
            "Saved key failed: "
                .. tostring(err),
            nil
        )
    end

else

    HolyLoaderCreateObsidianGui(
        "",
        "Waiting for key...",
        nil
    )
end
