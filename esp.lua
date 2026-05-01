-- Phantom Forces ESP - Rendering Engine
-- Standalone version with inline team detection

local Workspace = workspace
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")

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

local espCache = {}
local modelCache = {}
local chamCache = {}
local teamFolders = { friendly = nil, enemy = nil }
local myPosCache = { pos = nil, time = 0 }
local running = true

local chamContainer = Instance.new("Folder")
chamContainer.Name = "RBX_" .. tostring(math.random(100000, 999999))
chamContainer.Parent = game:GetService("CoreGui")

_G.PF_ESP_Functions = {}

function _G.PF_ESP_Functions.GetTeamInfo()
    return teamFolders
end

function _G.PF_ESP_Functions.RefreshCache()
    modelCache = {}
    for _, c in pairs(chamCache) do pcall(function() c:Destroy() end) end
    chamCache = {}
end

function _G.PF_ESP_Functions.Stop()
    running = false
    for _, d in pairs(espCache) do
        for _, v in pairs(d) do pcall(function() v:Remove() end) end
    end
    for _, c in pairs(chamCache) do pcall(function() c:Destroy() end) end
    espCache = {}
    modelCache = {}
    chamCache = {}
end

function _G.PF_ESP_Functions.Start()
    running = true
end

function _G.PF_ESP_Functions.DetectTeams()
    local myTeamColor = LocalPlayer.TeamColor
    if not myTeamColor then return false end
    local myColorNumber = myTeamColor.Number
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return false end

    teamFolders.friendly = nil
    teamFolders.enemy = nil

    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if teamFolder:IsA("Folder") then
            for _, model in ipairs(teamFolder:GetChildren()) do
                if model:IsA("Model") then
                    for _, part in ipairs(model:GetDescendants()) do
                        if part:IsA("BasePart") and part.Transparency < 0.5 then
                            local bc = part.BrickColor
                            if bc.Number == myColorNumber or bc.Name == "Earth blue" or bc.Name == "Royal blue" then
                                teamFolders.friendly = teamFolder.Name
                                for _, other in ipairs(playersFolder:GetChildren()) do
                                    if other:IsA("Folder") and other.Name ~= teamFolders.friendly then
                                        teamFolders.enemy = other.Name
                                    end
                                end
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

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
    cham.OutlineTransparency = math.min(0.99, settings.ChamFillTransparency - 0.25)
end

local function removeESP(model)
    if espCache[model] then
        for _, v in pairs(espCache[model]) do pcall(function() v:Remove() end) end
        espCache[model] = nil
    end
    removeCham(model)
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

local function isVisible(targetPos, model)
    local camPos = Camera.CFrame.Position
    local dir = targetPos - camPos
    local dist = dir.Magnitude
    if dist < 0.1 then return true end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character or nil, model}
    rayParams.IgnoreWater = true
    local result = Workspace:Raycast(camPos, dir.Unit * dist, rayParams)
    return result == nil
end

local function getCorners(cf, size)
    local sx, sy, sz = size.X * 0.5, size.Y * 0.5, size.Z * 0.5
    return {
        Vector3.new(cf.X + sx, cf.Y + sy, cf.Z + sz),
        Vector3.new(cf.X - sx, cf.Y + sy, cf.Z + sz),
        Vector3.new(cf.X + sx, cf.Y - sy, cf.Z + sz),
        Vector3.new(cf.X + sx, cf.Y + sy, cf.Z - sz),
        Vector3.new(cf.X - sx, cf.Y - sy, cf.Z + sz),
        Vector3.new(cf.X - sx, cf.Y + sy, cf.Z - sz),
        Vector3.new(cf.X + sx, cf.Y - sy, cf.Z - sz),
        Vector3.new(cf.X - sx, cf.Y - sy, cf.Z - sz),
    }
end

