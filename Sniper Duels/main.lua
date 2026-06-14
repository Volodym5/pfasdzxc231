-- ================
--   FULL SCRIPT
-- ================

local Workspace = workspace
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- ========================================================
-- GLOBAL SETTINGS
-- ========================================================
local Global = {
    VisCheck = true,
    TeamCheck = false
}

local config = {
    ESP = {
        Enabled = true,
        Enemy = {Fill = Color3.fromRGB(255, 60, 60), Outline = Color3.fromRGB(255, 60, 60)},
        Teammate = {Fill = Color3.fromRGB(60, 160, 255), Outline = Color3.fromRGB(60, 160, 255)},
        Transparency = {Fill = 0.75, Outline = 0.55}
    },
    
    Legit = {
        Aimbot = {
            Enabled = false,
            FOV = 120,
            Smoothness = 0.6,
            Humanize = true,
            AimDelay = 0.115,
            EasingCurve = 0.22,
            TargetPart = "Nearest",
            DynamicFOV = true
        },
        Triggerbot = {
            Enabled = false,
            Delay = 0.05,
            HitboxMultiplier = 1.2
        }
    },
    
    Rage = {
        SilentAim = {
            Enabled = false,
            FOV = 100,
            HitPart = "Nearest",
            HitChance = 100,
            DynamicFOV = true,
            FOVFollowTime = 3.0,
            FOVFollowEnabled = true,
            FOVSpawnDelay = 0.8 -- Seconds after spawn before FOV can follow
        },
        AutoShoot = {
            Enabled = false,
            Delay = 0.02,
            SpawnProtectionTime = 1.65 -- Seconds after spawn before autofire can target
        }
    },
    
    FOV = {
        Show = true,
        Transparency = 0.45,
        Color = Color3.fromRGB(255, 255, 255),
        SilentColor = Color3.fromRGB(255, 100, 100),
        Thickness = 1.5
    }
}

local state = {
    team = nil,
    silentTarget = nil,
    legitTarget = nil,
    lastTrigger = 0,
    isAiming = false,
    highlightCache = {},
    aimStartTime = 0,
    autoShootActive = false,
    silentFovTrackTarget = nil,
    silentFovTrackPart = nil,
    silentFovTrackTime = 0,
    fovTrackScreenPos = nil,
    -- Spawn times tracking (player -> spawnTime)
    spawnTimes = {},
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

-- ========================================================
-- SPAWN PROTECTION TRACKING (lightweight, per-player)
-- ========================================================
local function OnPlayerAdded(player)
    player.CharacterAdded:Connect(function(char)
        state.spawnTimes[player] = tick()
        -- Cleanup old entries when character despawns
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function()
                -- Keep spawn time until they respawn
            end)
        end
        char.AncestryChanged:Connect(function()
            if not char.Parent then
                task.delay(10, function()
                    if state.spawnTimes[player] and (not player.Character or not player.Character.Parent) then
                        state.spawnTimes[player] = nil
                    end
                end)
            end
        end)
    end)
end

-- Connect for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        OnPlayerAdded(player)
    end
end

-- Connect for new players
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        OnPlayerAdded(player)
    end
end)

-- Check if a player is spawn protected for AutoShoot (2.5s)
local function IsSpawnProtectedForShoot(player)
    local spawnTime = state.spawnTimes[player]
    if not spawnTime then return false end
    return (tick() - spawnTime) < config.Rage.AutoShoot.SpawnProtectionTime
end

-- Check if a player is spawn protected for FOV tracking (1.5s)
local function IsSpawnProtectedForFOV(player)
    local spawnTime = state.spawnTimes[player]
    if not spawnTime then return false end
    return (tick() - spawnTime) < config.Rage.SilentAim.FOVSpawnDelay
end

-- ========================================================
-- GLASS CACHE (updated every 10 seconds)
-- ========================================================
local glassParts = {}
local lastGlassUpdate = 0

local function UpdateGlassCache()
    local now = tick()
    if now - lastGlassUpdate < 10 then return end
    lastGlassUpdate = now
    
    local newGlass = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:find("Glass") then
            table.insert(newGlass, obj)
        end
    end
    glassParts = newGlass
end

-- ========================================================
-- GET TEAM
-- ========================================================
local function GetTeam()
    local char = LocalPlayer.Character
    if not char then return nil end
    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder then return nil end
    for _, folder in pairs(charsFolder:GetChildren()) do
        if folder:IsA("Folder") or folder:IsA("Model") then
            for _, teamFolder in pairs(folder:GetChildren()) do
                if teamFolder.Name == "A" or teamFolder.Name == "B" then
                    for _, model in pairs(teamFolder:GetChildren()) do
                        if model == char then return teamFolder.Name end
                    end
                end
            end
        end
    end
    return nil
