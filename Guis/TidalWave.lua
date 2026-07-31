local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
	return cloneref(game:GetService(Service))
end

local RunService: RunService = GetService("RunService")
local HttpService = GetService("HttpService")
local Players: Players = GetService("Players")
local CoreGui: CoreGui = GetService("CoreGui")
local TweenService: TweenService = GetService("TweenService")
local UIS: UserInputService = GetService("UserInputService")
local TextService: TextService = GetService("TextService")
local MarketplaceService: MarketplaceService = GetService("MarketplaceService")
local GuiService: GuiService = GetService("GuiService")

local Plr: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
local Enum = Enum
local Color3 = table.clone(Color3)
function Color3.fromRGBT(R, G, B, T)
	local self = {}
    self.R = R or 255
    self.G = G or 255
    self.B = B or 255
    self.T = T or 0
    self.Transparency = self.T
    self.Color = Color3.fromRGB(self.R, self.G, self.B)

    return self
end
Color3.Black = Color3.new()
Color3.White = Color3.new(1, 1, 1)
local Instance = Instance
local TweenInfo = TweenInfo
local UDim2 = UDim2
local UDim = UDim
local math = math
local task = task
local Font = Font
local table = table.clone(table)
function table.len(Tab)
	local Len = 0
	for _ in Tab do
		Len += 1
	end
	return Len
end

local IsStudio = RunService:IsStudio()

local Lucide = IsStudio and require(script.Parent.Parent.Libraries.Lucide) or nil
local loadstring = IsStudio and require(script.Parent.Parent.Libraries.Loadstring) or loadstring
local queueonteleport = queueonteleport or queue_on_teleport
local identifyexecutor = identifyexecutor
local loadfile = loadfile
local readfile = readfile
local isfile = isfile
local writefile = writefile
local delfile = delfile
local listfiles = listfiles
local gethui = gethui

if isfile('TidalWave/Libraries/Lucide.lua') then
	Lucide = loadstring(readfile('TidalWave/Libraries/Lucide.lua'), 'Lucide')()
else
	local Data = game:HttpGet('https://gitlab.com/upio/lucide-roblox-direct/-/raw/main/source.lua?ref_type=heads')
	writefile('TidalWave/Libraries/Lucide.lua', Data)
	Lucide = loadstring(Data, 'Lucide')()
end

if IsStudio then
	local FileSystem = require(script.Parent.Parent.Libraries.FileSystem)
	readfile = FileSystem.readfile
	isfile = FileSystem.isfile
	writefile = FileSystem.writefile
	delfile = FileSystem.delfile
	listfiles = FileSystem.listfiles
	loadfile = function(Path)
        return loadstring(readfile(Path))
    end
end

local function Run(f)
    f()
end

local function AddMaid(Obj)
    Obj.Connections = {}
	local Metatable = {
		__index = function(self, i)
			if i == 'Connected' then
				return self._Connected()
			end
		end
	}

    function Obj:Clean(Connection: RBXScriptConnection | thread | Instance | (...any) -> (...any) , ...: any)
        local Type = typeof(Connection)

        local Disconnect
        local Connected
		local ConnectionObject = {}

        if Type == "Instance" then
            Disconnect = function()
                Connection:Destroy()
                Obj.Connections[Connection] = nil
            end
            Connected = function()
                return Connection and Connection.Parent ~= nil
            end

			local Con; Con = Connection.AncestryChanged:Connect(function(_, Parent)
				if Parent == nil then
					Con:Disconnect()
					Con = nil
					Obj.Connections[Connection] = nil
				end
			end)
        elseif Type == "function" then
            local Args = {...}
            Disconnect = function()
                Connection(table.unpack(Args))
                Obj.Connections[Connection] = nil
            end
            Connected = function()
                return true
            end
        elseif Type == "RBXScriptConnection" then
            Disconnect = function()
                Connection:Disconnect()
                Obj.Connections[Connection] = nil
            end
            Connected = function()
                return Connection and Connection.Connected
            end
        elseif Type == "thread" then
            Disconnect = function()
                pcall(task.cancel, Connection)
                Obj.Connections[Connection] = nil
            end
            Connected = function()
                return Connection and coroutine.status(Connection) ~= "dead"
            end
        end

		ConnectionObject.Disconnect = Disconnect
		ConnectionObject.Destroy = Disconnect
		ConnectionObject.Remove = Disconnect
		ConnectionObject.Type = Type
		ConnectionObject._Connected = Connected

        setmetatable(ConnectionObject, Metatable)

        Obj.Connections[Connection] = ConnectionObject

        return ConnectionObject
    end

	function Obj:CleanUp()
		for i, v in Obj.Connections do
			if not v.Connected then
				Obj.Connections[i] = nil
			end
		end
	end

    function Obj:DisconnectAll()
        for _, v in Obj.Connections do
            v:Disconnect()
        end
    end
end

local function AddInstanceTable(Obj)
	Obj.Instances = {}
	Obj.InstanceConnections = {}

	function Obj:GetInstance(Name)
		return self.Instances[Name]
	end

	function Obj:GetInstances()
		return self.Instances
	end

	function Obj:RemoveInstance(Name)
		local Con = self.InstanceConnections[Name]
		if Con then
			Con:Disconnect()
			self.InstanceConnections[Name] = nil
		end
		local Object = self.Instances[Name]
		if Object then
			Object:Destroy()
			self.Instances[Name] = nil
		end
	end

	function Obj:CreateInstance(Class, Name, Properties)
		self:RemoveInstance(Name)
		local Inst = Instance.new(Class)
		if Properties then
			local Parent = Properties.Parent
			Properties.Parent = nil
			for i, v in Properties do
				Inst[i] = v
			end
			Inst.Parent = Parent
		end

		local Con; Con = Inst.AncestryChanged:Connect(function(_, NewParent)
			if NewParent == nil then
				Con:Disconnect()
				Inst:Destroy()
				self.Instances[Name], Con, Inst = nil, nil, nil
			end
		end)

		self.Instances[Name], self.InstanceConnections[Name] = Inst, Con

		return Inst
	end

	function Obj:ClearInstances()
		for Name in self.Instances do
			self:RemoveInstance(Name)
		end
	end
end

local BuiltInThemes = {
    TidalWave = {
        BuiltIn = true,
        Main = {
            Accent = Color3.fromRGBT(18, 124, 230),
            Icons = Color3.fromRGBT(255, 255, 255),
            EnabledBar = Color3.fromRGBT(18, 124, 230),
            DisabledBar = Color3.fromRGBT(0, 75, 133),
        },
        Text = {
            Primary = Color3.fromRGBT(255, 255, 255),
            Placeholder = Color3.fromRGBT(127, 127, 127),
            Shadow = Color3.fromRGBT(0, 0, 0),
            Tooltip = Color3.fromRGBT(255, 255, 255)
        },
        Background = {
            Primary = Color3.fromRGBT(25, 25, 25),
            Secondary = Color3.fromRGBT(18, 18, 18),
            Button = Color3.fromRGBT(20, 20, 20),
            ButtonHover = Color3.fromRGBT(40, 40, 40),
            ButtonPress = Color3.fromRGBT(20, 20, 20),
            Tooltip = Color3.fromRGBT(0, 0, 0, 0.3),
            Notification = Color3.fromRGBT(0, 0, 0, 0.2),
        },
        Outline = {
            Primary = Color3.fromRGBT(0, 0, 0),
            Tooltip = Color3.fromRGBT(0, 0, 0),
            Notification = Color3.fromRGBT(0, 0, 0),
        },
        Slider = {
            Handle = Color3.fromRGBT(18, 124, 230),
            HandleHover = Color3.fromRGBT(0, 128, 255),
            HandlePress = Color3.fromRGBT(18, 124, 230),
            LeftBar = Color3.fromRGBT(14, 97, 180),
            RightBar = Color3.fromRGBT(40, 40, 40),
        },
        Notification = {
            ProgressBar = Color3.fromRGBT(255, 255, 255),
            Info = Color3.fromRGBT(255, 255, 255),
            Warning = Color3.fromRGBT(255, 75, 0),
            Error = Color3.fromRGBT(255, 75, 75),
            ModuleEnabled = Color3.fromRGBT(75, 255, 75),
            ModuleDisabled = Color3.fromRGBT(255, 75, 75),
        },
    }
}

local Gui = {
	Scale = true,
    Tooltip = true,
    Notifications = true,
    CategoryAnimations = true,
    RainbowRunning = false,
    RainbowRefreshRate = 60,
    RainbowSpeed = 1,
    RainbowSpread = 1,
	ModuleNotificationDuration = 2,
	Profile = "Default",
    NotificationHorizontalAlignment = "Right",
    NotificationVerticalAlignment = "Bottom",
    NotificationFillDirection = "Up",
    RainbowTable = {},
	Profiles = {},
    Friends = {},
	PressedKeys = {},
	Menus = {},
	Modules = {},
    Buttons = {},
	Categories = {},
	Fonts = {
		Regular = {
			Name = "Gotham",
            Font = Font.fromEnum(Enum.Font.Gotham),
		},
		SemiBold = {
			Name = "GothamMedium",
            Font = Font.fromEnum(Enum.Font.GothamMedium),
		},
		Bold = {
			Name = "GothamBold",
            Font = Font.fromEnum(Enum.Font.GothamBold),
		}
	},
	CurrentVersion = shared.TidalWaveVersion,
	PlaceName = MarketplaceService:GetProductInfoAsync(game.PlaceId).Name,
    Themes = table.clone(BuiltInThemes),
    Theme = "TidalWave",
}
AddMaid(Gui)

if identifyexecutor then
	Gui.Executor, Gui.ExecutorVersion = identifyexecutor()
end

local SearchMatches = {}

local function GetCurrentTheme()
    return Gui.Themes[Gui.Theme]
end

local function GetColor(Type)
    local CurrentTheme = GetCurrentTheme()

    if CurrentTheme then
        local CurrentColor

        for _, v in Type:split("/") do
            CurrentColor = (CurrentColor or CurrentTheme)[v]
            if not CurrentColor then
                warn(debug.traceback(`Invalid Color: {Type}`))
                return Color3.White
            end
        end

        return CurrentColor.Color, CurrentColor.T
    else
        warn(debug.traceback(`Failed to find theme: {Gui.Theme}`))
        return Color3.White
    end
end

local function SetColor(Type, Color, Transparency)
    local CurrentTheme = GetCurrentTheme()

    if CurrentTheme and not CurrentTheme.BuiltIn then
        local First, Second = table.unpack(Type:split("/"))
        if Color.R > 1 or Color.G > 1 or Color.B > 1 then
            Color = {R = Color.R / 255, G = Color.G / 255, B = Color.B / 255}
        end
        CurrentTheme[First][Second] = Color3.fromRGBT(Color.R * 255, Color.G * 255, Color.B * 255, Transparency or CurrentTheme[First][Second].Transparency or 0)
    end
end

local function GetFont(Font)
    return Gui.Fonts[Font].Font
end

local function ApplyColor(Obj, Properties)
    for i, v in Properties do
        local Color, Transparency = GetColor(i)
        for i2 = 1, #v, 2 do
            if Color and v[i2] then
                Obj[v[i2]] = Color
            end
            if Transparency and v[i2 + 1] then
                Obj[v[i2 + 1]] = Transparency
            end
        end
    end
end

local function AddRGB(Tab)
    table.insert(Gui.RainbowTable, Tab)
    if not Gui.RainbowRunning then
        Gui.RainbowRunning = Gui:Clean(task.spawn(function()
            while Gui.RainbowRunning do
                for _, Color in Gui.RainbowTable do
                    local Hue = tick() * (Gui.RainbowSpeed * 0.2) % 1
                    Color:SetColor(Color3.fromHSV(Hue, 1, 1))
                end
                task.wait(1 / Gui.RainbowRefreshRate)
            end
        end))
    end
end

local function RemoveRGB(Tab)
    for i, v in Gui.RainbowTable do
        if v == Tab then
            table.remove(Gui.RainbowTable, i)
            if table.len(Gui.RainbowTable) == 0 then
                Gui.RainbowRunning:Disconnect()
                Gui.RainbowRunning = 0
            end
            break
        end
    end
end

local function AddCorner(Obj, CornerRadius)
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = CornerRadius
	UICorner.Parent = Obj
end

local function AddHighlight(Obj, UseSecondaryColor)
	local Info = TweenInfo.new(0.25)
	local Info2 = TweenInfo.new(0.1)
	Obj.MouseEnter:Connect(function()
		TweenService:Create(Obj, Info, {BackgroundColor3 = GetColor("Background/ButtonHover")}):Play()
	end)
	Obj.MouseLeave:Connect(function()
        if SearchMatches[Obj] then TweenService:Create(Obj, Info2, {BackgroundColor3 = GetColor("Background/ButtonHover")}):Play() return end
		TweenService:Create(Obj, Info, {BackgroundColor3 = UseSecondaryColor and GetColor("Background/Secondary") or GetColor("Background/Button")}):Play()
	end)
	Obj.MouseButton1Down:Connect(function()
		TweenService:Create(Obj, Info2, {BackgroundColor3 = UseSecondaryColor and GetColor("Background/Secondary") or GetColor("Background/Button")}):Play()
	end)
	Obj.MouseButton1Up:Connect(function()
        if not Gui.Theme then return end
		TweenService:Create(Obj, Info2, {BackgroundColor3 = GetColor("Background/ButtonHover")}):Play()
	end)
end

local function TweenEnabledBar(Bar, Enabled)
    if Bar and Enabled ~= nil then
        TweenService:Create(Bar, TweenInfo.new(0.2), {BackgroundColor3 = Enabled and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')}):Play()
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = `TidalWave v{Gui.CurrentVersion}`
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 69420
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = gethui and gethui() or CoreGui and CoreGui:FindFirstChild("RobloxGui") or CoreGui or Plr:FindFirstChildOfClass("PlayerGui")
Gui.Gui = ScreenGui

local ScaledGui = Instance.new("Frame")
ScaledGui.Name = "ScaledGui"
ScaledGui.BackgroundTransparency = 1
ScaledGui.Size = UDim2.fromScale(1, 1)
ScaledGui.Parent = ScreenGui

local UIScale = Instance.new("UIScale")
UIScale.Scale = math.max(ScreenGui.AbsoluteSize.X / 1920, 0.6)
UIScale.Parent = ScaledGui
ScaledGui.Size = UDim2.fromScale(1 / UIScale.Scale, 1 / UIScale.Scale)

local HudFolder = Instance.new("Frame")
HudFolder.Name = "Hud"
HudFolder.Size = UDim2.fromScale(1, 1)
HudFolder.BackgroundTransparency = 1
HudFolder.Parent = ScaledGui

local GuiFolder = Instance.new("Frame")
GuiFolder.Name = "Gui"
GuiFolder.Size = UDim2.fromScale(1, 1)
GuiFolder.BackgroundTransparency = 1
GuiFolder.Parent = ScaledGui

local CategoryHolder = Instance.new("Frame")
CategoryHolder.Name = "Categories"
CategoryHolder.Size = UDim2.fromScale(1, 1)
CategoryHolder.BackgroundTransparency = 1
CategoryHolder.Visible = false
CategoryHolder.Parent = GuiFolder

local MenuHolder = Instance.new("Frame")
MenuHolder.Name = "Menus"
MenuHolder.Size = UDim2.fromScale(1, 1)
MenuHolder.BackgroundTransparency = 1
MenuHolder.Parent = GuiFolder

local NotificationFolder = Instance.new("TextButton")
NotificationFolder.Name = "Notifications"
NotificationFolder.Size = UDim2.new(0, 270, 1)
NotificationFolder.Position = UDim2.new(1, -270, 0, 0)
NotificationFolder.BackgroundTransparency = 1
NotificationFolder.Text = ""
NotificationFolder.Active = false
NotificationFolder.Interactable = false
NotificationFolder.Parent = HudFolder

local Tooltip = Instance.new("TextLabel")
Tooltip.Name = "Tooltip"
Tooltip.TextColor3 = GetColor("Text/Primary")
Tooltip.BackgroundColor3 = GetColor("Background/Tooltip")
Tooltip.BorderSizePixel = 0
Tooltip.BackgroundTransparency = 0.3
Tooltip.FontFace = GetFont('Regular')
Tooltip.Size = UDim2.fromOffset(100, 24)
Tooltip.TextSize = 16
Tooltip.ZIndex = 3
Tooltip.Visible = false
Tooltip.Interactable = false
Tooltip.TextWrapped = true
Tooltip.Parent = GuiFolder
AddCorner(Tooltip, UDim.new(0, 5))

local TooltipUIStroke = Instance.new("UIStroke")
TooltipUIStroke.Thickness = 1
TooltipUIStroke.Color = GetColor("Outline/Tooltip")
TooltipUIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
TooltipUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
TooltipUIStroke.Parent = Tooltip

local Modal = Instance.new("TextButton")
Modal.Name = "Modal"
Modal.BackgroundTransparency = 1
Modal.Interactable = false
Modal.Active = false
Modal.Modal = true
Modal.Visible = false
Modal.Text = ""
Modal.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.BorderSizePixel = 0
TopBar.BackgroundColor3 = GetColor("Background/Primary")
TopBar.Position = UDim2.new(0.5, 0, 0, 12)
TopBar.Size = UDim2.fromOffset(0, 44)
TopBar.AnchorPoint = Vector2.new(0.5, 0)
TopBar.Visible = false
TopBar.Parent = GuiFolder
AddCorner(TopBar, UDim.new(0, 11))

local TopBarUIListLayout = Instance.new("UIListLayout")
TopBarUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TopBarUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TopBarUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TopBarUIListLayout.FillDirection = Enum.FillDirection.Horizontal
TopBarUIListLayout.Padding = UDim.new(0, 8)
TopBarUIListLayout.Parent = TopBar

local Cursor = Instance.new("ImageLabel")
Cursor.Name = "Cursor"
Cursor.Image = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
Cursor.Visible = false
Cursor.Size = UDim2.fromOffset(64, 64)
Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
Cursor.BackgroundTransparency = 1
Cursor.ZIndex = 69420
Cursor.Parent = ScreenGui

local GetTextBoundsParams = Instance.new("GetTextBoundsParams")

Gui:Clean(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	if Gui.Scale then
		UIScale.Scale = math.max(ScreenGui.AbsoluteSize.X / 1920, 0.6)
	end
end))

Gui:Clean(UIScale:GetPropertyChangedSignal("Scale"):Connect(function()
	ScaledGui.Size = UDim2.fromScale(1 / UIScale.Scale, 1 / UIScale.Scale)
	for _, v in ScaledGui:QueryDescendants('GuiObject[Visible = true]') do
		v.Visible = false
		v.Visible = true
	end
end))

Gui:Clean(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
end))

local function GetTextSize(Text, TextSize, Font, Size)
    GetTextBoundsParams.Text = Text
    GetTextBoundsParams.Font = Font
    GetTextBoundsParams.Size = TextSize
    GetTextBoundsParams.Width = Size
	GetTextBoundsParams.RichText = Text:match("<[^<>]->") ~= nil
    return TextService:GetTextBoundsAsync(GetTextBoundsParams)
end

local function CreateTopBarButton(Properties)
	local Table = {}

    local Size = math.max(GetTextSize(Properties.Name, 24, GetFont('Regular'), 200).X + 10, 80)
	local Button = Instance.new("TextButton")
	Button.Text = Properties.Name
	Button.Name = Properties.Name
	Button.LayoutOrder = #TopBar:GetChildren()
	Button.Size = UDim2.fromOffset(Size, 36)
	Button.BackgroundColor3 = GetColor("Background/Button")
	Button.BackgroundTransparency = 0.25
	Button.BorderSizePixel = 0
	Button.TextColor3 = GetColor("Text/Primary")
	Button.AutoButtonColor = false
	Button.FontFace = GetFont('Regular')
	Button.TextSize = 24
	Button.Parent = TopBar
	AddCorner(Button, UDim.new(0, 9))

	TopBar.Size += UDim2.fromOffset(Size + 8, 0)

    local Info = TweenInfo.new(0.1)

	function Table:Select(...)
		for _, v in TopBar:GetChildren() do
			if v:IsA("TextButton") then
				if v == Button then
                    local ButtonHover = GetColor("Background/ButtonHover")
					if v.BackgroundColor3 ~= ButtonHover then
						TweenService:Create(Button, Info, {BackgroundColor3 = ButtonHover}):Play()
					end
					if Properties.Function then
						Properties.Function(...)
					end
				else
                    local Button = GetColor("Background/Button")
					if v.BackgroundColor3 ~= Button then
						TweenService:Create(v, Info, {BackgroundColor3 = Button}):Play()
					end
				end
			end
		end
        Gui.SelectedTopBar = Button
	end

	Button.MouseButton1Click:Connect(Table.Select)

    Table.Object = Button

	return Table
end

local function SetIcon(Obj, IconName)
	local Icon = Lucide.GetAsset(IconName)
	Obj.Image = Icon.Url
	Obj.ImageRectOffset = Icon.ImageRectOffset
	Obj.ImageRectSize = Icon.ImageRectSize
end

local function AddTooltip(Obj, Text)
	if typeof(Text) == "string" and Text:match("%w") then
		local function OnMouseMoved()
			local MouseLocation = UIS:GetMouseLocation()
			local X = MouseLocation.X
			local Y = MouseLocation.Y - Tooltip.AbsoluteSize.Y
			if X + Tooltip.AbsoluteSize.X > Camera.ViewportSize.X then
				X -= Tooltip.AbsoluteSize.X
			end
			Tooltip.Position = UDim2.fromOffset(X / UIScale.Scale, Y / UIScale.Scale)
		end

		Obj.MouseEnter:Connect(function()
            if not Gui.Tooltip then return end
            local Size = GetTextSize(Text, Tooltip.TextSize, GetFont('Regular'), Camera.ViewportSize.X * 0.5)
			Tooltip.Text = Text
			Tooltip.Size = UDim2.fromOffset(Size.X + 10, Size.Y + 10)
			OnMouseMoved()
			Tooltip.Visible = true
		end)

		Obj.MouseMoved:Connect(OnMouseMoved)
		Obj.MouseLeave:Connect(function()
			Tooltip.Visible = false
		end)
	end
end

local function LoopClean(Tab)
	for _, v in Tab do
        local Type = typeof(v)
		if Type == "table" then
			LoopClean(v)
        elseif Type == 'thread' then
            pcall(task.cancel, v)
        elseif Type == 'RBXScriptConnection' then
            v:Disconnect()
		end
	end
	table.clear(Tab)
end

function Gui:Shutdown()
	Gui:Save()
	for _, v in Gui.Modules do
		if v.Enabled then
			v:Toggle(true)
		end
	end
	Gui:DisconnectAll()
	Gui.Libraries.CharacterLib:Shutdown()
	ScreenGui:Destroy()
	LoopClean(Gui)
	shared.TidalWave = nil
    shared.TidalWaveVersion = nil
	shared.TidalWaveDev = nil
end

local function RemoveTags(Str)
	return Str:gsub("<[^<>]->", "")
end

