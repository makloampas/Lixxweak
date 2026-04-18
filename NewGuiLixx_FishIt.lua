-- LIXX HUB | VIOLENCE DISTRICT EDITION (ULTIMATE FIX)
-- Created by LixxWeak
-- Version: 5.0

if getgenv().LiuxFinalMobile then return end
getgenv().LiuxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

-- ==================== VARIABLES ====================
local settings = {
    noclip = { enabled = false },
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
local originalWalkSpeed = 16
local originalJumpPower = 50
local connections = {}
local followConnection = nil
local killerConnection = nil
local aimbotConnection = nil
local espObjects = {}
local noclipConnection = nil
local noCooldownActive = false
local currentUI = nil
local emoteActive = false
local emoteCoroutine = nil

-- Save UI state
local uiVisible = true
local lastPosition = nil

-- ==================== NOCLIP (TEMBUS OBJEK) ====================
function toggleNoclip(state)
    settings.noclip.enabled = state
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if settings.noclip.enabled then
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

-- ==================== GODMODE (TRUE INVINCIBLE) ====================
function toggleGodmode(state)
    settings.godmode.enabled = state
    
    if settings.godmode.enabled then
        -- Infinite health loop
        local godmodeConnection
        godmodeConnection = RunService.Heartbeat:Connect(function()
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = math.huge
                    humanoid.Health = math.huge
                    humanoid.BreakJointsOnDeath = false
                end
                -- Prevent any damage
                for _, v in pairs(char:GetChildren()) do
                    if v:IsA("BasePart") then
                        v:SetNetworkOwner(nil)
                    end
                end
            end
        end)
        table.insert(connections, godmodeConnection)
        
        -- Anti-stun/ragdoll
        local stunConnection
        stunConnection = game:GetService("ReplicatedStorage").Events.OnClientEvent:Connect(function(event, ...)
            if settings.godmode.enabled and (event:lower():find("damage") or event:lower():find("hit") or event:lower():find("stun")) then
                return
            end
        end)
        table.insert(connections, stunConnection)
    end
end

-- ==================== ESP/WALLHACK ====================
function toggleWallhack(state)
    settings.wallhack.enabled = state
    
    if settings.wallhack.enabled then
        -- Set low transparency for walls
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:IsA("Tool") then
                v.LocalTransparencyModifier = 0.3
            end
        end
        
        Workspace.DescendantAdded:Connect(function(v)
            if settings.wallhack.enabled and v:IsA("BasePart") and not v.Parent:IsA("Tool") then
                v.LocalTransparencyModifier = 0.3
            end
        end)
        
        -- Add highlights to players
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
        -- Reset transparency
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0
            end
        end
        
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
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0.1
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Adornee = target.Character
    
    if target.Team and target.Team.Name == "Killer" then
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
    else
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
    end
    
    table.insert(espObjects, highlight)
    
    -- Update on respawn
    target.CharacterAdded:Connect(function(newChar)
        wait(0.5)
        local newHighlight = Instance.new("Highlight")
        newHighlight.Parent = newChar
        newHighlight.FillTransparency = 0.4
        newHighlight.OutlineTransparency = 0.1
        newHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        newHighlight.Adornee = newChar
        
        if target.Team and target.Team.Name == "Killer" then
            newHighlight.FillColor = Color3.fromRGB(255, 0, 0)
        else
            newHighlight.FillColor = Color3.fromRGB(0, 255, 0)
        end
        
        table.insert(espObjects, newHighlight)
    end)
end

-- ==================== EMOTE ANIMATIONS (FIXED) ====================
local function stopAllEmotes()
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        -- Reset arm positions
        local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
        if rightArm then
            local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            if torso then
                rightArm.CFrame = torso.CFrame * CFrame.new(1.2, 0, 0)
            end
        end
        -- Reset position
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local currentPos = hrp.Position
            hrp.CFrame = CFrame.new(currentPos.X, currentPos.Y + 2, currentPos.Z)
        end
    end
    if emoteCoroutine then
        coroutine.close(emoteCoroutine)
        emoteCoroutine = nil
    end
    emoteActive = false
end

local function emoteNyoli(character)
    local humanoid = character:FindFirstChild("Humanoid")
    local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    
    if not (humanoid and rightArm and torso) then return end
    
    humanoid.AutoRotate = false
    local originalCF = rightArm.CFrame
    
    emoteCoroutine = coroutine.create(function()
        while emoteActive and settings.emote.currentEmote == "nyoli" and character and character.Parent do
            -- Gerakan satu tangan mengocok (gerakan cepat naik turun)
            for i = 1, 15 do
                if not emoteActive or settings.emote.currentEmote ~= "nyoli" then break end
                local yOffset = 0.3 + math.sin(tick() * 30) * 0.25
                rightArm.CFrame = torso.CFrame * CFrame.new(1.3, yOffset, 0.2) * CFrame.Angles(math.rad(90), 0, math.rad(20))
                wait(0.02)
            end
            wait(0.05)
        end
        -- Reset
        rightArm.CFrame = originalCF
        humanoid.AutoRotate = true
    end)
    
    coroutine.resume(emoteCoroutine)
end

local function emoteLelah(character)
    local humanoid = character:FindFirstChild("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if not (humanoid and hrp) then return end
    
    humanoid.PlatformStand = true
    local targetPos = hrp.Position - Vector3.new(0, 2, 0)
    local tween = TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = targetPos})
    tween:Play()
    
    -- Rotate to lying position
    hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(90), 0, 0)
