loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/lib/source.lua"))()
local Library = getgenv().Library
local SaveManager = Library.SaveManager

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UIS = UserInputService

-- Settings
local Settings = {
    Aimbot = { Enabled = false, Smoothness = 5, FOV = 200, TeamCheck = true, VisCheck = false },
    ESP = { Enabled = false, TeamCheck = true },
    Bunnyhop = { Enabled = false },
    NoRecoil = { Enabled = false },
    Ragebot = { Enabled = false },
    Wallbang = { Enabled = false },
    DeleteMap = { Enabled = false }
}

-- ===== OPTIMIZED CACHE =====
local charactersFolder = nil
local myTeam = nil
local lastTeamCheck = 0
local lastTargetScan = 0
local lastESPUpdate = 0
local lastPlatformUpdate = 0
local cachedTargets = {}
local espCache = {}
local screenCenter = Vector2.new()
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local bhopReady = true
local playerModule = nil
local crouchOffset = 0
local platform = nil
local recoilData = {}
local removedParts = {}
local wasWallbanging = false
local rageShotCount = 0
local rageLastShot = 0
local kicked = false
local geometryBackup = nil
local geometryDeleted = false
local mapTrashDeleted = false

-- Staff list
local StaffList = {
    "SwipeGamesHolder","MaloniPepperoni","Fwoggyzs","Warm_Vibes","wookey12","OilyDev","IBrawlMonkeys","YTGonzo",
    "PrimeFIRE94","Bigzell","SmoothestGorilla","Aylaa","twqox","Bluay","jUan1to_45","sxyq","shad9ws","Veinze",
    "Summerek2137","Solarynin","K_irsha","6md6","grouperina1","Killergrad","X3EN0","MrShmunk","RealCalculus",
    "e8_Bl","minimeleeking","Ghostoffrec","meisu7","NotCanyy","Thraggorian","Turtlepla","georgiTgorgi","pitybite",
    "Hurb005","willy7603","Fliz25","Rex10590","c5evo","Gifted_Milo","GWTanaka","rajkoou","ashhgotbandz","ToeNae",
    "Rankingbeast","AltForTrashSkinsCB","PingTheChad","XWhite_EXE","ni3smi4ly"
}

-- ===== FAST STAFF CHECK =====
local function IsStaffInGame()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local name = player.Name
            local display = player.DisplayName
            for i = 1, #StaffList do
                local s = StaffList[i]
                if name == s or display == s then return true end
            end
        end
    end
    return false
end

local function LeaveGame()
    if kicked then return end
    kicked = true
    LocalPlayer:Kick("Staff detected")
end

-- ===== FAST TEAM CHECK (cached 1s) =====
local function UpdateTeam()
    local now = tick()
    if now - lastTeamCheck < 1 then return end
    lastTeamCheck = now
    local char = LocalPlayer.Character
    if not char then myTeam = nil; charactersFolder = nil; return end
    local cf = Workspace:FindFirstChild("Characters")
    charactersFolder = cf
    if not cf then myTeam = nil; return end
    for _, folder in ipairs(cf:GetChildren()) do
        if folder:IsA("Folder") then
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") and model.Name == LocalPlayer.Name then
                    myTeam = folder.Name
                    return
                end
            end
        end
    end
    myTeam = nil
end

-- ===== FAST MODEL VALIDATION =====
local function IsModelAlive(model)
    if model:GetAttribute("Dead") == true then return false end
    if model:GetAttribute("Invincible") == true then return false end
    if not model:FindFirstChild("Head") then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    return true
end

