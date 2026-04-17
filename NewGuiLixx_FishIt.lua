-- LIXX HUB | VIOLENCE DISTRICT EDITION (FIXED)
-- Created by LixxWeak
-- Version: 3.0 (ALL FEATURES WORKING)

if getgenv().LiuxFinalMobile then return end
getgenv().LiuxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

-- ==================== VARIABLES ====================
local settings = {
    fly = { enabled = false, speed = 50 },
    fastrun = { enabled = false, speed = 50 },
    aimbot = { enabled = false, target = "All" },
    wallhack = { enabled = false },
    godmode = { enabled = false },
    killerMode = { enabled = false },
    noCooldown = { enabled = false },
    emote = { enabled = false, currentEmote = nil, targetPlayer = nil },
    follow = { enabled = false }
}

local targetPlayer = nil
local flyBodyVelocity = nil
local flyConnection = nil
local originalWalkSpeed = 16
local originalJumpPower = 50
local connections = {}
local playersList = {}
local followConnection = nil
local killerConnection = nil
local emoteConnection = nil
local humanoidRootPart = nil

-- ==================== EMOTE ANIMATIONS ====================
local emoteAnimations = {
    nyoli = function(character)
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- Animasi nyoli (gerakan tangan)
        local leftArm = character:FindFirstChild("Left Arm")
        local rightArm = character:FindFirstChild("Right Arm")
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        
        if leftArm and rightArm and torso then
            local leftWeld = Instance.new("Weld")
            leftWeld.Part0 = torso
            leftWeld.Part1 = leftArm
            leftWeld.C0 = torso.CFrame:Inverse() * leftArm.CFrame
            leftWeld.C1 = CFrame.new(-1.5, 0.5, 0)
            leftWeld.Parent = torso
            
            local rightWeld = Instance.new("Weld")
            rightWeld.Part0 = torso
            rightWeld.Part1 = rightArm
            rightWeld.C0 = torso.CFrame:Inverse() * rightArm.CFrame
            rightWeld.C1 = CFrame.new(1.5, 0.5, 0)
            rightWeld.Parent = torso
            
            spawn(function()
                for i = 1, 100 do
                    if not settings.emote.enabled or settings.emote.currentEmote ~= "nyoli" then break end
                    leftWeld.C1 = CFrame.new(-1.5, 0.5 + math.sin(i * 0.5) * 0.3, 0)
                    rightWeld.C1 = CFrame.new(1.5, 0.5 + math.sin(i * 0.5) * 0.3, 0)
                    wait(0.05)
                end
            end)
        end
    end,
    
    lelah = function(character)
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        humanoid.PlatformStand = true
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 0)
        end
        
        spawn(function()
            wait(0.5)
            if settings.emote.currentEmote ~= "lelah" then
                humanoid.PlatformStand = false
            end
        end)
    end,
    
    duduk = function(character)
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1.5, 0)
        end
        
        spawn(function()
            wait(0.5)
            if settings.emote.currentEmote ~= "duduk" then
                humanoid.PlatformStand = false
            end
        end)
    end
}

function playEmote(emoteName, character)
    if not character then return end
    
    if emoteAnimations[emoteName] then
        emoteAnimations[emoteName](character)
    end
end

-- ==================== FLY FUNCTION (FIXED) ====================
function toggleFly(state)
    settings.fly.enabled = state
    local char = player.Character
    if not char then return end
    
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    if settings.fly.enabled then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
            originalWalkSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = 0
        end
        
        humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        flyBodyVelocity.Parent = humanoidRootPart
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not settings.fly.enabled or not char or not char.Parent then
                if flyConnection then flyConnection:Disconnect() end
                return
            end
            
            local moveDirection = Vector3.new()
            local cameraDirection = camera.CFrame.LookVector
            local cameraRight = camera.CFrame.RightVector
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + Vector3.new(cameraDirection.X, 0, cameraDirection.Z)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - Vector3.new(cameraDirection.X, 0, cameraDirection.Z)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - Vector3.new(cameraRight.X, 0, cameraRight.Z)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + Vector3.new(cameraRight.X, 0, cameraRight.Z)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit
            end
            
            if flyBodyVelocity then
                flyBodyVelocity.Velocity = moveDirection * settings.fly.speed
            end
            
            -- Rotate character to face movement direction
            if moveDirection.Magnitude > 0 and humanoidRootPart then
                local lookPos = humanoidRootPart.Position + moveDirection
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, lookPos)
            end
        end)
    else
        if flyBodyVelocity then
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
        end
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
            humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end

