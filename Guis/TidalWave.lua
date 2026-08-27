local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
	return cloneref(game:GetService(Service))
end

const RunService: RunService = GetService('RunService')
const HttpService = GetService('HttpService')
const Players: Players = GetService('Players')
const CoreGui: CoreGui = GetService('CoreGui')
const TweenService: TweenService = GetService('TweenService')
const UIS: UserInputService = GetService('UserInputService')
const TextService: TextService = GetService('TextService')
const MarketplaceService: MarketplaceService = GetService('MarketplaceService')
const GuiService: GuiService = GetService('GuiService')

local Plr: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')

local Color3 = table.clone(Color3)
Color3.White = Color3.new(1, 1, 1)
Color3.Black = Color3.new()
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

local UDim2 = table.clone(UDim2)
UDim2.zero = UDim2.new()

local UDim = table.clone(UDim)
UDim.zero = UDim.new()

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
local getcustomasset = getcustomasset or function(Path) return `rbxasset://{Path}` end
local gethui = gethui or function() return (CoreGui and CoreGui:FindFirstChild('RobloxGui')) or CoreGui or Plr:FindFirstChildOfClass('PlayerGui') end

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
if not Lucide then
	if isfile('TidalWave/Libraries/Lucide.lua') then
		Lucide = loadstring(readfile('TidalWave/Libraries/Lucide.lua'), 'Lucide')()
	else
		local Data = game:HttpGet('https://gitlab.com/upio/lucide-roblox-direct/-/raw/main/source.lua?ref_type=heads')
		writefile('TidalWave/Libraries/Lucide.lua', Data)
		Lucide = loadstring(Data, 'Lucide')()
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
			return nil
		end
	}

    function Obj:Clean(Connection: RBXScriptConnection | thread | Instance | (...any) -> (...any) , ...: any)
        local Type = typeof(Connection)

		local Disconnect
        local Connected
		local Key

        if Type == 'Instance' then
			local Con
            Disconnect = function()
				if Con then
					Con:Disconnect()
					Con = nil
				end
                Connection:Destroy()
                Obj.Connections[Connection] = nil
            end
            Connected = function()
                return Connection and Connection.Parent ~= nil
            end

			Con = Connection.AncestryChanged:Connect(function(_, Parent)
				if Parent == nil then
					Con:Disconnect()
					Con = nil
					Obj.Connections[Connection] = nil
				end
			end)
        elseif Type == 'function' then
            local Args = {...}
            Disconnect = function()
                Connection(table.unpack(Args))
                Obj.Connections[Connection] = nil
            end
            Connected = function()
                return true
            end
        elseif Type == 'RBXScriptConnection' then
            Disconnect = function()
                Connection:Disconnect()
                Obj.Connections[Connection] = nil
            end
            Connected = function()
                return Connection and Connection.Connected
            end
        elseif Type == 'thread' then
            Disconnect = function()
                pcall(task.cancel, Connection)
                Obj.Connections[Connection] = nil
            end
            Connected = function()
                return Connection and coroutine.status(Connection) ~= 'dead'
            end
		elseif Type == 'table' and Connection._fn then
			Disconnect = function()
				Connection:Disconnect()
				Obj.Connections[Connection._fn] = nil
			end
			Connected = function()
				return Connection and Connection._connected
			end
			Key = Connection._fn
		else
			error(`Invalid type '{Type}'`)
        end

		local ConnectionObject = {}
		ConnectionObject.Disconnect = Disconnect
		ConnectionObject.Destroy = Disconnect
		ConnectionObject.Remove = Disconnect
		ConnectionObject.Type = Type
		ConnectionObject._Connected = Connected

        setmetatable(ConnectionObject, Metatable)

		Obj.Connections[Key or Connection] = ConnectionObject

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
			Secondary = Color3.fromRGBT(200, 200, 200),
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
	ModuleToggledNotificationDuration = 2,
	NotificationCornerRadius = 6,
	Profile = 'Default',
    NotificationHorizontalAlignment = 'Right',
    NotificationVerticalAlignment = 'Bottom',
    NotificationFillDirection = 'Up',
    RainbowTable = {},
	Profiles = {},
    Friends = {},
	PressedKeys = {},
	Menus = {},
	Modules = {},
    Buttons = {},
	Categories = {},
	Fonts = {
		Regular = Font.fromEnum(Enum.Font.Gotham),
		Medium = Font.fromEnum(Enum.Font.GothamMedium),
		Bold = Font.fromEnum(Enum.Font.GothamBold)
	},
	CurrentVersion = shared.TidalWaveVersion,
	PlaceName = MarketplaceService:GetProductInfoAsync(game.PlaceId).Name,
    Themes = table.clone(BuiltInThemes),
    Theme = "TidalWave",
}
AddMaid(Gui)

local SearchMatches = {}
local ListeningObjects = {
	Colors = {
		Main = {Accent = {}, Icons = {}, EnabledBar = {}, DisabledBar = {}},
		Text = {Primary = {}, Secondary = {}, Placeholder = {}, Shadow = {}, Tooltip = {}},
		Background = {Primary = {}, Secondary = {}, Button = {}, ButtonHover = {}, ButtonPress = {}, Tooltip = {}, Notification = {}},
		Outline = {Primary = {}, Tooltip = {}, Notification = {}},
		Slider = {Handle = {}, HandleHover = {}, HandlePress = {}, LeftBar = {}, RightBar = {}},
		Notification = {ProgressBar = {}, Info = {}, Warning = {}, Error = {}, ModuleEnabled = {}, ModuleDisabled = {}},
	},
	Fonts = {
		Regular = {},
		Medium = {},
		Bold = {},
	}
}

local GuiObjectBackgroundProperties = {
	Frame = {'BackgroundColor3', 'BackgroundTransparency'},
	ScrollingFrame = {'BackgroundColor3', 'BackgroundTransparency'},
	TextButton = {'BackgroundColor3', 'BackgroundTransparency'},
	TextLabel = {'BackgroundColor3', 'BackgroundTransparency'},
	TextBox = {'BackgroundColor3', 'BackgroundTransparency'},
	ImageLabel = {'ImageColor3', 'ImageTransparency'},
	ImageButton = {'ImageColor3', 'ImageTransparency'},
	UIStroke = {'Color', 'Transparency'},
}

local GuiObjectTextProperties = {
	TextLabel = {'TextColor3', 'TextTransparency'},
	TextButton = {'TextColor3', 'TextTransparency'},
	TextBox = {'TextColor3', 'TextTransparency', 'PlaceholderColor3'},
}

local function ListenObject(Obj, First, Second, Callback)
	local SplitText = First and First:split('/') or nil
	if SplitText then
		ListeningObjects.Colors[SplitText[1]][SplitText[2]][Obj] = Callback or 'None'
	end
	SplitText = Second and Second:split('/') or nil
	if SplitText then
		ListeningObjects.Colors[SplitText[1]][SplitText[2]][Obj] = Callback or 'None'
	end
end

local function ListenFont(Obj, Font, Callback)
	assert(typeof(Obj) == 'Instance', `Invalid argument #1 (Instance expected, got {typeof(Obj)})`)
	assert(typeof(Font) == 'string', `Invalid argument #2 (string expected, got {typeof(Obj)})`)
	assert(typeof(Callback) == 'nil' or typeof(Callback) == 'function', `Invalid argument #3 (function or nil expected, got {typeof(Obj)})`)

	ListeningObjects.Fonts[Font][Obj] = Callback or 'None'
end

local function StopListeningFont(Obj)
	local Found
	for Font, Objects in ListeningObjects.Fonts do
		for Object, Callback in Objects do
			if Object == Obj then
				Objects[Obj] = nil
				Found = true
				break
			end
		end
		if Found then break end
	end
end

local function StopListeningObject(Obj)
	for _, Category in ListeningObjects.Colors do
		local Found
		for _, Colors in Category do
			for Object, Function in Colors do
				if Object == Obj then
					Found = true
					Colors[Object] = nil
					break
				end
			end
			if Found then break end
		end
		if Found then break end
	end
end

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
                return Color3.White
            end
        end

        return CurrentColor.Color, CurrentColor.T
    else
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
		local Tab = First == 'Text' and GuiObjectTextProperties or GuiObjectBackgroundProperties
		for Obj, Callback in ListeningObjects.Colors[First][Second] do
			local Properties = Tab[Obj.ClassName]
			local ColorProp, TransparencyProp = Properties[1], Properties[2]
			if typeof(Callback) == 'function' then
				Callback()
			else
				Obj[ColorProp] = Color
				if TransparencyProp then
					Obj[TransparencyProp] = Transparency
				end
			end
		end
    end
end

local function GetFont(FontName)
    return Gui.Fonts[FontName]
end

local function SetFont(FontType, NewFont)
	Gui.Fonts[FontType] = NewFont

	for Object, Callback in ListeningObjects.Fonts[FontType] do
		if typeof(Callback) == 'function' then
			Callback()
		else
			Object.FontFace = NewFont
		end
	end
end

local function AddCorner(Obj, CornerRadius)
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = CornerRadius
	UICorner.Parent = Obj
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
ScreenGui.Parent = gethui()
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
NotificationFolder.Text = ''
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
ListenObject(Tooltip, 'Background/Tooltip', 'Text/Primary')
ListenFont(Tooltip, 'Regular')

local TooltipUIStroke = Instance.new("UIStroke")
TooltipUIStroke.Thickness = 1
TooltipUIStroke.Color = GetColor("Outline/Tooltip")
TooltipUIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
TooltipUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
TooltipUIStroke.Parent = Tooltip
ListenObject(TooltipUIStroke, 'Outline/Tooltip')

local Modal = Instance.new("TextButton")
Modal.Name = "Modal"
Modal.BackgroundTransparency = 1
Modal.Interactable = false
Modal.Active = false
Modal.Modal = true
Modal.Visible = false
Modal.Text = ''
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
ListenObject(TopBar, 'Background/Primary')

local TopBarUIListLayout = Instance.new("UIListLayout")
TopBarUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TopBarUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TopBarUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TopBarUIListLayout.FillDirection = Enum.FillDirection.Horizontal
TopBarUIListLayout.Padding = UDim.new(0, 8)
TopBarUIListLayout.Parent = TopBar

local Cursor = Instance.new('ImageLabel')
Cursor.Name = 'Cursor'
Cursor.Image = 'rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png'
Cursor.Visible = false
Cursor.Size = UDim2.fromOffset(64, 64)
Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
Cursor.BackgroundTransparency = 1
Cursor.ZIndex = 69420
Cursor.Parent = ScreenGui

local GetTextBoundsParams = Instance.new('GetTextBoundsParams')
local TextGUI

Gui:Clean(ScreenGui:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
	if Gui.Scale then
		UIScale.Scale = math.max(ScreenGui.AbsoluteSize.X / 1920, 0.6)
	end
end))

Gui:Clean(UIScale:GetPropertyChangedSignal('Scale'):Connect(function()
	ScaledGui.Size = UDim2.fromScale(1 / UIScale.Scale, 1 / UIScale.Scale)
	for _, v in ScaledGui:QueryDescendants('GuiObject[Visible = true]') do
		v.Visible = false
		v.Visible = true
	end
end))

Gui:Clean(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
end))

local function GetTextBounds(Text: string, TextSize: number, Font: Font?, Width: number?)
    GetTextBoundsParams.Text = Text
    GetTextBoundsParams.Font = Font or GetFont('Regular')
    GetTextBoundsParams.Size = TextSize
    GetTextBoundsParams.Width = Width or 9e9
	GetTextBoundsParams.RichText = Text:match('<[^<>]->') ~= nil

    return TextService:GetTextBoundsAsync(GetTextBoundsParams)
end

local function CreateTopBarButton(Properties)
	local Table = {}

    local TextWidth = math.max(GetTextBounds(Properties.Name, 24).X + 10, 80)

	local Button = Instance.new("TextButton")
	Button.Text = Properties.Name
	Button.Name = Properties.Name
	Button.LayoutOrder = #TopBar:GetChildren()
	Button.Size = UDim2.fromOffset(TextWidth, 36)
	Button.BackgroundColor3 = GetColor("Background/Button")
	Button.BackgroundTransparency = 0.25
	Button.BorderSizePixel = 0
	Button.TextColor3 = GetColor("Text/Primary")
	Button.AutoButtonColor = false
	Button.FontFace = GetFont('Regular')
	Button.TextSize = 24
	Button.Parent = TopBar
	AddCorner(Button, UDim.new(0, 9))
	ListenObject(Button, 'Background/Button', 'Text/Primary', function()
		Button.BackgroundColor3 = Gui.SelectedTopBar == Button and GetColor('Background/ButtonHover') or GetColor('Background/Button')
		Button.TextColor3 = GetColor("Text/Primary")
	end)
	ListenFont(Button, 'Regular')

	TopBar.Size += UDim2.fromOffset(TextWidth + 8, 0)

    local Info = TweenInfo.new(0.1)

	function Table:Select(...)
		for _, v in TopBar:GetChildren() do
			if v:IsA("TextButton") then
				if v == Button then
                    local ButtonHover = GetColor('Background/ButtonHover')
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

local function GuiCheck(Obj)
	local MouseLocation = UIS:GetMouseLocation()
	local Objects = ScreenGui.Parent:GetGuiObjectsAtPosition(MouseLocation.X, MouseLocation.Y - GuiService.TopbarInset.Height)

	for i, v in Objects do
		if v == Obj then
			return true
		elseif v.Visible and v.BackgroundTransparency ~= 1 and v ~= Tooltip and v ~= Cursor then
			return false
		end
	end

	return false
end

local function AddTooltip(Obj, Text, NoGuiCheck)
	if typeof(Text) == 'string' and Text:match('%w+') then
		local function OnMouseMoved(X, Y)
			Y -= Tooltip.AbsoluteSize.Y
			if X + Tooltip.AbsoluteSize.X > Camera.ViewportSize.X then
				X -= Tooltip.AbsoluteSize.X
			end
			Tooltip.Position = UDim2.fromOffset(X / UIScale.Scale, Y / UIScale.Scale)

			if NoGuiCheck then
				Tooltip.Visible = true
			else
				if GuiCheck(Obj) then
					Tooltip.Visible = true
				else
					Tooltip.Visible = false
				end
			end
		end

		Obj.MouseEnter:Connect(function(X, Y)
            if not Gui.Tooltip then return end
			local TextBounds = GetTextBounds(Text, Tooltip.TextSize)
			Tooltip.Text = Text
			Tooltip.Size = UDim2.fromOffset(TextBounds.X + 5, TextBounds.Y + 10)
			OnMouseMoved(X, Y)
		end)

		Obj.MouseMoved:Connect(OnMouseMoved)
		Obj.MouseLeave:Connect(function()
			Tooltip.Visible = false
		end)
	end
end

local function AddHighlight(Obj, CustomColor, NoGuiCheck)
	local Info = TweenInfo.new(0.2)
	local Info2 = TweenInfo.new(0.1)

	local function MouseEnter()
		if not NoGuiCheck and not GuiCheck(Obj) then return end
		
		local Color, Transparency = GetColor('Background/ButtonHover')
		TweenService:Create(Obj, Info, {BackgroundColor3 = Color, BackgroundTransparency = Transparency}):Play()
	end

	local function MouseLeave()
		if SearchMatches[Obj] then
			MouseEnter()
			return
		end

		local Color, Transparency = GetColor(CustomColor or 'Background/Button')
		TweenService:Create(Obj, Info, {BackgroundColor3 = Color, BackgroundTransparency = Transparency}):Play()
	end

	local function MouseMove()
		if NoGuiCheck then return end
		
		if GuiCheck(Obj) then
			if Obj.BackgroundColor3 ~= GetColor('Background/ButtonHover') then
				MouseEnter()
			end
		else
			MouseLeave()
		end
	end

	local function MouseButton1Down()
		if not NoGuiCheck and not GuiCheck(Obj) then return end

		local Color, Transparency = GetColor(CustomColor or 'Background/Button')
		TweenService:Create(Obj, Info2, {BackgroundColor3 = Color, BackgroundTransparency = Transparency}):Play()
	end

	Obj.MouseMoved:Connect(MouseMove)
	Obj.MouseEnter:Connect(MouseEnter)
	Obj.MouseLeave:Connect(MouseLeave)
	Obj.MouseButton1Down:Connect(MouseButton1Down)
	Obj.MouseButton1Up:Connect(MouseEnter)
end

