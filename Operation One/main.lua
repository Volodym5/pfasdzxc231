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

local transparentParts = {}
local lastTransparentScan = 0

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

local function updateTransparentCache()
    local now = tick()
    if now - lastTransparentScan < 10 then return end
    lastTransparentScan = now
    
    local allParts = workspace:GetDescendants()
    for i = 1, #allParts do
        local part = allParts[i]
        if part:IsA("BasePart") and part.Transparency >= 0.95 then
            local alreadyInList = false
            for j = 1, #transparentParts do
                if transparentParts[j] == part then
                    alreadyInList = true
                    break
                end
            end
            if not alreadyInList then
                transparentParts[#transparentParts + 1] = part
            end
        end
    end
end

local function getTeamGroup(playerName)
    local children = workspace:GetChildren()
    for i = 1, #children do
        local obj = children[i]
        if obj:IsA("Model") and obj.Name == playerName then
            local teamAttr = obj:GetAttribute("Team")
            if teamAttr then
                return teamAttr
            end
        end
    end
    return nil
end

local function getPartRotations(model)
    local rotations = {}
    local parts = model:GetDescendants()
    for i = 1, #parts do
        local part = parts[i]
        if part:IsA("BasePart") then
            rotations[part] = part.Orientation
        end
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
        if not moveStartTime[model] then
            moveStartTime[model] = now
        end
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

local function getViewmodelPosition(vm)
    local torso = vm:FindFirstChild("torso")
    local head = vm:FindFirstChild("head")
    local target = torso or head
    if target and target:IsA("BasePart") then
        return target.Position
    end
    return nil
end

local function isEnemy(playerName)
    local localTeam = getTeamGroup(localPlayer.Name)
    local playerTeam = getTeamGroup(playerName)
    if not localTeam or not playerTeam then return true end
    return localTeam ~= playerTeam
end

local function isTargetVisible(vm)
    local camera = workspace.CurrentCamera
    if not camera then return false end
    
    local targetPos = getViewmodelPosition(vm)
    if not targetPos then return false end
    
    local head = vm:FindFirstChild("head")
    if head and head:IsA("BasePart") then
        targetPos = head.Position
    end
    
    local origin = camera.CFrame.Position
    local direction = (targetPos - origin).Unit
    local distance = (targetPos - origin).Magnitude
    
    local ignoreList = {}
    for i = 1, #transparentParts do
        ignoreList[#ignoreList + 1] = transparentParts[i]
    end
    
    local vmParts = vm:GetDescendants()
    for i = 1, #vmParts do
        if vmParts[i]:IsA("BasePart") then
            ignoreList[#ignoreList + 1] = vmParts[i]
        end
    end
    
    if localPlayer.Character then
        local parts = localPlayer.Character:GetDescendants()
        for i = 1, #parts do
            if parts[i]:IsA("BasePart") then
                ignoreList[#ignoreList + 1] = parts[i]
            end
        end
    end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = ignoreList
    
    local result = workspace:Raycast(origin, direction * distance, raycastParams)
    return result == nil
end

local function applyPlayerHighlight(vm, playerName)
    local enemy = isEnemy(playerName)
    
    if not enemy then
        viewmodelTeamCache[vm] = "teammate"
        visibilityCache[vm] = nil
        local oldHighlight = vm:FindFirstChild("PlayerHighlight")
        if oldHighlight then oldHighlight:Destroy() end
        return
    end
    
    viewmodelTeamCache[vm] = "enemy"
    
    local visible = isTargetVisible(vm)
    visibilityCache[vm] = visible
    
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
end

local function applyItemHighlights()
    for itemName, config in pairs(itemConfigs) do
        local item = workspace:FindFirstChild(itemName)
        if item then
            local highlightName = itemName .. "Highlight"
            if not item:FindFirstChild(highlightName) then
                local highlight = Instance.new("Highlight")
                highlight.Name = highlightName
                highlight.FillTransparency = config[2]
                highlight.OutlineTransparency = math.max(0, config[2] - 0.2)
                highlight.FillColor = config[1]
                highlight.OutlineColor = config[1]
                highlight.Parent = item
            end
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
        -- Only target visible enemies
        if visibilityCache[vm] then
            local screenPos, onScreen = camera:WorldToViewportPoint(pos)
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
    
    local pos = getViewmodelPosition(target)
    if not pos then return end
    
    local head = target:FindFirstChild("head")
    if head and head:IsA("BasePart") then pos = head.Position end
    
    local screenPos, onScreen = camera:WorldToViewportPoint(pos)
    if not onScreen then return end
    
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local targetScreen = Vector2.new(screenPos.X, screenPos.Y)
    local delta = targetScreen - screenCenter
    
    mousemoverel(math.floor(delta.X * (SMOOTHNESS / 10)), math.floor(delta.Y * (SMOOTHNESS / 10)))
end

local function updateHighlights()
    updateTransparentCache()
    
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
            allChars[obj] = {
                name = obj.Name,
                position = hrp.Position,
                moving = isMoving(obj),
                confirmed = confirmedMoving[obj]
            }
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
                                local dist = (vmPos - data.position).Magnitude
                                if dist < 25 then matchedChar = char end
                                break
                            end
                        end
                        if not matchedChar then
                            matchedName = nil
                            viewmodelMatch[vm] = nil
                        end
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
        if lastUpdate >= 0.1 then
            lastUpdate = 0
            updateHighlights()
        end
    end
    
    if aimbotEnabled and isRightMouseDown then
        if not currentTarget or not currentTarget.Parent then
            currentTarget = getClosestTarget()
        end
        if currentTarget and visibilityCache[currentTarget] then
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
                    local vm = children[i]
                    if vm:IsA("Model") then removePlayerHighlight(vm) end
                end
            end
            removeItemHighlights()
            viewmodelBlacklist = {}
            noMatchStart = {}
            viewmodelMatch = {}
            viewmodelTeamCache = {}
            visibilityCache = {}
        end
    end
end)
