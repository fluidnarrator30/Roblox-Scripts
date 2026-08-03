local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local Lighting: Lighting = GetService('Lighting')
local Players: Players = GetService('Players')
local RunService: RunService = GetService('RunService')
local TeleportService: TeleportService = GetService('TeleportService')
local TextService: TextService = GetService('TextService')
local UIS: UserInputService = GetService('UserInputService')
local HttpService: HttpService = GetService('HttpService')
local MaterialService: MaterialService = GetService('MaterialService')
local ProximityPromptService: ProximityPromptService = GetService('ProximityPromptService')
local ContextActionService: ContextActionService = GetService('ContextActionService')
local GuiService: GuiService = GetService('GuiService')
local VirtualUser: VirtualUser = GetService('VirtualUser')
local TweenService: TweenService = GetService('TweenService')

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local Modules = TidalWave.Modules
local CharacterLib = TidalWave.Libraries.CharacterLib
local Drawing = TidalWave.Libraries.Drawing
local ObjectFunctions = TidalWave.Libraries.ObjectFunctions

local Combat = Categories.Combat
local PlayerCategory = Categories.Player
local Movement = Categories.Movement
local Visuals = Categories.Visuals
local World = Categories.World
local Other = Categories.Other
local Animations = Categories.Animations
local Scripts = Categories.Scripts
local Server = Categories.Server

local IsStudio = RunService:IsStudio()

local Plr: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
local Color3 = table.clone(Color3)
Color3.White = Color3.new(1, 1, 1)
Color3.Black = Color3.new(0, 0, 0)
local CFrame = CFrame
local math = math
local table = table
local UDim2 = table.clone(UDim2)
UDim2.zero = UDim2.new()
local Vector2 = Vector2
local Instance = Instance
local Enum = Enum
local tostring = tostring
local Path2DControlPoint = Path2DControlPoint
local vector = table.clone(vector)
vector.xAxis = vector.create(1, 0, 0)
vector.yAxis = vector.create(0, 1, 0)
vector.zAxis = vector.create(0, 0, 1)
vector.XAxis = vector.xAxis
vector.YAxis = vector.yAxis
vector.ZAxis = vector.zAxis
vector.X = vector.xAxis
vector.Y = vector.yAxis
vector.Z = vector.zAxis
vector.huge = vector.create(math.huge, math.huge, math.huge)
vector.hugeX = vector.create(math.huge, 0, 0)
vector.hugeY = vector.create(0, math.huge, 0)
vector.hugeZ = vector.create(0, 0, math.huge)
vector.hugeXZ = vector.create(math.huge, 0, math.huge)
function vector.round(Vec)
    return vector.create(math.round(Vec.X), math.round(Vec.Y), math.round(Vec.Z))
end
vector.unit = vector.normalize

local newcclosure = newcclosure or function(f) return f end
local getnamecallmethod = getnamecallmethod or get_namecall_method
local setclipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
local fireproximityprompt = fireproximityprompt
local fireclickdetector = fireclickdetector
local firetouchinterest = firetouchinterest
local hookmetamethod = hookmetamethod
local mousemoverel = mousemoverel
local getconnections = getconnections or get_signal_cons
local getgc = getgc or get_gc_objects
local setfpscap = setfpscap
local getfpscap = getfpscap
local iswindowactive = iswindowactive or isrbxactive or isgameactive
local mouse1click = mouse1click
local mouse1press = mouse1press
local mouse1release = mouse1release
local mouse2click = mouse2click
local mouse2press = mouse2press
local mouse2release = mouse2release
local loadstring = IsStudio and require(script.Parent.Parent.Libraries.Loadstring) or loadstring

TidalWave:Clean(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
end))

local function Notify(Properties)
    TidalWave:Notify(Properties)
end

local function Run(f)
    f()
end

local function NotifyPoopSploit(Function)
    Notify({
        Title = "Poop Sploit",
        Text = `{TidalWave.Executor or "Your Executor"} doesn't support "{Function}"`,
        Type = "Error",
        Duration = 4,
    })
end

local function IsFriend(Player)
    return TidalWave:IsFriend(Player)
end

local function GetTeamColor(Character)
    return CharacterLib:GetTeamColor(Character)
end

local function GetFullPlayerName(Player)
    return Player.DisplayName == Player.Name and Player.Name or `{Player.DisplayName} (@{Player.Name})`
end

local function GetFullName(Object)
    return ObjectFunctions:GetFullName(Object)
end

local function FindPlayer(Name)
    if typeof(Name) == "string" and Name:match("%w+") then
        Name = Name:lower()
        local Match
        for _, Player in Players:GetPlayers() do
            if Player == Plr then continue end
            local PlayerName, DisplayName = Player.Name:lower(), Player.DisplayName:lower()
            if PlayerName:sub(1, #Name) == Name or Name:sub(1, #PlayerName) == PlayerName or DisplayName:sub(1, #Name) == Name or Name:sub(1, #DisplayName) == DisplayName then
                return Player
            elseif not Match and (PlayerName:match(Name) or Name:match(PlayerName) or DisplayName:match(Name) or Name:match(DisplayName)) then
                Match = Player
            end
        end
        return Match
    end
	return nil
end

local function CanClick()
    if UIS:GetFocusedTextBox() then return false end
    if TidalWave.Gui.ScaledGui.Gui.TopBar.Visible then return false end
    if iswindowactive and not iswindowactive() then return false end
    return true
end

local function ModY(Vector, Y)
    return vector.create(Vector.X, Y, Vector.Z)
end

Run(function() -- Combat
    Run(function() -- AimAssist
        local AimAssist, WallCheck, Part, Fov, Speed, Circle, CircleObject, OutlineColor, FillColor, OutlineTransparency, FillTransparency, Thickness

        local UserGameSettings = UserSettings():GetService('UserGameSettings')

        local function CreateCircle()
            CircleObject = Drawing.new("Circle")
            CircleObject.Radius = Fov.Value
            CircleObject.FillTransparency = FillTransparency.Value
            CircleObject.OutlineTransparency = OutlineTransparency.Value
            CircleObject.FillColor = FillColor.Color
            CircleObject.OutlineColor = OutlineColor.Color
            CircleObject.Thickness = Thickness.Value
            CircleObject.Position = UIS:GetMouseLocation()
            CircleObject.Visible = AimAssist.Enabled
            CircleObject.Parent = TidalWave.Gui
        end

        local function RemoveCircle()
            if CircleObject then
                CircleObject:Destroy()
                CircleObject = nil
            end
        end

        local function UpdateCircle()
            if CircleObject then
                CircleObject.Radius = Fov.Value
                CircleObject.FillTransparency = FillTransparency.Value
                CircleObject.OutlineTransparency = OutlineTransparency.Value
                CircleObject.FillColor = FillColor.Color
                CircleObject.OutlineColor = OutlineColor.Color
                CircleObject.Thickness = Thickness.Value
            end
        end

        AimAssist = Combat:CreateModule({
            Name = "AimAssist",
            Info = "Automatically moves your mouse towards the closest player.",
            Function = function(Enabled)
                if Enabled then
                    if not mousemoverel then NotifyPoopSploit("mousemoverel") return end
                    if Circle.Enabled and not CircleObject then
                        CreateCircle()
                    end
                    
                    AimAssist:Clean(RunService.PreRender:Connect(function(Delta)
                        if CircleObject then
                            CircleObject.Position = UIS:GetMouseLocation()
                        end
                        if CharacterLib.Alive and CanClick() then
                            local Character, Vector = CharacterLib:GetClosestCharacterWithinMouse({
                                Part = Part.Value,
                                Range = Fov.Value,
                                Origin = Camera.CFrame.Position,
                                WallCheck = WallCheck.Enabled,
                                NPCS = true,
                                Players = true
                            })

                            if Character then
                                local MouseLocation = UIS:GetMouseLocation()
                                local MouseDelta = Vector2.new(Vector.X - MouseLocation.X, Vector.Y - MouseLocation.Y) / UserGameSettings.MouseSensitivity
                                if MouseDelta.Magnitude > 1 then
                                    MouseDelta *= math.min(Speed.Value * Delta, 1)
                                    mousemoverel(MouseDelta.X, MouseDelta.Y)
                                end
                            end
                        end
                    end))
                else
                    RemoveCircle()
                end
            end
        })

        WallCheck = AimAssist:CreateToggle({
            Name = "Wall Check",
            Default = true
        })

        Part = AimAssist:CreateDropdown({
            Name = "Part",
            List = {'Head', 'Root', 'Closest'}
        })

        Fov = AimAssist:CreateSlider({
            Name = "Fov",
            Default = 100,
            Min = 0,
            Max = 1000,
            Function = UpdateCircle
        })

        Speed = AimAssist:CreateSlider({
            Name = 'Speed',
            Default = 15,
            Min = 1,
            Max = 30,
            Decimal = 10
        })

        Circle = AimAssist:CreateToggle({
            Name = "Circle",
            Function = function(Enabled)
                if Enabled and AimAssist.Enabled then
                    CreateCircle()
                else
                    RemoveCircle()
                end
                for _, v in {Fov, Thickness, OutlineTransparency, FillTransparency, OutlineColor, FillColor} do
                    v:SetVisible(Enabled)
                end
            end
        })

        Thickness = AimAssist:CreateSlider({
            Name = "Thickness",
            Default = 1,
            Min = 1,
            Max = 10,
            Visible = false,
            Function = UpdateCircle
        })

        OutlineTransparency = AimAssist:CreateSlider({
            Name = "Outline Transparency",
            Default = 0,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Visible = false,
            Function = UpdateCircle
        })

        FillTransparency = AimAssist:CreateSlider({
            Name = "Fill Transparency",
            Default = 1,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Visible = false,
            Function = UpdateCircle
        })

        OutlineColor = AimAssist:CreateColorPicker({
            Name = "Outline Color",
            Default = Color3.fromRGB(255, 255, 255),
            Visible = false,
            Function = UpdateCircle
        })

        FillColor = AimAssist:CreateColorPicker({
            Name = "Fill Color",
            Default = Color3.fromRGB(255, 255, 255),
            Visible = false,
            Function = UpdateCircle
        })
    end)

    Run(function() -- TriggerBot
        local TriggerBot, MouseButton, Mode, Held

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true

        TriggerBot = Combat:CreateModule({
            Name = 'TriggerBot',
            Info = 'Automatically clicks when hovering over another player.',
            Function = function(Enabled)
                if Enabled then
                    TriggerBot:Clean(RunService.PreRender:Connect(function()
                        if not (CharacterLib.Alive and CanClick()) then return end
                        Params.FilterDescendantsInstances = {CharacterLib.Character}
                        local MouseLocation = UIS:GetMouseLocation()
                        local MouseRaycast = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)
                        local Raycast = workspace:Raycast(MouseRaycast.Origin, MouseRaycast.Direction * 1000)
                        local Character = Raycast and Raycast.Instance.Parent.ClassName == 'Model' and CharacterLib:FindCharacter(Raycast.Instance.Parent)
                        if Character and not Character.Teammate and CharacterLib:CanAttack(Character) then
                            if Mode.Value == 'Hold' then
                                if not Held then
                                    (MouseButton.Value == 'LeftClick' and mouse1press or mouse2press)()
                                    Held = true
                                end
                            else
                                (MouseButton.Value == 'LeftClick' and mouse1click or mouse2click)()
                            end
                        elseif Held and Mode.Value == 'Hold' then
                            Held = nil
                            (MouseButton.Value == 'LeftClick' and mouse1release or mouse2release)()
                        end
                    end))
                else
                    Held = nil
                end
            end,
        })

        MouseButton = TriggerBot:CreateDropdown({
            Name = 'Mouse Button',
            List = {'LeftClick', 'RightClick'}
        })

        Mode = TriggerBot:CreateDropdown({
            Name = 'Mode',
            List = {'Spam', 'Hold'},
            Function = function(Val)
                if Val == 'Spam' then
                    Held = nil
                end
            end
        })
    end)

    Run(function() -- AutoClicker
        local AutoClicker, Interval, RandomizeInterval, IntervalMin, IntervalMax, Method

        local Rand = Random.new()

        local function Wait()
            if RandomizeInterval.Enabled then
                task.wait(Rand:NextNumber(IntervalMin.Value, IntervalMax.Value))
            else
                task.wait(Interval.Value)
            end
        end

        AutoClicker = Combat:CreateModule({
            Name = "AutoClicker",
            Info = "Automatically clicks for you.",
            Enabled = function()
                AutoClicker:Clean(UIS.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 and CanClick() then
                        repeat
                            local Tool = CharacterLib.Alive and CharacterLib.Character:FindFirstChildOfClass("Tool")
                            if Tool then
                                Tool:Activate()
                                Wait()
                            else
                                task.wait()
                            end
                        until not (AutoClicker.Enabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and CanClick())
                    end
                end))
            end
        })

        Interval = AutoClicker:CreateSlider({
            Name = "Interval",
            Default = 0.1,
            Min = 0,
            Max = 1,
        })

        RandomizeInterval = AutoClicker:CreateToggle({
            Name = "Randomize Interval",
        })

        IntervalMin = AutoClicker:CreateSlider({
            Name = "Interval Min",
            Default = 0.09,
            Min = 0,
            Max = 1,
        })

        IntervalMax = AutoClicker:CreateSlider({
            Name = "Interval Max",
            Default = 0.11,
            Min = 0,
            Max = 1,
        })

        Method = AutoClicker:CreateDropdown({
            Name = 'Method',
            List = {'Tool', 'MouseButton1', 'MouseButton2'}
        })
    end)
    
    Run(function() -- HitboxExpander
        local HitboxExpander, Target, Color, X, Y, Z, NoCollision

        local Parts = {}
        local db = {}
        local Size

        local function AddPart(Part)
            local Tab = {
                Size = Part.Size,
                Color = Part.Color,
                CanCollide = Part.CanCollide
            }
            Part.Size = Size
            Part.Color = Color.Color
            Part.Transparency = Color.Transparency

            if NoCollision.Enabled then
                Part.CanCollide = false
            end
            HitboxExpander:Clean(Part.Changed:Connect(function(Property)
                if db[Part] then return end
                db[Part] = true
                if Tab[Property] then
                    Tab[Property] = Part[Property]
                end
                if Property == 'CanCollide' and NoCollision.Enabled then
                    Part.CanCollide = false
                end
                db[Part] = nil
            end))

            Parts[Part] = Tab
        end

        HitboxExpander = Combat:CreateModule({
            Name = "HitboxExpander",
            Info = "Expands the hitbox of enemies.",
            Function = function(Enabled)
                if Enabled then
                    HitboxExpander:Clean(RunService.PreSimulation:Connect(function()
                        for _, Player in CharacterLib.List do
                            if Player.Teammate then continue end
                            if Target.Value == "Head" then
                                if Player.Head then
                                    AddPart(Player.Head)
                                end
                            elseif Target.Value == "RootPart" then
                                if Player.Root then
                                    AddPart(Player.Root)
                                end
                            elseif Target.Value == "All" then
                                for _, Part in Player.Character:QueryDescendants("BasePart") do
                                    AddPart(Part)
                                end
                            end
                        end
                    end))
                else
                    for Part, v in Parts do
                        Part.Size = v.Size
                        Part.Color = v.Color
                    end
                    table.clear(Parts)
                    table.clear(db)
                end
            end
        })

        local function UpdateSize()
            Size = vector.create(X.Value, Y.Value, Z.Value)
        end

        X = HitboxExpander:CreateSlider({
            Name = "X Size",
            Default = 5,
            Min = 1,
            Max = 20,
            Function = UpdateSize
        })

        Y = HitboxExpander:CreateSlider({
            Name = "Y Size",
            Default = 5,
            Min = 1,
            Max = 20,
            Function = UpdateSize
        })

        Z = HitboxExpander:CreateSlider({
            Name = "Z Size",
            Default = 5,
            Min = 1,
            Max = 20,
            Function = UpdateSize
        })

        UpdateSize()

        Target = HitboxExpander:CreateDropdown({
            Name = "Target",
            List = {"Head", "RootPart", "All"},
        })

        Color = HitboxExpander:CreateColorPicker({
            Name = "Color",
            Default = Color3.fromRGB(255, 0, 0),
        })

        NoCollision = HitboxExpander:CreateToggle({
            Name = 'No Collision',
            Info = 'Disables the collision of targeted parts.',
            Function = function(Enabled)
                if HitboxExpander.Enabled then
                    for Part in Parts do
                        db[Part] = true
                        Part.CanCollide = Enabled
                        db[Part] = nil
                    end
                    table.clear(db)
                end
            end
        })
    end)
end)

Run(function() -- Player
    Run(function() -- Noclip
        local Noclip, Method, ResetCollision, AntiNoclipBypass, BypassMethod, AntiNoclipPart

        local Parts = {}
        local Connections = {}

        local Params = OverlapParams.new()
        Params.MaxParts = 9e9
        Params.RespectCanCollide = true

        local Functions = {
            Character = function()
                if not CharacterLib.Alive then return end
                for _, Part in CharacterLib.Character:QueryDescendants("BasePart[CanCollide = true]") do
                    Part.CanCollide = false
                end
            end,
            Part = function()
                if not CharacterLib.Alive then return end
                local TouchingParts = workspace:GetPartBoundsInBox(CharacterLib.Root.CFrame, vector.create(7, CharacterLib.HipHeight, 7), Params)

                for Part in Parts do
                    if not table.find(TouchingParts, Part) then
                        Part.CanCollide = true
                        Parts[Part] = nil
                    end
                end

                for _, Part in TouchingParts do
                    if Part.CanCollide and not Parts[Part] then
                        Parts[Part] = true
                        Part.CanCollide = false
                    end
                end
            end
        }

        local function DisableConnections(Part)
            if not Part then return end
            task.defer(function()
                for _, Connection in getconnections(Part:GetPropertyChangedSignal("CanCollide")) do
                    Connections[#Connections + 1] = Connection
                    Connection:Disable()
                end
            end)
        end

        local function LocalAdded()
            table.clear(Connections)
            if AntiNoclipPart.Value == "All" then
                Noclip:Clean(CharacterLib.Character.DescendantAdded:Connect(function(Child)
                    if Child:IsA('BasePart') then
                        DisableConnections(Child)
                    end
                end))
                for _, Part in CharacterLib.Character:QueryDescendants("BasePart") do
                    DisableConnections(Part)
                end
            elseif AntiNoclipPart.Value == "Torso" then
                if CharacterLib.RigType == Enum.HumanoidRigType.R15 then
                    local LowerTorso, UpperTorso = CharacterLib.Character:WaitForChild("LowerTorso", 5), CharacterLib.Character:WaitForChild("UpperTorso", 5)
                    DisableConnections(LowerTorso)
                    DisableConnections(UpperTorso)
                else
                    local Torso = CharacterLib.Character:WaitForChild("Torso", 5)
                    DisableConnections(Torso)
                end
            else
                local Part = CharacterLib[AntiNoclipPart.Value]
                DisableConnections(Part)
            end
        end

        local Bypasses = {
            GetPropertyChangedSignal = function()
                if CharacterLib.Alive then
                    task.spawn(LocalAdded)
                end
                Noclip:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                Noclip:Clean(CharacterLib.Events.LocalRemoved:Connect(function()
                    table.clear(Connections)
                end))
            end
        }

        Noclip = PlayerCategory:CreateModule({
            Name = "Noclip",
            Info = "Disables the collision of your character allowing you to walk through walls.",
            Function = function(Enabled)
                if Enabled then
                    Noclip:Clean(RunService.PreSimulation:Connect(Functions[Method.Value]))
                    if AntiNoclipBypass.Enabled then
                        Bypasses[BypassMethod.Value]()
                    end
                else
                    if ResetCollision.Enabled and CharacterLib.Alive then
                        CharacterLib.Root.CanCollide = true
                    end
                    for _, Connection in Connections do
                        Connection:Enable()
                    end
                    for Part in Parts do
                        Part.CanCollide = true
                    end
                    table.clear(Parts)
                    table.clear(Connections)
                end
            end,
        })

        Method = Noclip:CreateDropdown({
            Name = "Method",
            List = {"Character", "Part"},
            Info = 'Character - Disables the collision of your character.\nPart - Disables the collision of parts around you.',
            Function = function(Val)
                AntiNoclipBypass:SetVisible(Val == 'Character')
                ResetCollision:SetVisible(Val == 'Character')
            end
        })

        ResetCollision = Noclip:CreateToggle({
            Name = "Reset Collision",
            Info = "Re-enables the collision of your character after disabling noclip.",
            Default = true
        })

        local function Update()
            if Noclip.Enabled then
                Noclip:Toggle(true)
                Noclip:Toggle(true)
            end
        end

        AntiNoclipBypass = Noclip:CreateToggle({
            Name = "Anti Noclip Bypass",
            Info = "Attempts to bypass anti noclip using various methods.",
            Function = function(Enabled)
                Update()
                BypassMethod:SetVisible(Enabled)
                AntiNoclipPart:SetVisible(Enabled)
            end
        })

        BypassMethod = Noclip:CreateDropdown({
            Name = "Bypass Method",
            List = {"GetPropertyChangedSignal"},
            Function = Update,
            Visible = false
        })

        AntiNoclipPart = Noclip:CreateDropdown({
            Name = "Part",
            List = {"Root", "Head", "Torso", "All"},
            Function = Update,
            Visible = false
        })
    end)

    Run(function() -- AntiRagdoll
        local AntiRagdoll

        local DisabledStates = {
            Enum.HumanoidStateType.FallingDown,
            Enum.HumanoidStateType.Ragdoll,
            Enum.HumanoidStateType.GettingUp
        }
        local PrevStates = {}

        local function OnCharacterAdded()
            local db = false
            AntiRagdoll:Clean(CharacterLib.Humanoid.StateEnabledChanged:Connect(function(State, Enabled)
                if db then return end
                db = true
                if DisabledStates[State.Name] then
                    PrevStates[State] = Enabled
                    if Enabled then
                        CharacterLib.Humanoid:SetStateEnabled(State, false)
                    end
                end
                db = false
            end))
            for _, State in DisabledStates do
                local Enabled = CharacterLib.Humanoid:GetStateEnabled(State)
                PrevStates[State] = Enabled
                if Enabled then
                    CharacterLib.Humanoid:SetStateEnabled(State, false)
                end
            end
        end

        AntiRagdoll = PlayerCategory:CreateModule({
            Name = "AntiRagdoll",
            Info = "Prevents your humanoid from going into the Ragdoll and FallingDown state",
            Function = function(Enabled)
                if Enabled then
                    AntiRagdoll:Clean(CharacterLib.Events.LocalAdded:Connect(OnCharacterAdded))
                    if CharacterLib.Alive then
                        OnCharacterAdded()
                        local State = CharacterLib.Humanoid:GetState()
                        if State == Enum.HumanoidStateType.Ragdoll or State == Enum.HumanoidStateType.FallingDown then
                            CharacterLib.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                        end
                    end
                else
                    if CharacterLib.Alive then
                        for State, Enabled in PrevStates do
                            CharacterLib.Humanoid:SetStateEnabled(State, Enabled)
                        end
                    end
                    table.clear(PrevStates)
                end
            end
        })
    end)

    Run(function() -- JumpPower
        local JumpPowerModule, JumpPower, db, OldJumpPower, OldUseJumpPower

        local function LocalAdded()
            OldJumpPower, OldUseJumpPower = CharacterLib.Humanoid.JumpPower, CharacterLib.Humanoid.UseJumpPower
            CharacterLib.Humanoid.JumpPower = JumpPower.Value
            CharacterLib.Humanoid.UseJumpPower = true
            JumpPowerModule:Clean(CharacterLib.Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
                if db then return end
                OldJumpPower = CharacterLib.Humanoid.JumpPower
                CharacterLib.Humanoid.JumpPower = JumpPower.Value
            end))
            JumpPowerModule:Clean(CharacterLib.Humanoid:GetPropertyChangedSignal("UseJumpPower"):Connect(function()
                if db then return end
                OldUseJumpPower = CharacterLib.Humanoid.UseJumpPower
                CharacterLib.Humanoid.UseJumpPower = true
            end))
        end

        JumpPowerModule = PlayerCategory:CreateModule({
            Name = "JumpPower",
            Info = "Sets the jump power of your humanoid.",
            Function = function(Enabled)
                if Enabled then
                    if CharacterLib.Alive then
                        LocalAdded()
                    end
                    JumpPowerModule:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                else
                    if CharacterLib.Alive then
                        CharacterLib.Humanoid.JumpPower, CharacterLib.Humanoid.UseJumpPower = OldJumpPower, OldUseJumpPower
                    end
                end
            end
        })

        JumpPower = JumpPowerModule:CreateSlider({
            Name = "Jump Power",
            Default = CharacterLib.Alive and math.floor(CharacterLib.Humanoid.JumpPower) or 50,
            Min = 0,
            Max = 500,
            Function = function()
                if JumpPowerModule.Enabled and CharacterLib.Alive then
                    db = true
                    CharacterLib.Humanoid.JumpPower = JumpPower.Value
                    CharacterLib.Humanoid.UseJumpPower = true
                    db = nil
                end
            end
        })
    end)

    Run(function() -- HipHeight
        local HipHeightModule, HipHeight, Old

        local function LocalAdded()
            Old = CharacterLib.Humanoid.HipHeight
            CharacterLib.Humanoid.HipHeight = HipHeight.Value
            CharacterLib.HipHeight = HipHeight.Value + (CharacterLib.Root.Size.Y / 2) + (CharacterLib.Humanoid.RigType == Enum.HumanoidRigType.R6 and 2 or 0)
            HipHeightModule:Clean(CharacterLib.Humanoid:GetPropertyChangedSignal("HipHeight"):Connect(function()
                Old = CharacterLib.Humanoid.HipHeight
                CharacterLib.Humanoid.HipHeight = HipHeight.Value
                CharacterLib.HipHeight = HipHeight.Value + (CharacterLib.Root.Size.Y / 2) + (CharacterLib.Humanoid.RigType == Enum.HumanoidRigType.R6 and 2 or 0)
            end))
        end

        HipHeightModule = PlayerCategory:CreateModule({
            Name = "HipHeight",
            Info = "Sets the hip height of your humanoid.",
            Function = function(Enabled)
                if Enabled then
                    HipHeightModule:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                    if CharacterLib.Alive then
                        LocalAdded()
                    end
                else
                    if CharacterLib.Alive then
                        CharacterLib.Humanoid.HipHeight = Old
                        CharacterLib.HipHeight = Old
                    end
                    Old = nil
                end
            end
        })

        HipHeight = HipHeightModule:CreateSlider({
            Name = "Hip Height",
            Default = math.floor((CharacterLib.Alive and CharacterLib.Humanoid.HipHeight or 2) * 100) / 100,
            Min = 0,
            Max = 10,
            Decimal = 100,
            Function = function(Val)
                if HipHeightModule.Enabled and CharacterLib.Alive then
                    CharacterLib.Humanoid.HipHeight = Val
                end
            end
        })
    end)

    Run(function() -- MaxSlopeAngle
        local MaxSlopeAngleModule, MaxSlopeAngle, Old

        local function LocalAdded()
            Old = CharacterLib.Humanoid.MaxSlopeAngle
            CharacterLib.Humanoid.MaxSlopeAngle = MaxSlopeAngle.Value
            MaxSlopeAngleModule:Clean(CharacterLib.Humanoid:GetPropertyChangedSignal("MaxSlopeAngle"):Connect(function()
                Old = CharacterLib.Humanoid.MaxSlopeAngle
                CharacterLib.Humanoid.MaxSlopeAngle = MaxSlopeAngle.Value
            end))
        end

        MaxSlopeAngleModule = PlayerCategory:CreateModule({
            Name = "MaxSlopeAngle",
            Info = "Sets the max angle you can climb up slopes.",
            Function = function(Enabled)
                if Enabled then
                    if CharacterLib.Alive then
                        LocalAdded()
                    end
                    MaxSlopeAngleModule:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                else
                    if CharacterLib.Alive then
                        CharacterLib.Humanoid.MaxSlopeAngle = Old
                    end
                    Old = nil
                end
            end
        })

        MaxSlopeAngle = MaxSlopeAngleModule:CreateSlider({
            Name = "Angle",
            Default = math.floor((CharacterLib.Alive and CharacterLib.Humanoid.MaxSlopeAngle or 89) * 10) / 10,
            Min = 0,
            Max = 90,
            Decimal = 10,
            Function = function(Val)
                if MaxSlopeAngleModule.Enabled and CharacterLib.Alive then
                    CharacterLib.Humanoid.MaxSlopeAngle = Val
                end
            end
        })
    end)

    Run(function() -- DropTools
        local DropTools

        DropTools = PlayerCategory:CreateButton({
            Name = "Drop Tools",
            Info = "Drops all the tools in your backpack\nMay lag depending on how many tools you have",
            Function = function()
                local Backpack = Plr:FindFirstChildOfClass("Backpack")
                if not (Backpack and CharacterLib.Alive) then return end
                for _, v in Backpack:GetChildren() do
                    if v.ClassName == "Tool" then
                        v.Parent = CharacterLib.Character
                    end
                end
                task.wait(0.2)
                if not CharacterLib.Alive then return end
                for _, v in CharacterLib.Character:GetChildren() do
                    if v.ClassName == "Tool" then
                        v.Parent = workspace
                    end
                end
            end,
        })
    end)
end)

