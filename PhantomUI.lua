-- PhantomUI_Full.lua
-- Elite Roblox UI Framework
-- Version: 2.0.0 (Full Framework Edition)
-- Bundled for single-file distribution

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")
local Camera = workspace.CurrentCamera

local Library = {
    Version = "2.0.0",
    Open = true,
    Windows = {},
    Notifications = {},
    Registry = {}, -- Global registry for state management
    _maid = nil
}

-- [[ CORE SYSTEMS ]]

-- Maid: Advanced Cleanup System
local Maid = {}
Maid.__index = Maid
function Maid.new() return setmetatable({ _tasks = {} }, Maid) end
function Maid:GiveTask(task) if not task then return end table.insert(self._tasks, task) return task end
function Maid:DoCleaning()
    for _, task in ipairs(self._tasks) do
        if typeof(task) == "function" then task()
        elseif typeof(task) == "RBXScriptConnection" then task:Disconnect()
        elseif typeof(task) == "Instance" then task:Destroy()
        elseif task.Destroy then task:Destroy()
        elseif task.DoCleaning then task:DoCleaning() end
    end
    self._tasks = {}
end
function Maid:Destroy() self:DoCleaning() end

Library._maid = Maid.new()

-- Signals: High-performance internal event system
local Signal = {}
Signal.__index = Signal
function Signal.new() return setmetatable({ _listeners = {} }, Signal) end
function Signal:Connect(callback)
    local connection = { _callback = callback, _connected = true, Disconnect = function(self) self._connected = false end }
    table.insert(self._listeners, connection)
    return connection
end
function Signal:Fire(...)
    for i = #self._listeners, 1, -1 do
        local listener = self._listeners[i]
        if listener._connected then task.spawn(listener._callback, ...) else table.remove(self._listeners, i) end
    end
end

-- Spring System: Physics-based animation engine
local Spring = {}
Spring.__index = Spring
function Spring.new(speed, damper)
    return setmetatable({
        Target = 0, Position = 0, Velocity = 0,
        Speed = speed or 15, Damper = damper or 0.7
    }, Spring)
end
function Spring:Update(dt)
    local force = (self.Target - self.Position) * self.Speed
    self.Velocity = (self.Velocity + force * dt) * self.Damper
    self.Position = self.Position + self.Velocity * dt
    return self.Position
end

-- Theme Engine: Centralized styling with dynamic propagation
local Theme = {
    Current = {
        Background = Color3.fromRGB(12, 12, 12),
        Surface = Color3.fromRGB(20, 20, 20),
        SurfaceLight = Color3.fromRGB(28, 28, 28),
        Border = Color3.fromRGB(35, 35, 35),
        BorderLight = Color3.fromRGB(50, 50, 50),
        Text = Color3.fromRGB(240, 240, 240),
        TextMuted = Color3.fromRGB(160, 160, 160),
        Accent = Color3.fromRGB(99, 102, 241),
        AccentMuted = Color3.fromRGB(60, 63, 150),
        Danger = Color3.fromRGB(239, 68, 68),
        Success = Color3.fromRGB(34, 197, 94),
    },
    Themes = {
        Obsidian = {
            Background = Color3.fromRGB(10, 10, 10),
            Surface = Color3.fromRGB(18, 18, 18),
            Border = Color3.fromRGB(30, 30, 30),
            Accent = Color3.fromRGB(99, 102, 241),
        },
        Midnight = {
            Background = Color3.fromRGB(5, 5, 10),
            Surface = Color3.fromRGB(12, 12, 20),
            Border = Color3.fromRGB(25, 25, 40),
            Accent = Color3.fromRGB(139, 92, 246),
        },
        Rose = {
            Background = Color3.fromRGB(15, 10, 12),
            Surface = Color3.fromRGB(25, 18, 20),
            Border = Color3.fromRGB(40, 30, 35),
            Accent = Color3.fromRGB(244, 63, 94),
        }
    },
    Changed = Signal.new()
}
function Theme:SetTheme(name)
    local data = self.Themes[name]
    if data then for k, v in pairs(data) do self.Current[k] = v end self.Changed:Fire(self.Current) end
end

-- [[ UTILITIES ]]

local function CreateShadow(parent, radius, transparency)
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Image = "rbxassetid://6015897843"
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.BackgroundTransparency = 1
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = transparency or 0.35
    Shadow.Size = UDim2.new(1, 18, 1, 18)
    Shadow.Position = UDim2.fromOffset(-9, -9)
    Shadow.ZIndex = parent.ZIndex - 1
    local Corner = Instance.new("UICorner", Shadow)
    Corner.CornerRadius = UDim.new(0, radius)
    Shadow.Parent = parent
    return Shadow
end

local function CreateAcrylic(parent)
    local Noise = Instance.new("ImageLabel")
    Noise.Name = "Noise"
    Noise.Image = "rbxassetid://9968344105"
    Noise.ImageTransparency = 0.94
    Noise.ScaleType = Enum.ScaleType.Tile
    Noise.TileSize = UDim2.fromOffset(128, 128)
    Noise.BackgroundTransparency = 1
    Noise.Size = UDim2.fromScale(1, 1)
    Noise.ZIndex = 1
    Noise.Parent = parent
    return Noise
end

local function GetMouse()
    local mouse = UserInputService:GetMouseLocation()
    local inset = GuiService:GetGuiInset()
    return Vector2.new(mouse.X, mouse.Y - inset.Y)
end