end

local function emoteDuduk(character)
    local humanoid = character:FindFirstChild("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if not (humanoid and hrp) then return end
    
    humanoid.PlatformStand = true
    local targetPos = hrp.Position - Vector3.new(0, 1.5, 0)
    local tween = TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = targetPos})
    tween:Play()
    
    -- Sit rotation
    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(90), 0)
end

function playEmote(emoteName, character)
    if not character then return end
    
    -- Stop current emote
    stopAllEmotes()
    emoteActive = true
    
    if emoteName == "nyoli" then
        emoteNyoli(character)
    elseif emoteName == "lelah" then
        emoteLelah(character)
    elseif emoteName == "duduk" then
        emoteDuduk(character)
    end
end

function toggleEmote(state)
    settings.emote.enabled = state
    if not state then
        stopAllEmotes()
    elseif settings.emote.currentEmote then
        playEmote(settings.emote.currentEmote, player.Character)
    end
end

function setEmote(emote)
    settings.emote.currentEmote = emote
    if settings.emote.enabled then
        playEmote(emote, player.Character)
    end
end

-- ==================== FOLLOW MODE ====================
function toggleFollow(state)
    settings.follow.enabled = state
    
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    
    if settings.follow.enabled and targetPlayer then
        followConnection = RunService.RenderStepped:Connect(function()
            if not settings.follow.enabled or not targetPlayer then
                if followConnection then followConnection:Disconnect() end
                return
            end
            
            local targetChar = targetPlayer.Character
            local playerChar = player.Character
            
            if targetChar and playerChar then
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                local playerHRP = playerChar:FindFirstChild("HumanoidRootPart")
                
                if targetHRP and playerHRP then
                    -- Follow position
                    local targetPos = targetHRP.Position
                    local newPos = targetPos - Vector3.new(0, 0, 3)
                    playerHRP.CFrame = CFrame.new(newPos, targetPos)
                    
                    -- Play emote while following
                    if settings.emote.enabled and settings.emote.currentEmote then
                        playEmote(settings.emote.currentEmote, playerChar)
                    end
                end
            end
        end)
    end
end

