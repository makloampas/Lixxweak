--[[
    DELTA EXECUTOR - VIOLENCE DISTRICT HUB [FINAL WORKING]
    Fitur: Fast Run (tembus tembok), Auto Follow + Teleport + List Player, 
    Mode Look (Wallhack), Auto Aim (fix ngikut + tembak), Kebal (True God),
    Mode Killer + Lompat Jauh, No Cooldown
    UI miring 16:9, bisa di-scroll, tombol L & ❎
    by Dyvillexz/Codex 🔥👾
]]

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local virtualUser = game:GetService("VirtualUser")
local tweenService = game:GetService("TweenService")

-- VARIABLES
local runEnabled = false
local runSpeed = 45
local originalSpeed = 16
local espEnabled = false
local espObjects = {}
local autoAimEnabled = false
local autoAimTarget = "Killer"
local godModeEnabled = false
local killerModeEnabled = false
local killerJumpEnabled = false
local noCooldownEnabled = false
local followEnabled = false
local followTarget = nil
local followConnection = nil
local killLoopConnection = nil
local noCdConnection = nil

-- Fungsi deteksi role (sesuai game Violence District)
local function getPlayerRole(plr)
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
    local character = plr.Character
    if character then
        if character:FindFirstChild("KillerTag") or character:FindFirstChild("IsKiller") then
            return "Killer"
        end
    end
    for _, tool in pairs(plr.Backpack:GetChildren()) do
        if tool.Name:lower():find("knife") or tool.Name:lower():find("sword") or tool.Name:lower():find("kill") then
            return "Killer"
        end
    end
    return "Survivor"
end

-- ========== FAST RUN (TEMBUS TEMBOK) ==========
local function updateRunSpeed()
    if runEnabled then
        hum.WalkSpeed = runSpeed
        -- Noclip / tembus tembok
        local noclipConn
        noclipConn = runService.RenderStepped:Connect(function()
            if not runEnabled then noclipConn:Disconnect() return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        hum.WalkSpeed = originalSpeed
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ========== WALLHACK / ESP ==========
local function updateESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
    if not espEnabled then return end
    
    for _, plr in pairs(players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local role = getPlayerRole(plr)
            local highlight = Instance.new("Highlight")
            highlight.Parent = plr.Character
            highlight.FillTransparency = 0.4
            highlight.OutlineTransparency = 0.1
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            if role == "Killer" then
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
            else
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(50, 255, 50)
            end
            table.insert(espObjects, highlight)
            
            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0, 120, 0, 35)
            bill.Adornee = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
            bill.Parent = plr.Character
            local text = Instance.new("TextLabel", bill)
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.TextColor3 = role == "Killer" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
            text.Text = plr.Name .. " [" .. role .. "]"
            text.TextStrokeTransparency = 0
            text.TextScaled = true
            table.insert(espObjects, bill)
        end
    end
end

-- ========== AUTO AIM (FIX: IKUTIN + TEMBAK) ==========
local function autoAimShoot()
    if not autoAimEnabled then return end
    
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
        -- Arahkan kamera ke target (LERCUSSS)
        local targetPos = bestTarget.Position
        local camPos = camera.CFrame.Position
        camera.CFrame = CFrame.new(camPos, targetPos)
        
        -- Cari pistol
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
            if tool.Parent ~= char then
                tool.Parent = char
                wait(0.05)
            end
            tool:Activate()
            virtualUser:ClickButton1(Vector2.new(0, 0))
        end
    end
end

-- ========== KEBAL MODE (TRUE GOD) ==========
local function enableGodMode()
    if godModeEnabled then
        hum.MaxHealth = 9e9
        hum.Health = 9e9
        hum.BreakJointsOnDeath = false
        hum:GetPropertyChangedSignal("Health"):Connect(function()
            if godModeEnabled and hum.Health <= 0 then
                hum.Health = 9e9
            end
        end)
        hum.Sit = false
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part:SetNetworkOwner(nil) end)
            end
        end
    else
        hum.MaxHealth = 100
        hum.BreakJointsOnDeath = true
    end
end