local function SetIcon(Obj, IconName)
	local Icon = Lucide.GetAsset(IconName)
	Obj.Image = Icon.Url
	Obj.ImageRectOffset = Icon.ImageRectOffset
	Obj.ImageRectSize = Icon.ImageRectSize
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

	local function CleanToggle(Toggle)
		if Toggle.DisconnectAll then
			Toggle:DisconnectAll()
		end
		if Toggle.ClearInstances then
			Toggle:ClearInstances()
		end
	end

	for _, v in Gui.Modules do
		if v.Enabled then
			v:Toggle(true)
		end
		for _, v2 in v.Options do
			CleanToggle(v2)
		end
	end

	for _, v in Gui.Menus do
		for _, v2 in v.Options do
			CleanToggle(v2)
			if v2.Options then
				for _, v3 in v2.Options do
					CleanToggle(v3)
				end
			end
		end
	end

	if shared.TidalWaveLoader then
		shared.TidalWaveLoader:Destroy()
		shared.TidalWaveLoader = nil
	end

	Gui.Gui:Destroy()

	Gui:DisconnectAll()
	Gui.Libraries.EntityLib:Shutdown()
	table.clear(Gui.Libraries)
	Gui.Libraries = nil
	LoopClean(Gui)
	Gui = nil

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

	function Gui:Notify(Properties: {Text: string, Title: string?, Duration: number?, Type: 'Info' | 'Warning' | 'Error'?})
		if not Gui.Notifications then return end
		task.delay(0, function()
            local TextWidth = math.max(GetTextBounds(Properties.Text, 15).X + 60, 260)
			local YOffset = (29 + (78 * (#Notifications + 1)))
			local RightAlignment = Gui.NotificationHorizontalAlignment == 'Right'
			local AnchorPoint = RightAlignment and Vector2.zero or Vector2.xAxis
			local TargetAnchorPoint = RightAlignment and Vector2.xAxis or Vector2.zero
			local HortAlignment = RightAlignment and 1 or 0
			local VertAlignment = Gui.NotificationVerticalAlignment == 'Bottom' and 1 or 0
			local VertOffset = Gui.NotificationFillDirection == 'Up' and -YOffset or YOffset
			local Duration = Properties.Duration or 2
			local Type = Properties.Type or 'Info'
			
			local Frame = Instance.new('Frame')
			Frame.Name = 'Notification'
			Frame.Position = UDim2.new(HortAlignment, 0, VertAlignment, VertOffset)
			Frame.Size = UDim2.fromOffset(TextWidth, 75)
			Frame.BackgroundColor3, Frame.BackgroundTransparency = GetColor('Background/Notification')
			Frame.AnchorPoint = AnchorPoint

			local Corner = Instance.new('UICorner')
			Corner.CornerRadius = UDim.new(0, 0)
			local CornerRadius = UDim.new(0, Gui.NotificationCornerRadius)
			if RightAlignment then
				Corner.TopLeftRadius = CornerRadius
				Corner.BottomLeftRadius = CornerRadius
			else
				Corner.TopRightRadius = CornerRadius
				Corner.BottomRightRadius = CornerRadius
			end
			Corner.Parent = Frame

			table.insert(Notifications, Frame)

			local UIStroke = Instance.new('UIStroke')
			UIStroke.Thickness = 1
			UIStroke.Color = GetColor('Outline/Notification')
			UIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
            UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			UIStroke.Parent = Frame

			local TitleShadow = Instance.new('TextLabel')
			TitleShadow.Name = 'TitleShadow'
			TitleShadow.Position = UDim2.fromOffset(40, 6)
			TitleShadow.Size = UDim2.new(1, -80, 0, 20)
			TitleShadow.BackgroundTransparency = 1
			TitleShadow.TextColor3 = GetColor('Text/Shadow')
			TitleShadow.TextSize = 17
			TitleShadow.FontFace = GetFont('Medium')
			TitleShadow.Text = Properties.Title and RemoveTags(Properties.Title) or 'Tidal Wave'
            TitleShadow.TextXAlignment = Enum.TextXAlignment.Left
			TitleShadow.Parent = Frame

			local Title = Instance.fromExisting(TitleShadow)
            Title.Size = UDim2.fromScale(1, 1)
			Title.Name = 'Title'
			Title.TextColor3 = GetColor('Text/Primary')
			Title.RichText = true
			Title.Text = Properties.Title or '<font color = "rgb(255, 215, 0)">Tidal</font> <font color = "rgb(20, 135, 255)">Wave</font>'
			Title.Position = UDim2.fromOffset(-1, -1)
			Title.Parent = TitleShadow

            local NotificationType = Instance.new('ImageLabel')
            NotificationType.Name = 'NotificationType'
            NotificationType.Size = UDim2.fromOffset(14, 14)
            NotificationType.Position = UDim2.fromOffset(10, 10)
            NotificationType.BackgroundTransparency = 1
			NotificationType.ImageColor3 = GetColor(`Notification/{Type}`)
            SetIcon(NotificationType, Type == 'Info' and 'info' or (Type == 'Warning' or Type == 'Error') and 'circle-alert')
            NotificationType.Parent = Frame

			local TextShadow = Instance.new('TextLabel')
			TextShadow.Name = 'TextShadow'
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

			local Text = Instance.fromExisting(TextShadow)
			Text.Name = 'TextLabel'
            Text.Size = UDim2.fromScale(1, 1)
			Text.RichText = true
			Text.TextColor3 = GetColor('Text/Primary')
			Text.Text = Properties.Text
			Text.Position = UDim2.fromOffset(-1, -1)
			Text.Parent = TextShadow

			local Progress = Instance.new('Frame')
			Progress.Name = 'Progress'
			Progress.BackgroundColor3 = GetColor('Notification/ProgressBar')
			Progress.BorderSizePixel = 0
			Progress.Size = UDim2.new(1, -2, 0, 1)
			Progress.Position = UDim2.new(0, 3, 1, -3)
			Progress.Parent = Frame

			Frame.Parent = NotificationFolder

			Tween(Frame, {AnchorPoint = TargetAnchorPoint})
			TweenService:Create(Progress, TweenInfo.new(Duration), {Size = UDim2.fromOffset(0, 1)}):Play()

			task.delay(Duration, function()
				if not Gui then return end
				Tween(Frame, {AnchorPoint = AnchorPoint})
				task.wait(0.25)

				local Index = table.find(Notifications, Frame)
				if Index then
					table.remove(Notifications, Index)
				end
				Frame:Destroy()

				for i, Frame in Notifications do
					YOffset = (29 + (78 * i))
					VertOffset = Gui.NotificationFillDirection == 'Up' and -YOffset or YOffset
                    local Goal = {Position = UDim2.new(HortAlignment, 0, VertAlignment, VertOffset)}
					Tween(Frame, Goal, NotificationTweens.Tweens2)
				end
			end)
		end)
	end
end)

local function Notify(Properties)
	Gui:Notify(Properties)
end

local function NotifyPoopSploit(Function)
    Notify({
        Title = 'Poop Sploit',
        Text = `Your executor doesn't support '{Function}'`,
        Type = 'Error',
        Duration = 5,
    })
end

local function GetAssetFromText(Text)
	local RbxAsset = Text:match('^rbxassetid://%d+$')
	if RbxAsset then
		return RbxAsset
	else
		local Id = Text:match('^%d+$')
		if Id then
			return `rbxassetid://{Id}`
		elseif getcustomasset then
			local Checked
			local Exists
			if isfile then
				Checked = true
				Exists = isfile(Text)
			end
			if Checked then
				if Exists then
					return getcustomasset(Text)
				else
					return nil, 'File not found'
				end
			else
				local Success, Result = pcall(function()
					return getcustomasset(Text)
				end)

				if Success and Result and Result ~= '' then
					return Result
				else
					return nil, Result
				end
			end
		end
	end

	return nil
end

local function CheckPlayer(Player: Player, Name: string): boolean
    Name = Name:lower()
    local PlayerName, DisplayName = Player.Name:lower(), Player.DisplayName:lower()
    local SubCheck = PlayerName:sub(1, #Name) == Name or Name:sub(1, #PlayerName) == PlayerName or DisplayName:sub(1, #Name) == Name or Name:sub(1, #DisplayName) == DisplayName
    local MatchCheck = (PlayerName:match(Name) or Name:match(PlayerName) or DisplayName:match(Name) or Name:match(DisplayName)) ~= nil
    return SubCheck or MatchCheck
end

local function FindPlayer(Name: string)
    if typeof(Name) ~= 'string' then return end
    Name = Name:lower()
	
    for _, Player in Players:GetPlayers() do
        if Player == Plr then continue end
        if Player.Name:lower():sub(1, #Name) == Name then
            return Player
        elseif Player.DisplayName:lower():sub(1, #Name) == Name then
            return Player
        end
    end
	
	return nil
end

local function GetFullPlayerName(Player: Player): string
    return Player.DisplayName == Player.Name and Player.Name or `{Player.DisplayName} (@{Player.Name})`
end

local Components
Components = {
	Delete = function(Properties)
		local Delete = Instance.new("TextButton")
        Delete.Name = "Delete"
        Delete.BackgroundColor3 = GetColor('Background/Button')
        Delete.Text = ''
        Delete.BorderSizePixel = 0
        Delete.Size = UDim2.fromOffset(40, 40)
        Delete.Position = UDim2.new(1, -40, 0, 0)
        Delete.AutoButtonColor = false
        Delete.Parent = Properties.Parent
        AddCorner(Delete, UDim.new(0, 7))
        AddHighlight(Delete)
		ListenObject(Delete, 'Background/Button')

        local Image = Instance.new("ImageLabel")
        Image.Name = "Image"
        Image.BackgroundTransparency = 1
        Image.Size = UDim2.fromOffset(24, 24)
        Image.Position = UDim2.fromOffset(8, 8)
        SetIcon(Image, "x")
        Image.Parent = Delete
		ListenObject(Image, 'Main/Icons')

		Delete.MouseButton1Click:Connect(Properties.Function)

		return Delete
	end,
	Reset = function(Properties)
		local Reset = Instance.new("TextButton")
		Reset.Name = "Reset"
		Reset.BackgroundColor3 = GetColor("Background/Button")
		Reset.Text = ''
		Reset.BorderSizePixel = 0
		Reset.Size = UDim2.fromOffset(40, 40)
		Reset.Position = UDim2.new(1, -40, 0, 0)
		Reset.AutoButtonColor = false
		Reset.Parent = Properties.Parent
		AddCorner(Reset, UDim.new(0, 7))
		AddHighlight(Reset)
		ListenObject(Reset, 'Background/Button')

		local Image = Instance.new("ImageLabel")
		Image.Name = "Image"
		Image.BackgroundTransparency = 1
		Image.Size = UDim2.fromOffset(24, 24)
		Image.Position = UDim2.fromOffset(8, 8)
		SetIcon(Image, "rotate-cw")
		Image.Parent = Reset
		ListenObject(Image, 'Main/Icons')

		Reset.MouseButton1Click:Connect(Properties.Function)

		return Reset
	end,
	Button = function(Properties)
		local Button = {
			Visible = if Properties.Visible ~= nil then Properties.Visible else true
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
		ListenObject(TextButton, 'Background/Button', 'Text/Primary')
		ListenFont(TextButton, 'Regular')

		TextButton.MouseButton1Click:Connect(Properties.Function)

		Button.Toggle = Properties.Function
		Button.Object = TextButton

		Properties.Module.Buttons[Properties.Name:gsub(" ", "")] = Button

		return Button
	end,
    Keybind = function(Properties)
        local Keybind = {
            Keybind = Properties.Keybind or 'None',
            Hold = if Properties.UseHold ~= nil then Properties.Hold or false else nil,
			Visible = if Properties.Visible ~= nil then Properties.Visible else true
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
		ListenObject(Background, 'Background/Button')

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
		ListenObject(KeybindName, 'Text/Primary')
		ListenFont(KeybindName, 'Regular')

        local BindButton = Instance.new("TextButton")
        BindButton.Name = "BindButton"
        BindButton.BackgroundColor3 = GetColor('Background/Secondary')
        BindButton.BorderSizePixel = 0
        BindButton.Size = UDim2.fromOffset(200, 30)
        BindButton.Position = UDim2.fromOffset(200, 5)
        BindButton.TextColor3 = GetColor('Text/Primary')
        BindButton.TextSize = 24
        BindButton.FontFace = GetFont('Regular')
        BindButton.Text = Properties.Keybind or 'None'
        BindButton.AutoButtonColor = false
        BindButton.Parent = Background
        AddCorner(BindButton, UDim.new(0, 7))
        AddHighlight(BindButton, 'Background/Secondary')
        AddTooltip(BindButton, "Click to bind")
		ListenObject(BindButton, 'Background/Secondary', 'Text/Primary')
		ListenFont(BindButton, 'Regular')

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
            AddHighlight(Hold, 'Background/Secondary')
            AddTooltip(Hold, 'Makes you able to hold the keybind rather then just pressing the keybind.')
			ListenObject(Hold, 'Background/Secondary', 'Text/Primary')
			ListenFont(Hold, 'Regular')

            EnabledBar = Instance.new("Frame")
            EnabledBar.Name = "Enabled"
            EnabledBar.BackgroundColor3 = Keybind.Hold and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
            EnabledBar.Size = UDim2.fromOffset(2, 24)
            EnabledBar.Position = UDim2.new(1, -8, 0, 3)
            EnabledBar.BorderSizePixel = 0
            EnabledBar.Parent = Hold
			ListenObject(EnabledBar, 'Main/EnabledBar', nil, function()
				EnabledBar.BackgroundColor3 = Keybind.Hold and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
			end)
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
			['MouseButton1'] = true,
			['MouseButton2'] = true,
			['MouseButton3'] = true,
		}

		local SecondaryKeybind

        function Keybind:IsPressed()
			if SecondaryKeybind and SecondaryKeybind:IsPressed() then return true end
			if self.Keybind == 'None' then return false end
			for _, v in self.Keybind:split('+') do
				local Key = (UserInputTypes[v] and not TopBar.Visible and Enum.UserInputType[v].Name or '') or Enum.KeyCode[v].Name
				if not Gui.PressedKeys[Key] then return false end
			end
			return true
        end

		function Keybind:Check(Input)
			if SecondaryKeybind and SecondaryKeybind:Check(Input) then return true end
			if self.Keybind == 'None' then return false end
			if Input.KeyCode == Enum.KeyCode.None and not UserInputTypes[Input.UserInputType.Name] then return false end
			local Split = self.Keybind:split('+')
			local Key = Input.KeyCode == Enum.KeyCode.None and (not TopBar.Visible and Input.UserInputType.Name or '') or Input.KeyCode.Name
			if Key == Split[1] then
				table.remove(Split, 1)
				for _, v in Split do
					if not Gui.PressedKeys[v] then return false end
				end
				
				return true
			end

			return false
		end

		function Keybind:SetVisible(Visible)
			self.Visible = Visible
			MainFrame.Visible = Visible
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
			Visible = if Properties.Visible ~= nil then Properties.Visible else true
		}

		local BindedOptions = {}

		local Frame = Instance.new("Frame")
		Frame.Name = `{Properties.Name}Toggle`
		Frame.BackgroundTransparency = 1
		Frame.Size = UDim2.new(1, -100, 0, 40)
		Frame.LayoutOrder = Properties.LayoutOrder
		Frame.Visible = Toggle.Visible
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
		AddInstanceTable(Toggle)
		ListenObject(Button, 'Background/Button', 'Text/Primary')
		ListenFont(Button, 'Regular')

		local EnabledBar = Instance.new("Frame")
		EnabledBar.Name = "Enabled"
		EnabledBar.BackgroundColor3 = GetColor("Main/DisabledBar")
		EnabledBar.Size = UDim2.new(0, 2, 1, -6)
		EnabledBar.Position = UDim2.new(1, -8, 0, 3)
		EnabledBar.BorderSizePixel = 0
		EnabledBar.Parent = Button
		ListenObject(EnabledBar, 'Main/EnabledBar', 'Main/DisabledBar', function()
			EnabledBar.BackgroundColor3 = Toggle.Enabled and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
		end)

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
			for _, Object in BindedOptions do
				Object:SetVisible(self.Enabled and self.Visible)
			end
			if self.Enabled then
				if Properties.Enabled then
					task.spawn(Properties.Enabled)
				end
			else
				self:DisconnectAll()
				self:ClearInstances()
			end
			if Properties.Function then
				task.spawn(Properties.Function, self.Enabled)
			end
		end

		function Toggle:Show(Bool)
			Frame.Visible = if Bool then Bool else self.Visible
			for _, Object in BindedOptions do
				Object:SetVisible(self.Enabled and self.Visible)
			end
		end

		function Toggle:Hide()
			Frame.Visible = false
			for _, Object in BindedOptions do
				Object:Hide()
			end
		end

		function Toggle:SetVisible(Visible)
			self.Visible = Visible or false
			Frame.Visible = self.Visible
			for _, Object in BindedOptions do
				Object:SetVisible(self.Enabled and self.Visible)
			end
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
			local MouseLocation = UIS:GetMouseLocation()
			if GuiCheck(Button, MouseLocation.X, MouseLocation.Y) then
				Toggle:Toggle()
			end
		end)

		for i, v in Components do
			Toggle[`Create{i}`] = function(_, ComponentProperties)
				ComponentProperties.Parent = Properties.Parent
                ComponentProperties.LayoutOrder = table.len(Properties.Module.Options) + table.len(Properties.Module.Keybinds)
				ComponentProperties.Visible = Toggle.Enabled and Toggle.Visible
				ComponentProperties.Module = Properties.Module
				local Component = v(ComponentProperties)

				local Name = ComponentProperties.Name:gsub(' ', '')

				BindedOptions[Name] = {
					SetVisible = function(_, Visible)
						Component:SetVisible(Visible)
					end,
					Hide = function()
						if Component.Hide then
							Component:Hide()
						else
							Component.Object.Visible = false
						end
					end,
					Object = Component.Object,
				}

				return Component
			end
		end

		Toggle.Object = Frame

		Properties.Module.Options[Name] = Toggle

		return Toggle
	end,
	TextBox = function(Properties)
		local TextBox = {
			Visible = if Properties.Visible ~= nil then Properties.Visible else true,
			Text = Properties.Text or Properties.Default or ''
		}
		TextBox.Value = TextBox.Text
		local Name = Properties.Name:gsub(' ', '')

		local Frame = Instance.new("Frame")
		Frame.Name = `{Properties.Name}TextBox`
		Frame.BackgroundTransparency = 1
		Frame.Size = UDim2.new(1, -100, 0, 40)
		Frame.LayoutOrder = Properties.LayoutOrder
		Frame.Visible = false
		Frame.Parent = Properties.Parent

		local Background = Instance.new("Frame")
		Background.Name = "Background"
		Background.BackgroundColor3 = GetColor("Background/Button")
		Background.BorderSizePixel = 0
		Background.Size = UDim2.new(1, -45, 0, 40)
		Background.Parent = Frame
		AddCorner(Background, UDim.new(0, 7))
		ListenObject(Background, 'Background/Button')

		local TextLabel = Instance.new("TextLabel")
		TextLabel.BackgroundTransparency = 1
		TextLabel.Size = UDim2.fromOffset(200, 40)
		TextLabel.TextSize = 24
		TextLabel.FontFace = GetFont('Regular')
		TextLabel.TextColor3 = GetColor("Text/Primary")
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.Text = ` {Properties.Name}`
		TextLabel.Parent = Background
		ListenObject(TextLabel, 'Text/Primary')
		ListenFont(TextLabel, 'Regular')

		local TextBoxObject = Instance.new("TextBox")
		TextBoxObject.BackgroundColor3 = GetColor("Background/Secondary")
		TextBoxObject.BorderSizePixel = 0
		TextBoxObject.Size = UDim2.fromOffset(335, 30)
		TextBoxObject.Position = UDim2.fromOffset(215, 5)
		TextBoxObject.ClearTextOnFocus = false
		TextBoxObject.PlaceholderText = Properties.PlaceholderText or Properties.Placeholder or ''
		TextBoxObject.TextColor3 = GetColor("Text/Primary")
        TextBoxObject.PlaceholderColor3 = GetColor("Text/Placeholder")
		TextBoxObject.FontFace = GetFont('Regular')
		TextBoxObject.TextSize = 24
		TextBoxObject.Text = TextBox.Text
		TextBoxObject.ClipsDescendants = true
		TextBoxObject.Parent = Background
		AddCorner(TextBoxObject, UDim.new(0, 7))
		ListenObject(TextBoxObject, 'Background/Secondary', 'Text/Primary')
		ListenObject(TextBoxObject, 'Text/Placeholder')
		ListenFont(TextBoxObject, 'Regular')

		local Padding = Instance.new('UIPadding')
		Padding.PaddingLeft = UDim.new(0, 5)
		Padding.PaddingRight = UDim.new(0, 5)
		Padding.Parent = TextBoxObject

		Components.Reset({
			Parent = Frame,
			Function = function()
				TextBox:SetText(Properties.Text or Properties.Default or '')
			end
		})

		TextBoxObject.FocusLost:Connect(function()
			TextBox.Text = TextBoxObject.Text
			if Properties.Function then
				Properties.Function(TextBox.Text, false)
			end
		end)

		function TextBox:SetVisible(Visible)
			TextBox.Visible = Visible
			Frame.Visible = Visible
		end

		function TextBox:SetText(Text)
			TextBox.Text = Text
			TextBox.Value = Text
			TextBoxObject.Text = Text
			if Properties.Function then
				Properties.Function(TextBox.Text, false)
			end
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

		TextBox.Object = Frame
		Properties.Module.Options[Name] = TextBox

		return TextBox
	end,
	AssetTextBox = function(Properties)
		local OldFunction = Properties.Function
		Properties.Function = function(Text, Loaded)
			local Asset, Result = GetAssetFromText(Text)

			if Asset then
				OldFunction(Asset)
			elseif Result and not Loaded then
				Notify({
					Text = Result,
					Duration = 10,
					Type = 'Error'
				})
			end
		end

		local TextBox = Components.TextBox(Properties)

		return TextBox
	end,
	PlayerTextBox = function(Properties)
		local OldFunction = Properties.Function
		Properties.Function = function(Text, Loaded)
			if Text:match('%w+') then
				local Player = FindPlayer(Text)

				OldFunction(Player)

				if Loaded then return end

				if Player then
					Notify({
						Text = `Set player to {Player.DisplayName} (@{Player.Name})`,
						Duration = 5
					})
				else
					Notify({
						Text = 'Failed to find player',
						Duration = 5,
						Type = 'Error'
					})
				end
			else
				OldFunction(nil)
			end
		end

		local TextBox = Components.TextBox(Properties)

		function TextBox:Refresh()
			Properties.Function(TextBox.Text)
		end

		function TextBox:CheckPlayer(Player)
			return TextBox.Text:match('%w+') ~= nil and CheckPlayer(Player, TextBox.Text)
		end

		return TextBox
	end,
	Slider = function(Properties)
		local Slider = {
			Value = Properties.Default or 0,
			Visible = if Properties.Visible ~= nil then Properties.Visible else true
		}

		local Frame = Instance.new("Frame")
		Frame.Name = `{Properties.Name}Slider`
		Frame.BackgroundTransparency = 1
		Frame.Size = UDim2.new(1, -100, 0, 40)
		Frame.LayoutOrder = Properties.LayoutOrder
		Frame.Visible = Slider.Visible
		Frame.Parent = Properties.Parent

		local Background = Instance.new("Frame")
		Background.Name = "Background"
		Background.BackgroundColor3 = GetColor("Background/Button")
		Background.BorderSizePixel = 0
		Background.Size = UDim2.new(1, -45, 1, 0)
		Background.Parent = Frame
		AddCorner(Background, UDim.new(0, 7))
		ListenObject(Background, 'Background/Button')

		local Input = Instance.new("TextBox")

		local function SetInputText(Number)
			local Suffix = typeof(Properties.Suffix) == 'function' and Properties.Suffix(Number) or Properties.Suffix or ''
			Input.Text = `{Number}{Suffix}`
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
		ListenObject(Input, 'Background/Secondary', 'Text/Primary')
		ListenFont(Input, 'Regular')

		local TextLabel = Instance.new("TextLabel")
		TextLabel.BackgroundTransparency = 1
		TextLabel.TextColor3 = GetColor("Text/Primary")
		TextLabel.Size = UDim2.fromOffset(200, 40)
		TextLabel.FontFace = GetFont('Regular')
		TextLabel.TextSize = 24
		TextLabel.Text = ` {Properties.Name}`
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.Parent = Background
		ListenObject(TextLabel, 'Text/Primary')
		ListenFont(TextLabel, 'Regular')

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
		ListenObject(RightBar, 'Slider/RightBar')

		local LeftBar = Instance.new("Frame")
		LeftBar.Name = "LeftBar"
		LeftBar.BackgroundColor3 = GetColor("Slider/LeftBar")
		LeftBar.BorderSizePixel = 0
		LeftBar.Position = UDim2.fromOffset(0, 9)
		LeftBar.Parent = SliderFrame
		ListenObject(LeftBar, 'Slider/LeftBar')

		local Handle = Instance.new("TextButton")

		local Decimals = typeof(Properties.Decimal) == "number" and Properties.Decimal or 1

		local function CalculatePosition(Type, CustomPosition)
			local X = Type == "Mouse" and (UIS:GetMouseLocation().X - SliderFrame.AbsolutePosition.X) / UIScale.Scale or Type == "Slider" and Handle.Position.X.Offset or Type == "Custom" and CustomPosition
            
			local MaxSize = math.floor(SliderFrame.AbsoluteSize.X / UIScale.Scale)
			local Pos = math.clamp(X, 0, MaxSize)
			local Scale = math.clamp(Pos / MaxSize, 0, 1)

			local Value = Properties.Min + (Scale * (Properties.Max - Properties.Min))

			if Type ~= "Custom" then
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
		ListenObject(Handle, 'Slider/Handle')

        local Info = TweenInfo.new(0.2)
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
			Number = tonumber(Number)
			if Number then
                if Properties.Clamp == true then
					Number = math.clamp(Number, Properties.Min, Properties.Max)
				elseif typeof(Properties.Clamp) == 'table' then
					Number = math.clamp(Number, Properties.Clamp[1], Properties.Clamp[2])
				elseif typeof(Properties.Clamp) == 'function' then
					Number = Properties.Clamp(Number)
				end
                local Pos = CalculatePositionFromValue(Number)
				Handle.Position = UDim2.new(0, Pos, 0, -7)
                LeftBar.Size = UDim2.fromOffset(Pos, 3)
                RightBar.Size = UDim2.fromOffset(SliderFrame.Size.X.Offset - Pos, 3)
                RightBar.Position = UDim2.fromOffset(Pos, 9)
				Slider.Value = Number
				if Properties.Function then
					Properties.Function(Number)
				end
			end
			SetInputText(Slider.Value)
		end

		Input.Focused:Connect(function()
			Input.Text = tostring(Slider.Value)
		end)

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
			Value = Properties.List[1] or 'None',
			Visible = if Properties.Visible ~= nil then Properties.Visible else true
		}

		local Frame = Instance.new('Frame')
		Frame.Name = `{Properties.Name}Dropdown`
		Frame.BackgroundTransparency = 1
		Frame.Size = UDim2.new(1, -100, 0, 40)
		Frame.LayoutOrder = Properties.LayoutOrder
		Frame.Parent = Properties.Parent

		local Background = Instance.new('Frame')
		Background.Name = 'Background'
		Background.BackgroundColor3 = GetColor('Background/Button')
		Background.BorderSizePixel = 0
		Background.Size = UDim2.new(1, -45, 1, 0)
		Background.Parent = Frame
		AddCorner(Background, UDim.new(0, 7))
		ListenObject(Background, 'Background/Button')

		local TextLabel = Instance.new('TextLabel')
		TextLabel.TextColor3 = GetColor('Text/Primary')
		TextLabel.BackgroundTransparency = 1
		TextLabel.Size = UDim2.new(0, 200, 1, 0)
		TextLabel.FontFace = GetFont('Regular')
		TextLabel.TextSize = 24
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.Text = ` {Properties.Name}`
		TextLabel.Parent = Background
		ListenObject(TextLabel, 'Text/Primary')
		ListenFont(TextLabel, 'Regular')

		local TopBar = Instance.new('TextButton')
		TopBar.BackgroundColor3 = GetColor('Background/Secondary')
		TopBar.Name = 'TopBar'
		TopBar.BorderSizePixel = 0
		TopBar.Size = UDim2.fromOffset(240, 30)
		TopBar.Position = UDim2.fromOffset(310, 5)
		TopBar.Text = `   {Properties.List[1] or 'None'}`
		TopBar.AutoButtonColor = false
		TopBar.FontFace = GetFont('Regular')
		TopBar.TextColor3 = GetColor('Text/Primary')
		TopBar.TextSize = 24
		TopBar.TextXAlignment = Enum.TextXAlignment.Left
		TopBar.Parent = Background
        AddTooltip(TopBar, Properties.Info or Properties.Tooltip)
		ListenObject(TopBar, 'Background/Secondary', 'Text/Primary')
		ListenFont(TopBar, 'Regular')

        local TopBarCorner = Instance.new('UICorner')
        TopBarCorner.CornerRadius = UDim.new(0, 7)
        TopBarCorner.Parent = TopBar

		local Arrow = Instance.new("TextButton")
		Arrow.Name = 'Arrow'
		Arrow.Size = UDim2.fromOffset(30, 30)
		Arrow.Position = UDim2.new(1, -30, 0, 0)
		Arrow.BackgroundTransparency = 1
		Arrow.Text = ''
		Arrow.Rotation = -90
		Arrow.Parent = TopBar
		AddCorner(Arrow, UDim.new(0, 7))

		local ArrowImage = Instance.new("ImageLabel")
		ArrowImage.Name = 'Image'
		ArrowImage.Size = UDim2.fromOffset(30, 30)
		ArrowImage.Position = UDim2.fromOffset(0, 0)
		ArrowImage.BackgroundTransparency = 1
		SetIcon(ArrowImage, 'chevron-down')
		ArrowImage.Parent = Arrow

		local ScrollingFrame = Instance.new('ScrollingFrame')
		ScrollingFrame.Size = UDim2.fromScale(1, 0)
		ScrollingFrame.Position = UDim2.fromScale(0, 1)
		ScrollingFrame.BackgroundColor3 = GetColor('Background/Secondary')
		ScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
		ScrollingFrame.ScrollBarThickness = 0
		ScrollingFrame.ScrollBarImageTransparency = 1
		ScrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		ScrollingFrame.ZIndex = 2
		ScrollingFrame.Visible = false
		ScrollingFrame.Parent = TopBar
		ListenObject(ScrollingFrame, 'Background/Secondary')

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 0)
        FrameCorner.BottomLeftRadius = UDim.new(0, 7)
        FrameCorner.BottomRightRadius = UDim.new(0, 7)
        FrameCorner.Parent = ScrollingFrame

		local Padding = Instance.new('UIPadding')
		Padding.PaddingTop = UDim.new(0, 10)
		Padding.PaddingBottom = UDim.new(0, 10)
		Padding.Parent = ScrollingFrame

		local Layout = Instance.new('UIListLayout')
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
			TopBar.Text = `   {Val}`
			if Properties.Function then
				Properties.Function(Val)
			end
			if Properties.Module.Enabled and Properties.Module.ExtraText then
				TextGUI:UpdateExtraText()
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
						ListenObject(Button, 'Background/Button', 'Text/Primary')
						ListenFont(Button, 'Regular')

						Button.MouseButton1Click:Connect(function()
							Dropdown:SetValue(v)
						end)

						table.insert(CreatedButtons, Button)
					end
				end
				ScrollingFrame.Visible = true
				TopBarCorner.CornerRadius = UDim.new(0, 0)
                TopBarCorner.TopLeftRadius = UDim.new(0, 7)
                TopBarCorner.TopRightRadius = UDim.new(0, 7)
			else
				Tween.Completed:Once(function(State)
					if State == Enum.PlaybackState.Completed then
						ScrollingFrame.Visible = false
                        TopBarCorner.CornerRadius = UDim.new(0, 7)
						for _, v in CreatedButtons do
							StopListeningObject(v)
							StopListeningFont(v)
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
		local DefaultList = Properties.List or Properties.Default or {}
		local DefaultEnabled = Properties.Enabled or table.clone(DefaultList)
		local TextList = {
			List = DefaultList,
            Enabled = DefaultEnabled,
			Visible = if Properties.Visible ~= nil then Properties.Visible else true
		}

		local Frame = Instance.new('Frame')
		Frame.Name = `{Properties.Name}TextList`
		Frame.BackgroundTransparency = 1
		Frame.Size = UDim2.new(1, -100, 0, 40)
		Frame.LayoutOrder = Properties.LayoutOrder
		Frame.Parent = Properties.Parent

		local Background = Instance.new('Frame')
		Background.Name = 'Background'
		Background.BackgroundColor3 = GetColor('Background/Button')
		Background.BorderSizePixel = 0
		Background.Size = UDim2.new(1, -45, 1, 0)
		Background.Parent = Frame
		AddCorner(Background, UDim.new(0, 7))
		ListenObject(Background, 'Background/Button')

		local TextLabel = Instance.new('TextLabel')
		TextLabel.TextColor3 = GetColor('Text/Primary')
		TextLabel.BackgroundTransparency = 1
		TextLabel.Size = UDim2.new(0, 200, 1, 0)
		TextLabel.FontFace = GetFont('Regular')
		TextLabel.TextSize = 24
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.Text = ` {Properties.Name}`
		TextLabel.Parent = Background
		ListenObject(TextLabel, 'Text/Primary')
		ListenFont(TextLabel, 'Regular')

		local TopBar = Instance.new('TextButton')
		TopBar.Name = 'TopBar'
		TopBar.Size = UDim2.fromOffset(240, 40)
		TopBar.Position = UDim2.fromOffset(310, 0)
		TopBar.BackgroundColor3 = GetColor('Background/Button')
		TopBar.BorderSizePixel = 0
		TopBar.Text = ''
		TopBar.AutoButtonColor = false
		TopBar.Parent = Background
		ListenObject(TopBar, 'Background/Button')

		local Selected = Instance.new('TextLabel')
		Selected.Size = UDim2.new(1, 0, 0, 30)
		Selected.Position = UDim2.fromOffset(0, 5)
		Selected.BackgroundColor3 = GetColor('Background/Secondary')
		Selected.BorderSizePixel = 0
		Selected.Text = `   {#TextList.Enabled > 0 and table.concat(TextList.Enabled, ', ') or 'None'}`
		Selected.TextSize = 24
		Selected.TextColor3 = GetColor('Text/Primary')
		Selected.FontFace = GetFont('Regular')
		Selected.TextXAlignment = Enum.TextXAlignment.Left
		Selected.TextTruncate = Enum.TextTruncate.AtEnd
		Selected.Parent = TopBar
		ListenObject(Selected, 'Background/Secondary', 'Text/Primary')
		ListenFont(Selected, 'Regular')

		local UICorner = Instance.new('UICorner')
		UICorner.CornerRadius = UDim.new(0, 7)
		UICorner.Parent = Selected

		local Arrow = Instance.new('TextButton')
		Arrow.Name = 'Arrow'
		Arrow.Size = UDim2.fromOffset(30, 30)
		Arrow.Position = UDim2.new(1, -30, 0, 0)
		Arrow.BackgroundTransparency = 1
		Arrow.Text = ''
		Arrow.Rotation = -90
		Arrow.Parent = Selected
		AddCorner(Arrow, UDim.new(0, 7))

		local ArrowImage = Instance.new('ImageLabel')
		ArrowImage.Name = 'ArrowImage'
		ArrowImage.Size = UDim2.fromOffset(30, 30)
		ArrowImage.Position = UDim2.fromOffset(0, 0)
		ArrowImage.BackgroundTransparency = 1
		SetIcon(ArrowImage, 'chevron-down')
		ArrowImage.Parent = Arrow
		ListenObject(ArrowImage, 'Main/Icons')

		local ScrollingFrame = Instance.new('ScrollingFrame')
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
		ListenObject(ScrollingFrame, 'Background/Secondary')
		
		local ScrollingFrameUICorner = Instance.new('UICorner')
		ScrollingFrameUICorner.CornerRadius = UDim.new(0, 0)
        ScrollingFrameUICorner.BottomLeftRadius = UDim.new(0, 7)
        ScrollingFrameUICorner.BottomRightRadius = UDim.new(0, 7)
		ScrollingFrameUICorner.Parent = ScrollingFrame

		local Padding = Instance.new('UIPadding')
		Padding.PaddingTop = UDim.new(0, 10)
		Padding.PaddingBottom = UDim.new(0, 10)
		Padding.Parent = ScrollingFrame

		local Layout = Instance.new('UIListLayout')
		Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		Layout.Padding = UDim.new(0, 5)
		Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Parent = ScrollingFrame

		local PlusButton

		if Properties.CanCreate or Properties.CanCreate == nil then
			PlusButton = Instance.new('TextButton')
			PlusButton.Name = 'Plus'
			PlusButton.BackgroundColor3 = GetColor('Background/Button')
			PlusButton.Text = ''
			PlusButton.BorderSizePixel = 0
			PlusButton.Size = UDim2.fromOffset(32, 32)
			PlusButton.AutoButtonColor = false
			PlusButton.LayoutOrder = 69420
			PlusButton.ZIndex = 2
			PlusButton.Parent = ScrollingFrame
			AddCorner(PlusButton, UDim.new(0, 7))
			AddHighlight(PlusButton)
			ListenObject(PlusButton, 'Background/Button')

			local PlusImage = Instance.new('ImageLabel')
			PlusImage.Name = 'Image'
			PlusImage.BackgroundTransparency = 1
			PlusImage.Size = UDim2.fromOffset(24, 24)
			PlusImage.Position = UDim2.fromOffset(4, 4)
			PlusImage.ZIndex = 2
			SetIcon(PlusImage, 'plus')
			PlusImage.Parent = PlusButton
			ListenObject(PlusImage, 'Main/Icons')
		end
		
		local function GetHeight()
			return (Layout.AbsoluteContentSize.Y + 12) / UIScale.Scale
		end

		Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetHeight())
		end)
		ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetHeight())

		local Expanded = false
		local Info = TweenInfo.new(0.2)
		local Tween, ArrowTween
		local CreatedButtons = {}

		local TextListProperties = Properties

		local function CreateButton(Properties)
            local Enabled = Properties.Enabled == true
			local Button = Instance.new('TextButton')
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
			ListenObject(Button, 'Background/Button', 'Text/Primary')
			ListenFont(Button, 'Regular')

            local EnabledBar = Instance.new('Frame')
            EnabledBar.Name = 'Enabled'
            EnabledBar.BackgroundColor3 = Enabled and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
            EnabledBar.Size = UDim2.new(0, 2, 1, -6)
            EnabledBar.Position = UDim2.new(1, -8, 0, 3)
            EnabledBar.BorderSizePixel = 0
            EnabledBar.ZIndex = 2
            EnabledBar.Parent = Button
			ListenObject(EnabledBar, 'Main/EnabledBar', 'Main/DisabledBar', function()
				EnabledBar.BackgroundColor3 = Enabled and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
			end)

			local DeleteButton, DeleteButtonImage, RenameTextBox

			local CanDelete = (TextListProperties.CanDelete or TextListProperties.CanDelete == nil)
			local CanRename = (TextListProperties.CanRename or TextListProperties.CanRename == nil)

			if CanDelete then
				if typeof(CanDelete) == 'function' and not CanDelete(Properties.Name) then return end

				DeleteButton = Instance.new('TextButton')
				DeleteButton.Name = 'Delete'
				DeleteButton.BackgroundTransparency = 1
				DeleteButton.BackgroundColor3 = GetColor('Background/Button')
				DeleteButton.Text = ''
				DeleteButton.BorderSizePixel = 0
				DeleteButton.Size = UDim2.fromOffset(30, 30)
				DeleteButton.Position = UDim2.new(1, -40, 0, 0)
				DeleteButton.AutoButtonColor = false
				DeleteButton.ZIndex = 2
				DeleteButton.Parent = Button
				AddCorner(DeleteButton, UDim.new(0, 7))
				AddTooltip(DeleteButton, 'Click to remove from list')
				ListenObject(DeleteButton, 'Background/Button')

				DeleteButtonImage = Instance.new('ImageLabel')
				DeleteButtonImage.Name = 'Image'
				DeleteButtonImage.BackgroundTransparency = 1
				DeleteButtonImage.Size = UDim2.fromOffset(24, 24)
				DeleteButtonImage.Position = UDim2.fromOffset(3, 3)
				DeleteButtonImage.ZIndex = 2
				SetIcon(DeleteButtonImage, 'x')
				DeleteButtonImage.Parent = DeleteButton
				ListenObject(DeleteButtonImage, 'Main/Icons')

				DeleteButton.MouseButton1Click:Connect(function()
					Tooltip.Visible = false
					TextList:Remove(Properties.Name)
					local Index = table.find(CreatedButtons, Frame)
					if Index then
						table.remove(CreatedButtons, Index)
					end
					StopListeningFont(Button)
					if RenameTextBox then
						StopListeningFont(RenameTextBox)
					end
					for _, v in {Button, EnabledBar, DeleteButton, DeleteButtonImage, RenameTextBox} do
						StopListeningObject(v)
					end
					Button:Destroy()
				end)
			end

			if CanRename then
				if typeof(CanRename) == 'function' and not CanRename(Properties.Name) then return end

				RenameTextBox = Instance.new('TextBox')
				RenameTextBox.Name = 'Rename'
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
				ListenObject(RenameTextBox, 'Text/Primary')
				ListenFont(RenameTextBox, 'Regular')

				local function Select()
					Button.TextTransparency = 1
					RenameTextBox.Text = Properties.Name
					RenameTextBox.Visible = true
					RenameTextBox:CaptureFocus()
					RenameTextBox.SelectionStart = 0
					RenameTextBox.CursorPosition = #RenameTextBox.Text + 1
					RenameTextBox.FocusLost:Once(function()
						local OldName, NewName = Properties.Name, RenameTextBox.Text
						TextList:Remove(OldName)
						TextList:Add(NewName, Enabled)
						RenameTextBox.Visible = false
						Button.Text = `  {NewName}`
						Button.TextTransparency = 0
						Properties.Name = NewName
					end)
				end

				if Properties.New then
					Select()
				end

				Button.MouseButton2Click:Connect(Select)
			end

			Button.MouseButton1Click:Connect(function()
				Enabled = not Enabled
				TweenEnabledBar(EnabledBar, Enabled)
				if Enabled then
					TextList:Enable(Properties.Name)
				else
					TextList:Disable(Properties.Name)
				end
			end)

			table.insert(CreatedButtons, Button)
		end

		if PlusButton then
			PlusButton.MouseButton1Click:Connect(function()
				CreateButton({
					Name = 'new item',
					LayoutOrder = #TextList.List + 1,
					New = true,
					Enabled = true
				})
			end)
		end

        function TextList:Find(Val)
            local Index = table.find(TextList.Enabled, Val)
            if Index then
                return TextList.Enabled[Index], Index
            end

            return nil
        end

		function TextList:Add(Val, Enabled)
			if not table.find(TextList.List, Val) then
                table.insert(TextList.List, Val)
            end
			if Enabled and not table.find(TextList.Enabled, Val) then
				table.insert(TextList.Enabled, Val)
				if Properties.Function then
                    Properties.Function(TextList.Enabled)
                end
				Selected.Text = `   {table.concat(TextList.Enabled, ', ')}`
			end
		end

		function TextList:Remove(Val)
			local Index = table.find(TextList.List, Val)
            if Index then
                table.remove(TextList.List, Index)
            end
			Index = table.find(TextList.Enabled, Val)
            if Index then
                table.remove(TextList.Enabled, Index)
                if Properties.Function then
                    Properties.Function(TextList.Enabled)
                end
				Selected.Text = `   {#TextList.Enabled > 0 and table.concat(TextList.Enabled, ', ') or 'None'}`
            end
		end

		function TextList:Enable(Val)
			if not table.find(TextList.Enabled, Val) then
				table.insert(TextList.Enabled, Val)
				if Properties.Function then
                    Properties.Function(TextList.Enabled)
                end
				Selected.Text = `   {table.concat(TextList.Enabled, ', ')}`
			end
		end

		function TextList:Disable(Val)
			local Index = table.find(TextList.Enabled, Val)
			if Index then
				table.remove(TextList.Enabled, Index)
				if Properties.Function then
                    Properties.Function(TextList.Enabled)
                end
				Selected.Text = `   {#TextList.Enabled > 0 and table.concat(TextList.Enabled, ', ') or 'None'}`
			end
		end

		function TextList:Expand()
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
							for _, v2 in v:GetDescendants() do
								StopListeningObject(v2)
							end
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
                TextList:Remove(v)
            end
            TextList.List = Tab.List
            TextList.Enabled = Tab.Enabled
			for _, v in TextList.Enabled do
                TextList:Add(v, true)
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
				if Properties.CanDelete or Properties.CanDelete == nil then
					for _, v in CreatedButtons do
						for _, v2 in v:GetDescendants() do
							StopListeningObject(v2)
						end
						v:Destroy()
					end
					table.clear(CreatedButtons)
					table.clear(TextList.List)
					table.clear(TextList.Enabled)
					if Properties.Function then
						Properties.Function(TextList.Enabled)
					end
				end
			end
		})

		TextList.Object = Frame

		Properties.Module.Options[Name] = TextList

		return TextList
	end,
	ColorPicker = function(Properties)
		local DefaultColor = Properties.Color or Properties.DefaultColor or Properties.Default or Color3.new(1, 1, 1)
		local DefaultTransparency = Properties.Transparency or Properties.DefaultTransparency or 0
		local DefaultHue, DefaultSaturation, DefaultValue = DefaultColor:ToHSV()

		local ColorPicker = {
			Color = DefaultColor,
			H = math.round(DefaultHue * 255),
			S = math.round(DefaultSaturation * 255),
			V = math.round(DefaultValue * 255),
			Transparency = DefaultTransparency,
			Visible = if Properties.Visible ~= nil then Properties.Visible else true
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
		ListenObject(Background, 'Background/Button')

		local TextBounds = GetTextBounds(Properties.Name, 24)

		local NameLabel = Instance.new("TextLabel")
		NameLabel.Position = UDim2.fromOffset(5, 0)
		NameLabel.Size = UDim2.fromOffset(TextBounds.X + 5, 40)
		NameLabel.BackgroundTransparency = 1
		NameLabel.FontFace = GetFont('Regular')
		NameLabel.TextSize = 24
		NameLabel.TextColor3 = GetColor("Text/Primary")
		NameLabel.Text = Properties.Name
		NameLabel.TextXAlignment = Enum.TextXAlignment.Left
		NameLabel.Parent = Background
		ListenObject(NameLabel, 'Text/Primary')
		ListenFont(NameLabel, 'Regular')

		local HSVFrame = Instance.new("Frame")
		HSVFrame.Name = "HSVFrame"
		HSVFrame.BackgroundColor3 = GetColor("Background/Secondary")
		HSVFrame.BorderSizePixel = 0
		HSVFrame.Position = UDim2.fromOffset(TextBounds.X + 10, 4)
		HSVFrame.Size = UDim2.fromOffset(168, 32)
		HSVFrame.Parent = Background
		AddCorner(HSVFrame, UDim.new(0, 7))
		ListenObject(HSVFrame, 'Background/Secondary')

		local RGBInput = Instance.new("TextBox")
		RGBInput.Name = "RGBInput"
		RGBInput.BackgroundTransparency = 1
		RGBInput.Position = UDim2.fromOffset(4, 0)
		RGBInput.Size = UDim2.fromOffset(130, 32)
		RGBInput.FontFace = GetFont('Regular')
		RGBInput.TextColor3 = GetColor("Text/Primary")
		RGBInput.TextSize = 24
		RGBInput.PlaceholderColor3 = GetColor("Text/Placeholder")
		RGBInput.PlaceholderText = "[H, S, V]"
		RGBInput.Text = `{ColorPicker.H}, {ColorPicker.S}, {ColorPicker.V}`
		RGBInput.ClearTextOnFocus = false
		RGBInput.ClipsDescendants = true
		RGBInput.Parent = HSVFrame
		ListenObject(RGBInput, 'Text/Primary', 'Text/Placeholder')
		ListenFont(RGBInput, 'Regular')

		local ColorDisplay = Instance.new("ImageButton")
		ColorDisplay.Name = "ColorDisplay"
		ColorDisplay.BackgroundColor3 = DefaultColor
		ColorDisplay.BorderSizePixel = 0
		ColorDisplay.Position = UDim2.fromOffset(136, 4)
		ColorDisplay.Size = UDim2.fromOffset(24, 24)
		ColorDisplay.ImageTransparency = 1
		ColorDisplay.AutoButtonColor = false
		ColorDisplay.Parent = HSVFrame
		AddCorner(ColorDisplay, UDim.new(0, 7))

		local ColorPickerDropdown = Instance.new("Frame")
		ColorPickerDropdown.Name = "ColorPickerDropdown"
		ColorPickerDropdown.BackgroundColor3 = GetColor("Background/Secondary")
		ColorPickerDropdown.BorderSizePixel = 0
		ColorPickerDropdown.Position = UDim2.fromOffset(TextBounds.X + 10, 36)
		ColorPickerDropdown.Size = UDim2.fromOffset(360, 360)
		ColorPickerDropdown.ZIndex = 2
		ColorPickerDropdown.Visible = false
		ColorPickerDropdown.Parent = Background
		AddCorner(ColorPickerDropdown, UDim.new(0, 7))
		ListenObject(ColorPickerDropdown, 'Background/Secondary')

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

		local PlusHorizontal = Instance.new("Frame")
		PlusHorizontal.Name = "Horizontal"
		PlusHorizontal.BackgroundColor3 = Color3.new()
		PlusHorizontal.BorderSizePixel = 0
		PlusHorizontal.Size = UDim2.fromOffset(24, 2)
		PlusHorizontal.Position = UDim2.fromOffset(0, 11)
		PlusHorizontal.ZIndex = 2
		PlusHorizontal.Parent = Plus

		local PlusVertical = Instance.fromExisting(PlusHorizontal)
		PlusVertical.Name = "Vertical"
		PlusVertical.Size = UDim2.fromOffset(2, 24)
		PlusVertical.Position = UDim2.fromOffset(11, 0)
		PlusVertical.Parent = Plus

		local ColorStrip = Instance.new("ImageButton")
		ColorStrip.Name = "ColorStrip"
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
		ListenObject(Arrow, 'Main/Icons')

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

		local function RefreshSwatch()
			local Color = Color3.fromHSV(ColorPicker.H / 255, ColorPicker.S / 255, ColorPicker.V / 255)
			RGBInput.Text = `{math.round(Color.R * 255)}, {math.round(Color.G * 255)}, {math.round(Color.B * 255)}`
			ColorStrip.ImageColor3 = Color3.fromHSV(ColorPicker.H / 255, ColorPicker.S / 255, 1)
			ColorDisplay.BackgroundColor3 = ColorPicker.Color
			ColorDisplay.BackgroundTransparency = ColorPicker.Transparency
		end

		local function RefreshHandles()
			local Scale = UIScale.Scale
			local BackgroundMax = ColorBackground.AbsoluteSize / Scale
			Plus.Position = UDim2.fromOffset(
				math.clamp(BackgroundMax.X - (BackgroundMax.X * (ColorPicker.H / 255)), 0, BackgroundMax.X),
				math.clamp(BackgroundMax.Y - (BackgroundMax.Y * (ColorPicker.S / 255)), 0, BackgroundMax.Y)
			)

			local StripMax = ColorStrip.AbsoluteSize.Y / Scale
			Arrow.Position = UDim2.new(1, 0, 0, math.clamp(StripMax - (StripMax * (ColorPicker.V / 255)), 0, StripMax))
		end

		local function ApplyHSV(SuppressCallback, SuppressHandles)
			ColorPicker.Color = Color3.fromHSV(ColorPicker.H / 255, ColorPicker.S / 255, ColorPicker.V / 255)
			RefreshSwatch()
			if not SuppressHandles then
				RefreshHandles()
			end
			if not SuppressCallback then
				FireCallback()
			end
		end

		local function CreateSlider(SliderProperties)
			local Max = SliderProperties.Max
			local Decimal = SliderProperties.Decimal or 1

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
			ListenObject(Label, 'Text/Primary')
			ListenFont(Label, 'Regular')

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
			Input.Parent = Picker
			AddCorner(Input, UDim.new(0, 7))
			ListenObject(Input, 'Background/Button', 'Text/Primary')
			ListenFont(Input, 'Regular')

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
			ListenObject(RightBar, 'Slider/RightBar')

			local LeftBar = Instance.new("Frame")
			LeftBar.Name = "LeftBar"
			LeftBar.BackgroundColor3 = GetColor("Slider/LeftBar")
			LeftBar.BorderSizePixel = 0
			LeftBar.ZIndex = 2
			LeftBar.Position = UDim2.fromOffset(0, 9)
			ListenObject(LeftBar, 'Slider/LeftBar')

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
			ListenObject(Handle, 'Slider/Handle')

			local function PositionToValue(RawX)
				local TrackWidth = math.floor(SliderFrame.AbsoluteSize.X / UIScale.Scale)
				local Pos = math.clamp(RawX, 0, TrackWidth)
				local Scale = TrackWidth > 0 and (Pos / TrackWidth) or 0
				return Pos, math.round((Scale * Max) * Decimal) / Decimal
			end

			local function ValueToPosition(Value)
				local TrackWidth = math.floor(SliderFrame.AbsoluteSize.X / UIScale.Scale)
				return PositionToValue((Value / Max) * TrackWidth)
			end

			local function SetVisuals(Pos, Value)
				Handle.Position = UDim2.new(0, Pos, 0, -7)
				LeftBar.Size = UDim2.fromOffset(Pos, 3)
				RightBar.Size = UDim2.fromOffset(SliderFrame.Size.X.Offset - Pos, 3)
				RightBar.Position = UDim2.fromOffset(Pos, 9)
				Input.Text = tostring(Value)
				ColorPicker[SliderProperties.Ref] = Value
			end

			local function OnFrameDragged(Source)
				local RawX = Source == "Slider" and Handle.Position.X.Offset
					or (UIS:GetMouseLocation().X - SliderFrame.AbsolutePosition.X) / UIScale.Scale
				local Pos, Value = PositionToValue(RawX)
				SetVisuals(Pos, Value)
				ApplyHSV()
			end

			local function Set(Value, SuppressCallback, SuppressHandles)
				local Number = tonumber(Value)
				if Number then
					local Pos, RoundedValue = ValueToPosition(Number)
					SetVisuals(Pos, RoundedValue)
					ApplyHSV(SuppressCallback, SuppressHandles)
				end
				Input.Text = tostring(ColorPicker[SliderProperties.Ref])
			end

			local StartPos, StartValue = ValueToPosition(ColorPicker[SliderProperties.Ref])
			SetVisuals(StartPos, StartValue)

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
				Set(Input.Text)
			end)

			local HoverTween = TweenInfo.new(0.2)
			local PressTween = TweenInfo.new(0.1)

			Handle.MouseEnter:Connect(function()
				TweenService:Create(Handle, HoverTween, {BackgroundColor3 = GetColor("Slider/HandleHover")}):Play()
			end)
			Handle.MouseLeave:Connect(function()
				TweenService:Create(Handle, HoverTween, {BackgroundColor3 = GetColor('Slider/Handle')}):Play()
			end)
			Handle.MouseButton1Down:Connect(function()
				TweenService:Create(Handle, PressTween, {BackgroundColor3 = GetColor('Slider/HandlePress')}):Play()
			end)
			Handle.MouseButton1Up:Connect(function()
				TweenService:Create(Handle, PressTween, {BackgroundColor3 = GetColor('Slider/HandleHover')}):Play()
			end)

			local Tab = {}
			function Tab:Set(Value, SuppressCallback, SuppressHandles)
				Set(Value, SuppressCallback, SuppressHandles)
			end

			return Tab
		end

		local HueSlider = CreateSlider({
			Name = "Hue",
			Text = "H:",
			Ref = "H",
			Max = 255
		})

		local SaturationSlider = CreateSlider({
			Name = "Saturation",
			Text = "S:",
			Ref = "S",
			Max = 255
		})

		local ValueSlider = CreateSlider({
			Name = "Value",
			Text = "V:",
			Ref = "V",
			Max = 255
		})

		local TransparencySlider = CreateSlider({
			Name = "Transparency",
			Text = "T:",
			Ref = "Transparency",
			Max = 1,
			Decimal = 100
		})

		Components.Reset({
			Parent = Frame,
			Function = function()
				HueSlider:Set(DefaultHue * 255, true, true)
				SaturationSlider:Set(DefaultSaturation * 255, true, true)
				ValueSlider:Set(DefaultValue * 255, true, true)
				TransparencySlider:Set(DefaultTransparency)
			end
		})

		local function OnColorAreaDragged(MouseLocation)
			local Scale = UIScale.Scale
			local X = math.clamp((MouseLocation.X - ColorBackground.AbsolutePosition.X) / Scale, 0, ColorBackground.Size.X.Offset)
			local Y = math.clamp((MouseLocation.Y - GuiService.TopbarInset.Height - ColorBackground.AbsolutePosition.Y) / Scale, 0, ColorBackground.Size.Y.Offset)
			Plus.Position = UDim2.fromOffset(X, Y)

			ColorPicker.H = math.round((1 - (X / ColorBackground.Size.X.Offset)) * 255)
			ColorPicker.S = math.round((1 - (Y / ColorBackground.Size.Y.Offset)) * 255)

			ApplyHSV(false, true)
			HueSlider:Set(ColorPicker.H, true, true)
			SaturationSlider:Set(ColorPicker.S, true, true)
		end

		local function OnColorStripDragged(MouseLocation)
			local Scale = UIScale.Scale
			local Y = math.clamp((MouseLocation.Y - GuiService.TopbarInset.Height - ColorStrip.AbsolutePosition.Y) / Scale, 0, ColorStrip.Size.Y.Offset)
			Arrow.Position = UDim2.new(1, 0, 0, Y)

			ColorPicker.V = math.round((1 - (Y / ColorStrip.Size.Y.Offset)) * 255)

			ApplyHSV(false, true)
			ValueSlider:Set(ColorPicker.V, true, true)
		end

		RefreshSwatch()
		RefreshHandles()

		ColorDisplay.MouseButton1Click:Connect(function()
			ColorPickerDropdown.Visible = not ColorPickerDropdown.Visible
		end)

		ColorBackgroundDragDetector.DragStart:Connect(OnColorAreaDragged)
		ColorBackgroundDragDetector.DragContinue:Connect(OnColorAreaDragged)
		ColorStripDragDetector.DragStart:Connect(OnColorStripDragged)
		ColorStripDragDetector.DragContinue:Connect(OnColorStripDragged)

		RGBInput.FocusLost:Connect(function()
			local Match = RGBInput.Text:gmatch('%d+')
			local Numbers = {Match(), Match(), Match(), Match()}
			if #Numbers == 0 then
				HueSlider:Set(ColorPicker.H, true, true)
				SaturationSlider:Set(ColorPicker.S, true, true)
				ValueSlider:Set(ColorPicker.V, false, false)
			else
				local R = tonumber(Numbers[1])
				local G = tonumber(Numbers[2]) or R
				local B = tonumber(Numbers[3]) or R
				local Transparency = tonumber(Numbers[4])
				local H, S, V = Color3.fromRGB(R, G, B):ToHSV()
				HueSlider:Set(H * 255, true, true)
				SaturationSlider:Set(S * 255, true, true)
				ValueSlider:Set(V * 255, Transparency ~= nil, Transparency ~= nil)
				if Transparency then
					TransparencySlider:Set(Transparency, false, false)
				end
			end
		end)

		local Name = Properties.Name:gsub(' ', '')

		function ColorPicker:Save(Tab)
			Tab[Name] = {
				H = ColorPicker.H,
				S = ColorPicker.S,
				V = ColorPicker.V,
				T = ColorPicker.Transparency,
			}
		end

		function ColorPicker:Load(Tab)
			HueSlider:Set(Tab.H, true, true)
			SaturationSlider:Set(Tab.S, true, true)
			ValueSlider:Set(Tab.V, true, true)
			TransparencySlider:Set(Tab.T)
		end

		function ColorPicker:SetVisible(Visible)
			ColorPicker.Visible = Visible
			Frame.Visible = ColorPicker.Visible
		end

		function ColorPicker:SetColor(Color, Transparency)
			local H, S, V = Color:ToHSV()
			HueSlider:Set(H * 255, true, true)
			SaturationSlider:Set(S * 255, true, true)
			ValueSlider:Set(V * 255, Transparency ~= nil, Transparency ~= nil)
			if Transparency then
				TransparencySlider:Set(Transparency)
			end
		end

		function ColorPicker:SetTransparency(Transparency)
			TransparencySlider:Set(Transparency)
		end

		ColorPicker.Object = Frame
		Properties.Module.Options[Name] = ColorPicker

		return ColorPicker
	end,
	Font = function(Properties)
		local Default = Properties.Default or Properties.Blacklist or 'Montserrat'
		local DefaultWeight = Properties.DefaultWeight or Properties.Weight or 'Regular'

		local Fonts = {
			'AccanthisADFStd',
			'AmaticSC',
			'Arial',
			'Arimo',
			'Balthazar',
			'Bangers',
			'BuilderExtended',
			'BuilderMono',
			'BuilderSans',
			'ComicNeueAngular',
			'Creepster',
			'DenkOne',
			'Fondamento',
			'FredokaOne',
			'GrenzeGotisch',
			'Guru',
			'HighwayGothic',
			'Inconsolata',
			'IndieFlower',
			'JosefinSans',
			'Jura',
			'Kalam',
			'LegacyArial',
			'LegacyArimo',
			'LuckiestGuy',
			'Merriweather',
			'Michroma',
			'Montserrat',
			'NotoSansCJKFallback',
			'Nunito',
			'Oswald',
			'PatrickHand',
			'PermanentMarker',
			'PressStart2P',
			'Roboto',
			'RobotoCondensed',
			'RobotoMono',
			'RomanAntique',
			'Sarpanch',
			'SourceSansPro',
			'SpecialElite',
			'TitilliumWeb',
			'Ubuntu',
			'Zekton',
		}

		local Weights = {
			'Thin',
			'ExtraLight',
			'Light',
			'Regular',
			'Medium',
			'SemiBold',
			'Bold',
			'ExtraBold',
			'Heavy'
		}

		local Index = table.find(Fonts, Default)

		if Index then
			table.remove(Fonts, Index)
			table.insert(Fonts, 1, Default)
		end

		local function GetFontName(Font)
			if Font.Family:match('rbxasset://') then
				return Font.Family:match('(%w+)%.json$')
			elseif Font.Family:match('rbxassetid://%d+') then
				return MarketplaceService:GetProductInfoAsync(tonumber(Font.Family:match('%d+'))).Name
			end

			return nil
		end

		local Dropdown = {
			Font = Default:find('rbxasset') and Font.new(Default, Enum.FontWeight[DefaultWeight]) or Font.fromName(Default, Enum.FontWeight[DefaultWeight]),
			Weight = DefaultWeight,
			Visible = if Properties.Visible ~= nil then Properties.Visible else true
		}

		local Frame = Instance.new('Frame')
		Frame.Name = `{Properties.Name}FontDropdown`
		Frame.BackgroundTransparency = 1
		Frame.Size = UDim2.new(1, -100, 0, 40)
		Frame.LayoutOrder = Properties.LayoutOrder
		Frame.Parent = Properties.Parent

		local Background = Instance.new('Frame')
		Background.Name = 'Background'
		Background.BackgroundColor3 = GetColor('Background/Button')
		Background.BorderSizePixel = 0
		Background.Size = UDim2.new(1, -45, 1, 0)
		Background.Parent = Frame
		AddCorner(Background, UDim.new(0, 7))
		ListenObject(Background, 'Background/Button')

		local TextLabel = Instance.new('TextLabel')
		TextLabel.TextColor3 = GetColor('Text/Primary')
		TextLabel.BackgroundTransparency = 1
		TextLabel.Size = UDim2.new(0, 200, 1, 0)
		TextLabel.FontFace = GetFont('Regular')
		TextLabel.TextSize = 24
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.Text = ` {Properties.Name}`
		TextLabel.Parent = Background
		ListenObject(TextLabel, 'Text/Primary')
		ListenFont(TextLabel, 'Regular')

		local TopBar = Instance.new('TextButton')
		TopBar.Name = 'TopBar'
		TopBar.Size = UDim2.fromOffset(220, 40)
		TopBar.Position = UDim2.fromOffset(330, 0)
		TopBar.BackgroundTransparency = 1
		TopBar.Text = ''
		TopBar.AutoButtonColor = false
		TopBar.Parent = Background

		local TopBarLabel = Instance.new('TextLabel')
		TopBarLabel.Size = UDim2.new(1, 0, 0, 30)
		TopBarLabel.Position = UDim2.fromOffset(0, 5)
		TopBarLabel.BackgroundColor3 = GetColor('Background/Secondary')
		TopBarLabel.BorderSizePixel = 0
		TopBarLabel.Text = `   {GetFontName(Dropdown.Font)}`
		TopBarLabel.TextSize = 24
		TopBarLabel.TextColor3 = GetColor('Text/Primary')
		TopBarLabel.FontFace = GetFont('Regular')
		TopBarLabel.TextXAlignment = Enum.TextXAlignment.Left
		TopBarLabel.Parent = TopBar
        AddTooltip(TopBarLabel, Properties.Info or Properties.Tooltip)
		ListenObject(TopBarLabel, 'Background/Secondary', 'Text/Primary')
		ListenFont(TopBarLabel, 'Regular')

		local LabelPadding = Instance.new('UIPadding')
		LabelPadding.PaddingLeft = UDim.new(0, 5)
		LabelPadding.Parent = TopBarLabel

        local UICorner = Instance.new('UICorner')
        UICorner.CornerRadius = UDim.new(0, 7)
        UICorner.Parent = TopBarLabel

		local Arrow = Instance.new('TextButton')
		Arrow.Name = 'Arrow'
		Arrow.Size = UDim2.fromOffset(30, 30)
		Arrow.Position = UDim2.new(1, -30, 0, 0)
		Arrow.BackgroundTransparency = 1
		Arrow.Text = ''
		Arrow.Rotation = -90
		Arrow.Parent = TopBarLabel
		AddCorner(Arrow, UDim.new(0, 7))

		local ArrowImage = Instance.new('ImageLabel')
		ArrowImage.Name = 'Image'
		ArrowImage.Size = UDim2.fromOffset(30, 30)
		ArrowImage.Position = UDim2.fromOffset(0, 0)
		ArrowImage.BackgroundTransparency = 1
		SetIcon(ArrowImage, 'chevron-down')
		ArrowImage.Parent = Arrow

		local ScrollingFrame = Instance.new('ScrollingFrame')
		ScrollingFrame.Size = UDim2.new(1, 5, 0, 0)
		ScrollingFrame.Position = UDim2.new(0, -5, 1, 0)
		ScrollingFrame.BackgroundColor3 = GetColor('Background/Secondary')
		ScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
		ScrollingFrame.ScrollBarThickness = 0
		ScrollingFrame.ScrollBarImageTransparency = 1
		ScrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		ScrollingFrame.Visible = false
		ScrollingFrame.ZIndex = 2
		ScrollingFrame.Parent = TopBarLabel
		ListenObject(ScrollingFrame, 'Background/Secondary')

        local ScrollingFrameUICorner = Instance.new('UICorner')
        ScrollingFrameUICorner.CornerRadius = UDim.new(0, 0)
        ScrollingFrameUICorner.BottomLeftRadius = UDim.new(0, 7)
        ScrollingFrameUICorner.BottomRightRadius = UDim.new(0, 7)
        ScrollingFrameUICorner.Parent = ScrollingFrame

		local Padding = Instance.new('UIPadding')
		Padding.PaddingTop = UDim.new(0, 10)
		Padding.PaddingBottom = UDim.new(0, 10)
		Padding.Parent = ScrollingFrame

		local Layout = Instance.new('UIListLayout')
		Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		Layout.Padding = UDim.new(0, 5)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Parent = ScrollingFrame

		local WeightTopBar = Instance.new('TextButton')
		WeightTopBar.Name = 'WeightTopBar'
		WeightTopBar.Size = UDim2.fromOffset(160, 40)
		WeightTopBar.Position = UDim2.fromOffset(160, 0)
		WeightTopBar.BackgroundTransparency = 1
		WeightTopBar.Text = ''
		WeightTopBar.AutoButtonColor = false
		WeightTopBar.Parent = Background

		local WeightLabel = Instance.new('TextLabel')
		WeightLabel.Size = UDim2.new(1, 0, 0, 30)
		WeightLabel.Position = UDim2.fromOffset(0, 5)
		WeightLabel.BackgroundColor3 = GetColor('Background/Secondary')
		WeightLabel.BorderSizePixel = 0
		WeightLabel.Text = `   {DefaultWeight}`
		WeightLabel.TextSize = 24
		WeightLabel.TextColor3 = GetColor('Text/Primary')
		WeightLabel.FontFace = GetFont('Regular')
		WeightLabel.TextXAlignment = Enum.TextXAlignment.Left
		WeightLabel.Parent = WeightTopBar
        AddTooltip(WeightLabel, Properties.Info or Properties.Tooltip)
		ListenObject(WeightLabel, 'Background/Secondary', 'Text/Primary')
		ListenFont(WeightLabel, 'Regular')

		local WeightLabelPadding = Instance.new('UIPadding')
		WeightLabelPadding.PaddingLeft = UDim.new(0, 5)
		WeightLabelPadding.Parent = WeightLabel

        local WeightCorner = Instance.new('UICorner')
        WeightCorner.CornerRadius = UDim.new(0, 7)
        WeightCorner.Parent = WeightLabel

		local WeightArrow = Instance.new('TextButton')
		WeightArrow.Name = 'Arrow'
		WeightArrow.Size = UDim2.fromOffset(30, 30)
		WeightArrow.Position = UDim2.new(1, -30, 0, 0)
		WeightArrow.BackgroundTransparency = 1
		WeightArrow.Text = ''
		WeightArrow.Rotation = -90
		WeightArrow.Parent = WeightLabel
		AddCorner(WeightArrow, UDim.new(0, 7))

		local WeightArrowImage = Instance.new('ImageLabel')
		WeightArrowImage.Name = 'Image'
		WeightArrowImage.Size = UDim2.fromOffset(30, 30)
		WeightArrowImage.Position = UDim2.fromOffset(0, 0)
		WeightArrowImage.BackgroundTransparency = 1
		SetIcon(WeightArrowImage, 'chevron-down')
		WeightArrowImage.Parent = WeightArrow

		local WeightScrollingFrame = Instance.new('ScrollingFrame')
		WeightScrollingFrame.Size = UDim2.new(1, 5, 0, 0)
		WeightScrollingFrame.Position = UDim2.new(0, -5, 1, 0)
		WeightScrollingFrame.BackgroundColor3 = GetColor('Background/Secondary')
		WeightScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
		WeightScrollingFrame.ScrollBarThickness = 0
		WeightScrollingFrame.ScrollBarImageTransparency = 1
		WeightScrollingFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		WeightScrollingFrame.Visible = false
		WeightScrollingFrame.ZIndex = 2
		WeightScrollingFrame.Parent = WeightLabel
		ListenObject(WeightScrollingFrame, 'Background/Secondary')

        local WeightScrollingFrameCorner = Instance.new('UICorner')
        WeightScrollingFrameCorner.CornerRadius = UDim.new(0, 0)
        WeightScrollingFrameCorner.BottomLeftRadius = UDim.new(0, 7)
        WeightScrollingFrameCorner.BottomRightRadius = UDim.new(0, 7)
        WeightScrollingFrameCorner.Parent = WeightScrollingFrame

		local WeightPadding = Instance.new('UIPadding')
		WeightPadding.PaddingTop = UDim.new(0, 10)
		WeightPadding.PaddingBottom = UDim.new(0, 10)
		WeightPadding.Parent = WeightScrollingFrame

		local WeightLayout = Instance.new('UIListLayout')
		WeightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		WeightLayout.Padding = UDim.new(0, 5)
        WeightLayout.SortOrder = Enum.SortOrder.LayoutOrder
		WeightLayout.Parent = WeightScrollingFrame

		local function GetHeight()
			return (Layout.AbsoluteContentSize.Y + 12) / UIScale.Scale
		end

		local function GetWeightHeight()
			return (WeightLayout.AbsoluteContentSize.Y + 12) / UIScale.Scale
		end

		Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetHeight())
		end)
		ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetHeight())

		WeightLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			WeightScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetWeightHeight())
		end)
		WeightScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, GetWeightHeight())

		local Expanded, WeightExpanded = false, false
		local Info = TweenInfo.new(0.2)
		local Tween, ArrowTween, Tween2, ArrowTween2
		local CreatedButtons = {}
		local CreatedWeightButtons = {}

		function Dropdown:SetFont(Name, Weight)
			if Name:find('rbxasset') then
				self.Font = Font.new(Name, Enum.FontWeight[Weight or self.Weight])
			else
				self.Font = Font.fromName(Name, Enum.FontWeight[Weight or self.Weight])
			end
			
			if Weight then
				WeightLabel.Text = Weight
			end
			
			TopBarLabel.Text = GetFontName(self.Font)
			if Properties.Function then
				Properties.Function(self.Font)
			end
		end

		function Dropdown:SetWeight(Weight)
			self.Font = Font.new(self.Font.Family, Enum.FontWeight[Weight])
			self.Weight = Weight

			WeightLabel.Text = Weight
			if Properties.Function then
				Properties.Function(self.Font)
			end
		end
		
		local function Expand()
			Expanded = not Expanded
			if Tween then
				Tween:Cancel()
			end
			if ArrowTween then
				ArrowTween:Cancel()
			end
			Tween = TweenService:Create(ScrollingFrame, Info, {Size = UDim2.new(1, 5, 0, Expanded and 240 or 0)})
			ArrowTween = TweenService:Create(Arrow, Info, {Rotation = Expanded and 0 or -90})
			if Expanded then
				if #CreatedButtons == 0 then
					for i, Name in Fonts do
						local Button = Instance.new('TextButton')
						Button.Size = UDim2.fromOffset(200, 30)
						Button.BackgroundColor3 = GetColor('Background/Button')
						Button.TextColor3 = GetColor('Text/Primary')
						Button.FontFace = GetFont('Regular')
						Button.TextSize = 20
						Button.Text = `  {Name}`
						Button.LayoutOrder = i
						Button.ZIndex = 2
						Button.BorderSizePixel = 0
						Button.AutoButtonColor = false
						Button.TextXAlignment = Enum.TextXAlignment.Left
						Button.Parent = ScrollingFrame
						AddCorner(Button, UDim.new(0, 7))
						AddHighlight(Button)
						ListenObject(Button, 'Background/Button', 'Text/Primary')
						ListenFont(Button, 'Regular')

						Button.MouseButton1Click:Connect(function()
							Dropdown:SetFont(Name)
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
						for _, v in CreatedButtons do
							StopListeningObject(v)
							StopListeningFont(v)
							v:Destroy()
						end
						table.clear(CreatedButtons)
					end
				end)
			end
			Tween:Play()
			ArrowTween:Play()
		end

		local function ExpandWeight()
			WeightExpanded = not WeightExpanded
			if Tween2 then
				Tween2:Cancel()
			end
			if ArrowTween2 then
				ArrowTween2:Cancel()
			end
			Tween2 = TweenService:Create(WeightScrollingFrame, Info, {Size = UDim2.new(1, 5, 0, WeightExpanded and 240 or 0)})
			ArrowTween2 = TweenService:Create(WeightArrow, Info, {Rotation = WeightExpanded and 0 or -90})
			if WeightExpanded then
				if #CreatedWeightButtons == 0 then
					for i, Weight in Weights do
						local Button = Instance.new('TextButton')
						Button.Size = UDim2.fromOffset(140, 30)
						Button.BackgroundColor3 = GetColor('Background/Button')
						Button.TextColor3 = GetColor('Text/Primary')
						Button.FontFace = GetFont('Regular')
						Button.TextSize = 20
						Button.Text = `  {Weight}`
						Button.LayoutOrder = i
						Button.ZIndex = 2
						Button.BorderSizePixel = 0
						Button.AutoButtonColor = false
						Button.TextXAlignment = Enum.TextXAlignment.Left
						Button.Parent = WeightScrollingFrame
						AddCorner(Button, UDim.new(0, 7))
						AddHighlight(Button)
						ListenObject(Button, 'Background/Button', 'Text/Primary')
						ListenFont(Button, 'Regular')

						Button.MouseButton1Click:Connect(function()
							Dropdown:SetWeight(Weight)
						end)

						table.insert(CreatedWeightButtons, Button)
					end
				end

				WeightScrollingFrame.Visible = true
				WeightCorner.CornerRadius = UDim.new(0, 0)
                WeightCorner.TopLeftRadius = UDim.new(0, 7)
                WeightCorner.TopRightRadius = UDim.new(0, 7)
			else
				Tween2.Completed:Once(function(State)
					if State == Enum.PlaybackState.Completed then
						WeightScrollingFrame.Visible = false
                        WeightCorner.CornerRadius = UDim.new(0, 7)
						for _, v in CreatedWeightButtons do
							StopListeningObject(v)
							StopListeningFont(v)
							v:Destroy()
						end
						table.clear(CreatedWeightButtons)
					end
				end)
			end
			Tween2:Play()
			ArrowTween2:Play()
		end

		local Name = Properties.Name:gsub(' ', '')

		function Dropdown:Save(Tab)
			Tab[Name] = {
				Family = self.Font.Family,
				Weight = self.Font.Weight.Name
			}
		end

		function Dropdown:Load(Tab)
			if Dropdown.Font.Family ~= Tab.Family or Dropdown.Font.Weight.Name ~= Tab.Weight then
				Dropdown:SetFont(Tab.Family, Tab.Weight)
			end
		end

		function Dropdown:SetVisible(Visible)
			Dropdown.Visible = Visible
			Frame.Visible = Dropdown.Visible
		end

		Arrow.MouseButton1Click:Connect(Expand)
		Arrow.MouseButton2Click:Connect(Expand)
		TopBar.MouseButton1Click:Connect(Expand)
		TopBar.MouseButton2Click:Connect(Expand)

		WeightArrow.MouseButton1Click:Connect(ExpandWeight)
		WeightArrow.MouseButton2Click:Connect(ExpandWeight)
		WeightTopBar.MouseButton1Click:Connect(ExpandWeight)
		WeightTopBar.MouseButton2Click:Connect(ExpandWeight)

		Components.Reset({
			Parent = Frame,
			Function = function()
				if Dropdown.Font ~= Default or Dropdown.Font.Weight.Name ~= DefaultWeight then
					Dropdown:SetFont(Default, DefaultWeight)
				end
			end
		})

		Dropdown.Object = Frame
		Properties.Module.Options[Name] = Dropdown

		return Dropdown
	end
}

