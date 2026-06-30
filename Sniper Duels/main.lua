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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")

-- Load UI library
local success = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/lib/source.lua"))()
end)

if not success or not getgenv().Library then
    warn("Failed to load UI library")
    return
end

local Library = getgenv().Library
local SaveManager = Library.SaveManager
local ThemeManager = Library.ThemeManager

SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()

-- ========================================================
-- EXECUTOR DETECTION
-- ========================================================
local executorName = "Unknown"
pcall(function() executorName = identifyexecutor() end)
local isXeno = (executorName:lower():find("xeno") ~= nil)
local silentAimDisabled = isXeno

if isXeno then
    Library:Notify(string.format("⚠️ Xeno detected - Silent Aim disabled to avoid detection"), 4)
end

-- ========================================================
-- GLOBAL SETTINGS
-- ========================================================
local Global = {
    Legit = {
        VisCheck = false,
        TeamCheck = false
    },
    Rage = {
        TeamCheck = false
    },
    ESP = {
        TeamCheck = false
    }
}

local config = {
    ESP = {
        Enabled = false,
        Enemy = {Fill = Color3.fromRGB(255, 60, 60), Outline = Color3.fromRGB(255, 60, 60)},
        Teammate = {Fill = Color3.fromRGB(60, 160, 255), Outline = Color3.fromRGB(60, 160, 255)},
        Transparency = {Fill = 0.75, Outline = 0.55}
    },
    
    Legit = {
        SilentAim = {
            Enabled = false,
            FOV = 212,
            HitPart = "Nearest",
            HitChance = 100,
            DynamicFOV = false,
            FOVFollowTime = 3.0,
            FOVFollowEnabled = false,
            FOVSpawnDelay = 0.8
        },
        Aimbot = {
            Enabled = false,
            FOV = 333,
            Smoothness = 0.6,
            Humanize = false,
            AimDelay = 0.115,
            EasingCurve = 0.22,
            TargetPart = "Nearest",
            DynamicFOV = false
        },
        Triggerbot = {
            Enabled = false,
            Delay = 0.05,
            HitboxMultiplier = 1.2
        }
    },
    
    Rage = {
        Enabled = false,
        FOV = 300,
        HitPart = "Head",
        DynamicFOV = false,
        ShootDelay = 0.01,
        SpawnProtectionTime = 2.5,
        AutoShoot = false,
        AutoScope = false,
        ScopeDelay = 0.05,
        HitboxMultiplier = 1.2,
        DynamicPrediction = false,
        PingUpdateInterval = 0.1
    },
    
    FOV = {
        Show = false,
        Transparency = 0.45,
        Color = Color3.fromRGB(255, 255, 255),
        SilentColor = Color3.fromRGB(255, 100, 100),
        Thickness = 1.5
    },
    
    Movement = {
        WalkSpeed = {
            Enabled = false,
            Speed = 40
        },
        AirJump = {
            Enabled = false
        },
        Gravity = {
            Enabled = false,
            Value = 0.5
        }
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
    rageActive = false,
    rageLastFire = 0,
    rageScoped = false,
    silentFovTrackTarget = nil,
    silentFovTrackPart = nil,
    silentFovTrackTime = 0,
    fovTrackScreenPos = nil,
    spawnTimes = {},
    originalGravity = Workspace.Gravity,
    currentPing = 0,
    dynamicPrediction = 0.05,
    lastPingUpdate = 0,
    humanizer = {
        lastTarget = nil,
        lastSwitch = 0,
        offset = Vector3.zero,
        nextOffsetTime = 0,
        microAdjustments = {},
        lastAdjustTime = 0,
        aimSmoothness = 0
    },
    hrpHistory = {},
    silentAimHooked = false
}

-- ========================================================
-- SPAWN PROTECTION TRACKING
-- ========================================================
local function OnPlayerAdded(player)
    player.CharacterAdded:Connect(function(char)
        state.spawnTimes[player] = tick()
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then hum.Died:Connect(function() end) end
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

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then OnPlayerAdded(player) end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then OnPlayerAdded(player) end
end)

local function IsSpawnProtected(player)
    local spawnTime = state.spawnTimes[player]
    if not spawnTime then return false end
    return (tick() - spawnTime) < config.Rage.SpawnProtectionTime
end

local function IsSpawnProtectedForFOV(player)
    local spawnTime = state.spawnTimes[player]
    if not spawnTime then return false end
    return (tick() - spawnTime) < config.Legit.SilentAim.FOVSpawnDelay
end

-- ========================================================
-- DYNAMIC PING TRACKING
-- ========================================================
local function UpdatePing()
    local now = tick()
    if now - state.lastPingUpdate < config.Rage.PingUpdateInterval then return end
    state.lastPingUpdate = now
    
    pcall(function()
        local perfStats = Stats:FindFirstChild("PerformanceStats")
        if perfStats then
            local ping = perfStats:FindFirstChild("Ping")
            if ping then state.currentPing = ping:GetValue() end
        end
    end)
    
    if config.Rage.DynamicPrediction then
        state.dynamicPrediction = math.clamp((state.currentPing / 1000) * 1.2, 0.03, 0.2)
    end
end

-- ========================================================
-- GLASS CACHE
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

local function IsEnemy(player, teamCheck)
    if not teamCheck then return true end
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

local function IsPositionVisible(position, character)
    UpdateGlassCache()
    local ignoreList = {character}
    if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
    for _, glass in ipairs(glassParts) do table.insert(ignoreList, glass) end
    
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = ignoreList
    
    local origin = Camera.CFrame.Position + Camera.CFrame.LookVector * 0.1
    local direction = position - origin
    local result = Workspace:Raycast(origin, direction, rayParams)
    return not result or result.Instance:IsDescendantOf(character)
end

local function IsPartVisible(part, character, visCheck)
    if not visCheck then return true end
    return IsPositionVisible(part.Position, character)
end

-- ========================================================
-- FOOLPROOF PREDICTION
-- ========================================================
local function GetPredictedPosition(part, character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return part.Position end
    
    local currentPos = part.Position
    local hrpPos = hrp.Position
    local now = tick()
    
    if not state.hrpHistory[character] then
        state.hrpHistory[character] = {
            lastPos = hrpPos,
            lastTime = now,
            smoothedVel = Vector3.zero
        }
        return IsPositionVisible(currentPos, character) and currentPos or nil
    end
    
    local history = state.hrpHistory[character]
    local dt = now - history.lastTime
    
    if dt < 0.016 then
        local vel = history.smoothedVel
        if vel.Magnitude < 1 then
            return IsPositionVisible(currentPos, character) and currentPos or nil
        end
        
        local predictionTime = math.clamp(state.currentPing / 1000 * 1.2, 0.03, 0.2)
        local offset = part.Position - hrpPos
        local predictedHRP = hrpPos + (vel * predictionTime)
        local predictedPos = predictedHRP + offset
        
        if IsPositionVisible(predictedPos, character) then return predictedPos end
        if IsPositionVisible(currentPos, character) then return currentPos end
        return nil
    end
    
    local rawVel = (hrpPos - history.lastPos) / dt
    local horizontalVel = Vector3.new(rawVel.X, 0, rawVel.Z)
    local smoothedVel = history.smoothedVel * 0.9 + horizontalVel * 0.1
    
    if math.abs(rawVel.Y) > 5 then
        smoothedVel = Vector3.new(smoothedVel.X, rawVel.Y, smoothedVel.Z)
    end
    
    history.lastPos = hrpPos
    history.lastTime = now
    history.smoothedVel = smoothedVel
    
    if smoothedVel.Magnitude < 1 then
        return IsPositionVisible(currentPos, character) and currentPos or nil
    end
    
    local predictionTime = math.clamp(state.currentPing / 1000 * 1.2, 0.03, 0.2)
    local offset = part.Position - hrpPos
    local predictedHRP = hrpPos + (smoothedVel * predictionTime)
    local predictedPos = predictedHRP + offset
    
    if IsPositionVisible(predictedPos, character) then return predictedPos end
    if IsPositionVisible(currentPos, character) then return currentPos end
    return nil
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
-- FIND TARGET (Legit)
-- ========================================================
local function FindTargetLegit(baseFOV, targetMode, visCheck, teamCheck, useDynamicFOV)
    local fov = useDynamicFOV and GetDynamicFOV(baseFOV) or baseFOV
    local best, bestDist = nil, fov
    local bestChar = nil
    local center = Camera.ViewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsEnemy(player, teamCheck) then continue end
        
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        for _, partName in ipairs(hitParts) do
            if IsValidHitPart(partName, targetMode) then
                local part = char:FindFirstChild(partName)
                if part then
                    if not IsPartVisible(part, char, visCheck) then continue end
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
-- FIND BEST RAGE TARGET
-- ========================================================
local function FindBestRageTarget(baseFOV, targetMode, teamCheck, useDynamicFOV)
    local fov = useDynamicFOV and GetDynamicFOV(baseFOV) or baseFOV
    local best, bestDist = nil, fov
    local bestPlayer = nil
    local bestPart = nil
    local center = Camera.ViewportSize / 2
    local hitboxMult = config.Rage.HitboxMultiplier
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsEnemy(player, teamCheck) then continue end
        if IsSpawnProtected(player) then continue end
        
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        local partsToCheck = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}
        
        for _, partName in ipairs(partsToCheck) do
            local part = char:FindFirstChild(partName)
            if part and IsPartVisible(part, char, true) then
                local predictedPos = GetPredictedPosition(part, char)
                if predictedPos then
                    local sp, vis = Camera:WorldToViewportPoint(predictedPos)
                    if vis then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude / hitboxMult
                        
                        if targetMode == "Head" and partName == "Head" then
                            d = d * 0.3
                        elseif targetMode == "Torso" and (partName == "UpperTorso" or partName == "LowerTorso") then
                            d = d * 0.5
                        elseif targetMode == "Nearest" then
                            -- no bonus
                        else
                            d = d * 2.0
                        end
                        
                        if d < bestDist then
                            bestDist = d
                            bestPart = part
                            bestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return bestPart, bestPlayer
end

-- ========================================================
-- TRIGGERBOT
-- ========================================================
local function HandleTriggerbot()
    if not config.Legit.Triggerbot.Enabled then return end
    
    local now = tick()
    if now - state.lastTrigger < config.Legit.Triggerbot.Delay then return end
    
    local center = Camera.ViewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsEnemy(player, Global.Legit.TeamCheck) then continue end
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if Global.Legit.VisCheck then
            local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            if head and not IsPartVisible(head, char, true) then continue end
        end
        
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Transparency < 0.95 then
                local sp, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local radius = math.max(part.Size.X, part.Size.Y) * 0.5 * config.Legit.Triggerbot.HitboxMultiplier
                    local dist = (Camera.CFrame.Position - part.Position).Magnitude
                    local fovRad = math.rad(Camera.FieldOfView)
                    local screenRadius = (radius * Camera.ViewportSize.Y) / (2 * dist * math.tan(fovRad / 2))
                    screenRadius = math.max(screenRadius, 5)
                    
                    if (Vector2.new(sp.X, sp.Y) - center).Magnitude <= screenRadius then
                        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.02)
                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        state.lastTrigger = now
                        return
                    end
                end
            end
        end
    end
