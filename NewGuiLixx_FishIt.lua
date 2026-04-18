-- LIXX HUB | VIOLENCE DISTRICT EDITION (WORKING UI)
-- Created by LixxWeak

if getgenv().LiuxFinalMobile then return end
getgenv().LiuxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==================== VARIABLES ====================
local settings = {
    noclip = false,
    fastrun = false,
    fastrunSpeed = 50,
    aimbot = false,
    aimbotTarget = "All",
    wallhack = false,
    godmode = false,
    killerMode = false,
    noCooldown = false,
    emote = false,
    currentEmote = nil,
    follow = false
}

local targetPlayer = nil
local originalWalkSpeed = 16
local connections = {}
local followConnection = nil
local killerConnection = nil
local aimbotConnection = nil
local espObjects = {}
local noclipConnection = nil
local emoteActive = false
local emoteCoroutine = nil

-- ==================== NOCLIP ====================
local function toggleNoclip(state)
    settings.noclip = state
    if noclipConnection then noclipConnection:Disconnect() end
    if settings.noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- ==================== FAST RUN ====================
local function toggleFastRun(state)
    settings.fastrun = state
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = settings.fastrun and settings.fastrunSpeed or 16
        end
    end
end

local function setFastRunSpeed(speed)
    settings.fastrunSpeed = speed
    if settings.fastrun then
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = speed
            end
        end
    end
end

-- ==================== GODMODE ====================
local function toggleGodmode(state)
    settings.godmode = state
    if settings.godmode then
        RunService.Heartbeat:Connect(function()
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = math.huge
                    humanoid.Health = math.huge
                    humanoid.BreakJointsOnDeath = false
                end
            end
        end)
    end
end

-- ==================== WALLHACK ====================
local function toggleWallhack(state)
    settings.wallhack = state
    if settings.wallhack then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:IsA("Tool") then
                v.LocalTransparencyModifier = 0.3
            end
        end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hl = Instance.new("Highlight")
                hl.Parent = p.Character
                hl.FillTransparency = 0.4
                hl.OutlineTransparency = 0.1
                hl.FillColor = p.Team and p.Team.Name == "Killer" and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                hl.OutlineColor = Color3.fromRGB(255,255,255)
                table.insert(espObjects, hl)
            end
        end
    else
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0
            end
        end
        for _, hl in pairs(espObjects) do
            if hl then hl:Destroy() end
        end
        espObjects = {}
    end
end

-- ==================== EMOTE ====================
local function stopEmote()
    if emoteCoroutine then coroutine.close(emoteCoroutine) end
    emoteActive = false
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
        local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if rightArm and torso then
            rightArm.CFrame = torso.CFrame * CFrame.new(1.2, 0, 0)
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + 2, hrp.Position.Z)
        end
    end
end

local function playEmote(emote)
    if not settings.emote then return end
    stopEmote()
    emoteActive = true
    local char = player.Character
    if not char then return end
    
    if emote == "nyoli" then
        local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if rightArm and torso then
            emoteCoroutine = coroutine.create(function()
                while emoteActive and settings.currentEmote == "nyoli" do
                    for i = 1, 20 do
                        if not emoteActive then break end
                        local y = 0.3 + math.sin(tick() * 30) * 0.25
                        rightArm.CFrame = torso.CFrame * CFrame.new(1.3, y, 0.2) * CFrame.Angles(math.rad(90), 0, math.rad(20))
                        wait(0.02)
                    end
                    wait(0.05)
                end
                rightArm.CFrame = torso.CFrame * CFrame.new(1.2, 0, 0)
            end)
            coroutine.resume(emoteCoroutine)
        end
    elseif emote == "lelah" then
        local humanoid = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if humanoid and hrp then
            humanoid.PlatformStand = true
            TweenService:Create(hrp, TweenInfo.new(0.3), {Position = hrp.Position - Vector3.new(0,2,0)}):Play()
            hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(90), 0, 0)
        end
    elseif emote == "duduk" then
        local humanoid = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if humanoid and hrp then
            humanoid.PlatformStand = true
            TweenService:Create(hrp, TweenInfo.new(0.3), {Position = hrp.Position - Vector3.new(0,1.5,0)}):Play()
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(90), 0)
        end
    end
