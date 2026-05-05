--[[
    ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗██╗     ██╗██████╗
    ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝██║     ██║██╔══██╗
    ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗██║     ██║██████╔╝
    ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║██║     ██║██╔══██╗
    ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║███████╗██║██████╔╝
    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚═╝╚═════╝
    NexusLib v2.3  —  Premium Roblox UI Library
    Sub-tab navigation · Themes · Spring animations · Notifications
--]]

local NexusLib = {}
NexusLib.__index = NexusLib

-- ════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")
local TextService     = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════
--  THEMES
-- ════════════════════════════════════════════════════════════
NexusLib.Themes = {
    Dark = {
        Accent      = Color3.fromRGB(129, 140, 248),
        Accent2     = Color3.fromRGB(196, 181, 253),
        AccentGlow  = Color3.fromRGB(129, 140, 248),
        AccentDim   = Color3.fromRGB(129, 140, 248),
        Background  = Color3.fromRGB(10,  10,  16),
        Surface1    = Color3.fromRGB(14,  14,  20),
        Surface2    = Color3.fromRGB(18,  18,  28),
        Surface3    = Color3.fromRGB(22,  22,  36),
        Border0     = Color3.fromRGB(255, 255, 255),
        Border1     = Color3.fromRGB(255, 255, 255),
        Border2     = Color3.fromRGB(255, 255, 255),
        Text1       = Color3.fromRGB(238, 236, 255),
        Text2       = Color3.fromRGB(168, 163, 210),
        Text3       = Color3.fromRGB(98,  93,  143),
        Ok          = Color3.fromRGB(74,  222, 128),
        Warn        = Color3.fromRGB(251, 146, 60),
        Err         = Color3.fromRGB(248, 113, 113),
        Inf         = Color3.fromRGB(96,  165, 250),
        PillOff     = Color3.fromRGB(255, 255, 255),
        -- Alpha values (0-1) for surfaces and borders
        Surface1Alpha = 0.97, Surface2Alpha = 0.94, Surface3Alpha = 0.90,
        Border0Alpha  = 0.04, Border1Alpha  = 0.08, Border2Alpha  = 0.15,
        AccentDimAlpha = 0.10, PillOffAlpha = 0.10, AccentGlowAlpha = 0.28,
    },
    Ocean = {
        Accent      = Color3.fromRGB(34,  211, 238),
        Accent2     = Color3.fromRGB(103, 232, 249),
        AccentGlow  = Color3.fromRGB(34,  211, 238),
        AccentDim   = Color3.fromRGB(34,  211, 238),
        Background  = Color3.fromRGB(2,   12,  20),
        Surface1    = Color3.fromRGB(4,   14,  26),
        Surface2    = Color3.fromRGB(6,   20,  36),
        Surface3    = Color3.fromRGB(8,   26,  46),
        Border0     = Color3.fromRGB(34,  211, 238),
        Border1     = Color3.fromRGB(34,  211, 238),
        Border2     = Color3.fromRGB(34,  211, 238),
        Text1       = Color3.fromRGB(218, 244, 255),
        Text2       = Color3.fromRGB(128, 194, 230),
        Text3       = Color3.fromRGB(68,  136, 184),
        Ok          = Color3.fromRGB(74,  222, 128),
        Warn        = Color3.fromRGB(251, 146, 60),
        Err         = Color3.fromRGB(248, 113, 113),
        Inf         = Color3.fromRGB(96,  165, 250),
        PillOff     = Color3.fromRGB(34,  211, 238),
        Surface1Alpha = 0.97, Surface2Alpha = 0.94, Surface3Alpha = 0.92,
        Border0Alpha  = 0.04, Border1Alpha  = 0.09, Border2Alpha  = 0.18,
        AccentDimAlpha = 0.09, PillOffAlpha = 0.10, AccentGlowAlpha = 0.25,
    },
    Crimson = {
        Accent      = Color3.fromRGB(251, 113, 133),
        Accent2     = Color3.fromRGB(253, 164, 175),
        AccentGlow  = Color3.fromRGB(251, 113, 133),
        AccentDim   = Color3.fromRGB(251, 113, 133),
        Background  = Color3.fromRGB(7,   3,   6),
        Surface1    = Color3.fromRGB(15,  3,   7),
        Surface2    = Color3.fromRGB(21,  5,   11),
        Surface3    = Color3.fromRGB(27,  7,   15),
        Border0     = Color3.fromRGB(251, 113, 133),
        Border1     = Color3.fromRGB(251, 113, 133),
        Border2     = Color3.fromRGB(251, 113, 133),
        Text1       = Color3.fromRGB(255, 232, 236),
        Text2       = Color3.fromRGB(213, 150, 168),
        Text3       = Color3.fromRGB(143, 80,  103),
        Ok          = Color3.fromRGB(74,  222, 128),
        Warn        = Color3.fromRGB(251, 146, 60),
        Err         = Color3.fromRGB(248, 113, 113),
        Inf         = Color3.fromRGB(96,  165, 250),
        PillOff     = Color3.fromRGB(251, 113, 133),
        Surface1Alpha = 0.97, Surface2Alpha = 0.94, Surface3Alpha = 0.92,
        Border0Alpha  = 0.04, Border1Alpha  = 0.09, Border2Alpha  = 0.18,
        AccentDimAlpha = 0.09, PillOffAlpha = 0.10, AccentGlowAlpha = 0.28,
    },
    Light = {
        Accent      = Color3.fromRGB(99,  102, 241),
        Accent2     = Color3.fromRGB(129, 140, 248),
        AccentGlow  = Color3.fromRGB(99,  102, 241),
        AccentDim   = Color3.fromRGB(99,  102, 241),
        Background  = Color3.fromRGB(232, 232, 244),
        Surface1    = Color3.fromRGB(252, 252, 255),
        Surface2    = Color3.fromRGB(246, 246, 253),
        Surface3    = Color3.fromRGB(255, 255, 255),
        Border0     = Color3.fromRGB(0,   0,   0),
        Border1     = Color3.fromRGB(0,   0,   0),
        Border2     = Color3.fromRGB(99,  102, 241),
        Text1       = Color3.fromRGB(10,  10,  28),
        Text2       = Color3.fromRGB(55,  53,  108),
        Text3       = Color3.fromRGB(105, 103, 158),
        Ok          = Color3.fromRGB(22,  163, 74),
        Warn        = Color3.fromRGB(217, 119, 6),
        Err         = Color3.fromRGB(220, 38,  38),
        Inf         = Color3.fromRGB(37,  99,  235),
        PillOff     = Color3.fromRGB(0,   0,   0),
        Surface1Alpha = 0.97, Surface2Alpha = 0.95, Surface3Alpha = 0.93,
        Border0Alpha  = 0.04, Border1Alpha  = 0.07, Border2Alpha  = 0.20,
        AccentDimAlpha = 0.09, PillOffAlpha = 0.12, AccentGlowAlpha = 0.20,
    },
}

-- ════════════════════════════════════════════════════════════
--  UTILITIES
-- ════════════════════════════════════════════════════════════
local function Tween(obj, props, duration, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir   = dir   or Enum.EasingDirection.Out
    local ti = TweenInfo.new(duration or 0.2, style, dir)
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

local function TweenSpring(obj, props, duration)
    return Tween(obj, props, duration or 0.35, Enum.EasingStyle.Spring, Enum.EasingDirection.Out)
end

local function New(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function MakeCorner(radius)
    return New("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

local function MakePadding(t, r, b, l)
    return New("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingRight  = UDim.new(0, r or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
    })
end

local function MakeList(padding, spacing)
    return New("UIListLayout", {
        SortOrder    = Enum.SortOrder.LayoutOrder,
        Padding      = UDim.new(0, spacing or 5),
        FillDirection = Enum.FillDirection.Vertical,
    })
end

local function MakeStroke(color, thickness, alpha)
    return New("UIStroke", {
        Color       = color,
        Thickness   = thickness or 1,
        Transparency = 1 - (alpha or 1),
    })
end

local function MakeGradient(rotation, c0, c1, a0, a1)
    local g = New("UIGradient", {
        Rotation = rotation or 0,
    })
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c0),
        ColorSequenceKeypoint.new(1, c1),
    })
    if a0 then
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1 - a0),
            NumberSequenceKeypoint.new(1, 1 - (a1 or a0)),
        })
    end
    return g
end

