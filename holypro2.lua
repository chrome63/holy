--==================================================
-- HOLY SHUTDOWN
--==================================================

local Players =
    game:GetService("Players")

local LocalPlayer =
    Players.LocalPlayer
    or Players.PlayerAdded:Wait()

pcall(function()
    if type(getgenv) == "function" then
        getgenv().HOLY_AUTH =
            nil

        getgenv().HOLY_SCRIPT_SHUTDOWN =
            true
    end

    _G.HOLY_AUTH =
        nil

    _G.HOLY_SCRIPT_SHUTDOWN =
        true
end)

pcall(function()
    if type(HolyNotify) == "function" then
        HolyNotify(
            "HOLY",
            "This old loadstring has been shut down. Use the new official loader.",
            8
        )
    end
end)

pcall(function()
    game:GetService("StarterGui"):SetCore(
        "SendNotification",
        {
            Title =
                "HOLY",

            Text =
                "This old loadstring has been shut down. Use the new official loader.",

            Duration =
                8,
        }
    )
end)

warn(
    "[HOLY]",
    "This old loadstring has been shut down. Use the new official loader."
)

return
