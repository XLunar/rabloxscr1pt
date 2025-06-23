local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Macro keybinds (replace with your UI's keybinds table)
local macroKeybinds = {
    ["Spin"] = Enum.KeyCode.B, -- Example: Spin is bound to B
    ["Behind Back"] = Enum.KeyCode.N,
    ["Back Hesitation"] = Enum.KeyCode.M,
    ["Double Cross"] = Enum.KeyCode.K,
    ["Double Behind Back"] = Enum.KeyCode.L,
    ["Cross Back"] = Enum.KeyCode.J,
    ["Under Front"] = Enum.KeyCode.H,
    ["Under Back"] = Enum.KeyCode.G,
    ["Under Side"] = Enum.KeyCode.F,
    ["Under Double"] = Enum.KeyCode.T,
}

-- Macro sequences for left/right hand
local macroSequences = {
    ["Spin"] = {Left = {"Z","X","C"}, Right = {"C","X","Z"}},
    ["Behind Back"] = {Left = {"Z","X"}, Right = {"C","X"}},
    ["Back Hesitation"] = {Left = {"Z","V"}, Right = {"V","Z"}},
    ["Double Cross"] = {Left = {"Z","Z"}, Right = {"C","C"}},
    ["Double Behind Back"] = {Left = {"Z","X","X"}, Right = {"C","X","X"}},
    ["Cross Back"] = {Left = {"X","X"}, Right = {"X","X"}},
    ["Under Front"] = {Left = {"V","V"}, Right = {"V","V"}},
    ["Under Back"] = {Left = {"V","X"}, Right = {"V","X"}},
    ["Under Side"] = {Left = {"V"}, Right = {"V","C"}},
    ["Under Double"] = {Left = {"V","Z","Z"}, Right = {"V","C","C"}},
}

-- Helper: Get closest basketball to character
local function getClosestBasketball(char)
    local closestBall, shortestDist = nil, math.huge
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "Basketball" and obj:IsA("BasePart") then
            local dist = (obj.Position - char.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closestBall = obj
            end
        end
    end
    return closestBall
end

-- Helper: Detect which hand the ball is in
local function getBallHand()
    local char = workspace:FindFirstChild(LocalPlayer.Name)
    if not char then return nil end
    local leftHand = char:FindFirstChild("LeftHand")
    local rightHand = char:FindFirstChild("RightHand")
    if not (leftHand and rightHand) then return nil end
    local ball = getClosestBasketball(char)
    if not ball then return nil end

    local leftDist = (ball.Position - leftHand.Position).Magnitude
    local rightDist = (ball.Position - rightHand.Position).Magnitude

    if math.abs(leftDist - rightDist) < 0.1 then
        return "Center"
    elseif leftDist < rightDist then
        return "Left"
    else
        return "Right"
    end
end

-- Helper: Simulate keypresses
local function pressKeys(keys)
    for _, key in ipairs(keys) do
        local keyEnum = Enum.KeyCode[key]
        if keyEnum then
            VirtualInputManager:SendKeyEvent(true, keyEnum, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, keyEnum, false, game)
            task.wait(0.05)
        end
    end
end

-- Macro enable toggle (sync this with your UI)
local macrosEnabled = true

-- Listen for macro keybinds
local macroConn
local function enableMacros()
    if macroConn then macroConn:Disconnect() end
    macroConn = UserInputService.InputBegan:Connect(function(input, processed)
        if not macrosEnabled or processed then return end
        for macroName, key in pairs(macroKeybinds) do
            if input.KeyCode == key then
                local hand = getBallHand()
                if hand == "Left" or hand == "Right" then
                    local seq = macroSequences[macroName] and macroSequences[macroName][hand]
                    if seq then
                        pressKeys(seq)
                    end
                end
                break
            end
        end
    end)
end

local function disableMacros()
    if macroConn then
        macroConn:Disconnect()
        macroConn = nil
    end
end

-- Enable macros by default (call enableMacros() when toggled on, disableMacros() when toggled off)
enableMacros()

-- Return unload function for UI toggle support
return function()
    disableMacros()
end
