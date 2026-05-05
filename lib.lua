--[[
    NexusLib - A Modern Roblox UI Library
    Version: 1.1.0

    Usage:
        local NexusLib = loadstring(game:HttpGet("your_url"))()
        local Window = NexusLib:CreateWindow({
            Title    = "My Script",
            Subtitle = "v1.0",
            Theme    = "Dark",  -- "Dark" | "Light" | "Ocean" | "Crimson"
            Size     = UDim2.new(0, 580, 0, 420),  -- optional
        })

        local Tab = Window:AddTab("Main", "rbxassetid://...")
        Tab:AddButton({ Label = "Click Me", Callback = function() print("clicked") end })

    Elements:
        Tab:AddSection(name)
        Tab:AddButton({ Label, Desc, Callback, Icon })
        Tab:AddToggle({ Label, Desc, Default, Callback })
        Tab:AddSlider({ Label, Min, Max, Default, Suffix, Decimals, Callback })
        Tab:AddTextBox({ Label, Placeholder, Default, Callback, ClearOnFocus, IsPassword })
        Tab:AddDropdown({ Label, Options, Default, Multi, Callback })
        Tab:AddKeybind({ Label, Default, Callback })
        Tab:AddColorPicker({ Label, Default, Callback })
        Tab:AddLabel({ Text, Color })
        Tab:AddSeparator()
        Tab:AddParagraph({ Title, Body })
        Tab:AddProgressBar({ Label, Min, Max, Default, Suffix, Callback })
        Tab:AddGrid({ Label, Options, Callback })

    Window methods:
        Window:SetTheme(name)
        Window:Minimize()
        Window:Close()
        Window:SetTitle(str)
        Window:SetSubtitle(str)
        Window:SelectTab(index)
        Window:Notify({ Title, Message, Duration, Type })

    Notify (global):
        NexusLib:Notify({ Title, Message, Duration, Type, Theme })
]]

local NexusLib = {}
NexusLib.__index = NexusLib

-- ============================================================
--  SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
--  THEMES
-- ============================================================
local Themes = {
    Dark = {
        Background  = Color3.fromRGB(15,  15,  20),
        Surface     = Color3.fromRGB(22,  22,  30),
        Panel       = Color3.fromRGB(28,  28,  38),
        Card        = Color3.fromRGB(35,  35,  48),
        Accent      = Color3.fromRGB(99,  102, 241),
        AccentHover = Color3.fromRGB(129, 132, 255),
        AccentDim   = Color3.fromRGB(60,  63,  160),
        Text        = Color3.fromRGB(240, 240, 255),
        TextMuted   = Color3.fromRGB(140, 140, 170),
        TextDim     = Color3.fromRGB(80,  80,  110),
        Success     = Color3.fromRGB(52,  211, 153),
        Warning     = Color3.fromRGB(251, 191, 36),
        Danger      = Color3.fromRGB(248, 113, 113),
        Border      = Color3.fromRGB(50,  50,  70),
        Toggle      = Color3.fromRGB(99,  102, 241),
        ToggleOff   = Color3.fromRGB(55,  55,  75),
        Scrollbar   = Color3.fromRGB(60,  60,  85),
    },
    Ocean = {
        Background  = Color3.fromRGB(8,   20,  35),
        Surface     = Color3.fromRGB(12,  28,  48),
        Panel       = Color3.fromRGB(16,  36,  60),
        Card        = Color3.fromRGB(20,  44,  72),
        Accent      = Color3.fromRGB(56,  189, 248),
        AccentHover = Color3.fromRGB(100, 210, 255),
        AccentDim   = Color3.fromRGB(30,  110, 180),
        Text        = Color3.fromRGB(225, 240, 255),
        TextMuted   = Color3.fromRGB(130, 170, 210),
        TextDim     = Color3.fromRGB(70,  110, 150),
        Success     = Color3.fromRGB(52,  211, 153),
        Warning     = Color3.fromRGB(251, 191, 36),
        Danger      = Color3.fromRGB(248, 113, 113),
        Border      = Color3.fromRGB(30,  60,  90),
        Toggle      = Color3.fromRGB(56,  189, 248),
        ToggleOff   = Color3.fromRGB(25,  55,  85),
        Scrollbar   = Color3.fromRGB(40,  80,  120),
    },
    Crimson = {
        Background  = Color3.fromRGB(18,  8,   10),
        Surface     = Color3.fromRGB(28,  12,  16),
        Panel       = Color3.fromRGB(36,  15,  20),
        Card        = Color3.fromRGB(46,  18,  24),
        Accent      = Color3.fromRGB(244, 63,  94),
        AccentHover = Color3.fromRGB(255, 100, 128),
        AccentDim   = Color3.fromRGB(160, 30,  55),
        Text        = Color3.fromRGB(255, 235, 238),
        TextMuted   = Color3.fromRGB(200, 150, 160),
        TextDim     = Color3.fromRGB(120, 70,  80),
        Success     = Color3.fromRGB(52,  211, 153),
        Warning     = Color3.fromRGB(251, 191, 36),
        Danger      = Color3.fromRGB(248, 113, 113),
        Border      = Color3.fromRGB(70,  25,  35),
        Toggle      = Color3.fromRGB(244, 63,  94),
        ToggleOff   = Color3.fromRGB(65,  20,  30),
        Scrollbar   = Color3.fromRGB(90,  30,  45),
    },
    Light = {
        Background  = Color3.fromRGB(245, 245, 250),
        Surface     = Color3.fromRGB(255, 255, 255),
        Panel       = Color3.fromRGB(240, 240, 248),
        Card        = Color3.fromRGB(250, 250, 255),
        Accent      = Color3.fromRGB(99,  102, 241),
        AccentHover = Color3.fromRGB(79,  82,  220),
        AccentDim   = Color3.fromRGB(180, 182, 255),
        Text        = Color3.fromRGB(20,  20,  40),
        TextMuted   = Color3.fromRGB(100, 100, 130),
        TextDim     = Color3.fromRGB(160, 160, 190),
        Success     = Color3.fromRGB(16,  185, 129),
        Warning     = Color3.fromRGB(217, 119, 6),
        Danger      = Color3.fromRGB(220, 38,  38),
        Border      = Color3.fromRGB(210, 210, 230),
        Toggle      = Color3.fromRGB(99,  102, 241),
        ToggleOff   = Color3.fromRGB(180, 180, 200),
        Scrollbar   = Color3.fromRGB(190, 190, 210),
    },
}

-- ============================================================
--  UTILITY HELPERS
-- ============================================================

local function Tween(obj, props, duration, style, direction)
    style     = style     or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration or 0.25, style, direction)
    TweenService:Create(obj, info, props):Play()
end

local function MakeRound(obj, radius)
    local existing = obj:FindFirstChildOfClass("UICorner")
    if existing then existing.CornerRadius = UDim.new(0, radius or 8) return existing end
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = obj
    return corner
end

local function MakePadding(obj, t, b, l, r)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, t or 6)
    pad.PaddingBottom = UDim.new(0, b or 6)
    pad.PaddingLeft   = UDim.new(0, l or 10)
    pad.PaddingRight  = UDim.new(0, r or 10)
    pad.Parent = obj
    return pad
end

-- Upserts a UIStroke so re-calling never stacks strokes
local function MakeStroke(obj, color, thickness, transparency)
    local s = obj:FindFirstChildOfClass("UIStroke")
    if not s then
        s = Instance.new("UIStroke")
        s.Parent = obj
    end
    s.Color        = color        or Color3.new(1,1,1)
    s.Thickness    = thickness    or 1
    s.Transparency = transparency or 0.85
    return s
end

local function NewFrame(parent, size, pos, color, name)
    local f = Instance.new("Frame")
    f.Size             = size  or UDim2.new(1,0,0,40)
    f.Position         = pos   or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = color or Color3.new(0,0,0)
    f.BorderSizePixel  = 0
    f.Name             = name  or "Frame"
    f.Parent           = parent
    return f
end

local function NewLabel(parent, text, size, color, name, font, textSize)
    local l = Instance.new("TextLabel")
    l.Size                   = size     or UDim2.new(1,0,1,0)
    l.Position               = UDim2.new(0,0,0,0)
    l.BackgroundTransparency = 1
    l.Text                   = text     or ""
    l.TextColor3             = color    or Color3.new(1,1,1)
    l.Font                   = font     or Enum.Font.GothamBold
    l.TextSize               = textSize or 13
    l.TextXAlignment         = Enum.TextXAlignment.Left
    l.Name                   = name     or "Label"
    l.Parent                 = parent
    return l
end

local function NewButton(parent, size, pos, color, name)
    local b = Instance.new("TextButton")
    b.Size             = size  or UDim2.new(1,0,0,36)
    b.Position         = pos   or UDim2.new(0,0,0,0)
    b.BackgroundColor3 = color or Color3.new(0.2,0.2,0.2)
    b.BorderSizePixel  = 0
    b.Text             = ""
    b.AutoButtonColor  = false
    b.Name             = name  or "Button"
    b.Parent           = parent
    return b
end

local function NewImage(parent, asset, size, pos, name)
    local img = Instance.new("ImageLabel")
    img.Size                   = size or UDim2.new(0,16,0,16)
    img.Position               = pos  or UDim2.new(0,0,0,0)
    img.BackgroundTransparency = 1
    img.Image                  = asset or ""
    img.Name                   = name  or "Icon"
    img.Parent                 = parent
    return img
end

local function NewImageButton(parent, asset, size, pos, name)
    local img = Instance.new("ImageButton")
    img.Size                   = size or UDim2.new(0,16,0,16)
    img.Position               = pos  or UDim2.new(0,0,0,0)
    img.BackgroundTransparency = 1
    img.Image                  = asset or ""
    img.AutoButtonColor        = false
    img.Name                   = name  or "IconBtn"
    img.Parent                 = parent
    return img
end

