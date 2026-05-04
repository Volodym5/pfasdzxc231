--[[
╔══════════════════════════════════════════════════════════════════════════════════╗
║                                                                                  ║
║                          N E X U S L I B  v2.0                                  ║
║                    A Professional Roblox UI Framework                            ║
║                                                                                  ║
║  Features:                                                                       ║
║    • Multi-tab windows with sidebar navigation                                   ║
║    • Buttons, Toggles, Sliders, Dropdowns, TextBoxes                            ║
║    • Keybinds, ColorPickers, Labels, Paragraphs, Sections                       ║
║    • Multi-select Dropdowns, Input Validation                                    ║
║    • Searchable Dropdowns                                                        ║
║    • Progress Bars                                                               ║
║    • Image Elements                                                              ║
║    • Tooltip system                                                              ║
║    • Notification system (stacked, animated)                                    ║
║    • Config save/load system (writefile support)                                 ║
║    • Draggable windows                                                           ║
║    • Minimise / Close / Resize                                                   ║
║    • Window blur (fake frosted glass via gradient)                               ║
║    • Fully themeable (7 built-in themes + custom theme API)                     ║
║    • Mobile / Touch support                                                      ║
║    • Smooth animations throughout                                                ║
║    • ZIndex management (no clipping issues)                                      ║
║    • Tab icons (rbxassetid or unicode emoji)                                    ║
║    • Section collapsing                                                          ║
║    • Watermark element                                                           ║
║    • Bind to hide (keybind to show/hide entire UI)                              ║
║                                                                                  ║
║  Usage:                                                                          ║
║    local NexusLib = loadstring(game:HttpGet("URL"))()                            ║
║    local W = NexusLib:Window({ Title="Hub", Theme="Midnight" })                 ║
║    local Tab = W:Tab({ Name="Main", Icon="🏠" })                                ║
║    Tab:Button({ Label="Click", Callback=function() end })                        ║
║                                                                                  ║
╚══════════════════════════════════════════════════════════════════════════════════╝
]]

-- ════════════════════════════════════════════════════════════════
--  STRICT ENVIRONMENT GUARD
-- ════════════════════════════════════════════════════════════════
local _ENV = _ENV or getfenv()
assert(game and game:IsA("DataModel"), "[NexusLib] Must run inside Roblox!")

-- ════════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════════
local Players            = game:GetService("Players")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local RunService         = game:GetService("RunService")
local TextService        = game:GetService("TextService")
local HttpService        = game:GetService("HttpService")
local CoreGui            = game:GetService("CoreGui")
local GuiService         = game:GetService("GuiService")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")
local Mouse        = LocalPlayer:GetMouse()
local Camera       = workspace.CurrentCamera

