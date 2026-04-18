-- [[ L - VIOLENCE DISTRIK GACOR EDITION (FIXED UI) ]] --
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("L - VIOLENCE DISTRIK", "GrapeTheme")

-- Simpan referensi Main Frame UI Kavo
local MainFrame = game:GetService("CoreGui"):FindFirstChild("L - VIOLENCE DISTRIK") or game:GetService("CoreGui"):WaitForChild("L - VIOLENCE DISTRIK")

-- // LOGIC OPEN/CLOSE DENGAN TOMBOL X & LOGO L
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local L_Button = Instance.new("TextButton", ScreenGui)
local Corner = Instance.new("UICorner", L_Button)

L_Button.Name = "L_Toggle"
L_Button.Size = UDim2.new(0, 60, 0, 60)
L_Button.Position = UDim2.new(0, 20, 0, 200)
L_Button.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
L_Button.Text = "L"
L_Button.TextColor3 = Color3.new(1,1,1)
L_Button.TextSize = 40
L_Button.Draggable = true
Corner.CornerRadius = UDim.new(0, 15)

-- Tambahkan Tombol X di UI Kavo secara manual
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame:FindFirstChild("Main") or MainFrame
CloseBtn.Name = "CloseButton"
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5) -- Pojok kanan atas
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 20

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 5)

-- Fungsi Close (X)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Enabled = false
end)

-- Fungsi Open (L)
L_Button.MouseButton1Click:Connect(function()
    MainFrame.Enabled = not MainFrame.Enabled
end)

-- =========================================================
-- JANGAN UBAH KODE DI BAWAH (FITUR TETAP SAMA SEPERTI SEBELUMNYA)
-- =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local _G = {
    Fly = false, Speed = 16, SpeedEnabled = false, FollowEnabled = false,
    FollowTarget = nil, AutoAim = false, AimType = "All", GodMode = false,
    KillerMode = false, NoCD = false, ESP = false, CurrentEmote = nil
}

-- TAB: MOVEMENT
local Tab1 = Window:NewTab("Movement")
local Sec1 = Tab1:NewSection("Terbang & Lari")
Sec1:NewToggle("Fly Mode", "Terbang", function(state)
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
Sec1:NewSlider("Run Speed", "Speed", 500, 16, function(s) _G.Speed = s end)
Sec1:NewToggle("Fast Run", "Lari", function(state)
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

-- TAB: AVATAR & EMOTE
local Tab2 = Window:NewTab("Avatar & Emote")
local Sec2 = Tab2:NewSection("Emote & Auto Follow")
Sec2:NewDropdown("Pilih Emote", "Animasi", {"Nyoli", "Lelah", "Duduk"}, function(e) _G.CurrentEmote = e end)
local p_names = {}
for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then table.insert(p_names, v.Name) end end
Sec2:NewDropdown("Pilih Player", "Daftar User", p_names, function(selected) _G.FollowTarget = Players:FindFirstChild(selected) end)
Sec2:NewToggle("Auto Follow Player", "Kejar & Tempel", function(state)
    _G.FollowEnabled = state
    task.spawn(function()
        while _G.FollowEnabled and _G.FollowTarget do
            local char = LocalPlayer.Character
            local tchar = _G.FollowTarget.Character
            if char and tchar and tchar:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = tchar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                if _G.CurrentEmote == "Nyoli" then
                   char.HumanoidRootPart.RootJoint.C0 = char.HumanoidRootPart.RootJoint.C0 * CFrame.Angles(math.rad(10),0,0)
                elseif _G.CurrentEmote == "Lelah" then char.Humanoid.PlatformStand = true
                elseif _G.CurrentEmote == "Duduk" then char.Humanoid.Sit = true end
            end
            task.wait()
        end
        if LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = false
            LocalPlayer.Character.Humanoid.Sit = false
        end
    end)
end)

-- TAB: VISUALS
local Tab3 = Window:NewTab("Visuals")
local Sec3 = Tab3:NewSection("Mode Look ESP")
Sec3:NewToggle("Mode Look (ESP)", "ESP", function(state)
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
    for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("L_ESP") then p.Character.L_ESP:Destroy() end end
end)

-- TAB: COMBAT
local Tab4 = Window:NewTab("Combat")
local Sec4 = Tab4:NewSection("Auto Aim & Killer Mode")
Sec4:NewDropdown("Aim Target", "Filter", {"Survivor", "Killer", "All"}, function(t) _G.AimType = t end)
Sec4:NewToggle("Auto Aim Pistol", "Lock Kamera", function(state)
    _G.AutoAim = state
    RunService.RenderStepped:Connect(function()
        if _G.AutoAim then
            local target = nil
            local dist = math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local mag = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if mag < dist then dist = mag target = p end
                end
            end
            if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position) end
        end
    end)
end)
Sec4:NewToggle("Kebal (God Mode)", "Anti Death", function(state)
    _G.GodMode = state
    task.spawn(function()
        while _G.GodMode do LocalPlayer.Character.Humanoid.Health = 100 task.wait() end
    end)
end)
Sec4:NewToggle("Mode Killer Ganas", "Auto TP Kill", function(state)
    _G.KillerMode = state
    task.spawn(function()
        while _G.KillerMode do
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") then
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
Sec4:NewToggle("No Cooldown", "Anti Stun", function(state)
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

print("L-Script FIXED UI Loaded! Klik Logo L buat buka, X buat tutup.")
