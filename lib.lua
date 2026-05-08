--[[
╔══════════════════════════════════════════════════════════════════╗
║                       NexusUI  v2.0.0                           ║
║          Modern Roblox Dashboard UI Library                     ║
║                                                                  ║
║  Architecture:                                                   ║
║    Window → Sidebar (collapse/expand) → Tab → SubTab            ║
║         → Content → MasonryGrid → Card → Controls              ║
║                                                                  ║
║  Features:                                                       ║
║    · Collapsible sidebar (icon-only ↔ full)                    ║
║    · Masonry/grid card layout with auto-sizing                  ║
║    · Full spring/tween animation system                         ║
║    · Toggles, Sliders, Dropdowns, Textboxes, Keybinds          ║
║    · Color Picker (HSV wheel + hex input)                       ║
║    · Multi-dropdown, Search, Player List                        ║
║    · Notification queue system                                  ║
║    · Config save/load (writefile/readfile)                      ║
║    · 8 built-in themes + custom theme support                   ║
║    · Blur background option                                     ║
║    · Mobile-aware sizing                                        ║
╚══════════════════════════════════════════════════════════════════╝

	QUICK START:
	────────────────────────────────────────────────
	local Nexus  = loadstring(game:HttpGet("YOUR_URL"))()

	local Win    = Nexus:CreateWindow({
	    Title       = "MyCheat",
	    SubTitle    = "v2.0",
	    Theme       = "Midnight",
	    ConfigurationSaving = { Enabled = true, FileName = "MyCheat" },
	    BlurBackground = true,
	})

	local Tab    = Win:AddTab({ Name = "Combat", Icon = "sword" })
	local Sub    = Tab:AddSubTab("Aimbot")
	local Card   = Sub:AddCard({ Title = "Aim Settings", Width = "half" })

	Card:AddToggle({
	    Name     = "Enable",
	    Flag     = "AimbotEnabled",
	    Default  = false,
	    Callback = function(v) print("Aimbot:", v) end,
	})

	Card:AddSlider({
	    Name     = "FOV",
	    Flag     = "AimbotFOV",
	    Min = 10, Max = 360, Default = 90, Suffix = "°",
	    Callback = function(v) print("FOV:", v) end,
	})

	Win:Notify({ Title = "Loaded", Description = "NexusUI ready.", Type = "Success" })
	────────────────────────────────────────────────
]]

-- ══════════════════════════════════════════════════════
--  0. SERVICES & CONSTANTS
-- ══════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")
local TextService      = game:GetService("TextService")

local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()

-- Safe pcall wrappers for exploit functions
local function safeCall(fn, ...)
	if type(fn) ~= "function" then return nil end
	local ok, r = pcall(fn, ...)
	return ok and r or nil
end

local writeFile  = safeCall(function() return writefile  end) or nil
local readFile   = safeCall(function() return readfile   end) or nil
local isFile     = safeCall(function() return isfile     end) or nil
local makeFolder = safeCall(function() return makefolder end) or nil
local isFolder   = safeCall(function() return isfolder   end) or nil
local getHUI     = safeCall(function() return gethui     end) or nil

-- ══════════════════════════════════════════════════════
--  1. THEME DEFINITIONS
-- ══════════════════════════════════════════════════════
local Themes = {}

-- Helper to make a theme
local function T(bg, sidebar, card, accent, text, textSec, header, input, toggle, slider, dropdown, notif)
	return {
		Background          = bg,
		Sidebar             = sidebar,
		SidebarBorder       = bg:Lerp(Color3.new(1,1,1), 0.07),
		Card                = card,
		CardBorder          = card:Lerp(Color3.new(1,1,1), 0.08),
		CardShadow          = Color3.new(0,0,0),
		Header              = header,
		HeaderBorder        = header:Lerp(Color3.new(1,1,1), 0.06),
		Accent              = accent,
		AccentDark          = accent:Lerp(Color3.new(0,0,0), 0.35),
		AccentLight         = accent:Lerp(Color3.new(1,1,1), 0.25),
		AccentTransp        = 0.82,
		Text                = text,
		TextSecondary       = textSec,
		TextDisabled        = textSec:Lerp(Color3.new(0,0,0), 0.3),
		TextOnAccent        = Color3.new(1,1,1),
		TabActiveBg         = accent:Lerp(Color3.new(0,0,0), 0.2),
		TabActiveText       = text,
		TabInactiveBg       = Color3.new(0,0,0),
		TabInactiveTransp   = 1,
		TabHoverBg          = card,
		TabHoverTransp      = 0,
		SubTabActive        = accent,
		SubTabInactive      = input,
		SubTabInactiveText  = textSec,
		ToggleOn            = toggle,
		ToggleOnStroke      = toggle:Lerp(Color3.new(1,1,1), 0.25),
		ToggleOff           = input,
		ToggleOffStroke     = input:Lerp(Color3.new(1,1,1), 0.08),
		ToggleKnob          = Color3.new(1,1,1),
		SliderFill          = slider,
		SliderTrack         = input,
		SliderKnob          = Color3.new(1,1,1),
		SliderKnobStroke    = slider,
		ButtonPrimary       = accent,
		ButtonPrimaryHover  = accent:Lerp(Color3.new(1,1,1), 0.12),
		ButtonPrimaryText   = Color3.new(1,1,1),
		ButtonSecondary     = input,
		ButtonSecondaryHover= input:Lerp(Color3.new(1,1,1), 0.08),
		ButtonSecondaryText = text,
		InputBg             = input,
		InputBgFocus        = input:Lerp(accent, 0.06),
		InputBorder         = input:Lerp(Color3.new(1,1,1), 0.1),
		InputBorderFocus    = accent,
		InputText           = text,
		InputPlaceholder    = textSec,
		DropdownBg          = dropdown,
		DropdownBorder      = dropdown:Lerp(Color3.new(1,1,1), 0.08),
		DropdownItemHover   = dropdown:Lerp(Color3.new(1,1,1), 0.06),
		DropdownItemActive  = accent:Lerp(Color3.new(0,0,0), 0.1),
		NotifBg             = notif,
		NotifBorder         = notif:Lerp(Color3.new(1,1,1), 0.1),
		NotifSuccess        = Color3.fromRGB(34, 197, 94),
		NotifWarning        = Color3.fromRGB(234, 179, 8),
		NotifError          = Color3.fromRGB(239, 68, 68),
		NotifInfo           = accent,
		ScrollBar           = textSec:Lerp(Color3.new(0,0,0), 0.4),
		Divider             = input:Lerp(Color3.new(1,1,1), 0.05),
	}
end

Themes.Midnight = T(
	Color3.fromRGB(11, 11, 15),
	Color3.fromRGB(8,  8,  12),
	Color3.fromRGB(18, 18, 26),
	Color3.fromRGB(99, 102, 241),
	Color3.fromRGB(228, 228, 240),
	Color3.fromRGB(120, 120, 148),
	Color3.fromRGB(14, 14, 20),
	Color3.fromRGB(13, 13, 19),
	Color3.fromRGB(99, 102, 241),
	Color3.fromRGB(99, 102, 241),
	Color3.fromRGB(10, 10, 16),
	Color3.fromRGB(16, 16, 24)
)

Themes.Carbon = T(
	Color3.fromRGB(14, 14, 14),
	Color3.fromRGB(10, 10, 10),
	Color3.fromRGB(22, 22, 22),
	Color3.fromRGB(255, 85, 85),
	Color3.fromRGB(230, 230, 230),
	Color3.fromRGB(115, 115, 115),
	Color3.fromRGB(17, 17, 17),
	Color3.fromRGB(12, 12, 12),
	Color3.fromRGB(255, 85, 85),
	Color3.fromRGB(255, 85, 85),
	Color3.fromRGB(8, 8, 8),
	Color3.fromRGB(18, 18, 18)
)

Themes.Ocean = T(
	Color3.fromRGB(12, 20, 28),
	Color3.fromRGB(9,  15, 22),
	Color3.fromRGB(17, 28, 40),
	Color3.fromRGB(0,  188, 212),
	Color3.fromRGB(220, 240, 250),
	Color3.fromRGB(100, 150, 180),
	Color3.fromRGB(13, 22, 32),
	Color3.fromRGB(10, 18, 28),
	Color3.fromRGB(0, 188, 212),
	Color3.fromRGB(0, 188, 212),
	Color3.fromRGB(7, 13, 21),
	Color3.fromRGB(14, 24, 36)
)

Themes.Sakura = T(
	Color3.fromRGB(28, 14, 20),
	Color3.fromRGB(22, 10, 16),
	Color3.fromRGB(38, 20, 30),
	Color3.fromRGB(236, 72, 153),
	Color3.fromRGB(240, 220, 230),
	Color3.fromRGB(170, 120, 150),
	Color3.fromRGB(32, 16, 24),
	Color3.fromRGB(22, 12, 18),
	Color3.fromRGB(236, 72, 153),
	Color3.fromRGB(236, 72, 153),
	Color3.fromRGB(18, 9, 14),
	Color3.fromRGB(34, 18, 26)
)

Themes.Forest = T(
	Color3.fromRGB(12, 20, 14),
	Color3.fromRGB(9,  15, 10),
	Color3.fromRGB(17, 28, 20),
	Color3.fromRGB(34, 197, 94),
	Color3.fromRGB(210, 240, 220),
	Color3.fromRGB(100, 160, 120),
	Color3.fromRGB(13, 22, 15),
	Color3.fromRGB(10, 18, 12),
	Color3.fromRGB(34, 197, 94),
	Color3.fromRGB(34, 197, 94),
	Color3.fromRGB(7, 13, 9),
	Color3.fromRGB(14, 24, 17)
)

Themes.Ember = T(
	Color3.fromRGB(24, 14, 10),
	Color3.fromRGB(18, 10, 7),
	Color3.fromRGB(34, 20, 14),
	Color3.fromRGB(251, 146, 60),
	Color3.fromRGB(245, 235, 225),
	Color3.fromRGB(180, 140, 120),
	Color3.fromRGB(28, 16, 12),
	Color3.fromRGB(20, 12, 9),
	Color3.fromRGB(251, 146, 60),
	Color3.fromRGB(251, 146, 60),
	Color3.fromRGB(14, 9, 6),
	Color3.fromRGB(30, 18, 13)
)

Themes.Violet = T(
	Color3.fromRGB(18, 12, 28),
	Color3.fromRGB(13, 8,  22),
	Color3.fromRGB(26, 17, 42),
	Color3.fromRGB(167, 139, 250),
	Color3.fromRGB(235, 228, 252),
	Color3.fromRGB(150, 120, 200),
	Color3.fromRGB(21, 14, 34),
	Color3.fromRGB(15, 10, 25),
	Color3.fromRGB(167, 139, 250),
	Color3.fromRGB(167, 139, 250),
	Color3.fromRGB(11, 7, 18),
	Color3.fromRGB(22, 15, 38)
)

Themes.Pearl = T(
	Color3.fromRGB(246, 246, 250),
	Color3.fromRGB(238, 238, 244),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(99, 102, 241),
	Color3.fromRGB(20, 20, 35),
	Color3.fromRGB(110, 110, 140),
	Color3.fromRGB(240, 240, 248),
	Color3.fromRGB(232, 232, 242),
	Color3.fromRGB(99, 102, 241),
	Color3.fromRGB(99, 102, 241),
	Color3.fromRGB(250, 250, 255),
	Color3.fromRGB(252, 252, 255)
)

-- ══════════════════════════════════════════════════════
--  2. UTILITY / HELPERS
-- ══════════════════════════════════════════════════════
local Util = {}

