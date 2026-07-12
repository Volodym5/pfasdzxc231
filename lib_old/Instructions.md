## Using Library
```lua
local NeverLose = loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/lib/source.lua"))()
```
## Creating Notification
```lua
local Notification = NeverLose:CreateNotification();
```
Usage:
```lua
Notification.new({
	Title = "Title",
	Content = "Content",
	Duration = 7,
})
```

## Creating Logger
```lua
local Logging = NeverLose:CreateLogger();
```
Usage:
```lua
Logging.new("crosshairs",'Hit {PLAYER_NAME} in the neck for 100 damage',15)
```
## Creating Indicator
```lua
local Indicator = NeverLose:CreateIndicator();
```
Usage:
```lua
local HitChance = Indicator.new({
	Name = "HC",
	Icon = 'crosshairs',
	Color = 'Red',
})
```
Visible:
```lua
HitChance:SetRender(<boolean>)
```
Set Color:
- Red
- Green
- White
```lua
HitChance:SetColor(<string>)
```
Edit Text:
```lua
HitChance:SetText(<string>)
```

## Creating Window
```lua
local Window = NeverLose:CreateWindow({
		Logo = NeverLose.GlobalLogo,
		Name = "Neverlose",
		Content = "Counter-Strike 2",
		Size = NeverLose.Scales.Default,
		ConfigFolder = "NeverLoseConfigs",
		Enable3DRenderer = false,
		Keybind = "RightShift"
});
```
## Creating Watermark
```lua
local Watermark = window:Watermark();
```
Usage:
```lua
local pings = Watermark:AddBlock(
  "chart-four-vertical-bars" , -- Icon <string>
  "0MS", -- Default Text <string>
);
```
Edit Text:
```lua
ping:SetText(tostring(game:GetService('Players').LocalPlayer:GetNetworkPing())..'MS')
```
Set Visible:
```lua
ping:SetVisible(<boolean>)
```
Add Input Signal:
```lua
ping:Input(function()
	print("click!")
end);
```
## User Settings
```lua
Window.UserSettings
```
Example:
```lua
Window.UserSettings:AddLabel('Synchronization'):AddToggle({
	Default = true,
	Callback = function(v)
		
	end,
})
```
## Set Window Size
```lua
Window:SetSize(<UDim2>)
```
## Toggle Window
```lua
Window:ToggleInterface()
```
## 3D Menu
Make sure "Enable3DRenderer" is enabled
```lua
Window:Set3DRender(<bool>)
```
## Set Profile
Set user profile ex: username , profile , expires date
```lua
Window:SetAccount({
  Profile = <string> or nil,
  Username = <string> or nil,
  Expires = <string> or nil
})
```
### Creating Tab Label
```lua
window:AddTabLabel('AIMBOT')
```
## Creating Tab
```lua
local Tab = window:AddTab({
	Icon = 'crosshairs',
	Name = "Rage",
})
```
## Creating Section
```lua
local Section = Tab:AddSection({
	Name = "MAIN"
})
```
### Creating Label
```
Text: <string> , Warp: <boolean>
```
```lua
local Label = Section:AddLabel('Label',false);
```
### Creating ToolTip
```lua
Label:ToolTip("Long Text, Something ...");
```
### Creating Toggle
```lua
Label:AddToggle({
  Default = false,
  Flag = "MyToggle",
  Callback = function(bool)
  
  end,
})
```

