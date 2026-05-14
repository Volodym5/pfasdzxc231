-- ============================================================
--  OBSIDIAN UI  ·  v4.0
--  Professional Roblox UI Library
-- ============================================================

local Library = {}
Library.__index = Library

-- ── Services ────────────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")

-- ── Palette ─────────────────────────────────────────────────
local C = {
    W0 = Color3.fromRGB(11,  11,  15),   -- deepest
    W1 = Color3.fromRGB(17,  17,  23),   -- sidebar / header bg
    W2 = Color3.fromRGB(23,  23,  31),   -- content bg
    W3 = Color3.fromRGB(31,  31,  41),   -- section card
    W4 = Color3.fromRGB(40,  40,  53),   -- element bg
    W5 = Color3.fromRGB(52,  52,  68),   -- hover
    W6 = Color3.fromRGB(65,  65,  84),   -- pressed / active edge

    T0 = Color3.fromRGB(240, 240, 245),  -- primary text
    T1 = Color3.fromRGB(155, 155, 175),  -- secondary
    T2 = Color3.fromRGB(88,   88, 115),  -- muted
    T3 = Color3.fromRGB(55,   55,  75),  -- disabled

    Ok  = Color3.fromRGB(72,  199, 130),
    Err = Color3.fromRGB(220,  88, 100),
    Wrn = Color3.fromRGB(220, 170,  75),

    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0,   0,   0),
}

-- ── Easing ──────────────────────────────────────────────────
local Exp   = Enum.EasingStyle.Exponential
local Out   = Enum.EasingDirection.Out
local In    = Enum.EasingDirection.In
local InOut = Enum.EasingDirection.InOut

local EFast = TweenInfo.new(0.18, Exp, Out)
local EMed  = TweenInfo.new(0.30, Exp, Out)
local ESlow = TweenInfo.new(0.50, Exp, Out)