-- ===== FAST TARGET SCAN (cached 100ms) =====
local function GetTargets(teamCheck)
    local now = tick()
    if now - lastTargetScan < 0.1 then return cachedTargets end
    lastTargetScan = now
    UpdateTeam()
    local targets = {}
    local cf = charactersFolder
    if not cf then cachedTargets = targets; return targets end
    for _, folder in ipairs(cf:GetChildren()) do
        if folder:IsA("Folder") and folder.Name ~= "Hostages" then
            if teamCheck and folder.Name == myTeam then continue end
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") and model ~= LocalPlayer.Character and IsModelAlive(model) then
                    targets[#targets + 1] = model
                end
            end
        end
    end
    cachedTargets = targets
    return targets
end

-- ===== FAST VISIBILITY =====
local function IsVisible(model)
    local head = model:FindFirstChild("Head")
    if not head then return false end
    local origin = Camera.CFrame.Position
    local direction = head.Position - origin
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local result = Workspace:Raycast(origin, direction, rayParams)
    if not result then return true end
    local hit = result.Instance
    while hit do
        if hit == model then return true end
        hit = hit.Parent
    end
    return false
end

-- ===== FAST ESP (cached 250ms) =====
local function UpdateESP()
    if not Settings.ESP.Enabled then
        for _, hl in pairs(espCache) do pcall(function() hl:Destroy() end) end
        espCache = {}
        return
    end
    local now = tick()
    if now - lastESPUpdate < 0.25 then
        for _, hl in pairs(espCache) do if hl.Parent then hl.Enabled = true end end
        return
    end
    lastESPUpdate = now
    local targets = GetTargets(Settings.ESP.TeamCheck)
    local active = {}
    for _, model in ipairs(targets) do
        active[model] = true
        local hl = espCache[model]
        if hl and hl.Parent then
            hl.Enabled = true
        else
            pcall(function()
                hl = Instance.new("Highlight")
                hl.Adornee = model
                hl.Parent = model
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillColor = Color3.fromRGB(255, 60, 60)
                hl.OutlineColor = Color3.fromRGB(255, 60, 60)
                hl.FillTransparency = 0.75
                hl.OutlineTransparency = 0.55
                hl.Enabled = true
                espCache[model] = hl
            end)
        end
    end
    for model, hl in pairs(espCache) do
        if not active[model] then
            pcall(function() hl:Destroy() end)
            espCache[model] = nil
        end
    end
end

-- ===== BUNNYHOP =====
local function RunBunnyhop()
    if not Settings.Bunnyhop.Enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.FloorMaterial == Enum.Material.Air or not bhopReady then return end
    bhopReady = false
    if not playerModule then
        pcall(function() playerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")) end)
    end
    if playerModule then
        pcall(function()
            local ctrl = playerModule:GetControls()
            if ctrl and ctrl.activeController then
                ctrl.activeController.isJumping = true
                task.wait(0.005)
                ctrl.activeController.isJumping = false
            end
        end)
    end
    task.wait(0.005)
    bhopReady = true
end

-- ===== AIMBOT =====
local function RunAimbot()
    if not Settings.Aimbot.Enabled then return end
    local targets = GetTargets(Settings.Aimbot.TeamCheck)
    if #targets == 0 then return end
    local fov = Settings.Aimbot.FOV
    local smoothness = Settings.Aimbot.Smoothness
    local visCheck = Settings.Aimbot.VisCheck
    screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestDist = fov * fov
    local bestX, bestY = nil, nil
    for i = 1, #targets do
        local model = targets[i]
        if visCheck and not IsVisible(model) then continue end
        local head = model:FindFirstChild("Head")
        if not head then continue end
        local pos, onScreen = Camera:WorldToScreenPoint(head.Position)
        if not onScreen then continue end
        local dx = pos.X - screenCenter.X
        local dy = pos.Y - screenCenter.Y
        local dist = dx * dx + dy * dy
        if dist < bestDist then
            bestDist = dist
            bestX = pos.X
            bestY = pos.Y
        end
    end
    if not bestX then return end
    local dx = bestX - Mouse.X
    local dy = bestY - Mouse.Y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist < 2 then
        mousemoverel(dx, dy)
    else
        local stepX = dx / smoothness
        local stepY = dy / smoothness
        if math.abs(stepX) < 1 and math.abs(dx) > 0 then stepX = dx > 0 and 1 or -1 end
        if math.abs(stepY) < 1 and math.abs(dy) > 0 then stepY = dy > 0 and 1 or -1 end
        mousemoverel(stepX, stepY)
    end
end

-- ===== RAGEBOT AIM =====
local function RageAimAtClosest()
    if not Settings.Ragebot.Enabled then return end
    local cf = charactersFolder or Workspace:FindFirstChild("Characters")
    if not cf then return end
    local sc = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestDist = 999999
    local bestX, bestY = nil, nil
    for _, folder in ipairs(cf:GetChildren()) do
        if not folder:IsA("Folder") or folder.Name == "Hostages" then continue end
        for _, model in ipairs(folder:GetChildren()) do
            if not model:IsA("Model") or model == LocalPlayer.Character then continue end
            if not IsModelAlive(model) then continue end
            local head = model:FindFirstChild("Head")
            if not head then continue end
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            if head.Position.Magnitude < 10 then continue end
            local pos, onScreen = Camera:WorldToScreenPoint(head.Position)
            if not onScreen then continue end
            local dx = pos.X - sc.X
            local dy = pos.Y - sc.Y
            local dist = dx * dx + dy * dy
            if dist < bestDist then
                bestDist = dist
                bestX = pos.X
                bestY = pos.Y
            end
        end
    end
    if not bestX then return end
    local dx = bestX - Mouse.X
    local dy = bestY - Mouse.Y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist < 2 then
        mousemoverel(dx, dy)
    else
        local stepX = dx > 0 and math.max(dx / 1, 1) or math.min(dx / 1, -1)
        local stepY = dy > 0 and math.max(dy / 1, 1) or math.min(dy / 1, -1)
        mousemoverel(stepX, stepY)
    end
end

local function Shoot()
    mouse1press()
    task.wait(0.01)
    mouse1release()
end

-- ===== PLATFORM (only when ragebot on, 100ms update) =====
local function UpdatePlatform()
    if not Settings.Ragebot.Enabled then return end
    local now = tick()
    if now - lastPlatformUpdate < 0.1 then return end
    lastPlatformUpdate = now
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not platform or not platform.Parent then
        platform = Instance.new("Part")
        platform.Size = Vector3.new(6, 0.5, 6)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 1
        platform.Parent = Workspace
    end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        crouchOffset = math.min(crouchOffset + 0.1, 1)
    else
        crouchOffset = math.max(crouchOffset - 0.1, 0)
    end
    platform.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 3.25 + crouchOffset, 0))
