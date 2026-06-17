--[[
    NexusUI — How to Use
    =====================

    ── 1. STARTUP ──────────────────────────────────────────────────────────────
    Load the library and create a window. All components hang off the window.

        local UI = loadstring(game:HttpGet("YOUR_RAW_URL"))()

        local Window = UI:CreateWindow({
            Title           = "My Menu",          -- window title
            Footer          = "v1.0",             -- small text in bottom-right
            Size            = UDim2.fromOffset(720, 540),
            Center          = true,               -- false = use Position instead
            Position        = UDim2.fromOffset(80, 80),
            Resizable       = true,
            CornerRadius    = 7,                  -- corner rounding in px
            ToggleKeybind   = Enum.KeyCode.RightControl,
            AutoShow        = true,               -- show immediately on load
            PageTransition  = "fade",             -- "fade" | "slide" | "scale"
            ShowCustomCursor = true,
            ConfigFolder    = "MyScript",         -- folder name for saved configs
            BuiltinSettings = true,               -- false = blank Settings tab (gear always shown)
        })

        -- Add a tab, then a groupbox inside it
        -- Side = 1 → left column,  Side = 2 → right column
        -- If only one side is used it auto-expands to full width.
        local Tab = Window:AddTab("Main")
        local Box = Tab:AddGroupbox({ Name = "Settings", Side = 1 })

    ── 2. BUTTON ────────────────────────────────────────────────────────────────
        Box:AddButton("myButton", {
            Text     = "Click Me",
            Variant  = "Primary",   -- "Primary" | "Secondary" | "Danger"
            Callback = function()
                print("Button clicked!")
            end,
        })

    ── 3. TOGGLE ────────────────────────────────────────────────────────────────
        Box:AddToggle("myToggle", {
            Text     = "Enable Feature",
            Default  = false,
            Risky    = false,       -- true = red warning style
            Disabled = false,
            Callback = function(value)
                print("Toggle is now:", value)
            end,
        })

        -- Read or set later:
        print(UI.Toggles.myToggle.Value)
        UI.Toggles.myToggle:SetValue(true)

    ── 4. SLIDER ────────────────────────────────────────────────────────────────
        Box:AddSlider("mySlider", {
            Text     = "Walk Speed",
            Default  = 16,
            Min      = 0,
            Max      = 100,
            Rounding = 0,           -- decimal places (0 = integer)
            Suffix   = " studs",    -- optional unit label shown after value
            Disabled = false,
            Callback = function(value)
                print("Slider value:", value)
            end,
        })

        -- Read or set later:
        print(UI.Options.mySlider.Value)
        UI.Options.mySlider:SetValue(50)

    ── 5. INPUT ─────────────────────────────────────────────────────────────────
        Box:AddInput("myInput", {
            Text        = "Player Name",
            Default     = "",
            Placeholder = "Enter name…",
            Numeric     = false,    -- true = numbers only
            Finished    = true,     -- true = callback fires on Enter, false = every keystroke
            Callback    = function(value)
                print("Input:", value)
            end,
        })

        -- Read or set later:
        print(UI.Options.myInput.Value)
        UI.Options.myInput:SetValue("hello")

    ── 6. COLOR PICKER ──────────────────────────────────────────────────────────
        Box:AddColorPicker("myColor", {
            Text     = "Highlight Color",
            Default  = Color3.fromRGB(108, 82, 246),
            Callback = function(color)
                print("Color changed:", color)
            end,
        })

        -- Read or set later:
        print(UI.Options.myColor.Value)
        UI.Options.myColor:SetValue(Color3.fromRGB(255, 0, 0))

    ── 7. KEYBIND ───────────────────────────────────────────────────────────────
        Box:AddKeyPicker("myKey", {
            Text     = "Activate",
            Default  = "F",         -- key name or "None" or "MB1" / "MB2"
            Mode     = "Toggle",    -- "Toggle" | "Hold" | "Always"
            NoUI     = false,       -- true = hidden from the Keybinds list in Settings
            Callback = function(value)
                -- fires when key state changes (bool in Toggle/Hold, always true in Always)
                print("Key active:", value)
            end,
            Changed  = function(newKey)
                -- fires when the user rebinds it
                print("Rebound to:", newKey)
            end,
        })

        -- Read or set later:
        print(UI.Options.myKey.Value)      -- current key name string
        print(UI.Options.myKey:IsActive()) -- true if currently held/toggled on
        UI.Options.myKey:SetValue("G")

    ── 8. DROPDOWN ──────────────────────────────────────────────────────────────
        Box:AddDropdown("myDropdown", {
            Text     = "Select Mode",
            Values   = { "Off", "Low", "Medium", "High" },
            Default  = "Off",
            Callback = function(value)
                print("Selected:", value)
            end,
        })

        -- Read or set later:
        print(UI.Options.myDropdown.Value)
        UI.Options.myDropdown:SetValue("High")

    ── 9. MULTI-DROPDOWN ────────────────────────────────────────────────────────
        Box:AddDropdown("myMulti", {
            Text   = "Select Features",
            Values = { "Aimbot", "ESP", "Wallhack", "Speedhack" },
            Multi  = true,          -- enables multi-select mode
            Callback = function(selectedTable)
                -- selectedTable is a dict: { ["ESP"] = true, ... }
                for name, enabled in pairs(selectedTable) do
                    print(name, enabled)
                end
            end,
        })

        -- Default selection must be set manually for Multi dropdowns:
        UI.Options.myMulti:SetValue("ESP")

        -- Read current selections:
        for name, enabled in pairs(UI.Options.myMulti.Value) do
            print(name, enabled)
        end

    ── 10. LABEL ────────────────────────────────────────────────────────────────
        local lbl = Box:AddLabel("myLabel", { Text = "Hello World", Visible = true })
        lbl:SetText("Updated text")

    ── 11. DIVIDER ──────────────────────────────────────────────────────────────
        Box:AddDivider()                        -- plain line
        Box:AddDivider({ Text = "── Section ──" })  -- line with centred label

    ── 12. DEPENDENCY BOX ───────────────────────────────────────────────────────
    A sub-groupbox whose elements are shown/hidden as a unit. Drive it from a
    toggle callback to only show relevant options:

        local depBox = Box:AddDependencyBox()
        depBox:AddSlider("depSlider", { Text = "Sub Slider", Default = 50, Min = 0, Max = 100, Callback = function() end })

        Box:AddToggle("showDep", {
            Text = "Show Extra Options",
            Default = false,
            Callback = function(v) depBox:SetVisible(v) end,
        })
        depBox:SetVisible(false)  -- start hidden

    ── 13. INLINE ADDONS (color picker / keybind on the same row) ───────────────
    Any toggle, slider, or dropdown can host an inline ColorPicker or KeyPicker
    on its right side — no extra row needed:

        local toggle = Box:AddToggle("espToggle", { Text = "ESP", Default = false, Callback = function() end })
        toggle:AddColorPicker("espColor", { Default = Color3.fromRGB(255, 80, 80), Callback = function(c) end })
        toggle:AddKeyPicker("espKey",    { Default = "X", Mode = "Toggle",          Callback = function(v) end })

    ── 14. TABBOX (sub-tabs inside a groupbox) ──────────────────────────────────
        local TBox   = Tab:AddTabbox({ Side = 2 })
        local SubTab = TBox:AddTab("Combat")
        SubTab:AddToggle("aimbot", { Text = "Aimbot", Default = false, Callback = function() end })

    ── 15. CONFIGS ──────────────────────────────────────────────────────────────
    Configs save all toggles, sliders, dropdowns, color pickers, keybinds and
    window size/position. They are stored in the ConfigFolder you set above.

        UI.Config.Save("myConfig")          -- save current state
        UI.Config.Load("myConfig")          -- restore a saved state
        UI.Config.SetDefault("myConfig")    -- auto-load this config on next launch
        UI.Config.GetDefault()              -- returns the current default name (or nil)
        UI.Config.Exists("myConfig")        -- true if the file exists
        UI.Config.Delete("myConfig")        -- delete a saved config
        UI.Config.List()                    -- returns table of all saved config names

    ── 16. KEYBINDS (global) ────────────────────────────────────────────────────
    These work at all times regardless of what's focused:

        RightControl          — toggle menu open / closed  (customisable via ToggleKeybind)
        Ctrl + K               — toggle Debug Overlay
        Ctrl + Shift + P       — open Script Hub
        Ctrl + Z               — undo last value change
        Ctrl + Shift + Z       — redo

    ── 17. SCRIPT HUB ───────────────────────────────────────────────────────────
    A grid of big rounded cards you click to run a saved loadstring. Opens
    with Ctrl+Shift+P, darkens/blurs the whole screen, and minimizes the main
    window while it's open. Users can add/edit/delete cards from inside the
    UI (click "+ Add Script"), but you can also preload cards from your own
    setup code so they're already there the first time someone opens it:

        UI:AddScript("Auto Farm", 'loadstring(game:HttpGet("https://..."))()')

        -- or several at once:
        UI:AddScripts({
            { Name = "Auto Farm",  Code = 'loadstring(game:HttpGet("..."))()' },
            { Name = "ESP",        Code = 'loadstring(game:HttpGet("..."))()' },
        })

    Safe to call every time your script runs — it matches by name, so
    re-running just updates that card's code instead of duplicating it.
    Scripts persist between sessions (saved under ConfigFolder), independent
    of UI.Config — they aren't part of the toggle/slider config system.

    Want presets baked directly into this file instead of called from setup
    code? Search for "DEFAULT_SCRIPTS" further down — fill that table in and
    every fresh install gets those cards automatically. They seed once; if a
    user deletes one it won't come back (their deletion is respected).

    ── NOTES ────────────────────────────────────────────────────────────────────
    • All component keys (first argument) must be unique across the whole script.
    • Toggles  → UI.Toggles.<key>.Value   /  :SetValue(bool)
    • Options  → UI.Options.<key>.Value   /  :SetValue(...)
      (covers Sliders, Inputs, Dropdowns, ColorPickers, KeyPickers)
    • Labels   → UI.Labels.<key>          /  :SetText(str)
    • Buttons are fire-and-forget; they are not saved in configs.
    • The built-in Settings tab (Appearance, Keybinds, Configs, Misc) is added
      automatically when BuiltinSettings = true (default). Settings are saved
      and restored as part of every config.
    • Window size is saved as the base (100% DPI) size and restores correctly
      regardless of what DPI scale is active when you load.
]]

-- ─── Service Acquisition ───────────────────────────────────────────────────
local cloneref = (cloneref or clonereference or function(i) return i end)
local CoreGui           = cloneref(game:GetService("CoreGui"))
local Players           = cloneref(game:GetService("Players"))
local RunService        = cloneref(game:GetService("RunService"))
local UserInputService  = cloneref(game:GetService("UserInputService"))
local TweenService      = cloneref(game:GetService("TweenService"))
local TextService       = cloneref(game:GetService("TextService"))
local SoundService      = cloneref(game:GetService("SoundService"))
local Teams             = cloneref(game:GetService("Teams"))
local HttpService        = cloneref(game:GetService("HttpService"))
local Lighting           = cloneref(game:GetService("Lighting"))

local getgenv           = getgenv   or function() return shared end
local setclipboard      = setclipboard or function() end
local protectgui        = protectgui or (syn and syn.protect_gui) or function() end
local gethui            = gethui    or function() return CoreGui end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse       = cloneref(LocalPlayer:GetMouse())
local Camera      = workspace.CurrentCamera

-- Forward declaration: the real Library table is assigned further down
-- (search "Main Library Object"), but earlier modules like the Script Hub
-- need to call into it (Window:Toggle, Library.ConfigFolder, etc). Since
-- this is a `local`, and Lua resolves upvalues lexically (not by execution
-- order), declaring the assignment later as `local Library = {...}` would
-- create a brand-new shadowing local invisible to closures defined above it
-- — they'd silently capture a `nil` global instead. Forward-declaring here
-- and assigning (without `local`) later keeps everyone pointed at the same
-- upvalue.
local Library

-- ─── Constants ─────────────────────────────────────────────────────────────
local LIBRARY_VERSION   = "2.0.0"
local POOL_MAX          = 64
local SPRING_DAMPING    = 20
local SPRING_STIFFNESS  = 200
local ANIM_FPS_LOW      = 30
local ANIM_FPS_CRIT     = 20
local RIPPLE_DURATION   = 0.5
local TOAST_DURATION    = 4.0
local TOAST_FADE        = 0.3
local PERF_SAMPLE_RATE  = 60  -- frames

-- ─── Design Tokens ─────────────────────────────────────────────────────────
local Tokens = {
    -- Spacing
    SpaceXS   = 2,
    SpaceSM   = 4,
    SpaceMD   = 8,
    SpaceLG   = 12,
    SpaceXL   = 16,
    Space2XL  = 24,
    Space3XL  = 32,

    -- Typography
    FontSize = {
        XS   = 11,
        SM   = 12,
        MD   = 13,
        LG   = 14,
        XL   = 15,
        H3   = 17,
        H2   = 19,
        H1   = 22,
    },
    FontWeight = {
        Regular  = Enum.FontWeight.Regular,
        Medium   = Enum.FontWeight.Medium,
        SemiBold = Enum.FontWeight.SemiBold,
        Bold     = Enum.FontWeight.Bold,
    },

    -- Radii — slightly more rounded for a modern feel
    RadiusXS   = 3,
    RadiusSM   = 5,
    RadiusMD   = 7,
    RadiusLG   = 10,
    RadiusFull = 999,

    -- Animation
    DurationFast    = 0.10,
    DurationNormal  = 0.16,
    DurationSlow    = 0.28,
    DurationSlower  = 0.45,

    -- Z-Layers
    LayerBase      = 1,
    LayerFloat     = 10,
    LayerDropdown  = 50,
    LayerModal     = 100,
    LayerToast     = 200,
    LayerCursor    = 500,
    LayerDebug     = 999,
}

-- ─── Theme Engine ──────────────────────────────────────────────────────────
--[[
    Themes define raw color values.
    AccentVariants are auto-generated from the primary accent.
    Supports Dark / Light and smooth interpolation between them.
]]
local ThemeEngine = {}
do
    -- Perceptual color interpolation (linear RGB)
    local function LerpColor(a, b, t)
        -- Convert to linear light
        local function toLinear(c) return c^2.2 end
        local function fromLinear(c) return c^(1/2.2) end
        return Color3.new(
            fromLinear(toLinear(a.R)*(1-t) + toLinear(b.R)*t),
            fromLinear(toLinear(a.G)*(1-t) + toLinear(b.G)*t),
            fromLinear(toLinear(a.B)*(1-t) + toLinear(b.B)*t)
        )
    end

    -- Generate hover/active/subtle variants from an accent color
    local function GenerateAccentVariants(accent)
        local H, S, V = accent:ToHSV()
        return {
            Base     = accent,
            Hover    = Color3.fromHSV(H, S, math.min(1, V + 0.12)),
            Active   = Color3.fromHSV(H, math.min(1, S + 0.05), math.max(0, V - 0.08)),
            Subtle   = Color3.fromHSV(H, S * 0.3, math.min(1, V + 0.05)),
            Glow     = Color3.fromHSV(H, S * 0.6, 1),
        }
    end

    local function GenerateNeutralScale(base, isLight)
        local H, S, V = base:ToHSV()
        if isLight then
            return {
                N900 = Color3.fromHSV(H, S*0.1, 0.05),
                N800 = Color3.fromHSV(H, S*0.1, 0.12),
                N700 = Color3.fromHSV(H, S*0.1, 0.22),
                N600 = Color3.fromHSV(H, S*0.1, 0.36),
                N500 = Color3.fromHSV(H, S*0.1, 0.50),
                N400 = Color3.fromHSV(H, S*0.1, 0.65),
                N300 = Color3.fromHSV(H, S*0.1, 0.78),
                N200 = Color3.fromHSV(H, S*0.1, 0.88),
                N100 = Color3.fromHSV(H, S*0.1, 0.94),
                N050 = Color3.fromHSV(H, S*0.1, 0.98),
            }
        else
            return {
                N900 = Color3.fromHSV(H, S*0.1, 0.98),
                N800 = Color3.fromHSV(H, S*0.1, 0.90),
                N700 = Color3.fromHSV(H, S*0.1, 0.78),
                N600 = Color3.fromHSV(H, S*0.1, 0.60),
                N500 = Color3.fromHSV(H, S*0.1, 0.45),
                N400 = Color3.fromHSV(H, S*0.1, 0.30),
                N300 = Color3.fromHSV(H, S*0.1, 0.22),
                N200 = Color3.fromHSV(H, S*0.1, 0.15),
                N100 = Color3.fromHSV(H, S*0.1, 0.10),
                N050 = Color3.fromHSV(H, S*0.1, 0.06),
            }
        end
    end

    local BuiltinThemes = {
        Dark = {
            IsLight  = false,
            Accent   = Color3.fromRGB(108, 82, 246),    -- refined purple
            Neutral  = Color3.fromRGB(14, 14, 18),       -- warm near-black
            Success  = Color3.fromRGB(34, 197, 94),
            Warning  = Color3.fromRGB(234, 179, 8),
            Danger   = Color3.fromRGB(239, 68, 68),
            Info     = Color3.fromRGB(59, 130, 246),
        },
        Midnight = {
            IsLight  = false,
            Accent   = Color3.fromRGB(0, 195, 240),      -- cyan
            Neutral  = Color3.fromRGB(7, 8, 14),
            Success  = Color3.fromRGB(20, 225, 105),
            Warning  = Color3.fromRGB(255, 200, 30),
            Danger   = Color3.fromRGB(255, 60, 70),
            Info     = Color3.fromRGB(80, 160, 255),
        },
        Ember = {
            IsLight  = false,
            Accent   = Color3.fromRGB(248, 92, 36),      -- warm orange
            Neutral  = Color3.fromRGB(13, 9, 7),
            Success  = Color3.fromRGB(40, 210, 100),
            Warning  = Color3.fromRGB(255, 200, 30),
            Danger   = Color3.fromRGB(240, 50, 50),
            Info     = Color3.fromRGB(80, 170, 255),
        },
        Jade = {
            IsLight  = false,
            Accent   = Color3.fromRGB(52, 211, 153),     -- emerald green
            Neutral  = Color3.fromRGB(10, 14, 12),
            Success  = Color3.fromRGB(52, 211, 153),
            Warning  = Color3.fromRGB(251, 191, 36),
            Danger   = Color3.fromRGB(248, 113, 113),
            Info     = Color3.fromRGB(96, 165, 250),
        },
        Rose = {
            IsLight  = false,
            Accent   = Color3.fromRGB(244, 63, 94),      -- rose / pink
            Neutral  = Color3.fromRGB(14, 10, 12),
            Success  = Color3.fromRGB(52, 211, 153),
            Warning  = Color3.fromRGB(251, 191, 36),
            Danger   = Color3.fromRGB(248, 113, 113),
            Info     = Color3.fromRGB(96, 165, 250),
        },
        Nord = {
            IsLight  = false,
            Accent   = Color3.fromRGB(136, 192, 208),    -- nord frost blue
            Neutral  = Color3.fromRGB(46, 52, 64),
            Success  = Color3.fromRGB(163, 190, 140),
            Warning  = Color3.fromRGB(235, 203, 139),
            Danger   = Color3.fromRGB(191, 97, 106),
            Info     = Color3.fromRGB(129, 161, 193),
        },
        Dracula = {
            IsLight  = false,
            Accent   = Color3.fromRGB(189, 147, 249),    -- dracula purple
            Neutral  = Color3.fromRGB(40, 42, 54),
            Success  = Color3.fromRGB(80, 250, 123),
            Warning  = Color3.fromRGB(241, 250, 140),
            Danger   = Color3.fromRGB(255, 85, 85),
            Info     = Color3.fromRGB(139, 233, 253),
        },
        Catppuccin = {
            IsLight  = false,
            Accent   = Color3.fromRGB(203, 166, 247),    -- mauve
            Neutral  = Color3.fromRGB(30, 30, 46),       -- crust
            Success  = Color3.fromRGB(166, 227, 161),
            Warning  = Color3.fromRGB(249, 226, 175),
            Danger   = Color3.fromRGB(243, 139, 168),
            Info     = Color3.fromRGB(137, 180, 250),
        },
        Amoled = {
            IsLight  = false,
            Accent   = Color3.fromRGB(0, 230, 118),      -- neon green on true black
            Neutral  = Color3.fromRGB(0, 0, 0),
            Success  = Color3.fromRGB(0, 230, 118),
            Warning  = Color3.fromRGB(255, 213, 0),
            Danger   = Color3.fromRGB(255, 45, 85),
            Info     = Color3.fromRGB(10, 200, 255),
        },
        Ocean = {
            IsLight  = false,
            Accent   = Color3.fromRGB(100, 210, 255),    -- ocean blue
            Neutral  = Color3.fromRGB(8, 18, 32),
            Success  = Color3.fromRGB(60, 220, 160),
            Warning  = Color3.fromRGB(255, 200, 60),
            Danger   = Color3.fromRGB(255, 80, 80),
            Info     = Color3.fromRGB(100, 210, 255),
        },
        Light = {
            IsLight  = true,
            Accent   = Color3.fromRGB(99, 74, 228),
            Neutral  = Color3.fromRGB(248, 248, 252),
            Success  = Color3.fromRGB(22, 163, 74),
            Warning  = Color3.fromRGB(202, 138, 4),
            Danger   = Color3.fromRGB(220, 38, 38),
            Info     = Color3.fromRGB(37, 99, 235),
        },
        -- Rainbow is handled specially in SetTheme — this entry just acts as
        -- a placeholder so it appears in the dropdown.
        Rainbow = {
            IsLight  = false,
            Accent   = Color3.fromRGB(255, 100, 100),
            Neutral  = Color3.fromRGB(14, 14, 18),
            Success  = Color3.fromRGB(34, 197, 94),
            Warning  = Color3.fromRGB(234, 179, 8),
            Danger   = Color3.fromRGB(239, 68, 68),
            Info     = Color3.fromRGB(59, 130, 246),
        },
    }

    ThemeEngine.LerpColor     = LerpColor
    ThemeEngine.BuiltinThemes = BuiltinThemes

    function ThemeEngine:Build(themeData)
        local isLight = themeData.IsLight
        local neutral = GenerateNeutralScale(themeData.Neutral, isLight)
        local accent  = GenerateAccentVariants(themeData.Accent)

        return {
            IsLight          = isLight,
            AccentColor      = accent.Base,
            AccentHover      = accent.Hover,
            AccentActive     = accent.Active,
            AccentSubtle     = accent.Subtle,
            AccentGlow       = accent.Glow,

            BackgroundColor  = neutral.N050,
            SurfaceColor     = neutral.N100,
            SurfaceAltColor  = neutral.N200,
            BorderColor      = neutral.N300,
            MutedColor       = neutral.N400,

            TextPrimary      = neutral.N900,
            TextSecondary    = neutral.N700,
            TextMuted        = neutral.N500,
            TextDisabled     = neutral.N400,

            SuccessColor     = themeData.Success,
            WarningColor     = themeData.Warning,
            DangerColor      = themeData.Danger,
            InfoColor        = themeData.Info,

            ShadowColor      = Color3.new(0, 0, 0),

            Font             = Font.fromEnum(Enum.Font.Gotham),
            FontBold         = Font.fromEnum(Enum.Font.Gotham),

            -- Legacy aliases for drop-in compat
            MainColor        = neutral.N100,
            OutlineColor     = neutral.N300,
            FontColor        = neutral.N900,
            DarkColor        = Color3.new(0, 0, 0),
            WhiteColor       = Color3.new(1, 1, 1),
            RedColor         = themeData.Danger,
            DestructiveColor = themeData.Danger,
        }
    end

    -- Interpolate between two built theme tables for smooth transition
    function ThemeEngine:Interpolate(from, to, t)
        local result = {}
        for k, v in pairs(to) do
            if typeof(v) == "Color3" and typeof(from[k]) == "Color3" then
                result[k] = LerpColor(from[k], v, t)
            else
                result[k] = (t >= 0.5) and v or from[k]
            end
        end
        return result
    end

    ThemeEngine.CurrentScheme = ThemeEngine:Build(BuiltinThemes.Dark)
    ThemeEngine.ActiveThemeName = "Dark"
end

-- ─── Spring Solver ─────────────────────────────────────────────────────────
--[[
    Semi-implicit Euler spring (also called symplectic Euler).
    v_new = v + (-k*(x-t) - c*v) * dt
    x_new = x + v_new * dt          ← uses updated velocity, not old
    This is unconditionally stable for any dt and feels smooth at 60fps.
    Supports interruption: new target preserves current velocity.
]]
local SpringSolver = {}
do
    -- Step one scalar channel; returns new_pos, new_vel
    local function stepScalar(pos, vel, target, k, c, dt)
        local a    = -k * (pos - target) - c * vel
        local nvel = vel + a * dt
        local npos = pos + nvel * dt   -- semi-implicit: use updated vel
        return npos, nvel
    end

    function SpringSolver.New(stiffness, damping, initialValue)
        local s = {
            k    = stiffness or SPRING_STIFFNESS,
            c    = damping   or SPRING_DAMPING,
            pos  = initialValue,
            tgt  = initialValue,
            vx   = 0, vy = 0, vz = 0, vw = 0,
            done = false,
        }
        return setmetatable(s, { __index = SpringSolver })
    end

    function SpringSolver:SetTarget(t)
        self.tgt  = t
        self.done = false
    end

    function SpringSolver:IsSettled()
        local THRESH = 0.0015
        local p, t = self.pos, self.tgt
        local tp = typeof(p)
        if tp == "number" then
            return math.abs(p-t) < THRESH and math.abs(self.vx) < THRESH
        elseif tp == "Color3" then
            return math.abs(p.R-t.R)+math.abs(p.G-t.G)+math.abs(p.B-t.B) < THRESH
        elseif tp == "UDim2" then
            return math.abs(p.X.Offset-t.X.Offset) < THRESH
               and math.abs(p.Y.Offset-t.Y.Offset) < THRESH
               and math.abs(self.vx) < THRESH and math.abs(self.vy) < THRESH
        end
        return true
    end

    function SpringSolver:Step(dt)
        if self.done then return self.pos end
        local k, c = self.k, self.c
        local tp = typeof(self.pos)

        if tp == "number" then
            local np, nv = stepScalar(self.pos, self.vx, self.tgt, k, c, dt)
            self.pos = np;  self.vx = nv

        elseif tp == "Color3" then
            local r, vr = stepScalar(self.pos.R, self.vx, self.tgt.R, k, c, dt)
            local g, vg = stepScalar(self.pos.G, self.vy, self.tgt.G, k, c, dt)
            local b, vb = stepScalar(self.pos.B, self.vz, self.tgt.B, k, c, dt)
            self.pos = Color3.new(math.clamp(r,0,1), math.clamp(g,0,1), math.clamp(b,0,1))
            self.vx = vr;  self.vy = vg;  self.vz = vb

        elseif tp == "UDim2" then
            local p, t = self.pos, self.tgt
            local xo, vx = stepScalar(p.X.Offset, self.vx, t.X.Offset, k, c, dt)
            local yo, vy = stepScalar(p.Y.Offset, self.vy, t.Y.Offset, k, c, dt)
            local xs, vxs = stepScalar(p.X.Scale,  self.vz, t.X.Scale,  k, c, dt)
            local ys, vys = stepScalar(p.Y.Scale,  self.vw, t.Y.Scale,  k, c, dt)
            self.pos = UDim2.new(xs, math.round(xo), ys, math.round(yo))
            self.vx = vx;  self.vy = vy;  self.vz = vxs;  self.vw = vys
        end

        if self:IsSettled() then
            self.pos  = self.tgt
            self.done = true
        end
        return self.pos
    end

    -- Legacy compat shim (old code used .Position / .Target)
    local mt = getmetatable(SpringSolver.New(200, 20, 0))
    local orig = mt.__index
    mt.__index = function(self, k)
        if k == "Position" then return self.pos end
        if k == "Target"   then return self.tgt end
        if k == "_done"    then return self.done end
        return orig[k]
    end
    mt.__newindex = function(self, k, v)
        if k == "Position" then self.pos  = v
        elseif k == "Target"   then self.tgt  = v
        elseif k == "_done"    then self.done = v
        else rawset(self, k, v) end
    end
end

-- ─── Global Animation Engine ───────────────────────────────────────────────
--[[
    Single Heartbeat drives all springs and fixed-duration tweens.
    No throttle, no adaptive-speed multiplier — both caused jitter.
    dt is clamped to 1/30 max so a lag spike doesn't explode springs.

    Performance notes:
      • A single pcall wraps each animation's apply/onDone instead of two
        separate pcalls per entry — halves call overhead in the hot path.
      • Finished entries are removed in-place during iteration (Lua allows
        setting the current key to nil mid `pairs` traversal) instead of
        building a fresh `remove` table every frame.
      • The perf-sample ring buffer uses a fixed-size array + cursor instead
        of table.insert/table.remove(1), avoiding O(n) shifts every frame.
]]
local AnimEngine = {}
do
    local anims     = {}   -- id → entry
    local counter   = 0
    local lastFPS   = 60
    local budgetMs  = 0

    local SAMPLE_COUNT = 60
    local samples   = table.create and table.create(SAMPLE_COUNT, 0) or {}
    local sampleIdx = 0
    local sampleLen = 0
    for i = 1, SAMPLE_COUNT do samples[i] = 0 end

    local function newId()
        counter += 1
        return counter
    end

    local function runEntry(id, a, dt)
        local done
        if a.spring then
            local v = a.spring:Step(dt)
            a.apply(v)
            done = a.spring.done
        else
            a.elapsed = a.elapsed + dt
            local prog  = a.elapsed / a.dur
            if prog > 1 then prog = 1 end
            local eased = a.ease and a.ease(prog) or prog
            a.apply(eased)
            done = prog >= 1
        end

        if done then
            if a.onDone then a.onDone() end
            anims[id] = nil
        end
    end

    RunService.Heartbeat:Connect(function(rawDt)
        local dt = rawDt < 1/30 and rawDt or 1/30   -- clamp: never let a lag spike explode springs
        lastFPS = (1/rawDt) * 0.1 + lastFPS * 0.9

        local t0 = tick()

        for id, a in pairs(anims) do
            -- Single pcall boundary per entry: protects against bad apply/
            -- onDone callbacks (e.g. a destroyed Instance) without paying
            -- for two pcalls per animation per frame.
            local ok, err = pcall(runEntry, id, a, dt)
            if not ok then
                anims[id] = nil -- drop broken animations instead of spamming errors every frame
            end
        end

        budgetMs = (tick() - t0) * 1000

        sampleIdx = (sampleIdx % SAMPLE_COUNT) + 1
        samples[sampleIdx] = budgetMs
        if sampleLen < SAMPLE_COUNT then sampleLen += 1 end
    end)

    -- Spring animation — returns a cancel function

    -- Each call creates a fresh spring from `from` targeting `to`.
    -- Interruption is safe: just call again with the current value as `from`.
    function AnimEngine.Spring(params)
        local sp = SpringSolver.New(params.stiffness, params.damping, params.from)
        sp:SetTarget(params.to)
        local id = newId()
        anims[id] = { spring = sp, apply = params.apply, onDone = params.onDone }
        return function() anims[id] = nil end
    end

    -- Fixed-duration tween with easing
    function AnimEngine.Tween(params)
        local id = newId()
        anims[id] = {
            dur     = params.duration or 0.18,
            ease    = params.easing,
            apply   = params.apply,
            onDone  = params.onDone,
            elapsed = 0,
        }
        return function() anims[id] = nil end
    end

    function AnimEngine.GetFPS()     return lastFPS  end
    function AnimEngine.GetBudget()  return budgetMs end

    -- Number of currently-active spring/tween animations (for the debug overlay)
    function AnimEngine.GetActiveCount()
        local n = 0
        for _ in pairs(anims) do n += 1 end
        return n
    end

    -- Returns perf samples in chronological order (oldest first), reading
    -- the fixed-size ring buffer used by the Heartbeat loop above.
    function AnimEngine.GetPerfSamples()
        if sampleLen < SAMPLE_COUNT then
            local out = {}
            for i = 1, sampleLen do out[i] = samples[i] end
            return out
        end
        local out = {}
        for i = 1, SAMPLE_COUNT do
            local pos = ((sampleIdx + i - 1) % SAMPLE_COUNT) + 1
            out[i] = samples[pos]
        end
        return out
    end

    -- Easing library
    AnimEngine.Easing = {
        Linear    = function(t) return t end,
        EaseIn    = function(t) return t*t end,
        EaseOut   = function(t) return 1-(1-t)^2 end,
        EaseInOut = function(t) return t<.5 and 2*t*t or 1-2*(1-t)^2 end,
        EaseOutBack = function(t)
            local c1,c3 = 1.70158, 2.70158
            return 1 + c3*(t-1)^3 + c1*(t-1)^2
        end,
        EaseOutBounce = function(t)
            local n1,d1 = 7.5625, 2.75
            if t < 1/d1 then return n1*t*t
            elseif t < 2/d1 then t=t-1.5/d1;  return n1*t*t+0.75
            elseif t < 2.5/d1 then t=t-2.25/d1; return n1*t*t+0.9375
            else t=t-2.625/d1; return n1*t*t+0.984375 end
        end,
    }
end

