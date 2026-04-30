-- Phantom Forces ESP - Rendering Engine
-- Settings controlled via _G.PF_ESP_Settings
-- Functions exposed via _G.PF_ESP_Functions

local Workspace = workspace
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Settings table (modified by external UI)
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
    ChamOutlineColor = Color3.fromRGB(255, 50, 50),
    ChamFillColor = Color3.fromRGB(255, 50, 50),
    ChamOutlineTransparency = 0.5,
    ChamFillTransparency = 0.75
}

local settings = _G.PF_ESP_Settings

-- Internal state
local espCache = {}
local modelCache = {}
local chamCache = {}
local teamFolders = { friendly = nil, enemy = nil }
local myPosCache = { pos = nil, time = 0 }
local running = true

-- Functions exposed to main script
_G.PF_ESP_Functions = {}

function _G.PF_ESP_Functions.GetTeamInfo()
    return teamFolders
end

function _G.PF_ESP_Functions.GetESPCount()
    local count = 0
    for _ in pairs(espCache) do count = count + 1 end
    return count
end

function _G.PF_ESP_Functions.Stop()
    running = false
    for _, d in pairs(espCache) do
        for _, v in pairs(d) do pcall(function() v:Remove() end) end
    end
    for _, c in pairs(chamCache) do
        pcall(function() c:Destroy() end)
    end
    espCache = {}
    modelCache = {}
    chamCache = {}
end

function _G.PF_ESP_Functions.Start()
    running = true
end

-- Corner calculation
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

-- Detect which team folder is friendly
function _G.PF_ESP_Functions.DetectTeams()
    local myTeamColor = LocalPlayer.TeamColor
    if not myTeamColor then return false end
    
    local myColorNumber = myTeamColor.Number
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    
    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if teamFolder:IsA("Folder") then
            for _, model in ipairs(teamFolder:GetChildren()) do
                if model:IsA("Model") then
                    local checked = 0
                    for _, part in ipairs(model:GetDescendants()) do
                        if checked >= 10 then break end
                        if part:IsA("BasePart") then
                            checked = checked + 1
                            local bc = part.BrickColor
                            if bc.Number == myColorNumber or
                               bc.Name == "Earth blue" or
                               bc.Name == "Royal blue" then
                                teamFolders.friendly = teamFolder.Name
                                for _, other in ipairs(playersFolder:GetChildren()) do
                                    if other:IsA("Folder") and other.Name ~= teamFolders.friendly then
                                        teamFolders.enemy = other.Name
                                        return true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

-- Create ESP drawings
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
    
    espCache[model] = d
    return d
end

-- Create cham highlight for a model
local function getOrCreateChams(model)
    if chamCache[model] then return chamCache[model] end
    
    local outline = Instance.new("Highlight")
    outline.Name = "PF_ChamOutline"
    outline.FillTransparency = 1
    outline.OutlineTransparency = settings.ChamOutlineTransparency
    outline.OutlineColor = settings.ChamOutlineColor
    outline.Adornee = model
    outline.Parent = model
    
    local fill = Instance.new("Highlight")
    fill.Name = "PF_ChamFill"
    fill.FillTransparency = settings.ChamFillTransparency
    fill.OutlineTransparency = 1
    fill.FillColor = settings.ChamFillColor
    fill.Adornee = model
    fill.Parent = model
    
    local cham = { outline = outline, fill = fill }
    chamCache[model] = cham
    return cham
end

-- Remove cham
local function removeChams(model)
    if chamCache[model] then
        pcall(function() chamCache[model].outline:Destroy() end)
        pcall(function() chamCache[model].fill:Destroy() end)
        chamCache[model] = nil
    end
end

-- Update cham properties
local function updateChamProperties(cham)
    cham.outline.OutlineColor = settings.ChamOutlineColor
    cham.outline.OutlineTransparency = settings.ChamOutlineTransparency
    cham.fill.FillColor = settings.ChamFillColor
    cham.fill.FillTransparency = settings.ChamFillTransparency
