--==================================================
-- HOLY PRO UNIVERSAL BOOTSTRAP
--==================================================

local MAIN_URL =
    "https://raw.githubusercontent.com/bencapalot041/holy/main/holypro2_main.lua?v=20260626_1"

local END_MARKER =
    "HOLY_PREMIUM_END"

local function holy_clean_text(value)

    return tostring(value or "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

local function holy_error(message)

    error(
        "[HOLY] "
        .. tostring(message or "Unknown loader error."),
        0
    )
end

local function holy_get_request_function()

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

local function holy_validate_source(source)

    if type(source) ~= "string"
    or source == "" then

        return nil,
            "empty response"
    end

    if source:sub(1, 3) == "\239\187\191" then

        source =
            source:sub(4)
    end

    local preview =
        source:sub(1, 400):lower()

    if preview:find("<!doctype", 1, true)
    or preview:find("<html", 1, true)
    or preview:find("rate limit", 1, true)
    or preview:find("not found", 1, true) then

        return nil,
            "download returned HTML/error page"
    end

    if source:find("\0", 1, true) then

        return nil,
            "download contains binary/null bytes"
    end

    if not source:find(END_MARKER, 1, true) then

        return nil,
            "script download incomplete, missing end marker"
    end

    return source,
        nil
end

local function holy_download_with_request(url)

    local request_function =
        holy_get_request_function()

    if type(request_function) ~= "function" then

        return nil,
            "request unsupported"
    end

    local ok,
        response =
        pcall(function()

            return request_function({
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

    if ok ~= true then

        return nil,
            "request failed: "
            .. tostring(response)
    end

    if type(response) == "string" then

        return response,
            nil
    end

    if type(response) == "table" then

        local status =
            tonumber(
                response.StatusCode
                or response.Status
                or response.statusCode
                or response.status
            )
            or 200

        local body =
            response.Body
            or response.body
            or response.ResponseBody
            or response.responseBody
            or ""

        if status < 200
        or status >= 300 then

            return nil,
                "request http "
                .. tostring(status)
                .. ": "
                .. tostring(body):sub(1, 120)
        end

        return body,
            nil
    end

    return nil,
        "bad request response"
end

local function holy_download_with_httpget(url)

    if not game
    or type(game.HttpGet) ~= "function" then

        return nil,
            "HttpGet unsupported"
    end

    local ok,
        result =
        pcall(function()

            return game:HttpGet(
                url,
                true
            )
        end)

    if ok ~= true then

        return nil,
            "HttpGet failed: "
            .. tostring(result)
    end

    return result,
        nil
end

local function holy_download_source(url)

    local failures =
        {}

    local source,
        reason =
        holy_download_with_request(
            url
        )

    source,
        reason =
        holy_validate_source(
            source
        )

    if source then

        return source,
            nil
    end

    table.insert(
        failures,
        "request: "
        .. tostring(reason)
    )

    source,
        reason =
        holy_download_with_httpget(
            url
        )

    source,
        reason =
        holy_validate_source(
            source
        )

    if source then

        return source,
            nil
    end

    table.insert(
        failures,
        "HttpGet: "
        .. tostring(reason)
    )

    return nil,
        table.concat(
            failures,
            " | "
        )
end

local function holy_get_compiler()

    if type(loadstring) == "function" then
        return loadstring
    end

    if type(load) == "function" then
        return load
    end

    local env =
        type(getgenv) == "function"
        and getgenv()
        or _G

    if type(env) == "table" then

        if type(env.loadstring) == "function" then
            return env.loadstring
        end

        if type(env.load) == "function" then
            return env.load
        end
    end

    return nil
end

local source,
    download_error =
    holy_download_source(
        MAIN_URL
    )

if type(source) ~= "string"
or source == "" then

    holy_error(
        "Failed to download Premium: "
        .. tostring(download_error)
    )
end

local compiler =
    holy_get_compiler()

if type(compiler) ~= "function" then

    holy_error(
        "Executor does not support loadstring/load."
    )
end

local compile_ok,
    chunk,
    compile_error =
    pcall(
        compiler,
        source
    )

if compile_ok ~= true
or type(chunk) ~= "function" then

    holy_error(
        "Premium compile failed: "
        .. tostring(compile_error or chunk)
    )
end

local run_ok,
    run_error =
    pcall(
        chunk
    )

if run_ok ~= true then

    holy_error(
        "Premium runtime failed: "
        .. tostring(run_error)
    )
end
