-- PhantomUI.lua
-- Professional Roblox UI Framework
-- Bundled for single-file distribution

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    Version = "1.0.0",
    Windows = {},
}

-- [[ CORE SYSTEMS ]]

-- Maid: Handles cleanup of tasks, connections, and instances.
local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({ _tasks = {} }, Maid)
end

function Maid:GiveTask(task)
    if not task then return end
    table.insert(self._tasks, task)
    return task
end

function Maid:DoCleaning()
    for _, task in ipairs(self._tasks) do
        if typeof(task) == "function" then
            task()
        elseif typeof(task) == "RBXScriptConnection" then
            task:Disconnect()
        elseif typeof(task) == "Instance" then
            task:Destroy()
        elseif task.Destroy then
            task:Destroy()
        elseif task.DoCleaning then
            task:DoCleaning()
        end
    end
    self._tasks = {}
end

function Maid:Destroy()
    self:DoCleaning()
end

-- Signals: Custom event system for internal events.
local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ _listeners = {} }, Signal)
end

function Signal:Connect(callback)
    local connection = {
        _callback = callback,
        _connected = true,
        Disconnect = function(self)
            self._connected = false
        end
    }
    table.insert(self._listeners, connection)
    return connection
end

function Signal:Fire(...)
    for i = #self._listeners, 1, -1 do
        local listener = self._listeners[i]
        if listener._connected then
            task.spawn(listener._callback, ...)
        else
            table.remove(self._listeners, i)
        end
    end
end

-- Theme: Manages colors and styles across the library.
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
        },
        Light = {
            Background = Color3.fromRGB(245, 245, 245),
            Surface = Color3.fromRGB(255, 255, 255),
            Border = Color3.fromRGB(220, 220, 220),
            Text = Color3.fromRGB(30, 30, 30),
            Accent = Color3.fromRGB(79, 70, 229),
        }
    },
    Changed = Signal.new()
}

function Theme:SetTheme(name)
    local themeData = self.Themes[name]
    if themeData then
        for k, v in pairs(themeData) do
            self.Current[k] = v
        end
        self.Changed:Fire(self.Current)
    end
end

function Theme:SetAccent(color)
    self.Current.Accent = color
    self.Changed:Fire(self.Current)
end

-- Animator: Centralized animation handler.
local Animator = {}
Animator.DefaultInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function Animator:Tween(object, goal, info)
    if not object then return end
    local tween = TweenService:Create(object, info or self.DefaultInfo, goal)
    tween:Play()
    return tween
end

-- [[ COMPONENTS ]]

-- Button Component
local Button = {}
Button.__index = Button

function Button.new(section, options)
    local self = setmetatable({
        Section = section,
        Name = options.Name or "Button",
        Callback = options.Callback or function() end
    }, Button)
    
    local Container = Instance.new("TextButton")
    Container.Name = self.Name
    Container.Size = UDim2.new(1, 0, 0, 32)
    Container.BackgroundColor3 = Theme.Current.Background
    Container.BorderSizePixel = 0
    Container.AutoButtonColor = false
    Container.Text = ""
    Container.Parent = self.Section.Instances.Content
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
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
    Label.Parent = Container
    
    Container.MouseEnter:Connect(function()
        Animator:Tween(Stroke, {Color = Theme.Current.Accent}, TweenInfo.new(0.2))
        Animator:Tween(Container, {BackgroundColor3 = Theme.Current.Border}, TweenInfo.new(0.2))
    end)
    
    Container.MouseLeave:Connect(function()
        Animator:Tween(Stroke, {Color = Theme.Current.Border}, TweenInfo.new(0.2))
        Animator:Tween(Container, {BackgroundColor3 = Theme.Current.Background}, TweenInfo.new(0.2))
    end)
    
    Container.MouseButton1Down:Connect(function()
        Animator:Tween(Label, {TextSize = 12}, TweenInfo.new(0.1))
    end)
    
    Container.MouseButton1Up:Connect(function()
        Animator:Tween(Label, {TextSize = 13}, TweenInfo.new(0.1))
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
        Callback = options.Callback or function() end
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
    Switch.Name = "Switch"
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
    Knob.Name = "Knob"
    Knob.Size = UDim2.fromOffset(12, 12)
    Knob.Position = self.State and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    Knob.AnchorPoint = Vector2.new(0, 0.5)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Knob.BorderSizePixel = 0
    Knob.Parent = Switch
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    
    self.Instances = { Switch = Switch, Knob = Knob }
    
    Container.MouseButton1Click:Connect(function()
        self:Set(not self.State)
    end)
    
    return self
end

function Toggle:Set(state)
    self.State = state
    Animator:Tween(self.Instances.Switch, {
        BackgroundColor3 = self.State and Theme.Current.Accent or Theme.Current.Border
    }, TweenInfo.new(0.2))
    Animator:Tween(self.Instances.Knob, {
        Position = self.State and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    }, TweenInfo.new(0.2))
    self.Callback(self.State)
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
        Dragging = false
    }, Slider)
    
    local Container = Instance.new("Frame")
    Container.Name = self.Name
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
    Track.Name = "Track"
    Track.Size = UDim2.new(1, 0, 0, 4)
    Track.Position = UDim2.fromOffset(0, 30)
    Track.BackgroundColor3 = Theme.Current.Border
    Track.BorderSizePixel = 0
    Track.Text = ""
    Track.AutoButtonColor = false
    Track.Parent = Container
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track
    
    local Fill = Instance.new("Frame")
    Fill.Name = "Fill"
    Fill.Size = UDim2.fromScale((self.Value - self.Min) / (self.Max - self.Min), 1)
    Fill.BackgroundColor3 = Theme.Current.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        self.Value = math.floor(self.Min + (self.Max - self.Min) * pos)
        ValueLabel.Text = tostring(self.Value) .. self.Suffix
        Animator:Tween(Fill, {Size = UDim2.fromScale(pos, 1)}, TweenInfo.new(0.1))
        self.Callback(self.Value)
    end
    
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = true
            Update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input)
        end
    end)
    
    return self