end

local function toggleEmote(state)
    settings.emote = state
    if not state then stopEmote() end
end

local function setEmote(emote)
    settings.currentEmote = emote
    if settings.emote then playEmote(emote) end
end

-- ==================== FOLLOW ====================
local function toggleFollow(state)
    settings.follow = state
    if followConnection then followConnection:Disconnect() end
    if settings.follow and targetPlayer then
        followConnection = RunService.RenderStepped:Connect(function()
            if not targetPlayer or not targetPlayer.Character then return end
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local playerChar = player.Character
            if targetHRP and playerChar then
                local playerHRP = playerChar:FindFirstChild("HumanoidRootPart")
                if playerHRP then
                    local newPos = targetHRP.Position - Vector3.new(0,0,3)
                    playerHRP.CFrame = CFrame.new(newPos, targetHRP.Position)
                    if settings.emote and settings.currentEmote then
                        playEmote(settings.currentEmote)
                    end
                end
            end
        end)
    end
end

-- ==================== AUTO AIM ====================
local function getClosestTarget()
    local closest, closestDist = nil, math.huge
    local playerChar = player.Character
    if not playerChar then return nil end
    local playerHRP = playerChar:FindFirstChild("HumanoidRootPart")
    if not playerHRP then return nil end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            if settings.aimbotTarget == "Killer" and not (p.Team and p.Team.Name == "Killer") then goto skip end
            if settings.aimbotTarget == "Survivor" and not (p.Team and p.Team.Name ~= "Killer") then goto skip end
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                local dist = (hrp.Position - playerHRP.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = p
                end
            end
            ::skip::
        end
    end
    return closest
end

local function toggleAimbot(state)
    settings.aimbot = state
    if aimbotConnection then aimbotConnection:Disconnect() end
    if settings.aimbot then
        aimbotConnection = RunService.RenderStepped:Connect(function()
            local target = getClosestTarget()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = target.Character.HumanoidRootPart
                camera.CFrame = CFrame.new(camera.CFrame.Position, hrp.Position)
            end
        end)
    end
end

local function setAimbotTarget(target)
    settings.aimbotTarget = target
end

-- ==================== KILLER MODE ====================
local function toggleKillerMode(state)
    settings.killerMode = state
    if killerConnection then killerConnection:Disconnect() end
    if settings.killerMode then
        killerConnection = RunService.RenderStepped:Connect(function()
            local playerChar = player.Character
            if not playerChar then return end
            local playerHRP = playerChar:FindFirstChild("HumanoidRootPart")
            if not playerHRP then return end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Team and p.Team.Name ~= "Killer" and p.Character then
                    local targetHRP = p.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        playerHRP.CFrame = targetHRP.CFrame * CFrame.new(0,0,2)
                        local humanoid = p.Character:FindFirstChild("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            humanoid.Health = humanoid.Health - 25
                        end
                        wait(0.3)
                    end
                end
            end
        end)
    end
end

-- ==================== NO COOLDOWN ====================
local function toggleNoCooldown(state)
    settings.noCooldown = state
    if settings.noCooldown then
        local mt = getrawmetatable(game)
        if mt then
            local old = mt.__index
            setreadonly(mt, false)
            mt.__index = function(self, k)
                if tostring(k):lower():find("cooldown") then return 0 end
                return old(self, k)
            end
            setreadonly(mt, true)
        end
    end
end

-- ==================== UI (PASTI MUNCUL) ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LixxWeakHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 500)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 50, 100)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 200, 0)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -60, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "LIXX HUB | VIOLENCE DISTRICT"
titleText.TextColor3 = Color3.fromRGB(255, 200, 0)
titleText.TextSize = 13
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Close Button (❌)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "❌"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

