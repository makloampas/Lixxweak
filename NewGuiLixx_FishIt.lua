-- LIXX Fish It | MOBILE VERSION (Modified with Close & Restore Button)
if getgenv().LixxFinalMobile then return end
getgenv().LixxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local request = (syn and syn.request) or (http and http.request) or http_request or request

--------------------------------------------------
-- TELEGRAM SYSTEM
--------------------------------------------------
local BOT_TOKEN = ""
local CHAT_ID = ""
local notifierOn = false

local function sendTG(msg)
    if not request or BOT_TOKEN == "" or CHAT_ID == "" then return end
    task.spawn(pcall, function()
        request({
            Url = "https://api.telegram.org/bot"..BOT_TOKEN.."/sendMessage",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({chat_id = CHAT_ID, text = msg})
        })
    end)
end

--------------------------------------------------
-- MOBILE FLY SYSTEM
--------------------------------------------------
local flying = false
local flySpeed = 50
local bodyVel, bodyGyro

local function stopFly()
    flying = false
    if bodyVel then bodyVel:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then 
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function startFly()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    stopFly()
    flying = true
    hum.PlatformStand = true
    bodyVel = Instance.new("BodyVelocity", hrp)
    bodyVel.MaxForce = Vector3.new(1,1,1) * 9e9
    bodyVel.Velocity = Vector3.new(0,0,0)
    bodyGyro = Instance.new("BodyGyro", hrp)
    bodyGyro.MaxTorque = Vector3.new(1,1,1) * 9e9
    bodyGyro.P = 3000
    task.spawn(function()
        while flying and hrp and char.Parent do
            local camCF = workspace.CurrentCamera.CFrame
            local moveDir = hum.MoveDirection 
            if moveDir.Magnitude > 0 then
                bodyVel.Velocity = moveDir * flySpeed
            else
                bodyVel.Velocity = Vector3.new(0, 0.1, 0)
            end
            bodyGyro.CFrame = camCF
            task.wait()
        end
        stopFly()
    end)
end

--------------------------------------------------
-- UI SYSTEM WITH CLOSE & MINIMIZE
--------------------------------------------------
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "LixxScriptUI"
sg.ResetOnSpawn = false

-- MENU UTAMA
local frame = Instance.new("Frame", sg)
frame.Size = UDim2.fromOffset(220, 250)
frame.Position = UDim2.new(0.5, -110, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true

-- Judul
local title = Instance.new("TextLabel", frame)
title.Text = "LIXX FISH IT"
title.Size = UDim2.new(1, 0, 0.15, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold

-- Tombol CLOSE (❌)
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Text = "❌"
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.new(1, 0, 0)
closeBtn.TextSize = 18

-- LOGO RESTORE (Lixx Logo di Kiri)
local restoreBtn = Instance.new("TextButton", sg)
restoreBtn.Name = "LixxLogo"
restoreBtn.Text = "LIXX"
restoreBtn.Size = UDim2.fromOffset(60, 60)
restoreBtn.Position = UDim2.new(0, 10, 0.4, 0) -- Di sebelah kiri layar
restoreBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
restoreBtn.TextColor3 = Color3.new(1, 1, 1)
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.Visible = false -- Sembunyi dulu

-- Fungsi Close/Restore
closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    restoreBtn.Visible = true
end)

restoreBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    restoreBtn.Visible = false
end)

-- Komponen Input & Tombol Fly (Sama seperti sebelumnya)
local function createInput(place, y)
    local i = Instance.new("TextBox", frame)
    i.PlaceholderText = place
    i.Size = UDim2.new(0.9, 0, 0.12, 0)
    i.Position = UDim2.new(0.05, 0, y, 0)
    i.BackgroundColor3 = Color3.fromRGB(50,50,50)
    i.TextColor3 = Color3.new(1,1,1)
    return i
end

local tInp = createInput("Token Bot", 0.2)
local cInp = createInput("Chat ID", 0.35)

local btnNotif = Instance.new("TextButton", frame)
btnNotif.Text = "AKTIFKAN NOTIF"
btnNotif.Size = UDim2.new(0.9, 0, 0.18, 0)
btnNotif.Position = UDim2.new(0.05, 0, 0.52, 0)
btnNotif.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
btnNotif.TextColor3 = Color3.new(1, 1, 1)

local btnFly = Instance.new("TextButton", frame)
btnFly.Text = "FLY: OFF"
btnFly.Size = UDim2.new(0.9, 0, 0.18, 0)
btnFly.Position = UDim2.new(0.05, 0, 0.75, 0)
btnFly.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
btnFly.TextColor3 = Color3.new(1, 1, 1)

-- Event Handlers
btnNotif.MouseButton1Click:Connect(function()
    BOT_TOKEN = tInp.Text
    CHAT_ID = cInp.Text
    notifierOn = true
    sendTG("🚀 Notifier Aktif di Mobile!")
    btnNotif.Text = "NOTIF ON ✅"
end)

btnFly.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
        btnFly.Text = "FLY: OFF"
        btnFly.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    else
        startFly()
        btnFly.Text = "FLY: ON"
        btnFly.BackgroundColor3 = Color3.fromRGB(0, 0, 120)
    end
end)
