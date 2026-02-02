--[[ 
    LIXX - Fish It Edition
    Stable Fast Boat System
    Executor: Delta
]]

if getgenv().LixxFishItLoaded then return end
getgenv().LixxFishItLoaded = true

-- MAP CHECK
if not game.PlaceId then return end
-- (Fish It biasanya tidak ganti PlaceId, jadi pakai nama map)
if not string.find(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name:lower(), "fish") then
    warn("[LIXX] This script only works in Fish It map")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- CONFIG
local SPEED = 220 -- STABIL (naikin pelan kalau mau)
local enabled = false

local bv
local hb

-- FIND BOAT
local function getBoat()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") and v.Occupant then
            if v.Occupant.Parent == player.Character then
                return v.Parent
            end
        end
    end
end

-- ENABLE
local function enableBoat()
    local boat = getBoat()
    if not boat then return end

    local part = boat:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e8, 0, 1e8) -- Y dikunci biar gak mental
        bv.Parent = part
    end

    hb = RunService.Heartbeat:Connect(function()
        if enabled and part and bv then
            bv.Velocity = Vector3.new(
                part.CFrame.LookVector.X * SPEED,
                0,
                part.CFrame.LookVector.Z * SPEED
            )
        end
    end)
end

-- DISABLE
local function disableBoat()
    if hb then hb:Disconnect() hb = nil end
    if bv then bv:Destroy() bv = nil end
end

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "LixxFishIt"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.2, 0.15)
frame.Position = UDim2.fromScale(0.4, 0.4)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1, 0.3)
title.Text = "LIXX | Fish It"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.fromScale(0.8, 0.4)
toggle.Position = UDim2.fromScale(0.1, 0.45)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.GothamBold
toggle.TextScaled = true

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        toggle.Text = "ON"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
        enableBoat()
    else
        toggle.Text = "OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(170,0,0)
        disableBoat()
    end
end)

print("🚤 LIXX Fish It Loaded | Stable Mode")
