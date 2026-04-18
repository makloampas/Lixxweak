--[[
    DELTA EXECUTOR - VIOLENCE DISTRICT HUB [FIXED FULL VERSION]
    Fitur: Fly, FastRun, Emote + Auto Follow + List Player, Wallhack, Auto Aim (Kamera & Tembak), 
    Kebal (True God Mode), Auto Kill Mode Killer (Teleport + Attack Loop)
    by Dyvillexz/Codex 🔥👾
]]

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenservice = game:GetService("TweenService")
local players = game:GetService("Players")
local virtualUser = game:GetService("VirtualUser")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- VARIABLES
local flyEnabled = false
local flyBV = nil
local flyBG = nil
local runEnabled = false
local runSpeed = 45
local originalSpeed = 16
local espEnabled = false
local espObjects = {}
local autoAimEnabled = false
local autoAimTarget = "Killer"
local godModeEnabled = false
local killerModeEnabled = false
local noCooldownEnabled = false
local emoteEnabled = false
local currentEmote = "nyoli"
local followTarget = nil
local followConnection = nil
local followEnabled = false
local killLoopConnection = nil

-- Fungsi deteksi role (sesuai game Violence District)
local function getPlayerRole(plr)
    -- Coba dari leaderstats
    local ls = plr:FindFirstChild("leaderstats")
    if ls then
        local role = ls:FindFirstChild("Role") or ls:FindFirstChild("Team")
        if role then
            local roleVal = tostring(role.Value)
            if roleVal:lower():find("killer") or roleVal:lower():find("murderer") then
                return "Killer"
            else
                return "Survivor"
            end
        end
    end
    -- Coba dari character tags
    local character = plr.Character
    if character then
        if character:FindFirstChild("KillerTag") or character:FindFirstChild("IsKiller") then
            return "Killer"
        end
    end
    -- Coba dari warna nama atau tool
    for _, tool in pairs(plr.Backpack:GetChildren()) do
        if tool.Name:lower():find("knife") or tool.Name:lower():find("sword") or tool.Name:lower():find("kill") then
            return "Killer"
        end
    end
    return "Survivor"
end

-- Dapetin semua player
local function getAllPlayers()
    local list = {}
    for _, plr in pairs(players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, plr)
        end
    end
    return list
end

-- ========== FLY FIX ==========
local function startFly()
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.CFrame = hrp.CFrame
    flyBV.Parent = hrp
    flyBG.Parent = hrp
    
    local moveVec = Vector3.new(0, 0, 0)
    local flySpeed = 70
    
    local inputBegan = userInput.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then moveVec = moveVec + Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then moveVec = moveVec + Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then moveVec = moveVec + Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then moveVec = moveVec + Vector3.new(1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.Space then moveVec = moveVec + Vector3.new(0, 1, 0) end
        if input.KeyCode == Enum.KeyCode.LeftControl then moveVec = moveVec + Vector3.new(0, -1, 0) end
    end)
    
    local inputEnded = userInput.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then moveVec = moveVec - Vector3.new(0, 0, -1) end
        if input.KeyCode == Enum.KeyCode.S then moveVec = moveVec - Vector3.new(0, 0, 1) end
        if input.KeyCode == Enum.KeyCode.A then moveVec = moveVec - Vector3.new(-1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.D then moveVec = moveVec - Vector3.new(1, 0, 0) end
        if input.KeyCode == Enum.KeyCode.Space then moveVec = moveVec - Vector3.new(0, 1, 0) end
        if input.KeyCode == Enum.KeyCode.LeftControl then moveVec = moveVec - Vector3.new(0, -1, 0) end
    end)
    
    runService.RenderStepped:Connect(function()
        if not flyEnabled then return end
        if moveVec.Magnitude > 0 then moveVec = moveVec.Unit end
        local camCF = camera.CFrame
        local vel = (camCF.LookVector * moveVec.Z + camCF.RightVector * moveVec.X + camCF.UpVector * moveVec.Y) * flySpeed
        flyBV.Velocity = vel
        flyBG.CFrame = camCF
    end)
