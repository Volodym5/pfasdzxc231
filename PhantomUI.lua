-- PhantomUI_v3.lua
-- Elite Roblox UI Framework
-- Version: 3.0.0 — Premium Edition
-- Improvements: Contrast hierarchy, text hierarchy, instant hover response,
--   press physicality, animated strokes, slider upgrades, accent glow,
--   spring open animation, noise layering, layout intelligence,
--   section collapse, tab transitions, corner radius hierarchy,
--   animation throttling, config system, notification queue polish,
--   coordinated multi-property hover animations.

local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local GuiService       = game:GetService("GuiService")
local TextService      = game:GetService("TextService")
local HttpService      = game:GetService("HttpService")
local Camera           = workspace.CurrentCamera

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ CORE: Maid ]]
-- ─────────────────────────────────────────────────────────────────────────────

local Maid = {}
Maid.__index = Maid
function Maid.new() return setmetatable({ _tasks = {} }, Maid) end
function Maid:GiveTask(task_)
    if not task_ then return end
    table.insert(self._tasks, task_)
    return task_
end
function Maid:DoCleaning()
    for _, t in ipairs(self._tasks) do
        if typeof(t) == "function" then t()
        elseif typeof(t) == "RBXScriptConnection" then t:Disconnect()
        elseif typeof(t) == "Instance" then t:Destroy()
        elseif t.Destroy then t:Destroy()
        elseif t.DoCleaning then t:DoCleaning() end
    end
    self._tasks = {}
end
function Maid:Destroy() self:DoCleaning() end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ CORE: Signal ]]
-- ─────────────────────────────────────────────────────────────────────────────

local Signal = {}
Signal.__index = Signal
function Signal.new() return setmetatable({ _listeners = {} }, Signal) end
function Signal:Connect(cb)
    local conn = { _callback = cb, _connected = true, Disconnect = function(self) self._connected = false end }
    table.insert(self._listeners, conn)
    return conn
end
function Signal:Fire(...)
    for i = #self._listeners, 1, -1 do
        local l = self._listeners[i]
        if l._connected then task.spawn(l._callback, ...)
        else table.remove(self._listeners, i) end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ CORE: Spring — physics-based animation ]]
-- ─────────────────────────────────────────────────────────────────────────────

local Spring = {}
Spring.__index = Spring
function Spring.new(speed, damper)
    return setmetatable({
        Target = 0, Position = 0, Velocity = 0,
        Speed  = speed  or 15,
        Damper = damper or 0.7,
    }, Spring)
end
function Spring:Update(dt)
    -- Animation throttling: skip tiny updates (perf fix #15)
    if math.abs(self.Target - self.Position) < 0.0005 and math.abs(self.Velocity) < 0.0005 then
        self.Position = self.Target
        self.Velocity = 0
        return self.Position
    end
    local force = (self.Target - self.Position) * self.Speed
    self.Velocity = (self.Velocity + force * dt) * (self.Damper ^ dt)
    self.Position = self.Position + self.Velocity * dt
    return self.Position
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ THEME ENGINE ]]
-- ─────────────────────────────────────────────────────────────────────────────

local Theme = {
    Current = {
        Background     = Color3.fromRGB(12,  12,  12),
        Surface        = Color3.fromRGB(20,  20,  20),
        SurfaceLight   = Color3.fromRGB(30,  30,  30),
        SurfaceDeep    = Color3.fromRGB(15,  15,  15),
        Border         = Color3.fromRGB(38,  38,  38),
        BorderLight    = Color3.fromRGB(58,  58,  58),
        Text           = Color3.fromRGB(240, 240, 240),
        TextMuted      = Color3.fromRGB(150, 150, 150),
        TextDimmed     = Color3.fromRGB(110, 110, 110),   -- new: inactive tabs, descriptions
        Accent         = Color3.fromRGB(99,  102, 241),
        AccentMuted    = Color3.fromRGB(60,  63,  150),
        AccentGlow     = Color3.fromRGB(99,  102, 241),
        Danger         = Color3.fromRGB(239, 68,  68),
        Success        = Color3.fromRGB(34,  197, 94),
    },
    Themes = {
        Obsidian = {
            Background   = Color3.fromRGB(10,  10,  10),
            Surface      = Color3.fromRGB(18,  18,  18),
            SurfaceLight = Color3.fromRGB(28,  28,  28),
            Border       = Color3.fromRGB(32,  32,  32),
            Accent       = Color3.fromRGB(99,  102, 241),
        },
        Midnight = {
            Background   = Color3.fromRGB(5,   5,  10),
            Surface      = Color3.fromRGB(12,  12,  20),
            SurfaceLight = Color3.fromRGB(20,  20,  32),
            Border       = Color3.fromRGB(28,  28,  44),
            Accent       = Color3.fromRGB(139, 92,  246),
        },
        Rose = {
            Background   = Color3.fromRGB(15,  10,  12),
            Surface      = Color3.fromRGB(25,  18,  20),
            SurfaceLight = Color3.fromRGB(36,  26,  30),
            Border       = Color3.fromRGB(44,  32,  36),
            Accent       = Color3.fromRGB(244, 63,  94),
        },
    },
    Changed = Signal.new(),
}
function Theme:SetTheme(name)
    local data = self.Themes[name]
    if not data then return end
    for k, v in pairs(data) do self.Current[k] = v end
    if not self.Current.AccentGlow then self.Current.AccentGlow = self.Current.Accent end
    self.Changed:Fire(self.Current)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ UTILITIES ]]
-- ─────────────────────────────────────────────────────────────────────────────

local function CreateShadow(parent, radius, transparency)
    local s = Instance.new("ImageLabel")
    s.Name              = "Shadow"
    s.Image             = "rbxassetid://6015897843"
    s.ScaleType         = Enum.ScaleType.Slice
    s.SliceCenter       = Rect.new(49, 49, 450, 450)
    s.BackgroundTransparency = 1
    s.ImageColor3       = Color3.new(0, 0, 0)
    s.ImageTransparency = transparency or 0.35
    s.Size              = UDim2.new(1, 24, 1, 24)
    s.Position          = UDim2.fromOffset(-12, -12)
    s.ZIndex            = parent.ZIndex - 1
    Instance.new("UICorner", s).CornerRadius = UDim.new(0, radius)
    s.Parent = parent
    return s
end

local function CreateAcrylic(parent)
    -- Noise texture for tactile acrylic realism (#9)
    local n = Instance.new("ImageLabel")
    n.Name              = "Noise"
    n.Image             = "rbxassetid://9968344105"
    n.ImageTransparency = 0.97          -- very subtle, huge realism boost
    n.ScaleType         = Enum.ScaleType.Tile
    n.TileSize          = UDim2.fromOffset(128, 128)
    n.BackgroundTransparency = 1
    n.Size              = UDim2.fromScale(1, 1)
    n.ZIndex            = 1
    n.Parent            = parent
    return n
end

local function CreateAccentGlow(parent)
    -- Subtle accent bloom on hover (#7)
    local g = Instance.new("ImageLabel")
    g.Name              = "AccentGlow"
    g.Image             = "rbxassetid://5028857472"   -- soft radial gradient
    g.ScaleType         = Enum.ScaleType.Stretch
    g.BackgroundTransparency = 1
    g.ImageColor3       = Theme.Current.AccentGlow
    g.ImageTransparency = 1             -- starts invisible, driven by spring
    g.Size              = UDim2.new(1, 40, 1, 40)
    g.Position          = UDim2.fromOffset(-20, -20)
    g.ZIndex            = parent.ZIndex - 1
    g.Parent            = parent
    return g
end

local function GetMouse()
    local m     = UserInputService:GetMouseLocation()
    local inset = GuiService:GetGuiInset()
    return Vector2.new(m.X, m.Y - inset.Y)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ COMPONENT BASE ]]
-- ─────────────────────────────────────────────────────────────────────────────

local Component = {}
Component.__index = Component
function Component.new(name)
    return setmetatable({ Name = name, _maid = Maid.new(), _state = {}, _instances = {} }, Component)