-- Spring-style tween info presets
Util.TweenPresets = {
	Fast     = TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Normal   = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Slow     = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Spring   = TweenInfo.new(0.30, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
	Bounce   = TweenInfo.new(0.45, Enum.EasingStyle.Bounce,Enum.EasingDirection.Out),
	Linear   = TweenInfo.new(0.20, Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),
	Ease     = TweenInfo.new(0.25, Enum.EasingStyle.Sine,  Enum.EasingDirection.InOut),
	Elastic  = TweenInfo.new(0.55, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
}

function Util.Tween(obj, props, preset, overrideDuration)
	if not obj or not obj.Parent then return end
	local info = type(preset) == "string" and Util.TweenPresets[preset] or (preset or Util.TweenPresets.Normal)
	if overrideDuration then
		info = TweenInfo.new(overrideDuration, info.EasingStyle, info.EasingDirection)
	end
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

function Util.TweenCallback(obj, props, preset, cb)
	local tw = Util.Tween(obj, props, preset)
	if tw then tw.Completed:Connect(cb) end
	return tw
end

function Util.New(class, props, parent)
	local inst = Instance.new(class)
	if props then
		for k, v in pairs(props) do
			if k ~= "Parent" then
				inst[k] = v
			end
		end
	end
	if parent then inst.Parent = parent end
	if props and props.Parent and not parent then
		inst.Parent = props.Parent
	end
	return inst
end

function Util.Corner(r, parent)
	return Util.New("UICorner", { CornerRadius = UDim.new(0, r or 8) }, parent)
end

function Util.Padding(t, b, l, r, parent)
	return Util.New("UIPadding", {
		PaddingTop    = UDim.new(0, t or 8),
		PaddingBottom = UDim.new(0, b or 8),
		PaddingLeft   = UDim.new(0, l or 8),
		PaddingRight  = UDim.new(0, r or 8),
	}, parent)
end

function Util.Stroke(color, thickness, transparency, parent)
	return Util.New("UIStroke", {
		Color        = color or Color3.new(1,1,1),
		Thickness    = thickness or 1,
		Transparency = transparency or 0,
	}, parent)
end

function Util.Shadow(parent, offset, trans, size)
	return Util.New("ImageLabel", {
		Name                 = "_Shadow",
		AnchorPoint          = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position             = UDim2.new(0.5, 0, 0.5, offset or 3),
		Size                 = UDim2.new(1, size or 24, 1, size or 24),
		ZIndex               = math.max(1, (parent.ZIndex or 1) - 1),
		Image                = "rbxassetid://6015897843",
		ImageColor3          = Color3.new(0, 0, 0),
		ImageTransparency    = trans or 0.65,
		ScaleType            = Enum.ScaleType.Slice,
		SliceCenter          = Rect.new(49, 49, 450, 450),
	}, parent)
end

function Util.ListLayout(parent, props)
	props = props or {}
	return Util.New("UIListLayout", {
		FillDirection      = props.Fill    or Enum.FillDirection.Vertical,
		HorizontalAlignment= props.HAlign  or Enum.HorizontalAlignment.Left,
		VerticalAlignment  = props.VAlign  or Enum.VerticalAlignment.Top,
		SortOrder          = props.Sort    or Enum.SortOrder.LayoutOrder,
		Padding            = props.Padding or UDim.new(0, 0),
		Wraps              = props.Wraps   or false,
	}, parent)
end

-- Ripple effect on click
function Util.Ripple(btn, color)
	local rip = Util.New("Frame", {
		Name                  = "_Ripple",
		BackgroundColor3      = color or Color3.new(1,1,1),
		BackgroundTransparency= 0.80,
		BorderSizePixel       = 0,
		ZIndex                = (btn.ZIndex or 1) + 8,
		ClipsDescendants      = false,
	}, btn)
	Util.Corner(100, rip)

	local mx = Mouse.X - btn.AbsolutePosition.X
	local my = Mouse.Y - btn.AbsolutePosition.Y
	local spread = btn.AbsoluteSize.X * 2.8

	rip.Position = UDim2.new(0, mx - 1, 0, my - 1)
	rip.Size     = UDim2.new(0, 2, 0, 2)

	Util.Tween(rip, {
		Size                  = UDim2.new(0, spread, 0, spread),
		Position              = UDim2.new(0, mx - spread/2, 0, my - spread/2),
		BackgroundTransparency= 1,
	}, "Slow")

	task.delay(0.45, function() rip:Destroy() end)
end

-- Draggable frame
function Util.Draggable(frame, handle)
	handle = handle or frame
	local dragging, startInput, startPos = false, nil, nil

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or
		   input.UserInputType == Enum.UserInputType.Touch then
			dragging  = true
			startInput= input.Position
			startPos  = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (
			input.UserInputType == Enum.UserInputType.MouseMovement or
			input.UserInputType == Enum.UserInputType.Touch
		) then
			local delta = input.Position - startInput
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- Clamp a value
function Util.Clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end

-- Round a number
function Util.Round(v, d)
	local m = 10^(d or 0)
	return math.floor(v * m + 0.5) / m
end

-- HSV → RGB
function Util.HSVtoRGB(h, s, v)
	return Color3.fromHSV(h, s, v)
end

-- Connection cleanup helper
local ConnectionList = {}
function Util.Connect(sig, fn)
	local c = sig:Connect(fn)
	table.insert(ConnectionList, c)
	return c
end

function Util.DisconnectAll()
	for _, c in ipairs(ConnectionList) do
		if c.Connected then c:Disconnect() end
	end
	ConnectionList = {}
end

-- ══════════════════════════════════════════════════════
--  3. ICON MAP  (unicode + text fallbacks)
-- ══════════════════════════════════════════════════════
local Icons = {
	-- Navigation
	home        = "⌂",
	combat      = "⚔",
	player      = "☻",
	players     = "☻",
	esp         = "◉",
	settings    = "⚙",
	misc        = "✦",
	movement    = "↑",
	weapon      = "⚡",
	visual      = "◈",
	visuals     = "◈",
	world       = "◇",
	speed       = "»",
	fly         = "△",
	aim         = "◎",
	aimbot      = "◎",
	script      = "{}",
	info        = "ℹ",
	close       = "✕",
	minimize    = "—",
	search      = "⌕",
	star        = "★",
	lock        = "⊘",
	key         = "⌘",
	notification= "◉",
	config      = "⊟",
	folder      = "⊞",
	lightning   = "⚡",
	fire        = "◈",
	sword       = "⚔",
	shield      = "⊕",
	eye         = "◉",
	clock       = "◷",
	tools       = "⚙",
	bolt        = "⚡",
	wifi        = "≋",
	default     = "▸",
	collapse    = "◂",
	expand      = "▸",
	chevronDown = "▾",
	chevronUp   = "▴",
	check       = "✓",
	x           = "✕",
	plus        = "+",
	minus       = "−",
}

local function getIcon(name)
	if not name then return Icons.default end
	return Icons[name:lower()] or Icons.default
end

-- ══════════════════════════════════════════════════════
--  4. CONFIG SAVE / LOAD
-- ══════════════════════════════════════════════════════
local ConfigSystem = {}
ConfigSystem.__index = ConfigSystem

function ConfigSystem.new(opts)
	local self = setmetatable({}, ConfigSystem)
	self.Enabled  = opts and opts.Enabled  or false
	self.Folder   = opts and opts.Folder   or "NexusUI"
	self.FileName = opts and opts.FileName or "config"
	self.Ext      = ".nexus"
	self.Flags    = {}

	if self.Enabled then
		pcall(function()
			if makeFolder and not (isFolder and isFolder(self.Folder)) then
				makeFolder(self.Folder)
			end
		end)
	end
	return self
end

function ConfigSystem:RegisterFlag(flag, default)
	if not self.Flags[flag] then
		self.Flags[flag] = default
	end
end

function ConfigSystem:SetFlag(flag, value)
	self.Flags[flag] = value
	if self.Enabled then
		self:Save()
	end
end

function ConfigSystem:GetFlag(flag)
	return self.Flags[flag]
end

function ConfigSystem:Save()
	if not self.Enabled then return end
	pcall(function()
		if makeFolder and not (isFolder and isFolder(self.Folder)) then
			makeFolder(self.Folder)
		end
		if writeFile then
			writeFile(self.Folder .. "/" .. self.FileName .. self.Ext,
				HttpService:JSONEncode(self.Flags))
		end
	end)
end

function ConfigSystem:Load()
	if not self.Enabled then return end
	pcall(function()
		if isFile and isFile(self.Folder .. "/" .. self.FileName .. self.Ext) then
			if readFile then
				local data = readFile(self.Folder .. "/" .. self.FileName .. self.Ext)
				local ok, decoded = pcall(function() return HttpService:JSONDecode(data) end)
				if ok and decoded then
					for k, v in pairs(decoded) do
						self.Flags[k] = v
					end
				end
			end
		end
	end)
end

-- ══════════════════════════════════════════════════════
--  5. NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════
local NotifSystem = {}
NotifSystem.__index = NotifSystem

function NotifSystem.new(screenGui, theme)
	local self    = setmetatable({}, NotifSystem)
	self.T        = theme
	self.Queue    = {}
	self.Active   = 0
	self.MaxShown = 4

	-- Container anchored bottom-right
	self.Container = Util.New("Frame", {
		Name                 = "NexusNotifications",
		BackgroundTransparency = 1,
		AnchorPoint          = Vector2.new(1, 1),
		Position             = UDim2.new(1, -16, 1, -16),
		Size                 = UDim2.new(0, 340, 1, 0),
		ZIndex               = 10000,
		ClipsDescendants     = false,
	}, screenGui)

	Util.ListLayout(self.Container, {
		VAlign  = Enum.VerticalAlignment.Bottom,
		HAlign  = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 8),
	})

	return self
end

function NotifSystem:Notify(opts)
	local T    = self.T
	local kind = opts.Type or "Info"

	local accentMap = {
		Info    = T.NotifInfo,
		Success = T.NotifSuccess,
		Warning = T.NotifWarning,
		Error   = T.NotifError,
	}
	local accent  = accentMap[kind] or T.NotifInfo
	local dur     = opts.Duration or 4.5
	local title   = opts.Title or "Notification"
	local desc    = opts.Description or opts.Content or ""

	-- Frame
	local nf = Util.New("Frame", {
		Name                 = "Notif",
		BackgroundColor3     = T.NotifBg,
		BackgroundTransparency= 0,
		Size                 = UDim2.new(1, 0, 0, 72),
		BorderSizePixel      = 0,
		ClipsDescendants     = true,
		ZIndex               = 10000,
	}, self.Container)
	Util.Corner(12, nf)
	Util.Stroke(T.NotifBorder, 1, 0.3, nf)
	Util.Shadow(nf, 5, 0.70, 20)

	-- Left accent stripe
	local stripe = Util.New("Frame", {
		Name             = "Stripe",
		BackgroundColor3 = accent,
		Size             = UDim2.new(0, 4, 1, 0),
		BorderSizePixel  = 0,
		ZIndex           = 10001,
	}, nf)
	Util.Corner(3, stripe)

	-- Icon circle
	local iconCircle = Util.New("Frame", {
		BackgroundColor3 = accent,
		BackgroundTransparency = 0.78,
		Position         = UDim2.new(0, 16, 0.5, 0),
		AnchorPoint      = Vector2.new(0, 0.5),
		Size             = UDim2.new(0, 28, 0, 28),
		ZIndex           = 10001,
	}, nf)
	Util.Corner(14, iconCircle)

	local iconMap = { Info = Icons.info, Success = Icons.check, Warning = "!", Error = Icons.x }
	Util.New("TextLabel", {
		Text                 = iconMap[kind] or Icons.info,
		TextColor3           = accent,
		Font                 = Enum.Font.GothamBold,
		TextSize             = 13,
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 1, 0),
		TextXAlignment       = Enum.TextXAlignment.Center,
		ZIndex               = 10002,
	}, iconCircle)

	-- Title
	Util.New("TextLabel", {
		Text             = title,
		TextColor3       = T.Text,
		Font             = Enum.Font.GothamBold,
		TextSize         = 13,
		BackgroundTransparency = 1,
		Position         = UDim2.new(0, 54, 0, 12),
		Size             = UDim2.new(1, -68, 0, 18),
		TextXAlignment   = Enum.TextXAlignment.Left,
		ZIndex           = 10001,
	}, nf)

	-- Description
	Util.New("TextLabel", {
		Text             = desc,
		TextColor3       = T.TextSecondary,
		Font             = Enum.Font.Gotham,
		TextSize         = 11,
		BackgroundTransparency = 1,
		Position         = UDim2.new(0, 54, 0, 33),
		Size             = UDim2.new(1, -68, 0, 28),
		TextXAlignment   = Enum.TextXAlignment.Left,
		TextWrapped      = true,
		ZIndex           = 10001,
	}, nf)

	-- Progress bar
	local prog = Util.New("Frame", {
		BackgroundColor3 = accent,
		BackgroundTransparency = 0.4,
		Position         = UDim2.new(0, 4, 1, -3),
		Size             = UDim2.new(1, -8, 0, 2),
		BorderSizePixel  = 0,
		ZIndex           = 10002,
	}, nf)
	Util.Corner(1, prog)

	-- Dismiss button
	local dismiss = Util.New("TextButton", {
		Text             = Icons.close,
		Font             = Enum.Font.GothamBold,
		TextSize         = 11,
		TextColor3       = T.TextSecondary,
		BackgroundTransparency = 1,
		AnchorPoint      = Vector2.new(1, 0),
		Position         = UDim2.new(1, -8, 0, 6),
		Size             = UDim2.new(0, 20, 0, 20),
		ZIndex           = 10003,
		AutoButtonColor  = false,
	}, nf)

	-- Slide in from right
	nf.Position = UDim2.new(1, 60, 0, 0)
	Util.Tween(nf, { Position = UDim2.new(0, 0, 0, 0) }, "Normal")

	-- Progress shrink
	Util.Tween(prog, { Size = UDim2.new(0, 0, 0, 2) }, TweenInfo.new(dur, Enum.EasingStyle.Linear))

	local function removeNotif()
		Util.TweenCallback(nf, {
			Position             = UDim2.new(1, 60, 0, 0),
			BackgroundTransparency = 1,
		}, "Normal", function()
			nf:Destroy()
		end)
	end

	dismiss.MouseButton1Click:Connect(removeNotif)
	task.delay(dur, removeNotif)
end

-- ══════════════════════════════════════════════════════
--  6. CONTROLS
-- ══════════════════════════════════════════════════════
local Controls = {}

-- ─── TOGGLE ───────────────────────────────────────────
function Controls.Toggle(parent, opts, T, Z, cfg)
	opts     = opts or {}
	local name = opts.Name or "Toggle"
	local flag = opts.Flag
	local desc = opts.Description
	local cb   = opts.Callback or function() end

	local savedVal = flag and cfg and cfg:GetFlag(flag)
	local value    = savedVal ~= nil and savedVal or (opts.Default or false)

	if flag and cfg then cfg:RegisterFlag(flag, value) end

	local rowH = desc and 54 or 40
	local row  = Util.New("Frame", {
		Name                 = "Toggle_"..name,
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 0, rowH),
		LayoutOrder          = opts.Order or 0,
		ZIndex               = Z,
	}, parent)

	-- Name label
	Util.New("TextLabel", {
		Text                 = name,
		TextColor3           = T.Text,
		Font                 = Enum.Font.GothamSemibold,
		TextSize             = 13,
		BackgroundTransparency = 1,
		Position             = UDim2.new(0, 0, 0, desc and 2 or 0),
		Size                 = UDim2.new(1, -56, 0, 20),
		TextXAlignment       = Enum.TextXAlignment.Left,
		ZIndex               = Z + 1,
	}, row)

	if desc then
		Util.New("TextLabel", {
			Text                 = desc,
			TextColor3           = T.TextSecondary,
			Font                 = Enum.Font.Gotham,
			TextSize             = 11,
			BackgroundTransparency = 1,
			Position             = UDim2.new(0, 0, 0, 24),
			Size                 = UDim2.new(1, -56, 0, 16),
			TextXAlignment       = Enum.TextXAlignment.Left,
			TextWrapped          = true,
			ZIndex               = Z + 1,
		}, row)
	end

	-- Track
	local trackW, trackH = 44, 22
	local track = Util.New("Frame", {
		Name             = "Track",
		AnchorPoint      = Vector2.new(1, 0.5),
		Position         = UDim2.new(1, 0, 0.5, 0),
		Size             = UDim2.new(0, trackW, 0, trackH),
		BackgroundColor3 = value and T.ToggleOn or T.ToggleOff,
		BorderSizePixel  = 0,
		ZIndex           = Z + 1,
	}, row)
	Util.Corner(trackH / 2, track)

	local trackStroke = Util.Stroke(value and T.ToggleOnStroke or T.ToggleOffStroke, 1, 0.5, track)

	-- Knob
	local knobSize = trackH - 6
	local knob     = Util.New("Frame", {
		Name             = "Knob",
		AnchorPoint      = Vector2.new(0, 0.5),
		Position         = value
			and UDim2.new(0, trackW - knobSize - 3, 0.5, 0)
			or  UDim2.new(0, 3, 0.5, 0),
		Size             = UDim2.new(0, knobSize, 0, knobSize),
		BackgroundColor3 = T.ToggleKnob,
		BorderSizePixel  = 0,
		ZIndex           = Z + 2,
	}, track)
	Util.Corner(knobSize / 2, knob)

	-- Subtle knob shadow
	Util.Shadow(knob, 1, 0.72, 6)

	local ctrl = { Row = row }

	local function setState(v, animate)
		value = v
		local dur = animate and nil or 0

		Util.Tween(track, { BackgroundColor3 = v and T.ToggleOn or T.ToggleOff }, animate and "Fast" or nil)
		Util.Tween(trackStroke, { Color = v and T.ToggleOnStroke or T.ToggleOffStroke }, animate and "Fast" or nil)
		Util.Tween(knob, {
			Position = v
				and UDim2.new(0, trackW - knobSize - 3, 0.5, 0)
				or  UDim2.new(0, 3, 0.5, 0),
		}, animate and "Fast" or nil)

		if flag and cfg then cfg:SetFlag(flag, v) end
		cb(v)
	end

	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			setState(not value, true)
			Util.Ripple(track)
		end
	end)
	track.MouseEnter:Connect(function()
		Util.Tween(track, { BackgroundColor3 = value
			and T.ToggleOn:Lerp(Color3.new(1,1,1), 0.1)
			or  T.ToggleOff:Lerp(Color3.new(1,1,1), 0.06)
		}, "Fast")
	end)
	track.MouseLeave:Connect(function()
		Util.Tween(track, { BackgroundColor3 = value and T.ToggleOn or T.ToggleOff }, "Fast")
	end)

	function ctrl:Set(v)  setState(v, true) end
	function ctrl:Get()   return value end
	function ctrl:Toggle() setState(not value, true) end

	-- Apply saved config
	if savedVal ~= nil then cb(savedVal) end

	return ctrl
end

