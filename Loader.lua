--[[
	App-style UI Shell v11 — perf + visual pass
	No remote code execution. Wire onButtonPressed() up to your own
	local ModuleScripts whenever you're ready.

	Changes vs v10:
	- Shadow: single sliced ImageLabel instead of 4 stacked frames.
	  Swap SHADOW_IMAGE below for your own uploaded soft-shadow PNG
	  (black-to-transparent radial, any size) for a real blur/falloff.
	- Perf: TweenInfo objects are now created once and reused, instead
	  of allocating a new TweenInfo + Tween on every single hover/press
	  event. Six buttons firing MouseEnter/Leave repeatedly was
	  generating a lot of short-lived garbage for no visual benefit.
	- Perf: dragging no longer creates a new TweenService Tween per
	  InputChanged sample. One RunService.Heartbeat connection lerps
	  toward the latest target position instead — same smoothness,
	  one persistent connection instead of N short-lived tween objects.
	- Visual: panel background now has a subtle vertical gradient
	  instead of flat color, for a bit of depth.
	- Visual: button hover accent bar now eases with a slight overshoot
	  instead of a flat fade, feels a touch snappier.
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ===== Palette =====
local BG          = Color3.fromRGB(16, 16, 20)
local BG_2        = Color3.fromRGB(20, 20, 25) -- gradient endpoint for panel bg
local PANEL       = Color3.fromRGB(22, 22, 27)
local SEARCH_BG   = Color3.fromRGB(19, 19, 25)
local BTN         = Color3.fromRGB(26, 26, 32)
local BTN_HOVER   = Color3.fromRGB(36, 36, 44)
local BTN_PRESS   = Color3.fromRGB(31, 31, 38)
local ACCENT      = Color3.fromRGB(122, 132, 255)
local ACCENT_2    = Color3.fromRGB(168, 122, 255)
local TEXT        = Color3.fromRGB(243, 243, 248)
local SUBTEXT     = Color3.fromRGB(140, 140, 152)
local STROKE      = Color3.fromRGB(38, 38, 46)
local SUCCESS     = Color3.fromRGB(94, 204, 135)

local CORNER = 18
local WINDOW_SIZE = UDim2.fromOffset(340, 460)

-- Replace with your own uploaded asset (black -> transparent radial PNG).
-- rbxassetid://0 will just render nothing, which is fine as a placeholder
-- until you upload one — the ImageTransparency tween still runs harmlessly.
local SHADOW_IMAGE = "rbxassetid://0"

-- ===== Cached TweenInfo (perf) =====
-- Building these once and reusing avoids allocating a fresh TweenInfo
-- table on every hover/press event across every button.
local TI_QUAD_FAST   = TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_QUAD_MED    = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_QUAD_SLOW   = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_QUINT_HOVER = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_QUINT_LEAVE = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_BACK_OUT    = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TI_ICON_DOWN   = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_ICON_UP     = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function tween(obj, props, tweenInfo)
	return TweenService:Create(obj, tweenInfo or TI_QUAD_MED, props)
end

-- ===== Root =====
local gui = Instance.new("ScreenGui")
gui.Name = "AppShell"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = player:WaitForChild("PlayerGui")

local windowContainer = Instance.new("Frame")
windowContainer.Name = "WindowContainer"
windowContainer.Size = WINDOW_SIZE
windowContainer.Position = UDim2.fromScale(0.5, 0.5)
windowContainer.AnchorPoint = Vector2.new(0.5, 0.5)
windowContainer.BackgroundTransparency = 1
windowContainer.ZIndex = 1
windowContainer.Parent = gui

-- Single sliced-image shadow instead of 4 stacked frames. Fixed pixel
-- offset padding (not Scale of windowContainer) for the same reason as
-- before: it only fades during collapse/expand, never resizes, so it
-- can't warp into a pill shape.
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
shadow.Size = UDim2.new(1, 48, 1, 48)
shadow.BackgroundTransparency = 1
shadow.Image = SHADOW_IMAGE
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 1
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24, 24, 24, 24) -- tune to your asset's actual blur border
shadow.ZIndex = 0
shadow.Parent = windowContainer

local function fadeShadow(visible, tweenInfo)
	tween(shadow, {ImageTransparency = visible and 0.55 or 1}, tweenInfo):Play()
end

local liftWrap = Instance.new("Frame")
liftWrap.Name = "LiftWrap"
liftWrap.Size = UDim2.fromScale(1, 1)
liftWrap.Position = UDim2.fromOffset(0, 0)
liftWrap.BackgroundTransparency = 1
liftWrap.ZIndex = 1
liftWrap.Parent = windowContainer

local main = Instance.new("CanvasGroup")
main.Name = "Main"
main.Size = UDim2.fromScale(1, 1)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.ZIndex = 2
main.Parent = liftWrap

Instance.new("UICorner", main).CornerRadius = UDim.new(0, CORNER)

-- Subtle vertical gradient for a bit of depth instead of flat color.
local mainGradient = Instance.new("UIGradient", main)
mainGradient.Color = ColorSequence.new(BG_2, BG)
mainGradient.Rotation = 90

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = STROKE
mainStroke.Thickness = 1
mainStroke.Transparency = 1

-- ===== Press-feedback for ICON-only controls (safe to scale — no text) =====
local function addIconPressFeedback(button, downScale)
	downScale = downScale or 0.96
	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = button

	local pressed = false

	button.MouseButton1Down:Connect(function()
		pressed = true
		tween(scale, {Scale = downScale}, TI_ICON_DOWN):Play()
	end)

	local function release()
		if not pressed then return end
		pressed = false
		tween(scale, {Scale = 1}, TI_ICON_UP):Play()
	end

	button.MouseButton1Up:Connect(release)
	button.MouseLeave:Connect(function()
		if pressed then release() end
	end)

	return scale
end

-- ===== Press-feedback for TEXT buttons (never scales — no font jitter) =====
local function addListPressFeedback(button, baseColor, hoverColor)
	local highlight = Instance.new("Frame")
	highlight.Size = UDim2.fromScale(1, 1)
	highlight.BackgroundColor3 = Color3.new(1, 1, 1)
	highlight.BackgroundTransparency = 1
	highlight.BorderSizePixel = 0
	highlight.ZIndex = button.ZIndex
	highlight.Parent = button
	Instance.new("UICorner", highlight).CornerRadius = UDim.new(0, 10)

	local pressed = false
	local hovering = false

	button.MouseButton1Down:Connect(function()
		pressed = true
		tween(highlight, {BackgroundTransparency = 0.9}, TI_QUAD_FAST):Play()
		tween(button, {BackgroundColor3 = BTN_PRESS}, TI_QUAD_FAST):Play()
	end)

	local function release()
		if not pressed then return end
		pressed = false
		tween(highlight, {BackgroundTransparency = 1}, TI_QUAD_SLOW):Play()
		tween(button, {BackgroundColor3 = hovering and hoverColor or baseColor}, TI_QUAD_MED):Play()
	end

	button.MouseButton1Up:Connect(release)
	button.MouseLeave:Connect(function()
		hovering = false
		if pressed then release() end
	end)
	button.MouseEnter:Connect(function()
		hovering = true
	end)

	return highlight
end

--============================================================
-- TITLE BAR
--============================================================
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = PANEL
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 3
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, CORNER)