-- ─── Object Pooling ────────────────────────────────────────────────────────
local ObjectPool = {}
do
    local pools = {}  -- { className → { freeList } }

    local function getPool(className)
        if not pools[className] then
            pools[className] = { free = {}, count = 0 }
        end
        return pools[className]
    end

    function ObjectPool.Get(className, properties)
        local pool = getPool(className)
        local obj
        if #pool.free > 0 then
            obj = table.remove(pool.free)
        else
            obj = Instance.new(className)
            pool.count += 1
        end
        if properties then
            for k, v in pairs(properties) do
                pcall(function() obj[k] = v end)
            end
        end
        return obj
    end

    function ObjectPool.Release(instance)
        if not instance or not instance.ClassName then return end
        local pool = getPool(instance.ClassName)
        if #pool.free >= POOL_MAX then
            instance:Destroy()
            return
        end
        -- Reset common properties
        pcall(function()
            instance.Parent = nil
            if instance:IsA("GuiObject") then
                instance.Visible = false
            end
        end)
        table.insert(pool.free, instance)
    end

    function ObjectPool.Stats()
        local s = {}
        for k, v in pairs(pools) do
            s[k] = { free = #v.free, total = v.count }
        end
        return s
    end
end

-- ─── Maid (Connection Manager) ─────────────────────────────────────────────
--[[
    Automatic cleanup of RBXScriptConnections, Instances, and functions.
    Used everywhere to prevent memory leaks.
]]
local Maid = {}
Maid.__index = Maid

function Maid.New()
    return setmetatable({ _tasks = {} }, Maid)
end

function Maid:Give(task)
    if task then
        table.insert(self._tasks, task)
    end
    return task
end

function Maid:GiveMany(...)
    for _, t in ipairs({...}) do self:Give(t) end
end

-- Convenience: connect and auto-manage
function Maid:Connect(signal, fn)
    return self:Give(signal:Connect(fn))
end

function Maid:Once(signal, fn)
    return self:Give(signal:Once(fn))
end

function Maid:Clean()
    for i = #self._tasks, 1, -1 do
        local task = table.remove(self._tasks, i)
        if typeof(task) == "RBXScriptConnection" then
            if task.Connected then task:Disconnect() end
        elseif typeof(task) == "Instance" then
            task:Destroy()
        elseif typeof(task) == "function" then
            pcall(task)
        elseif typeof(task) == "table" and task.Clean then
            task:Clean()
        end
    end
end

function Maid:Destroy()
    self:Clean()
end

-- ─── Reactive State Management ─────────────────────────────────────────────
--[[
    Signal  – a typed event emitter
    State   – a reactive value that notifies observers on change
    Computed– a derived value that recomputes when dependencies change
    Effect  – a side-effect that re-runs when dependencies change
]]
local Reactive = {}
do
    -- Signal
    local Signal = {}
    Signal.__index = Signal

    function Signal.New()
        return setmetatable({ _listeners = {} }, Signal)
    end

    function Signal:Fire(...)
        for _, fn in ipairs(self._listeners) do
            pcall(fn, ...)
        end
    end

    function Signal:Connect(fn)
        table.insert(self._listeners, fn)
        local idx = #self._listeners
        return {
            Disconnect = function()
                table.remove(self._listeners, idx)
            end,
            Connected = true,
        }
    end

    function Signal:Once(fn)
        local conn
        conn = self:Connect(function(...)
            conn:Disconnect()
            fn(...)
        end)
        return conn
    end

    function Signal:Wait()
        local thread = coroutine.running()
        local conn
        conn = self:Connect(function(...)
            conn:Disconnect()
            task.spawn(thread, ...)
        end)
        return coroutine.yield()
    end

    -- State
    local State = {}
    State.__index = State

    function State.New(initialValue, validator)
        local s = setmetatable({
            _value    = initialValue,
            _changed  = Signal.New(),
            _validator= validator,
        }, State)
        return s
    end

    function State:Get()
        return self._value
    end

    function State:Set(newValue)
        if self._validator then
            local ok, err = self._validator(newValue)
            if not ok then
                warn("State validation failed:", err)
                return false
            end
        end
        if newValue == self._value then return true end
        local old = self._value
        self._value = newValue
        self._changed:Fire(newValue, old)
        return true
    end

    function State:OnChanged(fn)
        return self._changed:Connect(fn)
    end

    -- Computed
    local function Computed(dependencies, compute)
        local s = State.New(compute())
        for _, dep in ipairs(dependencies) do
            dep:OnChanged(function()
                s:Set(compute())
            end)
        end
        return s
    end

    -- Effect
    local function Effect(dependencies, fn)
        fn()  -- run immediately
        local conns = {}
        for _, dep in ipairs(dependencies) do
            table.insert(conns, dep:OnChanged(fn))
        end
        return {
            Destroy = function()
                for _, c in ipairs(conns) do c:Disconnect() end
            end
        }
    end

    Reactive.Signal   = Signal
    Reactive.State    = State
    Reactive.Computed = Computed
    Reactive.Effect   = Effect
end

-- ─── Event Bus ─────────────────────────────────────────────────────────────
--[[
    Global pub/sub: decouple components completely.
    Any component can emit or subscribe without holding references.
]]
local EventBus = {}
do
    local channels = {}

    function EventBus:Emit(channel, ...)
        if not channels[channel] then return end
        for _, fn in ipairs(channels[channel]) do
            pcall(fn, ...)
        end
    end

    function EventBus:On(channel, fn)
        if not channels[channel] then
            channels[channel] = {}
        end
        table.insert(channels[channel], fn)
        local idx = #channels[channel]
        return {
            Disconnect = function()
                table.remove(channels[channel], idx)
            end
        }
    end

    function EventBus:Once(channel, fn)
        local conn
        conn = self:On(channel, function(...)
            conn:Disconnect()
            fn(...)
        end)
        return conn
    end
end

-- ─── Z-Index Manager ───────────────────────────────────────────────────────
--[[
    Assign logical layers instead of raw ZIndex values.
    Prevents stacking order conflicts globally.
]]
local ZManager = {}
do
    local layerBase = {
        base     = 1,
        content  = 5,
        float    = 10,
        dropdown = 50,
        tooltip  = 80,
        modal    = 100,
        toast    = 200,
        cursor   = 500,
        debug    = 999,
    }

    function ZManager.Get(layer)
        return layerBase[layer] or 1
    end

    function ZManager.Apply(instance, layer, offset)
        local z = ZManager.Get(layer) + (offset or 0)
        pcall(function() instance.ZIndex = z end)
        return z
    end

    function ZManager.ApplyTree(root, layer, offset)
        local z = ZManager.Get(layer) + (offset or 0)
        pcall(function()
            for _, desc in ipairs(root:GetDescendants()) do
                if desc:IsA("GuiObject") then
                    desc.ZIndex = z
                end
            end
            root.ZIndex = z
        end)
    end
end

-- ─── Focus Manager ─────────────────────────────────────────────────────────
--[[
    Proper keyboard navigation between focusable elements.
    Tab to move forward, Shift+Tab to move backward.
    Escape to close/dismiss.
]]
local FocusManager = {}
do
    local focusables = {}  -- ordered list of { element, onFocus, onBlur }
    local currentIdx = 0
    local maid = Maid.New()

    function FocusManager.Register(element, onFocus, onBlur, priority)
        table.insert(focusables, {
            element   = element,
            onFocus   = onFocus,
            onBlur    = onBlur,
            priority  = priority or 0,
        })
        table.sort(focusables, function(a, b) return a.priority < b.priority end)
    end

    function FocusManager.Unregister(element)
        for i, f in ipairs(focusables) do
            if f.element == element then
                table.remove(focusables, i)
                return
            end
        end
    end

    function FocusManager.Focus(element)
        for i, f in ipairs(focusables) do
            if f.element == element then
                if currentIdx ~= 0 and focusables[currentIdx] then
                    pcall(focusables[currentIdx].onBlur)
                end
                currentIdx = i
                pcall(f.onFocus)
                return
            end
        end
    end

    function FocusManager.Next()
        if #focusables == 0 then return end
        if currentIdx > 0 and focusables[currentIdx] then
            pcall(focusables[currentIdx].onBlur)
        end
        currentIdx = (currentIdx % #focusables) + 1
        pcall(focusables[currentIdx].onFocus)
    end

    function FocusManager.Prev()
        if #focusables == 0 then return end
        if currentIdx > 0 and focusables[currentIdx] then
            pcall(focusables[currentIdx].onBlur)
        end
        currentIdx = ((currentIdx - 2 + #focusables) % #focusables) + 1
        pcall(focusables[currentIdx].onFocus)
    end

    function FocusManager.Clear()
        if currentIdx > 0 and focusables[currentIdx] then
            pcall(focusables[currentIdx].onBlur)
        end
        currentIdx = 0
    end

    -- Handle Tab / Shift+Tab
    maid:Connect(UserInputService.InputBegan, function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Tab then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
              or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                FocusManager.Prev()
            else
                FocusManager.Next()
            end
        end
    end)
end

-- ─── Interaction Manager ───────────────────────────────────────────────────
--[[
    Prevents multiple popups, dropdowns, context menus from fighting.
    Only one "exclusive" layer is active at a time.
]]
local InteractionManager = {}
do
    local stack = {}  -- stack of { id, dismiss }

    function InteractionManager.Push(id, dismissFn)
        -- dismiss current top if same type
        if #stack > 0 and stack[#stack].id == id then
            InteractionManager.Pop()
        end
        table.insert(stack, { id = id, dismiss = dismissFn })
    end

    function InteractionManager.Pop()
        if #stack > 0 then
            local entry = table.remove(stack)
            if entry.dismiss then pcall(entry.dismiss) end
        end
    end

    function InteractionManager.DismissAll()
        while #stack > 0 do
            InteractionManager.Pop()
        end
    end

    function InteractionManager.Current()
        return stack[#stack]
    end
end

-- ─── Async Task Manager ────────────────────────────────────────────────────
--[[
    Lightweight Promise-like system for async operations.
    Wraps coroutines with resolve/reject/finally semantics.
]]
local AsyncTask = {}
do
    local TaskStatus = { Pending = "Pending", Fulfilled = "Fulfilled", Rejected = "Rejected" }

    local Promise = {}
    Promise.__index = Promise

    function Promise.New(executor)
        local self = setmetatable({
            _status  = TaskStatus.Pending,
            _value   = nil,
            _reason  = nil,
            _onFulfill = {},
            _onReject  = {},
        }, Promise)

        task.spawn(function()
            local ok, result = pcall(function()
                executor(
                    function(v) self:_resolve(v) end,
                    function(r) self:_reject(r)  end
                )
            end)
            if not ok then self:_reject(result) end
        end)

        return self
    end

    function Promise:_resolve(value)
        if self._status ~= TaskStatus.Pending then return end
        self._status = TaskStatus.Fulfilled
        self._value  = value
        for _, fn in ipairs(self._onFulfill) do pcall(fn, value) end
    end

    function Promise:_reject(reason)
        if self._status ~= TaskStatus.Pending then return end
        self._status = TaskStatus.Rejected
        self._reason = reason
        for _, fn in ipairs(self._onReject) do pcall(fn, reason) end
    end

    function Promise:Then(onFulfill, onReject)
        if self._status == TaskStatus.Fulfilled then
            if onFulfill then pcall(onFulfill, self._value) end
        elseif self._status == TaskStatus.Rejected then
            if onReject then pcall(onReject, self._reason) end
        else
            if onFulfill then table.insert(self._onFulfill, onFulfill) end
            if onReject  then table.insert(self._onReject,  onReject)  end
        end
        return self
    end

    function Promise:Catch(fn)
        return self:Then(nil, fn)
    end

    function Promise:Finally(fn)
        self:Then(fn, fn)
        return self
    end

    -- Await a promise (yields coroutine)
    function Promise:Await()
        if self._status == TaskStatus.Fulfilled then return true, self._value end
        if self._status == TaskStatus.Rejected  then return false, self._reason end
        local thread = coroutine.running()
        self:Then(
            function(v) task.spawn(thread, true,  v) end,
            function(r) task.spawn(thread, false, r) end
        )
        return coroutine.yield()
    end

    AsyncTask.Promise = Promise
    AsyncTask.Status  = TaskStatus

    function AsyncTask.Delay(t)
        return Promise.New(function(resolve)
            task.delay(t, resolve)
        end)
    end

    function AsyncTask.All(promises)
        return Promise.New(function(resolve, reject)
            local results = {}
            local count   = #promises
            if count == 0 then resolve(results); return end
            for i, p in ipairs(promises) do
                p:Then(function(v)
                    results[i] = v
                    count -= 1
                    if count == 0 then resolve(results) end
                end, reject)
            end
        end)
    end
end

-- ─── Undo / Redo Manager ───────────────────────────────────────────────────
local UndoManager = {}
do
    local stacks   = {}  -- per-context stacks
    local MAX_HIST = 50

    function UndoManager.GetStack(ctx)
        if not stacks[ctx] then
            stacks[ctx] = { past = {}, future = {} }
        end
        return stacks[ctx]
    end

    function UndoManager.Push(ctx, undoFn, redoFn, description)
        local s = UndoManager.GetStack(ctx)
        if #s.past >= MAX_HIST then
            table.remove(s.past, 1)
        end
        table.insert(s.past, { undo = undoFn, redo = redoFn, desc = description })
        s.future = {}  -- clear redo stack on new action
    end

    function UndoManager.Undo(ctx)
        local s = UndoManager.GetStack(ctx)
        if #s.past == 0 then return false end
        local entry = table.remove(s.past)
        pcall(entry.undo)
        table.insert(s.future, entry)
        EventBus:Emit("undo", ctx, entry.desc)
        return true
    end

    function UndoManager.Redo(ctx)
        local s = UndoManager.GetStack(ctx)
        if #s.future == 0 then return false end
        local entry = table.remove(s.future)
        pcall(entry.redo)
        table.insert(s.past, entry)
        EventBus:Emit("redo", ctx, entry.desc)
        return true
    end

    function UndoManager.CanUndo(ctx)
        return #UndoManager.GetStack(ctx).past > 0
    end

    function UndoManager.CanRedo(ctx)
        return #UndoManager.GetStack(ctx).future > 0
    end
end

-- ─── Navigation History ────────────────────────────────────────────────────
local NavHistory = {}
do
    local history  = {}
    local current  = 0
    local MAX_NAV  = 20

    function NavHistory.Push(entry)
        -- discard forward history
        while #history > current do
            table.remove(history)
        end
        if #history >= MAX_NAV then
            table.remove(history, 1)
        end
        table.insert(history, entry)
        current = #history
    end

    function NavHistory.Back()
        if current <= 1 then return nil end
        current -= 1
        return history[current]
    end

    function NavHistory.Forward()
        if current >= #history then return nil end
        current += 1
        return history[current]
    end

    function NavHistory.CanGoBack()
        return current > 1
    end

    function NavHistory.CanGoForward()
        return current < #history
    end
end

-- ─── Performance Profiler ──────────────────────────────────────────────────
local Profiler = {}
do
    local timers  = {}  -- name → { start, total, count }
    local enabled = false

    function Profiler.Enable()  enabled = true  end
    function Profiler.Disable() enabled = false end
    function Profiler.IsEnabled() return enabled end

    function Profiler.Begin(name)
        if not enabled then return end
        timers[name] = timers[name] or { total = 0, count = 0 }
        timers[name].start = tick()
    end

    function Profiler.End(name)
        if not enabled or not timers[name] then return end
        local elapsed = tick() - (timers[name].start or tick())
        timers[name].total += elapsed
        timers[name].count += 1
    end

    function Profiler.GetReport()
        local report = {}
        for name, data in pairs(timers) do
            report[name] = {
                total   = data.total,
                count   = data.count,
                average = data.count > 0 and data.total / data.count or 0,
            }
        end
        return report
    end

    function Profiler.Reset()
        timers = {}
    end
end

-- ─── Plugin Architecture ───────────────────────────────────────────────────
--[[
    Third-party components register themselves here.
    The library calls lifecycle hooks when relevant.
]]
local PluginSystem = {}
do
    local plugins   = {}
    local lifecycle = { onWindowCreate = {}, onTabCreate = {}, onThemeChange = {}, onUnload = {} }

    function PluginSystem.Register(plugin)
        assert(plugin.Name, "Plugin must have a Name")
        plugins[plugin.Name] = plugin
        -- Register lifecycle hooks
        for event, list in pairs(lifecycle) do
            if plugin[event] then
                table.insert(list, plugin[event])
            end
        end
        if plugin.Init then pcall(plugin.Init) end
    end

    function PluginSystem.Emit(event, ...)
        for _, fn in ipairs(lifecycle[event] or {}) do
            pcall(fn, ...)
        end
    end

    function PluginSystem.Get(name)
        return plugins[name]
    end
end

-- ─── Virtualized List ──────────────────────────────────────────────────────
--[[
    Renders only visible rows; recycles row frames from a pool.
    Handles thousands of items smoothly.
]]
local VirtualList = {}
VirtualList.__index = VirtualList

function VirtualList.New(params)
    --[[
        params = {
            container   = ScrollingFrame
            rowHeight   = number
            items       = {} (can be updated)
            renderItem  = function(frame, item, index) ... end
            padding     = number (optional)
        }
    ]]
    local self = setmetatable({
        container  = params.container,
        rowHeight  = params.rowHeight or 24,
        items      = params.items or {},
        renderItem = params.renderItem,
        padding    = params.padding or 0,
        _visibleRows = {},
        _maid        = Maid.New(),
    }, VirtualList)

    self:_Init()
    return self
end

function VirtualList:_Init()
    local container = self.container
    container.ScrollingEnabled = true
    container.ClipsDescendants = true

    local function refresh()
        self:_Render()
    end

    self._maid:Connect(container:GetPropertyChangedSignal("CanvasPosition"), refresh)
    self._maid:Connect(container:GetPropertyChangedSignal("AbsoluteSize"),   refresh)
    self:_Render()
end

function VirtualList:_Render()
    local container  = self.container
    local rowH       = self.rowHeight
    local pad        = self.padding
    local scrollY    = container.CanvasPosition.Y
    local viewH      = container.AbsoluteSize.Y
    local total      = #self.items

    -- Update canvas size
    container.CanvasSize = UDim2.new(0, 0, 0, total * rowH + pad * 2)

    local firstVisible = math.max(1, math.floor((scrollY - pad) / rowH))
    local lastVisible  = math.min(total, math.ceil((scrollY + viewH - pad) / rowH) + 1)

    -- Release rows no longer visible
    for idx, row in pairs(self._visibleRows) do
        if idx < firstVisible or idx > lastVisible then
            ObjectPool.Release(row)
            self._visibleRows[idx] = nil
        end
    end

    -- Create/recycle rows for visible range
    for i = firstVisible, lastVisible do
        if not self._visibleRows[i] and self.items[i] then
            local frame = ObjectPool.Get("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, pad + (i-1)*rowH),
                Size     = UDim2.new(1, 0, 0, rowH),
                Parent   = container,
            })
            self._visibleRows[i] = frame
            pcall(self.renderItem, frame, self.items[i], i)
        end
    end
end

function VirtualList:SetItems(items)
    self.items = items
    self:_Render()
end

function VirtualList:Destroy()
    self._maid:Destroy()
    for _, row in pairs(self._visibleRows) do
        ObjectPool.Release(row)
    end
    self._visibleRows = {}
end

-- ─── Microinteraction Helpers ──────────────────────────────────────────────
local Micro = {}
do
    local scheme = ThemeEngine.CurrentScheme

    -- Hover glow: UIStroke tweens in/out on hover
    function Micro.HoverGlow(element, maid, color, thickness)
        color     = color or Library.Scheme.AccentColor
        thickness = thickness or 1.5
        local stroke = Instance.new("UIStroke")
        stroke.Color       = color
        stroke.Thickness   = 0
        stroke.Transparency= 0.4
        stroke.Parent      = element

        local tiIn  = TweenInfo.new(0.12, Enum.EasingStyle.Quad)
        local tiOut = TweenInfo.new(0.18, Enum.EasingStyle.Quad)

        maid:Give(element.MouseEnter:Connect(function()
            TweenService:Create(stroke, tiIn,  { Thickness = thickness }):Play()
        end))
        maid:Give(element.MouseLeave:Connect(function()
            TweenService:Create(stroke, tiOut, { Thickness = 0 }):Play()
        end))
        return stroke
    end

    -- Press scale from center
    function Micro.PressDepression(element, maid)
        local scale = Instance.new("UIScale")
        scale.Scale  = 1
        scale.Parent = element

        local tiDown = TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tiUp   = TweenInfo.new(0.15, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)

        maid:Give(element.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            TweenService:Create(scale, tiDown, { Scale = 0.95 }):Play()
        end))
        maid:Give(element.InputEnded:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            TweenService:Create(scale, tiUp, { Scale = 1.0 }):Play()
        end))
        return scale
    end

    -- Ripple: clip to button, smaller max radius
    function Micro.Ripple(parent, color, maid)
        color = color or Color3.new(1,1,1)
        -- clip frame using raw Instance.new (Micro is defined before New)
        local clipFrame = Instance.new("Frame")
        clipFrame.BackgroundTransparency = 1
        clipFrame.ClipsDescendants       = true
        clipFrame.BorderSizePixel        = 0
        clipFrame.Size                   = UDim2.fromScale(1, 1)
        clipFrame.ZIndex                 = parent.ZIndex
        clipFrame.Parent                 = parent

        maid:Give(parent.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            local pp   = parent.AbsolutePosition
            local ps   = parent.AbsoluteSize
            local maxR = math.min(math.sqrt(ps.X^2 + ps.Y^2), ps.X * 2)
            local rx   = input.Position.X - pp.X
            local ry   = input.Position.Y - pp.Y

            local ripple = Instance.new("Frame")
            ripple.AnchorPoint          = Vector2.new(0.5, 0.5)
            ripple.BackgroundColor3     = color
            ripple.BackgroundTransparency = 0.75
            ripple.BorderSizePixel      = 0
            ripple.Position             = UDim2.fromOffset(rx, ry)
            ripple.Size                 = UDim2.fromOffset(0, 0)
            ripple.ZIndex               = parent.ZIndex + 1
            ripple.Parent               = clipFrame

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = ripple

            local tw = TweenService:Create(ripple,
                TweenInfo.new(RIPPLE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.fromOffset(maxR, maxR), BackgroundTransparency = 1 })
            tw:Play()
            tw.Completed:Connect(function()
                corner:Destroy()
                ripple:Destroy()
            end)
        end))
    end

    -- Selection pulse: uses TweenService looping pattern
    function Micro.SelectionPulse(element, maid, color)
        color = color or ThemeEngine.CurrentScheme.AccentColor
        local stroke = Instance.new("UIStroke")
        stroke.Color       = color
        stroke.Thickness   = 1.5
        stroke.Transparency= 0
        stroke.Parent      = element
        local running = false

        local function doPulse()
            running = true
            local function cycle()
                if not running then return end
                local t1 = TweenService:Create(stroke,
                    TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    { Transparency = 0.8 })
                t1:Play()
                t1.Completed:Connect(function()
                    if not running then return end
                    local t2 = TweenService:Create(stroke,
                        TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                        { Transparency = 0 })
                    t2:Play()
                    t2.Completed:Connect(cycle)
                end)
            end
            cycle()
        end

        return {
            Start  = doPulse,
            Stop   = function() running = false; stroke.Transparency = 1 end,
            Stroke = stroke,
        }
    end
end

-- ─── Instance Creator ──────────────────────────────────────────────────────
local Registry = {}  -- { instance → { property → schemeKey|fn } }

local function GetSchemeValue(v)
    local scheme = ThemeEngine.CurrentScheme
    if typeof(v) == "string" and scheme[v] then
        return scheme[v]
    end
    if typeof(v) == "function" then
        return v()
    end
    return nil
end

local function FillInstance(instance, props)
    local themeProps = Registry[instance] or {}
    for k, v in pairs(props) do
        if k ~= "Parent" and k ~= "Text" then
            local sv = GetSchemeValue(v)
            if sv ~= nil then
                themeProps[k] = v
                v = sv
            else
                themeProps[k] = nil
            end
        end
        pcall(function() instance[k] = v end)
    end
    if next(themeProps) then
        Registry[instance] = themeProps
    end
end

local ClassDefaults = {
    Frame = { BorderSizePixel = 0 },
    TextLabel = {
        BorderSizePixel        = 0,
        BackgroundTransparency = 1,
        TextColor3             = "TextPrimary",
        FontFace               = "Font",
        RichText               = true,
    },
    TextButton = {
        AutoButtonColor  = false,
        BorderSizePixel  = 0,
        TextColor3       = "TextPrimary",
        FontFace         = "Font",
        RichText         = true,
    },
    TextBox = {
        BorderSizePixel   = 0,
        TextColor3        = "TextPrimary",
        PlaceholderColor3 = "TextMuted",
        FontFace          = "Font",
        Text              = "",
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ImageButton = {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ScrollingFrame = {
        BorderSizePixel   = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = "MutedColor",
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder,
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    },
}

local function New(className, props)
    local inst = Instance.new(className)
    if ClassDefaults[className] then
        FillInstance(inst, ClassDefaults[className])
    end
    if props then
        FillInstance(inst, props)
    end
    return inst
end

local function UpdateRegistry()
    for inst, props in pairs(Registry) do
        if inst and inst.Parent then
            for prop, v in pairs(props) do
                local sv = GetSchemeValue(v)
                if sv ~= nil then
                    pcall(function() inst[prop] = sv end)
                end
            end
        else
            Registry[inst] = nil
        end
    end
end

-- ─── Screen Setup ──────────────────────────────────────────────────────────
local LibraryMaid   = Maid.New()
local ScreenGui     = New("ScreenGui", {
    Name            = "NexusUI",
    DisplayOrder    = 997,
    ResetOnSpawn    = false,
    IgnoreGuiInset  = true,
    ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    -- Blur/glass effect requires ScreenGui to not clip
})
-- Glass effect note: true background blur is not feasible per-element in Roblox
-- (BlurEffect is screen-wide). We instead use layered semi-transparent frames
-- to fake a "frosted" look localized to the menu.
pcall(protectgui, ScreenGui)
local ok = pcall(function() ScreenGui.Parent = gethui() end)
if not ok then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

LibraryMaid:Give(ScreenGui.DescendantRemoving:Connect(function(inst)
    Registry[inst] = nil
end))

-- ─── Toast / Notification System ──────────────────────────────────────────
--[[
    Multiple toasts stack vertically.
    Types: info, success, warning, error
    Smart grouping: identical messages are collapsed.
    Priority queue: high-priority toasts insert at top.
]]
local ToastSystem = {}
do
    local toasts    = {}
    local toastArea = New("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position    = UDim2.new(1, -12, 1, -12),
        Size        = UDim2.new(0, 320, 1, -24),
        Parent      = ScreenGui,
    })
    ZManager.Apply(toastArea, "toast")

    New("UIListLayout", {
        VerticalAlignment   = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding             = UDim.new(0, 6),
        FillDirection       = Enum.FillDirection.Vertical,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = toastArea,
    })

    local typeColors = {
        info    = ThemeEngine.CurrentScheme.InfoColor,
        success = ThemeEngine.CurrentScheme.SuccessColor,
        warning = ThemeEngine.CurrentScheme.WarningColor,
        error   = ThemeEngine.CurrentScheme.DangerColor,
    }
    local typeIcons = {
        info    = "ℹ",
        success = "✓",
        warning = "⚠",
        error   = "✕",
    }

    local toastCounter = 0

    function ToastSystem.Show(message, toastType, options)
        options = options or {}
        toastType = toastType or "info"
        local duration = options.Duration or TOAST_DURATION
        local priority = options.Priority or 0

        -- Smart grouping: collapse duplicates
        for _, existing in ipairs(toasts) do
            if existing.message == message and existing.type == toastType then
                existing.count += 1
                if existing.countLabel then
                    existing.countLabel.Text = "×" .. existing.count
                    existing.countLabel.Visible = true
                end
                existing.remaining = duration  -- reset timer
                return existing
            end
        end

        toastCounter += 1
        local id    = toastCounter
        local color = typeColors[toastType] or ThemeEngine.CurrentScheme.InfoColor

        local holder = New("Frame", {
            BackgroundTransparency = 1,
            Size        = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = -priority * 1000 + id,
            Parent      = toastArea,
        })

        local card = New("Frame", {
            BackgroundColor3 = "SurfaceColor",
            BackgroundTransparency = 0.12,
            Size        = UDim2.new(1, 0, 0, 36),
            Parent      = holder,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = card })
        New("UIStroke", { Color = color, Thickness = 1, Transparency = 0.5, Parent = card })
        New("UIPadding", {
            PaddingLeft   = UDim.new(0, 10),
            PaddingRight  = UDim.new(0, 26),
            PaddingTop    = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 0),
            Parent        = card,
        })

        -- Icon dot
        local iconLabel = New("TextLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size     = UDim2.fromOffset(14, 14),
            Text     = typeIcons[toastType] or "●",
            TextSize = 11,
            TextColor3 = color,
            ZIndex   = card.ZIndex + 1,
            Parent   = card,
        })

        local msgLabel = New("TextLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 18, 0.5, 0),
            Size     = UDim2.new(1, -18, 1, 0),
            Text     = message,
            TextSize = Tokens.FontSize.SM,
            TextColor3   = "TextPrimary",
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent       = card,
        })

        local countLabel = New("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -2, 0.5, 0),
            Size     = UDim2.fromOffset(20, 14),
            Text     = "",
            TextSize = Tokens.FontSize.XS,
            TextColor3 = color,
            TextXAlignment = Enum.TextXAlignment.Right,
            Visible  = false,
            ZIndex   = card.ZIndex + 2,
            Parent   = card,
        })

        local dismissBtn = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -2, 0.5, 0),
            Size     = UDim2.fromOffset(18, 18),
            Text     = "×",
            TextSize = 14,
            TextColor3 = "TextMuted",
            ZIndex   = card.ZIndex + 2,
            Parent   = card,
        })

        -- Slide up from below
        local startY = holder.AbsolutePosition.Y + 40
        card.Position = UDim2.fromOffset(0, 10)
        card.BackgroundTransparency = 1
        TweenService:Create(card,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { BackgroundTransparency = 0, Position = UDim2.fromOffset(0, 0) }):Play()

        local toastData = {
            id         = id, message = message, type = toastType,
            count = 1, countLabel = countLabel,
            holder = holder, card = card,
            remaining = duration, dismissed = false,
        }

        local function dismiss()
            if toastData.dismissed then return end
            toastData.dismissed = true
            local idx = table.find(toasts, toastData)
            if idx then table.remove(toasts, idx) end
            TweenService:Create(card,
                TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 8) }):Play()
            task.delay(0.14, function()
                if holder and holder.Parent then holder:Destroy() end
            end)
        end

        dismissBtn.MouseButton1Click:Connect(dismiss)

        -- Timer
        local timerConn
        timerConn = RunService.Heartbeat:Connect(function(dt)
            if toastData.dismissed then timerConn:Disconnect(); return end
            toastData.remaining -= dt
            if toastData.remaining <= 0 then
                timerConn:Disconnect()
                dismiss()
            end
        end)
        LibraryMaid:Give(timerConn)

        table.insert(toasts, toastData)
        return toastData
    end

    function ToastSystem.Info(msg, opts)    return ToastSystem.Show(msg, "info",    opts) end
    function ToastSystem.Success(msg, opts) return ToastSystem.Show(msg, "success", opts) end
    function ToastSystem.Warning(msg, opts) return ToastSystem.Show(msg, "warning", opts) end
    function ToastSystem.Error(msg, opts)   return ToastSystem.Show(msg, "error",   opts) end
end

