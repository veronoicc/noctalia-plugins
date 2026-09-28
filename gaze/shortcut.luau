-- Gaze Quick Settings / Control Center Shortcut for Noctalia Shell
-- Provides a quick tile in the Noctalia Control Center to trigger instant biometric auth.

local noctalia = require("noctalia")
local shortcut = require("shortcut")

local function updateShortcut()
    local status = noctalia.state.get("status") or "idle"
    local active = (status == "scanning" or status == "verified")

    if shortcut.setGlyph then
        shortcut.setGlyph("󰈈")
    end

    if shortcut.setLabel then
        if status == "scanning" then
            shortcut.setLabel("Scanning...")
        elseif status == "verified" then
            shortcut.setLabel("Unlocked")
        elseif status == "failed" then
            shortcut.setLabel("Auth Failed")
        else
            shortcut.setLabel("Face Auth")
        end
    end

    if shortcut.setActive then
        shortcut.setActive(active)
    end
end

shortcut.onClick(function()
    noctalia.ipc.call("veronoicc/gaze:gaze_service", "auth")
end)

noctalia.state.watch("status", function()
    updateShortcut()
end)

updateShortcut()