-- ════════════════════════════════════════════════════════════════
--  CONSTANTS
-- ════════════════════════════════════════════════════════════════
local TWEEN_FAST    = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_MED     = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_SLOW    = TweenInfo.new(0.40, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_SPRING  = TweenInfo.new(0.50, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)
local TWEEN_ELASTIC = TweenInfo.new(0.60, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local TWEEN_BOUNCE  = TweenInfo.new(0.40, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)

local SIDEBAR_W     = 160
local TITLEBAR_H    = 52
local ELEMENT_H     = 38
local ELEMENT_PAD   = 6
local CORNER_RADIUS = UDim.new(0, 8)
local CORNER_LARGE  = UDim.new(0, 12)
local CORNER_FULL   = UDim.new(1, 0)
local ZBASE         = 10

-- ════════════════════════════════════════════════════════════════
--  THEME DEFINITIONS
-- ════════════════════════════════════════════════════════════════
local Themes = {}

Themes.Midnight = {
    Name            = "Midnight",
    -- Window
    WindowBG        = Color3.fromRGB(12,  12,  18),
    TitleBG         = Color3.fromRGB(18,  18,  28),
    SidebarBG       = Color3.fromRGB(15,  15,  22),
    ContentBG       = Color3.fromRGB(12,  12,  18),
    -- Elements
    ElementBG       = Color3.fromRGB(22,  22,  34),
    ElementHover    = Color3.fromRGB(30,  30,  46),
    ElementActive   = Color3.fromRGB(38,  38,  58),
    -- Accent
    Accent          = Color3.fromRGB(99,  102, 241),
    AccentDark      = Color3.fromRGB(67,  70,  190),
    AccentLight     = Color3.fromRGB(139, 142, 255),
    AccentGlow      = Color3.fromRGB(99,  102, 241),
    -- Text
    TextPrimary     = Color3.fromRGB(242, 242, 255),
    TextSecondary   = Color3.fromRGB(160, 160, 195),
    TextMuted       = Color3.fromRGB(90,  90,  130),
    TextDisabled    = Color3.fromRGB(55,  55,  80),
    -- Status
    Success         = Color3.fromRGB(52,  211, 153),
    Warning         = Color3.fromRGB(251, 191, 36),
    Danger          = Color3.fromRGB(248, 113, 113),
    Info            = Color3.fromRGB(96,  165, 250),
    -- Borders / Misc
    Border          = Color3.fromRGB(40,  40,  62),
    BorderLight     = Color3.fromRGB(55,  55,  80),
    Scrollbar       = Color3.fromRGB(55,  55,  82),
    Shadow          = Color3.fromRGB(0,   0,   0),
    TabActive       = Color3.fromRGB(99,  102, 241),
    TabInactive     = Color3.fromRGB(22,  22,  34),
    ToggleOn        = Color3.fromRGB(99,  102, 241),
    ToggleOff       = Color3.fromRGB(40,  40,  60),
    ToggleKnob      = Color3.fromRGB(255, 255, 255),
    SliderTrack     = Color3.fromRGB(32,  32,  50),
    SliderFill      = Color3.fromRGB(99,  102, 241),
    SliderKnob      = Color3.fromRGB(255, 255, 255),
    InputBG         = Color3.fromRGB(20,  20,  32),
    InputBorder     = Color3.fromRGB(50,  50,  75),
    InputFocus      = Color3.fromRGB(99,  102, 241),
    DropdownBG      = Color3.fromRGB(20,  20,  32),
    DropdownItem    = Color3.fromRGB(25,  25,  38),
    DropdownHover   = Color3.fromRGB(35,  35,  55),
    SectionLine     = Color3.fromRGB(35,  35,  55),
    NotifBG         = Color3.fromRGB(20,  20,  32),
    WatermarkBG     = Color3.fromRGB(18,  18,  28),
}

Themes.Ocean = {
    Name            = "Ocean",
    WindowBG        = Color3.fromRGB(6,   18,  32),
    TitleBG         = Color3.fromRGB(8,   24,  42),
    SidebarBG       = Color3.fromRGB(7,   20,  36),
    ContentBG       = Color3.fromRGB(6,   18,  32),
    ElementBG       = Color3.fromRGB(10,  28,  50),
    ElementHover    = Color3.fromRGB(14,  36,  64),
    ElementActive   = Color3.fromRGB(18,  45,  78),
    Accent          = Color3.fromRGB(34,  197, 254),
    AccentDark      = Color3.fromRGB(14,  140, 210),
    AccentLight     = Color3.fromRGB(100, 220, 255),
    AccentGlow      = Color3.fromRGB(34,  197, 254),
    TextPrimary     = Color3.fromRGB(220, 240, 255),
    TextSecondary   = Color3.fromRGB(130, 180, 220),
    TextMuted       = Color3.fromRGB(65,  115, 160),
    TextDisabled    = Color3.fromRGB(35,  70,  105),
    Success         = Color3.fromRGB(52,  211, 153),
    Warning         = Color3.fromRGB(251, 191, 36),
    Danger          = Color3.fromRGB(248, 113, 113),
    Info            = Color3.fromRGB(96,  165, 250),
    Border          = Color3.fromRGB(15,  45,  75),
    BorderLight     = Color3.fromRGB(22,  60,  95),
    Scrollbar       = Color3.fromRGB(25,  70,  110),
    Shadow          = Color3.fromRGB(0,   5,   15),
    TabActive       = Color3.fromRGB(34,  197, 254),
    TabInactive     = Color3.fromRGB(10,  28,  50),
    ToggleOn        = Color3.fromRGB(34,  197, 254),
    ToggleOff       = Color3.fromRGB(18,  45,  70),
    ToggleKnob      = Color3.fromRGB(255, 255, 255),
    SliderTrack     = Color3.fromRGB(12,  35,  60),
    SliderFill      = Color3.fromRGB(34,  197, 254),
    SliderKnob      = Color3.fromRGB(255, 255, 255),
    InputBG         = Color3.fromRGB(8,   22,  40),
    InputBorder     = Color3.fromRGB(18,  55,  88),
    InputFocus      = Color3.fromRGB(34,  197, 254),
    DropdownBG      = Color3.fromRGB(8,   22,  40),
    DropdownItem    = Color3.fromRGB(10,  28,  50),
    DropdownHover   = Color3.fromRGB(16,  42,  70),
    SectionLine     = Color3.fromRGB(14,  40,  65),
    NotifBG         = Color3.fromRGB(8,   22,  40),
    WatermarkBG     = Color3.fromRGB(8,   24,  42),
}

Themes.Crimson = {
    Name            = "Crimson",
    WindowBG        = Color3.fromRGB(16,  6,   9),
    TitleBG         = Color3.fromRGB(24,  8,   13),
    SidebarBG       = Color3.fromRGB(20,  7,   11),
    ContentBG       = Color3.fromRGB(16,  6,   9),
    ElementBG       = Color3.fromRGB(30,  10,  16),
    ElementHover    = Color3.fromRGB(40,  14,  22),
    ElementActive   = Color3.fromRGB(52,  18,  28),
    Accent          = Color3.fromRGB(239, 68,  68),
    AccentDark      = Color3.fromRGB(185, 28,  28),
    AccentLight     = Color3.fromRGB(252, 125, 125),
    AccentGlow      = Color3.fromRGB(239, 68,  68),
    TextPrimary     = Color3.fromRGB(255, 235, 235),
    TextSecondary   = Color3.fromRGB(205, 155, 155),
    TextMuted       = Color3.fromRGB(130, 70,  80),
    TextDisabled    = Color3.fromRGB(75,  35,  42),
    Success         = Color3.fromRGB(52,  211, 153),
    Warning         = Color3.fromRGB(251, 191, 36),
    Danger          = Color3.fromRGB(248, 113, 113),
    Info            = Color3.fromRGB(96,  165, 250),
    Border          = Color3.fromRGB(55,  18,  26),
    BorderLight     = Color3.fromRGB(75,  24,  34),
    Scrollbar       = Color3.fromRGB(80,  25,  35),
    Shadow          = Color3.fromRGB(0,   0,   0),
    TabActive       = Color3.fromRGB(239, 68,  68),
    TabInactive     = Color3.fromRGB(30,  10,  16),
    ToggleOn        = Color3.fromRGB(239, 68,  68),
    ToggleOff       = Color3.fromRGB(50,  16,  22),
    ToggleKnob      = Color3.fromRGB(255, 255, 255),
    SliderTrack     = Color3.fromRGB(36,  12,  18),
    SliderFill      = Color3.fromRGB(239, 68,  68),
    SliderKnob      = Color3.fromRGB(255, 255, 255),
    InputBG         = Color3.fromRGB(22,  8,   12),
    InputBorder     = Color3.fromRGB(65,  20,  28),
    InputFocus      = Color3.fromRGB(239, 68,  68),
    DropdownBG      = Color3.fromRGB(22,  8,   12),
    DropdownItem    = Color3.fromRGB(28,  10,  15),
    DropdownHover   = Color3.fromRGB(42,  15,  22),
    SectionLine     = Color3.fromRGB(45,  15,  22),
    NotifBG         = Color3.fromRGB(22,  8,   12),
    WatermarkBG     = Color3.fromRGB(24,  8,   13),
}

Themes.Emerald = {
    Name            = "Emerald",
    WindowBG        = Color3.fromRGB(6,   18,  12),
    TitleBG         = Color3.fromRGB(8,   26,  18),
    SidebarBG       = Color3.fromRGB(7,   21,  15),
    ContentBG       = Color3.fromRGB(6,   18,  12),
    ElementBG       = Color3.fromRGB(10,  30,  20),
    ElementHover    = Color3.fromRGB(14,  40,  27),
    ElementActive   = Color3.fromRGB(18,  52,  35),
    Accent          = Color3.fromRGB(52,  211, 153),
    AccentDark      = Color3.fromRGB(25,  155, 105),
    AccentLight     = Color3.fromRGB(100, 235, 185),
    AccentGlow      = Color3.fromRGB(52,  211, 153),
    TextPrimary     = Color3.fromRGB(220, 255, 240),
    TextSecondary   = Color3.fromRGB(130, 200, 170),
    TextMuted       = Color3.fromRGB(65,  130, 100),
    TextDisabled    = Color3.fromRGB(35,  75,  55),
    Success         = Color3.fromRGB(52,  211, 153),
    Warning         = Color3.fromRGB(251, 191, 36),
    Danger          = Color3.fromRGB(248, 113, 113),
    Info            = Color3.fromRGB(96,  165, 250),
    Border          = Color3.fromRGB(15,  48,  32),
    BorderLight     = Color3.fromRGB(22,  65,  45),
    Scrollbar       = Color3.fromRGB(25,  75,  52),
    Shadow          = Color3.fromRGB(0,   5,   3),
    TabActive       = Color3.fromRGB(52,  211, 153),
    TabInactive     = Color3.fromRGB(10,  30,  20),
    ToggleOn        = Color3.fromRGB(52,  211, 153),
    ToggleOff       = Color3.fromRGB(18,  48,  32),
    ToggleKnob      = Color3.fromRGB(255, 255, 255),
    SliderTrack     = Color3.fromRGB(12,  36,  24),
    SliderFill      = Color3.fromRGB(52,  211, 153),
    SliderKnob      = Color3.fromRGB(255, 255, 255),
    InputBG         = Color3.fromRGB(8,   24,  16),
    InputBorder     = Color3.fromRGB(20,  60,  40),
    InputFocus      = Color3.fromRGB(52,  211, 153),
    DropdownBG      = Color3.fromRGB(8,   24,  16),
    DropdownItem    = Color3.fromRGB(10,  30,  20),
    DropdownHover   = Color3.fromRGB(16,  46,  30),
    SectionLine     = Color3.fromRGB(14,  42,  28),
    NotifBG         = Color3.fromRGB(8,   24,  16),
    WatermarkBG     = Color3.fromRGB(8,   26,  18),
}

Themes.Rose = {
    Name            = "Rose",
    WindowBG        = Color3.fromRGB(20,  10,  16),
    TitleBG         = Color3.fromRGB(28,  13,  22),
    SidebarBG       = Color3.fromRGB(24,  11,  18),
    ContentBG       = Color3.fromRGB(20,  10,  16),
    ElementBG       = Color3.fromRGB(35,  16,  28),
    ElementHover    = Color3.fromRGB(46,  21,  37),
    ElementActive   = Color3.fromRGB(58,  26,  46),
    Accent          = Color3.fromRGB(244, 114, 182),
    AccentDark      = Color3.fromRGB(190, 60,  128),
    AccentLight     = Color3.fromRGB(255, 165, 210),
    AccentGlow      = Color3.fromRGB(244, 114, 182),
    TextPrimary     = Color3.fromRGB(255, 235, 248),
    TextSecondary   = Color3.fromRGB(210, 160, 195),
    TextMuted       = Color3.fromRGB(140, 80,  120),
    TextDisabled    = Color3.fromRGB(80,  40,  65),
    Success         = Color3.fromRGB(52,  211, 153),
    Warning         = Color3.fromRGB(251, 191, 36),
    Danger          = Color3.fromRGB(248, 113, 113),
    Info            = Color3.fromRGB(96,  165, 250),
    Border          = Color3.fromRGB(60,  22,  48),
    BorderLight     = Color3.fromRGB(80,  30,  62),
    Scrollbar       = Color3.fromRGB(85,  30,  65),
    Shadow          = Color3.fromRGB(5,   0,   4),
    TabActive       = Color3.fromRGB(244, 114, 182),
    TabInactive     = Color3.fromRGB(35,  16,  28),
    ToggleOn        = Color3.fromRGB(244, 114, 182),
    ToggleOff       = Color3.fromRGB(55,  22,  44),
    ToggleKnob      = Color3.fromRGB(255, 255, 255),
    SliderTrack     = Color3.fromRGB(40,  16,  32),
    SliderFill      = Color3.fromRGB(244, 114, 182),
    SliderKnob      = Color3.fromRGB(255, 255, 255),
    InputBG         = Color3.fromRGB(26,  12,  20),
    InputBorder     = Color3.fromRGB(72,  26,  58),
    InputFocus      = Color3.fromRGB(244, 114, 182),
    DropdownBG      = Color3.fromRGB(26,  12,  20),
    DropdownItem    = Color3.fromRGB(32,  14,  25),
    DropdownHover   = Color3.fromRGB(48,  20,  38),
    SectionLine     = Color3.fromRGB(50,  20,  40),
    NotifBG         = Color3.fromRGB(26,  12,  20),
    WatermarkBG     = Color3.fromRGB(28,  13,  22),
}

Themes.Graphite = {
    Name            = "Graphite",
    WindowBG        = Color3.fromRGB(18,  18,  18),
    TitleBG         = Color3.fromRGB(24,  24,  24),
    SidebarBG       = Color3.fromRGB(20,  20,  20),
    ContentBG       = Color3.fromRGB(18,  18,  18),
    ElementBG       = Color3.fromRGB(28,  28,  28),
    ElementHover    = Color3.fromRGB(36,  36,  36),
    ElementActive   = Color3.fromRGB(45,  45,  45),
    Accent          = Color3.fromRGB(200, 200, 200),
    AccentDark      = Color3.fromRGB(140, 140, 140),
    AccentLight     = Color3.fromRGB(240, 240, 240),
    AccentGlow      = Color3.fromRGB(180, 180, 180),
    TextPrimary     = Color3.fromRGB(240, 240, 240),
    TextSecondary   = Color3.fromRGB(170, 170, 170),
    TextMuted       = Color3.fromRGB(100, 100, 100),
    TextDisabled    = Color3.fromRGB(60,  60,  60),
    Success         = Color3.fromRGB(134, 239, 172),
    Warning         = Color3.fromRGB(253, 224, 71),
    Danger          = Color3.fromRGB(252, 165, 165),
    Info            = Color3.fromRGB(147, 197, 253),
    Border          = Color3.fromRGB(40,  40,  40),
    BorderLight     = Color3.fromRGB(55,  55,  55),
    Scrollbar       = Color3.fromRGB(60,  60,  60),
    Shadow          = Color3.fromRGB(0,   0,   0),
    TabActive       = Color3.fromRGB(200, 200, 200),
    TabInactive     = Color3.fromRGB(28,  28,  28),
    ToggleOn        = Color3.fromRGB(200, 200, 200),
    ToggleOff       = Color3.fromRGB(48,  48,  48),
    ToggleKnob      = Color3.fromRGB(30,  30,  30),
    SliderTrack     = Color3.fromRGB(35,  35,  35),
    SliderFill      = Color3.fromRGB(200, 200, 200),
    SliderKnob      = Color3.fromRGB(240, 240, 240),
    InputBG         = Color3.fromRGB(22,  22,  22),
    InputBorder     = Color3.fromRGB(50,  50,  50),
    InputFocus      = Color3.fromRGB(160, 160, 160),
    DropdownBG      = Color3.fromRGB(22,  22,  22),
    DropdownItem    = Color3.fromRGB(28,  28,  28),
    DropdownHover   = Color3.fromRGB(40,  40,  40),
    SectionLine     = Color3.fromRGB(38,  38,  38),
    NotifBG         = Color3.fromRGB(22,  22,  22),
    WatermarkBG     = Color3.fromRGB(24,  24,  24),
}

Themes.Aurora = {
    Name            = "Aurora",
    WindowBG        = Color3.fromRGB(8,   10,  22),
    TitleBG         = Color3.fromRGB(12,  14,  32),
    SidebarBG       = Color3.fromRGB(10,  12,  26),
    ContentBG       = Color3.fromRGB(8,   10,  22),
    ElementBG       = Color3.fromRGB(16,  18,  40),
    ElementHover    = Color3.fromRGB(22,  24,  52),
    ElementActive   = Color3.fromRGB(28,  30,  66),
    Accent          = Color3.fromRGB(167, 139, 250),
    AccentDark      = Color3.fromRGB(109, 81,  210),
    AccentLight     = Color3.fromRGB(210, 190, 255),
    AccentGlow      = Color3.fromRGB(167, 139, 250),
    TextPrimary     = Color3.fromRGB(238, 235, 255),
    TextSecondary   = Color3.fromRGB(175, 165, 220),
    TextMuted       = Color3.fromRGB(100, 92,  155),
    TextDisabled    = Color3.fromRGB(55,  50,  90),
    Success         = Color3.fromRGB(110, 231, 183),
    Warning         = Color3.fromRGB(252, 211, 77),
    Danger          = Color3.fromRGB(252, 129, 129),
    Info            = Color3.fromRGB(125, 185, 255),
    Border          = Color3.fromRGB(30,  32,  65),
    BorderLight     = Color3.fromRGB(44,  46,  88),
    Scrollbar       = Color3.fromRGB(50,  48,  95),
    Shadow          = Color3.fromRGB(0,   0,   8),
    TabActive       = Color3.fromRGB(167, 139, 250),
    TabInactive     = Color3.fromRGB(16,  18,  40),
    ToggleOn        = Color3.fromRGB(167, 139, 250),
    ToggleOff       = Color3.fromRGB(32,  30,  62),
    ToggleKnob      = Color3.fromRGB(255, 255, 255),
    SliderTrack     = Color3.fromRGB(20,  22,  50),
    SliderFill      = Color3.fromRGB(167, 139, 250),
    SliderKnob      = Color3.fromRGB(255, 255, 255),
    InputBG         = Color3.fromRGB(12,  14,  30),
    InputBorder     = Color3.fromRGB(40,  38,  80),
    InputFocus      = Color3.fromRGB(167, 139, 250),
    DropdownBG      = Color3.fromRGB(12,  14,  30),
    DropdownItem    = Color3.fromRGB(16,  18,  40),
    DropdownHover   = Color3.fromRGB(26,  28,  58),
    SectionLine     = Color3.fromRGB(26,  28,  60),
    NotifBG         = Color3.fromRGB(12,  14,  30),
    WatermarkBG     = Color3.fromRGB(12,  14,  32),
}

-- ════════════════════════════════════════════════════════════════
--  UTILITY LIBRARY
-- ════════════════════════════════════════════════════════════════
local Util = {}

function Util.Tween(obj, props, info)
    local t = TweenService:Create(obj, info or TWEEN_MED, props)
    t:Play()
    return t
end

function Util.TweenFast(obj, props)   return Util.Tween(obj, props, TWEEN_FAST) end
function Util.TweenMed(obj, props)    return Util.Tween(obj, props, TWEEN_MED)  end
function Util.TweenSlow(obj, props)   return Util.Tween(obj, props, TWEEN_SLOW) end
function Util.TweenSpring(obj, props) return Util.Tween(obj, props, TWEEN_SPRING) end

function Util.Round(obj, r)
    local c = obj:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", obj)
    c.CornerRadius = type(r) == "number" and UDim.new(0, r) or (r or CORNER_RADIUS)
    return c
end

function Util.Stroke(obj, color, thickness, trans)
    local s = obj:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", obj)
    s.Color        = color or Color3.new(1,1,1)
    s.Thickness    = thickness or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

function Util.Padding(obj, top, bottom, left, right)
    local p = obj:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding", obj)
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    return p
end

function Util.ListLayout(parent, dir, align, padding, sortOrder)
    local l = Instance.new("UIListLayout")
    l.FillDirection  = dir       or Enum.FillDirection.Vertical
    l.HorizontalAlignment = align or Enum.HorizontalAlignment.Left
    l.Padding        = UDim.new(0, padding or 0)
    l.SortOrder      = sortOrder or Enum.SortOrder.LayoutOrder
    l.Parent         = parent
    return l
end

function Util.GridLayout(parent, cellSize, padding)
    local g = Instance.new("UIGridLayout")
    g.CellSize      = cellSize or UDim2.new(0,100,0,40)
    g.CellPadding   = padding  or UDim2.new(0,6,0,6)
    g.SortOrder     = Enum.SortOrder.LayoutOrder
    g.Parent        = parent
    return g
end

function Util.AspectRatio(obj, ratio)
    local a = Instance.new("UIAspectRatioConstraint")
    a.AspectRatio = ratio
    a.Parent = obj
    return a
end

function Util.SizeConstraint(obj, min, max)
    local c = Instance.new("UISizeConstraint")
    if min then c.MinSize = min end
    if max then c.MaxSize = max end
    c.Parent = obj
    return c
end

function Util.New(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

function Util.Frame(props, parent)
    props = props or {}
    props.BorderSizePixel = 0
    props.BackgroundColor3 = props.BackgroundColor3 or Color3.new(0,0,0)
    return Util.New("Frame", props, parent)
end

function Util.Button(props, parent)
    props = props or {}
    props.BorderSizePixel = 0
    props.AutoButtonColor = false
    props.Text            = props.Text or ""
    props.BackgroundColor3 = props.BackgroundColor3 or Color3.new(0.2,0.2,0.2)
    return Util.New("TextButton", props, parent)
end

function Util.Label(props, parent)
    props = props or {}
    props.BackgroundTransparency = 1
    props.BorderSizePixel        = 0
    props.Font                   = props.Font or Enum.Font.GothamSemibold
    props.TextSize               = props.TextSize or 13
    props.TextColor3             = props.TextColor3 or Color3.new(1,1,1)
    props.TextXAlignment         = props.TextXAlignment or Enum.TextXAlignment.Left
    props.TextYAlignment         = props.TextYAlignment or Enum.TextYAlignment.Center
    props.RichText               = true
    return Util.New("TextLabel", props, parent)
end

function Util.Image(props, parent)
    props = props or {}
    props.BackgroundTransparency = 1
    props.BorderSizePixel        = 0
    return Util.New("ImageLabel", props, parent)
end

function Util.ImageButton(props, parent)
    props = props or {}
    props.BackgroundTransparency = 1
    props.BorderSizePixel        = 0
    props.AutoButtonColor        = false
    return Util.New("ImageButton", props, parent)
end

function Util.ScrollFrame(props, parent)
    props = props or {}
    props.BorderSizePixel       = 0
    props.BackgroundColor3      = props.BackgroundColor3 or Color3.new(0,0,0)
    props.BackgroundTransparency = props.BackgroundTransparency or 1
    props.ScrollBarThickness    = props.ScrollBarThickness or 4
    props.CanvasSize            = props.CanvasSize or UDim2.new(0,0,0,0)
    props.AutomaticCanvasSize   = props.AutomaticCanvasSize or Enum.AutomaticSize.Y
    return Util.New("ScrollingFrame", props, parent)
end

function Util.AutoSize(obj, axis)
    obj.AutomaticSize = axis or Enum.AutomaticSize.Y
end

function Util.TextSize(text, font, size)
    return TextService:GetTextSize(text, size or 13, font or Enum.Font.GothamSemibold, Vector2.new(math.huge, math.huge))
end

function Util.Lerp(a, b, t)
    return a + (b - a) * t
end

function Util.LerpColor(a, b, t)
    return Color3.new(
        Util.Lerp(a.R, b.R, t),
        Util.Lerp(a.G, b.G, t),
        Util.Lerp(a.B, b.B, t)
    )
end

function Util.ColorToHex(c)
    return string.format("#%02X%02X%02X",
        math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
end

function Util.HexToColor(hex)
    hex = hex:gsub("#","")
    local r,g,b = tonumber(hex:sub(1,2),16), tonumber(hex:sub(3,4),16), tonumber(hex:sub(5,6),16)
    return Color3.fromRGB(r or 0, g or 0, b or 0)
end

function Util.HSVToColor(h,s,v)
    return Color3.fromHSV(h,s,v)
end

function Util.ColorToHSV(c)
    return Color3.toHSV(c)
end

function Util.Map(v, inMin, inMax, outMin, outMax)
    return outMin + (outMax - outMin) * ((v - inMin) / (inMax - inMin))
end

function Util.Clamp(v, min, max)
    return math.clamp(v, min, max)
end

function Util.Round2(v, decimals)
    local factor = 10 ^ (decimals or 0)
    return math.floor(v * factor + 0.5) / factor
end

function Util.Gradient(obj, colorList, rotation)
    local g = obj:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", obj)
    g.Color    = colorList
    g.Rotation = rotation or 0
    return g
end

function Util.Draggable(handle, target, onStart, onEnd)
    local dragging, dragStart, startPos = false, nil, nil
    local inputObj = nil

    local function update(input)
        if not dragging then return end
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        -- Clamp to screen
        local screenSize = Camera.ViewportSize
        local absSize    = target.AbsoluteSize
        local minX = 0
        local minY = 0
        local maxX = screenSize.X - absSize.X
        local maxY = screenSize.Y - absSize.Y
        local ox = math.clamp(newPos.X.Offset, minX, maxX)
        local oy = math.clamp(newPos.Y.Offset, minY, maxY)
        target.Position = UDim2.new(newPos.X.Scale, ox, newPos.Y.Scale, oy)
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = target.Position
            inputObj  = input
            if onStart then onStart() end
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if onEnd then onEnd() end
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            inputObj = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == inputObj then update(input) end
    end)
end

function Util.SafeParent(gui)
    local success = pcall(function()
        gui.Parent = CoreGui
    end)
    if not success or not gui.Parent then
        gui.Parent = PlayerGui
    end
end

function Util.Destroy(instance)
    if instance and instance.Parent then
        instance:Destroy()
    end
end

function Util.Connect(connections, signal, fn)
    local conn = signal:Connect(fn)
    table.insert(connections, conn)
    return conn
end

function Util.DisconnectAll(connections)
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(connections)
end

function Util.Debounce(fn, delay)
    local last = 0
    return function(...)
        local now = tick()
        if now - last >= (delay or 0.1) then
            last = now
            fn(...)
        end
    end
end

function Util.Shadow(parent, offset, transparency, zindex)
    local s = Util.Frame({
        Name                 = "Shadow",
        Size                 = UDim2.new(1, offset or 20, 1, offset or 20),
        Position             = UDim2.new(0, -(offset or 20)/2, 0, -(offset or 20)/2),
        BackgroundColor3     = Color3.new(0,0,0),
        BackgroundTransparency = transparency or 0.5,
        ZIndex               = (zindex or 1) - 1,
    }, parent)
    Util.Round(s, 14)
    return s
end

function Util.Glow(parent, color, size)
    local g = Util.Frame({
        Name                 = "Glow",
        Size                 = UDim2.new(1, size or 30, 1, size or 30),
        Position             = UDim2.new(0, -(size or 30)/2, 0, -(size or 30)/2),
        BackgroundColor3     = color or Color3.fromRGB(99,102,241),
        BackgroundTransparency = 0.85,
        ZIndex               = 0,
    }, parent)
    Util.Round(g, 18)
    return g
end

function Util.Divider(parent, color, layoutOrder)
    local d = Util.Frame({
        Name             = "Divider",
        Size             = UDim2.new(1, -24, 0, 1),
        Position         = UDim2.new(0, 12, 0, 0),
        BackgroundColor3 = color or Color3.fromRGB(50,50,70),
        BackgroundTransparency = 0.5,
        LayoutOrder      = layoutOrder or 0,
    }, parent)
    return d
end

-- ════════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ════════════════════════════════════════════════════════════════
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

local _notifGui  = nil
local _notifHolder = nil
local _notifCount  = 0

local function EnsureNotifSystem()
    if _notifGui and _notifGui.Parent then return end

    _notifGui = Util.New("ScreenGui", {
        Name           = "NexusLib_Notifications",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 9999,
        IgnoreGuiInset = true,
    })
    Util.SafeParent(_notifGui)

    _notifHolder = Util.Frame({
        Name                 = "NotifHolder",
        Size                 = UDim2.new(0, 300, 1, -20),
        Position             = UDim2.new(1, -315, 0, 10),
        BackgroundTransparency = 1,
        ZIndex               = 9999,
    }, _notifGui)

    local layout = Util.ListLayout(_notifHolder, Enum.FillDirection.Vertical, nil, 8)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.SortOrder         = Enum.SortOrder.LayoutOrder
end

function NotificationSystem.Send(opts)
    opts = opts or {}
    EnsureNotifSystem()

    local title    = opts.Title    or "Notification"
    local msg      = opts.Message  or ""
    local duration = opts.Duration or 5
    local ntype    = opts.Type     or "Info"
    local theme    = type(opts.Theme) == "table" and opts.Theme or (Themes[opts.Theme] or Themes.Midnight)

    _notifCount = _notifCount + 1
    local id = _notifCount

    -- Color by type
    local accentColor = theme.Info
    if ntype == "Success" then accentColor = theme.Success
    elseif ntype == "Warning" then accentColor = theme.Warning
    elseif ntype == "Error"   then accentColor = theme.Danger
    end

    -- Icon by type
    local icon = "ℹ"
    if ntype == "Success" then icon = "✓"
    elseif ntype == "Warning" then icon = "⚠"
    elseif ntype == "Error"   then icon = "✕"
    end

    -- Card
    local card = Util.Frame({
        Name                 = "Notif_" .. id,
        Size                 = UDim2.new(1, 0, 0, 0),
        AutomaticSize        = Enum.AutomaticSize.Y,
        BackgroundColor3     = theme.NotifBG,
        BackgroundTransparency = 1,
        ClipsDescendants     = false,
        LayoutOrder          = id,
        ZIndex               = 9999,
    }, _notifHolder)
    Util.Round(card, 10)
    Util.Stroke(card, theme.Border, 1, 0.3)

    -- Left accent bar
    local bar = Util.Frame({
        Name             = "AccentBar",
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accentColor,
        ZIndex           = 10000,
    }, card)
    Util.Round(bar, 2)

    -- Inner content
    local inner = Util.Frame({
        Name                 = "Inner",
        Size                 = UDim2.new(1, -3, 0, 0),
        Position             = UDim2.new(0, 3, 0, 0),
        AutomaticSize        = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex               = 10000,
    }, card)
    Util.Padding(inner, 10, 12, 12, 10)

    local contentLayout = Util.ListLayout(inner, Enum.FillDirection.Vertical, nil, 3)

    -- Header row
    local header = Util.Frame({
        Name                 = "Header",
        Size                 = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        ZIndex               = 10000,
        LayoutOrder          = 1,
    }, inner)

    local iconLbl = Util.Label({
        Name      = "Icon",
        Size      = UDim2.new(0, 22, 1, 0),
        Text      = icon,
        TextColor3 = accentColor,
        Font      = Enum.Font.GothamBold,
        TextSize  = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex    = 10000,
    }, header)

    local titleLbl = Util.Label({
        Name      = "Title",
        Size      = UDim2.new(1, -22, 1, 0),
        Position  = UDim2.new(0, 24, 0, 0),
        Text      = title,
        TextColor3 = theme.TextPrimary,
        Font      = Enum.Font.GothamBold,
        TextSize  = 13,
        ZIndex    = 10000,
    }, header)

    -- Message
    if msg ~= "" then
        local msgLbl = Util.Label({
            Name         = "Message",
            Size         = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text         = msg,
            TextColor3   = theme.TextSecondary,
            Font         = Enum.Font.Gotham,
            TextSize     = 12,
            TextWrapped  = true,
            ZIndex       = 10000,
            LayoutOrder  = 2,
        }, inner)
    end

    -- Progress bar
    local progBg = Util.Frame({
        Name             = "ProgBg",
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = theme.Border,
        ZIndex           = 10001,
        LayoutOrder      = 3,
    }, inner)
    Util.Round(progBg, 1)

    local prog = Util.Frame({
        Name             = "Prog",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentColor,
        ZIndex           = 10002,
    }, progBg)
    Util.Round(prog, 1)

    -- Close button
    local closeBtn = Util.Button({
        Name                 = "CloseBtn",
        Size                 = UDim2.new(0, 18, 0, 18),
        Position             = UDim2.new(1, -22, 0, 8),
        BackgroundTransparency = 1,
        Text                 = "×",
        TextColor3           = theme.TextMuted,
        Font                 = Enum.Font.GothamBold,
        TextSize             = 16,
        ZIndex               = 10003,
    }, card)

    -- Animate in
    card.BackgroundTransparency = 1
    task.spawn(function()
        task.wait(0.05)
        Util.TweenFast(card, { BackgroundTransparency = 0 })

        -- Progress animation
        Util.Tween(prog, { Size = UDim2.new(0, 0, 1, 0) }, TweenInfo.new(duration, Enum.EasingStyle.Linear))

        local function dismiss()
            Util.TweenFast(card, { BackgroundTransparency = 1 })
            task.wait(0.2)
            Util.Destroy(card)
        end

        closeBtn.MouseButton1Click:Connect(dismiss)

        task.delay(duration, function()
            if card and card.Parent then
                dismiss()
            end
        end)
    end)

    return card
end

-- ════════════════════════════════════════════════════════════════
--  TOOLTIP SYSTEM
-- ════════════════════════════════════════════════════════════════
local TooltipSystem = {}
local _tooltipGui  = nil
local _tooltipFrame = nil
local _tooltipLabel = nil
local _tooltipConn  = nil

local function EnsureTooltip(theme)
    if _tooltipGui and _tooltipGui.Parent then return end
    _tooltipGui = Util.New("ScreenGui", {
        Name           = "NexusLib_Tooltip",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 9998,
        IgnoreGuiInset = true,
    })
    Util.SafeParent(_tooltipGui)

    _tooltipFrame = Util.Frame({
        Name                 = "Tooltip",
        Size                 = UDim2.new(0, 10, 0, 26),
        BackgroundColor3     = theme and theme.ElementBG or Color3.fromRGB(22,22,34),
        BackgroundTransparency = 1,
        ZIndex               = 9998,
        Visible              = false,
    }, _tooltipGui)
    Util.Round(_tooltipFrame, 6)
    Util.Stroke(_tooltipFrame, theme and theme.Border or Color3.fromRGB(40,40,62), 1, 0.3)
    Util.Padding(_tooltipFrame, 4, 4, 8, 8)

    _tooltipLabel = Util.Label({
        Size       = UDim2.new(1, 0, 1, 0),
        Text       = "",
        TextColor3 = theme and theme.TextSecondary or Color3.fromRGB(160,160,195),
        Font       = Enum.Font.Gotham,
        TextSize   = 11,
        ZIndex     = 9999,
    }, _tooltipFrame)
end

function TooltipSystem.Attach(obj, text, theme)
    EnsureTooltip(theme)
    local showing = false

    obj.MouseEnter:Connect(function()
        if text == "" then return end
        showing = true
        _tooltipFrame.Visible = true
        local textSize = Util.TextSize(text, Enum.Font.Gotham, 11)
        _tooltipFrame.Size = UDim2.new(0, textSize.X + 16, 0, 26)
        _tooltipLabel.Text = text
    end)

    obj.MouseLeave:Connect(function()
        showing = false
        _tooltipFrame.Visible = false
    end)

    if _tooltipConn then return end
    _tooltipConn = RunService.Heartbeat:Connect(function()
        if not _tooltipFrame or not _tooltipFrame.Visible then return end
        local mp = UserInputService:GetMouseLocation()
        _tooltipFrame.Position = UDim2.new(0, mp.X + 14, 0, mp.Y + 4)
    end)
end

-- ════════════════════════════════════════════════════════════════
--  CONFIG SYSTEM
-- ════════════════════════════════════════════════════════════════
local ConfigSystem = {}

local _configFolder = "NexusLib_Configs"
local _configs      = {}

function ConfigSystem.Init(folder)
    _configFolder = folder or _configFolder
    pcall(function()
        if not isfolder(_configFolder) then
            makefolder(_configFolder)
        end
    end)
end

function ConfigSystem.Register(key, getter, setter)
    _configs[key] = { get = getter, set = setter }
end

function ConfigSystem.Save(filename)
    local data = {}
    for key, cfg in pairs(_configs) do
        local ok, val = pcall(cfg.get)
        if ok then data[key] = val end
    end
    local encoded
    local ok, err = pcall(function()
        encoded = HttpService:JSONEncode(data)
    end)
    if not ok then return false, err end
    pcall(function()
        writefile(_configFolder .. "/" .. (filename or "default") .. ".json", encoded)
    end)
    return true
end

function ConfigSystem.Load(filename)
    local raw
    local ok = pcall(function()
        raw = readfile(_configFolder .. "/" .. (filename or "default") .. ".json")
    end)
    if not ok or not raw then return false end
    local data
    ok = pcall(function()
        data = HttpService:JSONDecode(raw)
    end)
    if not ok or not data then return false end
    for key, val in pairs(data) do
        if _configs[key] then
            pcall(_configs[key].set, val)
        end
    end
    return true
end

function ConfigSystem.List()
    local files = {}
    pcall(function()
        for _, f in ipairs(listfiles(_configFolder)) do
            local name = f:match("([^/\\]+)%.json$")
            if name then table.insert(files, name) end
        end
    end)
    return files
end

function ConfigSystem.Delete(filename)
    pcall(function()
        delfile(_configFolder .. "/" .. filename .. ".json")
    end)
end

-- ════════════════════════════════════════════════════════════════
--  WATERMARK
-- ════════════════════════════════════════════════════════════════
local WatermarkSystem = {}

function WatermarkSystem.Create(opts, theme)
    opts  = opts  or {}
    theme = theme or Themes.Midnight

    local wGui = Util.New("ScreenGui", {
        Name           = "NexusLib_Watermark",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 500,
        IgnoreGuiInset = true,
    })
    Util.SafeParent(wGui)

    local frame = Util.Frame({
        Name             = "Watermark",
        Size             = UDim2.new(0, 10, 0, 28),
        Position         = opts.Position or UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = theme.WatermarkBG,
        ZIndex           = 500,
        AutomaticSize    = Enum.AutomaticSize.X,
    }, wGui)
    Util.Round(frame, 8)
    Util.Stroke(frame, theme.Border, 1, 0.3)
    Util.Padding(frame, 0, 0, 12, 12)

    local lbl = Util.Label({
        Size       = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Text       = opts.Text or "NexusLib",
        TextColor3 = theme.TextSecondary,
        Font       = Enum.Font.GothamBold,
        TextSize   = 12,
        ZIndex     = 501,
    }, frame)

    local WM = {}
    function WM:SetText(t)     lbl.Text = t end
    function WM:SetVisible(v)  wGui.Enabled = v end
    function WM:Destroy()      Util.Destroy(wGui) end

    -- Auto-update ping/fps if opts.ShowInfo
    if opts.ShowInfo then
        local base = opts.Text or "NexusLib"
        RunService.Heartbeat:Connect(function()
            local fps  = math.floor(1 / RunService.Heartbeat:Wait())
            local ping = 0
            pcall(function() ping = LocalPlayer:GetNetworkPing() * 1000 end)
            lbl.Text = string.format("%s  |  %d FPS  |  %dms", base, fps, math.floor(ping))
        end)
    end

    return WM
end

-- ════════════════════════════════════════════════════════════════
--  ELEMENT BUILDER HELPERS (used inside tabs)
-- ════════════════════════════════════════════════════════════════
local function MakeElementCard(scroll, theme, height, name)
    local card = Util.Frame({
        Name             = name or "Element",
        Size             = UDim2.new(1, 0, 0, height or ELEMENT_H),
        BackgroundColor3 = theme.ElementBG,
        LayoutOrder      = #scroll:GetChildren(),
        ClipsDescendants = false,
    }, scroll)
    Util.Round(card, 8)
    Util.Stroke(card, theme.Border, 1, 0.5)
    return card
end

local function MakeClickRipple(parent, color)
    local ripple = Util.Frame({
        Name                 = "Ripple",
        Size                 = UDim2.new(0, 0, 0, 0),
        Position             = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3     = color or Color3.new(1,1,1),
        BackgroundTransparency = 0.85,
        ZIndex               = parent.ZIndex + 5,
        ClipsDescendants     = false,
    }, parent)
    Util.Round(ripple, 999)
    Util.AspectRatio(ripple, 1)

    Util.TweenSpring(ripple, { Size = UDim2.new(2.5, 0, 2.5, 0), BackgroundTransparency = 1 })
    task.delay(0.6, function() Util.Destroy(ripple) end)
end

local function HoverEffect(btn, theme, isCard)
    btn.MouseEnter:Connect(function()
        Util.TweenFast(btn, { BackgroundColor3 = isCard and theme.ElementHover or theme.ElementHover })
    end)
    btn.MouseLeave:Connect(function()
        Util.TweenFast(btn, { BackgroundColor3 = isCard and theme.ElementBG or theme.ElementBG })
    end)
end

-- ════════════════════════════════════════════════════════════════
--  TAB OBJECT
-- ════════════════════════════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Tab.new(scroll, theme, window)
    local self = setmetatable({}, Tab)
    self._scroll      = scroll
    self._theme       = theme
    self._window      = window
    self._connections = {}
    self._elements    = {}
    self._configs     = {}
    return self
end

-- ┌──────────────────────────────────────────────────────────────┐
-- │  SECTION                                                      │
-- └──────────────────────────────────────────────────────────────┘
function Tab:Section(opts)
    opts = opts or {}
    local text    = opts.Name  or opts.Text or opts[1] or "Section"
    local theme   = self._theme
    local scroll  = self._scroll

    local container = Util.Frame({
        Name             = "Section_" .. text,
        Size             = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize    = Enum.AutomaticSize.Y,
        LayoutOrder      = #scroll:GetChildren(),
        ClipsDescendants = false,
    }, scroll)

    -- Header row
    local header = Util.Frame({
        Name                 = "Header",
        Size                 = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
    }, container)

    local line1 = Util.Frame({
        Size             = UDim2.new(0.22, -6, 0, 1),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = theme.SectionLine,
        BackgroundTransparency = 0.3,
    }, header)
    Util.Round(line1, 1)

    local label = Util.Label({
        Size      = UDim2.new(0.56, 0, 1, 0),
        Position  = UDim2.new(0.22, 0, 0, 0),
        Text      = text:upper(),
        TextColor3 = theme.TextMuted,
        Font      = Enum.Font.GothamBold,
        TextSize  = 9,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, header)

    local line2 = Util.Frame({
        Size             = UDim2.new(0.22, -6, 0, 1),
        Position         = UDim2.new(0.78, 6, 0.5, 0),
        BackgroundColor3 = theme.SectionLine,
        BackgroundTransparency = 0.3,
    }, header)
    Util.Round(line2, 1)

    -- Collapse button
    local collapseBtn = Util.Button({
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex               = header.ZIndex + 1,
    }, header)

    -- Content holder
    local content = Util.Frame({
        Name                 = "SectionContent",
        Size                 = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize        = Enum.AutomaticSize.Y,
        ClipsDescendants     = false,
    }, container)

    local contentLayout = Util.ListLayout(content, Enum.FillDirection.Vertical, nil, ELEMENT_PAD)

    local collapsed = opts.Collapsed or false
    local arrowLbl  = Util.Label({
        Size      = UDim2.new(0, 16, 1, 0),
        Position  = UDim2.new(1, -20, 0, 0),
        Text      = collapsed and "▶" or "▼",
        TextColor3 = theme.TextMuted,
        Font      = Enum.Font.GothamBold,
        TextSize  = 8,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, header)

    local function SetCollapsed(c)
        collapsed = c
        arrowLbl.Text = collapsed and "▶" or "▼"
        content.Visible = not collapsed
    end
    SetCollapsed(collapsed)

    collapseBtn.MouseButton1Click:Connect(function()
        SetCollapsed(not collapsed)
    end)

    -- The section returns a sub-tab-like object
    local SectionObj = {}

    -- Reuse all Tab element methods but parented to `content`
    local subTab = Tab.new(content, theme, self._window)

    for k, v in pairs(Tab) do
        if k ~= "new" and k ~= "Section" then
            SectionObj[k] = function(self2, ...)
                return v(subTab, ...)
            end
        end
    end

    SectionObj._scroll      = content
    SectionObj._theme       = theme
    SectionObj._window      = self._window
    SectionObj._connections = self._connections

    function SectionObj:Collapse()   SetCollapsed(true)  end
    function SectionObj:Expand()     SetCollapsed(false) end
    function SectionObj:IsCollapsed() return collapsed   end

    return SectionObj
end

-- ┌──────────────────────────────────────────────────────────────┐
-- │  BUTTON                                                       │
-- └──────────────────────────────────────────────────────────────┘
function Tab:Button(opts)
    opts = opts or {}
    local label    = opts.Label    or opts.Name or opts[1] or "Button"
    local desc     = opts.Desc     or opts.Description or ""
    local callback = opts.Callback or opts[2] or function() end
    local tooltip  = opts.Tooltip  or ""
    local disabled = opts.Disabled or false
    local icon     = opts.Icon     or ""
    local theme    = self._theme
    local scroll   = self._scroll

    local height = desc ~= "" and 52 or ELEMENT_H
    local card = MakeElementCard(scroll, theme, height, "Button_" .. label)
    Util.Padding(card, 0, 0, 14, 14)

    local btn = Util.Button({
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex               = card.ZIndex + 1,
    }, card)

    -- Icon
    local iconOffset = 0
    if icon ~= "" then
        local iconLbl = Util.Label({
            Size      = UDim2.new(0, 20, 1, 0),
            Text      = icon,
            TextColor3 = disabled and theme.TextDisabled or theme.Accent,
            Font      = Enum.Font.GothamBold,
            TextSize  = 16,
            TextXAlignment = Enum.TextXAlignment.Center,
        }, btn)
        iconOffset = 26
    end

    -- Label
    local lbl = Util.Label({
        Size       = UDim2.new(1, -iconOffset - 24, 0, desc ~= "" and 18 or 0),
        Position   = UDim2.new(0, iconOffset, desc ~= "" and 0 or 0, desc ~= "" and 9 or 0),
        Size       = UDim2.new(1, -iconOffset - 24, desc ~= "" and 0 or 1, 0),
        AutomaticSize = desc ~= "" and Enum.AutomaticSize.None or Enum.AutomaticSize.None,
        Text       = label,
        TextColor3 = disabled and theme.TextDisabled or theme.TextPrimary,
        Font       = Enum.Font.GothamSemibold,
        TextSize   = 13,
    }, btn)

    if desc ~= "" then
        lbl.Size     = UDim2.new(1, -iconOffset - 24, 0, 18)
        lbl.Position = UDim2.new(0, iconOffset, 0, 9)

        local descLbl = Util.Label({
            Size       = UDim2.new(1, -iconOffset - 24, 0, 16),
            Position   = UDim2.new(0, iconOffset, 0, 28),
            Text       = desc,
            TextColor3 = theme.TextMuted,
            Font       = Enum.Font.Gotham,
            TextSize   = 11,
        }, btn)
    end

    -- Arrow
    local arrowLbl = Util.Label({
        Size       = UDim2.new(0, 20, 1, 0),
        Position   = UDim2.new(1, -20, 0, 0),
        Text       = "›",
        TextColor3 = disabled and theme.TextDisabled or theme.Accent,
        Font       = Enum.Font.GothamBold,
        TextSize   = 18,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, btn)

    -- Tooltip
    if tooltip ~= "" then TooltipSystem.Attach(card, tooltip, theme) end

    -- Interactions
    if not disabled then
        btn.MouseEnter:Connect(function()
            Util.TweenFast(card, { BackgroundColor3 = theme.ElementHover })
            Util.TweenFast(arrowLbl, { TextColor3 = theme.AccentLight })
        end)
        btn.MouseLeave:Connect(function()
            Util.TweenFast(card, { BackgroundColor3 = theme.ElementBG })
            Util.TweenFast(arrowLbl, { TextColor3 = theme.Accent })
        end)
        btn.MouseButton1Down:Connect(function()
            Util.TweenFast(card, { BackgroundColor3 = theme.ElementActive })
            MakeClickRipple(card, theme.Accent)
        end)
        btn.MouseButton1Up:Connect(function()
            Util.TweenFast(card, { BackgroundColor3 = theme.ElementHover })
        end)
        btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
    else
        card.BackgroundColor3 = Color3.fromRGB(
            theme.ElementBG.R * 255 * 0.7,
            theme.ElementBG.G * 255 * 0.7,
            theme.ElementBG.B * 255 * 0.7
        )
    end

    -- API
    local Btn = {}
    function Btn:SetLabel(t)    lbl.Text = t end
    function Btn:SetDisabled(d)
        disabled = d
        lbl.TextColor3   = d and theme.TextDisabled or theme.TextPrimary
        arrowLbl.TextColor3 = d and theme.TextDisabled or theme.Accent
        btn.Active = not d
    end
    function Btn:Destroy() Util.Destroy(card) end
    function Btn:Fire()    if not disabled then pcall(callback) end end
    return Btn
end

-- ┌──────────────────────────────────────────────────────────────┐
-- │  TOGGLE                                                       │
-- └──────────────────────────────────────────────────────────────┘
function Tab:Toggle(opts)
    opts = opts or {}
    local label    = opts.Label    or opts.Name or opts[1] or "Toggle"
    local desc     = opts.Desc     or opts.Description or ""
    local default  = opts.Default  ~= nil and opts.Default or false
    local callback = opts.Callback or opts[2] or function() end
    local tooltip  = opts.Tooltip  or ""
    local disabled = opts.Disabled or false
    local flag     = opts.Flag     or opts.ConfigKey or nil
    local theme    = self._theme
    local scroll   = self._scroll

    local state  = default
    local height = desc ~= "" and 52 or ELEMENT_H

    local card = MakeElementCard(scroll, theme, height, "Toggle_" .. label)
    Util.Padding(card, 0, 0, 14, 14)

    local btn = Util.Button({
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex               = card.ZIndex + 1,
    }, card)

    -- Label + desc
    local lbl = Util.Label({
        Size       = desc ~= "" and UDim2.new(1, -68, 0, 18) or UDim2.new(1, -68, 1, 0),
        Position   = desc ~= "" and UDim2.new(0, 0, 0, 9) or UDim2.new(0, 0, 0, 0),
        Text       = label,
        TextColor3 = theme.TextPrimary,
        Font       = Enum.Font.GothamSemibold,
        TextSize   = 13,
    }, btn)
    if desc ~= "" then
        local descLbl = Util.Label({
            Size       = UDim2.new(1, -68, 0, 16),
            Position   = UDim2.new(0, 0, 0, 28),
            Text       = desc,
            TextColor3 = theme.TextMuted,
            Font       = Enum.Font.Gotham,
            TextSize   = 11,
        }, btn)
    end

    -- Toggle pill
    local pillW, pillH = 44, 24
    local pill = Util.Frame({
        Name             = "Pill",
        Size             = UDim2.new(0, pillW, 0, pillH),
        Position         = UDim2.new(1, -pillW, 0.5, -pillH/2),
        BackgroundColor3 = state and theme.ToggleOn or theme.ToggleOff,
        ZIndex           = card.ZIndex + 2,
    }, card)
    Util.Round(pill, pillH/2)
    Util.Stroke(pill, theme.Border, 1, 0.3)

    local knobSize = pillH - 6
    local knob = Util.Frame({
        Name             = "Knob",
        Size             = UDim2.new(0, knobSize, 0, knobSize),
        Position         = state
            and UDim2.new(0, pillW - knobSize - 3, 0.5, -knobSize/2)
            or  UDim2.new(0, 3, 0.5, -knobSize/2),
        BackgroundColor3 = theme.ToggleKnob,
        ZIndex           = card.ZIndex + 3,
    }, pill)
    Util.Round(knob, knobSize/2)

    local function SetState(val, skipCallback)
        state = val
        local knobOnPos  = UDim2.new(0, pillW - knobSize - 3, 0.5, -knobSize/2)
        local knobOffPos = UDim2.new(0, 3, 0.5, -knobSize/2)
        Util.TweenMed(pill,  { BackgroundColor3 = val and theme.ToggleOn or theme.ToggleOff })
        Util.TweenMed(knob,  { Position = val and knobOnPos or knobOffPos })
        if not skipCallback then
            pcall(callback, state)
        end
    end

    if tooltip ~= "" then TooltipSystem.Attach(card, tooltip, theme) end

    if not disabled then
        btn.MouseEnter:Connect(function()  Util.TweenFast(card, { BackgroundColor3 = theme.ElementHover }) end)
        btn.MouseLeave:Connect(function()  Util.TweenFast(card, { BackgroundColor3 = theme.ElementBG }) end)
        btn.MouseButton1Down:Connect(function() MakeClickRipple(card, theme.Accent) end)
        btn.MouseButton1Click:Connect(function()
            SetState(not state)
        end)
    end

    -- Config
    if flag then
        ConfigSystem.Register(flag,
            function() return state end,
            function(v) SetState(v == true or v == "true", false) end
        )
    end

    local Toggle = {}
    function Toggle:Set(v, skipCb)  SetState(v, skipCb) end
    function Toggle:Get()           return state end
    function Toggle:Toggle()        SetState(not state) end
    function Toggle:SetDisabled(d)  disabled = d ; btn.Active = not d end
    function Toggle:SetLabel(t)     lbl.Text = t end
    function Toggle:Destroy()       Util.Destroy(card) end
    return Toggle
end

-- ┌──────────────────────────────────────────────────────────────┐
-- │  SLIDER                                                       │
-- └──────────────────────────────────────────────────────────────┘
function Tab:Slider(opts)
    opts = opts or {}
    local label    = opts.Label    or opts.Name or opts[1] or "Slider"
    local desc     = opts.Desc     or opts.Description or ""
    local minimum  = opts.Min      or 0
    local maximum  = opts.Max      or 100
    local default  = opts.Default  or opts.Value or minimum
    local step     = opts.Step     or nil  -- nil = smooth
    local decimals = opts.Decimals or 0
    local suffix   = opts.Suffix   or ""
    local prefix   = opts.Prefix   or ""
    local callback = opts.Callback or opts[2] or function() end
    local tooltip  = opts.Tooltip  or ""
    local disabled = opts.Disabled or false
    local flag     = opts.Flag     or opts.ConfigKey or nil
    local theme    = self._theme
    local scroll   = self._scroll

    local value = math.clamp(default, minimum, maximum)

    local cardH = desc ~= "" and 68 or 56
    local card  = MakeElementCard(scroll, theme, cardH, "Slider_" .. label)
    Util.Padding(card, 8, 10, 14, 14)

    -- Top row: label + value
    local topRow = Util.Frame({
        Name                 = "TopRow",
        Size                 = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
    }, card)

    local lbl = Util.Label({
        Size       = UDim2.new(0.65, 0, 1, 0),
        Text       = label,
        TextColor3 = theme.TextPrimary,
        Font       = Enum.Font.GothamSemibold,
        TextSize   = 13,
    }, topRow)

    local function FormatValue(v)
        local fmt = "%." .. decimals .. "f"
        return prefix .. string.format(fmt, v) .. suffix
    end

    local valLbl = Util.Label({
        Size       = UDim2.new(0.35, 0, 1, 0),
        Position   = UDim2.new(0.65, 0, 0, 0),
        Text       = FormatValue(value),
        TextColor3 = theme.Accent,
        Font       = Enum.Font.GothamBold,
        TextSize   = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, topRow)

    -- Optional description
    local trackTopOffset = 24
    if desc ~= "" then
        local descLbl = Util.Label({
            Size       = UDim2.new(1, 0, 0, 14),
            Position   = UDim2.new(0, 0, 0, 22),
            Text       = desc,
            TextColor3 = theme.TextMuted,
            Font       = Enum.Font.Gotham,
            TextSize   = 11,
        }, card)
        trackTopOffset = 40
    end

    -- Track
    local trackH  = 6
    local track = Util.Frame({
        Name             = "Track",
        Size             = UDim2.new(1, 0, 0, trackH),
        Position         = UDim2.new(0, 0, 0, trackTopOffset),
        BackgroundColor3 = theme.SliderTrack,
    }, card)
    Util.Round(track, trackH/2)
    Util.Stroke(track, theme.Border, 1, 0.5)

    local fill = Util.Frame({
        Name             = "Fill",
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = theme.SliderFill,
    }, track)
    Util.Round(fill, trackH/2)

    -- Gradient on fill
    Util.Gradient(fill, ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.AccentDark),
        ColorSequenceKeypoint.new(1, theme.AccentLight),
    }), 0)

    -- Knob
    local knobSize = 16
    local knob = Util.Frame({
        Name             = "Knob",
        Size             = UDim2.new(0, knobSize, 0, knobSize),
        Position         = UDim2.new(0, -knobSize/2, 0.5, -knobSize/2),
        BackgroundColor3 = theme.SliderKnob,
        ZIndex           = card.ZIndex + 3,
    }, track)
    Util.Round(knob, knobSize/2)
    Util.Stroke(knob, theme.Accent, 2, 0)

    -- Value input (double-click to type)
    local inputBox = Util.New("TextBox", {
        Size                 = UDim2.new(0, 60, 0, 22),
        Position             = UDim2.new(0.65, 0, 0, -2),
        BackgroundColor3     = theme.InputBG,
        BackgroundTransparency = 1,
        TextColor3           = theme.Accent,
        PlaceholderColor3    = theme.TextMuted,
        Font                 = Enum.Font.GothamBold,
        TextSize             = 13,
        Text                 = FormatValue(value),
        TextXAlignment       = Enum.TextXAlignment.Right,
        Visible              = false,
        ZIndex               = card.ZIndex + 5,
        ClearTextOnFocus     = false,
    }, topRow)

    local function UpdateVisual(v)
        local pct = (v - minimum) / (maximum - minimum)
        fill.Size     = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -knobSize/2, 0.5, -knobSize/2)
        valLbl.Text   = FormatValue(v)
        inputBox.Text = FormatValue(v)
    end

    local function SetValue(v, skipCallback)
        if step then
            v = math.floor(v / step + 0.5) * step
        end
        v = Util.Round2(math.clamp(v, minimum, maximum), decimals)
        value = v
        UpdateVisual(v)
        if not skipCallback then pcall(callback, v) end
    end

    SetValue(value, true)

    -- Dragging
    local dragging = false
    local function OnTrackInput(inputPos)
        local relX = math.clamp(inputPos - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local pct  = relX / track.AbsoluteSize.X
        SetValue(minimum + (maximum - minimum) * pct)
    end

    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Util.TweenFast(knob, { Size = UDim2.new(0, knobSize + 4, 0, knobSize + 4),
                Position = UDim2.new(knob.Position.X.Scale, -(knobSize+4)/2, 0.5, -(knobSize+4)/2) })
        end
    end)

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            OnTrackInput(i.Position.X)
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                Util.TweenFast(knob, { Size = UDim2.new(0, knobSize, 0, knobSize),
                    Position = UDim2.new(knob.Position.X.Scale, -knobSize/2, 0.5, -knobSize/2) })
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            OnTrackInput(i.Position.X)
        end
    end)

    -- Double click to type value
    valLbl.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            valLbl.Visible  = false
            inputBox.Visible = true
            inputBox:CaptureFocus()
            inputBox.SelectionStart = 1
            inputBox.CursorPosition = #inputBox.Text + 1
        end
    end)

    inputBox.FocusLost:Connect(function(enter)
        local num = tonumber(inputBox.Text:gsub("[^%d%.%-]", ""))
        if num then SetValue(num) end
        valLbl.Visible  = true
        inputBox.Visible = false
    end)

    -- Scroll wheel on track
    track.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseWheel then
            local delta = i.Position.Z
            local incr  = step or ((maximum - minimum) / 100)
            SetValue(value + delta * incr)
        end
    end)

    if tooltip ~= "" then TooltipSystem.Attach(card, tooltip, theme) end

    -- Config
    if flag then
        ConfigSystem.Register(flag,
            function() return value end,
            function(v) local n = tonumber(v) ; if n then SetValue(n, true) end end
        )
    end

    local Slider = {}
    function Slider:Set(v, skipCb)  SetValue(v, skipCb) end
    function Slider:Get()           return value end
    function Slider:SetMin(v)       minimum = v ; SetValue(value, true) end
    function Slider:SetMax(v)       maximum = v ; SetValue(value, true) end
    function Slider:SetLabel(t)     lbl.Text = t end
    function Slider:Destroy()       Util.Destroy(card) end
    return Slider
