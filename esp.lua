-- Phantom Forces ESP - Rendering Engine

local Workspace = workspace
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")

_G.PF_ESP_Settings = _G.PF_ESP_Settings or {
    Enabled = true,
    Boxes = true,
    Tracers = true,
    Chams = false,
    MaxDistance = 800,
    TeamCheck = true,
    EnemyColor = Color3.fromRGB(255, 50, 50),
    BoxThickness = 1,
    TracerThickness = 1,
    ChamColor = Color3.fromRGB(255, 50, 50),
    ChamFillTransparency = 0.75,
    TracerFromCrosshair = false,
}

local settings = _G.PF_ESP_Settings

local espCache   = {}
local modelCache = {}
local chamCache  = {}
local teamFolders = { friendly = nil, enemy = nil }
local myPosCache  = { pos = nil, time = 0 }
local running = true

-- Randomised container name so it's not a static signature
local chamContainer = Instance.new("Folder")
chamContainer.Name  = "RBX_" .. tostring(math.random(100000, 999999))
chamContainer.Parent = game:GetService("CoreGui")

_G.PF_ESP_Functions = {}

-- ─── Helpers ────────────────────────────────────────────────────────────────

local function getCorners(cf, size)
    local sx, sy, sz = size.X * 0.5, size.Y * 0.5, size.Z * 0.5
    local x, y, z   = cf.X, cf.Y, cf.Z
    return {
        Vector3.new(x+sx, y+sy, z+sz), Vector3.new(x-sx, y+sy, z+sz),
        Vector3.new(x+sx, y-sy, z+sz), Vector3.new(x+sx, y+sy, z-sz),
        Vector3.new(x-sx, y-sy, z+sz), Vector3.new(x-sx, y+sy, z-sz),
        Vector3.new(x+sx, y-sy, z-sz), Vector3.new(x-sx, y-sy, z-sz),
    }
end

local function getMyPosition()
    if tick() - myPosCache.time < 0.05 and myPosCache.pos then
        return myPosCache.pos
    end

    local ignore = Workspace:FindFirstChild("Ignore")
    if ignore then
        for _, model in ipairs(ignore:GetChildren()) do
            if model:IsA("Model") then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    myPosCache.pos  = hrp.Position
                    myPosCache.time = tick()
                    return myPosCache.pos
                end
            end
        end
    end

    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            myPosCache.pos  = hrp.Position
            myPosCache.time = tick()
            return myPosCache.pos
        end
    end
    return nil
end

-- ─── Team detection (vote-based, robust) ────────────────────────────────────
--
-- For every folder in workspace.Players we score how many visible BaseParts
-- share the LocalPlayer's TeamColor number.  The folder with the highest score
-- is friendly.  This avoids the "first blue part wins" bug that caused
-- reversals when an enemy had a stray blue gun piece.

local FRIENDLY_BRICKCOLORS = {
    ["Bright blue"]  = true,
    ["Earth blue"]   = true,
    ["Royal blue"]   = true,
    ["Deep blue"]    = true,
    ["Navy blue"]    = true,
}

function _G.PF_ESP_Functions.DetectTeams()
    local myTeamColor = LocalPlayer.TeamColor
    if not myTeamColor then return false end

    local myColorNumber = myTeamColor.Number
    local myColorName   = myTeamColor.Name

    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return false end

    teamFolders.friendly = nil
    teamFolders.enemy    = nil

    local folderScores = {}  -- folderName -> {friendly=N, total=N}

    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if not teamFolder:IsA("Folder") then continue end

        local score = { friendly = 0, total = 0 }
        folderScores[teamFolder.Name] = score

        for _, model in ipairs(teamFolder:GetChildren()) do
            if not model:IsA("Model") then continue end

            local checked = 0
            for _, part in ipairs(model:GetDescendants()) do
                if checked >= 20 then break end
                if part:IsA("BasePart") and part.Transparency < 0.7 then
                    checked = checked + 1
                    score.total = score.total + 1
                    local bc = part.BrickColor
                    -- Match by exact number first (most reliable), then by name
                    if bc.Number == myColorNumber
                    or bc.Name   == myColorName
                    or FRIENDLY_BRICKCOLORS[bc.Name] then
                        score.friendly = score.friendly + 1
                    end
                end
            end
        end
    end

    -- Pick the folder whose friendly-part ratio is highest
    local bestFolder = nil
    local bestRatio  = -1

    for name, score in pairs(folderScores) do
        if score.total > 0 then
            local ratio = score.friendly / score.total
            if ratio > bestRatio then
                bestRatio  = ratio
                bestFolder = name
            end
        end
    end

    if not bestFolder or bestRatio < 0.1 then
        -- Fallback: couldn't confidently identify friendly team
        return false
    end

    teamFolders.friendly = bestFolder

    for name, _ in pairs(folderScores) do
        if name ~= bestFolder then
            teamFolders.enemy = name
            break
        end
    end

    return true
