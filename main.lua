local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local savedPosition = nil -- для сохранённой точки

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

-- Сохранить текущую позицию
local function SaveCurrentPosition()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        savedPosition = rootPart.Position
        print("Позиция сохранена:", savedPosition)
    end
end

-- Телепорт на сохранённую позицию
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

-- Перетаскивание GUI
local function MakeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos

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
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- GUI

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 30, 0, 30) -- чуть больше
ToggleButton.Position = UDim2.new(0, 10, 0, 200)
ToggleButton.Text = "+"
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 20
ToggleButton.Parent = ScreenGui

MakeDraggable(ToggleButton)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 150, 0, 210) -- под 6 кнопок
MainFrame.Position = UDim2.new(0, 50, 0, 180)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

MakeDraggable(MainFrame)

local function CreateButton(text, posY, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Parent = MainFrame
    return btn
end

local RoofButton = CreateButton("На крышу", 10, Color3.fromRGB(50, 100, 200))
local ForwardButton = CreateButton("Вперёд", 50, Color3.fromRGB(50, 150, 100))
local SpawnLowerButton = CreateButton("Ниже спавна", 90, Color3.fromRGB(200, 100, 50))
local SavePosButton = CreateButton("Сохранить точку", 130, Color3.fromRGB(100, 100, 200))
local TeleportSavedButton = CreateButton("Телепорт к точке", 170, Color3.fromRGB(100, 200, 200))
local ReconnectButton = CreateButton("Переподключиться", 210, Color3.fromRGB(170, 50, 50))

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

RoofButton.MouseButton1Click:Connect(TeleportToRoof)
ForwardButton.MouseButton1Click:Connect(TeleportForward)
SpawnLowerButton.MouseButton1Click:Connect(TeleportToSpawnLower)
SavePosButton.MouseButton1Click:Connect(SaveCurrentPosition)
TeleportSavedButton.MouseButton1Click:Connect(TeleportToSavedPosition)
ReconnectButton.MouseButton1Click:Connect(function()
    local TeleportService = game:GetService("TeleportService")
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)