-- ─── BUTTON ───────────────────────────────────────────
function Controls.Button(parent, opts, T, Z)
	opts      = opts or {}
	local name = opts.Name or "Button"
	local desc = opts.Description
	local cb   = opts.Callback or function() end
	local style= opts.Style or "Primary"   -- Primary | Secondary | Danger

	local bgColor   = style == "Primary"   and T.ButtonPrimary
	               or style == "Secondary" and T.ButtonSecondary
	               or style == "Danger"    and Color3.fromRGB(239, 68, 68)
	               or T.ButtonPrimary

	local hoverColor= style == "Primary"   and T.ButtonPrimaryHover
	               or style == "Secondary" and T.ButtonSecondaryHover
	               or style == "Danger"    and Color3.fromRGB(248, 90, 90)
	               or T.ButtonPrimaryHover

	local textColor = style == "Secondary" and T.ButtonSecondaryText or T.ButtonPrimaryText

	local rowH = desc and 62 or 36
	local row  = Util.New("Frame", {
		Name                 = "Button_"..name,
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 0, rowH),
		LayoutOrder          = opts.Order or 0,
		ZIndex               = Z,
	}, parent)

	if desc then
		Util.New("TextLabel", {
			Text                 = desc,
			TextColor3           = T.TextSecondary,
			Font                 = Enum.Font.Gotham,
			TextSize             = 11,
			BackgroundTransparency = 1,
			Position             = UDim2.new(0, 0, 0, 0),
			Size                 = UDim2.new(1, 0, 0, 16),
			TextXAlignment       = Enum.TextXAlignment.Left,
			ZIndex               = Z + 1,
		}, row)
	end

	local btn = Util.New("TextButton", {
		Name             = "Btn",
		Text             = name,
		Font             = Enum.Font.GothamSemibold,
		TextSize         = 13,
		TextColor3       = textColor,
		BackgroundColor3 = bgColor,
		Position         = desc and UDim2.new(0, 0, 0, 22) or UDim2.new(0, 0, 0, 0),
		Size             = UDim2.new(1, 0, 0, 36),
		BorderSizePixel  = 0,
		AutoButtonColor  = false,
		ClipsDescendants = true,
		ZIndex           = Z + 1,
	}, row)
	Util.Corner(9, btn)

	-- Subtle stroke for secondary
	if style == "Secondary" then
		Util.Stroke(T.InputBorder, 1, 0.3, btn)
	end

	btn.MouseEnter:Connect(function()
		Util.Tween(btn, { BackgroundColor3 = hoverColor }, "Fast")
	end)
	btn.MouseLeave:Connect(function()
		Util.Tween(btn, { BackgroundColor3 = bgColor }, "Fast")
	end)
	btn.MouseButton1Click:Connect(function()
		Util.Ripple(btn, textColor)
		-- Scale pop
		Util.Tween(btn, { Size = UDim2.new(1, -4, 0, 33) }, "Fast")
		task.delay(0.12, function()
			Util.Tween(btn, { Size = UDim2.new(1, 0, 0, 36) }, "Spring")
		end)
		cb()
	end)

	return { Row = row, Button = btn }
end

-- ─── SLIDER ───────────────────────────────────────────
function Controls.Slider(parent, opts, T, Z, cfg)
	opts      = opts or {}
	local name    = opts.Name or "Slider"
	local flag    = opts.Flag
	local minV    = opts.Min     or 0
	local maxV    = opts.Max     or 100
	local decimal = opts.Decimal or 0
	local suffix  = opts.Suffix  or ""
	local cb      = opts.Callback or function() end

	local savedVal = flag and cfg and cfg:GetFlag(flag)
	local value    = Util.Clamp(savedVal ~= nil and savedVal or (opts.Default or minV), minV, maxV)

	if flag and cfg then cfg:RegisterFlag(flag, value) end

	local row = Util.New("Frame", {
		Name                 = "Slider_"..name,
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 0, 58),
		LayoutOrder          = opts.Order or 0,
		ZIndex               = Z,
	}, parent)

	-- Top row: name + value
	Util.New("TextLabel", {
		Text                 = name,
		TextColor3           = T.Text,
		Font                 = Enum.Font.GothamSemibold,
		TextSize             = 13,
		BackgroundTransparency = 1,
		Position             = UDim2.new(0, 0, 0, 0),
		Size                 = UDim2.new(0.65, 0, 0, 20),
		TextXAlignment       = Enum.TextXAlignment.Left,
		ZIndex               = Z + 1,
	}, row)

	local valLabel = Util.New("TextLabel", {
		Text                 = Util.Round(value, decimal)..suffix,
		TextColor3           = T.Accent,
		Font                 = Enum.Font.GothamBold,
		TextSize             = 13,
		BackgroundTransparency = 1,
		Position             = UDim2.new(0.65, 0, 0, 0),
		Size                 = UDim2.new(0.35, 0, 0, 20),
		TextXAlignment       = Enum.TextXAlignment.Right,
		ZIndex               = Z + 1,
	}, row)

	-- Track background
	local trackWrap = Util.New("Frame", {
		BackgroundTransparency = 1,
		Position             = UDim2.new(0, 0, 0, 28),
		Size                 = UDim2.new(1, 0, 0, 18),
		ZIndex               = Z + 1,
	}, row)

	-- Center-align the track visually
	local track = Util.New("Frame", {
		Name             = "Track",
		AnchorPoint      = Vector2.new(0, 0.5),
		BackgroundColor3 = T.SliderTrack,
		Position         = UDim2.new(0, 0, 0.5, 0),
		Size             = UDim2.new(1, 0, 0, 6),
		BorderSizePixel  = 0,
		ZIndex           = Z + 2,
	}, trackWrap)
	Util.Corner(3, track)

	-- Fill
	local fillRel = (value - minV) / (maxV - minV)
	local fill = Util.New("Frame", {
		Name             = "Fill",
		BackgroundColor3 = T.SliderFill,
		Size             = UDim2.new(fillRel, 0, 1, 0),
		BorderSizePixel  = 0,
		ZIndex           = Z + 3,
	}, track)
	Util.Corner(3, fill)

	-- Glow on fill
	local fillGlow = Util.New("Frame", {
		BackgroundColor3     = T.SliderFill,
		BackgroundTransparency = 0.85,
		AnchorPoint          = Vector2.new(0, 0.5),
		Position             = UDim2.new(0, 0, 0.5, 0),
		Size                 = UDim2.new(fillRel, 0, 0, 12),
		BorderSizePixel      = 0,
		ZIndex               = Z + 2,
	}, track)
	Util.Corner(6, fillGlow)

	-- Knob
	local knobD = 16
	local knob  = Util.New("Frame", {
		Name             = "Knob",
		AnchorPoint      = Vector2.new(0.5, 0.5),
		Position         = UDim2.new(fillRel, 0, 0.5, 0),
		Size             = UDim2.new(0, knobD, 0, knobD),
		BackgroundColor3 = T.SliderKnob,
		BorderSizePixel  = 0,
		ZIndex           = Z + 4,
	}, track)
	Util.Corner(knobD / 2, knob)
	Util.Stroke(T.SliderKnobStroke, 2, 0, knob)
	Util.Shadow(knob, 1, 0.70, 8)

	-- Min/Max labels
	Util.New("TextLabel", {
		Text                 = tostring(minV),
		TextColor3           = T.TextDisabled,
		Font                 = Enum.Font.Gotham,
		TextSize             = 10,
		BackgroundTransparency = 1,
		Position             = UDim2.new(0, 0, 0, 10),
		Size                 = UDim2.new(0.5, 0, 0, 12),
		TextXAlignment       = Enum.TextXAlignment.Left,
		ZIndex               = Z + 1,
	}, trackWrap)

	Util.New("TextLabel", {
		Text                 = tostring(maxV),
		TextColor3           = T.TextDisabled,
		Font                 = Enum.Font.Gotham,
		TextSize             = 10,
		BackgroundTransparency = 1,
		Position             = UDim2.new(0.5, 0, 0, 10),
		Size                 = UDim2.new(0.5, 0, 0, 12),
		TextXAlignment       = Enum.TextXAlignment.Right,
		ZIndex               = Z + 1,
	}, trackWrap)

	local sliding = false

	local function applyValue(rel)
		rel   = Util.Clamp(rel, 0, 1)
		value = Util.Round(minV + rel * (maxV - minV), decimal)
		valLabel.Text = Util.Round(value, decimal)..suffix

		Util.Tween(fill,      { Size = UDim2.new(rel, 0, 1, 0) },       "Fast")
		Util.Tween(fillGlow,  { Size = UDim2.new(rel, 0, 0, 12) },      "Fast")
		Util.Tween(knob,      { Position = UDim2.new(rel, 0, 0.5, 0) }, "Fast")

		if flag and cfg then cfg:SetFlag(flag, value) end
		cb(value)
	end

	local function posToRel(x)
		return (x - track.AbsolutePosition.X) / track.AbsoluteSize.X
	end

	trackWrap.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = true
			applyValue(posToRel(i.Position.X))
			-- Scale knob up on drag
			Util.Tween(knob, { Size = UDim2.new(0, knobD + 4, 0, knobD + 4) }, "Fast")
		end
	end)
	track.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = true
			applyValue(posToRel(i.Position.X))
			Util.Tween(knob, { Size = UDim2.new(0, knobD + 4, 0, knobD + 4) }, "Fast")
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
			applyValue(posToRel(i.Position.X))
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 and sliding then
			sliding = false
			Util.Tween(knob, { Size = UDim2.new(0, knobD, 0, knobD) }, "Spring")
		end
	end)

	-- Hover on knob
	knob.MouseEnter:Connect(function()
		if not sliding then
			Util.Tween(knob, { Size = UDim2.new(0, knobD + 2, 0, knobD + 2) }, "Fast")
		end
	end)
	knob.MouseLeave:Connect(function()
		if not sliding then
			Util.Tween(knob, { Size = UDim2.new(0, knobD, 0, knobD) }, "Fast")
		end
	end)

	local ctrl = { Row = row }
	function ctrl:Set(v)
		value = Util.Clamp(v, minV, maxV)
		local rel = (value - minV) / (maxV - minV)
		valLabel.Text = Util.Round(value, decimal)..suffix
		fill.Size     = UDim2.new(rel, 0, 1, 0)
		fillGlow.Size = UDim2.new(rel, 0, 0, 12)
		knob.Position = UDim2.new(rel, 0, 0.5, 0)
		if flag and cfg then cfg:SetFlag(flag, value) end
		cb(value)
	end
	function ctrl:Get() return value end

	if savedVal ~= nil then cb(savedVal) end

	return ctrl
end

