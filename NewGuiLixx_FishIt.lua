-- [[ L - VIOLENCE DISTRIK GACOR V3 (FIXED FOLLOW, GOD MODE, AIM) ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // States
local _G = {
    Fly = false, Speed = 100, SpeedEnabled = false, FollowEnabled = false,
    FollowTarget = nil, AutoAim = false, AimType = "Killer", GodMode = false,
    KillerMode = false, NoCD = false, ESP = false, CurrentEmote = "Duduk"
}

-- // UI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "L_Gacor_V3_UI"

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

-- Main Frame (Menu)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 420) -- Sedikit lebih tinggi buat aim dropdown
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "L - VIOLENCE DISTRIK V3"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
Title.TextSize = 18
Instance.new("UICorner", Title)

-- Container Scroll
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -10, 1, -50)
Scroll.Position = UDim2.new(0, 5, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 3.5, 0) -- Lebih panjang buat aim dropdown
Scroll.ScrollBarThickness = 4
local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Toggle UI Logic
L_Btn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- // FITUR UPDATE // --

-- 1. Custom Speed Input
local SpeedInput = Instance.new("TextBox", Scroll)
SpeedInput.Size = UDim2.new(0, 250, 0, 35)
SpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedInput.Text = "100"
SpeedInput.TextColor3 = Color3.new(0, 1, 0)
SpeedInput.TextSize = 20
Instance.new("UICorner", SpeedInput)
SpeedInput.FocusLost:Connect(function()
    _G.Speed = tonumber(SpeedInput.Text) or 16
end)

-- 2. Follow Player List & Refresh
local TargetDisplay = Instance.new("TextLabel", Scroll)
TargetDisplay.Size = UDim2.new(0, 250, 0, 35)
TargetDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TargetDisplay.Text = "Target: None"
TargetDisplay.TextColor3 = Color3.new(1, 0.8, 0)
Instance.new("UICorner", TargetDisplay)

local PlayerListContainer = Instance.new("Frame", Scroll)
PlayerListContainer.Size = UDim2.new(0, 250, 0, 120)
PlayerListContainer.BackgroundTransparency = 1
local PScroll = Instance.new("ScrollingFrame", PlayerListContainer)
PScroll.Size = UDim2.new(1, 0, 1, 0)
PScroll.CanvasSize = UDim2.new(0, 0, 5, 0)
local PLayout = Instance.new("UIListLayout", PScroll)