end
function Component:SubscribeTheme(cb)
    self._maid:GiveTask(Theme.Changed:Connect(cb))
    cb(Theme.Current)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ CONFIG SYSTEM (#17) — flag registry + save/load ]]
-- ─────────────────────────────────────────────────────────────────────────────

local Config = {
    Flags   = {},           -- [flagName] = element
    Folder  = "PhantomUI",
    Ext     = ".pui",
    Enabled = false,        -- only true when a FileName is provided
    FileName = nil,
}

local function callSafely(fn, ...)
    if fn then
        local ok, r = pcall(fn, ...)
        return ok and r or false
    end
end

local function ensureFolder(path)
    if isfolder and not callSafely(isfolder, path) then
        callSafely(makefolder, path)
    end
end

function Config:RegisterFlag(name, element)
    self.Flags[name] = element
end

function Config:Save()
    if not self.Enabled or not self.FileName then return end
    if not (writefile and makefolder and isfolder and isfile) then return end
    ensureFolder(self.Folder)
    local data = {}
    for flagName, el in pairs(self.Flags) do
        data[flagName] = el.CurrentValue
    end
    local ok, json = pcall(function() return HttpService:JSONEncode(data) end)
    if ok then callSafely(writefile, self.Folder .. "/" .. self.FileName .. self.Ext, json) end
end

function Config:Load()
    if not self.Enabled or not self.FileName then return end
    if not (readfile and isfolder and isfile) then return end
    local path = self.Folder .. "/" .. self.FileName .. self.Ext
    if not callSafely(isfile, path) then return end
    local raw = callSafely(readfile, path)
    if not raw or raw == "" then return end
    local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok or type(data) ~= "table" then return end
    for flagName, value in pairs(data) do
        local el = self.Flags[flagName]
        if el and el.Set then
            task.spawn(function() el:Set(value) end)
        end
    end
end

function Config:AutoSave(interval)
    interval = interval or 30
    task.spawn(function()
        while task.wait(interval) do
            self:Save()
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ BUTTON (#4, #5, #7 — press scale, stroke glow, accent bloom) ]]
-- ─────────────────────────────────────────────────────────────────────────────

local Button = setmetatable({}, Component)
Button.__index = Button
function Button.new(section, options)
    local self = Component.new(options.Name or "Button")
    setmetatable(self, Button)
    self.Callback = options.Callback or function() end

    local Container = Instance.new("TextButton")
    Container.Name               = self.Name
    Container.Size               = UDim2.new(1, 0, 0, 34)
    Container.BackgroundColor3   = Theme.Current.Surface
    Container.BackgroundTransparency = 0.08    -- stronger button contrast (#1)
    Container.BorderSizePixel    = 0
    Container.AutoButtonColor    = false
    Container.ClipsDescendants   = true
    Container.Text               = ""
    Container.Parent             = section.Instances.Content
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke", Container)
    Stroke.Color     = Theme.Current.Border
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Transparency = 0.55      -- idle stroke subtle (#5)

    local Glow = CreateAccentGlow(Container)

    -- Press scale via UIScale (#4)
    local ScaleObj = Instance.new("UIScale", Container)
    ScaleObj.Scale = 1

    local Label = Instance.new("TextLabel", Container)
    Label.Size               = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text               = self.Name
    Label.TextColor3         = Theme.Current.Text
    Label.Font               = Enum.Font.GothamSemibold
    Label.TextSize           = 13
    Label.ZIndex             = 2

    -- Springs
    local hoverSpring = Spring.new(50, 0.72)
    local pressSpring = Spring.new(70, 0.65)
    local glowSpring  = Spring.new(40, 0.75)

    self._maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
        local h = hoverSpring:Update(dt)
        local p = pressSpring:Update(dt)
        local g = glowSpring:Update(dt)

        -- Contrast hierarchy: surface brightens on hover, accent on border
        Container.BackgroundColor3  = Theme.Current.Surface:Lerp(Theme.Current.SurfaceLight, h)
        Container.BackgroundTransparency = 0.08 - h * 0.05

        -- Stroke glow: idle 0.55 → hover 0.20 (#5)
        Stroke.Color        = Theme.Current.Border:Lerp(Theme.Current.Accent, h * 0.8)
        Stroke.Transparency = 0.55 - h * 0.35

        -- Accent glow bloom (#7)
        Glow.ImageColor3       = Theme.Current.AccentGlow
        Glow.ImageTransparency = 1 - g * 0.08   -- very subtle, 0.92 max opacity

        -- Press scale: 0.97 on press, spring back (#4)
        ScaleObj.Scale = 1 - p * 0.03
    end))

    -- Instant partial state on MouseEnter (#3)
    Container.MouseEnter:Connect(function()
        hoverSpring.Position = 0.25   -- snap partway immediately
        hoverSpring.Target = 1
        glowSpring.Target = 1
    end)
    Container.MouseLeave:Connect(function()
        hoverSpring.Target = 0
        pressSpring.Target = 0
        glowSpring.Target = 0
    end)
    Container.MouseButton1Down:Connect(function()
        pressSpring.Target = 1
    end)
    Container.MouseButton1Up:Connect(function()
        pressSpring.Target = 0
        -- Ripple
        local mouse = GetMouse()
        local rx = mouse.X - Container.AbsolutePosition.X
        local ry = mouse.Y - Container.AbsolutePosition.Y
        local size = math.max(Container.AbsoluteSize.X, Container.AbsoluteSize.Y) * 1.5
        local Ripple = Instance.new("Frame", Container)
        Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        Ripple.BackgroundColor3 = Color3.new(1, 1, 1)
        Ripple.BackgroundTransparency = 0.85
        Ripple.Position = UDim2.fromOffset(rx, ry)
        Ripple.Size = UDim2.fromOffset(0, 0)
        Ripple.ZIndex = 5
        Instance.new("UICorner", Ripple).CornerRadius = UDim.new(1, 0)
        TweenService:Create(Ripple, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1
        }):Play()
        task.delay(0.35, function() Ripple:Destroy() end)
        self.Callback()
    end)

    self:SubscribeTheme(function(t)
        Label.TextColor3 = t.Text
    end)
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ TOGGLE ]]
-- ─────────────────────────────────────────────────────────────────────────────

local Toggle = setmetatable({}, Component)
Toggle.__index = Toggle
function Toggle.new(section, options)
    local self = Component.new(options.Name or "Toggle")
    setmetatable(self, Toggle)
    self.State    = options.Default or false
    self.Callback = options.Callback or function() end
    self.CurrentValue = self.State

    local Container = Instance.new("TextButton", section.Instances.Content)
    Container.Size               = UDim2.new(1, 0, 0, 34)
    Container.BackgroundTransparency = 1
    Container.Text               = ""

    local Label = Instance.new("TextLabel", Container)
    Label.Size               = UDim2.new(1, -50, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text               = self.Name
    Label.TextColor3         = Theme.Current.Text
    Label.Font               = Enum.Font.GothamSemibold
    Label.TextSize           = 13
    Label.TextXAlignment     = Enum.TextXAlignment.Left

    local Switch = Instance.new("Frame", Container)
    Switch.Size              = UDim2.fromOffset(36, 20)
    Switch.Position          = UDim2.new(1, -36, 0.5, 0)
    Switch.AnchorPoint       = Vector2.new(0, 0.5)
    Switch.BackgroundColor3  = self.State and Theme.Current.Accent or Theme.Current.Border
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local SwitchStroke = Instance.new("UIStroke", Switch)
    SwitchStroke.Color       = Theme.Current.Border
    SwitchStroke.Thickness   = 1
    SwitchStroke.Transparency = 0.5

    local Knob = Instance.new("Frame", Switch)
    Knob.Size        = UDim2.fromOffset(14, 14)
    Knob.Position    = self.State and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    Knob.AnchorPoint = Vector2.new(0, 0.5)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local stateSpring = Spring.new(60, 0.68)
    stateSpring.Position = self.State and 1 or 0
    stateSpring.Target   = stateSpring.Position

    self._maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
        local s = stateSpring:Update(dt)
        local alpha = math.pow(math.clamp(s, 0, 1), 0.65)
        Switch.BackgroundColor3 = Theme.Current.Border:Lerp(Theme.Current.Accent, alpha)
        SwitchStroke.Color      = Theme.Current.Border:Lerp(Theme.Current.AccentGlow, alpha)
        Knob.Position           = UDim2.new(0, 3 + (s * 16), 0.5, 0)
    end))

    Container.MouseButton1Click:Connect(function()
        self.State        = not self.State
        self.CurrentValue = self.State
        stateSpring.Target = self.State and 1 or 0
        self.Callback(self.State)
        Config:Save()
    end)

    function self:Set(v)
        self.State        = v
        self.CurrentValue = v
        stateSpring.Target = v and 1 or 0
        self.Callback(v)
    end

    if options.Flag then Config:RegisterFlag(options.Flag, self) end
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ SLIDER — knob scaling, fill glow, elastic, hover expansion (#6) ]]
-- ─────────────────────────────────────────────────────────────────────────────

local Slider = setmetatable({}, Component)
Slider.__index = Slider
function Slider.new(section, options)
    local self = Component.new(options.Name or "Slider")
    setmetatable(self, Slider)
    self.Min      = options.Min     or 0
    self.Max      = options.Max     or 100
    self.Value    = options.Default or 50
    self.Suffix   = options.Suffix  or ""
    self.Callback = options.Callback or function() end
    self.Dragging = false
    self.CurrentValue = self.Value

    local Container = Instance.new("Frame", section.Instances.Content)
    Container.Size               = UDim2.new(1, 0, 0, 52)
    Container.BackgroundTransparency = 1

    -- Title row
    local Label = Instance.new("TextLabel", Container)
    Label.Size               = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text               = self.Name
    Label.TextColor3         = Theme.Current.Text
    Label.Font               = Enum.Font.GothamSemibold
    Label.TextSize           = 13
    Label.TextXAlignment     = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel", Container)
    ValueLabel.Size              = UDim2.new(1, 0, 0, 20)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text              = tostring(self.Value) .. self.Suffix
    ValueLabel.TextColor3        = Theme.Current.Accent    -- accent value (#2)
    ValueLabel.Font              = Enum.Font.GothamBold
    ValueLabel.TextSize          = 12
    ValueLabel.TextXAlignment    = Enum.TextXAlignment.Right

    -- Track
    local Track = Instance.new("TextButton", Container)
    Track.Size               = UDim2.new(1, 0, 0, 6)
    Track.Position           = UDim2.fromOffset(0, 36)
    Track.BackgroundColor3   = Theme.Current.SurfaceDeep
    Track.BorderSizePixel    = 0
    Track.Text               = ""
    Track.AutoButtonColor    = false
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    -- Fill with gradient for glow feel
    local Fill = Instance.new("Frame", Track)
    Fill.Size              = UDim2.fromScale((self.Value - self.Min) / (self.Max - self.Min), 1)
    Fill.BackgroundColor3  = Theme.Current.Accent
    Fill.BorderSizePixel   = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local FillGradient = Instance.new("UIGradient", Fill)
    FillGradient.Color     = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(0.7, 0.7, 1)),
    })
    FillGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0.2),
    })

    -- Knob: 14px idle → 18px dragging (#6)
    local Knob = Instance.new("Frame", Track)
    Knob.Size            = UDim2.fromOffset(14, 14)
    Knob.AnchorPoint     = Vector2.new(0.5, 0.5)
    Knob.Position        = UDim2.new(Fill.Size.X.Scale, 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Knob.ZIndex          = 2
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    CreateShadow(Knob, 7, 0.55)

    local fillSpring = Spring.new(75, 0.70)
    fillSpring.Position = Fill.Size.X.Scale
    fillSpring.Target   = fillSpring.Position

    local knobScaleSpring = Spring.new(55, 0.68)
    knobScaleSpring.Position = 14
    knobScaleSpring.Target   = 14

    local function Update(input)
        local pos = math.clamp(
            (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        self.Value        = math.floor(self.Min + (self.Max - self.Min) * pos)
        self.CurrentValue = self.Value
        ValueLabel.Text   = tostring(self.Value) .. self.Suffix
        fillSpring.Target = pos
        self.Callback(self.Value)
    end

    self._maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
        local f  = fillSpring:Update(dt)
        local ks = knobScaleSpring:Update(dt)
        Fill.Size       = UDim2.fromScale(f, 1)
        Knob.Position   = UDim2.new(f, 0, 0.5, 0)
        Knob.Size       = UDim2.fromOffset(ks, ks)
        -- Animate fill gradient rotation subtly for glow illusion
        FillGradient.Rotation = f * 30
        Fill.BackgroundColor3 = Theme.Current.Accent
    end))

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = true
            knobScaleSpring.Target = 18   -- knob expands on drag (#6)
            Update(input)
        end
    end)
    self._maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
            knobScaleSpring.Target = 14
            Config:Save()
        end
    end))
    self._maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input)
        end
    end))
    -- Hover: knob slight expand
    Track.MouseEnter:Connect(function() if not self.Dragging then knobScaleSpring.Target = 16 end end)
    Track.MouseLeave:Connect(function() if not self.Dragging then knobScaleSpring.Target = 14 end end)

    function self:Set(v)
        self.Value        = math.clamp(v, self.Min, self.Max)
        self.CurrentValue = self.Value
        ValueLabel.Text   = tostring(self.Value) .. self.Suffix
        fillSpring.Target = (self.Value - self.Min) / (self.Max - self.Min)
    end

    if options.Flag then Config:RegisterFlag(options.Flag, self) end
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ DROPDOWN ]]
-- ─────────────────────────────────────────────────────────────────────────────

