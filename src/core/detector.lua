local Detector = {}
local Input = require("src.core.input")
local Calibration = require("src.core.calibration")

Detector.config = {
    tolerance = 10,
    isRunning = false,
    ignoreSide = nil, -- 'left' or 'right' or nil
    ignoreTimer = 0
}

-- Global Control Functions
function startAutomation()
    Detector.config.isRunning = true
    print("BunnyBot: Started")
end

function stopAutomation()
    Detector.config.isRunning = false
    print("BunnyBot: Stopped")
end

-- Color match with tolerance
local function isPath(color, targetColor)
    if color == -1 then return false end
    
    local r = (color >> 16) & 0xFF
    local g = (color >> 8) & 0xFF
    local b = color & 0xFF

    local tr = (targetColor >> 16) & 0xFF
    local tg = (targetColor >> 8) & 0xFF
    local tb = targetColor & 0xFF

    local diff = math.abs(r - tr) + math.abs(g - tg) + math.abs(b - tb)
    return diff <= Detector.config.tolerance
end

function Detector.update()
    if not Detector.config.isRunning then return end
    if not getPixelColor then return end

    -- Use Calibrated points if available
    local pL = Calibration.state.pointL
    local pR = Calibration.state.pointR
    local targetColor = Calibration.state.pathColor

    -- If not calibrated, use default (safety fallback)
    if not Calibration.state.isCalibrated then
        -- Default: Center +/- offset
        local cx = 540
        local cy = 1500
        pL = {x = cx - 150, y = cy}
        pR = {x = cx + 150, y = cy}
        targetColor = 0xFFFFFF
    end

    -- Handle exclude timer (to prevent double tap on same turn)
    if Detector.config.ignoreTimer > 0 then
        Detector.config.ignoreTimer = Detector.config.ignoreTimer - 1
        -- Early exit or partial check could go here
    end

    -- Check sensors
    -- If we just turned LEFT (tapped because RIGHT sensor hit fence), 
    -- we should momentarily ignore the RIGHT sensor or the LEFT sensor depending on mechanics.
    -- Usually: You tap to TOGGLE direction.
    -- If moving Right -> Right sensor hits fence -> Tap -> Now moving Left.
    -- Danger: We might still be near the right fence for a few frames. 
    -- So we should ignore the sensor that triggered the tap.

    local checkLeft = (Detector.config.ignoreSide ~= 'left' or Detector.config.ignoreTimer <= 0)
    local checkRight = (Detector.config.ignoreSide ~= 'right' or Detector.config.ignoreTimer <= 0)

    local leftColor = -1
    local rightColor = -1

    if checkLeft then leftColor = getPixelColor(pL.x, pL.y) end
    if checkRight then rightColor = getPixelColor(pR.x, pR.y) end

    local triggerTap = false
    local triggerSource = nil

    if checkLeft and not isPath(leftColor, targetColor) then
        triggerTap = true
        triggerSource = 'left'
    elseif checkRight and not isPath(rightColor, targetColor) then
        triggerTap = true
        triggerSource = 'right'
    end

    if triggerTap then
        -- Action: Tap to switch direction
        -- Tap center or anywhere safe
        Input.tap(540, 1000) 
        
        -- Logic: We hit a fence on 'triggerSource' side.
        -- We are switching direction AWAY from that fence.
        -- We should ignore that side for a bit to avoid re-triggering while moving away.
        Detector.config.ignoreSide = triggerSource
        Detector.config.ignoreTimer = 10 -- frames (~160ms at 60fps)
        
        -- Also sleep briefly to ensure input registers
        os.sleep(50) 
    end
end

return Detector