end

-- ===== DELETE MAP TRASH (always deleted when ragebot/wallbang/deletemap is on, never restored) =====
local trashFolders = {"Ambience", "Barriers", "DeathBarriers"}

local function DeleteMapTrash()
    if mapTrashDeleted then return end
    local map = Workspace:FindFirstChild("Map")
    if not map then return end
    for _, name in ipairs(trashFolders) do
        local folder = map:FindFirstChild(name)
        if folder then
            pcall(function() folder:Destroy() end)
        end
    end
    mapTrashDeleted = true
end

-- ===== DELETE/RESTORE MAP GEOMETRY ONLY =====
local function DeleteGeometry()
    if geometryDeleted then return end
    local map = Workspace:FindFirstChild("Map")
    if not map then return end
    local geometry = map:FindFirstChild("Geometry")
    if not geometry or not geometry.Parent then return end
    
    geometryBackup = {
        Parent = geometry.Parent,
        Clone = geometry:Clone()
    }
    geometry:Destroy()
    geometryDeleted = true
end

local function RestoreGeometry()
    if not geometryBackup or not geometryBackup.Clone then return end
    if geometryBackup.Parent and geometryBackup.Parent:FindFirstChild("Geometry") then return end
    
    local clone = geometryBackup.Clone:Clone()
    clone.Parent = geometryBackup.Parent
    geometryBackup = nil
    geometryDeleted = false
end

-- ===== WALLBANG (only deletes parts inside Map.Geometry) =====
local function IsPartInGeometry(part)
    local map = Workspace:FindFirstChild("Map")
    if not map then return false end
    local geometry = map:FindFirstChild("Geometry")
    if not geometry then return false end
    
    local current = part
    while current do
        if current == geometry then return true end
        current = current.Parent
    end
    return false
end

local function IsWallbangProtected(part)
    local current = part
    while current do
        if current:IsA("Model") and (current:FindFirstChild("Humanoid") or current:FindFirstChild("HumanoidRootPart")) then return true end
        if current == LocalPlayer.Character or current == platform then return true end
        current = current.Parent
    end
    return false
end

