-- Phantom Forces Aimbot – Weighted head detection + flicker‑free teams + sight compensation

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

-- Team tracking (flicker‑free)
local teamMap = {}
local pendingTeam = {}
local streamingMemory = {}
local streamingTimestamps = {}
local modelToName = {}
local lastScanTime = 0
local SCAN_INTERVAL = 5
local CONFIDENCE_THRESHOLD = 2

-- Round detection
local roundSpawnBurst = 0
local roundActive = true

-- Gun position cache
local cachedBarrel = nil
local cachedBarrelOffset = Vector3.new(0, 0, 0)
local cachedSightOffset = Vector3.new(0, 0, 0)
local cachedSightToBarrel = Vector3.new(0, 0, 0)
local barrelCacheTime = 0

-- FOV circle
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
    local barrel, barrelDist = nil, -math.huge
    local sight, sightY = nil, -math.huge
    for _, child in ipairs(cam:GetChildren()) do
        if child:IsA("Model") then
            for _, part in ipairs(child:GetDescendants()) do
                if part:IsA("MeshPart") and part.Transparency < 0.5 then
                    local relPos = part.Position - cam.CFrame.Position
                    local fwd = relPos:Dot(cam.CFrame.LookVector)
                    if fwd > barrelDist then barrelDist = fwd; barrel = part end
                    if part.Position.Y > sightY then sightY = part.Position.Y; sight = part end
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
    return nil, Vector3.zero, Vector3.zero, Vector3.zero
end

-- ===== TEAM DETECTION =====
local function getPlayerNameFromModel(model)
    for _, desc in ipairs(model:GetDescendants()) do
        if desc.Name == "PlayerTag" and desc:IsA("TextLabel") then
            local text = desc.Text
            if text and #text > 0 then return text end
        end
    end
    return nil
end

local function resolveTeamFromName(playerName)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == playerName or p.DisplayName == playerName then
            if LocalPlayer.Team and p.Team then return p.Team == LocalPlayer.Team end
            if LocalPlayer.TeamColor and p.TeamColor then return p.TeamColor.Number == LocalPlayer.TeamColor.Number end
        end
    end
    return nil
end

local function identifyModel(model)
    if not model:IsA("Model") or modelToName[model] then return end
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
        workspace.ChildAdded:Connect(function(c) if c.Name == "Players" then setupInstantIdentification() end end)
        return
    end
    for _, tf in ipairs(playersFolder:GetChildren()) do
        if tf:IsA("Folder") then
            tf.ChildAdded:Connect(identifyModel)
            for _, m in ipairs(tf:GetChildren()) do identifyModel(m) end
        end
    end
    playersFolder.ChildAdded:Connect(function(tf) if tf:IsA("Folder") then tf.ChildAdded:Connect(identifyModel) end end)
end
setupInstantIdentification()

local function periodicRescan()
    local playerLookup = {}
    for _, p in ipairs(Players:GetPlayers()) do
        playerLookup[p.Name] = p
        if p.DisplayName ~= p.Name then playerLookup[p.DisplayName] = p end
    end
    local currentModels = {}
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return end
    for _, tf in ipairs(playersFolder:GetChildren()) do
        if tf:IsA("Folder") then
            for _, m in ipairs(tf:GetChildren()) do
                if m:IsA("Model") then
                    currentModels[m] = true
                    local knownName = modelToName[m]
                    if not knownName then
                        local tag = getPlayerNameFromModel(m)
                        if tag then modelToName[m] = tag; knownName = tag end
                    end
                    if knownName and playerLookup[knownName] then
                        local newTeam = resolveTeamFromName(knownName)
                        if newTeam == nil then continue end
                        local p = pendingTeam[m]
                        if p and p.team == newTeam then
                            p.confidence += 1
                            if p.confidence >= CONFIDENCE_THRESHOLD then
                                teamMap[m] = newTeam
                                streamingMemory[knownName] = newTeam
                                streamingTimestamps[knownName] = tick()
                            end
                        else
                            pendingTeam[m] = { team = newTeam, confidence = 1 }
                        end
                    end
                end
            end
        end
    end
    for m, _ in pairs(modelToName) do
        if not currentModels[m] then
            local name = modelToName[m]
            if name and teamMap[m] ~= nil then streamingMemory[name] = teamMap[m]; streamingTimestamps[name] = tick() end
            modelToName[m] = nil; teamMap[m] = nil; pendingTeam[m] = nil
        end
    end
    for m, _ in pairs(teamMap) do if not currentModels[m] then teamMap[m] = nil end end
    for m, _ in pairs(pendingTeam) do if not currentModels[m] then pendingTeam[m] = nil end end
    lastScanTime = tick()
