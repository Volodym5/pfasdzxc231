local cloneref = cloneref or clonereference or function(instance)
    return instance
end

local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local function safeParent(Instance)
    local success = pcall(function()
        if Instance and Instance.Parent ~= CoreGui then
            Instance.Parent = CoreGui
        end
    end)

    if not success or not Instance.Parent then
        Instance.Parent = LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    elseif value > maxValue then
        return maxValue
    end
    return value
end

local function round(value, precision)
    precision = precision or 0
    local factor = 10 ^ precision
    return math.floor(value * factor + 0.5) / factor
end

local function stopTween(tween)
    if tween and tween.PlaybackState == Enum.PlaybackState.Playing then
        tween:Cancel()
    end
end

local function createTween(instance, info, goals)
    if not instance then
        return
    end

    if instance._currentTween then
        stopTween(instance._currentTween)
    end

    local tween = TweenService:Create(instance, info, goals)
    instance._currentTween = tween
    tween:Play()
    return tween
end

local function createInstance(className, properties)
    local instance = Instance.new(className)
    if properties then
        for key, value in pairs(properties) do
            if key ~= "Parent" then
                instance[key] = value
            end
        end
        if properties.Parent then
            instance.Parent = properties.Parent
        end
    end
    return instance
end

local Library = {
    ScreenGui = nil,
    Theme = {
        Background = Color3.fromRGB(20, 22, 33),
        Panel = Color3.fromRGB(28, 31, 47),
        Surface = Color3.fromRGB(37, 42, 61),
        Accent = Color3.fromRGB(108, 99, 255),
        AccentLight = Color3.fromRGB(147, 137, 255),
        Text = Color3.fromRGB(241, 244, 255),
        MutedText = Color3.fromRGB(155, 166, 194),
        Border = Color3.fromRGB(58, 66, 87),
        Negative = Color3.fromRGB(255, 100, 100),
    },
    ZIndex = {
        Window = 1000,
        Popup = 1100,
        Toast = 1200,
    },
    TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Toasts = {},
}

function Library:InitScreenGui()
    if self.ScreenGui then
        return self.ScreenGui
    end

    local screenGui = createInstance("ScreenGui", {
        Name = "FramerUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
    })
    safeParent(screenGui)
    self.ScreenGui = screenGui
    return screenGui
end

function Library:SafeCallback(func, ...)
    if typeof(func) ~= "function" then
        return
    end

    local success, result = pcall(func, ...)
    if not success then
        warn("FramerUI callback error:", result)
    end
    return result
end