Run(function()
    local NotificationTweens = {
		Tweens = {},
		Tweens2 = {},
	}
	local Notifications = {}
	local Info = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    
	local function Tween(Obj, Goal, Tab)
		Tab = Tab or NotificationTweens.Tweens
		if Tab[Obj] then
			Tab[Obj]:Cancel()
			Tab[Obj] = nil
		end

		if Obj.Parent and Obj.Visible then
			Tab[Obj] = TweenService:Create(Obj, Info, Goal)
			Tab[Obj].Completed:Once(function()
				Tab[Obj] = nil
			end)
			Tab[Obj]:Play()
		else
			for i, v in Goal do
				Obj[i] = v
			end
		end
	end

	function Gui:Notify(Properties: {Text: string, Title: string?, Duration: number?, Type: "Info" | "Warning" | "Error"?})
		if not Gui.Notifications then return end
		task.delay(0, function()
			local Right, Bottom, FillDirectionUp = Gui.NotificationHorizontalAlignment == "Right", Gui.NotificationVerticalAlignment == "Bottom", Gui.NotificationFillDirection == "Up"
            local Width = math.max(GetTextSize(Properties.Text, 15, GetFont('Regular'), 1000).X + 60, 260)
			local YOffset = (29 + (78 * (#Notifications + 1)))

			local Frame = Instance.new('Frame')
			Frame.Name = "Notification"
			Frame.Position = UDim2.new(Right and 1 or 0, Right and 5 or -5, Bottom and 1 or 0, Bottom and FillDirectionUp and -YOffset or YOffset)
			Frame.Size = UDim2.fromOffset(Width, 75)
			Frame.BackgroundColor3, Frame.BackgroundTransparency = GetColor("Background/Notification")
			Frame.AnchorPoint = Right and Vector2.zero or Vector2.xAxis
			Frame.Parent = NotificationFolder
			AddCorner(Frame, UDim.new(0, 6))

            Notifications[#Notifications + 1] = Frame

			local UIStroke = Instance.new('UIStroke')
			UIStroke.Thickness = 1
			UIStroke.Color = GetColor('Outline/Notification')
			UIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
            UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			UIStroke.Parent = Frame

			local TitleShadow = Instance.new("TextLabel")
			TitleShadow.Name = "TitleShadow"
			TitleShadow.Position = UDim2.fromOffset(40, 6)
			TitleShadow.Size = UDim2.new(1, -80, 0, 20)
			TitleShadow.BackgroundTransparency = 1
			TitleShadow.TextColor3 = GetColor('Text/Shadow')
			TitleShadow.TextSize = 17
			TitleShadow.FontFace = GetFont('SemiBold')
			TitleShadow.Text = Properties.Title and RemoveTags(Properties.Title) or "Tidal Wave"
            TitleShadow.TextXAlignment = Enum.TextXAlignment.Left
			TitleShadow.Parent = Frame

			local Title = TitleShadow:Clone()
            Title.Size = UDim2.fromScale(1, 1)
			Title.Name = "Title"
			Title.TextColor3 = GetColor('Text/Primary')
			Title.RichText = true
			Title.Text = Properties.Title or "<font color = 'rgb(255, 215, 0)'>Tidal</font> <font color = 'rgb(20, 135, 255)'>Wave</font>"
			Title.Position = UDim2.fromOffset(-1, -1)
			Title.Parent = TitleShadow

            local NotificationType = Instance.new("ImageLabel")
            NotificationType.Name = "NotificationType"
            NotificationType.Size = UDim2.fromOffset(14, 14)
            NotificationType.Position = UDim2.fromOffset(10, 10)
            NotificationType.BackgroundTransparency = 1
            NotificationType.ImageColor3 = (Properties.Type == nil or Properties.Type == "Info") and GetColor('Notification/Info') or Properties.Type == "Warning" and GetColor('Notification/Warning') or Properties.Type == "Error" and GetColor('Notification/Error')
            SetIcon(NotificationType, (Properties.Type == nil or Properties.Type == "Info") and "info" or (Properties.Type == "Warning" or Properties.Type == "Error") and "circle-alert")
            NotificationType.Parent = Frame

			local TextShadow = Instance.new("TextLabel")
			TextShadow.Name = "TextShadow"
			TextShadow.Position = UDim2.fromOffset(40, 30)
			TextShadow.Size = UDim2.new(1, -40, 0, 40)
			TextShadow.BackgroundTransparency = 1
			TextShadow.TextColor3 = GetColor('Text/Shadow')
			TextShadow.TextSize = 15
			TextShadow.FontFace = GetFont('Regular')
			TextShadow.Text = RemoveTags(Properties.Text)
            TextShadow.TextXAlignment = Enum.TextXAlignment.Left
            TextShadow.TextWrapped = true
			TextShadow.Parent = Frame

			local Text = TextShadow:Clone()
			Text.Name = "TextLabel"
            Text.Size = UDim2.fromScale(1, 1)
			Text.RichText = true
			Text.TextColor3 = GetColor('Text/Primary')
			Text.Text = Properties.Text
			Text.Position = UDim2.fromOffset(-1, -1)
			Text.Parent = TextShadow

			local Progress = Instance.new("Frame")
			Progress.Name = "Progress"
			Progress.BackgroundColor3 = GetColor('Notification/ProgressBar')
			Progress.BorderSizePixel = 0
			Progress.Size = UDim2.new(1, -2, 0, 2)
			Progress.Position = UDim2.new(0, 3, 1, -4)
			Progress.Parent = Frame

			local Duration = Properties.Duration or 2

			Tween(Frame, {AnchorPoint = Right and Vector2.xAxis or Vector2.zero})
			TweenService:Create(Progress, TweenInfo.new(Duration), {Size = UDim2.fromOffset(0, 2)}):Play()

			task.delay(Duration, function()
				Tween(Frame, {AnchorPoint = Right and Vector2.zero or Vector2.xAxis})
				task.wait(0.25)

				table.remove(Notifications, table.find(Notifications, Frame))
				Frame:Destroy()

				for i, v in Notifications do
					YOffset = (29 + (78 * i))
                    local Goal = {Position = UDim2.new(Right and 1 or 0, Right and 5 or -5, Bottom and 1 or 0, Bottom and FillDirectionUp and -YOffset or YOffset)}
					Tween(v, Goal, NotificationTweens.Tweens2)
				end
			end)
		end)
	end
end)

local function Notify(Properties)
	Gui:Notify(Properties)
end

local function NotifyPoopSploit(FunctionName: string)
	Notify({
		Title = "Poop Sploit",
		Text = `{Gui.Executor or "Your Executor"} doesn't support "{FunctionName}"`,
        Type = "Error",
		Duration = 4,
	})
end

local Components
Components = {
	Delete = function(Properties)
		local DeleteKeybind = Instance.new("TextButton")
        DeleteKeybind.Name = "Delete"
        DeleteKeybind.BackgroundColor3 = GetColor('Background/Button')
        DeleteKeybind.Text = ""
        DeleteKeybind.BorderSizePixel = 0
        DeleteKeybind.Size = UDim2.fromOffset(40, 40)
        DeleteKeybind.Position = UDim2.new(1, -40, 0, 0)
        DeleteKeybind.AutoButtonColor = false
        DeleteKeybind.Parent = Properties.Parent
        AddCorner(DeleteKeybind, UDim.new(0, 7))
        AddHighlight(DeleteKeybind)

        local DeleteKeybindImage = Instance.new("ImageLabel")
        DeleteKeybindImage.Name = "Image"
        DeleteKeybindImage.BackgroundTransparency = 1
        DeleteKeybindImage.Size = UDim2.fromOffset(24, 24)
        DeleteKeybindImage.Position = UDim2.fromOffset(8, 8)
        SetIcon(DeleteKeybindImage, "x")
        DeleteKeybindImage.Parent = DeleteKeybind

		DeleteKeybind.MouseButton1Click:Connect(Properties.Function)
	end,
	Reset = function(Properties)
		local ResetButton = Instance.new("TextButton")
		ResetButton.Name = "Reset"
		ResetButton.BackgroundColor3 = GetColor("Background/Button")
		ResetButton.Text = ""
		ResetButton.BorderSizePixel = 0
		ResetButton.Size = UDim2.fromOffset(40, 40)
		ResetButton.Position = UDim2.new(1, -40, 0, 0)
		ResetButton.AutoButtonColor = false
		ResetButton.Parent = Properties.Parent
		AddCorner(ResetButton, UDim.new(0, 7))
		AddHighlight(ResetButton)

		local ResetButtonImage = Instance.new("ImageLabel")
		ResetButtonImage.Name = "Image"
		ResetButtonImage.BackgroundTransparency = 1
		ResetButtonImage.Size = UDim2.fromOffset(24, 24)
		ResetButtonImage.Position = UDim2.fromOffset(8, 8)
		SetIcon(ResetButtonImage, "rotate-cw")
		ResetButtonImage.Parent = ResetButton

		ResetButton.MouseButton1Click:Connect(Properties.Function)
	end,
	Button = function(Properties)
		local Button = {
			Visible = if Properties.Visible ~= nil then Properties.Visible else true,
            Type = "Button"
		}

		local TextButton = Instance.new("TextButton")
		TextButton.Name = `{Properties.Name}Button`
		TextButton.BackgroundColor3 = GetColor('Background/Button')
		TextButton.Size = UDim2.new(1, -100, 0, 40)
		TextButton.LayoutOrder = Properties.LayoutOrder
		TextButton.TextXAlignment = Enum.TextXAlignment.Left
		TextButton.TextSize = 24
		TextButton.FontFace = GetFont('Regular')
		TextButton.Text = ` {Properties.Name}`
		TextButton.AutoButtonColor = false
		TextButton.TextColor3 = GetColor('Text/Primary')
		TextButton.Parent = Properties.Parent
		AddCorner(TextButton, UDim.new(0, 7))
		AddTooltip(TextButton, Properties.Info or Properties.Tooltip)
		AddHighlight(TextButton)

		TextButton.MouseButton1Click:Connect(Properties.Function)

		Button.Toggle = Properties.Function
		Button.Object = TextButton

		Properties.Module.Buttons[Properties.Name:gsub(" ", "")] = Button

		return Button
	end,
    Keybind = function(Properties)
        local Keybind = {
            Keybind = Properties.Keybind or 'None',
            Hold = if Properties.UseHold ~= nil then Properties.Hold or false else nil
        }

        local MainFrame = Instance.new("Frame")
        MainFrame.Name = `{Properties.Name}Keybind`
        MainFrame.BackgroundTransparency = 1
        MainFrame.Size = UDim2.new(1, -100, 0, 40)
        MainFrame.LayoutOrder = Properties.LayoutOrder
        MainFrame.Parent = Properties.Parent

        local Background = Instance.new("Frame")
        Background.Name = "Background"
        Background.BackgroundColor3 = GetColor('Background/Button')
        Background.BorderSizePixel = 0
        Background.Size = UDim2.new(1, -45, 1, 0)
        Background.Parent = MainFrame
        AddCorner(Background, UDim.new(0, 7))

        local KeybindName = Instance.new("TextLabel")
        KeybindName.Name = "KeybindName"
        KeybindName.BackgroundTransparency = 1
        KeybindName.Size = UDim2.fromOffset(200, 40)
        KeybindName.TextColor3 = GetColor('Text/Primary')
        KeybindName.TextSize = 24
        KeybindName.FontFace = GetFont('Regular')
        KeybindName.Text = Properties.Text and ` {Properties.Text}` or ` {Properties.Name} Keybind`
        KeybindName.TextXAlignment = Enum.TextXAlignment.Left
        KeybindName.Parent = Background

        local BindButton = Instance.new("TextButton")
        BindButton.Name = "BindButton"
        BindButton.BackgroundColor3 = GetColor('Background/Secondary')
        BindButton.BorderSizePixel = 0
        BindButton.Size = UDim2.fromOffset(200, 30)
        BindButton.Position = UDim2.fromOffset(200, 5)
        BindButton.TextColor3 = GetColor('Text/Primary')
        BindButton.TextSize = 24
        BindButton.FontFace = GetFont('Regular')
        BindButton.Text = Properties.Keybind or "None"
        BindButton.AutoButtonColor = false
        BindButton.Parent = Background
        AddCorner(BindButton, UDim.new(0, 7))
        AddHighlight(BindButton, GetColor('Background/Secondary'))
        AddTooltip(BindButton, "Click to bind")

        local EnabledBar

        if Properties.UseHold then
            local Hold = Instance.new("TextButton")
            Hold.Name = "Hold"
            Hold.BackgroundColor3 = GetColor('Background/Secondary')
            Hold.BorderSizePixel = 0
            Hold.Size = UDim2.fromOffset(140, 30)
            Hold.Position = UDim2.fromOffset(410, 5)
            Hold.TextColor3 = GetColor('Text/Primary')
            Hold.TextSize = 24
            Hold.FontFace = GetFont('Regular')
            Hold.AutoButtonColor = false
            Hold.Text = "Hold"
            Hold.Parent = Background
            AddCorner(Hold, UDim.new(0, 7))
            AddHighlight(Hold, GetColor('Background/Secondary'))
            AddTooltip(Hold, 'Makes you able to hold the keybind rather then just pressing the keybind.')

            EnabledBar = Instance.new("Frame")
            EnabledBar.Name = "Enabled"
            EnabledBar.BackgroundColor3 = Keybind.Hold and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
            EnabledBar.Size = UDim2.fromOffset(2, 24)
            EnabledBar.Position = UDim2.new(1, -8, 0, 3)
            EnabledBar.BorderSizePixel = 0
            EnabledBar.Parent = Hold
        else
            BindButton.Position += UDim2.fromOffset(150, 0)
        end

        BindButton.MouseButton1Click:Connect(function()
			if Gui.Binding then
				Gui.Binding = nil
				BindButton.Text = Keybind.Keybind or "None"
			else
				BindButton.Text = "Press Key"
                task.wait()
				Gui.Binding = Keybind
			end
		end)

		function Keybind:SetKeybind(Bind)
			self.Keybind = Bind or 'None'
			BindButton.Text = self.Keybind
            if Properties.Function then
                Properties.Function(self.Keybind)
            end
		end

        function Keybind:ToggleHold()
            if self.Hold ~= nil and EnabledBar then
                self.Hold = not self.Hold
                TweenEnabledBar(EnabledBar, self.Hold)
            end
        end

		local UserInputTypes = {
			["MouseButton1"] = true,
			["MouseButton2"] = true,
			["MouseButton3"] = true,
		}

		local SecondaryKeybind

        function Keybind:IsPressed()
			if SecondaryKeybind and SecondaryKeybind:IsPressed() then return true end
			if self.Keybind == 'None' then return false end
			for _, v in self.Keybind:split('+') do
				local Key = UserInputTypes[v] and Enum.UserInputType[v].Name or Enum.KeyCode[v].Name
				if not Gui.PressedKeys[Key] then return false end
			end
			return true
        end

		function Keybind:Check(Input)
			if SecondaryKeybind and SecondaryKeybind:Check(Input) then return true end
			if self.Keybind == 'None' then return false end
			if Input.KeyCode == Enum.KeyCode.Unknown and not UserInputTypes[Input.UserInputType.Name] then return false end
			local Split = self.Keybind:split('+')
			local Key = Input.KeyCode == Enum.KeyCode.Unknown and Input.UserInputType.Name or Input.KeyCode.Name
			if Key == Split[1] then
				Split[1] = nil
				for _, v in Split do
					if not Gui.PressedKeys[v] then return false end
				end
				return true
			end

			return false
		end

        local Name = Properties.Name:gsub(' ', '')

		function Keybind:Save(Tab)
			Tab[Name] = {
                Keybind = self.Keybind,
                Hold = self.Hold
            }
		end

		function Keybind:Load(Tab)
            if self.Keybind ~= Tab.Keybind then
                self:SetKeybind(Tab.Keybind)
            end
            if self.Hold ~= nil and Tab.Hold ~= nil and self.Hold ~= Tab.Hold then
                self:ToggleHold()
            end
		end

		Components.Delete({
			Parent = MainFrame,
			Function = function()
				Keybind:SetKeybind('None')
			end
		})

		Keybind.Object = MainFrame
		Properties.Module.Keybinds[Name] = Keybind

		if Properties.Secondary or Properties.SecondaryKeybind then
			Properties.Text = `{Properties.Name} Keybind 2`
			Properties.Name ..= '2'
			Properties.Secondary = nil
			Properties.Keybind = Properties.SecondaryKeybind
			SecondaryKeybind = Components.Keybind(Properties)
		end

		return Keybind
    end,
	Toggle = function(Properties)
		local Toggle = {
			Enabled = false,
			Visible = if Properties.Visible ~= nil then Properties.Visible else true,
            Type = "Toggle"
		}
		local Frame = Instance.new("Frame")
		Frame.Name = `{Properties.Name}Toggle`
		Frame.BackgroundTransparency = 1
		Frame.Size = UDim2.new(1, -100, 0, 40)
		Frame.LayoutOrder = Properties.LayoutOrder
		Frame.Parent = Properties.Parent
		local Button = Instance.new("TextButton")
        Button.Name = "Button"
		Button.BackgroundColor3 = GetColor("Background/Button")
		Button.TextXAlignment = Enum.TextXAlignment.Left
		Button.Size = UDim2.new(1, -45, 0, 40)
		Button.TextColor3 = GetColor("Text/Primary")
		Button.TextSize = 24
		Button.FontFace = GetFont('Regular')
		Button.Text = ` {Properties.Name}`
		Button.AutoButtonColor = false
		Button.Parent = Frame
		AddCorner(Button, UDim.new(0, 7))
		AddTooltip(Button, Properties.Info or Properties.Tooltip)
		AddHighlight(Button)
		AddMaid(Toggle)

		local EnabledBar = Instance.new("Frame")
		EnabledBar.Name = "Enabled"
		EnabledBar.BackgroundColor3 = GetColor("Main/DisabledBar")
		EnabledBar.Size = UDim2.new(0, 2, 1, -6)
		EnabledBar.Position = UDim2.new(1, -8, 0, 3)
		EnabledBar.BorderSizePixel = 0
		EnabledBar.Parent = Button

		Components.Reset({
			Parent = Frame,
			Function = function()
				if Toggle.Enabled ~= (Properties.Default or false) then
					Toggle:Toggle()
				end
			end
		})

		function Toggle:Toggle()
			self.Enabled = not self.Enabled
            TweenEnabledBar(EnabledBar, self.Enabled)
			if self.Enabled then
				if Properties.Enabled then
					task.spawn(Properties.Enabled)
				end
			else
				self:DisconnectAll()
			end
			if Properties.Function then
				task.spawn(Properties.Function, self.Enabled)
			end
		end

		function Toggle:SetVisible(Visible)
			Toggle.Visible = Visible
			Frame.Visible = Toggle.Visible
		end

		local Name = Properties.Name:gsub(' ', '')

		function Toggle:Save(Tab)
			Tab[Name] = {Enabled = Toggle.Enabled}
		end

		function Toggle:Load(Tab)
			if Toggle.Enabled ~= Tab.Enabled then
				Toggle:Toggle()
			end
		end

		if Properties.Default then
			Toggle:Toggle()
		end

		Button.MouseButton1Click:Connect(function()
			Toggle:Toggle()
		end)

		Toggle.Object = Frame

		Properties.Module.Options[Name] = Toggle

		return Toggle
	end,
	TextBox = function(Properties)
		local TextBox = {
			Visible = if Properties.Visible ~= nil then Properties.Visible else true,
			Text = Properties.Text or '',
            Type = "TextBox"
		}
		local Name = Properties.Name:gsub(' ', '')

		local Background = Instance.new("Frame")
		Background.Name = "Background"
		Background.BackgroundColor3 = GetColor("Background/Button")
		Background.BorderSizePixel = 0
		Background.Size = UDim2.new(1, -100, 0, 40)
		Background.LayoutOrder = Properties.LayoutOrder
		Background.Parent = Properties.Parent
		AddCorner(Background, UDim.new(0, 7))

		local TextLabel = Instance.new("TextLabel")
		TextLabel.BackgroundTransparency = 1
		TextLabel.Size = UDim2.fromOffset(200, 40)
		TextLabel.TextSize = 24
		TextLabel.FontFace = GetFont('Regular')
		TextLabel.TextColor3 = GetColor("Text/Primary")
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.Text = ` {Properties.Name}`
		TextLabel.Parent = Background

		local TextBoxObject = Instance.new("TextBox")
		TextBoxObject.BackgroundColor3 = GetColor("Background/Secondary")
		TextBoxObject.BorderSizePixel = 0
		TextBoxObject.Size = UDim2.fromOffset(380, 30)
		TextBoxObject.Position = UDim2.fromOffset(215, 5)
		TextBoxObject.ClearTextOnFocus = false
		TextBoxObject.PlaceholderText = Properties.PlaceholderText or Properties.Placeholder or ''
		TextBoxObject.TextColor3 = GetColor("Text/Primary")
        TextBoxObject.PlaceholderColor3 = GetColor("Text/Placeholder")
		TextBoxObject.FontFace = GetFont('Regular')
		TextBoxObject.TextSize = 24
		TextBoxObject.Text = Properties.Text or ""
		TextBoxObject.ClipsDescendants = true
		TextBoxObject.Parent = Background
		AddCorner(TextBoxObject, UDim.new(0, 7))

		TextBoxObject.FocusLost:Connect(function()
			TextBox.Text = TextBoxObject.Text
			if Properties.Function then
				Properties.Function(TextBox.Text, false)
			end
		end)

		function TextBox:SetVisible(Visible)
			TextBox.Visible = Visible
			Background.Visible = Visible
		end

        function TextBox:Save(Tab)
            Tab[Name] = {
				Text = self.Text
			}
        end

        function TextBox:Load(Tab)
			if self.Text ~= Tab.Text then
				self.Text = Tab.Text
				TextBoxObject.Text = self.Text
				if Properties.Function then
					Properties.Function(self.Text, true)
				end
			end
        end

		TextBox.Object = Background
		Properties.Module.Options[Name] = TextBox

		return TextBox
	end,
	Slider = function(Properties)
		local Slider = {
			Value = Properties.Default or 0,
			Visible = if Properties.Visible ~= nil then Properties.Visible else true,
            Type = "Slider"
		}

		local Frame = Instance.new("Frame")
		Frame.Name = `{Properties.Name}Slider`
		Frame.BackgroundTransparency = 1
		Frame.Size = UDim2.new(1, -100, 0, 40)
		Frame.LayoutOrder = Properties.LayoutOrder
		Frame.Parent = Properties.Parent

		local Background = Instance.new("Frame")
		Background.Name = "Background"
		Background.BackgroundColor3 = GetColor("Background/Button")
		Background.BorderSizePixel = 0
		Background.Size = UDim2.new(1, -45, 1, 0)
		Background.Parent = Frame
		AddCorner(Background, UDim.new(0, 7))

		local Input = Instance.new("TextBox")

		local function SetInputText(Text)
			Input.Text = `{Text}{typeof(Properties.Suffix) == "function" and Properties.Suffix(Properties.Default) or Properties.Suffix or ""}`
		end

		Input.Name = "Input"
		Input.BackgroundColor3 = GetColor("Background/Secondary")
		Input.TextColor3 = GetColor("Text/Primary")
		Input.Size = UDim2.fromOffset(80, 30)
		Input.Position = UDim2.fromOffset(200, 5)
		SetInputText(Properties.Default)
		Input.ClearTextOnFocus = false
		Input.FontFace = GetFont('Regular')
		Input.TextSize = 24
		Input.ClipsDescendants = true
		Input.Parent = Background
		AddCorner(Input, UDim.new(0, 7))

		local TextLabel = Instance.new("TextLabel")
		TextLabel.BackgroundTransparency = 1
		TextLabel.TextColor3 = GetColor("Text/Primary")
		TextLabel.Size = UDim2.fromOffset(200, 40)
		TextLabel.FontFace = GetFont('Regular')
		TextLabel.TextSize = 24
		TextLabel.Text = ` {Properties.Name}`
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.Parent = Background

		local SliderFrame = Instance.new("TextButton")
		SliderFrame.Name = "SliderFrame"
		SliderFrame.BackgroundTransparency = 1
		SliderFrame.Text = ""
		SliderFrame.Size = UDim2.fromOffset(230, 20)
		SliderFrame.Position = UDim2.fromOffset(300, 10)
		SliderFrame.Parent = Background

		local FrameDragDetector = Instance.new("UIDragDetector")
		FrameDragDetector.CursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
		FrameDragDetector.ActivatedCursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
		FrameDragDetector.DragStyle = Enum.UIDragDetectorDragStyle.Scriptable
		FrameDragDetector.DragAxis = Vector2.new(1, 0)
		FrameDragDetector.ResponseStyle = Enum.UIDragDetectorResponseStyle.Offset
		FrameDragDetector.Parent = SliderFrame

        local RightBar = Instance.new("Frame")
        RightBar.Name = "RightBar"
        RightBar.BackgroundColor3 = GetColor("Slider/RightBar")
        RightBar.BorderSizePixel = 0
        RightBar.Parent = SliderFrame

		local LeftBar = Instance.new("Frame")
		LeftBar.Name = "LeftBar"
		LeftBar.BackgroundColor3 = GetColor("Slider/LeftBar")
		LeftBar.BorderSizePixel = 0
		LeftBar.Position = UDim2.fromOffset(0, 9)
		LeftBar.Parent = SliderFrame

		local Handle = Instance.new("TextButton")

		local Decimals = typeof(Properties.Decimal) == "number" and Properties.Decimal or 1

		local function CalculatePosition(Type, CustomPosition)
			local X = Type == "Mouse" and (UIS:GetMouseLocation().X - SliderFrame.AbsolutePosition.X) / UIScale.Scale or Type == "Slider" and Handle.Position.X.Offset or Type == "Custom" and CustomPosition
            
			local MaxSize = math.floor(SliderFrame.AbsoluteSize.X / UIScale.Scale)
			local Pos = math.clamp(X, 0, MaxSize)
			local Scale = math.clamp(Pos / MaxSize, 0, 1)

			local Value = Properties.Min + (Scale * (Properties.Max - Properties.Min))

			if Type ~= "Custom" or Properties.Clamp then
				Value = math.clamp(Value, Properties.Min, Properties.Max)
			end

			Value = math.round(Value * Decimals) / Decimals

			return Pos, Value
		end

		local function CalculatePositionFromValue(Value)
			local Scale = (Value - Properties.Min) / (Properties.Max - Properties.Min)

			local MaxSize = math.floor(SliderFrame.AbsoluteSize.X / UIScale.Scale)
			local Position = Scale * MaxSize

			return CalculatePosition("Custom", Position)
		end

        local StartPos = CalculatePositionFromValue(Properties.Default)

        LeftBar.Size = UDim2.fromOffset(StartPos, 3)
        RightBar.Size = UDim2.fromOffset(SliderFrame.Size.X.Offset - StartPos, 3)
        RightBar.Position = UDim2.fromOffset(StartPos, 9)
		Handle.Name = "Handle"
		Handle.BackgroundColor3 = GetColor("Slider/Handle")
		Handle.BorderSizePixel = 0
		Handle.Size = UDim2.fromOffset(15, 15)
		Handle.Position = UDim2.new(0, StartPos, 0, -7)
		Handle.AnchorPoint = Vector2.new(0.5, 0)
        Handle.AutoButtonColor = false
        Handle.Text = ""
		Handle.Parent = LeftBar
		AddCorner(Handle, UDim.new(1, 0))

        local Info = TweenInfo.new(0.25)
        local Info2 = TweenInfo.new(0.1)

        Handle.MouseEnter:Connect(function()
            TweenService:Create(Handle, Info, {BackgroundColor3 = GetColor("Slider/HandleHover")}):Play()
        end)
        Handle.MouseLeave:Connect(function()
            TweenService:Create(Handle, Info, {BackgroundColor3 = GetColor('Slider/Handle')}):Play()
        end)
        Handle.MouseButton1Down:Connect(function()
            TweenService:Create(Handle, Info2, {BackgroundColor3 = GetColor('Slider/HandlePress')}):Play()
        end)
        Handle.MouseButton1Up:Connect(function()
            TweenService:Create(Handle, Info2, {BackgroundColor3 = GetColor('Slider/HandleHover')}):Play()
        end)

		local DragDetector = Instance.new("UIDragDetector")
		DragDetector.CursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
		DragDetector.ActivatedCursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
		DragDetector.DragStyle = Enum.UIDragDetectorDragStyle.TranslateLine
		DragDetector.DragAxis = Vector2.new(1, 0)
		DragDetector.ResponseStyle = Enum.UIDragDetectorResponseStyle.Offset
		DragDetector.Parent = Handle

		local function OnFrameDragged(Type)
			local Pos, Value = CalculatePosition(typeof(Type) == "string" and Type or "Mouse")
			Handle.Position = UDim2.new(0, Pos, 0, -7)
            LeftBar.Size = UDim2.fromOffset(Pos, 3)
            RightBar.Size = UDim2.fromOffset(SliderFrame.Size.X.Offset - Pos, 3)
            RightBar.Position = UDim2.fromOffset(Pos, 9)
			Slider.Value = Value
			SetInputText(Slider.Value)
			if Properties.Function then
				Properties.Function(Value)
			end
		end

		FrameDragDetector.DragStart:Connect(OnFrameDragged)
		FrameDragDetector.DragContinue:Connect(OnFrameDragged)

		DragDetector.DragContinue:Connect(function()
            OnFrameDragged("Slider")
		end)

		local function InputNumber(Number)
			local String = tostring(Number):gsub("%%", "")
			local Val = tonumber(String)
			if Val then
                if Properties.Clamp then
                    Val = math.clamp(Val, Properties.Min, Properties.Max)
                end
                local Pos = CalculatePositionFromValue(Val)
				Handle.Position = UDim2.new(0, Pos, 0, -7)
                LeftBar.Size = UDim2.fromOffset(Pos, 3)
                RightBar.Size = UDim2.fromOffset(SliderFrame.Size.X.Offset - Pos, 3)
                RightBar.Position = UDim2.fromOffset(Pos, 9)
				Slider.Value = Val
				if Properties.Function then
					Properties.Function(Val)
				end
			end
			SetInputText(Slider.Value)
		end

		Input.FocusLost:Connect(function()
			InputNumber(Input.Text)
		end)

		Components.Reset({
			Parent = Frame,
			Function = function()
				InputNumber(Properties.Default)
			end
		})

		local Name = Properties.Name:gsub(' ', '')

		function Slider:Save(Tab)
			Tab[Name] = {
				Value = self.Value
			}
		end

		function Slider:Load(Tab)
			if Slider.Value ~= Tab.Value then
				InputNumber(Tab.Value)
			end
		end

		function Slider:SetVisible(Visible)
			Slider.Visible = Visible
			Frame.Visible = Slider.Visible
		end

		Slider.Object = Frame

		Properties.Module.Options[Name] = Slider

		return Slider
	end,
	Dropdown = function(Properties)
		local Dropdown = {
			Value = Properties.List[1] or "None",
			Visible = if Properties.Visible ~= nil then Properties.Visible else true,
            Type = "Dropdown"
		}

		local Frame = Instance.new("Frame")
		Frame.Name = `{Properties.Name}Dropdown`
		Frame.BackgroundTransparency = 1
		Frame.Size = UDim2.new(1, -100, 0, 40)
		Frame.LayoutOrder = Properties.LayoutOrder
		Frame.Parent = Properties.Parent

		local Background = Instance.new("Frame")
		Background.Name = "Background"
		Background.BackgroundColor3 = GetColor('Background/Button')
		Background.BorderSizePixel = 0
		Background.Size = UDim2.new(1, -45, 1, 0)
		Background.Parent = Frame
		AddCorner(Background, UDim.new(0, 7))

		local TextLabel = Instance.new("TextLabel")
		TextLabel.TextColor3 = GetColor('Text/Primary')
		TextLabel.BackgroundTransparency = 1
		TextLabel.Size = UDim2.new(0, 200, 1, 0)
		TextLabel.FontFace = GetFont('Regular')
		TextLabel.TextSize = 24
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.Text = ` {Properties.Name}`
		TextLabel.Parent = Background

		local TopBar = Instance.new("TextButton")
		TopBar.Name = "TopBar"
		TopBar.Size = UDim2.fromOffset(240, 40)
		TopBar.Position = UDim2.fromOffset(310, 0)
		TopBar.BackgroundTransparency = 1
		TopBar.Text = ""
		TopBar.AutoButtonColor = false
		TopBar.Parent = Background

		local TopBarLabel = Instance.new("TextLabel")
		TopBarLabel.Size = UDim2.new(1, 0, 0, 30)
		TopBarLabel.Position = UDim2.fromOffset(0, 5)
		TopBarLabel.BackgroundColor3 = GetColor('Background/Secondary')
		TopBarLabel.BorderSizePixel = 0
		TopBarLabel.Text = `   {Properties.List[1] or "None"}`
		TopBarLabel.TextSize = 24
		TopBarLabel.TextColor3 = GetColor('Text/Primary')
		TopBarLabel.FontFace = GetFont('Regular')
		TopBarLabel.TextXAlignment = Enum.TextXAlignment.Left
		TopBarLabel.Parent = TopBar
        AddTooltip(TopBarLabel, Properties.Info or Properties.Tooltip)

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 7)
        UICorner.Parent = TopBarLabel

		local Arrow = Instance.new("TextButton")
		Arrow.Name = "Arrow"
		Arrow.Size = UDim2.fromOffset(30, 30)
		Arrow.Position = UDim2.new(1, -30, 0, 0)
		Arrow.BackgroundTransparency = 1
		Arrow.Text = ""
		Arrow.Rotation = -90
		Arrow.Parent = TopBarLabel
		AddCorner(Arrow, UDim.new(0, 7))

		local ArrowImage = Instance.new("ImageLabel")
		ArrowImage.Name = "Image"
		ArrowImage.Size = UDim2.fromOffset(30, 30)
		ArrowImage.Position = UDim2.fromOffset(0, 0)
		ArrowImage.BackgroundTransparency = 1
		SetIcon(ArrowImage, "chevron-down")
		ArrowImage.Parent = Arrow

		local ScrollingFrame = Instance.new("ScrollingFrame")
		ScrollingFrame.Size = UDim2.fromScale(1, 0)
		ScrollingFrame.Position = UDim2.fromScale(0, 1)
		ScrollingFrame.BackgroundColor3 = GetColor('Background/Secondary')
		ScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
		ScrollingFrame.ScrollBarThickness = 0
		ScrollingFrame.ScrollBarImageTransparency = 1
		ScrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		ScrollingFrame.Visible = false
		ScrollingFrame.ZIndex = 2
		ScrollingFrame.Parent = TopBarLabel

        local ScrollingFrameUICorner = Instance.new("UICorner")
        ScrollingFrameUICorner.CornerRadius = UDim.new(0, 0)
        ScrollingFrameUICorner.BottomLeftRadius = UDim.new(0, 7)
        ScrollingFrameUICorner.BottomRightRadius = UDim.new(0, 7)
        ScrollingFrameUICorner.Parent = ScrollingFrame

		local Padding = Instance.new("UIPadding")
		Padding.PaddingTop = UDim.new(0, 10)
		Padding.PaddingBottom = UDim.new(0, 10)
		Padding.Parent = ScrollingFrame

		local Layout = Instance.new("UIListLayout")
		Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		Layout.Padding = UDim.new(0, 5)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Parent = ScrollingFrame

		local function GetHeight()
			return (Layout.AbsoluteContentSize.Y + 12) / UIScale.Scale
		end

		Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetHeight())
		end)
		ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetHeight())

		local Expanded = false
		local Info = TweenInfo.new(0.2)
		local Tween, ArrowTween
		local CreatedButtons = {}

		function Dropdown:SetValue(Val)
			Dropdown.Value = Val
			TopBarLabel.Text = `   {Val}`
			if Properties.Function then
				Properties.Function(Val)
			end
		end

		function Dropdown:Expand()
			Expanded = not Expanded
			if Tween then
				Tween:Cancel()
			end
			if ArrowTween then
				ArrowTween:Cancel()
			end
			Tween = TweenService:Create(ScrollingFrame, Info, {Size = UDim2.new(1, 0, 0, Expanded and 240 or 0)})
			ArrowTween = TweenService:Create(Arrow, Info, {Rotation = Expanded and 0 or -90})
			if Expanded then
				if #CreatedButtons == 0 then
					for i, v in Properties.List do
						local Button = Instance.new("TextButton")
						Button.Size = UDim2.fromOffset(220, 30)
						Button.BackgroundColor3 = GetColor('Background/Button')
						Button.TextColor3 = GetColor('Text/Primary')
						Button.FontFace = GetFont('Regular')
						Button.TextSize = 20
						Button.Text = `  {v}`
						Button.LayoutOrder = i
						Button.ZIndex = 2
						Button.BorderSizePixel = 0
						Button.AutoButtonColor = false
						Button.TextXAlignment = Enum.TextXAlignment.Left
						Button.Parent = ScrollingFrame
						AddCorner(Button, UDim.new(0, 7))
						AddHighlight(Button)

						Button.MouseButton1Click:Connect(function()
							Dropdown:SetValue(v)
						end)

						table.insert(CreatedButtons, Button)
					end
				end
				ScrollingFrame.Visible = true
				UICorner.CornerRadius = UDim.new(0, 0)
                UICorner.TopLeftRadius = UDim.new(0, 7)
                UICorner.TopRightRadius = UDim.new(0, 7)
			else
				Tween.Completed:Once(function(State)
					if State == Enum.PlaybackState.Completed then
						ScrollingFrame.Visible = false
                        UICorner.CornerRadius = UDim.new(0, 7)
						for i, v in CreatedButtons do
							v:Destroy()
						end
						table.clear(CreatedButtons)
					end
				end)
			end
			Tween:Play()
			ArrowTween:Play()
		end

		local Name = Properties.Name:gsub(' ', '')

		function Dropdown:Save(Tab)
			Tab[Name] = {
				Value = self.Value
			}
		end

		function Dropdown:Load(Tab)
			if Dropdown.Value ~= Tab.Value then
				Dropdown:SetValue(Tab.Value)
			end
		end

		function Dropdown:SetVisible(Visible)
			Dropdown.Visible = Visible
			Frame.Visible = Dropdown.Visible
		end

		Arrow.MouseButton1Click:Connect(Dropdown.Expand)
		Arrow.MouseButton2Click:Connect(Dropdown.Expand)
		TopBar.MouseButton1Click:Connect(Dropdown.Expand)
		TopBar.MouseButton2Click:Connect(Dropdown.Expand)

		Components.Reset({
			Parent = Frame,
			Function = function()
				local Val = Properties.List[1] or "None"
				if Dropdown.Value ~= Val then
					Dropdown:SetValue(Val)
				end
			end
		})

		Dropdown.Object = Frame
		Properties.Module.Options[Name] = Dropdown

		return Dropdown
	end,
	TextList = function(Properties)
		local TextList = {
			List = Properties.List or Properties.Default or {},
            Enabled = Properties.Enabled or Properties.List or Properties.Default or {},
			Visible = if Properties.Visible ~= nil then Properties.Visible else true,
            Type = "TextList"
		}

		local Frame = Instance.new("Frame")
		Frame.Name = `{Properties.Name}TextList`
		Frame.BackgroundTransparency = 1
		Frame.Size = UDim2.new(1, -100, 0, 40)
		Frame.LayoutOrder = Properties.LayoutOrder
		Frame.Parent = Properties.Parent

		local Background = Instance.new("Frame")
		Background.Name = "Background"
		Background.BackgroundColor3 = GetColor('Background/Button')
		Background.BorderSizePixel = 0
		Background.Size = UDim2.new(1, -45, 1, 0)
		Background.Parent = Frame
		AddCorner(Background, UDim.new(0, 7))

		local TextLabel = Instance.new("TextLabel")
		TextLabel.TextColor3 = GetColor('Text/Primary')
		TextLabel.BackgroundTransparency = 1
		TextLabel.Size = UDim2.new(0, 200, 1, 0)
		TextLabel.FontFace = GetFont('Regular')
		TextLabel.TextSize = 24
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.Text = ` {Properties.Name}`
		TextLabel.Parent = Background

		local TopBar = Instance.new("TextButton")
		TopBar.Name = "TopBar"
		TopBar.Size = UDim2.fromOffset(240, 40)
		TopBar.Position = UDim2.fromOffset(310, 0)
		TopBar.BackgroundColor3 = GetColor('Background/Button')
		TopBar.BorderSizePixel = 0
		TopBar.Text = ""
		TopBar.AutoButtonColor = false
		TopBar.Parent = Background

		local Selected = Instance.new("TextLabel")
		Selected.Size = UDim2.new(1, 0, 0, 30)
		Selected.Position = UDim2.fromOffset(0, 5)
		Selected.BackgroundColor3 = GetColor('Background/Secondary')
		Selected.BorderSizePixel = 0
		Selected.Text = "   Open to add entry"
		Selected.TextSize = 24
		Selected.TextColor3 = GetColor('Text/Primary')
		Selected.FontFace = GetFont('Regular')
		Selected.TextXAlignment = Enum.TextXAlignment.Left
		Selected.Parent = TopBar

		local UICorner = Instance.new('UICorner')
		UICorner.CornerRadius = UDim.new(0, 7)
		UICorner.Parent = Selected

		local Arrow = Instance.new("TextButton")
		Arrow.Name = "Arrow"
		Arrow.Size = UDim2.fromOffset(30, 30)
		Arrow.Position = UDim2.new(1, -30, 0, 0)
		Arrow.BackgroundTransparency = 1
		Arrow.Text = ""
		Arrow.Rotation = -90
		Arrow.Parent = Selected
		AddCorner(Arrow, UDim.new(0, 7))

		local ArrowImage = Instance.new("ImageLabel")
		ArrowImage.Name = "ArrowImage"
		ArrowImage.Size = UDim2.fromOffset(30, 30)
		ArrowImage.Position = UDim2.fromOffset(0, 0)
		ArrowImage.BackgroundTransparency = 1
		SetIcon(ArrowImage, "chevron-down")
		ArrowImage.Parent = Arrow

		local ScrollingFrame = Instance.new("ScrollingFrame")
		ScrollingFrame.Size = UDim2.fromScale(1, 0)
		ScrollingFrame.Position = UDim2.fromScale(0, 1)
		ScrollingFrame.BackgroundColor3 = GetColor('Background/Secondary')
		ScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
		ScrollingFrame.ScrollBarThickness = 0
		ScrollingFrame.ScrollBarImageTransparency = 1
		ScrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		ScrollingFrame.Visible = false
		ScrollingFrame.ZIndex = 2
		ScrollingFrame.Parent = Selected
		
		local ScrollingFrameUICorner = Instance.new('UICorner')
		ScrollingFrameUICorner.CornerRadius = UDim.new(0, 0)
        ScrollingFrameUICorner.BottomLeftRadius = UDim.new(0, 7)
        ScrollingFrameUICorner.BottomRightRadius = UDim.new(0, 7)
		ScrollingFrameUICorner.Parent = ScrollingFrame

		local Padding = Instance.new("UIPadding")
		Padding.PaddingTop = UDim.new(0, 10)
		Padding.PaddingBottom = UDim.new(0, 10)
		Padding.Parent = ScrollingFrame

		local Layout = Instance.new("UIListLayout")
		Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		Layout.Padding = UDim.new(0, 5)
		Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Parent = ScrollingFrame

		local PlusButton = Instance.new("TextButton")
		PlusButton.Name = "Plus"
		PlusButton.BackgroundColor3 = GetColor('Background/Button')
		PlusButton.Text = ""
		PlusButton.BorderSizePixel = 0
		PlusButton.Size = UDim2.fromOffset(32, 32)
		PlusButton.AutoButtonColor = false
		PlusButton.LayoutOrder = 69420
		PlusButton.ZIndex = 2
		PlusButton.Parent = ScrollingFrame
		AddCorner(PlusButton, UDim.new(0, 7))
		AddHighlight(PlusButton)

		local PlusImage = Instance.new("ImageLabel")
		PlusImage.Name = "Image"
		PlusImage.BackgroundTransparency = 1
		PlusImage.Size = UDim2.fromOffset(24, 24)
		PlusImage.Position = UDim2.fromOffset(4, 4)
		PlusImage.ZIndex = 2
		SetIcon(PlusImage, "plus")
		PlusImage.Parent = PlusButton

		local function GetHeight()
			return (Layout.AbsoluteContentSize.Y + 12) / UIScale.Scale
		end

		Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetHeight())
		end)
		ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetHeight())

		local Expanded = false
		local Info = TweenInfo.new(0.2)
		local Tween, ArrowTween, Con
		local CreatedButtons = {}

        local function Add(Val, Callback)
            if not table.find(TextList.Enabled, Val) then
                table.insert(TextList.Enabled, Val)
                if Callback then
                    Callback(TextList.Enabled)
                end
            end
        end

        local function Remove(Val, Callback)
            local Index = table.find(TextList.Enabled, Val)
            if Index then
                table.remove(TextList.Enabled, Index)
                if Callback then
                    Callback(TextList.Enabled)
                end
            end
        end

        local function Create(Val)
            if not table.find(TextList.List, Val) then
                table.insert(TextList.List, Val)
            end
        end

        local function Delete(Val)
            Remove(Val)
            local Index = table.find(TextList.List, Val)
            if Index then
                table.remove(TextList.List, Index)
            end
        end

		local function CreateButton(Properties)
            local Enabled = Properties.Enabled == true
			local Button = Instance.new("TextButton")
			Button.Size = UDim2.fromOffset(220, 30)
			Button.BackgroundColor3 = GetColor('Background/Button')
			Button.TextColor3 = GetColor('Text/Primary')
			Button.FontFace = GetFont('Regular')
			Button.TextSize = 20
			Button.Text = `  {Properties.Name}`
			Button.LayoutOrder = Properties.LayoutOrder or 0
			Button.ZIndex = 2
			Button.BorderSizePixel = 0
			Button.AutoButtonColor = false
			Button.TextXAlignment = Enum.TextXAlignment.Left
			Button.Parent = ScrollingFrame
			AddCorner(Button, UDim.new(0, 7))
            AddHighlight(Button)

            local EnabledBar = Instance.new("Frame")
            EnabledBar.Name = "Enabled"
            EnabledBar.BackgroundColor3 = Enabled and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
            EnabledBar.Size = UDim2.new(0, 2, 1, -6)
            EnabledBar.Position = UDim2.new(1, -8, 0, 3)
            EnabledBar.BorderSizePixel = 0
            EnabledBar.ZIndex = 2
            EnabledBar.Parent = Button

			local DeleteButton = Instance.new("TextButton")
			DeleteButton.Name = "Delete"
			DeleteButton.BackgroundTransparency = 1
			DeleteButton.BackgroundColor3 = GetColor('Background/Button')
			DeleteButton.Text = ""
			DeleteButton.BorderSizePixel = 0
			DeleteButton.Size = UDim2.fromOffset(30, 30)
			DeleteButton.Position = UDim2.new(1, -40, 0, 0)
			DeleteButton.AutoButtonColor = false
			DeleteButton.ZIndex = 2
			DeleteButton.Parent = Button
			AddCorner(DeleteButton, UDim.new(0, 7))
			AddHighlight(DeleteButton)
			AddTooltip(DeleteButton, "Click to remove from list")

			local DeleteButtonImage = Instance.new("ImageLabel")
			DeleteButtonImage.Name = "Image"
			DeleteButtonImage.BackgroundTransparency = 1
			DeleteButtonImage.Size = UDim2.fromOffset(24, 24)
			DeleteButtonImage.Position = UDim2.fromOffset(3, 3)
			DeleteButtonImage.ZIndex = 2
			SetIcon(DeleteButtonImage, "x")
			DeleteButtonImage.Parent = DeleteButton

			local RenameTextBox = Instance.new("TextBox")
			RenameTextBox.Name = "Rename"
			RenameTextBox.BackgroundTransparency = 1
			RenameTextBox.Size = UDim2.fromOffset(220, 30)
			RenameTextBox.Position = UDim2.fromOffset(10, 0)
			RenameTextBox.TextSize = 20
			RenameTextBox.TextColor3 = GetColor('Text/Primary')
			RenameTextBox.FontFace = GetFont('Regular')
			RenameTextBox.ClearTextOnFocus = false
			RenameTextBox.TextXAlignment = Enum.TextXAlignment.Left
			RenameTextBox.Visible = false
			RenameTextBox.ZIndex = 2
			RenameTextBox.Parent = Button

			local function Select()
				Button.TextTransparency = 1
				RenameTextBox.Text = Properties.Name
				RenameTextBox.Visible = true
				RenameTextBox:CaptureFocus()
				RenameTextBox.SelectionStart = 0
				RenameTextBox.CursorPosition = #RenameTextBox.Text + 1
				RenameTextBox.FocusLost:Once(function()
					local OldName, NewName = Properties.Name, RenameTextBox.Text
                    Delete(OldName)
                    Create(NewName)
                    if Enabled then
                        Add(NewName)
                    end
					RenameTextBox.Visible = false
					Button.Text = `  {NewName}`
					Button.TextTransparency = 0
					Properties.Name = NewName
				end)
			end

			if Properties.New then
				Select()
			end

			DeleteButton.MouseButton1Click:Connect(function()
				Tooltip.Visible = false
				TextList:Delete(Properties.Name)
				local Index = table.find(CreatedButtons, Frame)
				if Index then
					table.remove(CreatedButtons, Index)
				end
				Button:Destroy()
			end)

			Button.MouseButton1Click:Connect(function()
				Enabled = not Enabled
				TweenEnabledBar(EnabledBar, Enabled)
				if Enabled then
					TextList:Add(Properties.Name)
				else
					TextList:Remove(Properties.Name)
				end
			end)

			Button.MouseButton2Click:Connect(Select)

			table.insert(CreatedButtons, Button)
		end

		PlusButton.MouseButton1Click:Connect(function()
			CreateButton({
				Name = "new",
				LayoutOrder = #TextList.List + 1,
				New = true,
                Enabled = true
			})
		end)

        function TextList:Find(Val)
            local Index = table.find(TextList.Enabled, Val)
            if Index and TextList.Enabled[Index] then
                return TextList.Enabled[Index]
            end
            return nil
        end

		function TextList:Add(Val)
            Add(Val, Properties.Function)
		end

		function TextList:Remove(Val)
            Remove(Val, Properties.Function)
		end

        function TextList:Delete(Val)
            Delete(Val)
        end

		function TextList:Expand()
			Expanded = not Expanded
			if Tween then
				Tween:Cancel()
			end
			if ArrowTween then
				ArrowTween:Cancel()
			end
			if Con then
				Con:Disconnect()
			end
			Tween = TweenService:Create(ScrollingFrame, Info, {Size = UDim2.new(1, 0, 0, Expanded and 240 or 0)})
			ArrowTween = TweenService:Create(Arrow, Info, {Rotation = Expanded and 0 or -90})
			if Expanded then
				if #CreatedButtons == 0 then
					for i, v in TextList.List do
						CreateButton({
							Name = v,
							LayoutOrder = i,
                            Enabled = TextList:Find(v) ~= nil
						})
					end
				end
				ScrollingFrame.Visible = true
				UICorner.CornerRadius = UDim.new(0, 0)
				UICorner.TopLeftRadius = UDim.new(0, 7)
				UICorner.TopRightRadius = UDim.new(0, 7)
			else
				Tween.Completed:Once(function(State)
					if State == Enum.PlaybackState.Completed then
						UICorner.CornerRadius = UDim.new(0, 7)
						ScrollingFrame.Visible = false
						for _, v in CreatedButtons do
							v:Destroy()
						end
						table.clear(CreatedButtons)
					end
				end)
			end
			Tween:Play()
			ArrowTween:Play()
		end

		local Name = Properties.Name:gsub(' ', '')

		function TextList:Save(Tab)
			Tab[Name] = {
				Enabled = TextList.Enabled,
				List = TextList.List
			}
		end

		function TextList:Load(Tab)
            for _, v in TextList.Enabled do
                Remove(v)
            end
            TextList.List = Tab.List
            TextList.Enabled = Tab.Enabled
			for _, v in TextList.Enabled do
                Add(v)
			end
            if Properties.Function then
                Properties.Function(TextList.Enabled)
            end
		end

		function TextList:SetVisible(Visible)
			TextList.Visible = Visible
			Frame.Visible = TextList.Visible
		end

		Arrow.MouseButton1Click:Connect(TextList.Expand)
		Arrow.MouseButton2Click:Connect(TextList.Expand)
		TopBar.MouseButton1Click:Connect(TextList.Expand)
		TopBar.MouseButton2Click:Connect(TextList.Expand)

		Components.Delete({
			Parent = Frame,
			Function = function()
				for _, v in CreatedButtons do
					v:Destroy()
				end
				table.clear(CreatedButtons)
				table.clear(TextList.List)
				table.clear(TextList.Enabled)
				if Properties.Function then
					Properties.Function(TextList.Enabled)
				end
			end
		})

		TextList.Object = Frame

		Properties.Module.Options[Name] = TextList

		return TextList
	end,
    ColorPicker = function(Properties)
        local DefaultColor = Properties.Color or Properties.DefaultColor or Properties.Default or Color3.White
        local DefaultTransparency = Properties.Transparency or Properties.DefaultTransparency or 0
        local DefaultHue, DefaultSaturation, DefaultValue = DefaultColor:ToHSV()
        local ColorPicker = {
            Color = DefaultColor,
            R = math.floor(DefaultColor.R * 255),
            G = math.floor(DefaultColor.G * 255),
            B = math.floor(DefaultColor.B * 255),
            T = DefaultTransparency,
            H = DefaultHue,
            S = DefaultSaturation,
            V = DefaultValue,
            Transparency = DefaultTransparency,
            Visible = if Properties.Visible ~= nil then Properties.Visible else true,
            Type = 'ColorPicker'
        }

        local Frame = Instance.new("Frame")
		Frame.Name = `{Properties.Name}ColorPicker`
		Frame.BackgroundTransparency = 1
		Frame.Size = UDim2.new(1, -100, 0, 40)
		Frame.LayoutOrder = Properties.LayoutOrder
		Frame.Parent = Properties.Parent

		local Background = Instance.new("Frame")
		Background.Name = "Background"
		Background.BackgroundColor3 = GetColor('Background/Button')
		Background.BorderSizePixel = 0
		Background.Size = UDim2.new(1, -45, 1, 0)
		Background.Parent = Frame
		AddCorner(Background, UDim.new(0, 7))

        local TextSize = GetTextSize(Properties.Name, 24, GetFont('Regular'), 1000)
        
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Position = UDim2.fromOffset(5, 0)
        NameLabel.Size = UDim2.fromOffset(TextSize.X + 5, 40)
        NameLabel.BackgroundTransparency = 1
        NameLabel.FontFace = GetFont('Regular')
        NameLabel.TextSize = 24
        NameLabel.TextColor3 = GetColor("Text/Primary")
        NameLabel.Text = Properties.Name
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = Background

        local RGBFrame = Instance.new("Frame")
        RGBFrame.Name = "RGBFrame"
        RGBFrame.BackgroundColor3 = GetColor("Background/Secondary")
        RGBFrame.BorderSizePixel = 0
        RGBFrame.Position = UDim2.fromOffset(TextSize.X + 10, 4)
        RGBFrame.Size = UDim2.fromOffset(168, 32)
        RGBFrame.Parent = Background
        AddCorner(RGBFrame, UDim.new(0, 7))

        local RGBInput = Instance.new("TextBox")
        RGBInput.Name = "RGBInput"
        RGBInput.BackgroundTransparency = 1
        RGBInput.Position = UDim2.fromOffset(4, 0)
        RGBInput.Size = UDim2.fromOffset(130, 32)
        RGBInput.FontFace = GetFont('Regular')
        RGBInput.TextColor3 = GetColor("Text/Primary")
        RGBInput.TextSize = 24
        RGBInput.PlaceholderColor3 = GetColor("Text/Placeholder")
        RGBInput.PlaceholderText = "[R, G, B]"
        RGBInput.Text = `{math.floor(DefaultColor.R * 255)}, {math.floor(DefaultColor.G * 255)}, {math.floor(DefaultColor.B * 255)}`
        RGBInput.ClearTextOnFocus = false
        RGBInput.ClipsDescendants = true
        RGBInput.Parent = RGBFrame
        
        local ColorDisplay = Instance.new("ImageButton")
        ColorDisplay.Name = "ColorDisplay"
        ColorDisplay.BackgroundColor3 = DefaultColor
        ColorDisplay.BorderSizePixel = 0
        ColorDisplay.Position = UDim2.fromOffset(136, 4)
        ColorDisplay.Size = UDim2.fromOffset(24, 24)
        ColorDisplay.ImageTransparency = 1
        ColorDisplay.AutoButtonColor = false
        ColorDisplay.Parent = RGBFrame
        AddCorner(ColorDisplay, UDim.new(0, 7))

        local ColorPickerDropdown = Instance.new("Frame")
        ColorPickerDropdown.Name = "ColorPickerDropdown"
        ColorPickerDropdown.BackgroundColor3 = GetColor("Background/Secondary")
        ColorPickerDropdown.BorderSizePixel = 0
        ColorPickerDropdown.Position = UDim2.fromOffset(TextSize.X + 10, 36)
        ColorPickerDropdown.Size = UDim2.fromOffset(360, 360)
        ColorPickerDropdown.ZIndex = 2
        ColorPickerDropdown.Visible = false
        ColorPickerDropdown.Parent = Background
        AddCorner(ColorPickerDropdown, UDim.new(0, 7))

        local ColorBackground = Instance.new("ImageButton")
        ColorBackground.Name = "ColorBackground"
        ColorBackground.BackgroundTransparency = 1
        ColorBackground.Position = UDim2.fromOffset(10, 10)
        ColorBackground.Size = UDim2.fromOffset(300, 180)
        ColorBackground.ZIndex = 2
        ColorBackground.Image = "rbxassetid://1072518406"
        ColorBackground.ClipsDescendants = true
        ColorBackground.Parent = ColorPickerDropdown

        local ColorBackgroundDragDetector = Instance.new("UIDragDetector")
		ColorBackgroundDragDetector.CursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
		ColorBackgroundDragDetector.ActivatedCursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
		ColorBackgroundDragDetector.DragStyle = Enum.UIDragDetectorDragStyle.Scriptable
		ColorBackgroundDragDetector.ResponseStyle = Enum.UIDragDetectorResponseStyle.Offset
		ColorBackgroundDragDetector.Parent = ColorBackground

        local Plus = Instance.new("Frame")
        Plus.Name = "Plus"
        Plus.BackgroundTransparency = 1
        Plus.AnchorPoint = Vector2.new(0.5, 0.5)
        Plus.Size = UDim2.fromOffset(24, 24)
        Plus.ZIndex = 2
        Plus.Parent = ColorBackground

        local Frame1 = Instance.new("Frame")
        Frame1.Name = "Frame1"
        Frame1.BackgroundColor3 = Color3.new()
        Frame1.BorderSizePixel = 0
        Frame1.Size = UDim2.fromOffset(24, 2)
        Frame1.Position = UDim2.fromOffset(0, 11)
        Frame1.ZIndex = 2
        Frame1.Parent = Plus

        local Frame2 = Instance.fromExisting(Frame1)
        Frame2.Size = UDim2.fromOffset(2, 24)
        Frame2.Position = UDim2.fromOffset(11, 0)
        Frame2.Parent = Plus
    
        local ColorStrip = Instance.new("ImageButton")
        ColorStrip.BackgroundTransparency = 1
        ColorStrip.Position = UDim2.fromOffset(325, 10)
        ColorStrip.Size = UDim2.fromOffset(12, 180)
        ColorStrip.ZIndex = 2
        ColorStrip.Image = "rbxassetid://1072518502"
        ColorStrip.Parent = ColorPickerDropdown

        local ColorStripDragDetector = Instance.new("UIDragDetector")
		ColorStripDragDetector.CursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
		ColorStripDragDetector.ActivatedCursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
		ColorStripDragDetector.DragStyle = Enum.UIDragDetectorDragStyle.Scriptable
		ColorStripDragDetector.DragAxis = Vector2.new(0, 1)
		ColorStripDragDetector.ResponseStyle = Enum.UIDragDetectorResponseStyle.Offset
		ColorStripDragDetector.Parent = ColorStrip

        local Arrow = Instance.new("ImageLabel")
        Arrow.Name = "Arrow"
        Arrow.BackgroundTransparency = 1
        Arrow.Size = UDim2.fromOffset(24, 24)
        Arrow.Position = UDim2.fromScale(1, 0)
        Arrow.AnchorPoint = Vector2.new(0, 0.5)
        Arrow.ZIndex = 2
        SetIcon(Arrow, "chevron-left")
        Arrow.Parent = ColorStrip

        local Holder = Instance.new("Frame")
        Holder.Name = "Holder"
        Holder.BackgroundTransparency = 1
        Holder.Size = UDim2.fromOffset(328, 160)
        Holder.Position = UDim2.fromOffset(10, 200)
        Holder.ZIndex = 2
        Holder.Parent = ColorPickerDropdown

        local Layout = Instance.new("UIListLayout")
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Layout.VerticalAlignment = Enum.VerticalAlignment.Top
        Layout.Padding = UDim.new(0, 10)
        Layout.Parent = Holder

        local Function = Properties.Function

        local function FireCallback()
            if Function then
                Function(ColorPicker.Color, ColorPicker.Transparency)
            end
        end

        local function UpdateMainDisplay()
            RGBInput.Text = `{math.floor(ColorPicker.R)}, {math.floor(ColorPicker.G)}, {math.floor(ColorPicker.B)}`
            ColorStrip.ImageColor3 = Color3.fromHSV(ColorPicker.H, ColorPicker.S, 1)
            ColorDisplay.BackgroundColor3 = ColorPicker.Color
            ColorDisplay.BackgroundTransparency = ColorPicker.Transparency
        end

        local function UpdateMainPositions()
			local Scale = UIScale.Scale
			local MaxSize = ColorBackground.AbsoluteSize / Scale
			Plus.Position = UDim2.fromOffset(math.clamp((ColorBackground.AbsoluteSize.X - (ColorBackground.AbsoluteSize.X * ColorPicker.H)) / Scale, 0, MaxSize.X), math.clamp((ColorBackground.AbsoluteSize.Y - (ColorBackground.AbsoluteSize.Y * ColorPicker.S)) / Scale, 0, MaxSize.Y))
            MaxSize = ColorStrip.AbsoluteSize.Y / UIScale.Scale
			Arrow.Position = UDim2.new(1, 0, 0, math.clamp((ColorStrip.AbsoluteSize.Y - (ColorStrip.AbsoluteSize.Y * ColorPicker.V)) / UIScale.Scale, 0, MaxSize))
        end

        local function UpdateFromRGBT(Ignore, IgnoreMainPositions)
            ColorPicker.Color = Color3.fromRGB(ColorPicker.R, ColorPicker.G, ColorPicker.B)
            ColorPicker.T = ColorPicker.Transparency
            ColorPicker.H, ColorPicker.S, ColorPicker.V = ColorPicker.Color:ToHSV()
            UpdateMainDisplay()
            if not IgnoreMainPositions then
                UpdateMainPositions()
            end
            if not Ignore then
                FireCallback()
            end
        end

        local function CreateSlider(SliderProperties)
            local Picker = Instance.new("Frame")
            Picker.Name = `{SliderProperties.Name}Picker`
            Picker.BackgroundTransparency = 1
            Picker.Size = UDim2.new(1, 0, 0, 30)
            Picker.ZIndex = 2
            Picker.Parent = Holder

            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(0, 20, 1, 0)
            Label.Position = UDim2.fromOffset(5, 0)
            Label.FontFace = GetFont('Regular')
            Label.TextSize = 24
            Label.TextColor3 = GetColor("Text/Primary")
            Label.Text = SliderProperties.Text
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 2
            Label.Parent = Picker

            local Input = Instance.new("TextBox")
            Input.Name = "Input"
            Input.BackgroundColor3 = GetColor("Background/Button")
            Input.BorderSizePixel = 0
            Input.ClearTextOnFocus = false
            Input.Position = UDim2.fromOffset(30, 0)
            Input.Size = UDim2.new(0, 80, 1, 0)
            Input.FontFace = GetFont('Regular')
            Input.TextSize = 24
            Input.TextColor3 = GetColor("Text/Primary")
            Input.ZIndex = 2
            Input.Text = tostring(ColorPicker[SliderProperties.Ref])
            Input.Parent = Picker
            AddCorner(Input, UDim.new(0, 7))

            local SliderFrame = Instance.new("ImageButton")
            SliderFrame.Name = "SliderFrame"
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.ImageTransparency = 1
            SliderFrame.Position = UDim2.fromOffset(120, 5)
            SliderFrame.Size = UDim2.fromOffset(200, 20)
            SliderFrame.ZIndex = 2
            SliderFrame.Parent = Picker

            local FrameDragDetector = Instance.new("UIDragDetector")
            FrameDragDetector.CursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
            FrameDragDetector.ActivatedCursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
            FrameDragDetector.DragStyle = Enum.UIDragDetectorDragStyle.Scriptable
            FrameDragDetector.DragAxis = Vector2.new(1, 0)
            FrameDragDetector.ResponseStyle = Enum.UIDragDetectorResponseStyle.Offset
            FrameDragDetector.Parent = SliderFrame

            local RightBar = Instance.new("Frame")
            RightBar.Name = "RightBar"
            RightBar.BackgroundColor3 = GetColor("Slider/RightBar")
            RightBar.ZIndex = 2
            RightBar.BorderSizePixel = 0

            local LeftBar = Instance.new("Frame")
            LeftBar.Name = "LeftBar"
            LeftBar.BackgroundColor3 = GetColor("Slider/LeftBar")
            LeftBar.BorderSizePixel = 0
            LeftBar.ZIndex = 2
            LeftBar.Position = UDim2.fromOffset(0, 9)

            local Handle = Instance.new("TextButton")
            Handle.Name = "Handle"
            Handle.BackgroundColor3 = GetColor("Slider/Handle")
            Handle.BorderSizePixel = 0
            Handle.Size = UDim2.fromOffset(15, 15)
            Handle.AnchorPoint = Vector2.new(0.5, 0)
            Handle.AutoButtonColor = false
            Handle.ZIndex = 2
            Handle.Text = ""
            AddCorner(Handle, UDim.new(1, 0))

            local Decimal = SliderProperties.Decimal or 1

            local function CalculatePosition(Type, CustomPosition)
                local X = Type == "Mouse" and (UIS:GetMouseLocation().X - SliderFrame.AbsolutePosition.X) / UIScale.Scale or Type == "Slider" and Handle.Position.X.Offset or Type == "Custom" and CustomPosition
                
                local MaxSize = math.floor(SliderFrame.AbsoluteSize.X / UIScale.Scale)
                local Pos = math.clamp(X, 0, MaxSize)
                local Scale = math.clamp(Pos / MaxSize, 0, 1)

                return Pos, math.round((Scale * SliderProperties.Max) * Decimal) / Decimal
            end

            local function CalculatePositionFromValue(Value)
                local Position = (Value / SliderProperties.Max) * math.floor(SliderFrame.AbsoluteSize.X / UIScale.Scale)

                return CalculatePosition("Custom", Position)
            end

            local function OnFrameDragged(Type)
                local Pos, Value = CalculatePosition(typeof(Type) == "string" and Type or "Mouse")
                Handle.Position = UDim2.new(0, Pos, 0, -7)
                LeftBar.Size = UDim2.fromOffset(Pos, 3)
                RightBar.Size = UDim2.fromOffset(SliderFrame.Size.X.Offset - Pos, 3)
                RightBar.Position = UDim2.fromOffset(Pos, 9)
                Input.Text = tostring(Value)

                ColorPicker[SliderProperties.Ref] = Value
                UpdateFromRGBT()
                FireCallback()
            end

            local function InputNumber(Number, Ignore, IgnoreMainPositions)
                local Val = tonumber(Number)
                if Val then
                    local Pos = CalculatePositionFromValue(Val)
                    Handle.Position = UDim2.new(0, Pos, 0, -7)
                    LeftBar.Size = UDim2.fromOffset(Pos, 3)
                    RightBar.Size = UDim2.fromOffset(SliderFrame.Size.X.Offset - Pos, 3)
                    RightBar.Position = UDim2.fromOffset(Pos, 9)
                    ColorPicker[SliderProperties.Ref] = Val
                    UpdateFromRGBT(Ignore, IgnoreMainPositions)
                end
                Input.Text = tostring(math.floor(ColorPicker[SliderProperties.Ref] * Decimal) / Decimal)
            end

            local StartPos = CalculatePositionFromValue(ColorPicker[SliderProperties.Ref])
            LeftBar.Size = UDim2.fromOffset(StartPos, 3)
            RightBar.Size = UDim2.fromOffset(SliderFrame.Size.X.Offset - StartPos, 3)
            RightBar.Position = UDim2.fromOffset(StartPos, 9)
            Handle.Position = UDim2.new(0, StartPos, 0, -7)

            RightBar.Parent = SliderFrame
            LeftBar.Parent = SliderFrame
            Handle.Parent = LeftBar

            local HandleDragDetector = Instance.new("UIDragDetector")
            HandleDragDetector.CursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
            HandleDragDetector.ActivatedCursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
            HandleDragDetector.DragStyle = Enum.UIDragDetectorDragStyle.TranslateLine
            HandleDragDetector.DragAxis = Vector2.new(1, 0)
            HandleDragDetector.ResponseStyle = Enum.UIDragDetectorResponseStyle.Offset
            HandleDragDetector.Parent = Handle

            FrameDragDetector.DragStart:Connect(OnFrameDragged)
            FrameDragDetector.DragContinue:Connect(OnFrameDragged)

            HandleDragDetector.DragContinue:Connect(function()
                OnFrameDragged("Slider")
            end)

            Input.FocusLost:Connect(function()
                InputNumber(Input.Text)
            end)

            local Info = TweenInfo.new(0.25)
            local Info2 = TweenInfo.new(0.1)

            Handle.MouseEnter:Connect(function()
                TweenService:Create(Handle, Info, {BackgroundColor3 = GetColor("Slider/HandleHover")}):Play()
            end)
            Handle.MouseLeave:Connect(function()
                TweenService:Create(Handle, Info, {BackgroundColor3 = GetColor('Slider/Handle')}):Play()
            end)
            Handle.MouseButton1Down:Connect(function()
                TweenService:Create(Handle, Info2, {BackgroundColor3 = GetColor('Slider/HandlePress')}):Play()
            end)
            Handle.MouseButton1Up:Connect(function()
                TweenService:Create(Handle, Info2, {BackgroundColor3 = GetColor('Slider/HandleHover')}):Play()
            end)

            local Tab = {}
            function Tab:InputNumber(Num, Ignore, IgnoreMainPositions)
                InputNumber(Num, Ignore, IgnoreMainPositions)
            end

            return Tab
        end

        local RedSlider = CreateSlider({
            Name = "Red",
            Text = "R:",
            Ref = "R",
            Min = 0,
            Max = 255
        })

        local GreenSlider = CreateSlider({
            Name = "Green",
            Text = "G:",
            Ref = "G",
            Min = 0,
            Max = 255
        })

        local BlueSlider = CreateSlider({
            Name = "Blue",
            Text = "B:",
            Ref = "B",
            Min = 0,
            Max = 255
        })

        local TransparencySlider = CreateSlider({
            Name = "Transparency",
            Text = "T:",
            Ref = "Transparency",
            Min = 0,
            Max = 1,
            Decimal = 100
        })

		Components.Reset({
			Parent = Frame,
			Function = function()
				RedSlider:InputNumber(math.floor(DefaultColor.R * 255), true, true)
				GreenSlider:InputNumber(math.floor(DefaultColor.G * 255), true, true)
				BlueSlider:InputNumber(math.floor(DefaultColor.B * 255), true, true)
				TransparencySlider:InputNumber(DefaultTransparency)
			end
		})

        local function UpdateSliderDisplays()
            RedSlider:InputNumber(ColorPicker.R, true, true)
            GreenSlider:InputNumber(ColorPicker.G, true, true)
            BlueSlider:InputNumber(ColorPicker.B, true, true)
            TransparencySlider:InputNumber(ColorPicker.T, false, true)
        end

        local function UpdateFromHSV()
            ColorPicker.Color = Color3.fromHSV(ColorPicker.H, ColorPicker.S, ColorPicker.V)
            ColorPicker.R = ColorPicker.Color.R * 255
            ColorPicker.G = ColorPicker.Color.G * 255
            ColorPicker.B = ColorPicker.Color.B * 255
            UpdateSliderDisplays()
            FireCallback()
        end

		local function UpdatePlus(MouseLocation)
			local X = math.clamp((MouseLocation.X - ColorBackground.AbsolutePosition.X) / UIScale.Scale, 0, ColorBackground.Size.X.Offset)
			local Y = math.clamp((MouseLocation.Y - GuiService.TopbarInset.Height - ColorBackground.AbsolutePosition.Y) / UIScale.Scale, 0, ColorBackground.Size.Y.Offset)
			Plus.Position = UDim2.fromOffset(X, Y)
            ColorPicker.H = 1 - (Plus.Position.X.Offset / ColorBackground.Size.X.Offset)
            ColorPicker.S = 1 - (Plus.Position.Y.Offset / ColorBackground.Size.Y.Offset)
			UpdateFromHSV()
            UpdateMainDisplay()
		end

        local function UpdateArrow(MouseLocation)
			local Y = math.clamp((MouseLocation.Y - GuiService.TopbarInset.Height - ColorStrip.AbsolutePosition.Y) / UIScale.Scale, 0, ColorStrip.Size.Y.Offset)
			Arrow.Position = UDim2.new(1, 0, 0, Y)
            ColorPicker.V = math.floor((1 - (Arrow.Position.Y.Offset / ColorStrip.Size.Y.Offset)) * 255) / 255
            UpdateFromHSV()
			UpdateMainDisplay()
		end

        UpdateMainDisplay()
        UpdateMainPositions()

		RedSlider:InputNumber(math.floor(DefaultColor.R * 255), true, true)
		GreenSlider:InputNumber(math.floor(DefaultColor.G * 255), true, true)
		BlueSlider:InputNumber(math.floor(DefaultColor.B * 255), true, true)
		TransparencySlider:InputNumber(DefaultTransparency, true)

        ColorDisplay.MouseButton1Click:Connect(function()
            ColorPickerDropdown.Visible = not ColorPickerDropdown.Visible
        end)

        ColorBackgroundDragDetector.DragStart:Connect(UpdatePlus)
		ColorBackgroundDragDetector.DragContinue:Connect(UpdatePlus)
		ColorStripDragDetector.DragStart:Connect(UpdateArrow)
		ColorStripDragDetector.DragContinue:Connect(UpdateArrow)

        local SliderIndexes = {
            [1] = RedSlider,
            [2] = GreenSlider,
            [3] = BlueSlider,
            [4] = TransparencySlider
        }

        RGBInput.FocusLost:Connect(function()
            local Numbers = {}
            for Num in RGBInput.Text:gmatch('%d+') do
				Numbers[#Numbers + 1] = Num
            end
			local Len = math.min(#Numbers, 4)
            for i = 1, Len do
                SliderIndexes[i]:InputNumber(tonumber(Numbers[i]), i ~= Len, i ~= Len)
            end
        end)

		local Name = Properties.Name:gsub(' ', '')

        function ColorPicker:Save(Tab)
			Tab[Name] = {
				R = ColorPicker.R,
				G = ColorPicker.G,
				B = ColorPicker.B,
                T = ColorPicker.T,
			}
		end

		function ColorPicker:Load(Tab)
			RedSlider:InputNumber(Tab.R, true, true)
            GreenSlider:InputNumber(Tab.G, true, true)
            BlueSlider:InputNumber(Tab.B, true, true)
            TransparencySlider:InputNumber(Tab.T)
		end

		function ColorPicker:SetVisible(Visible)
			ColorPicker.Visible = Visible
			Frame.Visible = ColorPicker.Visible
		end

        function ColorPicker:SetColor(Color)
            RedSlider:InputNumber(math.floor(Color.R * 255), true, true)
            GreenSlider:InputNumber(math.floor(Color.G * 255), true, true)
            BlueSlider:InputNumber(math.floor(Color.B * 255))
        end

        function ColorPicker:SetTransparency(Transparency)
            TransparencySlider:InputNumber(Transparency)
        end

        ColorPicker.Object = Frame
        Properties.Module.Options[Name] = ColorPicker

        return ColorPicker
    end
}

local ModulesTopBar, MenuOptionsMenu

function Gui:CreateMenu(Properties)
	local Menu = {
		Options = {},
        Buttons = {},
		Keybinds = {}
	}

	local TopBar = Instance.new("TextButton")
	TopBar.Position = UDim2.new(0.5, -350, 0.5, -270)
	TopBar.Size = UDim2.fromOffset(700, 40)
	TopBar.BackgroundColor3 = GetColor('Main/Accent')
    TopBar.Text = ""
	TopBar.AutoButtonColor = false
	TopBar.Name = `{Properties.Name}Menu`
	TopBar.Visible = false
	TopBar.Parent = MenuHolder

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 0)
    UICorner.TopLeftRadius = UDim.new(0, 10)
    UICorner.TopRightRadius = UDim.new(0, 10)
    UICorner.Parent = TopBar

    local NameLabel = Instance.new("TextLabel")
	NameLabel.Name = 'Title'
    NameLabel.Size = UDim2.fromScale(1, 1)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = `  {Properties.Name}`
    NameLabel.TextSize = 32
    NameLabel.FontFace = GetFont('SemiBold')
    NameLabel.TextColor3 = GetColor('Text/Primary')
    NameLabel.Parent = TopBar

	local ScrollingFrame = Instance.new("ScrollingFrame")
	ScrollingFrame.Size = UDim2.new(1, 0, 0, 500)
	ScrollingFrame.Position = UDim2.fromScale(0, 1)
	ScrollingFrame.BackgroundColor3 = GetColor('Background/Primary')
	ScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
	ScrollingFrame.ScrollBarThickness = 6
    ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.None
	ScrollingFrame.Parent = TopBar

    local ScrollingFrameUICorner = Instance.new("UICorner")
    ScrollingFrameUICorner.CornerRadius = UDim.new(0, 0)
    ScrollingFrameUICorner.BottomLeftRadius = UDim.new(0, 10)
    ScrollingFrameUICorner.BottomRightRadius = UDim.new(0, 10)
    ScrollingFrameUICorner.Parent = ScrollingFrame

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0, 10)
	Padding.PaddingBottom = UDim.new(0, 10)
	Padding.Parent = ScrollingFrame

	local Layout = Instance.new("UIListLayout")
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.Padding = UDim.new(0, 5)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = ScrollingFrame

	local Close = Instance.new("TextButton")
	Close.Name = "Close"
	Close.Size = UDim2.fromOffset(40, 40)
	Close.Position = UDim2.new(1, -40, 0, 0)
	Close.BackgroundTransparency = 1
	Close.Text = ""
	Close.Parent = TopBar

	local CloseImage = Instance.new("ImageLabel")
	CloseImage.Name = "Image"
	CloseImage.Size = UDim2.fromOffset(36, 36)
	CloseImage.Position = UDim2.fromOffset(2, 2)
	CloseImage.BackgroundTransparency = 1
	SetIcon(CloseImage, "x")
	CloseImage.Parent = Close

	local function GetHeight()
		return (Layout.AbsoluteContentSize.Y + 400) / UIScale.Scale
	end

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetHeight())
	end)
	ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetHeight())

    local CloseFunction = function()
		ModulesTopBar:Select()
    end

	Close.MouseButton1Click:Connect(function()
		TopBar.Visible = false
        if CloseFunction then
            CloseFunction()
        end
	end)

    function Menu:BindToClose(f)
        if typeof(f) == "function" then
            CloseFunction = f
        end
    end

	function Menu:Show()
		TopBar.Visible = true
	end

	function Menu:Hide()
		TopBar.Visible = false
	end

	function Menu:HideOptions()
		for _, v in Menu.Options do
			v.Object.Visible = false
		end
	end

	function Menu:HideChildren()
		for _, v in ScrollingFrame:GetChildren() do
			if v:IsA("GuiObject") then
				v.Visible = false
			end
		end
	end

	function Menu:ShowOptions()
		for _, v in Menu.Options do
			v.Object.Visible = if v.Visible ~= nil then v.Visible else true
		end
	end

	function Menu:ShowChildren()
		for _, v in ScrollingFrame:GetChildren() do
			if v:IsA("GuiObject") then
				v.Visible = true
			end
		end
	end

	function Menu:ClearAllChildren()
		for _, v in Menu.Options do
			if v.Enabled then
				v:Toggle()
			end
			v.Object:Destroy()
		end
		table.clear(Menu.Options)
		table.clear(Menu.Keybinds)
	end

    if Properties.CanCreateOptions == nil or Properties.CanCreateOptions == true then
        function Menu:CreateOption(Properties)
            Properties.Parent = ScrollingFrame
            Properties.LayoutOrder = table.len(Menu.Options) + table.len(Menu.Keybinds)
            Properties.Module = Menu
            local Toggle = Components.Toggle(Properties)
            Toggle.Options = {}
			Toggle.Buttons = {}

            Toggle.Object.Button.MouseButton2Click:Connect(function()
                MenuOptionsMenu.Object.Title.Text = Properties.Name
                for i, v in Gui.Menus do
                    v.Object.Visible = i == "MenuOptions"
                end
                MenuOptionsMenu:HideOptions()
                for i, v in Toggle.Options do
                    v.Object.Visible = if v.Visible ~= nil then v.Visible else false
                end
            end)

            for i, v in Components do
                if i == 'Keybind' then continue end
                Toggle[`Create{i}`] = function(_, Properties)
                    Properties.Parent = MenuOptionsMenu.Object.ScrollingFrame
                    Properties.LayoutOrder = table.len(Toggle.Options)
                    Properties.Module = Toggle
                    local Obj = v(Properties)
                    MenuOptionsMenu.Options[Properties.Name:gsub(" ", "")] = Obj
                    return Obj
                end
            end

            Menu.Options[Properties.Name:gsub(" ", "")] = Toggle

            return Toggle
        end
    end

    for i, v in Components do
        Menu[`Create{i}`] = function(_, Properties)
            Properties.Parent = ScrollingFrame
            Properties.LayoutOrder = table.len(Menu.Options) + table.len(Menu.Keybinds)
            Properties.Module = Menu
            return v(Properties)
        end
    end

	Menu.Object = TopBar

	Gui.Menus[Properties.Name:gsub(" ", "")] = Menu

	return Menu
