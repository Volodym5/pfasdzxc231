--[[
	NexusUI v1.0.0
	A modern, sleek Roblox UI library with left-side navigation,
	horizontal subtabs, and dynamic content cards.
	
	API Example:
	
	local Nexus = loadstring(game:HttpGet("..."))()
	
	local Window = Nexus:CreateWindow({
		Title = "MyApp",
		SubTitle = "v1.0",
		Icon = "rbxassetid://...",
		Size = UDim2.new(0, 760, 0, 520),
		Theme = "Dark",
	})
	
	local Tab = Window:AddTab({ Name = "Combat", Icon = "sword" })
	local SubTab = Tab:AddSubTab("Aimbot")
	
	local Card = SubTab:AddCard({ Title = "Aim Settings" })
	Card:AddToggle({ Name = "Enable Aimbot", Default = false, Callback = function(v) end })
	Card:AddSlider({ Name = "FOV", Min = 1, Max = 360, Default = 90, Callback = function(v) end })
	Card:AddDropdown({ Name = "Target Part", Options = {"Head","Torso"}, Default = "Head", Callback = function(v) end })
	Card:AddButton({ Name = "Reset", Callback = function() end })
	Card:AddKeybind({ Name = "Toggle Key", Default = Enum.KeyCode.X, Callback = function(k) end })
	Card:AddColorPicker({ Name = "Color", Default = Color3.fromRGB(255,0,0), Callback = function(c) end })
	Card:AddTextbox({ Name = "Custom Tag", Placeholder = "Enter tag...", Callback = function(v) end })
]]

-- ─────────────────────────────────────────────────────
-- SERVICES
-- ─────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local TextService      = game:GetService("TextService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()

-- ─────────────────────────────────────────────────────
-- NEXUS LIB TABLE
-- ─────────────────────────────────────────────────────
local NexusUI = {}
NexusUI.__index = NexusUI
NexusUI.Version = "1.0.0"

-- ─────────────────────────────────────────────────────
-- THEMES
-- ─────────────────────────────────────────────────────
local Themes = {
	Dark = {
		Background       = Color3.fromRGB(13, 13, 17),
		Sidebar          = Color3.fromRGB(9,  9,  13),
		SidebarBorder    = Color3.fromRGB(30, 30, 40),
		Card             = Color3.fromRGB(20, 20, 28),
		CardBorder       = Color3.fromRGB(35, 35, 50),
		Header           = Color3.fromRGB(16, 16, 22),
		Accent           = Color3.fromRGB(99, 102, 241),
		AccentHover      = Color3.fromRGB(118, 120, 255),
		AccentGlow       = Color3.fromRGB(99, 102, 241),
		Text             = Color3.fromRGB(230, 230, 240),
		TextSecondary    = Color3.fromRGB(130, 130, 155),
		TextDisabled     = Color3.fromRGB(70, 70, 90),
		TabActive        = Color3.fromRGB(99, 102, 241),
		TabInactive      = Color3.fromRGB(0, 0, 0),
		TabHover         = Color3.fromRGB(25, 25, 35),
		SubTabActive     = Color3.fromRGB(99, 102, 241),
		SubTabInactive   = Color3.fromRGB(28, 28, 40),
		ToggleOn         = Color3.fromRGB(99, 102, 241),
		ToggleOff        = Color3.fromRGB(45, 45, 60),
		SliderFill       = Color3.fromRGB(99, 102, 241),
		SliderTrack      = Color3.fromRGB(35, 35, 50),
		ButtonBg         = Color3.fromRGB(99, 102, 241),
		ButtonHover      = Color3.fromRGB(118, 120, 255),
		ButtonText       = Color3.fromRGB(255, 255, 255),
		InputBg          = Color3.fromRGB(14, 14, 20),
		InputBorder      = Color3.fromRGB(45, 45, 65),
		InputFocus       = Color3.fromRGB(99, 102, 241),
		Dropdown         = Color3.fromRGB(14, 14, 20),
		DropdownItem     = Color3.fromRGB(20, 20, 30),
		DropdownHover    = Color3.fromRGB(30, 30, 45),
		Notification     = Color3.fromRGB(20, 20, 30),
		NotifSuccess     = Color3.fromRGB(34, 197, 94),
		NotifWarning     = Color3.fromRGB(234, 179, 8),
		NotifError       = Color3.fromRGB(239, 68, 68),
		NotifInfo        = Color3.fromRGB(99, 102, 241),
		ScrollBar        = Color3.fromRGB(50, 50, 70),
		Divider          = Color3.fromRGB(30, 30, 45),
		Shadow           = Color3.fromRGB(0, 0, 0),
	},
	Light = {
		Background       = Color3.fromRGB(245, 245, 250),
		Sidebar          = Color3.fromRGB(235, 235, 245),
		SidebarBorder    = Color3.fromRGB(210, 210, 225),
		Card             = Color3.fromRGB(255, 255, 255),
		CardBorder       = Color3.fromRGB(220, 220, 235),
		Header           = Color3.fromRGB(240, 240, 248),
		Accent           = Color3.fromRGB(99, 102, 241),
		AccentHover      = Color3.fromRGB(79, 82, 221),
		AccentGlow       = Color3.fromRGB(99, 102, 241),
		Text             = Color3.fromRGB(20, 20, 30),
		TextSecondary    = Color3.fromRGB(100, 100, 130),
		TextDisabled     = Color3.fromRGB(170, 170, 195),
		TabActive        = Color3.fromRGB(99, 102, 241),
		TabInactive      = Color3.fromRGB(0, 0, 0),
		TabHover         = Color3.fromRGB(225, 225, 240),
		SubTabActive     = Color3.fromRGB(99, 102, 241),
		SubTabInactive   = Color3.fromRGB(228, 228, 242),
		ToggleOn         = Color3.fromRGB(99, 102, 241),
		ToggleOff        = Color3.fromRGB(190, 190, 210),
		SliderFill       = Color3.fromRGB(99, 102, 241),
		SliderTrack      = Color3.fromRGB(210, 210, 230),
		ButtonBg         = Color3.fromRGB(99, 102, 241),
		ButtonHover      = Color3.fromRGB(79, 82, 221),
		ButtonText       = Color3.fromRGB(255, 255, 255),
		InputBg          = Color3.fromRGB(255, 255, 255),
		InputBorder      = Color3.fromRGB(200, 200, 220),
		InputFocus       = Color3.fromRGB(99, 102, 241),
		Dropdown         = Color3.fromRGB(255, 255, 255),
		DropdownItem     = Color3.fromRGB(248, 248, 255),
		DropdownHover    = Color3.fromRGB(235, 235, 250),
		Notification     = Color3.fromRGB(255, 255, 255),
		NotifSuccess     = Color3.fromRGB(34, 197, 94),
		NotifWarning     = Color3.fromRGB(234, 179, 8),
		NotifError       = Color3.fromRGB(239, 68, 68),
		NotifInfo        = Color3.fromRGB(99, 102, 241),
		ScrollBar        = Color3.fromRGB(180, 180, 210),
		Divider          = Color3.fromRGB(215, 215, 230),
		Shadow           = Color3.fromRGB(180, 180, 210),
	},
}

-- ─────────────────────────────────────────────────────
-- UTILITY FUNCTIONS
-- ─────────────────────────────────────────────────────
local Util = {}

function Util.Tween(obj, props, duration, style, dir)
	local info = TweenInfo.new(
		duration or 0.25,
		style  or Enum.EasingStyle.Quint,
		dir    or Enum.EasingDirection.Out
	)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

function Util.Create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	for _, child in pairs(children or {}) do
		if child then child.Parent = inst end
	end
	return inst
end

function Util.ApplyCorner(parent, radius)
	return Util.Create("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

function Util.ApplyPadding(parent, top, bottom, left, right)
	return Util.Create("UIPadding", {
		PaddingTop    = UDim.new(0, top    or 8),
		PaddingBottom = UDim.new(0, bottom or 8),
		PaddingLeft   = UDim.new(0, left   or 8),
		PaddingRight  = UDim.new(0, right  or 8),
		Parent = parent,
	})
end

function Util.ApplyStroke(parent, color, thickness, trans)
	return Util.Create("UIStroke", {
		Color       = color,
		Thickness   = thickness or 1,
		Transparency = trans or 0,
		Parent      = parent,
	})
end

function Util.MakeShadow(parent, size, trans)
	local s = Util.Create("ImageLabel", {
		Name = "Shadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 4),
		Size = UDim2.new(1, size or 20, 1, size or 20),
		ZIndex = parent.ZIndex - 1,
		Image = "rbxassetid://6015897843",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = trans or 0.65,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		Parent = parent,
	})
	return s
end

function Util.Ripple(button, theme)
	local ripple = Util.Create("Frame", {
		Name = "Ripple",
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		ZIndex = button.ZIndex + 5,
		Parent = button,
	})
	Util.ApplyCorner(ripple, 100)
	local mx = Mouse.X - button.AbsolutePosition.X
	local my = Mouse.Y - button.AbsolutePosition.Y
	ripple.Position = UDim2.new(0, mx - 1, 0, my - 1)
	ripple.Size = UDim2.new(0, 2, 0, 2)
	Util.Tween(ripple, {
		Size = UDim2.new(0, button.AbsoluteSize.X * 2.5, 0, button.AbsoluteSize.X * 2.5),
		Position = UDim2.new(0, mx - button.AbsoluteSize.X * 1.25, 0, my - button.AbsoluteSize.X * 1.25),
		BackgroundTransparency = 1,
	}, 0.5, Enum.EasingStyle.Quart)
	task.delay(0.55, function()
		ripple:Destroy()
	end)
end

function Util.Dragify(frame, handle)
	handle = handle or frame
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

-- ─────────────────────────────────────────────────────
-- ICON SYSTEM (text-based unicode icons)
-- ─────────────────────────────────────────────────────
local Icons = {
	home       = "⌂",
	combat     = "⚔",
	player     = "☻",
	esp        = "◉",
	settings   = "⚙",
	misc       = "✦",
	movement   = "↑",
	weapon     = "⚡",
	visual     = "👁",
	world      = "◈",
	speed      = "»",
	fly        = "△",
	aim        = "◎",
	script     = "{}",
	info       = "ℹ",
	close      = "✕",
	minimize   = "—",
	search     = "⌕",
	star       = "★",
	lock       = "🔒",
	notification = "🔔",
	default    = "▸",
}

function NexusUI.GetIcon(name)
	return Icons[name:lower()] or Icons.default
end

-- ─────────────────────────────────────────────────────
-- NOTIFICATION SYSTEM
-- ─────────────────────────────────────────────────────
local NotificationController = {}
NotificationController.__index = NotificationController

function NotificationController.new(screenGui, theme)
	local self = setmetatable({}, NotificationController)
	self.Theme = theme
	self.Container = Util.Create("Frame", {
		Name = "NotifContainer",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.new(0, 320, 1, -18),
		ZIndex = 9999,
		Parent = screenGui,
	})
	Util.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = self.Container,
	})
	return self
