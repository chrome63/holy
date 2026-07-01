--==================================================
-- HOLY GAG2 PUBLIC LOADER - OBSIDIAN VERSION
--==================================================

local Players =
    game:GetService("Players")

local HttpService =
    game:GetService("HttpService")

local CoreGui =
    game:GetService("CoreGui")

local StarterGui =
    game:GetService("StarterGui")

local LocalPlayer =
    Players.LocalPlayer
    or Players.PlayerAdded:Wait()

local HOLY_PRO_API =
    "https://holy-loader-api.benjicapalot041.workers.dev"

local HOLY_SNIPER_API =
    "https://holy-sniper-loader-api.benjicapalot041.workers.dev"

local HOLY_OBSIDIAN_REPO =
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local HOLY_OBSIDIAN_LIBRARY_URL =
    HOLY_OBSIDIAN_REPO
    .. "Library.lua"

local HOLY_FOLDER =
    "HolyGAG2"

local HOLY_KEY_FILE =
    HOLY_FOLDER
    .. "/HolyLoaderGAG2Key.txt"

local HOLY_SESSION_FILE =
    HOLY_FOLDER
    .. "/HolyLoaderGAG2Session.json"

local HOLY_LOADER_VERSION =
    "holy_loader_gag2_obsidian_v1"

local HOLY_PUBLIC_LOADSTRING =
    [[loadstring(game:HttpGet("https://raw.githubusercontent.com/bencapalot041/holy/main/holy_loader_gag2.lua", true))()]]

local HOLY_DISCORD_INVITE =
    ""

local HolyEnv =
    type(getgenv) == "function"
    and getgenv()
    or _G

pcall(function()

    if type(HolyEnv.HOLY_LOADER_STOP) == "function" then

        HolyEnv.HOLY_LOADER_STOP(
            "reload"
        )
    end
end)

local HOLY_CONNECTIONS =
    {}

local HOLY_LIBRARY =
    nil

local HOLY_WINDOW =
    nil

local HOLY_BUSY =
    false

local HOLY_UI =
    {}

--==================================================
-- BASIC HELPERS
--==================================================

local function HolyTrack(connection)

    if connection then

        table.insert(
            HOLY_CONNECTIONS,
            connection
        )
    end

    return connection
end

local function HolyClean(value)

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

local function HolyStop(reason)

    for _, connection in ipairs(HOLY_CONNECTIONS) do

        pcall(function()

            connection:Disconnect()
        end)
    end

    HOLY_CONNECTIONS =
        {}

    if type(HOLY_LIBRARY) == "table"
    and type(HOLY_LIBRARY.Unload) == "function" then

        pcall(function()

            HOLY_LIBRARY:Unload()
        end)
    end

    HOLY_LIBRARY =
        nil

    HOLY_WINDOW =
        nil

    HOLY_UI =
        {}
end

HolyEnv.HOLY_LOADER_STOP =
    HolyStop

local function HolySetStatus(text)

    text =
        tostring(text or "")

    local label =
        HOLY_UI.StatusLabel

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

    print(
        "[HOLY LOADER]",
        text
    )

    return false
end

local function HolyNotify(title, description, duration)

    title =
        tostring(title or "HOLY")

    description =
        tostring(description or "")

    duration =
        tonumber(duration)
        or 4

    if type(HOLY_LIBRARY) == "table"
    and type(HOLY_LIBRARY.Notify) == "function" then

        local ok =
            pcall(function()

                HOLY_LIBRARY:Notify({
                    Title =
                        title,

                    Description =
                        description,

                    Time =
                        duration,
                })
            end)

        if ok == true then
            return true
        end
    end

    pcall(function()

        StarterGui:SetCore(
            "SendNotification",
            {
                Title =
                    title,

                Text =
                    description,

                Duration =
                    duration,
            }
        )
    end)

    print(
        "[HOLY LOADER]",
        title,
        description
    )

    return true
end

local function HolyCanUseFiles()

    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

local function HolyEnsureFolder()

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

local function HolyReadFile(path)

    if HolyCanUseFiles() ~= true then
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

    if ok ~= true then
        return ""
    end

    return HolyClean(raw)
end

local function HolyWriteFile(path, text)

    if HolyCanUseFiles() ~= true then
        return false
    end

    HolyEnsureFolder()

    local ok =
        pcall(function()

            writefile(
                path,
                tostring(text or "")
            )
        end)

    return ok == true
end

local function HolyDeleteFile(path)

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

local function HolyCopyText(text)

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

local function HolyGetRequestFunction()

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

    if type(HolyEnv) == "table" then

        if type(HolyEnv.request) == "function" then
            return HolyEnv.request
        end

        if type(HolyEnv.http_request) == "function" then
            return HolyEnv.http_request
        end
    end

    return nil