local ModulesTopBar, MenuOptionsMenu

function Gui:CreateMenu(Properties)
	local Menu = {
		Options = {},
        Buttons = {},
		Keybinds = {}
	}

	local TopBar = Instance.new('TextButton')
	TopBar.Position = UDim2.new(0.5, -350, 0.5, -270)
	TopBar.Size = UDim2.fromOffset(700, 40)
	TopBar.BackgroundColor3 = GetColor('Main/Accent')
    TopBar.Text = ''
	TopBar.AutoButtonColor = false
	TopBar.Name = `{Properties.Name}Menu`
	TopBar.Visible = false
	TopBar.Parent = MenuHolder
	ListenObject(TopBar, 'Main/Accent')

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
    NameLabel.FontFace = GetFont('Medium')
    NameLabel.TextColor3 = GetColor('Text/Primary')
    NameLabel.Parent = TopBar
	ListenObject(NameLabel, 'Text/Primary')
	ListenFont(NameLabel, 'Medium')

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
	ListenObject(ScrollingFrame, 'Background/Primary')

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
	Close.Text = ''
	Close.Parent = TopBar

	local CloseImage = Instance.new("ImageLabel")
	CloseImage.Name = "Image"
	CloseImage.Size = UDim2.fromOffset(36, 36)
	CloseImage.Position = UDim2.fromOffset(2, 2)
	CloseImage.BackgroundTransparency = 1
	SetIcon(CloseImage, "x")
	CloseImage.Parent = Close
	ListenObject(CloseImage, 'Main/Icons')

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

    function Menu:CreateOption(Properties)
		Properties.Parent = ScrollingFrame
		Properties.LayoutOrder = table.len(Menu.Options) + table.len(Menu.Keybinds)
		Properties.Module = Menu
		local Toggle = Components.Toggle(Properties)
		Toggle.Options = {}
		Toggle.Buttons = {}
		Toggle.Keybinds = {}

		Toggle.Object.Button.MouseButton2Click:Connect(function()
			MenuOptionsMenu.Object.Title.Text = Properties.Name
			for i, v in Gui.Menus do
				v.Object.Visible = i == "MenuOptions"
			end
			
			for i, v in MenuOptionsMenu.Options do
				if v.Hide then
					v:Hide()
				else
					v.Object.Visible = false
				end
			end
			for i, v in MenuOptionsMenu.Keybinds do
				v.Object.Visible = false
			end
			for i, v in MenuOptionsMenu.Buttons do
				v.Object.Visible = false
			end

			for i, v in Toggle.Options do
				if v.Show then
					v:Show()
				else
					v.Object.Visible = v.Visible
				end
			end
			for i, v in Toggle.Buttons do
				v.Object.Visible = v.Visible
			end
		end)

		local Name = Properties.Name:gsub(' ', '')

		for i, v in Components do
			Toggle[`Create{i}`] = function(_, Properties)
				Properties.Parent = MenuOptionsMenu.Object.ScrollingFrame
				Properties.LayoutOrder = table.len(Toggle.Options)
				Properties.Module = Toggle
				local Component = v(Properties)
				local Tab = (i == 'Keybind' and MenuOptionsMenu.Keybinds or i == 'Button' and MenuOptionsMenu.Buttons or MenuOptionsMenu.Options)
				Tab[Name..'_'..Properties.Name:gsub(' ', '')] = Component

				return Component
			end
		end

		Menu.Options[Name] = Toggle

		return Toggle
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