local Dropdown = setmetatable({}, Component)
Dropdown.__index = Dropdown
function Dropdown.new(section, options)
    local self = Component.new(options.Name or "Dropdown")
    setmetatable(self, Dropdown)
    self.Options  = options.Options or {}
    self.Selected = options.Default or nil
    self.Callback = options.Callback or function() end
    self.Open     = false
    self.CurrentValue = self.Selected

    local Container = Instance.new("Frame", section.Instances.Content)
    Container.Size               = UDim2.new(1, 0, 0, 60)
    Container.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Container)
    Label.Size               = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text               = self.Name
    Label.TextColor3         = Theme.Current.Text
    Label.Font               = Enum.Font.GothamSemibold
    Label.TextSize           = 13
    Label.TextXAlignment     = Enum.TextXAlignment.Left

    local Selector = Instance.new("TextButton", Container)
    Selector.Size            = UDim2.new(1, 0, 0, 34)
    Selector.Position        = UDim2.fromOffset(0, 24)
    Selector.BackgroundColor3 = Theme.Current.Surface
    Selector.BackgroundTransparency = 0.08
    Selector.BorderSizePixel = 0
    Selector.AutoButtonColor = false
    Selector.Text            = ""
    Instance.new("UICorner", Selector).CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke", Selector)
    Stroke.Color        = Theme.Current.Border
    Stroke.Transparency = 0.55

    local SelectedLabel = Instance.new("TextLabel", Selector)
    SelectedLabel.Size           = UDim2.new(1, -40, 1, 0)
    SelectedLabel.Position       = UDim2.fromOffset(12, 0)
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Text           = self.Selected or "Select Option..."
    SelectedLabel.TextColor3     = Theme.Current.TextMuted
    SelectedLabel.Font           = Enum.Font.Gotham
    SelectedLabel.TextSize       = 13
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left

    local Icon = Instance.new("ImageLabel", Selector)
    Icon.Size           = UDim2.fromOffset(16, 16)
    Icon.Position       = UDim2.new(1, -28, 0.5, 0)
    Icon.AnchorPoint    = Vector2.new(0, 0.5)
    Icon.BackgroundTransparency = 1
    Icon.Image          = "rbxassetid://6031091007"
    Icon.ImageColor3    = Theme.Current.TextMuted

    local List = Instance.new("ScrollingFrame", Selector)
    List.Size            = UDim2.new(1, 0, 0, 0)
    List.Position        = UDim2.new(0, 0, 1, 4)
    List.BackgroundColor3 = Theme.Current.SurfaceDeep
    List.BackgroundTransparency = 0.04
    List.BorderSizePixel = 0
    List.Visible         = false
    List.ClipsDescendants = true
    List.ZIndex          = 10
    List.ScrollBarThickness = 0
    Instance.new("UICorner", List).CornerRadius = UDim.new(0, 8)
    CreateShadow(List, 8, 0.45)

    local ListLayout = Instance.new("UIListLayout", List)
    ListLayout.Padding = UDim.new(0, 2)

    for _, opt in ipairs(self.Options) do
        local OptBtn = Instance.new("TextButton", List)
        OptBtn.Size              = UDim2.new(1, 0, 0, 30)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text              = "  " .. opt
        OptBtn.TextColor3        = Theme.Current.TextMuted
        OptBtn.Font              = Enum.Font.Gotham
        OptBtn.TextSize          = 13
        OptBtn.TextXAlignment    = Enum.TextXAlignment.Left
        OptBtn.ZIndex            = 11
        OptBtn.MouseEnter:Connect(function()
            TweenService:Create(OptBtn, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.88,
                BackgroundColor3 = Color3.new(1,1,1),
                TextColor3 = Theme.Current.Text
            }):Play()
        end)
        OptBtn.MouseLeave:Connect(function()
            TweenService:Create(OptBtn, TweenInfo.new(0.15), {
                BackgroundTransparency = 1,
                TextColor3 = Theme.Current.TextMuted
            }):Play()
        end)
        OptBtn.MouseButton1Click:Connect(function()
            self.Selected     = opt
            self.CurrentValue = opt
            SelectedLabel.Text       = opt
            SelectedLabel.TextColor3 = Theme.Current.Text
            self.Callback(opt)
            self:Toggle(false)
            Config:Save()
        end)
    end

    -- Hover stroke feedback
    Selector.MouseEnter:Connect(function()
        TweenService:Create(Stroke, TweenInfo.new(0.18), { Transparency = 0.2, Color = Theme.Current.Accent }):Play()
    end)
    Selector.MouseLeave:Connect(function()
        if not self.Open then
            TweenService:Create(Stroke, TweenInfo.new(0.18), { Transparency = 0.55, Color = Theme.Current.Border }):Play()
        end
    end)

    function self:Toggle(state)
        self.Open = state
        List.Visible = true
        local targetH = state and math.min(#self.Options * 32, 160) or 0
        TweenService:Create(List, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
            Size = UDim2.new(1, 0, 0, targetH)
        }):Play()
        TweenService:Create(Icon, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Rotation = state and 180 or 0
        }):Play()
        if state then
            Stroke.Color        = Theme.Current.Accent
            Stroke.Transparency = 0.2
        else
            TweenService:Create(Stroke, TweenInfo.new(0.18), {
                Transparency = 0.55, Color = Theme.Current.Border
            }):Play()
            task.delay(0.35, function() if not self.Open then List.Visible = false end end)
        end
    end

    Selector.MouseButton1Click:Connect(function() self:Toggle(not self.Open) end)

    function self:Set(v)
        self.Selected         = v
        self.CurrentValue     = v
        SelectedLabel.Text        = v or "Select Option..."
        SelectedLabel.TextColor3  = v and Theme.Current.Text or Theme.Current.TextMuted
    end

    if options.Flag then Config:RegisterFlag(options.Flag, self) end
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ SECTION — with collapse animation (#11) ]]
-- ─────────────────────────────────────────────────────────────────────────────

local Section = {}
Section.__index = Section
function Section.new(tab, options)
    local self = setmetatable({
        Tab  = tab,
        Name = options.Name or "Section",
        Collapsed = false,
    }, Section)

    -- Section: transparency 0.18 (slightly lighter than window 0.12) (#1)
    local Container = Instance.new("Frame", tab.Instances.Content)
    Container.Size               = UDim2.new(1, 0, 0, 40)
    Container.BackgroundColor3   = Theme.Current.Surface
    Container.BackgroundTransparency = 0.18
    Container.BorderSizePixel    = 0
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", Container)
    Stroke.Color        = Theme.Current.Border
    Stroke.Transparency = 0.55

    -- Header (clickable for collapse)
    local Header = Instance.new("TextButton", Container)
    Header.Size              = UDim2.new(1, 0, 0, 30)
    Header.Position          = UDim2.fromOffset(0, 0)
    Header.BackgroundTransparency = 1
    Header.Text              = ""

    local Title = Instance.new("TextLabel", Header)
    Title.Size               = UDim2.new(1, -40, 1, 0)
    Title.Position           = UDim2.fromOffset(10, 5)
    Title.BackgroundTransparency = 1
    Title.Text               = self.Name:upper()
    Title.TextColor3         = Theme.Current.Accent
    Title.TextSize           = 11
    Title.Font               = Enum.Font.GothamBold
    Title.TextXAlignment     = Enum.TextXAlignment.Left

    local CollapseIcon = Instance.new("TextLabel", Header)
    CollapseIcon.Size            = UDim2.fromOffset(20, 20)
    CollapseIcon.Position        = UDim2.new(1, -28, 0.5, 0)
    CollapseIcon.AnchorPoint     = Vector2.new(0, 0.5)
    CollapseIcon.BackgroundTransparency = 1
    CollapseIcon.Text            = "−"
    CollapseIcon.TextColor3      = Theme.Current.TextDimmed
    CollapseIcon.Font            = Enum.Font.GothamBold
    CollapseIcon.TextSize        = 14

    local Content = Instance.new("Frame", Container)
    Content.Name             = "Content"
    Content.Size             = UDim2.new(1, -20, 0, 0)
    Content.Position         = UDim2.fromOffset(10, 35)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants = true

    local List = Instance.new("UIListLayout", Content)
    List.Padding = UDim.new(0, 8)

    local function RecalcSize()
        if self.Collapsed then return end
        local contentH = List.AbsoluteContentSize.Y
        Content.Size      = UDim2.new(1, -20, 0, contentH)
        Container.Size    = UDim2.new(1, 0, 0, contentH + 45)
    end
    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RecalcSize)

    -- Collapse animation (#11)
    Header.MouseButton1Click:Connect(function()
        self.Collapsed = not self.Collapsed
        local contentH = List.AbsoluteContentSize.Y
        if self.Collapsed then
            CollapseIcon.Text = "+"
            TweenService:Create(Content, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
                Size = UDim2.new(1, -20, 0, 0)
            }):Play()
            TweenService:Create(Container, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
                Size = UDim2.new(1, 0, 0, 40)
            }):Play()
        else
            CollapseIcon.Text = "−"
            TweenService:Create(Content, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
                Size = UDim2.new(1, -20, 0, contentH)
            }):Play()
            TweenService:Create(Container, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
                Size = UDim2.new(1, 0, 0, contentH + 45)
            }):Play()
        end
    end)

    self.Instances = { Content = Content, Container = Container, Stroke = Stroke }

    Theme.Changed:Connect(function(t)
        Container.BackgroundColor3 = t.Surface
        Stroke.Color = t.Border
        Title.TextColor3 = t.Accent
    end)

    return self