end

-- ┌──────────────────────────────────────────────────────────────┐
-- │  TEXTBOX                                                      │
-- └──────────────────────────────────────────────────────────────┘
function Tab:TextBox(opts)
    opts = opts or {}
    local label       = opts.Label    or opts.Name or opts[1] or "Input"
    local placeholder = opts.Placeholder or "Type here..."
    local default     = opts.Default  or opts.Value or ""
    local callback    = opts.Callback or opts[2] or function() end
    local onChanged   = opts.OnChanged or nil
    local clearFocus  = opts.ClearOnFocus ~= false
    local maxLen      = opts.MaxLength or nil
    local numbersOnly = opts.NumbersOnly or false
    local tooltip     = opts.Tooltip  or ""
    local flag        = opts.Flag     or opts.ConfigKey or nil
    local theme       = self._theme
    local scroll      = self._scroll

    local card = MakeElementCard(scroll, theme, 56, "TextBox_" .. label)
    Util.Padding(card, 8, 8, 14, 14)

    local topLayout = Util.ListLayout(card, Enum.FillDirection.Vertical, nil, 4)

    local lbl = Util.Label({
        Size       = UDim2.new(1, 0, 0, 14),
        Text       = label,
        TextColor3 = theme.TextMuted,
        Font       = Enum.Font.GothamSemibold,
        TextSize   = 10,
        LayoutOrder = 1,
    }, card)

    local inputBg = Util.Frame({
        Name             = "InputBG",
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = theme.InputBG,
        LayoutOrder      = 2,
    }, card)
    Util.Round(inputBg, 6)
    local stroke = Util.Stroke(inputBg, theme.InputBorder, 1, 0.2)
    Util.Padding(inputBg, 0, 0, 10, 10)

    local tb = Util.New("TextBox", {
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3           = theme.TextPrimary,
        PlaceholderColor3    = theme.TextMuted,
        PlaceholderText      = placeholder,
        Font                 = Enum.Font.Gotham,
        TextSize             = 12,
        Text                 = default,
        ClearTextOnFocus     = clearFocus,
        TextXAlignment       = Enum.TextXAlignment.Left,
        TextTruncate         = Enum.TextTruncate.AtEnd,
        ZIndex               = card.ZIndex + 2,
    }, inputBg)

    if tooltip ~= "" then TooltipSystem.Attach(card, tooltip, theme) end

    tb.Focused:Connect(function()
        Util.TweenFast(stroke, { Color = theme.InputFocus, Transparency = 0 })
        Util.TweenFast(inputBg, { BackgroundColor3 = theme.ElementBG })
    end)

    tb.FocusLost:Connect(function(enter)
        Util.TweenFast(stroke, { Color = theme.InputBorder, Transparency = 0.2 })
        Util.TweenFast(inputBg, { BackgroundColor3 = theme.InputBG })
        if numbersOnly then
            local n = tonumber(tb.Text)
            tb.Text = n and tostring(n) or default
        end
        if maxLen and #tb.Text > maxLen then
            tb.Text = tb.Text:sub(1, maxLen)
        end
        pcall(callback, tb.Text, enter)
    end)

    if onChanged then
        tb:GetPropertyChangedSignal("Text"):Connect(function()
            if maxLen and #tb.Text > maxLen then
                tb.Text = tb.Text:sub(1, maxLen)
            end
            pcall(onChanged, tb.Text)
        end)
    end

    if flag then
        ConfigSystem.Register(flag,
            function() return tb.Text end,
            function(v) tb.Text = tostring(v) end
        )
    end

    local TextBox = {}
    function TextBox:Set(v)    tb.Text = tostring(v) end
    function TextBox:Get()     return tb.Text end
    function TextBox:Clear()   tb.Text = "" end
    function TextBox:Focus()   tb:CaptureFocus() end
    function TextBox:SetLabel(t) lbl.Text = t end
    function TextBox:Destroy() Util.Destroy(card) end
    return TextBox