local function WallbangRemove()
    if not Settings.Wallbang.Enabled then return end
    local origin = Camera.CFrame.Position
    local direction = Camera.CFrame.LookVector * 500
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances = {LocalPlayer.Character}
    local result = Workspace:Raycast(origin, direction, rp)
    if result and result.Instance and result.Instance.Parent then
        local part = result.Instance
        if IsPartInGeometry(part) and not IsWallbangProtected(part) and not removedParts[part] then
            local clone = part:Clone()
            clone.Parent = nil
            removedParts[part] = {parent = part.Parent, clone = clone}
            pcall(function() part:Destroy() end)
        end
    end
end

local function WallbangRestore()
    for part, data in pairs(removedParts) do
        pcall(function() data.clone:Clone().Parent = data.parent end)
    end
    removedParts = {}
end

-- ===== WALLBANG KEY CHECK =====
local function IsWallbangKeyHeld()
    local kv = Library.Options["wallbang_key"] and Library.Options["wallbang_key"].Value
    if not kv or kv == "" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
    if kv == "MB1" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
    if kv == "MB2" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
    if kv == "MB3" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton3) end
    local kc = Enum.KeyCode[kv]
    return kc and UIS:IsKeyDown(kc) or false
end

-- ===== NO RECOIL =====
local function EnableNoRecoil()
    if #recoilData > 0 then return end
    local cc = ReplicatedStorage:FindFirstChild("Controllers")
    if not cc then return end
    cc = cc:FindFirstChild("CameraController")
    if not cc then return end
    local module = require(cc)
    local springs = {}
    local function addSprings(func)
        if not module[func] then return end
        for _, uv in ipairs(debug.getupvalues(module[func])) do
            if typeof(uv) == "table" and uv.update and uv.setPosition and uv.setGoal then
                table.insert(springs, uv)
            end
        end
    end
    addSprings("getWeaponRecoil")
    addSprings("getWeaponKickRotation")
    if #springs == 0 then return end
    for _, spring in ipairs(springs) do
        local origUpdate = spring.update
        table.insert(recoilData, {spring = spring, originalUpdate = origUpdate})
        spring.update = function(self, dt)
            origUpdate(self, dt)
            self.pos = Vector3.zero
            self.vel = Vector3.zero
            self.goal = Vector3.zero
            return Vector3.zero
        end
        spring.setPosition = function() end
        spring.setGoal = function() end
        spring.impulse = function() end
    end
end

local function DisableNoRecoil()
    for _, data in ipairs(recoilData) do
        data.spring.update = data.originalUpdate
    end
    recoilData = {}
end

-- ===== UI =====
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()

local Window = Library:CreateWindow({
    Title = "Bloxstrike",
    Size = UDim2.fromOffset(580, 440),
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightShift,
    ConfigFolder = "Bloxstrike"
})

local AimbotTab = Window:AddTab("Aimbot", "sword")
local RageTab = Window:AddTab("Rage", "skull")
local VisualsTab = Window:AddTab("Visuals", "eye")
local MovementTab = Window:AddTab("Misc", "square-menu")

-- Aimbot
local AimbotBox = AimbotTab:AddLeftGroupbox("Aimbot")
AimbotBox:AddToggle("aimbot_enabled", {Text="Enabled",Default=false,Callback=function(v)Settings.Aimbot.Enabled=v end})
AimbotBox:AddToggle("aimbot_teamcheck", {Text="Team Check",Default=true,Callback=function(v)Settings.Aimbot.TeamCheck=v end})
AimbotBox:AddToggle("aimbot_vischeck", {Text="Visible Only",Default=false,Callback=function(v)Settings.Aimbot.VisCheck=v end})
AimbotBox:AddSlider("aimbot_smoothness", {Text="Smoothness",Default=5,Min=1,Max=20,Rounding=0,Callback=function(v)Settings.Aimbot.Smoothness=v end})
AimbotBox:AddSlider("aimbot_fov", {Text="FOV",Default=200,Min=50,Max=500,Rounding=0,Suffix="px",Callback=function(v)Settings.Aimbot.FOV=v end})
AimbotBox:AddLabel("Aim Key:"):AddKeyPicker("aimbot_key",{Default="MB2",Mode="Hold",Text="Aim Key",Callback=function(v)end})

