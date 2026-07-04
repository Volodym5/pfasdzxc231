-- ===== Minimal footprint setup =====
local setthreadidentity = setthreadidentity or syn.set_thread_identity or function() end
local getthreadidentity = getthreadidentity or syn.get_thread_identity or function() return 3 end
local cloneref = cloneref or function(x) return x end
local clonefunction = clonefunction or function(f) return f end

local _Instance_new = clonefunction(Instance.new)
local _task_spawn = clonefunction(task.spawn)
local _task_delay = clonefunction(task.delay)
local _pcall = clonefunction(pcall)
local _Vector2_new = clonefunction(Vector2.new)
local _UDim2_new = clonefunction(UDim2.new)

local function New(className, parent)
    local obj = _Instance_new(className)
    if parent then obj.Parent = parent end
    return obj
end

-- ===== Services via cloneref =====
local TweenService = cloneref(game:GetService("TweenService"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Players = cloneref(game:GetService("Players"))
local player = Players.LocalPlayer

-- ===== Find or create host GUI =====
local gui = gethui()
if not gui or not gui.Parent then
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("ScreenGui") and v.Parent then
            gui = v
            break
        end
    end
end

-- ===== Script URLs =====
local SCRIPTS = {
    ["Bloxstrike"] = "https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/Bloxstrike/main.lua",
    ["Sniper Duels"] = "https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/Sniper%20Duels/main.lua",
    ["Deadline"] = "https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/Deadline/ui.lua",
    ["Operation One"] = "https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/Operation%20One/main.lua",
    ["Rivals"] = "https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/Rivals/main.lua",
}

-- ===== Palette =====
local BG          = Color3.fromRGB(14, 14, 18)
local BG_TOP      = Color3.fromRGB(18, 18, 24)
local PANEL       = Color3.fromRGB(20, 20, 26)
local SEARCH_BG   = Color3.fromRGB(17, 17, 23)
local BTN         = Color3.fromRGB(24, 24, 30)
local BTN_HOVER   = Color3.fromRGB(34, 34, 42)
local BTN_PRESS   = Color3.fromRGB(28, 28, 35)
local ACCENT      = Color3.fromRGB(110, 120, 255)
local ACCENT_2    = Color3.fromRGB(160, 110, 255)
local TEXT        = Color3.fromRGB(240, 240, 248)
local SUBTEXT     = Color3.fromRGB(135, 135, 150)
local STROKE      = Color3.fromRGB(34, 34, 42)
local SUCCESS     = Color3.fromRGB(90, 200, 130)
local DANGER      = Color3.fromRGB(220, 80, 80)

local CORNER = 16
local WINDOW_SIZE = UDim2.fromOffset(340, 460)

-- ===== TweenInfo cache =====
local TI_QUAD_FAST   = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_QUAD_MED    = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_QUAD_SLOW   = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_QUINT_HOVER = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_QUINT_LEAVE = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_BACK_IN     = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TI_SINE_OUT    = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local TI_QUINT_IN    = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

local function tween(obj, props, tweenInfo)
    return TweenService:Create(obj, tweenInfo or TI_QUAD_MED, props)
end

-- ===== Safe connection wrapper =====
local function connectSignal(signal, callback)
    local succ, conn = _pcall(function()
        return signal.Connect(signal, callback)
    end)
    if succ and conn then return conn end
    return signal:Connect(callback)
end

-- ===== Build UI =====
local container = New("ScreenGui")
container.ResetOnSpawn = false
container.IgnoreGuiInset = true
container.DisplayOrder = 999
container.ZIndexBehavior = Enum.ZIndexBehavior.Global
container.Parent = gui

-- Center of screen
local camera = workspace.CurrentCamera
local screenSize = camera.ViewportSize
local startX = (screenSize.X / 2) - 170
local startY = (screenSize.Y / 2) - 230

local windowContainer = New("Frame")
windowContainer.Size = WINDOW_SIZE
windowContainer.Position = _UDim2_new(0, startX, 0, startY)
windowContainer.BackgroundTransparency = 1
windowContainer.ZIndex = 1
windowContainer.Parent = container

local main = New("CanvasGroup")
main.Size = UDim2.fromScale(1, 1)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.ZIndex = 2
main.Parent = windowContainer
New("UICorner", main).CornerRadius = UDim.new(0, CORNER)

local mainGradient = New("UIGradient", main)
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, BG_TOP),
    ColorSequenceKeypoint.new(0.15, BG),
    ColorSequenceKeypoint.new(1, BG)
})
mainGradient.Rotation = 90