local titleBarMask = Instance.new("Frame")
titleBarMask.Name = "CornerMask"
titleBarMask.BackgroundColor3 = PANEL
titleBarMask.BorderSizePixel = 0
titleBarMask.Size = UDim2.new(1, 0, 0, CORNER)
titleBarMask.Position = UDim2.new(0, 0, 1, -CORNER)
titleBarMask.ZIndex = 3
titleBarMask.Parent = titleBar

local titleBarBottomLine = Instance.new("Frame")
titleBarBottomLine.Size = UDim2.new(1, 0, 0, 1)
titleBarBottomLine.Position = UDim2.new(0, 0, 1, -1)
titleBarBottomLine.BackgroundColor3 = STROKE
titleBarBottomLine.BorderSizePixel = 0
titleBarBottomLine.ZIndex = 3
titleBarBottomLine.Parent = titleBar

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.fromOffset(24, 24)
avatar.Position = UDim2.fromOffset(12, 10)
avatar.BackgroundColor3 = SEARCH_BG
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
avatar.ZIndex = 4
avatar.Parent = titleBar
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

local titleText = Instance.new("TextLabel")
titleText.BackgroundTransparency = 1
titleText.Size = UDim2.new(1, -122, 1, 0)
titleText.Position = UDim2.fromOffset(44, 0)
titleText.Text = "Test Panel"
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 15
titleText.TextColor3 = TEXT
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.ZIndex = 4
titleText.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 43)
closeBtn.AutoButtonColor = false
closeBtn.Text = ""
closeBtn.ZIndex = 4
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
addIconPressFeedback(closeBtn, 0.85)

