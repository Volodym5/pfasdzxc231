local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Settings
getgenv().Config = {
    SilentAim = true,
    Chams = true,
    FOV = 150,
    ShowFOV = true,
    VisibilityCheck = true,
    HitChance = 100,
    TeamCheck = false,
    TargetPart = "Head"
}

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

-- Get Closest Target
local function GetClosest()
    local Camera = Workspace.CurrentCamera
    if not Camera then return nil end
    
    local MousePos = UserInputService:GetMouseLocation()
    local Closest = nil
    local BestDist = Config.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if Config.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                local targetPart = player.Character:FindFirstChild(Config.TargetPart) or player.Character:FindFirstChild("Head")
                if targetPart then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
                        if dist < BestDist then
                            if not Config.VisibilityCheck or IsVisible(targetPart) then
                                Closest = targetPart
                                BestDist = dist
                            end
                        end
                    end
                end
            end
        end
    end
    
    return Closest
end

-- Silent Aim
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if Config.SilentAim and CurrentTarget and not checkcaller() then
        if self == Workspace and (method == "Raycast" or method == "raycast") then
            local origin = args[1]
            local direction = args[2]
            
            if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                if direction.Magnitude > 50 then
                    if math.random(1, 100) <= Config.HitChance then
                        args[2] = (CurrentTarget.Position - origin).Unit * direction.Magnitude
                        return oldNamecall(self, unpack(args))
                    end
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
    
    -- Remove old chams first
    for _, highlight in pairs(chams) do
        if highlight and highlight.Parent and highlight.Parent:IsDescendantOf(character) then
            highlight:Destroy()
        end
    end
    
    local highlights = {}
    local addedParts = {}
    
    -- Function to add highlight to a part
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
    
    -- Add highlights to all body parts
    for _, partName in pairs(R15_PARTS) do
        local part = character:FindFirstChild(partName)
        if part then
            addHighlight(part)
        end
    end
    
    -- Store highlights
    chams[character] = highlights
    
    -- Listen for new parts being added
    character.DescendantAdded:Connect(function(descendant)
        if Config.Chams and table.find(R15_PARTS, descendant.Name) and descendant:IsA("BasePart") then
            task.wait() -- Wait a frame for the part to initialize
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
        -- Wait for the character to fully load
        character:WaitForChild("HumanoidRootPart", 10)
        
        -- Wait a bit more to ensure all parts are loaded
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

-- Re-check chams periodically for missing parts
task.spawn(function()
    while task.wait(1) do
        if Config.Chams then
            for character, highlights in pairs(chams) do
                if character and character.Parent then
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
end)

-- Rainbow Color
local function GetRainbow(offset)
    local hue = (tick() * 0.5 + offset) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Update FOV
    if Config.ShowFOV then
        FovCircle.Position = UserInputService:GetMouseLocation()
        FovCircle.Radius = Config.FOV
        FovCircle.Visible = Config.SilentAim
    else
        FovCircle.Visible = false
    end
    
    -- Update Target
    if Config.SilentAim then
        CurrentTarget = GetClosest()
    else
        CurrentTarget = nil
    end
    
    -- Update Chams Colors
    if Config.Chams then
        local index = 0
        for character, highlights in pairs(chams) do
            local color = GetRainbow(index * 0.3)
            for _, highlight in pairs(highlights) do
                if highlight and highlight.Parent then
                    highlight.FillColor = color
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                end
            end
            index = index + 1
        end
    end
end)
