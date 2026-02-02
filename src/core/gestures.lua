local M = {}

-- Native Tap Helper
local function tap(x, y)
    gg.gesture({{{x = x, y = y, t = 0}, {x = x, y = y, t = 50}}})
end

-- Performs a "Human-like" reset of the app to bypass ads without Root
function M.humanResetApp(appIconX, appIconY)
    local sw, sh = gg.getscreenSize()
    
    gg.toast("🖐️ Performing Human Reset...")
    
    -- 1. Open Recent Apps (Slow swipe up and hold)
    -- Using the user's suggested coordinate-based format for clarity if needed, 
    -- but keeping the internal list format which is more standard for gg.gesture
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
    if appIconX and appIconY and appIconX > 0 then
        tap(appIconX, appIconY)
        gg.toast("🚀 Relaunching Bunny Runner...")
    else
        gg.alert("⚠️ Home Screen Icon not calibrated!")
    end
    
    gg.sleep(6000) -- Clean boot time
end

return M
