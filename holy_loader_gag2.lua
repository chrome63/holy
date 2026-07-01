--==================================================
-- HOLY GAG2 OFFICIAL LOADER
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

local HOLY_SETTINGS_FOLDER =
    "HolyGAG2"

local HOLY_KEY_FILE =
    HOLY_SETTINGS_FOLDER
    .. "/HolyLoaderGAG2Key.json"

local HOLY_LOADER_VERSION =
    "holy_loader_gag2_v1"

local HolyLoaderRunning =
    false

local HolyLoaderGui =
    nil

local HolyStatusLabel =
    nil

local HolyKeyBox =
    nil

local function HolyCleanText(value)

    local text =
        tostring(value or "")

    text =
        text:gsub("^%s+", "")

    text =
        text:gsub("%s+$", "")

    return text
end

local function HolySetStatus(text)

    text =
        tostring(text or "Ready.")

    if HolyStatusLabel then

        HolyStatusLabel.Text =
            text
    end

    print(
        "[HOLY LOADER]",
        text
    )
end

local function HolyNotify(title, text, duration)

    pcall(function()

        StarterGui:SetCore(
            "SendNotification",
            {
                Title =
                    tostring(title or "HOLY"),

                Text =
                    tostring(text or ""),

                Duration =
                    tonumber(duration)
                    or 5,
            }
        )
    end)
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

            if not isfolder(HOLY_SETTINGS_FOLDER) then

                makefolder(
                    HOLY_SETTINGS_FOLDER
                )
            end
        end)

    return ok == true
end

local function HolySaveKey(key)

    key =
        HolyCleanText(key)

    if key == "" then
        return false
    end

    if HolyCanUseFiles() ~= true then
        return false
    end

    HolyEnsureFolder()

    local payload = {
        Key =
            key,

        SavedAt =
            os.time(),

        Version =
            HOLY_LOADER_VERSION,
    }

    local ok,
        encoded =
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
                HOLY_KEY_FILE,
                encoded
            )
        end)

    return writeOk == true
end

local function HolyLoadSavedKey()

    if HolyCanUseFiles() ~= true then
        return ""
    end

    local exists =
        false

    pcall(function()

        exists =
            isfile(
                HOLY_KEY_FILE
            )
    end)

    if exists ~= true then
        return ""
    end

    local ok,
        raw =
        pcall(function()

            return readfile(
                HOLY_KEY_FILE
            )
        end)

    if ok ~= true
    or type(raw) ~= "string"
    or raw == "" then

        return ""
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

        return HolyCleanText(
            data.Key
            or data.key
            or ""
        )
    end

    return HolyCleanText(raw)
end

local function HolyResetSavedKey()

    if type(delfile) == "function" then

        pcall(function()

            if isfile(HOLY_KEY_FILE) then

                delfile(
                    HOLY_KEY_FILE
                )
            end
        end)
    end

    if HolyKeyBox then

        HolyKeyBox.Text =
            ""
    end

    HolySetStatus(
        "Saved key reset."
    )
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

local function HolyJsonEncode(value)

    local ok,
        encoded =
        pcall(function()

            return HttpService:JSONEncode(
                value
            )
        end)

    if ok == true
    and type(encoded) == "string" then

        return encoded
    end

    return "{}"
end

local function HolyJsonDecode(text)

    local ok,
        data =
        pcall(function()

            return HttpService:JSONDecode(
                tostring(text or "")
            )
        end)

    if ok == true
    and type(data) == "table" then

        return data
    end

    return nil
end

