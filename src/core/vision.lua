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

function M.checkState()
    -- Get current screen size to adjust anchors if they were set for 1080p
    local sw, sh = gg.getScreenSize()
    
    -- Heuristic check for each state
    for state, anchor in pairs(M.anchors) do
        -- Simple scaling if resolution differs from 1080p reference
        local targetX = math.floor(anchor.x * sw / 1080)
        local targetY = math.floor(anchor.y * sh / 2400)
        
        local current = gg.getPixel(targetX, targetY)
        
        -- Compare colors (using simple distance)
        if math.abs((current & 0xFFFFFF) - (anchor.color & 0xFFFFFF)) < anchor.tolerance then
            return state
        end
    end
    
    return "IN_GAME"
end

return M