-- ════════════════════════════════════════════════════════════
--  WINDOW CONSTRUCTOR
-- ════════════════════════════════════════════════════════════
function NexusLib.new(config)
    config = config or {}
    local self = setmetatable({}, NexusLib)

    self.Title     = config.Title     or "NexusLib"
    self.Subtitle  = config.Subtitle  or "v2.3"
    self.Theme     = NexusLib.Themes[config.Theme] or NexusLib.Themes.Dark
    self.ThemeName = config.Theme or "Dark"
    self.Layout    = config.Layout or "Sidebar" -- "Sidebar" | "Top"
    self.ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    self.Visible   = true

    self._tabs        = {}     -- array of tab objects
    self._curTab      = nil
    self._dragging    = false
    self._dragOffset  = Vector2.new()
    self._connections = {}
    self._notifications = {}

    self:_buildGui()
    self:_hookInput()

    return self
end

-- ════════════════════════════════════════════════════════════
--  BUILD GUI ROOT
-- ════════════════════════════════════════════════════════════
function NexusLib:_buildGui()
    local T = self.Theme

    -- ScreenGui
    self.ScreenGui = New("ScreenGui", {
        Name            = "NexusLib",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        DisplayOrder    = 999,
        Parent          = CoreGui,
    })

    -- WINDOW FRAME
    self.Window = New("Frame", {
        Name            = "Window",
        Size            = UDim2.new(0, 640, 0, 460),
        Position        = UDim2.new(0.5, -320, 0.5, -230),
        BackgroundColor3 = T.Surface1,
        BackgroundTransparency = 1 - T.Surface1Alpha,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent          = self.ScreenGui,
    }, {
        MakeCorner(14),
        MakeStroke(T.Border1, 1, T.Border1Alpha),
    })

    -- Window top shimmer line
    New("Frame", {
        Name = "TopShimmer",
        Size = UDim2.new(0.82, 0, 0, 1),
        Position = UDim2.new(0.09, 0, 0, 0),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        Parent = self.Window,
    }, { MakeCorner(1) })

    -- Window outer glow (ImageLabel trick)
    self.GlowFrame = New("ImageLabel", {
        Name = "OuterGlow",
        Size = UDim2.new(1, 80, 1, 80),
        Position = UDim2.new(0, -40, 0, -40),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084", -- radial blur asset
        ImageColor3 = T.AccentGlow,
        ImageTransparency = 1 - T.AccentGlowAlpha,
        ScaleType = Enum.ScaleType.Stretch,
        ZIndex = -1,
        Parent = self.Window,
    })

    -- Rotating accent border (UIStroke animation via gradient hack)
    self.AccentBorder = New("Frame", {
        Name = "AccentBorder",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = self.Window,
    })
    local borderGrad = MakeGradient(0, T.Accent2, T.Accent, 0.55, 0.85)
    borderGrad.Parent = self.AccentBorder
    -- Animate gradient rotation
    local angle = 0
    self._borderConn = RunService.Heartbeat:Connect(function(dt)
        angle = (angle + dt * 25) % 360
        borderGrad.Rotation = angle
    end)
    table.insert(self._connections, self._borderConn)

    self:_buildTitleBar()
    self:_buildBody()
    self:_buildStatusBar()
    self:_buildNotificationLayer()

    -- Entry animation
    self.Window.BackgroundTransparency = 1
    self.Window.Position = UDim2.new(0.5, -320, 0.5, -215)
    TweenSpring(self.Window, {
        BackgroundTransparency = 1 - T.Surface1Alpha,
        Position = UDim2.new(0.5, -320, 0.5, -230),
    }, 0.5)
end

-- ════════════════════════════════════════════════════════════
--  TITLE BAR
-- ════════════════════════════════════════════════════════════
function NexusLib:_buildTitleBar()
    local T = self.Theme

    self.TitleBar = New("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = T.Surface2,
        BackgroundTransparency = 1 - T.Surface2Alpha,
        BorderSizePixel = 0,
        Parent = self.Window,
    })

    -- Accent top line
    New("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = self.TitleBar,
    })

    -- Bottom divider
    New("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border0,
        BackgroundTransparency = 1 - T.Border0Alpha,
        BorderSizePixel = 0,
        Parent = self.TitleBar,
    })

    -- Logo chip
    local logo = New("Frame", {
        Name = "Logo",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 13, 0.5, -12),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        Parent = self.TitleBar,
    }, { MakeCorner(7) })
    New("UIGradient", {
        Color = ColorSequence.new(T.Accent, T.Accent2),
        Rotation = 135,
        Parent = logo,
    })
    New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "N",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        Parent = logo,
    })

    -- Title text
    New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 120, 0, 20),
        Position = UDim2.new(0, 44, 0.5, -10),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = T.Text1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
    })

    -- Version badge
    local verBadge = New("Frame", {
        Name = "Version",
        Size = UDim2.new(0, 44, 0, 18),
        Position = UDim2.new(0, 170, 0.5, -9),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 1 - T.AccentDimAlpha,
        BorderSizePixel = 0,
        Parent = self.TitleBar,
    }, { MakeCorner(5), MakeStroke(T.Border1, 1, T.Border1Alpha) })
    New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = self.Subtitle,
        TextColor3 = T.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Parent = verBadge,
    })

    -- Top-strip tab bar (shown in Top layout)
    self.TopStrip = New("Frame", {
        Name = "TopStrip",
        Size = UDim2.new(0, 0, 0, 30), -- width set dynamically
        Position = UDim2.new(0, 225, 0.5, -15),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = self.Layout == "Top",
        Parent = self.TitleBar,
    }, {
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 2),
        })
    })

    -- Window controls
    local function WinBtn(color, xpos, callback)
        local btn = New("TextButton", {
            Name = "WinBtn",
            Size = UDim2.new(0, 13, 0, 13),
            Position = UDim2.new(1, xpos, 0.5, -6),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Text = "",
            Parent = self.TitleBar,
        }, { MakeCorner(7) })
        btn.MouseButton1Click:Connect(callback)
        btn.MouseEnter:Connect(function()
            Tween(btn, { BackgroundTransparency = 0.2 }, 0.1)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, { BackgroundTransparency = 0 }, 0.1)
        end)
        return btn
    end

    WinBtn(Color3.fromRGB(255, 95,  87),  -14, function() self:_closeWindow() end)
    WinBtn(Color3.fromRGB(254, 188, 46),  -32, function() self:_minimizeWindow() end)

    -- Drag
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self._dragging = true
            self._dragOffset = input.Position - Vector2.new(
                self.Window.AbsolutePosition.X,
                self.Window.AbsolutePosition.Y
            )
        end
    end)
    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self._dragging = false
        end
    end)
    local dragConn = UserInputService.InputChanged:Connect(function(input)
        if self._dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = input.Position - self._dragOffset
            self.Window.Position = UDim2.new(0, pos.X, 0, pos.Y)
        end
    end)
    table.insert(self._connections, dragConn)
end

