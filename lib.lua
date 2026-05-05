--[[
	NexusLib v2.3 – Executor‑Compatible UI Library
	Works with: Synapse X, Krnl, Script‑Ware, Electron, etc.
	Features: Tabs, Toggles, Sliders, Dropdowns, ColorPickers,
	Keybinds, Buttons, Labels, Notifications, Drag, Status Bar
--]]

local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Safe UI container detection
local function getUIContainer()
	-- Prefer executor‑protected containers
	if syn and syn.protect_gui then
		return gethui and gethui() or game:GetService("CoreGui")
	end
	-- Fallback for other executors
	local success, container = pcall(function()
		return (gethui and gethui()) or game:GetService("CoreGui")
	end)
	return success and container or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- Theme
local Accent = Color3.fromRGB(0, 220, 255)
local Background = Color3.fromRGB(25, 25, 35)
local Darker = Color3.fromRGB(18, 18, 28)
local Light = Color3.fromRGB(45, 45, 55)
local TextColor = Color3.fromRGB(220, 220, 220)
local DimText = Color3.fromRGB(140, 140, 150)
local Font = Enum.Font.Gotham
local TabFont = Enum.Font.GothamBold

-- Tween helper
local function tween(obj, props, dur, style, dir)
	local t = TweenService:Create(obj, TweenInfo.new(dur, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

-- Smooth drag handler
local function makeDraggable(gui, handle)
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Main Window Class
local Window = {}
Window.__index = Window

function Window.new(title)
	local self = setmetatable({}, Window)
	self.Title = title
	self.Tabs = {}
	self.CurrentTab = nil
	self.Notifications = {}

	local container = getUIContainer()

	-- ScreenGui
	local Gui = Instance.new("ScreenGui")
	Gui.Name = "NexusLib"
	Gui.ResetOnSpawn = false
	Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.Gui = Gui
	Gui.Parent = container

	-- Main frame
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.BackgroundColor3 = Darker
	Main.BorderSizePixel = 0
	Main.Size = UDim2.new(0, 600, 0, 400)
	Main.Position = UDim2.new(0.5, -300, 0.5, -200)
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.ClipsDescendants = true
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
	self.Main = Main
	Main.Parent = Gui

	-- Top Bar
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.BackgroundColor3 = Background
	TopBar.BorderSizePixel = 0
	TopBar.Size = UDim2.new(1, 0, 0, 40)
	Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)
	TopBar.Parent = Main

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Text = title
	TitleLabel.Font = Font
	TitleLabel.TextColor3 = Accent
	TitleLabel.TextSize = 18
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Size = UDim2.new(0, 200, 1, 0)
	TitleLabel.Position = UDim2.new(0, 15, 0, 0)
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = TopBar

	local VersionLabel = Instance.new("TextLabel")
	VersionLabel.Text = "v2.3"
	VersionLabel.Font = Font
	VersionLabel.TextColor3 = DimText
	VersionLabel.TextSize = 12
	VersionLabel.BackgroundTransparency = 1
	VersionLabel.Size = UDim2.new(0, 40, 1, 0)
	VersionLabel.Position = UDim2.new(0, TitleLabel.Position.X.Offset + TitleLabel.TextBounds.X + 5, 0, 0)
	VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
	VersionLabel.Parent = TopBar

	-- Tab buttons container
	local TabContainer = Instance.new("Frame")
	TabContainer.Name = "TabContainer"
	TabContainer.BackgroundTransparency = 1
	TabContainer.Size = UDim2.new(1, -30, 1, 0)
	TabContainer.Position = UDim2.new(0, 15, 0, 0)
	TabContainer.ZIndex = 2
	TabContainer.Parent = TopBar
	self.TabContainer = TabContainer

	-- Content area
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.BackgroundColor3 = Background
	Content.BorderSizePixel = 0
	Content.Size = UDim2.new(1, 0, 1, -40)
	Content.Position = UDim2.new(0, 0, 0, 40)
	Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)
	Content.Parent = Main

	local ScrollingFrame = Instance.new("ScrollingFrame")
	ScrollingFrame.Name = "Scrolling"
	ScrollingFrame.BackgroundTransparency = 1
	ScrollingFrame.Size = UDim2.new(1, -20, 1, -20)
	ScrollingFrame.Position = UDim2.new(0, 10, 0, 10)
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollingFrame.ScrollBarThickness = 4
	ScrollingFrame.ScrollBarImageColor3 = Light
	ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ScrollingFrame.ScrollingEnabled = true
	ScrollingFrame.Parent = Content

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Padding = UDim.new(0, 8)
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Parent = ScrollingFrame

	self.ContentFrame = ScrollingFrame
	self.UIListLayout = UIListLayout

	-- Bottom status bar
	local BottomBar = Instance.new("Frame")
	BottomBar.Name = "BottomBar"
	BottomBar.BackgroundColor3 = Darker
	BottomBar.BorderSizePixel = 0
	BottomBar.Size = UDim2.new(1, 0, 0, 25)
	BottomBar.Position = UDim2.new(0, 0, 1, -25)
	Instance.new("UICorner", BottomBar).CornerRadius = UDim.new(0, 8)
	BottomBar.Parent = Main

	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.Text = "Connected · 0ms"
	StatusLabel.Font = Font
	StatusLabel.TextColor3 = DimText
	StatusLabel.TextSize = 12
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Size = UDim2.new(1, -20, 1, 0)
	StatusLabel.Position = UDim2.new(0, 10, 0, 0)
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	StatusLabel.Parent = BottomBar

	local Breadcrumb = Instance.new("TextLabel")
	Breadcrumb.Text = "Combat > General v2.3.0"
	Breadcrumb.Font = Font
	Breadcrumb.TextColor3 = DimText
	Breadcrumb.TextSize = 12
	Breadcrumb.BackgroundTransparency = 1
	Breadcrumb.Size = UDim2.new(1, -20, 1, 0)
	Breadcrumb.Position = UDim2.new(0, 10, 0, 0)
	Breadcrumb.TextXAlignment = Enum.TextXAlignment.Right
	Breadcrumb.Parent = BottomBar

	self.StatusLabel = StatusLabel
	self.Breadcrumb = Breadcrumb

	-- Make window draggable
	makeDraggable(Main, TopBar)

	-- Protect GUI if syn is available
	if syn and syn.protect_gui then
		syn.protect_gui(Gui)
	end

	return self
