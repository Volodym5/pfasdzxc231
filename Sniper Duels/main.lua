-- ===== NEXUS.GG - ESP + AIMBOT v5 - Fixed =====
local Workspace = workspace
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

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
    
    Aimbot = {
        Enabled = true,
        Smoothness = 0.71,
        FOV = 360,
        TargetPart = "Auto",
        VisCheck = true,
        Humanize = true,
        MaxDistance = 500,
        AimDelay = 0.09,
        EasingCurve = 0.22 -- New: controls easing curve (0=linear, 1=strong ease)
    },
    
    AutoFire = {
        Enabled = false,
        Delay = 0.08,
        HitboxMultiplier = 1.5,
        VisCheck = true,
        UseAimbotTarget = true
    },
    
    FOV = {
        Show = true,
        Transparency = 0.45,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1.5
    }
}

-- Hitbox configuration
local HITBOX = {
    Sizes = {
        Head = 1.4,
        UpperTorso = 2.2,
        LowerTorso = 1.8,
        HumanoidRootPart = 2.0
    },
    Priorities = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
    IgnoreList = {
        LeftHand = true, RightHand = true, LeftFoot = true, RightFoot = true,
        LeftLowerArm = true, RightLowerArm = true, LeftLowerLeg = true, RightLowerLeg = true
    }
}

-- State
local state = {
    team = nil,
    aimbotTarget = nil,
    lastFire = 0,
    isAiming = false,
    highlightCache = {},
    aimStartTime = 0,
    humanizer = {
        lastTarget = nil,
        lastSwitch = 0,
        offset = Vector3.zero,
        nextOffsetTime = 0,
        microAdjustments = {},
        lastAdjustTime = 0,
        aimSmoothness = 0
    }
}

-- Create UI
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
    return btn
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
        elseif suffix == "ms" then
            valueLabel.Text = string.format("%.0fms", val)
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

function UI:AddDropdown(name, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 28)
    frame.Position = UDim2.new(0, 10, 0, self.contentHeight)
    frame.BackgroundTransparency = 1
    frame.Parent = self.content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 70, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(160, 160, 165)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name
    label.Parent = frame
    
    local currentIndex = table.find(options, default) or 1
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(1, -75, 1, 0)
    dropdownBtn.Position = UDim2.new(0, 75, 0, 0)
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.Text = options[currentIndex]
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.TextSize = 11
    dropdownBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
    dropdownBtn.TextXAlignment = Enum.TextXAlignment.Center
    dropdownBtn.Parent = frame
    
    dropdownBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        dropdownBtn.Text = options[currentIndex]
        callback(options[currentIndex])
    end)
    
    self.contentHeight = self.contentHeight + 28
end

-- Initialize UI
UI:Create()

UI:AddSection("visuals")
UI:AddToggle("Enable ESP", config.ESP.Enabled, function(v) config.ESP.Enabled = v end)
UI:AddToggle("Team Check", config.ESP.TeamCheck, function(v) config.ESP.TeamCheck = v end)

UI:AddSection("aimbot")
UI:AddToggle("Enable Aimbot", config.Aimbot.Enabled, function(v) config.Aimbot.Enabled = v end)
UI:AddDropdown("Target", {"Auto", "Head", "Torso"}, config.Aimbot.TargetPart, function(v) config.Aimbot.TargetPart = v end)
UI:AddSlider("Smoothness", 0, 100, config.Aimbot.Smoothness * 100, "%", function(v) config.Aimbot.Smoothness = v / 100 end)
UI:AddSlider("FOV", 10, 360, config.Aimbot.FOV, "°", function(v) config.Aimbot.FOV = v end)
UI:AddToggle("Visible Only", config.Aimbot.VisCheck, function(v) config.Aimbot.VisCheck = v end)
UI:AddToggle("Humanize", config.Aimbot.Humanize, function(v) config.Aimbot.Humanize = v end)
UI:AddSlider("Aim Delay", 0, 200, config.Aimbot.AimDelay * 1000, "ms", function(v) config.Aimbot.AimDelay = v / 1000 end)
UI:AddSlider("Easing Curve", 0, 100, config.Aimbot.EasingCurve * 100, "%", function(v) config.Aimbot.EasingCurve = v / 100 end)