local xHolder = Instance.new("Frame")
xHolder.Size = UDim2.fromScale(1, 1)
xHolder.BackgroundTransparency = 1
xHolder.ZIndex = 4
xHolder.Parent = closeBtn

local function makeXBar(rotation)
	local bar = Instance.new("Frame")
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.Position = UDim2.fromScale(0.5, 0.5)
	bar.Size = UDim2.fromOffset(12, 2)
	bar.BackgroundColor3 = SUBTEXT
	bar.BorderSizePixel = 0
	bar.Rotation = rotation
	bar.ZIndex = 4
	bar.Parent = xHolder
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
	return bar
end
local xBar1 = makeXBar(45)
local xBar2 = makeXBar(-45)

local TI_XSPIN = TweenInfo.new(0.2, Enum.EasingStyle.Back)

closeBtn.MouseEnter:Connect(function()
	tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(214, 74, 74)}, TI_QUAD_MED):Play()
	tween(xBar1, {BackgroundColor3 = Color3.new(1, 1, 1)}, TI_QUAD_MED):Play()
	tween(xBar2, {BackgroundColor3 = Color3.new(1, 1, 1)}, TI_QUAD_MED):Play()
	tween(xHolder, {Rotation = 90}, TI_XSPIN):Play()
end)
closeBtn.MouseLeave:Connect(function()
	tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(36, 36, 43)}, TI_QUAD_MED):Play()
	tween(xBar1, {BackgroundColor3 = SUBTEXT}, TI_QUAD_MED):Play()
	tween(xBar2, {BackgroundColor3 = SUBTEXT}, TI_QUAD_MED):Play()
	tween(xHolder, {Rotation = 0}, TI_XSPIN):Play()
end)

local function closePanel()
	local collapseTime = 0.3
	tween(windowContainer,
		{Size = UDim2.new(windowContainer.Size.X.Scale, windowContainer.Size.X.Offset, 0, 0)},
		TweenInfo.new(collapseTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	):Play()
	tween(main, {GroupTransparency = 1}, TweenInfo.new(collapseTime * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In)):Play()
	tween(mainStroke, {Transparency = 1}, TweenInfo.new(collapseTime * 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)):Play()
	fadeShadow(false, TweenInfo.new(collapseTime * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In))
	task.delay(collapseTime, function()
		gui:Destroy()
	end)
end
closeBtn.MouseButton1Click:Connect(closePanel)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Escape and gui.Parent then
		closePanel()
	end
end)

