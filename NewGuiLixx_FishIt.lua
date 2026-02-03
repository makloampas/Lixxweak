-- LIXX Fish It | ANDROID V5 (FORCE RENDER & ANTI-REVERSE)
if getgenv().LixxFinalMobile then return end
getgenv().LixxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- UI RESET (Hapus yang lama biar gak tumpang tindih)
local oldUI = player.PlayerGui:FindFirstChild("LixxV4_Fixed") or player.PlayerGui:FindFirstChild("LixxV3")
if oldUI then oldUI:Destroy() end

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "LixxV5_Final"
sg.ResetOnSpawn = false

-- LOGO MINIMIZE
local logoBtn = Instance.new("TextButton", sg)
logoBtn.Text = "LIXX"
logoBtn.Size = UDim2.fromOffset(50, 50)
logoBtn.Position = UDim2.new(0, 15, 0.4, 0)
logoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
logoBtn.TextColor3 = Color3.white
logoBtn.Visible = false
Instance.new("UICorner", logoBtn).CornerRadius = UDim.new(1, 0)

-- MAIN FRAME
local main = Instance.new("Frame", sg)
main.Size = UDim2.fromOffset(260, 350)
main.Position = UDim2.new(0.5, -130, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- HEADER
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", header)

local closeBtn = Instance.new("TextButton", header)
closeBtn.Text = "❌"
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -35, 0.1, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.new(1, 0, 0)

closeBtn.MouseButton1Click:Connect(function() main.Visible = false; logoBtn.Visible = true end)
logoBtn.MouseButton1Click:Connect(function() main.Visible = true; logoBtn.Visible = false end)

-- SCROLLING FRAME (DIPERBAIKI)
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 0.85, 0)
scroll.Position = UDim2.new(0, 5, 0, 45)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0) -- Akan otomatis memanjang
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y -- INI KUNCINYA BIAR TOMBOL MUNCUL SEMUA

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = "Center"

local function createButton(txt, color)
    local btn = Instance.new("TextButton", scroll)
    btn.Text = txt
    btn.Size = UDim2.new(0.9, 0, 0, 45) -- Ukuran pas buat jari mobile
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.white
    btn.Font = "GothamBold"
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    return btn
end

--------------------------------------------------
-- FLY 3D FIX (MAJU = KAMERA DEPAN)
--------------------------------------------------
local flying = false
local flySpeed = 60
local btnFly = createButton("FLY 3D: OFF", Color3.fromRGB(130, 40, 40))

btnFly.MouseButton1Click:Connect(function()
    flying = not flying
    btnFly.Text = flying and "FLY 3D: ON" or "FLY 3D: OFF"
    btnFly.BackgroundColor3 = flying and Color3.fromRGB(40, 130, 40) or Color3.fromRGB(130, 40, 40)
    
    local char = player.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    if flying then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1, 1, 1) * 9e9
        local bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(1, 1, 1) * 9e9

        task.spawn(function()
            while flying do
                RunService.RenderStepped:Wait()
                local moveDir = hum.MoveDirection
                
                -- LOGIKA ANTI-KEBALIK:
                -- Kita pakai CFrame kamera sebagai acuan absolut
                if moveDir.Magnitude > 0 then
                    bv.Velocity = (camera.CFrame.LookVector * (moveDir.Magnitude * flySpeed))
                    -- Jika kamu gerak maju, LookVector akan membawa kamu ke arah yang kamu lihat (termasuk atas/bawah)
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
-- FAST FISH (ALGORITMA TIKTOK)
--------------------------------------------------
local btnFish = createButton("GOD REEL: OFF", Color3.fromRGB(100, 50, 180))
local fastFish = false

btnFish.MouseButton1Click:Connect(function()
    fastFish = not fastFish
    btnFish.Text = fastFish and "GOD REEL: ACTIVE" or "GOD REEL: OFF"
    
    task.spawn(function()
        while fastFish do
            task.wait(0.01)
            pcall(function()
                -- Cari Remote pancing secara agresif di semua folder
                for _, v in pairs(game:GetDescendants()) do
                    if v:IsA("RemoteEvent") and (v.Name:find("Reel") or v.Name:find("Fish")) then
                        v:FireServer(100) -- Kirim power tarikan 100 terus menerus
                    end
                end
            end)
        end
    end)
end)

--------------------------------------------------
-- TELEPORT LIST (AUTO-RENDER)
--------------------------------------------------
local listTitle = Instance.new("TextLabel", scroll)
listTitle.Text = "-- TAP PLAYER TO TELEPORT --"
listTitle.Size = UDim2.new(0.9, 0, 0, 30)
listTitle.TextColor3 = Color3.new(1, 0.8, 0)
listTitle.BackgroundTransparency = 1

local function updateTP()
    -- Hapus tombol player lama
    for _, v in pairs(scroll:GetChildren()) do
        if v:IsA("TextButton") and v.Name == "TP_BTN" then v:Destroy() end
    end
    -- Tambah baru
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", scroll)
            b.Name = "TP_BTN"
            b.Size = UDim2.new(0.9, 0, 0, 35)
            b.Text = p.DisplayName
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            b.TextColor3 = Color3.white
            Instance.new("UICorner", b)
            
            b.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end

updateTP()
Players.PlayerAdded:Connect(updateTP)
Players.PlayerRemoving:Connect(updateTP)

print("LIXX V5 LOADED - AUTO CANVAS ACTIVE")
