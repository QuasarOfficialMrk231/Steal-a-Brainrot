-- Delta X Script by @Ew3qs
-- Полная версия для ПК и Телефона

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local savedPoint = nil
local flying = false
local autoAimEnabled = false
local noPlayerCollEnabled = false
local noWallsEnabled = false
local wallsStored = {}
local guiOpen = false

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 270)
MainFrame.Position = UDim2.new(0, 50, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false

local PlusButton = Instance.new("TextButton", ScreenGui)
PlusButton.Size = UDim2.new(0, 30, 0, 30)
PlusButton.Position = UDim2.new(0, 10, 0, 10)
PlusButton.Text = "+"
PlusButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PlusButton.TextColor3 = Color3.fromRGB(0, 255, 255)
PlusButton.MouseButton1Click:Connect(function()
    guiOpen = not guiOpen
    MainFrame.Visible = guiOpen
end)

local CoordsLabel = Instance.new("TextLabel", ScreenGui)
CoordsLabel.Size = UDim2.new(0, 200, 0, 15)
CoordsLabel.Position = UDim2.new(1, -210, 0, 5)
CoordsLabel.BackgroundTransparency = 1
CoordsLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
CoordsLabel.TextSize = 12
CoordsLabel.TextXAlignment = Enum.TextXAlignment.Right

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        CoordsLabel.Text = string.format("X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z)
    end
end)

local function CreateButton(name, posY, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 200, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.TextColor3 = Color3.fromRGB(0, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.MouseButton1Click:Connect(callback)
end

-- 1. Установить точку
CreateButton("Установить точку", 10, function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedPoint = LocalPlayer.Character.HumanoidRootPart.Position
    end
end)

-- 2. Удалить стены
CreateButton("Удалить стены", 40, function()
    noWallsEnabled = not noWallsEnabled
    if noWallsEnabled then
        for _,v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Position.Y > -5.1 then
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

-- 3. Телепорт к точке
CreateButton("Телепорт к точке", 70, function()
    if savedPoint and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(savedPoint))
    end
end)

-- 4. Полет к точке (бег + прыжки)
CreateButton("Полет к точке", 100, function()
    flying = not flying
    if flying and savedPoint and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local RootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        task.spawn(function()
            while flying and Humanoid and RootPart and savedPoint do
                local direction = Vector3.new(savedPoint.X, RootPart.Position.Y, savedPoint.Z) - RootPart.Position
                if direction.Magnitude < 1 then
                    flying = false
                    break
                end

                direction = direction.Unit
                Humanoid:Move(Vector3.new(direction.X, 0, direction.Z), false)

                if Humanoid.FloorMaterial ~= Enum.Material.Air then
                    Humanoid.Jump = true
                end

                task.wait(0.1)
            end
        end)
    end
end)

-- 5. Переподключение к серверу
CreateButton("Переподключение", 130, function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)

-- 6. AutoAim
CreateButton("AutoAim", 160, function()
    autoAimEnabled = not autoAimEnabled
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if autoAimEnabled and not gameProcessed then
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and (tool.Name:lower():find("laser") or tool.Name:lower():find("cape") or tool.Name:lower():find("taser") or tool.Name:lower():find("hand")) then
                local closestTarget = nil
                local closestDist = math.huge
                for _,player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                        local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestTarget = player
                        end
                    end
                end
                if closestTarget then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, closestTarget.Character.HumanoidRootPart.Position)
                    task.wait(0.05)
                    tool:Activate()
                end
            end
        end
    end
end)

-- 7. NoPlayerColl (отключает коллизию игрока)
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
local AboutLabel = Instance.new("TextLabel", MainFrame)
AboutLabel.Size = UDim2.new(0, 200, 0, 25)
AboutLabel.Position = UDim2.new(0, 10, 0, 220)
AboutLabel.BackgroundTransparency = 1
AboutLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
AboutLabel.Text = "@Ew3qs | Поддержать: donationalerts.com/r/Ew3qs"
AboutLabel.TextSize = 10
AboutLabel.TextWrapped = true