end

-- Round detection: flush streaming memory on new round
local function setupRoundDetection()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function()
                roundSpawnBurst += 1
                task.delay(2, function() roundSpawnBurst = math.max(0, roundSpawnBurst - 1) end)
                if roundSpawnBurst >= 3 and not roundActive then
                    roundActive = true
                    streamingMemory = {}
                    streamingTimestamps = {}
                    pendingTeam = {}
                end
            end)
        end
    end
    task.spawn(function()
        while task.wait(1) do
            local playersFolder = workspace:FindFirstChild("Players")
            if playersFolder then
                local allEmpty = true
                for _, f in ipairs(playersFolder:GetChildren()) do
                    if f:IsA("Folder") and #f:GetChildren() > 0 then allEmpty = false; break end
                end
                if allEmpty and roundActive then roundActive = false end
            end
        end
    end)
end
setupRoundDetection()

-- ===== HEAD DETECTION (weighted + shape filter) =====
local function isHeadLike(part)
    local s = part.Size
    local dims = {s.X, s.Y, s.Z}
    table.sort(dims)
    local shortest, longest = dims[1], dims[3]
    local aspectRatio = shortest / longest
    local volume = s.X * s.Y * s.Z
    return aspectRatio > 0.35 and volume > 0.5  -- head is compact and has real volume
end

local function findHeadPosition(model)
    -- Fallback: ESP shared position or tight bounds
    if _G.PF_HeadPositions and _G.PF_HeadPositions[model] then
        return _G.PF_HeadPositions[model]
    end

    local parts = {}
    local minY, maxY = math.huge, -math.huge

    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.7 then
            local top = part.Position.Y + part.Size.Y / 2
            local bot = part.Position.Y - part.Size.Y / 2
            maxY = math.max(maxY, top)
            minY = math.min(minY, bot)
            table.insert(parts, part)
        end
    end

    if #parts == 0 then return nil end
    local height = maxY - minY
    if height <= 0 then return nil end

    -- Weighted centroid (cube bias toward top)
    local sumX, sumZ, sumW = 0, 0, 0
    for _, part in ipairs(parts) do
        local normY = (part.Position.Y - minY) / height
        local weight = normY ^ 3
        sumX += part.Position.X * weight
        sumZ += part.Position.Z * weight
        sumW += weight
    end
    local cx = sumX / sumW
    local cz = sumZ / sumW

    -- Search top 30% for head‑like part
    local searchFloor = maxY - height * 0.30
    local bestPart, bestScore = nil, -math.huge

    for _, part in ipairs(parts) do
        local partTop = part.Position.Y + part.Size.Y / 2
        if partTop >= searchFloor and isHeadLike(part) then
            local s = part.Size
            local volume = s.X * s.Y * s.Z
            local dims = {s.X, s.Y, s.Z}
            table.sort(dims)
            local aspectRatio = dims[1] / dims[3]
            local verticalBias = (part.Position.Y - minY) / height
            local score = aspectRatio * 2 + math.log(volume + 0.01) + verticalBias

            -- Penalize large nearby lower parts (held weapons)
            local hasNearby = false
            for _, other in ipairs(parts) do
                if other ~= part then
                    local dx = math.abs(other.Position.X - part.Position.X)
                    local dz = math.abs(other.Position.Z - part.Position.Z)
                    local dy = part.Position.Y - other.Position.Y
                    local otherVol = other.Size.X * other.Size.Y * other.Size.Z
                    if dx < 2 and dz < 2 and dy > 1.5 and otherVol > 2 then
                        hasNearby = true; break
                    end
                end
            end
            if hasNearby then score = score - 2 end

            if score > bestScore then
                bestScore = score
                bestPart = part
            end
        end
    end

    if bestPart then
        return Vector3.new(
            bestPart.Position.X,
            bestPart.Position.Y + bestPart.Size.Y * 0.3,
            bestPart.Position.Z
        )
    end

    -- Fallback: weighted centroid at 93% height
    return Vector3.new(cx, maxY - height * 0.07, cz)
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
    return workspace:Raycast(camPos, dir.Unit * dist, rayParams) == nil