end

function Window:SetStatus(text)
	self.StatusLabel.Text = text
end

function Window:SetBreadcrumb(text)
	self.Breadcrumb.Text = text
end

-- Tab management
function Window:Tab(name)
	if self.Tabs[name] then return self.Tabs[name] end
	local tab = { Name = name, Window = self, Elements = {} }

	local tabBtn = Instance.new("TextButton")
	tabBtn.Text = name
	tabBtn.Font = TabFont
	tabBtn.TextColor3 = TextColor
	tabBtn.TextSize = 14
	tabBtn.BackgroundColor3 = Light
	tabBtn.BorderSizePixel = 0
	tabBtn.Size = UDim2.new(0, 100, 0, 25)
	tabBtn.Position = UDim2.new(0, (#self.Tabs) * 110, 0.5, -12.5)
	Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 5)
	tabBtn.Parent = self.TabContainer

	tab.Button = tabBtn

	tabBtn.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	self.Tabs[name] = tab
	table.insert(self.Tabs, tab)

	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end

	return tab
end

function Window:SelectTab(tab)
	for _, t in ipairs(self.Tabs) do
		if type(t) == "table" then
			t.Button.BackgroundColor3 = Light
			t.Button.TextColor3 = TextColor
			for _, elem in ipairs(t.Elements) do
				elem.Frame.Visible = false
			end
		end
	end
	tab.Button.BackgroundColor3 = Accent
	tab.Button.TextColor3 = Color3.new(0, 0, 0)
	for _, elem in ipairs(tab.Elements) do
		elem.Frame.Visible = true
	end
	self.CurrentTab = tab
	self:SetBreadcrumb("Combat > " .. tab.Name .. " v2.3.0")
end

-- Element frame creator
local function createElementFrame(parent, height)
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Light
	frame.BorderSizePixel = 0
	frame.Size = UDim2.new(1, -10, 0, height)
	frame.Position = UDim2.new(0, 5, 0, 0)
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
	frame.Parent = parent
	return frame
end

-- ── UI Elements ──────────────────────────────────────────
function Window:AddToggle(tab, name, default, callback)
	local frame = createElementFrame(self.ContentFrame, 40)
	local toggle = Instance.new("TextButton")
	toggle.Text = ""
	toggle.BackgroundColor3 = Background
	toggle.BorderSizePixel = 0
	toggle.Size = UDim2.new(0, 20, 0, 20)
	toggle.Position = UDim2.new(0, 10, 0.5, -10)
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 4)
	toggle.Parent = frame

	local knob = Instance.new("Frame")
	knob.BackgroundColor3 = DimText
	knob.BorderSizePixel = 0
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(0, 3, 0.5, -7)
	Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 3)
	knob.Parent = toggle

	local label = Instance.new("TextLabel")
	label.Text = name
	label.Font = Font
	label.TextColor3 = TextColor
	label.TextSize = 14
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -40, 1, 0)
	label.Position = UDim2.new(0, 40, 0, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local state = default or false
	local function update()
		if state then
			knob.BackgroundColor3 = Accent
			toggle.BackgroundColor3 = Accent
		else
			knob.BackgroundColor3 = DimText
			toggle.BackgroundColor3 = Background
		end
	end
	update()

	toggle.MouseButton1Click:Connect(function()
		state = not state
		update()
		if callback then callback(state) end
	end)

	local element = { Frame = frame, Toggle = toggle, Label = label }
	table.insert(tab.Elements, element)
	return {
		SetState = function(self, val) state = val; update() end,
		GetState = function() return state end,
	}
end

function Window:AddSlider(tab, name, min, max, default, callback)
	local frame = createElementFrame(self.ContentFrame, 60)
	local label = Instance.new("TextLabel")
	label.Text = name .. ": " .. default
	label.Font = Font
	label.TextColor3 = TextColor
	label.TextSize = 13
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -20, 0, 20)
	label.Position = UDim2.new(0, 10, 0, 5)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local sliderBg = Instance.new("Frame")
	sliderBg.BackgroundColor3 = Background
	sliderBg.BorderSizePixel = 0
	sliderBg.Size = UDim2.new(1, -20, 0, 10)
	sliderBg.Position = UDim2.new(0, 10, 0, 30)
	Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 5)
	sliderBg.Parent = frame

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = Accent
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 5)
	fill.Parent = sliderBg

	local knob = Instance.new("Frame")
	knob.BackgroundColor3 = Accent
	knob.BorderSizePixel = 0
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
	Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 7)
	knob.Parent = sliderBg

	local value = default
	local function update(val)
		val = math.clamp(val, min, max)
		value = val
		local percent = (val - min) / (max - min)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		knob.Position = UDim2.new(percent, -7, 0.5, -7)
		label.Text = name .. ": " .. math.round(val * 100) / 100
		if callback then callback(val) end
	end

	local dragging = false
	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local mousePos = UserInputService:GetMouseLocation()
			local absPos = sliderBg.AbsolutePosition
			local absSize = sliderBg.AbsoluteSize
			local relativeX = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
			update(min + (max - min) * relativeX)
		end
	end)

	local element = { Frame = frame, Slider = sliderBg }
	table.insert(tab.Elements, element)
	return {
		SetValue = function(self, val) update(val) end,
		GetValue = function() return value end,
	}