end

-- ========== FAST RUN ==========
local function updateRunSpeed()
    if runEnabled then
        hum.WalkSpeed = runSpeed
    else
        hum.WalkSpeed = originalSpeed
    end
end

-- ========== WALLHACK / ESP FIX ==========
local function updateESP()
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    espObjects = {}
    
    if not espEnabled then return end
    
    for _, plr in pairs(players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local role = getPlayerRole(plr)
            local highlight = Instance.new("Highlight")
            highlight.Parent = plr.Character
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0.2
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            if role == "Killer" then
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
            else
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(50, 255, 50)
            end
            table.insert(espObjects, highlight)
            
            -- Tambah billboard biar makin jelas
            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0, 100, 0, 30)
            bill.Adornee = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
            bill.Parent = plr.Character
            local text = Instance.new("TextLabel", bill)
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.TextColor3 = role == "Killer" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
            text.Text = plr.Name .. " (" .. role .. ")"
            text.TextStrokeTransparency = 0
            text.TextScaled = true
            table.insert(espObjects, bill)
        end
    end
end

-- ========== AUTO AIM PISTOL (FIX: KAMERA & TEMBAK) ==========
local function autoAimShoot()
    if not autoAimEnabled then return end
    
    -- Cari target berdasarkan pilihan
    local bestTarget = nil
    local bestDist = math.huge
    
    for _, plr in pairs(players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local role = getPlayerRole(plr)
            local shouldTarget = false
            if autoAimTarget == "All" then
                shouldTarget = true
            elseif autoAimTarget == "Killer" and role == "Killer" then
                shouldTarget = true
            elseif autoAimTarget == "Survivor" and role == "Survivor" then
                shouldTarget = true
            end
            
            if shouldTarget then
                local targetPos = plr.Character.HumanoidRootPart.Position
                local dist = (targetPos - hrp.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestTarget = plr.Character.HumanoidRootPart
                end
            end
        end
    end
    
    if bestTarget then
        -- Arahkan kamera ke target
        camera.CFrame = CFrame.new(camera.CFrame.Position, bestTarget.Position)
        
        -- Cari pistol di tangan atau backpack
        local tool = char:FindFirstChildWhichIsA("Tool")
        if not tool then
            for _, t in pairs(player.Backpack:GetChildren()) do
                if t:IsA("Tool") and (t.Name:lower():find("pistol") or t.Name:lower():find("gun") or t.Name:lower():find("revolver")) then
                    tool = t
                    break
                end
            end
        end
        
        if tool then
            -- Equip kalo belum
            if tool.Parent ~= char then
                tool.Parent = char
                wait(0.1)
            end
            -- Tembak!
            tool:Activate()
            -- Simulasi klik mouse
            virtualUser:ClickButton1(Vector2.new(0, 0))
        end
    end
end

-- ========== KEBAL MODE (TRUE GOD MODE) ==========
local function enableGodMode()
    if godModeEnabled then
        -- Bikin character gabisa mati
        hum.MaxHealth = 9e9
        hum.Health = 9e9
        hum.BreakJointsOnDeath = false
        hum:GetPropertyChangedSignal("Health"):Connect(function()
            if godModeEnabled and hum.Health <= 0 then
                hum.Health = 9e9
            end
        end)
        -- Cegah stun/ragdoll
        hum.Sit = false
        -- Proteksi dari kill parts
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part:SetNetworkOwner(nil)
            end
        end
    else
        hum.MaxHealth = 100
        hum.BreakJointsOnDeath = true
    end
end

-- ========== AUTO FOLLOW + LIST PLAYER ==========
local function createPlayerList()
    local listFrame = Instance.new("Frame")
    listFrame.Name = "PlayerList"
    listFrame.Size = UDim2.new(0, 200, 0, 300)
    listFrame.Position = UDim2.new(1, -210, 0, 50)
    listFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    listFrame.BackgroundTransparency = 0.2
    listFrame.BorderSizePixel = 0
    listFrame.Parent = screenGui
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 10)
    
    local title = Instance.new("TextLabel", listFrame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "📋 PLAYER LIST"
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    
    local scroll = Instance.new("ScrollingFrame", listFrame)
    scroll.Size = UDim2.new(1, 0, 1, -30)
    scroll.Position = UDim2.new(0, 0, 0, 30)
    scroll.BackgroundTransparency = 1
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)
    
    local function refreshList()
        for _, child in pairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, plr in pairs(players:GetPlayers()) do
            if plr ~= player then
                local btn = Instance.new("TextButton", scroll)
                btn.Size = UDim2.new(1, -10, 0, 35)
                btn.Text = plr.Name .. " [" .. getPlayerRole(plr) .. "]"
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.Gotham
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
                
                btn.MouseButton1Click:Connect(function()
                    followTarget = plr
                    if followEnabled then
                        startFollowing()
                    end
                    -- Notif
                    local notif = Instance.new("TextLabel", screenGui)
                    notif.Text = "🎯 Now following: " .. plr.Name
                    notif.Size = UDim2.new(0, 250, 0, 30)
                    notif.Position = UDim2.new(0.5, -125, 0, 80)
                    notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    notif.TextColor3 = Color3.fromRGB(0, 255, 0)
                    wait(2)
                    notif:Destroy()
                end)
            end
        end
    end
    
    refreshList()
    players.PlayerAdded:Connect(refreshList)
    players.PlayerRemoving:Connect(refreshList)
    
    return listFrame
end

local function startFollowing()
    if followConnection then followConnection:Disconnect() end
    if not followTarget or not followTarget.Character then return end
    
    followConnection = runService.RenderStepped:Connect(function()
        if not followEnabled or not followTarget or not followTarget.Character then return end
        local targetHrp = followTarget.Character:FindFirstChild("HumanoidRootPart")
        if targetHrp then
            -- Teleport/lerakin ke target
            local distance = (targetHrp.Position - hrp.Position).Magnitude
            if distance > 5 then
                hrp.CFrame = hrp.CFrame + (targetHrp.Position - hrp.Position).Unit * 3
            end
            -- Hadapin target
            hrp.CFrame = CFrame.new(hrp.Position, targetHrp.Position)
            
            -- Play emote kalo enabled
            if emoteEnabled then
                if currentEmote == "nyoli" then
                    -- Gerakan ngocok
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.sin(tick() * 15) * 0.3)
                elseif currentEmote == "lelah" then
                    hum.Sit = true
                elseif currentEmote == "duduk" then
                    hum.Sit = true
                end
            end
        end
    end)
