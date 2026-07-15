local hub = {
    name = "Pruzgar Hub Clean",
    version = "1.7.2"
}

local gui = Instance.new("ScreenGui")
gui.Name = "Pruzgar Hub"
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 400, 0, 300)
main.Position = UDim2.new(0.5, -200, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.Parent = gui

local topbar = Instance.new("TextLabel")
topbar.Size = UDim2.new(1, 0, 0, 25)
topbar.Text = "Pruzgar Hub v1.7.2"
topbar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
topbar.TextColor3 = Color3.fromRGB(255, 255, 255)
topbar.Font = Enum.Font.SourceSansBold
topbar.TextSize = 14
topbar.Parent = main

local function createButton(text, posY, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.Parent = main
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createToggle(text, posY, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.Position = UDim2.new(0, 10, 0, posY)
    frame.BackgroundTransparency = 1
    frame.Parent = main

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local enabled = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 22)
    btn.Position = UDim2.new(1, -45, 0, 6)
    btn.Text = "OFF"
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.Parent = frame

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            btn.Text = "ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
        else
            btn.Text = "OFF"
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
        callback(enabled)
    end)
end

createToggle("Aimbot", 35, function(state)
    if state then
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Pruzgar Hub", Text = "Aimbot ON"})
    end
end)

createToggle("ESP", 75, function(state)
    if state then
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Pruzgar Hub", Text = "ESP ON"})
    end
end)

createToggle("Fly", 115, function(state)
    if state then
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        hum.PlatformStand = true
        task.spawn(function()
            while state do
                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dir = workspace.CurrentCamera.CFrame.LookVector
                    root.Velocity = Vector3.new(dir.X * 50, dir.Y * 50, dir.Z * 50)
                end
                task.wait()
            end
            if player.Character then
                player.Character:FindFirstChild("Humanoid").PlatformStand = false
            end
        end)
    end
end)

createButton("Speed 100", 155, Color3.fromRGB(50, 50, 200), function()
    local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = 100 end
end)

createButton("Jump 150", 195, Color3.fromRGB(50, 50, 200), function()
    local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.JumpPower = 150 end
end)

return hub