-- Mini Button (L)
local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 50, 0, 50)
miniBtn.Position = UDim2.new(0, 15, 0.5, -25)
miniBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
miniBtn.Text = "L"
miniBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
miniBtn.TextSize = 32
miniBtn.Font = Enum.Font.GothamBold
miniBtn.Visible = false
miniBtn.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(1, 0)
miniCorner.Parent = miniBtn

-- Scroll Frame
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -55)
scroll.Position = UDim2.new(0, 8, 0, 48)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 0)
scroll.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

-- ==================== UI HELPER FUNCTIONS ====================
local function createToggle(text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
    frame.BackgroundTransparency = 0.3
    frame.Parent = scroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 220, 100)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 26)
    btn.Position = UDim2.new(1, -56, 0, 4)
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = btn
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 120)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    
    return frame
end

local function createSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 52)
    frame.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
    frame.BackgroundTransparency = 0.3
    frame.Parent = scroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 18)
    label.Position = UDim2.new(0, 5, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 220, 100)
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.85, 0, 0, 4)
    sliderFrame.Position = UDim2.new(0.07, 0, 0, 34)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    sliderFrame.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    fill.Parent = sliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local value = default
    local dragging = false
    
    local function update(x)
        local percent = math.clamp((x - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * percent)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = text .. ": " .. value
        callback(value)
    end
    
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input.Position.X)
        end
    end)
    sliderFrame.InputEnded:Connect(function() dragging = false end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input.Position.X)
        end
    end)
    
    return frame
end

local function createDropdown(text, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
    frame.BackgroundTransparency = 0.3
    frame.Parent = scroll
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 220, 100)
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.4, -10, 0, 28)
    btn.Position = UDim2.new(0.6, 0, 0, 5)
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    btn.Text = options[1]
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.Font = Enum.Font.Gotham
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = btn
    
    local idx = 1
    btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        btn.Text = options[idx]
        callback(options[idx])
    end)
    
    return frame
end

-- ==================== EMOTE SECTION ====================
local emoteFrame = Instance.new("Frame")
emoteFrame.Size = UDim2.new(1, -10, 0, 120)
emoteFrame.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
emoteFrame.BackgroundTransparency = 0.3
emoteFrame.Parent = scroll

local emoteCorner = Instance.new("UICorner")
emoteCorner.CornerRadius = UDim.new(0, 6)
emoteCorner.Parent = emoteFrame

local emoteTitle = Instance.new("TextLabel")
emoteTitle.Size = UDim2.new(1, -10, 0, 24)
emoteTitle.Position = UDim2.new(0, 5, 0, 4)
emoteTitle.BackgroundTransparency = 1
emoteTitle.Text = "🎭 EMOTE & FOLLOW MODE"
emoteTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
emoteTitle.TextSize = 11
emoteTitle.Font = Enum.Font.GothamBold
emoteTitle.TextXAlignment = Enum.TextXAlignment.Left
emoteTitle.Parent = emoteFrame

-- Emote Toggle
local emoteToggleFrame = Instance.new("Frame")
emoteToggleFrame.Size = UDim2.new(1, -10, 0, 28)
emoteToggleFrame.Position = UDim2.new(0, 5, 0, 32)
emoteToggleFrame.BackgroundColor3 = Color3.fromRGB(0, 80, 140)
emoteToggleFrame.BackgroundTransparency = 0.3
emoteToggleFrame.Parent = emoteFrame

local emoteToggleCorner = Instance.new("UICorner")
emoteToggleCorner.CornerRadius = UDim.new(0, 5)
emoteToggleCorner.Parent = emoteToggleFrame

