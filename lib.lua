--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗██╗     ██╗██████╗            ║
║   ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝██║     ██║██╔══██╗           ║
║   ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗██║     ██║██████╔╝           ║
║   ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║██║     ██║██╔══██╗           ║
║   ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║███████╗██║██████╔╝           ║
║   ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚═╝╚═════╝            ║
║                                                                              ║
║   Version: 2.0.0  |  A Premium Roblox UI Library                           ║
║   Features: Themes, Animations, Drag, Resize, Notifications,               ║
║             Sliders, Toggles, Dropdowns, ColorPicker, Keybinds,            ║
║             TextBoxes, Checkboxes, Progress Bars, Tables, Charts,          ║
║             Context Menus, Tooltips, Modals, and much more!                ║
║                                                                              ║
║   Usage:                                                                    ║
║       local NexusLib = loadstring(game:HttpGet("url"))()                   ║
║       local Window = NexusLib:CreateWindow({ Title = "My Script" })        ║
║       local Tab = Window:AddTab("Main")                                     ║
║       Tab:AddButton({ Label = "Click", Callback = function() end })        ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
]]

-- ============================================================
--  LIBRARY ROOT
-- ============================================================
local NexusLib     = {}
NexusLib.__index   = NexusLib
NexusLib.Version   = "2.0.0"
NexusLib._windows  = {}
NexusLib._flags    = {}       -- global flag registry

-- ============================================================
--  SERVICES
-- ============================================================
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local TextService       = game:GetService("TextService")
local HttpService       = game:GetService("HttpService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()
local Camera      = workspace.CurrentCamera

-- ============================================================
--  CONSTANTS
-- ============================================================
local FONT_BOLD     = Enum.Font.GothamBold
local FONT_SEMI     = Enum.Font.GothamSemibold
local FONT_REG      = Enum.Font.Gotham
local FONT_MONO     = Enum.Font.Code
local EASE_OUT      = Enum.EasingDirection.Out
local EASE_IN       = Enum.EasingDirection.In
local EASE_INOUT    = Enum.EasingDirection.InOut
local STYLE_QUART   = Enum.EasingStyle.Quart
local STYLE_BACK    = Enum.EasingStyle.Back
local STYLE_SPRING  = Enum.EasingStyle.Elastic
local STYLE_BOUNCE  = Enum.EasingStyle.Bounce
local STYLE_CIRC    = Enum.EasingStyle.Circular
local STYLE_EXPO    = Enum.EasingStyle.Exponential
local STYLE_SINE    = Enum.EasingStyle.Sine
local STYLE_CUBIC   = Enum.EasingStyle.Cubic
local STYLE_LINEAR  = Enum.EasingStyle.Linear

-- ============================================================
--  THEME SYSTEM
-- ============================================================
local Themes = {}

Themes.Dark = {
    Name          = "Dark",
    Background    = Color3.fromRGB(13,  13,  18),
    Surface       = Color3.fromRGB(20,  20,  28),
    Panel         = Color3.fromRGB(26,  26,  36),
    Card          = Color3.fromRGB(32,  32,  46),
    CardHover     = Color3.fromRGB(40,  40,  58),
    Accent        = Color3.fromRGB(99,  102, 241),
    AccentHover   = Color3.fromRGB(129, 132, 255),
    AccentDim     = Color3.fromRGB(55,  58,  140),
    AccentGlow    = Color3.fromRGB(60,  63,  160),
    Text          = Color3.fromRGB(240, 240, 255),
    TextSub       = Color3.fromRGB(190, 190, 215),
    TextMuted     = Color3.fromRGB(130, 130, 165),
    TextDim       = Color3.fromRGB(75,  75,  100),
    Success       = Color3.fromRGB(52,  211, 153),
    SuccessDim    = Color3.fromRGB(20,  90,  65),
    Warning       = Color3.fromRGB(251, 191, 36),
    WarningDim    = Color3.fromRGB(110, 80,  10),
    Danger        = Color3.fromRGB(248, 113, 113),
    DangerDim     = Color3.fromRGB(110, 35,  35),
    Info          = Color3.fromRGB(96,  165, 250),
    InfoDim       = Color3.fromRGB(35,  65,  120),
    Border        = Color3.fromRGB(45,  45,  65),
    BorderLight   = Color3.fromRGB(60,  60,  85),
    Toggle        = Color3.fromRGB(99,  102, 241),
    ToggleOff     = Color3.fromRGB(45,  45,  65),
    Scrollbar     = Color3.fromRGB(55,  55,  80),
    InputBg       = Color3.fromRGB(18,  18,  26),
    TitleBar      = Color3.fromRGB(18,  18,  26),
    Sidebar       = Color3.fromRGB(18,  18,  26),
    Shadow        = Color3.fromRGB(0,   0,   0),
    White         = Color3.new(1, 1, 1),
}

Themes.Ocean = {
    Name          = "Ocean",
    Background    = Color3.fromRGB(6,   18,  32),
    Surface       = Color3.fromRGB(10,  26,  46),
    Panel         = Color3.fromRGB(14,  34,  58),
    Card          = Color3.fromRGB(18,  42,  70),
    CardHover     = Color3.fromRGB(24,  52,  84),
    Accent        = Color3.fromRGB(56,  189, 248),
    AccentHover   = Color3.fromRGB(100, 210, 255),
    AccentDim     = Color3.fromRGB(25,  100, 165),
    AccentGlow    = Color3.fromRGB(20,  80,  140),
    Text          = Color3.fromRGB(220, 240, 255),
    TextSub       = Color3.fromRGB(170, 205, 240),
    TextMuted     = Color3.fromRGB(110, 160, 210),
    TextDim       = Color3.fromRGB(55,  100, 150),
    Success       = Color3.fromRGB(52,  211, 153),
    SuccessDim    = Color3.fromRGB(15,  80,  60),
    Warning       = Color3.fromRGB(251, 191, 36),
    WarningDim    = Color3.fromRGB(100, 75,  10),
    Danger        = Color3.fromRGB(248, 113, 113),
    DangerDim     = Color3.fromRGB(100, 35,  35),
    Info          = Color3.fromRGB(56,  189, 248),
    InfoDim       = Color3.fromRGB(20,  75,  130),
    Border        = Color3.fromRGB(25,  55,  90),
    BorderLight   = Color3.fromRGB(35,  70,  110),
    Toggle        = Color3.fromRGB(56,  189, 248),
    ToggleOff     = Color3.fromRGB(22,  50,  80),
    Scrollbar     = Color3.fromRGB(35,  75,  120),
    InputBg       = Color3.fromRGB(8,   22,  38),
    TitleBar      = Color3.fromRGB(8,   22,  38),
    Sidebar       = Color3.fromRGB(8,   22,  38),
    Shadow        = Color3.new(0, 0, 0),
    White         = Color3.new(1, 1, 1),
}

Themes.Crimson = {
    Name          = "Crimson",
    Background    = Color3.fromRGB(16,  6,   8),
    Surface       = Color3.fromRGB(26,  10,  14),
    Panel         = Color3.fromRGB(34,  13,  18),
    Card          = Color3.fromRGB(44,  16,  22),
    CardHover     = Color3.fromRGB(56,  20,  28),
    Accent        = Color3.fromRGB(244, 63,  94),
    AccentHover   = Color3.fromRGB(255, 100, 128),
    AccentDim     = Color3.fromRGB(150, 28,  50),
    AccentGlow    = Color3.fromRGB(120, 22,  40),
    Text          = Color3.fromRGB(255, 232, 236),
    TextSub       = Color3.fromRGB(220, 180, 190),
    TextMuted     = Color3.fromRGB(180, 120, 135),
    TextDim       = Color3.fromRGB(110, 60,  75),
    Success       = Color3.fromRGB(52,  211, 153),
    SuccessDim    = Color3.fromRGB(16,  75,  55),
    Warning       = Color3.fromRGB(251, 191, 36),
    WarningDim    = Color3.fromRGB(100, 75,  10),
    Danger        = Color3.fromRGB(248, 113, 113),
    DangerDim     = Color3.fromRGB(110, 35,  35),
    Info          = Color3.fromRGB(96,  165, 250),
    InfoDim       = Color3.fromRGB(30,  60,  120),
    Border        = Color3.fromRGB(65,  22,  32),
    BorderLight   = Color3.fromRGB(85,  30,  44),
    Toggle        = Color3.fromRGB(244, 63,  94),
    ToggleOff     = Color3.fromRGB(60,  18,  28),
    Scrollbar     = Color3.fromRGB(85,  28,  42),
    InputBg       = Color3.fromRGB(12,  5,   7),
    TitleBar      = Color3.fromRGB(12,  5,   7),
    Sidebar       = Color3.fromRGB(12,  5,   7),
    Shadow        = Color3.new(0, 0, 0),
    White         = Color3.new(1, 1, 1),
}

Themes.Emerald = {
    Name          = "Emerald",
    Background    = Color3.fromRGB(6,   18,  12),
    Surface       = Color3.fromRGB(10,  26,  18),
    Panel         = Color3.fromRGB(14,  34,  24),
    Card          = Color3.fromRGB(18,  44,  30),
    CardHover     = Color3.fromRGB(24,  56,  38),
    Accent        = Color3.fromRGB(52,  211, 153),
    AccentHover   = Color3.fromRGB(90,  235, 180),
    AccentDim     = Color3.fromRGB(22,  95,  68),
    AccentGlow    = Color3.fromRGB(16,  75,  52),
    Text          = Color3.fromRGB(220, 255, 240),
    TextSub       = Color3.fromRGB(170, 225, 200),
    TextMuted     = Color3.fromRGB(110, 175, 145),
    TextDim       = Color3.fromRGB(55,  110, 80),
    Success       = Color3.fromRGB(52,  211, 153),
    SuccessDim    = Color3.fromRGB(16,  80,  55),
    Warning       = Color3.fromRGB(251, 191, 36),
    WarningDim    = Color3.fromRGB(100, 75,  10),
    Danger        = Color3.fromRGB(248, 113, 113),
    DangerDim     = Color3.fromRGB(105, 35,  35),
    Info          = Color3.fromRGB(96,  165, 250),
    InfoDim       = Color3.fromRGB(30,  60,  115),
    Border        = Color3.fromRGB(22,  55,  38),
    BorderLight   = Color3.fromRGB(32,  75,  52),
    Toggle        = Color3.fromRGB(52,  211, 153),
    ToggleOff     = Color3.fromRGB(18,  50,  35),
    Scrollbar     = Color3.fromRGB(32,  80,  55),
    InputBg       = Color3.fromRGB(5,   14,  10),
    TitleBar      = Color3.fromRGB(5,   14,  10),
    Sidebar       = Color3.fromRGB(5,   14,  10),
    Shadow        = Color3.new(0, 0, 0),
    White         = Color3.new(1, 1, 1),
}

Themes.Violet = {
    Name          = "Violet",
    Background    = Color3.fromRGB(10,  6,   22),
    Surface       = Color3.fromRGB(16,  10,  34),
    Panel         = Color3.fromRGB(22,  14,  46),
    Card          = Color3.fromRGB(28,  18,  58),
    CardHover     = Color3.fromRGB(36,  24,  72),
    Accent        = Color3.fromRGB(167, 139, 250),
    AccentHover   = Color3.fromRGB(196, 173, 255),
    AccentDim     = Color3.fromRGB(85,  65,  165),
    AccentGlow    = Color3.fromRGB(65,  45,  135),
    Text          = Color3.fromRGB(240, 235, 255),
    TextSub       = Color3.fromRGB(200, 190, 245),
    TextMuted     = Color3.fromRGB(150, 135, 210),
    TextDim       = Color3.fromRGB(90,  78,  145),
    Success       = Color3.fromRGB(52,  211, 153),
    SuccessDim    = Color3.fromRGB(16,  80,  55),
    Warning       = Color3.fromRGB(251, 191, 36),
    WarningDim    = Color3.fromRGB(100, 75,  10),
    Danger        = Color3.fromRGB(248, 113, 113),
    DangerDim     = Color3.fromRGB(105, 35,  35),
    Info          = Color3.fromRGB(167, 139, 250),
    InfoDim       = Color3.fromRGB(60,  45,  130),
    Border        = Color3.fromRGB(45,  30,  90),
    BorderLight   = Color3.fromRGB(60,  42,  118),
    Toggle        = Color3.fromRGB(167, 139, 250),
    ToggleOff     = Color3.fromRGB(38,  25,  78),
    Scrollbar     = Color3.fromRGB(60,  42,  110),
    InputBg       = Color3.fromRGB(8,   5,   18),
    TitleBar      = Color3.fromRGB(8,   5,   18),
    Sidebar       = Color3.fromRGB(8,   5,   18),
    Shadow        = Color3.new(0, 0, 0),
    White         = Color3.new(1, 1, 1),
}

Themes.Light = {
    Name          = "Light",
    Background    = Color3.fromRGB(248, 249, 252),
    Surface       = Color3.fromRGB(255, 255, 255),
    Panel         = Color3.fromRGB(244, 245, 250),
    Card          = Color3.fromRGB(250, 251, 255),
    CardHover     = Color3.fromRGB(238, 240, 252),
    Accent        = Color3.fromRGB(79,  82,  228),
    AccentHover   = Color3.fromRGB(60,  63,  200),
    AccentDim     = Color3.fromRGB(190, 192, 255),
    AccentGlow    = Color3.fromRGB(205, 207, 255),
    Text          = Color3.fromRGB(18,  18,  38),
    TextSub       = Color3.fromRGB(60,  60,  100),
    TextMuted     = Color3.fromRGB(110, 110, 155),
    TextDim       = Color3.fromRGB(165, 165, 200),
    Success       = Color3.fromRGB(16,  185, 129),
    SuccessDim    = Color3.fromRGB(200, 250, 235),
    Warning       = Color3.fromRGB(217, 119, 6),
    WarningDim    = Color3.fromRGB(255, 245, 210),
    Danger        = Color3.fromRGB(220, 38,  38),
    DangerDim     = Color3.fromRGB(255, 220, 220),
    Info          = Color3.fromRGB(59,  130, 246),
    InfoDim       = Color3.fromRGB(220, 235, 255),
    Border        = Color3.fromRGB(218, 220, 240),
    BorderLight   = Color3.fromRGB(200, 202, 228),
    Toggle        = Color3.fromRGB(79,  82,  228),
    ToggleOff     = Color3.fromRGB(200, 202, 225),
    Scrollbar     = Color3.fromRGB(190, 192, 222),
    InputBg       = Color3.fromRGB(242, 244, 255),
    TitleBar      = Color3.fromRGB(240, 242, 255),
    Sidebar       = Color3.fromRGB(240, 242, 255),
    Shadow        = Color3.fromRGB(80, 80, 120),
    White         = Color3.new(1, 1, 1),
}

NexusLib.Themes = Themes

-- ============================================================
--  ICON SYSTEM  (Unicode / rbxassetid fallback)
-- ============================================================
local Icons = {
    Close      = "✕",
    Minimize   = "─",
    Maximize   = "□",
    Search     = "⌕",
    Settings   = "⚙",
    Home       = "⌂",
    Star       = "★",
    Heart      = "♥",
    Check      = "✓",
    Cross      = "✗",
    Arrow      = "›",
    ArrowBack  = "‹",
    ArrowUp    = "↑",
    ArrowDown  = "↓",
    Chevron    = "⌄",
    ChevronUp  = "⌃",
    Dot        = "•",
    Info       = "ℹ",
    Warn       = "⚠",
    Lock       = "🔒",
    Unlock     = "🔓",
    Eye        = "👁",
    Trash      = "🗑",
    Edit       = "✎",
    Copy       = "⎘",
    Refresh    = "↺",
    Plus       = "+",
    Minus      = "−",
    Menu       = "≡",
    Grid       = "⊞",
    List       = "≣",
    Tag        = "⊞",
    Bell       = "🔔",
    Pin        = "📌",
    Link       = "🔗",
    Image      = "🖼",
    Code       = "</>",
    Play       = "▶",
    Pause      = "⏸",
    Stop       = "■",
    Record     = "⏺",
    Upload     = "⬆",
    Download   = "⬇",
    Folder     = "📁",
    File       = "📄",
    Drag       = "⠿",
    Resize     = "⤢",
}

NexusLib.Icons = Icons

-- ============================================================
--  CORE UTILITY FUNCTIONS
-- ============================================================

--- Create a TweenInfo and play a tween on an object
---@param obj Instance
---@param props table
---@param duration number
---@param style Enum.EasingStyle
---@param direction Enum.EasingDirection
---@param repeatCount number
---@param reverses boolean
---@param delay number
---@return Tween
local function Tween(obj, props, duration, style, direction, repeatCount, reverses, delay)
    style       = style       or STYLE_QUART
    direction   = direction   or EASE_OUT
    repeatCount = repeatCount or 0
    reverses    = reverses    or false
    delay       = delay       or 0
    local info  = TweenInfo.new(duration or 0.25, style, direction, repeatCount, reverses, delay)
    local t     = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

--- Wait for a tween to finish then call callback
local function TweenCallback(obj, props, duration, style, direction, cb)
    local t = Tween(obj, props, duration, style, direction)
    t.Completed:Connect(function() if cb then cb() end end)
    return t
end

--- Create UICorner
local function MakeRound(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
    return c
end

--- Create UIPadding
local function MakePadding(obj, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 6)
    p.PaddingBottom = UDim.new(0, b or 6)
    p.PaddingLeft   = UDim.new(0, l or 10)
    p.PaddingRight  = UDim.new(0, r or 10)
    p.Parent = obj
    return p
end

--- Create UIStroke
local function MakeStroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color        = color        or Color3.new(1,1,1)
    s.Thickness    = thickness    or 1
    s.Transparency = transparency or 0.8
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

--- Create UIGradient
local function MakeGradient(obj, colorSeq, rotation)
    local g = Instance.new("UIGradient")
    g.Color    = colorSeq or ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(0,0,0)),
    })
    g.Rotation = rotation or 0
    g.Parent   = obj
    return g
