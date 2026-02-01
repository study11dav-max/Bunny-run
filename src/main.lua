local wizard = require("src.core.wizard")

-- Mock GG for testing
if not gg then
    _G.gg = {
        getScreenSize = function() return 1080, 2400 end,
        getPixel = function() return 0xFFFFFF end,
        toast = print,
        sleep = function() end,
        click = function(t) print("Click", t.x, t.y) end,
        isKeyPressed = function() return false end,
        setVisible = function() end,
        EXT_STORAGE = "."
    }
end

-- Initialization
local pColor, rx, ry = wizard.loadConfig()
if not pColor then
    pColor, rx, ry = wizard.runSetup()
end

local function isDead()
    local c = gg.getPixel(rx, ry)
    -- Simple diff check from button color vs expected path? 
    -- Wait, user logic: "Button color is different from path"
    -- Actually correct logic: If pixel at restart button matches Restart Color?
    -- No, user code checks diff against pColor (Path Color).
    -- If `getPixel(rx, ry)` is NOT path color (distance > 10000), it implies button is there?
    -- Assuming path is White and button is Yellow/Green.
    if not pColor then return false end
    return math.abs(c - pColor) > 10000 
end

function startBot()
    gg.toast("🐰 BunnyBot GG Mode Started")
    local sw, sh = gg.getScreenSize()
    local direction = "RIGHT"
    
    while true do
        -- 1. Check for Death
        if isDead() then
            gg.toast("💀 Restarting...")
            gg.click({x=rx, y=ry})
            gg.sleep(2000) -- Wait for reload
        end

        -- 2. Automation Logic (The ZigZag)
        -- Look ahead? User code uses center offset based on internal direction state
        local checkX = (direction == "RIGHT") and (sw/2 + 150) or (sw/2 - 150)
        local currentColor = gg.getPixel(checkX, sh/2)

        -- If current lookup point is NOT path color -> Tap
        if math.abs(currentColor - pColor) > 5000 then
            gg.click({x=sw/2, y=sh/2}) -- Tap screen
            direction = (direction == "RIGHT") and "LEFT" or "RIGHT"
            gg.sleep(150) -- Refractory period
        end

        -- Emergency Exit
        if gg.isKeyPressed(gg.KEY_VOLUME_DOWN) then 
            gg.setVisible(true)
            break 
        end
        
        gg.sleep(10)
    end
end

startBot()
