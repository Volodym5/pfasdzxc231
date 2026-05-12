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
    -- Aimbot settings
    AimbotEnabled       = false,
    AimbotFOV           = 180,
    AimbotSmoothness    = 0.18,
    AimbotShowFOV       = true,
    AimbotFOVColor      = Color3.fromRGB(255, 255, 255),
    AimbotFOVTransparency = 0.5,
    AimbotTargetPart    = "Head",
    AimbotVisCheck      = false,
    AimbotPrediction    = true,
}

local highlightCache   = {}
local connections      = {}
local cleaned          = false
local teamTypeCache    = {}
local ConfirmedEnemies = {}

-- Aim variables
local aimConnection  = nil
local fovCircle      = nil
local predictionData = {}

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

-- ===== DYNAMIC PREDICTION SYSTEM =====
-- ===== DYNAMIC PREDICTION SYSTEM =====
local NEAR_THRESHOLD = 20

local function getPredictedPosition(model, part, smoothness)
    local data = predictionData[model]
    local root = model:FindFirstChild("humanoid_root_part")
    local currentPos = root and root.Position or part.Position

    if not data then
        predictionData[model] = {
            lastPos     = currentPos,
            velocity    = Vector3.zero,
            smoothedPos = currentPos,
            lastTime    = tick()
        }
        return currentPos
    end

    local now       = tick()
    local timeDelta = math.clamp(now - data.lastTime, 1e-6, 0.1)  -- cap at 100ms

    local rawVelocity = (currentPos - data.lastPos) / timeDelta
    local velAlpha    = math.clamp(timeDelta / 0.05, 0, 1)
    data.velocity     = data.velocity:Lerp(rawVelocity, velAlpha)

    local logTerm    = math.log(1 - smoothness)
    local decayRate  = -logTerm * 60
    local frameAlpha = 1 - math.exp(-decayRate * timeDelta)

    data.smoothedPos = data.smoothedPos:Lerp(currentPos, frameAlpha)

    local filterLag  = 1 / decayRate  -- FPS-independent time constant
    local networkLag = 0.1
    local totalLag   = filterLag + networkLag + 0.025

    local distance     = (currentPos - Camera.CFrame.Position).Magnitude
    local distanceDamp = math.clamp(distance / NEAR_THRESHOLD, 0.5, 1.0)

    local aimPos = data.smoothedPos + data.velocity * totalLag * distanceDamp

    data.lastPos  = currentPos
    data.lastTime = now

    return aimPos
end

-- ===== AIMBOT SYSTEM =====
local function getAimPart(model)
    if settings.AimbotTargetPart == "Head" then
        return model:FindFirstChild("head")
    elseif settings.AimbotTargetPart == "Torso" then
        return model:FindFirstChild("torso")
    else
        return model:FindFirstChild("humanoid_root_part")
    end
end

local function getClosestTarget()
    local mousePos = UIS:GetMouseLocation()
    local bestTarget = nil
    local bestDist = settings.AimbotFOV
    
    for model in pairs(highlightCache) do
        if not model.Parent then continue end
        if not ConfirmedEnemies[model] then continue end
        
        if settings.AimbotVisCheck then
            local visible = checkVisibility(model)
            if not visible then continue end
        end
        
        local part = getAimPart(model)
        if not part then continue end
        
        local aimPos
        if settings.AimbotPrediction then
            aimPos = getPredictedPosition(model, part, settings.AimbotSmoothness)
        else
            aimPos = part.Position
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(aimPos)
        if not onScreen or screenPos.Z <= 0 then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist < bestDist then
            bestDist = dist
            bestTarget = {
                screenPos = Vector2.new(screenPos.X, screenPos.Y),
                aimPos = aimPos
            }
        end
    end
    
    return bestTarget
end

local function updateFOVCircle()
    if fovCircle then
        fovCircle.Visible = settings.AimbotShowFOV and settings.AimbotEnabled
        fovCircle.Radius = settings.AimbotFOV
        fovCircle.Color = settings.AimbotFOVColor
        fovCircle.Transparency = settings.AimbotFOVTransparency
        fovCircle.Position = UIS:GetMouseLocation()
    end
end

local function startAimbot()
    if aimConnection then aimConnection:Disconnect() end
    
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.5
    fovCircle.Filled = false
    fovCircle.NumSides = 100
    updateFOVCircle()
    
    aimConnection = RunService.RenderStepped:Connect(function()
        if cleaned or not settings.AimbotEnabled then
            if fovCircle then fovCircle.Visible = false end
            return
        end
        
        updateFOVCircle()
        
        if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
        
        local target = getClosestTarget()
        if not target then return end
        
        local mousePos = UIS:GetMouseLocation()
        local delta = target.screenPos - mousePos
        
        pcall(function()
            if mousemoverel then
                mousemoverel(delta.X * settings.AimbotSmoothness, delta.Y * settings.AimbotSmoothness)
            end
        end)
    end)
end

local function stopAimbot()
    if aimConnection then aimConnection:Disconnect(); aimConnection = nil end
    if fovCircle then fovCircle:Remove(); fovCircle = nil end
    predictionData = {}
end

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
    stopAimbot()
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
    local ok, CameraShakeInstance = pcall(require,
        game:GetService("ReplicatedStorage").class.dependencies.CameraShake.CameraShakeInstance)
    if not ok then warn("[MISC] CameraShakeInstance not found") return end

    if enabled and not shakeHooked then
        origShakeNew = CameraShakeInstance.new
        CameraShakeInstance.new = function(magnitude, roughness, ...)
            return origShakeNew(0, 0, ...)
        end
        shakeHooked = true
    elseif not enabled and shakeHooked and origShakeNew then
        CameraShakeInstance.new = origShakeNew
        shakeHooked = false
    end
end

-- ===== NO BLUR =====
local blurConnection = nil

local function setNoBlur(enabled)
    local blurPart = workspace:FindFirstChild("ignore")
        and workspace.ignore:FindFirstChild("builder")
        and workspace.ignore.builder:FindFirstChild("FrameBlur, blur")

    if not blurPart then warn("[MISC] Blur part not found") return end

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
    startAimbot    = startAimbot,
    stopAimbot     = stopAimbot,
    updateFOVCircle = updateFOVCircle,
}