end

local function IsEnemy(player)
    if not Global.TeamCheck then return true end
    if not state.team then return true end
    local char = player.Character
    if not char then return true end
    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder then return true end
    for _, folder in pairs(charsFolder:GetChildren()) do
        if folder:IsA("Folder") or folder:IsA("Model") then
            for _, teamFolder in pairs(folder:GetChildren()) do
                if teamFolder.Name == "A" or teamFolder.Name == "B" then
                    for _, model in pairs(teamFolder:GetChildren()) do
                        if model == char then return teamFolder.Name ~= state.team end
                    end
                end
            end
        end
    end
    return true
end

-- ========================================================
-- SHARED RAYCAST HELPER
-- ========================================================
local rayParams = RaycastParams.new()
rayParams.IgnoreWater = true

local function RaycastVisible(origin, target, ignoreChar)
    local ignoreList = {ignoreChar}
    if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
    for _, glass in ipairs(glassParts) do table.insert(ignoreList, glass) end
    
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = ignoreList
    
    local result = Workspace:Raycast(origin, target - origin, rayParams)
    return not result or result.Instance:IsDescendantOf(ignoreChar)
end

-- ========================================================
-- SHARED VISIBILITY CHECK
-- ========================================================
local function IsPartVisible(part, character)
    if not Global.VisCheck then return true end
    UpdateGlassCache()
    return RaycastVisible(Camera.CFrame.Position, part.Position, character)
end

-- ========================================================
-- PREDICTION CHECK - 300ms future visibility
-- ========================================================
local function WillStillBeVisible(part, character)
    local PREDICT_TIME = 0.125 -- 300ms

    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    local targetVel = part.AssemblyLinearVelocity
    local predictedTargetPos = part.Position + targetVel * PREDICT_TIME

    local predictedCameraPos = Camera.CFrame.Position
    if rootPart then
        local rootVel = rootPart.AssemblyLinearVelocity
        local flatVel = Vector3.new(rootVel.X, 0, rootVel.Z)
        predictedCameraPos = Camera.CFrame.Position + flatVel * PREDICT_TIME
    end

    local direction = predictedTargetPos - predictedCameraPos
    local distance = direction.Magnitude

    if distance < 0.5 then
        return true
    end

    UpdateGlassCache()

    local ignoreList = {character}
    if LocalPlayer.Character then
        table.insert(ignoreList, LocalPlayer.Character)
    end
    for _, glass in ipairs(glassParts) do
        table.insert(ignoreList, glass)
    end

    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = ignoreList

    local result = Workspace:Raycast(predictedCameraPos, direction, rayParams)
    if not result or result.Instance:IsDescendantOf(character) then
        return true
    end

    local currentDir = part.Position - Camera.CFrame.Position
    local currentResult = Workspace:Raycast(Camera.CFrame.Position, currentDir, rayParams)
    if not currentResult or currentResult.Instance:IsDescendantOf(character) then
        return true
    end

    return false
end

-- ========================================================
-- DYNAMIC FOV
-- ========================================================
local function GetDynamicFOV(baseFOV)
    return baseFOV * (70 / Camera.FieldOfView) * (Camera.ViewportSize.Y / 1080)
end

-- ========================================================
-- HIT PARTS
-- ========================================================
local hitParts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}

local function IsValidHitPart(partName, targetMode)
    if targetMode == "Head" then return partName == "Head" end
    if targetMode == "Torso" then return partName == "UpperTorso" or partName == "LowerTorso" end
    return true
end

-- ========================================================
-- FIND TARGET (separate spawn protection for FOV vs Shoot)
-- ========================================================
local function FindTarget(baseFOV, targetMode, checkVis, useDynamicFOV, ignoreSpawnProtected, spawnCheckFunc)
    local fov = useDynamicFOV and GetDynamicFOV(baseFOV) or baseFOV
    local best, bestDist = nil, fov
    local bestChar = nil
    local center = Camera.ViewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsEnemy(player) then continue end
        
        -- Skip spawn protected players using the provided check function
        if ignoreSpawnProtected and spawnCheckFunc and spawnCheckFunc(player) then continue end
        
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        for _, partName in ipairs(hitParts) do
            if IsValidHitPart(partName, targetMode) then
                local part = char:FindFirstChild(partName)
                if part then
                    if checkVis and not IsPartVisible(part, char) then continue end
                    local sp, vis = Camera:WorldToViewportPoint(part.Position)
                    if vis then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d < bestDist then
                            bestDist = d
                            best = part
                            bestChar = char
                        end
                    end
                end
            end
        end
    end
    
    if best and best.Name == "Head" and bestChar then
        if math.random(1, 100) <= 10 then
            local torso = bestChar:FindFirstChild("UpperTorso") or bestChar:FindFirstChild("LowerTorso")
            if torso then best = torso end
        end
    end
    
    return best, bestChar
