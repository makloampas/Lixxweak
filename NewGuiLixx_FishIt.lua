-- [[ L - VIOLENCE DISTRIK MEGA SCRIPT ]] --
-- UI Library Setup
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("L - VIOLENCE DISTRIK", "GrapeTheme")

-- // Services & Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // States
local _G = {
    Fly = false,
    Speed = 16,
    SpeedEnabled = false,
    FollowEnabled = false,
    FollowTarget = nil,
    AutoAim = false,
    AimType = "All",
    GodMode = false,
    KillerMode = false,
    NoCD = false,
    ESP = false,
    CurrentEmote = nil
}

-- // UI TOGGLE BUTTON "L"
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainToggle = Instance.new("TextButton", ScreenGui)
local Corner = Instance.new("UICorner", MainToggle)

MainToggle.Name = "L_Button"
MainToggle.Size = UDim2.new(0, 60, 0, 60)
MainToggle.Position = UDim2.new(0, 20, 0, 200)
MainToggle.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
MainToggle.Text = "L"
MainToggle.TextColor3 = Color3.new(1,1,1)
MainToggle.TextSize = 40
MainToggle.Draggable = true
Corner.CornerRadius = UDim.new(0, 15)

MainToggle.MouseButton1Click:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
end)

-- // FUNCTIONS
local function getTarget()
    local target = nil
    local dist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local mag = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if mag < dist then
                -- Logic filter Killer/Survivor
                local isKiller = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                if _G.AimType == "All" or (_G.AimType == "Killer" and isKiller) or (_G.AimType == "Survivor" and not isKiller) then
                    dist = mag
                    target = p
                end
            end
        end
    end
    return target
end

-- // TAB 1: MOVEMENT
local Tab1 = Window:NewTab("Movement")
local Sec1 = Tab1:NewSection("Fly & Speed")

Sec1:NewToggle("Fly Mode", "Terbang (Analog & Kamera)", function(state)
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

Sec1:NewSlider("Run Speed", "Atur Kecepatan", 500, 16, function(s) _G.Speed = s end)
Sec1:NewToggle("Enable Fast Run", "Lari Cepat", function(state)
    _G.SpeedEnabled = state
    task.spawn(function()
        while _G.SpeedEnabled do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = _G.Speed
            end
            task.wait()
        end
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end)
end)

-- // TAB 2: SOCIAL & FOLLOW
local Tab2 = Window:NewTab("Avatar & Emote")
local Sec2 = Tab2:NewSection("Emote & Auto Follow")

Sec2:NewDropdown("Pilih Emote", "Animasi Custom", {"Nyoli", "Lelah", "Duduk"}, function(e) _G.CurrentEmote = e end)

local p_names = {}
local function updatePlayers()
    p_names = {}
    for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then table.insert(p_names, v.Name) end end
end
updatePlayers()

Sec2:NewDropdown("Pilih Player", "Daftar User", p_names, function(selected) _G.FollowTarget = Players:FindFirstChild(selected) end)

Sec2:NewToggle("Auto Follow Player", "Kejar & Tempel (ON/OFF)", function(state)
    _G.FollowEnabled = state
    task.spawn(function()
        while _G.FollowEnabled and _G.FollowTarget do
            local char = LocalPlayer.Character
            local tchar = _G.FollowTarget.Character
            if char and tchar and tchar:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = tchar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                
                -- Emote Logic
                if _G.CurrentEmote == "Nyoli" then
                   char.HumanoidRootPart.RootJoint.C0 = char.HumanoidRootPart.RootJoint.C0 * CFrame.Angles(math.rad(10),0,0)
                elseif _G.CurrentEmote == "Lelah" then
                    char.Humanoid.PlatformStand = true
                elseif _G.CurrentEmote == "Duduk" then
                    char.Humanoid.Sit = true
                end
            end
            task.wait()
        end
        if LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = false
            LocalPlayer.Character.Humanoid.Sit = false
        end
    end)
end)

-- // TAB 3: VISUALS (MODE LOOK)
local Tab3 = Window:NewTab("Visuals")
local Sec3 = Tab3:NewSection("Mode Look ESP")

Sec3:NewToggle("Mode Look (ESP)", "Garis Hijau (Survivor) / Merah (Killer)", function(state)
    _G.ESP = state
    while _G.ESP do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("L_ESP") then
                    local hl = Instance.new("Highlight", p.Character)
                    hl.Name = "L_ESP"
                    local isKiller = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                    hl.FillColor = isKiller and Color3.new(1,0,0) or Color3.new(0,1,0)
                    hl.FillTransparency = 0.5
                end
            end
        end
        task.wait(1)
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("L_ESP") then p.Character.L_ESP:Destroy() end
    end
end)

-- // TAB 4: COMBAT & KILLER
local Tab4 = Window:NewTab("Combat")
local Sec4 = Tab4:NewSection("Auto Aim & Killer Mode")

Sec4:NewDropdown("Aim Target", "Pilih Filter", {"Survivor", "Killer", "All"}, function(t) _G.AimType = t end)
Sec4:NewToggle("Auto Aim Pistol", "Lock ke Kepala", function(state)
    _G.AutoAim = state
    RunService.RenderStepped:Connect(function()
        if _G.AutoAim then
            local t = getTarget()
            if t and t.Character then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.HumanoidRootPart.Position)
            end
        end
    end)
end)

Sec4:NewToggle("Kebal (God Mode)", "Anti Death", function(state)
    _G.GodMode = state
    task.spawn(function()
        while _G.GodMode do
            LocalPlayer.Character.Humanoid.Health = 100
            task.wait()
        end
    end)
end)

Sec4:NewToggle("Mode Killer Ganas", "Auto TP & Attack", function(state)
    _G.KillerMode = state
    task.spawn(function()
        while _G.KillerMode do
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                    task.wait(0.4)
                end
            end
            task.wait()
        end
    end)
end)

Sec4:NewToggle("No Cooldown", "Spam Skill", function(state)
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

-- [[ FINALIZING ]] --
print("L-Script Loaded. Gaskeun Bosku!")
