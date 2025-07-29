local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Телепорт на крышу (Y = 300)
local function TeleportToRoof()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local newPosition = Vector3.new(rootPart.Position.X, 300, rootPart.Position.Z)
        rootPart.CFrame = CFrame.new(newPosition)
    end
end

-- Телепорт вперёд на 10 шагов
local function TeleportForward()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local forwardVector = Camera.CFrame.LookVector * 10
        local newPosition = rootPart.Position + Vector3.new(forwardVector.X, 0, forwardVector.Z)
        rootPart.CFrame = CFrame.new(newPosition)
    end
end

-- Телепорт ниже спавна на 3 единицы
local function TeleportToSpawnLower()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local spawnPos = rootPart.Position
        local newPosition = Vector3.new(spawnPos.X, spawnPos.Y - 3, spawnPos.Z)
        rootPart.CFrame = CFrame.new(newPosition)
    end
end

-- GUI

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 20, 0, 20)
ToggleButton.Position = UDim2.new(0, 10, 0, 200)
ToggleButton.Text = "+"
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 140, 0, 150)
MainFrame.Position = UDim2.new(0, 40, 0, 180)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local RoofButton = Instance.new("TextButton")
RoofButton.Size = UDim2.new(0, 120, 0, 30)
RoofButton.Position = UDim2.new(0, 10, 0, 10)
RoofButton.Text = "На крышу"
RoofButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
RoofButton.TextColor3 = Color3.new(1,1,1)
RoofButton.Font = Enum.Font.SourceSansBold
RoofButton.TextSize = 18
RoofButton.Parent = MainFrame

local ForwardButton = Instance.new("TextButton")
ForwardButton.Size = UDim2.new(0, 120, 0, 30)
ForwardButton.Position = UDim2.new(0, 10, 0, 50)
ForwardButton.Text = "Вперёд"
ForwardButton.BackgroundColor3 = Color3.fromRGB(50, 150, 100)
ForwardButton.TextColor3 = Color3.new(1,1,1)
ForwardButton.Font = Enum.Font.SourceSansBold
ForwardButton.TextSize = 18
ForwardButton.Parent = MainFrame

local SpawnLowerButton = Instance.new("TextButton")
SpawnLowerButton.Size = UDim2.new(0, 120, 0, 30)
SpawnLowerButton.Position = UDim2.new(0, 10, 0, 90)
SpawnLowerButton.Text = "Ниже спавна"
SpawnLowerButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
SpawnLowerButton.TextColor3 = Color3.new(1,1,1)
SpawnLowerButton.Font = Enum.Font.SourceSansBold
SpawnLowerButton.TextSize = 18
SpawnLowerButton.Parent = MainFrame

local ReconnectButton = Instance.new("TextButton")
ReconnectButton.Size = UDim2.new(0, 120, 0, 30)
ReconnectButton.Position = UDim2.new(0, 10, 0, 130)
ReconnectButton.Text = "Переподключиться"
ReconnectButton.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
ReconnectButton.TextColor3 = Color3.new(1,1,1)
ReconnectButton.Font = Enum.Font.SourceSansBold
ReconnectButton.TextSize = 18
ReconnectButton.Parent = MainFrame

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

RoofButton.MouseButton1Click:Connect(function()
    TeleportToRoof()
end)

ForwardButton.MouseButton1Click:Connect(function()
    TeleportForward()
end)

SpawnLowerButton.MouseButton1Click:Connect(function()
    TeleportToSpawnLower()
end)

ReconnectButton.MouseButton1Click:Connect(function()
    local TeleportService = game:GetService("TeleportService")
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