end

-- ========================================================
-- CHECK IF CROSSHAIR IS ON ENEMY
-- ========================================================
local function IsCrosshairOnEnemy(hitboxMultiplier)
    local center = Camera.ViewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsEnemy(player) then continue end
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if Global.VisCheck then
            local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            if head and not IsPartVisible(head, char) then continue end
        end
        
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Transparency < 0.95 then
                local sp, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local radius = math.max(part.Size.X, part.Size.Y) * 0.5 * hitboxMultiplier
                    local dist = (Camera.CFrame.Position - part.Position).Magnitude
                    local fovRad = math.rad(Camera.FieldOfView)
                    local screenRadius = (radius * Camera.ViewportSize.Y) / (2 * dist * math.tan(fovRad / 2))
                    screenRadius = math.max(screenRadius, 5)
                    
                    if (Vector2.new(sp.X, sp.Y) - center).Magnitude <= screenRadius then
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- ========================================================
-- TRIGGERBOT
-- ========================================================
local function HandleTriggerbot()
    if not config.Legit.Triggerbot.Enabled then return end
    
    local now = tick()
    if now - state.lastTrigger < config.Legit.Triggerbot.Delay then return end
    
    if IsCrosshairOnEnemy(config.Legit.Triggerbot.HitboxMultiplier) then
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        state.lastTrigger = now
    end
end

-- ========================================================
-- UPDATE SILENT AIM FOV TRACKING (1.5s spawn delay for FOV)
-- ========================================================
local function UpdateSilentFOVTracking()
    -- Find target with FOV spawn protection (1.5s)
    local part, char = FindTarget(config.Rage.SilentAim.FOV, config.Rage.SilentAim.HitPart, Global.VisCheck, config.Rage.SilentAim.DynamicFOV, true, IsSpawnProtectedForFOV)
    
    if part and char then
        state.silentFovTrackTarget = char
        state.silentFovTrackPart = part
        state.silentFovTrackTime = tick()
        
        local sp, vis = Camera:WorldToViewportPoint(part.Position)
        if vis then
            state.fovTrackScreenPos = Vector2.new(sp.X, sp.Y)
        end
    elseif state.silentFovTrackTarget then
        local hum = state.silentFovTrackTarget:FindFirstChildOfClass("Humanoid")
        local isDead = not hum or hum.Health <= 0
        local isBehindWall = state.silentFovTrackPart and not IsPartVisible(state.silentFovTrackPart, state.silentFovTrackTarget)
        local timeExceeded = (tick() - state.silentFovTrackTime) > config.Rage.SilentAim.FOVFollowTime
        
        if isDead or isBehindWall or timeExceeded then
            state.silentFovTrackTarget = nil
            state.silentFovTrackPart = nil
            state.silentFovTrackTime = 0
            state.fovTrackScreenPos = nil
        elseif state.silentFovTrackPart then
            local sp, vis = Camera:WorldToViewportPoint(state.silentFovTrackPart.Position)
            if vis then
                state.fovTrackScreenPos = Vector2.new(sp.X, sp.Y)
            else
                state.fovTrackScreenPos = nil
            end
        end
    end
    
    if not config.Rage.SilentAim.FOVFollowEnabled then
        state.silentFovTrackTarget = nil
        state.silentFovTrackPart = nil
        state.silentFovTrackTime = 0
        state.fovTrackScreenPos = nil
    end
end

-- ========================================================
-- AUTO SHOOT (RAGE) - 2.5s spawn protection for shooting
-- ========================================================
local function HandleAutoShoot()
    if not config.Rage.AutoShoot.Enabled then return end
    if state.autoShootActive then return end
    
    -- Find target with AutoShoot spawn protection (2.5s)
    local target, targetChar = FindTarget(config.Rage.SilentAim.FOV, "Nearest", Global.VisCheck, config.Rage.SilentAim.DynamicFOV, true, IsSpawnProtectedForShoot)
    
    if target then
        state.autoShootActive = true
        
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        
        task.wait(config.Rage.AutoShoot.Delay)
        state.autoShootActive = false
    end
