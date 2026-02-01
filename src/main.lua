local wizard = require("src.core.wizard")
local dashboard = require("src.ui.dashboard")

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
    refractoryMs = 150
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
local function isDead()
    local c = gg.getPixel(config.rx, config.ry)
    if not config.path_color then return false end
    return math.abs(c - config.path_color) > 10000
end

local function runBotLogic()
    gg.toast("🐰 BunnyBot Started!")
    gg.setVisible(false)
    
    local sw, sh = gg.getScreenSize()
    local direction = "RIGHT"
    local detectionY = sh * (config.detectionHeight / 100)
    
    while true do
        -- Check for Death & Auto-Restart
        if isDead() then
            gg.toast("💀 Restarting...")
            gg.click({x=config.rx, y=config.ry})
            gg.sleep(2000)
            direction = "RIGHT" -- Reset direction
        end

        -- ZigZag Detection (State-Locked)
        local checkX = (direction == "RIGHT") and (sw/2 + 150) or (sw/2 - 150)
        local currentColor = gg.getPixel(checkX, detectionY)

        -- Luminance/Darkness check (not exact color)
        if math.abs(currentColor - config.path_color) > config.tolerance then
            gg.click({x=sw/2, y=sh/2})
            direction = (direction == "RIGHT") and "LEFT" or "RIGHT"
            gg.sleep(config.refractoryMs)
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
            if config.ready then
                runBotLogic()
            else
                gg.alert("🚫 Please complete Steps 1 and 2 first!")
            end
            
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
            -- Tutorial
            dashboard.showTutorial()
            
        elseif choice == 5 then
            -- Advanced Settings
            config = dashboard.showAdvancedSettings(config)
            wizard.saveConfig(config.path_color, config.rx, config.ry, config)
            
        elseif choice == 6 then
            -- Exit
            os.exit()
        end
        
        gg.setVisible(false)
    end
    gg.sleep(100)
end