local emoteToggleLabel = Instance.new("TextLabel")
emoteToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
emoteToggleLabel.Position = UDim2.new(0, 8, 0, 0)
emoteToggleLabel.BackgroundTransparency = 1
emoteToggleLabel.Text = "🎭 Emote Mode"
emoteToggleLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
emoteToggleLabel.TextSize = 10
emoteToggleLabel.Font = Enum.Font.Gotham
emoteToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
emoteToggleLabel.Parent = emoteToggleFrame

local emoteToggleBtn = Instance.new("TextButton")
emoteToggleBtn.Size = UDim2.new(0, 45, 0, 22)
emoteToggleBtn.Position = UDim2.new(1, -50, 0, 3)
emoteToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
emoteToggleBtn.Text = "OFF"
emoteToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
emoteToggleBtn.TextSize = 9
emoteToggleBtn.Font = Enum.Font.GothamBold
emoteToggleBtn.Parent = emoteToggleFrame

local emoteToggleCornerBtn = Instance.new("UICorner")
emoteToggleCornerBtn.CornerRadius = UDim.new(0, 4)
emoteToggleCornerBtn.Parent = emoteToggleBtn

-- Emote Buttons
local emoteGrid = Instance.new("Frame")
emoteGrid.Size = UDim2.new(1, -10, 0, 32)
emoteGrid.Position = UDim2.new(0, 5, 0, 64)
emoteGrid.BackgroundTransparency = 1
emoteGrid.Parent = emoteFrame

local emoteList = {"nyoli", "lelah", "duduk"}
local emoteDisplay = {"🔞 Nyoli", "😴 Lelah", "💺 Duduk"}
for i, emote in ipairs(emoteList) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.31, -3, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.34, 3, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 80, 140)
    btn.Text = emoteDisplay[i]
    btn.TextColor3 = Color3.fromRGB(255, 220, 100)
    btn.TextSize = 9
    btn.Font = Enum.Font.Gotham
    btn.Parent = emoteGrid
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = btn
    btn.MouseButton1Click:Connect(function() setEmote(emote) end)
end

-- Follow Toggle
local followFrame = Instance.new("Frame")
followFrame.Size = UDim2.new(1, -10, 0, 28)
followFrame.Position = UDim2.new(0, 5, 0, 100)
followFrame.BackgroundColor3 = Color3.fromRGB(0, 80, 140)
followFrame.BackgroundTransparency = 0.3
followFrame.Parent = emoteFrame

local followCorner = Instance.new("UICorner")
followCorner.CornerRadius = UDim.new(0, 5)
followCorner.Parent = followFrame

local followLabel = Instance.new("TextLabel")
followLabel.Size = UDim2.new(0.6, 0, 1, 0)
followLabel.Position = UDim2.new(0, 8, 0, 0)
followLabel.BackgroundTransparency = 1
followLabel.Text = "🎯 Follow Mode"
followLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
followLabel.TextSize = 10
followLabel.Font = Enum.Font.Gotham
followLabel.TextXAlignment = Enum.TextXAlignment.Left
followLabel.Parent = followFrame

local followBtn = Instance.new("TextButton")
followBtn.Size = UDim2.new(0, 45, 0, 22)
followBtn.Position = UDim2.new(1, -50, 0, 3)
followBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
followBtn.Text = "OFF"
followBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
followBtn.TextSize = 9
followBtn.Font = Enum.Font.GothamBold
followBtn.Parent = followFrame

local followCornerBtn = Instance.new("UICorner")
followCornerBtn.CornerRadius = UDim.new(0, 4)
followCornerBtn.Parent = followBtn

-- Player List
local playerListFrame = Instance.new("Frame")
playerListFrame.Size = UDim2.new(1, -10, 0, 100)
playerListFrame.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
playerListFrame.BackgroundTransparency = 0.3
playerListFrame.Parent = scroll

local playerListCorner = Instance.new("UICorner")
playerListCorner.CornerRadius = UDim.new(0, 6)
playerListCorner.Parent = playerListFrame