end

-- ========================================================
-- SMOOTH EASING
-- ========================================================
local function SmoothEase(t, curveStrength)
    if t <= 0 then return 0 end
    if t >= 1 then return 1 end
    local easeOut = 1 - (1 - t)^3
    return easeOut * curveStrength + t * (1 - curveStrength)
end

-- ========================================================
-- HUMANIZATION
-- ========================================================
local function ApplyHumanization(aimPos, target, elapsedTime)
    if not config.Legit.Aimbot.Humanize then return aimPos end
    
    local now = tick()
    local distance = (Camera.CFrame.Position - target.Position).Magnitude
    
    if state.humanizer.lastTarget ~= target.Parent then
        if now - state.humanizer.lastSwitch < 0.1 + math.random() * 0.05 then
            return aimPos
        else
            state.humanizer.lastTarget = target.Parent
            state.humanizer.lastSwitch = now
            state.humanizer.microAdjustments = {}
        end
    end
    
    if now > state.humanizer.lastAdjustTime + (math.random(40, 120) / 1000) then
        local adjustStrength = math.max(0.05, 0.3 * (1 - math.min(1, elapsedTime / 1.5)))
        local microX = (math.random() - 0.5) * adjustStrength * (distance / 50)
        local microY = (math.random() - 0.5) * adjustStrength * (distance / 50)
        table.insert(state.humanizer.microAdjustments, {x = microX, y = microY, time = now})
        state.humanizer.lastAdjustTime = now
    end
    
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
    
    if elapsedTime < 0.25 and math.random() < 0.15 then
        local overshoot = Vector3.new(
            (math.random() - 0.5) * 0.8 * (1 - elapsedTime / 0.25),
            (math.random() - 0.5) * 0.8 * (1 - elapsedTime / 0.25), 0)
        totalOffset = totalOffset + overshoot
    end
    
    return aimPos + totalOffset
end

-- ========================================================
-- LEGIT AIMBOT
-- ========================================================
local function ProcessLegitAimbot()
    if not config.Legit.Aimbot.Enabled or not state.isAiming then
        state.legitTarget = nil
        state.aimStartTime = 0
        state.humanizer.aimSmoothness = 0
        return
    end
    
    local now = tick()
    if state.aimStartTime == 0 then
        state.aimStartTime = now
        state.humanizer.aimSmoothness = 0.01
    end
    
    local elapsed = now - state.aimStartTime
    if elapsed < config.Legit.Aimbot.AimDelay then return end
    local aimTime = elapsed - config.Legit.Aimbot.AimDelay
    
    local part = FindTarget(config.Legit.Aimbot.FOV, config.Legit.Aimbot.TargetPart, Global.VisCheck, config.Legit.Aimbot.DynamicFOV, false, nil)
    state.legitTarget = part
    
    if not part then
        state.humanizer.lastTarget = nil
        state.humanizer.aimSmoothness = math.max(0, state.humanizer.aimSmoothness - 0.05)
        return
    end
    
    local aimPos = part.Position
    aimPos = ApplyHumanization(aimPos, part, aimTime)
    
    local distance = (Camera.CFrame.Position - part.Position).Magnitude
    local baseSmoothness = 1 - config.Legit.Aimbot.Smoothness
    local aimProgress = math.min(1, aimTime / 0.4)
    local accelerationCurve = aimProgress^2
    local distanceFactor = math.clamp(distance / 100, 0.6, 1.4)
    
    local targetSmoothness = baseSmoothness * (1 - accelerationCurve * 0.7) * distanceFactor
    state.humanizer.aimSmoothness = state.humanizer.aimSmoothness * 0.95 + targetSmoothness * 0.05
    
    local easingStrength = config.Legit.Aimbot.EasingCurve
    local smoothFactor = SmoothEase(state.humanizer.aimSmoothness, easingStrength)
    
    if distance > 150 then smoothFactor = smoothFactor * 0.85
    elseif distance < 30 then smoothFactor = smoothFactor * 1.15 end
    
    local finalAlpha = math.clamp(smoothFactor, 0.008, 0.95)
    local lookAt = CFrame.new(Camera.CFrame.Position, aimPos)
    Camera.CFrame = Camera.CFrame:Lerp(lookAt, finalAlpha)
end

