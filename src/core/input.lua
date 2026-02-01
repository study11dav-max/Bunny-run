local Input = {}

-- Simulate a tap at coordinates (x, y)
function Input.tap(x, y)
    -- In a real GameGuardian environment this might be just `tap(x,y)`
    -- or require `touchDown(0, x, y); os.sleep(0.05); touchUp(0, x, y)`
    -- Adjust for the specific API available.
    if tap then
        tap(x, y)
    else
        -- Fallback for testing/logging
        print(string.format("[Input] Tap executed at %d, %d", x, y))
    end
end

-- Emergency stop mechanism
function Input.panicStop()
    print("[Input] PANIC STOP ACTIVATED!")
    os.exit()
end

return Input
