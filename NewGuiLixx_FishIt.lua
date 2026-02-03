-- LIXX Fish It | ANDROID ULTIMATE V2 (FIXED FLY & UI)
if getgenv().LixxFinalMobile then return end
getgenv().LixxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------
-- UI SETUP (MODERN & MINIMIZABLE)
--------------------------------------------------
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "LixxUltimateUI"
sg.ResetOnSpawn = false

-- Tombol Logo LIXX (Minimize)
local logoBtn = Instance.new("TextButton", sg)
logoBtn.Name = "LixxLogo"
logoBtn.Text = "LIXX"
logoBtn.Size = UDim2.fromOffset(50, 50)
logoBtn.Position = UDim2.new(0, 10, 0.1, 0)
logoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
logoBtn.TextColor3 = Color3.new(1, 1, 1)
logoBtn.Font = Enum.Font.GothamBold
logoBtn.Visible = false
local logoCorner = Instance.new("UICorner", logoBtn)
logoCorner.CornerRadius = UDim.new(1, 0)

local main = Instance.new("Frame", sg)
main.Size = UDim2.fromOffset(280, 400)
main.Position = UDim2.new(0.5, -140, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

-- Header & Close
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0.12, 0)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", header)

local title = Instance.new("TextLabel", header)
title.Text = "LIXX MOBILE HUB V2"
title.Size = UDim2.new(0.8, 0, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.new(0.05, 0, 0, 0)

local closeBtn = Instance.new("TextButton", header)
closeBtn.Text = "❌"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.15, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.new(1, 0, 0)

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    logoBtn.Visible = true
end)

logoBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    logoBtn.Visible = false
end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 0.85, 0)
scroll.Position = UDim2.new(0, 5, 0.14, 0)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 2.5, 0)
scroll.ScrollBarThickness = 0

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--------------------------------------------------
-- HELPERS
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

--------------------------------------------------
-- FIX FLY 3D (FULL DIRECTIONAL)
--------------------------------------------------
local flying = false
local flySpeed = 50
local btnFly = createButton("FLY 3D: OFF", Color3.fromRGB(150, 50, 50))

btnFly.MouseButton1Click:Connect(function()
    flying = not flying
    btnFly.Text = flying and "FLY 3D: ON" or "FLY 3D: OFF"
    btnFly.BackgroundColor3 = flying and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    if flying then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1,1,1) * 9e9
        bv.Velocity = Vector3.new(0, 0, 0)
        
        local bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(1,1,1) * 9e9
        bg.CFrame = hrp.CFrame

        task.spawn(function()
            while flying do
                RunService.RenderStepped:Wait()
                local moveDir = hum.MoveDirection
                
                if moveDir.Magnitude > 0 then
                    -- Logika Fly 3D: Mengikuti arah pandang kamera secara penuh (X, Y, Z)
                    bv.Velocity = camera.CFrame.LookVector * (moveDir.Z < 0 and flySpeed or -flySpeed) + 
                                  camera.CFrame.RightVector * (moveDir.X * flySpeed)
                    
                    -- Jika hanya gerak samping, LookVector dibatalkan
                    if moveDir.Z == 0 then
                        bv.Velocity = camera.CFrame.RightVector * (moveDir.X * flySpeed)
                    end
                else
                    bv.Velocity = Vector3.new(0, 0.1, 0)
                end
                bg.CFrame = camera.CFrame
            end
            bv:Destroy()
            bg:Destroy()
        end)
    end
end)

--------------------------------------------------
-- FAST FISH (VISUAL & RAPID)
--------------------------------------------------
local fastFish = false
local btnFish = createButton("INSTA-FISH (GOD): OFF", Color3.fromRGB(100, 50, 150))

btnFish.MouseButton1Click:Connect(function()
    fastFish = not fastFish
    btnFish.Text = fastFish and "GOD FISH: ACTIVE" or "INSTA-FISH (GOD): OFF"
    
    task.spawn(function()
        while fastFish do
            task.wait(0.01) -- Sangat cepat
            -- FITUR INI MENGASUMSIKAN REMOTE EVENT STANDAR GAME FISH IT
            -- Menarik semua ikan yang terdeteksi
            pcall(function()
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Click") then
                    -- Simulasi tarikan super cepat
                    for i = 1, 10 do
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                end
            end)
        end
    end)
end)

--------------------------------------------------
-- PLAYER TELEPORT LIST (AUTO REFRESH)
--------------------------------------------------
local tpListLabel = Instance.new("TextLabel", scroll)
tpListLabel.Text = "--- TELEPORT LIST ---"
tpListLabel.Size = UDim2.new(0.9, 0, 0, 25)
tpListLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
tpListLabel.BackgroundTransparency = 1

local listContainer = Instance.new("Frame", scroll)
listContainer.Size = UDim2.new(0.95, 0, 0, 120)
listContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", listContainer)

local listScroll = Instance.new("ScrollingFrame", listContainer)
listScroll.Size = UDim2.new(1, -10, 1, -10)
listScroll.Position = UDim2.new(0, 5, 0, 5)
listScroll.BackgroundTransparency = 1
listScroll.CanvasSize = UDim2.new(0, 0, 5, 0)
listScroll.ScrollBarThickness = 2

local listLayout = Instance.new("UIListLayout", listScroll)
listLayout.Padding = UDim.new(0, 5)

local function updatePlayers()
    for _, v in pairs(listScroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local pBtn = Instance.new("TextButton", listScroll)
            pBtn.Text = p.DisplayName
            pBtn.Size = UDim2.new(1, 0, 0, 30)
            pBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            pBtn.TextColor3 = Color3.white
            Instance.new("UICorner", pBtn)
            
            pBtn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end

updatePlayers()
Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)
