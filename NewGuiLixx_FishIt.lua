-- [[ L - VIOLENCE DISTRIK GACOR V6 (REFRESH BUTTON RESTORED) ]] --
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
Title.Text = "L - VIOLENCE DISTRIK V6"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
Title.TextSize = 18
Instance.new("UICorner", Title)

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -10, 1, -50)
Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 4.5, 0)
Scroll.ScrollBarThickness = 4
local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

L_Btn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

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

-- // FITUR UTAMA // --

-- 1. MODE LOOK (ESP)
CreateToggle("Mode Look (ESP)", function(state)
    _G.ESP = state
    task.spawn(function()
        while _G.ESP do
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local highlight = p.Character:FindFirstChild("L_ESP")
                    if not highlight then
                        highlight = Instance.new("Highlight", p.Character)
                        highlight.Name = "L_ESP"
                    end
                    local isKiller = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    highlight.FillColor = isKiller and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
                    highlight.FillTransparency = 0.5
                end
            end
            task.wait(1)
        end
        for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("L_ESP") then p.Character.L_ESP:Destroy() end end
    end)
end)

-- 2. SET SPEED
local SpeedInput = Instance.new("TextBox", Scroll)
SpeedInput.Size = UDim2.new(0, 250, 0, 35)
SpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedInput.Text = "100"
SpeedInput.TextColor3 = Color3.new(0, 1, 0)
Instance.new("UICorner", SpeedInput)
SpeedInput.FocusLost:Connect(function() _G.Speed = tonumber(SpeedInput.Text) or 16 end)

-- 3. PLAYER LIST & REFRESH (INI YANG TADI ILANG)
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
            end)
            Instance.new("UICorner", b)
        end
    end
end

-- TOMBOL REFRESH PLAYER LIST
local RefBtn = Instance.new("TextButton", Scroll)
RefBtn.Size = UDim2.new(0, 250, 0, 30)
RefBtn.Text = "REFRESH PLAYER LIST"
RefBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
RefBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", RefBtn)
RefBtn.MouseButton1Click:Connect(RefreshPlayers)
RefreshPlayers()

-- 4. AUTO FOLLOW & EMOTE
CreateToggle("Auto Follow & Emote", function(state)
    _G.FollowEnabled = state
    task.spawn(function()
        while _G.FollowEnabled and _G.FollowTarget do
            local char = LocalPlayer.Character
            local tchar = _G.FollowTarget.Character
            if char and tchar and tchar:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = tchar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2.5)
                char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                char.Humanoid.Sit = true 
            end
            RunService.Heartbeat:Wait()
        end
        if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = false end
    end)
end)

-- 5. AUTO AIM
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

-- 6. GOD MODE
CreateToggle("God Mode", function(state)
    _G.GodMode = state
    task.spawn(function()
        while _G.GodMode do
            local h = LocalPlayer.Character:FindFirstChild("Humanoid")
            if h then
                h.Health = 100
                if h.PlatformStand == true then h.PlatformStand = false end
            end
            task.wait()
        end
    end)
end)

-- 7. FAST RUN
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

-- 8. FLY MODE
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

-- 9. KILLER MODE
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

-- 10. NO COOLDOWN
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

print("L-V6 GACOR: SEMUA MENU & REFRESH SIAP!")