-- ── Core helpers ─────────────────────────────────────────────
local function tw(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

local function rnd(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
    return c
end

local function bdr(obj, col, thick, alpha)
    local s = Instance.new("UIStroke")
    s.Color           = col or C.White
    s.Thickness       = thick or 1
    s.Transparency    = alpha ~= nil and alpha or 0.88
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent          = obj
    return s
end

local function pad(obj, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.Parent        = obj
    return p
end

local function list(obj, gap, dir)
    local l = Instance.new("UIListLayout")
    l.SortOrder  = Enum.SortOrder.LayoutOrder
    l.Padding    = UDim.new(0, gap or 0)
    if dir then l.FillDirection = dir end
    l.Parent = obj
    return l
end

-- Frames, labels, buttons with sane defaults
local function frm(props)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    for k, v in pairs(props) do f[k] = v end
    return f
end

local function lbl(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel        = 0
    l.Font                   = Enum.Font.GothamMedium
    l.TextXAlignment         = Enum.TextXAlignment.Left
    for k, v in pairs(props) do l[k] = v end
    return l
end

local function btn(props)
    local b = Instance.new("TextButton")
    b.BorderSizePixel  = 0
    b.AutoButtonColor  = false
    b.BackgroundColor3 = C.W4
    b.Text             = ""
    b.Font             = Enum.Font.GothamMedium
    b.TextXAlignment   = Enum.TextXAlignment.Left
    for k, v in pairs(props) do b[k] = v end
    return b
end

-- Color helpers
local function hsv(h, s, v)    return Color3.fromHSV(h, s, v) end
local function toHSV(c)        local h,s,v = Color3.toHSV(c); return h,s,v end
local function toHex(c)        return string.format("%02X%02X%02X", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)) end
local function fromHex(h)
    h = h:gsub("#","")
    if #h == 6 then return Color3.fromRGB(tonumber("0x"..h:sub(1,2)), tonumber("0x"..h:sub(3,4)), tonumber("0x"..h:sub(5,6))) end
    return C.White
end

-- ── Notification system (standalone, top-right toasts) ───────
local _notifHolder
local function ensureNotif()
    if _notifHolder and _notifHolder.Parent then return end
    local sg = Instance.new("ScreenGui")
    sg.Name           = "ObsidianNotifs"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    sg.DisplayOrder   = 500
    sg.IgnoreGuiInset = true
    sg.Parent         = CoreGui

    _notifHolder = frm({
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(1, -310, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 500,
        Parent = sg,
    })
    list(_notifHolder, 8)
    pad(_notifHolder, 12, 0, 12, 0)
end

local function pushNotif(title, text, icon, duration, ntype)
    ensureNotif()
    duration = duration or 4
    local acol = ntype == "success" and C.Ok
               or ntype == "error"   and C.Err
               or ntype == "warn"    and C.Wrn
               or Color3.fromRGB(110, 168, 255)

    local card = frm({
        Size = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = C.W3,
        ZIndex = 501,
        Parent = _notifHolder,
    })
    rnd(card, 7)
    bdr(card, C.White, 1, 0.84)

    -- left accent stripe
    local stripe = frm({Size=UDim2.new(0,3,1,-16),Position=UDim2.new(0,0,0.5,-28),BackgroundColor3=acol,ZIndex=502,Parent=card})
    rnd(stripe, 2)

    lbl({Size=UDim2.new(0,22,0,22),Position=UDim2.new(0,14,0,12),Text=icon or "●",TextSize=15,TextColor3=acol,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=502,Parent=card})
    lbl({Size=UDim2.new(1,-50,0,18),Position=UDim2.new(0,40,0,10),Text=title,TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.T0,ZIndex=502,Parent=card})
    lbl({Size=UDim2.new(1,-50,0,30),Position=UDim2.new(0,40,0,30),Text=text,TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.T1,TextWrapped=true,ZIndex=502,Parent=card})

    local progBg = frm({Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=acol,BackgroundTransparency=0.55,ZIndex=502,Parent=card})
    rnd(progBg, 1)
    tw(progBg, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,0,2)})

    -- slide in from right
    card.Position = UDim2.new(1, 12, 0, 0)
    tw(card, EMed, {Position = UDim2.new(0, 0, 0, 0)})

    task.delay(duration, function()
        tw(card, EFast, {Position = UDim2.new(1, 12, 0, 0), BackgroundTransparency = 1})
        task.wait(0.22)
        card:Destroy()
    end)
end

-- ═══════════════════════════════════════════════════════════
--  WINDOW
-- ═══════════════════════════════════════════════════════════

local WIN_W    = 860
local WIN_H    = 560
local HDR_H    = 48
local SIDE_W   = 162
local RADIUS   = 8   -- window corner radius

function Library.CreateWindow(cfg)
    local self   = setmetatable({}, Library)
    cfg          = cfg or {}
    self.Accent  = cfg.Accent or Color3.fromRGB(110, 168, 255)
    self.Tabs    = {}
    self.Keybinds = {}
    self.Conns   = {}
    self.IsMin   = false

    -- ── ScreenGui ── ZIndexBehavior.Global so overlay ZIndex is absolute ──
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name           = cfg.Name or "ObsidianUI"
    self.Gui.ResetOnSpawn   = false
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.Gui.DisplayOrder   = cfg.DisplayOrder or 10
    self.Gui.IgnoreGuiInset = true
    self.Gui.Parent         = cfg.Parent or CoreGui

    -- ── Overlay for dropdowns — ZIndex 5000, always on top ──────────────
    self.Overlay = frm({
        Name = "Overlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 5000,
        Parent = self.Gui,
    })

    -- Invisible full-screen button to dismiss open dropdowns
    local dismissBtn = btn({
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        ZIndex = 4999,
        Visible = false,
        Parent = self.Overlay,
    })
    self._dismiss = dismissBtn
    self._closeDD = nil   -- fn to close currently open dropdown

    dismissBtn.MouseButton1Click:Connect(function()
        dismissBtn.Visible = false
        if self._closeDD then self._closeDD(); self._closeDD = nil end
    end)

    -- ── Window frame ──────────────────────────────────────────────────────
    self.Win = frm({
        Name = "Win",
        Size = UDim2.new(0, WIN_W, 0, WIN_H),
        Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
        BackgroundColor3 = C.W1,
        ZIndex = 10,
        Parent = self.Gui,
    })
    rnd(self.Win, RADIUS)
    bdr(self.Win, C.White, 1, 0.88)

    -- Drop shadow
    local shad = Instance.new("ImageLabel")
    shad.Name              = "Shadow"
    shad.Image             = "rbxassetid://6014261993"
    shad.ImageColor3       = C.Black
    shad.ImageTransparency = 0.60
    shad.ScaleType         = Enum.ScaleType.Slice
    shad.SliceCenter       = Rect.new(49,49,49,49)
    shad.AnchorPoint       = Vector2.new(0.5, 0.5)
    shad.Size              = UDim2.new(1, 56, 1, 56)
    shad.Position          = UDim2.new(0.5, 0, 0.5, 8)
    shad.BackgroundTransparency = 1
    shad.ZIndex            = 9
    shad.Parent            = self.Win

    -- ── Clip frame — MUST have same UICorner radius so ClipsDescendants
    --    clips to the rounded shape instead of a rectangle ────────────────
    local clip = frm({
        Name = "Clip",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = self.Win,
    })
    rnd(clip, RADIUS)   -- ← THE FIX: matching radius rounds the clip boundary

    -- ── Header ───────────────────────────────────────────────────────────
    local hdr = frm({
        Name = "Header",
        Size = UDim2.new(1, 0, 0, HDR_H),
        BackgroundColor3 = C.W1,
        ZIndex = 20,
        Parent = clip,
    })
    -- header bottom divider
    frm({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.White,BackgroundTransparency=0.91,ZIndex=21,Parent=hdr})

    -- Logo square
    local logo = frm({
        Size = UDim2.new(0,24,0,24),
        Position = UDim2.new(0,14,0.5,-12),
        BackgroundColor3 = self.Accent,
        ZIndex = 21,
        Parent = hdr,
    })
    rnd(logo, 6)
    lbl({
        Size=UDim2.new(1,0,1,0),Text=(cfg.Title or "O"):sub(1,1):upper(),
        TextSize=13,Font=Enum.Font.GothamBlack,TextColor3=C.W1,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=22,Parent=logo,
    })

    lbl({
        Size=UDim2.new(0,200,0,18),Position=UDim2.new(0,46,0,8),
        Text=cfg.Title or "Obsidian",TextSize=14,Font=Enum.Font.GothamBold,
        TextColor3=C.T0,ZIndex=21,Parent=hdr,
    })
    lbl({
        Size=UDim2.new(0,200,0,14),Position=UDim2.new(0,46,0,27),
        Text=cfg.Subtitle or "",TextSize=10,Font=Enum.Font.Gotham,
        TextColor3=C.T2,ZIndex=21,Parent=hdr,
    })

    -- Window control dots
    local function mkDot(xOff, col)
        local d = btn({
            Size=UDim2.new(0,13,0,13),Position=UDim2.new(1,xOff,0.5,-6),
            BackgroundColor3=col,BackgroundTransparency=0.25,ZIndex=21,Parent=hdr,
        })
        rnd(d, 7)
        d.MouseEnter:Connect(function()  tw(d, EFast, {BackgroundTransparency=0}) end)
        d.MouseLeave:Connect(function()  tw(d, EFast, {BackgroundTransparency=0.25}) end)
        return d
    end

    local dotClose = mkDot(-32, C.Err)
    local dotMin   = mkDot(-52, C.Wrn)
    local dotHide  = mkDot(-72, C.Ok)

    -- ── Body ─────────────────────────────────────────────────────────────
    -- Body is defined HERE, before connecting button callbacks,
    -- so closures below can safely reference it.
    local body = frm({
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -HDR_H),
        Position = UDim2.new(0, 0, 0, HDR_H),
        BackgroundTransparency = 1,
        ZIndex = 11,
        Parent = clip,
    })

    -- ── Sidebar ───────────────────────────────────────────────────────────
    local sidebar = frm({
        Name = "Sidebar",
        Size = UDim2.new(0, SIDE_W, 1, 0),
        BackgroundColor3 = C.W1,
        ZIndex = 12,
        Parent = body,
    })
    frm({Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BackgroundColor3=C.White,BackgroundTransparency=0.91,ZIndex=13,Parent=sidebar})

    -- Version footer inside sidebar
    local sideFooter = frm({
        Size=UDim2.new(1,0,0,40),Position=UDim2.new(0,0,1,-40),
        BackgroundColor3=C.W1,ZIndex=13,Parent=sidebar,
    })
    frm({Size=UDim2.new(1,0,0,1),BackgroundColor3=C.White,BackgroundTransparency=0.91,ZIndex=14,Parent=sideFooter})
    lbl({
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),
        Text="Obsidian  ·  v4.0",TextSize=9,Font=Enum.Font.Gotham,
        TextColor3=C.T3,ZIndex=14,Parent=sideFooter,
    })

    -- Tab scroll
    self.TabScroll = Instance.new("ScrollingFrame")
    self.TabScroll.Size               = UDim2.new(1, 0, 1, -40)
    self.TabScroll.BackgroundTransparency = 1
    self.TabScroll.ScrollBarThickness = 0
    self.TabScroll.CanvasSize         = UDim2.new(0,0,0,0)
    self.TabScroll.ClipsDescendants   = true
    self.TabScroll.ZIndex             = 13
    self.TabScroll.Parent             = sidebar
    pad(self.TabScroll, 8, 6, 8, 6)
    local tabList = list(self.TabScroll, 2)
    tabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.TabScroll.CanvasSize = UDim2.new(0,0,0, tabList.AbsoluteContentSize.Y + 16)
    end)

    -- ── Content area ──────────────────────────────────────────────────────
    self.Content = frm({
        Name = "Content",
        Size = UDim2.new(1, -SIDE_W, 1, 0),
        Position = UDim2.new(0, SIDE_W, 0, 0),
        BackgroundColor3 = C.W2,
        ZIndex = 11,
        Parent = body,
    })

    -- ── Button callbacks (body is now defined above) ──────────────────────
    dotClose.MouseButton1Click:Connect(function()
        body.Visible = false
        tw(self.Win, EMed, {BackgroundTransparency = 1})
        task.wait(0.30)
        self.Gui:Destroy()
        if cfg.OnClose then cfg.OnClose() end
    end)

    dotMin.MouseButton1Click:Connect(function()
        self.IsMin = not self.IsMin
        if self.IsMin then
            body.Visible = false
            tw(self.Win, EMed, {Size = UDim2.new(0, WIN_W, 0, HDR_H)})
        else
            tw(self.Win, EMed, {Size = UDim2.new(0, WIN_W, 0, WIN_H)})
            task.delay(0.25, function()
                if not self.IsMin then body.Visible = true end
            end)
        end
    end)

    dotHide.MouseButton1Click:Connect(function()
        self.Gui.Enabled = false
    end)

    -- ── Dragging ──────────────────────────────────────────────────────────
    local dStart, wStart
    hdr.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dStart = inp.Position
            wStart = self.Win.Position
        end
    end)
    hdr.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dStart = nil
        end
    end)
    table.insert(self.Conns, UserInputService.InputChanged:Connect(function(inp)
        if dStart and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dStart
            self.Win.Position = UDim2.new(
                wStart.X.Scale, wStart.X.Offset + d.X,
                wStart.Y.Scale, wStart.Y.Offset + d.Y)
            -- close any open dropdown when window is dragged
            if self._closeDD then
                self._dismiss.Visible = false
                self._closeDD()
                self._closeDD = nil
            end
        end
    end))

    -- ── Keybind dispatcher ────────────────────────────────────────────────
    table.insert(self.Conns, UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        for _, kb in pairs(self.Keybinds) do
            if kb.Key and inp.KeyCode == kb.Key and not kb._busy then
                task.spawn(kb._fn)
            end
        end
    end))

    -- ── Entrance animation ────────────────────────────────────────────────
    self.Win.BackgroundTransparency = 1
    self.Win.Size = UDim2.new(0, WIN_W, 0, WIN_H - 30)
    task.defer(function()
        tw(self.Win, EMed, {BackgroundTransparency = 0, Size = UDim2.new(0, WIN_W, 0, WIN_H)})
    end)

    return self
