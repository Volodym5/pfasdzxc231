-- Phantom Forces Aimbot - Flicker-free team cache + sight compensation

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

-- Display (confirmed) state
local teamMap = {}
local nameMap = {}
local pendingTeam = {}
local CONFIDENCE_THRESHOLD = 2
local streamingMemory = {}
local streamingTimestamps = {}
local modelToName = {}
local lastScanTime = 0
local SCAN_INTERVAL = 5

local cachedBarrel = nil
local cachedBarrelOffset = Vector3.new(0, 0, 0)
local cachedSightOffset = Vector3.new(0, 0, 0)
local cachedSightToBarrel = Vector3.new(0, 0, 0)
local barrelCacheTime = 0

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Radius = 100
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Filled = false
fovCircle.Transparency = 0.7

-- ===== GUN POSITION FINDER =====
local function findBarrelAndSight()
    if tick() - barrelCacheTime < 0.5 and cachedBarrel then
        return cachedBarrel, cachedBarrelOffset, cachedSightOffset, cachedSightToBarrel
    end
    
    local cam = workspace.CurrentCamera
    local barrel = nil
    local barrelDist = -math.huge
    local sight = nil
    local sightY = -math.huge
    
    for _, child in ipairs(cam:GetChildren()) do
        if child:IsA("Model") then
            for _, part in ipairs(child:GetDescendants()) do
                if part:IsA("MeshPart") and part.Transparency < 0.5 then
                    local relPos = part.Position - cam.CFrame.Position
                    local forwardDist = relPos:Dot(cam.CFrame.LookVector)
                    
                    if forwardDist > barrelDist then
                        barrelDist = forwardDist
                        barrel = part
                    end
                    
                    if part.Position.Y > sightY then
                        sightY = part.Position.Y
                        sight = part
                    end
                end
            end
        end
    end
    
    if barrel and sight then
        cachedBarrel = barrel
        cachedBarrelOffset = barrel.Position - cam.CFrame.Position
        cachedSightOffset = sight.Position - cam.CFrame.Position
        cachedSightToBarrel = cachedBarrelOffset - cachedSightOffset
        barrelCacheTime = tick()
        return barrel, cachedBarrelOffset, cachedSightOffset, cachedSightToBarrel
    end
    return nil, Vector3.new(0,0,0), Vector3.new(0,0,0), Vector3.new(0,0,0)
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

local function resolveTeamFromName(playerName)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == playerName or p.DisplayName == playerName then
            local isFriendly = false
            if LocalPlayer.Team and p.Team then
                isFriendly = (p.Team == LocalPlayer.Team)
            elseif LocalPlayer.TeamColor and p.TeamColor then
                isFriendly = (p.TeamColor.Number == LocalPlayer.TeamColor.Number)
            end
            return isFriendly
        end
    end
    return nil
end

local function identifyModel(model)
    if not model:IsA("Model") then return end
    if modelToName[model] then return end

    local tagName = getPlayerNameFromModel(model)
    if not tagName then return end

    modelToName[model] = tagName

    if streamingMemory[tagName] ~= nil then
        teamMap[model] = streamingMemory[tagName]
        pendingTeam[model] = { team = streamingMemory[tagName], confidence = CONFIDENCE_THRESHOLD }
        return
    end

    local isFriendly = resolveTeamFromName(tagName)
    if isFriendly ~= nil then
        teamMap[model] = isFriendly
        pendingTeam[model] = { team = isFriendly, confidence = 1 }
        streamingMemory[tagName] = isFriendly
        streamingTimestamps[tagName] = tick()
    end
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

local function periodicRescan()
    local playerLookup = {}
    for _, p in ipairs(Players:GetPlayers()) do
        playerLookup[p.Name] = p
        if p.DisplayName ~= p.Name then
            playerLookup[p.DisplayName] = p
        end
    end

    local currentModels = {}
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return end

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
                        local newTeam = resolveTeamFromName(knownName)
                        if newTeam == nil then continue end

                        local p = pendingTeam[model]
                        if p and p.team == newTeam then
                            p.confidence = p.confidence + 1
                            if p.confidence >= CONFIDENCE_THRESHOLD then
                                teamMap[model] = newTeam
                                streamingMemory[knownName] = newTeam
                                streamingTimestamps[knownName] = tick()
                            end
                        else
                            pendingTeam[model] = { team = newTeam, confidence = 1 }
                        end
                    end
                end
            end
        end
    end

    for model, _ in pairs(modelToName) do
        if not currentModels[model] then
            local name = modelToName[model]
            if name and teamMap[model] ~= nil then
                streamingMemory[name] = teamMap[model]
                streamingTimestamps[name] = tick()
            end
            modelToName[model] = nil
            teamMap[model] = nil
            pendingTeam[model] = nil
        end
    end
    for model, _ in pairs(teamMap) do
        if not currentModels[model] then teamMap[model] = nil end
    end
    for model, _ in pairs(pendingTeam) do
        if not currentModels[model] then pendingTeam[model] = nil end
    end

    lastScanTime = tick()
end

-- ===== HEAD DETECTION =====
local function getHeadPosition(model)
    if _G.PF_HeadPositions and _G.PF_HeadPositions[model] then
        return _G.PF_HeadPositions[model]
    end
    
    local cf, size = model:GetBoundingBox()
    if not cf or size.Magnitude < 1 then return nil end
    local bottomY = cf.Position.Y - size.Y / 2
    return Vector3.new(cf.Position.X, bottomY + size.Y * 0.85, cf.Position.Z)
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

    if tick() - lastScanTime > SCAN_INTERVAL then
        periodicRescan()
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
    
    local barrel, barrelOffset, sightOffset, sightToBarrel = findBarrelAndSight()
    local aimPoint = targetPos
    
    if barrel then
        aimPoint = targetPos - sightOffset
        aimPoint = aimPoint - sightToBarrel * 0.5
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

print("PF Aimbot loaded - flicker-free teams")