end

-- ========== MODE KILLER AUTO KILL (FIX) ==========
local function startKillerAutoKill()
    if killLoopConnection then killLoopConnection:Disconnect() end
    
    killLoopConnection = runService.RenderStepped:Connect(function()
        if not killerModeEnabled then return end
        
        -- Cari semua survivor
        local survivors = {}
        for _, plr in pairs(players:GetPlayers()) do
            if plr ~= player and getPlayerRole(plr) == "Survivor" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(survivors, plr)
            end
        end
        
        for _, target in pairs(survivors) do
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                -- Teleport ke target
                local targetPos = target.Character.HumanoidRootPart.Position
                hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 3), targetPos)
                wait(0.05)
                
                -- Cari weapon killer
                local weapon = nil
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        weapon = tool
                        break
                    end
                end
                if not weapon then
                    for _, tool in pairs(player.Backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            weapon = tool
                            weapon.Parent = char
                            wait(0.1)
                            break
                        end
                    end
                end
                
                if weapon then
                    weapon:Activate()
                    wait(0.1)
                    -- Serang 2-3 kali biat pasti mati
                    weapon:Activate()
                    wait(0.1)
                    weapon:Activate()
                end
                wait(0.2)
            end
        end
    end)
end

-- ========== NO COOLDOWN ==========
local function enableNoCooldown()
    spawn(function()
        while noCooldownEnabled do
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("Tool") then
                    for _, prop in pairs(v:GetChildren()) do
                        if prop.Name:lower():find("cooldown") or prop.Name:lower():find("cd") then
                            if prop:IsA("NumberValue") then prop.Value = 0 end
                            if prop:IsA("BoolValue") then prop.Value = false end
                        end
                    end
                end
            end
            wait(0.05)
        end
    end)
