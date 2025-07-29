local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local GameID = 15975200710

local function HTTPRequest(options)
    if http_request then
        return http_request(options)
    elseif request then
        return request(options)
    elseif syn and syn.request then
        return syn.request(options)
    else
        error("Executor не поддерживает HTTP-запросы!")
    end
end

-- Главное окно (скрыто при запуске)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "BrainrotTrackerGUI"
ScreenGui.Enabled = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 300)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Text = "Brainrot Utility"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

local TextBox = Instance.new("TextBox", Frame)
TextBox.Size = UDim2.new(1, -20, 0, 30)
TextBox.Position = UDim2.new(0, 10, 0, 40)
TextBox.PlaceholderText = "Введите ник игрока"
TextBox.Text = ""

local JoinButton = Instance.new("TextButton", Frame)
JoinButton.Size = UDim2.new(1, -20, 0, 30)
JoinButton.Position = UDim2.new(0, 10, 0, 80)
JoinButton.Text = "Присоединиться к игроку"

local TrackButton = Instance.new("TextButton", Frame)
TrackButton.Size = UDim2.new(1, -20, 0, 30)
TrackButton.Position = UDim2.new(0, 10, 0, 120)
TrackButton.Text = "Отслеживать вход"

local RejoinButton = Instance.new("TextButton", Frame)
RejoinButton.Size = UDim2.new(1, -20, 0, 30)
RejoinButton.Position = UDim2.new(0, 10, 0, 160)
RejoinButton.Text = "Переподключиться к своему серверу"

local CloseButton = Instance.new("TextButton", Frame)
CloseButton.Size = UDim2.new(1, -20, 0, 30)
CloseButton.Position = UDim2.new(0, 10, 0, 200)
CloseButton.Text = "Закрыть скрипт"
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseButton.TextColor3 = Color3.new(1,1,1)

-- Плавающая кнопка — маленький крестик (30x30)
local ToggleGui = Instance.new("ScreenGui", game.CoreGui)
ToggleGui.Name = "BrainrotToggleGui"

local ToggleButton = Instance.new("TextButton", ToggleGui)
ToggleButton.Size = UDim2.new(0, 30, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Text = "✕"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 24
ToggleButton.AutoButtonColor = false
ToggleButton.Active = true
ToggleButton.Draggable = true

ToggleButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

-- API функции
local function GetUserIdFromUsername(username)
    local url = "https://api.roblox.com/users/get-by-username?username="..username
    local response = HTTPRequest({Url = url, Method = "GET"})
    local data = HttpService:JSONDecode(response.Body)
    if data and data.Id then
        return data.Id
    else
        warn("Пользователь не найден!")
        return nil
    end
end

local function GetPresence(userId)
    local url = "https://presence.roblox.com/v1/presence/users"
    local body = HttpService:JSONEncode({userIds = {userId}})
    local response = HTTPRequest({
        Url = url,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = body
    })
    local data = HttpService:JSONDecode(response.Body)
    if data and data.userPresences then
        return data.userPresences[1]
    else
        return nil
    end
end

local function JoinToPlayerServer(username)
    local userId = GetUserIdFromUsername(username)
    if not userId then
        warn("Пользователь не найден!")
        return
    end
    local presence = GetPresence(userId)
    if presence and presence.placeId ~= 0 and presence.rootPlaceId == GameID and presence.gameId then
        TeleportService:TeleportToPlaceInstance(presence.placeId, presence.gameId, LocalPlayer)
    else
        warn("Игрок в другой игре или оффлайн.")
    end
end

local function TrackPlayerJoin(username)
    local userId = GetUserIdFromUsername(username)
    if not userId then return end
    while true do
        local presence = GetPresence(userId)
        if presence and presence.placeId ~= 0 and presence.rootPlaceId == GameID then
            game.StarterGui:SetCore("SendNotification", {
                Title = username.." зашел в Steal a Brainrot!",
                Text = "Нажми, чтобы присоединиться.",
                Duration = 10
            })
            break
        end
        wait(10)
    end
end

JoinButton.MouseButton1Click:Connect(function()
    if TextBox.Text ~= "" then
        JoinToPlayerServer(TextBox.Text)
    else
        warn("Введите ник игрока!")
    end
end)

TrackButton.MouseButton1Click:Connect(function()
    if TextBox.Text ~= "" then
        spawn(function()
            TrackPlayerJoin(TextBox.Text)
        end)
    else
        warn("Введите ник игрока!")
    end
end)

RejoinButton.MouseButton1Click:Connect(function()
    local placeId = game.PlaceId
    local jobId = game.JobId
    if placeId and jobId then
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    else
        warn("Не удалось получить текущий сервер.")
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    ToggleGui:Destroy()
end)