-- ========== AUTO FOLLOW + TELEPORT + LIST PLAYER ==========
local function createPlayerList()
    local listFrame = Instance.new("Frame")
    listFrame.Name = "PlayerList"
    listFrame.Size = UDim2.new(0, 220, 0, 350)
    listFrame.Position = UDim2.new(1, -235, 0, 60)
    listFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    listFrame.BackgroundTransparency = 0.25
    listFrame.BorderSizePixel = 0
    listFrame.Parent = screenGui
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 12)
    
    local title = Instance.new("TextLabel", listFrame)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Text = "📋 PLAYER LIST (klik untuk follow)"
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    
    local scroll = Instance.new("ScrollingFrame", listFrame)
    scroll.Size = UDim2.new(1, 0, 1, -35)
    scroll.Position = UDim2.new(0, 0, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)
    
    local function refreshList()
        for _, child in pairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, plr in pairs(players:GetPlayers()) do
            if plr ~= player then
                local btn = Instance.new("TextButton", scroll)
                btn.Size = UDim2.new(1, -10, 0, 40)
                btn.Text = plr.Name .. " [" .. getPlayerRole(plr) .. "]"
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                
                btn.MouseButton1Click:Connect(function()
                    followTarget = plr
                    if followEnabled then
                        startFollowing()
                    end
                    local notif = Instance.new("TextLabel", screenGui)
                    notif.Text = "🎯 Following: " .. plr.Name
                    notif.Size = UDim2.new(0, 250, 0, 30)
                    notif.Position = UDim2.new(0.5, -125, 0, 100)
                    notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    notif.TextColor3 = Color3.fromRGB(0, 255, 0)
                    wait(2)
                    notif:Destroy()
                end)
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
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
            -- TELEPORT ke target + ngikutin
            local distance = (targetHrp.Position - hrp.Position).Magnitude
            if distance > 8 then
                hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
            else
                hrp.CFrame = hrp.CFrame + (targetHrp.Position - hrp.Position).Unit * 5
            end
            hrp.CFrame = CFrame.new(hrp.Position, targetHrp.Position)
        end
    end)
end

-- ========== MODE KILLER + LOMPAT JAUH ==========
local function startKillerAutoKill()
    if killLoopConnection then killLoopConnection:Disconnect() end
    
    killLoopConnection = runService.RenderStepped:Connect(function()
        if not killerModeEnabled then return end
        
        -- Lompat jauh kalo enable
        if killerJumpEnabled then
            hum.JumpPower = 120
            hum.UseJumpPower = true
            if userInput:IsKeyDown(Enum.KeyCode.Space) then
                hum.Jump = true
            end
        else
            hum.JumpPower = 50
        end
        
        -- Cari survivor
        local survivors = {}
        for _, plr in pairs(players:GetPlayers()) do
            if plr ~= player and getPlayerRole(plr) == "Survivor" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(survivors, plr)
            end
        end
        
        for _, target in pairs(survivors) do
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = target.Character.HumanoidRootPart.Position
                hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 4), targetPos)
                wait(0.05)
                
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
                    wait(0.08)
                    weapon:Activate()
                    wait(0.08)
                    weapon:Activate()
                end
                wait(0.15)
            end
        end
    end)
end

-- ========== NO COOLDOWN ==========
local function enableNoCooldown()
    if noCdConnection then noCdConnection:Disconnect() end
    noCdConnection = runService.RenderStepped:Connect(function()
        if not noCooldownEnabled then return end
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
    end)
end

-- ========== UI MIRING 16:9 + BISA DI-SCROLL ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaViolenceHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame miring 16:9
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 480, 0, 720) -- Rasio 16:9
mainFrame.Position = UDim2.new(0.5, -240, 0.5, -360)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Rotation = 3 -- Miring dikit biar kece
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 20)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 2

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "💀 DELTA EXECUTOR | VIOLENCE DISTRICT 💀"
title.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 20)

-- Close button ❎
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 45, 0, 45)
closeBtn.Position = UDim2.new(1, -55, 0, 5)
closeBtn.Text = "❎"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 28
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Scrolling Frame (BISA DI-SCROLL)
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Size = UDim2.new(1, -20, 1, -65)
scroll.Position = UDim2.new(0, 10, 0, 55)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local scrollLayout = Instance.new("UIListLayout", scroll)
scrollLayout.Padding = UDim.new(0, 10)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Update canvas size
local function updateCanvas()
    scroll.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 20)
end
scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
task.wait() 
updateCanvas()

-- Helper bikin toggle
local function addToggle(text, flagVar, onChange)
    local frame = Instance.new("Frame", scroll)
    frame.Size = UDim2.new(1, 0, 0, 50)
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
    label.TextSize = 14
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 80, 0, 38)
    btn.Position = UDim2.new(1, -90, 0.5, -19)
    btn.Text = "OFF"
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.Font = Enum.Font.GothamBold
    
    btn.MouseButton1Click:Connect(function()
        _G[flagVar] = not _G[flagVar]
        btn.Text = _G[flagVar] and "ON" or "OFF"
        btn.BackgroundColor3 = _G[flagVar] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        if onChange then onChange(_G[flagVar]) end
    end)
    updateCanvas()
end

