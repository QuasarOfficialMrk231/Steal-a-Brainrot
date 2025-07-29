local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local savedPosition = nil
local flying = false
local noPlayerCollEnabled = false

-- Сохраняем текущую точку
local function SaveCurrentPosition()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        savedPosition = rootPart.Position
        print("Точка сохранена:", savedPosition)
    end
end

-- Переподключение к серверу
local function RejoinServer()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- Телепорт к сохранённой точке
local function TeleportToSavedPosition()
    if savedPosition then
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = CFrame.new(savedPosition)
        end
    end
end

-- Проверка касания пола
local function IsTouchingGround(character)
    local rayOrigin = character.HumanoidRootPart.Position
    local rayDirection = Vector3.new(0, -5, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    return result ~= nil
end

-- Полёт к точке с ударами об пол
local function StartFlying()
    if flying then return end
    flying = true
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")

    spawn(function()
        while flying do
            if savedPosition then
                local currentPos = rootPart.Position
                local direction = (savedPosition - currentPos).Unit
                rootPart.CFrame = CFrame.new(currentPos + direction * 2)

                if IsTouchingGround(character) then
                    rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 44, 0)
                    wait(0.05)
                    rootPart.CFrame = rootPart.CFrame - Vector3.new(0, 1, 0)
                end
            end
            wait(0.1)
        end
    end)
end

local function StopFlying()
    flying = false
end

-- Удаление стен (визуально и физически)
local function RemoveWalls()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if not string.find(obj.Name:lower(), "floor") and not string.find(obj.Name:lower(), "ground") then
                obj.Transparency = 1
                obj.CanCollide = false
            end
        end
    end
    print("Стены убраны")
end

-- Включение/выключение коллизий с игроками
local function NoPlayerCollisions(enable)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enable
            part.Massless = enable
            part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
        end
    end
    noPlayerCollEnabled = enable
    print("NoPlayerCollisions", enable and "ВКЛЮЧЕНЫ" or "ВЫКЛЮЧЕНЫ")
end

local function ToggleNoPlayerColl()
    if noPlayerCollEnabled then
        NoPlayerCollisions(false)
    else
        NoPlayerCollisions(true)
    end
end

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 380)
MainFrame.Position = UDim2.new(0, 10, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.3
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 170, 170)
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Steal-a-Brainrot"
TitleLabel.TextColor3 = Color3.new(0,0,0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.Parent = TitleBar

local function CreateButton(text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 40)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(0, 170, 170)
    button.BorderColor3 = Color3.fromRGB(0, 0, 0)
    button.BorderSizePixel = 2
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.Text = text
    button.Parent = MainFrame
    button.MouseButton1Click:Connect(callback)
end

CreateButton("Сохранить точку", UDim2.new(0, 10, 0, 40), SaveCurrentPosition)
CreateButton("Телепорт к точке", UDim2.new(0, 10, 0, 90), TeleportToSavedPosition)
CreateButton("Переподключиться", UDim2.new(0, 10, 0, 140), RejoinServer)
CreateButton("Запустить полёт", UDim2.new(0, 10, 0, 190), StartFlying)
CreateButton("Остановить полёт", UDim2.new(0, 10, 0, 240), StopFlying)
CreateButton("Удалить стены", UDim2.new(0, 10, 0, 290), RemoveWalls)
CreateButton("NoPlayerColl", UDim2.new(0, 10, 0, 340), ToggleNoPlayerColl)