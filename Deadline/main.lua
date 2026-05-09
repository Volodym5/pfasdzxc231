-- ===== CHAMS WITH 1 SECOND NEW PLAYER DELAY =====
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = workspace
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

debugX = true

local settings = {
    Enabled = true,
    TeamCheck = true,
    VisibilityCheck = true,
    VisibleColor = Color3.fromRGB(255, 50, 50),
    OccludedColor = Color3.fromRGB(255, 150, 50),
    FillTransparency = 0.75,
    OutlineTransparency = 0.5,
    NightVision = false,
}

local highlightCache = {}
local visibilityCache = {}
local connections = {}
local cleaned = false

-- New player cooldown tracking
local newPlayerCooldown = {}

-- Team detection tables
local FriendlyScores = {}
local ConfirmedEnemies = {}
local EnemyConfirmations = {}
local firstSeenOnScreen = {}

local ConfirmedEnemies = {}  -- true = enemy (show), false = friendly (hide)

local localTeam = nil -- "attacker" or "defender"
local localHeadName = nil -- the inner head part name of our character

-- Defenders: model.head -> Model "head" -> contains a Model "item" (nested cosmetics)
-- Attackers: model.head -> Model "head" -> only flat MeshParts, no nested Model "item"
-- Cache results so we only traverse the tree once per model
local teamTypeCache = {}

local function isDefenderHead(headModel)
    -- FindFirstChildWhichIsA only searches direct children, cheap O(n) over head's kids
    return headModel:FindFirstChildWhichIsA("Model") ~= nil
end

local function getPlayerTeamType(model)
    if teamTypeCache[model] ~= nil then return teamTypeCache[model] end
    local headMesh = model:FindFirstChild("head")
    if not headMesh then return nil end -- head not loaded yet, don't cache nil
    local headModel = headMesh:FindFirstChild("head")
    if not headModel then return nil end -- same
    local t = isDefenderHead(headModel) and "defender" or "attacker"
    teamTypeCache[model] = t
    return t
end

local function detectLocalTeam()
    local chars = Workspace:FindFirstChild("characters")
    if not chars then return end
    local mine = chars:FindFirstChild("StarterCharacter")
    if not mine then return end
    localTeam = getPlayerTeamType(mine)
    if debugX then print("[TEAM] Detected as:", tostring(localTeam)) end
end

local function isFriendlyModel(model)
    if not settings.TeamCheck or not localTeam then return false end
    return getPlayerTeamType(model) == localTeam
end

local function ScanFriendlyIndicators()
    if not localTeam then detectLocalTeam() end
    for model in pairs(highlightCache) do
        ConfirmedEnemies[model] = not isFriendlyModel(model)
    end
end

local function refreshHighlight(model)
    local h = highlightCache[model]
    if not h or not model.Parent then return end
    if newPlayerCooldown[model] then h.Enabled = false; return end
    h.Enabled = not isFriendlyModel(model)
end

-- ===== TEAM CHECK =====
local function isTeammate(model)
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if player.Team ~= LocalPlayer.Team then continue end
        local char = player.Character
        if char and char == model then return true end
    end
    return false
end

-- ===== NIGHT VISION =====
-- Names of effects to remove from Lighting
local NV_TARGETS = {
    "NightVision, dof",
    "NightVision, color_correction",
    "NightVision, blur",
    "NightVision, bloom",
    "IngameView, universal_desaturation",
}

-- Store removed effects so we can restore them
local function removeNVEffects()
    for _, name in ipairs(NV_TARGETS) do
        local effect = Lighting:FindFirstChild(name)
        if effect then
            effect:Destroy()
            if debugX then print("[NV] Destroyed: " .. name) end
        else
            if debugX then print("[NV] Not found: " .. name) end
        end
    end
end

local function setNightVision(enabled)
    settings.NightVision = enabled
    if enabled then
        removeNVEffects()
    end
end

local function fullCleanup()
    if cleaned then return end
    cleaned = true


    for model, highlight in pairs(highlightCache) do
        pcall(function() highlight:Destroy() end)
    end
    highlightCache = {}
    visibilityCache = {}
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
end

local function toggleChams(state)
    settings.Enabled = state
    if not state then
        for _, highlight in pairs(highlightCache) do
            pcall(function() highlight.Enabled = false end)
        end
    else
        for model, highlight in pairs(highlightCache) do
            if model and model.Parent then
                local isFriendly = settings.TeamCheck and (ConfirmedEnemies[model] == false)
                if not isFriendly then
                    highlight.Enabled = true
                end
            end
        end
    end
    if debugX then print("[DEBUG] Chams toggled: " .. tostring(state)) end
