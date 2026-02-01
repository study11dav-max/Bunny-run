local Detector = {}
local Input = require("src.core.input") -- dependency

-- Dynamic Configuration
Detector.config = {
    pathColor = 0xFFFFFF,
    tolerance = 10,
    offsetY_pct = 0.2, -- 20% from bottom
    offsetX_pct = 0.1, -- 10% from center
    centerX = 0,
    centerY = 0,
    isRunning = false
}

-- Global Control Functions (Bridged for UI)
function startAutomation()
    Detector.config.isRunning = true
    -- Initialize specific screen values on start if not set
    if Detector.config.centerX == 0 then
        -- Default fallback if calibration didn't run
        -- In GG, we might need a way to get screen size. 
        -- For now, we assume 1080p if not calibrated.
        Detector.config.centerX = 540
        Detector.config.centerY = 1920 / 2
    end
    print("BunnyBot: Started")
end

function stopAutomation()
    Detector.config.isRunning = false
    print("BunnyBot: Stopped")
end

function runCalibration()
    gg.toast("Tap CENTER of path in 2 seconds...")
    gg.sleep(2000)
    if getPixelColor then
        -- Mock center grab
        local c = getPixelColor(540, 1500)
        Detector.config.pathColor = c
        gg.alert("Calibrated Path Color: " .. c)
    else
        gg.alert("Unable to access getPixelColor")
    end
end

-- Check if a color matches the path color within tolerance
local function isPath(color)
    if color == -1 then return false end
    
    local r = (color >> 16) & 0xFF
    local g = (color >> 8) & 0xFF
    local b = color & 0xFF

    local tr = (Detector.config.pathColor >> 16) & 0xFF
    local tg = (Detector.config.pathColor >> 8) & 0xFF
    local tb = Detector.config.pathColor & 0xFF

    local diff = math.abs(r - tr) + math.abs(g - tg) + math.abs(b - tb)
    return diff <= Detector.config.tolerance
end

-- Core Logic
function Detector.update()
    if not Detector.config.isRunning then return end

    if not getPixelColor then return end

    -- Recalculate based on current config (in case screen size changes?)
    -- Ideally static, but allows tuning
    local offX = Detector.config.centerX * 0.25 -- example width scale
    local offY = 400 -- Fixed vertical lookahead often better than % 
    
    local leftX = Detector.config.centerX - offX
    local rightX = Detector.config.centerX + offX
    local scanY = 1920 - offY -- using fixed assumes 1920h, should use screenH

    local leftColor = getPixelColor(leftX, scanY)
    local rightColor = getPixelColor(rightX, scanY)

    if not isPath(leftColor) or not isPath(rightColor) then
        Input.tap(Detector.config.centerX, Detector.config.centerY)
        os.sleep(150) -- Humanize
    end
end

return Detector