end

--- Create UIListLayout
local function MakeListLayout(parent, order, padding, alignment, hAlign)
    local l = Instance.new("UIListLayout")
    l.SortOrder         = order     or Enum.SortOrder.LayoutOrder
    l.Padding           = padding   or UDim.new(0, 4)
    l.VerticalAlignment = alignment or Enum.VerticalAlignment.Top
    if hAlign then l.HorizontalAlignment = hAlign end
    l.Parent = parent
    return l
end

--- Create UIGridLayout
local function MakeGridLayout(parent, cellSize, cellPadding, cols)
    local g = Instance.new("UIGridLayout")
    g.CellSize        = cellSize   or UDim2.new(0, 100, 0, 100)
    g.CellPaddingSize = cellPadding or UDim2.new(0, 4, 0, 4)
    if cols then g.FillDirectionMaxCells = cols end
    g.SortOrder = Enum.SortOrder.LayoutOrder
    g.Parent = parent
    return g
end

--- Generic Frame factory
local function NewFrame(parent, size, pos, color, name, transparency)
    local f = Instance.new("Frame")
    f.Size              = size        or UDim2.new(1,0,0,40)
    f.Position          = pos         or UDim2.new(0,0,0,0)
    f.BackgroundColor3  = color       or Color3.new(0,0,0)
    f.BackgroundTransparency = transparency or 0
    f.BorderSizePixel   = 0
    f.Name              = name        or "Frame"
    f.Parent            = parent
    return f
end

--- TextLabel factory
local function NewLabel(parent, text, size, color, name, font, textSize, xAlign)
    local l = Instance.new("TextLabel")
    l.Size                   = size     or UDim2.new(1,0,1,0)
    l.Position               = UDim2.new(0,0,0,0)
    l.BackgroundTransparency = 1
    l.Text                   = text     or ""
    l.TextColor3             = color    or Color3.new(1,1,1)
    l.Font                   = font     or FONT_REG
    l.TextSize               = textSize or 13
    l.TextXAlignment         = xAlign   or Enum.TextXAlignment.Left
    l.TextTruncate           = Enum.TextTruncate.AtEnd
    l.Name                   = name     or "Label"
    l.Parent                 = parent
    return l
end

--- TextButton factory (invisible, used as hit-area)
local function NewButton(parent, size, pos, color, name, transparency)
    local b = Instance.new("TextButton")
    b.Size                   = size        or UDim2.new(1,0,0,36)
    b.Position               = pos         or UDim2.new(0,0,0,0)
    b.BackgroundColor3       = color       or Color3.new(0.2,0.2,0.2)
    b.BackgroundTransparency = transparency or 0
    b.BorderSizePixel        = 0
    b.Text                   = ""
    b.AutoButtonColor        = false
    b.Name                   = name        or "Button"
    b.Parent                 = parent
    return b
end

--- ImageLabel factory
local function NewImage(parent, asset, size, pos, name, color)
    local img = Instance.new("ImageLabel")
    img.Size                   = size  or UDim2.new(0,16,0,16)
    img.Position               = pos   or UDim2.new(0,0,0,0)
    img.BackgroundTransparency = 1
    img.Image                  = asset or ""
    img.ImageColor3            = color or Color3.new(1,1,1)
    img.ScaleType              = Enum.ScaleType.Fit
    img.Name                   = name  or "Icon"
    img.Parent                 = parent
    return img
end

--- ScrollingFrame factory
local function NewScroll(parent, size, pos, barColor, name)
    local s = Instance.new("ScrollingFrame")
    s.Size                   = size    or UDim2.new(1,0,1,0)
    s.Position               = pos     or UDim2.new(0,0,0,0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel        = 0
    s.ScrollBarThickness     = 4
    s.ScrollBarImageColor3   = barColor or Color3.fromRGB(80,80,100)
    s.CanvasSize             = UDim2.new(0,0,0,0)
    s.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    s.ScrollingDirection     = Enum.ScrollingDirection.Y
    s.ElasticBehavior        = Enum.ElasticBehavior.Never
    s.Name                   = name    or "Scroll"
    s.Parent                 = parent
    return s
end

--- Ripple effect on a button
local function SpawnRipple(btn, T, x, y)
    local ripple = NewFrame(btn, UDim2.new(0,0,0,0),
        UDim2.new(0, x - btn.AbsolutePosition.X, 0, y - btn.AbsolutePosition.Y),
        T.White, "Ripple")
    ripple.ZIndex = btn.ZIndex + 5
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundTransparency = 0.7
    MakeRound(ripple, 999)
    local size = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.5
    Tween(ripple, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.5, STYLE_QUART, EASE_OUT)
    task.delay(0.5, function() ripple:Destroy() end)
end

--- Glow pulse effect
local function PulseGlow(frame, color, duration)
    local orig = frame.BackgroundColor3
    Tween(frame, {BackgroundColor3 = color}, duration/2, STYLE_SINE, EASE_OUT)
    task.delay(duration/2, function()
        Tween(frame, {BackgroundColor3 = orig}, duration/2, STYLE_SINE, EASE_IN)
    end)
end

-- ============================================================
--  DRAGGING SYSTEM (Improved with bounds)
-- ============================================================
local function MakeDraggable(handle, target, onDrag)
    local dragging  = false
    local dragInput = nil
    local dragStart = nil
    local startPos  = nil

    local function Update(input)
        local delta = input.Position - dragStart
        local newX  = math.clamp(startPos.X.Offset + delta.X, 0, Camera.ViewportSize.X - target.AbsoluteSize.X)
        local newY  = math.clamp(startPos.Y.Offset + delta.Y, 0, Camera.ViewportSize.Y - target.AbsoluteSize.Y)
        target.Position = UDim2.new(0, newX, 0, newY)
        if onDrag then onDrag(newX, newY) end
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)
end

-- ============================================================
--  RESIZE SYSTEM
-- ============================================================
local function MakeResizable(handle, target, minW, minH, onResize)
    minW = minW or 300
    minH = minH or 200
    local resizing = false
    local startPos = nil
    local startSize = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing  = true
            startPos  = input.Position
            startSize = target.AbsoluteSize
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startPos
            local newW  = math.max(startSize.X + delta.X, minW)
            local newH  = math.max(startSize.Y + delta.Y, minH)
            target.Size = UDim2.new(0, newW, 0, newH)
            if onResize then onResize(newW, newH) end
        end
    end)
end

-- ============================================================
--  TOOLTIP SYSTEM
-- ============================================================
local TooltipFrame = nil

local function EnsureTooltip(T)
    if TooltipFrame and TooltipFrame.Parent then return end
    local sg = Instance.new("ScreenGui")
    sg.Name           = "NexusTooltips"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 998
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end

    local f = NewFrame(sg, UDim2.new(0,0,0,0), UDim2.new(0,0,0,0), T.Panel, "Tooltip")
    f.AutomaticSize          = Enum.AutomaticSize.XY
    f.BackgroundTransparency = 1
    f.ZIndex = 999
    MakeRound(f, 6)
    MakeStroke(f, T.Border, 1, 0.5)

    local lbl = NewLabel(f, "", UDim2.new(0,0,0,0), T.Text, "Tip", FONT_REG, 11)
    lbl.AutomaticSize = Enum.AutomaticSize.XY
    MakePadding(lbl, 5, 5, 8, 8)
    TooltipFrame = f
end

local function AttachTooltip(element, text, T)
    EnsureTooltip(T)
    local lbl = TooltipFrame:FindFirstChild("Tip")
    element.MouseEnter:Connect(function()
        if lbl then lbl.Text = text end
        TooltipFrame.BackgroundTransparency = 0
        TooltipFrame.Visible = true
    end)
    element.MouseLeave:Connect(function()
        TooltipFrame.Visible = false
    end)
    RunService.RenderStepped:Connect(function()
        if TooltipFrame.Visible then
            local pos = UserInputService:GetMouseLocation()
            TooltipFrame.Position = UDim2.new(0, pos.X + 14, 0, pos.Y - 4)
        end
    end)
end

-- ============================================================
--  NOTIFICATION SYSTEM  (Enhanced)
-- ============================================================
local NotifHolder = nil
local NotifCount  = 0

local function EnsureNotifHolder()
    if NotifHolder and NotifHolder.Parent then return end
    local sg = Instance.new("ScreenGui")
    sg.Name            = "NexusNotifs"
    sg.ResetOnSpawn    = false
    sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder    = 1000
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end

    local holder = NewFrame(sg, UDim2.new(0,300,1,0), UDim2.new(1,-310,0,0), Color3.new(0,0,0), "Holder", 1)
    MakeListLayout(holder, Enum.SortOrder.LayoutOrder, UDim.new(0,6), Enum.VerticalAlignment.Bottom)
    MakePadding(holder, 12, 12, 0, 0)
    NotifHolder = holder
end

--- Show a notification toast
---@param opts table { Title, Message, Duration, Type, Theme }
function NexusLib:Notify(opts)
    opts = opts or {}
    local title    = opts.Title    or "Notification"
    local message  = opts.Message  or ""
    local duration = opts.Duration or 5
    local ntype    = opts.Type     or "Info"
    local themeName = opts.Theme   or "Dark"
    local T        = Themes[themeName] or Themes.Dark

    EnsureNotifHolder()
    NotifCount += 1

    local typeData = {
        Info    = { color = T.Info,    bg = T.InfoDim,    icon = Icons.Info  .. " " },
        Success = { color = T.Success, bg = T.SuccessDim, icon = Icons.Check .. " " },
        Warning = { color = T.Warning, bg = T.WarningDim, icon = Icons.Warn  .. " " },
        Error   = { color = T.Danger,  bg = T.DangerDim,  icon = Icons.Cross .. " " },
    }
    local td = typeData[ntype] or typeData.Info

    -- Card
    local card = NewFrame(NotifHolder, UDim2.new(1,0,0,0), nil, T.Panel, "Notif_" .. NotifCount)
    card.AutomaticSize          = Enum.AutomaticSize.Y
    card.ClipsDescendants       = true
    card.LayoutOrder            = NotifCount
    MakeRound(card, 10)
    MakeStroke(card, T.Border, 1, 0.4)

    -- Colored left accent bar
    local bar = NewFrame(card, UDim2.new(0,4,1,0), UDim2.new(0,0,0,0), td.color, "Bar")
    MakeRound(bar, 3)

    -- Icon badge
    local badge = NewFrame(card, UDim2.new(0,32,0,32), UDim2.new(0,12,0,10), td.bg, "Badge")
    MakeRound(badge, 8)
    local iconLbl = NewLabel(badge, td.icon, UDim2.new(1,0,1,0), td.color, "Icon", FONT_BOLD, 14, Enum.TextXAlignment.Center)

    -- Text container
    local textBox = NewFrame(card, UDim2.new(1,-64,0,0), UDim2.new(0,52,0,0), T.Panel, "TextBox")
    textBox.AutomaticSize = Enum.AutomaticSize.Y
    MakePadding(textBox, 10, 10, 0, 10)
    MakeListLayout(textBox, Enum.SortOrder.LayoutOrder, UDim.new(0, 2))

    local titleLbl = NewLabel(textBox, title, UDim2.new(1,0,0,16), T.Text, "Title", FONT_BOLD, 13)
    titleLbl.LayoutOrder = 1

    if message ~= "" then
        local msgLbl = NewLabel(textBox, message, UDim2.new(1,0,0,0), T.TextMuted, "Msg", FONT_REG, 11)
        msgLbl.AutomaticSize = Enum.AutomaticSize.Y
        msgLbl.TextWrapped   = true
        msgLbl.LayoutOrder   = 2
    end

    -- Close button
    local closeBtn = NewButton(card, UDim2.new(0,20,0,20), UDim2.new(1,-24,0,8), T.Card, "CloseBtn")
    MakeRound(closeBtn, 5)
    local closeLbl = NewLabel(closeBtn, Icons.Close, UDim2.new(1,0,1,0), T.TextMuted, "X", FONT_BOLD, 10, Enum.TextXAlignment.Center)

    -- Progress bar
    local progressBg = NewFrame(card, UDim2.new(1,0,0,3), UDim2.new(0,0,1,-3), T.Card, "ProgressBg")
    local progress   = NewFrame(progressBg, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), td.color, "Progress")
    progress.BackgroundTransparency = 0.4
    MakeRound(progress, 1)

    -- Animate in: slide from right
    card.Position = UDim2.new(1,0,0,0)
    Tween(card, {Position = UDim2.new(0,0,0,0)}, 0.35, STYLE_BACK, EASE_OUT)
    Tween(progress, {Size = UDim2.new(0,0,1,0)}, duration, STYLE_LINEAR, EASE_IN)

    local function DismissNotif()
        Tween(card, {Position = UDim2.new(1,20,0,0), BackgroundTransparency = 1}, 0.3, STYLE_QUART, EASE_IN)
        task.wait(0.3)
        card:Destroy()
    end

    closeBtn.MouseButton1Click:Connect(DismissNotif)
    task.delay(duration, DismissNotif)
end

-- ============================================================
--  CONTEXT MENU  (right-click menus)
-- ============================================================
local ContextMenuFrame = nil

local function ShowContextMenu(items, T, x, y)
    if ContextMenuFrame then ContextMenuFrame:Destroy() end

    local sg = LocalPlayer.PlayerGui:FindFirstChild("NexusContext")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "NexusContext"
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.DisplayOrder = 997
        pcall(function() sg.Parent = CoreGui end)
        if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end
    end

    local menu = NewFrame(sg, UDim2.new(0, 160, 0, 0), UDim2.new(0, x, 0, y), T.Panel, "ContextMenu")
    menu.AutomaticSize = Enum.AutomaticSize.Y
    menu.ClipsDescendants = true
    MakeRound(menu, 8)
    MakeStroke(menu, T.Border, 1, 0.4)
    MakePadding(menu, 4, 4, 4, 4)
    MakeListLayout(menu, Enum.SortOrder.LayoutOrder, UDim.new(0, 2))

    -- Keep menu on screen
    menu.Position = UDim2.new(0, math.min(x, Camera.ViewportSize.X - 164), 0, y)

    for i, item in ipairs(items) do
        if item.Separator then
            local sep = NewFrame(menu, UDim2.new(1,-8,0,1), nil, T.Border, "Sep")
            sep.BackgroundTransparency = 0.5
            sep.LayoutOrder = i
        else
            local btn = NewButton(menu, UDim2.new(1,0,0,28), nil, T.Panel, "Item" .. i)
            btn.LayoutOrder = i
            MakeRound(btn, 5)
            MakePadding(btn, 0, 0, 8, 8)

            if item.Icon then
                local icon = NewLabel(btn, item.Icon, UDim2.new(0,18,1,0), item.Color or T.TextMuted, "Icon", FONT_REG, 12, Enum.TextXAlignment.Center)
            end
            local offset = item.Icon and 22 or 0
            local lbl = NewLabel(btn, item.Label or "Item", UDim2.new(1,-offset,1,0), item.Color or T.Text, "Lbl", FONT_SEMI, 12)
            lbl.Position = UDim2.new(0, offset, 0, 0)

            btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = T.CardHover}, 0.1) end)
            btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = T.Panel},     0.1) end)
            btn.MouseButton1Click:Connect(function()
                menu:Destroy()
                if item.Callback then item.Callback() end
            end)
        end
    end

    ContextMenuFrame = menu

    -- Dismiss on outside click
    local conn
    conn = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            task.wait()
            if menu and menu.Parent then
                menu:Destroy()
            end
            conn:Disconnect()
        end
    end)
end

