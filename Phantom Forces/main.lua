-- Phantom Forces - Main Loader

loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/Phantom%20Forces/esp.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/Phantom%20Forces/aimbot.lua"))()
local libary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/puppyware.lua"))()
local NotifyLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/puppyware_notify.lua"))()
local Notify = NotifyLibrary.Notify

repeat task.wait() until _G.PF_ESP_Settings and _G.PF_ESP_Functions and _G.PF_Aimbot_Settings

local espSettings = _G.PF_ESP_Settings
local aimSettings = _G.PF_Aimbot_Settings
local espFuncs = _G.PF_ESP_Functions

Notify({Title = "Phantom Forces", Description = "UI Loaded", Duration = 3})

local Window = libary:new({
    name = "Phantom Forces",
    accent = Color3.fromRGB(255, 70, 70),
    textsize = 13
})

local AimbotTab = Window:page({name = "Aimbot"})
local VisualsTab = Window:page({name = "Visuals"})
local ConfigTab = Window:page({name = "Config"})

-- ===== AIMBOT =====
local AimbotMain = AimbotTab:section({name = "Aimbot", side = "left", size = 250})
AimbotMain:toggle({name = "Enabled", def = aimSettings.Enabled, callback = function(v) aimSettings.Enabled = v end})
AimbotMain:toggle({name = "Team Check", def = aimSettings.TeamCheck, callback = function(v) aimSettings.TeamCheck = v end})
AimbotMain:toggle({name = "Visibility Check", def = aimSettings.VisibilityCheck, callback = function(v) aimSettings.VisibilityCheck = v end})
AimbotMain:slider({name = "Field of View", def = aimSettings.FOV, max = 500, min = 10, rounding = true, callback = function(v) aimSettings.FOV = v end})

local AimbotSettings = AimbotTab:section({name = "Settings", side = "right", size = 250})
AimbotSettings:dropdown({name = "Target Part", def = aimSettings.TargetPart, max = 2, options = {"Head", "Torso"}, callback = function(v) aimSettings.TargetPart = v end})
AimbotSettings:dropdown({name = "Aim Mode", def = aimSettings.Mode, max = 2, options = {"Camera", "Mouse"}, callback = function(v) aimSettings.Mode = v end})
AimbotSettings:toggle({name = "Smoothness", def = aimSettings.Smoothness, callback = function(v) aimSettings.Smoothness = v end})
AimbotSettings:slider({name = "Smoothness Amount", def = 5, max = 10, min = 1, rounding = true, callback = function(v) aimSettings.SmoothAmount = v / 10 end})
AimbotSettings:toggle({name = "Prediction", def = aimSettings.Prediction, callback = function(v) aimSettings.Prediction = v end})
AimbotSettings:slider({name = "Prediction Amount", def = aimSettings.PredAmount, max = 60, min = 1, rounding = true, callback = function(v) aimSettings.PredAmount = v end})
AimbotSettings:toggle({name = "Show FOV Circle", def = aimSettings.ShowFOV, callback = function(v) aimSettings.ShowFOV = v end})
AimbotSettings:colorpicker({name = "FOV Color", cpname = "", def = aimSettings.FOVColor, callback = function(c) aimSettings.FOVColor = c end})

-- Manual aim offset sliders
local OffsetSection = AimbotTab:section({name = "Aim Offset", side = "left", size = 250})
OffsetSection:slider({name = "Vertical Offset", def = 0, max = 50, min = -50, rounding = true, callback = function(v) aimSettings.VerticalOffset = v / 10 end})
OffsetSection:slider({name = "Horizontal Offset", def = 0, max = 50, min = -50, rounding = true, callback = function(v) aimSettings.HorizontalOffset = v / 10 end})

