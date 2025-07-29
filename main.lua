local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local savedPosition = nil
local flying = false
local noPlayerCollEnabled = false
local wallsRemoved = false
local removedWalls = {}

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
local function StartStopFlying()
    flying = not flying
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")

    if flying then
        print("Полёт запущен")
        spawn(function()
            while flying do
                if savedPosition then
                    local currentPos = rootPart.Position
                    local direction = (savedPosition - currentPos)
                    if direction.Magnitude > 2 then
                        direction = direction.Unit
                        rootPart.CFrame = CFrame.new(currentPos + direction * 2)
                    end

                    if IsTouchingGround(character) then
                        rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 44, 0)
                        wait(0.05)
                        rootPart.CFrame = rootPart.CFrame - Vector3.new(0, 1, 0)
                    end
                end
                wait(0.1)
            end
        end)
    else
        print("Полёт остановлен")
    end
end

-- Удаление и восстановление стен
local function ToggleRemoveWalls()
    if not wallsRemoved then
        removedWalls = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local nameLower = obj.Name:lower()
                if string.find(nameLower, "wall") and obj.Position.Y > 1 then
                    removedWalls[#removedWalls+1] = {
                        part = obj,
                        transparency = obj.Transparency,
                        canCollide = obj.CanCollide,
                    }
                    obj.Transparency = 1
                    obj.CanCollide = false
                end
            end
        end
        wallsRemoved = true
        print("Стены убраны")
    else
        for _, data in pairs(removedWalls) do
            if data.part and data.part.Parent then
                data.part.Transparency = data.transparency
                data.part.CanCollide = data.canCollide
            end
        end
        removedWalls = {}
        wallsRemoved = false
        print("Стены восстановлены")
    end
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

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 320)
MainFrame.Position = UDim2.new(0, 10, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 50, 50)
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
    button.Size = UDim2.new(0, 160, 0, 30)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(0, 170, 170)
    button.BorderColor3 = Color3.fromRGB(0, 0, 0)
    button.BorderSizePixel = 2
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.Text = text
    button.Parent = MainFrame
    button.MouseButton1Click:Connect(callback)
end

CreateButton("Сохранить точку", UDim2.new(0, 10, 0, 40), SaveCurrentPosition)
CreateButton("Телепорт к точке", UDim2.new(0, 10, 0, 80), TeleportToSavedPosition)
CreateButton("Переподключиться", UDim2.new(0, 10, 0, 120), RejoinServer)
CreateButton("Запустить/Остановить полёт", UDim2.new(0, 10, 0, 160), StartStopFlying)
CreateButton("Удалить/Восстановить стены", UDim2.new(0, 10, 0, 200), ToggleRemoveWalls)
CreateButton("NoPlayerColl", UDim2.new(0, 10, 0, 240), ToggleNoPlayerColl)

-- Плавающая кнопка + для скрытия/показа окна
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 25, 0, 25)
ToggleBtn.Position = UDim2.new(0, 10, 0, 70)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 170)
ToggleBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.BorderSizePixel = 2
ToggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 20
ToggleBtn.Text = "+"
ToggleBtn.Parent = ScreenGui

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Сделать окно и кнопку перетаскиваемыми

local function MakeDraggable(guiElement)
    local dragging
    local dragInput
    local dragStart
    local startPos

    guiElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiElement.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    guiElement.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            guiElement.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

MakeDraggable(MainFrame)
MakeDraggable(ToggleBtn)