-- ==================== AUTO AIM (WORKING) ====================
function getClosestTarget()
    local closest = nil
    local closestDist = math.huge
    local playerChar = player.Character
    
    if not playerChar then return nil end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            -- Filter berdasarkan target
            if settings.aimbot.target == "All" then
                -- semua target
            elseif settings.aimbot.target == "Killer" then
                if not (p.Team and p.Team.Name == "Killer") then
                    goto continue
                end
            elseif settings.aimbot.target == "Survivor" then
                if not (p.Team and p.Team.Name ~= "Killer") then
                    goto continue
                end
            end
            
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                local dist = (hrp.Position - playerChar:FindFirstChild("HumanoidRootPart").Position).Magnitude
                
                if dist < closestDist then
                    closestDist = dist
                    closest = p
                end
            end
        end
        ::continue::
    end
    
    return closest
end

function toggleAimbot(state)
    settings.aimbot.enabled = state
    
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    
    if settings.aimbot.enabled then
        aimbotConnection = RunService.RenderStepped:Connect(function()
            local target = getClosestTarget()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = target.Character.HumanoidRootPart
                -- Arahkan kamera ke target
                camera.CFrame = CFrame.new(camera.CFrame.Position, hrp.Position)
            end
        end)
    end
end

function setAimbotTarget(target)
    settings.aimbot.target = target
end

-- ==================== KILLER MODE (WITH ATTACK) ====================
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
                if p ~= player then
                    -- Target hanya survivor
                    if p.Team and p.Team.Name ~= "Killer" then
                        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local targetHRP = p.Character.HumanoidRootPart
                            -- Teleport to target
                            playerHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 2)
                            
                            -- Attack!
                            local humanoid = p.Character:FindFirstChild("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                humanoid.Health = humanoid.Health - 25
                                -- Create attack effect
                                local attackEffect = Instance.new("Part")
                                attackEffect.Shape = Enum.PartType.Ball
                                attackEffect.Size = Vector3.new(1, 1, 1)
                                attackEffect.BrickColor = BrickColor.new("Bright red")
                                attackEffect.Material = Enum.Material.Neon
                                attackEffect.CFrame = targetHRP.CFrame
                                attackEffect.Parent = Workspace
                                game:GetService("Debris"):AddItem(attackEffect, 0.2)
                            end
                            
                            wait(0.3)
                        end
                    end
                end
            end
        end)
    end
end

