local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Settings
getgenv().Config = {
    SilentAim = true,
    Chams = true,
    FOV = 150,
    ShowFOV = true,
    VisibilityCheck = true,
    HitChance = 100,
    TeamCheck = true,
    SmartTarget = true,
    PreferHead = true,
    DisableOnSlot4 = true, -- New: Disable silent aim on slot 4 (grenades/utility)
    
    -- Randomization (subtle)
    Randomization = {
        Enabled = true,
        OffsetRange = 0.5,
        UpdateInterval = 0.8,
        Smoothing = true,
        SmoothingSpeed = 0.05,
        PartRandomization = true,
        PartSwitchChance = 10,
        MissChance = 0,
    },
    
    -- Smart Selection
    SmartSelection = {
        Enabled = true,
        HealthBasedPriority = true,
        DistancePriority = true,
        ThreatDetection = true,
    }
}

-- Initialize FighterController for team checks
local FighterController = nil
pcall(function()
    local controller = LocalPlayer.PlayerScripts.Controllers.FighterController
    if controller and controller:IsA("ModuleScript") then
        FighterController = require(controller)
    end
end)

-- FOV Circle
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.NumSides = 64
FovCircle.Radius = Config.FOV
FovCircle.Color = Color3.new(1, 1, 1)
FovCircle.Visible = Config.ShowFOV
FovCircle.Filled = false

-- Current Target
local CurrentTarget = nil
local LastTarget = nil
local CurrentOffset = Vector3.zero
local TargetOffset = Vector3.zero
local LastRandomize = 0
local CurrentPartName = "Head"

-- Threat levels for smart targeting
local ThreatLevels = {}

-- Target parts with weights (head prioritized)
local TARGET_PARTS = {
    {Name = "Head", Weight = 70},
    {Name = "UpperTorso", Weight = 20},
    {Name = "HumanoidRootPart", Weight = 5},
    {Name = "LowerTorso", Weight = 3},
    {Name = "LeftUpperArm", Weight = 1},
    {Name = "RightUpperArm", Weight = 1},
}

-- Get Screen Center
local function GetScreenCenter()
    local Camera = Workspace.CurrentCamera
    if not Camera then return Vector2.zero end
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

-- Get player's TeamID from FighterController
local function GetTeamID(player)
    if not FighterController or not FighterController._player_to_fighter then
        return nil
    end
    
    local fighter = FighterController._player_to_fighter[player]
    if fighter and fighter.Data and fighter.Data.TeamID then
        return fighter.Data.TeamID
    end
    
    return nil
end

-- Team Check
local function IsOnSameTeam(player)
    if not Config.TeamCheck then return false end
    
    local localTeamID = GetTeamID(LocalPlayer)
    local playerTeamID = GetTeamID(player)
    
    if not localTeamID or not playerTeamID then
        return false
    end
    
    return localTeamID == playerTeamID
end

-- Check if current weapon is slot 4 (grenade/utility)
local function IsSlot4Equipped()
    if not Config.DisableOnSlot4 then return false end
    if not FighterController or not FighterController._player_to_fighter then return false end
    
    local localFighter = FighterController._player_to_fighter[LocalPlayer]
    if not localFighter then return false end
    
    -- Method 1: Check EquippedItem name
    if localFighter.EquippedItem and type(localFighter.EquippedItem) == "table" then
        local itemName = localFighter.EquippedItem.Name
        if itemName and (itemName:lower():find("grenade") or itemName:lower():find("utility") or itemName:lower():find("flash") or itemName:lower():find("smoke")) then
            return true
        end
    end
    
    -- Method 2: Check which item has IsEquipped = true (items are indexed 1-4)
    if localFighter.Items and type(localFighter.Items) == "table" then
        for slot, item in pairs(localFighter.Items) do
            if type(item) == "table" and item.IsEquipped == true and slot == 4 then
                return true
            end
        end
    end
    
    return false
end