-- ─── Script Hub ─────────────────────────────────────────────────────────────
--[[
    Replaces the old VS Code style command palette with an integrated script
    hub: big rounded cards you click to run a saved loadstring, plus a search
    bar to filter them. The whole screen darkens + blurs behind it (real
    Lighting.BlurEffect, not the menu-local fake frost), and the main window
    minimizes automatically while it's open (restored on close if it was open).

    API kept compatible with the old CommandPalette so existing call sites
    elsewhere in the file (Settings/theme quick-actions) don't need to change:
        CommandPalette.Register({ name=.., category=.., action=.. })
        CommandPalette.Open() / Close() / Toggle()
    Those registered entries still show up — as a slim "Quick Actions" list
    under the search results — while the big cards above them are reserved
    for user-created scripts (Name + loadstring), which is the actual point.
]]
local CommandPalette = {}
do
    -- ── persistence (independent of ConfigSystem — these aren't config values) ──
    -- NOTE: Library.ConfigFolder isn't set until the user calls
    -- Library:CreateWindow(...), which happens well after this module
    -- finishes loading (and Library itself is nil at module-load time, see
    -- the forward-declaration note near the top of the file). So the path
    -- must be computed fresh on every read/write, not baked in once here.
    local function getScriptsPath()
        return (Library and Library.ConfigFolder or "NexusUI") .. "/scripthub_scripts.json"
    end

    local function tryWrite(path, data)
        if writefile then
            local ok = pcall(writefile, path, data)
            return ok
        end
        if getgenv then
            getgenv().__NexusUI_ScriptHub = getgenv().__NexusUI_ScriptHub or {}
            getgenv().__NexusUI_ScriptHub[path] = data
            return true
        end
        return false
    end

    local function tryRead(path)
        if readfile and isfile and isfile(path) then
            local ok, data = pcall(readfile, path)
            if ok and data then return data end
        end
        if getgenv and getgenv().__NexusUI_ScriptHub then
            return getgenv().__NexusUI_ScriptHub[path]
        end
        return nil
    end

    local function ensureFolder()
        local folder = Library and Library.ConfigFolder or "NexusUI"
        if makefolder and not (isfolder and isfolder(folder)) then
            pcall(makefolder, folder)
        end
    end

    -- quick-actions (old CommandPalette.Register entries) — kept separate
    -- from user scripts since they're a different shape ({name,category,action}
    -- vs {name,code})
    local quickActions = {}

    -- ── Built-in default scripts ──────────────────────────────────────────
    -- Edit this list to ship preset cards with the library itself — they
    -- show up the very first time anyone opens the hub, no setup code or
    -- UI:AddScript() call needed. They're seeded once into the saved file;
    -- if a user deletes one it stays deleted (it's their choice at that
    -- point), it won't keep reappearing every load.
    local DEFAULT_SCRIPTS = {
        -- { Name = "Example", Code = 'loadstring(game:HttpGet("https://..."))()' },
        { Name = "Infinite Yield", Code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()' },
        { Name = "Secure Dex", Code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/SDex.lua"))()' },
        { Name = "Ketamine", Code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/Ketamine.lua"))()' },
    }

    -- user scripts: { id, name, code }
    local scripts = {}
    local scriptIdCounter = 0

    local function loadScripts()
        local raw = tryRead(getScriptsPath())
        if not raw then return end
        local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok and typeof(data) == "table" then
            scripts = data
            for _, s in ipairs(scripts) do
                scriptIdCounter = math.max(scriptIdCounter, tonumber(s.id) or 0)
            end
        end
    end

    local function saveScripts()
        ensureFolder()
        local ok, encoded = pcall(function() return HttpService:JSONEncode(scripts) end)
        if ok then tryWrite(getScriptsPath(), encoded) end
    end

    local function seedDefaultsIfNeeded()
        if #DEFAULT_SCRIPTS == 0 then return end
        if tryRead(getScriptsPath()) then return end -- file already exists: not a fresh install, never re-seed
        for _, d in ipairs(DEFAULT_SCRIPTS) do
            scriptIdCounter += 1
            table.insert(scripts, { id = scriptIdCounter, name = d.Name or d.name, code = d.Code or d.code })
        end
        saveScripts()
    end

    local scriptsLoaded = false
    local function ensureScriptsLoaded()
        if scriptsLoaded then return end
        scriptsLoaded = true
        loadScripts()
        if #scripts == 0 then
            seedDefaultsIfNeeded()
        end
    end

    -- ── fuzzy match scorer (kept from old palette) ──
    local function fuzzyScore(pattern, str)
        pattern = pattern:lower()
        str     = str:lower()
        local score = 0
        local pi    = 1
        for i = 1, #str do
            if pi <= #pattern and str:sub(i,i) == pattern:sub(pi,pi) then
                score += 10 - (i - pi)
                pi += 1
            end
        end
        if pi <= #pattern then return -1 end
        return score
    end

    -- ── state ──
    local visible        = false
    local openGen         = 0   -- generation token: invalidates stale close-delays
    local wasWindowOpen   = false
    local blurEffect, dimOverlay
    local frame, inputBox, cardGrid, quickList, emptyLabel
    local query = ""
    local maid = Maid.New()

    -- ── full-screen darken + blur (real BlurEffect, screen-wide on purpose —
    -- this is different from the menu's own internal frost layers, which
    -- only fake a localized blur because BlurEffect can't be scoped) ──
    local function buildScreenDim()
        dimOverlay = New("TextButton", {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            Size    = UDim2.fromScale(1, 1),
            Text    = "",
            AutoButtonColor = false,
            Visible = false,
            Parent  = ScreenGui,
        })
        ZManager.Apply(dimOverlay, "modal")

        -- defensive: if this script was executed before without a clean
        -- Unload(), an old blur effect could still be sitting in Lighting
        -- and would stack with this new one
        local existing = Lighting:FindFirstChild("NexusUI_ScriptHubBlur")
        if existing then existing:Destroy() end

        blurEffect = Instance.new("BlurEffect")
        blurEffect.Name = "NexusUI_ScriptHubBlur"
        blurEffect.Size = 0
        blurEffect.Parent = Lighting
        LibraryMaid:Give(blurEffect)
    end

    local function buildUI()
        frame = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "SurfaceColor",
            Position = UDim2.fromScale(0.5, 0.46),
            Size     = UDim2.fromOffset(620, 480),
            Active   = true, -- blocks clicks on blank panel areas from falling
                              -- through dimOverlay to the game world behind it
            Visible  = false,
            Parent   = dimOverlay,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 20), Parent = frame })
        New("UIStroke", { Color = "BorderColor", Thickness = 1, Transparency = 0.3, Parent = frame })
        ZManager.Apply(frame, "modal", 1)

        local scaleI = Instance.new("UIScale")
        scaleI.Scale = 0.94
        scaleI.Parent = frame

        New("UIPadding", {
            PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20),
            PaddingTop  = UDim.new(0, 18), PaddingBottom = UDim.new(0, 16),
            Parent = frame,
        })
        New("UIListLayout", { Padding = UDim.new(0, 14), Parent = frame })

        -- Header row: title + search bar
        local header = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 26),
            LayoutOrder = 1,
            Parent = frame,
        })
        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 0, 1, 0),
            Text = "Script Hub",
            TextSize = Tokens.FontSize.H2,
            FontFace = "FontBold",
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = header,
        })
        local countLabel = New("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0.5, 0, 1, 0),
            Text = "",
            TextSize = Tokens.FontSize.SM,
            TextColor3 = "TextMuted",
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = header,
        })

        -- Search bar
        local searchRow = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = UDim2.new(1, 0, 0, 38),
            LayoutOrder = 2,
            Parent = frame,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusMD), Parent = searchRow })
        New("UIStroke", { Color = "BorderColor", Thickness = 1, Transparency = 0.3, Parent = searchRow })
        New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = searchRow })

        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 18, 1, 0),
            Text = "⌕",
            TextSize = 18,
            TextColor3 = "TextMuted",
            Parent = searchRow,
        })
        inputBox = New("TextBox", {
            BackgroundTransparency = 1,
            ClearTextOnFocus = false,
            PlaceholderText = "Search scripts…",
            Position = UDim2.fromOffset(26, 0),
            Size     = UDim2.new(1, -26, 1, 0),
            TextSize = Tokens.FontSize.MD,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent   = searchRow,
        })

        -- Body: one scrolling area holding the card grid, then the quick
        -- actions list stacked underneath it. Both auto-size their height
        -- and the outer ScrollingFrame absorbs whatever doesn't fit in the
        -- visible 620x480 frame — this replaces an earlier version that
        -- tried to hand-compute a fixed height for the grid alone and left
        -- no room for the quick-actions list or empty-state message.
        local bodyScroll = New("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.None,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            LayoutOrder = 3,
            Parent = frame,
        })
        New("UIListLayout", { Padding = UDim.new(0, 16), Parent = bodyScroll })

        local gridHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            Parent = bodyScroll,
        })
        cardGrid = gridHolder

        local grid = New("UIGridLayout", {
            CellSize = UDim2.fromOffset(176, 108),
            CellPadding = UDim2.fromOffset(14, 14),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = gridHolder,
        })

        emptyLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            Text = "No scripts yet — click \"+ Add Script\" to create one.",
            TextSize = Tokens.FontSize.MD,
            TextColor3 = "TextMuted",
            Visible = false,
            LayoutOrder = 2,
            Parent = bodyScroll,
        })

        quickList = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 3,
            Visible = false,
            Parent = bodyScroll,
        })
        New("UIListLayout", { Padding = UDim.new(0, 2), Parent = quickList })

        maid:Connect(inputBox:GetPropertyChangedSignal("Text"), function()
            query = inputBox.Text
            CommandPalette.Refresh()
        end)

        return scaleI, countLabel, grid
    end

    local frameScale, countLabel, gridLayout
    buildScreenDim()
    frameScale, countLabel, gridLayout = buildUI()

    -- clicking the darkened backdrop (anywhere outside the hub panel) closes
    -- the hub, same as clicking outside the Add/Edit dialog closes that
    dimOverlay.MouseButton1Click:Connect(function()
        CommandPalette.Close()
    end)

    -- ── Card rendering ──
    local function clearChildren(inst)
        for _, c in ipairs(inst:GetChildren()) do
            if not c:IsA("UILayout") and not c:IsA("UIPadding") then
                c:Destroy()
            end
        end
    end

    local function makeAddCard(layoutOrder)
        local card = New("TextButton", {
            BackgroundColor3 = "BackgroundColor",
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = layoutOrder,
            Parent = cardGrid,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 18), Parent = card })
        local stroke = New("UIStroke", {
            Color = "BorderColor",
            Thickness = 1.5,
            Transparency = 0.2,
            Parent = card,
        })
        -- dashed look isn't natively supported; emulate with a slightly
        -- transparent stroke + plus icon instead
        New("TextLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.38),
            Size = UDim2.fromOffset(34, 34),
            Text = "+",
            TextSize = 30,
            TextColor3 = "AccentColor",
            Parent = card,
        })
        New("TextLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.72),
            Size = UDim2.new(1, -16, 0, 18),
            Text = "Add Script",
            TextSize = Tokens.FontSize.MD,
            TextColor3 = "TextSecondary",
            Parent = card,
        })

        card.MouseEnter:Connect(function()
            TweenService:Create(stroke, TweenInfo.new(0.12), { Color = ThemeEngine.CurrentScheme.AccentColor, Transparency = 0 }):Play()
        end)
        card.MouseLeave:Connect(function()
            TweenService:Create(stroke, TweenInfo.new(0.12), { Color = ThemeEngine.CurrentScheme.BorderColor, Transparency = 0.2 }):Play()
        end)
        card.MouseButton1Click:Connect(function()
            CommandPalette.OpenEditor(nil)
        end)
        return card
    end

    local function makeScriptCard(script, layoutOrder)
        local card = New("TextButton", {
            BackgroundColor3 = "BackgroundColor",
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = layoutOrder,
            Parent = cardGrid,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 18), Parent = card })
        local stroke = New("UIStroke", { Color = "BorderColor", Thickness = 1, Transparency = 0.4, Parent = card })

        New("UIPadding", {
            PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
            PaddingTop  = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10),
            Parent = card,
        })

        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            Text = script.name ~= "" and script.name or "Untitled",
            TextSize = Tokens.FontSize.LG,
            FontFace = "FontBold",
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = card,
        })
        New("TextLabel", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 16),
            Text = "▶ Run",
            TextSize = Tokens.FontSize.SM,
            TextColor3 = "AccentColor",
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = card,
        })

        -- small edit/delete affordance in the corner
        local editBtn = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.fromOffset(20, 20),
            Text = "⋯",
            TextSize = 18,
            TextColor3 = "TextMuted",
            ZIndex = 2,
            Parent = card,
        })

        card.MouseEnter:Connect(function()
            TweenService:Create(stroke, TweenInfo.new(0.12), { Transparency = 0, Color = ThemeEngine.CurrentScheme.AccentColor }):Play()
            TweenService:Create(card, TweenInfo.new(0.12), { BackgroundColor3 = ThemeEngine.CurrentScheme.SurfaceAltColor }):Play()
        end)
        card.MouseLeave:Connect(function()
            TweenService:Create(stroke, TweenInfo.new(0.12), { Transparency = 0.4, Color = ThemeEngine.CurrentScheme.BorderColor }):Play()
            TweenService:Create(card, TweenInfo.new(0.12), { BackgroundColor3 = ThemeEngine.CurrentScheme.BackgroundColor }):Play()
        end)
        card.MouseButton1Click:Connect(function()
            CommandPalette.RunScript(script.id)
        end)
        editBtn.MouseButton1Click:Connect(function()
            CommandPalette.OpenEditor(script.id)
        end)

        return card
    end

    local function renderQuickActions(list)
        clearChildren(quickList)
        quickList.Visible = #list > 0
        for i, qa in ipairs(list) do
            local row = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Text = "",
                LayoutOrder = i,
                Parent = quickList,
            })
            New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = row })
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.6, 0, 1, 0),
                Position = UDim2.fromOffset(8, 0),
                Text = qa.name,
                TextSize = Tokens.FontSize.SM,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })
            New("TextLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.new(0.35, 0, 1, 0),
                Text = qa.category or "",
                TextSize = Tokens.FontSize.XS,
                TextColor3 = "TextMuted",
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = row,
            })
            row.MouseEnter:Connect(function()
                row.BackgroundTransparency = 0.5
                row.BackgroundColor3 = ThemeEngine.CurrentScheme.SurfaceAltColor
            end)
            row.MouseLeave:Connect(function() row.BackgroundTransparency = 1 end)
            row.MouseButton1Click:Connect(function()
                pcall(qa.action)
                CommandPalette.Close()
            end)
        end
    end

    function CommandPalette.Refresh()
        clearChildren(cardGrid) -- UIGridLayout (gridLayout) survives this, it's excluded by IsA("UILayout")

        local filteredScripts = {}
        local filteredActions  = {}

        if query == "" then
            filteredScripts = scripts
            -- only surface quick actions when not searching and there are few/no scripts,
            -- so the hub doesn't get cluttered once someone has a real script library
            if #scripts == 0 then filteredActions = quickActions end
        else
            local scored = {}
            for _, s in ipairs(scripts) do
                local sc = fuzzyScore(query, s.name)
                if sc >= 0 then table.insert(scored, { item = s, score = sc }) end
            end
            table.sort(scored, function(a, b) return a.score > b.score end)
            for _, e in ipairs(scored) do table.insert(filteredScripts, e.item) end

            local scoredA = {}
            for _, a in ipairs(quickActions) do
                local sc = fuzzyScore(query, a.name)
                if sc >= 0 then table.insert(scoredA, { item = a, score = sc }) end
            end
            table.sort(scoredA, function(a, b) return a.score > b.score end)
            for _, e in ipairs(scoredA) do table.insert(filteredActions, e.item) end
        end

        makeAddCard(1)
        for i, s in ipairs(filteredScripts) do
            makeScriptCard(s, i + 1)
        end

        renderQuickActions(filteredActions)

        if #scripts == 0 and query == "" then
            emptyLabel.Text = "No scripts yet — click \"+ Add Script\" to create one."
            emptyLabel.Visible = true
        elseif query ~= "" and #filteredScripts == 0 and #filteredActions == 0 then
            emptyLabel.Text = "No matches for \"" .. query .. "\"."
            emptyLabel.Visible = true
        else
            emptyLabel.Visible = false
        end
        countLabel.Text = #scripts .. (#scripts == 1 and " script" or " scripts")
    end

    -- ── Editor dialog (Add / Edit script) ──
    local editorDismiss = nil  -- set while the Add/Edit dialog is open, so Escape closes it first

    function CommandPalette.OpenEditor(scriptId)
        local editing = nil
        if scriptId then
            for _, s in ipairs(scripts) do
                if s.id == scriptId then editing = s break end
            end
        end

        local overlay = New("TextButton", {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            AutoButtonColor = false,
            Parent = dimOverlay, -- sits above the hub frame, both inside the same dim overlay
        })
        ZManager.Apply(overlay, "modal", 2)
        TweenService:Create(overlay, TweenInfo.new(0.12), { BackgroundTransparency = 0.4 }):Play()

        local box = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "SurfaceColor",
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(420, 360),
            Active = true, -- blocks clicks from falling through to the overlay's
                            -- click-outside-to-dismiss handler when clicking on
                            -- blank areas of the dialog (title/hint text, padding)
            Parent = overlay,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 16), Parent = box })
        New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = box })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 18),
            PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 16),
            Parent = box,
        })
        New("UIListLayout", { Padding = UDim.new(0, 10), Parent = box })

        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            Text = editing and "Edit Script" or "Add Script",
            TextSize = Tokens.FontSize.H3,
            FontFace = "FontBold",
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
            Parent = box,
        })

        local nameRow = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = UDim2.new(1, 0, 0, 34),
            LayoutOrder = 2,
            Parent = box,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = nameRow })
        New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = nameRow })
        New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = nameRow })
        local nameBox = New("TextBox", {
            BackgroundTransparency = 1,
            ClearTextOnFocus = false,
            PlaceholderText = "Script name…",
            Text = editing and editing.name or "",
            Size = UDim2.new(1, 0, 1, 0),
            TextSize = Tokens.FontSize.MD,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = nameRow,
        })

        local codeRow = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = UDim2.new(1, 0, 0, 170),
            LayoutOrder = 3,
            Parent = box,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = codeRow })
        New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = codeRow })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
            Parent = codeRow,
        })
        local codeScroll = New("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = codeRow,
        })
        local codeBox = New("TextBox", {
            BackgroundTransparency = 1,
            ClearTextOnFocus = false,
            MultiLine = true,
            PlaceholderText = 'loadstring(game:HttpGet("https://..."))()',
            Text = editing and editing.code or "",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            TextSize = Tokens.FontSize.SM,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            FontFace = Font.fromEnum(Enum.Font.Code),
            Parent = codeScroll,
        })

        local hint = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = "Paste a loadstring or any Lua snippet — it runs when you click the card.",
            TextSize = Tokens.FontSize.XS,
            TextColor3 = "TextMuted",
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 4,
            Parent = box,
        })

        local btnRow = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            LayoutOrder = 5,
            Parent = box,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 8),
            Parent = btnRow,
        })

        local function dismiss()
            editorDismiss = nil
            TweenService:Create(overlay, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
            task.delay(0.12, function() if overlay and overlay.Parent then overlay:Destroy() end end)
        end
        editorDismiss = dismiss
        overlay.MouseButton1Click:Connect(dismiss)

        if editing then
            local delBtn = New("TextButton", {
                BackgroundColor3 = "DangerColor",
                Size = UDim2.fromOffset(0, 28),
                AutomaticSize = Enum.AutomaticSize.X,
                Text = "",
                Parent = btnRow,
            })
            New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = delBtn })
            New("UIPadding", { PaddingLeft = UDim.new(0,14), PaddingRight = UDim.new(0,14), Parent = delBtn })
            New("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.fromScale(1,1),
                Text = "Delete", TextSize = Tokens.FontSize.MD, TextColor3 = Color3.new(1,1,1),
                Parent = delBtn,
            })
            delBtn.MouseButton1Click:Connect(function()
                for i, s in ipairs(scripts) do
                    if s.id == editing.id then table.remove(scripts, i) break end
                end
                saveScripts()
                CommandPalette.Refresh()
                dismiss()
            end)
        end

        local cancelBtn = New("TextButton", {
            BackgroundColor3 = "SurfaceAltColor",
            Size = UDim2.fromOffset(0, 28),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = "",
            Parent = btnRow,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = cancelBtn })
        New("UIPadding", { PaddingLeft = UDim.new(0,14), PaddingRight = UDim.new(0,14), Parent = cancelBtn })
        New("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.fromScale(1,1),
            Text = "Cancel", TextSize = Tokens.FontSize.MD, Parent = cancelBtn,
        })
        cancelBtn.MouseButton1Click:Connect(dismiss)

        local saveBtn = New("TextButton", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromOffset(0, 28),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = "",
            Parent = btnRow,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = saveBtn })
        New("UIPadding", { PaddingLeft = UDim.new(0,14), PaddingRight = UDim.new(0,14), Parent = saveBtn })
        New("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.fromScale(1,1),
            Text = "Save", TextSize = Tokens.FontSize.MD, TextColor3 = Color3.new(1,1,1),
            Parent = saveBtn,
        })
        saveBtn.MouseButton1Click:Connect(function()
            local name = nameBox.Text ~= "" and nameBox.Text or "Untitled"
            local code = codeBox.Text
            if editing then
                editing.name = name
                editing.code = code
            else
                scriptIdCounter += 1
                table.insert(scripts, { id = scriptIdCounter, name = name, code = code })
            end
            saveScripts()
            CommandPalette.Refresh()
            dismiss()
        end)
    end

    function CommandPalette.RunScript(scriptId)
        local target = nil
        for _, s in ipairs(scripts) do
            if s.id == scriptId then target = s break end
        end
        if not target then return end
        if not loadstring then
            if Library then Library:Notify("This executor doesn't support loadstring.", "error") end
            return
        end
        local fn, err = loadstring(target.code)
        if not fn then
            if Library then Library:Notify("Script error: " .. tostring(err), "error", 5) end
            return
        end
        local ok, runErr = pcall(fn)
        if not ok then
            if Library then Library:Notify("Runtime error: " .. tostring(runErr), "error", 5) end
        else
            if Library then Library:Notify("Ran \"" .. target.name .. "\"", "success", 2) end
        end
        CommandPalette.Close()
    end

    -- ── Register: old API, now feeds the slim Quick Actions list instead of cards ──
    function CommandPalette.Register(cmd)
        table.insert(quickActions, cmd)
    end

    -- ── Preload scripts from your own setup code, e.g.:
    --      Library.Commands.AddScript("Auto Farm", 'loadstring(game:HttpGet("..."))()')
    --   Safe to call every time your script runs: matches by name, so it
    --   updates the code if the name already exists instead of duplicating
    --   the card. Works whether the hub has been opened yet or not.
    function CommandPalette.AddScript(name, code)
        ensureScriptsLoaded()
        name = name ~= "" and name or "Untitled"
        for _, s in ipairs(scripts) do
            if s.name == name then
                s.code = code
                saveScripts()
                if frame and frame.Visible then CommandPalette.Refresh() end
                return s
            end
        end
        scriptIdCounter += 1
        local entry = { id = scriptIdCounter, name = name, code = code }
        table.insert(scripts, entry)
        saveScripts()
        if frame and frame.Visible then CommandPalette.Refresh() end
        return entry
    end

    -- bulk version: Library.Commands.AddScripts({ { Name = "..", Code = ".." }, ... })
    function CommandPalette.AddScripts(list)
        for _, entry in ipairs(list) do
            CommandPalette.AddScript(entry.Name or entry.name, entry.Code or entry.code)
        end
    end

    -- kept for API compatibility; Refresh() does what Search() used to do
    function CommandPalette.Search(q)
        query = q or ""
        inputBox.Text = query
        CommandPalette.Refresh()
    end

    function CommandPalette.Execute(cmd)
        if cmd and cmd.action then pcall(cmd.action) end
    end

    -- ── Open / Close (generation-token guarded to fix the reopen flicker) ──
    function CommandPalette.Open()
        if visible then return end
        visible = true
        openGen += 1
        ensureScriptsLoaded()

        -- minimize the main window if it's open, and remember to restore it.
        -- (Window itself is a local scoped inside Library:CreateWindow, not
        -- reachable from here — Library:Toggle is the public wrapper for it.)
        wasWindowOpen = Library and Library.Toggled or false
        if wasWindowOpen and Library then
            Library:Toggle(false)
        end

        dimOverlay.Visible = true
        frame.Visible = true
        query = ""
        inputBox.Text = ""
        CommandPalette.Refresh()
        inputBox:CaptureFocus()

        frameScale.Scale = 0.94
        dimOverlay.BackgroundTransparency = 1
        TweenService:Create(blurEffect, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { Size = 24 }):Play()
        TweenService:Create(dimOverlay, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { BackgroundTransparency = 0.45 }):Play()
        TweenService:Create(frameScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

        InteractionManager.Push("scripthub", CommandPalette.Close)
    end

    function CommandPalette.Close()
        if not visible then return end
        visible = false
        openGen += 1
        local myGen = openGen  -- any in-flight delayed callback from a PRIOR open/close is now stale

        if editorDismiss then editorDismiss() end

        TweenService:Create(frameScale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.94 }):Play()
        TweenService:Create(dimOverlay, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(blurEffect, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = 0 }):Play()

        task.delay(0.14, function()
            -- only the close that scheduled this delay is allowed to hide things;
            -- if Open() was called again in the meantime, openGen has moved on
            -- and this stale callback must do nothing (this is what fixed the
            -- "opens for half a second then disappears" bug)
            if openGen ~= myGen then return end
            dimOverlay.Visible = false
            frame.Visible = false
        end)

        if wasWindowOpen and Library then
            Library:Toggle(true)
        end
    end

    function CommandPalette.Toggle()
        if visible then CommandPalette.Close() else CommandPalette.Open() end
    end

    -- Ctrl+Shift+P hotkey (unchanged), Escape closes the editor dialog first
    -- if it's open, otherwise the whole hub
    LibraryMaid:Connect(UserInputService.InputBegan, function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.P
            and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
            and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            CommandPalette.Toggle()
        end
        if input.KeyCode == Enum.KeyCode.Escape then
            if editorDismiss then
                editorDismiss()
            elseif visible then
                CommandPalette.Close()
            end
        end
    end)
end

-- ─── Context Menu ──────────────────────────────────────────────────────────
local ContextMenu = {}
do
    local currentMenu = nil
    local menuMaid    = Maid.New()

    function ContextMenu.Show(items, position, options)
        --[[
            items = {
                { Label = "Copy",  Icon = "copy",  Action = fn },
                { Label = "Paste", Disabled = true },
                { Separator = true },
            }
            position = UDim2 or Vector2
            options.Parent = Instance (optional, defaults to ScreenGui)
        ]]
        ContextMenu.Close()
        options = options or {}
        local parent = options.Parent or ScreenGui

        local overlay = New("TextButton", {
            BackgroundTransparency = 1,
            Size   = UDim2.fromScale(1, 1),
            Text   = "",
            ZIndex = ZManager.Get("dropdown"),
            Parent = ScreenGui,
        })

        local menu = New("Frame", {
            BackgroundColor3 = "SurfaceColor",
            Position         = typeof(position) == "Vector2"
                                and UDim2.fromOffset(position.X, position.Y)
                                or position,
            Size    = UDim2.fromOffset(180, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex  = ZManager.Get("dropdown") + 1,
            Parent  = overlay,
        })
        New("UICorner",  { CornerRadius = UDim.new(0, Tokens.RadiusMD), Parent = menu })
        New("UIStroke",  { Color = "BorderColor", Thickness = 1, Parent = menu })
        New("UIPadding", {
            PaddingTop    = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
            PaddingLeft   = UDim.new(0, 4),
            PaddingRight  = UDim.new(0, 4),
            Parent = menu,
        })
        New("UIListLayout", { Padding = UDim.new(0, 2), Parent = menu })

        -- Spring in
        local scaleInst = Instance.new("UIScale")
        scaleInst.Scale = 0.92
        scaleInst.Parent = menu
        TweenService:Create(scaleInst,
            TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Scale = 1 }):Play()
        task.delay(0.18, function()
            if scaleInst and scaleInst.Parent then scaleInst:Destroy() end
        end)

        for i, item in ipairs(items) do
            if item.Separator then
                New("Frame", {
                    BackgroundColor3 = "BorderColor",
                    Size   = UDim2.new(1, -8, 0, 1),
                    LayoutOrder = i,
                    Parent = menu,
                })
            else
                local btn = New("TextButton", {
                    BackgroundColor3 = "SurfaceColor",
                    BackgroundTransparency = 1,
                    Size    = UDim2.new(1, 0, 0, 28),
                    Text    = "",
                    LayoutOrder = i,
                    Parent  = menu,
                })
                New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = btn })
                New("UIPadding", {
                    PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
                    Parent = btn,
                })
                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.fromScale(1, 1),
                    Text     = item.Label or "",
                    TextSize = Tokens.FontSize.MD,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextColor3     = item.Disabled and "TextDisabled" or "TextPrimary",
                    Parent   = btn,
                })

                if not item.Disabled then
                    btn.MouseEnter:Connect(function()
                        btn.BackgroundTransparency = 0
                        btn.BackgroundColor3 = ThemeEngine.CurrentScheme.SurfaceAltColor
                    end)
                    btn.MouseLeave:Connect(function()
                        btn.BackgroundTransparency = 1
                    end)
                    btn.MouseButton1Click:Connect(function()
                        ContextMenu.Close()
                        if item.Action then pcall(item.Action) end
                    end)
                end
            end
        end

        overlay.MouseButton1Click:Connect(ContextMenu.Close)
        currentMenu = { overlay = overlay, menu = menu }
        InteractionManager.Push("contextmenu", ContextMenu.Close)

        return menu
    end

    function ContextMenu.Close()
        if not currentMenu then return end
        local menu    = currentMenu.menu
        local overlay = currentMenu.overlay
        currentMenu   = nil
        if menu and menu.Parent then
            TweenService:Create(menu,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { BackgroundTransparency = 1 }):Play()
        end
        task.delay(0.12, function()
            if overlay and overlay.Parent then overlay:Destroy() end
        end)
    end
end

-- ─── Loading Screen ────────────────────────────────────────────────────────
local LoadingScreen = {}
do
    function LoadingScreen.Create(options)
        options = options or {}
        local title      = options.Title or "Loading…"
        local steps      = options.Steps or 10
        local currentStep= 0

        local gui = New("ScreenGui", {
            Name            = "NexusUI_Loading",
            DisplayOrder    = 1000,
            ResetOnSpawn    = false,
            IgnoreGuiInset  = true,
        })
        pcall(protectgui, gui)
        local ok2 = pcall(function() gui.Parent = gethui() end)
        if not ok2 then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

        local bg = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.fromScale(0.5, 0.5),
            Size     = UDim2.fromOffset(420, 260),
            Parent   = gui,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusLG), Parent = bg })
        New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = bg })

        New("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 30),
            Size     = UDim2.new(1, -40, 0, 28),
            Text     = title,
            TextSize = Tokens.FontSize.H2,
            FontFace = Font.fromEnum(Enum.Font.Gotham),
            Parent   = bg,
        })

        local statusLabel = New("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 62),
            Size     = UDim2.new(1, -40, 0, 18),
            Text     = "Initializing…",
            TextSize = Tokens.FontSize.SM,
            TextColor3 = "TextMuted",
            Parent   = bg,
        })

        -- Progress bar track
        local track = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = "SurfaceColor",
            Position = UDim2.new(0.5, 0, 0, 100),
            Size     = UDim2.new(1, -40, 0, 6),
            Parent   = bg,
        })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

        local fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0, 1),
            Parent = track,
        })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

        local progressLabel = New("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 116),
            Size     = UDim2.new(1, -40, 0, 16),
            Text     = "0/" .. steps,
            TextSize = Tokens.FontSize.SM,
            TextColor3 = "TextMuted",
            Parent   = bg,
        })

        local Loading = {
            Gui          = gui,
            CurrentStep  = 0,
            TotalSteps   = steps,
        }

        function Loading:SetStatus(text)
            statusLabel.Text = text
        end

        function Loading:SetStep(n, statusText)
            currentStep = math.clamp(n, 0, self.TotalSteps)
            self.CurrentStep = currentStep
            local frac = currentStep / self.TotalSteps
            TweenService:Create(fill,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.fromScale(frac, 1) }):Play()
            progressLabel.Text = currentStep .. "/" .. self.TotalSteps
            if statusText then self:SetStatus(statusText) end
        end

        function Loading:Advance(statusText)
            self:SetStep(self.CurrentStep + 1, statusText)
        end

        function Loading:Destroy()
            TweenService:Create(bg,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { BackgroundTransparency = 1 }):Play()
            task.delay(0.28, function() gui:Destroy() end)
        end

        Loading.Continue = Loading.Destroy

        return Loading
    end
end

-- ─── Debug Overlay / UI Inspector ─────────────────────────────────────────
local DebugOverlay = {}
do
    local overlayVisible = false
    local overlayFrame

    function DebugOverlay.Build()
        if overlayFrame then return end

        overlayFrame = New("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = Color3.new(0,0,0),
            BackgroundTransparency = 0.25,
            Position = UDim2.new(1, -8, 1, -8),
            Size     = UDim2.fromOffset(260, 200),
            Visible  = false,
            Parent   = ScreenGui,
        })
        ZManager.Apply(overlayFrame, "debug")
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusMD), Parent = overlayFrame })
        New("UIStroke", { Color = Color3.fromRGB(60,60,60), Thickness = 1, Parent = overlayFrame })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
            PaddingTop  = UDim.new(0, 6), PaddingBottom= UDim.new(0, 6),
            Parent = overlayFrame,
        })

        local list = New("UIListLayout", { Padding = UDim.new(0, 3), Parent = overlayFrame })
        local labels = {}

        local keys = {
            "FPS", "AnimBudget(ms)", "SpringCount", "PoolStats",
            "RegCount", "Theme", "Version",
        }
        for _, k in ipairs(keys) do
            local row = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Parent = overlayFrame,
            })
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.45, 1),
                Text = k .. ":",
                TextSize = 11,
                TextColor3 = Color3.fromRGB(150,150,150),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })
            local val = New("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(1, 0),
                Size  = UDim2.fromScale(0.54, 1),
                Text  = "–",
                TextSize = 11,
                TextColor3 = Color3.new(1,1,1),
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = row,
            })
            labels[k] = val
        end

        -- Update loop
        local updateConn
        updateConn = RunService.Heartbeat:Connect(function()
            if not overlayVisible then return end
            local fps    = AnimEngine.GetFPS()
            local budget = AnimEngine.GetBudget()  -- already in ms
            local poolS  = ObjectPool.Stats()
            local poolStr = ""
            for k, v in pairs(poolS) do
                poolStr = poolStr .. k:sub(1,3) .. ":" .. v.free .. " "
            end
            local regCount = 0
            for _ in pairs(Registry) do regCount += 1 end

            pcall(function()
                labels["FPS"].Text         = string.format("%.0f", fps)
                labels["FPS"].TextColor3   = fps < 25 and Color3.fromRGB(255,80,80)
                                          or fps < 45 and Color3.fromRGB(255,200,50)
                                          or Color3.fromRGB(80,220,80)
                labels["AnimBudget(ms)"].Text = string.format("%.3f", budget)
                labels["SpringCount"].Text    = tostring(AnimEngine.GetActiveCount())
                labels["PoolStats"].Text      = poolStr ~= "" and poolStr or "empty"
                labels["RegCount"].Text       = tostring(regCount)
                labels["Theme"].Text          = ThemeEngine.ActiveThemeName
                labels["Version"].Text        = LIBRARY_VERSION
            end)
        end)
        LibraryMaid:Give(updateConn)
    end

    function DebugOverlay.Toggle()
        if not overlayFrame then DebugOverlay.Build() end
        overlayVisible = not overlayVisible
        overlayFrame.Visible = overlayVisible
    end

    function DebugOverlay.Show() 
        if not overlayFrame then DebugOverlay.Build() end
        overlayVisible = true
        overlayFrame.Visible = true
    end

    function DebugOverlay.Hide()
        overlayVisible = false
        if overlayFrame then overlayFrame.Visible = false end
    end

    function DebugOverlay.IsVisible()
        return overlayVisible
    end
end

-- ─── Main Library Object ───────────────────────────────────────────────────
Library = {
    Version         = LIBRARY_VERSION,
    ScreenGui       = ScreenGui,
    LocalPlayer     = LocalPlayer,

    -- Public subsystems
    Anim            = AnimEngine,
    Spring          = SpringSolver,
    Theme           = ThemeEngine,
    Reactive        = Reactive,
    Events          = EventBus,
    Commands        = CommandPalette,
    Context         = ContextMenu,
    Toast           = ToastSystem,
    Profiler        = Profiler,
    Plugins         = PluginSystem,
    Async           = AsyncTask,
    Undo            = UndoManager,
    Nav             = NavHistory,
    Debug           = DebugOverlay,
    Focus           = FocusManager,
    Tokens          = Tokens,
    VirtualList     = VirtualList,
    Micro           = Micro,

    -- State
    Toggled         = false,
    Unloaded        = false,
    IsMobile        = false,
    IsRobloxFocused = true,
    DPIScale        = 1,
    ElementTransparency = 0,
    Scheme          = ThemeEngine.CurrentScheme,

    -- Collections
    Toggles         = {},
    Options         = {},
    Labels          = {},
    Buttons         = {},
    Tabs            = {},
    ActiveTab       = nil,

    -- Settings
    ToggleKeybind    = Enum.KeyCode.RightControl,
    ShowCustomCursor = true,
}

-- Mobile detection
do
    local ok2, platform = pcall(function()
        return UserInputService:GetPlatform()
    end)
    if ok2 then
        Library.IsMobile = (platform == Enum.Platform.Android or platform == Enum.Platform.IOS)
    elseif RunService:IsStudio() then
        Library.IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
    end
end

-- Roblox focus tracking
LibraryMaid:Connect(UserInputService.WindowFocused,  function() Library.IsRobloxFocused = true  end)
LibraryMaid:Connect(UserInputService.WindowFocusReleased, function() Library.IsRobloxFocused = false end)

-- ── Theme Management ──────────────────────────────────────────────────────

-- Tracks the Rainbow cycling connection so it can be stopped when switching away
local _rainbowConn = nil
local _rainbowHue  = 0

