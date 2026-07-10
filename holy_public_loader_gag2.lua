--==================================================
-- HOLY PUBLIC LOADER
--==================================================

local Players =
    game:GetService("Players")

local LocalPlayer =
    Players.LocalPlayer
    or Players.PlayerAdded:Wait()

local ALLOWED_PLACE_IDS = {
    [97598239454123] =
        true,
}

if ALLOWED_PLACE_IDS[game.PlaceId] ~= true then

    error(
        "[HOLY] This loader cannot run in this experience.",
        0
    )
end

local PUBLIC_API =
    "https://holy-dev-api.benjicapalot041.workers.dev"

local PUBLIC_PRODUCT =
    "sniper"

local function HolyPublicInstallAuth()

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
            false,

        admin =
            false,
    }

    local auth = {
        ok =
            true,

        Valid =
            true,

        Dev =
            false,

        Public =
            true,

        Product =
            PUBLIC_PRODUCT,

        Plan =
            "finder",

        KeyPrefix =
            "HOLY-PUBLIC",

        SessionId =
            "public_"
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

    local environment =
        type(getgenv) == "function"
        and getgenv()
        or _G

    if type(environment) == "table" then

        environment.HOLY_AUTH =
            auth

        environment.HOLY_DEV_MODE =
            false

        environment.HOLY_PUBLIC_MODE =
            true

        environment.HOLY_DEV_PRODUCT =
            nil

        environment.HOLY_PUBLIC_PRODUCT =
            PUBLIC_PRODUCT
    end

    _G.HOLY_AUTH =
        auth

    _G.HOLY_DEV_MODE =
        false

    _G.HOLY_PUBLIC_MODE =
        true

    _G.HOLY_DEV_PRODUCT =
        nil

    _G.HOLY_PUBLIC_PRODUCT =
        PUBLIC_PRODUCT

    return auth
end

local function HolyPublicGetRequestFunction()

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

    local environment =
        type(getgenv) == "function"
        and getgenv()
        or _G

    if type(environment) == "table" then

        if type(environment.request) == "function" then

            return environment.request
        end

        if type(environment.http_request) == "function" then

            return environment.http_request
        end
    end

    return nil
end

local function HolyPublicDownload(url)

    local success,
        result =
        pcall(function()

            return game:HttpGet(
                url,
                true
            )
        end)

    if success == true
    and type(result) == "string"
    and result ~= "" then

        return result,
            nil
    end

    local requestFunction =
        HolyPublicGetRequestFunction()

    if type(requestFunction) ~= "function" then

        return nil,
            tostring(result)
    end

    local requestSuccess,
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

    if requestSuccess ~= true then

        return nil,
            tostring(response)
    end

    local body =
        type(response) == "string"
        and response
        or type(response) == "table"
        and (
            response.Body
            or response.body
            or response.ResponseBody
            or response.responseBody
        )
        or nil

    if type(body) ~= "string"
    or body == "" then

        return nil,
            "empty response"
    end

    return body,
        nil
end

local function HolyPublicCompile(source)

    local compiler =
        loadstring
        or load

    if type(compiler) ~= "function" then

        error(
            "[HOLY] loadstring/load is unavailable.",
            0
        )
    end

    local success,
        chunkOrError =
        pcall(
            compiler,
            source
        )

    if success ~= true
    or type(chunkOrError) ~= "function" then

        error(
            "[HOLY] Compile failed: "
            .. tostring(chunkOrError),
            0
        )
    end

    return chunkOrError
end

local function HolyPublicRun()

    HolyPublicInstallAuth()

    local cacheBreaker =
        tostring(os.time())
        .. "_"
        .. tostring(
            math.floor(
                os.clock()
                * 100000
            )
        )

    local url =
        PUBLIC_API
        .. "/public-source?product="
        .. PUBLIC_PRODUCT
        .. "&cache="
        .. cacheBreaker

    print(
        "[HOLY]",
        "Loading public product:",
        PUBLIC_PRODUCT
    )

    local source,
        downloadError =
        HolyPublicDownload(
            url
        )

    if type(source) ~= "string"
    or source == "" then

        error(
            "[HOLY] Download failed: "
            .. tostring(downloadError),
            0
        )
    end

    if source:sub(1, 3) == "\239\187\191" then

        source =
            source:sub(4)
    end

    local preview =
        source:sub(
            1,
            300
        ):lower()

    if preview:find(
        "<!doctype html",
        1,
        true
    )
    or preview:find(
        "<html",
        1,
        true
    ) then

        error(
            "[HOLY] The API returned HTML instead of Lua.",
            0
        )
    end

    if preview:find(
        "\"public_source_disabled\"",
        1,
        true
    )
    or preview:find(
        "\"error\"",
        1,
        true
    ) then

        error(
            "[HOLY] Public source is unavailable: "
            .. source:sub(
                1,
                300
            ),
            0
        )
    end

    local chunk =
        HolyPublicCompile(
            source
        )

    local runSuccess,
        runError =
        pcall(
            chunk
        )

    if runSuccess ~= true then

        error(
            "[HOLY] Run failed: "
            .. tostring(runError),
            0
        )
    end

    return true
end

HolyPublicRun()