end

-- ┌──────────────────────────────────────────────────────────────┐
-- │  DROPDOWN                                                     │
-- └──────────────────────────────────────────────────────────────┘
function Tab:Dropdown(opts)
    opts = opts or {}
    local label      = opts.Label    or opts.Name or opts[1] or "Dropdown"
    local options    = opts.Options  or opts[2] or {}
    local default    = opts.Default  or opts.Value or (options[1] or "")
    local multi      = opts.Multi    or opts.MultiSelect or false
    local searchable = opts.Searchable or false
    local callback   = opts.Callback or opts[3] or function() end
    local placeholder = opts.Placeholder or "Select..."
    local tooltip    = opts.Tooltip  or ""
    local flag       = opts.Flag     or opts.ConfigKey or nil
    local theme      = self._theme
    local scroll     = self._scroll

    local selected = {}
    if multi then
        if type(default) == "table" then
            for _, v in ipairs(default) do selected[v] = true end
        elseif default ~= "" then
            selected[default] = true
        end
    else
        selected = default
    end

    local card = MakeElementCard(scroll, theme, 56, "Dropdown_" .. label)
    card.ClipsDescendants = false
    Util.Padding(card, 8, 8, 14, 14)

    local cardLayout = Util.ListLayout(card, Enum.FillDirection.Vertical, nil, 4)

    local lbl = Util.Label({
        Size       = UDim2.new(1, 0, 0, 14),
        Text       = label,
        TextColor3 = theme.TextMuted,
        Font       = Enum.Font.GothamSemibold,
        TextSize   = 10,
        LayoutOrder = 1,
    }, card)

    -- Trigger button
    local triggerBg = Util.Frame({
        Name             = "TriggerBG",
        Size             = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = theme.InputBG,
        LayoutOrder      = 2,
        ClipsDescendants = false,
    }, card)
    Util.Round(triggerBg, 6)
    local trigStroke = Util.Stroke(triggerBg, theme.InputBorder, 1, 0.2)
    Util.Padding(triggerBg, 0, 0, 10, 10)

    local function GetDisplayText()
        if multi then
            local parts = {}
            for k, v in pairs(selected) do if v then table.insert(parts, k) end end
            return #parts == 0 and placeholder or table.concat(parts, ", ")
        else
            return selected == "" and placeholder or tostring(selected)
        end
    end

    local triggerLbl = Util.Label({
        Size       = UDim2.new(1, -22, 1, 0),
        Text       = GetDisplayText(),
        TextColor3 = (multi and next(selected) or (not multi and selected ~= ""))
            and theme.TextPrimary or theme.TextMuted,
        Font       = Enum.Font.Gotham,
        TextSize   = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex     = card.ZIndex + 2,
    }, triggerBg)

    local arrowLbl = Util.Label({
        Size       = UDim2.new(0, 18, 1, 0),
        Position   = UDim2.new(1, -18, 0, 0),
        Text       = "▾",
        TextColor3 = theme.TextMuted,
        Font       = Enum.Font.GothamBold,
        TextSize   = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex     = card.ZIndex + 2,
    }, triggerBg)

    local trigBtn = Util.Button({
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex               = card.ZIndex + 3,
    }, triggerBg)

    -- Dropdown popup
    local open    = false
    local menu    = nil
    local menuGui = nil  -- separate ScreenGui to avoid clipping

    local function CloseMenu()
        if not menu then return end
        Util.TweenFast(menu, { BackgroundTransparency = 1 })
        Util.TweenFast(arrowLbl, { Rotation = 0 })
        Util.TweenFast(trigStroke, { Color = theme.InputBorder, Transparency = 0.2 })
        task.wait(0.15)
        if menuGui then Util.Destroy(menuGui) ; menuGui = nil end
        menu = nil
        open = false
    end

    local function OpenMenu()
        if menu then CloseMenu() return end
        open = true
        Util.TweenFast(arrowLbl, { Rotation = 180 })
        Util.TweenFast(trigStroke, { Color = theme.InputFocus, Transparency = 0 })

        -- Use a ScreenGui layer so menu is never clipped
        menuGui = Util.New("ScreenGui", {
            Name           = "NexusLib_Dropdown",
            ResetOnSpawn   = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder   = 9500,
            IgnoreGuiInset = true,
        })
        Util.SafeParent(menuGui)

        local maxVisible = math.min(#options, 6)
        local itemH      = 30
        local searchH    = searchable and 34 or 0
        local menuH      = maxVisible * itemH + 8 + searchH

        -- Position relative to screen
        local abs = triggerBg.AbsolutePosition
        local absS = triggerBg.AbsoluteSize
        local screenH = Camera.ViewportSize.Y

        local posY = abs.Y + absS.Y + 4
        if posY + menuH > screenH - 20 then
            posY = abs.Y - menuH - 4
        end

        menu = Util.Frame({
            Name             = "DropMenu",
            Size             = UDim2.new(0, absS.X, 0, menuH),
            Position         = UDim2.new(0, abs.X, 0, posY),
            BackgroundColor3 = theme.DropdownBG,
            BackgroundTransparency = 0,
            ZIndex           = 9500,
            ClipsDescendants = true,
        }, menuGui)
        Util.Round(menu, 8)
        Util.Stroke(menu, theme.Border, 1, 0.2)

        -- Search bar
        local filteredOptions = {table.unpack(options)}
        local searchTB = nil
        if searchable then
            local searchBg = Util.Frame({
                Size             = UDim2.new(1, -8, 0, 26),
                Position         = UDim2.new(0, 4, 0, 4),
                BackgroundColor3 = theme.InputBG,
                ZIndex           = 9502,
            }, menu)
            Util.Round(searchBg, 5)
            Util.Padding(searchBg, 0, 0, 8, 8)

            searchTB = Util.New("TextBox", {
                Size                 = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextColor3           = theme.TextPrimary,
                PlaceholderColor3    = theme.TextMuted,
                PlaceholderText      = "Search...",
                Font                 = Enum.Font.Gotham,
                TextSize             = 12,
                Text                 = "",
                ZIndex               = 9503,
            }, searchBg)
        end

        -- Scrollable list
        local listScroll = Util.ScrollFrame({
            Size                  = UDim2.new(1, 0, 1, -searchH),
            Position              = UDim2.new(0, 0, 0, searchH),
            BackgroundTransparency = 1,
            ScrollBarThickness    = 3,
            ScrollBarImageColor3  = theme.Scrollbar,
            ZIndex                = 9501,
            CanvasSize            = UDim2.new(0,0,0,0),
            AutomaticCanvasSize   = Enum.AutomaticSize.Y,
        }, menu)

        local listLayout = Util.ListLayout(listScroll, Enum.FillDirection.Vertical, nil, 2)
        Util.Padding(listScroll, 4, 4, 4, 4)

        local itemFrames = {}

        local function BuildList(filter)
            for _, f in ipairs(itemFrames) do Util.Destroy(f) end
            table.clear(itemFrames)

            for _, opt in ipairs(options) do
                local optStr = tostring(opt)
                if filter and filter ~= "" and not optStr:lower():find(filter:lower(), 1, true) then
                    continue
                end

                local isSelected = multi and (selected[optStr] == true) or (not multi and selected == optStr)

                local item = Util.Button({
                    Name             = "Item_" .. optStr,
                    Size             = UDim2.new(1, 0, 0, itemH),
                    BackgroundColor3 = isSelected and theme.Accent or theme.DropdownItem,
                    BackgroundTransparency = isSelected and 0.75 or 0,
                    ZIndex           = 9502,
                })
                item.Parent = listScroll
                Util.Round(item, 5)
                Util.Padding(item, 0, 0, 10, 10)
                table.insert(itemFrames, item)

                local checkMark = Util.Label({
                    Size       = UDim2.new(0, 16, 1, 0),
                    Text       = isSelected and "✓" or "",
                    TextColor3 = theme.Accent,
                    Font       = Enum.Font.GothamBold,
                    TextSize   = 11,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex     = 9503,
                }, item)

                local itemLbl = Util.Label({
                    Size       = UDim2.new(1, -22, 1, 0),
                    Position   = UDim2.new(0, 20, 0, 0),
                    Text       = optStr,
                    TextColor3 = isSelected and theme.Accent or theme.TextPrimary,
                    Font       = Enum.Font.Gotham,
                    TextSize   = 12,
                    ZIndex     = 9503,
                }, item)

                item.MouseEnter:Connect(function()
                    if not (multi and selected[optStr]) and not (not multi and selected == optStr) then
                        Util.TweenFast(item, { BackgroundColor3 = theme.DropdownHover, BackgroundTransparency = 0 })
                    end
                end)
                item.MouseLeave:Connect(function()
                    if not (multi and selected[optStr]) and not (not multi and selected == optStr) then
                        Util.TweenFast(item, { BackgroundColor3 = theme.DropdownItem, BackgroundTransparency = 0 })
                    end
                end)

                item.MouseButton1Click:Connect(function()
                    if multi then
                        selected[optStr] = not selected[optStr] or nil
                        local parts = {}
                        for k, v in pairs(selected) do if v then table.insert(parts, k) end end
                        triggerLbl.Text = #parts > 0 and table.concat(parts, ", ") or placeholder
                        triggerLbl.TextColor3 = #parts > 0 and theme.TextPrimary or theme.TextMuted
                        pcall(callback, selected)
                        BuildList(searchTB and searchTB.Text or "")
                    else
                        selected = optStr
                        triggerLbl.Text = optStr
                        triggerLbl.TextColor3 = theme.TextPrimary
                        pcall(callback, optStr)
                        CloseMenu()
                    end
                end)
            end
        end

        BuildList()

        if searchTB then
            searchTB:GetPropertyChangedSignal("Text"):Connect(function()
                BuildList(searchTB.Text)
            end)
            searchTB:CaptureFocus()
        end

        -- Close on outside click
        local closeConn
        closeConn = UserInputService.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                task.defer(function()
                    local mp = UserInputService:GetMouseLocation()
                    if not menu then closeConn:Disconnect() return end
                    local mx, my = mp.X, mp.Y
                    local ma = menu.AbsolutePosition
                    local ms = menu.AbsoluteSize
                    local ta = triggerBg.AbsolutePosition
                    local ts = triggerBg.AbsoluteSize
                    local inMenu = mx >= ma.X and mx <= ma.X + ms.X and my >= ma.Y and my <= ma.Y + ms.Y
                    local inTrig = mx >= ta.X and mx <= ta.X + ts.X and my >= ta.Y and my <= ta.Y + ts.Y
                    if not inMenu and not inTrig then
                        CloseMenu()
                        closeConn:Disconnect()
                    end
                end)
            end
        end)
    end

    trigBtn.MouseButton1Click:Connect(function()
        if open then CloseMenu() else OpenMenu() end
    end)

    if tooltip ~= "" then TooltipSystem.Attach(card, tooltip, theme) end

    if flag then
        ConfigSystem.Register(flag,
            function() return selected end,
            function(v)
                if multi and type(v) == "table" then
                    selected = v
                    local parts = {}
                    for k, val in pairs(v) do if val then table.insert(parts, k) end end
                    triggerLbl.Text = #parts > 0 and table.concat(parts, ", ") or placeholder
                elseif not multi then
                    selected = tostring(v)
                    triggerLbl.Text = selected
                end
            end
        )
    end

    local DD = {}
    function DD:Set(v)
        if multi and type(v) == "table" then
            selected = v
            local parts = {}
            for k, val in pairs(v) do if val then table.insert(parts, k) end end
            triggerLbl.Text = #parts > 0 and table.concat(parts, ", ") or placeholder
            triggerLbl.TextColor3 = #parts > 0 and theme.TextPrimary or theme.TextMuted
        elseif not multi then
            selected = tostring(v)
            triggerLbl.Text = selected
            triggerLbl.TextColor3 = theme.TextPrimary
        end
    end
    function DD:Get() return selected end
    function DD:SetOptions(newOpts)
        options = newOpts
        if not multi then
            local found = false
            for _, v in ipairs(newOpts) do if tostring(v) == tostring(selected) then found = true break end end
            if not found then selected = newOpts[1] or "" ; triggerLbl.Text = GetDisplayText() end
        end
    end
    function DD:AddOption(opt)  table.insert(options, opt) end
    function DD:Clear()
        if multi then selected = {} else selected = "" end
        triggerLbl.Text = placeholder
        triggerLbl.TextColor3 = theme.TextMuted
    end
    function DD:Close()   CloseMenu() end
    function DD:Destroy() CloseMenu() ; Util.Destroy(card) end
    return DD
