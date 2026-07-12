-- Fixed Aimbot & ESP
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Game constants (with fallback)
local Constant
local success, result = pcall(function()
    Constant = require(ReplicatedStorage.Constant)
end)
if not success then
    Constant = { Tag = { GameClient = "GameClient" } }
end

-- Variables
local aimbotEnabled = false
local smoothness = 50
local fovRadius = 100
local fovVisible = false
local fovColor = Color3.fromRGB(255, 255, 255)
local fovTransparency = 0.7
local targetPart = "Head"
local teamCheck = true
local visibleCheck = true
local autoRespawn = false
local fastRespawn = false

local espEnabled = false
local fillColor = Color3.fromRGB(255, 0, 0)
local outlineColor = Color3.fromRGB(255, 255, 255)
local fillTransparency = 0.5
local outlineTransparency = 0
local espTeamCheck = true
local showPlayers = true
local showBots = true

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Radius = fovRadius
fovCircle.Color = fovColor
fovCircle.Transparency = fovTransparency

-- ESP Storage
local highlights = {}
local trackedCharacters = {}

-- Cache
local targetCache = {}
local lastCacheUpdate = 0

-- Get your team
local function getMyTeam()
    return LocalPlayer:GetAttribute("Team")
end

-- Check if model is a game client (player or bot)
local function isGameClient(model)
    if not model then return false end
    if not model:IsA("Model") then return false end
    
    local hasTag = model:HasTag(Constant.Tag.GameClient)
    if hasTag then return true end
    
    if Players:GetPlayerFromCharacter(model) then return true end
    
    return false
end

-- Check if model is a bot
local function isBot(model)
    if not model then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    
    local fakeId = model:GetAttribute("FakeUserId")
    if fakeId then return true end
    
    return false
end

-- Check if model is a real player
local function isRealPlayer(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

-- Fast visibility check (no cache, instant)
local function isVisible(part)
    if not part then return false end
    
    local cameraPos = Camera.CFrame.Position
    local partPos = part.Position
    local direction = partPos - cameraPos
    
    -- Skip if too far (optimization)
    if direction.Magnitude > 500 then return false end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local ignoreList = {}
    if LocalPlayer.Character then
        table.insert(ignoreList, LocalPlayer.Character)
    end
    local cameraFolder = Workspace:FindFirstChild("Camera")
    if cameraFolder then
        for _, name in pairs({"Human", "Blocker", "Placeholder"}) do
            local obj = cameraFolder:FindFirstChild(name)
            if obj then table.insert(ignoreList, obj) end
        end
    end
    rayParams.FilterDescendantsInstances = ignoreList
    
    local rayResult = Workspace:Raycast(cameraPos, direction, rayParams)
    
    if rayResult then
        local hitPart = rayResult.Instance
        
        -- Transparent objects don't block
        if hitPart.Transparency > 0.8 then
            return true
        end
        
        -- Check if we hit the target or something belonging to it
        if part.Parent and hitPart:IsDescendantOf(part.Parent) then
            return true
        end
        
        return false
    end
    
    return true
end

-- Check if target is valid (without visibility check for caching)
local function isValidTargetBasic(character)
    if not character then return false end
    if character == LocalPlayer.Character then return false end
    if not isGameClient(character) then return false end
    
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return false end
    
    local health = character:GetAttribute("Health")
    local state = character:GetAttribute("State")
    
    if health and tonumber(health) and tonumber(health) <= 0 then return false end
    if state and state == "Dead" then return false end
    if humanoid.Health <= 0 then return false end
    
    if not showPlayers and isRealPlayer(character) then return false end
    if not showBots and isBot(character) then return false end
    
    if teamCheck then
        local myTeam = getMyTeam()
        local targetTeam = character:GetAttribute("Team")
        if myTeam and targetTeam and myTeam ~= "" and targetTeam ~= "" and myTeam == targetTeam then
            return false
        end
    end
    
    return true
end

-- Scan targets with caching (no visibility checks here)
local function getTargets(forceRefresh)
    local now = tick()
    if not forceRefresh and now - lastCacheUpdate < 0.5 then
        return targetCache
    end
    
    local targets = {}
    local scanned = {}
    
    local function scan(parent, depth)
        if depth > 100 then return end
        if not parent then return end
        
        for _, child in pairs(parent:GetChildren()) do
            if child and not scanned[child] then
                scanned[child] = true
                
                if child:IsA("Model") and isGameClient(child) and isValidTargetBasic(child) then
                    local part = child:FindFirstChild(targetPart) or child:FindFirstChild("HumanoidRootPart")
                    table.insert(targets, {
                        character = child,
                        part = part
                    })
                end
                
                if child:IsA("Folder") or child:IsA("Model") then
                    scan(child, depth + 1)
                end
            end
        end
    end
    
    scan(Workspace, 0)
    
    targetCache = targets
    lastCacheUpdate = now
    return targets
end

-- Get dynamic FOV based on camera zoom
local function getDynamicFOV()
    local baseFOV = 70
    local currentFOV = Camera.FieldOfView
    local scale = baseFOV / math.max(currentFOV, 1)
    return fovRadius * scale
end

-- Get closest target (with instant visibility check on candidates)
local function getClosestTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local closest = nil
    local closestDist = getDynamicFOV()
    
    local targets = getTargets()
    
    for _, targetData in pairs(targets) do
        local part = targetData.part
        if part then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < closestDist then
                    -- Only check visibility for close candidates (instant check)
                    if not visibleCheck or isVisible(part) then
                        closestDist = dist
                        closest = part
                    end
                end
            end
        end
    end
    
    return closest
end

-- Smooth aim
local function smoothAim(currentPos, targetPos)
    local delta = targetPos - currentPos
    
    local speedFactor
    if smoothness <= 1 then
        speedFactor = 1
    elseif smoothness <= 30 then
        speedFactor = 0.6 + (0.4 * (1 - smoothness / 30))
    elseif smoothness <= 60 then
        speedFactor = 0.3 + (0.3 * (1 - (smoothness - 30) / 30))
    elseif smoothness <= 90 then
        speedFactor = 0.1 + (0.2 * (1 - (smoothness - 60) / 30))
    else
        speedFactor = 0.05 + (0.05 * (1 - (smoothness - 90) / 10))
    end
    
    if delta.Magnitude < 1 then
        return currentPos
    end
    
    return currentPos + (delta * speedFactor)
end

-- Aimbot
local aimbotConnection
local function startAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() end
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        local dynFOV = getDynamicFOV()
        fovCircle.Radius = dynFOV
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        if not aimbotEnabled then return end
        
        local isHolding = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if not isHolding then return end
        
        local target = getClosestTarget()
        if not target then return end
        
        local screenPos = Camera:WorldToViewportPoint(target.Position)
        local targetPos2D = Vector2.new(screenPos.X, screenPos.Y)
        local mousePos = UserInputService:GetMouseLocation()
        
        local newPos = smoothAim(mousePos, targetPos2D)
        
        local moveX = newPos.X - mousePos.X
        local moveY = newPos.Y - mousePos.Y
        
        if math.abs(moveX) > 0.1 or math.abs(moveY) > 0.1 then
            mousemoverel(moveX, moveY)
        end
    end)