Run(function() -- Movement
    Run(function() -- Speed
        local Speed, Method, UsePercentage, Value, Percentage, UseLimits, MinSpeed, MaxSpeed, AutoJump, CustomJump, CustomJumpPower
        local OldWalkSpeed, WalkSpeedCon, db

        local OldPhysicalProperties = {}

        local function GetMoveDirection()
            local CalculatedSpeed = UsePercentage.Enabled and CharacterLib.Humanoid.WalkSpeed * (Percentage.Value / 100) or Value.Value
            if UsePercentage.Enabled and UseLimits.Enabled then
                CalculatedSpeed = math.clamp(CalculatedSpeed, MinSpeed.Value, MaxSpeed.Value)
            end
            return CharacterLib.Humanoid.MoveDirection * CalculatedSpeed
        end

        local function GetWalkSpeed()
            local CalculatedSpeed = UsePercentage.Enabled and OldWalkSpeed * (Percentage.Value / 100) or Value.Value
            if UsePercentage.Enabled and UseLimits.Enabled then
                CalculatedSpeed = math.clamp(CalculatedSpeed, MinSpeed.Value, MaxSpeed.Value)
            end
            return CalculatedSpeed
        end

        local function UpdateWalkSpeed()
            if Speed.Enabled and Method.Value == 'WalkSpeed' and CharacterLib.Alive then
                db = true
                CharacterLib.Humanoid.WalkSpeed = GetWalkSpeed()
                db = nil
            end
        end

        local ClimbingFunctions = {
            BodyVelocity = function()
                local ExistingBodyVelocity = Speed:GetInstance('BodyVelocity')
                if ExistingBodyVelocity then
                    ExistingBodyVelocity.Velocity = vector.zero
                end
            end,
            LinearVelocity = function()
                local ExistingLinearVelocity, ExistingAttachment = Speed:GetInstance('LinearVelocity'), Speed:GetInstance('Attachment')
                if ExistingLinearVelocity and ExistingAttachment then
                    ExistingLinearVelocity.VectorVelocity = vector.zero
                end
            end
        }

        local CreateFunctions = {
            BodyVelocity = function()
                Speed:CreateInstance('BodyVelocity', 'BodyVelocity', {MaxForce = vector.hugeXZ, Velocity = GetMoveDirection(), Parent = CharacterLib.Root})
            end,
            LinearVelocity = function()
                local Attachment = Speed:CreateInstance('Attachment', 'Attachment', {Name = 'RootAttachment', Position = CharacterLib.Root.AssemblyCenterOfMass - CharacterLib.Root.Position, Parent = CharacterLib.Root})
                Speed:CreateInstance('LinearVelocity', 'LinearVelocity', {ForceLimitMode = Enum.ForceLimitMode.PerAxis, MaxAxesForce = vector.hugeXZ, Attachment0 = Attachment, VectorVelocity = GetMoveDirection(), Parent = workspace})
                Speed:Clean(CharacterLib.Root:GetPropertyChangedSignal('AssemblyCenterOfMass'):Connect(function()
                    Attachment.Position = CharacterLib.Root.AssemblyCenterOfMass - CharacterLib.Root.Position
                end))
            end,
        }

        local Methods = {
            BodyVelocity = function()
                local ExistingBodyVelocity = Speed:GetInstance('BodyVelocity')
                if ExistingBodyVelocity then
                    ExistingBodyVelocity.Velocity = GetMoveDirection()
                end
            end,
            LinearVelocity = function()
                local ExistingLinearVelocity, ExistingAttachment = Speed:GetInstance('LinearVelocity'), Speed:GetInstance('Attachment')
                if ExistingLinearVelocity and ExistingAttachment then
                    ExistingLinearVelocity.VectorVelocity = GetMoveDirection()
                end
            end,
            Velocity = function()
                CharacterLib.Root.AssemblyLinearVelocity = ModY(GetMoveDirection(), CharacterLib.Root.AssemblyLinearVelocity.Y)
            end,
            CFrame = function(Delta)
                CharacterLib.Character:TranslateBy((GetMoveDirection() - (CharacterLib.Humanoid.MoveDirection * CharacterLib.Humanoid.WalkSpeed)) * Delta)
            end
        }

        local function LocalRemoved()
            if WalkSpeedCon then
                WalkSpeedCon:Disconnect()
                WalkSpeedCon = nil
            end
            Speed:CleanUp()
            Speed:ClearInstances()
            table.clear(OldPhysicalProperties)
        end

        local function PartAdded(Part)
            OldPhysicalProperties[Part] = Part.CustomPhysicalProperties
            Part.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0.5, 1, 1)
        end

        local function LocalAdded()
            LocalRemoved()
            if Method.Value == 'WalkSpeed' then
                OldWalkSpeed = CharacterLib.Humanoid.WalkSpeed
                CharacterLib.Humanoid.WalkSpeed = GetWalkSpeed()
                WalkSpeedCon = Speed:Clean(CharacterLib.Humanoid:GetPropertyChangedSignal('WalkSpeed'):Connect(function()
                    if db then return end
                    OldWalkSpeed = CharacterLib.Humanoid.WalkSpeed
                    CharacterLib.Humanoid.WalkSpeed = GetWalkSpeed()
                end))
            else
                if CreateFunctions[Method.Value] then
                    CreateFunctions[Method.Value]()
                elseif Method.Value == 'Velocity' then
                    for _, Part: Part in CharacterLib.Character:GetChildren() do
                        if Part:IsA('BasePart') then
                            PartAdded(Part)
                        end
                    end
                    Speed:Clean(CharacterLib.Character.ChildAdded:Connect(function(Part)
                        if Part:IsA('BasePart') then
                            PartAdded(Part)
                        end
                    end))
                end
            end
        end

        Speed = Movement:CreateModule({
            Name = "Speed",
            Info = "Increases your speed using various methods.",
            Function = function(Enabled)
                if Enabled then
                    if CharacterLib.Alive then
                        LocalAdded()
                    end
                    Speed:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                    Speed:Clean(CharacterLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if Method.Value ~= 'WalkSpeed' then
                        Speed:Clean(RunService.PreSimulation:Connect(function(Delta)
                            if not CharacterLib.Alive or (Modules.Fly and Modules.Fly.Enabled) or (Modules.LongJump and Modules.LongJump.Enabled) then return end
                            local State = CharacterLib.Humanoid:GetState()
                            if State == Enum.HumanoidStateType.Climbing then
                                local Function = ClimbingFunctions[Method.Value]
                                if Function then
                                    Function()
                                end
                                return
                            end
                            Methods[Method.Value](Delta)
                            if AutoJump.Enabled and CharacterLib.Humanoid.MoveDirection ~= vector.zero and CharacterLib.Humanoid.FloorMaterial ~= Enum.Material.Air then
                                if CustomJump.Enabled then
                                    CharacterLib.Root.AssemblyLinearVelocity = ModY(CharacterLib.Root.AssemblyLinearVelocity, CustomJumpPower.Value)
                                else
                                    CharacterLib.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                end
                            end
                        end))
                    end
                else
                    for Part, Old in OldPhysicalProperties do
                        Part.CustomPhysicalProperties = Old
                    end
                    if Method.Value == 'WalkSpeed' and OldWalkSpeed and CharacterLib.Alive then
                        CharacterLib.Humanoid.WalkSpeed = OldWalkSpeed
                    end
                    OldWalkSpeed = nil
                end
            end,
        })

        function Speed:StopMovers()
            if Method.Value == 'BodyVelocity' then
                self:RemoveInstance('BodyVelocity')
            elseif Method.Value == 'LinearVelocity' then
                local LinearVelocity = self:GetInstance('LinearVelocity')
                if LinearVelocity then
                    LinearVelocity.Enabled = false
                    LinearVelocity:GetPropertyChangedSignal('VectorVelocity'):Once(function()
                        LinearVelocity.Enabled = true
                    end)
                end
            end
        end

        Value = Speed:CreateSlider({
            Name = "Speed",
            Default = 16,
            Min = 0,
            Max = 250,
            Function = UpdateWalkSpeed
        })

        Method = Speed:CreateDropdown({
            Name = "Method",
            List = {"Velocity", "BodyVelocity", 'LinearVelocity', "CFrame", "WalkSpeed"},
            Info = "BodyVelocity - Adjusts the velocity of your character by using a BodyVelocity object.\nLinearVelocity - More modern version of BodyVelocity.\nVelocity - Directly adjusts the velocity your character.\nCFrame - Directly adjusts the position of your character.",
            Function = function(Val)
                if Speed.Enabled then
                    if Val ~= 'WalkSpeed' and OldWalkSpeed then
                        if CharacterLib.Alive then
                            LocalRemoved()
                            CharacterLib.Humanoid.WalkSpeed = OldWalkSpeed
                        end
                        OldWalkSpeed = nil
                    end
                    Speed:Toggle(true)
                    Speed:Toggle(true)
                end
            end
        })

        UsePercentage = Speed:CreateToggle({
            Name = "Use Percentage",
            Info = "Uses speed based off a percentage of your humanoid's walk speed.",
            Function = function(Enabled)
                Percentage:SetVisible(Enabled)
                UseLimits:SetVisible(Enabled)
                MinSpeed:SetVisible(Enabled and UseLimits.Enabled)
                MaxSpeed:SetVisible(Enabled and UseLimits.Enabled)
                UpdateWalkSpeed()
            end,
        })

        Percentage = Speed:CreateSlider({
            Name = "Percentage",
            Min = 0,
            Default = 110,
            Max = 200,
            Suffix = "%",
            Visible = false,
            Function = UpdateWalkSpeed
        })

        UseLimits = Speed:CreateToggle({
            Name = 'Use Limits',
            Info = 'Limits the speed calculated by Speed Percentage between the minimum and maximum values.',
            Visible = false,
            Function = function(Enabled)
                MinSpeed:SetVisible(Enabled)
                MaxSpeed:SetVisible(Enabled)
                UpdateWalkSpeed()
            end,
        })

        MinSpeed = Speed:CreateSlider({
            Name = "Min Speed",
            Default = 0,
            Min = 0,
            Max = 32,
            Visible = false,
            Function = UpdateWalkSpeed
        })

        MaxSpeed = Speed:CreateSlider({
            Name = 'Max Speed',
            Default = 32,
            Min = 0,
            Max = 64,
            Visible = false,
            Function = UpdateWalkSpeed
        })

        AutoJump = Speed:CreateToggle({
            Name = 'Auto Jump',
            Info = 'Automatically jumps when moving.',
            Function = function(Enabled)
                CustomJump:SetVisible(Enabled)
                CustomJumpPower:SetVisible(Enabled and CustomJump.Enabled)
            end
        })

        CustomJump = Speed:CreateToggle({
            Name = 'Custom Jump',
            Info = 'Allows you to have a custom jump.',
            Visible = false,
            Function = function(Enabled)
                CustomJumpPower:SetVisible(Enabled)
            end,
        })

        CustomJumpPower = Speed:CreateSlider({
            Name = 'Jump Power',
            Default = 30,
            Min = 1,
            Max = 75,
            Visible = false
        })
    end)

    Run(function() -- HighJump
        local HighJump, Method, JumpPower, AutoDisable, Down

        local Methods = {
            Velocity = function()
                CharacterLib.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                CharacterLib.Root.AssemblyLinearVelocity = vector.create(CharacterLib.Root.AssemblyLinearVelocity.X, JumpPower.Value, CharacterLib.Root.AssemblyLinearVelocity.Z)
            end,
            CFrame = function()
                repeat
                    local Delta = RunService.PreSimulation:Wait()
                    CharacterLib.Root.AssemblyLinearVelocity = ModY(CharacterLib.Root.AssemblyLinearVelocity, 0)
                    CharacterLib.Character:TranslateBy(vector.create(0, JumpPower.Value * Delta, 0))
                    RunService.PostSimulation:Wait()
                    CharacterLib.Root.AssemblyLinearVelocity = ModY(CharacterLib.Root.AssemblyLinearVelocity, 0)
                until CharacterLib.Humanoid.FloorMaterial ~= Enum.Material.Air
            end
        }

        local function Jump()
            if not CharacterLib.Alive then return end
            if CharacterLib.Humanoid.FloorMaterial ~= Enum.Material.Air then
                Methods[Method.Value]()
                if Method.Value == "Velocity" then
                    local TimeOut = os.clock() + 1
                    repeat
                        RunService.PostSimulation:Wait()
                    until CharacterLib.Humanoid.FloorMaterial == Enum.Material.Air or not HighJump.Enabled or os.clock() >= TimeOut

                    repeat
                        RunService.PostSimulation:Wait()
                    until CharacterLib.Humanoid.FloorMaterial ~= Enum.Material.Air or not HighJump.Enabled
                end
            end
            if HighJump.Enabled and AutoDisable.Enabled then
                HighJump:Toggle(true)
            end
        end

        local function LocalRemoved()
            HighJump:CleanUp()
        end

        local function LocalAdded()
            LocalRemoved()
            HighJump:Clean(CharacterLib.Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
                if CharacterLib.Humanoid.FloorMaterial ~= Enum.HumanoidStateType.Air and Down then
                    Jump()
                end
            end))
        end

        HighJump = Movement:CreateModule({
            Name = "HighJump",
            Info = "Makes you jump high",
            Enabled = function()
                if AutoDisable.Enabled then
                    Jump()
                else
                    Down = false
                    HighJump:Clean(UIS.InputBegan:Connect(function(Input)
                        if Input.KeyCode == Enum.KeyCode.Space and not UIS:GetFocusedTextBox() then
                            Down = true
                            if CharacterLib.Humanoid.FloorMaterial ~= Enum.HumanoidStateType.Air then
                                Jump()
                            end
                        end
                    end))
                    HighJump:Clean(UIS.InputEnded:Connect(function(Input)
                        if Input.KeyCode == Enum.KeyCode.Space then
                            Down = false
                        end
                    end))
                    HighJump:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                    HighJump:Clean(CharacterLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if CharacterLib.Alive then
                        LocalAdded()
                    end
                end
            end
        })
        Method = HighJump:CreateDropdown({
            Name = "Method",
            List = {"Velocity", "CFrame"}
        })

        JumpPower = HighJump:CreateSlider({
            Name = "Jump Power",
            Default = 50,
            Min = 1,
            Max = 200
        })

        AutoDisable = HighJump:CreateToggle({
            Name = "Auto Disable",
            Default = true,
            Function = function(Enabled)
                if HighJump.Enabled and Enabled then
                    HighJump:Toggle(true)
                end
            end
        })
    end)

    Run(function() -- LongJump
        local LongJump, Method, Speed, AutoDisable, Down, FloorMaterialCon

        local Methods = {
            Velocity = function()
                local MoveDirection = CharacterLib.Humanoid.MoveDirection
                CharacterLib.Root.AssemblyLinearVelocity = vector.create(MoveDirection.X * Speed.Value, CharacterLib.Root.AssemblyLinearVelocity.Y, MoveDirection.Z * Speed.Value)
            end,
            TranslateBy = function(Delta)
                CharacterLib.Character:TranslateBy((CharacterLib.Humanoid.MoveDirection * Speed.Value) * Delta)
            end
        }

        local function Jump()
            if CharacterLib.Alive and CharacterLib.Humanoid.FloorMaterial ~= Enum.Material.Air then
                if Modules.Speed.Enabled then
                    Modules.Speed:StopMovers()
                end
                CharacterLib.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

                local TimeOut = os.clock() + 1
                repeat
                    RunService.PostSimulation:Wait()
                until CharacterLib.Humanoid.FloorMaterial == Enum.Material.Air or not LongJump.Enabled or os.clock() >= TimeOut

                repeat
                    local Delta = RunService.PostSimulation:Wait()
                    Methods[Method.Value](Delta)
                until CharacterLib.Humanoid.FloorMaterial ~= Enum.Material.Air or not LongJump.Enabled
            end

            if LongJump.Enabled and AutoDisable.Enabled then
                LongJump:Toggle(true)
            end
        end

        local function LocalRemoved()
            if FloorMaterialCon then
                FloorMaterialCon:Disconnect()
                FloorMaterialCon = nil
            end
        end

        local function LocalAdded()
            LocalRemoved()
            FloorMaterialCon = LongJump:Clean(CharacterLib.Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
                if CharacterLib.Humanoid.FloorMaterial ~= Enum.Material.Air and Down then
                    Jump()
                end
            end))
        end

        LongJump = Movement:CreateModule({
            Name = "LongJump",
            Info = "Makes your jump very much long.",
            Function = function(Enabled)
                if Enabled then
                    if AutoDisable.Enabled then
                        Jump()
                    else
                        Down = nil
                        LongJump:Clean(UIS.InputBegan:Connect(function(Input)
                            if Input.KeyCode == Enum.KeyCode.Space and not UIS:GetFocusedTextBox() then
                                Down = true
                                if CharacterLib.Humanoid.FloorMaterial ~= Enum.Material.Air then
                                    Jump()
                                end
                            end
                        end))
                        LongJump:Clean(UIS.InputEnded:Connect(function(Input)
                            if Input.KeyCode == Enum.KeyCode.Space then
                                Down = nil
                            end
                        end))
                        if CharacterLib.Alive then
                            LocalAdded()
                        end
                        LongJump:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                    end
                else
                    Down = nil
                    FloorMaterialCon = nil
                end
            end
        })

        Method = LongJump:CreateDropdown({
            Name = "Method",
            List = {"Velocity", "TranslateBy"}
        })

        Speed = LongJump:CreateSlider({
            Name = "Speed",
            Default = 50,
            Min = 1,
            Max = 500
        })

        AutoDisable = LongJump:CreateToggle({
            Name = "Auto Disable",
            Default = true,
            Function = function(Enabled)
                if LongJump.Enabled and Enabled then
                    LongJump:Toggle(true)
                end
            end
        })
    end)

    Run(function() -- AirJump
        local AirJump, Hold, JumpInterval, CustomJump, JumpPower

        local function Jump()
            if CustomJump.Enabled then
                if JumpPower.Value >= CharacterLib.Humanoid.JumpPower then
                    CharacterLib.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                CharacterLib.Root.AssemblyLinearVelocity = vector.create(CharacterLib.Root.AssemblyLinearVelocity.X, JumpPower.Value, CharacterLib.Root.AssemblyLinearVelocity.Z)
            else
                CharacterLib.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end

        AirJump = Movement:CreateModule({
            Name = "AirJump",
            Info = "Allows you to jump midair",
            Enabled = function()
                AirJump:Clean(UIS.InputBegan:Connect(function(Input)
                    if Input.KeyCode == Enum.KeyCode.Space and CharacterLib.Alive and not UIS:GetFocusedTextBox() then
                        if Hold.Enabled then
                            repeat
                                if CharacterLib.Humanoid.FloorMaterial == Enum.Material.Air then
                                    Jump()
                                    task.wait(JumpInterval.Value)
                                else
                                    RunService.PostSimulation:Wait()
                                end
                            until not AirJump.Enabled or not Hold.Enabled or not CharacterLib.Alive or not UIS:IsKeyDown(Enum.KeyCode.Space)
                        elseif CharacterLib.Humanoid.FloorMaterial == Enum.Material.Air then
                            Jump()
                        end
                    end
                end))
            end
        })

        Hold = AirJump:CreateToggle({
            Name = "Hold",
            Info = "Allows you to hold jump instead of spamming it",
            Function = function(Enabled)
                JumpInterval:SetVisible(Enabled)
            end
        })

        JumpInterval = AirJump:CreateSlider({
            Name = "Jump Interval",
            Default = 0.1,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Visible = false
        })

        CustomJump = AirJump:CreateToggle({
            Name = 'Custom Jump',
            Info = 'Allows you to have a custom air jump.',
            Function = function(Enabled)
                JumpPower:SetVisible(Enabled)
            end
        })

        JumpPower = AirJump:CreateSlider({
            Name = 'Jump Power',
            Default = 35,
            Min = 5,
            Max = 70,
            Visible = false
        })
    end)

    Run(function() -- Fly
        local Fly, HorizontalSpeed, VerticalSpeed, FlyMethod, AlignMethod, MoveMethod, State, Platform, Percentage, UsePercentage, UpKeybind, DownKeybind
        local W, A, S, D, E, Q

        local function GetMoveDirection()
            if MoveMethod.Value == 'MoveDirection' then
                return CharacterLib.Humanoid.MoveDirection * (UsePercentage.Enabled and (CharacterLib.Humanoid.WalkSpeed * (Percentage.Value / 100)) or HorizontalSpeed.Value)
            else
                return ((Camera.CFrame.LookVector * (W - S)) + (Camera.CFrame.RightVector * (D - A))) * HorizontalSpeed.Value
            end
        end

        local function GetVerticalDirection()
            if MoveMethod.Value == 'MoveDirection' then
                return vector.create(0, (E - Q) * VerticalSpeed.Value, 0)
            else
                return (Camera.CFrame.UpVector * (E - Q)) * VerticalSpeed.Value
            end
        end

        local function GetDirection()
            return GetMoveDirection() + GetVerticalDirection()
        end

        local CreateFunctions = {
            BodyVelocity = function()
                Fly:CreateInstance('BodyVelocity', 'BodyVelocity', {MaxForce = vector.huge, Velocity = GetDirection(), Name = 'RootAttachment', Parent = CharacterLib.Root})
            end,
            LinearVelocity = function()
                local Attachment = Fly:CreateInstance('Attachment', 'Attachment', {Name = 'RootAttachment', Position = CharacterLib.Root.AssemblyCenterOfMass - CharacterLib.Root.Position, Parent = CharacterLib.Root})
                Fly:CreateInstance('LinearVelocity', 'LinearVelocity', {ForceLimitMode = Enum.ForceLimitMode.PerAxis, MaxAxesForce = vector.huge, VectorVelocity = GetDirection(), Attachment0 = Attachment, Parent = workspace})
                Fly:Clean(CharacterLib.Root:GetPropertyChangedSignal('AssemblyCenterOfMass'):Connect(function()
                    Attachment.Position = CharacterLib.Root.AssemblyCenterOfMass - CharacterLib.Root.Position
                end))
            end,
        }

        local AlignmentCreateFunctions = {
            AlignOrientation = function()
                local Attachment = Fly:CreateInstance('Attachment', 'Attachment2', {Name = 'RootAttachment', Position = CharacterLib.Root.AssemblyCenterOfMass - CharacterLib.Root.Position, Parent = CharacterLib.Root})
                Fly:CreateInstance('AlignOrientation', 'AlignOrientation', {Mode = Enum.OrientationAlignmentMode.OneAttachment, Attachment0 = Attachment, RigidityEnabled = true, CFrame = Camera.CFrame, Parent = workspace})
                Fly:Clean(CharacterLib.Root:GetPropertyChangedSignal('AssemblyCenterOfMass'):Connect(function()
                    Attachment.Position = CharacterLib.Root.AssemblyCenterOfMass - CharacterLib.Root.Position
                end))
            end
        }

        local FlyMethods = {
            BodyVelocity = function()
                local ExistingBodyVelocity = Fly:GetInstance('BodyVelocity')
                if ExistingBodyVelocity then
                    ExistingBodyVelocity.Velocity = GetDirection()
                end
            end,
            LinearVelocity = function()
                local ExistingLinearVelocity, ExistingAttachment = Fly:GetInstance('LinearVelocity'), Fly:GetInstance('Attachment')
                if ExistingLinearVelocity and ExistingAttachment then
                    ExistingLinearVelocity.VectorVelocity = GetDirection()
                end
            end,
            Velocity = function()
                CharacterLib.Root.AssemblyLinearVelocity = GetDirection() + vector.Y
            end,
            CFrame = function(Delta)
                CharacterLib.Root.AssemblyLinearVelocity = vector.Y
                CharacterLib.Character:TranslateBy(GetDirection() * Delta)
            end
        }

        local AlignMethods = {
            AlignOrientation = function()
                local ExistingAlignOrientation, ExisitingAttachment = Fly:GetInstance('AlignOrientation'), Fly:GetInstance('Attachment2')
                if ExistingAlignOrientation and ExisitingAttachment then
                    ExistingAlignOrientation.CFrame = Camera.CFrame
                end
            end,
            CFrame = function()
                CharacterLib.Root.CFrame = CFrame.lookAlong(CharacterLib.Root.Position, Camera.CFrame.LookVector)
                CharacterLib.Root.AssemblyAngularVelocity = vector.zero
            end
        }

        local function LocalRemoved()
            Fly:CleanUp()
            Fly:ClearInstances()
        end

        local function LocalAdded()
            LocalRemoved()
            if CreateFunctions[FlyMethod.Value] then
                CreateFunctions[FlyMethod.Value]()
            end
            if AlignmentCreateFunctions[AlignMethod.Value] then
                AlignmentCreateFunctions[AlignMethod.Value]()
            end
        end

        Fly = Movement:CreateModule({
            Name = "Fly",
            Info = "Allows you to fly through the air with extra detected methods.",
            Function = function(Enabled)
                if Enabled then
                    if Modules.Speed.Enabled then
                        Modules.Speed:StopMovers()
                    end
                    
                    W, A, S, D, E, Q = UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0, UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0, UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0, UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0, UpKeybind:IsPressed() and 1 or 0, DownKeybind:IsPressed() and 1 or 0
                    
                    if CharacterLib.Alive then
                        LocalAdded()
                    end
                    Fly:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                    Fly:Clean(CharacterLib.Events.LocalRemoved:Connect(LocalRemoved))
                    Fly:Clean(RunService.PreRender:Connect(function()
                        if AlignMethod.Value ~= "None" and CharacterLib.Alive then
                            AlignMethods[AlignMethod.Value]()
                        end
                    end))
                    Fly:Clean(RunService.PreSimulation:Connect(function(Delta)
                        if not CharacterLib.Alive then return end
                        if State.Value ~= 'None' then
                            if State.Value == 'PlatformStand' then
                                CharacterLib.Humanoid.PlatformStand = true
                            else
                                CharacterLib.Humanoid:ChangeState(Enum.HumanoidStateType[State.Value])
                            end
                        end
                        FlyMethods[FlyMethod.Value](Delta)
                    end))
                    if Platform.Enabled then
                        local Part = Fly:CreateInstance('Part', 'Part', {Transparency = 1, Size = vector.create(2, 0.2, 2), Anchored = true, CanTouch = false, CanQuery = false, CastShadow = false, AudioCanCollide = false, Parent = workspace})
                        Fly:Clean(RunService.PostSimulation:Connect(function()
                            if not CharacterLib.Alive then return end
                            local Y = -(CharacterLib.HipHeight + 0.1)
                            Part.CFrame = CharacterLib.Root.CFrame * CFrame.new(0, Y, 0)
                        end))
                    end
                    
                    for i = 1, 0, -1 do
                        Fly:Clean(UIS[i == 1 and 'InputBegan' or 'InputEnded']:Connect(function(Input)
                            if i == 1 and UIS:GetFocusedTextBox() then return end
                            if Input.KeyCode == Enum.KeyCode.W then
                                W = i
                            elseif Input.KeyCode == Enum.KeyCode.A then
                                A = i
                            elseif Input.KeyCode == Enum.KeyCode.S then
                                S = i
                            elseif Input.KeyCode == Enum.KeyCode.D then
                                D = i
                            elseif UpKeybind:Check(Input) then
                                E = i
                            elseif DownKeybind:Check(Input) then
                                Q = i
                            end
                        end))
                    end
                else
                    if CharacterLib.Alive and State.Value ~= 'None' then
                        if State.Value == 'PlatformStand' then
                            CharacterLib.Humanoid.PlatformStand = false
                        elseif CharacterLib.Humanoid:GetState() == Enum.HumanoidStateType[State.Value] then
                            CharacterLib.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                        end
                    end
                    W, A, S, D, E, Q = nil, nil, nil, nil, nil, nil
                end
            end
        })

        UpKeybind = Fly:CreateKeybind({
            Name = "Up",
            Keybind = "E",
            Secondary = true
        })

        DownKeybind = Fly:CreateKeybind({
            Name = "Down",
            Keybind = "Q",
            Secondary = true
        })

        HorizontalSpeed = Fly:CreateSlider({
            Name = "Horizontal Speed",
            Default = 50,
            Min = 0,
            Max = 500,
        })

        VerticalSpeed = Fly:CreateSlider({
            Name = "Vertical Speed",
            Default = 50,
            Min = 0,
            Max = 500,
        })

        FlyMethod = Fly:CreateDropdown({
            Name = "Fly Method",
            Info = "BodyVelocity - Adjusts the velocity of your character by using a BodyVelocity object.\nVelocity - Directly adjusts the velocity your character.\nCFrame - Directly adjusts the position of your character.",
            List = {"BodyVelocity", 'LinearVelocity', "Velocity", "CFrame"},
            Function = function(Val)
                if Fly.Enabled then
                    if Val ~= 'BodyVelocity' then
                        Fly:RemoveInstance('BodyVelocity')
                    end
                    if Val ~= 'LinearVelocity' then
                        Fly:RemoveInstance('LinearVelocity')
                        Fly:RemoveInstance('Attachment')
                    end
                end
            end
        })

        AlignMethod = Fly:CreateDropdown({
            Name = "Align Method",
            List = {"AlignOrientation", "CFrame", "None"},
            Info = 'AlignOrientation - Smoothly adjusts your character\'s orientation.\nCFrame - Directly adjusts the CFrame of your character.\nNone - Doesn\'t align your character at all.',
            Function = function(Val)
                if Fly.Enabled then
                    if Val ~= 'AlignOrientation' then
                        Fly:RemoveInstance('AlignOrientation')
                        Fly:RemoveInstance('Attachment2')
                    end
                end
            end
        })

        MoveMethod = Fly:CreateDropdown({
            Name = 'Move Method',
            List = {'Camera', 'MoveDirection'},
        })

        State = Fly:CreateDropdown({
            Name = 'State',
            List = {'None', 'PlatformStand', 'FallingDown', 'Ragdoll', 'GettingUp', 'Jumping', 'Swimming', 'Freefall', 'Flying', 'Landed', 'Running', 'RunningNoPhysics', 'StrafingNoPhysics', 'Climbing', 'Seated', 'Physics'},
            Function = function(Val)
                if Fly.Enabled and CharacterLib.Alive and Val == 'None' then
                    CharacterLib.Humanoid:ChangeState(CharacterLib.Humanoid.FloorMaterial == Enum.Material.Air and Enum.HumanoidStateType.Freefall or Enum.HumanoidStateType.Running)
                end
            end
        })

        Platform = Fly:CreateToggle({
            Name = 'Platform',
            Info = 'Creates an invisible part below you to fake your humanoid\'s floor material.',
            Function = function()
                if Fly.Enabled then
                    Fly:Toggle(true)
                    Fly:Toggle(true)
                end
            end
        })

        UsePercentage = Fly:CreateToggle({
            Name = "Use Percentage",
            Info = "Uses speed based off a percentage of your humanoid's walk speed.",
            Function = function(Enabled)
                Percentage:SetVisible(Enabled)
            end
        })

        Percentage = Fly:CreateSlider({
            Name = "Percentage",
            Default = 110,
            Min = 0,
            Max = 200,
            Suffix = "%",
            Visible = false,
        })
    end)

    Run(function() -- FastClimb
        local FastClimb, Speed, Method, ResetVel

        local Functions = {
            Velocity = function()
                if CharacterLib.Humanoid.MoveDirection ~= vector.zero then
                    CharacterLib.Root.AssemblyLinearVelocity = vector.create(CharacterLib.Root.AssemblyLinearVelocity.X, math.sign(CharacterLib.Root.AssemblyLinearVelocity.Y) * Speed.Value, CharacterLib.Root.AssemblyLinearVelocity.Z)
                end
            end,
            CFrame = function(Delta)
                local Vector = vector.create(0, (Speed.Value - (CharacterLib.Humanoid.WalkSpeed * 0.7)) * Delta, 0)
                CharacterLib.Character:TranslateBy(Vector)
            end
        }

        FastClimb = Movement:CreateModule({
            Name = 'FastClimb',
            Info = 'Increases the speed at which you climb ladders.',
            Enabled = function()
                local Climbed
                FastClimb:Clean(RunService.PreSimulation:Connect(function(Delta)
                    if not CharacterLib.Alive then return end
                    local State = CharacterLib.Humanoid:GetState()
                    if State == Enum.HumanoidStateType.Climbing then
                        Functions[Method.Value](Delta)
                        Climbed = true
                    elseif Climbed then
                        if Method.Value == 'Velocity' and ResetVel.Enabled then
                            CharacterLib.Root.AssemblyLinearVelocity = vector.create(CharacterLib.Root.AssemblyLinearVelocity.X, 0, CharacterLib.Root.AssemblyLinearVelocity.Z)
                        end
                        Climbed = nil
                    end
                end))
            end
        })

        Speed = FastClimb:CreateSlider({
            Name = 'Speed',
            Default = 16,
            Min = 1,
            Max = 64
        })

        Method = FastClimb:CreateDropdown({
            Name = 'Method',
            List = {'Velocity', 'CFrame'},
            Info = 'Velocity - Increases the Y velocity of your character.\nCFrame - Directly adjusts the Y position of your character.',
            Function = function(Val)
                ResetVel:SetVisible(Val == 'Velocity')
            end
        })

        ResetVel = FastClimb:CreateToggle({
            Name = 'Reset Y Velocity',
            Info = 'Resets your Y velocity back to zero after climbing a ladder.',
        })
    end)

    Run(function() -- Spider
        local Spider, Speed, Radius, Method, ResetVel, MaxNormal, Keybind

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true
        Params.IgnoreWater = true

        local Methods = {
            Velocity = function()
                local Vel = CharacterLib.Root.AssemblyLinearVelocity
                CharacterLib.Root.AssemblyLinearVelocity = vector.create(Vel.X, Speed.Value, Vel.Z)
            end,
            CFrame = function(Delta)
                local Vector = vector.create(0, Speed.Value * Delta, 0)
                CharacterLib.Character:TranslateBy(Vector)
            end,
        }

        Spider = Movement:CreateModule({
            Name = 'Spider',
            Info = 'Makes you climb up walls like a spider 🕷️',
            Enabled = function()
                local ClimbedLastFrame = false
                Spider:Clean(RunService.PreSimulation:Connect(function(Delta)
                    if not CharacterLib.Alive then return end
                    local MoveDirection = CharacterLib.Humanoid.MoveDirection * Radius.Value

                    local Exclusions = {CharacterLib.Character}
                    for i, Char in CharacterLib.List do
                        Exclusions[i + 1] = Char
                    end
                    
                    Params.CollisionGroup = CharacterLib.Root.CollisionGroup
                    Params.FilterDescendantsInstances = Exclusions
                    local Raycast = workspace:Raycast(CharacterLib.Root.Position - vector.create(0, CharacterLib.HipHeight - 0.5, 0), MoveDirection, Params)
                    if Raycast and Raycast.Normal.Y <= MaxNormal then
                        ClimbedLastFrame = true
                        Methods[Method.Value](Delta)
                    elseif ClimbedLastFrame then
                        if ResetVel.Enabled then
                            local Vel = CharacterLib.Root.AssemblyLinearVelocity
                            CharacterLib.Root.AssemblyLinearVelocity = vector.create(Vel.X, 0, Vel.Z)
                        end
                        ClimbedLastFrame = false
                    end
                end))
            end,
        })

        Speed = Spider:CreateSlider({
            Name = 'Speed',
            Default = 20,
            Min = 0,
            Max = 50,
        })

        Radius = Spider:CreateSlider({
            Name = 'Radius',
            Default = 3,
            Min = 1,
            Max = 9,
            Decimal = 10
        })

        Spider:CreateSlider({
            Name = 'Max Angle',
            Default = 10,
            Min = 0,
            Max = 90,
            Function = function(Val)
                MaxNormal = 1 - math.cos(math.rad(Val))
            end
        })
        MaxNormal = 1 - math.cos(math.rad(10))

        Method = Spider:CreateDropdown({
            Name = 'Method',
            List = {'Velocity', 'CFrame'},
            Function = function(Val)
                ResetVel:SetVisible(Val == 'Velocity')
            end,
        })

        ResetVel = Spider:CreateToggle({
            Name = 'Reset Vel',
            Info = 'Resets your Y velocity back to zero after climbing over a wall.'
        })
    end)

    Run(function() -- Float
        local Float, Color, UpOffset, DownOffset, UpKeybind, DownKeybind
        local E, Q, EDown, QDown
        local Part

        Float = Movement:CreateModule({
            Name = "Float",
            Info = "Creates a part below you allowing you to float",
            Enabled = function()
                Part = Float:CreateInstance('Part', 'Part', {Color = Color.Color, Transparency = Color.Transparency, Size = vector.create(2, 0.2, 2), Anchored = true, CanTouch = false, CanQuery = false, CastShadow = false, AudioCanCollide = false, Parent = workspace})

                E, Q = UpKeybind:IsPressed() and 1 or 0, DownKeybind:IsPressed() and 1 or 0
                EDown, QDown = E == 1, Q == 1

                Float:Clean(RunService.PostSimulation:Connect(function()
                    if not CharacterLib.Alive then return end
                    local Offset = (CharacterLib.HipHeight - CharacterLib.Root.Size.Y)
                    local Y = -(CharacterLib.HipHeight + 0.1) + ((E - Q) * Offset) + ((EDown and UpOffset.Value or 0) - (QDown and DownOffset.Value or 0))
                    Part.CFrame = CharacterLib.Root.CFrame * CFrame.new(0, Y, 0)
                end))

                for i = 1, 0, -1 do
                    Float:Clean(UIS[i == 1 and 'InputBegan' or 'InputEnded']:Connect(function(Input)
                        if i == 1 and UIS:GetFocusedTextBox() then return end
                        if UpKeybind:Check(Input) then
                            E = i
                            EDown = E == 1
                        elseif DownKeybind:Check(Input) then
                            Q = i
                            QDown = Q == 1
                        end
                    end))
                end
            end
        })
        
        UpOffset = Float:CreateSlider({
            Name = "Up Offset",
            Default = 0,
            Min = 0,
            Max = 1,
            Decimal = 1000
        })

        DownOffset = Float:CreateSlider({
            Name = "Down Offset",
            Default = 0,
            Min = 0,
            Max = 1,
            Decimal = 1000
        })

        UpKeybind = Float:CreateKeybind({
            Name = "Up",
            Keybind = "E",
            Secondary = true
        })

        DownKeybind = Float:CreateKeybind({
            Name = "Down",
            Keybind = "Q",
            Secondary = true
        })

        Color = Float:CreateColorPicker({
            Name = "Color",
            Default = Color3.fromRGB(163, 162, 165),
            Function = function(Color, Transparency)
                if Part then
                    Part.Color = Color
                    Part.Transparency = Transparency
                end
            end
        })
    end)

    Run(function() -- WalkFling
        local WalkFling, FlingPower, AddMoveDirection, FlingDirection

        local Directions = {
            Up = vector.create(0, 1, 0),
            Down = vector.create(0, 1, 0),
            None = vector.zero
        }

        WalkFling = Movement:CreateModule({
            Name = "WalkFling",
            Info = "Flings players when you touch them.",
            Enabled = function()
                if Modules.Noclip and not Modules.Noclip.Enabled then
                    Modules.Noclip:Toggle(true)
                end
                WalkFling:Clean(RunService.PostSimulation:Connect(function()
                    if not CharacterLib.Alive then return end
                    local Vel = CharacterLib.Root.AssemblyLinearVelocity
                    local Unit = vector.normalize(Vel)
                    local NewVel = AddMoveDirection.Enabled and (Unit == Unit and Unit or vector.zero) + Directions[FlingDirection.Value] or Directions[FlingDirection.Value]
                    CharacterLib.Root.AssemblyLinearVelocity = NewVel * FlingPower.Value
                    RunService.PreRender:Wait()
                    if not CharacterLib.Alive then return end
                    CharacterLib.Root.AssemblyLinearVelocity = Vel
                end))
            end
        })

        FlingPower = WalkFling:CreateSlider({
            Name = 'Fling Power',
            Default = 10000,
            Min = 1,
            Max = 10000,
        })

        AddMoveDirection = WalkFling:CreateToggle({
            Name = 'Add Move Velocity',
            Info = 'Adds the velocity from you moving to the fling velocity.'
        })

        FlingDirection = WalkFling:CreateDropdown({
            Name = 'Fling Direction',
            List = {'Up', 'Down', 'None'},
        })
    end)

    Run(function() -- ClickTP
        local ClickTeleport, Keybind

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true

        ClickTeleport = Movement:CreateModule({
            Name = "ClickTP",
            Info = "Teleports you to your mouse's location when you hold your keybind and click",
            Enabled = function()
                ClickTeleport:Clean(UIS.InputBegan:Connect(function(Input)
                    if UIS:GetFocusedTextBox() or not CharacterLib.Alive then return end
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 and Keybind:IsPressed() then
                        Params.FilterDescendantsInstances = {CharacterLib.Character}
                        local MouseLocation = UIS:GetMouseLocation()
                        local MouseRaycast = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)
                        local Raycast = workspace:Raycast(MouseRaycast.Origin, MouseRaycast.Direction * 9e9, Params)
                        if Raycast then
                            local HitPos = ModY(Raycast.Position, Raycast.Position.Y + CharacterLib.HipHeight)
                            local _, Y = CFrame.lookAt(CharacterLib.Root.Position, HitPos):ToOrientation()
                            CharacterLib.Root.CFrame = CFrame.new(HitPos) * CFrame.Angles(0, Y, 0)
                        end
                    end
                end))
            end
        })

        Keybind = ClickTeleport:CreateKeybind({
            Name = "Teleport",
            Keybind = "R"
        })
    end)

    Run(function() -- CFrameFly
        local CFrameFly, UpKeybind, DownKeybind, CFrameFlySpeed, GoBackToOriginalPosition, ShowOriginalPosition, Color, Thickness, PositionPreset

        local TracerPositions = {
            TopLeft = Path2DControlPoint.new(UDim2.fromScale(0, 0)),
            Top = Path2DControlPoint.new(UDim2.fromScale(0.5, 0)),
            TopRight = Path2DControlPoint.new(UDim2.fromScale(1, 0)),
            Left = Path2DControlPoint.new(UDim2.fromScale(0, 0.5)),
            Middle = Path2DControlPoint.new(UDim2.fromScale(0.5, 0.5)),
            Right = Path2DControlPoint.new(UDim2.fromScale(1, 0.5)),
            BottomLeft = Path2DControlPoint.new(UDim2.fromScale(0, 1)),
            Bottom = Path2DControlPoint.new(UDim2.fromScale(0.5, 1)),
            BottomRight = Path2DControlPoint.new(UDim2.fromScale(1, 1)),
        }

        local From = TracerPositions.Bottom

        local function GetFrom()
            local Preset = PositionPreset.Value
            if Preset == "Mouse" then
                local MouseLocation = UIS:GetMouseLocation()
                return Path2DControlPoint.new(UDim2.fromOffset(MouseLocation.X, MouseLocation.Y))
            else
                return From
            end
        end

        CFrameFly = Movement:CreateModule({
            Name = "CFrameFly",
            Info = "Works like normal fly except it doesn't update your position to other players.",
            Function = function(Enabled)
                if Enabled then
                    local ScreenGui = CFrameFly:CreateInstance('ScreenGui', 'ScreenGui', {IgnoreGuiInset = true, Name = 'CFrameFlyTracers', Parent = TidalWave.Gui})
                    local Tracer = CFrameFly:CreateInstance('Path2D', 'Tracer', {Name = 'OriginalLocation', Color3 = Color.Color, Thickness = Thickness.Value, Visible = false, Parent = ScreenGui})

                    local E, Q = UpKeybind:IsPressed() and 1 or 0, DownKeybind:IsPressed() and 1 or 0
                    local OldCFrame

                    CFrameFly:Clean(RunService.PreRender:Connect(function()
                        if CharacterLib.Alive and not OldCFrame then
                            OldCFrame = CharacterLib.Root.CFrame
                            CFrameFly:Clean(function()
                                if GoBackToOriginalPosition.Enabled and CharacterLib.Alive then
                                    CharacterLib.Root.CFrame = OldCFrame
                                end
                            end)
                        end
                        if ShowOriginalPosition.Enabled then
                            local Vector, OnScreen = Camera:WorldToViewportPoint(OldCFrame.Position)
                            if OnScreen then
                                Tracer.Color3 = Color.Color
                                Tracer.Thickness = Thickness.Value
                                Tracer:SetControlPoints({GetFrom(), Path2DControlPoint.new(UDim2.fromOffset(Vector.X, Vector.Y))})
                            end
                            Tracer.Visible = OnScreen
                        else
                            Tracer.Visible = false
                        end
                    end))
                    CFrameFly:Clean(RunService.PostSimulation:Connect(function(Delta)
                        if not CharacterLib.Alive then return end
                        CharacterLib.Root.Anchored = true
                        local CameraOffset = CharacterLib.Root.CFrame:ToObjectSpace(Camera.CFrame).Position
                        Camera.CFrame *= CFrame.new(-CameraOffset.X, -CameraOffset.Y, -CameraOffset.Z + 1)
                        local ModdedCameraPos = vector.create(CharacterLib.Root.CFrame.Position.X, Camera.CFrame.Position.Y, CharacterLib.Root.CFrame.Position.Z)
                        local ObjectSpaceVelocity = CFrame.lookAt(Camera.CFrame.Position, ModdedCameraPos)
                        local MoveDirection =  CharacterLib.Humanoid.MoveDirection + vector.create(0, E - Q, 0)
                        ObjectSpaceVelocity = ObjectSpaceVelocity:VectorToObjectSpace(MoveDirection * (CFrameFlySpeed.Value * Delta))
                        CharacterLib.Root.CFrame = CFrame.new(CharacterLib.Root.CFrame.Position) * (Camera.CFrame - Camera.CFrame.Position) * CFrame.new(ObjectSpaceVelocity)
                    end))

                    for i = 1, 0, -1 do
                        CFrameFly:Clean(UIS[i == 1 and 'InputBegan' or 'InputEnded']:Connect(function(Input)
                            if i == 1 and UIS:GetFocusedTextBox() then return end
                            if UpKeybind:Check(Input) then
                                E = i
                            elseif DownKeybind:Check(Input) then
                                E = i
                            end
                        end))
                    end
                else
                    if CharacterLib.Alive then
                        CharacterLib.Root.Anchored = false
                    end
                end
            end,
        })

        CFrameFlySpeed = CFrameFly:CreateSlider({
            Name = "CFrame Fly Speed",
            Default = 50,
            Min = 0,
            Max = 500,
        })

        GoBackToOriginalPosition = CFrameFly:CreateToggle({
            Name = "Go Back To Original Position",
            Info = "Brings you back to the location you started at."
        })

        ShowOriginalPosition = CFrameFly:CreateToggle({
            Name = "Show Origin Tracer",
            Info = "Creates a tracer pointing to the location you started at.",
        })

        Color = CFrameFly:CreateColorPicker({
            Name = "Tracer Color",
            Default = Color3.fromRGB(255, 255, 255)
        })

        Thickness = CFrameFly:CreateSlider({
            Name = "Tracer Thickness",
            Default = 1,
            Min = 1,
            Max = 5,
            Function = function(Val)
                local Tracer = CFrameFly:GetInstance('Tracer')
                if Tracer then
                    Tracer.Thickness = Val
                end
            end
        })

        PositionPreset = CFrameFly:CreateDropdown({
            Name = "Position",
            List = {"Bottom", "Bottom Left", "Bottom Right", "Top Left", "Top", "Top Right", "Left", "Middle", "Right", "Mouse"},
            Function = function(Val)
                From = TracerPositions[Val]
            end
        })

        UpKeybind = CFrameFly:CreateKeybind({
            Name = "Up",
            Keybind = "E",
            Secondary = true
        })

        DownKeybind = CFrameFly:CreateKeybind({
            Name = "Down",
            Keybind = "Q",
            Secondary = true
        })
    end)

    Run(function() -- Timer
        local Timer, Speed

        Timer = Movement:CreateModule({
            Name = 'Timer',
            Info = 'Changes the speed of your character.',
            Enabled = function()
                Timer:Clean(RunService.PreRender:Connect(function(Delta)
                    if CharacterLib.Alive and Speed.Value > 1 then
                        RunService:Pause()
                        workspace:StepPhysics(Delta * (Speed.Value - 1), {CharacterLib.Root})
                        RunService:Run()
                    end
                end))
            end
        })

        Speed = Timer:CreateSlider({
            Name = 'Speed',
            Default = 1,
            Min = 1,
            Max = 5,
            Decimal = 10,
        })
    end)

    Run(function() -- Spin
        local Spin, Speed, AngularVelocity

        local HugeVector = vector.create(0, math.huge, 0)

        local function DestroyAngularVelocity()
            if AngularVelocity then
                AngularVelocity:Destroy()
                AngularVelocity = nil
            end
        end

        local function AddAngularVelocity(Player)
            DestroyAngularVelocity()
            AngularVelocity = Instance.new("BodyAngularVelocity")
            AngularVelocity.MaxTorque = HugeVector
            AngularVelocity.AngularVelocity = vector.create(0, Speed.Value, 0)
            AngularVelocity.Parent = Player.Root
        end

        Spin = Movement:CreateModule({
            Name = "Spin",
            Info = "Makes you spin",
            Function = function(Enabled)
                if Enabled then
                    Spin:Clean(CharacterLib.Events.LocalAdded:Connect(AddAngularVelocity))
                    if CharacterLib.Alive then
                        AddAngularVelocity(CharacterLib)
                    end
                else
                    DestroyAngularVelocity()
                end
            end
        })

        Speed = Spin:CreateSlider({
            Name = "Speed",
            Default = 45,
            Min = 0,
            Max = 360,
            Function = function(Val)
                if AngularVelocity then
                    AngularVelocity.AngularVelocity = vector.create(0, Speed.Value, 0)
                end
            end
        })
    end)

    Run(function() -- Swim
        local Swim, Speed, UsePercentage, Percentage, UseLimits, MinSpeed, MaxSpeed, SetEnabledChanged
        local UpKeybind, DownKeybind
        local W, A, S, D, Q, E

        local DisabledStates = Enum.HumanoidStateType:GetEnumItems()
        DisabledStates[17] = nil
        table.remove(DisabledStates, 15)
        table.remove(DisabledStates, 5)
        local PrevStates = {}

        local function LocalAdded()
            if SetEnabledChanged then
                SetEnabledChanged:Disconnect()
            end
            table.clear(PrevStates)
            for _, State in DisabledStates do
                PrevStates[State] = CharacterLib.Humanoid:GetStateEnabled(State)
                if PrevStates[State] then
                    CharacterLib.Humanoid:SetStateEnabled(State, false)
                end
            end
            local db = false
            SetEnabledChanged = Swim:Clean(CharacterLib.Humanoid.StateEnabledChanged:Connect(function(State, Enabled)
                if db then return end
                db = true
                PrevStates[State] = Enabled
                if Enabled then
                    CharacterLib.Humanoid:SetStateEnabled(State, false)
                end
                db = false
            end))
            CharacterLib.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        end

        local function LocalRemoved()
            if SetEnabledChanged then
                SetEnabledChanged:Disconnect()
                SetEnabledChanged = nil
            end
            table.clear(PrevStates)
        end

        Swim = Movement:CreateModule({
            Name = "Swim",
            Info = "Makes you swim.",
            Function = function(Enabled)
                if Enabled then
                    Swim:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                    Swim:Clean(CharacterLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if CharacterLib.Alive then
                        LocalAdded()
                    end

                    W, A, S, D, E, Q = UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0, UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0, UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0, UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0, UpKeybind:IsPressed()  and 1 or 0, DownKeybind:IsPressed() and 1 or 0

                    for i = 1, 0, -1 do
                        Swim:Clean(UIS[i == 1 and 'InputBegan' or 'InputEnded']:Connect(function(Input)
                            if Input.KeyCode == Enum.KeyCode.W then
                                W = i
                            elseif Input.KeyCode == Enum.KeyCode.A then
                                A = i
                            elseif Input.KeyCode == Enum.KeyCode.S then
                                S = i
                            elseif Input.KeyCode == Enum.KeyCode.D then
                                D = i
                            elseif UpKeybind:Check(Input) then
                                E = i
                            elseif DownKeybind:Check(Input) then
                                Q = i
                            end
                        end))
                    end

                    Swim:Clean(RunService.PreSimulation:Connect(function(Delta)
                        local Vel
                        if CharacterLib.Alive then
                            Vel = CharacterLib.Root.AssemblyLinearVelocity + vector.create(0, Delta * workspace.Gravity, 0)
                            CharacterLib.Root.AssemblyLinearVelocity = Vel
                        end
                        RunService.PostSimulation:Wait()
                        if CharacterLib.Alive then
                            if W > 0 or A > 0 or S > 0 or D > 0 or E > 0 or Q > 0 then
                                local Multi = UsePercentage.Enabled and (CharacterLib.Humanoid.WalkSpeed * (Percentage.Value / 100)) or Speed.Value
                                if UsePercentage.Enabled and UseLimits.Enabled then
                                    Multi = math.clamp(Multi, MinSpeed.Value, MaxSpeed.Value)
                                end
                                CharacterLib.Root.AssemblyLinearVelocity = ((Camera.CFrame.LookVector * (W - S)) + (Camera.CFrame.RightVector * (D - A)) + (Camera.CFrame.UpVector * (E - Q))).Unit * Multi
                            else
                                CharacterLib.Root.AssemblyLinearVelocity = vector.zero
                            end
                        end
                    end))
                else
                    if CharacterLib.Alive then
                        for State, Enabled in PrevStates do
                            CharacterLib.Humanoid:SetStateEnabled(State, Enabled)
                        end
                    end
                    table.clear(PrevStates)
                end
            end
        })

        UpKeybind = Swim:CreateKeybind({
            Name = "Up",
            Keybind = "Space",
            Secondary = true
        })

        DownKeybind = Swim:CreateKeybind({
            Name = "Down",
            Secondary = true
        })

        Speed = Swim:CreateSlider({
            Name = 'Speed',
            Default = CharacterLib.Alive and math.floor(CharacterLib.Humanoid.WalkSpeed) or 16,
            Min = 0,
            Max = 64
        })

        UsePercentage = Swim:CreateToggle({
            Name = "Use Percentage",
            Info = "Uses speed based off a percentage of your humanoid's walk speed.",
            Function = function(Enabled)
                Percentage:SetVisible(Enabled)
                UseLimits:SetVisible(Enabled)
                MinSpeed:SetVisible(Enabled and UseLimits.Enabled)
                MaxSpeed:SetVisible(Enabled and UseLimits.Enabled)
            end,
        })

        Percentage = Swim:CreateSlider({
            Name = "Percentage",
            Min = 0,
            Default = 110,
            Max = 200,
            Suffix = "%",
            Visible = false
        })

        UseLimits = Swim:CreateToggle({
            Name = 'Use Limits',
            Info = 'Limits the speed calculated by Speed Percentage between the minimum and maximum values.',
            Visible = false,
            Function = function(Enabled)
                MinSpeed:SetVisible(Enabled)
                MaxSpeed:SetVisible(Enabled)
            end,
        })

        MinSpeed = Swim:CreateSlider({
            Name = "Min Speed",
            Default = 0,
            Min = 0,
            Max = 32,
            Visible = false
        })

        MaxSpeed = Swim:CreateSlider({
            Name = 'Max Speed',
            Default = 32,
            Min = 0,
            Max = 64,
            Visible = false
        })
    end)
end)