function Library:SetTheme(name, customThemeData, animated)
    -- Stop any existing rainbow cycle
    if _rainbowConn then
        _rainbowConn:Disconnect()
        _rainbowConn = nil
    end

    -- Rainbow: cycle accent hue every frame instead of using a fixed color
    if name == "Rainbow" and not customThemeData then
        ThemeEngine.ActiveThemeName = "Rainbow"
        _rainbowConn = RunService.Heartbeat:Connect(function(dt)
            _rainbowHue = (_rainbowHue + dt * 0.12) % 1  -- full cycle ~8s
            local accentColor = Color3.fromHSV(_rainbowHue, 0.85, 1)
            -- Build theme on Dark neutral base with cycling accent
            local baseTheme = ThemeEngine.BuiltinThemes.Dark
            local rainbowTheme = {}
            for k, v in pairs(baseTheme) do rainbowTheme[k] = v end
            rainbowTheme.Accent = accentColor
            local scheme = ThemeEngine:Build(rainbowTheme)
            ThemeEngine.CurrentScheme = scheme
            Library.Scheme = scheme
            UpdateRegistry()
        end)
        LibraryMaid:Give(_rainbowConn)
        return
    end

    local themeData = customThemeData or ThemeEngine.BuiltinThemes[name]
    if not themeData then
        warn("NexusUI: Unknown theme:", name)
        return
    end

    local toScheme = ThemeEngine:Build(themeData)

    if animated then
        local fromScheme = ThemeEngine.CurrentScheme
        local STEPS      = 24
        local step       = 0
        local conn
        conn = RunService.Heartbeat:Connect(function()
            step += 1
            local t = step / STEPS
            if t >= 1 then
                conn:Disconnect()
                ThemeEngine.CurrentScheme = toScheme
                Library.Scheme = toScheme
                UpdateRegistry()
                ThemeEngine.ActiveThemeName = name or "Custom"
                PluginSystem.Emit("onThemeChange", Library.Scheme)
                EventBus:Emit("themeChange", Library.Scheme)
                return
            end
            -- Interpolate and push to all registered instances
            local interp = ThemeEngine:Interpolate(fromScheme, toScheme, t)
            ThemeEngine.CurrentScheme = interp
            Library.Scheme = interp
            UpdateRegistry()
            EventBus:Emit("themeChange", Library.Scheme)
        end)
        LibraryMaid:Give(conn)
    else
        ThemeEngine.CurrentScheme = toScheme
        Library.Scheme = toScheme
        UpdateRegistry()
        ThemeEngine.ActiveThemeName = name or "Custom"
        PluginSystem.Emit("onThemeChange", Library.Scheme)
        EventBus:Emit("themeChange", Library.Scheme)
    end
end

function Library:SetAccentColor(color, animated)
    local currentTheme = ThemeEngine.BuiltinThemes[ThemeEngine.ActiveThemeName]
                      or ThemeEngine.BuiltinThemes.Dark
    local newTheme = {}
    for k, v in pairs(currentTheme) do newTheme[k] = v end
    newTheme.Accent = color
    Library:SetTheme(nil, newTheme, animated)
end

function Library:ToggleLightMode(animated)
    local cur = ThemeEngine.ActiveThemeName
    if cur == "Light" then
        Library:SetTheme("Dark", nil, animated)
    else
        Library:SetTheme("Light", nil, animated)
    end
end

-- ── DPI Scaling ───────────────────────────────────────────────────────────
function Library:SetDPIScale(scale)
    Library.DPIScale = scale / 100
    EventBus:Emit("dpiChange", Library.DPIScale)
end

-- ── Utility Helpers ───────────────────────────────────────────────────────

function Library:SafeCallback(fn, ...)
    if typeof(fn) ~= "function" then return end
    -- NOTE: this used to also no-op while Library._loadingConfig was true,
    -- which silently dropped EVERY Toggle/Slider/Dropdown/ColorPicker/KeyPicker
    -- callback during config restore (startup autoload + manual Load Config).
    -- That's wrong — restoring a config is exactly when those callbacks need
    -- to run (e.g. Callback = function(value) testEnabled = value end), since
    -- that's what actually applies the saved value to the script. Visual
    -- elements update via :SetValue regardless, but nothing else happens
    -- unless the callback fires. _loadingConfig is still used elsewhere
    -- (UndoManager) to avoid polluting undo history during a restore — that's
    -- fine, it should NOT also suppress callbacks.
    local ok2, err = xpcall(fn, debug.traceback, ...)
    if not ok2 then
        task.defer(error, err)
        if self.NotifyOnError then
            ToastSystem.Error(tostring(err):sub(1, 80))
        end
    end
end

function Library:GetTextBounds(text, font, size, width)
    local params = Instance.new("GetTextBoundsParams")
    params.Text     = text
    params.RichText = true
    params.Font     = font or Library.Scheme.Font
    params.Size     = size or Tokens.FontSize.MD
    params.Width    = width or Camera.ViewportSize.X
    local bounds = TextService:GetTextBoundsAsync(params)
    return bounds.X, bounds.Y
end

function Library:MouseIsOver(frame)
    local pos  = frame.AbsolutePosition
    local size = frame.AbsoluteSize
    local mx   = Mouse.X
    local my   = Mouse.Y
    return mx >= pos.X and mx <= pos.X + size.X
       and my >= pos.Y and my <= pos.Y + size.Y
end

function Library:MakeDraggable(window, dragHandle, maid, onStart)
    local dragging = false
    local dragStart = Vector2.zero
    local windowStartPos = UDim2.new()
    local currentTween = nil

    local function cancelTween()
        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end
    end

    local function animateToPosition(x, y)
        cancelTween()
        currentTween = TweenService:Create(window, 
            TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Position = UDim2.new(windowStartPos.X.Scale, x, windowStartPos.Y.Scale, y) }
        )
        currentTween:Play()
        currentTween.Completed:Connect(function()
            currentTween = nil
        end)
    end

    maid:Connect(dragHandle.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if onStart then pcall(onStart) end
        dragging = true
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        windowStartPos = window.Position
        cancelTween()
    end)

    maid:Connect(UserInputService.InputChanged, function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        
        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
        local newX = windowStartPos.X.Offset + delta.X
        local newY = windowStartPos.Y.Offset + delta.Y

        -- Smooth follow
        animateToPosition(newX, newY)
    end)

    maid:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function Library:MakeResizable(window, resizeHandle, maid, minSize, onResize, onStart)
    -- minSize may be a Vector2 or a function() returning Vector2 (for DPI-aware min)
    local function getMin()
        if type(minSize) == "function" then return minSize() end
        return minSize or Vector2.new(400, 300)
    end
    local dragging = false
    local startMouse, startSize

    maid:Connect(resizeHandle.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if onStart then pcall(onStart) end
        dragging   = true
        startMouse = input.Position
        startSize  = window.Size
    end)

    maid:Connect(UserInputService.InputChanged, function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local delta = input.Position - startMouse
        local mn = getMin()
        window.Size = UDim2.new(
            startSize.X.Scale,
            math.max(mn.X, startSize.X.Offset + delta.X),
            startSize.Y.Scale,
            math.max(mn.Y, startSize.Y.Offset + delta.Y)
        )
        if onResize then pcall(onResize, window.Size) end
    end)

    maid:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Custom cursor removed

-- ─── Validate / Merge with Defaults ────────────────────────────────────────
function Library:Validate(info, defaults)
    if typeof(info) == "string" then
        info = { Text = info }
    end
    info = info or {}
    local out = {}
    for k, v in pairs(defaults) do
        out[k] = (info[k] ~= nil) and info[k] or
                 (typeof(v) == "function" and v() or v)
    end
    for k, v in pairs(info) do
        if out[k] == nil then out[k] = v end
    end
    return out
end

-- ─── Component Base (lifecycle + addons) ───────────────────────────────────
local ComponentBase = {}
ComponentBase.__index = ComponentBase

function ComponentBase:OnMount(fn)
    if fn then pcall(fn, self) end
    return self
end

function ComponentBase:OnDestroy(fn)
    self._destroyCbs = self._destroyCbs or {}
    table.insert(self._destroyCbs, fn)
    return self
end

function ComponentBase:Destroy()
    if self._destroyCbs then
        for _, fn in ipairs(self._destroyCbs) do pcall(fn) end
    end
    if self._maid then self._maid:Destroy() end
end

function ComponentBase:Animate(property, targetValue, params)
    params = params or {}
    local element = self.Instance or self.Holder or self.Base
    if not element then return end
    local current = element[property]
    if current == nil then return end
    local dur = params and params.duration or 0.18
    TweenService:Create(element,
        TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { [property] = targetValue }):Play()
end

-- ─── Groupbox / Container (BaseGroupbox) ───────────────────────────────────
local BaseGroupbox = {}
BaseGroupbox.__index = BaseGroupbox

function BaseGroupbox:AddDivider(info)
    info = info or {}
    local holder = New("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 0, info.Padding or 14),
        Parent = self.Container,
    })

    if info.Text then
        -- Label centred; two line frames stop 10 px short of the text on each side
        local lbl = New("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position   = UDim2.fromScale(0.5, 0.5),
            Size       = UDim2.new(1, -20, 1, 0),
            Text       = info.Text,
            TextSize   = Tokens.FontSize.SM,
            TextColor3 = "TextMuted",
            ZIndex     = holder.ZIndex + 1,
            Parent     = holder,
        })
        -- Left line: from left edge up to 10 px before the text
        New("Frame", {
            AnchorPoint      = Vector2.new(0, 0.5),
            BackgroundColor3 = "BorderColor",
            Position         = UDim2.fromOffset(0, 0),  -- vertically centred via AnchorPoint
            Size             = UDim2.new(0.5, -10 - (lbl.TextBounds.X / 2), 0, 1),
            Parent           = holder,
        })
        -- Right line: from 10 px after the text to right edge
        New("Frame", {
            AnchorPoint      = Vector2.new(1, 0.5),
            BackgroundColor3 = "BorderColor",
            Position         = UDim2.new(1, 0, 0.5, 0),
            Size             = UDim2.new(0.5, -10 - (lbl.TextBounds.X / 2), 0, 1),
            Parent           = holder,
        })
        -- Use AbsoluteSize-aware sizing once the label has rendered
        task.defer(function()
            if not lbl or not lbl.Parent then return end
            local halfText = lbl.TextBounds.X / 2 + 10
            local halfWidth = holder.AbsoluteSize.X / 2
            local lineW = math.max(0, halfWidth - halfText)
            for _, child in ipairs(holder:GetChildren()) do
                if child:IsA("Frame") then
                    child.Size = UDim2.fromOffset(lineW, 1)
                end
            end
        end)
    else
        -- Plain line, full width, vertically centred
        New("Frame", {
            AnchorPoint      = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "BorderColor",
            Position         = UDim2.fromScale(0.5, 0.5),
            Size             = UDim2.new(1, 0, 0, 1),
            Parent           = holder,
        })
    end

    local div = { Type = "Divider", Holder = holder, Visible = true }
    table.insert(self.Elements, div)
    self:Resize()
    return div
end

function BaseGroupbox:AddLabel(idx, info)
    info = Library:Validate(info, {
        Text     = "Label",
        Readable = false,
        Visible  = true,
    })

    local holder = New("TextLabel", {
        BackgroundTransparency = 1,
        Size      = UDim2.new(1, 0, 0, Tokens.FontSize.MD + 4),
        Text      = info.Text,
        TextSize  = Tokens.FontSize.MD,
        TextColor3= "TextSecondary",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped    = true,
        Visible   = info.Visible,
        Parent    = self.Container,
    })

    local label = {
        Text    = info.Text,
        Visible = info.Visible,
        Type    = "Label",
        Holder  = holder,
    }

    function label:SetText(text)
        label.Text  = text
        holder.Text = text
        self._groupbox:Resize()
    end

    function label:SetVisible(v)
        label.Visible = v
        holder.Visible = v
        self._groupbox:Resize()
    end

    label._groupbox = self
    if idx then Library.Labels[idx] = label end
    table.insert(self.Elements, label)
    self:Resize()
    return label
end

function BaseGroupbox:AddToggle(idx, info)
    info = Library:Validate(info, {
        Text     = "Toggle",
        Default  = false,
        Callback = function() end,
        Changed  = function() end,
        Risky    = false,
        Disabled = false,
        Visible  = true,
        Tooltip  = nil,
    })

    local container = self.Container
    local maid      = Maid.New()

    local holder = New("TextButton", {
        Active                = not info.Disabled,
        BackgroundTransparency= 1,
        Size                  = UDim2.new(1, 0, 0, 20),
        Text                  = "",
        Visible               = info.Visible,
        Parent                = container,
    })

    local label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, -46, 1, 0),
        Text   = info.Text,
        TextSize = Tokens.FontSize.MD,
        TextColor3 = info.Risky and "DangerColor" or "TextPrimary",
        TextTransparency = 0.4,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent = holder,
    })

    -- Switch track — wider for easier clicking
    local track = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = "SurfaceAltColor",
        Position = UDim2.new(1, 0, 0.5, 0),
        Size     = UDim2.fromOffset(38, 20),
        Parent   = holder,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3),
        PaddingTop  = UDim.new(0, 3), PaddingBottom= UDim.new(0, 3),
        Parent = track,
    })

    -- Knob with a subtle inner shadow ring
    local knob = New("Frame", {
        BackgroundColor3 = Color3.new(1,1,1),
        Size     = UDim2.fromScale(1, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Parent   = track,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
    New("UIStroke", { Color = Color3.fromRGB(180,180,180), Thickness = 0.5, Transparency = 0.6, Parent = knob })

    local Toggle = setmetatable({
        Text     = info.Text,
        Value    = info.Default,
        Callback = info.Callback,
        Changed  = info.Changed,
        Disabled = info.Disabled,
        Risky    = info.Risky,
        Visible  = info.Visible,
        Type     = "Toggle",
        Addons   = {},
        Holder   = holder,
        TextLabel= label,
        Container= container,
        _maid    = maid,
    }, ComponentBase)

    local _toggleTweenTrack
    local _cancelKnobSpring

    local function display(skipAnim)
        if Library.Unloaded then return end
        local on       = Toggle.Value
        local disabled = Toggle.Disabled

        if _cancelKnobSpring then _cancelKnobSpring() end
        if skipAnim then
            local v = on and 1 or 0
            knob.AnchorPoint = Vector2.new(v, 0)
            knob.Position    = UDim2.fromScale(v, 0)
            knob.BackgroundColor3 = on and Color3.new(1,1,1) or Color3.fromRGB(170,170,170)
        else
            _cancelKnobSpring = AnimEngine.Spring({
                from      = knob.Position.X.Scale,
                to        = on and 1 or 0,
                stiffness = 750, damping = 38,
                apply = function(v)
                    knob.AnchorPoint = Vector2.new(v, 0)
                    knob.Position    = UDim2.fromScale(v, 0)
                end,
            })
            TweenService:Create(knob, TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                { BackgroundColor3 = on and Color3.new(1,1,1) or Color3.fromRGB(170,170,170) }):Play()
        end

        if _toggleTweenTrack then _toggleTweenTrack:Cancel() end
        local targetColor = on and Library.Scheme.AccentColor or Library.Scheme.SurfaceAltColor
        if skipAnim then
            track.BackgroundColor3 = targetColor
        else
            _toggleTweenTrack = TweenService:Create(track,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                { BackgroundColor3 = targetColor })
            _toggleTweenTrack:Play()
        end

        local targetAlpha = (disabled and 0.65) or (on and 0 or 0.38)
        if skipAnim then
            label.TextTransparency = targetAlpha
        else
            TweenService:Create(label, TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                { TextTransparency = targetAlpha }):Play()
        end

        track.BackgroundTransparency = disabled and 0.5 or (on and 0 or (Library.ElementTransparency or 0))
    end

    function Toggle:SetValue(v)
        if self.Disabled then return end
        local old = self.Value
        self.Value = v
        display()
        Library:UpdateDependencyBoxes()
        Library:SafeCallback(self.Callback, v)
        Library:SafeCallback(self.Changed, v)
        if self._changedListeners then
            for _, fn in ipairs(self._changedListeners) do
                Library:SafeCallback(fn, v)
            end
        end
        -- Don't pollute undo history while restoring a config
        if not Library._loadingConfig then
            UndoManager.Push("toggle:" .. (idx or "?"),
                function() self:SetValue(old) end,
                function() self:SetValue(v)   end,
                "Toggle " .. self.Text
            )
        end
    end

    function Toggle:OnChanged(fn)
        self._changedListeners = self._changedListeners or {}
        table.insert(self._changedListeners, fn)
    end

    function Toggle:SetDisabled(v)
        self.Disabled = v
        holder.Active = not v
        display()
    end

    function Toggle:SetVisible(v)
        self.Visible = v
        holder.Visible = v
        Toggle._groupbox:Resize()
    end

    function Toggle:SetText(t)
        self.Text = t
        label.Text = t
    end

    -- Click
    maid:Connect(holder.MouseButton1Click, function()
        if Toggle.Disabled then return end
        Toggle:SetValue(not Toggle.Value)
    end)

    -- Hover: subtle label brightness only
    maid:Connect(holder.MouseEnter, function()
        if not Toggle.Value then
            TweenService:Create(label, TweenInfo.new(0.1), { TextTransparency = 0.2 }):Play()
        end
    end)
    maid:Connect(holder.MouseLeave, function()
        if not Toggle.Value then
            TweenService:Create(label, TweenInfo.new(0.1), { TextTransparency = 0.4 }):Play()
        end
    end)

    display()
    Toggle._groupbox = self
    self:Resize()

    -- Refresh colors when theme changes (hover/track colors are cached Color3s)
    maid:Give(EventBus:On("themeChange", function()
        display(true)
    end))

    Toggle._refreshTransparency = function()
        if not Toggle.Value and not Toggle.Disabled then
            TweenService:Create(track, TweenInfo.new(0.15, Enum.EasingStyle.Quad),
                { BackgroundTransparency = Library.ElementTransparency or 0 }):Play()
        end
    end

    if idx then Library.Toggles[idx] = Toggle end
    table.insert(self.Elements, Toggle)
    Toggle.Default = Toggle.Value
    return Toggle
end

function BaseGroupbox:AddCheckbox(idx, info)
    -- Alias for AddToggle but forced-checkbox visual
    return self:AddToggle(idx, info)
end

function BaseGroupbox:AddSlider(idx, info)
    info = Library:Validate(info, {
        Text     = "Slider",
        Default  = 50,
        Min      = 0,
        Max      = 100,
        Rounding = 0,
        Prefix   = "",
        Suffix   = "",
        Callback = function() end,
        Changed  = function() end,
        Disabled = false,
        Visible  = true,
        Tooltip  = nil,
    })

    local container = self.Container
    local maid      = Maid.New()

    local holder = New("Frame", {
        BackgroundTransparency = 1,
        Size    = UDim2.new(1, 0, 0, 34),
        Visible = info.Visible,
        Parent  = container,
    })

    -- Label row
    local topRow = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        Parent = holder,
    })
    local nameLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0.6, 1),
        Text = info.Text,
        TextSize = Tokens.FontSize.MD,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topRow,
    })
    local valueLabel = New("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.fromScale(0.4, 1),
        Text = "",
        TextSize = Tokens.FontSize.SM,
        TextColor3 = "TextMuted",
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = topRow,
    })

    -- Track
    local track = New("TextButton", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = "SurfaceAltColor",
        Position = UDim2.fromScale(0, 1),
        Size     = UDim2.new(1, 0, 0, 8),
        Text     = "",
        Parent   = holder,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

    local fill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        Size  = UDim2.fromScale(0, 1),
        Parent = track,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

    -- Knob
    local knob = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "TextPrimary",
        Position = UDim2.fromScale(0, 0.5),
        Size     = UDim2.fromOffset(14, 14),
        Parent   = track,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

    -- Drag state declared early so hover handlers can read it
    local dragging = false

    -- Hover: knob grows, track brightens
    local knobScale = Instance.new("UIScale")
    knobScale.Scale = 1
    knobScale.Parent = knob
    local tiKnob = TweenInfo.new(0.1, Enum.EasingStyle.Quad)
    maid:Connect(track.MouseEnter, function()
        TweenService:Create(knobScale, tiKnob, { Scale = 1.25 }):Play()
        TweenService:Create(fill,     tiKnob, { BackgroundColor3 = Library.Scheme.AccentHover }):Play()
    end)
    maid:Connect(track.MouseLeave, function()
        if not dragging then
            TweenService:Create(knobScale, tiKnob, { Scale = 1.0 }):Play()
            TweenService:Create(fill,     tiKnob, { BackgroundColor3 = Library.Scheme.AccentColor }):Play()
        end
    end)

    local function round(v, r)
        if r == 0 then return math.floor(v + 0.5) end
        return tonumber(string.format("%." .. r .. "f", v))
    end

    local Slider = setmetatable({
        Text     = info.Text,
        Value    = info.Default,
        Min      = info.Min,
        Max      = info.Max,
        Rounding = info.Rounding,
        Prefix   = info.Prefix,
        Suffix   = info.Suffix,
        Disabled = info.Disabled,
        Visible  = info.Visible,
        Callback = info.Callback,
        Changed  = info.Changed,
        Type     = "Slider",
        Holder   = holder,
        _maid    = maid,
    }, ComponentBase)

    local _fillTween
    local function setFillDirect(frac)
        if _fillTween then _fillTween:Cancel() end
        fill.Size     = UDim2.fromScale(frac, 1)
        knob.Position = UDim2.fromScale(frac, 0.5)
        valueLabel.Text = Slider.Prefix .. tostring(Slider.Value) .. Slider.Suffix
    end

    local function setFillAnimated(frac)
        if _fillTween then _fillTween:Cancel() end
        _fillTween = TweenService:Create(fill,
            TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.fromScale(frac, 1) })
        _fillTween:Play()
        TweenService:Create(knob,
            TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Position = UDim2.fromScale(frac, 0.5) }):Play()
        valueLabel.Text = Slider.Prefix .. tostring(Slider.Value) .. Slider.Suffix
    end

    function Slider:SetValue(v, fromDrag)
        if self.Disabled then return end
        local num = tonumber(v)
        if not num then return end
        num = math.clamp(num, self.Min, self.Max)
        num = round(num, self.Rounding)
        -- During config load always refresh display even if value is identical
        -- (ensures visual bar is correct when default == saved value)
        if num == self.Value and not Library._loadingConfig then return end
        self.Value = num
        local frac = (num - self.Min) / math.max(1e-6, self.Max - self.Min)
        -- Use fast tween during drag (smooth but responsive), spring for programmatic
        if fromDrag then
            setFillAnimated(frac)
        else
            AnimEngine.Spring({
                from = fill.Size.X.Scale, to = frac,
                stiffness = 400, damping = 28,
                apply = function(s)
                    fill.Size     = UDim2.fromScale(s, 1)
                    knob.Position = UDim2.fromScale(s, 0.5)
                end,
            })
            valueLabel.Text = self.Prefix .. tostring(self.Value) .. self.Suffix
        end
        Library:SafeCallback(self.Callback, num)
        Library:SafeCallback(self.Changed,  num)
    end

    function Slider:SetDisabled(v)
        self.Disabled = v
        track.Active  = not v
    end

    function Slider:SetVisible(v)
        self.Visible = v
        holder.Visible = v
        Slider._groupbox:Resize()
    end

    function Slider:SetMin(v)
        self.Min = v
        self:SetValue(math.max(self.Value, v))
    end

    function Slider:SetMax(v)
        self.Max = v
        self:SetValue(math.min(self.Value, v))
    end

    -- Drag: compute position immediately on click AND on move
    maid:Connect(track.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if Slider.Disabled then return end
        dragging = true
        TweenService:Create(knobScale, tiKnob, { Scale = 1.35 }):Play()
        -- Immediately jump to clicked position
        local abs  = track.AbsolutePosition
        local size = track.AbsoluteSize
        local frac = math.clamp((Mouse.X - abs.X) / size.X, 0, 1)
        Slider:SetValue(Slider.Min + (Slider.Max - Slider.Min) * frac, true)
    end)
    maid:Connect(UserInputService.InputChanged, function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local abs  = track.AbsolutePosition
        local size = track.AbsoluteSize
        local frac = math.clamp((Mouse.X - abs.X) / size.X, 0, 1)
        local val  = Slider.Min + (Slider.Max - Slider.Min) * frac
        Slider:SetValue(val, true)
    end)
    maid:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            TweenService:Create(knobScale, tiKnob, { Scale = 1.0 }):Play()
            TweenService:Create(fill, tiKnob, { BackgroundColor3 = Library.Scheme.AccentColor }):Play()
        end
    end)

    -- Initial display (direct, no animation on load)
    local initFrac = (info.Default - info.Min) / math.max(1e-6, info.Max - info.Min)
    setFillDirect(initFrac)
    valueLabel.Text = info.Prefix .. tostring(info.Default) .. info.Suffix
    Slider._groupbox = self
    self:Resize()

    -- Refresh fill/knob colors when theme changes
    maid:Give(EventBus:On("themeChange", function()
        fill.BackgroundColor3 = Library.Scheme.AccentColor
        knob.BackgroundColor3 = Library.Scheme.TextPrimary
    end))

    if idx then Library.Options[idx] = Slider end
    table.insert(self.Elements, Slider)
    Slider.Default = Slider.Value
    return Slider
end

function BaseGroupbox:AddInput(idx, info)
    info = Library:Validate(info, {
        Text        = "Input",
        Default     = "",
        Placeholder = "",
        Numeric     = false,
        Finished    = false,
        Disabled    = false,
        Visible     = true,
        Callback    = function() end,
        Changed     = function() end,
        AllowEmpty  = true,
    })

    local container = self.Container
    local maid      = Maid.New()

    local holder = New("Frame", {
        BackgroundTransparency = 1,
        Size    = UDim2.new(1, 0, 0, info.Text and 36 or 22),
        Visible = info.Visible,
        Parent  = container,
    })

    if info.Text then
        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = info.Text,
            TextSize = Tokens.FontSize.MD,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = holder,
        })
    end

    local inputFrame = New("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = "SurfaceColor",
        Position = UDim2.fromScale(0, 1),
        Size     = UDim2.new(1, 0, 0, 22),
        Parent   = holder,
    })
    New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = inputFrame })
    New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = inputFrame })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
        Parent = inputFrame,
    })

    local box = New("TextBox", {
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        PlaceholderText  = info.Placeholder,
        Size    = UDim2.fromScale(1, 1),
        Text    = info.Default,
        TextSize= Tokens.FontSize.MD,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent  = inputFrame,
    })

    local Input = setmetatable({
        Text     = info.Text,
        Value    = info.Default,
        Disabled = info.Disabled,
        Visible  = info.Visible,
        Callback = info.Callback,
        Changed  = info.Changed,
        Type     = "Input",
        Holder   = holder,
        Box      = box,
        _maid    = maid,
    }, ComponentBase)

    function Input:SetValue(v)
        self.Value = v
        box.Text   = tostring(v)
        Library:SafeCallback(self.Callback, v)
        Library:SafeCallback(self.Changed,  v)
    end

    function Input:SetDisabled(v)
        self.Disabled = v
        box.TextEditable = not v
    end

    function Input:SetVisible(v)
        self.Visible = v
        holder.Visible = v
        Input._groupbox:Resize()
    end

    -- Focus glow using TweenService
    local inputStroke = inputFrame:FindFirstChildOfClass("UIStroke")
    maid:Connect(box.Focused, function()
        if inputStroke then
            inputStroke.Color = Library.Scheme.AccentColor
            TweenService:Create(inputStroke,
                TweenInfo.new(0.12, Enum.EasingStyle.Quad),
                { Thickness = 1.5 }):Play()
        end
    end)
    maid:Connect(box.FocusLost, function(enterPressed)
        if inputStroke then
            inputStroke.Color = Library.Scheme.BorderColor
            TweenService:Create(inputStroke,
                TweenInfo.new(0.12, Enum.EasingStyle.Quad),
                { Thickness = 1 }):Play()
        end
        local val = box.Text
        if info.Numeric then
            val = tonumber(val)
            if not val then
                box.Text = tostring(Input.Value)
                return
            end
        end
        if val ~= Input.Value then
            Input.Value = val
            Library:SafeCallback(Input.Callback, val)
            Library:SafeCallback(Input.Changed,  val)
        end
    end)

    maid:Connect(box:GetPropertyChangedSignal("Text"), function()
        if not info.Finished then
            local val = box.Text
            if info.Numeric then
                val = tonumber(val)
                if not val then return end
            end
            Library:SafeCallback(Input.Changed, val)
        end
    end)

    Input._groupbox = self
    self:Resize()
    if idx then Library.Options[idx] = Input end
    table.insert(self.Elements, Input)
    Input.Default = Input.Value
    return Input
end

function BaseGroupbox:AddDropdown(idx, info)
    info = Library:Validate(info, {
        Text     = nil,
        Values   = {},
        Default  = nil,
        Multi    = false,
        Disabled = false,
        Visible  = true,
        Callback = function() end,
        Changed  = function() end,
        Tooltip  = nil,
        MaxVisible = 6,
    })

    local container = self.Container
    local maid      = Maid.New()
    local menuOpen  = false

    local holder = New("Frame", {
        BackgroundTransparency = 1,
        Size    = UDim2.new(1, 0, 0, info.Text and 42 or 24),
        Visible = info.Visible,
        Parent  = container,
    })

    if info.Text then
        New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, 0, 0, 14),
            Text = info.Text,
            TextSize = Tokens.FontSize.MD,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = holder,
        })
    end

    local displayBtn = New("TextButton", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = "SurfaceColor",
        Position = UDim2.fromScale(0, 1),
        Size     = UDim2.new(1, 0, 0, 24),
        Text     = "",
        Parent   = holder,
    })
    New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = displayBtn })
    New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = displayBtn })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
        Parent = displayBtn,
    })

    local displayLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -18, 1, 0),
        Text = info.Multi and "Select..." or (info.Default or "Select..."),
        TextSize = Tokens.FontSize.MD,
        TextColor3 = "TextMuted",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = displayBtn,
    })

    -- Arrow: use a simple TextLabel with a rotatable Frame chevron instead of a Unicode glyph
    local arrowFrame = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size     = UDim2.fromOffset(16, 16),
        Parent   = displayBtn,
    })
    -- Draw a simple "v" shape using two rotated frames
    local arrowL = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "TextMuted",
        BorderSizePixel  = 0,
        Position = UDim2.new(0.5, -3, 0.5, 0),
        Size     = UDim2.fromOffset(7, 1.5),
        Rotation = 35,
        Parent   = arrowFrame,
    })
    local arrowR = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "TextMuted",
        BorderSizePixel  = 0,
        Position = UDim2.new(0.5, 3, 0.5, 0),
        Size     = UDim2.fromOffset(7, 1.5),
        Rotation = -35,
        Parent   = arrowFrame,
    })
    local arrowLabel = arrowFrame  -- keep reference name for rotation tweens

    local Dropdown = setmetatable({
        Text     = info.Text,
        Value    = info.Multi and {} or info.Default,
        Values   = info.Values,
        Multi    = info.Multi,
        Disabled = info.Disabled,
        Visible  = info.Visible,
        Callback = info.Callback,
        Changed  = info.Changed,
        Type     = "Dropdown",
        Holder   = holder,
        _maid    = maid,
        _menu    = nil,
    }, ComponentBase)

    local function updateDisplay()
        if Dropdown.Multi then
            local count = 0
            local parts = {}
            for k, v in pairs(Dropdown.Value) do
                if v then count += 1; table.insert(parts, k) end
            end
            if count == 0 then
                displayLabel.Text = "Select…"
                displayLabel.TextColor3 = Library.Scheme.TextMuted
            else
                displayLabel.Text = table.concat(parts, ", "):sub(1, 40)
                displayLabel.TextColor3 = Library.Scheme.TextPrimary
            end
        else
            if Dropdown.Value then
                displayLabel.Text = tostring(Dropdown.Value)
                displayLabel.TextColor3 = Library.Scheme.TextPrimary
            else
                displayLabel.Text = "Select…"
                displayLabel.TextColor3 = Library.Scheme.TextMuted
            end
        end
    end

    local function closeMenu()
        if not Dropdown._menu then return end
        local m = Dropdown._menu
        Dropdown._menu = nil
        menuOpen = false

        local scaleI = m:FindFirstChildOfClass("UIScale")
        local tiOut = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        if scaleI then
            TweenService:Create(scaleI, tiOut, { Scale = 0.9 }):Play()
        end
        TweenService:Create(m, tiOut, { BackgroundTransparency = 1 }):Play()
        -- Fade all descendants out too so text/strokes don't pop
        for _, d in ipairs(m:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                TweenService:Create(d, tiOut, { TextTransparency = 1 }):Play()
            elseif d:IsA("Frame") then
                TweenService:Create(d, tiOut, { BackgroundTransparency = 1 }):Play()
            elseif d:IsA("UIStroke") then
                TweenService:Create(d, tiOut, { Transparency = 1 }):Play()
            end
        end
        task.delay(0.15, function() if m and m.Parent then m:Destroy() end end)
        TweenService:Create(arrowFrame, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Rotation = 0 }):Play()
    end

    local function openMenu()
        if menuOpen or Dropdown.Disabled then return end
        menuOpen = true
        InteractionManager.Push("dropdown:" .. (idx or "?"), closeMenu)
        TweenService:Create(arrowFrame, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Rotation = 180 }):Play()

        -- Position popup - clamp to screen so it never clips off edge
        local abs  = displayBtn.AbsolutePosition
        local absW = displayBtn.AbsoluteSize.X
        local rowH = 22
        local maxH = math.min(#Dropdown.Values, info.MaxVisible) * rowH + 8
        local vp   = Camera.ViewportSize
        local posX = math.clamp(abs.X, 4, vp.X - absW - 4)
        local posY = abs.Y + displayBtn.AbsoluteSize.Y + 4
        -- Flip above if not enough room below
        if posY + maxH > vp.Y - 8 then
            posY = abs.Y - maxH - 4
        end

        local menuFrame = New("Frame", {
            BackgroundColor3 = "SurfaceColor",
            Position = UDim2.fromOffset(posX, posY),
            Size     = UDim2.fromOffset(absW, maxH),
            ZIndex   = ZManager.Get("dropdown"),
            ClipsDescendants = true,
            Parent   = ScreenGui,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusMD), Parent = menuFrame })
        New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = menuFrame })

        local menuScale = Instance.new("UIScale")
        menuScale.Scale = 0.9
        menuScale.Parent = menuFrame

        local scroll = New("ScrollingFrame", {
            BackgroundTransparency = 1,
            CanvasSize  = UDim2.fromOffset(0, 0),
            Size        = UDim2.fromScale(1, 1),
            ScrollBarThickness = 3,
            Parent      = menuFrame,
        })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
            Parent = scroll,
        })
        local listLayout = New("UIListLayout", { Padding = UDim.new(0, 2), Parent = scroll })
        maid:Connect(listLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            scroll.CanvasSize = UDim2.fromOffset(0, listLayout.AbsoluteContentSize.Y + 8)
        end)

        for _, val in ipairs(Dropdown.Values) do
            local selected = Dropdown.Multi and Dropdown.Value[val] or Dropdown.Value == val
            local selBg    = Color3.fromRGB(60, 60, 80)  -- dark readable bg for selected
            local selText  = Color3.new(1, 1, 1)
            local row = New("TextButton", {
                BackgroundColor3       = selected and selBg or ThemeEngine.CurrentScheme.SurfaceColor,
                BackgroundTransparency = selected and 0 or 1,
                Size   = UDim2.new(1, 0, 0, rowH),
                Text   = "",
                Parent = scroll,
            })
            New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = row })
            New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = row })
            local rowLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = tostring(val),
                TextSize = Tokens.FontSize.MD,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = selected and selText or ThemeEngine.CurrentScheme.TextPrimary,
                Parent = row,
            })
            row.MouseEnter:Connect(function()
                if not (Dropdown.Multi and Dropdown.Value[val] or Dropdown.Value == val) then
                    row.BackgroundTransparency = 0
                    row.BackgroundColor3 = ThemeEngine.CurrentScheme.SurfaceAltColor
                end
            end)
            row.MouseLeave:Connect(function()
                local isSel = Dropdown.Multi and Dropdown.Value[val] or Dropdown.Value == val
                row.BackgroundTransparency = isSel and 0 or 1
                row.BackgroundColor3 = isSel and selBg or ThemeEngine.CurrentScheme.SurfaceColor
                rowLabel.TextColor3  = isSel and selText or ThemeEngine.CurrentScheme.TextPrimary
            end)
            row.MouseButton1Click:Connect(function()
                -- update visual immediately
                if Dropdown.Multi then
                    local nowSel = not Dropdown.Value[val]
                    row.BackgroundTransparency = nowSel and 0 or 1
                    row.BackgroundColor3 = nowSel and selBg or ThemeEngine.CurrentScheme.SurfaceColor
                    rowLabel.TextColor3  = nowSel and selText or ThemeEngine.CurrentScheme.TextPrimary
                end
                Dropdown:SetValue(val)
                if not Dropdown.Multi then closeMenu() end
                updateDisplay()
            end)
        end

        -- Fade + scale in
        menuFrame.AnchorPoint = Vector2.new(0, 0)
        menuFrame.BackgroundTransparency = 1
        local tiIn = TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TweenService:Create(menuFrame, tiIn, { BackgroundTransparency = 0 }):Play()
        TweenService:Create(menuScale, tiIn, { Scale = 1 }):Play()

        Dropdown._menu = menuFrame
    end

    function Dropdown:SetValue(v)
        if self.Multi then
            if self.Value[v] then
                self.Value[v] = nil
            else
                self.Value[v] = true
            end
        else
            self.Value = v
        end
        updateDisplay()
        Library:SafeCallback(self.Callback, self.Value)
        Library:SafeCallback(self.Changed,  self.Value)
    end

    -- Used by config restore: sets the value directly without toggle-semantics.
    -- For multi-dropdowns, v should be an array of selected keys (replaces entire selection).
    -- For single dropdowns, v is the string value to select.
    function Dropdown:SetValueConfig(v)
        if self.Multi then
            -- Replace entire selection atomically
            self.Value = {}
            if type(v) == "table" then
                for _, sv in ipairs(v) do
                    self.Value[sv] = true
                end
            end
        else
            self.Value = v
        end
        updateDisplay()
        Library:SafeCallback(self.Callback, self.Value)
        Library:SafeCallback(self.Changed,  self.Value)
    end

    function Dropdown:SetValues(vals)
        self.Values = vals
        if self._menu then
            closeMenu()
        end
    end

    function Dropdown:SetDisabled(v)
        self.Disabled = v
        displayBtn.Active = not v
    end

    function Dropdown:SetVisible(v)
        self.Visible = v
        holder.Visible = v
        Dropdown._groupbox:Resize()
    end

    maid:Connect(displayBtn.MouseButton1Click, function()
        if menuOpen then closeMenu() else openMenu() end
    end)

    -- Close on outside click (but not if clicking the button itself or inside the popup)
    maid:Connect(UserInputService.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if not menuOpen or not Dropdown._menu then return end
        task.defer(function()
            if not Dropdown._menu then return end
            local overHolder = Library:MouseIsOver(displayBtn)
            local overMenu   = Dropdown._menu and Dropdown._menu.Parent and Library:MouseIsOver(Dropdown._menu)
            if not overHolder and not overMenu then
                closeMenu()
            end
        end)
    end)

    Micro.PressDepression(displayBtn, maid)
    updateDisplay()

    Dropdown._groupbox = self
    self:Resize()
    if idx then Library.Options[idx] = Dropdown end
    table.insert(self.Elements, Dropdown)
    Dropdown.Default = Dropdown.Value
    return Dropdown