local mainStroke = New("UIStroke", main)
mainStroke.Color = STROKE
mainStroke.Thickness = 1
mainStroke.Transparency = 0.3

-- ===== Title bar =====
local titleBar = New("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = PANEL
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 3
titleBar.Parent = main
New("UICorner", titleBar).CornerRadius = UDim.new(0, CORNER)

local titleBarMask = New("Frame")
titleBarMask.BackgroundColor3 = PANEL
titleBarMask.BorderSizePixel = 0
titleBarMask.Size = UDim2.new(1, 0, 0, CORNER)
titleBarMask.Position = UDim2.new(0, 0, 1, -CORNER)
titleBarMask.ZIndex = 3
titleBarMask.Parent = titleBar

local titleDivider = New("Frame")
titleDivider.Size = UDim2.new(1, -24, 0, 1)
titleDivider.Position = UDim2.new(0, 12, 1, -1)
titleDivider.BackgroundColor3 = STROKE
titleDivider.BorderSizePixel = 0
titleDivider.ZIndex = 3
titleDivider.Parent = titleBar

local titleDot = New("Frame")
titleDot.Size = UDim2.fromOffset(8, 8)
titleDot.Position = UDim2.fromOffset(14, 18)
titleDot.BackgroundColor3 = ACCENT
titleDot.BorderSizePixel = 0
titleDot.ZIndex = 4
titleDot.Parent = titleBar
New("UICorner", titleDot).CornerRadius = UDim.new(1, 0)

local titleText = New("TextLabel")
titleText.BackgroundTransparency = 1
titleText.Size = UDim2.new(1, -100, 1, 0)
titleText.Position = UDim2.fromOffset(30, 0)
titleText.Text = "Script Hub"
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.TextColor3 = TEXT
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.ZIndex = 4
titleText.Parent = titleBar

local closeBtn = New("TextButton")
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 43)
closeBtn.AutoButtonColor = false
closeBtn.Text = ""
closeBtn.ZIndex = 4
closeBtn.Parent = titleBar
New("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local closeIcon = New("Frame")
closeIcon.Size = UDim2.fromOffset(12, 2)
closeIcon.Position = UDim2.fromScale(0.5, 0.5)
closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
closeIcon.Rotation = 45
closeIcon.BackgroundColor3 = SUBTEXT
closeIcon.BorderSizePixel = 0
closeIcon.ZIndex = 5
closeIcon.Parent = closeBtn

local closeIcon2 = New("Frame")
closeIcon2.Size = UDim2.fromOffset(12, 2)
closeIcon2.Position = UDim2.fromScale(0.5, 0.5)
closeIcon2.AnchorPoint = Vector2.new(0.5, 0.5)
closeIcon2.Rotation = -45
closeIcon2.BackgroundColor3 = SUBTEXT
closeIcon2.BorderSizePixel = 0
closeIcon2.ZIndex = 5
closeIcon2.Parent = closeBtn

connectSignal(closeBtn.MouseEnter, function()
    tween(closeBtn, {BackgroundColor3 = DANGER}, TI_QUAD_MED):Play()
    tween(closeIcon, {BackgroundColor3 = Color3.new(1, 1, 1)}, TI_QUAD_MED):Play()
    tween(closeIcon2, {BackgroundColor3 = Color3.new(1, 1, 1)}, TI_QUAD_MED):Play()
end)
connectSignal(closeBtn.MouseLeave, function()
    tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(36, 36, 43)}, TI_QUAD_MED):Play()
    tween(closeIcon, {BackgroundColor3 = SUBTEXT}, TI_QUAD_MED):Play()
    tween(closeIcon2, {BackgroundColor3 = SUBTEXT}, TI_QUAD_MED):Play()
end)

local function closePanel()
    tween(windowContainer, {Size = UDim2.new(WINDOW_SIZE.X.Scale, WINDOW_SIZE.X.Offset, 0, 0)}, TI_QUINT_IN):Play()
    tween(main, {GroupTransparency = 1}, TI_QUINT_IN):Play()
    _task_delay(0.3, function() container:Destroy() end)
end
connectSignal(closeBtn.MouseButton1Click, closePanel)

connectSignal(UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Escape and container.Parent then
        closePanel()
    end
end)