end

-- ========================================================
-- UPDATE SILENT AIM FOV TRACKING
-- ========================================================
local function UpdateSilentFOVTracking()
    local part, char = FindTargetLegit(config.Legit.SilentAim.FOV, config.Legit.SilentAim.HitPart, Global.Legit.VisCheck, Global.Legit.TeamCheck, config.Legit.SilentAim.DynamicFOV)
    
    if part and char then
        state.silentFovTrackTarget = char
        state.silentFovTrackPart = part
        state.silentFovTrackTime = tick()
        
        local sp, vis = Camera:WorldToViewportPoint(part.Position)
        if vis then state.fovTrackScreenPos = Vector2.new(sp.X, sp.Y) end
    elseif state.silentFovTrackTarget then
        local hum = state.silentFovTrackTarget:FindFirstChildOfClass("Humanoid")
        local isDead = not hum or hum.Health <= 0
        local isBehindWall = state.silentFovTrackPart and not IsPartVisible(state.silentFovTrackPart, state.silentFovTrackTarget, Global.Legit.VisCheck)
        local timeExceeded = (tick() - state.silentFovTrackTime) > config.Legit.SilentAim.FOVFollowTime
        
        if isDead or isBehindWall or timeExceeded then
            state.silentFovTrackTarget = nil
            state.silentFovTrackPart = nil
            state.silentFovTrackTime = 0
            state.fovTrackScreenPos = nil
        elseif state.silentFovTrackPart then
            local sp, vis = Camera:WorldToViewportPoint(state.silentFovTrackPart.Position)
            if vis then state.fovTrackScreenPos = Vector2.new(sp.X, sp.Y) else state.fovTrackScreenPos = nil end
        end
    end
    
    if not config.Legit.SilentAim.FOVFollowEnabled then
        state.silentFovTrackTarget = nil
        state.silentFovTrackPart = nil
        state.silentFovTrackTime = 0
        state.fovTrackScreenPos = nil
    end
