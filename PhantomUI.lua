-- PhantomUI_Premium.lua
-- Professional Roblox UI Framework (Refined Premium Version)
-- Bundled for single-file distribution

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local Camera = workspace.CurrentCamera

local Library = {
    Version = "1.2.0",
    Windows = {},
    Notifications = {},
    _maid = nil
}

-- [[ CORE SYSTEMS ]]

-- Maid: Handles cleanup of tasks, connections, and instances.
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

-- Signals: Custom event system.
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

-- Spring System: For ultra-smooth physics-based animations.
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

-- Theme Manager
local Theme = {
    Current = {
        Background = Color3.fromRGB(15, 15, 15),
        Surface = Color3.fromRGB(25, 25, 25),
        Border = Color3.fromRGB(40, 40, 40),
        Text = Color3.fromRGB(230, 230, 230),
        TextMuted = Color3.fromRGB(150, 150, 150),
        Accent = Color3.fromRGB(99, 102, 241),
    },
    Themes = {
        Obsidian = {
            Background = Color3.fromRGB(10, 10, 10),
            Surface = Color3.fromRGB(20, 20, 20),
            Border = Color3.fromRGB(35, 35, 35),
            Text = Color3.fromRGB(240, 240, 240),
            Accent = Color3.fromRGB(99, 102, 241),
        }
    },
    Changed = Signal.new()
}
function Theme:SetTheme(name)
    local data = self.Themes[name]
    if data then for k, v in pairs(data) do self.Current[k] = v end self.Changed:Fire(self.Current) end
end

-- [[ UTILITIES ]]

local function CreateShadow(parent, radius)
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Image = "rbxassetid://6015897843"
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.BackgroundTransparency = 1
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.35
    Shadow.Size = UDim2.new(1, 18, 1, 18)
    Shadow.Position = UDim2.fromOffset(-9, -9)
    Shadow.ZIndex = parent.ZIndex - 1
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, radius)
    Corner.Parent = Shadow
    
    Shadow.Parent = parent
    return Shadow
end

local function CreateAcrylic(parent)
    local Noise = Instance.new("ImageLabel")
    Noise.Name = "Noise"
    Noise.Image = "rbxassetid://9968344105"
    Noise.ImageTransparency = 0.92
    Noise.ScaleType = Enum.ScaleType.Tile
    Noise.TileSize = UDim2.fromOffset(128, 128)
    Noise.BackgroundTransparency = 1
    Noise.Size = UDim2.fromScale(1, 1)
    Noise.ZIndex = 1
    Noise.Parent = parent
    return Noise
end

-- [[ COMPONENTS ]]

-- Button Component
local Button = {}
Button.__index = Button
function Button.new(section, options)
    local self = setmetatable({
        Section = section,
        Name = options.Name or "Button",
        Callback = options.Callback or function() end,
        _maid = Maid.new()
    }, Button)
    
    local Container = Instance.new("TextButton")
    Container.Name = self.Name
    Container.Size = UDim2.new(1, 0, 0, 32)
    Container.BackgroundColor3 = Theme.Current.Background
    Container.BorderSizePixel = 0
    Container.AutoButtonColor = false
    Container.ClipsDescendants = true
    Container.Text = ""
    Container.Parent = self.Section.Instances.Content
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Container
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Current.Border
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = self.Name
    Label.TextColor3 = Theme.Current.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.ZIndex = 2
    Label.Parent = Container
    
    -- Refined Springs
    local hoverSpring = Spring.new(45, 0.75)
    local pressSpring = Spring.new(65, 0.7)
    
    self._maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
        local h = hoverSpring:Update(dt)
        local p = pressSpring:Update(dt)
        
        Stroke.Color = Theme.Current.Border:Lerp(Theme.Current.Accent, h)
        Container.BackgroundColor3 = Theme.Current.Background:Lerp(Theme.Current.Surface, h)
        Container.Position = UDim2.fromOffset(0, -h * 1) -- Suble Hover Lift
        Label.TextSize = 13 - (p * 1)
    end))
    
    Container.MouseEnter:Connect(function() 
        hoverSpring.Position = 0.4 -- Instant feedback
        hoverSpring.Target = 1 
    end)
    Container.MouseLeave:Connect(function() hoverSpring.Target = 0; pressSpring.Target = 0 end)
    Container.MouseButton1Down:Connect(function() pressSpring.Target = 1 end)
    
    Container.MouseButton1Up:Connect(function() 
        pressSpring.Target = 0
        
        -- Refined Ripple Effect
        local mouse = UserInputService:GetMouseLocation()
        local guiInset = GuiService:GetGuiInset()
        local relativeX = mouse.X - Container.AbsolutePosition.X
        local relativeY = mouse.Y - guiInset.Y - Container.AbsolutePosition.Y
        
        local size = math.max(Container.AbsoluteSize.X, Container.AbsoluteSize.Y) * 1.5
        
        local Ripple = Instance.new("Frame", Container)
        Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        Ripple.BackgroundColor3 = Color3.new(1, 1, 1)
        Ripple.Position = UDim2.fromOffset(relativeX, relativeY)
        Ripple.Size = UDim2.fromOffset(0, 0)
        Ripple.ZIndex = 3
        Instance.new("UICorner", Ripple).CornerRadius = UDim.new(1, 0)
        
        TweenService:Create(Ripple, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(size, size), 
            BackgroundTransparency = 1
        }):Play()
        task.delay(0.25, function() Ripple:Destroy() end)
        
        self.Callback() 
    end)
    
    return self
