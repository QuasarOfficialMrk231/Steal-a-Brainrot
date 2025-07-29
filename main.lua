-- Скрипт @Ew3qs с полётом из KaspikScriptsRb и AutoAim из spicy/chilli

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local savedPoint = nil
local flying = false
local noPlayerCollEnabled = false
local noWallsEnabled = false
local wallsStored = {}
local autoAimEnabled = false

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Position = UDim2.new(0, 50, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.BorderSizePixel = 0

-- Plus Button
local PlusButton = Instance.new("TextButton", ScreenGui)
PlusButton.Size = UDim2.new(0, 30, 0, 30)
PlusButton.Position = UDim2.new(0, 10, 0, 10)
PlusButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
PlusButton.TextColor3 = Color3.fromRGB(0, 255, 255)
PlusButton.Text = "+"
PlusButton.BorderSizePixel = 0
PlusButton.Font = Enum.Font.SourceSansBold
PlusButton.TextSize = 24
PlusButton.Draggable = true

PlusButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Coordinates Display (верхний правый угол, очень мелкий шрифт)
local CoordsLabel = Instance.new("TextLabel", ScreenGui)
CoordsLabel.Size = UDim2.new(0, 200, 0, 16)
CoordsLabel.Position = UDim2.new(1, -210, 0, 10)
CoordsLabel.BackgroundTransparency = 1
CoordsLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
CoordsLabel.TextSize = 10
CoordsLabel.Text = ""

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        CoordsLabel.Text = string.format("X=%.1f  Y=%.1f  Z=%.1f", pos.X, pos.Y, pos.Z)
    else
        CoordsLabel.Text = ""
    end
end)

-- Функция создания кнопок с цветами
local function CreateButton(name, posY, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 200, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.TextColor3 = Color3.fromRGB(0, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Кнопка 1: Установить точку
CreateButton("Установить точку", 40, function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedPoint = LocalPlayer.Character.HumanoidRootPart.Position
    end
end)

-- Кнопка 2: Удалить стены
CreateButton("Удалить стены", 70, function()
    noWallsEnabled = not noWallsEnabled
    if noWallsEnabled then
        -- Сохраняем все стены выше -5.1 и делаем их полупрозрачными и без коллизии
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Position.Y > -5.1 and string.find(v.Name:lower(), "wall") then
                table.insert(wallsStored, v)
                v.Transparency = 0.7
                v.CanCollide = false
            end
        end
    else
        -- Восстанавливаем стены
        for _, v in pairs(wallsStored) do
            if v and v:IsA("BasePart") then
                v.Transparency = 0
                v.CanCollide = true
            end
        end
        wallsStored = {}
    end
end)

-- Кнопка 3: Телепорт к точке
CreateButton("Телепорт к точке", 100, function()
    if savedPoint and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(savedPoint)
    end
end)

-- Кнопка 4: Полет к точке (по механике из первого скрипта)
CreateButton("Полет к точке", 130, function()
    flying = not flying
    if flying then
        task.spawn(function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            while flying and root and humanoid and savedPoint do
                -- Горизонтальное движение плавное
                local horizontalTarget = Vector3.new(savedPoint.X, root.Position.Y, savedPoint.Z)
                local dir = (horizontalTarget - root.Position)
                local dist = dir.Magnitude

                if dist > 1 then
                    local step = math.min(10, dist)
                    local moveVec = dir.Unit * step
                    root.CFrame = root.CFrame + moveVec
                end

                -- Проверка касания земли (raycast вниз)
                local rayOrigin = root.Position
                local rayDirection = Vector3.new(0, -10, 0)
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                local ray = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)

                if ray and ray.Position.Y <= -6.9 then
                    root.CFrame = CFrame.new(root.Position.X, 44, root.Position.Z)
                    task.wait(0.4)
                end

                task.wait(0.1)
            end
        end)
    end
end)

-- Кнопка 5: Переподключение к серверу (тот же сервер)
CreateButton("Переподключиться", 160, function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)

-- Кнопка 6: AutoAim из spicy/chilli.lua
local autoAimToggleBtn = CreateButton("AutoAim", 190, function()
    autoAimEnabled = not autoAimEnabled
    if autoAimEnabled then
        task.spawn(function()
            while autoAimEnabled do
                task.wait(0.1)
                if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then continue end
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if not tool then continue end
                
                local toolName = tool.Name:lower()
                if not (toolName == "laser cape" or toolName == "taser" or toolName == "руки" or toolName == "hands") then
                    -- отключаем, если нет нужного предмета
                    autoAimEnabled = false
                    break
                end
                
                -- Находим ближайшего игрока
                local closestPlayer = nil
                local shortestDist = math.huge
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if dist < shortestDist then
                            closestPlayer = player
                            shortestDist = dist
                        end
                    end
                end
                
                if closestPlayer then
                    -- Вызываем событие клика мыши на позицию цели
                    local mousePos = closestPlayer.Character.HumanoidRootPart.Position
                    -- Используем событие MouseButton1Down симуляцию
                    local mouse = LocalPlayer:GetMouse()
                    mouse.TargetFilter = LocalPlayer.Character
                    mouse.Hit = CFrame.new(mousePos)
                    mouse.Target = closestPlayer.Character.HumanoidRootPart
                    
                    -- Вызов события клика (на самом деле в Roblox нет прямой функции для клика в скрипте,
                    -- но обычно в таких скриптах вызывается RemoteEvent или вызывается активация инструмента через tool:Activate()
                    if tool and tool.Activate then
                        tool:Activate()
                    end
                end
            end
        end)
    end
end)

-- Кнопка 7: NoPlayerColl (отключить коллизию игрока)
CreateButton("NoPlayerColl", 220, function()
    noPlayerCollEnabled = not noPlayerCollEnabled
    if LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = not noPlayerCollEnabled
            end
        end
    end
end)

-- Кнопка 8: Об Авторе (копирует ссылку)
local AboutButton = CreateButton("Об Авторе", 250, function()
    setclipboard("https://www.donationalerts.com/r/Ew3qs")
end)
AboutButton.Text = "@Ew3qs - Поддержать автора"
AboutButton.TextSize = 12
AboutButton.BackgroundColor3 = Color3.fromRGB(0, 150, 150)

-- Цвета кнопок можно настроить рандомно или градиентом, оставил бирюзовый одноцветный
-- Окно и плюсик небольшие и кликабельные, как и просил

-- Конец скрипта