-- ===== Dragging (perf: Heartbeat lerp instead of per-sample Tween) =====
do
	local dragging = false
	local dragStart, startPos
	local targetPos
	local heartbeatConn

	local LERP_SPEED = 22 -- higher = snappier follow, lower = smoother/laggier

	local function beginDrag(input)
		dragging = true
		dragStart = input.Position
		startPos = windowContainer.Position
		targetPos = startPos

		tween(liftWrap, {Position = UDim2.fromOffset(0, -5)}, TweenInfo.new(0.18, Enum.EasingStyle.Quint)):Play()
		tween(mainStroke, {Color = ACCENT}, TI_QUAD_MED):Play()

		if heartbeatConn then heartbeatConn:Disconnect() end
		heartbeatConn = RunService.Heartbeat:Connect(function(dt)
			if not dragging then return end
			local alpha = math.clamp(LERP_SPEED * dt, 0, 1)
			local cur = windowContainer.Position
			windowContainer.Position = UDim2.new(
				cur.X.Scale, cur.X.Offset + (targetPos.X.Offset - cur.X.Offset) * alpha,
				cur.Y.Scale, cur.Y.Offset + (targetPos.Y.Offset - cur.Y.Offset) * alpha
			)
		end)
	end

	local function endDrag()
		if not dragging then return end
		dragging = false
		if heartbeatConn then
			heartbeatConn:Disconnect()
			heartbeatConn = nil
		end
		-- The Heartbeat lerp trails slightly behind targetPos while dragging
		-- (that's what makes it smooth), so on release there's usually a
		-- small leftover gap. Snapping straight to targetPos closed that gap
		-- instantly, which read as a pop/jump. Easing it shut over a couple
		-- frames instead removes the jump while still landing on the exact
		-- released position.
		tween(windowContainer, {Position = targetPos}, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)):Play()

		tween(liftWrap, {Position = UDim2.fromOffset(0, 0)}, TI_BACK_OUT):Play()
		tween(mainStroke, {Color = STROKE}, TI_QUAD_MED):Play()
	end

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			beginDrag(input)
		end
	end)

	titleBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			endDrag()
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			targetPos = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			endDrag()
		end
	end)
end

-- ===== Search bar =====
local searchWrap = Instance.new("Frame")
searchWrap.Size = UDim2.new(1, -32, 0, 40)
searchWrap.Position = UDim2.fromOffset(16, 60)
searchWrap.BackgroundColor3 = SEARCH_BG
searchWrap.BorderSizePixel = 0
searchWrap.ZIndex = 3
searchWrap.Parent = main
Instance.new("UICorner", searchWrap).CornerRadius = UDim.new(1, 0)

local searchStroke = Instance.new("UIStroke", searchWrap)
searchStroke.Color = ACCENT
searchStroke.Thickness = 1
searchStroke.Transparency = 0.75

local searchIcon = Instance.new("ImageLabel")
searchIcon.BackgroundTransparency = 1
searchIcon.Size = UDim2.fromOffset(16, 16)
searchIcon.Position = UDim2.fromOffset(14, 12)
searchIcon.Image = "rbxassetid://3926305904"
searchIcon.ImageRectOffset = Vector2.new(964, 324)
searchIcon.ImageRectSize = Vector2.new(36, 36)
searchIcon.ImageColor3 = ACCENT
searchIcon.ImageTransparency = 0.25
searchIcon.ZIndex = 3
searchIcon.Parent = searchWrap

local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.Size = UDim2.new(1, -72, 1, 0)
searchBox.Position = UDim2.fromOffset(40, 0)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "Search..."
searchBox.PlaceholderColor3 = SUBTEXT
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.TextColor3 = TEXT
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = true
searchBox.ZIndex = 3
searchBox.Parent = searchWrap

searchBox.Focused:Connect(function()
	tween(searchStroke, {Color = ACCENT, Thickness = 1.5, Transparency = 0}, TI_QUAD_MED):Play()
	tween(searchIcon, {ImageColor3 = ACCENT, ImageTransparency = 0}, TI_QUAD_MED):Play()
	tween(searchWrap, {BackgroundColor3 = Color3.fromRGB(26, 27, 36)}, TI_QUAD_MED):Play()
end)
searchBox.FocusLost:Connect(function()
	tween(searchStroke, {Color = ACCENT, Thickness = 1, Transparency = 0.75}, TI_QUAD_MED):Play()
	tween(searchIcon, {ImageColor3 = ACCENT, ImageTransparency = 0.25}, TI_QUAD_MED):Play()
	tween(searchWrap, {BackgroundColor3 = SEARCH_BG}, TI_QUAD_MED):Play()
end)