end

-- ┌──────────────────────────────────────────────────────────────┐
-- │  KEYBIND                                                      │
-- └──────────────────────────────────────────────────────────────┘
function Tab:Keybind(opts)
    opts = opts or {}
    local label    = opts.Label    or opts.Name or opts[1] or "Keybind"
    local default  = opts.Default  or opts.Key or Enum.KeyCode.Unknown
    local callback = opts.Callback or opts[2] or function() end
    local tooltip  = opts.Tooltip  or ""
    local blacklist = opts.Blacklist or {
        Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A,
        Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Space,
        Enum.KeyCode.LeftShift, Enum.KeyCode.LeftControl,
    }
    local allowMouse = opts.AllowMouse or false
    local flag      = opts.Flag or opts.ConfigKey or nil
    local theme     = self._theme
    local scroll    = self._scroll

    local currentKey = default
    local listening  = false

    local card = MakeElementCard(scroll, theme, ELEMENT_H, "Keybind_" .. label)
    Util.Padding(card, 0, 0, 14, 14)

    local lbl = Util.Label({
        Size       = UDim2.new(1, -90, 1, 0),
        Text       = label,
        TextColor3 = theme.TextPrimary,
        Font       = Enum.Font.GothamSemibold,
        TextSize   = 13,
    }, card)

    local keyBox = Util.Frame({
        Name             = "KeyBox",
        Size             = UDim2.new(0, 78, 0, 24),
        Position         = UDim2.new(1, -78, 0.5, -12),
        BackgroundColor3 = theme.InputBG,
        ZIndex           = card.ZIndex + 2,
    }, card)
    Util.Round(keyBox, 5)
    local keyStroke = Util.Stroke(keyBox, theme.Border, 1, 0.3)
    Util.Padding(keyBox, 0, 0, 6, 6)

    local function KeyName(k)
        if type(k) == "EnumItem" then
            return k.Name
        end
        return tostring(k)
    end

    local keyLbl = Util.Label({
        Size       = UDim2.new(1, 0, 1, 0),
        Text       = KeyName(currentKey),
        TextColor3 = theme.Accent,
        Font       = Enum.Font.GothamBold,
        TextSize   = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex     = card.ZIndex + 3,
    }, keyBox)

    local keyBtn = Util.Button({
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex               = card.ZIndex + 4,
    }, keyBox)

    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyLbl.Text      = "..."
        keyLbl.TextColor3 = theme.Warning
        Util.TweenFast(keyStroke, { Color = theme.Warning, Transparency = 0 })

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            local isKey   = input.UserInputType == Enum.UserInputType.Keyboard
            local isMouse = allowMouse and input.UserInputType == Enum.UserInputType.MouseButton1

            if input.KeyCode == Enum.KeyCode.Escape then
                listening = false
                keyLbl.Text       = KeyName(currentKey)
                keyLbl.TextColor3 = theme.Accent
                Util.TweenFast(keyStroke, { Color = theme.Border, Transparency = 0.3 })
                conn:Disconnect()
                return
            end

            if isKey then
                local blacklisted = false
                for _, k in ipairs(blacklist) do
                    if input.KeyCode == k then blacklisted = true break end
                end
                if not blacklisted then
                    currentKey = input.KeyCode
                    keyLbl.Text       = KeyName(currentKey)
                    keyLbl.TextColor3 = theme.Accent
                    Util.TweenFast(keyStroke, { Color = theme.Border, Transparency = 0.3 })
                    listening = false
                    pcall(opts.OnChanged, currentKey)
                    conn:Disconnect()
                end
            elseif isMouse then
                currentKey = input.UserInputType
                keyLbl.Text       = "Mouse1"
                keyLbl.TextColor3 = theme.Accent
                Util.TweenFast(keyStroke, { Color = theme.Border, Transparency = 0.3 })
                listening = false
                conn:Disconnect()
            end
        end)
    end)

    -- Global key listener
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or listening then return end
        if input.KeyCode == currentKey then
            pcall(callback)
        end
    end)

    keyBox.MouseEnter:Connect(function() Util.TweenFast(card, { BackgroundColor3 = theme.ElementHover }) end)
    keyBox.MouseLeave:Connect(function() Util.TweenFast(card, { BackgroundColor3 = theme.ElementBG }) end)

    if tooltip ~= "" then TooltipSystem.Attach(card, tooltip, theme) end

    if flag then
        ConfigSystem.Register(flag,
            function() return currentKey.Name end,
            function(v)
                local k = Enum.KeyCode[v]
                if k then currentKey = k ; keyLbl.Text = KeyName(k) end
            end
        )
    end

    local KB = {}
    function KB:Set(k)
        currentKey = k
        keyLbl.Text = KeyName(k)
    end
    function KB:Get()      return currentKey end
    function KB:SetLabel(t) lbl.Text = t end
    function KB:Destroy()  Util.Destroy(card) end
    return KB
