--[[
    NexusLib - A Modern Roblox UI Library
    Version: 2.0.0

    Improvements over 1.x:
      • Executor compatibility (gethui, protectgui, syn.protect_gui, makefolder, writefile)
      • Protected callbacks (pcall + task.spawn — one error won't crash the UI)
      • Cleanup / Destroy system (tracks connections + instances)
      • Config save / load via filesystem (JSON, auto-folder)
      • Debounces on buttons / toggles
      • Reused TweenInfo objects (no new allocation per tween)
      • Notification queue (no overlap, ordered stack)
      • Extra elements: ProgressBar, SearchDropdown
      • Fixed dropdown "click outside" detection
      • Fixed color picker layout (UIListLayout conflict removed)
      • Fixed subtitle position (no more magic pixel offset)
      • MakeStroke no longer stacks on re-focus (TextBox)

    Usage:
        local NexusLib = loadstring(game:HttpGet("your_url"))()
        local Window = NexusLib:CreateWindow({
            Title    = "My Script",
            Subtitle = "v2.0",
            Theme    = "Dark",   -- "Dark" | "Light" | "Ocean" | "Crimson"
            Size     = UDim2.new(0, 560, 0, 420),
        })
        local Tab = Window:AddTab("Main")
        Tab:AddButton({ Label = "Click Me", Callback = function() print("hi") end })

        -- Notifications (standalone, no window needed)
        NexusLib:Notify({ Title = "Done", Message = "All good!", Type = "Success" })

        -- Config
        Window:SaveConfig("default")
        Window:LoadConfig("default")
]]

-- ============================================================
--  SERVICES  (cached once)
-- ============================================================
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
--  EXECUTOR COMPAT
-- ============================================================
local function GetGui()
    -- gethui() is safer on most modern executors (Synapse X, etc.)
    if gethui then return gethui() end
    return CoreGui
end

local function ProtectGui(sg)
    if syn and syn.protect_gui then
        syn.protect_gui(sg)
    elseif protectgui then
        protectgui(sg)
    end
end

local CONFIG_FOLDER = "NexusLib"
local function EnsureFolder()
    if makefolder and not isfolder(CONFIG_FOLDER) then
        pcall(makefolder, CONFIG_FOLDER)
    end
end

-- ============================================================
--  TWEEN INFO CACHE  (avoids per-call allocation)
-- ============================================================
local TI = {
    Fast   = TweenInfo.new(0.15, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Slow   = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Linear = function(d) return TweenInfo.new(d, Enum.EasingStyle.Linear) end,
}

local function Tween(obj, props, speed)
    local info = (speed == "fast" and TI.Fast)
              or (speed == "slow" and TI.Slow)
              or TI.Normal
    TweenService:Create(obj, info, props):Play()
end

local function TweenLinear(obj, props, duration)
    TweenService:Create(obj, TI.Linear(duration), props):Play()
end

-- ============================================================
--  SAFE CALL  (prevents callback errors from crashing the UI)
-- ============================================================
local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return end
    local args = {...}
    task.spawn(function()
        local ok, err = pcall(fn, table.unpack(args))
        if not ok then
            warn("[NexusLib] Callback error:", err)
        end
    end)
end

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
--  UI HELPERS
-- ============================================================
local function MakeRound(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
    return c
end

local function MakePadding(obj, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 6)
    p.PaddingBottom = UDim.new(0, b or 6)
    p.PaddingLeft   = UDim.new(0, l or 10)
    p.PaddingRight  = UDim.new(0, r or 10)
    p.Parent = obj
    return p
end

local function MakeStroke(obj, color, thickness, transparency)
    -- Remove existing stroke first to avoid stacking
    local existing = obj:FindFirstChildOfClass("UIStroke")
    if existing then existing:Destroy() end
    local s = Instance.new("UIStroke")
    s.Color        = color        or Color3.new(1,1,1)
    s.Thickness    = thickness    or 1
    s.Transparency = transparency or 0.85
    s.Parent       = obj
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

local function MakeScrollFrame(parent, color, scrollbarColor)
    local sf = Instance.new("ScrollingFrame")
    sf.Size                   = UDim2.new(1,0,1,0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel        = 0
    sf.ScrollBarThickness     = 4
    sf.ScrollBarImageColor3   = scrollbarColor or Color3.fromRGB(80,80,110)
    sf.CanvasSize             = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    sf.Parent                 = parent
    return sf
end

-- Dragging
local function MakeDraggable(handle, target)
    local dragging, dragStart, startPos = false, nil, nil
    local dragInput = nil

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
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
--  NOTIFICATION SYSTEM  (with queue so they don't overlap)
-- ============================================================
local NotifHolder    = nil
local NotifQueue     = {}
local NotifActive    = 0
local NOTIF_MAX      = 5

local function EnsureNotifHolder()
    if NotifHolder and NotifHolder.Parent then return end

    local sg = Instance.new("ScreenGui")
    sg.Name           = "NexusLib_Notifs"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 999
    ProtectGui(sg)
    pcall(function() sg.Parent = GetGui() end)
    if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end

    local holder = NewFrame(sg, UDim2.new(0,290,1,0), UDim2.new(1,-298,0,0),
        Color3.new(0,0,0), "Holder")
    holder.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout")
    layout.SortOrder         = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Padding           = UDim.new(0, 8)
    layout.Parent            = holder
    MakePadding(holder, 12, 12, 0, 0)

    NotifHolder = holder
end

local NexusLib = {}
NexusLib.__index = NexusLib

function NexusLib:Notify(opts)
    opts = opts or {}
    local title    = opts.Title    or "Notification"
    local message  = opts.Message  or ""
    local duration = opts.Duration or 4
    local ntype    = opts.Type     or "Info"
    local theme    = opts.Theme    or "Dark"
    local T        = Themes[theme] or Themes.Dark

    EnsureNotifHolder()

    -- Cap active notifications
    if NotifActive >= NOTIF_MAX then
        table.insert(NotifQueue, opts)
        return
    end
    NotifActive += 1

    local typeColor = T.Accent
    local typeIcon  = "🔵"
    if ntype == "Success" then typeColor = T.Success ; typeIcon = "✅"
    elseif ntype == "Warning" then typeColor = T.Warning ; typeIcon = "⚠️"
    elseif ntype == "Error"   then typeColor = T.Danger  ; typeIcon = "❌"
    end

    local card = NewFrame(NotifHolder, UDim2.new(1,0,0,0), nil, T.Panel, "Notif")
    card.AutomaticSize    = Enum.AutomaticSize.Y
    card.ClipsDescendants = false
    MakeRound(card, 10)
    MakeStroke(card, T.Border, 1, 0.5)

    -- Accent stripe
    local stripe = NewFrame(card, UDim2.new(0,3,1,0), UDim2.new(0,0,0,0), typeColor, "Stripe")
    MakeRound(stripe, 3)

    local inner = NewFrame(card, UDim2.new(1,-12,0,0), UDim2.new(0,12,0,0), T.Panel, "Inner")
    inner.AutomaticSize = Enum.AutomaticSize.Y
    MakePadding(inner, 10, 10, 4, 8)

    local iLayout = Instance.new("UIListLayout")
    iLayout.SortOrder = Enum.SortOrder.LayoutOrder
    iLayout.Padding   = UDim.new(0, 2)
    iLayout.Parent    = inner

    local titleLabel = NewLabel(inner, typeIcon .. "  " .. title,
        UDim2.new(1,0,0,18), T.Text, "Title", Enum.Font.GothamBold, 13)
    titleLabel.LayoutOrder = 1

    if message ~= "" then
        local msgLabel = NewLabel(inner, message, UDim2.new(1,0,0,0),
            T.TextMuted, "Msg", Enum.Font.Gotham, 11)
        msgLabel.AutomaticSize = Enum.AutomaticSize.Y
        msgLabel.TextWrapped   = true
        msgLabel.LayoutOrder   = 2
    end

    local barBg = NewFrame(card, UDim2.new(1,0,0,3), UDim2.new(0,0,1,-3), T.Card, "BarBg")
    local bar   = NewFrame(barBg, UDim2.new(1,0,1,0), nil, typeColor, "Bar")
    MakeRound(barBg, 2)
    MakeRound(bar,   2)

    -- Slide in from right
    card.Position = UDim2.new(1, 10, 0, 0)
    Tween(card, {Position = UDim2.new(0,0,0,0)}, "fast")

    TweenLinear(bar, {Size = UDim2.new(0,0,1,0)}, duration)

    task.delay(duration, function()
        Tween(card, {BackgroundTransparency = 1}, "fast")
        task.wait(0.2)
        pcall(function() card:Destroy() end)
        NotifActive -= 1
        -- Drain queue
        if #NotifQueue > 0 then
            local next = table.remove(NotifQueue, 1)
            self:Notify(next)
        end
    end)
end

-- ============================================================
--  WINDOW
-- ============================================================
function NexusLib:CreateWindow(opts)
    opts = opts or {}
    local title     = opts.Title    or "NexusLib"
    local subtitle  = opts.Subtitle or ""
    local themeName = opts.Theme    or "Dark"
    local T         = Themes[themeName] or Themes.Dark
    local winSize   = opts.Size or UDim2.new(0, 560, 0, 420)

    -- Connection tracker for cleanup
    local _connections = {}
    local function Track(conn)
        table.insert(_connections, conn)
        return conn
    end

    -- Config registry: element key → { Get, Set }
    local _configElements = {}

    -- ── ScreenGui ────────────────────────────────────────────
    local sg = Instance.new("ScreenGui")
    sg.Name           = "NexusLib_" .. title
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 100
    ProtectGui(sg)
    pcall(function() sg.Parent = GetGui() end)
    if not sg.Parent then sg.Parent = LocalPlayer.PlayerGui end

    -- Root window
    local win = NewFrame(sg, winSize, UDim2.new(0.5, -winSize.X.Offset/2,
        0.5, -winSize.Y.Offset/2), T.Background, "Window")
    win.ClipsDescendants = false
    MakeRound(win, 12)
    MakeStroke(win, T.Border, 1, 0.6)

    -- Shadow
    local shadow = NewFrame(sg,
        UDim2.new(0, winSize.X.Offset+40, 0, winSize.Y.Offset+40),
        UDim2.new(0.5, -(winSize.X.Offset+40)/2, 0.5, -(winSize.Y.Offset+40)/2),
        Color3.new(0,0,0), "Shadow")
    shadow.BackgroundTransparency = 0.6
    shadow.ZIndex = 0
    MakeRound(shadow, 16)

    -- ── Title Bar ────────────────────────────────────────────
    local titleBar = NewFrame(win, UDim2.new(1,0,0,50), nil, T.Surface, "TitleBar")
    MakeRound(titleBar, 12)
    -- fill to cover bottom round corners of title bar
    NewFrame(win, UDim2.new(1,0,0,14), UDim2.new(0,0,0,36), T.Surface, "TitleFill")
    MakePadding(titleBar, 0, 0, 16, 12)
    MakeDraggable(titleBar, win)

    -- Title / subtitle inside a small layout
    local titleContainer = NewFrame(titleBar, UDim2.new(1,-50,1,0), nil, T.Surface, "TitleCont")
    titleContainer.BackgroundTransparency = 1
    local titleLbl = NewLabel(titleContainer, title,
        UDim2.new(1,0, subtitle ~= "" and 0 or 1, 0),
        T.Text, "Title", Enum.Font.GothamBold, 15)
    titleLbl.Position = UDim2.new(0,0,0, subtitle ~= "" and 6 or 0)
    if subtitle ~= "" then
        local subLbl = NewLabel(titleContainer, subtitle,
            UDim2.new(1,0,0,14), T.TextMuted, "Sub", Enum.Font.Gotham, 11)
        subLbl.Position = UDim2.new(0,0,0,26)
    end

    -- Window buttons
    local btnClose = NewButton(titleBar, UDim2.new(0,18,0,18),
        UDim2.new(1,-20,0.5,-9), T.Danger, "Close")
    MakeRound(btnClose, 9)
    local btnMin = NewButton(titleBar, UDim2.new(0,18,0,18),
        UDim2.new(1,-42,0.5,-9), T.Warning, "Min")
    MakeRound(btnMin, 9)

    for _, btn in ipairs({btnClose, btnMin}) do
        Track(btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency = 0.3}, "fast") end))
        Track(btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency = 0},   "fast") end))
    end

    -- ── Sidebar ──────────────────────────────────────────────
    local sidebar = NewFrame(win, UDim2.new(0,140,1,-50), UDim2.new(0,0,0,50),
        T.Surface, "Sidebar")
    -- cover sidebar's right rounded corners
    NewFrame(win, UDim2.new(0,14,1,-50), UDim2.new(0,126,0,50), T.Surface, "SBFill")

    local sideLayout = Instance.new("UIListLayout")
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sideLayout.Padding   = UDim.new(0, 2)
    sideLayout.Parent    = sidebar
    MakePadding(sidebar, 10, 10, 8, 4)

    -- Divider
    NewFrame(win, UDim2.new(0,1,1,-50), UDim2.new(0,140,0,50), T.Border, "Divider")

    -- ── Content area ─────────────────────────────────────────
    local contentArea = NewFrame(win, UDim2.new(1,-142,1,-50), UDim2.new(0,142,0,50),
        T.Background, "Content")
    contentArea.ClipsDescendants = true

    -- ── Minimize / Close ─────────────────────────────────────
    local minimized = false
    local originalSize = winSize

    Track(btnClose.MouseButton1Click:Connect(function()
        Tween(win, {Size = UDim2.new(0, winSize.X.Offset, 0,0)}, "normal")
        task.wait(0.25)
        sg:Destroy()
    end))

    Track(btnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(win, {Size = UDim2.new(originalSize.X.Scale,
                originalSize.X.Offset, 0, 50)}, "normal")
        else
            Tween(win, {Size = originalSize}, "normal")
        end
    end))

    -- ============================================================
    --  WINDOW OBJECT
    -- ============================================================
    local Window = {
        _T            = T,
        _tabs         = {},
        _activeTab    = nil,
        _sidebar      = sidebar,
        _contentArea  = contentArea,
        _sg           = sg,
        _connections  = _connections,
        _configEls    = _configElements,
        _themeName    = themeName,
    }

    -- ── AddTab ───────────────────────────────────────────────
    function Window:AddTab(name, icon)
        local T        = self._T
        local tabCount = #self._tabs + 1

        -- Sidebar button
        local tabBtn = NewButton(self._sidebar, UDim2.new(1,-4,0,34), nil,
            T.Panel, "Tab_" .. name)
        tabBtn.LayoutOrder    = tabCount
        tabBtn.BackgroundTransparency = 1
        MakeRound(tabBtn, 7)
        MakePadding(tabBtn, 0, 0, 10, 6)

        if icon then
            NewImage(tabBtn, icon, UDim2.new(0,16,0,16), UDim2.new(0,0,0.5,-8))
        end
        local iconOffset = icon and 22 or 0
        local tabLbl = NewLabel(tabBtn, name,
            UDim2.new(1,-iconOffset,1,0),
            T.TextMuted, "Label", Enum.Font.GothamSemibold, 12)
        tabLbl.Position = UDim2.new(0, iconOffset, 0, 0)

        -- Tab page
        local page = NewFrame(self._contentArea, UDim2.new(1,0,1,0), nil,
            T.Background, "Page_" .. name)
        page.Visible          = false
        page.ClipsDescendants = true

        local scroll = MakeScrollFrame(page, T.Background, T.Scrollbar)
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding   = UDim.new(0, 6)
        layout.Parent    = scroll
        MakePadding(scroll, 10, 10, 12, 12)

        -- Selection logic
        local function Select()
            if Window._activeTab then
                local prev = Window._activeTab
                Tween(prev._btn, {BackgroundColor3 = T.Panel, BackgroundTransparency = 1}, "fast")
                Tween(prev._lbl, {TextColor3 = T.TextMuted}, "fast")
                prev._page.Visible = false
            end
            Tween(tabBtn, {BackgroundColor3 = T.Accent, BackgroundTransparency = 0}, "fast")
            Tween(tabLbl, {TextColor3 = T.Text}, "fast")
            page.Visible = true
            Window._activeTab = { _btn = tabBtn, _lbl = tabLbl, _page = page }
        end

        Track(tabBtn.MouseButton1Click:Connect(Select))
        Track(tabBtn.MouseEnter:Connect(function()
            if not (Window._activeTab and Window._activeTab._btn == tabBtn) then
                Tween(tabBtn, {BackgroundTransparency = 0.75, BackgroundColor3 = T.Card}, "fast")
            end
        end))
        Track(tabBtn.MouseLeave:Connect(function()
            if not (Window._activeTab and Window._activeTab._btn == tabBtn) then
                Tween(tabBtn, {BackgroundTransparency = 1}, "fast")
            end
        end))

        if tabCount == 1 then Select() end

        -- ============================================================
        --  TAB OBJECT
        -- ============================================================
        local Tab = {
            _scroll   = scroll,
            _T        = T,
            _window   = Window,
        }

        local function NextOrder()
            return #scroll:GetChildren() + 1
        end

        -- ── Section ──────────────────────────────────────────
        function Tab:AddSection(name)
            local T   = self._T
            local row = NewFrame(self._scroll, UDim2.new(1,0,0,24), nil, T.Background, "Section")
            row.LayoutOrder = NextOrder()

            NewFrame(row, UDim2.new(0.3,-8,0,1), UDim2.new(0,0,0.5,0), T.Border, "L1")
            local lbl = NewLabel(row, name:upper(), UDim2.new(0.4,0,1,0),
                T.TextDim, "SLbl", Enum.Font.GothamBold, 9)
            lbl.Position       = UDim2.new(0.3,0,0,0)
            lbl.TextXAlignment = Enum.TextXAlignment.Center
            NewFrame(row, UDim2.new(0.3,-8,0,1), UDim2.new(0.7,8,0.5,0), T.Border, "L2")
            return row
        end

        -- ── Button ───────────────────────────────────────────
        function Tab:AddButton(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Button"
            local desc     = opts.Desc     or ""
            local callback = opts.Callback or function() end
            local debounce = false
            local h        = desc ~= "" and 50 or 36

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,h), nil, T.Card, "BtnCard")
            card.LayoutOrder = NextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)

            local btn = NewButton(card, UDim2.new(1,0,1,0), nil, T.Card)
            MakeRound(btn, 8)
            MakePadding(btn, 0, 0, 12, 36)

            local lbl = NewLabel(btn, label, UDim2.new(1,0,0,20),
                T.Text, "Lbl", Enum.Font.GothamSemibold, 13)
            lbl.Position = UDim2.new(0,0,0,desc~="" and 7 or 8)
            if desc ~= "" then
                local d = NewLabel(btn, desc, UDim2.new(1,0,0,16),
                    T.TextMuted, "Desc", Enum.Font.Gotham, 11)
                d.Position = UDim2.new(0,0,0,26)
            end

            local arrow = NewLabel(btn, "›", UDim2.new(0,24,1,0),
                T.Accent, "Arrow", Enum.Font.GothamBold, 20)
            arrow.Position       = UDim2.new(1,-30,0,0)
            arrow.TextXAlignment = Enum.TextXAlignment.Center

            Track(btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = T.AccentDim}, "fast") end))
            Track(btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = T.Card},      "fast") end))
            Track(btn.MouseButton1Down:Connect(function() Tween(btn, {BackgroundColor3 = T.Accent}, "fast") end))
            Track(btn.MouseButton1Up:Connect(function()
                Tween(btn, {BackgroundColor3 = T.Card}, "fast")
                if debounce then return end
                debounce = true
                SafeCall(callback)
                task.delay(0.2, function() debounce = false end)
            end))

            return card
        end

        -- ── Toggle ───────────────────────────────────────────
        function Tab:AddToggle(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Toggle"
            local desc     = opts.Desc     or ""
            local default  = opts.Default  or false
            local callback = opts.Callback or function() end
            local configKey = opts.ConfigKey
            local state    = default
            local debounce = false
            local h        = desc ~= "" and 50 or 36

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,h), nil, T.Card, "TogCard")
            card.LayoutOrder = NextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)

            local btn = NewButton(card, UDim2.new(1,0,1,0), nil, T.Card)
            MakeRound(btn, 8)
            MakePadding(btn, 0, 0, 12, 12)

            local lbl = NewLabel(btn, label, UDim2.new(1,-60,0,20),
                T.Text, "Lbl", Enum.Font.GothamSemibold, 13)
            lbl.Position = UDim2.new(0,0,0,desc~="" and 7 or 8)
            if desc ~= "" then
                local d = NewLabel(btn, desc, UDim2.new(1,-60,0,16),
                    T.TextMuted, "Desc", Enum.Font.Gotham, 11)
                d.Position = UDim2.new(0,0,0,26)
            end

            local pill = NewFrame(btn, UDim2.new(0,44,0,24),
                UDim2.new(1,-50,0.5,-12), T.ToggleOff, "Pill")
            MakeRound(pill, 12)
            local knob = NewFrame(pill, UDim2.new(0,18,0,18),
                UDim2.new(0,3,0.5,-9), Color3.new(1,1,1), "Knob")
            MakeRound(knob, 9)

            local function UpdateVisual(noAnim)
                if state then
                    if noAnim then
                        pill.BackgroundColor3 = T.Toggle
                        knob.Position = UDim2.new(0,23,0.5,-9)
                    else
                        Tween(pill, {BackgroundColor3 = T.Toggle}, "fast")
                        Tween(knob, {Position = UDim2.new(0,23,0.5,-9)}, "fast")
                    end
                else
                    if noAnim then
                        pill.BackgroundColor3 = T.ToggleOff
                        knob.Position = UDim2.new(0,3,0.5,-9)
                    else
                        Tween(pill, {BackgroundColor3 = T.ToggleOff}, "fast")
                        Tween(knob, {Position = UDim2.new(0,3,0.5,-9)}, "fast")
                    end
                end
            end
            UpdateVisual(true)

            Track(btn.MouseButton1Click:Connect(function()
                if debounce then return end
                debounce = true
                state = not state
                UpdateVisual()
                SafeCall(callback, state)
                task.delay(0.2, function() debounce = false end)
            end))

            local Toggle = {}
            function Toggle:Set(val, silent)
                state = val
                UpdateVisual()
                if not silent then SafeCall(callback, state) end
            end
            function Toggle:Get() return state end

            if configKey then
                Window._configEls[configKey] = {
                    Get = function() return state end,
                    Set = function(v) Toggle:Set(v, true) end,
                }
            end
            return Toggle
        end

        -- ── Slider ───────────────────────────────────────────
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
            local configKey = opts.ConfigKey
            local value    = math.clamp(default, min, max)

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,54), nil, T.Card, "SlideCard")
            card.LayoutOrder = NextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 10, 12, 12)

            local topRow = NewFrame(card, UDim2.new(1,0,0,18), nil, T.Card, "Top")
            topRow.BackgroundTransparency = 1
            NewLabel(topRow, label, UDim2.new(0.7,0,1,0),
                T.Text, "Lbl", Enum.Font.GothamSemibold, 13)

            local valLbl = NewLabel(topRow, tostring(value)..suffix,
                UDim2.new(0.3,0,1,0), T.Accent, "Val", Enum.Font.GothamBold, 13)
            valLbl.Position       = UDim2.new(0.7,0,0,0)
            valLbl.TextXAlignment = Enum.TextXAlignment.Right

            local track = NewFrame(card, UDim2.new(1,0,0,6), UDim2.new(0,0,0,28), T.Panel, "Track")
            MakeRound(track, 3)
            local fill  = NewFrame(track, UDim2.new(0,0,1,0), nil, T.Accent, "Fill")
            MakeRound(fill, 3)
            local knob  = NewButton(track, UDim2.new(0,14,0,14), UDim2.new(0,0,0.5,-7), T.Accent, "Knob")
            MakeRound(knob, 7)

            local fmt = "%." .. decimals .. "f"
            local snap = 1 / (10 ^ decimals)

            local function UpdateSlider(v, silent)
                value = math.clamp(
                    math.floor(v / snap + 0.5) * snap,
                    min, max
                )
                local pct = (value - min) / (max - min)
                fill.Size     = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, -7, 0.5, -7)
                valLbl.Text   = string.format(fmt, value) .. suffix
                if not silent then SafeCall(callback, value) end
            end
            UpdateSlider(value, true)

            local dragging = false
            Track(knob.MouseButton1Down:Connect(function() dragging = true end))
            Track(UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end))
            Track(UserInputService.InputChanged:Connect(function(i)
                if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local relX = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                    UpdateSlider(min + (max - min) * (relX / track.AbsoluteSize.X))
                end
            end))
            Track(track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local relX = math.clamp(i.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                    UpdateSlider(min + (max - min) * (relX / track.AbsoluteSize.X))
                    dragging = true
                end
            end))

            local Slider = {}
            function Slider:Set(v, silent) UpdateSlider(v, silent) end
            function Slider:Get() return value end

            if configKey then
                Window._configEls[configKey] = {
                    Get = function() return value end,
                    Set = function(v) Slider:Set(v, true) end,
                }
            end
            return Slider
        end

        -- ── TextBox ──────────────────────────────────────────
        function Tab:AddTextBox(opts)
            opts = opts or {}
            local T            = self._T
            local label        = opts.Label        or "Input"
            local placeholder  = opts.Placeholder  or "Enter text..."
            local default      = opts.Default      or ""
            local callback     = opts.Callback     or function() end
            local clearOnFocus = opts.ClearOnFocus ~= false
            local configKey    = opts.ConfigKey

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,56), nil, T.Card, "TBCard")
            card.LayoutOrder = NextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 8, 12, 12)

            NewLabel(card, label, UDim2.new(1,0,0,16),
                T.TextMuted, "Lbl", Enum.Font.GothamSemibold, 11)

            local inputBg = NewFrame(card, UDim2.new(1,0,0,26), UDim2.new(0,0,0,22), T.Panel, "InputBg")
            MakeRound(inputBg, 6)
            local stroke = MakeStroke(inputBg, T.Border, 1, 0.4)

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
            tb.Parent                 = inputBg
            MakePadding(tb, 0, 0, 8, 8)

            Track(tb.Focused:Connect(function()
                Tween(inputBg, {BackgroundColor3 = T.Card}, "fast")
                stroke.Color        = T.Accent
                stroke.Transparency = 0.3
            end))
            Track(tb.FocusLost:Connect(function(enter)
                Tween(inputBg, {BackgroundColor3 = T.Panel}, "fast")
                stroke.Color        = T.Border
                stroke.Transparency = 0.4
                SafeCall(callback, tb.Text, enter)
            end))

            local TB = {}
            function TB:Set(v) tb.Text = tostring(v) end
            function TB:Get() return tb.Text end

            if configKey then
                Window._configEls[configKey] = {
                    Get = function() return tb.Text end,
                    Set = function(v) TB:Set(v) end,
                }
            end
            return TB
        end

        -- ── Dropdown ─────────────────────────────────────────
        function Tab:AddDropdown(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Dropdown"
            local options  = opts.Options  or {}
            local default  = opts.Default  or (options[1] or "Select...")
            local callback = opts.Callback or function() end
            local multi    = opts.Multi    or false
            local configKey = opts.ConfigKey

            local selected = multi and {} or default
            if multi and default then selected[default] = true end

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,56), nil, T.Card, "DDCard")
            card.LayoutOrder    = NextOrder()
            card.ClipsDescendants = false
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 8, 12, 12)

            NewLabel(card, label, UDim2.new(1,0,0,16),
                T.TextMuted, "Lbl", Enum.Font.GothamSemibold, 11)

            local trigger = NewButton(card, UDim2.new(1,0,0,26), UDim2.new(0,0,0,22), T.Panel, "Trigger")
            MakeRound(trigger, 6)
            MakeStroke(trigger, T.Border, 1, 0.4)
            MakePadding(trigger, 0, 0, 8, 28)

            local function GetDisplayText()
                if multi then
                    local keys = {}
                    for k in pairs(selected) do table.insert(keys, k) end
                    return #keys == 0 and "None" or table.concat(keys, ", ")
                end
                return selected
            end

            local trigLbl = NewLabel(trigger, GetDisplayText(), UDim2.new(1,0,1,0),
                T.Text, "Txt", Enum.Font.Gotham, 12)
            local arrow = NewLabel(trigger, "▾", UDim2.new(0,20,1,0),
                T.TextMuted, "Arr", Enum.Font.GothamBold, 12)
            arrow.Position       = UDim2.new(1,-22,0,0)
            arrow.TextXAlignment = Enum.TextXAlignment.Center

            local open = false
            local menu = nil

            local function CloseMenu()
                if menu then pcall(function() menu:Destroy() end) menu = nil end
                open = false
                Tween(arrow, {Rotation = 0}, "fast")
            end

            local outsideConn = nil

            Track(trigger.MouseButton1Click:Connect(function()
                open = not open
                if not open then CloseMenu() return end

                Tween(arrow, {Rotation = 180}, "fast")

                local menuH = math.min(#options, 6) * 28 + 10
                menu = NewFrame(card, UDim2.new(1,0,0,menuH),
                    UDim2.new(0,0,0,56), T.Panel, "Menu")
                menu.ZIndex           = 15
                menu.ClipsDescendants = true
                MakeRound(menu, 8)
                MakeStroke(menu, T.Border, 1, 0.4)
                MakePadding(menu, 4, 4, 4, 4)

                local container = menu
                if #options > 6 then
                    local sf = Instance.new("ScrollingFrame")
                    sf.Size                   = UDim2.new(1,0,1,0)
                    sf.BackgroundTransparency = 1
                    sf.BorderSizePixel        = 0
                    sf.ScrollBarThickness     = 3
                    sf.ScrollBarImageColor3   = T.Scrollbar
                    sf.CanvasSize             = UDim2.new(0,0,0,#options*28)
                    sf.Parent                 = menu
                    container = sf
                end

                local mLayout = Instance.new("UIListLayout")
                mLayout.SortOrder = Enum.SortOrder.LayoutOrder
                mLayout.Parent    = container

                for _, opt in ipairs(options) do
                    local isSelected = multi and selected[opt] or (selected == opt)
                    local item = NewButton(container, UDim2.new(1,0,0,28), nil, T.Panel, "Item")
                    MakeRound(item, 5)
                    MakePadding(item, 0, 0, 8, 8)
                    local iLbl = NewLabel(item, opt, UDim2.new(1,0,1,0),
                        isSelected and T.Accent or T.Text, "ILbl", Enum.Font.Gotham, 12)

                    Track(item.MouseEnter:Connect(function() Tween(item, {BackgroundColor3 = T.Card},  "fast") end))
                    Track(item.MouseLeave:Connect(function() Tween(item, {BackgroundColor3 = T.Panel}, "fast") end))
                    Track(item.MouseButton1Click:Connect(function()
                        if multi then
                            if selected[opt] then selected[opt] = nil else selected[opt] = true end
                            iLbl.TextColor3 = selected[opt] and T.Accent or T.Text
                            trigLbl.Text    = GetDisplayText()
                            SafeCall(callback, selected)
                        else
                            selected        = opt
                            trigLbl.Text    = opt
                            SafeCall(callback, opt)
                            CloseMenu()
                        end
                    end))
                end

                -- Close on outside click
                if outsideConn then outsideConn:Disconnect() end
                outsideConn = Track(UserInputService.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        task.wait() -- let button clicks fire first
                        if menu and menu.Parent then
                            local mPos  = menu.AbsolutePosition
                            local mSize = menu.AbsoluteSize
                            local mx, my = i.Position.X, i.Position.Y
                            if mx < mPos.X or mx > mPos.X + mSize.X
                            or my < mPos.Y or my > mPos.Y + mSize.Y then
                                CloseMenu()
                            end
                        end
                    end
                end))
            end))

            local DD = {}
            function DD:Set(v) selected = v ; trigLbl.Text = GetDisplayText() end
            function DD:Get() return selected end
            function DD:SetOptions(newOpts)
                options = newOpts
                if not multi and not table.find(options, selected) then
                    selected = options[1] or "Select..."
                    trigLbl.Text = selected
                end
            end

            if configKey then
                Window._configEls[configKey] = {
                    Get = function() return selected end,
                    Set = function(v) DD:Set(v) end,
                }
            end
            return DD
        end

        -- ── SearchDropdown ────────────────────────────────────
        --   Like a dropdown but has a text box you can type in to filter options.
        function Tab:AddSearchDropdown(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Search"
            local options  = opts.Options  or {}
            local callback = opts.Callback or function() end
            local selected = opts.Default  or (options[1] or "Select...")

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,56), nil, T.Card, "SDD")
            card.LayoutOrder    = NextOrder()
            card.ClipsDescendants = false
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 8, 12, 12)

            NewLabel(card, label, UDim2.new(1,0,0,16),
                T.TextMuted, "Lbl", Enum.Font.GothamSemibold, 11)

            local inputBg = NewFrame(card, UDim2.new(1,0,0,26), UDim2.new(0,0,0,22), T.Panel, "InputBg")
            MakeRound(inputBg, 6)
            MakeStroke(inputBg, T.Border, 1, 0.4)

            local tb = Instance.new("TextBox")
            tb.Size                   = UDim2.new(1,-28,1,0)
            tb.BackgroundTransparency = 1
            tb.TextColor3             = T.Text
            tb.PlaceholderColor3      = T.TextDim
            tb.PlaceholderText        = selected
            tb.Font                   = Enum.Font.Gotham
            tb.TextSize               = 12
            tb.Text                   = ""
            tb.ClearTextOnFocus       = true
            tb.TextXAlignment         = Enum.TextXAlignment.Left
            tb.Parent                 = inputBg
            MakePadding(tb, 0, 0, 8, 8)

            local arrow = NewLabel(inputBg, "▾", UDim2.new(0,20,1,0),
                T.TextMuted, "Arr", Enum.Font.GothamBold, 12)
            arrow.Position       = UDim2.new(1,-22,0,0)
            arrow.TextXAlignment = Enum.TextXAlignment.Center

            local menu    = nil
            local menuOpen = false

            local function BuildMenu(filter)
                if menu then pcall(function() menu:Destroy() end) menu = nil end
                local filtered = {}
                local fl = filter:lower()
                for _, o in ipairs(options) do
                    if fl == "" or o:lower():find(fl, 1, true) then
                        table.insert(filtered, o)
                    end
                end
                if #filtered == 0 then return end

                local mH = math.min(#filtered, 5) * 28 + 8
                menu = NewFrame(card, UDim2.new(1,0,0,mH),
                    UDim2.new(0,0,0,56), T.Panel, "SDDMenu")
                menu.ZIndex           = 15
                menu.ClipsDescendants = true
                MakeRound(menu, 8)
                MakeStroke(menu, T.Border, 1, 0.4)
                MakePadding(menu, 4, 4, 4, 4)

                local sf = nil
                local container = menu
                if #filtered > 5 then
                    sf = Instance.new("ScrollingFrame")
                    sf.Size                   = UDim2.new(1,0,1,0)
                    sf.BackgroundTransparency = 1
                    sf.BorderSizePixel        = 0
                    sf.ScrollBarThickness     = 3
                    sf.ScrollBarImageColor3   = T.Scrollbar
                    sf.CanvasSize             = UDim2.new(0,0,0,#filtered*28)
                    sf.Parent                 = menu
                    container                 = sf
                end

                local mLayout = Instance.new("UIListLayout")
                mLayout.SortOrder = Enum.SortOrder.LayoutOrder
                mLayout.Parent    = container

                for _, opt in ipairs(filtered) do
                    local item = NewButton(container, UDim2.new(1,0,0,28), nil, T.Panel, "Item")
                    MakeRound(item, 5)
                    MakePadding(item, 0, 0, 8, 8)
                    NewLabel(item, opt, UDim2.new(1,0,1,0),
                        opt == selected and T.Accent or T.Text, "ILbl", Enum.Font.Gotham, 12)
                    Track(item.MouseEnter:Connect(function() Tween(item, {BackgroundColor3 = T.Card},  "fast") end))
                    Track(item.MouseLeave:Connect(function() Tween(item, {BackgroundColor3 = T.Panel}, "fast") end))
                    Track(item.MouseButton1Click:Connect(function()
                        selected = opt
                        tb.Text  = ""
                        tb.PlaceholderText = opt
                        SafeCall(callback, opt)
                        if menu then pcall(function() menu:Destroy() end) menu = nil end
                        menuOpen = false
                    end))
                end
            end

            Track(tb.Focused:Connect(function()
                menuOpen = true
                BuildMenu(tb.Text)
            end))
            Track(tb.FocusLost:Connect(function()
                task.wait(0.15)
                if menu then pcall(function() menu:Destroy() end) menu = nil end
                menuOpen = false
            end))
            Track(tb:GetPropertyChangedSignal("Text"):Connect(function()
                if menuOpen then BuildMenu(tb.Text) end
            end))

            local SDD = {}
            function SDD:Get() return selected end
            function SDD:Set(v) selected = v ; tb.PlaceholderText = v end
            return SDD
        end

        -- ── Keybind ──────────────────────────────────────────
        function Tab:AddKeybind(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Keybind"
            local default  = opts.Default  or Enum.KeyCode.Unknown
            local callback = opts.Callback or function() end
            local configKey = opts.ConfigKey

            local key       = default
            local listening = false

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,36), nil, T.Card, "KBCard")
            card.LayoutOrder = NextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 0, 0, 12, 12)

            NewLabel(card, label, UDim2.new(1,-80,1,0),
                T.Text, "Lbl", Enum.Font.GothamSemibold, 13)

            local keyBtn = NewButton(card, UDim2.new(0,70,0,22),
                UDim2.new(1,-72,0.5,-11), T.Panel, "KeyBtn")
            MakeRound(keyBtn, 5)
            MakeStroke(keyBtn, T.Border, 1, 0.4)

            local keyLbl = NewLabel(keyBtn, key.Name, UDim2.new(1,0,1,0),
                T.Accent, "KLbl", Enum.Font.GothamBold, 11)
            keyLbl.TextXAlignment = Enum.TextXAlignment.Center

            Track(keyBtn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                keyLbl.Text       = "..."
                keyLbl.TextColor3 = T.Warning
                local conn
                conn = Track(UserInputService.InputBegan:Connect(function(i, gpe)
                    if gpe then return end
                    if i.UserInputType == Enum.UserInputType.Keyboard then
                        key = i.KeyCode
                        keyLbl.Text       = key.Name
                        keyLbl.TextColor3 = T.Accent
                        listening = false
                        conn:Disconnect()
                    end
                end))
            end))

            Track(UserInputService.InputBegan:Connect(function(i, gpe)
                if gpe or listening then return end
                if i.KeyCode == key then SafeCall(callback) end
            end))

            local KB = {}
            function KB:Set(k) key = k ; keyLbl.Text = k.Name end
            function KB:Get() return key end

            if configKey then
                Window._configEls[configKey] = {
                    Get = function() return key.Name end,
                    Set = function(v)
                        local kc = Enum.KeyCode[v]
                        if kc then KB:Set(kc) end
                    end,
                }
            end
            return KB
        end

        -- ── ColorPicker ──────────────────────────────────────
        function Tab:AddColorPicker(opts)
            opts = opts or {}
            local T        = self._T
            local label    = opts.Label    or "Color"
            local default  = opts.Default  or Color3.fromRGB(255,100,100)
            local callback = opts.Callback or function() end
            local configKey = opts.ConfigKey

            local color   = default
            local h, s, v = Color3.toHSV(color)
            local open    = false
            local CLOSED_H, OPEN_H = 36, 36+140

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,CLOSED_H), nil, T.Card, "CPCard")
            card.LayoutOrder    = NextOrder()
            card.ClipsDescendants = true
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 0, 0, 12, 12)

            local lbl = NewLabel(card, label, UDim2.new(1,-50,0,36),
                T.Text, "Lbl", Enum.Font.GothamSemibold, 13)

            local preview = NewButton(card, UDim2.new(0,36,0,22),
                UDim2.new(1,-40,0,7), color, "Preview")
            MakeRound(preview, 5)
            MakeStroke(preview, T.Border, 1, 0.3)

            -- Picker body (hidden until opened)
            local pickerBody = NewFrame(card, UDim2.new(1,0,0,130),
                UDim2.new(0,0,0,40), T.Panel, "Picker")
            MakeRound(pickerBody, 8)
            MakePadding(pickerBody, 8, 8, 8, 8)

            -- Three HSV sliders
            local sliderData = {
                {label="H", getter=function() return h end, setter=function(p) h=p end},
                {label="S", getter=function() return s end, setter=function(p) s=p end},
                {label="V", getter=function() return v end, setter=function(p) v=p end},
            }
            local fills  = {}
            local knobs  = {}
            local tracks = {}

            local pLayout = Instance.new("UIListLayout")
            pLayout.SortOrder = Enum.SortOrder.LayoutOrder
            pLayout.Padding   = UDim.new(0, 6)
            pLayout.Parent    = pickerBody

            local function UpdateAll(silent)
                color = Color3.fromHSV(h, s, v)
                preview.BackgroundColor3 = color
                for i, d in ipairs(sliderData) do
                    local pct = d.getter()
                    fills[i].Size     = UDim2.new(pct,0,1,0)
                    knobs[i].Position = UDim2.new(pct,-6,0.5,-6)
                end
                if not silent then SafeCall(callback, color) end
            end

            for i, d in ipairs(sliderData) do
                local row = NewFrame(pickerBody, UDim2.new(1,0,0,26), nil,
                    T.Panel, "Row"..d.label)
                row.BackgroundTransparency = 1
                row.LayoutOrder = i

                local rowLbl = NewLabel(row, d.label, UDim2.new(0,14,1,0),
                    T.TextMuted, "L", Enum.Font.GothamBold, 10)
                rowLbl.TextXAlignment = Enum.TextXAlignment.Center

                local track = NewFrame(row, UDim2.new(1,-20,0,6),
                    UDim2.new(0,20,0.5,-3), T.Card, "Track")
                MakeRound(track, 3)
                local fill = NewFrame(track, UDim2.new(0,0,1,0), nil, T.Accent, "Fill")
                MakeRound(fill, 3)
                local knob = NewButton(track, UDim2.new(0,12,0,12),
                    UDim2.new(0,-6,0.5,-6), Color3.new(1,1,1), "Knob")
                MakeRound(knob, 6)

                fills[i]  = fill
                knobs[i]  = knob
                tracks[i] = track

                local dr = false
                Track(knob.MouseButton1Down:Connect(function() dr = true end))
                Track(UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dr = false end
                end))
                Track(UserInputService.InputChanged:Connect(function(inp)
                    if dr and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local pct = math.clamp(
                            (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        d.setter(pct)
                        UpdateAll()
                    end
                end))
                Track(track.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        local pct = math.clamp(
                            (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        d.setter(pct)
                        UpdateAll()
                        dr = true
                    end
                end))
            end
            UpdateAll(true)

            Track(preview.MouseButton1Click:Connect(function()
                open = not open
                Tween(card, {Size = UDim2.new(1,0,0, open and OPEN_H or CLOSED_H)}, "normal")
            end))

            local CP = {}
            function CP:Set(c, silent)
                color = c
                h, s, v = Color3.toHSV(c)
                preview.BackgroundColor3 = c
                UpdateAll(silent)
            end
            function CP:Get() return color end

            if configKey then
                Window._configEls[configKey] = {
                    Get = function()
                        return string.format("%d,%d,%d",
                            math.floor(color.R*255+0.5),
                            math.floor(color.G*255+0.5),
                            math.floor(color.B*255+0.5))
                    end,
                    Set = function(str)
                        local r,g,b = str:match("(%d+),(%d+),(%d+)")
                        if r then CP:Set(Color3.fromRGB(tonumber(r),tonumber(g),tonumber(b)), true) end
                    end,
                }
            end
            return CP
        end

        -- ── ProgressBar ──────────────────────────────────────
        --   A read-only visual bar (use :Set(pct) to update, 0–1).
        function Tab:AddProgressBar(opts)
            opts = opts or {}
            local T       = self._T
            local label   = opts.Label   or "Progress"
            local default = opts.Default or 0   -- 0 to 1
            local suffix  = opts.Suffix  or "%"
            local color   = opts.Color   or T.Accent

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,44), nil, T.Card, "PBCard")
            card.LayoutOrder = NextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 8, 8, 12, 12)

            local topRow = NewFrame(card, UDim2.new(1,0,0,16), nil, T.Card, "Top")
            topRow.BackgroundTransparency = 1
            NewLabel(topRow, label, UDim2.new(0.7,0,1,0),
                T.Text, "Lbl", Enum.Font.GothamSemibold, 12)
            local valLbl = NewLabel(topRow, math.floor(default*100)..suffix,
                UDim2.new(0.3,0,1,0), T.Accent, "Val", Enum.Font.GothamBold, 12)
            valLbl.Position       = UDim2.new(0.7,0,0,0)
            valLbl.TextXAlignment = Enum.TextXAlignment.Right

            local track = NewFrame(card, UDim2.new(1,0,0,8), UDim2.new(0,0,0,22), T.Panel, "Track")
            MakeRound(track, 4)
            local fill = NewFrame(track, UDim2.new(math.clamp(default,0,1),0,1,0), nil, color, "Fill")
            MakeRound(fill, 4)

            local PB = {}
            function PB:Set(pct)
                pct = math.clamp(pct, 0, 1)
                Tween(fill, {Size = UDim2.new(pct,0,1,0)}, "normal")
                valLbl.Text = math.floor(pct*100)..suffix
            end
            function PB:SetColor(c)
                color = c
                fill.BackgroundColor3 = c
            end
            return PB
        end

        -- ── Label ─────────────────────────────────────────────
        function Tab:AddLabel(opts)
            opts = opts or {}
            local T     = self._T
            local text  = opts.Text  or "Label"
            local color = opts.Color or T.TextMuted

            local lbl = NewLabel(self._scroll, text, UDim2.new(1,0,0,0),
                color, "StandaloneLbl", Enum.Font.Gotham, 12)
            lbl.AutomaticSize = Enum.AutomaticSize.Y
            lbl.TextWrapped   = true
            lbl.LayoutOrder   = NextOrder()

            local L = {}
            function L:Set(t) lbl.Text = t end
            function L:SetColor(c) lbl.TextColor3 = c end
            return L
        end

        -- ── Separator ─────────────────────────────────────────
        function Tab:AddSeparator()
            local T   = self._T
            local sep = NewFrame(self._scroll, UDim2.new(1,0,0,1), nil, T.Border, "Sep")
            sep.BackgroundTransparency = 0.5
            sep.LayoutOrder = NextOrder()
        end

        -- ── Paragraph ─────────────────────────────────────────
        function Tab:AddParagraph(opts)
            opts = opts or {}
            local T      = self._T
            local ptitle = opts.Title or ""
            local body   = opts.Body  or ""

            local card = NewFrame(self._scroll, UDim2.new(1,0,0,0), nil, T.Card, "ParaCard")
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.LayoutOrder   = NextOrder()
            MakeRound(card, 8)
            MakeStroke(card, T.Border, 1, 0.7)
            MakePadding(card, 10, 10, 12, 12)

            local pLayout = Instance.new("UIListLayout")
            pLayout.SortOrder = Enum.SortOrder.LayoutOrder
            pLayout.Padding   = UDim.new(0, 4)
            pLayout.Parent    = card

            local titleLblRef = nil
            if ptitle ~= "" then
                titleLblRef = NewLabel(card, ptitle, UDim2.new(1,0,0,16),
                    T.Text, "PTitle", Enum.Font.GothamBold, 13)
                titleLblRef.LayoutOrder = 1
            end
            local bodyLbl = NewLabel(card, body, UDim2.new(1,0,0,0),
                T.TextMuted, "PBody", Enum.Font.Gotham, 12)
            bodyLbl.AutomaticSize = Enum.AutomaticSize.Y
            bodyLbl.TextWrapped   = true
            bodyLbl.LayoutOrder   = 2

            local P = {}
            function P:SetTitle(t) if titleLblRef then titleLblRef.Text = t end end
            function P:SetBody(t)  bodyLbl.Text = t end
            return P
        end

        table.insert(self._tabs, Tab)
        return Tab
    end

    -- ── Config: Save ─────────────────────────────────────────
    function Window:SaveConfig(name)
        if not (writefile and makefolder) then
            warn("[NexusLib] Filesystem functions unavailable — cannot save config.")
            return
        end
        EnsureFolder()
        local data = {}
        for k, el in pairs(self._configEls) do
            local ok, val = pcall(el.Get)
            if ok then data[k] = val end
        end
        local ok, err = pcall(writefile,
            CONFIG_FOLDER .. "/" .. name .. ".json",
            HttpService:JSONEncode(data))
        if not ok then warn("[NexusLib] SaveConfig failed:", err) end
    end

    -- ── Config: Load ─────────────────────────────────────────
    function Window:LoadConfig(name)
        if not (readfile and isfile) then
            warn("[NexusLib] Filesystem functions unavailable — cannot load config.")
            return
        end
        local path = CONFIG_FOLDER .. "/" .. name .. ".json"
        if not isfile(path) then
            warn("[NexusLib] Config not found:", path)
            return
        end
        local ok, raw = pcall(readfile, path)
        if not ok then warn("[NexusLib] LoadConfig read failed:", raw) return end
        local data
        ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if not ok then warn("[NexusLib] LoadConfig parse failed:", data) return end
        for k, val in pairs(data) do
            if self._configEls[k] then
                pcall(self._configEls[k].Set, val)
            end
        end
    end

    -- ── Destroy ──────────────────────────────────────────────
    function Window:Destroy()
        for _, conn in ipairs(self._connections) do
            pcall(function() conn:Disconnect() end)
        end
        pcall(function() self._sg:Destroy() end)
    end

    return Window
end

-- ============================================================
--  LIBRARY META
-- ============================================================
NexusLib.Version = "2.0.0"
NexusLib.Themes  = Themes

function NexusLib:GetThemeNames()
    local names = {}
    for k in pairs(Themes) do table.insert(names, k) end
    table.sort(names)
    return names
end

return NexusLib