local resultCount = Instance.new("TextLabel")
resultCount.BackgroundTransparency = 1
resultCount.Size = UDim2.fromOffset(28, 20)
resultCount.Position = UDim2.new(1, -34, 0.5, -10)
resultCount.Font = Enum.Font.GothamMedium
resultCount.TextSize = 11
resultCount.TextColor3 = SUBTEXT
resultCount.Text = ""
resultCount.TextXAlignment = Enum.TextXAlignment.Right
resultCount.ZIndex = 3
resultCount.Parent = searchWrap

-- ===== Button list =====
local list = Instance.new("ScrollingFrame")
list.Name = "ButtonList"
list.Size = UDim2.new(1, -32, 1, -148)
list.Position = UDim2.fromOffset(16, 112)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.ScrollBarImageColor3 = ACCENT
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ZIndex = 3
list.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local emptyState = Instance.new("TextLabel")
emptyState.BackgroundTransparency = 1
emptyState.Size = UDim2.new(1, 0, 0, 60)
emptyState.Font = Enum.Font.Gotham
emptyState.TextSize = 13
emptyState.TextColor3 = SUBTEXT
emptyState.Text = "No results found"
emptyState.Visible = false
emptyState.LayoutOrder = 999
emptyState.ZIndex = 3
emptyState.Parent = list

--============================================================
-- FOOTER
--============================================================
local footer = Instance.new("Frame")
footer.Size = UDim2.new(1, 0, 0, 32)
footer.Position = UDim2.new(0, 0, 1, -32)
footer.BackgroundColor3 = PANEL
footer.BorderSizePixel = 0
footer.ZIndex = 3
footer.Parent = main
Instance.new("UICorner", footer).CornerRadius = UDim.new(0, CORNER)

local footerMask = Instance.new("Frame")
footerMask.BackgroundColor3 = PANEL
footerMask.BorderSizePixel = 0
footerMask.Size = UDim2.new(1, 0, 0, CORNER)
footerMask.Position = UDim2.fromOffset(0, 0)
footerMask.ZIndex = 3
footerMask.Parent = footer

local footerLine = Instance.new("Frame")
footerLine.Size = UDim2.new(1, 0, 0, 1)
footerLine.BackgroundColor3 = STROKE
footerLine.BorderSizePixel = 0
footerLine.ZIndex = 3
footerLine.Parent = footer

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.fromOffset(6, 6)
statusDot.Position = UDim2.fromOffset(16, 13)
statusDot.BackgroundColor3 = SUCCESS
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 4
statusDot.Parent = footer
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

local statusText = Instance.new("TextLabel")
statusText.BackgroundTransparency = 1
statusText.Size = UDim2.new(1, -100, 1, 0)
statusText.Position = UDim2.fromOffset(28, 0)
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 11
statusText.TextColor3 = SUBTEXT
statusText.Text = "Ready"
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.ZIndex = 4
statusText.Parent = footer

local versionText = Instance.new("TextLabel")
versionText.BackgroundTransparency = 1
versionText.Size = UDim2.fromOffset(60, 20)
versionText.Position = UDim2.new(1, -76, 0.5, -10)
versionText.Font = Enum.Font.Gotham
versionText.TextSize = 11
versionText.TextColor3 = SUBTEXT
versionText.Text = "v1.1.0"
versionText.TextXAlignment = Enum.TextXAlignment.Right
versionText.ZIndex = 4
versionText.Parent = footer

-- ===== Toast notification system =====
local toastLayer = Instance.new("Frame")
toastLayer.Name = "Toasts"
toastLayer.BackgroundTransparency = 1
toastLayer.AnchorPoint = Vector2.new(0.5, 0)
toastLayer.Position = UDim2.new(0.5, 0, 0, 16)
toastLayer.Size = UDim2.fromOffset(280, 0)
toastLayer.AutomaticSize = Enum.AutomaticSize.Y
toastLayer.ZIndex = 1000
toastLayer.Parent = gui

local toastListLayout = Instance.new("UIListLayout")
toastListLayout.Padding = UDim.new(0, 8)
toastListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
toastListLayout.Parent = toastLayer