end

function Gui:CreateModuleList()
	local ModuleList = {
		Sorting = "Length",
		Text = `<font color = 'rgb(255, 215, 0)'>Tidal</font> <font color = 'rgb(20, 135, 255)'>Wave</font> v{Gui.CurrentVersion}`,
		Padding = 0,
		BackgroundTransparency = 0.5,
		BackgroundEnabled = true,
		BarEnabled = true,
		TextShadow = true,
		BackgroundColor = Color3.fromRGB(0, 0, 0),
		BarColor = Color3.fromRGB(0, 200, 255),
		TextColor = GetColor('Text/Primary'),
		WatermarkTextColor = GetColor('Text/Primary'),
		Alignment = "Right",
		Rainbow = false,
		RainbowBackgroundEnabled = false,
		RainbowSpeed = 1,
		RainbowSpread = 1,
		RainbowDirection = "Down",
		RainbowSaturation = 1,
		RainbowValue = 1,
		BackgroundRainbowSaturation = 1,
		BackgroundRainbowValue = 1,
		RainbowBarEnabled = false,
		BarRainbowSaturation = 1,
		BarRainbowValue = 1,
	}
    local StartSize = UDim2.fromOffset(math.max(GetTextSize(ModuleList.Text, 24, GetFont('Bold'), 1000).X, 300), 32)
	local TopBar = Instance.new("ImageButton")
	TopBar.Name = "ModuleList"
	TopBar.Size = StartSize
	TopBar.Position = UDim2.new(1, -StartSize.X.Offset, 0, 0)
	TopBar.BackgroundTransparency = 1
	TopBar.ImageTransparency = 1
	TopBar.Active = false
	TopBar.Interactable = false
	TopBar.Parent = HudFolder

	local TopBarUIScale = Instance.new('UIScale')
	TopBarUIScale.Scale = 1
	TopBarUIScale.Parent = TopBar

	ModuleList.Object = TopBar

	local WatermarkShadow = Instance.new("TextLabel")
	WatermarkShadow.Name = "Watermark"
	WatermarkShadow.Size = StartSize
	WatermarkShadow.BackgroundTransparency = 1
	WatermarkShadow.Text = RemoveTags(ModuleList.Text)..' '
	WatermarkShadow.TextColor3 = GetColor('Text/Shadow')
	WatermarkShadow.TextSize = 24
	WatermarkShadow.FontFace = GetFont('Bold')
	WatermarkShadow.RichText = true
	WatermarkShadow.TextXAlignment = Enum.TextXAlignment.Right
	WatermarkShadow.Parent = TopBar

	local Watermark = WatermarkShadow:Clone()
	Watermark.RichText = true
	Watermark.TextColor3 = GetColor('Text/Primary')
	Watermark.Text = ModuleList.Text..' '
	Watermark.Position = UDim2.fromOffset(-1, -1)
	Watermark.Parent = WatermarkShadow

	local Children = Instance.new("Frame")
	Children.Name = "Children"
	Children.Size = UDim2.new(1, 0, 0, 1080)
	Children.Position = UDim2.fromOffset(0, 32)
	Children.BackgroundTransparency = 1
	Children.ClipsDescendants = true
	Children.Active = false
	Children.Parent = TopBar

	local Tweens = {}
	local Tweens2 = {}
	local Modules = {}

	local Info = TweenInfo.new(0.5)

	function ModuleList:Enable(Bool)
		TopBar.Visible = if Bool ~= nil then Bool else true
	end

	function ModuleList:Disable(Bool)
		TopBar.Visible = if Bool ~= nil then not Bool else false
	end

	local function Sort()
		if ModuleList.Sorting == "Length" then
			table.sort(Modules, function(a, b)
				return GetTextSize(a.Text, 16, GetFont('SemiBold'), Children.Size.X.Offset).X > GetTextSize(b.Text, 16, GetFont('SemiBold'), Children.Size.X.Offset).X
			end)
		elseif ModuleList.Sorting == "Alphabetical" then
			table.sort(Modules, function(a, b)
				return a.Text:lower() < b.Text:lower()
			end)
		end
	end

	local function Find(Frame)
		for i, v in Modules do
			if v.Frame == Frame then
				return i, v
			end
		end
	end

	local function UpdateYPositions(NoTween)
		for i, v in Modules do
			if NoTween then
				v.Frame.Position = UDim2.fromOffset(v.Frame.Position.X.Offset, (20 + ModuleList.Padding) * (i - 1))
			else
				if Tweens2[v.Frame] then
					Tweens2[v.Frame]:Cancel()
				end
				Tweens2[v.Frame] = TweenService:Create(v.Frame, Info, {Position = UDim2.fromOffset(v.Frame.Position.X.Offset, (20 + ModuleList.Padding) * (i - 1))})
				Tweens2[v.Frame]:Play()
				Tweens2[v.Frame].Completed:Once(function(State)
					if State == Enum.PlaybackState.Completed then
						Tweens2[v.Frame] = nil
					end
				end)
			end
		end
	end

	function ModuleList:AddModule(Module)
		local FoundModule = Children:FindFirstChild(Module)
		if FoundModule then
			if Tweens[FoundModule] and Tweens[FoundModule].Closing then
				table.insert(Modules, {
					Frame = FoundModule,
					Text = FoundModule.TextShadow.TextLabel.Text,
				})
				Sort()
				Tweens[FoundModule].Closing = false
				Tweens[FoundModule].Tween:Cancel()
				Tweens[FoundModule].Tween = TweenService:Create(FoundModule, Info, {AnchorPoint = Vector2.new(ModuleList.Alignment == "Right" and 1 or 0, 0)})
				Tweens[FoundModule].Tween:Play()
				Tweens[FoundModule].Tween.Completed:Once(function(State)
					if State == Enum.PlaybackState.Completed then
						Tweens[FoundModule] = nil
					end
				end)
				UpdateYPositions()
			end
		else
            local TextSize = GetTextSize(Module, 16, GetFont('SemiBold'), Children.Size.X.Offset)
			local Frame = Instance.new("Frame")
			table.insert(Modules, {
				Frame = Frame,
				Text = Module,
			})
			Sort()
			local Index = Find(Frame)
			Frame.BackgroundTransparency = 1
			Frame.Size = UDim2.fromOffset(TextSize.X + 10, 20)
			Frame.Position = UDim2.fromOffset(ModuleList.Alignment == "Right" and TopBar.Size.X.Offset or 0, (20 + ModuleList.Padding) * (Index - 1))
			Frame.AnchorPoint = ModuleList.Alignment == "Right" and Vector2.new(0, 0) or Vector2.new(1, 0)
			Frame.Name = Module
			Frame.Parent = Children
			local TextShadow = Instance.new("TextLabel")
			TextShadow.Name = "TextShadow"
			TextShadow.Size = UDim2.fromOffset(TextSize.X + 10, 20)
			TextShadow.BackgroundColor3 = ModuleList.BackgroundColor
			TextShadow.BackgroundTransparency = ModuleList.BackgroundEnabled and ModuleList.BackgroundTransparency or 1
			TextShadow.BorderSizePixel = 0
			TextShadow.TextColor3 = GetColor('Text/Shadow')
			TextShadow.FontFace = GetFont('SemiBold')
			TextShadow.TextSize = 16
			TextShadow.Text = Module
			TextShadow.Parent = Frame
			local Text = TextShadow:Clone()
			Text.Name = "TextLabel"
			Text.TextColor3 = ModuleList.TextColor
			Text.Position = UDim2.fromOffset(-1, -1)
			Text.BackgroundTransparency = 1
			Text.Parent = TextShadow
			local Bar = Instance.new("Frame")
			Bar.Name = "Bar"
			Bar.BorderSizePixel = 0
			Bar.BackgroundTransparency = ModuleList.BarEnabled and 0 or 1
			Bar.BackgroundColor3 = ModuleList.BarColor
			Bar.Size = UDim2.fromOffset(2, 20)
			Bar.Position = UDim2.fromOffset(ModuleList.Alignment == "Right" and TextSize.X + 8 or 0, 0)
			Bar.Parent = Frame
			Tweens[Frame] = {
				Tween = TweenService:Create(Frame, Info, {AnchorPoint = Vector2.new(ModuleList.Alignment == "Right" and 1 or 0, 0)})
			}
			Tweens[Frame].Tween:Play()
			Tweens[Frame].Tween.Completed:Once(function(State)
				if State == Enum.PlaybackState.Completed then
					Tweens[Frame] = nil
				end
			end)
			UpdateYPositions()
		end
	end

	function ModuleList:RemoveModule(Module)
		local FoundModule = Children:FindFirstChild(Module)
		if FoundModule then
			if Tweens[FoundModule] then
				if Tweens[FoundModule].Closing then
					return
				else
					Tweens[FoundModule].Tween:Cancel()
				end
			else
				Tweens[FoundModule] = {}
			end
			Tweens[FoundModule].Closing = true
			Tweens[FoundModule].Tween = TweenService:Create(FoundModule, Info, {AnchorPoint = Vector2.new(ModuleList.Alignment == "Right" and 0 or 1, 0)})
			Tweens[FoundModule].Tween:Play()
			Tweens[FoundModule].Tween.Completed:Once(function(State)
				if State == Enum.PlaybackState.Completed then
					Tweens[FoundModule] = nil
					FoundModule:Destroy()
				end
			end)
			local Index = Find(FoundModule)
			if Index then
				table.remove(Modules, Index)
			end
			UpdateYPositions()
		end
	end

	function ModuleList:SetScale(Scale)
		TopBarUIScale.Scale = Scale
	end

	function ModuleList:SetWatermarkText(Text)
		if typeof(Text) ~= "string" then return end
		ModuleList.Text = Text
		local TextSize = UDim2.fromOffset(math.max(GetTextSize(Text, 24, GetFont('Bold'), 1000).X + 10, 300), 32)
		ModuleList.Size = TextSize
		WatermarkShadow.Size = TextSize
		Watermark.Size = TextSize
        Text = ModuleList.Alignment == 'Right' and Text..' ' or ' '..Text
		if ModuleList.TextShadow then
			WatermarkShadow.Text = RemoveTags(Text)
			Watermark.Text = Text
		else
			WatermarkShadow.Text = Text
		end
	end

	function ModuleList:SetWatermarkTextShadowEnabled(Enabled)
		if Enabled then
			ModuleList.TextShadow = true
			WatermarkShadow.RichText = false
			WatermarkShadow.TextColor3 = GetColor('Text/Shadow')
			ModuleList:SetWatermarkText(ModuleList.Text)
			Watermark.Visible = true
			Watermark.TextColor3 = ModuleList.WatermarkTextColor
		else
			ModuleList.TextShadow = false
			WatermarkShadow.RichText = true
			WatermarkShadow.TextColor3 = ModuleList.WatermarkTextColor
			ModuleList:SetWatermarkText(ModuleList.Text)
			Watermark.Visible = false
		end
	end

	function ModuleList:ResetWatermarkText()
		ModuleList:SetWatermarkText(`<font color = 'rgb(255, 215, 0)'>Tidal</font> <font color = 'rgb(20, 135, 255)'>Wave</font> v{Gui.CurrentVersion}`)
	end

	function ModuleList:SetPadding(Padding)
		if typeof(Padding) ~= "number" then return end
		ModuleList.Padding = Padding
		UpdateYPositions(true)
	end

	function ModuleList:SetAlignment(Alignment)
		if Alignment ~= "Left" and Alignment ~= "Right" then return end
		ModuleList.Alignment = Alignment
        WatermarkShadow.TextXAlignment = Enum.TextXAlignment[Alignment]
        Watermark.TextXAlignment = WatermarkShadow.TextXAlignment
		for i, v in Modules do
			v.Frame.Position = UDim2.fromOffset(Alignment == "Right" and TopBar.Size.X.Offset or 0, (20 + ModuleList.Padding) * (i - 1))
			v.Frame.AnchorPoint = Alignment == "Right" and Vector2.new(1, 0) or Vector2.new(0, 0)
			v.Frame.Bar.Position = UDim2.fromScale(Alignment == "Right" and 1 or 0, 0)
		end
	end

	function ModuleList:SetBackgroundEnabled(Enabled)
		ModuleList.BackgroundEnabled = Enabled
		for i, v in Modules do
			v.Frame.TextShadow.BackgroundTransparency = Enabled and ModuleList.BackgroundTransparency or 1
		end
	end

	function ModuleList:SetBackgroundTransparency(Transparency)
		if typeof(Transparency) ~= "number" then return end
		ModuleList.BackgroundTransparency = Transparency
		for i, v in Modules do
			v.Frame.TextShadow.BackgroundTransparency = ModuleList.BackgroundEnabled and Transparency or 1
		end
	end

	function ModuleList:SetBarEnabled(Enabled)
		ModuleList.BarEnabled = Enabled
		for i, v in Modules do
			v.Frame.Bar.BackgroundTransparency = Enabled and 0 or 1
		end
	end

	function ModuleList:SetBarColor(Color)
		if typeof(Color) ~= "Color3" then return end
		if ModuleList.Rainbow and ModuleList.RainbowBarEnabled then return end
		ModuleList.BarColor = Color
		for i, v in Modules do
			v.Frame.Bar.BackgroundColor3 = Color
		end
	end

	function ModuleList:SetBackgroundColor(Color)
		if typeof(Color) ~= "Color3" then return end
		ModuleList.BackgroundColor = Color
		if ModuleList.Rainbow and ModuleList.RainbowBackgroundEnabled then return end
		for i, v in Modules do
			v.Frame.TextShadow.BackgroundColor3 = Color
		end
	end

	function ModuleList:SetTextColor(Color)
		if typeof(Color) ~= "Color3" then return end
		ModuleList.TextColor = Color
		if ModuleList.Rainbow then return end
		for i, v in Modules do
			v.Frame.TextShadow.TextLabel.TextColor3 = Color
		end
	end

	function ModuleList:SetWatermarkTextColor(Color)
		if typeof(Color) ~= "Color3" then return end
		ModuleList.WatermarkTextColor = Color
		Watermark.TextColor3 = Color
	end

	function ModuleList:SetSortingMethod(Method: "Length" | "Alphabetical")
		if Method ~= "Length" and Method ~= "Alphabetical" then return end
		ModuleList.Sorting = Method
		Sort()
		UpdateYPositions(true)
	end

	local RainbowCon

	function ModuleList:SetRainbowTextEnabled(Enabled)
		ModuleList.Rainbow = Enabled
		if RainbowCon then
			RainbowCon:Disconnect()
			RainbowCon = nil
		end
		if Enabled then
			local Alpha = 0
			RainbowCon = RunService.PreRender:Connect(function(Delta)
				if #Modules == 0 then return end

				Alpha += Delta * (ModuleList.RainbowSpeed / 5)

				local Down = ModuleList.RainbowDirection == "Down"

				local Saturation, Value = ModuleList.RainbowSaturation, ModuleList.RainbowValue
				local BackgroundSaturation, BackgroundValue = ModuleList.BackgroundRainbowSaturation, ModuleList.BackgroundRainbowValue
				local BarSaturation, BarValue = ModuleList.BarRainbowSaturation, ModuleList.BarRainbowValue

				for i, v in Modules do
					local Offset = (i / #Modules) / (ModuleList.RainbowSpread * 5)
					local Hue = (Alpha - (Down and Offset or -Offset)) % 1

					v.Frame.TextShadow.TextLabel.TextColor3 = Color3.fromHSV(Hue, Saturation, Value)

					if ModuleList.RainbowBackgroundEnabled then
						v.Frame.TextShadow.BackgroundColor3 = Color3.fromHSV(Hue, BackgroundSaturation, BackgroundValue)
					end
					if ModuleList.RainbowBarEnabled then
						v.Frame.Bar.BackgroundColor3 = Color3.fromHSV(Hue, BarSaturation, BarValue)
					end
				end
			end)
			Gui:Clean(RainbowCon)
		else
			ModuleList:SetTextColor(ModuleList.TextColor)
			ModuleList:SetBackgroundColor(ModuleList.BackgroundColor)
			ModuleList:SetBarColor(ModuleList.BarColor)
		end
	end

	function ModuleList:SetRainbowSpeed(Speed)
		ModuleList.RainbowSpeed = Speed
	end

	function ModuleList:SetRainbowSpread(Speed)
		ModuleList.RainbowSpread = Speed
	end

	function ModuleList:SetRainbowDirection(Direction)
		if Direction ~= "Up" and Direction ~= "Down" then return end
		ModuleList.RainbowDirection = Direction
	end

	function ModuleList:SetRainbowBackgroundEnabled(Enabled)
		ModuleList.RainbowBackgroundEnabled = Enabled
		if not Enabled then
			ModuleList:SetBackgroundColor(ModuleList.BackgroundColor)
		end
	end

	function ModuleList:SetRainbowSaturation(Saturation)
		ModuleList.RainbowSaturation = Saturation
	end

	function ModuleList:SetRainbowValue(Value)
		ModuleList.RainbowValue = Value
	end

	function ModuleList:SetBackgroundRainbowSaturation(Saturation)
		ModuleList.BackgroundRainbowSaturation = Saturation
	end

	function ModuleList:SetBackgroundRainbowValue(Value)
		ModuleList.BackgroundRainbowValue = Value
	end

	function ModuleList:SetRainbowBarEnabled(Enabled)
		ModuleList.RainbowBarEnabled = Enabled
		if not Enabled then
			ModuleList:SetBarColor(ModuleList.BarColor)
		end
	end

	function ModuleList:SetBarRainbowSaturation(Saturation)
		ModuleList.BarRainbowSaturation = Saturation
	end

	function ModuleList:SetBarRainbowValue(Value)
		ModuleList.BarRainbowValue = Value
	end

	return ModuleList
end

local ModuleList = Gui:CreateModuleList()

local CategoryArray = {}

function Gui:RemoveModule(Module)
	if Gui.Modules and Gui.Modules[Module] then
        if Gui.Modules[Module].Enabled then
            Gui.Modules[Module]:Toggle(true)
        end
        if Gui.Modules[Module].Object then
            Gui.Modules[Module].Object:Destroy()
        end
		LoopClean(Gui.Modules[Module])
		Gui.Modules[Module] = nil
	end
end

local function UpdateCategoryPositions()
	local x = 8
	local y = 60
	for i, v in CategoryArray do
		local CurrentCategory = Gui.Categories[v]
		if CurrentCategory then
			if i > 9 then
				if i % 10 == 0 then
					x = 8
				end
				local AboveCategory = Gui.Categories[CategoryArray[i - 9]]
				y = 60 + AboveCategory.Object.Size.Y.Offset + AboveCategory.Object.ScrollingFrame.Size.Y.Offset + 10
				x += i > 10 and (Gui.Categories[CategoryArray[i - 9]].Object.Size.X.Offset + 10) or 0
			elseif i > 1 then
				x += Gui.Categories[CategoryArray[i - 1]].Object.Size.X.Offset + 10
			end
			local Pos = UDim2.fromOffset(x, y)
			CurrentCategory:SetOpenedPosition(Pos)
			if CategoryHolder.Visible and not CurrentCategory:IsMoving() then
				CurrentCategory.Object.Position = Pos
			end
		end
	end
end

function Gui:CreateCategory(Properties)
	local Rand = Random.new(table.len(Gui.Categories))
	local Category = {
		Expanded = true,
		ClosedPosition = UDim2.fromScale(Rand:NextNumber(-1, 1), Rand:NextInteger(0, 1) == 0 and -1 or 1),
		OpenedPosition = UDim2.fromOffset(8, 60)
	}

	local Info = TweenInfo.new(0.2)
	local CloseInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local OpenTween, CloseTween, ExpandTween, ArrowTween

	local TopBar2 = TopBar
	local TopBar = Instance.new("ImageButton")
	TopBar.Position = Category.ClosedPosition
	TopBar.Size = UDim2.fromOffset(180, 28)
	TopBar.Name = `{Properties.Name}Category`
    TopBar.BackgroundColor3 = GetColor("Main/Accent")
	TopBar.Parent = CategoryHolder

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 0)
    UICorner.TopLeftRadius = UDim.new(0, 5)
    UICorner.TopRightRadius = UDim.new(0, 5)
    UICorner.Parent = TopBar

    local NameLabel = Instance.new("TextLabel")
	NameLabel.Name = 'Title'
    NameLabel.Text = `   {Properties.Name}`
	NameLabel.TextColor3 = GetColor('Text/Primary')
	NameLabel.FontFace = GetFont('SemiBold')
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	NameLabel.TextSize = 20
	NameLabel.BackgroundTransparency = 1
    NameLabel.Size = UDim2.fromScale(1, 1)
    NameLabel.Parent = TopBar

	local DragDetector = Instance.new("UIDragDetector")
	DragDetector.CursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
	DragDetector.ActivatedCursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
	DragDetector.Parent = TopBar

	local ScrollingFrame = Instance.new("ScrollingFrame")
	ScrollingFrame.Size = UDim2.new(1, 0, 0, 380)
    ScrollingFrame.Position = UDim2.fromScale(0, 1)
    ScrollingFrame.BackgroundColor3 = GetColor('Background/Primary')
	ScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
	ScrollingFrame.ScrollBarThickness = 0
	ScrollingFrame.ScrollBarImageTransparency = 1
	ScrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.None
	ScrollingFrame.Parent = TopBar

    local ScrollingFrameUICorner = Instance.new("UICorner")
    ScrollingFrameUICorner.CornerRadius = UDim.new(0, 0)
    ScrollingFrameUICorner.BottomLeftRadius = UDim.new(0, 5)
    ScrollingFrameUICorner.BottomRightRadius = UDim.new(0, 5)
    ScrollingFrameUICorner.Parent = ScrollingFrame

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0, 6)
	Padding.PaddingBottom = UDim.new(0, 6)
	Padding.Parent = ScrollingFrame

	local Layout = Instance.new("UIListLayout")
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.Padding = UDim.new(0, 5)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = ScrollingFrame

	local Arrow = Instance.new("TextButton")
	Arrow.Name = "Arrow"
	Arrow.Size = UDim2.fromOffset(28, 28)
	Arrow.Position = UDim2.new(1, -28, 0, 0)
	Arrow.BackgroundTransparency = 1
	Arrow.Text = ""
	Arrow.Parent = TopBar

	local ArrowImage = Instance.new("ImageLabel")
	ArrowImage.Name = "Image"
	ArrowImage.Size = UDim2.fromOffset(24, 24)
	ArrowImage.Position = UDim2.fromOffset(2, 2)
	ArrowImage.BackgroundTransparency = 1
	SetIcon(ArrowImage, "chevron-down")
	ArrowImage.Parent = Arrow

	local function GetHeight(NoLimits)
		local AbsoluteContentSize = Layout.AbsoluteContentSize
		local Scale = UIScale.Scale
		return Category.Expanded and (NoLimits and (AbsoluteContentSize.Y + 12) / Scale or math.clamp((AbsoluteContentSize.Y + 12) / Scale, 184, 532)) or 0
	end

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ScrollingFrame.Size = UDim2.new(1, 0, 0, GetHeight())
		ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetHeight(true))
	end)

	function Category:Expand(Instant)
		self.Expanded = not self.Expanded
        if not Gui.CategoryAnimations or Instant == true then
            ScrollingFrame.Size = UDim2.new(1, 0, 0, GetHeight())
            ScrollingFrame.Visible = self.Expanded
            Arrow.Rotation = self.Expanded and 0 or -90
            UICorner.BottomLeftRadius = UDim.new(0, self.Expanded and 0 or 5)
            UICorner.BottomRightRadius = UDim.new(0, self.Expanded and 0 or 5)
            return
        end
		if ExpandTween then
			ExpandTween:Cancel()
		end
		if ArrowTween then
			ArrowTween:Cancel()
		end
		ExpandTween = TweenService:Create(ScrollingFrame, Info, {Size = UDim2.new(1, 0, 0, GetHeight())})
		ArrowTween = TweenService:Create(Arrow, Info, {Rotation = self.Expanded and 0 or -90})
		if self.Expanded then
			ScrollingFrame.Visible = true
            UICorner.BottomLeftRadius = UDim.new(0, 0)
            UICorner.BottomRightRadius = UDim.new(0, 0)
		else
			ExpandTween.Completed:Once(function(State)
				if State == Enum.PlaybackState.Completed then
					ScrollingFrame.Visible = false
                    UICorner.BottomLeftRadius = UDim.new(0, 5)
                    UICorner.BottomRightRadius = UDim.new(0, 5)
					ExpandTween, ArrowTween = nil, nil
				end
			end)
		end
		ExpandTween:Play()
		ArrowTween:Play()
	end

	DragDetector.DragContinue:Connect(function()
		Category.OpenedPosition = TopBar.Position
	end)

	function Category:Toggle()
		local Visible = CategoryHolder.Visible
        if not Gui.CategoryAnimations then
            CategoryHolder.Visible = not Visible
            Modal.Visible = not Visible
            TopBar2.Visible = not Visible
            return
        end
		if Visible and not CloseTween then
			CloseTween = TweenService:Create(TopBar, CloseInfo, {Position = self.ClosedPosition})
			CloseTween:Play()
			CloseTween.Completed:Once(function(State)
				if State == Enum.PlaybackState.Completed and Visible then
					CategoryHolder.Visible = false
					Modal.Visible = false
				end
				CloseTween = nil
			end)
		else
			if CloseTween then
				CloseTween:Cancel()
				TopBar2.Visible = true
			end
			OpenTween = TweenService:Create(TopBar, Info, {Position = self.OpenedPosition})
			OpenTween:Play()
			OpenTween.Completed:Once(function()
				OpenTween = nil
			end)
		end
	end

	function Category:SetOpenedPosition(Pos)
		self.OpenedPosition = Pos
		if CategoryHolder.Visible and not self:IsMoving() then
			TopBar.Position = self.OpenedPosition
		end
	end

	function Category:IsMoving()
		return OpenTween ~= nil or CloseTween ~= nil
	end

	Arrow.MouseButton1Click:Connect(function()
		Category:Expand()
	end)
	Arrow.MouseButton2Down:Connect(function()
		Category:Expand()
	end)
	TopBar.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton2 then
			Category:Expand()
		end
	end)

	function Category:CreateModule(Properties)
        Gui:RemoveModule(Properties.Name)
		local Module = {
			Enabled = false,
			Hold = false,
            Keybind = 'None',
			Options = {},
            Keybinds = {}
		}

		local Button = Instance.new("TextButton")
		Button.Name = `{Properties.Name}Module`
		Button.BackgroundColor3 = GetColor('Background/Button')
		Button.Text = ` {Properties.Name}`
		Button.TextXAlignment = Enum.TextXAlignment.Left
		Button.Size = UDim2.new(1, -10, 0, 26)
		Button.TextColor3 = GetColor('Text/Primary')
		Button.TextSize = 17
		Button.AutoButtonColor = false
		Button.FontFace = GetFont('Regular')
		Button.LayoutOrder = table.len(Gui.Modules)
		Button.Parent = ScrollingFrame
		AddCorner(Button, UDim.new(0, 5))
		AddTooltip(Button, Properties.Info or Properties.Tooltip)
		AddHighlight(Button)
		AddMaid(Module)
		AddInstanceTable(Module)

		local EnabledBar = Instance.new("Frame")
		EnabledBar.Name = "Enabled"
		EnabledBar.BackgroundColor3 = GetColor('Main/DisabledBar')
		EnabledBar.Size = UDim2.fromOffset(2, 20)
		EnabledBar.Position = UDim2.new(1, -6, 0, 3)
		EnabledBar.BorderSizePixel = 0
		EnabledBar.Parent = Button

		local TextSize = GetTextSize(` {Properties.Name}`, 17, GetFont('Regular'), 1000).X

		if TextSize > (TopBar.Size.X.Offset - 10) then
			TopBar.Size = UDim2.fromOffset(TextSize, 28)
			UpdateCategoryPositions()
		end

        local KeybindFrame

        Run(function()
            KeybindFrame = Instance.new("Frame")
            KeybindFrame.Name = `{Properties.Name}Keybind`
            KeybindFrame.BackgroundTransparency = 1
            KeybindFrame.Size = UDim2.new(1, -100, 0, 40)
            KeybindFrame.LayoutOrder = 0
            KeybindFrame.Parent = Gui.Menus.Options.Object.ScrollingFrame

            local Background = Instance.new("Frame")
            Background.Name = "Background"
            Background.BackgroundColor3 = GetColor('Background/Button')
            Background.BorderSizePixel = 0
            Background.Size = UDim2.new(1, -45, 1, 0)
            Background.Parent = KeybindFrame
            AddCorner(Background, UDim.new(0, 7))

            local KeybindName = Instance.new("TextLabel")
            KeybindName.Name = "KeybindName"
            KeybindName.BackgroundTransparency = 1
            KeybindName.Size = UDim2.fromOffset(200, 40)
            KeybindName.TextColor3 = GetColor('Text/Primary')
            KeybindName.TextSize = 24
            KeybindName.FontFace = GetFont('Regular')
            KeybindName.Text = ' Keybind'
            KeybindName.TextXAlignment = Enum.TextXAlignment.Left
            KeybindName.Parent = Background

            local BindButton = Instance.new("TextButton")
            BindButton.Name = "BindButton"
            BindButton.BackgroundColor3 = GetColor('Background/Secondary')
            BindButton.BorderSizePixel = 0
            BindButton.Size = UDim2.fromOffset(200, 30)
            BindButton.Position = UDim2.fromOffset(200, 5)
            BindButton.TextColor3 = GetColor('Text/Primary')
            BindButton.TextSize = 24
            BindButton.FontFace = GetFont('Regular')
            BindButton.Text = Properties.Keybind or "None"
            BindButton.AutoButtonColor = false
            BindButton.Parent = Background
            AddCorner(BindButton, UDim.new(0, 7))
            AddHighlight(BindButton, GetColor('Background/Secondary'))
            AddTooltip(BindButton, "Click to bind")

            local DeleteKeybind = Instance.new("TextButton")
            DeleteKeybind.Name = "Delete"
            DeleteKeybind.BackgroundColor3 = GetColor('Background/Button')
            DeleteKeybind.Text = ""
            DeleteKeybind.BorderSizePixel = 0
            DeleteKeybind.Size = UDim2.fromOffset(40, 40)
            DeleteKeybind.Position = UDim2.new(1, -40, 0, 0)
            DeleteKeybind.AutoButtonColor = false
            DeleteKeybind.Parent = KeybindFrame
            AddCorner(DeleteKeybind, UDim.new(0, 7))
            AddHighlight(DeleteKeybind)
            AddTooltip(DeleteKeybind, "Click to delete keybind")

            local DeleteKeybindImage = Instance.new("ImageLabel")
            DeleteKeybindImage.Name = "Image"
            DeleteKeybindImage.BackgroundTransparency = 1
            DeleteKeybindImage.Size = UDim2.fromOffset(24, 24)
            DeleteKeybindImage.Position = UDim2.fromOffset(8, 8)
            SetIcon(DeleteKeybindImage, "x")
            DeleteKeybindImage.Parent = DeleteKeybind

            local Hold = Instance.new("TextButton")
            Hold.Name = "Hold"
            Hold.BackgroundColor3 = GetColor('Background/Secondary')
            Hold.BorderSizePixel = 0
            Hold.Size = UDim2.fromOffset(140, 30)
            Hold.Position = UDim2.fromOffset(410, 5)
            Hold.TextColor3 = GetColor('Text/Primary')
            Hold.TextSize = 24
            Hold.FontFace = GetFont('Regular')
            Hold.AutoButtonColor = false
            Hold.Text = "Hold"
            Hold.Parent = Background
            AddCorner(Hold, UDim.new(0, 7))
            AddHighlight(Hold, GetColor('Background/Secondary'))
            AddTooltip(Hold, `Toggles off the module when releasing the keybind`)

            local EnabledBar = Instance.new("Frame")
            EnabledBar.Name = "Enabled"
            EnabledBar.BackgroundColor3 = Properties.Hold and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
            EnabledBar.Size = UDim2.fromOffset(2, 24)
            EnabledBar.Position = UDim2.new(1, -8, 0, 3)
            EnabledBar.BorderSizePixel = 0
            EnabledBar.Parent = Hold

            BindButton.MouseButton1Click:Connect(function()
                if Gui.Binding then
                    Gui.Binding = nil
                    BindButton.Text = Module.Keybind or 'None'
                else
                    BindButton.Text = "Press Key"
                    task.wait()
                    Gui.Binding = Module
                end
            end)

            function Module:SetKeybind(Bind)
                self.Keybind = Bind or 'None'
                BindButton.Text = Bind or 'None'
            end

            function Module:ToggleHold()
                self.Hold = not self.Hold
                TweenEnabledBar(EnabledBar, self.Hold)
            end

            DeleteKeybind.MouseButton1Click:Connect(function()
                Module:SetKeybind('None')
            end)
            Hold.MouseButton1Click:Connect(function()
                Module:ToggleHold()
            end)
        end)

		function Module:Toggle(NoNotify)
			self.Enabled = not self.Enabled
			if not NoNotify then
                local Toggled = self.Enabled and 'Enabled' or 'Disabled'
                local Color = GetColor(`Notification/Module{Toggled}`):ToHex()
				Notify({
					Title = "Module Toggled",
					Text = `{Properties.Name} has been <font color = "#{Color}">{Toggled}</font>`,
					Duration = Gui.ModuleNotificationDuration,
				})
			end

            TweenEnabledBar(EnabledBar, self.Enabled)

			if self.Enabled then
				ModuleList:AddModule(Properties.Name)
                if Properties.Enabled then
                    task.spawn(Properties.Enabled)
                end
			else
				ModuleList:RemoveModule(Properties.Name)
				self:DisconnectAll()
				self:ClearInstances()
			end
            if Properties.Function then
				task.spawn(Properties.Function, self.Enabled)
			end
		end

		Button.MouseButton1Click:Connect(function()
            Module:Toggle()
        end)
		Button.MouseButton2Click:Connect(function()
			Tooltip.Visible = false
			CategoryHolder.Visible = false
			Gui.Menus.Options:HideChildren()
			for _, v in Module.Options do
				v.Object.Visible = if v.Visible ~= nil then v.Visible else true
			end
            for _, v in Module.Keybinds do
                v.Object.Visible = true
            end
			KeybindFrame.Visible = true
            Gui.Menus.Options.Object.Title.Text = Properties.Name
			Gui.Menus.Options:Show()
		end)

		Module.Object = Button
		Module.KeybindObject = KeybindFrame

		for i, v in Components do
			Module[`Create{i}`] = function(_, Properties)
				Properties.Parent = Gui.Menus.Options.Object.ScrollingFrame
                Properties.LayoutOrder = table.len(Module.Options) + table.len(Module.Keybinds)
				Properties.Module = Module
				return v(Properties)
			end
		end

		Gui.Modules[Properties.Name:gsub(' ', '')] = Module

		return Module
	end

	function Category:CreateButton(Properties)
		local Button = {
            Keybind = 'None',
			Options = {},
            Keybinds = {}
		}

		local TextButton = Instance.new("TextButton")
		TextButton.Name = `{Properties.Name}Button`
		TextButton.BackgroundColor3 = GetColor('Background/Button')
		TextButton.TextXAlignment = Enum.TextXAlignment.Left
		TextButton.Size = UDim2.new(1, -10, 0, 26)
		TextButton.TextColor3 = GetColor('Text/Primary')
		TextButton.TextSize = 17
		TextButton.FontFace = GetFont('Regular')
		TextButton.Text = ` {Properties.Name}`
		TextButton.AutoButtonColor = false
        TextButton.LayoutOrder = table.len(Gui.Modules) + table.len(Gui.Buttons)
		TextButton.Parent = ScrollingFrame
		AddCorner(TextButton, UDim.new(0, 5))
		AddTooltip(TextButton, Properties.Info or Properties.Tooltip)
		AddHighlight(TextButton)

		function Button:Toggle()
			if Properties.Function then
				Properties.Function()
			end
		end

        local KeybindFrame

        Run(function()
            KeybindFrame = Instance.new("Frame")
            KeybindFrame.Name = `{Properties.Name}Keybind`
            KeybindFrame.BackgroundTransparency = 1
            KeybindFrame.Size = UDim2.new(1, -100, 0, 40)
            KeybindFrame.LayoutOrder = 0
            KeybindFrame.Parent = Gui.Menus.Options.Object.ScrollingFrame

            local Background = Instance.new("Frame")
            Background.Name = "Background"
            Background.BackgroundColor3 = GetColor('Background/Button')
            Background.BorderSizePixel = 0
            Background.Size = UDim2.new(1, -45, 1, 0)
            Background.Parent = KeybindFrame
            AddCorner(Background, UDim.new(0, 7))

            local KeybindName = Instance.new("TextLabel")
            KeybindName.Name = "KeybindName"
            KeybindName.BackgroundTransparency = 1
            KeybindName.Size = UDim2.fromOffset(200, 40)
            KeybindName.TextColor3 = GetColor('Text/Primary')
            KeybindName.TextSize = 24
            KeybindName.FontFace = GetFont('Regular')
            KeybindName.Text = ' Keybind'
            KeybindName.TextXAlignment = Enum.TextXAlignment.Left
            KeybindName.Parent = Background

            local BindButton = Instance.new("TextButton")
            BindButton.Name = "BindButton"
            BindButton.BackgroundColor3 = GetColor('Background/Secondary')
            BindButton.BorderSizePixel = 0
            BindButton.Size = UDim2.fromOffset(200, 30)
            BindButton.Position = UDim2.fromOffset(350, 5)
            BindButton.TextColor3 = GetColor('Text/Primary')
            BindButton.TextSize = 24
            BindButton.FontFace = GetFont('Regular')
            BindButton.Text = Properties.Keybind or "None"
            BindButton.AutoButtonColor = false
            BindButton.Parent = Background
            AddCorner(BindButton, UDim.new(0, 7))
            AddHighlight(BindButton, GetColor('Background/Secondary'))
            AddTooltip(BindButton, "Click to bind")

            local DeleteKeybind = Instance.new("TextButton")
            DeleteKeybind.Name = "Delete"
            DeleteKeybind.BackgroundColor3 = GetColor('Background/Button')
            DeleteKeybind.Text = ""
            DeleteKeybind.BorderSizePixel = 0
            DeleteKeybind.Size = UDim2.fromOffset(40, 40)
            DeleteKeybind.Position = UDim2.new(1, -40, 0, 0)
            DeleteKeybind.AutoButtonColor = false
            DeleteKeybind.Parent = KeybindFrame
            AddCorner(DeleteKeybind, UDim.new(0, 7))
            AddHighlight(DeleteKeybind)
            AddTooltip(DeleteKeybind, "Click to delete keybind")

            local DeleteKeybindImage = Instance.new("ImageLabel")
            DeleteKeybindImage.Name = "Image"
            DeleteKeybindImage.BackgroundTransparency = 1
            DeleteKeybindImage.Size = UDim2.fromOffset(24, 24)
            DeleteKeybindImage.Position = UDim2.fromOffset(8, 8)
            SetIcon(DeleteKeybindImage, "x")
            DeleteKeybindImage.Parent = DeleteKeybind

            BindButton.MouseButton1Click:Connect(function()
                if Gui.Binding then
                    Gui.Binding = nil
                    BindButton.Text = Button.Keybind or 'None'
                else
                    BindButton.Text = "Press Key"
                    task.wait()
                    Gui.Binding = Button
                end
            end)

            function Button:SetKeybind(Bind)
                self.Keybind = Bind or 'None'
                BindButton.Text = Bind or 'None'
            end

            DeleteKeybind.MouseButton1Click:Connect(function()
                Button:SetKeybind('None')
            end)
        end)

		TextButton.MouseButton1Click:Connect(Button.Toggle)
		TextButton.MouseButton2Click:Connect(function()
			Tooltip.Visible = false
			CategoryHolder.Visible = false
			Gui.Menus.Options:HideChildren()
			for _, v in Button.Options do
				v.Object.Visible = if v.Visible ~= nil then v.Visible else true
			end
            for _, v in Button.Keybinds do
                v.Object.Visible = true
            end
            KeybindFrame.Visible = true
            Gui.Menus.Options.Object.Title.Text = Properties.Name
			Gui.Menus.Options:Show()
		end)

        Button.Object = TextButton

		for i, v in Components do
			Button[`Create{i}`] = function(_, Properties)
				Properties.Parent = Gui.Menus.Options.Object.ScrollingFrame
                Properties.LayoutOrder = table.len(Button.Options) + table.len(Button.Keybinds)
				Properties.Module = Button
				return v(Properties)
			end
		end

        Gui.Buttons[Properties.Name:gsub(" ", "")] = Button

		return Button
	end

	Category.Object = TopBar

	Gui.Categories[Properties.Name] = Category
	table.insert(CategoryArray, Properties.Name)

	UpdateCategoryPositions()

	return Category
