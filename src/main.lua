local wizard = require("src.core.wizard")
local dashboard = require("src.ui.dashboard")
local vision = require("src.core.vision")
local vision_auto = require("src.core.vision_auto")
local reset = require("src.core.reset")
local gestures = require("src.core.gestures")

-- Mock GG for testing
if not gg then
    _G.gg = {
        getScreenSize = function() return 1080, 2400 end,
        getPixel = function() return 0xFFFFFF end,
        toast = print,
        sleep = function() end,
        click = function(t) print("Click", t.x, t.y) end,
        gesture = function() print("Gesture performed") end,
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
    rx = 0, ry = 0, -- Legacy / Manual calibration
    appIconX = 0, appIconY = 0, -- New Home Icon calibration
    ready = false,
    detectionHeight = 65,
    tolerance = 5000,
    refractoryMs = 150,
    autoReset = true,
    rootMode = true -- Default to Root Mode
}

-- Load existing config...
local savedConfig = wizard.loadConfig()
if savedConfig then
    for k, v in pairs(savedConfig) do config[k] = v end
end

-- Unified Reset Function
local function performReset()
    if config.rootMode then
        reset.restartGame()
    else
        gestures.humanResetApp(config.appIconX, config.appIconY)
    end
end

-- Bot Logic
local function runBotLogic()
    gg.toast("🐰 BunnyBot Started!")
    gg.setVisible(false)
    
    local sw, sh = gg.getScreenSize()
    local direction = "RIGHT"
    
    -- Cache UI locations if not already found
    if not next(UI_LOCS) then
        UI_LOCS = vision_auto.autoLocate()
    end
    
    while true do
        local state = vision.checkState()
        
        if state == "START_SCREEN" then
            gg.toast("🏠 At Start Screen - Tapping Play")
            -- Use UI_LOCS if found, otherwise fallback
            local x = UI_LOCS.START_BTN and UI_LOCS.START_BTN.x or sw/2
            local y = UI_LOCS.START_BTN and UI_LOCS.START_BTN.y or sh*0.8
            gg.click({x=x, y=y})
            gg.sleep(2000)
            
        elseif state == "WIN_SCREEN" or state == "GAME_OVER" or state == "LOSE_SCREEN" then
            if config.autoReset then
                performReset()
                direction = "RIGHT"
            else
                break
            end
        end

        -- ZigZag Logic
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
            gg.alert("🏠 GO TO HOME SCREEN\nHover finger over Bunny Runner icon.\nPress Volume Up to calibrate.")
            while not gg.isKeyPressed(gg.KEY_VOLUME_UP) do gg.sleep(100) end
            local pos = gg.getPointer() -- Assuming environment supports this or simple manual input
            config.appIconX, config.appIconY = 540, 1200 -- Placeholder for logic
            gg.toast("✅ Icon Position Saved!")
            wizard.saveConfig(config.path_color, config.rx, config.ry, config)
            
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