end

-- Toggle Component
local Toggle = {}
Toggle.__index = Toggle
function Toggle.new(section, options)
    local self = setmetatable({
        Section = section,
        Name = options.Name or "Toggle",
        State = options.Default or false,
        Callback = options.Callback or function() end,
        _maid = Maid.new()
    }, Toggle)
    
    local Container = Instance.new("TextButton")
    Container.Name = self.Name
    Container.Size = UDim2.new(1, 0, 0, 32)
    Container.BackgroundTransparency = 1
    Container.Text = ""
    Container.Parent = self.Section.Instances.Content
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = self.Name
    Label.TextColor3 = Theme.Current.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.fromOffset(34, 18)
    Switch.Position = UDim2.new(1, -34, 0.5, 0)
    Switch.AnchorPoint = Vector2.new(0, 0.5)
    Switch.BackgroundColor3 = self.State and Theme.Current.Accent or Theme.Current.Border
    Switch.BorderSizePixel = 0
    Switch.Parent = Container
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(12, 12)
    Knob.Position = self.State and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    Knob.AnchorPoint = Vector2.new(0, 0.5)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Knob.Parent = Switch
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    
    local stateSpring = Spring.new(55, 0.7)
    stateSpring.Position = self.State and 1 or 0
    stateSpring.Target = stateSpring.Position
    
    self._maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
        local s = stateSpring:Update(dt)
        local alpha = math.pow(s, 0.7) -- Sharper color interpolation
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