end

function Window:AddDropdown(tab, name, options, default, callback)
	local frame = createElementFrame(self.ContentFrame, 50)
	local label = Instance.new("TextButton")
	label.Text = name .. ": " .. (default or options[1])
	label.Font = Font
	label.TextColor3 = TextColor
	label.TextSize = 13
	label.BackgroundColor3 = Background
	label.BorderSizePixel = 0
	label.Size = UDim2.new(1, -20, 0, 30)
	label.Position = UDim2.new(0, 10, 0, 10)
	label.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", label).CornerRadius = UDim.new(0, 5)
	label.Parent = frame

	local selected = default or options[1]
	local function open()
		local drop = Instance.new("Frame")
		drop.BackgroundColor3 = Darker
		drop.BorderSizePixel = 0
		drop.Size = UDim2.new(1, -20, 0, #options * 25 + 10)
		drop.Position = UDim2.new(0, 10, 0, 45)
		drop.ZIndex = 5
		Instance.new("UICorner", drop).CornerRadius = UDim.new(0, 5)
		drop.Parent = frame

		local list = Instance.new("UIListLayout")
		list.Padding = UDim.new(0, 2)
		list.Parent = drop

		for _, opt in ipairs(options) do
			local btn = Instance.new("TextButton")
			btn.Text = opt
			btn.Font = Font
			btn.TextColor3 = TextColor
			btn.TextSize = 13
			btn.BackgroundColor3 = Light
			btn.BorderSizePixel = 0
			btn.Size = UDim2.new(1, -10, 0, 22)
			btn.Position = UDim2.new(0, 5, 0, 0)
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
			btn.Parent = drop

			btn.MouseButton1Click:Connect(function()
				selected = opt
				label.Text = name .. ": " .. opt
				drop:Destroy()
				outside:Destroy()
				if callback then callback(opt) end
			end)
		end

		local outside = Instance.new("TextButton")
		outside.Text = ""
		outside.BackgroundTransparency = 1
		outside.Size = UDim2.new(1, 0, 1, 0)
		outside.Position = UDim2.new(0, 0, 0, 0)
		outside.ZIndex = 4
		outside.Parent = frame
		outside.MouseButton1Click:Connect(function()
			drop:Destroy()
			outside:Destroy()
		end)
	end

	label.MouseButton1Click:Connect(open)

	local element = { Frame = frame, Dropdown = label }
	table.insert(tab.Elements, element)
	return {}
end

function Window:AddColorPicker(tab, name, default, callback)
	local frame = createElementFrame(self.ContentFrame, 50)
	local label = Instance.new("TextButton")
	label.Text = name
	label.Font = Font
	label.TextColor3 = TextColor
	label.TextSize = 13
	label.BackgroundColor3 = Background
	label.BorderSizePixel = 0
	label.Size = UDim2.new(1, -60, 0, 30)
	label.Position = UDim2.new(0, 10, 0, 10)
	label.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", label).CornerRadius = UDim.new(0, 5)
	label.Parent = frame

	local preview = Instance.new("Frame")
	preview.BackgroundColor3 = default or Accent
	preview.BorderSizePixel = 0
	preview.Size = UDim2.new(0, 30, 0, 30)
	preview.Position = UDim2.new(1, -40, 0, 10)
	Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 5)
	preview.Parent = frame

	local currentColor = default or Accent
	local hue = 0.5

	local function openPicker()
		local pickerFrame = Instance.new("Frame")
		pickerFrame.BackgroundColor3 = Darker
		pickerFrame.BorderSizePixel = 0
		pickerFrame.Size = UDim2.new(0, 200, 0, 120)
		pickerFrame.Position = UDim2.new(0, 10, 0, 60)
		pickerFrame.ZIndex = 10
		Instance.new("UICorner", pickerFrame).CornerRadius = UDim.new(0, 8)
		pickerFrame.Parent = frame

		local hueSlider = Instance.new("Frame")
		hueSlider.BackgroundColor3 = Color3.new(1,0,0)
		hueSlider.BorderSizePixel = 0
		hueSlider.Size = UDim2.new(1, -20, 0, 20)
		hueSlider.Position = UDim2.new(0, 10, 0, 10)
		hueSlider.ZIndex = 11
		Instance.new("UICorner", hueSlider).CornerRadius = UDim.new(0, 4)
		hueSlider.Parent = pickerFrame

		local gradient = Instance.new("UIGradient")
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
			ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,255,0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
			ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,0,255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
		})
		gradient.Rotation = 90
		gradient.Parent = hueSlider

		local hueKnob = Instance.new("Frame")
		hueKnob.BackgroundColor3 = Color3.new(1,1,1)
		hueKnob.BorderSizePixel = 0
		hueKnob.Size = UDim2.new(0, 10, 1, 4)
		hueKnob.Position = UDim2.new(hue, -5, 0, -2)
		hueKnob.ZIndex = 12
		Instance.new("UICorner", hueKnob).CornerRadius = UDim.new(0, 3)
		hueKnob.Parent = hueSlider

		local satValBox = Instance.new("Frame")
		satValBox.BackgroundColor3 = Background
		satValBox.BorderSizePixel = 0
		satValBox.Size = UDim2.new(1, -20, 0, 40)
		satValBox.Position = UDim2.new(0, 10, 0, 40)
		satValBox.ZIndex = 11
		Instance.new("UICorner", satValBox).CornerRadius = UDim.new(0, 4)
		satValBox.Parent = pickerFrame

		local satGrad = Instance.new("UIGradient")
		satGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1)),
		})
		satGrad.Parent = satValBox

		local satKnob = Instance.new("Frame")
		satKnob.BackgroundColor3 = Color3.new(1,1,1)
		satKnob.BorderSizePixel = 0
		satKnob.Size = UDim2.new(0, 8, 0, 8)
		satKnob.Position = UDim2.new(1, -4, 0.5, -4)
		satKnob.ZIndex = 13
		Instance.new("UICorner", satKnob).CornerRadius = UDim.new(0, 4)
		satKnob.Parent = satValBox

		local function updateColor()
			currentColor = Color3.fromHSV(hue, 1, 1)
			preview.BackgroundColor3 = currentColor
			if callback then callback(currentColor) end
		end

		-- Hue slider dragging
		local hvDragging = false
		hueKnob.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then hvDragging = true end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then hvDragging = false end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if hvDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local mouseX = UserInputService:GetMouseLocation().X
				local absX = hueSlider.AbsolutePosition.X
				local absWidth = hueSlider.AbsoluteSize.X
				hue = math.clamp((mouseX - absX) / absWidth, 0, 1)
				hueKnob.Position = UDim2.new(hue, -5, 0, -2)
				satGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1)),
				})
				updateColor()
			end
		end)

		local outside = Instance.new("TextButton")
		outside.Text = ""
		outside.BackgroundTransparency = 1
		outside.Size = UDim2.new(1, 0, 1, 0)
		outside.Position = UDim2.new(0, 0, 0, 0)
		outside.ZIndex = 9
		outside.Parent = frame
		outside.MouseButton1Click:Connect(function()
			pickerFrame:Destroy()
			outside:Destroy()
		end)
	end

	label.MouseButton1Click:Connect(openPicker)
	preview.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then openPicker() end
	end)

	local element = { Frame = frame, Picker = preview }
	table.insert(tab.Elements, element)
	return {}