### Creating Slider
```lua
Label:AddSlider({
  Default = 50,
  Min = 0,
  Max = 10,
  Type = "", -- Opional
  Rounding = 0,
  
  Nums = { -- Opional
    [0] = "Off",
    [10] = "Max",
  },
  
  Flag = "MySlider",
  Size = 125, -- Size of Slider <Pixel> (Opional)
  Callback = function(value)
  
  end,,
})
```
### Creating Option
- 1 > Gear Icon
- 2 > Chevron Right Icon
```lua
Label:AddOption(<number (Opional)>)
```
Usage:
```lua
local Label = Section:AddLabel("Enabled");
Label:AddToggle({
	Default = false,
	Callback = print;
	Flag = "Ragebot",
})

local LabelOption = Label:AddOption();
LabelOption:AddLabel("Force Shoot"):AddToggle({
	Default = false,
	Callback = print,
	Flag = "FS"
})

-- LabelOption:... like section
```
### Creating Color Picker
```lua
Label:AddColorPicker({
  Default = Color3.fromRGB(255, 255, 255), -- Color 3 or Hex Code
  Flag = "MyColor",
  Callback  = function()
    
  end,
})
```
### Creating Keybind
```lua
Label:AddKeybind({
    Default = "K", -- Enum.KeyCode, String or nil
    Blacklist = {},
    Callback = function()
    end,
    Flag = "MyKeybind"
  })
```
### Creating Text Input
```lua
Label:AddTextInput({
  Default = "",
  Placeholder = "Placeholder",
  Callback = function()
  end,
  Flag = "MyText",
  Size = 100, -- Size of Textbox <Pixel> (Opional)
  Numeric = false,
})
```
### Creating Dropdown
```lua
Label:AddDropdown({
  Default = "1",
  Values = {"1","2","3","4"},
  Multi = false,
  Callback = function()
  end,
  AutoUpdate = false,
  Flag = "MySingleDropdown",
  Size = 100, -- Size of Dropdown <Pixel> (Opional)
})
```
Multiple Dropdown
```lua
Label:AddDropdown({
  Default = {
    ["1"] = true,
  },
  Values = {"1","2","3","4"},
  Multi = true,
  Callback = function()
  end,
  AutoUpdate = false,
  Flag = "MySingleDropdown",
  Size = 100, -- Size of Dropdown <Pixel> (Opional)
})
```
# Other Functions
## Get Value
Get current value of item
```lua
Element:GetValue() -> any , bool , table , something
```
## Set Value
Set value of item
```lua
Element:SetValue(<any , bool , table , something>)
```
## Set List Value
Set new item list of dropdown
```lua
Dropdown:SetValues({a,b,c,d})
```