end

local function findNewTarget(mousePos)
    local cam = workspace.CurrentCamera
    local bestModel, bestDist = nil, settings.FOV
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return nil end
    for _, tf in ipairs(playersFolder:GetChildren()) do
        if not tf:IsA("Folder") then continue end
        for _, model in ipairs(tf:GetChildren()) do
            if not model:IsA("Model") then continue end
            if settings.TeamCheck and teamMap[model] == true then continue end
            local headPos = findHeadPosition(model)
            if not headPos then continue end
            if settings.VisibilityCheck and not isVisible(headPos, model) then continue end
            local screenPos, _ = cam:WorldToViewportPoint(headPos)
            if screenPos.Z < 0 then continue end
            local dx, dy = screenPos.X - mousePos.X, screenPos.Y - mousePos.Y
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist < bestDist then bestDist = dist; bestModel = model end
        end
    end
    return bestModel
end

local function isTargetValid(model)
    if not model or not model.Parent then return false end
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder or not model:IsDescendantOf(playersFolder) then return false end
    if settings.TeamCheck and teamMap[model] == true then return false end
    local headPos = findHeadPosition(model)
    if not headPos then return false end
    if settings.VisibilityCheck and not isVisible(headPos, model) then return false end
    local cam = workspace.CurrentCamera
    local screenPos, _ = cam:WorldToViewportPoint(headPos)
    if screenPos.Z < 0 then return false end
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local dx, dy = screenPos.X - mousePos.X, screenPos.Y - mousePos.Y
    return math.sqrt(dx*dx + dy*dy) < settings.FOV * 1.3
end

-- ===== INPUT =====
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
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
    if not settings.Enabled or not locked then return end

    if tick() - lastScanTime > SCAN_INTERVAL then periodicRescan() end
    if not isTargetValid(currentTargetModel) then currentTargetModel = findNewTarget(Vector2.new(Mouse.X, Mouse.Y)) end
    if not currentTargetModel then return end

    local targetPos = findHeadPosition(currentTargetModel)
    if not targetPos then currentTargetModel = nil; return end

    local cam = workspace.CurrentCamera
    local barrel, _, sightOffset, sightToBarrel = findBarrelAndSight()
    local aimPoint = targetPos
    if barrel then
        aimPoint = targetPos - sightOffset - sightToBarrel * 0.5
    end
    aimPoint += Vector3.new(settings.HorizontalOffset, settings.VerticalOffset, 0)

    local screenPos = cam:WorldToViewportPoint(aimPoint)
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local dx = (screenPos.X - center.X) * (settings.Smoothness and settings.SmoothAmount or 1)
    local dy = (screenPos.Y - center.Y) * (settings.Smoothness and settings.SmoothAmount or 1)
    if math.abs(dx) > 0.5 or math.abs(dy) > 0.5 then mousemoverel(dx, dy) end
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
        else fovCircle.Visible = false end
    end
end)

print("PF Aimbot loaded – weighted head + flicker‑free teams")