end

local function HolyEncodeJson(value)

    local ok,
        result =
        pcall(function()

            return HttpService:JSONEncode(
                value
            )
        end)

    if ok == true
    and type(result) == "string" then

        return result
    end

    return "{}"
end

local function HolyDecodeJson(body)

    if type(body) ~= "string" then
        return nil
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

        return data
    end

    return nil
end

local function HolyHttpRaw(method, url, payload, accept)

    method =
        tostring(method or "GET")

    url =
        HolyClean(url)

    if url == "" then

        return nil,
            "empty url",
            0
    end

    local requestFunction =
        HolyGetRequestFunction()

    if type(requestFunction) == "function" then

        local options = {
            Url =
                url,

            Method =
                method,

            Headers = {
                ["Accept"] =
                    accept
                    or "application/json, text/plain",

                ["Cache-Control"] =
                    "no-cache",
            },
        }

        if payload ~= nil then

            options.Headers["Content-Type"] =
                "application/json"

            options.Body =
                HolyEncodeJson(
                    payload
                )
        end

        local ok,
            response =
            pcall(
                requestFunction,
                options
            )

        if ok ~= true then

            return nil,
                tostring(response),
                0
        end

        if type(response) == "string" then

            return response,
                nil,
                200
        end

        if type(response) == "table" then

            return tostring(
                response.Body
                or response.body
                or response.ResponseBody
                or response.responseBody
                or ""
            ),
                nil,
                tonumber(
                    response.StatusCode
                    or response.Status
                    or response.status
                    or response.status_code
                    or 200
                )
                or 200
        end

        return nil,
            "bad response",
            0
    end

    if method == "POST" then

        local ok,
            body =
            pcall(function()

                return HttpService:PostAsync(
                    url,
                    HolyEncodeJson(payload or {}),
                    Enum.HttpContentType.ApplicationJson,
                    false
                )
            end)

        if ok == true then

            return tostring(body or ""),
                nil,
                200
        end

        return nil,
            tostring(body),
            0
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
            nil,
            200
    end

    return nil,
        tostring(body),
        0
end

local function HolyHttpJson(method, url, payload)

    local body,
        err,
        status =
        HolyHttpRaw(
            method,
            url,
            payload,
            "application/json"
        )

    if body == nil then

        return nil,
            err,
            status
    end

    local data =
        HolyDecodeJson(
            body
        )

    if type(data) ~= "table" then

        return nil,
            "invalid json",
            status
    end

    return data,
        nil,
        status
end

local function HolyHttpGetText(url)

    local body,
        err =
        HolyHttpRaw(
            "GET",
            url,
            nil,
            "text/plain"
        )

    return body,
        err
end

local function HolyCompiler()

    if type(loadstring) == "function" then
        return loadstring
    end

    if type(load) == "function" then
        return load
    end

    return nil
end

local function HolyFormatTime(seconds)

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

local function HolyNormalizeFeatures(features)

    local output =
        {}

    if type(features) ~= "table" then
        return output
    end

    for key, value in pairs(features) do

        if type(key) == "number" then

            local name =
                HolyClean(value)

            if name ~= "" then

                output[name] =
                    true
            end

        elseif value == true then

            output[tostring(key)] =
                true
        end
    end

    return output
end

local function HolyHasFeature(features, featureName)

    featureName =
        tostring(featureName or ""):lower()

    if type(features) ~= "table"
    or featureName == "" then

        return false
    end

    for key, value in pairs(features) do

        if value == true
        and tostring(key):lower() == featureName then

            return true
        end
    end

    return false
end

local function HolyFeatureText(features)

    features =
        type(features) == "table"
        and features
        or {}

    if HolyHasFeature(features, "admin") == true
    or HolyHasFeature(features, "dev_tools") == true then

        return "Owner/Admin"
    end

    if HolyHasFeature(features, "server_finder") == true
    or HolyHasFeature(features, "pet_sniper") == true
    or HolyHasFeature(features, "pet_sniper_autobuy") == true then

        return "Server Sniper"
    end

    if HolyHasFeature(features, "basic") == true then

        return "HOLY Pro"
    end

    return "Access"
end

local function HolyShortKey(key)

    key =
        HolyClean(key)

    if key == "" then
        return "None"
    end

    return key:sub(1, 10)
        .. "..."
end

--==================================================
-- AUTH / PRODUCT ROUTING
--==================================================

local function HolyBuildVerifyPayload(key)

    return {
        Key =
            key,

        key =
            key,

        UserId =
            tostring(LocalPlayer.UserId),

        RobloxUserId =
            tostring(LocalPlayer.UserId),

        Username =
            tostring(LocalPlayer.Name),

        RobloxUsername =
            tostring(LocalPlayer.Name),

        PlaceId =
            tostring(game.PlaceId),

        JobId =
            tostring(game.JobId),

        Loader =
            "holy_loader_gag2",

        LoaderVersion =
            HOLY_LOADER_VERSION,
    }
