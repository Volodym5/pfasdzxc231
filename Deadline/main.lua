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

local function getHeadFingerprint(model)
    local headMesh  = model:FindFirstChild("head")
    if not headMesh then return nil end
    local headModel = headMesh:FindFirstChild("head")
    if not headModel then return nil end
    -- count direct children by class, order-independent
    local counts = {}
    for _, child in ipairs(headModel:GetChildren()) do
        local c = child.ClassName
        counts[c] = (counts[c] or 0) + 1
    end
    local parts = {}
    for class, count in pairs(counts) do
        parts[#parts + 1] = class .. "=" .. count
    end
    table.sort(parts)
    return table.concat(parts, ",")
end

local function getPlayerTeamType(model)
    if teamTypeCache[model] ~= nil then return teamTypeCache[model] end
    local fp = getHeadFingerprint(model)
    if fp == nil then return nil end
    teamTypeCache[model] = fp
    return fp
end

local function detectLocalTeam()
    local chars = Workspace:FindFirstChild("characters")
    if not chars then return end
    local mine = chars:FindFirstChild("StarterCharacter")
    if not mine then return end
    teamTypeCache[mine] = nil
    local fp = getHeadFingerprint(mine)
    if fp and fp ~= localFingerprint then
        localFingerprint = fp
    end
end

local function isFriendlyModel(model)
    if not settings.TeamCheck or not localFingerprint then return false end
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
    local camPos    = Camera.CFrame.Position
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {model}
    rayParams.IgnoreWater = true
    local dir  = head.Position - camPos
    local dist = dir.Magnitude
    if dist < 0.1 then return true end
    return Workspace:Raycast(camPos, dir.Unit * dist, rayParams) == nil
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
local nvConnection = nil

local function stopNV()
    if nvConnection then nvConnection:Disconnect(); nvConnection = nil end
end

local function startNV()
    for name in pairs(NV_TARGETS) do
        local e = Lighting:FindFirstChild(name)
        if e then e:Destroy() end
    end
    nvConnection = Lighting.ChildAdded:Connect(function(child)
        if NV_TARGETS[child.Name] then child:Destroy() end
    end)
end

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

-- ===== EXPOSE =====
_G.ChamsState = {
    settings       = settings,
    highlightCache = highlightCache,
    toggleChams    = toggleChams,
    fullCleanup    = fullCleanup,
    startNV        = startNV,
    stopNV         = stopNV,
}