local function HolyHttpJsonPost(url, payload)

    local requestFunction =
        HolyGetRequestFunction()

    if type(requestFunction) ~= "function" then

        return nil,
            "Executor request/http_request is missing."
    end

    local body =
        HolyJsonEncode(
            payload or {}
        )

    local ok,
        response =
        pcall(function()

            return requestFunction({
                Url =
                    url,

                Method =
                    "POST",

                Headers = {
                    ["Content-Type"] =
                        "application/json",

                    ["Accept"] =
                        "application/json, text/plain",

                    ["Cache-Control"] =
                        "no-cache",
                },

                Body =
                    body,
            })
        end)

    if ok ~= true then

        return nil,
            tostring(response)
    end

    if type(response) == "string" then

        return {
            StatusCode =
                200,

            Body =
                response,
        },
            nil
    end

    if type(response) ~= "table" then

        return nil,
            "bad response"
    end

    response.StatusCode =
        tonumber(
            response.StatusCode
            or response.Status
            or response.status
            or response.status_code
            or 200
        )
        or 200

    response.Body =
        response.Body
        or response.body
        or response.ResponseBody
        or response.responseBody
        or ""

    return response,
        nil
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
                HolyCleanText(value)

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

local function HolyFeatureEnabled(features, name)

    name =
        tostring(name or "")

    if type(features) ~= "table"
    or name == "" then

        return false
    end

    if features[name] == true then
        return true
    end

    local lower =
        name:lower()

    for key, value in pairs(features) do

        if value == true
        and tostring(key):lower() == lower then

            return true
        end
    end

    return false
end

local function HolyExtractAuth(data, apiBase, key)

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

    local sessionId =
        HolyCleanText(
            data.sessionId
            or data.SessionId
            or data.session_id
            or sessionData.id
            or sessionData.Id
            or sessionData.sessionId
            or sessionData.SessionId
            or ""
        )

    local plan =
        HolyCleanText(
            data.plan
            or data.Plan
            or keyData.plan
            or keyData.Plan
            or ""
        )

    local valid =
        data.ok == true
        or data.valid == true
        or data.Valid == true

    if valid ~= true then

        return nil,
            tostring(
                data.error
                or data.Error
                or "invalid key"
            )
    end

    if sessionId == "" then

        return nil,
            "missing session id"
    end

    return {
        Valid =
            true,

        Key =
            key,

        SessionId =
            sessionId,

        Features =
            features,

        Plan =
            plan,

        ApiBase =
            apiBase,

        VerifiedAt =
            os.time(),

        RobloxUserId =
            tostring(LocalPlayer.UserId),

        RobloxUsername =
            tostring(LocalPlayer.Name),

        LoaderVersion =
            HOLY_LOADER_VERSION,
    },
        nil
end