Run(function()
	TextGUI = {
		Sorting = 'Biggest',
		Text = `<font color = 'rgb(255, 215, 0)'>Tidal</font> <font color = 'rgb(20, 135, 255)'>Wave</font> v{Gui.CurrentVersion}`,
		AnimationEnabled = true,
		AnimationDuration = 0.3,
		OutlineOffset = 1,
		Scale = 1,
		RightPadding = 8,
		LeftPadding = 4,
		Spacing = 0,
		LayoutPadding = 0,
		CornerRadius = 4,
		BackgroundTransparency = 0.5,
		BarThickness = 4,
		BackgroundEnabled = false,
		BarEnabled = true,
		TextShadow = true,
		WatermarkEnabled = true,
		ImageEnabled = false,
		Image = '',
		ImageWidth = 200,
		ImageHeight = 50,
		ImageRectEnabled = false,
		ImageRectOffsetX = 0,
		ImageRectOffsetY = 0,
		ImageRectSizeX = 200,
		ImageRectSizeY = 50,
		BackgroundColor = Color3.fromRGB(0, 0, 0),
		BarColor = Color3.fromRGB(0, 200, 255),
		TextColor = Color3.fromRGB(30, 150, 255),
		WatermarkTextColor = GetColor('Text/Primary'),
		WatermarkFont = GetFont('Bold'),
		Font = GetFont('Medium'),
		Alignment = 'Right',
		RGB = false,
		RGBText = false,
		RGBBackground = false,
		RGBBar = false,
		RGBWatermark = false,
		RGBImage = false,
		RGBGradient = true,
		RGBRefreshRate = 60,
		RGBSpeed = 1,
		RGBSpread = 1,
		RGBDirection = 'Down',
		RGBTextSaturation = 1,
		RGBTextValue = 1,
		RGBBackgroundSaturation = 1,
		RGBBackgroundValue = 1,
		RGBBarSaturation = 1,
		RGBBarValue = 1,
		RGBWatermarkSaturation = 1,
		RGBWatermarkValue = 1
	}
	Gui.TextGUI = TextGUI

    local DefaultSize = UDim2.fromOffset(math.max(GetTextBounds(TextGUI.Text, 24, TextGUI.WatermarkFont).X, 300), 32)
	local TopBar = Instance.new('ImageButton')
	TopBar.Name = 'TextGUI'
	TopBar.Size = DefaultSize
	TopBar.Position = UDim2.new(1, -DefaultSize.X.Offset - 7, 0, 7)
	TopBar.BackgroundTransparency = 1
	TopBar.ImageTransparency = 1
	TopBar.Active = false
	TopBar.Interactable = false
	TopBar.Parent = HudFolder

	TextGUI.Object = TopBar
	
	local Layout = Instance.new('UIListLayout')
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = TopBar

	local WatermarkShadow = Instance.new('TextLabel')
	WatermarkShadow.Name = 'Watermark'
	WatermarkShadow.Size = DefaultSize
	WatermarkShadow.BackgroundTransparency = 1
	WatermarkShadow.Text = RemoveTags(TextGUI.Text)
	WatermarkShadow.TextColor3 = GetColor('Text/Shadow')
	WatermarkShadow.TextSize = 24
	WatermarkShadow.FontFace = TextGUI.WatermarkFont
	WatermarkShadow.RichText = true
	WatermarkShadow.TextXAlignment = Enum.TextXAlignment.Right
	WatermarkShadow.LayoutOrder = 1
	WatermarkShadow.Parent = TopBar

	local WatermarkShadowPadding = Instance.new('UIPadding')
	WatermarkShadowPadding.PaddingRight = UDim.new(0, 5)
	WatermarkShadowPadding.Parent = WatermarkShadow

	local Watermark = Instance.fromExisting(WatermarkShadow)
	Watermark.RichText = true
	Watermark.TextColor3 = GetColor('Text/Primary')
	Watermark.Size = UDim2.fromScale(1, 1)
	Watermark.Text = TextGUI.Text
	Watermark.Position = UDim2.fromOffset(-1, -1)
	Watermark.Parent = WatermarkShadow

	local WatermarkGradient = Instance.new('UIGradient')
	WatermarkGradient.Rotation = 90
	WatermarkGradient.Enabled = false
	WatermarkGradient.Parent = Watermark

	local Image = Instance.new('ImageLabel')
	Image.Size = UDim2.fromOffset(200, 50)
	Image.BackgroundTransparency = 1
	Image.Image = ''
	Image.Visible = false
	Image.LayoutOrder = 2
	Image.Parent = TopBar

	local ImageGradient = Instance.new('UIGradient')
	ImageGradient.Rotation = 90
	ImageGradient.Enabled = false
	ImageGradient.Parent = Image

	local Children = Instance.new("Frame")
	Children.Name = "Children"
	Children.Size = UDim2.new(1, 0, 0, 0)
	Children.Position = UDim2.fromOffset(0, 32)
	Children.AutomaticSize = Enum.AutomaticSize.Y
	Children.BackgroundTransparency = 1
	Children.ClipsDescendants = true
	Children.Active = false
	Children.LayoutOrder = 3
	Children.Parent = TopBar

	local Tweens = {}
	local Tweens2 = {}
	local Modules = {}

	local Info = TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

	local function GetFullText(Module)
		local Name = Module.Name
		local RichText
		local ExtraText = typeof(Module.ExtraText) == 'function' and Module.ExtraText() or Module.ExtraText
		if ExtraText then
			local Color = GetColor('Text/Secondary')
			RichText = `{Name} <font color = '#{Color:ToHex()}'>{ExtraText}</font>`
			Name ..= ' ' .. ExtraText
		end
		return Name, RichText
	end

	local function Sort()
		if TextGUI.Sorting == "a-z" or TextGUI.Sorting == 'z-a' then
			table.sort(Modules, function(a, b)
				a = GetFullText(a):lower()
				b = GetFullText(b):lower()
				if TextGUI.Sorting == 'a-z' then
					return a < b
				else
					return a > b
				end
			end)
		else
			local Medium = GetFont('Medium')

			table.sort(Modules, function(a, b)
				local aText = GetFullText(a)
				local bText = GetFullText(b)
				a = GetTextBounds(aText, 16, Medium).X
				b = GetTextBounds(bText, 16, Medium).X

				if a == b then
					return aText:lower() < bText:lower()
				end

				if TextGUI.Sorting == 'Biggest' then
					return a > b
				else
					return a < b
				end
			end)
		end
	end

	local function UpdateCorners()
		local Length = #Modules
		for Index, CurrentModule in Modules do
			local NextModule = Modules[Index + 1]
			local NextModuleSize = NextModule and NextModule.Frame.Size.X.Offset or 0

			local CurrentModuleSize = CurrentModule.Frame.Size.X.Offset

			local Diff = CurrentModuleSize - NextModuleSize
			local AbsoluteDiff = math.min(math.abs(Diff), TextGUI.CornerRadius)

			local Corner = CurrentModule.Frame.TextShadow.UICorner
			local BarCorner = CurrentModule.Frame.Bar.UICorner
			local CornerRadius = UDim.new(0, AbsoluteDiff)

			Corner.CornerRadius = UDim.zero
			BarCorner.CornerRadius = UDim.zero

			if TextGUI.Sorting == 'a-z' or TextGUI.Sorting == 'z-a' then
				Corner[`Bottom{TextGUI.Alignment == 'Right' and 'Left' or 'Right'}Radius`] = Diff > 0 and CornerRadius or UDim.zero

				if Index ~= 1 then
					local LastModule = Modules[Index - 1]
					local LastModuleSize = LastModule and LastModule.Frame.Size.X.Offset or 0
					local Diff2 = LastModuleSize - CurrentModuleSize
					local AbsoluteDiff2 = math.min(math.abs(Diff2), TextGUI.CornerRadius)

					Corner[`Top{TextGUI.Alignment == 'Right' and 'Left' or 'Right'}Radius`] = Diff2 > 0 and UDim.new(0, AbsoluteDiff2) or UDim.zero
				end
			else
				Corner[`{TextGUI.Sorting == 'Biggest' and 'Bottom' or 'Top'}{TextGUI.Alignment == 'Right' and 'Left' or 'Right'}Radius`] = CornerRadius
			end

			if Index == 1 then
				Corner.TopLeftRadius = CornerRadius
				Corner.TopRightRadius = CornerRadius
				BarCorner[`Top{TextGUI.Alignment}Radius`] = CornerRadius
			end
			if Index == Length then
				Corner.BottomRightRadius = CornerRadius
				BarCorner[`Bottom{TextGUI.Alignment}Radius`] = CornerRadius
			end
		end
	end

	local function SetPadding(UIPadding)
		if TextGUI.Alignment == 'Right' then
			UIPadding.PaddingLeft = UDim.zero
			UIPadding.PaddingRight = UDim.new(0, TextGUI.RightPadding)
		else
			UIPadding.PaddingRight = UDim.zero
			UIPadding.PaddingLeft = UDim.new(0, TextGUI.RightPadding)
		end
	end

	local function UpdateBarThickness()
		for _, Module in Modules do
			local Text = GetFullText(Module)
			local TextWidth = GetTextBounds(Text, 16 * TextGUI.Scale, TextGUI.Font).X + TextGUI.RightPadding + TextGUI.LeftPadding
			local Height = 20 * TextGUI.Scale
			local Size = UDim2.fromOffset(TextWidth, Height)
			local BarSize = UDim2.fromOffset(TextGUI.BarThickness, Height)
			
			Module.Frame.Size = Size
			Module.Frame.Bar.Size = BarSize
		end
	end

	local function UpdateYPositions(NoTween)
		for i, v in Modules do
			local Height = 20 * TextGUI.Scale
			local Y = (Height + TextGUI.Spacing) * (i - 1)
			local Goal = UDim2.new(v.Frame.Position.X.Scale, v.Frame.Position.X.Offset, 0, Y)
			if NoTween or not TextGUI.AnimationEnabled then
				v.Frame.Position = Goal
			else
				local ExistingTween = Tweens2[v.Frame]
				if ExistingTween then
					ExistingTween:Cancel()
				end

				local NewTween = TweenService:Create(v.Frame, Info, {Position = Goal})
				NewTween:Play()
				NewTween.Completed:Once(function(State)
					if State == Enum.PlaybackState.Completed then
						Tweens2[v.Frame] = nil
					end
				end)

				Tweens2[v.Frame] = NewTween
			end
		end
	end

	local function UpdateExtraText(Module)
		local FullText, RichText = GetFullText(Module)
		local Width = GetTextBounds(FullText, 16 * TextGUI.Scale, TextGUI.Font).X + TextGUI.RightPadding + TextGUI.LeftPadding
		local Height = 20 * TextGUI.Scale
		local Size = UDim2.fromOffset(Width, Height)

		Module.Frame.Size = Size
		Module.Frame.TextShadow.Text = FullText
		Module.Frame.TextShadow.TextLabel.Text = RichText or FullText
	end

	local function Find(Frame)
		for i, v in Modules do
			if v.Frame == Frame then
				return i, v
			end
		end
		
		return nil
	end

	local function TweenModule(Frame)
		if TextGUI.AnimationEnabled then
			local NewTween = TweenService:Create(Frame, Info, {AnchorPoint = TextGUI.Alignment == 'Right' and Vector2.xAxis or Vector2.zero})
			NewTween:Play()
			NewTween.Completed:Once(function(State)
				if State == Enum.PlaybackState.Completed then
					Tweens[Frame] = nil
				end
			end)
			
			Tweens[Frame] = NewTween
		else
			Frame.AnchorPoint = TextGUI.Alignment == 'Right' and Vector2.xAxis or Vector2.zero
		end

		Sort()
		UpdateYPositions()
		UpdateCorners()
	end

	function TextGUI:AddModule(ModuleName, ExtraText)
		local ExistingModule = Children:FindFirstChild(ModuleName)
		if ExistingModule then
			local Tween = Tweens[ExistingModule]
			if Tween and Tween.Closing then
				Tween.Closing = false

				local Tab = {
					Frame = ExistingModule,
					Name = ModuleName,
					ExtraText = ExtraText
				}

				table.insert(Modules, Tab)

				Sort()

				TweenModule(ExistingModule)
			end
		else
			local Frame = Instance.new("Frame")

			local Tab = {
				Frame = Frame,
				Name = ModuleName,
				ExtraText = ExtraText
			}

			table.insert(Modules, Tab)

			Sort()

			local Index = Find(Frame)

			local Text, RichText = GetFullText(Tab)
			local Width = (GetTextBounds(Text, 16, TextGUI.Font).X * TextGUI.Scale) + TextGUI.RightPadding + TextGUI.LeftPadding
			local Height = 20 * TextGUI.Scale
            local Size = UDim2.fromOffset(Width, Height)
			local Position = UDim2.new(TextGUI.Alignment == 'Right' and 1 or 0, 0, 0, (Height + TextGUI.Spacing) * (Index - 1))
			local AnchorPoint

			if TextGUI.AnimationEnabled then
				AnchorPoint = TextGUI.Alignment == 'Right' and Vector2.zero or Vector2.xAxis
			else
				AnchorPoint = TextGUI.Alignment == 'Right' and Vector2.xAxis or Vector2.zero
			end

			Frame.BackgroundTransparency = 1
			Frame.Size = Size
			Frame.Position = Position
			Frame.AnchorPoint = AnchorPoint
			Frame.Name = ModuleName

			local TextShadow = Instance.new("TextLabel")
			TextShadow.Name = "TextShadow"
			TextShadow.Size = UDim2.fromScale(1, 1)
			TextShadow.BackgroundColor3 = TextGUI.RGB and TextGUI.RGBBackground and Color3.White or TextGUI.BackgroundColor
			TextShadow.BackgroundTransparency = TextGUI.BackgroundEnabled and TextGUI.BackgroundTransparency or 1
			TextShadow.BorderSizePixel = 0
			TextShadow.TextColor3 = GetColor('Text/Shadow')
			TextShadow.FontFace = TextGUI.Font
			TextShadow.TextSize = 16 * TextGUI.Scale
			TextShadow.Text = Text
			TextShadow.TextXAlignment = Enum.TextXAlignment[TextGUI.Alignment]
			TextShadow.Parent = Frame

			local Padding = Instance.new('UIPadding')
			if TextGUI.Alignment == 'Right' then
				Padding.PaddingRight = UDim.new(0, TextGUI.RightPadding)
			else
				Padding.PaddingLeft = UDim.new(0, TextGUI.RightPadding)
			end
			Padding.Parent = TextShadow

			local Corner = Instance.new('UICorner')
			Corner.CornerRadius = UDim.zero
			Corner.Parent = TextShadow

			local Gradient = Instance.new('UIGradient')
			Gradient.Rotation = 90
			Gradient.Enabled = TextGUI.RGB and TextGUI.RGBBackground
			Gradient.Parent = TextShadow

			local TextLabel = Instance.fromExisting(TextShadow)
			TextLabel.Name = "TextLabel"
			TextLabel.TextColor3 = TextGUI.TextColor
			TextLabel.Position = UDim2.fromOffset(-TextGUI.OutlineOffset, -TextGUI.OutlineOffset)
			TextLabel.BackgroundTransparency = 1
			TextLabel.Text = RichText or Text
			TextLabel.RichText = true
			TextLabel.Parent = TextShadow

			local Bar = Instance.new("Frame")
			Bar.Name = "Bar"
			Bar.BorderSizePixel = 0
			Bar.BackgroundColor3 = TextGUI.RGB and TextGUI.RGBBar and Color3.White or TextGUI.BarColor
			Bar.Size = UDim2.fromOffset(TextGUI.BarThickness, Height)
			Bar.Position = UDim2.fromScale(TextGUI.Alignment == 'Right' and 1 or 0, 0)
			Bar.AnchorPoint = TextGUI.Alignment == 'Right' and Vector2.xAxis or Vector2.zero
			Bar.Visible = TextGUI.BarEnabled
			Bar.Parent = Frame

			local BarCorner = Instance.new('UICorner')
			BarCorner.CornerRadius = UDim.zero
			BarCorner.Parent = Bar

			local Gradient2 = Instance.new('UIGradient')
			Gradient2.Rotation = 90
			Gradient2.Enabled = TextGUI.RGB and TextGUI.RGBBar
			Gradient2.Parent = Bar
			
			Frame.Parent = Children

			TweenModule(Frame, Size)
		end
	end

	function TextGUI:RemoveModule(ModuleName)
		local ExistingModule = Children:FindFirstChild(ModuleName)
		if ExistingModule then
			if TextGUI.AnimationEnabled then
				local Tab = {}
				Tab.Closing = true
				Tab.Tween = TweenService:Create(ExistingModule, Info, {AnchorPoint = TextGUI.Alignment == 'Right' and Vector2.zero or Vector2.xAxis})
				Tab.Tween:Play()
				Tab.Tween.Completed:Once(function(State)
					if State == Enum.PlaybackState.Completed then
						Tweens[ExistingModule] = nil
						ExistingModule:Destroy()
					end
				end)

				Tweens[ExistingModule] = Tab
			else
				ExistingModule.AnchorPoint = TextGUI.Alignment == 'Right' and Vector2.zero or Vector2.xAxis
				ExistingModule:Destroy()
			end

			local Index = Find(ExistingModule)
			if Index then
				table.remove(Modules, Index)
			end

			UpdateYPositions()
			UpdateCorners()
		end
	end

	function TextGUI:SetWatermarkFont(Font)
		self.WatermarkFont = Font
		WatermarkShadow.FontFace = Font
		Watermark.FontFace = Font

		local Width = math.max(GetTextBounds(TextGUI.Text, 24, TextGUI.Font).X, 300)
		local Height = 32 * TextGUI.Scale
		
		WatermarkShadow.Size = UDim2.fromOffset(Width, Height)
	end

	function TextGUI:SetFont(Font)
		self.Font = Font
		for i, Module in Modules do
			local Text = GetFullText(Module)
			local Width = (GetTextBounds(Text, 16, TextGUI.Font).X * TextGUI.Scale) + TextGUI.RightPadding + TextGUI.LeftPadding
			Module.Frame.Size = UDim2.fromOffset(Width, 20 * TextGUI.Scale)
			Module.Frame.TextShadow.FontFace = Font
			Module.Frame.TextShadow.TextLabel.FontFace = Font
		end

		Sort()
		UpdateYPositions()
		UpdateCorners()
	end

	function TextGUI:SetAnimationEnabled(Enabled)
		self.AnimationEnabled = Enabled
	end

	function TextGUI:SetAnimationDuration(Duration)
		self.Duration = Duration
		Info = TweenInfo.new(Duration, Info.EasingStyle, Info.EasingDirection)
	end

	function TextGUI:SetWatermarkEnabled(Enabled)
		self.WatermarkEnabled = Enabled
		WatermarkShadow.Visible = Enabled
	end

	function TextGUI:SetImageEnabled(Enabled)
		self.ImageEnabled = Enabled
		Image.Visible = Enabled
	end

	function TextGUI:SetImage(Asset)
		self.Image = Asset
		Image.Image = Asset
	end

	function TextGUI:SetImageWidth(Width)
		self.ImageWidth = Width
		Image.Size = UDim2.fromOffset(Width, Image.Size.Y.Offset)
	end

	function TextGUI:SetImageHeight(Height)
		self.ImageHeight = Height
		Image.Size = UDim2.fromOffset(Image.Size.X.Offset, Height)
	end

	function TextGUI:SetImageOrder(Order)
		self.ImageOrder = Order
		Image.LayoutOrder = Order
	end

	function TextGUI:SetImageAlignment(Alignment)
		self.ImageAlignment = Alignment
		Layout.HorizontalAlignment = Enum.HorizontalAlignment[Alignment]
	end

	function TextGUI:SetLayoutPadding(Padding)
		self.LayoutPadding = Padding
		Layout.Padding = UDim.new(0, Padding)
	end

	function TextGUI:SetImageRectEnabled(Enabled)
		self.ImageRectEnabled = Enabled

		if Enabled then
			Image.ImageRectOffset = Vector2.new(self.ImageRectOffsetX, self.ImageRectOffsetY)
			Image.ImageRectSize = Vector2.new(self.ImageRectSizeX, self.ImageRectSizeY)
		else
			Image.ImageRectOffset = Vector2.zero
			Image.ImageRectSize = Vector2.zero
		end
	end

	function TextGUI:SetImageRectOffsetX(X)
		self.ImageRectOffsetX = X
		if self.ImageRectEnabled then
			Image.ImageRectOffset = Vector2.new(X, self.ImageRectOffsetY)
		end
	end

	function TextGUI:SetImageRectOffsetY(Y)
		self.ImageRectOffsetY = Y
		if self.ImageRectEnabled then
			Image.ImageRectOffset = Vector2.new(self.ImageRectOffsetX, Y)
		end
	end

	function TextGUI:SetImageRectSizeX(X)
		self.ImageRectSizeX = X
		if self.ImageRectEnabled then
			Image.ImageRectSize = Vector2.new(X, self.ImageRectSizeY)
		end
	end

	function TextGUI:SetImageRectSizeY(Y)
		self.ImageRectSizeY = Y
		if self.ImageRectEnabled then
			Image.ImageRectSize = Vector2.new(self.ImageRectSizeX, Y)
		end
	end

	function TextGUI:SetOutlineOffset(Offset)
		Watermark.Position = UDim2.fromOffset(-TextGUI.OutlineOffset, -TextGUI.OutlineOffset)
		TextGUI.OutlineOffset = Offset

		for i, Module in Modules do
			Module.Frame.TextShadow.TextLabel.Position = UDim2.fromOffset(-TextGUI.OutlineOffset, -TextGUI.OutlineOffset)
		end
	end

	function TextGUI:SetBarThickness(Thickness)
		TextGUI.BarThickness = Thickness
		UpdateBarThickness()
	end

	function TextGUI:SetCornerRadius(CornerRadius)
		TextGUI.CornerRadius = CornerRadius
		UpdateCorners()
	end

	function TextGUI:UpdateExtraText(Module)
		if Module then
			local FoundModule = Children:FindFirstChild(Module)
			if FoundModule then
				local _, Tab = Find(FoundModule)
				if Tab then
					UpdateExtraText(Tab)
				end
			end
		else
			for _, v in Modules do
				UpdateExtraText(v)
			end
		end

		Sort()
		UpdateYPositions()
		UpdateCorners()
	end

	local LastSize = TopBar.Size
	
	function TextGUI:SetScale(Scale)
		TextGUI.Scale = Scale
		local WatermarkWidth = math.max(GetTextBounds(TextGUI.Text, 24 * Scale, TextGUI.WatermarkFont).X, 300)
		local WatermarkSize = UDim2.fromOffset(WatermarkWidth, 32 * Scale)
		TopBar.Size = WatermarkSize
		WatermarkShadow.Size = WatermarkSize
		WatermarkShadow.TextSize = 24 * TextGUI.Scale
		Watermark.TextSize = 24 * TextGUI.Scale

		for i, Module in Modules do
			local Text = GetFullText(Module)
			local Width = GetTextBounds(Text, 16 * Scale, TextGUI.Font).X
			local Height = 20 * Scale
			local ModuleSize = UDim2.fromOffset(Width + TextGUI.RightPadding + TextGUI.LeftPadding, Height)
			Module.Frame.Size = ModuleSize
			Module.Frame.TextShadow.TextSize = 16 * Scale
			Module.Frame.TextShadow.TextLabel.TextSize = 16 * Scale
			Module.Frame.Position = UDim2.fromOffset(TextGUI.Alignment == 'Right' and WatermarkSize.X.Offset or 0, (Height + TextGUI.Spacing) * (i - 1))
			Module.Frame.Bar.Size = UDim2.fromOffset(TextGUI.BarThickness, Height)
		end

		local Diff = TopBar.Size - LastSize
		
		TopBar.Position -= UDim2.new(Diff.X.Scale / 2, Diff.X.Offset / 2, Diff.Y.Scale / 2, Diff.Y.Offset / 2)
		LastSize = TopBar.Size

		Sort()
		UpdateYPositions()
		UpdateCorners()
	end

	function TextGUI:SetWatermarkText(Text)
		TextGUI.Text = Text
		local Width = math.max(GetTextBounds(Text, 24, TextGUI.WatermarkFont).X * TextGUI.Scale, 300)
		local TextBounds = UDim2.fromOffset(Width, 32 * TextGUI.Scale)
		WatermarkShadow.Size = TextBounds

		if TextGUI.TextShadow then
			WatermarkShadow.Text = RemoveTags(Text)
			Watermark.Text = Text
		else
			WatermarkShadow.Text = Text
		end
	end

	function TextGUI:SetWatermarkTextShadowEnabled(Enabled)
		TextGUI.TextShadow = Enabled
		Watermark.Visible = Enabled
		WatermarkShadow.RichText = not Enabled
		WatermarkShadow.TextColor3 = Enabled and GetColor('Text/Shadow') or TextGUI.WatermarkTextColor
	end

	function TextGUI:SetSpacing(Spacing)
		TextGUI.Spacing = Spacing
		UpdateYPositions(true)
	end

	function TextGUI:SetRightPadding(Padding)
		TextGUI.RightPadding = Padding

		for i, Module in Modules do
			local Text = GetFullText(Module)
			local Height = 20 * TextGUI.Scale
			local Width = (GetTextBounds(Text, 16, TextGUI.Font).X * TextGUI.Scale) + TextGUI.RightPadding + TextGUI.LeftPadding
			local Size = UDim2.fromOffset(Width, Height)
			Module.Frame.Size = Size
			SetPadding(Module.Frame.TextShadow.UIPadding)
		end
	end

	function TextGUI:SetLeftPadding(Padding)
		TextGUI.LeftPadding = Padding

		for i, Module in Modules do
			local Text = GetFullText(Module)
			local Height = 20 * TextGUI.Scale
			local Width = (GetTextBounds(Text, 16, TextGUI.Font).X * TextGUI.Scale) + TextGUI.RightPadding + TextGUI.LeftPadding
			local Size = UDim2.fromOffset(Width, Height)
			Module.Frame.Size = Size
			Module.Frame.TextShadow.UIPadding[`Padding{TextGUI.Alignment == 'Right' and 'Left' or 'Right'}`] = UDim.new(0, TextGUI.RightPadding)
			Module.Frame.TextShadow.UIPadding[`Padding{TextGUI.Alignment}`] = UDim.new(0, TextGUI.RightPadding)
		end
	end

	function TextGUI:SetAlignment(Alignment)
		TextGUI.Alignment = Alignment
        WatermarkShadow.TextXAlignment = Enum.TextXAlignment[Alignment]
        Watermark.TextXAlignment = WatermarkShadow.TextXAlignment
		WatermarkShadowPadding.PaddingRight = UDim.zero
		WatermarkShadowPadding.PaddingLeft = UDim.zero

		if Alignment == 'Left' then
			WatermarkShadowPadding.PaddingLeft = UDim.new(0, 5)
		elseif Alignment == 'Right' then
			WatermarkShadowPadding.PaddingRight = UDim.new(0, 5)
		end

		for i, Module in Modules do
			local Height = (20 * TextGUI.Scale)
			local FrameX = Alignment == 'Right' and TopBar.Size.X.Offset or 0
			local FrameY = (Height + TextGUI.Spacing) * (i - 1)
			local AnchorPoint = Alignment == 'Right' and Vector2.xAxis or Vector2.zero

			Module.Frame.Position = UDim2.fromOffset(FrameX, FrameY)
			Module.Frame.AnchorPoint = AnchorPoint
			Module.Frame.Bar.Position = UDim2.fromScale(Alignment == 'Right' and 1 or 0, 0)
			Module.Frame.Bar.AnchorPoint = AnchorPoint
			Module.Frame.TextShadow.TextXAlignment = Enum.TextXAlignment[Alignment]
			Module.Frame.TextShadow.TextLabel.TextXAlignment = Enum.TextXAlignment[Alignment]

			SetPadding(Module.Frame.TextShadow.UIPadding)
		end

		UpdateCorners()
	end

	function TextGUI:SetBackgroundEnabled(Enabled)
		TextGUI.BackgroundEnabled = Enabled
		for _, v in Modules do
			v.Frame.TextShadow.BackgroundTransparency = Enabled and TextGUI.BackgroundTransparency or 1
		end
	end

	function TextGUI:SetBackgroundTransparency(Transparency)
		TextGUI.BackgroundTransparency = Transparency
		for _, v in Modules do
			v.Frame.TextShadow.BackgroundTransparency = TextGUI.BackgroundEnabled and Transparency or 1
		end
	end

	function TextGUI:SetBarEnabled(Enabled)
		TextGUI.BarEnabled = Enabled
		for _, v in Modules do
			v.Frame.Bar.Visible = Enabled
		end
	end

	function TextGUI:SetBarColor(Color)
		TextGUI.BarColor = Color
		if TextGUI.RGB and TextGUI.RGBBar then return end
		for _, v in Modules do
			v.Frame.Bar.BackgroundColor3 = Color
		end
	end

	function TextGUI:SetBackgroundColor(Color)
		TextGUI.BackgroundColor = Color
		if TextGUI.RGB and TextGUI.RGBBackground then return end
		for _, v in Modules do
			v.Frame.TextShadow.BackgroundColor3 = Color
		end
	end

	function TextGUI:SetTextColor(Color)
		TextGUI.TextColor = Color
		if TextGUI.RGB and TextGUI.RGBText then return end
		for _, v in Modules do
			v.Frame.TextShadow.TextLabel.TextColor3 = Color
		end
	end

	function TextGUI:SetWatermarkTextColor(Color)
		TextGUI.WatermarkTextColor = Color
		if TextGUI.RGB and TextGUI.RGBWatermark then return end
		Watermark.TextColor3 = Color
	end

	function TextGUI:SetRGBImageEnabled(Enabled)
		TextGUI.RGBImage = Enabled
		ImageGradient.Enabled = Enabled and TextGUI.RGB and TextGUI.RGBGradient
	end

	function TextGUI:SetSortingMethod(Method)
		TextGUI.Sorting = Method
		Sort()
		UpdateYPositions(true)
		UpdateCorners()
	end

	local Thread

	function TextGUI:SetRGBEnabled(Enabled)
		TextGUI.RGB = Enabled
		if Thread then
			pcall(task.cancel, Thread)
			Thread = nil
		end

		for _, Module in Modules do
			Module.Frame.TextShadow.UIGradient.Enabled = Enabled and TextGUI.RGBBackground and TextGUI.RGBGradient
			Module.Frame.TextShadow.BackgroundColor3 = Enabled and TextGUI.RGBBackground and TextGUI.RGBGradient and Color3.White or TextGUI.BackgroundColor
			Module.Frame.Bar.UIGradient.Enabled = Enabled and TextGUI.RGBBar and TextGUI.RGBGradient
			Module.Frame.Bar.BackgroundColor3 = Enabled and TextGUI.RGBBar and TextGUI.RGBGradient and Color3.White or TextGUI.BarColor
		end

		WatermarkGradient.Enabled = Enabled and TextGUI.RGBWatermark and TextGUI.RGBGradient
		Watermark.TextColor3 = Enabled and TextGUI.RGBWatermark and TextGUI.RGBGradient and Color3.White or TextGUI.WatermarkTextColor
		ImageGradient.Enabled = Enabled and TextGUI.RGBImage and TextGUI.RGBGradient

		if Enabled then
			Thread = task.spawn(function()
				while TextGUI.RGB do
					local Len = #Modules
					if Len == 0 then
						task.wait()
						continue
					end

					local Tick = (os.clock() * (TextGUI.RGBSpeed / 5)) % 1
					local Spread = TextGUI.RGBSpread * 5
					local Down = TextGUI.RGBDirection == 'Down'
					local IndexOffset = 0

					if TextGUI.RGBWatermark then
						Len += 1
						IndexOffset += 1
						local Alpha = (IndexOffset / Len) / Spread
						local Hue = (Tick - (Down and Alpha or -Alpha)) % 1

						local Sat = TextGUI.RGBWatermarkSaturation
						local Val = TextGUI.RGBWatermarkSaturation

						local Color = Color3.fromHSV(Hue, Sat, Val)
						
						if TextGUI.RGBGradient then
							local NextOffset = ((IndexOffset + 1) / Len) / Spread
							local NextHue = (Tick - (Down and NextOffset or -NextOffset)) % 1
							local GoalColor = Color3.fromHSV(NextHue, Sat, Val)
							WatermarkGradient.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color),
								ColorSequenceKeypoint.new(1, GoalColor)
							})
						else
							Watermark.TextColor3 = Color
						end
					end

					if TextGUI.RGBImage then
						Len += 1
						IndexOffset += 1

						local Alpha = (IndexOffset / Len) / Spread
						local Hue = (Tick - (Down and Alpha or -Alpha)) % 1

						local Sat = TextGUI.RGBWatermarkSaturation
						local Val = TextGUI.RGBWatermarkSaturation

						local Color = Color3.fromHSV(Hue, Sat, Val)
						
						if TextGUI.RGBGradient then
							local NextOffset = (2 / Len) / Spread
							local NextHue = (Tick - (Down and NextOffset or -NextOffset)) % 1
							local GoalColor = Color3.fromHSV(NextHue, Sat, Val)
							ImageGradient.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color),
								ColorSequenceKeypoint.new(1, GoalColor)
							})
						else
							Image.ImageColor3 = Color
						end
					end

					for i, Module in Modules do
						i += IndexOffset
						if Module.Frame.Parent == nil then continue end
						local Offset = (i / Len) / Spread
						local Hue = (Tick - (Down and Offset or -Offset)) % 1
						
						if TextGUI.RGBText then
							Module.Frame.TextShadow.TextLabel.TextColor3 = Color3.fromHSV(Hue, TextGUI.RGBTextSaturation, TextGUI.RGBTextValue)
						end
						if TextGUI.RGBBackground or TextGUI.RGBBar then
							local NextOffset = ((i + 1) / Len) / Spread
							local NextHue = (Tick - (Down and NextOffset or -NextOffset)) % 1

							if TextGUI.RGBBackground then
								local BackgroundSaturation = TextGUI.RGBBackgroundSaturation
								local BackgroundValue = TextGUI.RGBBackgroundValue

								if TextGUI.RGBGradient then
									local Color = Color3.fromHSV(Hue, BackgroundSaturation, BackgroundValue)
									local GoalColor = Color3.fromHSV(NextHue, BackgroundSaturation, BackgroundValue)

									Module.Frame.TextShadow.UIGradient.Color = ColorSequence.new({
										ColorSequenceKeypoint.new(0, Color),
										ColorSequenceKeypoint.new(1, GoalColor)
									})
								else
									Module.Frame.TextShadow.BackgroundColor3 = Color3.fromHSV(Hue, BackgroundSaturation, BackgroundValue)
								end
							end
							if TextGUI.RGBBar then
								local BarSaturation = TextGUI.RGBBarSaturation
								local BarValue = TextGUI.RGBBarValue
								if TextGUI.RGBGradient then
									local Color = Color3.fromHSV(Hue, BarSaturation, BarValue)
									local GoalColor = Color3.fromHSV(NextHue, BarSaturation, BarValue)

									Module.Frame.Bar.UIGradient.Color = ColorSequence.new({
										ColorSequenceKeypoint.new(0, Color),
										ColorSequenceKeypoint.new(1, GoalColor)
									})
								else
									Module.Frame.Bar.BackgroundColor3 = Color3.fromHSV(Hue, BarSaturation, BarValue)
								end
							end
						end
					end

					task.wait(1 / TextGUI.RGBRefreshRate)
				end
			end)
		else
			TextGUI:SetTextColor(TextGUI.TextColor)
			TextGUI:SetBackgroundColor(TextGUI.BackgroundColor)
			TextGUI:SetBarColor(TextGUI.BarColor)
		end
	end

	Gui:Clean(function()
		if Thread then
			pcall(task.cancel, Thread)
			Thread = nil
		end
	end)

	function TextGUI:SetRGBTextEnabled(Enabled)
		TextGUI.RGBText = Enabled
		if TextGUI.RGB and not Enabled then
			for _, Module in Modules do
				Module.Frame.TextShadow.TextLabel.TextColor3 = TextGUI.TextColor
			end
		end
	end

	function TextGUI:SetRGBSpeed(Speed)
		TextGUI.RGBSpeed = Speed
	end

	function TextGUI:SetRGBSpread(Speed)
		TextGUI.RGBSpread = Speed
	end

	function TextGUI:SetRGBDirection(Direction)
		TextGUI.RGBDirection = Direction
	end

	function TextGUI:SetRGBRefreshRate(Rate)
		TextGUI.RGBRefreshRate = Rate
	end

	function TextGUI:SetRGBBackgroundEnabled(Enabled)
		TextGUI.RGBBackground = Enabled
		for i, Module in Modules do
			Module.Frame.TextShadow.UIGradient.Enabled = Enabled and TextGUI.RGB
			Module.Frame.TextShadow.BackgroundColor3 = Enabled and TextGUI.RGB and Color3.White or TextGUI.BackgroundColor
		end
	end

	function TextGUI:SetRGBTextSaturation(Saturation)
		TextGUI.RGBTextSaturation = Saturation
	end

	function TextGUI:SetRGBTextValue(Value)
		TextGUI.RGBTextValue = Value
	end

	function TextGUI:SetRGBBackgroundSaturation(Saturation)
		TextGUI.RGBBackgroundSaturation = Saturation
	end

	function TextGUI:SetRGBBackgroundValue(Value)
		TextGUI.RGBBackgroundValue = Value
	end

	function TextGUI:SetRGBBarEnabled(Enabled)
		TextGUI.RGBBar = Enabled
		for i, Module in Modules do
			Module.Frame.Bar.UIGradient.Enabled = Enabled and TextGUI.RGB
			Module.Frame.Bar.BackgroundColor3 = Enabled and TextGUI.RGB and Color3.White or TextGUI.BarColor
		end
	end

	function TextGUI:SetRGBBarSaturation(Saturation)
		TextGUI.RGBBarSaturation = Saturation
	end

	function TextGUI:SetRGBBarValue(Value)
		TextGUI.RGBarValue = Value
	end

	function TextGUI:SetRGBWatermarkEnabled(Enabled)
		TextGUI.RGBWatermark = Enabled
		Watermark.Text = Enabled and `Tidal Wave v{Gui.CurrentVersion}` or TextGUI.Text
		WatermarkGradient.Enabled = Enabled and TextGUI.RGB and TextGUI.RGBGradient
		Watermark.TextColor3 = Enabled and TextGUI.RGB and TextGUI.RGBGradient and Color3.White or TextGUI.WatermarkTextColor
	end

	function TextGUI:SetRGBWatermarkSaturation(Sat)
		TextGUI.RGBWatermarkSaturation = Sat
	end

	function TextGUI:SetRGBWatermarkValue(Value)
		TextGUI.RGBwatermarkValue = Value
	end

	function TextGUI:SetRGBGradientEnabled(Enabled)
		TextGUI.RGBGradient = Enabled
		for _, Module in Modules do
			Module.Frame.TextShadow.UIGradient.Enabled = Enabled and TextGUI.RGB and TextGUI.RGBBackground
			Module.Frame.TextShadow.BackgroundColor3 = Enabled and TextGUI.RGB and TextGUI.RGBBackground and Color3.White or TextGUI.BackgroundColor
			Module.Frame.Bar.UIGradient.Enabled = Enabled and TextGUI.RGB and TextGUI.RGBBar
			Module.Frame.Bar.BackgroundColor3 = Enabled and TextGUI.RGB and TextGUI.RGBBar and Color3.White or TextGUI.BarColor
		end
		WatermarkGradient.Enabled = Enabled and TextGUI.RGB and TextGUI.RGBWatermark
		Watermark.TextColor3 = Enabled and TextGUI.RGB and TextGUI.RGBWatermark and Color3.White or TextGUI.WatermarkTextColor
		ImageGradient.Enabled = Enabled and TextGUI.RGB and TextGUI.RGBImage
	end