-- ─── DROPDOWN ─────────────────────────────────────────
function Controls.Dropdown(parent, opts, T, Z, cfg)
	opts       = opts or {}
	local name  = opts.Name    or "Dropdown"
	local flag  = opts.Flag
	local items = opts.Options or opts.Items or {}
	local multi = opts.Multi   or false
	local cb    = opts.Callback or function() end
	local searchEnabled = opts.Searchable ~= false and #items > 5

	local savedVal = flag and cfg and cfg:GetFlag(flag)
	local selected

	if multi then
		selected = savedVal or opts.Default or {}
		if type(selected) ~= "table" then selected = { selected } end
	else
		selected = savedVal or opts.Default or items[1]
	end

	if flag and cfg then cfg:RegisterFlag(flag, selected) end

	local isOpen  = false
	local wrapper = Util.New("Frame", {
		Name                 = "DD_"..name,
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 0, 62),
		LayoutOrder          = opts.Order or 0,
		ZIndex               = Z,
		ClipsDescendants     = false,
	}, parent)

	-- Label
	Util.New("TextLabel", {
		Text                 = name,
		TextColor3           = T.Text,
		Font                 = Enum.Font.GothamSemibold,
		TextSize             = 13,
		BackgroundTransparency = 1,
		Position             = UDim2.new(0, 0, 0, 0),
		Size                 = UDim2.new(1, 0, 0, 18),
		TextXAlignment       = Enum.TextXAlignment.Left,
		ZIndex               = Z + 1,
	}, wrapper)

	-- Box
	local box = Util.New("Frame", {
		Name             = "Box",
		BackgroundColor3 = T.InputBg,
		Position         = UDim2.new(0, 0, 0, 22),
		Size             = UDim2.new(1, 0, 0, 36),
		BorderSizePixel  = 0,
		ZIndex           = Z + 1,
		ClipsDescendants = false,
	}, wrapper)
	Util.Corner(9, box)
	local boxStroke = Util.Stroke(T.InputBorder, 1, 0.3, box)

	local function getDisplayText()
		if multi then
			if #selected == 0 then return "Select options..." end
			if #selected == 1 then return selected[1] end
			return selected[1] .. " +"..tostring(#selected - 1).." more"
		end
		return tostring(selected or "Select...")
	end

	local selectedLabel = Util.New("TextLabel", {
		Text             = getDisplayText(),
		TextColor3       = selected and T.InputText or T.InputPlaceholder,
		Font             = Enum.Font.Gotham,
		TextSize         = 12,
		BackgroundTransparency = 1,
		Position         = UDim2.new(0, 12, 0, 0),
		Size             = UDim2.new(1, -40, 1, 0),
		TextXAlignment   = Enum.TextXAlignment.Left,
		TextTruncate     = Enum.TextTruncate.AtEnd,
		ZIndex           = Z + 2,
	}, box)

	local arrow = Util.New("TextLabel", {
		Text             = Icons.chevronDown,
		TextColor3       = T.TextSecondary,
		Font             = Enum.Font.GothamBold,
		TextSize         = 14,
		BackgroundTransparency = 1,
		AnchorPoint      = Vector2.new(1, 0.5),
		Position         = UDim2.new(1, -10, 0.5, 0),
		Size             = UDim2.new(0, 22, 0, 22),
		ZIndex           = Z + 2,
	}, box)

	-- Dropdown list panel
	local panel = Util.New("Frame", {
		Name             = "Panel",
		BackgroundColor3 = T.DropdownBg,
		Position         = UDim2.new(0, 0, 1, 5),
		Size             = UDim2.new(1, 0, 0, 0),
		BorderSizePixel  = 0,
		ClipsDescendants = true,
		ZIndex           = Z + 30,
		Visible          = false,
	}, box)
	Util.Corner(9, panel)
	Util.Stroke(T.DropdownBorder, 1, 0.35, panel)
	Util.Shadow(panel, 6, 0.68, 16)

	-- Search bar inside panel
	local searchBar, searchInput
	if searchEnabled then
		searchBar = Util.New("Frame", {
			BackgroundColor3 = T.InputBg,
			Position         = UDim2.new(0, 6, 0, 6),
			Size             = UDim2.new(1, -12, 0, 28),
			BorderSizePixel  = 0,
			ZIndex           = Z + 32,
		}, panel)
		Util.Corner(7, searchBar)

		Util.New("TextLabel", {
			Text             = Icons.search,
			TextColor3       = T.TextSecondary,
			Font             = Enum.Font.Gotham,
			TextSize         = 12,
			BackgroundTransparency = 1,
			Position         = UDim2.new(0, 6, 0, 0),
			Size             = UDim2.new(0, 18, 1, 0),
			ZIndex           = Z + 33,
		}, searchBar)

		searchInput = Util.New("TextBox", {
			Text             = "",
			PlaceholderText  = "Search...",
			PlaceholderColor3= T.InputPlaceholder,
			TextColor3       = T.InputText,
			Font             = Enum.Font.Gotham,
			TextSize         = 11,
			BackgroundTransparency = 1,
			ClearTextOnFocus = false,
			Position         = UDim2.new(0, 26, 0, 0),
			Size             = UDim2.new(1, -32, 1, 0),
			ZIndex           = Z + 33,
		}, searchBar)
	end

	local listFrame = Util.New("ScrollingFrame", {
		Name             = "List",
		BackgroundTransparency = 1,
		Position         = searchEnabled
			and UDim2.new(0, 0, 0, 40) or UDim2.new(0, 0, 0, 4),
		Size             = UDim2.new(1, 0, 1, searchEnabled and -44 or -8),
		BorderSizePixel  = 0,
		ScrollBarImageColor3 = T.ScrollBar,
		ScrollBarThickness = 3,
		CanvasSize       = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex           = Z + 31,
	}, panel)
	Util.ListLayout(listFrame, { Padding = UDim.new(0, 2) })
	Util.Padding(4, 4, 5, 5, listFrame)

	local ITEM_H  = 30
	local MAX_VIS = 6

	local function isSelected(opt)
		if multi then return table.find(selected, opt) ~= nil
		else return selected == opt end
	end

	local function buildItems(filter)
		-- Clear existing items
		for _, c in ipairs(listFrame:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		local count = 0
		for _, opt in ipairs(items) do
			if not filter or opt:lower():find(filter:lower(), 1, true) then
				local sel = isSelected(opt)
				local item = Util.New("TextButton", {
					Text             = "",
					BackgroundColor3 = sel and T.DropdownItemActive or T.DropdownBg,
					Size             = UDim2.new(1, 0, 0, ITEM_H),
					BorderSizePixel  = 0,
					AutoButtonColor  = false,
					ZIndex           = Z + 32,
					LayoutOrder      = count,
				}, listFrame)
				Util.Corner(6, item)

				-- Check mark
				local checkL = Util.New("TextLabel", {
					Text             = sel and Icons.check or "",
					TextColor3       = T.Accent,
					Font             = Enum.Font.GothamBold,
					TextSize         = 11,
					BackgroundTransparency = 1,
					Position         = UDim2.new(0, 8, 0, 0),
					Size             = UDim2.new(0, 16, 1, 0),
					ZIndex           = Z + 33,
				}, item)

				Util.New("TextLabel", {
					Text             = opt,
					TextColor3       = sel and T.Accent or T.Text,
					Font             = Enum.Font.Gotham,
					TextSize         = 12,
					BackgroundTransparency = 1,
					Position         = UDim2.new(0, 28, 0, 0),
					Size             = UDim2.new(1, -36, 1, 0),
					TextXAlignment   = Enum.TextXAlignment.Left,
					ZIndex           = Z + 33,
				}, item)

				item.MouseEnter:Connect(function()
					if not isSelected(opt) then
						Util.Tween(item, { BackgroundColor3 = T.DropdownItemHover }, "Fast")
					end
				end)
				item.MouseLeave:Connect(function()
					Util.Tween(item, {
						BackgroundColor3 = isSelected(opt) and T.DropdownItemActive or T.DropdownBg,
					}, "Fast")
				end)
				item.MouseButton1Click:Connect(function()
					if multi then
						local idx = table.find(selected, opt)
						if idx then
							table.remove(selected, idx)
						else
							table.insert(selected, opt)
						end
						selectedLabel.Text  = getDisplayText()
						selectedLabel.TextColor3 = #selected > 0 and T.InputText or T.InputPlaceholder
						cb(selected)
						if flag and cfg then cfg:SetFlag(flag, selected) end
						buildItems(searchInput and searchInput.Text or nil)
					else
						selected = opt
						selectedLabel.Text       = opt
						selectedLabel.TextColor3 = T.InputText
						cb(opt)
						if flag and cfg then cfg:SetFlag(flag, opt) end
						-- Close
						isOpen = false
						Util.Tween(panel, { Size = UDim2.new(1, 0, 0, 0) }, "Normal")
						Util.Tween(arrow, { Rotation = 0 }, "Normal")
						Util.Tween(boxStroke, { Color = T.InputBorder }, "Fast")
						task.delay(0.25, function() panel.Visible = false end)
						if searchInput then searchInput.Text = "" end
					end
				end)

				count += 1
			end
		end
		return count
	end

	if searchInput then
		searchInput:GetPropertyChangedSignal("Text"):Connect(function()
			buildItems(searchInput.Text ~= "" and searchInput.Text or nil)
		end)
	end

	local function openPanel()
		isOpen = true
		panel.Visible = true
		panel.Size    = UDim2.new(1, 0, 0, 0)
		local count   = buildItems()
		local visCount= math.min(count, MAX_VIS)
		local topPad  = searchEnabled and 44 or 8
		local targetH = visCount * (ITEM_H + 2) + topPad + 8

		Util.Tween(panel, { Size = UDim2.new(1, 0, 0, targetH) }, "Normal")
		Util.Tween(arrow, { Rotation = 180 }, "Normal")
		Util.Tween(boxStroke, { Color = T.InputBorderFocus, Transparency = 0 }, "Fast")
		Util.Tween(box, { BackgroundColor3 = T.InputBgFocus }, "Fast")
	end

	local function closePanel()
		isOpen = false
		Util.Tween(panel, { Size = UDim2.new(1, 0, 0, 0) }, "Normal")
		Util.Tween(arrow, { Rotation = 0 }, "Normal")
		Util.Tween(boxStroke, { Color = T.InputBorder, Transparency = 0.3 }, "Fast")
		Util.Tween(box, { BackgroundColor3 = T.InputBg }, "Fast")
		task.delay(0.28, function()
			if not isOpen then
				panel.Visible = false
				if searchInput then searchInput.Text = "" end
			end
		end)
	end

	box.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			if isOpen then closePanel() else openPanel() end
		end
	end)
	box.MouseEnter:Connect(function()
		if not isOpen then
			Util.Tween(box, { BackgroundColor3 = T.InputBg:Lerp(Color3.new(1,1,1), 0.04) }, "Fast")
		end
	end)
	box.MouseLeave:Connect(function()
		if not isOpen then
			Util.Tween(box, { BackgroundColor3 = T.InputBg }, "Fast")
		end
	end)

	local ctrl = { Wrapper = wrapper }
	function ctrl:Set(v)
		selected = v
		selectedLabel.Text = getDisplayText()
		selectedLabel.TextColor3 = T.InputText
		if flag and cfg then cfg:SetFlag(flag, v) end
		cb(v)
	end
	function ctrl:Get() return selected end
	function ctrl:SetOptions(newOpts)
		items = newOpts
		if isOpen then buildItems() end
	end
	function ctrl:AddOption(opt)
		table.insert(items, opt)
		if isOpen then buildItems() end
	end
	function ctrl:RemoveOption(opt)
		local i = table.find(items, opt)
		if i then table.remove(items, i) end
		if isOpen then buildItems() end
	end

	if savedVal ~= nil then cb(savedVal) end

	return ctrl
end

-- ─── TEXTBOX ──────────────────────────────────────────
function Controls.Textbox(parent, opts, T, Z, cfg)
	opts     = opts or {}
	local name    = opts.Name or "Input"
	local flag    = opts.Flag
	local ph      = opts.Placeholder or ""
	local numeric = opts.Numeric or false
	local liveUpdate = opts.LiveUpdate or false
	local cb    = opts.Callback or function() end

	local savedVal = flag and cfg and cfg:GetFlag(flag)
	local defVal   = savedVal or opts.Default or ""

	if flag and cfg then cfg:RegisterFlag(flag, defVal) end

	local rowH = 58
	local row  = Util.New("Frame", {
		Name                 = "Textbox_"..name,
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 0, rowH),
		LayoutOrder          = opts.Order or 0,
		ZIndex               = Z,
	}, parent)

	Util.New("TextLabel", {
		Text                 = name,
		TextColor3           = T.Text,
		Font                 = Enum.Font.GothamSemibold,
		TextSize             = 13,
		BackgroundTransparency = 1,
		Position             = UDim2.new(0, 0, 0, 0),
		Size                 = UDim2.new(1, 0, 0, 18),
		TextXAlignment       = Enum.TextXAlignment.Left,
		ZIndex               = Z + 1,
	}, row)

	local inputBox = Util.New("Frame", {
		BackgroundColor3 = T.InputBg,
		Position         = UDim2.new(0, 0, 0, 22),
		Size             = UDim2.new(1, 0, 0, 32),
		BorderSizePixel  = 0,
		ZIndex           = Z + 1,
	}, row)
	Util.Corner(9, inputBox)
	local stroke = Util.Stroke(T.InputBorder, 1, 0.3, inputBox)

	local tb = Util.New("TextBox", {
		Text             = tostring(defVal),
		PlaceholderText  = ph,
		PlaceholderColor3= T.InputPlaceholder,
		TextColor3       = T.InputText,
		Font             = Enum.Font.Gotham,
		TextSize         = 12,
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Position         = UDim2.new(0, 12, 0, 0),
		Size             = UDim2.new(1, -24, 1, 0),
		ZIndex           = Z + 2,
	}, inputBox)

	tb.Focused:Connect(function()
		Util.Tween(stroke, { Color = T.InputBorderFocus, Transparency = 0 }, "Fast")
		Util.Tween(inputBox, { BackgroundColor3 = T.InputBgFocus }, "Fast")
	end)
	tb.FocusLost:Connect(function(enter)
		Util.Tween(stroke, { Color = T.InputBorder, Transparency = 0.3 }, "Fast")
		Util.Tween(inputBox, { BackgroundColor3 = T.InputBg }, "Fast")
		local val = numeric and tonumber(tb.Text) or tb.Text
		if enter then
			cb(val or tb.Text)
			if flag and cfg then cfg:SetFlag(flag, val or tb.Text) end
		end
	end)
	if liveUpdate then
		tb:GetPropertyChangedSignal("Text"):Connect(function()
			local val = numeric and tonumber(tb.Text) or tb.Text
			cb(val or tb.Text)
		end)
	end

	local ctrl = { Row = row }
	function ctrl:Set(v) tb.Text = tostring(v) end
	function ctrl:Get() return numeric and tonumber(tb.Text) or tb.Text end
	return ctrl
end

-- ─── KEYBIND ──────────────────────────────────────────
function Controls.Keybind(parent, opts, T, Z, cfg)
	opts     = opts or {}
	local name      = opts.Name or "Keybind"
	local flag      = opts.Flag
	local cb        = opts.Callback or function() end
	local changedCb = opts.Changed  or function() end

	local savedKey = flag and cfg and cfg:GetFlag(flag)
	local binding  = savedKey and Enum.KeyCode[savedKey] or (opts.Default or Enum.KeyCode.Unknown)
	local listening = false

	if flag and cfg then cfg:RegisterFlag(flag, binding.Name) end

	local row = Util.New("Frame", {
		Name                 = "Keybind_"..name,
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 0, 38),
		LayoutOrder          = opts.Order or 0,
		ZIndex               = Z,
	}, parent)

	Util.New("TextLabel", {
		Text                 = name,
		TextColor3           = T.Text,
		Font                 = Enum.Font.GothamSemibold,
		TextSize             = 13,
		BackgroundTransparency = 1,
		Position             = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint          = Vector2.new(0, 0.5),
		Size                 = UDim2.new(1, -96, 0, 20),
		TextXAlignment       = Enum.TextXAlignment.Left,
		ZIndex               = Z + 1,
	}, row)

	local keybtn = Util.New("TextButton", {
		Text             = binding.Name == "Unknown" and "None" or binding.Name,
		Font             = Enum.Font.GothamBold,
		TextSize         = 11,
		TextColor3       = T.Accent,
		BackgroundColor3 = T.InputBg,
		AnchorPoint      = Vector2.new(1, 0.5),
		Position         = UDim2.new(1, 0, 0.5, 0),
		Size             = UDim2.new(0, 88, 0, 28),
		BorderSizePixel  = 0,
		AutoButtonColor  = false,
		ZIndex           = Z + 1,
	}, row)
	Util.Corner(7, keybtn)
	local kStroke = Util.Stroke(T.InputBorder, 1, 0.3, keybtn)

	keybtn.MouseButton1Click:Connect(function()
		if listening then
			listening = false
			keybtn.Text = binding.Name == "Unknown" and "None" or binding.Name
			keybtn.TextColor3 = T.Accent
			Util.Tween(kStroke, { Color = T.InputBorder, Transparency = 0.3 }, "Fast")
		else
			listening = true
			keybtn.Text = "Press key..."
			keybtn.TextColor3 = T.TextSecondary
			Util.Tween(kStroke, { Color = T.InputBorderFocus, Transparency = 0 }, "Fast")
		end
	end)

	-- Right-click to clear
	keybtn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton2 then
			binding = Enum.KeyCode.Unknown
			keybtn.Text = "None"
			keybtn.TextColor3 = T.TextSecondary
			listening = false
			if flag and cfg then cfg:SetFlag(flag, "Unknown") end
			changedCb(binding)
		end
	end)

	UserInputService.InputBegan:Connect(function(inp, gp)
		if listening and not gp then
			if inp.UserInputType == Enum.UserInputType.Keyboard then
				binding        = inp.KeyCode
				listening      = false
				keybtn.Text    = binding.Name
				keybtn.TextColor3 = T.Accent
				Util.Tween(kStroke, { Color = T.InputBorder, Transparency = 0.3 }, "Fast")
				if flag and cfg then cfg:SetFlag(flag, binding.Name) end
				changedCb(binding)
			end
		elseif not gp and binding ~= Enum.KeyCode.Unknown then
			if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == binding then
				cb(binding)
			end
		end
	end)

	local ctrl = { Row = row }
	function ctrl:Get() return binding end
	function ctrl:Set(k)
		binding = k
		keybtn.Text = k.Name == "Unknown" and "None" or k.Name
	end
	return ctrl
end