end

function NotificationController:Notify(opts)
	local T       = self.Theme
	local title   = opts.Title or "Notification"
	local desc    = opts.Description or ""
	local kind    = opts.Type or "Info"   -- Info | Success | Warning | Error
	local dur     = opts.Duration or 4

	local accentColor = ({
		Info    = T.NotifInfo,
		Success = T.NotifSuccess,
		Warning = T.NotifWarning,
		Error   = T.NotifError,
	})[kind] or T.NotifInfo

	local notif = Util.Create("Frame", {
		Name = "Notification",
		BackgroundColor3 = T.Notification,
		Size = UDim2.new(1, 0, 0, 70),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 9999,
		Parent = self.Container,
	})
	Util.ApplyCorner(notif, 10)
	Util.ApplyStroke(notif, T.CardBorder, 1, 0.5)
	Util.MakeShadow(notif, 16, 0.7)

	-- Left accent bar
	Util.Create("Frame", {
		Name = "Accent",
		BackgroundColor3 = accentColor,
		Size = UDim2.new(0, 3, 1, 0),
		BorderSizePixel = 0,
		ZIndex = 10000,
		Parent = notif,
	})
	Util.ApplyCorner(notif:FindFirstChild("Accent"), 3)

	-- Title
	Util.Create("TextLabel", {
		Name = "Title",
		Text = title,
		TextColor3 = T.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 12),
		Size = UDim2.new(1, -30, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 10000,
		Parent = notif,
	})

	-- Description
	Util.Create("TextLabel", {
		Name = "Desc",
		Text = desc,
		TextColor3 = T.TextSecondary,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 32),
		Size = UDim2.new(1, -30, 0, 28),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		ZIndex = 10000,
		Parent = notif,
	})

	-- Progress bar
	local pbar = Util.Create("Frame", {
		Name = "Progress",
		BackgroundColor3 = accentColor,
		Position = UDim2.new(0, 0, 1, -2),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		ZIndex = 10001,
		Parent = notif,
	})

	-- Slide in
	notif.Position = UDim2.new(1, 20, 0, 0)
	Util.Tween(notif, { BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0) }, 0.35)

	-- Progress shrink
	Util.Tween(pbar, { Size = UDim2.new(0, 0, 0, 2) }, dur, Enum.EasingStyle.Linear)

	-- Slide out
	task.delay(dur, function()
		Util.Tween(notif, { BackgroundTransparency = 1, Position = UDim2.new(1, 20, 0, 0) }, 0.35)
		task.delay(0.4, function()
			notif:Destroy()
		end)
	end)
end

-- ─────────────────────────────────────────────────────
-- CONTROL BUILDERS
-- ─────────────────────────────────────────────────────
local Controls = {}

-- TOGGLE
function Controls.AddToggle(parent, opts, T, zBase)
	opts = opts or {}
	local name     = opts.Name or "Toggle"
	local default  = opts.Default or false
	local callback = opts.Callback or function() end
	local desc     = opts.Description
	local value    = default

	local h = desc and 52 or 38
	local row = Util.Create("Frame", {
		Name = "Toggle_"..name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, h),
		LayoutOrder = #parent:GetChildren(),
		ZIndex = zBase or 10,
		Parent = parent,
	})

	Util.Create("TextLabel", {
		Text = name,
		TextColor3 = T.Text,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -52, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = (zBase or 10) + 1,
		Parent = row,
	})

	if desc then
		Util.Create("TextLabel", {
			Text = desc,
			TextColor3 = T.TextSecondary,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 22),
			Size = UDim2.new(1, -52, 0, 16),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			ZIndex = (zBase or 10) + 1,
			Parent = row,
		})
	end

	-- Track
	local track = Util.Create("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0, h/2 - 1),
		Size = UDim2.new(0, 40, 0, 20),
		BackgroundColor3 = value and T.ToggleOn or T.ToggleOff,
		BorderSizePixel = 0,
		ZIndex = (zBase or 10) + 1,
		Parent = row,
	})
	Util.ApplyCorner(track, 10)

	-- Knob
	local knob = Util.Create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, value and 22 or 2, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BorderSizePixel = 0,
		ZIndex = (zBase or 10) + 2,
		Parent = track,
	})
	Util.ApplyCorner(knob, 8)

	local function setState(v, animate)
		value = v
		local dur = animate and 0.2 or 0
		Util.Tween(track, { BackgroundColor3 = v and T.ToggleOn or T.ToggleOff }, dur)
		Util.Tween(knob,  { Position = UDim2.new(0, v and 22 or 2, 0.5, 0) }, dur)
		callback(v)
	end

	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			setState(not value, true)
			Util.Ripple(track, T)
		end
	end)
	track.MouseEnter:Connect(function()
		Util.Tween(track, { BackgroundColor3 = value and T.AccentHover or Color3.fromRGB(60,60,80) }, 0.15)
	end)
	track.MouseLeave:Connect(function()
		Util.Tween(track, { BackgroundColor3 = value and T.ToggleOn or T.ToggleOff }, 0.15)
	end)

	local ctrl = { Row = row }
	function ctrl:Set(v) setState(v, true) end
	function ctrl:Get() return value end
	return ctrl
