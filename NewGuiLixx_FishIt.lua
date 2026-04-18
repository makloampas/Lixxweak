-- [[ L - VIOLENCE DISTRIK CUSTOM UI GACOR ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // States
local _G = {
    Fly = false, Speed = 16, SpeedEnabled = false, FollowEnabled = false,
    FollowTarget = nil, AutoAim = false, AimType = "All", GodMode = false,
    KillerMode = false, NoCD = false, ESP = false, CurrentEmote = "Duduk"
}

-- // UI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "L_Gacor_UI"

-- Floating Button L
local L_Btn = Instance.new("TextButton", ScreenGui)
L_Btn.Size = UDim2.new(0, 50, 0, 50)
L_Btn.Position = UDim2.new(0, 10, 0, 200)
L_Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
L_Btn.Text = "L"
L_Btn.TextSize = 30
L_Btn.TextColor3 = Color3.new(1,1,1)
L_Btn.Draggable = true
local CornerL = Instance.new("UICorner", L_Btn)
CornerL.CornerRadius = UDim.new(0, 12)

-- Main Frame (Menu)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 350)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Draggable = true -- BISA DIGESER
local CornerM = Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "L - VIOLENCE DISTRIK"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
Title.TextSize = 18
Instance.new("UICorner", Title)

-- Container Scroll buat Button
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -10, 1, -50)
Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
Scroll.ScrollBarThickness = 4

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- // HELPER FUNCTION BUAT BIKIN BUTTON
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

-- // TOGGLE UI LOGIC
L_Btn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- // FITUR-FITUR // --

-- 1. Fly
CreateToggle("Fly Mode", function(state)
    _G.Fly = state
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    task.spawn(function()
        while _G.Fly do
            RunService.RenderStepped:Wait()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                bv.Parent = LocalPlayer.Character.HumanoidRootPart
                bv.Velocity = Camera.CFrame.LookVector * 100
            end
        end
        bv:Destroy()
    end)
end)

-- 2. Speed
CreateToggle("Fast Run (500)", function(state)
    _G.SpeedEnabled = state
    task.spawn(function()
        while _G.SpeedEnabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 500
            end
            task.wait()
        end
        if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
    end)
end)

-- 3. Emote & Follow (Auto Detect Target)
CreateToggle("Auto Follow & Emote", function(state)
    _G.FollowEnabled = state
    task.spawn(function()
        while _G.FollowEnabled do
            local target = nil
            local dist = math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local m = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if m < dist then dist = m target = p end
                end
            end
            if target and target.Character then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                -- Emote Lelah/Duduk sederhana
                LocalPlayer.Character.Humanoid.Sit = true
            end
            task.wait()
        end
        LocalPlayer.Character.Humanoid.Sit = false
    end)
end)

-- 4. ESP (Mode Look)
CreateToggle("Mode Look (ESP)", function(state)
    _G.ESP = state
    task.spawn(function()
        while _G.ESP do
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if not p.Character:FindFirstChild("L_ESP") then
                        local hl = Instance.new("Highlight", p.Character)
                        hl.Name = "L_ESP"
                        local isKiller = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                        hl.FillColor = isKiller and Color3.new(1,0,0) or Color3.new(0,1,0)
                    end
                end
            end
            task.wait(1)
        end
        for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("L_ESP") then p.Character.L_ESP:Destroy() end end
    end)
end)

-- 5. Auto Aim
CreateToggle("Auto Aim Pistol", function(state)
    _G.AutoAim = state
    task.spawn(function()
        while _G.AutoAim do
            RunService.RenderStepped:Wait()
            local target = nil
            local dist = math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local m = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if m < dist then dist = m target = p end
                end
            end
            if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position) end
        end
    end)
end)

-- 6. God Mode
CreateToggle("God Mode (Kebal)", function(state)
    _G.GodMode = state
    task.spawn(function()
        while _G.GodMode do 
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Health = 100 end
            task.wait() 
        end
    end)
end)

-- 7. Killer Mode
CreateToggle("Killer Mode (TP KILL)", function(state)
    _G.KillerMode = state
    task.spawn(function()
        while _G.KillerMode do
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") then
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

-- 8. No Cooldown
CreateToggle("No Cooldown / Anti Stun", function(state)
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

print("L-CUSTOM UI GACOR LOADED!")
