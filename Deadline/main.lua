-- ===== UI.LUA — backend systems =====
local Workspace  = workspace
local Camera     = Workspace.CurrentCamera
local Lighting   = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")

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
    AimbotFOV           = 150,
    AimbotSmoothness    = 0.5,
    AimbotKey           = Enum.UserInputType.MouseButton2,
    AimbotHoldKey       = true,
    AimbotShowFOV       = true,
    AimbotFOVColor      = Color3.fromRGB(255, 255, 255),
    AimbotFOVTransparency = 0.5,
}

local highlightCache   = {}
local connections      = {}
local cleaned          = false
local teamTypeCache    = {}
local ConfirmedEnemies = {}

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
    local MAX_ITER = 10 -- prevent infinite loops on edge cases

    for _ = 1, MAX_ITER do
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = excluded
        params.IgnoreWater = true

        local origin = Camera.CFrame.Position
        local dir    = target - origin
        local result = Workspace:Raycast(origin, dir, params)

        if result == nil then
            return true -- nothing blocking, visible
        elseif result.Instance.Transparency ~= 0 then
            table.insert(excluded, result.Instance) -- skip transparent, try again
        else
            return false -- solid hit, occluded
        end
    end

    return false
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

-- NV poll runs inside the periodic heartbeat — no ChildAdded callback needed
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
