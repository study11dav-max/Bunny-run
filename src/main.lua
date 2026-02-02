-- TYPO VACCINE: Ensures the script works on all GG versions
if gg then
    if not gg.getscreenSize then gg.getscreenSize = gg.getScreenSize end
    if not gg.getpixel then gg.getpixel = gg.getPixel end
end

-- Add the script's current folder to Lua's search path
local scriptPath = gg.getFile():match("(.*/)")
if scriptPath then
    package.path = package.path .. ";" .. scriptPath .. "?.lua;" .. scriptPath .. "?/init.lua"
end

-- Now you can use simple relative names
local wizard = require("core.wizard")
local dashboard = require("ui.dashboard")
local vision = require("core.vision")
local vision_auto = require("core.vision_auto")
local reset = require("core.reset")
local gestures = require("core.gestures")
local permissions = require("core.permissions")

-- STATE CONSTANTS
local STATE_WAITING = 0
local STATE_LEARNING = 1
local STATE_RUNNING = 2

local current_state = STATE_WAITING
local path_color = nil

-- Default App Icon Location (Top-Left Relaunch Strategy)
local APP_X, APP_Y = 50, 50

-- Configuration State
local config = {
    path_color = nil,
    rx = 0, ry = 0,
    appIconX = APP_X, 
    appIconY = APP_Y,
    ready = false,
    detectionHeight = 65,
    tolerance = 5000,
    refractoryMs = 150,
    autoReset = true,
    rootMode = true
}

-- Load existing config...
local savedConfig = wizard.loadConfig()
if savedConfig then
    for k, v in pairs(savedConfig) do config[k] = v end
end

-- Helper for Fuzzy Matching
local function isColorClose(c1, c2, tolerance)
    local r1, g1, b1 = (c1 >> 16) & 0xFF, (c1 >> 8) & 0xFF, c1 & 0xFF
    local r2, g2, b2 = (c2 >> 16) & 0xFF, (c2 >> 8) & 0xFF, c2 & 0xFF
    return (math.abs(r1-r2) + math.abs(g1-g2) + math.abs(b1-b2)) < (tolerance or 40)
end

-- Native Click Helper
local function click(p)
    gg.gesture({{{x=p.x, y=p.y, t=0}, {x=p.x, y=p.y, t=50}}})
end

-- Heartbeat Logic
local lastChangeTime = os.time()
local lastScreenHash = ""

local function checkStuck()
    local sw, sh = gg.getScreenSize()
    local currentHash = gg.getPixel(sw/2, sh/2)
    
    if currentHash == lastScreenHash then
        if os.time() - lastChangeTime > 12 then -- 12 seconds heartbeat
            gg.toast("⚠️ STUCK DETECTED. Emergency Resetting...")
            performReset()
            lastChangeTime = os.time()
            return true
        end
    else
        lastScreenHash = currentHash
        lastChangeTime = os.time()
    end
    return false
end

-- Startup Diagnostics
local function checkSystem()
    local sw, sh = gg.getScreenSize()
    if sw > sh then
        gg.alert("⚠️ LANDSCAPE DETECTED\nThis script is optimized for PORTRAIT mode. Please rotate your device.")
    end

    if not config.rootMode then
        local success = gg.gesture({{{x=1,y=1,t=0},{x=1,y=1,t=1}}})
        if success == false then
            permissions.requestAccessibility()
            return false
        end
    end
    return true
end

-- Unified Reset Function
local function performReset()
    if config.rootMode then
        reset.restartGame()
    else
        gestures.humanResetApp(config.appIconX, config.appIconY)
    end
    
    -- Clear PATH_COLOR to force dynamic re-learning next level
    path_color = nil
    config.path_color = nil
end