end
function Section:CreateToggle(o)    return Toggle.new(self, o) end
function Section:CreateButton(o)    return Button.new(self, o) end
function Section:CreateSlider(o)    return Slider.new(self, o) end
function Section:CreateDropdown(o)  return Dropdown.new(self, o) end

-- Forward-declare extended components (defined after Section)
function Section:CreateColorPicker(o)    return ColorPicker.new(self, o) end
function Section:CreateKeybind(o)        return Keybind.new(self, o) end
function Section:CreateTextbox(o)        return Textbox.new(self, o) end
function Section:CreateParagraph(o)      return Paragraph.new(self, o) end
function Section:CreateMultiDropdown(o)  return MultiDropdown.new(self, o) end
function Section:CreateSearchList(o)     return SearchList.new(self, o) end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ TAB — with transition animation (#12) ]]
-- ─────────────────────────────────────────────────────────────────────────────

local Tab = {}
Tab.__index = Tab
function Tab.new(window, options)
    local self = setmetatable({ Window = window, Name = options.Name or "Tab", Active = false }, Tab)

    local Btn = Instance.new("TextButton", window.Instances.TabContainer)
    Btn.Size             = UDim2.new(1, 0, 0, 34)
    Btn.BackgroundTransparency = 1
    Btn.Text             = "  " .. self.Name
    Btn.TextColor3       = Theme.Current.TextDimmed    -- dimmed inactive (#2)
    Btn.TextTransparency = 0.45                         -- inactive tab text dim (#2)
    Btn.TextXAlignment   = Enum.TextXAlignment.Left
    Btn.Font             = Enum.Font.GothamSemibold
    Btn.TextSize         = 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local ActiveBar = Instance.new("Frame", Btn)
    ActiveBar.Size           = UDim2.new(0, 3, 0.7, 0)
    ActiveBar.Position       = UDim2.new(0, 0, 0.15, 0)
    ActiveBar.BackgroundColor3 = Theme.Current.Accent
    ActiveBar.BackgroundTransparency = 1
    ActiveBar.BorderSizePixel = 0
    Instance.new("UICorner", ActiveBar).CornerRadius = UDim.new(1, 0)

    local Content = Instance.new("ScrollingFrame", window.Instances.Main)
    Content.Size             = UDim2.new(1, -220, 1, -20)
    Content.Position         = UDim2.new(0, 210, 0, 10)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel  = 0
    Content.Visible          = false
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 0
    Content.Position         = UDim2.fromOffset(220, 10)
    local SCL = Instance.new("UIListLayout", Content)
    SCL.Padding = UDim.new(0, 12)

    -- Content uses AbsoluteContentSize for dynamic height (#10)
    SCL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, SCL.AbsoluteContentSize.Y + 20)
    end)

    self.Instances = { Button = Btn, Content = Content, ActiveBar = ActiveBar }
    Btn.MouseButton1Click:Connect(function() self:Select() end)
    return self
end

function Tab:Select()
    if self.Window.CurrentTab then self.Window.CurrentTab:Deselect() end
    self.Active             = true
    self.Window.CurrentTab  = self

    -- Fade+slide new content in (#12): start offset, then animate to position
    self.Instances.Content.Position      = UDim2.fromOffset(230, 10)
    self.Instances.Content.BackgroundTransparency = 1
    self.Instances.Content.Visible       = true
    TweenService:Create(self.Instances.Content, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Position = UDim2.fromOffset(210, 10),
    }):Play()

    TweenService:Create(self.Instances.Button, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        BackgroundTransparency = 0.88,
        BackgroundColor3       = Theme.Current.Accent,
        TextColor3             = Theme.Current.Text,
        TextTransparency       = 0,
    }):Play()
    TweenService:Create(self.Instances.ActiveBar, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        BackgroundTransparency = 0,
    }):Play()
