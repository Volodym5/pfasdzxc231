-- Phantom Forces Aimbot

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

_G.PF_Aimbot_Settings = _G.PF_Aimbot_Settings or {
    Enabled = false,
    TeamCheck = true,
    VisibilityCheck = false,
    FOV = 100,
    TargetPart = "Head",
    Mode = "Camera",
    Smoothness = false,
    SmoothAmount = 0.5,
    Prediction = false,
    PredAmount = 10,
    ShowFOV = false,
    FOVColor = Color3.fromRGB(255, 50, 50),
    ShowDebug = true
}

local settings = _G.PF_Aimbot_Settings
local locked = false

-- FOV circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Radius = 100
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Filled = false
fovCircle.Transparency = 0.7

-- Debug lines to show what the aimbot sees
local debugLines = {}
local function clearDebugLines()
    for _, line in ipairs(debugLines) do
        pcall(function() line:Remove() end)
    end
    debugLines = {}
end

local function addDebugLine(from, to, color)
    local line = Drawing.new("Line")
    line.From = from
    line.To = to
    line.Color = color or Color3.fromRGB(255, 255, 0)
    line.Thickness = 1
    line.Transparency = 0.5
    table.insert(debugLines, line)
    return line
end

-- Find head (highest part)
local function getHeadPart(model)
    local highest = nil
    local highestY = -math.huge
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.7 then
            if part.Position.Y > highestY then
                highestY = part.Position.Y
                highest = part
            end
        end
    end
    return highest
end

-- Find torso (middle part)
local function getTorsoPart(model)
    local parts = {}
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.7 then
            table.insert(parts, part)
        end
    end
    if #parts == 0 then return nil end
    table.sort(parts, function(a, b) return a.Position.Y > b.Position.Y end)
    return parts[math.floor(#parts / 2)]
end

local function getTargetPart(character)
    if settings.TargetPart == "Head" then
        return getHeadPart(character)
    else
        return getTorsoPart(character)
    end
end

-- Team check
local function isTeammate(player)
    if not player.Character then return false end
    local myTeamColor = LocalPlayer.TeamColor
    if not myTeamColor then return false end
    local myColorNumber = myTeamColor.Number
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.5 then
            local bc = part.BrickColor
            if bc.Number == myColorNumber or bc.Name == "Earth blue" or bc.Name == "Royal blue" then
                return true
            end
        end
    end
    return false
end

-- Get closest target
local function getClosestTarget()
    clearDebugLines()
    
    local closest = nil
    local shortestDist = settings.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local guiInset = game:GetService("GuiService"):GetGuiInset()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local targetPart = getTargetPart(player.Character)
        if not targetPart then continue end
        
        if settings.TeamCheck and isTeammate(player) then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        
        -- Debug: show line to every valid target in FOV
        if settings.ShowDebug and dist < settings.FOV then
            local color = (closest == nil or dist < shortestDist) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
            addDebugLine(
                Vector2.new(Mouse.X, Mouse.Y + guiInset.Y),
                Vector2.new(screenPos.X, screenPos.Y),
                color
            )
        end
        
        if dist < shortestDist then
            shortestDist = dist
            closest = player
        end
    end
    
    -- Highlight selected target with bright line
    if closest and settings.ShowDebug then
        local tp = getTargetPart(closest.Character)
        if tp then
            local sp = Camera:WorldToViewportPoint(tp.Position)
            addDebugLine(
                Vector2.new(Mouse.X, Mouse.Y + guiInset.Y),
                Vector2.new(sp.X, sp.Y),
                Color3.fromRGB(0, 255, 255)
            )
        end
    end
    
    return closest
end

-- FOV circle
task.spawn(function()
    while task.wait() do
        if settings.ShowFOV then
            fovCircle.Visible = true
            fovCircle.Radius = settings.FOV
            fovCircle.Color = settings.FOVColor
            local guiInset = game:GetService("GuiService"):GetGuiInset()
            fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y + guiInset.Y)
        else
            fovCircle.Visible = false
        end
    end
end)

-- Hold RMB to lock
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        locked = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        locked = false
        clearDebugLines()
    end
end)

-- Aimbot
RunService.RenderStepped:Connect(function()
    if not settings.Enabled then
        clearDebugLines()
        return
    end
    if not locked then
        clearDebugLines()
        return
    end
    
    local target = getClosestTarget()
    if not target then return end
    
    local targetPart = getTargetPart(target.Character)
    if not targetPart then return end
    
    local targetPos = targetPart.Position
    
    -- Prediction
    if settings.Prediction and targetPart.Velocity then
        targetPos = targetPos + targetPart.Velocity * settings.PredAmount / 100
    end
    
    if settings.Mode == "Camera" then
        local lookAt = CFrame.new(Camera.CFrame.Position, targetPos)
        if settings.Smoothness then
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, settings.SmoothAmount)
        else
            Camera.CFrame = lookAt
        end
    elseif settings.Mode == "Mouse" then
        local screenPos = Camera:WorldToScreenPoint(targetPos)
        mousemoverel(screenPos.X - Mouse.X, screenPos.Y - Mouse.Y)
    end
end)

print("PF Aimbot loaded")