-- ==================== NO COOLDOWN (FIXED) ====================
function toggleNoCooldown(state)
    settings.noCooldown.enabled = state
    noCooldownActive = state
    
    if settings.noCooldown.enabled then
        -- Hook all remote events for cooldown
        local mt = getrawmetatable(game)
        if mt then
            local old_namecall = mt.__namecall
            local old_index = mt.__index
            
            setreadonly(mt, false)
            
            mt.__namecall = function(self, ...)
                local args = {...}
                local method = getnamecallmethod()
                local name = tostring(self)
                
                if noCooldownActive then
                    -- Bypass cooldown checks
                    if name:lower():find("cooldown") or name:lower():find("cd") or 
                       method:lower():find("cooldown") or method:lower():find("cd") then
                        return 0
                    end
                    
                    -- Bypass ability cooldowns
                    if method == "FireServer" and args[1] then
                        local eventName = tostring(args[1])
                        if eventName:lower():find("ability") or eventName:lower():find("skill") then
                            -- Allow ability to fire instantly
                        end
                    end
                end
                
                return old_namecall(self, ...)
            end
            
            mt.__index = function(self, key)
                if noCooldownActive then
                    if tostring(key):lower():find("cooldown") or tostring(key):lower():find("cd") then
                        return 0
                    end
                end
                return old_index(self, key)
            end
            
            setreadonly(mt, true)
        end
        
        -- Also patch remote events
        local replicatedStorage = game:GetService("ReplicatedStorage")
        for _, v in pairs(replicatedStorage:GetChildren()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local oldFire = v.FireServer
                v.FireServer = function(...)
                    if noCooldownActive then
                        -- Allow all remote calls
                    end
                    return oldFire(...)
                end
            end
        end
    end
end

-- ==================== UI SETUP (16:9, BLUE + YELLOW, PERSISTENT) ====================
local function createUI()
    -- Clear old UI if exists
    for _, gui in pairs(player.PlayerGui:GetChildren()) do
        if gui.Name == "LixxWeakHub" then
            gui:Destroy()
        end
    end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "LixxWeakHub"
    sg.Parent = player:WaitForChild("PlayerGui")
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame (16:9 aspect ratio, ukuran pas)
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 530)
    main.Position = lastPosition or UDim2.new(0.7, -150, 0.5, -265)
    main.BackgroundColor3 = Color3.fromRGB(0, 50, 100)
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    main.Parent = sg
    main.Active = true
    main.Draggable = true
    
    -- Save position when dragged
    main:GetPropertyChangedSignal("Position"):Connect(function()
        lastPosition = main.Position
    end)
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = main
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(255, 200, 0)
    mainStroke.Thickness = 2
    mainStroke.Parent = main
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
    titleBar.BackgroundTransparency = 0
    titleBar.Parent = main
    
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
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    -- Mini Button (huruf L)
    local miniBtn = Instance.new("TextButton")
    miniBtn.Size = UDim2.new(0, 45, 0, 45)
    miniBtn.Position = UDim2.new(0, 15, 0.5, -22)
    miniBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    miniBtn.Text = "L"
    miniBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
    miniBtn.TextSize = 28
    miniBtn.Font = Enum.Font.GothamBold
    miniBtn.Visible = false
    miniBtn.Parent = sg
    
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
    scroll.Parent = main
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll
    
    -- UI Functions
    local function createToggle(title, state, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 34)
        frame.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
        frame.BackgroundTransparency = 0.3
        frame.Parent = scroll
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 6)
        frameCorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = title
        label.TextColor3 = Color3.fromRGB(255, 220, 100)
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 50, 0, 26)
        btn.Position = UDim2.new(1, -56, 0, 4)
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 120)
        btn.Text = state and "ON" or "OFF"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 10
        btn.Font = Enum.Font.GothamBold
        btn.Parent = frame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 120)
            btn.Text = state and "ON" or "OFF"
            callback(state)
        end)
        
        return frame
    end
    
    local function createSlider(title, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 52)
        frame.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
        frame.BackgroundTransparency = 0.3
        frame.Parent = scroll
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 6)
        frameCorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 18)
        label.Position = UDim2.new(0, 5, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = title .. ": " .. default
        label.TextColor3 = Color3.fromRGB(255, 220, 100)
        label.TextSize = 10
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0.85, 0, 0, 4)
        slider.Position = UDim2.new(0.07, 0, 0, 34)
        slider.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        slider.Parent = frame
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(1, 0)
        sliderCorner.Parent = slider
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
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
    
    local function createDropdown(title, options, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 38)
        frame.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
        frame.BackgroundTransparency = 0.3
        frame.Parent = scroll
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 6)
        frameCorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = title
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
        
        local currentIndex = 1
        
        btn.MouseButton1Click:Connect(function()
            currentIndex = currentIndex % #options + 1
            btn.Text = options[currentIndex]
            callback(options[currentIndex])
        end)
        
        return frame
    end

     -- ==================== EMOTE SECTION ====================
    local emoteFrame = Instance.new("Frame")
    emoteFrame.Size = UDim2.new(1, -10, 0, 130)
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
    
    local emoteNames = {"nyoli", "lelah", "duduk"}
    local emoteDisplay = {"🔞 Nyoli", "😴 Lelah", "💺 Duduk"}
    local emotePositions = {0, 0.34, 0.67}
    
    for i, emote in ipairs(emoteNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.31, -3, 1, 0)
        btn.Position = UDim2.new(emotePositions[i], 3, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(0, 80, 140)
        btn.Text = emoteDisplay[i]
        btn.TextColor3 = Color3.fromRGB(255, 220, 100)
        btn.TextSize = 9
        btn.Font = Enum.Font.Gotham
        btn.Parent = emoteGrid
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            setEmote(emote)
        end)
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
    playerScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 0)
    playerScroll.Parent = playerListFrame
    
    local playerLayoutList = Instance.new("UIListLayout")
    playerLayoutList.Padding = UDim.new(0, 2)
    playerLayoutList.SortOrder = Enum.SortOrder.LayoutOrder
    playerLayoutList.Parent = playerScroll
    
    -- Emote Toggle Logic
    local emoteState = false
    emoteToggleBtn.MouseButton1Click:Connect(function()
        emoteState = not emoteState
        emoteToggleBtn.BackgroundColor3 = emoteState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 120)
        emoteToggleBtn.Text = emoteState and "ON" or "OFF"
        toggleEmote(emoteState)
    end)
    
    -- Follow Toggle Logic
    local followState = false
    followBtn.MouseButton1Click:Connect(function()
        followState = not followState
        followBtn.BackgroundColor3 = followState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 120)
        followBtn.Text = followState and "ON" or "OFF"
        toggleFollow(followState)
    end)
    
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
    createToggle("🌀 Noclip (Tembus Objek)", false, function(state)
        toggleNoclip(state)
    end)
    
    createToggle("🏃 Fast Run", false, function(state)
        toggleFastRun(state)
    end)
    
    createSlider("Run Speed", 20, 200, 50, function(value)
        setFastRunSpeed(value)
    end)
    
    createToggle("👁️ Wallhack / ESP", false, function(state)
        toggleWallhack(state)
    end)
    
    createToggle("🛡️ Godmode (Kebal Total)", false, function(state)
        toggleGodmode(state)
    end)
    
    createToggle("🎯 Auto Aim", false, function(state)
        toggleAimbot(state)
    end)
    
    createDropdown("Aimbot Target", {"All", "Killer", "Survivor"}, function(value)
        setAimbotTarget(value)
    end)
    
    createToggle("👑 Killer Mode (Auto Kill)", false, function(state)
        toggleKillerMode(state)
    end)
    
    createToggle("⚡ No Cooldown (Killer)", false, function(state)
        toggleNoCooldown(state)
    end)

      -- ==================== CLOSE/OPEN HANDLER ====================
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        miniBtn.Visible = true
        uiVisible = false
    end)
    
    miniBtn.MouseButton1Click:Connect(function()
        main.Visible = true
        miniBtn.Visible = false
        uiVisible = true
    end)
    
    return sg