-- [[ COMPONENT BASE ]]

local Component = {}
Component.__index = Component
function Component.new(name)
    return setmetatable({
        Name = name,
        _maid = Maid.new(),
        _state = {},
        _instances = {}
    }, Component)
end
function Component:SubscribeTheme(callback)
    self._maid:GiveTask(Theme.Changed:Connect(callback))
    callback(Theme.Current)
end

-- [[ ADVANCED COMPONENTS ]]

-- Button Component (Refined)
local Button = setmetatable({}, Component)
Button.__index = Button
function Button.new(section, options)
    local self = Component.new(options.Name or "Button")
    setmetatable(self, Button)
    
    self.Section = section
    self.Callback = options.Callback or function() end
    
    local Container = Instance.new("TextButton")
    Container.Name = self.Name
    Container.Size = UDim2.new(1, 0, 0, 34)
    Container.BackgroundColor3 = Theme.Current.Surface
    Container.BorderSizePixel = 0
    Container.AutoButtonColor = false
    Container.ClipsDescendants = true
    Container.Text = ""
    Container.Parent = self.Section.Instances.Content
    
    local Corner = Instance.new("UICorner", Container)
    Corner.CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke", Container)
    Stroke.Color = Theme.Current.Border
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = self.Name
    Label.TextColor3 = Theme.Current.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.ZIndex = 2
    
    local hoverSpring = Spring.new(45, 0.75)
    local pressSpring = Spring.new(65, 0.7)
    
    self._maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
        local h = hoverSpring:Update(dt)
        local p = pressSpring:Update(dt)
        
        Stroke.Color = Theme.Current.Border:Lerp(Theme.Current.Accent, h)
        Container.BackgroundColor3 = Theme.Current.Surface:Lerp(Theme.Current.SurfaceLight, h)
        Container.Position = UDim2.fromOffset(0, -h * 1)
        Label.TextSize = 13 - (p * 1)
    end))
    
    Container.MouseEnter:Connect(function() hoverSpring.Position = 0.4; hoverSpring.Target = 1 end)
    Container.MouseLeave:Connect(function() hoverSpring.Target = 0; pressSpring.Target = 0 end)
    Container.MouseButton1Down:Connect(function() pressSpring.Target = 1 end)
    
    Container.MouseButton1Up:Connect(function() 
        pressSpring.Target = 0
        local mouse = GetMouse()
        local relativeX = mouse.X - Container.AbsolutePosition.X
        local relativeY = mouse.Y - Container.AbsolutePosition.Y
        
        local size = math.max(Container.AbsoluteSize.X, Container.AbsoluteSize.Y) * 1.5
        local Ripple = Instance.new("Frame", Container)
        Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        Ripple.BackgroundColor3 = Color3.new(1, 1, 1)
        Ripple.Position = UDim2.fromOffset(relativeX, relativeY)
        Ripple.Size = UDim2.fromOffset(0, 0)
        Ripple.ZIndex = 3
        Instance.new("UICorner", Ripple).CornerRadius = UDim.new(1, 0)
        
        TweenService:Create(Ripple, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(size, size), 
            BackgroundTransparency = 1
        }):Play()
        task.delay(0.3, function() Ripple:Destroy() end)
        
        self.Callback() 
    end)
    
    self:SubscribeTheme(function(theme)
        Label.TextColor3 = theme.Text
        Stroke.Color = theme.Border
    end)
    
    return self
end

-- Toggle Component (Refined)
local Toggle = setmetatable({}, Component)
Toggle.__index = Toggle
function Toggle.new(section, options)
    local self = Component.new(options.Name or "Toggle")
    setmetatable(self, Toggle)
    
    self.Section = section
    self.State = options.Default or false
    self.Callback = options.Callback or function() end
    
    local Container = Instance.new("TextButton", self.Section.Instances.Content)
    Container.Size = UDim2.new(1, 0, 0, 34)
    Container.BackgroundTransparency = 1
    Container.Text = ""
    
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = self.Name
    Label.TextColor3 = Theme.Current.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Switch = Instance.new("Frame", Container)
    Switch.Size = UDim2.fromOffset(36, 20)
    Switch.Position = UDim2.new(1, -36, 0.5, 0)
    Switch.AnchorPoint = Vector2.new(0, 0.5)
    Switch.BackgroundColor3 = self.State and Theme.Current.Accent or Theme.Current.Border
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
    
    local Knob = Instance.new("Frame", Switch)
    Knob.Size = UDim2.fromOffset(14, 14)
    Knob.Position = self.State and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    Knob.AnchorPoint = Vector2.new(0, 0.5)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    
    local stateSpring = Spring.new(55, 0.7)
    stateSpring.Position = self.State and 1 or 0
    stateSpring.Target = stateSpring.Position
    
    self._maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
        local s = stateSpring:Update(dt)
        local alpha = math.pow(s, 0.7)
        Switch.BackgroundColor3 = Theme.Current.Border:Lerp(Theme.Current.Accent, alpha)
        Knob.Position = UDim2.new(0, 3 + (s * 16), 0.5, 0)
    end))
    
    Container.MouseButton1Click:Connect(function()
        self.State = not self.State
        stateSpring.Target = self.State and 1 or 0
        self.Callback(self.State)
    end)
    
    return self
end