end

function Window:AddKeybind(tab, name, default, callback)
	local frame = createElementFrame(self.ContentFrame, 40)
	local label = Instance.new("TextLabel")
	label.Text = name
	label.Font = Font
	label.TextColor3 = TextColor
	label.TextSize = 14
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0, 120, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local keyBtn = Instance.new("TextButton")
	keyBtn.Text = default and default.Name or "None"
	keyBtn.Font = Font
	keyBtn.TextColor3 = TextColor
	keyBtn.TextSize = 13
	keyBtn.BackgroundColor3 = Background
	keyBtn.BorderSizePixel = 0
	keyBtn.Size = UDim2.new(0, 80, 0, 24)
	keyBtn.Position = UDim2.new(1, -90, 0.5, -12)
	Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 4)
	keyBtn.Parent = frame

	local currentKey = default
	local listening = false
	keyBtn.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		keyBtn.Text = "..."
		local conn
		conn = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				currentKey = input.KeyCode
				keyBtn.Text = input.KeyCode.Name
				listening = false
				conn:Disconnect()
				if callback then callback(input.KeyCode) end
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				currentKey = input.UserInputType
				keyBtn.Text = "Mouse1"
				listening = false
				conn:Disconnect()
				if callback then callback(input.UserInputType) end
			end
		end)
		task.delay(5, function()
			if listening then
				listening = false
				conn:Disconnect()
				keyBtn.Text = currentKey and currentKey.Name or "None"
			end
		end)
	end)

	local element = { Frame = frame, Keybind = keyBtn }
	table.insert(tab.Elements, element)
	return {
		GetKey = function() return currentKey end,
	}
