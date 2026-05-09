-- PhantomUI_v4.lua
-- Elite Roblox UI Framework — Version 4.0.0
--
-- FIXES vs v3:
--   • nil 'State' crash — Toggle self-reference before assignment fixed
--   • Tab transition lock — SwitchingTabs guard, coordinated fade+slide
--   • Dropdown/ColorPicker on dedicated OverlayFrame (ZIndex 9999, no clipping)
--   • Slider single source of truth — spring only, no dual-write
--   • Spring damping raised (0.82–0.88) — no more wobble
--   • Color picker global input tracking via UserInputService
--   • Section ClipsDescendants OFF when dropdown opens, restored on close
--   • Centralized Animator — one RenderStepped loop for everything
--   • Scroll fade (gradient) on scrolling frames
--   • Spacing scale constants used throughout
--   • Collapse via chevron only (no accidental full-header click)

local UIS   = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local Run   = game:GetService("RunService")
local Core  = game:GetService("CoreGui")
local Gui   = game:GetService("GuiService")
local Text  = game:GetService("TextService")
local Http  = game:GetService("HttpService")
local Cam   = workspace.CurrentCamera

-- ─────────────────────────────────────────────────────────────────────────────
-- SPACING SCALE
-- ─────────────────────────────────────────────────────────────────────────────
local S = { Tiny = 4, Small = 6, Normal = 8, Large = 12, Huge = 16 }

-- ─────────────────────────────────────────────────────────────────────────────
-- MAID
-- ─────────────────────────────────────────────────────────────────────────────
local Maid = {}; Maid.__index = Maid
function Maid.new() return setmetatable({_t={}}, Maid) end
function Maid:Give(t) table.insert(self._t, t); return t end
function Maid:Clean()
    for _,t in ipairs(self._t) do
        if type(t)=="function" then t()
        elseif typeof(t)=="RBXScriptConnection" then t:Disconnect()
        elseif typeof(t)=="Instance" then t:Destroy()
        elseif t.Destroy then t:Destroy()
        elseif t.Clean then t:Clean() end
    end
    self._t = {}
end
function Maid:Destroy() self:Clean() end

-- ─────────────────────────────────────────────────────────────────────────────
-- SIGNAL
-- ─────────────────────────────────────────────────────────────────────────────
local Signal = {}; Signal.__index = Signal
function Signal.new() return setmetatable({_l={}}, Signal) end
function Signal:Connect(cb)
    local c = {_cb=cb, _on=true, Disconnect=function(s) s._on=false end}
    table.insert(self._l, c); return c
end
function Signal:Fire(...)
    for i=#self._l,1,-1 do
        local l=self._l[i]
        if l._on then task.spawn(l._cb,...) else table.remove(self._l,i) end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- SPRING  (damping raised — no wobble)
-- ─────────────────────────────────────────────────────────────────────────────
local Spring = {}; Spring.__index = Spring
function Spring.new(speed, damper)
    return setmetatable({Target=0,Position=0,Velocity=0,Speed=speed or 40,Damper=damper or 0.82}, Spring)
end
function Spring:Update(dt)
    if math.abs(self.Target-self.Position)<5e-4 and math.abs(self.Velocity)<5e-4 then
        self.Position=self.Target; self.Velocity=0; return self.Target
    end
    local f=(self.Target-self.Position)*self.Speed
    self.Velocity=(self.Velocity+f*dt)*(self.Damper^dt)
    self.Position=self.Position+self.Velocity*dt
    return self.Position
end
function Spring:Snap(v) self.Position=v; self.Target=v; self.Velocity=0 end

-- ─────────────────────────────────────────────────────────────────────────────
-- CENTRALIZED ANIMATOR  (#10 — one loop, all springs registered here)
-- ─────────────────────────────────────────────────────────────────────────────
local Animator = {_jobs={}}
function Animator:Add(fn) -- fn(dt) called every frame; returns false to remove
    table.insert(self._jobs, fn)
end
Run.RenderStepped:Connect(function(dt)
    local alive = {}
    for _, fn in ipairs(Animator._jobs) do
        if fn(dt) ~= false then table.insert(alive, fn) end
    end
    Animator._jobs = alive
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- THEME
-- ─────────────────────────────────────────────────────────────────────────────
local Theme = {
    Current = {
        Background   = Color3.fromRGB(12, 12, 12),
        Surface      = Color3.fromRGB(20, 20, 20),
        SurfaceLight = Color3.fromRGB(30, 30, 30),
        SurfaceDeep  = Color3.fromRGB(14, 14, 14),
        Border       = Color3.fromRGB(38, 38, 38),
        BorderLight  = Color3.fromRGB(58, 58, 58),
        Text         = Color3.fromRGB(240,240,240),
        TextMuted    = Color3.fromRGB(150,150,150),
        TextDimmed   = Color3.fromRGB(100,100,100),
        Accent       = Color3.fromRGB(99,102,241),
        AccentMuted  = Color3.fromRGB(60,63,150),
        Danger       = Color3.fromRGB(239,68,68),
        Success      = Color3.fromRGB(34,197,94),
    },
    Themes = {
        Obsidian = {Background=Color3.fromRGB(10,10,10),Surface=Color3.fromRGB(18,18,18),SurfaceLight=Color3.fromRGB(26,26,26),SurfaceDeep=Color3.fromRGB(12,12,12),Border=Color3.fromRGB(30,30,30),Accent=Color3.fromRGB(99,102,241)},
        Midnight = {Background=Color3.fromRGB(5,5,10),Surface=Color3.fromRGB(12,12,20),SurfaceLight=Color3.fromRGB(20,20,32),SurfaceDeep=Color3.fromRGB(7,7,14),Border=Color3.fromRGB(28,28,44),Accent=Color3.fromRGB(139,92,246)},
        Rose     = {Background=Color3.fromRGB(15,10,12),Surface=Color3.fromRGB(25,18,20),SurfaceLight=Color3.fromRGB(36,26,30),SurfaceDeep=Color3.fromRGB(12,8,10),Border=Color3.fromRGB(44,32,36),Accent=Color3.fromRGB(244,63,94)},
    },
    Changed = Signal.new(),
}
function Theme:Set(name)
    local d=self.Themes[name]; if not d then return end
    for k,v in pairs(d) do self.Current[k]=v end
    self.Changed:Fire(self.Current)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- UTILITIES
-- ─────────────────────────────────────────────────────────────────────────────
local function Corner(parent, r) local c=Instance.new("UICorner",parent); c.CornerRadius=UDim.new(0,r); return c end
local function Stroke(parent, color, trans)
    local s=Instance.new("UIStroke",parent)
    s.Color=color or Theme.Current.Border
    s.Transparency=trans or 0.55
    s.Thickness=1
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    return s
end
local function Shadow(parent, r, trans)
    local s=Instance.new("ImageLabel")
    s.Name="Shadow"; s.Image="rbxassetid://6015897843"
    s.ScaleType=Enum.ScaleType.Slice; s.SliceCenter=Rect.new(49,49,450,450)
    s.BackgroundTransparency=1; s.ImageColor3=Color3.new(0,0,0)
    s.ImageTransparency=trans or 0.4
    s.Size=UDim2.new(1,22,1,22); s.Position=UDim2.fromOffset(-11,-11)
    s.ZIndex=parent.ZIndex-1
    Corner(s,r); s.Parent=parent; return s
end
local function Noise(parent)
    local n=Instance.new("ImageLabel",parent)
    n.Image="rbxassetid://9968344105"; n.ImageTransparency=0.97
    n.ScaleType=Enum.ScaleType.Tile; n.TileSize=UDim2.fromOffset(128,128)
    n.BackgroundTransparency=1; n.Size=UDim2.fromScale(1,1); n.ZIndex=1; return n
end
local function ScrollFade(frame)
    -- Top + bottom gradient fade for scroll containers
    local grad=Instance.new("UIGradient",frame)
    grad.Rotation=90
    grad.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,   1),
        NumberSequenceKeypoint.new(0.04,0),
        NumberSequenceKeypoint.new(0.96,0),
        NumberSequenceKeypoint.new(1,   1),
    })
    return grad
end
local function Mouse()
    local m=UIS:GetMouseLocation(); local i=Gui:GetGuiInset()
    return Vector2.new(m.X, m.Y-i.Y)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- OVERLAY LAYER  — dropdowns, color pickers, tooltips live here
