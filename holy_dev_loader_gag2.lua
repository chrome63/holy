--==================================================
-- HOLY DEV LOADER
--==================================================

local Players =
    game:GetService("Players")

local HttpService =
    game:GetService("HttpService")

local LocalPlayer =
    Players.LocalPlayer
    or Players.PlayerAdded:Wait()

local ALLOWED_DEV_USER_IDS = {
    [78428093] =
        true,
    
    [8668060320] =
        true,

    [8842726746] =
        true,

    [9317135728] =
        true,

    [8842696762] =
        true,
    
    
}

if ALLOWED_DEV_USER_IDS[LocalPlayer.UserId] ~= true then

    error(
        "[HOLY DEV] You are not allowed to use this dev loader.",
        0
    )
end

-- Change this to "pro" when testing Pro.
-- Keep "sniper" when testing Server Sniper.
local DEV_PRODUCT =
    "sniper"

local HOLY_DEV_API =
    "https://holy-dev-api.benjicapalot041.workers.dev"

local DEV_KEY =
    (
        type(getgenv) == "function"
        and getgenv().HOLY_DEV_KEY
    )
    or _G.HOLY_DEV_KEY
    or ""

local function HolyDevClean(value)

    return tostring(value or "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

local function HolyDevGetSourceUrl()

    if DEV_KEY == "" then

        error(
            "[HOLY DEV] Missing dev key. Run getgenv().HOLY_DEV_KEY first.",
            0
        )
    end

    local cacheBreaker =
        tostring(os.time())
        .. "_"
        .. tostring(math.floor(os.clock() * 100000))

    return HOLY_DEV_API
        .. "/source?product="
        .. tostring(DEV_PRODUCT)
        .. "&key="
        .. tostring(DEV_KEY)
        .. "&dev="
        .. cacheBreaker
end

local function HolyDevGetRequestFunction()

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

local function HolyDevHttpGet(url)

    local ok,
        result =
        pcall(function()

            return game:HttpGet(
                url,
                true
            )
        end)

    if ok == true
    and type(result) == "string"
    and result ~= "" then

        return result,
            nil
    end

    local requestFunction =
        HolyDevGetRequestFunction()

    if type(requestFunction) == "function" then

        local requestOk,
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

                        ["Accept-Encoding"] =
                            "identity",

                        ["Cache-Control"] =
                            "no-cache",
                    },
                })
            end)

        if requestOk == true then

            local body =
                nil

            if type(response) == "string" then

                body =
                    response

            elseif type(response) == "table" then

                body =
                    response.Body
                    or response.body
                    or response.ResponseBody
                    or response.responseBody
            end

            if type(body) == "string"
            and body ~= "" then

                return body,
                    nil
            end
        end

        return nil,
            tostring(response)
    end

    return nil,
        tostring(result)
end

local function HolyDevInstallAuth()

    local features = {
        basic =
            true,

        server_finder =
            true,

        pet_sniper =
            true,

        pet_sniper_autobuy =
            true,

        dev_tools =
            true,

        admin =
            true,
    }

    local auth = {
        ok =
            true,

        Valid =
            true,

        Dev =
            true,

        Product =
            DEV_PRODUCT,

        Plan =
            DEV_PRODUCT == "sniper"
            and "finder"
            or "owner",

        KeyPrefix =
            "HOLY-DEV",

        SessionId =
            "dev_"
            .. tostring(LocalPlayer.UserId)
            .. "_"
            .. tostring(os.time()),

        RobloxUserId =
            LocalPlayer.UserId,

        RobloxUsername =
            LocalPlayer.Name,

        Features =
            features,

        features =
            features,
    }

    if type(getgenv) == "function" then

        getgenv().HOLY_AUTH =
            auth

        getgenv().HOLY_DEV_MODE =
            true

        getgenv().HOLY_DEV_PRODUCT =
            DEV_PRODUCT
    end

    _G.HOLY_AUTH =
        auth

    _G.HOLY_DEV_MODE =
        true

    _G.HOLY_DEV_PRODUCT =
        DEV_PRODUCT

    return auth
end

local function HolyDevCompile(source, name)

    local compiler =
        loadstring
        or load

    if type(compiler) ~= "function" then

        error(
            "[HOLY DEV] loadstring/load missing.",
            0
        )
    end

    local ok,
        chunkOrError =
        pcall(
            compiler,
            source
        )

    if ok ~= true
    or type(chunkOrError) ~= "function" then

        error(
            "[HOLY DEV] Compile failed for "
            .. tostring(name or "dev source")
            .. ": "
            .. tostring(chunkOrError),
            0
        )
    end

    return chunkOrError
end

local function HolyDevRun()

    local auth =
        HolyDevInstallAuth()

    print(
        "[HOLY DEV]",
        "Dev auth installed.",
        "Product:",
        DEV_PRODUCT,
        "User:",
        tostring(LocalPlayer.Name)
    )

    local url =
        HolyDevGetSourceUrl()

    print(
        "[HOLY DEV]",
        "Loading:",
        url
    )

    local source,
        downloadError =
        HolyDevHttpGet(
            url
        )

    if type(source) ~= "string"
    or source == "" then

        error(
            "[HOLY DEV] Download failed: "
            .. tostring(downloadError),
            0
        )
    end

    if source:sub(1, 3) == "\239\187\191" then

        source =
            source:sub(4)
    end

    local preview =
        source:sub(1, 220):lower()

    if preview:find("<!doctype html", 1, true)
    or preview:find("<html", 1, true) then

        error(
            "[HOLY DEV] Source returned HTML instead of Lua.",
            0
        )
    end

    local chunk =
        HolyDevCompile(
            source,
            url
        )

    local runOk,
        runError =
        pcall(
            chunk
        )

    if runOk ~= true then

        error(
            "[HOLY DEV] Run failed: "
            .. tostring(runError),
            0
        )
    end

    return true
end

HolyDevRun()