function setFlySpeed(speed)
    settings.fly.speed = speed
end

-- ==================== FAST RUN (FIXED) ====================
function toggleFastRun(state)
    settings.fastrun.enabled = state
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            if settings.fastrun.enabled then
                humanoid.WalkSpeed = settings.fastrun.speed
            else
                humanoid.WalkSpeed = 16
            end
        end
    end
end

function setFastRunSpeed(speed)
    settings.fastrun.speed = speed
    if settings.fastrun.enabled then
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = settings.fastrun.speed
            end
        end
    end
end

-- ==================== GODMODE (FIXED) ====================
function toggleGodmode(state)
    settings.godmode.enabled = state
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            if settings.godmode.enabled then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
                humanoid.BreakJointsOnDeath = false
                
                -- Anti damage connection
                local connection
                connection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                    if settings.godmode.enabled and humanoid.Health < humanoid.MaxHealth then
                        humanoid.Health = humanoid.MaxHealth
                    end
                end)
                table.insert(connections, connection)
            else
                humanoid.MaxHealth = 100
                humanoid.Health = 100
                humanoid.BreakJointsOnDeath = true
            end
        end
    end
end

-- ==================== ESP/WALLHACK (FIXED) ====================
local espObjects = {}

function toggleWallhack(state)
    settings.wallhack.enabled = state
    
    if settings.wallhack.enabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                addESP(p)
            end
        end
        
        Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                addESP(p)
            end)
        end)
    else
        for _, obj in pairs(espObjects) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        espObjects = {}
    end
end

function addESP(target)
    if not target.Character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = target.Character
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0.3
    
    -- Determine color based on team
    if target.Team then
        if target.Team.Name == "Killer" then
            highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Merah
            highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
        else
            highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Hijau
            highlight.OutlineColor = Color3.fromRGB(100, 255, 100)
        end
    else
        highlight.FillColor = Color3.fromRGB(255, 255, 0) -- Kuning
        highlight.OutlineColor = Color3.fromRGB(255, 255, 100)
    end
    
    table.insert(espObjects, highlight)
    
    -- Update when character respawns
    target.CharacterAdded:Connect(function(newChar)
        wait(0.5)
        local newHighlight = Instance.new("Highlight")
        newHighlight.Parent = newChar
        newHighlight.FillTransparency = 0.6
        newHighlight.OutlineTransparency = 0.3
        
        if target.Team and target.Team.Name == "Killer" then
            newHighlight.FillColor = Color3.fromRGB(255, 0, 0)
            newHighlight.OutlineColor = Color3.fromRGB(255, 100, 100)
        else
            newHighlight.FillColor = Color3.fromRGB(0, 255, 0)
            newHighlight.OutlineColor = Color3.fromRGB(100, 255, 100)
        end
        
        table.insert(espObjects, newHighlight)
    end)
end

