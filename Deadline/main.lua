-- ===== CHAMS WITH 1 SECOND NEW PLAYER DELAY + LIGHT CONTROL (EXTENDED RANGES) =====
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = workspace
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

debugX = true

local settings = {
    Enabled = true,
    TeamCheck = true,
    VisibilityCheck = true,
    VisibleColor = Color3.fromRGB(255, 50, 50),
    OccludedColor = Color3.fromRGB(255, 150, 50),
    FillTransparency = 0.75,
    OutlineTransparency = 0.5,
    -- Light control settings
    LightControl = false,
    Brightness = 0.4,
    Exposure = -0.3,
    Ambient = 0.2,
}

local highlightCache = {}
local visibilityCache = {}
local connections = {}
local cleaned = false

-- Store original lighting values
local originalBrightness = Lighting.Brightness
local originalExposure = Lighting.ExposureCompensation
local originalAmbient = Lighting.Ambient

-- New player cooldown tracking
local newPlayerCooldown = {}

-- ===== FRIENDLY INDICATOR SCANNER =====
local FriendlyIndicators = {}
local FriendlyScores = {}
local ConfirmedEnemies = {}
local EnemyConfirmations = {}

local function ScanFriendlyIndicators()
    FriendlyIndicators = {}
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    local count = 0
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if count >= 50 then break end
        if not gui:IsA("GuiObject") or not gui.Visible then continue end
        local size = gui.AbsoluteSize
        if size.X <= 0 or size.Y <= 0 or size.X >= 20 or size.Y >= 20 then continue end
        local isIndicator = false
        if gui:IsA("Frame") and gui.BackgroundTransparency < 0.9 then
            local col = gui.BackgroundColor3
            if col.G > 0.5 or col.B > 0.5 then isIndicator = true end
        elseif gui:IsA("ImageLabel") and gui.ImageTransparency < 0.5 and gui.Image ~= "" then
            isIndicator = true
        end
        if isIndicator then
            local pos = gui.AbsolutePosition
            FriendlyIndicators[count + 1] = Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2)
            count = count + 1
        end
    end
end

local function UpdateFriendlyStatus()
    if not settings.TeamCheck then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end
    
    for model in pairs(highlightCache) do
        if not model.Parent then continue end
        if ConfirmedEnemies[model] then continue end
        
        if newPlayerCooldown[model] and tick() - newPlayerCooldown[model] < 1 then
            continue
        end
        
        local root = model:FindFirstChild("humanoid_root_part") or model:FindFirstChild("head") or model:FindFirstChildWhichIsA("BasePart")
        if not root then continue end
        
        local screenPos, onScreen = cam:WorldToViewportPoint(root.Position)
        if not onScreen or screenPos.Z <= 0 then
            local confirms = EnemyConfirmations[model] or 0
            if confirms > 0 then
                EnemyConfirmations[model] = confirms + 1
                if EnemyConfirmations[model] >= 2 then
                    ConfirmedEnemies[model] = true
                    FriendlyScores[model] = nil
                end
            end
            continue
        end
        
        local screenPos2D = Vector2.new(screenPos.X, screenPos.Y)
        local foundIndicator = false
        for i = 1, #FriendlyIndicators do
            if (FriendlyIndicators[i] - screenPos2D).Magnitude < 120 then
                foundIndicator = true
                break
            end
        end
        
        local score = FriendlyScores[model] or 0
        local confirms = EnemyConfirmations[model] or 0
        
        if foundIndicator then
            score = math.min(score + 3, 6)
            confirms = math.max(confirms - 3, 0)
        else
            score = math.max(score - 1, 0)
            confirms = confirms + 3
        end
        
        FriendlyScores[model] = score
        EnemyConfirmations[model] = confirms
        
        if score >= 3 then
            ConfirmedEnemies[model] = nil
        elseif confirms >= 2 then
            FriendlyScores[model] = nil
            ConfirmedEnemies[model] = true
        elseif score <= 0 then
            FriendlyScores[model] = nil
        end
    end
end

