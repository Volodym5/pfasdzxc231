-- Phantom Forces ESP - Rendering Engine v10
-- Shared screen cache + window focus throttle + staggered raycasts + text shadows

local Workspace = workspace
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UIS = game:GetService("UserInputService")
local TeamModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/refs/heads/main/team.lua"))()
local ScreenCache = loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/refs/heads/main/screen_cache.lua"))()

_G.PF_ESP_Settings = _G.PF_ESP_Settings or {
    Enabled = true,
    Boxes = true,
    Tracers = true,
    Names = true,
    Chams = false,
    VisibilityCheck = false,
    MaxDistance = 800,
    TeamCheck = true,
    TracerFromCrosshair = false,
    EnemyColor = Color3.fromRGB(255, 50, 50),
    OccludedColor = Color3.fromRGB(255, 150, 50),
    BoxThickness = 1,
    TracerThickness = 1,
    NameSize = 13,
    ChamColor = Color3.fromRGB(255, 50, 50),
    ChamFillTransparency = 0.75
}

local settings = _G.PF_ESP_Settings

local aabbCorners = table.create(8)
local smoothers = {}
local espCache = {}
local modelCache = {}
local chamCache = {}
local myPosCache = { pos = nil, time = 0 }
local running = true
local nameMap = {}
local visibilityCache = {}
local raycastQueue = {}
local raycastIndex = 1
local RAYCAST_BATCH = 7
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist
rayParams.IgnoreWater = true

local chamContainer = Instance.new("Folder")
chamContainer.Name = "RBX_" .. tostring(math.random(100000, 999999))
chamContainer.Parent = game:GetService("CoreGui")

local spawnBurst = 0
local roundActive = true

_G.PF_ESP_Functions = {}

function _G.PF_ESP_Functions.GetTeamInfo()
    return { friendly = TeamModule.GetMyTeamFolder(), enemy = nil }
end

function _G.PF_ESP_Functions.RefreshCache()
    modelCache = {}
    for _, c in pairs(chamCache) do pcall(function() c:Destroy() end) end
    chamCache = {}
    nameMap = {}
    visibilityCache = {}
    table.clear(raycastQueue)
    raycastIndex = 1
    table.clear(smoothers)
end

function _G.PF_ESP_Functions.CleanupRound()
    table.clear(modelCache)
    table.clear(nameMap)
    table.clear(visibilityCache)
    table.clear(raycastQueue)
    table.clear(smoothers)
    raycastIndex = 1
    for _, d in pairs(espCache) do
        for _, v in pairs(d) do pcall(function() v:Remove() end) end
    end
    table.clear(espCache)
    for _, c in pairs(chamCache) do pcall(function() c:Destroy() end) end
    table.clear(chamCache)
end

function _G.PF_ESP_Functions.Stop()
    running = false
    _G.PF_ESP_Functions.CleanupRound()
end

function _G.PF_ESP_Functions.Start()
    running = true
end

function _G.PF_ESP_Functions.DetectTeams()
    return true
end

local function setupRoundDetection()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function()
                spawnBurst = spawnBurst + 1
                task.delay(2, function()
                    spawnBurst = math.max(0, spawnBurst - 1)
                end)
                if spawnBurst >= 3 and not roundActive then
                    roundActive = true
                    _G.PF_ESP_Functions.RefreshCache()
                end
            end)
        end
    end
    task.spawn(function()
        while task.wait(1) do
            local playersFolder = Workspace:FindFirstChild("Players")
            if playersFolder then
                local allEmpty = true
                for _, f in ipairs(playersFolder:GetChildren()) do
                    if f:IsA("Folder") and #f:GetChildren() > 0 then
                        allEmpty = false
                        break
                    end
                end
                if allEmpty and roundActive then
                    roundActive = false
                    _G.PF_ESP_Functions.CleanupRound()
                end
            end
        end
    end)
end

setupRoundDetection()

local function isPlayerActive()
    return UIS.WindowFocused and not GuiService.MenuIsOpen
end

local function setIfChanged(obj, prop, newVal)
    local cacheKey = "c_" .. prop
    if obj[cacheKey] ~= newVal then
        obj[prop] = newVal
        obj[cacheKey] = newVal
    end
end