end

-- ========== UI KECE DENGAN HURUF L ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaViolenceHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 550)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 20)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 1.5

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "💀 DELTA EXECUTOR | VIOLENCE DISTRICT 💀"
title.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 20)

-- Close button ❎
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.Text = "❎"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 25
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Scrolling Frame
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Size = UDim2.new(1, -20, 1, -55)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local scrollLayout = Instance.new("UIListLayout", scroll)
scrollLayout.Padding = UDim.new(0, 8)

-- Helper bikin toggle
local function addToggle(text, flagVar, onChange)
    local frame = Instance.new("Frame", scroll)
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    frame.BackgroundTransparency = 0.3
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = text
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 70, 0, 35)
    btn.Position = UDim2.new(1, -80, 0.5, -17.5)
    btn.Text = "OFF"
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        _G[flagVar] = not _G[flagVar]
        btn.Text = _G[flagVar] and "ON" or "OFF"
        btn.BackgroundColor3 = _G[flagVar] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        if onChange then onChange(_G[flagVar]) end
    end)
end

-- Slider
local function addSlider(text, minVal, maxVal, varName, onChange)
    local frame = Instance.new("Frame", scroll)
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Text = text .. ": " .. tostring(_G[varName] or minVal)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local sliderBtn = Instance.new("TextButton", frame)
    sliderBtn.Size = UDim2.new(0.8, 0, 0, 30)
    sliderBtn.Position = UDim2.new(0.1, 0, 0.45, 0)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    sliderBtn.Text = tostring(_G[varName] or minVal)
    Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    sliderBtn.MouseButton1Down:Connect(function() dragging = true end)
    userInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    runService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = userInput:GetMouseLocation()
            local absPos = sliderBtn.AbsolutePosition
            local percent = (mousePos.X - absPos.X) / sliderBtn.AbsoluteSize.X
            percent = math.clamp(percent, 0, 1)
            local val = math.floor(minVal + (maxVal - minVal) * percent)
            _G[varName] = val
            sliderBtn.Text = tostring(val)
            label.Text = text .. ": " .. tostring(val)
            if onChange then onChange(val) end
        end
    end)
end

-- Dropdown
local function addDropdown(text, options, varName)
    local frame = Instance.new("Frame", scroll)
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = text
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local dropBtn = Instance.new("TextButton", frame)
    dropBtn.Size = UDim2.new(0.4, 0, 0.6, 0)
    dropBtn.Position = UDim2.new(0.55, 0, 0.2, 0)
    dropBtn.Text = _G[varName] or options[1]
    dropBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 5)
    
    local open = false
    local listFrame = nil
    dropBtn.MouseButton1Click:Connect(function()
        if listFrame then listFrame:Destroy() end
        listFrame = Instance.new("Frame", frame)
        listFrame.Size = UDim2.new(0.4, 0, 0, #options * 35)
        listFrame.Position = UDim2.new(0.55, 0, 0.8, 0)
        listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 5)
        
        for i, opt in pairs(options) do
            local optBtn = Instance.new("TextButton", listFrame)
            optBtn.Size = UDim2.new(1, 0, 0, 35)
            optBtn.Text = opt
            optBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            optBtn.MouseButton1Click:Connect(function()
                _G[varName] = opt
                dropBtn.Text = opt
                listFrame:Destroy()
            end)
        end
    end)
end

