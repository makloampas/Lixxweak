-- LIXX HUB | VIOLENCE DISTRICT EDITION (DELTA EXECUTOR)
-- Created by LixxWeak
-- Version: 2.0

if getgenv().LiuxFinalMobile then return end
getgenv().LiuxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
    emote = { enabled = false, currentEmote = nil, targetPlayer = nil }
}

local targetPlayer = nil
local flyBodyVelocity = nil
local originalWalkSpeed = 16
local originalJumpPower = 50
local connections = {}
local playersList = {}
local emotes = {
    nyoli = { name = "🔞 Nyoli", animation = "nyoli" },
    lelah = { name = "😴 Lelah", animation = "lelah" },
    duduk = { name = "💺 Duduk", animation = "duduk" }
}

-- ==================== UI SETUP ====================
local sg = Instance.new("ScreenGui")
sg.Name = "LixxWeakHub"
sg.Parent = player:WaitForChild("PlayerGui")
sg.ResetOnSpawn = false

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 320, 0, 520)
main.Position = UDim2.new(0.5, -160, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
main.BackgroundTransparency = 0.05
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
titleText.TextSize = 16
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

-- ==================== HELPER FUNCTIONS ====================
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
    label.TextSize = 13
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
        value = min + (max - min) * percent
        value = math.floor(value)
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

function createButton(title, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    btn.Text = title
    btn.TextColor3 = Color3.fromRGB(200, 200, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = scroll
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    return btn
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

-- ==================== EMOTE SECTION ====================
local emoteFrame = Instance.new("Frame")
emoteFrame.Size = UDim2.new(1, -10, 0, 120)
emoteFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
emoteFrame.BackgroundTransparency = 0.3
emoteFrame.Parent = scroll

local emoteCorner = Instance.new("UICorner")
emoteCorner.CornerRadius = UDim.new(0, 8)
emoteCorner.Parent = emoteFrame

local emoteLabel = Instance.new("TextLabel")
emoteLabel.Size = UDim2.new(1, -10, 0, 20)
emoteLabel.Position = UDim2.new(0, 5, 0, 5)
emoteLabel.BackgroundTransparency = 1
emoteLabel.Text = "🎭 EMOTE & FOLLOW MODE"
emoteLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
emoteLabel.TextSize = 12
emoteLabel.Font = Enum.Font.GothamBold
emoteLabel.TextXAlignment = Enum.TextXAlignment.Left
emoteLabel.Parent = emoteFrame

local emoteGrid = Instance.new("Frame")
emoteGrid.Size = UDim2.new(1, -10, 0, 40)
emoteGrid.Position = UDim2.new(0, 5, 0, 30)
emoteGrid.BackgroundTransparency = 1
emoteGrid.Parent = emoteFrame

local emoteButtons = {}
local emoteNames = {"nyoli", "lelah", "duduk"}
local emotePositions = {0, 0.35, 0.7}

for i, emote in ipairs(emoteNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, 0, 1, 0)
    btn.Position = UDim2.new(emotePositions[i], 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Text = emotes[emote].name
    btn.TextColor3 = Color3.fromRGB(200, 200, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.Parent = emoteGrid
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        settings.emote.currentEmote = emote
        for _, b in pairs(emoteButtons) do
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    end)
    
    emoteButtons[i] = btn
end

-- Player List Frame
local playerFrame = Instance.new("Frame")
playerFrame.Size = UDim2.new(1, -10, 0, 100)
playerFrame.Position = UDim2.new(0, 5, 0, 75)
playerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
playerFrame.BackgroundTransparency = 0.3
playerFrame.Parent = emoteFrame

local playerCorner = Instance.new("UICorner")
playerCorner.CornerRadius = UDim.new(0, 8)
playerCorner.Parent = playerFrame

local playerLabel = Instance.new("TextLabel")
playerLabel.Size = UDim2.new(1, -10, 0, 20)
playerLabel.Position = UDim2.new(0, 5, 0, 5)
playerLabel.BackgroundTransparency = 1
playerLabel.Text = "👥 PLAYER LIST (Klik untuk follow)"
playerLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
playerLabel.TextSize = 11
playerLabel.Font = Enum.Font.Gotham
playerLabel.TextXAlignment = Enum.TextXAlignment.Left
playerLabel.Parent = playerFrame

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, -10, 1, -30)
playerScroll.Position = UDim2.new(0, 5, 0, 28)
playerScroll.BackgroundTransparency = 1
playerScroll.ScrollBarThickness = 3
playerScroll.Parent = playerFrame

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0, 3)
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Parent = playerScroll

-- Follow Toggle
local followToggleFrame = Instance.new("Frame")
followToggleFrame.Size = UDim2.new(1, -10, 0, 30)
followToggleFrame.Position = UDim2.new(0, 5, 0, 180)
followToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
followToggleFrame.BackgroundTransparency = 0.3
followToggleFrame.Parent = emoteFrame

local followCorner = Instance.new("UICorner")
followCorner.CornerRadius = UDim.new(0, 6)
followCorner.Parent = followToggleFrame

local followLabel = Instance.new("TextLabel")
followLabel.Size = UDim2.new(0.6, 0, 1, 0)
followLabel.Position = UDim2.new(0, 8, 0, 0)
followLabel.BackgroundTransparency = 1
followLabel.Text = "🎯 Follow Mode"
followLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
followLabel.TextSize = 11
followLabel.Font = Enum.Font.Gotham
followLabel.TextXAlignment = Enum.TextXAlignment.Left
followLabel.Parent = followToggleFrame

local followBtn = Instance.new("TextButton")
followBtn.Size = UDim2.new(0, 50, 0, 22)
followBtn.Position = UDim2.new(1, -55, 0, 4)
followBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
followBtn.Text = "OFF"
followBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
followBtn.TextSize = 10
followBtn.Font = Enum.Font.GothamBold
followBtn.Parent = followToggleFrame

local followCornerBtn = Instance.new("UICorner")
followCornerBtn.CornerRadius = UDim.new(0, 5)
followCornerBtn.Parent = followBtn

local followEnabled = false
local followConnection = nil

followBtn.MouseButton1Click:Connect(function()
    followEnabled = not followEnabled
    followBtn.BackgroundColor3 = followEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 120)
    followBtn.Text = followEnabled and "ON" or "OFF"
    
    if followEnabled and targetPlayer and targetPlayer.Character then
        if followConnection then followConnection:Disconnect() end
        followConnection = RunService.RenderStepped:Connect(function()
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = targetPlayer.Character.HumanoidRootPart
                local playerChar = player.Character
                if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
                    playerChar.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3)
                    
                    if settings.emote.enabled and settings.emote.currentEmote then
                        local emoteAnim = getEmoteAnimation(settings.emote.currentEmote)
                        if emoteAnim then
                            local humanoid = playerChar:FindFirstChild("Humanoid")
                            if humanoid then
                                local track = humanoid:LoadAnimation(emoteAnim)
                                if not track.IsPlaying then
                                    track:Play()
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        if followConnection then
            followConnection:Disconnect()
            followConnection = nil
        end
    end
end)

function getEmoteAnimation(emoteName)
    -- Create simple animations for emotes
    local anim = Instance.new("Animation")
    if emoteName == "nyoli" then
        anim.AnimationId = "rbxassetid://1234567890" -- Replace with actual animation ID
    elseif emoteName == "lelah" then
        anim.AnimationId = "rbxassetid://1234567891"
    elseif emoteName == "duduk" then
        anim.AnimationId = "rbxassetid://1234567892"
    end
    return anim
end

-- Update player list
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
        btn.Size = UDim2.new(1, -10, 0, 25)
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
            if followEnabled then
                if followConnection then followConnection:Disconnect() end
                followConnection = RunService.RenderStepped:Connect(function()
                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = targetPlayer.Character.HumanoidRootPart
                        local playerChar = player.Character
                        if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
                            playerChar.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3)
                            
                            if settings.emote.enabled and settings.emote.currentEmote then
                                local emoteAnim = getEmoteAnimation(settings.emote.currentEmote)
                                if emoteAnim then
                                    local humanoid = playerChar:FindFirstChild("Humanoid")
                                    if humanoid then
                                        local track = humanoid:LoadAnimation(emoteAnim)
                                        if not track.IsPlaying then
                                            track:Play()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- ==================== FEATURES ====================
-- Fly
local flyEnabled = false
local flySpeed = 50

function toggleFly(state)
    flyEnabled = state
    local char = player.Character
    if not char then return end
    
    if flyEnabled then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
        end
        
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        flyBodyVelocity.Parent = char:FindFirstChild("HumanoidRootPart")
        
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not flyEnabled then
                connection:Disconnect()
                return
            end
            if not char or not char.Parent then return end
            
            local cameraDirection = camera.CFrame.LookVector
            local moveDirection = Vector3.new()
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + cameraDirection
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - cameraDirection
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
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
                flyBodyVelocity.Velocity = moveDirection * flySpeed
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
        end
    end
end

-- Fast Run
local fastrunEnabled = false
local fastrunSpeed = 50

function toggleFastRun(state)
    fastrunEnabled = state
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            if fastrunEnabled then
                humanoid.WalkSpeed = fastrunSpeed
            else
                humanoid.WalkSpeed = 16
            end
        end
    end
end

function setFastRunSpeed(speed)
    fastrunSpeed = speed
    if fastrunEnabled then
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = fastrunSpeed
            end
        end
    end
end

-- Wallhack/ESP
local wallhackEnabled = false
local espConnections = {}

function toggleWallhack(state)
    wallhackEnabled = state
    
    if wallhackEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                local char = p.Character
                if char then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = char
                    highlight.FillColor = p.TeamColor and p.TeamColor.Color or Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.7
                    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineTransparency = 0.3
                    
                    espConnections[p] = highlight
                end
            end
        end
        
        Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(char)
                if wallhackEnabled then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = char
                    highlight.FillColor = p.TeamColor and p.TeamColor.Color or Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.7
                    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineTransparency = 0.3
                    espConnections[p] = highlight
                end
            end)
        end)
    else
        for _, highlight in pairs(espConnections) do
            if highlight then
                highlight:Destroy()
            end
        end
        espConnections = {}
    end
