-- ========================================================
-- FULL CHEAT - ESP + SILENT AIM + AUTOFIRE + FOV + UI
-- ========================================================

local Workspace = workspace
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local config = {
    ESP = {
        Enabled = true,
        TeamCheck = false,
        ShowTeammates = false,
        Enemy = {Fill = Color3.fromRGB(255, 60, 60), Outline = Color3.fromRGB(255, 60, 60)},
        Teammate = {Fill = Color3.fromRGB(60, 160, 255), Outline = Color3.fromRGB(60, 160, 255)},
        Transparency = {Fill = 0.75, Outline = 0.55},
        MaxDistance = 500
    },
    
    SilentAim = {
        Enabled = false,
        FOV = 100,
        HitPart = "Head",
        VisCheck = true
    },
    
    AutoFire = {
        Enabled = false,
        Delay = 0.08,
        HitboxMultiplier = 1.5,
        VisCheck = true,
        UseSilentTarget = true
    },
    
    FOV = {
        Show = true,
        Transparency = 0.45,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1.5
    }
}

-- State
local state = {
    team = nil,
    silentTarget = nil,
    lastFire = 0,
    isAiming = false,
    highlightCache = {}
}

-- ========================================================
-- UI
-- ========================================================
local UI = {
    gui = Instance.new("ScreenGui"),
    isOpen = false
}
UI.gui.Name = HttpService:GenerateGUID(false)
UI.gui.Parent = gethui()
UI.gui.ResetOnSpawn = false
UI.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

function UI:Create()
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 230, 0, 35)
    main.Position = UDim2.new(0.5, -115, 0, 80)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = self.gui
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    header.BorderSizePixel = 0
    header.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -45, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(220, 220, 225)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "nexus.gg"
    title.Parent = header
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 35)
    content.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    content.BorderSizePixel = 0
    content.ClipsDescendants = true
    content.Parent = main
    
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -32, 0, 2)
    close.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    close.BorderSizePixel = 0
    close.Text = "×"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 18
    close.TextColor3 = Color3.fromRGB(200, 200, 205)
    close.Parent = header
    
    self.content = content
    self.main = main
    self.contentHeight = 0
    
    close.MouseButton1Click:Connect(function()
        self.isOpen = not self.isOpen
        if self.isOpen then
            content.Size = UDim2.new(1, 0, 0, self.contentHeight)
            main.Size = UDim2.new(0, 230, 0, 35 + self.contentHeight)
        else
            content.Size = UDim2.new(1, 0, 0, 0)
            main.Size = UDim2.new(0, 230, 0, 35)
        end
    end)
end

function UI:AddSection(name)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 24)
    section.Position = UDim2.new(0, 10, 0, self.contentHeight)
    section.BackgroundTransparency = 1
    section.Parent = self.content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextColor3 = Color3.fromRGB(140, 140, 150)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name:upper()
    label.Parent = section
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, 0)
    line.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    line.BorderSizePixel = 0
    line.Parent = section
    
    self.contentHeight = self.contentHeight + 24
end

function UI:AddToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 28)
    frame.Position = UDim2.new(0, 10, 0, self.contentHeight)
    frame.BackgroundTransparency = 1
    frame.Parent = self.content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(160, 160, 165)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name
    label.Parent = frame
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 30, 0, 16)
    toggle.Position = UDim2.new(1, -30, 0.5, -8)
    toggle.BackgroundColor3 = default and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(50, 50, 55)
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new(0, default and 14 or 2, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = toggle
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame
    
    local enabled = default
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(50, 50, 55)
        dot.Position = UDim2.new(0, enabled and 14 or 2, 0.5, -7)
        callback(enabled)
    end)
    
    self.contentHeight = self.contentHeight + 28
end

function UI:AddSlider(name, min, max, default, suffix, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.Position = UDim2.new(0, 10, 0, self.contentHeight)
    frame.BackgroundTransparency = 1
    frame.Parent = self.content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 90, 0, 14)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(160, 160, 165)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 14)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 10
    valueLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local function updateDisplay(val)
        if suffix == "%" then
            valueLabel.Text = string.format("%.0f%%", val)
        elseif suffix == "x" then
            valueLabel.Text = string.format("%.1fx", val)
        elseif suffix == "s" then
            valueLabel.Text = string.format("%.2fs", val)
        elseif suffix == "°" then
            valueLabel.Text = string.format("%.0f°", val)
        else
            valueLabel.Text = string.format("%.0f", val) .. (suffix or "")
        end
    end
    
    updateDisplay(default)
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 22)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    track.BorderSizePixel = 0
    track.Parent = frame
    
    local fill = Instance.new("Frame")
    local pct = (default - min) / (max - min)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(1, 0, 1, 0)
    slider.BackgroundTransparency = 1
    slider.Text = ""
    slider.Parent = track
    
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    slider.MouseMoved:Connect(function(x, y)
        if dragging then
            local relX = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = min + relX * (max - min)
            value = math.floor(value * 100 + 0.5) / 100
            fill.Size = UDim2.new(relX, 0, 1, 0)
            updateDisplay(value)
            callback(value)
        end
    end)
    
    self.contentHeight = self.contentHeight + 35
end

-- Initialize UI
UI:Create()

UI:AddSection("visuals")
UI:AddToggle("Enable ESP", config.ESP.Enabled, function(v) config.ESP.Enabled = v end)

UI:AddSection("silent aim")
UI:AddToggle("Enable Silent Aim", config.SilentAim.Enabled, function(v) config.SilentAim.Enabled = v end)
UI:AddSlider("FOV", 10, 300, config.SilentAim.FOV, "°", function(v) config.SilentAim.FOV = v end)
UI:AddToggle("Visible Only", config.SilentAim.VisCheck, function(v) config.SilentAim.VisCheck = v end)

