-- Phantom Forces ESP - Standalone
-- Upload this to GitHub raw, then use: loadstring(game:HttpGet("YOUR_RAW_URL"))()

local Workspace = workspace
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Settings
local settings = {
    enabled = true,
    boxes = true,
    names = true,
    distance = true,
    tracers = true,
    maxDistance = 800,
    teamCheck = true,
    enemyColor = Color3.fromRGB(255, 50, 50),
    boxThickness = 2,
    tracerThickness = 1,
    fontSize = 13
}

-- Cache
local espCache = {}
local modelCache = {}
local teamFolders = { friendly = nil, enemy = nil }
local myPosCache = { pos = nil, time = 0 }

-- Pre-allocated corner vectors
local cornerMultipliers = {
    {1, 1, 1}, {-1, 1, 1}, {1, -1, 1}, {1, 1, -1},
    {-1, -1, 1}, {-1, 1, -1}, {1, -1, -1}, {-1, -1, -1}
}

-- Detect teams
local function detectTeams()
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
                            if part.BrickColor.Number == myColorNumber or
                               part.BrickColor.Name == "Earth blue" or
                               part.BrickColor.Name == "Royal blue" then
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
    
    if settings.boxes then
        d.box = Drawing.new("Square")
        d.box.Visible = false
        d.box.Filled = false
        d.box.Transparency = 1
    end
    
    if settings.names then
        d.name = Drawing.new("Text")
        d.name.Visible = false
        d.name.Center = true
        d.name.Outline = true
        d.name.Font = Drawing.Fonts.Monospace
        d.name.Transparency = 1
    end
    
    if settings.distance then
        d.dist = Drawing.new("Text")
        d.dist.Visible = false
        d.dist.Center = true
        d.dist.Outline = true
        d.dist.Font = Drawing.Fonts.Monospace
        d.dist.Transparency = 1
    end
    
    if settings.tracers then
        d.tracer = Drawing.new("Line")
        d.tracer.Visible = false
        d.tracer.Transparency = 1
    end
    
    espCache[model] = d
    return d
end

-- Remove ESP
local function removeESP(model)
    if espCache[model] then
        for _, drawing in pairs(espCache[model]) do
            pcall(function() drawing:Remove() end)
        end
        espCache[model] = nil
    end
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
    if not settings.enabled then
        for _, d in pairs(espCache) do
            for _, v in pairs(d) do v.Visible = false end
        end
        return
    end
    
    local myPos = getMyPosition()
    local playersFolder = Workspace:FindFirstChild("Players")
    if not playersFolder then return end
    
    local activeModels = {}
    local vs = Camera.ViewportSize
    local screenCX = vs.X / 2
    local screenBY = vs.Y
    
    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if not teamFolder:IsA("Folder") then continue end
        if settings.teamCheck and teamFolders.friendly and teamFolder.Name == teamFolders.friendly then
            continue
        end
        
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
                continue
            end
            
            local d = getOrCreateESP(model)
            
            -- Bounding box (skip parts for performance)
            local mx, my, Mx, My = math.huge, math.huge, -math.huge, -math.huge
            local mz = math.huge
            local step = math.max(1, math.floor(#parts / 8))
            
            for i = 1, #parts, step do
                local part = parts[i]
                local cf = part.CFrame
                local s = part.Size * 0.5
                
                for j = 1, 8 do
                    local cm = cornerMultipliers[j]
                    local wx = cf.X + cm[1] * s.X
                    local wy = cf.Y + cm[2] * s.Y
                    local wz = cf.Z + cm[3] * s.Z
                    local sp, on = Camera:WorldToViewportPoint(Vector3.new(wx, wy, wz))
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
                for _, v in pairs(d) do v.Visible = false end
                continue
            end
            
            local centerPos = head and head.Position or parts[1].Position
            local cs = Camera:WorldToViewportPoint(centerPos)
            local dist = myPos and (myPos - centerPos).Magnitude or 0
            local show = mz > 0 and dist < settings.maxDistance
            
            -- Box
            if d.box then
                d.box.Visible = show
                if show then
                    d.box.Color = settings.enemyColor
                    d.box.Thickness = settings.boxThickness
                    d.box.Position = Vector2.new(mx, my)
                    d.box.Size = Vector2.new(Mx - mx, My - my)
                end
            end
            
            -- Name
            if d.name then
                d.name.Visible = show
                if show then
                    d.name.Color = Color3.new(1, 1, 1)
                    d.name.Size = settings.fontSize
                    d.name.Position = Vector2.new(cs.X, my - settings.fontSize - 2)
                    d.name.Text = "Enemy"
                end
            end
            
            -- Distance
            if d.dist then
                d.dist.Visible = show
                if show then
                    d.dist.Color = Color3.new(0.8, 0.8, 0.8)
                    d.dist.Size = settings.fontSize - 1
                    d.dist.Position = Vector2.new(cs.X, My + 2)
                    d.dist.Text = string.format("%.0fm", dist * 0.28)
                end
            end
            
            -- Tracer
            if d.tracer then
                d.tracer.Visible = show
                if show then
                    d.tracer.Color = settings.enemyColor
                    d.tracer.Thickness = settings.tracerThickness
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
end

-- Simple UI
local sg = Instance.new("ScreenGui")
sg.Name = "PF_ESP"
sg.Parent = game:GetService("CoreGui")

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 170, 0, 160)
f.Position = UDim2.new(0, 10, 0.5, -80)
f.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
f.BorderSizePixel = 0
f.Active = true
f.Draggable = true
f.Parent = sg

local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, 0, 0, 22)
t.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
t.TextColor3 = Color3.fromRGB(255, 255, 255)
t.Text = "PF ESP"
t.Font = Enum.Font.GothamBold
t.TextSize = 13
t.Parent = f