-- Get weighted random part
local function GetRandomPart(currentTarget)
    if currentTarget and currentTarget.Name == "Head" then
        if math.random(1, 100) > Config.Randomization.PartSwitchChance then
            return "Head"
        end
    end
    
    if currentTarget then
        local character = currentTarget.Parent
        if character then
            local availableParts = {}
            local head = character:FindFirstChild("Head")
            local upperTorso = character:FindFirstChild("UpperTorso")
            local lowerTorso = character:FindFirstChild("LowerTorso")
            local humanoidRoot = character:FindFirstChild("HumanoidRootPart")
            
            if head then table.insert(availableParts, {name = "Head", weight = 70}) end
            if upperTorso then table.insert(availableParts, {name = "UpperTorso", weight = 20}) end
            if humanoidRoot then table.insert(availableParts, {name = "HumanoidRootPart", weight = 5}) end
            if lowerTorso then table.insert(availableParts, {name = "LowerTorso", weight = 5}) end
            
            if #availableParts > 0 then
                local totalWeight = 0
                for _, p in pairs(availableParts) do
                    totalWeight = totalWeight + p.weight
                end
                
                local random = math.random(1, totalWeight)
                local currentWeight = 0
                
                for _, p in pairs(availableParts) do
                    currentWeight = currentWeight + p.weight
                    if random <= currentWeight then
                        return p.name
                    end
                end
            end
        end
    end
    
    return "Head"
end

-- Generate subtle random offset
local function GetRandomOffset()
    local range = Config.Randomization.OffsetRange
    return Vector3.new(
        (math.random() - 0.5) * range * 0.5,
        (math.random() - 0.5) * range * 0.3,
        (math.random() - 0.5) * range * 0.5
    )
end

-- Visibility Check
local function IsVisible(part)
    local Camera = Workspace.CurrentCamera
    if not Camera or not part then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    
    local result = Workspace:Raycast(origin, direction, params)
    return result == nil or result.Instance:IsDescendantOf(part.Parent)
end

-- Get screen distance from center
local function GetScreenDistance(worldPos)
    local Camera = Workspace.CurrentCamera
    if not Camera then return math.huge end
    
    local pos, onScreen = Camera:WorldToViewportPoint(worldPos)
    if not onScreen then return math.huge end
    
    local ScreenCenter = GetScreenCenter()
    return (Vector2.new(pos.X, pos.Y) - ScreenCenter).Magnitude
end

-- Calculate threat level
local function CalculateThreatLevel(player)
    if not player.Character then return 0 end
    
    local threat = 0
    local character = player.Character
    
    local head = character:FindFirstChild("Head")
    if head and LocalPlayer.Character then
        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if localRoot then
            local theirLook = head.CFrame.LookVector
            local directionToUs = (localRoot.Position - head.Position).Unit
            local dotProduct = theirLook:Dot(directionToUs)
            
            if dotProduct > 0.6 then
                threat = threat + 50
            end
        end
    end
    
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("Tool") then
            threat = threat + 30
            break
        end
    end
    
    if LocalPlayer.Character then
        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local enemyRoot = character:FindFirstChild("HumanoidRootPart")
        if localRoot and enemyRoot then
            local distance = (enemyRoot.Position - localRoot.Position).Magnitude
            if distance < 50 then
                threat = threat + (50 - distance) * 1.5
            end
        end
    end
    
    ThreatLevels[player] = threat
    return threat
end

