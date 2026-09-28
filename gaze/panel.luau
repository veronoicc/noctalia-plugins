-- Gaze Control Panel for Noctalia Shell
-- Interactive overlay showing biometric device info, enrolled templates, and quick actions.

local noctalia = require("noctalia")
local panel = require("panel")
local ui = require("ui")

panel.render(function()
    local status = noctalia.state.get("status") or "idle"
    local daemonActive = noctalia.state.get("daemon_active") or false
    local device = noctalia.state.get("device") or "/dev/surface-ir-camera"
    local lastMsg = noctalia.state.get("last_message") or "Ready"

    local statusColor = "#a6e3a1"
    if status == "scanning" then
        statusColor = "#89b4fa"
    elseif status == "failed" or status == "offline" then
        statusColor = "#f38ba8"
    end

    return ui.box({
        padding = 16,
        spacing = 14,
        children = {
            -- Header
            ui.hbox({
                spacing = 10,
                children = {
                    ui.glyph({ icon = "󰈈", size = 24, color = statusColor }),
                    ui.vbox({
                        children = {
                            ui.text({ text = "Gaze Face Authentication", font_weight = "bold", size = 16 }),
                            ui.text({ text = "Surface Pro 8 IR Biometrics", color = "#6c7086", size = 12 })
                        }
                    })
                }
            }),

            -- Status card
            ui.box({
                padding = 12,
                background = "#1e1e2e",
                border_radius = 8,
                spacing = 8,
                children = {
                    ui.hbox({
                        children = {
                            ui.text({ text = "Daemon: ", color = "#a6adc8" }),
                            ui.text({ text = daemonActive and "Running (gazed)" or "Inactive", color = daemonActive and "#a6e3a1" or "#f38ba8" })
                        }
                    }),
                    ui.hbox({
                        children = {
                            ui.text({ text = "Device: ", color = "#a6adc8" }),
                            ui.text({ text = device, color = "#cdd6f4" })
                        }
                    }),
                    ui.hbox({
                        children = {
                            ui.text({ text = "Status: ", color = "#a6adc8" }),
                            ui.text({ text = lastMsg, color = statusColor })
                        }
                    })
                }
            }),

            -- Action buttons
            ui.vbox({
                spacing = 8,
                children = {
                    ui.button({
                        label = (status == "scanning") and "Authenticating..." or "󰈈  Test Facial Unlock",
                        onClick = function()
                            noctalia.ipc.call("veronoicc/gaze:gaze_service", "auth")
                        end
                    }),
                    ui.button({
                        label = "󰌆  Enroll New Face (gaze add-face)",
                        onClick = function()
                            noctalia.ipc.call("veronoicc/gaze:gaze_service", "enroll")
                        end
                    }),
                    ui.button({
                        label = "󰌾  Lock Session Now",
                        onClick = function()
                            noctalia.runAsync({"loginctl", "lock-session"})
                        end
                    })
                }
            })
        }
    })
end)
