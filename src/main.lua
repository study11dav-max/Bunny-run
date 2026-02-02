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
        getscreenSize = function() return 1080, 2400 end,
        getPixel = function() return 0xFFFFFF end,
        toast = print,
        sleep = function() end,
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

-- STATE CONSTANTS
local STATE_WAITING = 0
local STATE_LEARNING = 1
local STATE_RUNNING = 2

local current_state = STATE_WAITING
local path_color = nil

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
end

-- Helper for Fuzzy Matching
local function isColorClose(c1, c2, tolerance)
    local r1, g1, b1 = (c1 >> 16) & 0xFF, (c1 >> 8) & 0xFF, c1 & 0xFF
    local r2, g2, b2 = (c2 >> 16) & 0xFF, (c2 >> 8) & 0xFF, c2 & 0xFF
    return (math.abs(r1-r2) + math.abs(g1-g2) + math.abs(b1-b2)) < (tolerance or 30)
end

-- Native Click Helper
local function click(p)
    gg.gesture({{{x=p.x, y=p.y, t=0}, {x=p.x, y=p.y, t=50}}})
end

-- Heartbeat Logic
local lastChangeTime = os.time()
local lastScreenHash = ""

local function checkStuck()
    local sw, sh = gg.getscreenSize()
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
    local sw, sh = gg.getscreenSize()
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
    
    -- GHOST TAP: Tap center until Path Color is detected (handles popups)
    if config.path_color or path_color then
        gg.toast("👻 GHOST TAP: Navigating through pop-ups...")
        local sw, sh = gg.getscreenSize()
        local startTime = os.time()
        local targetColor = config.path_color or path_color
        
        while os.time() - startTime < 10 do
            local detectionY = sh * (config.detectionHeight / 100)
            local currentColor = gg.getPixel(sw/2, detectionY)
            
            if isColorClose(currentColor, targetColor, 60) then
                gg.toast("✅ Game Loaded. Resuming Bot.")
                break
            end
            
            click({x=sw/2, y=sh/2})
            gg.sleep(2000)
        end
    end
end

-- Bot Logic (The Robust Loop)
local function runBotLogic()
    if not checkSystem() then return end
    
    local sw, sh = gg.getscreenSize()
    current_state = STATE_WAITING
    gg.toast("🐰 BunnyBot: Robust Learning Mode ON")
    gg.setVisible(false)
    
    local direction = "RIGHT"
    lastChangeTime = os.time()
    
    if not next(UI_LOCS) then UI_LOCS = vision_auto.autoLocate() end
    
    while true do
        if current_state == STATE_WAITING then
            -- Look for the blue 'PLAY' button (Welcome Page)
            local welcomePixel = gg.getPixel(sw / 2, sh * 0.85)
            if isColorClose(welcomePixel, 0x2196F3, 30) then
                gg.toast("👋 Waiting for you to press PLAY...")
                gg.sleep(1000)
            else
                -- User started the game
                current_state = STATE_LEARNING
            end

        elseif current_state == STATE_LEARNING then
            path_color = wizard.passivePathGatherer()
            config.path_color = path_color
            current_state = STATE_RUNNING
            gg.toast("🚀 Bot Logic ACTIVATED")

        elseif current_state == STATE_RUNNING then
            -- 1. Heartbeat Check
            if checkStuck() then
                direction = "RIGHT"
                current_state = STATE_WAITING
            end

            -- 2. State Detection & ZigZag
            local state = vision.checkState()
            
            if state == "START_SCREEN" then
                gg.toast("🔍 SCANNING: Play Button Detected")
                gg.vibrate(200)
                click({x=sw/2, y=sh*0.8}) -- Backup click
                gg.sleep(2000)
                
            elseif state == "WIN_SCREEN" or state == "GAME_OVER" or state == "LOSE_SCREEN" then
                gg.toast("🏆/💩 Resetting to skip ads...")
                if config.autoReset then 
                    performReset() 
                    direction = "RIGHT"
                    current_state = STATE_WAITING
                else 
                    break 
                end
                
            elseif state == "IN_GAME" then
                local detectionY = sh * (config.detectionHeight / 100)
                local checkX = (direction == "RIGHT") and (sw/2 + 150) or (sw/2 - 150)
                local currentColor = gg.getPixel(checkX, detectionY)

                if not isColorClose(currentColor, config.path_color, config.tolerance / 100) then
                    click({x=sw/2, y=sh/2})
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
            config.path_color = wizard.passivePathGatherer()
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
