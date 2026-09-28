-- Gaze Background Daemon Service for Noctalia Shell
-- Manages biometric authentication state, daemon monitoring, and camera triggers.

local noctalia = require("noctalia")

-- Initial state
noctalia.state.set("status", "idle") -- "idle" | "scanning" | "verified" | "failed" | "offline"
noctalia.state.set("daemon_active", false)
noctalia.state.set("device", "/dev/surface-ir-camera")
noctalia.state.set("last_message", "Gaze initialized")

-- Check if gazed daemon is active
local function checkDaemon()
    noctalia.runAsync({"systemctl", "--user", "is-active", "gazed"}, function(res)
        local isActive = res and res.stdout and res.stdout:match("active") ~= nil
        if not isActive then
            -- Fallback check via pgrep
            noctalia.runAsync({"pgrep", "-x", "gazed"}, function(pres)
                local running = pres and pres.exit_code == 0
                noctalia.state.set("daemon_active", running)
                if not running and noctalia.state.get("status") ~= "scanning" then
                    noctalia.state.set("status", "offline")
                    noctalia.state.set("last_message", "gazed daemon not running")
                end
            end)
        else
            noctalia.state.set("daemon_active", true)
            if noctalia.state.get("status") == "offline" then
                noctalia.state.set("status", "idle")
                noctalia.state.set("last_message", "Ready")
            end
        end
    end)
end

-- Trigger facial authentication via Gaze CLI
local function triggerAuth()
    local currentStatus = noctalia.state.get("status")
    if currentStatus == "scanning" then
        return
    end

    noctalia.state.set("status", "scanning")
    noctalia.state.set("last_message", "Scanning face via IR camera...")

    -- Invoke gaze auth
    noctalia.runAsync({"gaze", "auth"}, function(res)
        if res and res.exit_code == 0 then
            noctalia.state.set("status", "verified")
            noctalia.state.set("last_message", "Face recognized! Unlocked.")
            -- Revert back to idle after 2.5 seconds
            task.delay(2.5, function()
                if noctalia.state.get("status") == "verified" then
                    noctalia.state.set("status", "idle")
                    noctalia.state.set("last_message", "Ready")
                end
            end)
        else
            noctalia.state.set("status", "failed")
            local err = (res and res.stderr and #res.stderr > 0) and res.stderr or "Face not recognized"
            noctalia.state.set("last_message", err)
            task.delay(3.0, function()
                if noctalia.state.get("status") == "failed" then
                    noctalia.state.set("status", "idle")
                    noctalia.state.set("last_message", "Ready")
                end
            end)
        end
    end)
end

-- Enroll new face template (opens terminal prompt)
local function triggerEnroll()
    noctalia.runInTerminal("gaze add-face default")
end

-- Register IPC command handlers
noctalia.ipc.handle("auth", function()
    triggerAuth()
end)

noctalia.ipc.handle("status", function()
    checkDaemon()
end)

noctalia.ipc.handle("enroll", function()
    triggerEnroll()
end)

-- Initial check and periodic polling every 5s
checkDaemon()

while true do
    task.wait(5)
    checkDaemon()
end
