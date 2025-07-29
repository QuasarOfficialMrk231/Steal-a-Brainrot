--// Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

--// Constants
local GameID = 15975200710 -- Steal a Brainrot Game ID
local UserToTrack = ""

--// GUI Creation
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "BrainrotTrackerGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 220)
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

--// API Functions
function GetUserIdFromUsername(username)
    local url = "https://api.roblox.com/users/get-by-username?username="..username
    local response = syn.request({Url = url, Method = "GET"})
    local data = HttpService:JSONDecode(response.Body)
    if data and data.Id then
        return data.Id
    else
        warn("Пользователь не найден!")
        return nil
    end
end

function GetPresence(userId)
    local url = "https://presence.roblox.com/v1/presence/users"
    local body = HttpService:JSONEncode({userIds = {userId}})
    local response = syn.request({
        Url = url,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = body
    })
    local data = HttpService:JSONDecode(response.Body)
    if data and data.userPresences then
        return data.userPresences[1]
    end
end

function JoinToPlayerServer(username)
    local userId = GetUserIdFromUsername(username)
    if userId then
        local presence = GetPresence(userId)
        if presence.placeId ~= 0 and presence.rootPlaceId == GameID then
            TeleportService:TeleportToPlaceInstance(presence.placeId, presence.gameId, Players.LocalPlayer)
        else
            warn("Игрок в другой игре или оффлайн.")
        end
    end
end

function TrackPlayerJoin(username)
    local userId = GetUserIdFromUsername(username)
    if not userId then return end
    while true do
        local presence = GetPresence(userId)
        if presence.placeId ~= 0 and presence.rootPlaceId == GameID then
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

--// Button Events
JoinButton.MouseButton1Click:Connect(function()
    UserToTrack = TextBox.Text
    JoinToPlayerServer(UserToTrack)
end)

TrackButton.MouseButton1Click:Connect(function()
    UserToTrack = TextBox.Text
    spawn(function() TrackPlayerJoin(UserToTrack) end)
end)