-- ============================================================
--  MODAL  (Dialog / Prompt)
-- ============================================================
local function ShowModal(opts, T, parent)
    opts = opts or {}
    local title   = opts.Title   or "Dialog"
    local message = opts.Message or ""
    local buttons = opts.Buttons or {{ Label = "OK", Callback = function() end }}
    local width   = opts.Width   or 320
    local icon    = opts.Icon    or ""
    local iconColor = opts.IconColor or T.Accent

    local sg = Instance.new("ScreenGui")
    sg.Name = "NexusModal"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 995
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end

    -- Overlay backdrop
    local overlay = NewFrame(sg, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), T.Shadow, "Overlay", 0.5)

    -- Modal card
    local modal = NewFrame(sg, UDim2.new(0, width, 0, 0), UDim2.new(0.5, -width/2, 0.5, -100), T.Panel, "Modal")
    modal.AutomaticSize = Enum.AutomaticSize.Y
    MakeRound(modal, 12)
    MakeStroke(modal, T.Border, 1, 0.4)
    MakePadding(modal, 24, 24, 24, 24)

    -- Entry animation
    modal.BackgroundTransparency = 1
    modal.Position = UDim2.new(0.5, -width/2, 0.5, -60)
    Tween(modal, {BackgroundTransparency = 0, Position = UDim2.new(0.5, -width/2, 0.5, -100)}, 0.3, STYLE_BACK, EASE_OUT)

    local layout = MakeListLayout(modal, Enum.SortOrder.LayoutOrder, UDim.new(0, 12))

    -- Icon (optional)
    if icon ~= "" then
        local iconFrame = NewFrame(modal, UDim2.new(0,48,0,48), nil, iconColor .. "20" or T.AccentDim, "IconFrame")
        -- Can't do hex on color, use AccentDim
        iconFrame.BackgroundColor3 = T.AccentDim
        iconFrame.LayoutOrder = 1
        MakeRound(iconFrame, 24)
        local iconLbl = NewLabel(iconFrame, icon, UDim2.new(1,0,1,0), iconColor, "Icon", FONT_BOLD, 22, Enum.TextXAlignment.Center)
        iconFrame.Parent = modal -- ensure it's inside padded modal
    end

    -- Title
    local titleLbl = NewLabel(modal, title, UDim2.new(1,0,0,22), T.Text, "Title", FONT_BOLD, 16)
    titleLbl.LayoutOrder = 2

    -- Message
    if message ~= "" then
        local msgLbl = NewLabel(modal, message, UDim2.new(1,0,0,0), T.TextMuted, "Msg", FONT_REG, 13)
        msgLbl.TextWrapped   = true
        msgLbl.AutomaticSize = Enum.AutomaticSize.Y
        msgLbl.LayoutOrder   = 3
    end

    -- Buttons row
    local btnRow = NewFrame(modal, UDim2.new(1,0,0,36), nil, T.Panel, "BtnRow")
    btnRow.BackgroundTransparency = 1
    btnRow.LayoutOrder = 4
    local btnLayout = MakeListLayout(btnRow, Enum.SortOrder.LayoutOrder, UDim.new(0, 8), Enum.VerticalAlignment.Top, Enum.HorizontalAlignment.Right)
    btnLayout.FillDirection = Enum.FillDirection.Horizontal

    local function CloseModal()
        Tween(modal,   {BackgroundTransparency = 1, Position = UDim2.new(0.5, -width/2, 0.5, -80)}, 0.25)
        Tween(overlay, {BackgroundTransparency = 1}, 0.25)
        task.delay(0.25, function() sg:Destroy() end)
    end

    for i, btn in ipairs(buttons) do
        local btnFr = NewButton(btnRow, UDim2.new(0, 0, 1, 0), nil, btn.Primary and T.Accent or T.Card, "Btn" .. i)
        btnFr.AutomaticSize = Enum.AutomaticSize.X
        btnFr.LayoutOrder   = i
        MakeRound(btnFr, 7)
        MakePadding(btnFr, 0, 0, 16, 16)
        local bLbl = NewLabel(btnFr, btn.Label or "OK", UDim2.new(0,0,1,0), btn.Primary and T.White or T.Text, "L", FONT_SEMI, 13)
        bLbl.AutomaticSize = Enum.AutomaticSize.X
        bLbl.TextXAlignment = Enum.TextXAlignment.Center

        btnFr.MouseEnter:Connect(function()
            Tween(btnFr, {BackgroundColor3 = btn.Primary and T.AccentHover or T.CardHover}, 0.15)
        end)
        btnFr.MouseLeave:Connect(function()
            Tween(btnFr, {BackgroundColor3 = btn.Primary and T.Accent or T.Card}, 0.15)
        end)
        btnFr.MouseButton1Click:Connect(function()
            CloseModal()
            if btn.Callback then btn.Callback() end
        end)
    end

    overlay.MouseButton1Click:Connect(CloseModal)

    return { Close = CloseModal }
end