-- Slider Component (Advanced)
local Slider = setmetatable({}, Component)
Slider.__index = Slider
function Slider.new(section, options)
    local self = Component.new(options.Name or "Slider")
    setmetatable(self, Slider)
    
    self.Section = section
    self.Min = options.Min or 0
    self.Max = options.Max or 100
    self.Value = options.Default or 50
    self.Suffix = options.Suffix or ""
    self.Callback = options.Callback or function() end
    self.Dragging = false
    
    local Container = Instance.new("Frame", self.Section.Instances.Content)
    Container.Size = UDim2.new(1, 0, 0, 48)
    Container.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = self.Name
    Label.TextColor3 = Theme.Current.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ValueLabel = Instance.new("TextLabel", Container)
    ValueLabel.Size = UDim2.new(1, 0, 0, 20)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(self.Value) .. self.Suffix
    ValueLabel.TextColor3 = Theme.Current.TextMuted
    ValueLabel.Font = Enum.Font.GothamSemibold
    ValueLabel.TextSize = 12
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local Track = Instance.new("TextButton", Container)
    Track.Size = UDim2.new(1, 0, 0, 6)
    Track.Position = UDim2.fromOffset(0, 32)
    Track.BackgroundColor3 = Theme.Current.Border
    Track.BorderSizePixel = 0
    Track.Text = ""
    Track.AutoButtonColor = false
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.fromScale((self.Value - self.Min) / (self.Max - self.Min), 1)
    Fill.BackgroundColor3 = Theme.Current.Accent
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.fromOffset(14, 14)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(Fill.Size.X.Scale, 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    CreateShadow(Knob, 7, 0.5)
    
    local fillSpring = Spring.new(70, 0.72)
    fillSpring.Position = Fill.Size.X.Scale
    fillSpring.Target = fillSpring.Position
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        self.Value = math.floor(self.Min + (self.Max - self.Min) * pos)
        ValueLabel.Text = tostring(self.Value) .. self.Suffix
        fillSpring.Target = pos
        self.Callback(self.Value)
    end
    
    self._maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
        local f = fillSpring:Update(dt)
        Fill.Size = UDim2.fromScale(f, 1)
        Knob.Position = UDim2.new(f, 0, 0.5, 0)
    end))
    
    Track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then self.Dragging = true; Update(input) end end)
    self._maid:GiveTask(UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then self.Dragging = false end end))
    self._maid:GiveTask(UserInputService.InputChanged:Connect(function(input) if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end end))
    
    return self
end

-- Dropdown Component (Elite)
local Dropdown = setmetatable({}, Component)
Dropdown.__index = Dropdown
function Dropdown.new(section, options)
    local self = Component.new(options.Name or "Dropdown")
    setmetatable(self, Dropdown)
    
    self.Section = section
    self.Options = options.Options or {}
    self.Selected = options.Default or nil
    self.Callback = options.Callback or function() end
    self.Open = false
    
    local Container = Instance.new("Frame", self.Section.Instances.Content)
    Container.Size = UDim2.new(1, 0, 0, 60)
    Container.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = self.Name
    Label.TextColor3 = Theme.Current.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Selector = Instance.new("TextButton", Container)
    Selector.Size = UDim2.new(1, 0, 0, 34)
    Selector.Position = UDim2.fromOffset(0, 24)
    Selector.BackgroundColor3 = Theme.Current.Surface
    Selector.BorderSizePixel = 0
    Selector.AutoButtonColor = false
    Selector.Text = ""
    Instance.new("UICorner", Selector).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Selector)
    Stroke.Color = Theme.Current.Border
    
    local SelectedLabel = Instance.new("TextLabel", Selector)
    SelectedLabel.Size = UDim2.new(1, -40, 1, 0)
    SelectedLabel.Position = UDim2.fromOffset(12, 0)
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Text = self.Selected or "Select Option..."
    SelectedLabel.TextColor3 = Theme.Current.TextMuted
    SelectedLabel.Font = Enum.Font.Gotham
    SelectedLabel.TextSize = 13
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local Icon = Instance.new("ImageLabel", Selector)
    Icon.Size = UDim2.fromOffset(16, 16)
    Icon.Position = UDim2.new(1, -28, 0.5, 0)
    Icon.AnchorPoint = Vector2.new(0, 0.5)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://6031091007"
    Icon.ImageColor3 = Theme.Current.TextMuted
    
    local List = Instance.new("ScrollingFrame", Selector)
    List.Size = UDim2.new(1, 0, 0, 0)
    List.Position = UDim2.new(0, 0, 1, 4)
    List.BackgroundColor3 = Theme.Current.Surface
    List.BorderSizePixel = 0
    List.Visible = false
    List.ClipsDescendants = true
    List.ZIndex = 10
    List.ScrollBarThickness = 0
    Instance.new("UICorner", List).CornerRadius = UDim.new(0, 8)
    CreateShadow(List, 8, 0.4)
    
    local ListLayout = Instance.new("UIListLayout", List)
    ListLayout.Padding = UDim.new(0, 2)
    
    local function UpdateList()
        for _, opt in ipairs(self.Options) do
            local OptBtn = Instance.new("TextButton", List)
            OptBtn.Size = UDim2.new(1, 0, 0, 30)
            OptBtn.BackgroundTransparency = 1
            OptBtn.Text = "  " .. opt
            OptBtn.TextColor3 = Theme.Current.TextMuted
            OptBtn.Font = Enum.Font.Gotham
            OptBtn.TextSize = 13
            OptBtn.TextXAlignment = Enum.TextXAlignment.Left
            OptBtn.ZIndex = 11
            
            OptBtn.MouseEnter:Connect(function() OptBtn.BackgroundTransparency = 0.9; OptBtn.BackgroundColor3 = Color3.new(1,1,1) end)
            OptBtn.MouseLeave:Connect(function() OptBtn.BackgroundTransparency = 1 end)
            OptBtn.MouseButton1Click:Connect(function()
                self.Selected = opt
                SelectedLabel.Text = opt
                self.Callback(opt)
                self:Toggle(false)
            end)
        end
    end
    UpdateList()
    
    function self:Toggle(state)
        self.Open = state
        List.Visible = true
        local targetSize = state and math.min(#self.Options * 32, 160) or 0
        TweenService:Create(List, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, targetSize)}):Play()
        TweenService:Create(Icon, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Rotation = state and 180 or 0}):Play()
        if not state then task.delay(0.3, function() if not self.Open then List.Visible = false end end) end
    end
    
    Selector.MouseButton1Click:Connect(function() self:Toggle(not self.Open) end)
    
    return self