end

function BaseGroupbox:AddButton(idx, info)
    info = Library:Validate(info, {
        Text     = "Button",
        Callback = function() end,
        Disabled = false,
        Visible  = true,
        Tooltip  = nil,
        Variant  = "Primary",  -- Primary | Secondary | Ghost | Danger
        Sub      = nil,
    })

    local container = self.Container
    local maid      = Maid.New()

    local scheme = Library.Scheme
    -- All buttons use a neutral surface style — no loud accent or red
    local bgColors = {
        Primary   = scheme.SurfaceAltColor,
        Secondary = scheme.SurfaceColor,
        Ghost     = Color3.new(0,0,0),
        Danger    = Color3.fromRGB(60, 25, 25),  -- very subtle dark red
    }
    local textColors = {
        Primary   = scheme.TextPrimary,
        Secondary = scheme.TextSecondary,
        Ghost     = scheme.TextPrimary,
        Danger    = Color3.fromRGB(220, 100, 100),  -- muted red text
    }
    local strokeColors = {
        Primary   = scheme.BorderColor,
        Secondary = scheme.BorderColor,
        Ghost     = Color3.new(0,0,0),
        Danger    = Color3.fromRGB(100, 40, 40),
    }

    local bg     = bgColors[info.Variant]     or scheme.SurfaceAltColor
    local tc     = textColors[info.Variant]   or scheme.TextPrimary
    local sc     = strokeColors[info.Variant] or scheme.BorderColor
    local bgT    = info.Variant == "Ghost" and 1 or 0
    local hoverBg = Color3.fromRGB(
        math.clamp(bg.R*255 + 12, 0, 255)/255,
        math.clamp(bg.G*255 + 12, 0, 255)/255,
        math.clamp(bg.B*255 + 12, 0, 255)/255
    )

    local btn = New("TextButton", {
        BackgroundColor3 = bg,
        BackgroundTransparency = bgT,
        Size     = UDim2.new(1, 0, 0, 22),
        Text     = info.Text,
        TextColor3 = tc,
        TextSize = Tokens.FontSize.MD,
        Visible  = info.Visible,
        Parent   = container,
    })
    New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = btn })
    New("UIStroke", { Color = sc,  Thickness = 1, Parent = btn })

    Micro.PressDepression(btn, maid)
    Micro.Ripple(btn, Color3.new(1,1,1), maid)

    local tiBtn = TweenInfo.new(0.1, Enum.EasingStyle.Quad)
    maid:Connect(btn.MouseEnter, function()
        if not info.Disabled then
            TweenService:Create(btn, tiBtn, { BackgroundColor3 = hoverBg, BackgroundTransparency = bgT == 1 and 0.85 or 0 }):Play()
        end
    end)
    maid:Connect(btn.MouseLeave, function()
        TweenService:Create(btn, tiBtn, { BackgroundColor3 = bg, BackgroundTransparency = bgT }):Play()
    end)

    local Button = setmetatable({
        Text     = info.Text,
        Disabled = info.Disabled,
        Visible  = info.Visible,
        Callback = info.Callback,
        Type     = "Button",
        Holder   = btn,
        Instance = btn,
        _maid    = maid,
    }, ComponentBase)

    maid:Connect(btn.MouseButton1Click, function()
        if Button.Disabled then return end
        Library:SafeCallback(Button.Callback)
    end)

    function Button:SetText(t)
        self.Text = t
        btn.Text  = t
    end

    function Button:SetDisabled(v)
        self.Disabled = v
        btn.Active    = not v
        btn.BackgroundTransparency = v and 0.5 or bgT
    end

    function Button:SetVisible(v)
        self.Visible = v
        btn.Visible  = v
        Button._groupbox:Resize()
    end

    if info.Tooltip then
        maid:Connect(btn.MouseEnter, function()
            ToastSystem.Info(info.Tooltip, { Duration = 2 })
        end)
    end

    Button._groupbox = self
    self:Resize()
    if idx then Library.Buttons[idx] = Button end
    table.insert(self.Elements, Button)

    -- Refresh button colors on theme change
    maid:Give(EventBus:On("themeChange", function()
        local s = Library.Scheme
        local newBg = info.Variant == "Primary" and s.SurfaceAltColor
                   or info.Variant == "Secondary" and s.SurfaceColor
                   or info.Variant == "Danger" and Color3.fromRGB(60, 25, 25)
                   or Color3.new(0,0,0)
        local newTc = info.Variant == "Primary" and s.TextPrimary
                   or info.Variant == "Secondary" and s.TextSecondary
                   or info.Variant == "Danger" and Color3.fromRGB(220, 100, 100)
                   or s.TextPrimary
        bg, tc = newBg, newTc
        hoverBg = Color3.fromRGB(
            math.clamp(bg.R*255 + 12, 0, 255)/255,
            math.clamp(bg.G*255 + 12, 0, 255)/255,
            math.clamp(bg.B*255 + 12, 0, 255)/255
        )
        btn.BackgroundColor3 = bg
        btn.TextColor3 = tc
    end))

    return Button
end

-- Resize: recalculates groupbox height from content
function BaseGroupbox:Resize()
    if not self.Container then return end
    local list = self.Container:FindFirstChildOfClass("UIListLayout")
    if not list then return end
    task.defer(function()
        local h = list.AbsoluteContentSize.Y
        if self.BoxHolder then
            self.BoxHolder.Size = UDim2.new(1, 0, 0, h + 48)  -- 48 = header
        end
    end)
end

function BaseGroupbox:AddDependencyBox()
    local depBox = setmetatable({
        Elements      = {},
        DependencyBoxes = {},
        Container     = self.Container,
        Visible       = true,
        _groupbox     = self,
    }, BaseGroupbox)

    function depBox:SetVisible(v)
        depBox.Visible = v
        for _, e in ipairs(depBox.Elements) do
            e.Holder.Visible = v and e.Visible
        end
        self._groupbox:Resize()
    end

    table.insert(self.DependencyBoxes, depBox)
    return depBox
end

-- ─── Component Addon Methods ───────────────────────────────────────────────
-- Lets components host an inline ColorPicker or KeyPicker on the same row.
-- Usage:  local toggle = Box:AddToggle(...)
--         toggle:AddColorPicker("myColor", { Default = Color3.new(1,0,0) })
--         toggle:AddKeyPicker("myKey",   { Default = "F", Mode = "Toggle" })

local function attachAddonToComponent(component, addonComponent)
    -- Shrink the component's main label to make room on the right
    local label = component.TextLabel
    if label then
        local currentSize = label.Size
        label.Size = UDim2.new(currentSize.X.Scale, currentSize.X.Offset - 26, currentSize.Y.Scale, currentSize.Y.Offset)
    end
    -- Re-parent the addon holder into the component holder
    if addonComponent.Holder then
        addonComponent.Holder.Parent = component.Holder
        addonComponent.Holder.Size   = UDim2.new(0, 26, 1, 0)
        addonComponent.Holder.AnchorPoint = Vector2.new(1, 0.5)
        addonComponent.Holder.Position    = UDim2.new(1, 0, 0.5, 0)
        addonComponent.Holder.BackgroundTransparency = 1
    end
    table.insert(component.Addons, addonComponent)
end

-- Patch Toggle to support addon attachment
local _origToggleReturn = nil  -- handled inline below via ComponentBase extension

function ComponentBase:AddColorPicker(idx, info)
    -- Delegate to groupbox but then re-attach inline
    local gb = self._groupbox
    if not gb then return end
    info = info or {}
    info.Text = ""  -- no label, it's inline
    local cp = gb:AddColorPicker(idx, info)
    -- Pop it out of gb.Elements (it was added there)
    for i = #gb.Elements, 1, -1 do
        if gb.Elements[i] == cp then
            table.remove(gb.Elements, i)
            break
        end
    end
    attachAddonToComponent(self, cp)
    return cp
end

function ComponentBase:AddKeyPicker(idx, info)
    local gb = self._groupbox
    if not gb then return end
    info = info or {}
    info.Text = ""
    local kp = gb:AddKeyPicker(idx, info)
    for i = #gb.Elements, 1, -1 do
        if gb.Elements[i] == kp then
            table.remove(gb.Elements, i)
            break
        end
    end
    attachAddonToComponent(self, kp)
    return kp
end

-- ─── Status Badge ──────────────────────────────────────────────────────────
function BaseGroupbox:AddStatusBadge(info)
    info = Library:Validate(info, {
        Text    = "Status",
        Status  = "ok",     -- "ok" | "warn" | "error" | "info" | "offline"
        Visible = true,
    })

    local statusColors = {
        ok      = Library.Scheme.SuccessColor,
        warn    = Library.Scheme.WarningColor,
        error   = Library.Scheme.DangerColor,
        info    = Library.Scheme.InfoColor,
        offline = Library.Scheme.MutedColor,
    }
    local statusDot = { ok="●", warn="●", error="●", info="●", offline="○" }

    local holder = New("Frame", {
        BackgroundTransparency = 1,
        Size    = UDim2.new(1, 0, 0, 18),
        Visible = info.Visible,
        Parent  = self.Container,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = holder,
    })

    local dot = New("TextLabel", {
        BackgroundTransparency = 1,
        Size  = UDim2.fromOffset(10, 10),
        Text  = statusDot[info.Status] or "●",
        TextSize = 10,
        TextColor3 = statusColors[info.Status] or Library.Scheme.InfoColor,
        LayoutOrder = 1,
        Parent = holder,
    })
    local textLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size  = UDim2.new(1, -16, 1, 0),
        Text  = info.Text,
        TextSize = Tokens.FontSize.SM,
        TextColor3 = "TextSecondary",
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        Parent = holder,
    })

    local Badge = { Type = "StatusBadge", Holder = holder, Visible = info.Visible }

    function Badge:SetStatus(s)
        dot.TextColor3 = statusColors[s] or Library.Scheme.InfoColor
        dot.Text       = statusDot[s] or "●"
        dot.TextTransparency = 1
        TweenService:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { TextTransparency = 0 }):Play()
    end

    function Badge:SetText(t)
        textLabel.Text = t
    end

    function Badge:SetVisible(v)
        self.Visible = v
        holder.Visible = v
        self._groupbox:Resize()
    end

    Badge._groupbox = self
    table.insert(self.Elements, Badge)
    self:Resize()
    return Badge
end

-- ─── Progress Bar ──────────────────────────────────────────────────────────
function BaseGroupbox:AddProgressBar(idx, info)
    info = Library:Validate(info, {
        Text    = "Progress",
        Value   = 0,
        Min     = 0,
        Max     = 100,
        Suffix  = "%",
        Color   = nil,  -- nil = accent
        Visible = true,
    })

    local holder = New("Frame", {
        BackgroundTransparency = 1,
        Size    = UDim2.new(1, 0, 0, 28),
        Visible = info.Visible,
        Parent  = self.Container,
    })

    local topRow = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        Parent = holder,
    })
    local nameLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6, 0, 1, 0),
        Text = info.Text,
        TextSize = Tokens.FontSize.SM,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topRow,
    })
    local valLabel = New("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0.4, 0, 1, 0),
        Text = tostring(info.Value) .. info.Suffix,
        TextSize = Tokens.FontSize.XS,
        TextColor3 = "TextMuted",
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = topRow,
    })

    local track = New("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = "SurfaceAltColor",
        Position = UDim2.fromScale(0, 1),
        Size     = UDim2.new(1, 0, 0, 6),
        Parent   = holder,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

    local fill = New("Frame", {
        BackgroundColor3 = info.Color or "AccentColor",
        Size = UDim2.fromScale(0, 1),
        Parent = track,
    })
    New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

    local frac = math.clamp((info.Value - info.Min) / math.max(1, info.Max - info.Min), 0, 1)
    fill.Size = UDim2.fromScale(frac, 1)

    local Bar = { Type = "ProgressBar", Holder = holder, Value = info.Value, Visible = info.Visible }

    function Bar:SetValue(v)
        self.Value = math.clamp(v, info.Min, info.Max)
        local f = (self.Value - info.Min) / math.max(1, info.Max - info.Min)
        TweenService:Create(fill,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.fromScale(f, 1) }):Play()
        valLabel.Text = tostring(math.round(self.Value)) .. info.Suffix
    end

    function Bar:SetText(t)
        nameLabel.Text = t
    end

    function Bar:SetVisible(v)
        self.Visible = v
        holder.Visible = v
        self._groupbox:Resize()
    end

    Bar._groupbox = self
    table.insert(self.Elements, Bar)
    if idx then Library.Options[idx] = Bar end
    self:Resize()
    return Bar
end

-- ─── Accordion Group ───────────────────────────────────────────────────────
function BaseGroupbox:AddAccordion(info)
    info = Library:Validate(info, {
        Text      = "Section",
        Expanded  = false,
        Visible   = true,
    })

    local expanded = info.Expanded
    local maid     = Maid.New()

    local wrapper = New("Frame", {
        BackgroundTransparency = 1,
        Size    = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Visible = info.Visible,
        Parent  = self.Container,
    })

    -- Header button
    local header = New("TextButton", {
        BackgroundColor3 = "SurfaceAltColor",
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, 0, 0, 22),
        Text = "",
        Parent = wrapper,
    })
    New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = header })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
        Parent = header,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = header,
    })

    local arrow = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(12, 12),
        Text = "▸",
        TextSize = 11,
        TextColor3 = "TextMuted",
        LayoutOrder = 1,
        Parent = header,
    })
    New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -18, 1, 0),
        Text = info.Text,
        TextSize = Tokens.FontSize.MD,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        Parent = header,
    })

    -- Content area
    local content = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 22),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = false,
        Visible = expanded,
        Parent = wrapper,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 8), PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = content,
    })
    New("UIListLayout", { Padding = UDim.new(0, 4), Parent = content })

    -- Left accent line
    New("Frame", {
        BackgroundColor3 = "AccentSubtle",
        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(0, 2, 1, 0),
        Parent = content,
    })

    local Accordion = setmetatable({
        Type      = "Accordion",
        Holder    = wrapper,
        Elements  = {},
        DependencyBoxes = {},
        Container = content,
        Expanded  = expanded,
        Visible   = info.Visible,
        BoxHolder = nil,
    }, BaseGroupbox)

    function Accordion:Resize()
        self._groupbox:Resize()
    end

    local function setExpanded(v)
        expanded = v
        Accordion.Expanded = v
        content.Visible = true

        local tiFast = TweenInfo.new(0.12, Enum.EasingStyle.Quad)
        TweenService:Create(arrow, tiFast, { Rotation = expanded and 0 or -90 }):Play()

        if not expanded then
            task.delay(0.25, function()
                if not Accordion.Expanded then
                    content.Visible = false
                end
            end)
        end
        Accordion._groupbox:Resize()
    end

    if expanded then
        arrow.Rotation = 0
    end

    maid:Connect(header.MouseButton1Click, function()
        setExpanded(not expanded)
    end)
    local tiHdr = TweenInfo.new(0.1, Enum.EasingStyle.Quad)
    maid:Connect(header.MouseEnter, function()
        TweenService:Create(header, tiHdr, { BackgroundTransparency = 0.3 }):Play()
    end)
    maid:Connect(header.MouseLeave, function()
        TweenService:Create(header, tiHdr, { BackgroundTransparency = 0.5 }):Play()
    end)

    Accordion._groupbox = self
    Accordion._maid     = maid
    table.insert(self.Elements, Accordion)
    self:Resize()
    return Accordion
end

-- ─── Config Persistence ────────────────────────────────────────────────────
-- Serialises all Toggles, Options (Sliders, Inputs, Dropdowns, ColorPickers,
-- KeyPickers) to a JSON string and restores them on load.
-- Uses writefile/readfile if available (executor), else falls back to a
-- protected in-memory store accessible via getgenv().
local ConfigSystem = {}
do
    local function tryWrite(path, data)
        if writefile then
            pcall(writefile, path, data)
            return true
        end
        if getgenv then
            getgenv().__NexusUI_Config = getgenv().__NexusUI_Config or {}
            getgenv().__NexusUI_Config[path] = data
            return true
        end
        return false
    end

    local function tryRead(path)
        if readfile then
            local ok, data = pcall(readfile, path)
            if ok and data then return data end
        end
        if getgenv and getgenv().__NexusUI_Config then
            return getgenv().__NexusUI_Config[path]
        end
        return nil
    end

    local function isDir(path)
        if isfolder then return isfolder(path) end
        return false
    end

    local function makeDir(path)
        if makefolder and not isDir(path) then
            pcall(makefolder, path)
        end
    end

    local function fileExists(filename)
        local path = (Library.ConfigFolder or "NexusUI") .. "/" .. filename .. ".json"
        return tryRead(path) ~= nil
    end

    function ConfigSystem.Exists(filename)
        return fileExists(filename)
    end

    function ConfigSystem.Save(filename)
        local data = {}

        for k, toggle in pairs(Library.Toggles) do
            data["toggle:" .. k] = toggle.Value
        end

        -- Saveable types only — Buttons, ProgressBars, StatusBadges etc. are skipped
        local SAVEABLE_TYPES = {
            Toggle = true, Slider = true, Input = true, Dropdown = true,
            ColorPicker = true, KeyPicker = true,
        }
        for k, option in pairs(Library.Options) do
            local t = option.Type
            if not SAVEABLE_TYPES[t] then continue end
            if t == "Slider" or t == "Input" then
                data["option:" .. k] = option.Value
            elseif t == "Dropdown" then
                if option.Multi then
                    local sel = {}
                    for v, on in pairs(option.Value or {}) do
                        if on then table.insert(sel, v) end
                    end
                    data["dropdown_multi:" .. k] = sel
                else
                    data["dropdown:" .. k] = option.Value
                end
            elseif t == "ColorPicker" then
                local c = option.Value
                data["color:" .. k] = {
                    math.round(c.R * 255),
                    math.round(c.G * 255),
                    math.round(c.B * 255),
                    option.Alpha or 1,
                }
            elseif t == "KeyPicker" then
                data["key:" .. k] = { value = option.Value, mode = option.Mode }
            end
        end

        -- Save builtin settings (nx_ keys) separately so they restore last
        -- after PopulateBuiltinSettings has fully wired up its callbacks.
        -- Toggles
        for k, toggle in pairs(Library.Toggles) do
            if k:sub(1, 3) == "nx_" then
                data["settings_toggle:" .. k] = toggle.Value
                data["toggle:" .. k] = nil  -- remove from normal toggle namespace
            end
        end
        -- Options
        for k, option in pairs(Library.Options) do
            local t = option.Type
            if k:sub(1, 3) == "nx_" and SAVEABLE_TYPES[t] then
                if t == "Slider" or t == "Input" then
                    data["settings_option:" .. k] = option.Value
                    data["option:" .. k] = nil
                elseif t == "Dropdown" then
                    if option.Multi then
                        local sel = {}
                        for v, on in pairs(option.Value or {}) do
                            if on then table.insert(sel, v) end
                        end
                        data["settings_dropdown_multi:" .. k] = sel
                        data["dropdown_multi:" .. k] = nil
                    else
                        data["settings_dropdown:" .. k] = option.Value
                        data["dropdown:" .. k] = nil
                    end
                elseif t == "ColorPicker" then
                    local c = option.Value
                    data["settings_color:" .. k] = {
                        math.round(c.R * 255),
                        math.round(c.G * 255),
                        math.round(c.B * 255),
                        option.Alpha or 1,
                    }
                    data["color:" .. k] = nil
                elseif t == "KeyPicker" then
                    data["settings_key:" .. k] = { value = option.Value, mode = option.Mode }
                    data["key:" .. k] = nil
                end
            end
        end

        -- Save window size and position if a window has been created.
        -- Always store the BASE (100% DPI) size so it restores correctly at any DPI level.
        if Library.Window and Library.Window.Main then
            local mainFrame = Library.Window.Main
            local baseSize = Library.Window._getBaseSize and Library.Window._getBaseSize()
            local saveX, saveY
            if baseSize then
                saveX = baseSize.X.Offset
                saveY = baseSize.Y.Offset
            else
                -- Fallback: divide current size by DPI scale to get base
                local dpi = Library.DPIScale or 1
                saveX = math.round(mainFrame.Size.X.Offset / dpi)
                saveY = math.round(mainFrame.Size.Y.Offset / dpi)
            end
            data["window_size"] = { X = saveX, Y = saveY }
            data["window_pos"] = {
                X = mainFrame.Position.X.Offset,
                Y = mainFrame.Position.Y.Offset,
                XScale = mainFrame.Position.X.Scale,
                YScale = mainFrame.Position.Y.Scale,
            }
        end

        local encoded = HttpService:JSONEncode(data)
        makeDir(Library.ConfigFolder or "NexusUI")
        local path = (Library.ConfigFolder or "NexusUI") .. "/" .. (filename or "config") .. ".json"
        tryWrite(path, encoded)
        EventBus:Emit("configSaved", path)
        return encoded
    end

    --[[
        ConfigSystem.Load
        ─────────────────
        Restores Toggles, Options and the window size/position from a saved
        config file.

        Robustness / "missing element" handling:
          • If a saved key refers to a Toggle/Option/Window element that no
            longer exists (e.g. the script removed that toggle, or it was
            renamed), the entry is simply skipped — it is collected into
            `missing` and reported via the `configIntegrity` event / toast
            instead of erroring.
          • If the *current* UI has Toggles/Options that are NOT present in
            the saved config (new elements added since the config was saved),
            those are left at their defaults and reported as `unset` so the
            user knows their config is "out of date" without anything
            breaking.
          • Every individual restore is wrapped in pcall so one bad/corrupt
            entry can never abort the whole load.
    ]]
    function ConfigSystem.Load(filename)
        local path = (Library.ConfigFolder or "NexusUI") .. "/" .. (filename or "config") .. ".json"
        local raw = tryRead(path)
        if not raw then return false end

        local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if not ok or type(data) ~= "table" then return false end

        local missing = {}   -- keys present in the config but not in the live UI
        local applied  = {}  -- idx -> true, for computing `unset` afterwards

        -- Safe wrapper for single-value SetValue calls
        local function safeSetValue(target, value)
            return pcall(function() target:SetValue(value) end)
        end

        -- Split data into normal entries and settings (nx_) entries;
        -- settings are applied last so PopulateBuiltinSettings is ready.
        local normalData   = {}
        local settingsData = {}
        for k, v in pairs(data) do
            if k:sub(1, 9) == "settings_" then
                settingsData[k] = v
            else
                normalData[k] = v
            end
        end

        -- Maps saved prefixes to restore logic. Shared by both normal and settings passes.
        local function restoreEntry(k, v)
            -- Window size/pos (only on normal pass, not settings pass)
            if k == "window_size" and Library.Window and Library.Window.Main then
                pcall(function()
                    local mf = Library.Window.Main
                    -- v.X/Y are base (100% DPI) dimensions; scale by current DPI before applying
                    local dpi = Library.DPIScale or 1
                    local scaledX = math.round(v.X * dpi)
                    local scaledY = math.round(v.Y * dpi)
                    local newSize = UDim2.new(mf.Size.X.Scale, scaledX, mf.Size.Y.Scale, scaledY)
                    -- Also update _dpiBaseSize so future DPI changes stay correct
                    if Library.Window._getBaseSize then
                        -- Replace the base reference via the applyDPISize path
                        Library.Window._restoreBaseSize = UDim2.fromOffset(v.X, v.Y)
                    end
                    if Library.Window.SetSize then Library.Window:SetSize(newSize)
                    else mf.Size = newSize end
                end)
            elseif k == "window_pos" and Library.Window and Library.Window.Main then
                pcall(function()
                    local mf = Library.Window.Main
                    local newPos = UDim2.new(
                        v.XScale or mf.Position.X.Scale, v.X,
                        v.YScale or mf.Position.Y.Scale, v.Y)
                    if Library.Window.SetPosition then Library.Window:SetPosition(newPos)
                    else mf.Position = newPos end
                end)
            else
                -- Strip settings_ prefix so patterns below work for both passes
                local stripped = k:gsub("^settings_", "")

                -- ── Toggle ───────────────────────────────────────────────────
                local toggleKey = stripped:match("^toggle:(.+)$")
                if toggleKey then
                    local target = Library.Toggles[toggleKey]
                    if target then
                        -- Coerce to boolean with fallback to false
                        local boolVal = (v == true or v == 1) and true or false
                        safeSetValue(target, boolVal)
                        applied["toggle:" .. toggleKey] = true
                    else
                        table.insert(missing, { kind = "Toggle", idx = toggleKey })
                    end
                end

                -- ── Slider / Input (option:) ─────────────────────────────────
                local optKey = stripped:match("^option:(.+)$")
                if optKey then
                    local target = Library.Options[optKey]
                    if target then
                        safeSetValue(target, v)
                        applied["option:" .. optKey] = true
                    else
                        table.insert(missing, { kind = "Option", idx = optKey })
                    end
                end

                -- ── Single Dropdown ──────────────────────────────────────────
                local dropKey = stripped:match("^dropdown:(.+)$")
                if dropKey then
                    local target = Library.Options[dropKey]
                    if target then
                        -- Use SetValueConfig if available to avoid toggle-semantics issues
                        if target.SetValueConfig then
                            pcall(function() target:SetValueConfig(v) end)
                        else
                            safeSetValue(target, v)
                        end
                        applied["dropdown:" .. dropKey] = true
                    else
                        table.insert(missing, { kind = "Dropdown", idx = dropKey })
                    end
                end

                -- ── Multi Dropdown ───────────────────────────────────────────
                -- Use SetValueConfig to replace selection atomically — avoids
                -- the old bug where calling SetValue per-item would toggle
                -- items that were already selected by a default value.
                local dropMultiKey = stripped:match("^dropdown_multi:(.+)$")
                if dropMultiKey then
                    local target = Library.Options[dropMultiKey]
                    if target and type(v) == "table" then
                        pcall(function()
                            if target.SetValueConfig then
                                target:SetValueConfig(v)
                            else
                                -- Fallback: wipe then set each item directly
                                target.Value = {}
                                for _, sv in ipairs(v) do
                                    target.Value[sv] = true
                                end
                                -- Manually fire updateDisplay via SetValue on a
                                -- dummy then undo, or call the callback directly.
                                -- Safest: just call Callback with the final value.
                                Library:SafeCallback(target.Callback, target.Value)
                                Library:SafeCallback(target.Changed,  target.Value)
                            end
                        end)
                        applied["dropdown_multi:" .. dropMultiKey] = true
                    else
                        table.insert(missing, { kind = "Dropdown (multi)", idx = dropMultiKey })
                    end
                end

                -- ── ColorPicker ──────────────────────────────────────────────
                -- v is {R, G, B} or {R, G, B, alpha} — alpha added in newer saves.
                local colorKey = stripped:match("^color:(.+)$")
                if colorKey then
                    local target = Library.Options[colorKey]
                    if target and type(v) == "table" and #v >= 3 then
                        pcall(function()
                            local color = Color3.fromRGB(v[1], v[2], v[3])
                            local alpha = v[4]  -- nil on old saves → SetValue keeps current alpha
                            target:SetValue(color, alpha)
                        end)
                        applied["color:" .. colorKey] = true
                    else
                        table.insert(missing, { kind = "ColorPicker", idx = colorKey })
                    end
                end

                -- ── KeyPicker ────────────────────────────────────────────────
                -- Restore both key AND mode, then fire refreshDisplay by calling
                -- SetValue (which calls refreshDisplay internally).
                local keyKey = stripped:match("^key:(.+)$")
                if keyKey then
                    local target = Library.Options[keyKey]
                    if target and type(v) == "table" then
                        pcall(function()
                            -- Set mode first so refreshDisplay shows the correct label
                            if v.mode and type(v.mode) == "string" then
                                target.Mode = v.mode
                            end
                            -- SetValue with fireCallback=false to suppress side-effects;
                            -- it calls refreshDisplay internally which picks up new mode.
                            if v.value then
                                target:SetValue(v.value, false)
                            end
                        end)
                        applied["key:" .. keyKey] = true
                    else
                        table.insert(missing, { kind = "KeyPicker", idx = keyKey })
                    end
                end
            end
        end

        -- Suppress user callbacks AND undo history during the entire restore.
        -- _loadingConfig must be true BEFORE any restoreEntry call, including
        -- the deferred settings pass.
        Library._loadingConfig = true

        -- Pass 1: normal user values
        for k, v in pairs(normalData) do restoreEntry(k, v) end

        -- Pass 2: builtin settings (nx_ keys) — deferred one frame so the
        -- Settings panel callbacks are guaranteed to be wired up.
        -- _loadingConfig stays true until this pass finishes.
        task.defer(function()
            for k, v in pairs(settingsData) do restoreEntry(k, v) end
            Library._loadingConfig = false
        end)

        -- Anything that exists in the live UI but wasn't in the config
        local unset = {}
        for k in pairs(Library.Toggles) do
            if not applied["toggle:" .. k] then
                table.insert(unset, { kind = "Toggle", idx = k })
            end
        end
        for k, option in pairs(Library.Options) do
            local t = option.Type
            local prefix
            if t == "Dropdown" then
                prefix = option.Multi and "dropdown_multi:" or "dropdown:"
            elseif t == "Slider" or t == "Input" then
                prefix = "option:"
            elseif t == "ColorPicker" then
                prefix = "color:"
            elseif t == "KeyPicker" then
                prefix = "key:"
            end
            if prefix and not applied[prefix .. k] then
                table.insert(unset, { kind = t, idx = k })
            end
        end

        if #missing > 0 or #unset > 0 then
            EventBus:Emit("configIntegrity", { path = path, missing = missing, unset = unset })
        end

        EventBus:Emit("configLoaded", path)
        return true, { missing = missing, unset = unset }
    end

    function ConfigSystem.Delete(filename)
        local path = (Library.ConfigFolder or "NexusUI") .. "/" .. (filename or "config") .. ".json"
        if delfile then pcall(delfile, path) end
        if getgenv and getgenv().__NexusUI_Config then
            getgenv().__NexusUI_Config[path] = nil
        end
    end

    function ConfigSystem.List()
        local _cfolder = Library.ConfigFolder or "NexusUI"
        if listfiles and isDir(_cfolder) then
            local files = {}
            local ok, list = pcall(listfiles, _cfolder)
            if ok then
                for _, f in ipairs(list) do
                    local name = f:match("([^/\\]+)%.json$")
                    if name and name ~= "_default" then table.insert(files, name) end
                end
            end
            return files
        end
        if getgenv and getgenv().__NexusUI_Config then
            local files = {}
            for path in pairs(getgenv().__NexusUI_Config) do
                local cfolder = Library.ConfigFolder or "NexusUI"
                local name = path:match(cfolder:gsub("%-", "%%%%-") .. "/(.+)%.json$")
                if name and name ~= "_default" then table.insert(files, name) end
            end
            return files
        end
        return {}
    end

    function ConfigSystem.SetDefault(filename)
        tryWrite((Library.ConfigFolder or "NexusUI") .. "/_default.json", HttpService:JSONEncode({ default = filename }))
    end

    function ConfigSystem.GetDefault()
        local raw = tryRead((Library.ConfigFolder or "NexusUI") .. "/_default.json")
        if not raw then return nil end
        local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok and data and data.default then return data.default end
        return nil
    end

    -- ── Integrity handler ──────────────────────────────────────────────
    -- Fires automatically whenever ConfigSystem.Load finds entries that
    -- don't map to a live element (deleted/renamed toggles/options) or
    -- live elements that weren't in the saved config (new elements added
    -- since the config was last saved). Surfaces a single, short toast so
    -- the user knows their config is out of sync without spamming errors
    -- or breaking the load.
    EventBus:On("configIntegrity", function(info)
        local missingN = #info.missing
        local unsetN   = #info.unset

        if missingN > 0 then
            local sample = info.missing[1].idx
            local extra  = missingN > 1 and (" +" .. (missingN - 1) .. " more") or ""
            ToastSystem.Warning(
                "Config: '" .. tostring(sample) .. "'" .. extra ..
                " no longer exist" .. (missingN == 1 and "s" or "") .. " — skipped.",
                { Duration = 4 }
            )
        end

        if unsetN > 0 then
            local sample = info.unset[1].idx
            local extra  = unsetN > 1 and (" +" .. (unsetN - 1) .. " more") or ""
            ToastSystem.Info(
                "Config: '" .. tostring(sample) .. "'" .. extra ..
                " not found in save — using default" .. (unsetN == 1 and "" or "s") .. ".",
                { Duration = 4 }
            )
        end
    end)

    Library.Config = ConfigSystem
