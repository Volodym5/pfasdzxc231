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

-- Load your UI library
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/lib/source.lua"))()

-- ========================================================
-- GLOBAL SETTINGS
-- ========================================================
local Global = {
    Legit = {
        VisCheck = true,
        TeamCheck = false
    },
    Rage = {
        VisCheck = true,
        TeamCheck = false
    },
    ESP = {
        TeamCheck = false
    }
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
            FOVSpawnDelay = 0.8
        },
        AutoShoot = {
            Enabled = false,
            Delay = 0.02,
            SpawnProtectionTime = 1.65,
            TieToSilentAim = true -- When true, AutoShoot uses Silent Aim's exact target
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
-- SPAWN PROTECTION TRACKING
-- ========================================================
local function OnPlayerAdded(player)
    player.CharacterAdded:Connect(function(char)
        state.spawnTimes[player] = tick()
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function() end)
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

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        OnPlayerAdded(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        OnPlayerAdded(player)
    end
end)

local function IsSpawnProtectedForShoot(player)
    local spawnTime = state.spawnTimes[player]
    if not spawnTime then return false end
    return (tick() - spawnTime) < config.Rage.AutoShoot.SpawnProtectionTime
end

local function IsSpawnProtectedForFOV(player)
    local spawnTime = state.spawnTimes[player]
    if not spawnTime then return false end
    return (tick() - spawnTime) < config.Rage.SilentAim.FOVSpawnDelay
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

local function RaycastVisible(origin, target, ignoreChar)
    local ignoreList = {ignoreChar}
    if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
    for _, glass in ipairs(glassParts) do table.insert(ignoreList, glass) end
    
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = ignoreList
    
    local result = Workspace:Raycast(origin, target - origin, rayParams)
    return not result or result.Instance:IsDescendantOf(ignoreChar)
end

local function IsPartVisible(part, character, visCheck)
    if not visCheck then return true end
    UpdateGlassCache()
    return RaycastVisible(Camera.CFrame.Position, part.Position, character)
end

local function WillStillBeVisible(part, character)
    local PREDICT_TIME = 0.125
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
    if distance < 0.5 then return true end
    UpdateGlassCache()
    local ignoreList = {character}
    if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
    for _, glass in ipairs(glassParts) do table.insert(ignoreList, glass) end
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = ignoreList
    local result = Workspace:Raycast(predictedCameraPos, direction, rayParams)
    if not result or result.Instance:IsDescendantOf(character) then return true end
    local currentDir = part.Position - Camera.CFrame.Position
    local currentResult = Workspace:Raycast(Camera.CFrame.Position, currentDir, rayParams)
    if not currentResult or currentResult.Instance:IsDescendantOf(character) then return true end
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
-- FIND TARGET (Rage)
-- ========================================================
local function FindTargetRage(baseFOV, targetMode, visCheck, teamCheck, useDynamicFOV, ignoreSpawnProtected, spawnCheckFunc)
    local fov = useDynamicFOV and GetDynamicFOV(baseFOV) or baseFOV
    local best, bestDist = nil, fov
    local bestChar = nil
    local center = Camera.ViewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsEnemy(player, teamCheck) then continue end
        if ignoreSpawnProtected and spawnCheckFunc and spawnCheckFunc(player) then continue end
        
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
-- CHECK IF CROSSHAIR IS ON ENEMY
-- ========================================================
local function IsCrosshairOnEnemy(hitboxMultiplier, visCheck, teamCheck)
    local center = Camera.ViewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not IsEnemy(player, teamCheck) then continue end
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if visCheck then
            local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            if head and not IsPartVisible(head, char, visCheck) then continue end
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
    
    if IsCrosshairOnEnemy(config.Legit.Triggerbot.HitboxMultiplier, Global.Legit.VisCheck, Global.Legit.TeamCheck) then
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        state.lastTrigger = now
    end
end

-- ========================================================
-- UPDATE SILENT AIM FOV TRACKING
-- ========================================================
local function UpdateSilentFOVTracking()
    local part, char = FindTargetRage(config.Rage.SilentAim.FOV, config.Rage.SilentAim.HitPart, Global.Rage.VisCheck, Global.Rage.TeamCheck, config.Rage.SilentAim.DynamicFOV, true, IsSpawnProtectedForFOV)
    
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
        local isBehindWall = state.silentFovTrackPart and not IsPartVisible(state.silentFovTrackPart, state.silentFovTrackTarget, Global.Rage.VisCheck)
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
-- AUTO SHOOT (RAGE) - WITH TIE TO SILENT AIM
-- ========================================================
local function HandleAutoShoot()
    if not config.Rage.AutoShoot.Enabled then return end
    if state.autoShootActive then return end
    
    if config.Rage.AutoShoot.TieToSilentAim then
        -- Use Silent Aim's exact target if available and still valid
        if state.silentTarget and state.silentTarget.Parent then
            local char = state.silentTarget.Parent
            local hum = char:FindFirstChildOfClass("Humanoid")
            local player = Players:GetPlayerFromCharacter(char)
            
            -- Verify target is still valid
            if hum and hum.Health > 0 then
                if not player or not IsSpawnProtectedForShoot(player) then
                    if IsPartVisible(state.silentTarget, char, Global.Rage.VisCheck) then
                        state.autoShootActive = true
                        
                        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.02)
                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        
                        task.wait(config.Rage.AutoShoot.Delay)
                        state.autoShootActive = false
                        return
                    end
                end
            end
        end
        
        -- Fallback: Silent Aim target not available, find our own
        local target, targetChar = FindTargetRage(config.Rage.SilentAim.FOV, "Nearest", Global.Rage.VisCheck, Global.Rage.TeamCheck, config.Rage.SilentAim.DynamicFOV, true, IsSpawnProtectedForShoot)
        
        if target then
            state.autoShootActive = true
            
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.02)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            
            task.wait(config.Rage.AutoShoot.Delay)
            state.autoShootActive = false
        end
    else
        -- Independent mode
        local target, targetChar = FindTargetRage(config.Rage.SilentAim.FOV, "Nearest", Global.Rage.VisCheck, Global.Rage.TeamCheck, config.Rage.SilentAim.DynamicFOV, true, IsSpawnProtectedForShoot)
        
        if target then
            state.autoShootActive = true
            
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.02)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            
            task.wait(config.Rage.AutoShoot.Delay)
            state.autoShootActive = false
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
    
    if distance > 150 then smoothFactor = smoothFactor * 0.85
    elseif distance < 30 then smoothFactor = smoothFactor * 1.15 end
    
    local finalAlpha = math.clamp(smoothFactor, 0.008, 0.95)
    local lookAt = CFrame.new(Camera.CFrame.Position, aimPos)
    Camera.CFrame = Camera.CFrame:Lerp(lookAt, finalAlpha)
