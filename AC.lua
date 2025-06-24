-- Prevent multiple instances
if getgenv then
    if getgenv().FZ_AutoClutchUnload then
        getgenv().FZ_AutoClutchUnload()
        getgenv().FZ_AutoClutchUnload = nil
    end
    if getgenv().FZ_AutoClutchActive then
        -- Already running, don't run again
        return function() end
    end
    getgenv().FZ_AutoClutchActive = true
end

print("[AutoClutch] Activated")

local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local holdingE = false
local tappedThisRelease = false
local inputBeganConn, inputEndedConn

inputBeganConn = UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.E and not holdingE then
        holdingE = true
        tappedThisRelease = false
    end
end)

inputEndedConn = UIS.InputEnded:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.E and holdingE then
        holdingE = false
        if not tappedThisRelease then
            tappedThisRelease = true
            print("[AutoClutch] E released, tapping E 2 times!")
            task.spawn(function()
                for i = 1, 2 do
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.03)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(0.03)
                end
                tappedThisRelease = false
            end)
        end
    end
end)

-- Unload function
local function unload()
    print("[AutoClutch] Unloading and disconnecting all connections.")
    if inputBeganConn then pcall(function() inputBeganConn:Disconnect() end) inputBeganConn = nil end
    if inputEndedConn then pcall(function() inputEndedConn:Disconnect() end) inputEndedConn = nil end
    holdingE = false
    tappedThisRelease = false
    if getgenv then
        getgenv().FZ_AutoClutchActive = nil
        getgenv().FZ_AutoClutchUnload = nil
    end
end

if getgenv then
    getgenv().FZ_AutoClutchUnload = unload
end

return unload