end

-- BUTTON
function Controls.AddButton(parent, opts, T, zBase)
	opts = opts or {}
	local name     = opts.Name or "Button"
	local callback = opts.Callback or function() end
	local color    = opts.Color

	local btn = Util.Create("TextButton", {
		Name = "Button_"..name,
		Text = name,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = T.ButtonText,
		BackgroundColor3 = color or T.ButtonBg,
		Size = UDim2.new(1, 0, 0, 34),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		ZIndex = zBase or 10,
		LayoutOrder = #parent:GetChildren(),
		Parent = parent,
	})
	Util.ApplyCorner(btn, 8)
	Util.MakeShadow(btn, 10, 0.75)

	btn.MouseEnter:Connect(function()
		Util.Tween(btn, { BackgroundColor3 = color and color or T.ButtonHover }, 0.15)
	end)
	btn.MouseLeave:Connect(function()
		Util.Tween(btn, { BackgroundColor3 = color or T.ButtonBg }, 0.15)
	end)
	btn.MouseButton1Click:Connect(function()
		Util.Ripple(btn, T)
		callback()
	end)

	return { Button = btn }
end

-- SLIDER
function Controls.AddSlider(parent, opts, T, zBase)
	opts = opts or {}
	local name     = opts.Name or "Slider"
	local min      = opts.Min or 0
	local max      = opts.Max or 100
	local default  = math.clamp(opts.Default or min, min, max)
	local suffix   = opts.Suffix or ""
	local callback = opts.Callback or function() end
	local value    = default

	local row = Util.Create("Frame", {
		Name = "Slider_"..name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 52),
		LayoutOrder = #parent:GetChildren(),
		ZIndex = zBase or 10,
		Parent = parent,
	})

	-- Header row
	Util.Create("TextLabel", {
		Text = name,
		TextColor3 = T.Text,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0.7, 0, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = (zBase or 10) + 1,
		Parent = row,
	})

	local valLabel = Util.Create("TextLabel", {
		Text = tostring(value)..suffix,
		TextColor3 = T.Accent,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.7, 0, 0, 0),
		Size = UDim2.new(0.3, 0, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = (zBase or 10) + 1,
		Parent = row,
	})

	-- Track
	local track = Util.Create("Frame", {
		Name = "Track",
		BackgroundColor3 = T.SliderTrack,
		Position = UDim2.new(0, 0, 0, 28),
		Size = UDim2.new(1, 0, 0, 6),
		BorderSizePixel = 0,
		ZIndex = (zBase or 10) + 1,
		Parent = row,
	})
	Util.ApplyCorner(track, 3)

	-- Fill
	local fill = Util.Create("Frame", {
		Name = "Fill",
		BackgroundColor3 = T.SliderFill,
		Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
		BorderSizePixel = 0,
		ZIndex = (zBase or 10) + 2,
		Parent = track,
	})
	Util.ApplyCorner(fill, 3)

	-- Thumb
	local thumb = Util.Create("Frame", {
		Name = "Thumb",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BorderSizePixel = 0,
		ZIndex = (zBase or 10) + 3,
		Parent = track,
	})
	Util.ApplyCorner(thumb, 7)
	Util.Create("UIStroke", { Color = T.Accent, Thickness = 2, Parent = thumb })

	local sliding = false

	local function updateSlider(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		value = math.floor(min + rel * (max - min) + 0.5)
		valLabel.Text = tostring(value)..suffix
		Util.Tween(fill,  { Size = UDim2.new(rel, 0, 1, 0) }, 0.05)
		Util.Tween(thumb, { Position = UDim2.new(rel, 0, 0.5, 0) }, 0.05)
		callback(value)
	end

	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = true
			updateSlider(i.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(i.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = false
		end
	end)

	local ctrl = { Row = row }
	function ctrl:Set(v)
		value = math.clamp(v, min, max)
		local rel = (value - min) / (max - min)
		valLabel.Text = tostring(value)..suffix
		fill.Size = UDim2.new(rel, 0, 1, 0)
		thumb.Position = UDim2.new(rel, 0, 0.5, 0)
		callback(value)
	end
	function ctrl:Get() return value end
	return ctrl
end

-- DROPDOWN
function Controls.AddDropdown(parent, opts, T, zBase)
	opts = opts or {}
	local name     = opts.Name or "Dropdown"
	local options  = opts.Options or {}
	local default  = opts.Default or options[1]
	local callback = opts.Callback or function() end
	local multi    = opts.Multi or false
	local selected = multi and {} or default

	if multi and default then
		if type(default) == "table" then selected = default
		else selected = {default} end
	end

	local isOpen   = false

	local wrapper = Util.Create("Frame", {
		Name = "Dropdown_"..name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 58),
		LayoutOrder = #parent:GetChildren(),
		ClipsDescendants = false,
		ZIndex = zBase or 10,
		Parent = parent,
	})

	Util.Create("TextLabel", {
		Text = name,
		TextColor3 = T.Text,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = (zBase or 10) + 1,
		Parent = wrapper,
	})

	local box = Util.Create("Frame", {
		Name = "Box",
		BackgroundColor3 = T.InputBg,
		Position = UDim2.new(0, 0, 0, 22),
		Size = UDim2.new(1, 0, 0, 32),
		BorderSizePixel = 0,
		ZIndex = (zBase or 10) + 1,
		Parent = wrapper,
	})
	Util.ApplyCorner(box, 8)
	Util.ApplyStroke(box, T.InputBorder, 1)

	local function getDisplayText()
		if multi then
			if #selected == 0 then return "Select..." end
			return table.concat(selected, ", ")
		else
			return selected or "Select..."
		end
	end

	local selectedLabel = Util.Create("TextLabel", {
		Text = getDisplayText(),
		TextColor3 = T.TextSecondary,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -36, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = (zBase or 10) + 2,
		Parent = box,
	})

	local arrow = Util.Create("TextLabel", {
		Text = "▾",
		TextColor3 = T.TextSecondary,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 20, 0, 20),
		ZIndex = (zBase or 10) + 2,
		Parent = box,
	})

	-- Dropdown list (rendered below)
	local listFrame = Util.Create("Frame", {
		Name = "List",
		BackgroundColor3 = T.Dropdown,
		Position = UDim2.new(0, 0, 1, 4),
		Size = UDim2.new(1, 0, 0, 0),
		ClipsDescendants = true,
		BorderSizePixel = 0,
		ZIndex = (zBase or 10) + 20,
		Visible = false,
		Parent = box,
	})
	Util.ApplyCorner(listFrame, 8)
	Util.ApplyStroke(listFrame, T.InputBorder, 1)

	local listLayout = Util.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = listFrame,
	})
	Util.ApplyPadding(listFrame, 4, 4, 4, 4)

	local function buildList()
		for _, ch in pairs(listFrame:GetChildren()) do
			if ch:IsA("TextButton") then ch:Destroy() end
		end
		for i, opt in ipairs(options) do
			local isSelected = multi and table.find(selected, opt) or (selected == opt)
			local item = Util.Create("TextButton", {
				Name = "Item_"..opt,
				Text = (isSelected and "✓  " or "    ")..opt,
				TextColor3 = isSelected and T.Accent or T.Text,
				Font = Enum.Font.Gotham,
				TextSize = 12,
				BackgroundColor3 = isSelected and T.DropdownHover or T.DropdownItem,
				Size = UDim2.new(1, 0, 0, 28),
				BorderSizePixel = 0,
				AutoButtonColor = false,
				LayoutOrder = i,
				ZIndex = (zBase or 10) + 21,
				Parent = listFrame,
			})
			Util.ApplyCorner(item, 6)

			item.MouseEnter:Connect(function()
				if not (multi and table.find(selected, opt)) and not (selected == opt) then
					Util.Tween(item, { BackgroundColor3 = T.DropdownHover }, 0.1)
				end
			end)
			item.MouseLeave:Connect(function()
				local sel = multi and table.find(selected, opt) or (selected == opt)
				Util.Tween(item, { BackgroundColor3 = sel and T.DropdownHover or T.DropdownItem }, 0.1)
			end)
			item.MouseButton1Click:Connect(function()
				if multi then
					local idx = table.find(selected, opt)
					if idx then table.remove(selected, idx)
					else table.insert(selected, opt) end
					callback(selected)
				else
					selected = opt
					callback(opt)
					-- close
					isOpen = false
					Util.Tween(listFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
					Util.Tween(arrow, { Rotation = 0 }, 0.2)
					task.delay(0.22, function() listFrame.Visible = false end)
				end
				selectedLabel.Text = getDisplayText()
				buildList()
			end)
		end
		-- resize list
		local count = math.min(#options, 6)
		local targetH = count * 30 + 8
		listLayout:ApplyLayout()
		Util.Tween(listFrame, { Size = UDim2.new(1, 0, 0, targetH) }, 0.2)
	end

	box.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			isOpen = not isOpen
			if isOpen then
				listFrame.Visible = true
				listFrame.Size = UDim2.new(1, 0, 0, 0)
				buildList()
				Util.Tween(arrow, { Rotation = 180 }, 0.2)
				Util.Tween(box, { BackgroundColor3 = T.InputBg }, 0.1)
				local stroke = box:FindFirstChildOfClass("UIStroke")
				if stroke then Util.Tween(stroke, { Color = T.InputFocus }, 0.15) end
			else
				Util.Tween(listFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
				Util.Tween(arrow, { Rotation = 0 }, 0.2)
				local stroke = box:FindFirstChildOfClass("UIStroke")
				if stroke then Util.Tween(stroke, { Color = T.InputBorder }, 0.15) end
				task.delay(0.22, function() listFrame.Visible = false end)
			end
		end
	end)

	local ctrl = { Wrapper = wrapper }
	function ctrl:Set(v)
		if multi then selected = type(v) == "table" and v or {v}
		else selected = v end
		selectedLabel.Text = getDisplayText()
		callback(selected)
	end
	function ctrl:Get() return selected end
	function ctrl:SetOptions(newOpts)
		options = newOpts
		if isOpen then buildList() end
	end
	return ctrl
end

-- TEXTBOX
function Controls.AddTextbox(parent, opts, T, zBase)
	opts = opts or {}
	local name        = opts.Name or "Textbox"
	local placeholder = opts.Placeholder or ""
	local default     = opts.Default or ""
	local callback    = opts.Callback or function() end
	local numeric     = opts.Numeric or false

	local row = Util.Create("Frame", {
		Name = "Textbox_"..name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 56),
		LayoutOrder = #parent:GetChildren(),
		ZIndex = zBase or 10,
		Parent = parent,
	})

	Util.Create("TextLabel", {
		Text = name,
		TextColor3 = T.Text,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = (zBase or 10) + 1,
		Parent = row,
	})

	local box = Util.Create("Frame", {
		BackgroundColor3 = T.InputBg,
		Position = UDim2.new(0, 0, 0, 22),
		Size = UDim2.new(1, 0, 0, 30),
		BorderSizePixel = 0,
		ZIndex = (zBase or 10) + 1,
		Parent = row,
	})
	Util.ApplyCorner(box, 8)
	local stroke = Util.ApplyStroke(box, T.InputBorder, 1)

	local input = Util.Create("TextBox", {
		Text = default,
		PlaceholderText = placeholder,
		PlaceholderColor3 = T.TextDisabled,
		TextColor3 = T.Text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -20, 1, 0),
		ZIndex = (zBase or 10) + 2,
		Parent = box,
	})

	input.Focused:Connect(function()
		Util.Tween(stroke, { Color = T.InputFocus }, 0.15)
	end)
	input.FocusLost:Connect(function(enter)
		Util.Tween(stroke, { Color = T.InputBorder }, 0.15)
		if enter then callback(input.Text) end
	end)

	local ctrl = { Row = row }
	function ctrl:Set(v) input.Text = tostring(v) end
	function ctrl:Get() return input.Text end
	return ctrl