local function HolyBuildVerifyPayload(key)

    return {
        Key =
            key,

        key =
            key,

        RobloxUserId =
            tostring(LocalPlayer.UserId),

        RobloxUsername =
            tostring(LocalPlayer.Name),

        UserId =
            tostring(LocalPlayer.UserId),

        Username =
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

local function HolyVerifyAt(apiBase, key)

    local response,
        requestError =
        HolyHttpJsonPost(
            apiBase .. "/verify",
            HolyBuildVerifyPayload(key)
        )

    if response == nil then

        return nil,
            requestError
    end

    local data =
        HolyJsonDecode(
            response.Body
        )

    if type(data) ~= "table" then

        return nil,
            "verify returned non-json"
    end

    return HolyExtractAuth(
        data,
        apiBase,
        key
    )
end

local function HolyIsServerSniperAuth(auth)

    if type(auth) ~= "table" then
        return false
    end

    local features =
        type(auth.Features) == "table"
        and auth.Features
        or {}

    if HolyFeatureEnabled(features, "admin") == true then
        return true
    end

    if HolyFeatureEnabled(features, "dev_tools") == true then
        return true
    end

    if HolyFeatureEnabled(features, "server_finder") == true then
        return true
    end

    if HolyFeatureEnabled(features, "pet_sniper") == true then
        return true
    end

    if HolyFeatureEnabled(features, "pet_sniper_autobuy") == true then
        return true
    end

    local plan =
        tostring(auth.Plan or ""):lower()

    if plan:find("finder", 1, true)
    or plan:find("sniper", 1, true)
    or plan:find("server", 1, true) then

        return true
    end

    return false
end

local function HolyVerifyKey(key)

    key =
        HolyCleanText(key)

    if key == "" then

        return nil,
            "Enter a key first."
    end

    local proAuth,
        proError =
        HolyVerifyAt(
            HOLY_PRO_API,
            key
        )

    if type(proAuth) == "table"
    and proAuth.Valid == true then

        if HolyIsServerSniperAuth(proAuth) == true then

            local sniperAuth,
                sniperError =
                HolyVerifyAt(
                    HOLY_SNIPER_API,
                    key
                )

            if type(sniperAuth) == "table"
            and sniperAuth.Valid == true then

                return sniperAuth,
                    "sniper"
            end

            return nil,
                sniperError
                or "Server Sniper verify failed."
        end

        return proAuth,
            "pro"
    end

    local sniperAuth,
        sniperError =
        HolyVerifyAt(
            HOLY_SNIPER_API,
            key
        )

    if type(sniperAuth) == "table"
    and sniperAuth.Valid == true then

        return sniperAuth,
            "sniper"
    end

    return nil,
        proError
        or sniperError
        or "Key verify failed."
end

local function HolySetAuth(auth)

    if type(getgenv) == "function" then

        getgenv().HOLY_AUTH =
            auth
    end

    _G.HOLY_AUTH =
        auth
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
        HolyJsonDecode(
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
                or "source json had no source"
            )
    end

    local preview =
        body:sub(1, 240):lower()

    if preview:find("<!doctype html", 1, true)
    or preview:find("<html", 1, true)
    or preview:find("404", 1, true)
    or preview:find("not found", 1, true) then

        return nil,
            "source fetch failed / bad source"
    end

    return body,
        nil
end

local function HolyFetchSource(auth)

    local apiBase =
        HolyCleanText(
            auth.ApiBase
        )

    if apiBase == "" then

        return nil,
            "missing api base"
    end

    local response,
        requestError =
        HolyHttpJsonPost(
            apiBase .. "/source",
            {
                Key =
                    auth.Key,

                key =
                    auth.Key,

                SessionId =
                    auth.SessionId,

                sessionId =
                    auth.SessionId,

                RobloxUserId =
                    tostring(LocalPlayer.UserId),

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
        )

    if response == nil then

        return nil,
            requestError
    end

    local statusCode =
        tonumber(response.StatusCode)
        or 200

    if statusCode < 200
    or statusCode >= 300 then

        return nil,
            "source_fetch_failed status "
            .. tostring(statusCode)
    end

    return HolyValidateSource(
        response.Body
    )
end

local function HolyRunSource(source)

    local compiler =
        loadstring
        or load

    if type(compiler) ~= "function" then

        return false,
            "loadstring/load missing"
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

        return false,
            "compile failed: "
            .. tostring(compileError or chunk)
    end

    local runOk,
        runError =
        pcall(chunk)

    if runOk ~= true then

        return false,
            "run failed: "
            .. tostring(runError)
    end

    return true,
        "loaded"
end

local function HolyExecuteKey(key)

    if HolyLoaderRunning == true then
        return
    end

    HolyLoaderRunning =
        true

    key =
        HolyCleanText(key)

    HolySetStatus(
        "Verifying key..."
    )

    local auth,
        productOrError =
        HolyVerifyKey(key)

    if type(auth) ~= "table"
    or auth.Valid ~= true then

        HolyLoaderRunning =
            false

        HolySetStatus(
            "Load failed: "
            .. tostring(productOrError)
        )

        HolyNotify(
            "HOLY",
            "Key failed: "
            .. tostring(productOrError),
            6
        )

        return false
    end

    local product =
        tostring(productOrError or "pro")

    HolySaveKey(
        key
    )

    HolySetAuth(
        auth
    )

    HolySetStatus(
        product == "sniper"
        and "Loading Server Sniper..."
        or "Loading HOLY Pro..."
    )

    local source,
        sourceError =
        HolyFetchSource(
            auth
        )

    if type(source) ~= "string"
    or source == "" then

        HolyLoaderRunning =
            false

        HolySetStatus(
            "Load failed: "
            .. tostring(sourceError)
        )

        HolyNotify(
            "HOLY",
            "Source failed: "
            .. tostring(sourceError),
            6
        )

        return false
    end

    HolySetStatus(
        "Running..."
    )

    local ok,
        runError =
        HolyRunSource(
            source
        )

    if ok ~= true then

        HolyLoaderRunning =
            false

        HolySetStatus(
            "Load failed: "
            .. tostring(runError)
        )

        HolyNotify(
            "HOLY",
            tostring(runError),
            7
        )

        return false
    end

    HolySetStatus(
        "Loaded."
    )

    HolyNotify(
        "HOLY",
        product == "sniper"
        and "Server Sniper loaded."
        or "HOLY Pro loaded.",
        4
    )

    task.delay(0.5, function()

        if HolyLoaderGui then

            pcall(function()

                HolyLoaderGui.Enabled =
                    false
            end)
        end
    end)

    return true
end

local function HolyCreate(className, props, parent)

    local object =
        Instance.new(
            className
        )

    for key, value in pairs(props or {}) do

        object[key] =
            value
    end

    object.Parent =
        parent

    return object
end

local function HolyCorner(parent, radius)

    return HolyCreate(
        "UICorner",
        {
            CornerRadius =
                radius
                or UDim.new(0, 8),
        },
        parent
    )
end

local function HolyStroke(parent, color, transparency, thickness)

    return HolyCreate(
        "UIStroke",
        {
            Color =
                color
                or Color3.fromRGB(80, 80, 95),

            Transparency =
                transparency
                or 0.25,

            Thickness =
                thickness
                or 1,
        },
        parent
    )
end

local function HolyMakeButton(parent, text, pos, size)

    local button =
        HolyCreate(
            "TextButton",
            {
                BackgroundColor3 =
                    Color3.fromRGB(24, 24, 32),

                BorderSizePixel =
                    0,

                Position =
                    pos,

                Size =
                    size,

                Font =
                    Enum.Font.GothamBold,

                Text =
                    tostring(text or "Button"),

                TextColor3 =
                    Color3.fromRGB(235, 238, 245),

                TextSize =
                    13,

                AutoButtonColor =
                    true,
            },
            parent
        )

    HolyCorner(
        button,
        UDim.new(0, 8)
    )

    HolyStroke(
        button,
        Color3.fromRGB(90, 90, 115),
        0.35,
        1
    )

    return button
end

local function HolyBuildLoaderGui()

    if HolyLoaderGui then

        pcall(function()

            HolyLoaderGui:Destroy()
        end)
    end

    local gui =
        HolyCreate(
            "ScreenGui",
            {
                Name =
                    "HOLY_GAG2_LOADER",

                ResetOnSpawn =
                    false,

                IgnoreGuiInset =
                    true,

                ZIndexBehavior =
                    Enum.ZIndexBehavior.Sibling,
            },
            CoreGui
        )

    HolyLoaderGui =
        gui

    local holder =
        HolyCreate(
            "Frame",
            {
                AnchorPoint =
                    Vector2.new(0.5, 0.5),

                Position =
                    UDim2.fromScale(0.5, 0.5),

                Size =
                    UDim2.fromOffset(560, 250),

                BackgroundColor3 =
                    Color3.fromRGB(12, 12, 16),

                BorderSizePixel =
                    0,
            },
            gui
        )

    HolyCorner(
        holder,
        UDim.new(0, 12)
    )

    HolyStroke(
        holder,
        Color3.fromRGB(120, 85, 255),
        0.20,
        1
    )

    local title =
        HolyCreate(
            "TextLabel",
            {
                BackgroundTransparency =
                    1,

                Position =
                    UDim2.fromOffset(0, 12),

                Size =
                    UDim2.new(1, 0, 0, 32),

                Font =
                    Enum.Font.GothamBold,

                Text =
                    "HOLY GAG2 LOADER",

                TextColor3 =
                    Color3.fromRGB(245, 245, 255),

                TextSize =
                    20,

                TextXAlignment =
                    Enum.TextXAlignment.Center,
            },
            holder
        )

    local subtitle =
        HolyCreate(
            "TextLabel",
            {
                BackgroundTransparency =
                    1,

                Position =
                    UDim2.fromOffset(24, 48),

                Size =
                    UDim2.new(1, -48, 0, 34),

                Font =
                    Enum.Font.GothamMedium,

                Text =
                    "Enter your HOLY key. The loader will open the correct product automatically.",

                TextColor3 =
                    Color3.fromRGB(185, 188, 205),

                TextSize =
                    13,

                TextWrapped =
                    true,

                TextXAlignment =
                    Enum.TextXAlignment.Center,
            },
            holder
        )

    HolyStatusLabel =
        HolyCreate(
            "TextLabel",
            {
                BackgroundColor3 =
                    Color3.fromRGB(18, 18, 24),

                BorderSizePixel =
                    0,

                Position =
                    UDim2.fromOffset(24, 88),

                Size =
                    UDim2.new(1, -48, 0, 42),

                Font =
                    Enum.Font.GothamMedium,

                Text =
                    "Status: Ready.",

                TextColor3 =
                    Color3.fromRGB(220, 225, 240),

                TextSize =
                    13,

                TextWrapped =
                    true,

                TextXAlignment =
                    Enum.TextXAlignment.Center,
            },
            holder
        )

    HolyCorner(
        HolyStatusLabel,
        UDim.new(0, 8)
    )

    HolyStroke(
        HolyStatusLabel,
        Color3.fromRGB(48, 48, 60),
        0.35,
        1
    )

    HolyKeyBox =
        HolyCreate(
            "TextBox",
            {
                BackgroundColor3 =
                    Color3.fromRGB(18, 18, 24),

                BorderSizePixel =
                    0,

                Position =
                    UDim2.fromOffset(24, 146),

                Size =
                    UDim2.new(1, -168, 0, 36),

                Font =
                    Enum.Font.GothamMedium,

                PlaceholderText =
                    "HOLY-XXXX-XXXX-XXXX",

                Text =
                    HolyLoadSavedKey(),

                TextColor3 =
                    Color3.fromRGB(240, 240, 250),

                PlaceholderColor3 =
                    Color3.fromRGB(105, 108, 120),

                TextSize =
                    13,

                ClearTextOnFocus =
                    false,
            },
            holder
        )

    HolyCorner(
        HolyKeyBox,
        UDim.new(0, 8)
    )

    HolyStroke(
        HolyKeyBox,
        Color3.fromRGB(60, 60, 75),
        0.30,
        1
    )

    local executeButton =
        HolyMakeButton(
            holder,
            "Execute",
            UDim2.new(1, -132, 0, 146),
            UDim2.fromOffset(108, 36)
        )

    local savedButton =
        HolyMakeButton(
            holder,
            "Use Saved Key",
            UDim2.fromOffset(24, 194),
            UDim2.new(0.5, -30, 0, 34)
        )

    local resetButton =
        HolyMakeButton(
            holder,
            "Reset Saved Key",
            UDim2.new(0.5, 6, 0, 194),
            UDim2.new(0.5, -30, 0, 34)
        )

    executeButton.MouseButton1Click:Connect(function()

        HolyExecuteKey(
            HolyKeyBox.Text
        )
    end)

    savedButton.MouseButton1Click:Connect(function()

        local savedKey =
            HolyLoadSavedKey()

        if savedKey ~= "" then

            HolyKeyBox.Text =
                savedKey
        end

        HolyExecuteKey(
            HolyKeyBox.Text
        )
    end)

    resetButton.MouseButton1Click:Connect(function()

        HolyResetSavedKey()
    end)

    local savedKey =
        HolyLoadSavedKey()

    if savedKey ~= "" then

        HolySetStatus(
            "Saved key found. Auto-loading..."
        )

        task.delay(0.35, function()

            if HolyLoaderRunning ~= true then

                HolyExecuteKey(
                    savedKey
                )
            end
        end)

    else

        HolySetStatus(
            "Status: Ready."
        )
    end
end

HolyBuildLoaderGui()