local function smoothScreenPosition(modelId, targetX, targetY)
    local s = smoothers[modelId]
    if not s then
        s = { x = targetX, y = targetY, init = true }
        smoothers[modelId] = s
        return targetX, targetY
    end
    if s.init then
        s.x, s.y = targetX, targetY
        s.init = nil
        return targetX, targetY
    end
    local dx = targetX - s.x
    local dy = targetY - s.y
    local dist = math.sqrt(dx*dx + dy*dy)
    local SNAP_THRESH = 80
    local MIN_ALPHA = 0.12
    local MAX_ALPHA = 0.95
    local alpha = MIN_ALPHA + (MAX_ALPHA - MIN_ALPHA) * math.min(dist / SNAP_THRESH, 1)
    s.x = s.x + dx * alpha
    s.y = s.y + dy * alpha
    return s.x, s.y
end

local function processVisibilityBatch()
    if #raycastQueue == 0 then return end
    local camPos = Camera.CFrame.Position
    local checked = 0
    while checked < RAYCAST_BATCH and #raycastQueue > 0 do
        if raycastIndex > #raycastQueue then raycastIndex = 1 end
        local entry = raycastQueue[raycastIndex]
        local model = entry.model
        if model and model.Parent then
            local cached = ScreenCache.Get(model)
            if cached and cached.onScreen then
                local headPos = cached.worldPos
                local dir = headPos - camPos
                local dist = dir.Magnitude
                if dist > 0.1 then
                    rayParams.FilterDescendantsInstances = {LocalPlayer.Character or nil, model}
                    local result = Workspace:Raycast(camPos, dir.Unit * dist, rayParams)
                    visibilityCache[model] = (result == nil)
                end
            end
        else
            table.remove(raycastQueue, raycastIndex)
            visibilityCache[model] = nil
            raycastIndex = raycastIndex - 1
        end
        raycastIndex = raycastIndex + 1
        checked = checked + 1
    end
end

local function getWorldAABB(parts)
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
    local anyPart = false
    for i = 1, #parts do
        local part = parts[i]
        if part.Parent then
            anyPart = true
            local px, py, pz = part.Position.X, part.Position.Y, part.Position.Z
            local sx = part.Size.X * 0.5
            local sy = part.Size.Y * 0.5
            local sz = part.Size.Z * 0.5
            if px - sx < minX then minX = px - sx end
            if py - sy < minY then minY = py - sy end
            if pz - sz < minZ then minZ = pz - sz end
            if px + sx > maxX then maxX = px + sx end
            if py + sy > maxY then maxY = py + sy end
            if pz + sz > maxZ then maxZ = pz + sz end
        end
    end
    return anyPart and { minX = minX, minY = minY, minZ = minZ, maxX = maxX, maxY = maxY, maxZ = maxZ } or nil
end

local function aabbToScreen(aabb, camera)
    aabbCorners[1] = Vector3.new(aabb.minX, aabb.minY, aabb.minZ)
    aabbCorners[2] = Vector3.new(aabb.maxX, aabb.minY, aabb.minZ)
    aabbCorners[3] = Vector3.new(aabb.minX, aabb.maxY, aabb.minZ)
    aabbCorners[4] = Vector3.new(aabb.maxX, aabb.maxY, aabb.minZ)
    aabbCorners[5] = Vector3.new(aabb.minX, aabb.minY, aabb.maxZ)
    aabbCorners[6] = Vector3.new(aabb.maxX, aabb.minY, aabb.maxZ)
    aabbCorners[7] = Vector3.new(aabb.minX, aabb.maxY, aabb.maxZ)
    aabbCorners[8] = Vector3.new(aabb.maxX, aabb.maxY, aabb.maxZ)
    local mx, my, Mx, My = math.huge, math.huge, -math.huge, -math.huge
    local mz = math.huge
    local anyOnScreen = false
    for i = 1, 8 do
        local sp, on = camera:WorldToViewportPoint(aabbCorners[i])
        if on then
            anyOnScreen = true
            local spx, spy, spz = sp.X, sp.Y, sp.Z
            if spx < mx then mx = spx end
            if spy < my then my = spy end
            if spx > Mx then Mx = spx end
            if spy > My then My = spy end
            if spz < mz then mz = spz end
        end
    end
    return anyOnScreen and { mx = mx, my = my, Mx = Mx, My = My, mz = mz } or nil