-- ─── COLOR PICKER ─────────────────────────────────────
function Controls.ColorPicker(parent, opts, T, Z, cfg)
	opts     = opts or {}
	local name = opts.Name or "Color"
	local flag = opts.Flag
	local cb   = opts.Callback or function() end

	local savedColor = flag and cfg and cfg:GetFlag(flag)
	if savedColor and type(savedColor) == "table" then
		savedColor = Color3.fromRGB(savedColor.r or 255, savedColor.g or 255, savedColor.b or 255)
	end

	local color = savedColor or opts.Default or Color3.fromRGB(99, 102, 241)
	local h, s, v = Color3.toHSV(color)

	if flag and cfg then
		cfg:RegisterFlag(flag, { r = color.R*255, g = color.G*255, b = color.B*255 })
	end

	local isOpen = false

	local row = Util.New("Frame", {
		Name                 = "ColorPicker_"..name,
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 0, 38),
		LayoutOrder          = opts.Order or 0,
		ZIndex               = Z,
		ClipsDescendants     = false,
	}, parent)

	Util.New("TextLabel", {
		Text                 = name,
		TextColor3           = T.Text,
		Font                 = Enum.Font.GothamSemibold,
		TextSize             = 13,
		BackgroundTransparency = 1,
		Position             = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint          = Vector2.new(0, 0.5),
		Size                 = UDim2.new(1, -56, 0, 20),
		TextXAlignment       = Enum.TextXAlignment.Left,
		ZIndex               = Z + 1,
	}, row)

	-- Swatch
	local swatch = Util.New("TextButton", {
		Text             = "",
		BackgroundColor3 = color,
		AnchorPoint      = Vector2.new(1, 0.5),
		Position         = UDim2.new(1, 0, 0.5, 0),
		Size             = UDim2.new(0, 46, 0, 24),
		BorderSizePixel  = 0,
		AutoButtonColor  = false,
		ZIndex           = Z + 1,
		ClipsDescendants = false,
	}, row)
	Util.Corner(6, swatch)
	Util.Stroke(T.InputBorder, 1, 0.3, swatch)

	-- Checkerboard inside swatch (just a visual hint)
	local checker = Util.New("Frame", {
		BackgroundColor3 = Color3.fromRGB(180,180,180),
		Size             = UDim2.new(0.5, 0, 1, 0),
		BorderSizePixel  = 0,
		ZIndex           = Z,
	}, swatch)
	Util.Corner(6, checker)
	swatch.ZIndex = Z + 2

	-- Picker panel
	local PANEL_W = 220
	local PANEL_H = 240

	local picker = Util.New("Frame", {
		Name             = "Picker",
		BackgroundColor3 = T.DropdownBg,
		AnchorPoint      = Vector2.new(1, 0),
		Position         = UDim2.new(1, 4, 1, 6),
		Size             = UDim2.new(0, PANEL_W, 0, 0),
		BorderSizePixel  = 0,
		ClipsDescendants = true,
		ZIndex           = Z + 40,
		Visible          = false,
	}, row)
	Util.Corner(12, picker)
	Util.Stroke(T.DropdownBorder, 1, 0.3, picker)
	Util.Shadow(picker, 8, 0.65, 18)
	Util.Padding(12, 12, 12, 12, picker)

	local pickerLayout = Util.ListLayout(picker, { Padding = UDim.new(0, 8) })

	-- Hue bar
	local hueLabel = Util.New("TextLabel", {
		Text             = "Hue",
		TextColor3       = T.TextSecondary,
		Font             = Enum.Font.Gotham,
		TextSize         = 11,
		BackgroundTransparency = 1,
		Size             = UDim2.new(1, 0, 0, 14),
		TextXAlignment   = Enum.TextXAlignment.Left,
		ZIndex           = Z + 42,
	}, picker)

	local hueTrack = Util.New("Frame", {
		BackgroundColor3 = Color3.new(1,1,1),
		Size             = UDim2.new(1, 0, 0, 14),
		BorderSizePixel  = 0,
		ZIndex           = Z + 42,
	}, picker)
	Util.Corner(7, hueTrack)
	-- Rainbow gradient
	Util.New("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0.00, 1, 1)),
			ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
			ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
			ColorSequenceKeypoint.new(0.50, Color3.fromHSV(0.50, 1, 1)),
			ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
			ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
			ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1.00, 1, 1)),
		}),
	}, hueTrack)

	local hueKnob = Util.New("Frame", {
		AnchorPoint      = Vector2.new(0.5, 0.5),
		Position         = UDim2.new(h, 0, 0.5, 0),
		Size             = UDim2.new(0, 12, 0, 20),
		BackgroundColor3 = Color3.new(1,1,1),
		BorderSizePixel  = 0,
		ZIndex           = Z + 43,
	}, hueTrack)
	Util.Corner(3, hueKnob)
	Util.Stroke(Color3.new(0,0,0), 1, 0.5, hueKnob)

	-- Saturation bar
	Util.New("TextLabel", {
		Text             = "Saturation",
		TextColor3       = T.TextSecondary,
		Font             = Enum.Font.Gotham,
		TextSize         = 11,
		BackgroundTransparency = 1,
		Size             = UDim2.new(1, 0, 0, 14),
		TextXAlignment   = Enum.TextXAlignment.Left,
		ZIndex           = Z + 42,
	}, picker)

	local satTrack = Util.New("Frame", {
		BackgroundColor3 = Color3.new(1,1,1),
		Size             = UDim2.new(1, 0, 0, 14),
		BorderSizePixel  = 0,
		ZIndex           = Z + 42,
	}, picker)
	Util.Corner(7, satTrack)
	local satGrad = Util.New("UIGradient", {
		Color = ColorSequence.new(Color3.fromHSV(h, 0, 1), Color3.fromHSV(h, 1, 1)),
	}, satTrack)
	local satKnob = Util.New("Frame", {
		AnchorPoint      = Vector2.new(0.5, 0.5),
		Position         = UDim2.new(s, 0, 0.5, 0),
		Size             = UDim2.new(0, 12, 0, 20),
		BackgroundColor3 = Color3.new(1,1,1),
		BorderSizePixel  = 0,
		ZIndex           = Z + 43,
	}, satTrack)
	Util.Corner(3, satKnob)
	Util.Stroke(Color3.new(0,0,0), 1, 0.5, satKnob)

	-- Value/brightness bar
	Util.New("TextLabel", {
		Text             = "Brightness",
		TextColor3       = T.TextSecondary,
		Font             = Enum.Font.Gotham,
		TextSize         = 11,
		BackgroundTransparency = 1,
		Size             = UDim2.new(1, 0, 0, 14),
		TextXAlignment   = Enum.TextXAlignment.Left,
		ZIndex           = Z + 42,
	}, picker)

	local valTrack = Util.New("Frame", {
		BackgroundColor3 = Color3.new(1,1,1),
		Size             = UDim2.new(1, 0, 0, 14),
		BorderSizePixel  = 0,
		ZIndex           = Z + 42,
	}, picker)
	Util.Corner(7, valTrack)
	local valGrad = Util.New("UIGradient", {
		Color = ColorSequence.new(Color3.fromHSV(h, s, 0), Color3.fromHSV(h, s, 1)),
	}, valTrack)
	local valKnob = Util.New("Frame", {
		AnchorPoint      = Vector2.new(0.5, 0.5),
		Position         = UDim2.new(v, 0, 0.5, 0),
		Size             = UDim2.new(0, 12, 0, 20),
		BackgroundColor3 = Color3.new(1,1,1),
		BorderSizePixel  = 0,
		ZIndex           = Z + 43,
	}, valTrack)
	Util.Corner(3, valKnob)
	Util.Stroke(Color3.new(0,0,0), 1, 0.5, valKnob)

	-- Preview + Hex
	local previewRow = Util.New("Frame", {
		BackgroundTransparency = 1,
		Size                   = UDim2.new(1, 0, 0, 28),
		ZIndex                 = Z + 42,
	}, picker)

	local preview = Util.New("Frame", {
		BackgroundColor3 = color,
		Size             = UDim2.new(0, 28, 0, 28),
		BorderSizePixel  = 0,
		ZIndex           = Z + 43,
	}, previewRow)
	Util.Corner(6, preview)

	local hexInput = Util.New("TextBox", {
		Text             = string.format("#%02X%02X%02X",
			math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)),
		TextColor3       = T.InputText,
		Font             = Enum.Font.GothamBold,
		TextSize         = 11,
		BackgroundColor3 = T.InputBg,
		Position         = UDim2.new(0, 36, 0, 0),
		Size             = UDim2.new(1, -36, 1, 0),
		BorderSizePixel  = 0,
		ClearTextOnFocus = false,
		ZIndex           = Z + 43,
	}, previewRow)
	Util.Corner(7, hexInput)
	Util.Padding(0, 0, 8, 8, hexInput)

	local function updateColor()
		color = Color3.fromHSV(h, s, v)
		swatch.BackgroundColor3  = color
		preview.BackgroundColor3 = color
		hexInput.Text = string.format("#%02X%02X%02X",
			math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))

		satGrad.Color = ColorSequence.new(Color3.fromHSV(h, 0, v), Color3.fromHSV(h, 1, v))
		valGrad.Color = ColorSequence.new(Color3.fromHSV(h, s, 0), Color3.fromHSV(h, s, 1))

		hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
		satKnob.Position = UDim2.new(s, 0, 0.5, 0)
		valKnob.Position = UDim2.new(v, 0, 0.5, 0)

		if flag and cfg then
			cfg:SetFlag(flag, { r = math.floor(color.R*255), g = math.floor(color.G*255), b = math.floor(color.B*255) })
		end
		cb(color)
	end

	local function makeBarDrag(track, knob, onChange)
		local dragging = false
		track.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				local rel = Util.Clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				onChange(rel)
				updateColor()
			end
		end)
		UserInputService.InputChanged:Connect(function(i)
			if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
				local rel = Util.Clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				onChange(rel)
				updateColor()
			end
		end)
		UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
	end

	makeBarDrag(hueTrack, hueKnob, function(r) h = r end)
	makeBarDrag(satTrack, satKnob, function(r) s = r end)
	makeBarDrag(valTrack, valKnob, function(r) v = r end)

	hexInput.FocusLost:Connect(function(enter)
		if not enter then return end
		local hex = hexInput.Text:gsub("#", "")
		if #hex == 6 then
			local r = tonumber(hex:sub(1,2), 16)
			local g = tonumber(hex:sub(3,4), 16)
			local b = tonumber(hex:sub(5,6), 16)
			if r and g and b then
				color = Color3.fromRGB(r, g, b)
				h, s, v = Color3.toHSV(color)
				updateColor()
			end
		end
	end)

	swatch.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		if isOpen then
			picker.Visible = true
			Util.Tween(picker, { Size = UDim2.new(0, PANEL_W, 0, PANEL_H) }, "Normal")
		else
			Util.TweenCallback(picker, { Size = UDim2.new(0, PANEL_W, 0, 0) }, "Normal", function()
				picker.Visible = false
			end)
		end
	end)

	local ctrl = { Row = row }
	function ctrl:Set(c)
		color = c
		h, s, v = Color3.toHSV(c)
		updateColor()
	end
	function ctrl:Get() return color end
	return ctrl
end

-- ─── LABEL ────────────────────────────────────────────
function Controls.Label(parent, opts, T, Z)
	opts    = opts or {}
	local text  = opts.Text or opts.Name or ""
	local style = opts.Style or "secondary"  -- primary | secondary | accent

	local textColor = style == "primary" and T.Text
	               or style == "accent"  and T.Accent
	               or T.TextSecondary

	local label = Util.New("TextLabel", {
		Name                 = "Label",
		Text                 = text,
		TextColor3           = textColor,
		Font                 = style == "primary" and Enum.Font.GothamSemibold or Enum.Font.Gotham,
		TextSize             = style == "primary" and 13 or 12,
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 0, 0),
		AutomaticSize        = Enum.AutomaticSize.Y,
		TextXAlignment       = Enum.TextXAlignment.Left,
		TextWrapped          = true,
		LayoutOrder          = opts.Order or 0,
		ZIndex               = Z + 1,
	}, parent)

	local ctrl = { Label = label }
	function ctrl:Set(t) label.Text = t end
	function ctrl:Get() return label.Text end
	return ctrl
end

-- ─── DIVIDER ──────────────────────────────────────────
function Controls.Divider(parent, opts, T, Z)
	opts = opts or {}
	local label = opts.Label

	local wrapper = Util.New("Frame", {
		Name                 = "Divider",
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 0, label and 22 or 10),
		LayoutOrder          = opts.Order or 0,
		ZIndex               = Z,
	}, parent)

	if label then
		Util.New("TextLabel", {
			Text             = label,
			TextColor3       = T.TextDisabled,
			Font             = Enum.Font.GothamBold,
			TextSize         = 10,
			BackgroundTransparency = 1,
			Position         = UDim2.new(0, 0, 0, 0),
			Size             = UDim2.new(1, 0, 0, 14),
			TextXAlignment   = Enum.TextXAlignment.Left,
			ZIndex           = Z + 1,
		}, wrapper)
	end

	Util.New("Frame", {
		BackgroundColor3 = T.Divider,
		AnchorPoint      = Vector2.new(0, 1),
		Position         = UDim2.new(0, 0, 1, 0),
		Size             = UDim2.new(1, 0, 0, 1),
		BorderSizePixel  = 0,
		ZIndex           = Z + 1,
	}, wrapper)

	return { Wrapper = wrapper }
end

-- ─── SEARCH INPUT ─────────────────────────────────────
function Controls.SearchInput(parent, opts, T, Z)
	opts = opts or {}
	local cb = opts.Callback or function() end

	local wrapper = Util.New("Frame", {
		Name                 = "SearchInput",
		BackgroundColor3     = T.InputBg,
		Size                 = UDim2.new(1, 0, 0, 34),
		BorderSizePixel      = 0,
		LayoutOrder          = opts.Order or 0,
		ZIndex               = Z,
	}, parent)
	Util.Corner(9, wrapper)
	local stroke = Util.Stroke(T.InputBorder, 1, 0.3, wrapper)

	Util.New("TextLabel", {
		Text             = Icons.search,
		TextColor3       = T.TextSecondary,
		Font             = Enum.Font.Gotham,
		TextSize         = 14,
		BackgroundTransparency = 1,
		Position         = UDim2.new(0, 10, 0, 0),
		Size             = UDim2.new(0, 22, 1, 0),
		ZIndex           = Z + 1,
	}, wrapper)

	local input = Util.New("TextBox", {
		PlaceholderText  = opts.Placeholder or "Search...",
		PlaceholderColor3= T.InputPlaceholder,
		Text             = "",
		TextColor3       = T.InputText,
		Font             = Enum.Font.Gotham,
		TextSize         = 12,
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Position         = UDim2.new(0, 34, 0, 0),
		Size             = UDim2.new(1, -42, 1, 0),
		ZIndex           = Z + 1,
	}, wrapper)

	input.Focused:Connect(function()
		Util.Tween(stroke, { Color = T.InputBorderFocus, Transparency = 0 }, "Fast")
		Util.Tween(wrapper, { BackgroundColor3 = T.InputBgFocus }, "Fast")
	end)
	input.FocusLost:Connect(function()
		Util.Tween(stroke, { Color = T.InputBorder, Transparency = 0.3 }, "Fast")
		Util.Tween(wrapper, { BackgroundColor3 = T.InputBg }, "Fast")
	end)
	input:GetPropertyChangedSignal("Text"):Connect(function()
		cb(input.Text)
	end)

	return { Wrapper = wrapper, Input = input }
end

-- ─── PARAGRAPH ────────────────────────────────────────
function Controls.Paragraph(parent, opts, T, Z)
	opts = opts or {}
	local title = opts.Title
	local body  = opts.Body or opts.Text or ""

	local wrapper = Util.New("Frame", {
		Name                 = "Paragraph",
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 0, 0),
		AutomaticSize        = Enum.AutomaticSize.Y,
		LayoutOrder          = opts.Order or 0,
		ZIndex               = Z,
	}, parent)
	Util.ListLayout(wrapper, { Padding = UDim.new(0, 4) })

	if title then
		Util.New("TextLabel", {
			Text             = title,
			TextColor3       = T.Text,
			Font             = Enum.Font.GothamSemibold,
			TextSize         = 13,
			BackgroundTransparency = 1,
			Size             = UDim2.new(1, 0, 0, 0),
			AutomaticSize    = Enum.AutomaticSize.Y,
			TextXAlignment   = Enum.TextXAlignment.Left,
			TextWrapped      = true,
			ZIndex           = Z + 1,
		}, wrapper)
	end

	local bodyLabel = Util.New("TextLabel", {
		Text             = body,
		TextColor3       = T.TextSecondary,
		Font             = Enum.Font.Gotham,
		TextSize         = 12,
		BackgroundTransparency = 1,
		Size             = UDim2.new(1, 0, 0, 0),
		AutomaticSize    = Enum.AutomaticSize.Y,
		TextXAlignment   = Enum.TextXAlignment.Left,
		TextWrapped      = true,
		ZIndex           = Z + 1,
		LineHeight       = 1.4,
	}, wrapper)

	local ctrl = { Wrapper = wrapper, Body = bodyLabel }
	function ctrl:SetBody(t) bodyLabel.Text = t end
	return ctrl
end

-- ══════════════════════════════════════════════════════
--  7. CARD
-- ══════════════════════════════════════════════════════
local Card = {}
Card.__index = Card

