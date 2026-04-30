-- Phantom Forces Aimbot with Debug

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

-- Find all parts that could be a head
local function getHeadPart(model)
    local highest = nil
    local highestY = -math.huge
    local partCount = 0
    
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            partCount = partCount + 1
            if part.Transparency < 0.7 and part.Position.Y > highestY then
                highestY = part.Position.Y
                highest = part
            end
        end
    end
    
    return highest, partCount
end

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

local function getTargetPart(character)
    if settings.TargetPart == "Head" then
        local head, count = getHeadPart(character)
        return head, count
    else
        return getTorsoPart(character), 0
    end
end

-- Team check
local function isTeammate(player)
    if not player.Character then return false end
    local myTeamColor = LocalPlayer.TeamColor
    if not myTeamColor then return false end
    local myColorNumber = myTeamColor.Number
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.5 then
            local bc = part.BrickColor
            if bc.Number == myColorNumber or bc.Name == "Earth blue" or bc.Name == "Royal blue" then
                return true
            end
        end
    end
    return false
end

-- Get closest target
local function getClosestTarget()
    clearDebugLines()
    
    local closest = nil
    local shortestDist = settings.FOV
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    local guiInset = game:GetService("GuiService"):GetGuiInset()
    local debugInfo = ""
    
    -- First, check workspace.Players folder
    local playersFolder = workspace:FindFirstChild("Players")
    local folderModels = 0
    
    if playersFolder then
        for _, teamFolder in ipairs(playersFolder:GetChildren()) do
            if teamFolder:IsA("Folder") then
                for _, model in ipairs(teamFolder:GetChildren()) do
                    if model:IsA("Model") then
                        folderModels = folderModels + 1
                    end
                end
            end
        end
    end
    
    -- Check all players via Players service
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        if not char then continue end
        
        local targetPart, partCount = getTargetPart(char)
        
        if not targetPart then
            -- Try finding any part
            local anyPart = char:FindFirstChildWhichIsA("BasePart")
            if not anyPart then
                -- Check if character model has children
                local childCount = 0
                for _ in ipairs(char:GetChildren()) do childCount = childCount + 1 end
                debugInfo = debugInfo .. player.Name .. ": no parts (" .. childCount .. " children)\n"
            else
                debugInfo = debugInfo .. player.Name .. ": has parts but no target\n"
            end
            continue
        end
        
        if settings.TeamCheck and isTeammate(player) then
            debugInfo = debugInfo .. player.Name .. ": teammate (skip)\n"
            continue
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then
            debugInfo = debugInfo .. player.Name .. ": off screen\n"
            continue
        end
        
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
            closest = player
        end
    end
    
    -- Show debug info
    if settings.ShowDebug then
        debugInfo = debugInfo .. "Folder models: " .. folderModels .. "\n"
        debugInfo = debugInfo .. "Players: " .. (#Players:GetPlayers() - 1) .. "\n"
        debugInfo = debugInfo .. "Closest: " .. (closest and closest.Name or "none") .. "\n"
        debugInfo = debugInfo .. "Dist: " .. (closest and math.floor(shortestDist) or "N/A") .. "\n"
        debugInfo = debugInfo .. "FOV: " .. settings.FOV
        
        debugText.Visible = true
        debugText.Text = debugInfo
        debugText.Position = Vector2.new(Camera.ViewportSize.X / 2, 50)
    else
        debugText.Visible = false
    end
    
    return closest
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
    
    local target = getClosestTarget()
    if not target then return end
    
    local targetPart, _ = getTargetPart(target.Character)
    if not targetPart then return end
    
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

print("PF Aimbot loaded")
