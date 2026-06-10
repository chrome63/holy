--==================================================
-- HOLY FRESH LOADER
-- Obfuscate this file, not the full core.
--==================================================

local Root =
    type(getgenv) == "function"
    and getgenv()
    or _G

Root.HOLY_FRESH_AUTHORIZED =
    true

Root.HOLY_FRESH_SALT =
    tostring(os.clock())
    .. "_"
    .. tostring(math.random(100000, 999999))

local Repo =
    "https://raw.githubusercontent.com/bencapalot041/goons/main/"

local CacheBust =
    "?v="
    .. tostring(os.time())
    .. "_"
    .. tostring(math.random(100000, 999999))

Root.HOLY_FRESH_OBSIDIAN_URL =
    Repo .. "librarylite.lua" .. CacheBust

Root.HOLY_FRESH_THEME_MANAGER_URL =
    Repo .. "addons/ThemeManager.lua" .. CacheBust

Root.HOLY_FRESH_SAVE_MANAGER_URL =
    Repo .. "addons/SaveManager.lua" .. CacheBust

local CoreUrl =
    Repo .. "HolyFreshCore.lua" .. CacheBust

local okSource, source =
    pcall(function()
        return game:HttpGet(CoreUrl)
    end)

if okSource ~= true
or type(source) ~= "string"
or source == "" then
    warn("[HOLY FRESH LOADER] Failed to fetch core.")
    return
end

local chunk, compileErr =
    loadstring(source)

if type(chunk) ~= "function" then
    warn("[HOLY FRESH LOADER] Core compile failed:", tostring(compileErr))
    return
end

local okRun, runErr =
    pcall(chunk)

if okRun ~= true then
    warn("[HOLY FRESH LOADER] Core runtime failed:", tostring(runErr))
end
