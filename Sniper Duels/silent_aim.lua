-- ========================================================
-- SILENT AIM - LIVE TEST (will actually redirect shots)
-- ========================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local settings = {
    enabled = false,
    fov = 100,
    hitpart = "Head",
    visibleOnly = true
}

-- ========================================================
-- FIND TARGET
-- ========================================================
local function isVisible(part)
    if not settings.visibleOnly then return true end
    
    local camPos = camera.CFrame.Position
    local targetPos = part.Position
    local direction = (targetPos - camPos).Unit
    local distance = (targetPos - camPos).Magnitude - 0.5
    
    if distance <= 0 then return true end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character or {}}
    rayParams.IgnoreWater = true
    
    local rayResult = Workspace:Raycast(camPos, direction * distance, rayParams)
    
    if rayResult then
        local hitChar = rayResult.Instance:FindFirstAncestorOfClass("Model")
        return hitChar and hitChar == part.Parent
    end
    
    return true
end

local function nearest()
    local best, bestDist = nil, settings.fov
    local center = camera.ViewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        if not char then continue end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hp = char:FindFirstChild(settings.hitpart)
        
        if not hp or not hum or hum.Health <= 0 then continue end
        if not isVisible(hp) then continue end
        
        local sp, vis = camera:WorldToViewportPoint(hp.Position)
        if not vis then continue end
        
        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if d < bestDist then
            bestDist = d
            best = hp
        end
    end
    
    return best
end

-- ========================================================
-- LIVE SILENT AIM
-- ========================================================
print("========================================")
print("SILENT AIM - LIVE TEST")
print("========================================")
print("⚠️ This WILL redirect shots to enemies")
print("========================================")

local gunMod = require(ReplicatedStorage.Modules.Controllers.WeaponController.Gun)
local uvs = {debug.getupvalues(gunMod.Fire)}
local theTable = uvs[1]
local targetFunction = theTable[12]

local orig
local success = pcall(function()
    orig = hookfunction(targetFunction, newcclosure(function(...)
        local args = {...}
        
        if settings.enabled then
            local tgt = nearest()
            if tgt then
                args[5] = tgt.Position  -- target position
                args[6] = tgt           -- hitpart
            end
        end
        
        return orig(unpack(args))
    end))
end)

if success then
    print("✅ Ready!")
    print("Press Y to toggle")
else
    print("❌ Failed")
end

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.Y then
        settings.enabled = not settings.enabled
        print("Silent aim: " .. (settings.enabled and "ON" or "OFF"))
    end
end)

print("========================================")
