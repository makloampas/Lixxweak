-- LIXX Fish It | ANDROID ULTIMATE BLUE VERSION
if getgenv().LixxFinalMobile then return end
getgenv().LixxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------
-- UI SETUP (MODERN BLUE THEME)
--------------------------------------------------
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "LixxBlueHub"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.fromOffset(280, 400)
main.Position = UDim2.new(0.5, -140, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 15)

-- Stroke agar UI terlihat lebih tajam
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Thickness = 2

local title = Instance.new("TextLabel", main)
title.Text = "LIXX HUB: BLUE EDITION"
title.Size = UDim2.new(1, 0, 0.1, 0)
title.BackgroundColor3 = Color3.fromRGB(0, 85, 150)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local closeBtn = Instance.new("TextButton", main)
closeBtn.Text = "X"
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.new(1, 1, 1)

local restoreBtn = Instance.new("TextButton", sg)
restoreBtn.Text = "LIXX"
restoreBtn.Size = UDim2.fromOffset(60, 60)
restoreBtn.Position = UDim2.new(0, 10, 0.5, 0)
restoreBtn.Visible = false
restoreBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
restoreBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(1, 0)

closeBtn.MouseButton1Click:Connect(function() main.Visible = false; restoreBtn.Visible = true end)
restoreBtn.MouseButton1Click:Connect(function() main.Visible = true; restoreBtn.Visible = false end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 0.88, 0)
scroll.Position = UDim2.new(0, 5, 0.12, 0)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 3, 0)
scroll.ScrollBarThickness = 2

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--------------------------------------------------
-- UI BUILDER FUNCTIONS
--------------------------------------------------
local function createButton(txt, color)
    local btn = Instance.new("TextButton", scroll)
    btn.Text = txt
    btn.Size = UDim2.new(0.95, 0, 0, 35)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    Instance.new("UICorner", btn)
    return btn
end

local function createLabel(txt)
    local lbl = Instance.new("TextLabel", scroll)
    lbl.Text = txt
    lbl.Size = UDim2.new(0.95, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(0, 200, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    return lbl
end

--------------------------------------------------
-- FLY SYSTEM + SPEED ADJUSTER
--------------------------------------------------
createLabel("--- MOVEMENT ---")
local flySpeed = 50
local flying = false
local bv, bg

local flyInp = Instance.new("TextBox", scroll)
flyInp.PlaceholderText = "Fly Speed (Set before ON)"
flyInp.Size = UDim2.new(0.95, 0, 0, 30)
flyInp.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
flyInp.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", flyInp)

flyInp.FocusLost:Connect(function() flySpeed = tonumber(flyInp.Text) or 50 end)

local btnFly = createButton("FLY: OFF", Color3.fromRGB(50, 50, 80))
btnFly.MouseButton1Click:Connect(function()
    flying = not flying
    local char = player.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if flying then
        btnFly.Text = "FLY: ON"
        btnFly.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        hum.PlatformStand = true
        bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1,1,1) * 9e9
        bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(1,1,1) * 9e9
        
        task.spawn(function()
            while flying do
                bv.Velocity = camera.CFrame.LookVector * (hum.MoveDirection.Magnitude > 0 and flySpeed or 0)
                bg.CFrame = camera.CFrame
                RunService.RenderStepped:Wait()
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            hum.PlatformStand = false
        end)
    else
        btnFly.Text = "FLY: OFF"
        btnFly.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    end
end)

--------------------------------------------------
-- PLAYER LIST SYSTEM (TELEPORT & RUSUH)
--------------------------------------------------
createLabel("--- PLAYER LIST ---")
local playerScroll = Instance.new("ScrollingFrame", scroll)
playerScroll.Size = UDim2.new(0.95, 0, 0, 150)
playerScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
playerScroll.CanvasSize = UDim2.new(0, 0, 5, 0)
Instance.new("UICorner", playerScroll)
local pListLayout = Instance.new("UIListLayout", playerScroll)

local targetPlayer = nil
local modeRusuh = false

local function updatePlayerList()
    for _, child in pairs(playerScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local pBtn = Instance.new("TextButton", playerScroll)
            pBtn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            pBtn.Size = UDim2.new(1, 0, 0, 30)
            pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            pBtn.TextColor3 = Color3.new(1, 1, 1)
            pBtn.Font = Enum.Font.Gotham
            pBtn.TextSize = 10
            
            pBtn.MouseButton1Click:Connect(function()
                targetPlayer = p
                print("Selected: " .. p.Name)
                -- Feedback visual saat klik
                for _, b in pairs(playerScroll:GetChildren()) do 
                    if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(40, 40, 60) end 
                end
                pBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            end)
        end
    end
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

local btnRefresh = createButton("REFRESH LIST", Color3.fromRGB(0, 80, 150))
btnRefresh.MouseButton1Click:Connect(updatePlayerList)

createLabel("--- ACTIONS ---")
local btnTp = createButton("TELEPORT TO SELECTED", Color3.fromRGB(0, 170, 100))
btnTp.MouseButton1Click:Connect(function()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
    end
end)

local btnRusuh = createButton("MODE RUSUH: OFF", Color3.fromRGB(200, 50, 50))
btnRusuh.MouseButton1Click:Connect(function()
    modeRusuh = not modeRusuh
    btnRusuh.Text = modeRusuh and "MODE RUSUH: ON" or "MODE RUSUH: OFF"
    btnRusuh.BackgroundColor3 = modeRusuh and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(200, 50, 50)
    
    if modeRusuh then
        task.spawn(function()
            while modeRusuh do
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHRP = targetPlayer.Character.HumanoidRootPart
                    local myHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP then
                        -- Mengikuti posisi target (menempel)
                        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1)
                        player.Character.Humanoid.PlatformStand = true -- Freeze karakter agar tidak jatuh
                    end
                end
                task.wait()
            end
            player.Character.Humanoid.PlatformStand = false
        end)
    end
end)

createLabel("--- SERVER ---")
local btnRejoin = createButton("REJOIN SERVER", Color3.fromRGB(40, 40, 40))
btnRejoin.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, player)
end)