end

-- ========================================================
-- SILENT AIM - STORES TARGET FOR AUTOSHOOT TIE-IN
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
                    local tgt = FindTargetRage(config.Rage.SilentAim.FOV, config.Rage.SilentAim.HitPart, Global.Rage.VisCheck, Global.Rage.TeamCheck, config.Rage.SilentAim.DynamicFOV, false, nil)
                    if tgt and WillStillBeVisible(tgt, tgt.Parent) then
                        -- Store for AutoShoot tie-in
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
-- CREATE UI WINDOW
-- ========================================================
local Window = UI:CreateWindow({
    Title          = "nexus.gg",
    Size           = UDim2.fromOffset(520, 460),
    Center         = true,
    Resizable      = true,
    ToggleKeybind  = Enum.KeyCode.RightShift,
    AutoShow       = true,
})

-- ========================================================
-- LEGIT TAB
-- ========================================================
local LegitTab = Window:AddTab("🎯 Legit")

local LegitGlobalBox = LegitTab:AddGroupbox({ Name = "Global", Side = 2 })
LegitGlobalBox:AddToggle("LegitVisCheck", {
    Text     = "Visible Only",
    Default  = Global.Legit.VisCheck,
    Callback = function(v) Global.Legit.VisCheck = v end,
})
LegitGlobalBox:AddToggle("LegitTeamCheck", {
    Text     = "Team Check",
    Default  = Global.Legit.TeamCheck,
    Callback = function(v) Global.Legit.TeamCheck = v end,
})