-- ZIndex 9999, no ClipsDescendants, parented to ScreenGui (#3)
-- ─────────────────────────────────────────────────────────────────────────────
local OverlayGui, OverlayFrame  -- populated when first window is created

local function GetOverlay()
    if OverlayFrame then return OverlayFrame end
    OverlayGui=Instance.new("ScreenGui",Core)
    OverlayGui.Name="PhantomOverlay"; OverlayGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    OverlayGui.DisplayOrder=100
    OverlayFrame=Instance.new("Frame",OverlayGui)
    OverlayFrame.Name="Overlay"; OverlayFrame.Size=UDim2.fromScale(1,1)
    OverlayFrame.BackgroundTransparency=1; OverlayFrame.ZIndex=9999
    return OverlayFrame
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CONFIG
-- ─────────────────────────────────────────────────────────────────────────────
local Config={Flags={},Folder="PhantomUI",Ext=".pui",Enabled=false,FileName=nil}
local function cSafe(fn,...) if fn then local ok,r=pcall(fn,...); return ok and r or false end end
local function cFolder(p) if isfolder and not cSafe(isfolder,p) then cSafe(makefolder,p) end end
function Config:Register(name,el) self.Flags[name]=el end
function Config:Save()
    if not self.Enabled or not self.FileName then return end
    if not (writefile and makefolder and isfolder and isfile) then return end
    cFolder(self.Folder)
    local data={}
    for n,el in pairs(self.Flags) do data[n]=el.CurrentValue end
    local ok,j=pcall(function() return Http:JSONEncode(data) end)
    if ok then cSafe(writefile, self.Folder.."/"..self.FileName..self.Ext, j) end
end
function Config:Load()
    if not self.Enabled or not self.FileName then return end
    if not (readfile and isfolder and isfile) then return end
    local path=self.Folder.."/"..self.FileName..self.Ext
    if not cSafe(isfile,path) then return end
    local raw=cSafe(readfile,path); if not raw or raw=="" then return end
    local ok,data=pcall(function() return Http:JSONDecode(raw) end)
    if not ok or type(data)~="table" then return end
    for n,v in pairs(data) do
        local el=self.Flags[n]
        if el and el.Set then task.spawn(function() el:Set(v) end) end
    end
end
function Config:AutoSave(interval)
    task.spawn(function() while task.wait(interval or 30) do self:Save() end end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- COMPONENT BASE
-- ─────────────────────────────────────────────────────────────────────────────
local Component={}; Component.__index=Component
function Component.new(name)
    return setmetatable({Name=name,_maid=Maid.new(),CurrentValue=nil},Component)
end
function Component:OnTheme(cb)
    self._maid:Give(Theme.Changed:Connect(cb)); cb(Theme.Current)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- BUTTON
-- ─────────────────────────────────────────────────────────────────────────────
local Button=setmetatable({},Component); Button.__index=Button
function Button.new(section, opts)
    local self=Component.new(opts.Name or "Button")
    setmetatable(self,Button)
    self.Callback=opts.Callback or function() end

    local Btn=Instance.new("TextButton")
    Btn.Name=self.Name; Btn.Size=UDim2.new(1,0,0,34)
    Btn.BackgroundColor3=Theme.Current.Surface
    Btn.BackgroundTransparency=0.08
    Btn.BorderSizePixel=0; Btn.AutoButtonColor=false
    Btn.ClipsDescendants=true; Btn.Text=""
    Btn.Parent=section.Instances.Content
    Corner(Btn,8); Stroke(Btn)

    local Scale=Instance.new("UIScale",Btn)
    local Lbl=Instance.new("TextLabel",Btn)
    Lbl.Size=UDim2.fromScale(1,1); Lbl.BackgroundTransparency=1
    Lbl.Text=self.Name; Lbl.TextColor3=Theme.Current.Text
    Lbl.Font=Enum.Font.GothamSemibold; Lbl.TextSize=13; Lbl.ZIndex=2

    local hS=Spring.new(55,0.82); local pS=Spring.new(75,0.80)
    local st=Stroke(Btn,Theme.Current.Border,0.55)

    Animator:Add(function(dt)
        local h=hS:Update(dt); local p=pS:Update(dt)
        Btn.BackgroundColor3=Theme.Current.Surface:Lerp(Theme.Current.SurfaceLight,h)
        Btn.BackgroundTransparency=0.08-h*0.05
        st.Color=Theme.Current.Border:Lerp(Theme.Current.Accent,h*0.8)
        st.Transparency=0.55-h*0.35
        Scale.Scale=1-p*0.03
    end)

    Btn.MouseEnter:Connect(function() hS.Position=0.25; hS.Target=1 end)
    Btn.MouseLeave:Connect(function() hS.Target=0; pS.Target=0 end)
    Btn.MouseButton1Down:Connect(function() pS.Target=1 end)
    Btn.MouseButton1Up:Connect(function()
        pS.Target=0
        local m=Mouse(); local rx=m.X-Btn.AbsolutePosition.X; local ry=m.Y-Btn.AbsolutePosition.Y
        local sz=math.max(Btn.AbsoluteSize.X,Btn.AbsoluteSize.Y)*1.5
        local R=Instance.new("Frame",Btn)
        R.AnchorPoint=Vector2.new(0.5,0.5); R.BackgroundColor3=Color3.new(1,1,1)
        R.BackgroundTransparency=0.85; R.Position=UDim2.fromOffset(rx,ry)
        R.Size=UDim2.fromOffset(0,0); R.ZIndex=10; Corner(R,999)
        Tween:Create(R,TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
            {Size=UDim2.fromOffset(sz,sz),BackgroundTransparency=1}):Play()
        task.delay(0.35,function() R:Destroy() end)
        self.Callback()
    end)
    self:OnTheme(function(t) Lbl.TextColor3=t.Text end)
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TOGGLE
-- ─────────────────────────────────────────────────────────────────────────────
local Toggle=setmetatable({},Component); Toggle.__index=Toggle
function Toggle.new(section, opts)
    local self=Component.new(opts.Name or "Toggle")
    setmetatable(self,Toggle)
    -- FIX: store state in local var first, assign self.State after full init
    local state   = opts.Default or false
    self.Callback = opts.Callback or function() end
    self.CurrentValue = state

    local Con=Instance.new("TextButton",section.Instances.Content)
    Con.Size=UDim2.new(1,0,0,34); Con.BackgroundTransparency=1; Con.Text=""

    local Lbl=Instance.new("TextLabel",Con)
    Lbl.Size=UDim2.new(1,-54,1,0); Lbl.BackgroundTransparency=1
    Lbl.Text=self.Name; Lbl.TextColor3=Theme.Current.Text
    Lbl.Font=Enum.Font.GothamSemibold; Lbl.TextSize=13
    Lbl.TextXAlignment=Enum.TextXAlignment.Left

    local Sw=Instance.new("Frame",Con)
    Sw.Size=UDim2.fromOffset(36,20); Sw.Position=UDim2.new(1,-36,0.5,0)
    Sw.AnchorPoint=Vector2.new(0,0.5); Corner(Sw,999)

    local Kn=Instance.new("Frame",Sw)
    Kn.Size=UDim2.fromOffset(14,14); Kn.AnchorPoint=Vector2.new(0,0.5)
    Kn.BackgroundColor3=Color3.new(1,1,1); Corner(Kn,999)

    local sp=Spring.new(60,0.84)
    sp:Snap(state and 1 or 0)

    Animator:Add(function(dt)
        local s=sp:Update(dt); local a=math.clamp(s,0,1)^0.65
        Sw.BackgroundColor3=Theme.Current.Border:Lerp(Theme.Current.Accent,a)
        Kn.Position=UDim2.new(0,3+s*16,0.5,0)
    end)

    -- FIX: click handler references local `state`, updates self.State after
    Con.MouseButton1Click:Connect(function()
        state=not state
        self.State=state          -- safe: self exists by this point
        self.CurrentValue=state
        sp.Target=state and 1 or 0
        self.Callback(state)
        Config:Save()
    end)

    self.State=state              -- assign after Click handler closure is made

    function self:Set(v)
        state=v; self.State=v; self.CurrentValue=v
        sp.Target=v and 1 or 0
        self.Callback(v)
    end

    if opts.Flag then Config:Register(opts.Flag,self) end
    self:OnTheme(function(t) Lbl.TextColor3=t.Text end)
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- SLIDER  — single source of truth: spring only (#2)
-- ─────────────────────────────────────────────────────────────────────────────
local Slider=setmetatable({},Component); Slider.__index=Slider
function Slider.new(section, opts)
    local self=Component.new(opts.Name or "Slider")
    setmetatable(self,Slider)
    self.Min=opts.Min or 0; self.Max=opts.Max or 100
    self.Value=math.clamp(opts.Default or 50,self.Min,self.Max)
    self.Suffix=opts.Suffix or ""
    self.Callback=opts.Callback or function() end
    self.Dragging=false
    self.CurrentValue=self.Value

    local Con=Instance.new("Frame",section.Instances.Content)
    Con.Size=UDim2.new(1,0,0,52); Con.BackgroundTransparency=1

    local Lbl=Instance.new("TextLabel",Con)
    Lbl.Size=UDim2.new(1,-60,0,20); Lbl.BackgroundTransparency=1
    Lbl.Text=self.Name; Lbl.TextColor3=Theme.Current.Text
    Lbl.Font=Enum.Font.GothamSemibold; Lbl.TextSize=13
    Lbl.TextXAlignment=Enum.TextXAlignment.Left

    local ValLbl=Instance.new("TextLabel",Con)
    ValLbl.Size=UDim2.new(1,0,0,20); ValLbl.BackgroundTransparency=1
    ValLbl.Text=tostring(self.Value)..self.Suffix
    ValLbl.TextColor3=Theme.Current.Accent
    ValLbl.Font=Enum.Font.GothamBold; ValLbl.TextSize=12
    ValLbl.TextXAlignment=Enum.TextXAlignment.Right

    local Track=Instance.new("TextButton",Con)
    Track.Size=UDim2.new(1,0,0,6); Track.Position=UDim2.fromOffset(0,36)
    Track.BackgroundColor3=Theme.Current.SurfaceDeep
    Track.BackgroundTransparency=0.2; Track.BorderSizePixel=0; Track.Text=""
    Track.AutoButtonColor=false; Corner(Track,999)

    local Fill=Instance.new("Frame",Track)
    Fill.BackgroundColor3=Theme.Current.Accent; Fill.BorderSizePixel=0; Corner(Fill,999)

    local Kn=Instance.new("Frame",Track)
    Kn.AnchorPoint=Vector2.new(0.5,0.5); Kn.BackgroundColor3=Color3.new(1,1,1)
    Kn.ZIndex=2; Corner(Kn,999); Shadow(Kn,7,0.55)

    -- SINGLE source of truth: fillSpring drives everything
    local fillSp=Spring.new(65,0.86)
    fillSp:Snap((self.Value-self.Min)/(self.Max-self.Min))

    local knobSzSp=Spring.new(50,0.80); knobSzSp:Snap(14)

    Animator:Add(function(dt)
        local f=fillSp:Update(dt); local ks=knobSzSp:Update(dt)
        Fill.Size=UDim2.fromScale(math.clamp(f,0,1),1)
        Kn.Position=UDim2.new(math.clamp(f,0,1),0,0.5,0)
        Kn.Size=UDim2.fromOffset(ks,ks)
        Fill.BackgroundColor3=Theme.Current.Accent
    end)

    local function ApplyPos(inputX)
        local norm=math.clamp((inputX-Track.AbsolutePosition.X)/Track.AbsoluteSize.X,0,1)
        self.Value=math.floor(self.Min+(self.Max-self.Min)*norm+0.5)
        self.CurrentValue=self.Value
        ValLbl.Text=tostring(self.Value)..self.Suffix
        fillSp.Target=norm          -- ONLY spring, no direct position write
        self.Callback(self.Value)
    end

    Track.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            self.Dragging=true; knobSzSp.Target=18; ApplyPos(inp.Position.X)
        end
    end)
    self._maid:Give(UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 and self.Dragging then
            self.Dragging=false; knobSzSp.Target=14; Config:Save()
        end
    end))
    self._maid:Give(UIS.InputChanged:Connect(function(inp)
        if self.Dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
            ApplyPos(inp.Position.X)
        end
    end))
    Track.MouseEnter:Connect(function() if not self.Dragging then knobSzSp.Target=16 end end)
    Track.MouseLeave:Connect(function() if not self.Dragging then knobSzSp.Target=14 end end)

    function self:Set(v)
        v=math.clamp(v,self.Min,self.Max)
        self.Value=v; self.CurrentValue=v
        ValLbl.Text=tostring(v)..self.Suffix
        fillSp.Target=(v-self.Min)/(self.Max-self.Min)
    end

    if opts.Flag then Config:Register(opts.Flag,self) end
    self:OnTheme(function(t) Lbl.TextColor3=t.Text; ValLbl.TextColor3=t.Accent end)
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- DROPDOWN  — rendered on OverlayFrame, absolute positioned (#3)
-- ─────────────────────────────────────────────────────────────────────────────
local Dropdown=setmetatable({},Component); Dropdown.__index=Dropdown
function Dropdown.new(section, opts)
    local self=Component.new(opts.Name or "Dropdown")
    setmetatable(self,Dropdown)
    self.Options=opts.Options or {}; self.Selected=opts.Default or nil
    self.Callback=opts.Callback or function() end; self.Open=false
    self.CurrentValue=self.Selected

    local Con=Instance.new("Frame",section.Instances.Content)
    Con.Size=UDim2.new(1,0,0,60); Con.BackgroundTransparency=1

    local Lbl=Instance.new("TextLabel",Con)
    Lbl.Size=UDim2.new(1,0,0,20); Lbl.BackgroundTransparency=1
    Lbl.Text=self.Name; Lbl.TextColor3=Theme.Current.Text
    Lbl.Font=Enum.Font.GothamSemibold; Lbl.TextSize=13
    Lbl.TextXAlignment=Enum.TextXAlignment.Left

    local Sel=Instance.new("TextButton",Con)
    Sel.Size=UDim2.new(1,0,0,34); Sel.Position=UDim2.fromOffset(0,S.Large+S.Small)
    Sel.BackgroundColor3=Theme.Current.Surface; Sel.BackgroundTransparency=0.08
    Sel.BorderSizePixel=0; Sel.AutoButtonColor=false; Sel.Text=""
    Corner(Sel,8)
    local selStroke=Stroke(Sel,Theme.Current.Border,0.55)

    local SelLbl=Instance.new("TextLabel",Sel)
    SelLbl.Size=UDim2.new(1,-40,1,0); SelLbl.Position=UDim2.fromOffset(S.Normal+S.Small,0)
    SelLbl.BackgroundTransparency=1
    SelLbl.Text=self.Selected or "Select..."
    SelLbl.TextColor3=self.Selected and Theme.Current.Text or Theme.Current.TextMuted
    SelLbl.Font=Enum.Font.Gotham; SelLbl.TextSize=13
    SelLbl.TextXAlignment=Enum.TextXAlignment.Left

    local Icon=Instance.new("ImageLabel",Sel)
    Icon.Size=UDim2.fromOffset(14,14); Icon.Position=UDim2.new(1,-26,0.5,0)
    Icon.AnchorPoint=Vector2.new(0,0.5); Icon.BackgroundTransparency=1
    Icon.Image="rbxassetid://6031091007"; Icon.ImageColor3=Theme.Current.TextMuted

    -- List lives on OverlayFrame — never clipped
    local List=Instance.new("ScrollingFrame",GetOverlay())
    List.Size=UDim2.fromOffset(1,0); List.BackgroundColor3=Theme.Current.SurfaceDeep
    List.BackgroundTransparency=0.04; List.BorderSizePixel=0
    List.Visible=false; List.ZIndex=9999; List.ScrollBarThickness=0
    Corner(List,8); Shadow(List,8,0.45)
    local LL=Instance.new("UIListLayout",List); LL.Padding=UDim.new(0,2)
    local ListPad=Instance.new("UIPadding",List)
    ListPad.PaddingTop=UDim.new(0,S.Small); ListPad.PaddingBottom=UDim.new(0,S.Small)
    ListPad.PaddingLeft=UDim.new(0,S.Small); ListPad.PaddingRight=UDim.new(0,S.Small)
    ScrollFade(List)

    for _,opt in ipairs(self.Options) do
        local OB=Instance.new("TextButton",List)
        OB.Size=UDim2.new(1,0,0,30); OB.BackgroundTransparency=1
        OB.Text="  "..opt; OB.TextColor3=Theme.Current.TextMuted
        OB.Font=Enum.Font.Gotham; OB.TextSize=13
        OB.TextXAlignment=Enum.TextXAlignment.Left; OB.ZIndex=9999
        OB.MouseEnter:Connect(function()
            Tween:Create(OB,TweenInfo.new(0.12),{BackgroundTransparency=0.88,BackgroundColor3=Color3.new(1,1,1),TextColor3=Theme.Current.Text}):Play()
        end)
        OB.MouseLeave:Connect(function()
            Tween:Create(OB,TweenInfo.new(0.12),{BackgroundTransparency=1,TextColor3=Theme.Current.TextMuted}):Play()
        end)
        OB.MouseButton1Click:Connect(function()
            self.Selected=opt; self.CurrentValue=opt
            SelLbl.Text=opt; SelLbl.TextColor3=Theme.Current.Text
            self.Callback(opt); self:Close(); Config:Save()
        end)
    end

    local heightSp=Spring.new(55,0.84); heightSp:Snap(0)
    local function UpdateOverlayPos()
        if not self.Open then return end
        local ap=Sel.AbsolutePosition; local as=Sel.AbsoluteSize
        local targetH=math.min(#self.Options*32+S.Normal*2,160)
        List.Position=UDim2.fromOffset(ap.X, ap.Y+as.Y+S.Small)
        List.Size=UDim2.fromOffset(as.X, targetH)
    end

    function self:Open_()
        self.Open=true
        List.Visible=true
        UpdateOverlayPos()
        local targetH=math.min(#self.Options*32+S.Normal*2,160)
        Tween:Create(Icon,TweenInfo.new(0.25,Enum.EasingStyle.Quint),{Rotation=180}):Play()
        selStroke.Color=Theme.Current.Accent; selStroke.Transparency=0.2
    end
    function self:Close()
        self.Open=false
        Tween:Create(Icon,TweenInfo.new(0.25,Enum.EasingStyle.Quint),{Rotation=0}):Play()
        Tween:Create(selStroke,TweenInfo.new(0.2),{Color=Theme.Current.Border,Transparency=0.55}):Play()
        Tween:Create(List,TweenInfo.new(0.25,Enum.EasingStyle.Quint),{Size=UDim2.fromOffset(List.AbsoluteSize.X,0)}):Play()
        task.delay(0.25,function() if not self.Open then List.Visible=false end end)
    end

    Sel.MouseButton1Click:Connect(function()
        if self.Open then self:Close() else self:Open_() end
    end)

    -- Close when clicking outside
    self._maid:Give(UIS.InputBegan:Connect(function(inp)
        if self.Open and inp.UserInputType==Enum.UserInputType.MouseButton1 then
            local m=Mouse()
            local lp=List.AbsolutePosition; local ls=List.AbsoluteSize
            local sp2=Sel.AbsolutePosition; local ss=Sel.AbsoluteSize
            local inList=m.X>=lp.X and m.X<=lp.X+ls.X and m.Y>=lp.Y and m.Y<=lp.Y+ls.Y
            local inSel=m.X>=sp2.X and m.X<=sp2.X+ss.X and m.Y>=sp2.Y and m.Y<=sp2.Y+ss.Y
            if not inList and not inSel then self:Close() end
        end
    end))

    function self:Set(v)
        self.Selected=v; self.CurrentValue=v
        SelLbl.Text=v or "Select..."
        SelLbl.TextColor3=v and Theme.Current.Text or Theme.Current.TextMuted
    end

    if opts.Flag then Config:Register(opts.Flag,self) end
    self:OnTheme(function(t) Lbl.TextColor3=t.Text end)
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- SECTION  — chevron-only collapse, ClipsDescendants managed dynamically
-- ─────────────────────────────────────────────────────────────────────────────
local Section={}; Section.__index=Section
function Section.new(tab, opts)
    local self=setmetatable({Tab=tab,Name=opts.Name or "Section",Collapsed=false},Section)

    local Con=Instance.new("Frame",tab.Instances.Content)
    Con.Size=UDim2.new(1,0,0,40)
    Con.BackgroundColor3=Theme.Current.Surface
    Con.BackgroundTransparency=0.18; Con.BorderSizePixel=0
    Corner(Con,10)
    local sStroke=Stroke(Con,Theme.Current.Border,0.55)

    -- Header row
    local Header=Instance.new("Frame",Con)
    Header.Size=UDim2.new(1,0,0,34); Header.BackgroundTransparency=1

    local Title=Instance.new("TextLabel",Header)
    Title.Size=UDim2.new(1,-36,1,0); Title.Position=UDim2.fromOffset(S.Normal+S.Small,0)
    Title.BackgroundTransparency=1; Title.Text=self.Name:upper()
    Title.TextColor3=Theme.Current.Accent; Title.TextSize=11
    Title.Font=Enum.Font.GothamBold; Title.TextXAlignment=Enum.TextXAlignment.Left

    -- Chevron button (collapse trigger — only this, not full header)
    local Chev=Instance.new("TextButton",Header)
    Chev.Size=UDim2.fromOffset(24,24); Chev.Position=UDim2.new(1,-30,0.5,0)
    Chev.AnchorPoint=Vector2.new(0,0.5); Chev.BackgroundTransparency=1
    Chev.Text="▾"; Chev.TextColor3=Theme.Current.TextDimmed
    Chev.Font=Enum.Font.GothamBold; Chev.TextSize=14

    local Content=Instance.new("Frame",Con)
    Content.Name="Content"; Content.Size=UDim2.new(1,-S.Huge,0,0)
    Content.Position=UDim2.fromOffset(S.Small+S.Tiny,34+S.Small)
    Content.BackgroundTransparency=1
    Content.ClipsDescendants=false   -- OFF: dropdowns must not be clipped

    local List=Instance.new("UIListLayout",Content)
    List.Padding=UDim.new(0,S.Normal)

    local function Recalc()
        if self.Collapsed then return end
        local h=List.AbsoluteContentSize.Y
        Content.Size=UDim2.new(1,-S.Huge,0,h)
        Con.Size=UDim2.new(1,0,0,h+34+S.Large+S.Small)
    end
    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Recalc)

    Chev.MouseButton1Click:Connect(function()
        self.Collapsed=not self.Collapsed
        local h=List.AbsoluteContentSize.Y
        if self.Collapsed then
            Tween:Create(Chev,TweenInfo.new(0.25,Enum.EasingStyle.Quint),{Rotation=−90}):Play()
            Tween:Create(Content,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{Size=UDim2.new(1,-S.Huge,0,0)}):Play()
            Tween:Create(Con,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{Size=UDim2.new(1,0,0,34+S.Normal)}):Play()
        else
            Tween:Create(Chev,TweenInfo.new(0.25,Enum.EasingStyle.Quint),{Rotation=0}):Play()
            Tween:Create(Content,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{Size=UDim2.new(1,-S.Huge,0,h)}):Play()
            Tween:Create(Con,TweenInfo.new(0.3,Enum.EasingStyle.Quint),{Size=UDim2.new(1,0,0,h+34+S.Large+S.Small)}):Play()
        end
    end)

    self.Instances={Content=Content,Container=Con,Stroke=sStroke}
    Theme.Changed:Connect(function(t)
        Con.BackgroundColor3=t.Surface; sStroke.Color=t.Border; Title.TextColor3=t.Accent
    end)
    return self
end

-- Section component factories
function Section:CreateButton(o)        return Button.new(self,o) end
function Section:CreateToggle(o)        return Toggle.new(self,o) end
function Section:CreateSlider(o)        return Slider.new(self,o) end
function Section:CreateDropdown(o)      return Dropdown.new(self,o) end
function Section:CreateColorPicker(o)   return ColorPicker.new(self,o) end
function Section:CreateKeybind(o)       return Keybind.new(self,o) end
function Section:CreateTextbox(o)       return Textbox.new(self,o) end
function Section:CreateParagraph(o)     return Paragraph.new(self,o) end
function Section:CreateMultiDropdown(o) return MultiDropdown.new(self,o) end
function Section:CreateSearchList(o)    return SearchList.new(self,o) end

-- ─────────────────────────────────────────────────────────────────────────────
-- TAB  — transition lock + coordinated fade+slide (#1)
-- ─────────────────────────────────────────────────────────────────────────────
local Tab={}; Tab.__index=Tab
function Tab.new(window, opts)
    local self=setmetatable({Window=window,Name=opts.Name or "Tab",Active=false,_maid=Maid.new()},Tab)

    local Btn=Instance.new("TextButton",window.Instances.TabContainer)
    Btn.Size=UDim2.new(1,0,0,34); Btn.BackgroundTransparency=1
    Btn.Text="  "..self.Name; Btn.TextColor3=Theme.Current.TextDimmed
    Btn.TextTransparency=0.45; Btn.TextXAlignment=Enum.TextXAlignment.Left
    Btn.Font=Enum.Font.GothamSemibold; Btn.TextSize=13; Corner(Btn,8)

    local ActiveBar=Instance.new("Frame",Btn)
    ActiveBar.Size=UDim2.new(0,3,0.6,0); ActiveBar.Position=UDim2.new(0,0,0.2,0)
    ActiveBar.BackgroundColor3=Theme.Current.Accent; ActiveBar.BackgroundTransparency=1
    ActiveBar.BorderSizePixel=0; Corner(ActiveBar,999)

    -- Content: ClipsDescendants OFF so dropdowns can overflow
    local Content=Instance.new("ScrollingFrame",window.Instances.ContentHost)
    Content.Size=UDim2.fromScale(1,1); Content.BackgroundTransparency=1
    Content.BorderSizePixel=0; Content.Visible=false; Content.ScrollBarThickness=0
    Content.ClipsDescendants=false    -- dropdowns need this off
    local SCL=Instance.new("UIListLayout",Content); SCL.Padding=UDim.new(0,S.Large)
    local CPad=Instance.new("UIPadding",Content)
    CPad.PaddingLeft=UDim.new(0,S.Normal); CPad.PaddingRight=UDim.new(0,S.Normal)
    CPad.PaddingTop=UDim.new(0,S.Normal); CPad.PaddingBottom=UDim.new(0,S.Normal)
    SCL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize=UDim2.new(0,0,0,SCL.AbsoluteContentSize.Y+S.Large)
    end)
    ScrollFade(Content)

    self.Instances={Button=Btn,Content=Content,ActiveBar=ActiveBar}
    Btn.MouseButton1Click:Connect(function() self:Select() end)
    return self
end

function Tab:Select()
    local win=self.Window
    if win._switching then return end    -- LOCK
    if win.CurrentTab==self then return end
    win._switching=true

    local old=win.CurrentTab
    win.CurrentTab=self; self.Active=true

    -- Activate button style immediately
    Tween:Create(self.Instances.Button,TweenInfo.new(0.22,Enum.EasingStyle.Quint),
        {BackgroundTransparency=0.88,BackgroundColor3=Theme.Current.Accent,
         TextColor3=Theme.Current.Text,TextTransparency=0}):Play()
    Tween:Create(self.Instances.ActiveBar,TweenInfo.new(0.22,Enum.EasingStyle.Quint),
        {BackgroundTransparency=0}):Play()

    if old then
        -- STEP 1: fade old OUT + slide left
        old.Active=false
        Tween:Create(old.Instances.Button,TweenInfo.new(0.2,Enum.EasingStyle.Quint),
            {BackgroundTransparency=1,TextColor3=Theme.Current.TextDimmed,TextTransparency=0.45}):Play()
        Tween:Create(old.Instances.ActiveBar,TweenInfo.new(0.2,Enum.EasingStyle.Quint),
            {BackgroundTransparency=1}):Play()

        -- slide old content out
        Tween:Create(old.Instances.Content,TweenInfo.new(0.22,Enum.EasingStyle.Quint),{
            Position=UDim2.fromOffset(-S.Large,0),
        }):Play()
        task.delay(0.22,function()
            -- STEP 2: hide old
            old.Instances.Content.Visible=false
            old.Instances.Content.Position=UDim2.fromOffset(0,0)

            -- STEP 3+4: show + slide new content IN
            self.Instances.Content.Position=UDim2.fromOffset(S.Large,0)
            self.Instances.Content.Visible=true
            Tween:Create(self.Instances.Content,TweenInfo.new(0.28,Enum.EasingStyle.Quint),{
                Position=UDim2.fromOffset(0,0),
            }):Play()

            task.delay(0.28,function() win._switching=false end)
        end)
    else
        self.Instances.Content.Visible=true
        win._switching=false
    end
end

function Tab:CreateSection(o) return Section.new(self,o) end
function Tab:SetIcon(id)
    if self.Instances.Icon then self.Instances.Icon:Destroy() end
    local Ic=Instance.new("ImageLabel",self.Instances.Button)
    Ic.Size=UDim2.fromOffset(16,16); Ic.Position=UDim2.fromOffset(S.Normal,S.Normal+1)
    Ic.BackgroundTransparency=1; Ic.Image="rbxassetid://"..tostring(id)
    Ic.ImageColor3=Theme.Current.TextMuted; self.Instances.Icon=Ic
    self.Instances.Button.Text="      "..self.Name
end

-- ─────────────────────────────────────────────────────────────────────────────
-- WINDOW  — spring open, dragging, viewport scale
-- ─────────────────────────────────────────────────────────────────────────────
local Window={}; Window.__index=Window
function Window.new(opts)
    local self=setmetatable({
        Title=opts.Title or "Window",
        Size=opts.Size or UDim2.fromOffset(780,530),
        _maid=Maid.new(),
        _switching=false,
    },Window)

    local SGui=Instance.new("ScreenGui",Core)
    SGui.Name="PhantomUI_v4"; SGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

    local Main=Instance.new("Frame",SGui)
    Main.Size=UDim2.fromOffset(0,0); Main.Position=UDim2.fromScale(0.5,0.5)
    Main.AnchorPoint=Vector2.new(0.5,0.5)
    Main.BackgroundColor3=Theme.Current.Background
    Main.BackgroundTransparency=0.12; Main.BorderSizePixel=0
    Corner(Main,12); Shadow(Main,12,0.38); Noise(Main)
    Stroke(Main,Theme.Current.Border,0.65)

    local Scale=Instance.new("UIScale",Main)
    Scale.Scale=0.92

    -- Sidebar
    local Sidebar=Instance.new("Frame",Main)
    Sidebar.Size=UDim2.new(0,200,1,0)
    Sidebar.BackgroundColor3=Theme.Current.Surface
    Sidebar.BackgroundTransparency=0.20; Sidebar.BorderSizePixel=0; Corner(Sidebar,12)

    local Divider=Instance.new("Frame",Main)
    Divider.Size=UDim2.new(0,1,1,-S.Huge*2); Divider.Position=UDim2.fromOffset(200,S.Huge)
    Divider.BackgroundColor3=Theme.Current.Border; Divider.BackgroundTransparency=0.6
    Divider.BorderSizePixel=0

    local TitleLbl=Instance.new("TextLabel",Sidebar)
    TitleLbl.Size=UDim2.new(1,-S.Huge,0,42); TitleLbl.Position=UDim2.fromOffset(S.Normal+S.Small,S.Small)
    TitleLbl.BackgroundTransparency=1; TitleLbl.Text=self.Title
    TitleLbl.TextColor3=Theme.Current.Text; TitleLbl.Font=Enum.Font.GothamBold
    TitleLbl.TextSize=16; TitleLbl.TextXAlignment=Enum.TextXAlignment.Left

    local TabContainer=Instance.new("ScrollingFrame",Sidebar)
    TabContainer.Size=UDim2.new(1,-S.Normal,1,-54)
    TabContainer.Position=UDim2.fromOffset(S.Small,52)
    TabContainer.BackgroundTransparency=1; TabContainer.BorderSizePixel=0
    TabContainer.ScrollBarThickness=0; TabContainer.ClipsDescendants=true
    local TCL=Instance.new("UIListLayout",TabContainer); TCL.Padding=UDim.new(0,S.Small)

    -- Content host: right panel, ClipsDescendants OFF for dropdowns
    local ContentHost=Instance.new("Frame",Main)
    ContentHost.Size=UDim2.new(1,-208,1,-S.Normal*2)
    ContentHost.Position=UDim2.fromOffset(204,S.Normal)
    ContentHost.BackgroundTransparency=1; ContentHost.ClipsDescendants=false

    self.Instances={ScreenGui=SGui,Main=Main,TabContainer=TabContainer,Sidebar=Sidebar,ContentHost=ContentHost}
    self._maid:Give(SGui)

    -- Smooth drag
    local targetPos=Main.Position; local dragging,dragStart,startPos
    Main.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=inp.Position; startPos=Main.Position
        end
    end)
    self._maid:Give(UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
            local d=inp.Position-dragStart
            targetPos=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end))
    self._maid:Give(UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end))
    Animator:Add(function(dt)
        Main.Position=Main.Position:Lerp(targetPos,1-math.exp(-28*dt))
    end)

    -- Spring open: scale 0.92→1 elastic, transparency 1→0.12 exponential
    Main.BackgroundTransparency=1
    Tween:Create(Main,TweenInfo.new(0.55,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out),
        {Size=self.Size,BackgroundTransparency=0.12}):Play()
    Tween:Create(Scale,TweenInfo.new(0.65,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out,1,false,0),
        {Scale=math.clamp(Cam.ViewportSize.Y/1080,0.8,1)}):Play()

    return self