UI:AddSection("auto fire")
UI:AddToggle("Enable AutoFire", config.AutoFire.Enabled, function(v) config.AutoFire.Enabled = v end)
UI:AddToggle("Use Aimbot Target", config.AutoFire.UseAimbotTarget, function(v) config.AutoFire.UseAimbotTarget = v end)
UI:AddToggle("Visible Only", config.AutoFire.VisCheck, function(v) config.AutoFire.VisCheck = v end)
UI:AddSlider("Hitbox Mult.", 1.0, 3.0, config.AutoFire.HitboxMultiplier, "x", function(v) config.AutoFire.HitboxMultiplier = v end)
UI:AddSlider("Fire Delay", 0.05, 0.5, config.AutoFire.Delay, "s", function(v) config.AutoFire.Delay = v end)

UI:AddSection("fov circle")
UI:AddToggle("Show FOV", config.FOV.Show, function(v) config.FOV.Show = v end)
UI:AddSlider("Transparency", 0, 100, config.FOV.Transparency * 100, "%", function(v) config.FOV.Transparency = v / 100 end)

-- Game Functions
local function GetTeam()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder then return nil end
    
    for _, folder in pairs(charsFolder:GetChildren()) do
        if folder:IsA("Folder") or folder:IsA("Model") then
            for _, teamFolder in pairs(folder:GetChildren()) do
                if (teamFolder.Name == "A" or teamFolder.Name == "B") then
                    for _, model in pairs(teamFolder:GetChildren()) do
                        if model == char then
                            return teamFolder.Name
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function GetHitboxRadius(part)
    return (HITBOX.Sizes[part.Name] or math.max(part.Size.X, part.Size.Y, part.Size.Z) * 0.5) * config.AutoFire.HitboxMultiplier
end

local function ScreenSpaceRadius(part)
    local distance = (Camera.CFrame.Position - part.Position).Magnitude
    local fovRad = math.rad(Camera.FieldOfView)
    local radius = (GetHitboxRadius(part) * Camera.ViewportSize.Y) / (2 * distance * math.tan(fovRad / 2))
    return math.max(radius, 6)
end

local function IsPartVisible(part, character)
    if not config.AutoFire.VisCheck then return true end
    
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
    if not result or result.Instance:IsDescendantOf(character) then
        return true
    end
    
    local halfSize = part.Size / 2
    local checks = {
        Vector3.new(halfSize.X, 0, 0),
        Vector3.new(-halfSize.X, 0, 0),
        Vector3.new(0, halfSize.Y, 0),
        Vector3.new(0, -halfSize.Y, 0),
        Vector3.new(0, 0, halfSize.Z),
        Vector3.new(0, 0, -halfSize.Z)
    }
    
    for _, offset in pairs(checks) do
        local checkPoint = part.Position + offset
        direction = checkPoint - origin
        result = Workspace:Raycast(origin, direction, rayParams)
        if not result or result.Instance:IsDescendantOf(character) then
            return true
        end
    end
    
    return false
end

local function IsTargetVisible(character, targetPos)
    if not config.Aimbot.VisCheck then return true end
    
    local myChar = LocalPlayer.Character
    local ignoreList = {character}
    if myChar then table.insert(ignoreList, myChar) end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = ignoreList
    rayParams.IgnoreWater = true
    
    local origin = Camera.CFrame.Position
    local result = Workspace:Raycast(origin, targetPos - origin, rayParams)
    
    return not result or result.Instance:IsDescendantOf(character)
end