-- Smart Target Selection
local function GetBestTarget()
    -- Don't target if slot 4 is equipped
    if IsSlot4Equipped() then
        return nil
    end
    
    local Camera = Workspace.CurrentCamera
    if not Camera then return nil end
    
    local BestTarget = nil
    local BestScore = math.huge
    local FOV = Config.FOV
    
    local currentTime = tick()
    if currentTime - LastRandomize > Config.Randomization.UpdateInterval then
        LastRandomize = currentTime
        
        if Config.Randomization.Enabled and Config.Randomization.PartRandomization then
            if math.random(1, 100) <= Config.Randomization.PartSwitchChance then
                CurrentPartName = GetRandomPart(CurrentTarget)
            end
        end
        
        if Config.Randomization.Enabled then
            TargetOffset = GetRandomOffset()
        else
            TargetOffset = Vector3.zero
        end
    end
    
    if Config.Randomization.Enabled and Config.Randomization.Smoothing then
        CurrentOffset = CurrentOffset:Lerp(TargetOffset, Config.Randomization.SmoothingSpeed)
    else
        CurrentOffset = TargetOffset
    end
    
    if LastTarget and LastTarget.Parent then
        local player = Players:GetPlayerFromCharacter(LastTarget.Parent)
        if player and not IsOnSameTeam(player) then
            local pos = LastTarget.Position + CurrentOffset
            local dist = GetScreenDistance(pos)
            
            if dist < FOV * 1.3 then
                if not Config.VisibilityCheck or IsVisible(LastTarget) then
                    BestTarget = LastTarget
                    BestScore = dist * 0.7
                end
            end
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        if IsOnSameTeam(player) then continue end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local threat = CalculateThreatLevel(player)
        
        if Config.SmartTarget then
            for _, partInfo in pairs(TARGET_PARTS) do
                local part = player.Character:FindFirstChild(partInfo.Name)
                if part and part:IsA("BasePart") then
                    local pos = part.Position + CurrentOffset
                    local dist = GetScreenDistance(pos)
                    
                    local score = dist
                    
                    if partInfo.Name == "Head" then
                        score = score * 0.65
                    elseif partInfo.Name == "UpperTorso" then
                        score = score * 0.8
                    elseif partInfo.Name:find("Torso") then
                        score = score * 0.9
                    end
                    
                    if Config.SmartSelection.HealthBasedPriority then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        score = score * (0.5 + healthPercent * 0.5)
                    end
                    
                    if Config.SmartSelection.DistancePriority then
                        local distance = (part.Position - Camera.CFrame.Position).Magnitude
                        score = score * (1 + distance / 200)
                    end
                    
                    if Config.SmartSelection.ThreatDetection and threat > 0 then
                        score = score * (1 - threat / 200)
                    end
                    
                    if score < BestScore and dist < FOV then
                        if not Config.VisibilityCheck or IsVisible(part) then
                            BestTarget = part
                            BestScore = score
                            CurrentPartName = partInfo.Name
                        end
                    end
                end
            end
        else
            local head = player.Character:FindFirstChild("Head")
            if head then
                local pos = head.Position + CurrentOffset
                local dist = GetScreenDistance(pos)
                
                if dist < BestScore and dist < FOV then
                    if not Config.VisibilityCheck or IsVisible(head) then
                        BestTarget = head
                        BestScore = dist
                    end
                end
            end
        end
    end
    
    LastTarget = BestTarget
    return BestTarget
end

-- Silent Aim
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if Config.SilentAim and CurrentTarget and not checkcaller() and not IsSlot4Equipped() then
        if self == Workspace and (method == "Raycast" or method == "raycast") then
            local origin = args[1]
            local direction = args[2]
            
            if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                if direction.Magnitude > 50 then
                    local targetPos = CurrentTarget.Position + CurrentOffset
                    args[2] = (targetPos - origin).Unit * direction.Magnitude
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    
    return oldNamecall(self, ...)
end))

-- Chams System
local chams = {}

local R15_PARTS = {
    "Head",
    "UpperTorso", "LowerTorso", "HumanoidRootPart",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot"
}

local function AddChamsToCharacter(character)
    if not character then return end
    
    -- Skip teammates
    local player = Players:GetPlayerFromCharacter(character)
    if player and IsOnSameTeam(player) then
        return
    end
    
    for _, highlight in pairs(chams) do
        if highlight and highlight.Parent and highlight.Parent:IsDescendantOf(character) then
            highlight:Destroy()
        end
    end
    
    local highlights = {}
    local addedParts = {}
    
    local function addHighlight(part)
        if part and part:IsA("BasePart") and not addedParts[part] then
            addedParts[part] = true
            
            local highlight = Instance.new("Highlight")
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.FillColor = Color3.new(1, 1, 1)
            highlight.Adornee = part
            highlight.Parent = part
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            
            table.insert(highlights, highlight)
        end
    end
    
    for _, partName in pairs(R15_PARTS) do
        local part = character:FindFirstChild(partName)
        if part then
            addHighlight(part)
        end
    end
    
    chams[character] = highlights
    
    character.DescendantAdded:Connect(function(descendant)
        local charPlayer = Players:GetPlayerFromCharacter(character)
        if Config.Chams and not IsOnSameTeam(charPlayer) and table.find(R15_PARTS, descendant.Name) and descendant:IsA("BasePart") then
            task.wait()
            addHighlight(descendant)
        end
    end)
end

local function RemoveChamsFromCharacter(character)
    if chams[character] then
        for _, highlight in pairs(chams[character]) do
            if highlight then
                highlight:Destroy()
            end
        end
        chams[character] = nil
    end
end

-- Player Management
local function OnPlayerAdded(player)
    if player == LocalPlayer then return end
    
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart", 10)
        task.wait(0.5)
        
        if Config.Chams then
            AddChamsToCharacter(character)
        end
    end)
    
    player.CharacterRemoving:Connect(function(character)
        RemoveChamsFromCharacter(character)
    end)
    
    if player.Character then
        if Config.Chams then
            task.wait(0.5)
            AddChamsToCharacter(player.Character)
        end
    end
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        RemoveChamsFromCharacter(player.Character)
    end
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        OnPlayerAdded(player)
    end
