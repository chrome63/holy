-- Holy Loader Debug

local MAIN_URL =
    "https://raw.githubusercontent.com/bencapalot041/holy/main/HolyV3.lua?v="
    .. tostring(os.time())

print("[HOLY LOADER] Fetching:", MAIN_URL)

local ok, source =
    pcall(function()
        return game:HttpGet(MAIN_URL, true)
    end)

if not ok then
    error("[HOLY LOADER] HttpGet failed: " .. tostring(source))
end

if type(source) ~= "string" then
    error("[HOLY LOADER] Source is not string: " .. typeof(source))
end

print("[HOLY LOADER] Loaded bytes:", #source)
print("[HOLY LOADER] First 80 chars:", string.sub(source, 1, 80))

local fn, compileErr =
    loadstring(source)

if not fn then
    error("[HOLY LOADER] Compile failed: " .. tostring(compileErr))
end

print("[HOLY LOADER] Compile OK, running...")

local okRun, runtimeErr =
    xpcall(fn, function(err)
        return tostring(err) .. "\n" .. debug.traceback()
    end)

if not okRun then
    error("[HOLY LOADER] Runtime failed:\n" .. tostring(runtimeErr))
end

print("[HOLY LOADER] Runtime OK")
