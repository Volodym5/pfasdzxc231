-- Phantom Forces Aimbot

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

_G.PF_Aimbot_Settings = _G.PF_Aimbot_Settings or {
    Enabled = false,
    TeamCheck = true,
    VisibilityCheck = false,
    FOV = 100,
    TargetPart = "Head",
    Mode = "Camera",
    Smoothness = false,
    SmoothAmount = 0.5,
    Prediction = false,
    PredAmount = 10,
    ShowFOV = false,
    FOVColor = Color3.fromRGB(255, 50, 50),
    ShowDebug = true
}

local settings = _G.PF_Aimbot_Settings
local locked = false
local myTeamFolder = nil
local enemyTeamFolder = nil

-- FOV circle
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Radius = 100
fovCircle.Color = Color3.fromRGB(255, 50, 50)
fovCircle.Filled = false
fovCircle.Transparency = 0.7

-- Debug text
local debugText = Drawing.new("Text")
debugText.Visible = false
debugText.Size = 14
debugText.Color = Color3.fromRGB(255, 255, 255)
debugText.Center = true
debugText.Outline = true
debugText.Font = Drawing.Fonts.Monospace
debugText.Position = Vector2.new(200, 200)

-- Debug lines
local debugLines = {}
local function clearDebugLines()
    for _, line in ipairs(debugLines) do
        pcall(function() line:Remove() end)
    end
    debugLines = {}
end

local function addDebugLine(from, to, color)
    local line = Drawing.new("Line")
    line.From = from
    line.To = to
    line.Color = color or Color3.fromRGB(255, 255, 0)
    line.Thickness = 1
    line.Transparency = 0.5
    table.insert(debugLines, line)
end

-- Detect teams by finding which folder has OUR TeamColor
local function detectTeams()
    myTeamFolder = nil
    enemyTeamFolder = nil
    
    local myTeamColor = LocalPlayer.TeamColor
    if not myTeamColor then return false end
    
    local myColorNumber = myTeamColor.Number
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    
    for _, teamFolder in ipairs(playersFolder:GetChildren()) do
        if teamFolder:IsA("Folder") then
            for _, model in ipairs(teamFolder:GetChildren()) do
                if model:IsA("Model") then
                    for _, part in ipairs(model:GetDescendants()) do
                        if part:IsA("BasePart") and part.Transparency < 0.5 then
                            local bc = part.BrickColor
                            if bc.Number == myColorNumber or bc.Name == "Earth blue" or bc.Name == "Royal blue" then
                                myTeamFolder = teamFolder
                                -- Find the other folder
                                for _, other in ipairs(playersFolder:GetChildren()) do
                                    if other:IsA("Folder") and other ~= myTeamFolder then
                                        enemyTeamFolder = other
                                    end
                                end
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

-- Find head (highest part of a model)
local function getHeadPart(model)
    local highest = nil
    local highestY = -math.huge
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.7 and part.Position.Y > highestY then
            highestY = part.Position.Y
            highest = part
        end
    end
    return highest, highestY
end

-- Find torso (middle part)
local function getTorsoPart(model)
    local parts = {}
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.7 then
            table.insert(parts, part)
        end
    end
    if #parts == 0 then return nil end
    table.sort(parts, function(a, b) return a.Position.Y > b.Position.Y end)
    return parts[math.floor(#parts / 2)]
end

local function getTargetPart(model)
    if settings.TargetPart == "Head" then
        return getHeadPart(model)
    else
        return getTorsoPart(model)
    end
end

-- Get closest enemy model from workspace.Players
local function getClosestTarget()
    clearDebugLines()
    
    local closest = nil
    local closestPart = nil
    local shortestDist = settings.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local guiInset = game:GetService("GuiService"):GetGuiInset()
    local debugInfo = ""
    
    -- Re-detect teams if needed
    if not myTeamFolder then
        detectTeams()
    end
    
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then
        debugText.Text = "No Players folder"
        debugText.Visible = true
        return nil
    end
    
    local totalModels = 0
    local enemyModels = 0
    
    -- Only scan ENEMY team folder
    local targetFolder = settings.TeamCheck and enemyTeamFolder or playersFolder
    local foldersToScan = settings.TeamCheck and {enemyTeamFolder} or playersFolder:GetChildren()
    
    for _, folder in ipairs(foldersToScan) do
        if not folder or not folder:IsA("Folder") then continue end
        
        for _, model in ipairs(folder:GetChildren()) do
            if not model:IsA("Model") then continue end
            totalModels = totalModels + 1
            
            if settings.TeamCheck and folder == myTeamFolder then continue end
            enemyModels = enemyModels + 1
            
            local targetPart = getTargetPart(model)
            if not targetPart then continue end
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if not onScreen then continue end
            
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            
            if settings.ShowDebug and dist < settings.FOV * 2 then
                local color = dist < settings.FOV and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
                addDebugLine(
                    Vector2.new(Mouse.X, Mouse.Y + guiInset.Y),
                    Vector2.new(screenPos.X, screenPos.Y),
                    color
                )
            end
            
            if dist < shortestDist then
                shortestDist = dist
                closest = model
                closestPart = targetPart
            end
        end
    end
    
    if settings.ShowDebug then
        debugInfo = debugInfo .. "My team: " .. (myTeamFolder and myTeamFolder.Name or "?") .. "\n"
        debugInfo = debugInfo .. "Enemy team: " .. (enemyTeamFolder and enemyTeamFolder.Name or "?") .. "\n"
        debugInfo = debugInfo .. "Total models: " .. totalModels .. "\n"
        debugInfo = debugInfo .. "Enemy models: " .. enemyModels .. "\n"
        debugInfo = debugInfo .. "Closest dist: " .. (closest and math.floor(shortestDist) or "none") .. "\n"
        debugInfo = debugInfo .. "FOV: " .. settings.FOV
        
        debugText.Visible = true
        debugText.Text = debugInfo
        debugText.Position = Vector2.new(Camera.ViewportSize.X / 2, 60)
    else
        debugText.Visible = false
    end
    
    return closest, closestPart
end

-- FOV circle
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

-- Hold RMB
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        locked = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        locked = false
        clearDebugLines()
        debugText.Visible = false
    end
end)

-- Aimbot
RunService.RenderStepped:Connect(function()
    if not settings.Enabled then
        clearDebugLines()
        debugText.Visible = false
        return
    end
    
    if not locked then
        clearDebugLines()
        debugText.Visible = false
        return
    end
    
    local model, targetPart = getClosestTarget()
    if not model or not targetPart then return end
    
    local targetPos = targetPart.Position
    
    if settings.Prediction and targetPart.Velocity then
        targetPos = targetPos + targetPart.Velocity * settings.PredAmount / 100
    end
    
    if settings.Mode == "Camera" then
        local lookAt = CFrame.new(Camera.CFrame.Position, targetPos)
        if settings.Smoothness then
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, settings.SmoothAmount)
        else
            Camera.CFrame = lookAt
        end
    elseif settings.Mode == "Mouse" then
        local screenPos = Camera:WorldToScreenPoint(targetPos)
        mousemoverel(screenPos.X - Mouse.X, screenPos.Y - Mouse.Y)
    end
end)

-- Re-detect teams every 3 seconds
task.spawn(function()
    while task.wait(3) do
        detectTeams()
    end
end)

print("PF Aimbot loaded - scans workspace.Players directly")
