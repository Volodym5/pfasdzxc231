-- ===== UI.LUA — backend systems =====
local Workspace  = workspace
local Camera     = Workspace.CurrentCamera
local Lighting   = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Players    = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local settings = {
    Enabled             = true,
    TeamCheck           = true,
    VisibilityCheck     = true,
    VisibleColor        = Color3.fromRGB(255, 50,  50),
    OccludedColor       = Color3.fromRGB(255, 150, 50),
    FillTransparency    = 0.75,
    OutlineTransparency = 0.5,
    NightVision         = false,
    -- Silent Aim settings
    SilentAimEnabled    = false,
    SilentAimFOV        = 180,
    SilentAimTargetPart = "Head",
    SilentAimVisCheck   = false,
    SilentAimPrediction = true,
    SilentAimShowFOV    = true,
    SilentAimFOVColor   = Color3.fromRGB(255, 255, 255),
    SilentAimFOVTransparency = 0.5,
    SilentAimDebug      = false,
}

local highlightCache   = {}
local connections      = {}
local cleaned          = false
local teamTypeCache    = {}
local ConfirmedEnemies = {}

-- Silent aim variables
local firingRemote     = nil
local firingHooked     = false
local predictionData   = {}
local NEAR_THRESHOLD   = 20
local fovCircle        = nil
local debugLines       = {}
local _lastDebugPrint  = 0

-- ===== HIGHLIGHT CREATION =====
local function createCham(model)
    if cleaned or highlightCache[model] then return end
    local h = Instance.new("Highlight")
    h.Name                = "\0"
    h.Adornee             = model
    h.Parent              = gethui()
    h.FillColor           = settings.VisibleColor
    h.OutlineColor        = settings.VisibleColor
    h.FillTransparency    = settings.FillTransparency
    h.OutlineTransparency = settings.OutlineTransparency
    h.Enabled             = false
    highlightCache[model] = h
end

-- ===== TEAM DETECTION =====
local localFingerprint = nil

local function getPlayerTeamType(model)
    if teamTypeCache[model] ~= nil then return teamTypeCache[model] end
    local headMesh = model:FindFirstChild("head")
    if not headMesh then return nil end
    local headModel = headMesh:FindFirstChild("head")
    if not headModel then return nil end
    local t = headModel:FindFirstChildWhichIsA("Model") ~= nil
    teamTypeCache[model] = t
    return t
end

local function detectLocalTeam()
    local chars = Workspace:FindFirstChild("characters")
    if not chars then return end
    local mine = chars:FindFirstChild("StarterCharacter")
    if not mine then return end
    teamTypeCache[mine] = nil
    local detected = getPlayerTeamType(mine)
    if detected ~= nil and detected ~= localFingerprint then
        localFingerprint = detected
    end
end

local function isFriendlyModel(model)
    if not settings.TeamCheck or localFingerprint == nil then return false end
    return getPlayerTeamType(model) == localFingerprint
end

local function scanFriendly()
    for model in pairs(highlightCache) do
        ConfirmedEnemies[model] = not isFriendlyModel(model)
    end
end

local function refreshHighlight(model)
    local h = highlightCache[model]
    if not h or not model.Parent then return end
    h.Enabled = settings.Enabled and not isFriendlyModel(model)
end

-- ===== VISIBILITY CHECK =====
local function checkVisibility(model)
    local head = model:FindFirstChild("head")
    if not head then return nil end

    local excluded = {model}
    local target   = head.Position
    local MAX_ITER = 10

    for _ = 1, MAX_ITER do
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = excluded
        params.IgnoreWater = true

        local origin = Camera.CFrame.Position
        local dir    = target - origin
        local result = Workspace:Raycast(origin, dir, params)

        if result == nil then
            return true
        elseif result.Instance.Transparency ~= 0 then
            table.insert(excluded, result.Instance)
        else
            return false
        end
    end

    return false
end

-- ===== PREDICTION =====
local function getPredictedPosition(model, part)
    local data = predictionData[model]
    local root = model:FindFirstChild("humanoid_root_part")
    local currentPos = root and root.Position or part.Position

    if not data then
        predictionData[model] = {
            lastPos     = currentPos,
            velocity    = Vector3.zero,
            lastTime    = tick()
        }
        return currentPos
    end

    local now       = tick()
    local timeDelta = math.clamp(now - data.lastTime, 1e-6, 0.1)

    local rawVelocity = (currentPos - data.lastPos) / timeDelta
    local velAlpha    = math.clamp(timeDelta / 0.05, 0, 1)
    data.velocity     = data.velocity:Lerp(rawVelocity, velAlpha)

    local networkLag = 0.1
    local totalLag   = networkLag + 0.025

    local distance     = (currentPos - Camera.CFrame.Position).Magnitude
    local distanceDamp = math.clamp(distance / NEAR_THRESHOLD, 0.5, 1.0)

    local aimPos = currentPos + data.velocity * totalLag * distanceDamp

    data.lastPos  = currentPos
    data.lastTime = now

    return aimPos