end

-- ── Notify (instance method) ──────────────────────────────────
function Library:Notify(opts)
    opts = opts or {}
    pushNotif(opts.Title or "Notice", opts.Text or "", opts.Icon or "●", opts.Duration or 4, opts.Type or "info")
end

-- ── Toggle visibility ────────────────────────────────────────
function Library:Toggle()
    self.Gui.Enabled = not self.Gui.Enabled
end

-- ── Destroy ──────────────────────────────────────────────────
function Library:Destroy()
    for _, c in ipairs(self.Conns) do c:Disconnect() end
    self.Gui:Destroy()
end

-- ═══════════════════════════════════════════════════════════
--  TABS
-- ═══════════════════════════════════════════════════════════
function Library:CreateTab(icon, name)
    local tab = { Active = false }

    -- Sidebar button
    local tbtn = btn({
        Name = name.."_Tab",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = C.W4,
        BackgroundTransparency = 1,
        ZIndex = 14,
        LayoutOrder = #self.Tabs + 1,
        Parent = self.TabScroll,
    })
    rnd(tbtn, 5)

    -- Active indicator bar
    local bar = frm({
        Size = UDim2.new(0, 3, 0, 18),
        Position = UDim2.new(0, 0, 0.5, -9),
        BackgroundColor3 = self.Accent,
        BackgroundTransparency = 1,
        ZIndex = 16,
        Parent = tbtn,
    })
    rnd(bar, 2)

    -- Icon
    local ico = lbl({
        Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,10,0.5,-10),
        Text=icon or "○",TextSize=14,TextXAlignment=Enum.TextXAlignment.Center,
        TextColor3=C.T2,ZIndex=15,Parent=tbtn,
    })

    -- Name
    local nam = lbl({
        Size=UDim2.new(1,-38,1,0),Position=UDim2.new(0,36,0,0),
        Text=name,TextSize=12,Font=Enum.Font.GothamMedium,
        TextColor3=C.T2,ZIndex=15,Parent=tbtn,
    })

    -- Tab page
    local page = Instance.new("ScrollingFrame")
    page.Name               = name.."_Page"
    page.Size               = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = self.Accent
    page.ScrollBarImageTransparency = 0.45
    page.CanvasSize         = UDim2.new(0,0,0,0)
    page.Visible            = false
    page.ZIndex             = 12
    page.ElasticBehavior    = Enum.ElasticBehavior.Never
    page.Parent             = self.Content
    pad(page, 12, 12, 20, 12)
    local pageList = list(page, 8)
    pageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0, pageList.AbsoluteContentSize.Y + 32)
    end)

    tab._btn  = tbtn
    tab._bar  = bar
    tab._ico  = ico
    tab._nam  = nam
    tab._page = page

    tbtn.MouseEnter:Connect(function()
        if not tab.Active then
            tw(tbtn, EFast, {BackgroundTransparency = 0.84, BackgroundColor3 = C.W4})
        end
    end)
    tbtn.MouseLeave:Connect(function()
        if not tab.Active then
            tw(tbtn, EFast, {BackgroundTransparency = 1})
        end
    end)
    tbtn.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then self:SelectTab(tab) end
    return tab
end

function Library:SelectTab(target)
    for _, t in ipairs(self.Tabs) do
        local on = (t == target)
        t.Active = on
        t._page.Visible = on

        if on then
            tw(t._btn, EFast, {BackgroundTransparency = 0.84, BackgroundColor3 = C.W4})
            tw(t._bar, EFast, {BackgroundTransparency = 0})
            tw(t._ico, EFast, {TextColor3 = self.Accent})
            tw(t._nam, EFast, {TextColor3 = C.T0})
        else
            tw(t._btn, EFast, {BackgroundTransparency = 1})
            tw(t._bar, EFast, {BackgroundTransparency = 1})
            tw(t._ico, EFast, {TextColor3 = C.T2})
            tw(t._nam, EFast, {TextColor3 = C.T2})
        end
    end
end

-- ═══════════════════════════════════════════════════════════
--  SECTION
-- ═══════════════════════════════════════════════════════════
function Library:CreateSection(tab, title)
    local sec = {}

    local card = frm({
        Name = (title or "Sec").."_Card",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.W3,
        ZIndex = 13,
        LayoutOrder = #tab._page:GetChildren() + 1,
        Parent = tab._page,
    })
    rnd(card, 6)
    bdr(card, C.White, 1, 0.90)

    local yOffset = 10

    if title then
        yOffset = 42
        local sh = frm({Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,ZIndex=14,Parent=card})

        -- accent dot
        local dot = frm({Size=UDim2.new(0,5,0,5),Position=UDim2.new(0,12,0.5,-2),BackgroundColor3=self.Accent,ZIndex=15,Parent=sh})
        rnd(dot, 3)

        lbl({
            Size=UDim2.new(1,-36,1,0),Position=UDim2.new(0,23,0,0),
            Text=title:upper(),TextSize=9,Font=Enum.Font.GothamBold,
            TextColor3=C.T2,ZIndex=15,Parent=sh,
        })

        -- collapse chevron
        local collapsed = false
        local chev = btn({
            Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-24,0.5,-10),
            BackgroundTransparency=1,Text="▾",TextSize=12,
            TextColor3=C.T3,TextXAlignment=Enum.TextXAlignment.Center,
            ZIndex=15,Parent=sh,
        })

        -- bottom divider
        frm({Size=UDim2.new(1,-24,0,1),Position=UDim2.new(0,12,1,-1),BackgroundColor3=C.White,BackgroundTransparency=0.91,ZIndex=14,Parent=sh})

        chev.MouseButton1Click:Connect(function()
            collapsed = not collapsed
            sec._ct.Visible = not collapsed
            chev.Text = collapsed and "▸" or "▾"
        end)
    end

    -- Content container
    local ct = frm({
        Name = "Ct",
        Size = UDim2.new(1, -24, 0, 0),
        Position = UDim2.new(0, 12, 0, yOffset),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 14,
        Parent = card,
    })
    list(ct, 4)
    pad(ct, 0, 0, 12, 0)
    sec._ct   = ct
    sec._card = card

    return sec
end

-- ── Element row helper ────────────────────────────────────────
local function mkRow(sec, h)
    return frm({
        Size = UDim2.new(1, 0, 0, h or 36),
        BackgroundTransparency = 1,
        ZIndex = 15,
        LayoutOrder = #sec._ct:GetChildren() + 1,
        Parent = sec._ct,
    })
end

local function mkRowLabel(row, text)
    return lbl({
        Size=UDim2.new(1,-70,1,0),Text=text,TextSize=12,
        Font=Enum.Font.GothamMedium,TextColor3=C.T0,ZIndex=16,Parent=row,
    })
end