local function IsAimKeyHeld()
    local kv = Library.Options["aimbot_key"] and Library.Options["aimbot_key"].Value
    if not kv or kv == "" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
    if kv == "MB1" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
    if kv == "MB2" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
    if kv == "MB3" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton3) end
    local kc = Enum.KeyCode[kv]
    return kc and UIS:IsKeyDown(kc) or false
end

-- Rage
local RageBox = RageTab:AddLeftGroupbox("Ragebot")
RageBox:AddToggle("ragebot_enabled",{Text="Enable Ragebot",Default=false,Callback=function(v)Settings.Ragebot.Enabled=v;if v then DeleteMapTrash()else RestoreGeometry()end end})
RageBox:AddToggle("wallbang_enabled",{Text="Enable Wallbang",Default=false,Callback=function(v)Settings.Wallbang.Enabled=v;if v then DeleteMapTrash()end end})
RageBox:AddLabel("Wallbang Key:"):AddKeyPicker("wallbang_key",{Default="MB1",Mode="Hold",Text="Wallbang Key",Callback=function(v)end})
RageBox:AddToggle("deletemap_enabled",{Text="Delete Map Geometry",Default=false,Callback=function(v)Settings.DeleteMap.Enabled=v;if v then DeleteMapTrash();DeleteGeometry()else RestoreGeometry()end end})
RageBox:AddButton("Restore Geometry", function() RestoreGeometry(); Settings.DeleteMap.Enabled = false end)

-- Visuals
local VisualsBox = VisualsTab:AddLeftGroupbox("Visuals")
VisualsBox:AddToggle("esp_enabled",{Text="ESP (Red)",Default=false,Callback=function(v)Settings.ESP.Enabled=v;if not v then for _,hl in pairs(espCache)do pcall(function()hl:Destroy()end)end;espCache={}end end})
VisualsBox:AddToggle("esp_teamcheck",{Text="Team Check",Default=true,Callback=function(v)Settings.ESP.TeamCheck=v;for _,hl in pairs(espCache)do pcall(function()hl:Destroy()end)end;espCache={}end})

-- Movement
local MovementBox = MovementTab:AddLeftGroupbox("Movement")
MovementBox:AddToggle("bhop_enabled",{Text="Bunnyhop",Default=false,Callback=function(v)Settings.Bunnyhop.Enabled=v end})
MovementBox:AddToggle("norecoil_enabled",{Text="No Recoil",Default=false,Callback=function(v)Settings.NoRecoil.Enabled=v;if v then pcall(EnableNoRecoil)else pcall(DisableNoRecoil)end end})

-- ===== MAIN LOOP =====
RunService.RenderStepped:Connect(function()
    if IsStaffInGame() then LeaveGame() return end
    
    UpdatePlatform()
    
    -- Delete trash if any rage option is on
    if Settings.Ragebot.Enabled or Settings.Wallbang.Enabled or Settings.DeleteMap.Enabled then
        DeleteMapTrash()
    end
    
    if Settings.Aimbot.Enabled and IsAimKeyHeld() then RunAimbot() end
    
    if Settings.Ragebot.Enabled then
        RageAimAtClosest()
        local now = tick()
        if now - rageLastShot >= 0.4 and rageShotCount < 3 then
            Shoot()
            rageLastShot = now
            rageShotCount = rageShotCount + 1
        elseif rageShotCount >= 3 and now - rageLastShot >= 0.3 then
            rageShotCount = 0
        end
    else
        rageShotCount = 0
    end
    
    if Settings.DeleteMap.Enabled and not geometryDeleted then
        DeleteGeometry()
    elseif not Settings.DeleteMap.Enabled and geometryDeleted then
        RestoreGeometry()
    end
    
    if Settings.Wallbang.Enabled then
        if IsWallbangKeyHeld() then
            wasWallbanging = true
            WallbangRemove()
        else
            if wasWallbanging then WallbangRestore() end
            wasWallbanging = false
        end
    end
    
    UpdateESP()
end)

task.spawn(function()
    while task.wait(0.005) do
        if Settings.Bunnyhop.Enabled and UIS:IsKeyDown(Enum.KeyCode.Space) then RunBunnyhop() end
    end
end)

Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then return end
    local name = player.Name
    local display = player.DisplayName
    for i = 1, #StaffList do
        local s = StaffList[i]
        if name == s or display == s then LeaveGame() return end
    end
end)