function Library:CreateWindow(options)
    options = options or {}
    local windowTitle = options.Title or "FramerUI"
    local footerText = options.Footer or "Powered by FramerUI"
    local width = options.Width or 760
    local height = options.Height or 520
    local minWidth = options.MinWidth or 560
    local minHeight = options.MinHeight or 340

    local screenGui = self:InitScreenGui()

    local window = createInstance("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = self.Theme.Panel,
        BorderSizePixel = 0,
        Parent = screenGui,
    })
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 18),
        Parent = window,
    })
    createInstance("UIStroke", {
        Color = self.Theme.Border,
        Transparency = 0.4,
        Thickness = 1,
        Parent = window,
    })

    local header = createInstance("Frame", {
        Name = "Header",
        BackgroundColor3 = Color3.fromRGB(18, 20, 31),
        Size = UDim2.new(1, 0, 0, 52),
        Parent = window,
    })
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 18),
        Parent = header,
    })

    local headerPadding = createInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        Parent = header,
    })

    local titleLabel = createInstance("TextLabel", {
        Name = "TitleLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -104, 1, 0),
        Text = windowTitle,
        Font = Enum.Font.GothamSemibold,
        TextSize = 20,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = header,
    })

    local headerButtons = createInstance("Frame", {
        Name = "HeaderButtons",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 88, 1, 0),
        Position = UDim2.new(1, -88, 0, 0),
        Parent = header,
    })
    createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = headerButtons,
    })

    local function createHeaderButton(iconText, tooltip)
        local button = createInstance("TextButton", {
            BackgroundColor3 = self.Theme.Surface,
            Size = UDim2.new(0, 36, 0, 36),
            Text = iconText,
            Font = Enum.Font.Code,
            TextSize = 18,
            TextColor3 = self.Theme.Text,
            BorderSizePixel = 0,
            Parent = headerButtons,
        })
        createInstance("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = button,
        })
        button.MouseEnter:Connect(function()
            createTween(button, self.TweenInfo, {BackgroundColor3 = self.Theme.Accent})
        end)
        button.MouseLeave:Connect(function()
            createTween(button, self.TweenInfo, {BackgroundColor3 = self.Theme.Surface})
        end)
        return button
    end

    local minimizeButton = createHeaderButton("—")
    local closeButton = createHeaderButton("✕")

    local body = createInstance("Frame", {
        Name = "Body",
        BackgroundColor3 = self.Theme.Background,
        Position = UDim2.new(0, 0, 0, 52),
        Size = UDim2.new(1, 0, 1, -92),
        Parent = window,
    })
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 18),
        Parent = body,
    })

    local footer = createInstance("Frame", {
        Name = "Footer",
        BackgroundColor3 = Color3.fromRGB(16, 17, 26),
        Position = UDim2.new(0, 0, 1, -40),
        Size = UDim2.new(1, 0, 0, 40),
        Parent = window,
    })
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 0),
        Parent = footer,
    })
    createInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingTop = UDim.new(0, 8),
        Parent = footer,
    })

    local footerLabel = createInstance("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = footerText,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = self.Theme.MutedText,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = footer,
    })

    local navPanel = createInstance("Frame", {
        Name = "NavPanel",
        BackgroundColor3 = self.Theme.Panel,
        Size = UDim2.new(0, 180, 1, -92),
        Parent = body,
    })
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 16),
        Parent = navPanel,
    })

    local navLayout = createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 8),
        Parent = navPanel,
    })
    createInstance("UIPadding", {
        PaddingTop = UDim.new(0, 14),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = navPanel,
    })

    local content = createInstance("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 190, 0, 0),
        Size = UDim2.new(1, -190, 1, -92),
        Parent = body,
    })
    local contentLayout = createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 16),
        Parent = content,
    })
    createInstance("UIPadding", {
        PaddingTop = UDim.new(0, 16),
        PaddingBottom = UDim.new(0, 16),
        PaddingLeft = UDim.new(0, 18),
        PaddingRight = UDim.new(0, 18),
        Parent = content,
    })

    local WindowObject = {
        Root = window,
        Header = header,
        NavPanel = navPanel,
        Content = content,
        Tabs = {},
        ActiveTab = nil,
        Minimized = false,
        MinSize = Vector2.new(minWidth, minHeight),
        FullSize = Vector2.new(width, height),
        Library = self,
    }

    function WindowObject:SetActiveTab(tab)
        if self.ActiveTab == tab then
            return
        end
        if self.ActiveTab then
            self.ActiveTab.Page.Visible = false
            self.ActiveTab.Button.BackgroundColor3 = self.Library.Theme.Surface
            self.ActiveTab.Button.TextColor3 = self.Library.Theme.Text
        end
        self.ActiveTab = tab
        self.ActiveTab.Page.Visible = true
        self.ActiveTab.Button.BackgroundColor3 = self.Library.Accent or self.Library.Theme.Accent
        self.ActiveTab.Button.TextColor3 = Color3.new(1, 1, 1)
    end

    function WindowObject:AddTab(name)
        local tabButton = createInstance("TextButton", {
            BackgroundColor3 = self.Library.Theme.Surface,
            Size = UDim2.new(1, 0, 0, 40),
            Text = name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            TextColor3 = self.Library.Theme.Text,
            BorderSizePixel = 0,
            Parent = self.NavPanel,
        })
        createInstance("UICorner", {
            CornerRadius = UDim.new(0, 12),
            Parent = tabButton,
        })

        local page = createInstance("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            Parent = self.Content,
        })
        createInstance("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 16),
            Parent = page,
        })
        createInstance("UIPadding", {
            PaddingTop = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 0),
            PaddingRight = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 0),
            Parent = page,
        })

        local tab = {
            Name = name,
            Button = tabButton,
            Page = page,
            Sections = {},
            Window = self,
        }

        tabButton.MouseButton1Click:Connect(function()
            self:SetActiveTab(tab)
        end)

        function tab:AddSection(title)
            local section = createInstance("Frame", {
                BackgroundColor3 = self.Window.Library.Theme.Panel,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = self.Page,
            })
            createInstance("UICorner", {
                CornerRadius = UDim.new(0, 14),
                Parent = section,
            })
            createInstance("UIStroke", {
                Color = self.Window.Library.Theme.Border,
                Transparency = 0.35,
                Thickness = 1,
                Parent = section,
            })
            createInstance("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 10),
                Parent = section,
            })
            createInstance("UIPadding", {
                PaddingLeft = UDim.new(0, 16),
                PaddingRight = UDim.new(0, 16),
                PaddingTop = UDim.new(0, 16),
                PaddingBottom = UDim.new(0, 18),
                Parent = section,
            })

            local header = createInstance("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                Text = title,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = self.Window.Library.Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section,
            })

            local sectionContent = createInstance("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = section,
            })
            createInstance("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 10),
                Parent = sectionContent,
            })
            createInstance("UIPadding", {
                PaddingLeft = UDim.new(0, 0),
                PaddingRight = UDim.new(0, 0),
                PaddingTop = UDim.new(0, 0),
                PaddingBottom = UDim.new(0, 0),
                Parent = sectionContent,
            })

            local group = {
                Title = title,
                Root = section,
                Content = sectionContent,
                Tab = self,
            }

            function group:AddButton(text, callback)
                local buttonFrame = createInstance("Frame", {
                    BackgroundColor3 = self.Tab.Window.Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, 44),
                    Parent = self.Content,
                })
                createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                    Parent = buttonFrame,
                })

                local button = createInstance("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 1, 1, 0),
                    Text = text,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 15,
                    TextColor3 = self.Tab.Window.Library.Theme.Text,
                    Parent = buttonFrame,
                })

                button.MouseEnter:Connect(function()
                    createTween(buttonFrame, self.Tab.Window.Library.TweenInfo, {BackgroundColor3 = self.Tab.Window.Library.Theme.Accent})
                end)
                button.MouseLeave:Connect(function()
                    createTween(buttonFrame, self.Tab.Window.Library.TweenInfo, {BackgroundColor3 = self.Tab.Window.Library.Theme.Surface})
                end)
                button.MouseButton1Click:Connect(function()
                    self.Tab.Window.Library:SafeCallback(callback, true)
                end)

                return button
            end

            function group:AddToggle(text, default, callback)
                local row = createInstance("Frame", {
                    BackgroundColor3 = self.Tab.Window.Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, 44),
                    Parent = self.Content,
                })
                createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                    Parent = row,
                })
                createInstance("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 12),
                    Parent = row,
                })
                createInstance("UIPadding", {
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 14),
                    Parent = row,
                })

                local label = createInstance("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = text,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextColor3 = self.Tab.Window.Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })

                local switch = createInstance("Frame", {
                    BackgroundColor3 = default and self.Tab.Window.Library.Theme.Accent or self.Tab.Window.Library.Theme.Border,
                    Size = UDim2.new(0, 0, 0, 24),
                    Size = UDim2.fromOffset(48, 24),
                    Parent = row,
                })
                createInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = switch,
                })

                local knob = createInstance("Frame", {
                    BackgroundColor3 = self.Tab.Window.Library.Theme.Text,
                    Size = UDim2.fromOffset(18, 18),
                    Position = default and UDim2.fromOffset(26, 3) or UDim2.fromOffset(4, 3),
                    Parent = switch,
                })
                createInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = knob,
                })

                local toggled = default
                local function updateState(value)
                    toggled = value
                    createTween(switch, self.Tab.Window.Library.TweenInfo, {BackgroundColor3 = value and self.Tab.Window.Library.Theme.Accent or self.Tab.Window.Library.Theme.Border})
                    createTween(knob, self.Tab.Window.Library.TweenInfo, {Position = value and UDim2.fromOffset(26, 3) or UDim2.fromOffset(4, 3)})
                    self.Tab.Window.Library:SafeCallback(callback, value)
                end

                row.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        updateState(not toggled)
                    end
                end)

                return {
                    Set = updateState,
                    Get = function() return toggled end,
                    Root = row,
                }
            end

            function group:AddSlider(text, minValue, maxValue, defaultValue, callback)
                minValue = minValue or 0
                maxValue = maxValue or 100
                defaultValue = clamp(defaultValue or minValue, minValue, maxValue)

                local wrapper = createInstance("Frame", {
                    BackgroundColor3 = self.Tab.Window.Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, 80),
                    Parent = self.Content,
                })
                createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                    Parent = wrapper,
                })
                createInstance("UIPadding", {
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                    PaddingTop = UDim.new(0, 12),
                    Parent = wrapper,
                })
                createInstance("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    VerticalAlignment = Enum.VerticalAlignment.Top,
                    Padding = UDim.new(0, 8),
                    Parent = wrapper,
                })

                local label = createInstance("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Text = text,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextColor3 = self.Tab.Window.Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = wrapper,
                })

                local sliderBar = createInstance("Frame", {
                    BackgroundColor3 = self.Tab.Window.Library.Theme.Border,
                    Size = UDim2.new(1, 0, 0, 12),
                    Parent = wrapper,
                })
                createInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = sliderBar,
                })

                local fill = createInstance("Frame", {
                    BackgroundColor3 = self.Tab.Window.Library.Theme.Accent,
                    Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0),
                    Parent = sliderBar,
                })
                createInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = fill,
                })

                local handle = createInstance("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = self.Tab.Window.Library.Theme.Text,
                    Size = UDim2.fromOffset(20, 20),
                    Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0),
                    Parent = sliderBar,
                })
                createInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = handle,
                })

                local valueLabel = createInstance("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Text = tostring(defaultValue),
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextColor3 = self.Tab.Window.Library.Theme.MutedText,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = wrapper,
                })

                local dragging = false
                local currentValue = defaultValue

                local function updateSlider(value)
                    currentValue = clamp(round(value, 0), minValue, maxValue)
                    local normalized = (currentValue - minValue) / (maxValue - minValue)
                    fill.Size = UDim2.new(normalized, 0, 1, 0)
                    handle.Position = UDim2.new(normalized, 0, 0.5, 0)
                    valueLabel.Text = tostring(currentValue)
                    self.Tab.Window.Library:SafeCallback(callback, currentValue)
                end

                handle.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if not dragging then
                        return
                    end
                    if input.UserInputType ~= Enum.UserInputType.MouseMovement then
                        return
                    end

                    local barAbsolute = sliderBar.AbsolutePosition.X
                    local barWidth = sliderBar.AbsoluteSize.X
                    local mouseX = math.clamp(input.Position.X - barAbsolute, 0, barWidth)
                    local percent = mouseX / barWidth
                    updateSlider(minValue + percent * (maxValue - minValue))
                end)

                return {
                    Set = updateSlider,
                    Get = function() return currentValue end,
                    Root = wrapper,
                }
            end

            function group:AddDropdown(text, values, callback)
                values = values or {}
                local selected = values[1]

                local wrapper = createInstance("Frame", {
                    BackgroundColor3 = self.Tab.Window.Library.Theme.Surface,
                    Size = UDim2.new(1, 0, 0, 54),
                    Parent = self.Content,
                })
                createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 14),
                    Parent = wrapper,
                })
                createInstance("UIPadding", {
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                    PaddingTop = UDim.new(0, 12),
                    PaddingBottom = UDim.new(0, 12),
                    Parent = wrapper,
                })
                createInstance("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    Padding = UDim.new(0, 8),
                    Parent = wrapper,
                })

                local label = createInstance("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Text = text,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextColor3 = self.Tab.Window.Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = wrapper,
                })

                local button = createInstance("TextButton", {
                    BackgroundColor3 = self.Tab.Window.Library.Theme.Panel,
                    Size = UDim2.new(1, 0, 0, 28),
                    Text = tostring(selected),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 14,
                    TextColor3 = self.Tab.Window.Library.Theme.Text,
                    BorderSizePixel = 0,
                    Parent = wrapper,
                })
                createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 12),
                    Parent = button,
                })

                local listHolder = createInstance("Frame", {
                    BackgroundColor3 = self.Tab.Window.Library.Theme.Panel,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 8),
                    Visible = false,
                    Parent = wrapper,
                })
                createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 14),
                    Parent = listHolder,
                })
                createInstance("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    Padding = UDim.new(0, 0),
                    Parent = listHolder,
                })
                createInstance("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    Parent = listHolder,
                })

                local function refreshMenu()
                    for _, child in ipairs(listHolder:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    for _, option in ipairs(values) do
                        local entry = createInstance("TextButton", {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 30),
                            Text = tostring(option),
                            Font = Enum.Font.Gotham,
                            TextSize = 14,
                            TextColor3 = self.Tab.Window.Library.Theme.Text,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BorderSizePixel = 0,
                            Parent = listHolder,
                        })
                        entry.MouseButton1Click:Connect(function()
                            selected = option
                            button.Text = tostring(option)
                            listHolder.Visible = false
                            self.Tab.Window.Library:SafeCallback(callback, option)
                        end)
                        entry.MouseEnter:Connect(function()
                            createTween(entry, self.Tab.Window.Library.TweenInfo, {TextColor3 = self.Tab.Window.Library.Theme.AccentLight})
                        end)
                        entry.MouseLeave:Connect(function()
                            createTween(entry, self.Tab.Window.Library.TweenInfo, {TextColor3 = self.Tab.Window.Library.Theme.Text})
                        end)
                    end
                    listHolder.Size = UDim2.new(1, 0, 0, #values * 30 + 8)
                end

                button.MouseButton1Click:Connect(function()
                    listHolder.Visible = not listHolder.Visible
                end)
                refreshMenu()

                return {
                    Get = function() return selected end,
                    Set = function(value)
                        if table.find(values, value) then
                            selected = value
                            button.Text = tostring(value)
                        end
                    end,
                    Root = wrapper,
                }
            end

            function group:AddLabel(text)
                local label = createInstance("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Text = text,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextColor3 = self.Tab.Window.Library.Theme.MutedText,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    Parent = self.Content,
                })
                return label
            end

            table.insert(self.Sections, group)
            return group
        end

        table.insert(self.Tabs, tab)
        if #self.Tabs == 1 then
            self:SetActiveTab(tab)
        end
        return tab
    end

    function WindowObject:Minimize()
        local targetHeight = self.Minimized and self.FullSize.Y or 52
        self.Minimized = not self.Minimized
        self.Content.Visible = not self.Minimized
        self.NavPanel.Visible = not self.Minimized
        self.Root.Size = self.Minimized and UDim2.new(0, self.FullSize.X, 0, targetHeight) or UDim2.fromOffset(self.FullSize.X, self.FullSize.Y)
        self.Root.Position = UDim2.fromScale(0.5, 0.5)
    end

    minimizeButton.MouseButton1Click:Connect(function()
        WindowObject:Minimize()
    end)
    closeButton.MouseButton1Click:Connect(function()
        window.Visible = false
    end)

    return WindowObject
