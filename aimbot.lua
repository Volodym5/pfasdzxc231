-- Phantom Forces Aimbot - Instant ID + 10s backup + cached barrel

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
    Mode = "Camera",
    Smoothness = false,
    SmoothAmount = 0.5,
    Prediction = false,
    PredAmount = 10,
    ShowFOV = false,
    FOVColor = Color3.fromRGB(255, 50, 50),
    ShowDebug = false,
    VerticalOffset = 0,
    HorizontalOffset = 0,
}

local settings = _G.PF_Aimbot_Settings
local locked = false
local currentTargetModel = nil
local teamMap = {}
local playerTeamCache = {}
local modelToName = {}
local teamCheckTime = 0

-- Cached barrel (refreshed every 0.5s, not every frame)
local cachedBarrel = nil
local cachedBarrelOffset = Vector3.new(0, 0, 0)
local barrelCacheTime = 0

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Radius = 100
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Filled = false
fovCircle.Transparency = 0.7

-- ===== BARREL FINDER (cached) =====
local function findBarrel()
    if tick() - barrelCacheTime < 0.5 and cachedBarrel then
        return cachedBarrel, cachedBarrelOffset
    end
    
    local cam = workspace.CurrentCamera
    for _, child in ipairs(cam:GetChildren()) do
        if child:IsA("Model") then
            local furthest = nil
            local furthestDist = -math.huge
            for _, part in ipairs(child:GetDescendants()) do
                if part:IsA("MeshPart") and part.Transparency < 0.5 then
                    local relPos = part.Position - cam.CFrame.Position
                    local dist = relPos:Dot(cam.CFrame.LookVector)
                    if dist > furthestDist then
                        furthestDist = dist
                        furthest = part
                    end
                end
            end
            if furthest then
                cachedBarrel = furthest
                cachedBarrelOffset = furthest.Position - cam.CFrame.Position
                barrelCacheTime = tick()
                return furthest, cachedBarrelOffset
            end
        end
    end
    return nil, Vector3.new(0, 0, 0)
end

-- ===== TEAM DETECTION =====
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
            if child.Name == "Players" then setupInstantIdentification() end
        end)
        return
    end
    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if teamFolder:IsA("Folder") then
            teamFolder.ChildAdded:Connect(function(model) identifyModel(model) end)
            for _, model in ipairs(teamFolder:GetChildren()) do identifyModel(model) end
        end
    end
    playersFolder.ChildAdded:Connect(function(teamFolder)
        if teamFolder:IsA("Folder") then
            teamFolder.ChildAdded:Connect(function(model) identifyModel(model) end)
        end
    end)
end
setupInstantIdentification()

-- Backup: full team re-check every 10 seconds
local function updateTeamMap()
    local playersList = Players:GetPlayers()
    if #playersList == 0 then return end
    
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return end

    local playerLookup = {}
    for _, p in ipairs(playersList) do
        playerLookup[p.Name] = p
        if p.DisplayName ~= p.Name then
            playerLookup[p.DisplayName] = p
        end
    end

    local currentModels = {}
    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if teamFolder:IsA("Folder") then
            for _, model in ipairs(teamFolder:GetChildren()) do
                if model:IsA("Model") then
                    currentModels[model] = true
                    
                    local knownName = modelToName[model]
                    if not knownName then
                        local tagName = getPlayerNameFromModel(model)
                        if tagName then
                            modelToName[model] = tagName
                            knownName = tagName
                        end
                    end
                    
                    if knownName and playerLookup[knownName] then
                        local player = playerLookup[knownName]
                        local isFriendly = false
                        if LocalPlayer.Team and player.Team then
                            isFriendly = (player.Team == LocalPlayer.Team)
                        elseif LocalPlayer.TeamColor and player.TeamColor then
                            isFriendly = (player.TeamColor.Number == LocalPlayer.TeamColor.Number)
                        end
                        playerTeamCache[knownName] = isFriendly
                        teamMap[model] = isFriendly
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

-- ===== HEAD DETECTION =====
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

local function findNewTarget(mousePos)
    local cam = workspace.CurrentCamera
    local bestModel = nil
    local bestDist = settings.FOV
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return nil end
    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if not teamFolder:IsA("Folder") then continue end
        for _, model in ipairs(teamFolder:GetChildren()) do
            if not model:IsA("Model") then continue end
            if settings.TeamCheck and teamMap[model] == true then continue end
            local headPos = getHeadPosition(model)
            if not headPos then continue end
            if settings.VisibilityCheck and not isVisible(headPos, model) then continue end
            local screenPos, _ = cam:WorldToViewportPoint(headPos)
            if screenPos.Z < 0 then continue end
            local dx = screenPos.X - mousePos.X
            local dy = screenPos.Y - mousePos.Y
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
    local headPos = getHeadPosition(model)
    if not headPos then return false end
    if settings.VisibilityCheck and not isVisible(headPos, model) then return false end
    local cam = workspace.CurrentCamera
    local screenPos, _ = cam:WorldToViewportPoint(headPos)
    if screenPos.Z < 0 then return false end
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local dx = screenPos.X - mousePos.X
    local dy = screenPos.Y - mousePos.Y
    local dist = math.sqrt(dx*dx + dy*dy)
    return dist < settings.FOV * 1.3
end

-- ===== INPUT =====
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

-- ===== AIM LOGIC =====
RunService.RenderStepped:Connect(function()
    if not settings.Enabled then return end
    if not locked then return end

    -- Backup team check every 10 seconds
    if tick() - teamCheckTime > 10 then
        updateTeamMap()
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

    local cam = workspace.CurrentCamera
    
    -- Use cached barrel (refreshed every 0.5s)
    local barrel, barrelOffset = findBarrel()
    local aimPoint = targetPos
    
    if barrel then
        aimPoint = targetPos - barrelOffset
    end
    
    aimPoint = aimPoint + Vector3.new(settings.HorizontalOffset, settings.VerticalOffset, 0)
    
    local targetScreenPos = cam:WorldToViewportPoint(aimPoint)
    local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    
    local dx = targetScreenPos.X - screenCenter.X
    local dy = targetScreenPos.Y - screenCenter.Y
    
    if settings.Smoothness then
        dx = dx * settings.SmoothAmount
        dy = dy * settings.SmoothAmount
    end
    
    if math.abs(dx) > 0.5 or math.abs(dy) > 0.5 then
        mousemoverel(dx, dy)
    end
end)

-- ===== FOV CIRCLE =====
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
