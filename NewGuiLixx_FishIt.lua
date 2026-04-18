-- [[ L - VIOLENCE DISTRIK GACOR (RAYFIELD EDITION) ]] --
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "L - VIOLENCE DISTRIK",
   LoadingTitle = "Gacor No Error",
   LoadingSubtitle = "by L-Helper",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "L_Distrik",
      FileName = "Config"
   },
   KeySystem = false -- Gak pake key biar cepet
})

-- // Variabel Global
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local _G = {
    Fly = false, Speed = 16, SpeedEnabled = false, FollowEnabled = false,
    FollowTarget = nil, AutoAim = false, AimType = "All", GodMode = false,
    KillerMode = false, NoCD = false, ESP = false, CurrentEmote = nil
}

-- // TAB: MOVEMENT
local Tab1 = Window:CreateTab("Movement", 4483362458) -- Icon ID
local Section1 = Tab1:CreateSection("Terbang & Lari")

Tab1:CreateToggle({
   Name = "Fly Mode",
   CurrentValue = false,
   Callback = function(state)
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
   end,
})

Tab1:CreateSlider({
   Name = "Run Speed",
   Range = {16, 500},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "Slider1",
   Callback = function(Value) _G.Speed = Value end,
})

Tab1:CreateToggle({
   Name = "Enable Fast Run",
   CurrentValue = false,
   Callback = function(state)
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
   end,
})

-- // TAB: AVATAR & EMOTE
local Tab2 = Window:CreateTab("Avatar & Emote", 4483362458)
local Section2 = Tab2:CreateSection("Emote & Auto Follow")

Tab2:CreateDropdown({
   Name = "Pilih Emote",
   Options = {"Nyoli", "Lelah", "Duduk"},
   CurrentOption = {"Duduk"},
   MultipleOptions = false,
   Callback = function(Option) _G.CurrentEmote = Option[1] end,
})

local function getPlayers()
    local p_names = {}
    for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then table.insert(p_names, v.Name) end end
    return p_names
end

Tab2:CreateDropdown({
   Name = "Pilih Target Player",
   Options = getPlayers(),
   CurrentOption = {""},
   MultipleOptions = false,
   Callback = function(Option) _G.FollowTarget = Players:FindFirstChild(Option[1]) end,
})

Tab2:CreateToggle({
   Name = "Auto Follow Player",
   CurrentValue = false,
   Callback = function(state)
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
   end,
})

-- // TAB: VISUALS (MODE LOOK)
local Tab3 = Window:CreateTab("Visuals", 4483362458)
Tab3:CreateToggle({
   Name = "Mode Look (ESP)",
   CurrentValue = false,
   Callback = function(state)
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
   end,
})

-- // TAB: COMBAT
local Tab4 = Window:CreateTab("Combat", 4483362458)
Tab4:CreateToggle({
   Name = "Auto Aim Pistol",
   CurrentValue = false,
   Callback = function(state)
        _G.AutoAim = state
        RunService.RenderStepped:Connect(function()
            if _G.AutoAim then
                local t = nil
                local dist = math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local m = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if m < dist then dist = m t = p end
                    end
                end
                if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.HumanoidRootPart.Position) end
            end
        end)
   end,
})

Tab4:CreateToggle({
   Name = "Kebal (God Mode)",
   CurrentValue = false,
   Callback = function(state)
        _G.GodMode = state
        task.spawn(function()
            while _G.GodMode do 
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Health = 100 end
                task.wait() 
            end
        end)
   end,
})

Tab4:CreateToggle({
   Name = "Mode Killer Ganas",
   CurrentValue = false,
   Callback = function(state)
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
   end,
})

Tab4:CreateToggle({
   Name = "No Cooldown",
   CurrentValue = false,
   Callback = function(state)
        _G.NoCD = state
        task.spawn(function()
            while _G.NoCD do
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v.Name == "Cooldown" or v.Name == "Stun" then v:Destroy() end
                end
                task.wait()
            end
        end)
   end,
})

-- // TOMBOL L FLOATING
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local L_Btn = Instance.new("TextButton", ScreenGui)
L_Btn.Size = UDim2.new(0, 60, 0, 60)
L_Btn.Position = UDim2.new(0, 20, 0, 200)
L_Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
L_Btn.Text = "L"
L_Btn.TextSize = 40
L_Btn.TextColor3 = Color3.new(1,1,1)
L_Btn.Draggable = true
Instance.new("UICorner", L_Btn).CornerRadius = UDim.new(0, 15)

L_Btn.MouseButton1Click:Connect(function()
    Rayfield:ToggleUI()
end)

Rayfield:Notify({
   Title = "L-Script Loaded",
   Content = "Berhasil masuk ke Violence Distrik!",
   Duration = 5,
   Image = 4483362458,
})