end

function Library:Notify(message, duration)
    duration = duration or 2.8
    local screenGui = self:InitScreenGui()
    local listRoot = screenGui:FindFirstChild("ToastRoot")
    if not listRoot then
        listRoot = createInstance("Frame", {
            Name = "ToastRoot",
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -18, 0, 18),
            Size = UDim2.new(0, 300, 0, 0),
            BackgroundTransparency = 1,
            Parent = screenGui,
            ZIndex = self.ZIndex.Toast,
        })
        createInstance("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, 10),
            Parent = listRoot,
        })
    end

    local toast = createInstance("Frame", {
        BackgroundColor3 = self.Theme.Panel,
        Size = UDim2.new(1, 0, 0, 54),
        Parent = listRoot,
        ZIndex = self.ZIndex.Toast,
    })
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 14),
        Parent = toast,
    })
    createInstance("UIStroke", {
        Color = self.Theme.Border,
        Transparency = 0.35,
        Thickness = 1,
        Parent = toast,
    })
    createInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = toast,
    })

    local label = createInstance("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = message,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = toast,
    })

    toast.BackgroundTransparency = 1
    createTween(toast, self.TweenInfo, {BackgroundTransparency = 0})

    spawn(function()
        task.wait(duration)
        createTween(toast, self.TweenInfo, {BackgroundTransparency = 1})
        task.wait(self.TweenInfo.Time + 0.05)
        if toast and toast.Parent then
            toast:Destroy()
        end
    end)
