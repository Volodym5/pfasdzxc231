--[[
    ██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗    ██╗   ██╗██╗
    ██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║    ██║   ██║██║
    ██████╔╝███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║    ██║   ██║██║
    ██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║    ██║   ██║██║
    ██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║    ╚██████╔╝██║
    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝  ╚═╝    ╚═════╝ ╚═╝     ╚═╝     ╚═════╝ ╚═╝

    PhantomUI — A Luxury Roblox UI Library
    Version: 1.0.0
    Author: PhantomUI
    
    "Inspired by perfection. Built for those who demand more."

    USAGE EXAMPLE:
    --------------
    local Phantom = loadstring(game:HttpGet("..."))()
    
    local Window = Phantom:CreateWindow({
        Title = "My Script",
        Subtitle = "v1.0",
        Theme = "Obsidian" -- "Obsidian", "Ivory", "Crimson"
    })
    
    local Tab = Window:AddTab("Main", "rbxassetid://...")
    
    Tab:AddButton({ Label = "Execute", Callback = function() end })
    Tab:AddToggle({ Label = "Auto Farm", Default = false, Callback = function(v) end })
    Tab:AddSlider({ Label = "Speed", Min = 0, Max = 100, Default = 16, Callback = function(v) end })
    Tab:AddDropdown({ Label = "Mode", Options = {"Fast", "Slow"}, Callback = function(v) end })
    Tab:AddTextbox({ Label = "Player", Default = "", Callback = function(v) end })
    Tab:AddLabel("Welcome to PhantomUI")
    Tab:AddSeparator()
    Tab:AddColorPicker({ Label = "Trail Color", Default = Color3.fromRGB(200,160,80), Callback = function(v) end })
    Tab:AddKeybind({ Label = "Toggle GUI", Default = Enum.KeyCode.RightShift, Callback = function() end })
    
    Phantom:Notify({
        Title = "Loaded",
        Message = "PhantomUI initialized successfully.",
        Duration = 4,
        Type = "Success"  -- "Success", "Error", "Warning", "Info"
    })
]]

local PhantomUI = {}
PhantomUI.__index = PhantomUI