-- ════════════════════════════════════════════════════════════
--  BODY (Sidebar + Content)
-- ════════════════════════════════════════════════════════════
function NexusLib:_buildBody()
    local T = self.Theme

    self.Body = New("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -78), -- minus titlebar + statusbar
        Position = UDim2.new(0, 0, 0, 52),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = self.Window,
    })

    -- SIDEBAR
    self.Sidebar = New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 46, 1, 0),
        BackgroundColor3 = T.Surface2,
        BackgroundTransparency = 1 - T.Surface2Alpha,
        BorderSizePixel = 0,
        Visible = self.Layout == "Sidebar",
        Parent = self.Body,
    }, {
        New("UIStroke", {
            Color = T.Border0,
            Thickness = 1,
            Transparency = 1 - T.Border0Alpha,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        })
    })

    self.SidebarList = New("Frame", {
        Name = "List",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = self.Sidebar,
    }, {
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        }),
        MakePadding(8, 0, 8, 0),
    })

    -- CONTENT COLUMN
    local contentX = self.Layout == "Sidebar" and 46 or 0
    local contentW = self.Layout == "Sidebar" and -46 or 0
    self.ContentCol = New("Frame", {
        Name = "ContentCol",
        Size = UDim2.new(1, contentW, 1, 0),
        Position = UDim2.new(0, contentX, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = self.Body,
    })

    -- Sub-tab bar area (top of content col)
    self.SubBarContainer = New("Frame", {
        Name = "SubBarContainer",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = T.Surface2,
        BackgroundTransparency = 1 - T.Surface2Alpha,
        BorderSizePixel = 0,
        Parent = self.ContentCol,
    }, {
        New("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = T.Border0,
            BackgroundTransparency = 1 - T.Border0Alpha,
            BorderSizePixel = 0,
        })
    })

    -- Page scroll frame
    self.PageContainer = New("ScrollingFrame", {
        Name = "Pages",
        Size = UDim2.new(1, 0, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.Border2,
        ScrollBarImageTransparency = 1 - T.Border2Alpha,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.ContentCol,
    }, {
        MakeList(nil, 5),
        MakePadding(10, 11, 12, 11),
    })
end

-- ════════════════════════════════════════════════════════════
--  STATUS BAR
-- ════════════════════════════════════════════════════════════
function NexusLib:_buildStatusBar()
    local T = self.Theme

    self.StatusBar = New("Frame", {
        Name = "StatusBar",
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0, 0, 1, -26),
        BackgroundColor3 = T.Surface2,
        BackgroundTransparency = 1 - T.Surface2Alpha,
        BorderSizePixel = 0,
        Parent = self.Window,
    }, {
        New("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.Border0,
            BackgroundTransparency = 1 - T.Border0Alpha,
            BorderSizePixel = 0,
        })
    })

    -- Pulsing dot
    local dot = New("Frame", {
        Name = "Dot",
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 12, 0.5, -3),
        BackgroundColor3 = T.Ok,
        BorderSizePixel = 0,
        Parent = self.StatusBar,
    }, { MakeCorner(3) })

    -- Pulse animation
    local pulseUp = true
    local dotConn = RunService.Heartbeat:Connect(function(dt)
        -- simple lerp pulse
    end)
    -- Simpler tween loop for pulse
    local function pulseDot()
        Tween(dot, { BackgroundTransparency = 0.5 }, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Completed:Wait()
        Tween(dot, { BackgroundTransparency = 0 }, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut):Completed:Wait()
        task.defer(pulseDot)
    end
    task.defer(pulseDot)

    New("TextLabel", {
        Name = "Status",
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text = "Connected · 0ms",
        TextColor3 = T.Text3,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.StatusBar,
    })

    self.StatusLabel = New("TextLabel", {
        Name = "TabLabel",
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 140, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = T.Text3,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = self.StatusBar,
    })

    -- Version tag
    local verTag = New("Frame", {
        Name = "VerTag",
        Size = UDim2.new(0, 54, 0, 16),
        Position = UDim2.new(1, -66, 0.5, -8),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 1 - T.AccentDimAlpha,
        BorderSizePixel = 0,
        Parent = self.StatusBar,
    }, { MakeCorner(5), MakeStroke(T.Border1, 1, T.Border1Alpha) })
    New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = self.Subtitle,
        TextColor3 = T.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Parent = verTag,
    })
end

-- ════════════════════════════════════════════════════════════
--  NOTIFICATION LAYER
-- ════════════════════════════════════════════════════════════
function NexusLib:_buildNotificationLayer()
    self.NotifContainer = New("Frame", {
        Name = "NotifContainer",
        Size = UDim2.new(0, 298, 1, 0),
        Position = UDim2.new(1, -318, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = self.ScreenGui,
    }, {
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, 8),
        }),
        MakePadding(18, 0, 0, 0),
    })
end

-- ════════════════════════════════════════════════════════════
--  ADD TAB
-- ════════════════════════════════════════════════════════════
function NexusLib:AddTab(config)
    config = config or {}
    local T = self.Theme
    local tabId = #self._tabs + 1

    local tab = {
        Name     = config.Name or ("Tab "..tabId),
        Icon     = config.Icon or "☰",
        Id       = tabId,
        _subtabs = {},
        _curSub  = nil,
    }

    -- SIDEBAR BUTTON
    local sbBtn = New("TextButton", {
        Name = "SidebarBtn_"..tabId,
        Size = UDim2.new(0, 32, 0, 32),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = tab.Icon,
        TextColor3 = T.Text3,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        LayoutOrder = tabId,
        Parent = self.SidebarList,
    }, { MakeCorner(9) })

    -- Sidebar active indicator
    local sbIndicator = New("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0, 3, 0, 17),
        Position = UDim2.new(0, -1, 0.5, -8),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = sbBtn,
    }, { MakeCorner(2) })

    -- Tooltip
    local tooltip = New("Frame", {
        Name = "Tooltip",
        Size = UDim2.new(0, 0, 0, 26),
        Position = UDim2.new(1, 10, 0.5, -13),
        BackgroundColor3 = T.Surface3,
        BackgroundTransparency = 1 - T.Surface3Alpha,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
        Parent = sbBtn,
    }, { MakeCorner(7), MakeStroke(T.Border2, 1, T.Border2Alpha) })
    local tooltipLabel = New("TextLabel", {
        Size = UDim2.new(1, 16, 1, 0),
        Position = UDim2.new(0, -8, 0, 0),
        BackgroundTransparency = 1,
        Text = tab.Name,
        TextColor3 = T.Text1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        ZIndex = 51,
        Parent = tooltip,
    })
    -- Resize tooltip to text
    task.defer(function()
        local tw = TextService:GetTextSize(tab.Name, 11, Enum.Font.Gotham, Vector2.new(999, 999))
        tooltip.Size = UDim2.new(0, tw.X + 18, 0, 26)
    end)

    sbBtn.MouseEnter:Connect(function()
        Tween(sbBtn, { BackgroundTransparency = 0.92 }, 0.15)
        tooltip.Visible = true
    end)
    sbBtn.MouseLeave:Connect(function()
        if self._curTab ~= tab then
            Tween(sbBtn, { BackgroundTransparency = 1 }, 0.15)
        end
        tooltip.Visible = false
    end)

    -- TOP STRIP BUTTON
    local tsBtn = New("TextButton", {
        Name = "TopBtn_"..tabId,
        Size = UDim2.new(0, 0, 0, 29),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = tab.Icon.." "..tab.Name,
        TextColor3 = T.Text3,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        LayoutOrder = tabId,
        Parent = self.TopStrip,
    }, { MakeCorner(7), MakePadding(0, 11, 0, 11) })

    local tsUnderline = New("Frame", {
        Name = "Underline",
        Size = UDim2.new(0.6, 0, 0, 2),
        Position = UDim2.new(0.2, 0, 1, -1),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = tsBtn,
    }, { MakeCorner(1) })

    -- SUB-TAB BAR (one per main tab, sits inside SubBarContainer)
    local subBar = New("Frame", {
        Name = "SubBar_"..tabId,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        Parent = self.SubBarContainer,
    }, {
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 3),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
        MakePadding(0, 10, 0, 10),
    })

    tab._sbBtn      = sbBtn
    tab._sbInd      = sbIndicator
    tab._tsBtn      = tsBtn
    tab._tsUnder    = tsUnderline
    tab._subBar     = subBar

    -- Click handlers
    local function selectThisTab()
        self:_selectTab(tab)
    end
    sbBtn.MouseButton1Click:Connect(selectThisTab)
    tsBtn.MouseButton1Click:Connect(selectThisTab)

    table.insert(self._tabs, tab)

    -- Auto-select first tab
    if #self._tabs == 1 then
        self:_selectTab(tab)
    end

    -- Return tab handle with AddSection method
    local tabHandle = {}
    function tabHandle:AddSection(sectionConfig)
        return NexusLib._addSubTab(NexusLib, tab, sectionConfig)
    end
    -- Legacy alias
    function tabHandle:AddSubTab(sectionConfig)
        return tabHandle:AddSection(sectionConfig)
    end
    return tabHandle
end

-- ════════════════════════════════════════════════════════════
--  SELECT MAIN TAB
-- ════════════════════════════════════════════════════════════
function NexusLib:_selectTab(tab)
    local T = self.Theme

    -- Deactivate old tab
    if self._curTab and self._curTab ~= tab then
        local old = self._curTab
        -- Sidebar btn
        Tween(old._sbBtn, { BackgroundTransparency = 1, TextColor3 = T.Text3 }, 0.18)
        Tween(old._sbInd, { BackgroundTransparency = 1 }, 0.18)
        -- Top btn
        Tween(old._tsBtn, { TextColor3 = T.Text3, BackgroundTransparency = 1 }, 0.18)
        Tween(old._tsUnder, { BackgroundTransparency = 1 }, 0.18)
        -- Hide sub-bar
        old._subBar.Visible = false
        -- Hide pages
        if old._curSub then
            if old._curSub._page then
                Tween(old._curSub._page, { BackgroundTransparency = 1 }, 0.15)
                task.delay(0.15, function()
                    if old._curSub and old._curSub._page then
                        old._curSub._page.Visible = false
                    end
                end)
            end
        end
    end

    self._curTab = tab

    -- Activate sidebar btn
    Tween(tab._sbBtn, { BackgroundTransparency = 0.88, TextColor3 = T.Accent }, 0.18)
    Tween(tab._sbInd, { BackgroundTransparency = 0 }, 0.18)
    -- Activate top btn
    Tween(tab._tsBtn, { TextColor3 = T.Text1, BackgroundTransparency = 0.88 }, 0.18)
    Tween(tab._tsUnder, { BackgroundTransparency = 0 }, 0.18)
    -- Show sub-bar
    tab._subBar.Visible = true

    -- Show current sub-tab page
    if tab._curSub then
        self:_selectSubTab(tab, tab._curSub)
    elseif #tab._subtabs > 0 then
        self:_selectSubTab(tab, tab._subtabs[1])
    end

    -- Update status bar
    self:_updateStatus()