end

-- ─── ESP drawing cache ───────────────────────────────────────────────────────
--
-- FIX: getOrCreateESP used to create box/tracer only if the setting was ON
-- at creation time. If you toggled Boxes on later, d.box stayed nil forever.
-- Now we ALWAYS create both drawing objects; visibility is controlled by
-- d.box.Visible, not by whether the object exists.

local function getOrCreateESP(model)
    local d = espCache[model]
    if d then
        -- Ensure both drawings exist even if a setting was off at creation time
        if not d.box then
            d.box = Drawing.new("Square")
            d.box.Visible = false
            d.box.Filled  = false
            d.box.Transparency = 1
        end
        if not d.tracer then
            d.tracer = Drawing.new("Line")
            d.tracer.Visible = false
            d.tracer.Transparency = 1
        end
        return d
    end

    d = {}
    d.box = Drawing.new("Square")
    d.box.Visible = false
    d.box.Filled  = false
    d.box.Transparency = 1

    d.tracer = Drawing.new("Line")
    d.tracer.Visible = false
    d.tracer.Transparency = 1

    espCache[model] = d
    return d
end

local function getOrCreateCham(model)
    if chamCache[model] then return chamCache[model] end

    local cham    = Instance.new("Highlight")
    cham.Name     = tostring(math.random(10000, 99999))  -- don't use model name
    cham.Adornee  = model
    cham.Parent   = chamContainer
    cham.Enabled  = false

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
    cham.FillColor          = settings.ChamColor
    cham.OutlineColor       = settings.ChamColor
    cham.FillTransparency   = settings.ChamFillTransparency
    -- Slight random offset so values are never an exact known signature
    local outlineT = settings.ChamFillTransparency - 0.23 + (math.random() * 0.04)
    cham.OutlineTransparency = math.clamp(outlineT, 0, 1)
end

local function removeESP(model)
    if espCache[model] then
        for _, drawing in pairs(espCache[model]) do
            pcall(function() drawing:Remove() end)
        end
        espCache[model] = nil
    end
    removeCham(model)
end

-- ─── Public control functions ────────────────────────────────────────────────

function _G.PF_ESP_Functions.GetTeamInfo()
    return teamFolders
end

-- FIX: FlushCache wipes BOTH espCache and modelCache so toggling a setting
-- causes a full rebuild next frame — drawings are recreated with correct state.
function _G.PF_ESP_Functions.FlushCache()
    for _, d in pairs(espCache) do
        for _, drawing in pairs(d) do
            pcall(function() drawing:Remove() end)
        end
    end
    espCache   = {}
    modelCache = {}
end

function _G.PF_ESP_Functions.Stop()
    running = false
    _G.PF_ESP_Functions.FlushCache()
    for model, _ in pairs(chamCache) do removeCham(model) end
end

function _G.PF_ESP_Functions.Start()
    running = true
end

-- ─── Main render loop ────────────────────────────────────────────────────────

