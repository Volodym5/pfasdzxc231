local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local rotationHistory = {}
local positionHistory = {}
local moveStartTime = {}
local lastMoveTime = {}
local confirmedMoving = {}
local MOVE_TIMEOUT = 35
local MOVE_THRESHOLD = 0.2

local viewmodelBlacklist = {}
local noMatchStart = {}
local BLACKLIST_DURATION = 5
local NO_MATCH_THRESHOLD = 10

local FOV_RADIUS = 150
local SMOOTHNESS = 0.6
local aimbotEnabled = true
local currentTarget = nil

local viewmodelMatch = {}
local viewmodelTeamCache = {}
local visibilityCache = {}
local aimPositionCache = {}

-- ─── Cached visibility system ───────────────────────────────────────────────
local transparentSet = {}
local localCharacterParts = {}
local sharedIgnoreList = {}
local ignoreListDirty = true
local lastTransparentScan = 0

local SAMPLE_OFFSETS = {
    Vector3.new(0, 0, 0),
    Vector3.new(0, 0.5, 0),
    Vector3.new(0, -0.5, 0),
    Vector3.new(0.4, 0, 0),
    Vector3.new(-0.4, 0, 0),
}

local function updateTransparentCache()
    local now = tick()
    if now - lastTransparentScan < 10 then return end
    lastTransparentScan = now
    
    local allParts = workspace:GetDescendants()
    for i = 1, #allParts do
        local part = allParts[i]
        if part:IsA("BasePart") and part.Transparency >= 0.92 then
            if not transparentSet[part] then
                transparentSet[part] = true
                ignoreListDirty = true
            end
        end
    end
    
    for part, _ in pairs(transparentSet) do
        if not part.Parent then
            transparentSet[part] = nil
            ignoreListDirty = true
        end
    end
end

