--==================================================
-- HOLY PUBLIC LOADER
--==================================================

local Players =
    game:GetService("Players")

local HttpService =
    game:GetService("HttpService")

local CoreGui =
    game:GetService("CoreGui")

local UserInputService =
    game:GetService("UserInputService")

local LocalPlayer =
    Players.LocalPlayer
    or Players.PlayerAdded:Wait()

local HOLY_LOADER_API =
    "https://holy-loader-api.benjicapalot041.workers.dev"

local HOLY_FOLDER =
    "HolyGAG2"

local HOLY_KEY_FILE =
    HOLY_FOLDER
    .. "/HolyAccessKey.txt"

local HOLY_SESSION_FILE =
    HOLY_FOLDER
    .. "/HolySession.json"

local HOLY_LOADER_VERSION =
    "holy-loader-v1"

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

local HOLY_LOADER_BUSY =
    false

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

    if typeof(HOLY_LOADER_GUI) == "Instance" then

        pcall(function()

            HOLY_LOADER_GUI:Destroy()
        end)
    end

    HOLY_LOADER_GUI =
        nil
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

function HolyLoaderSetStatus(label, text)

    if typeof(label) == "Instance" then

        label.Text =
            tostring(text or "")
    end
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

    local hours =
        math.floor(seconds / 3600)

    local minutes =
        math.floor((seconds % 3600) / 60)

    if hours > 0 then

        return tostring(hours)
            .. "h "
            .. tostring(minutes)
            .. "m"
    end

    return tostring(minutes)
        .. "m"
end

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

    HolyLoaderStop(
        "loading premium"
    )

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