end

-- [[ MANAGERS ]]

-- Section Manager
local Section = {}
Section.__index = Section
function Section.new(tab, options)
    local self = setmetatable({ Tab = tab, Name = options.Name or "Section" }, Section)
    local Container = Instance.new("Frame", self.Tab.Instances.Content)
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundColor3 = Theme.Current.Surface
    Container.BorderSizePixel = 0
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Container)
    Stroke.Color = Theme.Current.Border
    
    local Title = Instance.new("TextLabel", Container)
    Title.Size = UDim2.new(1, -20, 0, 30)
    Title.Position = UDim2.fromOffset(10, 5)
    Title.BackgroundTransparency = 1
    Title.Text = self.Name:upper()
    Title.TextColor3 = Theme.Current.Accent
    Title.TextSize = 11
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local Content = Instance.new("Frame", Container)
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -20, 0, 0)
    Content.Position = UDim2.fromOffset(10, 35)
    Content.BackgroundTransparency = 1
    local List = Instance.new("UIListLayout", Content)
    List.Padding = UDim.new(0, 8)
    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.Size = UDim2.new(1, -20, 0, List.AbsoluteContentSize.Y)
        Container.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 45)
    end)
    self.Instances = { Content = Content }
    return self
end
function Section:CreateToggle(options) return Toggle.new(self, options) end
function Section:CreateButton(options) return Button.new(self, options) end
function Section:CreateSlider(options) return Slider.new(self, options) end
function Section:CreateDropdown(options) return Dropdown.new(self, options) end

-- Tab Manager
local Tab = {}
Tab.__index = Tab
function Tab.new(window, options)
    local self = setmetatable({ Window = window, Name = options.Name or "Tab", Active = false }, Tab)
    local Button = Instance.new("TextButton", self.Window.Instances.TabContainer)
    Button.Size = UDim2.new(1, 0, 0, 34)
    Button.BackgroundTransparency = 1
    Button.Text = "  " .. self.Name
    Button.TextColor3 = Theme.Current.TextMuted
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 13
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
    
    local Content = Instance.new("ScrollingFrame", self.Window.Instances.Main)
    Content.Size = UDim2.new(1, -220, 1, -20)
    Content.Position = UDim2.fromOffset(210, 10)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.Visible = false
    Content.ScrollBarThickness = 0
    Instance.new("UIListLayout", Content).Padding = UDim.new(0, 12)
    
    self.Instances = { Button = Button, Content = Content }
    Button.MouseButton1Click:Connect(function() self:Select() end)
    return self
end
function Tab:Select()
    if self.Window.CurrentTab then self.Window.CurrentTab:Deselect() end
    self.Active = true
    self.Window.CurrentTab = self
    self.Instances.Content.Visible = true
    TweenService:Create(self.Instances.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0, BackgroundColor3 = Theme.Current.Accent, TextColor3 = Color3.new(1, 1, 1)}):Play()
end
function Tab:Deselect()
    self.Active = false
    self.Instances.Content.Visible = false
    TweenService:Create(self.Instances.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1, TextColor3 = Theme.Current.TextMuted}):Play()
end
function Tab:CreateSection(options) return Section.new(self, options) end

-- Window Manager
local Window = {}
Window.__index = Window
function Window.new(options)
    local self = setmetatable({
        Title = options.Title or "Window",
        Size = options.Size or UDim2.fromOffset(760, 520),
        _maid = Maid.new()
    }, Window)
    
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "PhantomUI_Full"
    
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.fromOffset(0, 0)
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Theme.Current.Background
    Main.BackgroundTransparency = 0.1
    Main.BorderSizePixel = 0
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    CreateShadow(Main, 12, 0.4)
    CreateAcrylic(Main)
    
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Current.Surface
    Sidebar.BackgroundTransparency = 0.2
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)
    
    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, -20, 1, -60)
    TabContainer.Position = UDim2.fromOffset(10, 50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 4)
    
    local UIScale = Instance.new("UIScale", Main)
    UIScale.Scale = math.clamp(Camera.ViewportSize.Y / 1080, 0.8, 1)
    
    self.Instances = { ScreenGui = ScreenGui, Main = Main, TabContainer = TabContainer }
    self._maid:GiveTask(ScreenGui)
    
    -- Smooth Dragging (Lerping)
    local targetPos = Main.Position
    local dragging, dragStart, startPos
    
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    
    self._maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    
    self._maid:GiveTask(UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end))
    
    self._maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
        Main.Position = Main.Position:Lerp(targetPos, 1 - math.exp(-25 * dt))
    end))
    
    -- Open Animation
    TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = self.Size}):Play()
    
    return self