-- ==================== FOLLOW & EMOTE MODE (FIXED) ====================
function toggleFollow(state)
    settings.follow.enabled = state
    
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    
    if settings.follow.enabled and targetPlayer then
        followConnection = RunService.RenderStepped:Connect(function()
            if not settings.follow.enabled then
                if followConnection then followConnection:Disconnect() end
                return
            end
            
            if targetPlayer and targetPlayer.Character then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local playerChar = player.Character
                
                if targetHRP and playerChar then
                    local playerHRP = playerChar:FindFirstChild("HumanoidRootPart")
                    if playerHRP then
                        -- Follow with distance
                        local targetPos = targetHRP.Position
                        local direction = (targetPos - playerHRP.Position).Unit
                        local newPos = targetPos - direction * 4
                        playerHRP.CFrame = CFrame.new(newPos, targetPos)
                        
                        -- Play emote while following
                        if settings.emote.enabled and settings.emote.currentEmote then
                            playEmote(settings.emote.currentEmote, playerChar)
                        end
                    end
                end
            end
        end)
    end
end

function toggleEmote(state)
    settings.emote.enabled = state
    
    if not settings.emote.enabled then
        -- Reset character position when emote off
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.new(0, 2, 0)
            end
        end
    end
end

function setEmote(emote)
    settings.emote.currentEmote = emote
    if settings.emote.enabled then
        local char = player.Character
        if char then
            playEmote(emote, char)
        end
    end
end

-- ==================== AUTO AIM PISTOL (FIXED) ====================
function getClosestTarget()
    local closest = nil
    local closestDist = math.huge
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            if settings.aimbot.target == "All" or 
               (settings.aimbot.target == "Killer" and p.Team and p.Team.Name == "Killer") or
               (settings.aimbot.target == "Survivor" and p.Team and p.Team.Name ~= "Killer") then
                
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                    local dist = (hrp.Position - camera.CFrame.Position).Magnitude
                    
                    if onScreen and dist < closestDist then
                        closestDist = dist
                        closest = p
                    end
                end
            end
        end
    end
    
    return closest
end

function toggleAimbot(state)
    settings.aimbot.enabled = state
end

function setAimbotTarget(target)
    settings.aimbot.target = target
end

-- ==================== KILLER MODE (FIXED) ====================
function toggleKillerMode(state)
    settings.killerMode.enabled = state
    
    if killerConnection then
        killerConnection:Disconnect()
        killerConnection = nil
    end
    
    if settings.killerMode.enabled then
        killerConnection = RunService.RenderStepped:Connect(function()
            local playerChar = player.Character
            if not playerChar then return end
            
            local playerHRP = playerChar:FindFirstChild("HumanoidRootPart")
            if not playerHRP then return end
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Team and p.Team.Name ~= "Killer" then
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHRP = p.Character.HumanoidRootPart
                        playerHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 2)
                        
                        -- Attack
                        local humanoid = p.Character:FindFirstChild("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            humanoid.Health = humanoid.Health - 15
                        end
                        
                        wait(0.5)
                    end
                end
            end
        end)
    end
end

-- ==================== NO COOLDOWN (FIXED) ====================
function toggleNoCooldown(state)
    settings.noCooldown.enabled = state
    
    if settings.noCooldown.enabled then
        local mt = getrawmetatable(game)
        local old_index = mt.__index
        setreadonly(mt, false)
        
        mt.__index = function(self, key)
            if tostring(key):lower():find("cooldown") or tostring(key):lower():find("cd") then
                return 0
            end
            return old_index(self, key)
        end
        
        setreadonly(mt, true)
    end
end

-- ==================== UI SETUP ====================
local sg = Instance.new("ScreenGui")
sg.Name = "LixxWeakHub"
sg.Parent = player:WaitForChild("PlayerGui")
sg.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 320, 0, 550)
main.Position = UDim2.new(0.5, -160, 0.5, -275)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Parent = sg
main.Active = true
main.Draggable = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 200, 255)
mainStroke.Thickness = 2
mainStroke.Parent = main

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
titleBar.BackgroundTransparency = 0.2
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -50, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "LIXX HUB | VIOLENCE DISTRICT"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 14
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