end

-- ┌──────────────────────────────────────────────────────────────┐
-- │  COLOR PICKER                                                 │
-- └──────────────────────────────────────────────────────────────┘
function Tab:ColorPicker(opts)
    opts = opts or {}
    local label    = opts.Label    or opts.Name or opts[1] or "Color"
    local default  = opts.Default  or opts.Color or Color3.fromRGB(255, 100, 100)
    local callback = opts.Callback or opts[2] or function() end
    local tooltip  = opts.Tooltip  or ""
    local flag     = opts.Flag     or opts.ConfigKey or nil
    local theme    = self._theme
    local scroll   = self._scroll

    local color     = default
    local h, s, v  = Color3.toHSV(color)
    local alpha     = 1.0
    local showAlpha = opts.Alpha or false
    local open      = false

    local card = MakeElementCard(scroll, theme, ELEMENT_H, "ColorPicker_" .. label)
    card.ClipsDescendants = false
    Util.Padding(card, 0, 0, 14, 14)

    local lbl = Util.Label({
        Size       = UDim2.new(1, -56, 1, 0),
        Text       = label,
        TextColor3 = theme.TextPrimary,
        Font       = Enum.Font.GothamSemibold,
        TextSize   = 13,
    }, card)

    local previewBtn = Util.Button({
        Name             = "Preview",
        Size             = UDim2.new(0, 44, 0, 24),
        Position         = UDim2.new(1, -44, 0.5, -12),
        BackgroundColor3 = color,
        ZIndex           = card.ZIndex + 2,
    }, card)
    Util.Round(previewBtn, 6)
    Util.Stroke(previewBtn, theme.Border, 1, 0.2)

    -- Hex label under preview
    local hexLbl = Util.Label({
        Size       = UDim2.new(0, 44, 0, 10),
        Position   = UDim2.new(1, -44, 1, -2),
        Text       = Util.ColorToHex(color),
        TextColor3 = theme.TextMuted,
        Font       = Enum.Font.Gotham,
        TextSize   = 8,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex     = card.ZIndex + 2,
    }, card)

    local pickerFrame = nil

    local function BuildPicker()
        local pickerH = showAlpha and 185 or 160
        pickerFrame = Util.Frame({
            Name             = "PickerFrame",
            Size             = UDim2.new(1, 0, 0, pickerH),
            Position         = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = theme.DropdownBG,
            ZIndex           = card.ZIndex + 10,
            ClipsDescendants = false,
        }, card)
        Util.Round(pickerFrame, 8)
        Util.Stroke(pickerFrame, theme.Border, 1, 0.2)
        Util.Padding(pickerFrame, 10, 10, 10, 10)

        local pLayout = Util.ListLayout(pickerFrame, Enum.FillDirection.Vertical, nil, 8)

        -- SV Square
        local svFrame = Util.Frame({
            Name             = "SV",
            Size             = UDim2.new(1, 0, 0, 90),
            BackgroundColor3 = Color3.fromHSV(h, 1, 1),
            LayoutOrder      = 1,
        }, pickerFrame)
        Util.Round(svFrame, 5)

        -- White gradient overlay
        local wGrad = Util.Image({
            Size  = UDim2.new(1, 0, 1, 0),
            Image = "rbxassetid://4155801252", -- white to transparent gradient
            ZIndex = svFrame.ZIndex + 1,
        }, svFrame)
        Util.Gradient(svFrame, ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(h,1,1)),
        }), 0)

        -- Black overlay
        local bGrad = Util.Frame({
            Size = UDim2.new(1,0,1,0),
            BackgroundColor3 = Color3.new(0,0,0),
            BackgroundTransparency = 0,
            ZIndex = svFrame.ZIndex + 2,
        }, svFrame)
        Util.Gradient(bGrad, ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
            ColorSequenceKeypoint.new(1, Color3.new(0,0,0)),
        }), 90)
        -- bGrad transparency gradient (bottom dark, top clear)
        local bGrad2 = Instance.new("UIGradient")
        bGrad2.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
            ColorSequenceKeypoint.new(1, Color3.new(0,0,0)),
        })
        bGrad2.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        bGrad2.Rotation = 90
        bGrad2.Parent = bGrad

        -- SV cursor
        local svCursor = Util.Frame({
            Size             = UDim2.new(0, 12, 0, 12),
            Position         = UDim2.new(s, -6, 1-v, -6),
            BackgroundColor3 = Color3.new(1,1,1),
            ZIndex           = svFrame.ZIndex + 5,
        }, svFrame)
        Util.Round(svCursor, 6)
        Util.Stroke(svCursor, Color3.new(0,0,0), 2, 0)

        -- Hue bar
        local hueBar = Util.Frame({
            Name        = "HueBar",
            Size        = UDim2.new(1, 0, 0, 14),
            LayoutOrder = 2,
        }, pickerFrame)
        Util.Round(hueBar, 4)
        Util.Gradient(hueBar, ColorSequence.new({
            ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,     1, 1)),
            ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167, 1, 1)),
            ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333, 1, 1)),
            ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5,   1, 1)),
            ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667, 1, 1)),
            ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833, 1, 1)),
            ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,     1, 1)),
        }), 0)

        local hueCursor = Util.Frame({
            Size             = UDim2.new(0, 4, 1, 4),
            Position         = UDim2.new(h, -2, 0, -2),
            BackgroundColor3 = Color3.new(1,1,1),
            ZIndex           = hueBar.ZIndex + 2,
        }, hueBar)
        Util.Round(hueCursor, 2)
        Util.Stroke(hueCursor, Color3.new(0,0,0), 1, 0)

        -- Alpha bar (optional)
        local alphaBar, alphaCursor
        if showAlpha then
            alphaBar = Util.Frame({
                Name        = "AlphaBar",
                Size        = UDim2.new(1, 0, 0, 14),
                LayoutOrder = 3,
            }, pickerFrame)
            Util.Round(alphaBar, 4)
            Util.Gradient(alphaBar, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
                ColorSequenceKeypoint.new(1, color),
            }), 0)

            alphaCursor = Util.Frame({
                Size             = UDim2.new(0, 4, 1, 4),
                Position         = UDim2.new(alpha, -2, 0, -2),
                BackgroundColor3 = Color3.new(1,1,1),
                ZIndex           = alphaBar.ZIndex + 2,
            }, alphaBar)
            Util.Round(alphaCursor, 2)
            Util.Stroke(alphaCursor, Color3.new(0,0,0), 1, 0)
        end

        -- Hex input row
        local hexRow = Util.Frame({
            Name                 = "HexRow",
            Size                 = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            LayoutOrder          = showAlpha and 4 or 3,
        }, pickerFrame)

        local hexBg = Util.Frame({
            Size             = UDim2.new(0.6, -4, 1, 0),
            BackgroundColor3 = theme.InputBG,
        }, hexRow)
        Util.Round(hexBg, 5)
        Util.Padding(hexBg, 0, 0, 6, 6)
        Util.Stroke(hexBg, theme.Border, 1, 0.3)

        local hexInput = Util.New("TextBox", {
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                 = Util.ColorToHex(color),
            TextColor3           = theme.TextPrimary,
            Font                 = Enum.Font.Code,
            TextSize             = 11,
            PlaceholderText      = "#FFFFFF",
            PlaceholderColor3    = theme.TextMuted,
            ZIndex               = pickerFrame.ZIndex + 5,
        }, hexBg)

        local previewSmall = Util.Frame({
            Size             = UDim2.new(0.4, -4, 1, 0),
            Position         = UDim2.new(0.6, 4, 0, 0),
            BackgroundColor3 = color,
        }, hexRow)
        Util.Round(previewSmall, 5)
        Util.Stroke(previewSmall, theme.Border, 1, 0.3)

        -- Update function
        local function UpdateAll()
            color = Color3.fromHSV(h, s, v)
            previewBtn.BackgroundColor3 = color
            previewSmall.BackgroundColor3 = color
            hexLbl.Text  = Util.ColorToHex(color)
            hexInput.Text = Util.ColorToHex(color)
            svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            Util.Gradient(svFrame, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(h,1,1)),
            }), 0)
            svCursor.Position = UDim2.new(s, -6, 1-v, -6)
            hueCursor.Position = UDim2.new(h, -2, 0, -2)
            if showAlpha and alphaBar then
                Util.Gradient(alphaBar, ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
                    ColorSequenceKeypoint.new(1, color),
                }), 0)
                alphaCursor.Position = UDim2.new(alpha, -2, 0, -2)
            end
            pcall(callback, color, alpha)
        end

        -- SV drag
        local svDragging = false
        svFrame.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                svDragging = true
                local relX = math.clamp(i.Position.X - svFrame.AbsolutePosition.X, 0, svFrame.AbsoluteSize.X)
                local relY = math.clamp(i.Position.Y - svFrame.AbsolutePosition.Y, 0, svFrame.AbsoluteSize.Y)
                s = relX / svFrame.AbsoluteSize.X
                v = 1 - relY / svFrame.AbsoluteSize.Y
                UpdateAll()
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                svDragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if svDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local relX = math.clamp(i.Position.X - svFrame.AbsolutePosition.X, 0, svFrame.AbsoluteSize.X)
                local relY = math.clamp(i.Position.Y - svFrame.AbsolutePosition.Y, 0, svFrame.AbsoluteSize.Y)
                s = relX / svFrame.AbsoluteSize.X
                v = 1 - relY / svFrame.AbsoluteSize.Y
                UpdateAll()
            end
        end)

        -- Hue drag
        local hueDragging = false
        local function UpdateHue(ix)
            h = math.clamp((ix - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
            UpdateAll()
        end
        hueBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                hueDragging = true
                UpdateHue(i.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if hueDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateHue(i.Position.X)
            end
        end)

        -- Alpha drag
        if showAlpha and alphaBar then
            local alphaDragging = false
            local function UpdateAlpha(ix)
                alpha = math.clamp((ix - alphaBar.AbsolutePosition.X) / alphaBar.AbsoluteSize.X, 0, 1)
                UpdateAll()
            end
            alphaBar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    alphaDragging = true
                    UpdateAlpha(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then alphaDragging = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if alphaDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateAlpha(i.Position.X)
                end
            end)
        end

        -- Hex input
        hexInput.FocusLost:Connect(function()
            local c = pcall(function()
                local newC = Util.HexToColor(hexInput.Text)
                h, s, v = Color3.toHSV(newC)
                UpdateAll()
            end)
        end)
    end

    previewBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            card.Size = UDim2.new(1, 0, 0, ELEMENT_H + 4 + (showAlpha and 185 or 160))
            BuildPicker()
        else
            card.Size = UDim2.new(1, 0, 0, ELEMENT_H)
            if pickerFrame then Util.Destroy(pickerFrame) ; pickerFrame = nil end
        end
    end)

    if tooltip ~= "" then TooltipSystem.Attach(card, tooltip, theme) end

    if flag then
        ConfigSystem.Register(flag,
            function() return Util.ColorToHex(color) end,
            function(v) local c = pcall(function()
                local nc = Util.HexToColor(v)
                color = nc ; h, s, vv = Color3.toHSV(nc)
                previewBtn.BackgroundColor3 = nc
                hexLbl.Text = Util.ColorToHex(nc)
            end) end
        )
    end

    local CP = {}
    function CP:Set(c)
        color = c
        h, s, v = Color3.toHSV(c)
        previewBtn.BackgroundColor3 = c
        hexLbl.Text = Util.ColorToHex(c)
        pcall(callback, c, alpha)
    end
    function CP:Get()      return color end
    function CP:GetAlpha() return alpha end
    function CP:SetLabel(t) lbl.Text = t end
    function CP:Destroy()  Util.Destroy(card) end
    return CP
end

-- ┌──────────────────────────────────────────────────────────────┐
-- │  LABEL                                                        │
-- └──────────────────────────────────────────────────────────────┘
function Tab:Label(opts)
    opts = opts or {}
    local text  = type(opts) == "string" and opts or (opts.Text or opts.Label or opts[1] or "Label")
    local color = opts.Color or self._theme.TextSecondary
    local font  = opts.Font  or Enum.Font.Gotham
    local size  = opts.TextSize or 12
    local theme = self._theme
    local scroll = self._scroll

    local lbl = Util.Label({
        Name         = "Label",
        Size         = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text         = text,
        TextColor3   = color,
        Font         = font,
        TextSize     = size,
        TextWrapped  = true,
        LayoutOrder  = #scroll:GetChildren(),
    }, scroll)
    Util.Padding(lbl, 2, 2, 2, 2)

    local L = {}
    function L:Set(t)     lbl.Text = t end
    function L:SetColor(c) lbl.TextColor3 = c end
    function L:SetFont(f, s) lbl.Font = f ; if s then lbl.TextSize = s end end
    function L:Destroy()  Util.Destroy(lbl) end
    return L
end

-- ┌──────────────────────────────────────────────────────────────┐
-- │  PARAGRAPH                                                    │
-- └──────────────────────────────────────────────────────────────┘
function Tab:Paragraph(opts)
    opts = opts or {}
    local title = opts.Title or opts.Name or opts[1] or ""
    local body  = opts.Body  or opts.Text or opts[2] or ""
    local theme = self._theme
    local scroll = self._scroll

    local card = Util.Frame({
        Name             = "Paragraph",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.ElementBG,
        LayoutOrder      = #scroll:GetChildren(),
    }, scroll)
    Util.Round(card, 8)
    Util.Stroke(card, theme.Border, 1, 0.5)
    Util.Padding(card, 10, 10, 14, 14)

    local layout = Util.ListLayout(card, Enum.FillDirection.Vertical, nil, 4)

    local titleLbl, bodyLbl

    if title ~= "" then
        titleLbl = Util.Label({
            Size       = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text       = title,
            TextColor3 = theme.TextPrimary,
            Font       = Enum.Font.GothamBold,
            TextSize   = 13,
            TextWrapped = true,
            LayoutOrder = 1,
        }, card)
    end

    if body ~= "" then
        bodyLbl = Util.Label({
            Size       = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text       = body,
            TextColor3 = theme.TextSecondary,
            Font       = Enum.Font.Gotham,
            TextSize   = 12,
            TextWrapped = true,
            LineHeight  = 1.3,
            LayoutOrder = 2,
        }, card)
    end

    local P = {}
    function P:SetTitle(t) if titleLbl then titleLbl.Text = t end end
    function P:SetBody(t)  if bodyLbl  then bodyLbl.Text  = t end end
    function P:Destroy()   Util.Destroy(card) end
    return P
end

-- ┌──────────────────────────────────────────────────────────────┐
-- │  SEPARATOR                                                    │
-- └──────────────────────────────────────────────────────────────┘
function Tab:Separator(opts)
    opts = opts or {}
    local text  = opts.Text or opts[1] or ""
    local theme = self._theme
    local scroll = self._scroll

    local sep = Util.Frame({
        Name                 = "Separator",
        Size                 = UDim2.new(1, 0, 0, text ~= "" and 20 or 8),
        BackgroundTransparency = 1,
        LayoutOrder          = #scroll:GetChildren(),
    }, scroll)

    if text ~= "" then
        local row = Util.Frame({
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
        }, sep)
        Util.Frame({ Size = UDim2.new(0.35, -8, 0, 1), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = theme.SectionLine, BackgroundTransparency = 0.4 }, row)
        Util.Label({ Size = UDim2.new(0.3, 0, 1, 0), Position = UDim2.new(0.35, 0, 0, 0), Text = text, TextColor3 = theme.TextMuted, Font = Enum.Font.GothamSemibold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Center }, row)
        Util.Frame({ Size = UDim2.new(0.35, -8, 0, 1), Position = UDim2.new(0.65, 8, 0.5, 0), BackgroundColor3 = theme.SectionLine, BackgroundTransparency = 0.4 }, row)
    else
        Util.Frame({ Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = theme.SectionLine, BackgroundTransparency = 0.4 }, sep)
    end
end

-- ┌──────────────────────────────────────────────────────────────┐
-- │  PROGRESS BAR                                                 │
-- └──────────────────────────────────────────────────────────────┘
function Tab:ProgressBar(opts)
    opts = opts or {}
    local label   = opts.Label   or opts.Name or opts[1] or "Progress"
    local minimum = opts.Min     or 0
    local maximum = opts.Max     or 100
    local default = opts.Default or opts.Value or 0
    local suffix  = opts.Suffix  or "%"
    local color   = opts.Color   or nil
    local theme   = self._theme
    local scroll  = self._scroll

    local value = math.clamp(default, minimum, maximum)

    local card = MakeElementCard(scroll, theme, 48, "ProgressBar_" .. label)
    Util.Padding(card, 8, 10, 14, 14)

    local topLayout = Util.ListLayout(card, Enum.FillDirection.Vertical, nil, 6)

    local topRow = Util.Frame({ Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = 1 }, card)
    local lbl = Util.Label({ Size = UDim2.new(0.7, 0, 1, 0), Text = label, TextColor3 = theme.TextPrimary, Font = Enum.Font.GothamSemibold, TextSize = 12 }, topRow)
    local pctLbl = Util.Label({
        Size = UDim2.new(0.3, 0, 1, 0), Position = UDim2.new(0.7, 0, 0, 0),
        Text = tostring(value) .. suffix,
        TextColor3 = color or theme.Accent, Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, topRow)

    local trackBg = Util.Frame({ Size = UDim2.new(1, 0, 0, 8), BackgroundColor3 = theme.SliderTrack, LayoutOrder = 2 }, card)
    Util.Round(trackBg, 4)

    local fill = Util.Frame({ Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = color or theme.Accent }, trackBg)
    Util.Round(fill, 4)
    if not color then
        Util.Gradient(fill, ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme.AccentDark),
            ColorSequenceKeypoint.new(1, theme.AccentLight),
        }), 0)
    end

    local function SetValue(v, animated)
        value = math.clamp(v, minimum, maximum)
        local pct = (value - minimum) / (maximum - minimum)
        pctLbl.Text = tostring(Util.Round2(value, 1)) .. suffix
        if animated then
            Util.TweenMed(fill, { Size = UDim2.new(pct, 0, 1, 0) })
        else
            fill.Size = UDim2.new(pct, 0, 1, 0)
        end
    end
    SetValue(value, false)

    local PB = {}
    function PB:Set(v, animated)  SetValue(v, animated ~= false) end
    function PB:Get()             return value end
    function PB:SetLabel(t)       lbl.Text = t end
    function PB:SetColor(c)
        fill.BackgroundColor3 = c
        pctLbl.TextColor3 = c
    end
    function PB:Destroy()         Util.Destroy(card) end
    return PB
