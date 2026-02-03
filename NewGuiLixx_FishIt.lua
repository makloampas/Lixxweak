-- LIXX Fish It | MOBILE VERSION (FIXED FLY & SCROLLABLE UI)
if getgenv().LixxFinalMobile then return end
getgenv().LixxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

--------------------------------------------------
-- FLY SYSTEM (FIXED DIRECTION)
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
            local moveDir = hum.MoveDirection
            
            if moveDir.Magnitude > 0 then
                -- Perbaikan Logika: Menggunakan LookVector & RightVector sesuai input joystick
                local direction = (cam.CFrame.LookVector * -moveDir.Z) + (cam.CFrame.RightVector * moveDir.X)
                bodyVel.Velocity = direction.Unit * flySpeed
            else
                bodyVel.Velocity = Vector3.new(0, 0, 0)
            end
            bodyGyro.CFrame = cam.CFrame
            task.wait()
        end
        stopFly()
    end)
end

RunService.RenderStepped:Connect(function()
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") and not flying then
        player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = walkSpeed
    end
end)

--------------------------------------------------
-- UI SYSTEM (SCROLLABLE MENU)
--------------------------------------------------
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "LixxScriptUI"
sg.ResetOnSpawn = false

-- Frame Utama (Sekarang pakai Scrolling agar muat semua)
local mainFrame = Instance.new("ScrollingFrame", sg)
mainFrame.Size = UDim2.fromOffset(240, 350)
mainFrame.Position = UDim2.new(0.5, -120, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.CanvasSize = UDim2.new(0, 0, 0, 550) -- Ukuran scroll ke bawah
mainFrame.ScrollBarThickness = 6

local uiList = Instance.new("UIListLayout", mainFrame)
uiList.Padding =信号.new(0, 8)
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Text = "LIXX FISH IT V2"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold

-- Speed & Fly Inputs
local function createInput(place)
    local i = Instance.new("TextBox", mainFrame)
    i.PlaceholderText = place
    i.Size = UDim2.new(0.9, 0, 0, 35)
    i.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    i.TextColor3 = Color3.new(1, 1, 1)
    return i
end

local speedInp = createInput("Set WalkSpeed (Def: 16)")
speedInp.FocusLost:Connect(function() walkSpeed = tonumber(speedInp.Text) or 16 end)

local flyInp = createInput("Set FlySpeed (Def: 50)")
flyInp.FocusLost:Connect(function() flySpeed = tonumber(flyInp.Text) or 50 end)

local btnFly = Instance.new("TextButton", mainFrame)
btnFly.Text = "FLY: OFF"
btnFly.Size = UDim2.new(0.9, 0, 0, 40)
btnFly.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
btnFly.TextColor3 = Color3.new(1, 1, 1)

--------------------------------------------------
-- TELEPORT SECTION
--------------------------------------------------
local tpTitle = Instance.new("TextLabel", mainFrame)
tpTitle.Text = "--- TELEPORT USER ---"
tpTitle.Size = UDim2.new(1, 0, 0, 30)
tpTitle.BackgroundTransparency = 1
tpTitle.TextColor3 = Color3.new(1, 1, 0)
tpTitle.Font = Enum.Font.GothamBold

local tpContainer = Instance.new("Frame", mainFrame)
tpContainer.Size = UDim2.new(0.9, 0, 0, 150)
tpContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local tpScroll = Instance.new("ScrollingFrame", tpContainer)
tpScroll.Size = UDim2.new(1, 0, 1, 0)
tpScroll.BackgroundTransparency = 1
tpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local tpList = Instance.new("UIListLayout", tpScroll)

local function refreshPlayers()
    for _, child in pairs(tpScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local pBtn = Instance.new("TextButton", tpScroll)
            pBtn.Text = p.DisplayName or p.Name
            pBtn.Size = UDim2.new(1, 0, 0, 30)
            pBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            pBtn.TextColor3 = Color3.new(1, 1, 1)
            pBtn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character:SetPrimaryPartCFrame(p.Character.HumanoidRootPart.CFrame)
                end
            end)
        end
    end
    tpScroll.CanvasSize = UDim2.new(0, 0, 0, tpList.AbsoluteContentSize.Y)
end

local btnRefresh = Instance.new("TextButton", mainFrame)
btnRefresh.Text = "🔄 REFRESH LIST"
btnRefresh.Size = UDim2.new(0.9, 0, 0, 35)
btnRefresh.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
btnRefresh.TextColor3 = Color3.new(1, 1, 1)

-- Handlers
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

btnRefresh.MouseButton1Click:Connect(refreshPlayers)
refreshPlayers()