-- Bot Logic (The Zero-Load automated flow)
local function runBotLogic()
    if not checkSystem() then return end
    
    local sw, sh = gg.getScreenSize()
    current_state = STATE_WAITING
    gg.toast("🐰 BunnyBot: Zero-Load Automator ON")
    gg.setVisible(false)
    
    local direction = "RIGHT"
    lastChangeTime = os.time()
    
    while true do
        -- SAFE EXIT: Hold Volume Down / Press Volume Down to Terminate
        if gg.isKeyPressed(gg.KEY_VOLUME_DOWN) then
            gg.toast("🛑 Script Terminated by User")
            gg.setVisible(true)
            os.exit()
        end

        if current_state == STATE_WAITING then
            -- 1. WAIT FOR START (Look for Blue PLAY button)
            local btnPixel = gg.getPixel(sw / 2, sh * 0.82)
            if isColorClose(btnPixel, 0x2196F3, 30) then
                gg.toast("🎮 Ready. Press PLAY to start.")
                gg.sleep(1000)
            else
                -- 2. DYNAMIC LEARNING (Triggered after Play is pressed)
                gg.sleep(1000) -- Wait for level to load
                current_state = STATE_LEARNING
            end

        elseif current_state == STATE_LEARNING then
            path_color = gg.getPixel(sw / 2, sh * 0.7)
            config.path_color = path_color
            current_state = STATE_RUNNING
            gg.toast("✨ Path Learned Automatically! Don't touch.")

        elseif current_state == STATE_RUNNING then
            -- 1. Heartbeat Check
            if checkStuck() then
                direction = "RIGHT"
                current_state = STATE_WAITING
            end

            -- 2. State Detection & ZigZag Logic
            local state = vision.checkState()
            
            if state == "START_SCREEN" then
                -- Backup scanner if PLAY pixel check missed
                gg.toast("🔍 SCANNING: Play Button Detected")
                gg.vibrate(200)
                click({x=sw/2, y=sh*0.82}) 
                gg.sleep(2000)
                
            elseif state == "WIN_SCREEN" or state == "GAME_OVER" or state == "LOSE_SCREEN" then
                -- AD-SKIP TRIGGER (Detection of Win/Loss)
                gg.toast("🏁 Level Ended. Resetting App...")
                if config.autoReset then 
                    performReset() 
                    direction = "RIGHT"
                    current_state = STATE_WAITING
                else 
                    break 
                end
                
            elseif state == "IN_GAME" then
                -- 3. IN-GAME LOGIC (ZigZag)
                local detectionY = sh * (config.detectionHeight / 100)
                local checkX = (direction == "RIGHT") and (sw/2 + 150) or (sw/2 - 150)
                local currentColor = gg.getPixel(checkX, detectionY)

                if not isColorClose(currentColor, config.path_color, 40) then
                    click({x=sw/2, y=sh/2})
                    direction = (direction == "RIGHT") and "LEFT" or "RIGHT"
                    gg.sleep(config.refractoryMs)
                end
            end
        end
        gg.sleep(10)
    end
end

-- Main Loop (Dashboard)
while true do
    if gg.isVisible() then
        local choice = dashboard.showDashboard(config)
        
        if choice == 1 then
            runBotLogic()
            
        elseif choice == 2 then
            config.path_color = wizard.passivePathGatherer()
            wizard.saveConfig(config.path_color, config.rx, config.ry, config)
            
        elseif choice == 4 then
            config.rootMode = not config.rootMode
            gg.toast("Mode: " .. (config.rootMode and "ROOT (Shell)" or "HUMAN (Gesture)"))
            wizard.saveConfig(config.path_color, config.rx, config.ry, config)
            
        elseif choice == 5 then
            gg.alert("🏠 NO-ROOT RELAUNCH:\nEnsure the Bunny Runner icon is in the TOP-LEFT corner of your Home Screen for auto-mode.\n\nOr enter manual coordinates below.")
            local result = gg.prompt({"Icon X", "Icon Y"}, {config.appIconX or 50, config.appIconY or 50}, {"number", "number"})
            if result then
                config.appIconX, config.appIconY = tonumber(result[1]), tonumber(result[2])
                gg.toast("✅ Icon Position Saved!")
                wizard.saveConfig(nil, nil, nil, config)
            end
            
        elseif choice == 6 then
            config.autoReset = not config.autoReset
            wizard.saveConfig(config.path_color, config.rx, config.ry, config)
            
        elseif choice == 7 then
            dashboard.showTutorial()
            
        elseif choice == 8 then
            config = dashboard.showAdvancedSettings(config)
            wizard.saveConfig(config.path_color, config.rx, config.ry, config)
            
        elseif choice == 9 then
            os.exit()
        end
        
        gg.setVisible(false)
    end
    gg.sleep(100)
end