-- ========================================================
-- SILENT AIM (with 300ms prediction)
-- ========================================================
local function SetupSilentAim()
    local s, gunMod = pcall(function()
        return require(ReplicatedStorage.Modules.Controllers.WeaponController.Gun)
    end)
    if not s or not gunMod then return end
    
    local uvs = {}
    s = pcall(function() uvs = {debug.getupvalues(gunMod.Fire)} end)
    if not s or not uvs[1] then return end
    
    local theTable = uvs[1]
    local fireFunc = theTable[12]
    if type(fireFunc) ~= "function" then return end
    
    local orig
    s = pcall(function()
        orig = hookfunction(fireFunc, newcclosure(function(...)
            local args = {...}
            if config.Rage.SilentAim.Enabled then
                if math.random(1, 100) <= config.Rage.SilentAim.HitChance then
                    local tgt = FindTarget(config.Rage.SilentAim.FOV, config.Rage.SilentAim.HitPart, Global.VisCheck, config.Rage.SilentAim.DynamicFOV, false, nil)
                    if tgt and WillStillBeVisible(tgt, tgt.Parent) then
                        state.silentTarget = tgt
                        args[5] = tgt.Position
                        args[6] = tgt
                    else
                        state.silentTarget = nil
                    end
                else
                    state.silentTarget = nil
                end
            end
            return orig(unpack(args))
        end))
    end)
end

pcall(SetupSilentAim)

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
        
        if IsEnemy(player) then
            highlight.FillColor = config.ESP.Enemy.Fill
            highlight.OutlineColor = config.ESP.Enemy.Outline
        else
            highlight.FillColor = config.ESP.Teammate.Fill
            highlight.OutlineColor = config.ESP.Teammate.Outline
        end
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
-- FOV CIRCLES
-- ========================================================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = config.FOV.Thickness
fovCircle.Filled = false
fovCircle.NumSides = 100
fovCircle.Visible = false

local silentFovCircle = Drawing.new("Circle")
silentFovCircle.Thickness = 1
silentFovCircle.Filled = false
silentFovCircle.NumSides = 100
silentFovCircle.Visible = false

local function UpdateFOVCircles()
    local center = Camera.ViewportSize / 2
    
    if config.FOV.Show and config.Legit.Aimbot.Enabled then
        fovCircle.Visible = true
        fovCircle.Radius = config.Legit.Aimbot.DynamicFOV and GetDynamicFOV(config.Legit.Aimbot.FOV) or config.Legit.Aimbot.FOV
        fovCircle.Color = config.FOV.Color
        fovCircle.Transparency = config.FOV.Transparency
        fovCircle.Position = center
    else
        fovCircle.Visible = false
    end
    
    if config.FOV.Show and config.Rage.SilentAim.Enabled then
        silentFovCircle.Visible = true
        silentFovCircle.Radius = config.Rage.SilentAim.DynamicFOV and GetDynamicFOV(config.Rage.SilentAim.FOV) or config.Rage.SilentAim.FOV
        silentFovCircle.Color = config.FOV.SilentColor
        silentFovCircle.Transparency = 0.5
        
        if config.Rage.SilentAim.FOVFollowEnabled and state.fovTrackScreenPos then
            silentFovCircle.Position = state.fovTrackScreenPos
        else
            silentFovCircle.Position = center
        end
    else
        silentFovCircle.Visible = false
    end
end

-- ========================================================
-- UI
-- ========================================================
local UI = {
    gui = Instance.new("ScreenGui"),
    tabs = {}
}
UI.gui.Name = HttpService:GenerateGUID(false)
UI.gui.Parent = gethui()
UI.gui.ResetOnSpawn = false
UI.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local accentColor = Color3.fromRGB(255, 70, 85)
local bgColor = Color3.fromRGB(15, 15, 20)
local bg2Color = Color3.fromRGB(22, 22, 28)
local bg3Color = Color3.fromRGB(30, 30, 38)
local textColor = Color3.fromRGB(200, 200, 210)
local textDimColor = Color3.fromRGB(130, 130, 145)

local mainFrame
local contentArea
local sliderDragging = nil
local sliderData = {}

