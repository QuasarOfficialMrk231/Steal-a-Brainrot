local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local savedPosition = nil -- сохранённая точка

-- ===== Функции Телепорта =====
local function TeleportToRoof()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local newPosition = Vector3.new(rootPart.Position.X, 300, rootPart.Position.Z)
        rootPart.CFrame = CFrame.new(newPosition)
    end
end

local function TeleportForward()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local forwardVector = Camera.CFrame.LookVector * 10
        local newPosition = rootPart.Position + Vector3.new(forwardVector.X, 0, forwardVector.Z)
        rootPart.CFrame = CFrame.new(newPosition)
    end
end

local function TeleportToSpawnLower()
    local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
    if spawnLocation then
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local spawnPos = spawnLocation.Position
            local newPosition = Vector3.new(spawnPos.X, spawnPos.Y - 3, spawnPos.Z)
            rootPart.CFrame = CFrame.new(newPosition)
        end
    else
        warn("SpawnLocation не найден!")
    end
end

local function SaveCurrentPosition()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        savedPosition = rootPart.Position
        print("Позиция сохранена:", savedPosition)
    end
end

local function TeleportToSavedPosition()
    if savedPosition then
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = CFrame.new(savedPosition)
        end
    else
        warn("Позиция не сохранена!")
    end
end

local function Reconnect()
    local TeleportService = game:GetService("TeleportService")
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- ====== Перетаскивание GUI ======
local function MakeDraggable(guiObject)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        guiObject.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            update(UserInputService:GetMouseLocation())
        end
    end)
end

-- ===== GUI Elements =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 30, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 200)
ToggleButton.Text = "+"
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 20
ToggleButton.BorderSizePixel = 0
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = ScreenGui

MakeDraggable(ToggleButton)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 160, 0, 270)
MainFrame.Position = UDim2.new(0, 50, 0, 180)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

MakeDraggable(MainFrame)

local function CreateButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(0, 200, 200)
    end)
    btn.Parent = MainFrame
    return btn
end

local RoofButton = CreateButton("На крышу", 10)
local ForwardButton = CreateButton("Вперёд", 50)
local SpawnLowerButton = CreateButton("Ниже спавна", 90)
local SavePosButton = CreateButton("Сохранить точку", 130)
local TeleportSavedButton = CreateButton("Телепорт к точке", 170)
local ReconnectButton = CreateButton("Переподключиться", 210)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

RoofButton.MouseButton1Click:Connect(TeleportToRoof)
ForwardButton.MouseButton1Click:Connect(TeleportForward)
SpawnLowerButton.MouseButton1Click:Connect(TeleportToSpawnLower)
SavePosButton.MouseButton1Click:Connect(SaveCurrentPosition)
TeleportSavedButton.MouseButton1Click:Connect(TeleportToSavedPosition)
ReconnectButton.MouseButton1Click:Connect(Reconnect)