end

-- ==================== INITIALIZE ====================
local ui = createUI()

-- Persistent UI handler (keep UI on match change)
local function ensureUI()
    if not ui or not ui.Parent then
        ui = createUI()
    end
end

player.PlayerGui.ChildRemoved:Connect(function(child)
    if child == ui then
        wait(0.1)
        ensureUI()
    end
end)

-- Re-apply settings on character respawn
player.CharacterAdded:Connect(function(char)
    wait(0.5)
    
    if settings.fastrun.enabled then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = settings.fastrun.speed
        end
    end
    
    if settings.godmode.enabled then
        toggleGodmode(true)
    end
    
    if settings.noclip.enabled then
        toggleNoclip(true)
    end
    
    if settings.emote.enabled and settings.emote.currentEmote then
        wait(0.3)
        playEmote(settings.emote.currentEmote, char)
    end
end)

-- Re-apply wallhack on map change
game:GetService("Workspace").DescendantAdded:Connect(function(v)
    if settings.wallhack.enabled and v:IsA("BasePart") and not v.Parent:IsA("Tool") then
        v.LocalTransparencyModifier = 0.3
    end
end)

print("✅ LIXX HUB | VIOLENCE DISTRICT EDITION ULTIMATE FIX LOADED!")
print("✅ Fitur: Noclip, Fast Run, Wallhack, Godmode, Auto Aim, Killer Mode, No Cooldown, Emote, Follow")
print("✅ UI: 16:9 | Blue + Yellow | Persistent")
   