Run(function() -- Visuals
    Run(function() -- FullBright
        local FullBright, Bloom

        local AtmosphereProperties = {"Density", "Offset", "Glare", "Haze"}
        local LightingProperties = {}
        local EnabledProperties = {}
        
		local function AddAtmosphere(Atmosphere)
            for _, v in AtmosphereProperties do
                Atmosphere[v] = 0
                FullBright:Clean(Atmosphere:GetPropertyChangedSignal(v):Connect(function()
                    Atmosphere[v] = 0
                end))
            end
		end

        local function AddEffect(Effect)
            local Enabled = Effect == Bloom
            Effect.Enabled = Enabled
            FullBright:Clean(Effect:GetPropertyChangedSignal("Enabled"):Connect(function()
                Effect.Enabled = Enabled
            end))
        end

        FullBright = Visuals:CreateModule({
            Name = "FullBright",
            Info = "Increases the brightness of lighting and removes visual effects that can make it harder to see.",
            Function = function(Enabled)
                if Enabled then
                    Bloom = Instance.new("BloomEffect")
                    Bloom.Intensity = 0
                    Bloom.Size = 0
                    Bloom.Threshold = 0
                    Bloom.Parent = Lighting

                    for i, v in LightingProperties do
                        if EnabledProperties[i].Enabled then
                            Lighting[i] = v.Value or v.Color
                        end
                        Lighting:GetPropertyChangedSignal(i):Connect(function()
                            if EnabledProperties[i].Enabled then
                                Lighting[i] = v.Value or v.Color
                            end
                        end)
                    end

                    FullBright:Clean(Lighting.DescendantAdded:Connect(function(Descendant)
                        if Descendant.ClassName == "Atmosphere" then
                            AddAtmosphere(Descendant)
                        elseif Descendant:IsA("PostEffect") then
                            AddEffect(Descendant)
                        end
                    end))

                    FullBright:Clean(Camera.DescendantAdded:Connect(function(Descendant)
                        if Descendant:IsA("PostEffect") then
                            AddEffect(Descendant)
                        end
                    end))

                    for _, Effect in Lighting:QueryDescendants("Atmosphere, PostEffect") do
                        if Effect.ClassName == "Atmosphere" then
                            AddAtmosphere(Effect)
                        elseif Effect:IsA("PostEffect") then
                            AddEffect(Effect)
                        end
                    end
                    for _, Effect in Camera:QueryDescendants("PostEffect") do
                        if Effect:IsA("PostEffect") then
                            AddEffect(Effect)
                        end
                    end
                else
                    if Bloom then
                        Bloom:Destroy()
                        Bloom = nil
                    end
                end
            end
        })

        EnabledProperties.ExposureCompensation = FullBright:CreateToggle({
            Name = "Set Exposure",
            Function = function(Enabled)
                LightingProperties.ExposureCompensation:SetVisible(Enabled)
            end
        })

        LightingProperties.ExposureCompensation = FullBright:CreateSlider({
            Name = "Exposure",
            Default = 0,
            Min = -3,
            Max = 3,
            Decimal = 100,
            Function = function(Val)
                if FullBright.Enabled then
                    Lighting.ExposureCompensation = Val
                end
            end
        })
        
        EnabledProperties.Brightness = FullBright:CreateToggle({
            Name = "Set Brightness",
            Function = function(Enabled)
                LightingProperties.Brightness:SetVisible(Enabled)
            end
        })

        LightingProperties.Brightness = FullBright:CreateSlider({
            Name = "Brightness",
            Default = 3,
            Min = 0,
            Max = 10,
            Decimal = 10,
            Function = function(Val)
                if FullBright.Enabled then
                    Lighting.Brightness = Val
                end
            end
        })

        EnabledProperties.Ambient = FullBright:CreateToggle({
            Name = "Set Ambient",
            Function = function(Enabled)
                LightingProperties.Ambient:SetVisible(Enabled)
            end
        })

        LightingProperties.Ambient = FullBright:CreateColorPicker({
            Name = "Ambient",
            Default = Color3.White,
            Function = function(Color)
                if FullBright.Enabled then
                    Lighting.Ambient = Color
                end
            end
        })

        EnabledProperties.OutdoorAmbient = FullBright:CreateToggle({
            Name = "Set Outdoor Ambient",
            Function = function(Enabled)
                LightingProperties.OutdoorAmbient:SetVisible(Enabled)
            end
        })

        LightingProperties.OutdoorAmbient = FullBright:CreateColorPicker({
            Name = "Outdoor Ambient",
            Default = Color3.White,
            Function = function(Color)
                if FullBright.Enabled then
                    Lighting.OutdoorAmbient = Color
                end
            end
        })

        EnabledProperties.ColorShift_Bottom = FullBright:CreateToggle({
            Name = "Set Color Shift Bottom",
            Function = function(Enabled)
                LightingProperties.ColorShift_Bottom:SetVisible(Enabled)
            end
        })

        LightingProperties.ColorShift_Bottom = FullBright:CreateColorPicker({
            Name = "Color Shift Bottom",
            Default = Color3.White,
            Function = function(Color)
                if FullBright.Enabled then
                    Lighting.ColorShift_Bottom = Color
                end
            end
        })

        EnabledProperties.ColorShift_Top = FullBright:CreateToggle({
            Name = "Set Color Shift Top",
            Function = function(Enabled)
                LightingProperties.ColorShift_Top:SetVisible(Enabled)
            end
        })

        LightingProperties.ColorShift_Top = FullBright:CreateColorPicker({
            Name = "Color Shift Top",
            Default = Color3.White,
            Function = function(Color)
                if FullBright.Enabled then
                    Lighting.ColorShift_Top = Color
                end
            end
        })

        EnabledProperties.GlobalShadows = FullBright:CreateToggle({
            Name = "Set Shadows",
            Function = function(Enabled)
                LightingProperties.GlobalShadows:SetVisible(Enabled)
            end
        })

        LightingProperties.GlobalShadows = FullBright:CreateToggle({
            Name = "Shadows",
            Function = function(Enabled)
                if FullBright.Enabled then
                    Lighting.GlobalShadows = Enabled
                end
            end
        })

        EnabledProperties.EnvironmentDiffuseScale = FullBright:CreateToggle({
            Name = "Set Diffuse Scale",
            Function = function(Enabled)
                LightingProperties.EnvironmentDiffuseScale:SetVisible(Enabled)
            end
        })

        LightingProperties.EnvironmentDiffuseScale = FullBright:CreateSlider({
            Name = "Diffuse Scale",
            Default = 0,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = function(Val)
                if FullBright.Enabled then
                    Lighting.EnvironmentDiffuseScale = Val
                end
            end
        })

        EnabledProperties.EnvironmentSpecularScale = FullBright:CreateToggle({
            Name = "Set Specular Scale",
            Function = function(Enabled)
                LightingProperties.EnvironmentSpecularScale:SetVisible(Enabled)
            end
        })

        LightingProperties.EnvironmentSpecularScale = FullBright:CreateSlider({
            Name = "Specular Scale",
            Default = 0,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = function(Val)
                if FullBright.Enabled then
                    Lighting.EnvironmentSpecularScale = Val
                end
            end
        })

        EnabledProperties.ClockTime = FullBright:CreateToggle({
            Name = "Set Clock Time",
            Function = function(Enabled)
                LightingProperties.ClockTime:SetVisible(Enabled)
            end
        })

        LightingProperties.ClockTime = FullBright:CreateSlider({
            Name = "Clock Time",
            Default = 12,
            Min = 0,
            Max = 24,
            Decimal = 10,
            Function = function(Val)
                if FullBright.Enabled and Val >= 0 then
                    Lighting.ClockTime = Val
                end
            end
        })

        EnabledProperties.FogStart = FullBright:CreateToggle({
            Name = "Set Fog Start",
            Function = function(Enabled)
                LightingProperties.FogStart:SetVisible(Enabled)
            end
        })

        LightingProperties.FogStart = FullBright:CreateSlider({
            Name = "Fog Start",
            Default = Lighting.FogStart,
            Min = 0,
            Max = 100,
            Function = function(Val)
                if FullBright.Enabled then
                    Lighting.FogStart = Val
                end
            end
        })

        EnabledProperties.FogEnd = FullBright:CreateToggle({
            Name = "Set Fog End",
            Function = function(Enabled)
                LightingProperties.FogEnd:SetVisible(Enabled)
            end
        })

        LightingProperties.FogEnd = FullBright:CreateSlider({
            Name = "Fog End",
            Default = 100000,
            Min = 0,
            Max = 100000,
            Function = function(Val)
                if FullBright.Enabled then
                    Lighting.FogEnd = Val
                end
            end
        })

        EnabledProperties.FogColor = FullBright:CreateToggle({
            Name = "Set Fog Color",
            Function = function(Enabled)
                LightingProperties.FogColor:SetVisible(Enabled)
            end
        })

        LightingProperties.FogColor = FullBright:CreateColorPicker({
            Name = "Fog Color",
            Default = Color3.White,
            Function = function(Color)
                if FullBright.Enabled then
                    Lighting.FogColor = Color
                end
            end
        })

        for _, v in EnabledProperties do
            v:Toggle()
        end
    end)

    Run(function() -- WaterModifer
        local WaterSettings, WaterColor, WaterTransparency, WaterReflectance, WaterWaveSize, WaterWaveSpeed

        local Terrain = workspace.Terrain
        
        local function UpdateWaterSettings()
            if not WaterSettings.Enabled then return end
            Terrain.WaterColor = WaterColor.Color
            Terrain.WaterTransparency = WaterTransparency.Value
            Terrain.WaterReflectance = WaterReflectance.Value
            Terrain.WaterWaveSize = WaterWaveSize.Value
            Terrain.WaterWaveSpeed = WaterWaveSpeed.Value
        end

        WaterSettings = Visuals:CreateModule({
            Name = "WaterModifier",
            Info = "Allows you to modify different properties of terrain water",
            Enabled = function()
                WaterSettings:Clean(Terrain.Changed:Connect(UpdateWaterSettings))
                UpdateWaterSettings()
            end
        })

        WaterColor = WaterSettings:CreateColorPicker({
            Name = "Water Color",
            Default = Terrain.WaterColor,
            Function = UpdateWaterSettings
        })
        WaterTransparency = WaterSettings:CreateSlider({
            Name = "Water Transparency",
            Default = Terrain.WaterTransparency,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = UpdateWaterSettings
        })
        WaterReflectance = WaterSettings:CreateSlider({
            Name = "Water Reflectance",
            Default = Terrain.WaterReflectance,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = UpdateWaterSettings
        })
        WaterWaveSize = WaterSettings:CreateSlider({
            Name = "Water Wave Size",
            Default = Terrain.WaterWaveSize,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = UpdateWaterSettings
        })
        WaterWaveSpeed = WaterSettings:CreateSlider({
            Name = "Water Wave Speed",
            Default = Terrain.WaterWaveSpeed,
            Min = 0,
            Max = 100,
            Function = UpdateWaterSettings
        })
    end)

    Run(function() -- Chams
        local Chams, OutlineColor, FillColor, OutlineTransparency, FillTransparency, TeamCheck, NpcOutlineColor, NpcFillColor, NpcOutlineTransparency, NpcFillTransparency, ShowPlayers, ShowNpcs, UseTeamColor, Folder

        local Highlights = {}

        local function OnCharacterAdded(Char)
            if TeamCheck.Enabled and Char.Teammate then return end
            if not ShowPlayers.Enabled and Char.Player then return end
            if not ShowNpcs.Enabled and Char.NPC then return end

            local TeamColor = UseTeamColor.Enabled and Char and GetTeamColor(Char) or nil

            local Highlight = Instance.new("Highlight")
            Highlight.Name = `{Char.Player and Char.Player.Name or Char.Character.Name}_Chams`
            Highlight.Adornee = Char.Character
            Highlight.OutlineColor = TeamColor or (Char.Player and OutlineColor.Color or NpcOutlineColor.Color)
            Highlight.FillColor = TeamColor or (Char.Player and FillColor.Color or NpcFillColor.Color)
            Highlight.OutlineTransparency = (Char.Player and OutlineTransparency.Value or NpcOutlineTransparency.Value)
            Highlight.FillTransparency = (Char.Player and FillTransparency.Value or NpcFillTransparency.Value)
            Highlight.Parent = Folder

            Highlights[Char.Character] = {
                Highlight = Highlight,
                Character = Char
            }
        end

        local function OnCharacterRemoved(Char)
            local Tab = Highlights[Char.Character]
            if Tab then
                Tab.Highlight:Destroy()
                Highlights[Char.Character] = nil
            end
        end

        local function OnTeamChanged(Char)
            local Tab = Highlights[Char.Character]
            if Tab then
                if TeamCheck.Enabled and Tab.Character.Teammate then
                    OnCharacterRemoved(Tab.Character)
                elseif UseTeamColor.Enabled then
                    local TeamColor = GetTeamColor(Tab.Character)
                    Tab.Highlight.OutlineColor = TeamColor or (Tab.Player and OutlineColor.Color or NpcOutlineColor.Color)
                    Tab.Highlight.FillColor = TeamColor or (Tab.Player and FillColor.Color or NpcFillColor.Color)
                end
            end
        end
        
        Chams = Visuals:CreateModule({
            Name = "Chams",
            Info = "Renders players through walls.",
            Function = function(Enabled)
                if Enabled then
                    Folder = Instance.new("Folder")
                    Folder.Name = "Chams"
                    Folder.Parent = TidalWave.Gui

                    Chams:Clean(CharacterLib.Events.CharacterAdded:Connect(OnCharacterAdded))
                    Chams:Clean(CharacterLib.Events.CharacterRemoved:Connect(OnCharacterRemoved))
                    Chams:Clean(CharacterLib.Events.TeamChanged:Connect(OnTeamChanged))
                    for _, Character in CharacterLib.List do
                        OnCharacterAdded(Character)
                    end
                else
                    if Folder then
                        Folder:Destroy()
                        Folder = nil
                    end
                    table.clear(Highlights)
                end
            end
        })

        local function UpdateHighlights()
            for _, Tab in Highlights do
                local TeamColor = UseTeamColor.Enabled and GetTeamColor(Tab.Character) or nil
                Tab.Highlight.OutlineColor = TeamColor or (Tab.Character.Player and OutlineColor.Color or NpcOutlineColor.Color)
                Tab.Highlight.FillColor = TeamColor or (Tab.Character.Player and FillColor.Color or NpcFillColor.Color)
                Tab.Highlight.OutlineTransparency = (Tab.Character.Player and OutlineTransparency.Value or NpcOutlineTransparency.Value)
                Tab.Highlight.FillTransparency = (Tab.Character.Player and FillTransparency.Value or NpcFillTransparency.Value)
            end
        end

        local Restart = function()
            if Chams.Enabled then
                Chams:Toggle(true)
                Chams:Toggle(true)
            end
        end

        TeamCheck = Chams:CreateToggle({
            Name = "Team Check",
            Info = "Hides teammates",
            Function = Restart
        })

        ShowPlayers = Chams:CreateToggle({
            Name = "Players",
            Info = "Whether or not to show players.",
            Default = true,
            Function = function(Enabled)
                for _, v in {OutlineTransparency, FillTransparency, OutlineColor, FillColor} do
                    v:SetVisible(Enabled)
                end
                Restart()
            end,
        })

        OutlineTransparency = Chams:CreateSlider({
            Name = "Player Outline Transparency",
            Default = 0,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = UpdateHighlights
        })

        FillTransparency = Chams:CreateSlider({
            Name = "Player Fill Transparency",
            Default = 0.5,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = UpdateHighlights
        })

        OutlineColor = Chams:CreateColorPicker({
            Name = "Player Outline Color",
            Default = Color3.fromRGB(255, 255, 255),
            Function = UpdateHighlights
        })

        FillColor = Chams:CreateColorPicker({
            Name = "Player Fill Color",
            Default = Color3.fromRGB(255, 255, 255),
            Function = UpdateHighlights
        })

        ShowNpcs = Chams:CreateToggle({
            Name = "NPCs",
            Info = "Whether or not to show NPCs.",
            Function = function(Enabled)
                Restart()
                for _, v in {NpcOutlineTransparency, NpcFillTransparency, NpcOutlineColor, NpcFillColor} do
                    v:SetVisible(Enabled)
                end
            end,
        })

        NpcOutlineTransparency = Chams:CreateSlider({
            Name = "NPC Outline Transparency",
            Default = 0,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Visible = false,
            Function = UpdateHighlights
        })

        NpcFillTransparency = Chams:CreateSlider({
            Name = "NPC Fill Transparency",
            Default = 0.5,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Visible = false,
            Function = UpdateHighlights
        })

        NpcOutlineColor = Chams:CreateColorPicker({
            Name = "NPC Outline Color",
            Default = Color3.fromRGB(255, 255, 255),
            Visible = false,
            Function = UpdateHighlights
        })

        NpcFillColor = Chams:CreateColorPicker({
            Name = "NPC Fill Color",
            Default = Color3.fromRGB(255, 255, 255),
            Visible = false,
            Function = UpdateHighlights
        })

        UseTeamColor = Chams:CreateToggle({
            Name = "Use Team Color",
            Function = UpdateHighlights
        })
    end)

    Run(function() -- Tracers
        local Tracers, Thickness, Color, TeamCheck, XBoxConnect, HideMainTracer, UseTeamColor, ScreenGui, TracerTarget, TracerOffsetX, TracerOffsetY, TracerOffsetZ

        local TracerOffsetVector = vector.zero

        local PresetPositons = {
            TopLeft = Path2DControlPoint.new(UDim2.fromScale(0, 0)),
            Top = Path2DControlPoint.new(UDim2.fromScale(0.5, 0)),
            TopRight = Path2DControlPoint.new(UDim2.fromScale(1, 0)),
            Left = Path2DControlPoint.new(UDim2.fromScale(0, 0.5)),
            Middle = Path2DControlPoint.new(UDim2.fromScale(0.5, 0.5)),
            Right = Path2DControlPoint.new(UDim2.fromScale(1, 0.5)),
            BottomLeft = Path2DControlPoint.new(UDim2.fromScale(0, 1)),
            Bottom = Path2DControlPoint.new(UDim2.fromScale(0.5, 1)),
            BottomRight = Path2DControlPoint.new(UDim2.fromScale(1, 1)),
        }

        local TracerPath = {
            R15 = {
                LeftFoot = {
                    {"LowerTorso"},
                    {"LeftUpperLeg"},
                    {"LeftLowerLeg"},
                    {"LeftFoot"}
                },
                RightFoot = {
                    {"LowerTorso"},
                    {"RightUpperLeg"},
                    {"RightLowerLeg"},
                    {"RightFoot"}
                },
                LeftHand = {
                    {"LowerTorso"},
                    {"UpperTorso", {vector.create(0, 0.25, 0)}},
                    {"LeftUpperArm"},
                    {"LeftLowerArm"},
                    {"LeftHand"}
                },
                RightHand = {
                    {"UpperTorso", {vector.create(0, 0.25, 0)}},
                    {"RightUpperArm"},
                    {"RightLowerArm"},
                    {"RightHand"}
                },
                Head = {
                    {"UpperTorso", {vector.create(0, 0.25, 0)}},
                    {"Head"}
                }
            },
            R6 = {
                LeftFoot = {
                    {"Torso", {vector.create(0, 0.25, 0), vector.create(0, -0.25, 0)}},
                    {"Left Leg", {vector.create(0, 0.25, 0), vector.create(0, -0.25, 0)}}
                },
                RightFoot = {
                    {"Torso", {vector.create(0, -0.25, 0)}},
                    {"Right Leg", {vector.create(0, 0.25, 0), vector.create(0, -0.25, 0)}}
                },
                LeftHand = {
                    {"Torso", {vector.create(0, 0.25, 0)}},
                    {"Left Arm", {vector.create(0, 0.25, 0), vector.create(0, -0.25, 0)}}
                },
                RightHand = {
                    {"Torso", {vector.create(0, 0.25, 0)}},
                    {"Right Arm", {vector.create(0, 0.25, 0), vector.create(0, -0.25, 0)}}
                },
                Head = {
                    {"Torso", {vector.create(0, 0.25, 0)}},
                    {"Head"}
                }
            }
        }

        local TracerObjects = {}

        local TracerControlPoints = {
            [1] = PresetPositons.Bottom
        }

        local function RenderTracers()
            for _, Tab in TracerObjects do
                local Hide = TeamCheck.Enabled and Tab.Character.Teammate
                if Hide or HideMainTracer.Enabled then
                    Tab.Tracers.Tracer.Visible = false
                else
                    local Part = Tab.Character[TracerTarget.Value] or Tab.Character.Root
                    local Vector, OnScreen = Camera:WorldToViewportPoint(Part.Position + TracerOffsetVector)
                    if OnScreen then
                        TracerControlPoints[2] = Path2DControlPoint.new(UDim2.fromOffset(Vector.X, Vector.Y))
                        Tab.Tracers.Tracer:SetControlPoints(TracerControlPoints)
                        Tab.Tracers.Tracer.Visible = true
                    else
                        Tab.Tracers.Tracer.Visible = false
                    end
                end
                if XBoxConnect.Enabled then
                    for RigType, Data in TracerPath[Tab.Character.RigType.Name] do
                        local CurrentPath2D = Tab.Tracers[RigType]
                        if Hide then
                            CurrentPath2D.Visible = false
                        else
                            local NewControlPoints = {}
                            for _, LimbData in Data do
                                local Limb = Tab.Character.Character:FindFirstChild(LimbData[1])
                                if not Limb then break end
                                local LimbPos, LimbOnScreen
                                if LimbData[2] then
                                    for _, Offset in LimbData[2] do
                                        LimbPos = Limb.CFrame:ToWorldSpace(CFrame.new(Limb.Size * Offset)).Position
                                    end
                                else
                                    LimbPos = Limb.Position
                                end
                                LimbPos, LimbOnScreen = Camera:WorldToViewportPoint(LimbPos)
                                if not LimbOnScreen then break end
                                NewControlPoints[#NewControlPoints + 1] = Path2DControlPoint.new(UDim2.fromOffset(LimbPos.X, LimbPos.Y))
                            end
                            if #NewControlPoints == 0 then
                                CurrentPath2D.Visible = false
                            else
                                CurrentPath2D.Visible = true
                                CurrentPath2D:SetControlPoints(NewControlPoints)
                            end
                        end
                    end
                end
            end
        end

        local function CreateTracer(Char, LimbName)
            local Line = Instance.new("Path2D")
            Line.Name = `{Char.Player and Char.Player.Name or Char.Character.Name}_{LimbName and LimbName .. "_" or ""}Tracer`
            Line.Color3 = UseTeamColor.Enabled and GetTeamColor(Char) or Color.Color
            Line.Thickness = Thickness.Value
            Line.Parent = ScreenGui
            return Line
        end

        local function OnCharacterRemoved(Char)
            local Tab = TracerObjects[Char.Character]
            if Tab then
                for _, v in Tab.Tracers do
                    v:Destroy()
                end
                TracerObjects[Char.Character] = nil
            end
        end

        local function OnCharacterAdded(Char)
            OnCharacterRemoved(Char)
            local Tab = {
                Character = Char,
                Tracers = {
                    Tracer = CreateTracer(Char),
                }
            }
            for Limb, _ in TracerPath.R15 do
                Tab.Tracers[Limb] = CreateTracer(Char, Limb)
            end
            TracerObjects[Char.Character] = Tab
        end

        local function OnTeamChanged(Char)
            local Tab = TracerObjects[Char.Character]
            if Tab then
                local Color = GetTeamColor(Tab.Character) or Color.Color
                for _, Tracer in Tab.Tracers do
                    if TeamCheck.Enabled and Char.Teammate then
                        Tracer.Visible = false
                    else
                        Tracer.Color3 = Color
                        Tracer.Thickness = Thickness.Value
                    end
                end
            end
        end

        Tracers = Visuals:CreateModule({
            Name = "Tracers",
            Info = "Creates tracers",
            Function = function(Enabled)
                if Enabled then
                    ScreenGui = Instance.new("ScreenGui")
                    ScreenGui.IgnoreGuiInset = true
                    ScreenGui.Name = "Tracers"
                    ScreenGui.Parent = TidalWave.Gui

                    for _, Player in CharacterLib.List do
                        OnCharacterAdded(Player)
                    end

                    Tracers:Clean(CharacterLib.Events.CharacterAdded:Connect(OnCharacterAdded))
                    Tracers:Clean(CharacterLib.Events.CharacterRemoved:Connect(OnCharacterRemoved))
                    Tracers:Clean(CharacterLib.Events.TeamChanged:Connect(OnTeamChanged))
                    Tracers:Clean(RunService.PreRender:Connect(RenderTracers))
                else
                    if ScreenGui then
                        ScreenGui:Destroy()
                        ScreenGui = nil
                    end
                    table.clear(TracerObjects)
                end
            end
        })

        local function UpdateTracers()
            if not Tracers.Enabled then return end
            for _, Tab in TracerObjects do
                local Color = UseTeamColor.Enabled and GetTeamColor(Tab.Character) or Color.Color
                for _, Tracer in Tab.Tracers do
                    if TeamCheck.Enabled and Tab.Character.Teammate then
                        Tracer.Visible = false
                    else
                        Tracer.Color3 = Color
                        Tracer.Thickness = Thickness.Value
                    end
                end
            end
        end

        Thickness = Tracers:CreateSlider({
            Name = "Thickness",
            Default = 1,
            Min = 1,
            Max = 5,
            Function = UpdateTracers
        })

        Color = Tracers:CreateColorPicker({
            Name = "Color",
            Default = Color3.fromRGB(255, 255, 255),
            Function = UpdateTracers
        })

        TeamCheck = Tracers:CreateToggle({
            Name = "Team Check",
            Function = UpdateTracers
        })

        UseTeamColor = Tracers:CreateToggle({
            Name = "Use Team Color",
            Function = UpdateTracers
        })

        HideMainTracer = Tracers:CreateToggle({
            Name = "Hide Main Tracer",
            Info = "Hides the main tracer for if you want to only see xbox connect"
        })

        XBoxConnect = Tracers:CreateToggle({
            Name = "Xbox Connect",
            Info = "It connects the xbox",
            Function = function(Enabled)
                if not Enabled then
                    for _, v in TracerObjects do
                        for i2, v2 in v.Tracers do
                            if i2 ~= "Tracer" then
                                v2.Visible = false
                            end
                        end
                    end
                end
            end
        })

        Tracers:CreateDropdown({
            Name = "Position",
            List = {"Bottom", "Bottom Left", "Bottom Right", "Top Left", "Top", "Top Right", "Left", "Middle", "Right", "Mouse"},
            Function = function(Val)
                TracerControlPoints[1] = PresetPositons[Val:gsub(" ", "")]
            end
        })

        TracerTarget = Tracers:CreateDropdown({
            Name = 'Tracer Target',
            List = {'Root', 'Head', 'Torso'}
        })

        local function UpdateTracerOffsetVector()
            TracerOffsetVector = vector.create(TracerOffsetX.Value, TracerOffsetY.Value, TracerOffsetZ.Value)
        end

        TracerOffsetX = Tracers:CreateSlider({
            Name = 'Tracer Offset X',
            Default = 0,
            Min = -3,
            Max = 3,
            Decimal = 100,
            Function = UpdateTracerOffsetVector
        })

        TracerOffsetY = Tracers:CreateSlider({
            Name = 'Tracer Offset Y',
            Default = 0,
            Min = -3,
            Max = 3,
            Decimal = 100,
            Function = UpdateTracerOffsetVector
        })

        TracerOffsetZ = Tracers:CreateSlider({
            Name = 'Tracer Offset Z',
            Default = 0,
            Min = -3,
            Max = 3,
            Decimal = 100,
            Function = UpdateTracerOffsetVector
        })
    end)

    Run(function() -- NameTags
        local NameTags, UsePlayers, UseNPCs, TextColor, BackgroundColor, BackgroundTransparency, TextSize, Font, TeamCheck, ShowName, ShowDisplayName, ShowHealth, ShowHealthAsPercentage, ShowDistance, UseTeamColor, PixelsOffset, MinDistance, MaxDistance
        local Folder

        local NameTagObjects = {}

        local function OnCharacterRemoved(Char)
            local Player = NameTagObjects[Char.Character]
            if Player then
                Player.NameTag:Destroy()
                NameTagObjects[Char.Character] = nil
            end
        end

        local function OnCharacterAdded(Char)
            OnCharacterRemoved(Char)
            if Char.Player and not UsePlayers.Enabled then return end
            if Char.NPC and not UseNPCs.Enabled then return end

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Active = false
            TextLabel.Interactable = false
            TextLabel.Name = `{Char.Player and Char.Player.Name or Char.Character.Name}_NameTag`
            TextLabel.BorderSizePixel = 0
            TextLabel.BackgroundColor3 = BackgroundColor.Color
            TextLabel.BackgroundTransparency = BackgroundTransparency.Value
            TextLabel.TextColor3 = TextColor.Color
            TextLabel.TextSize = TextSize.Value
            TextLabel.Font = Enum.Font[Font.Value]
            TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel.RichText = true
            TextLabel.ZIndex = 0
            TextLabel.Parent = Folder

            NameTagObjects[Char.Character] = {NameTag = TextLabel, Character = Char}

            return TextLabel
        end

        local StudsOffsetVector = vector.create(0, 0.5, 0)

        local function RenderNameTags()
            for _, Tab in NameTagObjects do
                if TeamCheck.Enabled and Tab.Character.Teammate then
                    Tab.NameTag.Visible = false
                else
                    local Magnitude
                    if CharacterLib.Alive then
                        Magnitude = vector.magnitude(CharacterLib.Root.Position - Tab.Character.Root.Position)
                        if Magnitude > MaxDistance.Value then Tab.NameTag.Visible = false continue end
                        if Magnitude < MinDistance.Value then Tab.NameTag.Visible = false continue end
                    end
                    local HeadPos, HeadOnScreen = Camera:WorldToViewportPoint(Tab.Character.Head.Position + StudsOffsetVector)
                    if HeadOnScreen then
                        local Text = ''
                        local Player = Tab.Character.Player
                        local Character = Tab.Character.Character
                        if ShowDistance.Enabled and Magnitude then
                            Text ..= `[<font color = 'rgb(255, 255, 255)'>{math.round(Magnitude)}</font>]`
                        end
                        if ShowName.Enabled and ShowDisplayName.Enabled then
                            Text ..= `{Text == '' and '' or ' '}{Player and GetFullPlayerName(Player) or Character.Name}`
                        elseif ShowName.Enabled then
                            Text ..= `{Text == '' and '' or ' '}{Player and Player.Name or Character.Name}`
                        elseif ShowDisplayName.Enabled then
                            Text ..= `{Text == '' and '' or ' '}{Player and Player.DisplayName or Character.Name}`
                        end
                        if ShowHealth.Enabled then
                            local Percentage = (Tab.Character.Health or 100) / (Tab.Character.MaxHealth or 100)
                            local HealthColor = Color3.fromHSV((1 / 3) * Percentage, 1, 1)
                            local Health = math.round(ShowHealthAsPercentage.Enabled and Percentage * 100 or Tab.Character.Health or 100)
                            Text ..= `{Text == '' and '' or ' '}<font color = '#{HealthColor:ToHex()}'>{Health}{ShowHealthAsPercentage.Enabled and '%' or ''}</font>`
                        end
                        Tab.NameTag.Text = Text

                        local Color = UseTeamColor.Enabled and GetTeamColor(Tab.Character) or TextColor.Color
                        local Size = TextService:GetTextSize(Tab.NameTag.ContentText, Tab.NameTag.TextSize, Tab.NameTag.Font, Camera.ViewportSize)
                        Tab.NameTag.Size = UDim2.fromOffset(Size.X + 8, Size.Y + 8)
                        Tab.NameTag.Position = UDim2.fromOffset(HeadPos.X, HeadPos.Y - PixelsOffset.Value)
                        Tab.NameTag.TextColor3 = Color
                        Tab.NameTag.TextTransparency = TextColor.Transparency
                        Tab.NameTag.Visible = true
                    else
                        Tab.NameTag.Visible = false
                    end
                end
            end
        end

        NameTags = Visuals:CreateModule({
            Name = "NameTags",
            Function = function(Enabled)
                if Enabled then
                    Folder = NameTags:CreateInstance('Folder', 'Folder', {Name = 'NameTags', Parent = TidalWave.Gui})
                    NameTags:Clean(CharacterLib.Events.CharacterAdded:Connect(OnCharacterAdded))
                    NameTags:Clean(CharacterLib.Events.CharacterRemoved:Connect(OnCharacterRemoved))
                    for _, Char in CharacterLib.List do
                        OnCharacterAdded(Char)
                    end
                    NameTags:Clean(RunService.PreRender:Connect(RenderNameTags))
                else
                    table.clear(NameTagObjects)
                end
            end
        })

        MinDistance = NameTags:CreateSlider({
            Name = 'Min Distance',
            Default = 0,
            Min = 0,
            Max = 40
        })

        MaxDistance = NameTags:CreateSlider({
            Name = 'Max Distance',
            Default = 1000,
            Min = 100,
            Max = 1000
        })

        local function Update()
            if not NameTags.Enabled then return end
            for _, v in NameTagObjects do
                v.NameTag.BackgroundTransparency = BackgroundTransparency.Value
                v.NameTag.BackgroundColor3 = BackgroundColor.Color
                v.NameTag.TextSize = TextSize.Value
                v.NameTag.Font = Enum.Font[Font.Value]
            end
        end

        TextSize = NameTags:CreateSlider({
            Name = "Text Size",
            Default = 16,
            Min = 8,
            Max = 32,
            Function = Update
        })

        local Fonts = {"Gotham"}

        for _, v in Enum.Font:GetEnumItems() do
            if v.Name == "Gotham" then continue end
            Fonts[#Fonts + 1] = v.Name
        end

        Font = NameTags:CreateDropdown({
            Name = "Font",
            List = Fonts,
            Function = Update
        })

        TextColor = NameTags:CreateColorPicker({
            Name = "Text Color",
            Default = Color3.fromRGB(255, 255, 255)
        })

        BackgroundColor = NameTags:CreateColorPicker({
            Name = "Background Color",
            Default = Color3.fromRGB(0, 0, 0),
            Function = Update
        })

        BackgroundTransparency = NameTags:CreateSlider({
            Name = "Transparency",
            Default = 0.5,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = Update
        })

        NameTags:CreateSlider({
            Name = "Studs Offset",
            Default = 0.5,
            Min = 0,
            Max = 10,
            Decimal = 100,
            Function = function(Val)
                StudsOffsetVector = vector.create(0, Val, 0)
            end
        })

        PixelsOffset = NameTags:CreateSlider({
            Name = "Pixels Offset",
            Default = 12,
            Min = 0,
            Max = 50
        })

        local RestartNameTags = function()
            if NameTags.Enabled then
                NameTags:Toggle(true)
                NameTags:Toggle(true)
            end
        end

        UsePlayers = NameTags:CreateToggle({
            Name = "Players",
            Info = "Whether or not to show players.",
            Default = true,
            Function = RestartNameTags
        })

        UseNPCs = NameTags:CreateToggle({
            Name = "NPCs",
            Info = "Whether or not to show npcs.",
            Function = RestartNameTags
        })

        TeamCheck = NameTags:CreateToggle({
            Name = "Team Check",
            Info = "Hides teammates",
            Function = RestartNameTags
        })

        ShowName = NameTags:CreateToggle({
            Name = "Name",
            Default = true
        })

        ShowDisplayName = NameTags:CreateToggle({
            Name = 'Display Name',
        })

        ShowHealth = NameTags:CreateToggle({
            Name = "Health",
            Default = true,
            Function = function(Enabled)
                if ShowHealthAsPercentage then
                    ShowHealthAsPercentage:SetVisible(Enabled)
                end
            end
        })

        ShowHealthAsPercentage = NameTags:CreateToggle({
            Name = 'Show Health As Percentage',
            Visible = false
        })

        ShowDistance = NameTags:CreateToggle({
            Name = "Distance"
        })

        UseTeamColor = NameTags:CreateToggle({
            Name = "Use Team Color",
        })
    end)

    Run(function() -- ESP
        local ESP, Color, Thickness, UsePlayers, UseNPCs, TeamCheck, UseTeamColor, Folder, SizeX, SizeY

        local Frames = {}

        local function OnCharacterRemoved(Char)
            local Box = Frames[Char.Character]
            if Box then
                Box.Frame:Destroy()
                Frames[Char.Character] = nil
            end
        end

        local function OnCharacterAdded(Char)
            OnCharacterRemoved(Char)
            if Char.Player and not UsePlayers.Enabled then return end
            if Char.NPC and not UseNPCs.Enabled then return end
            local Box = Instance.new("Frame")
            Box.BackgroundTransparency = 1
            Box.Active = false
            Box.Interactable = false
            Box.Name = `{Char.Player and Char.Player.Name or Char.Character.Name}_BoxESP`
            Box.AnchorPoint = Vector2.new(0.5, 0.5)
            Box.ZIndex = 0
            Box.Parent = Folder
            
            local UIStroke = Instance.new("UIStroke")
            UIStroke.Thickness = Thickness.Value
            UIStroke.Color = Color.Color
            UIStroke.LineJoinMode = Enum.LineJoinMode.Miter
            UIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
            UIStroke.Parent = Box

            Frames[Char.Character] = {Frame = Box, Character = Char}
        end

        ESP = Visuals:CreateModule({
            Name = "ESP",
            Function = function(Enabled)
                if Enabled then
                    Folder = Instance.new("Folder")
                    Folder.Name = "ESP"
                    Folder.Parent = TidalWave.Gui

                    ESP:Clean(CharacterLib.Events.CharacterAdded:Connect(OnCharacterAdded))
                    ESP:Clean(CharacterLib.Events.CharacterRemoved:Connect(OnCharacterRemoved))
                    for _, Char in CharacterLib.List do
                        OnCharacterAdded(Char)
                    end

                    ESP:Clean(RunService.PreRender:Connect(function()
                        for _, Tab in Frames do
                            if TeamCheck.Enabled and Tab.Character.Teammate then
                                Tab.Frame.UIStroke.Enabled = false
                            else
                                local RootPos, RootOnScreen = Camera:WorldToViewportPoint(Tab.Character.Root.Position)
                                if RootOnScreen then
                                    Tab.Frame.Size = UDim2.fromOffset((1920 * SizeX.Value) / RootPos.Z, (1920 * SizeY.Value) / RootPos.Z)
                                    Tab.Frame.Position = UDim2.fromOffset(RootPos.X, RootPos.Y)
                                    Tab.Frame.UIStroke.Color = UseTeamColor.Enabled and GetTeamColor(Tab.Character) or Color.Color
                                    Tab.Frame.UIStroke.Thickness = Thickness.Value
                                    Tab.Frame.UIStroke.Enabled = true
                                else
                                    Tab.Frame.UIStroke.Enabled = false
                                end
                            end
                        end
                    end))
                else
                    Folder:Destroy()
                    Folder = nil
                    table.clear(Frames)
                end
            end
        })

        Thickness = ESP:CreateSlider({
            Name = "Box Thickness",
            Default = 1,
            Min = 1,
            Max = 5,
        })

        Color = ESP:CreateColorPicker({
            Name = "Box Color",
            Default = Color3.fromRGB(255, 255, 255),
            Function = function(Color, Transparency)
                for _, Tab in Frames do
                    Tab.Frame.UIStroke.Color = UseTeamColor.Enabled and GetTeamColor(Tab.Character) or Color
                    Tab.Frame.UIStroke.Transparency = Transparency
                end
            end,
        })

        UseTeamColor = ESP:CreateToggle({
            Name = "Use Team Color",
            Function = function()
                for _, Tab in Frames do
                    Tab.Frame.UIStroke.Color = UseTeamColor.Enabled and GetTeamColor(Tab.Character) or Color.Color
                end
            end,
        })

        TeamCheck = ESP:CreateToggle({
            Name = "Team Check",
            Info = "Hides teammates",
        })

        local Restart = function()
            if ESP.Enabled then
                ESP:Toggle(true)
                ESP:Toggle(true)
            end
        end

        UsePlayers = ESP:CreateToggle({
            Name = "Players",
            Info = "Whether or not to show players.",
            Default = true,
            Function = Restart
        })

        UseNPCs = ESP:CreateToggle({
            Name = "NPCs",
            Info = "Whether or not to show npcs.",
            Function = Restart
        })

        SizeX = ESP:CreateSlider({
            Name = "X Size",
            Default = 1.5,
            Min = 0,
            Max = 3,
            Decimal = 100,
        })

        SizeY = ESP:CreateSlider({
            Name = "Y Size",
            Default = 2.5,
            Min = 0,
            Max = 3,
            Decimal = 100,
        })
    end)

    Run(function() -- ViewportChams
        local ViewportChams, ViewportFrame, ViewportModel, Color, TeamCheck, ShowPlayers, ShowNPCs

        local Models = {}
        local Parts = {}
        local OtherObjects = {}

        local Blacklist = {
            Status = true,
            LocalScript = true,
            Script = true,
            ModuleScript = true,
            TouchTransmitter = true,
            Sound = true,
        }

        local function CharacterAdded(Char)
            if TeamCheck.Enabled and Char.Teammate then return end
            if not ShowPlayers.Enabled and Char.Player then return end
            if not ShowNPCs.Enabled and Char.NPC then return end

            local function Recursive(Obj, Parent)
                for _, v in Obj:GetChildren() do
                    if Blacklist[v.ClassName] then continue end
                    local Clone = Instance.fromExisting(v)
                    if Clone:IsA("BasePart") then
                        Parts[v] = Clone
                    else
                        OtherObjects[v] = Clone
                    end
                    Clone.Parent = Parent
                    Recursive(v, Clone)
                end
            end

            local Model = Instance.new("Model")
            Model.Name = (Char.Player and Char.Player.Name or Char.Character.Name) .. '_Chams'
            Model.Parent = ViewportModel

            Recursive(Char.Character, Model)

            ViewportChams:Clean(Char.Character.DescendantAdded:Connect(function(Child)
                if Blacklist[Child.ClassName] then return end
                task.defer(function()
                    local Clone = Instance.fromExisting(Child)
                    if Child:IsA("BasePart") then
                        Parts[Child] = Clone
                    else
                        OtherObjects[Child] = Clone
                    end
                    local Parent
                    for _, Tab in {Parts, OtherObjects} do
                        local Success
                        for Original, Clone in Tab do
                            if Original == Child.Parent then
                                Parent = Clone
                                Success = true
                                break
                            end
                        end
                        if Success then break end
                    end
                    
                    Clone.Parent = Parent or Model
                end)
            end))

            ViewportChams:Clean(Char.Character.DescendantRemoving:Connect(function(Child)
                if Parts[Child] then
                    Parts[Child]:Destroy()
                    Parts[Child] = nil
                end
            end))

            Models[Char.Character] = Model
        end

        local function CharacterRemoved(Char)
            if Models[Char.Character] then
                Models[Char.Character]:Destroy()
                Models[Char.Character] = nil
            end
        end
        
        ViewportChams = Visuals:CreateModule({
            Name = "ViewportChams",
            Info = "Renders players through walls using viewport frames.\nMay cause lag spikes when characters are being added.",
            Function = function(Enabled)
                if Enabled then
                    ViewportFrame = Instance.new("ViewportFrame")
                    ViewportFrame.Name = 'ChamsViewportFrame'
                    ViewportFrame.Size = UDim2.fromScale(1, 1)
                    ViewportFrame.BackgroundTransparency = 1
                    ViewportFrame.CurrentCamera = Camera
                    ViewportFrame.Ambient = Color3.White
                    ViewportFrame.LightColor = Color3.White
                    ViewportFrame.ImageColor3 = Color.Color
                    ViewportFrame.ImageTransparency = Color.Transparency
                    ViewportFrame.LightDirection = vector.zero
                    ViewportFrame.ZIndex = 0
                    ViewportFrame.Parent = TidalWave.Gui

                    ViewportModel = Instance.new("WorldModel")
                    ViewportModel.Name = 'ChamsWorldModel'
                    ViewportModel.Parent = ViewportFrame

                    ViewportChams:Clean(CharacterLib.Events.CharacterAdded:Connect(CharacterAdded))
                    ViewportChams:Clean(CharacterLib.Events.CharacterRemoved:Connect(CharacterRemoved))
                    for _, Character in CharacterLib.List do
                        CharacterAdded(Character)
                    end

                    ViewportChams:Clean(RunService.PreRender:Connect(function()
                        for Part, Clone in Parts do
                            Clone.CFrame = Part.CFrame
                        end
                    end))
                else
                    ViewportFrame:Destroy()
                    ViewportFrame = nil
                    table.clear(Parts)
                    table.clear(OtherObjects)
                    table.clear(Models)
                end
            end,
        })

        Color = ViewportChams:CreateColorPicker({
            Name = 'Color',
            Default = Color3.White,
            Function = function(Color, Transparency)
                if ViewportFrame then
                    ViewportFrame.ImageColor3 = Color
                    ViewportFrame.ImageTransparency = Transparency
                end
            end
        })

        local function Update()
            if ViewportChams.Enabled then
                ViewportChams:Toggle(true)
                ViewportChams:Toggle(true)
            end
        end

        ShowPlayers = ViewportChams:CreateToggle({
            Name = 'Players',
            Info = 'Whether or not to show players.',
            Default = true,
            Function = Update
        })

        ShowNPCs = ViewportChams:CreateToggle({
            Name = 'NPCs',
            Info = 'Whether or not to show NPCs.',
            Function = Update
        })

        TeamCheck = ViewportChams:CreateToggle({
            Name = 'Team Check',
            Info = 'Hides teammates.',
            Function = Update
        })
    end)

    Run(function() -- PartESP
        local PartESP, NameCheckMethod, HighlightType, OutlineColor, FillColor, Shading, DepthMode, Path, SearchMethod, Names, FilterType, Folder

		local function HighlightPart(Part)
			if HighlightType.Value == "Highlight" then
				local Highlight = Instance.new("Highlight")
				Highlight.Name = `{Part.Name}_ESP`
				Highlight.OutlineColor = OutlineColor.Color
				Highlight.FillColor = FillColor.Color
				Highlight.OutlineTransparency = OutlineColor.Transparency
				Highlight.FillTransparency = FillColor.Transparency
				Highlight.DepthMode = Enum.HighlightDepthMode[DepthMode.Value]
				Highlight.Adornee = Part
				Highlight.Parent = Folder
			else
				local Box = Instance.new("BoxHandleAdornment")
				Box.Shading = Enum.AdornShading[Shading.Value]
				Box.Size = Part.Size
				Box.Name = `{Part.Name}_ESP`
				Box.Color3 = FillColor.Color
				Box.Transparency = FillColor.Transparency
				Box.Adornee = Part
				Box.ZIndex = 1
				Box.Parent = Folder
			end
		end

		local function NameCheck(Child)
            if FilterType.Value == 'None' then return true end
			local Name = Child.Name:lower()
			for _, v in Names.Enabled do
				local ListName = v:lower()
				if (NameCheckMethod.Value == "Exact Name" and (FilterType.Value == 'Include' and ListName == Name or ListName ~= Name)) or (NameCheckMethod.Value == "Contains String" and (FilterType.Value == 'Include' and Name:match(ListName) or not Name:match(ListName))) then
					return true
				end
			end
            return false
		end

        local function Loop(Obj)
            for _, v in Obj:GetChildren() do
                if v:IsA("Folder") then
                    Loop(v)
                elseif (HighlightType.Value == 'Highlight' and (v:IsA('BasePart') or v:IsA('Model')) or v:IsA('BasePart')) and NameCheck(v) then
                    HighlightPart(v)
                end
            end
            PartESP:Clean(Obj.ChildAdded:Connect(function(Child)
                if (HighlightType.Value == 'Highlight' and (Child:IsA('BasePart') or Child:IsA('Model')) or Child:IsA('BasePart')) and NameCheck(Child) then
                    HighlightPart(Child)
                end
            end))
        end

		PartESP = Visuals:CreateModule({
			Name = "PartESP",
			Function = function(Enabled)
				if Enabled then
					Folder = Instance.new("Folder")
					Folder.Name = "PartESP"
					Folder.Parent = TidalWave.Gui
					if SearchMethod.Value == 'Children' then
                        Loop(Path or workspace)
                    else
                        for _, v in (Path or workspace):QueryDescendants(HighlightType.Value == "Highlight" and 'BasePart, Model' or 'BasePart') do
                            if NameCheck(v) then
                                HighlightPart(v)
                            end
                        end
                        PartESP:Clean((Path or workspace).DescendantAdded:Connect(function(Descendant)
                            if (HighlightType.Value == 'Highlight' and (Descendant:IsA('BasePart') or Descendant:IsA('Model')) or Descendant:IsA('BasePart')) and NameCheck(Descendant) then
                                HighlightPart(Descendant)
                            end
                        end))
                    end
				else
					if Folder then
						Folder:Destroy()
						Folder = nil
					end
				end
			end
		})

		local function Restart()
			if PartESP.Enabled then
				PartESP:Toggle(true)
				PartESP:Toggle(true)
			end
		end

		local function UpdateColors()
			if not PartESP.Enabled then return end
			for i, v in Folder:GetChildren() do
				if v:IsA("Highlight") then
					v.OutlineColor = OutlineColor.Color
					v.FillColor = FillColor.Color
					v.OutlineTransparency = OutlineColor.Transparency
					v.FillTransparency = FillColor.Transparency
				elseif v:IsA("BoxHandleAdornment") then
					v.Color3 = FillColor.Color
					v.Transparency = FillColor.Transparency
				end
			end
		end

		HighlightType = PartESP:CreateDropdown({
			Name = "Highlight Type",
			List = {"Highlight", "BoxHandle"},
			Function = function(Val)
				local Equal = Val == "Highlight"
				DepthMode:SetVisible(Equal)
				Shading:SetVisible(not Equal)
				OutlineColor:SetVisible(Equal)
				FillColor:SetVisible(Equal)
				Restart()
			end
		})

		Shading = PartESP:CreateDropdown({
			Name = "Shading",
			List = {"AlwaysOnTop", "Default", "Shaded", "XRay", "XRayShaded"},
			Visible = false,
			Function = Restart,
		})

		DepthMode = PartESP:CreateDropdown({
			Name = "Depth Mode",
			List = {"AlwaysOnTop", "Occluded"},
			Function = Restart,
		})
		
		OutlineColor = PartESP:CreateColorPicker({
			Name = "Outline Color",
			Default = Color3.fromRGB(255, 255, 255),
			Function = UpdateColors
		})
		
		FillColor = PartESP:CreateColorPicker({
			Name = "Fill Color",
			Default = Color3.fromRGB(255, 255, 255),
			Transparency = 0.2,
			Function = UpdateColors
		})

	    PartESP:CreateTextBox({
			Name = "Folder Path",
			PlaceholderText = "Enter path",
			Function = function(Text, Loaded)
                if Text:match('%w+') then
                    local Function = loadstring(`return {Text}`)
                    if typeof(Function) == 'string' then
                        Path = Function()
                        if typeof(Path) == 'Instance' then
                            if Loaded then return end
                            Notify({Text = `Set Object to {GetFullName(Path)}`, Duration = 4})
                        else
                            Path = nil
                            if Loaded then return end
                            Notify({Text = 'Invalid type', Duration = 4, Type = 'Error'})
                        end
                    end
                else
                    Path = nil
                end
			end
		})

        NameCheckMethod = PartESP:CreateDropdown({
			Name = "Method",
			List = {"Exact Name", "Contains String"},
			Function = Restart
		})

        SearchMethod = PartESP:CreateDropdown({
            Name = 'Search Method',
            List = {'Children', 'Descendants'},
            Function = Restart
        })

        FilterType = PartESP:CreateDropdown({
            Name = 'Filter Type',
            List = {'Include', 'Exclude', 'None'}
        })

		Names = PartESP:CreateTextList({
			Name = "Names",
			Function = Restart
		})
    end)

    Run(function() -- Fov
        local Fov, Value, Old, db

        Fov = Visuals:CreateModule({
            Name = "Fov",
            Info = "Sets your field of view to the specified value",
            Function = function(Enabled)
                if Enabled then
                    Old  = Camera.FieldOfView
                    Camera.FieldOfView = Value.Value
                    Fov:Clean(Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
                        if db then return end
                        Old = Camera.FieldOfView
                        Camera.FieldOfView = Value.Value
                    end))
                else
                    Camera.FieldOfView = Old
                    Old = nil
                end
            end
        })

        Value = Fov:CreateSlider({
            Name = "Field Of View",
            Default = math.floor(Camera.FieldOfView),
            Min = 1,
            Max = 120,
            Function = function(Val)
                if Fov.Enabled then
                    db = true
                    Camera.FieldOfView = Val
                    db = false
                end
            end
        })
    end)

    Run(function() -- CameraZoom
        local CameraZoom, MinZoom, MaxZoom

        CameraZoom = Visuals:CreateModule({
            Name = "CameraZoom",
            Info = "Loop Sets Camera Min Zoom And Max Zoom",
            Enabled = function()
                Plr.CameraMaxZoomDistance = MaxZoom.Value
                Plr.CameraMinZoomDistance = MinZoom.Value
                CameraZoom:Clean(Plr:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
                    Plr.CameraMaxZoomDistance = MaxZoom.Value
                end))
                CameraZoom:Clean(Plr:GetPropertyChangedSignal("CameraMinZoomDistance"):Connect(function()
                    Plr.CameraMinZoomDistance = MinZoom.Value
                end))
            end,
        })

        MinZoom = CameraZoom:CreateSlider({
            Name = "Min Zoom",
            Default = math.floor(Plr.CameraMinZoomDistance * 10) / 10,
            Min = 0.5,
            Max = 100,
            Decimal = 10,
            Function = function(Val)
                if CameraZoom.Enabled then
                    Plr.CameraMinZoomDistance = Val
                end
            end
        })

        MaxZoom = CameraZoom:CreateSlider({
            Name = "Max Zoom",
            Default = Plr.CameraMaxZoomDistance,
            Min = 1,
            Max = 1000,
            Function = function(Val)
                if CameraZoom.Enabled then
                    Plr.CameraMaxZoomDistance = Val
                end
            end
        })
    end)

    Run(function() -- CameraMode
        local CameraMode, Mode

        CameraMode = Visuals:CreateModule({
            Name = "CameraMode",
            Info = "Sets your camera to third/first person",
            Enabled = function()
                Plr.CameraMode = Mode.Value == "First Person" and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
                CameraMode:Clean(Plr:GetPropertyChangedSignal("CameraMode"):Connect(function()
                    Plr.CameraMode = Mode.Value == "First Person" and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
                end))
            end
        })

        Mode = CameraMode:CreateDropdown({
            Name = "Camera Mode",
            List = {"Third Person", "First Person"},
            Function = function(Val)
                if CameraMode.Enabled then
                    Plr.CameraMode = Mode.Value == "First Person" and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
                end
            end
        })
    end)

    Run(function() -- AntiLag
        local AntiLag

        local Objects = {}
        
        local function SparklesFunction(Obj)
            if Obj.Enabled then
                Objects[Obj] = {Enabled = true}
                Obj.Enabled = false
            end
        end

        local function BasePartFunction(Obj)
            Objects[Obj] = {Material = Obj.Material, Reflectance = Obj.Reflectance, CastShadow = Obj.CastShadow}
            Obj.Material = Enum.Material.Plastic
            Obj.Reflectance = 0
            Obj.CastShadow = false
        end

        local Functions = {
            Part = BasePartFunction,
            MeshPart = BasePartFunction,
            TrussPart = BasePartFunction,
            SpawnLocation = BasePartFunction,
            Seat = BasePartFunction,
            VehicleSeat = BasePartFunction,
            UnionOperation = BasePartFunction,
            NegateOperation = BasePartFunction,
            IntersectOperation = BasePartFunction,
            Decal = function(Obj)
                Objects[Obj] = {Transparency = Obj.Transparency}
                Obj.Transparency = 1
            end,
            Texture = function(Obj)
                Objects[Obj] = {Transparency = Obj.Transparency}
                Obj.Transparency = 1
            end,
            ParticleEmitter = function(Obj)
                Objects[Obj] = {Lifetime = Obj.Lifetime}
                Obj.Lifetime = NumberRange.new(0, 0)
            end,
            Trail = function(Obj)
                Objects[Obj] = {Lifetime = Obj.Lifetime}
                Obj.Lifetime = 0
            end,
            Explosion = function(Obj)
                Objects[Obj] = {BlastPressure = Obj.BlastPressure, BlastRadius = Obj.BlastRadius}
                Obj.BlastPressure = 0
                Obj.BlastRadius = 0
            end,
            Sparkles = SparklesFunction,
            Smoke = SparklesFunction,
            Fire = SparklesFunction,
            ForceField = function(Obj)
                Objects[Obj] = {Visible = Obj.Visible}
                Obj.Visible = false
            end
        }

        local Query = "Part, MeshPart, TrussPart, SpawnLocation, Seat, VehicleSeat, UnionOperation, NegateOperation, IntersectOperation, Decal, Texture, ParticleEmitter, Trail, Explosion, Sparkles, Smoke, Fire, ForceField"

        AntiLag = Visuals:CreateModule({
            Name = "AntiLag",
            Info = "Removes lots of diffent details to increase FPS",
            Function = function(Enabled)
                if Enabled then
                    for _, v in workspace:QueryDescendants(Query) do
                        Functions[v.ClassName](v)
                    end

                    AntiLag:Clean(workspace.DescendantAdded:Connect(function(Descendant)
                        local f = Functions[Descendant.ClassName]
                        if f then
                            task.wait()
                            f(Descendant)
                        end
                    end))

                    AntiLag:Clean(workspace.DescendantRemoving:Connect(function(Descendant)
                        if Objects[Descendant] then
                            Objects[Descendant] = nil
                        end
                    end))
                else
                    for Obj, Properties in Objects do
                        if Obj.Parent then
                            for Property, OldValue in Properties do
                                Obj[Property] = OldValue
                            end
                        end
                    end
                    table.clear(Objects)
                end
            end
        })
    end)

    Run(function()
        local Xray, Transparency, FilterType, Filter, Path

        local Modified = {}

        local function DescendantAdded(Part)
            if Part.Parent.ClassName == 'Model' and Players:GetPlayerFromCharacter(Part.Parent) then return end
            if FilterType.Value == 'None' or (FilterType.Value == 'Include' and not Filter:Find(Part.Name)) or (FilterType.Value == 'Exclude' and Filter:Find(Part.Name)) then
                Modified[Part] = Part.LocalTransparencyModifier
                Part.LocalTransparencyModifier = Transparency.Value
            end
        end
            
        Xray = Visuals:CreateModule({
            Name = "Xray",
            Info = "Makes parts transparent",
            Function = function(Enabled)
                if Enabled then
                    for _, Part in workspace:QueryDescendants('BasePart') do
                        DescendantAdded(Part)
                    end
                    Xray:Clean(workspace.DescendantAdded:Connect(DescendantAdded))
                    Xray:Clean(workspace.DescendantRemoving:Connect(function(Descendant)
                        if Modified[Descendant] then
                            Modified[Descendant] = nil
                        end
                    end))
                else
                    for Part, Transparency in Modified do
                        Part.LocalTransparencyModifier = Transparency
                    end
                    table.clear(Modified)
                end
            end,
        })

        Transparency = Xray:CreateSlider({
            Name = 'Transparency',
            Default = 0.5,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = function(Val)
                for Part in Modified do
                    Part.LocalTransparencyModifier = Val
                end
            end
        })

        Xray:CreateTextBox({
            Name = 'Path',
            Info = 'The folder/model to look through.',
            PlaceholderText = '[Path]',
            Function = function(Text, Loaded)
                if Text:match('%w+') then
                    local Function = loadstring(`return {Text}`)
                    if typeof(Function) == 'function' then
                        Path = Function() or Path
                        if Loaded then return end
                        if typeof(Path) == 'Instance' then
                            Notify({Text = `Set Object to {GetFullName(Path)}`, Duration = 4})
                        else
                            Path = nil
                            Notify({Text = `Expected type 'Instance' got '{typeof(Path)}'`, Duration = 6, Type = 'Error'})
                        end
                    elseif typeof(Function) == 'string' and not Loaded then
                        Notify({Text = Function, Duration = 6, Type = 'Error'})
                    end
                else
                    Path = nil
                end
            end
        })

        FilterType = Xray:CreateDropdown({
            Name = 'Filter Type',
            List = {'None', 'Exclude', 'Include'},
            Function = function()
                if Xray.Enabled then
                    Xray:Toggle(true)
                    Xray:Toggle(true)
                end
            end
        })

        Filter = Xray:CreateTextList({
            Name = 'Filter',
            Function = function()
                for Part, Transparency in Modified do
                    if (FilterType.Value == 'Include' and not Filter:Find(Part.Name)) or (FilterType.Value == 'Exclude' and Filter:Find(Part.Name)) then
                        Part.LocalTransparencyModifier = Transparency
                        Modified[Part] = nil
                    end
                end
            end
        })
    end)

    Run(function() -- Use2022Materials
        Visuals:CreateModule({
            Name = "Use2022Materials",
            Function = function(Enabled)
                MaterialService.Use2022Materials = Enabled
            end,
        })
    end)

    Run(function() -- NoRender
        Visuals:CreateModule({
            Name = "NoRender",
            Info = "Disables 3D Rendering",
            Function = function(Enabled)
                RunService:Set3dRenderingEnabled(not Enabled)
            end
        })
    end)
end)