end)

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

function Gui:RemoveButton(Button)
	if Gui.Buttons and Gui.Buttons[Button] then
		if Gui.Buttons[Button].Object then
			Gui.Buttons[Button].Object:Destroy()
		end
		LoopClean(Gui.Buttons[Button])
		Gui.Buttons[Button] = nil
	end
end

local CategoryArray = {}

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
				x += i > 10 and (Gui.Categories[CategoryArray[i - 1]].Object.Size.X.Offset + 10) or 0
			elseif i > 1 then
				x += Gui.Categories[CategoryArray[i - 1]].Object.Size.X.Offset + 10
			end
			local Pos = UDim2.fromOffset(x, y)
			CurrentCategory:SetOpenedPosition(Pos)
			if TopBar.Visible and not CurrentCategory:IsMoving() then
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
	local TidalWaveTopBar = TopBar

	local TopBar = Instance.new('TextButton')
	TopBar.Name = `{Properties.Name}Category`
	TopBar.Position = Category.ClosedPosition
	TopBar.Size = UDim2.fromOffset(180, 28)
	TopBar.Text = ''
    TopBar.BackgroundColor3 = GetColor("Main/Accent")
	TopBar.Parent = CategoryHolder
	ListenObject(TopBar, 'Main/Accent')

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 0)
    UICorner.TopLeftRadius = UDim.new(0, 5)
    UICorner.TopRightRadius = UDim.new(0, 5)
    UICorner.Parent = TopBar

    local NameLabel = Instance.new("TextLabel")
	NameLabel.Name = 'Title'
    NameLabel.Text = Properties.Name
	NameLabel.TextColor3 = GetColor('Text/Primary')
	NameLabel.FontFace = GetFont('Medium')
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	NameLabel.TextSize = 20
	NameLabel.BackgroundTransparency = 1
    NameLabel.Size = UDim2.fromScale(1, 1)
	NameLabel.Position = UDim2.fromOffset(10, 0)
    NameLabel.Parent = TopBar
	ListenObject(NameLabel, 'Text/Primary')
	ListenFont(NameLabel, 'Medium')

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
	ListenObject(ScrollingFrame, 'Background/Primary')

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
	Arrow.Text = ''
	Arrow.Parent = TopBar

	local ArrowImage = Instance.new("ImageLabel")
	ArrowImage.Name = "Image"
	ArrowImage.Size = UDim2.fromOffset(24, 24)
	ArrowImage.Position = UDim2.fromOffset(2, 2)
	ArrowImage.BackgroundTransparency = 1
	SetIcon(ArrowImage, "chevron-down")
	ArrowImage.Parent = Arrow
	ListenObject(ArrowImage, 'Main/Icons')

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
        if Gui.CategoryAnimations then
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
					TidalWaveTopBar.Visible = true
				end
				OpenTween = TweenService:Create(TopBar, Info, {Position = self.OpenedPosition})
				OpenTween:Play()
				OpenTween.Completed:Once(function()
					OpenTween = nil
				end)
			end
		else
            Modal.Visible = Visible
            TidalWaveTopBar.Visible = Visible
			TopBar.Position = Visible and self.OpenedPosition or self.ClosedPosition
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
			ExtraText = Properties.ExtraText,
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
		AddTooltip(Button, Properties.Info or Properties.Tooltip, true)
		AddHighlight(Button, nil, true)
		AddMaid(Module)
		AddInstanceTable(Module)
		ListenObject(Button, 'Background/Button', 'Text/Primary')
		ListenFont(Button, 'Regular')

		local EnabledBar = Instance.new("Frame")
		EnabledBar.Name = "Enabled"
		EnabledBar.BackgroundColor3 = GetColor('Main/DisabledBar')
		EnabledBar.Size = UDim2.fromOffset(2, 20)
		EnabledBar.Position = UDim2.new(1, -6, 0, 3)
		EnabledBar.BorderSizePixel = 0
		EnabledBar.Parent = Button
		ListenObject(EnabledBar, 'Main/EnabledBar', 'Main/DisabledBar', function()
			EnabledBar.BackgroundColor3 = Module.Enabled and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
		end)

		local TextBounds = GetTextBounds(` {Properties.Name}`, 17, Button.FontFace).X + 20

		if TextBounds > TopBar.Size.X.Offset then
			TopBar.Size = UDim2.fromOffset(TextBounds, 28)
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
            ListenObject(Background, 'Background/Button')

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
			ListenObject(KeybindName, 'Text/Primary')
			ListenFont(KeybindName, 'Regular')

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
            AddHighlight(BindButton, 'Background/Secondary')
            AddTooltip(BindButton, "Click to bind")
			ListenObject(BindButton, 'Background/Secondary', 'Text/Primary')
			ListenFont(BindButton, 'Regular')

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
			ListenObject(DeleteKeybind, 'Background/Button')

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
            AddHighlight(Hold, 'Background/Secondary')
            AddTooltip(Hold, `Toggles off the module when releasing the keybind`)
			ListenObject(Hold, 'Background/Secondary', 'Text/Primary')
			ListenFont(Hold, 'Regular')

            local EnabledBar = Instance.new("Frame")
            EnabledBar.Name = "Enabled"
            EnabledBar.BackgroundColor3 = Module.Hold and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
            EnabledBar.Size = UDim2.fromOffset(2, 24)
            EnabledBar.Position = UDim2.new(1, -8, 0, 3)
            EnabledBar.BorderSizePixel = 0
            EnabledBar.Parent = Hold
			ListenObject(EnabledBar, 'Main/EnabledBar', 'Main/DisabledBar', function()
				EnabledBar.BackgroundColor3 = Module.Hold and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
			end)

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
					Title = 'Module Toggled',
					Text = `{Properties.Name} has been <font color = '#{Color}'>{Toggled}</font>`,
					Duration = Gui.ModuleToggledNotificationDuration,
				})
			end

            TweenEnabledBar(EnabledBar, self.Enabled)

			if self.Enabled then
				TextGUI:AddModule(Properties.Name, self.ExtraText)
                if Properties.Enabled then
                    task.spawn(Properties.Enabled)
                end
			else
				TextGUI:RemoveModule(Properties.Name)
				self:DisconnectAll()
				self:ClearInstances()
			end
            if Properties.Function then
				task.spawn(Properties.Function, self.Enabled)
			end
		end

		function Module:UpdateTextGUI()
			TextGUI:UpdateExtraText(Properties.Name)
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
                v.Object.Visible = if v.Visible ~= nil then v.Visible else true
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
		AddTooltip(TextButton, Properties.Info or Properties.Tooltip, true)
		AddHighlight(TextButton, nil, true)
		ListenObject(TextButton, 'Background/Button', 'Text/Primary')
		ListenFont(TextButton, 'Regular')

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
			ListenObject(Background, 'Background/Button')

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
			ListenObject(KeybindName, 'Text/Primary')
			ListenFont(KeybindName, 'Regular')

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
            AddHighlight(BindButton, 'Background/Secondary')
            AddTooltip(BindButton, "Click to bind")
			ListenObject(BindButton, 'Background/Secondary', 'Text/Primary')
			ListenFont(BindButton, 'Regular')

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
			ListenObject(DeleteKeybind, 'Background/Button')

            local DeleteKeybindImage = Instance.new("ImageLabel")
            DeleteKeybindImage.Name = "Image"
            DeleteKeybindImage.BackgroundTransparency = 1
            DeleteKeybindImage.Size = UDim2.fromOffset(24, 24)
            DeleteKeybindImage.Position = UDim2.fromOffset(8, 8)
            SetIcon(DeleteKeybindImage, "x")
            DeleteKeybindImage.Parent = DeleteKeybind
			ListenObject(DeleteKeybindImage, 'Main/Icons')

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
    Info = "Keeps TidalWave opened when teleporting through games",
    Enabled = function()
        if not queueonteleport then NotifyPoopSploit("queueonteleport") return end
        local TeleportCheck = false
        KeepOnTeleport:Clean(Plr.OnTeleport:Connect(function()
            if TeleportCheck then return end
            TeleportCheck = true
            local Code
            if shared.TidalWaveDev then
                Code = 'shared.TidalWaveDev = true\nloadfile("TidalWave/Loader.lua")()'
            else
                Code = 'loadstring(game:HttpGet(`https://raw.githubusercontent.com/fluidnarrator30/Tidal-Wave/{readfile("TidalWave/Profiles/Commit.txt")}/Loader.lua`, true))()'
            end
            queueonteleport(Code)
        end))
    end
})