end

-- KEYBIND
function Controls.AddKeybind(parent, opts, T, zBase)
	opts = opts or {}
	local name     = opts.Name or "Keybind"
	local default  = opts.Default or Enum.KeyCode.Unknown
	local callback = opts.Callback or function() end
	local binding  = default
	local listening = false

	local row = Util.Create("Frame", {
		Name = "Keybind_"..name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 36),
		LayoutOrder = #parent:GetChildren(),
		ZIndex = zBase or 10,
		Parent = parent,
	})

	Util.Create("TextLabel", {
		Text = name,
		TextColor3 = T.Text,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 8),
		Size = UDim2.new(1, -90, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = (zBase or 10) + 1,
		Parent = row,
	})

	local keybtn = Util.Create("TextButton", {
		Name = "KeyBtn",
		Text = binding.Name,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = T.Accent,
		BackgroundColor3 = T.InputBg,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 82, 0, 26),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		ZIndex = (zBase or 10) + 1,
		Parent = row,
	})
	Util.ApplyCorner(keybtn, 6)
	Util.ApplyStroke(keybtn, T.InputBorder, 1)

	keybtn.MouseButton1Click:Connect(function()
		listening = true
		keybtn.Text = "Press key..."
		keybtn.TextColor3 = T.TextSecondary
		Util.Tween(keybtn:FindFirstChildOfClass("UIStroke"), { Color = T.Accent }, 0.15)
	end)

	UserInputService.InputBegan:Connect(function(inp, gp)
		if listening and not gp and inp.UserInputType == Enum.UserInputType.Keyboard then
			listening = false
			binding = inp.KeyCode
			keybtn.Text = binding.Name
			keybtn.TextColor3 = T.Accent
			Util.Tween(keybtn:FindFirstChildOfClass("UIStroke"), { Color = T.InputBorder }, 0.15)
			callback(binding)
		end
	end)

	local ctrl = { Row = row }
	function ctrl:Get() return binding end
	function ctrl:Set(k) binding = k; keybtn.Text = k.Name end
	return ctrl
end