end

function Window:CreateTab(opts)
    local t=Tab.new(self,opts)
    if not self.CurrentTab then t:Select() end
    return t
end
function Window:EnableResizing()
    local RBtn=Instance.new("ImageButton",self.Instances.Main)
    RBtn.Size=UDim2.fromOffset(16,16); RBtn.Position=UDim2.new(1,-16,1,-16)
    RBtn.BackgroundTransparency=1; RBtn.Image="rbxassetid://6031091007"
    RBtn.ImageColor3=Theme.Current.TextMuted; RBtn.Rotation=45
    local res,ss,sm
    RBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            res=true; ss=self.Instances.Main.Size; sm=UIS:GetMouseLocation()
        end
    end)
    self._maid:Give(UIS.InputChanged:Connect(function(inp)
        if res and inp.UserInputType==Enum.UserInputType.MouseMovement then
            local d=UIS:GetMouseLocation()-sm
            self.Instances.Main.Size=UDim2.fromOffset(
                math.clamp(ss.X.Offset+d.X,420,1100),
                math.clamp(ss.Y.Offset+d.Y,300,860))
        end
    end))
    self._maid:Give(UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then res=false end
    end))
end

-- ─────────────────────────────────────────────────────────────────────────────
-- COLOR PICKER  — global input tracking, on OverlayFrame (#4)
-- ─────────────────────────────────────────────────────────────────────────────
ColorPicker=setmetatable({},Component); ColorPicker.__index=ColorPicker
function ColorPicker.new(section, opts)
    local self=Component.new(opts.Name or "Color Picker")
    setmetatable(self,ColorPicker)
    self.Value=opts.Default or Color3.new(1,1,1)
    self.Callback=opts.Callback or function() end; self.Open=false
    self.CurrentValue=self.Value
    local h0,s0,v0=self.Value:ToHSV(); self.H,self.S,self.V=h0,s0,v0

    local Con=Instance.new("Frame",section.Instances.Content)
    Con.Size=UDim2.new(1,0,0,34); Con.BackgroundTransparency=1

    local Lbl=Instance.new("TextLabel",Con)
    Lbl.Size=UDim2.new(1,-60,1,0); Lbl.BackgroundTransparency=1
    Lbl.Text=self.Name; Lbl.TextColor3=Theme.Current.Text
    Lbl.Font=Enum.Font.GothamSemibold; Lbl.TextSize=13
    Lbl.TextXAlignment=Enum.TextXAlignment.Left

    local Prev=Instance.new("TextButton",Con)
    Prev.Size=UDim2.fromOffset(40,22); Prev.Position=UDim2.new(1,-40,0.5,0)
    Prev.AnchorPoint=Vector2.new(0,0.5); Prev.BackgroundColor3=self.Value; Prev.Text=""
    Corner(Prev,S.Small); Stroke(Prev,Theme.Current.Border,0.5)

    -- Picker panel on Overlay
    local Panel=Instance.new("Frame",GetOverlay())
    Panel.Size=UDim2.fromOffset(190,170); Panel.BackgroundColor3=Theme.Current.Surface
    Panel.Visible=false; Panel.ZIndex=9999; Corner(Panel,S.Normal); Shadow(Panel,S.Normal,0.42)
    local PStroke=Stroke(Panel,Theme.Current.Border,0.55)

    -- SV square
    local SV=Instance.new("ImageButton",Panel)
    SV.Size=UDim2.fromOffset(144,144); SV.Position=UDim2.fromOffset(S.Normal,S.Normal)
    SV.Image="rbxassetid://4155801252"; SV.BackgroundColor3=Color3.fromHSV(self.H,1,1)
    SV.ZIndex=9999

    -- SV cursor dot
    local SVDot=Instance.new("Frame",SV)
    SVDot.Size=UDim2.fromOffset(10,10); SVDot.AnchorPoint=Vector2.new(0.5,0.5)
    SVDot.BackgroundColor3=Color3.new(1,1,1); SVDot.BorderSizePixel=0; SVDot.ZIndex=10000; Corner(SVDot,999)
    local SVDotStroke=Stroke(SVDot,Color3.new(0,0,0),0)

    -- Hue bar
    local Hue=Instance.new("ImageButton",Panel)
    Hue.Size=UDim2.fromOffset(14,144); Hue.Position=UDim2.fromOffset(S.Normal+144+S.Small,S.Normal)
    Hue.Image="rbxassetid://4155801337"; Hue.ZIndex=9999

    -- Hue cursor
    local HueDot=Instance.new("Frame",Hue)
    HueDot.Size=UDim2.new(1,4,0,4); HueDot.AnchorPoint=Vector2.new(0.5,0.5)
    HueDot.BackgroundColor3=Color3.new(1,1,1); HueDot.BorderSizePixel=0; HueDot.ZIndex=10000; Corner(HueDot,999)

    local draggingSV,draggingHue=false,false

    local function UpdateCursors()
        SVDot.Position=UDim2.fromScale(self.S,1-self.V)
        HueDot.Position=UDim2.new(0.5,0,1-self.H,0)
    end
    local function Apply()
        self.Value=Color3.fromHSV(self.H,self.S,self.V)
        self.CurrentValue=self.Value
        Prev.BackgroundColor3=self.Value
        SV.BackgroundColor3=Color3.fromHSV(self.H,1,1)
        UpdateCursors()
        self.Callback(self.Value)
        Config:Save()
    end

    -- Global input tracking — works even when cursor leaves the widget
    self._maid:Give(UIS.InputChanged:Connect(function(inp)
        if inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local m=Mouse()
        if draggingSV then
            local rp=SV.AbsolutePosition; local rs=SV.AbsoluteSize
            self.S=math.clamp((m.X-rp.X)/rs.X,0,1)
            self.V=1-math.clamp((m.Y-rp.Y)/rs.Y,0,1)
            Apply()
        elseif draggingHue then
            local rp=Hue.AbsolutePosition; local rs=Hue.AbsoluteSize
            self.H=1-math.clamp((m.Y-rp.Y)/rs.Y,0,1)
            Apply()
        end
    end))
    self._maid:Give(UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            draggingSV=false; draggingHue=false
        end
    end))

    SV.MouseButton1Down:Connect(function() draggingSV=true end)
    Hue.MouseButton1Down:Connect(function() draggingHue=true end)

    local function PositionPanel()
        local ap=Prev.AbsolutePosition; local as=Prev.AbsoluteSize
        Panel.Position=UDim2.fromOffset(ap.X+as.X+S.Normal,ap.Y-S.Normal)
    end

    Prev.MouseButton1Click:Connect(function()
        self.Open=not self.Open
        Panel.Visible=self.Open
        if self.Open then PositionPanel(); UpdateCursors() end
    end)

    -- Close on outside click
    self._maid:Give(UIS.InputBegan:Connect(function(inp)
        if self.Open and inp.UserInputType==Enum.UserInputType.MouseButton1 then
            local m=Mouse()
            local pp=Panel.AbsolutePosition; local ps=Panel.AbsoluteSize
            local ep=Prev.AbsolutePosition; local es=Prev.AbsoluteSize
            local inPanel=m.X>=pp.X and m.X<=pp.X+ps.X and m.Y>=pp.Y and m.Y<=pp.Y+ps.Y
            local inPrev=m.X>=ep.X and m.X<=ep.X+es.X and m.Y>=ep.Y and m.Y<=ep.Y+es.Y
            if not inPanel and not inPrev then self.Open=false; Panel.Visible=false end
        end
    end))

    function self:Set(v)
        self.Value=v; self.CurrentValue=v; Prev.BackgroundColor3=v
        local hn,sn,vn=v:ToHSV(); self.H,self.S,self.V=hn,sn,vn
        SV.BackgroundColor3=Color3.fromHSV(hn,1,1); UpdateCursors()
    end

    Apply()  -- set initial cursor positions

    if opts.Flag then Config:Register(opts.Flag,self) end
    self:OnTheme(function(t) Lbl.TextColor3=t.Text end)
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- KEYBIND
-- ─────────────────────────────────────────────────────────────────────────────
Keybind=setmetatable({},Component); Keybind.__index=Keybind
function Keybind.new(section, opts)
    local self=Component.new(opts.Name or "Keybind")
    setmetatable(self,Keybind)
    self.Binding=opts.Default or Enum.KeyCode.F
    self.Callback=opts.Callback or function() end; self.IsBinding=false
    self.CurrentKeybind=self.Binding.Name; self.CurrentValue=self.Binding.Name

    local Con=Instance.new("Frame",section.Instances.Content)
    Con.Size=UDim2.new(1,0,0,34); Con.BackgroundTransparency=1

    local Lbl=Instance.new("TextLabel",Con)
    Lbl.Size=UDim2.new(1,-80,1,0); Lbl.BackgroundTransparency=1
    Lbl.Text=self.Name; Lbl.TextColor3=Theme.Current.Text
    Lbl.Font=Enum.Font.GothamSemibold; Lbl.TextSize=13
    Lbl.TextXAlignment=Enum.TextXAlignment.Left

    local BindBtn=Instance.new("TextButton",Con)
    BindBtn.Size=UDim2.fromOffset(70,22); BindBtn.Position=UDim2.new(1,-70,0.5,0)
    BindBtn.AnchorPoint=Vector2.new(0,0.5); BindBtn.BackgroundColor3=Theme.Current.Surface
    BindBtn.BackgroundTransparency=0.08; BindBtn.Text=self.Binding.Name
    BindBtn.TextColor3=Theme.Current.TextMuted; BindBtn.Font=Enum.Font.GothamBold
    BindBtn.TextSize=11; Corner(BindBtn,S.Small)
    local bStroke=Stroke(BindBtn,Theme.Current.Border,0.55)

    BindBtn.MouseButton1Click:Connect(function()
        self.IsBinding=true; BindBtn.Text="..."; bStroke.Color=Theme.Current.Accent
        local conn; conn=UIS.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                self.Binding=inp.KeyCode; self.CurrentKeybind=self.Binding.Name
                self.CurrentValue=self.CurrentKeybind
                BindBtn.Text=self.Binding.Name; self.IsBinding=false
                bStroke.Color=Theme.Current.Border; conn:Disconnect(); Config:Save()
            end
        end)
    end)

    self._maid:Give(UIS.InputBegan:Connect(function(inp,gpe)
        if not gpe and inp.KeyCode==self.Binding and not self.IsBinding then self.Callback() end
    end))

    function self:Set(v)
        local kc=Enum.KeyCode[v]
        if kc then self.Binding=kc; self.CurrentKeybind=v; self.CurrentValue=v; BindBtn.Text=v end
    end

    if opts.Flag then Config:Register(opts.Flag,self) end
    self:OnTheme(function(t) Lbl.TextColor3=t.Text end)
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TEXTBOX
-- ─────────────────────────────────────────────────────────────────────────────
Textbox=setmetatable({},Component); Textbox.__index=Textbox
function Textbox.new(section, opts)
    local self=Component.new(opts.Name or "Textbox")
    setmetatable(self,Textbox)
    self.Placeholder=opts.Placeholder or "Type here..."
    self.Callback=opts.Callback or function() end; self.CurrentValue=""

    local Con=Instance.new("Frame",section.Instances.Content)
    Con.Size=UDim2.new(1,0,0,60); Con.BackgroundTransparency=1

    local Lbl=Instance.new("TextLabel",Con)
    Lbl.Size=UDim2.new(1,0,0,20); Lbl.BackgroundTransparency=1
    Lbl.Text=self.Name; Lbl.TextColor3=Theme.Current.Text
    Lbl.Font=Enum.Font.GothamSemibold; Lbl.TextSize=13
    Lbl.TextXAlignment=Enum.TextXAlignment.Left

    local Box=Instance.new("TextBox",Con)
    Box.Size=UDim2.new(1,0,0,34); Box.Position=UDim2.fromOffset(0,24)
    Box.BackgroundColor3=Theme.Current.Surface; Box.BackgroundTransparency=0.08
    Box.Text=""; Box.PlaceholderText=self.Placeholder
    Box.PlaceholderColor3=Theme.Current.TextDimmed; Box.TextColor3=Theme.Current.Text
    Box.Font=Enum.Font.Gotham; Box.TextSize=13; Box.ClearTextOnFocus=false; Corner(Box,8)
    local bStroke=Stroke(Box,Theme.Current.Border,0.55)

    Box.Focused:Connect(function()
        Tween:Create(bStroke,TweenInfo.new(0.2),{Color=Theme.Current.Accent,Transparency=0.1}):Play()
    end)
    Box.FocusLost:Connect(function(enter)
        Tween:Create(bStroke,TweenInfo.new(0.2),{Color=Theme.Current.Border,Transparency=0.55}):Play()
        self.CurrentValue=Box.Text
        if enter then self.Callback(Box.Text) end
    end)

    function self:Set(v) Box.Text=v; self.CurrentValue=v end
    if opts.Flag then Config:Register(opts.Flag,self) end
    self:OnTheme(function(t) Lbl.TextColor3=t.Text; Box.TextColor3=t.Text end)
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- PARAGRAPH
-- ─────────────────────────────────────────────────────────────────────────────
Paragraph=setmetatable({},Component); Paragraph.__index=Paragraph
function Paragraph.new(section, opts)
    local self=Component.new("Paragraph")
    setmetatable(self,Paragraph)
    self.Title=opts.Title or "Info"; self.Content=opts.Content or ""

    local Con=Instance.new("Frame",section.Instances.Content)
    Con.Size=UDim2.new(1,0,0,60); Con.BackgroundColor3=Theme.Current.Surface
    Con.BackgroundTransparency=0.45; Corner(Con,8)
    local pStroke=Stroke(Con,Theme.Current.Border,0.65)
    pStroke.DashPattern={4,4}

    local T=Instance.new("TextLabel",Con)
    T.Size=UDim2.new(1,-S.Huge,0,20); T.Position=UDim2.fromOffset(S.Normal,S.Normal)
    T.BackgroundTransparency=1; T.Text=self.Title
    T.TextColor3=Theme.Current.Text; T.Font=Enum.Font.GothamBold; T.TextSize=13
    T.TextXAlignment=Enum.TextXAlignment.Left

    local C=Instance.new("TextLabel",Con)
    C.Size=UDim2.new(1,-S.Huge,0,0); C.Position=UDim2.fromOffset(S.Normal,30)
    C.BackgroundTransparency=1; C.Text=self.Content
    C.TextColor3=Theme.Current.TextDimmed; C.TextTransparency=0.35
    C.Font=Enum.Font.Gotham; C.TextSize=12; C.TextWrapped=true
    C.TextXAlignment=Enum.TextXAlignment.Left

    local function Resize()
        local sz=Text:GetTextSize(self.Content,12,Enum.Font.Gotham,
            Vector2.new(Con.AbsoluteSize.X-S.Huge,1000))
        C.Size=UDim2.new(1,-S.Huge,0,sz.Y)
        Con.Size=UDim2.new(1,0,0,sz.Y+S.Huge*3)
    end
    Con:GetPropertyChangedSignal("AbsoluteSize"):Connect(Resize); task.spawn(Resize)
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- MULTI DROPDOWN
-- ─────────────────────────────────────────────────────────────────────────────
MultiDropdown=setmetatable({},Component); MultiDropdown.__index=MultiDropdown
function MultiDropdown.new(section, opts)
    local self=Component.new(opts.Name or "Multi-Dropdown")
    setmetatable(self,MultiDropdown)
    self.Options=opts.Options or {}; self.Selected=opts.Default and {table.unpack(opts.Default)} or {}
    self.Callback=opts.Callback or function() end; self.Open=false
    self.CurrentValue=self.Selected

    local Con=Instance.new("Frame",section.Instances.Content)
    Con.Size=UDim2.new(1,0,0,60); Con.BackgroundTransparency=1

    local Lbl=Instance.new("TextLabel",Con)
    Lbl.Size=UDim2.new(1,0,0,20); Lbl.BackgroundTransparency=1
    Lbl.Text=self.Name; Lbl.TextColor3=Theme.Current.Text
    Lbl.Font=Enum.Font.GothamSemibold; Lbl.TextSize=13
    Lbl.TextXAlignment=Enum.TextXAlignment.Left

    local Sel=Instance.new("TextButton",Con)
    Sel.Size=UDim2.new(1,0,0,34); Sel.Position=UDim2.fromOffset(0,24)
    Sel.BackgroundColor3=Theme.Current.Surface; Sel.BackgroundTransparency=0.08
    Sel.BorderSizePixel=0; Sel.AutoButtonColor=false; Sel.Text=""; Corner(Sel,8)
    local selStroke=Stroke(Sel,Theme.Current.Border,0.55)

    local SelLbl=Instance.new("TextLabel",Sel)
    SelLbl.Size=UDim2.new(1,-32,1,0); SelLbl.Position=UDim2.fromOffset(S.Normal,0)
    SelLbl.BackgroundTransparency=1
    SelLbl.Text=#self.Selected>0 and table.concat(self.Selected,", ") or "Select..."
    SelLbl.TextColor3=Theme.Current.TextMuted; SelLbl.Font=Enum.Font.Gotham
    SelLbl.TextSize=13; SelLbl.TextXAlignment=Enum.TextXAlignment.Left
    SelLbl.ClipsDescendants=true

    -- List on overlay
    local List=Instance.new("ScrollingFrame",GetOverlay())
    List.BackgroundColor3=Theme.Current.SurfaceDeep; List.BackgroundTransparency=0.04
    List.BorderSizePixel=0; List.Visible=false; List.ZIndex=9999; List.ScrollBarThickness=0
    Corner(List,8); Shadow(List,8,0.45)
    local LL=Instance.new("UIListLayout",List); LL.Padding=UDim.new(0,2)
    local LP=Instance.new("UIPadding",List)
    LP.PaddingTop=UDim.new(0,S.Small); LP.PaddingBottom=UDim.new(0,S.Small)
    LP.PaddingLeft=UDim.new(0,S.Small); LP.PaddingRight=UDim.new(0,S.Small)

    local function UpdateLabel()
        SelLbl.Text=#self.Selected>0 and table.concat(self.Selected,", ") or "Select..."
        SelLbl.TextColor3=#self.Selected>0 and Theme.Current.Text or Theme.Current.TextMuted
        self.CurrentValue=self.Selected; self.Callback(self.Selected); Config:Save()
    end

    for _,opt in ipairs(self.Options) do
        local OB=Instance.new("TextButton",List)
        OB.Size=UDim2.new(1,0,0,32); OB.BackgroundTransparency=1
        OB.Text="  "..opt; OB.Font=Enum.Font.Gotham; OB.TextSize=13
        OB.TextXAlignment=Enum.TextXAlignment.Left; OB.ZIndex=9999
        local isSel=table.find(self.Selected,opt)~=nil
        OB.TextColor3=isSel and Theme.Current.Accent or Theme.Current.TextMuted

        local Tick=Instance.new("TextLabel",OB)
        Tick.Size=UDim2.fromOffset(16,16); Tick.Position=UDim2.new(1,-20,0.5,0)
        Tick.AnchorPoint=Vector2.new(0,0.5); Tick.BackgroundTransparency=1
        Tick.Text=isSel and "✓" or ""; Tick.TextColor3=Theme.Current.Accent
        Tick.Font=Enum.Font.GothamBold; Tick.TextSize=12; Tick.ZIndex=9999

        OB.MouseButton1Click:Connect(function()
            local idx=table.find(self.Selected,opt)
            if idx then
                table.remove(self.Selected,idx)
                OB.TextColor3=Theme.Current.TextMuted; Tick.Text=""
            else
                table.insert(self.Selected,opt)
                OB.TextColor3=Theme.Current.Accent; Tick.Text="✓"
            end
            UpdateLabel()
        end)
    end

    local function PosAndShow()
        local ap=Sel.AbsolutePosition; local as=Sel.AbsoluteSize
        local targetH=math.min(#self.Options*34+S.Normal*2,200)
        List.Position=UDim2.fromOffset(ap.X,ap.Y+as.Y+S.Small)
        List.Size=UDim2.fromOffset(as.X,targetH)
        List.Visible=true
        selStroke.Color=Theme.Current.Accent; selStroke.Transparency=0.2
    end
    local function HideList()
        self.Open=false; List.Visible=false
        Tween:Create(selStroke,TweenInfo.new(0.18),{Color=Theme.Current.Border,Transparency=0.55}):Play()
    end

    Sel.MouseButton1Click:Connect(function()
        self.Open=not self.Open
        if self.Open then PosAndShow() else HideList() end
    end)

    self._maid:Give(UIS.InputBegan:Connect(function(inp)
        if self.Open and inp.UserInputType==Enum.UserInputType.MouseButton1 then
            local m=Mouse(); local lp=List.AbsolutePosition; local ls=List.AbsoluteSize
            local sp2=Sel.AbsolutePosition; local ss=Sel.AbsoluteSize
            local inL=m.X>=lp.X and m.X<=lp.X+ls.X and m.Y>=lp.Y and m.Y<=lp.Y+ls.Y
            local inS=m.X>=sp2.X and m.X<=sp2.X+ss.X and m.Y>=sp2.Y and m.Y<=sp2.Y+ss.Y
            if not inL and not inS then HideList() end
        end
    end))

    function self:Set(v)
        self.Selected=v; self.CurrentValue=v
        SelLbl.Text=#v>0 and table.concat(v,", ") or "Select..."
        SelLbl.TextColor3=#v>0 and Theme.Current.Text or Theme.Current.TextMuted
    end

    if opts.Flag then Config:Register(opts.Flag,self) end
    self:OnTheme(function(t) Lbl.TextColor3=t.Text end)
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- SEARCH LIST
-- ─────────────────────────────────────────────────────────────────────────────
SearchList=setmetatable({},Component); SearchList.__index=SearchList
function SearchList.new(section, opts)
    local self=Component.new(opts.Name or "Search List")
    setmetatable(self,SearchList)
    self.Items=opts.Items or {}; self.Callback=opts.Callback or function() end

    local Con=Instance.new("Frame",section.Instances.Content)
    Con.Size=UDim2.new(1,0,0,200); Con.BackgroundColor3=Theme.Current.Surface
    Con.BackgroundTransparency=0.45; Corner(Con,10)
    Stroke(Con,Theme.Current.Border,0.55)

    local Bar=Instance.new("TextBox",Con)
    Bar.Size=UDim2.new(1,-S.Huge,0,30); Bar.Position=UDim2.fromOffset(S.Normal,S.Normal)
    Bar.BackgroundColor3=Theme.Current.Background; Bar.BackgroundTransparency=0.06
    Bar.Text=""; Bar.PlaceholderText="Search..."; Bar.PlaceholderColor3=Theme.Current.TextDimmed
    Bar.TextColor3=Theme.Current.Text; Bar.Font=Enum.Font.Gotham; Bar.TextSize=12
    Bar.ClearTextOnFocus=false; Corner(Bar,S.Small)

    local Scroll=Instance.new("ScrollingFrame",Con)
    Scroll.Size=UDim2.new(1,-S.Huge,1,-50); Scroll.Position=UDim2.fromOffset(S.Normal,45)
    Scroll.BackgroundTransparency=1; Scroll.BorderSizePixel=0
    Scroll.ScrollBarThickness=2; Scroll.ScrollBarImageColor3=Theme.Current.Border
    local SL=Instance.new("UIListLayout",Scroll); SL.Padding=UDim.new(0,S.Small)
    SL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize=UDim2.new(0,0,0,SL.AbsoluteContentSize.Y+S.Normal)
    end)
    ScrollFade(Scroll)

    local function Populate(f)
        for _,ch in ipairs(Scroll:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
        for _,item in ipairs(self.Items) do
            if not f or item:lower():find(f:lower(),1,true) then
                local B=Instance.new("TextButton",Scroll)
                B.Size=UDim2.new(1,-S.Small,0,28); B.BackgroundTransparency=0.92
                B.BackgroundColor3=Color3.new(1,1,1); B.Text="  "..item
                B.TextColor3=Theme.Current.Text; B.Font=Enum.Font.Gotham; B.TextSize=12
                B.TextXAlignment=Enum.TextXAlignment.Left; Corner(B,S.Small)
                B.MouseEnter:Connect(function() B.BackgroundTransparency=0.85 end)
                B.MouseLeave:Connect(function() B.BackgroundTransparency=0.92 end)
                B.MouseButton1Click:Connect(function() self.Callback(item) end)
            end
        end
    end
    Populate()
    Bar:GetPropertyChangedSignal("Text"):Connect(function() Populate(Bar.Text) end)
    return self
end

-- ─────────────────────────────────────────────────────────────────────────────
-- NOTIFICATIONS
-- ─────────────────────────────────────────────────────────────────────────────
local NQueue={Active={},Pending={},MAX=5}
local function SpawnNotif(opts)
    local Title=opts.Title or "Notice"; local Content=opts.Content or ""
    local Duration=opts.Duration or 5; local Type=opts.Type or "Default"
    local accent=({Success=Theme.Current.Success,Error=Theme.Current.Danger,
        Warning=Color3.fromRGB(234,179,8)})[Type] or Theme.Current.Accent

    local NG=Core:FindFirstChild("PhantomNotifs_v4")
    if not NG then
        NG=Instance.new("ScreenGui",Core); NG.Name="PhantomNotifs_v4"
        NG.DisplayOrder=200
    end
    local Wrap=NG:FindFirstChild("Wrap")
    if not Wrap then
        Wrap=Instance.new("Frame",NG); Wrap.Name="Wrap"
        Wrap.Size=UDim2.new(0,310,1,-S.Huge*2); Wrap.Position=UDim2.new(1,-330,0,S.Huge)
        Wrap.BackgroundTransparency=1
        local WL=Instance.new("UIListLayout",Wrap)
        WL.VerticalAlignment=Enum.VerticalAlignment.Bottom; WL.Padding=UDim.new(0,S.Normal)
    end

    local T=Instance.new("Frame",Wrap)
    T.Size=UDim2.new(1,0,0,72); T.BackgroundColor3=Theme.Current.Background
    T.BackgroundTransparency=0.12; Corner(T,10)
    local ts=Stroke(T,accent,0.65); Shadow(T,10,0.5)

    local Bar=Instance.new("Frame",T)
    Bar.Size=UDim2.new(0,3,0.7,0); Bar.Position=UDim2.new(0,0,0.15,0)
    Bar.BackgroundColor3=accent; Bar.BorderSizePixel=0; Corner(Bar,999)

    local TL=Instance.new("TextLabel",T)
    TL.Size=UDim2.new(1,-S.Huge,0,24); TL.Position=UDim2.fromOffset(S.Normal,S.Normal)
    TL.BackgroundTransparency=1; TL.Text=Title; TL.TextColor3=accent
    TL.Font=Enum.Font.GothamBold; TL.TextSize=13; TL.TextXAlignment=Enum.TextXAlignment.Left

    local CL=Instance.new("TextLabel",T)
    CL.Size=UDim2.new(1,-S.Huge,0,18); CL.Position=UDim2.fromOffset(S.Normal,32)
    CL.BackgroundTransparency=1; CL.Text=Content; CL.TextColor3=Theme.Current.TextMuted
    CL.Font=Enum.Font.Gotham; CL.TextSize=12; CL.TextXAlignment=Enum.TextXAlignment.Left

    local PT=Instance.new("Frame",T)
    PT.Size=UDim2.new(1,-S.Huge,0,3); PT.Position=UDim2.new(0,S.Normal,1,-S.Normal)
    PT.AnchorPoint=Vector2.new(0,1); PT.BackgroundColor3=Theme.Current.Border
    PT.BackgroundTransparency=0.5; PT.BorderSizePixel=0; Corner(PT,999)

    local PF=Instance.new("Frame",PT)
    PF.Size=UDim2.fromScale(1,1); PF.BackgroundColor3=accent; PF.BorderSizePixel=0; Corner(PF,999)

    T.Position=UDim2.new(1,320,0,0)
    Tween:Create(T,TweenInfo.new(0.55,Enum.EasingStyle.Quint),{Position=UDim2.new(0,0,0,0)}):Play()
    Tween:Create(PF,TweenInfo.new(Duration,Enum.EasingStyle.Linear),{Size=UDim2.fromScale(0,1)}):Play()

    task.delay(Duration,function()
        Tween:Create(T,TweenInfo.new(0.45,Enum.EasingStyle.Quint),{Position=UDim2.new(1,320,0,0)}):Play()
        task.wait(0.45); T:Destroy()
        for i,a in ipairs(NQueue.Active) do if a==opts then table.remove(NQueue.Active,i); break end end
        if #NQueue.Pending>0 then
            local nx=table.remove(NQueue.Pending,1); table.insert(NQueue.Active,nx); SpawnNotif(nx)
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- LIBRARY API
-- ─────────────────────────────────────────────────────────────────────────────
local Library={Version="4.0.0",Open=true,Windows={},_maid=Maid.new(),Theme=Theme,Config=Config}

function Library:CreateWindow(opts)
    if opts.ConfigurationSaving then
        local cs=opts.ConfigurationSaving
        Config.Enabled=cs.Enabled~=false; Config.FileName=cs.FileName
        Config.Folder=cs.FolderName or "PhantomUI"
    end
    GetOverlay()  -- init overlay early
    local w=Window.new(opts)
    table.insert(self.Windows,w)
    if Config.Enabled and Config.FileName then
        task.defer(function() Config:Load() end); Config:AutoSave(30)
    end
    return w
end

function Library:Notify(opts)
    if #NQueue.Active>=NQueue.MAX then table.insert(NQueue.Pending,opts); return end
    table.insert(NQueue.Active,opts); SpawnNotif(opts)
end

function Library:SetTheme(name) Theme:Set(name) end

function Library:Destroy()
    for _,w in ipairs(self.Windows) do w._maid:Destroy() end
    self.Windows={}; self._maid:Destroy()
    if OverlayGui then OverlayGui:Destroy(); OverlayGui=nil; OverlayFrame=nil end
end

-- Global toggle (RightControl)
Library._maid:Give(UIS.InputBegan:Connect(function(inp,gpe)
    if not gpe and inp.KeyCode==Enum.KeyCode.RightControl then
        Library.Open=not Library.Open
        for _,w in ipairs(Library.Windows) do w.Instances.ScreenGui.Enabled=Library.Open end
    end
end))

-- Viewport scale update
Library._maid:Give(Cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local sc=math.clamp(Cam.ViewportSize.Y/1080,0.8,1)
    for _,w in ipairs(Library.Windows) do
        for _,c in ipairs(w.Instances.Main:GetChildren()) do
            if c:IsA("UIScale") then c.Scale=sc end
        end
    end
end))

-- Theme propagation to window frames
Theme.Changed:Connect(function(t)
    for _,w in ipairs(Library.Windows) do
        if w.Instances and w.Instances.Main then
            w.Instances.Main.BackgroundColor3=t.Background
            w.Instances.Sidebar.BackgroundColor3=t.Surface
        end
    end
end)

task.spawn(function()
    print("────────────────────────────────────")
    print("  PhantomUI v4.0.0  — Bug Fix Build")
    print("────────────────────────────────────")
end)

return Library