-- ===== Dragging =====
do
    local dragging = false
    local clickOffset
    local gotOffset = false

    connectSignal(titleBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            gotOffset = false
            tween(mainStroke, {Color = ACCENT, Transparency = 0}, TI_QUAD_FAST):Play()
        end
    end)

    connectSignal(UserInputService.InputChanged, function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if not gotOffset then
                clickOffset = _Vector2_new(
                    windowContainer.Position.X.Offset - input.Position.X,
                    windowContainer.Position.Y.Offset - input.Position.Y
                )
                gotOffset = true
            end
            windowContainer.Position = _UDim2_new(
                0, input.Position.X + clickOffset.X,
                0, input.Position.Y + clickOffset.Y
            )
        end
    end)

    connectSignal(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            tween(mainStroke, {Color = STROKE, Transparency = 0.3}, TI_QUAD_MED):Play()
        end
    end)
end

-- ===== Search bar =====
local searchWrap = New("Frame")
searchWrap.Size = UDim2.new(1, -28, 0, 38)
searchWrap.Position = UDim2.fromOffset(14, 56)
searchWrap.BackgroundColor3 = SEARCH_BG
searchWrap.BorderSizePixel = 0
searchWrap.ZIndex = 3
searchWrap.Parent = main
New("UICorner", searchWrap).CornerRadius = UDim.new(0, 10)

local searchStroke = New("UIStroke", searchWrap)
searchStroke.Color = STROKE
searchStroke.Thickness = 1
searchStroke.Transparency = 0.6

local searchDot = New("Frame")
searchDot.Size = UDim2.fromOffset(7, 7)
searchDot.Position = UDim2.fromOffset(13, 13)
searchDot.BackgroundColor3 = SUBTEXT
searchDot.BorderSizePixel = 0
searchDot.ZIndex = 4
searchDot.Parent = searchWrap
New("UICorner", searchDot).CornerRadius = UDim.new(1, 0)

local searchRing = New("Frame")
searchRing.Size = UDim2.fromOffset(7, 7)
searchRing.Position = UDim2.fromOffset(10, 10)
searchRing.BackgroundTransparency = 1
searchRing.BorderSizePixel = 2
searchRing.BorderColor3 = SUBTEXT
searchRing.ZIndex = 4
searchRing.Parent = searchWrap
New("UICorner", searchRing).CornerRadius = UDim.new(1, 0)

local searchBox = New("TextBox")
searchBox.Size = UDim2.new(1, -52, 1, 0)
searchBox.Position = UDim2.fromOffset(34, 0)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "Search scripts..."
searchBox.PlaceholderColor3 = SUBTEXT
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 13
searchBox.TextColor3 = TEXT
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ZIndex = 4
searchBox.Parent = searchWrap

connectSignal(searchBox.Focused, function()
    tween(searchStroke, {Color = ACCENT, Transparency = 0}, TI_QUAD_MED):Play()
    tween(searchDot, {BackgroundColor3 = ACCENT}, TI_QUAD_MED):Play()
    tween(searchRing, {BorderColor3 = ACCENT}, TI_QUAD_MED):Play()
end)
connectSignal(searchBox.FocusLost, function()
    tween(searchStroke, {Color = STROKE, Transparency = 0.6}, TI_QUAD_MED):Play()
    tween(searchDot, {BackgroundColor3 = SUBTEXT}, TI_QUAD_MED):Play()
    tween(searchRing, {BorderColor3 = SUBTEXT}, TI_QUAD_MED):Play()
end)

local resultCount = New("TextLabel")
resultCount.BackgroundTransparency = 1
resultCount.Size = UDim2.fromOffset(24, 18)
resultCount.Position = UDim2.new(1, -30, 0.5, -9)
resultCount.Font = Enum.Font.GothamMedium
resultCount.TextSize = 10
resultCount.TextColor3 = SUBTEXT
resultCount.Text = ""
resultCount.TextXAlignment = Enum.TextXAlignment.Right
resultCount.ZIndex = 4
resultCount.Parent = searchWrap

-- ===== Script list =====
local list = New("ScrollingFrame")
list.Size = UDim2.new(1, -28, 1, -140)
list.Position = UDim2.fromOffset(14, 106)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.ScrollBarImageColor3 = ACCENT
list.ScrollBarImageTransparency = 0.7
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ZIndex = 3
list.Parent = main