function Card.new(parent, opts, T, Z)
	local self = setmetatable({}, Card)
	opts       = opts or {}
	self.T     = T
	self.Z     = Z or 10
	self._order = 0

	-- The card frame auto-sizes vertically
	self.Frame = Util.New("Frame", {
		Name                 = "Card_"..(opts.Title or ""),
		BackgroundColor3     = T.Card,
		Size                 = UDim2.new(1, 0, 0, 0),
		AutomaticSize        = Enum.AutomaticSize.Y,
		BorderSizePixel      = 0,
		ZIndex               = Z,
		LayoutOrder          = opts.LayoutOrder or 0,
	}, parent)
	Util.Corner(12, self.Frame)
	Util.Stroke(T.CardBorder, 1, 0.6, self.Frame)
	Util.Shadow(self.Frame, 4, 0.72, 18)

	-- Inner container with padding
	self.Inner = Util.New("Frame", {
		BackgroundTransparency = 1,
		Size                   = UDim2.new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		ZIndex                 = Z + 1,
	}, self.Frame)
	Util.Padding(14, 16, 16, 16, self.Inner)

	-- Controls list layout
	self.ControlList = Util.ListLayout(self.Inner, {
		Padding = UDim.new(0, 10),
	})

	-- Header section if title provided
	if opts.Title then
		local header = Util.New("Frame", {
			Name                 = "CardHeader",
			BackgroundTransparency = 1,
			Size                 = UDim2.new(1, 0, 0, 28),
			LayoutOrder          = -100,
			ZIndex               = Z + 2,
		}, self.Inner)
		Util.ListLayout(header, {
			Fill   = Enum.FillDirection.Horizontal,
			VAlign = Enum.VerticalAlignment.Center,
			Padding= UDim.new(0, 8),
		})

		-- Accent pill
		Util.New("Frame", {
			BackgroundColor3 = T.Accent,
			Size             = UDim2.new(0, 4, 0, 18),
			BorderSizePixel  = 0,
			LayoutOrder      = 0,
			ZIndex           = Z + 3,
		}, header):FindFirstChildOfClass("UICorner") or Util.Corner(2, header:GetChildren()[1] or header)

		local pill = header:GetChildren()[1]
		if pill then Util.Corner(2, pill) end

		Util.New("TextLabel", {
			Text             = opts.Title,
			TextColor3       = T.Text,
			Font             = Enum.Font.GothamBold,
			TextSize         = 14,
			BackgroundTransparency = 1,
			Size             = UDim2.new(0, 0, 1, 0),
			AutomaticSize    = Enum.AutomaticSize.X,
			TextXAlignment   = Enum.TextXAlignment.Left,
			LayoutOrder      = 1,
			ZIndex           = Z + 3,
		}, header)

		-- Description under title
		if opts.Description then
			local descLabel = Util.New("TextLabel", {
				Text             = opts.Description,
				TextColor3       = T.TextSecondary,
				Font             = Enum.Font.Gotham,
				TextSize         = 11,
				BackgroundTransparency = 1,
				Size             = UDim2.new(1, 0, 0, 14),
				LayoutOrder      = -99,
				TextXAlignment   = Enum.TextXAlignment.Left,
				ZIndex           = Z + 2,
			}, self.Inner)
		end

		-- Divider
		Util.New("Frame", {
			Name             = "CardDiv",
			BackgroundColor3 = T.Divider,
			Size             = UDim2.new(1, 0, 0, 1),
			BorderSizePixel  = 0,
			LayoutOrder      = -98,
			ZIndex           = Z + 2,
		}, self.Inner)
	end

	return self
end

function Card:_nextOrder()
	self._order += 1
	return self._order
end

function Card:AddToggle(opts)
	opts.Order = opts.Order or self:_nextOrder()
	return Controls.Toggle(self.Inner, opts, self.T, self.Z + 2, self._cfg)
end
function Card:AddButton(opts)
	opts.Order = opts.Order or self:_nextOrder()
	return Controls.Button(self.Inner, opts, self.T, self.Z + 2)
end
function Card:AddSlider(opts)
	opts.Order = opts.Order or self:_nextOrder()
	return Controls.Slider(self.Inner, opts, self.T, self.Z + 2, self._cfg)
end
function Card:AddDropdown(opts)
	opts.Order = opts.Order or self:_nextOrder()
	return Controls.Dropdown(self.Inner, opts, self.T, self.Z + 2, self._cfg)
end
function Card:AddTextbox(opts)
	opts.Order = opts.Order or self:_nextOrder()
	return Controls.Textbox(self.Inner, opts, self.T, self.Z + 2, self._cfg)
end
function Card:AddKeybind(opts)
	opts.Order = opts.Order or self:_nextOrder()
	return Controls.Keybind(self.Inner, opts, self.T, self.Z + 2, self._cfg)
end
function Card:AddColorPicker(opts)
	opts.Order = opts.Order or self:_nextOrder()
	return Controls.ColorPicker(self.Inner, opts, self.T, self.Z + 2, self._cfg)
end
function Card:AddLabel(opts)
	opts.Order = opts.Order or self:_nextOrder()
	return Controls.Label(self.Inner, opts, self.T, self.Z + 2)
end
function Card:AddDivider(opts)
	opts = opts or {}
	opts.Order = opts.Order or self:_nextOrder()
	return Controls.Divider(self.Inner, opts, self.T, self.Z + 2)
end
function Card:AddParagraph(opts)
	opts.Order = opts.Order or self:_nextOrder()
	return Controls.Paragraph(self.Inner, opts, self.T, self.Z + 2)
end
function Card:AddSearch(opts)
	opts.Order = opts.Order or self:_nextOrder()
	return Controls.SearchInput(self.Inner, opts, self.T, self.Z + 2)
end

-- ══════════════════════════════════════════════════════
--  8. MASONRY GRID (Two-column responsive layout)
-- ══════════════════════════════════════════════════════
local MasonryGrid = {}
MasonryGrid.__index = MasonryGrid

function MasonryGrid.new(parent, T, Z)
	local self      = setmetatable({}, MasonryGrid)
	self.T          = T
	self.Z          = Z or 10
	self.Cards      = {}
	self.CardCount  = 0

	-- The grid is a horizontal layout with two column frames
	self.Container = Util.New("Frame", {
		Name                 = "MasonryGrid",
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 0, 0),
		AutomaticSize        = Enum.AutomaticSize.Y,
		ZIndex               = Z,
	}, parent)

	Util.ListLayout(self.Container, {
		Fill    = Enum.FillDirection.Horizontal,
		HAlign  = Enum.HorizontalAlignment.Left,
		VAlign  = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 14),
	})

	-- Left column
	self.ColLeft = Util.New("Frame", {
		Name                 = "ColLeft",
		BackgroundTransparency = 1,
		Size                 = UDim2.new(0.5, -7, 0, 0),
		AutomaticSize        = Enum.AutomaticSize.Y,
		ZIndex               = Z,
	}, self.Container)
	Util.ListLayout(self.ColLeft, { Padding = UDim.new(0, 14) })

	-- Right column
	self.ColRight = Util.New("Frame", {
		Name                 = "ColRight",
		BackgroundTransparency = 1,
		Size                 = UDim2.new(0.5, -7, 0, 0),
		AutomaticSize        = Enum.AutomaticSize.Y,
		ZIndex               = Z,
	}, self.Container)
	Util.ListLayout(self.ColRight, { Padding = UDim.new(0, 14) })

	return self
end

function MasonryGrid:AddCard(opts, cfg)
	opts        = opts or {}
	self.CardCount += 1
	opts.LayoutOrder = opts.LayoutOrder or self.CardCount

	-- Alternate columns
	local col = (self.CardCount % 2 == 1) and self.ColLeft or self.ColRight

	-- If width override requested
	if opts.Width == "full" then
		-- Full width card needs its own single-col wrapper; just use left for simplicity
		col = self.ColLeft
	end

	local card = Card.new(col, opts, self.T, self.Z + 1)
	card._cfg   = cfg
	table.insert(self.Cards, card)
	return card
end

-- ══════════════════════════════════════════════════════
--  9. SUBTAB
-- ══════════════════════════════════════════════════════
local SubTab = {}
SubTab.__index = SubTab

function SubTab.new(name, T, Z, cfg)
	local self    = setmetatable({}, SubTab)
	self.Name     = name
	self.T        = T
	self.Z        = Z or 10
	self.CFG      = cfg

	-- Outer scrollable view
	self.Scroll = Util.New("ScrollingFrame", {
		Name                 = "SubTab_"..name,
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 1, 0),
		BorderSizePixel      = 0,
		ScrollBarImageColor3 = T.ScrollBar,
		ScrollBarThickness   = 4,
		ScrollBarImageTransparency = 0.4,
		CanvasSize           = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize  = Enum.AutomaticSize.Y,
		Visible              = false,
		ZIndex               = Z,
	})
	Util.Padding(16, 20, 16, 16, self.Scroll)

	-- Masonry grid inside scroll
	self.Grid = MasonryGrid.new(self.Scroll, T, Z + 1)

	return self
end

function SubTab:AddCard(opts)
	return self.Grid:AddCard(opts, self.CFG)
end

-- ══════════════════════════════════════════════════════
--  10. TAB
-- ══════════════════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Tab.new(opts, T, contentArea, Z, cfg)
	local self       = setmetatable({}, Tab)
	self.Name        = opts.Name or "Tab"
	self.Icon        = opts.Icon or "default"
	self.T           = T
	self.Z           = Z or 10
	self.CFG         = cfg
	self.SubTabs     = {}
	self.ActiveSubTab = nil

	-- Tab container (full content area)
	self.Container = Util.New("Frame", {
		Name                 = "TabContainer_"..self.Name,
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 1, 0),
		Visible              = false,
		ZIndex               = Z,
	}, contentArea)

	-- SubTab bar
	self.SubBar = Util.New("Frame", {
		Name             = "SubBar",
		BackgroundColor3 = T.Header,
		Size             = UDim2.new(1, 0, 0, 0),
		BorderSizePixel  = 0,
		ClipsDescendants = true,
		ZIndex           = Z + 1,
	}, self.Container)

	Util.Stroke(T.HeaderBorder, 1, 0.7, self.SubBar)

	local subBarLayout = Util.ListLayout(self.SubBar, {
		Fill   = Enum.FillDirection.Horizontal,
		VAlign = Enum.VerticalAlignment.Center,
		Padding= UDim.new(0, 6),
	})
	Util.Padding(0, 0, 14, 14, self.SubBar)

	-- Content host (below subbar)
	self.SubContent = Util.New("Frame", {
		Name                 = "SubContent",
		BackgroundTransparency = 1,
		Position             = UDim2.new(0, 0, 0, 0),
		Size                 = UDim2.new(1, 0, 1, 0),
		ZIndex               = Z + 1,
	}, self.Container)

	-- Active subtab underline indicator
	self.SubIndicator = Util.New("Frame", {
		Name             = "SubIndicator",
		BackgroundColor3 = T.Accent,
		AnchorPoint      = Vector2.new(0, 1),
		Position         = UDim2.new(0, 14, 0, 0),
		Size             = UDim2.new(0, 60, 0, 2),
		BorderSizePixel  = 0,
		ZIndex           = Z + 3,
		Visible          = false,
	}, self.SubBar)
	Util.Corner(1, self.SubIndicator)

	return self
end

function Tab:_updateSubContentBounds(hasSubBar)
	local h = hasSubBar and 46 or 0
	Util.Tween(self.SubBar, { Size = UDim2.new(1, 0, 0, h) }, "Normal")
	self.SubContent.Position = UDim2.new(0, 0, 0, h)
	self.SubContent.Size     = UDim2.new(1, 0, 1, -h)
end

function Tab:AddSubTab(name)
	local st = SubTab.new(name, self.T, self.Z + 2, self.CFG)
	st.Scroll.Parent = self.SubContent
	table.insert(self.SubTabs, st)

	-- Show subbar
	self:_updateSubContentBounds(true)

	-- Pill button
	local btn = Util.New("TextButton", {
		Name             = "STBtn_"..name,
		Text             = name,
		Font             = Enum.Font.GothamSemibold,
		TextSize         = 12,
		TextColor3       = self.T.SubTabInactiveText,
		BackgroundColor3 = self.T.SubTabInactive,
		BackgroundTransparency = 0.6,
		Size             = UDim2.new(0, 0, 0, 28),
		AutomaticSize    = Enum.AutomaticSize.X,
		BorderSizePixel  = 0,
		AutoButtonColor  = false,
		ZIndex           = self.Z + 2,
	}, self.SubBar)
	Util.Corner(14, btn)  -- fully pill-shaped
	Util.Padding(0, 0, 14, 14, btn)

	st.Button = btn

	btn.MouseButton1Click:Connect(function()
		self:SelectSubTab(st)
	end)
	btn.MouseEnter:Connect(function()
		if self.ActiveSubTab ~= st then
			Util.Tween(btn, { BackgroundTransparency = 0.4 }, "Fast")
		end
	end)
	btn.MouseLeave:Connect(function()
		if self.ActiveSubTab ~= st then
			Util.Tween(btn, { BackgroundTransparency = 0.6 }, "Fast")
		end
	end)

	-- Auto-select first
	if #self.SubTabs == 1 then
		task.defer(function() self:SelectSubTab(st) end)
	end

	return st
end

function Tab:SelectSubTab(st)
	if self.ActiveSubTab == st then return end

	if self.ActiveSubTab then
		self.ActiveSubTab.Scroll.Visible = false
		Util.Tween(self.ActiveSubTab.Button, {
			BackgroundColor3     = self.T.SubTabInactive,
			TextColor3           = self.T.SubTabInactiveText,
			BackgroundTransparency = 0.6,
		}, "Fast")
	end

	self.ActiveSubTab = st
	st.Scroll.Visible = true

	Util.Tween(st.Button, {
		BackgroundColor3     = self.T.SubTabActive,
		TextColor3           = self.T.TextOnAccent,
		BackgroundTransparency = 0,
	}, "Fast")

	-- Slide indicator under active button
	task.wait()  -- let button position update
	local btnPos = st.Button.AbsolutePosition.X - self.SubBar.AbsolutePosition.X
	local btnW   = st.Button.AbsoluteSize.X
	self.SubIndicator.Visible = true
	Util.Tween(self.SubIndicator, {
		Position = UDim2.new(0, btnPos, 0, 0),
		Size     = UDim2.new(0, btnW, 0, 2),
	}, "Normal")
end

-- Subtab-less card adding: first subtab is created automatically
function Tab:AddCard(opts)
	if #self.SubTabs == 0 then
		self:AddSubTab("Main")
	end
	return self.SubTabs[1]:AddCard(opts)
end

-- ══════════════════════════════════════════════════════
--  11. SIDEBAR
-- ══════════════════════════════════════════════════════
local SIDEBAR_COLLAPSED = 72
local SIDEBAR_EXPANDED  = 200

local Sidebar = {}
Sidebar.__index = Sidebar

