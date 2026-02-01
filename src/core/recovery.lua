local Input = require("src.core.input")

local Recovery = {}

-- CONFIGURATION
-- Adjust these based on the actual Game Over screen
Recovery.RESTART_BTN_COLOR = 0xFFCC00 -- Example: Yellow
Recovery.RESTART_X = 540
Recovery.RESTART_Y = 1600

-- Shared color matcher (simplified for UI)
local function isColorMatch(c1, c2)
    if c1 == -1 then return false end
    -- Simple distance check or bitwise diff
    -- User provided: math.abs((c1 & 0xFFFFFF) - (c2 & 0xFFFFFF)) < 2000
    -- Note: This is a very loose check, might need RGB split if buttons are complex
    local diff = math.abs((c1 & 0xFFFFFF) - (c2 & 0xFFFFFF))
    return diff < 2000
end

-- Check if we are dead
function Recovery.checkGameOver()
    -- Ensure API availability
    local api = getPixelColor or gg.getPixel
    if not api then return false end

    -- Look for the "Game Over" specific pixel
    local color = api(Recovery.RESTART_X, Recovery.RESTART_Y)
    
    if isColorMatch(color, Recovery.RESTART_BTN_COLOR) then
        gg.toast("💀 Bunny Died. Restarting...")
        gg.sleep(1000) -- Wait for animation to settle
        Input.tap(Recovery.RESTART_X, Recovery.RESTART_Y) -- Click Restart
        gg.sleep(500)  -- Wait for game to reload
        return true
    end
    return false
end

return Recovery
