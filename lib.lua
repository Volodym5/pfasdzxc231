--[[
    UILib
    A clean, reusable Roblox UI library.

    USAGE EXAMPLE:
    ──────────────
        local UILib = require(path.to.UILib)

        local win = UILib.new({
            title  = "My Tool",
            logo   = "rbxassetid://126303338963508", -- optional
            width  = 720,
            height = 440,
        })

        local col1, col2 = win:addTab("Settings")

        win:addSection(col1, "General")
        win:addToggle(col1, "Enable", function(on) print(on) end)
        win:addButton(col1, "Run", function(btn) print("clicked") end)
        win:addSlider(col1, "Speed", 0, 100, 50, function(val) print(val) end)
        win:addDropdown(col2, "Mode", {"Auto","Manual","Off"}, "Auto", function(v) print(v) end)
        win:addKeybind(col2, "Hotkey", Enum.KeyCode.F, function(key) print(key) end)
        win:addColorSlider(col2, "Accent Color", Color3.fromRGB(114,137,218), function(c) print(c) end)

        win:selectTab("Settings")
        win:show()
]]

local UILib = {}
UILib.__index = UILib

-- ════════════════════════════════════════
-- Services
-- ════════════════════════════════════════
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local UIS           = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ════════════════════════════════════════
-- Theme
-- ════════════════════════════════════════
local DEFAULT_THEME = {
    BG_DEEP       = Color3.fromRGB(10,  10,  13),
    BG_MID        = Color3.fromRGB(14,  14,  18),
    BG_RAISED     = Color3.fromRGB(19,  19,  25),
    BG_HOVER      = Color3.fromRGB(25,  25,  33),
    BG_SIDEBAR    = Color3.fromRGB(11,  11,  15),
    BORDER        = Color3.fromRGB(33,  33,  43),
    BORDER_LIGHT  = Color3.fromRGB(48,  48,  62),
    TEXT_PRIMARY  = Color3.fromRGB(210, 210, 225),
    TEXT_LABEL    = Color3.fromRGB(185, 185, 200),
    TEXT_DIM      = Color3.fromRGB(80,  80,  100),
    TEXT_SECTION  = Color3.fromRGB(52,  52,  68),
    ACCENT        = Color3.fromRGB(255, 255, 255),
}

-- ════════════════════════════════════════
-- Internal helpers
-- ════════════════════════════════════════
local function tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t), props):Play()
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 4)
    return c
end

local function makeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color = color
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function makePadding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    return p
end

