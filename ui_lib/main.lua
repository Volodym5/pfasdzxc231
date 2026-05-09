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

-- You can add more tabs here

-- Initial tab selection (optional, if not set, the first added tab will be active)
-- tabController:SwitchTab("Home")

print("UI Library Initialized!")