end

-- ========================================================
-- RAGEBOT
-- ========================================================
local function HandleRagebot()
    if not config.Rage.Enabled then
        state.rageActive = false
        state.silentTarget = nil
        return
    end
    
    state.rageActive = true
    local now = tick()
    
    UpdatePing()
    
    local bestPart, bestPlayer = FindBestRageTarget(config.Rage.FOV, config.Rage.HitPart, Global.Rage.TeamCheck, config.Rage.DynamicFOV)
    
    if not bestPart or not bestPlayer then
        state.silentTarget = nil
        return
    end
    
    state.silentTarget = bestPart
    
    if config.Rage.AutoShoot then
        if now - state.rageLastFire > config.Rage.ShootDelay then
            
            if config.Rage.AutoScope and not state.isAiming then
                VIM:SendMouseButtonEvent(1, 0, 0, true, game, 0)
                state.rageScoped = true
            end
            
            if state.rageScoped then
                task.wait(config.Rage.ScopeDelay)
            end
            
            state.rageLastFire = now
            
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            
            if state.rageScoped then
                task.wait(0.05)
                VIM:SendMouseButtonEvent(1, 0, 0, false, game, 0)
                state.rageScoped = false
            end
        end
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
        if now - state.humanizer.lastSwitch < 0.1 + math.random() * 0.05 then return aimPos
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
        if age > 0.3 then table.remove(state.humanizer.microAdjustments, i)
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
    
    local part = FindTargetLegit(config.Legit.Aimbot.FOV, config.Legit.Aimbot.TargetPart, Global.Legit.VisCheck, Global.Legit.TeamCheck, config.Legit.Aimbot.DynamicFOV)
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
    
    if distance > 150 then smoothFactor = smoothFactor * 0.85 elseif distance < 30 then smoothFactor = smoothFactor * 1.15 end
    
    local finalAlpha = math.clamp(smoothFactor, 0.008, 0.95)
    local lookAt = CFrame.new(Camera.CFrame.Position, aimPos)
    Camera.CFrame = Camera.CFrame:Lerp(lookAt, finalAlpha)