-- ═══════════════════════════════════════════════════════════
--  BUTTON
-- ═══════════════════════════════════════════════════════════
function Library:CreateButton(sec, text, cb)
    local b = btn({
        Name = text,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = C.W4,
        ZIndex = 15,
        LayoutOrder = #sec._ct:GetChildren() + 1,
        Parent = sec._ct,
    })
    rnd(b, 5)
    bdr(b, C.White, 1, 0.90)

    lbl({
        Size=UDim2.new(1,-32,1,0),Position=UDim2.new(0,12,0,0),
        Text=text,TextSize=12,Font=Enum.Font.GothamSemibold,TextColor3=C.T0,ZIndex=16,Parent=b,
    })

    -- right arrow indicator
    lbl({
        Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-24,0,0),
        Text="›",TextSize=20,Font=Enum.Font.GothamBold,TextColor3=C.T3,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=16,Parent=b,
    })

    b.MouseEnter:Connect(function()  tw(b, EFast, {BackgroundColor3=C.W5}) end)
    b.MouseLeave:Connect(function()  tw(b, EFast, {BackgroundColor3=C.W4}) end)
    b.MouseButton1Down:Connect(function()
        tw(b, EFast, {BackgroundColor3=self.Accent})
    end)
    b.MouseButton1Up:Connect(function()
        tw(b, EFast, {BackgroundColor3=C.W5})
        task.spawn(cb)
    end)

    return { _btn = b }
end

-- ═══════════════════════════════════════════════════════════
--  TOGGLE
-- ═══════════════════════════════════════════════════════════
function Library:CreateToggle(sec, text, default, cb)
    local val = (default == true)
    local tog = { Value = val }

    local row = mkRow(sec, 36)
    mkRowLabel(row, text)

    -- Track
    local track = frm({
        Size=UDim2.new(0,42,0,22),Position=UDim2.new(1,-42,0.5,-11),
        BackgroundColor3 = val and self.Accent or C.W5,ZIndex=16,Parent=row,
    })
    rnd(track, 11)
    -- deliberately no UIStroke on toggle track (cleaner look)

    -- Thumb
    local thumb = frm({
        Size=UDim2.new(0,16,0,16),
        Position = val and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
        BackgroundColor3=C.White,ZIndex=17,Parent=track,
    })
    rnd(thumb, 8)

    local function set(v, fire)
        val = v; tog.Value = v
        tw(track, EMed, {BackgroundColor3 = v and self.Accent or C.W5})
        tw(thumb, EMed, {Position = v and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)})
        if fire and cb then task.spawn(cb, v) end
    end

    local hit = btn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=18,Parent=row})
    hit.MouseButton1Click:Connect(function() set(not val, true) end)
    tog.Set = function(v) set(v, true) end
    return tog
end

-- ═══════════════════════════════════════════════════════════
--  SLIDER  ─  uses RunService.Heartbeat for 60 fps smoothness
-- ═══════════════════════════════════════════════════════════
function Library:CreateSlider(sec, text, min, max, default, cb, dec)
    dec = dec or 0
    local sl = { Value = default or min }

    local wrap = frm({
        Name = text.."_Sl",
        Size = UDim2.new(1,0,0,52),
        BackgroundTransparency=1,ZIndex=15,
        LayoutOrder=#sec._ct:GetChildren()+1,Parent=sec._ct,
    })

    -- Label row
    local topRow = frm({Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,ZIndex=16,Parent=wrap})
    lbl({Size=UDim2.new(1,-70,1,0),Text=text,TextSize=12,Font=Enum.Font.GothamMedium,TextColor3=C.T0,ZIndex=17,Parent=topRow})

    local badge = frm({Size=UDim2.new(0,58,0,20),Position=UDim2.new(1,-58,0,0),BackgroundColor3=C.W4,ZIndex=17,Parent=topRow})
    rnd(badge, 4)
    local valLbl = lbl({
        Size=UDim2.new(1,0,1,0),Text=tostring(sl.Value),TextSize=11,
        Font=Enum.Font.GothamBold,TextColor3=self.Accent,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=18,Parent=badge,
    })

    -- Track background
    local trackBg = frm({
        Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0,32),
        BackgroundColor3=C.W5,ZIndex=16,Parent=wrap,
    })
    rnd(trackBg, 3)

    local initPct = math.clamp((sl.Value - min) / (max - min), 0, 1)

    -- Fill
    local fill = frm({
        Size=UDim2.new(initPct,0,1,0),
        BackgroundColor3=self.Accent,ZIndex=17,Parent=trackBg,
    })
    rnd(fill, 3)

    -- Thumb circle
    local thumb = frm({
        Size=UDim2.new(0,14,0,14),
        Position=UDim2.new(initPct,-7,0.5,-7),
        BackgroundColor3=C.White,ZIndex=18,Parent=trackBg,
    })
    rnd(thumb, 7)
    bdr(thumb, self.Accent, 2, 0.30)

    -- Value computation from raw mouse X
    local function calc(mx)
        local x0 = trackBg.AbsolutePosition.X
        local w  = trackBg.AbsoluteSize.X
        if w == 0 then return initPct, sl.Value end
        local pct = math.clamp((mx - x0) / w, 0, 1)
        local raw = min + (max - min) * pct
        local v   = dec == 0 and math.floor(raw + 0.5)
                    or tonumber(string.format("%."..dec.."f", raw))
        return pct, v
    end

    local function apply(pct, v)
        fill.Size      = UDim2.new(pct, 0, 1, 0)
        thumb.Position = UDim2.new(pct, -7, 0.5, -7)
        valLbl.Text    = tostring(v)
        sl.Value       = v
        if cb then task.spawn(cb, v) end
    end

    -- Full-wrap hitbox catches clicks anywhere on the slider row
    local hit = btn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=19,Parent=wrap})

    hit.MouseButton1Down:Connect(function()
        -- immediate response on click
        local pct, v = calc(UserInputService:GetMouseLocation().X)
        apply(pct, v)

        -- smooth drag via Heartbeat
        local hb, ue
        hb = RunService.Heartbeat:Connect(function()
            local p2, v2 = calc(UserInputService:GetMouseLocation().X)
            apply(p2, v2)
        end)
        ue = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                hb:Disconnect()
                ue:Disconnect()
            end
        end)
    end)

    sl.Set = function(v)
        local pct = math.clamp((v - min) / (max - min), 0, 1)
        apply(pct, v)
    end

    return sl
end

-- ═══════════════════════════════════════════════════════════
--  DROPDOWN PANEL BUILDER  (shared by single + multi)
-- ═══════════════════════════════════════════════════════════
local function buildPanel(win, itemCount, itemH)
    local h = itemCount * itemH + 8
    local panel = frm({
        Name = "DDPanel",
        Size = UDim2.new(0, 1, 0, h),
        BackgroundColor3 = C.W4,
        ClipsDescendants = true,
        ZIndex = 5010,
        Visible = false,
        Parent = win.Overlay,
    })
    rnd(panel, 6)
    bdr(panel, C.White, 1, 0.82)
    pad(panel, 4, 0, 4, 0)
    list(panel, 0)
    return panel, h
end

local function positionPanel(panel, bar, panelH, guiSize)
    local ap   = bar.AbsolutePosition
    local as   = bar.AbsoluteSize
    local panY = ap.Y + as.Y + 4
    local vpH  = guiSize.Y
    if panY + panelH > vpH - 8 then
        panY = ap.Y - panelH - 4
    end
    panel.Position = UDim2.new(0, ap.X, 0, panY)
    panel.Size     = UDim2.new(0, as.X, 0, 0)   -- starts at 0 height, tweens open
end