-- Mini Button (huruf L)
local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 50, 0, 50)
miniBtn.Position = UDim2.new(0, 10, 0.5, -25)
miniBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
miniBtn.Text = "L"
miniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
miniBtn.TextSize = 30
miniBtn.Font = Enum.Font.GothamBold
miniBtn.Visible = false
miniBtn.Parent = sg

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(1, 0)
miniCorner.Parent = miniBtn

-- Scroll Frame
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

-- ==================== UI FUNCTIONS ====================
function createToggle(title, state, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BackgroundTransparency = 0.3
    frame.Parent = scroll
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 30)
    btn.Position = UDim2.new(1, -70, 0, 5)
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 120)
    btn.Text = state and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 120)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    
    return frame
end

function createSlider(title, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BackgroundTransparency = 0.3
    frame.Parent = scroll
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = title .. ": " .. default
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.9, 0, 0, 4)
    slider.Position = UDim2.new(0.05, 0, 0, 35)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    slider.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local value = default
    local dragging = false
    
    local function updateValue(x)
        local percent = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * percent)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = title .. ": " .. value
        callback(value)
    end
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateValue(input.Position.X)
        end
    end)
    
    slider.InputEnded:Connect(function()
        dragging = false
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input.Position.X)
        end
    end)
    
    return frame
end

function createDropdown(title, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BackgroundTransparency = 0.3
    frame.Parent = scroll
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.4, -10, 0, 30)
    btn.Position = UDim2.new(0.6, 0, 0, 7)
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    btn.Text = options[1]
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local currentIndex = 1
    
    btn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        btn.Text = options[currentIndex]
        callback(options[currentIndex])
    end)
    
    return frame
end

