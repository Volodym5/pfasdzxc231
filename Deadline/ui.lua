-- ===== CHAMS UI (loaded externally via loadstring) =====
local state = _G.ChamsState
if not state then warn("[UI] ChamsState not found in _G - did main.lua run first?") return end

local settings       = state.settings
local highlightCache = state.highlightCache
local toggleChams    = state.toggleChams
local setNightVision = state.setNightVision
local fullCleanup    = state.fullCleanup

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/rayfield%20custom.lua'))()

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

MainTab:CreateSection("Colors")
MainTab:CreateColorPicker({
    Name = "Visible Color",
    Color = settings.VisibleColor,
    Flag = "VisibleColor",
    Callback = function(Color) settings.VisibleColor = Color end,
})
MainTab:CreateColorPicker({
    Name = "Occluded Color",
    Color = settings.OccludedColor,
    Flag = "OccludedColor",
    Callback = function(Color) settings.OccludedColor = Color end,
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
