-- LIXX Fish It | ANDROID ULTIMATE V3 (FINAL REPAIR)
if getgenv().LixxFinalMobile then return end
getgenv().LixxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------
-- UI SETUP (FIXED LIST & LOGO)
--------------------------------------------------
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "LixxV3"
sg.ResetOnSpawn = false

local logoBtn = Instance.new("TextButton", sg)
logoBtn.Text = "LIXX"
logoBtn.Size = UDim2.fromOffset(55, 55)
logoBtn.Position = UDim2.new(0, 15, 0.15, 0)
logoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
logoBtn.TextColor3 = Color3.new(1, 1, 1)
logoBtn.Visible = false
Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(1, 0)

local main = Instance.new("Frame", sg)
main.Size = UDim2.fromOffset(280, 420)
main.Position = UDim2.new(0.5, -140, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", header)

local title = Instance.new("TextLabel", header)
title.Text = " LIXX MOBILE V3 - FIXED"
title.Size = UDim2.new(0.7, 0, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextXAlignment = "Left"
title.Position = UDim2.new(0.05, 0, 0, 0)

local closeBtn = Instance.new("TextButton", header)
closeBtn.Text = "❌"
closeBtn.Size = UDim2.fromOffset(35, 35)
closeBtn.Position = UDim2.new(1, -40, 0.1, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.new(1, 0, 0)

closeBtn.MouseButton1Click:Connect(function() main.Visible = false; logoBtn.Visible = true end)
logoBtn.MouseButton1Click:Connect(function() main.Visible = true; logoBtn.Visible = false end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 0.85, 0)
scroll.Position = UDim2.new(0, 5, 0.12, 5)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
scroll.ScrollBarThickness = 0

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 7)
layout.HorizontalAlignment = "Center"

--------------------------------------------------
-- FIX FLY 3D (REVERSED CONTROL FIXED)
--------------------------------------------------
local flying = false
local flySpeed = 70
local btnFly = Instance.new("TextButton", scroll)
btnFly.Text = "FLY 3D: OFF"
btnFly.Size = UDim2.new(0.9, 0, 0, 40)
btnFly.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
btnFly.TextColor3 = Color3.white
Instance.new("UICorner", btnFly)

btnFly.MouseButton1Click:Connect(function()
    flying = not flying
    btnFly.Text = flying and "FLY 3D: ON" or "FLY 3D: OFF"
    btnFly.BackgroundColor3 = flying and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    
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
                RunService.RenderStepped:Wait()
                local moveDir = hum.MoveDirection
                -- FIX: Menggunakan negatif LookVector agar arah joystick maju = kamera maju
                if moveDir.Magnitude > 0 then
                    bv.Velocity = (camera.CFrame.LookVector * (moveDir.Z * -flySpeed)) + 
                                  (camera.CFrame.RightVector * (moveDir.X * flySpeed))
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
-- MANCING CEPAT (GOD REEL) - ALA TIKTOK
--------------------------------------------------
local godFish = false
local btnFish = Instance.new("TextButton", scroll)
btnFish.Text = "GOD FISH: OFF"
btnFish.Size = UDim2.new(0.9, 0, 0, 40)
btnFish.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
btnFish.TextColor3 = Color3.white
Instance.new("UICorner", btnFish)

btnFish.MouseButton1Click:Connect(function()
    godFish = not godFish
    btnFish.Text = godFish and "GOD FISH: ACTIVE" or "GOD FISH: OFF"
    
    task.spawn(function()
        while godFish do
            task.wait(0.05) -- Delay minimal biar gak crash tapi narik gila-gilaan
            pcall(function()
                -- Mencari tool pancing di karakter
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    -- Mengirim sinyal "Click" atau "Pull" ke server berkali-kali
                    -- Kamu bisa sesuaikan nama Remote-nya jika tau (contoh: FishEvents)
                    local re = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
                    if re then
                        re:FireServer("Reel", 100) -- Menarik dengan power 100
                    end
                end
            end)
        end
    end)
end)

--------------------------------------------------
-- TELEPORT LIST (FIXED UI & AUTO REFRESH)
--------------------------------------------------
local tpTitle = Instance.new("TextLabel", scroll)
tpTitle.Text = "--- PLAYER LIST (TAP TO TP) ---"
tpTitle.Size = UDim2.new(0.9, 0, 0, 25)
tpTitle.TextColor3 = Color3.new(1, 0.8, 0)
tpTitle.BackgroundTransparency = 1

local listFrame = Instance.new("Frame", scroll)
listFrame.Size = UDim2.new(0.95, 0, 0, 150)
listFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", listFrame)

local listScroll = Instance.new("ScrollingFrame", listFrame)
listScroll.Size = UDim2.new(1, -10, 1, -10)
listScroll.Position = UDim2.new(0, 5, 0, 5)
listScroll.BackgroundTransparency = 1
listScroll.ScrollBarThickness = 3
listScroll.CanvasSize = UDim2.new(0, 0, 0, 0) -- Akan update otomatis

local listLayout = Instance.new("UIListLayout", listScroll)
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    listScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end)

local function refreshList()
    for _, v in pairs(listScroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local pBtn = Instance.new("TextButton", listScroll)
            pBtn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            pBtn.Size = UDim2.new(1, -5, 0, 30)
            pBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            pBtn.TextColor3 = Color3.white
            pBtn.Font = "Gotham"
            pBtn.TextSize = 12
            Instance.new("UICorner", pBtn)
            
            pBtn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end

refreshList()
Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)

print("LIXX V3 LOADED SUCCESSFULLY")