local function updateESP()
    if not running then return end

    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return end

    -- If ESP is disabled, hide everything and bail
    if not settings.Enabled then
        for _, d in pairs(espCache) do
            if d.box    then d.box.Visible    = false end
            if d.tracer then d.tracer.Visible = false end
        end
        for model, cham in pairs(chamCache) do cham.Enabled = false end
        return
    end

    local myPos      = getMyPosition()
    local vs         = Camera.ViewportSize
    local screenCX   = vs.X / 2
    local screenBY   = vs.Y
    local screenMidY = vs.Y / 2
    local activeModels = {}

    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if not teamFolder:IsA("Folder") then continue end

        local isFriendly = settings.TeamCheck
            and teamFolders.friendly ~= nil
            and teamFolder.Name == teamFolders.friendly

        for _, model in ipairs(teamFolder:GetChildren()) do
            if not model:IsA("Model") then continue end
            activeModels[model] = true

            -- Model part cache (0.5 s TTL)
            local md = modelCache[model]
            if not md or md.t + 0.5 < tick() then
                local parts = {}
                local head  = nil
                local hy    = -math.huge

                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("BasePart") and part.Transparency < 0.95 then
                        parts[#parts + 1] = part
                        local py = part.Position.Y
                        if py > hy then hy = py; head = part end
                    end
                end

                md = { p = parts, h = head, t = tick() }
                modelCache[model] = md
            end

            local parts = md.p
            local head  = md.h

            if #parts == 0 then
                local d = espCache[model]
                if d then
                    if d.box    then d.box.Visible    = false end
                    if d.tracer then d.tracer.Visible = false end
                end
                removeCham(model)
                continue
            end

            local centerPos = head and head.Position or parts[1].Position
            local dist      = myPos and (myPos - centerPos).Magnitude or 0
            local inRange   = dist < settings.MaxDistance

            -- ── Chams ──
            local showChams = settings.Chams and inRange
                and (not settings.TeamCheck or not isFriendly)

            if showChams then
                local cham = getOrCreateCham(model)
                if cham then
                    cham.Enabled = true
                    updateCham(cham)
                end
            else
                if chamCache[model] then
                    chamCache[model].Enabled = false
                end
            end

            -- ── Boxes & Tracers ──
            if isFriendly then
                -- Hide drawings for teammates
                local d = espCache[model]
                if d then
                    if d.box    then d.box.Visible    = false end
                    if d.tracer then d.tracer.Visible = false end
                end
                continue
            end

            local d  = getOrCreateESP(model)
            local mx, my, Mx, My = math.huge, math.huge, -math.huge, -math.huge
            local mz = math.huge

            local maxParts = math.min(#parts, 12)
            local step     = math.max(1, math.floor(#parts / maxParts))

            for i = 1, #parts, step do
                local part    = parts[i]
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
                if d.box    then d.box.Visible    = false end
                if d.tracer then d.tracer.Visible = false end
                continue
            end

            local cs   = Camera:WorldToViewportPoint(centerPos)
            local show = mz > 0 and inRange

            if d.box then
                d.box.Visible = show and settings.Boxes
                if show and settings.Boxes then
                    d.box.Color     = settings.EnemyColor
                    d.box.Thickness = settings.BoxThickness
                    d.box.Position  = Vector2.new(mx, my)
                    d.box.Size      = Vector2.new(Mx - mx, My - my)
                end
            end

            if d.tracer then
                d.tracer.Visible = show and settings.Tracers
                if show and settings.Tracers then
                    d.tracer.Color     = settings.EnemyColor
                    d.tracer.Thickness = settings.TracerThickness
                    d.tracer.From      = Vector2.new(screenCX,
                        settings.TracerFromCrosshair and screenMidY or screenBY)
                    d.tracer.To        = Vector2.new(cs.X, cs.Y)
                end
            end
        end
    end

    -- Cleanup stale models
    for model in pairs(espCache) do
        if not activeModels[model] then removeESP(model); modelCache[model] = nil end
    end
    for model in pairs(modelCache) do
        if not activeModels[model] then modelCache[model] = nil end
    end
    for model in pairs(chamCache) do
        if not activeModels[model] then removeCham(model) end
    end
end

-- Re-detect teams periodically in case of map reload / team swap
task.spawn(function()
    while task.wait(3) do
        -- Always re-run detection (not just when nil) so a swap mid-match is caught
        _G.PF_ESP_Functions.DetectTeams()
    end
end)

RunService.RenderStepped:Connect(updateESP)