end
function Window:CreateTab(options)
    local newTab = Tab.new(self, options)
    if not self.CurrentTab then newTab:Select() end
    return newTab
end

-- [[ LIBRARY API ]]

function Library:CreateWindow(options)
    local newWindow = Window.new(options)
    table.insert(self.Windows, newWindow)
    return newWindow
end

function Library:Notify(options)
    local Title = options.Title or "Notification"
    local Content = options.Content or ""
    local Duration = options.Duration or 5
    
    local NotificationGui = CoreGui:FindFirstChild("PhantomNotifications")
    if not NotificationGui then
        NotificationGui = Instance.new("ScreenGui", CoreGui)
        NotificationGui.Name = "PhantomNotifications"
    end
    
    local Container = NotificationGui:FindFirstChild("Container")
    if not Container then
        Container = Instance.new("Frame", NotificationGui)
        Container.Name = "Container"
        Container.Size = UDim2.new(0, 300, 1, -40)
        Container.Position = UDim2.new(1, -320, 0, 20)
        Container.BackgroundTransparency = 1
        local List = Instance.new("UIListLayout", Container)
        List.VerticalAlignment = Enum.VerticalAlignment.Bottom
        List.Padding = UDim.new(0, 10)
    end
    
    local Toast = Instance.new("Frame", Container)
    Toast.Size = UDim2.new(1, 0, 0, 64)
    Toast.BackgroundColor3 = Theme.Current.Background
    Toast.BackgroundTransparency = 0.1
    Instance.new("UICorner", Toast).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", Toast).Color = Theme.Current.Border
    CreateShadow(Toast, 10, 0.5)
    
    local T = Instance.new("TextLabel", Toast)
    T.Size = UDim2.new(1, -20, 0, 25)
    T.Position = UDim2.fromOffset(10, 8)
    T.BackgroundTransparency = 1
    T.Text = Title
    T.TextColor3 = Theme.Current.Accent
    T.Font = Enum.Font.GothamBold
    T.TextSize = 13
    T.TextXAlignment = Enum.TextXAlignment.Left
    
    local C = Instance.new("TextLabel", Toast)
    C.Size = UDim2.new(1, -20, 0, 20)
    C.Position = UDim2.fromOffset(10, 32)
    C.BackgroundTransparency = 1
    C.Text = Content
    C.TextColor3 = Theme.Current.Text
    C.Font = Enum.Font.Gotham
    C.TextSize = 12
    C.TextXAlignment = Enum.TextXAlignment.Left
    
    Toast.Position = UDim2.new(1, 320, 0, 0)
    TweenService:Create(Toast, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    task.delay(Duration, function()
        TweenService:Create(Toast, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 320, 0, 0)}):Play()
        task.wait(0.6)
        Toast:Destroy()
    end)
end

function Library:Destroy()
    for _, window in ipairs(self.Windows) do window._maid:Destroy() end
    self.Windows = {}
    if self._maid then self._maid:Destroy() end
end

return Library

-- Color Picker Component (Elite)
local ColorPicker = setmetatable({}, Component)
ColorPicker.__index = ColorPicker
function ColorPicker.new(section, options)
    local self = Component.new(options.Name or "Color Picker")
    setmetatable(self, ColorPicker)
    
    self.Section = section
    self.Value = options.Default or Color3.new(1, 1, 1)
    self.Callback = options.Callback or function() end
    self.Open = false
    
    local h, s, v = self.Value:ToHSV()
    self.H, self.S, self.V = h, s, v
    
    local Container = Instance.new("Frame", self.Section.Instances.Content)
    Container.Size = UDim2.new(1, 0, 0, 34)
    Container.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = self.Name
    Label.TextColor3 = Theme.Current.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Preview = Instance.new("TextButton", Container)
    Preview.Size = UDim2.fromOffset(40, 20)
    Preview.Position = UDim2.new(1, -40, 0.5, 0)
    Preview.AnchorPoint = Vector2.new(0, 0.5)
    Preview.BackgroundColor3 = self.Value
    Preview.Text = ""
    Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)
    local Stroke = Instance.new("UIStroke", Preview)
    Stroke.Color = Theme.Current.Border
    
    local Picker = Instance.new("Frame", Preview)
    Picker.Size = UDim2.fromOffset(180, 160)
    Picker.Position = UDim2.new(1, 10, 0, 0)
    Picker.BackgroundColor3 = Theme.Current.Surface
    Picker.Visible = false
    Picker.ZIndex = 20
    Instance.new("UICorner", Picker).CornerRadius = UDim.new(0, 8)
    CreateShadow(Picker, 8, 0.4)
    
    local SatVal = Instance.new("ImageButton", Picker)
    SatVal.Size = UDim2.fromOffset(140, 140)
    SatVal.Position = UDim2.fromOffset(10, 10)
    SatVal.Image = "rbxassetid://4155801252"
    SatVal.BackgroundColor3 = Color3.fromHSV(self.H, 1, 1)
    
    local Hue = Instance.new("ImageButton", Picker)
    Hue.Size = UDim2.fromOffset(15, 140)
    Hue.Position = UDim2.fromOffset(155, 10)
    Hue.Image = "rbxassetid://4155801337"
    
    local function Update()
        self.Value = Color3.fromHSV(self.H, self.S, self.V)
        Preview.BackgroundColor3 = self.Value
        SatVal.BackgroundColor3 = Color3.fromHSV(self.H, 1, 1)
        self.Callback(self.Value)
    end
    
    SatVal.MouseButton1Down:Connect(function()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then connection:Disconnect() return end
            local mouse = GetMouse()
            local relX = math.clamp((mouse.X - SatVal.AbsolutePosition.X) / SatVal.AbsoluteSize.X, 0, 1)
            local relY = 1 - math.clamp((mouse.Y - SatVal.AbsolutePosition.Y) / SatVal.AbsoluteSize.Y, 0, 1)
            self.S, self.V = relX, relY
            Update()
        end)
    end)
    
    Hue.MouseButton1Down:Connect(function()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then connection:Disconnect() return end
            local mouse = GetMouse()
            local relY = 1 - math.clamp((mouse.Y - Hue.AbsolutePosition.Y) / Hue.AbsoluteSize.Y, 0, 1)
            self.H = relY
            Update()
        end)
    end)
    
    Preview.MouseButton1Click:Connect(function()
        self.Open = not self.Open
        Picker.Visible = self.Open
    end)
    
    return self
