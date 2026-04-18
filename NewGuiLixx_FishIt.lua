-- [[ L - VIOLENCE DISTRIK GACOR V4 (HARD-LOCK EDITION) ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // States
local _G = {
    Fly = false, Speed = 100, SpeedEnabled = false, FollowEnabled = false,
    FollowTarget = nil, AutoAim = false, AimTarget = nil, GodMode = false,
    KillerMode = false, NoCD = false, ESP = false
}

-- // UI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local L_Btn = Instance.new("TextButton", ScreenGui)
L_Btn.Size = UDim2.new(0, 55, 0, 55)
L_Btn.Position = UDim2.new(0, 10, 0, 200)
L_Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
L_Btn.Text = "L"
L_Btn.TextSize = 35
L_Btn.TextColor3 = Color3.new(1,1,1)
L_Btn.Draggable = true
Instance.new("UICorner", L_Btn).CornerRadius = UDim.new(0, 15)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 420)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "L - VIOLENCE DISTRIK V4"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
Title.TextSize = 18
Instance.new("UICorner", Title)

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -10, 1, -50)
Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 4, 0)
Scroll.ScrollBarThickness = 4
local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

L_Btn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- // FITUR UPDATE // --

-- 1. Custom Speed
local SpeedInput = Instance.new("TextBox", Scroll)
SpeedInput.Size = UDim2.new(0, 250, 0, 35)
SpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedInput.Text = "100"
SpeedInput.TextColor3 = Color3.new(0, 1, 0)
Instance.new("UICorner", SpeedInput)
SpeedInput.FocusLost:Connect(function() _G.Speed = tonumber(SpeedInput.Text) or 16 end)

-- 2. List Player untuk Aim & Follow
local TargetLabel = Instance.new("TextLabel", Scroll)
TargetLabel.Size = UDim2.new(0, 250, 0, 25)
TargetLabel.Text = "PILIH USERNAME (UNTUK AIM & FOLLOW):"
TargetLabel.TextColor3 = Color3.new(1,1,1)
TargetLabel.BackgroundTransparency = 1

local CurrentTarget = Instance.new("TextLabel", Scroll)
CurrentTarget.Size = UDim2.new(0, 250, 0, 30)
CurrentTarget.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CurrentTarget.Text = "Target: None"
CurrentTarget.TextColor3 = Color3.new(1, 0.8, 0)
Instance.new("UICorner", CurrentTarget)

local PList = Instance.new("ScrollingFrame", Scroll)
PList.Size = UDim2.new(0, 250, 0, 100)
PList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
local PLay = Instance.new("UIListLayout", PList)

local function RefreshPlayers()
    for _, v in pairs(PList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton", PList)
            b.Size = UDim2.new(1, 0, 0, 25)
            b.Text = p.Name
            b.TextColor3 = Color3.new(1,1,1)
            b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            b.MouseButton1Click:Connect(function()
                _G.AimTarget = p
                _G.FollowTarget = p
                CurrentTarget.Text = "Target: " .. p.Name
            end)
        end
    end
end
RefreshPlayers()

local Ref = Instance.new("TextButton", Scroll)
Ref.Size = UDim2.new(0, 250, 0, 30)
Ref.Text = "REFRESH LIST"
Ref.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Instance.new("UICorner", Ref)
Ref.MouseButton1Click:Connect(RefreshPlayers)

-- // HELPER TOGGLE
local function CreateToggle(name, callback)
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(0, 250, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.Text = name .. " : OFF"
    Btn.TextColor3 = Color3.new(1,1,1)
    local on = false
    Btn.MouseButton1Click:Connect(function()
        on = not on
        Btn.Text = name .. " : " .. (on and "ON" or "OFF")
        Btn.BackgroundColor3 = on and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(50, 50, 50)
        callback(on)
    end)
    Instance.new("UICorner", Btn)
end

-- // EKSEKUSI FITUR FIX // --

-- FIX: FOLLOW DIAM (HARD LOCK)
CreateToggle("Auto Follow & Emote", function(state)
    _G.FollowEnabled = state
    task.spawn(function()
        while _G.FollowEnabled and _G.FollowTarget do
            local char = LocalPlayer.Character
            local tchar = _G.FollowTarget.Character
            if char and tchar and tchar:FindFirstChild("HumanoidRootPart") then
                -- Hard Lock Position (Biar gak lasak)
                char.HumanoidRootPart.CFrame = tchar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2.5)
                char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                char.Humanoid.Sit = true -- Posisi Duduk
            end
            RunService.Heartbeat:Wait() -- Lebih stabil dari task.wait
        end
        if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = false end
    end)
end)

-- FIX: AUTO AIM BY USERNAME
CreateToggle("Auto Aim Pistol", function(state)
    _G.AutoAim = state
    task.spawn(function()
        while _G.AutoAim do
            if _G.AimTarget and _G.AimTarget.Character and _G.AimTarget.Character:FindFirstChild("HumanoidRootPart") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, _G.AimTarget.Character.HumanoidRootPart.Position)
            end
            RunService.RenderStepped:Wait()
        end
    end)
end)

-- FIX: GOD MODE (KEBAL STANDING)
CreateToggle("God Mode", function(state)
    _G.GodMode = state
    task.spawn(function()
        while _G.GodMode do
            local h = LocalPlayer.Character:FindFirstChild("Humanoid")
            if h then
                h.Health = 100
                if h.PlatformStand == true then h.PlatformStand = false end -- Paksa berdiri kalau knock
            end
            task.wait()
        end
    end)
end)

-- FITUR LAIN (TETAP SAMA)
CreateToggle("Fast Run", function(state)
    _G.SpeedEnabled = state
    task.spawn(function()
        while _G.SpeedEnabled do
            if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = _G.Speed end
            task.wait()
        end
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end)
end)

CreateToggle("Fly Mode", function(state)
    _G.Fly = state
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    task.spawn(function()
        while _G.Fly do
            bv.Parent = LocalPlayer.Character.HumanoidRootPart
            bv.Velocity = Camera.CFrame.LookVector * 100
            task.wait()
        end
        bv:Destroy()
    end)
end)

CreateToggle("Killer Mode (TP KILL)", function(state)
    _G.KillerMode = state
    task.spawn(function()
        while _G.KillerMode do
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                    task.wait(0.3)
                end
            end
            task.wait()
        end
    end)
end)

CreateToggle("No Cooldown", function(state)
    _G.NoCD = state
    task.spawn(function()
        while _G.NoCD do
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v.Name == "Cooldown" or v.Name == "Stun" then v:Destroy() end
            end
            task.wait()
        end
    end)
end)

print("L-V4 FIXED TOTAL!")
