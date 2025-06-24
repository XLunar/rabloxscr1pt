print("[AutoClutch] Core logic initializing and activating...")

-- Localize Roblox Services
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- State variables
local holdingE = false
local isExecutingDoubleTap = false -- Flag to prevent re-triggering during the double tap
local inputBeganConn = nil
local inputEndedConn = nil

-- Function to simulate a single key tap
local function simulateKeyTap(keyCode)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game) -- Key Down
    task.wait(0.03) -- Small delay for game to register key down
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game) -- Key Up
end

--- Connects the AutoClutch input listeners.
-- This function is called automatically when this script is loaded (toggled ON).
local function connectAutoClutch()
    -- Only connect if not already connected (redundant check but good practice)
    if inputBeganConn and inputEndedConn then
        print("[AutoClutch] Input listeners already connected. Skipping.")
        return
    end

    inputBeganConn = UIS.InputBegan:Connect(function(input, processed)
        if processed then return end

        -- Only start holding if we are not currently executing a double tap
        if input.KeyCode == Enum.KeyCode.E and not holdingE and not isExecutingDoubleTap then
            holdingE = true
            -- print("[AutoClutch] E key held.") -- Uncomment for debug
        end
    end)

    inputEndedConn = UIS.InputEnded:Connect(function(input, processed)
        if processed then return end

        -- Trigger the double tap only if E was genuinely held and released,
        -- and we are not already in the middle of executing a double tap.
        if input.KeyCode == Enum.KeyCode.E and holdingE and not isExecutingDoubleTap then
            holdingE = false -- Reset holding state immediately
            isExecutingDoubleTap = true -- Set flag to prevent re-triggering

            -- print("[AutoClutch] E key released. Performing double tap...") -- Uncomment for debug
            
            -- Perform two 'E' taps
            simulateKeyTap(Enum.KeyCode.E)
            task.wait(0.05) -- A slightly longer delay between taps to ensure distinct presses
            simulateKeyTap(Enum.KeyCode.E)
            
            -- print("[AutoClutch] Double tap completed.") -- Uncomment for debug
            isExecutingDoubleTap = false -- Reset flag after completion
        elseif input.KeyCode == Enum.KeyCode.E and not holdingE and isExecutingDoubleTap then
            -- This case handles if the user releases E again while our double-tap is happening.
            -- We don't want to re-trigger, but we should reset holdingE just in case.
            holdingE = false
        end
    end)
    print("[AutoClutch] Input listeners connected and AutoClutch is ON.")
end

--- Disconnects the AutoClutch input listeners and resets state.
-- This function is called as part of the unload process (toggled OFF).
local function disconnectAutoClutch()
    if inputBeganConn then
        pcall(function() inputBeganConn:Disconnect() end)
        inputBeganConn = nil
    end
    if inputEndedConn then
        pcall(function() inputEndedConn:Disconnect() end)
        inputEndedConn = nil
    end
    holdingE = false -- Ensure state is reset
    isExecutingDoubleTap = false -- Reset this flag too
    print("[AutoClutch] Input listeners disconnected and AutoClutch is OFF.")
end

--- Unloads the entire AutoClutch logic.
-- This function should be called when the main UI toggle is turned OFF.
local function unload()
    print("[AutoClutch] Unload function called. Disconnecting all connections.")
    disconnectAutoClutch() -- Ensure listeners are off
    if getgenv then
        getgenv().FZ_AutoClutchActive = nil
        getgenv().FZ_AutoClutchUnload = nil
    end
    print("[AutoClutch] Unload complete.")
end

-- Set unload function in getgenv for external calling
-- This ensures that if the script is loaded multiple times,
-- the previous instance can be properly unloaded.
if getgenv then
    getgenv().FZ_AutoClutchUnload = unload
end

-- Automatically connect the AutoClutch when this script is loaded.
-- This makes it compatible with your `loadstring(...)()` on toggle ON.
connectAutoClutch()

print("[AutoClutch] Script loaded successfully. AutoClutch is now active.")

-- Return the `unload` function. This is what 'autoclutchUnload' in your main script will receive.
return unload