end

-- ════════════════════════════════════════════════════════════
--  ADD SUB-TAB
-- ════════════════════════════════════════════════════════════
function NexusLib:_addSubTab(tab, config)
    config = config or {}
    local T = self.Theme
    local subId = #tab._subtabs + 1

    local subtab = {
        Name  = config.Name or ("Section "..subId),
        Id    = subId,
        _page = nil,
        _btn  = nil,
    }

    -- Sub-tab button
    local btn = New("TextButton", {
        Name = "SubBtn_"..subId,
        Size = UDim2.new(0, 0, 0, 26),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = subtab.Name,
        TextColor3 = T.Text3,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        LayoutOrder = subId,
        Parent = tab._subBar,
    }, { MakeCorner(6), MakePadding(0, 11, 0, 11) })

    -- Underline dot
    local dot = New("Frame", {
        Name = "Dot",
        Size = UDim2.new(0, 14, 0, 2),
        Position = UDim2.new(0.5, -7, 1, -3),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = btn,
    }, { MakeCorner(1) })

    -- Page (one ScrollingFrame per sub-tab, stacked in PageContainer)
    local page = New("Frame", {
        Name = "Page_"..tab.Id.."_"..subId,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        Parent = self.PageContainer,
    }, { MakeList(nil, 5) })

    subtab._page  = page
    subtab._btn   = btn
    subtab._dot   = dot

    btn.MouseEnter:Connect(function()
        if tab._curSub ~= subtab then
            Tween(btn, { BackgroundTransparency = 0.92, TextColor3 = T.Text2 }, 0.14)
        end
    end)
    btn.MouseLeave:Connect(function()
        if tab._curSub ~= subtab then
            Tween(btn, { BackgroundTransparency = 1, TextColor3 = T.Text3 }, 0.14)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        self:_selectSubTab(tab, subtab)
    end)

    table.insert(tab._subtabs, subtab)

    -- Auto-select first subtab
    if subId == 1 and self._curTab == tab then
        self:_selectSubTab(tab, subtab)
    end

    -- Return element builder
    local builder = {}
    local mt = {__index = builder}

    function builder:AddToggle(cfg)       return NexusLib._addToggle(NexusLib, page, cfg) end
    function builder:AddButton(cfg)       return NexusLib._addButton(NexusLib, page, cfg) end
    function builder:AddSlider(cfg)       return NexusLib._addSlider(NexusLib, page, cfg) end
    function builder:AddDropdown(cfg)     return NexusLib._addDropdown(NexusLib, page, cfg) end
    function builder:AddKeybind(cfg)      return NexusLib._addKeybind(NexusLib, page, cfg) end
    function builder:AddTextbox(cfg)      return NexusLib._addTextbox(NexusLib, page, cfg) end
    function builder:AddColorPicker(cfg)  return NexusLib._addColorPicker(NexusLib, page, cfg) end
    function builder:AddLabel(cfg)        return NexusLib._addLabel(NexusLib, page, cfg) end
    function builder:AddSeparator()       return NexusLib._addSeparator(NexusLib, page) end
    function builder:AddRow(cfg)          return NexusLib._addRow(NexusLib, page, cfg) end
    function builder:AddParagraph(cfg)    return NexusLib._addParagraph(NexusLib, page, cfg) end

    return setmetatable({}, mt)
end

-- ════════════════════════════════════════════════════════════
--  SELECT SUB-TAB
-- ════════════════════════════════════════════════════════════
function NexusLib:_selectSubTab(tab, subtab)
    local T = self.Theme

    -- Hide old sub-tab page
    if tab._curSub and tab._curSub ~= subtab then
        local old = tab._curSub
        if old._btn then
            Tween(old._btn, { BackgroundTransparency = 1, TextColor3 = T.Text3 }, 0.15)
            Tween(old._dot, { BackgroundTransparency = 1 }, 0.15)
        end
        if old._page then
            old._page.Visible = false
        end
    end

    tab._curSub = subtab

    -- Activate button
    Tween(subtab._btn, { BackgroundTransparency = 0.88, TextColor3 = T.Text1 }, 0.15)
    -- Update font weight (simulate bold)
    subtab._btn.Font = Enum.Font.GothamBold
    Tween(subtab._dot, { BackgroundTransparency = 0 }, 0.15)

    -- Show page
    if subtab._page then
        subtab._page.Visible = true
    end

    self:_updateStatus()
end

function NexusLib:_updateStatus()
    if not self.StatusLabel then return end
    local tabName = self._curTab and self._curTab.Name or ""
    local subName = (self._curTab and self._curTab._curSub) and self._curTab._curSub.Name or ""
    self.StatusLabel.Text = tabName .. (subName ~= "" and (" › "..subName) or "")
end

-- ════════════════════════════════════════════════════════════
--  CARD BUILDER
-- ════════════════════════════════════════════════════════════
function NexusLib:_makeCard(parent, height, autoSize)
    local T = self.Theme
    local card = New("Frame", {
        Name = "Card",
        Size = UDim2.new(1, 0, 0, height or 46),
        AutomaticSize = autoSize and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
        BackgroundColor3 = T.Surface3,
        BackgroundTransparency = 1 - T.Surface3Alpha,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Parent = parent,
    }, {
        MakeCorner(11),
        MakeStroke(T.Border0, 1, T.Border0Alpha),
    })

    -- Hover effect
    card.MouseEnter:Connect(function()
        Tween(card, { BackgroundTransparency = 1 - T.Surface3Alpha * 1.15 }, 0.12)
        -- Stroke
        local stroke = card:FindFirstChildOfClass("UIStroke")
        if stroke then Tween(stroke, { Transparency = 1 - T.Border2Alpha }, 0.12) end
    end)
    card.MouseLeave:Connect(function()
        Tween(card, { BackgroundTransparency = 1 - T.Surface3Alpha }, 0.12)
        local stroke = card:FindFirstChildOfClass("UIStroke")
        if stroke then Tween(stroke, { Transparency = 1 - T.Border0Alpha }, 0.12) end
    end)

    return card
end

function NexusLib:_flashCard(card)
    local stroke = card:FindFirstChildOfClass("UIStroke")
    if stroke then
        local T = self.Theme
        Tween(stroke, { Color = T.Accent, Transparency = 0.2 }, 0.05)
        task.delay(0.05, function()
            Tween(stroke, { Color = T.Border0, Transparency = 1 - T.Border0Alpha }, 0.28)
        end)
    end
end

