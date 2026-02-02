local M = {}

-- Anchors: Unique pixel points from the provided screenshots
-- These are based on center-ish coordinates for buttons and text banners
-- Note: These may need adjustments based on device resolution during calibration

M.anchors = {
    -- Starting Screen: 'PLAY' button (Blue)
    START_SCREEN = {x = 540, y = 1600, color = 0x2196F3, tolerance = 1000},
    
    -- Winning Screen: 'Next' button (Orange/Yellow) or 'Congratulations' banner
    WIN_SCREEN = {x = 540, y = 1750, color = 0xFFAA00, tolerance = 1000},
    
    -- Ending Screen: 'Try Again' button (Red) or 'GAME OVER' text
    GAME_OVER = {x = 540, y = 1550, color = 0xFF4444, tolerance = 1000},
    
    -- Losing Screen: 'Continue' button (Green) or 'No Thanks' text
    LOSE_SCREEN = {x = 540, y = 1450, color = 0x8BC34A, tolerance = 1000}
}

local function isColorClose(color1, color2, tolerance)
    local r1, g1, b1 = (color1 >> 16) & 0xFF, (color1 >> 8) & 0xFF, color1 & 0xFF
    local r2, g2, b2 = (color2 >> 16) & 0xFF, (color2 >> 8) & 0xFF, color2 & 0xFF
    
    local diff = math.abs(r1 - r2) + math.abs(g1 - g2) + math.abs(b1 - b2)
    return diff < (tolerance or 60) -- Default tolerance 60 for RGB distance
end

function M.checkState()
    -- Get current screen size to adjust anchors if they were set for 1080p
    local sw, sh = gg.getscreenSize()
    
    -- Heuristic check for each state
    for state, anchor in pairs(M.anchors) do
        -- Simple scaling if resolution differs from 1080p reference
        local targetX = math.floor(anchor.x * sw / 1080)
        local targetY = math.floor(anchor.y * sh / 2400)
        
        local current = gg.getPixel(targetX, targetY)
        
        -- Fuzzy color matching
        if isColorClose(current, anchor.color, anchor.tolerance) then
            return state
        end
    end
    
    return "IN_GAME"
end

return M
