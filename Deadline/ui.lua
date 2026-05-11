-- ===== UI.LUA — UI only, loads backend from main.lua =====
loadstring(game:HttpGet('https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/Deadline/main.lua'))()

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/rayfield.lua'))()

local state          = _G.ChamsState
local settings       = state.settings
local highlightCache = state.highlightCache
local toggleChams    = state.toggleChams
local fullCleanup    = state.fullCleanup
local setNoShake      = state.setNoShake
local setNoBlur       = state.setNoBlur
local flashKiller     = state.flashKiller
local suppressionKiller = state.suppressionKiller
local explosionKiller = state.explosionKiller
local waterKiller     = state.waterKiller
local startAimbot     = state.startAimbot
local stopAimbot      = state.stopAimbot
local updateFOVCircle = state.updateFOVCircle

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

-- ===== MAIN TAB (VISUALS)=====
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

-- ===== AIMBOT TAB =====
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)

AimbotTab:CreateSection("Main")
AimbotTab:CreateToggle({
    Name         = "Enable Aimbot",
    CurrentValue = settings.AimbotEnabled,
    Flag         = "AimbotEnabled",
    Callback     = function(v)
        settings.AimbotEnabled = v
        if v then startAimbot() else stopAimbot() end
    end,
})

AimbotTab:CreateSection("Settings")
AimbotTab:CreateSlider({
    Name         = "FOV",
    Range        = {50, 500},
    Increment    = 10,
    CurrentValue = settings.AimbotFOV,
    Flag         = "AimbotFOV",
    Callback     = function(v)
        settings.AimbotFOV = v
        updateFOVCircle()
    end,
})

AimbotTab:CreateSlider({
    Name         = "Smoothness",
    Range        = {0, 1},
    Increment    = 0.1,
    CurrentValue = settings.AimbotSmoothness,
    Flag         = "AimbotSmoothness",
    Callback     = function(v)
        settings.AimbotSmoothness = v
    end,
})

AimbotTab:CreateSection("FOV Circle")
AimbotTab:CreateToggle({
    Name         = "Show FOV Circle",
    CurrentValue = settings.AimbotShowFOV,
    Flag         = "ShowFOV",
    Callback     = function(v)
        settings.AimbotShowFOV = v
        updateFOVCircle()
    end,
})

AimbotTab:CreateColorPicker({
    Name     = "FOV Color",
    Color    = settings.AimbotFOVColor,
    Flag     = "FOVColor",
    Callback = function(c)
        settings.AimbotFOVColor = c
        updateFOVCircle()
    end,
})

AimbotTab:CreateSlider({
    Name         = "FOV Transparency",
    Range        = {0, 1},
    Increment    = 0.1,
    CurrentValue = settings.AimbotFOVTransparency,
    Flag         = "FOVTrans",
    Callback     = function(v)
        settings.AimbotFOVTransparency = v
        updateFOVCircle()
    end,
})

-- ===== MISC TAB =====
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateSection("Camera")
MiscTab:CreateToggle({
    Name = "No Camera Shake", CurrentValue = false,
    Callback = function(v) setNoShake(v) end,
})
MiscTab:CreateToggle({
    Name = "No Blur", CurrentValue = false,
    Callback = function(v) setNoBlur(v) end,
})

MiscTab:CreateSection("Screen Effects")
MiscTab:CreateToggle({
    Name = "No Flash", CurrentValue = false,
    Callback = function(v) if v then flashKiller.enable() else flashKiller.disable() end end,
})
MiscTab:CreateToggle({
    Name = "No Suppression", CurrentValue = false,
    Callback = function(v) if v then suppressionKiller.enable() else suppressionKiller.disable() end end,
})
MiscTab:CreateToggle({
    Name = "No Explosion Screen Effect", CurrentValue = false,
    Callback = function(v) if v then explosionKiller.enable() else explosionKiller.disable() end end,
})
MiscTab:CreateToggle({
    Name = "No Water Effects", CurrentValue = false,
    Callback = function(v) if v then waterKiller.enable() else waterKiller.disable() end end,
})

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
