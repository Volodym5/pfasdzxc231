local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Colors (using Color3.fromRGB as discussed)
local Colors = {
    Background = Color3.fromRGB(25, 25, 30),
    WindowBackground = Color3.fromRGB(35, 35, 40),
    TabBar = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(100, 150, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 190),
    TabActive = Color3.fromRGB(45, 45, 50),
    TabInactive = Color3.fromRGB(30, 30, 35),
    Border = Color3.fromRGB(50, 50, 55),
    ContentBackground = Color3.fromRGB(40, 40, 45),
}

-- Hex to Color3 converter (for convenience)
local function hexToColor3(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber("0x"..hex:sub(1,2)),
        tonumber("0x"..hex:sub(3,4)),
        tonumber("0x"..hex:sub(5,6))
    )
end

-- Create rounded corners using UICorner
local function applyRoundedCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
    return corner
end

-- Create a gradient for depth
local function applyGradient(instance, color1, color2)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1 or Colors.Background),
        ColorSequenceKeypoint.new(1, color2 or Colors.WindowBackground)
    })
    gradient.Rotation = 135
    gradient.Parent = instance
    return gradient
end

-- Create a drop shadow
local function applyShadow(instance)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://6014261993" -- Standard Roblox shadow asset
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 49, 49)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = 0
    shadow.BackgroundTransparency = 1
    shadow.Parent = instance
    return shadow
end

-- Create the main window
function Library.CreateWindow(config)
    local self = setmetatable({}, Library)
    
    config = config or {}
    self.Title = config.Title or "UI Library"
    self.AccentColor = config.AccentColor or Colors.Accent
    
    -- Create the ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = config.Name or "UILibrary"
    self.ScreenGui.Parent = config.Parent or CoreGui
    self.ScreenGui.ResetOnSpawn = false
    
    -- Create the main container
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 550, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    self.MainFrame.BackgroundColor3 = Colors.WindowBackground
    self.MainFrame.BackgroundTransparency = 0
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.ZIndex = 1
    
    applyRoundedCorners(self.MainFrame, 10)
    applyShadow(self.MainFrame)
    
    -- Make the window draggable
    self.IsDragging = false
    self.DragStart = nil
    self.StartPos = nil
    
    -- Create the title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.Position = UDim2.new(0, 0, 0, 0)
    self.TitleBar.BackgroundColor3 = Colors.TabBar
    self.TitleBar.BackgroundTransparency = 0
    self.TitleBar.Parent = self.MainFrame
    self.TitleBar.ZIndex = 2
    
    applyRoundedCorners(self.TitleBar, 10)
    
    -- Title text
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Colors.Text
    self.TitleLabel.TextSize = 18
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TitleBar
    self.TitleLabel.ZIndex = 3
    
    -- Create the tab bar (below title bar)
    self.TabBar = Instance.new("Frame")
    self.TabBar.Name = "TabBar"
    self.TabBar.Size = UDim2.new(0, 120, 1, -40)
    self.TabBar.Position = UDim2.new(0, 0, 0, 40)
    self.TabBar.BackgroundColor3 = Colors.TabBar
    self.TabBar.BackgroundTransparency = 0
    self.TabBar.Parent = self.MainFrame
    self.TabBar.ZIndex = 2
    
    -- Create the tab buttons container
    self.TabButtons = Instance.new("ScrollingFrame")
    self.TabButtons.Name = "TabButtons"
    self.TabButtons.Size = UDim2.new(1, -10, 1, -10)
    self.TabButtons.Position = UDim2.new(0, 5, 0, 5)
    self.TabButtons.BackgroundTransparency = 1
    self.TabButtons.ScrollBarThickness = 0
    self.TabButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.TabButtons.Parent = self.TabBar
    self.TabButtons.ZIndex = 3
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.Parent = self.TabButtons
    
    -- Create the content area
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.Size = UDim2.new(1, -130, 1, -50)
    self.ContentArea.Position = UDim2.new(0, 125, 0, 45)
    self.ContentArea.BackgroundColor3 = Colors.ContentBackground
    self.ContentArea.BackgroundTransparency = 0
    self.ContentArea.Parent = self.MainFrame
    self.ContentArea.ZIndex = 2
    
    applyRoundedCorners(self.ContentArea, 8)
    
    -- Create pages container (holds content for each tab)
    self.Pages = Instance.new("Folder")
    self.Pages.Name = "Pages"
    self.Pages.Parent = self.ContentArea
    
    -- Dragging functionality
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = true
            self.DragStart = input.Position
            self.StartPos = self.MainFrame.Position
        end
    end)
    
    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and self.IsDragging then
            local delta = input.Position - self.DragStart
            self.MainFrame.Position = UDim2.new(
                self.StartPos.X.Scale, 
                self.StartPos.X.Offset + delta.X, 
                self.StartPos.Y.Scale, 
                self.StartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = false
        end
    end)
    
    -- Store tabs table
    self.Tabs = {}
    
    return self
