-- LIXX Fish It | ULTIMATE MOBILE V2
if getgenv().LixxFinalMobile then return end
getgenv().LixxFinalMobile = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Variables untuk Fitur
local _G = {
    AutoFish = false,
    FastPull = false,
    NoVisual = false,
    PullDelay = 0.1 -- Default delay tarik
}

--------------------------------------------------
-- UI CONSTRUCTION (PREMIUM LOOK)
--------------------------------------------------
local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "LixxPremiumUI"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.fromOffset(320, 400)
main.Position = UDim2.new(0.5, -160, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 15)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(50, 50, 60)
stroke.Thickness = 2

local title = Instance.new("TextLabel", main)
title.Text = "LIXX HUB: FISH IT EDITION"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 15)

-- Container Scroll
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
scroll.ScrollBarThickness = 2

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--------------------------------------------------
-- UI BUILDER FUNCTIONS
--------------------------------------------------
local function createToggle(txt, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Text = txt .. ": OFF"
    btn.Size = UDim2.new(0.95, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamSemibold
    local brdr = Instance.new("UICorner", btn)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = txt .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.new(1, 1, 1)
        callback(state)
    end)
end

local function createInput(place, callback)
    local inp = Instance.new("TextBox", scroll)
    inp.PlaceholderText = place
    inp.Size = UDim2.new(0.95, 0, 0, 40)
    inp.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    inp.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", inp)
    inp.FocusLost:Connect(function() callback(inp.Text) end)
end

--------------------------------------------------
-- FITUR: AUTO FISHING & FAST PULL
--------------------------------------------------
-- Logika Auto Pull (Mendeteksi saat ikan menggigit dan langsung menarik)
task.spawn(function()
    while task.wait() do
        if _G.AutoFish then
            -- Simulasi Lempar Pancing (Sesuaikan Remote Event dengan Game)
            -- Game Fish It biasanya menggunakan RemoteEvent di ReplicatedStorage
            local tool = player.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("RemoteEvent") then 
                -- Logika spesifik game: memanggil fungsi cast/pull
                if _G.FastPull then
                    task.wait(_G.PullDelay)
                    -- Trigger narik di sini
                end
            end
        end
    end
end)

createToggle("AUTO FISHING", function(v) _G.AutoFish = v end)
createToggle("FAST PULL (CEPAT)", function(v) _G.FastPull = v end)
createToggle("NO VISUAL (ANTI LAG)", function(v) 
    _G.NoVisual = v
    -- Sembunyikan efek air/pancing jika aktif
end)

createInput("Delay Tarik (Contoh: 0.1)", function(val)
    _G.PullDelay = tonumber(val) or 0.1
end)

--------------------------------------------------
-- FITUR TAMBAHAN (MOVEMENT)
--------------------------------------------------
createToggle("WALKSPEED HACK", function(v)
    player.Character.Humanoid.WalkSpeed = v and 50 or 16
end)

local btnRejoin = Instance.new("TextButton", scroll)
btnRejoin.Text = "REJOIN SERVER"
btnRejoin.Size = UDim2.new(0.95, 0, 0, 40)
btnRejoin.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
btnRejoin.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", btnRejoin)
btnRejoin.MouseButton1Click:Connect(function() 
    game:GetService("TeleportService"):Teleport(game.PlaceId, player) 
end)

-- Tombol Minimize
local minBtn = Instance.new("TextButton", sg)
minBtn.Size = UDim2.fromOffset(50, 50)
minBtn.Position = UDim2.new(0, 10, 0.4, 0)
minBtn.Text = "LIXX"
minBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
minBtn.TextColor3 = Color3.new(0,0,0)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

minBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)