local layout = New("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

-- ===== Footer =====
local footer = New("Frame")
footer.Size = UDim2.new(1, 0, 0, 34)
footer.Position = UDim2.new(0, 0, 1, -34)
footer.BackgroundColor3 = PANEL
footer.BorderSizePixel = 0
footer.ZIndex = 3
footer.Parent = main
New("UICorner", footer).CornerRadius = UDim.new(0, CORNER)

local footerMask = New("Frame")
footerMask.BackgroundColor3 = PANEL
footerMask.BorderSizePixel = 0
footerMask.Size = UDim2.new(1, 0, 0, CORNER)
footerMask.Position = UDim2.fromOffset(0, 0)
footerMask.ZIndex = 3
footerMask.Parent = footer

local footerDivider = New("Frame")
footerDivider.Size = UDim2.new(1, -24, 0, 1)
footerDivider.Position = UDim2.new(0, 12, 0, 0)
footerDivider.BackgroundColor3 = STROKE
footerDivider.BorderSizePixel = 0
footerDivider.ZIndex = 3
footerDivider.Parent = footer

local statusDot = New("Frame")
statusDot.Size = UDim2.fromOffset(7, 7)
statusDot.Position = UDim2.fromOffset(14, 14)
statusDot.BackgroundColor3 = SUCCESS
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 4
statusDot.Parent = footer
New("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

local statusPulse = New("Frame")
statusPulse.Size = UDim2.fromOffset(13, 13)
statusPulse.Position = UDim2.fromOffset(11, 11)
statusPulse.BackgroundColor3 = SUCCESS
statusPulse.BackgroundTransparency = 0.8
statusPulse.BorderSizePixel = 0
statusPulse.ZIndex = 3
statusPulse.Parent = footer
New("UICorner", statusPulse).CornerRadius = UDim.new(1, 0)

local statusText = New("TextLabel")
statusText.BackgroundTransparency = 1
statusText.Size = UDim2.new(1, -120, 1, 0)
statusText.Position = UDim2.fromOffset(30, 0)
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 11
statusText.TextColor3 = SUBTEXT
statusText.Text = "Ready"
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.ZIndex = 4
statusText.Parent = footer

local versionText = New("TextLabel")
versionText.BackgroundTransparency = 1
versionText.Size = UDim2.fromOffset(56, 20)
versionText.Position = UDim2.new(1, -70, 0.5, -10)
versionText.Font = Enum.Font.GothamMedium
versionText.TextSize = 10
versionText.TextColor3 = SUBTEXT
versionText.Text = "v1.1.0"
versionText.TextXAlignment = Enum.TextXAlignment.Right
versionText.ZIndex = 4
versionText.Parent = footer

-- ===== Notification =====
local function notify(text, kind)
    kind = kind or "info"
    local color = kind == "success" and SUCCESS or (kind == "error" and DANGER or ACCENT)
    
    statusText.Text = text
    tween(statusDot, {BackgroundColor3 = color}, TI_QUAD_FAST):Play()
    tween(statusPulse, {BackgroundColor3 = color, BackgroundTransparency = 0.6}, TI_QUAD_FAST):Play()
    
    _task_delay(2.5, function()
        statusText.Text = "Ready"
        tween(statusDot, {BackgroundColor3 = SUCCESS}, TI_QUAD_SLOW):Play()
        tween(statusPulse, {BackgroundColor3 = SUCCESS, BackgroundTransparency = 0.8}, TI_QUAD_SLOW):Play()
    end)
end

-- ===== Script execution =====
local function executeScript(name)
    local url = SCRIPTS[name]
    if not url then
        notify("Script not found", "error")
        return
    end
    
    statusText.Text = name
    tween(statusDot, {BackgroundColor3 = ACCENT}, TI_QUAD_FAST):Play()
    tween(statusPulse, {BackgroundColor3 = ACCENT, BackgroundTransparency = 0.6}, TI_QUAD_FAST):Play()
    
    _task_spawn(function()
        local success, result = _pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        
        if success then
            notify(name, "success")
        else
            notify("Execution failed", "error")
        end
    end)
end

-- ===== Button creation =====
local entries = {}

local function createButton(order, name, url)
    local btn = New("TextButton")
    btn.LayoutOrder = order
    btn.Size = UDim2.new(1, 0, 0, 54)
    btn.BackgroundColor3 = BTN
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.ZIndex = 3
    btn.Parent = list
    New("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local accentBar = New("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, -16)
    accentBar.Position = UDim2.fromOffset(0, 8)
    accentBar.BackgroundColor3 = ACCENT
    accentBar.BackgroundTransparency = 1
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 4
    accentBar.Parent = btn
    New("UICorner", accentBar).CornerRadius = UDim.new(1, 0)
    
    local barGradient = New("UIGradient", accentBar)
    barGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, ACCENT),
        ColorSequenceKeypoint.new(1, ACCENT_2)
    })
    barGradient.Rotation = 90

    local scriptName = New("TextLabel")
    scriptName.BackgroundTransparency = 1
    scriptName.Size = UDim2.new(1, -30, 0, 18)
    scriptName.Position = UDim2.fromOffset(14, 10)
    scriptName.Text = name
    scriptName.Font = Enum.Font.GothamSemibold
    scriptName.TextSize = 13
    scriptName.TextColor3 = TEXT
    scriptName.TextXAlignment = Enum.TextXAlignment.Left
    scriptName.ZIndex = 4
    scriptName.Parent = btn

    local scriptUrl = New("TextLabel")
    scriptUrl.BackgroundTransparency = 1
    scriptUrl.Size = UDim2.new(1, -30, 0, 14)
    scriptUrl.Position = UDim2.fromOffset(14, 30)
    scriptUrl.Text = "Click to execute"
    scriptUrl.Font = Enum.Font.Gotham
    scriptUrl.TextSize = 10
    scriptUrl.TextColor3 = SUBTEXT
    scriptUrl.TextXAlignment = Enum.TextXAlignment.Left
    scriptUrl.ZIndex = 4
    scriptUrl.Parent = btn

    local arrow = New("TextLabel")
    arrow.BackgroundTransparency = 1
    arrow.Size = UDim2.fromOffset(16, 16)
    arrow.Position = UDim2.new(1, -24, 0.5, -8)
    arrow.Text = ">"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14
    arrow.TextColor3 = SUBTEXT
    arrow.ZIndex = 4
    arrow.Parent = btn

    connectSignal(btn.MouseEnter, function()
        tween(btn, {BackgroundColor3 = BTN_HOVER}, TI_QUINT_HOVER):Play()
        tween(accentBar, {BackgroundTransparency = 0}, TI_QUINT_HOVER):Play()
        tween(arrow, {TextColor3 = ACCENT, Position = UDim2.new(1, -20, 0.5, -8)}, TI_QUINT_HOVER):Play()
    end)
    connectSignal(btn.MouseLeave, function()
        tween(btn, {BackgroundColor3 = BTN}, TI_QUINT_LEAVE):Play()
        tween(accentBar, {BackgroundTransparency = 1}, TI_QUINT_LEAVE):Play()
        tween(arrow, {TextColor3 = SUBTEXT, Position = UDim2.new(1, -24, 0.5, -8)}, TI_QUINT_LEAVE):Play()
    end)
    connectSignal(btn.MouseButton1Down, function()
        tween(btn, {BackgroundColor3 = BTN_PRESS}, TI_QUAD_FAST):Play()
    end)
    connectSignal(btn.MouseButton1Up, function()
        tween(btn, {BackgroundColor3 = BTN_HOVER}, TI_QUAD_MED):Play()
    end)
    connectSignal(btn.MouseButton1Click, function()
        executeScript(name)
    end)

    table.insert(entries, {button = btn, name = name:lower()})
    return btn
end

-- Create buttons
local order = 1
for name, url in pairs(SCRIPTS) do
    createButton(order, name, url)
    order = order + 1
end

-- ===== Search filtering =====
local function refreshSearch()
    local query = searchBox.Text:lower()
    local visibleCount = 0
    for _, entry in ipairs(entries) do
        local match = query == "" or entry.name:find(query, 1, true)
        entry.button.Visible = match
        if match then visibleCount = visibleCount + 1 end
    end
    resultCount.Text = query == "" and "" or visibleCount
end

connectSignal(searchBox:GetPropertyChangedSignal("Text"), refreshSearch)

-- ===== Intro animation =====
windowContainer.Size = UDim2.new(WINDOW_SIZE.X.Scale, WINDOW_SIZE.X.Offset, 0, 0)
main.GroupTransparency = 1

tween(windowContainer, {Size = WINDOW_SIZE}, TI_BACK_IN):Play()
tween(main, {GroupTransparency = 0}, TI_SINE_OUT):Play()

_task_delay(0.5, function()
    notify("Panel loaded", "success")
end)
