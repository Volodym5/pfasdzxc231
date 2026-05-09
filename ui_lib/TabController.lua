--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)
local Components = require(script.Parent.Components)

local TabController = {}

function TabController:New(sidebarFrame: Frame, contentAreaFrame: Frame, setCurrentTabCallback: (tabName: string) -> ())
    local self = {}
    self.sidebarFrame = sidebarFrame
    self.contentAreaFrame = contentAreaFrame
    self.setCurrentTabCallback = setCurrentTabCallback
    self.tabs = {}
    self.activeTab = nil

    function self:AddTab(tabName: string, iconAssetId: string, contentBuilder: (parent: GuiObject) -> ())
        local tabContentFrame = Instance.new("Frame")
        tabContentFrame.Name = tabName .. "TabContent"
        tabContentFrame.Size = UDim2.new(1, 0, 1, 0)
        tabContentFrame.Position = UDim2.new(0, 0, 0, 0)
        tabContentFrame.BackgroundColor3 = Theme.Theme.Background
        tabContentFrame.BackgroundTransparency = 1
        tabContentFrame.BorderSizePixel = 0
        tabContentFrame.ClipsDescendants = true
        tabContentFrame.Visible = false
        tabContentFrame.Parent = self.contentAreaFrame

        contentBuilder(tabContentFrame)

        local sidebarButton = Components:CreateSidebarButton(self.sidebarFrame, iconAssetId, tabName, function()
            self:SwitchTab(tabName)
        end)
        sidebarButton.LayoutOrder = #self.tabs + 1

        self.tabs[tabName] = {
            contentFrame = tabContentFrame,
            sidebarButton = sidebarButton
        }

        if not self.activeTab then
            self:SwitchTab(tabName)
        end
    end

    function self:SwitchTab(tabName: string)
        if self.activeTab == tabName then return end

        if self.activeTab then
            local oldTab = self.tabs[self.activeTab]
            if oldTab then
                oldTab.sidebarButton:SetActive(false)
                TweenService:Create(oldTab.contentFrame, Theme.Animations.Fast, {BackgroundTransparency = 1, Position = UDim2.new(0, -50, 0, 0)}):Play()
                task.delay(Theme.Animations.Fast.Time, function()
                    oldTab.contentFrame.Visible = false
                end)
            end
        end

        local newTab = self.tabs[tabName]
        if newTab then
            newTab.contentFrame.Position = UDim2.new(0, 50, 0, 0)
            newTab.contentFrame.BackgroundTransparency = 1
            newTab.contentFrame.Visible = true
            newTab.sidebarButton:SetActive(true)
            TweenService:Create(newTab.contentFrame, Theme.Animations.Fast, {BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}):Play()
            self.activeTab = tabName
            self.setCurrentTabCallback(tabName)
        end
    end

    return self
end

return TabController