function UI:Create()
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 520, 0, 440)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -220)
    mainFrame.BackgroundColor3 = bgColor
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = self.gui
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Thickness = 1
    mainStroke.Color = Color3.fromRGB(40, 40, 50)
    mainStroke.Parent = mainFrame
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = bg2Color
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)
    
    local titleCover = Instance.new("Frame")
    titleCover.Size = UDim2.new(1, 0, 0, 20)
    titleCover.Position = UDim2.new(0, 0, 0, 20)
    titleCover.BackgroundColor3 = bg2Color
    titleCover.BorderSizePixel = 0
    titleCover.Parent = titleBar
    
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 120, 1, 0)
    logo.Position = UDim2.new(0, 18, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "nexus"
    logo.Font = Enum.Font.GothamBold
    logo.TextSize = 18
    logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = titleBar
    
    local logoDot = Instance.new("Frame")
    logoDot.Size = UDim2.new(0, 6, 0, 6)
    logoDot.Position = UDim2.new(0, 73, 0.5, -3)
    logoDot.BackgroundColor3 = accentColor
    logoDot.BorderSizePixel = 0
    logoDot.Parent = titleBar
    Instance.new("UICorner", logoDot).CornerRadius = UDim.new(1, 0)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -38, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.TextColor3 = textDimColor
    closeBtn.Parent = titleBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    closeBtn.MouseButton1Click:Connect(function()
        self.gui.Enabled = false
    end)
    
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 34)
    tabBar.Position = UDim2.new(0, 0, 0, 40)
    tabBar.BackgroundColor3 = bg2Color
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainFrame
    
    contentArea = Instance.new("ScrollingFrame")
    contentArea.Size = UDim2.new(1, 0, 1, -84)
    contentArea.Position = UDim2.new(0, 0, 0, 74)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.ScrollBarThickness = 3
    contentArea.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentArea.ScrollingDirection = Enum.ScrollingDirection.Y
    contentArea.ElasticBehavior = Enum.ElasticBehavior.Never
    contentArea.ClipsDescendants = true
    contentArea.Parent = mainFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.Parent = contentArea
    
    local watermark = Instance.new("TextLabel")
    watermark.Size = UDim2.new(1, -20, 0, 14)
    watermark.Position = UDim2.new(0, 10, 1, -18)
    watermark.BackgroundTransparency = 1
    watermark.Text = "nexus.gg  •  " .. LocalPlayer.Name
    watermark.Font = Enum.Font.Gotham
    watermark.TextSize = 10
    watermark.TextColor3 = Color3.fromRGB(60, 60, 70)
    watermark.TextXAlignment = Enum.TextXAlignment.Right
    watermark.Parent = mainFrame
    
    self.tabBar = tabBar
    self.contentLayout = contentLayout
    self.contentHeight = 8
end

function UI:AddTab(name, icon)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 110, 1, -6)
    tabBtn.Position = UDim2.new(0, 8 + (#self.tabs * 116), 0, 3)
    tabBtn.BackgroundColor3 = bg2Color
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = icon .. "  " .. name
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 12
    tabBtn.TextColor3 = textDimColor
    tabBtn.Parent = self.tabBar
    
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
    
    local tabData = {
        btn = tabBtn,
        yOffset = 8,
        active = #self.tabs == 0
    }
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, tab in ipairs(self.tabs) do
            tab.active = false
            tab.btn.BackgroundColor3 = bg2Color
            tab.btn.TextColor3 = textDimColor
        end
        tabData.active = true
        tabBtn.BackgroundColor3 = bg3Color
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        for _, child in ipairs(contentArea:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        self.contentHeight = 8
        
        if tabData.buildFunc then
            tabData.buildFunc()
        end
        
        contentArea.CanvasSize = UDim2.new(0, 0, 0, self.contentHeight + 20)
    end)
    
    table.insert(self.tabs, tabData)
    
    if #self.tabs == 1 then
        tabBtn.BackgroundColor3 = bg3Color
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    return tabData
end

function UI:SetTabBuilder(tab, buildFunc)
    tab.buildFunc = buildFunc
end

function UI:AddSection(name)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -24, 0, 24)
    section.Position = UDim2.new(0, 12, 0, self.contentHeight)
    section.BackgroundTransparency = 1
    section.Parent = contentArea
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextColor3 = accentColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name:upper()
    label.Parent = section
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -2)
    line.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    line.BorderSizePixel = 0
    line.Parent = section
    
    self.contentHeight = self.contentHeight + 24
end

function UI:AddToggle(name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 30)
    frame.Position = UDim2.new(0, 12, 0, self.contentHeight)
    frame.BackgroundColor3 = default and bg3Color or bg2Color
    frame.BorderSizePixel = 0
    frame.Parent = contentArea
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = textColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name
    label.Parent = frame
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 36, 0, 20)
    toggle.Position = UDim2.new(1, -44, 0.5, -10)
    toggle.BackgroundColor3 = default and accentColor or Color3.fromRGB(50, 50, 58)
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = UDim2.new(0, default and 18 or 2, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = toggle
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame
    
    local enabled = default
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.BackgroundColor3 = enabled and accentColor or Color3.fromRGB(50, 50, 58)
        TweenService:Create(dot, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
            Position = UDim2.new(0, enabled and 18 or 2, 0.5, -8)
        }):Play()
        callback(enabled)
    end)
    
    self.contentHeight = self.contentHeight + 34
