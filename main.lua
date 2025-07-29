-- Delta X Universal Script by @Ew3qs
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local savedPoint = nil
local flying = false
local noPlayerCollEnabled = false
local noWallsEnabled = false
local autoAimEnabled = false
local wallsStored = {}

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 270)
MainFrame.Position = UDim2.new(0, 50, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false

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

local CoordsLabel = Instance.new("TextLabel", ScreenGui)
CoordsLabel.Size = UDim2.new(0, 200, 0, 15)
CoordsLabel.Position = UDim2.new(1, -210, 0, 5)
CoordsLabel.BackgroundTransparency = 1
CoordsLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
CoordsLabel.TextSize = 10
CoordsLabel.Text = ""

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        CoordsLabel.Text = string.format("X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z)
    end
end)

local AuthorLabel = Instance.new("TextLabel", MainFrame)
AuthorLabel.Size = UDim2.new(0, 200, 0, 15)
AuthorLabel.Position = UDim2.new(0, 10, 0, 5)
AuthorLabel.BackgroundTransparency = 1
AuthorLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
AuthorLabel.TextSize = 10
AuthorLabel.Text = "@Ew3qs | Поддержать: donationalerts.com/r/Ew3qs"

local function CreateButton(name, posY, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 200, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    btn.MouseButton1Click:Connect(callback)
end

-- Save Point
CreateButton("Установить точку", 30, function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedPoint = LocalPlayer.Character.HumanoidRootPart.Position
    end
end)

-- Remove Walls
CreateButton("Удалить стены", 60, function()
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

-- Teleport to Point
CreateButton("Телепорт к точке", 90, function()
    if savedPoint and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(savedPoint)
    end
end)

-- Bounce Fly
CreateButton("Полет к точке", 120, function()
    flying = not flying
    if flying then
        task.spawn(function()
            while flying do
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and savedPoint then
                    local root = LocalPlayer.Character.HumanoidRootPart
                    local moveDir = Vector3.new(savedPoint.X - root.Position.X, 0, savedPoint.Z - root.Position.Z)
                    if moveDir.Magnitude > 1 then
                        local direction = moveDir.Unit * 16 * RunService.RenderStepped:Wait()
                        root.CFrame = root.CFrame + direction
                    end
                    if root.Position.Y <= -6.8 then
                        root.CFrame = root.CFrame + Vector3.new(0, 44, 0)
                        task.wait(0.4)
                    end
                end
                task.wait(0.01)
            end
        end)
    end
end)

-- Reconnect
CreateButton("Переподключение", 150, function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)

-- AutoAim Shot
CreateButton("AutoAim", 180, function()
    autoAimEnabled = not autoAimEnabled
end)

RunService.RenderStepped:Connect(function()
    if autoAimEnabled and LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and (tool.Name:lower():find("laser") or tool.Name:lower():find("cape") or tool.Name:lower():find("taser")) then
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
            if closestPlayer then
                local root = LocalPlayer.Character.HumanoidRootPart
                root.CFrame = CFrame.lookAt(root.Position, Vector3.new(closestPlayer.Character.HumanoidRootPart.Position.X, root.Position.Y, closestPlayer.Character.HumanoidRootPart.Position.Z))
                tool:Activate()
            end
        end
    end
end)

-- NoPlayerColl
CreateButton("NoPlayerColl", 210, function()
    noPlayerCollEnabled = not noPlayerCollEnabled
    if LocalPlayer.Character then
        for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = not noPlayerCollEnabled
            end
        end
    end
end)