function HolyLoaderVerifyAndLoad(key, statusLabel, button)

    if HOLY_LOADER_BUSY == true then

        return false
    end

    HOLY_LOADER_BUSY =
        true

    if typeof(button) == "Instance" then

        button.Text =
            "Checking..."
    end

    HolyLoaderSetStatus(
        statusLabel,
        "Checking key..."
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

            if typeof(button) == "Instance" then

                button.Text =
                    "Verify Key"
            end

            HolyLoaderSetStatus(
                statusLabel,
                "Key failed: "
                .. tostring(verifyErr)
            )

            return
        end

        HolyLoaderApplyAuth(
            key,
            data
        )

        local features =
            type(data.features) == "table"
            and data.features
            or {}

        local featureText =
            "Basic"

        if features.admin == true then

            featureText =
                "Owner/Admin"

        elseif features.pet_sniper == true
        or features.server_finder == true then

            featureText =
                "Pet Finder Slot"
        end

        HolyLoaderSetStatus(
            statusLabel,
            "Verified: "
            .. featureText
            .. " | "
            .. HolyLoaderFormatTime(
                data.timeLeft
            )
            .. " left. Loading..."
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

            if typeof(button) == "Instance" then

                button.Text =
                    "Verify Key"
            end

            HolyLoaderSetStatus(
                statusLabel,
                "Load failed: "
                .. tostring(loadErr)
            )
        end
    end)

    return true
end

function HolyLoaderCreateGui(savedKey)

    HolyLoaderStop(
        "rebuild gui"
    )

    local gui =
        Instance.new(
            "ScreenGui"
        )

    gui.Name =
        "HOLY_Key_Loader"

    gui.ResetOnSpawn =
        false

    gui.IgnoreGuiInset =
        true

    pcall(function()

        gui.ZIndexBehavior =
            Enum.ZIndexBehavior.Sibling
    end)

    local parent =
        CoreGui

    pcall(function()

        gui.Parent =
            parent
    end)

    if gui.Parent == nil then

        gui.Parent =
            LocalPlayer:WaitForChild(
                "PlayerGui"
            )
    end

    HOLY_LOADER_GUI =
        gui

    local dim =
        Instance.new(
            "Frame"
        )

    dim.Name =
        "Dim"

    dim.BackgroundColor3 =
        Color3.fromRGB(
            0,
            0,
            0
        )

    dim.BackgroundTransparency =
        0.18

    dim.BorderSizePixel =
        0

    dim.Size =
        UDim2.fromScale(
            1,
            1
        )

    dim.Parent =
        gui

    local card =
        Instance.new(
            "Frame"
        )

    card.Name =
        "Card"

    card.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )

    card.Position =
        UDim2.fromScale(
            0.5,
            0.5
        )

    card.Size =
        UDim2.fromOffset(
            430,
            270
        )

    card.BackgroundColor3 =
        Color3.fromRGB(
            11,
            12,
            16
        )

    card.BorderSizePixel =
        0

    card.Parent =
        gui

    local corner =
        Instance.new(
            "UICorner"
        )

    corner.CornerRadius =
        UDim.new(
            0,
            14
        )

    corner.Parent =
        card

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
        0.45

    stroke.Thickness =
        1

    stroke.Parent =
        card

    local title =
        Instance.new(
            "TextLabel"
        )

    title.BackgroundTransparency =
        1

    title.Position =
        UDim2.fromOffset(
            24,
            20
        )

    title.Size =
        UDim2.new(
            1,
            -48,
            0,
            34
        )

    title.Font =
        Enum.Font.GothamBold

    title.TextSize =
        22

    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.TextColor3 =
        Color3.fromRGB(
            245,
            245,
            247
        )

    title.Text =
        "HOLY Key System"

    title.Parent =
        card

    local subtitle =
        Instance.new(
            "TextLabel"
        )

    subtitle.BackgroundTransparency =
        1

    subtitle.Position =
        UDim2.fromOffset(
            24,
            55
        )

    subtitle.Size =
        UDim2.new(
            1,
            -48,
            0,
            28
        )

    subtitle.Font =
        Enum.Font.GothamMedium

    subtitle.TextSize =
        13

    subtitle.TextXAlignment =
        Enum.TextXAlignment.Left

    subtitle.TextColor3 =
        Color3.fromRGB(
            156,
            163,
            175
        )

    subtitle.Text =
        "Enter your HOLY key to unlock your features."

    subtitle.Parent =
        card

    local input =
        Instance.new(
            "TextBox"
        )

    input.BackgroundColor3 =
        Color3.fromRGB(
            18,
            19,
            25
        )

    input.BorderSizePixel =
        0

    input.Position =
        UDim2.fromOffset(
            24,
            96
        )

    input.Size =
        UDim2.new(
            1,
            -48,
            0,
            42
        )

    input.Font =
        Enum.Font.GothamMedium

    input.TextSize =
        14

    input.PlaceholderText =
        "HOLY-XXXX-XXXX-XXXX..."

    input.Text =
        tostring(savedKey or "")

    input.TextColor3 =
        Color3.fromRGB(
            245,
            245,
            247
        )

    input.PlaceholderColor3 =
        Color3.fromRGB(
            100,
            105,
            115
        )

    input.ClearTextOnFocus =
        false

    input.Parent =
        card

    local inputCorner =
        Instance.new(
            "UICorner"
        )

    inputCorner.CornerRadius =
        UDim.new(
            0,
            9
        )

    inputCorner.Parent =
        input

    local inputPadding =
        Instance.new(
            "UIPadding"
        )

    inputPadding.PaddingLeft =
        UDim.new(
            0,
            12
        )

    inputPadding.PaddingRight =
        UDim.new(
            0,
            12
        )

    inputPadding.Parent =
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
            24,
            154
        )

    verify.Size =
        UDim2.new(
            0.5,
            -30,
            0,
            40
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
        card

    local verifyCorner =
        Instance.new(
            "UICorner"
        )

    verifyCorner.CornerRadius =
        UDim.new(
            0,
            9
        )

    verifyCorner.Parent =
        verify

    local reset =
        Instance.new(
            "TextButton"
        )

    reset.BackgroundColor3 =
        Color3.fromRGB(
            21,
            23,
            33
        )

    reset.BorderSizePixel =
        0

    reset.Position =
        UDim2.new(
            0.5,
            6,
            0,
            154
        )

    reset.Size =
        UDim2.new(
            0.5,
            -30,
            0,
            40
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
        "Reset Saved Key"

    reset.Parent =
        card

    local resetCorner =
        Instance.new(
            "UICorner"
        )

    resetCorner.CornerRadius =
        UDim.new(
            0,
            9
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
            24,
            210
        )

    status.Size =
        UDim2.new(
            1,
            -48,
            0,
            44
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
        savedKey ~= ""
        and "Saved key found. Press Verify Key."
        or "No saved key found."

    status.Parent =
        card

    HolyLoaderTrack(
        verify.MouseButton1Click:Connect(function()

            HolyLoaderVerifyAndLoad(
                input.Text,
                status,
                verify
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

            HolyLoaderSetStatus(
                status,
                "Saved key reset."
            )
        end)
    )

    HolyLoaderTrack(
        input.FocusLost:Connect(function(enterPressed)

            if enterPressed == true then

                HolyLoaderVerifyAndLoad(
                    input.Text,
                    status,
                    verify
                )
            end
        end)
    )

    return gui
end

local savedKey =
    HolyLoaderReadFile(
        HOLY_KEY_FILE
    )

if savedKey ~= "" then

    local fakeStatus =
        nil

    local loaded =
        false

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

        loaded =
            HolyLoaderLoadPremium()
    end

    if loaded ~= true then

        HolyLoaderCreateGui(
            savedKey
        )
    end

else

    HolyLoaderCreateGui(
        ""
    )
end
