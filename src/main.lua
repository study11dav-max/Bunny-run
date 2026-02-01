-- Main Entry Point for Bunny Runner Auto

-- Load Modules
local Detector = require("src.core.detector")
local Panel = require("src.ui.panel")
local Recovery = require("src.core.recovery")
local Wizard = require("src.core.wizard")

-- Mock globals for local testing if needed
if not gg then
    print("[MOCK] Initializing Mock Environment")
    _G.gg = {
        toast = print,
        sleep = function(ms) end,
        isVisible = function() return false end,
        choice = function() return 1 end,
        alert = print,
        EXT_STORAGE = "."
    }
end

function main()
    -- 1. Check Setup
    if not Wizard.loadConfig() then
        Wizard.runWizard()
    end
    
    -- 2. Apply Settings
    Detector.config.safeColor = Wizard.config.path_color
    Recovery.RESTART_X = Wizard.config.restart_x
    Recovery.RESTART_Y = Wizard.config.restart_y
    Recovery.RESTART_BTN_COLOR = 0xFFCC00 -- Might need to learn this too in Wizard?
    -- Wizard currently only learns Pos, not color for restart. 
    -- Assuming static or add color learn to wizard if strictly needed.
    
    gg.toast("🐰 BunnyBot Pro Loaded")
    
    -- Ensure UI is hidden initially (shows icon)
    gg.setVisible(false)

    while true do
        -- 1. UI Check (User tapped icon?)
        Panel.update()

        -- 2. Core Automation Logic
        -- The Detector handles the isRunning check internally now
        Detector.update()
        
        -- Check Game Over (Lazarus)
        if Panel.isRunning and Recovery.checkGameOver() then
             startAutomation() 
             gg.sleep(1000)
        end

        -- 3. Throttle
        -- V2 logic requires extremely fast polling (5ms recommended by user).
        -- We will match that.
        gg.sleep(5) 
    end
end

main()