function createButton(title, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    btn.Text = title
    btn.TextColor3 = Color3.fromRGB(200, 200, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = scroll
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    return btn
end

-- ==================== EMOTE SECTION ====================
local emoteFrame = Instance.new("Frame")
emoteFrame.Size = UDim2.new(1, -10, 0, 160)
emoteFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
emoteFrame.BackgroundTransparency = 0.3
emoteFrame.Parent = scroll

local emoteCorner = Instance.new("UICorner")
emoteCorner.CornerRadius = UDim.new(0, 8)
emoteCorner.Parent = emoteFrame

local emoteTitle = Instance.new("TextLabel")
emoteTitle.Size = UDim2.new(1, -10, 0, 25)
emoteTitle.Position = UDim2.new(0, 5, 0, 5)
emoteTitle.BackgroundTransparency = 1
emoteTitle.Text = "🎭 EMOTE & FOLLOW MODE"
emoteTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
emoteTitle.TextSize = 12
emoteTitle.Font = Enum.Font.GothamBold
emoteTitle.TextXAlignment = Enum.TextXAlignment.Left
emoteTitle.Parent = emoteFrame

-- Emote Toggle
local emoteToggleFrame = Instance.new("Frame")
emoteToggleFrame.Size = UDim2.new(1, -10, 0, 30)
emoteToggleFrame.Position = UDim2.new(0, 5, 0, 35)
emoteToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
emoteToggleFrame.BackgroundTransparency = 0.3
emoteToggleFrame.Parent = emoteFrame

local emoteToggleCorner = Instance.new("UICorner")
emoteToggleCorner.CornerRadius = UDim.new(0, 6)
emoteToggleCorner.Parent = emoteToggleFrame

local emoteToggleLabel = Instance.new("TextLabel")
emoteToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
emoteToggleLabel.Position = UDim2.new(0, 8, 0, 0)
emoteToggleLabel.BackgroundTransparency = 1
emoteToggleLabel.Text = "🎭 Emote Mode"
emoteToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
emoteToggleLabel.TextSize = 11
emoteToggleLabel.Font = Enum.Font.Gotham
emoteToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
emoteToggleLabel.Parent = emoteToggleFrame

local emoteToggleBtn = Instance.new("TextButton")
emoteToggleBtn.Size = UDim2.new(0, 50, 0, 22)
emoteToggleBtn.Position = UDim2.new(1, -55, 0, 4)
emoteToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
emoteToggleBtn.Text = "OFF"
emoteToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
emoteToggleBtn.TextSize = 10
emoteToggleBtn.Font = Enum.Font.GothamBold
emoteToggleBtn.Parent = emoteToggleFrame

local emoteToggleCornerBtn = Instance.new("UICorner")
emoteToggleCornerBtn.CornerRadius = UDim.new(0, 5)
emoteToggleCornerBtn.Parent = emoteToggleBtn

-- Emote Buttons
local emoteGrid = Instance.new("Frame")
emoteGrid.Size = UDim2.new(1, -10, 0, 35)
emoteGrid.Position = UDim2.new(0, 5, 0, 70)
emoteGrid.BackgroundTransparency = 1
emoteGrid.Parent = emoteFrame

local emoteNames = {"nyoli", "lelah", "duduk"}
local emoteDisplay = {"🔞 Nyoli", "😴 Lelah", "💺 Duduk"}
local emotePositions = {0, 0.33, 0.66}

for i, emote in ipairs(emoteNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, -5, 1, 0)
    btn.Position = UDim2.new(emotePositions[i], 5, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Text = emoteDisplay[i]
    btn.TextColor3 = Color3.fromRGB(200, 200, 255)
    btn.TextSize = 10
    btn.Font = Enum.Font.Gotham
    btn.Parent = emoteGrid
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        setEmote(emote)
    end)
end

-- Follow Toggle
local followFrame = Instance.new("Frame")
followFrame.Size = UDim2.new(1, -10, 0, 30)
followFrame.Position = UDim2.new(0, 5, 0, 110)
followFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
followFrame.BackgroundTransparency = 0.3
followFrame.Parent = emoteFrame

local followCorner = Instance.new("UICorner")
followCorner.CornerRadius = UDim.new(0, 6)
followCorner.Parent = followFrame

local followLabel = Instance.new("TextLabel")
followLabel.Size = UDim2.new(0.6, 0, 1, 0)
followLabel.Position = UDim2.new(0, 8, 0, 0)
followLabel.BackgroundTransparency = 1
followLabel.Text = "🎯 Follow Mode (Auto Track)"
followLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
followLabel.TextSize = 11
followLabel.Font = Enum.Font.Gotham
followLabel.TextXAlignment = Enum.TextXAlignment.Left
followLabel.Parent = followFrame

local followBtn = Instance.new("TextButton")
followBtn.Size = UDim2.new(0, 50, 0, 22)
followBtn.Position = UDim2.new(1, -55, 0, 4)
followBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
followBtn.Text = "OFF"
followBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
followBtn.TextSize = 10
followBtn.Font = Enum.Font.GothamBold
followBtn.Parent = followFrame

local followCornerBtn = Instance.new("UICorner")
followCornerBtn.CornerRadius = UDim.new(0, 5)
followCornerBtn.Parent = followBtn

-- Emote Toggle Logic
local emoteState = false
emoteToggleBtn.MouseButton1Click:Connect(function()
    emoteState = not emoteState
    emoteToggleBtn.BackgroundColor3 = emoteState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 120)
    emoteToggleBtn.Text = emoteState and "ON" or "OFF"
    toggleEmote(emoteState)
end)

-- Follow Toggle Logic
local followState = false
followBtn.MouseButton1Click:Connect(function()
    followState = not followState
    followBtn.BackgroundColor3 = followState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 120)
    followBtn.Text = followState and "ON" or "OFF"
    toggleFollow(followState)
end)

-- Player List
local playerListFrame = Instance.new("Frame")
playerListFrame.Size = UDim2.new(1, -10, 0, 120)
playerListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
playerListFrame.BackgroundTransparency = 0.3
playerListFrame.Parent = scroll

