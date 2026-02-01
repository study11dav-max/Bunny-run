local Panel = {}

-- State variables
Panel.isRunning = false
Panel.speedMultiplier = 1.0

function Panel.show()
    -- GameGuardian UI implementation
    -- This is a simplified menu structure
    local choice = gg.choice({
        "Start/Stop Script [" .. (Panel.isRunning and "RUNNING" or "STOPPED") .. "]",
        "Config Speed [" .. Panel.speedMultiplier .. "x]",
        "Exit"
    }, nil, "Bunny Runner Auto v1.0")

    if choice == 1 then
        Panel.isRunning = not Panel.isRunning
        gg.toast("Script is now " .. (Panel.isRunning and "RUNNING" or "STOPPED"))
    elseif choice == 2 then
        local input = gg.prompt({"Enter Speed Multiplier (0.5 - 5.0):"}, {Panel.speedMultiplier}, {"number"})
        if input and input[1] then
            Panel.speedMultiplier = tonumber(input[1])
            gg.toast("Speed set to " .. Panel.speedMultiplier)
        end
    elseif choice == 3 then
        print("Exiting...")
        os.exit()
    end
end

-- Non-blocking UI update (if framework supports it, otherwise poll)
function Panel.update()
    -- In standard GG, ui is blocking (showMenu), so this might need to be called periodically
    -- or use a transparent overlay if available in advanced setups.
    -- For now, we assume key press triggers menu or it runs in a standard visible check loop.
    if gg.isVisible(true) then
        gg.setVisible(false)
        Panel.show()
    end
end

return Panel
