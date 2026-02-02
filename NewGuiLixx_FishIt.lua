--[[ 
    LIXX Fish It - Chloe Style UI
    Stable Boat Speed System
    Executor: Delta
]]

if getgenv().LixxFishItUI then return end
getgenv().LixxFishItUI = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- SETTINGS
local enabled = false
local SPEED = 300 -- default
local MIN_SPEED = 50
local MAX_SPEED = 700

local bv, hb

-- FIND BOAT (ANY BOAT)
local function getBoat()
    if not player.Character then return end
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
    if not boat then return false end

    local part = boat:FindFirstChildWhichIsA("BasePart")
    if not part then return false end

    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e8, 0, 1e8)
        bv.Parent = part
    end

    hb = RunService.Heartbeat:Connect(function()
        if enabled and bv and part then
            bv.Velocity = Vector3.new(
                part.CFrame.LookVector.X * SPEED,
                0,
                part.CFrame.LookVector.Z * SPEED
            )
        end
    end)

    return true
end

-- DISABLE
local function disableBoat()
    if hb then hb:Disconnect() hb = nil end
    if bv then bv:Destroy() bv = nil end
end

-- ================= UI =================

local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "LixxFishItUI"

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.25, 0.32)
main.Position = UDim2.fromScale(0.38, 0.32)
main.BackgroundColor3 = Color3.fromRGB(15, 30, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.UICorner = Instance.new("UICorner", main)
main.UICorner.CornerRadius = UDim.new(0,16)

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromScale(1, 0.18)
title.BackgroundTransparency = 1
title.Text = "LIXX | Fish It"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(0,255,140)

-- STATUS
local status = Instance.new("TextLabel", main)
status.Position = UDim2.fromScale(0,0.18)
status.Size = UDim2.fromScale(1,0.12)
status.BackgroundTransparency = 1
status.Text = "Status: OFF"
status.TextColor3 = Color3.fromRGB(255,80,80)
status.Font = Enum.Font.Gotham
status.TextScaled = true

-- TOGGLE
local toggle = Instance.new("TextButton", main)
toggle.Position = UDim2.fromScale(0.15,0.33)
toggle.Size = UDim2.fromScale(0.7,0.16)
toggle.Text = "ENABLE"
toggle.Font = Enum.Font.GothamBold
toggle.TextScaled = true
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(0,120,80)
toggle.UICorner = Instance.new("UICorner", toggle)

-- SPEED TEXT
local speedText = Instance.new("TextLabel", main)
speedText.Position = UDim2.fromScale(0.1,0.53)
speedText.Size = UDim2.fromScale(0.8,0.1)
speedText.BackgroundTransparency = 1
speedText.Text = "Speed: "..SPEED
speedText.Font = Enum.Font.Gotham
speedText.TextScaled = true
speedText.TextColor3 = Color3.fromRGB(200,255,220)

-- SLIDER BG
local sliderBg = Instance.new("Frame", main)
sliderBg.Position = UDim2.fromScale(0.1,0.65)
sliderBg.Size = UDim2.fromScale(0.8,0.07)
sliderBg.BackgroundColor3 = Color3.fromRGB(40,80,60)
sliderBg.BorderSizePixel = 0
sliderBg.UICorner = Instance.new("UICorner", sliderBg)

-- SLIDER
local slider = Instance.new("Frame", sliderBg)
slider.Size = UDim2.fromScale((SPEED-MIN_SPEED)/(MAX_SPEED-MIN_SPEED),1)
slider.BackgroundColor3 = Color3.fromRGB(0,255,140)
slider.BorderSizePixel = 0
slider.UICorner = Instance.new("UICorner", slider)

-- INFO
local info = Instance.new("TextLabel", main)
info.Position = UDim2.fromScale(0,0.78)
info.Size = UDim2.fromScale(1,0.15)
info.BackgroundTransparency = 1
info.Text = "⚠ Naik kapal dulu (bebas kapal apa saja)"
info.TextScaled = true
info.Font = Enum.Font.Gotham
info.TextColor3 = Color3.fromRGB(255,200,120)

-- TOGGLE FUNC
toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        if enableBoat() then
            status.Text = "Status: ON"
            status.TextColor3 = Color3.fromRGB(0,255,140)
            toggle.Text = "DISABLE"
        else
            enabled = false
        end
    else
        disableBoat()
        status.Text = "Status: OFF"
        status.TextColor3 = Color3.fromRGB(255,80,80)
        toggle.Text = "ENABLE"
    end
end)

-- SLIDER FUNC
sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local move
        move = RunService.RenderStepped:Connect(function()
            local x = math.clamp(
                (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X,
                0,1
            )
            slider.Size = UDim2.fromScale(x,1)
            SPEED = math.floor(MIN_SPEED + (MAX_SPEED-MIN_SPEED)*x)
            speedText.Text = "Speed: "..SPEED
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                move:Disconnect()
            end
        end)
    end
end)

print("✅ LIXX Fish It UI Loaded | Chloe Style")