function Sidebar.new(parent, T, Z, win)
	local self       = setmetatable({}, Sidebar)
	self.T           = T
	self.Z           = Z
	self.Win         = win
	self.Expanded    = true
	self.Tabs        = {}
	self.ActiveTab   = nil

	-- Sidebar frame
	self.Frame = Util.New("Frame", {
		Name             = "Sidebar",
		BackgroundColor3 = T.Sidebar,
		Size             = UDim2.new(0, SIDEBAR_EXPANDED, 1, 0),
		BorderSizePixel  = 0,
		ZIndex           = Z,
		ClipsDescendants = true,
	}, parent)

	-- Right border line
	Util.New("Frame", {
		Name             = "Border",
		BackgroundColor3 = T.SidebarBorder,
		AnchorPoint      = Vector2.new(1, 0),
		Position         = UDim2.new(1, 0, 0, 0),
		Size             = UDim2.new(0, 1, 1, 0),
		BorderSizePixel  = 0,
		ZIndex           = Z + 1,
	}, self.Frame)

	-- ── Logo area ──────────────────────────────────────
	self.LogoArea = Util.New("Frame", {
		Name                 = "LogoArea",
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 0, 62),
		ZIndex               = Z + 1,
	}, self.Frame)

	-- Accent dot / logo icon
	self.LogoDot = Util.New("Frame", {
		Name             = "Dot",
		BackgroundColor3 = T.Accent,
		Position         = UDim2.new(0, 20, 0.5, -10),
		Size             = UDim2.new(0, 20, 0, 20),
		BorderSizePixel  = 0,
		ZIndex           = Z + 2,
	}, self.LogoArea)
	Util.Corner(10, self.LogoDot)
	Util.Shadow(self.LogoDot, 0, 0.65, 8)

	-- Glow ring around dot
	Util.New("Frame", {
		BackgroundColor3     = T.Accent,
		BackgroundTransparency = 0.80,
		AnchorPoint          = Vector2.new(0.5, 0.5),
		Position             = UDim2.new(0.5, 0, 0.5, 0),
		Size                 = UDim2.new(0, 30, 0, 30),
		BorderSizePixel      = 0,
		ZIndex               = Z + 1,
	}, self.LogoDot)
	Util.Corner(15, self.LogoDot:GetChildren()[2] or self.LogoDot)

	self.TitleLabel = Util.New("TextLabel", {
		Name             = "Title",
		Text             = "App",
		TextColor3       = T.Text,
		Font             = Enum.Font.GothamBold,
		TextSize         = 15,
		BackgroundTransparency = 1,
		Position         = UDim2.new(0, 50, 0.5, -10),
		Size             = UDim2.new(1, -70, 0, 20),
		TextXAlignment   = Enum.TextXAlignment.Left,
		ZIndex           = Z + 2,
	}, self.LogoArea)

	self.SubtitleLabel = Util.New("TextLabel", {
		Name             = "Subtitle",
		Text             = "",
		TextColor3       = T.Accent,
		Font             = Enum.Font.Gotham,
		TextSize         = 10,
		BackgroundTransparency = 1,
		Position         = UDim2.new(0, 50, 0.5, 10),
		Size             = UDim2.new(1, -70, 0, 14),
		TextXAlignment   = Enum.TextXAlignment.Left,
		ZIndex           = Z + 2,
	}, self.LogoArea)

	-- Divider under logo
	Util.New("Frame", {
		BackgroundColor3 = T.SidebarBorder,
		Position         = UDim2.new(0, 12, 0, 60),
		Size             = UDim2.new(1, -24, 0, 1),
		BorderSizePixel  = 0,
		ZIndex           = Z + 1,
	}, self.Frame)

	-- ── Tab list ───────────────────────────────────────
	self.TabList = Util.New("Frame", {
		Name                 = "TabList",
		BackgroundTransparency = 1,
		Position             = UDim2.new(0, 0, 0, 68),
		Size                 = UDim2.new(1, 0, 1, -140),
		ZIndex               = Z + 1,
		ClipsDescendants     = false,
	}, self.Frame)
	Util.ListLayout(self.TabList, { Padding = UDim.new(0, 2) })
	Util.Padding(6, 6, 8, 8, self.TabList)

	-- Active bar (left accent strip)
	self.ActiveBar = Util.New("Frame", {
		Name             = "ActiveBar",
		BackgroundColor3 = T.Accent,
		Position         = UDim2.new(0, 0, 0, 0),
		Size             = UDim2.new(0, 3, 0, 20),
		BorderSizePixel  = 0,
		Visible          = false,
		ZIndex           = Z + 5,
	}, self.Frame)
	Util.Corner(2, self.ActiveBar)

	-- Active bar glow
	self.ActiveBarGlow = Util.New("Frame", {
		BackgroundColor3     = T.Accent,
		BackgroundTransparency = 0.85,
		Position             = UDim2.new(0, 0, 0, 0),
		Size                 = UDim2.new(0, 8, 0, 28),
		BorderSizePixel      = 0,
		Visible              = false,
		ZIndex               = Z + 4,
	}, self.Frame)
	Util.Corner(4, self.ActiveBarGlow)

	-- ── Footer area ────────────────────────────────────
	self.Footer = Util.New("Frame", {
		Name                 = "Footer",
		BackgroundTransparency = 1,
		AnchorPoint          = Vector2.new(0, 1),
		Position             = UDim2.new(0, 0, 1, -8),
		Size                 = UDim2.new(1, 0, 0, 64),
		ZIndex               = Z + 1,
	}, self.Frame)

	-- Divider above footer
	Util.New("Frame", {
		BackgroundColor3 = T.SidebarBorder,
		Position         = UDim2.new(0, 12, 0, 0),
		Size             = UDim2.new(1, -24, 0, 1),
		BorderSizePixel  = 0,
		ZIndex           = Z + 1,
	}, self.Footer)

	-- Collapse/Expand toggle button in footer
	self.CollapseBtn = Util.New("TextButton", {
		Text             = "",
		BackgroundColor3 = T.TabHoverBg,
		BackgroundTransparency = 1,
		Position         = UDim2.new(0, 8, 0, 10),
		Size             = UDim2.new(1, -16, 0, 34),
		BorderSizePixel  = 0,
		AutoButtonColor  = false,
		ZIndex           = Z + 2,
	}, self.Footer)
	Util.Corner(9, self.CollapseBtn)

	self.CollapseIcon = Util.New("TextLabel", {
		Text             = Icons.collapse,
		TextColor3       = T.TextSecondary,
		Font             = Enum.Font.GothamBold,
		TextSize         = 16,
		BackgroundTransparency = 1,
		Position         = UDim2.new(0, 0, 0, 0),
		Size             = UDim2.new(0, SIDEBAR_COLLAPSED - 16, 1, 0),
		ZIndex           = Z + 3,
	}, self.CollapseBtn)

	self.CollapseText = Util.New("TextLabel", {
		Text             = "Collapse",
		TextColor3       = T.TextSecondary,
		Font             = Enum.Font.Gotham,
		TextSize         = 12,
		BackgroundTransparency = 1,
		Position         = UDim2.new(0, SIDEBAR_COLLAPSED - 16, 0, 0),
		Size             = UDim2.new(1, -(SIDEBAR_COLLAPSED - 16), 1, 0),
		TextXAlignment   = Enum.TextXAlignment.Left,
		ZIndex           = Z + 3,
	}, self.CollapseBtn)

	self.CollapseBtn.MouseEnter:Connect(function()
		Util.Tween(self.CollapseBtn, { BackgroundTransparency = 0 }, "Fast")
	end)
	self.CollapseBtn.MouseLeave:Connect(function()
		Util.Tween(self.CollapseBtn, { BackgroundTransparency = 1 }, "Fast")
	end)
	self.CollapseBtn.MouseButton1Click:Connect(function()
		self:ToggleCollapse()
	end)

	return self
end

function Sidebar:AddTabButton(tab, order)
	local T   = self.T
	local btn = Util.New("TextButton", {
		Name                 = "TabBtn_"..tab.Name,
		Text                 = "",
		BackgroundColor3     = T.TabHoverBg,
		BackgroundTransparency = 1,
		Size                 = UDim2.new(1, 0, 0, 40),
		BorderSizePixel      = 0,
		AutoButtonColor      = false,
		LayoutOrder          = order,
		ZIndex               = self.Z + 2,
	}, self.TabList)
	Util.Corner(9, btn)

	-- Icon
	local iconL = Util.New("TextLabel", {
		Text             = getIcon(tab.Icon),
		TextColor3       = T.TextSecondary,
		Font             = Enum.Font.GothamBold,
		TextSize         = 16,
		BackgroundTransparency = 1,
		AnchorPoint      = Vector2.new(0, 0.5),
		Position         = UDim2.new(0, 12, 0.5, 0),
		Size             = UDim2.new(0, 24, 0, 24),
		ZIndex           = self.Z + 3,
	}, btn)

	-- Name label (hidden when collapsed)
	local nameL = Util.New("TextLabel", {
		Text             = tab.Name,
		TextColor3       = T.TextSecondary,
		Font             = Enum.Font.GothamSemibold,
		TextSize         = 13,
		BackgroundTransparency = 1,
		Position         = UDim2.new(0, 46, 0, 0),
		Size             = UDim2.new(1, -54, 1, 0),
		TextXAlignment   = Enum.TextXAlignment.Left,
		TextTruncate     = Enum.TextTruncate.AtEnd,
		ZIndex           = self.Z + 3,
	}, btn)

	-- Tooltip (shown when collapsed)
	local tooltip = Util.New("Frame", {
		BackgroundColor3 = T.DropdownBg,
		Position         = UDim2.new(1, 8, 0.5, 0),
		AnchorPoint      = Vector2.new(0, 0.5),
		Size             = UDim2.new(0, 0, 0, 28),
		BorderSizePixel  = 0,
		ClipsDescendants = true,
		ZIndex           = self.Z + 20,
		Visible          = false,
	}, btn)
	Util.Corner(7, tooltip)
	Util.Stroke(T.DropdownBorder, 1, 0.3, tooltip)
	Util.New("TextLabel", {
		Text             = tab.Name,
		TextColor3       = T.Text,
		Font             = Enum.Font.GothamSemibold,
		TextSize         = 12,
		BackgroundTransparency = 1,
		Position         = UDim2.new(0, 10, 0, 0),
		Size             = UDim2.new(0, 120, 1, 0),
		TextXAlignment   = Enum.TextXAlignment.Left,
		ZIndex           = self.Z + 21,
	}, tooltip)

	tab._sideBtn     = btn
	tab._sideIcon    = iconL
	tab._sideName    = nameL
	tab._sideTooltip = tooltip

	btn.MouseButton1Click:Connect(function()
		self.Win:SelectTab(tab)
	end)
	btn.MouseEnter:Connect(function()
		if self.ActiveTab ~= tab then
			Util.Tween(btn, { BackgroundTransparency = 0 }, "Fast")
			Util.Tween(iconL, { TextColor3 = T.Text }, "Fast")
		end
		if not self.Expanded then
			-- Show tooltip
			local tw = TextService:GetTextSize(tab.Name, 12, Enum.Font.GothamSemibold, Vector2.new(9999,9999))
			tooltip.Visible = true
			tooltip.Size    = UDim2.new(0, 0, 0, 28)
			Util.Tween(tooltip, { Size = UDim2.new(0, tw.X + 20, 0, 28) }, "Fast")
		end
	end)
	btn.MouseLeave:Connect(function()
		if self.ActiveTab ~= tab then
			Util.Tween(btn, { BackgroundTransparency = 1 }, "Fast")
			Util.Tween(iconL, { TextColor3 = T.TextSecondary }, "Fast")
		end
		Util.Tween(tooltip, { Size = UDim2.new(0, 0, 0, 28) }, "Fast")
		task.delay(0.22, function() tooltip.Visible = false end)
	end)

	return btn
end

function Sidebar:SelectTab(tab)
	if self.ActiveTab == tab then return end

	if self.ActiveTab then
		Util.Tween(self.ActiveTab._sideBtn,  { BackgroundTransparency = 1 }, "Fast")
		Util.Tween(self.ActiveTab._sideIcon, { TextColor3 = self.T.TextSecondary }, "Fast")
		Util.Tween(self.ActiveTab._sideName, { TextColor3 = self.T.TextSecondary }, "Fast")
	end

	self.ActiveTab = tab

	Util.Tween(tab._sideBtn,  { BackgroundColor3 = self.T.TabActiveBg, BackgroundTransparency = 0 }, "Fast")
	Util.Tween(tab._sideIcon, { TextColor3 = self.T.Accent }, "Fast")
	Util.Tween(tab._sideName, { TextColor3 = self.T.Text   }, "Fast")

	-- Animate active bar
	task.wait()
	local btnY = tab._sideBtn.AbsolutePosition.Y - self.Frame.AbsolutePosition.Y
	local btnH = tab._sideBtn.AbsoluteSize.Y

	self.ActiveBar.Visible     = true
	self.ActiveBarGlow.Visible = true

	Util.Tween(self.ActiveBar, {
		Position = UDim2.new(0, 0, 0, btnY + btnH/2 - 10),
		Size     = UDim2.new(0, 3, 0, 20),
	}, "Normal")
	Util.Tween(self.ActiveBarGlow, {
		Position = UDim2.new(0, 0, 0, btnY + btnH/2 - 14),
		Size     = UDim2.new(0, 8, 0, 28),
	}, "Normal")
end

function Sidebar:ToggleCollapse()
	self.Expanded = not self.Expanded
	local w = self.Expanded and SIDEBAR_EXPANDED or SIDEBAR_COLLAPSED

	Util.Tween(self.Frame, { Size = UDim2.new(0, w, 1, 0) }, "Normal")
	Util.Tween(self.Win.Content, {
		Position = UDim2.new(0, w, 0, 0),
		Size     = UDim2.new(1, -w, 1, 0),
	}, "Normal")

	-- Show/hide text elements
	if self.Expanded then
		self.TitleLabel.Visible    = true
		self.SubtitleLabel.Visible = true
		self.CollapseText.Visible  = true
		self.CollapseIcon.Text     = Icons.collapse
	else
		task.delay(0.18, function()
			self.TitleLabel.Visible    = false
			self.SubtitleLabel.Visible = false
			self.CollapseText.Visible  = false
		end)
		self.CollapseIcon.Text = Icons.expand
	end

	-- Fade name labels
	for _, t in ipairs(self.Tabs) do
		if t._sideName then
			Util.Tween(t._sideName, {
				TextTransparency = self.Expanded and 0 or 1,
			}, "Fast")
		end
	end
end

-- ══════════════════════════════════════════════════════
--  12. WINDOW
-- ══════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

