-- [[ L - VIOLENCE DISTRIK GACOR UPDATE: LIST PLAYER & CUSTOM SPEED ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // States
local _G = {
    Fly = false, Speed = 100, SpeedEnabled = false, FollowEnabled = false,
    FollowTarget = nil, AutoAim = false, AimType = "All", GodMode = false,
    KillerMode = false, NoCD = false, ESP = false, CurrentEmote = "Duduk"
}

-- // UI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "L_Gacor_Update_UI"

-- Floating Button L
local L_Btn = Instance.new("TextButton", ScreenGui)
L_Btn.Size = UDim2.new(0, 55, 0, 55)
L_Btn.Position = UDim2.new(0, 10, 0, 200)
L_Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
L_Btn.Text = "L"
L_Btn.TextSize = 35
L_Btn.TextColor3 = Color3.new(1,1,1)
L_Btn.Draggable = true
Instance.new("UICorner", L_Btn).CornerRadius = UDim.new(0, 15)

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 380)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Visible = false
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "L - VIOLENCE DISTRIK V2"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
Title.TextSize = 18
Instance.new("UICorner", Title)

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -10, 1, -50)
Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2.5, 0)
Scroll.ScrollBarThickness = 4
local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Toggle UI
L_Btn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- // FITUR UPDATE // --

-- 1. Custom Speed Input
local SpeedLabel = Instance.new("TextLabel", Scroll)
SpeedLabel.Size = UDim2.new(0, 250, 0, 20)
SpeedLabel.Text = "SET SPEED (ANGKA):"
SpeedLabel.TextColor3 = Color3.new(1,1,1)
SpeedLabel.BackgroundTransparency = 1

local SpeedInput = Instance.new("TextBox", Scroll)
SpeedInput.Size = UDim2.new(0, 250, 0, 35)
SpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedInput.Text = "100"
SpeedInput.TextColor3 = Color3.new(0,1,0)
SpeedInput.TextSize = 20
Instance.new("UICorner", SpeedInput)

SpeedInput.FocusLost:Connect(function()
    _G.Speed = tonumber(SpeedInput.Text) or 16
end)

-- 2. Follow Player List
local FollowLabel = Instance.new("TextLabel", Scroll)
FollowLabel.Size = UDim2.new(0, 250, 0, 20)
FollowLabel.Text = "PILIH USERNAME TARGET:"
FollowLabel.TextColor3 = Color3.new(1,1,1)
FollowLabel.BackgroundTransparency = 1

local TargetDisplay = Instance.new("TextLabel", Scroll)
TargetDisplay.Size = UDim2.new(0, 250, 0, 35)
TargetDisplay.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TargetDisplay.Text = "Target: None"
TargetDisplay.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", TargetDisplay)

local function UpdateFollowList()
    -- Fungsi ini buat button list player
    for _, child in pairs(Scroll:GetChildren()) do
        if child.Name == "PlayerBtn" then child:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", Scroll)
            pBtn.Name = "PlayerBtn"
            pBtn.Size = UDim2.new(0, 230, 0, 30)
            pBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            pBtn.Text = p.Name
            pBtn.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", pBtn)
            pBtn.MouseButton1Click:Connect(function()
                _G.FollowTarget = p
                TargetDisplay.Text = "Target: " .. p.Name
                TargetDisplay.TextColor3 = Color3.new(1, 0.8, 0)
            end)
        end
    end
end
UpdateFollowList()

-- Tombol Refresh Player
local RefBtn = Instance.new("TextButton", Scroll)
RefBtn.Size = UDim2.new(0, 250, 0, 30)
RefBtn.Text = "REFRESH PLAYER LIST"
RefBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
RefBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", RefBtn)
RefBtn.MouseButton1Click:Connect(UpdateFollowList)

-- // FUNGSI TOGGLE (KODE TETAP)
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

-- // EKSEKUSI FITUR // --

CreateToggle("Fast Run", function(state)
    _G.SpeedEnabled = state
    task.spawn(function()
        while _G.SpeedEnabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = _G.Speed
            end
            task.wait()
        end
        if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
    end)
end)

CreateToggle("Auto Follow & Emote", function(state)
    _G.FollowEnabled = state
    task.spawn(function()
        while _G.FollowEnabled and _G.FollowTarget do
            local char = LocalPlayer.Character
            local tchar = _G.FollowTarget.Character
            if char and tchar and tchar:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = tchar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                -- Emote Lucu Nyoli/Duduk
                char.Humanoid.Sit = true
                char.HumanoidRootPart.RootJoint.C0 = char.HumanoidRootPart.RootJoint.C0 * CFrame.Angles(math.rad(10),0,0)
            end
            task.wait()
        end
        if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = false end
    end)
end)

CreateToggle("Fly Mode", function(state)
    _G.Fly = state
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    task.spawn(function()
        while _G.Fly do
            RunService.RenderStepped:Wait()
            if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                bv.Parent = LocalPlayer.Character.HumanoidRootPart
                bv.Velocity = Camera.CFrame.LookVector * 100
            end
        end
        bv:Destroy()
    end)
end)

CreateToggle("Mode Look (ESP)", function(state)
    _G.ESP = state
    task.spawn(function()
        while _G.ESP do
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if not p.Character:FindFirstChild("L_ESP") then
                        local hl = Instance.new("Highlight", p.Character)
                        hl.Name = "L_ESP"
                        local isK = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                        hl.FillColor = isK and Color3.new(1,0,0) or Color3.new(0,1,0)
                    end
                end
            end
            task.wait(1)
        end
        for _, p in pairs(Players:GetPlayers()) do if p.Character:FindFirstChild("L_ESP") then p.Character.L_ESP:Destroy() end end
    end)
end)

CreateToggle("Auto Aim Pistol", function(state)
    _G.AutoAim = state
    task.spawn(function()
        while _G.AutoAim do
            RunService.RenderStepped:Wait()
            local t = nil local d = math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character:FindFirstChild("HumanoidRootPart") then
                    local m = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if m < d then d = m t = p end
                end
            end
            if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.HumanoidRootPart.Position) end
        end
    end)
end)

CreateToggle("God Mode", function(state)
    _G.GodMode = state
    task.spawn(function()
        while _G.GodMode do LocalPlayer.Character.Humanoid.Health = 100 task.wait() end
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

print("L-GACOR V2 LOADED!")
