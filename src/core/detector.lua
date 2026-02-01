local Detector = {}

-- Configuration for fence colors (Calibration needed)
Detector.FENCE_COLOR_RGB = {0xFF, 0x00, 0x00} -- Example: Red
Detector.TOLERANCE = 10 -- Color matching tolerance

-- Helper to check if color matches
local function isColorMatch(hexColor, targetRGB)
    -- Extract RGB from hex (assuming 0xRRGGBB format)
    local r = (hexColor >> 16) & 0xFF
    local g = (hexColor >> 8) & 0xFF
    local b = hexColor & 0xFF

    local dr = math.abs(r - targetRGB[1])
    local dg = math.abs(g - targetRGB[2])
    local db = math.abs(b - targetRGB[3])

    return (dr + dg + db) < Detector.TOLERANCE
end

-- Main function to check boundaries
-- x, y: Coordinates to check
function Detector.checkBoundary(x, y)
    local color = -1
    
    -- Check if getPixelColor API exists (GameGuardian specific)
    if getPixelColor then
        color = getPixelColor(x, y)
    else
        -- Mock for testing
        return false 
    end

    if isColorMatch(color, Detector.FENCE_COLOR_RGB) then
        return true
    end

    return false
end

return Detector