-- COLOR PICKER
function Controls.AddColorPicker(parent, opts, T, zBase)
	opts = opts or {}
	local name     = opts.Name or "Color"
	local default  = opts.Default or Color3.fromRGB(255,255,255)
	local callback = opts.Callback or function() end
	local color    = default
	local isOpen   = false

	local row = Util.Create("Frame", {
		Name = "ColorPicker_"..name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 38),
		LayoutOrder = #parent:GetChildren(),
		ZIndex = zBase or 10,
		Parent = parent,
	})

	Util.Create("TextLabel", {
		Text = name,
		TextColor3 = T.Text,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 9),
		Size = UDim2.new(1, -50, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = (zBase or 10) + 1,
		Parent = row,
	})

	local swatch = Util.Create("TextButton", {
		Name = "Swatch",
		Text = "",
		BackgroundColor3 = color,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 40, 0, 22),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		ZIndex = (zBase or 10) + 1,
		Parent = row,
	})
	Util.ApplyCorner(swatch, 6)
	Util.ApplyStroke(swatch, T.InputBorder, 1)

	-- Simple RGB sliders popup
	local picker = Util.Create("Frame", {
		Name = "Picker",
		BackgroundColor3 = T.Dropdown,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 4, 1, 4),
		Size = UDim2.new(0, 200, 0, 0),
		ClipsDescendants = true,
		BorderSizePixel = 0,
		ZIndex = (zBase or 10) + 30,
		Visible = false,
		Parent = row,
	})
	Util.ApplyCorner(picker, 10)
	Util.ApplyStroke(picker, T.InputBorder, 1)
	Util.ApplyPadding(picker, 10, 10, 10, 10)

	local pickerLayout = Util.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = picker,
	})

	local r, g, b = color.R * 255, color.G * 255, color.B * 255

	local function makeColorSlider(label, startVal, onChanged)
		local sf = Util.Create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 36),
			ZIndex = (zBase or 10) + 31,
			Parent = picker,
		})
		Util.Create("TextLabel", {
			Text = label,
			TextColor3 = T.TextSecondary,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			BackgroundTransparency = 1,
			Position = UDim2.new(0,0,0,0),
			Size = UDim2.new(0.6,0,0,16),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = (zBase or 10) + 32,
			Parent = sf,
		})
		local vl = Util.Create("TextLabel", {
			Text = tostring(math.floor(startVal)),
			TextColor3 = T.Accent,
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			BackgroundTransparency = 1,
			Position = UDim2.new(0.6,0,0,0),
			Size = UDim2.new(0.4,0,0,16),
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = (zBase or 10) + 32,
			Parent = sf,
		})
		local trk = Util.Create("Frame", {
			BackgroundColor3 = T.SliderTrack,
			Position = UDim2.new(0,0,0,20),
			Size = UDim2.new(1,0,0,5),
			BorderSizePixel = 0,
			ZIndex = (zBase or 10) + 32,
			Parent = sf,
		})
		Util.ApplyCorner(trk, 3)
		local fl = Util.Create("Frame", {
			BackgroundColor3 = T.Accent,
			Size = UDim2.new(startVal/255,0,1,0),
			BorderSizePixel = 0,
			ZIndex = (zBase or 10) + 33,
			Parent = trk,
		})
		Util.ApplyCorner(fl, 3)
		local sliding2 = false
		trk.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				sliding2 = true
				local rel = math.clamp((i.Position.X - trk.AbsolutePosition.X)/trk.AbsoluteSize.X,0,1)
				local v = math.floor(rel*255)
				vl.Text = tostring(v)
				fl.Size = UDim2.new(rel,0,1,0)
				onChanged(v)
			end
		end)
		UserInputService.InputChanged:Connect(function(i)
			if sliding2 and i.UserInputType == Enum.UserInputType.MouseMovement then
				local rel = math.clamp((i.Position.X - trk.AbsolutePosition.X)/trk.AbsoluteSize.X,0,1)
				local v = math.floor(rel*255)
				vl.Text = tostring(v)
				fl.Size = UDim2.new(rel,0,1,0)
				onChanged(v)
			end
		end)
		UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding2 = false end
		end)
	end

	makeColorSlider("R", r, function(v) r = v; color = Color3.fromRGB(r,g,b); swatch.BackgroundColor3 = color; callback(color) end)
	makeColorSlider("G", g, function(v) g = v; color = Color3.fromRGB(r,g,b); swatch.BackgroundColor3 = color; callback(color) end)
	makeColorSlider("B", b, function(v) b = v; color = Color3.fromRGB(r,g,b); swatch.BackgroundColor3 = color; callback(color) end)

	local PICKER_H = 3 * 36 + 2 * 6 + 20  -- items + gaps + padding

	swatch.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		if isOpen then
			picker.Visible = true
			picker.Size = UDim2.new(0, 200, 0, 0)
			Util.Tween(picker, { Size = UDim2.new(0, 200, 0, PICKER_H) }, 0.2)
		else
			Util.Tween(picker, { Size = UDim2.new(0, 200, 0, 0) }, 0.2)
			task.delay(0.22, function() picker.Visible = false end)
		end
	end)

	local ctrl = { Row = row }
	function ctrl:Set(c) color = c; swatch.BackgroundColor3 = c; r,g,b = c.R*255,c.G*255,c.B*255; callback(c) end
	function ctrl:Get() return color end
	return ctrl
end

-- LABEL
function Controls.AddLabel(parent, opts, T, zBase)
	opts = opts or {}
	local text = opts.Text or opts.Name or ""
	local label = Util.Create("TextLabel", {
		Name = "Label",
		Text = text,
		TextColor3 = T.TextSecondary,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		LayoutOrder = #parent:GetChildren(),
		ZIndex = zBase or 10,
		Parent = parent,
	})
	local ctrl = { Label = label }
	function ctrl:Set(t) label.Text = t end
	function ctrl:Get() return label.Text end
	return ctrl
end

-- DIVIDER
function Controls.AddDivider(parent, T, zBase)
	local div = Util.Create("Frame", {
		Name = "Divider",
		BackgroundColor3 = T.Divider,
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		LayoutOrder = #parent:GetChildren(),
		ZIndex = zBase or 10,
		Parent = parent,
	})
	return { Frame = div }
end

-- SEARCH INPUT
function Controls.AddSearch(parent, opts, T, zBase)
	opts = opts or {}
	local callback = opts.Callback or function() end

	local row = Util.Create("Frame", {
		Name = "Search",
		BackgroundColor3 = T.InputBg,
		Size = UDim2.new(1, 0, 0, 32),
		BorderSizePixel = 0,
		LayoutOrder = #parent:GetChildren(),
		ZIndex = zBase or 10,
		Parent = parent,
	})
	Util.ApplyCorner(row, 8)
	local stroke = Util.ApplyStroke(row, T.InputBorder, 1)

	Util.Create("TextLabel", {
		Text = Icons.search,
		TextColor3 = T.TextSecondary,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(0, 20, 1, 0),
		ZIndex = (zBase or 10) + 1,
		Parent = row,
	})

	local input = Util.Create("TextBox", {
		PlaceholderText = opts.Placeholder or "Search...",
		PlaceholderColor3 = T.TextDisabled,
		Text = "",
		TextColor3 = T.Text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Position = UDim2.new(0, 30, 0, 0),
		Size = UDim2.new(1, -38, 1, 0),
		ZIndex = (zBase or 10) + 1,
		Parent = row,
	})

	input.Focused:Connect(function() Util.Tween(stroke, { Color = T.InputFocus }, 0.15) end)
	input.FocusLost:Connect(function() Util.Tween(stroke, { Color = T.InputBorder }, 0.15) end)
	input:GetPropertyChangedSignal("Text"):Connect(function() callback(input.Text) end)

	return { Row = row, Input = input }
end

-- ─────────────────────────────────────────────────────
-- CARD CLASS
-- ─────────────────────────────────────────────────────
local Card = {}
Card.__index = Card

function Card.new(parent, opts, T, zBase)
	local self = setmetatable({}, Card)
	opts = opts or {}
	self.T = T
	self.Z = zBase or 10

	local cardFrame = Util.Create("Frame", {
		Name = "Card_"..(opts.Title or "Card"),
		BackgroundColor3 = T.Card,
		Size = UDim2.new(1, 0, 0, 40),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = opts.LayoutOrder or 0,
		ZIndex = zBase or 10,
		Parent = parent,
	})
	Util.ApplyCorner(cardFrame, 10)
	Util.ApplyStroke(cardFrame, T.CardBorder, 1, 0.5)

	local inner = Util.Create("Frame", {
		Name = "Inner",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = (zBase or 10) + 1,
		Parent = cardFrame,
	})
	Util.ApplyPadding(inner, 12, 14, 14, 14)

	local layout = Util.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = inner,
	})

	-- Title header
	if opts.Title then
		local titleRow = Util.Create("Frame", {
			Name = "TitleRow",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 22),
			LayoutOrder = -10,
			ZIndex = (zBase or 10) + 2,
			Parent = inner,
		})
		Util.Create("TextLabel", {
			Text = opts.Title,
			TextColor3 = T.Text,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = (zBase or 10) + 3,
			Parent = titleRow,
		})

		-- Accent top-left corner marker
		Util.Create("Frame", {
			Name = "TitleAccent",
			BackgroundColor3 = T.Accent,
			Position = UDim2.new(0, -14, 0, 4),
			Size = UDim2.new(0, 3, 0, 14),
			BorderSizePixel = 0,
			ZIndex = (zBase or 10) + 3,
			Parent = titleRow,
		})

		-- Divider under title
		if opts.Description or true then
			Util.Create("Frame", {
				Name = "TitleDiv",
				BackgroundColor3 = T.Divider,
				Size = UDim2.new(1, 0, 0, 1),
				BorderSizePixel = 0,
				LayoutOrder = -9,
				ZIndex = (zBase or 10) + 2,
				Parent = inner,
			})
		end
	end

	if opts.Description then
		Util.Create("TextLabel", {
			Text = opts.Description,
			TextColor3 = T.TextSecondary,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 14),
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = -8,
			ZIndex = (zBase or 10) + 2,
			Parent = inner,
		})
	end

	self.Frame   = cardFrame
	self.Inner   = inner
	self.Layout  = layout

	return self
