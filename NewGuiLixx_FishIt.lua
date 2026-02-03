-- LIXX SIMPLE FIX | Fly + Telegram Notif
-- Tested logic (classic fly)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local request = request or http_request or (syn and syn.request)
if not request then return warn("HTTP not supported") end

------------------------------------------------
-- TELEGRAM CONFIG
------------------------------------------------
local BOT_TOKEN = "ISI_TOKEN_BOT"
local CHAT_ID = "ISI_USER_ID"

local function sendTG(msg)
    request({
        Url = "https://api.telegram.org/bot"..BOT_TOKEN.."/sendMessage",
        Method = "POST",
        Headers = {["Content-Type"]="application/json"},
        Body = HttpService:JSONEncode({
            chat_id = CHAT_ID,
            text = msg
        })
    })
end

------------------------------------------------
-- FISH DETECTOR (NO TIER, ALL FISH)
------------------------------------------------
local function fishFound(tool)
    if not tool:IsA("Tool") then return end

    local thumb = "https://www.roblox.com/asset-thumbnail/image?assetId=0&width=420&height=420&format=png"

    sendTG(
        "🎣 LIXX Fish Alert\n\n"..
        "👤 Player: "..player.Name..
        "\n🐟 Fish: "..tool.Name..
        "\n🖼️ "..thumb
    )
end

player.Backpack.ChildAdded:Connect(fishFound)
if player.Character then
    player.Character.ChildAdded:Connect(fishFound)
end
player.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(fishFound)
end)

sendTG("✅ LIXX aktif\nNotif ikan ON")

------------------------------------------------
-- CLASSIC FLY (ANTI FREEZE)
------------------------------------------------
local flying = false
local speed = 80
local bv, bg

local function startFly()
    local char = player.Character
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    hum:ChangeState(Enum.HumanoidStateType.Physics)

    bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e9,1e9,1e9)

    bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
    bg.P = 9e4

    RunService.RenderStepped:Connect(function()
        if not flying then return end
        local cam = workspace.CurrentCamera

        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

        bv.Velocity = dir * speed
        bg.CFrame = cam.CFrame
    end)
end

local function stopFly()
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

-- Toggle Fly (PRESS F)
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.F then
        flying = not flying
        if flying then
            startFly()
        else
            stopFly()
        end
    end
end)

print("LIXX LOADED | F = FLY")
