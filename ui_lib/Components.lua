--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)

local Components = {}

-- Button Component
function Components:CreateButton(parent: GuiObject, text: string, callback: () -> ())
    local Button = Instance.new("TextButton")
    Button.Name = "Button"
    Button.Size = UDim2.new(0, 100, 0, 30)
    Button.BackgroundColor3 = Theme.Theme.Surface
    Button.BorderSizePixel = 0
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 13
    Button.TextColor3 = Theme.Theme.Text
    Button.Text = text
    Button.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, Theme.Radius.Small)
    UICorner.Parent = Button

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Theme.Theme.Border
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.75
    UIStroke.ApplyStrokeMode = Enum.UIStrokeApplyMode.Border
    UIStroke.Parent = Button

    local originalColor = Button.BackgroundColor3
    local originalSize = Button.Size
    local originalPosition = Button.Position

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, Theme.Animations.Fast, {BackgroundColor3 = Theme.Theme.SurfaceHover}):Play()
        TweenService:Create(UIStroke, Theme.Animations.Fast, {Transparency = 0.5}):Play()
        -- Subtle lift
        TweenService:Create(Button, Theme.Animations.Fast, {Position = originalPosition - UDim2.new(0,0,0,1)}):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, Theme.Animations.Fast, {BackgroundColor3 = originalColor}):Play()
        TweenService:Create(UIStroke, Theme.Animations.Fast, {Transparency = 0.75}):Play()
        -- Return to original position
        TweenService:Create(Button, Theme.Animations.Fast, {Position = originalPosition}):Play()
    end)

    Button.MouseButton1Down:Connect(function()
        -- Compress slightly, move down 1px
        TweenService:Create(Button, Theme.Animations.Fast, {Size = originalSize - UDim2.new(0,0,0,2), Position = originalPosition + UDim2.new(0,0,0,1)}):Play()
    end)

    Button.MouseButton1Up:Connect(function()
        TweenService:Create(Button, Theme.Animations.Fast, {Size = originalSize, Position = originalPosition}):Play()
        callback()
    end)

    return Button
end

-- Toggle Component
function Components:CreateToggle(parent: GuiObject, initialState: boolean, callback: (state: boolean) -> ())
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "Toggle"
    ToggleFrame.Size = UDim2.new(0, 36, 0, 18)
    ToggleFrame.BackgroundColor3 = Theme.Theme.Surface
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, Theme.Radius.Pill)
    UICorner.Parent = ToggleFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Theme.Theme.Border
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.75
    UIStroke.ApplyStrokeMode = Enum.UIStrokeApplyMode.Border
    UIStroke.Parent = ToggleFrame

    local ToggleHandle = Instance.new("Frame")
    ToggleHandle.Name = "Handle"
    ToggleHandle.Size = UDim2.new(0, 14, 0, 14)
    ToggleHandle.BackgroundColor3 = Theme.Theme.Subtext
    ToggleHandle.BorderSizePixel = 0
    ToggleHandle.Parent = ToggleFrame

    local HandleCorner = Instance.new("UICorner")
    HandleCorner.CornerRadius = UDim.new(0, Theme.Radius.Pill)
    HandleCorner.Parent = ToggleHandle

    local state = initialState

    local function updateToggleVisual(animate: boolean)
        local targetPosition = if state then UDim2.new(1, -16, 0.5, -7) else UDim2.new(0, 2, 0.5, -7)
        local targetColor = if state then Theme.Theme.Accent else Theme.Theme.Subtext
        local targetStrokeTransparency = if state then 0.5 else 0.75

        if animate then
            TweenService:Create(ToggleHandle, Theme.Animations.Fast, {Position = targetPosition, BackgroundColor3 = targetColor}):Play()
            TweenService:Create(UIStroke, Theme.Animations.Fast, {Transparency = targetStrokeTransparency}):Play()
        else
            ToggleHandle.Position = targetPosition
            ToggleHandle.BackgroundColor3 = targetColor
            UIStroke.Transparency = targetStrokeTransparency
        end
    end

    updateToggleVisual(false)

    ToggleFrame.MouseButton1Click:Connect(function()
        state = not state
        updateToggleVisual(true)
        callback(state)
    end)

    return ToggleFrame
end

