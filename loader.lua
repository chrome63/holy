-- Holy Loader

local URLS = {
    "https://raw.githubusercontent.com/bencapalot041/holy/main/HolyV3.lua?v=" .. tostring(os.time()),
}

local lastError =
    nil

for _, url in ipairs(URLS) do

    local ok, source =
        pcall(function()
            return game:HttpGet(url, true)
        end)

    if ok
    and type(source) == "string"
    and #source > 100 then

        local fn, compileErr =
            loadstring(source)

        if fn then

            local okRun, runtimeErr =
                pcall(fn)

            if okRun then
                return
            end

            lastError =
                runtimeErr
        else
            lastError =
                compileErr
        end
    else
        lastError =
            source
    end
end

error("[HOLY] Loader failed: " .. tostring(lastError))
