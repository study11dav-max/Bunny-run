-- TYPO VACCINE: Ensures the script works on all GG versions
if gg then
    if not gg.getscreenSize then gg.getscreenSize = gg.getScreenSize end
    if not gg.getpixel then gg.getpixel = gg.getPixel end
end

local M = {}

-- Native Tap Helper
local function tap(x, y)
    gg.gesture({{{x = x, y = y, t = 0}, {x = x, y = y, t = 50}}})
end

-- Performs a "Human-like" reset of the app to bypass ads without Root
function M.humanResetApp(appIconX, appIconY)
    local sw, sh = gg.getScreenSize()
    
    gg.toast("🖐️ Performing Human Reset...")
    
    -- 1. Open Recent Apps (Slow swipe up and hold)
    gg.gesture({
        {
            {x = sw / 2, y = sh - 20, t = 0},
            {x = sw / 2, y = sh / 2, t = 800}
        }
    })
    gg.sleep(1200)
    
    -- 2. Dismiss the Game (Swipe card to the side)
    gg.gesture({
        {
            {x = sw / 2, y = sh / 2, t = 0},
            {x = sw - 50, y = sh / 2, t = 400}
        }
    })
    gg.sleep(1000)
    
    -- 3. Tap Home Button (Assumes bottom center)
    tap(sw / 2, sh - 50)
    gg.sleep(1000)
    
    -- 4. Tap the App Icon on Home Screen (Relaunch)
    -- Defaulting to Top-Left if not provided
    local targetX = (appIconX and appIconX > 0) and appIconX or 50
    local targetY = (appIconY and appIconY > 0) and appIconY or 50
    
    tap(targetX, targetY)
    gg.toast("🚀 Relaunching Bunny Runner...")
    
    gg.sleep(6000) -- Allow time for game splash screen
end

return M