-- Apply light control (ONLY called when values actually change)
local function ApplyLighting()
    if settings.LightControl then
        Lighting.Brightness = settings.Brightness
        Lighting.ExposureCompensation = settings.Exposure
        Lighting.Ambient = Color3.new(settings.Ambient, settings.Ambient, settings.Ambient)
        Lighting.ClockTime = 0.5
        Lighting.GlobalShadows = false
        if debugX then print("[LIGHT] Applied - Brightness:" .. string.format("%.2f", settings.Brightness) .. " Exposure:" .. string.format("%.2f", settings.Exposure) .. " Ambient:" .. string.format("%.2f", settings.Ambient)) end
    else
        -- Restore original
        Lighting.Brightness = originalBrightness
        Lighting.ExposureCompensation = originalExposure
        Lighting.Ambient = originalAmbient
        Lighting.GlobalShadows = true
        if debugX then print("[LIGHT] Restored original lighting") end
    end
end

local function fullCleanup()
    if cleaned then return end
    cleaned = true
    
    -- Restore lighting
    Lighting.Brightness = originalBrightness
    Lighting.ExposureCompensation = originalExposure
    Lighting.Ambient = originalAmbient
    Lighting.GlobalShadows = true
    
    for model, highlight in pairs(highlightCache) do
        pcall(function() highlight:Destroy() end)
    end
    highlightCache = {}
    visibilityCache = {}
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
end

local function toggleChams(state)
    settings.Enabled = state
    if not state then
        for _, highlight in pairs(highlightCache) do
            pcall(function() highlight.Enabled = false end)
        end
    else
        for model, highlight in pairs(highlightCache) do
            if model and model.Parent then
                local friendly = (FriendlyScores[model] or 0) >= 3 and not ConfirmedEnemies[model]
                if not (settings.TeamCheck and friendly) then
                    highlight.Enabled = true
                end
            end
        end
    end
    if debugX then print("[DEBUG] Chams toggled: " .. tostring(state)) end
end

-- ===== VISIBILITY =====
local function checkVisibility(model)
    local head = model:FindFirstChild("head")
    if not head then return nil end
    local camPos = Camera.CFrame.Position
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {model}
    rayParams.IgnoreWater = true
    local dir = head.Position - camPos
    local dist = dir.Magnitude
    if dist >= 0.1 then
        return Workspace:Raycast(camPos, dir.Unit * dist, rayParams) == nil
    end
    return true
end

local function createCham(model)
    if cleaned or highlightCache[model] or not settings.Enabled then return end
    visibilityCache[model] = true
    local h = Instance.new("Highlight")
    h.Name = "\0"
    h.Adornee = model
    h.Parent = gethui()
    h.FillColor = settings.VisibleColor
    h.OutlineColor = settings.VisibleColor
    h.FillTransparency = settings.FillTransparency
    h.OutlineTransparency = settings.OutlineTransparency
    h.Enabled = false
    highlightCache[model] = h
    
    newPlayerCooldown[model] = tick()
    
    task.delay(1, function()
        if cleaned or not settings.Enabled then return end
        if highlightCache[model] and model.Parent then
            local friendly = (FriendlyScores[model] or 0) >= 3 and not ConfirmedEnemies[model]
            if settings.TeamCheck and friendly then
                highlightCache[model].Enabled = false
            else
                highlightCache[model].Enabled = true
            end
            newPlayerCooldown[model] = nil
        end
    end)
end

-- ===== MAIN LOOP =====
local visQueue = {}
local visIndex = 1
local lastTeamScan = 0

