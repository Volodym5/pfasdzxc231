-- Phantom Forces Aimbot - Camera CFrame manipulation at Camera priority

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

_G.PF_Aimbot_Settings = _G.PF_Aimbot_Settings or {
    Enabled = false,
    TeamCheck = true,
    VisibilityCheck = false,
    FOV = 100,
    TargetPart = "Head",
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
local teamMap = {}
local playerTeamCache = {}
local modelToName = {}
local teamCheckTime = 0

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Radius = 100
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Filled = false
fovCircle.Transparency = 0.7

local function getPlayerNameFromModel(model)
    for _, desc in ipairs(model:GetDescendants()) do
        if desc.Name == "PlayerTag" and desc:IsA("TextLabel") then
            local text = desc.Text
            if text and #text > 0 then
                return text
            end
        end
    end
    return nil
end

local function cacheTeamForName(tagName)
    if playerTeamCache[tagName] ~= nil then return end
    local playersList = Players:GetPlayers()
    for _, p in ipairs(playersList) do
        if p.Name == tagName or p.DisplayName == tagName then
            local isFriendly = false
            if LocalPlayer.Team and p.Team then
                isFriendly = (p.Team == LocalPlayer.Team)
            elseif LocalPlayer.TeamColor and p.TeamColor then
                isFriendly = (p.TeamColor.Number == LocalPlayer.TeamColor.Number)
            end
            playerTeamCache[tagName] = isFriendly
            return
        end
    end
end

local function applyModelIdentification(model, tagName)
    modelToName[model] = tagName
    cacheTeamForName(tagName)
    if playerTeamCache[tagName] ~= nil then
        teamMap[model] = playerTeamCache[tagName]
    end
end

local function identifyModel(model)
    if not model:IsA("Model") then return end
    if modelToName[model] then return end

    local tagName = getPlayerNameFromModel(model)
    if tagName then
        applyModelIdentification(model, tagName)
        return
    end

    local conn
    conn = model.DescendantAdded:Connect(function(desc)
        if desc.Name == "PlayerTag" and desc:IsA("TextLabel") and desc.Text ~= "" then
            applyModelIdentification(model, desc.Text)
            conn:Disconnect()
        end
    end)
end

local function setupInstantIdentification()
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then
        workspace.ChildAdded:Connect(function(child)
            if child.Name == "Players" then
                setupInstantIdentification()
            end
        end)
        return
    end

    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if teamFolder:IsA("Folder") then
            teamFolder.ChildAdded:Connect(function(model)
                identifyModel(model)
            end)
            for _, model in ipairs(teamFolder:GetChildren()) do
                identifyModel(model)
            end
        end
    end

    playersFolder.ChildAdded:Connect(function(teamFolder)
        if teamFolder:IsA("Folder") then
            teamFolder.ChildAdded:Connect(function(model)
                identifyModel(model)
            end)
        end
    end)
end

setupInstantIdentification()

local function updateTeamMap()
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return end

    local currentModels = {}
    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if teamFolder:IsA("Folder") then
            for _, model in ipairs(teamFolder:GetChildren()) do
                if model:IsA("Model") then
                    currentModels[model] = true
                    if not modelToName[model] then
                        identifyModel(model)
                    end
                end
            end
        end
    end

    for model, _ in pairs(modelToName) do
        if not currentModels[model] then modelToName[model] = nil end
    end
    for model, _ in pairs(teamMap) do
        if not currentModels[model] then teamMap[model] = nil end
    end

    teamCheckTime = tick()
end

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

local function getTorsoPosition(model)
    local parts = {}
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.7 then
            parts[#parts + 1] = part
        end
    end
    if #parts == 0 then return nil end
    
    table.sort(parts, function(a, b) return a.Position.Y > b.Position.Y end)
    local index = math.floor(#parts * 0.45)
    if index < 1 then index = 1 end
    return parts[index].Position
end

local function getTargetPosition(model)
    if settings.TargetPart == "Head" then
        return getHeadPosition(model)
    else
        return getTorsoPosition(model)
    end
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

local function findNewTarget()
    local cam = workspace.CurrentCamera
    local bestModel = nil
    local bestDist = settings.FOV
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return nil end

    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)

    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if not teamFolder:IsA("Folder") then continue end

        for _, model in ipairs(teamFolder:GetChildren()) do
            if not model:IsA("Model") then continue end
            
            if settings.TeamCheck and teamMap[model] == true then continue end
            
            local targetPos = getTargetPosition(model)
            if not targetPos then continue end

            if settings.VisibilityCheck and not isVisible(targetPos, model) then continue end
            
            local screenPos, _ = cam:WorldToViewportPoint(targetPos)
            if screenPos.Z < 0 then continue end
            
            local dx = screenPos.X - center.X
            local dy = screenPos.Y - center.Y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            if dist < bestDist then
                bestDist = dist
                bestModel = model
            end
        end
    end

    return bestModel
end

local function isTargetValid(model)
    if not model or not model.Parent then return false end
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    if not model:IsDescendantOf(playersFolder) then return false end

    if settings.TeamCheck and teamMap[model] == true then return false end

    local targetPos = getTargetPosition(model)
    if not targetPos then return false end

    if settings.VisibilityCheck and not isVisible(targetPos, model) then return false end
    
    local cam = workspace.CurrentCamera
    local screenPos, _ = cam:WorldToViewportPoint(targetPos)
    if screenPos.Z < 0 then return false end
    
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local dx = screenPos.X - center.X
    local dy = screenPos.Y - center.Y
    local dist = math.sqrt(dx*dx + dy*dy)
    return dist < settings.FOV * 1.3
end

local function safeUnlock()
    if locked then
        locked = false
        currentTargetModel = nil
    end
end

LocalPlayer.CharacterAdded:Connect(function() safeUnlock() end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if not LocalPlayer.Character then return end
        locked = true
        currentTargetModel = findNewTarget()
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        safeUnlock()
    end
end)

RunService:BindToRenderStep("PFAimbot", Enum.RenderPriority.Camera.Value, function()
    if not settings.Enabled then return end
    if not locked then return end
    if not LocalPlayer.Character then safeUnlock() return end

    if tick() - teamCheckTime > 3 then
        updateTeamMap()
        teamCheckTime = tick()
    end

    if not isTargetValid(currentTargetModel) then
        currentTargetModel = findNewTarget()
    end

    if not currentTargetModel then return end

    local targetPos = getTargetPosition(currentTargetModel)
    if not targetPos then
        currentTargetModel = nil
        return
    end

    local cam = workspace.CurrentCamera
    local lookAt = CFrame.new(cam.CFrame.Position, targetPos)
    if settings.Smoothness then
        cam.CFrame = cam.CFrame:Lerp(lookAt, settings.SmoothAmount)
    else
        cam.CFrame = lookAt
    end
end)

task.spawn(function()
    while task.wait() do
        if settings.ShowFOV then
            local cam = workspace.CurrentCamera
            fovCircle.Visible = true
            fovCircle.Radius = settings.FOV
            fovCircle.Color = settings.FOVColor
            fovCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        else
            fovCircle.Visible = false
        end
    end
end)

print("PF Aimbot loaded - Camera CFrame mode")