end

function Card:AddToggle(opts)      return Controls.AddToggle(self.Inner, opts, self.T, self.Z + 2) end
function Card:AddButton(opts)      return Controls.AddButton(self.Inner, opts, self.T, self.Z + 2) end
function Card:AddSlider(opts)      return Controls.AddSlider(self.Inner, opts, self.T, self.Z + 2) end
function Card:AddDropdown(opts)    return Controls.AddDropdown(self.Inner, opts, self.T, self.Z + 2) end
function Card:AddTextbox(opts)     return Controls.AddTextbox(self.Inner, opts, self.T, self.Z + 2) end
function Card:AddKeybind(opts)     return Controls.AddKeybind(self.Inner, opts, self.T, self.Z + 2) end
function Card:AddColorPicker(opts) return Controls.AddColorPicker(self.Inner, opts, self.T, self.Z + 2) end
function Card:AddLabel(opts)       return Controls.AddLabel(self.Inner, opts, self.T, self.Z + 2) end
function Card:AddDivider()         return Controls.AddDivider(self.Inner, self.T, self.Z + 2) end
function Card:AddSearch(opts)      return Controls.AddSearch(self.Inner, opts, self.T, self.Z + 2) end

-- ─────────────────────────────────────────────────────
-- SUBTAB CLASS
-- ─────────────────────────────────────────────────────
local SubTab = {}
SubTab.__index = SubTab

function SubTab.new(name, T, zBase)
	local self = setmetatable({}, SubTab)
	self.Name = name
	self.T    = T
	self.Z    = zBase or 10

	-- Scrollable content container
	local scroll = Util.Create("ScrollingFrame", {
		Name = "SubTab_"..name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		ScrollBarImageColor3 = T.ScrollBar,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		ZIndex = zBase or 10,
	})
	Util.ApplyPadding(scroll, 14, 14, 16, 16)

	local colLayout = Util.Create("Frame", {
		Name = "ColLayout",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = (zBase or 10) + 1,
		Parent = scroll,
	})

	local colList = Util.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Wraps = true,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 14),
		Parent = colLayout,
	})

	self.Scroll    = scroll
	self.ColLayout = colLayout
	self.CardCount = 0

	return self
end

function SubTab:AddCard(opts)
	self.CardCount += 1
	opts = opts or {}
	opts.LayoutOrder = self.CardCount

	-- Each card gets a wrapper frame that auto-sizes
	local wrapper = Util.Create("Frame", {
		Name = "CardWrapper",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -7, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self.CardCount,
		ZIndex = self.Z + 1,
		Parent = self.ColLayout,
	})

	local c = Card.new(wrapper, opts, self.T, self.Z + 1)

	-- Make card fill wrapper
	c.Frame.Size = UDim2.new(1, 0, 0, 0)
	c.Frame.AutomaticSize = Enum.AutomaticSize.Y

	return c
end

-- ─────────────────────────────────────────────────────
-- TAB CLASS
-- ─────────────────────────────────────────────────────
local Tab = {}
Tab.__index = Tab

function Tab.new(name, icon, T, contentArea, zBase)
	local self = setmetatable({}, Tab)
	self.Name        = name
	self.T           = T
	self.SubTabs     = {}
	self.ActiveSubTab = nil
	self.Z           = zBase or 10

	-- Tab's container
	self.Container = Util.Create("Frame", {
		Name = "Tab_"..name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		ZIndex = zBase or 10,
		Parent = contentArea,
	})

	-- Subtab bar
	self.SubBar = Util.Create("Frame", {
		Name = "SubBar",
		BackgroundColor3 = T.Header,
		Size = UDim2.new(1, 0, 0, 0),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = (zBase or 10) + 1,
		Parent = self.Container,
	})

	Util.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = self.SubBar,
	})
	Util.ApplyPadding(self.SubBar, 0, 0, 12, 12)

	-- Subtab content area
	self.SubContent = Util.Create("Frame", {
		Name = "SubContent",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = (zBase or 10) + 1,
		Parent = self.Container,
	})

	return self
end

function Tab:AddSubTab(name)
	local st = SubTab.new(name, self.T, self.Z + 2)
	st.Scroll.Parent = self.SubContent
	table.insert(self.SubTabs, st)

	-- Show subtab bar
	if #self.SubTabs == 1 then
		self:_ShowSubBar(true)
	end

	-- Create subtab button
	local btn = Util.Create("TextButton", {
		Name = "STBtn_"..name,
		Text = name,
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = self.T.TextSecondary,
		BackgroundColor3 = self.T.SubTabInactive,
		Size = UDim2.new(0, 0, 0, 28),
		AutomaticSize = Enum.AutomaticSize.X,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		ZIndex = self.Z + 3,
		Parent = self.SubBar,
	})
	Util.ApplyCorner(btn, 6)
	Util.ApplyPadding(btn, 0, 0, 12, 12)

	st.Button = btn

	btn.MouseButton1Click:Connect(function()
		self:SelectSubTab(st)
	end)
	btn.MouseEnter:Connect(function()
		if self.ActiveSubTab ~= st then
			Util.Tween(btn, { BackgroundColor3 = self.T.TabHover }, 0.15)
		end
	end)
	btn.MouseLeave:Connect(function()
		if self.ActiveSubTab ~= st then
			Util.Tween(btn, { BackgroundColor3 = self.T.SubTabInactive }, 0.15)
		end
	end)

	-- Auto-select first subtab
	if #self.SubTabs == 1 then
		self:SelectSubTab(st)
	end

	return st
end

function Tab:_ShowSubBar(show)
	local targetH = show and 48 or 0
	Util.Tween(self.SubBar, { Size = UDim2.new(1, 0, 0, targetH) }, 0.2)
	self.SubContent.Position = UDim2.new(0, 0, 0, show and 48 or 0)
	self.SubContent.Size     = UDim2.new(1, 0, 1, show and -48 or 0)
end

function Tab:SelectSubTab(st)
	if self.ActiveSubTab == st then return end
	-- Deselect old
	if self.ActiveSubTab then
		self.ActiveSubTab.Scroll.Visible = false
		Util.Tween(self.ActiveSubTab.Button, {
			BackgroundColor3 = self.T.SubTabInactive,
			TextColor3       = self.T.TextSecondary,
		}, 0.18)
	end
	self.ActiveSubTab = st
	st.Scroll.Visible = true
	Util.Tween(st.Button, {
		BackgroundColor3 = self.T.SubTabActive,
		TextColor3       = Color3.fromRGB(255,255,255),
	}, 0.18)
end

-- ─────────────────────────────────────────────────────
-- WINDOW CLASS
-- ─────────────────────────────────────────────────────
local Window = {}
Window.__index = Window