end

-- Keybind Component (Elite)
local Keybind = setmetatable({}, Component)
Keybind.__index = Keybind
function Keybind.new(section, options)
    local self = Component.new(options.Name or "Keybind")
    setmetatable(self, Keybind)
    
    self.Section = section
    self.Binding = options.Default or Enum.KeyCode.F
    self.Callback = options.Callback or function() end
    self.IsBinding = false
    
    local Container = Instance.new("Frame", self.Section.Instances.Content)
    Container.Size = UDim2.new(1, 0, 0, 34)
    Container.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = self.Name
    Label.TextColor3 = Theme.Current.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local BindBtn = Instance.new("TextButton", Container)
    BindBtn.Size = UDim2.fromOffset(70, 22)
    BindBtn.Position = UDim2.new(1, -70, 0.5, 0)
    BindBtn.AnchorPoint = Vector2.new(0, 0.5)
    BindBtn.BackgroundColor3 = Theme.Current.Surface
    BindBtn.Text = self.Binding.Name
    BindBtn.TextColor3 = Theme.Current.TextMuted
    BindBtn.Font = Enum.Font.GothamBold
    BindBtn.TextSize = 11
    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
    local Stroke = Instance.new("UIStroke", BindBtn)
    Stroke.Color = Theme.Current.Border
    
    BindBtn.MouseButton1Click:Connect(function()
        self.IsBinding = true
        BindBtn.Text = "..."
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                self.Binding = input.KeyCode
                BindBtn.Text = self.Binding.Name
                self.IsBinding = false
                connection:Disconnect()
            end
        end)
    end)
    
    self._maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.Binding and not self.IsBinding then
            self.Callback()
        end
    end))
    
    return self
end

function Section:CreateColorPicker(options) return ColorPicker.new(self, options) end
function Section:CreateKeybind(options) return Keybind.new(self, options) end

-- Textbox Component (Advanced)
local Textbox = setmetatable({}, Component)
Textbox.__index = Textbox
function Textbox.new(section, options)
    local self = Component.new(options.Name or "Textbox")
    setmetatable(self, Textbox)
    
    self.Section = section
    self.Placeholder = options.Placeholder or "Type here..."
    self.Callback = options.Callback or function() end
    
    local Container = Instance.new("Frame", self.Section.Instances.Content)
    Container.Size = UDim2.new(1, 0, 0, 60)
    Container.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = self.Name
    Label.TextColor3 = Theme.Current.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local InputBox = Instance.new("TextBox", Container)
    InputBox.Size = UDim2.new(1, 0, 0, 34)
    InputBox.Position = UDim2.fromOffset(0, 24)
    InputBox.BackgroundColor3 = Theme.Current.Surface
    InputBox.Text = ""
    InputBox.PlaceholderText = self.Placeholder
    InputBox.PlaceholderColor3 = Theme.Current.TextMuted
    InputBox.TextColor3 = Theme.Current.Text
    InputBox.Font = Enum.Font.Gotham
    InputBox.TextSize = 13
    InputBox.ClipsDescendants = true
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", InputBox)
    Stroke.Color = Theme.Current.Border
    
    InputBox.FocusLost:Connect(function(enter)
        if enter then
            self.Callback(InputBox.Text)
        end
    end)
    
    InputBox.Focused:Connect(function()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = Theme.Current.Accent}):Play()
    end)
    
    InputBox.FocusLost:Connect(function()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = Theme.Current.Border}):Play()
    end)
    
    return self
end

