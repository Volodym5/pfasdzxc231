-- Phantom Forces Aimbot - Visibility check + mouse mode default + mousemoverel guards

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Mouse = LocalPlayer:GetMouse()

_G.PF_Aimbot_Settings = _G.PF_Aimbot_Settings or {
    Enabled = false,
    TeamCheck = true,
    VisibilityCheck = false,
    FOV = 100,
    TargetPart = "Head",
    Mode = "Mouse",
    Smoothness = false,
    SmoothAmount = 0.5,
    Prediction = false,
    PredAmount = 10,
    ShowFOV = false,
    FOVColor = Color3.fromRGB(255, 50, 50),
    ShowDebug = false
}

local settings = _G.PF_Aimbot_Settings
local locked = false
local currentTargetModel = nil
local currentTargetPart = nil
local myTeamFolder = nil
local enemyTeamFolder = nil

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Radius = 100
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Filled = false
fovCircle.Transparency = 0.7

local function detectTeams()
    local myTeamColor = LocalPlayer.TeamColor
    if not myTeamColor then return false end
    local myColorNumber = myTeamColor.Number
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return false end

    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if teamFolder:IsA("Folder") then
            for _, model in ipairs(teamFolder:GetChildren()) do
                if model:IsA("Model") then
                    for _, part in ipairs(model:GetDescendants()) do
                        if part:IsA("BasePart") and part.Transparency < 0.5 then
                            local bc = part.BrickColor
                            if bc.Number == myColorNumber or bc.Name == "Earth blue" or bc.Name == "Royal blue" then
                                myTeamFolder = teamFolder
                                for _, other in ipairs(playersFolder:GetChildren()) do
                                    if other:IsA("Folder") and other ~= myTeamFolder then
                                        enemyTeamFolder = other
                                    end
                                end
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

local function getHeadPart(model)
    local highest = nil
    local highestY = -math.huge
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.7 and part.Position.Y > highestY then
            highestY = part.Position.Y
            highest = part
        end
    end
    return highest
end

local function getTargetPart(model)
    return getHeadPart(model)
end

local function isVisible(targetPos, model)
    local camPos = Camera.CFrame.Position
    local dir = targetPos - camPos
    local dist = dir.Magnitude
    if dist < 0.1 then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character or nil, model}
    rayParams.IgnoreWater = true
    local result = Workspace:Raycast(camPos, dir.Unit * dist, rayParams)
    return result == nil
end

local function canMoveMouse()
    return not GuiService.MenuIsOpen
        and UIS:GetFocusedTextBox() == nil
        and UIS.MouseBehavior ~= Enum.MouseBehavior.LockCenter
end

local function findNewTarget(mousePos)
    local bestModel = nil
    local bestPart = nil
    local bestDist = settings.FOV
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return nil, nil end

    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if not teamFolder:IsA("Folder") then continue end
        if settings.TeamCheck and myTeamFolder and teamFolder == myTeamFolder then continue end

        for _, model in ipairs(teamFolder:GetChildren()) do
            if not model:IsA("Model") then continue end
            
            local part = getTargetPart(model)
            if not part then continue end

            if settings.VisibilityCheck and not isVisible(part.Position, model) then continue end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end
            
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if dist < bestDist then
                bestDist = dist
                bestModel = model
                bestPart = part
            end
        end
    end

    return bestModel, bestPart
end

local function isTargetValid(model)
    if not model or not model.Parent then return false end
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    if not model:IsDescendantOf(playersFolder) then return false end

    local part = getTargetPart(model)
    if not part then return false end

    if settings.VisibilityCheck and not isVisible(part.Position, model) then return false end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return false end
    
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
    return dist < settings.FOV * 1.3
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        locked = true
        if not currentTargetModel or not isTargetValid(currentTargetModel) then
            local m, p = findNewTarget(Vector2.new(Mouse.X, Mouse.Y))
            if m and p then
                currentTargetModel = m
                currentTargetPart = p
            end
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        locked = false
        currentTargetModel = nil
        currentTargetPart = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if not settings.Enabled then return end
    if not locked then return end

    if not myTeamFolder then detectTeams() end

    if not isTargetValid(currentTargetModel) then
        currentTargetModel = nil
        currentTargetPart = nil
        local m, p = findNewTarget(Vector2.new(Mouse.X, Mouse.Y))
        if m and p then
            currentTargetModel = m
            currentTargetPart = p
        end
    end

    if not currentTargetModel or not currentTargetPart then return end

    local part = getTargetPart(currentTargetModel)
    if not part then
        currentTargetModel = nil
        return
    end
    currentTargetPart = part

    local targetPos = part.Position
    if settings.Prediction and part.Velocity then
        targetPos = targetPos + part.Velocity * settings.PredAmount / 100
    end

    if settings.Mode == "Camera" then
        local lookAt = CFrame.new(Camera.CFrame.Position, targetPos)
        if settings.Smoothness then
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, settings.SmoothAmount)
        else
            Camera.CFrame = lookAt
        end
    elseif settings.Mode == "Mouse" then
        if canMoveMouse() then
            local screenPos = Camera:WorldToScreenPoint(targetPos)
            mousemoverel(screenPos.X - Mouse.X, screenPos.Y - Mouse.Y)
        end
    end
end)

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

task.spawn(function()
    while task.wait(3) do
        detectTeams()
    end
end)

print("PF Aimbot loaded")
