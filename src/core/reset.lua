local M = {}

-- App Package Name
local PACKAGE = "com.bunny.runner3D.dg"

function M.restartGame()
    gg.toast("🔄 Resetting App to bypass Ads...")
    
    -- Force kill the app
    os.execute("am force-stop " .. PACKAGE)
    gg.sleep(1000)
    
    -- Relaunch the app
    os.execute("monkey -p " .. PACKAGE .. " -c android.intent.category.LAUNCHER 1")
    
    -- Wait for "Starting" screen to load
    -- We can make this dynamic later, but 5s is a safe baseline
    gg.sleep(5000) 
end

return M