end

-- Remove ESP
local function removeESP(model)
    if espCache[model] then
        for _, drawing in pairs(espCache[model]) do
            pcall(function() drawing:Remove() end)
        end
        espCache[model] = nil
    end
    removeChams(model)
end

-- Get our position
local function getMyPosition()
    if tick() - myPosCache.time < 0.1 and myPosCache.pos then
        return myPosCache.pos
    end
    
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

-- Main update
local function updateESP()
    if not running then return end
    
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return end
    
    if not settings.Enabled then
        for _, d in pairs(espCache) do
            for _, v in pairs(d) do v.Visible = false end
        end
        for model, _ in pairs(chamCache) do
            removeChams(model)
        end
        return
    end
    
    local myPos = getMyPosition()
    local activeModels = {}
    local vs = Camera.ViewportSize
    local screenCX = vs.X / 2
    local screenBY = vs.Y
    
    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if not teamFolder:IsA("Folder") then continue end
        
        local isFriendly = settings.TeamCheck and teamFolders.friendly and teamFolder.Name == teamFolders.friendly
        
        for _, model in ipairs(teamFolder:GetChildren()) do
            if not model:IsA("Model") then continue end
            activeModels[model] = true
            
            -- Get/cache parts
            local md = modelCache[model]
            if not md or md.t + 0.5 < tick() then
                local parts = {}
                local head = nil
                local hy = -math.huge
                
                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("BasePart") and part.Transparency < 0.7 then
                        parts[#parts + 1] = part
                        local py = part.Position.Y
                        if py > hy then
                            hy = py
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
                removeChams(model)
                continue
            end
            
            local centerPos = head and head.Position or parts[1].Position
            local dist = myPos and (myPos - centerPos).Magnitude or 0
            
            -- Chams
            if settings.Chams and not isFriendly then
                local cham = getOrCreateChams(model)
                cham.outline.Enabled = dist < settings.MaxDistance
                cham.fill.Enabled = dist < settings.MaxDistance
                updateChamProperties(cham)
            else
                removeChams(model)
            end
            
            -- Skip ESP drawings for friendlies
            if isFriendly then
                if espCache[model] then
                    for _, v in pairs(espCache[model]) do v.Visible = false end
                end
                if not settings.Chams then
                    removeChams(model)
                end
                continue
            end
            
            -- ESP Drawings
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
                continue
            end
            
            local cs = Camera:WorldToViewportPoint(centerPos)
            local show = mz > 0 and dist < settings.MaxDistance
            
            -- Box
            if d.box then
                d.box.Visible = show
                if show then
                    d.box.Color = settings.EnemyColor
                    d.box.Thickness = settings.BoxThickness
                    d.box.Position = Vector2.new(mx, my)
                    d.box.Size = Vector2.new(Mx - mx, My - my)
                end
            end
            
            -- Tracer
            if d.tracer then
                d.tracer.Visible = show
                if show then
                    d.tracer.Color = settings.EnemyColor
                    d.tracer.Thickness = settings.TracerThickness
                    d.tracer.From = Vector2.new(screenCX, screenBY)
                    d.tracer.To = Vector2.new(cs.X, cs.Y)
                end
            end
        end
    end
    
    -- Cleanup
    for model, _ in pairs(espCache) do
        if not activeModels[model] then
            removeESP(model)
            modelCache[model] = nil
        end
    end
    for model, _ in pairs(modelCache) do
        if not activeModels[model] then
            modelCache[model] = nil
        end
    end
    for model, _ in pairs(chamCache) do
        if not activeModels[model] then
            removeChams(model)
        end
    end
end

-- Team detection loop
task.spawn(function()
    while task.wait(2) do
        if not teamFolders.friendly then
            _G.PF_ESP_Functions.DetectTeams()
        end
    end
end)

-- Start rendering
RunService.RenderStepped:Connect(updateESP)

print("PF ESP Engine loaded")
