local M = {}

function M.showDashboard(configState)
    -- Check what steps are done
    local step1 = configState.path_color and "✅" or "❌"
    local step2 = (configState.rx > 0) and "✅" or "❌"
    
    local status = string.format(
        "--- SETUP STATUS ---\n1. Path Color: %s\n2. Restart Button: %s\n--------------------",
        step1, step2
    )

    local menu = gg.choice({
        "🚀 RUN BOT (Ready: " .. (configState.ready and "YES" or "NO") .. ")",
        "🎨 Step 1: Calibrate Path",
        "💀 Step 2: Calibrate Restart",
        "📖 View Tutorial / Help",
        "⚙️ Advanced Settings",
        "❌ Close Panel"
    }, nil, status)
    
    return menu
end

function M.showTutorial()
    gg.alert([[
📖 QUICK START GUIDE:
1. Start a match and Pause. Click 'Step 1' while Bunny is on the track.
2. Let the Bunny die. When the 'Restart' button appears, click 'Step 2'.
3. Use the crosshair to mark the button.
4. Click 'RUN BOT'.

💡 PRO TIPS:
• Turn OFF Battery Saver mode for smooth frame rates
• If Bunny turns too late, re-calibrate Step 1 slightly higher
• The 60-70% screen height is the "Sweet Spot" for detection
• Emergency Stop: Press Volume Down during a run

🔧 TECHNICAL:
• Uses Luminance Threshold (not exact color matching)
• Detects "darker" pixels as walls/fences
• Auto-restarts on death
    ]])
end

function M.showAdvancedSettings(config)
    local result = gg.prompt({
        "Detection Height (% from top, 60-70 recommended)",
        "Color Tolerance (5-15 recommended)",
        "Refractory Period (ms, 100-200 recommended)"
    }, {
        config.detectionHeight or 65,
        config.tolerance or 5000,
        config.refractoryMs or 150
    }, {
        "number",
        "number", 
        "number"
    })
    
    if result then
        config.detectionHeight = tonumber(result[1])
        config.tolerance = tonumber(result[2])
        config.refractoryMs = tonumber(result[3])
        gg.toast("⚙️ Settings Updated!")
    end
    
    return config
end

return M
