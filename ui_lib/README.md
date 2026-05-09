# Roblox UI Library

This is a Roblox UI library designed with a clean, compact, and professional aesthetic, inspired by modern desktop applications like Linear and Notion. It aims to provide a quiet, structured, and intentional user experience, avoiding flashy or oversized elements.

## Core Design Philosophy

The UI prioritizes a professional desktop app, developer software, or dashboard tool feel. This aesthetic is intended to age well and provide a premium look.

## Features

-   **Quiet, Compact, Structured, Intentional Design:** Focus on subtlety and functionality over flashy visuals.
-   **Low Contrast & Soft Layering:** Utilizes a carefully selected color palette with subtle blue tints.
-   **Consistent Spacing & Rounding Systems:** Ensures a cohesive and polished look across all UI elements.
-   **Microinteractions & Smooth Animations:** Enhances user experience with subtle hover effects, button presses, and transitions.
-   **Modular Components:** Easily create and manage UI elements like buttons, toggles, sliders, textboxes, dropdowns, and sections.
-   **Tabbed Navigation:** Organize content efficiently with a sidebar-based tab system.
-   **Search Functionality:** Integrated search bar in the topbar for quick navigation and filtering.
-   **Minimize/Maximize Window Controls:** Standard window controls for better user management.
-   **Resizable Window:** Users can adjust the window size to their preference.
-   **Custom Scrollbars:** Thin, low-contrast, and rounded scrollbars for a refined look.
-   **Subtle Noise Overlay:** Adds a delicate texture to backgrounds for a richer feel.

## Installation

1.  Download the `roblox_ui_lib` folder.
2.  Place the `roblox_ui_lib` folder into `ReplicatedStorage` in your Roblox Studio project.
3.  You can then `require` the modules from your local scripts.

## Usage

### Theme Configuration (`Theme.lua`)

This module defines the color palette, spacing, rounding, and animation settings. You can customize these values to match your project's needs.

```lua
local Theme = {
    Background = Color3.fromRGB(11, 12, 16),
    Sidebar = Color3.fromRGB(14, 15, 20),
    Surface = Color3.fromRGB(18, 19, 26),
    SurfaceHover = Color3.fromRGB(24, 25, 34),
    Border = Color3.fromRGB(38, 40, 52),
    Accent = Color3.fromRGB(99, 102, 241),
    Text = Color3.fromRGB(238, 240, 255),
    Subtext = Color3.fromRGB(150, 155, 175),
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(255, 184, 77),
}

local Spacing = {
    XS = 4,
    SM = 8,
    MD = 12,
    LG = 16,
    XL = 24
}

local Radius = {
    Small = 5,
    Medium = 8,
    Large = 12,
    Pill = 999
}

local Animations = {
    Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quint),
    Medium = TweenInfo.new(0.18, Enum.EasingStyle.Quint),
    Slow = TweenInfo.new(0.26, Enum.EasingStyle.Exponential),
}

return {Theme = Theme, Spacing = Spacing, Radius = Radius, Animations = Animations}
```

### Creating a Window (`UI.lua`)

The `UI` module is responsible for creating the main window structure, including the sidebar, topbar, and content area.

```lua
local UI = require(game.ReplicatedStorage.roblox_ui_lib.UI)

local window = UI:CreateWindow("My Awesome UI", 840, 560)
-- window.ScreenGui, window.MainWindow, window.Sidebar, window.MainArea, window.Topbar, window.ContentArea, window.SearchBar, window.ResizeCorner, window.SetCurrentTab
```

### Managing Tabs (`TabController.lua`)

The `TabController` module helps manage tabbed navigation within your UI.

```lua
local TabController = require(game.ReplicatedStorage.roblox_ui_lib.TabController)

local tabController = TabController:New(window.Sidebar, window.ContentArea, window.SetCurrentTab)

tabController:AddTab("Home", "rbxassetid://6032094984", function(parent)
    -- Add your UI components for the Home tab here
end)

tabController:AddTab("Settings", "rbxassetid://6032094984", function(parent)
    -- Add your UI components for the Settings tab here
end)

-- To switch tabs programmatically:
-- tabController:SwitchTab("Home")
```

### UI Components (`Components.lua`)

The `Components` module provides functions to create various UI elements.