end

-- ===== VISIBILITY =====
local function checkVisibility(model)
    local head = model:FindFirstChild("head")
    if not head then return nil end
    local camPos = Camera.CFrame.Position
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {model}
    rayParams.IgnoreWater = true
    local dir = head.Position - camPos
    local dist = dir.Magnitude
    if dist >= 0.1 then
        return Workspace:Raycast(camPos, dir.Unit * dist, rayParams) == nil
    end
    return true
end

local function createCham(model)
    if cleaned or highlightCache[model] or not settings.Enabled then return end
    visibilityCache[model] = true
    local h = Instance.new("Highlight")
    h.Name = "\0"
    h.Adornee = model
    h.Parent = gethui()
    h.FillColor = settings.VisibleColor
    h.OutlineColor = settings.VisibleColor
    h.FillTransparency = settings.FillTransparency
    h.OutlineTransparency = settings.OutlineTransparency
    h.Enabled = false
    highlightCache[model] = h

    newPlayerCooldown[model] = tick()

    task.delay(1, function()
        if cleaned or not settings.Enabled then return end
        if highlightCache[model] and model.Parent then
            -- Force fresh team detection for this model (handles respawns)
            teamTypeCache[model] = nil
            ConfirmedEnemies[model] = not isFriendlyModel(model)

            local isFriendly = settings.TeamCheck and ConfirmedEnemies[model] == false
            highlightCache[model].Enabled = not isFriendly
            newPlayerCooldown[model] = nil
        end
    end)
end

-- ===== MAIN LOOP =====
local visQueue = {}
local visIndex = 1
local lastTeamScan = 0

-- Visibility: stagger one model per Heartbeat tick
local visQueue = {}
local visIndex = 1

local heartbeatConnection = RunService.Heartbeat:Connect(function()
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
                h.FillColor = color
                h.OutlineColor = color
            end
        end
        visIndex = visIndex + 1
    else
        table.remove(visQueue, visIndex)
    end
end)
table.insert(connections, heartbeatConnection)

-- Periodic team + state refresh (every 2s)
local lastPeriodicCheck = 0
local periodicConnection = RunService.Heartbeat:Connect(function()
    if cleaned then return end
    local now = tick()
    if now - lastPeriodicCheck < 2 then return end
    lastPeriodicCheck = now

    ScanFriendlyIndicators()

    -- Reap dead models, refresh state for live ones
    for model, highlight in pairs(highlightCache) do
        if not model.Parent then
            pcall(function() highlight:Destroy() end)
            highlightCache[model] = nil
            visibilityCache[model] = nil
            newPlayerCooldown[model] = nil
        else
            refreshHighlight(model)
        end
    end
end)
table.insert(connections, periodicConnection)

table.insert(connections, renderConnection)

-- ===== CHARACTER DETECTION =====
local Characters = Workspace:FindFirstChild("characters")
if Characters then
    local childAddedConn = Characters.ChildAdded:Connect(function(model)
        if cleaned or not model:IsA("Model") then return end
        teamTypeCache[model] = nil -- always start fresh for new/reset models
        createCham(model)
        visQueue[#visQueue + 1] = model
    end)
    table.insert(connections, childAddedConn)

    for _, model in ipairs(Characters:GetChildren()) do
        if model:IsA("Model") then
            createCham(model)
            visQueue[#visQueue + 1] = model
        end
    end

    local childRemovedConn = Characters.ChildRemoved:Connect(function(model)
        if highlightCache[model] then
            pcall(function() highlightCache[model]:Destroy() end)
            highlightCache[model] = nil
            visibilityCache[model] = nil
            ConfirmedEnemies[model] = nil
            newPlayerCooldown[model] = nil
            teamTypeCache[model] = nil
        end
    end)
    table.insert(connections, childRemovedConn)
end

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.End then fullCleanup() end
end)

detectLocalTeam()
print("Chams loaded - New players have 1 second cooldown")
print("Press END to unload")

-- ===== EXPOSE SHARED STATE FOR UI =====
_G.ChamsState = {
    settings      = settings,
    highlightCache = highlightCache,
    toggleChams   = toggleChams,
    setNightVision = setNightVision,
    fullCleanup   = fullCleanup,
}

-- ===== LOAD UI EXTERNALLY =====
loadstring(game:HttpGet('https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/Deadline/ui.lua'))()
