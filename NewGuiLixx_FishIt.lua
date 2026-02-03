-- LIXX Fish It | ANDROID ULTIMATE VERSION FIXED
if getgenv().LixxFinalMobile then return end
getgenv().LixxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------
-- UI SETUP
--------------------------------------------------
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "LixxMobileUI"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.fromOffset(260, 380)
main.Position = UDim2.new(0.5, -130, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", main)
title.Text = "LIXX HUB FIX - MOBILE"
title.Size = UDim2.new(1, 0, 0.1, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 0.88, 0)
scroll.Position = UDim2.new(0, 5, 0.11, 0)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 3, 0)
scroll.ScrollBarThickness = 2

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createButton(txt, color)
    local btn = Instance.new("TextButton", scroll)
    btn.Text = txt
    btn.Size = UDim2.new(0.95, 0, 0, 35)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn)
    return btn
end

--------------------------------------------------
-- FIX FLY SYSTEM (MOBILE SENSITIVE)
--------------------------------------------------
local flying = false
local flySpeed = 60
local btnFly = createButton("FLY: OFF", Color3.fromRGB(150, 50, 50))

btnFly.MouseButton1Click:Connect(function()
    flying = not flying
    btnFly.Text = flying and "FLY: ON" or "FLY: OFF"
    btnFly.BackgroundColor3 = flying and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    
    local char = player.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    if flying then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1,1,1) * 9e9
        bv.Velocity = Vector3.new(0,0,0)
        
        local bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(1,1,1) * 9e9
        bg.CFrame = hrp.CFrame

        task.spawn(function()
            while flying do
                RunService.RenderStepped:Wait()
                -- Perbaikan: Menggunakan MoveDirection agar joystick sinkron dengan kamera
                local direction = hum.MoveDirection
                if direction.Magnitude > 0 then
                    bv.Velocity = direction * flySpeed
                else
                    bv.Velocity = Vector3.new(0, 0.01, 0) -- Anti gravitasi
                end
                bg.CFrame = camera.CFrame
            end
            bv:Destroy()
            bg:Destroy()
        end)
    end
end)

--------------------------------------------------
-- FAST FISH & SECRET LUCK
--------------------------------------------------
local fastFish = false
local btnFish = createButton("FAST FISH: OFF", Color3.fromRGB(100, 50, 150))

btnFish.MouseButton1Click:Connect(function()
    fastFish = not fastFish
    btnFish.Text = fastFish and "FAST FISH: ACTIVE" or "FAST FISH: OFF"
    
    task.spawn(function()
        while fastFish do
            task.wait(0.1) 
            -- CONTOH LOGIKA: Ganti 'Cast' dan 'Catch' sesuai nama RemoteEvent di gamemu
            -- local remote = game:GetService("ReplicatedStorage"):FindFirstChild("FishRemote")
            -- if remote then 
            --    remote:FireServer("Cast") 
            --    task.wait(0.5)
            --    remote:FireServer("Catch", true) -- "true" biasanya bypass minigame
            -- end
        end
    end)
end)

--------------------------------------------------
-- TELEPORT LIST (NO TYPING)
--------------------------------------------------
local tpLabel = Instance.new("TextLabel", scroll)
tpLabel.Text = "--- CLICK NAME TO TELEPORT ---"
tpLabel.Size = UDim2.new(0.9, 0, 0, 20)
tpLabel.TextColor3 = Color3.new(1, 0.8, 0)
tpLabel.BackgroundTransparency = 1

local listFrame = Instance.new("Frame", scroll)
listFrame.Size = UDim2.new(0.95, 0, 0, 150)
listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

local listScroll = Instance.new("ScrollingFrame", listFrame)
listScroll.Size = UDim2.new(1, 0, 1, 0)
listScroll.CanvasSize = UDim2.new(0, 0, 5, 0)
listScroll.BackgroundTransparency = 1

local listLayout = Instance.new("UIListLayout", listScroll)

local function updateList()
    for _, child in pairs(listScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local pBtn = Instance.new("TextButton", listScroll)
            pBtn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            pBtn.Size = UDim2.new(1, 0, 0, 30)
            pBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            pBtn.TextColor3 = Color3.new(1, 1, 1)
            
            pBtn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end

updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

--------------------------------------------------
-- REJOIN
--------------------------------------------------
local btnRejoin = createButton("REJOIN SERVER", Color3.fromRGB(70, 70, 70))
btnRejoin.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, player)
end)