end

-- [[ MANAGERS ]]

-- Section Manager
local Section = {}
Section.__index = Section

function Section.new(tab, options)
    local self = setmetatable({
        Tab = tab,
        Name = options.Name or "Section",
    }, Section)
    
    local Container = Instance.new("Frame")
    Container.Name = self.Name
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.BackgroundColor3 = Theme.Current.Surface
    Container.BorderSizePixel = 0
    Container.Parent = self.Tab.Instances.Content
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Container
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Current.Border
    Stroke.Thickness = 1
    Stroke.Parent = Container
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 0, 30)
    Title.Position = UDim2.fromOffset(10, 5)
    Title.BackgroundTransparency = 1
    Title.Text = self.Name:upper()
    Title.TextColor3 = Theme.Current.Accent
    Title.TextSize = 11
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Container
    
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -20, 0, 0)
    Content.Position = UDim2.fromOffset(10, 35)
    Content.BackgroundTransparency = 1
    Content.Parent = Container
    
    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 6)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Parent = Content
    
    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.Size = UDim2.new(1, -20, 0, List.AbsoluteContentSize.Y)
        Container.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 45)
    end)
    
    self.Instances = { Container = Container, Content = Content }
    return self
end

function Section:CreateToggle(options) return Toggle.new(self, options) end
function Section:CreateButton(options) return Button.new(self, options) end
function Section:CreateSlider(options) return Slider.new(self, options) end

-- Tab Manager
local Tab = {}
Tab.__index = Tab

function Tab.new(window, options)
    local self = setmetatable({
        Window = window,
        Name = options.Name or "Tab",
        Active = false
    }, Tab)
    
    local Button = Instance.new("TextButton")
    Button.Name = self.Name
    Button.Size = UDim2.new(1, 0, 0, 32)
    Button.BackgroundTransparency = 1
    Button.Text = "  " .. self.Name
    Button.TextColor3 = Theme.Current.TextMuted
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 13
    Button.Parent = self.Window.Instances.TabContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    
    local Content = Instance.new("ScrollingFrame")
    Content.Name = self.Name .. "_Content"
    Content.Size = UDim2.new(1, -220, 1, -20)
    Content.Position = UDim2.fromOffset(210, 10)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.Visible = false
    Content.ScrollBarThickness = 2
    Content.ScrollBarImageColor3 = Theme.Current.Border
    Content.Parent = self.Window.Instances.Main
    
    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 10)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Parent = Content
    
    self.Instances = { Button = Button, Content = Content }
    
    Button.MouseButton1Click:Connect(function() self:Select() end)
    
    Button.MouseEnter:Connect(function()
        if not self.Active then
            Animator:Tween(Button, {BackgroundTransparency = 0.9, BackgroundColor3 = Theme.Current.Text}, TweenInfo.new(0.2))
        end
    end)
    
    Button.MouseLeave:Connect(function()
        if not self.Active then
            Animator:Tween(Button, {BackgroundTransparency = 1}, TweenInfo.new(0.2))
        end
    end)
    
    return self
end

function Tab:Select()
    if self.Window.CurrentTab then self.Window.CurrentTab:Deselect() end
    self.Active = true
    self.Window.CurrentTab = self
    self.Instances.Content.Visible = true
    Animator:Tween(self.Instances.Button, {
        BackgroundTransparency = 0,
        BackgroundColor3 = Theme.Current.Accent,
        TextColor3 = Color3.new(1, 1, 1)
    }, TweenInfo.new(0.2))
end

function Tab:Deselect()
    self.Active = false
    self.Instances.Content.Visible = false
    Animator:Tween(self.Instances.Button, {
        BackgroundTransparency = 1,
        TextColor3 = Theme.Current.TextMuted
    }, TweenInfo.new(0.2))
end

function Tab:CreateSection(options) return Section.new(self, options) end

-- Window Manager
local Window = {}
Window.__index = Window

function Window.new(options)
    local self = setmetatable({
        Title = options.Title or "Window",
        Size = options.Size or UDim2.fromOffset(760, 520),
        CurrentTab = nil,
        _maid = Maid.new()
    }, Window)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PhantomUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = self.Size
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Theme.Current.Background
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Main
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Current.Border
    Stroke.Thickness = 1
    Stroke.Parent = Main
    
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Current.Surface
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 8)
    SidebarCorner.Parent = Sidebar
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -20, 1, -60)
    TabContainer.Position = UDim2.fromOffset(10, 50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 4)
    TabList.Parent = TabContainer
    
    self.Instances = { ScreenGui = ScreenGui, Main = Main, TabContainer = TabContainer }
    self._maid:GiveTask(ScreenGui)
    
    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
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
    print("Notification:", options.Title, options.Content)
end

function Library:SetTheme(name) Theme:SetTheme(name) end
function Library:SetAccent(color) Theme:SetAccent(color) end

function Library:Destroy()
    for _, window in ipairs(self.Windows) do
        window._maid:Destroy()
    end
    self.Windows = {}
end

return Library