local function UpdatePlayerList()
    for _, child in pairs(PScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", PScroll)
            pBtn.Size = UDim2.new(1, -5, 0, 25)
            pBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            pBtn.Text = p.Name
            pBtn.TextColor3 = Color3.new(1,1,1)
            pBtn.MouseButton1Click:Connect(function()
                _G.FollowTarget = p
                TargetDisplay.Text = "Target: " .. p.Name
            end)
            Instance.new("UICorner", pBtn)
        end
    end
end
UpdatePlayerList()

local RefBtn = Instance.new("TextButton", Scroll)
RefBtn.Size = UDim2.new(0, 250, 0, 30)
RefBtn.Text = "REFRESH LIST PLAYER"
RefBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
RefBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", RefBtn)
RefBtn.MouseButton1Click:Connect(UpdatePlayerList)

-- 3. Auto Aim Target Type
local AimTypeLabel = Instance.new("TextLabel", Scroll)
AimTypeLabel.Size = UDim2.new(0, 250, 0, 20)
AimTypeLabel.Text = "AUTO AIM TARGET:"
AimTypeLabel.TextColor3 = Color3.new(1,1,1)
AimTypeLabel.BackgroundTransparency = 1

local AimTypeDisplay = Instance.new("TextLabel", Scroll)
AimTypeDisplay.Size = UDim2.new(0, 250, 0, 35)
AimTypeDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AimTypeDisplay.Text = "Type: Killer"
AimTypeDisplay.TextColor3 = Color3.new(1, 0.8, 0)
Instance.new("UICorner", AimTypeDisplay)

local AimDropdownBtn = Instance.new("TextButton", Scroll)
AimDropdownBtn.Size = UDim2.new(0, 250, 0, 35)
AimDropdownBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
AimDropdownBtn.Text = "PILIH TARGET AIM (Killer/Survivor/All)"
AimDropdownBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", AimDropdownBtn)

local AimDropdown = Instance.new("Frame", Scroll)
AimDropdown.Size = UDim2.new(0, 230, 0, 75)
AimDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AimDropdown.Visible = false
Instance.new("UICorner", AimDropdown)
local ADLayout = Instance.new("UIListLayout", AimDropdown)

for _, type in pairs({"Killer", "Survivor", "All"}) do
    local ab = Instance.new("TextButton", AimDropdown)
    ab.Size = UDim2.new(1, 0, 0, 25)
    ab.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ab.Text = type
    ab.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", ab)
    ab.MouseButton1Click:Connect(function()
        _G.AimType = type
        AimTypeDisplay.Text = "Type: " .. type
        AimDropdown.Visible = false
    end)
end

AimDropdownBtn.MouseButton1Click:Connect(function()
    AimDropdown.Visible = not AimDropdown.Visible
end)

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

-- // FITUR EKSEKUSI // --

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

-- **[BENERIN FIX]** Karakter diem posisi U pas follow
CreateToggle("Auto Follow & Emote", function(state)
    _G.FollowEnabled = state
    local hrp_joint = nil
    task.spawn(function()
        while _G.FollowEnabled and _G.FollowTarget do
            local char = LocalPlayer.Character
            local tchar = _G.FollowTarget.Character
            if char and tchar and tchar:FindFirstChild("HumanoidRootPart") then
                -- Teleport tujuannya nempel, diem total
                char.HumanoidRootPart.CFrame = tchar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2.5) -- Nempel lebih rapet
                char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0) -- Hentikan inersia lari
                char.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0) -- Hentikan putaran
                
                -- Emote Lucu (Sit & RootJoint Manip total diem)
                char.Humanoid.Sit = true
                if char.HumanoidRootPart:FindFirstChild("RootJoint") then
                   char.HumanoidRootPart.RootJoint.C0 = char.HumanoidRootPart.RootJoint.C0 * CFrame.Angles(math.rad(10),0,0)
                   char.HumanoidRootPart.RootJoint.C1 = char.HumanoidRootPart.RootJoint.C1 * CFrame.Angles(0,0,0)
                end
            end
            task.wait(0.1) -- Sedikit delay buat sinkronisasi teleport total diem
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
        for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("L_ESP") then p.Character.L_ESP:Destroy() end end
    end)
end)

-- **[BENERIN FIX]** Auto Aim bisa milih target
CreateToggle("Auto Aim Pistol", function(state)
    _G.AutoAim = state
    task.spawn(function()
        while _G.AutoAim do
            RunService.RenderStepped:Wait()
            local t = nil local d = math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character:FindFirstChild("HumanoidRootPart") then
                    -- Logic filter Killer/Survivor
                    local isK = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    if (_G.AimType == "Killer" and isK) or (_G.AimType == "Survivor" and not isK) or (_G.AimType == "All") then
                        local m = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if m < d then d = m t = p end
                    end
                end
            end
            if t and t.Character and tool_equipped then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.HumanoidRootPart.Position) end
        end
    end)
end)

-- **[BENERIN FIX]** Kebal tetep berdiri gak knock
CreateToggle("God Mode", function(state)
    _G.GodMode = state
    task.spawn(function()
        while _G.GodMode do 
            if LocalPlayer.Character:FindFirstChild("Humanoid") then 
                LocalPlayer.Character.Humanoid.Health = 100
                -- Paksa tetep berdiri total (anti knock physics)
                LocalPlayer.Character.Humanoid.PlatformStand = false
                LocalPlayer.Character.Humanoid.SeatPart = nil
                LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                -- Izinkan pake item (tidak hapus debounce, cuma paksa posisi berdiri)
            end 
            task.wait() 
        end
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

-- Cek jika LocalPlayer pake pistol/tool
LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child) if child:IsA("Tool") then tool_equipped = true end end)
    char.ChildRemoved:Connect(function(child) if child:IsA("Tool") then tool_equipped = false end end)
end)

print("L-GACOR V3 SIAP RUSUH, FIX TOTAL BOSKU!")
