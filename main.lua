-- Full Script for Steal a Brainrot by @Ew3qs
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local savedPoint = nil
local flightEnabled = false
local noPlayerCollEnabled = false
local noWallsEnabled = false
local wallsStored = {}

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 250)
MainFrame.Position = UDim2.new(0, 50, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false

-- Toggle Button (+)
local PlusButton = Instance.new("TextButton", ScreenGui)
PlusButton.Size = UDim2.new(0, 30, 0, 30)
PlusButton.Position = UDim2.new(0, 10, 0, 10)
PlusButton.Text = "+"
PlusButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PlusButton.TextColor3 = Color3.fromRGB(0, 255, 255)
PlusButton.Draggable = true
PlusButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Coordinates Display
local CoordsLabel = Instance.new("TextLabel", ScreenGui)
CoordsLabel.Size = UDim2.new(0, 200, 0, 20)
CoordsLabel.Position = UDim2.new(1, -210, 0, 10)
CoordsLabel.BackgroundTransparency = 1
CoordsLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
CoordsLabel.TextSize = 14
CoordsLabel.Text = ""

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        CoordsLabel.Text = string.format("X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z)
    end
end)

-- Buttons
local function CreateButton(name, posY, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 200, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.TextColor3 = Color3.fromRGB(0, 255, 255)
    btn.MouseButton1Click:Connect(callback)
end

-- Save Point
CreateButton("Поставить точку", 40, function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedPoint = LocalPlayer.Character.HumanoidRootPart.Position
    end
end)

-- Teleport to Point
CreateButton("Телепорт к точке", 70, function()
    if savedPoint and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(savedPoint)
    end
end)

-- Reconnect
CreateButton("Переподключиться", 100, function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)

-- Toggle NoplayerColl
CreateButton("NoPlayerColl", 130, function()
    noPlayerCollEnabled = not noPlayerCollEnabled
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = not noPlayerCollEnabled
            end
        end
    end
end)

-- Toggle Remove Walls
CreateButton("Удалить стены", 160, function()
    noWallsEnabled = not noWallsEnabled
    if noWallsEnabled then
        for _,v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Position.Y > -5.1 and string.find(v.Name:lower(), "wall") then
                table.insert(wallsStored, v)
                v.Transparency = 0.7
                v.CanCollide = false
            end
        end
    else
        for _,v in pairs(wallsStored) do
            if v and v:IsA("BasePart") then
                v.Transparency = 0
                v.CanCollide = true
            end
        end
        wallsStored = {}
    end
end)

-- Fly to Point (bounce floor)
local flying = false
CreateButton("Полет к точке", 190, function()
    flying = not flying
    if flying then
        task.spawn(function()
            while flying do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and savedPoint then
                    local root = LocalPlayer.Character.HumanoidRootPart
                    local direction = (savedPoint - root.Position).Unit
                    local distance = (savedPoint - root.Position).Magnitude
                    local moveStep = math.min(10, distance)
                    root.CFrame = root.CFrame + Vector3.new(direction.X * moveStep, 0, direction.Z * moveStep)
                    local rayOrigin = root.Position
                    local rayDirection = Vector3.new(0, -10, 0)
                    local ray = Workspace:Raycast(rayOrigin, rayDirection)
                    if ray and ray.Position.Y <= -6.8 then
                        root.CFrame = root.CFrame + Vector3.new(0, 44, 0)
                        task.wait(0.2)
                    end
                end
                task.wait(0.01)
            end
        end)
    end
end)

-- Autoaim
CreateButton("AutoAim", 220, function()
    task.spawn(function()
        while true do
            task.wait(0.1)
            local closestPlayer = nil
            local shortestDistance = math.huge
            for _,player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
            if closestPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, closestPlayer.Character.HumanoidRootPart.Position)
            end
        end
    end)
end)

-- About Button
local AboutButton = Instance.new("TextButton", MainFrame)
AboutButton.Size = UDim2.new(0, 200, 0, 25)
AboutButton.Position = UDim2.new(0, 10, 0, 250)
AboutButton.Text = "Об авторе"
AboutButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
AboutButton.TextColor3 = Color3.fromRGB(0, 255, 255)
AboutButton.MouseButton1Click:Connect(function()
    setclipboard("https://www.donationalerts.com/r/ew3qs")
end)