local sl = Instance.new("TextLabel")
sl.Size = UDim2.new(1, -10, 0, 30)
sl.Position = UDim2.new(0, 5, 0, 25)
sl.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sl.TextColor3 = Color3.fromRGB(255, 200, 100)
sl.Text = "Teams: detecting..."
sl.TextWrapped = true
sl.Font = Enum.Font.Code
sl.TextSize = 9
sl.Parent = f

local y = 58
local toggles = {"enabled", "teamCheck", "boxes", "names", "distance", "tracers"}
local buttons = {}

for _, name in ipairs(toggles) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 18)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = settings[name] and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 0, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.Parent = f
    buttons[name] = btn
    
    btn.MouseButton1Click:Connect(function()
        settings[name] = not settings[name]
        btn.BackgroundColor3 = settings[name] and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 0, 0)
        -- Rebuild ESP if needed
        if name == "boxes" or name == "names" or name == "distance" or name == "tracers" then
            for model, _ in pairs(espCache) do removeESP(model) end
        end
    end)
    
    y = y + 20
end

-- Close button
local cb = Instance.new("TextButton")
cb.Size = UDim2.new(0, 20, 0, 20)
cb.Position = UDim2.new(1, -22, 0, 1)
cb.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
cb.TextColor3 = Color3.fromRGB(255, 255, 255)
cb.Text = "X"
cb.Font = Enum.Font.GothamBold
cb.TextSize = 12
cb.Parent = f
cb.MouseButton1Click:Connect(function()
    for _, d in pairs(espCache) do
        for _, v in pairs(d) do pcall(function() v:Remove() end) end
    end
    sg:Destroy()
end)

-- Team detection loop
task.spawn(function()
    while task.wait(2) do
        if not teamFolders.friendly then
            detectTeams()
        end
        if teamFolders.friendly then
            local ec = 0
            for _ in pairs(espCache) do ec = ec + 1 end
            sl.Text = "Friendly: " .. teamFolders.friendly .. "\nEnemy: " .. (teamFolders.enemy or "?") .. "\nShowing: " .. ec
            sl.TextColor3 = Color3.fromRGB(150, 255, 150)
        else
            sl.Text = "Teams: detecting..."
        end
    end
end)

-- Start
RunService.RenderStepped:Connect(updateESP)
