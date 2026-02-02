local M = {}

-- Native Tap Helper
local function tap(x, y)
    gg.gesture({{{x = x, y = y, t = 0}, {x = x, y = y, t = 50}}})
end

-- Performs a "Human-like" reset of the app to bypass ads without Root
function M.humanResetApp(appIconX, appIconY)
    local sw, sh = gg.getscreenSize()
    
    gg.toast("🖐️ Performing Human Reset...")
    
    -- 1. Open Recents (Swipe up and HOLD)
    gg.gesture({
        {
            {x = sw / 2, y = sh - 10, t = 0},
            {x = sw / 2, y = sh / 2, t = 600}
        }
    })
    gg.sleep(1000)
    
    -- 2. Swipe App Away (Swipe card OFF the screen)
    -- Using a side swipe as per the user's refined logic
    gg.gesture({
        {
            {x = sw / 2, y = sh / 2, t = 0},
            {x = sw, y = sh / 2, t = 300}
        }
    })
    gg.sleep(1000)
    
    -- 3. Tap Home Button (Assumes bottom center)
    tap(sw / 2, sh - 50)
    gg.sleep(500)
    
    -- 4. Tap the App Icon on Home Screen (Relaunch)
    if appIconX and appIconY and appIconX > 0 then
        tap(appIconX, appIconY)
        gg.toast("🚀 Relaunching Bunny Runner...")
    else
        gg.alert("⚠️ Home Screen Icon not calibrated!")
    end
    
    gg.sleep(5000) -- Clean boot time
end

return M
