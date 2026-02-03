-- LIXX Fish It | MOBILE VERSION (Joystick Support)
-- Fix: Fly tidak freeze & Notif Telegram lancar

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

local function onChildAdded(obj)
    if not notifierOn or not obj:IsA("Tool") then return end
    local name = obj.Name:lower()
    if name:find("secret") or name:find("mythic") or name:find("legendary") then
        sendTG("⭐ IKAN TIER TINGGI!\n👤 User: "..player.Name.."\n🐟 Ikan: "..obj.Name)
    end
end

player.Backpack.ChildAdded:Connect(onChildAdded)
player.CharacterAdded:Connect(function(c) c.ChildAdded:Connect(onChildAdded) end)

--------------------------------------------------
-- MOBILE FLY SYSTEM (Joystick Compatible)
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
            -- Deteksi gerakan dari Joystick Android
            local moveDir = hum.MoveDirection 
            
            if moveDir.Magnitude > 0 then
                -- Terbang ke arah joystick + kamera
                bodyVel.Velocity = moveDir * flySpeed
            else
                -- Melayang di tempat (tidak jatuh)
                bodyVel.Velocity = Vector3.new(0, 0.1, 0)
            end
            
            bodyGyro.CFrame = camCF
            task.wait()
        end
        stopFly()
    end)
end

--------------------------------------------------
-- UI SEDERHANA (Mudah di Klik di HP)
--------------------------------------------------
local sg = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", sg)
frame.Size = UDim2.fromOffset(200, 220)
frame.Position = UDim2.new(0.5, -100, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local function createInput(place, y)
    local i = Instance.new("TextBox", frame)
    i.PlaceholderText = place
    i.Size = UDim2.new(0.9, 0, 0.15, 0)
    i.Position = UDim2.new(0.05, 0, y, 0)
    i.BackgroundColor3 = Color3.fromRGB(50,50,50)
    i.TextColor3 = Color3.new(1,1,1)
    return i
end

local tInp = createInput("Token Bot", 0.1)
local cInp = createInput("Chat ID", 0.3)

local btnNotif = Instance.new("TextButton", frame)
btnNotif.Text = "AKTIFKAN NOTIF"
btnNotif.Size = UDim2.new(0.9, 0, 0.2, 0)
btnNotif.Position = UDim2.new(0.05, 0, 0.5, 0)
btnNotif.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnNotif.MouseButton1Click:Connect(function()
    BOT_TOKEN = tInp.Text
    CHAT_ID = cInp.Text
    notifierOn = true
    sendTG("🚀 Notifier Aktif di Mobile!")
    btnNotif.Text = "NOTIF ON ✅"
end)

local btnFly = Instance.new("TextButton", frame)
btnFly.Text = "FLY: OFF"
btnFly.Size = UDim2.new(0.9, 0, 0.2, 0)
btnFly.Position = UDim2.new(0.05, 0, 0.75, 0)
btnFly.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
btnFly.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
        btnFly.Text = "FLY: OFF"
        btnFly.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    else
        startFly()
        btnFly.Text = "FLY: ON"
        btnFly.BackgroundColor3 = Color3.fromRGB(0, 0, 150)
    end
end)
