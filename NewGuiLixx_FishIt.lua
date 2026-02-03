-- LIXX Fish It | ANDROID ULTIMATE V4 (ULTRA FIX)
if getgenv().LixxFinalMobile then return end
getgenv().LixxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------
-- UI SETUP (RESPONSIVE MOBILE)
--------------------------------------------------
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "LixxV4_Fixed"
sg.ResetOnSpawn = false

-- Tombol Logo LIXX
local logoBtn = Instance.new("TextButton", sg)
logoBtn.Text = "LIXX"
logoBtn.Size = UDim2.fromOffset(50, 50)
logoBtn.Position = UDim2.new(0, 10, 0.2, 0)
logoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
logoBtn.TextColor3 = Color3.white
logoBtn.Visible = false
Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(1, 0)

local main = Instance.new("Frame", sg)
main.Size = UDim2.fromOffset(260, 380)
main.Position = UDim2.new(0.5, -130, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", header)

local title = Instance.new("TextLabel", header)
title.Text = " LIXX V4 - ULTRA FIX"
title.Size = UDim2.new(0.8, 0, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.white
title.Font = "GothamBold"
title.TextXAlignment = "Left"
title.Position = UDim2.new(0.05, 0, 0, 0)

local closeBtn = Instance.new("TextButton", header)
closeBtn.Text = "❌"
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -35, 0.1, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.new(1, 0, 0)

closeBtn.MouseButton1Click:Connect(function() main.Visible = false; logoBtn.Visible = true end)
logoBtn.MouseButton1Click:Connect(function() main.Visible = true; logoBtn.Visible = false end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 0.85, 0)
scroll.Position = UDim2.new(0, 5, 0.12, 5)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
scroll.CanvasSize = UDim2.new(0, 0, 0, 500) -- Memastikan area scroll cukup luas

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = "Center"

--------------------------------------------------
-- FLY 3D (DIPERBAIKI)
--------------------------------------------------
local flying = false
local flySpeed = 60
local btnFly = Instance.new("TextButton", scroll)
btnFly.Text = "FLY 3D: OFF"
btnFly.Size = UDim2.new(0.9, 0, 0, 45)
btnFly.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
btnFly.TextColor3 = Color3.white
Instance.new("UICorner", btnFly)

btnFly.MouseButton1Click:Connect(function()
    flying = not flying
    btnFly.Text = flying and "FLY 3D: ON" or "FLY 3D: OFF"
    btnFly.BackgroundColor3 = flying and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(120, 40, 40)
    
    local char = player.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    if flying then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1,1,1) * 9e9
        local bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(1,1,1) * 9e9

        task.spawn(function()
            while flying do
                RunService.Heartbeat:Wait()
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    -- Kalkulasi arah: Kamera LookVector digunakan secara penuh (Maju = Ke depan kamera)
                    bv.Velocity = camera.CFrame:VectorToWorldSpace(Vector3.new(moveDir.X, 0, moveDir.Z * 1).Unit * -flySpeed)
                else
                    bv.Velocity = Vector3.new(0, 0.1, 0)
                end
                bg.CFrame = camera.CFrame
            end
            bv:Destroy(); bg:Destroy()
        end)
    end
end)

--------------------------------------------------
-- GOD FISH (PULL CEPAT)
--------------------------------------------------
local godFish = false
local btnFish = Instance.new("TextButton", scroll)
btnFish.Text = "GOD FISH: OFF"
btnFish.Size = UDim2.new(0.9, 0, 0, 45)
btnFish.BackgroundColor3 = Color3.fromRGB(80, 40, 150)
btnFish.TextColor3 = Color3.white
Instance.new("UICorner", btnFish)

btnFish.MouseButton1Click:Connect(function()
    godFish = not godFish
    btnFish.Text = godFish and "GOD FISH: ACTIVE" or "GOD FISH: OFF"
    
    task.spawn(function()
        while godFish do
            task.wait(0.01)
            pcall(function()
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool and tool.Name:lower():find("rod") then
                    -- Mencoba menembak Remote pull secara umum
                    local events = game:GetService("ReplicatedStorage"):FindFirstChild("Events") or game:GetService("ReplicatedStorage")
                    for _, v in pairs(events:GetDescendants()) do
                        if v:IsA("RemoteEvent") and (v.Name:find("Reel") or v.Name:find("Catch")) then
                            v:FireServer(100) -- Power max
                        end
                    end
                end
            end)
        end
    end)
end)

--------------------------------------------------
-- TELEPORT LIST (AUTO-FIX)
--------------------------------------------------
local listTitle = Instance.new("TextLabel", scroll)
listTitle.Text = "-- TELEPORT LIST --"
listTitle.Size = UDim2.new(0.9, 0, 0, 20)
listTitle.TextColor3 = Color3.new(0, 1, 0.5)
listTitle.BackgroundTransparency = 1

local listFrame = Instance.new("Frame", scroll)
listFrame.Size = UDim2.new(0.95, 0, 0, 150)
listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", listFrame)

local listScroll = Instance.new("ScrollingFrame", listFrame)
listScroll.Size = UDim2.new(1, -10, 1, -10)
listScroll.Position = UDim2.new(0, 5, 0, 5)
listScroll.BackgroundTransparency = 1
listScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UIListLayout", listScroll).Padding = UDim.new(0, 5)

local function updateTP()
    for _, v in pairs(listScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", listScroll)
            b.Size = UDim2.new(1, 0, 0, 30)
            b.Text = p.DisplayName
            b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            b.TextColor3 = Color3.white
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
    listScroll.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 35)
end

updateTP()
Players.PlayerAdded:Connect(updateTP)
Players.PlayerRemoving:Connect(updateTP)
