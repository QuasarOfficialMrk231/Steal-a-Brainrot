local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- UI Elements
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 300)
MainFrame.Position = UDim2.new(0, 20, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true

local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 30, 0, 30)
ToggleButton.Position = UDim2.new(0, 20, 0, 60)
ToggleButton.Text = "+"
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 20

local CoordLabel = Instance.new("TextLabel", ScreenGui)
CoordLabel.Size = UDim2.new(0, 300, 0, 25)
CoordLabel.Position = UDim2.new(0.5, -150, 0, 10)
CoordLabel.BackgroundTransparency = 1
CoordLabel.TextColor3 = Color3.new(1,1,1)
CoordLabel.Font = Enum.Font.SourceSansBold
CoordLabel.TextSize = 20
CoordLabel.Text = "Position: (0,0,0)"

-- Toggle GUI Visibility
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Save/TP Point Variables
local savedPoint = nil
local flyEnabled = false
local noWallState = false
local noCollidePlayers = false

-- Save Point Button
local SavePointBtn = Instance.new("TextButton", MainFrame)
SavePointBtn.Size = UDim2.new(0, 180, 0, 25)
SavePointBtn.Position = UDim2.new(0, 10, 0, 10)
SavePointBtn.Text = "Save Point"
SavePointBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
SavePointBtn.TextColor3 = Color3.new(1,1,1)

SavePointBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        savedPoint = char.HumanoidRootPart.Position
    end
end)

-- Teleport to Saved Point Button
local TPPointBtn = Instance.new("TextButton", MainFrame)
TPPointBtn.Size = UDim2.new(0, 180, 0, 25)
TPPointBtn.Position = UDim2.new(0, 10, 0, 40)
TPPointBtn.Text = "Teleport to Point"
TPPointBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
TPPointBtn.TextColor3 = Color3.new(1,1,1)

TPPointBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if savedPoint and char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(savedPoint)
    end
end)

-- Flight Button (with floor collision bump)
local FlyBtn = Instance.new("TextButton", MainFrame)
FlyBtn.Size = UDim2.new(0, 180, 0, 25)
FlyBtn.Position = UDim2.new(0, 10, 0, 70)
FlyBtn.Text = "Start/Stop Fly"
FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
FlyBtn.TextColor3 = Color3.new(1,1,1)

FlyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
end)

-- NoPlayerColl Button
local NoPlayerCollBtn = Instance.new("TextButton", MainFrame)
NoPlayerCollBtn.Size = UDim2.new(0, 180, 0, 25)
NoPlayerCollBtn.Position = UDim2.new(0, 10, 0, 100)
NoPlayerCollBtn.Text = "Toggle NoPlayerColl"
NoPlayerCollBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
NoPlayerCollBtn.TextColor3 = Color3.new(1,1,1)

NoPlayerCollBtn.MouseButton1Click:Connect(function()
    noCollidePlayers = not noCollidePlayers
end)

-- Remove Walls Button
local RemoveWallsBtn = Instance.new("TextButton", MainFrame)
RemoveWallsBtn.Size = UDim2.new(0, 180, 0, 25)
RemoveWallsBtn.Position = UDim2.new(0, 10, 0, 130)
RemoveWallsBtn.Text = "Toggle Remove Walls"
RemoveWallsBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
RemoveWallsBtn.TextColor3 = Color3.new(1,1,1)

RemoveWallsBtn.MouseButton1Click:Connect(function()
    noWallState = not noWallState
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Position.Y > 1 and string.find(obj.Name:lower(), "wall") then
            obj.Transparency = noWallState and 1 or 0
            obj.CanCollide = not noWallState
        end
    end
end)

-- Rejoin Server Button
local RejoinBtn = Instance.new("TextButton", MainFrame)
RejoinBtn.Size = UDim2.new(0, 180, 0, 25)
RejoinBtn.Position = UDim2.new(0, 10, 0, 160)
RejoinBtn.Text = "Reconnect Server"
RejoinBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
RejoinBtn.TextColor3 = Color3.new(1,1,1)

RejoinBtn.MouseButton1Click:Connect(function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)

-- Update Loop
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        CoordLabel.Text = string.format("Position: (%.1f, %.1f, %.1f)", pos.X, pos.Y, pos.Z)

        if flyEnabled and savedPoint then
            local rootPart = char.HumanoidRootPart
            local direction = (savedPoint - rootPart.Position).Unit
            rootPart.Velocity = Vector3.new(direction.X * 50, 0, direction.Z * 50)

            local rayOrigin = rootPart.Position
            local rayDirection = Vector3.new(0, -5, 0)
            local ray = Ray.new(rayOrigin, rayDirection)
            local hit = Workspace:FindPartOnRay(ray, char)

            if hit then
                rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 44, 0)
            end
        end

        -- NoPlayerColl
        if noCollidePlayers then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end)