-- ═══════════════════════════════════════════════════════════
--  DROPDOWN  (single select)
-- ═══════════════════════════════════════════════════════════
function Library:CreateDropdown(sec, text, opts, default, cb)
    local dd = { Value = default or opts[1], IsOpen = false }

    local wrap = frm({
        Name=text.."_DD",Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,
        ZIndex=15,LayoutOrder=#sec._ct:GetChildren()+1,Parent=sec._ct,
    })

    local bar = btn({
        Size=UDim2.new(1,0,0,36),BackgroundColor3=C.W4,ZIndex=16,Parent=wrap,
    })
    rnd(bar, 5)
    bdr(bar, C.White, 1, 0.88)

    lbl({Size=UDim2.new(0.45,0,1,0),Position=UDim2.new(0,10,0,0),Text=text,TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.T1,ZIndex=17,Parent=bar})
    local valLbl = lbl({Size=UDim2.new(0.42,0,1,0),Position=UDim2.new(0.5,0,0,0),Text=dd.Value,TextSize=12,Font=Enum.Font.GothamSemibold,TextColor3=C.T0,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=17,Parent=bar})
    local chev  = lbl({Size=UDim2.new(0,22,1,0),Position=UDim2.new(1,-24,0,0),Text="⌄",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.T2,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=17,Parent=bar})

    local ITEM_H = 34
    local panel, panelH = buildPanel(self, #opts, ITEM_H)

    -- Build option rows
    local rows = {}
    for i, opt in ipairs(opts) do
        local row = btn({
            Name=opt,Size=UDim2.new(1,0,0,ITEM_H),BackgroundColor3=C.W4,
            BackgroundTransparency=1,ZIndex=5011,LayoutOrder=i,Parent=panel,
        })
        local tick = lbl({Size=UDim2.new(0,20,1,0),Position=UDim2.new(0,6,0,0),Text="✓",TextSize=11,Font=Enum.Font.GothamBold,TextColor3=self.Accent,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=5012,Visible=(opt==dd.Value),Parent=row})
        lbl({Size=UDim2.new(1,-28,1,0),Position=UDim2.new(0,26,0,0),Text=opt,TextSize=12,Font=Enum.Font.GothamMedium,TextColor3=(opt==dd.Value and C.T0 or C.T1),ZIndex=5012,Parent=row})

        row.MouseEnter:Connect(function() tw(row, EFast, {BackgroundTransparency=0.80,BackgroundColor3=C.W5}) end)
        row.MouseLeave:Connect(function() tw(row, EFast, {BackgroundTransparency=1}) end)

        row.MouseButton1Click:Connect(function()
            dd.Value = opt
            valLbl.Text = opt
            -- refresh all row indicators
            for _, r in ipairs(rows) do
                for _, ch in ipairs(r:GetChildren()) do
                    if ch:IsA("TextLabel") then
                        if ch.Text == "✓" then
                            ch.Visible = (r.Name == opt)
                        else
                            ch.TextColor3 = (r.Name == opt and C.T0 or C.T1)
                        end
                    end
                end
            end
            -- close
            dd.IsOpen = false
            panel.Visible = false
            self._dismiss.Visible = false
            self._closeDD = nil
            tw(chev, EFast, {Rotation = 0})
            if cb then task.spawn(cb, opt) end
        end)

        rows[i] = row
    end

    local function closeFn()
        dd.IsOpen = false
        tw(panel, EFast, {Size = UDim2.new(0, panel.AbsoluteSize.X, 0, 0)})
        tw(chev,  EFast, {Rotation = 0})
        task.delay(0.20, function() panel.Visible = false end)
    end

    bar.MouseEnter:Connect(function() tw(bar, EFast, {BackgroundColor3=C.W5}) end)
    bar.MouseLeave:Connect(function() tw(bar, EFast, {BackgroundColor3=C.W4}) end)

    bar.MouseButton1Click:Connect(function()
        -- close whatever is currently open
        if self._closeDD and self._closeDD ~= closeFn then
            self._closeDD()
        end

        dd.IsOpen = not dd.IsOpen
        if dd.IsOpen then
            self._closeDD = closeFn
            self._dismiss.Visible = true
            positionPanel(panel, bar, panelH, self.Gui.AbsoluteSize)
            panel.Visible = true
            tw(panel, EMed, {Size = UDim2.new(0, bar.AbsoluteSize.X, 0, panelH)})
            tw(chev, EFast, {Rotation = 180})
        else
            self._closeDD = nil
            self._dismiss.Visible = false
            closeFn()
        end
    end)

    dd.Set = function(v) dd.Value = v; valLbl.Text = v end
    return dd
end

-- ═══════════════════════════════════════════════════════════
--  MULTI DROPDOWN
-- ═══════════════════════════════════════════════════════════
function Library:CreateMultiDropdown(sec, text, opts, defaults, cb)
    local sel = {}
    if defaults then for _, v in ipairs(defaults) do sel[v] = true end end
    local mdd = { Selected = sel, IsOpen = false }

    local function displayText()
        local parts = {}
        for _, o in ipairs(opts) do if sel[o] then parts[#parts+1] = o end end
        if #parts == 0 then return "None"
        elseif #parts <= 2 then return table.concat(parts, ", ")
        else return parts[1]..", +"..tostring(#parts-1) end
    end

    local wrap = frm({
        Name=text.."_MDD",Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,
        ZIndex=15,LayoutOrder=#sec._ct:GetChildren()+1,Parent=sec._ct,
    })

    local bar = btn({
        Size=UDim2.new(1,0,0,36),BackgroundColor3=C.W4,ZIndex=16,Parent=wrap,
    })
    rnd(bar, 5)
    bdr(bar, C.White, 1, 0.88)

    lbl({Size=UDim2.new(0.43,0,1,0),Position=UDim2.new(0,10,0,0),Text=text,TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.T1,ZIndex=17,Parent=bar})
    local valLbl = lbl({Size=UDim2.new(0.42,0,1,0),Position=UDim2.new(0.5,0,0,0),Text=displayText(),TextSize=12,Font=Enum.Font.GothamSemibold,TextColor3=C.T0,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=17,Parent=bar})
    local chev  = lbl({Size=UDim2.new(0,22,1,0),Position=UDim2.new(1,-24,0,0),Text="⌄",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.T2,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=17,Parent=bar})

    local ITEM_H = 34
    local panel, panelH = buildPanel(self, #opts, ITEM_H)

    for i, opt in ipairs(opts) do
        local isOn = sel[opt] or false
        local row = btn({
            Name=opt,Size=UDim2.new(1,0,0,ITEM_H),BackgroundColor3=C.W4,
            BackgroundTransparency=1,ZIndex=5011,LayoutOrder=i,Parent=panel,
        })

        -- Checkbox
        local cbBg = frm({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,8,0.5,-7),BackgroundColor3=(isOn and self.Accent or C.W6),ZIndex=5012,Parent=row})
        rnd(cbBg, 3)
        local cbMk = lbl({Size=UDim2.new(1,0,1,0),Text="✓",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.W1,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=5013,Visible=isOn,Parent=cbBg})
        local optLbl = lbl({Size=UDim2.new(1,-30,1,0),Position=UDim2.new(0,28,0,0),Text=opt,TextSize=12,Font=Enum.Font.GothamMedium,TextColor3=(isOn and C.T0 or C.T1),ZIndex=5012,Parent=row})

        row.MouseEnter:Connect(function() tw(row, EFast, {BackgroundTransparency=0.80,BackgroundColor3=C.W5}) end)
        row.MouseLeave:Connect(function() tw(row, EFast, {BackgroundTransparency=1}) end)

        row.MouseButton1Click:Connect(function()
            sel[opt] = not sel[opt]
            local on = sel[opt]
            tw(cbBg, EFast, {BackgroundColor3 = on and self.Accent or C.W6})
            cbMk.Visible = on
            tw(optLbl, EFast, {TextColor3 = on and C.T0 or C.T1})
            valLbl.Text = displayText()
            mdd.Selected = sel
            local out = {}
            for _, o in ipairs(opts) do if sel[o] then out[#out+1] = o end end
            if cb then task.spawn(cb, out) end
        end)
    end

    local function closeFn()
        mdd.IsOpen = false
        tw(panel, EFast, {Size = UDim2.new(0, panel.AbsoluteSize.X, 0, 0)})
        tw(chev,  EFast, {Rotation = 0})
        task.delay(0.20, function() panel.Visible = false end)
    end

    bar.MouseEnter:Connect(function() tw(bar, EFast, {BackgroundColor3=C.W5}) end)
    bar.MouseLeave:Connect(function() tw(bar, EFast, {BackgroundColor3=C.W4}) end)

    bar.MouseButton1Click:Connect(function()
        if self._closeDD and self._closeDD ~= closeFn then self._closeDD() end

        mdd.IsOpen = not mdd.IsOpen
        if mdd.IsOpen then
            self._closeDD = closeFn
            self._dismiss.Visible = true
            positionPanel(panel, bar, panelH, self.Gui.AbsoluteSize)
            panel.Visible = true
            tw(panel, EMed, {Size = UDim2.new(0, bar.AbsoluteSize.X, 0, panelH)})
            tw(chev, EFast, {Rotation = 180})
        else
            self._closeDD = nil
            self._dismiss.Visible = false
            closeFn()
        end
    end)

    mdd.Set = function(newSel)
        sel = {}
        for _, v in ipairs(newSel) do sel[v] = true end
        mdd.Selected = sel
        valLbl.Text = displayText()
    end

    return mdd
end

-- ═══════════════════════════════════════════════════════════
--  COLOR PICKER  (HSV square + hue bar)
-- ═══════════════════════════════════════════════════════════
function Library:CreateColorPicker(sec, text, default, cb)
    local cp = { Value = default or C.White }
    local H, S, V = toHSV(cp.Value)

    local container = frm({
        Name=text.."_CP",Size=UDim2.new(1,0,0,36),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,ZIndex=15,
        LayoutOrder=#sec._ct:GetChildren()+1,Parent=sec._ct,
    })
    list(container, 6)

    -- Header row
    local hrow = frm({Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,ZIndex=16,LayoutOrder=1,Parent=container})
    lbl({Size=UDim2.new(1,-72,1,0),Text=text,TextSize=12,Font=Enum.Font.GothamMedium,TextColor3=C.T0,ZIndex=17,Parent=hrow})

    local swatch = btn({
        Size=UDim2.new(0,60,0,26),Position=UDim2.new(1,-60,0.5,-13),
        BackgroundColor3=cp.Value,ZIndex=17,Parent=hrow,
    })
    rnd(swatch, 5)
    bdr(swatch, C.White, 1.5, 0.72)

    local swHexLbl = lbl({
        Size=UDim2.new(1,0,1,0),Text=toHex(cp.Value),TextSize=9,
        Font=Enum.Font.GothamBold,TextColor3=C.White,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=18,Parent=swatch,
    })

    -- Picker panel
    local PICKER_H = 178
    local picker = frm({
        Size=UDim2.new(1,0,0,0),BackgroundColor3=C.W4,ClipsDescendants=true,
        ZIndex=16,Visible=false,LayoutOrder=2,Parent=container,
    })
    rnd(picker, 6)
    bdr(picker, C.White, 1, 0.85)

    -- SV square
    local SQ_H = 100
    local sq = frm({
        Size=UDim2.new(1,-16,0,SQ_H),Position=UDim2.new(0,8,0,8),
        BackgroundColor3=hsv(H,1,1),ZIndex=17,Parent=picker,
    })
    rnd(sq, 5)

    -- Saturation gradient (left=white, right=transparent → shows hue)
    local satL = frm({Size=UDim2.new(1,0,1,0),BackgroundColor3=C.White,ZIndex=18,Parent=sq})
    rnd(satL, 5)
    local satG = Instance.new("UIGradient")
    satG.Rotation = 0
    satG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
    satG.Parent = satL

    -- Value gradient (top=transparent, bottom=black)
    local valL = frm({Size=UDim2.new(1,0,1,0),BackgroundColor3=C.Black,ZIndex=19,Parent=sq})
    rnd(valL, 5)
    local valG = Instance.new("UIGradient")
    valG.Rotation = 90
    valG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)})
    valG.Parent = valL

    -- SV cursor
    local svCur = frm({
        Size=UDim2.new(0,12,0,12),AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(S,0,1-V,0),BackgroundColor3=C.White,ZIndex=21,Parent=sq,
    })
    rnd(svCur, 6)
    bdr(svCur, C.Black, 1.5, 0.25)

    -- Hue bar
    local HUE_Y = SQ_H + 16
    local hueBar = frm({
        Size=UDim2.new(1,-16,0,10),Position=UDim2.new(0,8,0,HUE_Y),
        BackgroundColor3=C.White,ZIndex=17,Parent=picker,
    })
    rnd(hueBar, 5)
    local hueG = Instance.new("UIGradient")
    hueG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,     hsv(0,    1,1)),
        ColorSequenceKeypoint.new(0.167, hsv(0.167,1,1)),
        ColorSequenceKeypoint.new(0.333, hsv(0.333,1,1)),
        ColorSequenceKeypoint.new(0.5,   hsv(0.5,  1,1)),
        ColorSequenceKeypoint.new(0.667, hsv(0.667,1,1)),
        ColorSequenceKeypoint.new(0.833, hsv(0.833,1,1)),
        ColorSequenceKeypoint.new(1,     hsv(1,    1,1)),
    })
    hueG.Parent = hueBar

    local hueCur = frm({
        Size=UDim2.new(0,4,1,6),AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(H,0,0.5,0),BackgroundColor3=C.White,ZIndex=18,Parent=hueBar,
    })
    rnd(hueCur, 2)
    bdr(hueCur, C.Black, 1, 0.35)

    -- Bottom row: preview + hex input
    local BOT_Y = HUE_Y + 18
    local botRow = frm({Size=UDim2.new(1,-16,0,28),Position=UDim2.new(0,8,0,BOT_Y),BackgroundTransparency=1,ZIndex=17,Parent=picker})

    local prevSwatch = frm({Size=UDim2.new(0,28,1,0),BackgroundColor3=cp.Value,ZIndex=18,Parent=botRow})
    rnd(prevSwatch, 4)
    bdr(prevSwatch, C.White, 1, 0.80)

    lbl({Size=UDim2.new(0,12,1,0),Position=UDim2.new(0,34,0,0),Text="#",TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.T2,ZIndex=18,Parent=botRow})

    local hexBg = frm({Size=UDim2.new(0,82,1,-4),Position=UDim2.new(0,46,0,2),BackgroundColor3=C.W5,ZIndex=17,Parent=botRow})
    rnd(hexBg, 4)

    local hexBox = Instance.new("TextBox")
    hexBox.Size               = UDim2.new(1,-10,1,0)
    hexBox.Position           = UDim2.new(0,5,0,0)
    hexBox.BackgroundTransparency = 1
    hexBox.Text               = toHex(cp.Value)
    hexBox.PlaceholderText    = "FFFFFF"
    hexBox.PlaceholderColor3  = C.T2
    hexBox.TextColor3         = C.T0
    hexBox.TextSize           = 11
    hexBox.Font               = Enum.Font.GothamMedium
    hexBox.ZIndex             = 19
    hexBox.ClearTextOnFocus   = false
    hexBox.Parent             = hexBg

    -- Refresh all picker visuals from H, S, V state
    local function refresh()
        local col = hsv(H, S, V)
        cp.Value                  = col
        swatch.BackgroundColor3   = col
        prevSwatch.BackgroundColor3 = col
        sq.BackgroundColor3       = hsv(H, 1, 1)
        svCur.Position            = UDim2.new(S, 0, 1-V, 0)
        hueCur.Position           = UDim2.new(H, 0, 0.5, 0)
        swHexLbl.Text             = toHex(col)
        hexBox.Text               = toHex(col)
        if cb then task.spawn(cb, col) end
    end

    -- SV square drag (Heartbeat)
    local sqHit = btn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=22,Parent=sq})
    sqHit.MouseButton1Down:Connect(function()
        local hb, ue
        hb = RunService.Heartbeat:Connect(function()
            local mx, my = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y
            S = math.clamp((mx - sq.AbsolutePosition.X) / math.max(sq.AbsoluteSize.X, 1), 0, 1)
            V = 1 - math.clamp((my - sq.AbsolutePosition.Y) / math.max(sq.AbsoluteSize.Y, 1), 0, 1)
            refresh()
        end)
        ue = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then hb:Disconnect(); ue:Disconnect() end
        end)
    end)

    -- Hue bar drag (Heartbeat)
    local hueHit = btn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=19,Parent=hueBar})
    hueHit.MouseButton1Down:Connect(function()
        local hb, ue
        hb = RunService.Heartbeat:Connect(function()
            H = math.clamp((UserInputService:GetMouseLocation().X - hueBar.AbsolutePosition.X) / math.max(hueBar.AbsoluteSize.X, 1), 0, 1)
            refresh()
        end)
        ue = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then hb:Disconnect(); ue:Disconnect() end
        end)
    end)

    -- Hex input
    hexBox.Focused:Connect(function()    tw(hexBg, EFast, {BackgroundColor3=C.W6}) end)
    hexBox.FocusLost:Connect(function()
        tw(hexBg, EFast, {BackgroundColor3=C.W5})
        local col = fromHex(hexBox.Text)
        H, S, V = toHSV(col)
        refresh()
    end)

    -- Toggle open/close
    local isOpen = false
    swatch.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            picker.Visible = true
            tw(picker, EMed, {Size = UDim2.new(1, 0, 0, PICKER_H)})
        else
            tw(picker, EFast, {Size = UDim2.new(1, 0, 0, 0)})
            task.delay(0.20, function() picker.Visible = false end)
        end
    end)

    cp.Set = function(col)
        cp.Value = col; H, S, V = toHSV(col); refresh()
    end
    return cp