local function GetTargetPart(character)
    if config.Aimbot.TargetPart == "Head" then
        return character:FindFirstChild("Head")
    elseif config.Aimbot.TargetPart == "Torso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("LowerTorso")
    elseif config.Aimbot.TargetPart == "Auto" then
        local center = Camera.ViewportSize / 2
        local bestPart = nil
        local bestScore = math.huge
        
        for _, partName in ipairs(HITBOX.Priorities) do
            local part = character:FindFirstChild(partName)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and screenPos.Z > 0 then
                    local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (screenPoint - center).Magnitude
                    
                    if dist < bestScore then
                        bestScore = dist
                        bestPart = part
                    end
                end
            end
        end
        
        return bestPart or character:FindFirstChild("HumanoidRootPart")
    end
    
    return character:FindFirstChild("HumanoidRootPart")
end

local function FindBestTarget()
    local center = Camera.ViewportSize / 2
    local bestTarget = nil
    local bestDistance = config.Aimbot.FOV * (Camera.ViewportSize.Y / 1080)
    
    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder then return nil end
    
    for _, folder in pairs(charsFolder:GetChildren()) do
        if folder:IsA("Folder") or folder:IsA("Model") then
            for _, teamFolder in pairs(folder:GetChildren()) do
                if teamFolder.Name == "A" or teamFolder.Name == "B" then
                    if not (config.ESP.TeamCheck and state.team and teamFolder.Name == state.team) then
                        for _, character in pairs(teamFolder:GetChildren()) do
                            if character:IsA("Model") and character ~= LocalPlayer.Character then
                                local humanoid = character:FindFirstChild("Humanoid")
                                if humanoid and humanoid.Health > 0 then
                                    local targetPart = GetTargetPart(character)
                                    if targetPart then
                                        if config.Aimbot.VisCheck and not IsTargetVisible(character, targetPart.Position) then
                                            -- skip if not visible
                                        else
                                            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                                            if onScreen and screenPos.Z > 0 then
                                                local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
                                                local dist = (screenPoint - center).Magnitude
                                                
                                                if dist < bestDistance then
                                                    bestDistance = dist
                                                    bestTarget = {
                                                        character = character,
                                                        part = targetPart,
                                                        position = targetPart.Position,
                                                        distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
                                                    }
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

local function GetCharacterHitboxes(character)
    local hitboxes = {}
    local center = Camera.ViewportSize / 2
    
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            
            if onScreen and screenPos.Z > 0 then
                local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
                local distFromCenter = (screenPoint - center).Magnitude
                
                if distFromCenter < 500 then
                    if IsPartVisible(part, character) then
                        table.insert(hitboxes, {
                            center = screenPoint,
                            radius = ScreenSpaceRadius(part),
                            distance = distFromCenter,
                            part = part
                        })
                    end
                end
            end
        end
    end
    
    table.sort(hitboxes, function(a, b) return a.distance < b.distance end)
    return hitboxes
end

local function IsCrosshairOnTarget()
    local center = Camera.ViewportSize / 2
    
    if config.AutoFire.UseAimbotTarget and state.aimbotTarget then
        local hitboxes = GetCharacterHitboxes(state.aimbotTarget.character)
        for _, hitbox in pairs(hitboxes) do
            if (center - hitbox.center).Magnitude <= hitbox.radius then
                return true
            end
        end
        return false
    end
    
    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder then return false end
    
    for _, folder in pairs(charsFolder:GetChildren()) do
        if folder:IsA("Folder") or folder:IsA("Model") then
            for _, teamFolder in pairs(folder:GetChildren()) do
                if teamFolder.Name == "A" or teamFolder.Name == "B" then
                    if not (config.ESP.TeamCheck and state.team and teamFolder.Name == state.team) then
                        for _, character in pairs(teamFolder:GetChildren()) do
                            if character:IsA("Model") and character ~= LocalPlayer.Character then
                                local humanoid = character:FindFirstChild("Humanoid")
                                if humanoid and humanoid.Health > 0 then
                                    local hitboxes = GetCharacterHitboxes(character)
                                    for _, hitbox in pairs(hitboxes) do
                                        if (center - hitbox.center).Magnitude <= hitbox.radius then
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