-- ════════════════════════════════════════════════════════════
--  TOGGLE
-- ════════════════════════════════════════════════════════════
function NexusLib:_addToggle(parent, config)
    config = config or {}
    local T = self.Theme
    local height = config.Description and 46 or 34

    local card = self:_makeCard(parent, height)

    -- Icon
    if config.Icon then
        local ico = New("Frame", {
            Size = UDim2.new(0, 26, 0, 26),
            Position = UDim2.new(0, 13, 0.5, -13),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1 - T.AccentDimAlpha,
            BorderSizePixel = 0,
            Parent = card,
        }, { MakeCorner(8), MakeStroke(T.Border1, 1, T.Border1Alpha) })
        New("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = config.Icon,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextColor3 = T.Text1,
            Parent = ico,
        })
    end

    local textX = config.Icon and 49 or 13

    -- Label
    New("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -(textX + 58), 0, 16),
        Position = UDim2.new(0, textX, 0, config.Description and 11 or height/2 - 8),
        BackgroundTransparency = 1,
        Text = config.Name or "Toggle",
        TextColor3 = T.Text1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    if config.Description then
        New("TextLabel", {
            Name = "Desc",
            Size = UDim2.new(1, -(textX + 58), 0, 13),
            Position = UDim2.new(0, textX, 0, 28),
            BackgroundTransparency = 1,
            Text = config.Description,
            TextColor3 = T.Text3,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = card,
        })
    end

    -- PILL
    local pillBg = New("Frame", {
        Name = "Pill",
        Size = UDim2.new(0, 38, 0, 21),
        Position = UDim2.new(1, -51, 0.5, -10),
        BackgroundColor3 = T.PillOff,
        BackgroundTransparency = 1 - T.PillOffAlpha,
        BorderSizePixel = 0,
        Parent = card,
    }, { MakeCorner(11), MakeStroke(T.Border1, 1, T.Border1Alpha) })

    local knob = New("Frame", {
        Name = "Knob",
        Size = UDim2.new(0, 13, 0, 13),
        Position = UDim2.new(0, 3, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(180, 175, 210),
        BorderSizePixel = 0,
        Parent = pillBg,
    }, { MakeCorner(7) })

    -- State
    local state = config.Default or false
    local toggling = false

    local function setState(val, silent)
        if toggling then return end
        toggling = true
        state = val

        if val then
            TweenSpring(pillBg, { BackgroundColor3 = T.Accent, BackgroundTransparency = 0 }, 0.28)
            TweenSpring(knob, { Position = UDim2.new(0, 20, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255,255,255) }, 0.28)
            local stroke = pillBg:FindFirstChildOfClass("UIStroke")
            if stroke then Tween(stroke, { Color = T.Accent }, 0.2) end
        else
            TweenSpring(pillBg, { BackgroundColor3 = T.PillOff, BackgroundTransparency = 1 - T.PillOffAlpha }, 0.28)
            TweenSpring(knob, { Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Color3.fromRGB(180, 175, 210) }, 0.28)
            local stroke = pillBg:FindFirstChildOfClass("UIStroke")
            if stroke then Tween(stroke, { Color = T.Border1 }, 0.2) end
        end

        task.delay(0.3, function() toggling = false end)

        if not silent and config.Callback then
            config.Callback(state)
        end
    end

    -- Set initial state
    if state then setState(true, true) end

    -- Click anywhere on card
    local btn = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = card,
    })
    btn.MouseButton1Click:Connect(function()
        setState(not state)
        self:_flashCard(card)
    end)

    -- Handle object
    local handle = {}
    function handle:Set(val) setState(val) end
    function handle:Get() return state end
    return handle
end

-- ════════════════════════════════════════════════════════════
--  BUTTON
-- ════════════════════════════════════════════════════════════
function NexusLib:_addButton(parent, config)
    config = config or {}
    local T = self.Theme
    local height = config.Description and 46 or 34

    local card = self:_makeCard(parent, height)

    if config.Icon then
        local ico = New("Frame", {
            Size = UDim2.new(0, 26, 0, 26),
            Position = UDim2.new(0, 13, 0.5, -13),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1 - T.AccentDimAlpha,
            BorderSizePixel = 0,
            Parent = card,
        }, { MakeCorner(8), MakeStroke(T.Border1, 1, T.Border1Alpha) })
        New("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = config.Icon,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextColor3 = T.Text1,
            Parent = ico,
        })
    end

    local textX = config.Icon and 49 or 13

    New("TextLabel", {
        Size = UDim2.new(1, -(textX + 36), 0, 16),
        Position = UDim2.new(0, textX, 0, config.Description and 11 or height/2 - 8),
        BackgroundTransparency = 1,
        Text = config.Name or "Button",
        TextColor3 = T.Text1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    if config.Description then
        New("TextLabel", {
            Size = UDim2.new(1, -(textX + 36), 0, 13),
            Position = UDim2.new(0, textX, 0, 28),
            BackgroundTransparency = 1,
            Text = config.Description,
            TextColor3 = T.Text3,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = card,
        })
    end

    -- Arrow
    local arrow = New("Frame", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(1, -35, 0.5, -11),
        BackgroundColor3 = T.Border0,
        BackgroundTransparency = 1 - T.Border0Alpha,
        BorderSizePixel = 0,
        Parent = card,
    }, { MakeCorner(6) })
    New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "›",
        TextColor3 = T.Text3,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Parent = arrow,
    })

    local btn = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = card,
    })

    btn.MouseEnter:Connect(function()
        Tween(arrow, { BackgroundColor3 = T.Accent, BackgroundTransparency = 0 }, 0.15)
        arrow:FindFirstChildOfClass("TextLabel") and Tween(arrow:FindFirstChildOfClass("TextLabel"), { TextColor3 = Color3.fromRGB(255,255,255) }, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tween(arrow, { BackgroundColor3 = T.Border0, BackgroundTransparency = 1 - T.Border0Alpha }, 0.15)
        arrow:FindFirstChildOfClass("TextLabel") and Tween(arrow:FindFirstChildOfClass("TextLabel"), { TextColor3 = T.Text3 }, 0.15)
    end)
    btn.MouseButton1Click:Connect(function()
        self:_flashCard(card)
        if config.Callback then config.Callback() end
    end)
end

-- ════════════════════════════════════════════════════════════
--  SLIDER
-- ════════════════════════════════════════════════════════════
function NexusLib:_addSlider(parent, config)
    config = config or {}
    local T = self.Theme
    local min   = config.Min     or 0
    local max   = config.Max     or 100
    local step  = config.Step    or 1
    local val   = config.Default or min
    local dp    = step < 1 and 1 or 0

    local card = self:_makeCard(parent, 58)

    -- Label row
    New("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 16),
        Position = UDim2.new(0, 13, 0, 11),
        BackgroundTransparency = 1,
        Text = config.Name or "Slider",
        TextColor3 = T.Text1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    -- Value badge
    local valBadge = New("Frame", {
        Size = UDim2.new(0, 48, 0, 18),
        Position = UDim2.new(1, -61, 0, 8),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 1 - T.AccentDimAlpha,
        BorderSizePixel = 0,
        Parent = card,
    }, { MakeCorner(5), MakeStroke(T.Border1, 1, T.Border1Alpha) })
    local valLabel = New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = tostring(val),
        TextColor3 = T.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        Parent = valBadge,
    })

    -- Track
    local track = New("Frame", {
        Name = "Track",
        Size = UDim2.new(1, -26, 0, 4),
        Position = UDim2.new(0, 13, 0, 36),
        BackgroundColor3 = T.Border1,
        BackgroundTransparency = 1 - T.Border1Alpha,
        BorderSizePixel = 0,
        Parent = card,
    }, { MakeCorner(2) })

    local fill = New("Frame", {
        Name = "Fill",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        Parent = track,
    }, { MakeCorner(2) })
    New("UIGradient", {
        Color = ColorSequence.new(T.Accent, T.Accent2),
        Rotation = 0,
        Parent = fill,
    })

    local thumb = New("Frame", {
        Name = "Thumb",
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = T.Text1,
        BorderSizePixel = 0,
        Parent = track,
    }, {
        MakeCorner(7),
        MakeStroke(T.Accent, 2.5, 1),
    })

    local function snapVal(v)
        return math.round(v / step) * step
    end
    local function clamp(v) return math.max(min, math.min(max, v)) end
    local function v2p(v) return (v - min) / (max - min) end

    local function setVal(v, silent)
        v = clamp(snapVal(v))
        val = v
        local pct = v2p(v)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        thumb.Position = UDim2.new(pct, 0, 0.5, 0)
        valLabel.Text = string.format(dp > 0 and "%.1f" or "%d", v)
        if not silent and config.Callback then config.Callback(v) end
    end

    setVal(val, true)

    -- Dragging
    local dragging = false
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local rel = input.Position.X - track.AbsolutePosition.X
            setVal(min + (max - min) * math.clamp(rel / track.AbsoluteSize.X, 0, 1))
        end
    end)
    local sliderConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = input.Position.X - track.AbsolutePosition.X
            setVal(min + (max - min) * math.clamp(rel / track.AbsoluteSize.X, 0, 1))
        end
    end)
    local sliderEndConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    table.insert(self._connections, sliderConn)
    table.insert(self._connections, sliderEndConn)

    local handle = {}
    function handle:Set(v) setVal(v) end
    function handle:Get() return val end
    return handle
end

