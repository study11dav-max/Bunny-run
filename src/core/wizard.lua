local M = {}
local configPath = gg.EXT_STORAGE .. "/bunny_runner.cfg"

-- Passive Learning: Samples the path many times and picks the most frequent color
function M.passivePathGatherer()
    local sw, sh = gg.getScreenSize()
    local colorVotes = {}
    local samplesNeeded = 30
    local collected = 0

    gg.toast("🕒 Learning Path... Just play normally!")
    
    while collected < samplesNeeded do
        local color = gg.getPixel(sw / 2, sh * 0.7)
        -- Ignore pure black or pure white (loading screens)
        if color ~= 0x000000 and color ~= 0xFFFFFF then
            colorVotes[color] = (colorVotes[color] or 0) + 1
            collected = collected + 1
        end
        gg.sleep(150)
    end

    -- Find the most frequent color (Mode) to ignore shadows
    local winner, max = nil, 0
    for color, count in pairs(colorVotes) do
        if count > max then
            max = count
            winner = color
        end
    end

    gg.toast("✅ Calibration Successful!")
    return winner
end

-- Step 2: Capture Restart Button Position
function M.captureRestartPos()
    -- Use the center for the Restart/Continue button based on game UI
    local sw, sh = gg.getScreenSize()
    
    -- Based on UI screenshots, buttons are centered horizontally
    local rx = sw / 2
    local ry = math.floor(sh * 0.75) -- Adjusted for the 'Try Again'/'Continue' area
    
    gg.toast("✅ Button Coordinates set to center-bottom.")
    return rx, ry
end

-- Save configuration
function M.saveConfig(pathColor, rx, ry, settings)
    local file = io.open(configPath, "w")
    if file then
        file:write((pathColor or 0) .. "\n")
        file:write((rx or 0) .. "\n")
        file:write((ry or 0) .. "\n")
        -- Optional: Save advanced settings
        if settings then
            file:write((settings.detectionHeight or 65) .. "\n")
            file:write((settings.tolerance or 5000) .. "\n")
            file:write((settings.refractoryMs or 150) .. "\n")
            file:write((settings.appIconX or 0) .. "\n")
            file:write((settings.appIconY or 0) .. "\n")
            file:write((settings.autoReset and 1 or 0) .. "\n")
            file:write((settings.rootMode and 1 or 0) .. "\n")
        end
        file:close()
        return true
    end
    return false
end

-- Load configuration
function M.loadConfig()
    local file = io.open(configPath, "r")
    if file then
        local data = {}
        for line in file:lines() do table.insert(data, line) end
        file:close()
        
        if #data >= 3 then
            local config = {
                path_color = tonumber(data[1]),
                rx = tonumber(data[2]),
                ry = tonumber(data[3]),
                detectionHeight = tonumber(data[4]) or 65,
                tolerance = tonumber(data[5]) or 5000,
                refractoryMs = tonumber(data[6]) or 150,
                appIconX = tonumber(data[7]) or 0,
                appIconY = tonumber(data[8]) or 0,
                autoReset = (tonumber(data[9]) == 1),
                rootMode = (tonumber(data[10]) == 1)
            }
            return config
        end
    end
    return nil
end

-- Full Intelligent Calibration Wizard
function M.runFullCalibration(config)
    gg.alert("🎯 STARTING AUTOMATED CALIBRATION\n\nPlease follow the prompts to make the bot fail-proof.")

    local sw, sh = gg.getScreenSize()

    -- STEP 1: App Icon Location (For No-Root Reset)
    gg.alert("1. Go to your Home Screen.\n2. Note where the Bunny Runner icon is.\n3. Press OK and enter the coordinates.")
    
    local appPos = gg.prompt({
        "Icon X-Coordinate", 
        "Icon Y-Coordinate"
    }, {sw/2, sh/2}, {"number", "number"})

    if appPos then
        config.appIconX = tonumber(appPos[1])
        config.appIconY = tonumber(appPos[2])
    end

    -- STEP 2: Path Color Detection
    gg.alert("2. Open the game to the START screen (where Bunny is on the path) and press OK.")
    gg.sleep(2000)
    config.path_color = gg.getPixel(sw/2, sh*0.65)
    
    -- DEFAULT Advanced Settings
    config.detectionHeight = 65
    config.tolerance = 5000
    config.refractoryMs = 150
    config.autoReset = true
    
    M.saveConfig(config.path_color, config.rx, config.ry, config)
    gg.toast("✅ Calibration Saved! Bot is now bulletproof.")
    
    return config
end

return M