local playerListTitle = Instance.new("TextLabel")
playerListTitle.Size = UDim2.new(1, -10, 0, 24)
playerListTitle.Position = UDim2.new(0, 5, 0, 4)
playerListTitle.BackgroundTransparency = 1
playerListTitle.Text = "👥 PLAYER LIST (Klik untuk follow)"
playerListTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
playerListTitle.TextSize = 10
playerListTitle.Font = Enum.Font.Gotham
playerListTitle.TextXAlignment = Enum.TextXAlignment.Left
playerListTitle.Parent = playerListFrame

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, -10, 1, -32)
playerScroll.Position = UDim2.new(0, 5, 0, 30)
playerScroll.BackgroundTransparency = 1
playerScroll.ScrollBarThickness = 2
playerScroll.Parent = playerListFrame

local playerLayoutList = Instance.new("UIListLayout")
playerLayoutList.Padding = UDim.new(0, 2)
playerLayoutList.SortOrder = Enum.SortOrder.LayoutOrder
playerLayoutList.Parent = playerScroll

-- Emote & Follow Logic
local emoteState = false
emoteToggleBtn.MouseButton1Click:Connect(function()
    emoteState = not emoteState
    emoteToggleBtn.BackgroundColor3 = emoteState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 120)
    emoteToggleBtn.Text = emoteState and "ON" or "OFF"
    toggleEmote(emoteState)
end)

local followState = false
followBtn.MouseButton1Click:Connect(function()
    followState = not followState
    followBtn.BackgroundColor3 = followState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 120)
    followBtn.Text = followState and "ON" or "OFF"
    toggleFollow(followState)
end)

local function updatePlayerList()
    for _, child in pairs(playerScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 26)
            btn.BackgroundColor3 = Color3.fromRGB(0, 80, 140)
            btn.Text = p.Name
            btn.TextColor3 = Color3.fromRGB(255, 220, 100)
            btn.TextSize = 10
            btn.Font = Enum.Font.Gotham
            btn.Parent = playerScroll
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = btn
            btn.MouseButton1Click:Connect(function()
                targetPlayer = p
                if followState then
                    toggleFollow(false)
                    wait(0.1)
                    toggleFollow(true)
                end
            end)
        end
    end
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- ==================== BUILD MENU ====================
createToggle("🌀 Noclip (Tembus Objek)", function(v) toggleNoclip(v) end)
createToggle("🏃 Fast Run", function(v) toggleFastRun(v) end)
createSlider("Run Speed", 20, 200, 50, function(v) setFastRunSpeed(v) end)
createToggle("👁️ Wallhack / ESP", function(v) toggleWallhack(v) end)
createToggle("🛡️ Godmode (Kebal)", function(v) toggleGodmode(v) end)
createToggle("🎯 Auto Aim", function(v) toggleAimbot(v) end)
createDropdown("Aimbot Target", {"All", "Killer", "Survivor"}, function(v) setAimbotTarget(v) end)
createToggle("👑 Killer Mode (Auto Kill)", function(v) toggleKillerMode(v) end)
createToggle("⚡ No Cooldown (Killer)", function(v) toggleNoCooldown(v) end)

-- ==================== CLOSE / MINIMIZE ====================
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    miniBtn.Visible = true
end)

miniBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    miniBtn.Visible = false
end)

-- ==================== RESPAWN HANDLER ====================
player.CharacterAdded:Connect(function(char)
    wait(0.5)
    if settings.fastrun then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = settings.fastrunSpeed end
    end
    if settings.godmode then toggleGodmode(true) end
    if settings.noclip then toggleNoclip(true) end
    if settings.emote and settings.currentEmote then playEmote(settings.currentEmote) end
end)

print("✅ LIXX HUB LOADED! UI muncul di layar")
print("✅ Logo L untuk minimize, ❌ untuk close") 