Run(function() -- World
    Run(function() -- Gravity
        local Gravity, GravityVal, Method, Old, Skip

        Gravity = World:CreateModule({
            Name = "Gravity",
            Info = "Changes the speed at which you fall.",
            Function = function(Enabled)
                if Enabled then
                    if Method.Value == 'Velocity' then
                        Gravity:Clean(RunService.PreSimulation:Connect(function(Delta)
                            if CharacterLib.Alive and CharacterLib.Humanoid.FloorMaterial == Enum.Material.Air then
                                CharacterLib.Root.AssemblyLinearVelocity += vector.create(0, Delta * (workspace.Gravity - GravityVal.Value), 0)
                            end
                        end))
                    else
                        Old = workspace.Gravity
                        workspace.Gravity = GravityVal.Value
                        Gravity:Clean(workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
                            if Skip then return end
                            Old = workspace.Gravity
                            workspace.Gravity = GravityVal.Value
                        end))
                    end
                else
                    if Old then
                        workspace.Gravity = Old
                        Old = nil
                    end
                    Skip = nil
                end
            end
        })

        GravityVal = Gravity:CreateSlider({
            Name = "Gravity",
            Default = 196.2,
            Min = 0,
            Max = 1000,
            Decimal = 10,
            Function = function(Val)
                if Gravity.Enabled and Method.Value == 'Gravity' then
                    Skip = true
                    workspace.Gravity = Val
                    Skip = nil
                end
            end
        })

        Method = Gravity:CreateDropdown({
            Name = 'Method',
            List = {'Gravity', 'Velocity'},
            Function = function()
                if Gravity.Enabled then
                    Gravity:Toggle()
                    Gravity:Toggle()
                end
            end
        })
    end)

    Run(function() -- Jesus
        local Jesus
        
        local Params = RaycastParams.new()
        Params.RespectCanCollide = true
        Params.FilterType = Enum.RaycastFilterType.Include
        Params.FilterDescendantsInstances = {workspace.Terrain}

        Jesus = World:CreateModule({
            Name = 'Jesus',
            Info = 'Allows you to walk on water like jesus.',
            Enabled = function()
                local Part = Jesus:CreateInstance('Part', 'Part', {Transparency = 1, Size = vector.create(2, 0.2, 2), Anchored = true, CanTouch = false, CanQuery = false, CastShadow = false, CanCollide = false, AudioCanCollide = false, Parent = workspace})
                Jesus:Clean(RunService.PostSimulation:Connect(function()
                    if not (CharacterLib.Alive and Part) then return end
                    local Raycast = workspace:Raycast(CharacterLib.Root.Position, vector.create(0, -(CharacterLib.HipHeight + 0.1), 0), Params)
                    if Raycast and Raycast.Material == Enum.Material.Water then
                        Part.Position = Raycast.Position
                        Part.CanCollide = true
                    else
                        Part.CanCollide = false
                    end
                end))
            end
        })
    end)

    Run(function() -- FastProximityPrompts
        local FastProximityPrompts, Duration, Mode, Thread

        local Modified = {}
        
        FastProximityPrompts = World:CreateModule({
            Name = "FastProximityPrompts",
            Info = "Modifies how fast you interact with proximity prompts.",
            Function = function(Enabled)
                if Enabled then
                    if Mode.Value == 'Signal' then
                        FastProximityPrompts:Clean(ProximityPromptService.PromptButtonHoldBegan:Connect(function(Prompt, Player)
                            if Player == Plr then
                                Thread = task.delay(Prompt.HoldDuration * (Duration.Value / 100), function()
                                    Thread = nil
                                    fireproximityprompt(Prompt)
                                end)
                            end
                        end))
                        FastProximityPrompts:Clean(ProximityPromptService.PromptButtonHoldEnded:Connect(function(Prompt, Player)
                            if Player == Plr and Thread then
                                task.cancel(Thread)
                                Thread = nil
                            end
                        end))
                    else
                        FastProximityPrompts:Clean(ProximityPromptService.PromptShown:Connect(function(Prompt)
                            if not Modified[Prompt] then
                                Modified[Prompt] = Prompt.HoldDuration
                            end
                            Prompt.HoldDuration = Modified[Prompt] * (Duration.Value / 100)
                        end))
        
                        FastProximityPrompts:Clean(ProximityPromptService.PromptHidden:Connect(function(Prompt)
                            if Modified[Prompt] then
                                Prompt.HoldDuration = Modified[Prompt]
                                Modified[Prompt] = nil
                            end
                        end))
                    end
                else
                    if Thread then
                        task.cancel(Thread)
                        Thread = nil
                    end
        
                    for Prompt, OldDuration in Modified do
                        Prompt.HoldDuration = OldDuration
                    end
        
                    table.clear(Modified)
                end
            end,
        })

        Mode = FastProximityPrompts:CreateDropdown({
            Name = 'Mode',
            List = {'Signal', 'Property'},
            Function = function()
                if FastProximityPrompts.Enabled then
                    FastProximityPrompts:Toggle(true)
                    FastProximityPrompts:Toggle(true)
                end
            end
        })

        Duration = FastProximityPrompts:CreateSlider({
            Name = 'Duration',
            Default = 50,
            Min = 0,
            Max = 100,
            Suffix = '%',
            Function = function(Val)
                for Prompt, OldDuration in Modified do
                    Prompt.HoldDuration = OldDuration * (Val / 100)
                end
            end
        })
    end)

    Run(function() -- TP-Unanchored Parts
        local Tpua, Fling, Player

        local Limbs = {
            "Head",
            "Torso",
            "LowerTorso",
            "UpperRightArm",
            "Right Arm",
            "LowerRightArm",
            "UpperLeftArm",
            "LowerLeftArm",
            "Left Arm",
            "UpperRightLeg",
            "LowerRightLeg",
            "Right Leg",
            "UpperLeftLeg",
            "LowerLeftLeg",
            "Left Leg",
            "HumanoidRootPart",
        }

        local BodyPositions = {}
        
        Tpua = World:CreateModule({
            Name = "TP Un-anchored Parts",
            Info = "Teleports un-anchored parts to the specified player\nYou must have network ownership of the parts for it to work",
            Function = function(Enabled)
                if Enabled then
                    local Character = CharacterLib:FindCharacter(Player)
                    local Target = (Character and Character.Root) or (CharacterLib.Alive and CharacterLib.Root) or nil
                    if not Target then return end
                    for _, Part in workspace:QueryDescendants("BasePart[Anchored = false]") do
                        if Part:IsDescendantOf(CharacterLib.Character) or table.find(Limbs, Part.Name) then continue end
                        local BodyPosition = Instance.new("BodyPosition")
                        BodyPosition.MaxForce = vector.huge
                        BodyPosition.Position = Target.Position
                        BodyPosition.D = Fling.Enabled and 0 or 1250
                        BodyPosition.Parent = Part
                        BodyPositions[#BodyPositions + 1] = BodyPosition
                    end
                else
                    for _, v in BodyPositions do
                        v:Destroy()
                    end
                    table.clear(BodyPositions)
                end
            end
        })

        Tpua:CreateTextBox({
            Name = "Name",
            PlaceholderText = "[Player Name]",
            Function = function(Text, Loaded)
                if Text:match('%w+') then
                    Player = FindPlayer(Text)
                    if Loaded then return end
                    if Player then
                        Notify({Text = `Set player to {GetFullPlayerName(Player)}`, Duration = 4})
                    else
                        Notify({Text = "Failed to find player", Type = "Error"})
                    end
                else
                    Player = nil
                end
            end
        })

        Fling = Tpua:CreateToggle({
            Name = "Fling",
            Info = "Fling people that touch the parts",
            Function = function(Enabled)
                for _, v in BodyPositions do
                    v.D = Enabled and 0 or 1250
                end
            end
        })
    end)

    Run(function() -- fireclickdetectors
        World:CreateButton({
            Name = "Fire ClickDetectors",
            Info = "Fires all click detectors",
            Function = function()
                if not fireclickdetector then NotifyPoopSploit("fireclickdetector") return end
                for _, v in workspace:QueryDescendants("ClickDetector") do
                    fireclickdetector(v)
                end
            end,
        })
    end)

    Run(function() -- fireproximityprompts
        World:CreateButton({
            Name = "Fire ProximityPrompts",
            Info = "Fires all proximity prompts",
            Function = function()
                if not fireproximityprompt then NotifyPoopSploit("fireproximityprompt") return end
                for _, v in workspace:QueryDescendants("ProximityPrompt") do
                    fireproximityprompt(v)
                end
            end,
        })
    end)

    Run(function() -- firetouchinterests
        World:CreateButton({
            Name = "Fire TouchInterests",
            Info = "Fires all touch interests",
            Function = function()
                if not firetouchinterest then NotifyPoopSploit("firetouchinterest"); return end
                if CharacterLib.Alive then
                    for _, Part in workspace:QueryDescendants("BasePart") do
                        firetouchinterest(CharacterLib.Root, Part, true)
                        task.wait()
                        firetouchinterest(CharacterLib.Root, Part, false)
                        task.wait()
                    end
                end
            end,
        })
    end)
end)

