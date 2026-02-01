local M = {}
local configPath = gg.EXT_STORAGE .. "/bunny_runner.cfg"

function M.runSetup()
    gg.alert("🚀 Bunny Runner: FIRST RUN SETUP")
    
    -- 1. Get Path Color
    gg.alert("STEP 1: Start a game and PAUSE. Position the Bunny on a clear path. Then press OK.")
    local sw, sh = gg.getScreenSize()
    
    -- In standard GG, getPixel(x,y) returns the color integer
    -- We assume the center is safe
    local pathColor = gg.getPixel(sw / 2, sh / 2)
    gg.toast("Color Captured: " .. pathColor)
    
    -- 2. Get Restart Button Location
    gg.alert("STEP 2: Die in the game. When the RESTART button appears, HOVER your finger over it and press VOLUME UP.")
    
    local rx, ry = 0, 0
    while true do
        -- Wait for Vol Up Key
        if gg.isKeyPressed(gg.KEY_VOLUME_UP) then
            -- Only use getTargetInfo or prompt because standard GG gets pointer hard
            -- User specifically requested prompting coords if device not rooted/capable
            local input = gg.prompt({"Enter X of Restart Button", "Enter Y of Restart Button"}, {sw/2, sh*0.8}, {"number", "number"})
            if input and input[1] then
                rx = tonumber(input[1])
                ry = tonumber(input[2])
                break
            end
        end
        gg.sleep(100)
    end
    
    -- Save to file
    local file = io.open(configPath, "w")
    if file then
        file:write(pathColor .. "\n" .. rx .. "\n" .. ry)
        file:close()
        gg.alert("✅ Setup Saved! Restarting script...")
    else
        gg.alert("❌ Error saving config")
    end
    
    return pathColor, rx, ry
end

function M.loadConfig()
    local file = io.open(configPath, "r")
    if file then
        local data = {}
        for line in file:lines() do table.insert(data, line) end
        file:close()
        if #data >= 3 then
            return tonumber(data[1]), tonumber(data[2]), tonumber(data[3])
        end
    end
    return nil
end

return M