local TI_TOAST_IN = TweenInfo.new(0.3, Enum.EasingStyle.Back)
local TI_TOAST_FADE_IN = TweenInfo.new(0.22, Enum.EasingStyle.Quad)
local TI_TOAST_FADE_OUT = TweenInfo.new(0.25, Enum.EasingStyle.Quad)

local function notify(text, kind)
	kind = kind or "info"
	local color = kind == "success" and SUCCESS or ACCENT

	local toast = Instance.new("Frame")
	toast.Size = UDim2.new(1, 0, 0, 0)
	toast.AutomaticSize = Enum.AutomaticSize.Y
	toast.BackgroundTransparency = 1
	toast.ZIndex = 1000
	toast.Parent = toastLayer

	local scale = Instance.new("UIScale")
	scale.Scale = 0.85
	scale.Parent = toast

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundColor3 = PANEL
	card.BackgroundTransparency = 1
	card.BorderSizePixel = 0
	card.ClipsDescendants = true
	card.ZIndex = 1000
	card.Parent = toast
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

	local tStroke = Instance.new("UIStroke", card)
	tStroke.Color = STROKE
	tStroke.Thickness = 1
	tStroke.Transparency = 1

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 12)
	pad.PaddingBottom = UDim.new(0, 12)
	pad.PaddingLeft = UDim.new(0, 14)
	pad.PaddingRight = UDim.new(0, 14)
	pad.Parent = card

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 3, 1, 0)
	bar.BackgroundColor3 = color
	bar.BackgroundTransparency = 1
	bar.BorderSizePixel = 0
	bar.ZIndex = 1000
	bar.Parent = card
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(14, 0)
	label.Size = UDim2.new(1, -14, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextColor3 = TEXT
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.TextTransparency = 1
	label.ZIndex = 1000
	label.Parent = card

	tween(scale, {Scale = 1}, TI_TOAST_IN):Play()
	tween(card, {BackgroundTransparency = 0}, TI_TOAST_FADE_IN):Play()
	tween(tStroke, {Transparency = 0}, TI_TOAST_FADE_IN):Play()
	tween(bar, {BackgroundTransparency = 0}, TI_TOAST_FADE_IN):Play()
	tween(label, {TextTransparency = 0}, TI_TOAST_FADE_IN):Play()

	task.delay(2.6, function()
		local fadeScale = tween(scale, {Scale = 0.9}, TI_TOAST_FADE_OUT)
		tween(card, {BackgroundTransparency = 1}, TI_TOAST_FADE_OUT):Play()
		tween(tStroke, {Transparency = 1}, TI_TOAST_FADE_OUT):Play()
		tween(bar, {BackgroundTransparency = 1}, TI_TOAST_FADE_OUT):Play()
		tween(label, {TextTransparency = 1}, TI_TOAST_FADE_OUT):Play()
		fadeScale:Play()
		fadeScale.Completed:Wait()
		toast:Destroy()
	end)
end

-- Callback you wire up later, e.g. to require your own ModuleScripts
local function onButtonPressed(name)
	print("[AppShell] button pressed:", name)
	statusText.Text = name .. "..."
	tween(statusDot, {BackgroundColor3 = ACCENT}, TI_QUAD_MED):Play()
	notify(name .. " executed", "success")
	task.delay(1.2, function()
		statusText.Text = "Ready"
		tween(statusDot, {BackgroundColor3 = SUCCESS}, TI_QUAD_MED):Play()
	end)
end

local entries = {}

local function createButton(order, text, subtext)
	local btn = Instance.new("TextButton")
	btn.Name = text
	btn.LayoutOrder = order
	btn.Size = UDim2.new(1, 0, 0, 52)
	btn.BackgroundColor3 = BTN
	btn.AutoButtonColor = false
	btn.Text = ""
	btn.ZIndex = 3
	btn.Parent = list

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
	addListPressFeedback(btn, BTN, BTN_HOVER)

	local accentBar = Instance.new("Frame")
	accentBar.Size = UDim2.new(0, 3, 1, -14)
	accentBar.Position = UDim2.fromOffset(0, 7)
	accentBar.BackgroundColor3 = ACCENT
	accentBar.BorderSizePixel = 0
	accentBar.BackgroundTransparency = 1
	accentBar.ZIndex = 3
	accentBar.Parent = btn
	Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)
	local accentGradient = Instance.new("UIGradient", accentBar)
	accentGradient.Color = ColorSequence.new(ACCENT, ACCENT_2)
	accentGradient.Rotation = 90

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -36, 0, 20)
	label.Position = UDim2.fromOffset(14, subtext and 7 or 15)
	label.Text = text
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 14
	label.TextColor3 = TEXT
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 3
	label.Parent = btn

	if subtext then
		local sub = Instance.new("TextLabel")
		sub.BackgroundTransparency = 1
		sub.Size = UDim2.new(1, -36, 0, 16)
		sub.Position = UDim2.fromOffset(14, 28)
		sub.Text = subtext
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 11
		sub.TextColor3 = SUBTEXT
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.ZIndex = 3
		sub.Parent = btn
	end

	local chevron = Instance.new("TextLabel")
	chevron.BackgroundTransparency = 1
	chevron.Size = UDim2.fromOffset(20, 20)
	chevron.Position = UDim2.new(1, -28, 0.5, -10)
	chevron.Text = "›"
	chevron.Font = Enum.Font.GothamBold
	chevron.TextSize = 18
	chevron.TextColor3 = SUBTEXT
	chevron.ZIndex = 3
	chevron.Parent = btn

	btn.MouseEnter:Connect(function()
		tween(btn, {BackgroundColor3 = BTN_HOVER}, TI_QUINT_HOVER):Play()
		tween(accentBar, {BackgroundTransparency = 0}, TI_BACK_OUT):Play() -- slight overshoot now
		tween(chevron, {Position = UDim2.new(1, -24, 0.5, -10), TextColor3 = ACCENT}, TI_QUINT_HOVER):Play()
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, {BackgroundColor3 = BTN}, TI_QUINT_LEAVE):Play()
		tween(accentBar, {BackgroundTransparency = 1}, TI_QUINT_LEAVE):Play()
		tween(chevron, {Position = UDim2.new(1, -28, 0.5, -10), TextColor3 = SUBTEXT}, TI_QUINT_LEAVE):Play()
	end)
	btn.MouseButton1Click:Connect(function()
		onButtonPressed(text)
	end)

	table.insert(entries, {button = btn, name = text:lower(), sub = (subtext or ""):lower()})
	return btn