end

-- ─── Floating Keybind List ─────────────────────────────────────────────────
-- A small overlay in the corner listing all active keybinds and their state.
-- Shown/hidden via Library:ToggleKeybindList().
local KeybindListFrame
do
    KeybindListFrame = New("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = "SurfaceColor",
        BackgroundTransparency = 0.1,
        Position = UDim2.new(1, -12, 1, -42),
        Size     = UDim2.fromOffset(160, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible  = false,
        Parent   = ScreenGui,
    })
    ZManager.Apply(KeybindListFrame, "toast", -1)
    New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusMD), Parent = KeybindListFrame })
    New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = KeybindListFrame })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 8), PaddingRight  = UDim.new(0, 8),
        PaddingTop  = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
        Parent = KeybindListFrame,
    })
    New("UIListLayout", { Padding = UDim.new(0, 4), Parent = KeybindListFrame })

    -- Header
    New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        Text = "KEYBINDS",
        TextSize = Tokens.FontSize.XS,
        TextColor3 = "TextMuted",
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = KeybindListFrame,
    })
    New("Frame", {
        BackgroundColor3 = "BorderColor",
        Size = UDim2.new(1, 0, 0, 1),
        Parent = KeybindListFrame,
    })

    local keyRows = {}  -- idx → { row, keyLabel, stateLabel }

    local updateConn = RunService.Heartbeat:Connect(function()
        if not KeybindListFrame.Visible then return end
        for idx, kp in pairs(Library.Options) do
            if kp.Type == "KeyPicker" and kp.Value ~= "None" and not kp.NoUI then
                if not keyRows[idx] then
                    local row = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 16),
                        Parent = KeybindListFrame,
                    })
                    local nl = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.65, 0, 1, 0),
                        Text = kp.Text,
                        TextSize = Tokens.FontSize.XS,
                        TextColor3 = "TextSecondary",
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = row,
                    })
                    local kl = New("TextLabel", {
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.fromScale(1, 0),
                        Size = UDim2.new(0.34, 0, 1, 0),
                        Text = kp.Value,
                        TextSize = Tokens.FontSize.XS,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Parent = row,
                    })
                    keyRows[idx] = { row = row, keyLabel = kl, nameLabel = nl }
                end

                local r = keyRows[idx]
                r.keyLabel.Text = kp.Value
                r.nameLabel.Text = kp.Text
                -- Active = accent color, inactive = muted
                local isActive = kp:IsActive()
                r.keyLabel.TextColor3 = isActive
                    and Library.Scheme.AccentColor
                    or  Library.Scheme.TextMuted
            end
        end
        -- Remove stale rows
        for idx, r in pairs(keyRows) do
            local kp = Library.Options[idx]
            if not kp or kp.Type ~= "KeyPicker" or kp.Value == "None" then
                r.row:Destroy()
                keyRows[idx] = nil
            end
        end
    end)
    LibraryMaid:Give(updateConn)

    function Library:ToggleKeybindList(v)
        local show = (v == nil) and not KeybindListFrame.Visible or v
        KeybindListFrame.Visible = true
        TweenService:Create(KeybindListFrame,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad),
            { BackgroundTransparency = show and 0.1 or 1 }):Play()
        task.delay(0.17, function()
            if not show then KeybindListFrame.Visible = false end
        end)
    end
end

-- ─── Tooltip with Delay ────────────────────────────────────────────────────
local tooltipFrame
do
    tooltipFrame = New("Frame", {
        AutomaticSize    = Enum.AutomaticSize.XY,
        BackgroundColor3 = "SurfaceColor",
        Visible          = false,
        ZIndex           = ZManager.Get("tooltip"),
        Parent           = ScreenGui,
    })
    New("UICorner",  { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = tooltipFrame })
    New("UIStroke",  { Color = "BorderColor", Thickness = 1, Parent = tooltipFrame })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
        PaddingTop  = UDim.new(0, 3), PaddingBottom= UDim.new(0, 3),
        Parent = tooltipFrame,
    })
    local tooltipLabel = New("TextLabel", {
        AutomaticSize  = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        Text           = "",
        TextSize       = Tokens.FontSize.SM,
        TextColor3     = "TextSecondary",
        TextWrapped    = true,
        Parent         = tooltipFrame,
    })

    local currentHover = nil

    function Library:AddTooltip(element, text, delaySeconds)
        delaySeconds = delaySeconds or 0.5
        local thread
        local maid = Maid.New()

        maid:Connect(element.MouseEnter, function()
            currentHover = element
            thread = task.delay(delaySeconds, function()
                if currentHover ~= element then return end
                tooltipLabel.Text = text
                tooltipFrame.Visible = true
                while currentHover == element and Library.Toggled do
                    tooltipFrame.Position = UDim2.fromOffset(Mouse.X + 14, Mouse.Y + 10)
                    RunService.RenderStepped:Wait()
                end
                tooltipFrame.Visible = false
            end)
        end)

        maid:Connect(element.MouseLeave, function()
            if currentHover == element then
                currentHover = nil
                tooltipFrame.Visible = false
            end
            if thread then
                task.cancel(thread)
                thread = nil
            end
        end)

        return maid
    end
end

-- ─── Color Picker ──────────────────────────────────────────────────────────
function BaseGroupbox:AddColorPicker(idx, info)
    info = Library:Validate(info, {
        Text     = "Color",
        Default  = Color3.fromRGB(255, 255, 255),
        Callback = function() end,
        Changed  = function() end,
        Disabled = false,
        Visible  = true,
    })

    local container = self.Container
    local maid      = Maid.New()
    local menuOpen  = false
    local menuFrame = nil

    -- Current H, S, V state
    local H, S, V = info.Default:ToHSV()
    local A = 1

    local holder = New("Frame", {
        BackgroundTransparency = 1,
        Size    = UDim2.new(1, 0, 0, 20),
        Visible = info.Visible,
        Parent  = container,
    })

    -- Label
    local nameLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, -28, 1, 0),
        Text     = info.Text,
        TextSize = Tokens.FontSize.MD,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent   = holder,
    })

    -- Outer holder (rounded border + stroke)
    local swatchHolder = New("Frame", {
        AnchorPoint          = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position             = UDim2.new(1, 0, 0.5, 0),
        Size                 = UDim2.fromOffset(24, 14),
        Parent               = holder,
    })
    New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = swatchHolder })
    New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = swatchHolder })
    -- Inner masked frame: clips children to rounded shape
    local swatchMask = New("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants       = true,
        Size                   = UDim2.fromScale(1, 1),
        Parent                 = swatchHolder,
    })
    New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = swatchMask })
    -- Checkerboard tiles inside the mask
    for col = 0, 3 do
        for row = 0, 1 do
            local isDark = (col + row) % 2 == 0
            local tile = Instance.new("Frame")
            tile.BackgroundColor3 = isDark and Color3.fromRGB(160,160,160) or Color3.fromRGB(220,220,220)
            tile.BorderSizePixel  = 0
            tile.Position         = UDim2.fromOffset(col * 6, row * 7)
            tile.Size             = UDim2.fromOffset(6, 7)
            tile.Parent           = swatchMask
        end
    end
    -- Color overlay on top
    local swatch = New("TextButton", {
        BackgroundColor3       = info.Default,
        BackgroundTransparency = 1 - A,
        Size                   = UDim2.fromScale(1, 1),
        Text                   = "",
        Parent                 = swatchMask,
    })

    local ColorPicker = setmetatable({
        Text     = info.Text,
        Value    = info.Default,
        Disabled = info.Disabled,
        Visible  = info.Visible,
        Callback = info.Callback,
        Changed  = info.Changed,
        Type     = "ColorPicker",
        Holder   = holder,
        _maid    = maid,
        _changedListeners = {},
    }, ComponentBase)

    local function closeMenu()
        if not menuFrame then return end
        menuOpen = false
        local m = menuFrame
        menuFrame = nil
        TweenService:Create(m, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { BackgroundTransparency = 1 }):Play()
        task.delay(0.12, function() if m and m.Parent then m:Destroy() end end)
        InteractionManager.Pop()
    end

    local function updateColor(newH, newS, newV)
        H, S, V = newH, newS, newV
        local color = Color3.fromHSV(H, S, V)
        ColorPicker.Value = color
        swatch.BackgroundColor3 = color
        Library:SafeCallback(ColorPicker.Callback, color)
        Library:SafeCallback(ColorPicker.Changed,  color)
        for _, fn in ipairs(ColorPicker._changedListeners) do
            Library:SafeCallback(fn, color)
        end
    end

    local A = 1  -- alpha channel (0=transparent, 1=opaque)

    local function openMenu()
        if menuOpen or ColorPicker.Disabled then return end
        menuOpen = true
        InteractionManager.Push("colorpicker:" .. (idx or "?"), closeMenu)

        local PICKER_W = 216
        local PICKER_H = 150
        local BAR_H    = 12
        local IW       = PICKER_W - 16  -- inner width after padding

        local absPos  = swatch.AbsolutePosition
        local absSize = swatch.AbsoluteSize
        local vp      = Camera.ViewportSize
        local popX    = math.clamp(absPos.X, 4, vp.X - PICKER_W - 4)
        local popY    = absPos.Y + absSize.Y + 4
        -- Estimate height: PICKER_H + 3 bars + hex row + padding ≈ PICKER_H + 80
        if popY + PICKER_H + 80 > vp.Y - 8 then
            popY = absPos.Y - PICKER_H - 80
        end

        menuFrame = New("Frame", {
            BackgroundColor3  = "SurfaceColor",
            Position          = UDim2.fromOffset(popX, popY),
            Size              = UDim2.fromOffset(PICKER_W, 0),
            AutomaticSize     = Enum.AutomaticSize.Y,
            ZIndex            = ZManager.Get("dropdown"),
            ClipsDescendants  = false,
            Parent            = ScreenGui,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusMD), Parent = menuFrame })
        New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = menuFrame })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
            PaddingTop  = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
            Parent = menuFrame,
        })
        New("UIListLayout", { Padding = UDim.new(0, 6), Parent = menuFrame })

        local IW = PICKER_W - 16  -- inner width

        -- ── SV Box ──────────────────────────────────────────────────────
        local svBox = New("TextButton", {
            BackgroundColor3 = Color3.fromHSV(H, 1, 1),
            Size = UDim2.fromOffset(IW, PICKER_H),
            Text = "",
            ClipsDescendants = true,
            LayoutOrder = 1,
            Parent = menuFrame,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = svBox })

        -- White-to-transparent gradient (left=white, right=transparent) — saturation axis
        local whiteOverlay = New("Frame", {
            BackgroundColor3 = Color3.new(1,1,1),
            Size = UDim2.fromScale(1,1),
            ZIndex = svBox.ZIndex + 1,
            Parent = svBox,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = whiteOverlay })
        local whiteGrad = Instance.new("UIGradient")
        whiteGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),  -- left: opaque white
            NumberSequenceKeypoint.new(1, 1),  -- right: transparent
        })
        whiteGrad.Parent = whiteOverlay

        -- Black overlay: transparent at top, opaque at bottom — value axis
        local blackOverlay = New("Frame", {
            BackgroundColor3 = Color3.new(0,0,0),
            Size = UDim2.fromScale(1,1),
            ZIndex = svBox.ZIndex + 2,
            Parent = svBox,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = blackOverlay })
        local blackGrad = Instance.new("UIGradient")
        blackGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),  -- top: fully transparent (bright)
            NumberSequenceKeypoint.new(1, 0),  -- bottom: fully opaque black (dark)
        })
        blackGrad.Rotation = 90  -- 270° = top transparent → bottom opaque
        blackGrad.Parent = blackOverlay

        -- SV cursor: top-left = white (S=0,V=1), bottom-right = black (S=1,V=0)
        -- X axis = saturation (0→1 left→right), Y axis = value (1→0 top→bottom)
        local svCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1,1,1),
            Position = UDim2.fromScale(S, 1-V),  -- X=S, Y=1-V (top=bright)
            Size     = UDim2.fromOffset(10, 10),
            ZIndex   = svBox.ZIndex + 3,
            Parent   = svBox,
        })
        New("UICorner", { CornerRadius = UDim.new(1,0), Parent = svCursor })
        New("UIStroke", { Color = Color3.new(0,0,0), Thickness = 1.5, Parent = svCursor })

        -- ── Hue Bar ─────────────────────────────────────────────────────
        local hueBar = New("TextButton", {
            Size = UDim2.fromOffset(IW, BAR_H),
            Text = "",
            LayoutOrder = 2,
            Parent = menuFrame,
        })
        New("UICorner", { CornerRadius = UDim.new(1,0), Parent = hueBar })
        local hueGrad = Instance.new("UIGradient")
        hueGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0/6, Color3.fromHSV(0/6,1,1)),
            ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6,1,1)),
            ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6,1,1)),
            ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6,1,1)),
            ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6,1,1)),
            ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6,1,1)),
            ColorSequenceKeypoint.new(1,   Color3.fromHSV(1,  1,1)),
        })
        hueGrad.Parent = hueBar

        local hueCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1,1,1),
            Position = UDim2.fromScale(H, 0.5),
            Size     = UDim2.fromOffset(6, BAR_H + 4),
            ZIndex   = hueBar.ZIndex + 1,
            Parent   = hueBar,
        })
        New("UICorner", { CornerRadius = UDim.new(0,2), Parent = hueCursor })
        New("UIStroke", { Color = Color3.new(0,0,0), Thickness = 1, Parent = hueCursor })

        -- ── Alpha Bar ────────────────────────────────────────────────────
        local alphaBar = New("TextButton", {
            Size = UDim2.fromOffset(IW, BAR_H),
            Text = "",
            ClipsDescendants = true,
            LayoutOrder = 3,
            Parent = menuFrame,
        })
        New("UICorner", { CornerRadius = UDim.new(1,0), Parent = alphaBar })

        -- Checkerboard tiles to indicate transparency
        for col = 0, 7 do
            for row = 0, 1 do
                local isDark = (col + row) % 2 == 0
                New("Frame", {
                    BackgroundColor3 = isDark and Color3.fromRGB(160,160,160) or Color3.fromRGB(220,220,220),
                    BorderSizePixel  = 0,
                    Position         = UDim2.fromOffset(col * (IW/8), row * (BAR_H/2)),
                    Size             = UDim2.fromOffset(math.ceil(IW/8)+1, math.ceil(BAR_H/2)+1),
                    ZIndex           = alphaBar.ZIndex,
                    Parent           = alphaBar,
                })
            end
        end

        -- Color gradient overlay (from transparent to opaque)
        local alphaFill = New("Frame", {
            BackgroundColor3 = Color3.fromHSV(H, S, V),
            Size = UDim2.fromScale(1,1),
            ZIndex = alphaBar.ZIndex + 1,
            Parent = alphaBar,
        })
        New("UICorner", { CornerRadius = UDim.new(1,0), Parent = alphaFill })
        local alphaGrad = Instance.new("UIGradient")
        alphaGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0) })
        alphaGrad.Parent = alphaFill

        local alphaCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1,1,1),
            Position = UDim2.fromScale(A, 0.5),
            Size     = UDim2.fromOffset(6, BAR_H + 4),
            ZIndex   = alphaBar.ZIndex + 2,
            Parent   = alphaBar,
        })
        New("UICorner", { CornerRadius = UDim.new(0,2), Parent = alphaCursor })
        New("UIStroke", { Color = Color3.new(0,0,0), Thickness = 1, Parent = alphaCursor })

        -- ── Bottom row: HEX input + preview swatch ──────────────────────
        local bottomRow = New("Frame", {
            BackgroundTransparency = 1,
            Size      = UDim2.new(1, 0, 0, 22),
            LayoutOrder = 4,
            Parent    = menuFrame,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = bottomRow,
        })

        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(24, 22),
            Text = "HEX",
            TextSize = Tokens.FontSize.XS,
            TextColor3 = "TextMuted",
            LayoutOrder = 1,
            Parent = bottomRow,
        })

        local hexBox = New("TextBox", {
            BackgroundColor3 = "BackgroundColor",
            ClearTextOnFocus = false,
            Size = UDim2.new(1, -56, 1, 0),
            Text = string.format("%02X%02X%02X",
                math.round(ColorPicker.Value.R*255),
                math.round(ColorPicker.Value.G*255),
                math.round(ColorPicker.Value.B*255)),
            TextSize = Tokens.FontSize.XS,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            Parent = bottomRow,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = hexBox })
        New("UIPadding", { PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4), Parent = hexBox })

        -- Preview swatch: checkerboard base + colored overlay to show real transparency
        local previewHolder = New("Frame", {
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Size = UDim2.fromOffset(22, 22),
            LayoutOrder = 3,
            Parent = bottomRow,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = previewHolder })
        New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = previewHolder })
        for col = 0, 1 do
            for row = 0, 1 do
                local isDark = (col + row) % 2 == 0
                local tile = Instance.new("Frame")
                tile.BackgroundColor3 = isDark and Color3.fromRGB(160,160,160) or Color3.fromRGB(220,220,220)
                tile.BorderSizePixel  = 0
                tile.Position         = UDim2.fromOffset(col * 11, row * 11)
                tile.Size             = UDim2.fromOffset(11, 11)
                tile.Parent           = previewHolder
            end
        end
        local previewSwatch = New("Frame", {
            BackgroundColor3       = ColorPicker.Value,
            BackgroundTransparency = 1 - A,
            Size                   = UDim2.fromScale(1, 1),
            Parent                 = previewHolder,
        })

        -- ── Helpers ──────────────────────────────────────────────────────
        local function hexFromCurrent()
            return string.format("%02X%02X%02X",
                math.round(ColorPicker.Value.R*255),
                math.round(ColorPicker.Value.G*255),
                math.round(ColorPicker.Value.B*255))
        end

        local function updateAlphaFill()
            alphaFill.BackgroundColor3 = Color3.fromHSV(H, S, V)
        end

        -- Override updateColor to also refresh alpha bar and preview
        local baseUpdateColor = updateColor
        updateColor = function(nh, ns, nv)
            baseUpdateColor(nh, ns, nv)
            updateAlphaFill()
            previewSwatch.BackgroundColor3 = ColorPicker.Value
            previewSwatch.BackgroundTransparency = 1 - A
            hexBox.Text = hexFromCurrent()
            ColorPicker.Alpha = A
        end

        -- ── Drag: SV ──────────────────────────────────────────────────
        local svDragging = false
        maid:Connect(svBox.InputBegan, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            svDragging = true
        end)
        maid:Connect(UserInputService.InputChanged, function(input)
            if not svDragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local abs  = svBox.AbsolutePosition
            local size = svBox.AbsoluteSize
            local ns = math.clamp((Mouse.X - abs.X) / size.X, 0, 1)
            local nv = 1 - math.clamp((Mouse.Y - abs.Y) / size.Y, 0, 1)
            svCursor.Position = UDim2.fromScale(ns, 1-nv)
            updateColor(H, ns, nv)
        end)
        maid:Connect(UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = false end
        end)

        -- ── Drag: Hue ─────────────────────────────────────────────────
        local hueDragging = false
        maid:Connect(hueBar.InputBegan, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            hueDragging = true
        end)
        maid:Connect(UserInputService.InputChanged, function(input)
            if not hueDragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local abs  = hueBar.AbsolutePosition
            local size = hueBar.AbsoluteSize
            local nh = math.clamp((Mouse.X - abs.X) / size.X, 0, 1)
            hueCursor.Position = UDim2.fromScale(nh, 0.5)
            svBox.BackgroundColor3 = Color3.fromHSV(nh, 1, 1)
            updateColor(nh, S, V)
        end)
        maid:Connect(UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = false end
        end)

        -- ── Drag: Alpha ───────────────────────────────────────────────
        local alphaDragging = false
        maid:Connect(alphaBar.InputBegan, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            alphaDragging = true
        end)
        maid:Connect(UserInputService.InputChanged, function(input)
            if not alphaDragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local abs  = alphaBar.AbsolutePosition
            local size = alphaBar.AbsoluteSize
            A = math.clamp((Mouse.X - abs.X) / size.X, 0, 1)
            alphaCursor.Position = UDim2.fromScale(A, 0.5)
            previewSwatch.BackgroundTransparency = 1 - A
            swatch.BackgroundTransparency = 1 - A
            ColorPicker.Alpha = A
            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value, A)
            for _, fn in ipairs(ColorPicker._changedListeners) do
                Library:SafeCallback(fn, ColorPicker.Value, A)
            end
        end)
        maid:Connect(UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then alphaDragging = false end
        end)

        -- ── Hex input ─────────────────────────────────────────────────
        maid:Connect(hexBox.FocusLost, function()
            local hex = hexBox.Text:gsub("#",""):upper()
            if #hex == 6 then
                local r = tonumber(hex:sub(1,2),16)
                local g = tonumber(hex:sub(3,4),16)
                local b = tonumber(hex:sub(5,6),16)
                if r and g and b then
                    local nc = Color3.fromRGB(r,g,b)
                    H, S, V = nc:ToHSV()
                    updateColor(H, S, V)
                    svBox.BackgroundColor3 = Color3.fromHSV(H,1,1)
                    svCursor.Position = UDim2.fromScale(S, 1-V)
                    hueCursor.Position = UDim2.fromScale(H, 0.5)
                end
            end
            hexBox.Text = hexFromCurrent()
        end)

        -- Fade in
        menuFrame.BackgroundTransparency = 1
        TweenService:Create(menuFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad),
            { BackgroundTransparency = 0 }):Play()

        -- Close on outside click
        maid:Connect(UserInputService.InputBegan, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            if not menuFrame or not menuFrame.Parent then return end
            local pos  = menuFrame.AbsolutePosition
            local size = menuFrame.AbsoluteSize
            if Mouse.X < pos.X or Mouse.X > pos.X + size.X
                or Mouse.Y < pos.Y or Mouse.Y > pos.Y + size.Y then
                closeMenu()
            end
        end)
    end

    maid:Connect(swatch.MouseButton1Click, function()
        if menuOpen then closeMenu() else openMenu() end
    end)

    function ColorPicker:SetValue(color, alpha)
        self.Value = color
        if alpha ~= nil then A = alpha; self.Alpha = alpha end
        H, S, V = color:ToHSV()
        swatch.BackgroundColor3       = color
        swatch.BackgroundTransparency = 1 - A
        Library:SafeCallback(self.Callback, color, A)
        Library:SafeCallback(self.Changed,  color, A)
    end

    function ColorPicker:OnChanged(fn)
        table.insert(self._changedListeners, fn)
    end

    function ColorPicker:SetDisabled(v)
        self.Disabled = v
        swatch.Active = not v
    end

    function ColorPicker:SetVisible(v)
        self.Visible = v
        holder.Visible = v
        ColorPicker._groupbox:Resize()
    end

    function ColorPicker:SetText(t)
        self.Text = t
        nameLabel.Text = t
    end

    ColorPicker.Alpha    = 1
    ColorPicker._groupbox = self
    self:Resize()
    if idx then Library.Options[idx] = ColorPicker end
    table.insert(self.Elements, ColorPicker)
    ColorPicker.Default = ColorPicker.Value
    return ColorPicker
end

-- ─── Key Picker ────────────────────────────────────────────────────────────
function BaseGroupbox:AddKeyPicker(idx, info)
    info = Library:Validate(info, {
        Text     = "Keybind",
        Default  = "None",
        Mode     = "Toggle",   -- "Toggle" | "Hold" | "Always"
        Modes    = { "Toggle", "Hold", "Always" },
        Callback = function() end,
        Changed  = function() end,
        Disabled = false,
        Visible  = true,
        Blacklisted = {},
        NoUI     = false,      -- if true, don't show in keybind frame
    })

    local container = self.Container
    local maid      = Maid.New()
    local picking   = false
    local menuOpen  = false
    local menuFrame = nil

    local SPECIAL_KEYS = {
        ["MB1"] = Enum.UserInputType.MouseButton1,
        ["MB2"] = Enum.UserInputType.MouseButton2,
    }
    local SPECIAL_INPUT = {
        [Enum.UserInputType.MouseButton1] = "MB1",
        [Enum.UserInputType.MouseButton2] = "MB2",
    }

    local holder = New("Frame", {
        BackgroundTransparency = 1,
        Size    = UDim2.new(1, 0, 0, 20),
        Visible = info.Visible,
        Parent  = container,
    })

    New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -70, 1, 0),
        Text = info.Text,
        TextSize = Tokens.FontSize.MD,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder,
    })

    -- Key display button
    local keyBtn = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = "SurfaceColor",
        Position = UDim2.new(1, 0, 0.5, 0),
        Size     = UDim2.fromOffset(64, 16),
        Text     = info.Default,
        TextSize = Tokens.FontSize.XS,
        Parent   = holder,
    })
    New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = keyBtn })
    New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = keyBtn })

    local KeyPicker = setmetatable({
        Text       = info.Text,
        Value      = info.Default,
        Mode       = info.Mode,
        Modes      = info.Modes,
        Toggled    = false,
        Disabled   = info.Disabled,
        Visible    = info.Visible,
        Callback   = info.Callback,
        Changed    = info.Changed,
        Type       = "KeyPicker",
        Holder     = holder,
        _maid      = maid,
        _changedListeners = {},
    }, ComponentBase)

    local function getDisplayText()
        if picking then return "..." end
        return KeyPicker.Value == "None" and "[ None ]" or "[ " .. KeyPicker.Value .. " ]"
    end

    local function refreshDisplay()
        keyBtn.Text = getDisplayText()
        if picking then
            keyBtn.TextColor3 = Library.Scheme.AccentColor
        else
            keyBtn.TextColor3 = Library.Scheme.TextMuted
        end
    end

    local function closeMenu()
        if not menuFrame then return end
        menuOpen = false
        local m = menuFrame; menuFrame = nil
        TweenService:Create(m, TweenInfo.new(0.1, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
        task.delay(0.12, function() if m and m.Parent then m:Destroy() end end)
    end

    local function openMenu()
        if menuOpen or KeyPicker.Disabled then return end
        menuOpen = true

        local abs  = keyBtn.AbsolutePosition
        local absH = keyBtn.AbsoluteSize.Y
        local rowH = 26
        local menuH = #KeyPicker.Modes * rowH + 8

        menuFrame = New("Frame", {
            BackgroundColor3 = "SurfaceColor",
            Position = UDim2.fromOffset(abs.X, abs.Y + absH + 4),
            Size     = UDim2.fromOffset(110, menuH),
            ZIndex   = ZManager.Get("dropdown"),
            Parent   = ScreenGui,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusMD), Parent = menuFrame })
        New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = menuFrame })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
            Parent = menuFrame,
        })
        New("UIListLayout", { Padding = UDim.new(0, 2), Parent = menuFrame })

        for _, modeName in ipairs(KeyPicker.Modes) do
            local isCurrent = modeName == KeyPicker.Mode
            local row = New("TextButton", {
                BackgroundColor3       = isCurrent and "AccentSubtle" or "SurfaceColor",
                BackgroundTransparency = isCurrent and 0 or 1,
                Size   = UDim2.new(1, 0, 0, rowH),
                Text   = "",
                Parent = menuFrame,
            })
            New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = row })
            New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = row })
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = modeName,
                TextSize = Tokens.FontSize.SM,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = isCurrent and "AccentColor" or "TextPrimary",
                Parent = row,
            })
            row.MouseEnter:Connect(function()
                row.BackgroundTransparency = 0
                row.BackgroundColor3 = Library.Scheme.SurfaceAltColor
            end)
            row.MouseLeave:Connect(function()
                if KeyPicker.Mode ~= modeName then
                    row.BackgroundTransparency = 1
                end
            end)
            row.MouseButton1Click:Connect(function()
                KeyPicker.Mode = modeName
                closeMenu()
            end)
        end

        menuFrame.BackgroundTransparency = 1
        TweenService:Create(menuFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad),
            { BackgroundTransparency = 0 }):Play()

        maid:Connect(UserInputService.InputBegan, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            if not menuFrame or not menuFrame.Parent then return end
            local pos  = menuFrame.AbsolutePosition
            local size = menuFrame.AbsoluteSize
            if Mouse.X < pos.X or Mouse.X > pos.X + size.X
                or Mouse.Y < pos.Y or Mouse.Y > pos.Y + size.Y then
                closeMenu()
            end
        end)
    end

    -- Left click: start picking key
    maid:Connect(keyBtn.MouseButton1Click, function()
        if KeyPicker.Disabled then return end
        if picking then
            picking = false
            refreshDisplay()
            return
        end
        picking = true
        refreshDisplay()
    end)

    -- Right click: open mode menu
    maid:Connect(keyBtn.MouseButton2Click, function()
        if KeyPicker.Disabled then return end
        if menuOpen then closeMenu() else openMenu() end
    end)

    -- Listen for key input when picking
    maid:Connect(UserInputService.InputBegan, function(input, gpe)
        if not picking then return end

        local keyName
        if SPECIAL_INPUT[input.UserInputType] then
            keyName = SPECIAL_INPUT[input.UserInputType]
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            keyName = input.KeyCode.Name
        else
            return
        end

        -- Escape cancels
        if input.KeyCode == Enum.KeyCode.Escape then
            picking = false
            refreshDisplay()
            return
        end

        -- Check blacklist
        for _, bl in ipairs(info.Blacklisted) do
            if bl == keyName then
                picking = false
                refreshDisplay()
                return
            end
        end

        picking = false
        KeyPicker.Value = keyName
        refreshDisplay()

        -- If this keybind controls the window toggle, update Library immediately
        if idx == "toggleKey" then
            local ok, kc = pcall(function()
                return Enum.KeyCode[keyName]
            end)
            if ok and kc then
                Library.ToggleKeybind = kc
            end
        end

        Library:SafeCallback(KeyPicker.Changed, keyName)
        for _, fn in ipairs(KeyPicker._changedListeners) do
            Library:SafeCallback(fn, keyName)
        end
    end)

    -- Handle toggle/hold firing
    maid:Connect(UserInputService.InputBegan, function(input, gpe)
        if picking or KeyPicker.Disabled or KeyPicker.Value == "None" then return end
        local keyName
        if SPECIAL_INPUT[input.UserInputType] then
            keyName = SPECIAL_INPUT[input.UserInputType]
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            keyName = input.KeyCode.Name
        end
        if keyName ~= KeyPicker.Value then return end

        if KeyPicker.Mode == "Toggle" then
            KeyPicker.Toggled = not KeyPicker.Toggled
            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
        elseif KeyPicker.Mode == "Hold" then
            KeyPicker.Toggled = true
            Library:SafeCallback(KeyPicker.Callback, true)
        elseif KeyPicker.Mode == "Always" then
            Library:SafeCallback(KeyPicker.Callback, true)
        end
    end)

    maid:Connect(UserInputService.InputEnded, function(input)
        if KeyPicker.Disabled or KeyPicker.Value == "None" then return end
        if KeyPicker.Mode ~= "Hold" then return end
        local keyName
        if SPECIAL_INPUT[input.UserInputType] then
            keyName = SPECIAL_INPUT[input.UserInputType]
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            keyName = input.KeyCode.Name
        end
        if keyName == KeyPicker.Value and KeyPicker.Toggled then
            KeyPicker.Toggled = false
            Library:SafeCallback(KeyPicker.Callback, false)
        end
    end)

    function KeyPicker:SetValue(keyName, fireCallback)
        self.Value = keyName
        refreshDisplay()
        if fireCallback then
            Library:SafeCallback(self.Changed, keyName)
            for _, fn in ipairs(self._changedListeners) do
                Library:SafeCallback(fn, keyName)
            end
        end
    end

    function KeyPicker:OnChanged(fn)
        table.insert(self._changedListeners, fn)
    end

    function KeyPicker:SetDisabled(v)
        self.Disabled = v
        keyBtn.Active = not v
    end

    function KeyPicker:SetVisible(v)
        self.Visible = v
        holder.Visible = v
        KeyPicker._groupbox:Resize()
    end

    function KeyPicker:IsActive()
        if self.Mode == "Always" then return true end
        return self.Toggled
    end

    Micro.PressDepression(keyBtn, maid)
    refreshDisplay()

    KeyPicker._groupbox = self
    self:Resize()
    if idx then Library.Options[idx] = KeyPicker end
    table.insert(self.Elements, KeyPicker)
    KeyPicker.Default = KeyPicker.Value
    return KeyPicker
end

-- ─── UpdateDependencyBoxes (library-level) ─────────────────────────────────
function Library:UpdateDependencyBoxes()
    EventBus:Emit("dependencyUpdate")
end

