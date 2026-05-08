-- ===== CHAMS UI (loaded externally via loadstring) =====
local state = _G.ChamsState
if not state then warn("[UI] ChamsState not found in _G - did main.lua run first?") return end

local settings       = state.settings
local highlightCache = state.highlightCache
local toggleChams    = state.toggleChams
local setNightVision = state.setNightVision
local fullCleanup    = state.fullCleanup

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Volodym5/pfasdzxc231/refs/heads/main/lib.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Deadline Xeno - Chams",
   Icon = 0,
   LoadingTitle = "Deadline Xeno",
   LoadingSubtitle = "Chams Menu",
   Theme = "Default",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "DeadlineXeno",
      FileName = "ChamsSettings"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
})

-- ===== MAIN TAB =====
local MainTab = Window:CreateTab("Chams", 4483362458)

MainTab:CreateSection("Toggle")
MainTab:CreateToggle({
   Name = "Enable Chams",
   CurrentValue = settings.Enabled,
   Flag = "ChamsEnabled",
   Callback = function(Value) toggleChams(Value) end,
})

MainTab:CreateSection("Settings")
MainTab:CreateToggle({
   Name = "Team Check (Friendly Detection)",
   CurrentValue = settings.TeamCheck,
   Flag = "TeamCheck",
   Callback = function(Value) settings.TeamCheck = Value end,
})
MainTab:CreateToggle({
   Name = "Visibility Check",
   CurrentValue = settings.VisibilityCheck,
   Flag = "VisibilityCheck",
   Callback = function(Value) settings.VisibilityCheck = Value end,
})

MainTab:CreateSection("Colors")

-- Quick swatches: applied to whichever picker was last focused
local lastFocused = "visible" -- "visible" | "occluded"

local swatches = {
    { name = "Red",    c = Color3.fromRGB(255, 50,  50)  },
    { name = "Orange", c = Color3.fromRGB(255, 150, 50)  },
    { name = "Yellow", c = Color3.fromRGB(240, 230, 50)  },
    { name = "Green",  c = Color3.fromRGB(50,  255, 80)  },
    { name = "Cyan",   c = Color3.fromRGB(0,   220, 255) },
    { name = "Blue",   c = Color3.fromRGB(30,  80,  255) },
    { name = "Purple", c = Color3.fromRGB(180, 60,  255) },
    { name = "Pink",   c = Color3.fromRGB(255, 80,  180) },
    { name = "White",  c = Color3.fromRGB(255, 255, 255) },
    { name = "Grey",   c = Color3.fromRGB(140, 140, 140) },
}

-- Debounce so dragging custom picker doesn't spam every frame
local debounceThread = nil
local function applyColor(target, color)
    if target == "visible" then
        settings.VisibleColor = color
        for _, h in pairs(highlightCache) do
            if h.Enabled then
                local dVis = (h.FillColor - color).Magnitude
                local dOcc = (h.FillColor - settings.OccludedColor).Magnitude
                if dVis <= dOcc then h.FillColor = color; h.OutlineColor = color end
            end
        end
    else
        settings.OccludedColor = color
        for _, h in pairs(highlightCache) do
            if h.Enabled then
                local dOcc = (h.FillColor - color).Magnitude
                local dVis = (h.FillColor - settings.VisibleColor).Magnitude
                if dOcc < dVis then h.FillColor = color; h.OutlineColor = color end
            end
        end
    end
end

local function debouncedApply(target, color)
    if debounceThread then task.cancel(debounceThread) end
    debounceThread = task.delay(0.1, function()
        applyColor(target, color)
        debounceThread = nil
    end)
end

MainTab:CreateSection("Colors")
MainTab:CreateLabel("Click a swatch to set the focused picker's color")

for _, s in ipairs(swatches) do
    local sw = s
    MainTab:CreateButton({
        Name = sw.name,
        Callback = function() applyColor(lastFocused, sw.c) end,
    })
end

MainTab:CreateColorPicker({
    Name = "Visible Color",
    Color = settings.VisibleColor,
    Flag = "VisibleColor",
    Callback = function(Color)
        lastFocused = "visible"
        debouncedApply("visible", Color)
    end,
})
MainTab:CreateColorPicker({
    Name = "Occluded Color",
    Color = settings.OccludedColor,
    Flag = "OccludedColor",
    Callback = function(Color)
        lastFocused = "occluded"
        debouncedApply("occluded", Color)
    end,
})

MainTab:CreateSection("Transparency")
MainTab:CreateSlider({
   Name = "Fill Transparency",
   Range = {0, 1},
   Increment = 0.05,
   Suffix = "",
   CurrentValue = settings.FillTransparency,
   Flag = "FillTrans",
   Callback = function(Value)
       settings.FillTransparency = Value
       for _, h in pairs(highlightCache) do h.FillTransparency = Value end
   end,
})
MainTab:CreateSlider({
   Name = "Outline Transparency",
   Range = {0, 1},
   Increment = 0.05,
   Suffix = "",
   CurrentValue = settings.OutlineTransparency,
   Flag = "OutlineTrans",
   Callback = function(Value)
       settings.OutlineTransparency = Value
       for _, h in pairs(highlightCache) do h.OutlineTransparency = Value end
   end,
})

-- ===== MISC TAB =====
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateSection("Night Vision")
MiscTab:CreateToggle({
   Name = "Remove Night Vision Effects",
   CurrentValue = settings.NightVision,
   Callback = function(Value) setNightVision(Value) end,
})
MiscTab:CreateLabel("Removes: NightVision dof/color_correction/blur/bloom\nand IngameView universal_desaturation from Lighting")

MiscTab:CreateSection("Utility")
MiscTab:CreateButton({
   Name = "Unload Script",
   Callback = function()
       fullCleanup()
       Rayfield:Destroy()
   end,
})

Rayfield:LoadConfiguration()
