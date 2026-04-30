-- Phantom Forces Aimbot - Rendering Engine

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
    FOVColor = Color3.fromRGB(255, 50, 50)
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

-- Get team color from player
local function getPlayerTeamColor(player)
    if not player.Character then return nil end
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.5 then
            local bc = part.BrickColor
            if bc.Name ~= "Black" and bc.Name ~= "White" and bc.Name ~= "Medium stone grey" and
               bc.Name ~= "Cashmere" and bc.Name ~= "Seashell" and bc.Name ~= "Dark taupe" and
               bc.Name ~= "Medium brown" and bc.Name ~= "Brown" and bc.Name ~= "Black metallic" then
                return bc.Number, bc.Name
            end
        end
    end
    return nil
end

-- Check if player is teammate
local function isTeammate(player)
    local myTeamColor = LocalPlayer.TeamColor
    if not myTeamColor then return false end
    
    local playerColorNum, playerColorName = getPlayerTeamColor(player)
    if not playerColorNum then return false end
    
    if playerColorNum == myTeamColor.Number then return true end
    if playerColorName == "Earth blue" or playerColorName == "Royal blue" then
        return myTeamColor.Name == "Bright blue" or myTeamColor.Name == "Earth blue" or myTeamColor.Name == "Royal blue"
    end
    
    return false
end

-- Get closest target to mouse within FOV
local function getClosestTarget()
    local closest = nil
    local shortestDist = settings.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local targetPart = player.Character:FindFirstChild(settings.TargetPart)
        if not targetPart then continue end
        
        -- Team check
        if settings.TeamCheck and isTeammate(player) then continue end
        
        -- Visibility check
        if settings.VisibilityCheck then
            local ignoreList = {LocalPlayer.Character, player.Character}
            local rayOrigin = Camera.CFrame.Position
            local rayDir = (targetPart.Position - rayOrigin).Unit * 1000
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = ignoreList
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            local rayResult = workspace:Raycast(rayOrigin, rayDir, rayParams)
            if rayResult and rayResult.Instance:IsDescendantOf(player.Character) == false then
                continue
            end
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist < shortestDist then
            shortestDist = dist
            closest = player
        end
    end
    
    return closest
end

-- FOV circle update
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

-- Track RMB state
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        locked = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        locked = false
    end
end)

-- Aimbot update
RunService.RenderStepped:Connect(function()
    if not settings.Enabled then return end
    if not locked then return end
    
    local target = getClosestTarget()
    if not target then return end
    
    local targetPart = target.Character:FindFirstChild(settings.TargetPart)
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

print("PF Aimbot Engine loaded")
