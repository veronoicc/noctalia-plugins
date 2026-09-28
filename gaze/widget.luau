-- Gaze Status Bar Widget for Noctalia Shell
-- Displays real-time IR facial authentication status and provides click-to-authenticate.

local noctalia = require("noctalia")
local barWidget = require("barWidget")
local ui = require("ui")

local currentStatus = noctalia.state.get("status") or "idle"
local lastMessage = noctalia.state.get("last_message") or "Ready"

-- Icons and colors for each authentication state
local STATES = {
    idle = {
        glyph = "󰈈",
        color = "#a6e3a1",
        label = "Gaze",
        tooltip = "Gaze Face Auth: Ready (Click to authenticate)"
    },
    scanning = {
        glyph = "󰈈",
        color = "#89b4fa",
        label = "Scanning...",
        tooltip = "Surface IR Camera active: Looking for face..."
    },
    verified = {
        glyph = "󰄬",
        color = "#a6e3a1",
        label = "Verified",
        tooltip = "Face recognized successfully!"
    },
    failed = {
        glyph = "󰅚",
        color = "#f38ba8",
        label = "Retry",
        tooltip = "Authentication failed (Click to retry)"
    },
    offline = {
        glyph = "󰈉",
        color = "#6c7086",
        label = "Gaze Off",
        tooltip = "gazed service is inactive"
    }
}

-- Render declarative bar widget layout
local function updateUi()
    local state = STATES[currentStatus] or STATES.idle
    
    if barWidget and barWidget.render then
        barWidget.render(function()
            return ui.button({
                onClick = function()
                    noctalia.ipc.call("veronoicc/gaze:gaze_service", "auth")
                end,
                child = ui.hbox({
                    spacing = 6,
                    children = {
                        ui.glyph({
                            icon = state.glyph,
                            color = state.color
                        }),
                        ui.text({
                            text = state.label,
                            color = state.color
                        })
                    }
                })
            })
        end)
    else
        -- Fallback to imperative widget methods if render is unavailable
        if barWidget.setGlyph then barWidget.setGlyph(state.glyph) end
        if barWidget.setText then barWidget.setText(state.label) end
        if barWidget.setTooltip then barWidget.setTooltip(state.tooltip) end
    end
end

-- Watch state changes from background service
noctalia.state.watch("status", function(newStatus)
    currentStatus = newStatus or "idle"
    updateUi()
end)

noctalia.state.watch("last_message", function(newMsg)
    lastMessage = newMsg or ""
    updateUi()
end)

-- Click action
if barWidget.onClick then
    barWidget.onClick(function()
        noctalia.ipc.call("veronoicc/gaze:gaze_service", "auth")
    end)
end

updateUi()