end

function UI:AddDropdown(name, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 30)
    frame.Position = UDim2.new(0, 12, 0, self.contentHeight)
    frame.BackgroundColor3 = bg2Color
    frame.BorderSizePixel = 0
    frame.Parent = contentArea
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 70, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = textColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name
    label.Parent = frame
    
    local currentIndex = 1
    for i, opt in ipairs(options) do if opt == default then currentIndex = i break end end
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(1, -90, 0, 24)
    dropdownBtn.Position = UDim2.new(0, 82, 0.5, -12)
    dropdownBtn.BackgroundColor3 = bg3Color
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.Text = options[currentIndex]
    dropdownBtn.Font = Enum.Font.GothamSemibold
    dropdownBtn.TextSize = 11
    dropdownBtn.TextColor3 = accentColor
    dropdownBtn.Parent = frame
    Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 4)
    
    dropdownBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        dropdownBtn.Text = options[currentIndex]
        callback(options[currentIndex])
    end)
    
    self.contentHeight = self.contentHeight + 34
end

function UI:AddSlider(name, min, max, default, suffix, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -24, 0, 40)
    frame.Position = UDim2.new(0, 12, 0, self.contentHeight)
    frame.BackgroundColor3 = bg2Color
    frame.BorderSizePixel = 0
    frame.Parent = contentArea
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 80, 0, 16)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextColor3 = textColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 16)
    valueLabel.Position = UDim2.new(1, -54, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextSize = 11
    valueLabel.TextColor3 = accentColor
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local function updateDisplay(val)
        if suffix == "%" then valueLabel.Text = string.format("%.0f%%", val)
        elseif suffix == "°" then valueLabel.Text = string.format("%.0f°", val)
        elseif suffix == "s" then valueLabel.Text = string.format("%.2fs", val)
        elseif suffix == "x" then valueLabel.Text = string.format("%.1fx", val)
        elseif suffix == "ms" then valueLabel.Text = string.format("%.0fms", val)
        else valueLabel.Text = string.format("%.1f", val) end
    end
    updateDisplay(default)
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 0, 26)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    track.BorderSizePixel = 0
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)
    
    local fill = Instance.new("Frame")
    local pct = (default - min) / (max - min)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = accentColor
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
    
    local sliderInfo = {
        track = track,
        fill = fill,
        label = valueLabel,
        min = min,
        max = max,
        suffix = suffix,
        updateDisplay = updateDisplay,
        callback = callback
    }
    sliderData[track] = sliderInfo
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 1, 0)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = track
    
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = track
            local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local value = min + relX * (max - min)
            value = math.floor(value * 100 + 0.5) / 100
            fill.Size = UDim2.new(relX, 0, 1, 0)
            updateDisplay(value)
            callback(value)
        end
    end)
    
    self.contentHeight = self.contentHeight + 44
end

UIS.InputChanged:Connect(function(input)
    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local info = sliderData[sliderDragging]
        if info then
            local track = info.track
            local mouseX = input.Position.X
            local trackX = track.AbsolutePosition.X
            local trackWidth = track.AbsoluteSize.X
            
            if math.abs(mouseX - (trackX + trackWidth / 2)) < trackWidth then
                local relX = math.clamp((mouseX - trackX) / trackWidth, 0, 1)
                local value = info.min + relX * (info.max - info.min)
                value = math.floor(value * 100 + 0.5) / 100
                info.fill.Size = UDim2.new(relX, 0, 1, 0)
                info.updateDisplay(value)
                info.callback(value)
            end
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = nil
    end
end)

-- Build UI
UI:Create()