end

local OptionsMenu = Gui:CreateMenu({
	Name = "Options",
})

local PrevMenu

MenuOptionsMenu = Gui:CreateMenu({
    Name = "Menu Options"
})
MenuOptionsMenu.Object.Title.Text = "Options"
MenuOptionsMenu:BindToClose(function()
    for i, v in Gui.Menus do
        if i == PrevMenu then
            v:Show()
            break
        end
    end
end)

local ConfigMenu = Gui:CreateMenu({
	Name = "Config",
})

local KeepOnTeleport; KeepOnTeleport = ConfigMenu:CreateToggle({
    Name = "Keep On Teleport",
    Info = "Keeps tidal wave opened when teleporting through games.",
    Enabled = function()
        if not queueonteleport then NotifyPoopSploit("queueonteleport") return end
        local TeleportCheck = false
        KeepOnTeleport:Clean(Plr.OnTeleport:Connect(function()
            if TeleportCheck then return end
            TeleportCheck = true
            local Code
            if shared.TidalWaveDev then
                Code = 'shared.TidalWaveDev = true\nloadfile("Loader.lua")()'
            else
                Code = 'loadstring(game:HttpGet("https://github.com/fluidnarrator30/Tidal-Wave/blob/main/Loader.lua", true))()'
            end
            queueonteleport(Code)
        end))
    end
})