end

-- ═══════════════════════════════════════════════════════════
--  TEXTBOX
-- ═══════════════════════════════════════════════════════════
function Library:CreateTextbox(sec, text, placeholder, cb)
    local tb = { Value = "" }

    local wrap = frm({
        Name=text.."_TB",Size=UDim2.new(1,0,0,58),BackgroundTransparency=1,
        ZIndex=15,LayoutOrder=#sec._ct:GetChildren()+1,Parent=sec._ct,
    })

    lbl({Size=UDim2.new(1,0,0,17),Text=text,TextSize=11,Font=Enum.Font.GothamMedium,TextColor3=C.T1,ZIndex=16,Parent=wrap})

    local ibg = frm({Size=UDim2.new(1,0,0,34),Position=UDim2.new(0,0,0,20),BackgroundColor3=C.W4,ZIndex=16,Parent=wrap})
    rnd(ibg, 5)
    local ibStroke = bdr(ibg, C.White, 1, 0.88)

    local box = Instance.new("TextBox")
    box.Size               = UDim2.new(1,-20,1,0)
    box.Position           = UDim2.new(0,10,0,0)
    box.BackgroundTransparency = 1
    box.PlaceholderText    = placeholder or ""
    box.PlaceholderColor3  = C.T2
    box.Text               = ""
    box.TextColor3         = C.T0
    box.TextSize           = 12
    box.Font               = Enum.Font.GothamMedium
    box.ZIndex             = 17
    box.ClearTextOnFocus   = false
    box.Parent             = ibg

    box.Focused:Connect(function()
        tw(ibg, EFast, {BackgroundColor3=C.W5})
        ibStroke.Color        = self.Accent
        ibStroke.Transparency = 0.50
    end)
    box.FocusLost:Connect(function(enter)
        tw(ibg, EFast, {BackgroundColor3=C.W4})
        ibStroke.Color        = C.White
        ibStroke.Transparency = 0.88
        tb.Value = box.Text
        if cb then task.spawn(cb, box.Text, enter) end
    end)

    tb.Set = function(v) tb.Value = v; box.Text = v end
    return tb