Run(function() -- Other
    Run(function() -- Freecam
        local Freecam, Speed, ShiftMultiplier, Part, ActionName

        local Keyboard = {
            W = 0,
            A = 0,
            S = 0,
            D = 0,
            E = 0,
            Q = 0,
            LeftShift = 0
        }

        local function KeyPress(_, State, Input)
            Keyboard[Input.KeyCode.Name] = State == Enum.UserInputState.Begin and 1 or 0
        end

        local function StepCamera(Delta)
            local Direction = vector.create(Keyboard.D - Keyboard.A, 0, Keyboard.S - Keyboard.W)
            if Direction ~= vector.zero then
                Direction = vector.unit(Direction)
            end

            Direction = (Direction + vector.create(0, Keyboard.E - Keyboard.Q, 0)) * Speed.Value
            if Keyboard.LeftShift == 1 then
                Direction *= ShiftMultiplier.Value
            end

            Part.CFrame = CFrame.lookAlong(Part.Position, Camera.CFrame.LookVector) * CFrame.new(Direction * 50 * Delta)
        end

        Freecam = Other:CreateModule({
            Name = "Freecam",
            Function = function(Enabled)
                if Enabled then
                    Part = Instance.new("Part")
                    Part.Transparency = 1
                    Part.Size = vector.zero
                    Part.Anchored = true
                    Part.CanCollide = false
                    Part.CanTouch = false
                    Part.CanQuery = false
                    Part.AudioCanCollide = false
                    Part.CastShadow = false
                    Part.Material = Enum.Material.Plastic
                    Part.CFrame = CharacterLib.Alive and CharacterLib.Head.CFrame or Camera.CFrame
                    Part.Parent = workspace

                    ActionName = HttpService:GenerateGUID(false)

                    Camera.CameraSubject = Part
                    Freecam:Clean(Camera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
                        Camera.CameraSubject = Part
                    end))
                    Freecam:Clean(RunService.PreRender:Connect(StepCamera))
			        ContextActionService:BindActionAtPriority(`FreecamKeyboard_{ActionName}`, KeyPress, false, 69420, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.E, Enum.KeyCode.Q, Enum.KeyCode.LeftShift)
                else
                    ContextActionService:UnbindAction(`FreecamKeyboard_{ActionName}`)
                    ActionName = nil
                    if Part then
                        Part:Destroy()
                        Part = nil
                    end
                    if CharacterLib.Alive then
                        Camera.CameraSubject = CharacterLib.Humanoid
                    end
                end
            end
        })

        Speed = Freecam:CreateSlider({
            Name = "Speed",
            Default = 1,
            Min = 0,
            Max = 10,
        })
        ShiftMultiplier = Freecam:CreateSlider({
            Name = "Shift Multiplier",
            Default = 2,
            Min = 0,
            Max = 10,
        })
    end)

    Run(function() -- Zoom
        local Zoom, ZoomSpeed, ZoomFactor, AllowScrolling, ScrollSpeed, Keybind

        Zoom = Other:CreateModule({
            Name = 'Zoom',
            Info = 'Zooms in your camera when pressing your binded key.',
            Enabled = function()
                local OldFov = Camera.FieldOfView
                local Con, db, db2, Zoomed
                local ActionName = HttpService:GenerateGUID(false)
                local Sensitivity = UIS.MouseDeltaSensitivity

                local function ScrollFunction(_, _, Input)
                    if UIS:GetFocusedTextBox() or not AllowScrolling.Enabled then return end
                    if Zoomed then
                        if Con then Con:Disconnect() end
                        local Start = Camera.FieldOfView
                        local Goal = math.min(Start - (Input.Position.Z * ScrollSpeed.Value * (Start / 12)), 120)
                        local Alpha = 0
                        Con = RunService.PreRender:Connect(function(Delta)
                            Alpha = math.min(Alpha + Delta * 2.5, 1)
                            local Value = TweenService:GetValue(Alpha, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
                            db, db2 = true, true
                            Camera.FieldOfView = math.lerp(Start, Goal, Value)
                            UIS.MouseDeltaSensitivity = math.min((Camera.FieldOfView / OldFov) * 2, Sensitivity)
                            db, db2 = nil, nil
                            if Value >= 1 then
                                Con:Disconnect()
                                Con = nil
                                Zoomed = true
                                ContextActionService:BindActionAtPriority('ZoomScroll_'..ActionName, ScrollFunction, false, 69420, Enum.UserInputType.MouseWheel)
                            end
                        end)
                    end
                end

                Zoom:Clean(UIS:GetPropertyChangedSignal('MouseDeltaSensitivity'):Connect(function()
                    if db2 then return end
                    Sensitivity = UIS.MouseDeltaSensitivity
                end))
                Zoom:Clean(Camera:GetPropertyChangedSignal('FieldOfView'):Connect(function()
                    if db then return end
                    OldFov = Camera.FieldOfView
                    if Zoomed then
                        Camera.FieldOfView = OldFov * (1 / ZoomFactor.Value)
                        UIS.MouseDeltaSensitivity = math.min((Camera.FieldOfView / OldFov) * 2, Sensitivity)
                    end
                end))
                Zoom:Clean(function()
                    if Con then
                        Con:Disconnect()
                        Con = nil
                    end
                    Camera.FieldOfView = OldFov
                    UIS.MouseDeltaSensitivity = Sensitivity
                    ContextActionService:UnbindAction('ZoomScroll_'..ActionName)
                end)
                Zoom:Clean(UIS.InputBegan:Connect(function(Input)
                    if not UIS:GetFocusedTextBox() and Keybind:Check(Input) then
                        if Con then Con:Disconnect() end
                        local Alpha = 0
                        Con = RunService.PreRender:Connect(function(Delta)
                            Alpha = math.min(Alpha + (Delta * ZoomSpeed.Value), 1)
                            local Value = TweenService:GetValue(Alpha, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
                            db, db2 = true, true
                            Camera.FieldOfView = math.lerp(OldFov, OldFov * (1 / ZoomFactor.Value), Value)
                            UIS.MouseDeltaSensitivity = math.min((Camera.FieldOfView / OldFov) * 2, Sensitivity)
                            db, db2 = nil, nil
                            if Value >= 1 then
                                Con:Disconnect()
                                Con = nil
                                Zoomed = true
                                ContextActionService:BindActionAtPriority('ZoomScroll_'..ActionName, ScrollFunction, false, 69420, Enum.UserInputType.MouseWheel)
                            end
                        end)
                    end
                end))
                Zoom:Clean(UIS.InputEnded:Connect(function(Input)
                    if Keybind:Check(Input) then
                        if Con then Con:Disconnect() end
                        Zoomed = false
                        ContextActionService:UnbindAction('ZoomScroll_'..ActionName)
                        local Start = Camera.FieldOfView
                        local Alpha = 0
                        Con = RunService.PreRender:Connect(function(Delta)
                            Alpha = math.min(Alpha + (Delta * ZoomSpeed.Value), 1)
                            local Value = TweenService:GetValue(Alpha, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
                            db, db2 = true, true
                            Camera.FieldOfView = math.lerp(Start, OldFov, Value)
                            UIS.MouseDeltaSensitivity = math.min((Camera.FieldOfView / OldFov) * 2, Sensitivity)
                            db, db2 = nil, nil
                            if Value >= 1 then
                                Con:Disconnect()
                                Con = nil
                            end
                        end)
                    end
                end))
            end
        })

        ZoomSpeed = Zoom:CreateSlider({
            Name = 'Zoom Speed',
            Default = 2.5,
            Min = 1,
            Max = 5,
            Decimal = 10
        })

        ZoomFactor = Zoom:CreateSlider({
            Name = 'Zoom Factor',
            Default = 2,
            Min = 1,
            Max = 5,
            Decimal = 10
        })

        AllowScrolling = Zoom:CreateToggle({
            Name = 'Allow Scrolling',
            Info = 'Allows you to scroll to change the zoom factor.',
            Default = true
        })

        ScrollSpeed = Zoom:CreateSlider({
            Name = 'Scroll Speed',
            Default = 1,
            Min = 1,
            Max = 3
        })

        Keybind = Zoom:CreateKeybind({
            Name = 'Zoom',
            Keybind = 'C'
        })
    end)

    Run(function() -- View
        local View, TextBox, Player

        View = Other:CreateModule({
            Name = "View",
            Info = "Views the specified player",
            Function = function(Enabled)
                if Enabled then
                    if not Player and TextBox.Text:match('%w+') then
                        Player = FindPlayer(TextBox.Text)
                    end
                    View:Clean(Camera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
                        local Character = CharacterLib:FindCharacter(Player)
                        if Character then
                            Camera.CameraSubject = Character.Humanoid
                        end
                    end))
                    View:Clean(CharacterLib.Events.CharacterAdded:Connect(function(Char)
                        if Char.Player and Char.Player == Player then
                            Camera.CameraSubject = Char.Humanoid
                        end
                    end))
                    View:Clean(CharacterLib.Events.CharacterRemoved:Connect(function(Char)
                        if Char.Player and Char.Player == Player and CharacterLib.Alive then
                            Camera.CameraSubject = CharacterLib.Humanoid
                        end
                    end))
                    View:Clean(Players.PlayerAdded:Connect(function()
                        if not Player and TextBox.Text:match('%w+') then
                            Player = FindPlayer(TextBox.Text)
                        end
                    end))
                    View:Clean(Players.PlayerRemoving:Connect(function(PlayerRemoving)
                        if PlayerRemoving == Player then
                            Camera.CameraSubject = CharacterLib.Humanoid
                            Player = nil
                            Notify({Text = "View has been disabled because the player left.", Duration = 4})
                        end
                    end))
                    if Player and Player.Parent then
                        local Character = CharacterLib:FindCharacter(Player)
                        if Character then
                            Camera.CameraSubject = Character.Humanoid
                        end
                    else
                        Player = nil
                        Notify({Text = "Select a player first.", Duration = 4})
                    end
                else
                    if CharacterLib.Alive then
                        Camera.CameraSubject = CharacterLib.Humanoid
                    end
                end
            end
        })

        TextBox = View:CreateTextBox({
            Name = "Player",
            PlaceholderText = "[Player Name]",
            Function = function(Text, Loaded)
                if Text:match('%w+') then
                    Player = FindPlayer(Text)
                    if Player then
                        if View.Enabled then
                            local Character = CharacterLib:FindCharacter(Player)
                            if Character then
                                Camera.CameraSubject = Character.Humanoid
                            end
                        end
                        if Loaded then return end
                        Notify({Text = `Set player to {GetFullPlayerName(Player)}`, Duration = 4})
                    else
                        Notify({Text = "Failed to find player", Duration = 4, Type = "Error"})
                    end
                else
                    Player = nil
                end
            end
        })
    end)

    Run(function() -- AntiKick
        local AntiKick, OldIndex, OldNamecall

        AntiKick = Other:CreateModule({
            Name = "AntiKick",
            Info = "Prevents you from getting kicked by local scripts",
            Enabled = function()
                if not hookmetamethod then NotifyPoopSploit("hookmetamethod") return end
                if not getnamecallmethod then NotifyPoopSploit("getnamecallmethod") return end
                OldIndex = hookmetamethod(game, "__index", newcclosure(function(self, Key)
                    if self == Plr and Key:lower() == "kick" then
                        return error("Expected ':' not '.' calling member function Kick", 2)
                    end
                    return OldIndex(self, Key)
                end))
                OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                    if self == Plr and getnamecallmethod():lower() == "kick" then
                        return
                    end
                    return OldNamecall(self, ...)
                end))
                AntiKick:Clean(function()
                    hookmetamethod(game, "__index", OldIndex)
                    hookmetamethod(game, "__namecall", OldNamecall)
                end)
            end,
        })
    end)

    Run(function() -- AntiTeleport
        local AntiTeleport, OldIndex, OldNamecall

        AntiTeleport = Other:CreateModule({
            Name = "AntiTeleport",
            Info = "Prevents you from getting teleported by local scripts",
            Enabled = function()
                if not hookmetamethod then NotifyPoopSploit("hookmetamethod") return end
                if not getnamecallmethod then NotifyPoopSploit("getnamecallmethod") return end
                OldIndex = hookmetamethod(game, "__index", newcclosure(function(self, Key)
                    if self == TeleportService then
                        if Key:lower() == "teleport" then
                            return error("Expected ':' not '.' calling member function Teleport", 2)
                        elseif Key == "TeleportToPlaceInstance" then
                            return error("Expected ':' not '.' calling member function TeleportToPlaceInstance", 2)
                        end
                    end
                    return OldIndex(self, Key)
                end))
                OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                    if self == TeleportService then
                        local Method = getnamecallmethod()
                        if Method:lower() == "teleport" or Method == "TeleportToPlaceInstance" then
                            return
                        end
                    end
                    return OldNamecall(self, ...)
                end))
                AntiTeleport:Clean(function()
                    hookmetamethod(game, "__index", OldIndex)
                    hookmetamethod(game, "__namecall", OldNamecall)
                end)
            end,
        })
    end)

    Run(function() -- AntiAFK
        local AntiAFK

        AntiAFK = Other:CreateModule({
            Name = 'AntiAFK',
            Info = 'Prevents you from getting kicked for being idle.',
            Enabled = function()
                if getconnections then
                    local Connections = getconnections(Plr.Idled)
                    for _, v in Connections do
                        v:Disable()
                    end
                    AntiAFK:Clean(function()
                        for _, v in Connections do
                            v:Enable()
                        end
                    end)
                else
                    AntiAFK:Clean(Plr.Idled:Connect(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.zero)
                    end))
                end
            end
        })
    end)

    Run(function() -- AntiFling
        local AntiFling

        AntiFling = Other:CreateModule({
            Name = "AntiFling",
            Info = "Prevents you from getting flung by other players",
            Enabled = function()
                AntiFling:Clean(RunService.PreSimulation:Connect(function()
                    for _, Player in CharacterLib.List do
                        for _, Part in Player.Character:QueryDescendants("BasePart[CanCollide = true]") do
                            Part.CanCollide = false
                        end
                    end
                end))
            end
        })
    end)

    Run(function() -- CameraNoclip
        local CameraNoclip

        CameraNoclip = Other:CreateModule({
            Name = "CameraNoclip",
            Info = "Allows your camera to clip through walls",
            Enabled = function()
                if debug.setconstant and debug.getconstants and getgc then
                    for _, f in getgc() do
                        if typeof(f) == "function" then
                            local Source, Name = debug.info(f, "sn")
                            if Name == "queryPoint" and Source:find("ZoomController.Popper") then
                                for i, c in debug.getconstants(f) do
                                    if c == 0.25 then
                                        debug.setconstant(f, i, 0)
                                        CameraNoclip:Clean(debug.setconstant, f, i, 0.25)
                                        break
                                    end
                                end
                                break
                            end
                        end
                    end
                else
                    if not debug.setconstant then
                        Notify({Text = `{TidalWave.Executor or 'Your executor'} doesn't support "debug.setconstant"\ncamera noclip may not work.`, Duration = 5, Type = 'Warning'})
                    elseif not debug.getconstants then
                        Notify({Text = `{TidalWave.Executor or 'Your executor'} doesn't support "debug.getconstants"\ncamera noclip may not work.`, Duration = 5, Type = 'Warning'})
                    elseif not getgc then
                        Notify({Text = `{TidalWave.Executor or 'Your executor'} doesn't support "getgc"\ncamera noclip may not work.`, Duration = 5, Type = 'Warning'})
                    end
                    
                    local Old = Plr.DevCameraOcclusionMode
                    CameraNoclip:Clean(function()
                        Plr.DevCameraOcclusionMode = Old
                    end)

                    Plr.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
                    CameraNoclip:Clean(Plr:GetPropertyChangedSignal("DevCameraOcclusionMode"):Connect(function()
                        Old = Plr.DevCameraOcclusionMode
                        Plr.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
                    end))
                end
            end
        })
    end)

    Run(function() -- Fix Camera
        Other:CreateButton({
            Name = "Fix Camera",
            Info = "Attempts to fix your camera",
            Function = function()
                if Modules.Freecam and Modules.Freecam.Enabled then
                    Modules.Freecam:Toggle(true)
                end
                if Modules.View and Modules.View.Enabled then
                    Modules.View:Toggle(true)
                end
                Camera.CameraSubject = CharacterLib.Humanoid
            end
        })
    end)

    Run(function() -- FPS Cap
        local FPSCap, FPS

        local clock = os.clock

        FPSCap = Other:CreateModule({
            Name = "FPS Cap",
            Info = "Sets your fps cap to the specified value.",
            Enabled = function()
                if setfpscap then
                    local OldCap = getfpscap and getfpscap() or 60
                    setfpscap(FPS.Value)
                    FPSCap:Clean(setfpscap, OldCap)
                else
                    local NextFrame = clock() + (1 / FPS.Value)
                    while FPSCap.Enabled do
                        local CurrentTime = clock()
                        if CurrentTime >= NextFrame then
                            NextFrame = CurrentTime + (1 / FPS.Value)
                            RunService.PreRender:Wait()
                        end
                    end
                end
            end,
        })

        FPS = FPSCap:CreateSlider({
            Name = "FPS",
            Default = 60,
            Min = 1,
            Max = 500,
            Function = function(Val)
                if FPSCap.Enabled and setfpscap then
                    setfpscap(Val)
                end
            end
        })
    end)

    Run(function() -- ShiftLock
        local ShiftLock

        ShiftLock = Other:CreateModule({
            Name = 'ShiftLock',
            Info = 'Force enables the option to toggle shift lock.',
            Enabled = function()
                Plr.DevEnableMouseLock = true
                ShiftLock:Clean(Plr:GetPropertyChangedSignal('DevEnableMouseLock'):Connect(function()
                    Plr.DevEnableMouseLock = true
                end))
            end,
        })
    end)

    Run(function()
        local NoGameplayPause

        NoGameplayPause = Other:CreateModule({
            Name = 'NoGameplayPause',
            Info = 'Removes the gameplay paused popup.',
            Function = function(Enabled)
                GuiService:SetGameplayPausedNotificationEnabled(not Enabled)
            end
        })
    end)

    Run(function() -- Panic
        local Panic

        Panic = Other:CreateButton({
            Name = 'Panic',
            Info = 'Disables all the currently enabled modules',
            Function = function()
                for _, v in Modules do
                    if v.Enabled then
                        v:Toggle(true)
                    end
                end
            end,
        })
    end)

    Run(function()
        local PartPath

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true

        PartPath = Other:CreateModule({
            Name = 'Part Path',
            Info = 'Copies the path of parts you click on.',
            Enabled = function()
                if not setclipboard then NotifyPoopSploit('setclipboard') return end
                PartPath:Clean(UIS.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 and CanClick() then
                        Params.FilterDescendantsInstances = {CharacterLib.Character}
                        local MouseLocation = UIS:GetMouseLocation()
                        local MouseRaycast = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)
                        local Raycast = workspace:Raycast(MouseRaycast.Origin, MouseRaycast.Direction * 1000, Params)
                        if Raycast then
                            local FullName = GetFullName(Raycast.Instance)
                            setclipboard(FullName)
                            Notify({Text = `Set Clipboard to {FullName}`})
                        end
                    end
                end))
            end
        })
    end)