-- Slider Component
function Components:CreateSlider(parent: GuiObject, minValue: number, maxValue: number, initialValue: number, callback: (value: number) -> ())
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "Slider"
    SliderFrame.Size = UDim2.new(0, 200, 0, 18)
    SliderFrame.BackgroundColor3 = Theme.Theme.Surface
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, Theme.Radius.Pill)
    UICorner.Parent = SliderFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Theme.Theme.Border
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.75
    UIStroke.ApplyStrokeMode = Enum.UIStrokeApplyMode.Border
    UIStroke.Parent = SliderFrame

    local SliderTrack = Instance.new("Frame")
    SliderTrack.Name = "Track"
    SliderTrack.Size = UDim2.new(1, -4, 0, 4)
    SliderTrack.Position = UDim2.new(0.5, 0, 0.5, -2)
    SliderTrack.BackgroundColor3 = Theme.Theme.Subtext
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = SliderFrame

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, Theme.Radius.Pill)
    TrackCorner.Parent = SliderTrack

    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "Fill"
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.Position = UDim2.new(0, 0, 0, 0)
    SliderFill.BackgroundColor3 = Theme.Theme.Accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, Theme.Radius.Pill)
    FillCorner.Parent = SliderFill

    local SliderHandle = Instance.new("Frame")
    SliderHandle.Name = "Handle"
    SliderHandle.Size = UDim2.new(0, 12, 0, 12)
    SliderHandle.BackgroundColor3 = Theme.Theme.Text
    SliderHandle.BorderSizePixel = 0
    SliderHandle.Parent = SliderFrame

    local HandleCorner = Instance.new("UICorner")
    HandleCorner.CornerRadius = UDim.new(0, Theme.Radius.Pill)
    HandleCorner.Parent = SliderHandle

    local currentValue = initialValue
    local dragging = false

    local function updateSliderVisual(animate: boolean)
        local percentage = (currentValue - minValue) / (maxValue - minValue)
        local handleX = percentage * (SliderFrame.AbsoluteSize.X - SliderHandle.AbsoluteSize.X)
        local fillScaleX = percentage

        if animate then
            TweenService:Create(SliderHandle, Theme.Animations.Fast, {Position = UDim2.new(0, handleX, 0.5, -6)}):Play()
            TweenService:Create(SliderFill, Theme.Animations.Fast, {Size = UDim2.new(fillScaleX, 0, 1, 0)}):Play()
        else
            SliderHandle.Position = UDim2.new(0, handleX, 0.5, -6)
            SliderFill.Size = UDim2.new(fillScaleX, 0, 1, 0)
        end
    end

    updateSliderVisual(false)

    SliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    SliderFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    SliderFrame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.MouseButton1) then
            local mouseX = SliderFrame:GetRelativePosition(input.Position).X
            local newPercentage = math.clamp(mouseX / SliderFrame.AbsoluteSize.X, 0, 1)
            currentValue = minValue + newPercentage * (maxValue - minValue)
            updateSliderVisual(true)
            callback(currentValue)
        end
    end)

    return SliderFrame
end

-- Textbox Component
function Components:CreateTextbox(parent: GuiObject, placeholder: string, initialText: string, callback: (text: string) -> ())
    local Textbox = Instance.new("TextBox")
    Textbox.Name = "Textbox"
    Textbox.Size = UDim2.new(0, 150, 0, 30)
    Textbox.BackgroundColor3 = Theme.Theme.Surface
    Textbox.BorderSizePixel = 0
    Textbox.Font = Enum.Font.Gotham
    Textbox.TextSize = 13
    Textbox.TextColor3 = Theme.Theme.Text
    Textbox.PlaceholderText = placeholder
    Textbox.PlaceholderColor3 = Theme.Theme.Subtext
    Textbox.Text = initialText
    Textbox.TextXAlignment = Enum.TextXAlignment.Left
    Textbox.TextYAlignment = Enum.TextYAlignment.Center
    Textbox.ClearTextOnFocus = false
    Textbox.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, Theme.Radius.Small)
    UICorner.Parent = Textbox

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Theme.Theme.Border
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.75
    UIStroke.ApplyStrokeMode = Enum.UIStrokeApplyMode.Border
    UIStroke.Parent = Textbox

    Textbox.Focused:Connect(function()
        TweenService:Create(UIStroke, Theme.Animations.Fast, {Transparency = 0.5}):Play()
    end)

    Textbox.FocusLost:Connect(function()
        TweenService:Create(UIStroke, Theme.Animations.Fast, {Transparency = 0.75}):Play()
        callback(Textbox.Text)
    end)

    return Textbox