local AllowMouseBinding = ConfigMenu:CreateToggle({
    Name = "Allow Mouse Binding",
    Info = "Allows you to bind modules to mouse buttons",
	Function = function()
		table.clear(Gui.PressedKeys)
	end
})

local MenuKeybind = ConfigMenu:CreateKeybind({
	Name = 'Menu',
	Keybind = 'RightShift',
	Secondary = true
})

ConfigMenu:CreateToggle({
	Name = 'Use Team Color',
	Info = 'Uses the TeamColor property on players for visual modules',
	Default = true,
	Function = function()
		if Gui.Libraries and Gui.Libraries.EntityLib then
			Gui.Libraries.EntityLib:Refresh()
		end
	end
})

local ReloadButton = ConfigMenu:CreateButton({
	Name = "Reload",
	Function = function()
		task.defer(function()
			local Dev = shared.TidalWaveDev
			Gui:Shutdown()
			if IsStudio then
				script.Parent.Parent.Enabled = false
				script.Parent.Parent.Enabled = true
			else
				if Dev then
					shared.TidalWaveDev = true
					loadfile('TidalWave/Loader.lua')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/fluidnarrator30/Tidal-Wave/main/Loader.lua', true))()
				end
			end
		end)
	end,
})

ConfigMenu:CreateButton({
	Name = "Close",
	Function = function()
		task.defer(Gui.Shutdown)
	end
})