-- Smooth easing function that starts slow and naturally accelerates
local function SmoothEase(t, curveStrength)
    -- t is normalized time (0 to 1)
    -- curveStrength: 0 = linear, 1 = strong ease out
    if t <= 0 then return 0 end
    if t >= 1 then return 1 end
    
    -- Cubic ease out for natural movement
    local easeOut = 1 - (1 - t)^3
    
    -- Mix between linear and eased based on curveStrength
    return easeOut * curveStrength + t * (1 - curveStrength)
end

-- Advanced humanizer with realistic aim patterns
local function ApplyHumanization(aimPos, target, elapsedTime)
    if not config.Aimbot.Humanize then return aimPos end
    
    local now = tick()
    local distance = target.distance
    
    -- Target switching delay (human reaction time)
    if state.humanizer.lastTarget ~= target.character then
        if now - state.humanizer.lastSwitch < 0.1 + math.random() * 0.05 then
            return aimPos -- Still reacting
        else
            state.humanizer.lastTarget = target.character
            state.humanizer.lastSwitch = now
            state.humanizer.microAdjustments = {}
        end
    end
    
    -- Micro-adjustments (tiny cursor movements like a real player)
    if now > state.humanizer.lastAdjustTime + (math.random(40, 120) / 1000) then
        -- Random micro-movements that get smaller over time
        local adjustStrength = math.max(0.05, 0.3 * (1 - math.min(1, elapsedTime / 1.5)))
        local microX = (math.random() - 0.5) * adjustStrength * (distance / 50)
        local microY = (math.random() - 0.5) * adjustStrength * (distance / 50)
        
        table.insert(state.humanizer.microAdjustments, {
            x = microX,
            y = microY,
            time = now
        })
        
        state.humanizer.lastAdjustTime = now
    end
    
    -- Apply micro-adjustments with decay
    local totalOffset = Vector3.zero
    for i = #state.humanizer.microAdjustments, 1, -1 do
        local adj = state.humanizer.microAdjustments[i]
        local age = now - adj.time
        if age > 0.3 then
            table.remove(state.humanizer.microAdjustments, i)
        else
            local decay = 1 - (age / 0.3)
            totalOffset = totalOffset + Vector3.new(adj.x, adj.y, 0) * decay
        end
    end
    
    -- Natural aim overshoot simulation
    if elapsedTime < 0.25 and math.random() < 0.15 then
        local overshoot = Vector3.new(
            (math.random() - 0.5) * 0.8 * (1 - elapsedTime / 0.25),
            (math.random() - 0.5) * 0.8 * (1 - elapsedTime / 0.25),
            0
        )
        totalOffset = totalOffset + overshoot
    end
    
    return aimPos + totalOffset
end

local function ProcessAimbot()
    if not config.Aimbot.Enabled or not state.isAiming then
        state.aimbotTarget = nil
        state.aimStartTime = 0
        state.humanizer.aimSmoothness = 0
        return
    end
    
    local now = tick()
    
    -- Aim delay initialization
    if state.aimStartTime == 0 then
        state.aimStartTime = now
        state.humanizer.aimSmoothness = 0.01 -- Start very slow
    end
    
    local elapsed = now - state.aimStartTime
    if elapsed < config.Aimbot.AimDelay then
        return
    end
    
    local aimTime = elapsed - config.Aimbot.AimDelay
    
    local target = FindBestTarget()
    state.aimbotTarget = target
    
    if not target then
        state.humanizer.lastTarget = nil
        state.humanizer.aimSmoothness = math.max(0, state.humanizer.aimSmoothness - 0.05)
        return
    end
    
    local aimPos = target.position
    
    -- Apply humanization
    aimPos = ApplyHumanization(aimPos, target, aimTime)
    
    -- Dynamic smoothness based on distance and elapsed time
    local baseSmoothness = 1 - config.Aimbot.Smoothness
    
    -- Start very slow, then speed up (natural aim acceleration)
    local aimProgress = math.min(1, aimTime / 0.4) -- Max acceleration over 0.4 seconds
    local accelerationCurve = aimProgress^2 -- Quadratic acceleration
    
    -- Distance-based adjustment (further targets need more precise aiming)
    local distanceFactor = math.clamp(target.distance / 100, 0.6, 1.4)
    
    -- Update aim smoothness dynamically
    local targetSmoothness = baseSmoothness * (1 - accelerationCurve * 0.7) * distanceFactor
    state.humanizer.aimSmoothness = state.humanizer.aimSmoothness * 0.95 + targetSmoothness * 0.05
    
    -- Apply easing curve
    local easingStrength = config.Aimbot.EasingCurve
    local smoothFactor = SmoothEase(state.humanizer.aimSmoothness, easingStrength)
    
    -- Additional micro-adjustment factor based on distance
    if target.distance > 150 then
        smoothFactor = smoothFactor * 0.85 -- Slower for distant targets
    elseif target.distance < 30 then
        smoothFactor = smoothFactor * 1.15 -- Faster for close targets
    end
    
    local finalAlpha = math.clamp(smoothFactor, 0.008, 0.95)
    
    -- Calculate new camera position
    local lookAt = CFrame.new(Camera.CFrame.Position, aimPos)
    Camera.CFrame = Camera.CFrame:Lerp(lookAt, finalAlpha)