end

-- Label Component
function Components:CreateLabel(parent: GuiObject, text: string, textSize: number, textColor: Color3, textXAlignment: Enum.TextXAlignment)
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, 0, 0, textSize + 4) -- Adjust height based on text size
    Label.BackgroundColor3 = Theme.Theme.Background
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextSize = textSize
    Label.TextColor3 = textColor
    Label.Text = text
    Label.TextXAlignment = textXAlignment
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.Parent = parent

    return Label
end

-- Section Component
function Components:CreateSection(parent: GuiObject, title: string)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = "Section"
    SectionFrame.Size = UDim2.new(1, 0, 0, 100) -- Placeholder size, will be adjusted by content
    SectionFrame.BackgroundColor3 = Theme.Theme.Surface
    SectionFrame.BorderSizePixel = 0
    SectionFrame.ClipsDescendants = true
    SectionFrame.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, Theme.Radius.Medium)
    UICorner.Parent = SectionFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Theme.Theme.Border
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.75
    UIStroke.ApplyStrokeMode = Enum.UIStrokeApplyMode.Border
    UIStroke.Parent = SectionFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -Theme.Spacing.MD * 2, 0, 20)
    TitleLabel.Position = UDim2.new(0, Theme.Spacing.MD, 0, Theme.Spacing.MD)
    TitleLabel.BackgroundColor3 = Theme.Theme.Surface
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Gotham
    TitleLabel.TextSize = 15
    TitleLabel.TextColor3 = Theme.Theme.Text
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Text = title
    TitleLabel.Parent = SectionFrame

    local Separator = Instance.new("Frame")
    Separator.Name = "Separator"
    Separator.Size = UDim2.new(1, -Theme.Spacing.MD * 2, 0, 1)
    Separator.Position = UDim2.new(0, Theme.Spacing.MD, 0, TitleLabel.Position.Y.Offset + TitleLabel.Size.Y.Offset + Theme.Spacing.XS)
    Separator.BackgroundColor3 = Theme.Theme.Border
    Separator.BorderSizePixel = 0
    Separator.Parent = SectionFrame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, -Theme.Spacing.MD * 2, 1, -(Separator.Position.Y.Offset + Separator.Size.Y.Offset + Theme.Spacing.MD))
    ContentFrame.Position = UDim2.new(0, Theme.Spacing.MD, 0, Separator.Position.Y.Offset + Separator.Size.Y.Offset + Theme.Spacing.MD)
    ContentFrame.BackgroundColor3 = Theme.Theme.Surface
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = SectionFrame

    local UIGridLayout = Instance.new("UIGridLayout")
    UIGridLayout.Name = "Layout"
    UIGridLayout.FillDirection = Enum.FillDirection.Horizontal
    UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    UIGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIGridLayout.CellSize = UDim2.new(0.5, -Theme.Spacing.MD/2, 0, 50) -- 2-column layout
    UIGridLayout.CellPadding = UDim2.new(0, Theme.Spacing.MD, 0, Theme.Spacing.MD)
    UIGridLayout.Parent = ContentFrame

    return {
        Frame = SectionFrame,
        Content = ContentFrame,
        Layout = UIGridLayout
    }
end

-- Notification Component (simplified for now)
function Components:CreateNotification(parent: GuiObject, message: string, notificationType: string)
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = "Notification"
    NotificationFrame.Size = UDim2.new(0, 250, 0, 50)
    NotificationFrame.BackgroundColor3 = Theme.Theme.Surface
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, Theme.Radius.Small)
    UICorner.Parent = NotificationFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Theme.Theme.Border
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.75
    UIStroke.ApplyStrokeMode = Enum.UIStrokeApplyMode.Border
    UIStroke.Parent = NotificationFrame

    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Name = "Message"
    MessageLabel.Size = UDim2.new(1, -20, 1, 0)
    MessageLabel.Position = UDim2.new(0, 10, 0, 0)
    MessageLabel.BackgroundColor3 = Theme.Theme.Surface
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextSize = 14
    MessageLabel.TextColor3 = Theme.Theme.Text
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextYAlignment = Enum.TextYAlignment.Center
    MessageLabel.Text = message
    MessageLabel.Parent = NotificationFrame

    local function showNotification()
        NotificationFrame.Position = UDim2.new(1, 10, 0, 10) -- Start off-screen
        TweenService:Create(NotificationFrame, Theme.Animations.Medium, {Position = UDim2.new(1, -260, 0, 10)}):Play()
        task.delay(3, function()
            TweenService:Create(NotificationFrame, Theme.Animations.Medium, {Position = UDim2.new(1, 10, 0, 10)}):Play()
            task.delay(Theme.Animations.Medium.Time, function()
                NotificationFrame:Destroy()
            end)
        end)
    end

    showNotification()

    return NotificationFrame