end

-- Create a new tab
function Library:CreateTab(name, icon)
    local tab = {
        Name = name,
        Icon = icon,
        Active = false
    }
    
    -- Create the tab button
    tab.Button = Instance.new("TextButton")
    tab.Button.Name = name
    tab.Button.Size = UDim2.new(1, 0, 0, 35)
    tab.Button.BackgroundColor3 = Colors.TabInactive
    tab.Button.Text = (icon and icon.."  " or "")..name
    tab.Button.TextColor3 = Colors.TextSecondary
    tab.Button.TextSize = 14
    tab.Button.Font = Enum.Font.GothamSemibold
    tab.Button.TextXAlignment = Enum.TextXAlignment.Left
    tab.Button.TextTruncate = Enum.TextTruncate.AtEnd
    tab.Button.Parent = self.TabButtons
    tab.Button.ZIndex = 3
    tab.Button.LayoutOrder = #self.Tabs + 1
    
    applyRoundedCorners(tab.Button, 6)
    
    -- Create the content page
    tab.Page = Instance.new("ScrollingFrame")
    tab.Page.Name = name.."_Page"
    tab.Page.Size = UDim2.new(1, -20, 1, -20)
    tab.Page.Position = UDim2.new(0, 10, 0, 10)
    tab.Page.BackgroundTransparency = 1
    tab.Page.ScrollBarThickness = 4
    tab.Page.ScrollBarImageColor3 = Colors.Accent
    tab.Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.Page.Visible = false
    tab.Page.Parent = self.Pages
    tab.Page.ZIndex = 3
    
    local pageListLayout = Instance.new("UIListLayout")
    pageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageListLayout.Padding = UDim.new(0, 10)
    pageListLayout.Parent = tab.Page
    
    -- Update canvas size when content changes
    pageListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.Page.CanvasSize = UDim2.new(0, 0, 0, pageListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Tab click handler
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Select first tab automatically
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    -- Update canvas size
    self.TabButtons.CanvasSize = UDim2.new(0, 0, 0, #self.Tabs * 40)
    
    return tab
end

-- Select a tab
function Library:SelectTab(tab)
    for _, t in ipairs(self.Tabs) do
        if t == tab then
            t.Active = true
            t.Button.BackgroundColor3 = Colors.TabActive
            t.Button.TextColor3 = Colors.Text
            
            -- Animate accent bar
            if not t.Button:FindFirstChild("AccentBar") then
                local accentBar = Instance.new("Frame")
                accentBar.Name = "AccentBar"
                accentBar.Size = UDim2.new(0, 3, 0.6, 0)
                accentBar.Position = UDim2.new(0, 0, 0.2, 0)
                accentBar.BackgroundColor3 = self.AccentColor
                accentBar.Parent = t.Button
                applyRoundedCorners(accentBar, 2)
            end
            
            t.Page.Visible = true
        else
            t.Active = false
            t.Button.BackgroundColor3 = Colors.TabInactive
            t.Button.TextColor3 = Colors.TextSecondary
            
            if t.Button:FindFirstChild("AccentBar") then
                t.Button.AccentBar:Destroy()
            end
            
            t.Page.Visible = false
        end
    end
end

-- Set accent color
function Library:SetAccent(color)
    if type(color) == "string" then
        color = hexToColor3(color)
    end
    self.AccentColor = color
end

return Library