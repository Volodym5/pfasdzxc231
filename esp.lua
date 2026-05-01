-- Phantom Forces ESP - Rendering Engine
-- Debug version - prints team info

local Workspace = workspace
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UIS = game:GetService("UserInputService")

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
    ChamOccludedColor = Color3.fromRGB(255, 150, 50),
    ChamFillTransparency = 0.75
}

local settings = _G.PF_ESP_Settings

local espCache = {}
local modelCache = {}
local chamCache = {}
local myPosCache = { pos = nil, time = 0 }
local running = true
local nameMap = {}
local teamMap = {}
local teamCheckTime = 0
local debugPrinted = false

local chamContainer = Instance.new("Folder")
chamContainer.Name = "RBX_" .. tostring(math.random(100000, 999999))
chamContainer.Parent = game:GetService("CoreGui")

_G.PF_ESP_Functions = {}

function _G.PF_ESP_Functions.RefreshCache()
    modelCache = {}
    for _, c in pairs(chamCache) do pcall(function() c:Destroy() end) end
    chamCache = {}
    nameMap = {}
    teamMap = {}
    teamCheckTime = 0
    debugPrinted = false
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
    nameMap = {}
    teamMap = {}
end

function _G.PF_ESP_Functions.Start()
    running = true
end

function _G.PF_ESP_Functions.DetectTeams()
end

local function isPlayerActive()
    return UIS.WindowFocused and not GuiService.MenuIsOpen
end

local function updateTeamMap()
    local playersList = Players:GetPlayers()
    if #playersList == 0 then return end
    
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return end

    local myTeam = LocalPlayer.Team
    
    if not debugPrinted then
        print("=== TEAM DEBUG ===")
        print("My Name: " .. LocalPlayer.Name)
        print("My Team: " .. tostring(myTeam))
        print("My TeamColor: " .. tostring(LocalPlayer.TeamColor))
        print("Players in server: " .. #playersList)
        for _, p in ipairs(playersList) do
            print("  " .. p.Name .. " | Team: " .. tostring(p.Team) .. " | TeamColor: " .. tostring(p.TeamColor) .. " | HasChar: " .. tostring(p.Character ~= nil))
        end
    end

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
                        allModels[#allModels + 1] = {
                            model = model,
                            center = center / count
                        }
                    end
                end
            end
        end
    end

    local matched = {}
    nameMap = {}
    teamMap = {}
    
    for _, data in ipairs(allModels) do
        local bestPlayer, bestDist = nil, 15
        for _, player in ipairs(playersList) do
            if not matched[player] and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
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
            local isFriendly = false
            if myTeam then
                isFriendly = (bestPlayer.Team == myTeam)
            else
                -- Fallback: use TeamColor
                if LocalPlayer.TeamColor and bestPlayer.TeamColor then
                    isFriendly = (LocalPlayer.TeamColor.Number == bestPlayer.TeamColor.Number)
                end
            end
            teamMap[data.model] = isFriendly
            
            if not debugPrinted then
                print("Model matched: " .. nameMap[data.model] .. " | Friendly: " .. tostring(isFriendly))
            end
            matched[bestPlayer] = true
        end
    end
    
    if not debugPrinted then
        print("=== END DEBUG ===")
        debugPrinted = true
    end
    
    teamCheckTime = tick()
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
        d.nameShadow = Drawing.new("Text")
        d.nameShadow.Visible = false
        d.nameShadow.Center = true
        d.nameShadow.Font = Drawing.Fonts.Monospace
        d.nameShadow.Color = Color3.new(0, 0, 0)
        d.nameShadow.Transparency = 0.5
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

local function updateCham(cham, visible)
    local color = visible and settings.ChamColor or settings.ChamOccludedColor
    cham.FillColor = color
    cham.OutlineColor = color
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
    if not isPlayerActive() then return end
    
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return end

    if not settings.Enabled then
        for _, d in pairs(espCache) do
            for _, v in pairs(d) do v.Visible = false end
        end
        for _, c in pairs(chamCache) do c.Enabled = false end
        return
    end

    if tick() - teamCheckTime > 2 then
        updateTeamMap()
    end

    local myPos = getMyPosition()
    local activeModels = {}
    local vs = Camera.ViewportSize
    local screenCX = vs.X / 2
    local screenBY = vs.Y
    local tracerOriginY = settings.TracerFromCrosshair and (vs.Y / 2) or vs.Y

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

            local isFriendly = false
            if settings.TeamCheck then
                isFriendly = teamMap[model] == true
            end

            local visible = true
            if settings.VisibilityCheck and inRange and not isFriendly then
                visible = isVisible(centerPos, model)
            end
            local currentColor = visible and settings.EnemyColor or settings.OccludedColor

            local showChams = settings.Chams and inRange and (not settings.TeamCheck or not isFriendly)
            if showChams then
                local cham = getOrCreateCham(model)
                if cham then
                    cham.Enabled = true
                    updateCham(cham, visible)
                end
            else
                if chamCache[model] then chamCache[model].Enabled = false end
            end

            if isFriendly then
                if espCache[model] then
                    for _, v in pairs(espCache[model]) do v.Visible = false end
                end
                continue
            end

            local d = getOrCreateESP(model)

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
                if d.nameShadow then d.nameShadow.Visible = false end
                continue
            end

            local cs = Camera:WorldToViewportPoint(centerPos)
            local show = mz > 0 and inRange
            local playerName = nameMap[model]

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
                d.nameShadow.Visible = show
                if show then
                    local displayName = playerName or "Enemy"
                    d.nameShadow.Color = Color3.new(0, 0, 0)
                    d.nameShadow.Transparency = 0.5
                    d.nameShadow.Size = settings.NameSize
                    d.nameShadow.Position = Vector2.new(cs.X + 1, my - settings.NameSize - 3)
                    d.nameShadow.Text = displayName
                    
                    d.name.Color = Color3.fromRGB(255, 255, 255)
                    d.name.Size = settings.NameSize
                    d.name.Position = Vector2.new(cs.X, my - settings.NameSize - 4)
                    d.name.Text = displayName
                end
            end
        end
    end

    for model, _ in pairs(espCache) do
        if not activeModels[model] then
            removeESP(model)
            modelCache[model] = nil
            nameMap[model] = nil
            teamMap[model] = nil
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
