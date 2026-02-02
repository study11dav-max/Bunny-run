local M = {}

-- DNA of UI buttons for auto-scanning
M.PATTERNS = {
    START_BTN = {color = 0x2196F3, label = "Play Button"},    -- Blue
    WIN_NEXT  = {color = 0xFFAA00, label = "Next Button"},    -- Orange
    ENDING_RE = {color = 0xFF4444, label = "Try Again"},     -- Red/Pink
    LOSE_NO   = {color = 0x8BC34A, label = "Continue Button"} -- Green
}

-- Scans the screen to find button locations automatically
function M.autoLocate()
    local sw, sh = gg.getScreenSize()
    gg.toast("🔍 Auto-Scanning UI Elements...")

    local centerX = sw / 2
    local found = {}

    -- Scan vertical center from 70% to 95% of screen height
    for y = math.floor(sh * 0.7), math.floor(sh * 0.95), 10 do
        local pixel = gg.getPixel(centerX, y)
        
        for key, pattern in pairs(M.PATTERNS) do
            if not found[key] then
                -- Check color with tolerance
                if math.abs((pixel & 0xFFFFFF) - (pattern.color & 0xFFFFFF)) < 1000 then
                    found[key] = {x = centerX, y = y}
                    gg.toast("✅ Found " .. pattern.label)
                end
            end
        end
    end
    
    return found
end

return M