end

function Window:AddButton(tab, name, callback)
	local frame = createElementFrame(self.ContentFrame, 35)
	local btn = Instance.new("TextButton")
	btn.Text = name
	btn.Font = Font
	btn.TextColor3 = TextColor
	btn.TextSize = 14
	btn.BackgroundColor3 = Accent
	btn.BorderSizePixel = 0
	btn.Size = UDim2.new(1, -20, 0, 25)
	btn.Position = UDim2.new(0, 10, 0.5, -12.5)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
	btn.Parent = frame

	btn.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)

	local element = { Frame = frame, Button = btn }
	table.insert(tab.Elements, element)
	return {}
end

function Window:AddLabel(tab, text)
	local frame = createElementFrame(self.ContentFrame, 30)
	local lbl = Instance.new("TextLabel")
	lbl.Text = text
	lbl.Font = Font
	lbl.TextColor3 = DimText
	lbl.TextSize = 13
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -20, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = frame

	local element = { Frame = frame, Label = lbl }
	table.insert(tab.Elements, element)
	return {}
end

function Window:Notify(title, message, duration)
	duration = duration or 3
	local notif = Instance.new("Frame")
	notif.BackgroundColor3 = Darker
	notif.BorderSizePixel = 0
	notif.Size = UDim2.new(0, 250, 0, 60)
	notif.Position = UDim2.new(1, 10, 0, 10 + (#self.Notifications * 70))
	notif.AnchorPoint = Vector2.new(1, 0)
	Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
	notif.Parent = self.Gui
	table.insert(self.Notifications, notif)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = title
	titleLabel.Font = Font
	titleLabel.TextColor3 = Accent
	titleLabel.TextSize = 14
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -20, 0, 20)
	titleLabel.Position = UDim2.new(0, 10, 0, 5)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = notif

	local msgLabel = Instance.new("TextLabel")
	msgLabel.Text = message
	msgLabel.Font = Font
	msgLabel.TextColor3 = TextColor
	msgLabel.TextSize = 12
	msgLabel.BackgroundTransparency = 1
	msgLabel.Size = UDim2.new(1, -20, 0, 20)
	msgLabel.Position = UDim2.new(0, 10, 0, 30)
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.Parent = notif

	tween(notif, {Position = UDim2.new(1, -260, 0, notif.Position.Y.Offset)}, 0.3)

	task.delay(duration, function()
		tween(notif, {Position = UDim2.new(1, 10, 0, notif.Position.Y.Offset)}, 0.3)
		task.wait(0.3)
		notif:Destroy()
		for i, n in ipairs(self.Notifications) do
			if n == notif then
				table.remove(self.Notifications, i)
				break
			end
		end
		for i, n in ipairs(self.Notifications) do
			n.Position = UDim2.new(1, -260, 0, 10 + ((i-1) * 70))
		end
	end)
end

-- Public API
local Lib = {}
function Lib:CreateWindow(title)
	local win = Window.new(title)
	return {
		Tab = function(self, name) return win:Tab(name) end,
		AddToggle = function(self, tab, ...) return win:AddToggle(tab, ...) end,
		AddSlider = function(self, tab, ...) return win:AddSlider(tab, ...) end,
		AddDropdown = function(self, tab, ...) return win:AddDropdown(tab, ...) end,
		AddColorPicker = function(self, tab, ...) return win:AddColorPicker(tab, ...) end,
		AddKeybind = function(self, tab, ...) return win:AddKeybind(tab, ...) end,
		AddButton = function(self, tab, ...) return win:AddButton(tab, ...) end,
		AddLabel = function(self, tab, ...) return win:AddLabel(tab, ...) end,
		SetStatus = function(self, text) win:SetStatus(text) end,
		Notify = function(self, ...) win:Notify(...) end,
		Window = win,
	}
end

return Lib
