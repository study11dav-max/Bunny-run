local M = {}

function M.requestAccessibility()
    gg.alert("🛡️ NON-ROOT SETUP\n\nTo skip ads like a human, the script needs 'Accessibility' permission to perform gestures.\n\nPress OK to open Settings.")
    
    -- Launch the Android Accessibility Settings page directly
    os.execute("am start -a android.settings.ACCESSIBILITY_SETTINGS")
    
    gg.alert([[
📢 ATTENTION:
1. Find 'GameGuardian' or 'Downloaded Apps'.
2. If it's greyed out, click the 3 dots (top right) and select 'Allow Restricted Settings'.
3. Enable the toggle.
4. Return to the game and restart the script!
    ]])
end

return M