end

function Tab:Deselect()
    self.Active = false
    -- Slide old content out (#12)
    TweenService:Create(self.Instances.Content, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        Position = UDim2.fromOffset(200, 10),
    }):Play()
    task.delay(0.25, function()
        if not self.Active then self.Instances.Content.Visible = false end
    end)
    TweenService:Create(self.Instances.Button, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        BackgroundTransparency = 1,
        TextColor3             = Theme.Current.TextDimmed,
        TextTransparency       = 0.45,
    }):Play()
    TweenService:Create(self.Instances.ActiveBar, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        BackgroundTransparency = 1,
    }):Play()
end

function Tab:CreateSection(o) return Section.new(self, o) end
function Tab:SetIcon(id)
    if self.Instances.Icon then self.Instances.Icon:Destroy() end
    local Icon = Instance.new("ImageLabel", self.Instances.Button)
    Icon.Size       = UDim2.fromOffset(16, 16)
    Icon.Position   = UDim2.fromOffset(8, 9)
    Icon.BackgroundTransparency = 1
    Icon.Image      = "rbxassetid://" .. tostring(id)
    Icon.ImageColor3 = Theme.Current.TextMuted
    self.Instances.Icon = Icon
    self.Instances.Button.Text = "      " .. self.Name
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ WINDOW — spring open animation (#8), contrast hierarchy (#1) ]]
-- ─────────────────────────────────────────────────────────────────────────────

local Window = {}
Window.__index = Window
function Window.new(options)
    local self = setmetatable({
        Title   = options.Title or "Window",
        Size    = options.Size  or UDim2.fromOffset(760, 520),
        _maid   = Maid.new(),
    }, Window)

    local ScreenGui       = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name        = "PhantomUI_v3"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main window: transparency 0.12 — darkest layer (#1)
    local Main            = Instance.new("Frame", ScreenGui)
    Main.Size             = UDim2.fromOffset(0, 0)
    Main.Position         = UDim2.fromScale(0.5, 0.5)
    Main.AnchorPoint      = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Theme.Current.Background
    Main.BackgroundTransparency = 0.12
    Main.BorderSizePixel  = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    CreateShadow(Main, 12, 0.38)
    CreateAcrylic(Main)   -- noise layer (#9)

    -- Window outline
    local WindowStroke = Instance.new("UIStroke", Main)
    WindowStroke.Color        = Theme.Current.Border
    WindowStroke.Transparency = 0.65
    WindowStroke.Thickness    = 1

    -- Sidebar: transparency 0.20 (#1 — surface layer)
    local Sidebar         = Instance.new("Frame", Main)
    Sidebar.Size          = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Current.Surface
    Sidebar.BackgroundTransparency = 0.20
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

    -- Sidebar right edge divider
    local Divider = Instance.new("Frame", Main)
    Divider.Size    = UDim2.new(0, 1, 1, -20)
    Divider.Position = UDim2.fromOffset(200, 10)
    Divider.BackgroundColor3 = Theme.Current.Border
    Divider.BackgroundTransparency = 0.7
    Divider.BorderSizePixel = 0

    -- Title (brighter, larger = title hierarchy #2)
    local TitleLabel = Instance.new("TextLabel", Sidebar)
    TitleLabel.Size          = UDim2.new(1, -20, 0, 40)
    TitleLabel.Position      = UDim2.fromOffset(10, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text          = self.Title
    TitleLabel.TextColor3    = Theme.Current.Text
    TitleLabel.Font          = Enum.Font.GothamBold
    TitleLabel.TextSize      = 16          -- larger title (#2)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local TabContainer    = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size     = UDim2.new(1, -20, 1, -60)
    TabContainer.Position = UDim2.fromOffset(10, 50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 4)

    -- UIScale for viewport
    local UIScale         = Instance.new("UIScale", Main)
    UIScale.Scale         = math.clamp(Camera.ViewportSize.Y / 1080, 0.8, 1)

    self.Instances = { ScreenGui = ScreenGui, Main = Main, TabContainer = TabContainer, Sidebar = Sidebar }
    self._maid:GiveTask(ScreenGui)

    -- Smooth Lerp Dragging
    local targetPos   = Main.Position
    local dragging, dragStart, startPos

    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = Main.Position
        end
    end)
    self._maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            targetPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    self._maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
    self._maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
        Main.Position = Main.Position:Lerp(targetPos, 1 - math.exp(-28 * dt))
    end))

    -- Spring open animation (#8): Scale 0.92 → 1 with overshoot
    UIScale.Scale = 0.92
    Main.BackgroundTransparency = 1
    TweenService:Create(Main, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Size = self.Size, BackgroundTransparency = 0.12
    }):Play()
    TweenService:Create(UIScale, TweenInfo.new(0.65, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 1, false, 0), {
        Scale = math.clamp(Camera.ViewportSize.Y / 1080, 0.8, 1)
    }):Play()

    return self
end

function Window:CreateTab(options)
    local newTab = Tab.new(self, options)
    if not self.CurrentTab then newTab:Select() end
    return newTab
end

function Window:EnableResizing()
    local ResizeBtn = Instance.new("ImageButton", self.Instances.Main)
    ResizeBtn.Size             = UDim2.fromOffset(16, 16)
    ResizeBtn.Position         = UDim2.new(1, -16, 1, -16)
    ResizeBtn.BackgroundTransparency = 1
    ResizeBtn.Image            = "rbxassetid://6031091007"
    ResizeBtn.ImageColor3      = Theme.Current.TextMuted
    ResizeBtn.Rotation         = 45

    local resizing, startSize, startMouse
    ResizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing   = true
            startSize  = self.Instances.Main.Size
            startMouse = UserInputService:GetMouseLocation()
        end
    end)
    self._maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = UserInputService:GetMouseLocation()
            local delta = mouse - startMouse
            self.Instances.Main.Size = UDim2.fromOffset(
                math.clamp(startSize.X.Offset + delta.X, 400, 1100),
                math.clamp(startSize.Y.Offset + delta.Y, 300, 850))
        end
    end))
    self._maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
    end))
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ EXTENDED COMPONENTS ]]
-- ─────────────────────────────────────────────────────────────────────────────