function Window.new(opts, theme)
	local self       = setmetatable({}, Window)
	opts             = opts or {}
	self.T           = theme
	self.Tabs        = {}
	self.ActiveTab   = nil
	self.Z           = 10
	self._minimized  = false
	self._closed     = false

	-- Config system
	self.CFG = ConfigSystem.new(opts.ConfigurationSaving)
	if opts.ConfigurationSaving and opts.ConfigurationSaving.Enabled then
		self.CFG:Load()
	end

	local title    = opts.Title    or "NexusUI"
	local subtitle = opts.SubTitle or opts.Subtitle or ""
	local size     = opts.Size     or UDim2.new(0, 810, 0, 540)
	local center   = opts.Center   ~= false

	self._origSize = size

	-- ── Screen GUI ─────────────────────────────────────
	local sGui = Instance.new("ScreenGui")
	sGui.Name            = "NexusUI"
	sGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
	sGui.ResetOnSpawn    = false
	sGui.IgnoreGuiInset  = true

	if getHUI then
		pcall(function() sGui.Parent = getHUI() end)
	end
	if not sGui.Parent then
		pcall(function() sGui.Parent = CoreGui end)
	end
	if not sGui.Parent then
		sGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
	self.ScreenGui = sGui

	-- Optional blur
	if opts.BlurBackground then
		local blur = Instance.new("BlurEffect")
		blur.Size   = 0
		blur.Parent = game:GetService("Lighting")
		self._blur  = blur
		Util.Tween(blur, { Size = 8 }, "Slow")
	end

	-- Notification system
	self.Notif = NotifSystem.new(sGui, theme)

	-- ── Main window frame ──────────────────────────────
	self.MainFrame = Util.New("Frame", {
		Name             = "NexusWindow",
		BackgroundColor3 = theme.Background,
		AnchorPoint      = center and Vector2.new(0.5, 0.5) or Vector2.new(0,0),
		Position         = center and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.05, 0, 0.1, 0),
		Size             = size,
		BorderSizePixel  = 0,
		ZIndex           = self.Z,
		ClipsDescendants = true,
	}, sGui)
	Util.Corner(14, self.MainFrame)
	Util.Stroke(theme.SidebarBorder, 1, 0.5, self.MainFrame)
	Util.Shadow(self.MainFrame, 8, 0.50, 40)

	-- Opening animation
	self.MainFrame.BackgroundTransparency = 1
	self.MainFrame.Size = UDim2.new(
		size.X.Scale, size.X.Offset * 0.92,
		size.Y.Scale, size.Y.Offset * 0.92
	)
	Util.Tween(self.MainFrame, {
		BackgroundTransparency = 0,
		Size = size,
	}, "Spring")

	-- ── Sidebar ────────────────────────────────────────
	self.SidebarObj = Sidebar.new(self.MainFrame, theme, self.Z + 1, self)
	self.SidebarObj.TitleLabel.Text    = title
	self.SidebarObj.SubtitleLabel.Text = subtitle

	-- ── Content area ───────────────────────────────────
	self.Content = Util.New("Frame", {
		Name                 = "Content",
		BackgroundTransparency = 1,
		Position             = UDim2.new(0, SIDEBAR_EXPANDED, 0, 0),
		Size                 = UDim2.new(1, -SIDEBAR_EXPANDED, 1, 0),
		ZIndex               = self.Z + 1,
	}, self.MainFrame)

	-- ── Top bar ────────────────────────────────────────
	self.TopBar = Util.New("Frame", {
		Name             = "TopBar",
		BackgroundColor3 = theme.Header,
		Size             = UDim2.new(1, 0, 0, 48),
		BorderSizePixel  = 0,
		ZIndex           = self.Z + 2,
	}, self.Content)
	Util.Stroke(theme.HeaderBorder, 1, 0.7, self.TopBar)

	-- Bottom-left & bottom-right corner repair (make only top corners rounded by the window)
	Util.New("Frame", {
		BackgroundColor3 = theme.Background,
		Position         = UDim2.new(0, 0, 1, -1),
		Size             = UDim2.new(1, 0, 0, 1),
		BorderSizePixel  = 0,
		ZIndex           = self.Z + 2,
	}, self.TopBar)

	-- Current tab breadcrumb
	self.BreadcrumbFrame = Util.New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 0),
		Size     = UDim2.new(0.6, 0, 1, 0),
		ZIndex   = self.Z + 3,
	}, self.TopBar)
	Util.ListLayout(self.BreadcrumbFrame, {
		Fill   = Enum.FillDirection.Horizontal,
		VAlign = Enum.VerticalAlignment.Center,
		Padding= UDim.new(0, 6),
	})

	self.BreadcrumbIcon = Util.New("TextLabel", {
		Text             = "",
		TextColor3       = theme.Accent,
		Font             = Enum.Font.GothamBold,
		TextSize         = 16,
		BackgroundTransparency = 1,
		Size             = UDim2.new(0, 22, 0, 22),
		ZIndex           = self.Z + 4,
	}, self.BreadcrumbFrame)

	self.BreadcrumbText = Util.New("TextLabel", {
		Text             = title,
		TextColor3       = theme.Text,
		Font             = Enum.Font.GothamBold,
		TextSize         = 14,
		BackgroundTransparency = 1,
		Size             = UDim2.new(0, 0, 0, 22),
		AutomaticSize    = Enum.AutomaticSize.X,
		TextXAlignment   = Enum.TextXAlignment.Left,
		ZIndex           = self.Z + 4,
	}, self.BreadcrumbFrame)

	-- Window controls (top-right)
	local ctrlFrame = Util.New("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint      = Vector2.new(1, 0.5),
		Position         = UDim2.new(1, -12, 0.5, 0),
		Size             = UDim2.new(0, 80, 0, 32),
		ZIndex           = self.Z + 3,
	}, self.TopBar)
	Util.ListLayout(ctrlFrame, {
		Fill    = Enum.FillDirection.Horizontal,
		HAlign  = Enum.HorizontalAlignment.Right,
		VAlign  = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
	})

	local function makeCtrl(icon, bg, hoverBg, action)
		local b = Util.New("TextButton", {
			Text             = icon,
			Font             = Enum.Font.GothamBold,
			TextSize         = 12,
			TextColor3       = Color3.fromRGB(200, 200, 210),
			BackgroundColor3 = bg,
			Size             = UDim2.new(0, 28, 0, 28),
			BorderSizePixel  = 0,
			AutoButtonColor  = false,
			ZIndex           = self.Z + 4,
		}, ctrlFrame)
		Util.Corner(8, b)
		b.MouseEnter:Connect(function()
			Util.Tween(b, { BackgroundColor3 = hoverBg }, "Fast")
		end)
		b.MouseLeave:Connect(function()
			Util.Tween(b, { BackgroundColor3 = bg }, "Fast")
		end)
		b.MouseButton1Click:Connect(function()
			Util.Ripple(b)
			action()
		end)
		return b
	end

	makeCtrl("—", Color3.fromRGB(40,40,56), Color3.fromRGB(55,55,75), function()
		self:SetMinimized(not self._minimized)
	end)
	makeCtrl("✕", Color3.fromRGB(60,24,24), Color3.fromRGB(239,68,68), function()
		self:Close()
	end)

	-- Draggable on topbar
	Util.Draggable(self.MainFrame, self.TopBar)

	-- ── Tab content host ───────────────────────────────
	self.TabContentArea = Util.New("Frame", {
		Name                 = "TabContent",
		BackgroundTransparency = 1,
		Position             = UDim2.new(0, 0, 0, 48),
		Size                 = UDim2.new(1, 0, 1, -48),
		ZIndex               = self.Z + 2,
	}, self.Content)

	return self
end

function Window:AddTab(opts)
	opts         = opts or {}
	local tab    = Tab.new(opts, self.T, self.TabContentArea, self.Z + 3, self.CFG)
	table.insert(self.Tabs, tab)
	table.insert(self.SidebarObj.Tabs, tab)

	self.SidebarObj:AddTabButton(tab, #self.Tabs)

	-- Auto-select first tab
	if #self.Tabs == 1 then
		task.defer(function() self:SelectTab(tab) end)
	end

	return tab
end

function Window:SelectTab(tab)
	if self.ActiveTab == tab then return end

	if self.ActiveTab then
		local old = self.ActiveTab
		Util.Tween(old.Container, { BackgroundTransparency = 1 }, "Fast")
		task.delay(0.18, function()
			old.Container.Visible = false
			old.Container.BackgroundTransparency = 1
		end)
	end

	self.ActiveTab = tab
	tab.Container.Visible              = true
	tab.Container.BackgroundTransparency = 1

	-- Breadcrumb update
	self.BreadcrumbIcon.Text = getIcon(tab.Icon)
	self.BreadcrumbText.Text = tab.Name

	self.SidebarObj:SelectTab(tab)

	-- Re-select first subtab if not yet active
	if #tab.SubTabs > 0 and not tab.ActiveSubTab then
		tab:SelectSubTab(tab.SubTabs[1])
	end
end

function Window:SetMinimized(v)
	self._minimized = v
	if v then
		Util.Tween(self.MainFrame, {
			Size = UDim2.new(0, self._origSize.X.Offset, 0, 48),
		}, "Normal")
		self.Content.Visible = false
		self.SidebarObj.Frame.ClipsDescendants = true
		Util.Tween(self.SidebarObj.Frame, { Size = UDim2.new(0, SIDEBAR_EXPANDED, 0, 48) }, "Normal")
	else
		Util.Tween(self.MainFrame, { Size = self._origSize }, "Normal")
		task.delay(0.1, function()
			self.Content.Visible = true
			self.SidebarObj.Frame.ClipsDescendants = false
			Util.Tween(self.SidebarObj.Frame, { Size = UDim2.new(0, SIDEBAR_EXPANDED, 1, 0) }, "Normal")
		end)
	end
end

function Window:SetVisible(v)
	Util.Tween(self.MainFrame, {
		BackgroundTransparency = v and 0 or 1,
		Size = v and self._origSize
		         or  UDim2.new(
		               self._origSize.X.Scale,
		               self._origSize.X.Offset * 0.92,
		               self._origSize.Y.Scale,
		               self._origSize.Y.Offset * 0.92),
	}, "Normal")
end

function Window:Notify(opts)
	self.Notif:Notify(opts)
end

function Window:Close()
	Util.TweenCallback(self.MainFrame, {
		BackgroundTransparency = 1,
		Size = UDim2.new(
			self._origSize.X.Scale, self._origSize.X.Offset * 0.88,
			self._origSize.Y.Scale, self._origSize.Y.Offset * 0.88),
	}, "Normal", function()
		if self._blur then
			Util.TweenCallback(self._blur, { Size = 0 }, "Normal", function()
				self._blur:Destroy()
			end)
		end
		self.ScreenGui:Destroy()
	end)
end

function Window:SaveConfig()
	self.CFG:Save()
end

function Window:LoadConfig()
	self.CFG:Load()
end

function Window:GetFlag(flag)
	return self.CFG:GetFlag(flag)
end

function Window:SetTheme(themeName)
	-- Theme hot-swap placeholder
	-- Full hot-swap would require re-applying colors to all instances
	warn("NexusUI: SetTheme called with '"..themeName.."'. Hot-swap requires re-creating the window.")
end

-- ══════════════════════════════════════════════════════
--  13. LIBRARY ENTRY POINT
-- ══════════════════════════════════════════════════════
local NexusUI = {}
NexusUI.__index = NexusUI
NexusUI.Version  = "2.0.0"
NexusUI.Themes   = Themes
NexusUI.Flags    = {}  -- Global flags table (updated by config system)

function NexusUI:CreateWindow(opts)
	opts       = opts or {}
	local tName = opts.Theme or "Midnight"
	local T     = Themes[tName] or Themes.Midnight

	-- Support partial theme override
	if opts.ThemeOverride and type(opts.ThemeOverride) == "table" then
		local merged = {}
		for k, v in pairs(T)                  do merged[k] = v end
		for k, v in pairs(opts.ThemeOverride)  do merged[k] = v end
		T = merged
	end

	local win = Window.new(opts, T)

	-- Expose global flags from this window's config
	NexusUI.Flags = win.CFG.Flags

	return win
end

function NexusUI:RegisterTheme(name, theme)
	assert(type(name) == "string", "Theme name must be a string")
	assert(type(theme) == "table", "Theme must be a table")
	Themes[name] = theme
end

function NexusUI:GetThemes()
	local names = {}
	for k in pairs(Themes) do table.insert(names, k) end
	table.sort(names)
	return names
end

function NexusUI:Destroy()
	Util.DisconnectAll()
end

return NexusUI

--[[
╔══════════════════════════════════════════════════════════╗
║              FULL USAGE REFERENCE                       ║
╠══════════════════════════════════════════════════════════╣

── WINDOW ─────────────────────────────────────────────────

  local Nexus = loadstring(game:HttpGet("YOUR_URL"))()

  local Win = Nexus:CreateWindow({
      Title    = "NexusUI",
      SubTitle = "v2.0",
      Theme    = "Midnight",  -- Midnight|Carbon|Ocean|Sakura|Forest|Ember|Violet|Pearl
      Size     = UDim2.new(0, 810, 0, 540),
      Center   = true,
      BlurBackground = true,
      ThemeOverride  = { Accent = Color3.fromRGB(255, 100, 100) },
      ConfigurationSaving = {
          Enabled  = true,
          FileName = "MyScript",
          Folder   = "NexusUI",
      },
  })

── TABS ────────────────────────────────────────────────────

  local Tab = Win:AddTab({ Name = "Combat",   Icon = "combat"  })
  local Tab = Win:AddTab({ Name = "Visuals",  Icon = "visual"  })
  local Tab = Win:AddTab({ Name = "Settings", Icon = "settings"})

── SUBTABS ─────────────────────────────────────────────────

  local Sub1 = Tab:AddSubTab("Aimbot")
  local Sub2 = Tab:AddSubTab("Triggerbot")
  -- If no subtabs, cards go directly: Tab:AddCard({...})

── CARDS ───────────────────────────────────────────────────

  -- Width alternates left/right in masonry by default
  local Card = Sub1:AddCard({
      Title       = "Aimbot",
      Description = "Configure aim assistance",
  })

── CONTROLS ────────────────────────────────────────────────

  -- Toggle
  local Toggle = Card:AddToggle({
      Name        = "Enable",
      Flag        = "AimbotEnabled",
      Default     = false,
      Description = "Activates the aimbot",
      Callback    = function(v) end,
  })
  Toggle:Set(true)   -- set value
  Toggle:Get()       -- get value
  Toggle:Toggle()    -- flip

  -- Slider
  local Slider = Card:AddSlider({
      Name     = "FOV",
      Flag     = "AimbotFOV",
      Min = 5, Max = 360, Default = 90,
      Decimal  = 1,       -- decimal places
      Suffix   = "°",
      Callback = function(v) end,
  })
  Slider:Set(120)
  Slider:Get()

  -- Button
  Card:AddButton({
      Name     = "Reset Settings",
      Style    = "Primary",    -- Primary | Secondary | Danger
      Callback = function() end,
  })

  -- Dropdown
  local DD = Card:AddDropdown({
      Name       = "Target Part",
      Flag       = "AimbotPart",
      Options    = { "Head", "Torso", "Neck", "Chest" },
      Default    = "Head",
      Searchable = true,   -- auto-enabled if >5 options
      Multi      = false,  -- multi-select mode
      Callback   = function(v) end,
  })
  DD:Set("Torso")
  DD:Get()
  DD:SetOptions({"Head","Torso"})
  DD:AddOption("LeftArm")
  DD:RemoveOption("LeftArm")

  -- Textbox
  local TB = Card:AddTextbox({
      Name        = "Custom Tag",
      Flag        = "PlayerTag",
      Placeholder = "Enter tag...",
      Default     = "",
      Numeric     = false,
      LiveUpdate  = false,
      Callback    = function(v) end,
  })

  -- Keybind
  local KB = Card:AddKeybind({
      Name     = "Toggle Aimbot",
      Flag     = "AimbotKey",
      Default  = Enum.KeyCode.X,
      Callback = function(key) end,  -- fires on press
      Changed  = function(key) end,  -- fires on rebind
  })

  -- Color Picker
  local CP = Card:AddColorPicker({
      Name     = "ESP Color",
      Flag     = "ESPColor",
      Default  = Color3.fromRGB(255, 80, 80),
      Callback = function(color) end,
  })

  -- Label
  Card:AddLabel({ Text = "Some info text", Style = "secondary" })
  -- Style: "primary" | "secondary" | "accent"

  -- Paragraph
  Card:AddParagraph({
      Title = "About",
      Body  = "This is a multi-line paragraph with some descriptive text.",
  })

  -- Divider
  Card:AddDivider({ Label = "SECTION" })  -- optional label

  -- Search Input
  Card:AddSearch({
      Placeholder = "Search players...",
      Callback    = function(query) print(query) end,
  })

── NOTIFICATIONS ───────────────────────────────────────────

  Win:Notify({
      Title       = "Success!",
      Description = "Settings saved.",
      Type        = "Success",   -- Info | Success | Warning | Error
      Duration    = 4.5,
  })

── CONFIG ─────────────────────────────────────────────────

  Win:SaveConfig()  -- manual save
  Win:LoadConfig()  -- manual load
  Win:GetFlag("AimbotEnabled")   -- read any flag

── WINDOW METHODS ──────────────────────────────────────────

  Win:SetMinimized(true/false)
  Win:SetVisible(true/false)
  Win:Close()

── THEMES ──────────────────────────────────────────────────

  Nexus:GetThemes()   -- {"Midnight","Carbon","Ocean",...}

  Nexus:RegisterTheme("MyTheme", {
      Background = Color3.fromRGB(10,10,10),
      Accent     = Color3.fromRGB(255,200,0),
      -- ... (see Themes table for all keys)
  })

╚══════════════════════════════════════════════════════════╝
]]