-- ============================================================
-- SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local TextService      = game:GetService("TextService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ============================================================
-- THEME DEFINITIONS
-- ============================================================
local Themes = {
    Obsidian = {
        -- Base surfaces
        Background        = Color3.fromRGB(10,  10,  12),
        Surface           = Color3.fromRGB(16,  16,  20),
        SurfaceElevated   = Color3.fromRGB(22,  22,  28),
        SurfaceRaised     = Color3.fromRGB(28,  28,  36),
        -- Accents
        Accent            = Color3.fromRGB(200, 160, 70),
        AccentDim         = Color3.fromRGB(140, 110, 50),
        AccentGlow        = Color3.fromRGB(220, 180, 90),
        -- Text
        TextPrimary       = Color3.fromRGB(240, 235, 220),
        TextSecondary     = Color3.fromRGB(160, 155, 140),
        TextMuted         = Color3.fromRGB(80,  78,  70),
        -- State
        Success           = Color3.fromRGB(80,  200, 120),
        Error             = Color3.fromRGB(220, 70,  70),
        Warning           = Color3.fromRGB(220, 170, 50),
        Info              = Color3.fromRGB(70,  140, 220),
        -- Interactive
        ButtonHover       = Color3.fromRGB(32,  32,  40),
        ToggleOff         = Color3.fromRGB(40,  40,  50),
        Scrollbar         = Color3.fromRGB(50,  48,  42),
        -- Border
        Border            = Color3.fromRGB(40,  38,  30),
        BorderAccent      = Color3.fromRGB(100, 80,  35),
    },
    Ivory = {
        Background        = Color3.fromRGB(245, 242, 235),
        Surface           = Color3.fromRGB(255, 253, 248),
        SurfaceElevated   = Color3.fromRGB(250, 247, 240),
        SurfaceRaised     = Color3.fromRGB(240, 236, 226),
        Accent            = Color3.fromRGB(140, 100, 40),
        AccentDim         = Color3.fromRGB(100, 75,  30),
        AccentGlow        = Color3.fromRGB(170, 130, 60),
        TextPrimary       = Color3.fromRGB(30,  25,  15),
        TextSecondary     = Color3.fromRGB(100, 90,  70),
        TextMuted         = Color3.fromRGB(170, 160, 140),
        Success           = Color3.fromRGB(50,  160, 90),
        Error             = Color3.fromRGB(190, 50,  50),
        Warning           = Color3.fromRGB(190, 140, 30),
        Info              = Color3.fromRGB(50,  110, 190),
        ButtonHover       = Color3.fromRGB(235, 230, 218),
        ToggleOff         = Color3.fromRGB(210, 205, 192),
        Scrollbar         = Color3.fromRGB(200, 192, 170),
        Border            = Color3.fromRGB(210, 200, 180),
        BorderAccent      = Color3.fromRGB(160, 130, 80),
    },
    Crimson = {
        Background        = Color3.fromRGB(8,   6,   8),
        Surface           = Color3.fromRGB(14,  10,  14),
        SurfaceElevated   = Color3.fromRGB(20,  14,  20),
        SurfaceRaised     = Color3.fromRGB(28,  18,  28),
        Accent            = Color3.fromRGB(200, 50,  80),
        AccentDim         = Color3.fromRGB(140, 35,  55),
        AccentGlow        = Color3.fromRGB(230, 70,  100),
        TextPrimary       = Color3.fromRGB(240, 230, 235),
        TextSecondary     = Color3.fromRGB(160, 140, 150),
        TextMuted         = Color3.fromRGB(80,  65,  70),
        Success           = Color3.fromRGB(80,  200, 120),
        Error             = Color3.fromRGB(220, 70,  70),
        Warning           = Color3.fromRGB(220, 170, 50),
        Info              = Color3.fromRGB(70,  140, 220),
        ButtonHover       = Color3.fromRGB(32,  22,  32),
        ToggleOff         = Color3.fromRGB(42,  28,  42),
        Scrollbar         = Color3.fromRGB(52,  35,  45),
        Border            = Color3.fromRGB(50,  28,  40),
        BorderAccent      = Color3.fromRGB(120, 40,  65),
    },
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local Utility = {}

function Utility.Tween(instance, properties, duration, easingStyle, easingDirection, delay)
    easingStyle      = easingStyle      or Enum.EasingStyle.Quint
    easingDirection  = easingDirection  or Enum.EasingDirection.Out
    duration         = duration         or 0.3
    delay            = delay            or 0

    local info   = TweenInfo.new(duration, easingStyle, easingDirection, 0, false, delay)
    local tween  = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Utility.Spring(instance, properties, duration)
    return Utility.Tween(instance, properties, duration or 0.5, Enum.EasingStyle.Spring, Enum.EasingDirection.Out)
end

function Utility.MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos = false, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta   = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function Utility.RippleEffect(button, theme)
    button.ClipsDescendants = true
    button.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        local ripple = Instance.new("Frame")
        ripple.AnchorPoint     = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = theme.Accent
        ripple.BackgroundTransparency = 0.6
        ripple.BorderSizePixel = 0
        ripple.Size            = UDim2.new(0, 0, 0, 0)
        ripple.Position        = UDim2.new(
            0, input.Position.X - button.AbsolutePosition.X,
            0, input.Position.Y - button.AbsolutePosition.Y
        )
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple
        ripple.Parent = button

        local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
        Utility.Tween(ripple, {
            Size = UDim2.new(0, size, 0, size),
            BackgroundTransparency = 1
        }, 0.55, Enum.EasingStyle.Quad)

        task.delay(0.6, function()
            ripple:Destroy()
        end)
    end)
end

function Utility.GlowEffect(frame, color, size)
    local glow = Instance.new("ImageLabel")
    glow.Name              = "Glow"
    glow.AnchorPoint       = Vector2.new(0.5, 0.5)
    glow.BackgroundTransparency = 1
    glow.Position          = UDim2.new(0.5, 0, 0.5, 0)
    glow.Size              = UDim2.new(1, size or 40, 1, size or 40)
    glow.Image             = "rbxassetid://5028857084"
    glow.ImageColor3       = color
    glow.ImageTransparency = 0.7
    glow.ZIndex            = frame.ZIndex - 1
    glow.Parent            = frame
    return glow
end

function Utility.Icon(parent, assetId, size, color, position)
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Image      = assetId or ""
    img.ImageColor3 = color or Color3.new(1,1,1)
    img.Size       = size or UDim2.new(0, 16, 0, 16)
    img.Position   = position or UDim2.new(0,0,0,0)
    img.Parent     = parent
    return img
end

function Utility.Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

function Utility.Stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color        = color or Color3.fromRGB(60,60,60)
    s.Thickness    = thickness or 1
    s.Transparency = transparency or 0
    s.Parent       = parent
    return s
end

function Utility.Shadow(frame, theme)
    local shadow = Instance.new("ImageLabel")
    shadow.Name              = "Shadow"
    shadow.AnchorPoint       = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image             = "rbxassetid://6014261993"
    shadow.ImageColor3       = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = 0.5
    shadow.Position          = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size              = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex            = frame.ZIndex - 1
    shadow.Parent            = frame
    return shadow
end

function Utility.Gradient(frame, colors, rotation)
    local g = Instance.new("UIGradient")
    local seq = {}
    for i, data in ipairs(colors) do
        table.insert(seq, ColorSequenceKeypoint.new(data[1], data[2]))
    end
    g.Color    = ColorSequence.new(seq)
    g.Rotation = rotation or 90
    g.Parent   = frame
    return g
end

function Utility.Shimmer(frame, theme)
    -- Creates a subtle animated shimmer on hover
    local shimmer = Instance.new("Frame")
    shimmer.Name              = "Shimmer"
    shimmer.BackgroundTransparency = 1
    shimmer.BorderSizePixel   = 0
    shimmer.Size              = UDim2.new(0, 60, 1, 0)
    shimmer.Position          = UDim2.new(-0.2, 0, 0, 0)
    shimmer.ClipsDescendants  = false
    shimmer.ZIndex            = frame.ZIndex + 2
    shimmer.Parent            = frame

    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
    })
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.85),
        NumberSequenceKeypoint.new(1, 1),
    })
    g.Rotation = 15
    g.Parent = shimmer

    frame.MouseEnter:Connect(function()
        shimmer.Position = UDim2.new(-0.2, 0, 0, 0)
        Utility.Tween(shimmer, { Position = UDim2.new(1.2, 0, 0, 0) }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    end)

    return shimmer
end

-- ============================================================
-- PHANTOM UI CORE
-- ============================================================

local NotificationQueue = {}
local NotificationCount = 0

function PhantomUI:CreateWindow(config)
    config = config or {}
    local Title    = config.Title    or "PhantomUI"
    local Subtitle = config.Subtitle or ""
    local ThemeName = config.Theme   or "Obsidian"
    local Size      = config.Size    or UDim2.new(0, 680, 0, 460)
    local MinimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift

    local T = Themes[ThemeName] or Themes.Obsidian

    -- --------------------------------------------------------
    -- ROOT GUI
    -- --------------------------------------------------------
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name              = "PhantomUI_" .. Title
    ScreenGui.ResetOnSpawn      = false
    ScreenGui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder      = 999

    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- --------------------------------------------------------
    -- WINDOW FRAME
    -- --------------------------------------------------------
    local WindowFrame = Instance.new("Frame")
    WindowFrame.Name              = "WindowFrame"
    WindowFrame.AnchorPoint       = Vector2.new(0.5, 0.5)
    WindowFrame.BackgroundColor3  = T.Background
    WindowFrame.BorderSizePixel   = 0
    WindowFrame.Position          = UDim2.new(0.5, 0, 0.5, 0)
    WindowFrame.Size              = UDim2.new(0, 0, 0, 0)
    WindowFrame.ClipsDescendants  = true
    WindowFrame.ZIndex            = 10
    WindowFrame.Parent            = ScreenGui

    Utility.Corner(WindowFrame, 12)
    Utility.Stroke(WindowFrame, T.BorderAccent, 1, 0.4)
    Utility.Shadow(WindowFrame, T)

    -- Subtle background gradient
    Utility.Gradient(WindowFrame, {
        {0,   T.Background},
        {0.5, T.Surface},
        {1,   T.Background},
    }, 135)

    -- Acrylic noise texture overlay
    local AcrylicNoise = Instance.new("ImageLabel")
    AcrylicNoise.Name              = "AcrylicNoise"
    AcrylicNoise.BackgroundTransparency = 1
    AcrylicNoise.Image             = "rbxassetid://9968344828"
    AcrylicNoise.ImageTransparency = 0.97
    AcrylicNoise.Size              = UDim2.new(1, 0, 1, 0)
    AcrylicNoise.ZIndex            = WindowFrame.ZIndex + 20
    AcrylicNoise.TileSize          = UDim2.new(0, 64, 0, 64)
    AcrylicNoise.ScaleType         = Enum.ScaleType.Tile
    AcrylicNoise.Parent            = WindowFrame

    -- Top accent line (gold rule)
    local TopAccentLine = Instance.new("Frame")
    TopAccentLine.Name             = "TopAccentLine"
    TopAccentLine.BackgroundColor3 = T.Accent
    TopAccentLine.BorderSizePixel  = 0
    TopAccentLine.Size             = UDim2.new(1, 0, 0, 1)
    TopAccentLine.Position         = UDim2.new(0, 0, 0, 0)
    TopAccentLine.ZIndex           = WindowFrame.ZIndex + 1
    TopAccentLine.Parent           = WindowFrame
    Utility.Gradient(TopAccentLine, {
        {0, Color3.fromRGB(0,0,0)},
        {0.3, T.Accent},
        {0.7, T.AccentGlow},
        {1, Color3.fromRGB(0,0,0)},
    }, 0)

    -- --------------------------------------------------------
    -- TITLEBAR
    -- --------------------------------------------------------
    local TitleBar = Instance.new("Frame")
    TitleBar.Name             = "TitleBar"
    TitleBar.BackgroundColor3 = T.SurfaceElevated
    TitleBar.BorderSizePixel  = 0
    TitleBar.Size             = UDim2.new(1, 0, 0, 52)
    TitleBar.ZIndex           = WindowFrame.ZIndex + 2
    TitleBar.Parent           = WindowFrame
    Utility.Gradient(TitleBar, {
        {0, T.SurfaceElevated},
        {1, T.Surface},
    }, 90)

    -- Logo mark / emblem (stylized P)
    local Emblem = Instance.new("Frame")
    Emblem.Name              = "Emblem"
    Emblem.BackgroundColor3  = T.Accent
    Emblem.BorderSizePixel   = 0
    Emblem.Size              = UDim2.new(0, 28, 0, 28)
    Emblem.Position          = UDim2.new(0, 14, 0.5, -14)
    Emblem.ZIndex            = TitleBar.ZIndex + 1
    Emblem.Parent            = TitleBar
    Utility.Corner(Emblem, 6)

    local EmblemLabel = Instance.new("TextLabel")
    EmblemLabel.BackgroundTransparency = 1
    EmblemLabel.Size                   = UDim2.new(1, 0, 1, 0)
    EmblemLabel.Text                   = "P"
    EmblemLabel.TextColor3             = T.Background
    EmblemLabel.Font                   = Enum.Font.GothamBold
    EmblemLabel.TextSize               = 15
    EmblemLabel.ZIndex                 = Emblem.ZIndex + 1
    EmblemLabel.Parent                 = Emblem

    local EmblemGlow = Utility.GlowEffect(Emblem, T.Accent, 20)

    -- Title text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name                = "TitleLabel"
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position            = UDim2.new(0, 52, 0, 8)
    TitleLabel.Size                = UDim2.new(0.6, 0, 0, 20)
    TitleLabel.Text                = Title
    TitleLabel.TextColor3          = T.TextPrimary
    TitleLabel.Font                = Enum.Font.GothamBold
    TitleLabel.TextSize            = 14
    TitleLabel.TextXAlignment      = Enum.TextXAlignment.Left
    TitleLabel.ZIndex              = TitleBar.ZIndex + 1
    TitleLabel.Parent              = TitleBar

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Name               = "SubtitleLabel"
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Position           = UDim2.new(0, 52, 0, 29)
    SubtitleLabel.Size               = UDim2.new(0.6, 0, 0, 14)
    SubtitleLabel.Text               = Subtitle
    SubtitleLabel.TextColor3         = T.AccentDim
    SubtitleLabel.Font               = Enum.Font.Gotham
    SubtitleLabel.TextSize           = 11
    SubtitleLabel.TextXAlignment     = Enum.TextXAlignment.Left
    SubtitleLabel.ZIndex             = TitleBar.ZIndex + 1
    SubtitleLabel.Parent             = TitleBar

    -- Bottom border of titlebar
    local TitleDivider = Instance.new("Frame")
    TitleDivider.BackgroundColor3 = T.Border
    TitleDivider.BorderSizePixel  = 0
    TitleDivider.Size             = UDim2.new(1, 0, 0, 1)
    TitleDivider.Position         = UDim2.new(0, 0, 1, -1)
    TitleDivider.ZIndex           = TitleBar.ZIndex
    TitleDivider.Parent           = TitleBar
    Utility.Gradient(TitleDivider, {
        {0, Color3.fromRGB(0,0,0)},
        {0.5, T.BorderAccent},
        {1, Color3.fromRGB(0,0,0)},
    }, 0)

    -- --------------------------------------------------------
    -- WINDOW CONTROLS (close, minimize)
    -- --------------------------------------------------------
    local Controls = Instance.new("Frame")
    Controls.Name              = "Controls"
    Controls.BackgroundTransparency = 1
    Controls.Size              = UDim2.new(0, 72, 0, 52)
    Controls.Position          = UDim2.new(1, -76, 0, 0)
    Controls.ZIndex            = TitleBar.ZIndex + 2
    Controls.Parent            = TitleBar

    local function MakeControl(icon, color, xOffset, callback)
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3  = T.SurfaceRaised
        btn.BorderSizePixel   = 0
        btn.Size              = UDim2.new(0, 22, 0, 22)
        btn.Position          = UDim2.new(0, xOffset, 0.5, -11)
        btn.Text              = ""
        btn.ZIndex            = Controls.ZIndex + 1
        btn.Parent            = Controls
        Utility.Corner(btn, 11)
        Utility.Stroke(btn, T.Border, 1, 0.3)

        local dot = Instance.new("Frame")
        dot.AnchorPoint       = Vector2.new(0.5, 0.5)
        dot.BackgroundColor3  = color
        dot.BorderSizePixel   = 0
        dot.Position          = UDim2.new(0.5, 0, 0.5, 0)
        dot.Size              = UDim2.new(0, 8, 0, 8)
        dot.ZIndex            = btn.ZIndex + 1
        dot.Parent            = btn
        Utility.Corner(dot, 4)

        btn.MouseEnter:Connect(function()
            Utility.Tween(dot, { Size = UDim2.new(0, 10, 0, 10) }, 0.15)
            Utility.Tween(btn, { BackgroundColor3 = color }, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Utility.Tween(dot, { Size = UDim2.new(0, 8, 0, 8) }, 0.15)
            Utility.Tween(btn, { BackgroundColor3 = T.SurfaceRaised }, 0.15)
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local IsMinimized = false
    local FullSize    = Size
    local MiniSize    = UDim2.new(Size.X.Scale, Size.X.Offset, 0, 52)

    local CloseBtn    = MakeControl("✕", T.Error,   4, function()
        Utility.Tween(WindowFrame, { Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.45, function() ScreenGui:Destroy() end)
    end)
    local MinBtn      = MakeControl("−", T.Warning, 32, function()
        IsMinimized = not IsMinimized
        Utility.Spring(WindowFrame, {
            Size = IsMinimized and MiniSize or FullSize
        }, 0.55)
    end)

    -- --------------------------------------------------------
    -- SIDEBAR (tab navigation)
    -- --------------------------------------------------------
    local Sidebar = Instance.new("Frame")
    Sidebar.Name             = "Sidebar"
    Sidebar.BackgroundColor3 = T.SurfaceElevated
    Sidebar.BorderSizePixel  = 0
    Sidebar.Position         = UDim2.new(0, 0, 0, 52)
    Sidebar.Size             = UDim2.new(0, 140, 1, -52)
    Sidebar.ZIndex           = WindowFrame.ZIndex + 2
    Sidebar.Parent           = WindowFrame
    Utility.Gradient(Sidebar, {
        {0, T.SurfaceElevated},
        {1, T.Surface},
    }, 90)

    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.BackgroundColor3 = T.Border
    SidebarDivider.BorderSizePixel  = 0
    SidebarDivider.Size             = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Position         = UDim2.new(1, -1, 0, 0)
    SidebarDivider.ZIndex           = Sidebar.ZIndex
    SidebarDivider.Parent           = Sidebar

    local TabList = Instance.new("ScrollingFrame")
    TabList.Name                  = "TabList"
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel       = 0
    TabList.Position              = UDim2.new(0, 0, 0, 10)
    TabList.Size                  = UDim2.new(1, 0, 1, -38)
    TabList.ScrollBarThickness    = 0
    TabList.CanvasSize            = UDim2.new(0, 0, 0, 0)
    TabList.ZIndex                = Sidebar.ZIndex + 1
    TabList.Parent                = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder       = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding         = UDim.new(0, 4)
    TabListLayout.Parent          = TabList

    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabList.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Phantom branding at bottom of sidebar
        -- Phantom branding at bottom of sidebar
    local SidebarBrand = Instance.new("TextLabel")
    SidebarBrand.Name               = "SidebarBrand"
    SidebarBrand.BackgroundTransparency = 1
    SidebarBrand.Position           = UDim2.new(0, 0, 1, -28)
    SidebarBrand.Size               = UDim2.new(1, 0, 0, 28)
    SidebarBrand.Text               = "PHANTOM"
    SidebarBrand.TextColor3         = T.TextMuted
    SidebarBrand.Font               = Enum.Font.GothamBold
    SidebarBrand.TextSize           = 9
    SidebarBrand.LetterSpacing      = 4
    SidebarBrand.ZIndex             = Sidebar.ZIndex + 1
    SidebarBrand.Parent             = Sidebar

    -- --------------------------------------------------------
    -- CONTENT AREA
    -- --------------------------------------------------------
    local ContentArea = Instance.new("Frame")
    ContentArea.Name             = "ContentArea"
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel  = 0
    ContentArea.Position         = UDim2.new(0, 140, 0, 52)
    ContentArea.Size             = UDim2.new(1, -140, 1, -52)
    ContentArea.ClipsDescendants = true
    ContentArea.ZIndex           = WindowFrame.ZIndex + 2
    ContentArea.Parent           = WindowFrame

    -- --------------------------------------------------------
    -- DRAG & OPEN ANIMATION
    -- --------------------------------------------------------
    Utility.MakeDraggable(WindowFrame, TitleBar)

    task.spawn(function()
        WindowFrame.Size = UDim2.new(0, 0, 0, 0)
        task.wait()
        Utility.Spring(WindowFrame, { Size = FullSize }, 0.65)
    end)

    -- --------------------------------------------------------
    -- KEYBOARD TOGGLE
    -- --------------------------------------------------------
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == MinimizeKey then
            IsMinimized = not IsMinimized
            Utility.Spring(WindowFrame, {
                Size = IsMinimized and MiniSize or FullSize
            }, 0.55)
        end
    end)

    -- ============================================================
    -- WINDOW OBJECT
    -- ============================================================
    local Window = { _tabs = {}, _activeTab = nil, _theme = T, _gui = ScreenGui }

    -- --------------------------------------------------------
    -- ADD TAB
    -- --------------------------------------------------------
    function Window:AddTab(label, icon)
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name                  = "Tab_" .. label
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel       = 0
        TabPage.Size                  = UDim2.new(1, 0, 1, 0)
        TabPage.ScrollBarThickness    = 3
        TabPage.ScrollBarImageColor3  = T.Scrollbar
        TabPage.CanvasSize            = UDim2.new(0, 0, 0, 0)
        TabPage.Visible               = false
        TabPage.ZIndex                = ContentArea.ZIndex + 1
        TabPage.Parent                = ContentArea

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder  = Enum.SortOrder.LayoutOrder
        PageLayout.Padding    = UDim.new(0, 6)
        PageLayout.Parent     = TabPage

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop    = UDim.new(0, 12)
        PagePadding.PaddingLeft   = UDim.new(0, 14)
        PagePadding.PaddingRight  = UDim.new(0, 14)
        PagePadding.PaddingBottom = UDim.new(0, 12)
        PagePadding.Parent        = TabPage

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 24)
        end)

        -- Sidebar tab button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name              = "TabBtn_" .. label
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel   = 0
        TabBtn.Size              = UDim2.new(1, -16, 0, 36)
        TabBtn.Position          = UDim2.new(0, 8, 0, 0)
        TabBtn.Text              = ""
        TabBtn.ZIndex            = TabList.ZIndex + 1
        TabBtn.LayoutOrder       = #self._tabs + 1
        TabBtn.Parent            = TabList
        Utility.Corner(TabBtn, 8)

        local TabIndicator = Instance.new("Frame")
        TabIndicator.Name             = "Indicator"
        TabIndicator.BackgroundColor3 = T.Accent
        TabIndicator.BorderSizePixel  = 0
        TabIndicator.Size             = UDim2.new(0, 3, 0, 0)
        TabIndicator.Position         = UDim2.new(0, 0, 0.5, 0)
        TabIndicator.AnchorPoint      = Vector2.new(0, 0.5)
        TabIndicator.ZIndex           = TabBtn.ZIndex + 1
        TabIndicator.Parent           = TabBtn
        Utility.Corner(TabIndicator, 2)

        local TabLabel = Instance.new("TextLabel")
        TabLabel.BackgroundTransparency = 1
        TabLabel.Position          = UDim2.new(0, 16, 0, 0)
        TabLabel.Size              = UDim2.new(1, -16, 1, 0)
        TabLabel.Text              = label
        TabLabel.TextColor3        = T.TextSecondary
        TabLabel.Font              = Enum.Font.Gotham
        TabLabel.TextSize          = 12
        TabLabel.TextXAlignment    = Enum.TextXAlignment.Left
        TabLabel.ZIndex            = TabBtn.ZIndex + 1
        TabLabel.Parent            = TabBtn

        local function Activate()
            -- Deactivate others
            for _, t in ipairs(Window._tabs) do
                t.page.Visible = false
                Utility.Tween(t.btn, { BackgroundTransparency = 1 }, 0.2)
                Utility.Tween(t.label, { TextColor3 = T.TextSecondary, Font = Enum.Font.Gotham }, 0.2)
                Utility.Tween(t.indicator, { Size = UDim2.new(0, 3, 0, 0) }, 0.25, Enum.EasingStyle.Back)
            end
            -- Activate this
            TabPage.Visible = true
            TabPage.ScrollingEnabled = true
            Utility.Tween(TabBtn, { BackgroundColor3 = T.SurfaceRaised, BackgroundTransparency = 0 }, 0.2)
            Utility.Tween(TabLabel, { TextColor3 = T.Accent }, 0.2)
            TabLabel.Font = Enum.Font.GothamBold
            Utility.Spring(TabIndicator, { Size = UDim2.new(0, 3, 0.55, 0) }, 0.4)
            Window._activeTab = label
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        TabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= label then
                Utility.Tween(TabBtn, { BackgroundColor3 = T.ButtonHover, BackgroundTransparency = 0 }, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= label then
                Utility.Tween(TabBtn, { BackgroundTransparency = 1 }, 0.15)
            end
        end)

        local tabEntry = { page = TabPage, btn = TabBtn, label = TabLabel, indicator = TabIndicator }
        table.insert(self._tabs, tabEntry)

        if #self._tabs == 1 then
            task.defer(Activate)
        end

        -- ============================================================
        -- TAB OBJECT (component factory)
        -- ============================================================
        local Tab = { _page = TabPage, _theme = T, _layout = PageLayout, _order = 0 }

        local function NextOrder()
            Tab._order = Tab._order + 1
            return Tab._order
        end

        local function MakeElementFrame(height)
            local frame = Instance.new("Frame")
            frame.BackgroundColor3 = T.SurfaceElevated
            frame.BorderSizePixel  = 0
            frame.Size             = UDim2.new(1, 0, 0, height or 42)
            frame.LayoutOrder      = NextOrder()
            frame.ZIndex           = TabPage.ZIndex + 1
            frame.Parent           = TabPage
            Utility.Corner(frame, 8)
            Utility.Stroke(frame, T.Border, 1, 0.6)
            return frame
        end

        local function ElementLabel(parent, text, xOff, yOff, w, h)
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Position          = UDim2.new(0, xOff, 0, yOff)
            lbl.Size              = UDim2.new(0, w or 200, 0, h or 14)
            lbl.Text              = text
            lbl.TextColor3        = T.TextPrimary
            lbl.Font              = Enum.Font.Gotham
            lbl.TextSize          = 12
            lbl.TextXAlignment    = Enum.TextXAlignment.Left
            lbl.ZIndex            = parent.ZIndex + 1
            lbl.Parent            = parent
            return lbl
        end

        -- --------------------------------------------------------
        -- BUTTON
        -- --------------------------------------------------------
        function Tab:AddButton(cfg)
            cfg = cfg or {}
            local frame = MakeElementFrame(42)
            Utility.Gradient(frame, { {0, T.SurfaceElevated}, {1, T.SurfaceRaised} }, 90)

            local btn = Instance.new("TextButton")
            btn.BackgroundTransparency = 1
            btn.BorderSizePixel  = 0
            btn.Size             = UDim2.new(1, 0, 1, 0)
            btn.Text             = ""
            btn.ZIndex           = frame.ZIndex + 1
            btn.Parent           = frame

            local lbl = ElementLabel(frame, cfg.Label or "Button", 16, 0, 300, 42)
            lbl.TextColor3  = T.TextPrimary
            lbl.Font        = Enum.Font.Gotham
            lbl.TextSize    = 12

            -- Right arrow indicator
            local arrow = Instance.new("TextLabel")
            arrow.BackgroundTransparency = 1
            arrow.Position          = UDim2.new(1, -36, 0.5, -8)
            arrow.Size              = UDim2.new(0, 20, 0, 16)
            arrow.Text              = "›"
            arrow.TextColor3        = T.AccentDim
            arrow.Font              = Enum.Font.GothamBold
            arrow.TextSize          = 18
            arrow.ZIndex            = frame.ZIndex + 2
            arrow.Parent            = frame

            Utility.RippleEffect(btn, T)
            Utility.Shimmer(frame, T)

            btn.MouseEnter:Connect(function()
                Utility.Tween(frame, { BackgroundColor3 = T.ButtonHover }, 0.15)
                Utility.Tween(arrow, { TextColor3 = T.Accent, Position = UDim2.new(1, -30, 0.5, -8) }, 0.2)
                Utility.Tween(lbl, { TextColor3 = T.AccentGlow }, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                Utility.Tween(frame, { BackgroundColor3 = T.SurfaceElevated }, 0.15)
                Utility.Tween(arrow, { TextColor3 = T.AccentDim, Position = UDim2.new(1, -36, 0.5, -8) }, 0.2)
                Utility.Tween(lbl, { TextColor3 = T.TextPrimary }, 0.15)
            end)

            btn.MouseButton1Click:Connect(function()
                -- Press animation
                Utility.Spring(frame, { Size = UDim2.new(0.98, 0, 0, 40) }, 0.3)
                task.delay(0.12, function()
                    Utility.Spring(frame, { Size = UDim2.new(1, 0, 0, 42) }, 0.4)
                end)
                if cfg.Callback then cfg.Callback() end
            end)

            return { Frame = frame }
        end

        -- --------------------------------------------------------
        -- TOGGLE
        -- --------------------------------------------------------
        function Tab:AddToggle(cfg)
            cfg = cfg or {}
            local frame  = MakeElementFrame(42)
            local Value  = cfg.Default or false

            ElementLabel(frame, cfg.Label or "Toggle", 16, 0, 250, 42)

            -- Toggle pill
            local Track = Instance.new("Frame")
            Track.AnchorPoint      = Vector2.new(1, 0.5)
            Track.BackgroundColor3 = Value and T.Accent or T.ToggleOff
            Track.BorderSizePixel  = 0
            Track.Position         = UDim2.new(1, -14, 0.5, 0)
            Track.Size             = UDim2.new(0, 38, 0, 20)
            Track.ZIndex           = frame.ZIndex + 2
            Track.Parent           = frame
            Utility.Corner(Track, 10)
            local TrackStroke = Utility.Stroke(Track, Value and T.BorderAccent or T.Border, 1, 0.3)

            local Thumb = Instance.new("Frame")
            Thumb.AnchorPoint      = Vector2.new(0.5, 0.5)
            Thumb.BackgroundColor3 = Color3.new(1,1,1)
            Thumb.BorderSizePixel  = 0
            Thumb.Position         = Value and UDim2.new(0.75, 0, 0.5, 0) or UDim2.new(0.28, 0, 0.5, 0)
            Thumb.Size             = UDim2.new(0, 14, 0, 14)
            Thumb.ZIndex           = Track.ZIndex + 1
            Thumb.Parent           = Track
            Utility.Corner(Thumb, 7)

            local ThumbGlow = nil
            if Value then ThumbGlow = Utility.GlowEffect(Thumb, T.Accent, 12) end

            local function SetValue(v)
                Value = v
                Utility.Tween(Track, { BackgroundColor3 = v and T.Accent or T.ToggleOff }, 0.25)
                Utility.Tween(TrackStroke, { Color = v and T.BorderAccent or T.Border }, 0.25)
                Utility.Spring(Thumb, { Position = v and UDim2.new(0.75, 0, 0.5, 0) or UDim2.new(0.28, 0, 0.5, 0) }, 0.4)
                if v and not ThumbGlow then
                    ThumbGlow = Utility.GlowEffect(Thumb, T.Accent, 12)
                elseif not v and ThumbGlow then
                    ThumbGlow:Destroy()
                    ThumbGlow = nil
                end
                if cfg.Callback then cfg.Callback(Value) end
            end

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Size             = UDim2.new(1, 0, 1, 0)
            ClickBtn.Text             = ""
            ClickBtn.ZIndex           = frame.ZIndex + 3
            ClickBtn.Parent           = frame
            ClickBtn.MouseButton1Click:Connect(function() SetValue(not Value) end)

            frame.MouseEnter:Connect(function() Utility.Tween(frame, { BackgroundColor3 = T.ButtonHover }, 0.15) end)
            frame.MouseLeave:Connect(function() Utility.Tween(frame, { BackgroundColor3 = T.SurfaceElevated }, 0.15) end)

            return {
                Frame = frame,
                Set   = SetValue,
                Get   = function() return Value end,
            }
        end

        -- --------------------------------------------------------
        -- SLIDER
        -- --------------------------------------------------------
        function Tab:AddSlider(cfg)
            cfg = cfg or {}
            local frame = MakeElementFrame(56)
            local Min   = cfg.Min     or 0
            local Max   = cfg.Max     or 100
            local Value = cfg.Default or Min
            local Suffix = cfg.Suffix or ""

            local TitleLbl = ElementLabel(frame, cfg.Label or "Slider", 16, 8, 220, 14)

            local ValLbl = Instance.new("TextLabel")
            ValLbl.BackgroundTransparency = 1
            ValLbl.Position  = UDim2.new(1, -52, 0, 8)
            ValLbl.Size      = UDim2.new(0, 40, 0, 14)
            ValLbl.Text      = tostring(math.floor(Value)) .. Suffix
            ValLbl.TextColor3 = T.Accent
            ValLbl.Font      = Enum.Font.GothamBold
            ValLbl.TextSize  = 11
            ValLbl.TextXAlignment = Enum.TextXAlignment.Right
            ValLbl.ZIndex    = frame.ZIndex + 1
            ValLbl.Parent    = frame

            -- Track
            local TrackBg = Instance.new("Frame")
            TrackBg.BackgroundColor3 = T.ToggleOff
            TrackBg.BorderSizePixel  = 0
            TrackBg.Position         = UDim2.new(0, 16, 0, 38)
            TrackBg.Size             = UDim2.new(1, -32, 0, 5)
            TrackBg.ZIndex           = frame.ZIndex + 1
            TrackBg.Parent           = frame
            Utility.Corner(TrackBg, 3)

            local Range  = (Max - Min) ~= 0 and (Max - Min) or 1
            local Fill = Instance.new("Frame")
            Fill.BackgroundColor3 = T.Accent
            Fill.BorderSizePixel  = 0
            Fill.Size             = UDim2.new((Value - Min) / Range, 0, 1, 0)
            Fill.ZIndex           = TrackBg.ZIndex + 1
            Fill.Parent           = TrackBg
            Utility.Corner(Fill, 3)
            Utility.Gradient(Fill, { {0, T.AccentDim}, {1, T.AccentGlow} }, 0)

            local Handle = Instance.new("Frame")
            Handle.AnchorPoint      = Vector2.new(0.5, 0.5)
            Handle.BackgroundColor3 = Color3.new(1,1,1)
            Handle.BorderSizePixel  = 0
            Handle.Position         = UDim2.new((Value - Min) / Range, 0, 0.5, 0)
            Handle.Size             = UDim2.new(0, 13, 0, 13)
            Handle.ZIndex           = TrackBg.ZIndex + 2
            Handle.Parent           = TrackBg
            Utility.Corner(Handle, 7)
            Utility.Stroke(Handle, T.Accent, 2, 0)
            Utility.GlowEffect(Handle, T.Accent, 16)

            local Dragging = false

            local function UpdateSlider(input)
                local rel   = (input.Position.X - TrackBg.AbsolutePosition.X) / TrackBg.AbsoluteSize.X
                rel         = math.clamp(rel, 0, 1)
                local val   = math.floor(Min + rel * Range)
                if val == Value then return end
                Value       = val
                ValLbl.Text = tostring(Value) .. Suffix
                Fill.Size   = UDim2.new(rel, 0, 1, 0)
                Handle.Position = UDim2.new(rel, 0, 0.5, 0)
                if cfg.Callback then cfg.Callback(Value) end
            end

            local SliderBtn = Instance.new("TextButton")
            SliderBtn.BackgroundTransparency = 1
            SliderBtn.Size    = UDim2.new(1, 0, 1, 0)
            SliderBtn.Text    = ""
            SliderBtn.ZIndex  = TrackBg.ZIndex + 3
            SliderBtn.Parent  = TrackBg

            SliderBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    Utility.Spring(Handle, { Size = UDim2.new(0, 16, 0, 16) }, 0.3)
                    UpdateSlider(input)
                end
            end)
            SliderBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                    Utility.Spring(Handle, { Size = UDim2.new(0, 13, 0, 13) }, 0.3)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)

            frame.MouseEnter:Connect(function() Utility.Tween(frame, { BackgroundColor3 = T.ButtonHover }, 0.15) end)
            frame.MouseLeave:Connect(function() Utility.Tween(frame, { BackgroundColor3 = T.SurfaceElevated }, 0.15) end)

            return {
                Frame = frame,
                Set   = function(v)
                    Value = math.clamp(v, Min, Max)
                    ValLbl.Text = tostring(math.floor(Value)) .. Suffix
                    local rel = (Value - Min) / Range
                    Fill.Size = UDim2.new(rel, 0, 1, 0)
                    Handle.Position = UDim2.new(rel, 0, 0.5, 0)
                end,
                Get = function() return Value end,
            }
        end

        -- --------------------------------------------------------
        -- DROPDOWN
        -- --------------------------------------------------------
        function Tab:AddDropdown(cfg)
            cfg = cfg or {}
            local frame    = MakeElementFrame(42)
            frame.ClipsDescendants = false
            local Options  = cfg.Options or {}
            local Selected = cfg.Default or Options[1] or ""
            local IsOpen   = false

            ElementLabel(frame, cfg.Label or "Dropdown", 16, 0, 200, 42)

            local SelBtn = Instance.new("TextButton")
            SelBtn.AnchorPoint       = Vector2.new(1, 0.5)
            SelBtn.BackgroundColor3  = T.SurfaceRaised
            SelBtn.BorderSizePixel   = 0
            SelBtn.Position          = UDim2.new(1, -12, 0.5, 0)
            SelBtn.Size              = UDim2.new(0, 130, 0, 26)
            SelBtn.Text              = ""
            SelBtn.ZIndex            = frame.ZIndex + 2
            SelBtn.Parent            = frame
            Utility.Corner(SelBtn, 6)
            Utility.Stroke(SelBtn, T.BorderAccent, 1, 0.5)

            local SelLbl = Instance.new("TextLabel")
            SelLbl.BackgroundTransparency = 1
            SelLbl.Position   = UDim2.new(0, 10, 0, 0)
            SelLbl.Size       = UDim2.new(1, -26, 1, 0)
            SelLbl.Text       = Selected
            SelLbl.TextColor3 = T.Accent
            SelLbl.Font       = Enum.Font.Gotham
            SelLbl.TextSize   = 11
            SelLbl.TextXAlignment = Enum.TextXAlignment.Left
            SelLbl.ZIndex     = SelBtn.ZIndex + 1
            SelLbl.Parent     = SelBtn

            local Chevron = Instance.new("TextLabel")
            Chevron.BackgroundTransparency = 1
            Chevron.Position   = UDim2.new(1, -22, 0.5, -8)
            Chevron.Size       = UDim2.new(0, 16, 0, 16)
            Chevron.Text       = "⌄"
            Chevron.TextColor3 = T.AccentDim
            Chevron.Font       = Enum.Font.GothamBold
            Chevron.TextSize   = 13
            Chevron.ZIndex     = SelBtn.ZIndex + 1
            Chevron.Parent     = SelBtn

            -- Dropdown list
            local DropFrame = Instance.new("Frame")
            DropFrame.BackgroundColor3 = T.SurfaceRaised
            DropFrame.BorderSizePixel  = 0
            DropFrame.Position         = UDim2.new(0, 0, 1, 2)
            DropFrame.Size             = UDim2.new(1, 0, 0, 0)
            DropFrame.ZIndex           = frame.ZIndex + 10
            DropFrame.ClipsDescendants = true
            DropFrame.Parent           = frame
            Utility.Corner(DropFrame, 8)
            Utility.Stroke(DropFrame, T.BorderAccent, 1, 0.4)
            Utility.Shadow(DropFrame, T)

            local DropList = Instance.new("UIListLayout")
            DropList.SortOrder = Enum.SortOrder.LayoutOrder
            DropList.Padding   = UDim.new(0, 2)
            DropList.Parent    = DropFrame

            local DropPad = Instance.new("UIPadding")
            DropPad.PaddingTop    = UDim.new(0, 4)
            DropPad.PaddingBottom = UDim.new(0, 4)
            DropPad.PaddingLeft   = UDim.new(0, 4)
            DropPad.PaddingRight  = UDim.new(0, 4)
            DropPad.Parent = DropFrame

            local totalH = #Options * 30 + 8

            for i, opt in ipairs(Options) do
                local optBtn = Instance.new("TextButton")
                optBtn.BackgroundColor3  = T.SurfaceRaised
                optBtn.BackgroundTransparency = opt == Selected and 0 or 1
                optBtn.BorderSizePixel   = 0
                optBtn.Size              = UDim2.new(1, 0, 0, 28)
                optBtn.Text              = ""
                optBtn.ZIndex            = DropFrame.ZIndex + 1
                optBtn.LayoutOrder       = i
                optBtn.Parent            = DropFrame
                Utility.Corner(optBtn, 6)

                if opt == Selected then
                    optBtn.BackgroundColor3 = T.ButtonHover
                    optBtn.BackgroundTransparency = 0
                end

                local optLbl = Instance.new("TextLabel")
                optLbl.BackgroundTransparency = 1
                optLbl.Position   = UDim2.new(0, 10, 0, 0)
                optLbl.Size       = UDim2.new(1, -10, 1, 0)
                optLbl.Text       = opt
                optLbl.TextColor3 = opt == Selected and T.Accent or T.TextSecondary
                optLbl.Font       = opt == Selected and Enum.Font.GothamBold or Enum.Font.Gotham
                optLbl.TextSize   = 11
                optLbl.TextXAlignment = Enum.TextXAlignment.Left
                optLbl.ZIndex     = optBtn.ZIndex + 1
                optLbl.Parent     = optBtn

                optBtn.MouseEnter:Connect(function()
                    Utility.Tween(optBtn, { BackgroundTransparency = 0, BackgroundColor3 = T.ButtonHover }, 0.1)
                    Utility.Tween(optLbl, { TextColor3 = T.TextPrimary }, 0.1)
                end)
                optBtn.MouseLeave:Connect(function()
                    if opt ~= Selected then
                        Utility.Tween(optBtn, { BackgroundTransparency = 1 }, 0.1)
                        Utility.Tween(optLbl, { TextColor3 = T.TextSecondary }, 0.1)
                    end
                end)
                optBtn.MouseButton1Click:Connect(function()
                    -- Reset all options visually
                    for _, child in ipairs(DropFrame:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.BackgroundTransparency = 1
                            local childLbl = child:FindFirstChildWhichIsA("TextLabel")
                            if childLbl then
                                childLbl.TextColor3 = T.TextSecondary
                                childLbl.Font = Enum.Font.Gotham
                            end
                        end
                    end
                    -- Highlight new selection
                    optBtn.BackgroundColor3 = T.ButtonHover
                    optBtn.BackgroundTransparency = 0
                    optLbl.TextColor3 = T.Accent
                    optLbl.Font = Enum.Font.GothamBold

                    Selected    = opt
                    SelLbl.Text = opt
                    -- Close
                    IsOpen = false
                    Utility.Tween(DropFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2, Enum.EasingStyle.Quint)
                    Utility.Tween(Chevron, { Rotation = 0 }, 0.2)
                    if cfg.Callback then cfg.Callback(opt) end
                end)
            end

            SelBtn.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                Utility.Spring(DropFrame, { Size = IsOpen and UDim2.new(1, 0, 0, totalH) or UDim2.new(1, 0, 0, 0) }, 0.4)
                Utility.Tween(Chevron, { Rotation = IsOpen and 180 or 0 }, 0.25)
            end)

            return {
                Frame    = frame,
                Set      = function(v) SelLbl.Text = v; Selected = v end,
                Get      = function() return Selected end,
            }
        end

        -- --------------------------------------------------------
        -- TEXTBOX
        -- --------------------------------------------------------
        function Tab:AddTextbox(cfg)
            cfg = cfg or {}
            local frame = MakeElementFrame(42)

            ElementLabel(frame, cfg.Label or "Input", 16, 0, 200, 42)

            local Box = Instance.new("TextBox")
            Box.AnchorPoint          = Vector2.new(1, 0.5)
            Box.BackgroundColor3     = T.SurfaceRaised
            Box.BorderSizePixel      = 0
            Box.Position             = UDim2.new(1, -12, 0.5, 0)
            Box.Size                 = UDim2.new(0, 160, 0, 26)
            Box.Text                 = cfg.Default or ""
            Box.PlaceholderText      = cfg.Placeholder or "Enter value..."
            Box.PlaceholderColor3    = T.TextMuted
            Box.TextColor3           = T.TextPrimary
            Box.Font                 = Enum.Font.Gotham
            Box.TextSize             = 11
            Box.ClearTextOnFocus     = cfg.ClearOnFocus ~= nil and cfg.ClearOnFocus or false
            Box.ZIndex               = frame.ZIndex + 2
            Box.Parent               = frame
            Utility.Corner(Box, 6)

            local BoxStroke = Utility.Stroke(Box, T.BorderAccent, 1, 0.5)

            local BoxPad = Instance.new("UIPadding")
            BoxPad.PaddingLeft = UDim.new(0, 8)
            BoxPad.Parent = Box

            Box.Focused:Connect(function()
                Utility.Tween(Box, { BackgroundColor3 = T.Background }, 0.15)
                Utility.Tween(BoxStroke, { Color = T.Accent, Transparency = 0 }, 0.15)
            end)
            Box.FocusLost:Connect(function(enter)
                Utility.Tween(Box, { BackgroundColor3 = T.SurfaceRaised }, 0.15)
                Utility.Tween(BoxStroke, { Color = T.BorderAccent, Transparency = 0.5 }, 0.15)
                if cfg.Callback then cfg.Callback(Box.Text, enter) end
            end)

            frame.MouseEnter:Connect(function() Utility.Tween(frame, { BackgroundColor3 = T.ButtonHover }, 0.15) end)
            frame.MouseLeave:Connect(function() Utility.Tween(frame, { BackgroundColor3 = T.SurfaceElevated }, 0.15) end)

            return {
                Frame = frame,
                Box   = Box,
                Get   = function() return Box.Text end,
                Set   = function(v) Box.Text = v end,
            }
        end

        -- --------------------------------------------------------
        -- LABEL
        -- --------------------------------------------------------
        function Tab:AddLabel(text)
            local frame = Instance.new("Frame")
            frame.BackgroundTransparency = 1
            frame.BorderSizePixel        = 0
            frame.Size                   = UDim2.new(1, 0, 0, 24)
            frame.LayoutOrder            = NextOrder()
            frame.ZIndex                 = TabPage.ZIndex + 1
            frame.Parent                 = TabPage

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency   = 1
            lbl.Position                 = UDim2.new(0, 4, 0, 0)
            lbl.Size                     = UDim2.new(1, -8, 1, 0)
            lbl.Text                     = text
            lbl.TextColor3               = T.TextSecondary
            lbl.Font                     = Enum.Font.Gotham
            lbl.TextSize                 = 11
            lbl.TextXAlignment           = Enum.TextXAlignment.Left
            lbl.ZIndex                   = frame.ZIndex + 1
            lbl.Parent                   = frame

            return {
                Frame = frame,
                Set   = function(v) lbl.Text = v end,
                Get   = function() return lbl.Text end,
            }
        end

        -- --------------------------------------------------------
        -- SEPARATOR
        -- --------------------------------------------------------
        function Tab:AddSeparator(labelText)
            local frame = Instance.new("Frame")
            frame.BackgroundTransparency = 1
            frame.Size        = UDim2.new(1, 0, 0, 20)
            frame.LayoutOrder = NextOrder()
            frame.ZIndex      = TabPage.ZIndex + 1
            frame.Parent      = TabPage

            if labelText then
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Position   = UDim2.new(0, 0, 0, 2)
                lbl.Size       = UDim2.new(0, 80, 0, 14)
                lbl.Text       = labelText
                lbl.TextColor3 = T.AccentDim
                lbl.Font       = Enum.Font.GothamBold
                lbl.TextSize   = 9
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.ZIndex     = frame.ZIndex + 2
                lbl.Parent     = frame
            end

            local line = Instance.new("Frame")
            line.BackgroundColor3 = T.Border
            line.BorderSizePixel  = 0
            line.Position         = UDim2.new(0, 0, 0.5, 0)
            line.Size             = UDim2.new(1, 0, 0, 1)
            line.ZIndex           = frame.ZIndex + 1
            line.Parent           = frame
            Utility.Gradient(line, {
                {0, Color3.fromRGB(0,0,0)},
                {0.4, T.BorderAccent},
                {0.6, T.BorderAccent},
                {1, Color3.fromRGB(0,0,0)},
            }, 0)

            return { Frame = frame }
        end

        -- --------------------------------------------------------
        -- COLOR PICKER
        -- --------------------------------------------------------
        function Tab:AddColorPicker(cfg)
            cfg = cfg or {}
            local frame   = MakeElementFrame(42)
            frame.ClipsDescendants = false
            local Value   = cfg.Default or Color3.fromRGB(255, 255, 255)
            local IsOpen  = false

            ElementLabel(frame, cfg.Label or "Color", 16, 0, 200, 42)

            local Preview = Instance.new("Frame")
            Preview.AnchorPoint      = Vector2.new(1, 0.5)
            Preview.BackgroundColor3 = Value
            Preview.BorderSizePixel  = 0
            Preview.Position         = UDim2.new(1, -14, 0.5, 0)
            Preview.Size             = UDim2.new(0, 58, 0, 24)
            Preview.ZIndex           = frame.ZIndex + 2
            Preview.Parent           = frame
            Utility.Corner(Preview, 6)
            Utility.Stroke(Preview, T.Border, 1, 0.3)

            -- Color picker panel
            local PickerFrame = Instance.new("Frame")
            PickerFrame.BackgroundColor3 = T.SurfaceRaised
            PickerFrame.BorderSizePixel  = 0
            PickerFrame.Position         = UDim2.new(0, 0, 1, 2)
            PickerFrame.Size             = UDim2.new(1, 0, 0, 0)
            PickerFrame.ClipsDescendants = true
            PickerFrame.ZIndex           = frame.ZIndex + 10
            PickerFrame.Parent           = frame
            Utility.Corner(PickerFrame, 8)
            Utility.Stroke(PickerFrame, T.BorderAccent, 1, 0.4)

            -- Hue, Saturation, Value inputs
            local H, S, V_val = Color3.toHSV(Value)
            local function Rebuild()
                Value   = Color3.fromHSV(H, S, V_val)
                Utility.Tween(Preview, { BackgroundColor3 = Value }, 0.1)
                if cfg.Callback then cfg.Callback(Value) end
            end

            local function Slider3(lbl, yOff, getVal, setVal, color)
                local sl = Instance.new("Frame")
                sl.BackgroundColor3 = T.ToggleOff
                sl.BorderSizePixel  = 0
                sl.Position         = UDim2.new(0, 12, 0, yOff)
                sl.Size             = UDim2.new(1, -24, 0, 12)
                sl.ZIndex           = PickerFrame.ZIndex + 1
                sl.Parent           = PickerFrame
                Utility.Corner(sl, 6)

                local fill = Instance.new("Frame")
                fill.BackgroundColor3 = color or T.Accent
                fill.BorderSizePixel  = 0
                fill.Size             = UDim2.new(getVal(), 0, 1, 0)
                fill.ZIndex           = sl.ZIndex + 1
                fill.Parent           = sl
                Utility.Corner(fill, 6)

                local thumb = Instance.new("Frame")
                thumb.AnchorPoint      = Vector2.new(0.5, 0.5)
                thumb.BackgroundColor3 = Color3.new(1,1,1)
                thumb.BorderSizePixel  = 0
                thumb.Position         = UDim2.new(getVal(), 0, 0.5, 0)
                thumb.Size             = UDim2.new(0, 10, 0, 10)
                thumb.ZIndex           = sl.ZIndex + 2
                thumb.Parent           = sl
                Utility.Corner(thumb, 5)

                local dragging = false
                local sb = Instance.new("TextButton")
                sb.BackgroundTransparency = 1
                sb.Size   = UDim2.new(1, 0, 1, 0)
                sb.Text   = ""
                sb.ZIndex = sl.ZIndex + 3
                sb.Parent = sl

                sb.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                sb.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local rel = math.clamp((input.Position.X - sl.AbsolutePosition.X) / sl.AbsoluteSize.X, 0, 1)
                        setVal(rel)
                        fill.Size        = UDim2.new(rel, 0, 1, 0)
                        thumb.Position   = UDim2.new(rel, 0, 0.5, 0)
                        Rebuild()
                    end
                end)
            end

            local lblH = Instance.new("TextLabel")
            lblH.BackgroundTransparency = 1
            lblH.Position  = UDim2.new(0, 12, 0, 10)
            lblH.Size      = UDim2.new(1, 0, 0, 12)
            lblH.Text      = "H    S    V"
            lblH.TextColor3 = T.TextMuted
            lblH.Font      = Enum.Font.GothamBold
            lblH.TextSize  = 9
            lblH.LetterSpacing = 2
            lblH.TextXAlignment = Enum.TextXAlignment.Left
            lblH.ZIndex    = PickerFrame.ZIndex + 1
            lblH.Parent    = PickerFrame

            Slider3("H", 26, function() return H end, function(v) H = v end, T.AccentGlow)
            Slider3("S", 48, function() return S end, function(v) S = v end, T.Accent)
            Slider3("V", 70, function() return V_val end, function(v) V_val = v end, T.TextSecondary)

            Preview.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    IsOpen = not IsOpen
                    Utility.Spring(PickerFrame, { Size = IsOpen and UDim2.new(1, 0, 0, 96) or UDim2.new(1, 0, 0, 0) }, 0.4)
                end
            end)

            frame.MouseEnter:Connect(function() Utility.Tween(frame, { BackgroundColor3 = T.ButtonHover }, 0.15) end)
            frame.MouseLeave:Connect(function() Utility.Tween(frame, { BackgroundColor3 = T.SurfaceElevated }, 0.15) end)

            return {
                Frame = frame,
                Get   = function() return Value end,
                Set   = function(v)
                    Value = v
                    H, S, V_val = Color3.toHSV(v)
                    Preview.BackgroundColor3 = v
                end,
            }
        end

        -- --------------------------------------------------------
        -- KEYBIND
        -- --------------------------------------------------------
        function Tab:AddKeybind(cfg)
            cfg = cfg or {}
            local frame   = MakeElementFrame(42)
            local Bound   = cfg.Default or Enum.KeyCode.Unknown
            local Listening = false

            ElementLabel(frame, cfg.Label or "Keybind", 16, 0, 200, 42)

            local KeyBtn = Instance.new("TextButton")
            KeyBtn.AnchorPoint       = Vector2.new(1, 0.5)
            KeyBtn.BackgroundColor3  = T.SurfaceRaised
            KeyBtn.BorderSizePixel   = 0
            KeyBtn.Position          = UDim2.new(1, -12, 0.5, 0)
            KeyBtn.Size              = UDim2.new(0, 90, 0, 26)
            KeyBtn.Text              = Bound == Enum.KeyCode.Unknown and "None" or Bound.Name
            KeyBtn.TextColor3        = T.Accent
            KeyBtn.Font              = Enum.Font.GothamBold
            KeyBtn.TextSize          = 11
            KeyBtn.ZIndex            = frame.ZIndex + 2
            KeyBtn.Parent            = frame
            Utility.Corner(KeyBtn, 6)
            Utility.Stroke(KeyBtn, T.BorderAccent, 1, 0.5)

            KeyBtn.MouseButton1Click:Connect(function()
                if Listening then return end
                Listening = true
                KeyBtn.Text      = "..."
                KeyBtn.TextColor3 = T.Warning
                Utility.Tween(KeyBtn, { BackgroundColor3 = T.Background }, 0.15)
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if not Listening then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    Listening         = false
                    Bound             = input.KeyCode
                    KeyBtn.Text       = input.KeyCode.Name
                    KeyBtn.TextColor3 = T.Accent
                    Utility.Tween(KeyBtn, { BackgroundColor3 = T.SurfaceRaised }, 0.15)
                end
            end)

            -- Listen for bound key (only when not actively rebinding, and not game-processed)
            UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if not Listening and input.KeyCode == Bound and Bound ~= Enum.KeyCode.Unknown then
                    if cfg.Callback then cfg.Callback() end
                end
            end)

            frame.MouseEnter:Connect(function() Utility.Tween(frame, { BackgroundColor3 = T.ButtonHover }, 0.15) end)
            frame.MouseLeave:Connect(function() Utility.Tween(frame, { BackgroundColor3 = T.SurfaceElevated }, 0.15) end)

            return {
                Frame = frame,
                Get   = function() return Bound end,
                Set   = function(k) Bound = k; KeyBtn.Text = k.Name end,
            }
        end

        -- --------------------------------------------------------
        -- SECTION HEADER
        -- --------------------------------------------------------
        function Tab:AddSection(text)
            local frame = Instance.new("Frame")
            frame.BackgroundTransparency = 1
            frame.Size        = UDim2.new(1, 0, 0, 28)
            frame.LayoutOrder = NextOrder()
            frame.ZIndex      = TabPage.ZIndex + 1
            frame.Parent      = TabPage

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Position   = UDim2.new(0, 4, 0, 0)
            lbl.Size       = UDim2.new(1, -8, 1, 0)
            lbl.Text       = string.upper(text)
            lbl.TextColor3 = T.Accent
            lbl.Font       = Enum.Font.GothamBold
            lbl.TextSize   = 9
            lbl.LetterSpacing = 3
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex     = frame.ZIndex + 1
            lbl.Parent     = frame

            -- Accent underline
            local line = Instance.new("Frame")
            line.BackgroundColor3 = T.Accent
            line.BorderSizePixel  = 0
            line.Position         = UDim2.new(0, 0, 1, -2)
            line.Size             = UDim2.new(0, 40, 0, 1)
            line.ZIndex           = frame.ZIndex + 1
            line.Parent           = frame

            return { Frame = frame }
        end

        return Tab
    end

    -- ============================================================
    -- WINDOW METHODS
    -- ============================================================
    function Window:SetTitle(text)
        TitleLabel.Text = text
    end
    function Window:SetSubtitle(text)
        SubtitleLabel.Text = text
    end
    function Window:Destroy()
        Utility.Tween(WindowFrame, {
            Size     = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.45, function() ScreenGui:Destroy() end)
    end

    return Window
end

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
local NotifContainer

local function EnsureNotifContainer()
    if NotifContainer and NotifContainer.Parent then return end

    -- Find or create ScreenGui for notifs
    local sg = Instance.new("ScreenGui")
    sg.Name           = "PhantomUI_Notifications"
    sg.ResetOnSpawn   = false
    sg.DisplayOrder   = 1000
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    NotifContainer = Instance.new("Frame")
    NotifContainer.Name              = "NotifContainer"
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.AnchorPoint       = Vector2.new(1, 1)
    NotifContainer.Position          = UDim2.new(1, -20, 1, -20)
    NotifContainer.Size              = UDim2.new(0, 320, 1, -20)
    NotifContainer.ZIndex            = 100
    NotifContainer.Parent            = sg

    local layout = Instance.new("UIListLayout")
    layout.SortOrder        = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Padding          = UDim.new(0, 8)
    layout.Parent           = NotifContainer
end

function PhantomUI:Notify(cfg)
    cfg = cfg or {}
    local ThemeName = cfg.Theme    or "Obsidian"
    local T         = Themes[ThemeName] or Themes.Obsidian
    local Title     = cfg.Title    or "Notification"
    local Message   = cfg.Message  or ""
    local Duration  = cfg.Duration or 4
    local NType     = cfg.Type     or "Info"

    EnsureNotifContainer()

    NotificationCount = NotificationCount + 1
    local Order = NotificationCount

    local TypeColor = {
        Success = T.Success,
        Error   = T.Error,
        Warning = T.Warning,
        Info    = T.Info,
    }
    local AccentColor = TypeColor[NType] or T.Info

    local TypeIcon = {
        Success = "✓",
        Error   = "✕",
        Warning = "⚠",
        Info    = "ℹ",
    }

    -- Notif frame
    local NFrame = Instance.new("Frame")
    NFrame.BackgroundColor3 = T.SurfaceElevated
    NFrame.BorderSizePixel  = 0
    NFrame.Size             = UDim2.new(1, 0, 0, 0)
    NFrame.ClipsDescendants = true
    NFrame.ZIndex           = 200
    NFrame.LayoutOrder      = Order
    NFrame.Parent           = NotifContainer
    Utility.Corner(NFrame, 10)
    Utility.Stroke(NFrame, T.Border, 1, 0.4)
    Utility.Shadow(NFrame, T)
    Utility.Gradient(NFrame, { {0, T.SurfaceElevated}, {1, T.Surface} }, 90)

    -- Left accent strip
    local Strip = Instance.new("Frame")
    Strip.BackgroundColor3 = AccentColor
    Strip.BorderSizePixel  = 0
    Strip.Size             = UDim2.new(0, 3, 1, 0)
    Strip.ZIndex           = NFrame.ZIndex + 1
    Strip.Parent           = NFrame
    Utility.Corner(Strip, 2)
    Utility.GlowEffect(Strip, AccentColor, 12)

    -- Icon circle
    local IconFrame = Instance.new("Frame")
    IconFrame.BackgroundColor3 = AccentColor
    IconFrame.BackgroundTransparency = 0.85
    IconFrame.BorderSizePixel  = 0
    IconFrame.Position         = UDim2.new(0, 14, 0, 12)
    IconFrame.Size             = UDim2.new(0, 26, 0, 26)
    IconFrame.ZIndex           = NFrame.ZIndex + 1
    IconFrame.Parent           = NFrame
    Utility.Corner(IconFrame, 13)

    local IconLbl = Instance.new("TextLabel")
    IconLbl.BackgroundTransparency = 1
    IconLbl.Size         = UDim2.new(1, 0, 1, 0)
    IconLbl.Text         = TypeIcon[NType] or "ℹ"
    IconLbl.TextColor3   = AccentColor
    IconLbl.Font         = Enum.Font.GothamBold
    IconLbl.TextSize     = 12
    IconLbl.ZIndex       = IconFrame.ZIndex + 1
    IconLbl.Parent       = IconFrame

    -- Title
    local NTitle = Instance.new("TextLabel")
    NTitle.BackgroundTransparency = 1
    NTitle.Position  = UDim2.new(0, 52, 0, 10)
    NTitle.Size      = UDim2.new(1, -70, 0, 16)
    NTitle.Text      = Title
    NTitle.TextColor3 = T.TextPrimary
    NTitle.Font      = Enum.Font.GothamBold
    NTitle.TextSize  = 12
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.ZIndex    = NFrame.ZIndex + 1
    NTitle.Parent    = NFrame

    -- Message
    local NMsg = Instance.new("TextLabel")
    NMsg.BackgroundTransparency = 1
    NMsg.Position    = UDim2.new(0, 52, 0, 28)
    NMsg.Size        = UDim2.new(1, -62, 0, 28)
    NMsg.Text        = Message
    NMsg.TextColor3  = T.TextSecondary
    NMsg.Font        = Enum.Font.Gotham
    NMsg.TextSize    = 11
    NMsg.TextXAlignment = Enum.TextXAlignment.Left
    NMsg.TextWrapped = true
    NMsg.ZIndex      = NFrame.ZIndex + 1
    NMsg.Parent      = NFrame

    -- Progress bar
    local Progress = Instance.new("Frame")
    Progress.BackgroundColor3 = AccentColor
    Progress.BackgroundTransparency = 0.4
    Progress.BorderSizePixel  = 0
    Progress.Position         = UDim2.new(0, 0, 1, -3)
    Progress.Size             = UDim2.new(1, 0, 0, 3)
    Progress.ZIndex           = NFrame.ZIndex + 2
    Progress.Parent           = NFrame
    Utility.Gradient(Progress, { {0, AccentColor}, {1, T.AccentGlow or AccentColor} }, 0)

    -- Close btn
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.AnchorPoint         = Vector2.new(1, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position            = UDim2.new(1, -8, 0, 6)
    CloseBtn.Size                = UDim2.new(0, 20, 0, 20)
    CloseBtn.Text                = "×"
    CloseBtn.TextColor3          = T.TextMuted
    CloseBtn.Font                = Enum.Font.GothamBold
    CloseBtn.TextSize            = 16
    CloseBtn.ZIndex              = NFrame.ZIndex + 3
    CloseBtn.Parent              = NFrame

    local Dismissed = false
    local function Dismiss()
        if Dismissed then return end
        Dismissed = true
        Utility.Tween(NFrame, { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0) }, 0.35, Enum.EasingStyle.Quint)
        Utility.Tween(Strip, { BackgroundTransparency = 1 }, 0.2)
        task.delay(0.4, function()
            NFrame:Destroy()
        end)
    end

    CloseBtn.MouseButton1Click:Connect(Dismiss)

    -- Slide in + expand
    Utility.Spring(NFrame, { Size = UDim2.new(1, 0, 0, 64) }, 0.5)

    -- Animate progress bar
    Utility.Tween(Progress, { Size = UDim2.new(0, 0, 0, 3) }, Duration, Enum.EasingStyle.Linear)

    task.delay(Duration, Dismiss)

    return { Dismiss = Dismiss }
end

-- ============================================================
-- LOADING SCREEN
-- ============================================================
function PhantomUI:LoadingScreen(cfg)
    cfg = cfg or {}
    local ThemeName = cfg.Theme or "Obsidian"
    local T         = Themes[ThemeName] or Themes.Obsidian
    local Title     = cfg.Title   or "Loading"
    local Subtitle  = cfg.Subtitle or "Please wait..."

    local sg = Instance.new("ScreenGui")
    sg.Name         = "PhantomUI_Loader"
    sg.DisplayOrder = 2000
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local Overlay = Instance.new("Frame")
    Overlay.BackgroundColor3 = Color3.new(0,0,0)
    Overlay.BackgroundTransparency = 0
    Overlay.BorderSizePixel  = 0
    Overlay.Size             = UDim2.new(1, 0, 1, 0)
    Overlay.ZIndex           = 10
    Overlay.Parent           = sg

    local Card = Instance.new("Frame")
    Card.AnchorPoint      = Vector2.new(0.5, 0.5)
    Card.BackgroundColor3 = T.Surface
    Card.BorderSizePixel  = 0
    Card.Position         = UDim2.new(0.5, 0, 0.5, 0)
    Card.Size             = UDim2.new(0, 280, 0, 130)
    Card.ZIndex           = 11
    Card.Parent           = sg
    Utility.Corner(Card, 14)
    Utility.Stroke(Card, T.BorderAccent, 1, 0.3)
    Utility.Shadow(Card, T)

    -- Top accent
    local TopLine = Instance.new("Frame")
    TopLine.BackgroundColor3 = T.Accent
    TopLine.BorderSizePixel  = 0
    TopLine.Size             = UDim2.new(1, 0, 0, 2)
    TopLine.ZIndex           = Card.ZIndex + 1
    TopLine.Parent           = Card
    Utility.Gradient(TopLine, { {0,Color3.new(0,0,0)}, {0.5, T.AccentGlow}, {1, Color3.new(0,0,0)} }, 0)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Position   = UDim2.new(0, 0, 0, 18)
    TitleLbl.Size       = UDim2.new(1, 0, 0, 24)
    TitleLbl.Text       = Title
    TitleLbl.TextColor3 = T.TextPrimary
    TitleLbl.Font       = Enum.Font.GothamBold
    TitleLbl.TextSize   = 16
    TitleLbl.ZIndex     = Card.ZIndex + 1
    TitleLbl.Parent     = Card

    local SubLbl = Instance.new("TextLabel")
    SubLbl.BackgroundTransparency = 1
    SubLbl.Position   = UDim2.new(0, 0, 0, 44)
    SubLbl.Size       = UDim2.new(1, 0, 0, 16)
    SubLbl.Text       = Subtitle
    SubLbl.TextColor3 = T.TextSecondary
    SubLbl.Font       = Enum.Font.Gotham
    SubLbl.TextSize   = 12
    SubLbl.ZIndex     = Card.ZIndex + 1
    SubLbl.Parent     = Card

    -- Progress bar track
    local BarBg = Instance.new("Frame")
    BarBg.BackgroundColor3 = T.ToggleOff
    BarBg.BorderSizePixel  = 0
    BarBg.Position         = UDim2.new(0, 24, 0, 82)
    BarBg.Size             = UDim2.new(1, -48, 0, 6)
    BarBg.ZIndex           = Card.ZIndex + 1
    BarBg.Parent           = Card
    Utility.Corner(BarBg, 3)

    local Bar = Instance.new("Frame")
    Bar.BackgroundColor3  = T.Accent
    Bar.BorderSizePixel   = 0
    Bar.Size              = UDim2.new(0, 0, 1, 0)
    Bar.ZIndex            = BarBg.ZIndex + 1
    Bar.Parent            = BarBg
    Utility.Corner(Bar, 3)
    Utility.Gradient(Bar, { {0, T.AccentDim}, {1, T.AccentGlow} }, 0)

    local BarGlow = Utility.GlowEffect(Bar, T.Accent, 10)

    local PercentLbl = Instance.new("TextLabel")
    PercentLbl.BackgroundTransparency = 1
    PercentLbl.Position   = UDim2.new(0, 0, 0, 96)
    PercentLbl.Size       = UDim2.new(1, 0, 0, 16)
    PercentLbl.Text       = "0%"
    PercentLbl.TextColor3 = T.AccentDim
    PercentLbl.Font       = Enum.Font.GothamBold
    PercentLbl.TextSize   = 10
    PercentLbl.ZIndex     = Card.ZIndex + 1
    PercentLbl.Parent     = Card

    local Loader = {
        _gui     = sg,
        _bar     = Bar,
        _percent = PercentLbl,
        _overlay = Overlay,
        _card    = Card,
    }

    function Loader:SetProgress(p)
        p = math.clamp(p, 0, 1)
        Utility.Tween(self._bar, { Size = UDim2.new(p, 0, 1, 0) }, 0.3)
        self._percent.Text = math.floor(p * 100) .. "%"
    end

    function Loader:SetStatus(text)
        SubLbl.Text = text
    end

    function Loader:Finish(delay_)
        self:SetProgress(1)
        task.delay(delay_ or 0.5, function()
            Utility.Tween(self._overlay, { BackgroundTransparency = 1 }, 0.5)
            Utility.Tween(self._card, { BackgroundTransparency = 1 }, 0.5)
            task.delay(0.6, function()
                self._gui:Destroy()
            end)
        end)
    end

    return Loader
end

-- ============================================================
-- THEME UTILITIES
-- ============================================================
function PhantomUI:GetTheme(name)
    return Themes[name] or Themes.Obsidian
end

function PhantomUI:RegisterTheme(name, themeTable)
    Themes[name] = themeTable
end

-- ============================================================
-- RETURN
-- ============================================================
return PhantomUI

--[[
===============================================
  FULL USAGE GUIDE
===============================================

  -- Load the library
  local Phantom = loadstring(game:HttpGet("YOUR_RAW_URL"))()

  -- Loading screen
  local Loader = Phantom:LoadingScreen({
      Title = "MyScript",
      Subtitle = "Initializing modules...",
      Theme = "Obsidian"
  })
  Loader:SetProgress(0.3)
  Loader:SetStatus("Loading assets...")
  Loader:SetProgress(0.7)
  Loader:SetStatus("Finalizing...")
  Loader:SetProgress(1.0)
  Loader:Finish(0.5)

  -- Create window
  local Window = Phantom:CreateWindow({
      Title    = "My Script",
      Subtitle = "v2.0 | Phantom",
      Theme    = "Obsidian",    -- "Obsidian" | "Ivory" | "Crimson"
      Size     = UDim2.new(0, 680, 0, 460),
      MinimizeKey = Enum.KeyCode.RightShift,
  })

  -- Add tabs
  local MainTab  = Window:AddTab("Main")
  local AuraTab  = Window:AddTab("Aura")
  local CfgTab   = Window:AddTab("Config")

  -- Section headers
  MainTab:AddSection("Combat")

  -- Button
  MainTab:AddButton({
      Label    = "Teleport to Waypoint",
      Callback = function()
          print("Teleporting!")
      end,
  })

  -- Toggle
  local speedToggle = MainTab:AddToggle({
      Label    = "Auto Sprint",
      Default  = false,
      Callback = function(value)
          print("Auto Sprint:", value)
      end,
  })
  speedToggle.Set(true)  -- programmatic set

  -- Slider
  local walkSpeed = MainTab:AddSlider({
      Label    = "Walk Speed",
      Min      = 0,
      Max      = 500,
      Default  = 16,
      Suffix   = " st",
      Callback = function(value)
          game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
      end,
  })

  -- Dropdown
  local modeDD = MainTab:AddDropdown({
      Label    = "Attack Mode",
      Options  = { "Silent Aim", "Aimbot", "Off" },
      Default  = "Off",
      Callback = function(selected)
          print("Mode:", selected)
      end,
  })

  -- Textbox
  MainTab:AddTextbox({
      Label       = "Target Player",
      Placeholder = "Username...",
      Callback    = function(text, entered)
          if entered then print("Targeting:", text) end
      end,
  })

  -- Separator
  MainTab:AddSeparator()

  -- Label
  MainTab:AddLabel("Use keybind to toggle the GUI")

  -- Color Picker
  AuraTab:AddColorPicker({
      Label    = "Aura Color",
      Default  = Color3.fromRGB(200, 160, 70),
      Callback = function(color)
          print(color)
      end,
  })

  -- Keybind
  AuraTab:AddKeybind({
      Label    = "Toggle Aura",
      Default  = Enum.KeyCode.E,
      Callback = function()
          print("Aura toggled!")
      end,
  })

  -- Notifications
  Phantom:Notify({
      Title    = "Script Loaded",
      Message  = "All modules initialized successfully.",
      Duration = 5,
      Type     = "Success",   -- "Success" | "Error" | "Warning" | "Info"
      Theme    = "Obsidian",
  })

===============================================
]]