end

local function HolyExtractAuth(apiBase, key, data)

    data =
        type(data) == "table"
        and data
        or {}

    local keyData =
        type(data.key) == "table"
        and data.key
        or type(data.Key) == "table"
        and data.Key
        or {}

    local sessionData =
        type(data.session) == "table"
        and data.session
        or type(data.Session) == "table"
        and data.Session
        or {}

    local ok =
        data.ok == true
        or data.valid == true
        or data.Valid == true
        or data.active == true

    if ok ~= true then

        return nil,
            tostring(
                data.error
                or data.message
                or data.Error
                or "key rejected"
            )
    end

    local sessionId =
        HolyClean(
            data.sessionId
            or data.SessionId
            or data.session_id
            or sessionData.id
            or sessionData.Id
            or sessionData.sessionId
            or sessionData.SessionId
            or ""
        )

    if sessionId == "" then

        return nil,
            "missing session id"
    end

    local features =
        data.features
        or data.Features
        or data.liveFeatures
        or data.LiveFeatures
        or keyData.features
        or keyData.Features
        or keyData.liveFeatures
        or keyData.LiveFeatures
        or {}

    features =
        HolyNormalizeFeatures(
            features
        )

    local auth = {
        Valid =
            true,

        Key =
            key,

        SessionId =
            sessionId,

        KeyPrefix =
            data.keyPrefix
            or data.KeyPrefix
            or keyData.keyPrefix
            or keyData.KeyPrefix
            or HolyShortKey(key),

        Plan =
            data.plan
            or data.Plan
            or keyData.plan
            or keyData.Plan
            or "",

        Features =
            features,

        ExpiresAt =
            tonumber(data.expiresAt or data.ExpiresAt or keyData.expiresAt or keyData.ExpiresAt)
            or 0,

        SlotExpiresAt =
            tonumber(data.slotExpiresAt or data.SlotExpiresAt or keyData.slotExpiresAt or keyData.SlotExpiresAt)
            or 0,

        TimeLeft =
            tonumber(data.timeLeft or data.TimeLeft)
            or 0,

        Slots =
            data.slots
            or data.Slots
            or {},

        ApiBase =
            apiBase,

        VerifiedAt =
            os.time(),

        LoaderVersion =
            HOLY_LOADER_VERSION,
    }

    return auth,
        nil
end

local function HolyVerifyAt(apiBase, key)

    local data,
        err =
        HolyHttpJson(
            "POST",
            apiBase .. "/verify",
            HolyBuildVerifyPayload(key)
        )

    if type(data) ~= "table" then

        return nil,
            tostring(err or "verify failed")
    end

    return HolyExtractAuth(
        apiBase,
        key,
        data
    )
end

local function HolyShouldUseSniper(auth)

    auth =
        type(auth) == "table"
        and auth
        or {}

    local plan =
        tostring(auth.Plan or ""):lower()

    local features =
        type(auth.Features) == "table"
        and auth.Features
        or {}

    if plan:find("finder", 1, true)
    or plan:find("server_sniper", 1, true)
    or plan:find("server sniper", 1, true)
    or plan:find("sniper_slot", 1, true) then

        return true
    end

    if HolyHasFeature(features, "server_finder") == true
    and HolyHasFeature(features, "basic") ~= true then

        return true
    end

    return false
end

local function HolyVerifyKey(key)

    key =
        HolyClean(key)

    if key == "" then

        return nil,
            "Enter a key first."
    end

    local proAuth,
        proErr =
        HolyVerifyAt(
            HOLY_PRO_API,
            key
        )

    if type(proAuth) == "table"
    and proAuth.Valid == true then

        if HolyShouldUseSniper(proAuth) == true then

            local sniperAuth,
                sniperErr =
                HolyVerifyAt(
                    HOLY_SNIPER_API,
                    key
                )

            if type(sniperAuth) == "table"
            and sniperAuth.Valid == true then

                sniperAuth.Product =
                    "sniper"

                return sniperAuth,
                    nil
            end

            return nil,
                tostring(sniperErr or "Server Sniper verify failed.")
        end

        proAuth.Product =
            "pro"

        return proAuth,
            nil
    end

    local sniperAuth,
        sniperErr =
        HolyVerifyAt(
            HOLY_SNIPER_API,
            key
        )

    if type(sniperAuth) == "table"
    and sniperAuth.Valid == true then

        sniperAuth.Product =
            "sniper"

        return sniperAuth,
            nil
    end

    return nil,
        tostring(proErr or sniperErr or "Key verify failed.")