function Window.new(opts, T)
	local self = setmetatable({}, Window)
	opts = opts or {}
	self.T          = T
	self.Tabs       = {}
	self.ActiveTab  = nil
	self.Z          = 5

	local title    = opts.Title or "NexusUI"
	local subtitle = opts.SubTitle or ""
	local size     = opts.Size or UDim2.new(0, 780, 0, 530)
	local center   = opts.Center ~= false

	-- ScreenGui
	local sgui = Util.Create("ScreenGui", {
		Name = "NexusUI_"..title,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
	})
	pcall(function() sgui.Parent = CoreGui end)
	if not sgui.Parent then sgui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	self.ScreenGui = sgui

	-- Notification controller
	self.Notif = NotificationController.new(sgui, T)

	-- Main window frame
	local mainFrame = Util.Create("Frame", {
		Name = "Window",
		BackgroundColor3 = T.Background,
		AnchorPoint = center and Vector2.new(0.5, 0.5) or Vector2.new(0, 0),
		Position = center and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.1, 0, 0.1, 0),
		Size = size,
		BorderSizePixel = 0,
		ZIndex = self.Z,
		Parent = sgui,
	})
	Util.ApplyCorner(mainFrame, 12)
	Util.ApplyStroke(mainFrame, T.SidebarBorder, 1, 0.5)
	Util.MakeShadow(mainFrame, 30, 0.55)

	self.MainFrame = mainFrame

	-- Allow dragging from top bar
	Util.Dragify(mainFrame)

	-- Sidebar
	local sidebar = Util.Create("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = T.Sidebar,
		Size = UDim2.new(0, 190, 1, 0),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = self.Z + 1,
		Parent = mainFrame,
	})
	Util.ApplyCorner(sidebar, 12)

	-- Fix right corners of sidebar (square)
	Util.Create("Frame", {
		BackgroundColor3 = T.Sidebar,
		Position = UDim2.new(1, -12, 0, 0),
		Size = UDim2.new(0, 12, 1, 0),
		BorderSizePixel = 0,
		ZIndex = self.Z + 1,
		Parent = sidebar,
	})

	-- Sidebar border line
	Util.Create("Frame", {
		Name = "Border",
		BackgroundColor3 = T.SidebarBorder,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BorderSizePixel = 0,
		ZIndex = self.Z + 2,
		Parent = sidebar,
	})

	self.Sidebar = sidebar

	-- Logo area
	local logoArea = Util.Create("Frame", {
		Name = "Logo",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 68),
		ZIndex = self.Z + 2,
		Parent = sidebar,
	})

	-- Logo accent dot
	Util.Create("Frame", {
		Name = "Dot",
		BackgroundColor3 = T.Accent,
		Position = UDim2.new(0, 16, 0, 22),
		Size = UDim2.new(0, 8, 0, 8),
		BorderSizePixel = 0,
		ZIndex = self.Z + 3,
		Parent = logoArea,
	})
	Util.ApplyCorner(logoArea:FindFirstChild("Dot"), 4)

	-- Logo glow
	Util.Create("Frame", {
		Name = "DotGlow",
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0.7,
		Position = UDim2.new(0, 12, 0, 18),
		Size = UDim2.new(0, 16, 0, 16),
		BorderSizePixel = 0,
		ZIndex = self.Z + 2,
		Parent = logoArea,
	})
	Util.ApplyCorner(logoArea:FindFirstChild("DotGlow"), 8)

	Util.Create("TextLabel", {
		Text = title,
		TextColor3 = T.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 32, 0, 16),
		Size = UDim2.new(1, -48, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = self.Z + 3,
		Parent = logoArea,
	})

	if subtitle ~= "" then
		Util.Create("TextLabel", {
			Text = subtitle,
			TextColor3 = T.Accent,
			Font = Enum.Font.Gotham,
			TextSize = 10,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 32, 0, 36),
			Size = UDim2.new(1, -48, 0, 14),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = self.Z + 3,
			Parent = logoArea,
		})
	end

	-- Divider under logo
	Util.Create("Frame", {
		BackgroundColor3 = T.SidebarBorder,
		Position = UDim2.new(0, 12, 0, 62),
		Size = UDim2.new(1, -24, 0, 1),
		BorderSizePixel = 0,
		ZIndex = self.Z + 2,
		Parent = sidebar,
	})

	-- Tab list
	local tabList = Util.Create("Frame", {
		Name = "TabList",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 70),
		Size = UDim2.new(1, 0, 1, -130),
		ZIndex = self.Z + 2,
		Parent = sidebar,
		ClipsDescendants = false,
	})
	Util.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = tabList,
	})
	Util.ApplyPadding(tabList, 6, 6, 8, 8)
	self.TabList = tabList

	-- Active tab indicator bar (animated)
	self.ActiveBar = Util.Create("Frame", {
		Name = "ActiveBar",
		BackgroundColor3 = T.Accent,
		Size = UDim2.new(0, 3, 0, 20),
		Position = UDim2.new(0, 0, 0, 0),
		BorderSizePixel = 0,
		ZIndex = self.Z + 5,
		Visible = false,
		Parent = sidebar,
	})
	Util.ApplyCorner(self.ActiveBar, 2)

	-- Bottom sidebar controls
	local sideBottom = Util.Create("Frame", {
		Name = "SideBottom",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -8),
		Size = UDim2.new(1, 0, 0, 56),
		ZIndex = self.Z + 2,
		Parent = sidebar,
	})

	Util.Create("Frame", {
		BackgroundColor3 = T.SidebarBorder,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -24, 0, 1),
		BorderSizePixel = 0,
		ZIndex = self.Z + 2,
		Parent = sideBottom,
	})

	-- Content area
	local content = Util.Create("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 190, 0, 0),
		Size = UDim2.new(1, -190, 1, 0),
		ZIndex = self.Z + 1,
		Parent = mainFrame,
	})
	self.Content = content

	-- Top header bar
	local topBar = Util.Create("Frame", {
		Name = "TopBar",
		BackgroundColor3 = T.Header,
		Size = UDim2.new(1, 0, 0, 44),
		BorderSizePixel = 0,
		ZIndex = self.Z + 2,
		Parent = content,
	})
	Util.Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = topBar })
	-- Square bottom left
	Util.Create("Frame", {
		BackgroundColor3 = T.Header,
		Position = UDim2.new(0, 0, 1, -12),
		Size = UDim2.new(1, 0, 0, 12),
		BorderSizePixel = 0,
		ZIndex = self.Z + 2,
		Parent = topBar,
	})

	self.TopBarTitle = Util.Create("TextLabel", {
		Name = "TabTitle",
		Text = "",
		TextColor3 = T.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 0),
		Size = UDim2.new(0.6, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = self.Z + 3,
		Parent = topBar,
	})

	-- Window controls (close/minimize)
	local ctrlRow = Util.Create("Frame", {
		Name = "WindowCtrls",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, 60, 0, 28),
		ZIndex = self.Z + 3,
		Parent = topBar,
	})
	Util.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 6),
		Parent = ctrlRow,
	})

	local function makeCtrl(txt, col, cb)
		local btn = Util.Create("TextButton", {
			Text = txt,
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextColor3 = Color3.fromRGB(200,200,200),
			BackgroundColor3 = col,
			Size = UDim2.new(0, 24, 0, 24),
			BorderSizePixel = 0,
			AutoButtonColor = false,
			ZIndex = self.Z + 4,
			Parent = ctrlRow,
		})
		Util.ApplyCorner(btn, 6)
		btn.MouseButton1Click:Connect(cb)
		btn.MouseEnter:Connect(function() Util.Tween(btn, { BackgroundColor3 = col:Lerp(Color3.fromRGB(255,255,255), 0.15) }, 0.1) end)
		btn.MouseLeave:Connect(function() Util.Tween(btn, { BackgroundColor3 = col }, 0.1) end)
		return btn
	end

	makeCtrl("—", Color3.fromRGB(50,50,70), function()
		self:Toggle()
	end)
	makeCtrl("✕", Color3.fromRGB(239,68,68), function()
		self:Destroy()
	end)

	-- Tab content host
	self.TabContent = Util.Create("Frame", {
		Name = "TabContent",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 44),
		Size = UDim2.new(1, 0, 1, -44),
		ZIndex = self.Z + 2,
		Parent = content,
	})

	self._minimized = false
	self._origSize  = size

	return self
end