end

-- ===== FOV CIRCLE & DEBUG =====
local function updateFOVCircle()
    if not fovCircle then
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 1.5
        fovCircle.Filled = false
        fovCircle.NumSides = 100
    end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Visible = settings.SilentAimShowFOV and settings.SilentAimEnabled
    fovCircle.Radius = settings.SilentAimFOV
    fovCircle.Color = settings.SilentAimFOVColor
    fovCircle.Transparency = settings.SilentAimFOVTransparency
    fovCircle.Position = center
end

local function clearDebugLines()
    for _, line in ipairs(debugLines) do
        if line then line:Remove() end
    end
    debugLines = {}
end

local function drawDebugLine(from, to, color)
    local line = Drawing.new("Line")
    line.From = from
    line.To = to
    line.Color = color or Color3.fromRGB(255, 0, 0)
    line.Thickness = 1
    line.Transparency = 0.5
    line.Visible = true
    table.insert(debugLines, line)
end

local function drawDebugCircle(position, radius, color)
    local circle = Drawing.new("Circle")
    circle.Position = position
    circle.Radius = radius or 5
    circle.Color = color or Color3.fromRGB(255, 0, 0)
    circle.Thickness = 1
    circle.Filled = true
    circle.Transparency = 0.3
    circle.NumSides = 16
    circle.Visible = true
    table.insert(debugLines, circle)
end

-- ===== TARGET SELECTION FOR SILENT AIM =====
local function getAimPart(model)
    if settings.SilentAimTargetPart == "Head" then
        return model:FindFirstChild("head")
    elseif settings.SilentAimTargetPart == "Torso" then
        return model:FindFirstChild("torso")
    else
        return model:FindFirstChild("humanoid_root_part")
    end
end

local function getBestTarget()
    local camPos = Camera.CFrame.Position
    local camDir = Camera.CFrame.LookVector
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local bestTarget = nil
    local bestAngle  = math.rad(settings.SilentAimFOV)
    local bestModel  = nil
    local targetsInFOV = 0

    clearDebugLines()

    for model in pairs(highlightCache) do
        if not model.Parent then continue end
        if not ConfirmedEnemies[model] then continue end

        if settings.SilentAimVisCheck then
            local visible = checkVisibility(model)
            if not visible then continue end
        end

        local part = getAimPart(model)
        if not part then continue end

        local aimPos
        if settings.SilentAimPrediction then
            aimPos = getPredictedPosition(model, part)
        else
            aimPos = part.Position
        end

        local dirToTarget = (aimPos - camPos).Unit
        local angle = math.acos(math.clamp(camDir:Dot(dirToTarget), -1, 1))

        if angle < math.rad(settings.SilentAimFOV) then
            targetsInFOV = targetsInFOV + 1
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(aimPos)
            if onScreen then
                local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
                
                if settings.SilentAimDebug then
                    drawDebugLine(center, screenPoint, Color3.fromRGB(100, 100, 100))
                    drawDebugCircle(screenPoint, 5, Color3.fromRGB(100, 100, 100))
                end
            end

            if angle < bestAngle then
                bestAngle = angle
                bestTarget = aimPos
                bestModel = model
            end
        end
    end

    if settings.SilentAimDebug and bestTarget then
        local screenPos, onScreen = Camera:WorldToViewportPoint(bestTarget)
        if onScreen then
            local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
            drawDebugLine(center, screenPoint, Color3.fromRGB(255, 0, 0))
            drawDebugCircle(screenPoint, 8, Color3.fromRGB(255, 0, 0))
        end
    end

    if settings.SilentAimDebug then
        local now = tick()
        if now - _lastDebugPrint > 1 then
            _lastDebugPrint = now
            if targetsInFOV > 0 then
                print(string.format("[SilentAim] Targets in FOV: %d | Best: %s (%.1f deg)", 
                    targetsInFOV, 
                    bestModel and bestModel.Name or "none",
                    math.deg(bestAngle)))
            else
                print("[SilentAim] No targets in FOV")
            end
        end
    end

    return bestTarget
end

