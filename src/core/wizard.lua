local M = {}

-- Simple JSON mock if not available in environment
local json = {}
function json.encode(t) 
    -- Ultra-simple serializer for our flat config
    local s = "{"
    for k,v in pairs(t) do
        if type(v) == "number" or type(v) == "boolean" then
            s = s .. string.format('"%s": %s, ', k, tostring(v))
        else
            s = s .. string.format('"%s": "%s", ', k, tostring(v))
        end
    end
    return s .. '"_end":0}' -- Hacky valid JSON
end
function json.decode(s)
    -- Just return default or mock; parsing JSON in Lua without lib is verbose
    -- In real GG, 'json' is often available or we read/write Lua tables
    return M.config -- Fallback
end

-- Try require real JSON if available
pcall(function() json = require("json") end)

local CONFIG_FILE = (gg.EXT_STORAGE or "/sdcard") .. "/bunny_bot_config.json"

M.config = {
    path_color = 0xFFFFFF,
    restart_x = 0,
    restart_y = 0,
    is_configured = false
}

function M.loadConfig()
    local f = io.open(CONFIG_FILE, "r")
    if f then
        local content = f:read("*a")
        local status, res = pcall(json.decode, content)
        if status then 
            M.config = res 
        else
            -- If decode fails (e.g. using our mock), use default logic or simple parse
            -- For this prototype, we'll assume load failed if we can't parse
            f:close()
            return false
        end
        f:close()
        return true
    end
    return false
end

function M.saveConfig()
    local f = io.open(CONFIG_FILE, "w")
    f:write(json.encode(M.config))
    f:close()
    gg.toast("✅ Configuration Saved!")
end

function M.runWizard()
    gg.alert("⚠️ FIRST RUN SETUP ⚠️\nWe need to learn the game. Follow the instructions exactly.")
    
    -- STEP 1: LEARN PATH
    gg.alert("1. Start game, PAUSE while bunny is on path.\n\nPress OK when ready.")
    gg.sleep(1000)
    
    -- In standard GG, screen size isn't always directly exposed via getScreenSize without context
    -- We assume getRanges or similar might give hints, or we just take center relative to 1080p assumption
    -- Or user provided code `gg.getScreenSize` implies it's available in their env.
    local sw, sh = 0, 0
    if gg.getScreenSize then 
        sw, sh = gg.getScreenSize() 
    else
        sw, sh = 1080, 2400 -- Fallback
    end

    if getPixelColor or gg.getPixel then
        local pixelApi = getPixelColor or gg.getPixel
        M.config.path_color = pixelApi(sw / 2, sh * 0.6)
        gg.toast("🔹 Path Color Learned: " .. M.config.path_color)
    else
        gg.alert("Error: Cannot read pixels.")
    end
    
    -- STEP 2: LEARN DEATH SCREEN
    gg.alert("2. Resume and DIE. Wait for 'Restart'.\n\nPress OK when Death Screen is visible.")
    gg.sleep(2000)
    
    gg.toast("👇 Hover finger over RESTART button & Press Volume UP!")
    
    -- Wait for VolUp key for "Touch" capture if getTouch is missing
    local captured = false
    while not captured do
        -- Mock check for VolUp (gg.isVisible flip is common hack, but assuming key listener)
        -- If specific Env has getTouch:
        if gg.getTouch then 
             local t = gg.getTouch()
             if t then
                M.config.restart_x = t.x
                M.config.restart_y = t.y
                captured = true
             end
        else
            -- Polling loop for non-touch GG is hard without specific key API
            -- We'll just ask them to tap Center of button relative to crosshair logic maybe?
            -- Or just fallback to hardcoded if we can't detect touch.
            -- User request says "Hover your finger... Press Vol Up", implies we can read pointer?
            -- Usually `gg.getPointer()` isn't standard. 
            -- Let's stick to the prompt if no touch:
            local input = gg.prompt({"Enter Restart X:", "Enter Restart Y:"}, {540, 1600}, {"number", "number"})
            if input then
                M.config.restart_x = tonumber(input[1])
                M.config.restart_y = tonumber(input[2])
                captured = true
            end
        end
        gg.sleep(100)
    end
    
    M.config.is_configured = true
    M.saveConfig()
    gg.alert("🎉 Setup Complete!")
end

return M