local legitTab = UI:AddTab("Legit", "🎯")
UI:SetTabBuilder(legitTab, function()
    UI:AddSection("Global")
    UI:AddToggle("Visible Only", Global.VisCheck, function(v) Global.VisCheck = v end)
    UI:AddToggle("Team Check", Global.TeamCheck, function(v) Global.TeamCheck = v end)

    UI:AddSection("Aimbot")
    UI:AddToggle("Enabled", config.Legit.Aimbot.Enabled, function(v) config.Legit.Aimbot.Enabled = v end)
    UI:AddDropdown("Target", {"Nearest", "Head", "Torso"}, config.Legit.Aimbot.TargetPart, function(v) config.Legit.Aimbot.TargetPart = v end)
    UI:AddSlider("FOV", 10, 720, config.Legit.Aimbot.FOV, "°", function(v) config.Legit.Aimbot.FOV = v end)
    UI:AddSlider("Smoothness", 1, 100, config.Legit.Aimbot.Smoothness * 100, "%", function(v) config.Legit.Aimbot.Smoothness = v / 100 end)
    UI:AddToggle("Humanize", config.Legit.Aimbot.Humanize, function(v) config.Legit.Aimbot.Humanize = v end)
    UI:AddToggle("Dynamic FOV", config.Legit.Aimbot.DynamicFOV, function(v) config.Legit.Aimbot.DynamicFOV = v end)

    UI:AddSection("Triggerbot")
    UI:AddToggle("Enabled", config.Legit.Triggerbot.Enabled, function(v) config.Legit.Triggerbot.Enabled = v end)
    UI:AddSlider("Delay", 10, 300, config.Legit.Triggerbot.Delay * 1000, "ms", function(v) config.Legit.Triggerbot.Delay = v / 1000 end)
    UI:AddSlider("Hitbox Size", 1.0, 3.0, config.Legit.Triggerbot.HitboxMultiplier, "x", function(v) config.Legit.Triggerbot.HitboxMultiplier = v end)
end)

local rageTab = UI:AddTab("Rage", "💀")
UI:SetTabBuilder(rageTab, function()
    UI:AddSection("Silent Aim")
    UI:AddToggle("Enabled", config.Rage.SilentAim.Enabled, function(v) config.Rage.SilentAim.Enabled = v end)
    UI:AddDropdown("Target", {"Nearest", "Head", "Torso"}, config.Rage.SilentAim.HitPart, function(v) config.Rage.SilentAim.HitPart = v end)
    UI:AddSlider("FOV", 10, 1000, config.Rage.SilentAim.FOV, "°", function(v) config.Rage.SilentAim.FOV = v end)
    UI:AddSlider("Hit Chance", 0, 100, config.Rage.SilentAim.HitChance, "%", function(v) config.Rage.SilentAim.HitChance = v end)
    UI:AddToggle("Dynamic FOV", config.Rage.SilentAim.DynamicFOV, function(v) config.Rage.SilentAim.DynamicFOV = v end)
    UI:AddToggle("FOV Follow Target", config.Rage.SilentAim.FOVFollowEnabled, function(v) config.Rage.SilentAim.FOVFollowEnabled = v end)
    UI:AddSlider("Follow Time", 0.5, 5.0, config.Rage.SilentAim.FOVFollowTime, "s", function(v) config.Rage.SilentAim.FOVFollowTime = v end)
    UI:AddSlider("FOV Spawn Delay", 0, 3, config.Rage.SilentAim.FOVSpawnDelay, "s", function(v) config.Rage.SilentAim.FOVSpawnDelay = v end)

    UI:AddSection("Auto Shoot")
    UI:AddToggle("Enabled", config.Rage.AutoShoot.Enabled, function(v) config.Rage.AutoShoot.Enabled = v end)
    UI:AddSlider("Delay", 0, 500, config.Rage.AutoShoot.Delay * 1000, "ms", function(v) config.Rage.AutoShoot.Delay = v / 1000 end)
    UI:AddSlider("Spawn Protect", 0, 5, config.Rage.AutoShoot.SpawnProtectionTime, "s", function(v) config.Rage.AutoShoot.SpawnProtectionTime = v end)
end)

local visualsTab = UI:AddTab("Visuals", "👁️")
UI:SetTabBuilder(visualsTab, function()
    UI:AddSection("ESP")
    UI:AddToggle("Enabled", config.ESP.Enabled, function(v) config.ESP.Enabled = v end)

    UI:AddSection("FOV Circle")
    UI:AddToggle("Show", config.FOV.Show, function(v) config.FOV.Show = v end)
end)

if UI.tabs[1] and UI.tabs[1].buildFunc then
    UI.tabs[1].buildFunc()
    contentArea.CanvasSize = UDim2.new(0, 0, 0, UI.contentHeight + 20)
end

-- ========================================================
-- RENDER LOOP
-- ========================================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        state.isAiming = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if not state.isAiming then state.aimStartTime = 0 end
        UpdateSilentFOVTracking()
        UpdateFOVCircles()
        ProcessLegitAimbot()
        HandleTriggerbot()
        HandleAutoShoot()
        UpdateESP()
    end)
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    state.team = GetTeam()
end)
state.team = GetTeam()

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        UI.gui.Enabled = not UI.gui.Enabled
    end
end)
