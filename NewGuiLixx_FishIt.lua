-- LIXX Fish It | Telegram Notifier + Fly FIXED + Anti-AFK
-- Executor: Delta / Fluxus / Hydrogen

if getgenv().LixxFinal then return end
getgenv().LixxFinal = true

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local request = request or http_request or (syn and syn.request)

--------------------------------------------------
-- ANTI AFK (Supaya tidak terputus saat mancing lama)
--------------------------------------------------
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

--------------------------------------------------
-- TELEGRAM
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
    if not request then return end
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
        "👤 "..player.Name..
        "\n🐟 "..obj.Name..
        "\n⭐ "..tier
    )
end

local function hookFish()
    player.Backpack.ChildAdded:Connect(onFish)
    if player.Character then
        player.Character.ChildAdded:Connect(onFish)
    end
    player.CharacterAdded:Connect(function(c)
        c.ChildAdded:Connect(onFish)
    end)
end

--------------------------------------------------
-- FLY SYSTEM (FIXED)
--------------------------------------------------
local flying = false
local flySpeed = 60
local lv, ao, att

local function stopFly()
    flying = false
    RunService:UnbindFromRenderStep("LIXX_FLY")
    if lv then lv:Destroy() lv = nil end
    if ao then ao:Destroy() ao = nil end
    if att then att:Destroy() att = nil end

    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

local function startFly()
    if flying then stopFly() end
    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    flying = true
    hum.PlatformStand = true

    att = Instance.new("Attachment", hrp)
    lv = Instance.new("LinearVelocity", hrp)
    lv.Attachment0 = att
    lv.MaxForce = math.huge
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.RelativeTo = Enum.ActuatorRelativeTo.World

    ao = Instance.new("AlignOrientation", hrp)
    ao.Attachment0 = att
    ao.MaxTorque = math.huge
    ao.Responsiveness = 200
    ao.Mode = Enum.OrientationControlMode.OneAttachment

    RunService:BindToRenderStep("LIXX_FLY", Enum.RenderPriority.Character.Value, function()
        if not flying or not hrp or not lv then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.new(0,0,0)

        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

        if dir.Magnitude > 0 then
            lv.VectorVelocity = dir.Unit * flySpeed
        else
            lv.VectorVelocity = Vector3.new(0,0,0)
        end
        ao.CFrame = cam.CFrame
    end)
end

--------------------------------------------------
-- UI
--------------------------------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local logo = Instance.new("TextButton", gui)
logo.Size = UDim2.fromScale(0.06,0.08)
logo.Position = UDim2.fromScale(0.01,0.35)
logo.Text = "LIXX"
logo.TextScaled = true
logo.Font = Enum.Font.GothamBlack
logo.BackgroundColor3 = Color3.fromRGB(0,180,120)
logo.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", logo)

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.36,0.6)
main.Position = UDim2.fromScale(0.32,0.2)
main.BackgroundColor3 = Color3.fromRGB(10,30,22)
main.Active = true
main.Draggable = true
main.Visible = true
Instance.new("UICorner", main)

logo.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

local close = Instance.new("TextButton", main)
close.Text = "❌"
close.Size = UDim2.fromScale(0.1,0.07)
close.Position = UDim2.fromScale(0.88,0.02)
close.BackgroundTransparency = 1
close.TextScaled = true
close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromScale(1,0.1)
title.Text = "LIXX Fish It Utility"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(0,255,160)
title.BackgroundTransparency = 1

local function box(ph,y)
    local b = Instance.new("TextBox", main)
    b.Position = UDim2.fromScale(0.08,y)
    b.Size = UDim2.fromScale(0.84,0.07)
    b.PlaceholderText = ph
    b.Text = ""
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(30,70,55)
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    return b
end

local tokenBox = box("Telegram Bot Token",0.12)
local idBox = box("Telegram User ID",0.21)

local test = Instance.new("TextButton", main)
test.Position = UDim2.fromScale(0.08,0.3)
test.Size = UDim2.fromScale(0.38,0.08)
test.Text = "TEST NOTIF"
test.TextScaled = true
test.BackgroundColor3 = Color3.fromRGB(0,120,90)
Instance.new("UICorner", test)

test.MouseButton1Click:Connect(function()
    BOT_TOKEN = tokenBox.Text
    CHAT_ID = idBox.Text
    sendTG("Hallo kak "..player.Name.." 👋\nLIXX script aktif!")
end)

local run = Instance.new("TextButton", main)
run.Position = UDim2.fromScale(0.54,0.3)
run.Size = UDim2.fromScale(0.38,0.08)
run.Text = "AKTIFKAN NOTIF"
run.TextScaled = true
run.BackgroundColor3 = Color3.fromRGB(0,200,140)
Instance.new("UICorner", run)

run.MouseButton1Click:Connect(function()
    BOT_TOKEN = tokenBox.Text
    CHAT_ID = idBox.Text
    notifierOn = true
    hookFish()
    sendTG("🚀 LIXX Notifier aktif untuk "..player.Name)
end)

local flyBtn = Instance.new("TextButton", main)
flyBtn.Position = UDim2.fromScale(0.08,0.42)
flyBtn.Size = UDim2.fromScale(0.84,0.08)
flyBtn.Text = "FLY : OFF"
flyBtn.TextScaled = true
flyBtn.BackgroundColor3 = Color3.fromRGB(40,140,100)
Instance.new("UICorner", flyBtn)

flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    flyBtn.Text = flying and "FLY : ON" or "FLY : OFF"
    if flying then startFly() else stopFly() end
end)

local speedBox = box("Fly Speed (Default 60)",0.52)
speedBox.FocusLost:Connect(function()
    local v = tonumber(speedBox.Text)
    if v and v >= 10 and v <= 300 then
        flySpeed = v
    end
end)

print("✅ LIXX FINAL LOADED | FLY & ANTI-AFK FIXED")
