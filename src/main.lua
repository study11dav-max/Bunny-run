-- Main Entry Point for Bunny Runner Auto

-- Load Modules
local Detector = require("src.core.detector")
local Input = require("src.core.input")
local Panel = require("src.ui.panel")

-- Mock global objects if not present (for testing outside GG)
-- These should obviously be removed or guarded in production
if not gg then
    _G.gg = {
        choice = function(items) 
            print("MOCK UI: Select option (1-"..#items..")")
            for i,v in ipairs(items) do print(i..": "..v) end
            return 1 -- Default to Start for test
        end,
        toast = function(msg) print("[TOAST]: "..msg) end,
        prompt = function(p) return {1.0} end,
        isVisible = function() return false end,
        setVisible = function() end,
        sleep = function(ms) end
    }
end
if not os.sleep then os.sleep = function() end end

-- Main Execution Loop
function main()
    gg.toast("Bunny Runner Auto Loaded")
    
    while true do
        -- 1. Handle UI
        Panel.update()

        -- 2. Run Logic if Active
        if Panel.isRunning then
            -- Define critical coordinates (need calibration)
            local checkX = 500
            local checkY = 1000

            -- Check boundary
            if Detector.checkBoundary(checkX, checkY) then
                print("Boundary Detected! Tapping...")
                Input.tap(checkX, checkY)
                -- Add cooldown to prevent double taps
                os.sleep(100) 
            end
        end

        -- 3. Loop throttling
        os.sleep(16) -- ~60 FPS
    end
end

-- Run
-- Use pcall to catch errors and safely exit
local status, err = pcall(main)
if not status then
    print("CRASH: " .. tostring(err))
    Input.panicStop()
end
