if not game:IsLoaded() then game.Loaded:Wait() end
if shared.TidalWave then shared.TidalWave:Shutdown() end

local Start = os.clock()
local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local RunService: RunService = GetService('RunService')
local CoreGui: CoreGui = GetService('CoreGui')
local Players: Players = GetService('Players')
local TweenService: TweenService = GetService('TweenService')

local Plr = Players.LocalPlayer
local IsStudio = RunService:IsStudio()

local gethui = gethui or function() return CoreGui and CoreGui:FindFirstChild('RobloxGui') or CoreGui or Plr:FindFirstChildOfClass('PlayerGui') end
local writefile, makefolder, isfolder, isfile, readfile, loadfile = writefile, makefolder, isfolder or function(s) return false end, isfile or function(s) return false end, readfile, loadfile
local getcustomasset = getcustomasset or function(Path) return `rbxasset://{Path}` end

if IsStudio then
    local FileSystem = require(script.Libraries.FileSystem)
    writefile, makefolder, isfile, isfolder, readfile = FileSystem.writefile, FileSystem.makefolder, FileSystem.isfile, FileSystem.isfolder, FileSystem.readfile
end

for _, v in {'TidalWave', 'TidalWave/Games', 'TidalWave/Guis', 'TidalWave/Libraries', 'TidalWave/Profiles', 'TidalWave/Assets'} do
    if not isfolder(v) then
        makefolder(v)
    end
end

local Gui

if writefile and isfile then
    if isfile('TidalWave/Profiles/Gui.txt') then
        Gui = readfile('TidalWave/Profiles/Gui.txt') or 'TidalWave'
    else
        writefile('TidalWave/Profiles/Gui.txt', 'TidalWave')
        Gui = 'TidalWave'
    end
end

local function DownloadFile(Path, Function)
	if not isfile(Path) then
		local Success, Result = pcall(function()
			return game:HttpGet(`https://raw.githubusercontent.com/fluidnarrator30/Tidal-Wave/refs/heads/main/{Path:gsub('TidalWave/', '')}`, true)
		end)
        if Success and Result ~= '404: Not Found' then
            writefile(Path, Result)
        end
	end
    return (Function or readfile)(Path)
end

local TidalWave

local function AddCorner(Obj, CornerRadius)
    local Corner = Instance.new('UICorner')
    Corner.CornerRadius = CornerRadius
    Corner.Parent = Obj
end

local LoadingScreen = Instance.new('ScreenGui')
LoadingScreen.Name = 'TidalWave Loading Screen'
LoadingScreen.DisplayOrder = 69420
LoadingScreen.IgnoreGuiInset = true
LoadingScreen.ResetOnSpawn = false
LoadingScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadingScreen.Parent = gethui()

local LoadingFrame = Instance.new('Frame')
LoadingFrame.Size = UDim2.fromOffset(300, 150)
LoadingFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LoadingFrame.Parent = LoadingScreen
AddCorner(LoadingFrame, UDim.new(0, 6))

local ImageLabel = Instance.new('ImageLabel')
ImageLabel.Size = UDim2.fromOffset(125, 72)
ImageLabel.BackgroundTransparency = 1
ImageLabel.Position = UDim2.fromOffset(87, 10)
ImageLabel.Image = DownloadFile('TidalWave/Assets/LoadingIcon.webp', getcustomasset)
ImageLabel.Parent = LoadingFrame

local LoadingInfo = Instance.new('TextLabel')
LoadingInfo.Size = UDim2.fromOffset(290, 35)
LoadingInfo.BackgroundTransparency = 1
LoadingInfo.Position = UDim2.fromOffset(5, 96)
LoadingInfo.TextSize = 20
LoadingInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingInfo.Text = ""
LoadingInfo.FontFace = Font.fromEnum(Enum.Font.Gotham)
LoadingInfo.Parent = LoadingFrame