-- ============================================================
--  WINDOW CREATION
-- ============================================================
function NexusLib:CreateWindow(opts)
    opts = opts or {}
    local title     = opts.Title     or "NexusLib"
    local subtitle  = opts.Subtitle  or ""
    local themeName = opts.Theme     or "Dark"
    local winW      = opts.Width     or 580
    local winH      = opts.Height    or 420
    local startPos  = opts.Position  or UDim2.new(0.5, -winW/2, 0.5, -winH/2)
    local sidebar   = opts.Sidebar   ~= false
    local sideW     = sidebar and (opts.SidebarWidth or 145) or 0
    local T         = Themes[themeName] or Themes.Dark
    local keybind   = opts.ToggleKeybind -- Enum.KeyCode

    -- ── ScreenGui ───────────────────────────────────────────
    local sg = Instance.new("ScreenGui")
    sg.Name           = "NexusLib_" .. title:gsub(" ","")
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 100
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end

    -- ── Shadow ──────────────────────────────────────────────
    local shadowFr = NewFrame(sg,
        UDim2.new(0, winW+40, 0, winH+40),
        UDim2.new(0, startPos.X.Offset - 20, 0, startPos.Y.Offset - 20),
        T.Shadow, "Shadow", 0.65)
    MakeRound(shadowFr, 18)
    shadowFr.ZIndex = 0

    -- ── Root Window ─────────────────────────────────────────
    local win = NewFrame(sg, UDim2.new(0, winW, 0, winH), startPos, T.Background, "Window")
    win.ClipsDescendants = false
    MakeRound(win, 12)
    MakeStroke(win, T.Border, 1, 0.5)
    win.ZIndex = 1

    -- ── Title Bar ───────────────────────────────────────────
    local titleBar = NewFrame(win, UDim2.new(1,0,0,48), UDim2.new(0,0,0,0), T.TitleBar, "TitleBar")
    MakeRound(titleBar, 12)
    -- Cover bottom-rounded corners
    local titleFill = NewFrame(win, UDim2.new(1,0,0,10), UDim2.new(0,0,0,38), T.TitleBar, "TF")
    MakeDraggable(titleBar, win, function(x, y)
        shadowFr.Position = UDim2.new(0, x - 20, 0, y - 20)
    end)

    -- Logo dot / gradient
    local logoDot = NewFrame(titleBar, UDim2.new(0,8,0,8), UDim2.new(0,14,0.5,-4), T.Accent, "Dot")
    MakeRound(logoDot, 4)

    -- Title text
    local titleLbl = NewLabel(titleBar, title, UDim2.new(0.55,0,1,0), T.Text, "Title", FONT_BOLD, 14)
    titleLbl.Position = UDim2.new(0, 28, 0, 0)

    -- Subtitle
    if subtitle ~= "" then
        local subLbl = NewLabel(titleBar, subtitle, UDim2.new(0.4,0,1,0), T.TextMuted, "Sub", FONT_REG, 11)
        subLbl.Position = UDim2.new(0, 28 + #title * 8 + 6, 0, 0)
    end

    -- Window control buttons
    local function MakeWinBtn(color, xOff, icon)
        local btn = NewButton(titleBar, UDim2.new(0,14,0,14), UDim2.new(1, xOff, 0.5, -7), color, "WinBtn")
        MakeRound(btn, 7)
        MakeStroke(btn, Color3.new(0,0,0), 1, 0.7)
        local lbl = NewLabel(btn, icon, UDim2.new(1,0,1,0), T.White, "I", FONT_BOLD, 8, Enum.TextXAlignment.Center)
        lbl.Visible = false
        btn.MouseEnter:Connect(function() lbl.Visible = true  Tween(btn, {BackgroundTransparency = 0.2}, 0.1) end)
        btn.MouseLeave:Connect(function() lbl.Visible = false Tween(btn, {BackgroundTransparency = 0},   0.1) end)
        return btn, lbl
    end

    local btnClose, _ = MakeWinBtn(T.Danger,   -22, Icons.Close)
    local btnMin,   _ = MakeWinBtn(T.Warning,  -40, Icons.Minimize)
    local btnMax,   _ = MakeWinBtn(T.Success,  -58, Icons.Maximize)

    -- ── Sidebar ─────────────────────────────────────────────
    local sidebarFr = nil
    local tabContainer = nil
    if sidebar then
        sidebarFr = NewFrame(win, UDim2.new(0, sideW, 1,-48), UDim2.new(0,0,0,48), T.Sidebar, "Sidebar")
        -- Cover right rounded corner of sidebar
        local sbFill = NewFrame(win, UDim2.new(0,10,1,-48), UDim2.new(0, sideW-10, 0,48), T.Sidebar, "SBFill")

        -- Divider
        local div = NewFrame(win, UDim2.new(0,1,1,-48), UDim2.new(0, sideW, 0,48), T.Border, "Div")

        -- Logo area at bottom of sidebar
        local sideFooter = NewFrame(sidebarFr, UDim2.new(1,0,0,30), UDim2.new(0,0,1,-30), T.Sidebar, "Footer")
        local footerLbl  = NewLabel(sideFooter, "NexusLib v2", UDim2.new(1,0,1,0), T.TextDim, "FLbl", FONT_REG, 9, Enum.TextXAlignment.Center)

        tabContainer = NewFrame(sidebarFr, UDim2.new(1,0,1,-30), UDim2.new(0,0,0,0), T.Sidebar, "Tabs")
        tabContainer.BackgroundTransparency = 1
        MakeListLayout(tabContainer, Enum.SortOrder.LayoutOrder, UDim.new(0,2))
        MakePadding(tabContainer, 8, 0, 6, 6)
    end

    -- ── Content Area ────────────────────────────────────────
    local contentX = sidebar and (sideW + 2) or 0
    local contentW = sidebar and -(sideW + 2) or 0
    local contentArea = NewFrame(win, UDim2.new(1, contentW, 1,-48), UDim2.new(0, contentX, 0,48), T.Background, "Content")
    contentArea.ClipsDescendants = true

    -- ── Resize Handle ───────────────────────────────────────
    local resizeHandle = NewButton(win, UDim2.new(0,12,0,12), UDim2.new(1,-12,1,-12), T.Border, "ResizeHandle", 0.7)
    MakeRound(resizeHandle, 2)
    local rIcon = NewLabel(resizeHandle, Icons.Resize, UDim2.new(1,0,1,0), T.TextDim, "I", FONT_REG, 9, Enum.TextXAlignment.Center)
    MakeResizable(resizeHandle, win, 320, 240, function(w, h)
        shadowFr.Size     = UDim2.new(0, w+40, 0, h+40)
        contentArea.Size  = UDim2.new(1, contentW, 1, -48)
    end)

    -- ── Window Minimize/Close/Max ────────────────────────────
    local minimized  = false
    local maximized  = false
    local savedSize  = win.Size
    local savedPos   = win.Position

    btnClose.MouseButton1Click:Connect(function()
        Tween(win,      {Size = UDim2.new(0, winW, 0, 0), BackgroundTransparency = 1}, 0.25)
        Tween(shadowFr, {BackgroundTransparency = 1}, 0.25)
        task.delay(0.25, function() sg:Destroy() end)
    end)

    btnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            savedSize = win.Size
            Tween(win, {Size = UDim2.new(0, win.AbsoluteSize.X, 0, 48)}, 0.3, STYLE_QUART, EASE_OUT)
        else
            Tween(win, {Size = savedSize}, 0.3, STYLE_QUART, EASE_OUT)
        end
    end)

    btnMax.MouseButton1Click:Connect(function()
        maximized = not maximized
        if maximized then
            savedSize = win.Size
            savedPos  = win.Position
            Tween(win, {
                Size     = UDim2.new(0, Camera.ViewportSize.X - 20, 0, Camera.ViewportSize.Y - 20),
                Position = UDim2.new(0, 10, 0, 10)
            }, 0.3, STYLE_QUART, EASE_OUT)
        else
            Tween(win, { Size = savedSize, Position = savedPos }, 0.3, STYLE_QUART, EASE_OUT)
        end
    end)

    -- Toggle keybind
    if keybind then
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == keybind then
                win.Visible = not win.Visible
            end
        end)
    end

    -- Animate window in
    win.BackgroundTransparency = 1
    win.Size = UDim2.new(0, winW, 0, 0)
    Tween(win, {BackgroundTransparency = 0, Size = UDim2.new(0, winW, 0, winH)}, 0.4, STYLE_BACK, EASE_OUT)

    -- ============================================================
    --  WINDOW OBJECT
    -- ============================================================
    local Window = {
        _T           = T,
        _tabs        = {},
        _activeTab   = nil,
        _sidebar     = tabContainer,
        _content     = contentArea,
        _sg          = sg,
        _win         = win,
        _shadow      = shadowFr,
        _keybind     = keybind,
        _themeName   = themeName,
        _flags       = {},
    }

    -- ── Set Theme ───────────────────────────────────────────────
    function Window:SetTheme(name)
        -- Theme changes require full rebuild; expose as method for scripting
        self._themeName = name
        self._T = Themes[name] or Themes.Dark
        print("[NexusLib] Dynamic theme switching: rebuild recommended.")
    end

    -- ── Notify from Window context ───────────────────────────────
    function Window:Notify(opts)
        opts = opts or {}
        opts.Theme = opts.Theme or self._themeName
        NexusLib:Notify(opts)
    end

    -- ── Modal from Window context ─────────────────────────────────
    function Window:ShowModal(opts)
        return ShowModal(opts, self._T, self._sg)
    end

    -- ── Add Tab ─────────────────────────────────────────────────
    function Window:AddTab(name, icon)
        local T       = self._T
        local tabIdx  = #self._tabs + 1
        local tabBtn  = nil

        -- Sidebar tab button (if sidebar enabled)
        if self._sidebar then
            tabBtn = NewButton(self._sidebar, UDim2.new(1,-4,0,32), nil, T.Panel, "Tab_" .. name, 1)
            tabBtn.LayoutOrder = tabIdx
            MakeRound(tabBtn, 7)
            MakePadding(tabBtn, 0, 0, 10, 4)

            -- Icon
            local iconOffset = 0
            if icon then
                local iconImg = NewImage(tabBtn, icon, UDim2.new(0,14,0,14), UDim2.new(0,0,0.5,-7), "TIcon", T.TextMuted)
                iconOffset = 18
            end

            local tabLbl = NewLabel(tabBtn, name, UDim2.new(1,-iconOffset, 1,0), T.TextMuted, "TLbl", FONT_SEMI, 12)
            tabLbl.Position = UDim2.new(0, iconOffset, 0, 0)

            -- Active indicator dot
            local activeDot = NewFrame(tabBtn, UDim2.new(0,3,0,16), UDim2.new(0,-3,0.5,-8), T.Accent, "Dot")
            MakeRound(activeDot, 2)
            activeDot.BackgroundTransparency = 1

            -- Hover effect
            tabBtn.MouseEnter:Connect(function()
                if Window._activeTab and Window._activeTab._btn ~= tabBtn then
                    Tween(tabBtn, {BackgroundColor3 = T.Card, BackgroundTransparency = 0.5}, 0.15)
                end
            end)
            tabBtn.MouseLeave:Connect(function()
                if Window._activeTab and Window._activeTab._btn ~= tabBtn then
                    Tween(tabBtn, {BackgroundTransparency = 1}, 0.15)
                end
            end)
        end

        -- Content page
        local page = NewFrame(self._content, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), T.Background, "Page_" .. name)
        page.Visible = false
        page.ClipsDescendants = true

        -- Scroll frame inside page
        local scroll = NewScroll(page, UDim2.new(1,0,1,0), nil, T.Scrollbar, "Scroll")
        MakePadding(scroll, 10, 12, 12, 12)
        MakeListLayout(scroll, Enum.SortOrder.LayoutOrder, UDim.new(0,5))

        -- Select this tab
        local function SelectTab()
            -- Deselect previous
            if Window._activeTab then
                local prev = Window._activeTab
                if prev._btn then
                    Tween(prev._btn, {BackgroundColor3 = T.Panel, BackgroundTransparency = 1}, 0.2)
                    if prev._lbl then Tween(prev._lbl, {TextColor3 = T.TextMuted}, 0.2) end
                    if prev._dot then Tween(prev._dot, {BackgroundTransparency = 1}, 0.2) end
                end
                -- Slide out old page
                prev._page.Visible = false
            end

            -- Select this
            if tabBtn then
                Tween(tabBtn, {BackgroundColor3 = T.AccentDim, BackgroundTransparency = 0}, 0.2)
                local lbl = tabBtn:FindFirstChild("TLbl")
                local dot = tabBtn:FindFirstChild("Dot")
                if lbl then Tween(lbl, {TextColor3 = T.Accent}, 0.2) end
                if dot then Tween(dot, {BackgroundTransparency = 0}, 0.2) end
            end
            page.Visible = true
            -- Slide in new page
            page.Position = UDim2.new(0.04, 0, 0, 0)
            page.BackgroundTransparency = 0.5
            Tween(page, {Position = UDim2.new(0,0,0,0), BackgroundTransparency = 0}, 0.2, STYLE_QUART, EASE_OUT)

            Window._activeTab = {
                _btn  = tabBtn,
                _lbl  = tabBtn and tabBtn:FindFirstChild("TLbl"),
                _dot  = tabBtn and tabBtn:FindFirstChild("Dot"),
                _page = page,
            }
        end

        if tabBtn then tabBtn.MouseButton1Click:Connect(SelectTab) end
        if tabIdx == 1 then SelectTab() end

        -- ============================================================
        --  TAB OBJECT
        -- ============================================================
        local Tab = {
            _scroll  = scroll,
            _T       = T,
            _window  = Window,
            _name    = name,
            _select  = SelectTab,
        }

        -- Helper: add child to scroll with auto layout order
        local function AddToScroll(element)
            element.Parent = scroll
            element.LayoutOrder = #scroll:GetChildren()
            return element
        end

        -- ── SECTION ─────────────────────────────────────────────
        function Tab:AddSection(name)
            local T = self._T
            local row = NewFrame(scroll, UDim2.new(1,0,0,22), nil, T.Background, "Section")
            row.BackgroundTransparency = 1
            AddToScroll(row)

            local line = NewFrame(row, UDim2.new(1,0,0,1), UDim2.new(0,0,0.5,0), T.Border, "Line")
            line.BackgroundTransparency = 0.4

            local bgLbl = NewFrame(row, UDim2.new(0,0,0,16), UDim2.new(0.5,0,0.5,-8), T.Background, "BgLbl")
            bgLbl.AutomaticSize = Enum.AutomaticSize.X
            MakePadding(bgLbl, 0, 0, 6, 6)
            local lbl = NewLabel(bgLbl, name:upper(), UDim2.new(0,0,1,0), T.TextDim, "L", FONT_BOLD, 9, Enum.TextXAlignment.Center)
            lbl.AutomaticSize = Enum.AutomaticSize.X
            return row
        end

        -- ── SEPARATOR ───────────────────────────────────────────
        function Tab:AddSeparator()
            local T   = self._T
            local sep = NewFrame(scroll, UDim2.new(1,0,0,1), nil, T.Border, "Sep")
            sep.BackgroundTransparency = 0.5
            AddToScroll(sep)
            return sep
        end

        -- ── LABEL ───────────────────────────────────────────────
        function Tab:AddLabel(opts)
            opts = opts or {}
            local T = self._T
            local text  = opts.Text  or "Label"
            local color = opts.Color or T.TextMuted
            local size  = opts.Size  or 12
            local bold  = opts.Bold  or false

            local lbl = NewLabel(scroll, text, UDim2.new(1,0,0,0), color, "Label", bold and FONT_BOLD or FONT_REG, size)
            lbl.AutomaticSize = Enum.AutomaticSize.Y
            lbl.TextWrapped   = true
            AddToScroll(lbl)

            local L = {}
            function L:Set(t)    lbl.Text      = t end
            function L:SetColor(c) lbl.TextColor3 = c end
            function L:Get()     return lbl.Text end
            return L
        end

        -- ── PARAGRAPH ───────────────────────────────────────────
        function Tab:AddParagraph(opts)
            opts = opts or {}
            local T     = self._T
            local title = opts.Title or ""
            local body  = opts.Body  or ""
            local color = opts.Color

            local card = NewFrame(scroll, UDim2.new(1,0,0,0), nil, T.Card, "Para")
            card.AutomaticSize = Enum.AutomaticSize.Y
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 10, 10, 12, 12)
            MakeListLayout(card, Enum.SortOrder.LayoutOrder, UDim.new(0, 4))
            AddToScroll(card)

            local titleLbl = nil
            if title ~= "" then
                titleLbl = NewLabel(card, title, UDim2.new(1,0,0,18), color or T.Text, "Title", FONT_BOLD, 13)
                titleLbl.LayoutOrder = 1
            end

            local bodyLbl = NewLabel(card, body, UDim2.new(1,0,0,0), color or T.TextMuted, "Body", FONT_REG, 12)
            bodyLbl.TextWrapped   = true
            bodyLbl.AutomaticSize = Enum.AutomaticSize.Y
            bodyLbl.LayoutOrder   = 2

            local P = {}
            function P:SetTitle(t) if titleLbl then titleLbl.Text = t end end
            function P:SetBody(t)  bodyLbl.Text = t end
            function P:SetColor(c)
                if titleLbl then titleLbl.TextColor3 = c end
                bodyLbl.TextColor3 = c
            end
            return P
        end

        -- ── BUTTON ──────────────────────────────────────────────
        function Tab:AddButton(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Button"
            local desc     = opts.Desc     or ""
            local icon     = opts.Icon     or ""
            local callback = opts.Callback or function() end
            local danger   = opts.Danger   or false
            local tooltip  = opts.Tooltip  or ""
            local flag     = opts.Flag

            local cardH = desc ~= "" and 52 or 36
            local card  = NewFrame(scroll, UDim2.new(1,0,0,cardH), nil, T.Card, "BtnCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            AddToScroll(card)

            local accentColor = danger and T.Danger or T.Accent
            local accentDim   = danger and T.DangerDim or T.AccentDim

            -- Left accent strip
            local strip = NewFrame(card, UDim2.new(0,3,0.6,0), UDim2.new(0,0,0.2,0), accentColor, "Strip")
            strip.BackgroundTransparency = 0.7
            MakeRound(strip, 2)

            local btn = NewButton(card, UDim2.new(1,0,1,0), nil, T.Card, "Btn")
            MakeRound(btn, 8)
            MakePadding(btn, 0, 0, 12, 50)

            -- Icon
            local iconOffset = 0
            if icon ~= "" then
                local iconLbl = NewLabel(btn, icon, UDim2.new(0,28,1,0), accentColor, "BIcon", FONT_REG, 16, Enum.TextXAlignment.Center)
                iconOffset = 28
            end

            local lbl = NewLabel(btn, label, UDim2.new(1,-iconOffset-40,0,16), T.Text, "Lbl", FONT_SEMI, 13)
            lbl.Position = UDim2.new(0, iconOffset, 0, desc ~= "" and 9 or 10)

            if desc ~= "" then
                local dLbl = NewLabel(btn, desc, UDim2.new(1,-iconOffset-40,0,14), T.TextMuted, "Desc", FONT_REG, 11)
                dLbl.Position = UDim2.new(0, iconOffset, 0, 28)
            end

            -- Right arrow / spinner area
            local rightFr = NewFrame(btn, UDim2.new(0,36,1,0), UDim2.new(1,-40,0,0), T.Card, "Right")
            rightFr.BackgroundTransparency = 1
            local arrLbl = NewLabel(rightFr, Icons.Arrow, UDim2.new(1,0,1,0), accentColor, "Arr", FONT_BOLD, 16, Enum.TextXAlignment.Center)

            -- Hover / click
            btn.MouseEnter:Connect(function()
                Tween(btn,   {BackgroundColor3 = accentDim}, 0.15)
                Tween(strip, {BackgroundTransparency = 0.3}, 0.15)
                Tween(arrLbl,{Position = UDim2.new(0,3,0,0)}, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn,   {BackgroundColor3 = T.Card}, 0.15)
                Tween(strip, {BackgroundTransparency = 0.7}, 0.15)
                Tween(arrLbl,{Position = UDim2.new(0,0,0,0)}, 0.15)
            end)
            btn.MouseButton1Down:Connect(function()
                Tween(btn, {BackgroundColor3 = accentColor}, 0.08)
            end)
            btn.MouseButton1Up:Connect(function(x, y)
                Tween(btn, {BackgroundColor3 = T.Card}, 0.2)
                SpawnRipple(btn, T, Mouse.X, Mouse.Y)
                callback()
            end)

            if tooltip ~= "" then AttachTooltip(btn, tooltip, T) end

            local Btn = {}
            function Btn:SetLabel(t) lbl.Text = t end
            function Btn:SetDesc(t)
                if desc ~= "" then
                    local d = btn:FindFirstChild("Desc")
                    if d then d.Text = t end
                end
            end
            function Btn:SetCallback(f) callback = f end
            return Btn
        end

        -- ── TOGGLE ──────────────────────────────────────────────
        function Tab:AddToggle(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Toggle"
            local desc     = opts.Desc     or ""
            local default  = opts.Default  ~= nil and opts.Default or false
            local callback = opts.Callback or function() end
            local flag     = opts.Flag
            local tooltip  = opts.Tooltip  or ""

            local state  = default
            local cardH  = desc ~= "" and 52 or 36
            local card   = NewFrame(scroll, UDim2.new(1,0,0,cardH), nil, T.Card, "TogCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            AddToScroll(card)

            local btn = NewButton(card, UDim2.new(1,0,1,0), nil, T.Card, "Btn")
            MakeRound(btn, 8)
            MakePadding(btn, 0, 0, 12, 12)

            local lbl = NewLabel(btn, label, UDim2.new(1,-62,0,16), T.Text, "Lbl", FONT_SEMI, 13)
            lbl.Position = UDim2.new(0,0,0, desc ~= "" and 9 or 10)

            if desc ~= "" then
                local dLbl = NewLabel(btn, desc, UDim2.new(1,-62,0,14), T.TextMuted, "Desc", FONT_REG, 11)
                dLbl.Position = UDim2.new(0,0,0,28)
            end

            -- Toggle pill
            local pill = NewFrame(btn, UDim2.new(0,46,0,24), UDim2.new(1,-52,0.5,-12), T.ToggleOff, "Pill")
            MakeRound(pill, 12)
            MakeStroke(pill, T.Border, 1, 0.6)

            -- Inner knob
            local knob = NewFrame(pill, UDim2.new(0,20,0,20), UDim2.new(0,2,0.5,-10), T.White, "Knob")
            MakeRound(knob, 10)
            -- Knob shadow
            MakeStroke(knob, Color3.new(0,0,0), 1, 0.8)

            -- Shine on knob
            local shine = NewFrame(knob, UDim2.new(0,8,0,8), UDim2.new(0,3,0,3), T.White, "Shine")
            shine.BackgroundTransparency = 0.6
            MakeRound(shine, 4)

            local function UpdateVisual(animate)
                if state then
                    if animate then
                        Tween(pill, {BackgroundColor3 = T.Toggle}, 0.25, STYLE_QUART, EASE_OUT)
                        Tween(knob, {Position = UDim2.new(0,24,0.5,-10)}, 0.25, STYLE_BACK, EASE_OUT)
                        Tween(knob, {BackgroundColor3 = T.White}, 0.15)
                    else
                        pill.BackgroundColor3 = T.Toggle
                        knob.Position = UDim2.new(0,24,0.5,-10)
                    end
                else
                    if animate then
                        Tween(pill, {BackgroundColor3 = T.ToggleOff}, 0.25, STYLE_QUART, EASE_OUT)
                        Tween(knob, {Position = UDim2.new(0,2,0.5,-10)},  0.25, STYLE_BACK, EASE_OUT)
                    else
                        pill.BackgroundColor3 = T.ToggleOff
                        knob.Position = UDim2.new(0,2,0.5,-10)
                    end
                end
            end
            UpdateVisual(false)

            btn.MouseButton1Click:Connect(function()
                state = not state
                UpdateVisual(true)
                callback(state)
                if flag then NexusLib._flags[flag] = state end
                SpawnRipple(btn, T, Mouse.X, Mouse.Y)
            end)

            btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = T.CardHover}, 0.15) end)
            btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = T.Card},      0.15) end)

            if tooltip ~= "" then AttachTooltip(btn, tooltip, T) end
            if flag then NexusLib._flags[flag] = state end

            local Toggle = {}
            function Toggle:Set(val)
                state = val
                UpdateVisual(true)
                callback(state)
                if flag then NexusLib._flags[flag] = state end
            end
            function Toggle:Get() return state end
            function Toggle:SetLabel(t) lbl.Text = t end
            return Toggle
        end

        -- ── SLIDER ──────────────────────────────────────────────
        function Tab:AddSlider(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Slider"
            local min      = opts.Min      or 0
            local max      = opts.Max      or 100
            local default  = opts.Default  or min
            local suffix   = opts.Suffix   or ""
            local prefix   = opts.Prefix   or ""
            local decimals = opts.Decimals or 0
            local step     = opts.Step     -- optional fixed step
            local callback = opts.Callback or function() end
            local flag     = opts.Flag
            local tooltip  = opts.Tooltip  or ""

            local value = math.clamp(default, min, max)

            local card = NewFrame(scroll, UDim2.new(1,0,0,58), nil, T.Card, "SlideCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 10, 12, 12)
            AddToScroll(card)

            -- Top row: label + value
            local topRow = NewFrame(card, UDim2.new(1,0,0,18), nil, T.Card, "Top")
            topRow.BackgroundTransparency = 1

            local lbl = NewLabel(topRow, label, UDim2.new(0.65,0,1,0), T.Text, "Lbl", FONT_SEMI, 13)

            local valBg = NewFrame(topRow, UDim2.new(0,72,0,18), UDim2.new(1,-72,0,0), T.Panel, "ValBg")
            MakeRound(valBg, 5)

            local function FmtValue()
                local fmt = "%." .. decimals .. "f"
                return prefix .. string.format(fmt, value) .. suffix
            end

            local valLbl = NewLabel(valBg, FmtValue(), UDim2.new(1,0,1,0), T.Accent, "Val", FONT_BOLD, 11, Enum.TextXAlignment.Center)

            -- Track
            local track = NewFrame(card, UDim2.new(1,0,0,6), UDim2.new(0,0,0,26), T.Panel, "Track")
            MakeRound(track, 3)

            -- Track gradient
            MakeGradient(track, ColorSequence.new({
                ColorSequenceKeypoint.new(0, T.AccentDim),
                ColorSequenceKeypoint.new(1, T.Accent),
            }), 0)

            local fill = NewFrame(track, UDim2.new(0,0,1,0), nil, T.Accent, "Fill")
            fill.BackgroundTransparency = 0
            MakeRound(fill, 3)

            -- Filled area gradient
            MakeGradient(fill, ColorSequence.new({
                ColorSequenceKeypoint.new(0, T.AccentDim),
                ColorSequenceKeypoint.new(1, T.AccentHover),
            }), 0)

            -- Knob
            local knob = NewButton(track, UDim2.new(0,16,0,16), UDim2.new(0,-8,0.5,-8), T.White, "Knob")
            MakeRound(knob, 8)
            MakeStroke(knob, T.Accent, 2, 0.2)

            -- Min/max labels
            local minLbl = NewLabel(card, tostring(min), UDim2.new(0.5,0,0,12), T.TextDim, "MinL", FONT_REG, 9)
            minLbl.Position = UDim2.new(0,0,0,36)

            local maxLbl = NewLabel(card, tostring(max), UDim2.new(0.5,0,0,12), T.TextDim, "MaxL", FONT_REG, 9, Enum.TextXAlignment.Right)
            maxLbl.Position = UDim2.new(0.5,0,0,36)

            local function ApplySnap(v)
                if step then
                    v = math.floor(v / step + 0.5) * step
                end
                local snap = 1 / (10 ^ decimals)
                return math.floor(v / snap + 0.5) * snap
            end

            local function UpdateSlider(v, animate)
                value = math.clamp(ApplySnap(v), min, max)
                local pct = (value - min) / (max - min)
                if animate then
                    Tween(fill, {Size = UDim2.new(pct,0,1,0)}, 0.1)
                    Tween(knob, {Position = UDim2.new(pct,-8,0.5,-8)}, 0.1)
                else
                    fill.Size     = UDim2.new(pct,0,1,0)
                    knob.Position = UDim2.new(pct,-8,0.5,-8)
                end
                valLbl.Text = FmtValue()
                callback(value)
                if flag then NexusLib._flags[flag] = value end
            end
            UpdateSlider(value, false)

            -- Dragging logic
            local dragging = false
            knob.MouseButton1Down:Connect(function()
                dragging = true
                Tween(knob, {Size = UDim2.new(0,20,0,20), Position = UDim2.new(
                    (value-min)/(max-min),-10,0.5,-10)}, 0.1)
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                    dragging = false
                    Tween(knob, {Size = UDim2.new(0,16,0,16)}, 0.15)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                    UpdateSlider(min + (max-min) * (rel / track.AbsoluteSize.X), true)
                end
            end)
            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local rel = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                    UpdateSlider(min + (max-min) * (rel / track.AbsoluteSize.X), true)
                    dragging = true
                end
            end)

            -- Scroll wheel support
            track.InputChanged:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseWheel then
                    local delta = i.Position.Z
                    local inc   = step or ((max - min) / 100)
                    UpdateSlider(value + delta * inc, true)
                end
            end)

            if tooltip ~= "" then AttachTooltip(card, tooltip, T) end
            if flag then NexusLib._flags[flag] = value end

            local Slider = {}
            function Slider:Set(v) UpdateSlider(v, true) end
            function Slider:Get() return value end
            function Slider:SetMin(v) min = v UpdateSlider(value, true) end
            function Slider:SetMax(v) max = v UpdateSlider(value, true) end
            return Slider
        end

        -- ── TEXTBOX ─────────────────────────────────────────────
        function Tab:AddTextBox(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label       or "Input"
            local placeholder = opts.Placeholder or "Type here..."
            local default  = opts.Default     or ""
            local callback = opts.Callback    or function() end
            local secret   = opts.Secret      or false  -- password field
            local clearOnFocus = opts.ClearOnFocus ~= false
            local multiLine = opts.MultiLine  or false
            local flag     = opts.Flag
            local tooltip  = opts.Tooltip     or ""
            local maxLen   = opts.MaxLength   or nil
            local validate = opts.Validate    -- function(text) -> bool, msg

            local height = multiLine and 76 or 58

            local card = NewFrame(scroll, UDim2.new(1,0,0,height), nil, T.Card, "TBCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 8, 12, 12)
            AddToScroll(card)

            -- Label row
            local lblRow = NewFrame(card, UDim2.new(1,0,0,14), nil, T.Card, "LRow")
            lblRow.BackgroundTransparency = 1
            local lbl = NewLabel(lblRow, label, UDim2.new(0.7,0,1,0), T.TextMuted, "Lbl", FONT_SEMI, 11)
            local charCountLbl = NewLabel(lblRow, "", UDim2.new(0.3,0,1,0), T.TextDim, "CC", FONT_REG, 9, Enum.TextXAlignment.Right)

            -- Input field background
            local inputH = multiLine and 44 or 26
            local inputBg = NewFrame(card, UDim2.new(1,0,0,inputH), UDim2.new(0,0,0,18), T.InputBg, "InputBg")
            MakeRound(inputBg, 6)
            local inputStroke = MakeStroke(inputBg, T.Border, 1, 0.4)

            -- Secret eye toggle
            local showSecret = false
            if secret then
                local eyeBtn = NewButton(inputBg, UDim2.new(0,20,0,20), UDim2.new(1,-22,0.5,-10), T.InputBg, "Eye", 1)
                local eyeLbl = NewLabel(eyeBtn, Icons.Eye, UDim2.new(1,0,1,0), T.TextMuted, "E", FONT_REG, 12, Enum.TextXAlignment.Center)
                eyeBtn.MouseButton1Click:Connect(function()
                    showSecret = not showSecret
                    -- TextBox doesn't have a built-in password mode; we handle masking manually
                end)
            end

            local tb = Instance.new("TextBox")
            tb.Size              = UDim2.new(1, secret and -28 or 0, 1, 0)
            tb.BackgroundTransparency = 1
            tb.TextColor3        = T.Text
            tb.PlaceholderColor3 = T.TextDim
            tb.PlaceholderText   = placeholder
            tb.Font              = FONT_REG
            tb.TextSize          = 12
            tb.Text              = default
            tb.ClearTextOnFocus  = clearOnFocus
            tb.TextXAlignment    = Enum.TextXAlignment.Left
            tb.TextYAlignment    = Enum.TextYAlignment.Top
            tb.MultiLine         = multiLine
            tb.TextTruncate      = multiLine and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd
            tb.Parent            = inputBg
            MakePadding(tb, 2, 2, 8, 8)

            -- Validation message
            local validLbl = NewLabel(card, "", UDim2.new(1,0,0,10), T.Danger, "Valid", FONT_REG, 10)
            validLbl.Position = UDim2.new(0,0,0,height - 12)
            validLbl.Visible  = false

            tb.Focused:Connect(function()
                Tween(inputBg, {BackgroundColor3 = T.Surface}, 0.15)
                Tween(inputStroke, {Color = T.Accent, Transparency = 0.4}, 0.15)
            end)
            tb.FocusLost:Connect(function(enter)
                Tween(inputBg, {BackgroundColor3 = T.InputBg}, 0.15)
                Tween(inputStroke, {Color = T.Border, Transparency = 0.4}, 0.15)

                local txt = tb.Text
                if maxLen and #txt > maxLen then
                    tb.Text = txt:sub(1, maxLen)
                    txt = tb.Text
                end

                local ok, msg = true, ""
                if validate then ok, msg = validate(txt) end

                validLbl.Text    = ok and "" or (msg or "Invalid input")
                validLbl.Visible = not ok

                callback(txt, enter)
                if flag then NexusLib._flags[flag] = txt end
            end)

            tb:GetPropertyChangedSignal("Text"):Connect(function()
                local txt = tb.Text
                if maxLen then
                    charCountLbl.Text = tostring(#txt) .. "/" .. maxLen
                end
            end)

            if tooltip ~= "" then AttachTooltip(card, tooltip, T) end
            if flag then NexusLib._flags[flag] = default end

            local TB = {}
            function TB:Set(v) tb.Text = v if flag then NexusLib._flags[flag] = v end end
            function TB:Get() return tb.Text end
            function TB:Focus() tb:CaptureFocus() end
            function TB:Clear() tb.Text = "" end
            return TB
        end

        -- ── DROPDOWN ────────────────────────────────────────────
        function Tab:AddDropdown(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Dropdown"
            local options  = opts.Options  or {}
            local default  = opts.Default  or options[1]
            local callback = opts.Callback or function() end
            local multi    = opts.Multi    or false
            local flag     = opts.Flag
            local searchable = opts.Searchable or (#options > 8)
            local tooltip  = opts.Tooltip  or ""

            local selected = multi and {} or default
            if multi and default then selected[default] = true end

            local card = NewFrame(scroll, UDim2.new(1,0,0,58), nil, T.Card, "DDCard")
            card.ClipsDescendants = false
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 8, 12, 12)
            AddToScroll(card)

            local lbl = NewLabel(card, label, UDim2.new(1,0,0,14), T.TextMuted, "Lbl", FONT_SEMI, 11)

            local trigger = NewButton(card, UDim2.new(1,0,0,26), UDim2.new(0,0,0,18), T.InputBg, "Trigger")
            MakeRound(trigger, 6)
            MakeStroke(trigger, T.Border, 1, 0.4)
            MakePadding(trigger, 0, 0, 8, 28)

            local function GetDisplayText()
                if multi then
                    local keys = {}
                    for k,v in pairs(selected) do if v then table.insert(keys, k) end end
                    table.sort(keys)
                    return #keys == 0 and "None selected" or (#keys == 1 and keys[1] or keys[1] .. " +" .. (#keys-1))
                else
                    return tostring(selected or "Select...")
                end
            end

            local trigLbl = NewLabel(trigger, GetDisplayText(), UDim2.new(1,0,1,0), T.Text, "TLbl", FONT_REG, 12)
            local arrowLbl = NewLabel(trigger, Icons.Chevron, UDim2.new(0,20,1,0), T.TextMuted, "Arr", FONT_BOLD, 12, Enum.TextXAlignment.Center)
            arrowLbl.Position = UDim2.new(1,-22,0,0)

            local open = false
            local menu = nil

            local function CloseMenu()
                if menu then
                    Tween(menu, {Size = UDim2.new(1,0,0,0), BackgroundTransparency = 1}, 0.2)
                    task.delay(0.2, function() if menu then menu:Destroy() menu = nil end end)
                end
                open = false
                Tween(arrowLbl, {Rotation = 0}, 0.2)
            end

            local function OpenMenu()
                open = true
                Tween(arrowLbl, {Rotation = 180}, 0.2)

                local itemH = 28
                local maxVisible = 6
                local menuH = math.min(#options, maxVisible) * itemH + (searchable and 36 or 0) + 8

                menu = NewFrame(card, UDim2.new(1,0,0,0), UDim2.new(0,0,0,58), T.Panel, "DDMenu")
                menu.ZIndex = 20
                menu.ClipsDescendants = true
                menu.BackgroundTransparency = 1
                MakeRound(menu, 8)
                MakeStroke(menu, T.Border, 1, 0.3)

                Tween(menu, {Size = UDim2.new(1,0,0,menuH), BackgroundTransparency = 0}, 0.2, STYLE_BACK, EASE_OUT)
                MakePadding(menu, 4, 4, 4, 4)

                local searchText = ""

                -- Search box (if searchable)
                local itemsContainer = nil
                if searchable then
                    local searchBg = NewFrame(menu, UDim2.new(1,0,0,26), nil, T.InputBg, "Search")
                    MakeRound(searchBg, 5)
                    MakeStroke(searchBg, T.Border, 1, 0.5)
                    MakePadding(searchBg, 0, 0, 8, 8)
                    local searchIcon = NewLabel(searchBg, Icons.Search, UDim2.new(0,14,1,0), T.TextDim, "SI", FONT_REG, 11)
                    local searchTB = Instance.new("TextBox")
                    searchTB.Size              = UDim2.new(1,-18,1,0)
                    searchTB.Position          = UDim2.new(0,18,0,0)
                    searchTB.BackgroundTransparency = 1
                    searchTB.TextColor3        = T.Text
                    searchTB.PlaceholderColor3 = T.TextDim
                    searchTB.PlaceholderText   = "Search..."
                    searchTB.Font              = FONT_REG
                    searchTB.TextSize          = 11
                    searchTB.ClearTextOnFocus  = false
                    searchTB.Parent            = searchBg
                    searchTB:GetPropertyChangedSignal("Text"):Connect(function()
                        searchText = searchTB.Text:lower()
                        -- Refresh items visibility
                        if itemsContainer then
                            for _, child in ipairs(itemsContainer:GetChildren()) do
                                if child:IsA("TextButton") then
                                    local optLbl = child:FindFirstChild("OLbl")
                                    if optLbl then
                                        child.Visible = searchText == "" or optLbl.Text:lower():find(searchText, 1, true) ~= nil
                                    end
                                end
                            end
                        end
                    end)
                end

                -- Items scroll
                local itemScroll = NewScroll(menu, UDim2.new(1,0,1, searchable and -34 or 0),
                    UDim2.new(0,0,0, searchable and 30 or 0), T.Scrollbar, "Items")
                itemScroll.CanvasSize = UDim2.new(0,0,0, #options * itemH)
                itemScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
                MakeListLayout(itemScroll, Enum.SortOrder.LayoutOrder, UDim.new(0,1))
                itemsContainer = itemScroll

                for i, opt in ipairs(options) do
                    local isSelected = multi and (selected[opt] == true) or (not multi and selected == opt)

                    local item = NewButton(itemScroll, UDim2.new(1,0,0,itemH), nil, isSelected and T.AccentDim or T.Panel, "Opt" .. i)
                    item.LayoutOrder = i
                    MakeRound(item, 5)
                    MakePadding(item, 0, 0, 8, 8)

                    -- Checkmark for selected
                    local checkLbl = NewLabel(item, isSelected and Icons.Check or "", UDim2.new(0,16,1,0), T.Accent, "Chk", FONT_BOLD, 11, Enum.TextXAlignment.Center)
                    local optLbl   = NewLabel(item, tostring(opt), UDim2.new(1,-20,1,0), isSelected and T.Accent or T.Text, "OLbl", FONT_REG, 12)
                    optLbl.Position = UDim2.new(0, 20, 0, 0)

                    item.MouseEnter:Connect(function()
                        if not (multi and selected[opt] or (not multi and selected == opt)) then
                            Tween(item, {BackgroundColor3 = T.CardHover}, 0.1)
                        end
                    end)
                    item.MouseLeave:Connect(function()
                        local sel = multi and selected[opt] or (not multi and selected == opt)
                        Tween(item, {BackgroundColor3 = sel and T.AccentDim or T.Panel}, 0.1)
                    end)
                    item.MouseButton1Click:Connect(function()
                        if multi then
                            selected[opt] = not selected[opt] or nil
                            local sel = selected[opt] == true
                            checkLbl.Text       = sel and Icons.Check or ""
                            optLbl.TextColor3   = sel and T.Accent or T.Text
                            item.BackgroundColor3 = sel and T.AccentDim or T.Panel
                            trigLbl.Text = GetDisplayText()
                            callback(selected)
                        else
                            -- Deselect all items visually
                            for _, child in ipairs(itemScroll:GetChildren()) do
                                if child:IsA("TextButton") then
                                    local c = child:FindFirstChild("Chk")
                                    local o = child:FindFirstChild("OLbl")
                                    if c then c.Text = "" end
                                    if o then o.TextColor3 = T.Text end
                                    Tween(child, {BackgroundColor3 = T.Panel}, 0.1)
                                end
                            end
                            selected = opt
                            checkLbl.Text       = Icons.Check
                            optLbl.TextColor3   = T.Accent
                            item.BackgroundColor3 = T.AccentDim
                            trigLbl.Text = GetDisplayText()
                            callback(opt)
                            if flag then NexusLib._flags[flag] = opt end
                            task.delay(0.15, CloseMenu)
                        end
                    end)
                end

                -- Close on outside click
                local conn
                conn = UserInputService.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        task.wait()
                        if menu and open then
                            local mPos = menu.AbsolutePosition
                            local mSize = menu.AbsoluteSize
                            local mx, my = Mouse.X, Mouse.Y
                            if mx < mPos.X or mx > mPos.X + mSize.X or my < mPos.Y or my > mPos.Y + mSize.Y then
                                CloseMenu()
                                conn:Disconnect()
                            end
                        end
                    end
                end)
            end

            trigger.MouseButton1Click:Connect(function()
                if open then CloseMenu() else OpenMenu() end
            end)

            if tooltip ~= "" then AttachTooltip(card, tooltip, T) end
            if flag then NexusLib._flags[flag] = selected end

            local DD = {}
            function DD:Set(v)
                if multi then
                    selected = v
                else
                    selected = v
                end
                trigLbl.Text = GetDisplayText()
                if flag then NexusLib._flags[flag] = selected end
            end
            function DD:Get() return selected end
            function DD:SetOptions(newOpts)
                options = newOpts
                if not multi then
                    if not table.find(options, selected) then
                        selected = options[1]
                        trigLbl.Text = GetDisplayText()
                    end
                end
            end
            function DD:AddOption(opt)
                table.insert(options, opt)
            end
            function DD:RemoveOption(opt)
                local idx = table.find(options, opt)
                if idx then table.remove(options, idx) end
            end
            return DD
        end

        -- ── KEYBIND ─────────────────────────────────────────────
        function Tab:AddKeybind(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Keybind"
            local desc     = opts.Desc     or ""
            local default  = opts.Default  or Enum.KeyCode.Unknown
            local callback = opts.Callback or function() end
            local hold     = opts.Hold     or false  -- require hold
            local flag     = opts.Flag
            local tooltip  = opts.Tooltip  or ""

            local key = default
            local listening = false
            local holding   = false

            local cardH = desc ~= "" and 52 or 36
            local card  = NewFrame(scroll, UDim2.new(1,0,0,cardH), nil, T.Card, "KBCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 0, 0, 12, 12)
            AddToScroll(card)

            local lbl = NewLabel(card, label, UDim2.new(1,-90,0,16), T.Text, "Lbl", FONT_SEMI, 13)
            lbl.Position = UDim2.new(0,0,0, desc ~= "" and 9 or 10)

            if desc ~= "" then
                local dLbl = NewLabel(card, desc, UDim2.new(1,-90,0,14), T.TextMuted, "D", FONT_REG, 11)
                dLbl.Position = UDim2.new(0,0,0,28)
            end

            local keyBtn = NewButton(card, UDim2.new(0,80,0,22), UDim2.new(1,-82,0.5,-11), T.Panel, "KB")
            MakeRound(keyBtn, 5)
            MakeStroke(keyBtn, T.Border, 1, 0.4)

            local keyLbl = NewLabel(keyBtn, key.Name == "Unknown" and "None" or key.Name,
                UDim2.new(1,0,1,0), T.Accent, "KL", FONT_BOLD, 10, Enum.TextXAlignment.Center)

            -- Listening state
            keyBtn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                keyLbl.Text       = "..."
                keyLbl.TextColor3 = T.Warning
                Tween(keyBtn, {BackgroundColor3 = T.AccentDim}, 0.15)

                local conn
                conn = UserInputService.InputBegan:Connect(function(i, gpe)
                    if gpe then return end
                    if i.UserInputType == Enum.UserInputType.Keyboard then
                        if i.KeyCode == Enum.KeyCode.Escape then
                            key = Enum.KeyCode.Unknown
                            keyLbl.Text       = "None"
                            keyLbl.TextColor3 = T.TextMuted
                        else
                            key = i.KeyCode
                            keyLbl.Text       = key.Name
                            keyLbl.TextColor3 = T.Accent
                        end
                        Tween(keyBtn, {BackgroundColor3 = T.Panel}, 0.15)
                        listening = false
                        conn:Disconnect()
                        if flag then NexusLib._flags[flag] = key end
                    end
                end)
            end)

            -- Key listener
            UserInputService.InputBegan:Connect(function(i, gpe)
                if gpe or listening then return end
                if i.KeyCode == key and key ~= Enum.KeyCode.Unknown then
                    if not hold then callback() end
                    holding = true
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.KeyCode == key then
                    if hold and holding then callback() end
                    holding = false
                end
            end)

            if tooltip ~= "" then AttachTooltip(card, tooltip, T) end
            if flag then NexusLib._flags[flag] = key end

            local KB = {}
            function KB:Set(k)
                key = k
                keyLbl.Text = k.Name == "Unknown" and "None" or k.Name
                if flag then NexusLib._flags[flag] = k end
            end
            function KB:Get() return key end
            return KB
        end

        -- ── COLOR PICKER ────────────────────────────────────────
        function Tab:AddColorPicker(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Color"
            local default  = opts.Default  or Color3.fromRGB(99, 102, 241)
            local callback = opts.Callback or function() end
            local flag     = opts.Flag
            local tooltip  = opts.Tooltip  or ""

            local color = default
            local h, s, v = Color3.toHSV(color)
            local a = 1  -- alpha
            local open = false
            local closedH = 36

            local card = NewFrame(scroll, UDim2.new(1,0,0,closedH), nil, T.Card, "CPCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 0, 0, 12, 12)
            AddToScroll(card)

            -- Header row
            local headerRow = NewFrame(card, UDim2.new(1,0,0,closedH), nil, T.Card, "Head")
            headerRow.BackgroundTransparency = 1

            local lbl = NewLabel(headerRow, label, UDim2.new(1,-90,1,0), T.Text, "Lbl", FONT_SEMI, 13)

            -- Color preview swatch
            local swatchBg = NewFrame(headerRow, UDim2.new(0,56,0,22), UDim2.new(1,-60,0.5,-11), T.Border, "SwBg")
            MakeRound(swatchBg, 5)
            -- Checkerboard pattern for alpha preview
            local swatch = NewFrame(swatchBg, UDim2.new(1,0,1,0), nil, color, "Sw")
            MakeRound(swatch, 4)
            local swatchBtn = NewButton(swatchBg, UDim2.new(1,0,1,0), nil, color, "SwBtn", 1)
            MakeRound(swatchBtn, 4)

            -- Hex label overlay on swatch
            local hexLbl = NewLabel(swatch,
                string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)),
                UDim2.new(1,0,1,0), Color3.new(1,1,1), "Hex", FONT_BOLD, 8, Enum.TextXAlignment.Center)
            hexLbl.TextStrokeTransparency = 0.3

            local picker = nil

            local function UpdateColor()
                color = Color3.fromHSV(h, s, v)
                swatch.BackgroundColor3 = color
                hexLbl.Text = string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
                callback(color)
                if flag then NexusLib._flags[flag] = color end
            end

            local function BuildPicker()
                local pickerH = 200
                picker = NewFrame(card, UDim2.new(1,0,0,pickerH), UDim2.new(0,0,0,closedH), T.Panel, "Picker")
                MakeRound(picker, 8)
                MakeStroke(picker, T.Border, 1, 0.5)
                MakePadding(picker, 8, 10, 8, 8)

                -- ── SV Gradient canvas ─────────────────────────────
                local svCanvas = NewFrame(picker, UDim2.new(1,0,0,90), nil, T.White, "SV")
                MakeRound(svCanvas, 6)
                -- White to pure hue horizontal gradient
                local svGradH = MakeGradient(svCanvas, ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1)),
                }), 0)
                -- Black vertical overlay
                local svOverlay = NewFrame(svCanvas, UDim2.new(1,0,1,0), nil, Color3.new(0,0,0), "Overlay", 0)
                MakeRound(svOverlay, 6)
                MakeGradient(svOverlay, ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
                    ColorSequenceKeypoint.new(1, Color3.new(0,0,0)),
                }), 90)
                svOverlay.BackgroundTransparency = 0  -- We'll use actual transparent gradient
                -- Actually make it properly transparent
                local overG = svOverlay:FindFirstChildOfClass("UIGradient")
                if overG then
                    overG.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1),
                    })
                end

                -- SV cursor
                local svCursor = NewFrame(svCanvas, UDim2.new(0,10,0,10), UDim2.new(s,-5,1-v,-5), T.White, "Cur")
                MakeRound(svCursor, 5)
                MakeStroke(svCursor, T.White, 2, 0)

                -- SV dragging
                local svDragging = false
                svCanvas.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = true
                        local relX = math.clamp(i.Position.X - svCanvas.AbsolutePosition.X, 0, svCanvas.AbsoluteSize.X)
                        local relY = math.clamp(i.Position.Y - svCanvas.AbsolutePosition.Y, 0, svCanvas.AbsoluteSize.Y)
                        s = relX / svCanvas.AbsoluteSize.X
                        v = 1 - (relY / svCanvas.AbsoluteSize.Y)
                        svCursor.Position = UDim2.new(s, -5, 1-v, -5)
                        UpdateColor()
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if svDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local relX = math.clamp(i.Position.X - svCanvas.AbsolutePosition.X, 0, svCanvas.AbsoluteSize.X)
                        local relY = math.clamp(i.Position.Y - svCanvas.AbsolutePosition.Y, 0, svCanvas.AbsoluteSize.Y)
                        s = relX / svCanvas.AbsoluteSize.X
                        v = 1 - (relY / svCanvas.AbsoluteSize.Y)
                        svCursor.Position = UDim2.new(s, -5, 1-v, -5)
                        UpdateColor()
                    end
                end)

                -- ── Hue slider ─────────────────────────────────────
                local hueRow = NewFrame(picker, UDim2.new(1,0,0,16), nil, T.Panel, "HRow")
                hueRow.BackgroundTransparency = 1

                local hueLbl = NewLabel(hueRow, "H", UDim2.new(0,12,1,0), T.TextMuted, "HL", FONT_BOLD, 9)

                local hueTrack = NewFrame(hueRow, UDim2.new(1,-18,0,10), UDim2.new(0,18,0.5,-5), T.White, "HT")
                MakeRound(hueTrack, 5)

                -- Rainbow gradient for hue
                local hueKeys = {}
                for i = 0, 6 do
                    local frac = i / 6
                    table.insert(hueKeys, ColorSequenceKeypoint.new(frac, Color3.fromHSV(frac, 1, 1)))
                end
                MakeGradient(hueTrack, ColorSequence.new(hueKeys), 0)

                local hueKnob = NewFrame(hueTrack, UDim2.new(0,12,0,12), UDim2.new(h,-6,0.5,-6), T.White, "HK")
                MakeRound(hueKnob, 6)
                MakeStroke(hueKnob, Color3.new(0,0,0), 1, 0.6)

                local hueDrag = false
                hueTrack.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDrag = true
                        local rel = math.clamp(i.Position.X - hueTrack.AbsolutePosition.X, 0, hueTrack.AbsoluteSize.X)
                        h = rel / hueTrack.AbsoluteSize.X
                        hueKnob.Position = UDim2.new(h,-6,0.5,-6)
                        -- Update SV canvas hue color
                        if svGradH then svGradH.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                            ColorSequenceKeypoint.new(1, Color3.fromHSV(h,1,1))
                        }) end
                        UpdateColor()
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if hueDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local rel = math.clamp(i.Position.X - hueTrack.AbsolutePosition.X, 0, hueTrack.AbsoluteSize.X)
                        h = rel / hueTrack.AbsoluteSize.X
                        hueKnob.Position = UDim2.new(h,-6,0.5,-6)
                        if svGradH then svGradH.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                            ColorSequenceKeypoint.new(1, Color3.fromHSV(h,1,1))
                        }) end
                        UpdateColor()
                    end
                end)

                -- ── Alpha slider ────────────────────────────────────
                local alphaRow = NewFrame(picker, UDim2.new(1,0,0,16), nil, T.Panel, "ARow")
                alphaRow.BackgroundTransparency = 1
                local alphaLbl = NewLabel(alphaRow, "A", UDim2.new(0,12,1,0), T.TextMuted, "AL", FONT_BOLD, 9)
                local alphaTrack = NewFrame(alphaRow, UDim2.new(1,-18,0,10), UDim2.new(0,18,0.5,-5), T.White, "AT")
                MakeRound(alphaTrack, 5)
                MakeGradient(alphaTrack, ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(0.1,0.1,0.1)),
                    ColorSequenceKeypoint.new(1, T.White),
                }), 0)
                local alphaKnob = NewFrame(alphaTrack, UDim2.new(0,12,0,12), UDim2.new(a,-6,0.5,-6), T.White, "AK")
                MakeRound(alphaKnob, 6)
                MakeStroke(alphaKnob, Color3.new(0,0,0), 1, 0.6)

                local alphaDrag = false
                alphaTrack.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        alphaDrag = true
                        a = math.clamp((i.Position.X - alphaTrack.AbsolutePosition.X) / alphaTrack.AbsoluteSize.X, 0, 1)
                        alphaKnob.Position = UDim2.new(a,-6,0.5,-6)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then alphaDrag = false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if alphaDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
                        a = math.clamp((i.Position.X - alphaTrack.AbsolutePosition.X) / alphaTrack.AbsoluteSize.X, 0, 1)
                        alphaKnob.Position = UDim2.new(a,-6,0.5,-6)
                    end
                end)

                -- ── Hex input ───────────────────────────────────────
                local hexRow = NewFrame(picker, UDim2.new(1,0,0,22), nil, T.Panel, "HexRow")
                hexRow.BackgroundTransparency = 1
                local hexBg = NewFrame(hexRow, UDim2.new(1,0,0,22), nil, T.InputBg, "HB")
                MakeRound(hexBg, 5)
                MakeStroke(hexBg, T.Border, 1, 0.5)
                MakePadding(hexBg, 0, 0, 8, 8)
                local hexTag = NewLabel(hexBg, "#", UDim2.new(0,10,1,0), T.TextDim, "HT", FONT_BOLD, 11)
                local hexTB = Instance.new("TextBox")
                hexTB.Size = UDim2.new(1,-12,1,0)
                hexTB.Position = UDim2.new(0,12,0,0)
                hexTB.BackgroundTransparency = 1
                hexTB.TextColor3 = T.Text
                hexTB.PlaceholderText = "RRGGBB"
                hexTB.Text = string.format("%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
                hexTB.Font = FONT_MONO
                hexTB.TextSize = 11
                hexTB.ClearTextOnFocus = false
                hexTB.Parent = hexBg
                hexTB.FocusLost:Connect(function()
                    local hex = hexTB.Text:gsub("#",""):upper()
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1,2), 16)
                        local g = tonumber(hex:sub(3,4), 16)
                        local b = tonumber(hex:sub(5,6), 16)
                        if r and g and b then
                            local newColor = Color3.fromRGB(r, g, b)
                            h, s, v = Color3.toHSV(newColor)
                            svCursor.Position = UDim2.new(s,-5,1-v,-5)
                            hueKnob.Position  = UDim2.new(h,-6,0.5,-6)
                            UpdateColor()
                        end
                    end
                end)

                -- Layout inside picker
                MakeListLayout(picker, Enum.SortOrder.LayoutOrder, UDim.new(0, 6))
                svCanvas.LayoutOrder  = 1
                hueRow.LayoutOrder    = 2
                alphaRow.LayoutOrder  = 3
                hexRow.LayoutOrder    = 4
            end

            swatchBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    card.Size = UDim2.new(1,0,0,closedH + 208)
                    BuildPicker()
                else
                    card.Size = UDim2.new(1,0,0,closedH)
                    if picker then picker:Destroy() picker = nil end
                end
            end)

            if tooltip ~= "" then AttachTooltip(card, tooltip, T) end
            if flag then NexusLib._flags[flag] = color end

            local CP = {}
            function CP:Set(c)
                color = c
                h, s, v = Color3.toHSV(c)
                swatch.BackgroundColor3 = c
                hexLbl.Text = string.format("#%02X%02X%02X", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
                callback(c)
                if flag then NexusLib._flags[flag] = c end
            end
            function CP:Get() return color end
            function CP:GetAlpha() return a end
            return CP
        end

        -- ── CHECKBOX ────────────────────────────────────────────
        function Tab:AddCheckbox(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Checkbox"
            local default  = opts.Default  or false
            local callback = opts.Callback or function() end
            local flag     = opts.Flag

            local state = default

            local card = NewFrame(scroll, UDim2.new(1,0,0,34), nil, T.Card, "CBCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 0, 0, 12, 12)
            AddToScroll(card)

            local btn = NewButton(card, UDim2.new(1,0,1,0), nil, T.Card, "Btn")
            MakeRound(btn, 8)
            MakePadding(btn, 0, 0, 0, 0)

            -- Checkbox box
            local box = NewFrame(btn, UDim2.new(0,18,0,18), UDim2.new(0,0,0.5,-9), T.ToggleOff, "Box")
            MakeRound(box, 4)
            MakeStroke(box, T.Border, 1.5, 0.3)

            local check = NewLabel(box, "", UDim2.new(1,0,1,0), T.White, "Check", FONT_BOLD, 12, Enum.TextXAlignment.Center)

            local lbl = NewLabel(btn, label, UDim2.new(1,-30,1,0), T.Text, "Lbl", FONT_SEMI, 13)
            lbl.Position = UDim2.new(0,26,0,0)

            local function UpdateVisual(animate)
                if state then
                    if animate then
                        Tween(box,   {BackgroundColor3 = T.Toggle}, 0.2)
                        Tween(check, {TextTransparency = 0}, 0.15)
                    else
                        box.BackgroundColor3 = T.Toggle
                        check.TextTransparency = 0
                    end
                    check.Text = Icons.Check
                else
                    if animate then
                        Tween(box,   {BackgroundColor3 = T.ToggleOff}, 0.2)
                        Tween(check, {TextTransparency = 1}, 0.15)
                    else
                        box.BackgroundColor3  = T.ToggleOff
                        check.TextTransparency = 1
                    end
                end
            end
            UpdateVisual(false)

            btn.MouseButton1Click:Connect(function()
                state = not state
                UpdateVisual(true)
                callback(state)
                if flag then NexusLib._flags[flag] = state end
                SpawnRipple(btn, T, Mouse.X, Mouse.Y)
            end)

            btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = T.CardHover}, 0.15) end)
            btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = T.Card},      0.15) end)

            if flag then NexusLib._flags[flag] = state end

            local CB = {}
            function CB:Set(val) state = val UpdateVisual(true) callback(state) end
            function CB:Get() return state end
            return CB
        end

        -- ── PROGRESS BAR ────────────────────────────────────────
        function Tab:AddProgress(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Progress"
            local value    = opts.Value    or 0    -- 0 to 100
            local color    = opts.Color    or T.Accent
            local animated = opts.Animated ~= false
            local striped  = opts.Striped  or false
            local suffix   = opts.Suffix   or "%"

            local card = NewFrame(scroll, UDim2.new(1,0,0,50), nil, T.Card, "PBCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 8, 12, 12)
            AddToScroll(card)

            local topRow = NewFrame(card, UDim2.new(1,0,0,16), nil, T.Card, "Top")
            topRow.BackgroundTransparency = 1
            local lbl = NewLabel(topRow, label, UDim2.new(0.7,0,1,0), T.TextMuted, "Lbl", FONT_SEMI, 11)
            local valLbl = NewLabel(topRow, tostring(value) .. suffix, UDim2.new(0.3,0,1,0), T.Accent, "Val", FONT_BOLD, 11, Enum.TextXAlignment.Right)

            local track = NewFrame(card, UDim2.new(1,0,0,8), UDim2.new(0,0,0,22), T.Panel, "Track")
            MakeRound(track, 4)

            local fill = NewFrame(track, UDim2.new(math.clamp(value/100,0,1),0,1,0), nil, color, "Fill")
            MakeRound(fill, 4)
            MakeGradient(fill, ColorSequence.new({
                ColorSequenceKeypoint.new(0, color),
                ColorSequenceKeypoint.new(1, Color3.new(
                    math.min(color.R + 0.15, 1),
                    math.min(color.G + 0.15, 1),
                    math.min(color.B + 0.15, 1)
                )),
            }), 0)

            -- Animated shimmer
            if animated then
                local shimmer = NewFrame(fill, UDim2.new(0,40,1,0), UDim2.new(-0.3,0,0,0), T.White, "Shimmer")
                MakeRound(shimmer, 4)
                shimmer.BackgroundTransparency = 0.7
                MakeGradient(shimmer, ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
                }), 0)

                local function AnimateShimmer()
                    shimmer.Position = UDim2.new(-0.3, 0, 0, 0)
                    Tween(shimmer, {Position = UDim2.new(1.2,0,0,0)}, 1.8, STYLE_SINE, EASE_INOUT)
                    task.delay(1.8, function()
                        if fill.Parent then AnimateShimmer() end
                    end)
                end
                task.spawn(AnimateShimmer)
            end

            local PB = {}
            function PB:Set(val, animate)
                value = math.clamp(val, 0, 100)
                valLbl.Text = tostring(math.floor(value)) .. suffix
                local pct = value / 100
                if animate ~= false then
                    Tween(fill, {Size = UDim2.new(pct,0,1,0)}, 0.4, STYLE_QUART, EASE_OUT)
                else
                    fill.Size = UDim2.new(pct,0,1,0)
                end
            end
            function PB:Get() return value end
            function PB:SetColor(c)
                color = c
                fill.BackgroundColor3 = c
            end
            return PB
        end

        -- ── INPUT (number stepper) ───────────────────────────────
        function Tab:AddStepper(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Value"
            local min      = opts.Min      or 0
            local max      = opts.Max      or 100
            local step     = opts.Step     or 1
            local default  = opts.Default  or min
            local suffix   = opts.Suffix   or ""
            local callback = opts.Callback or function() end
            local flag     = opts.Flag

            local value = math.clamp(default, min, max)

            local card = NewFrame(scroll, UDim2.new(1,0,0,36), nil, T.Card, "StepCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 0, 0, 12, 12)
            AddToScroll(card)

            local lbl = NewLabel(card, label, UDim2.new(0.5,0,1,0), T.Text, "Lbl", FONT_SEMI, 13)

            -- Stepper controls
            local ctrlFr = NewFrame(card, UDim2.new(0,100,1,0), UDim2.new(1,-102,0,0), T.Panel, "Ctrl")
            ctrlFr.BackgroundTransparency = 1

            local minusBtn = NewButton(ctrlFr, UDim2.new(0,26,0,26), UDim2.new(0,0,0.5,-13), T.Panel, "Minus")
            MakeRound(minusBtn, 5)
            MakeStroke(minusBtn, T.Border, 1, 0.4)
            NewLabel(minusBtn, Icons.Minus, UDim2.new(1,0,1,0), T.Accent, "ML", FONT_BOLD, 14, Enum.TextXAlignment.Center)

            local valDisplay = NewFrame(ctrlFr, UDim2.new(0,40,0,26), UDim2.new(0,30,0.5,-13), T.InputBg, "VD")
            MakeRound(valDisplay, 4)
            local valLbl2 = NewLabel(valDisplay, tostring(value) .. suffix, UDim2.new(1,0,1,0), T.Text, "VL", FONT_BOLD, 12, Enum.TextXAlignment.Center)

            local plusBtn = NewButton(ctrlFr, UDim2.new(0,26,0,26), UDim2.new(0,74,0.5,-13), T.Panel, "Plus")
            MakeRound(plusBtn, 5)
            MakeStroke(plusBtn, T.Border, 1, 0.4)
            NewLabel(plusBtn, Icons.Plus, UDim2.new(1,0,1,0), T.Accent, "PL", FONT_BOLD, 14, Enum.TextXAlignment.Center)

            local function UpdateStep(newVal)
                value = math.clamp(newVal, min, max)
                valLbl2.Text = tostring(value) .. suffix
                callback(value)
                if flag then NexusLib._flags[flag] = value end
            end

            local function BtnEffect(btn)
                btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = T.AccentDim}, 0.1) end)
                btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = T.Panel},     0.1) end)
                btn.MouseButton1Down:Connect(function() Tween(btn, {BackgroundColor3 = T.Accent}, 0.08) end)
                btn.MouseButton1Up:Connect(function()   Tween(btn, {BackgroundColor3 = T.Panel},  0.15) end)
            end
            BtnEffect(minusBtn)
            BtnEffect(plusBtn)

            minusBtn.MouseButton1Click:Connect(function() UpdateStep(value - step) end)
            plusBtn.MouseButton1Click:Connect(function()  UpdateStep(value + step) end)

            -- Hold to repeat
            local function HoldRepeat(btn, delta)
                btn.MouseButton1Down:Connect(function()
                    task.delay(0.5, function()
                        while btn.Active and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                            UpdateStep(value + delta)
                            task.wait(0.1)
                        end
                    end)
                end)
            end
            HoldRepeat(minusBtn, -step)
            HoldRepeat(plusBtn,   step)

            if flag then NexusLib._flags[flag] = value end

            local Step = {}
            function Step:Set(v) UpdateStep(v) end
            function Step:Get() return value end
            return Step
        end

        -- ── RADIO GROUP ─────────────────────────────────────────
        function Tab:AddRadioGroup(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Options"
            local options  = opts.Options  or {}
            local default  = opts.Default  or options[1]
            local callback = opts.Callback or function() end
            local flag     = opts.Flag

            local selected = default

            local card = NewFrame(scroll, UDim2.new(1,0,0,0), nil, T.Card, "RGCard")
            card.AutomaticSize = Enum.AutomaticSize.Y
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 8, 12, 12)
            MakeListLayout(card, Enum.SortOrder.LayoutOrder, UDim.new(0, 4))
            AddToScroll(card)

            local headerLbl = NewLabel(card, label, UDim2.new(1,0,0,16), T.TextMuted, "HL", FONT_SEMI, 11)
            headerLbl.LayoutOrder = 0

            local radioButtons = {}

            for i, opt in ipairs(options) do
                local row = NewButton(card, UDim2.new(1,0,0,28), nil, T.Card, "RO" .. i)
                row.LayoutOrder = i
                MakeRound(row, 5)
                MakePadding(row, 0, 0, 0, 0)

                -- Radio circle
                local outerCircle = NewFrame(row, UDim2.new(0,16,0,16), UDim2.new(0,4,0.5,-8), T.ToggleOff, "Out")
                MakeRound(outerCircle, 8)
                MakeStroke(outerCircle, T.Border, 1.5, 0.3)

                local innerCircle = NewFrame(outerCircle, UDim2.new(0,8,0,8), UDim2.new(0.5,-4,0.5,-4), T.Toggle, "In")
                MakeRound(innerCircle, 4)
                innerCircle.BackgroundTransparency = 1

                local optLbl = NewLabel(row, tostring(opt), UDim2.new(1,-28,1,0), T.Text, "OL", FONT_REG, 13)
                optLbl.Position = UDim2.new(0,26,0,0)

                local isSelected = opt == selected

                local function UpdateThis(sel)
                    if sel then
                        Tween(outerCircle, {BackgroundColor3 = T.Toggle}, 0.2)
                        Tween(innerCircle, {BackgroundTransparency = 0}, 0.2)
                        Tween(optLbl,      {TextColor3 = T.Accent}, 0.2)
                    else
                        Tween(outerCircle, {BackgroundColor3 = T.ToggleOff}, 0.2)
                        Tween(innerCircle, {BackgroundTransparency = 1}, 0.2)
                        Tween(optLbl,      {TextColor3 = T.Text}, 0.2)
                    end
                end

                if isSelected then UpdateThis(true) end

                table.insert(radioButtons, { btn = row, update = UpdateThis, opt = opt })

                row.MouseEnter:Connect(function() Tween(row, {BackgroundColor3 = T.CardHover}, 0.1) end)
                row.MouseLeave:Connect(function() Tween(row, {BackgroundColor3 = T.Card},      0.1) end)
                row.MouseButton1Click:Connect(function()
                    selected = opt
                    for _, rb in ipairs(radioButtons) do
                        rb.update(rb.opt == opt)
                    end
                    callback(opt)
                    if flag then NexusLib._flags[flag] = opt end
                end)
            end

            if flag then NexusLib._flags[flag] = selected end

            local RG = {}
            function RG:Set(v)
                selected = v
                for _, rb in ipairs(radioButtons) do rb.update(rb.opt == v) end
                callback(v)
                if flag then NexusLib._flags[flag] = v end
            end
            function RG:Get() return selected end
            return RG
        end

        -- ── TABLE / LIST VIEW ───────────────────────────────────
        function Tab:AddTable(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Table"
            local columns  = opts.Columns  or {"Column 1", "Column 2"}
            local rows     = opts.Rows     or {}
            local maxRows  = opts.MaxRows  or 6
            local sortable = opts.Sortable or false

            local rowH = 26
            local headerH = 24
            local tableH  = headerH + math.min(#rows, maxRows) * rowH + 8

            local card = NewFrame(scroll, UDim2.new(1,0,0,0), nil, T.Card, "TblCard")
            card.AutomaticSize = Enum.AutomaticSize.Y
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 6, 6, 6, 6)
            AddToScroll(card)

            -- Table label
            local lblFr = NewLabel(card, label, UDim2.new(1,0,0,14), T.TextMuted, "TLbl", FONT_SEMI, 11)

            -- Header row
            local headerFr = NewFrame(card, UDim2.new(1,0,0,headerH), UDim2.new(0,0,0,16), T.Panel, "Header")
            MakeRound(headerFr, 5)
            local colW = 1 / #columns

            for i, col in ipairs(columns) do
                local hLbl = NewLabel(headerFr, col, UDim2.new(colW,0,1,0), T.Accent, "H" .. i, FONT_BOLD, 11)
                hLbl.Position = UDim2.new(colW * (i-1), 4, 0, 0)
                hLbl.TextXAlignment = Enum.TextXAlignment.Left
            end

            -- Row scroll
            local rowScroll = NewScroll(card, UDim2.new(1,0,0,math.min(#rows, maxRows)*rowH),
                UDim2.new(0,0,0,16+headerH+4), T.Scrollbar, "Rows")
            rowScroll.CanvasSize = UDim2.new(0,0,0,#rows*rowH)
            rowScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
            MakeListLayout(rowScroll, Enum.SortOrder.LayoutOrder, UDim.new(0, 1))

            local rowElements = {}

            local function PopulateRows(data)
                for _, el in ipairs(rowElements) do el:Destroy() end
                rowElements = {}
                for ri, row in ipairs(data) do
                    local rowFr = NewFrame(rowScroll, UDim2.new(1,0,0,rowH), nil,
                        ri % 2 == 0 and T.Panel or T.Card, "Row" .. ri)
                    rowFr.LayoutOrder = ri

                    for ci, cell in ipairs(row) do
                        local cLbl = NewLabel(rowFr, tostring(cell), UDim2.new(colW,-4,1,0), T.Text, "C" .. ci, FONT_REG, 11)
                        cLbl.Position = UDim2.new(colW*(ci-1), 4, 0, 0)
                        cLbl.TextXAlignment = Enum.TextXAlignment.Left
                    end

                    rowFr.MouseEnter:Connect(function() Tween(rowFr, {BackgroundColor3 = T.CardHover}, 0.1) end)
                    rowFr.MouseLeave:Connect(function()
                        Tween(rowFr, {BackgroundColor3 = ri%2==0 and T.Panel or T.Card}, 0.1)
                    end)

                    table.insert(rowElements, rowFr)
                end
                rowScroll.CanvasSize = UDim2.new(0,0,0,#data*rowH)
                rowScroll.Size = UDim2.new(1,0,0,math.min(#data,maxRows)*rowH)
            end

            PopulateRows(rows)

            local Tbl = {}
            function Tbl:SetRows(newRows)
                rows = newRows
                PopulateRows(rows)
            end
            function Tbl:AddRow(row)
                table.insert(rows, row)
                PopulateRows(rows)
            end
            function Tbl:Clear()
                rows = {}
                PopulateRows(rows)
            end
            function Tbl:GetRows() return rows end
            return Tbl
        end

        -- ── IMAGE DISPLAY ────────────────────────────────────────
        function Tab:AddImage(opts)
            opts = opts or {}
            local T       = self._T
            local asset   = opts.Asset   or ""
            local height  = opts.Height  or 120
            local label   = opts.Label   or ""
            local rounded = opts.Rounded ~= false

            local card = NewFrame(scroll, UDim2.new(1,0,0,height + (label ~= "" and 22 or 0)), nil, T.Card, "ImgCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            AddToScroll(card)

            local imgFr = NewFrame(card, UDim2.new(1,0,0,height), nil, T.Panel, "ImgFr")
            if rounded then MakeRound(imgFr, 8) end

            local img = NewImage(imgFr, asset, UDim2.new(1,0,1,0), nil, "Img")
            img.ScaleType = Enum.ScaleType.Crop

            if label ~= "" then
                local capLbl = NewLabel(card, label, UDim2.new(1,0,0,18), T.TextMuted, "Cap", FONT_REG, 11, Enum.TextXAlignment.Center)
                capLbl.Position = UDim2.new(0,0,0,height+2)
            end

            local Img = {}
            function Img:SetAsset(a) img.Image = a end
            function Img:SetHeight(h)
                card.Size   = UDim2.new(1,0,0,h+(label~="" and 22 or 0))
                imgFr.Size  = UDim2.new(1,0,0,h)
                if label ~= "" then
                    local cap = card:FindFirstChild("Cap")
                    if cap then cap.Position = UDim2.new(0,0,0,h+2) end
                end
            end
            return Img
        end

        -- ── CHART (simple bar chart) ──────────────────────────────
        function Tab:AddBarChart(opts)
            opts = opts or {}
            local T       = self._T
            local label   = opts.Label   or "Chart"
            local data    = opts.Data    or {}  -- { { Label = "A", Value = 50, Color = ... }, ... }
            local maxVal  = opts.MaxValue
            local height  = opts.Height  or 100
            local showLabels = opts.ShowLabels ~= false

            -- Compute maxVal
            if not maxVal then
                maxVal = 0
                for _, d in ipairs(data) do maxVal = math.max(maxVal, d.Value or 0) end
                maxVal = maxVal == 0 and 1 or maxVal
            end

            local extraH = showLabels and 18 or 0
            local card = NewFrame(scroll, UDim2.new(1,0,0,height + 24 + extraH), nil, T.Card, "ChartCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 8, 12, 12)
            AddToScroll(card)

            local titleLbl = NewLabel(card, label, UDim2.new(1,0,0,14), T.TextMuted, "ChL", FONT_SEMI, 11)
            titleLbl.Position = UDim2.new(0,0,0,0)

            local chartFr = NewFrame(card, UDim2.new(1,0,0,height), UDim2.new(0,0,0,16), T.Panel, "ChFr")
            MakeRound(chartFr, 6)

            local barW = 1 / math.max(#data, 1)
            local barElements = {}

            local function RenderBars(d, maxV)
                for _, el in ipairs(barElements) do el:Destroy() end
                barElements = {}
                for i, item in ipairs(d) do
                    local pct = math.clamp((item.Value or 0) / maxV, 0, 1)
                    local barColor = item.Color or T.Accent
                    local pad = 3
                    local barContainer = NewFrame(chartFr,
                        UDim2.new(barW, -pad*2, 1, 0),
                        UDim2.new(barW*(i-1), pad, 0, 0),
                        T.Panel, "B" .. i)
                    barContainer.BackgroundTransparency = 1

                    local bar = NewFrame(barContainer, UDim2.new(1,0,0,0), UDim2.new(0,0,1,0), barColor, "Bar")
                    MakeRound(bar, 4)
                    -- Animate bar up
                    task.spawn(function()
                        task.wait(0.05 * i)
                        Tween(bar, {Size = UDim2.new(1,0,pct,0), Position = UDim2.new(0,0,1-pct,0)}, 0.5, STYLE_BACK, EASE_OUT)
                    end)

                    -- Value label on hover
                    local valTip = NewLabel(barContainer, tostring(item.Value), UDim2.new(1,0,0,14),
                        T.White, "VTip", FONT_BOLD, 9, Enum.TextXAlignment.Center)
                    valTip.Position = UDim2.new(0,0,1-pct,-16)
                    valTip.BackgroundTransparency = 1
                    valTip.TextTransparency = 1

                    bar.MouseEnter:Connect(function()
                        Tween(bar, {BackgroundColor3 = Color3.new(
                            math.min(barColor.R+0.1,1),
                            math.min(barColor.G+0.1,1),
                            math.min(barColor.B+0.1,1))}, 0.1)
                        Tween(valTip, {TextTransparency = 0}, 0.1)
                    end)
                    bar.MouseLeave:Connect(function()
                        Tween(bar, {BackgroundColor3 = barColor}, 0.1)
                        Tween(valTip, {TextTransparency = 1}, 0.1)
                    end)

                    if showLabels and item.Label then
                        local capLbl = NewLabel(chartFr, item.Label,
                            UDim2.new(barW,-pad*2,0,extraH),
                            T.TextDim, "Cap" .. i, FONT_REG, 9, Enum.TextXAlignment.Center)
                        capLbl.Position = UDim2.new(barW*(i-1),pad,1,0)
                        table.insert(barElements, capLbl)
                    end

                    table.insert(barElements, barContainer)
                end
            end

            RenderBars(data, maxVal)

            local Chart = {}
            function Chart:SetData(newData, newMax)
                data   = newData
                maxVal = newMax or maxVal
                if not newMax then
                    maxVal = 0
                    for _, d in ipairs(data) do maxVal = math.max(maxVal, d.Value or 0) end
                    maxVal = maxVal == 0 and 1 or maxVal
                end
                RenderBars(data, maxVal)
            end
            function Chart:AddBar(item)
                table.insert(data, item)
                maxVal = math.max(maxVal, item.Value or 0)
                RenderBars(data, maxVal)
            end
            return Chart
        end

        -- ── LINE CHART ───────────────────────────────────────────
        function Tab:AddLineChart(opts)
            opts = opts or {}
            local T      = self._T
            local label  = opts.Label  or "Line Chart"
            local data   = opts.Data   or {}  -- array of numbers
            local color  = opts.Color  or T.Accent
            local height = opts.Height or 80
            local filled = opts.Filled ~= false

            local card = NewFrame(scroll, UDim2.new(1,0,0,height+24), nil, T.Card, "LCCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 8, 12, 12)
            AddToScroll(card)

            local titleLbl = NewLabel(card, label, UDim2.new(1,0,0,14), T.TextMuted, "LCL", FONT_SEMI, 11)

            local canvas = NewFrame(card, UDim2.new(1,0,0,height), UDim2.new(0,0,0,16), T.Panel, "Canvas")
            MakeRound(canvas, 6)
            MakePadding(canvas, 4, 4, 4, 4)

            local pointElements = {}

            local function RenderLine(d)
                for _, el in ipairs(pointElements) do el:Destroy() end
                pointElements = {}
                if #d < 2 then return end

                local minV, maxV = math.huge, -math.huge
                for _, v in ipairs(d) do
                    minV = math.min(minV, v)
                    maxV = math.max(maxV, v)
                end
                if maxV == minV then maxV = minV + 1 end

                local function NormX(i) return (i-1) / (#d-1) end
                local function NormY(v) return 1 - (v - minV) / (maxV - minV) end

                -- Draw line segments
                for i = 1, #d - 1 do
                    local x1, y1 = NormX(i),   NormY(d[i])
                    local x2, y2 = NormX(i+1), NormY(d[i+1])

                    local dx = (x2 - x1) * canvas.AbsoluteSize.X
                    local dy = (y2 - y1) * canvas.AbsoluteSize.Y
                    local len = math.sqrt(dx*dx + dy*dy)
                    local angle = math.deg(math.atan2(dy, dx))

                    local midX = (x1 + x2) / 2
                    local midY = (y1 + y2) / 2

                    local seg = NewFrame(canvas, UDim2.new(0, len, 0, 2),
                        UDim2.new(midX, -len/2, midY, -1), color, "Seg" .. i)
                    seg.Rotation = angle
                    seg.BackgroundTransparency = 0.2
                    table.insert(pointElements, seg)
                end

                -- Draw dots
                for i, v in ipairs(d) do
                    local x, y = NormX(i), NormY(v)
                    local dot = NewFrame(canvas, UDim2.new(0,6,0,6), UDim2.new(x,-3,y,-3), color, "Dot"..i)
                    MakeRound(dot, 3)
                    table.insert(pointElements, dot)
                end
            end

            RenderLine(data)

            local LC = {}
            function LC:SetData(d) data = d RenderLine(d) end
            function LC:AddPoint(v) table.insert(data, v) RenderLine(data) end
            function LC:Clear() data = {} RenderLine(data) end
            return LC
        end

        -- ── ALERT BOX ───────────────────────────────────────────
        function Tab:AddAlert(opts)
            opts = opts or {}
            local T       = self._T
            local message = opts.Message or "Alert"
            local atype   = opts.Type    or "Info"  -- Info, Success, Warning, Error
            local icon    = opts.Icon    or nil
            local dismiss = opts.Dismiss or false

            local typeMap = {
                Info    = { color = T.Info,    bg = T.InfoDim,    defaultIcon = Icons.Info  },
                Success = { color = T.Success, bg = T.SuccessDim, defaultIcon = Icons.Check },
                Warning = { color = T.Warning, bg = T.WarningDim, defaultIcon = Icons.Warn  },
                Error   = { color = T.Danger,  bg = T.DangerDim,  defaultIcon = Icons.Cross },
            }
            local td = typeMap[atype] or typeMap.Info

            local card = NewFrame(scroll, UDim2.new(1,0,0,0), nil, td.bg, "AlertCard")
            card.AutomaticSize = Enum.AutomaticSize.Y
            MakeRound(card, 8)
            MakeStroke(card, td.color, 1, 0.6)
            MakePadding(card, 8, 8, 10, dismiss and 30 or 10)
            AddToScroll(card)

            -- Left border strip
            local strip = NewFrame(card, UDim2.new(0,3,1,0), nil, td.color, "Strip")
            strip.BackgroundTransparency = 0.3
            MakeRound(strip, 2)

            local msgRow = NewFrame(card, UDim2.new(1,0,0,0), nil, td.bg, "MRow")
            msgRow.AutomaticSize = Enum.AutomaticSize.Y
            msgRow.BackgroundTransparency = 1

            local iconLbl = NewLabel(msgRow, icon or td.defaultIcon, UDim2.new(0,16,0,16), td.color, "Icon", FONT_BOLD, 13)
            local msgLbl  = NewLabel(msgRow, message, UDim2.new(1,-20,0,0), td.color, "Msg", FONT_REG, 12)
            msgLbl.Position      = UDim2.new(0,20,0,0)
            msgLbl.TextWrapped   = true
            msgLbl.AutomaticSize = Enum.AutomaticSize.Y

            if dismiss then
                local dismissBtn = NewButton(card, UDim2.new(0,18,0,18), UDim2.new(1,-20,0.5,-9), td.bg, "Dis", 1)
                local disLbl = NewLabel(dismissBtn, Icons.Close, UDim2.new(1,0,1,0), td.color, "DL", FONT_BOLD, 9, Enum.TextXAlignment.Center)
                dismissBtn.MouseButton1Click:Connect(function()
                    Tween(card, {Size = UDim2.new(1,0,0,0), BackgroundTransparency = 1}, 0.25)
                    task.delay(0.25, function() card:Destroy() end)
                end)
            end

            local Alert = {}
            function Alert:SetMessage(m) msgLbl.Text = m end
            function Alert:Dismiss()
                Tween(card, {Size = UDim2.new(1,0,0,0), BackgroundTransparency = 1}, 0.25)
                task.delay(0.25, function() card:Destroy() end)
            end
            return Alert
        end

        -- ── ACCORDION / COLLAPSIBLE ──────────────────────────────
        function Tab:AddAccordion(opts)
            opts = opts or {}
            local T      = self._T
            local title  = opts.Title  or "Section"
            local open   = opts.Open   or false

            local card = NewFrame(scroll, UDim2.new(1,0,0,36), nil, T.Card, "AccCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            AddToScroll(card)

            -- Header (clickable)
            local header = NewButton(card, UDim2.new(1,0,0,36), nil, T.Card, "Head")
            MakeRound(header, 8)
            MakePadding(header, 0, 0, 12, 12)

            local titleLbl = NewLabel(header, title, UDim2.new(1,-28,1,0), T.Text, "TLbl", FONT_SEMI, 13)
            local arrowLbl = NewLabel(header, Icons.Chevron, UDim2.new(0,18,1,0), T.TextMuted, "Arr", FONT_BOLD, 12, Enum.TextXAlignment.Center)
            arrowLbl.Position = UDim2.new(1,-20,0,0)

            -- Content container
            local content = NewFrame(card, UDim2.new(1,0,0,0), UDim2.new(0,0,0,36), T.Card, "Content")
            content.ClipsDescendants = true
            content.BackgroundTransparency = 1

            local innerScroll = NewScroll(content, UDim2.new(1,0,0,0), nil, T.Scrollbar, "IScroll")
            innerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            MakeListLayout(innerScroll, Enum.SortOrder.LayoutOrder, UDim.new(0, 4))
            MakePadding(innerScroll, 4, 8, 8, 8)

            local expanded  = open
            local contentH  = 0

            -- Sub-tab object for adding elements into accordion
            local AccordionTab = {
                _scroll = innerScroll,
                _T      = T,
            }
            -- Inherit all Tab element factories
            for k, v in pairs(Tab) do
                if type(v) == "function" and k ~= "AddAccordion" then
                    AccordionTab[k] = v
                end
            end
            AccordionTab._scroll = innerScroll

            local function UpdateExpanded(animate)
                if expanded then
                    innerScroll.Size = UDim2.new(1,0,0,0)
                    -- Wait a frame for layout to compute
                    task.spawn(function()
                        task.wait()
                        contentH = innerScroll.AbsoluteCanvasSize.Y + 16
                        if animate then
                            Tween(card,    {Size = UDim2.new(1,0,0,36+contentH)}, 0.3, STYLE_QUART, EASE_OUT)
                            Tween(content, {Size = UDim2.new(1,0,0,contentH)},    0.3, STYLE_QUART, EASE_OUT)
                            innerScroll.Size = UDim2.new(1,0,0,contentH)
                        else
                            card.Size    = UDim2.new(1,0,0,36+contentH)
                            content.Size = UDim2.new(1,0,0,contentH)
                            innerScroll.Size = UDim2.new(1,0,0,contentH)
                        end
                    end)
                    Tween(arrowLbl, {Rotation = 180}, 0.25)
                else
                    Tween(card,    {Size = UDim2.new(1,0,0,36)}, 0.3, STYLE_QUART, EASE_OUT)
                    Tween(content, {Size = UDim2.new(1,0,0,0)},  0.3, STYLE_QUART, EASE_OUT)
                    Tween(arrowLbl, {Rotation = 0}, 0.25)
                end
            end

            header.MouseButton1Click:Connect(function()
                expanded = not expanded
                UpdateExpanded(true)
            end)
            header.MouseEnter:Connect(function() Tween(header, {BackgroundColor3 = T.CardHover}, 0.1) end)
            header.MouseLeave:Connect(function() Tween(header, {BackgroundColor3 = T.Card},      0.1) end)

            if expanded then task.spawn(function() task.wait() UpdateExpanded(false) end) end

            local Acc = {}
            function Acc:GetTab()  return AccordionTab end
            function Acc:Expand()  expanded = true  UpdateExpanded(true) end
            function Acc:Collapse() expanded = false UpdateExpanded(true) end
            function Acc:Toggle()  expanded = not expanded UpdateExpanded(true) end
            return Acc
        end

        -- ── HOTBAR (quick action buttons row) ───────────────────
        function Tab:AddHotbar(opts)
            opts = opts or {}
            local T       = self._T
            local buttons = opts.Buttons or {}  -- { { Label, Icon, Callback, Tooltip }, ... }
            local columns = opts.Columns or #buttons

            local card = NewFrame(scroll, UDim2.new(1,0,0,48), nil, T.Card, "HBCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 4, 4, 6, 6)
            AddToScroll(card)

            local layout = Instance.new("UIListLayout")
            layout.FillDirection        = Enum.FillDirection.Horizontal
            layout.SortOrder            = Enum.SortOrder.LayoutOrder
            layout.VerticalAlignment    = Enum.VerticalAlignment.Center
            layout.Padding              = UDim.new(0, 4)
            layout.Parent               = card

            for i, btnOpts in ipairs(buttons) do
                local w = (1 / columns) * (1 - 0.01 * (columns - 1))
                local btn = NewButton(card, UDim2.new(w, -4, 1, -8), nil, T.Panel, "HBtn" .. i)
                MakeRound(btn, 6)
                MakeStroke(btn, T.Border, 1, 0.5)
                btn.LayoutOrder = i

                if btnOpts.Icon then
                    local iconLbl = NewLabel(btn, btnOpts.Icon, UDim2.new(1,0,1,0), T.Accent, "I", FONT_REG, 14, Enum.TextXAlignment.Center)
                end
                if btnOpts.Label then
                    local lbl = NewLabel(btn, btnOpts.Label, UDim2.new(1,0,1,0), T.Text, "L", FONT_SEMI, 10, Enum.TextXAlignment.Center)
                    if btnOpts.Icon then
                        lbl.Size     = UDim2.new(1,0,0,12)
                        lbl.Position = UDim2.new(0,0,1,-14)
                    end
                end

                btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = T.AccentDim}, 0.1) end)
                btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = T.Panel},     0.1) end)
                btn.MouseButton1Down:Connect(function() Tween(btn, {BackgroundColor3 = T.Accent}, 0.08) end)
                btn.MouseButton1Up:Connect(function()
                    Tween(btn, {BackgroundColor3 = T.Panel}, 0.15)
                    if btnOpts.Callback then btnOpts.Callback() end
                end)

                if btnOpts.Tooltip then AttachTooltip(btn, btnOpts.Tooltip, T) end
            end

            return card
        end

        -- ── SEARCH BOX ──────────────────────────────────────────
        function Tab:AddSearchBox(opts)
            opts = opts or {}
            local T        = self._T
            local placeholder = opts.Placeholder or "Search..."
            local callback = opts.Callback or function() end
            local live     = opts.Live ~= false

            local card = NewFrame(scroll, UDim2.new(1,0,0,34), nil, T.Card, "SBCard")
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 2, 2, 8, 8)
            AddToScroll(card)

            -- Search icon
            local iconLbl = NewLabel(card, Icons.Search, UDim2.new(0,20,1,0), T.TextDim, "SIcon", FONT_REG, 14)
            iconLbl.Position = UDim2.new(0,4,0,0)
            iconLbl.TextXAlignment = Enum.TextXAlignment.Center

            -- Clear button
            local clearBtn = NewButton(card, UDim2.new(0,20,1,0), UDim2.new(1,-24,0,0), T.Card, "Clear", 1)
            local clearLbl = NewLabel(clearBtn, Icons.Close, UDim2.new(1,0,1,0), T.TextDim, "CL", FONT_BOLD, 9, Enum.TextXAlignment.Center)
            clearBtn.Visible = false

            local tb = Instance.new("TextBox")
            tb.Size              = UDim2.new(1,-50,1,0)
            tb.Position          = UDim2.new(0,26,0,0)
            tb.BackgroundTransparency = 1
            tb.TextColor3        = T.Text
            tb.PlaceholderColor3 = T.TextDim
            tb.PlaceholderText   = placeholder
            tb.Font              = FONT_REG
            tb.TextSize          = 12
            tb.ClearTextOnFocus  = false
            tb.TextXAlignment    = Enum.TextXAlignment.Left
            tb.Parent            = card

            tb:GetPropertyChangedSignal("Text"):Connect(function()
                clearBtn.Visible = tb.Text ~= ""
                if live then callback(tb.Text) end
            end)
            tb.FocusLost:Connect(function(enter)
                if not live or enter then callback(tb.Text) end
            end)
            clearBtn.MouseButton1Click:Connect(function()
                tb.Text = ""
                callback("")
            end)

            local SB = {}
            function SB:Set(v) tb.Text = v end
            function SB:Get() return tb.Text end
            function SB:Clear() tb.Text = "" callback("") end
            return SB
        end

        -- ── BADGE / TAG ROW ─────────────────────────────────────
        function Tab:AddBadges(opts)
            opts = opts or {}
            local T      = self._T
            local label  = opts.Label  or ""
            local badges = opts.Badges or {}  -- { { Text, Color, BgColor }, ... }

            local card = NewFrame(scroll, UDim2.new(1,0,0,0), nil, T.Card, "BadgeCard")
            card.AutomaticSize = Enum.AutomaticSize.Y
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 6, 6, 10, 10)
            AddToScroll(card)

            if label ~= "" then
                local lbl = NewLabel(card, label, UDim2.new(1,0,0,14), T.TextMuted, "BL", FONT_SEMI, 11)
                lbl.Position = UDim2.new(0,0,0,0)
            end

            local badgeRow = NewFrame(card, UDim2.new(1,0,0,22), UDim2.new(0,0,0, label~="" and 16 or 0), T.Card, "BRow")
            badgeRow.BackgroundTransparency = 1
            badgeRow.AutomaticSize = Enum.AutomaticSize.Y

            local flowLayout = Instance.new("UIListLayout")
            flowLayout.FillDirection = Enum.FillDirection.Horizontal
            flowLayout.SortOrder     = Enum.SortOrder.LayoutOrder
            flowLayout.Padding       = UDim.new(0, 4)
            flowLayout.Wraps         = true
            flowLayout.Parent        = badgeRow

            for i, b in ipairs(badges) do
                local bgColor = b.BgColor or T.AccentDim
                local fgColor = b.Color   or T.Accent

                local badge = NewFrame(badgeRow, UDim2.new(0,0,0,20), nil, bgColor, "Bdg" .. i)
                badge.AutomaticSize = Enum.AutomaticSize.X
                badge.LayoutOrder   = i
                MakeRound(badge, 10)
                MakePadding(badge, 0, 0, 8, 8)

                local bLbl = NewLabel(badge, b.Text or "Tag", UDim2.new(0,0,1,0), fgColor, "L", FONT_BOLD, 9)
                bLbl.AutomaticSize = Enum.AutomaticSize.X
                bLbl.TextXAlignment = Enum.TextXAlignment.Center
            end

            local Badges = {}
            function Badges:Add(b)
                local bgColor = b.BgColor or T.AccentDim
                local fgColor = b.Color   or T.Accent
                local badge   = NewFrame(badgeRow, UDim2.new(0,0,0,20), nil, bgColor, "Bdg")
                badge.AutomaticSize = Enum.AutomaticSize.X
                badge.LayoutOrder   = #badgeRow:GetChildren()
                MakeRound(badge, 10)
                MakePadding(badge, 0, 0, 8, 8)
                local bLbl = NewLabel(badge, b.Text or "", UDim2.new(0,0,1,0), fgColor, "L", FONT_BOLD, 9)
                bLbl.AutomaticSize = Enum.AutomaticSize.X
            end
            function Badges:Clear()
                for _, ch in ipairs(badgeRow:GetChildren()) do
                    if not ch:IsA("UIListLayout") then ch:Destroy() end
                end
            end
            return Badges
        end

        table.insert(Window._tabs, Tab)
        return Tab
    end -- AddTab

    -- ── GLOBAL SEARCH ─────────────────────────────────────────────
    function Window:AddSearch()
        -- Adds a search icon to title bar that lets user filter elements
        local T = self._T
        local searchActive = false
        local searchBtn = NewButton(titleBar, UDim2.new(0,22,0,22), UDim2.new(1,-86,0.5,-11), T.Panel, "SearchBtn")
        MakeRound(searchBtn, 6)
        local searchIcon = NewLabel(searchBtn, Icons.Search, UDim2.new(1,0,1,0), T.TextMuted, "SI", FONT_REG, 13, Enum.TextXAlignment.Center)
        searchBtn.MouseEnter:Connect(function() Tween(searchBtn, {BackgroundColor3 = T.Card}, 0.15) end)
        searchBtn.MouseLeave:Connect(function() Tween(searchBtn, {BackgroundColor3 = T.Panel}, 0.15) end)
        searchBtn.MouseButton1Click:Connect(function()
            searchActive = not searchActive
            -- Could implement a search overlay here
        end)
    end

    -- Expose flag registry access
    function Window:GetFlag(flag) return NexusLib._flags[flag] end
    function Window:SetFlag(flag, val) NexusLib._flags[flag] = val end
    function Window:GetAllFlags() return NexusLib._flags end

    -- Destroy window
    function Window:Destroy()
        Tween(win,      {BackgroundTransparency = 1, Size = UDim2.new(0, winW, 0, 0)}, 0.25)
        Tween(shadowFr, {BackgroundTransparency = 1}, 0.25)
        task.delay(0.25, function() sg:Destroy() end)
    end

    -- Toggle visibility
    function Window:Toggle(visible)
        if visible == nil then visible = not win.Visible end
        win.Visible    = visible
        shadowFr.Visible = visible
    end

    table.insert(NexusLib._windows, Window)
    return Window
end

-- ============================================================
--  LIBRARY UTILITIES
-- ============================================================

--- Get all windows
function NexusLib:GetWindows()
    return self._windows
end

--- Get all flags
function NexusLib:GetFlags()
    return self._flags
end

--- Get a specific flag by name
function NexusLib:GetFlag(name)
    return self._flags[name]
end

--- Destroy all windows
function NexusLib:DestroyAll()
    for _, win in ipairs(self._windows) do
        pcall(function() win:Destroy() end)
    end
    self._windows = {}
end

--- Get available themes
function NexusLib:GetThemeNames()
    local names = {}
    for k in pairs(Themes) do table.insert(names, k) end
    table.sort(names)
    return names
end

--- Add a custom theme
---@param name string
---@param theme table
function NexusLib:AddTheme(name, theme)
    assert(type(name) == "string", "Theme name must be a string")
    assert(type(theme) == "table", "Theme must be a table")
    -- Fill in any missing keys from the Dark theme as fallback
    local base = Themes.Dark
    for k, v in pairs(base) do
        if theme[k] == nil then
            theme[k] = v
        end
    end
    Themes[name] = theme
end

--- Show a quick confirm dialog
---@param message string
---@param onConfirm function
---@param onCancel function
---@param themeName string
function NexusLib:Confirm(message, onConfirm, onCancel, themeName)
    local T = Themes[themeName or "Dark"] or Themes.Dark
    ShowModal({
        Title   = "Confirm",
        Message = message,
        Icon    = "?",
        IconColor = T.Warning,
        Buttons = {
            { Label = "Cancel",  Primary = false, Callback = onCancel  },
            { Label = "Confirm", Primary = true,  Callback = onConfirm },
        }
    }, T)
end

--- Show a quick alert modal
function NexusLib:Alert(title, message, themeName)
    local T = Themes[themeName or "Dark"] or Themes.Dark
    ShowModal({
        Title   = title or "Alert",
        Message = message or "",
        Icon    = Icons.Info,
        IconColor = T.Info,
        Buttons = {{ Label = "OK", Primary = true, Callback = function() end }},
    }, T)
end

--- Animate a number from a to b over duration, calling callback each step
---@param from number
---@param to number
---@param duration number
---@param callback function(value)
---@param onDone function?
function NexusLib:AnimateValue(from, to, duration, callback, onDone)
    local startTime = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local alpha   = math.min(elapsed / duration, 1)
        -- ease out quart
        local t = 1 - (1 - alpha)^4
        callback(from + (to - from) * t)
        if alpha >= 1 then
            conn:Disconnect()
            if onDone then onDone() end
        end
    end)
end

-- ============================================================
--  EXPOSE ICONS & UTILITIES
-- ============================================================
NexusLib.Icons   = Icons
NexusLib.Tween   = Tween

-- ============================================================
--  RETURN
-- ============================================================
return NexusLib
