-- ===== MAIN.LUA — UI only, loads backend from ui.lua =====
loadstring(game:HttpGet('https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/ui.lua'))()

local state          = _G.ChamsState
local settings       = state.settings
local highlightCache = state.highlightCache
local toggleChams    = state.toggleChams
local fullCleanup    = state.fullCleanup
local startNV        = state.startNV
local stopNV         = state.stopNV

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Volodym5/pfasdzxc231/refs/heads/main/lib.lua'))()

local Window = Rayfield:CreateWindow({
    Name                   = "Deadline Xeno - Chams",
    Icon                   = 0,
    LoadingTitle           = "Deadline Xeno",
    LoadingSubtitle        = "Chams Menu",
    Theme                  = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings   = false,
    ConfigurationSaving    = {
        Enabled    = true,
        FolderName = "DeadlineXeno",
        FileName   = "ChamsSettings"
    },
    KeySystem = false,
})

-- ===== MAIN TAB =====
local MainTab = Window:CreateTab("Chams", 4483362458)

MainTab:CreateSection("Toggle")
MainTab:CreateToggle({
    Name         = "Enable Chams",
    CurrentValue = settings.Enabled,
    Flag         = "ChamsEnabled",
    Callback     = function(v) toggleChams(v) end,
})

MainTab:CreateSection("Settings")
MainTab:CreateToggle({
    Name         = "Team Check",
    CurrentValue = settings.TeamCheck,
    Flag         = "TeamCheck",
    Callback     = function(v) settings.TeamCheck = v end,
})
MainTab:CreateToggle({
    Name         = "Visibility Check",
    CurrentValue = settings.VisibilityCheck,
    Flag         = "VisibilityCheck",
    Callback     = function(v) settings.VisibilityCheck = v end,
})

MainTab:CreateSection("Colors")
MainTab:CreateColorPicker({
    Name     = "Visible Color",
    Color    = settings.VisibleColor,
    Flag     = "VisibleColor",
    Callback = function(c) settings.VisibleColor = c end,
})
MainTab:CreateColorPicker({
    Name     = "Occluded Color",
    Color    = settings.OccludedColor,
    Flag     = "OccludedColor",
    Callback = function(c) settings.OccludedColor = c end,
})

MainTab:CreateSection("Transparency")
MainTab:CreateSlider({
    Name         = "Fill Transparency",
    Range        = {0, 1},
    Increment    = 0.05,
    CurrentValue = settings.FillTransparency,
    Flag         = "FillTrans",
    Callback     = function(v)
        settings.FillTransparency = v
        for _, h in pairs(highlightCache) do h.FillTransparency = v end
    end,
})
MainTab:CreateSlider({
    Name         = "Outline Transparency",
    Range        = {0, 1},
    Increment    = 0.05,
    CurrentValue = settings.OutlineTransparency,
    Flag         = "OutlineTrans",
    Callback     = function(v)
        settings.OutlineTransparency = v
        for _, h in pairs(highlightCache) do h.OutlineTransparency = v end
    end,
})

-- ===== MISC TAB =====
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateSection("Night Vision")
MiscTab:CreateToggle({
    Name         = "Night Vision",
    CurrentValue = settings.NightVision,
    Callback     = function(v)
        settings.NightVision = v
        if v then startNV() else stopNV() end
    end,
})

MiscTab:CreateSection("Utility")
MiscTab:CreateButton({
    Name     = "Unload",
    Callback = function()
        fullCleanup()
        Rayfield:Destroy()
    end,
})

Rayfield:LoadConfiguration()
