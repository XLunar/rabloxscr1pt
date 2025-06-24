return function()
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    local LocalPlayer = Players.LocalPlayer
    local holdingE = false
    local tappedThisRelease = false
    local inputBeganConn, inputEndedConn

    -- Helper: Get the bar (customize if needed)
    local function getBar()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then print("[AutoClutch] PlayerGui not found!") return nil end
        local shotGui = playerGui:FindFirstChild("ShotMeterUI_Vertical")
        if not shotGui then print("[AutoClutch] ShotMeterUI_Vertical not found!") return nil end
        local canvas = shotGui:FindFirstChild("Canvas")
        if not canvas then print("[AutoClutch] Canvas not found!") return nil end
        local meter = canvas:FindFirstChild("Meter")
        if not meter then print("[AutoClutch] Meter not found!") return nil end
        local bar = meter:FindFirstChild("Bar")
        if not bar or not bar:IsA("Frame") then print("[AutoClutch] Bar not found or not a Frame!") return nil end
        return bar
    end

    inputBeganConn = UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.E and not holdingE then
            holdingE = true
            tappedThisRelease = false
            print("[AutoClutch] E pressed.")
        end
    end)

    inputEndedConn = UIS.InputEnded:Connect(function(input, processed)
        if input.KeyCode == Enum.KeyCode.E and holdingE and not tappedThisRelease then
            holdingE = false
            tappedThisRelease = true
            print("[AutoClutch] E released, tapping E instantly.")
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.01)  -- Reduced wait time to prevent spamming
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            print("[AutoClutch] Tapped E after release!")
        end
    end)

    -- Unload function (safe disconnect)
    return function()
        print("[AutoClutch] Unloading and disconnecting all connections.")
        if inputBeganConn then pcall(function() inputBeganConn:Disconnect() end) inputBeganConn = nil end
        if inputEndedConn then pcall(function() inputEndedConn:Disconnect() end) inputEndedConn = nil end
        holdingE = false
        tappedThisRelease = false
    end
end