-- Build UI
addToggle("✈️ FLY MODE (WASD + Space/Ctrl)", "flyEnabled", function(val)
    flyEnabled = val
    if val then startFly() end
end)

addToggle("🏃 FAST RUN", "runEnabled", function(val)
    runEnabled = val
    updateRunSpeed()
end)
addSlider("⚡ RUN SPEED", 16, 250, "runSpeed", function(val)
    runSpeed = val
    if runEnabled then hum.WalkSpeed = runSpeed end
end)

addToggle("👁️ MODE LOOK (WALLHACK)", "espEnabled", function(val)
    espEnabled = val
    updateESP()
end)

addToggle("🎯 AUTO AIM PISTOL", "autoAimEnabled", function(val)
    autoAimEnabled = val
    if val then
        spawn(function()
            while autoAimEnabled do
                autoAimShoot()
                wait(0.05)
            end
        end)
    end
end)
addDropdown("🔫 TARGET AIM", {"Killer", "Survivor", "All"}, "autoAimTarget")

addToggle("🛡️ KEBAL MODE (GOD MODE)", "godModeEnabled", function(val)
    godModeEnabled = val
    enableGodMode()
end)

addToggle("😈 EMOTE MODE", "emoteEnabled", function(val)
    emoteEnabled = val
end)
addDropdown("🎭 PILIH EMOTE", {"nyoli", "lelah", "duduk"}, "currentEmote")

addToggle("👥 AUTO FOLLOW (klik nama di list)", "followEnabled", function(val)
    followEnabled = val
    if val and followTarget then
        startFollowing()
    elseif not val and followConnection then
        followConnection:Disconnect()
    end
end)

addToggle("💀 MODE KILLER (AUTO KILL ALL)", "killerModeEnabled", function(val)
    killerModeEnabled = val
    if val then
        startKillerAutoKill()
    elseif killLoopConnection then
        killLoopConnection:Disconnect()
    end
end)

addToggle("⏱️ NO COOLDOWN", "noCooldownEnabled", function(val)
    noCooldownEnabled = val
    if val then enableNoCooldown() end
end)

-- Tombol L (toggle UI)
local lButton = Instance.new("TextButton", screenGui)
lButton.Size = UDim2.new(0, 55, 0, 55)
lButton.Position = UDim2.new(0, 15, 1, -75)
lButton.Text = "L"
lButton.TextColor3 = Color3.fromRGB(0, 255, 255)
lButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
lButton.BackgroundTransparency = 0.3
lButton.Font = Enum.Font.GothamBold
lButton.TextSize = 35
Instance.new("UICorner", lButton).CornerRadius = UDim.new(1, 0)
local lStroke = Instance.new("UIStroke", lButton)
lStroke.Color = Color3.fromRGB(0, 255, 255)
lStroke.Thickness = 2

lButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Buat player list
createPlayerList()

-- Auto update ESP tiap detik
spawn(function()
    while wait(1) do
        if espEnabled then updateESP() end
    end
end)

-- Character respawn handler
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
    wait(0.5)
    if flyEnabled then startFly() end
    if runEnabled then hum.WalkSpeed = runSpeed end
    if godModeEnabled then enableGodMode() end
    if espEnabled then updateESP() end
    if killerModeEnabled then startKillerAutoKill() end
    if noCooldownEnabled then enableNoCooldown() end
    if followEnabled and followTarget then startFollowing() end
end)

-- Notifikasi sukses
local notif = Instance.new("TextLabel", screenGui)
notif.Text = "✅ VIOLENCE DISTRICT HUB ACTIVE | Tekan L untuk buka/tutup UI"
notif.Size = UDim2.new(0, 400, 0, 35)
notif.Position = UDim2.new(0.5, -200, 0, 20)
notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notif.BackgroundTransparency = 0.3
notif.TextColor3 = Color3.fromRGB(0, 255, 0)
notif.Font = Enum.Font.GothamBold
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)
wait(3)
notif:Destroy()

print("🔥 Delta Executor - Violence District HUB LOADED! 🔥")