local renderConnection = RunService.RenderStepped:Connect(function()
    if cleaned or not settings.Enabled then return end
    local now = tick()
    
    if settings.TeamCheck and now - lastTeamScan > 0.3 then
        lastTeamScan = now
        ScanFriendlyIndicators()
        UpdateFriendlyStatus()
    end
    
    if settings.VisibilityCheck and #visQueue > 0 then
        local checked = 0
        while checked < 3 and #visQueue > 0 do
            if visIndex > #visQueue then visIndex = 1 end
            local model = visQueue[visIndex]
            if model and model.Parent then
                local result = checkVisibility(model)
                if result ~= nil then visibilityCache[model] = result end
            else
                table.remove(visQueue, visIndex)
                visIndex = visIndex - 1
            end
            visIndex = visIndex + 1
            checked = checked + 1
        end
    end
    
    for model, highlight in pairs(highlightCache) do
        if not model.Parent then
            pcall(function() highlight:Destroy() end)
            highlightCache[model] = nil
            visibilityCache[model] = nil
            newPlayerCooldown[model] = nil
        else
            if newPlayerCooldown[model] then
                if highlight.Enabled then
                    highlight.Enabled = false
                end
                continue
            end
            
            local friendly = (FriendlyScores[model] or 0) >= 3 and not ConfirmedEnemies[model]
            
            if settings.TeamCheck and friendly then
                if highlight.Enabled then
                    highlight.Enabled = false
                end
            else
                if not highlight.Enabled then
                    highlight.Enabled = true
                end
                if settings.VisibilityCheck then
                    local visible = visibilityCache[model]
                    if visible == nil then visible = true end
                    local color = visible and settings.VisibleColor or settings.OccludedColor
                    highlight.FillColor = color
                    highlight.OutlineColor = color
                end
            end
        end
    end
end)

table.insert(connections, renderConnection)