-- ===== SILENT AIM HOOK SETUP =====
local function hookFiringRemote(remote)
    if firingHooked then return end
    firingHooked = true
    firingRemote = remote
    print("[SilentAim] Firing remote hooked: " .. tostring(remote) .. " | " .. remote:GetFullName())

    local oldFireServer
    oldFireServer = hookfunction(remote.FireServer, function(self, ...)
        if not settings.SilentAimEnabled then
            return oldFireServer(self, ...)
        end

        local args = {...}
        if #args >= 2 and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
            local targetPos = getBestTarget()
            if targetPos then
                local newDir = (targetPos - Camera.CFrame.Position).Unit
                local newArgs = {args[1], newDir}
                for i = 3, #args do
                    newArgs[i] = args[i]
                end
                return oldFireServer(self, unpack(newArgs, 1, #newArgs))
            end
        end

        return oldFireServer(self, ...)
    end)
end

-- Hook __namecall by unlocking the metatable first
local function scanForFiringRemote()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)  -- bypass the lock
    
    local originalNamecall = mt.__namecall
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        if method == "FireServer" and not firingHooked then
            local args = {...}
            if #args >= 2 and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                hookFiringRemote(self)
            end
        end
        
        return originalNamecall(self, ...)
    end)
    
    setreadonly(mt, true)  -- re-lock
    
    table.insert(connections, function()
        pcall(function()
            setreadonly(mt, false)
            mt.__namecall = originalNamecall
            setreadonly(mt, true)
        end)
    end)
end

scanForFiringRemote()

-- ===== DEBUG RENDER LOOP =====
table.insert(connections, RunService.RenderStepped:Connect(function()
    if cleaned then return end
    if not settings.SilentAimEnabled or not settings.SilentAimDebug then
        clearDebugLines()
        return
    end
    updateFOVCircle()
    getBestTarget()
end))

-- ===== TOGGLE / CLEANUP =====
local function toggleChams(enabled)
    settings.Enabled = enabled
    for model, h in pairs(highlightCache) do
        if not enabled then
            h.Enabled = false
        elseif model.Parent and not isFriendlyModel(model) then
            h.Enabled = true
        end
    end
end

local function fullCleanup()
    if cleaned then return end
    cleaned = true
    settings.SilentAimEnabled = false
    if fovCircle then fovCircle:Remove(); fovCircle = nil end
    clearDebugLines()
    for _, h in pairs(highlightCache) do pcall(function() h:Destroy() end) end
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
end

-- ===== NIGHT VISION =====
local NV_TARGETS = {
    ["NightVision, dof"]                   = true,
    ["NightVision, color_correction"]      = true,
    ["NightVision, blur"]                  = true,
    ["NightVision, bloom"]                 = true,
    ["IngameView, universal_desaturation"] = true,
}
local nvActive = false

local function stopNV()
    nvActive = false
end

local function startNV()
    nvActive = true
end

local lastNVPoll = 0
table.insert(connections, RunService.Heartbeat:Connect(function()
    if cleaned or not nvActive then return end
    local now = tick()
    if now - lastNVPoll < 0.2 then return end
    lastNVPoll = now
    for name in pairs(NV_TARGETS) do
        local e = Lighting:FindFirstChild(name)
        if e then pcall(function() e:Destroy() end) end
    end
end))

