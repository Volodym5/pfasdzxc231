-- Phantom Forces Aimbot v7 - Shared screen cache + squared distance + pre-filter

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()
local TeamModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/refs/heads/main/team.lua"))()
local ScreenCache = loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/refs/heads/main/screen_cache.lua"))()

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
    ShowDebug = false
}

local settings = _G.PF_Aimbot_Settings

local locked = false
local currentTargetModel = nil
local currentTargetPlayer = nil
local REPLICATE_RADIUS = 350
local FOV_SQUARED = settings.FOV * settings.FOV

local springPos = Vector3.zero
local springVel = Vector3.zero
local STIFFNESS = 30
local DAMPING = 2 * math.sqrt(STIFFNESS)
local springInitialized = false

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Radius = 100
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Filled = false
fovCircle.Transparency = 0.7

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
    line.Color = color or Color3.fromRGB(255,255,0)
    line.Thickness = 1
    line.Transparency = 0.5
    table.insert(debugLines, line)
end

local function findHead(model)
    local parts = {}
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") and p.Transparency < 0.7 then
            parts[#parts+1] = p
        end
    end
    if #parts == 0 then return nil end
    local minY, maxY = math.huge, -math.huge
    for _, p in ipairs(parts) do
        local y = p.Position.Y
        if y < minY then minY = y end
        if y > maxY then maxY = y end
    end
    local range = maxY - minY
    local threshold = minY + range * 0.65
    local bestPart, bestScore = nil, math.huge
    for _, p in ipairs(parts) do
        if p.Position.Y >= threshold then
            local s = p.Size
            local volume = s.X * s.Y * s.Z
            local maxDim = math.max(s.X, s.Y, s.Z)
            local minDim = math.min(s.X, s.Y, s.Z)
            local aspectPenalty = (maxDim / math.max(minDim, 0.01)) - 1
            local score = volume * (1 + aspectPenalty * 0.5)
            if score < bestScore then
                bestScore = score
                bestPart = p
            end
        end
    end
    return bestPart
end

local function getTorsoPart(model)
    local parts = {}
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.7 then
            parts[#parts+1] = part
        end
    end
    if #parts == 0 then return nil end
    table.sort(parts, function(a,b) return a.Position.Y > b.Position.Y end)
    return parts[math.floor(#parts/2)]
end

local function getTargetPart(model)
    if settings.TargetPart == "Head" then
        return findHead(model)
    else
        return getTorsoPart(model)
    end
end

local function willStreamIn(player)
    if not player or not player.Character then return false end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local dx = root.Position.X - Camera.CFrame.Position.X
    local dy = root.Position.Y - Camera.CFrame.Position.Y
    local dz = root.Position.Z - Camera.CFrame.Position.Z
    return (dx*dx + dy*dy + dz*dz) <= REPLICATE_RADIUS * REPLICATE_RADIUS
end

local function getTargetPosition(player, model)
    if model and model.Parent then
        local part = getTargetPart(model)
        if part then return part.Position, part end
    end
    if player and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            return root.Position + Vector3.new(0, 2, 0), root
        end
    end
    return nil, nil
end

local function isTargetValid()
    if not currentTargetPlayer then return false end
    if not currentTargetPlayer.Parent then return false end
    if currentTargetModel then
        if not currentTargetModel.Parent then return false end
        local playersFolder = workspace:FindFirstChild("Players")
        if not playersFolder then return false end
        if not currentTargetModel:IsDescendantOf(playersFolder) then return false end
        local cached = ScreenCache.Get(currentTargetModel)
        if cached and cached.onScreen then
            local mx, my = Mouse.X, Mouse.Y
            local dx = cached.x - mx
            local dy = cached.y - my
            if (dx*dx + dy*dy) > FOV_SQUARED * 1.69 then return false end
        end
    else
        if not willStreamIn(currentTargetPlayer) then return false end
    end
    return true
end

local function findPlayerByModel(model)
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return nil end
    local center = Vector3.zero
    local count = 0
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            center = center + part.Position
            count = count + 1
        end
    end
    if count == 0 then return nil end
    center = center / count
    local bestPlayer, bestDist = nil, 225
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dx = root.Position.X - center.X
                local dy = root.Position.Y - center.Y
                local dz = root.Position.Z - center.Z
                local dist2 = dx*dx + dy*dy + dz*dz
                if dist2 < bestDist then
                    bestDist = dist2
                    bestPlayer = player
                end
            end
        end
    end
    return bestPlayer
end

local function getEnemyFolder()
    local myFolder = TeamModule.GetMyTeamFolder()
    if not myFolder then return nil end
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return nil end
    for _, f in ipairs(playersFolder:GetChildren()) do
        if f:IsA("Folder") and f ~= myFolder then
            return f
        end
    end
    return nil
end

local function isWithinRange(pos)
    local camPos = Camera.CFrame.Position
    local dx = pos.X - camPos.X
    local dy = pos.Y - camPos.Y
    local dz = pos.Z - camPos.Z
    return (dx*dx + dy*dy + dz*dz) <= REPLICATE_RADIUS * REPLICATE_RADIUS
end

local function tryAcquire()
    if currentTargetPlayer and isTargetValid() then return true end
    FOV_SQUARED = settings.FOV * settings.FOV
    local bestModel = nil
    local bestPlayer = nil
    local bestDist2 = FOV_SQUARED
    local mx, my = Mouse.X, Mouse.Y
    local enemyFolder = settings.TeamCheck and getEnemyFolder() or nil

    local playersFolder = workspace:FindFirstChild("Players")
    if playersFolder then
        for _, teamFolder in ipairs(playersFolder:GetChildren()) do
            if not teamFolder:IsA("Folder") then continue end
            if settings.TeamCheck and enemyFolder and teamFolder ~= enemyFolder then continue end

            for _, model in ipairs(teamFolder:GetChildren()) do
                if not model:IsA("Model") then continue end
                local cached = ScreenCache.Get(model)
                if not cached or not cached.onScreen then continue end
                if not isWithinRange(cached.worldPos) then continue end
                local dx = cached.x - mx
                local dy = cached.y - my
                local dist2 = dx*dx + dy*dy
                if dist2 < bestDist2 then
                    bestDist2 = dist2
                    bestModel = model
                end
            end
        end
    end

    if not bestModel then
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not player.Character then continue end
            if settings.TeamCheck and not TeamModule.IsEnemy(player) then continue end
            if not willStreamIn(player) then continue end
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            local predictedHead = root.Position + Vector3.new(0, 2, 0)
            if not isWithinRange(predictedHead) then continue end
            local screenPos, onScreen = Camera:WorldToViewportPoint(predictedHead)
            if not onScreen then continue end
            local dx = screenPos.X - mx
            local dy = screenPos.Y - my
            local dist2 = dx*dx + dy*dy
            if dist2 < bestDist2 then
                bestDist2 = dist2
                bestPlayer = player
            end
        end
    end

    if bestModel then
        currentTargetModel = bestModel
        currentTargetPlayer = findPlayerByModel(bestModel)
        springInitialized = false
        return true
    elseif bestPlayer then
        currentTargetModel = nil
        currentTargetPlayer = bestPlayer
        springInitialized = false
        return true
    end
    return false
end

local function releaseTarget()
    currentTargetModel = nil
    currentTargetPlayer = nil
    springVel = Vector3.zero
    springInitialized = false
    clearDebugLines()
end

local function springStep(currentPos, targetPos, dt)
    if not springInitialized then
        springPos = currentPos
        springVel = Vector3.zero
        springInitialized = true
    end
    local displacement = springPos - targetPos
    local acceleration = (-STIFFNESS * displacement) - (DAMPING * springVel)
    springVel = springVel + acceleration * math.min(dt, 0.05)
    springPos = springPos + springVel * math.min(dt, 0.05)
    return springPos
end

local function switchSpringTarget(newTarget)
    local dx = newTarget.X - springPos.X
    local dy = newTarget.Y - springPos.Y
    local dz = newTarget.Z - springPos.Z
    local switchDist2 = dx*dx + dy*dy + dz*dz
    if switchDist2 > 2500 or not springInitialized then
        springPos = Camera.CFrame.Position
        springVel = Vector3.zero
        springInitialized = true
        return
    end
    local newDisplacement = springPos - newTarget
    local dispMag = newDisplacement.Magnitude
    if dispMag > 0.001 and springVel.Magnitude > 0.001 then
        local dispDir = newDisplacement / dispMag
        local projectedSpeed = springVel:Dot(dispDir)
        springVel = dispDir * math.max(projectedSpeed, 0)
    end
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        locked = true
        tryAcquire()
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        locked = false
        releaseTarget()
    end
end)

RunService.RenderStepped:Connect(function(dt)
    FOV_SQUARED = settings.FOV * settings.FOV
    if not settings.Enabled then
        clearDebugLines()
        return
    end
    if not locked then
        releaseTarget()
        return
    end
    if not isTargetValid() then
        releaseTarget()
        tryAcquire()
    end
    if not currentTargetPlayer then
        tryAcquire()
    end
    if not currentTargetPlayer then return end

    local targetPos, targetPart = getTargetPosition(currentTargetPlayer, currentTargetModel)
    if not targetPos then
        releaseTarget()
        return
    end

    if not currentTargetModel and currentTargetPlayer then
        local enemyFolder = getEnemyFolder()
        if enemyFolder then
            for _, model in ipairs(enemyFolder:GetChildren()) do
                if model:IsA("Model") then
                    if findPlayerByModel(model) == currentTargetPlayer then
                        currentTargetModel = model
                        switchSpringTarget(targetPos)
                        break
                    end
                end
            end
        end
    end

    if settings.Prediction and targetPart and targetPart.Velocity then
        targetPos = targetPos + targetPart.Velocity * settings.PredAmount / 100
    end

    if settings.ShowDebug then
        clearDebugLines()
        local guiInset = game:GetService("GuiService"):GetGuiInset()
        local mousePos = Vector2.new(Mouse.X, Mouse.Y + guiInset.Y)
        local sp = Camera:WorldToViewportPoint(targetPos)
        addDebugLine(mousePos, Vector2.new(sp.X, sp.Y), Color3.fromRGB(0,255,0))
    end

    if settings.Mode == "Camera" then
        if settings.Smoothness then
            local goalPos = targetPos + (Camera.CFrame.Position - targetPos).Unit * 5
            local newPos = springStep(Camera.CFrame.Position, goalPos, dt)
            Camera.CFrame = CFrame.new(newPos, targetPos)
        else
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    elseif settings.Mode == "Mouse" then
        local screenPos = Camera:WorldToScreenPoint(targetPos)
        mousemoverel(screenPos.X - Mouse.X, screenPos.Y - Mouse.Y)
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
