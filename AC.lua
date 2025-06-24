if getgenv and getgenv().FZ_AutoClutchUnload then
    getgenv().FZ_AutoClutchUnload()
    getgenv().FZ_AutoClutchUnload = nil
end

print("active22")

local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local holdingE = false
local inputBeganConn, inputEndedConn

inputBeganConn = UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.E and not holdingE then
        holdingE = true
    end
end)

inputEndedConn = UIS.InputEnded:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.E and holdingE then
        holdingE = false
        print("[AutoClutch] E released, tapping E 2 times!")
        for i = 1, 2 do
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.03)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            task.wait(0.03)
        end
    end
end)

local function unload()
    print("[AutoClutch] Unloading and disconnecting all connections.")
    if inputBeganConn then pcall(function() inputBeganConn:Disconnect() end) inputBeganConn = nil end
    if inputEndedConn then pcall(function() inputEndedConn:Disconnect() end) inputEndedConn = nil end
    holdingE = false
end

if getgenv then
    getgenv().FZ_AutoClutchUnload = unload
end

return unload