end

local function stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

-- Auto respawn
local respawnConnection
local function startAutoRespawn()
    if respawnConnection then respawnConnection:Disconnect() end
    
    respawnConnection = RunService.Heartbeat:Connect(function()
        if not autoRespawn then return end
        
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if humanoid and humanoid.Health <= 0 then
            pcall(function()
                ReplicatedStorage.Remote.GameService.Respawn:FireServer()
            end)
        end
    end)
end

local function stopAutoRespawn()
    if respawnConnection then
        respawnConnection:Disconnect()
        respawnConnection = nil
    end
end

-- ESP Functions
local function addChams(character)
    if not character or trackedCharacters[character] then return end
    
    local health = character:GetAttribute("Health")
    local state = character:GetAttribute("State")
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if health and tonumber(health) and tonumber(health) <= 0 then return end
    if state and state == "Dead" then return end
    if humanoid and humanoid.Health <= 0 then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = fillColor
    highlight.OutlineColor = outlineColor
    highlight.FillTransparency = fillTransparency
    highlight.OutlineTransparency = outlineTransparency
    highlight.Parent = character
    
    highlights[character] = highlight
    trackedCharacters[character] = true
end

local function removeAllChams()
    for _, highlight in pairs(highlights) do
        if highlight then highlight:Destroy() end
    end
    highlights = {}
    trackedCharacters = {}
end

local function updateAllChams()
    for _, highlight in pairs(highlights) do
        if highlight then
            highlight.FillColor = fillColor
            highlight.OutlineColor = outlineColor
            highlight.FillTransparency = fillTransparency
            highlight.OutlineTransparency = outlineTransparency
        end
    end
end

local function refreshESP()
    removeAllChams()
    if not espEnabled then return end
    
    local targets = getTargets(true)
    for _, targetData in pairs(targets) do
        addChams(targetData.character)
    end
end

-- Watch for new spawns
Workspace.DescendantAdded:Connect(function(descendant)
    if espEnabled and descendant:IsA("Model") and isGameClient(descendant) then
        wait(0.5)
        if isValidTargetBasic(descendant) then
            addChams(descendant)
        end
    end
end)