-- ===== ESP =====
local ESPMain = VisualsTab:section({name = "ESP", side = "left", size = 250})
ESPMain:toggle({name = "Enabled", def = espSettings.Enabled, callback = function(v) espSettings.Enabled = v; espFuncs.RefreshCache() end})
ESPMain:toggle({name = "Team Check", def = espSettings.TeamCheck, callback = function(v) espSettings.TeamCheck = v end})
ESPMain:toggle({name = "Visibility Check", def = espSettings.VisibilityCheck, callback = function(v) espSettings.VisibilityCheck = v end})
ESPMain:toggle({name = "Boxes", def = espSettings.Boxes, callback = function(v) espSettings.Boxes = v end})
ESPMain:toggle({name = "Tracers", def = espSettings.Tracers, callback = function(v) espSettings.Tracers = v end})
ESPMain:toggle({name = "Names", def = espSettings.Names, callback = function(v) espSettings.Names = v end})
ESPMain:toggle({name = "Tracer from Crosshair", def = espSettings.TracerFromCrosshair, callback = function(v) espSettings.TracerFromCrosshair = v end})
ESPMain:slider({name = "Max Distance", def = espSettings.MaxDistance, max = 3000, min = 100, rounding = true, callback = function(v) espSettings.MaxDistance = v end})

local ESPLook = VisualsTab:section({name = "ESP Look", side = "right", size = 250})
ESPLook:colorpicker({name = "Visible Color", cpname = "", def = espSettings.EnemyColor, callback = function(c) espSettings.EnemyColor = c end})
ESPLook:colorpicker({name = "Occluded Color", cpname = "", def = espSettings.OccludedColor, callback = function(c) espSettings.OccludedColor = c end})
ESPLook:slider({name = "Box Thickness", def = espSettings.BoxThickness, max = 3, min = 1, rounding = true, callback = function(v) espSettings.BoxThickness = v end})
ESPLook:slider({name = "Tracer Thickness", def = espSettings.TracerThickness, max = 2, min = 1, rounding = true, callback = function(v) espSettings.TracerThickness = v end})

local ChamMain = VisualsTab:section({name = "Chams (Highlight)", side = "left", size = 250})
ChamMain:toggle({name = "Enabled", def = espSettings.Chams, callback = function(v) espSettings.Chams = v; espFuncs.RefreshCache() end})
ChamMain:colorpicker({name = "Visible Color", cpname = "", def = espSettings.ChamColor, callback = function(c) espSettings.ChamColor = c end})
ChamMain:colorpicker({name = "Occluded Color", cpname = "", def = espSettings.ChamOccludedColor, callback = function(c) espSettings.ChamOccludedColor = c end})
ChamMain:slider({name = "Transparency", def = 75, max = 100, min = 0, rounding = true, callback = function(v) espSettings.ChamFillTransparency = v / 100 end})

-- ===== Config =====
local ConfigSection = ConfigTab:section({name = "Config", side = "left", size = 250})
ConfigSection:configloader({folder = "pf_configs"})

ConfigSection:keybind({
    name = "Menu Keybind",
    def = Enum.KeyCode.RightShift,
    callback = function(newKey)
        libary.ToggleKeybind = newKey
    end
})
libary.ToggleKeybind = Enum.KeyCode.RightShift

local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        espSettings.Enabled = not espSettings.Enabled
        espFuncs.RefreshCache()
    elseif input.KeyCode == Enum.KeyCode.Delete then
        aimSettings.Enabled = not aimSettings.Enabled
    elseif input.KeyCode == Enum.KeyCode.PageUp then
        espSettings.Chams = not espSettings.Chams
        espFuncs.RefreshCache()
    elseif input.KeyCode == Enum.KeyCode.Home then
        espSettings.Boxes = not espSettings.Boxes
        espSettings.Tracers = not espSettings.Tracers
    end
end)

Notify({Title = "Hotkeys", Description = "Insert=ESP | Del=Aimbot | PgUp=Chams | Home=Box/Tracer", Duration = 8})

AimbotTab:openpage()
