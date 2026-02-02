local M = {}

function M.showDashboard(configState)
    -- Check what steps are done
    local step1 = configState.path_color and "✅" or "❌"
    local step2 = (configState.rx > 0) and "✅" or "❌"
    local ghost = configState.autoReset and "ON" or "OFF"
    local mode = configState.rootMode and "ROOT" or "HUMAN"
    
    local status = string.format(
        "--- SETUP STATUS ---\n1. Path Color: %s\n2. Mode: %s\n3. Ghost Reset: %s\n--------------------",
        step1, mode, ghost
    )

    local menu = gg.choice({
        "🚀 RUN BOT",
        "🎨 Step 1: Calibrate Path",
        "🤖 Auto-Scan UI Elements",
        "🔄 Switch Mode [" .. mode .. "]",
        "🏠 Calibrate Home App Icon",
        "👻 Toggle Ghost Reset [" .. ghost .. "]",
        "📖 View Tutorial / Help",
        "⚙️ Advanced Settings",
        "❌ Close Panel"
    }, nil, status)
    
    return menu
end

function M.showTutorial()
    gg.alert([[
📖 GHOST RESET GUIDE:
• This bot uses the "Ghost" method to bypass ads.
• When you Win or Lose, the app automatically restarts.
• This ensures 0 ads and infinite loops!

💡 QUICK START:
1. Calibrate Path Color while playing.
2. Toggle Ghost Reset to ON.
3. Click 'RUN BOT'.

🔧 TECHNICAL:
• Requires Shell/Root for app restarting.
• Uses Pixel Anchors for state detection.
• Emergency Stop: Volume Down.
    ]])
end

function M.showAdvancedSettings(config)
    local ghost = config.autoReset and "ON" or "OFF"
    local result = gg.prompt({
        "Detection Height (% from top)",
        "Color Tolerance (Luminance)",
        "Refractory Period (ms)",
        "Auto-Reset (1=ON, 0=OFF)"
    }, {
        config.detectionHeight or 65,
        config.tolerance or 5000,
        config.refractoryMs or 150,
        config.autoReset and 1 or 0
    }, {
        "number",
        "number", 
        "number",
        "number"
    })
    
    if result then
        config.detectionHeight = tonumber(result[1])
        config.tolerance = tonumber(result[2])
        config.refractoryMs = tonumber(result[3])
        config.autoReset = (tonumber(result[4]) == 1)
        gg.toast("⚙️ Settings Updated!")
    end
    
    return config
end

return M