end

local function HolyApplyAuth(auth)

    if type(auth) ~= "table" then
        return false
    end

    HolyEnv.HOLY_AUTH =
        auth

    _G.HOLY_AUTH =
        auth

    HolyWriteFile(
        HOLY_KEY_FILE,
        tostring(auth.Key or "")
    )

    HolyWriteFile(
        HOLY_SESSION_FILE,
        HolyEncodeJson(auth)
    )

    return true
end

local function HolyValidateSource(body)

    if type(body) ~= "string"
    or body == "" then

        return nil,
            "empty source"
    end

    if body:sub(1, 3) == "\239\187\191" then

        body =
            body:sub(4)
    end

    local decoded =
        HolyDecodeJson(
            body
        )

    if type(decoded) == "table" then

        local source =
            decoded.source
            or decoded.Source
            or decoded.script
            or decoded.Script
            or decoded.code
            or decoded.Code

        if type(source) == "string"
        and source ~= "" then

            return source,
                nil
        end

        return nil,
            tostring(
                decoded.error
                or decoded.Error
                or "source json missing source"
            )
    end

    local preview =
        body:sub(1, 240):lower()

    if preview:find("<!doctype html", 1, true)
    or preview:find("<html", 1, true)
    or preview:find("404", 1, true)
    or preview:find("not found", 1, true) then

        return nil,
            "source_fetch_failed / bad source"
    end

    return body,
        nil
end

local function HolyFetchSource(auth)

    auth =
        type(auth) == "table"
        and auth
        or {}

    local apiBase =
        HolyClean(auth.ApiBase)

    if apiBase == "" then

        return nil,
            "missing api base"
    end

    local payload = {
        Key =
            auth.Key,

        key =
            auth.Key,

        SessionId =
            auth.SessionId,

        sessionId =
            auth.SessionId,

        UserId =
            tostring(LocalPlayer.UserId),

        RobloxUserId =
            tostring(LocalPlayer.UserId),

        Username =
            tostring(LocalPlayer.Name),

        RobloxUsername =
            tostring(LocalPlayer.Name),

        PlaceId =
            tostring(game.PlaceId),

        JobId =
            tostring(game.JobId),

        Loader =
            "holy_loader_gag2",

        LoaderVersion =
            HOLY_LOADER_VERSION,
    }

    local body,
        postErr,
        status =
        HolyHttpRaw(
            "POST",
            apiBase .. "/source",
            payload,
            "application/json, text/plain"
        )

    if type(body) == "string"
    and body ~= ""
    and tonumber(status) >= 200
    and tonumber(status) < 300 then

        local source,
            sourceErr =
            HolyValidateSource(
                body
            )

        if source then
            return source, nil
        end
    end

    local getBody,
        getErr =
        HolyHttpGetText(
            apiBase
            .. "/source?sessionId="
            .. HttpService:UrlEncode(
                tostring(auth.SessionId or "")
            )
        )

    if type(getBody) ~= "string"
    or getBody == "" then

        return nil,
            tostring(postErr or getErr or "source fetch failed")
    end

    return HolyValidateSource(
        getBody
    )
end

local function HolyRunSource(source)

    local compiler =
        HolyCompiler()

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

    return true,
        "loaded"
end

--==================================================
-- OBSIDIAN UI HELPERS
--==================================================

local function HolyLoadObsidian()

    if type(HOLY_LIBRARY) == "table" then

        return HOLY_LIBRARY,
            nil
    end

    local source,
        err =
        HolyHttpGetText(
            HOLY_OBSIDIAN_LIBRARY_URL
        )

    if type(source) ~= "string"
    or source == "" then

        return nil,
            "Obsidian download failed: "
            .. tostring(err)
    end

    local lower =
        source:sub(1, 200):lower()

    if lower:find("<html", 1, true)
    or lower:find("<!doctype", 1, true) then

        return nil,
            "Obsidian returned HTML"
    end

    local compiler =
        HolyCompiler()

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

    HOLY_LIBRARY =
        library

    return library,
        nil
end

local function HolyAddLabel(parent, text, wrap)

    if type(parent) ~= "table"
    or type(parent.AddLabel) ~= "function" then

        return nil
    end

    local ok,
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

local function HolyAddDivider(parent)

    if type(parent) ~= "table"
    or type(parent.AddDivider) ~= "function" then

        return false
    end

    pcall(function()

        parent:AddDivider()
    end)

    return true
end

local function HolyAddButton(parent, text, callback, tooltip, doubleClick)

    if type(parent) ~= "table"
    or type(parent.AddButton) ~= "function" then

        return nil
    end

    local ok,
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

