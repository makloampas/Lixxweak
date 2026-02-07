-- LIXX HUB | BLUE EDITION V2 (MOBILE OPTIMIZED)
if getgenv().LixxFinalMobile then return end
getgenv().LixxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- UI SETUP (COMPACT & NEON)
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "LixxBlueHub"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.fromOffset(250, 350) -- Ukuran lebih kecil/compact
main.Position = UDim2.new(0.5, -125, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Thickness = 1.5

-- TITLE BAR
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 85, 150)
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", titleBar)
title.Text = "LIXX HUB 🔵"
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Text = "✕"
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -32, 0, 2)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18

-- LOGO / MINIMIZE BUTTON
local restoreBtn = Instance.new("TextButton", sg)
restoreBtn.Text = "LX"
restoreBtn.Size = UDim2.fromOffset(45, 45)
restoreBtn.Position = UDim2.new(0, 10, 0.5, 0)
restoreBtn.Visible = false
restoreBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
restoreBtn.TextColor3 = Color3.new(1, 1, 1)
restoreBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", restoreBtn).Color = Color3.new(1,1,1)

closeBtn.MouseButton1Click:Connect(function() main.Visible = false; restoreBtn.Visible = true end)
restoreBtn.MouseButton1Click:Connect(function() main.Visible = true; restoreBtn.Visible = false end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 0.85, 0)
scroll.Position = UDim2.new(0, 5, 0.12, 5)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 4, 0) -- Lebih panjang untuk fitur baru
scroll.ScrollBarThickness = 0

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- HELPER FUNCTIONS
local function createButton(txt, color)
    local btn = Instance.new("TextButton", scroll)
    btn.Text = txt
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local function createLabel(txt)
    local lbl = Instance.new("TextLabel", scroll)
    lbl.Text = "— " .. txt .. " —"
    lbl.Size = UDim2.new(0.9, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(0, 200, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    return lbl
end

--- FITUR BARU: AUTO ISLAND TELEPORT ---
createLabel("ISLAND TELEPORT")
local islandContainer = Instance.new("Frame", scroll)
islandContainer.Size = UDim2.new(0.9, 0, 0, 100)
islandContainer.BackgroundTransparency = 1

local islandList = Instance.new("ScrollingFrame", islandContainer)
islandList.Size = UDim2.new(1, 0, 1, 0)
islandList.BackgroundTransparency = 0.9
islandList.BackgroundColor3 = Color3.new(1,1,1)
islandList.CanvasSize = UDim2.new(0,0,2,0)
islandList.ScrollBarThickness = 2
local iLayout = Instance.new("UIListLayout", islandList)

local function getIslands()
    for _, v in pairs(islandList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    
    -- Mencari folder yang biasanya berisi lokasi map (disesuaikan dengan game umum)
    local worldFolder = workspace:FindFirstChild("Islands") or workspace:FindFirstChild("Map") or workspace:FindFirstChild("World")
    
    if worldFolder then
        for _, island in pairs(worldFolder:GetChildren()) do
            local btn = Instance.new("TextButton", islandList)
            btn.Text = island.Name
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 10
            
            btn.MouseButton1Click:Connect(function()
                local targetPos = island:GetModelCFrame() or island.PrimaryPart.CFrame
                player.Character.HumanoidRootPart.CFrame = targetPos * CFrame.new(0, 10, 0)
            end)
        end
    else
        local err = Instance.new("TextLabel", islandList)
        err.Text = "Map Folder Not Found"
        err.Size = UDim2.new(1,0,1,0)
        err.TextColor3 = Color3.new(1,0,0)
    end
end

local btnScan = createButton("SCAN ISLANDS", Color3.fromRGB(0, 100, 200))
btnScan.MouseButton1Click:Connect(getIslands)

--- MOVEMENT & UTILS ---
createLabel("MOVEMENT")
local flySpeed = 50
local flying = false

local btnFly = createButton("FLY: OFF", Color3.fromRGB(40, 40, 60))
btnFly.MouseButton1Click:Connect(function()
    flying = not flying
    btnFly.Text = flying and "FLY: ON" or "FLY: OFF"
    btnFly.BackgroundColor3 = flying and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 60)
    
    if flying then
        local char = player.Character
        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1,1,1) * 9e9
        local bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(1,1,1) * 9e9
        
        task.spawn(function()
            while flying do
                bv.Velocity = camera.CFrame.LookVector * flySpeed
                bg.CFrame = camera.CFrame
                RunService.RenderStepped:Wait()
            end
            bv:Destroy()
            bg:Destroy()
            hum.PlatformStand = false
        end)
    end
end)

createLabel("SERVER")
createButton("REJOIN SERVER", Color3.fromRGB(50, 50, 50)).MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, player)
end)

-- Initial Scan
getIslands()
