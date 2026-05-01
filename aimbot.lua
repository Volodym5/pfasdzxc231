-- Phantom Forces Aimbot - Fixed target acquisition + bounding box head detection

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Mouse = LocalPlayer:GetMouse()

_G.PF_Aimbot_Settings = _G.PF_Aimbot_Settings or {
    Enabled = false,
    TeamCheck = true,
    VisibilityCheck = false,
    FOV = 100,
    TargetPart = "Head",
    Mode = "Mouse",
    Smoothness = false,
    SmoothAmount = 0.5,
    Prediction = false,
    PredAmount = 10,
    ShowFOV = false,
    FOVColor = Color3.fromRGB(255, 50, 50),
    ShowDebug = false
}

local settings = _G.PF_Aimbot_Settings
local locked = false
local currentTargetModel = nil
local currentTargetPart = nil
local enemyFolder = nil

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Radius = 100
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Filled = false
fovCircle.Transparency = 0.7

-- Find which folder contains models near our character
local function detectEnemyFolder()
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return nil end
    if not LocalPlayer.Character then return nil end
    
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local myPos = myRoot.Position
    
    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if not teamFolder:IsA("Folder") then continue end
        
        for _, model in ipairs(teamFolder:GetChildren()) do
            if not model:IsA("Model") then continue end
            
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    local dist = (part.Position - myPos).Magnitude
                    if dist < 5 then
                        for _, other in ipairs(playersFolder:GetChildren()) do
                            if other:IsA("Folder") and other ~= teamFolder then
                                return other
                            end
                        end
                    end
                end
            end
        end
    end
    
    local folders = {}
    for _, f in ipairs(playersFolder:GetChildren()) do
        if f:IsA("Folder") then
            folders[#folders + 1] = f
        end
    end
    if #folders >= 2 then
        return folders[2]
    end
    
    return nil
end

-- Head detection using bounding box (reliable, no part name dependency)
local function getHeadPosition(model)
    local cf, size = model:GetBoundingBox()
    if not cf then return nil end
    -- 80% of the way up the model = roughly head height
    return cf.Position + Vector3.new(0, size.Y * 0.4, 0)
end

local function isVisible(targetPos, model)
    local cam = workspace.CurrentCamera
    local camPos = cam.CFrame.Position
    local dir = targetPos - camPos
    local dist = dir.Magnitude
    if dist < 0.1 then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character or nil, model}
    rayParams.IgnoreWater = true
    local result = workspace:Raycast(camPos, dir.Unit * dist, rayParams)
    return result == nil
end

local function canMoveMouse()
    return not GuiService.MenuIsOpen
        and UIS:GetFocusedTextBox() == nil
        and UIS.MouseBehavior ~= Enum.MouseBehavior.LockCenter
end

local function findNewTarget(mousePos)
    local cam = workspace.CurrentCamera
    local bestModel = nil
    local bestPos = nil
    local bestDist = settings.FOV
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return nil, nil end

    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if not teamFolder:IsA("Folder") then continue end
        if settings.TeamCheck and enemyFolder and teamFolder ~= enemyFolder then continue end

        for _, model in ipairs(teamFolder:GetChildren()) do
            if not model:IsA("Model") then continue end
            
            local headPos = getHeadPosition(model)
            if not headPos then continue end

            if settings.VisibilityCheck and not isVisible(headPos, model) then continue end
            
            -- Use WorldToScreenPoint to match Mouse.X/Y coordinate space
            local screenPos, onScreen = cam:WorldToScreenPoint(headPos)
            
            -- Guard: behind camera
            if screenPos.Z < 0 then continue end
            if not onScreen then continue end
            
            local dx = screenPos.X - mousePos.X
            local dy = screenPos.Y - mousePos.Y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            if dist < bestDist then
                bestDist = dist
                bestModel = model
                bestPos = headPos
            end
        end
    end

    return bestModel, bestPos
end

local function isTargetValid(model)
    if not model or not model.Parent then return false end
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    if not model:IsDescendantOf(playersFolder) then return false end

    local headPos = getHeadPosition(model)
    if not headPos then return false end

    if settings.VisibilityCheck and not isVisible(headPos, model) then return false end
    
    local cam = workspace.CurrentCamera
    local screenPos, onScreen = cam:WorldToScreenPoint(headPos)
    if screenPos.Z < 0 then return false end
    if not onScreen then return false end
    
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local dx = screenPos.X - mousePos.X
    local dy = screenPos.Y - mousePos.Y
    local dist = math.sqrt(dx*dx + dy*dy)
    return dist < settings.FOV * 1.3
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        locked = true
        if not currentTargetModel or not isTargetValid(currentTargetModel) then
            local m, p = findNewTarget(Vector2.new(Mouse.X, Mouse.Y))
            if m and p then
                currentTargetModel = m
                currentTargetPart = nil -- we use position now, not a part reference
            end
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        locked = false
        currentTargetModel = nil
        currentTargetPart = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if not settings.Enabled then return end
    if not locked then return end

    if not enemyFolder then
        enemyFolder = detectEnemyFolder()
    end

    if not isTargetValid(currentTargetModel) then
        currentTargetModel = nil
        currentTargetPart = nil
        local m, p = findNewTarget(Vector2.new(Mouse.X, Mouse.Y))
        if m and p then
            currentTargetModel = m
        end
    end

    if not currentTargetModel then return end

    local targetPos = getHeadPosition(currentTargetModel)
    if not targetPos then
        currentTargetModel = nil
        return
    end

    -- Prediction (apply to the world position)
    -- Since we don't have a specific part, skip velocity-based prediction
    -- or use the model's PrimaryPart if it has one

    if settings.Mode == "Camera" then
        local cam = workspace.CurrentCamera
        local lookAt = CFrame.new(cam.CFrame.Position, targetPos)
        if settings.Smoothness then
            cam.CFrame = cam.CFrame:Lerp(lookAt, settings.SmoothAmount)
        else
            cam.CFrame = lookAt
        end
    elseif settings.Mode == "Mouse" then
        if canMoveMouse() then
            local cam = workspace.CurrentCamera
            local screenPos = cam:WorldToScreenPoint(targetPos)
            mousemoverel(screenPos.X - Mouse.X, screenPos.Y - Mouse.Y)
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if settings.ShowFOV then
            fovCircle.Visible = true
            fovCircle.Radius = settings.FOV
            fovCircle.Color = settings.FOVColor
            local guiInset = game:GetService("GuiService"):GetGuiInset()
            fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y + guiInset.Y)
        else
            fovCircle.Visible = false
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        enemyFolder = detectEnemyFolder()
    end
end)

print("PF Aimbot loaded - bounding box head detection + fixed screen projection")