end

-- Re-check chams periodically
task.spawn(function()
    while task.wait(1) do
        if Config.Chams then
            for character, highlights in pairs(chams) do
                if character and character.Parent then
                    local player = Players:GetPlayerFromCharacter(character)
                    
                    if player and IsOnSameTeam(player) then
                        RemoveChamsFromCharacter(character)
                    else
                        for _, partName in pairs(R15_PARTS) do
                            local part = character:FindFirstChild(partName)
                            if part then
                                local hasHighlight = false
                                for _, highlight in pairs(highlights) do
                                    if highlight and highlight.Adornee == part then
                                        hasHighlight = true
                                        break
                                    end
                                end
                                
                                if not hasHighlight then
                                    local highlight = Instance.new("Highlight")
                                    highlight.FillTransparency = 0.5
                                    highlight.OutlineTransparency = 0
                                    highlight.OutlineColor = Color3.new(1, 1, 1)
                                    highlight.FillColor = Color3.new(1, 1, 1)
                                    highlight.Adornee = part
                                    highlight.Parent = part
                                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    
                                    table.insert(highlights, highlight)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Rainbow Color
local function GetRainbow(offset)
    local hue = (tick() * 0.5 + offset) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Target indicators
local TargetIndicator = Drawing.new("Circle")
TargetIndicator.Thickness = 2
TargetIndicator.NumSides = 4
TargetIndicator.Radius = 8
TargetIndicator.Color = Color3.new(1, 0, 0)
TargetIndicator.Visible = false

local DebugText = Drawing.new("Text")
DebugText.Color = Color3.new(1, 1, 1)
DebugText.Size = 12
DebugText.Center = true
DebugText.Outline = true
DebugText.Visible = false

-- Main Loop
RunService.RenderStepped:Connect(function()
    local ScreenCenter = GetScreenCenter()
    local Camera = Workspace.CurrentCamera
    
    -- Update FOV - centered on screen (only show when not on slot 4)
    if Config.ShowFOV then
        FovCircle.Position = ScreenCenter
        FovCircle.Radius = Config.FOV
        FovCircle.Visible = Config.SilentAim and not IsSlot4Equipped()
        
        -- Change FOV color when slot 4 is equipped
        if IsSlot4Equipped() then
            FovCircle.Color = Color3.new(0.5, 0.5, 0.5) -- Gray when disabled
        else
            FovCircle.Color = Color3.new(1, 1, 1) -- White when active
        end
    else
        FovCircle.Visible = false
    end
    
    -- Update Target
    if Config.SilentAim then
        CurrentTarget = GetBestTarget()
    else
        CurrentTarget = nil
    end
    
    -- Visual feedback
    if CurrentTarget and Camera then
        local targetPos = CurrentTarget.Position + CurrentOffset
        local pos, onScreen = Camera:WorldToViewportPoint(targetPos)
        
        if onScreen then
            TargetIndicator.Position = Vector2.new(pos.X, pos.Y)
            TargetIndicator.Visible = true
            
            if CurrentTarget.Name == "Head" then
                TargetIndicator.Color = Color3.new(1, 0, 0)
            elseif CurrentTarget.Name:find("Torso") then
                TargetIndicator.Color = Color3.new(1, 1, 0)
            else
                TargetIndicator.Color = Color3.new(0, 1, 0)
            end
            
            local threat = 0
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:IsAncestorOf(CurrentTarget) then
                    threat = ThreatLevels[player] or 0
                    break
                end
            end
            
            DebugText.Position = Vector2.new(pos.X, pos.Y - 20)
            DebugText.Text = string.format("%s [%.0f]", CurrentTarget.Name, threat)
            DebugText.Visible = true
        else
            TargetIndicator.Visible = false
            DebugText.Visible = false
        end
    else
        TargetIndicator.Visible = false
        DebugText.Visible = false
    end
    
    -- Update Chams Colors for enemies only
    if Config.Chams then
        local enemyIndex = 0
        for character, highlights in pairs(chams) do
            local player = Players:GetPlayerFromCharacter(character)
            
            if player and not IsOnSameTeam(player) then
                local color = GetRainbow(enemyIndex * 0.3)
                
                for _, highlight in pairs(highlights) do
                    if highlight and highlight.Parent then
                        highlight.FillColor = color
                        highlight.OutlineColor = Color3.new(1, 1, 1)
                    end
                end
                enemyIndex = enemyIndex + 1
            end
        end
    end
end)
