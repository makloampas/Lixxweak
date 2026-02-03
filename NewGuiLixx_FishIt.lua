-- LIXX Fish It | Telegram Notifier + Fly
-- Executor: Delta / Fluxus

if getgenv().LixxUltimate then return end
getgenv().LixxUltimate = true

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local request = request or http_request or (syn and syn.request)
if not request then return warn("HTTP not supported") end

--------------------------------------------------
-- TELEGRAM CONFIG
--------------------------------------------------
local BOT_TOKEN = ""
local CHAT_ID = ""
local notifierOn = false
local sent = {}

local TierFilter = {
    Common = false,
    Uncommon = false,
    Legendary = true,
    Mythic = true,
    Secret = true
}

local TierEmoji = {
    Common = "⚪",
    Uncommon = "🟢",
    Legendary = "🟡",
    Mythic = "🔴",
    Secret = "🟣"
}

local function sendTG(msg)
    request({
        Url = "https://api.telegram.org/bot"..BOT_TOKEN.."/sendMessage",
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            chat_id = CHAT_ID,
            text = msg
        })
    })
end

local function getTier(name)
    name = name:lower()
    if name:find("secret") then return "Secret" end
    if name:find("mythic") then return "Mythic" end
    if name:find("legendary") then return "Legendary" end
    if name:find("uncommon") then return "Uncommon" end
    return "Common"
end

local function onFish(obj)
    if not notifierOn then return end
    if not obj:IsA("Tool") then return end
    if sent[obj] then return end
    sent[obj] = true

    local tier = getTier(obj.Name)
    if not TierFilter[tier] then return end

    sendTG(
        TierEmoji[tier].." Fish It Alert\n"..
        "Player: "..player.Name..
        "\nFish: "..obj.Name..
        "\nTier: "..tier
    )
end

local function hookFish()
    if player.Character then
        player.Character.ChildAdded:Connect(onFish)
    end
    player.CharacterAdded:Connect(function(c)
        c.ChildAdded:Connect(onFish)
    end)
    player.Backpack.ChildAdded:Connect(onFish)
end

--------------------------------------------------
-- FLY SYSTEM
--------------------------------------------------
local flying = false
local flySpeed = 60
local bv, bg

local function startFly()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)

    bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bg.CFrame = hrp.CFrame

    RunService:BindToRenderStep("LIXX_FLY", 0, function()
        if not flying then return end
        local cam = workspace.CurrentCamera
        local move = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

        bv.Velocity = move * flySpeed
        bg.CFrame = cam.CFrame
    end)
end

local function stopFly()
    RunService:UnbindFromRenderStep("LIXX_FLY")
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

--------------------------------------------------
-- UI
--------------------------------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

-- LOGO
local logo = Instance.new("TextButton", gui)
logo.Size = UDim2.fromScale(0.06,0.08)
logo.Position = UDim2.fromScale(0.01,0.35)
logo.Text = "LIXX"
logo.Font = Enum.Font.GothamBlack
logo.TextScaled = true
logo.BackgroundColor3 = Color3.fromRGB(0,180,120)
logo.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", logo)

-- MAIN
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.36,0.55)
main.Position = UDim2.fromScale(0.32,0.22)
main.BackgroundColor3 = Color3.fromRGB(12,30,22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

logo.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- CLOSE
local close = Instance.new("TextButton", main)
close.Text = "❌"
close.Size = UDim2.fromScale(0.1,0.08)
close.Position = UDim2.fromScale(0.88,0.02)
close.BackgroundTransparency = 1
close.TextScaled = true
close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromScale(1,0.12)
title.Text = "LIXX Fish It Utility"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(0,255,150)
title.BackgroundTransparency = 1

-- INPUT
local function box(ph,y)
    local b = Instance.new("TextBox", main)
    b.Position = UDim2.fromScale(0.08,y)
    b.Size = UDim2.fromScale(0.84,0.07)
    b.PlaceholderText = ph
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(30,70,55)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    return b
end

local tokenBox = box("Telegram Bot Token",0.15)
local idBox = box("Telegram User ID",0.24)

-- TEST
local test = Instance.new("TextButton", main)
test.Position = UDim2.fromScale(0.08,0.33)
test.Size = UDim2.fromScale(0.38,0.08)
test.Text = "TEST NOTIF"
test.TextScaled = true
test.BackgroundColor3 = Color3.fromRGB(0,120,90)
Instance.new("UICorner", test)

test.MouseButton1Click:Connect(function()
    BOT_TOKEN = tokenBox.Text
    CHAT_ID = idBox.Text
    sendTG("Hallo kak "..player.Name.." 👋\nScript LIXX berjalan 😸✌️")
end)

-- RUN
local run = Instance.new("TextButton", main)
run.Position = UDim2.fromScale(0.54,0.33)
run.Size = UDim2.fromScale(0.38,0.08)
run.Text = "AKTIFKAN NOTIF"
run.TextScaled = true
run.BackgroundColor3 = Color3.fromRGB(0,200,130)
Instance.new("UICorner", run)

run.MouseButton1Click:Connect(function()
    BOT_TOKEN = tokenBox.Text
    CHAT_ID = idBox.Text
    notifierOn = true
    hookFish()
    sendTG("🚀 LIXX Notifier aktif untuk "..player.Name)
end)

-- FLY TOGGLE
local flyBtn = Instance.new("TextButton", main)
flyBtn.Position = UDim2.fromScale(0.08,0.45)
flyBtn.Size = UDim2.fromScale(0.84,0.09)
flyBtn.Text = "FLY : OFF"
flyBtn.TextScaled = true
flyBtn.BackgroundColor3 = Color3.fromRGB(40,120,90)
Instance.new("UICorner", flyBtn)

flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyBtn.Text = flying and "FLY : ON" or "FLY : OFF"
    if flying then startFly() else stopFly() end
end)

print("✅ LIXX NOTIFIER + FLY LOADED")