end

local function updateNameMap()
    nameMap = {}
    local playersList = Players:GetPlayers()
    if #playersList == 0 then return end
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return end
    local allModels = {}
    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if teamFolder:IsA("Folder") then
            for _, model in ipairs(teamFolder:GetChildren()) do
                if model:IsA("Model") then
                    local center = Vector3.zero
                    local count = 0
                    for _, part in ipairs(model:GetDescendants()) do
                        if part:IsA("BasePart") then
                            center = center + part.Position
                            count = count + 1
                        end
                    end
                    if count > 0 then
                        allModels[#allModels + 1] = { model = model, center = center / count }
                    end
                end
            end
        end
    end
    local matched = {}
    for _, data in ipairs(allModels) do
        local bestPlayer, bestDist = nil, 15
        for _, player in ipairs(playersList) do
            if not matched[player] and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                    or player.Character:FindFirstChildWhichIsA("BasePart")
                if root then
                    local dist = (root.Position - data.center).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestPlayer = player
                    end
                end
            end
        end
        if bestPlayer then
            nameMap[data.model] = bestPlayer.DisplayName or bestPlayer.Name
            matched[bestPlayer] = true
        end
    end
end

task.spawn(function()
    while task.wait(0.2) do
        if running then pcall(updateNameMap) end
    end
end)

local function getOrCreateESP(model)
    if espCache[model] then return espCache[model] end
    local d = {}
    if settings.Boxes then
        d.box = Drawing.new("Square")
        d.box.Visible = false
        d.box.Filled = false
        d.box.Transparency = 1
    end
    if settings.Tracers then
        d.tracer = Drawing.new("Line")
        d.tracer.Visible = false
        d.tracer.Transparency = 1
    end
    if settings.Names then
        d.nameShadow = Drawing.new("Text")
        d.nameShadow.Visible = false
        d.nameShadow.Center = true
        d.nameShadow.Font = Drawing.Fonts.Monospace
        d.nameShadow.Color = Color3.new(0, 0, 0)
        d.nameShadow.Transparency = 0.4
        d.name = Drawing.new("Text")
        d.name.Visible = false
        d.name.Center = true
        d.name.Outline = true
        d.name.Font = Drawing.Fonts.Monospace
        d.name.Transparency = 1
    end
    espCache[model] = d
    return d
end

local function getOrCreateCham(model)
    if chamCache[model] then return chamCache[model] end
    local cham = Instance.new("Highlight")
    cham.Name = model.Name
    cham.Adornee = model
    cham.Parent = chamContainer
    cham.Enabled = false
    chamCache[model] = cham
    return cham
end

local function removeCham(model)
    if chamCache[model] then
        pcall(function() chamCache[model]:Destroy() end)
        chamCache[model] = nil
    end
end

local function updateCham(cham)
    cham.FillColor = settings.ChamColor
    cham.OutlineColor = settings.ChamColor
    cham.FillTransparency = settings.ChamFillTransparency
    cham.OutlineTransparency = math.min(0.99, settings.ChamFillTransparency - 0.23 + math.random() * 0.04)
end

local function removeESP(model)
    if espCache[model] then
        for _, v in pairs(espCache[model]) do pcall(function() v:Remove() end) end
        espCache[model] = nil
    end
    removeCham(model)
    smoothers[model] = nil
    visibilityCache[model] = nil
end

local function getMyPosition()
    if tick() - myPosCache.time < 0.1 and myPosCache.pos then return myPosCache.pos end
    local ignore = Workspace:FindFirstChild("Ignore")
    if ignore then
        for _, model in ipairs(ignore:GetChildren()) do
            if model:IsA("Model") then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    myPosCache.pos = hrp.Position
                    myPosCache.time = tick()
                    return myPosCache.pos
                end
            end
        end
    end
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            myPosCache.pos = hrp.Position
            myPosCache.time = tick()
            return myPosCache.pos
        end
    end
    return nil
end

local function resolveLabelOverlap(labels)
    local MIN_SEPARATION = 25
    for i = 1, #labels do
        if not labels[i].visible then continue end
        for j = i + 1, #labels do
            if not labels[j].visible then continue end
            local dx = labels[i].x - labels[j].x
            local dy = labels[i].y - labels[j].y
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist < MIN_SEPARATION then
                local distI = math.abs(labels[i].x - Camera.ViewportSize.X / 2)
                local distJ = math.abs(labels[j].x - Camera.ViewportSize.X / 2)
                if distI > distJ then
                    labels[i].visible = false
                else
                    labels[j].visible = false
                end
            end
        end
    end
end

local function rebuildRaycastQueue(activeModels)
    table.clear(raycastQueue)
    for model, _ in pairs(activeModels) do
        if visibilityCache[model] == nil then
            visibilityCache[model] = true
        end
        raycastQueue[#raycastQueue + 1] = { model = model }
    end
    if raycastIndex > #raycastQueue then raycastIndex = 1 end
end

local lastQueueRebuild = 0

local function updateESP()
    if not running then return end
    if not isPlayerActive() then return end

    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return end

    if not settings.Enabled then
        for _, d in pairs(espCache) do
            if d.box then d.box.Visible = false end
            if d.tracer then d.tracer.Visible = false end
            if d.name then d.name.Visible = false end
            if d.nameShadow then d.nameShadow.Visible = false end
        end
        for _, c in pairs(chamCache) do c.Enabled = false end
        return
    end

    if settings.VisibilityCheck then
        processVisibilityBatch()
    end

    local myPos = getMyPosition()
    local myFolder = TeamModule.GetMyTeamFolder()
    local activeModels = {}
    local headPositions = {}
    local vs = Camera.ViewportSize
    local screenCX = vs.X / 2
    local screenBY = vs.Y
    local tracerOriginY = settings.TracerFromCrosshair and (vs.Y / 2) or vs.Y
    local activeLabels = {}

    if tick() - lastQueueRebuild > 2 then
        rebuildRaycastQueue(activeModels)
        lastQueueRebuild = tick()
    end

    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if not teamFolder:IsA("Folder") then continue end
        for _, model in ipairs(teamFolder:GetChildren()) do
            if not model:IsA("Model") then continue end
            activeModels[model] = true

            local md = modelCache[model]
            if not md or md.t + 0.5 < tick() then
                local parts = {}
                local head = nil
                local hy = -math.huge
                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("BasePart") and part.Transparency < 0.95 then
                        parts[#parts + 1] = part
                        if part.Position.Y > hy then
                            hy = part.Position.Y
                            head = part
                        end
                    end
                end
                md = { p = parts, h = head, t = tick() }
                modelCache[model] = md
            end

            if md.h then
                headPositions[model] = md.h.Position
            elseif #md.p > 0 then
                headPositions[model] = md.p[1].Position
            end
        end
    end

    ScreenCache.Rebuild(activeModels, headPositions)

    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if not teamFolder:IsA("Folder") then continue end
        local isFriendly = settings.TeamCheck and myFolder and teamFolder == myFolder

        for _, model in ipairs(teamFolder:GetChildren()) do
            if not model:IsA("Model") then continue end

            local md = modelCache[model]
            if not md or #md.p == 0 then
                if espCache[model] then
                    if espCache[model].box then espCache[model].box.Visible = false end
                    if espCache[model].tracer then espCache[model].tracer.Visible = false end
                    if espCache[model].name then espCache[model].name.Visible = false end
                    if espCache[model].nameShadow then espCache[model].nameShadow.Visible = false end
                end
                if chamCache[model] then chamCache[model].Enabled = false end
                continue
            end

            local parts = md.p
            local cached = ScreenCache.Get(model)
            if not cached or not cached.onScreen then
                if espCache[model] then
                    if espCache[model].box then espCache[model].box.Visible = false end
                    if espCache[model].tracer then espCache[model].tracer.Visible = false end
                    if espCache[model].name then espCache[model].name.Visible = false end
                    if espCache[model].nameShadow then espCache[model].nameShadow.Visible = false end
                end
                continue
            end

            local centerPos = cached.worldPos
            local dist = myPos and (myPos - centerPos).Magnitude or 0
            local inRange = dist < settings.MaxDistance
            local playerName = nameMap[model]

            local visible = true
            if settings.VisibilityCheck and inRange and not isFriendly then
                visible = visibilityCache[model]
                if visible == nil then visible = true end
            end

            local currentColor = visible and settings.EnemyColor or settings.OccludedColor

            local showChams = settings.Chams and inRange and (not settings.TeamCheck or not isFriendly)
            if showChams then
                local cham = getOrCreateCham(model)
                if cham then
                    cham.Enabled = true
                    updateCham(cham)
                end
            else
                if chamCache[model] then chamCache[model].Enabled = false end
            end

            if isFriendly then
                if espCache[model] then
                    if espCache[model].box then espCache[model].box.Visible = false end
                    if espCache[model].tracer then espCache[model].tracer.Visible = false end
                    if espCache[model].name then espCache[model].name.Visible = false end
                    if espCache[model].nameShadow then espCache[model].nameShadow.Visible = false end
                end
                continue
            end

            local d = getOrCreateESP(model)

            local aabb = getWorldAABB(parts)
            if not aabb then
                if d.box then setIfChanged(d.box, "Visible", false) end
                if d.tracer then setIfChanged(d.tracer, "Visible", false) end
                if d.name then setIfChanged(d.name, "Visible", false) end
                if d.nameShadow then setIfChanged(d.nameShadow, "Visible", false) end
                continue
            end

            local bounds = aabbToScreen(aabb, Camera)
            if not bounds then
                if d.box then setIfChanged(d.box, "Visible", false) end
                if d.tracer then setIfChanged(d.tracer, "Visible", false) end
                if d.name then setIfChanged(d.name, "Visible", false) end
                if d.nameShadow then setIfChanged(d.nameShadow, "Visible", false) end
                continue
            end

            local sx, sy = smoothScreenPosition(model, cached.x, cached.y)
            local show = bounds.mz > 0 and inRange

            if d.box then
                setIfChanged(d.box, "Visible", show)
                if show then
                    setIfChanged(d.box, "Color", currentColor)
                    setIfChanged(d.box, "Thickness", settings.BoxThickness)
                    setIfChanged(d.box, "Position", Vector2.new(bounds.mx, bounds.my))
                    setIfChanged(d.box, "Size", Vector2.new(bounds.Mx - bounds.mx, bounds.My - bounds.my))
                end
            end

            if d.tracer then
                setIfChanged(d.tracer, "Visible", show)
                if show then
                    setIfChanged(d.tracer, "Color", currentColor)
                    setIfChanged(d.tracer, "Thickness", settings.TracerThickness)
                    setIfChanged(d.tracer, "From", Vector2.new(screenCX, tracerOriginY))
                    setIfChanged(d.tracer, "To", Vector2.new(cached.x, cached.y))
                end
            end

            if d.name and playerName then
                local labelY = bounds.my - settings.NameSize - 4
                activeLabels[#activeLabels + 1] = {
                    drawing = d.name,
                    shadow = d.nameShadow,
                    x = sx,
                    y = labelY,
                    visible = show,
                    text = playerName
                }
            elseif d.name then
                setIfChanged(d.name, "Visible", false)
                if d.nameShadow then setIfChanged(d.nameShadow, "Visible", false) end
            end
        end
    end

    resolveLabelOverlap(activeLabels)
    for _, label in ipairs(activeLabels) do
        if label.shadow then
            setIfChanged(label.shadow, "Visible", label.visible)
            if label.visible then
                setIfChanged(label.shadow, "Size", settings.NameSize)
                setIfChanged(label.shadow, "Position", Vector2.new(label.x + 1, label.y + 1))
                setIfChanged(label.shadow, "Text", label.text)
            end
        end
        setIfChanged(label.drawing, "Visible", label.visible)
        if label.visible then
            setIfChanged(label.drawing, "Color", Color3.fromRGB(255, 255, 255))
            setIfChanged(label.drawing, "Size", settings.NameSize)
            setIfChanged(label.drawing, "Position", Vector2.new(label.x, label.y))
            setIfChanged(label.drawing, "Text", label.text)
        end
    end

    for model, _ in pairs(espCache) do
        if not activeModels[model] then
            removeESP(model)
            modelCache[model] = nil
            nameMap[model] = nil
        end
    end
    for model, _ in pairs(modelCache) do
        if not activeModels[model] then modelCache[model] = nil end
    end
    for model, _ in pairs(chamCache) do
        if not activeModels[model] then removeCham(model) end
    end
end

RunService.RenderStepped:Connect(updateESP)