# Example
```
local NeverLose = loadstring(game:HttpGet("https://raw.githubusercontent.com/Volodym5/pfasdzxc231/main/lib/source.lua"))()

local Notification = NeverLose:CreateNotification();
local Logging = NeverLose:CreateLogger();
local Indicator = NeverLose:CreateIndicator();
local window = NeverLose:CreateWindow({
	Logo = NeverLose.GlobalLogo,
	Name = "Neverlose",
	Content = "Counter-Strike 2",
	Size = NeverLose.Scales.Default,
	ConfigFolder = "NeverLoseConfigs",
	Enable3DRenderer = false,
	Keybind = "Insert"
});

local Watermark = window:Watermark();

local HC = Indicator.new({
	Name = "HC",
	Icon = 'crosshairs',
	Color = 'Red',
})

window:AddTabLabel('AIMBOT')

local ping = Watermark:AddBlock("chart-four-vertical-bars" , "0MS");
local UITogg = Watermark:AddBlock("cube-vertexes" , "Neverlose");

UITogg:Input(function()
	window:ToggleInterface();
end);

task.spawn(function()
	while true do task.wait(1)
		ping:SetText(tostring(math.random(30,90))..'MS')
	end
end)

local Rage = window:AddTab({
	Icon = 'crosshairs',
	Name = "Rage",
})

local Legit = window:AddTab({
	Icon = 'mouse-scrollwheel',
	Name = "Legit"
})
 
local Raging = Rage:AddSection({
	Name = "MAIN"
})

local Selection = Rage:AddSection({
	Name = "SELECTION",
	Position = 'left'
})

local Other = Rage:AddSection({
	
	Name = "OTHER",
	Position = 'right'
})

local AntiAim = Rage:AddSection({
	Name = "ANTI-AIM",
	Position = 'right'
})


-- <STRING : TEXT, BOOLEAN : WARP> --
Raging:AddLabel('Ts so skbidi\nfr noi cap',true)

local EnabledRage = Raging:AddLabel('Enabled')
local SlientAim = Raging:AddLabel('Silent Aim')

EnabledRage:ToolTip("Dynamically adjusts grenade throw angles to counteract\nmovement velocity, allowing precise straight-line throws\neven while strafing")
EnabledRage:AddToggle({
	Default = false,
	Callback = print;
	Flag = "Ragebot",
})

EnabledRage:AddOption():AddLabel("Force Shoot"):AddToggle({
	Default = false,
	Callback = print,
	Flag = "FS"
})

SlientAim:AddToggle({
	Default = false,
	Callback = print,
	Flag = "SLIENTAIM",
})

local opt = SlientAim:AddOption();
opt:AddLabel('Perfect Silent-Aim'):AddToggle({
	Default = false,
	Callback = print,
	Flag = "HideShot",
})

opt:AddLabel('Perfect Silent-Aim'):AddToggle({
	Default = false,
	Callback = print,
	Flag = "HideShot2",
})

Raging:AddLabel('Automatic Fire'):AddToggle({
	Default = false,
	Flag = "AutoFire",
})

Raging:AddLabel('Aim Through Walls'):AddToggle({
	Default = false,
	Flag = "AWALLS",
})

Raging:AddLabel('Field of View'):AddSlider({
	Min = 0,
	Max = 2600,
	Rounding = 1,
	Default = 100,
	Type = "Lv",
	Size = 100,
	Callback = print,
	Flag = "fov",
})

Selection:AddLabel("Target"):AddDropdown({
	Default = 'Hightest Damage',
	Values = {
		'Hightest Damage',
		'Automatic',
		'Lowest Damage'
	},
	Callback = print,
	Flag = "target_box",
})

Selection:AddLabel('Hitboxes'):AddDropdown({
	Default = {'Head'},
	Multi = true,
	Values = {
		'Head',
		'Body',
		'Arms',
		'Legs'
	},
	Flag = "hitboxes",
	Callback = print
})

local Multipoint = Selection:AddLabel('Multipoint')

Multipoint:AddOption():AddLabel('Multipoint'):AddSlider({
	Min = 0,
	Max = 100,
	Default = 75,
	Flag = "multipoint",
	Callback = print
})

Multipoint:AddDropdown({
	Default = {'Head'},
	Multi = true,
	Values = {
		'Head',
		'Body',
		'Arms',
		'Legs'
	},
	Flag = "hitboxmuklti",
	Callback = print
})

local hc = Selection:AddLabel('Hit Chance')

hc:AddSlider({
	Min = 0,
	Max = 100,
	Type = "%",
	Nums = {
		[0] = 'Auto',
	},
	Flag = "hc",
	Size = 95,
	Default = 50,
})

hc:AddOption():AddLabel('Something'):AddToggle({
	Default = false
})

local md = Selection:AddLabel('Min Damage')

md:AddSlider({
	Min = 0,
	Max = 100,
	Nums = {
		[0] = 'Auto',
	},
	Flag = "md",
	Size = 95,
	Default = 15,
})

md:AddOption():AddLabel('Something'):AddToggle({
	Default = false
})

local qs = Selection:AddLabel('Quick Stop')

qs:AddToggle({
	Default = false,
	Flag = "astop",
	Callback = print
})

qs:AddOption():AddLabel('Auto Stop'):AddDropdown({
	Default = {'Early'},
	Multi = true,
	Flag = "astop_module",
	Values = {'Early','In Air','Between Shot' , 'Force Accurate'},
	Callback = print
})

Selection:AddLabel('Quick Scope'):AddToggle({
	Default = false,
	Flag = "ascope",
	Callback = print
})

Other:AddLabel('History'):AddDropdown({
	Default = 'High',
	Values = {'Minimum','Low','High','Maximum'},
	Flag = "backtrack",
	Callback = print
})

Other:AddLabel('Delay Shot'):AddToggle({
	Default = false,
	Flag = "delayshoot",
	Callback = print
})

Other:AddLabel('Remove Recoil'):AddToggle({
	Default = false,
	Flag = "removerecoil",
	Callback = print
})


Other:AddLabel('Remove Spread'):AddToggle({
	Default = false,
	Flag = "removespread",
	Callback = print
})


Other:AddLabel('Duck Peek Assist'):AddToggle({
	Default = false,
	Callback = print
})


local qpa = Other:AddLabel('Quick Peek Assist');
qpa:AddToggle({
	Default = false,
	Flag = "qpa",
	Callback = print
})

qpa:AddOption():AddLabel('Something tung tung')

Other:AddLabel('Double Tap'):AddToggle({
	Default = false,
	Callback = print,
	Flag = "dt",
})

local aa_enable = AntiAim:AddLabel('Enabled');
aa_enable:AddToggle({
	Default = false,
	Flag = "aa",
	Callback = print
})

aa_enable:AddOption():AddLabel('Resolvers tung tung'):AddToggle({
	Default = false,
	Callback = print
})

AntiAim:AddLabel('Pitch'):AddDropdown({
	Default = 'Down',
	Flag = "pitch",
	Values = {'Down','Center','Up','Fake Up','Fake Down'}
})

AntiAim:AddLabel('Yaw'):AddDropdown({
	Default = 'Backwards',
	Flag = "yaw",
	Values = {'Backwards','Left','Right','Forwards'}
})

AntiAim:AddLabel('Freestanding'):AddToggle({
	Default = false,
	Flag = "freestand",
	Callback = print
})

AntiAim:AddLabel('Mouse Override'):AddToggle({
	Default = false,
	Flag = "mouse_override",
	Callback = print
})

---------- Menu Configuration ------------
window.UserSettings:AddLabel("Menu Keybind"):AddKeybind({
	Default = 'Insert',
	Callback = function(v)
		window.Keybind = v;
		
		Logging.new("ps4-touchpad",'Changed ui keybind to '..tostring(v),5)
	end,
})

window.UserSettings:AddLabel('Menu Scale'):AddDropdown({
	Default = "Default",
	Values = {"Default",'Large','Mobile','Small'},
	Callback = function(v)
		window:SetSize(NeverLose.Scales[v]);
		
		Logging.new("crop",'Changed ui size to '..tostring(v),5)
	end,
})

window.UserSettings:AddLabel('3D Menu'):AddToggle({
	Default = false,
	Callback = function(v)
		window:Set3DRender(v);
	end,
})

window.UserSettings:AddButton({
	Icon = 'discord',
	Name = 'Discord',
	Callback = function()
		print('invite')
		
		Logging.new("discord",'Copied discord invite link',5)
	end,
})

Notification.new({
	Title = "Notification",
	Content = "This is Neverlose Notification",
	Duration = 5,
})

task.wait(1)
Notification.new({
	Title = "Neverlose",
	Content = "Initialization in progress",
	Duration = 7,
})

Logging.new("crosshairs",'Hit thatguy in the neck for 100 damage',15)
task.wait(2)
Logging.new("crosshairs-slash",'Missed shot due to prediction error & YOUR NN',15)

HC:SetRender(true);

while true do task.wait(3)
	Watermark:SetRender(true);
	
	HC:SetColor('Red')
	HC:SetText("FL")
	task.wait(3);
	Watermark:SetRender(false);
	HC:SetColor('Green');
	HC:SetText("AUTO")
	task.wait(3)
	Watermark:SetRender(true);
	HC:SetColor('White')
	HC:SetText("HC")
	task.wait(1)
	Watermark:SetRender(false);
	HC:SetRender(false);
	task.wait(1)
	HC:SetRender(true);
end
```