end

return Components

-- Dropdown Component
function Components:CreateDropdown(parent: GuiObject, options: {string}, initialSelection: string, callback: (selection: string) -> ())
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = "Dropdown"
    DropdownFrame.Size = UDim2.new(0, 150, 0, 30)
    DropdownFrame.BackgroundColor3 = Theme.Theme.Surface
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ClipsDescendants = true
    DropdownFrame.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, Theme.Radius.Small)
    UICorner.Parent = DropdownFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Theme.Theme.Border
    UIStroke.Thickness = 1
    UIStroke.Transparency = 0.75
    UIStroke.ApplyStrokeMode = Enum.UIStrokeApplyMode.Border
    UIStroke.Parent = DropdownFrame

    local SelectedText = Instance.new("TextLabel")
    SelectedText.Name = "SelectedText"
    SelectedText.Size = UDim2.new(1, -20, 1, 0)
    SelectedText.Position = UDim2.new(0, 10, 0, 0)
    SelectedText.BackgroundColor3 = Theme.Theme.Surface
    SelectedText.BackgroundTransparency = 1
    SelectedText.Font = Enum.Font.Gotham
    SelectedText.TextSize = 13
    SelectedText.TextColor3 = Theme.Theme.Text
    SelectedText.TextXAlignment = Enum.TextXAlignment.Left
    SelectedText.TextYAlignment = Enum.TextYAlignment.Center
    SelectedText.Text = initialSelection
    SelectedText.Parent = DropdownFrame

    local Arrow = Instance.new("ImageLabel")
    Arrow.Name = "Arrow"
    Arrow.Size = UDim2.new(0, 16, 0, 16)
    Arrow.Position = UDim2.new(1, -20, 0.5, -8)
    Arrow.Image = "rbxassetid://5961036030" -- Example arrow icon
    Arrow.ImageColor3 = Theme.Theme.Text
    Arrow.BackgroundTransparency = 1
    Arrow.Parent = DropdownFrame

    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Name = "OptionsFrame"
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0) -- Will expand
    OptionsFrame.Position = UDim2.new(0, 0, 1, 2) -- Position below the dropdown
    OptionsFrame.BackgroundColor3 = Theme.Theme.Surface
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.ZIndex = 2
    OptionsFrame.Parent = DropdownFrame

    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.Name = "OptionsLayout"
    OptionsLayout.FillDirection = Enum.FillDirection.Vertical
    OptionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    OptionsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    OptionsLayout.Padding = UDim.new(0, Theme.Spacing.XS)
    OptionsLayout.Parent = OptionsFrame

    local currentSelection = initialSelection
    local expanded = false

    local function setSelection(selection: string)
        currentSelection = selection
        SelectedText.Text = selection
        callback(selection)
    end

    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Name = "OptionButton"
        OptionButton.Size = UDim2.new(1, 0, 0, 25)
        OptionButton.BackgroundColor3 = Theme.Theme.Surface
        OptionButton.BackgroundTransparency = 1
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 13
        OptionButton.TextColor3 = Theme.Theme.Text
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.TextYAlignment = Enum.TextYAlignment.Center
        OptionButton.Text = option
        OptionButton.Parent = OptionsFrame

        OptionButton.MouseEnter:Connect(function()
            TweenService:Create(OptionButton, Theme.Animations.Fast, {BackgroundColor3 = Theme.Theme.SurfaceHover}):Play()
        end)

        OptionButton.MouseLeave:Connect(function()
            TweenService:Create(OptionButton, Theme.Animations.Fast, {BackgroundColor3 = Theme.Theme.Surface}):Play()
        end)

        OptionButton.MouseButton1Click:Connect(function()
            setSelection(option)
            -- Collapse dropdown after selection
            TweenService:Create(OptionsFrame, Theme.Animations.Fast, {Size = UDim2.new(1, 0, 0, 0)}):Play()
            expanded = false
        end)
    end

    DropdownFrame.MouseButton1Click:Connect(function()
        expanded = not expanded
        local targetHeight = if expanded then #options * (25 + Theme.Spacing.XS) + Theme.Spacing.XS else 0
        TweenService:Create(OptionsFrame, Theme.Animations.Fast, {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
    end)

    return DropdownFrame
end

-- Sidebar Button Component
function Components:CreateSidebarButton(parent: GuiObject, iconAssetId: string, text: string, callback: () -> ())
    local Button = Instance.new("TextButton")
    Button.Name = "SidebarButton"
    Button.Size = UDim2.new(1, -Theme.Spacing.MD * 2, 0, 30)
    Button.Position = UDim2.new(0, Theme.Spacing.MD, 0, 0)
    Button.BackgroundColor3 = Theme.Theme.Sidebar
    Button.BorderSizePixel = 0
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 13
    Button.TextColor3 = Theme.Theme.Subtext
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.TextYAlignment = Enum.TextYAlignment.Center
    Button.Text = "   " .. text -- Add space for icon
    Button.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, Theme.Radius.Small)
    UICorner.Parent = Button

    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(0, 16, 0, 16)
    Icon.Position = UDim2.new(0, Theme.Spacing.XS, 0.5, -8)
    Icon.Image = iconAssetId
    Icon.ImageColor3 = Theme.Theme.Subtext
    Icon.BackgroundTransparency = 1
    Icon.Parent = Button

    local ActiveLine = Instance.new("Frame")
    ActiveLine.Name = "ActiveLine"
    ActiveLine.Size = UDim2.new(0, 3, 1, 0)
    ActiveLine.Position = UDim2.new(0, 0, 0, 0)
    ActiveLine.BackgroundColor3 = Theme.Theme.Accent
    ActiveLine.BorderSizePixel = 0
    ActiveLine.Visible = false
    ActiveLine.Parent = Button

    local originalTextColor = Button.TextColor3
    local originalIconColor = Icon.ImageColor3

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, Theme.Animations.Fast, {BackgroundColor3 = Theme.Theme.SurfaceHover}):Play()
        TweenService:Create(Button, Theme.Animations.Fast, {TextColor3 = Theme.Theme.Text}):Play()
        TweenService:Create(Icon, Theme.Animations.Fast, {ImageColor3 = Theme.Theme.Text}):Play()
    end)

    Button.MouseLeave:Connect(function()
        if not ActiveLine.Visible then
            TweenService:Create(Button, Theme.Animations.Fast, {BackgroundColor3 = Theme.Theme.Sidebar}):Play()
            TweenService:Create(Button, Theme.Animations.Fast, {TextColor3 = originalTextColor}):Play()
            TweenService:Create(Icon, Theme.Animations.Fast, {ImageColor3 = originalIconColor}):Play()
        end
    end)

    Button.MouseButton1Down:Connect(function()
        TweenService:Create(Button, Theme.Animations.Fast, {Size = UDim2.new(1, -Theme.Spacing.MD * 2, 0, 28), Position = UDim2.new(0, Theme.Spacing.MD, 0, 1)}):Play()
    end)

    Button.MouseButton1Up:Connect(function()
        TweenService:Create(Button, Theme.Animations.Fast, {Size = UDim2.new(1, -Theme.Spacing.MD * 2, 0, 30), Position = UDim2.new(0, Theme.Spacing.MD, 0, 0)}):Play()
        callback()
    end)

    function Button:SetActive(isActive: boolean)
        ActiveLine.Visible = isActive
        if isActive then
            Button.BackgroundColor3 = Theme.Theme.SurfaceHover
            Button.TextColor3 = Theme.Theme.Text
            Icon.ImageColor3 = Theme.Theme.Text
        else
            Button.BackgroundColor3 = Theme.Theme.Sidebar
            Button.TextColor3 = originalTextColor
            Icon.ImageColor3 = originalIconColor
        end
    end

    return Button
end
