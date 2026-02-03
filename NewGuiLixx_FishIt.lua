--[[ 
    LIXX Fish It - Telegram Fish Notifier
    Backpack Detection Method (STABLE)
    Executor: Delta
]]

if getgenv().LixxNotifier then return end
getgenv().LixxNotifier = true

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ================= HTTP FIX =================
local request = request or http_request or (syn and syn.request)
if not request then
    warn("[LIXX] HTTP request not supported")
    return
end

-- ================= CONFIG =================
local BOT_TOKEN = ""
local CHAT_ID = ""
local enabled = false
local sent = {}

-- ================= TELEGRAM =================
local function sendTelegram(text)
    if BOT_TOKEN == "" or CHAT_ID == "" then return end

    request({
        Url = "https://api.telegram.org/bot"..BOT_TOKEN.."/sendMessage",
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            chat_id = CHAT_ID,
            text = text
        })
    })
end

-- ================= DETECT FISH =================
local function hookBackpack()
    local backpack = player:WaitForChild("Backpack")

    backpack.ChildAdded:Connect(function(tool)
        if not enabled then return end
        if not tool:IsA("Tool") then return end
        if sent[tool.Name] then return end
        sent[tool.Name] = true

        local rarity = "Unknown"
        if tool:FindFirstChild("Rarity") then
            rarity = tostring(tool.Rarity.Value)
        end

        sendTelegram(
            "🎣 LIXX Fish Notifier\n"..
            "Player: "..player.Name.."\n"..
            "Fish: "..tool.Name.."\n"..
            "Rarity: "..rarity
        )
    end)
end

-- ================= UI =================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "LixxUI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.3,0.42)
main.Position = UDim2.fromScale(0.35,0.28)
main.BackgroundColor3 = Color3.fromRGB(15,35,25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,18)

-- CLOSE
local close = Instance.new("TextButton", main)
close.Size = UDim2.fromScale(0.1,0.1)
close.Position = UDim2.fromScale(0.88,0.02)
close.Text = "❌"
close.TextScaled = true
close.BackgroundTransparency = 1
close.TextColor3 = Color3.fromRGB(255,80,80)
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- LOGO
local logo = Instance.new("TextLabel", main)
logo.Size = UDim2.fromScale(1,0.18)
logo.Text = "LIXX"
logo.Font = Enum.Font.GothamBlack
logo.TextScaled = true
logo.TextColor3 = Color3.fromRGB(0,255,140)
logo.BackgroundTransparency = 1

-- SUB
local sub = Instance.new("TextLabel", main)
sub.Position = UDim2.fromScale(0,0.16)
sub.Size = UDim2.fromScale(1,0.08)
sub.Text = "Fish It Telegram Notifier"
sub.TextScaled = true
sub.TextColor3 = Color3.fromRGB(200,255,220)
sub.BackgroundTransparency = 1

-- INPUT
local function input(ph,y)
    local b = Instance.new("TextBox", main)
    b.Position = UDim2.fromScale(0.08,y)
    b.Size = UDim2.fromScale(0.84,0.09)
    b.PlaceholderText = ph
    b.Text = ""
    b.TextScaled = true
    b.Font = Enum.Font.Gotham
    b.BackgroundColor3 = Color3.fromRGB(30,70,55)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    return b
end

local tokenBox = input("Telegram Bot Token",0.28)
local idBox = input("Telegram User ID",0.40)

-- TEST
local test = Instance.new("TextButton", main)
test.Position = UDim2.fromScale(0.08,0.54)
test.Size = UDim2.fromScale(0.38,0.1)
test.Text = "TEST NOTIF"
test.TextScaled = true
test.BackgroundColor3 = Color3.fromRGB(0,120,90)
test.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", test)

test.MouseButton1Click:Connect(function()
    BOT_TOKEN = tokenBox.Text
    CHAT_ID = idBox.Text
    sendTelegram("Hallo kak "..player.Name.." 👋\nScript berjalan lancar\nNotif akan masuk 😸✌️")
end)

-- RUN
local run = Instance.new("TextButton", main)
run.Position = UDim2.fromScale(0.54,0.54)
run.Size = UDim2.fromScale(0.38,0.1)
run.Text = "JALANKAN"
run.TextScaled = true
run.BackgroundColor3 = Color3.fromRGB(0,200,130)
run.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", run)

run.MouseButton1Click:Connect(function()
    BOT_TOKEN = tokenBox.Text
    CHAT_ID = idBox.Text
    enabled = true
    hookBackpack()
    sendTelegram("🚀 LIXX aktif untuk "..player.Name)
end)

print("✅ LIXX Fish It Notifier Loaded")
