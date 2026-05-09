--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Theme = require(script.Parent.Theme)

local UI = {}

function UI:CreateWindow(title: string, sizeX: number, sizeY: number)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ManusUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = UDim2.new(0, sizeX, 0, sizeY)
    MainWindow.Position = UDim2.new(0.5, -sizeX/2, 0.5, -sizeY/2) -- Center the window
    MainWindow.BackgroundColor3 = Theme.Theme.Background
    MainWindow.BorderSizePixel = 0
    MainWindow.ClipsDescendants = true


    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, Theme.Radius.Medium)
    UICorner.Parent = MainWindow

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Theme.Theme.Border
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.75
    UIStroke.ApplyStrokeMode = Enum.UIStrokeApplyMode.Border
    UIStroke.Parent = MainWindow

    -- Add a subtle noise overlay (Background Texture)
    local NoiseOverlay = Instance.new("ImageLabel")
    NoiseOverlay.Name = "NoiseOverlay"
    NoiseOverlay.Image = "rbxassetid://13341766699" -- Example noise texture asset ID
    NoiseOverlay.BackgroundTransparency = 1
    NoiseOverlay.ImageColor3 = Color3.new(1, 1, 1)
    NoiseOverlay.ImageTransparency = 0.97 -- As per design doc
    NoiseOverlay.ScaleType = Enum.ScaleType.Tile
    NoiseOverlay.TileSize = UDim2.new(0, 100, 0, 100)
    NoiseOverlay.Size = UDim2.new(1, 0, 1, 0)
    NoiseOverlay.ZIndex = 0
    NoiseOverlay.Parent = MainWindow

    -- Draggable functionality (simplified for now)
    local dragging = false
    local dragInput: InputObject
    local dragStart: Vector2
    local startPosition: UDim2

    MainWindow.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPosition = MainWindow.Position
        end
    end)

    MainWindow.InputEnded:Connect(function(input)
        if input == dragInput then
            dragging = false
            dragInput = nil
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainWindow.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, 0) -- 170-190px width
    Sidebar.Position = UDim2.new(0, 0, 0, 0)
    Sidebar.BackgroundColor3 = Theme.Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainWindow

    local SidebarStroke = Instance.new("UIStroke")
    SidebarStroke.Color = Theme.Theme.Border
    SidebarStroke.Thickness = 1
    SidebarStroke.Transparency = 0.75
    SidebarStroke.ApplyStrokeMode = Enum.UIStrokeApplyMode.Border
    SidebarStroke.Parent = Sidebar

    -- MainArea
    local MainArea = Instance.new("Frame")
    MainArea.Name = "MainArea"
    MainArea.Size = UDim2.new(1, -Sidebar.Size.X.Offset, 1, 0)
    MainArea.Position = UDim2.new(0, Sidebar.Size.X.Offset, 0, 0)
    MainArea.BackgroundColor3 = Theme.Theme.Background
    MainArea.BorderSizePixel = 0
    MainArea.Parent = MainWindow

    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 46) -- 44-50px height
    Topbar.Position = UDim2.new(0, 0, 0, 0)
    Topbar.BackgroundColor3 = Theme.Theme.Surface
    Topbar.BorderSizePixel = 0
    Topbar.Parent = MainArea

    local TopbarStroke = Instance.new("UIStroke")
    TopbarStroke.Color = Theme.Theme.Border
    TopbarStroke.Thickness = 1
    TopbarStroke.Transparency = 0.75
    TopbarStroke.ApplyStrokeMode = Enum.UIStrokeApplyMode.Border
    TopbarStroke.Parent = Topbar

    local CurrentTabLabel = Instance.new("TextLabel")
    CurrentTabLabel.Name = "CurrentTabLabel"
    CurrentTabLabel.Size = UDim2.new(1, -100, 1, 0)
    CurrentTabLabel.Position = UDim2.new(0, 10, 0, 0)
    CurrentTabLabel.BackgroundColor3 = Theme.Theme.Surface
    CurrentTabLabel.BackgroundTransparency = 1
    CurrentTabLabel.Font = Enum.Font.Gotham
    CurrentTabLabel.TextSize = 16
    CurrentTabLabel.TextColor3 = Theme.Theme.Text
    CurrentTabLabel.TextXAlignment = Enum.TextXAlignment.Left
    CurrentTabLabel.Text = title -- Initial tab title
    CurrentTabLabel.Parent = Topbar

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
    MinimizeButton.Position = UDim2.new(1, -45, 0.5, -10)
    MinimizeButton.BackgroundColor3 = Theme.Theme.Surface
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = "_"
    MinimizeButton.Font = Enum.Font.Gotham
    MinimizeButton.TextSize = 18
    MinimizeButton.TextColor3 = Theme.Theme.Text
    MinimizeButton.Parent = Topbar

    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, Theme.Radius.Small)
    MinimizeCorner.Parent = MinimizeButton

    local MaximizeButton = Instance.new("TextButton")
    MaximizeButton.Name = "MaximizeButton"
    MaximizeButton.Size = UDim2.new(0, 20, 0, 20)
    MaximizeButton.Position = UDim2.new(1, -25, 0.5, -10)
    MaximizeButton.BackgroundColor3 = Theme.Theme.Surface
    MaximizeButton.BorderSizePixel = 0
    MaximizeButton.Text = "[]"
    MaximizeButton.Font = Enum.Font.Gotham
    MaximizeButton.TextSize = 14
    MaximizeButton.TextColor3 = Theme.Theme.Text
    MaximizeButton.Parent = Topbar

    local MaximizeCorner = Instance.new("UICorner")
    MaximizeCorner.CornerRadius = UDim.new(0, Theme.Radius.Small)
    MaximizeCorner.Parent = MaximizeButton

    local isMinimized = false
    local originalSize = MainWindow.Size
    local originalPosition = MainWindow.Position

    MinimizeButton.MouseButton1Click:Connect(function()
        if not isMinimized then
            TweenService:Create(MainWindow, Theme.Animations.Medium, {Size = UDim2.new(0, originalSize.X.Offset, 0, Topbar.Size.Y.Offset), Position = UDim2.new(originalPosition.X.Scale, originalPosition.X.Offset, 1, -Topbar.Size.Y.Offset)}):Play()
            isMinimized = true
        else
            TweenService:Create(MainWindow, Theme.Animations.Medium, {Size = originalSize, Position = originalPosition}):Play()
            isMinimized = false
        end
    end)

    MaximizeButton.MouseButton1Click:Connect(function()
        if isMinimized then
            TweenService:Create(MainWindow, Theme.Animations.Medium, {Size = originalSize, Position = originalPosition}):Play()
            isMinimized = false
        end
    end)

    local SearchBar = Instance.new("TextBox")
    SearchBar.Name = "SearchBar"
    SearchBar.Size = UDim2.new(0, 150, 0, 28)
    SearchBar.Position = UDim2.new(1, -160, 0.5, -14)
    SearchBar.BackgroundColor3 = Theme.Theme.Surface
    SearchBar.BackgroundTransparency = 0.15
    SearchBar.BorderSizePixel = 0
    SearchBar.Font = Enum.Font.Gotham
    SearchBar.TextSize = 13
    SearchBar.TextColor3 = Theme.Theme.Text
    SearchBar.PlaceholderText = "Search (Ctrl+K)"
    SearchBar.PlaceholderColor3 = Theme.Theme.Subtext
    SearchBar.TextXAlignment = Enum.TextXAlignment.Left
    SearchBar.TextYAlignment = Enum.TextYAlignment.Center
    SearchBar.ClearTextOnFocus = false
    SearchBar.Parent = Topbar

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, Theme.Radius.Small)
    SearchCorner.Parent = SearchBar

    local SearchStroke = Instance.new("UIStroke")
    SearchStroke.Color = Theme.Theme.Border
    SearchStroke.Thickness = 1
    SearchStroke.Transparency = 0.75
    SearchStroke.ApplyStrokeMode = Enum.UIStrokeApplyMode.Border
    SearchStroke.Parent = SearchBar

    SearchBar.Focused:Connect(function()
        TweenService:Create(SearchStroke, Theme.Animations.Fast, {Transparency = 0.5}):Play()
    end)

    SearchBar.FocusLost:Connect(function()
        TweenService:Create(SearchStroke, Theme.Animations.Fast, {Transparency = 0.75}):Play()
    end)

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Name = "SearchIcon"
    SearchIcon.Size = UDim2.new(0, 16, 0, 16)
    SearchIcon.Position = UDim2.new(0, 5, 0.5, -8)
    SearchIcon.Image = "rbxassetid://6032094984" -- Placeholder search icon asset ID
    SearchIcon.ImageColor3 = Theme.Theme.Subtext
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Parent = SearchBar

    -- Content Area (now a ScrollingFrame)
    local ContentAreaScroll = Instance.new("ScrollingFrame")
    ContentAreaScroll.Name = "ContentArea"
    ContentAreaScroll.Size = UDim2.new(1, 0, 1, -Topbar.Size.Y.Offset)
    ContentAreaScroll.Position = UDim2.new(0, 0, 0, Topbar.Size.Y.Offset)
    ContentAreaScroll.BackgroundColor3 = Theme.Theme.Background
    ContentAreaScroll.BackgroundTransparency = 1
    ContentAreaScroll.BorderSizePixel = 0
    ContentAreaScroll.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
    ContentAreaScroll.ScrollBarThickness = 6
    ContentAreaScroll.ScrollBarImageColor3 = Theme.Theme.Subtext
    ContentAreaScroll.ScrollBarImageTransparency = 0.7
    ContentAreaScroll.Parent = MainArea

    local ResizeCorner = Instance.new("ImageLabel")
    ResizeCorner.Name = "ResizeCorner"
    ResizeCorner.Size = UDim2.new(0, 20, 0, 20)
    ResizeCorner.Position = UDim2.new(1, -20, 1, -20)
    ResizeCorner.Image = "rbxassetid://6032094984" -- Placeholder resize icon
    ResizeCorner.ImageColor3 = Theme.Theme.Subtext
    ResizeCorner.BackgroundTransparency = 1
    ResizeCorner.ZIndex = 10
    ResizeCorner.Parent = MainWindow

    local resizing = false
    local resizeInput: InputObject
    local resizeStart: Vector2
    local startSize: UDim2

    ResizeCorner.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeInput = input
            resizeStart = input.Position
            startSize = MainWindow.Size
        end
    end)

    ResizeCorner.InputEnded:Connect(function(input)
        if input == resizeInput then
            resizing = false
            resizeInput = nil
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == resizeInput and resizing then
            local delta = input.Position - resizeStart
            MainWindow.Size = UDim2.new(
                startSize.X.Scale, startSize.X.Offset + delta.X,
                startSize.Y.Scale, startSize.Y.Offset + delta.Y
            )
        end
    end)

    return {
        ScreenGui = ScreenGui,
        MainWindow = MainWindow,
        Sidebar = Sidebar,
        MainArea = MainArea,
        Topbar = Topbar,
        ContentArea = ContentAreaScroll, -- Return the ScrollingFrame as ContentArea
        SearchBar = SearchBar,
        ResizeCorner = ResizeCorner,
        SetCurrentTab = function(tabName: string)
            CurrentTabLabel.Text = tabName
        end
    }
end

return UI