-- ─── Built-in Settings Panel Content ───────────────────────────────────────
--[[
    Populates a Window's Settings panel with the standard NexusUI sections:
      • Appearance — theme dropdown, menu transparency, acrylic toggle
      • Keybinds   — UI toggle keybind picker
      • Configs    — create / save / load / set default / delete configs
                      (also persists window size & position, see ConfigSystem)
      • Misc       — debug overlay toggle, unload button

    This runs automatically from CreateWindow when `BuiltinSettings` (default
    true) is left on. The returned Settings object is the same one passed in,
    so user scripts can keep calling Settings:AddLeftGroupbox / 
    Settings:AddRightGroupbox to append their own sections alongside these.
]]
local function PopulateBuiltinSettings(Window, Settings)
    local UI = Library

    -- ── Appearance ──────────────────────────────────────────────────────
    local Appearance = Settings:AddLeftGroupbox("Appearance")

    local themeNames = {}
    for name in pairs(ThemeEngine.BuiltinThemes) do
        table.insert(themeNames, name)
    end
    table.sort(themeNames)

    Appearance:AddDropdown("nx_themeDrop", {
        Text     = "Theme",
        Values   = themeNames,
        Default  = ThemeEngine.ActiveThemeName,
        Callback = function(v) UI:SetTheme(v, nil, true) end,
    })
    Appearance:AddSlider("nx_menuTransparency", {
        Text     = "Menu Transparency",
        Default  = 18,
        Min      = 0,
        Max      = 80,
        Rounding = 0,
        Suffix   = "%",
        Callback = function(v) Window:SetMenuTransparency(v) end,
    })
    Appearance:AddToggle("nx_acrylicToggle", {
        Text     = "Acrylic / Blur Background",
        Default  = false,
        Callback = function(v) Window:SetAcrylicEnabled(v) end,
    })
    Appearance:AddToggle("nx_particlesToggle", {
        Text     = "Particle Effects",
        Default  = true,
        Callback = function(v) Window:SetParticlesEnabled(v) end,
    })
    Appearance:AddDropdown("nx_dpiScale", {
        Text     = "DPI Scale",
        Values   = { "50%", "75%", "100%", "125%", "150%" },
        Default  = "100%",
        Callback = function(v)
            local pct = tonumber(v:match("(%d+)"))
            if pct then UI:SetDPIScale(pct) end
        end,
    })

    -- ── Keybinds ─────────────────────────────────────────────────────────
    local Keybinds = Settings:AddRightGroupbox("Keybinds")
    Keybinds:AddKeyPicker("nx_toggleKey", {
        Text     = "Toggle UI",
        Default  = Library.ToggleKeybind and Library.ToggleKeybind.Name or "RightControl",
        Mode     = "Toggle",
        Callback = function() end,
        Changed  = function(v)
            local key = Enum.KeyCode[v]
            if key then Library.ToggleKeybind = key end
        end,
    })

    -- ── Configs ──────────────────────────────────────────────────────────
    local Configs = Settings:AddLeftGroupbox("Configs")

    local function refreshConfigList()
        local files = UI.Config.List()
        local vals  = #files > 0 and files or { "(none)" }
        if UI.Options.nx_configSelect then
            UI.Options.nx_configSelect:SetValues(vals)
            if #files > 0 then UI.Options.nx_configSelect:SetValue(files[1]) end
        end
    end

    Configs:AddInput("nx_configName", {
        Text        = "New Config Name",
        Default     = "default",
        Placeholder = "my_config",
        Finished    = false,
    })
    Configs:AddButton("nx_createConfigBtn", {
        Text     = "Create Config",
        Variant  = "Primary",
        Callback = function()
            local name = (UI.Options.nx_configName and UI.Options.nx_configName.Value) or ""
            if name == "" then
                UI.Toast.Warning("Enter a config name.", { Duration = 2 })
                return
            end
            if UI.Config.Exists(name) then
                UI.Toast.Warning("Config '" .. name .. "' already exists.", { Duration = 2.5 })
                return
            end
            local ok, err = pcall(function() UI.Config.Save(name) end)
            if ok then
                refreshConfigList()
                if UI.Options.nx_configSelect then UI.Options.nx_configSelect:SetValue(name) end
                UI.Toast.Success("Created: " .. name, { Duration = 2 })
            else
                UI.Toast.Error(tostring(err):sub(1, 60), { Duration = 3 })
            end
        end,
    })

    local configFiles = UI.Config.List()
    Configs:AddDropdown("nx_configSelect", {
        Text    = "Saved Configs",
        Values  = #configFiles > 0 and configFiles or { "(none)" },
        Default = #configFiles > 0 and configFiles[1] or "(none)",
    })

    Configs:AddButton("nx_saveConfigBtn", {
        Text     = "Save Config",
        Variant  = "Secondary",
        Callback = function()
            local sel = UI.Options.nx_configSelect and UI.Options.nx_configSelect.Value
            if not sel or sel == "(none)" then
                UI.Toast.Warning("No config selected to save.", { Duration = 2 })
                return
            end
            local ok, err = pcall(function() UI.Config.Save(sel) end)
            if ok then
                UI.Toast.Success("Saved: " .. sel .. " (incl. window size)", { Duration = 2 })
            else
                UI.Toast.Error(tostring(err):sub(1, 60), { Duration = 3 })
            end
        end,
    })
    Configs:AddButton("nx_loadConfigBtn", {
        Text     = "Load Selected",
        Variant  = "Secondary",
        Callback = function()
            local sel = UI.Options.nx_configSelect and UI.Options.nx_configSelect.Value
            if not sel or sel == "(none)" then
                UI.Toast.Warning("No config selected.", { Duration = 2 })
                return
            end
            -- Load returns (ok, report). report.missing / report.unset list any
            -- toggles/options that don't line up between the saved config and
            -- the current UI — automatically toasted via "configIntegrity" too.
            local ok = UI.Config.Load(sel)
            if ok then
                UI.Toast.Success("Loaded: " .. sel, { Duration = 2 })
            else
                UI.Toast.Warning("Not found: " .. sel, { Duration = 2 })
            end
        end,
    })
    Configs:AddButton("nx_setDefaultConfigBtn", {
        Text     = "Set as Default",
        Variant  = "Secondary",
        Callback = function()
            local sel = UI.Options.nx_configSelect and UI.Options.nx_configSelect.Value
            if not sel or sel == "(none)" then
                UI.Toast.Warning("No config selected.", { Duration = 2 })
                return
            end
            UI.Config.SetDefault(sel)
            UI.Toast.Success("Default config: " .. sel, { Duration = 2 })
        end,
    })
    Configs:AddButton("nx_deleteConfigBtn", {
        Text     = "Delete Selected",
        Variant  = "Danger",
        Callback = function()
            local sel = UI.Options.nx_configSelect and UI.Options.nx_configSelect.Value
            if not sel or sel == "(none)" then return end
            UI.Config.Delete(sel)
            refreshConfigList()
            UI.Toast.Info("Deleted: " .. sel, { Duration = 2 })
        end,
    })

    -- ── Misc ─────────────────────────────────────────────────────────────
    local Misc = Settings:AddRightGroupbox("Misc")
    Misc:AddToggle("nx_debugOverlay", {
        Text     = "Debug Overlay",
        Default  = false,
        Callback = function(v)
            if DebugOverlay.IsVisible() ~= v then
                DebugOverlay.Toggle()
            end
        end,
    })
    Misc:AddButton("nx_unloadBtn", {
        Text     = "Unload UI",
        Variant  = "Danger",
        Callback = function()
            UI.Toast.Warning("Unloading NexusUI...", { Duration = 1.5 })
            task.delay(0.2, function() Library:Unload() end)
        end,
    })

    -- Command palette entries for the built-in config actions
    CommandPalette.Register({ name = "Open Settings", category = "UI",     action = function() Settings:Show() end })
    CommandPalette.Register({ name = "Save Config",   category = "Config", action = function() UI.Config.Save("default") end })
    CommandPalette.Register({ name = "Load Config",   category = "Config", action = function() UI.Config.Load("default") end })
    CommandPalette.Register({ name = "Unload UI",      category = "UI",     action = function() Library:Unload() end })
end