local function updateESP()
    if not running then return end
    
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return end

    if not settings.Enabled then
        for _, d in pairs(espCache) do
            for _, v in pairs(d) do v.Visible = false end
        end
        for _, c in pairs(chamCache) do c.Enabled = false end
        return
    end

    local myPos = getMyPosition()
    local activeModels = {}
    local vs = Camera.ViewportSize
    local screenCX = vs.X / 2
    local screenBY = vs.Y
    local tracerOriginY = settings.TracerFromCrosshair and (vs.Y / 2) or vs.Y

    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if not teamFolder:IsA("Folder") then continue end
        local isFriendly = settings.TeamCheck and teamFolders.friendly and teamFolder.Name == teamFolders.friendly

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

            local parts = md.p
            local head = md.h
            if #parts == 0 then
                if espCache[model] then
                    for _, v in pairs(espCache[model]) do v.Visible = false end
                end
                if chamCache[model] then chamCache[model].Enabled = false end
                continue
            end

            local centerPos = head and head.Position or parts[1].Position
            local dist = myPos and (myPos - centerPos).Magnitude or 0
            local inRange = dist < settings.MaxDistance

            -- Visibility check
            local visible = true
            if settings.VisibilityCheck and inRange and not isFriendly then
                visible = isVisible(centerPos, model)
            end
            local currentColor = visible and settings.EnemyColor or settings.OccludedColor

            -- Chams
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

            -- Skip friendly
            if isFriendly then
                if espCache[model] then
                    for _, v in pairs(espCache[model]) do v.Visible = false end
                end
                continue
            end

            local d = getOrCreateESP(model)

            -- Bounding box
            local mx, my, Mx, My = math.huge, math.huge, -math.huge, -math.huge
            local mz = math.huge
            local step = math.max(1, math.floor(#parts / 8))

            for i = 1, #parts, step do
                local part = parts[i]
                local corners = getCorners(part.CFrame, part.Size)
                for j = 1, 8 do
                    local sp, on = Camera:WorldToViewportPoint(corners[j])
                    if on then
                        if sp.X < mx then mx = sp.X end
                        if sp.Y < my then my = sp.Y end
                        if sp.X > Mx then Mx = sp.X end
                        if sp.Y > My then My = sp.Y end
                        if sp.Z < mz then mz = sp.Z end
                    end
                end
            end

            if mx == math.huge then
                if d.box then d.box.Visible = false end
                if d.tracer then d.tracer.Visible = false end
                if d.name then d.name.Visible = false end
                continue
            end

            local cs = Camera:WorldToViewportPoint(centerPos)
            local show = mz > 0 and inRange

            if d.box then
                d.box.Visible = show
                if show then
                    d.box.Color = currentColor
                    d.box.Thickness = settings.BoxThickness
                    d.box.Position = Vector2.new(mx, my)
                    d.box.Size = Vector2.new(Mx - mx, My - my)
                end
            end

            if d.tracer then
                d.tracer.Visible = show
                if show then
                    d.tracer.Color = currentColor
                    d.tracer.Thickness = settings.TracerThickness
                    d.tracer.From = Vector2.new(screenCX, tracerOriginY)
                    d.tracer.To = Vector2.new(cs.X, cs.Y)
                end
            end

            if d.name then
                d.name.Visible = show
                if show then
                    d.name.Color = Color3.fromRGB(255, 255, 255)
                    d.name.Size = settings.NameSize
                    d.name.Position = Vector2.new(cs.X, my - settings.NameSize - 4)
                    d.name.Text = "Enemy"
                end
            end
        end
    end

    for model, _ in pairs(espCache) do
        if not activeModels[model] then
            removeESP(model)
            modelCache[model] = nil
        end
    end
    for model, _ in pairs(modelCache) do
        if not activeModels[model] then modelCache[model] = nil end
    end
    for model, _ in pairs(chamCache) do
        if not activeModels[model] then removeCham(model) end
    end
end

task.spawn(function()
    while task.wait(2) do
        if not teamFolders.friendly then
            _G.PF_ESP_Functions.DetectTeams()
        end
    end
end)

RunService.RenderStepped:Connect(updateESP)