-- ════════════════════════════════════════
-- Constructor
-- ════════════════════════════════════════
--[[
    UILib.new(options)
    options:
        title   string           Window title text          (default "UILib")
        logo    string           Asset ID for the logo icon (optional)
        width   number           Window width in pixels      (default 720)
        height  number           Window height in pixels     (default 440)
        theme   table            Partial or full theme table (optional)
        guiName string           ScreenGui instance name    (default "UILib")
]]
function UILib.new(options)
    options = options or {}
    local self = setmetatable({}, UILib)

    -- Merge theme
    self.theme = setmetatable(options.theme or {}, { __index = DEFAULT_THEME })
    local T = self.theme

    local W = options.width  or 720
    local H = options.height or 440

    self._tabs      = {}   -- [name] = { btn, accent }
    self._pages     = {}   -- [name] = { page, col1, col2 }
    self._activeTab = nil

    -- ── ScreenGui ──────────────────────────────────────────
    local sg = Instance.new("ScreenGui")
    sg.Name            = options.guiName or "UILib"
    sg.ResetOnSpawn    = false
    sg.IgnoreGuiInset  = true
    sg.DisplayOrder    = 9999
    sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    sg.Parent          = player.PlayerGui
    self._sg = sg

    -- ── Window ─────────────────────────────────────────────
    local win = Instance.new("Frame", sg)
    win.Size              = UDim2.new(0, W, 0, H)
    win.Position          = UDim2.new(0.5, -W/2, 0.5, -H/2)
    win.BackgroundColor3  = T.BG_MID
    win.BorderSizePixel   = 0
    win.Active            = true
    win.Draggable         = false
    makeCorner(win, 5)
    makeStroke(win, T.BORDER, 1)
    self._win = win

    -- Drop shadow
    local shadow = Instance.new("ImageLabel", win)
    shadow.Size               = UDim2.new(1, 40, 1, 40)
    shadow.Position           = UDim2.new(0, -20, 0, -20)
    shadow.BackgroundTransparency = 1
    shadow.Image              = "rbxassetid://5028857084"
    shadow.ImageColor3        = Color3.new(0, 0, 0)
    shadow.ImageTransparency  = 0.75
    shadow.ScaleType          = Enum.ScaleType.Slice
    shadow.SliceCenter        = Rect.new(24, 24, 276, 276)
    shadow.ZIndex             = 0

    -- ── Titlebar ───────────────────────────────────────────
    local titlebar = Instance.new("Frame", win)
    titlebar.Size            = UDim2.new(1, 0, 0, 48)
    titlebar.BackgroundColor3 = T.BG_DEEP
    titlebar.BorderSizePixel = 0
    titlebar.ZIndex          = 2
    titlebar.Active          = true
    makeCorner(titlebar, 5)

    -- Fill the rounded bottom corners of the titlebar
    local titleFill = Instance.new("Frame", titlebar)
    titleFill.Size            = UDim2.new(1, 0, 0, 8)
    titleFill.Position        = UDim2.new(0, 0, 1, -8)
    titleFill.BackgroundColor3 = T.BG_DEEP
    titleFill.BorderSizePixel = 0
    titleFill.ZIndex          = 2

    -- Logo (optional)
    if options.logo then
        local logo = Instance.new("ImageLabel", titlebar)
        logo.Size                  = UDim2.new(0, 32, 0, 32)
        logo.Position              = UDim2.new(0, 10, 0.5, -16)
        logo.BackgroundTransparency = 1
        logo.Image                 = options.logo
        logo.ZIndex                = 3
    end

    local titleOffset = options.logo and 50 or 12
    local titleText = Instance.new("TextLabel", titlebar)
    titleText.Size               = UDim2.new(1, -(titleOffset + 6), 1, 0)
    titleText.Position           = UDim2.new(0, titleOffset, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text               = options.title or "UILib"
    titleText.TextColor3         = T.TEXT_PRIMARY
    titleText.TextSize           = 15
    titleText.Font               = Enum.Font.GothamBold
    titleText.TextXAlignment     = Enum.TextXAlignment.Left
    titleText.ZIndex             = 3

    -- ── Drag ──────────────────────────────────────────────
    local dragging, dragStart, startPos = false, nil, nil
    titlebar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = i.Position
            startPos  = win.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            win.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ── Accent bar ────────────────────────────────────────
    local accentBar = Instance.new("Frame", win)
    accentBar.Size                  = UDim2.new(1, 0, 0, 1)
    accentBar.Position              = UDim2.new(0, 0, 0, 48)
    accentBar.BackgroundColor3      = T.ACCENT
    accentBar.BackgroundTransparency = 0.5
    accentBar.BorderSizePixel       = 0
    accentBar.ZIndex                = 2

    -- ── Sidebar ───────────────────────────────────────────
    local sidebar = Instance.new("Frame", win)
    sidebar.Size            = UDim2.new(0, 110, 1, -49)
    sidebar.Position        = UDim2.new(0, 0, 0, 49)
    sidebar.BackgroundColor3 = T.BG_SIDEBAR
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex          = 2

    Instance.new("UIListLayout", sidebar).Padding = UDim.new(0, 1)
    makePadding(sidebar, 6, 6, 0, 0)

    local sidebarLine = Instance.new("Frame", win)
    sidebarLine.Size            = UDim2.new(0, 1, 1, -49)
    sidebarLine.Position        = UDim2.new(0, 110, 0, 49)
    sidebarLine.BackgroundColor3 = T.BORDER
    sidebarLine.BorderSizePixel = 0
    sidebarLine.ZIndex          = 2

    self._sidebar = sidebar

    -- ── Content area ──────────────────────────────────────
    local content = Instance.new("Frame", win)
    content.Size                  = UDim2.new(1, -111, 1, -49)
    content.Position              = UDim2.new(0, 111, 0, 49)
    content.BackgroundTransparency = 1
    content.BorderSizePixel       = 0
    content.ClipsDescendants      = true
    self._content = content

    return self
end

-- ════════════════════════════════════════
-- Window visibility
-- ════════════════════════════════════════
function UILib:show()
    self._sg.Enabled = true
end

function UILib:hide()
    self._sg.Enabled = false
end

function UILib:toggle()
    self._sg.Enabled = not self._sg.Enabled
end

function UILib:destroy()
    self._sg:Destroy()
end

-- ════════════════════════════════════════
-- Internal: build a two-column page
-- ════════════════════════════════════════
function UILib:_newPage()
    local T = self.theme
    local page = Instance.new("ScrollingFrame", self._content)
    page.Size                    = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency  = 1
    page.BorderSizePixel         = 0
    page.ScrollBarThickness      = 2
    page.ScrollBarImageColor3    = T.ACCENT
    page.ScrollBarImageTransparency = 0.5
    page.CanvasSize              = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize     = Enum.AutomaticSize.Y
    page.Visible                 = false

    local cols = Instance.new("Frame", page)
    cols.Size               = UDim2.new(1, 0, 1, 0)
    cols.BackgroundTransparency = 1
    cols.BorderSizePixel    = 0
    makePadding(cols, 10, 10, 12, 12)
    local cl = Instance.new("UIListLayout", cols)
    cl.FillDirection       = Enum.FillDirection.Horizontal
    cl.Padding             = UDim.new(0, 10)
    cl.VerticalAlignment   = Enum.VerticalAlignment.Top

    local col1 = Instance.new("Frame", cols)
    col1.Size               = UDim2.new(0.5, -5, 1, 0)
    col1.BackgroundTransparency = 1
    col1.BorderSizePixel    = 0
    local l1 = Instance.new("UIListLayout", col1)
    l1.Padding = UDim.new(0, 3)

    local col2 = Instance.new("Frame", cols)
    col2.Size               = UDim2.new(0.5, -5, 1, 0)
    col2.BackgroundTransparency = 1
    col2.BorderSizePixel    = 0
    local l2 = Instance.new("UIListLayout", col2)
    l2.Padding = UDim.new(0, 3)

    return page, col1, col2
end

-- ════════════════════════════════════════
-- Tab system
-- ════════════════════════════════════════
--[[
    win:addTab(name) → col1, col2
    Adds a sidebar tab. Returns two column frames to pass into component functions.
]]
function UILib:addTab(name)
    local T = self.theme

    local btn = Instance.new("TextButton", self._sidebar)
    btn.Size            = UDim2.new(1, -2, 0, 30)
    btn.BackgroundColor3 = T.BG_SIDEBAR
    btn.BorderSizePixel = 0
    btn.Text            = name
    btn.TextColor3      = T.TEXT_DIM
    btn.TextSize        = 11
    btn.Font            = Enum.Font.GothamBold
    btn.ZIndex          = 3
    makeCorner(btn, 3)

    local accent = Instance.new("Frame", btn)
    accent.Size            = UDim2.new(0, 2, 0.6, 0)
    accent.Position        = UDim2.new(0, 0, 0.2, 0)
    accent.BackgroundColor3 = T.ACCENT
    accent.BorderSizePixel = 0
    accent.Visible         = false
    makeCorner(accent, 2)

    btn.MouseEnter:Connect(function()
        if self._activeTab ~= name then
            tween(btn, 0.08, { BackgroundColor3 = T.BG_RAISED, TextColor3 = Color3.fromRGB(140, 140, 160) })
        end
    end)
    btn.MouseLeave:Connect(function()
        if self._activeTab ~= name then
            tween(btn, 0.08, { BackgroundColor3 = T.BG_SIDEBAR, TextColor3 = T.TEXT_DIM })
        end
    end)

    local page, col1, col2 = self:_newPage()
    self._tabs[name]  = { btn = btn, accent = accent }
    self._pages[name] = { page = page, col1 = col1, col2 = col2 }

    btn.MouseButton1Click:Connect(function() self:selectTab(name) end)
    return col1, col2
end

--[[
    win:selectTab(name)
    Switches the visible tab to the one with the given name.
]]
function UILib:selectTab(name)
    local T = self.theme
    for n, data in pairs(self._tabs) do
        local active = n == name
        data.btn.BackgroundColor3 = active and T.BG_HOVER or T.BG_SIDEBAR
        data.btn.TextColor3       = active and T.TEXT_PRIMARY or T.TEXT_DIM
        data.accent.Visible       = active
        self._pages[n].page.Visible = active
    end
    self._activeTab = name
end

-- ════════════════════════════════════════
-- Components
-- ════════════════════════════════════════

--[[
    win:addSection(col, text)
    Adds a labelled horizontal divider to the given column.
]]
function UILib:addSection(col, text)
    local T = self.theme
    local wrap = Instance.new("Frame", col)
    wrap.Size               = UDim2.new(1, 0, 0, 24)
    wrap.BackgroundTransparency = 1
    wrap.BorderSizePixel    = 0

    local lbl = Instance.new("TextLabel", wrap)
    lbl.Size               = UDim2.new(1, 0, 0, 13)
    lbl.Position           = UDim2.new(0, 0, 1, -14)
    lbl.BackgroundTransparency = 1
    lbl.Text               = text:upper()
    lbl.TextColor3         = T.TEXT_SECTION
    lbl.TextSize           = 9
    lbl.Font               = Enum.Font.GothamBold
    lbl.TextXAlignment     = Enum.TextXAlignment.Left

    local line = Instance.new("Frame", wrap)
    line.Size            = UDim2.new(1, 0, 0, 1)
    line.Position        = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = T.BORDER
    line.BorderSizePixel = 0
end

--[[
    win:addToggle(col, label, callback)
    callback(on: bool)
    Adds a toggle row. Returns a table with a :set(bool) method to set state externally.
]]
function UILib:addToggle(col, label, callback)
    local T = self.theme

    local row = Instance.new("Frame", col)
    row.Size            = UDim2.new(1, 0, 0, 24)
    row.BackgroundColor3 = T.BG_RAISED
    row.BorderSizePixel = 0
    makeCorner(row, 3)
    makeStroke(row, T.BORDER, 1)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size               = UDim2.new(1, -28, 1, 0)
    lbl.Position           = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = T.TEXT_LABEL
    lbl.TextSize           = 11
    lbl.Font               = Enum.Font.Gotham
    lbl.TextXAlignment     = Enum.TextXAlignment.Left

    local box = Instance.new("Frame", row)
    box.Size            = UDim2.new(0, 11, 0, 11)
    box.Position        = UDim2.new(1, -18, 0.5, -5)
    box.BackgroundColor3 = T.BG_MID
    box.BorderSizePixel = 0
    makeCorner(box, 2)
    makeStroke(box, T.BORDER_LIGHT, 1)

    local check = Instance.new("TextLabel", box)
    check.Size               = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Text               = "✓"
    check.TextColor3         = T.ACCENT
    check.TextSize           = 8
    check.Font               = Enum.Font.GothamBold
    check.Visible            = false

    local on = false

    local function setState(value)
        on = value
        check.Visible = on
        if on then
            box.BackgroundColor3 = Color3.fromRGB(18, 28, 48)
            tween(box:FindFirstChildOfClass("UIStroke"), 0.1, { Color = T.ACCENT })
            tween(lbl, 0.1, { TextColor3 = T.TEXT_PRIMARY })
        else
            box.BackgroundColor3 = T.BG_MID
            tween(box:FindFirstChildOfClass("UIStroke"), 0.1, { Color = T.BORDER_LIGHT })
            tween(lbl, 0.1, { TextColor3 = T.TEXT_LABEL })
        end
    end

    local hitbox = Instance.new("TextButton", row)
    hitbox.Size               = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text               = ""
    hitbox.ZIndex             = 2

    hitbox.MouseEnter:Connect(function()
        tween(row, 0.08, { BackgroundColor3 = T.BG_HOVER })
        tween(lbl, 0.08, { TextColor3 = T.TEXT_PRIMARY })
    end)
    hitbox.MouseLeave:Connect(function()
        tween(row, 0.08, { BackgroundColor3 = T.BG_RAISED })
        if not on then tween(lbl, 0.08, { TextColor3 = T.TEXT_LABEL }) end
    end)
    hitbox.MouseButton1Click:Connect(function()
        setState(not on)
        callback(on)
    end)

    return {
        -- Programmatically set the toggle state (does NOT fire callback)
        set = function(_, value)
            setState(value)
        end
    }
end

--[[
    win:addButton(col, label, callback)
    callback(btn: TextButton)
    Adds a clickable button. Returns the TextButton instance.
]]
function UILib:addButton(col, label, callback)
    local T = self.theme

    local btn = Instance.new("TextButton", col)
    btn.Size            = UDim2.new(1, 0, 0, 24)
    btn.BackgroundColor3 = T.BG_RAISED
    btn.BorderSizePixel = 0
    btn.Text            = label
    btn.TextColor3      = T.ACCENT
    btn.TextSize        = 11
    btn.Font            = Enum.Font.GothamBold
    makeCorner(btn, 3)
    makeStroke(btn, T.BORDER, 1)

    btn.MouseEnter:Connect(function()  tween(btn, 0.08, { BackgroundColor3 = T.BG_HOVER  }) end)
    btn.MouseLeave:Connect(function()  tween(btn, 0.08, { BackgroundColor3 = T.BG_RAISED }) end)
    btn.MouseButton1Click:Connect(function() callback(btn) end)

    return btn
end

--[[
    win:addSlider(col, label, min, max, default, callback)
    callback(value: number)
    Adds an integer slider. Returns a table with a :set(value) method.
]]
function UILib:addSlider(col, label, min, max, default, callback)
    local T = self.theme

    local container = Instance.new("Frame", col)
    container.Size            = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = T.BG_RAISED
    container.BorderSizePixel = 0
    makeCorner(container, 3)
    makeStroke(container, T.BORDER, 1)

    local lbl = Instance.new("TextLabel", container)
    lbl.Size               = UDim2.new(0.6, 0, 0, 16)
    lbl.Position           = UDim2.new(0, 8, 0, 3)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = T.TEXT_LABEL
    lbl.TextSize           = 11
    lbl.Font               = Enum.Font.Gotham
    lbl.TextXAlignment     = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", container)
    valLbl.Size               = UDim2.new(0.4, -8, 0, 16)
    valLbl.Position           = UDim2.new(0.6, 0, 0, 3)
    valLbl.BackgroundTransparency = 1
    valLbl.Text               = tostring(default)
    valLbl.TextColor3         = T.ACCENT
    valLbl.TextSize           = 10
    valLbl.Font               = Enum.Font.GothamBold
    valLbl.TextXAlignment     = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", container)
    track.Size            = UDim2.new(1, -16, 0, 4)
    track.Position        = UDim2.new(0, 8, 0, 27)
    track.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    track.BorderSizePixel = 0
    track.Active          = true
    makeCorner(track, 99)

    local fill = Instance.new("Frame", track)
    fill.Size            = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = T.ACCENT
    fill.BorderSizePixel = 0
    makeCorner(fill, 99)

    local handle = Instance.new("Frame", track)
    handle.Size            = UDim2.new(0, 9, 0, 9)
    handle.AnchorPoint     = Vector2.new(0.5, 0.5)
    handle.Position        = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    handle.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    handle.BorderSizePixel = 0
    handle.ZIndex          = 4
    makeCorner(handle, 99)
    makeStroke(handle, Color3.fromRGB(45, 45, 60), 1)

    local isDragging = false

    local function update(x)
        local t   = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * t)
        handle.Position = UDim2.new(t, 0, 0.5, 0)
        fill.Size       = UDim2.new(t, 0, 1, 0)
        valLbl.Text     = tostring(val)
        callback(val)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            update(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if isDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            update(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
    end)

    return {
        -- Set the slider value programmatically (does NOT fire callback)
        set = function(_, value)
            local t = math.clamp((value - min) / (max - min), 0, 1)
            handle.Position = UDim2.new(t, 0, 0.5, 0)
            fill.Size       = UDim2.new(t, 0, 1, 0)
            valLbl.Text     = tostring(math.floor(value))
        end
    }
end

--[[
    win:addDropdown(col, label, options, default, callback)
    options  table of strings
    callback(value: string)
    Adds an animated dropdown. Returns a table with a :set(value) method.
]]
function UILib:addDropdown(col, label, options, default, callback)
    local T = self.theme

    local container = Instance.new("Frame", col)
    container.Size               = UDim2.new(1, 0, 0, 24)
    container.BackgroundColor3   = T.BG_RAISED
    container.BorderSizePixel    = 0
    container.ClipsDescendants   = false
    container.ZIndex             = 5
    makeCorner(container, 3)
    makeStroke(container, T.BORDER, 1)

    local lbl = Instance.new("TextLabel", container)
    lbl.Size               = UDim2.new(0.5, 0, 1, 0)
    lbl.Position           = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = T.TEXT_LABEL
    lbl.TextSize           = 11
    lbl.Font               = Enum.Font.Gotham
    lbl.TextXAlignment     = Enum.TextXAlignment.Left
    lbl.ZIndex             = 5

    local dropBtn = Instance.new("TextButton", container)
    dropBtn.Size               = UDim2.new(0.5, -8, 1, 0)
    dropBtn.Position           = UDim2.new(0.5, 0, 0, 0)
    dropBtn.BackgroundTransparency = 1
    dropBtn.Text               = default .. "  ▾"
    dropBtn.TextColor3         = T.ACCENT
    dropBtn.TextSize           = 10
    dropBtn.Font               = Enum.Font.GothamBold
    dropBtn.TextXAlignment     = Enum.TextXAlignment.Right
    dropBtn.ZIndex             = 6

    local menu = Instance.new("Frame", container)
    menu.Size              = UDim2.new(1, 0, 0, 0)
    menu.Position          = UDim2.new(0, 0, 1, 1)
    menu.BackgroundColor3  = T.BG_DEEP
    menu.BorderSizePixel   = 0
    menu.ClipsDescendants  = true
    menu.ZIndex            = 10
    menu.Visible           = false
    makeCorner(menu, 3)
    makeStroke(menu, T.BORDER_LIGHT, 1)
    Instance.new("UIListLayout", menu).Padding = UDim.new(0, 0)

    local isOpen = false

    for _, opt in ipairs(options) do
        local ob = Instance.new("TextButton", menu)
        ob.Size            = UDim2.new(1, 0, 0, 22)
        ob.BackgroundColor3 = T.BG_DEEP
        ob.BorderSizePixel = 0
        ob.Text            = opt
        ob.TextColor3      = Color3.fromRGB(160, 160, 175)
        ob.TextSize        = 10
        ob.Font            = Enum.Font.Gotham
        ob.ZIndex          = 11

        ob.MouseEnter:Connect(function()
            tween(ob, 0.06, { BackgroundColor3 = T.BG_HOVER, TextColor3 = T.TEXT_PRIMARY })
        end)
        ob.MouseLeave:Connect(function()
            tween(ob, 0.06, { BackgroundColor3 = T.BG_DEEP, TextColor3 = Color3.fromRGB(160, 160, 175) })
        end)
        ob.MouseButton1Click:Connect(function()
            dropBtn.Text = opt .. "  ▾"
            isOpen       = false
            menu.Visible = false
            tween(menu, 0.1, { Size = UDim2.new(1, 0, 0, 0) })
            callback(opt)
        end)
    end

    dropBtn.MouseButton1Click:Connect(function()
        isOpen       = not isOpen
        menu.Visible = true
        tween(menu, 0.12, { Size = UDim2.new(1, 0, 0, isOpen and #options * 22 or 0) })
        if not isOpen then
            task.delay(0.12, function() menu.Visible = false end)
        end
    end)

    return {
        set = function(_, value)
            dropBtn.Text = value .. "  ▾"
        end
    }
end

--[[
    win:addKeybind(col, label, default, callback)
    default   Enum.KeyCode
    callback(key: Enum.KeyCode)
    Adds a key-bind picker row.
]]
function UILib:addKeybind(col, label, default, callback)
    local T = self.theme

    local row = Instance.new("Frame", col)
    row.Size            = UDim2.new(1, 0, 0, 24)
    row.BackgroundColor3 = T.BG_RAISED
    row.BorderSizePixel = 0
    makeCorner(row, 3)
    makeStroke(row, T.BORDER, 1)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size               = UDim2.new(0.5, 0, 1, 0)
    lbl.Position           = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = T.TEXT_LABEL
    lbl.TextSize           = 11
    lbl.Font               = Enum.Font.Gotham
    lbl.TextXAlignment     = Enum.TextXAlignment.Left

    local keyBtn = Instance.new("TextButton", row)
    keyBtn.Size               = UDim2.new(0.5, -8, 1, 0)
    keyBtn.Position           = UDim2.new(0.5, 0, 0, 0)
    keyBtn.BackgroundTransparency = 1
    keyBtn.Text               = "[ " .. tostring(default):gsub("Enum.KeyCode.", "") .. " ]"
    keyBtn.TextColor3         = T.ACCENT
    keyBtn.TextSize           = 10
    keyBtn.Font               = Enum.Font.GothamBold
    keyBtn.TextXAlignment     = Enum.TextXAlignment.Right

    local listening = false

    keyBtn.MouseButton1Click:Connect(function()
        listening        = true
        keyBtn.Text      = "[ ... ]"
        keyBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
    end)

    UIS.InputBegan:Connect(function(i)
        if not listening then return end
        if i.UserInputType == Enum.UserInputType.Keyboard then
            listening         = false
            keyBtn.Text       = "[ " .. tostring(i.KeyCode):gsub("Enum.KeyCode.", "") .. " ]"
            keyBtn.TextColor3 = T.ACCENT
            callback(i.KeyCode)
        end
    end)
end

--[[
    win:addColorSlider(col, label, initialColor, callback)
    initialColor  Color3   Starting color (optional, defaults to white)
    callback(color: Color3)
    Adds a hue-spectrum color picker row.
]]
function UILib:addColorSlider(col, label, initialColor, callback)
    local T        = self.theme
    initialColor   = initialColor or Color3.fromRGB(114, 137, 218)
    callback       = callback or function() end

    local container = Instance.new("Frame", col)
    container.Size            = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = T.BG_RAISED
    container.BorderSizePixel = 0
    makeCorner(container, 3)
    makeStroke(container, T.BORDER, 1)

    local lbl = Instance.new("TextLabel", container)
    lbl.Size               = UDim2.new(0.6, 0, 0, 16)
    lbl.Position           = UDim2.new(0, 8, 0, 3)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = T.TEXT_LABEL
    lbl.TextSize           = 11
    lbl.Font               = Enum.Font.Gotham
    lbl.TextXAlignment     = Enum.TextXAlignment.Left

    local preview = Instance.new("Frame", container)
    preview.Size            = UDim2.new(0, 9, 0, 9)
    preview.Position        = UDim2.new(1, -17, 0, 4)
    preview.BackgroundColor3 = initialColor
    preview.BorderSizePixel = 0
    makeCorner(preview, 2)

    local track = Instance.new("Frame", container)
    track.Size            = UDim2.new(1, -16, 0, 5)
    track.Position        = UDim2.new(0, 8, 0, 26)
    track.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    track.BorderSizePixel = 0
    track.Active          = true
    makeCorner(track, 99)

    local grad = Instance.new("UIGradient", track)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 0,   0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 165, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0,   255, 0)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,   120, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(114, 0,   255)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 0,   200)),
    })

    local handle = Instance.new("Frame", track)
    handle.Size            = UDim2.new(0, 9, 0, 9)
    handle.AnchorPoint     = Vector2.new(0.5, 0.5)
    handle.Position        = UDim2.new(0.67, 0, 0.5, 0)
    handle.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    handle.BorderSizePixel = 0
    handle.ZIndex          = 4
    makeCorner(handle, 99)
    makeStroke(handle, Color3.fromRGB(45, 45, 60), 1)

    -- Hue stop table for interpolation
    local stops = {
        { 0,    Color3.fromRGB(255, 0,   0)   },
        { 0.17, Color3.fromRGB(255, 165, 0)   },
        { 0.33, Color3.fromRGB(255, 255, 0)   },
        { 0.5,  Color3.fromRGB(0,   255, 0)   },
        { 0.67, Color3.fromRGB(0,   120, 255) },
        { 0.83, Color3.fromRGB(114, 0,   255) },
        { 1,    Color3.fromRGB(255, 0,   200) },
    }

    local function lerpColor(a, b, t)
        return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
    end

    local function colorAtT(t)
        t = math.clamp(t, 0, 1)
        for i = 1, #stops - 1 do
            local t0, c0 = stops[i][1],   stops[i][2]
            local t1, c1 = stops[i+1][1], stops[i+1][2]
            if t >= t0 and t <= t1 then
                return lerpColor(c0, c1, (t - t0) / (t1 - t0))
            end
        end
        return stops[#stops][2]
    end

    local isDragging = false

    local function applyT(t)
        local color = colorAtT(t)
        handle.Position          = UDim2.new(t, 0, 0.5, 0)
        preview.BackgroundColor3 = color
        callback(color)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            applyT(math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1))
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if isDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            applyT(math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1))
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
    end)
end

return UILib