UI:AddSection("auto fire")
UI:AddToggle("Enable AutoFire", config.AutoFire.Enabled, function(v) config.AutoFire.Enabled = v end)
UI:AddSlider("Fire Delay", 0.05, 0.5, config.AutoFire.Delay, "s", function(v) config.AutoFire.Delay = v end)

UI:AddSection("fov circle")
UI:AddToggle("Show FOV", config.FOV.Show, function(v) config.FOV.Show = v end)

-- ========================================================
-- VISIBILITY CHECK
-- ========================================================
local function IsPartVisible(part, character)
    local myChar = LocalPlayer.Character
    local ignoreList = {character}
    if myChar then table.insert(ignoreList, myChar) end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = ignoreList
    rayParams.IgnoreWater = true
    
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    
    local result = Workspace:Raycast(origin, direction, rayParams)
    return not result or result.Instance:IsDescendantOf(character)
end

-- ========================================================
-- FIND TARGET FOR SILENT AIM
-- ========================================================
local function FindSilentTarget()
    local best, bestDist = nil, config.SilentAim.FOV
    local center = Camera.ViewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        if not char then continue end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hp = char:FindFirstChild(config.SilentAim.HitPart)
        
        if not hp or not hum or hum.Health <= 0 then continue end
        
        if config.SilentAim.VisCheck and not IsPartVisible(hp, char) then continue end
        
        local sp, vis = Camera:WorldToViewportPoint(hp.Position)
        if not vis then continue end
        
        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if d < bestDist then
            bestDist = d
            best = hp
        end
    end
    
    return best
end

-- ========================================================
-- SILENT AIM - Hook table[12]
-- ========================================================
local gunMod = require(ReplicatedStorage.Modules.Controllers.WeaponController.Gun)
local uvs = {debug.getupvalues(gunMod.Fire)}
local theTable = uvs[1]
local fireFunc = theTable[12]

if fireFunc and type(fireFunc) == "function" then
    local orig = hookfunction(fireFunc, newcclosure(function(...)
        local args = {...}
        
        if config.SilentAim.Enabled then
            local tgt = FindSilentTarget()
            if tgt then
                state.silentTarget = tgt
                args[5] = tgt.Position
                args[6] = tgt
            else
                state.silentTarget = nil
            end
        end
        
        return orig(unpack(args))
    end))
    print("✅ Silent aim hooked")
else
    print("❌ Silent aim hook failed")
end

-- ========================================================
-- AUTO FIRE
-- ========================================================
local function IsCrosshairOnTarget()
    local center = Camera.ViewportSize / 2
    
    if config.AutoFire.UseSilentTarget and state.silentTarget then
        local part = state.silentTarget
        local char = part.Parent
        if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
            local sp, vis = Camera:WorldToViewportPoint(part.Position)
            if vis then
                local hitboxRadius = math.max(part.Size.X, part.Size.Y, part.Size.Z) * 0.5 * config.AutoFire.HitboxMultiplier
                local distance = (Camera.CFrame.Position - part.Position).Magnitude
                local fovRad = math.rad(Camera.FieldOfView)
                local screenRadius = (hitboxRadius * Camera.ViewportSize.Y) / (2 * distance * math.tan(fovRad / 2))
                screenRadius = math.max(screenRadius, 8)
                
                if (Vector2.new(sp.X, sp.Y) - center).Magnitude <= screenRadius then
                    return true
                end
            end
        end
    end
    
    return false
end

local function HandleAutoFire()
    if not config.AutoFire.Enabled or not state.isAiming then return end
    
    local now = tick()
    if now - state.lastFire < config.AutoFire.Delay then return end
    
    if IsCrosshairOnTarget() then
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.03)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        state.lastFire = now
    end
end

-- ========================================================
-- ESP
-- ========================================================
local function UpdateESP()
    if not config.ESP.Enabled then
        for _, highlight in pairs(state.highlightCache) do
            pcall(function() highlight:Destroy() end)
        end
        state.highlightCache = {}
        return
    end
    
    local processed = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        processed[char] = true
        
        local highlight = state.highlightCache[char]
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Parent = char
            highlight.Adornee = char
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            state.highlightCache[char] = highlight
        end
        
        highlight.FillTransparency = config.ESP.Transparency.Fill
        highlight.OutlineTransparency = config.ESP.Transparency.Outline
        highlight.FillColor = config.ESP.Enemy.Fill
        highlight.OutlineColor = config.ESP.Enemy.Outline
        highlight.Enabled = true
    end
    
    for char, highlight in pairs(state.highlightCache) do
        if not processed[char] then
            pcall(function() highlight:Destroy() end)
            state.highlightCache[char] = nil
        end
    end
end

-- ========================================================
-- FOV CIRCLE
-- ========================================================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = config.FOV.Thickness
fovCircle.Filled = false
fovCircle.NumSides = 100
fovCircle.Visible = false

local function UpdateFOVCircle()
    fovCircle.Visible = config.FOV.Show and config.SilentAim.Enabled
    fovCircle.Radius = config.SilentAim.FOV
    fovCircle.Color = config.FOV.Color
    fovCircle.Transparency = config.FOV.Transparency
    fovCircle.Position = Camera.ViewportSize / 2
end

-- ========================================================
-- RENDER LOOP
-- ========================================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        state.isAiming = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        
        UpdateFOVCircle()
        HandleAutoFire()
        UpdateESP()
    end)
end)

-- ========================================================
-- TOGGLE UI
-- ========================================================
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        UI.gui.Enabled = not UI.gui.Enabled
    end
end)

print("========================================")
print("LOADED - Insert = Menu | Right Click = Aim")
print("Silent Aim: table[12] method")
print("========================================")