end)

Run(function() -- Animations
    Run(function() -- Spasm
        local Spasm, Speed, Track

        local Animation = Instance.new("Animation")
        Animation.AnimationId = "rbxassetid://33796059"

        local function LocalAdded()
            if CharacterLib.RigType == Enum.HumanoidRigType.R15 then
                Notify({Text = "Spasm only works in R6", Duration = 4})
                Spasm:Toggle(true)
                return
            end
            local Animator: Animator = CharacterLib.Animator or CharacterLib.Humanoid
            Track = Animator:LoadAnimation(Animation)
            Track.Priority = Enum.AnimationPriority.Action4
            Track.Looped = true
            Track:Play(0, 1, Speed.Value)
        end

        local function LocalRemoved()
            if Track then
                Track:Stop()
                Track:Destroy()
                Track = nil
            end
        end

        Spasm = Animations:CreateModule({
            Name = "Spasm",
            Function = function(Enabled)
                if Enabled then
                    Spasm:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                    Spasm:Clean(CharacterLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if CharacterLib.Alive then
                        LocalAdded()
                    end
                else
                    LocalRemoved()
                end
            end,
        })

        Speed = Spasm:CreateSlider({
            Name = "Speed",
            Default = 100,
            Min = 0,
            Max = 100,
            Function = function(Val)
                if Track then
                    Track:AdjustSpeed(Val)
                end
            end,
        })
    end)

    Run(function() -- HeadThrow
        local HeadThrow, Speed, Track

        local Animation = Instance.new("Animation")
        Animation.AnimationId = "rbxassetid://35154961"

        local function LocalAdded()
            if CharacterLib.Humanoid.RigType == Enum.HumanoidRigType.R15 then
                Notify({Text = "Head Throw only works with R6"})
                HeadThrow:Toggle(true)
                return
            end
            local Animator: Animator = CharacterLib.Animator or CharacterLib.Humanoid
            Track = Animator:LoadAnimation(Animation)
            Track.Priority = Enum.AnimationPriority.Action4
            Track.Looped = true
            Track:Play(0, 1, Speed.Value)
        end

        local function LocalRemoved()
            if Track then
                Track:Stop()
                Track:Destroy()
                Track = nil
            end
        end

        HeadThrow = Animations:CreateModule({
            Name = "HeadThrow",
            Function = function(Enabled)
                if Enabled then
                    HeadThrow:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                    HeadThrow:Clean(CharacterLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if CharacterLib.Alive then
                        LocalAdded()
                    end
                else
                    LocalRemoved()
                end
            end
        })

        Speed = HeadThrow:CreateSlider({
            Name = 'Speed',
            Default = 1,
            Min = 0,
            Max = 10,
            Function = function(Val)
                if Track then
                    Track:AdjustSpeed(Val)
                end
            end
        })
    end)

    Run(function() -- FreezeAnimations
        local FreezeAnimations, Speed, UseMulti, Multi

        local AnimationTracks = {}

        FreezeAnimations = Animations:CreateModule({
            Name = "AnimationSpeed",
            Info = "Sets the speed of all your currently playing animations",
            Enabled = function()
                FreezeAnimations:Clean(RunService.PreAnimation:Connect(function()
                    if not CharacterLib.Alive then return end
                    local Animator: Animator = CharacterLib.Animator or CharacterLib.Humanoid
                    for i, v: AnimationTrack in Animator:GetPlayingAnimationTracks() do
                        if not AnimationTracks[v] then
                            AnimationTracks[v] = v.Speed
                        end
                        local CalculatedSpeed = UseMulti.Enabled and (AnimationTracks[v] * Multi.Value) or Speed.Value
                        if v.Speed ~= CalculatedSpeed then
                            v:AdjustSpeed(CalculatedSpeed)
                        end
                    end
                end))
                FreezeAnimations:Clean(function()
                    for i: AnimationTrack, v in AnimationTracks do
                        i:AdjustSpeed(v)
                    end
                    table.clear(AnimationTracks)
                end)
            end,
        })

        Speed = FreezeAnimations:CreateSlider({
            Name = "Speed",
            Default = 1,
            Min = 0,
            Max = 3,
            Decimal = 10,
        })

        UseMulti = FreezeAnimations:CreateToggle({
            Name = "Use Multi",
            Info = "Multiplies the speed of all your animations rather than just setting it",
            Function = function(Enabled)
                Multi:SetVisible(Enabled)
            end
        })

        Multi = FreezeAnimations:CreateSlider({
            Name = "Multi",
            Default = 1,
            Min = 0,
            Max = 3,
            Visible = false,
            Decimal = 10,
        })
    end)

    Run(function() -- Jerk
        local Jerk, Speed, Track

        local Animation = Instance.new("Animation")

        local function LocalAdded()
            Animation.AnimationId = CharacterLib.RigType == Enum.HumanoidRigType.R15 and "rbxassetid://698251653" or "rbxassetid://72042024"
            local Animator: Animator = CharacterLib.Animator or CharacterLib.Humanoid
            Track = Animator:LoadAnimation(Animation)
            Track.Priority = Enum.AnimationPriority.Action4
            Track:Play(0, 1, 0.7 * Speed.Value)
            Track.TimePosition = 0.6
        end

        local function LocalRemoved()
            if Track then
                Track:Stop()
                Track:Destroy()
                Track = nil
            end
        end

        Jerk = Animations:CreateModule({
            Name = "Jerk",
            Info = "Makes you absolutely jork it",
            Function = function(Enabled)
                if Enabled then
                    Jerk:Clean(RunService.PreAnimation:Connect(function()
                        if CharacterLib.Alive and Track and Track.TimePosition >= 0.7 then
                            Track.TimePosition = 0.6
                        end
                    end))
                    Jerk:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                    Jerk:Clean(CharacterLib.Events.LocalRemoved:Connect(LocalRemoved))

                    if CharacterLib.Alive then
                        LocalAdded()
                    end
                else
                    LocalRemoved()
                end
            end,
        })

        Speed = Jerk:CreateSlider({
            Name = "Jerk Speed",
            Default = 1,
            Min = 0,
            Max = 10,
            Decimal = 10,
            Function = function(Val)
                if Track then
                    Track:AdjustSpeed(Val)
                end
            end
        })
    end)

    Run(function() -- Bang
        local Bang, Player, Speed, Track

        local Offset = CFrame.new(0, 0, 1.1)
        local Animation = Instance.new("Animation")

        local function LocalAdded()
            Animation.AnimationId = CharacterLib.RigType == Enum.HumanoidRigType.R15 and "rbxassetid://5918726674" or "rbxassetid://148840371"
            local Animator: Animator = CharacterLib.Animator or CharacterLib.Humanoid
            Track = Animator:LoadAnimation(Animation)
            Track.Looped = true
            Track.Priority = Enum.AnimationPriority.Action4
            Track:Play(0, 1, Speed.Value * 3)
        end

        local function LocalRemoved()
            if Track then
                Track:Stop()
                Track:Destroy()
                Track = nil
            end
        end

        Bang = Animations:CreateModule({
            Name = "Bang",
            Info = "Bangs the specified player",
            Function = function(Enabled)
                if Enabled then
                    local Character
                    Bang:Clean(RunService.PreSimulation:Connect(function()
                        if not CharacterLib.Alive then return end
                        Character = Player and Player.Parent and ((Character and Player and Character.Player == Player and Character) or CharacterLib:FindCharacter(Player))
                        if Character then
                            CharacterLib.Root.CFrame = Character.Root.CFrame * Offset
                            CharacterLib.Root.AssemblyLinearVelocity = vector.zero
                            RunService.PostSimulation:Wait()
                            if not CharacterLib.Alive then return end
                            CharacterLib.Root.CFrame = Character.Root.CFrame * Offset
                            CharacterLib.Root.AssemblyLinearVelocity = vector.zero
                        elseif Character then
                            Character = nil
                        end
                    end))
                    Bang:Clean(Players.PlayerRemoving:Connect(function(PlayerRemoving)
                        if PlayerRemoving == Player then
                            Bang:Toggle(true)
                            Notify({Text = "Bang has been disabled because the player left.", Duration = 4})
                            Player = nil
                        end
                    end))
                    Bang:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                    Bang:Clean(CharacterLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if CharacterLib.Alive then
                        LocalAdded()
                    end
                else
                    LocalRemoved()
                end
            end
        })

        Bang:CreateTextBox({
            Name = "Player",
            PlaceholderText = "[Player Name]",
            Function = function(Text, Loaded)
                if Text:match('%w+') then
                    Player = FindPlayer(Text)
                    if Loaded then return end
                    if Player then
                        Notify({Text = `Set player to {GetFullPlayerName(Player)}`, Duration = 5})
                    else
                        Notify({Text = "Failed to find player", Type = "Error"})
                    end
                else
                    Player = nil
                end
            end
        })

        Speed = Bang:CreateSlider({
            Name = "Speed",
            Default = 1,
            Min = 0,
            Max = 3,
            Decimal = 100,
            Function = function(Val)
                if Track then
                    Track:AdjustSpeed(Val * 3)
                end
            end
        })
    end)

    Run(function() -- Carpet
        local Carpet, Player, Track

        local Animation = Instance.new("Animation")
        Animation.AnimationId = "rbxassetid://282574440"

        local Angle = CFrame.Angles(math.rad(-90), 0, 0)

        local function SetCFrame(cf, R15, HipHeight)
            if R15 then
                CharacterLib.Root.CFrame = cf:ToWorldSpace(CFrame.new(0, -HipHeight, 0) * Angle)
                CharacterLib.Root.AssemblyLinearVelocity = vector.zero
                CharacterLib.Root.AssemblyAngularVelocity = vector.zero
            else
                CharacterLib.Root.CFrame = cf
                CharacterLib.Root.AssemblyLinearVelocity = vector.zero
            end
        end

        local function LocalAdded()
            if CharacterLib.RigType == Enum.HumanoidRigType.R6 then
                local Animator: Animator = CharacterLib.Animator or CharacterLib.Humanoid
                Track = Animator:LoadAnimation(Animation)
                Track.Priority = Enum.AnimationPriority.Action4
                Track.Looped = true
                Track:Play(0, 1, 1)
            end
        end

        local function LocalRemoved()
            if Track then
                Track:Stop()
                Track:Destroy()
                Track = nil
            end
        end

        Carpet = Animations:CreateModule({
            Name = "Carpet",
            Info = "You become the specifed player's carpet",
            Function = function(Enabled)
                if Enabled then
                    local Character
                    Carpet:Clean(RunService.PreSimulation:Connect(function()
                        if not CharacterLib.Alive then return end
                        Character = Player and Player.Parent and ((Character and Player and Character.Player == Player and Character) or CharacterLib:FindCharacter(Player))
                        if Character then
                            if CharacterLib.Alive and CharacterLib.Humanoid.RigType == Enum.HumanoidRigType.R15 then
                                SetCFrame(Character.Root.CFrame, true, Character.HipHeight)
                                RunService.PostSimulation:Wait()
                                SetCFrame(Character.Root.CFrame, true, Character.HipHeight)
                            else
                                SetCFrame(Character.Root.CFrame, false)
                                RunService.PostSimulation:Wait()
                                SetCFrame(Character.Root.CFrame, false)
                            end
                        elseif Track then
                            Track:Stop()
                            Track:Destroy()
                            Track = nil
                        end
                    end))
                    Carpet:Clean(Players.PlayerRemoving:Connect(function(PlayerRemoving)
                        if PlayerRemoving == Player then
                            Carpet:Toggle(true)
                            Notify({Text = "Carpet has been disabled because the player left"})
                            Player = nil
                        end
                    end))
                    Carpet:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                    Carpet:Clean(CharacterLib.Events.LocalRemoved:Connect(LocalRemoved))
                else
                    LocalRemoved()
                end
            end
        })

        Carpet:CreateTextBox({
            Name = "Player",
            PlaceholderText = "[Player Name]",
            Function = function(Text, Loaded)
                if Text:match('%w+') then
                    Player = FindPlayer(Text)
                    if Loaded then return end
                    if Player then
                        Notify({Text = `Set player to {GetFullPlayerName(Player)})`, Duration = 4})
                    else
                        Notify({Text = "Failed to find player", Type = "Error"})
                    end
                else
                    Player = nil
                end
            end
        })
    end)

    Run(function() -- HeadSit
        local HeadSit, Player

        local Offset = CFrame.new(0, 1.6, 0.4)

        HeadSit = Animations:CreateModule({
            Name = "HeadSit",
            Info = "Sits on the specified player's head",
            Function = function(Enabled)
                if Enabled then
                    local Character
                    local Sat
                    HeadSit:Clean(RunService.PostSimulation:Connect(function()
                        if not CharacterLib.Alive then return end
                        Character = Player and Player.Parent and ((Character and Player and Character.Player == Player and Character) or CharacterLib:FindCharacter(Player))
                        if Character then
                            if Sat then
                                if not CharacterLib.Humanoid.Sit then
                                    HeadSit:Toggle(true)
                                end
                            else
                                Sat = true
                                CharacterLib.Humanoid.Sit = true
                            end
                            CharacterLib.Root.AssemblyLinearVelocity = vector.zero
                            CharacterLib.Root.CFrame = Character.Root.CFrame:ToWorldSpace(Offset)
                        else
                            CharacterLib.Humanoid.Sit = false
                            Sat = false
                        end
                    end))
                else
                    if CharacterLib.Alive then
                        CharacterLib.Humanoid.Sit = false
                    end
                end
            end
        })

        HeadSit:CreateTextBox({
            Name = "Player",
            PlaceholderText = "[Player Name]",
            Function = function(Text, Loaded)
                if Text:match('%w+') then
                    Player = FindPlayer(Text)
                    if Loaded then return end
                    if Player then
                        Notify({Text = `Set player to {GetFullPlayerName(Player)}`, Duration = 4})
                    else
                        Notify({Text = "Failed to find player", Type = "Error"})
                    end
                else
                    Player = nil
                end
            end
        })
    end)

    Run(function() -- BendOver
        local BendOver, Track, Player

        local Offset = CFrame.new(0.4, 0, -2.1) * CFrame.Angles(0, math.rad(14), 0)

        local Animation = Instance.new("Animation")
        Animation.AnimationId = "rbxassetid://10214311282"

        local function LocalAdded()
            if CharacterLib.RigType == Enum.HumanoidRigType.R6 then
                Notify({Text = "Bend Over only works with R15"})
                BendOver:Toggle(true)
                return
            end
            local Animator: Animator = CharacterLib.Animator or CharacterLib.Humanoid
            Track = Animator:LoadAnimation(Animation)
            Track.Priority = Enum.AnimationPriority.Action4
            Track:Play(0.1, 1, 1)
            Track.TimePosition = 4
            Track:AdjustSpeed(0)
        end

        local function LocalRemoved()
            if Track then
                Track:Stop()
                Track:Destroy()
                Track = nil
            end
        end
        
        BendOver = Animations:CreateModule({
            Name = 'BendOver',
            Info = 'It makes you bend over',
            Function = function(Enabled)
                if Enabled then
                    local Character
                    BendOver:Clean(RunService.PreSimulation:Connect(function()
                        if not CharacterLib.Alive then return end
                        Character = Player and Player.Parent and ((Character and Player and Character.Player == Player and Character) or CharacterLib:FindCharacter(Player))
                        if Character then
                            CharacterLib.Root.AssemblyLinearVelocity = vector.zero
                            CharacterLib.Root.CFrame = Character.Root.CFrame * Offset
                            RunService.PostSimulation:Wait()
                            CharacterLib.Root.AssemblyLinearVelocity = vector.zero
                            CharacterLib.Root.CFrame = Character.Root.CFrame * Offset
                        end
                    end))
                    BendOver:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                    BendOver:Clean(CharacterLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if CharacterLib.Alive then
                        LocalAdded()
                    end
                else
                    LocalRemoved()
                end
            end,
        })

        BendOver:CreateTextBox({
            Name = "Player",
            PlaceholderText = "[Player Name]",
            Function = function(Text, Loaded)
                if Text:match('%w+') then
                    Player = FindPlayer(Text)
                    if Loaded then return end
                    if Player then
                        Notify({Text = `Set player to {GetFullPlayerName(Player)}`, Duration = 5})
                    else
                        Notify({Text = "Failed to find player", Type = "Error"})
                    end
                else
                    Player = nil
                end
            end
        })
    end)

    Run(function() -- Orbit
        local Orbit, Speed, Distance, Player

        Orbit = Animations:CreateModule({
            Name = "Orbit",
            Info = "Orbits the specified player.",
            Enabled = function()
                local Rot = 0
                local Character
                Orbit:Clean(RunService.PreSimulation:Connect(function(Delta)
                    Character = Player and Player.Parent and ((Character and Player and Character.Player == Player and Character) or CharacterLib:FindCharacter(Player))
                    if Character then
                        Rot += (Speed.Value * math.pi) * Delta
                        local cf = CFrame.new(Character.Root.Position) * CFrame.Angles(0, math.rad(Rot), 0) * CFrame.new(0, 0, Distance.Value)
                        CharacterLib.Root.AssemblyLinearVelocity = vector.zero
                        CharacterLib.Root.CFrame = cf
                        RunService.PostSimulation:Wait()
                        if CharacterLib.Alive then
                            CharacterLib.Root.AssemblyLinearVelocity = vector.zero
                            CharacterLib.Root.CFrame = cf
                        end
                    end
                end))
            end
        })

        Speed = Orbit:CreateSlider({
            Name = "Speed",
            Default = 30,
            Min = 0,
            Max = 360,
        })

        Distance = Orbit:CreateSlider({
            Name = "Distance",
            Default = 5,
            Min = 0,
            Max = 20,
            Decimal = 100,
        })

        Orbit:CreateTextBox({
            Name = "Player",
            PlaceholderText = "[Name]",
            Function = function(Text, Loaded)
                if Text:match('%w+') then
                    Player = FindPlayer(Text)
                    if Loaded then return end
                    if Player then
                        Notify({Text = `Set player to {GetFullPlayerName(Player)}`, Duration = 4})
                    else
                        Notify({Text = "Failed to find player", Type = "Error"})
                    end
                else
                    Player = nil
                end
            end
        })
    end)

    Run(function() -- StareAt
        local StareAt, Player

        StareAt = Animations:CreateModule({
            Name = "StareAt",
            Info = "Stares at the specified player.",
            Enabled = function()
                local Character
                StareAt:Clean(RunService.PreRender:Connect(function()
                    if not CharacterLib.Alive then return end
                    Character = Player and Player.Parent and ((Character and Player and Character.Player == Player and Character) or CharacterLib:FindCharacter(Player))
                    if Character then
                        CharacterLib.Root.CFrame = CFrame.lookAt(CharacterLib.Root.Position, vector.create(Character.Root.Position.X, CharacterLib.Root.Position.Y, Character.Root.Position.Z))
                    end
                end))
            end
        })

        StareAt:CreateTextBox({
            Name = "Player",
            PlaceholderText = "[Player Name]",
            Function = function(Text)
                if Text:match('%w+') then
                    Player = FindPlayer(Text)
                    if Player then
                        Notify({Text = `Set player to {GetFullPlayerName(Player)}`, Duration = 5})
                    else
                        Notify({Text = "Failed to find player", Type = "Error"})
                    end
                else
                    Player = nil
                end
            end
        })
    end)

    Run(function() -- Dance
        local Dance, Track, R15Dance, R6Dance

        local R6Dances = {
            ["Dance"] = "rbxassetid://27789359",
            ["Moonwalk"] = "rbxassetid://30196114",
            ["Dance Like There's no Tomorrow"] = "rbxassetid://248263260",
            ["Disco"] = "rbxassetid://45834924",
            ["Party"] = "rbxassetid://33796059",
            ["Goal"] = "rbxassetid://28488254",
            ["Flute Dance"] = "rbxassetid://52155728"
        }

        local R15Dances = {
            ["River Dance"] = "rbxassetid://3333432454",
            ["Keeping Time"] = "rbxassetid://4555808220",
            ["Line Dance"] = "rbxassetid://4049037604",
            ["Air Dance"] = "rbxassetid://4555782893",
            ["Break Dance"] = "rbxassetid://10214311282",
            ["Reflex"] = "rbxassetid://10714010337",
            ["Around Town"] = "rbxassetid://10713981723",
            ["Idol Face"] = "rbxassetid://10714372526",
            ["Fancy Feet"] = "rbxassetid://10714076981",
            ["Robot"] = "rbxassetid://10714392151",
            ["Still Standing"] = "rbxassetid://11444443576"
        }

        local Animation = Instance.new("Animation")

        local function LocalAdded()
            Animation.AnimationId = CharacterLib.RigType == Enum.HumanoidRigType.R15 and R15Dances[R15Dance.Value] or R6Dances[R6Dance.Value]
            local Animator: Animator = CharacterLib.Animator or CharacterLib.Humanoid
            Track = Animator:LoadAnimation(Animation)
            Track.Priority = Enum.AnimationPriority.Action4
            Track.Looped = true
            Track:Play(0, 1, 1)
        end

        local function LocalRemoved()
            if Track then
                Track:Stop()
                Track:Destroy()
                Track = nil
            end
        end

        Dance = Animations:CreateModule({
            Name = "Dance",
            Info = "It makes you dance.",
            Function = function(Enabled)
                if Enabled then
                    Dance:Clean(CharacterLib.Events.LocalAdded:Connect(LocalAdded))
                    Dance:Clean(CharacterLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if CharacterLib.Alive then
                        LocalAdded()
                    end
                else
                    LocalRemoved()
                end
            end,
        })

        R6Dance = Dance:CreateDropdown({
            Name = "R6 Dances",
            List = {"Dance", "Moonwalk", "Dance Like There's no Tomorrow", "Disco", "Party", "Goal", "Flute Dance"},
            Function = function(Val)
                if Dance.Enabled and CharacterLib.Alive and CharacterLib.RigType == Enum.HumanoidRigType.R6 then
                    LocalRemoved()
                    Animation.AnimationId = R6Dances[R6Dance.Value]
                    LocalAdded()
                end
            end
        })

        R15Dance = Dance:CreateDropdown({
            Name = "R15 Dances",
            List = {"River Dance", "Keeping Time", "Line Dance", "Air Dance", "Break Dance", "Reflex", "Around Town", "Idol Face", "Fancy Feet", "Robot", "Still Standing"},
            Function = function(Val)
                if Dance.Enabled and CharacterLib.Alive and CharacterLib.RigType == Enum.HumanoidRigType.R15 then
                    LocalRemoved()
                    Animation.AnimationId = R15Dances[Val]
                    LocalAdded()
                end
            end
        })
    end)

    Run(function() -- Refresh Animations
        Animations:CreateButton({
            Name = "Refresh Animations",
            Info = "Refreshes all your currently playing animations",
            Function = function()
                if CharacterLib.Alive then
                    local Animate = CharacterLib.Character:FindFirstChild("Animate")
                    if Animate then
                        Animate.Enabled = false
                    end
                    for _, v in (CharacterLib.Animator or CharacterLib.Humanoid):GetPlayingAnimationTracks() do
                        v:Stop()
                    end
                    if Animate then
                        Animate.Enabled = true
                    end
                end
            end
        })
    end)
end)

Run(function() -- Scripts
    Run(function() -- Infinite Yield
        Scripts:CreateButton({
            Name = "Infinite Yield",
            Function = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
            end
        })
    end)

    Run(function() -- Dex
        Scripts:CreateButton({
            Name = "Dex",
            Function = function()
                local Dex = isfile('DexModified.lua') and readfile('DexModified.lua') or game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/dex.lua')
                loadstring(Dex)()
            end
        })
    end)

    Run(function() -- Simple Spy
        Scripts:CreateButton({
            Name = "Simple Spy",
            Function = function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
            end
        })
    end)

    Run(function() -- Cobalt Spy
        Scripts:CreateButton({
            Name = "Cobalt Spy",
            Function = function()
                loadstring(game:HttpGet('https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau'))()
            end
        })
    end)

    Run(function() -- Audio Logger
        Scripts:CreateButton({
            Name = "Audio Logger",
            Function = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua'))()
            end
        })
    end)

    Run(function() -- Syn Save Instance
        Scripts:CreateButton({
            Name = "Syn Save Instance",
            Function = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.lua'), "saveinstance")({})
            end
        })
    end)
end)

Run(function() -- Server
    Run(function() -- Server Hop
        local ServerHop, Priority, UseExtraOptions, MinPlayers, MaxPlayers, MinPing, MaxPing

        local Priorities = {
            ['Low Players'] = function(a, b)
                return a.Players < b.Players
            end,
            ['High Players'] = function(a, b)
                return a.Players > b.Players
            end,
            ['Low Ping'] = function(a, b)
                return a.Ping < b.Ping
            end,
            ['High Ping'] = function(a, b)
                return a.Ping > b.Ping
            end,
        }
    
        ServerHop = Server:CreateButton({
            Name = "Server Hop",
            Function = function()
                local Data = game:HttpGet(`https://games.roblox.com/v1/games/{game.PlaceId}/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true`)
                local Body = HttpService:JSONDecode(Data)

                local Servers = {}

                if Body and Body.data then
                    for _, v in Body.data do
                        if v.id ~= game.JobId and v.playing >= MinPlayers.Value and v.playing <= MaxPlayers.Value and v.ping >= MinPing.Value and v.ping <= MaxPing.Value then
                            if UseExtraOptions.Enabled and v.playing < MinPlayers.Value and v.playing > MaxPlayers.Value and v.ping < MinPing.Value and v.ping > MaxPing.Value then continue end
                            Servers[#Servers + 1] = {
                                JobId = v.id,
                                Ping = v.ping,
                                Players = v.playing
                            }
                        end
                    end
                end

                table.sort(Servers, Priorities[Priority.Value])

                if #Servers > 0 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, Servers[1].JobId, Plr)
                else
                    Notify({Text = "Failed to find any servers.", Duration = 4, Type = "Error"})
                end
            end
        })

        Priority = ServerHop:CreateDropdown({
            Name = 'Priority',
            List = {'Low Players', 'High Players', 'Low Ping', 'High Ping'}
        })

        UseExtraOptions = ServerHop:CreateToggle({
            Name = 'Use Extra Options',
            Function = function(Enabled)
                MinPlayers:SetVisible(Enabled)
                MaxPlayers:SetVisible(Enabled)
                MinPing:SetVisible(Enabled)
                MaxPing:SetVisible(Enabled)
            end
        })

        MinPlayers = ServerHop:CreateSlider({
            Name = 'Min Players',
            Default = 0,
            Min = 0,
            Max = 10,
            Visible = false
        })

        MaxPlayers = ServerHop:CreateSlider({
            Name = 'Max Players',
            Default = 100,
            Min = 0,
            Max = 100,
            Visible = false
        })

        MinPing = ServerHop:CreateSlider({
            Name = 'Min Ping',
            Default = 0,
            Min = 0,
            Max = 50,
            Visible = false
        })

        MaxPing = ServerHop:CreateSlider({
            Name = 'Max Ping',
            Default = 100,
            Min = 0,
            Max = 100,
            Visible = false
        })
    end)

    Run(function() -- Rejoin
        Server:CreateButton({
            Name = "Rejoin",
            Function = function()
                if #Players:GetPlayers() > 1 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Plr)
                else
                    TeleportService:Teleport(game.PlaceId)
                end
            end
        })
    end)

    Run(function() -- Copy GameId
        Server:CreateButton({
            Name = "Copy GameId",
            Function = function()
                if not setclipboard then NotifyPoopSploit("setclipboard") return end
                setclipboard(tostring(game.GameId))
                Notify({Text = "Copied game Id to clipboard.", Duration = 3})
            end
        })
    end)

    Run(function() -- Notify GameId
        Server:CreateButton({
            Name = "Notify GameId",
            Function = function()
                Notify({Text = tostring(game.GameId), Duration = 5})
            end
        })
    end)

    Run(function() -- Copy PlaceId
        Server:CreateButton({
            Name = "Copy PlaceId",
            Function = function()
                if not setclipboard then NotifyPoopSploit("setclipboard") return end
                setclipboard(tostring(game.PlaceId))
                Notify({Text = "Copied place Id to clipboard.", Duration = 3})
            end
        })
    end)

    Run(function() -- Notify PlaceId
        Server:CreateButton({
            Name = "Notify PlaceId",
            Function = function()
                Notify({Text = tostring(game.PlaceId), Duration = 5})
            end
        })
    end)

    Run(function() -- Copy JobId
        Server:CreateButton({
            Name = "Copy JobId",
            Function = function()
                if not setclipboard then NotifyPoopSploit("setclipboard") return end
                setclipboard(tostring(game.JobId))
                Notify({Text = "Copied job Id to clipboard.", Duration = 3})
            end
        })
    end)

    Run(function() -- Copy Root Position
        Server:CreateButton({
            Name = "Copy Root Position",
            Function = function()
                if not setclipboard then NotifyPoopSploit("setclipboard") return end
                if not CharacterLib.Alive then return end

                local Position = (CharacterLib.Root.Position * 100):Floor()
                setclipboard(`{Position.X / 100}, {Position.Y / 100}, {Position.Z / 100}`)
                Notify({Text = "Copied root position to clipboard."})
            end
        })
    end)

    Run(function() -- Copy WalkSpeed
        Server:CreateButton({
            Name = "Copy WalkSpeed",
            Function = function()
                if not setclipboard then NotifyPoopSploit("setclipboard") return end
                if not CharacterLib.Alive then return end
                setclipboard(tostring(math.floor(CharacterLib.Humanoid.WalkSpeed * 100) / 100))
                Notify({Text = "Copied WalkSpeed to clipboard."})
            end
        })
    end)

    Run(function() -- Notify WalkSpeed
        Server:CreateButton({
            Name = "Notify WalkSpeed",
            Function = function()
                if not CharacterLib.Alive then return end
                Notify({Text = tostring(math.floor(CharacterLib.Humanoid.WalkSpeed * 100) / 100), Duration = 5})
            end
        })
    end)

    Run(function() -- Copy JumpPower
        Server:CreateButton({
            Name = "Copy JumpPower",
            Function = function()
                if not setclipboard then NotifyPoopSploit("setclipboard") return end
                if not CharacterLib.Alive then return end
                setclipboard(tostring(math.floor(CharacterLib.Humanoid.JumpPower * 100) / 100))
                Notify({Text = "Copied JumpPower to clipboard."})
            end
        })
    end)
    
    Run(function() -- Notify JumpPower
        Server:CreateButton({
            Name = "Notify JumpPower",
            Function = function()
                if not CharacterLib.Alive then return end
                Notify({Text = tostring(math.floor(CharacterLib.Humanoid.JumpPower * 100) / 100), Duration = 5})
            end
        })
    end)
end)