-- ColorPicker
ColorPicker = setmetatable({}, Component)
ColorPicker.__index = ColorPicker
function ColorPicker.new(section, options)
    local self = Component.new(options.Name or "Color Picker")
    setmetatable(self, ColorPicker)
    self.Value    = options.Default or Color3.new(1, 1, 1)
    self.Callback = options.Callback or function() end
    self.Open     = false
    self.CurrentValue = self.Value

    local h, s, v = self.Value:ToHSV()
    self.H, self.S, self.V = h, s, v

    local Container = Instance.new("Frame", section.Instances.Content)
    Container.Size               = UDim2.new(1, 0, 0, 34)
    Container.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Container)
    Label.Size               = UDim2.new(1, -60, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text               = self.Name
    Label.TextColor3         = Theme.Current.Text
    Label.Font               = Enum.Font.GothamSemibold
    Label.TextSize           = 13
    Label.TextXAlignment     = Enum.TextXAlignment.Left

    local Preview = Instance.new("TextButton", Container)
    Preview.Size             = UDim2.fromOffset(40, 20)
    Preview.Position         = UDim2.new(1, -40, 0.5, 0)
    Preview.AnchorPoint      = Vector2.new(0, 0.5)
    Preview.BackgroundColor3 = self.Value
    Preview.Text             = ""
    Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", Preview).Color        = Theme.Current.Border

    local Picker = Instance.new("Frame", Preview)
    Picker.Size            = UDim2.fromOffset(180, 160)
    Picker.Position        = UDim2.new(1, 10, 0, 0)
    Picker.BackgroundColor3 = Theme.Current.Surface
    Picker.Visible         = false
    Picker.ZIndex          = 20
    Instance.new("UICorner", Picker).CornerRadius = UDim.new(0, 8)
    CreateShadow(Picker, 8, 0.42)

    local SatVal = Instance.new("ImageButton", Picker)
    SatVal.Size  = UDim2.fromOffset(140, 140)
    SatVal.Position = UDim2.fromOffset(10, 10)
    SatVal.Image = "rbxassetid://4155801252"
    SatVal.BackgroundColor3 = Color3.fromHSV(self.H, 1, 1)

    local Hue = Instance.new("ImageButton", Picker)
    Hue.Size     = UDim2.fromOffset(15, 140)
    Hue.Position = UDim2.fromOffset(155, 10)
    Hue.Image    = "rbxassetid://4155801337"

    local function Update()
        self.Value        = Color3.fromHSV(self.H, self.S, self.V)
        self.CurrentValue = self.Value
        Preview.BackgroundColor3 = self.Value
        SatVal.BackgroundColor3  = Color3.fromHSV(self.H, 1, 1)
        self.Callback(self.Value)
        Config:Save()
    end

    SatVal.MouseButton1Down:Connect(function()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect(); return end
            local mouse = GetMouse()
            self.S = math.clamp((mouse.X - SatVal.AbsolutePosition.X) / SatVal.AbsoluteSize.X, 0, 1)
            self.V = 1 - math.clamp((mouse.Y - SatVal.AbsolutePosition.Y) / SatVal.AbsoluteSize.Y, 0, 1)
            Update()
        end)
    end)
    Hue.MouseButton1Down:Connect(function()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect(); return end
            local mouse = GetMouse()
            self.H = 1 - math.clamp((mouse.Y - Hue.AbsolutePosition.Y) / Hue.AbsoluteSize.Y, 0, 1)
            Update()
        end)
    end)
    Preview.MouseButton1Click:Connect(function()
        self.Open   = not self.Open
        Picker.Visible = self.Open
    end)

    function self:Set(v)
        self.Value        = v
        self.CurrentValue = v
        Preview.BackgroundColor3 = v
        local hn, sn, vn = v:ToHSV()
        self.H, self.S, self.V = hn, sn, vn
        SatVal.BackgroundColor3 = Color3.fromHSV(hn, 1, 1)
    end

    if options.Flag then Config:RegisterFlag(options.Flag, self) end
    return self
end

-- Keybind
Keybind = setmetatable({}, Component)
Keybind.__index = Keybind
function Keybind.new(section, options)
    local self = Component.new(options.Name or "Keybind")
    setmetatable(self, Keybind)
    self.Binding    = options.Default or Enum.KeyCode.F
    self.Callback   = options.Callback or function() end
    self.IsBinding  = false
    self.CurrentKeybind = self.Binding.Name

    local Container = Instance.new("Frame", section.Instances.Content)
    Container.Size               = UDim2.new(1, 0, 0, 34)
    Container.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Container)
    Label.Size               = UDim2.new(1, -80, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text               = self.Name
    Label.TextColor3         = Theme.Current.Text
    Label.Font               = Enum.Font.GothamSemibold
    Label.TextSize           = 13
    Label.TextXAlignment     = Enum.TextXAlignment.Left

    local BindBtn = Instance.new("TextButton", Container)
    BindBtn.Size             = UDim2.fromOffset(70, 22)
    BindBtn.Position         = UDim2.new(1, -70, 0.5, 0)
    BindBtn.AnchorPoint      = Vector2.new(0, 0.5)
    BindBtn.BackgroundColor3 = Theme.Current.Surface
    BindBtn.BackgroundTransparency = 0.08
    BindBtn.Text             = self.Binding.Name
    BindBtn.TextColor3       = Theme.Current.TextMuted
    BindBtn.Font             = Enum.Font.GothamBold
    BindBtn.TextSize         = 11
    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", BindBtn)
    Stroke.Color = Theme.Current.Border

    BindBtn.MouseButton1Click:Connect(function()
        self.IsBinding  = true
        BindBtn.Text    = "..."
        Stroke.Color    = Theme.Current.Accent
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                self.Binding        = input.KeyCode
                self.CurrentKeybind = self.Binding.Name
                BindBtn.Text        = self.Binding.Name
                self.IsBinding      = false
                Stroke.Color        = Theme.Current.Border
                conn:Disconnect()
                Config:Save()
            end
        end)
    end)

    self._maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.Binding and not self.IsBinding then
            self.Callback()
        end
    end))

    function self:Set(v)
        local kc = Enum.KeyCode[v]
        if kc then
            self.Binding        = kc
            self.CurrentKeybind = v
            BindBtn.Text        = v
        end
    end

    if options.Flag then Config:RegisterFlag(options.Flag, self) end
    return self
end

-- Textbox
Textbox = setmetatable({}, Component)
Textbox.__index = Textbox
function Textbox.new(section, options)
    local self = Component.new(options.Name or "Textbox")
    setmetatable(self, Textbox)
    self.Placeholder  = options.Placeholder or "Type here..."
    self.Callback     = options.Callback    or function() end
    self.CurrentValue = ""

    local Container = Instance.new("Frame", section.Instances.Content)
    Container.Size               = UDim2.new(1, 0, 0, 60)
    Container.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Container)
    Label.Size               = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text               = self.Name
    Label.TextColor3         = Theme.Current.Text
    Label.Font               = Enum.Font.GothamSemibold
    Label.TextSize           = 13
    Label.TextXAlignment     = Enum.TextXAlignment.Left

    local InputBox = Instance.new("TextBox", Container)
    InputBox.Size            = UDim2.new(1, 0, 0, 34)
    InputBox.Position        = UDim2.fromOffset(0, 24)
    InputBox.BackgroundColor3 = Theme.Current.Surface
    InputBox.BackgroundTransparency = 0.08
    InputBox.Text            = ""
    InputBox.PlaceholderText = self.Placeholder
    InputBox.PlaceholderColor3 = Theme.Current.TextDimmed
    InputBox.TextColor3      = Theme.Current.Text
    InputBox.Font            = Enum.Font.Gotham
    InputBox.TextSize        = 13
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", InputBox)
    Stroke.Color        = Theme.Current.Border
    Stroke.Transparency = 0.55

    InputBox.Focused:Connect(function()
        TweenService:Create(Stroke, TweenInfo.new(0.2), { Color = Theme.Current.Accent, Transparency = 0.1 }):Play()
    end)
    InputBox.FocusLost:Connect(function(enter)
        TweenService:Create(Stroke, TweenInfo.new(0.2), { Color = Theme.Current.Border, Transparency = 0.55 }):Play()
        self.CurrentValue = InputBox.Text
        if enter then self.Callback(InputBox.Text) end
    end)
    return self
end