end

-- ========================================================
-- SILENT AIM HOOK (DISABLED ON XENO)
-- ========================================================
local silentAimOrig = nil

local function EnableSilentAim()
    if state.silentAimHooked then return end
    if silentAimDisabled then return end
    
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
    
    s = pcall(function()
        silentAimOrig = hookfunction(fireFunc, newcclosure(function(...)
            local args = {...}
            
            if config.Rage.Enabled and state.silentTarget then
                local tgt = state.silentTarget
                if tgt and tgt.Parent then
                    local char = tgt.Parent
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local predictedPos = GetPredictedPosition(tgt, char)
                        if predictedPos then
                            args[5] = predictedPos
                            args[6] = tgt
                            return silentAimOrig(unpack(args))
                        end
                    end
                end
            end
            
            if config.Legit.SilentAim.Enabled and not config.Rage.Enabled then
                if math.random(1, 100) <= config.Legit.SilentAim.HitChance then
                    local tgt = FindTargetLegit(config.Legit.SilentAim.FOV, config.Legit.SilentAim.HitPart, Global.Legit.VisCheck, Global.Legit.TeamCheck, config.Legit.SilentAim.DynamicFOV)
                    if tgt then
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
            
            return silentAimOrig(unpack(args))
        end))
    end)
    
    if s then state.silentAimHooked = true end
