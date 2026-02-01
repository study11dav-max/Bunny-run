local Panel = {}

-- UI Configuration
local UI_TITLE = "🐰 BunnyBot Pro"
local menu_options = {"🚀 Start Script", "🛑 Stop Script", "⚙️ Calibration", "❌ Exit"}

function Panel.show()
    -- This uses a standard Android-Lua interface pattern
    local choice = gg.choice(menu_options, nil, UI_TITLE)
    
    if choice == 1 then
        gg.toast("Running BunnyBot...")
        if startAutomation then startAutomation() end
    elseif choice == 2 then
        if stopAutomation then stopAutomation() end
        gg.toast("Script Paused.")
    elseif choice == 3 then
        if runCalibration then runCalibration() end
    elseif choice == 4 then
        os.exit()
    end
end

-- Create a floating icon to trigger the menu
function Panel.update()
    -- In main loop, we check if user tapped the GG icon (isVisible returns true)
    if gg.isVisible(true) then
        gg.setVisible(false)
        Panel.show()
    end
end

return Panel