local function HolyAddGroupbox(tab, side, title, icon)

    if type(tab) ~= "table" then
        return nil
    end

    local method =
        side == "Right"
        and "AddRightGroupbox"
        or "AddLeftGroupbox"

    if type(tab[method]) ~= "function" then
        return nil
    end

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

    if ok == true then
        return groupbox
    end

    return nil
end

local function HolySetAnyLabel(label, text)

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

local function HolyRefreshStatusAuth(auth, message)

    auth =
        type(auth) == "table"
        and auth
        or HolyEnv.HOLY_AUTH
        or {}

    local features =
        type(auth.Features) == "table"
        and auth.Features
        or {}

    local slots =
        type(auth.Slots) == "table"
        and auth.Slots
        or {}

    local featureList =
        {}

    for key, value in pairs(features) do

        if value == true then

            table.insert(
                featureList,
                tostring(key)
            )
        end
    end

    table.sort(
        featureList
    )

    HolySetStatus(
        message
        or "Waiting for key..."
    )

    HolySetAnyLabel(
        HOLY_UI.AccountLabel,
        "Account: "
            .. tostring(LocalPlayer.Name)
            .. " | "
            .. tostring(LocalPlayer.UserId)
    )

    HolySetAnyLabel(
        HOLY_UI.KeyLabel,
        "Key: "
            .. tostring(auth.KeyPrefix or "None")
    )

    HolySetAnyLabel(
        HOLY_UI.PlanLabel,
        "Plan: "
            .. tostring(auth.Plan or "--")
            .. " | "
            .. HolyFeatureText(features)
    )

    HolySetAnyLabel(
        HOLY_UI.TimeLabel,
        "Time Left: "
            .. HolyFormatTime(
                tonumber(auth.TimeLeft)
                or 0
            )
    )

    HolySetAnyLabel(
        HOLY_UI.SlotLabel,
        "Finder Slots: "
            .. tostring(slots.active or slots.Active or 0)
            .. "/"
            .. tostring(slots.max or slots.Max or 3)
    )

    HolySetAnyLabel(
        HOLY_UI.FeaturesLabel,
        "Features: "
            .. (
                #featureList > 0
                and table.concat(featureList, ", ")
                or "None"
            )
    )
end

--==================================================
-- LOAD FLOW
--==================================================

local function HolyVerifyAndLoad(key)

    if HOLY_BUSY == true then

        HolyNotify(
            "HOLY Loader",
            "Already checking a key.",
            3
        )

        return false
    end

    HOLY_BUSY =
        true

    key =
        HolyClean(key)

    HolySetStatus(
        "Checking key..."
    )

    HolyNotify(
        "HOLY Key System",
        "Checking key...",
        2
    )

    task.spawn(function()

        local auth,
            verifyErr =
            HolyVerifyKey(
                key
            )

        if type(auth) ~= "table" then

            HOLY_BUSY =
                false

            HolySetStatus(
                "Key failed: "
                .. tostring(verifyErr)
            )

            HolyNotify(
                "Key Failed",
                tostring(verifyErr),
                5
            )

            return
        end

        HolyApplyAuth(
            auth
        )

        local productText =
            auth.Product == "sniper"
            and "Server Sniper"
            or "HOLY Pro"

        HolyRefreshStatusAuth(
            auth,
            "Verified. Loading "
                .. productText
                .. "..."
        )

        HolyNotify(
            "Key Verified",
            productText
                .. " | "
                .. HolyFormatTime(auth.TimeLeft)
                .. " left.",
            4
        )

        task.wait(
            0.25
        )

        local source,
            sourceErr =
            HolyFetchSource(
                auth
            )

        if type(source) ~= "string"
        or source == "" then

            HOLY_BUSY =
                false

            HolySetStatus(
                "Load failed: "
                .. tostring(sourceErr)
            )

            HolyNotify(
                "Source Failed",
                tostring(sourceErr),
                6
            )

            return
        end

        local ok,
            runErr =
            HolyRunSource(
                source
            )

        HOLY_BUSY =
            false

        if ok ~= true then

            HolySetStatus(
                "Load failed: "
                .. tostring(runErr)
            )

            HolyNotify(
                "Load Failed",
                tostring(runErr),
                6
            )

            return
        end

        HolyNotify(
            "HOLY",
            productText
                .. " loaded.",
            4
        )

        HolyStop(
            "loaded"
        )
    end)

    return true
end

--==================================================
-- FALLBACK UI
--==================================================