end

local function CheckAndHookSilentAim()
    if silentAimDisabled then return end
    if (config.Legit.SilentAim.Enabled or config.Rage.Enabled) and not state.silentAimHooked then
        EnableSilentAim()
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
        
        if IsEnemy(player, Global.ESP.TeamCheck) then
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
    
    if config.FOV.Show and config.Legit.Aimbot.Enabled and not config.Rage.Enabled then
        fovCircle.Visible = true
        fovCircle.Radius = config.Legit.Aimbot.DynamicFOV and GetDynamicFOV(config.Legit.Aimbot.FOV) or config.Legit.Aimbot.FOV
        fovCircle.Color = config.FOV.Color
        fovCircle.Transparency = config.FOV.Transparency
        fovCircle.Position = center
    else
        fovCircle.Visible = false
    end
    
    if config.FOV.Show and config.Legit.SilentAim.Enabled and not config.Rage.Enabled then
        silentFovCircle.Visible = true
        silentFovCircle.Radius = config.Legit.SilentAim.DynamicFOV and GetDynamicFOV(config.Legit.SilentAim.FOV) or config.Legit.SilentAim.FOV
        silentFovCircle.Color = config.FOV.SilentColor
        silentFovCircle.Transparency = 0.5
        
        if config.Legit.SilentAim.FOVFollowEnabled and state.fovTrackScreenPos then
            silentFovCircle.Position = state.fovTrackScreenPos
        else
            silentFovCircle.Position = center
        end
    else
        silentFovCircle.Visible = false
    end
end

-- ========================================================
-- MOVEMENT SYSTEM
-- ========================================================
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not config.Movement.AirJump.Enabled then return end
    
    if input.KeyCode == Enum.KeyCode.Space then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if hum.FloorMaterial == Enum.Material.Air then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if config.Movement.Gravity.Enabled then
            Workspace.Gravity = state.originalGravity * config.Movement.Gravity.Value
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if config.Movement.WalkSpeed.Enabled then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    hum.WalkSpeed = config.Movement.WalkSpeed.Speed
                end
            end
        end
    end
end)

task.spawn(function()
    local wasEnabled = false
    while true do
        task.wait(1)
        if not config.Movement.Gravity.Enabled and wasEnabled then
            Workspace.Gravity = state.originalGravity
        end
        wasEnabled = config.Movement.Gravity.Enabled
    end
end)

-- ========================================================
-- CREATE UI WINDOW
-- ========================================================
local Window = Library:CreateWindow({
    Title         = "Sniper Duels",
    Size          = UDim2.fromOffset(660, 580),
    Center        = true,
    AutoShow      = true,
    ToggleKeybind = Enum.KeyCode.RightShift,
    ConfigFolder  = "Sniper Duels"
})

-- ========================================================
-- LEGIT TAB
-- ========================================================
local LegitTab = Window:AddTab("Legit", "crosshair")

