-- LIXX Fish It | ANDROID ULTIMATE VERSION
if getgenv().LixxFinalMobile then return end
getgenv().LixxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------
-- UI SETUP (SCROLLING & MOBILE FRIENDLY)
--------------------------------------------------
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "LixxMobileUI"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.fromOffset(250, 350)
main.Position = UDim2.new(0.5, -125, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

-- Corner UI agar terlihat modern
local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", main)
title.Text = "LIXX MOBILE HUB"
title.Size = UDim2.new(1, 0, 0.12, 0)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold

-- Tombol Close & Restore
local closeBtn = Instance.new("TextButton", main)
closeBtn.Text = "X"
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.new(1, 0, 0)

local restoreBtn = Instance.new("TextButton", sg)
restoreBtn.Text = "OPEN"
restoreBtn.Size = UDim2.fromOffset(60, 40)
restoreBtn.Position = UDim2.new(0, 10, 0.5, 0)
restoreBtn.Visible = false
restoreBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
restoreBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", restoreBtn)

closeBtn.MouseButton1Click:Connect(function() main.Visible = false; restoreBtn.Visible = true end)
restoreBtn.MouseButton1Click:Connect(function() main.Visible = true; restoreBtn.Visible = false end)

-- SCROLLING CONTAINER
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 0.85, 0)
scroll.Position = UDim2.new(0, 5, 0.13, 0)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 2, 0) -- Area scroll panjang ke bawah
scroll.ScrollBarThickness = 3

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--------------------------------------------------
-- FUNGSI PEMBANTU (HELPERS)
--------------------------------------------------
local function createButton(txt, color)
    local btn = Instance.new("TextButton", scroll)
    btn.Text = txt
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn)
    return btn
end

local function createInput(place)
    local inp = Instance.new("TextBox", scroll)
    inp.PlaceholderText = place
    inp.Size = UDim2.new(0.9, 0, 0, 35)
    inp.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    inp.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", inp)
    return inp
end

--------------------------------------------------
-- FITUR: FLY SYSTEM (STABLE LOOKVECTOR)
--------------------------------------------------
local flying = false
local flySpeed = 50
local bv, bg

local btnFly = createButton("FLY: OFF", Color3.fromRGB(150, 50, 50))
btnFly.MouseButton1Click:Connect(function()
    flying = not flying
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if flying then
        btnFly.Text = "FLY: ON"
        btnFly.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        hum.PlatformStand = true
        bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1,1,1) * 9e9
        bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(1,1,1) * 9e9
        
        task.spawn(function()
            while flying do
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    -- Fly mengikuti arah pandang kamera
                    bv.Velocity = camera.CFrame:VectorToWorldSpace(Vector3.new(moveDir.X, 0, moveDir.Z * -1).Unit * flySpeed)
                else
                    bv.Velocity = Vector3.new(0, 0.1, 0)
                end
                bg.CFrame = camera.CFrame
                RunService.RenderStepped:Wait()
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            hum.PlatformStand = false
        end)
    else
        btnFly.Text = "FLY: OFF"
        btnFly.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end
end)

--------------------------------------------------
-- FITUR: SPEED HACK
--------------------------------------------------
local walkSpeedVal = 16
local speedInp = createInput("WalkSpeed (Default 16)")
speedInp.FocusLost:Connect(function()
    walkSpeedVal = tonumber(speedInp.Text) or 16
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = walkSpeedVal
    end
end)

--------------------------------------------------
-- FITUR: TELEPORT PLAYER
--------------------------------------------------
local tpInp = createInput("Target Username")
local btnTp = createButton("TELEPORT TO PLAYER", Color3.fromRGB(0, 120, 200))

btnTp.MouseButton1Click:Connect(function()
    local targetName = tpInp.Text:lower()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Name:lower():sub(1, #targetName) == targetName or v.DisplayName:lower():sub(1, #targetName) == targetName then
            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
                break
            end
        end
    end
end)

--------------------------------------------------
-- FITUR: SERVER REFRESH (REJOIN)
--------------------------------------------------
local btnRejoin = createButton("REJOIN SERVER", Color3.fromRGB(80, 80, 80))
btnRejoin.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, player)
end)

--------------------------------------------------
-- FITUR: AUTO FISH (BASIC TRIGGER)
--------------------------------------------------
local autoFish = false
local btnFish = createButton("AUTO FISH: OFF", Color3.fromRGB(100, 50, 150))
btnFish.MouseButton1Click:Connect(function()
    autoFish = not autoFish
    btnFish.Text = autoFish and "AUTO FISH: ON" or "AUTO FISH: OFF"
    -- Logika auto fish bisa kamu sesuaikan dengan remote event game pancingmu
end)
