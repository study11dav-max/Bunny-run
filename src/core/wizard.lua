local M = {}
local configPath = gg.EXT_STORAGE .. "/bunny_runner.cfg"

-- Step 1: Capture Path Color
function M.capturePathColor()
    gg.alert("🎨 STEP 1: Pause the game while Bunny is on the path.\n\nPress OK to capture the path color.")
    local sw, sh = gg.getScreenSize()
    
    -- Use the "Sweet Spot" - 60-70% from top
    local pathColor = gg.getPixel(sw / 2, sh * 0.65)
    gg.toast("✅ Path Color Captured: " .. string.format("0x%06X", pathColor))
    
    return pathColor
end

-- Step 2: Capture Restart Button Position
function M.captureRestartPos()
    gg.alert("💀 STEP 2: Let the Bunny die.\n\nWhen the RESTART button appears, press OK.")
    gg.sleep(500)
    
    local sw, sh = gg.getScreenSize()
    
    -- Prompt for coordinates (GG doesn't have reliable touch tracking)
    local input = gg.prompt({
        "Enter X of Restart Button", 
        "Enter Y of Restart Button"
    }, {
        sw/2, 
        sh*0.75
    }, {
        "number", 
        "number"
    })
    
    if input and input[1] then
        local rx = tonumber(input[1])
        local ry = tonumber(input[2])
        gg.toast("✅ Restart Position Saved: " .. rx .. ", " .. ry)
        return rx, ry
    end
    
    return 0, 0
end

-- Save configuration
function M.saveConfig(pathColor, rx, ry, settings)
    local file = io.open(configPath, "w")
    if file then
        file:write(pathColor .. "\n")
        file:write(rx .. "\n")
        file:write(ry .. "\n")
        -- Optional: Save advanced settings
        if settings then
            file:write((settings.detectionHeight or 65) .. "\n")
            file:write((settings.tolerance or 5000) .. "\n")
            file:write((settings.refractoryMs or 150) .. "\n")
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
                refractoryMs = tonumber(data[6]) or 150
            }
            return config
        end
    end
    return nil
end

return M
