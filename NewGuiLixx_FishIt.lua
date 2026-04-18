--[[
    DELTA EXECUTOR - VIOLENCE DISTRICT HUB
    Fitur lengkap: Fly, FastRun, Emote + Auto Chase, Wallhack, AutoAim, Kebal, Mode Killer God, No Cooldown
    UI dengan huruf L & tombol ❎, persistent antar match
    by Dyvillexz/Codex 👾🔥
]]

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

-- Variables
local flyEnabled = false
local flyBodyVel = nil
local flyGyro = nil
local runSpeed = 16
local runEnabled = false
local originalSpeed = 16
local espEnabled = false
local espLines = {}
local autoAimEnabled = false
local autoAimTarget = "All" -- "Survivor" / "Killer" / "All"
local godModeEnabled = false
local killerModeEnabled = false
local noCooldownEnabled = false
local emoteEnabled = false
local currentEmote = "nyoli"
local chaseTarget = nil
local chaseConnection = nil
local killerAttackTask = nil

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- Fungsi untuk nentuin role (Killer/Survivor) di Violence District
local function getPlayerRole(plr)
    -- Biasanya role ada di leaderstats atau atribut
    local leaderstats = plr:FindFirstChild("leaderstats")
    if leaderstats then
        local role = leaderstats:FindFirstChild("Role")
        if role then return role.Value end
    end
    local character = plr.Character
    if character and character:FindFirstChild("KillerTag") then return "Killer" end
    if character and character:FindFirstChild("SurvivorTag") then return "Survivor" end
    -- Fallback detect dari tool atau warna
    return "Survivor" -- default
end

-- Fungsi buat dapetin semua player di server
local function getAllPlayers()
    local list = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, plr)
        end
    end
    return list
end

-- ========== FITUR 1: FLY ==========
local function startFly()
    if flyBodyVel then flyBodyVel:Destroy() end
    if flyGyro then flyGyro:Destroy() end
    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBodyVel.Velocity = Vector3.new(0, 0, 0)
    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyGyro.CFrame = hrp.CFrame
    flyBodyVel.Parent = hrp
    flyGyro.Parent = hrp
    
    local moveDirection = Vector3.new(0, 0, 0)
    local speed = 50
    
    local userInputConnections = {}
    userInputConnections.MoveForward = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.W then moveDirection = moveDirection + Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then moveDirection = moveDirection + Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then moveDirection = moveDirection + Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then moveDirection = moveDirection + Vector3.new(1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.Space then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if input.KeyCode == Enum.KeyCode.LeftControl then moveDirection = moveDirection + Vector3.new(0, -1, 0) end
    end)
    
    userInputConnections.MoveEnded = UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then moveDirection = moveDirection - Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then moveDirection = moveDirection - Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then moveDirection = moveDirection - Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then moveDirection = moveDirection - Vector3.new(1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.Space then moveDirection = moveDirection - Vector3.new(0, 1, 0) end
        if input.KeyCode == Enum.KeyCode.LeftControl then moveDirection = moveDirection - Vector3.new(0, -1, 0) end
    end)
    
    RunService.RenderStepped:Connect(function()
        if not flyEnabled then return end
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end
        local camCF = camera.CFrame
        local forward = camCF.LookVector
        local right = camCF.RightVector
        local up = camCF.UpVector
        local velocity = (forward * moveDirection.Z + right * moveDirection.X + up * moveDirection.Y) * speed
        flyBodyVel.Velocity = velocity
        flyGyro.CFrame = camCF
    end)
end

-- ========== FITUR 2: FAST RUN ==========
local function setRunSpeed()
    if runEnabled then
        hum.WalkSpeed = runSpeed
    else
        hum.WalkSpeed = originalSpeed
    end
end