local function rebuildCharacterCache(character)
    localCharacterParts = {}
    if not character then return end
    local parts = character:GetDescendants()
    for i = 1, #parts do
        if parts[i]:IsA("BasePart") then
            localCharacterParts[#localCharacterParts + 1] = parts[i]
        end
    end
    ignoreListDirty = true
end

localPlayer.CharacterAdded:Connect(rebuildCharacterCache)
if localPlayer.Character then
    rebuildCharacterCache(localPlayer.Character)
end

local function getIgnoreList(modelParts)
    updateTransparentCache()
    
    if ignoreListDirty then
        sharedIgnoreList = {}
        for part, _ in pairs(transparentSet) do
            sharedIgnoreList[#sharedIgnoreList + 1] = part
        end
        for i = 1, #localCharacterParts do
            sharedIgnoreList[#sharedIgnoreList + 1] = localCharacterParts[i]
        end
        ignoreListDirty = false
    end
    
    if modelParts and #modelParts > 0 then
        local list = {}
        for i = 1, #sharedIgnoreList do
            list[i] = sharedIgnoreList[i]
        end
        for i = 1, #modelParts do
            list[#list + 1] = modelParts[i]
        end
        return list
    end
    
    return sharedIgnoreList
end

local function getModelPartsList(model)
    local parts = {}
    local descendants = model:GetDescendants()
    for i = 1, #descendants do
        if descendants[i]:IsA("BasePart") then
            parts[#parts + 1] = descendants[i]
        end
    end
    return parts
end

local function getBestTargetPart(model)
    if not model then return nil end
    local priorityParts = {"head", "torso", "HumanoidRootPart", "UpperTorso", "LowerTorso"}
    for i = 1, #priorityParts do
        local part = model:FindFirstChild(priorityParts[i])
        if part and part:IsA("BasePart") then return part end
    end
    local children = model:GetChildren()
    for i = 1, #children do
        if children[i]:IsA("BasePart") then return children[i] end
    end
    return nil
end

local function isTargetVisible(vm)
    local camera = workspace.CurrentCamera
    if not camera or not vm then return false, nil end
    
    local anchor = getBestTargetPart(vm)
    if not anchor then return false, nil end
    
    local modelParts = getModelPartsList(vm)
    local ignoreList = getIgnoreList(modelParts)
    local origin = camera.CFrame.Position
    local base = anchor.Position
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = ignoreList
    
    -- Try sample offsets, return first visible one
    for i = 1, #SAMPLE_OFFSETS do
        local targetPos = base + SAMPLE_OFFSETS[i]
        local delta = targetPos - origin
        local result = workspace:Raycast(origin, delta, raycastParams)
        if result == nil then
            return true, targetPos
        end
    end
    
    return false, nil
end

-- ─── Item configs ───────────────────────────────────────────────────────────
local itemConfigs = {
    ["Defuser"] = {Color3.fromRGB(255, 150, 0), 0.3},
    ["Claymore"] = {Color3.fromRGB(255, 0, 0), 0.3},
    ["BreachCharge"] = {Color3.fromRGB(255, 50, 50), 0.35},
    ["HardBreachCharge"] = {Color3.fromRGB(255, 30, 30), 0.3},
    ["ThermiteCharge"] = {Color3.fromRGB(255, 80, 0), 0.3},
    ["BarbedWire"] = {Color3.fromRGB(150, 150, 150), 0.6},
    ["BulletproofCamera"] = {Color3.fromRGB(0, 150, 255), 0.55},
    ["DeployableShield"] = {Color3.fromRGB(100, 100, 255), 0.65},
    ["IncendiaryCanister"] = {Color3.fromRGB(255, 100, 0), 0.4},
    ["ShockBattery"] = {Color3.fromRGB(255, 255, 0), 0.7},
    ["SignalDisruptor"] = {Color3.fromRGB(255, 0, 255), 0.5},
}

-- ─── Team check ─────────────────────────────────────────────────────────────
local function getTeamGroup(playerName)
    local children = workspace:GetChildren()
    for i = 1, #children do
        local obj = children[i]
        if obj:IsA("Model") and obj.Name == playerName then
            local teamAttr = obj:GetAttribute("Team")
            if teamAttr then return teamAttr end
        end
    end
    return nil
end

local function isEnemy(playerName)
    local localTeam = getTeamGroup(localPlayer.Name)
    local playerTeam = getTeamGroup(playerName)
    if not localTeam or not playerTeam then return true end
    return localTeam ~= playerTeam
end

-- ─── Movement detection ────────────────────────────────────────────────────
local function getPartRotations(model)
    local rotations = {}
    local parts = model:GetDescendants()
    for i = 1, #parts do
        local part = parts[i]
        if part:IsA("BasePart") then rotations[part] = part.Orientation end
    end
    return rotations
end

local function hasMovement(model)
    local currentRotations = getPartRotations(model)
    local previousRotations = rotationHistory[model]
    
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local currentPos = nil
    if hrp then currentPos = hrp.Position end
    local previousPos = positionHistory[model]
    positionHistory[model] = currentPos
    
    if previousPos and currentPos then
        local posDiff = (currentPos - previousPos).Magnitude
        if posDiff > 0.1 then
            rotationHistory[model] = currentRotations
            return true
        end
    end
    
    if not previousRotations then
        rotationHistory[model] = currentRotations
        return false
    end
    
    for part, orientation in pairs(currentRotations) do
        local prevOrientation = previousRotations[part]
        if prevOrientation then
            local diff = (orientation - prevOrientation).Magnitude
            if diff > 0.005 then
                rotationHistory[model] = currentRotations
                return true
            end
        end
    end
    
    rotationHistory[model] = currentRotations
    return false
end

local function isMoving(model)
    local now = tick()
    local currentlyMoving = hasMovement(model)
    
    if currentlyMoving then
        if not moveStartTime[model] then moveStartTime[model] = now end
        if now - moveStartTime[model] >= MOVE_THRESHOLD then
            lastMoveTime[model] = now
            confirmedMoving[model] = true
            return true
        end
    else
        moveStartTime[model] = nil
    end
    
    if lastMoveTime[model] and (now - lastMoveTime[model] < MOVE_TIMEOUT) then
        return true
    end
    
    confirmedMoving[model] = nil
    return false
end

-- ─── Viewmodel helpers ─────────────────────────────────────────────────────
local function getViewmodelPosition(vm)
    local torso = vm:FindFirstChild("torso")
    local head = vm:FindFirstChild("head")
    local target = torso or head
    if target and target:IsA("BasePart") then return target.Position end
    return nil
end

-- ─── Highlight functions ───────────────────────────────────────────────────
local function applyPlayerHighlight(vm, playerName)
    local enemy = isEnemy(playerName)
    
    if not enemy then
        viewmodelTeamCache[vm] = "teammate"
        visibilityCache[vm] = nil
        aimPositionCache[vm] = nil
        local oldHighlight = vm:FindFirstChild("PlayerHighlight")
        if oldHighlight then oldHighlight:Destroy() end
        return
    end
    
    viewmodelTeamCache[vm] = "enemy"
    
    local visible, aimPos = isTargetVisible(vm)
    visibilityCache[vm] = visible
    aimPositionCache[vm] = aimPos
    
    local oldHighlight = vm:FindFirstChild("PlayerHighlight")
    if oldHighlight then oldHighlight:Destroy() end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    
    if visible then
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    else
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    end
    
    highlight.Parent = vm
end

local function removePlayerHighlight(vm)
    local highlight = vm:FindFirstChild("PlayerHighlight")
    if highlight then highlight:Destroy() end
    viewmodelTeamCache[vm] = nil
    visibilityCache[vm] = nil
    aimPositionCache[vm] = nil
end

local function applyItemHighlights()
    for itemName, config in pairs(itemConfigs) do
        local item = workspace:FindFirstChild(itemName)
        if item and not item:FindFirstChild(itemName .. "Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = itemName .. "Highlight"
            highlight.FillTransparency = config[2]
            highlight.OutlineTransparency = math.max(0, config[2] - 0.2)
            highlight.FillColor = config[1]
            highlight.OutlineColor = config[1]
            highlight.Parent = item
        end
    end
end

local function removeItemHighlights()
    for itemName, _ in pairs(itemConfigs) do
        local item = workspace:FindFirstChild(itemName)
        if item then
            local highlight = item:FindFirstChild(itemName .. "Highlight")
            if highlight then highlight:Destroy() end
        end
    end
end

-- ─── Aimbot helpers ────────────────────────────────────────────────────────
local function getHighlightedViewmodels()
    local highlighted = {}
    local viewmodels = workspace:FindFirstChild("Viewmodels")
    if not viewmodels then return highlighted end
    
    local children = viewmodels:GetChildren()
    for i = 1, #children do
        local vm = children[i]
        if vm:IsA("Model") and vm.Name ~= "LocalViewmodel" then
            if vm:FindFirstChild("PlayerHighlight") then
                local pos = getViewmodelPosition(vm)
                if pos then highlighted[vm] = pos end
            end
        end
    end
    return highlighted
end

local function getClosestTarget()
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local highlightedViewmodels = getHighlightedViewmodels()
    local closestVm = nil
    local closestDistance = FOV_RADIUS
    
    for vm, pos in pairs(highlightedViewmodels) do
        if visibilityCache[vm] and aimPositionCache[vm] then
            local screenPos, onScreen = camera:WorldToViewportPoint(aimPositionCache[vm])
            if onScreen then
                local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
                local distance = (screenPoint - screenCenter).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestVm = vm
                end
            end
        end
    end
    
    return closestVm
end

local function aimAt(target)
    local camera = workspace.CurrentCamera
    if not camera then return end
    if not visibilityCache[target] then return end
    if not aimPositionCache[target] then return end
    
    local targetPos = aimPositionCache[target]
    local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
    if not onScreen then return end
    
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local targetScreen = Vector2.new(screenPos.X, screenPos.Y)
    local delta = targetScreen - screenCenter
    
    mousemoverel(math.floor(delta.X * (SMOOTHNESS / 10)), math.floor(delta.Y * (SMOOTHNESS / 10)))
end

-- ─── Main update ───────────────────────────────────────────────────────────
local function updateHighlights()
    local viewmodels = workspace:FindFirstChild("Viewmodels")
    if not viewmodels then return end
    
    local now = tick()
    local viewmodelChildren = viewmodels:GetChildren()
    local workspaceChildren = workspace:GetChildren()
    
    local allChars = {}
    for i = 1, #workspaceChildren do
        local obj = workspaceChildren[i]
        if obj:IsA("Model") and obj:FindFirstChildWhichIsA("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            allChars[obj] = {name = obj.Name, position = hrp.Position, moving = isMoving(obj), confirmed = confirmedMoving[obj]}
        end
    end
    
    for i = 1, #viewmodelChildren do
        local vm = viewmodelChildren[i]
        if vm:IsA("Model") and vm.Name ~= "LocalViewmodel" then
            
            if viewmodelBlacklist[vm] then
                if now - viewmodelBlacklist[vm] < BLACKLIST_DURATION then
                    removePlayerHighlight(vm)
                else
                    viewmodelBlacklist[vm] = nil
                    viewmodelMatch[vm] = nil
                end
            end
            
            if not viewmodelBlacklist[vm] then
                local vmPos = getViewmodelPosition(vm)
                if vmPos then
                    local matchedName = viewmodelMatch[vm]
                    local matchedChar = nil
                    
                    if matchedName then
                        for char, data in pairs(allChars) do
                            if data.name == matchedName then
                                if (vmPos - data.position).Magnitude < 25 then matchedChar = char end
                                break
                            end
                        end
                        if not matchedChar then viewmodelMatch[vm] = nil end
                    end
                    
                    if not matchedChar then
                        local closestName = nil
                        local closestDist = 25
                        for char, data in pairs(allChars) do
                            local dist = (vmPos - data.position).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closestName = data.name
                                matchedChar = char
                            end
                        end
                        if closestName then
                            viewmodelMatch[vm] = closestName
                            matchedName = closestName
                        end
                    end
                    
                    if matchedChar and matchedName then
                        local hasTeam = getTeamGroup(matchedName) ~= nil
                        local charData = allChars[matchedChar]
                        
                        if hasTeam or (charData and (charData.moving or charData.confirmed)) then
                            noMatchStart[vm] = nil
                            applyPlayerHighlight(vm, matchedName)
                        else
                            removePlayerHighlight(vm)
                            if not noMatchStart[vm] then
                                noMatchStart[vm] = now
                            elseif now - noMatchStart[vm] >= NO_MATCH_THRESHOLD then
                                viewmodelBlacklist[vm] = now
                                noMatchStart[vm] = nil
                                viewmodelMatch[vm] = nil
                            end
                        end
                    else
                        removePlayerHighlight(vm)
                    end
                end
            end
        end
    end
    
    applyItemHighlights()
end

local espEnabled = true
local lastUpdate = 0
local isRightMouseDown = false

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseDown = true
        currentTarget = getClosestTarget()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRightMouseDown = false
        currentTarget = nil
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if espEnabled then
        lastUpdate = lastUpdate + dt
        if lastUpdate >= 0.05 then
            lastUpdate = 0
            updateHighlights()
        end
    end
    
    if aimbotEnabled and isRightMouseDown then
        if not currentTarget or not currentTarget.Parent then
            currentTarget = getClosestTarget()
        end
        if currentTarget and visibilityCache[currentTarget] and aimPositionCache[currentTarget] then
            aimAt(currentTarget)
        end
    end
end)

local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        espEnabled = not espEnabled
        if not espEnabled then
            local viewmodels = workspace:FindFirstChild("Viewmodels")
            if viewmodels then
                local children = viewmodels:GetChildren()
                for i = 1, #children do
                    if children[i]:IsA("Model") then removePlayerHighlight(children[i]) end
                end
            end
            removeItemHighlights()
            viewmodelBlacklist = {}
            noMatchStart = {}
            viewmodelMatch = {}
            viewmodelTeamCache = {}
            visibilityCache = {}
            aimPositionCache = {}
        end
    end
end)