local ProgressBar = Instance.new('CanvasGroup')
ProgressBar.Size = UDim2.fromOffset(290, 5)
ProgressBar.Position = UDim2.new(0, 5, 0, 140)
ProgressBar.BorderSizePixel = 0
ProgressBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ProgressBar.Parent = LoadingFrame
AddCorner(ProgressBar, UDim.new(0, 6))

local ProgressBarFill = Instance.new('Frame')
ProgressBarFill.Size = UDim2.fromScale(0, 1)
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ProgressBarFill.Parent = ProgressBar

local function Error(Msg, Name, Er)
    if TidalWave then
        TidalWave:Notify({
            Text = `{Msg} Check logs for more info.`,
            Type = 'Error',
            Duration = 5
        })
    end
    LoadingScreen:Destroy()
    warn(`[TidalWave]: Failed to load '{Name}': {Er}`)
end

if not shared.TidalWaveDev then
    local Success, Result = pcall(function()
        return game:HttpGet(`https://raw.githubusercontent.com/fluidnarrator30/Tidal-Wave/refs/heads/main/Games/{game.PlaceId}.lua`, true)
    end)
    if Success and Result ~= '404: Not Found' then
        writefile(`TidalWave/Games/{game.PlaceId}.lua`, Result)
    end
end

local GameSupported = isfile(`TidalWave/Games/{game.PlaceId}.lua`)
local CurrentLoaded = 0
local AmountToLoad = GameSupported and 6 or 5

local function IncrementBar()
    CurrentLoaded += 1
    TweenService:Create(ProgressBarFill, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.fromScale(CurrentLoaded / AmountToLoad, 1)}):Play()
end

local function Load(Path, Name)
    LoadingInfo.Text = `Loading {Name}...`
    if IsStudio then
        local Ref = script
        for _, v in Path:gsub('%.lua', ''):split("/") do
            Ref = Ref[v]
        end
        local Result = require(Ref)
        IncrementBar()
        return Result
    else
        local Function = loadstring(DownloadFile(`TidalWave/{Path}`), Name)
        if typeof(Function) == "function" then
            local Result = Function()
            IncrementBar()
            return Result
        else
            Error(`Failed to load '{Name}'`, Name, Function)
        end
    end
end

shared.TidalWaveVersion = '2.2.0-beta'
shared.TidalWave = Load(`Guis/{Gui}.lua`, 'Gui')
TidalWave = shared.TidalWave
TidalWave.Libraries = {}
TidalWave.Libraries.CharacterLib = Load('Libraries/CharacterLib.lua', 'CharacterLib')
TidalWave.Libraries.Drawing = Load('Libraries/Drawing.lua', 'Drawing')
TidalWave.Libraries.ObjectFunctions = Load('Libraries/ObjectFunctions.lua', 'ObjectFunctions')
TidalWave.Libraries.Prediction = Load('Libraries/Prediction.lua', 'Prediction')
Load('Games/Universal.lua', 'Universal')

if GameSupported then
    LoadingInfo.Text = `Loading {TidalWave.PlaceName} Modules...`
    loadfile(`TidalWave/Games/{game.PlaceId}.lua`)()
    IncrementBar()

    TidalWave:Notify({
        Text = `Loaded Modules for '{TidalWave.PlaceName}'`,
        Duration = 5
    })
end

LoadingInfo.Text = 'Finished Loading.'

local Tween = TweenService:Create(LoadingFrame, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0, false, 0.75), {Position = UDim2.new(0.5, -150, 0, -150)})
Tween:Play()
Tween.Completed:Once(function()
	LoadingScreen:Destroy()
end)

TidalWave:Load()

local LoadTime = os.clock() - Start
local RoundedTime = math.round(LoadTime * 1000) / 1000

TidalWave:Notify({
    Text = `Loaded TidalWave in {RoundedTime} seconds.\nPress {TidalWave.Menus.Config.Keybinds.Menu.Keybind} to open gui.`,
    Duration = 5
})