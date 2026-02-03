-- LIXX Fish It | MOBILE VERSION (Fly Kamera, Teleport & Speed)
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
-- FLY & SPEED SYSTEM
--------------------------------------------------
local flying = false
local flySpeed = 50
local walkSpeed = 16
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
            local cam = workspace.CurrentCamera
            if hum.MoveDirection.Magnitude > 0 then
                bodyVel.Velocity = cam.CFrame.LookVector * flySpeed * (hum.MoveDirection.Z < 0 and 1 or -0.5) + 
                                  cam.CFrame.RightVector * flySpeed * (hum.MoveDirection.X > 0 and 1 or -1) * math.abs(hum.MoveDirection.X)
            else
                bodyVel.Velocity = Vector3.new(0, 0, 0)
            end
            bodyGyro.CFrame = cam.CFrame
            task.wait()
        end
        stopFly()
    end)
end

-- Loop untuk menjaga WalkSpeed tetap aktif
RunService.RenderStepped:Connect(function()
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") and not flying then
        player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = walkSpeed
    end
end)

--------------------------------------------------
-- UI SYSTEM
--------------------------------------------------
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "LixxScriptUI"
sg.ResetOnSpawn = false

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.fromOffset(240, 480) -- Ukuran diperbesar sedikit
frame.Position = UDim2.new(0.5, -120, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "LIXX FISH IT + SPEED"
title.Size = UDim2.new(1, 0, 0.08, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold

-- Tombol Close & Restore
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Text = "❌"
closeBtn.Size = UDim2.fromOffset(25, 25)
closeBtn.Position = UDim2.new(1, -28, 0, 4)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.new(1, 0, 0)

local restoreBtn = Instance.new("TextButton", sg)
restoreBtn.Text = "LIXX"
restoreBtn.Size = UDim2.fromOffset(50, 50)
restoreBtn.Position = UDim2.new(0, 10, 0.4, 0)
restoreBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
restoreBtn.TextColor3 = Color3.new(1, 1, 1)
restoreBtn.Visible = false

closeBtn.MouseButton1Click:Connect(function() frame.Visible = false; restoreBtn.Visible = true end)
restoreBtn.MouseButton1Click:Connect(function() frame.Visible = true; restoreBtn.Visible = false end)

-- Fitur Speed Slider (TextBox Input)
local speedInp = Instance.new("TextBox", frame)
speedInp.PlaceholderText = "Set WalkSpeed (Def: 16)"
speedInp.Size = UDim2.new(0.9, 0, 0.07, 0)
speedInp.Position = UDim2.new(0.05, 0, 0.1, 0)
speedInp.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedInp.TextColor3 = Color3.new(1, 1, 1)
speedInp.FocusLost:Connect(function()
    walkSpeed = tonumber(speedInp.Text) or 16
end)

-- Fly Speed Input
local flyInp = Instance.new("TextBox", frame)
flyInp.PlaceholderText = "Set FlySpeed (Def: 50)"
flyInp.Size = UDim2.new(0.9, 0, 0.07, 0)
flyInp.Position = UDim2.new(0.05, 0, 0.18, 0)
flyInp.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flyInp.TextColor3 = Color3.new(1, 1, 1)
flyInp.FocusLost:Connect(function()
    flySpeed = tonumber(flyInp.Text) or 50
end)

-- Tombol Fly
local btnFly = Instance.new("TextButton", frame)
btnFly.Text = "FLY: OFF"
btnFly.Size = UDim2.new(0.9, 0, 0.08, 0)
btnFly.Position = UDim2.new(0.05, 0, 0.27, 0)
btnFly.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
btnFly.TextColor3 = Color3.new(1, 1, 1)

-- Telegram Inputs (Simplified)
local tInp = Instance.new("TextBox", frame)
tInp.PlaceholderText = "Bot Token"
tInp.Size = UDim2.new(0.43, 0, 0.07, 0)
tInp.Position = UDim2.new(0.05, 0, 0.37, 0)
tInp.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
tInp.TextColor3 = Color3.new(1, 1, 1)

local cInp = Instance.new("TextBox", frame)
cInp.PlaceholderText = "Chat ID"
cInp.Size = UDim2.new(0.43, 0, 0.07, 0)
cInp.Position = UDim2.new(0.52, 0, 0.37, 0)
cInp.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
cInp.TextColor3 = Color3.new(1, 1, 1)

local btnNotif = Instance.new("TextButton", frame)
btnNotif.Text = "NOTIF"
btnNotif.Size = UDim2.new(0.9, 0, 0.07, 0)
btnNotif.Position = UDim2.new(0.05, 0, 0.45, 0)
btnNotif.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
btnNotif.TextColor3 = Color3.new(1, 1, 1)

--------------------------------------------------
-- TELEPORT SYSTEM
--------------------------------------------------
local tpTitle = Instance.new("TextLabel", frame)
tpTitle.Text = "TELEPORT TO PLAYER"
tpTitle.Size = UDim2.new(1, 0, 0.06, 0)
tpTitle.Position = UDim2.new(0, 0, 0.53, 0)
tpTitle.BackgroundTransparency = 1
tpTitle.TextColor3 = Color3.new(1, 1, 0)
tpTitle.Font = Enum.Font.GothamBold

local scrollingFrame = Instance.new("ScrollingFrame", frame)
scrollingFrame.Size = UDim2.new(0.9, 0, 0.28, 0)
scrollingFrame.Position = UDim2.new(0.05, 0, 0.6, 0)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local uiList = Instance.new("UIListLayout", scrollingFrame)
uiList.SortOrder = Enum.SortOrder.LayoutOrder

local function refreshPlayers()
    for _, child in pairs(scrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local pBtn = Instance.new("TextButton", scrollingFrame)
            pBtn.Text = p.DisplayName or p.Name
            pBtn.Size = UDim2.new(1, -5, 0, 25)
            pBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            pBtn.TextColor3 = Color3.new(1, 1, 1)
            pBtn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character:MoveTo(p.Character.HumanoidRootPart.Position)
                end
            end)
        end
    end
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y)
end

local btnRefresh = Instance.new("TextButton", frame)
btnRefresh.Text = "🔄 REFRESH PLAYER LIST"
btnRefresh.Size = UDim2.new(0.9, 0, 0.08, 0)
btnRefresh.Position = UDim2.new(0.05, 0, 0.9, 0)
btnRefresh.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
btnRefresh.TextColor3 = Color3.new(1, 1, 1)

--------------------------------------------------
-- HANDLERS
--------------------------------------------------
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

btnNotif.MouseButton1Click:Connect(function()
    BOT_TOKEN = tInp.Text
    CHAT_ID = cInp.Text
    sendTG("🚀 Notifier Aktif!")
    btnNotif.Text = "NOTIF ON ✅"
end)

btnRefresh.MouseButton1Click:Connect(refreshPlayers)
refreshPlayers()