-- ─── Main Window Constructor ────────────────────────────────────────────────
function Library:CreateWindow(info)
    info = Library:Validate(info, {
        Title          = "NexusUI",
        Footer         = "",
        Position       = UDim2.fromOffset(80, 80),
        Size           = UDim2.fromOffset(720, 540),
        Center         = true,
        Resizable      = true,
        CornerRadius   = Tokens.RadiusMD,
        ToggleKeybind  = Enum.KeyCode.RightControl,
        AutoShow       = true,
        PageTransition = "fade",  -- "fade" | "slide" | "scale"
        ShowCustomCursor = true,
        NotifySide     = "Right",
        Font           = Enum.Font.Gotham,
        BuiltinSettings = true,  -- auto-populate AddSettingsPanel with Appearance/Configs/Misc
        ConfigFolder   = "NexusUI",  -- folder name under workspace for config files
    })

    Library.ToggleKeybind    = info.ToggleKeybind
    Library.ShowCustomCursor = info.ShowCustomCursor
    Library.ConfigFolder     = info.ConfigFolder

    local windowMaid = Maid.New()
    LibraryMaid:Give(windowMaid)

    -- Layout constants
    local TH  = 42   -- titlebar height
    local SW  = 152  -- sidebar width
    local FH  = 22   -- footer height
    local CR  = info.CornerRadius

    -- ── Main Frame ───────────────────────────────────────────────────────
    local mainFrame = New("Frame", {
        AnchorPoint      = info.Center and Vector2.new(0.5, 0.5) or Vector2.zero,
        BackgroundColor3 = "BackgroundColor",
        BackgroundTransparency = 0.18,
        Position         = info.Center and UDim2.fromScale(0.5, 0.5) or info.Position,
        Size             = info.Size,
        Visible          = false,
        ClipsDescendants = true,
        Parent           = ScreenGui,
    })
    New("UICorner",  { CornerRadius = UDim.new(0, CR), Parent = mainFrame })
    New("UIStroke",  { Color = "BorderColor", Thickness = 1, Transparency = 0.5, Parent = mainFrame })
    ZManager.Apply(mainFrame, "float")

    -- DPI Scale — resize the window frame AND compensate TextSize so text
    -- stays visually identical to 100% at every scale level.
    local _dpiBaseSize = info.Size  -- the "100%" reference size
    local _applyingDPI = false       -- guard: don't treat DPI-driven resizes as manual

    -- Snapshot original TextSize for every text element inside mainFrame once,
    -- then reapply them corrected by 1/scale so they appear the same size.
    local _textBaseSizes = nil  -- populated lazily on first DPI change
    local function snapshotTextSizes()
        _textBaseSizes = {}
        local textClasses = { "TextLabel", "TextButton", "TextBox" }
        for _, cls in ipairs(textClasses) do
            for _, inst in ipairs(mainFrame:GetDescendants()) do
                if inst:IsA(cls) and inst.TextSize > 0 then
                    _textBaseSizes[inst] = inst.TextSize
                end
            end
        end
    end
    local function applyTextSizes(s)
        if not _textBaseSizes then snapshotTextSizes() end
        local inv = 1 / math.max(0.1, s)
        for inst, base in pairs(_textBaseSizes) do
            if inst and inst.Parent then
                pcall(function() inst.TextSize = math.round(base * inv) end)
            else
                _textBaseSizes[inst] = nil  -- clean up destroyed instances
            end
        end
    end

    local function applyDPISize(s)
        _applyingDPI = true
        -- If a config restore has set a new base size, adopt it
        if Window._restoreBaseSize then
            _dpiBaseSize = Window._restoreBaseSize
            Window._restoreBaseSize = nil
        end
        local baseX = _dpiBaseSize.X.Offset
        local baseY = _dpiBaseSize.Y.Offset
        local newSize = UDim2.fromOffset(
            math.round(baseX * s),
            math.round(baseY * s)
        )
        TweenService:Create(mainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { Size = newSize }):Play()
        applyTextSizes(s)
        task.delay(0.2, function() _applyingDPI = false end)
    end
    windowMaid:Give(EventBus:On("dpiChange", applyDPISize))
    -- When the user manually resizes, update the base size so DPI changes
    -- stay relative to the new manual size rather than the original.
    windowMaid:Give(mainFrame:GetPropertyChangedSignal("Size"):Connect(function()
        if _applyingDPI then return end
        local s = Library.DPIScale
        if s and s > 0 then
            _dpiBaseSize = UDim2.fromOffset(
                math.round(mainFrame.Size.X.Offset / s),
                math.round(mainFrame.Size.Y.Offset / s)
            )
        end
    end))

    -- Frosted glass layers: stacked semi-transparent tints to fake acrylic blur
    -- localized to the menu (Roblox BlurEffect is screen-wide, so this is the
    -- closest approximation without affecting the whole game view).
    local frostLayer1 = New("Frame", {
        BackgroundColor3 = "SurfaceColor",
        BackgroundTransparency = 0.85,
        Size = UDim2.fromScale(1, 1),
        ZIndex = mainFrame.ZIndex,
        Parent = mainFrame,
    })
    local frostLayer2 = New("Frame", {
        BackgroundColor3 = "AccentColor",
        BackgroundTransparency = 0.95,
        Size = UDim2.fromScale(1, 1),
        ZIndex = mainFrame.ZIndex,
        Parent = mainFrame,
    })
    local frostGrad = Instance.new("UIGradient")
    frostGrad.Rotation = 45
    frostGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.8),
        NumberSequenceKeypoint.new(1, 0.3),
    })
    frostGrad.Parent = frostLayer2

    -- ── Particle Network Field ──────────────────────────────────────────
    --[[
        Connected-dots network effect: dots drift around and thin lines are
        drawn between any two dots closer than CONNECT_DIST px. Line opacity
        scales with proximity (closer = more opaque). Runs on Heartbeat so
        positions and lines update every frame. Everything is destroyed (not
        just hidden) when the menu closes or particles are toggled off.
    ]]
    local particleField = New("Frame", {
        BackgroundTransparency = 1,
        Size             = UDim2.fromScale(1, 1),
        ZIndex           = mainFrame.ZIndex,
        ClipsDescendants = true,
        Parent           = mainFrame,
    })

    local PARTICLE_COUNT = 40       -- number of dots
    local CONNECT_DIST   = 120      -- px — max distance to draw a line
    local DOT_SPEED      = 28       -- px/s base speed
    local DOT_MIN_SIZE   = 2
    local DOT_MAX_SIZE   = 4
    local DOT_ALPHA      = 0.55     -- dot transparency (lower = more visible)
    local LINE_MAX_ALPHA = 0.72     -- line transparency at closest distance

    local _particlesSpawned = false
    local _heartbeatConn    = nil
    local _dots             = {}    -- { inst, x, y, vx, vy, size }
    local _lines            = {}    -- pool of line frames

    -- Line pool: reuse frames instead of creating/destroying every frame
    local function getLine()
        for _, l in ipairs(_lines) do
            if not l._inUse then
                l._inUse = true
                l.inst.Visible = true
                return l
            end
        end
        -- Allocate a new one
        local inst = New("Frame", {
            AnchorPoint      = Vector2.new(0, 0.5),
            BackgroundColor3 = "AccentColor",
            BorderSizePixel  = 0,
            ZIndex           = particleField.ZIndex,
            Parent           = particleField,
        })
        local l = { inst = inst, _inUse = true }
        table.insert(_lines, l)
        return l
    end

    local function returnLines()
        for _, l in ipairs(_lines) do
            l._inUse = false
            l.inst.Visible = false
        end
    end

    local function spawnParticles()
        if _particlesSpawned then return end
        _particlesSpawned = true

        local w = mainFrame.AbsoluteSize.X
        local h = mainFrame.AbsoluteSize.Y

        -- Create dots
        for i = 1, PARTICLE_COUNT do
            local sz  = math.random(DOT_MIN_SIZE, DOT_MAX_SIZE)
            local spd = DOT_SPEED * (0.6 + math.random() * 0.8)
            local ang = math.random() * math.pi * 2
            local inst = New("Frame", {
                BackgroundColor3       = "AccentColor",
                BackgroundTransparency = DOT_ALPHA,
                Size     = UDim2.fromOffset(sz, sz),
                Position = UDim2.fromOffset(math.random() * w, math.random() * h),
                ZIndex   = particleField.ZIndex + 1,
                Parent   = particleField,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = inst })
            _dots[i] = {
                inst = inst,
                x    = math.random() * w,
                y    = math.random() * h,
                vx   = math.cos(ang) * spd,
                vy   = math.sin(ang) * spd,
                size = sz,
            }
        end

        -- Heartbeat: move dots + redraw lines every frame
        _heartbeatConn = RunService.Heartbeat:Connect(function(dt)
            if not mainFrame or not mainFrame.Parent then return end

            local fw = mainFrame.AbsoluteSize.X
            local fh = mainFrame.AbsoluteSize.Y
            if fw < 10 or fh < 10 then return end

            -- Move dots, bounce off edges
            for _, d in ipairs(_dots) do
                d.x = d.x + d.vx * dt
                d.y = d.y + d.vy * dt
                -- Bounce
                if d.x < 0       then d.x = 0;        d.vx = math.abs(d.vx)  end
                if d.x > fw      then d.x = fw;        d.vx = -math.abs(d.vx) end
                if d.y < 0       then d.y = 0;         d.vy = math.abs(d.vy)  end
                if d.y > fh      then d.y = fh;        d.vy = -math.abs(d.vy) end
                -- Apply position
                d.inst.Position = UDim2.fromOffset(d.x - d.size * 0.5, d.y - d.size * 0.5)
            end

            -- Draw lines between close pairs
            returnLines()
            local n = #_dots
            for i = 1, n - 1 do
                local a = _dots[i]
                for j = i + 1, n do
                    local b  = _dots[j]
                    local dx = b.x - a.x
                    local dy = b.y - a.y
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist < CONNECT_DIST then
                        local alpha = LINE_MAX_ALPHA + (1 - LINE_MAX_ALPHA) * (dist / CONNECT_DIST)
                        local l = getLine()
                        local angle = math.deg(math.atan2(dy, dx))
                        l.inst.Position            = UDim2.fromOffset(a.x, a.y)
                        l.inst.Size                = UDim2.fromOffset(dist, 1)
                        l.inst.Rotation            = angle
                        l.inst.BackgroundTransparency = alpha
                    end
                end
            end
        end)

        -- clearParticles handles disconnect; also register with maid for safety
        windowMaid:Give(function() if _heartbeatConn then _heartbeatConn:Disconnect() end end)
    end

    local function clearParticles()
        if _heartbeatConn then
            _heartbeatConn:Disconnect()
            _heartbeatConn = nil
        end
        for _, d in ipairs(_dots) do
            if d.inst and d.inst.Parent then d.inst:Destroy() end
        end
        _dots = {}
        for _, l in ipairs(_lines) do
            if l.inst and l.inst.Parent then l.inst:Destroy() end
        end
        _lines = {}
        _particlesSpawned = false
    end

    Library.ParticlesEnabled = true

    -- ── Titlebar ─────────────────────────────────────────────────────────
    local titleBar = New("Frame", {
        BackgroundColor3 = "SurfaceColor",
        BackgroundTransparency = 0.25,
        Size             = UDim2.new(1, 0, 0, TH),
        ZIndex           = mainFrame.ZIndex + 1,
        Parent           = mainFrame,
    })
    -- Bottom border line
    New("Frame", {
        AnchorPoint      = Vector2.new(0, 1),
        BackgroundColor3 = "BorderColor",
        Position         = UDim2.fromScale(0, 1),
        Size             = UDim2.new(1, 0, 0, 1),
        ZIndex           = titleBar.ZIndex,
        Parent           = titleBar,
    })

    -- Subtle accent shimmer: a soft gradient sliver that slowly sweeps
    -- across the titlebar's bottom edge. Purely cosmetic, single Frame +
    -- looping UIGradient offset tween — negligible cost.
    do
        local shimmer = New("Frame", {
            AnchorPoint      = Vector2.new(0, 1),
            BackgroundColor3 = "AccentColor",
            BackgroundTransparency = 0.5,
            Position         = UDim2.fromScale(0, 1),
            Size             = UDim2.new(1, 0, 0, 1),
            ZIndex           = titleBar.ZIndex,
            Parent           = titleBar,
        })
        local shimmerGrad = Instance.new("UIGradient")
        shimmerGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,    1),
            NumberSequenceKeypoint.new(0.45, 1),
            NumberSequenceKeypoint.new(0.5,  0),
            NumberSequenceKeypoint.new(0.55, 1),
            NumberSequenceKeypoint.new(1,    1),
        })
        shimmerGrad.Offset = Vector2.new(-1.5, 0)
        shimmerGrad.Parent = shimmer

        local shimmerInfo = TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false)
        TweenService:Create(shimmerGrad, shimmerInfo, { Offset = Vector2.new(1.5, 0) }):Play()
    end

    -- Title label: starts after a left pad, ends before close button
    local titleLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.fromOffset(16, 0),
        Size      = UDim2.new(1, -56, 1, 0),
        Text      = info.Title,
        TextSize  = Tokens.FontSize.XL,
        FontFace  = Font.new("rbxasset://fonts/families/GothamSSm.json",
            Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex    = titleBar.ZIndex,
        Parent    = titleBar,
    })

    -- Close button: pinned to right edge
    local closeBtn = New("TextButton", {
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(210, 40, 40),
        BackgroundTransparency = 1,
        Position         = UDim2.new(1, -12, 0.5, 0),
        Size             = UDim2.fromOffset(24, 24),
        Text             = "×",
        TextSize         = 16,
        TextColor3       = "TextMuted",
        ZIndex           = titleBar.ZIndex + 1,
        Parent           = titleBar,
    })
    New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = closeBtn })

    local tiClose = TweenInfo.new(0.12, Enum.EasingStyle.Quad)
    windowMaid:Connect(closeBtn.MouseEnter, function()
        TweenService:Create(closeBtn, tiClose, {
            BackgroundTransparency = 0,
            TextColor3 = Color3.new(1, 1, 1),
        }):Play()
    end)
    windowMaid:Connect(closeBtn.MouseLeave, function()
        TweenService:Create(closeBtn, tiClose, {
            BackgroundTransparency = 1,
            TextColor3 = Library.Scheme.TextMuted,
        }):Play()
    end)
    windowMaid:Connect(closeBtn.MouseButton1Click, function()
        Library:Toggle(false)
    end)

    -- ── Footer ───────────────────────────────────────────────────────────
    local footer = New("Frame", {
        AnchorPoint      = Vector2.new(0, 1),
        BackgroundColor3 = "SurfaceColor",
        Position         = UDim2.fromScale(0, 1),
        Size             = UDim2.new(1, 0, 0, FH),
        ZIndex           = mainFrame.ZIndex + 1,
        Parent           = mainFrame,
    })
    New("Frame", {  -- top border
        BackgroundColor3 = "BorderColor",
        Size             = UDim2.new(1, 0, 0, 1),
        ZIndex           = footer.ZIndex,
        Parent           = footer,
    })
    New("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.fromOffset(12, 0),
        Size      = UDim2.new(0.5, -12, 1, 0),
        Text      = info.Footer,
        TextSize  = Tokens.FontSize.XS,
        TextColor3 = "TextMuted",
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex    = footer.ZIndex,
        Parent    = footer,
    })
    New("TextLabel", {
        AnchorPoint    = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position       = UDim2.new(1, -12, 0, 0),
        Size           = UDim2.new(0.5, 0, 1, 0),
        Text           = "NexusUI v" .. LIBRARY_VERSION,
        TextSize       = Tokens.FontSize.XS,
        TextColor3     = "TextMuted",
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex         = footer.ZIndex,
        Parent         = footer,
    })

    -- ── Sidebar ───────────────────────────────────────────────────────────
    -- Sidebar: left column from below titlebar to above footer
    local sidebar = New("Frame", {
        BackgroundColor3 = "SurfaceColor",
        BackgroundTransparency = 0.2,
        Position         = UDim2.fromOffset(0, TH),
        Size             = UDim2.new(0, SW, 1, -(TH + FH)),
        ZIndex           = mainFrame.ZIndex + 1,
        Parent           = mainFrame,
    })
    New("Frame", {  -- right border
        AnchorPoint      = Vector2.new(1, 0),
        BackgroundColor3 = "BorderColor",
        Position         = UDim2.fromScale(1, 0),
        Size             = UDim2.new(0, 1, 1, 0),
        ZIndex           = sidebar.ZIndex,
        Parent           = sidebar,
    })

    -- Tab button list: leaves 42px at bottom for settings button + separator
    local tabList = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(6, 8),
        Size     = UDim2.new(1, -12, 1, -50),
        ZIndex   = sidebar.ZIndex,
        Parent   = sidebar,
    })
    New("UIListLayout", {
        Padding   = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent    = tabList,
    })

    -- Search box at bottom of sidebar (sits inside footer area on the left)
    local searchBox = New("TextBox", {
        BackgroundColor3 = "SurfaceColor",
        BackgroundTransparency = 0.3,
        Position         = UDim2.new(0, 0, 1, -(FH + 1)),
        Size             = UDim2.new(0, SW, 0, FH),
        PlaceholderText  = "⌕  Search…",
        ClearTextOnFocus = true,
        TextSize         = Tokens.FontSize.SM,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = mainFrame.ZIndex + 2,
        Parent           = mainFrame,
    })
    New("UIPadding", {
        PaddingLeft  = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 4),
        Parent       = searchBox,
    })
    New("Frame", {  -- top border of search box
        BackgroundColor3 = "BorderColor",
        Size             = UDim2.new(1, 0, 0, 1),
        ZIndex           = searchBox.ZIndex,
        Parent           = searchBox,
    })
    New("Frame", {  -- right border of search box
        AnchorPoint      = Vector2.new(1, 0),
        BackgroundColor3 = "BorderColor",
        Position         = UDim2.fromScale(1, 0),
        Size             = UDim2.new(0, 1, 1, 0),
        ZIndex           = searchBox.ZIndex,
        Parent           = searchBox,
    })

    -- ── Content Area ──────────────────────────────────────────────────────
    -- Right of sidebar, below titlebar, above footer
    local contentArea = New("Frame", {
        BackgroundTransparency = 1,
        Position         = UDim2.fromOffset(SW + 1, TH),
        Size             = UDim2.new(1, -(SW + 1), 1, -(TH + FH)),
        ClipsDescendants = true,
        ZIndex           = mainFrame.ZIndex,
        Parent           = mainFrame,
    })

    -- Tracks any in-flight Window:SetSize / Window:SetPosition spring so
    -- MakeDraggable/MakeResizable can cancel it the moment the user starts
    -- a manual drag or resize — otherwise a programmatic animation (e.g.
    -- from config restore) keeps overwriting mainFrame.Position/Size every
    -- Heartbeat frame and fights the drag/resize math, making the window
    -- feel unresponsive or "stuck".
    local MIN_WINDOW_SIZE = Vector2.new(500, 380)
    local _cancelSizeSpring, _cancelPosSpring
    local function cancelWindowSprings()
        if _cancelSizeSpring then _cancelSizeSpring(); _cancelSizeSpring = nil end
        if _cancelPosSpring  then _cancelPosSpring();  _cancelPosSpring  = nil end
    end

    -- ── Resize handle ─────────────────────────────────────────────────────
    if info.Resizable then
        local resizeHandle = New("TextButton", {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1,
            Position    = UDim2.new(1, -2, 1, -2),
            Size        = UDim2.fromOffset(14, 14),
            Text        = "⇲",
            TextSize    = 11,
            TextColor3  = "TextMuted",
            ZIndex      = mainFrame.ZIndex + 5,
            Parent      = mainFrame,
        })
        -- Min size scales with current DPI — passed as a function so it
        -- re-evaluates on every resize (after DPI has been changed).
        local function getScaledMin()
            local d = Library.DPIScale or 1
            return Vector2.new(math.round(500 * d), math.round(380 * d))
        end
        Library:MakeResizable(mainFrame, resizeHandle, windowMaid, getScaledMin, nil, cancelWindowSprings)
    end

    -- Dragging on titlebar
    Library:MakeDraggable(mainFrame, titleBar, windowMaid, cancelWindowSprings)

    -- ── Tab System ───────────────────────────────────────────────────────
    local Window = {
        Main       = mainFrame,
        Tabs       = {},
        ActiveTab  = nil,
        _maid      = windowMaid,
    }

    function Window:SetParticlesEnabled(v)
        Library.ParticlesEnabled = v
        if not v then
            clearParticles()
        elseif Library.Toggled then
            spawnParticles()
        end
    end

    -- Fade overlay for transitions - sits on top and fades in/out
    local fadeOverlay = New("Frame", {
        BackgroundColor3   = "BackgroundColor",
        BackgroundTransparency = 1,
        Size               = UDim2.fromScale(1, 1),
        ZIndex             = mainFrame.ZIndex + 2,
        Visible            = false,
        Parent             = contentArea,
    })

    local function showTabContent(tab, prevTab)
        if prevTab and prevTab.Container then
            prevTab.Container.Visible = false
        end
        if tab and tab.Container then
            tab.Container.Visible = true
            -- Quick fade overlay to smooth the switch
            fadeOverlay.Visible = true
            fadeOverlay.BackgroundTransparency = 0.4
            TweenService:Create(fadeOverlay,
                TweenInfo.new(0.12, Enum.EasingStyle.Quad),
                { BackgroundTransparency = 1 }):Play()
            task.delay(0.14, function()
                fadeOverlay.Visible = false
                fadeOverlay.BackgroundTransparency = 1
            end)
        end
    end

    function Window:AddTab(name, icon)
        local tab = {
            Name       = name,
            Groupboxes = {},
            Tabboxes   = {},
            Elements   = {},
            DependencyBoxes = {},
        }

        -- Tab button in sidebar tab list
        local tabBtn = New("TextButton", {
            BackgroundColor3       = "AccentColor",
            BackgroundTransparency = 1,
            Size                   = UDim2.new(1, 0, 0, 32),
            Text                   = "",
            ClipsDescendants       = true,
            Parent                 = tabList,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = tabBtn })

        -- Accent pill on the left edge
        local activeBar = New("Frame", {
            AnchorPoint      = Vector2.new(0, 0.5),
            BackgroundColor3 = "AccentColor",
            Position         = UDim2.new(0, 0, 0.5, 0),
            Size             = UDim2.fromOffset(0, 14),
            ZIndex           = tabBtn.ZIndex + 1,
            Parent           = tabBtn,
        })
        New("UICorner", { CornerRadius = UDim.new(0, 2), Parent = activeBar })

        local tabBtnLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Position         = UDim2.fromOffset(14, 0),
            Size             = UDim2.new(1, -14, 1, 0),
            Text             = name,
            TextSize         = Tokens.FontSize.SM,
            TextTransparency = 0.45,
            FontFace         = Font.new("rbxasset://fonts/families/GothamSSm.json",
                Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            TextXAlignment   = Enum.TextXAlignment.Left,
            Parent           = tabBtn,
        })

        -- Content container for this tab - fully transparent, no background
        local tabContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size             = UDim2.fromScale(1, 1),
            Visible          = false,
            ClipsDescendants = true,
            Parent           = contentArea,
        })

        -- Two-column layout: each half fills full height
        local scrollLeft = New("ScrollingFrame", {
            BackgroundTransparency    = 1,
            BorderSizePixel           = 0,
            CanvasSize                = UDim2.fromOffset(0, 0),
            AutomaticCanvasSize       = Enum.AutomaticSize.Y,
            ScrollBarThickness        = 4,
            ScrollBarImageColor3      = "AccentColor",
            ScrollingDirection        = Enum.ScrollingDirection.Y,
            Position                  = UDim2.fromOffset(0, 0),
            Size                      = UDim2.new(0.5, -1, 1, 0),
            Parent                    = tabContainer,
        })
        New("UIPadding", {
            PaddingLeft   = UDim.new(0, 8), PaddingRight  = UDim.new(0, 4),
            PaddingTop    = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
            Parent = scrollLeft,
        })
        New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scrollLeft })

        -- Centre divider (hidden when only one side is used)
        local colDivider = New("Frame", {
            BackgroundColor3 = "BorderColor",
            Position         = UDim2.new(0.5, -1, 0, 0),
            Size             = UDim2.new(0, 1, 1, 0),
            Visible          = false,
            Parent           = tabContainer,
        })

        local scrollRight = New("ScrollingFrame", {
            BackgroundTransparency    = 1,
            BorderSizePixel           = 0,
            CanvasSize                = UDim2.fromOffset(0, 0),
            AutomaticCanvasSize       = Enum.AutomaticSize.Y,
            ScrollBarThickness        = 4,
            ScrollBarImageColor3      = "AccentColor",
            ScrollingDirection        = Enum.ScrollingDirection.Y,
            Position                  = UDim2.new(0.5, 1, 0, 0),
            Size                      = UDim2.new(0.5, -1, 1, 0),
            Visible                   = false,
            Parent                    = tabContainer,
        })
        New("UIPadding", {
            PaddingLeft   = UDim.new(0, 4), PaddingRight  = UDim.new(0, 8),
            PaddingTop    = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
            Parent = scrollRight,
        })
        New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scrollRight })

        -- Column usage counters; refreshed every time a groupbox is added
        local _leftCount  = 0
        local _rightCount = 0
        local function refreshColumnLayout()
            local hasLeft  = _leftCount  > 0
            local hasRight = _rightCount > 0
            if hasLeft and hasRight then
                -- Normal two-column split
                scrollLeft.Size     = UDim2.new(0.5, -1, 1, 0)
                scrollLeft.Visible  = true
                scrollRight.Size    = UDim2.new(0.5, -1, 1, 0)
                scrollRight.Position = UDim2.new(0.5, 1, 0, 0)
                scrollRight.Visible = true
                colDivider.Visible  = true
            elseif hasLeft then
                -- Only left used — expand to full width
                scrollLeft.Size     = UDim2.new(1, 0, 1, 0)
                scrollLeft.Visible  = true
                scrollRight.Visible = false
                colDivider.Visible  = false
            elseif hasRight then
                -- Only right used — move to left edge, expand to full width
                scrollRight.Size     = UDim2.new(1, 0, 1, 0)
                scrollRight.Position = UDim2.fromOffset(0, 0)
                scrollRight.Visible  = true
                scrollLeft.Visible   = false
                colDivider.Visible   = false
            end
        end
        -- Start with left full-width until something is added
        scrollLeft.Size    = UDim2.new(1, 0, 1, 0)
        scrollLeft.Visible = true

        tab.Container   = tabContainer
        tab.LeftScroll  = scrollLeft
        tab.RightScroll = scrollRight

        -- Show/hide logic
        local function showTab()
            if Window.ActiveTab == tab then return end
            NavHistory.Push({ type = "tab", name = name })
            local prev = Window.ActiveTab
            Window.ActiveTab = tab

            local tiNorm = TweenInfo.new(0.13, Enum.EasingStyle.Quad)
            local tiFast = TweenInfo.new(0.1,  Enum.EasingStyle.Quad)

            -- Hide settings container if it was active
            if Window.Settings and Window.Settings.Container then
                Window.Settings.Container.Visible = false
            end
            -- Deactivate settings button visuals
            if Window.Settings and Window.Settings._btn then
                TweenService:Create(Window.Settings._btn,   tiNorm, { BackgroundTransparency = 1 }):Play()
                TweenService:Create(Window.Settings._label, tiNorm, { TextTransparency = 0.45 }):Play()
                if Window.Settings._bar then
                    TweenService:Create(Window.Settings._bar, tiFast, { Size = UDim2.fromOffset(0, 14) }):Play()
                end
            end

            for _, t in pairs(Window.Tabs) do
                if t ~= tab then
                    TweenService:Create(t._btn,   tiNorm, { BackgroundTransparency = 1 }):Play()
                    TweenService:Create(t._label, tiNorm, { TextTransparency = 0.45 }):Play()
                    TweenService:Create(t._bar,   tiFast, { Size = UDim2.fromOffset(0, 14) }):Play()
                end
            end

            TweenService:Create(tabBtn,      tiNorm, { BackgroundTransparency = 0.88 }):Play()
            TweenService:Create(tabBtnLabel, tiNorm, { TextTransparency = 0 }):Play()
            TweenService:Create(activeBar,   tiFast, { Size = UDim2.fromOffset(3, 18) }):Play()

            showTabContent(tab, prev)
            Library.ActiveTab = tab
            EventBus:Emit("tabChanged", tab)
        end

        windowMaid:Connect(tabBtn.MouseButton1Click, showTab)
        windowMaid:Connect(tabBtn.MouseEnter, function()
            if Window.ActiveTab ~= tab then
                TweenService:Create(tabBtnLabel,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                    { TextTransparency = 0.2 }):Play()
            end
        end)
        windowMaid:Connect(tabBtn.MouseLeave, function()
            if Window.ActiveTab ~= tab then
                TweenService:Create(tabBtnLabel,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                    { TextTransparency = 0.5 }):Play()
            end
        end)

        tab._btn   = tabBtn
        tab._label = tabBtnLabel
        tab._bar   = activeBar
        tab.Show   = showTab

        -- AddGroupbox for tab
        function tab:AddGroupbox(gbInfo)
            gbInfo = gbInfo or {}
            local side = gbInfo.Side or 1
            local scroll = side == 1 and scrollLeft or scrollRight
            -- Track usage and reflow columns
            if side == 1 then _leftCount = _leftCount + 1
            else               _rightCount = _rightCount + 1
            end
            refreshColumnLayout()

            local boxHolder = New("Frame", {
                BackgroundColor3 = "SurfaceColor",
                BackgroundTransparency = 0.4,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = scroll,
            })
            New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusMD), Parent = boxHolder })
            New("UIStroke", {
                Color = "BorderColor",
                Thickness = 1,
                Transparency = 0.4,
                Parent = boxHolder,
            })

            -- Header row
            local header = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                Parent = boxHolder,
            })
            -- Accent left bar on header
            New("Frame", {
                BackgroundColor3 = "AccentColor",
                Position = UDim2.fromOffset(-9, 7.5),
                Size     = UDim2.fromOffset(3, 16),
                ZIndex   = boxHolder.ZIndex + 1,
                Parent   = header,
            })
            New("UICorner", { CornerRadius = UDim.new(1, 0),
                Parent = header:FindFirstChildOfClass("Frame") })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 8),
                Parent = header,
            })
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = gbInfo.Name or "",
                TextSize = Tokens.FontSize.SM,
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json",
                    Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextColor3 = "TextSecondary",
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header,
            })

            -- Divider under header
            New("Frame", {
                AnchorPoint = Vector2.new(0, 0),
                BackgroundColor3 = "BorderColor",
                BackgroundTransparency = 0.5,
                Position = UDim2.fromOffset(0, 32),
                Size = UDim2.new(1, 0, 0, 1),
                Parent = boxHolder,
            })

            -- Content
            local gbContainer = New("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 33),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = boxHolder,
            })
            New("UIPadding", {
                PaddingLeft   = UDim.new(0, 10),
                PaddingRight  = UDim.new(0, 10),
                PaddingTop    = UDim.new(0, 7),
                PaddingBottom = UDim.new(0, 9),
                Parent = gbContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 4),
                Parent  = gbContainer,
            })

            local gb = setmetatable({
                Name            = gbInfo.Name or "",
                Elements        = {},
                DependencyBoxes = {},
                Container       = gbContainer,
                BoxHolder       = boxHolder,
                Visible         = true,
            }, BaseGroupbox)

            function gb:Resize()
                task.defer(function()
                    if not gbContainer or not gbContainer.Parent then return end
                    local list = gbContainer:FindFirstChildOfClass("UIListLayout")
                    if list then
                        gbContainer.Size = UDim2.new(1, 0, 0, list.AbsoluteContentSize.Y + 16)
                    end
                end)
            end

            -- Entrance animation
            local entryScale = Instance.new("UIScale")
            entryScale.Scale = 0.97
            entryScale.Parent = boxHolder
            boxHolder.BackgroundTransparency = 1
            TweenService:Create(entryScale,
                TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Scale = 1 }):Play()
            TweenService:Create(boxHolder,
                TweenInfo.new(0.15, Enum.EasingStyle.Quad),
                { BackgroundTransparency = 0 }):Play()
            task.delay(0.22, function()
                if entryScale and entryScale.Parent then entryScale:Destroy() end
            end)

            table.insert(tab.Groupboxes, gb)
            return gb
        end

        function tab:AddTabbox(tbInfo)
            tbInfo = tbInfo or {}
            local side   = tbInfo.Side or 1
            local scroll = side == 1 and scrollLeft or scrollRight
            -- Track usage and reflow columns
            if side == 1 then _leftCount = _leftCount + 1
            else               _rightCount = _rightCount + 1
            end
            refreshColumnLayout()

            local tbHolder = New("Frame", {
                BackgroundColor3 = "SurfaceColor",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = scroll,
            })
            New("UICorner", { CornerRadius = UDim.new(0, info.CornerRadius), Parent = tbHolder })
            New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = tbHolder })

            local tabHeader = New("Frame", {
                BackgroundColor3 = "SurfaceAltColor",
                Size = UDim2.new(1, 0, 0, 30),
                Parent = tbHolder,
            })
            New("UICorner", { CornerRadius = UDim.new(0, info.CornerRadius), Parent = tabHeader })
            New("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = "SurfaceAltColor",
                Position = UDim2.fromScale(0, 1),
                Size     = UDim2.new(1, 0, 0, info.CornerRadius),
                Parent   = tabHeader,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 0),
                Parent  = tabHeader,
            })

            local tbContent = New("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 31),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = tbHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 6),
                Parent = tbContent,
            })

            local Tabbox = {
                ActiveTab = nil,
                Tabs      = {},
                Holder    = tbHolder,
            }

            function Tabbox:AddTab(tabName)
                local subMaid = Maid.New()

                local btn = New("TextButton", {
                    BackgroundColor3 = "SurfaceAltColor",
                    BackgroundTransparency = 1,
                    Size   = UDim2.new(0, 80, 1, 0),
                    Text   = tabName,
                    TextSize = Tokens.FontSize.SM,
                    TextTransparency = 0.5,
                    Parent = tabHeader,
                })
                New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = btn })

                local subContainer = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Visible = false,
                    Parent  = tbContent,
                })
                New("UIPadding", {
                    PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
                    PaddingTop = UDim.new(0, 6),
                    Parent = subContainer,
                })
                New("UIListLayout", {
                    Padding = UDim.new(0, 5),
                    Parent  = subContainer,
                })

                local SubTab = setmetatable({
                    Name = tabName,
                    Elements = {},
                    DependencyBoxes = {},
                    Container = subContainer,
                    ButtonHolder = btn,
                }, BaseGroupbox)

                function SubTab:Resize()
                    task.defer(function()
                        if not subContainer or not subContainer.Parent then return end
                        local list = subContainer:FindFirstChildOfClass("UIListLayout")
                        if list then
                            subContainer.Size = UDim2.new(1, 0, 0, list.AbsoluteContentSize.Y + 12)
                        end
                    end)
                end

                local function showSubTab()
                    if Tabbox.ActiveTab and Tabbox.ActiveTab ~= SubTab then
                        local prev = Tabbox.ActiveTab
                        prev.Container.Visible = false
                        prev.ButtonHolder.TextTransparency = 0.5
                        prev.ButtonHolder.BackgroundTransparency = 1
                    end
                    Tabbox.ActiveTab = SubTab
                    subContainer.Visible = true
                    btn.TextTransparency = 0
                    btn.BackgroundTransparency = 0
                    btn.BackgroundColor3 = Library.Scheme.BackgroundColor
                end

                subMaid:Connect(btn.MouseButton1Click, showSubTab)

                if not Tabbox.ActiveTab then
                    showSubTab()
                end

                Tabbox.Tabs[tabName] = SubTab
                windowMaid:Give(subMaid)
                return SubTab
            end

            table.insert(tab.Tabboxes, Tabbox)
            return Tabbox
        end

        function tab:AddLeftGroupbox(gbInfo)
            gbInfo = gbInfo or {}
            gbInfo.Side = 1
            return self:AddGroupbox(gbInfo)
        end

        function tab:AddRightGroupbox(gbInfo)
            gbInfo = gbInfo or {}
            gbInfo.Side = 2
            return self:AddGroupbox(gbInfo)
        end

        function tab:AddLeftTabbox()
            return self:AddTabbox({ Side = 1 })
        end

        function tab:AddRightTabbox()
            return self:AddTabbox({ Side = 2 })
        end

        Window.Tabs[name] = tab
        table.insert(Library.Tabs, tab)

        -- Auto-show first tab
        if not Window.ActiveTab then
            showTab()
        end

        PluginSystem.Emit("onTabCreate", tab)
        return tab
    end

    -- ── Glass / Acrylic helpers ─────────────────────────────────────────
    function Window:SetMenuTransparency(pct)
        -- pct: 0 = opaque, 100 = fully transparent
        local t = math.clamp(pct, 0, 100) / 100
        TweenService:Create(mainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundTransparency = t }):Play()
        TweenService:Create(titleBar,  TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundTransparency = math.clamp(t + 0.07, 0, 1) }):Play()
        TweenService:Create(sidebar,   TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundTransparency = math.clamp(t + 0.02, 0, 1) }):Play()
        TweenService:Create(footer,    TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundTransparency = math.clamp(t + 0.07, 0, 1) }):Play()

        -- Cards/groupboxes get a smaller proportional bump in transparency
        local cardT = math.clamp(t * 0.6 + 0.2, 0.2, 0.85)
        for _, tab in pairs(Window.Tabs) do
            for _, gb in ipairs(tab.Groupboxes or {}) do
                if gb.BoxHolder then
                    TweenService:Create(gb.BoxHolder, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundTransparency = cardT }):Play()
                end
            end
        end

        -- Search box
        TweenService:Create(searchBox, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundTransparency = cardT }):Play()

        -- Toggles, dropdowns, sliders, inputs — adjust base transparency
        local elT = math.clamp(t * 0.5 + 0.15, 0.15, 0.8)
        Library.ElementTransparency = elT

        for idx, toggle in pairs(Library.Toggles) do
            if toggle._refreshTransparency then toggle._refreshTransparency() end
        end
        for _, opt in pairs(Library.Options) do
            if opt.Type == "Dropdown" and opt.Holder then
                local displayBtn = opt.Holder:FindFirstChildWhichIsA("TextButton")
                if displayBtn then
                    TweenService:Create(displayBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundTransparency = elT }):Play()
                end
            elseif (opt.Type == "Input") and opt.Box and opt.Box.Parent then
                TweenService:Create(opt.Box.Parent, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundTransparency = elT }):Play()
            elseif opt.Type == "Slider" and opt.Holder then
                local track = opt.Holder:FindFirstChildWhichIsA("TextButton")
                if track then
                    TweenService:Create(track, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundTransparency = elT }):Play()
                end
            end
        end
    end

    function Window:SetAcrylicEnabled(v)
        local target = v and 0.08 or 0.18
        TweenService:Create(frostLayer1, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundTransparency = v and 0.55 or 0.85 }):Play()
        TweenService:Create(frostLayer2, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundTransparency = v and 0.75 or 0.95 }):Play()
    end

    -- ── Size / Position (used by config restore + resize handle) ────────
    -- Instant by default. A spring-based animation is only used when the
    -- caller explicitly passes `animate = true` — e.g. for a deliberate
    -- "snap into place" effect from a script. Config restore (and the
    -- resize handle) always apply instantly: an in-flight spring writing
    -- to mainFrame.Position/Size every Heartbeat frame would fight with
    -- MakeDraggable's per-frame tween and MakeResizable's direct writes,
    -- which is what made dragging/resizing feel "broken" after a config
    -- with a saved size/position was loaded.

    function Window:SetSize(newSize, animate)
        -- Clamp against the minimum scaled by current DPI so there's no jump
        local dpi = Library.DPIScale or 1
        local clampedX = math.max(math.round(MIN_WINDOW_SIZE.X * dpi), newSize.X.Offset)
        local clampedY = math.max(math.round(MIN_WINDOW_SIZE.Y * dpi), newSize.Y.Offset)
        local target = UDim2.new(newSize.X.Scale, clampedX, newSize.Y.Scale, clampedY)

        if _cancelSizeSpring then _cancelSizeSpring(); _cancelSizeSpring = nil end

        if animate then
            _cancelSizeSpring = AnimEngine.Spring({
                from      = mainFrame.Size,
                to        = target,
                stiffness = 280, damping = 26,
                apply     = function(v) mainFrame.Size = v end,
                onDone    = function() _cancelSizeSpring = nil end,
            })
        else
            mainFrame.Size = target
        end

        EventBus:Emit("windowResized", target)
        return target
    end

    function Window:SetPosition(newPos, animate)
        if _cancelPosSpring then _cancelPosSpring(); _cancelPosSpring = nil end

        if animate then
            _cancelPosSpring = AnimEngine.Spring({
                from      = mainFrame.Position,
                to        = newPos,
                stiffness = 280, damping = 26,
                apply     = function(v) mainFrame.Position = v end,
                onDone    = function() _cancelPosSpring = nil end,
            })
        else
            mainFrame.Position = newPos
        end

        return newPos
    end

    -- ── Window Toggle ────────────────────────────────────────────────────
    function Window:Toggle(v)
        if typeof(v) == "boolean" then
            Library.Toggled = v
        else
            Library.Toggled = not Library.Toggled
        end

        if Library.Toggled then
            mainFrame.Visible            = true
            mainFrame.BackgroundTransparency = 0

            if Library.ParticlesEnabled then
                spawnParticles()
            end

            local scaleI = Instance.new("UIScale")
            scaleI.Scale = 0.96
            scaleI.Parent = mainFrame
            TweenService:Create(scaleI,
                TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Scale = 1 }):Play()
            task.delay(0.22, function()
                if scaleI and scaleI.Parent then scaleI:Destroy() end
            end)


        else
            TweenService:Create(mainFrame,
                TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { BackgroundTransparency = 1 }
            ):Play()
            task.delay(0.14, function()
                if mainFrame and mainFrame.Parent then
                    mainFrame.Visible = false
                    mainFrame.BackgroundTransparency = 0
                end
                clearParticles()
            end)
        end
    end

    function Library:Toggle(v)
        Window:Toggle(v)
    end

    -- ── AddDialog ────────────────────────────────────────────────────────
    function Window:AddDialog(dialogInfo)
        dialogInfo = dialogInfo or {}
        local overlay = New("TextButton", {
            BackgroundColor3 = Color3.new(0,0,0),
            BackgroundTransparency = 0.5,
            Size    = UDim2.fromScale(1, 1),
            Text    = "",
            ZIndex  = ZManager.Get("modal"),
            Parent  = mainFrame,
        })
        overlay.BackgroundTransparency = 1
        TweenService:Create(overlay,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad),
            { BackgroundTransparency = 0.5 }):Play()

        local dFrame = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "SurfaceColor",
            Position = UDim2.fromScale(0.5, 0.5),
            Size     = UDim2.fromOffset(300, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text     = "",
            ZIndex   = ZManager.Get("modal") + 1,
            Parent   = overlay,
        })
        New("UICorner", { CornerRadius = UDim.new(0, info.CornerRadius), Parent = dFrame })
        New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = dFrame })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
            PaddingTop  = UDim.new(0, 14), PaddingBottom= UDim.new(0, 14),
            Parent = dFrame,
        })
        New("UIListLayout", { Padding = UDim.new(0, 10), Parent = dFrame })

        local scaleI = Instance.new("UIScale")
        scaleI.Scale = 0.94
        scaleI.Parent = dFrame
        TweenService:Create(scaleI,
            TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Scale = 1 }):Play()
        task.delay(0.22, function()
            if scaleI and scaleI.Parent then scaleI:Destroy() end
        end)

        -- Title
        if dialogInfo.Title then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                Text = dialogInfo.Title,
                TextSize = Tokens.FontSize.H3,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 1,
                Parent = dFrame,
            })
        end
        if dialogInfo.Description then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Text = dialogInfo.Description,
                TextSize = Tokens.FontSize.MD,
                TextColor3 = "TextSecondary",
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                LayoutOrder = 2,
                Parent = dFrame,
            })
        end

        -- Separator
        New("Frame", {
            BackgroundColor3 = "BorderColor",
            Size = UDim2.new(1, 0, 0, 1),
            LayoutOrder = 3,
            Parent = dFrame,
        })

        -- Buttons
        local btnRow = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 4,
            Parent = dFrame,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 8),
            Parent  = btnRow,
        })

        local Dialog = {
            Frame   = dFrame,
            Overlay = overlay,
        }

        function Dialog:Dismiss()
            Library.ActiveDialog = nil
            local ti = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            if dFrame and dFrame.Parent then
                TweenService:Create(dFrame, ti, { BackgroundTransparency = 1 }):Play()
            end
            TweenService:Create(overlay, ti, { BackgroundTransparency = 1 }):Play()
            task.delay(0.14, function()
                if overlay and overlay.Parent then overlay:Destroy() end
            end)
        end

        function Dialog:AddButton(btnInfo)
            local col = btnInfo.Variant == "Primary" and Library.Scheme.AccentColor
                     or btnInfo.Variant == "Danger"  and Library.Scheme.DangerColor
                     or Library.Scheme.SurfaceColor

            local b = New("TextButton", {
                BackgroundColor3 = col,
                Size = UDim2.fromOffset(0, 26),
                AutomaticSize = Enum.AutomaticSize.X,
                Text = "",
                Parent = btnRow,
            })
            New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = b })
            New("UIStroke", { Color = "BorderColor", Thickness = 1, Parent = b })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
                Parent = b,
            })
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = btnInfo.Title or "OK",
                TextSize = Tokens.FontSize.MD,
                TextColor3 = btnInfo.Variant == "Primary" and Color3.new(1,1,1) or "TextPrimary",
                Parent = b,
            })
            b.MouseButton1Click:Connect(function()
                if btnInfo.Callback then pcall(btnInfo.Callback, Dialog) end
                if dialogInfo.AutoDismiss ~= false then Dialog:Dismiss() end
            end)
            return b
        end

        for i, btn in ipairs(dialogInfo.FooterButtons or {}) do
            Dialog:AddButton(btn)
        end

        if dialogInfo.OutsideClickDismiss ~= false then
            overlay.MouseButton1Click:Connect(function()
                Dialog:Dismiss()
            end)
        end

        Library.ActiveDialog = Dialog
        return Dialog
    end

    -- ── Settings Tab (pinned at bottom of sidebar) ────────────────────────
    function Window:AddSettingsPanel()
        -- Settings tab button pinned at the bottom of the sidebar
        local settingsBtn = New("TextButton", {
            AnchorPoint      = Vector2.new(0, 1),
            BackgroundColor3 = "SurfaceAltColor",
            BackgroundTransparency = 1,
            Position         = UDim2.new(0, 6, 1, -6),
            Size             = UDim2.new(1, -12, 0, 30),
            Text             = "",
            ClipsDescendants = false,
            ZIndex           = sidebar.ZIndex + 1,
            Parent           = sidebar,
        })
        New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusSM), Parent = settingsBtn })

        -- Separator line above settings button
        New("Frame", {
            AnchorPoint      = Vector2.new(0, 1),
            BackgroundColor3 = "BorderColor",
            Position         = UDim2.new(0, 0, 1, -36),
            Size             = UDim2.new(1, 0, 0, 1),
            ZIndex           = sidebar.ZIndex,
            Parent           = sidebar,
        })

        local settingsBtnLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Position         = UDim2.fromOffset(14, 0),
            Size             = UDim2.new(1, -14, 1, 0),
            Text             = "Settings",
            TextSize         = Tokens.FontSize.MD,
            TextTransparency = 0.5,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = settingsBtn.ZIndex,
            Parent           = settingsBtn,
        })

        local settingsActiveBar = New("Frame", {
            AnchorPoint      = Vector2.new(0, 0.5),
            BackgroundColor3 = "AccentColor",
            Position         = UDim2.new(0, 3, 0.5, 0),
            Size             = UDim2.fromOffset(3, 0),
            ZIndex           = settingsBtn.ZIndex + 1,
            Parent           = settingsBtn,
        })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = settingsActiveBar })

        -- Content panel (same structure as a tab container)
        local settingsContainer = New("Frame", {
            BackgroundTransparency = 1,
            Size             = UDim2.fromScale(1, 1),
            Visible          = false,
            ClipsDescendants = true,
            Parent           = contentArea,
        })

        local scrollLeft = New("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            CanvasSize             = UDim2.fromOffset(0, 0),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            ScrollBarThickness     = 3,
            Position               = UDim2.fromOffset(0, 0),
            Size                   = UDim2.new(1, 0, 1, 0),
            Parent                 = settingsContainer,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0,8), PaddingRight  = UDim.new(0,4),
            PaddingTop  = UDim.new(0,8), PaddingBottom = UDim.new(0,8),
            Parent = scrollLeft,
        })
        New("UIListLayout", { Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scrollLeft })

        local sColDivider = New("Frame", {
            BackgroundColor3 = "BorderColor",
            Position = UDim2.new(0.5,-1,0,0),
            Size     = UDim2.new(0,1,1,0),
            Visible  = false,
            Parent   = settingsContainer,
        })

        local scrollRight = New("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            CanvasSize             = UDim2.fromOffset(0, 0),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            ScrollBarThickness     = 3,
            Position               = UDim2.new(0.5, 1, 0, 0),
            Size                   = UDim2.new(0.5, -1, 1, 0),
            Visible                = false,
            Parent                 = settingsContainer,
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0,4), PaddingRight  = UDim.new(0,8),
            PaddingTop  = UDim.new(0,8), PaddingBottom = UDim.new(0,8),
            Parent = scrollRight,
        })
        New("UIListLayout", { Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scrollRight })

        local _sLeftCount  = 0
        local _sRightCount = 0
        local function refreshSettingsLayout()
            local hasLeft  = _sLeftCount  > 0
            local hasRight = _sRightCount > 0
            if hasLeft and hasRight then
                scrollLeft.Size      = UDim2.new(0.5, -1, 1, 0)
                scrollLeft.Visible   = true
                scrollRight.Size     = UDim2.new(0.5, -1, 1, 0)
                scrollRight.Position = UDim2.new(0.5, 1, 0, 0)
                scrollRight.Visible  = true
                sColDivider.Visible  = true
            elseif hasLeft then
                scrollLeft.Size      = UDim2.new(1, 0, 1, 0)
                scrollLeft.Visible   = true
                scrollRight.Visible  = false
                sColDivider.Visible  = false
            elseif hasRight then
                scrollRight.Size     = UDim2.new(1, 0, 1, 0)
                scrollRight.Position = UDim2.fromOffset(0, 0)
                scrollRight.Visible  = true
                scrollLeft.Visible   = false
                sColDivider.Visible  = false
            end
        end

        local function makeGroupbox(name, parent)
            local boxHolder = New("Frame", {
                BackgroundColor3 = "SurfaceColor",
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                Parent           = parent,
            })
            New("UICorner", { CornerRadius = UDim.new(0, Tokens.RadiusMD), Parent = boxHolder })
            New("UIStroke",  { Color = "BorderColor", Thickness = 1, Parent = boxHolder })

            if name and name ~= "" then
                local hdr = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1,0,0,32),
                    Parent = boxHolder,
                })
                New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position  = UDim2.fromOffset(12,0),
                    Size      = UDim2.new(1,-12,1,0),
                    Text      = name,
                    TextSize  = Tokens.FontSize.MD,
                    TextColor3 = "TextPrimary",
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent    = hdr,
                })
                New("Frame", {
                    AnchorPoint      = Vector2.new(0,1),
                    BackgroundColor3 = "BorderColor",
                    Position         = UDim2.fromScale(0,1),
                    Size             = UDim2.new(1,0,0,1),
                    Parent           = hdr,
                })
            end

            local container = New("Frame", {
                BackgroundTransparency = 1,
                Position  = UDim2.fromOffset(0, (name and name ~= "") and 33 or 0),
                Size      = UDim2.new(1,0,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent    = boxHolder,
            })
            New("UIPadding", {
                PaddingLeft   = UDim.new(0,10), PaddingRight  = UDim.new(0,10),
                PaddingTop    = UDim.new(0,6),  PaddingBottom = UDim.new(0,8),
                Parent = container,
            })
            New("UIListLayout", { Padding = UDim.new(0,5), Parent = container })

            local gb = setmetatable({
                Name = name or "", Elements = {}, DependencyBoxes = {},
                Container = container, BoxHolder = boxHolder, Visible = true,
            }, BaseGroupbox)
            function gb:Resize()
                task.defer(function()
                    if not container or not container.Parent then return end
                    local l = container:FindFirstChildOfClass("UIListLayout")
                    if l then container.Size = UDim2.new(1,0,0, l.AbsoluteContentSize.Y+14) end
                end)
            end
            return gb
        end

        local function activateSettings()
            -- Deactivate all regular tabs
            for _, t in pairs(Window.Tabs) do
                TweenService:Create(t._btn,   TweenInfo.new(0.13, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
                TweenService:Create(t._label, TweenInfo.new(0.13, Enum.EasingStyle.Quad), { TextTransparency = 0.5 }):Play()
                t._bar.Size = UDim2.fromOffset(3, 0)
                if t.Container then t.Container.Visible = false end
            end
            showTabContent({ Container = settingsContainer }, nil)
            Window.ActiveTab = "settings"
            TweenService:Create(settingsBtn,      TweenInfo.new(0.13, Enum.EasingStyle.Quad), { BackgroundTransparency = 0 }):Play()
            TweenService:Create(settingsBtnLabel, TweenInfo.new(0.13, Enum.EasingStyle.Quad), { TextTransparency = 0 }):Play()
            TweenService:Create(settingsActiveBar, TweenInfo.new(0.1, Enum.EasingStyle.Quad), { Size = UDim2.fromOffset(3, 18) }):Play()
        end

        windowMaid:Connect(settingsBtn.MouseButton1Click, function()
            if Window.ActiveTab == "settings" then return end
            activateSettings()
        end)
        windowMaid:Connect(settingsBtn.MouseEnter, function()
            if Window.ActiveTab ~= "settings" then
                TweenService:Create(settingsBtnLabel, TweenInfo.new(0.1,Enum.EasingStyle.Quad), { TextTransparency = 0.2 }):Play()
            end
        end)
        windowMaid:Connect(settingsBtn.MouseLeave, function()
            if Window.ActiveTab ~= "settings" then
                TweenService:Create(settingsBtnLabel, TweenInfo.new(0.1,Enum.EasingStyle.Quad), { TextTransparency = 0.5 }):Play()
            end
        end)

        local Settings = {
            Container = settingsContainer,
            Visible   = false,
            _btn      = settingsBtn,
            _label    = settingsBtnLabel,
            _bar      = settingsActiveBar,
        }
        function Settings:AddLeftGroupbox(name)
            _sLeftCount = _sLeftCount + 1
            refreshSettingsLayout()
            return makeGroupbox(name, scrollLeft)
        end
        function Settings:AddRightGroupbox(name)
            _sRightCount = _sRightCount + 1
            refreshSettingsLayout()
            return makeGroupbox(name, scrollRight)
        end
        function Settings:Show()  activateSettings() end

        Window.Settings = Settings
        return Settings
    end
    Window.SearchText  = ""
    Window.IsSearching = false

    local function applySearch(query)
        query = (query or ""):lower():match("^%s*(.-)%s*$")
        Window.SearchText  = query
        Window.IsSearching = query ~= ""

        local activeTab = Window.ActiveTab
        if not activeTab then return end

        local function restoreGroupbox(gb)
            for _, el in ipairs(gb.Elements or {}) do
                if el.Holder then el.Holder.Visible = el.Visible ~= false end
            end
            if gb.BoxHolder then gb.BoxHolder.Visible = true end
        end

        for _, gb in ipairs(activeTab.Groupboxes or {}) do
            restoreGroupbox(gb)
        end

        if not Window.IsSearching then return end

        local function filterGroupbox(gb)
            local anyVisible = false
            for _, el in ipairs(gb.Elements or {}) do
                if el.Type == "Divider" then
                    if el.Holder then el.Holder.Visible = false end
                elseif el.Holder then
                    local txt = (el.Text or ""):lower()
                    local match = txt:find(query, 1, true) ~= nil
                    el.Holder.Visible = match and el.Visible ~= false
                    if el.Holder.Visible then anyVisible = true end
                end
            end
            if gb.BoxHolder then gb.BoxHolder.Visible = anyVisible end
        end

        for _, gb in ipairs(activeTab.Groupboxes or {}) do
            filterGroupbox(gb)
        end
    end

    windowMaid:Connect(searchBox:GetPropertyChangedSignal("Text"), function()
        applySearch(searchBox.Text)
    end)

    -- ── Notification helper ───────────────────────────────────────────────
    function Window:Notify(msg, duration)
        return ToastSystem.Info(msg, { Duration = duration })
    end

    -- ── Keybind handler ───────────────────────────────────────────────────
    windowMaid:Connect(UserInputService.InputBegan, function(input, gpe)
        if input.KeyCode == Library.ToggleKeybind then
            Window:Toggle()
            return
        end
        if gpe then return end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            if input.KeyCode == Enum.KeyCode.Z then
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    UndoManager.Redo("default")
                else
                    UndoManager.Undo("default")
                end
            end
            if input.KeyCode == Enum.KeyCode.K then
                DebugOverlay.Toggle()
            end
        end
    end)

    if info.AutoShow then
        Window:Toggle(true)
    end

    -- Expose the base (100% DPI) window size so ConfigSystem.Save stores
    -- the unscaled dimensions — restoring always works regardless of current DPI.
    Window._getBaseSize = function() return _dpiBaseSize end

    PluginSystem.Emit("onWindowCreate", Window)
    Library.Window = Window

    -- Register default commands
    CommandPalette.Register({ name = "Toggle Window",       category = "UI",    action = function() Window:Toggle() end })
    CommandPalette.Register({ name = "Toggle Debug Overlay",category = "Debug", action = function() DebugOverlay.Toggle() end })
    CommandPalette.Register({ name = "Toggle Light Mode",    category = "Theme", action = function() Library:ToggleLightMode(true) end })
    CommandPalette.Register({ name = "Theme: Dark",          category = "Theme", action = function() Library:SetTheme("Dark",       nil, true) end })
    CommandPalette.Register({ name = "Theme: Midnight",      category = "Theme", action = function() Library:SetTheme("Midnight",   nil, true) end })
    CommandPalette.Register({ name = "Theme: Ember",         category = "Theme", action = function() Library:SetTheme("Ember",      nil, true) end })
    CommandPalette.Register({ name = "Theme: Jade",          category = "Theme", action = function() Library:SetTheme("Jade",       nil, true) end })
    CommandPalette.Register({ name = "Theme: Rose",          category = "Theme", action = function() Library:SetTheme("Rose",       nil, true) end })
    CommandPalette.Register({ name = "Theme: Nord",          category = "Theme", action = function() Library:SetTheme("Nord",       nil, true) end })
    CommandPalette.Register({ name = "Theme: Dracula",       category = "Theme", action = function() Library:SetTheme("Dracula",    nil, true) end })
    CommandPalette.Register({ name = "Theme: Catppuccin",    category = "Theme", action = function() Library:SetTheme("Catppuccin", nil, true) end })
    CommandPalette.Register({ name = "Theme: Amoled",        category = "Theme", action = function() Library:SetTheme("Amoled",     nil, true) end })
    CommandPalette.Register({ name = "Theme: Ocean",         category = "Theme", action = function() Library:SetTheme("Ocean",      nil, true) end })
    CommandPalette.Register({ name = "Theme: Light",         category = "Theme", action = function() Library:SetTheme("Light",      nil, true) end })
    CommandPalette.Register({ name = "Theme: Rainbow",       category = "Theme", action = function() Library:SetTheme("Rainbow") end })

    -- Settings panel is always created so the gear button is always present.
    -- PopulateBuiltinSettings (Appearance / Keybinds / Configs / Misc) runs
    -- by default; set BuiltinSettings = false to get a blank panel instead.
    do
        local Settings = Window:AddSettingsPanel()
        if info.BuiltinSettings ~= false then
            PopulateBuiltinSettings(Window, Settings)
        end
    end

    -- Autoload default config — deferred two frames so that:
    --   1. All user groupboxes/toggles/options are registered (user code runs first)
    --   2. PopulateBuiltinSettings callbacks are wired up
    --   3. The settings pass (task.defer inside Load) fires after both passes
    task.defer(function()
        task.defer(function()
            local defaultCfg = Library.Config and Library.Config.GetDefault()
            if defaultCfg and Library.Config.Exists(defaultCfg) then
                local ok = Library.Config.Load(defaultCfg)
                if ok then
                    ToastSystem.Info("Loaded config: " .. tostring(defaultCfg), { Duration = 3 })
                else
                    ToastSystem.Warning("Failed to load default config: " .. tostring(defaultCfg), { Duration = 4 })
                end
            end
        end)
    end)

    return Window
end

-- ─── Notify shorthand ──────────────────────────────────────────────────────
function Library:Notify(msg, notifType, duration)
    return ToastSystem.Show(msg, notifType or "info", { Duration = duration })
end

-- ─── Script Hub preload shorthand ──────────────────────────────────────────
-- Preload a Script Hub card from your own setup code instead of adding it
-- by hand through the UI, e.g.:
--     UI:AddScript("Auto Farm", 'loadstring(game:HttpGet("..."))()')
-- Safe to call every run — matches by name, so re-running your script
-- updates the existing card's code instead of creating a duplicate.
function Library:AddScript(name, code)
    return CommandPalette.AddScript(name, code)
end

function Library:AddScripts(list)
    return CommandPalette.AddScripts(list)
end

-- ─── Loading Screen ────────────────────────────────────────────────────────
function Library:CreateLoading(options)
    return LoadingScreen.Create(options)
end

-- ─── Unload ────────────────────────────────────────────────────────────────
function Library:Unload()
    Library.Unloaded = true
    LibraryMaid:Destroy()
    pcall(function()
        RunService:UnbindFromRenderStep("NexusUI_cursor")
    end)
    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
    if getgenv then
        getgenv().NexusUI = nil
    end
    EventBus:Emit("unload")
end

-- ─── Export ────────────────────────────────────────────────────────────────
if getgenv then
    getgenv().NexusUI = Library
end

return Library