end

-- ┌──────────────────────────────────────────────────────────────┐
-- │  IMAGE                                                        │
-- └──────────────────────────────────────────────────────────────┘
function Tab:Image(opts)
    opts = opts or {}
    local asset  = opts.Image  or opts.Asset or opts[1] or ""
    local height = opts.Height or 120
    local label  = opts.Label  or ""
    local theme  = self._theme
    local scroll = self._scroll

    local card = MakeElementCard(scroll, theme, height + (label ~= "" and 24 or 0), "Image")
    local img = Util.Image({
        Size  = UDim2.new(1, 0, 1, label ~= "" and -24 or 0),
        Image = asset,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = card.ZIndex + 1,
    }, card)
    if label ~= "" then
        Util.Label({
            Size      = UDim2.new(1, 0, 0, 20),
            Position  = UDim2.new(0, 0, 1, -22),
            Text      = label,
            TextColor3 = theme.TextMuted,
            Font      = Enum.Font.Gotham,
            TextSize  = 11,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex    = card.ZIndex + 2,
        }, card)
    end

    local I = {}
    function I:SetImage(a) img.Image = a end
    function I:Destroy()   Util.Destroy(card) end
    return I
end

-- ┌──────────────────────────────────────────────────────────────┐
-- │  CONFIG SELECTOR (Save/Load UI element)                       │
-- └──────────────────────────────────────────────────────────────┘
function Tab:ConfigManager(opts)
    opts  = opts  or {}
    local theme  = self._theme
    local scroll = self._scroll

    local card = Util.Frame({
        Name             = "ConfigManager",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.ElementBG,
        LayoutOrder      = #scroll:GetChildren(),
    }, scroll)
    Util.Round(card, 8)
    Util.Stroke(card, theme.Border, 1, 0.5)
    Util.Padding(card, 10, 10, 14, 14)

    local layout = Util.ListLayout(card, Enum.FillDirection.Vertical, nil, 8)

    local headerLbl = Util.Label({
        Size = UDim2.new(1,0,0,14), Text = "CONFIG MANAGER",
        TextColor3 = theme.TextMuted, Font = Enum.Font.GothamBold, TextSize = 9,
        LayoutOrder = 1,
    }, card)

    -- Filename input
    local inputBg = Util.Frame({ Size = UDim2.new(1,0,0,28), BackgroundColor3 = theme.InputBG, LayoutOrder = 2 }, card)
    Util.Round(inputBg, 6) ; Util.Stroke(inputBg, theme.Border, 1, 0.3) ; Util.Padding(inputBg, 0, 0, 8, 8)
    local nameInput = Util.New("TextBox", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
        Text = "", PlaceholderText = "Config name...", PlaceholderColor3 = theme.TextMuted,
        TextColor3 = theme.TextPrimary, Font = Enum.Font.Gotham, TextSize = 12,
    }, inputBg)

    -- Buttons row
    local btnRow = Util.Frame({ Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1, LayoutOrder = 3 }, card)
    local bLayout = Util.ListLayout(btnRow, Enum.FillDirection.Horizontal, nil, 6)

    local function MakeSmallBtn(text, color, onClick)
        local b = Util.Button({
            Size             = UDim2.new(0.5, -3, 1, 0),
            BackgroundColor3 = color or theme.ElementHover,
            Text             = text,
            TextColor3       = theme.TextPrimary,
            Font             = Enum.Font.GothamSemibold,
            TextSize         = 11,
        }, btnRow)
        Util.Round(b, 5)
        b.MouseButton1Click:Connect(onClick)
        return b
    end

    MakeSmallBtn("💾 Save", theme.AccentDark, function()
        local name = nameInput.Text:gsub("[^%w%s%-_]", "")
        if name == "" then name = "default" end
        ConfigSystem.Save(name)
        NotificationSystem.Send({ Title = "Config Saved", Message = '"' .. name .. '" saved successfully.', Type = "Success", Theme = theme })
    end)

    MakeSmallBtn("📂 Load", theme.ElementHover, function()
        local name = nameInput.Text:gsub("[^%w%s%-_]", "")
        if name == "" then name = "default" end
        local ok = ConfigSystem.Load(name)
        NotificationSystem.Send({
            Title = ok and "Config Loaded" or "Load Failed",
            Message = ok and ('"' .. name .. '" loaded.') or "Config not found.",
            Type = ok and "Success" or "Error",
            Theme = theme,
        })
    end)

    -- Config list
    local listFrame = Util.Frame({
        Name             = "ConfigList",
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder      = 4,
    }, card)
    local listLayout = Util.ListLayout(listFrame, Enum.FillDirection.Vertical, nil, 4)

    local function RefreshList()
        for _, c in ipairs(listFrame:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local files = ConfigSystem.List()
        for _, f in ipairs(files) do
            local row = Util.Frame({ Size = UDim2.new(1,0,0,26), BackgroundColor3 = theme.InputBG }, listFrame)
            Util.Round(row, 5) ; Util.Padding(row, 0, 0, 8, 8)

            Util.Label({ Size = UDim2.new(1,-52,1,0), Text = f, TextColor3 = theme.TextSecondary, Font = Enum.Font.Gotham, TextSize = 11 }, row)

            local loadBtn = Util.Button({ Size = UDim2.new(0,44,0,18), Position = UDim2.new(1,-46,0.5,-9), BackgroundColor3 = theme.AccentDark, Text = "Load", TextColor3 = theme.TextPrimary, Font = Enum.Font.GothamSemibold, TextSize = 10 }, row)
            Util.Round(loadBtn, 4)
            loadBtn.MouseButton1Click:Connect(function()
                ConfigSystem.Load(f)
                NotificationSystem.Send({ Title = "Loaded", Message = f, Type = "Success", Theme = theme })
            end)
        end
    end
    RefreshList()

    local CM = {}
    function CM:Refresh() RefreshList() end
    function CM:Destroy() Util.Destroy(card) end
    return CM
end

-- ════════════════════════════════════════════════════════════════
--  WINDOW
-- ════════════════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

function Window.new(opts)
    local self     = setmetatable({}, Window)
    opts           = opts or {}
    self._opts     = opts
    self._tabs     = {}
    self._activeTab = nil
    self._theme    = type(opts.Theme) == "table" and opts.Theme or (Themes[opts.Theme] or Themes.Midnight)
    self._connections = {}
    self._visible  = true

    local theme    = self._theme
    local title    = opts.Title    or "NexusLib"
    local subtitle = opts.Subtitle or ""
    local logoIcon = opts.Icon     or ""
    local size     = opts.Size     or UDim2.new(0, 580, 0, 420)
    local minW     = opts.MinWidth  or 400
    local minH     = opts.MinHeight or 300

    ConfigSystem.Init(opts.ConfigFolder)

    -- ── ROOT SCREENGUI ───────────────────────────────────────────
    self._gui = Util.New("ScreenGui", {
        Name           = "NexusLib_" .. title,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 200,
        IgnoreGuiInset = true,
    })
    Util.SafeParent(self._gui)

    -- Shadow
    local shadow = Util.Shadow(self._gui, 40, 0.55, ZBASE)
    shadow.Size     = UDim2.new(0, size.X.Offset + 40, 0, size.Y.Offset + 40)
    shadow.Position = UDim2.new(0.5, -(size.X.Offset + 40)/2, 0.5, -(size.Y.Offset + 40)/2)

    -- Glow effect (accent-colored)
    local glow = Util.Frame({
        Name                 = "Glow",
        Size                 = UDim2.new(0, size.X.Offset + 60, 0, size.Y.Offset + 60),
        Position             = UDim2.new(0.5, -(size.X.Offset + 60)/2, 0.5, -(size.Y.Offset + 60)/2),
        BackgroundColor3     = theme.AccentGlow,
        BackgroundTransparency = 0.92,
        ZIndex               = ZBASE - 1,
    }, self._gui)
    Util.Round(glow, 20)

    -- ── MAIN WINDOW FRAME ────────────────────────────────────────
    self._win = Util.Frame({
        Name             = "Window",
        Size             = size,
        Position         = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = theme.WindowBG,
        ClipsDescendants = false,
        ZIndex           = ZBASE,
    }, self._gui)
    Util.Round(self._win, 12)
    Util.Stroke(self._win, theme.Border, 1, 0.3)

    -- Sync shadow/glow with window
    self._win:GetPropertyChangedSignal("Position"):Connect(function()
        local p = self._win.Position
        shadow.Position = UDim2.new(p.X.Scale, p.X.Offset - 20, p.Y.Scale, p.Y.Offset - 20)
        glow.Position   = UDim2.new(p.X.Scale, p.X.Offset - 30, p.Y.Scale, p.Y.Offset - 30)
    end)

    -- ── TITLE BAR ────────────────────────────────────────────────
    self._titleBar = Util.Frame({
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, TITLEBAR_H),
        BackgroundColor3 = theme.TitleBG,
        ZIndex           = ZBASE + 2,
        ClipsDescendants = true,
    }, self._win)
    Util.Round(self._titleBar, 12)

    -- Cover bottom-round corners of title bar
    Util.Frame({
        Size             = UDim2.new(1, 0, 0, 12),
        Position         = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = theme.TitleBG,
        ZIndex           = ZBASE + 1,
    }, self._titleBar)

    -- Bottom border line on title bar
    Util.Frame({
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = theme.Border,
        ZIndex           = ZBASE + 3,
    }, self._titleBar)

    Util.Padding(self._titleBar, 0, 0, 16, 12)

    -- Icon
    local iconOffset = 0
    if logoIcon ~= "" then
        local ic = Util.Label({
            Size       = UDim2.new(0, 22, 1, 0),
            Text       = logoIcon,
            TextColor3 = theme.Accent,
            Font       = Enum.Font.GothamBold,
            TextSize   = 18,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex     = ZBASE + 3,
        }, self._titleBar)
        iconOffset = 28
    end

    -- Title
    local titleLbl = Util.Label({
        Size       = UDim2.new(0, 200, 1, 0),
        Position   = UDim2.new(0, iconOffset, 0, 0),
        Text       = title,
        TextColor3 = theme.TextPrimary,
        Font       = Enum.Font.GothamBold,
        TextSize   = 15,
        ZIndex     = ZBASE + 3,
    }, self._titleBar)

    -- Subtitle
    if subtitle ~= "" then
        Util.Label({
            Size       = UDim2.new(0, 120, 1, 0),
            Position   = UDim2.new(0, iconOffset + Util.TextSize(title, Enum.Font.GothamBold, 15).X + 8, 0, 0),
            Text       = subtitle,
            TextColor3 = theme.TextMuted,
            Font       = Enum.Font.Gotham,
            TextSize   = 11,
            ZIndex     = ZBASE + 3,
        }, self._titleBar)
    end

    -- Window control buttons (close/min/max style)
    local function MakeCtrlBtn(xOffset, bg, icon, action)
        local btn = Util.Button({
            Size             = UDim2.new(0, 20, 0, 20),
            Position         = UDim2.new(1, xOffset, 0.5, -10),
            BackgroundColor3 = bg,
            ZIndex           = ZBASE + 4,
            Text             = "",
        }, self._titleBar)
        Util.Round(btn, 10)
        local iconL = Util.Label({
            Size       = UDim2.new(1,0,1,0),
            Text       = icon,
            TextColor3 = Color3.new(0,0,0),
            Font       = Enum.Font.GothamBold,
            TextSize   = 10,
            TextXAlignment = Enum.TextXAlignment.Center,
            BackgroundTransparency = 1,
            Visible    = false,
            ZIndex     = ZBASE + 5,
        }, btn)
        btn.MouseEnter:Connect(function()  iconL.Visible = true  ; Util.TweenFast(btn, { BackgroundColor3 = bg }) end)
        btn.MouseLeave:Connect(function()  iconL.Visible = false end)
        btn.MouseButton1Click:Connect(action)
        return btn
    end

    local minimized  = false
    local origSize   = self._win.Size
    local origShadSz = shadow.Size

    MakeCtrlBtn(-10, theme.Danger, "×", function()
        Util.TweenMed(self._win, { Size = UDim2.new(0, origSize.X.Offset, 0, 0), BackgroundTransparency = 1 })
        Util.TweenMed(shadow,    { BackgroundTransparency = 1 })
        Util.TweenMed(glow,      { BackgroundTransparency = 1 })
        task.delay(0.3, function() self:Destroy() end)
    end)

    MakeCtrlBtn(-34, theme.Warning, "–", function()
        minimized = not minimized
        if minimized then
            origSize    = self._win.Size
            origShadSz  = shadow.Size
            Util.TweenMed(self._win, { Size = UDim2.new(0, origSize.X.Offset, 0, TITLEBAR_H) })
        else
            Util.TweenMed(self._win, { Size = origSize })
        end
    end)

    MakeCtrlBtn(-58, theme.Success, "+", function()
        -- Maximise / restore
        local screen = Camera.ViewportSize
        if self._win.Size.X.Offset < screen.X - 40 then
            origSize = self._win.Size
            Util.TweenMed(self._win, {
                Size     = UDim2.new(0, screen.X - 40, 0, screen.Y - 40),
                Position = UDim2.new(0, 20, 0, 20),
            })
        else
            Util.TweenMed(self._win, { Size = origSize })
        end
    end)

    -- Draggable
    Util.Draggable(self._titleBar, self._win)

    -- ── SIDEBAR ──────────────────────────────────────────────────
    self._sidebar = Util.Frame({
        Name             = "Sidebar",
        Size             = UDim2.new(0, SIDEBAR_W, 1, -TITLEBAR_H),
        Position         = UDim2.new(0, 0, 0, TITLEBAR_H),
        BackgroundColor3 = theme.SidebarBG,
        ZIndex           = ZBASE + 1,
        ClipsDescendants = true,
    }, self._win)

    -- Cover sidebar right round corners
    Util.Frame({
        Size             = UDim2.new(0, 12, 1, 0),
        Position         = UDim2.new(1, -12, 0, 0),
        BackgroundColor3 = theme.SidebarBG,
        ZIndex           = ZBASE + 1,
    }, self._sidebar)

    -- Sidebar right border
    Util.Frame({
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = theme.Border,
        ZIndex           = ZBASE + 2,
    }, self._sidebar)

    -- Sidebar scroll for many tabs
    self._sideScroll = Util.ScrollFrame({
        Size                  = UDim2.new(1, -8, 1, 0),
        Position              = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness    = 2,
        ScrollBarImageColor3  = theme.Scrollbar,
        ZIndex                = ZBASE + 2,
        CanvasSize            = UDim2.new(0,0,0,0),
        AutomaticCanvasSize   = Enum.AutomaticSize.Y,
    }, self._sidebar)

    local sideLayout = Util.ListLayout(self._sideScroll, Enum.FillDirection.Vertical, nil, 2)
    Util.Padding(self._sideScroll, 8, 8, 8, 0)

    -- ── CONTENT AREA ─────────────────────────────────────────────
    self._content = Util.Frame({
        Name             = "Content",
        Size             = UDim2.new(1, -SIDEBAR_W, 1, -TITLEBAR_H),
        Position         = UDim2.new(0, SIDEBAR_W, 0, TITLEBAR_H),
        BackgroundColor3 = theme.ContentBG,
        ClipsDescendants = true,
        ZIndex           = ZBASE,
    }, self._win)

    -- Bind-to-hide keybind
    if opts.ToggleKey then
        UserInputService.InputBegan:Connect(function(i, gpe)
            if gpe then return end
            if i.KeyCode == opts.ToggleKey then
                self:SetVisible(not self._visible)
            end
        end)
    end

    return self
