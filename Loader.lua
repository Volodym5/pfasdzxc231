--[[
	App-style UI Shell v8 — search bar, toast notifications, dummy buttons
	No remote code execution. Wire onButtonPressed() up to your own
	local ModuleScripts whenever you're ready.

	Changelog vs v4:
	- Fixed jittery/"instantly resizing" text on button press and while
	  dragging. Root cause: v4 used UIScale to shrink buttons and lift
	  the whole window, and UIScale forces Roblox to re-rasterize text
	  glyphs at each new pixel size, which reads as a stepped/instant
	  resize instead of a smooth scale. Text now never gets UIScale'd —
	  only shapes/icons (which scale cleanly) do.
	- Button press feedback is now a background-color + highlight-flash
	  tween instead of a scale tween.
	- Window drag no longer scales the window. It translates an inner
	  wrapper a few pixels up instead, which is smooth with zero text
	  artifacts.

	Changelog vs v6:
	- Removed the layered drop shadow entirely — it never looked right
	  and wasn't worth the churn. The panel now relies on the UIStroke
	  border for edge definition, no shadow.
	- Rebuilt "main" as a CanvasGroup instead of a plain Frame. A
	  CanvasGroup composites everything inside it (background, title bar,
	  buttons, text, all of it) into one image and exposes a single
	  GroupTransparency. That's what open/close now animate, so the
	  whole panel — buttons included — fades and shrinks together as one
	  piece. Previously only the panel's own background was faded, so
	  the buttons (each with their own opaque background) stayed fully
	  visible until the GUI was destroyed out from under them, which is
	  why they looked like they "disappeared last".
	- Bonus: CanvasGroup + UICorner also gives properly rounded clipping
	  (a plain Frame only clips to a rectangle), so corners are cleaner.

	Changelog vs v7:
	- Dragging now tweens to each new position instead of hard-setting it.
	  InputChanged only fires as new mouse/touch samples arrive, which
	  isn't necessarily every render frame — hard-setting Position left
	  visible gaps between samples. A short (0.08s, Linear) TweenService
	  tween per sample interpolates across those gaps, so motion stays
	  fluid. Cost is one cheap tween per mouse-move, cancelled/replaced
	  by the next — negligible.
	- Search bar is now visually distinct from the list buttons: fully
	  rounded pill shape (vs. the buttons' 10px rounded rect), a darker
	  "inset" tone instead of a near-identical raised color, and a
	  faint always-on accent-tinted outline that brightens on focus.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ===== Palette =====
local BG          = Color3.fromRGB(16, 16, 20)
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

local function tween(obj, props, dur, style, dir)
	return TweenService:Create(obj, TweenInfo.new(dur or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
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

-- introScale drives the one-time pop-in/pop-out. Unlike the button-press
-- and drag cases, this is a single, brief, large-amplitude motion rather
-- than lots of tiny repeated adjustments, so scaling the whole window
-- (including text) here doesn't read as jittery the way it did before —
-- it's the same technique virtually every polished modal/panel uses.
local introScale = Instance.new("UIScale")
introScale.Scale = 1
introScale.Parent = windowContainer

-- liftWrap is what actually gets nudged up/down for the "lift" feel while
-- dragging. Because it's a plain Position tween (no UIScale), text inside
-- never gets re-rasterized — it just translates, which is always smooth.
local liftWrap = Instance.new("Frame")
liftWrap.Name = "LiftWrap"
liftWrap.Size = UDim2.fromScale(1, 1)
liftWrap.Position = UDim2.fromOffset(0, 0)
liftWrap.BackgroundTransparency = 1
liftWrap.ZIndex = 1
liftWrap.Parent = windowContainer

-- "main" is a CanvasGroup rather than a plain Frame. A CanvasGroup
-- composites everything parented under it — background, title bar,
-- buttons, labels, all of it — into a single image, and exposes one
-- GroupTransparency for the whole thing. That's what intro/outro tween,
-- so the entire panel (buttons included) fades and shrinks together as
-- one piece instead of the background disappearing while the buttons
-- (each with their own opaque color) hang around until destroy.
-- It also clips descendants to the rounded UICorner shape properly,
-- unlike a plain Frame which only clips to a rectangle.
local main = Instance.new("CanvasGroup")
main.Name = "Main"
main.Size = UDim2.fromScale(1, 1)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.ZIndex = 2
main.Parent = liftWrap

Instance.new("UICorner", main).CornerRadius = UDim.new(0, CORNER)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = STROKE
mainStroke.Thickness = 1

-- ===== Press-feedback for ICON-only controls (safe to scale — no text) =====
local function addIconPressFeedback(button, downScale)
	downScale = downScale or 0.96
	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = button

	local pressed = false

	button.MouseButton1Down:Connect(function()
		pressed = true
		tween(scale, {Scale = downScale}, 0.06, Enum.EasingStyle.Quad):Play()
	end)

	local function release()
		if not pressed then return end
		pressed = false
		tween(scale, {Scale = 1}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
	end

	button.MouseButton1Up:Connect(release)
	button.MouseLeave:Connect(function()
		if pressed then release() end
	end)

	return scale
end

-- ===== Press-feedback for TEXT buttons (never scales — no font jitter) =====
-- Uses a background-color dip plus a quick white highlight flash instead
-- of UIScale, so labels stay pixel-crisp on press.
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
		tween(highlight, {BackgroundTransparency = 0.9}, 0.07, Enum.EasingStyle.Quad):Play()
		tween(button, {BackgroundColor3 = BTN_PRESS}, 0.07, Enum.EasingStyle.Quad):Play()
	end)

	local function release()
		if not pressed then return end
		pressed = false
		tween(highlight, {BackgroundTransparency = 1}, 0.28, Enum.EasingStyle.Quad):Play()
		tween(button, {BackgroundColor3 = hovering and hoverColor or baseColor}, 0.2, Enum.EasingStyle.Quad):Play()
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

-- ===== Close button (icon only — safe to scale) =====
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

closeBtn.MouseEnter:Connect(function()
	tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(214, 74, 74)}):Play()
	tween(xBar1, {BackgroundColor3 = Color3.new(1, 1, 1)}):Play()
	tween(xBar2, {BackgroundColor3 = Color3.new(1, 1, 1)}):Play()
	tween(xHolder, {Rotation = 90}, 0.2, Enum.EasingStyle.Back):Play()
end)
closeBtn.MouseLeave:Connect(function()
	tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(36, 36, 43)}):Play()
	tween(xBar1, {BackgroundColor3 = SUBTEXT}):Play()
	tween(xBar2, {BackgroundColor3 = SUBTEXT}):Play()
	tween(xHolder, {Rotation = 0}, 0.2, Enum.EasingStyle.Back):Play()
end)

local function closePanel()
	tween(introScale, {Scale = 0.88}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
	tween(main, {GroupTransparency = 1}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
	task.delay(0.18, function()
		gui:Destroy()
	end)
end
closeBtn.MouseButton1Click:Connect(closePanel)

-- ESC to close, since we're already handling window-level input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Escape and gui.Parent then
		closePanel()
	end
end)

-- ===== Dragging =====
-- windowContainer.Position is still what actually moves the window, but
-- instead of hard-setting it every InputChanged event (which only fires
-- as often as new mouse/touch samples arrive, not every render frame —
-- that gap is what read as "not smooth"), each new sample now tweens to
-- its goal over a very short window. TweenService interpolates the gaps
-- between samples for you, so motion stays fluid even if input events
-- come in a little unevenly. Cost is negligible — it's one cheap tween
-- per mouse-move event, cancelled and replaced by the next.
do
	local dragging = false
	local dragStart, startPos
	local dragTween

	local function beginDrag(input)
		dragging = true
		dragStart = input.Position
		startPos = windowContainer.Position

		tween(liftWrap, {Position = UDim2.fromOffset(0, -5)}, 0.18, Enum.EasingStyle.Quint):Play()
		tween(mainStroke, {Color = ACCENT}, 0.15):Play()
	end

	local function endDrag()
		if not dragging then return end
		dragging = false

		if dragTween then
			dragTween:Cancel()
			dragTween = nil
		end

		tween(liftWrap, {Position = UDim2.fromOffset(0, 0)}, 0.28, Enum.EasingStyle.Back):Play()
		tween(mainStroke, {Color = STROKE}, 0.2):Play()
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
			local goal = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)

			if dragTween then
				dragTween:Cancel()
			end
			dragTween = TweenService:Create(
				windowContainer,
				TweenInfo.new(0.08, Enum.EasingStyle.Linear),
				{Position = goal}
			)
			dragTween:Play()
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
-- Fully rounded "pill" shape (radius = half the height) instead of the
-- buttons' 10px rounded-rect — an instantly different silhouette, plus
-- a darker "inset" tone (closer to the panel background than the raised
-- button color) so it reads as a field you type into, not a button.
Instance.new("UICorner", searchWrap).CornerRadius = UDim.new(1, 0)

local searchStroke = Instance.new("UIStroke", searchWrap)
searchStroke.Color = ACCENT
searchStroke.Thickness = 1
searchStroke.Transparency = 0.75 -- always faintly visible, not just on focus

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
searchBox.ClearTextOnFocus = false
searchBox.ZIndex = 3
searchBox.Parent = searchWrap

searchBox.Focused:Connect(function()
	tween(searchStroke, {Color = ACCENT, Thickness = 1.5, Transparency = 0}, 0.15):Play()
	tween(searchIcon, {ImageColor3 = ACCENT, ImageTransparency = 0}, 0.15):Play()
	tween(searchWrap, {BackgroundColor3 = Color3.fromRGB(26, 27, 36)}, 0.15):Play()
end)
searchBox.FocusLost:Connect(function()
	tween(searchStroke, {Color = ACCENT, Thickness = 1, Transparency = 0.75}, 0.15):Play()
	tween(searchIcon, {ImageColor3 = ACCENT, ImageTransparency = 0.25}, 0.15):Play()
	tween(searchWrap, {BackgroundColor3 = SEARCH_BG}, 0.15):Play()
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
versionText.Text = "v1.0.0"
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

	tween(scale, {Scale = 1}, 0.3, Enum.EasingStyle.Back):Play()
	tween(card, {BackgroundTransparency = 0}, 0.22, Enum.EasingStyle.Quad):Play()
	tween(tStroke, {Transparency = 0}, 0.22):Play()
	tween(bar, {BackgroundTransparency = 0}, 0.22):Play()
	tween(label, {TextTransparency = 0}, 0.22):Play()

	task.delay(2.6, function()
		local fadeScale = tween(scale, {Scale = 0.9}, 0.25, Enum.EasingStyle.Quad)
		tween(card, {BackgroundTransparency = 1}, 0.25):Play()
		tween(tStroke, {Transparency = 1}, 0.25):Play()
		tween(bar, {BackgroundTransparency = 1}, 0.25):Play()
		tween(label, {TextTransparency = 1}, 0.25):Play()
		fadeScale:Play()
		fadeScale.Completed:Wait()
		toast:Destroy()
	end)
end

-- Callback you wire up later, e.g. to require your own ModuleScripts
local function onButtonPressed(name)
	print("[AppShell] button pressed:", name)
	statusText.Text = name .. "..."
	tween(statusDot, {BackgroundColor3 = ACCENT}, 0.15):Play()
	notify(name .. " executed", "success")
	task.delay(1.2, function()
		statusText.Text = "Ready"
		tween(statusDot, {BackgroundColor3 = SUCCESS}, 0.15):Play()
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
		tween(btn, {BackgroundColor3 = BTN_HOVER}, 0.18, Enum.EasingStyle.Sine):Play()
		tween(accentBar, {BackgroundTransparency = 0}, 0.18, Enum.EasingStyle.Sine):Play()
		tween(chevron, {Position = UDim2.new(1, -24, 0.5, -10), TextColor3 = ACCENT}, 0.18, Enum.EasingStyle.Sine):Play()
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, {BackgroundColor3 = BTN}, 0.18, Enum.EasingStyle.Sine):Play()
		tween(accentBar, {BackgroundTransparency = 1}, 0.18, Enum.EasingStyle.Sine):Play()
		tween(chevron, {Position = UDim2.new(1, -28, 0.5, -10), TextColor3 = SUBTEXT}, 0.18, Enum.EasingStyle.Sine):Play()
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
-- windowContainer stays at its real, full size the whole time (no
-- animating height from 0) — growing height made offset/scale-mixed
-- children (like the footer, pinned to the bottom via scale) slide and
-- pop in at uneven moments as the frame passed their thresholds, which
-- read as glitchy rather than smooth.
--
-- Instead: everything starts slightly small + fully transparent, then
-- scales up to 1 with a gentle overshoot while GroupTransparency fades
-- the entire composited panel (background, title bar, buttons, text —
-- all of it) in as one piece.
introScale.Scale = 0.86
main.GroupTransparency = 1

tween(introScale, {Scale = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
tween(main, {GroupTransparency = 0}, 0.28, Enum.EasingStyle.Sine):Play()

task.delay(0.55, function()
	notify("Panel loaded")
end)

return gui