-- ===== CHARACTER WATCHING =====
local visQueue = {}
local Characters = Workspace:FindFirstChild("characters")
if Characters then
    table.insert(connections, Characters.ChildAdded:Connect(function(model)
        if not model:IsA("Model") then return end
        createCham(model)
        visQueue[#visQueue + 1] = model
        task.delay(1, function()
            if cleaned then return end
            teamTypeCache[model]    = nil
            ConfirmedEnemies[model] = not isFriendlyModel(model)
            local h = highlightCache[model]
            if h and model.Parent then
                h.Enabled = settings.Enabled and not isFriendlyModel(model)
            end
        end)
    end))

    for _, model in ipairs(Characters:GetChildren()) do
        if model:IsA("Model") then
            createCham(model)
            visQueue[#visQueue + 1] = model
        end
    end

    table.insert(connections, Characters.ChildRemoved:Connect(function(model)
        if highlightCache[model] then
            pcall(function() highlightCache[model]:Destroy() end)
            highlightCache[model]   = nil
            ConfirmedEnemies[model] = nil
            teamTypeCache[model]    = nil
            predictionData[model]   = nil
        end
    end))
end

-- ===== VISIBILITY LOOP =====
local visIndex = 1
table.insert(connections, RunService.Heartbeat:Connect(function()
    if cleaned or not settings.Enabled or not settings.VisibilityCheck then return end
    if #visQueue == 0 then return end
    if visIndex > #visQueue then visIndex = 1 end
    local model = visQueue[visIndex]
    if model and model.Parent then
        local h = highlightCache[model]
        if h and h.Enabled then
            local visible = checkVisibility(model)
            if visible ~= nil then
                local color = visible and settings.VisibleColor or settings.OccludedColor
                h.FillColor    = color
                h.OutlineColor = color
            end
        end
        visIndex = visIndex + 1
    else
        table.remove(visQueue, visIndex)
    end
end))

-- ===== PERIODIC CHECKS =====
local lastStateCheck  = 0
local lastTeamRecheck = 0
local localTeam = nil
table.insert(connections, RunService.Heartbeat:Connect(function()
    if cleaned then return end
    local now = tick()

    if settings.SilentAimEnabled and not settings.SilentAimDebug then
        updateFOVCircle()
    elseif not settings.SilentAimEnabled then
        if fovCircle then fovCircle.Visible = false end
    end

    if now - lastStateCheck >= 2 then
        lastStateCheck = now
        scanFriendly()
        for model, h in pairs(highlightCache) do
            if not model.Parent then
                pcall(function() h:Destroy() end)
                highlightCache[model]   = nil
                ConfirmedEnemies[model] = nil
                teamTypeCache[model]    = nil
                predictionData[model]   = nil
                for i = #visQueue, 1, -1 do
                    if visQueue[i] == model then table.remove(visQueue, i) end
                end
            else
                refreshHighlight(model)
            end
        end
    end

    if now - lastTeamRecheck >= 10 then
        lastTeamRecheck = now
        local prev = localTeam
        localTeam  = nil
        detectLocalTeam()
        if localTeam ~= prev then
            teamTypeCache    = {}
            ConfirmedEnemies = {}
            scanFriendly()
        else
            localTeam = prev
        end
    end
end))

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.End then fullCleanup() end
end)

detectLocalTeam()

-- ===== NO CAMERA SHAKE =====
local shakeHooked = false
local origShakeNew = nil

local function setNoShake(enabled)
    local ok, CameraShakeInstance = pcall(function()
        return game:GetService("ReplicatedStorage").class.dependencies.CameraShake.CameraShakeInstance
    end)
    if not ok then return end
    
    local CameraShakeModule = CameraShakeInstance
    
    if enabled and not shakeHooked then
        local mt = getrawmetatable(CameraShakeModule)
        local oldNew = mt.__index.new
        if oldNew then
            origShakeNew = oldNew
            mt.__index.new = function(self, magnitude, roughness, ...)
                return origShakeNew(self, 0, 0, ...)
            end
            shakeHooked = true
        end
    elseif not enabled and shakeHooked and origShakeNew then
        local mt = getrawmetatable(CameraShakeModule)
        if mt and mt.__index then
            mt.__index.new = origShakeNew
        end
        shakeHooked = false
    end
end

-- ===== NO BLUR =====
local blurConnection = nil

local function setNoBlur(enabled)
    local blurPart = workspace:FindFirstChild("ignore")
        and workspace.ignore:FindFirstChild("builder")
        and workspace.ignore.builder:FindFirstChild("FrameBlur, blur")

    if not blurPart then return end

    if enabled then
        blurPart.Transparency = 1
        blurConnection = blurPart:GetPropertyChangedSignal("Transparency"):Connect(function()
            blurPart.Transparency = 1
        end)
    else
        if blurConnection then blurConnection:Disconnect(); blurConnection = nil end
        blurPart.Transparency = 0
    end
end

-- ===== SCREEN EFFECTS =====
local IngameView = Lighting:FindFirstChild("IngameView")

local function makeEffectKiller(names)
    local nameSet = {}
    for _, n in ipairs(names) do nameSet[n] = true end
    local conn = nil
    return {
        enable = function()
            if not IngameView then return end
            for _, name in ipairs(names) do
                local e = IngameView:FindFirstChild(name)
                if e then e:Destroy() end
            end
            conn = IngameView.ChildAdded:Connect(function(child)
                if nameSet[child.Name] then child:Destroy() end
            end)
        end,
        disable = function()
            if conn then conn:Disconnect(); conn = nil end
        end,
    }
end

local flashKiller = makeEffectKiller(
    {"flash_color_correction", "flash_desaturation", "flash_blur_effect"}
)
local suppressionKiller = makeEffectKiller(
    {"suppression_color_correction", "suppression_blur_effect"}
)
local explosionKiller = makeEffectKiller(
    {"explosion_color_correction", "explosion_blur_effect"}
)
local waterKiller = makeEffectKiller(
    {"water_color_correction", "water_blur", "drown_blur"}
)

-- ===== EXPOSE =====
_G.ChamsState = {
    settings       = settings,
    highlightCache = highlightCache,
    toggleChams    = toggleChams,
    fullCleanup    = fullCleanup,
    startNV        = startNV,
    stopNV         = stopNV,
    setNoShake     = setNoShake,
    setNoBlur      = setNoBlur,
    flashKiller    = flashKiller,
    suppressionKiller = suppressionKiller,
    explosionKiller   = explosionKiller,
    waterKiller    = waterKiller,
}