local AllowMouseBinding; AllowMouseBinding = ConfigMenu:CreateToggle({
    Name = "Allow Mouse Binding",
    Info = "Allows you to bind modules to mouse buttons.",
})

local MenuKeybind = ConfigMenu:CreateKeybind({
	Name = "Menu",
	Keybind = "RightShift"
})

local MenuKeybind2 = ConfigMenu:CreateKeybind({
	Name = "Menu2",
	Text = "Menu Keybind 2"
})

local DoneButton, UpdateFonts

local function IsTextObject(Obj)
    return Obj:IsA("TextButton") or Obj:IsA("TextLabel") or Obj:IsA("TextBox")
end

do
	local function SetFont(Obj, Font)
		if IsTextObject(Obj) then
			Obj.FontFace = Font
		elseif Obj:IsA("Frame") then
			for _, v in Obj:GetChildren() do
                SetFont(v, Font)
			end
		end
	end

	UpdateFonts = function()
		local RegularFont = GetFont('Regular')
		local SemiBoldFont = GetFont('SemiBold')
		local BoldFont = GetFont('Bold')

		DoneButton.FontFace = RegularFont
		Tooltip.FontFace = RegularFont

		for i, v in Gui.Menus do
			SetFont(v.Object.Title, SemiBoldFont)
			for _, v2 in v.Object.ScrollingFrame:GetDescendants() do
				SetFont(v2, RegularFont)
			end
		end

		for i, v in Gui.Categories do
			SetFont(v.Object.Title, SemiBoldFont)
			for _, v2 in v.Object.ScrollingFrame:GetDescendants() do
				SetFont(v2, RegularFont)
			end
		end

		for i, v in TopBar:GetChildren() do
			SetFont(v, RegularFont)
		end

		local WatermarkShadow = ModuleList.Object:FindFirstChildOfClass("TextLabel")
		local Watermark = WatermarkShadow and WatermarkShadow:FindFirstChildOfClass("TextLabel")

		if WatermarkShadow then
			SetFont(WatermarkShadow, BoldFont)
			if Watermark then
				SetFont(Watermark, BoldFont)
			end
		end

		for i, v in ModuleList.Object.Children:GetChildren() do
			local TextShadow = v:FindFirstChildOfClass("TextLabel")
			local TextLabel = TextShadow and TextShadow:FindFirstChildOfClass("TextLabel")
			if TextShadow then
				SetFont(TextShadow, RegularFont)
				if TextLabel then
					SetFont(TextLabel, RegularFont)
				end
			end
		end

		for i, v in NotificationFolder:GetChildren() do
			if v:IsA("Frame") then
				local TextShadow = v:FindFirstChild("TextShadow")
				local Text = TextShadow and TextShadow:FindFirstChildOfClass("TextLabel")
				local TitleShadow = v:FindFirstChild("TitleShadow")
				local Title = TitleShadow and TitleShadow:FindFirstChildOfClass("TextLabel")
				if TextShadow then
					SetFont(TextShadow, RegularFont)
					if Text then
						SetFont(Text, RegularFont)
					end
				end
				if TitleShadow then
					SetFont(TitleShadow, SemiBoldFont)
					if Title then
						SetFont(Title, SemiBoldFont)
					end
				end
			end
		end
	end