-- ════════════════════════════════════════════════════════════
--  DROPDOWN
-- ════════════════════════════════════════════════════════════
function NexusLib:_addDropdown(parent, config)
    config = config or {}
    local T  = self.Theme
    local opts = config.Options or {}
    local cur  = config.Default or (opts[1] or "Select...")

    local card = self:_makeCard(parent, nil, true)

    -- Header row
    local header = New("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundTransparency = 1,
        Parent = card,
    })

    if config.Name then
        New("TextLabel", {
            Size = UDim2.new(1, -26, 0, 12),
            Position = UDim2.new(0, 13, 0, 8),
            BackgroundTransparency = 1,
            Text = string.upper(config.Name),
            TextColor3 = T.Text3,
            Font = Enum.Font.Gotham,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            LetterSpacing = 2,
            Parent = header,
        })
    end

    -- Trigger
    local trigger = New("Frame", {
        Size = UDim2.new(1, -26, 0, 30),
        Position = UDim2.new(0, 13, 0, config.Name and 24 or 13),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
        Parent = header,
    }, {
        MakeCorner(8),
        MakeStroke(T.Border1, 1, T.Border1Alpha),
    })

    local curLabel = New("TextLabel", {
        Size = UDim2.new(1, -28, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = cur,
        TextColor3 = T.Text1,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = trigger,
    })

    local caretLabel = New("TextLabel", {
        Size = UDim2.new(0, 18, 1, 0),
        Position = UDim2.new(1, -20, 0, 0),
        BackgroundTransparency = 1,
        Text = "▾",
        TextColor3 = T.Text3,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        Parent = trigger,
    })

    -- Dropdown panel (inside card, slides open)
    local panel = New("Frame", {
        Size = UDim2.new(1, -26, 0, 0),
        Position = UDim2.new(0, 13, 0, config.Name and 58 or 47),
        BackgroundColor3 = T.Surface1,
        BackgroundTransparency = 1 - T.Surface1Alpha,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        Parent = card,
    }, {
        MakeCorner(8),
        MakeStroke(T.Accent, 1, 1),
    })

    local panelList = New("Frame", {
        Size = UDim2.new(1, 0, 0, #opts * 30),
        BackgroundTransparency = 1,
        Parent = panel,
    }, { MakeList(nil, 0) })

    -- Populate options
    local optBtns = {}
    for i, opt in ipairs(opts) do
        local isSel = opt == cur
        local optBtn = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = isSel and (1 - T.AccentDimAlpha) or 1,
            BorderSizePixel = 0,
            Text = (isSel and "▸  " or "    ") .. opt,
            TextColor3 = isSel and T.Accent or T.Text2,
            Font = isSel and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = i,
            Parent = panelList,
        }, { MakePadding(0, 0, 0, 11) })

        if i < #opts then
            New("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = T.Border0,
                BackgroundTransparency = 1 - T.Border0Alpha,
                BorderSizePixel = 0,
                Parent = optBtn,
            })
        end

        optBtn.MouseEnter:Connect(function()
            if opt ~= cur then
                Tween(optBtn, { BackgroundTransparency = 1 - T.AccentDimAlpha, TextColor3 = T.Text1 }, 0.1)
            end
        end)
        optBtn.MouseLeave:Connect(function()
            if opt ~= cur then
                Tween(optBtn, { BackgroundTransparency = 1, TextColor3 = T.Text2 }, 0.1)
            end
        end)

        optBtns[i] = optBtn
    end

    -- Open/close logic
    local isOpen = false
    local panelHeight = #opts * 30

    local function closePanel()
        isOpen = false
        Tween(caretLabel, { Rotation = 0 }, 0.2)
        Tween(trigger:FindFirstChildOfClass("UIStroke"), { Transparency = 1 - T.Border1Alpha }, 0.15)
        Tween(panel, { Size = UDim2.new(1, -26, 0, 0) }, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.2, function() panel.Visible = false end)
    end

    local function openPanel()
        isOpen = true
        panel.Visible = true
        Tween(caretLabel, { Rotation = 180 }, 0.2)
        local stroke = trigger:FindFirstChildOfClass("UIStroke")
        if stroke then Tween(stroke, { Color = T.Accent, Transparency = 1 - T.Border2Alpha }, 0.15) end
        Tween(panel, { Size = UDim2.new(1, -26, 0, panelHeight) }, 0.22, Enum.EasingStyle.Quad)
    end

    -- Select option
    local function selectOpt(opt)
        for i, ob in ipairs(optBtns) do
            local isSel = opts[i] == opt
            Tween(ob, {
                BackgroundTransparency = isSel and (1 - T.AccentDimAlpha) or 1,
                TextColor3 = isSel and T.Accent or T.Text2,
            }, 0.12)
            ob.Font = isSel and Enum.Font.GothamBold or Enum.Font.Gotham
            ob.Text = (isSel and "▸  " or "    ") .. opts[i]
        end
        cur = opt
        curLabel.Text = opt
        closePanel()
        if config.Callback then config.Callback(opt) end
    end

    for i, ob in ipairs(optBtns) do
        ob.MouseButton1Click:Connect(function()
            selectOpt(opts[i])
        end)
    end

    local trigBtn = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = trigger,
    })
    trigBtn.MouseButton1Click:Connect(function()
        if isOpen then closePanel() else openPanel() end
    end)

    local handle = {}
    function handle:Set(opt) selectOpt(opt) end
    function handle:Get() return cur end
    function handle:Refresh(newOpts)
        -- rebuild options if needed
    end
    return handle
end

-- ════════════════════════════════════════════════════════════
--  KEYBIND
-- ════════════════════════════════════════════════════════════
function NexusLib:_addKeybind(parent, config)
    config = config or {}
    local T   = self.Theme
    local key = config.Default or Enum.KeyCode.E
    local listening = false

    local card = self:_makeCard(parent, 34)

    New("TextLabel", {
        Size = UDim2.new(1, -90, 1, 0),
        Position = UDim2.new(0, 13, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Keybind",
        TextColor3 = T.Text1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    local badge = New("Frame", {
        Size = UDim2.new(0, 66, 0, 22),
        Position = UDim2.new(1, -79, 0.5, -11),
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 1 - T.AccentDimAlpha,
        BorderSizePixel = 0,
        Parent = card,
    }, { MakeCorner(6), MakeStroke(T.Border2, 1, T.Border2Alpha) })

    local badgeLabel = New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = key.Name,
        TextColor3 = T.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        Parent = badge,
    })

    local badgeBtn = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = badge,
    })

    badgeBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        badgeLabel.Text = "..."
        Tween(badge, { BackgroundColor3 = T.Warn }, 0.15)
        Tween(badgeLabel, { TextColor3 = T.Warn }, 0.15)

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                badgeLabel.Text = key.Name
                Tween(badge, { BackgroundColor3 = T.Accent }, 0.15)
                Tween(badgeLabel, { TextColor3 = T.Accent }, 0.15)
                listening = false
                conn:Disconnect()
                if config.Callback then config.Callback(key) end
            end
        end)
    end)

    badgeBtn.MouseEnter:Connect(function()
        local stroke = badge:FindFirstChildOfClass("UIStroke")
        if stroke then Tween(stroke, { Color = T.Accent, Transparency = 0 }, 0.15) end
    end)
    badgeBtn.MouseLeave:Connect(function()
        local stroke = badge:FindFirstChildOfClass("UIStroke")
        if stroke then Tween(stroke, { Color = T.Border2, Transparency = 1 - T.Border2Alpha }, 0.15) end
    end)

    local handle = {}
    function handle:Get() return key end
    function handle:Set(k) key = k; badgeLabel.Text = k.Name end
    return handle
end