Workspace.DescendantRemoving:Connect(function(descendant)
    if trackedCharacters[descendant] then
        local highlight = highlights[descendant]
        if highlight then highlight:Destroy() end
        highlights[descendant] = nil
        trackedCharacters[descendant] = nil
    end
end)

-- Periodic refresh
spawn(function()
    while true do
        wait(2)
        if espEnabled then refreshESP() end
    end
end)

-- FOV circle update
local function updateFOV()
    fovCircle.Visible = fovVisible
    fovCircle.Radius = fovRadius
    fovCircle.Color = fovColor
    fovCircle.Transparency = fovTransparency
end

-- ==================== UI ====================
loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/lib/source.lua"))()

local Library = getgenv().Library
local SaveManager = Library.SaveManager

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()

local Window = Library:CreateWindow({
    Title = "Aimbot & ESP",
    Footer = "FFA/TDM",
    Size = UDim2.fromOffset(600, 500),
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightShift,
    ConfigFolder = "AimbotESP",
})

local AimbotTab = Window:AddTab("Aimbot", "rbxassetid://6031265976")
local ESPTab = Window:AddTab("ESP", "rbxassetid://6031082533")

-- AIMBOT TAB
local AimLeft = AimbotTab:AddLeftGroupbox("Aimbot")
local AimRight = AimbotTab:AddRightGroupbox("FOV")

AimLeft:AddToggle("AimbotEnabled", {
    Text = "Enable Aimbot",
    Default = false,
    Callback = function(v)
        aimbotEnabled = v
        if v then startAimbot() else stopAimbot() end
    end,
})

AimLeft:AddSlider("Smoothness", {
    Text = "Smoothness",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Suffix = "%",
    Callback = function(v) smoothness = v end,
})

AimLeft:AddDropdown("TargetPart", {
    Text = "Target Part",
    Default = "Head",
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Callback = function(v) targetPart = v end,
})

AimLeft:AddToggle("TeamCheck", {
    Text = "Team Check",
    Default = true,
    Callback = function(v) teamCheck = v end,
})

AimLeft:AddToggle("VisibleCheck", {
    Text = "Visible Only",
    Default = true,
    Tooltip = "Only aim at visible targets (instant check)",
    Callback = function(v) visibleCheck = v end,
})

AimLeft:AddLabel("Hold Right Mouse to aim")

AimRight:AddToggle("FOVVisible", {
    Text = "Show FOV",
    Default = false,
    Callback = function(v)
        fovVisible = v
        fovCircle.Visible = v
    end,
})

AimRight:AddSlider("FOVRadius", {
    Text = "FOV Radius",
    Default = 100,
    Min = 25,
    Max = 500,
    Rounding = 0,
    Suffix = "px",
    Callback = function(v) fovRadius = v end,
})

AimRight:AddLabel("FOV Color"):AddColorPicker("FOVColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(v) fovColor = v end,
})

AimRight:AddSlider("FOVTransparency", {
    Text = "FOV Transparency",
    Default = 0.7,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Callback = function(v) fovTransparency = v end,
})

-- ESP TAB
local ESPLeft = ESPTab:AddLeftGroupbox("ESP Controls")
local ESPRight = ESPTab:AddRightGroupbox("Colors")

ESPLeft:AddToggle("ESPEnabled", {
    Text = "Enable ESP",
    Default = false,
    Callback = function(v)
        espEnabled = v
        if v then refreshESP() else removeAllChams() end
    end,
})

ESPLeft:AddToggle("ESPTeamCheck", {
    Text = "Team Check",
    Default = true,
    Callback = function(v)
        espTeamCheck = v
        if espEnabled then refreshESP() end
    end,
})

ESPLeft:AddToggle("ShowPlayers", {
    Text = "Show Players",
    Default = true,
    Callback = function(v)
        showPlayers = v
        if espEnabled then refreshESP() end
    end,
})

ESPLeft:AddToggle("ShowBots", {
    Text = "Show Bots",
    Default = true,
    Callback = function(v)
        showBots = v
        if espEnabled then refreshESP() end
    end,
})

ESPRight:AddLabel("Fill Color"):AddColorPicker("FillColor", {
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(v)
        fillColor = v
        updateAllChams()
    end,
})

ESPRight:AddLabel("Outline Color"):AddColorPicker("OutlineColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(v)
        outlineColor = v
        updateAllChams()
    end,
})

ESPRight:AddSlider("FillTransparency", {
    Text = "Fill Transparency",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Callback = function(v)
        fillTransparency = v
        updateAllChams()
    end,
})

ESPRight:AddSlider("OutlineTransparency", {
    Text = "Outline Transparency",
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 1,
    Callback = function(v)
        outlineTransparency = v
        updateAllChams()
    end,
})