local LegitGlobal = LegitTab:AddLeftGroupbox("Global")
LegitGlobal:AddToggle("LegitVisCheck", {
    Text     = "Visible Only",
    Default  = Global.Legit.VisCheck,
    Callback = function(v) Global.Legit.VisCheck = v end,
})
LegitGlobal:AddToggle("LegitTeamCheck", {
    Text     = "Team Check",
    Default  = Global.Legit.TeamCheck,
    Callback = function(v) Global.Legit.TeamCheck = v end,
})

local LegitSilentAim = LegitTab:AddLeftGroupbox("Silent Aim")
LegitSilentAim:AddToggle("LegitSilentAimEnabled", {
    Text     = "Enabled",
    Default  = config.Legit.SilentAim.Enabled,
    Disabled = silentAimDisabled,
    Tooltip  = silentAimDisabled and "Disabled on Xeno" or nil,
    Callback = function(v)
        config.Legit.SilentAim.Enabled = v
        CheckAndHookSilentAim()
    end,
})
LegitSilentAim:AddDropdown("LegitSilentAimTarget", {
    Text    = "Target",
    Default = config.Legit.SilentAim.HitPart,
    Values  = { "Nearest", "Head", "Torso" },
    Callback = function(v) config.Legit.SilentAim.HitPart = v end,
})
LegitSilentAim:AddSlider("LegitSilentAimFOV", {
    Text     = "FOV",
    Default  = 212,
    Min      = 10,
    Max      = 1000,
    Rounding = 0,
    Callback = function(v) config.Legit.SilentAim.FOV = v end,
})
LegitSilentAim:AddSlider("LegitSilentAimHitChance", {
    Text     = "Hit Chance",
    Default  = config.Legit.SilentAim.HitChance,
    Min      = 0,
    Max      = 100,
    Rounding = 0,
    Callback = function(v) config.Legit.SilentAim.HitChance = v end,
})
LegitSilentAim:AddToggle("LegitSilentAimDynamicFOV", {
    Text     = "Dynamic FOV",
    Default  = config.Legit.SilentAim.DynamicFOV,
    Callback = function(v) config.Legit.SilentAim.DynamicFOV = v end,
})
LegitSilentAim:AddToggle("LegitSilentAimFOVFollow", {
    Text     = "FOV Follow Target",
    Default  = config.Legit.SilentAim.FOVFollowEnabled,
    Callback = function(v) config.Legit.SilentAim.FOVFollowEnabled = v end,
})
LegitSilentAim:AddSlider("LegitSilentAimFollowTime", {
    Text     = "Follow Time",
    Default  = config.Legit.SilentAim.FOVFollowTime,
    Min      = 0.5,
    Max      = 5.0,
    Rounding = 1,
    Callback = function(v) config.Legit.SilentAim.FOVFollowTime = v end,
})

local LegitAimbot = LegitTab:AddRightGroupbox("Aimbot")
LegitAimbot:AddToggle("AimbotEnabled", {
    Text     = "Enabled",
    Default  = config.Legit.Aimbot.Enabled,
    Callback = function(v) config.Legit.Aimbot.Enabled = v end,
})
LegitAimbot:AddDropdown("AimbotTarget", {
    Text    = "Target",
    Default = config.Legit.Aimbot.TargetPart,
    Values  = { "Nearest", "Head", "Torso" },
    Callback = function(v) config.Legit.Aimbot.TargetPart = v end,
})
LegitAimbot:AddSlider("AimbotFOV", {
    Text     = "FOV",
    Default  = 333,
    Min      = 10,
    Max      = 720,
    Rounding = 0,
    Callback = function(v) config.Legit.Aimbot.FOV = v end,
})
LegitAimbot:AddSlider("AimbotSmoothness", {
    Text     = "Smoothness",
    Default  = config.Legit.Aimbot.Smoothness * 100,
    Min      = 1,
    Max      = 100,
    Rounding = 0,
    Callback = function(v) config.Legit.Aimbot.Smoothness = v / 100 end,
})
LegitAimbot:AddToggle("AimbotHumanize", {
    Text     = "Humanize",
    Default  = config.Legit.Aimbot.Humanize,
    Callback = function(v) config.Legit.Aimbot.Humanize = v end,
})
LegitAimbot:AddToggle("AimbotDynamicFOV", {
    Text     = "Dynamic FOV",
    Default  = config.Legit.Aimbot.DynamicFOV,
    Callback = function(v) config.Legit.Aimbot.DynamicFOV = v end,
})