-- ════════════════════════════════════════════════════════════
--  TEXTBOX
-- ════════════════════════════════════════════════════════════
function NexusLib:_addTextbox(parent, config)
    config = config or {}
    local T = self.Theme

    local card = self:_makeCard(parent, nil, true)

    local inner = New("Frame", {
        Size = UDim2.new(1, 0, 0, config.Name and 58 or 44),
        BackgroundTransparency = 1,
        Parent = card,
    })

    if config.Name then
        New("TextLabel", {
            Size = UDim2.new(1, -26, 0, 12),
            Position = UDim2.new(0, 13, 0, 8),
            BackgroundTransparency = 1,
            Text = string.upper(config.Name),
            TextColor3 = T.Text3,
            Font = Enum.Font.Gotham,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = inner,
        })
    end

    local wrap = New("Frame", {
        Size = UDim2.new(1, -26, 0, 30),
        Position = UDim2.new(0, 13, 0, config.Name and 24 or 7),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
        Parent = inner,
    }, {
        MakeCorner(8),
        MakeStroke(T.Border1, 1, T.Border1Alpha),
    })

    if config.Prefix then
        New("TextLabel", {
            Size = UDim2.new(0, 28, 1, 0),
            BackgroundTransparency = 1,
            Text = config.Prefix,
            TextColor3 = T.Text3,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            Parent = wrap,
        })
    end

    local xOffset = config.Prefix and 28 or 10
    local tb = New("TextBox", {
        Size = UDim2.new(1, -(xOffset + 10), 1, 0),
        Position = UDim2.new(0, xOffset, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Default or "",
        PlaceholderText = config.Placeholder or "...",
        TextColor3 = T.Text1,
        PlaceholderColor3 = T.Text3,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = config.ClearOnFocus or false,
        Parent = wrap,
    })

    local stroke = wrap:FindFirstChildOfClass("UIStroke")
    tb.Focused:Connect(function()
        if stroke then Tween(stroke, { Color = T.Accent, Transparency = 1 - T.Border2Alpha }, 0.2) end
    end)
    tb.FocusLost:Connect(function(enter)
        if stroke then Tween(stroke, { Color = T.Border1, Transparency = 1 - T.Border1Alpha }, 0.2) end
        if config.Callback then config.Callback(tb.Text, enter) end
    end)

    local handle = {}
    function handle:Get() return tb.Text end
    function handle:Set(v) tb.Text = v end
    return handle
end

-- ════════════════════════════════════════════════════════════
--  COLOR PICKER
-- ════════════════════════════════════════════════════════════
function NexusLib:_addColorPicker(parent, config)
    config = config or {}
    local T   = self.Theme
    local col = config.Default or Color3.fromRGB(129, 140, 248)
    local h, s, v = Color3.toHSV(col)

    local card = self:_makeCard(parent, nil, true)

    -- Header row
    local headerRow = New("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = card,
    })

    if config.Icon then
        local ico = New("Frame", {
            Size = UDim2.new(0, 26, 0, 26),
            Position = UDim2.new(0, 13, 0.5, -13),
            BackgroundColor3 = col,
            BackgroundTransparency = 0.85,
            BorderSizePixel = 0,
            Parent = headerRow,
        }, { MakeCorner(8) })
        New("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = config.Icon or "●",
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextColor3 = T.Text1,
            Parent = ico,
        })
    end

    local textX = config.Icon and 49 or 13
    New("TextLabel", {
        Size = UDim2.new(1, -(textX + 60), 1, 0),
        Position = UDim2.new(0, textX, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Color",
        TextColor3 = T.Text1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = headerRow,
    })

    local swatch = New("Frame", {
        Size = UDim2.new(0, 40, 0, 18),
        Position = UDim2.new(1, -53, 0.5, -9),
        BackgroundColor3 = col,
        BorderSizePixel = 0,
        Parent = headerRow,
    }, { MakeCorner(5), MakeStroke(T.Border1, 1, T.Border1Alpha) })

    -- Toggle expand
    local expandBtn = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = headerRow,
    })

    -- Expand body
    local body = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false,
        Parent = card,
    })

    local bodyInner = New("Frame", {
        Size = UDim2.new(1, 0, 0, 78),
        BackgroundTransparency = 1,
        Parent = body,
    })

    -- Divider
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.Border0,
        BackgroundTransparency = 1 - T.Border0Alpha,
        BorderSizePixel = 0,
        Parent = bodyInner,
    })

    local function makeHSVRow(label, yPos, gradStart, gradEnd, gradMid)
        local row = New("Frame", {
            Size = UDim2.new(1, -26, 0, 5),
            Position = UDim2.new(0, 13, 0, yPos),
            BackgroundTransparency = 1,
            Parent = bodyInner,
        })
        New("TextLabel", {
            Size = UDim2.new(0, 10, 0, 14),
            Position = UDim2.new(0, 0, 0.5, -7),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = T.Text3,
            Font = Enum.Font.GothamBold,
            TextSize = 8,
            Parent = row,
        })
        local trackWrap = New("Frame", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 16, 0, 0),
            BackgroundColor3 = T.Border1,
            BackgroundTransparency = 1 - T.Border1Alpha,
            BorderSizePixel = 0,
            Parent = row,
        }, { MakeCorner(3) })
        if gradStart then
            New("UIGradient", {
                Color = ColorSequence.new(gradStart, gradEnd or gradStart),
                Rotation = 0,
                Parent = trackWrap,
            })
        end
        local knob = New("Frame", {
            Size = UDim2.new(0, 11, 0, 11),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = trackWrap,
        }, { MakeCorner(6), MakeStroke(Color3.fromRGB(255,255,255), 1.5, 0.4) })
        return trackWrap, knob
    end

    local hTrack, hKnob = makeHSVRow("H", 10,
        Color3.fromRGB(255,0,0),   -- fake rainbow below
        Color3.fromRGB(255,0,0))
    -- Rainbow for hue
    hTrack:FindFirstChildOfClass("UIGradient"):Destroy()
    New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,0,0)),
        }),
        Parent = hTrack,
    })

    local sTrack, sKnob = makeHSVRow("S", 32,
        Color3.fromRGB(255,255,255), Color3.fromHSV(h,1,v))
    local vTrack, vKnob = makeHSVRow("V", 54,
        Color3.fromRGB(0,0,0), Color3.fromHSV(h,s,1))

    local function updateColor(silent)
        local newCol = Color3.fromHSV(h, s, v)
        swatch.BackgroundColor3 = newCol
        -- Update gradients
        local sg = sTrack:FindFirstChildOfClass("UIGradient")
        if sg then sg.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromHSV(h,1,v)) end
        local vg = vTrack:FindFirstChildOfClass("UIGradient")
        if vg then vg.Color = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromHSV(h,s,1)) end
        hKnob.Position = UDim2.new(h, 0, 0.5, 0)
        sKnob.Position = UDim2.new(s, 0, 0.5, 0)
        vKnob.Position = UDim2.new(v, 0, 0.5, 0)
        if not silent and config.Callback then config.Callback(newCol) end
    end
    updateColor(true)

    local function makeSliderDrag(track, knob, onSet)
        local function drag(input)
            local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            onSet(math.clamp(rel, 0, 1))
            updateColor()
        end
        local dragging = false
        knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true end end)
        track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true; drag(i) end end)
        local c1 = UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then drag(i) end end)
        local c2 = UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
        table.insert(self._connections, c1)
        table.insert(self._connections, c2)
    end

    makeSliderDrag(hTrack, hKnob, function(val) h=val end)
    makeSliderDrag(sTrack, sKnob, function(val) s=val end)
    makeSliderDrag(vTrack, vKnob, function(val) v=val end)

    -- Expand/collapse
    local expanded = false
    expandBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            body.Visible = true
            Tween(body, { Size = UDim2.new(1, 0, 0, 80) }, 0.22, Enum.EasingStyle.Quad)
        else
            Tween(body, { Size = UDim2.new(1, 0, 0, 0) }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.delay(0.18, function() body.Visible = false end)
        end
    end)

    local handle = {}
    function handle:Set(c)
        h, s, v = Color3.toHSV(c)
        updateColor(true)
    end
    function handle:Get()
        return Color3.fromHSV(h, s, v)
    end
    return handle
end

-- ════════════════════════════════════════════════════════════
--  LABEL
-- ════════════════════════════════════════════════════════════
function NexusLib:_addLabel(parent, config)
    config = config or {}
    local T = self.Theme
    New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = config.Text or "",
        TextColor3 = T.Text3,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = parent,
    })
end

-- ════════════════════════════════════════════════════════════
--  SEPARATOR
-- ════════════════════════════════════════════════════════════
function NexusLib:_addSeparator(parent)
    local T = self.Theme
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.Border1,
        BackgroundTransparency = 1 - T.Border1Alpha * 0.6,
        BorderSizePixel = 0,
        Parent = parent,
    })
end

-- ════════════════════════════════════════════════════════════
--  PARAGRAPH
-- ════════════════════════════════════════════════════════════
function NexusLib:_addParagraph(parent, config)
    config = config or {}
    local T = self.Theme
    local card = self:_makeCard(parent, nil, true)
    local inner = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = card,
    }, {
        MakeList(nil, 5),
        MakePadding(12, 13, 12, 13),
    })
    if config.Title then
        New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text = config.Title,
            TextColor3 = T.Text1,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = inner,
        })
    end
    if config.Text then
        New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = config.Text,
            TextColor3 = T.Text2,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            LineHeight = 1.5,
            Parent = inner,
        })
    end
end

-- ════════════════════════════════════════════════════════════
--  ROW (2 elements side by side)
-- ════════════════════════════════════════════════════════════
function NexusLib:_addRow(parent, config)
    config = config or {}
    local T = self.Theme
    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, config.Height or 34),
        BackgroundTransparency = 1,
        Parent = parent,
    }, {
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5),
        })
    })
    local rowHandle = {}
    function rowHandle:AddButton(cfg)
        cfg = cfg or {}
        local card = New("Frame", {
            Size = UDim2.new(0.5, -2, 1, 0),
            BackgroundColor3 = T.Surface3,
            BackgroundTransparency = 1 - T.Surface3Alpha,
            BorderSizePixel = 0,
            LayoutOrder = #row:GetChildren(),
            Parent = row,
        }, { MakeCorner(11), MakeStroke(T.Border0, 1, T.Border0Alpha) })
        local btn = New("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = cfg.Name or "Button",
            TextColor3 = cfg.Color or T.Text1,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            Parent = card,
        })
        btn.MouseButton1Click:Connect(function()
            NexusLib._flashCard(NexusLib, card)
            if cfg.Callback then cfg.Callback() end
        end)
    end
    return rowHandle