end

-- ═══════════════════════════════════════════════════════════
--  KEYBIND
-- ═══════════════════════════════════════════════════════════
function Library:CreateKeybind(sec, text, default, cb)
    local kb = { Key = default, _busy = false, _fn = cb or function() end }

    local row = mkRow(sec, 36)
    mkRowLabel(row, text)

    local kbBtn = btn({
        Size=UDim2.new(0,84,0,26),Position=UDim2.new(1,-84,0.5,-13),
        BackgroundColor3=C.W4,Text=(default and default.Name or "NONE"),
        TextSize=11,Font=Enum.Font.GothamBold,TextColor3=C.T0,
        TextXAlignment=Enum.TextXAlignment.Center,ZIndex=16,Parent=row,
    })
    rnd(kbBtn, 4)
    bdr(kbBtn, C.White, 1, 0.88)

    kbBtn.MouseButton1Click:Connect(function()
        if kb._busy then return end
        kb._busy = true
        kbBtn.Text       = "..."
        kbBtn.TextColor3 = self.Accent
        tw(kbBtn, EFast, {BackgroundColor3=C.W5})
    end)

    table.insert(self.Conns, UserInputService.InputBegan:Connect(function(inp)
        if kb._busy and inp.UserInputType == Enum.UserInputType.Keyboard then
            kb._busy       = false
            kb.Key         = inp.KeyCode
            kbBtn.Text     = inp.KeyCode.Name
            kbBtn.TextColor3 = C.T0
            tw(kbBtn, EFast, {BackgroundColor3=C.W4})
        end
    end))

    table.insert(self.Keybinds, kb)
    return kb
end

-- ═══════════════════════════════════════════════════════════
--  LABEL  &  SEPARATOR
-- ═══════════════════════════════════════════════════════════
function Library:CreateLabel(sec, text, color, size)
    return lbl({
        Size=UDim2.new(1,0,0,18),Text=text,TextSize=size or 11,
        Font=Enum.Font.Gotham,TextColor3=color or C.T2,ZIndex=15,
        LayoutOrder=#sec._ct:GetChildren()+1,Parent=sec._ct,
    })
end

function Library:CreateSeparator(sec)
    return frm({
        Size=UDim2.new(1,0,0,1),BackgroundColor3=C.White,BackgroundTransparency=0.91,
        ZIndex=15,LayoutOrder=#sec._ct:GetChildren()+1,Parent=sec._ct,
    })
end

-- ═══════════════════════════════════════════════════════════
--  PROGRESS BAR  (bonus element)
-- ═══════════════════════════════════════════════════════════
function Library:CreateProgressBar(sec, text, value)
    value = math.clamp(value or 0, 0, 100)
    local pb = { Value = value }

    local wrap = frm({
        Name=text.."_PB",Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,
        ZIndex=15,LayoutOrder=#sec._ct:GetChildren()+1,Parent=sec._ct,
    })

    local topRow = frm({Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,ZIndex=16,Parent=wrap})
    lbl({Size=UDim2.new(1,-44,1,0),Text=text,TextSize=12,Font=Enum.Font.GothamMedium,TextColor3=C.T0,ZIndex=17,Parent=topRow})
    local pctLbl = lbl({Size=UDim2.new(0,40,1,0),Position=UDim2.new(1,-40,0,0),Text=tostring(value).."%",TextSize=11,Font=Enum.Font.GothamBold,TextColor3=self.Accent,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=17,Parent=topRow})

    local trackBg = frm({Size=UDim2.new(1,0,0,7),Position=UDim2.new(0,0,0,26),BackgroundColor3=C.W5,ZIndex=16,Parent=wrap})
    rnd(trackBg, 4)

    local fill = frm({Size=UDim2.new(value/100,0,1,0),BackgroundColor3=self.Accent,ZIndex=17,Parent=trackBg})
    rnd(fill, 4)

    -- Shine effect on fill
    local shine = frm({Size=UDim2.new(1,0,0.5,0),BackgroundColor3=C.White,BackgroundTransparency=0.80,ZIndex=18,Parent=fill})
    rnd(shine, 4)

    pb.Set = function(v)
        v = math.clamp(v, 0, 100)
        pb.Value = v
        tw(fill, EMed, {Size = UDim2.new(v/100, 0, 1, 0)})
        pctLbl.Text = tostring(v).."%"
    end
    return pb
