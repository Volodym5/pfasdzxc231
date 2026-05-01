-- Phantom Forces Aimbot - Fixed with debug

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
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
local teamCheckTime = 0
local teamMap = {}
local debugPrinted = false

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Radius = 100
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Filled = false
fovCircle.Transparency = 0.7

-- Debug text
local debugText = Drawing.new("Text")
debugText.Visible = false
debugText.Size = 14
debugText.Color = Color3.fromRGB(255, 255, 255)
debugText.Center = true
debugText.Outline = true
debugText.Font = Drawing.Fonts.Monospace
debugText.Position = Vector2.new(200, 400)

local function updateTeamMap()
    local playersList = Players:GetPlayers()
    if #playersList == 0 then return end
    
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return end

    local myTeam = LocalPlayer.Team
    teamMap = {}

    local allModels = {}
    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if teamFolder:IsA("Folder") then
            for _, model in ipairs(teamFolder:GetChildren()) do
                if model:IsA("Model") then
                    local center = Vector3.zero
                    local count = 0
                    for _, part in ipairs(model:GetDescendants()) do
                        if part:IsA("BasePart") then
                            center = center + part.Position
                            count = count + 1
                        end
                    end
                    if count > 0 then
                        allModels[#allModels + 1] = { model = model, center = center / count }
                    end
                end
            end
        end
    end

    local matched = {}
    for _, data in ipairs(allModels) do
        local bestPlayer, bestDist = nil, 15
        for _, player in ipairs(playersList) do
            if not matched[player] and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - data.center).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestPlayer = player
                    end
                end
            end
        end
        if bestPlayer then
            local isFriendly = false
            if myTeam then
                isFriendly = (bestPlayer.Team == myTeam)
            elseif LocalPlayer.TeamColor and bestPlayer.TeamColor then
                isFriendly = (LocalPlayer.TeamColor.Number == bestPlayer.TeamColor.Number)
            end
            teamMap[data.model] = isFriendly
            matched[bestPlayer] = true
        end
    end
end

-- Simple highest-Y head detection (reliable, tested)
local function getHeadPosition(model)
    local highest = nil
    local highestY = -math.huge
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.7 and part.Position.Y > highestY then
            highestY = part.Position.Y
            highest = part
        end
    end
    if highest then
        return highest.Position + Vector3.new(0, highest.Size.Y / 2, 0)
    end
    return nil
end

local function isVisible(targetPos, model)
    local cam = workspace.CurrentCamera
    local camPos = cam.CFrame.Position
    local dir = targetPos - camPos
    local dist = dir.Magnitude
    if dist < 0.1 then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character or nil, model}
    rayParams.IgnoreWater = true
    local result = workspace:Raycast(camPos, dir.Unit * dist, rayParams)
    return result == nil
end

local function canMoveMouse()
    return not GuiService.MenuIsOpen
        and UIS:GetFocusedTextBox() == nil
        and UIS.MouseBehavior ~= Enum.MouseBehavior.LockCenter
end

local function findNewTarget(mousePos)
    local cam = workspace.CurrentCamera
    local bestModel = nil
    local bestDist = settings.FOV
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return nil end

    local modelsChecked = 0
    local modelsSkippedTeam = 0
    local modelsSkippedOffScreen = 0

    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if not teamFolder:IsA("Folder") then continue end

        for _, model in ipairs(teamFolder:GetChildren()) do
            if not model:IsA("Model") then continue end
            modelsChecked = modelsChecked + 1
            
            if settings.TeamCheck and teamMap[model] == true then
                modelsSkippedTeam = modelsSkippedTeam + 1
                continue end
            
            local headPos = getHeadPosition(model)
            if not headPos then continue end

            if settings.VisibilityCheck and not isVisible(headPos, model) then continue end
            
            local screenPos, _ = cam:WorldToScreenPoint(headPos)
            if screenPos.Z < 0 then
                modelsSkippedOffScreen = modelsSkippedOffScreen + 1
                continue end
            
            local dx = screenPos.X - mousePos.X
            local dy = screenPos.Y - mousePos.Y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            if dist < bestDist then
                bestDist = dist
                bestModel = model
            end
        end
    end

    if settings.ShowDebug then
        debugText.Visible = true
        debugText.Text = string.format("Models: %d | Team skip: %d | Off screen: %d | Best: %s",
            modelsChecked, modelsSkippedTeam, modelsSkippedOffScreen,
            bestModel and "Found" or "None")
    end

    return bestModel
end

local function isTargetValid(model)
    if not model or not model.Parent then return false end
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    if not model:IsDescendantOf(playersFolder) then return false end

    if settings.TeamCheck and teamMap[model] == true then return false end

    local headPos = getHeadPosition(model)
    if not headPos then return false end

    if settings.VisibilityCheck and not isVisible(headPos, model) then return false end
    
    local cam = workspace.CurrentCamera
    local screenPos, _ = cam:WorldToScreenPoint(headPos)
    if screenPos.Z < 0 then return false end
    
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local dx = screenPos.X - mousePos.X
    local dy = screenPos.Y - mousePos.Y
    local dist = math.sqrt(dx*dx + dy*dy)
    return dist < settings.FOV * 1.3
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        locked = true
        if not currentTargetModel or not isTargetValid(currentTargetModel) then
            currentTargetModel = findNewTarget(Vector2.new(Mouse.X, Mouse.Y))
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        locked = false
        currentTargetModel = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if not settings.Enabled then
        debugText.Visible = false
        return
    end
    if not locked then
        debugText.Visible = false
        return
    end

    if tick() - teamCheckTime > 2 then
        updateTeamMap()
        teamCheckTime = tick()
    end

    if not isTargetValid(currentTargetModel) then
        currentTargetModel = findNewTarget(Vector2.new(Mouse.X, Mouse.Y))
    end

    if not currentTargetModel then return end

    local targetPos = getHeadPosition(currentTargetModel)
    if not targetPos then
        currentTargetModel = nil
        return
    end

    if settings.Mode == "Camera" then
        local cam = workspace.CurrentCamera
        local lookAt = CFrame.new(cam.CFrame.Position, targetPos)
        if settings.Smoothness then
            cam.CFrame = cam.CFrame:Lerp(lookAt, settings.SmoothAmount)
        else
            cam.CFrame = lookAt
        end
    elseif settings.Mode == "Mouse" then
        if canMoveMouse() then
            local cam = workspace.CurrentCamera
            local screenPos = cam:WorldToScreenPoint(targetPos)
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

print("PF Aimbot loaded")