end

Run(function()
    local function AddFont(FontName)
        local Fonts = {Gui.Fonts[FontName].Name}

        for _, v in Enum.Font:GetEnumItems() do
            if v.Name == Gui.Fonts[FontName].Name then continue end
			Fonts[#Fonts + 1] = v.Name
        end

        ConfigMenu:CreateDropdown({
            Name = `{FontName} Font`,
            List = Fonts,
            Function = function(Val)
                Gui.Fonts[FontName].Font = Font.fromEnum(Enum.Font[Val])
                Gui.Fonts[FontName].Name = Val
                UpdateFonts()
            end
        })
    end

	AddFont("Regular")
    AddFont("SemiBold")
    AddFont("Bold")
end)

local ReloadButton = ConfigMenu:CreateButton({
	Name = "Reload",
	Function = function()
		local Dev = shared.TidalWaveDev
		Gui:Shutdown()
		if IsStudio then
			for _, v in script.Parent.Parent.Games:GetChildren() do
				v.Enabled = false
			end
			script.Parent.Parent.Enabled = false
			script.Parent.Parent.Enabled = true
		else
			if Dev then
				shared.TidalWaveDev = true
				loadfile("Loader.lua")()
			else
				loadstring(game:HttpGet("https://raw.githubusercontent.com/fluidnarrator30/Tidal-Wave/refs/heads/main/Loader.lua", true))()
			end
		end
	end,
})

ConfigMenu:CreateButton({
	Name = "Close",
	Function = Gui.Shutdown
})

local GuiMenu = Gui:CreateMenu({
	Name = "GUI",
})

GuiMenu:CreateOption({
    Name = "Category Animations",
    Default = true,
    Function = function(Enabled)
        Gui.CategoryAnimations = Enabled
    end
})

local function ColorOption(Option)
	local Icon = Option.Object:FindFirstChild('Reset') or Option.Object:FindFirstChild('Delete')
	if Icon then
		ApplyColor(Icon, {['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Icon.Image, {['Main/Icons'] = {'ImageColor3', 'ImageTransparency'}})
	end
	if Option.Type == "Toggle" then
		ApplyColor(Option.Object.Button, {['Text/Primary'] = {'TextColor3', 'TextTransparency'},['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Option.Object.Button.Enabled, Option.Enabled and {['Main/EnabledBar'] = {'BackgroundColor3', 'BackgroundTransparency'}} or {['Main/DisabledBar'] = {'BackgroundColor3', 'BackgroundTransparency'}})
	elseif Option.Type == "TextBox" then
		ApplyColor(Option.Object, {['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Option.Object.TextLabel, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}})
		ApplyColor(Option.Object.TextBox, {['Background/Secondary'] = {'BackgroundColor3', 'BackgroundTransparency'}, ['Text/Primary'] = {'TextColor3', 'TextTransparency'}, ['Text/Placeholder'] = {'PlaceholderColor3'}})
	elseif Option.Type == "Slider" then
		ApplyColor(Option.Object.Background, {['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Option.Object.Background.TextLabel, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}})
		ApplyColor(Option.Object.Background.Input, {['Background/Secondary'] = {'BackgroundColor3', 'BackgroundTransparency'}, ['Text/Primary'] = {'TextColor3', 'TextTransparency'}})
		ApplyColor(Option.Object.Background.SliderFrame.RightBar, {['Slider/RightBar'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Option.Object.Background.SliderFrame.LeftBar, {['Slider/LeftBar'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Option.Object.Background.SliderFrame.LeftBar.Handle, {['Slider/Handle'] = {'BackgroundColor3', 'BackgroundTransparency'}})
	elseif Option.Type == "TextList" then
		ApplyColor(Option.Object.Background, {['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Option.Object.Background.TextLabel, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}})
		ApplyColor(Option.Object.Background.TopBar, {['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Option.Object.Background.TopBar.TextLabel, {['Background/Secondary'] = {'BackgroundColor3', 'BackgroundTransparency'}, ['Text/Primary'] = {'TextColor3', 'TextTransparency'}})
		ApplyColor(Option.Object.Background.TopBar.TextLabel.ScrollingFrame, {['Background/Secondary'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Option.Object.Background.TopBar.TextLabel.Arrow.ArrowImage, {['Main/Icons'] = {'ImageColor3', 'ImageTransparency'}})
		ApplyColor(Option.Object.Delete, {['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Option.Object.Delete.Image, {['Main/Icons'] = {'ImageColor3', 'ImageTransparency'}})
		for _, Button in Option.Object.Background.TopBar.TextLabel.ScrollingFrame:GetChildren() do
			if Button:IsA("TextButton") then
				if Button.Name == 'Plus' then
					ApplyColor(Button, {['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
					ApplyColor(Button.Image, {['Main/Icons'] = {'ImageColor3', 'ImageTransparency'}})
				else
					ApplyColor(Button, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}, ['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
					ApplyColor(Button.Enabled, {['Main/EnabledBar'] = {'BackgroundColor3', 'BackgroundTransparency'}})
					ApplyColor(Button.Delete.Image, {['Main/Icons'] = {'ImageColor3', 'ImageTransparency'}})
					ApplyColor(Button.RenameTextBox, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}, ['Text/Placeholder'] = {'PlaceholderColor3'}})
				end
			end
		end
	elseif Option.Type == "Dropdown" then
		ApplyColor(Option.Object.Background, {['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Option.Object.Background.TextLabel, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}})
		ApplyColor(Option.Object.Background.TopBar.TextLabel, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}, ['Background/Secondary'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Option.Object.Background.TopBar.TextLabel.ScrollingFrame, {['Background/Secondary'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Option.Object.Background.TopBar.TextLabel.Arrow.Image, {['Main/Icons'] = {'ImageColor3', 'ImageTransparency'}})
		for _, Button in Option.Object.Background.TopBar.TextLabel.ScrollingFrame:GetChildren() do
			if Button:IsA("TextButton") then
				ApplyColor(Button, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}, ['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
			end
		end
	elseif Option.Type == "ColorPicker" then
		ApplyColor(Option.Object.Background, {['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Option.Object.Background.TextLabel, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}})
		ApplyColor(Option.Object.Background.RGBFrame, {['Background/Secondary'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Option.Object.Background.RGBFrame.RGBInput, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}, ['Text/Placeholder'] = {'PlaceholderColor3'}})
		ApplyColor(Option.Object.Background.ColorPickerDropdown, {['Background/Secondary'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		for _, Slider in Option.Object.Background.ColorPickerDropdown.Holder:GetChildren() do
			if Slider:IsA("Frame") then
				ApplyColor(Slider.Label, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}})
				ApplyColor(Slider.Input, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}, ['Text/Placeholder'] = {'PlaceholderColor3'}, ['Background/Button'] = {"BackgroundColor3", "BackgroundTransparency"}})
				ApplyColor(Slider.SliderFrame.LeftBar, {['Slider/LeftBar'] = {"BackgroundColor3", "BackgroundTransparency"}})
				ApplyColor(Slider.SliderFrame.RightBar, {['Slider/RightBar'] = {'BackgroundColor3', "BackgroundTransparency"}})
				ApplyColor(Slider.SliderFrame.LeftBar.Handle, {['Slider/Handle'] = {"BackgroundColor3", "BackgroundTransparency"}})
			end
		end
	end
end

local function ColorKeybind(KeybindObject)
	ApplyColor(KeybindObject.Delete, {['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
	ApplyColor(KeybindObject.Delete.Image, {['Main/Icons'] = {'ImageColor3', 'ImageTransparency'}})
	ApplyColor(KeybindObject.Background, {['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
	ApplyColor(KeybindObject.Background.KeybindName, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}})
	ApplyColor(KeybindObject.Background.BindButton, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}, ['Background/Secondary'] = {'BackgroundColor3', 'BackgroundTransparency'}})
	local Hold = KeybindObject.Background:FindFirstChild('Hold')
	if Hold then
		ApplyColor(Hold, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}, ['Background/Secondary'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		ApplyColor(Hold.Enabled, {['Main/EnabledBar'] = {'BackgroundColor3', 'BackgroundTransparency'}})
	end
end

function Gui:UpdateTheme()
    local CurrentTheme = GetCurrentTheme()
    if not CurrentTheme then return end
    ApplyColor(Tooltip, {['Text/Tooltip'] = {'TextColor3', 'TextTransparency'}, ['Background/Tooltip'] = {'BackgroundColor3', 'BackgroundTransparency'}})
    ApplyColor(TooltipUIStroke, {['Outline/Tooltip'] = {'Color', "Transparency"}})
    ApplyColor(GuiFolder.Done, {['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}, ['Text/Primary'] = {'TextColor3', 'TextTransparency'}})
	ApplyColor(TopBar, {['Background/Primary'] = {'BackgroundColor3', 'BackgroundTransparency'}})

    for _, Category in Gui.Categories do
        ApplyColor(Category.Object.Title, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}})
        ApplyColor(Category.Object.Arrow.Image, {['Main/Icons'] = {'ImageColor3', 'ImageTransparency'}})
        ApplyColor(Category.Object.ScrollingFrame, {['Background/Primary'] = {'BackgroundColor3', 'BackgroundTransparency'}})
        ApplyColor(Category.Object, {['Main/Accent'] = {'BackgroundColor3', 'BackgroundTransparency'}})
	end
    for _, Button in Gui.Buttons do
        ApplyColor(Button.Object, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}, ['Background/Button'] = {'BackgroundColor3', "BackgroundTransparency"}})
    end
    for _, Button in TopBar:GetChildren() do
        if Button:IsA("TextButton") then
            ApplyColor(Button, {[Button == Gui.SelectedTopBar and 'Background/ButtonHover' or 'Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}, ['Text/Primary'] = {'TextColor3', 'TextTransparency'}})
        elseif Button:IsA("TextBox") then
            ApplyColor(Button, {['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}, ['Text/Primary'] = {'TextColor3', 'TextTransparency'}, ['Text/Placeholder'] = {'PlaceholderColor3'}})
        end
    end
	for _, Module in Gui.Modules do
        ApplyColor(Module.Object, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}, ['Background/Button'] = {'BackgroundColor3', "BackgroundTransparency"}})
        ApplyColor(Module.Object.Enabled, {[Module.Enabled and 'Main/EnabledBar' or 'Main/DisabledBar'] = {'BackgroundColor3', 'BackgroundTransparency'}})
		for _, Option in Module.Options do
			ColorOption(Option)
		end
		for _, Keybind in Module.Keybinds do
			ColorKeybind(Keybind.Object)
		end
		ColorKeybind(Module.KeybindObject)
    end
    for _, Menu in Gui.Menus do
        ApplyColor(Menu.Object, {['Main/Accent'] = {'BackgroundColor3', 'BackgroundTransparency'}})
        ApplyColor(Menu.Object.Title, {['Text/Primary'] = {'TextColor3', 'TextTransparency'}})
        ApplyColor(Menu.Object.Close.Image, {['Main/Icons'] = {'ImageColor3', 'ImageTransparency'}})
        ApplyColor(Menu.Object.ScrollingFrame, {['Background/Primary'] = {'BackgroundColor3', 'BackgroundTransparency'}})
        for _, Option in Menu.Options do
            ColorOption(Option)
        end
        for _, Keybind in Menu.Keybinds do
			ColorKeybind(Keybind.Object)
        end
        for _, Button in Menu.Buttons do
            ApplyColor(Button.Object, {['Text/Primary'] = {'TextColor3', 'TextTransparency'},['Background/Button'] = {'BackgroundColor3', 'BackgroundTransparency'}})
        end
    end
end

local function UpdateTheme()
    Gui:UpdateTheme()
end

local ThemesDropdown

do
    function GuiMenu:CreateThemesDropdown(Properties)
        local Dropdown = {
			Value = Properties.List[1],
            List = Properties.List,
			Visible = if Properties.Visible ~= nil then Properties.Visible else true,
            Expanded = false,
            Type = "Dropdown"
		}

		local Frame = Instance.new("Frame")
		Frame.Name = `{Properties.Name}Dropdown`
		Frame.BackgroundTransparency = 1
		Frame.Size = UDim2.new(1, -100, 0, 40)
		Frame.LayoutOrder = table.len(GuiMenu.Options) + table.len(GuiMenu.Keybinds)
		Frame.Parent = GuiMenu.Object.ScrollingFrame

		local Background = Instance.new("Frame")
		Background.Name = "Background"
		Background.BackgroundColor3 = GetColor('Background/Button')
		Background.BorderSizePixel = 0
		Background.Size = UDim2.new(1, -45, 1, 0)
		Background.Parent = Frame
		AddCorner(Background, UDim.new(0, 7))

		local TextLabel = Instance.new("TextLabel")
		TextLabel.TextColor3 = GetColor('Text/Primary')
		TextLabel.BackgroundTransparency = 1
		TextLabel.Size = UDim2.new(0, 200, 1, 0)
		TextLabel.FontFace = GetFont('Regular')
		TextLabel.TextSize = 24
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.Text = ` {Properties.Name}`
		TextLabel.Parent = Background

		local TopBar = Instance.new("TextButton")
		TopBar.Name = "TopBar"
		TopBar.Size = UDim2.fromOffset(240, 40)
		TopBar.Position = UDim2.fromOffset(310, 0)
		TopBar.BackgroundTransparency = 1
		TopBar.BorderSizePixel = 0
		TopBar.Text = ""
		TopBar.AutoButtonColor = false
		TopBar.Parent = Background

		local TopBarLabel = Instance.new("TextLabel")
		TopBarLabel.Size = UDim2.new(1, 0, 0, 30)
		TopBarLabel.Position = UDim2.fromOffset(0, 5)
		TopBarLabel.BackgroundColor3 = GetColor('Background/Secondary')
		TopBarLabel.BorderSizePixel = 0
		TopBarLabel.Text = `   {Properties.List[1] or "None"}`
		TopBarLabel.TextSize = 24
		TopBarLabel.TextColor3 = GetColor('Text/Primary')
		TopBarLabel.FontFace = GetFont('Regular')
		TopBarLabel.TextXAlignment = Enum.TextXAlignment.Left
		TopBarLabel.Parent = TopBar

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 7)
        UICorner.Parent = TopBarLabel
        AddTooltip(TopBarLabel, Properties.Info or Properties.Tooltip)

		local Arrow = Instance.new("TextButton")
		Arrow.Name = "Arrow"
		Arrow.Size = UDim2.fromOffset(30, 30)
		Arrow.Position = UDim2.new(1, -30, 0, 0)
		Arrow.BackgroundTransparency = 1
		Arrow.Text = ""
		Arrow.Rotation = -90
		Arrow.Parent = TopBarLabel
		AddCorner(Arrow, UDim.new(0, 7))

		local ArrowImage = Instance.new("ImageLabel")
		ArrowImage.Name = "Image"
		ArrowImage.Size = UDim2.fromOffset(30, 30)
		ArrowImage.Position = UDim2.fromOffset(0, 0)
		ArrowImage.BackgroundTransparency = 1
		SetIcon(ArrowImage, "chevron-down")
		ArrowImage.Parent = Arrow

		local ResetButton = Instance.new("TextButton")
		ResetButton.Name = "Reset"
		ResetButton.BackgroundColor3 = GetColor('Background/Button')
		ResetButton.Text = ""
		ResetButton.BorderSizePixel = 0
		ResetButton.Size = UDim2.fromOffset(40, 40)
		ResetButton.Position = UDim2.new(1, -40, 0, 0)
		ResetButton.AutoButtonColor = false
		ResetButton.Parent = Frame
		AddCorner(ResetButton, UDim.new(0, 7))
		AddHighlight(ResetButton)

		local ResetButtonImage = Instance.new("ImageLabel")
		ResetButtonImage.Name = "Image"
		ResetButtonImage.BackgroundTransparency = 1
		ResetButtonImage.Size = UDim2.fromOffset(24, 24)
		ResetButtonImage.Position = UDim2.fromOffset(8, 8)
		SetIcon(ResetButtonImage, "rotate-cw")
		ResetButtonImage.Parent = ResetButton

		local ScrollingFrame = Instance.new("ScrollingFrame")
		ScrollingFrame.Size = UDim2.fromScale(1, 0)
		ScrollingFrame.Position = UDim2.fromScale(0, 1)
		ScrollingFrame.BackgroundColor3 = GetColor('Background/Secondary')
		ScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
		ScrollingFrame.ScrollBarThickness = 0
		ScrollingFrame.ScrollBarImageTransparency = 1
		ScrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		ScrollingFrame.Visible = false
		ScrollingFrame.ZIndex = 2
		ScrollingFrame.Parent = TopBarLabel

        local ScrollingFrameUICorner = Instance.new("UICorner")
        ScrollingFrameUICorner.CornerRadius = UDim.new(0, 0)
        ScrollingFrameUICorner.BottomLeftRadius = UDim.new(0, 7)
        ScrollingFrameUICorner.BottomRightRadius = UDim.new(0, 7)
        ScrollingFrameUICorner.Parent = ScrollingFrame

		local Padding = Instance.new("UIPadding")
		Padding.PaddingTop = UDim.new(0, 10)
		Padding.PaddingBottom = UDim.new(0, 10)
		Padding.Parent = ScrollingFrame

		local Layout = Instance.new("UIListLayout")
		Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		Layout.Padding = UDim.new(0, 5)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Parent = ScrollingFrame

		local function GetHeight()
			return (Layout.AbsoluteContentSize.Y + 12) / UIScale.Scale
		end

		Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetHeight())
		end)
		ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetHeight())

		local Info = TweenInfo.new(0.2)
		local Tween, ArrowTween
		local CreatedButtons = {}

		function Dropdown:SetValue(Val)
			Dropdown.Value = Val
			TopBarLabel.Text = `   {Val}`
			if Properties.Function then
				Properties.Function(Val)
			end
		end

        function Dropdown:Remove(Value)
            local Index = table.find(Dropdown.List, Value)
            if Index then
                table.remove(Dropdown.List, Index)
            end
        end

        function Dropdown:Add(Value)
            if not table.find(Dropdown.List, Value) then
				self.List[#self.List + 1] = Value
            end
        end

        local PlusButton = Instance.new("TextButton")
        PlusButton.Name = "Plus"
        PlusButton.BackgroundColor3 = GetColor('Background/Button')
        PlusButton.Text = ""
        PlusButton.BorderSizePixel = 0
        PlusButton.Size = UDim2.fromOffset(32, 32)
        PlusButton.AutoButtonColor = false
        PlusButton.LayoutOrder = 69420
        PlusButton.ZIndex = 2
        PlusButton.Parent = ScrollingFrame
        AddCorner(PlusButton, UDim.new(0, 7))
        AddHighlight(PlusButton)

        local PlusImage = Instance.new("ImageLabel")
        PlusImage.Name = "Image"
        PlusImage.BackgroundTransparency = 1
        PlusImage.Size = UDim2.fromOffset(24, 24)
        PlusImage.Position = UDim2.fromOffset(4, 4)
        PlusImage.ZIndex = 2
        SetIcon(PlusImage, "plus")
        PlusImage.Parent = PlusButton

        PlusButton.MouseButton1Click:Connect(function()
            Dropdown:CreateButton({
                Name = "new theme",
				New = true,
                CanDelete = true,
                LayoutOrder = #CreatedButtons + 1,
            })
        end)

        function Dropdown:CreateButton(Properties)
            local Button = Instance.new("TextButton")
			Button.Size = UDim2.fromOffset(220, 30)
			Button.BackgroundColor3 = GetColor('Background/Button')
			Button.TextColor3 = GetColor('Text/Primary')
			Button.FontFace = GetFont('Regular')
			Button.TextSize = 20
			Button.Text = `  {Properties.Name}`
			Button.LayoutOrder = Properties.LayoutOrder or 0
			Button.ZIndex = 2
			Button.BorderSizePixel = 0
			Button.AutoButtonColor = false
			Button.TextXAlignment = Enum.TextXAlignment.Left
			Button.Parent = ScrollingFrame
			AddCorner(Button, UDim.new(0, 7))
            AddHighlight(Button)
            AddTooltip(Button, Properties.CanDelete and "Left Click to select.\nRight Click to rename." or "Left Click to select.")

            if Properties.CanDelete then
                local Delete = Instance.new("TextButton")
                Delete.Name = "Delete"
                Delete.BackgroundTransparency = 1
                Delete.Size = UDim2.fromOffset(30, 30)
                Delete.Position = UDim2.new(1, -30, 0, 0)
                Delete.ZIndex = 2
				Delete.Text = ''
                Delete.Parent = Button

				local Image = Instance.new('ImageLabel')
				Image.Name = 'Image'
				Image.BackgroundTransparency = 1
				Image.Size = UDim2.fromOffset(24, 24)
				Image.Position = UDim2.fromOffset(3, 3)
				Image.ZIndex = 2
				SetIcon(Image, 'x')
				Image.Parent = Delete

                Delete.MouseButton1Click:Connect(function()
                    Tooltip.Visible = false
                    Dropdown:Remove(Properties.Name)
                    local Index = table.find(CreatedButtons, Button)
                    if Index then
                        table.remove(CreatedButtons, Index)
                    end
                    Button:Destroy()
                    Gui.Themes[Properties.Name] = nil
                    Dropdown:SetValue("TidalWave")
                end)

                local RenameTextBox = Instance.new("TextBox")
                RenameTextBox.Name = "Rename"
                RenameTextBox.BackgroundTransparency = 1
                RenameTextBox.Size = UDim2.fromOffset(220, 30)
                RenameTextBox.Position = UDim2.fromOffset(10, 0)
                RenameTextBox.TextSize = 20
                RenameTextBox.TextColor3 = GetColor('Text/Primary')
                RenameTextBox.FontFace = GetFont('Regular')
                RenameTextBox.ClearTextOnFocus = false
                RenameTextBox.TextXAlignment = Enum.TextXAlignment.Left
                RenameTextBox.Visible = false
                RenameTextBox.ZIndex = 2
                RenameTextBox.Parent = Button

                local function Select()
                    Button.TextTransparency = 1
                    RenameTextBox.Text = Properties.Name
                    RenameTextBox.Visible = true
                    RenameTextBox:CaptureFocus()
                    RenameTextBox.SelectionStart = 0
                    RenameTextBox.CursorPosition = #RenameTextBox.Text + 1
                    RenameTextBox.FocusLost:Once(function()
                        local OldName, NewName = Properties.Name, RenameTextBox.Text
                        Dropdown:Remove(OldName)
                        Dropdown:Add(NewName)
                        Dropdown:SetValue(NewName)
                        RenameTextBox.Visible = false
                        Button.Text = `  {NewName}`
                        Button.TextTransparency = 0
                        Properties.Name = NewName
                    end)
                end

                if Properties.New then
                    Select()
                else
                    Dropdown:Add(Properties.Name)
                end

                Button.MouseButton2Click:Connect(Select)
            end

			Button.MouseButton1Click:Connect(function()
				Dropdown:SetValue(Properties.Name)
			end)

			CreatedButtons[#CreatedButtons + 1] = Button
        end

		function Dropdown:Expand()
			Dropdown.Expanded = not Dropdown.Expanded
			if Tween then
				Tween:Cancel()
			end
			if ArrowTween then
				ArrowTween:Cancel()
			end
			Tween = TweenService:Create(ScrollingFrame, Info, {Size = UDim2.new(1, 0, 0, Dropdown.Expanded and 240 or 0)})
			ArrowTween = TweenService:Create(Arrow, Info, {Rotation = Dropdown.Expanded and 0 or -90})
			if Dropdown.Expanded then
				if #CreatedButtons == 0 then
					for i, v in Dropdown.List do
                        Dropdown:CreateButton({
                            Name = v,
                            CanDelete = not BuiltInThemes[v],
                            LayoutOrder = i,
                        })
					end
				end
				ScrollingFrame.Visible = true
                UICorner.CornerRadius = UDim.new(0, 0)
                UICorner.TopLeftRadius = UDim.new(0, 7)
                UICorner.TopRightRadius = UDim.new(0, 7)
			else
				Tween.Completed:Once(function(State)
					if State == Enum.PlaybackState.Completed then
                        UICorner.CornerRadius = UDim.new(0, 7)
						ScrollingFrame.Visible = false
						for _, v in CreatedButtons do
							v:Destroy()
						end
						table.clear(CreatedButtons)
					end
				end)
			end
			Tween:Play()
			ArrowTween:Play()
		end

		local Name = Properties.Name:gsub(' ', '')

		function Dropdown:Save(Tab)
			Tab[Name] = {
				List = self.List,
				Value = self.Value
			}
		end

		function Dropdown:Load(Tab)
			self.List = Tab.List
			self:SetValue(Tab.Value)
			if self.Expanded then
				for _, v in CreatedButtons do
					v:Destroy()
				end
				table.clear(CreatedButtons)
				for i, v in Dropdown.List do
					Dropdown:CreateButton({
						Name = v,
						CanDelete = not BuiltInThemes[v],
						LayoutOrder = i,
					})
				end
			end
		end

		function Dropdown:SetVisible(Visible)
			Dropdown.Visible = Visible
			Frame.Visible = Dropdown.Visible
		end

		Arrow.MouseButton1Click:Connect(Dropdown.Expand)
		Arrow.MouseButton2Click:Connect(Dropdown.Expand)
		TopBar.MouseButton1Click:Connect(Dropdown.Expand)
		TopBar.MouseButton2Click:Connect(Dropdown.Expand)

		ResetButton.MouseButton1Click:Connect(function()
			Dropdown:SetValue("TidalWave")
		end)

		Dropdown.Object = Frame

		GuiMenu.Options[Name] = Dropdown

		return Dropdown
    end

    local ColorPickers = {}

    ThemesDropdown = GuiMenu:CreateThemesDropdown({
        Name = "Theme",
        List = {"TidalWave"},
        Function = function(Value)
            if not Gui.Themes[Value] then
				local NewTheme = table.clone(BuiltInThemes.TidalWave)
				NewTheme.BuiltIn = nil
				Gui.Themes[Value] = NewTheme
            end
            Gui.Theme = Value
            UpdateTheme()
            for _, v in ColorPickers do
                v:SetVisible(not BuiltInThemes[Value])
            end
        end
    })

    for i, v in BuiltInThemes.TidalWave do
        if i == "BuiltIn" then continue end
        for i2, v2 in v do
			ColorPickers[#ColorPickers + 1] = GuiMenu:CreateColorPicker({
                Name = i == "Main" and i2 or `{i} {i2}`,
                Default = v2.Color,
				Transparency = v2.Transparency,
                Visible = false,
                Function = function(Color, Transparency)
                    SetColor(`{i}/{i2}`, Color, Transparency)
                    UpdateTheme()
                end
            })
        end
    end
end

Run(function()
    local List = {}
    if IsStudio then
        for _, v in script.Parent:GetChildren() do
            table.insert(List, v.Name)
        end
    else
        for _, v in listfiles("TidalWave/Guis") do
            table.insert(List, v:gsub("\\", "/"):split("/")[3]:split(".")[1])
        end
    end
    
	local CurrentGui = readfile and readfile("TidalWave/Profiles/Gui.txt") or "TidalWave"

	table.sort(List, function(a)
		return a == CurrentGui
	end)

	GuiMenu:CreateDropdown({
		Name = "Gui",
		List = List,
		Function = function(Val)
			if writefile then
				writefile("TidalWave/Profiles/Gui.txt", Val)
				ReloadButton:Toggle()
			end
		end
	})
end)

local HudMenu = Gui:CreateMenu({
	Name = "HUD",
})

HudMenu:CreateToggle({
	Name = "Allow Dragging Off Screen"
})

Run(function()
    local TooltipOptions = HudMenu:CreateOption({
        Name = "Tooltip",
        Default = true,
        Function = function(Enabled)
            Gui.Tooltip = Enabled
            if Tooltip.Visible and not Enabled then
                Tooltip.Visible = false
            end
        end
    })

    TooltipOptions:CreateSlider({
        Name = "Text Size",
        Default = 16,
        Min = 8,
        Max = 24,
        Function = function(Val)
            Tooltip.TextSize = Val
        end
    })
end)

DoneButton = Instance.new("TextButton")
DoneButton.Name = "Done"
DoneButton.Size = UDim2.fromOffset(200, 50)
DoneButton.Position = UDim2.fromScale(0.5, 1)
DoneButton.AnchorPoint = Vector2.new(0.5, 1)
DoneButton.BackgroundColor3 = GetColor('Background/Button')
DoneButton.BorderSizePixel = 0
DoneButton.Text = "Done"
DoneButton.TextColor3 = GetColor('Text/Primary')
DoneButton.TextSize = 36
DoneButton.FontFace = GetFont('Regular')
DoneButton.Visible = false
DoneButton.Parent = GuiFolder

local StopEditingHudPositions
local StartEditingHudPositions

Run(function()
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 0)
    Corner.TopLeftRadius = UDim.new(0, 7)
    Corner.TopRightRadius = UDim.new(0, 7)
    Corner.Parent = DoneButton

    local Objects = {}
	local PrevInvisibleObjects = {}
	local PrevNonInteractableObjects = {}
	local EditingPositions = false
	local Con

	StopEditingHudPositions = function()
		if not EditingPositions then return end
		EditingPositions = false
		if Con then
			Con:Disconnect()
			Con = nil
		end
		for _, v in PrevInvisibleObjects do
			v.Visible = false
		end
		for _, v in PrevNonInteractableObjects do
			v.Interactable = false
		end
		for _, v in Objects do
			v:Destroy()
		end
		table.clear(Objects)
		table.clear(PrevInvisibleObjects)
		DoneButton.Visible = false
		HudMenu.Object.Visible = true
	end
	StartEditingHudPositions = function()
		if not HudMenu.Object.Visible then return end
		EditingPositions = true
		HudMenu.Object.Visible = false
		for _, v in HudFolder:GetChildren() do
			if v:IsA("GuiObject") then
				if not v.Visible then
					table.insert(PrevInvisibleObjects, v)
					v.Visible = true
				end
				if not v.Interactable then
					table.insert(PrevNonInteractableObjects, v)
					v.Interactable = true
				end
				local DragDetector = Instance.new("UIDragDetector")
				DragDetector.CursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
				DragDetector.ActivatedCursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png"
				if not HudMenu.Options.AllowDraggingOffScreen.Enabled then
					DragDetector.BoundingUI = HudFolder
					DragDetector.BoundingBehavior = Enum.UIDragDetectorBoundingBehavior.EntireObject
				end
				DragDetector.Parent = v
				local UIStroke = Instance.new("UIStroke")
				UIStroke.Color = Color3.White
				UIStroke.Thickness = 2
				UIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
				UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke.LineJoinMode = Enum.LineJoinMode.Miter
				UIStroke.Parent = v
				table.insert(Objects, DragDetector)
				table.insert(Objects, UIStroke)
			end
		end
		DoneButton.Visible = true
		Con = DoneButton.MouseButton1Click:Once(StopEditingHudPositions)
	end
end)

HudMenu:CreateButton({
	Name = "Edit Positions",
	Function = StartEditingHudPositions
})

Run(function()
    local Notifications = HudMenu:CreateOption({
		Name = "Notifications",
		Default = true,
        Function = function(Enabled)
            Gui.Notifications = Enabled
        end
	})

	Notifications:CreateDropdown({
		Name = "Horizontal Alignment",
		List = {"Right", "Left"},
        Function = function(Val)
            Gui.NotificationHorizontalAlignment = Val
        end
	})

	Notifications:CreateDropdown({
		Name = "Vertical Alignment",
		List = {"Bottom", "Top"},
        Function = function(Val)
            Gui.NotificationVerticalAlignment = Val
        end
	})

	Notifications:CreateDropdown({
		Name = "Fill Direction",
		List = {"Up", "Down"},
        Function = function(Val)
            Gui.NotificationFillDirection = Val
        end
	})

	Notifications:CreateSlider({
		Name = 'Module Toggled Duration',
		Default = 2,
		Min = 0.5,
		Max = 4,
		Decimal = 100
	})
end)

Run(function()
    local ModuleListEnabled, RGBText, RGBSpeed, RGBSpread, RGBDirection, RGBBackground, RGBBar, RGBBackgroundSaturation, RGBBackgroundValue, RGBTextSaturation, RGBTextValue, RGBBarSaturation, RGBBarValue

	local Tab = {}

	ModuleListEnabled = HudMenu:CreateOption({
		Name = "Module List",
		Info = "Shows a list of all your currently enabled modules",
		Default = true,
		Function = function(Enabled)
			ModuleList:Enable(Enabled)
		end
	})

	ModuleListEnabled:CreateTextBox({
		Name = 'Text',
		Text = `<font color = 'rgb(255, 215, 0)'>Tidal</font> <font color = 'rgb(20, 135, 255)'>Wave</font> v{Gui.CurrentVersion}`,
		Placeholder = '[cool watermark text whatever]',
		Function = function(Text)
			ModuleList:SetWatermarkText(Text)
		end
	})

	ModuleListEnabled:CreateButton({
		Name = 'Reset Text',
		Info = 'Changes the text back to default.',
		Function = function()
			ModuleList:SetWatermarkText(`<font color = 'rgb(255, 215, 0)'>Tidal</font> <font color = 'rgb(20, 135, 255)'>Wave</font> v{Gui.CurrentVersion}`)
		end
	})

	ModuleListEnabled:CreateSlider({
		Name = 'Scale',
		Default = 1,
		Min = 0.6,
		Max = 2,
		Decimal = 100,
		Function = function(Val)
			ModuleList:SetScale(Val)
		end
	})

	ModuleListEnabled:CreateDropdown({
		Name = "Sorting",
		Info = "Length - Sorts the modules from biggest to smallest\nAlphabetical - Sorts the modules from a-z",
		List = {"Length", "Alphabetical"},
		Function = function(Val)
			ModuleList:SetSortingMethod(Val)
		end
	})

	ModuleListEnabled:CreateDropdown({
		Name = "Alignment",
		Info = "Right - Aligns the modules to the right\nLeft - Alings the modules to the left",
		List = {"Right", "Left"},
		Function = function(Val)
			ModuleList:SetAlignment(Val)
		end
	})

	ModuleListEnabled:CreateSlider({
		Name = "Padding",
		Default = 0,
		Min = 0,
		Max = 5,
		Function = function(Val)
			ModuleList:SetPadding(Val)
		end
	})

	ModuleListEnabled:CreateToggle({
		Name = "Background Enabled",
		Default = true,
		Function = function(Enabled)
			ModuleList:SetBackgroundEnabled(Enabled)
		end
	})

	ModuleListEnabled:CreateColorPicker({
		Name = "Background Color",
		Default = Color3.fromRGB(0, 0, 0),
		DefaultTransparency = 0.5,
		Function = function(Color)
			ModuleList:SetBackgroundColor(Color)
		end,
	})

	ModuleListEnabled:CreateToggle({
		Name = "Bar Enabled",
		Info = "Toggles the visibility of the bar on the modules",
		Default = true,
		Function = function(Enabled)
			ModuleList:SetBarEnabled(Enabled)
		end
	})

	ModuleListEnabled:CreateColorPicker({
		Name = "Bar Color",
		Default = ModuleList.BarColor,
		Function = function(Color)
			ModuleList:SetBarColor(Color)
		end
	})

	ModuleListEnabled:CreateToggle({
		Name = "Watermark Text Shadow",
		Info = "Whether or not to show a text shadow on the watermark",
		Default = true,
		Function = function(Enabled)
			ModuleList:SetWatermarkTextShadowEnabled(Enabled)
		end
	})

	ModuleListEnabled:CreateColorPicker({
		Name = "Watermark Text Color",
        Default = GetColor('Text/Primary'),
		Function = function(Color)
			ModuleList:SetWatermarkTextColor(Color)
		end
	})

	ModuleListEnabled:CreateColorPicker({
		Name = "Text Color",
		Default = GetColor('Text/Primary'),
		Function = function(Color)
			ModuleList:SetTextColor(Color)
		end
	})

	RGBText = ModuleListEnabled:CreateToggle({
		Name = "RGB Text",
		Info = "Makes the text of the modules RGB :D",
		Function = function(Enabled)
			ModuleList:SetRainbowTextEnabled(Enabled)
            for i, v in Tab do
                v:SetVisible(true)
            end
		end
	})

	RGBSpeed = ModuleListEnabled:CreateSlider({
		Name = "RGB Speed",
		Default = 1,
		Min = 0.01,
		Max = 3,
		Decimal = 100,
		Visible = false,
		Function = function(Val)
			ModuleList:SetRainbowSpeed(Val)
		end
	})

	RGBSpread = ModuleListEnabled:CreateSlider({
		Name = "RGB Spread",
		Default = 1,
		Min = 0.01,
		Max = 3,
		Decimal = 100,
		Visible = false,
		Function = function(Val)
			ModuleList:SetRainbowSpread(Val)
		end
	})

	RGBDirection = ModuleListEnabled:CreateDropdown({
		Name = "RGB Direction",
		Info = "Down - The RGB effect goes down\nUp - The RGB effect goes up",
		List = {"Down", "Up"},
		Visible = false,
		Function = function(Val)
			ModuleList:SetRainbowDirection(Val)
		end
	})

	RGBBackground = ModuleListEnabled:CreateToggle({
		Name = "RGB Background",
		Info = "Whether or not to make the background of modules RGB",
		Visible = false,
		Function = function(Enabled)
			ModuleList:SetRainbowBackgroundEnabled(Enabled)
		end
	})

	RGBBar = ModuleListEnabled:CreateToggle({
		Name = "RGB Bar",
		Info = "Whether or not to make the bar of the modules RGB",
		Visible = false,
		Function = function(Enabled)
			ModuleList:SetRainbowBarEnabled(Enabled)
		end
	})

	RGBBackgroundSaturation = ModuleListEnabled:CreateSlider({
		Name = "Background Sat",
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Visible = false,
		Function = function(Val)
			ModuleList:SetBackgroundRainbowSaturation(Val)
		end
	})

	RGBBackgroundValue = ModuleListEnabled:CreateSlider({
		Name = "Background Val",
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Visible = false,
		Function = function(Val)
			ModuleList:SetBackgroundRainbowValue(Val)
		end
	})

	RGBTextSaturation = ModuleListEnabled:CreateSlider({
		Name = "Text Saturation",
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Visible = false,
		Function = function(Val)
			ModuleList:SetRainbowSaturation(Val)
		end
	})

	RGBTextValue = ModuleListEnabled:CreateSlider({
		Name = "Text Value",
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Visible = false,
		Function = function(Val)
			ModuleList:SetRainbowValue(Val)
		end
	})

	RGBBarSaturation = ModuleListEnabled:CreateSlider({
		Name = "Bar Saturation",
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Visible = false,
		Function = function(Val)
			ModuleList:SetBarRainbowSaturation(Val)
		end
	})

	RGBBarValue = ModuleListEnabled:CreateSlider({
		Name = "Bar Value",
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Visible = false,
		Function = function(Val)
			ModuleList:SetBarRainbowValue(Val)
		end
	})

    Tab = {RGBText, RGBSpeed, RGBSpread, RGBDirection, RGBBackground, RGBBar, RGBBackgroundSaturation, RGBBackgroundValue, RGBTextSaturation, RGBTextValue, RGBBarSaturation, RGBBarValue}
end)

local ProfilesMenu = Gui:CreateMenu({
	Name = "Profiles",
})

local function HideMenus(Exclusion, Visible)
	for i, v in Gui.Menus do
        if i == Exclusion then
            Exclusion = nil
            v.Object.Visible = true
            PrevMenu = i
        else
            v.Object.Visible = false
        end
	end
	CategoryHolder.Visible = if Visible ~= nil then Visible else false
end

ModulesTopBar = CreateTopBarButton({
	Name = "Modules",
	Function = function(Visible)
		HideMenus("Modules", if Visible ~= nil then Visible else true)
	end,
})
ModulesTopBar:Select(false)
Gui.SelectedTopBar = ModulesTopBar.Object

local ConfigTopBar = CreateTopBarButton({
	Name = "Config",
	Function = function()
		ConfigMenu:ShowOptions()
		HideMenus("Config")
		StopEditingHudPositions()
	end,
})

local GuiTopBar = CreateTopBarButton({
	Name = "GUI",
	Function = function()
		GuiMenu:ShowOptions()
		HideMenus("GUI")
		StopEditingHudPositions()
	end,
})

local HudTopBar = CreateTopBarButton({
	Name = "HUD",
	Function = function()
		HudMenu:ShowOptions()
		HideMenus("HUD")
		StopEditingHudPositions()
	end,
})

function Gui:LoadOptions(Options, JsonOptions)
	for i, v in JsonOptions do
		local Option = Options[i]
		if Option and Option.Load then
			Option:Load(v)
		end
	end
end

local function LoadThemes(JSON)
    if not JSON.Themes then return table.clone(BuiltInThemes) end
    local NewThemes = {}

    for ThemeName, Theme in JSON.Themes do
        NewThemes[ThemeName] = {}
        for CategoryName, Category in Theme do
            NewThemes[ThemeName][CategoryName] = {}
            for ColorName, Color in Category do
                NewThemes[ThemeName][CategoryName][ColorName] = Color3.fromRGBT(Color.R, Color.G, Color.B, Color.T)
            end
        end
    end

    return NewThemes
end

local function TableToUDim2(Tab)
    return UDim2.new(Tab.X.Scale, Tab.X.Offset, Tab.Y.Scale, Tab.Y.Offset)
end

function Gui:Load(Profile)
	if not readfile then return end

	local Config

    if isfile and isfile(`TidalWave/Profiles/Gui{game.GameId}.json`) then
        Config = HttpService:JSONDecode(readfile(`TidalWave/Profiles/Gui{game.GameId}.json`))
    else
        Config = {
            Scale = true,
            Profile = "Default",
            Profiles = {"Default"},
            Theme = Gui.Theme,
            Menus = {},
            HudLocations = {},
            Categories = {}
        }
    end

	if Gui.Scale ~= (Config.Scale or false) then
		Gui.Scale = Config.Scale
		UIScale.Scale = Gui.Scale and UIScale.Scale or 1
	end

	Gui.Profile = Profile or Config.Profile or "Default"
	Gui.Profiles = Config.Profiles or {"Default"}
    Gui.Friends = Config.Friends or {}
    Gui.Theme = Config.Theme or "TidalWave"
    Gui.Themes = LoadThemes(Config)

    local Index = 0

    for i, v in Gui.Themes do
        Index += 1
        if not v.BuiltIn then
            if ThemesDropdown.Expanded then
                ThemesDropdown:CreateButton({
                    Name = i,
                    LayoutOrder = Index,
                    CanDelete = true
                })
            else
                ThemesDropdown:Add(i)
            end
        end
    end

    ThemesDropdown:SetValue(Gui.Theme)

    for i, v in Config.Menus do
        if typeof(v) ~= "table" then continue end
        local Menu = Gui.Menus[i]
        if not Menu then continue end

        for i2, v2 in v.Options do
            if i2 == "Gui" then continue end
            local Option = Menu.Options[i2]
            if not Option then continue end
            if typeof(v2) == "table" and v2.Options and Option.Options then
                Gui:LoadOptions(Option, v2.Options)
                if Option.Enabled ~= v2.Enabled then
                    Option:Toggle()
                end
            else
                Option:Load(v2)
            end
        end
        for i2, v2 in v.Keybinds do
            local Keybind = Menu.Keybinds[i2]
            if not Keybind then continue end
            Keybind:Load(v2)
        end
    end

    for i, v in Config.HudLocations do
        local HudObject = HudFolder:FindFirstChild(i)
        if HudObject then
            HudObject.Position = TableToUDim2(v)
        end
    end

    for i, v in Config.Categories do
        local Category = Gui.Categories[i]
        if Category then
			local Position = TableToUDim2(v.Location)
            Category:SetOpenedPosition(Position)
            if Category.Expanded ~= v.Expanded then
                Category:Expand(true)
            end
        end
    end

	if isfile and isfile(`TidalWave/Profiles/{Gui.Profile}{game.PlaceId}.json`) then
		local Settings = HttpService:JSONDecode(readfile(`TidalWave/Profiles/{Gui.Profile}{game.PlaceId}.json`))

		Notify({
			Text = `Loaded profile {Gui.Profile} for '{Gui.PlaceName}'`,
			Duration = 5
		})

		for i, v in Settings.Modules do
			local Module = Gui.Modules[i]
			if not Module then continue end
			if Module.Options and v.Options then
				Gui:LoadOptions(Module.Options, v.Options)
			end
            if Module.Keybinds and v.Keybinds then
                Gui:LoadOptions(Module.Keybinds, v.Keybinds)
            end
            if Module.Keybind ~= v.Keybind and typeof(v.Keybind) == 'string' then
                Module:SetKeybind(v.Keybind)
            end
			if Module.Hold ~= v.Hold and typeof(v.Hold) == 'boolean' then
				Module:ToggleHold()
			end
			if Module.Enabled ~= v.Enabled then
				Module:Toggle(true)
			end
		end
        for i, v in Settings.Buttons do
            local Button = Gui.Buttons[i]
            if not Button then return end
            if Button.Options and v.Options then
                Gui:LoadOptions(Button, v.Options)
            end
            Button:SetKeybind(v.Keybind)
        end
	end
end

function Gui:SaveOptions(Options)
	if not Options then return end
	local Tab = {}
	for _, v in Options do
		if not v.Save then continue end
		v:Save(Tab)
	end
	return Tab
end

local function SaveThemes()
    local Tab = {}
    for i, v in Gui.Themes do
		if v.BuiltIn then continue end
        Tab[i] = {}
        for i2, v2 in v do
            Tab[i][i2] = {}
            for i3, v3 in v2 do
                Tab[i][i2][i3] = {
                    R = v3.R,
                    G = v3.G,
                    B = v3.B,
                    T = v3.T
                }
            end
        end
    end

    return Tab
end

local function UDim2ToTable(Pos)
    return {
        X = {
            Scale = Pos.X.Scale,
            Offset = Pos.X.Offset
        },
        Y = {
            Scale = Pos.Y.Scale,
            Offset = Pos.Y.Offset
        }
    }
end

function Gui:Save(Profile)
	if not writefile then return end

	local Config = {
		Scale = Gui.Scale,
		Profile = Profile or Gui.Profile or "Default",
		Profiles = Gui.Profiles or {'Default'},
        Friends = Gui.Friends or {},
        Fonts = {
            Regular = Gui.Fonts.Regular.Name,
            SemiBold = Gui.Fonts.SemiBold.Name,
            Bold = Gui.Fonts.Bold.Name
        },
        Themes = SaveThemes(),
        Theme = Gui.Theme or 'TidalWave',
        Menus = {},
        HudLocations = {},
        Categories = {}
	}

	for i, v in Gui.Menus do
		if i == "Options" or i == "MenuOptions" or i == "Profiles" then continue end
        Config.Menus[i] = {
            Options = {},
            Keybinds = {}
        }
        for i2, v2 in v.Options do
            if v2.Options then
                Config.Menus[i].Options[i2] = {
                    Enabled = v2.Enabled,
                    Options = Gui:SaveOptions(v2.Options)
                }
            else
                v2:Save(Config.Menus[i].Options)
            end
        end
        for _, v2 in v.Keybinds do
            v2:Save(Config.Menus[i].Keybinds)
        end
	end

    for _, v in HudFolder:GetChildren() do
        Config.HudLocations[v.Name] = UDim2ToTable(v.Position)
    end

    for Name, Category in Gui.Categories do
        Config.Categories[Name] = {
            Location = UDim2ToTable(Category.OpenedPosition),
            Expanded = Category.Expanded
        }
    end

	local Settings = {
		Modules = {},
        Buttons = {}
	}

	for i, v in Gui.Modules do
		Settings.Modules[i] = {
			Enabled = v.Enabled,
			Keybind = v.Keybind,
			Hold = v.Hold,
			Options = Gui:SaveOptions(v.Options),
            Keybinds = Gui:SaveOptions(v.Keybinds),
		}
	end

    for i, v in Gui.Buttons do
        Settings.Buttons[i] = {
            Keybind = v.Keybind,
            Options = Gui:SaveOptions(v.Options),
            Keybinds = Gui:SaveOptions(v.Keybinds)
        }
    end

	writefile(`TidalWave/Profiles/Gui{game.GameId}.json`, HttpService:JSONEncode(Config))
	writefile(`TidalWave/Profiles/{Config.Profile}{game.PlaceId}.json`, HttpService:JSONEncode(Settings))
end

function ProfilesMenu:CreateProfileButton(Properties)
	local Frame = Instance.new("Frame")
	Frame.Name = `{Properties.Name}Button`
	Frame.BackgroundTransparency = 1
	Frame.Size = UDim2.new(1, -100, 0, 40)
	Frame.LayoutOrder = Properties.LayoutOrder or table.len(ProfilesMenu.Options)
	Frame.Parent = ProfilesMenu.Object.ScrollingFrame

	local Background = Instance.new("Frame")
	Background.BackgroundColor3 = GetColor('Background/Button')
	Background.Size = UDim2.new(1, -45, 0, 40)
	Background.BorderSizePixel = 0
	Background.Parent = Frame
	AddCorner(Background, UDim.new(0, 7))

	local NameLabel = Instance.new("TextButton")
	NameLabel.BackgroundTransparency = 1
	NameLabel.Size = UDim2.fromOffset(400, 40)
	NameLabel.Position = UDim2.fromOffset(5, 0)
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	NameLabel.Text = Properties.Name
	NameLabel.TextSize = 24
	NameLabel.TextColor3 = GetColor('Text/Primary')
	NameLabel.FontFace = GetFont('Regular')
	NameLabel.AutoButtonColor = false
	NameLabel.Parent = Background

	local RenameTextBox = Instance.new("TextBox")
	RenameTextBox.Name = "Rename"
	RenameTextBox.BackgroundTransparency = 1
	RenameTextBox.Size = UDim2.fromOffset(200, 40)
	RenameTextBox.TextSize = 24
	RenameTextBox.TextColor3 = GetColor('Text/Primary')
	RenameTextBox.FontFace = GetFont('Regular')
	RenameTextBox.ClearTextOnFocus = false
	RenameTextBox.TextXAlignment = Enum.TextXAlignment.Left
	RenameTextBox.Visible = false
	RenameTextBox.Parent = NameLabel

	local DeleteButton = Instance.new("TextButton")
	DeleteButton.Name = "Delete"
	DeleteButton.BackgroundColor3 = GetColor('Background/Button')
	DeleteButton.Text = ""
	DeleteButton.BorderSizePixel = 0
	DeleteButton.Size = UDim2.fromOffset(40, 40)
	DeleteButton.Position = UDim2.new(1, -40, 0, 0)
	DeleteButton.AutoButtonColor = false
	DeleteButton.Parent = Frame
	AddCorner(DeleteButton, UDim.new(0, 7))
	AddHighlight(DeleteButton)
	AddTooltip(DeleteButton, "Click to delete the profile")

	local DeleteButtonImage = Instance.new("ImageLabel")
	DeleteButtonImage.Name = "Image"
	DeleteButtonImage.BackgroundTransparency = 1
	DeleteButtonImage.Size = UDim2.fromOffset(24, 24)
	DeleteButtonImage.Position = UDim2.fromOffset(8, 8)
	SetIcon(DeleteButtonImage, "x")
	DeleteButtonImage.Parent = DeleteButton

	local Load = Instance.new("TextButton")
	Load.Name = "Load"
	Load.BackgroundColor3 = GetColor('Background/Secondary')
	Load.Text = "Load"
	Load.BorderSizePixel = 0
	Load.Size = UDim2.fromOffset(100, 30)
	Load.Position = UDim2.new(1, -105, 0, 5)
	Load.TextColor3 = GetColor('Text/Primary')
	Load.TextSize = 24
	Load.FontFace = GetFont('Regular')
	Load.AutoButtonColor = false
	Load.Parent = Background
	AddCorner(Load, UDim.new(0, 7))
	AddHighlight(Load, true)

	local Save = Instance.new("TextButton")
	Save.Name = "Save"
	Save.BackgroundColor3 = GetColor('Background/Secondary')
	Save.Text = "Save"
	Save.BorderSizePixel = 0
	Save.Size = UDim2.fromOffset(100, 30)
	Save.Position = UDim2.new(1, -210, 0, 5)
	Save.TextColor3 = GetColor('Text/Primary')
	Save.TextSize = 24
	Save.FontFace = GetFont('Regular')
	Save.AutoButtonColor = false
	Save.Parent = Background
	AddCorner(Save, UDim.new(0, 7))
	AddHighlight(Save, true)

	local function Select()
		NameLabel.TextTransparency = 1
		RenameTextBox.Text = Properties.Name
		RenameTextBox.Visible = true
		RenameTextBox:CaptureFocus()
		RenameTextBox.SelectionStart = 0
		RenameTextBox.CursorPosition = #RenameTextBox.Text + 1
		RenameTextBox.FocusLost:Once(function()
			local Text
			if table.find(Gui.Profiles, RenameTextBox.Text) then
				local Start, End = RenameTextBox.Text:find('%d+$')
				if Start then
					Text = RenameTextBox.Text:sub(1, Start - 1)..tostring(tonumber(RenameTextBox.Text:sub(Start, End)))
				else
					Text = RenameTextBox.Text..'2'
				end
			else
				Text = RenameTextBox.Text
			end
			Gui.Profiles[#Gui.Profiles + 1] = Text
			Gui:Save(Text)
			if delfile then
				delfile(`TidalWave/Profiles/{Properties.Name}{game.PlaceId}.json`)
			end
			local Index = table.find(Gui.Profiles, Properties.Name)
			if Index then
				table.remove(Gui.Profiles, Index)
			end
			RenameTextBox.Visible = false
			NameLabel.Text = Text
			NameLabel.TextTransparency = 0
			Properties.Name = Text
		end)
	end

	if Properties.New then
		Select()
	end

	local LastClick = 0

	NameLabel.MouseButton1Click:Connect(function()
		if os.clock() - LastClick <= 0.5 then
			Select()
			LastClick = 0
		else
			LastClick = os.clock()
		end
	end)

	Save.MouseButton1Click:Connect(function()
		Gui:Save(Properties.Name)
	end)

	Load.MouseButton1Click:Connect(function()
		Gui:Load(Properties.Name)
	end)

	DeleteButton.MouseButton1Click:Connect(function()
		if not delfile then NotifyPoopSploit("delfile") return end
		local Path = `TidalWave/Profiles/{Properties.Name}{game.PlaceId}.json`
		Tooltip.Visible = false
		if isfile then
			if isfile(Path) then
				delfile(Path)
			end
		else
			pcall(delfile, Path)
		end
		local Index = table.find(Gui.Profiles, Properties.Name)
		if Index then
			table.remove(Gui.Profiles, Index)
		end
		Frame:Destroy()
	end)
end

local ProfilesTopBar = CreateTopBarButton({
	Name = "Profiles",
	Function = function()
		HideMenus("Profiles")
		StopEditingHudPositions()
		for _, v in ProfilesMenu.Object.ScrollingFrame:GetChildren() do
			if v:IsA("GuiObject") then
				v:Destroy()
			end
		end
		for i, v in Gui.Profiles do
			ProfilesMenu:CreateProfileButton({
				Name = v,
				LayoutOrder = i
			})
		end

		local PlusButton = Instance.new("TextButton")
		PlusButton.Name = "Plus"
		PlusButton.BackgroundColor3 = GetColor('Background/Button')
		PlusButton.Text = ''
		PlusButton.BorderSizePixel = 0
		PlusButton.Size = UDim2.fromOffset(40, 40)
		PlusButton.AutoButtonColor = false
		PlusButton.LayoutOrder = 69420
		PlusButton.Parent = ProfilesMenu.Object.ScrollingFrame
		AddCorner(PlusButton, UDim.new(0, 7))
		AddHighlight(PlusButton)

		local PlusImage = Instance.new("ImageLabel")
		PlusImage.Name = "Image"
		PlusImage.BackgroundTransparency = 1
		PlusImage.Size = UDim2.fromOffset(24, 24)
		PlusImage.Position = UDim2.fromOffset(8, 8)
		SetIcon(PlusImage, "plus")
		PlusImage.Parent = PlusButton

		PlusButton.MouseButton1Click:Connect(function()
			local Name = 'new profile'
			if table.find(Gui.Profiles, Name) then
				for i = 1, 100 do
					if not table.find(Gui.Profiles, Name..tostring(i)) then
						Name ..= tostring(i)
						break
					end
				end
			end
			ProfilesMenu:CreateProfileButton({
				Name = "new profile",
				New = true,
			})
		end)
	end,
})

local FriendsMenu = Gui:CreateMenu({
    Name = "Friends"
})

function FriendsMenu:CreateFriendButton(Properties)
    local Frame = Instance.new("Frame")
	Frame.Name = `{Properties.Name}Button`
	Frame.BackgroundTransparency = 1
	Frame.Size = UDim2.new(1, -100, 0, 40)
	Frame.LayoutOrder = Properties.LayoutOrder or table.len(FriendsMenu.Options)
	Frame.Parent = FriendsMenu.Object.ScrollingFrame

	local Background = Instance.new("Frame")
	Background.BackgroundColor3 = GetColor('Background/Button')
	Background.Size = UDim2.new(1, -45, 0, 40)
	Background.BorderSizePixel = 0
	Background.Parent = Frame
	AddCorner(Background, UDim.new(0, 7))

	local NameLabel = Instance.new("TextButton")
	NameLabel.BackgroundTransparency = 1
	NameLabel.Size = UDim2.fromOffset(400, 40)
	NameLabel.Position = UDim2.fromOffset(5, 0)
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	NameLabel.Text = Properties.Name
	NameLabel.TextSize = 24
	NameLabel.TextColor3 = GetColor('Text/Primary')
	NameLabel.FontFace = GetFont('Regular')
	NameLabel.AutoButtonColor = false
	NameLabel.Parent = Background
    AddHighlight(NameLabel)

    local Enabled = if Properties.Enabled ~= nil then Properties.Enabled else true

    local EnabledBar = Instance.new("Frame")
    EnabledBar.Name = "Enabled"
    EnabledBar.BackgroundColor3 = Enabled and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
    EnabledBar.Size = UDim2.new(0, 2, 1, -6)
    EnabledBar.Position = UDim2.new(1, -8, 0, 3)
    EnabledBar.BorderSizePixel = 0
    EnabledBar.Parent = Background

	local RenameTextBox = Instance.new("TextBox")
	RenameTextBox.Name = "Rename"
	RenameTextBox.BackgroundTransparency = 1
	RenameTextBox.Size = UDim2.fromOffset(200, 40)
	RenameTextBox.TextSize = 24
	RenameTextBox.TextColor3 = GetColor('Text/Primary')
	RenameTextBox.FontFace = GetFont('Regular')
	RenameTextBox.ClearTextOnFocus = false
	RenameTextBox.TextXAlignment = Enum.TextXAlignment.Left
	RenameTextBox.Visible = false
	RenameTextBox.Parent = NameLabel

	local DeleteButton = Instance.new("TextButton")
	DeleteButton.Name = "Delete"
	DeleteButton.BackgroundColor3 = GetColor('Background/Button')
	DeleteButton.Text = ""
	DeleteButton.BorderSizePixel = 0
	DeleteButton.Size = UDim2.fromOffset(40, 40)
	DeleteButton.Position = UDim2.new(1, -40, 0, 0)
	DeleteButton.AutoButtonColor = false
	DeleteButton.Parent = Frame
	AddCorner(DeleteButton, UDim.new(0, 7))
	AddHighlight(DeleteButton)
	AddTooltip(DeleteButton, "Click to remove friend")

	local DeleteButtonImage = Instance.new("ImageLabel")
	DeleteButtonImage.Name = "Image"
	DeleteButtonImage.BackgroundTransparency = 1
	DeleteButtonImage.Size = UDim2.fromOffset(24, 24)
	DeleteButtonImage.Position = UDim2.fromOffset(8, 8)
	SetIcon(DeleteButtonImage, "x")
	DeleteButtonImage.Parent = DeleteButton

	local Rename = Instance.new("TextButton")
	Rename.Name = "Rename"
	Rename.BackgroundColor3 = GetColor('Background/Secondary')
	Rename.Text = "Rename"
	Rename.BorderSizePixel = 0
	Rename.Size = UDim2.fromOffset(100, 30)
	Rename.Position = UDim2.new(1, -105, 0, 5)
	Rename.TextColor3 = GetColor('Text/Primary')
	Rename.TextSize = 24
	Rename.FontFace = GetFont('Regular')
	Rename.AutoButtonColor = false
	Rename.Parent = Background
	AddCorner(Rename, UDim.new(0, 7))
	AddHighlight(Rename, true)

	local function Select()
		NameLabel.TextTransparency = 1
		RenameTextBox.Text = Properties.Name
		RenameTextBox.Visible = true
		RenameTextBox:CaptureFocus()
		RenameTextBox.SelectionStart = 0
		RenameTextBox.CursorPosition = #RenameTextBox.Text + 1
		RenameTextBox.FocusLost:Once(function()
            Properties.Name = RenameTextBox.Text
            Gui.Friends[Properties.Name] = Enabled
			RenameTextBox.Visible = false
			NameLabel.Text = Properties.Name
			NameLabel.TextTransparency = 0
		end)
	end

	if Properties.New then
		Select()
	end

	NameLabel.MouseButton1Click:Connect(function()
		Enabled = not Enabled
        EnabledBar.BackgroundColor3 = Enabled and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
        Gui.Friends[Properties.Name] = Enabled
	end)

	Rename.MouseButton1Click:Connect(function()
		Select()
	end)

	DeleteButton.MouseButton1Click:Connect(function()
		Tooltip.Visible = false
		Gui.Friends[Properties.Name] = nil
		Frame:Destroy()
	end)
end

Run(function()
    local UseFriends = FriendsMenu:CreateToggle({
        Name = "Use Friends",
    })

    local Recolor = FriendsMenu:CreateToggle({
        Name = "Recolor Friends"
    })

    local FriendColor = FriendsMenu:CreateColorPicker({
        Name = "Friend Color",
        Default = Color3.fromRGB(0, 255, 0)
    })

    local List = FriendsMenu:CreateTextList({
        Name = "Friends",
    })

    function Gui:IsFriend(Player)
        if not (typeof(Player) == "Instance" and Player:IsA("Player")) then return false end
        return UseFriends.Enabled and table.find(List.Enabled, Player.Name) and true or false, Recolor.Enabled and FriendColor.Color or nil
    end
end)

local FriendsTopBar = CreateTopBarButton({
    Name = "Friends",
    Function = function()
		FriendsMenu:ShowOptions()
		HideMenus("Friends")
		StopEditingHudPositions()
    end
})

local MouseEnabledCon, UpdateCursorCon, HeldModule

local function OnMouseEnableChanged()
	if UIS.MouseIconEnabled then
		if UpdateCursorCon then
			UpdateCursorCon:Disconnect()
			UpdateCursorCon = nil
		end
		Cursor.Visible = false
	else
		Cursor.Visible = true
		UpdateCursorCon = RunService.PreRender:Connect(function()
			local MouseLocation = UIS:GetMouseLocation()
			Cursor.Position = UDim2.fromOffset(MouseLocation.X, MouseLocation.Y)
		end)
	end
end

local function StopCursorCon()
	if MouseEnabledCon then
		MouseEnabledCon:Disconnect()
		MouseEnabledCon = nil
	end
	if UpdateCursorCon then
		UpdateCursorCon:Disconnect()
		UpdateCursorCon = nil
	end
	Cursor.Visible = false
end

local function StartCursorCon()
	StopCursorCon()
	MouseEnabledCon = UIS:GetPropertyChangedSignal("MouseEnabled"):Connect(OnMouseEnableChanged)
	OnMouseEnableChanged()
end

local function CheckKeybind(Keybind, LatestInput)
	if Keybind == 'None' then return false end
	if Keybind:match(LatestInput) then
		for _, v in Keybind:split('+') do
			if not Gui.PressedKeys[v] then return false end
		end
		return true
	end

	return false
end

local UserInputTypes = {
    ["MouseButton1"] = true,
    ["MouseButton2"] = true,
    ["MouseButton3"] = true,
}

local function Concat(Tab, Char)
	local String = ''
	local Index = 0
	for Name in Tab do
		Index += 1
		String ..= (String ~= '' and Char or '') .. Name
	end
	return String
end

Gui:Clean(UIS.InputBegan:Connect(function(Input)
	local TextBox = UIS:GetFocusedTextBox()
	if TextBox then return end
	if Gui.Binding and ((Input.KeyCode == Enum.KeyCode.Unknown and not AllowMouseBinding.Enabled) or Input.KeyCode == Enum.KeyCode.Escape) then
		Gui.Binding:SetKeybind(Gui.Binding.Keybind)
		Gui.Binding = nil
	elseif ((Input.KeyCode ~= Enum.KeyCode.Unknown or AllowMouseBinding.Enabled and UserInputTypes[Input.UserInputType.Name]) and Input.KeyCode ~= Enum.KeyCode.Escape) then
        local Key = Input.KeyCode == Enum.KeyCode.Unknown and Input.UserInputType.Name or Input.KeyCode.Name
		Gui.PressedKeys[Key] = true
		if Gui.Binding then
			Gui.Binding:SetKeybind(Concat(Gui.PressedKeys, '+'))
		else
			local ConfigKeybinds = Gui.Menus.Config.Keybinds
			if ConfigKeybinds.Menu:Check(Input) or ConfigKeybinds.Menu2:Check(Input) then
				if MenuOptionsMenu.Object.Visible then
                    MenuOptionsMenu.Object.Visible = false
                    for i, v in Gui.Menus do
                        if i == PrevMenu then
                            v:Show()
                            break
                        end
                    end
                    return
				end
                local Menu
				for _, v in Gui.Menus do
					if v.Object.Visible then
						Menu = v
					end
				end
				if Menu then
					ModulesTopBar:Select()
					return
				end
				if DoneButton.Visible then
					StopEditingHudPositions()
					return
				end
				if CategoryHolder.Visible then
					Tooltip.Visible = false
					TopBar.Visible = false
					StopCursorCon()
				else
					TopBar.Visible = true
					StartCursorCon()
				end
				for _, v in Gui.Categories do
					v:Toggle()
				end
				if not CategoryHolder.Visible and Gui.CategoryAnimations then
					CategoryHolder.Visible = true
					Modal.Visible = true
				end
			else
				if TopBar.Visible and UserInputTypes[Key] then return end
				for _, Module in Gui.Modules do
					if CheckKeybind(Module.Keybind, Key) then
						if Module.Hold then
							HeldModule = Module
							if not Module.Enabled then
								Module:Toggle()
							end
						else
							Module:Toggle()
						end
					end
				end
                for _, Button in Gui.Buttons do
					if CheckKeybind(Button.Keybind, Key) then
						Button:Toggle()
					end
				end
			end
		end
	end
end))

Gui:Clean(UIS.InputEnded:Connect(function(Input)
	if Input.KeyCode == Enum.KeyCode.Unknown and not AllowMouseBinding.Enabled then return end
    local Key = Input.KeyCode == Enum.KeyCode.Unknown and Input.UserInputType.Name or Input.KeyCode.Name
	Gui.PressedKeys[Key] = nil
	if Gui.Binding then
		Gui.Binding = nil
		table.clear(Gui.PressedKeys)
	elseif HeldModule and HeldModule.Keybind:match(Key) then
		if HeldModule.Enabled then
			HeldModule:Toggle()
		end
		HeldModule = nil
	end
end))

Gui:CreateCategory({
	Name = "Combat"
})

Gui:CreateCategory({
	Name = "Player"
})

Gui:CreateCategory({
	Name = "Movement"
})

Gui:CreateCategory({
	Name = "Visuals"
})

Gui:CreateCategory({
	Name = "World"
})

Gui:CreateCategory({
	Name = "Other"
})

Gui:CreateCategory({
	Name = "Animations"
})

Gui:CreateCategory({
	Name = "Scripts"
})

Gui:CreateCategory({
	Name = "Server"
})

Run(function()
	local Search = Instance.new("TextBox")
	Search.Text = ""
	Search.Name = "Search"
	Search.LayoutOrder = #TopBar:GetChildren()
	Search.Size = UDim2.fromOffset(160, 36)
	Search.BackgroundColor3 = GetColor("Background/Button")
	Search.BackgroundTransparency = 0.25
	Search.BorderSizePixel = 0
	Search.TextColor3 = GetColor("Text/Primary")
	Search.FontFace = GetFont('Regular')
	Search.TextSize = 24
	Search.TextXAlignment = Enum.TextXAlignment.Left
	Search.ClearTextOnFocus = false
	Search.PlaceholderText = "Search"
	Search.PlaceholderColor3 = GetColor("Text/Placeholder")
	Search.Parent = TopBar
	AddCorner(Search, UDim.new(0, 9))
	TopBar.Size += UDim2.fromOffset(168, 0)

	Search:GetPropertyChangedSignal("Text"):Connect(function()
		local Text = Search.Text:lower():gsub(" ", "")
		local Blank = Text:match("%w+") == nil

		for _, Category in Gui.Categories do
			for _, Button in Category.Object.ScrollingFrame:GetChildren() do
				if IsTextObject(Button) then
					local ButtonText = Button.Text:lower():gsub(" ", "")
					local Match = ButtonText:match(Text) or Text:match(ButtonText)
					Button.BackgroundColor3 = Match and not Blank and GetColor("Background/ButtonHover") or GetColor("Background/Button")
					SearchMatches[Button] = if Blank then nil else Match ~= nil or nil
				end
			end
		end
	end)

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, 8)
    UIPadding.Parent = Search

    local Icon = Instance.new("ImageLabel")
    Icon.Name = "SearchIcon"
	Icon.BackgroundTransparency = 1
	Icon.Size = UDim2.fromOffset(24, 24)
	Icon.Position = UDim2.new(1, -32, 0, 6)
	SetIcon(Icon, "search")
	Icon.Parent = Search
end)

Gui:Clean(Players.PlayerRemoving:Connect(function(Player)
	if Player == Plr then
		Gui:Save()
	end
end))

return Gui