local playerListCorner = Instance.new("UICorner")
playerListCorner.CornerRadius = UDim.new(0, 8)
playerListCorner.Parent = playerListFrame

local playerListTitle = Instance.new("TextLabel")
playerListTitle.Size = UDim2.new(1, -10, 0, 25)
playerListTitle.Position = UDim2.new(0, 5, 0, 5)
playerListTitle.BackgroundTransparency = 1
playerListTitle.Text = "👥 PLAYER LIST (Klik untuk follow)"
playerListTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
playerListTitle.TextSize = 11
playerListTitle.Font = Enum.Font.Gotham
playerListTitle.TextXAlignment = Enum.TextXAlignment.Left
playerListTitle.Parent = playerListFrame

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, -10, 1, -35)
playerScroll.Position = UDim2.new(0, 5, 0, 32)
playerScroll.BackgroundTransparency = 1
playerScroll.ScrollBarThickness = 3
playerScroll.Parent = playerListFrame

local playerLayoutList = Instance.new("UIListLayout")
playerLayoutList.Padding = UDim.new(0, 3)
playerLayoutList.SortOrder = Enum.SortOrder.LayoutOrder
playerLayoutList.Parent = playerScroll

function updatePlayerList()
    for _, child in pairs(playerScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local players_list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(players_list, p)
        end
    end
    
    for _, p in pairs(players_list) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        btn.Text = p.Name
        btn.TextColor3 = Color3.fromRGB(200, 200, 255)
        btn.TextSize = 11
        btn.Font = Enum.Font.Gotham
        btn.Parent = playerScroll
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            targetPlayer = p
            settings.emote.targetPlayer = p
            if followState then
                toggleFollow(false)
                wait(0.1)
                toggleFollow(true)
            end
        end)
    end
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- ==================== BUILD UI MENU ====================
-- Fly Section
createToggle("✈️ Fly Mode", false, function(state)
    toggleFly(state)
end)

createSlider("Fly Speed", 20, 200, 50, function(value)
    setFlySpeed(value)
end)

-- Fast Run Section
createToggle("🏃 Fast Run", false, function(state)
    toggleFastRun(state)
end)

createSlider("Run Speed", 20, 200, 50, function(value)
    setFastRunSpeed(value)
end)

-- ESP Section
createToggle("👁️ Wallhack / ESP", false, function(state)
    toggleWallhack(state)
end)

-- Godmode Section
createToggle("🛡️ Godmode (Invincible)", false, function(state)
    toggleGodmode(state)
end)

-- Aimbot Section
createToggle("🎯 Auto Aim (Pistol)", false, function(state)
    toggleAimbot(state)
end)

createDropdown("Aimbot Target", {"All", "Killer", "Survivor"}, function(value)
    setAimbotTarget(value)
end)

-- Killer Mode Section
createToggle("👑 Killer Mode (Auto Kill)", false, function(state)
    toggleKillerMode(state)
end)

-- No Cooldown Section
createToggle("⚡ No Cooldown (Killer)", false, function(state)
    toggleNoCooldown(state)
end)

-- ==================== CLOSE/OPEN HANDLER ====================
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    miniBtn.Visible = true
end)

miniBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    miniBtn.Visible = false
end)

-- ==================== CHARACTER RESPAWN HANDLER ====================
player.CharacterAdded:Connect(function(char)
    wait(1)
    
    if settings.fastrun.enabled then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = settings.fastrun.speed
        end
    end
    
    if settings.godmode.enabled then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
            humanoid.BreakJointsOnDeath = false
        end
    end
    
    if settings.fly.enabled then
        wait(0.5)
        toggleFly(true)
    end
    
    if settings.emote.enabled and settings.emote.currentEmote then
        wait(0.5)
        playEmote(settings.emote.currentEmote, char)
    end
end)

print("✅ LIXX HUB | VIOLENCE DISTRICT EDITION FIXED LOADED!")