-- Paragraph Component
local Paragraph = setmetatable({}, Component)
Paragraph.__index = Paragraph
function Paragraph.new(section, options)
    local self = Component.new("Paragraph")
    setmetatable(self, Paragraph)
    
    self.Section = section
    self.Title = options.Title or "Info"
    self.Content = options.Content or "Content goes here."
    
    local Container = Instance.new("Frame", self.Section.Instances.Content)
    Container.Size = UDim2.new(1, 0, 0, 60)
    Container.BackgroundColor3 = Theme.Current.Surface
    Container.BackgroundTransparency = 0.5
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Container)
    Stroke.Color = Theme.Current.Border
    Stroke.DashPattern = {4, 4}
    
    local T = Instance.new("TextLabel", Container)
    T.Size = UDim2.new(1, -20, 0, 20)
    T.Position = UDim2.fromOffset(10, 8)
    T.BackgroundTransparency = 1
    T.Text = self.Title
    T.TextColor3 = Theme.Current.Text
    T.Font = Enum.Font.GothamBold
    T.TextSize = 13
    T.TextXAlignment = Enum.TextXAlignment.Left
    
    local C = Instance.new("TextLabel", Container)
    C.Size = UDim2.new(1, -20, 0, 0)
    C.Position = UDim2.fromOffset(10, 30)
    C.BackgroundTransparency = 1
    C.Text = self.Content
    C.TextColor3 = Theme.Current.TextMuted
    C.Font = Enum.Font.Gotham
    C.TextSize = 12
    C.TextXAlignment = Enum.TextXAlignment.Left
    C.TextWrapped = true
    
    local function UpdateSize()
        local size = TextService:GetTextSize(self.Content, 12, Enum.Font.Gotham, Vector2.new(Container.AbsoluteSize.X - 20, 1000))
        C.Size = UDim2.new(1, -20, 0, size.Y)
        Container.Size = UDim2.new(1, 0, 0, size.Y + 45)
    end
    
    Container:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)
    task.spawn(UpdateSize)
    
    return self
end

function Section:CreateTextbox(options) return Textbox.new(self, options) end
function Section:CreateParagraph(options) return Paragraph.new(self, options) end

-- [[ GLOBAL LOGIC ]]

-- Global Keybind to Toggle UI
Library._maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        Library.Open = not Library.Open
        for _, window in ipairs(Library.Windows) do
            window.Instances.ScreenGui.Enabled = Library.Open
        end
    end
end))

-- Auto-scaling on Viewport Change
Library._maid:GiveTask(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local scale = math.clamp(Camera.ViewportSize.Y / 1080, 0.8, 1)
    for _, window in ipairs(Library.Windows) do
        window.Instances.Main.UIScale.Scale = scale
    end
end))

return Library

-- [[ EXTENDED FRAMEWORK FEATURES ]]

-- Multi-Select Dropdown (Elite)
local MultiDropdown = setmetatable({}, Component)
MultiDropdown.__index = MultiDropdown
function MultiDropdown.new(section, options)
    local self = Component.new(options.Name or "Multi-Dropdown")
    setmetatable(self, MultiDropdown)
    
    self.Section = section
    self.Options = options.Options or {}
    self.Selected = options.Default or {}
    self.Callback = options.Callback or function() end
    self.Open = false
    
    local Container = Instance.new("Frame", self.Section.Instances.Content)
    Container.Size = UDim2.new(1, 0, 0, 60)
    Container.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Container)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = self.Name
    Label.TextColor3 = Theme.Current.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Selector = Instance.new("TextButton", Container)
    Selector.Size = UDim2.new(1, 0, 0, 34)
    Selector.Position = UDim2.fromOffset(0, 24)
    Selector.BackgroundColor3 = Theme.Current.Surface
    Selector.BorderSizePixel = 0
    Selector.AutoButtonColor = false
    Selector.Text = ""
    Instance.new("UICorner", Selector).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Selector)
    Stroke.Color = Theme.Current.Border
    
    local SelectedLabel = Instance.new("TextLabel", Selector)
    SelectedLabel.Size = UDim2.new(1, -40, 1, 0)
    SelectedLabel.Position = UDim2.fromOffset(12, 0)
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Text = #self.Selected > 0 and table.concat(self.Selected, ", ") or "Select Options..."
    SelectedLabel.TextColor3 = Theme.Current.TextMuted
    SelectedLabel.Font = Enum.Font.Gotham
    SelectedLabel.TextSize = 13
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SelectedLabel.ClipsDescendants = true
    
    local List = Instance.new("ScrollingFrame", Selector)
    List.Size = UDim2.new(1, 0, 0, 0)
    List.Position = UDim2.new(0, 0, 1, 4)
    List.BackgroundColor3 = Theme.Current.Surface
    List.BorderSizePixel = 0
    List.Visible = false
    List.ZIndex = 15
    List.ScrollBarThickness = 0
    Instance.new("UICorner", List).CornerRadius = UDim.new(0, 8)
    CreateShadow(List, 8, 0.4)
    
    local ListLayout = Instance.new("UIListLayout", List)
    ListLayout.Padding = UDim.new(0, 2)
    
    local function UpdateSelected()
        SelectedLabel.Text = #self.Selected > 0 and table.concat(self.Selected, ", ") or "Select Options..."
        self.Callback(self.Selected)
    end
    
    for _, opt in ipairs(self.Options) do
        local OptBtn = Instance.new("TextButton", List)
        OptBtn.Size = UDim2.new(1, 0, 0, 32)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = "  " .. opt
        OptBtn.TextColor3 = table.find(self.Selected, opt) and Theme.Current.Accent or Theme.Current.TextMuted
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.TextSize = 13
        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
        OptBtn.ZIndex = 16
        
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
        end)
    end
    
    Selector.MouseButton1Click:Connect(function()
        self.Open = not self.Open
        List.Visible = true
        local targetSize = self.Open and math.min(#self.Options * 34, 200) or 0
        TweenService:Create(List, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, targetSize)}):Play()
        if not self.Open then task.delay(0.4, function() if not self.Open then List.Visible = false end end) end
    end)
    
    return self
end

