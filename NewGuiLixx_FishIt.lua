--[[ 
    LIXX Fish It - Telegram Fish Notifier
    No Boat | Notification Only
    Executor: Delta
]]

if getgenv().LixxFishNotifier then return end
getgenv().LixxFishNotifier = true

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ================= CONFIG =================
local enabled = false
local selectedTiers = {
    Uncommon = false,
    Mythic = true,
    Legendary = true,
    Secret = true
}

local BOT_TOKEN = ""
local CHAT_ID = ""

-- ================= TELEGRAM =================
local function sendTelegram(msg)
    if BOT_TOKEN == "" or CHAT_ID == "" then return end

    local url = "https://api.telegram.org/bot"..BOT_TOKEN.."/sendMessage"
    local data = {
        chat_id = CHAT_ID,
        text = msg
    }

    pcall(function()
        syn.request({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- ================= FISH DETECT =================
local function checkTier(text)
    text = text:lower()
    if text:find("secret") and selectedTiers.Secret then return "Secret" end
    if text:find("legendary") and selectedTiers.Legendary then return "Legendary" end
    if text:find("mythic") and selectedTiers.Mythic then return "Mythic" end
    if text:find("uncommon") and selectedTiers.Uncommon then return "Uncommon" end
end

-- Monitor GUI reward text
local function hookRewards()
    player.PlayerGui.DescendantAdded:Connect(function(obj)
        if not enabled then return end
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local txt = obj.Text or ""
            local tier = checkTier(txt)
            if tier then
                sendTelegram("🎣 Fish It Notification\nTier: "..tier.."\nPlayer: "..player.Name)
            end
        end
    end)
end

-- ================= UI =================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "LixxFishNotifier"

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.32,0.45)
main.Position = UDim2.fromScale(0.34,0.25)
main.BackgroundColor3 = Color3.fromRGB(15,30,20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

local function label(txt, y)
    local l = Instance.new("TextLabel", main)
    l.Position = UDim2.fromScale(0.05,y)
    l.Size = UDim2.fromScale(0.9,0.07)
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(0,255,140)
    l.Font = Enum.Font.GothamBold
    l.TextScaled = true
    l.BackgroundTransparency = 1
end

label("LIXX | Fish It Notifier",0.02)

-- INPUT
local function input(ph, y)
    local b = Instance.new("TextBox", main)
    b.Position = UDim2.fromScale(0.05,y)
    b.Size = UDim2.fromScale(0.9,0.08)
    b.PlaceholderText = ph
    b.Text = ""
    b.TextScaled = true
    b.Font = Enum.Font.Gotham
    b.BackgroundColor3 = Color3.fromRGB(30,60,45)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    return b
end

local tokenBox = input("Telegram Bot Token",0.12)
local idBox = input("Telegram User ID",0.22)

-- TIER BUTTONS
local y = 0.32
for tier,_ in pairs(selectedTiers) do
    local btn = Instance.new("TextButton", main)
    btn.Position = UDim2.fromScale(0.05,y)
    btn.Size = UDim2.fromScale(0.9,0.07)
    btn.Text = tier..": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(120,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        selectedTiers[tier] = not selectedTiers[tier]
        btn.Text = tier..": "..(selectedTiers[tier] and "ON" or "OFF")
        btn.BackgroundColor3 = selectedTiers[tier] and Color3.fromRGB(0,150,90) or Color3.fromRGB(120,0,0)
    end)

    y += 0.08
end

-- TEST
local test = Instance.new("TextButton", main)
test.Position = UDim2.fromScale(0.05,0.72)
test.Size = UDim2.fromScale(0.4,0.1)
test.Text = "TEST NOTIF"
test.TextScaled = true
test.BackgroundColor3 = Color3.fromRGB(0,120,80)
Instance.new("UICorner", test)

test.MouseButton1Click:Connect(function()
    BOT_TOKEN = tokenBox.Text
    CHAT_ID = idBox.Text
    sendTelegram("✅ TEST NOTIFICATION FROM LIXX")
end)

-- RUN
local run = Instance.new("TextButton", main)
run.Position = UDim2.fromScale(0.55,0.72)
run.Size = UDim2.fromScale(0.4,0.1)
run.Text = "JALANKAN"
run.TextScaled = true
run.BackgroundColor3 = Color3.fromRGB(0,200,120)
Instance.new("UICorner", run)

run.MouseButton1Click:Connect(function()
    BOT_TOKEN = tokenBox.Text
    CHAT_ID = idBox.Text
    enabled = true
    hookRewards()
    sendTelegram("🚀 LIXX Fish Notifier AKTIF")
end)

print("✅ LIXX Fish It Notifier Loaded")