local LegitAimbotBox = LegitTab:AddGroupbox({ Name = "Aimbot", Side = 1 })
LegitAimbotBox:AddToggle("AimbotEnabled", {
    Text     = "Enabled",
    Default  = config.Legit.Aimbot.Enabled,
    Callback = function(v) config.Legit.Aimbot.Enabled = v end,
})
LegitAimbotBox:AddDropdown("AimbotTarget", {
    Text     = "Target",
    Values   = { "Nearest", "Head", "Torso" },
    Default  = config.Legit.Aimbot.TargetPart,
    Callback = function(v) config.Legit.Aimbot.TargetPart = v end,
})
LegitAimbotBox:AddSlider("AimbotFOV", {
    Text     = "FOV",
    Default  = config.Legit.Aimbot.FOV,
    Min      = 10,
    Max      = 720,
    Rounding = 0,
    Callback = function(v) config.Legit.Aimbot.FOV = v end,
})
LegitAimbotBox:AddSlider("AimbotSmoothness", {
    Text     = "Smoothness",
    Default  = config.Legit.Aimbot.Smoothness * 100,
    Min      = 1,
    Max      = 100,
    Rounding = 0,
    Callback = function(v) config.Legit.Aimbot.Smoothness = v / 100 end,
})
LegitAimbotBox:AddToggle("AimbotHumanize", {
    Text     = "Humanize",
    Default  = config.Legit.Aimbot.Humanize,
    Callback = function(v) config.Legit.Aimbot.Humanize = v end,
})
LegitAimbotBox:AddToggle("AimbotDynamicFOV", {
    Text     = "Dynamic FOV",
    Default  = config.Legit.Aimbot.DynamicFOV,
    Callback = function(v) config.Legit.Aimbot.DynamicFOV = v end,
})

local TriggerbotBox = LegitTab:AddGroupbox({ Name = "Triggerbot", Side = 2 })
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
    Callback = function(v) config.Legit.Triggerbot.Delay = v / 1000 end,
})
TriggerbotBox:AddSlider("TriggerbotHitbox", {
    Text     = "Hitbox Size",
    Default  = config.Legit.Triggerbot.HitboxMultiplier,
    Min      = 1.0,
    Max      = 3.0,
    Rounding = 1,
    Callback = function(v) config.Legit.Triggerbot.HitboxMultiplier = v end,
})

-- ========================================================
-- RAGE TAB
-- ========================================================
local RageTab = Window:AddTab("💀 Rage")

local RageGlobalBox = RageTab:AddGroupbox({ Name = "Global", Side = 2 })
RageGlobalBox:AddToggle("RageVisCheck", {
    Text     = "Visible Only",
    Default  = Global.Rage.VisCheck,
    Callback = function(v) Global.Rage.VisCheck = v end,
})
RageGlobalBox:AddToggle("RageTeamCheck", {
    Text     = "Team Check",
    Default  = Global.Rage.TeamCheck,
    Callback = function(v) Global.Rage.TeamCheck = v end,
})