end

-- ── ADD TAB ──────────────────────────────────────────────────────
function Window:Tab(opts)
    opts = opts or {}
    local name   = opts.Name  or opts[1] or "Tab"
    local icon   = opts.Icon  or ""
    local theme  = self._theme
    local idx    = #self._tabs + 1

    -- Sidebar tab button
    local tabBtn = Util.Button({
        Name             = "TabBtn_" .. name,
        Size             = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = theme.TabInactive,
        BackgroundTransparency = 1,
        ZIndex           = ZBASE + 3,
        LayoutOrder      = idx,
    }, self._sideScroll)
    Util.Round(tabBtn, 7)
    Util.Padding(tabBtn, 0, 0, 10, 6)

    -- Active indicator bar
    local indicator = Util.Frame({
        Name             = "Indicator",
        Size             = UDim2.new(0, 3, 0.6, 0),
        Position         = UDim2.new(0, 0, 0.2, 0),
        BackgroundColor3 = theme.Accent,
        BackgroundTransparency = 1,
        ZIndex           = ZBASE + 4,
    }, tabBtn)
    Util.Round(indicator, 2)

    -- Icon
    local iconOffset = 0
    if icon ~= "" then
        Util.Label({
            Size       = UDim2.new(0, 20, 1, 0),
            Text       = icon,
            TextColor3 = theme.TextMuted,
            Font       = Enum.Font.GothamBold,
            TextSize   = 14,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex     = ZBASE + 4,
            Name       = "TabIcon",
        }, tabBtn)
        iconOffset = 24
    end

    local tabLbl = Util.Label({
        Size       = UDim2.new(1, -iconOffset, 1, 0),
        Position   = UDim2.new(0, iconOffset, 0, 0),
        Text       = name,
        TextColor3 = theme.TextMuted,
        Font       = Enum.Font.GothamSemibold,
        TextSize   = 12,
        ZIndex     = ZBASE + 4,
        Name       = "TabLabel",
    }, tabBtn)

    -- Content page
    local page = Util.Frame({
        Name             = "Page_" .. name,
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible          = false,
        ClipsDescendants = false,
        ZIndex           = ZBASE + 1,
    }, self._content)

    local pageScroll = Util.ScrollFrame({
        Name                  = "Scroll",
        Size                  = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness    = 4,
        ScrollBarImageColor3  = theme.Scrollbar,
        CanvasSize            = UDim2.new(0,0,0,0),
        AutomaticCanvasSize   = Enum.AutomaticSize.Y,
        ZIndex                = ZBASE + 1,
    }, page)

    local pageLayout = Util.ListLayout(pageScroll, Enum.FillDirection.Vertical, nil, ELEMENT_PAD)
    Util.Padding(pageScroll, 12, 12, 12, 12)

    -- Selection logic
    local function Activate()
        -- Deactivate previous
        if self._activeTab then
            local prev = self._activeTab
            Util.TweenFast(prev._btn, { BackgroundColor3 = theme.TabInactive, BackgroundTransparency = 1 })
            Util.TweenFast(prev._lbl, { TextColor3 = theme.TextMuted, Font = Enum.Font.GothamSemibold })
            Util.TweenFast(prev._ind, { BackgroundTransparency = 1 })
            if prev._icon then Util.TweenFast(prev._icon, { TextColor3 = theme.TextMuted }) end
            prev._page.Visible = false
        end
        -- Activate
        Util.TweenFast(tabBtn, { BackgroundColor3 = theme.ElementBG, BackgroundTransparency = 0 })
        Util.TweenFast(tabLbl, { TextColor3 = theme.TextPrimary, Font = Enum.Font.GothamBold })
        Util.TweenFast(indicator, { BackgroundTransparency = 0 })
        local iconLabel = tabBtn:FindFirstChild("TabIcon")
        if iconLabel then Util.TweenFast(iconLabel, { TextColor3 = theme.Accent }) end
        page.Visible = true

        self._activeTab = {
            _btn  = tabBtn,
            _lbl  = tabLbl,
            _ind  = indicator,
            _icon = tabBtn:FindFirstChild("TabIcon"),
            _page = page,
        }
    end

    tabBtn.MouseButton1Click:Connect(Activate)
    tabBtn.MouseEnter:Connect(function()
        if self._activeTab and self._activeTab._btn ~= tabBtn then
            Util.TweenFast(tabBtn, { BackgroundColor3 = theme.ElementBG, BackgroundTransparency = 0.5 })
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self._activeTab and self._activeTab._btn ~= tabBtn then
            Util.TweenFast(tabBtn, { BackgroundTransparency = 1 })
        end
    end)

    -- Auto-select first
    if idx == 1 then Activate() end

    -- Build Tab object
    local tabObj = Tab.new(pageScroll, theme, self)
    tabObj._btn = tabBtn
    tabObj._select = Activate

    table.insert(self._tabs, tabObj)
    return tabObj
end

-- ── WINDOW API ───────────────────────────────────────────────────
function Window:SetVisible(v)
    self._visible = v
    self._gui.Enabled = v
end

function Window:Toggle()
    self:SetVisible(not self._visible)
end

function Window:SetTitle(t)
    local lbl = self._titleBar:FindFirstChild("TextLabel")
    if lbl then lbl.Text = t end
end

function Window:SetTheme(themeName)
    -- Minimal theme update (full rebuild is complex; recommend recreating window)
    self._theme = type(themeName) == "table" and themeName or (Themes[themeName] or Themes.Midnight)
end

function Window:Notify(opts)
    opts = opts or {}
    opts.Theme = self._theme
    NotificationSystem.Send(opts)
end

function Window:Destroy()
    Util.DisconnectAll(self._connections)
    Util.Destroy(self._gui)
end

-- ════════════════════════════════════════════════════════════════
--  NEXUSLIB MAIN OBJECT
-- ════════════════════════════════════════════════════════════════
local NexusLib = {}
NexusLib.__index = NexusLib

NexusLib.Version  = "2.0.0"
NexusLib.Themes   = Themes
NexusLib.Util     = Util
NexusLib.Config   = ConfigSystem

function NexusLib:Window(opts)
    return Window.new(opts)
end

function NexusLib:Notify(opts)
    NotificationSystem.Send(opts)
end

function NexusLib:Watermark(opts)
    return WatermarkSystem.Create(opts, type(opts.Theme) == "table" and opts.Theme or (Themes[opts.Theme] or Themes.Midnight))
end

function NexusLib:AddTheme(name, themeTable)
    Themes[name] = themeTable
end

function NexusLib:GetThemes()
    local t = {}
    for k in pairs(Themes) do table.insert(t, k) end
    return t
end

function NexusLib:DestroyAll()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui.Name:find("NexusLib") then gui:Destroy() end
    end
    pcall(function()
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if gui.Name:find("NexusLib") then gui:Destroy() end
        end
    end)
end

return NexusLib