local TriggerbotBox = LegitTab:AddRightGroupbox("Triggerbot")
TriggerbotBox:AddToggle("TriggerbotEnabled", {
    Text     = "Enabled",
    Default  = config.Legit.Triggerbot.Enabled,
    Callback = function(v) config.Legit.Triggerbot.Enabled = v end,
})
TriggerbotBox:AddSlider("TriggerbotDelay", {
    Text     = "Delay",
    Default  = config.Legit.Triggerbot.Delay * 1000,
    Min      = 10,
    Max      = 300,
    Rounding = 0,
    Suffix   = "ms",
    Callback = function(v) config.Legit.Triggerbot.Delay = v / 1000 end,
})
TriggerbotBox:AddSlider("TriggerbotHitbox", {
    Text     = "Hitbox Size",
    Default  = config.Legit.Triggerbot.HitboxMultiplier,
    Min      = 1.0,
    Max      = 3.0,
    Rounding = 1,
    Suffix   = "x",
    Callback = function(v) config.Legit.Triggerbot.HitboxMultiplier = v end,
})

-- ========================================================
-- RAGE TAB
-- ========================================================
local RageTab = Window:AddTab("Rage", "skull")

local RageMain = RageTab:AddLeftGroupbox("Ragebot")
RageMain:AddToggle("RageEnabled", {
    Text     = "Enabled",
    Default  = config.Rage.Enabled,
    Disabled = silentAimDisabled,
    Tooltip  = silentAimDisabled and "Disabled on Xeno" or nil,
    Callback = function(v)
        config.Rage.Enabled = v
        CheckAndHookSilentAim()
    end,
})
RageMain:AddToggle("RageTeamCheck", {
    Text     = "Team Check",
    Default  = Global.Rage.TeamCheck,
    Callback = function(v) Global.Rage.TeamCheck = v end,
})
RageMain:AddDropdown("RageTarget", {
    Text    = "Target",
    Default = config.Rage.HitPart,
    Values  = { "Head", "Nearest", "Torso" },
    Callback = function(v) config.Rage.HitPart = v end,
})
RageMain:AddSlider("RageFOV", {
    Text     = "FOV",
    Default  = config.Rage.FOV,
    Min      = 10,
    Max      = 1000,
    Rounding = 0,
    Callback = function(v) config.Rage.FOV = v end,
})
RageMain:AddToggle("RageDynamicFOV", {
    Text     = "Dynamic FOV",
    Default  = config.Rage.DynamicFOV,
    Callback = function(v) config.Rage.DynamicFOV = v end,
})
RageMain:AddToggle("RageAutoShoot", {
    Text     = "Auto Shoot",
    Default  = config.Rage.AutoShoot,
    Callback = function(v) config.Rage.AutoShoot = v end,
})
RageMain:AddToggle("RageAutoScope", {
    Text     = "Auto Scope",
    Default  = config.Rage.AutoScope,
    Callback = function(v) config.Rage.AutoScope = v end,
})
RageMain:AddSlider("RageScopeDelay", {
    Text     = "Scope Delay",
    Default  = config.Rage.ScopeDelay * 1000,
    Min      = 0,
    Max      = 300,
    Rounding = 0,
    Suffix   = "ms",
    Callback = function(v) config.Rage.ScopeDelay = v / 1000 end,
})
RageMain:AddSlider("RageShootDelay", {
    Text     = "Fire Rate",
    Default  = config.Rage.ShootDelay * 1000,
    Min      = 0,
    Max      = 500,
    Rounding = 0,
    Suffix   = "ms",
    Callback = function(v) config.Rage.ShootDelay = v / 1000 end,
})
RageMain:AddSlider("RageHitboxMultiplier", {
    Text     = "Hitbox Size",
    Default  = config.Rage.HitboxMultiplier,
    Min      = 1.0,
    Max      = 3.0,
    Rounding = 1,
    Suffix   = "x",
    Callback = function(v) config.Rage.HitboxMultiplier = v end,
})
RageMain:AddSlider("RageSpawnProtect", {
    Text     = "Spawn Protect",
    Default  = config.Rage.SpawnProtectionTime,
    Min      = 0,
    Max      = 5,
    Rounding = 1,
    Suffix   = "s",
    Callback = function(v) config.Rage.SpawnProtectionTime = v end,
})
RageMain:AddToggle("RageDynamicPrediction", {
    Text     = "Dynamic Prediction",
    Default  = config.Rage.DynamicPrediction,
    Callback = function(v) config.Rage.DynamicPrediction = v end,
})