local GuiMenu = Gui:CreateMenu({
	Name = "GUI",
})

GuiMenu:CreateButton({
	Name = 'Sort Categories',
	Function = UpdateCategoryPositions
})

GuiMenu:CreateOption({
    Name = "Category Animations",
    Default = true,
    Function = function(Enabled)
        Gui.CategoryAnimations = Enabled
    end
})

GuiMenu:CreateToggle({
	Name = 'Auto-Scale Gui',
	Default = true,
	Function = function(Enabled)
		Gui.Scale = Enabled
		UIScale.Scale = Enabled and math.max(ScreenGui.AbsoluteSize.X / 1920, 0.6) or 1
	end
})

GuiMenu:CreateSlider({
	Name = 'Module Text Size',
	Default = 17,
	Min = 6,
	Max = 24,
	Function = function(Val)
		for i, Module in Gui.Modules do
			Module.Object.TextSize = Val
		end
		for i, Button in Gui.Buttons do
			Button.Object.TextSize = Val
		end
	end
})

GuiMenu:CreateFont({
	Name = 'Regular Font',
	Default = 'Montserrat',
	Weight = 'Regular',
	Function = function(Font)
		SetFont('Regular', Font)
	end
})

GuiMenu:CreateFont({
	Name = 'Medium Font',
	Default = 'Montserrat',
	Weight = 'Medium',
	Function = function(Font)
		SetFont('Medium', Font)
	end
})

GuiMenu:CreateFont({
	Name = 'Bold Font',
	Default = 'Montserrat',
	Weight = 'Bold',
	Function = function(Font)
		SetFont('Bold', Font)
	end
})

local ThemesDropdown

Run(function()
	function GuiMenu:CreateThemesDropdown(Properties)
        local Dropdown = {
			Value = Properties.List[1],
            List = Properties.List,
			Visible = if Properties.Visible ~= nil then Properties.Visible else true,
            Expanded = false
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
		ListenObject(Background, 'Background/Button')

		local TextLabel = Instance.new("TextLabel")
		TextLabel.TextColor3 = GetColor('Text/Primary')
		TextLabel.BackgroundTransparency = 1
		TextLabel.Size = UDim2.new(0, 200, 1, 0)
		TextLabel.FontFace = GetFont('Regular')
		TextLabel.TextSize = 24
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		TextLabel.Text = ` {Properties.Name}`
		TextLabel.Parent = Background
		ListenObject(TextLabel, 'Text/Primary')
		ListenFont(TextLabel, 'Regular')

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
		ListenObject(TopBarLabel, 'Text/Primary', 'Background/Secondary')
		ListenFont(TopBarLabel, 'Regular')

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
		ListenObject(ArrowImage, 'Main/Icons')

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
		ListenObject(ResetButton, 'Background/Button')

		local ResetButtonImage = Instance.new("ImageLabel")
		ResetButtonImage.Name = "Image"
		ResetButtonImage.BackgroundTransparency = 1
		ResetButtonImage.Size = UDim2.fromOffset(24, 24)
		ResetButtonImage.Position = UDim2.fromOffset(8, 8)
		SetIcon(ResetButtonImage, "rotate-cw")
		ResetButtonImage.Parent = ResetButton
		ListenObject(ResetButtonImage, 'Main/Icons')

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
				table.insert(self.List, Value)
            end
        end

        local PlusButton = Instance.new('TextButton')
        PlusButton.Name = 'Plus'
        PlusButton.BackgroundColor3 = GetColor('Background/Button')
        PlusButton.Text = ''
        PlusButton.BorderSizePixel = 0
        PlusButton.Size = UDim2.fromOffset(32, 32)
        PlusButton.AutoButtonColor = false
        PlusButton.LayoutOrder = 69420
        PlusButton.ZIndex = 2
        PlusButton.Parent = ScrollingFrame
        AddCorner(PlusButton, UDim.new(0, 7))
        AddHighlight(PlusButton)
		ListenObject(PlusButton, 'Background/Button')

        local PlusImage = Instance.new('ImageLabel')
        PlusImage.Name = 'Image'
        PlusImage.BackgroundTransparency = 1
        PlusImage.Size = UDim2.fromOffset(24, 24)
        PlusImage.Position = UDim2.fromOffset(4, 4)
        PlusImage.ZIndex = 2
        SetIcon(PlusImage, "plus")
        PlusImage.Parent = PlusButton
		ListenObject(PlusImage, 'Main/Icons')

        PlusButton.MouseButton1Click:Connect(function()
            Dropdown:CreateButton({
                Name = 'new theme',
				New = true,
                CanDelete = true,
                LayoutOrder = #CreatedButtons + 1,
            })
        end)

        function Dropdown:CreateButton(Properties)
            local Button = Instance.new('TextButton')
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
            AddTooltip(Button, Properties.CanDelete and 'Left Click to select.\nRight Click to rename.' or 'Left Click to select.')
			ListenObject(Button, 'Background/Button', 'Text/Primary')
			ListenFont(Button, 'Regular')

            if Properties.CanDelete then
                local Delete = Instance.new('TextButton')
                Delete.Name = 'Delete'
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
				ListenObject(Image, 'Main/Icons')

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
				ListenObject(RenameTextBox, 'Text/Primary')
				ListenFont(RenameTextBox, 'Regular')

				Delete.MouseButton1Click:Connect(function()
                    Tooltip.Visible = false
                    Dropdown:Remove(Properties.Name)
                    local Index = table.find(CreatedButtons, Button)
                    if Index then
                        table.remove(CreatedButtons, Index)
                    end
					for _, v in {Button, Delete, Image, RenameTextBox} do
						StopListeningObject(v)
					end
                    Button:Destroy()
                    Gui.Themes[Properties.Name] = nil
                    Dropdown:SetValue("TidalWave")
                end)

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

			table.insert(CreatedButtons, Button)
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
							for _, v2 in v:GetDescendants() do
								StopListeningObject(v2)
							end
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
					for _, v2 in v:GetDescendants() do
						StopListeningObject(v2)
					end
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
        Name = 'Theme',
        List = {'TidalWave'},
        Function = function(Val)
            if not Gui.Themes[Val] then
				local NewTheme = table.clone(BuiltInThemes.TidalWave)
				NewTheme.BuiltIn = nil
				Gui.Themes[Val] = NewTheme
            end
            Gui.Theme = Val
            for i, v in ColorPickers do
				local Color, Transparency = GetColor(i)
				if v.Color ~= Color or v.Transparency ~= Transparency then
					v:SetColor(Color, Transparency)
				end
                v:SetVisible(not BuiltInThemes[Val])
            end
        end
    })

    for i, v in BuiltInThemes.TidalWave do
        if i == 'BuiltIn' then continue end
        for i2, v2 in v do
			ColorPickers[`{i}/{i2}`] = GuiMenu:CreateColorPicker({
                Name = i == 'Main' and i2 or `{i} {i2}`,
                Default = v2.Color,
				Transparency = v2.Transparency,
                Visible = false,
                Function = function(Color, Transparency)
                    SetColor(`{i}/{i2}`, Color, Transparency)
                end
            })
        end
    end
	
    local List = {}
    if IsStudio then
        for _, v in script.Parent:GetChildren() do
            table.insert(List, v.Name)
        end
    else
        for _, v in listfiles('TidalWave/Guis') do
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

local DoneButton = Instance.new("TextButton")
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
ListenObject(DoneButton, 'Background/Button', 'Text/Primary')
ListenFont(DoneButton, 'Regular')

local StopEditingHudPositions
local StartEditingHudPositions

Run(function()
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 0)
    Corner.TopLeftRadius = UDim.new(0, 7)
    Corner.TopRightRadius = UDim.new(0, 7)
    Corner.Parent = DoneButton

    local Objects = {}
	local OldProperties = {}
	local EditingPositions = false
	local Con

	StopEditingHudPositions = function()
		if not EditingPositions then return end
		EditingPositions = false

		if Con then
			Con:Disconnect()
			Con = nil
		end

		for Obj, Properties in OldProperties do
			for Property, Value in Properties do
				Obj[Property] = Value
			end
		end
		for _, v in Objects do
			v:Destroy()
		end
		table.clear(Objects)
		table.clear(OldProperties)
		DoneButton.Visible = false
		HudMenu.Object.Visible = true
	end

	StartEditingHudPositions = function()
		if not HudMenu.Object.Visible then return end
		EditingPositions = true
		HudMenu.Object.Visible = false
		for _, v in HudFolder:GetChildren() do
			if v:IsA('GuiObject') then
				OldProperties[v] = {
					Interactable = v.Interactable
				}
				v.Interactable = true

				local DragDetector = Instance.new('UIDragDetector')
				DragDetector.CursorIcon = 'rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png'
				DragDetector.ActivatedCursorIcon = 'rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png'

				if not HudMenu.Options.AllowDraggingOffScreen.Enabled then
					DragDetector.BoundingUI = HudFolder
					DragDetector.BoundingBehavior = Enum.UIDragDetectorBoundingBehavior.EntireObject
				end

				DragDetector.Parent = v

				local ExistingCorner = v:FindFirstChildOfClass('UICorner')
				if ExistingCorner then
					OldProperties[ExistingCorner] = {
						TopLeftRadius = ExistingCorner.TopLeftRadius,
						TopRightRadius = ExistingCorner.TopRightRadius,
						BottomLeftRadius = ExistingCorner.BottomLeftRadius,
						BottomRightRadius = ExistingCorner.BottomRightRadius
					}

					ExistingCorner.CornerRadius = UDim.zero
				end

				local UIStroke = Instance.new('UIStroke')
				UIStroke.Color = Color3.White
				UIStroke.Thickness = 2
				UIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
				UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke.LineJoinMode = Enum.LineJoinMode.Miter
				UIStroke.ZIndex = 69420
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
	Name = 'Edit Positions',
	Function = StartEditingHudPositions
})

Run(function()
    local Notifications = HudMenu:CreateOption({
		Name = 'Notifications',
		Default = true,
        Function = function(Enabled)
            Gui.Notifications = Enabled
        end
	})

	Notifications:CreateDropdown({
		Name = 'Horizontal Alignment',
		List = {'Right', 'Left'},
        Function = function(Val)
            Gui.NotificationHorizontalAlignment = Val
        end
	})

	Notifications:CreateDropdown({
		Name = 'Vertical Alignment',
		List = {'Bottom', 'Top'},
        Function = function(Val)
            Gui.NotificationVerticalAlignment = Val
        end
	})

	Notifications:CreateDropdown({
		Name = 'Fill Direction',
		List = {'Up', 'Down'},
        Function = function(Val)
            Gui.NotificationFillDirection = Val
        end
	})

	Notifications:CreateSlider({
		Name = 'Corner Radius',
		Default = 6,
		Min = 0,
		Max = 24,
		Function = function(Val)
			Gui.NotificationCornerRadius = Val
		end
	})

	Notifications:CreateSlider({
		Name = 'Module Toggled Duration',
		Default = 2,
		Min = 0.5,
		Max = 4,
		Decimal = 100,
		Function = function(Val)
			Gui.ModuleToggledNotificationDuration = Val
		end
	})
end)