-- Slider Component
local Slider = {}
Slider.__index = Slider
function Slider.new(section, options)
    local self = setmetatable({
        Section = section,
        Name = options.Name or "Slider",
        Min = options.Min or 0,
        Max = options.Max or 100,
        Value = options.Default or 50,
        Suffix = options.Suffix or "",
        Callback = options.Callback or function() end,
        Dragging = false,
        _maid = Maid.new()
    }, Slider)
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 45)
    Container.BackgroundTransparency = 1
    Container.Parent = self.Section.Instances.Content
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = self.Name
    Label.TextColor3 = Theme.Current.Text
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(1, 0, 0, 20)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(self.Value) .. self.Suffix
    ValueLabel.TextColor3 = Theme.Current.TextMuted
    ValueLabel.Font = Enum.Font.GothamSemibold
    ValueLabel.TextSize = 12
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Container
    
    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(1, 0, 0, 4)
    Track.Position = UDim2.fromOffset(0, 30)
    Track.BackgroundColor3 = Theme.Current.Border
    Track.BorderSizePixel = 0
    Track.Text = ""
    Track.AutoButtonColor = false
    Track.Parent = Container
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.fromScale((self.Value - self.Min) / (self.Max - self.Min), 1)
    Fill.BackgroundColor3 = Theme.Current.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(12, 12)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(Fill.Size.X.Scale, 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Knob.Parent = Track
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    
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

-- [[ MANAGERS ]]

-- Section Manager
local Section = {}
Section.__index = Section
function Section.new(tab, options)
    local self = setmetatable({ Tab = tab, Name = options.Name or "Section" }, Section)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundColor3 = Theme.Current.Surface
    Container.BorderSizePixel = 0
    Container.Parent = self.Tab.Instances.Content
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
    List.Padding = UDim.new(0, 6)
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

-- Tab Manager
local Tab = {}
Tab.__index = Tab
function Tab.new(window, options)
    local self = setmetatable({ Window = window, Name = options.Name or "Tab", Active = false }, Tab)
    local Button = Instance.new("TextButton", self.Window.Instances.TabContainer)
    Button.Size = UDim2.new(1, 0, 0, 32)
    Button.BackgroundTransparency = 1
    Button.Text = "  " .. self.Name
    Button.TextColor3 = Theme.Current.TextMuted
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 13
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    
    local Content = Instance.new("ScrollingFrame", self.Window.Instances.Main)
    Content.Size = UDim2.new(1, -220, 1, -20)
    Content.Position = UDim2.fromOffset(210, 10)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.Visible = false
    Content.ScrollBarThickness = 0
    Instance.new("UIListLayout", Content).Padding = UDim.new(0, 10)
    
    self.Instances = { Button = Button, Content = Content }
    Button.MouseButton1Click:Connect(function() self:Select() end)
    return self
end
function Tab:Select()
    if self.Window.CurrentTab then self.Window.CurrentTab:Deselect() end
    self.Active = true
    self.Window.CurrentTab = self
    self.Instances.Content.Visible = true
    TweenService:Create(self.Instances.Button, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundTransparency = 0, BackgroundColor3 = Theme.Current.Accent, TextColor3 = Color3.new(1, 1, 1)}):Play()
end
function Tab:Deselect()
    self.Active = false
    self.Instances.Content.Visible = false
    TweenService:Create(self.Instances.Button, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundTransparency = 1, TextColor3 = Theme.Current.TextMuted}):Play()
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
    ScreenGui.Name = "PhantomUI_Premium"
    
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.fromOffset(0, 0)
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Theme.Current.Background
    Main.BackgroundTransparency = 0.15
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = false
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    CreateShadow(Main, 12)
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
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = self.Size}):Play()
    
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
    Toast.Size = UDim2.new(1, 0, 0, 60)
    Toast.BackgroundColor3 = Theme.Current.Background
    Toast.BackgroundTransparency = 0.1
    Instance.new("UICorner", Toast).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Toast).Color = Theme.Current.Border
    
    local T = Instance.new("TextLabel", Toast)
    T.Size = UDim2.new(1, -20, 0, 25)
    T.Position = UDim2.fromOffset(10, 5)
    T.BackgroundTransparency = 1
    T.Text = Title
    T.TextColor3 = Theme.Current.Accent
    T.Font = Enum.Font.GothamBold
    T.TextSize = 13
    T.TextXAlignment = Enum.TextXAlignment.Left
    
    local C = Instance.new("TextLabel", Toast)
    C.Size = UDim2.new(1, -20, 0, 20)
    C.Position = UDim2.fromOffset(10, 30)
    C.BackgroundTransparency = 1
    C.Text = Content
    C.TextColor3 = Theme.Current.Text
    C.Font = Enum.Font.Gotham
    C.TextSize = 12
    C.TextXAlignment = Enum.TextXAlignment.Left
    
    Toast.Position = UDim2.new(1, 0, 0, 0)
    TweenService:Create(Toast, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    task.delay(Duration, function()
        TweenService:Create(Toast, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 320, 0, 0)}):Play()
        task.wait(0.5)
        Toast:Destroy()
    end)
end

function Library:Destroy()
    for _, window in ipairs(self.Windows) do window._maid:Destroy() end
    self.Windows = {}
    if self._maid then self._maid:Destroy() end
end

return Library

