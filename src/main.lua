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

-- Mock GG for testing
if not gg then
    _G.gg = {
        getScreenSize = function() return 1080, 2400 end,
        getPixel = function() return 0xFFFFFF end,
        toast = print,
        sleep = function() end,
        click = function(t) print("Click", t.x, t.y) end,
        gesture = function() print("Gesture performed"); return true end,
        isKeyPressed = function() return false end,
        setVisible = function() end,
        isVisible = function() return false end,
        choice = function() return 1 end,
        alert = print,
        EXT_STORAGE = "."
    }
end

-- UI Anchor Cache
local UI_LOCS = {}

-- Configuration State
local config = {
    path_color = nil,
    rx = 0, ry = 0,
    appIconX = 0, appIconY = 0,
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
else
    -- FIRST RUN: Auto-trigger Wizard
    config = wizard.runFullCalibration(config)
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

-- Unified Reset Function (Ghost Tap included)
local function performReset()
    if config.rootMode then
        reset.restartGame()
    else
        gestures.humanResetApp(config.appIconX, config.appIconY)
    end
    
    -- GHOST TAP: Tap center until Path Color is detected (handles popups)
    if config.path_color then
        gg.toast("👻 GHOST TAP: Navigating through pop-ups...")
        local sw, sh = gg.getScreenSize()
        local startTime = os.time()
        
        while os.time() - startTime < 10 do -- Max 10s ghost tapping
            local detectionY = sh * (config.detectionHeight / 100)
            local currentColor = gg.getPixel(sw/2, detectionY)
            
            -- If we see the path, stop ghost tapping
            if math.abs(currentColor - config.path_color) < config.tolerance then
                gg.toast("✅ Game Loaded. Resuming Bot.")
                break
            end
            
            gg.click({x=sw/2, y=sh/2})
            gg.sleep(2000)
        end
    end
end

-- Bot Logic
local function runBotLogic()
    if not checkSystem() then return end
    
    gg.toast("🐰 BunnyBot: Bulletproof Mode ON")
    gg.setVisible(false)
    
    local sw, sh = gg.getScreenSize()
    local direction = "RIGHT"
    lastChangeTime = os.time()
    
    if not next(UI_LOCS) then UI_LOCS = vision_auto.autoLocate() end
    
    while true do
        -- 1. Heartbeat Check (STUCK State)
        if checkStuck() then
            direction = "RIGHT"
        end

        -- 2. State Detection
        local state = vision.checkState()
        
        if state == "START_SCREEN" then
            -- SCANNING State
            gg.toast("🔍 SCANNING: Play Button Detected")
            gg.vibrate(200) -- Haptic feedback
            
            local x = UI_LOCS.START_BTN and UI_LOCS.START_BTN.x or sw/2
            local y = UI_LOCS.START_BTN and UI_LOCS.START_BTN.y or sh*0.8
            gg.click({x=x, y=y})
            gg.sleep(2000)
            
        elseif state == "WIN_SCREEN" then
            -- VICTORY State
            gg.toast("🏆 VICTORY: Resetting for next level...")
            if config.autoReset then performReset() direction = "RIGHT" else break end
            
        elseif state == "GAME_OVER" or state == "LOSE_SCREEN" then
            -- DEFEAT State
            gg.toast("💩 DEFEAT: Resetting to skip ads...")
            if config.autoReset then performReset() direction = "RIGHT" else break end
            
        elseif state == "IN_GAME" then
            -- PLAYING State
            if config.path_color then
                local detectionY = sh * (config.detectionHeight / 100)
                local checkX = (direction == "RIGHT") and (sw/2 + 150) or (sw/2 - 150)
                local currentColor = gg.getPixel(checkX, detectionY)

                if math.abs(currentColor - config.path_color) > config.tolerance then
                    gg.click({x=sw/2, y=sh/2})
                    direction = (direction == "RIGHT") and "LEFT" or "RIGHT"
                    gg.sleep(config.refractoryMs)
                end
            end
        end

        if gg.isKeyPressed(gg.KEY_VOLUME_DOWN) then
            gg.toast("⏸️ Stopped by User")
            gg.setVisible(true)
            break
        end
        gg.sleep(10)
    end
end

-- Main Loop
while true do
    if gg.isVisible() then
        local choice = dashboard.showDashboard(config)
        
        if choice == 1 then
            runBotLogic()
            
        elseif choice == 2 then
            config.path_color = wizard.capturePathColor()
            wizard.saveConfig(config.path_color, config.rx, config.ry, config)
            
        elseif choice == 3 then
            UI_LOCS = vision_auto.autoLocate()
            
        elseif choice == 4 then
            config.rootMode = not config.rootMode
            gg.toast("Mode: " .. (config.rootMode and "ROOT (Shell)" or "HUMAN (Gesture)"))
            wizard.saveConfig(config.path_color, config.rx, config.ry, config)
            
        elseif choice == 5 then
            gg.alert("🏠 NO-ROOT CALIBRATION:\n1. Go to your Home Screen.\n2. Note the X,Y coordinates of the Bunny Runner icon.\n3. (Or use GG's 'Get Coordinate' tool if available).\n\nPress OK to enter coordinates.")
            local result = gg.prompt({"Icon X (0-1080)", "Icon Y (0-2400)"}, {config.appIconX or 540, config.appIconY or 1200}, {"number", "number"})
            if result then
                config.appIconX, config.appIconY = tonumber(result[1]), tonumber(result[2])
                gg.toast("✅ Icon Position Saved!")
                wizard.saveConfig(nil, nil, nil, config) -- Custom save
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