Run(function()
    local TextGUIEnabled

	TextGUIEnabled = HudMenu:CreateOption({
		Name = 'TextGUI',
		Default = true,
		Function = function(Enabled)
			TextGUI.Object.Visible = Enabled
		end
	})

	local WatermarkEnabled = TextGUIEnabled:CreateToggle({
		Name = 'Watermark',
		Default = true,
		Function = function(Enabled)
			TextGUI:SetWatermarkEnabled(Enabled)
		end
	})

	WatermarkEnabled:CreateTextBox({
		Name = 'Watermark Text',
		Text = `<font color = 'rgb(255, 215, 0)'>Tidal</font> <font color = 'rgb(20, 135, 255)'>Wave</font> v{Gui.CurrentVersion}`,
		Placeholder = '[cool watermark text]',
		Function = function(Text)
			TextGUI:SetWatermarkText(Text)
		end
	})

	WatermarkEnabled:CreateColorPicker({
		Name = 'Watermark Text Color',
        Default = GetColor('Text/Primary'),
		Function = function(Color)
			TextGUI:SetWatermarkTextColor(Color)
		end
	})

	local ImageEnabled = TextGUIEnabled:CreateToggle({
		Name = 'Image Enabled',
		Function = function(Enabled)
			TextGUI:SetImageEnabled(Enabled)
		end
	})

	ImageEnabled:CreateAssetTextBox({
		Name = 'Image',
		Placeholder = '[rbxassetid://12345] or [cool image.png]',
		Function = function(Asset)
			TextGUI:SetImage(Asset)
		end
	})

	ImageEnabled:CreateSlider({
		Name = 'Image Width',
		Default = 200,
		Min = 20,
		Max = 400,
		Function = function(Val)
			TextGUI:SetImageWidth(Val)
		end
	})

	ImageEnabled:CreateSlider({
		Name = 'Image Height',
		Default = 50,
		Min = 10,
		Max = 100,
		Function = function(Val)
			TextGUI:SetImageHeight(Val)
		end
	})

	ImageEnabled:CreateSlider({
		Name = 'Image Order',
		Default = 1,
		Min = 0,
		Max = 3,
		Function = function(Val)
			TextGUI:SetImageOrder(Val)
		end
	})

	ImageEnabled:CreateDropdown({
		Name = 'Image Alignment',
		List = {'Right', 'Center', 'Left'},
		Function = function(Val)
			TextGUI:SetImageAlignment(Val)
		end
	})

	local ImageRectEnabled = ImageEnabled:CreateToggle({
		Name = 'Image Rect Enabled',
	})

	ImageRectEnabled:CreateSlider({
		Name = 'Rect Offset X',
		Default = 0,
		Min = 0,
		Max = 100,
		Function = function(Val)
			TextGUI:SetImageRectOffsetX(Val)
		end
	})

	ImageRectEnabled:CreateSlider({
		Name = 'Rect Offset Y',
		Default = 0,
		Min = 0,
		Max = 100,
		Function = function(Val)
			TextGUI:SetImageRectOffsetY(Val)
		end
	})

	ImageRectEnabled:CreateSlider({
		Name = 'Rect Size X',
		Default = 200,
		Min = 50,
		Max = 200,
		Function = function(Val)
			TextGUI:SetImageRectSizeX(Val)
		end
	})

	ImageRectEnabled:CreateSlider({
		Name = 'Rect Size Y',
		Default = 50,
		Min = 25,
		Max = 200,
		Function = function(Val)
			TextGUI:SetImageRectSizeY(Val)
		end
	})

	TextGUIEnabled:CreateSlider({
		Name = 'Layout Spacing',
		Default = 0,
		Min = 0,
		Max = 10,
		Function = function(Val)
			TextGUI:SetLayoutPadding(Val)
		end
	})

	TextGUIEnabled:CreateSlider({
		Name = 'Scale',
		Default = 1,
		Min = 0.6,
		Max = 2,
		Decimal = 20,
		Function = function(Val)
			TextGUI:SetScale(Val)
		end
	})

	TextGUIEnabled:CreateSlider({
		Name = 'Left Padding',
		Default = 4,
		Min = 0,
		Max = 12,
		Function = function(Val)
			TextGUI:SetLeftPadding(Val)
		end
	})

	TextGUIEnabled:CreateSlider({
		Name = 'Right Padding',
		Default = 8,
		Min = 0,
		Max = 12,
		Function = function(Val)
			TextGUI:SetRightPadding(Val)
		end
	})

	TextGUIEnabled:CreateSlider({
		Name = 'Spacing',
		Default = 0,
		Min = 0,
		Max = 6,
		Function = function(Val)
			TextGUI:SetSpacing(Val)
		end
	})

	TextGUIEnabled:CreateDropdown({
		Name = "Sorting",
		Info = 'Biggest - Sorts the modules from biggest to smallest\nSmallest - Sorts the modules from smallest to biggest\na-z - Sorts the modules from a-z\nz-a - Sorts the modules from z-a',
		List = {'Biggest', 'Smallest', 'a-z', 'z-a'},
		Function = function(Val)
			TextGUI:SetSortingMethod(Val)
		end
	})

	TextGUIEnabled:CreateDropdown({
		Name = "Alignment",
		Info = "Right - Aligns the modules to the right\nLeft - Alings the modules to the left",
		List = {'Right', 'Left'},
		Function = function(Val)
			TextGUI:SetAlignment(Val)
		end
	})

	TextGUIEnabled:CreateFont({
		Name = 'Watermark Font',
		Default = 'Montserrat',
		Function = function(Font)
			TextGUI:SetWatermarkFont(Font)
		end
	})

	TextGUIEnabled:CreateFont({
		Name = 'Font',
		Default = 'Montserrat',
		Function = function(Font)
			TextGUI:SetFont(Font)
		end
	})

	local AnimationEnabled = TextGUIEnabled:CreateToggle({
		Name = 'Animation',
		Default = true,
		Function = function(Enabled)
			TextGUI:SetAnimationEnabled(Enabled)
		end
	})

	AnimationEnabled:CreateSlider({
		Name = 'Animation Duration',
		Default = 0.3,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Function = function(Val)
			TextGUI:SetAnimationDuration(Val)
		end
	})

	local BackgroundEnabled = TextGUIEnabled:CreateToggle({
		Name = "Background Enabled",
		Default = true,
		Function = function(Enabled)
			TextGUI:SetBackgroundEnabled(Enabled)
		end
	})

	BackgroundEnabled:CreateColorPicker({
		Name = "Background Color",
		Default = Color3.fromRGB(0, 0, 0),
		DefaultTransparency = 0.5,
		Function = function(Color, Transparency)
			TextGUI:SetBackgroundColor(Color)
			TextGUI:SetBackgroundTransparency(Transparency)
		end,
	})

	TextGUIEnabled:CreateSlider({
		Name = 'Corner Radius',
		Default = 4,
		Min = 0,
		Max = 12,
		Function = function(Val)
			TextGUI:SetCornerRadius(Val)
		end
	})

	local BarEnabled = TextGUIEnabled:CreateToggle({
		Name = "Bar Enabled",
		Info = "Toggles the visibility of the bar on the modules",
		Default = true,
		Function = function(Enabled)
			TextGUI:SetBarEnabled(Enabled)
		end
	})

	BarEnabled:CreateColorPicker({
		Name = "Bar Color",
		Default = TextGUI.BarColor,
		Function = function(Color)
			TextGUI:SetBarColor(Color)
		end
	})

	BarEnabled:CreateSlider({
		Name = 'Bar Thickness',
		Default = 4,
		Min = 1,
		Max = 6,
		Function = function(Val)
			TextGUI:SetBarThickness(Val)
		end
	})

	TextGUIEnabled:CreateColorPicker({
		Name = "Text Color",
		Default = Color3.fromRGB(20, 135, 255),
		Function = function(Color)
			TextGUI:SetTextColor(Color)
		end
	})

	local RGB = TextGUIEnabled:CreateToggle({
		Name = "RGB",
		Info = "Makes the TextGUI RGB (:",
		Function = function(Enabled)
			TextGUI:SetRGBEnabled(Enabled)
		end
	})

	local RGBText = RGB:CreateToggle({
		Name = "RGB Text",
		Default = true,
		Function = function(Enabled)
			TextGUI:SetRGBTextEnabled(Enabled)
		end
	})

	RGBText:CreateSlider({
		Name = 'Text Sat',
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Function = function(Val)
			TextGUI:SetRGBTextSaturation(Val)
		end
	})

	RGBText:CreateSlider({
		Name = 'Text Val',
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Function = function(Val)
			TextGUI:SetRGBTextValue(Val)
		end
	})

	local RGBBackground = RGB:CreateToggle({
		Name = "RGB Background",
		Function = function(Enabled)
			TextGUI:SetRGBBackgroundEnabled(Enabled)
		end
	})

	RGBBackground:CreateSlider({
		Name = 'Background Sat',
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Function = function(Val)
			TextGUI:SetRGBBackgroundSaturation(Val)
		end
	})

	RGBBackground:CreateSlider({
		Name = 'Background Val',
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Function = function(Val)
			TextGUI:SetRGBBackgroundValue(Val)
		end
	})

	local RGBBar = RGB:CreateToggle({
		Name = "RGB Bar",
		Default = true,
		Function = function(Enabled)
			TextGUI:SetRGBBarEnabled(Enabled)
		end
	})

	RGBBar:CreateSlider({
		Name = 'Bar Sat',
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Function = function(Val)
			TextGUI:SetRGBBarSaturation(Val)
		end
	})

	RGBBar:CreateSlider({
		Name = 'Bar Val',
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Function = function(Val)
			TextGUI:SetRGBBarValue(Val)
		end
	})

	local RGBWatermark = RGB:CreateToggle({
		Name = 'RGB Watermark',
		Function = function(Enabled)
			TextGUI:SetRGBWatermarkEnabled(Enabled)
		end
	})

	RGBWatermark:CreateSlider({
		Name = 'Watermark Sat',
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Function = function(Val)
			TextGUI:SetRGBWatermarkSaturation(Val)
		end
	})

	RGBWatermark:CreateSlider({
		Name = 'Watermark Val',
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100,
		Function = function(Val)
			TextGUI:SetRGBWatermarkValue(Val)
		end
	})

	local RGBImage = RGB:CreateToggle({
		Name = 'RGB Image',
		Function = function(Enabled)
			TextGUI:SetRGBImageEnabled(Enabled)
		end
	})

	RGBImage:CreateSlider({
		Name = 'Image Sat',
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100
	})

	RGBImage:CreateSlider({
		Name = 'Image Val',
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 100
	})

	RGB:CreateToggle({
		Name = 'RGB Gradient',
		Function = function(Enabled)
			TextGUI:SetRGBGradientEnabled(Enabled)
		end
	})

	RGB:CreateSlider({
		Name = "RGB Speed",
		Default = 1,
		Min = 0.01,
		Max = 3,
		Decimal = 100,
		Function = function(Val)
			TextGUI:SetRGBSpeed(Val)
		end
	})

	RGB:CreateSlider({
		Name = "RGB Spread",
		Default = 1,
		Min = 0.01,
		Max = 3,
		Decimal = 100,
		Function = function(Val)
			TextGUI:SetRGBSpread(Val)
		end
	})

	RGB:CreateSlider({
		Name = 'RGB Refresh Rate',
		Default = 60,
		Min = 1,
		Max = 240,
		Function = function(Val)
			TextGUI:SetRGBRefreshRate(Val)
		end
	})

	RGB:CreateDropdown({
		Name = 'RGB Direction',
		Info = 'Down - The RGB effect goes down\nUp - The RGB effect goes up',
		List = {'Down', 'Up'},
		Function = function(Val)
			TextGUI:SetRGBDirection(Val)
		end
	})
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
	Name = 'Modules',
	Function = function(Visible)
		HideMenus("Modules", if Visible ~= nil then Visible else true)
	end,
})
ModulesTopBar:Select(false)
Gui.SelectedTopBar = ModulesTopBar.Object

local ConfigTopBar = CreateTopBarButton({
	Name = 'Config',
	Function = function()
		ConfigMenu:ShowOptions()
		HideMenus('Config')
		StopEditingHudPositions()
	end,
})

local GuiTopBar = CreateTopBarButton({
	Name = 'GUI',
	Function = function()
		GuiMenu:ShowOptions()
		HideMenus('GUI')
		StopEditingHudPositions()
	end,
})

local HudTopBar = CreateTopBarButton({
	Name = 'HUD',
	Function = function()
		HudMenu:ShowOptions()
		HideMenus('HUD')
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
            Menus = {},
            HudLocations = {},
            Categories = {}
        }
    end

	if Gui.Scale ~= Config.Scale then
		Gui.Scale = Config.Scale
		UIScale.Scale = Gui.Scale and math.max(ScreenGui.AbsoluteSize.X / 1920, 0.6) or 1
	end

	Gui.Profile = Profile or Config.Profile or 'Default'
	Gui.Profiles = Config.Profiles or {'Default'}
    Gui.Friends = Config.Friends or {}
    Gui.Theme = Config.Theme or 'TidalWave'
    Gui.Themes = LoadThemes(Config)
	if Config.Fonts then
		Gui.Fonts = {
			Regular = Font.new(Config.Fonts.Regular.Family, Enum.FontWeight[Config.Fonts.Regular.Weight]),
			Medium = Font.new(Config.Fonts.Medium.Family, Enum.FontWeight[Config.Fonts.Medium.Weight]),
			Bold = Font.new(Config.Fonts.Bold.Family, Enum.FontWeight[Config.Fonts.Bold.Weight])
		}
	end

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
        if typeof(v) ~= 'table' then continue end
        local Menu = Gui.Menus[i]
        if not Menu then continue end

        for i2, v2 in v.Options do
            if i2 == 'Gui' or i2 == 'Themes' then continue end
            local Option = Menu.Options[i2]
            if not Option then continue end
            if typeof(v2) == "table" and v2.Options and Option.Options then
                Gui:LoadOptions(Option.Options, v2.Options)
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
		Profile = Profile or Gui.Profile or 'Default',
		Profiles = Gui.Profiles or {'Default'},
        Friends = Gui.Friends or {},
        Fonts = {
            Regular = {
				Family = Gui.Fonts.Regular.Family,
				Weight = Gui.Fonts.Regular.Weight.Name
			},
            Medium = {
				Family = Gui.Fonts.Medium.Family,
				Weight = Gui.Fonts.Medium.Weight.Name
			},
            Bold = {
				Family = Gui.Fonts.Bold.Family,
				Weight = Gui.Fonts.Bold.Weight.Name
			}
        },
        Themes = SaveThemes(),
        Theme = Gui.Theme or 'TidalWave',
        Menus = {},
        HudLocations = {},
        Categories = {}
	}

	for i, v in Gui.Menus do
		if i == 'Options' or i == 'Profiles' or i == 'MenuOptions' then continue end
        Config.Menus[i] = {
            Options = {},
            Keybinds = {}
        }
        for i2, v2 in v.Options do
            if v2.Options then
                Config.Menus[i].Options[i2] = {
                    Enabled = v2.Enabled,
                    Options = Gui:SaveOptions(v2.Options),
					Keybinds = Gui:SaveOptions(v2.Keybinds)
                }
            elseif v2.Save then
                v2:Save(Config.Menus[i].Options)
            end
        end
        for i2, v2 in v.Keybinds do
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
	ListenObject(Background, 'Background/Button')

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
	ListenObject(NameLabel, 'Text/Primary')
	ListenFont(NameLabel, 'Regular')

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
	ListenObject(RenameTextBox, 'Text/Primary')
	ListenFont(RenameTextBox, 'Regular')

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
	ListenObject(DeleteButton, 'Background/Button')

	local DeleteButtonImage = Instance.new("ImageLabel")
	DeleteButtonImage.Name = "Image"
	DeleteButtonImage.BackgroundTransparency = 1
	DeleteButtonImage.Size = UDim2.fromOffset(24, 24)
	DeleteButtonImage.Position = UDim2.fromOffset(8, 8)
	SetIcon(DeleteButtonImage, "x")
	DeleteButtonImage.Parent = DeleteButton
	ListenObject(DeleteButtonImage, 'Main/Icons')

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
	AddHighlight(Load, 'Background/Secondary')
	ListenObject(Load, 'Background/Secondary', 'Text/Primary')
	ListenFont(Load, 'Regular')

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
	AddHighlight(Save, 'Background/Secondary')
	ListenObject(Save, 'Background/Secondary', 'Text/Primary')
	ListenFont(Save, 'Regular')

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
		for _, v in {Frame, Background, NameLabel, RenameTextBox, DeleteButton, DeleteButtonImage, Load, Save} do
			StopListeningObject(v)
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
		ListenObject(PlusButton, 'Background/Button')

		local PlusImage = Instance.new("ImageLabel")
		PlusImage.Name = "Image"
		PlusImage.BackgroundTransparency = 1
		PlusImage.Size = UDim2.fromOffset(24, 24)
		PlusImage.Position = UDim2.fromOffset(8, 8)
		SetIcon(PlusImage, "plus")
		PlusImage.Parent = PlusButton
		ListenObject(PlusImage, 'Main/Icons')

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
	ListenObject(Background, 'Background/Button')

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
	ListenObject(NameLabel, 'Text/Primary')
	ListenFont(NameLabel, 'Regular')

    local Enabled = if Properties.Enabled ~= nil then Properties.Enabled else true

    local EnabledBar = Instance.new("Frame")
    EnabledBar.Name = "Enabled"
    EnabledBar.BackgroundColor3 = Enabled and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
    EnabledBar.Size = UDim2.new(0, 2, 1, -6)
    EnabledBar.Position = UDim2.new(1, -8, 0, 3)
    EnabledBar.BorderSizePixel = 0
    EnabledBar.Parent = Background
	ListenObject(EnabledBar, 'Main/EnabledBar', 'Main/DisabledBar', function()
		EnabledBar.BackgroundColor3 = Enabled and GetColor('Main/EnabledBar') or GetColor('Main/DisabledBar')
	end)

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
	ListenObject(RenameTextBox, 'Text/Primary')
	ListenFont(RenameTextBox, 'Regular')

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
	AddTooltip(DeleteButton, 'Click to remove friend')
	ListenObject(DeleteButton, 'Background/Button')

	local DeleteButtonImage = Instance.new("ImageLabel")
	DeleteButtonImage.Name = "Image"
	DeleteButtonImage.BackgroundTransparency = 1
	DeleteButtonImage.Size = UDim2.fromOffset(24, 24)
	DeleteButtonImage.Position = UDim2.fromOffset(8, 8)
	SetIcon(DeleteButtonImage, 'x')
	DeleteButtonImage.Parent = DeleteButton
	ListenObject(DeleteButtonImage, 'Main/Icons')

	local Rename = Instance.new("TextButton")
	Rename.Name = 'Rename'
	Rename.BackgroundColor3 = GetColor('Background/Secondary')
	Rename.Text = 'Rename'
	Rename.BorderSizePixel = 0
	Rename.Size = UDim2.fromOffset(100, 30)
	Rename.Position = UDim2.new(1, -105, 0, 5)
	Rename.TextColor3 = GetColor('Text/Primary')
	Rename.TextSize = 24
	Rename.FontFace = GetFont('Regular')
	Rename.AutoButtonColor = false
	Rename.Parent = Background
	AddCorner(Rename, UDim.new(0, 7))
	AddHighlight(Rename, 'Background/Secondary')
	ListenObject(Rename, 'Background/Secondary', 'Text/Primary')
	ListenFont(Rename, 'Regular')

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
        TweenEnabledBar(EnabledBar, Enabled)
        Gui.Friends[Properties.Name] = Enabled
	end)

	Rename.MouseButton1Click:Connect(function()
		Select()
	end)

	DeleteButton.MouseButton1Click:Connect(function()
		Tooltip.Visible = false
		Gui.Friends[Properties.Name] = nil
		for _, v in {Frame, Background, NameLabel, EnabledBar, RenameTextBox, DeleteButton, DeleteButtonImage, Rename} do
			StopListeningObject(v)
		end
		Frame:Destroy()
	end)
end

Run(function()
	local UseFriends, RecolorFriends, FriendColor, AllowDisplayName, List

	local function Refresh()
		if UseFriends.Enabled and RecolorFriends.Enabled and Gui.Libraries and Gui.Libraries.EntityLib then
			Gui.Libraries.EntityLib:Refresh()
		end
	end

    UseFriends = FriendsMenu:CreateToggle({
        Name = "Use Friends",
		Function = Refresh
    })

    RecolorFriends = FriendsMenu:CreateToggle({
        Name = "Recolor Friends",
		Function = Refresh
    })

    FriendColor = FriendsMenu:CreateColorPicker({
        Name = "Friend Color",
        Default = Color3.fromRGB(0, 255, 0),
		Function = Refresh
    })

	AllowDisplayName = FriendsMenu:CreateToggle({
		Name = 'Allow Display Name',
		Info = 'Checks for display names instead of only regular names.',
		Function = Refresh
	})

    List = FriendsMenu:CreateTextList({
        Name = "Friends",
		Function = Refresh
    })

	local function Find(Name: string): boolean
		Name = Name:lower()

		for _, v in List.Enabled do
			if v:lower() == Name then
				return true
			end
		end

		return false
	end

    function Gui:IsFriend(Player: Player): boolean
		if typeof(Player) == 'Instance' and Player:IsA('Player') then
			if Find(Player.Name) then
				return true
			elseif AllowDisplayName.Enabled and Player.DisplayName ~= Player.Name then
				return Find(Player.DisplayName)
			end
		end

        return false
    end
	
	function Gui:GetFriendColor(Player: Player): (Color3, number)
		if typeof(Player) == 'Instance' and Player:IsA('Player') then
			local Valid = UseFriends.Enabled and RecolorFriends.Enabled and Gui:IsFriend(Player)
			if Valid then
				return FriendColor.Color, FriendColor.Transparency
			end
		end
		return nil, nil
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
		UpdateCursorCon = UIS.InputChanged:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				Cursor.Position = UDim2.fromOffset(Input.Position.X, Input.Position.Y + GuiService.TopbarInset.Height)
			end
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
	OnMouseEnableChanged()
	MouseEnabledCon = UIS:GetPropertyChangedSignal('MouseEnabled'):Connect(OnMouseEnableChanged)
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

Gui:Clean(StopCursorCon)

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
	if Gui.Binding and ((Input.KeyCode == Enum.KeyCode.None and not AllowMouseBinding.Enabled) or Input.KeyCode == Enum.KeyCode.Escape) then
		Gui.Binding:SetKeybind(Gui.Binding.Keybind)
		Gui.Binding = nil
	elseif ((Input.KeyCode ~= Enum.KeyCode.None or AllowMouseBinding.Enabled and UserInputTypes[Input.UserInputType.Name]) and Input.KeyCode ~= Enum.KeyCode.Escape) then
        local Key = Input.KeyCode == Enum.KeyCode.None and Input.UserInputType.Name or Input.KeyCode.Name
		Gui.PressedKeys[Key] = true
		if Gui.Binding then
			Gui.Binding:SetKeybind(Concat(Gui.PressedKeys, '+'))
		else
			if MenuKeybind:Check(Input) then
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

				TopBar.Visible = not CategoryHolder.Visible
				if not Gui.CategoryAnimations then
					CategoryHolder.Visible = not CategoryHolder.Visible
				end

				if CategoryHolder.Visible then
					Tooltip.Visible = false
					StopCursorCon()
				else
					StartCursorCon()
				end

				for _, Category in Gui.Categories do
					Category:Toggle()
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
	if Input.KeyCode == Enum.KeyCode.None and not AllowMouseBinding.Enabled then return end
    local Key = Input.KeyCode == Enum.KeyCode.None and Input.UserInputType.Name or Input.KeyCode.Name
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
	Name = 'Combat',
})

Gui:CreateCategory({
	Name = 'Player',
})

Gui:CreateCategory({
	Name = 'Movement'
})

Gui:CreateCategory({
	Name = 'Visuals'
})

Gui:CreateCategory({
	Name = 'World'
})

Gui:CreateCategory({
	Name = 'Other'
})

Gui:CreateCategory({
	Name = 'Animations'
})

Gui:CreateCategory({
	Name = 'Scripts'
})

Gui:CreateCategory({
	Name = 'Server'
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
	ListenObject(Search, "Background/Button", "Text/Primary")
	ListenObject(Search, "Text/Placeholder")
	ListenFont(Search, 'Regular')
	TopBar.Size += UDim2.fromOffset(168, 0)

	Search:GetPropertyChangedSignal("Text"):Connect(function()
		local Text = Search.Text:lower():gsub(" ", "")
		local Blank = Text:match("%w+") == nil

		for _, Category in Gui.Categories do
			for _, Button in Category.Object.ScrollingFrame:GetChildren() do
				if Button:IsA("TextButton") or Button:IsA("TextLabel") or Button:IsA("TextBox") then
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