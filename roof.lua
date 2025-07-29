local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function TeleportToRoof()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local newPosition = Vector3.new(rootPart.Position.X, 300, rootPart.Position.Z) -- Поменяй 300 на высоту своей крыши
        rootPart.CFrame = CFrame.new(newPosition)
    end
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RoofTeleportGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Кнопка на экране
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 30, 0, 30) -- маленькая кнопка как крестик
Button.Position = UDim2.new(0, 10, 0, 300)
Button.Text = "↑"
Button.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
Button.TextColor3 = Color3.new(1,1,1)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 18
Button.Parent = ScreenGui

-- Логика нажатия
Button.MouseButton1Click:Connect(function()
    TeleportToRoof()
end)