-- ========== FITUR 3: EMOTE + AUTO CHASE ==========
local function playEmote(emoteName)
    -- Animasi emote (simulasi pake tween)
    local animTrack = nil
    if emoteName == "nyoli" then
        -- Gerakan ngocok pake satu tangan
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
        local goal = {CFrame = hrp.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(30))}
        TweenService:Create(hrp, tweenInfo, goal):Play()
    elseif emoteName == "lelah" then
        -- Terbaring di tanah
        hum.Sit = true
        wait(0.1)
        hrp.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
    elseif emoteName == "duduk" then
        hum.Sit = true
    end
end

local function startChase(targetPlayer)
    if chaseConnection then chaseConnection:Disconnect() end
    chaseConnection = RunService.RenderStepped:Connect(function()
        if not emoteEnabled or not chaseTarget or not chaseTarget.Character or not chaseTarget.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        local targetPos = chaseTarget.Character.HumanoidRootPart.Position
        hrp.CFrame = CFrame.new(hrp.Position, targetPos)
        local distance = (targetPos - hrp.Position).Magnitude
        if distance > 5 then
            hrp.CFrame = CFrame.new(hrp.Position + (targetPos - hrp.Position).Unit * 4, targetPos)
        end
        playEmote(currentEmote)
    end)
end

-- ========== FITUR 4: WALLHACK / MODE LOOK ==========
local function createESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local highlight = Instance.new("Highlight")
            highlight.Parent = plr.Character
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0
            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
            local role = getPlayerRole(plr)
            if role == "Killer" then
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
            else
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
            end
            table.insert(espLines, highlight)
        end
    end
end

local function clearESP()
    for _, esp in pairs(espLines) do
        if esp and esp.Parent then esp:Destroy() end
    end
    espLines = {}
end

-- ========== FITUR 5: AUTO AIM PISTOL ==========
local function autoAim()
    local tool = player.Character and player.Character:FindFirstChildWhichIsA("Tool")
    if not tool or not tool:FindFirstChild("Handle") then return end
    local closestTarget = nil
    local closestDist = math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local role = getPlayerRole(plr)
            if autoAimTarget == "All" or (autoAimTarget == "Survivor" and role == "Survivor") or (autoAimTarget == "Killer" and role == "Killer") then
                local pos = plr.Character.HumanoidRootPart.Position
                local dist = (pos - camera.CFrame.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestTarget = plr.Character.HumanoidRootPart
                end
            end
        end
    end
    if closestTarget then
        camera.CFrame = CFrame.new(camera.CFrame.Position, closestTarget.Position)
        -- Simulasi tembak
        tool:Activate()
    end
end

-- ========== FITUR 6: KEBAL ==========
local function setGodMode()
    if godModeEnabled then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum.BreakJointsOnDeath = false
        char:FindFirstChild("Humanoid").BreakJointsOnDeath = false
    else
        hum.MaxHealth = 100
        hum.BreakJointsOnDeath = true
    end
end

-- ========== FITUR 7: MODE KILLER (TELEPORT + AUTO SERANG) ==========
local function startKillerMode()
    if killerAttackTask then killerAttackTask:Disconnect() end
    killerAttackTask = RunService.RenderStepped:Connect(function()
        if not killerModeEnabled then return end
        local survivors = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and getPlayerRole(plr) == "Survivor" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(survivors, plr)
            end
        end
        for _, target in pairs(survivors) do
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                wait(0.1)
                -- Serang pake tool killer
                local killerTool = player.Character:FindFirstChildWhichIsA("Tool")
                if killerTool then killerTool:Activate() end
                wait(0.3)
            end
        end
    end)
end

-- ========== FITUR 8: NO COOLDOWN ==========
local function setNoCooldown()
    if noCooldownEnabled then
        -- Loop untuk reset cooldown skill
        spawn(function()
            while noCooldownEnabled do
                for _, v in pairs(player.Character:GetChildren()) do
                    if v:IsA("Tool") and v:FindFirstChild("Cooldown") then
                        v.Cooldown.Value = 0
                    end
                end
                wait(0.1)
            end
        end)
    end
end

-- ========== UI KECE DENGAN HURUF L & TOMBOL ❎ ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaViolenceHub"
screenGui.ResetOnSpawn = false -- PENTING: UI TIDAK ILANG SAAT MATCH SELANJUTNYA
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)