-- Safe ScreenGui parenting: tries CoreGui, falls back to PlayerGui
local function SafeParentGui(sg)
    local ok = pcall(function() sg.Parent = CoreGui end)
    if not ok or not sg.Parent then
        sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- Shared global drag state for sliders (prevents multi-slider confusion)
local GlobalDragTarget = nil

-- Makes any GuiObject draggable by a given handle
local function MakeDraggable(handle, target)
    local dragging  = false
    local dragStart = nil
    local startPos  = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = target.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging
        and (input.UserInputType == Enum.UserInputType.MouseMovement
          or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local vp    = workspace.CurrentCamera.ViewportSize
            local newX  = math.clamp(startPos.X.Offset + delta.X, 0, vp.X - target.AbsoluteSize.X)
            local newY  = math.clamp(startPos.Y.Offset + delta.Y, 0, vp.Y - target.AbsoluteSize.Y)
            target.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
end

-- Builds a horizontal slider track and returns { track, fill, knob }
-- The caller is responsible for binding drag events
local function BuildSliderTrack(parent, T, yOffset)
    local track = NewFrame(parent, UDim2.new(1,0,0,6), UDim2.new(0,0,0,yOffset or 0), T.Panel, "Track")
    MakeRound(track, 3)
    local fill = NewFrame(track, UDim2.new(0,0,1,0), UDim2.new(0,0,0,0), T.Accent, "Fill")
    MakeRound(fill, 3)
    local knob = NewFrame(track, UDim2.new(0,14,0,14), UDim2.new(0,0,0.5,-7), Color3.new(1,1,1), "Knob")
    MakeRound(knob, 7)
    -- Inner knob highlight
    local knobInner = NewFrame(knob, UDim2.new(0,6,0,6), UDim2.new(0.5,-3,0.5,-3), T.Accent, "KnobInner")
    MakeRound(knobInner, 3)
    -- Invisible hit area for easier grabbing
    local hitArea = NewButton(track, UDim2.new(1,0,0,20), UDim2.new(0,0,0.5,-10), Color3.new(0,0,0), "HitArea")
    hitArea.BackgroundTransparency = 1
    hitArea.ZIndex = knob.ZIndex + 1
    return track, fill, knob, hitArea
end

-- Binds drag + click to a slider track, calling setter(pct) on change
local function BindSliderDrag(track, hitArea, setter, decimals)
    decimals = decimals or 0
    local dragging = false

    local function applyInput(inputPos)
        local relX = math.clamp(inputPos.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local pct  = relX / math.max(track.AbsoluteSize.X, 1)
        setter(pct)
    end

    hitArea.MouseButton1Down:Connect(function()
        dragging = true
        GlobalDragTarget = track
    end)

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            GlobalDragTarget = track
            applyInput(i.Position)
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and GlobalDragTarget == track then
            dragging = false
            GlobalDragTarget = nil
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and GlobalDragTarget == track
        and i.UserInputType == Enum.UserInputType.MouseMovement then
            applyInput(i.Position)
        end
    end)
end

-- ============================================================
--  NOTIFICATION SYSTEM
-- ============================================================
local NotifHolder = nil

local function EnsureNotifHolder()
    if NotifHolder and NotifHolder.Parent then return end

    local sg = Instance.new("ScreenGui")
    sg.Name           = "NexusNotifs"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 9999
    SafeParentGui(sg)

    local holder = NewFrame(sg, UDim2.new(0,300,1,-24), UDim2.new(1,-316,0,0), Color3.new(0,0,0), "Holder")
    holder.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout")
    layout.SortOrder         = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Padding           = UDim.new(0, 8)
    layout.Parent            = holder

    MakePadding(holder, 12, 12, 0, 0)
    NotifHolder = holder
end

function NexusLib:Notify(opts)
    opts = opts or {}
    local title    = opts.Title    or "Notification"
    local message  = opts.Message  or ""
    local duration = opts.Duration or 4
    local ntype    = opts.Type     or "Info"
    local theme    = opts.Theme    or "Dark"
    local T        = Themes[theme] or Themes.Dark

    EnsureNotifHolder()

    local typeColor = T.Accent
    local typeIcon  = "ℹ"
    if ntype == "Success" then
        typeColor = T.Success ; typeIcon = "✓"
    elseif ntype == "Warning" then
        typeColor = T.Warning ; typeIcon = "⚠"
    elseif ntype == "Error" then
        typeColor = T.Danger  ; typeIcon = "✕"
    end

    -- Count existing notifs for LayoutOrder
    local order = 0
    for _, c in ipairs(NotifHolder:GetChildren()) do
        if c:IsA("Frame") then order = order + 1 end
    end

    local card = NewFrame(NotifHolder, UDim2.new(1,0,0,0), UDim2.new(0,0,0,0), T.Panel, "Notif")
    card.AutomaticSize    = Enum.AutomaticSize.Y
    card.ClipsDescendants = false
    card.LayoutOrder      = order
    MakeRound(card, 10)
    MakeStroke(card, T.Border, 1, 0.5)

    -- Coloured left stripe
    local stripe = NewFrame(card, UDim2.new(0,3,1,0), UDim2.new(0,0,0,0), typeColor, "Stripe")
    MakeRound(stripe, 3)

    -- Icon circle
    local iconCircle = NewFrame(card, UDim2.new(0,28,0,28), UDim2.new(0,14,0,10), typeColor, "IconCircle")
    iconCircle.BackgroundTransparency = 0.75
    MakeRound(iconCircle, 14)
    local iconLbl = NewLabel(iconCircle, typeIcon, UDim2.new(1,0,1,0), typeColor, "Icon", Enum.Font.GothamBold, 13)
    iconLbl.TextXAlignment = Enum.TextXAlignment.Center

    -- Text area
    local textFrame = NewFrame(card, UDim2.new(1,-56,0,0), UDim2.new(0,52,0,0), T.Panel, "TextArea")
    textFrame.AutomaticSize       = Enum.AutomaticSize.Y
    textFrame.BackgroundTransparency = 1

    local textLayout = Instance.new("UIListLayout")
    textLayout.SortOrder = Enum.SortOrder.LayoutOrder
    textLayout.Padding   = UDim.new(0, 2)
    textLayout.Parent    = textFrame
    MakePadding(textFrame, 10, 10, 0, 8)

    local titleLbl = NewLabel(textFrame, title, UDim2.new(1,0,0,16), T.Text, "Title", Enum.Font.GothamBold, 13)
    titleLbl.LayoutOrder = 1
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd

    if message ~= "" then
        local msgLbl = NewLabel(textFrame, message, UDim2.new(1,0,0,0), T.TextMuted, "Msg", Enum.Font.Gotham, 11)
        msgLbl.AutomaticSize = Enum.AutomaticSize.Y
        msgLbl.TextWrapped   = true
        msgLbl.LayoutOrder   = 2
    end

    -- Progress bar
    local barBg = NewFrame(card, UDim2.new(1,-3,0,3), UDim2.new(0,3,1,-3), T.Card, "BarBg")
    MakeRound(barBg, 2)
    local bar = NewFrame(barBg, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), typeColor, "Bar")
    bar.BackgroundTransparency = 0.4
    MakeRound(bar, 2)

    -- Dismiss button
    local dismissBtn = NewButton(card, UDim2.new(0,18,0,18), UDim2.new(1,-24,0,6), T.Panel, "Dismiss")
    MakeRound(dismissBtn, 9)
    local dismissLbl = NewLabel(dismissBtn, "×", UDim2.new(1,0,1,0), T.TextMuted, "X", Enum.Font.GothamBold, 14)
    dismissLbl.TextXAlignment = Enum.TextXAlignment.Center

    -- Animate in from right
    card.Position = UDim2.new(1.1, 0, 0, 0)
    Tween(card, {Position = UDim2.new(0,0,0,0)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Progress bar drain
    Tween(bar, {Size = UDim2.new(0,0,1,0)}, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

    local function Dismiss()
        Tween(card, {Position = UDim2.new(1.1,0,0,0), BackgroundTransparency = 1}, 0.25)
        task.wait(0.28)
        if card and card.Parent then card:Destroy() end
    end

    dismissBtn.MouseButton1Click:Connect(Dismiss)
    task.delay(duration, function()
        if card and card.Parent then Dismiss() end
    end)
end

-- ============================================================
--  WINDOW
-- ============================================================
function NexusLib:CreateWindow(opts)
    opts = opts or {}
    local title     = opts.Title     or "NexusLib"
    local subtitle  = opts.Subtitle  or ""
    local themeName = opts.Theme     or "Dark"
    local T         = Themes[themeName] or Themes.Dark
    local winSize   = opts.Size      or UDim2.new(0, 580, 0, 420)
    local startPos  = opts.Position  or UDim2.new(0.5, -math.floor(winSize.X.Offset/2), 0.5, -math.floor(winSize.Y.Offset/2))

    -- ── SCREEN GUI ───────────────────────────────────────────
    local sg = Instance.new("ScreenGui")
    sg.Name           = "NexusLib_" .. title:gsub("%s","")
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 100
    SafeParentGui(sg)

    -- ── SHADOW ───────────────────────────────────────────────
    local shadowFrame = NewFrame(sg,
        UDim2.new(0, winSize.X.Offset + 40, 0, winSize.Y.Offset + 40),
        UDim2.new(startPos.X.Scale, startPos.X.Offset - 20, startPos.Y.Scale, startPos.Y.Offset - 20),
        Color3.new(0,0,0), "Shadow")
    shadowFrame.BackgroundTransparency = 0.65
    shadowFrame.ZIndex = 1
    MakeRound(shadowFrame, 18)

    -- ── ROOT WINDOW ───────────────────────────────────────────
    local win = NewFrame(sg, winSize, startPos, T.Background, "Window")
    win.ZIndex           = 2
    win.ClipsDescendants = true
    MakeRound(win, 12)
    MakeStroke(win, T.Border, 1, 0.55)

    -- ── TITLE BAR ────────────────────────────────────────────
    local titleBar = NewFrame(win, UDim2.new(1,0,0,52), UDim2.new(0,0,0,0), T.Surface, "TitleBar")
    titleBar.ZIndex = 3
    -- Square off the bottom corners of the title bar
    local tbFill = NewFrame(win, UDim2.new(1,0,0,14), UDim2.new(0,0,0,40), T.Surface, "TitleBarFill")
    tbFill.ZIndex = 3

    MakePadding(titleBar, 0, 0, 16, 14)
    MakeDraggable(titleBar, win)

    -- Also drag shadow along with window
    win:GetPropertyChangedSignal("Position"):Connect(function()
        shadowFrame.Position = UDim2.new(
            win.Position.X.Scale, win.Position.X.Offset - 20,
            win.Position.Y.Scale, win.Position.Y.Offset - 20
        )
    end)

    -- Window control buttons (macOS style)
    local function MakeWinBtn(color, offsetX)
        local btn = NewButton(titleBar, UDim2.new(0,13,0,13), UDim2.new(0, offsetX, 0.5, -6), color, "WinBtn")
        MakeRound(btn, 7)
        MakeStroke(btn, Color3.new(0,0,0), 1, 0.88)
        return btn
    end
    local btnClose = MakeWinBtn(T.Danger,   0)
    local btnMin   = MakeWinBtn(T.Warning,  20)
    local btnMax   = MakeWinBtn(T.Success,  40)

    -- Title text — anchored after the control buttons
    local titleLbl = NewLabel(titleBar, title, UDim2.new(1,-70,1,0), T.Text, "Title", Enum.Font.GothamBold, 14)
    titleLbl.Position      = UDim2.new(0, 62, 0, 0)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local subtitleLbl = nil
    if subtitle ~= "" then
        titleLbl.Size = UDim2.new(0,200,0,28)
        titleLbl.Position = UDim2.new(0,62,0,4)
        subtitleLbl = NewLabel(titleBar, subtitle, UDim2.new(0,200,0,16), T.TextMuted, "Sub", Enum.Font.Gotham, 10)
        subtitleLbl.Position = UDim2.new(0,62,0,28)
    end

    -- Thin accent line under title bar
    local accentLine = NewFrame(win, UDim2.new(0,40,0,2), UDim2.new(0,16,0,50), T.Accent, "AccentLine")
    accentLine.BackgroundTransparency = 0.4
    MakeRound(accentLine, 1)

    -- ── SIDEBAR ──────────────────────────────────────────────
    local SIDEBAR_W = 148
    local sidebar = NewFrame(win, UDim2.new(0,SIDEBAR_W,1,-52), UDim2.new(0,0,0,52), T.Surface, "Sidebar")
    sidebar.ClipsDescendants = true
    sidebar.ZIndex = 2
    -- Fill corner gap
    local sbFill = NewFrame(win, UDim2.new(0,12,1,-52), UDim2.new(0,SIDEBAR_W-12,0,52), T.Surface, "SBFill")
    sbFill.ZIndex = 2

    local sideLayout = Instance.new("UIListLayout")
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sideLayout.Padding   = UDim.new(0, 3)
    sideLayout.Parent    = sidebar
    MakePadding(sidebar, 10, 10, 8, 8)

    -- Divider between sidebar and content
    local divider = NewFrame(win, UDim2.new(0,1,1,-52), UDim2.new(0,SIDEBAR_W,0,52), T.Border, "Divider")
    divider.BackgroundTransparency = 0.5

    -- ── CONTENT AREA ─────────────────────────────────────────
    local contentArea = NewFrame(win, UDim2.new(1,-(SIDEBAR_W+1),1,-52), UDim2.new(0,SIDEBAR_W+1,0,52), T.Background, "Content")
    contentArea.ClipsDescendants = true
    contentArea.ZIndex = 2

    -- ── BOTTOM STATUS BAR ────────────────────────────────────
    local statusBar = NewFrame(win, UDim2.new(1,0,0,22), UDim2.new(0,0,1,-22), T.Surface, "StatusBar")
    statusBar.ZIndex = 3
    local statusFill = NewFrame(win, UDim2.new(1,0,0,10), UDim2.new(0,0,1,-28), T.Surface, "StatusFill")
    statusFill.ZIndex = 3
    local statusLbl = NewLabel(statusBar, "NexusLib  v1.1.0", UDim2.new(0.5,0,1,0), T.TextDim, "StatusTxt", Enum.Font.Gotham, 9)
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    local statusLblR = NewLabel(statusBar, themeName, UDim2.new(0.5,0,1,0), T.Accent, "StatusTheme", Enum.Font.GothamBold, 9)
    statusLblR.Position = UDim2.new(0.5,0,0,0)
    statusLblR.TextXAlignment = Enum.TextXAlignment.Right
    MakePadding(statusBar, 0, 0, 12, 12)

    -- ============================================================
    --  WINDOW OBJECT
    -- ============================================================
    local Window = {
        _T           = T,
        _themeName   = themeName,
        _tabs        = {},
        _activeTab   = nil,
        _sidebar     = sidebar,
        _contentArea = contentArea,
        _sg          = sg,
        _win         = win,
        _shadow      = shadowFrame,
        _statusLbl   = statusLbl,
        _statusLblR  = statusLblR,
        _titleLbl    = titleLbl,
        _subtitleLbl = subtitleLbl,
        _minimized   = false,
        _originalSize = winSize,
    }

    -- ── WINDOW BUTTON HOVER FX ───────────────────────────────
    for _, btn in ipairs({btnClose, btnMin, btnMax}) do
        btn.MouseEnter:Connect(function()  Tween(btn, {BackgroundTransparency = 0.25}, 0.12) end)
        btn.MouseLeave:Connect(function()  Tween(btn, {BackgroundTransparency = 0},    0.12) end)
    end

    -- ── CLOSE ────────────────────────────────────────────────
    btnClose.MouseButton1Click:Connect(function()
        Tween(win,         {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, 0.28)
        Tween(shadowFrame, {BackgroundTransparency = 1}, 0.28)
        task.wait(0.30)
        sg:Destroy()
    end)

    -- ── MINIMIZE ─────────────────────────────────────────────
    btnMin.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)

    -- ── MAXIMIZE (toggle full height) ────────────────────────
    local maximized = false
    local prevSize  = winSize
    btnMax.MouseButton1Click:Connect(function()
        maximized = not maximized
        local vp = workspace.CurrentCamera.ViewportSize
        if maximized then
            prevSize = win.Size
            Tween(win,         {Size = UDim2.new(0, math.min(winSize.X.Offset, vp.X-40), 0, vp.Y-80)}, 0.3)
            Tween(shadowFrame, {Size = UDim2.new(0, math.min(winSize.X.Offset, vp.X-40)+40, 0, vp.Y-40)}, 0.3)
        else
            Tween(win,         {Size = prevSize}, 0.3)
            Tween(shadowFrame, {Size = UDim2.new(0, prevSize.X.Offset+40, 0, prevSize.Y.Offset+40)}, 0.3)
        end
    end)

    -- ── MINIMIZE METHOD ──────────────────────────────────────
    function Window:Minimize()
        self._minimized = not self._minimized
        if self._minimized then
            Tween(win,         {Size = UDim2.new(0, win.AbsoluteSize.X, 0, 52)}, 0.3)
            Tween(shadowFrame, {Size = UDim2.new(0, win.AbsoluteSize.X+40, 0, 92)}, 0.3)
        else
            local s = self._originalSize
            Tween(win,         {Size = s}, 0.3)
            Tween(shadowFrame, {Size = UDim2.new(0, s.X.Offset+40, 0, s.Y.Offset+40)}, 0.3)
        end
    end

    -- ── CLOSE METHOD ─────────────────────────────────────────
    function Window:Close()
        Tween(win,         {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, 0.28)
        Tween(shadowFrame, {BackgroundTransparency = 1}, 0.28)
        task.wait(0.30)
        sg:Destroy()
    end

    -- ── SET TITLE ────────────────────────────────────────────
    function Window:SetTitle(str)
        self._titleLbl.Text = str
    end

    -- ── SET SUBTITLE ─────────────────────────────────────────
    function Window:SetSubtitle(str)
        if self._subtitleLbl then
            self._subtitleLbl.Text = str
        end
    end

    -- ── SELECT TAB BY INDEX ──────────────────────────────────
    function Window:SelectTab(index)
        local tab = self._tabs[index]
        if tab and tab._select then
            tab._select()
        end
    end

    -- ── PER-WINDOW NOTIFY ────────────────────────────────────
    function Window:Notify(opts)
        opts = opts or {}
        opts.Theme = opts.Theme or self._themeName
        NexusLib:Notify(opts)
    end

    -- ── SET THEME ────────────────────────────────────────────
    function Window:SetTheme(newThemeName)
        -- Recreating is the safest approach for a complete theme swap.
        -- Patch the status bar label for live feedback.
        local newT = Themes[newThemeName]
        if not newT then return end
        self._themeName  = newThemeName
        self._T          = newT
        statusLblR.Text  = newThemeName
        Tween(statusLblR, {TextColor3 = newT.Accent}, 0.3)
        -- Full theme swap requires window recreation; notify user.
        self:Notify({
            Title   = "Theme Changed",
            Message = "Recreate the window to apply '" .. newThemeName .. "' fully.",
            Type    = "Info",
            Theme   = newThemeName,
        })
    end

    -- ============================================================
    --  ADD TAB
    -- ============================================================
    function Window:AddTab(name, icon)
        local T       = self._T
        local tabIndex = #self._tabs + 1

        -- ── SIDEBAR BUTTON ───────────────────────────────────
        local tabBtn = NewButton(self._sidebar, UDim2.new(1,0,0,36), UDim2.new(0,0,0,0), T.Panel, "Tab_"..name)
        tabBtn.LayoutOrder         = tabIndex
        tabBtn.BackgroundTransparency = 1
        MakeRound(tabBtn, 8)

        -- Icon (optional)
        local iconOffset = 0
        if icon and icon ~= "" then
            local iconImg = NewImage(tabBtn, icon, UDim2.new(0,16,0,16), UDim2.new(0,10,0.5,-8), "Icon")
            iconImg.ImageColor3 = T.TextMuted
            iconOffset = 30
        end

        local tabLbl = NewLabel(tabBtn, name, UDim2.new(1, -(iconOffset+10), 1, 0), T.TextMuted, "Label", Enum.Font.GothamSemibold, 12)
        tabLbl.Position = UDim2.new(0, iconOffset + (icon and 0 or 10), 0, 0)

        -- Active indicator bar
        local indicator = NewFrame(tabBtn, UDim2.new(0,3,0.5,0), UDim2.new(0,0,0.25,0), T.Accent, "Indicator")
        indicator.BackgroundTransparency = 1
        MakeRound(indicator, 2)

        -- ── PAGE ─────────────────────────────────────────────
        local page = NewFrame(self._contentArea, UDim2.new(1,0,1,-22), UDim2.new(0,0,0,0), T.Background, "Page_"..name)
        page.Visible = false
        page.ClipsDescendants = true

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size                   = UDim2.new(1,0,1,0)
        scroll.Position               = UDim2.new(0,0,0,0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel        = 0
        scroll.ScrollBarThickness     = 4
        scroll.ScrollBarImageColor3   = T.Scrollbar
        scroll.ScrollingDirection     = Enum.ScrollingDirection.Y
        scroll.CanvasSize             = UDim2.new(0,0,0,0)
        scroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        scroll.Parent                 = page

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding   = UDim.new(0, 6)
        pageLayout.Parent    = scroll
        MakePadding(scroll, 12, 12, 14, 14)

        -- Element order counter (avoids counting UIListLayout/UIPadding as children)
        local elemOrder = 0
        local function NextOrder()
            elemOrder = elemOrder + 1
            return elemOrder
        end

        -- ── TAB SELECT LOGIC ─────────────────────────────────
        local function Select()
            -- Deactivate previous
            if Window._activeTab then
                local prev = Window._activeTab
                Tween(prev._btn,       {BackgroundColor3 = T.Panel, BackgroundTransparency = 1}, 0.2)
                Tween(prev._lbl,       {TextColor3 = T.TextMuted}, 0.2)
                Tween(prev._indicator, {BackgroundTransparency = 1, Size = UDim2.new(0,3,0.5,0)}, 0.2)
                prev._page.Visible = false
            end
            -- Activate this
            Tween(tabBtn,    {BackgroundColor3 = T.AccentDim, BackgroundTransparency = 0.75}, 0.2)
            Tween(tabLbl,    {TextColor3 = T.Text}, 0.2)
            Tween(indicator, {BackgroundTransparency = 0, Size = UDim2.new(0,3,0.7,0)}, 0.2)
            page.Visible = true
            Window._activeTab = { _btn = tabBtn, _lbl = tabLbl, _indicator = indicator, _page = page }
        end

        tabBtn.MouseButton1Click:Connect(Select)
        tabBtn.MouseEnter:Connect(function()
            if not (Window._activeTab and Window._activeTab._btn == tabBtn) then
                Tween(tabBtn, {BackgroundTransparency = 0.88, BackgroundColor3 = T.Card}, 0.15)
                Tween(tabLbl, {TextColor3 = T.Text}, 0.15)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if not (Window._activeTab and Window._activeTab._btn == tabBtn) then
                Tween(tabBtn, {BackgroundTransparency = 1}, 0.15)
                Tween(tabLbl, {TextColor3 = T.TextMuted}, 0.15)
            end
        end)

        -- Auto-select first tab
        if tabIndex == 1 then Select() end

        -- ============================================================
        --  TAB OBJECT
        -- ============================================================
        local Tab = {
            _scroll    = scroll,
            _T         = T,
            _layout    = pageLayout,
            _nextOrder = NextOrder,
            _select    = Select,
        }

        -- ── SECTION ──────────────────────────────────────────
        function Tab:AddSection(name)
            local T   = self._T
            local row = NewFrame(self._scroll, UDim2.new(1,0,0,28), nil, T.Background, "Section_"..name)
            row.LayoutOrder       = self._nextOrder()
            row.BackgroundTransparency = 1

            local line1 = NewFrame(row, UDim2.new(0.25,0,0,1), UDim2.new(0,0,0.5,0), T.Border, "L1")
            line1.BackgroundTransparency = 0.5

            local lbl = NewLabel(row, name:upper(), UDim2.new(0.5,0,1,0), T.TextDim, "SectionLbl", Enum.Font.GothamBold, 9)
            lbl.Position       = UDim2.new(0.25,0,0,0)
            lbl.TextXAlignment = Enum.TextXAlignment.Center

            local line2 = NewFrame(row, UDim2.new(0.25,0,0,1), UDim2.new(0.75,0,0.5,0), T.Border, "L2")
            line2.BackgroundTransparency = 0.5

            return row
        end

        -- ── BUTTON ───────────────────────────────────────────
        function Tab:AddButton(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Button"
            local desc     = opts.Desc     or ""
            local callback = opts.Callback or function() end
            local icon     = opts.Icon     or nil
            local hasDesc  = desc ~= ""

            local cardH = hasDesc and 52 or 38
            local card  = NewFrame(self._scroll, UDim2.new(1,0,0,cardH), nil, T.Card, "BtnCard")
            card.LayoutOrder = self._nextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.72)

            local btn = NewButton(card, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), T.Card, "Btn")
            MakeRound(btn, 8)

            -- Left icon strip
            local contentOffsetL = 12
            if icon then
                local iconBg = NewFrame(btn, UDim2.new(0,30,1,0), UDim2.new(0,0,0,0), T.AccentDim, "IconBg")
                iconBg.BackgroundTransparency = 0.75
                local iconImg = NewImage(iconBg, icon, UDim2.new(0,16,0,16), UDim2.new(0.5,-8,0.5,-8), "Icon")
                iconImg.ImageColor3 = T.Accent
                contentOffsetL = 40
            end

            local lbl = NewLabel(btn, label, UDim2.new(1, -(contentOffsetL+36), 0, 18), T.Text, "Lbl", Enum.Font.GothamSemibold, 13)
            lbl.Position = UDim2.new(0, contentOffsetL, 0, hasDesc and 8 or 10)

            if hasDesc then
                local d = NewLabel(btn, desc, UDim2.new(1,-(contentOffsetL+36),0,14), T.TextMuted, "Desc", Enum.Font.Gotham, 11)
                d.Position = UDim2.new(0, contentOffsetL, 0, 28)
            end

            -- Arrow on right
            local arrow = NewLabel(btn, "›", UDim2.new(0,24,1,0), T.Accent, "Arrow", Enum.Font.GothamBold, 20)
            arrow.Position       = UDim2.new(1,-28,0,0)
            arrow.TextXAlignment = Enum.TextXAlignment.Center

            -- Ripple frame (clipped to card)
            btn.ClipsDescendants = true

            local function DoRipple(x, y)
                local rip = NewFrame(btn, UDim2.new(0,0,0,0), UDim2.new(0,x - btn.AbsolutePosition.X,0,y - btn.AbsolutePosition.Y), T.Accent, "Ripple")
                rip.BackgroundTransparency = 0.7
                rip.AnchorPoint = Vector2.new(0.5,0.5)
                MakeRound(rip, 999)
                Tween(rip, {Size = UDim2.new(0,200,0,200), BackgroundTransparency = 1}, 0.5)
                task.delay(0.52, function() if rip and rip.Parent then rip:Destroy() end end)
            end

            btn.MouseEnter:Connect(function()      Tween(btn, {BackgroundColor3 = T.AccentDim}, 0.15)   end)
            btn.MouseLeave:Connect(function()      Tween(btn, {BackgroundColor3 = T.Card},      0.15)   end)
            btn.MouseButton1Down:Connect(function() Tween(btn, {BackgroundColor3 = T.Accent},    0.08)  end)
            btn.MouseButton1Up:Connect(function()
                Tween(btn,   {BackgroundColor3 = T.Card}, 0.2)
                Tween(arrow, {Position = UDim2.new(1,-24,0,0)}, 0.08)
                task.delay(0.08, function() Tween(arrow, {Position = UDim2.new(1,-28,0,0)}, 0.15) end)
                local ok, err = pcall(callback)
                if not ok then warn("[NexusLib] Button callback error: " .. tostring(err)) end
            end)
            btn.MouseButton1Click:Connect(function()
                local mp = UserInputService:GetMouseLocation()
                DoRipple(mp.X, mp.Y)
            end)

            return { card = card, SetLabel = function(_,s) lbl.Text = s end }
        end

        -- ── TOGGLE ───────────────────────────────────────────
        function Tab:AddToggle(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Toggle"
            local desc     = opts.Desc     or ""
            local default  = opts.Default  == true
            local callback = opts.Callback or function() end
            local hasDesc  = desc ~= ""

            local state   = default
            local cardH   = hasDesc and 52 or 38
            local card    = NewFrame(self._scroll, UDim2.new(1,0,0,cardH), nil, T.Card, "TogCard")
            card.LayoutOrder = self._nextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.72)

            local btn = NewButton(card, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), T.Card, "Btn")
            MakeRound(btn, 8)
            MakePadding(btn, 0, 0, 12, 14)

            local lbl = NewLabel(btn, label, UDim2.new(1,-58,0,18), T.Text, "Lbl", Enum.Font.GothamSemibold, 13)
            lbl.Position = UDim2.new(0,0,0, hasDesc and 8 or 10)
            if hasDesc then
                local d = NewLabel(btn, desc, UDim2.new(1,-58,0,14), T.TextMuted, "Desc", Enum.Font.Gotham, 11)
                d.Position = UDim2.new(0,0,0,28)
            end

            -- Toggle pill
            local pill = NewFrame(btn, UDim2.new(0,44,0,24), UDim2.new(1,-44,0.5,-12), state and T.Toggle or T.ToggleOff, "Pill")
            MakeRound(pill, 12)
            MakeStroke(pill, Color3.new(0,0,0), 1, 0.9)

            local knob = NewFrame(pill, UDim2.new(0,18,0,18), UDim2.new(0, state and 23 or 3, 0.5,-9), Color3.new(1,1,1), "Knob")
            MakeRound(knob, 9)
            -- Knob shadow
            MakeStroke(knob, Color3.new(0,0,0), 1, 0.7)

            local function UpdateVisual(animated)
                if animated == false then
                    pill.BackgroundColor3 = state and T.Toggle or T.ToggleOff
                    knob.Position = UDim2.new(0, state and 23 or 3, 0.5, -9)
                else
                    Tween(pill, {BackgroundColor3 = state and T.Toggle or T.ToggleOff}, 0.2)
                    Tween(knob, {Position = UDim2.new(0, state and 23 or 3, 0.5, -9)}, 0.2, Enum.EasingStyle.Back)
                end
            end
            UpdateVisual(false)

            btn.MouseEnter:Connect(function()  Tween(btn, {BackgroundColor3 = T.Panel}, 0.12) end)
            btn.MouseLeave:Connect(function()  Tween(btn, {BackgroundColor3 = T.Card},  0.12) end)
            btn.MouseButton1Click:Connect(function()
                state = not state
                UpdateVisual()
                local ok, err = pcall(callback, state)
                if not ok then warn("[NexusLib] Toggle callback error: " .. tostring(err)) end
            end)

            local Toggle = {}
            function Toggle:Set(val)
                state = (val == true)
                UpdateVisual()
                pcall(callback, state)
            end
            function Toggle:Get() return state end
            function Toggle:SetLabel(str) lbl.Text = str end
            return Toggle
        end

        -- ── SLIDER ───────────────────────────────────────────
        function Tab:AddSlider(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Slider"
            local min      = opts.Min      or 0
            local max      = opts.Max      or 100
            local default  = opts.Default  or min
            local suffix   = opts.Suffix   or ""
            local decimals = opts.Decimals or 0
            local callback = opts.Callback or function() end

            local value = math.clamp(default, min, max)

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,58), nil, T.Card, "SlideCard")
            card.LayoutOrder = self._nextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.72)
            MakePadding(card, 10, 12, 14, 14)

            -- Top row: label + value
            local topRow = NewFrame(card, UDim2.new(1,0,0,18), UDim2.new(0,0,0,0), T.Card, "TopRow")
            topRow.BackgroundTransparency = 1

            local lbl = NewLabel(topRow, label, UDim2.new(0.7,0,1,0), T.Text, "Lbl", Enum.Font.GothamSemibold, 13)

            local function FormatValue(v)
                local fmt = "%." .. decimals .. "f"
                return string.format(fmt, v) .. suffix
            end

            local valLbl = NewLabel(topRow, FormatValue(value), UDim2.new(0.3,0,1,0), T.Accent, "Val", Enum.Font.GothamBold, 13)
            valLbl.Position       = UDim2.new(0.7,0,0,0)
            valLbl.TextXAlignment = Enum.TextXAlignment.Right

            -- Track (placed below top row, inside padded card)
            local track, fill, knob, hitArea = BuildSliderTrack(card, T, 28)

            local function UpdateSlider(pct)
                pct   = math.clamp(pct, 0, 1)
                local snap = 1 / (10 ^ decimals)
                local raw  = min + (max - min) * pct
                value = math.floor(raw / snap + 0.5) * snap
                value = math.clamp(value, min, max)

                local visualPct = (value - min) / math.max(max - min, 0.0001)
                fill.Size     = UDim2.new(visualPct, 0, 1, 0)
                knob.Position = UDim2.new(visualPct, -7, 0.5, -7)
                valLbl.Text   = FormatValue(value)
                pcall(callback, value)
            end

            -- Set initial visual
            do
                local initPct = (value - min) / math.max(max - min, 0.0001)
                fill.Size     = UDim2.new(initPct, 0, 1, 0)
                knob.Position = UDim2.new(initPct, -7, 0.5, -7)
            end

            BindSliderDrag(track, hitArea, UpdateSlider, decimals)

            local Slider = {}
            function Slider:Set(v)
                local pct = (math.clamp(v, min, max) - min) / math.max(max - min, 0.0001)
                UpdateSlider(pct)
            end
            function Slider:Get() return value end
            function Slider:SetMin(v) min = v ; self:Set(value) end
            function Slider:SetMax(v) max = v ; self:Set(value) end
            function Slider:SetLabel(str) lbl.Text = str end
            return Slider
        end

        -- ── TEXTBOX ──────────────────────────────────────────
        function Tab:AddTextBox(opts)
            opts = opts or {}
            local T            = self._T
            local label        = opts.Label        or "Input"
            local placeholder  = opts.Placeholder  or "Enter text..."
            local default      = opts.Default      or ""
            local callback     = opts.Callback     or function() end
            local clearOnFocus = opts.ClearOnFocus ~= false
            local isPassword   = opts.IsPassword   == true

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,60), nil, T.Card, "TBCard")
            card.LayoutOrder = self._nextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.72)
            MakePadding(card, 10, 8, 14, 14)

            local lbl = NewLabel(card, label, UDim2.new(1,0,0,16), T.TextMuted, "Lbl", Enum.Font.GothamSemibold, 11)

            local inputBg = NewFrame(card, UDim2.new(1,0,0,28), UDim2.new(0,0,0,20), T.Panel, "InputBg")
            MakeRound(inputBg, 6)
            local inputStroke = MakeStroke(inputBg, T.Border, 1, 0.45)

            local tb = Instance.new("TextBox")
            tb.Size                   = UDim2.new(1,0,1,0)
            tb.BackgroundTransparency = 1
            tb.TextColor3             = T.Text
            tb.PlaceholderColor3      = T.TextDim
            tb.PlaceholderText        = placeholder
            tb.Font                   = Enum.Font.Gotham
            tb.TextSize               = 12
            tb.Text                   = default
            tb.ClearTextOnFocus       = clearOnFocus
            tb.TextXAlignment         = Enum.TextXAlignment.Left
            if isPassword then tb.TextTransparency = 1 end -- mask text
            tb.Parent                 = inputBg
            MakePadding(tb, 0, 0, 8, 8)

            -- Password masking overlay
            if isPassword then
                local maskLbl = NewLabel(inputBg, string.rep("●", #default), UDim2.new(1,0,1,0), T.Text, "Mask", Enum.Font.Gotham, 12)
                maskLbl.Position = UDim2.new(0,8,0,0)
                tb:GetPropertyChangedSignal("Text"):Connect(function()
                    maskLbl.Text = string.rep("●", #tb.Text)
                end)
            end

            tb.Focused:Connect(function()
                Tween(inputBg, {BackgroundColor3 = T.Card}, 0.15)
                inputStroke.Color        = T.Accent
                inputStroke.Transparency = 0.35
                Tween(lbl, {TextColor3 = T.Accent}, 0.15)
            end)
            tb.FocusLost:Connect(function(enter)
                Tween(inputBg, {BackgroundColor3 = T.Panel}, 0.15)
                inputStroke.Color        = T.Border
                inputStroke.Transparency = 0.45
                Tween(lbl, {TextColor3 = T.TextMuted}, 0.15)
                local ok, err = pcall(callback, tb.Text, enter)
                if not ok then warn("[NexusLib] TextBox callback error: " .. tostring(err)) end
            end)

            local TB = {}
            function TB:Set(v)
                tb.Text = v
            end
            function TB:Get()
                return tb.Text
            end
            function TB:SetLabel(str) lbl.Text = str end
            function TB:SetPlaceholder(str) tb.PlaceholderText = str end
            return TB
        end

        -- ── DROPDOWN ─────────────────────────────────────────
        function Tab:AddDropdown(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Dropdown"
            local options  = opts.Options  or {}
            local default  = opts.Default
            local callback = opts.Callback or function() end
            local multi    = opts.Multi    == true

            -- Selected state
            local selected
            if multi then
                selected = {}
                if default then selected[default] = true end
            else
                selected = default or (options[1] or "Select...")
            end

            local function GetDisplayText()
                if multi then
                    local keys = {}
                    for k,v in pairs(selected) do if v then table.insert(keys, k) end end
                    table.sort(keys)
                    return #keys == 0 and "None selected" or table.concat(keys, ", ")
                else
                    return tostring(selected)
                end
            end

            local isOpen   = false
            local menuFrame = nil
            local outsideConn = nil

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,60), nil, T.Card, "DDCard")
            card.LayoutOrder      = self._nextOrder()
            card.ClipsDescendants = false
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.72)
            MakePadding(card, 10, 8, 14, 14)

            local lbl = NewLabel(card, label, UDim2.new(1,0,0,16), T.TextMuted, "Lbl", Enum.Font.GothamSemibold, 11)

            local trigger = NewButton(card, UDim2.new(1,0,0,28), UDim2.new(0,0,0,20), T.Panel, "Trigger")
            MakeRound(trigger, 6)
            MakeStroke(trigger, T.Border, 1, 0.45)
            MakePadding(trigger, 0, 0, 10, 30)

            local trigLbl = NewLabel(trigger, GetDisplayText(), UDim2.new(1,0,1,0), T.Text, "TrigLbl", Enum.Font.Gotham, 12)
            trigLbl.TextTruncate = Enum.TextTruncate.AtEnd

            local arrowLbl = NewLabel(trigger, "▾", UDim2.new(0,22,1,0), T.TextMuted, "Arrow", Enum.Font.GothamBold, 12)
            arrowLbl.Position       = UDim2.new(1,-24,0,0)
            arrowLbl.TextXAlignment = Enum.TextXAlignment.Center

            local function CloseMenu()
                if menuFrame and menuFrame.Parent then
                    Tween(menuFrame, {BackgroundTransparency = 1, Size = UDim2.new(menuFrame.Size.X.Scale, menuFrame.Size.X.Offset, 0,0)}, 0.18)
                    task.delay(0.20, function() if menuFrame then menuFrame:Destroy() menuFrame = nil end end)
                end
                isOpen = false
                Tween(arrowLbl, {Rotation = 0}, 0.2)
                if outsideConn then outsideConn:Disconnect() outsideConn = nil end
            end

            local function BuildItem(parent, opt)
                local isSelected = multi and (selected[opt] == true) or (not multi and selected == opt)
                local item = NewButton(parent, UDim2.new(1,0,0,30), nil, T.Panel, "Item_"..opt)
                MakeRound(item, 6)
                MakePadding(item, 0, 0, 10, 10)

                local checkMark = NewLabel(item, isSelected and "✓" or "", UDim2.new(0,16,1,0), T.Accent, "Check", Enum.Font.GothamBold, 11)
                checkMark.TextXAlignment = Enum.TextXAlignment.Center

                local itemLbl = NewLabel(item, opt, UDim2.new(1,-20,1,0), isSelected and T.Accent or T.Text, "Lbl", Enum.Font.Gotham, 12)
                itemLbl.Position = UDim2.new(0,18,0,0)

                item.MouseEnter:Connect(function() Tween(item, {BackgroundColor3 = T.Card}, 0.1) end)
                item.MouseLeave:Connect(function() Tween(item, {BackgroundColor3 = T.Panel}, 0.1) end)

                item.MouseButton1Click:Connect(function()
                    if multi then
                        selected[opt] = not selected[opt] or nil
                        local sel = selected[opt]
                        checkMark.Text    = sel and "✓" or ""
                        Tween(itemLbl, {TextColor3 = sel and T.Accent or T.Text}, 0.12)
                        trigLbl.Text = GetDisplayText()
                        pcall(callback, selected)
                    else
                        selected     = opt
                        trigLbl.Text = opt
                        CloseMenu()
                        pcall(callback, opt)
                    end
                end)
                return item
            end

            local function OpenMenu()
                isOpen = true
                Tween(arrowLbl, {Rotation = 180}, 0.2)

                local maxVisible  = 6
                local itemH       = 32
                local menuH       = math.min(#options, maxVisible) * itemH + 10
                local needsScroll = #options > maxVisible

                menuFrame = NewFrame(card, UDim2.new(1,0,0,0), UDim2.new(0,0,0,60), T.Panel, "Menu")
                menuFrame.BackgroundTransparency = 0
                menuFrame.ZIndex              = 20
                menuFrame.ClipsDescendants    = true
                MakeRound(menuFrame, 8)
                MakeStroke(menuFrame, T.Border, 1, 0.4)

                -- Animate open
                Tween(menuFrame, {Size = UDim2.new(1,0,0,menuH)}, 0.2, Enum.EasingStyle.Quart)

                local itemParent = menuFrame
                if needsScroll then
                    local sf = Instance.new("ScrollingFrame")
                    sf.Size                   = UDim2.new(1,0,1,0)
                    sf.BackgroundTransparency = 1
                    sf.BorderSizePixel        = 0
                    sf.ScrollBarThickness     = 3
                    sf.ScrollBarImageColor3   = T.Scrollbar
                    sf.CanvasSize             = UDim2.new(0,0,0,#options * itemH + 10)
                    sf.Parent                 = menuFrame
                    itemParent = sf
                end

                local itemLayout = Instance.new("UIListLayout")
                itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
                itemLayout.Padding   = UDim.new(0, 2)
                itemLayout.Parent    = itemParent
                MakePadding(itemParent, 4, 4, 4, 4)

                for i, opt in ipairs(options) do
                    local item = BuildItem(itemParent, opt)
                    item.LayoutOrder = i
                end

                -- Close when clicking outside
                task.wait()
                outsideConn = UserInputService.InputBegan:Connect(function(i)
                    if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    task.wait()
                    -- Check if click was inside the menu
                    local mPos = UserInputService:GetMouseLocation()
                    if not menuFrame or not menuFrame.Parent then return end
                    local mAbs = menuFrame.AbsolutePosition
                    local mSiz = menuFrame.AbsoluteSize
                    local inside = mPos.X >= mAbs.X and mPos.X <= mAbs.X + mSiz.X
                                and mPos.Y >= mAbs.Y and mPos.Y <= mAbs.Y + mSiz.Y
                    if not inside then CloseMenu() end
                end)
            end

            trigger.MouseButton1Click:Connect(function()
                if isOpen then CloseMenu() else OpenMenu() end
            end)

            trigger.MouseEnter:Connect(function()
                Tween(trigger, {BackgroundColor3 = T.Card}, 0.12)
            end)
            trigger.MouseLeave:Connect(function()
                Tween(trigger, {BackgroundColor3 = T.Panel}, 0.12)
            end)

            local DD = {}
            function DD:Set(v)
                if multi then
                    selected = type(v) == "table" and v or {}
                else
                    selected = v
                end
                trigLbl.Text = GetDisplayText()
            end
            function DD:Get() return selected end
            function DD:SetOptions(newOpts)
                options = newOpts
                if not multi then
                    if not table.find(options, selected) then
                        selected     = options[1] or "Select..."
                        trigLbl.Text = selected
                    end
                end
            end
            function DD:SetLabel(str) lbl.Text = str end
            function DD:Close() CloseMenu() end
            return DD
        end

        -- ── KEYBIND ──────────────────────────────────────────
        function Tab:AddKeybind(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Keybind"
            local default  = opts.Default  or Enum.KeyCode.Unknown
            local callback = opts.Callback or function() end

            local key      = default
            local listening = false
            local listenConn = nil

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,38), nil, T.Card, "KBCard")
            card.LayoutOrder = self._nextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.72)
            MakePadding(card, 0, 0, 14, 14)

            local lbl = NewLabel(card, label, UDim2.new(1,-90,1,0), T.Text, "Lbl", Enum.Font.GothamSemibold, 13)

            local keyBtn = NewButton(card, UDim2.new(0,78,0,24), UDim2.new(1,-80,0.5,-12), T.Panel, "KeyBtn")
            MakeRound(keyBtn, 6)
            MakeStroke(keyBtn, T.Border, 1, 0.45)

            local keyLbl = NewLabel(keyBtn, key == Enum.KeyCode.Unknown and "None" or key.Name,
                UDim2.new(1,0,1,0), T.Accent, "KLbl", Enum.Font.GothamBold, 11)
            keyLbl.TextXAlignment = Enum.TextXAlignment.Center

            keyBtn.MouseEnter:Connect(function() Tween(keyBtn, {BackgroundColor3 = T.Card}, 0.12) end)
            keyBtn.MouseLeave:Connect(function() Tween(keyBtn, {BackgroundColor3 = T.Panel}, 0.12) end)

            keyBtn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                keyLbl.Text      = "..."
                keyLbl.TextColor3 = T.Warning
                Tween(keyBtn, {BackgroundColor3 = T.AccentDim}, 0.15)

                if listenConn then listenConn:Disconnect() end
                listenConn = UserInputService.InputBegan:Connect(function(i, gpe)
                    if gpe then return end
                    if i.UserInputType == Enum.UserInputType.Keyboard then
                        if i.KeyCode == Enum.KeyCode.Escape then
                            -- Cancel
                            key              = Enum.KeyCode.Unknown
                            keyLbl.Text      = "None"
                            keyLbl.TextColor3 = T.TextMuted
                        else
                            key              = i.KeyCode
                            keyLbl.Text      = key.Name
                            keyLbl.TextColor3 = T.Accent
                        end
                        listening = false
                        Tween(keyBtn, {BackgroundColor3 = T.Panel}, 0.15)
                        listenConn:Disconnect()
                        listenConn = nil
                    end
                end)
            end)

            -- Global trigger listener (separate, persistent)
            UserInputService.InputBegan:Connect(function(i, gpe)
                if gpe or listening then return end
                if i.UserInputType == Enum.UserInputType.Keyboard
                and i.KeyCode == key and key ~= Enum.KeyCode.Unknown then
                    pcall(callback)
                end
            end)

            local KB = {}
            function KB:Set(k)
                key          = k
                keyLbl.Text  = k == Enum.KeyCode.Unknown and "None" or k.Name
                keyLbl.TextColor3 = k == Enum.KeyCode.Unknown and T.TextMuted or T.Accent
            end
            function KB:Get() return key end
            function KB:SetLabel(str) lbl.Text = str end
            return KB
        end

        -- ── COLOR PICKER ─────────────────────────────────────
        function Tab:AddColorPicker(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Color"
            local default  = opts.Default  or Color3.fromRGB(99, 102, 241)
            local callback = opts.Callback or function() end

            local color     = default
            local h, s, v   = Color3.toHSV(color)
            local isOpen    = false
            local pickerFrame = nil

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,38), nil, T.Card, "CPCard")
            card.LayoutOrder = self._nextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.72)
            MakePadding(card, 0, 0, 14, 14)

            local lbl = NewLabel(card, label, UDim2.new(1,-54,1,0), T.Text, "Lbl", Enum.Font.GothamSemibold, 13)

            -- Preview swatch
            local swatch = NewButton(card, UDim2.new(0,40,0,24), UDim2.new(1,-42,0.5,-12), color, "Swatch")
            MakeRound(swatch, 6)
            MakeStroke(swatch, T.Border, 1, 0.3)

            -- Hex label overlay on swatch
            local hexLbl = NewLabel(swatch, "", UDim2.new(1,0,1,0), Color3.new(1,1,1), "Hex", Enum.Font.GothamBold, 7)
            hexLbl.TextXAlignment = Enum.TextXAlignment.Center
            hexLbl.TextStrokeTransparency = 0.3

            local function ColorToHex(c)
                return string.format("%02X%02X%02X",
                    math.round(c.R*255),
                    math.round(c.G*255),
                    math.round(c.B*255))
            end

            local function UpdateSwatch()
                swatch.BackgroundColor3 = color
                hexLbl.Text = "#"..ColorToHex(color)
            end
            UpdateSwatch()

            local function BuildPickerPanel()
                pickerFrame = NewFrame(card, UDim2.new(1,0,0,0), UDim2.new(0,0,0,38), T.Panel, "Picker")
                pickerFrame.ClipsDescendants = true
                pickerFrame.ZIndex = 5
                MakeRound(pickerFrame, 8)
                MakeStroke(pickerFrame, T.Border, 1, 0.45)
                MakePadding(pickerFrame, 10, 10, 10, 10)

                Tween(pickerFrame, {Size = UDim2.new(1,0,0,168)}, 0.22, Enum.EasingStyle.Quart)
                Tween(card, {Size = UDim2.new(1,0,0,38+178)}, 0.22, Enum.EasingStyle.Quart)

                local pickerLayout = Instance.new("UIListLayout")
                pickerLayout.SortOrder = Enum.SortOrder.LayoutOrder
                pickerLayout.Padding   = UDim.new(0, 8)
                pickerLayout.Parent    = pickerFrame

                -- HSV sliders
                local sliderDefs = {
                    { name = "H", color = T.Accent,   getter = function() return h end, setter = function(p) h = p end },
                    { name = "S", color = T.Success,  getter = function() return s end, setter = function(p) s = p end },
                    { name = "V", color = T.TextMuted, getter = function() return v end, setter = function(p) v = p end },
                }

                local function RebuildColor()
                    color = Color3.fromHSV(h, s, v)
                    UpdateSwatch()
                    pcall(callback, color)
                end

                for i, def in ipairs(sliderDefs) do
                    local row = NewFrame(pickerFrame, UDim2.new(1,0,0,32), nil, T.Panel, def.name.."Row")
                    row.BackgroundTransparency = 1
                    row.LayoutOrder = i

                    local rowLbl = NewLabel(row, def.name, UDim2.new(0,14,1,0), T.TextMuted, "L", Enum.Font.GothamBold, 10)
                    rowLbl.TextXAlignment = Enum.TextXAlignment.Center

                    local track = NewFrame(row, UDim2.new(1,-22,0,6), UDim2.new(0,20,0.5,-3), T.Card, "Track")
                    MakeRound(track, 3)
                    local fill = NewFrame(track, UDim2.new(def.getter(),0,1,0), UDim2.new(0,0,0,0), def.color, "Fill")
                    fill.BackgroundTransparency = 0.3
                    MakeRound(fill, 3)
                    local knob2 = NewFrame(track, UDim2.new(0,12,0,12), UDim2.new(def.getter(),-6,0.5,-6), Color3.new(1,1,1), "Knob")
                    MakeRound(knob2, 6)
                    MakeStroke(knob2, Color3.new(0,0,0), 1, 0.7)
                    local hitArea2 = NewButton(track, UDim2.new(1,0,0,20), UDim2.new(0,0,0.5,-10), Color3.new(0,0,0), "Hit")
                    hitArea2.BackgroundTransparency = 1

                    local capturedDef = def
                    local capturedFill = fill
                    local capturedKnob = knob2

                    BindSliderDrag(track, hitArea2, function(pct)
                        capturedDef.setter(pct)
                        capturedFill.Size     = UDim2.new(pct, 0, 1, 0)
                        capturedKnob.Position = UDim2.new(pct,-6, 0.5,-6)
                        RebuildColor()
                    end, 2)
                end

                -- Hex input row
                local hexRow = NewFrame(pickerFrame, UDim2.new(1,0,0,28), nil, T.Panel, "HexRow")
                hexRow.BackgroundTransparency = 1
                hexRow.LayoutOrder = 10

                local hexLabel = NewLabel(hexRow, "HEX", UDim2.new(0,30,1,0), T.TextMuted, "L", Enum.Font.GothamBold, 9)
                hexLabel.TextXAlignment = Enum.TextXAlignment.Center

                local hexBg = NewFrame(hexRow, UDim2.new(1,-38,0,24), UDim2.new(0,36,0.5,-12), T.Card, "HexBg")
                MakeRound(hexBg, 5)
                MakeStroke(hexBg, T.Border, 1, 0.45)

                local hexTB = Instance.new("TextBox")
                hexTB.Size                   = UDim2.new(1,0,1,0)
                hexTB.BackgroundTransparency = 1
                hexTB.TextColor3             = T.Text
                hexTB.Font                   = Enum.Font.GothamBold
                hexTB.TextSize               = 11
                hexTB.Text                   = ColorToHex(color)
                hexTB.PlaceholderText        = "RRGGBB"
                hexTB.ClearTextOnFocus       = true
                hexTB.TextXAlignment         = Enum.TextXAlignment.Center
                hexTB.Parent                 = hexBg
                MakePadding(hexTB, 0, 0, 4, 4)

                hexTB.FocusLost:Connect(function()
                    local hex = hexTB.Text:gsub("#",""):upper()
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1,2), 16)
                        local g = tonumber(hex:sub(3,4), 16)
                        local b = tonumber(hex:sub(5,6), 16)
                        if r and g and b then
                            color = Color3.fromRGB(r,g,b)
                            h, s, v = Color3.toHSV(color)
                            UpdateSwatch()
                            pcall(callback, color)
                        end
                    end
                    hexTB.Text = ColorToHex(color)
                end)
            end

            local function DestroyPicker()
                if pickerFrame then
                    Tween(pickerFrame, {Size = UDim2.new(1,0,0,0)}, 0.18)
                    Tween(card, {Size = UDim2.new(1,0,0,38)}, 0.18)
                    task.delay(0.2, function() if pickerFrame then pickerFrame:Destroy() pickerFrame = nil end end)
                end
            end

            swatch.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then BuildPickerPanel() else DestroyPicker() end
            end)
            swatch.MouseEnter:Connect(function()
                Tween(swatch, {BackgroundTransparency = 0.15}, 0.12)
            end)
            swatch.MouseLeave:Connect(function()
                Tween(swatch, {BackgroundTransparency = 0}, 0.12)
            end)

            local CP = {}
            function CP:Set(c)
                color = c
                h, s, v = Color3.toHSV(c)
                UpdateSwatch()
                pcall(callback, c)
            end
            function CP:Get() return color end
            function CP:SetLabel(str) lbl.Text = str end
            return CP
        end

        -- ── LABEL ────────────────────────────────────────────
        function Tab:AddLabel(opts)
            opts = opts or {}
            local T     = self._T
            local text  = opts.Text  or "Label"
            local color = opts.Color or T.TextMuted

            local lbl = NewLabel(self._scroll, text, UDim2.new(1,0,0,0), color, "InfoLbl", Enum.Font.Gotham, 12)
            lbl.AutomaticSize = Enum.AutomaticSize.Y
            lbl.TextWrapped   = true
            lbl.LayoutOrder   = self._nextOrder()
            MakePadding(lbl, 2, 2, 4, 4)

            local L = {}
            function L:Set(t)    lbl.Text      = t end
            function L:SetColor(c) lbl.TextColor3 = c end
            return L
        end

        -- ── SEPARATOR ────────────────────────────────────────
        function Tab:AddSeparator()
            local T   = self._T
            local sep = NewFrame(self._scroll, UDim2.new(1,0,0,1), nil, T.Border, "Sep")
            sep.BackgroundTransparency = 0.55
            sep.LayoutOrder            = self._nextOrder()
        end

        -- ── PARAGRAPH ────────────────────────────────────────
        function Tab:AddParagraph(opts)
            opts = opts or {}
            local T     = self._T
            local ttl   = opts.Title or ""
            local body  = opts.Body  or ""

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,0), nil, T.Card, "ParaCard")
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.LayoutOrder   = self._nextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.72)
            MakePadding(card, 10, 10, 14, 14)

            local innerLayout = Instance.new("UIListLayout")
            innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            innerLayout.Padding   = UDim.new(0, 4)
            innerLayout.Parent    = card

            local titleLbl = nil
            if ttl ~= "" then
                titleLbl = NewLabel(card, ttl, UDim2.new(1,0,0,16), T.Text, "ParaTitle", Enum.Font.GothamBold, 13)
                titleLbl.LayoutOrder = 1
            end

            local bodyLbl = NewLabel(card, body, UDim2.new(1,0,0,0), T.TextMuted, "ParaBody", Enum.Font.Gotham, 12)
            bodyLbl.AutomaticSize  = Enum.AutomaticSize.Y
            bodyLbl.TextWrapped    = true
            bodyLbl.LayoutOrder    = 2

            local P = {}
            function P:SetTitle(t) if titleLbl then titleLbl.Text = t end end
            function P:SetBody(t)  bodyLbl.Text = t end
            return P
        end

        -- ── PROGRESS BAR ─────────────────────────────────────
        function Tab:AddProgressBar(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Progress"
            local min      = opts.Min      or 0
            local max      = opts.Max      or 100
            local default  = opts.Default  or min
            local suffix   = opts.Suffix   or "%"
            local callback = opts.Callback or function() end
            local value    = math.clamp(default, min, max)

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,50), nil, T.Card, "PBCard")
            card.LayoutOrder = self._nextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.72)
            MakePadding(card, 10, 10, 14, 14)

            local topRow = NewFrame(card, UDim2.new(1,0,0,16), UDim2.new(0,0,0,0), T.Card, "TopRow")
            topRow.BackgroundTransparency = 1

            local lbl = NewLabel(topRow, label, UDim2.new(0.7,0,1,0), T.Text, "Lbl", Enum.Font.GothamSemibold, 13)
            local valLbl = NewLabel(topRow, tostring(value)..suffix, UDim2.new(0.3,0,1,0), T.Accent, "Val", Enum.Font.GothamBold, 13)
            valLbl.Position       = UDim2.new(0.7,0,0,0)
            valLbl.TextXAlignment = Enum.TextXAlignment.Right

            -- Track
            local track = NewFrame(card, UDim2.new(1,0,0,8), UDim2.new(0,0,0,24), T.Panel, "Track")
            MakeRound(track, 4)

            local fill = NewFrame(track, UDim2.new(0,0,1,0), UDim2.new(0,0,0,0), T.Accent, "Fill")
            fill.BackgroundTransparency = 0.15
            MakeRound(fill, 4)

            -- Shimmer effect inside fill
            local shimmer = NewFrame(fill, UDim2.new(0,40,1,0), UDim2.new(-0.2,0,0,0), Color3.new(1,1,1), "Shimmer")
            shimmer.BackgroundTransparency = 0.8
            MakeRound(shimmer, 2)

            -- Animate shimmer continuously
            task.spawn(function()
                while fill and fill.Parent do
                    Tween(shimmer, {Position = UDim2.new(1.2,0,0,0)}, 1.2, Enum.EasingStyle.Sine)
                    task.wait(2.0)
                    shimmer.Position = UDim2.new(-0.2,0,0,0)
                end
            end)

            local function UpdateProgress(newVal)
                value = math.clamp(newVal, min, max)
                local pct = (value - min) / math.max(max - min, 0.0001)
                Tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.35, Enum.EasingStyle.Quart)
                valLbl.Text = tostring(math.round(value)) .. suffix
                pcall(callback, value)
            end
            UpdateProgress(value)

            local PB = {}
            function PB:Set(v)     UpdateProgress(v) end
            function PB:Get()      return value end
            function PB:SetMin(v)  min = v ; UpdateProgress(value) end
            function PB:SetMax(v)  max = v ; UpdateProgress(value) end
            function PB:SetLabel(str) lbl.Text = str end
            function PB:Animate(target, duration)
                duration = duration or 1
                local startVal = value
                local startTime = tick()
                task.spawn(function()
                    while tick() - startTime < duration do
                        local elapsed = tick() - startTime
                        local t = elapsed / duration
                        t = t * t * (3 - 2*t) -- smoothstep
                        local current = startVal + (target - startVal) * t
                        UpdateProgress(current)
                        task.wait()
                    end
                    UpdateProgress(target)
                end)
            end
            return PB
        end

        -- ── GRID (option grid / button grid) ─────────────────
        function Tab:AddGrid(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Grid"
            local options  = opts.Options  or {}
            local callback = opts.Callback or function() end
            local multi    = opts.Multi    == true
            local columns  = opts.Columns  or 3

            local selected = {}

            local rows = math.ceil(#options / columns)
            local cardH = 28 + rows * 34 + (rows-1)*4 + 16

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,cardH), nil, T.Card, "GridCard")
            card.LayoutOrder = self._nextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.72)
            MakePadding(card, 10, 10, 14, 14)

            local lbl = NewLabel(card, label, UDim2.new(1,0,0,18), T.TextMuted, "Lbl", Enum.Font.GothamSemibold, 11)

            local grid = NewFrame(card, UDim2.new(1,0,0,cardH-34), UDim2.new(0,0,0,22), T.Card, "Grid")
            grid.BackgroundTransparency = 1

            local gridLayout = Instance.new("UIGridLayout")
            gridLayout.CellSize    = UDim2.new(1/columns, -4, 0, 30)
            gridLayout.CellPadding = UDim2.new(0, 4, 0, 4)
            gridLayout.SortOrder   = Enum.SortOrder.LayoutOrder
            gridLayout.Parent      = grid

            local items = {}

            for i, opt in ipairs(options) do
                local item = NewButton(grid, UDim2.new(0,0,0,30), nil, T.Panel, "GridItem_"..i)
                item.LayoutOrder = i
                MakeRound(item, 6)
                MakeStroke(item, T.Border, 1, 0.5)

                local itemLbl = NewLabel(item, tostring(opt), UDim2.new(1,0,1,0), T.TextMuted, "L", Enum.Font.GothamSemibold, 11)
                itemLbl.TextXAlignment = Enum.TextXAlignment.Center

                local function SetActive(active)
                    if active then
                        Tween(item,    {BackgroundColor3 = T.AccentDim}, 0.15)
                        Tween(itemLbl, {TextColor3 = T.Text}, 0.15)
                        MakeStroke(item, T.Accent, 1, 0.3)
                    else
                        Tween(item,    {BackgroundColor3 = T.Panel}, 0.15)
                        Tween(itemLbl, {TextColor3 = T.TextMuted}, 0.15)
                        MakeStroke(item, T.Border, 1, 0.5)
                    end
                end

                item.MouseEnter:Connect(function()
                    if not selected[opt] then Tween(item, {BackgroundColor3 = T.Card}, 0.1) end
                end)
                item.MouseLeave:Connect(function()
                    if not selected[opt] then Tween(item, {BackgroundColor3 = T.Panel}, 0.1) end
                end)

                item.MouseButton1Click:Connect(function()
                    if multi then
                        selected[opt] = not selected[opt]
                        SetActive(selected[opt])
                        local active = {}
                        for k,vv in pairs(selected) do if vv then table.insert(active, k) end end
                        pcall(callback, active)
                    else
                        -- Deselect all others
                        for _, other in ipairs(items) do
                            if other.opt ~= opt then
                                selected[other.opt] = false
                                other.setActive(false)
                            end
                        end
                        selected[opt] = true
                        SetActive(true)
                        pcall(callback, opt)
                    end
                end)

                table.insert(items, { opt = opt, btn = item, setActive = SetActive })
            end

            local Grid = {}
            function Grid:Set(v)
                if multi then
                    for k in pairs(selected) do selected[k] = false end
                    if type(v) == "table" then
                        for _, k in ipairs(v) do selected[k] = true end
                    end
                    for _, it in ipairs(items) do it.setActive(selected[it.opt] == true) end
                else
                    for _, it in ipairs(items) do
                        selected[it.opt] = (it.opt == v)
                        it.setActive(it.opt == v)
                    end
                end
            end
            function Grid:Get()
                if multi then
                    local out = {}
                    for k,vv in pairs(selected) do if vv then table.insert(out, k) end end
                    return out
                else
                    for k,vv in pairs(selected) do if vv then return k end end
                    return nil
                end
            end
            return Grid
        end

        -- ── SPACER ───────────────────────────────────────────
        function Tab:AddSpacer(height)
            height = height or 8
            local spacer = NewFrame(self._scroll, UDim2.new(1,0,0,height), nil, T.Background, "Spacer")
            spacer.BackgroundTransparency = 1
            spacer.LayoutOrder = self._nextOrder()
        end

        -- ── ALERT / CALLOUT ──────────────────────────────────
        function Tab:AddAlert(opts)
            opts = opts or {}
            local T       = self._T
            local text    = opts.Text  or "Alert"
            local atype   = opts.Type  or "Info" -- Info, Success, Warning, Error
            local title   = opts.Title or nil

            local accentColor = T.Accent
            local icon = "ℹ"
            if atype == "Success" then accentColor = T.Success ; icon = "✓"
            elseif atype == "Warning" then accentColor = T.Warning ; icon = "⚠"
            elseif atype == "Error"   then accentColor = T.Danger  ; icon = "✕"
            end

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,0), nil, T.Panel, "AlertCard")
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.LayoutOrder   = self._nextOrder()
            MakeRound(card, 8)
            MakeStroke(card, accentColor, 1, 0.55)

            -- Left accent bar
            local bar = NewFrame(card, UDim2.new(0,3,1,0), UDim2.new(0,0,0,0), accentColor, "Bar")
            bar.BackgroundTransparency = 0.2
            MakeRound(bar, 2)

            local inner = NewFrame(card, UDim2.new(1,-14,0,0), UDim2.new(0,14,0,0), T.Panel, "Inner")
            inner.AutomaticSize       = Enum.AutomaticSize.Y
            inner.BackgroundTransparency = 1
            MakePadding(inner, 8, 8, 0, 6)

            local innerLayout = Instance.new("UIListLayout")
            innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            innerLayout.Padding   = UDim.new(0, 3)
            innerLayout.Parent    = inner

            local iconRow = NewFrame(inner, UDim2.new(1,0,0,16), nil, T.Panel, "IconRow")
            iconRow.BackgroundTransparency = 1
            iconRow.LayoutOrder = 1

            local iconL = NewLabel(iconRow, icon, UDim2.new(0,16,1,0), accentColor, "Icon", Enum.Font.GothamBold, 12)
            iconL.TextXAlignment = Enum.TextXAlignment.Center

            if title then
                local titleL = NewLabel(iconRow, title, UDim2.new(1,-18,1,0), T.Text, "T", Enum.Font.GothamBold, 12)
                titleL.Position = UDim2.new(0,18,0,0)
            end

            local bodyL = NewLabel(inner, text, UDim2.new(1,0,0,0), T.TextMuted, "Body", Enum.Font.Gotham, 11)
            bodyL.AutomaticSize = Enum.AutomaticSize.Y
            bodyL.TextWrapped   = true
            bodyL.LayoutOrder   = 2

            local A = {}
            function A:SetText(t) bodyL.Text = t end
            function A:SetTitle(t) if title then iconRow:FindFirstChild("T").Text = t end end
            return A
        end

        table.insert(self._tabs, Tab)
        return Tab
    end -- end AddTab

    return Window
end -- end CreateWindow

-- ============================================================
--  LIBRARY META
-- ============================================================
NexusLib.Version = "1.1.0"
NexusLib.Themes  = Themes

function NexusLib:GetThemeNames()
    local names = {}
    for k in pairs(Themes) do table.insert(names, k) end
    table.sort(names)
    return names
end

function NexusLib:AddTheme(name, themeTable)
    assert(type(name) == "string", "Theme name must be a string")
    assert(type(themeTable) == "table", "Theme must be a table")
    Themes[name] = themeTable
end

return NexusLib