-- Paragraph
Paragraph = setmetatable({}, Component)
Paragraph.__index = Paragraph
function Paragraph.new(section, options)
    local self = Component.new("Paragraph")
    setmetatable(self, Paragraph)
    self.Title   = options.Title   or "Info"
    self.Content = options.Content or ""

    local Container = Instance.new("Frame", section.Instances.Content)
    Container.Size               = UDim2.new(1, 0, 0, 60)
    Container.BackgroundColor3   = Theme.Current.Surface
    Container.BackgroundTransparency = 0.45
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Container)
    Stroke.Color        = Theme.Current.Border
    Stroke.Transparency = 0.65
    Stroke.DashPattern  = {4, 4}

    local T = Instance.new("TextLabel", Container)
    T.Size               = UDim2.new(1, -20, 0, 20)
    T.Position           = UDim2.fromOffset(10, 8)
    T.BackgroundTransparency = 1
    T.Text               = self.Title
    T.TextColor3         = Theme.Current.Text
    T.Font               = Enum.Font.GothamBold
    T.TextSize           = 13
    T.TextXAlignment     = Enum.TextXAlignment.Left

    local C = Instance.new("TextLabel", Container)
    C.Size               = UDim2.new(1, -20, 0, 0)
    C.Position           = UDim2.fromOffset(10, 30)
    C.BackgroundTransparency = 1
    C.Text               = self.Content
    C.TextColor3         = Theme.Current.TextDimmed    -- description dimmed (#2)
    C.TextTransparency   = 0.35
    C.Font               = Enum.Font.Gotham
    C.TextSize           = 12
    C.TextXAlignment     = Enum.TextXAlignment.Left
    C.TextWrapped        = true

    local function UpdateSize()
        local size = TextService:GetTextSize(self.Content, 12, Enum.Font.Gotham,
            Vector2.new(Container.AbsoluteSize.X - 20, 1000))
        C.Size         = UDim2.new(1, -20, 0, size.Y)
        Container.Size = UDim2.new(1, 0, 0, size.Y + 45)
    end
    Container:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)
    task.spawn(UpdateSize)
    return self
end

-- MultiDropdown
MultiDropdown = setmetatable({}, Component)
MultiDropdown.__index = MultiDropdown
function MultiDropdown.new(section, options)
    local self = Component.new(options.Name or "Multi-Dropdown")
    setmetatable(self, MultiDropdown)
    self.Options      = options.Options  or {}
    self.Selected     = options.Default  or {}
    self.Callback     = options.Callback or function() end
    self.Open         = false
    self.CurrentValue = self.Selected

    local Container = Instance.new("Frame", section.Instances.Content)
    Container.Size               = UDim2.new(1, 0, 0, 60)
    Container.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", Container)
    Label.Size               = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text               = self.Name
    Label.TextColor3         = Theme.Current.Text
    Label.Font               = Enum.Font.GothamSemibold
    Label.TextSize           = 13
    Label.TextXAlignment     = Enum.TextXAlignment.Left

    local Selector = Instance.new("TextButton", Container)
    Selector.Size            = UDim2.new(1, 0, 0, 34)
    Selector.Position        = UDim2.fromOffset(0, 24)
    Selector.BackgroundColor3 = Theme.Current.Surface
    Selector.BackgroundTransparency = 0.08
    Selector.BorderSizePixel = 0
    Selector.AutoButtonColor = false
    Selector.Text            = ""
    Instance.new("UICorner", Selector).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Selector)
    Stroke.Color        = Theme.Current.Border
    Stroke.Transparency = 0.55

    local SelectedLabel = Instance.new("TextLabel", Selector)
    SelectedLabel.Size           = UDim2.new(1, -40, 1, 0)
    SelectedLabel.Position       = UDim2.fromOffset(12, 0)
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Text           = #self.Selected > 0 and table.concat(self.Selected, ", ") or "Select Options..."
    SelectedLabel.TextColor3     = Theme.Current.TextMuted
    SelectedLabel.Font           = Enum.Font.Gotham
    SelectedLabel.TextSize       = 13
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SelectedLabel.ClipsDescendants = true

    local List = Instance.new("ScrollingFrame", Selector)
    List.Size             = UDim2.new(1, 0, 0, 0)
    List.Position         = UDim2.new(0, 0, 1, 4)
    List.BackgroundColor3 = Theme.Current.SurfaceDeep
    List.BackgroundTransparency = 0.04
    List.BorderSizePixel  = 0
    List.Visible          = false
    List.ZIndex           = 15
    List.ScrollBarThickness = 0
    Instance.new("UICorner", List).CornerRadius = UDim.new(0, 8)
    CreateShadow(List, 8, 0.45)
    local LL = Instance.new("UIListLayout", List)
    LL.Padding = UDim.new(0, 2)

    local function UpdateSelected()
        SelectedLabel.Text = #self.Selected > 0 and table.concat(self.Selected, ", ") or "Select Options..."
        self.CurrentValue  = self.Selected
        self.Callback(self.Selected)
    end

    for _, opt in ipairs(self.Options) do
        local OptBtn = Instance.new("TextButton", List)
        OptBtn.Size              = UDim2.new(1, 0, 0, 32)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text              = "  " .. opt
        OptBtn.TextColor3        = table.find(self.Selected, opt) and Theme.Current.Accent or Theme.Current.TextMuted
        OptBtn.Font              = Enum.Font.Gotham
        OptBtn.TextSize          = 13
        OptBtn.TextXAlignment    = Enum.TextXAlignment.Left
        OptBtn.ZIndex            = 16
        OptBtn.MouseButton1Click:Connect(function()
            local idx = table.find(self.Selected, opt)
            if idx then
                table.remove(self.Selected, idx)
                OptBtn.TextColor3 = Theme.Current.TextMuted
            else
                table.insert(self.Selected, opt)
                OptBtn.TextColor3 = Theme.Current.Accent
            end
            UpdateSelected()
            Config:Save()
        end)
    end

    Selector.MouseButton1Click:Connect(function()
        self.Open = not self.Open
        List.Visible = true
        local targetH = self.Open and math.min(#self.Options * 34, 200) or 0
        TweenService:Create(List, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            Size = UDim2.new(1, 0, 0, targetH)
        }):Play()
        if not self.Open then task.delay(0.4, function() if not self.Open then List.Visible = false end end) end
    end)

    function self:Set(v)
        self.Selected     = v
        self.CurrentValue = v
        SelectedLabel.Text = #v > 0 and table.concat(v, ", ") or "Select Options..."
    end

    if options.Flag then Config:RegisterFlag(options.Flag, self) end
    return self
end

