local Detector = {}
local Input = require("src.core.input")
local Calibration = require("src.core.calibration")

-- CONFIGURATION (V2)
-- These defaults are overridden by Calibration if available
Detector.config = {
    safeColor = 0xFFFFFF,
    tolerance = 15,
    baseLookAhead = 400,
    speedMultiplier = 1.02,
    maxLookAhead = 800,
    isRunning = false
}

-- STATE
Detector.state = {
    currentDirection = "RIGHT", -- Start assumption
    lookAheadY = 400,
    startTime = 0
}

-- Global Control Functions
function startAutomation()
    Detector.config.isRunning = true
    Detector.state.startTime = os.time()
    Detector.state.lookAheadY = Detector.config.baseLookAhead
    Detector.state.currentDirection = "RIGHT" -- Reset
    
    -- Sync with Calibration if available
    if Calibration.state.isCalibrated then
        Detector.config.safeColor = Calibration.state.pathColor
        -- Recalculate offsets/positions if needed
    end
    
    print("BunnyBot V2: Started")
end

function stopAutomation()
    Detector.config.isRunning = false
    print("BunnyBot V2: Stopped")
end

-- Advanced RGB split for better accuracy
local function isColorMatch(pixel, target)
    if pixel == -1 then return false end
    
    local r1, g1, b1 = (pixel >> 16) & 0xFF, (pixel >> 8) & 0xFF, pixel & 0xFF
    local r2, g2, b2 = (target >> 16) & 0xFF, (target >> 8) & 0xFF, target & 0xFF
    
    if math.abs(r1 - r2) > Detector.config.tolerance then return false end
    if math.abs(g1 - g2) > Detector.config.tolerance then return false end
    if math.abs(b1 - b2) > Detector.config.tolerance then return false end
    return true
end

-- "WHISKER" CHECK
-- Checks 3 points: Center, Center+10px, Center-10px
local function checkWhisker(x, y)
    -- Abstracting the API call
    local api = getPixelColor or gg.getPixel
    if not api then return false end

    local c1 = api(x, y)
    local c2 = api(x + 10, y) 
    local c3 = api(x - 10, y)
    
    local target = Detector.config.safeColor
    
    -- If ANY of these 3 are NOT the path color, return TRUE (Danger!)
    if not isColorMatch(c1, target) then return true end
    if not isColorMatch(c2, target) then return true end
    if not isColorMatch(c3, target) then return true end
    
    return false -- All safe
end

function Detector.updateSpeed()
    -- Every 10 seconds, look 2% further ahead
    local elapsed = (os.time() - Detector.state.startTime)
    if elapsed > 10 then
        -- Reset timer reference or keep continuous scaling?
        -- User logic: "Every 10 seconds, look 2% further"
        -- We can just calc based on total time chunks
        local chunks = math.floor(elapsed / 10)
        local newLook = Detector.config.baseLookAhead * (Detector.config.speedMultiplier ^ chunks)
        
        if newLook > Detector.config.maxLookAhead then newLook = Detector.config.maxLookAhead end
        Detector.state.lookAheadY = newLook
    end
end

-- Main Update Loop (Called by main.lua)
function Detector.update()
    if not Detector.config.isRunning then return end
    
    Detector.updateSpeed()

    -- Coordinate Resolving
    local cx = 540 -- Default Center X
    local sh = 1920 -- Default Screen H
    
    if Calibration.state.isCalibrated then
        cx = Calibration.state.pointL.x + 150 -- Re-deriving center from calibration point offset? 
        -- Actually Calibration sets pointL/pointR. 
        -- Let's assume we want to use the Calibration Center if we have one.
        -- But for V2 logic, user provided code uses `cx + 150`.
        -- Let's stick to the Calibration logic: Center is avg of L and R?
        -- Or just use screen center.
        -- User said: "Level 1: Look 300 pixels ahead."
        -- Let's assume we use standard screen center for now or calibration provided center if any.
        -- Calibration module we built saves `state.pointL`.
        -- Let's use hardcoded screen center allowing fallback.
        if Calibration.state.pointL.x > 0 then
             -- Rough estimate of center from left point
             cx = Calibration.state.pointL.x + 150 
        end
    end
    
    -- Calculate Detection Y
    -- The user code: detection_y = sh - look_ahead_y
    local detection_y = sh - Detector.state.lookAheadY
    
    -- State Locked Logic
    if Detector.state.currentDirection == "RIGHT" then
        -- ONLY watch the Right Wall (cx + 150)
        if checkWhisker(cx + 150, detection_y) then
            Input.tap(cx, sh / 2)
            Detector.state.currentDirection = "LEFT" -- State switch
            os.sleep(100) -- Small refractory period
        end
        
    elseif Detector.state.currentDirection == "LEFT" then
        -- ONLY watch the Left Wall (cx - 150)
        if checkWhisker(cx - 150, detection_y) then
            Input.tap(cx, sh / 2)
            Detector.state.currentDirection = "RIGHT" -- State switch
            os.sleep(100)
        end
    end
end

return Detector