-- Slider
local function addSlider(text, minVal, maxVal, varName, onChange)
    local frame = Instance.new("Frame", scroll)
    frame.Size = UDim2.new(1, 0, 0, 80)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Text = text .. ": " .. tostring(_G[varName] or minVal)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    
    local sliderBtn = Instance.new("TextButton", frame)
    sliderBtn.Size = UDim2.new(0.85, 0, 0, 35)
    sliderBtn.Position = UDim2.new(0.075, 0, 0.45, 0)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    sliderBtn.Text = tostring(_G[varName] or minVal)
    sliderBtn.Font = Enum.Font.GothamBold
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
    updateCanvas()
end

-- Dropdown
local function addDropdown(text, options, varName)
    local frame = Instance.new("Frame", scroll)
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = text
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    
    local dropBtn = Instance.new("TextButton", frame)
    dropBtn.Size = UDim2.new(0.4, 0, 0.6, 0)
    dropBtn.Position = UDim2.new(0.55, 0, 0.2, 0)
    dropBtn.Text = _G[varName] or options[1]
    dropBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 5)
    dropBtn.Font = Enum.Font.Gotham
    
    local open = false
    local listFrame = nil
    dropBtn.MouseButton1Click:Connect(function()
        if listFrame then listFrame:Destroy() end
        listFrame = Instance.new("Frame", frame)
        listFrame.Size = UDim2.new(0.4, 0, 0, #options * 40)
        listFrame.Position = UDim2.new(0.55, 0, 0.8, 0)
        listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
        Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 5)
        
        for i, opt in pairs(options) do
            local optBtn = Instance.new("TextButton", listFrame)
            optBtn.Size = UDim2.new(1, 0, 0, 40)
            optBtn.Text = opt
            optBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            optBtn.Font = Enum.Font.Gotham
            optBtn.MouseButton1Click:Connect(function()
                _G[varName] = opt
                dropBtn.Text = opt
                listFrame:Destroy()
            end)
        end
    end)
    updateCanvas()
end

-- BUILD UI (tanpa Fly)
addToggle("🏃 FAST RUN + TEMBUS TEMBOK", "runEnabled", function(val)
    runEnabled = val
    updateRunSpeed()
end)
addSlider("⚡ RUN SPEED", 16, 120, "runSpeed", function(val)
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

addToggle("👥 AUTO FOLLOW (klik nama di list kanan)", "followEnabled", function(val)
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

addToggle("🦘 KILLER LOMPAT JAUH", "killerJumpEnabled", function(val)
    killerJumpEnabled = val
end)

addToggle("⏱️ NO COOLDOWN", "noCooldownEnabled", function(val)
    noCooldownEnabled = val
    if val then 
        enableNoCooldown() 
    elseif noCdConnection then
        noCdConnection:Disconnect()
    end
end)

-- Tombol L (toggle UI)
local lButton = Instance.new("TextButton", screenGui)
lButton.Size = UDim2.new(0, 60, 0, 60)
lButton.Position = UDim2.new(0, 15, 1, -80)
lButton.Text = "L"
lButton.TextColor3 = Color3.fromRGB(0, 255, 255)
lButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
lButton.BackgroundTransparency = 0.3
lButton.Font = Enum.Font.GothamBold
lButton.TextSize = 38
Instance.new("UICorner", lButton).CornerRadius = UDim.new(1, 0)
local lStroke = Instance.new("UIStroke", lButton)
lStroke.Color = Color3.fromRGB(0, 255, 255)
lStroke.Thickness = 2

lButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Buat player list di kanan
createPlayerList()

-- Auto update ESP tiap detik
spawn(function()
    while wait(1.5) do
        if espEnabled then updateESP() end
    end
end)

-- Character respawn handler
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
    wait(0.8)
    if runEnabled then 
        hum.WalkSpeed = runSpeed
        updateRunSpeed()
    end
    if godModeEnabled then enableGodMode() end
    if espEnabled then updateESP() end
    if killerModeEnabled then startKillerAutoKill() end
    if noCooldownEnabled then enableNoCooldown() end
    if followEnabled and followTarget then startFollowing() end
end)

-- Notifikasi sukses
local notif = Instance.new("TextLabel", screenGui)
notif.Text = "✅ VIOLENCE DISTRICT HUB ACTIVE | Tekan L untuk buka/tutup UI"
notif.Size = UDim2.new(0, 420, 0, 40)
notif.Position = UDim2.new(0.5, -210, 0, 20)
notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notif.BackgroundTransparency = 0.3
notif.TextColor3 = Color3.fromRGB(0, 255, 0)
notif.Font = Enum.Font.GothamBold
notif.TextSize = 14
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)
wait(3)
notif:Destroy()

print("🔥🔥🔥 DELTA EXECUTOR - VIOLENCE DISTRICT HUB FULLY LOADED! 🔥🔥🔥")
    