end

-- Godmode
local godmodeEnabled = false

function toggleGodmode(state)
    godmodeEnabled = state
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.BreakJointsOnDeath = not godmodeEnabled
            if godmodeEnabled then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
            else
                humanoid.MaxHealth = 100
                humanoid.Health = 100
            end
        end
    end
end

-- Aimbot
local aimbotEnabled = false
local aimbotTarget = "All"

function toggleAimbot(state)
    aimbotEnabled = state
end

function setAimbotTarget(target)
    aimbotTarget = target
end

-- Check who is killer (simulation)
function getKiller()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Team and p.Team.Name == "Killer" then
            return p
        end
    end
    return nil
end

function getSurvivors()
    local survivors = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Team and p.Team.Name == "Survivor" then
            table.insert(survivors, p)
        end
    end
    return survivors
end

function getAimbotTarget()
    if aimbotTarget == "All" then
        local closest = nil
        local closestDist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (p.Character.HumanoidRootPart.Position - camera.CFrame.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = p
                end
            end
        end
        return closest
    elseif aimbotTarget == "Killer" then
        return getKiller()
    elseif aimbotTarget == "Survivor" then
        local survivors = getSurvivors()
        if #survivors > 0 then
            local closest = nil
            local closestDist = math.huge
            for _, p in pairs(survivors) do
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (p.Character.HumanoidRootPart.Position - camera.CFrame.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = p
                    end
                end
            end
            return closest
        end
    end
    return nil
end

-- Killer Mode
local killerModeEnabled = false
local killerConnection = nil

function toggleKillerMode(state)
    killerModeEnabled = state
    
    if killerModeEnabled then
        killerConnection = RunService.RenderStepped:Connect(function()
            local killer = player
            if killer and killer.Character then
                local survivors = getSurvivors()
                for _, survivor in pairs(survivors) do
                    if survivor and survivor.Character and survivor.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = survivor.Character.HumanoidRootPart
                        local killerHrp = killer.Character:FindFirstChild("HumanoidRootPart")
                        if killerHrp then
                            killerHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 2)
                            
                            -- Attack simulation
                            local humanoid = survivor.Character:FindFirstChild("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                humanoid.Health = humanoid.Health - 10
                            end
                        end
                    end
                end
            end
        end)
    else
        if killerConnection then
            killerConnection:Disconnect()
            killerConnection = nil
        end
    end
end

-- No Cooldown
local noCooldownEnabled = false

function toggleNoCooldown(state)
    noCooldownEnabled = state
end

-- ==================== UI BUILD ====================
-- Fly Section
createToggle("✈️ Fly Mode", false, function(state)
    settings.fly.enabled = state
    toggleFly(state)
end)

createSlider("Fly Speed", 20, 200, 50, function(value)
    flySpeed = value
    settings.fly.speed = value
end)

-- Fast Run Section
createToggle("🏃 Fast Run", false, function(state)
    settings.fastrun.enabled = state
    toggleFastRun(state)
end)

createSlider("Run Speed", 20, 200, 50, function(value)
    setFastRunSpeed(value)
    settings.fastrun.speed = value
end)

-- ESP Section
createToggle("👁️ Wallhack / ESP", false, function(state)
    settings.wallhack.enabled = state
    toggleWallhack(state)
end)

-- Godmode Section
createToggle("🛡️ Godmode (Invincible)", false, function(state)
    settings.godmode.enabled = state
    toggleGodmode(state)
end)

-- Aimbot Section
createToggle("🎯 Auto Aim (Pistol)", false, function(state)
    settings.aimbot.enabled = state
    toggleAimbot(state)
end)

createDropdown("Aimbot Target", {"All", "Killer", "Survivor"}, function(value)
    setAimbotTarget(value)
    settings.aimbot.target = value
end)

-- Killer Mode Section
createToggle("👑 Killer Mode (Auto Kill)", false, function(state)
    settings.killerMode.enabled = state
    toggleKillerMode(state)
end)

-- No Cooldown Section
createToggle("⚡ No Cooldown (Killer)", false, function(state)
    settings.noCooldown.enabled = state
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

-- ==================== AUTO UPDATE PLAYER LIST ====================
game:GetService("Players").PlayerAdded:Connect(function()
    wait(0.5)
    updatePlayerList()
end)

game:GetService("Players").PlayerRemoving:Connect(function()
    wait(0.5)
    updatePlayerList()
end)

-- ==================== CHARACTER RESPAWN HANDLER ====================
player.CharacterAdded:Connect(function(char)
    wait(0.5)
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
        end
    end
    
    if settings.fly.enabled then
        toggleFly(true)
    end
end)

-- ==================== AIMBOT LOOP ====================
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getAimbotTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = target.Character.HumanoidRootPart
            camera.CFrame = CFrame.new(camera.CFrame.Position, hrp.Position)
        end
    end
end)

-- ==================== NO COOLDOWN HANDLER ====================
if noCooldownEnabled then
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if noCooldownEnabled and tostring(key):lower():find("cooldown") then
            return 0
        end
        return oldIndex(self, key)
    end)
end

print("✅ LIXX HUB | VIOLENCE DISTRICT EDITION LOADED!")