-- SearchList
SearchList = setmetatable({}, Component)
SearchList.__index = SearchList
function SearchList.new(section, options)
    local self = Component.new(options.Name or "Search List")
    setmetatable(self, SearchList)
    self.Items    = options.Items    or {}
    self.Callback = options.Callback or function() end

    local Container = Instance.new("Frame", section.Instances.Content)
    Container.Size               = UDim2.new(1, 0, 0, 200)
    Container.BackgroundColor3   = Theme.Current.Surface
    Container.BackgroundTransparency = 0.45
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", Container).Color = Theme.Current.Border

    local SearchBar = Instance.new("TextBox", Container)
    SearchBar.Size             = UDim2.new(1, -20, 0, 30)
    SearchBar.Position         = UDim2.fromOffset(10, 10)
    SearchBar.BackgroundColor3 = Theme.Current.Background
    SearchBar.BackgroundTransparency = 0.06
    SearchBar.Text             = ""
    SearchBar.PlaceholderText  = "Search items..."
    SearchBar.PlaceholderColor3 = Theme.Current.TextDimmed
    SearchBar.TextColor3       = Theme.Current.Text
    SearchBar.Font             = Enum.Font.Gotham
    SearchBar.TextSize         = 12
    Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 6)

    local Scroll = Instance.new("ScrollingFrame", Container)
    Scroll.Size              = UDim2.new(1, -20, 1, -50)
    Scroll.Position          = UDim2.fromOffset(10, 45)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel   = 0
    Scroll.ScrollBarThickness = 2
    Scroll.ScrollBarImageColor3 = Theme.Current.Border
    local LL2 = Instance.new("UIListLayout", Scroll)
    LL2.Padding = UDim.new(0, 4)

    local function Populate(filter)
        for _, child in ipairs(Scroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for _, item in ipairs(self.Items) do
            if not filter or item:lower():find(filter:lower(), 1, true) then
                local Btn = Instance.new("TextButton", Scroll)
                Btn.Size             = UDim2.new(1, -5, 0, 28)
                Btn.BackgroundTransparency = 0.92
                Btn.BackgroundColor3 = Color3.new(1, 1, 1)
                Btn.Text             = "  " .. item
                Btn.TextColor3       = Theme.Current.Text
                Btn.Font             = Enum.Font.Gotham
                Btn.TextSize         = 12
                Btn.TextXAlignment   = Enum.TextXAlignment.Left
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
                Btn.MouseButton1Click:Connect(function() self.Callback(item) end)
            end
        end
        Scroll.CanvasSize = UDim2.new(0, 0, 0, LL2.AbsoluteContentSize.Y + 8)
    end
    Populate()
    SearchBar:GetPropertyChangedSignal("Text"):Connect(function() Populate(SearchBar.Text) end)
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ NOTIFICATION SYSTEM — stacking queue, progress bar (#16) ]]
-- ─────────────────────────────────────────────────────────────────────────────

local NotificationQueue = { Active = {}, Pending = {}, MAX = 5 }

local function SpawnNotification(options)
    local Title    = options.Title    or "Notification"
    local Content  = options.Content  or ""
    local Duration = options.Duration or 5
    local Type     = options.Type     or "Default"   -- "Success", "Error", "Warning"

    local NotifGui = CoreGui:FindFirstChild("PhantomNotifications_v3")
    if not NotifGui then
        NotifGui      = Instance.new("ScreenGui", CoreGui)
        NotifGui.Name = "PhantomNotifications_v3"
    end

    local Container = NotifGui:FindFirstChild("Container")
    if not Container then
        Container      = Instance.new("Frame", NotifGui)
        Container.Name = "Container"
        Container.Size = UDim2.new(0, 310, 1, -40)
        Container.Position = UDim2.new(1, -330, 0, 20)
        Container.BackgroundTransparency = 1
        local LL3 = Instance.new("UIListLayout", Container)
        LL3.VerticalAlignment = Enum.VerticalAlignment.Bottom
        LL3.Padding           = UDim.new(0, 8)
    end

    local accentColor = ({
        Success = Theme.Current.Success,
        Error   = Theme.Current.Danger,
        Warning = Color3.fromRGB(234, 179, 8),
    })[Type] or Theme.Current.Accent

    local Toast = Instance.new("Frame", Container)
    Toast.Size             = UDim2.new(1, 0, 0, 72)
    Toast.BackgroundColor3 = Theme.Current.Background
    Toast.BackgroundTransparency = 0.12
    Instance.new("UICorner", Toast).CornerRadius = UDim.new(0, 10)
    local TStroke = Instance.new("UIStroke", Toast)
    TStroke.Color = accentColor
    TStroke.Transparency = 0.7
    CreateShadow(Toast, 10, 0.5)

    -- Accent left bar
    local Bar = Instance.new("Frame", Toast)
    Bar.Size    = UDim2.new(0, 3, 0.7, 0)
    Bar.Position = UDim2.new(0, 0, 0.15, 0)
    Bar.BackgroundColor3 = accentColor
    Bar.BorderSizePixel  = 0
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

    local T = Instance.new("TextLabel", Toast)
    T.Size               = UDim2.new(1, -20, 0, 24)
    T.Position           = UDim2.fromOffset(14, 8)
    T.BackgroundTransparency = 1
    T.Text               = Title
    T.TextColor3         = accentColor
    T.Font               = Enum.Font.GothamBold
    T.TextSize           = 13
    T.TextXAlignment     = Enum.TextXAlignment.Left

    local C = Instance.new("TextLabel", Toast)
    C.Size               = UDim2.new(1, -20, 0, 18)
    C.Position           = UDim2.fromOffset(14, 32)
    C.BackgroundTransparency = 1
    C.Text               = Content
    C.TextColor3         = Theme.Current.TextMuted
    C.Font               = Enum.Font.Gotham
    C.TextSize           = 12
    C.TextXAlignment     = Enum.TextXAlignment.Left

    -- Progress bar
    local ProgTrack = Instance.new("Frame", Toast)
    ProgTrack.Size           = UDim2.new(1, -16, 0, 3)
    ProgTrack.Position       = UDim2.new(0, 8, 1, -8)
    ProgTrack.BackgroundColor3 = Theme.Current.Border
    ProgTrack.BackgroundTransparency = 0.5
    ProgTrack.BorderSizePixel = 0
    Instance.new("UICorner", ProgTrack).CornerRadius = UDim.new(1, 0)

    local Prog = Instance.new("Frame", ProgTrack)
    Prog.Size             = UDim2.fromScale(1, 1)
    Prog.BackgroundColor3 = accentColor
    Prog.BorderSizePixel  = 0
    Instance.new("UICorner", Prog).CornerRadius = UDim.new(1, 0)

    -- Slide in
    Toast.Position = UDim2.new(1, 320, 0, 0)
    TweenService:Create(Toast, TweenInfo.new(0.55, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    -- Progress drain
    TweenService:Create(Prog, TweenInfo.new(Duration, Enum.EasingStyle.Linear), {
        Size = UDim2.fromScale(0, 1)
    }):Play()

    task.delay(Duration, function()
        TweenService:Create(Toast, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, 320, 0, 0)
        }):Play()
        task.wait(0.5)
        Toast:Destroy()
        -- Dequeue
        for i, a in ipairs(NotificationQueue.Active) do
            if a == options then table.remove(NotificationQueue.Active, i); break end
        end
        if #NotificationQueue.Pending > 0 then
            local next = table.remove(NotificationQueue.Pending, 1)
            table.insert(NotificationQueue.Active, next)
            SpawnNotification(next)
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- [[ LIBRARY API ]]
-- ─────────────────────────────────────────────────────────────────────────────

local Library = {
    Version    = "3.0.0",
    Open       = true,
    Windows    = {},
    _maid      = Maid.new(),
    Theme      = Theme,
    Config     = Config,
}

function Library:CreateWindow(options)
    -- Config system setup
    if options.ConfigurationSaving then
        Config.Enabled  = options.ConfigurationSaving.Enabled  ~= false
        Config.FileName = options.ConfigurationSaving.FileName
        Config.Folder   = options.ConfigurationSaving.FolderName or "PhantomUI"
    end

    local w = Window.new(options)
    table.insert(self.Windows, w)

    -- Load config after window built (elements registered via Flag)
    if Config.Enabled and Config.FileName then
        task.defer(function() Config:Load() end)
        Config:AutoSave(30)
    end

    return w
end

function Library:Notify(options)
    if #NotificationQueue.Active >= NotificationQueue.MAX then
        table.insert(NotificationQueue.Pending, options)
        return
    end
    table.insert(NotificationQueue.Active, options)
    SpawnNotification(options)
end

function Library:SetTheme(name)
    Theme:SetTheme(name)
end

function Library:Destroy()
    for _, w in ipairs(self.Windows) do w._maid:Destroy() end
    self.Windows = {}
    self._maid:Destroy()
end

-- Global keybind: RightControl toggles UI
Library._maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        Library.Open = not Library.Open
        for _, w in ipairs(Library.Windows) do
            w.Instances.ScreenGui.Enabled = Library.Open
        end
    end
end))

-- Auto-scale on viewport change
Library._maid:GiveTask(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local scale = math.clamp(Camera.ViewportSize.Y / 1080, 0.8, 1)
    for _, w in ipairs(Library.Windows) do
        for _, child in ipairs(w.Instances.Main:GetChildren()) do
            if child:IsA("UIScale") then child.Scale = scale end
        end
    end
end))

-- Theme → window propagation
Theme.Changed:Connect(function(t)
    for _, w in ipairs(Library.Windows) do
        if w.Instances and w.Instances.Main then
            w.Instances.Main.BackgroundColor3     = t.Background
            w.Instances.Sidebar.BackgroundColor3  = t.Surface
        end
    end
end)

task.spawn(function()
    print("───────────────────────────────────")
    print("  PhantomUI Framework v3.0.0")
    print("  Elite Roblox UI — Premium Edition")
    print("───────────────────────────────────")
end)

return Library