function Window:AddTab(opts)
	opts = opts or {}
	local name = opts.Name or ("Tab "..tostring(#self.Tabs + 1))
	local icon = opts.Icon or "default"
	local T    = self.T

	local tab = Tab.new(name, icon, T, self.TabContent, self.Z + 3)
	table.insert(self.Tabs, tab)

	-- Sidebar tab button
	local btn = Util.Create("TextButton", {
		Name = "TabBtn_"..name,
		Text = "",
		BackgroundColor3 = Color3.fromRGB(0,0,0),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 38),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		LayoutOrder = #self.Tabs,
		ZIndex = self.Z + 3,
		Parent = self.TabList,
	})
	Util.ApplyCorner(btn, 8)

	local iconLabel = Util.Create("TextLabel", {
		Text = NexusUI.GetIcon(icon),
		TextColor3 = T.TextSecondary,
		Font = Enum.Font.Gotham,
		TextSize = 15,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(0, 24, 1, 0),
		ZIndex = self.Z + 4,
		Parent = btn,
	})

	local nameLabel = Util.Create("TextLabel", {
		Text = name,
		TextColor3 = T.TextSecondary,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 38, 0, 0),
		Size = UDim2.new(1, -46, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = self.Z + 4,
		Parent = btn,
	})

	tab.SideBtn     = btn
	tab.SideIcon    = iconLabel
	tab.SideName    = nameLabel

	btn.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)
	btn.MouseEnter:Connect(function()
		if self.ActiveTab ~= tab then
			Util.Tween(btn, { BackgroundTransparency = 0, BackgroundColor3 = T.TabHover }, 0.15)
		end
	end)
	btn.MouseLeave:Connect(function()
		if self.ActiveTab ~= tab then
			Util.Tween(btn, { BackgroundTransparency = 1 }, 0.15)
		end
	end)

	-- Auto select first
	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end

	return tab
end

function Window:SelectTab(tab)
	if self.ActiveTab == tab then return end

	-- Deselect old
	if self.ActiveTab then
		self.ActiveTab.Container.Visible = false
		local ob = self.ActiveTab.SideBtn
		Util.Tween(ob, { BackgroundTransparency = 1 }, 0.18)
		Util.Tween(self.ActiveTab.SideIcon, { TextColor3 = self.T.TextSecondary }, 0.18)
		Util.Tween(self.ActiveTab.SideName, { TextColor3 = self.T.TextSecondary }, 0.18)
	end

	self.ActiveTab = tab
	tab.Container.Visible = true
	self.TopBarTitle.Text = tab.Name

	-- Animate sidebar button
	Util.Tween(tab.SideBtn, { BackgroundTransparency = 0, BackgroundColor3 = self.T.TabHover }, 0.18)
	Util.Tween(tab.SideIcon, { TextColor3 = self.T.Accent }, 0.18)
	Util.Tween(tab.SideName, { TextColor3 = self.T.Text }, 0.18)

	-- Move active bar
	local btnPos = tab.SideBtn.AbsolutePosition.Y - self.Sidebar.AbsolutePosition.Y + tab.SideBtn.AbsoluteSize.Y / 2 - 10
	self.ActiveBar.Visible = true
	Util.Tween(self.ActiveBar, { Position = UDim2.new(0, 0, 0, btnPos) }, 0.22, Enum.EasingStyle.Quint)
end

function Window:Notify(opts)
	self.Notif:Notify(opts)
end

function Window:Toggle()
	self._minimized = not self._minimized
	if self._minimized then
		Util.Tween(self.MainFrame, { Size = UDim2.new(0, self._origSize.X.Offset, 0, 44) }, 0.3, Enum.EasingStyle.Quint)
		self.Content.Visible  = false
		self.Sidebar.ClipsDescendants = true
		Util.Tween(self.Sidebar, { Size = UDim2.new(0, 190, 0, 44) }, 0.3, Enum.EasingStyle.Quint)
	else
		Util.Tween(self.MainFrame, { Size = self._origSize }, 0.3, Enum.EasingStyle.Quint)
		task.delay(0.15, function()
			self.Content.Visible = true
			self.Sidebar.ClipsDescendants = false
			Util.Tween(self.Sidebar, { Size = UDim2.new(0, 190, 1, 0) }, 0.25, Enum.EasingStyle.Quint)
		end)
	end
end

function Window:SetTheme(themeName)
	-- Hot theme switch placeholder
	local newTheme = Themes[themeName]
	if newTheme then self.T = newTheme end
end

function Window:Destroy()
	Util.Tween(self.MainFrame, { Size = UDim2.new(0, self._origSize.X.Offset * 0.9, 0, self._origSize.Y.Offset * 0.9), BackgroundTransparency = 1 }, 0.3)
	task.delay(0.32, function()
		self.ScreenGui:Destroy()
	end)
end

-- ─────────────────────────────────────────────────────
-- NEXUSUI ENTRY POINT
-- ─────────────────────────────────────────────────────
function NexusUI:CreateWindow(opts)
	opts = opts or {}
	local themeName = opts.Theme or "Dark"
	local T = Themes[themeName] or Themes.Dark
	-- Allow partial theme override
	if opts.ThemeOverride then
		T = setmetatable(opts.ThemeOverride, { __index = T })
	end
	return Window.new(opts, T)
end

function NexusUI:GetThemes()
	local out = {}
	for k in pairs(Themes) do table.insert(out, k) end
	return out
end

function NexusUI:RegisterTheme(name, theme)
	Themes[name] = theme
end

-- ─────────────────────────────────────────────────────
-- RETURN
-- ─────────────────────────────────────────────────────
return NexusUI

--[[
===========================================
 FULL USAGE EXAMPLE
===========================================

local Nexus = loadstring(game:HttpGet("YOUR_RAW_URL"))()

local Win = Nexus:CreateWindow({
	Title    = "NexusUI",
	SubTitle = "v1.0.0",
	Theme    = "Dark",     -- "Dark" | "Light"
	Size     = UDim2.new(0, 780, 0, 530),
})

-- ── COMBAT TAB ──────────────────────────
local Combat = Win:AddTab({ Name = "Combat", Icon = "combat" })

local Aim = Combat:AddSubTab("Aimbot")
local AimCard = Aim:AddCard({ Title = "Aimbot", Description = "Silent aim & FOV settings" })

AimCard:AddToggle({
	Name = "Enable Aimbot",
	Default = false,
	Callback = function(v) print("Aimbot:", v) end,
})
AimCard:AddSlider({
	Name = "FOV",
	Min = 10, Max = 360, Default = 90, Suffix = "°",
	Callback = function(v) print("FOV:", v) end,
})
AimCard:AddDropdown({
	Name = "Target Part",
	Options = { "Head", "Torso", "Left Arm", "Right Arm" },
	Default = "Head",
	Callback = function(v) print("Target:", v) end,
})
AimCard:AddKeybind({
	Name = "Toggle Key",
	Default = Enum.KeyCode.X,
	Callback = function(k) print("Key:", k) end,
})

local TrigCard = Aim:AddCard({ Title = "Triggerbot" })
TrigCard:AddToggle({ Name = "Triggerbot", Default = false })
TrigCard:AddSlider({ Name = "Delay (ms)", Min = 0, Max = 500, Default = 50, Suffix = "ms" })

local ESP = Combat:AddSubTab("ESP")
local ESPCard = ESP:AddCard({ Title = "ESP Settings" })
ESPCard:AddToggle({ Name = "Box ESP", Default = true })
ESPCard:AddToggle({ Name = "Name ESP", Default = true })
ESPCard:AddColorPicker({ Name = "ESP Color", Default = Color3.fromRGB(255,0,0) })
ESPCard:AddSlider({ Name = "Max Distance", Min = 100, Max = 2000, Default = 500, Suffix = "m" })

-- ── SETTINGS TAB ────────────────────────
local Settings = Win:AddTab({ Name = "Settings", Icon = "settings" })
local General  = Settings:AddSubTab("General")

local ThemeCard = General:AddCard({ Title = "Appearance" })
ThemeCard:AddDropdown({
	Name = "Theme",
	Options = { "Dark", "Light" },
	Default = "Dark",
	Callback = function(v) Win:SetTheme(v) end,
})
ThemeCard:AddToggle({ Name = "Show FPS", Default = false })

-- ── NOTIFICATIONS ───────────────────────
Win:Notify({
	Title = "Welcome!",
	Description = "NexusUI loaded successfully.",
	Type = "Success",
	Duration = 5,
})

===========================================
]]
