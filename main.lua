-- Full Script for Steal a Brainrot by @Ew3qs
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local savedPoint = nil
local flying = false
local autoAimEnabled = false
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

-- Coordinates Display (Top Right Corner)
local CoordsLabel = Instance.new("TextLabel", ScreenGui)
CoordsLabel.Size = UDim2.new(0, 200, 0, 15)
CoordsLabel.Position = UDim2.new(1, -210, 0, 5)
CoordsLabel.BackgroundTransparency = 1
CoordsLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
CoordsLabel.TextSize = 12
CoordsLabel.Text = ""

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        CoordsLabel.Text = string.format("X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z)
    end
end)

-- Buttons Function
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
CreateButton("Установить точку", 10, function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedPoint = LocalPlayer.Character.HumanoidRootPart.Position
    end
end)

-- Удалить стены
CreateButton("Удалить стены", 40, function()
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

-- Телепорт к точке
CreateButton("Телепорт к точке", 70, function()
    if savedPoint and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(savedPoint)
    end
end)

-- Полет к точке (пешком)
CreateButton("Полет к точке", 100, function()
    if savedPoint and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        flying = not flying
        local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local RootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if flying then
            task.spawn(function()
                while flying and Humanoid and RootPart do
                    local direction = (Vector3.new(savedPoint.X, RootPart.Position.Y, savedPoint.Z) - RootPart.Position).Unit
                    local distance = (Vector3.new(savedPoint.X, RootPart.Position.Y, savedPoint.Z) - RootPart.Position).Magnitude
                    
                    Humanoid:Move(Vector3.new(direction.X, 0, direction.Z), false)
                    
                    -- Прыжок если на земле
                    if Humanoid.FloorMaterial ~= Enum.Material.Air then
                        Humanoid.Jump = true
                    end
                    
                    if distance < 3 then
                        flying = false
                        Humanoid:Move(Vector3.zero, false)
                    end
                    
                    task.wait(0.1)
                end
            end)
        else
            Humanoid:Move(Vector3.zero, false)
        end
    end
end)

-- Переподключение
CreateButton("Переподключение", 130, function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)

-- AutoAim
CreateButton("AutoAim", 160, function()
    autoAimEnabled = not autoAimEnabled
end)

-- NoPlayerColl
CreateButton("NoPlayerColl", 190, function()
    noPlayerCollEnabled = not noPlayerCollEnabled
    if LocalPlayer.Character then
        for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = not noPlayerCollEnabled
            end
        end
    end
end)

-- Об авторе
local AboutLabel = Instance.new("TextButton", MainFrame)
AboutLabel.Size = UDim2.new(0, 200, 0, 25)
AboutLabel.Position = UDim2.new(0, 10, 0, 220)
AboutLabel.Text = "@Ew3qs | Поддержать автора"
AboutLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
AboutLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
AboutLabel.MouseButton1Click:Connect(function()
    setclipboard("https://www.donationalerts.com/r/Ew3qs")
end)

-- AutoAim Execution on Tap/Click
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if autoAimEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        
        if closestPlayer and LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Activate") then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, closestPlayer.Character.HumanoidRootPart.Position)
                tool:Activate()
            elseif tool then
                tool:Activate()
            end
        end
    end
end)