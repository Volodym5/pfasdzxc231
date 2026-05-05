--[[
    NexusLib - A Modern Roblox UI Library
    Version: 1.0.0
    
    Usage:
        local NexusLib = loadstring(game:HttpGet("your_url"))()
        local Window = NexusLib:CreateWindow({
            Title = "My Script",
            Subtitle = "v1.0",
            Theme = "Dark", -- "Dark", "Light", "Ocean", "Crimson"
        })
        local Tab = Window:AddTab("Main", "rbxassetid://...")
        Tab:AddButton({ Label = "Click Me", Callback = function() print("Clicked!") end })
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
local Mouse       = LocalPlayer:GetMouse()

-- ============================================================
--  THEMES
-- ============================================================
local Themes = {
    Dark = {
        Background    = Color3.fromRGB(15,  15,  20),
        Surface       = Color3.fromRGB(22,  22,  30),
        Panel         = Color3.fromRGB(28,  28,  38),
        Card          = Color3.fromRGB(35,  35,  48),
        Accent        = Color3.fromRGB(99,  102, 241),
        AccentHover   = Color3.fromRGB(129, 132, 255),
        AccentDim     = Color3.fromRGB(60,  63,  160),
        Text          = Color3.fromRGB(240, 240, 255),
        TextMuted     = Color3.fromRGB(140, 140, 170),
        TextDim       = Color3.fromRGB(80,  80,  110),
        Success       = Color3.fromRGB(52,  211, 153),
        Warning       = Color3.fromRGB(251, 191, 36),
        Danger        = Color3.fromRGB(248, 113, 113),
        Border        = Color3.fromRGB(50,  50,  70),
        Toggle        = Color3.fromRGB(99,  102, 241),
        ToggleOff     = Color3.fromRGB(55,  55,  75),
        Scrollbar     = Color3.fromRGB(60,  60,  85),
    },
    Ocean = {
        Background    = Color3.fromRGB(8,   20,  35),
        Surface       = Color3.fromRGB(12,  28,  48),
        Panel         = Color3.fromRGB(16,  36,  60),
        Card          = Color3.fromRGB(20,  44,  72),
        Accent        = Color3.fromRGB(56,  189, 248),
        AccentHover   = Color3.fromRGB(100, 210, 255),
        AccentDim     = Color3.fromRGB(30,  110, 180),
        Text          = Color3.fromRGB(225, 240, 255),
        TextMuted     = Color3.fromRGB(130, 170, 210),
        TextDim       = Color3.fromRGB(70,  110, 150),
        Success       = Color3.fromRGB(52,  211, 153),
        Warning       = Color3.fromRGB(251, 191, 36),
        Danger        = Color3.fromRGB(248, 113, 113),
        Border        = Color3.fromRGB(30,  60,  90),
        Toggle        = Color3.fromRGB(56,  189, 248),
        ToggleOff     = Color3.fromRGB(25,  55,  85),
        Scrollbar     = Color3.fromRGB(40,  80,  120),
    },
    Crimson = {
        Background    = Color3.fromRGB(18,  8,   10),
        Surface       = Color3.fromRGB(28,  12,  16),
        Panel         = Color3.fromRGB(36,  15,  20),
        Card          = Color3.fromRGB(46,  18,  24),
        Accent        = Color3.fromRGB(244, 63,  94),
        AccentHover   = Color3.fromRGB(255, 100, 128),
        AccentDim     = Color3.fromRGB(160, 30,  55),
        Text          = Color3.fromRGB(255, 235, 238),
        TextMuted     = Color3.fromRGB(200, 150, 160),
        TextDim       = Color3.fromRGB(120, 70,  80),
        Success       = Color3.fromRGB(52,  211, 153),
        Warning       = Color3.fromRGB(251, 191, 36),
        Danger        = Color3.fromRGB(248, 113, 113),
        Border        = Color3.fromRGB(70,  25,  35),
        Toggle        = Color3.fromRGB(244, 63,  94),
        ToggleOff     = Color3.fromRGB(65,  20,  30),
        Scrollbar     = Color3.fromRGB(90,  30,  45),
    },
    Light = {
        Background    = Color3.fromRGB(245, 245, 250),
        Surface       = Color3.fromRGB(255, 255, 255),
        Panel         = Color3.fromRGB(240, 240, 248),
        Card          = Color3.fromRGB(250, 250, 255),
        Accent        = Color3.fromRGB(99,  102, 241),
        AccentHover   = Color3.fromRGB(79,  82,  220),
        AccentDim     = Color3.fromRGB(180, 182, 255),
        Text          = Color3.fromRGB(20,  20,  40),
        TextMuted     = Color3.fromRGB(100, 100, 130),
        TextDim       = Color3.fromRGB(160, 160, 190),
        Success       = Color3.fromRGB(16,  185, 129),
        Warning       = Color3.fromRGB(217, 119, 6),
        Danger        = Color3.fromRGB(220, 38,  38),
        Border        = Color3.fromRGB(210, 210, 230),
        Toggle        = Color3.fromRGB(99,  102, 241),
        ToggleOff     = Color3.fromRGB(180, 180, 200),
        Scrollbar     = Color3.fromRGB(190, 190, 210),
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

local function MakeStroke(obj, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color        = color or Color3.new(1,1,1)
    stroke.Thickness    = thickness or 1
    stroke.Transparency = transparency or 0.85
    stroke.Parent       = obj
    return stroke
end

local function NewFrame(parent, size, pos, color, name)
    local f = Instance.new("Frame")
    f.Size            = size  or UDim2.new(1,0,0,40)
    f.Position        = pos   or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = color or Color3.new(0,0,0)
    f.BorderSizePixel = 0
    f.Name            = name  or "Frame"
    f.Parent          = parent
    return f
end

local function NewLabel(parent, text, size, color, name, font, textSize)
    local l = Instance.new("TextLabel")
    l.Size              = size     or UDim2.new(1,0,1,0)
    l.Position          = UDim2.new(0,0,0,0)
    l.BackgroundTransparency = 1
    l.Text              = text     or ""
    l.TextColor3        = color    or Color3.new(1,1,1)
    l.Font              = font     or Enum.Font.GothamBold
    l.TextSize          = textSize or 13
    l.TextXAlignment    = Enum.TextXAlignment.Left
    l.Name              = name     or "Label"
    l.Parent            = parent
    return l
end

local function NewButton(parent, size, pos, color, name)
    local b = Instance.new("TextButton")
    b.Size            = size  or UDim2.new(1,0,0,36)
    b.Position        = pos   or UDim2.new(0,0,0,0)
    b.BackgroundColor3 = color or Color3.new(0.2,0.2,0.2)
    b.BorderSizePixel = 0
    b.Text            = ""
    b.AutoButtonColor = false
    b.Name            = name  or "Button"
    b.Parent          = parent
    return b
end

local function NewImage(parent, asset, size, pos, name)
    local img = Instance.new("ImageLabel")
    img.Size                 = size or UDim2.new(0,16,0,16)
    img.Position             = pos  or UDim2.new(0,0,0,0)
    img.BackgroundTransparency = 1
    img.Image                = asset or ""
    img.Name                 = name  or "Icon"
    img.Parent               = parent
    return img
end

-- Dragging utility
local function MakeDraggable(handle, target)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
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
    sg.Name            = "NexusNotifs"
    sg.ResetOnSpawn    = false
    sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder    = 999
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end

    local holder = NewFrame(sg, UDim2.new(0,280,1,0), UDim2.new(1,-290,0,0), Color3.new(0,0,0))
    holder.BackgroundTransparency = 1
    holder.Name = "Holder"

    local layout = Instance.new("UIListLayout")
    layout.SortOrder        = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Padding          = UDim.new(0, 8)
    layout.Parent           = holder

    MakePadding(holder, 12, 12, 0, 0)
    NotifHolder = holder
end

function NexusLib:Notify(opts)
    opts = opts or {}
    local title    = opts.Title    or "Notification"
    local message  = opts.Message  or ""
    local duration = opts.Duration or 4
    local ntype    = opts.Type     or "Info" -- Info, Success, Warning, Error
    local theme    = opts.Theme    or "Dark"
    local T        = Themes[theme] or Themes.Dark

    EnsureNotifHolder()

    local typeColor = T.Accent
    local typeIcon  = "рџ”µ"
    if ntype == "Success" then typeColor = T.Success ; typeIcon = "вњ…"
    elseif ntype == "Warning" then typeColor = T.Warning ; typeIcon = "вљ пёЏ"
    elseif ntype == "Error"   then typeColor = T.Danger  ; typeIcon = "вќЊ"
    end

    local card = NewFrame(NotifHolder, UDim2.new(1,0,0,0), UDim2.new(0,0,0,0), T.Panel, "Notif")
    card.AutomaticSize    = Enum.AutomaticSize.Y
    card.ClipsDescendants = true
    MakeRound(card, 10)
    MakeStroke(card, T.Border, 1, 0.5)

    -- Accent stripe
    local stripe = NewFrame(card, UDim2.new(0,3,1,0), UDim2.new(0,0,0,0), typeColor, "Stripe")
    MakeRound(stripe, 3)

    local inner = NewFrame(card, UDim2.new(1,-12,0,0), UDim2.new(0,12,0,0), T.Panel, "Inner")
    inner.AutomaticSize = Enum.AutomaticSize.Y
    MakePadding(inner, 10, 10, 4, 8)

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding   = UDim.new(0, 2)
    layout.Parent    = inner

    local titleLabel = NewLabel(inner, typeIcon .. "  " .. title, UDim2.new(1,0,0,18), T.Text, "Title", Enum.Font.GothamBold, 13)
    titleLabel.LayoutOrder = 1

    if message ~= "" then
        local msgLabel = NewLabel(inner, message, UDim2.new(1,0,0,0), T.TextMuted, "Msg", Enum.Font.Gotham, 11)
        msgLabel.AutomaticSize   = Enum.AutomaticSize.Y
        msgLabel.TextWrapped     = true
        msgLabel.LayoutOrder     = 2
    end

    -- Progress bar
    local barBg = NewFrame(card, UDim2.new(1,0,0,2), UDim2.new(0,0,1,-2), T.Card, "BarBg")
    local bar   = NewFrame(barBg, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), typeColor, "Bar")

    -- Animate in
    card.BackgroundTransparency = 1
    Tween(card, {BackgroundTransparency = 0}, 0.25)
    Tween(bar, {Size = UDim2.new(0,0,1,0)}, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

    task.delay(duration, function()
        Tween(card, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        card:Destroy()
    end)
end

-- ============================================================
--  WINDOW
-- ============================================================
function NexusLib:CreateWindow(opts)
    opts = opts or {}
    local title    = opts.Title    or "NexusLib"
    local subtitle = opts.Subtitle or ""
    local themeName = opts.Theme   or "Dark"
    local T = Themes[themeName] or Themes.Dark
    local size = opts.Size or UDim2.new(0, 560, 0, 400)
    local minSize = { X = 400, Y = 300 }

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name           = "NexusLib_" .. title
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 100
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end

    -- Root window frame
    local win = NewFrame(sg, size, UDim2.new(0.5,-280,0.5,-200), T.Background, "Window")
    win.ClipsDescendants = false
    MakeRound(win, 12)
    MakeStroke(win, T.Border, 1, 0.6)

    -- Drop shadow
    local shadow = NewFrame(sg, UDim2.new(0, size.X.Offset+30, 0, size.Y.Offset+30),
        UDim2.new(0.5,-295,0.5,-215), Color3.new(0,0,0), "Shadow")
    shadow.BackgroundTransparency = 0.6
    shadow.ZIndex = 0
    MakeRound(shadow, 16)

    -- в”Ђв”Ђ TITLE BAR в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    local titleBar = NewFrame(win, UDim2.new(1,0,0,50), UDim2.new(0,0,0,0), T.Surface, "TitleBar")
    MakeRound(titleBar, 12)
    -- Cover bottom corners
    local titleBarFill = NewFrame(win, UDim2.new(1,0,0,12), UDim2.new(0,0,0,38), T.Surface, "TitleFill")

    MakePadding(titleBar, 0, 0, 16, 12)
    MakeDraggable(titleBar, win)

    -- Logo / title text
    local titleLabel = NewLabel(titleBar, title, UDim2.new(0.6,0,1,0), T.Text, "Title", Enum.Font.GothamBold, 15)
    titleLabel.Position = UDim2.new(0,0,0,0)
    if subtitle ~= "" then
        local subLabel = NewLabel(titleBar, subtitle, UDim2.new(0,100,1,0), T.TextMuted, "Sub", Enum.Font.Gotham, 11)
        subLabel.Position = UDim2.new(0, #title*9 + 4, 0,0)
    end

    -- Window buttons (close / minimize)
    local btnClose = NewButton(titleBar, UDim2.new(0,18,0,18), UDim2.new(1,-20,0.5,-9), T.Danger, "Close")
    MakeRound(btnClose, 9)
    local btnMin = NewButton(titleBar, UDim2.new(0,18,0,18), UDim2.new(1,-42,0.5,-9), T.Warning, "Min")
    MakeRound(btnMin, 9)

    -- в”Ђв”Ђ SIDEBAR в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    local sidebar = NewFrame(win, UDim2.new(0,140,1,-50), UDim2.new(0,0,0,50), T.Surface, "Sidebar")
    local sidebarFill = NewFrame(win, UDim2.new(0,12,1,-50), UDim2.new(0,128,0,50), T.Surface, "SBFill")
    local sideLayout = Instance.new("UIListLayout")
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sideLayout.Padding   = UDim.new(0, 2)
    sideLayout.Parent    = sidebar
    MakePadding(sidebar, 10, 10, 8, 0)

    -- Divider line between sidebar and content
    local divider = NewFrame(win, UDim2.new(0,1,1,-50), UDim2.new(0,140,0,50), T.Border, "Divider")

    -- в”Ђв”Ђ CONTENT AREA в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    local contentArea = NewFrame(win, UDim2.new(1,-142,1,-50), UDim2.new(0,142,0,50), T.Background, "Content")
    contentArea.ClipsDescendants = true
    local contentInner = NewFrame(contentArea, UDim2.new(1,0,0,0), UDim2.new(0,0,0,0), T.Background, "Inner")
    contentInner.AutomaticSize = Enum.AutomaticSize.None

    -- в”Ђв”Ђ CLOSE / MINIMIZE LOGIC в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    local minimized = false
    local originalSize = win.Size

    btnClose.MouseButton1Click:Connect(function()
        Tween(win, {Size = UDim2.new(0,0,0,0)}, 0.25)
        task.wait(0.25)
        sg:Destroy()
    end)

    btnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(win, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 50)}, 0.3)
        else
            Tween(win, {Size = originalSize}, 0.3)
        end
    end)

    -- Hover effects for window buttons
    for _, btn in ipairs({btnClose, btnMin}) do
        local baseColor = btn.BackgroundColor3
        btn.MouseEnter:Connect(function()  Tween(btn, {BackgroundTransparency = 0.3}, 0.15) end)
        btn.MouseLeave:Connect(function()  Tween(btn, {BackgroundTransparency = 0},   0.15) end)
    end

    -- ============================================================
    --  WINDOW OBJECT
    -- ============================================================
    local Window = { _T = T, _tabs = {}, _activeTab = nil, _sidebar = sidebar, _contentArea = contentArea }

    -- в”Ђв”Ђ ADD TAB в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    function Window:AddTab(name, icon)
        local T = self._T
        local tabCount = #self._tabs + 1

        -- Sidebar button
        local tabBtn = NewButton(self._sidebar, UDim2.new(1,-8,0,34), UDim2.new(0,0,0,0), T.Panel, "Tab_" .. name)
        tabBtn.LayoutOrder = tabCount
        MakeRound(tabBtn, 7)
        MakePadding(tabBtn, 0, 0, 10, 6)

        if icon then
            local iconImg = NewImage(tabBtn, icon, UDim2.new(0,16,0,16), UDim2.new(0,0,0.5,-8), "Icon")
        end
        local offset = icon and 22 or 0
        local tabLabel = NewLabel(tabBtn, name, UDim2.new(1,-offset,1,0), T.TextMuted, "Label", Enum.Font.GothamSemibold, 12)
        tabLabel.Position = UDim2.new(0, offset, 0, 0)

        -- Tab content page
        local page = NewFrame(self._contentArea, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), T.Background, "Page_" .. name)
        page.Visible = false
        page.ClipsDescendants = true

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size                  = UDim2.new(1,0,1,0)
        scroll.Position              = UDim2.new(0,0,0,0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel       = 0
        scroll.ScrollBarThickness    = 4
        scroll.ScrollBarImageColor3  = T.Scrollbar
        scroll.CanvasSize            = UDim2.new(0,0,0,0)
        scroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
        scroll.Parent                = page

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding   = UDim.new(0, 6)
        layout.Parent    = scroll
        MakePadding(scroll, 10, 10, 12, 12)

        -- Tab selection logic
        local function Select()
            -- Deactivate previous
            if Window._activeTab then
                local prev = Window._activeTab
                Tween(prev._btn, {BackgroundColor3 = T.Panel, BackgroundTransparency = 1}, 0.2)
                Tween(prev._lbl, {TextColor3 = T.TextMuted}, 0.2)
                prev._page.Visible = false
            end
            -- Activate this
            Tween(tabBtn, {BackgroundColor3 = T.Accent, BackgroundTransparency = 0}, 0.2)
            Tween(tabLabel, {TextColor3 = T.Text}, 0.2)
            page.Visible = true
            Window._activeTab = { _btn = tabBtn, _lbl = tabLabel, _page = page }
        end

        tabBtn.BackgroundTransparency = 1
        tabBtn.MouseButton1Click:Connect(Select)
        tabBtn.MouseEnter:Connect(function()
            if Window._activeTab and Window._activeTab._btn ~= tabBtn then
                Tween(tabBtn, {BackgroundTransparency = 0.7, BackgroundColor3 = T.Card}, 0.15)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if Window._activeTab and Window._activeTab._btn ~= tabBtn then
                Tween(tabBtn, {BackgroundTransparency = 1}, 0.15)
            end
        end)

        -- Auto-select first tab
        if tabCount == 1 then Select() end

        -- ============================================================
        --  TAB OBJECT (element factories)
        -- ============================================================
        local Tab = { _scroll = scroll, _T = T, _layout = layout }

        -- в”Ђв”Ђ SECTION LABEL в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
        function Tab:AddSection(name)
            local T = self._T
            local row = NewFrame(self._scroll, UDim2.new(1,0,0,24), nil, T.Background, "Section")
            row.LayoutOrder = #self._scroll:GetChildren()

            local line1 = NewFrame(row, UDim2.new(0.3,-8,0,1), UDim2.new(0,0,0.5,0), T.Border, "L1")
            local lbl   = NewLabel(row, name:upper(), UDim2.new(0.4,0,1,0), T.TextDim, "Lbl", Enum.Font.GothamBold, 9)
            lbl.Position     = UDim2.new(0.3,0,0,0)
            lbl.TextXAlignment = Enum.TextXAlignment.Center
            local line2 = NewFrame(row, UDim2.new(0.3,-8,0,1), UDim2.new(0.7,8,0.5,0), T.Border, "L2")
            return row
        end

        -- в”Ђв”Ђ BUTTON в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
        function Tab:AddButton(opts)
            opts = opts or {}
            local T = self._T
            local label    = opts.Label    or "Button"
            local desc     = opts.Desc     or ""
            local callback = opts.Callback or function() end

            local card = NewFrame(self._scroll, UDim2.new(1,0,0, desc~="" and 50 or 36), nil, T.Card, "BtnCard")
            card.LayoutOrder = #self._scroll:GetChildren()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)

            local btn = NewButton(card, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), T.Card)
            MakeRound(btn, 8)
            MakePadding(btn, 0, 0, 12, 60)

            local lbl = NewLabel(btn, label, UDim2.new(1,0,0,20), T.Text, "Lbl", Enum.Font.GothamSemibold, 13)
            lbl.Position = UDim2.new(0,0,0,desc~="" and 8 or 8)
            if desc ~= "" then
                local d = NewLabel(btn, desc, UDim2.new(1,0,0,16), T.TextMuted, "Desc", Enum.Font.Gotham, 11)
                d.Position = UDim2.new(0,0,0,26)
            end

            -- Arrow icon on right
            local arrow = NewLabel(btn, "вЂє", UDim2.new(0,20,1,0), T.Accent, "Arrow", Enum.Font.GothamBold, 18)
            arrow.Position       = UDim2.new(1,-30,0,0)
            arrow.TextXAlignment = Enum.TextXAlignment.Center

            btn.MouseEnter:Connect(function()  Tween(btn, {BackgroundColor3 = T.AccentDim}, 0.15) end)
            btn.MouseLeave:Connect(function()  Tween(btn, {BackgroundColor3 = T.Card},      0.15) end)
            btn.MouseButton1Down:Connect(function() Tween(btn, {BackgroundColor3 = T.Accent}, 0.1) end)
            btn.MouseButton1Up:Connect(function()
                Tween(btn, {BackgroundColor3 = T.Card}, 0.15)
                callback()
            end)
            return card
        end

        -- в”Ђв”Ђ TOGGLE в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
        function Tab:AddToggle(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Toggle"
            local desc     = opts.Desc     or ""
            local default  = opts.Default  ~= false and opts.Default or false
            local callback = opts.Callback or function() end

            local state = default
            local card = NewFrame(self._scroll, UDim2.new(1,0,0, desc~="" and 50 or 36), nil, T.Card, "TogCard")
            card.LayoutOrder = #self._scroll:GetChildren()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)

            local btn = NewButton(card, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), T.Card)
            MakeRound(btn, 8)
            MakePadding(btn, 0, 0, 12, 12)

            local lbl = NewLabel(btn, label, UDim2.new(1,-60,0,20), T.Text, "Lbl", Enum.Font.GothamSemibold, 13)
            lbl.Position = UDim2.new(0,0,0,desc~="" and 8 or 8)
            if desc ~= "" then
                local d = NewLabel(btn, desc, UDim2.new(1,-60,0,16), T.TextMuted, "Desc", Enum.Font.Gotham, 11)
                d.Position = UDim2.new(0,0,0,26)
            end

            -- Toggle pill
            local pill = NewFrame(btn, UDim2.new(0,44,0,24), UDim2.new(1,-50,0.5,-12), T.ToggleOff, "Pill")
            MakeRound(pill, 12)
            local knob = NewFrame(pill, UDim2.new(0,18,0,18), UDim2.new(0,3,0.5,-9), Color3.new(1,1,1), "Knob")
            MakeRound(knob, 9)

            local function UpdateVisual()
                if state then
                    Tween(pill,  {BackgroundColor3 = T.Toggle}, 0.2)
                    Tween(knob,  {Position = UDim2.new(0,23,0.5,-9)}, 0.2)
                else
                    Tween(pill,  {BackgroundColor3 = T.ToggleOff}, 0.2)
                    Tween(knob,  {Position = UDim2.new(0,3,0.5,-9)}, 0.2)
                end
            end
            UpdateVisual()

            btn.MouseButton1Click:Connect(function()
                state = not state
                UpdateVisual()
                callback(state)
            end)

            local Toggle = {}
            function Toggle:Set(val)
                state = val
                UpdateVisual()
                callback(state)
            end
            function Toggle:Get() return state end
            return Toggle
        end

        -- в”Ђв”Ђ SLIDER в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
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

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,54), nil, T.Card, "SlideCard")
            card.LayoutOrder = #self._scroll:GetChildren()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 10, 12, 12)

            local topRow = NewFrame(card, UDim2.new(1,0,0,18), UDim2.new(0,0,0,0), T.Card, "Top")
            topRow.BackgroundTransparency = 1
            local lbl = NewLabel(topRow, label, UDim2.new(0.7,0,1,0), T.Text, "Lbl", Enum.Font.GothamSemibold, 13)

            local valLbl = NewLabel(topRow, tostring(value) .. suffix, UDim2.new(0.3,0,1,0), T.Accent, "Val", Enum.Font.GothamBold, 13)
            valLbl.Position       = UDim2.new(0.7,0,0,0)
            valLbl.TextXAlignment = Enum.TextXAlignment.Right

            -- Track
            local track = NewFrame(card, UDim2.new(1,0,0,6), UDim2.new(0,0,0,28), T.Panel, "Track")
            MakeRound(track, 3)
            local fill = NewFrame(track, UDim2.new(0,0,1,0), UDim2.new(0,0,0,0), T.Accent, "Fill")
            MakeRound(fill, 3)
            local knob = NewButton(track, UDim2.new(0,14,0,14), UDim2.new(0,0,0.5,-7), T.Accent, "Knob")
            MakeRound(knob, 7)

            local function UpdateSlider(v)
                value = math.clamp(v, min, max)
                local pct = (value - min) / (max - min)
                fill.Size     = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, -7, 0.5, -7)
                local fmt = "%." .. decimals .. "f"
                valLbl.Text = string.format(fmt, value) .. suffix
                callback(value)
            end
            UpdateSlider(value)

            local dragging = false
            knob.MouseButton1Down:Connect(function() dragging = true end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local relX = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                    local pct  = relX / track.AbsoluteSize.X
                    local snap = 1 / (10 ^ decimals)
                    local raw  = min + (max - min) * pct
                    UpdateSlider(math.floor(raw / snap + 0.5) * snap)
                end
            end)
            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local relX = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                    UpdateSlider(min + (max - min) * (relX / track.AbsoluteSize.X))
                    dragging = true
                end
            end)

            local Slider = {}
            function Slider:Set(v) UpdateSlider(v) end
            function Slider:Get() return value end
            return Slider
        end

        -- в”Ђв”Ђ TEXTBOX в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
        function Tab:AddTextBox(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label       or "Input"
            local placeholder = opts.Placeholder or "Enter text..."
            local default  = opts.Default     or ""
            local callback = opts.Callback    or function() end
            local clearOnFocus = opts.ClearOnFocus ~= false

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,56), nil, T.Card, "TBCard")
            card.LayoutOrder = #self._scroll:GetChildren()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 8, 12, 12)

            local lbl = NewLabel(card, label, UDim2.new(1,0,0,16), T.TextMuted, "Lbl", Enum.Font.GothamSemibold, 11)
            lbl.Position = UDim2.new(0,0,0,0)

            local inputBg = NewFrame(card, UDim2.new(1,0,0,26), UDim2.new(0,0,0,22), T.Panel, "InputBg")
            MakeRound(inputBg, 6)
            MakeStroke(inputBg, T.Border, 1, 0.4)

            local tb = Instance.new("TextBox")
            tb.Size              = UDim2.new(1,0,1,0)
            tb.BackgroundTransparency = 1
            tb.TextColor3        = T.Text
            tb.PlaceholderColor3 = T.TextDim
            tb.PlaceholderText   = placeholder
            tb.Font              = Enum.Font.Gotham
            tb.TextSize          = 12
            tb.Text              = default
            tb.ClearTextOnFocus  = clearOnFocus
            tb.TextXAlignment    = Enum.TextXAlignment.Left
            tb.Parent            = inputBg
            MakePadding(tb, 0, 0, 8, 8)

            tb.Focused:Connect(function()
                Tween(inputBg, {BackgroundColor3 = T.Card}, 0.15)
                MakeStroke(inputBg, T.Accent, 1, 0.3)
            end)
            tb.FocusLost:Connect(function(enter)
                Tween(inputBg, {BackgroundColor3 = T.Panel}, 0.15)
                callback(tb.Text, enter)
            end)

            local TB = {}
            function TB:Set(v) tb.Text = v end
            function TB:Get() return tb.Text end
            return TB
        end

        -- в”Ђв”Ђ DROPDOWN в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
        function Tab:AddDropdown(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Dropdown"
            local options  = opts.Options  or {}
            local default  = opts.Default  or (options[1] or "Select...")
            local callback = opts.Callback or function() end
            local multi    = opts.Multi    or false

            local selected = multi and {} or default
            if multi and default then selected[default] = true end

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,56), nil, T.Card, "DDCard")
            card.LayoutOrder = #self._scroll:GetChildren()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 8, 12, 12)
            card.ClipsDescendants = false

            local lbl = NewLabel(card, label, UDim2.new(1,0,0,16), T.TextMuted, "Lbl", Enum.Font.GothamSemibold, 11)

            local trigger = NewButton(card, UDim2.new(1,0,0,26), UDim2.new(0,0,0,22), T.Panel, "Trigger")
            MakeRound(trigger, 6)
            MakeStroke(trigger, T.Border, 1, 0.4)
            MakePadding(trigger, 0, 0, 8, 30)

            local function GetDisplayText()
                if multi then
                    local keys = {}
                    for k in pairs(selected) do table.insert(keys, k) end
                    return #keys == 0 and "None" or table.concat(keys, ", ")
                else
                    return selected
                end
            end

            local triggerLbl = NewLabel(trigger, GetDisplayText(), UDim2.new(1,0,1,0), T.Text, "Txt", Enum.Font.Gotham, 12)
            local arrow = NewLabel(trigger, "в–ѕ", UDim2.new(0,20,1,0), T.TextMuted, "Arr", Enum.Font.GothamBold, 12)
            arrow.Position       = UDim2.new(1,-22,0,0)
            arrow.TextXAlignment = Enum.TextXAlignment.Center

            -- Dropdown menu (spawned above/below)
            local open = false
            local menu = nil

            local function CloseMenu()
                if menu then menu:Destroy() menu = nil end
                open = false
                Tween(arrow, {Rotation = 0}, 0.2)
            end

            trigger.MouseButton1Click:Connect(function()
                open = not open
                if not open then CloseMenu() return end

                Tween(arrow, {Rotation = 180}, 0.2)

                menu = NewFrame(card, UDim2.new(1,0,0, math.min(#options, 6)*28 + 8), UDim2.new(0,0,0,56), T.Panel, "Menu")
                menu.ZIndex = 10
                menu.ClipsDescendants = true
                MakeRound(menu, 8)
                MakeStroke(menu, T.Border, 1, 0.4)

                local mLayout = Instance.new("UIListLayout")
                mLayout.SortOrder = Enum.SortOrder.LayoutOrder
                mLayout.Parent    = menu
                MakePadding(menu, 4, 4, 4, 4)

                if #options > 6 then
                    local sf = Instance.new("ScrollingFrame")
                    sf.Size = UDim2.new(1,0,1,0)
                    sf.BackgroundTransparency = 1
                    sf.BorderSizePixel = 0
                    sf.ScrollBarThickness = 3
                    sf.ScrollBarImageColor3 = T.Scrollbar
                    sf.CanvasSize = UDim2.new(0,0,0,#options*28)
                    sf.Parent = menu
                    local sfl = Instance.new("UIListLayout")
                    sfl.SortOrder = Enum.SortOrder.LayoutOrder
                    sfl.Parent = sf
                    -- add to scrollframe instead
                    for _, opt in ipairs(options) do
                        local item = NewButton(sf, UDim2.new(1,0,0,28), nil, T.Panel, "Item")
                        MakeRound(item, 5)
                        MakePadding(item, 0, 0, 8, 8)
                        local isSelected = multi and selected[opt] or (not multi and selected == opt)
                        local itemLbl = NewLabel(item, opt, UDim2.new(1,0,1,0), isSelected and T.Accent or T.Text, "Lbl", Enum.Font.Gotham, 12)
                        item.MouseEnter:Connect(function() Tween(item, {BackgroundColor3 = T.Card}, 0.1) end)
                        item.MouseLeave:Connect(function() Tween(item, {BackgroundColor3 = T.Panel}, 0.1) end)
                        item.MouseButton1Click:Connect(function()
                            if multi then
                                selected[opt] = not selected[opt] or nil
                                itemLbl.TextColor3 = selected[opt] and T.Accent or T.Text
                                triggerLbl.Text = GetDisplayText()
                                callback(selected)
                            else
                                selected = opt
                                triggerLbl.Text = opt
                                callback(opt)
                                CloseMenu()
                            end
                        end)
                    end
                    mLayout:Destroy()
                else
                    for _, opt in ipairs(options) do
                        local item = NewButton(menu, UDim2.new(1,0,0,28), nil, T.Panel, "Item")
                        MakeRound(item, 5)
                        MakePadding(item, 0, 0, 8, 8)
                        local isSelected = multi and selected[opt] or (not multi and selected == opt)
                        local itemLbl = NewLabel(item, opt, UDim2.new(1,0,1,0), isSelected and T.Accent or T.Text, "Lbl", Enum.Font.Gotham, 12)
                        item.MouseEnter:Connect(function() Tween(item, {BackgroundColor3 = T.Card}, 0.1) end)
                        item.MouseLeave:Connect(function() Tween(item, {BackgroundColor3 = T.Panel}, 0.1) end)
                        item.MouseButton1Click:Connect(function()
                            if multi then
                                selected[opt] = not selected[opt] or nil
                                itemLbl.TextColor3 = selected[opt] and T.Accent or T.Text
                                triggerLbl.Text = GetDisplayText()
                                callback(selected)
                            else
                                selected = opt
                                triggerLbl.Text = opt
                                callback(opt)
                                CloseMenu()
                            end
                        end)
                    end
                end

                -- Close when clicking elsewhere
                local conn
                conn = UserInputService.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        task.wait()
                        if menu and not menu:IsAncestorOf(i) then
                            CloseMenu()
                            conn:Disconnect()
                        end
                    end
                end)
            end)

            local DD = {}
            function DD:Set(v)
                if multi then selected = v else selected = v end
                triggerLbl.Text = GetDisplayText()
            end
            function DD:Get() return selected end
            function DD:SetOptions(newOpts)
                options = newOpts
                if not multi and not table.find(options, selected) then
                    selected = options[1] or "Select..."
                    triggerLbl.Text = selected
                end
            end
            return DD
        end

        -- в”Ђв”Ђ KEYBIND в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
        function Tab:AddKeybind(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Keybind"
            local default  = opts.Default  or Enum.KeyCode.Unknown
            local callback = opts.Callback or function() end

            local key = default
            local listening = false

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,36), nil, T.Card, "KBCard")
            card.LayoutOrder = #self._scroll:GetChildren()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 0, 0, 12, 12)

            local lbl = NewLabel(card, label, UDim2.new(1,-80,1,0), T.Text, "Lbl", Enum.Font.GothamSemibold, 13)

            local keyBtn = NewButton(card, UDim2.new(0,70,0,22), UDim2.new(1,-72,0.5,-11), T.Panel, "KeyBtn")
            MakeRound(keyBtn, 5)
            MakeStroke(keyBtn, T.Border, 1, 0.4)
            local keyLbl = NewLabel(keyBtn, key.Name, UDim2.new(1,0,1,0), T.Accent, "KLbl", Enum.Font.GothamBold, 11)
            keyLbl.TextXAlignment = Enum.TextXAlignment.Center

            keyBtn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                keyLbl.Text      = "..."
                keyLbl.TextColor3 = T.Warning
                local conn
                conn = UserInputService.InputBegan:Connect(function(i, gpe)
                    if gpe then return end
                    if i.UserInputType == Enum.UserInputType.Keyboard then
                        key = i.KeyCode
                        keyLbl.Text       = key.Name
                        keyLbl.TextColor3 = T.Accent
                        listening = false
                        conn:Disconnect()
                    end
                end)
            end)

            UserInputService.InputBegan:Connect(function(i, gpe)
                if gpe or listening then return end
                if i.KeyCode == key then callback() end
            end)

            local KB = {}
            function KB:Set(k) key = k ; keyLbl.Text = k.Name end
            function KB:Get() return key end
            return KB
        end

        -- в”Ђв”Ђ COLOR PICKER в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
        function Tab:AddColorPicker(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Color"
            local default  = opts.Default  or Color3.fromRGB(255,100,100)
            local callback = opts.Callback or function() end

            local color = default
            local h, s, v = Color3.toHSV(color)
            local open = false

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,36), nil, T.Card, "CPCard")
            card.LayoutOrder = #self._scroll:GetChildren()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 0, 0, 12, 12)

            local lbl = NewLabel(card, label, UDim2.new(1,-50,1,0), T.Text, "Lbl", Enum.Font.GothamSemibold, 13)

            local preview = NewButton(card, UDim2.new(0,36,0,22), UDim2.new(1,-40,0.5,-11), color, "Preview")
            MakeRound(preview, 5)
            MakeStroke(preview, T.Border, 1, 0.3)

            local picker = nil

            local function BuildPicker()
                picker = NewFrame(card, UDim2.new(1,0,0,160), UDim2.new(0,0,0,38), T.Panel, "Picker")
                MakeRound(picker, 8)
                MakeStroke(picker, T.Border, 1, 0.4)
                MakePadding(picker, 8, 8, 8, 8)

                local function MakeSliderRow(labelText, startH, startS, startV)
                    local row = NewFrame(picker, UDim2.new(1,0,0,28), nil, T.Panel, "Row")
                    row.BackgroundTransparency = 1
                    local rowLbl = NewLabel(row, labelText, UDim2.new(0,10,1,0), T.TextMuted, "L", Enum.Font.GothamBold, 10)
                    rowLbl.TextXAlignment = Enum.TextXAlignment.Center
                    local track = NewFrame(row, UDim2.new(1,-20,0,6), UDim2.new(0,20,0.5,-3), T.Card, "Track")
                    MakeRound(track, 3)
                    local fill = NewFrame(track, UDim2.new(0,0,1,0), nil, T.Accent, "Fill")
                    MakeRound(fill, 3)
                    local knob = NewButton(track, UDim2.new(0,12,0,12), UDim2.new(0,-6,0.5,-6), Color3.new(1,1,1), "Knob")
                    MakeRound(knob, 6)
                    return track, fill, knob
                end

                local hTrack, hFill, hKnob = MakeSliderRow("H")
                local sTrack, sFill, sKnob = MakeSliderRow("S")
                local vTrack, vFill, vKnob = MakeSliderRow("V")

                -- Lay out rows manually
                local layout2 = Instance.new("UIListLayout")
                layout2.SortOrder = Enum.SortOrder.LayoutOrder
                layout2.Padding = UDim.new(0, 4)
                layout2.Parent = picker

                local function UpdateAll()
                    color = Color3.fromHSV(h, s, v)
                    preview.BackgroundColor3 = color
                    hFill.Size = UDim2.new(h, 0, 1, 0)
                    hKnob.Position = UDim2.new(h, -6, 0.5, -6)
                    sFill.Size = UDim2.new(s, 0, 1, 0)
                    sKnob.Position = UDim2.new(s, -6, 0.5, -6)
                    vFill.Size = UDim2.new(v, 0, 1, 0)
                    vKnob.Position = UDim2.new(v, -6, 0.5, -6)
                    callback(color)
                end
                UpdateAll()

                local function BindSlider(track, knob, setter)
                    local dragging = false
                    knob.MouseButton1Down:Connect(function() dragging = true end)
                    UserInputService.InputEnded:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                    end)
                    UserInputService.InputChanged:Connect(function(i)
                        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                            local pct = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                            setter(pct)
                            UpdateAll()
                        end
                    end)
                    track.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 then
                            local pct = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                            setter(pct)
                            UpdateAll()
                            dragging = true
                        end
                    end)
                end

                BindSlider(hTrack, hKnob, function(p) h = p end)
                BindSlider(sTrack, sKnob, function(p) s = p end)
                BindSlider(vTrack, vKnob, function(p) v = p end)
            end

            preview.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    card.Size = UDim2.new(1,0,0,36+168)
                    BuildPicker()
                else
                    card.Size = UDim2.new(1,0,0,36)
                    if picker then picker:Destroy() picker = nil end
                end
            end)

            local CP = {}
            function CP:Set(c)
                color = c
                h, s, v = Color3.toHSV(c)
                preview.BackgroundColor3 = c
                callback(c)
            end
            function CP:Get() return color end
            return CP
        end

        -- в”Ђв”Ђ LABEL / PARAGRAPH в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
        function Tab:AddLabel(opts)
            opts = opts or {}
            local T    = self._T
            local text = opts.Text or "Label"
            local color = opts.Color or T.TextMuted

            local lbl = NewLabel(self._scroll, text, UDim2.new(1,0,0,0), color, "Lbl", Enum.Font.Gotham, 12)
            lbl.AutomaticSize = Enum.AutomaticSize.Y
            lbl.TextWrapped   = true
            lbl.LayoutOrder   = #self._scroll:GetChildren()

            local L = {}
            function L:Set(t) lbl.Text = t end
            function L:SetColor(c) lbl.TextColor3 = c end
            return L
        end

        -- в”Ђв”Ђ SEPARATOR в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
        function Tab:AddSeparator()
            local T   = self._T
            local sep = NewFrame(self._scroll, UDim2.new(1,0,0,1), nil, T.Border, "Sep")
            sep.BackgroundTransparency = 0.5
            sep.LayoutOrder = #self._scroll:GetChildren()
        end

        -- в”Ђв”Ђ PARAGRAPH в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
        function Tab:AddParagraph(opts)
            opts = opts or {}
            local T     = self._T
            local title = opts.Title or ""
            local body  = opts.Body  or ""

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,0), nil, T.Card, "ParaCard")
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.LayoutOrder   = #self._scroll:GetChildren()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 10, 10, 12, 12)

            local layout = Instance.new("UIListLayout")
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding   = UDim.new(0, 4)
            layout.Parent    = card

            if title ~= "" then
                local t = NewLabel(card, title, UDim2.new(1,0,0,16), T.Text, "Title", Enum.Font.GothamBold, 13)
                t.LayoutOrder = 1
            end
            local b = NewLabel(card, body, UDim2.new(1,0,0,0), T.TextMuted, "Body", Enum.Font.Gotham, 12)
            b.AutomaticSize = Enum.AutomaticSize.Y
            b.TextWrapped   = true
            b.LayoutOrder   = 2

            local P = {}
            function P:SetTitle(t) title.Text = t end
            function P:SetBody(t) b.Text = t end
            return P
        end

        table.insert(self._tabs, Tab)
        return Tab
    end

    -- в”Ђв”Ђ CHANGE THEME в”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђв”Ђ
    function Window:SetTheme(themeName)
        -- Simplified: destroys and re-creates the GUI
        -- For production use, you'd recursively update colors
        print("[NexusLib] Theme change requires recreation of window.")
    end

    return Window
end

-- ============================================================
--  LIBRARY META
-- ============================================================
NexusLib.Version = "1.0.0"
NexusLib.Themes  = Themes

function NexusLib:GetThemeNames()
    local names = {}
    for k in pairs(Themes) do table.insert(names, k) end
    return names
end

return NexusLib