end

local function UpdateESP()
    if not config.ESP.Enabled then return end
    
    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder then return end
    
    local processedChars = {}
    
    for _, folder in pairs(charsFolder:GetChildren()) do
        if folder:IsA("Folder") or folder:IsA("Model") then
            for _, teamFolder in pairs(folder:GetChildren()) do
                if teamFolder.Name == "A" or teamFolder.Name == "B" then
                    local isEnemy = not config.ESP.TeamCheck or not state.team or teamFolder.Name ~= state.team
                    
                    for _, character in pairs(teamFolder:GetChildren()) do
                        if character:IsA("Model") and character ~= LocalPlayer.Character then
                            processedChars[character] = true
                            
                            local highlight = state.highlightCache[character]
                            if not highlight then
                                highlight = Instance.new("Highlight")
                                highlight.Parent = character
                                highlight.Adornee = character
                                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                state.highlightCache[character] = highlight
                            end
                            
                            highlight.FillTransparency = config.ESP.Transparency.Fill
                            highlight.OutlineTransparency = config.ESP.Transparency.Outline
                            
                            if isEnemy then
                                highlight.FillColor = config.ESP.Enemy.Fill
                                highlight.OutlineColor = config.ESP.Enemy.Outline
                                highlight.Enabled = true
                            else
                                highlight.FillColor = config.ESP.Teammate.Fill
                                highlight.OutlineColor = config.ESP.Teammate.Outline
                                highlight.Enabled = config.ESP.ShowTeammates
                            end
                        end
                    end
                end
            end
        end
    end
    
    for character, highlight in pairs(state.highlightCache) do
        if not processedChars[character] then
            pcall(function() highlight:Destroy() end)
            state.highlightCache[character] = nil
        end
    end
end

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = config.FOV.Thickness
fovCircle.Filled = false
fovCircle.NumSides = 100
fovCircle.Visible = config.FOV.Show

local function UpdateFOVCircle()
    if config.FOV.Show then
        fovCircle.Visible = true
        local dynamicFOV = config.Aimbot.FOV * (70 / Camera.FieldOfView) * (Camera.ViewportSize.Y / 1080)
        fovCircle.Radius = dynamicFOV
        fovCircle.Color = config.FOV.Color
        fovCircle.Transparency = config.FOV.Transparency
        fovCircle.Position = Camera.ViewportSize / 2
    else
        fovCircle.Visible = false
    end
end

-- Main render loop
RunService.RenderStepped:Connect(function()
    pcall(function()
        state.isAiming = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        
        if not state.isAiming then
            state.aimStartTime = 0
        end
        
        UpdateFOVCircle()
        ProcessAimbot()
        HandleAutoFire()
        UpdateESP()
    end)
end)

-- Character events
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    state.team = GetTeam()
end)

state.team = GetTeam()

-- Toggle UI with Insert key
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        UI.gui.Enabled = not UI.gui.Enabled
    end
end)
