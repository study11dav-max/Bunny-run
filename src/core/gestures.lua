local M = {}

-- Performs a "Human-like" reset of the app to bypass ads without Root
function M.humanResetApp(appIconX, appIconY)
    local sw, sh = gg.getScreenSize()
    
    gg.toast("🖐️ Performing Human Reset...")
    
    -- 1. Swipe up from bottom and HOLD to show Recent Apps
    -- Start from very bottom, move to middle, and stay briefly
    gg.gesture({
        {
            {x = sw / 2, y = sh - 10, t = 0},
            {x = sw / 2, y = sh / 2, t = 500}
        }
    })
    gg.sleep(1000)
    
    -- 2. Swipe the app card to the RIGHT (or UP depending on OS) to close it
    -- Note: Most modern Androids use Up swipe to close in recents. 
    -- We can try Up first as it's more common.
    gg.gesture({
        {
            {x = sw / 2, y = sh / 2, t = 0},
            {x = sw / 2, y = 100, t = 300}
        }
    })
    gg.sleep(800)
    
    -- 3. Click Home Button (Approximate center bottom)
    -- In gesture navigation, a quick swipe up from bottom works.
    gg.gesture({
        {
            {x = sw / 2, y = sh - 10, t = 0},
            {x = sw / 2, y = sh - 100, t = 100}
        }
    })
    gg.sleep(1000)
    
    -- 4. Click the App Icon on Home Screen (Calibrated by user)
    if appIconX and appIconY and appIconX > 0 then
        gg.click({x = appIconX, y = appIconY})
    else
        gg.alert("⚠️ Home Screen App Icon not calibrated. Please calibrate in Advanced Settings.")
    end
    
    gg.sleep(5000) -- Wait for clean launch
end

return M