-- ===== CHARACTER DETECTION =====
local Characters = Workspace:FindFirstChild("characters")
if Characters then
    local childAddedConn = Characters.ChildAdded:Connect(function(model)
        if cleaned or not model:IsA("Model") then return end
        createCham(model)
        visQueue[#visQueue + 1] = model
    end)
    table.insert(connections, childAddedConn)
    
    for _, model in ipairs(Characters:GetChildren()) do
        if model:IsA("Model") then
            createCham(model)
            visQueue[#visQueue + 1] = model
        end
    end
    
    local childRemovedConn = Characters.ChildRemoved:Connect(function(model)
        if highlightCache[model] then
            pcall(function() highlightCache[model]:Destroy() end)
            highlightCache[model] = nil
            visibilityCache[model] = nil
            FriendlyScores[model] = nil
            ConfirmedEnemies[model] = nil
            EnemyConfirmations[model] = nil
            newPlayerCooldown[model] = nil
        end
    end)
    table.insert(connections, childRemovedConn)
end

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.End then fullCleanup() end
end)

print("Chams loaded - New players have 1 second cooldown")
print("Press END to unload")

-- ===== RAYFIELD UI =====
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Volodym5/pfasdzxc231/refs/heads/main/lib.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Deadline Xeno - Chams",
   Icon = 0,
   LoadingTitle = "Deadline Xeno",
   LoadingSubtitle = "Chams Menu",
   Theme = "Default",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "DeadlineXeno",
      FileName = "ChamsSettings"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

-- Main Tab
local MainTab = Window:CreateTab("Chams", 4483362458)
local ToggleSection = MainTab:CreateSection("Toggle")

local ChamsToggle = MainTab:CreateToggle({
   Name = "Enable Chams",
   CurrentValue = settings.Enabled,
   Flag = "ChamsEnabled",
   Callback = function(Value)
       toggleChams(Value)
   end,
})

local SettingsSection = MainTab:CreateSection("Settings")

local TeamCheckToggle = MainTab:CreateToggle({
   Name = "Team Check (Friendly Detection)",
   CurrentValue = settings.TeamCheck,
   Flag = "TeamCheck",
   Callback = function(Value)
       settings.TeamCheck = Value
   end,
})

local VisibilityToggle = MainTab:CreateToggle({
   Name = "Visibility Check",
   CurrentValue = settings.VisibilityCheck,
   Flag = "VisibilityCheck",
   Callback = function(Value)
       settings.VisibilityCheck = Value
   end,
})

local ColorsSection = MainTab:CreateSection("Colors")

local VisibleColorPicker = MainTab:CreateColorPicker({
   Name = "Visible Color",
   Color = settings.VisibleColor,
   Flag = "VisibleColor",
   Callback = function(Color)
       settings.VisibleColor = Color
   end,
})

local OccludedColorPicker = MainTab:CreateColorPicker({
   Name = "Occluded Color",
   Color = settings.OccludedColor,
   Flag = "OccludedColor",
   Callback = function(Color)
       settings.OccludedColor = Color
   end,
})

local TransSection = MainTab:CreateSection("Transparency")

local FillTransSlider = MainTab:CreateSlider({
   Name = "Fill Transparency",
   Range = {0, 1},
   Increment = 0.05,
   Suffix = "",
   CurrentValue = settings.FillTransparency,
   Flag = "FillTrans",
   Callback = function(Value)
       settings.FillTransparency = Value
       for _, highlight in pairs(highlightCache) do
           highlight.FillTransparency = Value
       end
   end,
})

local OutlineTransSlider = MainTab:CreateSlider({
   Name = "Outline Transparency",
   Range = {0, 1},
   Increment = 0.05,
   Suffix = "",
   CurrentValue = settings.OutlineTransparency,
   Flag = "OutlineTrans",
   Callback = function(Value)
       settings.OutlineTransparency = Value
       for _, highlight in pairs(highlightCache) do
           highlight.OutlineTransparency = Value
       end
   end,
})

-- ===== MISC TAB =====
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Light Control Section
local LightSection = MiscTab:CreateSection("Light Control (Anti-Flashbang)")

local LightControlToggle = MiscTab:CreateToggle({
   Name = "Enable Light Control",
   CurrentValue = settings.LightControl,
   Flag = "LightControl",
   Callback = function(Value)
       settings.LightControl = Value
       ApplyLighting()
   end,
})

-- Brightness Slider (-2 to 2)
local BrightnessSlider = MiscTab:CreateSlider({
   Name = "Brightness (-2 to 2, Lower = Darker)",
   Range = {-2, 2},
   Increment = 0.05,
   Suffix = "",
   CurrentValue = settings.Brightness,
   Flag = "Brightness",
   Callback = function(Value)
       settings.Brightness = Value
       if settings.LightControl then
           ApplyLighting()
       end
   end,
})

-- Exposure Slider (-2 to 2)
local ExposureSlider = MiscTab:CreateSlider({
   Name = "Exposure (-2 to 2, Negative = Darker)",
   Range = {-2, 2},
   Increment = 0.05,
   Suffix = "",
   CurrentValue = settings.Exposure,
   Flag = "Exposure",
   Callback = function(Value)
       settings.Exposure = Value
       if settings.LightControl then
           ApplyLighting()
       end
   end,
})

-- Ambient Slider (-2 to 2)
local AmbientSlider = MiscTab:CreateSlider({
   Name = "Ambient Light (-2 to 2, Lower = Darker)",
   Range = {-2, 2},
   Increment = 0.05,
   Suffix = "",
   CurrentValue = settings.Ambient,
   Flag = "Ambient",
   Callback = function(Value)
       settings.Ambient = Value
       if settings.LightControl then
           ApplyLighting()
       end
   end,
})

local ResetLighting = MiscTab:CreateButton({
   Name = "Reset Lighting to Default",
   Callback = function()
       settings.Brightness = originalBrightness or 1
       settings.Exposure = originalExposure or 0
       settings.Ambient = 0.3
       
       -- Update slider displays
       BrightnessSlider:SetValue(settings.Brightness)
       ExposureSlider:SetValue(settings.Exposure)
       AmbientSlider:SetValue(settings.Ambient)
       
       if settings.LightControl then
           ApplyLighting()
       else
           -- Restore original even if disabled
           Lighting.Brightness = originalBrightness
           Lighting.ExposureCompensation = originalExposure
           Lighting.Ambient = originalAmbient
           Lighting.GlobalShadows = true
       end
   end,
})

local LightInfo = MiscTab:CreateLabel("Extended ranges: -2 to 2 for all values\nLower brightness/exposure = less flashbang\nRecommended: Brightness -0.5 to 0, Exposure -1 to -0.5")

-- Utility Section
local UtilSection = MiscTab:CreateSection("Utility")

local UnloadButton = MiscTab:CreateButton({
   Name = "Unload Script",
   Callback = function()
       fullCleanup()
       Rayfield:Destroy()
   end,
})

Rayfield:LoadConfiguration()

-- Apply initial lighting if enabled
if settings.LightControl then
    ApplyLighting()
end