```lua
local Components = require(game.ReplicatedStorage.roblox_ui_lib.Components)
local Theme = require(game.ReplicatedStorage.roblox_ui_lib.Theme)

-- Button
local button = Components:CreateButton(parentFrame, "Click Me", function()
    print("Button Clicked!")
end)

-- Toggle
local toggle = Components:CreateToggle(parentFrame, true, function(state)
    print("Toggle state: " .. tostring(state))
end)

-- Slider
local slider = Components:CreateSlider(parentFrame, 0, 100, 50, function(value)
    print("Slider value: " .. tostring(value))
end)

-- Textbox
local textbox = Components:CreateTextbox(parentFrame, "Enter text here", "", function(text)
    print("Textbox text: " .. text)
end)

-- Dropdown
local dropdown = Components:CreateDropdown(parentFrame, {"Option 1", "Option 2", "Option 3"}, "Option 1", function(selection)
    print("Dropdown selected: " .. selection)
end)

-- Label
local label = Components:CreateLabel(parentFrame, "Hello World!", 14, Theme.Theme.Text, Enum.TextXAlignment.Left)

-- Section
local section = Components:CreateSection(parentFrame, "My Section")
-- Add components to section.Content

-- Notification
Components:CreateNotification(window.ScreenGui, "Something happened!", "info")
```

## Example (`main.lua`)

Refer to `main.lua` for a complete example demonstrating how to use the library to create a functional UI with multiple tabs and components.

```lua
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UI = require(script.Parent.UI)
local Components = require(script.Parent.Components)
local TabController = require(script.Parent.TabController)
local Theme = require(script.Parent.Theme)

local window = UI:CreateWindow("My Awesome UI", 840, 560)
local tabController = TabController:New(window.Sidebar, window.ContentArea, window.SetCurrentTab)

-- Simple search functionality
window.SearchBar.Changed:Connect(function(text)
    print("Searching for: " .. text)
    -- Implement actual search logic here, e.g., filter visible components
end)

-- Add tabs
tabController:AddTab("Home", "rbxassetid://6032094984", function(parent)
    local section1 = Components:CreateSection(parent, "Welcome")
    section1.Frame.Size = UDim2.new(1, -Theme.Spacing.MD * 2, 0, 150)
    section1.Frame.Position = UDim2.new(0, Theme.Spacing.MD, 0, Theme.Spacing.MD)

    local welcomeLabel = Components:CreateLabel(section1.Content, "This is a custom Roblox UI library.", 14, Theme.Theme.Text, Enum.TextXAlignment.Center)
    welcomeLabel.Size = UDim2.new(1, 0, 0, 20)
    welcomeLabel.Position = UDim2.new(0, 0, 0, 0)

    local button = Components:CreateButton(section1.Content, "Click Me", function()
        print("Button Clicked!")
        Components:CreateNotification(window.ScreenGui, "Button Clicked!", "info")
    end)
    button.Size = UDim2.new(0, 100, 0, 30)
    button.Position = UDim2.new(0.5, -50, 0.5, 0)
end)

tabController:AddTab("Settings", "rbxassetid://6032094984", function(parent)
    local section1 = Components:CreateSection(parent, "General Settings")
    section1.Frame.Size = UDim2.new(1, -Theme.Spacing.MD * 2, 0, 200)
    section1.Frame.Position = UDim2.new(0, Theme.Spacing.MD, 0, Theme.Spacing.MD)

    local toggle = Components:CreateToggle(section1.Content, true, function(state)
        print("Toggle state: " .. tostring(state))
        Components:CreateNotification(window.ScreenGui, "Toggle: " .. tostring(state), "info")
    end)
    toggle.Position = UDim2.new(0, 0, 0, 0)

    local slider = Components:CreateSlider(section1.Content, 0, 100, 50, function(value)
        print("Slider value: " .. tostring(value))
    end)
    slider.Position = UDim2.new(0, 0, 0, 40)

    local textbox = Components:CreateTextbox(section1.Content, "Enter text here", "", function(text)
        print("Textbox text: " .. text)
    end)
    textbox.Position = UDim2.new(0, 0, 0, 80)

    local dropdown = Components:CreateDropdown(section1.Content, {"Option 1", "Option 2", "Option 3"}, "Option 1", function(selection)
        print("Dropdown selected: " .. selection)
    end)
    dropdown.Position = UDim2.new(0, 0, 0, 120)
end)

print("UI Library Initialized!")
```

## Icon Asset IDs

Note that placeholder asset IDs like `rbxassetid://6032094984` are used for icons. You will need to replace these with your actual icon asset IDs from Roblox.

## Contributing

Feel free to fork, modify, and improve this library. Contributions are welcome!

## License

This project is open-source and available under the MIT License.
