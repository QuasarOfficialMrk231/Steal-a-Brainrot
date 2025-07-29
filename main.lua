local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- Variables
local savedPoint = nil
local flyEnabled = false
local teleportLoopEnabled = false
local wallRemoved = false
local noPlayerColl = false

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 320)
MainFrame.Position = UDim2.new(0, 100, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Active = true
MainFrame.Draggable = true

local btnToggleGUI = Instance.new("TextButton", ScreenGui)
btnToggleGUI.Size = UDim2.new(0, 40, 0, 40)
btnToggleGUI.Position = UDim2.new(0, 0, 0, 100)
btnToggleGUI.Text = "+"
btnToggleGUI.BackgroundColor3 = Color3.fromRGB(0, 170, 170)
btnToggleGUI.TextColor3 = Color3.new(1,1,1)
btnToggleGUI.Font = Enum.Font.SourceSansBold
btnToggleGUI.TextSize = 24
btnToggleGUI.Active = true
btnToggleGUI.Draggable = true

btnToggleGUI.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

MainFrame.Visible = false

-- Function to create small buttons
local function createButton(name, posY, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 220, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.MouseButton1Click:Connect(callback)
end

-- Coordinates Display
local coordLabel = Instance.new("TextLabel", ScreenGui)
coordLabel.Size = UDim2.new(0, 300, 0, 20)
coordLabel.Position = UDim2.new(1, -310, 0, 10)
coordLabel.Text = "X=0 Y=0 Z=0"
coordLabel.BackgroundTransparency = 1
coordLabel.TextColor3 = Color3.new(1,1,1)
coordLabel.Font = Enum.Font.SourceSans
coordLabel.TextSize = 14

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        coordLabel.Text = string.format("X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z)
    end
end)

-- Save Point Button
createButton("Поставить Точку", 10, function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedPoint = LocalPlayer.Character.HumanoidRootPart.Position
    end
end)

-- Teleport to Point Loop
createButton("Телепорт К Точке", 40, function()
    teleportLoopEnabled = not teleportLoopEnabled
    while teleportLoopEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(savedPoint.X, savedPoint.Y, savedPoint.Z)
        task.wait(0.25)
    end
end)

-- Reconnect to Current Server
createButton("Переподключиться", 70, function()
    TeleportService:Teleport(game.PlaceId)
end)

-- Fly with Ground Touch Every 0.2 sec
createButton("Включить Полет", 100, function()
    flyEnabled = not flyEnabled
    while flyEnabled do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(savedPoint.X, hrp.Position.Y, savedPoint.Z), 0.1)
            if hrp.Position.Y <= -6.8 then
                task.wait(0.2)
                hrp.CFrame = CFrame.new(hrp.Position.X, 44, hrp.Position.Z)
            end
        end
        task.wait(0.1)
    end
end)
-- NoPlayerColl Toggle
createButton("NoPlayerColl", 130, function()
    noPlayerColl = not noPlayerColl
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noPlayerColl
            end
        end
    end
end)

-- Remove/Restore Walls Above -5.1
createButton("Удалить Стены", 160, function()
    wallRemoved = not wallRemoved
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Position.Y > -5.1 or string.find(obj.Name, "wall")) then
            if wallRemoved then
                obj.Transparency = 0.8
                obj.CanCollide = false
            else
                obj.Transparency = 0
                obj.CanCollide = true
            end
        end
    end
end)

-- AutoAim Functionality
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        local closestTarget = nil
        local closestDist = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestTarget = player
                end
            end
        end
        if closestTarget and tool:FindFirstChild("Handle") then
            tool.Handle.CFrame = CFrame.lookAt(tool.Handle.Position, closestTarget.Character.HumanoidRootPart.Position)
        end
    end
end)

-- About Author Label
local aboutLabel = Instance.new("TextLabel", ScreenGui)
aboutLabel.Size = UDim2.new(0, 220, 0, 20)
aboutLabel.Position = UDim2.new(0, 100, 0, 80)
aboutLabel.Text = "Автор: @Ew3qs | https://www.donationalerts.com/r/ew3qs"
aboutLabel.BackgroundTransparency = 1
aboutLabel.TextColor3 = Color3.new(1,1,1)
aboutLabel.Font = Enum.Font.SourceSans
aboutLabel.TextSize = 12