-- ========================================================
-- MOVEMENT TAB
-- ========================================================
local MovementTab = Window:AddTab("Movement", "wind")

local WalkSpeedBox = MovementTab:AddLeftGroupbox("Walk Speed")
WalkSpeedBox:AddToggle("WalkSpeedEnabled", {
    Text     = "Enabled",
    Default  = config.Movement.WalkSpeed.Enabled,
    Callback = function(v) config.Movement.WalkSpeed.Enabled = v end,
})
WalkSpeedBox:AddSlider("WalkSpeedValue", {
    Text     = "Speed",
    Default  = config.Movement.WalkSpeed.Speed,
    Min      = 16,
    Max      = 100,
    Rounding = 0,
    Callback = function(v) config.Movement.WalkSpeed.Speed = v end,
})

local AirJumpBox = MovementTab:AddLeftGroupbox("Air Jump")
AirJumpBox:AddToggle("AirJumpEnabled", {
    Text     = "Enabled",
    Default  = config.Movement.AirJump.Enabled,
    Callback = function(v) config.Movement.AirJump.Enabled = v end,
})

local GravityBox = MovementTab:AddRightGroupbox("Gravity")
GravityBox:AddToggle("GravityEnabled", {
    Text     = "Enabled",
    Default  = config.Movement.Gravity.Enabled,
    Callback = function(v) config.Movement.Gravity.Enabled = v end,
})
GravityBox:AddSlider("GravityValue", {
    Text     = "Gravity %",
    Default  = config.Movement.Gravity.Value * 100,
    Min      = 10,
    Max      = 100,
    Rounding = 0,
    Suffix   = "%",
    Callback = function(v) config.Movement.Gravity.Value = v / 100 end,
})

-- ========================================================
-- VISUALS TAB
-- ========================================================
local VisualsTab = Window:AddTab("Visuals", "eye")

local ESPBox = VisualsTab:AddLeftGroupbox("ESP")
ESPBox:AddToggle("ESPEnabled", {
    Text     = "Enabled",
    Default  = config.ESP.Enabled,
    Callback = function(v) config.ESP.Enabled = v end,
})
ESPBox:AddToggle("ESPTeamCheck", {
    Text     = "Team Check",
    Default  = Global.ESP.TeamCheck,
    Callback = function(v) Global.ESP.TeamCheck = v end,
})

local FOVBox = VisualsTab:AddLeftGroupbox("FOV Circle")
FOVBox:AddToggle("FOVShow", {
    Text     = "Show",
    Default  = config.FOV.Show,
    Callback = function(v) config.FOV.Show = v end,
})

SaveManager:LoadAutoloadConfig()

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
        HandleRagebot()
        UpdateESP()
    end)
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    state.team = GetTeam()
end)
state.team = GetTeam()