-- Searchable List Component
local SearchList = setmetatable({}, Component)
SearchList.__index = SearchList
function SearchList.new(section, options)
    local self = Component.new(options.Name or "Search List")
    setmetatable(self, SearchList)
    
    self.Section = section
    self.Items = options.Items or {}
    self.Callback = options.Callback or function() end
    
    local Container = Instance.new("Frame", self.Section.Instances.Content)
    Container.Size = UDim2.new(1, 0, 0, 200)
    Container.BackgroundColor3 = Theme.Current.Surface
    Container.BackgroundTransparency = 0.5
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Container)
    Stroke.Color = Theme.Current.Border
    
    local SearchBar = Instance.new("TextBox", Container)
    SearchBar.Size = UDim2.new(1, -20, 0, 30)
    SearchBar.Position = UDim2.fromOffset(10, 10)
    SearchBar.BackgroundColor3 = Theme.Current.Background
    SearchBar.Text = ""
    SearchBar.PlaceholderText = "Search items..."
    SearchBar.PlaceholderColor3 = Theme.Current.TextMuted
    SearchBar.TextColor3 = Theme.Current.Text
    SearchBar.Font = Enum.Font.Gotham
    SearchBar.TextSize = 12
    Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 6)
    
    local Scroll = Instance.new("ScrollingFrame", Container)
    Scroll.Size = UDim2.new(1, -20, 1, -50)
    Scroll.Position = UDim2.fromOffset(10, 45)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 2
    Scroll.ScrollBarImageColor3 = Theme.Current.Border
    local ListLayout = Instance.new("UIListLayout", Scroll)
    ListLayout.Padding = UDim.new(0, 4)
    
    local function Populate(filter)
        for _, child in ipairs(Scroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for _, item in ipairs(self.Items) do
            if not filter or item:lower():find(filter:lower()) then
                local Btn = Instance.new("TextButton", Scroll)
                Btn.Size = UDim2.new(1, -5, 0, 28)
                Btn.BackgroundTransparency = 0.9
                Btn.BackgroundColor3 = Color3.new(1,1,1)
                Btn.Text = "  " .. item
                Btn.TextColor3 = Theme.Current.Text
                Btn.Font = Enum.Font.Gotham
                Btn.TextSize = 12
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
                
                Btn.MouseButton1Click:Connect(function() self.Callback(item) end)
            end
        end
    end
    Populate()
    
    SearchBar:GetPropertyChangedSignal("Text"):Connect(function() Populate(SearchBar.Text) end)
    
    return self
end

function Section:CreateMultiDropdown(options) return MultiDropdown.new(self, options) end
function Section:CreateSearchList(options) return SearchList.new(self, options) end

-- [[ FURTHER EXTENSIONS ]]

-- Window Resizing Logic
function Window:EnableResizing()
    local ResizeBtn = Instance.new("ImageButton", self.Instances.Main)
    ResizeBtn.Size = UDim2.fromOffset(16, 16)
    ResizeBtn.Position = UDim2.new(1, -16, 1, -16)
    ResizeBtn.BackgroundTransparency = 1
    ResizeBtn.Image = "rbxassetid://6031091007"
    ResizeBtn.ImageColor3 = Theme.Current.TextMuted
    ResizeBtn.Rotation = 45
    
    local resizing, startSize, startMouse
    ResizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startSize = self.Instances.Main.Size
            startMouse = UserInputService:GetMouseLocation()
        end
    end)
    
    self._maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = UserInputService:GetMouseLocation()
            local delta = mouse - startMouse
            self.Instances.Main.Size = UDim2.fromOffset(
                math.clamp(startSize.X.Offset + delta.X, 400, 1000),
                math.clamp(startSize.Y.Offset + delta.Y, 300, 800)
            )
        end
    end))
    
    self._maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
    end))
end

-- Tab Icons Support
function Tab:SetIcon(id)
    if self.Instances.Icon then self.Instances.Icon:Destroy() end
    local Icon = Instance.new("ImageLabel", self.Instances.Button)
    Icon.Size = UDim2.fromOffset(16, 16)
    Icon.Position = UDim2.fromOffset(8, 9)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://" .. tostring(id)
    Icon.ImageColor3 = Theme.Current.TextMuted
    self.Instances.Icon = Icon
    self.Instances.Button.Text = "      " .. self.Name
end

-- Advanced Notification Queue
local NotificationQueue = {
    Active = {},
    Pending = {}
}
function Library:PushNotification(options)
    if #NotificationQueue.Active >= 5 then
        table.insert(NotificationQueue.Pending, options)
        return
    end
    
    table.insert(NotificationQueue.Active, options)
    self:Notify(options)
    
    task.delay(options.Duration or 5, function()
        table.remove(NotificationQueue.Active, 1)
        if #NotificationQueue.Pending > 0 then
            local nextNotif = table.remove(NotificationQueue.Pending, 1)
            Library:PushNotification(nextNotif)
        end
    end)
end

-- Global Theme Propagation Fix
Theme.Changed:Connect(function(newTheme)
    for _, window in ipairs(Library.Windows) do
        window.Instances.Main.BackgroundColor3 = newTheme.Background
        window.Instances.Sidebar.BackgroundColor3 = newTheme.Surface
    end
end)

-- [[ FINAL BUNDLE WRAPPER ]]
-- This section ensures the library is returned correctly and handles any final initialization.

task.spawn(function()
    print("---------------------------------------")
    print("PhantomUI Framework v2.0.0 Initialized")
    print("Developed for Elite Roblox Developers")
    print("---------------------------------------")
end)