end

-- ─────────────────────────────────────────────────────────────
--  EXAMPLE USAGE
-- ─────────────────────────────────────────────────────────────

local W = Library.CreateWindow({
    Title    = "Obsidian",
    Subtitle = "Hub  ·  v4.0",
    Name     = "ObsidianHub",
    Accent   = Color3.fromRGB(110, 168, 255),
})

-- Tabs
local MainTab     = W:CreateTab("🏠", "Main")
local CombatTab   = W:CreateTab("⚔️", "Combat")
local VisualsTab  = W:CreateTab("👁", "Visuals")
local MiscTab     = W:CreateTab("🔧", "Misc")
local SettingsTab = W:CreateTab("⚙️", "Settings")

-- ── Main ───────────────────────────────────────────────────
local S1 = W:CreateSection(MainTab, "Core")
W:CreateButton(S1, "Start Farm", function()
    W:Notify({Title="Farm", Text="Auto farm started successfully.", Icon="🌾", Type="success"})
end)
W:CreateToggle(S1, "Auto Farm",    false, function(v) warn("AutoFarm:", v)   end)
W:CreateToggle(S1, "Auto Rebirth", true,  function(v) warn("AutoRebirth:", v) end)
W:CreateToggle(S1, "Auto Quest",   false, function(v) warn("AutoQuest:", v)  end)
W:CreateSeparator(S1)
W:CreateProgressBar(S1, "Farm Progress", 68)
W:CreateSlider(S1, "Farm Delay (ms)", 0, 2000, 200, function(v) warn("Delay:", v) end)

local S2 = W:CreateSection(MainTab, "Character")
W:CreateSlider(S2, "Walk Speed",  16, 500, 50,  function(v) warn("Speed:", v) end)
W:CreateSlider(S2, "Jump Power",  50, 500, 100, function(v) warn("Jump:", v)  end)
W:CreateSlider(S2, "Gravity",      0, 200, 196, function(v) warn("Grav:", v)  end)

local S3 = W:CreateSection(MainTab, "Teleports")
W:CreateButton(S3, "Teleport to Spawn", function() warn("TP Spawn") end)
W:CreateButton(S3, "Teleport to Shop",  function() warn("TP Shop")  end)
W:CreateDropdown(S3, "Target Area", {"Lobby","Boss Room","Safe Zone","Shop","Dungeon","Arena"}, "Lobby", function(v) warn("Area:", v) end)

-- ── Combat ──────────────────────────────────────────────────
local C1 = W:CreateSection(CombatTab, "Aimbot")
W:CreateToggle(C1, "Aimbot Enabled", true,  function(v) warn("Aim:", v)    end)
W:CreateToggle(C1, "Silent Aim",     false, function(v) warn("Silent:", v) end)
W:CreateToggle(C1, "Prediction",     true,  function(v) warn("Pred:", v)   end)
W:CreateSlider(C1, "FOV Radius",  50, 600, 180, function(v) warn("FOV:", v)    end)
W:CreateSlider(C1, "Smoothness",   1, 100,  25, function(v) warn("Smooth:", v) end, 1)
W:CreateDropdown(C1, "Aim Part", {"Head","HumanoidRootPart","Torso","UpperTorso"}, "Head", function(v) warn("Part:", v) end)

local C2 = W:CreateSection(CombatTab, "Weapons")
W:CreateDropdown(C2, "Weapon Mode", {"Normal","Rage","Legit","Custom"}, "Legit", function(v) warn("Mode:", v) end)
W:CreateMultiDropdown(C2, "Modifiers", {"Crit Boost","Speed Up","Lifesteal","Shield","Burst"}, {"Crit Boost"}, function(v)
    warn("Mods:", table.concat(v, ", "))
end)
W:CreateSlider(C2, "Damage Mult", 1, 10, 1, function(v) warn("DMG:", v) end, 1)

-- ── Visuals ──────────────────────────────────────────────────
local V1 = W:CreateSection(VisualsTab, "ESP")
W:CreateToggle(V1, "Player ESP", false, function(v) warn("PESP:", v) end)
W:CreateToggle(V1, "NPC ESP",    false, function(v) warn("NESP:", v) end)
W:CreateToggle(V1, "Item ESP",   true,  function(v) warn("IESP:", v) end)
W:CreateToggle(V1, "Chams",      false, function(v) warn("Chams:", v) end)
W:CreateDropdown(V1, "Box Style", {"2D Box","3D Box","Corner Box","Wireframe"}, "2D Box", function(v) warn("Box:", v) end)
W:CreateSlider(V1, "ESP Range", 100, 3000, 1000, function(v) warn("Range:", v) end)
W:CreateColorPicker(V1, "ESP Color",     Color3.fromRGB(255, 80, 80),  function(c) warn("ESPCol:", c) end)
W:CreateColorPicker(V1, "Friendly Color", Color3.fromRGB(80, 210, 100), function(c) warn("FCol:", c)   end)

local V2 = W:CreateSection(VisualsTab, "World")
W:CreateToggle(V2, "Full Bright", false, function(v) warn("FB:", v)  end)
W:CreateToggle(V2, "No Fog",      true,  function(v) warn("Fog:", v) end)
W:CreateSlider(V2, "Brightness",   0, 100, 50, function(v) warn("Bright:", v) end)
W:CreateColorPicker(V2, "Sky Tint", Color3.fromRGB(100, 160, 255), function(c) warn("Sky:", c) end)

-- ── Misc ─────────────────────────────────────────────────────
local M1 = W:CreateSection(MiscTab, "Player")
W:CreateToggle(M1, "Anti AFK",      true,  function(v) warn("AFK:", v) end)
W:CreateToggle(M1, "Infinite Jump",  false, function(v) warn("IJ:", v) end)
W:CreateToggle(M1, "No Clip",        false, function(v) warn("NC:", v) end)
W:CreateToggle(M1, "God Mode",       false, function(v) warn("God:", v) end)
W:CreateMultiDropdown(M1, "Active Cheats", {"Fly","Ghost","Speed","God Mode","Invisible"}, {}, function(v)
    warn("Cheats:", table.concat(v, ", "))
end)

local M2 = W:CreateSection(MiscTab, "World")
W:CreateButton(M2, "Rejoin Server",  function() warn("Rejoin") end)
W:CreateButton(M2, "Copy Server ID", function()
    W:Notify({Title="Copied", Text="Server ID copied to clipboard.", Icon="📋", Type="info"})
end)

-- ── Settings ─────────────────────────────────────────────────
local ST1 = W:CreateSection(SettingsTab, "Config")
W:CreateTextbox(ST1, "Config Name", "Enter name...", function(t) warn("ConfigName:", t) end)
W:CreateButton(ST1, "Save Config",  function() W:Notify({Title="Config", Text="Saved successfully.",  Icon="💾", Type="success"}) end)
W:CreateButton(ST1, "Load Config",  function() W:Notify({Title="Config", Text="Loaded successfully.", Icon="📂", Type="info"})    end)
W:CreateButton(ST1, "Reset Config", function() W:Notify({Title="Config", Text="Reset to defaults.",   Icon="🔄", Type="warn"})    end)
W:CreateSeparator(ST1)
W:CreateLabel(ST1, "Obsidian UI  v4.0  ·  github.com/obsidian-ui", C.T3)

local ST2 = W:CreateSection(SettingsTab, "Keybinds")
W:CreateKeybind(ST2, "Toggle Menu",  Enum.KeyCode.RightShift, function() W:Toggle() end)
W:CreateKeybind(ST2, "Panic / Close", Enum.KeyCode.Delete,    function() W:Destroy() end)

print("✅ Obsidian UI v4.0 loaded")
return Library