end

function Library:Dialog(options)
    options = options or {}
    local screenGui = self:InitScreenGui()
    local overlay = createInstance("Frame", {
        Name = "DialogOverlay",
        BackgroundColor3 = Color3.fromRGB(10, 10, 15),
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = screenGui,
        ZIndex = self.ZIndex.Popup,
    })

    local dialog = createInstance("Frame", {
        Name = "Dialog",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(420, 240),
        BackgroundColor3 = self.Theme.Panel,
        Parent = overlay,
    })
    createInstance("UICorner", {
        CornerRadius = UDim.new(0, 20),
        Parent = dialog,
    })
    createInstance("UIStroke", {
        Color = self.Theme.Border,
        Transparency = 0.35,
        Thickness = 1,
        Parent = dialog,
    })
    createInstance("UIPadding", {
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20),
        PaddingTop = UDim.new(0, 18),
        PaddingBottom = UDim.new(0, 18),
        Parent = dialog,
    })
    createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 16),
        Parent = dialog,
    })

    local title = createInstance("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Text = options.Title or "Dialog",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dialog,
    })

    local bodyText = createInstance("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 80),
        Text = options.Description or "",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = self.Theme.MutedText,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = dialog,
    })

    local buttonContainer = createInstance("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = dialog,
    })
    createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 10),
        Parent = buttonContainer,
    })

    local buttons = options.FooterButtons or {{Text = "Close", Callback = function() end}}
    for _, info in ipairs(buttons) do
        local button = createInstance("TextButton", {
            BackgroundColor3 = self.Theme.Surface,
            Size = UDim2.new(0, 100, 1, 0),
            Text = info.Text or "Button",
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            TextColor3 = self.Theme.Text,
            BorderSizePixel = 0,
            Parent = buttonContainer,
        })
        createInstance("UICorner", {
            CornerRadius = UDim.new(0, 12),
            Parent = button,
        })
        button.MouseButton1Click:Connect(function()
            self:SafeCallback(info.Callback)
            overlay:Destroy()
        end)
    end

    return dialog
end

return Library