-- Huruf L (tombol toggle UI)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 1, -60)
toggleButton.Text = "L"
toggleButton.TextColor3 = Color3.fromRGB(0, 255, 255)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.BackgroundTransparency = 0.5
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 30
toggleButton.Parent = screenGui
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)

-- Tombol ❎ (close UI)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -50, 0, 10)
closeBtn.Text = "❎"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 25
closeBtn.Parent = mainFrame

-- Scrolling frame untuk menu
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundTransparency = 1
scroll.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.Parent = scroll

-- Fungsi bikin toggle
local function makeToggle(text, flagVar, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.BackgroundTransparency = 0.5
    frame.Parent = scroll
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 30)
    btn.Position = UDim2.new(1, -70, 0.5, -15)
    btn.Text = "OFF"
    btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    btn.MouseButton1Click:Connect(function()
        _G[flagVar] = not _G[flagVar]
        btn.Text = _G[flagVar] and "ON" or "OFF"
        btn.BackgroundColor3 = _G[flagVar] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        callback(_G[flagVar])
    end)
end

-- Slider untuk fast run speed
local function makeSlider(text, minVal, maxVal, varName, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.BackgroundTransparency = 0.5
    frame.Parent = scroll
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = frame
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0.8, 0, 0, 30)
    slider.Position = UDim2.new(0.1, 0, 0.5, 0)
    slider.Text = tostring(_G[varName] or minVal)
    slider.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    slider.Parent = frame
    Instance.new("UICorner", slider).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    slider.MouseButton1Down:Connect(function()
        dragging = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = slider.AbsolutePosition
            local percent = (mousePos.X - absPos.X) / slider.AbsoluteSize.X
            percent = math.clamp(percent, 0, 1)
            local val = math.floor(minVal + (maxVal - minVal) * percent)
            _G[varName] = val
            slider.Text = tostring(val)
            callback(val)
        end
    end)
end

-- Dropdown untuk auto aim target
local function makeDropdown(text, options, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.BackgroundTransparency = 0.5
    frame.Parent = scroll
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.4, 0, 0.6, 0)
    dropdown.Position = UDim2.new(0.55, 0, 0.2, 0)
    dropdown.Text = _G[varName] or options[1]
    dropdown.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    dropdown.Parent = frame
    Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 5)
    
    local isOpen = false
    local listFrame = nil
    dropdown.MouseButton1Click:Connect(function()
        if listFrame then listFrame:Destroy() end
        isOpen = true
        listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(0.4, 0, 0, #options * 30)
        listFrame.Position = UDim2.new(0.55, 0, 0.8, 0)
        listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        listFrame.Parent = frame
        Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 5)
        
        local listLayout = Instance.new("UIListLayout", listFrame)
        for _, opt in pairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 30)
            optBtn.Text = opt
            optBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            optBtn.Parent = listFrame
            optBtn.MouseButton1Click:Connect(function()
                _G[varName] = opt
                dropdown.Text = opt
                listFrame:Destroy()
                isOpen = false
            end)
        end
    end)
end

-- Daftar menu UI
makeToggle("✈️ Fly (WASD + Space/Ctrl)", "flyEnabled", function(val)
    flyEnabled = val
    if val then startFly() else if flyBodyVel then flyBodyVel:Destroy() end end
end)

makeToggle("🏃 Fast Run", "runEnabled", function(val)
    runEnabled = val
    setRunSpeed()
end)
makeSlider("⚡ Fast Run Speed", 16, 200, "runSpeed", function(val)
    runSpeed = val
    if runEnabled then hum.WalkSpeed = runSpeed end
end)

makeToggle("😈 Emote + Auto Chase", "emoteEnabled", function(val)
    emoteEnabled = val
    if not val and chaseConnection then chaseConnection:Disconnect() end
end)

