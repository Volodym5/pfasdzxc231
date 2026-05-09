local Theme = {
    Background = Color3.fromRGB(11, 12, 16),
    Sidebar = Color3.fromRGB(14, 15, 20),
    Surface = Color3.fromRGB(18, 19, 26),
    SurfaceHover = Color3.fromRGB(24, 25, 34),
    Border = Color3.fromRGB(38, 40, 52),
    Accent = Color3.fromRGB(99, 102, 241),
    Text = Color3.fromRGB(238, 240, 255),
    Subtext = Color3.fromRGB(150, 155, 175),
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(255, 184, 77),
}

local Spacing = {
    XS = 4,
    SM = 8,
    MD = 12,
    LG = 16,
    XL = 24
}

local Radius = {
    Small = 5,
    Medium = 8,
    Large = 12,
    Pill = 999
}

local Animations = {
    Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quint),
    Medium = TweenInfo.new(0.18, Enum.EasingStyle.Quint),
    Slow = TweenInfo.new(0.26, Enum.EasingStyle.Exponential),
}

return {Theme = Theme, Spacing = Spacing, Radius = Radius, Animations = Animations}