local SilentAimBox = RageTab:AddGroupbox({ Name = "Silent Aim", Side = 1 })
SilentAimBox:AddToggle("SilentAimEnabled", {
    Text     = "Enabled",
    Default  = config.Rage.SilentAim.Enabled,
    Callback = function(v) config.Rage.SilentAim.Enabled = v end,
})
SilentAimBox:AddDropdown("SilentAimTarget", {
    Text     = "Target",
    Values   = { "Nearest", "Head", "Torso" },
    Default  = config.Rage.SilentAim.HitPart,
    Callback = function(v) config.Rage.SilentAim.HitPart = v end,
})
SilentAimBox:AddSlider("SilentAimFOV", {
    Text     = "FOV",
    Default  = config.Rage.SilentAim.FOV,
    Min      = 10,
    Max      = 1000,
    Rounding = 0,
    Callback = function(v) config.Rage.SilentAim.FOV = v end,
})
SilentAimBox:AddSlider("SilentAimHitChance", {
    Text     = "Hit Chance",
    Default  = config.Rage.SilentAim.HitChance,
    Min      = 0,
    Max      = 100,
    Rounding = 0,
    Callback = function(v) config.Rage.SilentAim.HitChance = v end,
})
SilentAimBox:AddToggle("SilentAimDynamicFOV", {
    Text     = "Dynamic FOV",
    Default  = config.Rage.SilentAim.DynamicFOV,
    Callback = function(v) config.Rage.SilentAim.DynamicFOV = v end,
})
SilentAimBox:AddToggle("SilentAimFOVFollow", {
    Text     = "FOV Follow Target",
    Default  = config.Rage.SilentAim.FOVFollowEnabled,
    Callback = function(v) config.Rage.SilentAim.FOVFollowEnabled = v end,
})
SilentAimBox:AddSlider("SilentAimFollowTime", {
    Text     = "Follow Time",
    Default  = config.Rage.SilentAim.FOVFollowTime,
    Min      = 0.5,
    Max      = 5.0,
    Rounding = 1,
    Callback = function(v) config.Rage.SilentAim.FOVFollowTime = v end,
})
SilentAimBox:AddSlider("SilentAimFOVSpawnDelay", {
    Text     = "FOV Spawn Delay",
    Default  = config.Rage.SilentAim.FOVSpawnDelay,
    Min      = 0,
    Max      = 3,
    Rounding = 1,
    Callback = function(v) config.Rage.SilentAim.FOVSpawnDelay = v end,
})

local AutoShootBox = RageTab:AddGroupbox({ Name = "Auto Shoot", Side = 2 })
AutoShootBox:AddToggle("AutoShootEnabled", {
    Text     = "Enabled",
    Default  = config.Rage.AutoShoot.Enabled,
    Callback = function(v) config.Rage.AutoShoot.Enabled = v end,
})
AutoShootBox:AddToggle("AutoShootTie", {
    Text     = "Tie to Silent Aim",
    Default  = config.Rage.AutoShoot.TieToSilentAim,
    Callback = function(v) config.Rage.AutoShoot.TieToSilentAim = v end,
})
AutoShootBox:AddSlider("AutoShootDelay", {
    Text     = "Delay",
    Default  = config.Rage.AutoShoot.Delay * 1000,
    Min      = 0,
    Max      = 500,
    Rounding = 0,
    Callback = function(v) config.Rage.AutoShoot.Delay = v / 1000 end,
})
AutoShootBox:AddSlider("AutoShootSpawnProtect", {
    Text     = "Spawn Protect",
    Default  = config.Rage.AutoShoot.SpawnProtectionTime,
    Min      = 0,
    Max      = 5,
    Rounding = 2,
    Callback = function(v) config.Rage.AutoShoot.SpawnProtectionTime = v end,
})

-- ========================================================
-- VISUALS TAB
-- ========================================================
local VisualsTab = Window:AddTab("👁️ Visuals")

local ESPBox = VisualsTab:AddGroupbox({ Name = "ESP", Side = 1 })
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

local FOVBox = VisualsTab:AddGroupbox({ Name = "FOV Circle", Side = 1 })
FOVBox:AddToggle("FOVShow", {
    Text     = "Show",
    Default  = config.FOV.Show,
    Callback = function(v) config.FOV.Show = v end,
})

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