-- Dropdown emote
local emoteFrame = Instance.new("Frame")
emoteFrame.Size = UDim2.new(1, 0, 0, 40)
emoteFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
emoteFrame.BackgroundTransparency = 0.5
emoteFrame.Parent = scroll
Instance.new("UICorner", emoteFrame).CornerRadius = UDim.new(0, 8)
local emoteLabel = Instance.new("TextLabel", emoteFrame)
emoteLabel.Text = "🎭 Pilih Emote:"
emoteLabel.Size = UDim2.new(0.4, 0, 1, 0)
emoteLabel.BackgroundTransparency = 1
emoteLabel.TextColor3 = Color3.fromRGB(255,255,255)
local emoteDropdown = Instance.new("TextButton", emoteFrame)
emoteDropdown.Size = UDim2.new(0.4, 0, 0.6, 0)
emoteDropdown.Position = UDim2.new(0.55, 0, 0.2, 0)
emoteDropdown.Text = "nyoli"
emoteDropdown.BackgroundColor3 = Color3.fromRGB(0,100,150)
emoteDropdown.MouseButton1Click:Connect(function()
    local opts = {"nyoli", "lelah", "duduk"}
    local list = Instance.new("Frame", emoteFrame)
    list.Size = UDim2.new(0.4, 0, 0, 90)
    list.Position = UDim2.new(0.55, 0, 0.8, 0)
    list.BackgroundColor3 = Color3.fromRGB(30,30,50)
    for i, opt in pairs(opts) do
        local btn = Instance.new("TextButton", list)
        btn.Size = UDim2.new(1,0,0,30)
        btn.Text = opt
        btn.MouseButton1Click:Connect(function()
            currentEmote = opt
            emoteDropdown.Text = opt
            list:Destroy()
        end)
    end
end)

makeToggle("👁️ Mode Look (Wallhack)", "espEnabled", function(val)
    espEnabled = val
    if val then createESP() else clearESP() end
end)

makeToggle("🎯 Auto Aim Pistol", "autoAimEnabled", function(val)
    autoAimEnabled = val
    if val then
        spawn(function()
            while autoAimEnabled do
                autoAim()
                wait(0.1)
            end
        end)
    end
end)
makeDropdown("🔫 Target Aim", {"Survivor", "Killer", "All"}, "autoAimTarget")

makeToggle("🛡️ Kebal (God Mode)", "godModeEnabled", function(val)
    godModeEnabled = val
    setGodMode()
end)

makeToggle("💀 Mode Killer (Teleport + Auto Attack)", "killerModeEnabled", function(val)
    killerModeEnabled = val
    if val then startKillerMode() elseif killerAttackTask then killerAttackTask:Disconnect() end
end)

makeToggle("⏱️ No Cooldown", "noCooldownEnabled", function(val)
    noCooldownEnabled = val
    if val then setNoCooldown() end
end)

-- Toggle UI dengan huruf L
local uiVisible = true
toggleButton.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    mainFrame.Visible = uiVisible
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    uiVisible = false
end)

-- Reset on character respawn biar fitur tetep jalan
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
    wait(0.5)
    if flyEnabled then startFly() end
    if runEnabled then hum.WalkSpeed = runSpeed end
    if godModeEnabled then setGodMode() end
    if espEnabled then createESP() end
    if killerModeEnabled then startKillerMode() end
    if noCooldownEnabled then setNoCooldown() end
end)

-- Notifikasi siap
local notif = Instance.new("TextLabel", screenGui)
notif.Text = "✅ Delta Executor | Violence District HUB Aktif! Tekan L untuk toggle UI"
notif.Size = UDim2.new(0, 400, 0, 40)
notif.Position = UDim2.new(0.5, -200, 0, 20)
notif.BackgroundColor3 = Color3.fromRGB(0,0,0)
notif.BackgroundTransparency = 0.3
notif.TextColor3 = Color3.fromRGB(0,255,255)
notif.Font = Enum.Font.GothamBold
notif.TextSize = 14
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)
wait(3)
notif:Destroy()