local function HolyCreateFallback(savedKey, lastError)

    local gui =
        Instance.new(
            "ScreenGui"
        )

    gui.Name =
        "HOLY_GAG2_LOADER_FALLBACK"

    gui.ResetOnSpawn =
        false

    gui.IgnoreGuiInset =
        true

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

    local frame =
        Instance.new(
            "Frame"
        )

    frame.AnchorPoint =
        Vector2.new(0.5, 0.5)

    frame.Position =
        UDim2.fromScale(0.5, 0.5)

    frame.Size =
        UDim2.fromOffset(460, 230)

    frame.BackgroundColor3 =
        Color3.fromRGB(12, 12, 16)

    frame.BorderSizePixel =
        0

    frame.Parent =
        gui

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 12)

    corner.Parent =
        frame

    local title =
        Instance.new("TextLabel")

    title.BackgroundTransparency =
        1

    title.Position =
        UDim2.fromOffset(22, 18)

    title.Size =
        UDim2.new(1, -44, 0, 30)

    title.Font =
        Enum.Font.GothamBold

    title.TextSize =
        20

    title.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.Text =
        "HOLY Loader"

    title.Parent =
        frame

    local input =
        Instance.new("TextBox")

    input.BackgroundColor3 =
        Color3.fromRGB(20, 21, 28)

    input.BorderSizePixel =
        0

    input.Position =
        UDim2.fromOffset(22, 72)

    input.Size =
        UDim2.new(1, -44, 0, 40)

    input.Font =
        Enum.Font.GothamMedium

    input.TextSize =
        13

    input.TextColor3 =
        Color3.fromRGB(245, 245, 247)

    input.PlaceholderText =
        "HOLY-XXXX-XXXX-XXXX"

    input.ClearTextOnFocus =
        false

    input.Text =
        tostring(savedKey or "")

    input.Parent =
        frame

    Instance.new("UICorner", input).CornerRadius =
        UDim.new(0, 8)

    local verify =
        Instance.new("TextButton")

    verify.BackgroundColor3 =
        Color3.fromRGB(130, 90, 255)

    verify.BorderSizePixel =
        0

    verify.Position =
        UDim2.fromOffset(22, 126)

    verify.Size =
        UDim2.new(0.5, -28, 0, 38)

    verify.Font =
        Enum.Font.GothamBold

    verify.TextSize =
        14

    verify.TextColor3 =
        Color3.fromRGB(255, 255, 255)

    verify.Text =
        "Verify Key"

    verify.Parent =
        frame

    Instance.new("UICorner", verify).CornerRadius =
        UDim.new(0, 8)

    local reset =
        Instance.new("TextButton")

    reset.BackgroundColor3 =
        Color3.fromRGB(24, 25, 34)

    reset.BorderSizePixel =
        0

    reset.Position =
        UDim2.new(0.5, 6, 0, 126)

    reset.Size =
        UDim2.new(0.5, -28, 0, 38)

    reset.Font =
        Enum.Font.GothamBold

    reset.TextSize =
        14

    reset.TextColor3 =
        Color3.fromRGB(245, 245, 247)

    reset.Text =
        "Reset Key"

    reset.Parent =
        frame

    Instance.new("UICorner", reset).CornerRadius =
        UDim.new(0, 8)

    local status =
        Instance.new("TextLabel")

    status.BackgroundTransparency =
        1

    status.Position =
        UDim2.fromOffset(22, 178)

    status.Size =
        UDim2.new(1, -44, 0, 42)

    status.Font =
        Enum.Font.GothamMedium

    status.TextSize =
        12

    status.TextWrapped =
        true

    status.TextColor3 =
        Color3.fromRGB(170, 175, 190)

    status.TextXAlignment =
        Enum.TextXAlignment.Left

    status.TextYAlignment =
        Enum.TextYAlignment.Top

    status.Text =
        tostring(lastError or "Obsidian failed. Fallback active.")

    status.Parent =
        frame

    HOLY_UI.StatusLabel =
        status

    HolyTrack(
        verify.MouseButton1Click:Connect(function()

            HolyVerifyAndLoad(
                input.Text
            )
        end)
    )

    HolyTrack(
        reset.MouseButton1Click:Connect(function()

            HolyDeleteFile(
                HOLY_KEY_FILE
            )

            HolyDeleteFile(
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

local function HolyCreateObsidian(savedKey, lastError)

    HolyStop(
        "rebuild"
    )

    local Library,
        libraryErr =
        HolyLoadObsidian()

    if type(Library) ~= "table" then

        return HolyCreateFallback(
            savedKey,
            libraryErr
                or lastError
                or "Obsidian failed."
        )
    end

    HOLY_LIBRARY =
        Library

    pcall(function()

        Library.ShowToggleFrameInKeybinds =
            true
    end)

    local ok,
        window =
        pcall(function()

            return Library:CreateWindow({
                Title =
                    "HOLY HUB",

                Footer =
                    "loader v1.2",

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
    or type(window) ~= "table" then

        return HolyCreateFallback(
            savedKey,
            "Obsidian window failed: "
                .. tostring(window)
        )
    end

    HOLY_WINDOW =
        window

    local tabs =
        {}

    pcall(function()

        tabs.Key =
            window:AddKeyTab(
                "Key System"
            )
    end)

    if type(tabs.Key) ~= "table" then

        pcall(function()

            tabs.Key =
                window:AddTab(
                    "Key System",
                    "key-round"
                )
        end)
    end

    pcall(function()

        tabs.Status =
            window:AddTab(
                "Status",
                "activity"
            )
    end)

    pcall(function()

        tabs.Links =
            window:AddTab(
                "Links",
                "link"
            )
    end)

    pcall(function()

        tabs.UI =
            window:AddTab(
                "UI",
                "settings"
            )
    end)

    if type(tabs.Key) == "table" then

        HolyAddLabel(
            tabs.Key,
            "HOLY Access",
            false
        )

        HolyAddLabel(
            tabs.Key,
            "Enter your HOLY key below. The loader automatically opens HOLY Pro or Server Sniper based on your key.",
            true
        )

        HolyAddDivider(
            tabs.Key
        )

        HOLY_UI.StatusLabel =
            HolyAddLabel(
                tabs.Key,
                tostring(
                    lastError
                    or (
                        savedKey ~= ""
                        and "Saved key found. Auto-loading..."
                        or "Waiting for key..."
                    )
                ),
                true
            )

        HolyAddDivider(
            tabs.Key
        )

        if type(tabs.Key.AddKeyBox) == "function" then

            pcall(function()

                tabs.Key:AddKeyBox(function(receivedKey)

                    HolyVerifyAndLoad(
                        receivedKey
                    )
                end)
            end)

        else

            local manualBox =
                HolyAddGroupbox(
                    tabs.Key,
                    "Left",
                    "Manual Key",
                    "key"
                )

            if type(manualBox) == "table" then

                local typedKey =
                    savedKey

                if type(manualBox.AddInput) == "function" then

                    pcall(function()

                        manualBox:AddInput("HolyLoaderGAG2ManualKey", {
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
                                "HOLY-XXXX-XXXX-XXXX",

                            Callback =
                                function(value)

                                    typedKey =
                                        tostring(value or "")
                                end,
                        })
                    end)
                end

                HolyAddButton(
                    manualBox,
                    "Verify Key",
                    function()

                        HolyVerifyAndLoad(
                            typedKey
                        )
                    end,
                    "Verify and load."
                )
            end
        end

        HolyAddButton(
            tabs.Key,
            "Use Saved Key",
            function()

                local key =
                    HolyReadFile(
                        HOLY_KEY_FILE
                    )

                if key == "" then

                    HolyNotify(
                        "HOLY Key System",
                        "No saved key found.",
                        3
                    )

                    return
                end

                HolyVerifyAndLoad(
                    key
                )
            end,
            "Verify and load saved key."
        )

        HolyAddButton(
            tabs.Key,
            "Reset Saved Key",
            function()

                HolyDeleteFile(
                    HOLY_KEY_FILE
                )

                HolyDeleteFile(
                    HOLY_SESSION_FILE
                )

                HolySetStatus(
                    "Saved key reset. Enter a new key."
                )

                HolyNotify(
                    "HOLY Key System",
                    "Saved key reset.",
                    3
                )
            end,
            "Deletes local key/session files.",
            true
        )
    end

    if type(tabs.Status) == "table" then

        local accountBox =
            HolyAddGroupbox(
                tabs.Status,
                "Left",
                "Account",
                "user"
            )

        local licenseBox =
            HolyAddGroupbox(
                tabs.Status,
                "Right",
                "License",
                "badge-check"
            )

        local finderBox =
            HolyAddGroupbox(
                tabs.Status,
                "Left",
                "Finder Slot",
                "radar"
            )

        local featureBox =
            HolyAddGroupbox(
                tabs.Status,
                "Right",
                "Features",
                "list-checks"
            )

        if type(accountBox) == "table" then

            HOLY_UI.AccountLabel =
                HolyAddLabel(
                    accountBox,
                    "Account: "
                        .. tostring(LocalPlayer.Name)
                        .. " | "
                        .. tostring(LocalPlayer.UserId),
                    true
                )

            HolyAddLabel(
                accountBox,
                "PlaceId: "
                    .. tostring(game.PlaceId),
                true
            )
        end

        if type(licenseBox) == "table" then

            HOLY_UI.KeyLabel =
                HolyAddLabel(
                    licenseBox,
                    "Key: "
                        .. (
                            savedKey ~= ""
                            and HolyShortKey(savedKey)
                            or "None"
                        ),
                    true
                )

            HOLY_UI.PlanLabel =
                HolyAddLabel(
                    licenseBox,
                    "Plan: --",
                    true
                )

            HOLY_UI.TimeLabel =
                HolyAddLabel(
                    licenseBox,
                    "Time Left: --",
                    true
                )
        end

        if type(finderBox) == "table" then

            HOLY_UI.SlotLabel =
                HolyAddLabel(
                    finderBox,
                    "Finder Slots: --/3",
                    true
                )

            HolyAddLabel(
                finderBox,
                "Server Sniper is slot-based. Normal HOLY Pro keys load Pro instead.",
                true
            )
        end

        if type(featureBox) == "table" then

            HOLY_UI.FeaturesLabel =
                HolyAddLabel(
                    featureBox,
                    "Features: --",
                    true
                )

            HolyAddButton(
                featureBox,
                "Refresh Saved Key",
                function()

                    local key =
                        HolyReadFile(
                            HOLY_KEY_FILE
                        )

                    if key == "" then

                        HolyNotify(
                            "HOLY Key System",
                            "No saved key found.",
                            3
                        )

                        return
                    end

                    HolyVerifyAndLoad(
                        key
                    )
                end,
                "Verify the saved key again."
            )
        end
    end

    if type(tabs.Links) == "table" then

        local actionsBox =
            HolyAddGroupbox(
                tabs.Links,
                "Left",
                "Actions",
                "mouse-pointer-click"
            )

        local infoBox =
            HolyAddGroupbox(
                tabs.Links,
                "Right",
                "Info",
                "info"
            )

        if type(actionsBox) == "table" then

            HolyAddButton(
                actionsBox,
                "Copy Public Loadstring",
                function()

                    if HolyCopyText(
                        HOLY_PUBLIC_LOADSTRING
                    ) == true then

                        HolyNotify(
                            "Copied",
                            "Public loadstring copied.",
                            3
                        )

                    else

                        HolyNotify(
                            "Clipboard Failed",
                            "Your executor does not support clipboard.",
                            4
                        )
                    end
                end,
                "Copies the public HOLY loader loadstring."
            )

            HolyAddButton(
                actionsBox,
                "Copy Discord Invite",
                function()

                    if HolyClean(HOLY_DISCORD_INVITE) == "" then

                        HolyNotify(
                            "Discord",
                            "Discord invite is not set yet.",
                            4
                        )

                        return
                    end

                    if HolyCopyText(
                        HOLY_DISCORD_INVITE
                    ) == true then

                        HolyNotify(
                            "Copied",
                            "Discord invite copied.",
                            3
                        )

                    else

                        HolyNotify(
                            "Clipboard Failed",
                            "Your executor does not support clipboard.",
                            4
                        )
                    end
                end,
                "Copies Discord invite."
            )

            HolyAddButton(
                actionsBox,
                "Reset Saved Key",
                function()

                    HolyDeleteFile(
                        HOLY_KEY_FILE
                    )

                    HolyDeleteFile(
                        HOLY_SESSION_FILE
                    )

                    HolySetStatus(
                        "Saved key reset. Enter a new key."
                    )

                    HolyNotify(
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

            HolyAddLabel(
                infoBox,
                "Current public loader:",
                false
            )

            HolyAddLabel(
                infoBox,
                HOLY_PUBLIC_LOADSTRING,
                true
            )

            HolyAddDivider(
                infoBox
            )

            HolyAddLabel(
                infoBox,
                "Keys are saved locally in HolyGAG2/HolyLoaderGAG2Key.txt after successful verification.",
                true
            )
        end
    end

    if type(tabs.UI) == "table" then

        local menuBox =
            HolyAddGroupbox(
                tabs.UI,
                "Left",
                "Menu",
                "wrench"
            )

        if type(menuBox) == "table" then

            HolyAddLabel(
                menuBox,
                "This tab is only for loader actions. The main script UI opens after your key loads.",
                true
            )

            HolyAddButton(
                menuBox,
                "Unload Loader",
                function()

                    HolyStop(
                        "manual unload"
                    )
                end,
                "Closes the loader window."
            )
        end
    end

    HolyRefreshStatusAuth(
        {
            KeyPrefix =
                savedKey ~= ""
                and HolyShortKey(savedKey)
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
                and "Saved key found. Auto-loading..."
                or "Waiting for key..."
            )
    )

    return window
end

--==================================================
-- STARTUP
--==================================================

local savedKey =
    HolyReadFile(
        HOLY_KEY_FILE
    )

HolyCreateObsidian(
    savedKey,
    savedKey ~= ""
    and "Saved key found. Auto-loading..."
    or "Waiting for key..."
)

if savedKey ~= "" then

    task.delay(0.35, function()

        if HOLY_BUSY ~= true then

            HolyVerifyAndLoad(
                savedKey
            )
        end
    end)
end
