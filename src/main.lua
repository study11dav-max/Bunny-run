local wizard = require("src.core.wizard")
local dashboard = require("src.ui.dashboard")
local vision = require("src.core.vision")
local reset = require("src.core.reset")

-- Mock GG for testing
if not gg then
    _G.gg = {
        getScreenSize = function() return 1080, 2400 end,
        getPixel = function() return 0xFFFFFF end,
        toast = print,
        sleep = function() end,
        click = function(t) print("Click", t.x, t.y) end,
        isKeyPressed = function() return false end,
        setVisible = function() end,
        isVisible = function() return false end,
        choice = function() return 1 end,
        alert = print,
        EXT_STORAGE = "."
    }
end

-- Configuration State
local config = {
    path_color = nil,
    rx = 0,
    ry = 0,
    ready = false,
    detectionHeight = 65,
    tolerance = 5000,
    refractoryMs = 150,
    autoReset = true -- New toggle for Ghost Reset
}

-- Load existing config if available
local savedConfig = wizard.loadConfig()
if savedConfig then
    config.path_color = savedConfig.path_color
    config.rx = savedConfig.rx
    config.ry = savedConfig.ry
    config.detectionHeight = savedConfig.detectionHeight
    config.tolerance = savedConfig.tolerance
    config.refractoryMs = savedConfig.refractoryMs
    config.ready = (config.path_color and config.rx > 0)
end

-- Bot Logic
local function runBotLogic()
    gg.toast("🐰 BunnyBot Started!")
    gg.setVisible(false)
    
    local sw, sh = gg.getScreenSize()
    local direction = "RIGHT"
    
    while true do
        -- High-level State Detection
        local state = vision.checkState()
        
        if state == "START_SCREEN" then
            gg.toast("🏠 At Start Screen - Tapping Play")
            gg.click({x=sw/2, y=sh*0.8}) -- Approximate Play Button
            gg.sleep(2000)
            
        elseif state == "WIN_SCREEN" or state == "GAME_OVER" then
            if config.autoReset then
                reset.restartGame()
                direction = "RIGHT" -- Reset direction for new run
            else
                break -- Exit or wait for user if autoReset is off
            end
            
        elseif state == "LOSE_SCREEN" then
            -- On the "Do you want to continue?" screen
            -- Instead of clicking "No Thanks" and hitting an ad on the next screen,
            -- we can either wait or just reset here too.
            if config.autoReset then
                reset.restartGame()
            end
        end

        -- ZigZag Detection (Only runs if path_color is calibrated)
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

        -- Emergency Exit
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
            -- RUN BOT
            runBotLogic()
            
        elseif choice == 2 then
            -- Step 1: Calibrate Path
            config.path_color = wizard.capturePathColor()
            wizard.saveConfig(config.path_color, config.rx, config.ry, config)
            config.ready = (config.path_color and config.rx > 0)
            
        elseif choice == 3 then
            -- Step 2: Calibrate Restart
            config.rx, config.ry = wizard.captureRestartPos()
            wizard.saveConfig(config.path_color, config.rx, config.ry, config)
            config.ready = (config.path_color and config.rx > 0)
            
        elseif choice == 4 then
            -- Toggle Ghost Reset
            config.autoReset = not config.autoReset
            wizard.saveConfig(config.path_color, config.rx, config.ry, config)
            
        elseif choice == 5 then
            -- Tutorial
            dashboard.showTutorial()
            
        elseif choice == 6 then
            -- Advanced Settings
            config = dashboard.showAdvancedSettings(config)
            wizard.saveConfig(config.path_color, config.rx, config.ry, config)
            
        elseif choice == 7 then
            -- Exit
            os.exit()
        end
        
        gg.setVisible(false)
    end
    gg.sleep(100)
end