end

createButton(1, "Dummy Option 1", "does nothing yet")
createButton(2, "Dummy Option 2", "does nothing yet")
createButton(3, "Dummy Option 3", "does nothing yet")
createButton(4, "Dummy Option 4", "does nothing yet")
createButton(5, "Dummy Option 5", "does nothing yet")
createButton(6, "Dummy Option 6", "does nothing yet")

-- ===== Live search filtering =====
local function refreshSearch()
	local query = searchBox.Text:lower()
	local visibleCount = 0

	for _, entry in ipairs(entries) do
		local match = query == "" or entry.name:find(query, 1, true) or entry.sub:find(query, 1, true)
		entry.button.Visible = match
		if match then
			visibleCount += 1
		end
	end

	emptyState.Visible = visibleCount == 0
	resultCount.Text = query == "" and "" or (visibleCount .. "/" .. #entries)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(refreshSearch)

-- ===== Intro animation =====
windowContainer.Size = UDim2.new(WINDOW_SIZE.X.Scale, WINDOW_SIZE.X.Offset, 0, 0)
main.GroupTransparency = 1

tween(windowContainer, {Size = WINDOW_SIZE}, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)):Play()
tween(main, {GroupTransparency = 0}, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)):Play()
tween(mainStroke, {Transparency = 0}, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)):Play()
fadeShadow(true, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))

task.delay(0.55, function()
	notify("Panel loaded")
end)

return gui