end

-- ════════════════════════════════════════════════════════════
--  NOTIFICATION
-- ════════════════════════════════════════════════════════════
function NexusLib:Notify(config)
    config = config or {}
    local T    = self.Theme
    local dur  = config.Duration or 4

    local typeColors = {
        Success = T.Ok,
        Warning = T.Warn,
        Error   = T.Err,
        Info    = T.Inf,
    }
    local typeIcons = {
        Success = "✓",
        Warning = "!",
        Error   = "✕",
        Info    = "i",
    }
    local nType = config.Type or "Info"
    local color = typeColors[nType] or T.Inf
    local icon  = typeIcons[nType]  or "i"

    local notif = New("Frame", {
        Name = "Notif",
        Size = UDim2.new(1, 0, 0, config.Description and 72 or 56),
        BackgroundColor3 = T.Surface2,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 10, 0, 0), -- start off-screen
        Parent = self.NotifContainer,
    }, {
        MakeCorner(12),
        MakeStroke(T.Border1, 1, T.Border1Alpha),
    })

    -- Top color bar
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = notif,
    }, { MakeCorner(12) })
    -- Fix bottom corners of top bar
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = notif,
    })

    -- Icon
    local iconWrap = New("Frame", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 11, 0, 13),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.87,
        BorderSizePixel = 0,
        Parent = notif,
    }, { MakeCorner(8) })
    New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = icon,
        TextColor3 = color,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Parent = iconWrap,
    })

    -- Title
    New("TextLabel", {
        Size = UDim2.new(1, -70, 0, 16),
        Position = UDim2.new(0, 49, 0, 11),
        BackgroundTransparency = 1,
        Text = config.Title or nType,
        TextColor3 = T.Text1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })

    if config.Description then
        New("TextLabel", {
            Size = UDim2.new(1, -70, 0, 28),
            Position = UDim2.new(0, 49, 0, 28),
            BackgroundTransparency = 1,
            Text = config.Description,
            TextColor3 = T.Text2,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = notif,
        })
    end

    -- Progress bar
    local progBg = New("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = T.Border0,
        BackgroundTransparency = 1 - T.Border0Alpha,
        BorderSizePixel = 0,
        Parent = notif,
    })
    local prog = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = progBg,
    }, { MakeCorner(1) })

    -- Close button
    local closeBtn = New("TextButton", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -26, 0, 9),
        BackgroundColor3 = T.Border1,
        BackgroundTransparency = 1 - T.Border1Alpha,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = T.Text3,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Parent = notif,
    }, { MakeCorner(9) })

    -- Animate in
    Tween(notif, { Position = UDim2.new(0, 0, 0, 0) }, 0.4, Enum.EasingStyle.Spring)

    -- Progress countdown
    Tween(prog, { Size = UDim2.new(0, 0, 1, 0) }, dur, Enum.EasingStyle.Linear)

    -- Dismiss function
    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        Tween(notif, { Position = UDim2.new(1, 10, 0, 0) }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.35, function() notif:Destroy() end)
    end

    closeBtn.MouseButton1Click:Connect(dismiss)
    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, { BackgroundColor3 = T.Err }, 0.12) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, { BackgroundColor3 = T.Border1 }, 0.12) end)
    task.delay(dur, dismiss)
end

-- ════════════════════════════════════════════════════════════
--  WINDOW CONTROLS
-- ════════════════════════════════════════════════════════════
function NexusLib:_minimizeWindow()
    local T = self.Theme
    if self._minimized then
        self._minimized = false
        TweenSpring(self.Window, { Size = UDim2.new(0, 640, 0, 460) }, 0.38)
    else
        self._minimized = true
        TweenSpring(self.Window, { Size = UDim2.new(0, 640, 0, 52) }, 0.38)
    end
end

function NexusLib:_closeWindow()
    Tween(self.Window, { BackgroundTransparency = 1 }, 0.3)
    Tween(self.Window, { Size = UDim2.new(0, 620, 0, 440) }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.delay(0.32, function()
        self.ScreenGui:Destroy()
        self:Destroy()
    end)
end

function NexusLib:SetVisible(val)
    self.Visible = val
    self.Window.Visible = val
end

function NexusLib:Toggle()
    self:SetVisible(not self.Visible)
end

-- ════════════════════════════════════════════════════════════
--  INPUT HOOK (toggle key)
-- ════════════════════════════════════════════════════════════
function NexusLib:_hookInput()
    local conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == self.ToggleKey then
            self:Toggle()
        end
    end)
    table.insert(self._connections, conn)
end

-- ════════════════════════════════════════════════════════════
--  THEME SWITCHER
-- ════════════════════════════════════════════════════════════
function NexusLib:SetTheme(themeName)
    -- Full re-theme would require rebuilding or per-element refs
    -- For live switching: rebuild GUI
    self.ThemeName = themeName
    self.Theme = NexusLib.Themes[themeName] or NexusLib.Themes.Dark
    self.ScreenGui:Destroy()
    self:_buildGui()
end

-- ════════════════════════════════════════════════════════════
--  DESTROY
-- ════════════════════════════════════════════════════════════
function NexusLib:Destroy()
    for _, conn in pairs(self._connections) do
        conn:Disconnect()
    end
    if self.ScreenGui and self.ScreenGui.Parent then
        self.ScreenGui:Destroy()
    end
end

-- ════════════════════════════════════════════════════════════
--  RETURN
-- ════════════════════════════════════════════════════════════
return NexusLib

--[[
═══════════════════════════════════════════════════════════════
  USAGE EXAMPLE
═══════════════════════════════════════════════════════════════

local NexusLib = loadstring(game:HttpGet("..."))()

local Window = NexusLib.new({
    Title      = "My Script",
    Subtitle   = "v1.0",
    Theme      = "Dark",        -- "Dark" | "Ocean" | "Crimson" | "Light"
    ToggleKey  = Enum.KeyCode.RightShift,
})

-- Add a main tab
local CombatTab = Window:AddTab({ Name = "Combat", Icon = "⚔" })

-- Add sub-tabs (sections) inside the tab
local General = CombatTab:AddSection({ Name = "General" })

General:AddToggle({
    Name        = "God Mode",
    Icon        = "🛡",
    Description = "Prevents all incoming damage",
    Default     = false,
    Callback    = function(val)
        print("God Mode:", val)
    end,
})

General:AddToggle({
    Name     = "Infinite Stamina",
    Icon     = "∞",
    Default  = true,
    Callback = function(val) print("Stamina:", val) end,
})

General:AddButton({
    Name     = "Kill Aura",
    Icon     = "🎯",
    Callback = function() print("Kill Aura triggered") end,
})

General:AddKeybind({
    Name     = "Toggle Aura",
    Default  = Enum.KeyCode.E,
    Callback = function(key) print("New key:", key) end,
})

-- Aimbot sub-tab
local Aimbot = CombatTab:AddSection({ Name = "Aimbot" })

Aimbot:AddToggle({ Name = "Silent Aim", Default = false, Callback = function(v) end })

Aimbot:AddDropdown({
    Name    = "Target Mode",
    Options = { "Nearest", "Lowest HP", "Crosshair", "Random" },
    Default = "Nearest",
    Callback = function(val) print("Mode:", val) end,
})

Aimbot:AddSlider({
    Name     = "FOV Size",
    Min      = 0,
    Max      = 360,
    Default  = 90,
    Step     = 5,
    Callback = function(val) print("FOV:", val) end,
})

-- Visuals tab
local VisualsTab = Window:AddTab({ Name = "Visuals", Icon = "◈" })
local ESP = VisualsTab:AddSection({ Name = "ESP" })

ESP:AddToggle({ Name = "ESP Boxes",  Default = true,  Callback = function(v) end })
ESP:AddToggle({ Name = "Nametags",   Default = true,  Callback = function(v) end })
ESP:AddToggle({ Name = "Tracers",    Default = false, Callback = function(v) end })

local Colors = VisualsTab:AddSection({ Name = "Colors" })

Colors:AddColorPicker({
    Name    = "Enemy Color",
    Icon    = "●",
    Default = Color3.fromRGB(248, 113, 113),
    Callback = function(color) print("Color:", color) end,
})

-- Notifications
Window:Notify({
    Title       = "NexusLib",
    Description = "Loaded successfully.",
    Type        = "Success",
    Duration    = 4,
})

--]]
