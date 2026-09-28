-- Gaze Lockscreen Face Badge Widget for Noctalia Shell
-- Displays a Windows Hello-style animated biometric indicator on the lock screen surface.

local noctalia = require("noctalia")
local desktopWidget = require("desktopWidget")
local ui = require("ui")

desktopWidget.render(function()
    local status = noctalia.state.get("status") or "idle"
    local lastMsg = noctalia.state.get("last_message") or "Looking for you..."

    local icon = "󰈈"
    local iconColor = "#89b4fa"
    local promptText = "Looking for you..."

    if status == "scanning" then
        icon = "󰈈"
        iconColor = "#89b4fa"
        promptText = "Making sure it's you..."
    elseif status == "verified" then
        icon = "󰄬"
        iconColor = "#a6e3a1"
        promptText = "Welcome back!"
    elseif status == "failed" then
        icon = "󰅚"
        iconColor = "#f38ba8"
        promptText = "Face not recognized. Tap or swipe to enter password."
    elseif status == "offline" then
        icon = "󰈉"
        iconColor = "#6c7086"
        promptText = "Biometric unlock unavailable."
    else
        icon = "󰈈"
        iconColor = "#cdd6f4"
        promptText = "Gaze Face Unlock Ready"
    end

    return ui.box({
        padding = 16,
        spacing = 8,
        alignment = "center",
        children = {
            ui.glyph({
                icon = icon,
                size = 36,
                color = iconColor
            }),
            ui.text({
                text = promptText,
                size = 14,
                font_weight = "medium",
                color = iconColor
            })
        }
    })
end)
