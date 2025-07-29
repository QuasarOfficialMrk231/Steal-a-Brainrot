local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

-- Основная панель
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 180, 0, 140)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(10, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = false -- Будем делать вручную для совместимости с тач

-- Функция для драг&дроп (поддержка ПК и телефона)
local function makeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos

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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

makeDraggable(Frame)

-- Кнопка "+" для скрытия/показа панели
local toggleUI = Instance.new("TextButton", ScreenGui)
toggleUI.Size = UDim2.new(0, 30, 0, 30)
toggleUI.Position = UDim2.new(0, 10, 0, 10)
toggleUI.BackgroundColor3 = Color3.fromRGB(0, 170, 170)
toggleUI.TextColor3 = Color3.new(1, 1, 1)
toggleUI.Font = Enum.Font.SourceSansBold
toggleUI.TextSize = 24
toggleUI.Text = "+"

makeDraggable(toggleUI)

local uiVisible = true
toggleUI.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    Frame.Visible = uiVisible
end)

-- Координаты в правом верхнем углу
local CoordLabel = Instance.new("TextLabel", ScreenGui)
CoordLabel.Size = UDim2.new(0, 160, 0, 20)
CoordLabel.Position = UDim2.new(1, -170, 0, 10)
CoordLabel.BackgroundTransparency = 1
CoordLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
CoordLabel.Font = Enum.Font.SourceSans
CoordLabel.TextSize = 14
CoordLabel.TextXAlignment = Enum.TextXAlignment.Right
CoordLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Переменные
local FlyActive = false
local NoPlayerColl = false
local WallRemoved = false
local TeleportLoop = false
local TeleportInterval = 0.25
local FlyBaseY = -6.9
local FlyHeight = 44
local lastFlyTeleport = 0

local character = nil
local rootPart = nil

local function updateCharacter()
    character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    rootPart = character:WaitForChild("HumanoidRootPart")
end
updateCharacter()
LocalPlayer.CharacterAdded:Connect(updateCharacter)

-- Переподключение
local function RejoinServer()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

-- Полет с касанием пола
local function FlyToBase(dt)
    if not FlyActive or not rootPart then return end

    local pos = rootPart.Position
    -- Движемся к базе по XZ (0,0)
    local horizDist = Vector3.new(pos.X, 0, pos.Z).Magnitude
    local dir = Vector3.new(-pos.X, 0, -pos.Z).Unit

    if horizDist > 1 then
        rootPart.Velocity = Vector3.new(dir.X * 80, rootPart.Velocity.Y, dir.Z * 80)
    else
        rootPart.Velocity = Vector3.new(0, rootPart.Velocity.Y, 0)
    end

    local timeNow = tick()
    if timeNow - lastFlyTeleport > 0.8 then
        if pos.Y <= FlyBaseY + 0.2 then
            rootPart.CFrame = rootPart.CFrame + Vector3.new(0, FlyHeight, 0)
            lastFlyTeleport = timeNow
        end
    end
end

RunService.Heartbeat:Connect(FlyToBase)

-- Телепорт к базе каждые 0.25 секунды
local TeleportConnection = nil
local function StartTeleportLoop()
    if TeleportConnection then return end
    TeleportConnection = RunService.Heartbeat:Connect(function()
        if TeleportLoop and rootPart then
            rootPart.CFrame = CFrame.new(0, FlyBaseY, 0)
        end
    end)
end

local function StopTeleportLoop()
    if TeleportConnection then
        TeleportConnection:Disconnect()
        TeleportConnection = nil
    end
end

-- noplayercoll (снимает коллизию с персонажа)
local function ToggleNoPlayerColl()
    NoPlayerColl = not NoPlayerColl
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = not NoPlayerColl
            end
        end
    end
end

-- Удалить стены (Y>1 или имя содержит "wall")
local originalWallProperties = {}

local function ToggleRemoveWalls()
    WallRemoved = not WallRemoved
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local yPos = obj.Position.Y
            local nameLower = obj.Name:lower()
            if (yPos > 1 or string.find(nameLower, "wall")) then
                if WallRemoved then
                    if not originalWallProperties[obj] then
                        originalWallProperties[obj] = {
                            Transparency = obj.Transparency,
                            CanCollide = obj.CanCollide
                        }
                    end
                    obj.Transparency = 0.7
                    obj.CanCollide = false
                else
                    if originalWallProperties[obj] then
                        obj.Transparency = originalWallProperties[obj].Transparency
                        obj.CanCollide = originalWallProperties[obj].CanCollide
                        originalWallProperties[obj] = nil
                    end
                end
            end
        end
    end
end

-- Обновление координат
RunService.RenderStepped:Connect(function()
    if rootPart then
        local pos = rootPart.Position
        CoordLabel.Text = string.format("X=%.2f  Y=%.2f  Z=%.2f", pos.X, pos.Y, pos.Z)
    end
end)

-- Кнопки (компактные, высота 25)
local function createButton(text, posY, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, -20, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(0, 170, 170)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Text = text
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local btnFly = createButton("Полет к базе", 10, function()
    FlyActive = not FlyActive
    if FlyActive then
        print("Полет включен")
    else
        print("Полет выключен")
    end
end)

local btnNoPlayerColl = createButton("NoPlayerColl", 45, function()
    ToggleNoPlayerColl()
    print("NoPlayerColl: "..tostring(NoPlayerColl))
end)

local btnRemoveWalls = createButton("Удалить стены", 80, function()
    ToggleRemoveWalls()
    print("Удалить стены: "..tostring(WallRemoved))
end)

local btnTeleportLoop = createButton("Телепорт к базе", 115, function()
    TeleportLoop = not TeleportLoop
    if TeleportLoop then
        StartTeleportLoop()
        print("Телепорт к базе включен")
    else
        StopTeleportLoop()
        print("Телепорт к базе выключен")
    end
end)

local btnRejoin = createButton("Переподключиться", 150, function()
    RejoinServer()
end) 