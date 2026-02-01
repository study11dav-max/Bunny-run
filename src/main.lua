-- Main Entry Point for Bunny Runner Auto

-- Load Modules
local Detector = require("src.core.detector")
local Panel = require("src.ui.panel")

-- Mock globals for local testing if needed
if not gg then
    print("[MOCK] Initializing Mock Environment")
    _G.gg = {
        toast = print,
        sleep = function(ms) end,
        isVisible = function() return false end,
        choice = function() return 1 end,
        alert = print
    }
end

function main()
    gg.toast("🐰 BunnyBot Pro Loaded")
    
    -- Ensure UI is hidden initially (shows icon)
    gg.setVisible(false)

    while true do
        -- 1. UI Check (User tapped icon?)
        Panel.update()

        -- 2. Core Automation Logic
        -- The Detector handles the isRunning check internally now
        Detector.update()

        -- 3. Throttle
        -- V2 logic requires extremely fast polling (5ms recommended by user).
        -- We will match that.
        gg.sleep(5) 
    end
end

main()
