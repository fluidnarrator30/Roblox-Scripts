local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

const Lighting: Lighting = GetService('Lighting')
const Players: Players = GetService('Players')
const RunService: RunService = GetService('RunService')
const TeleportService: TeleportService = GetService('TeleportService')
const TextService: TextService = GetService('TextService')
const UIS: UserInputService = GetService('UserInputService')
const HttpService: HttpService = GetService('HttpService')
const ProximityPromptService: ProximityPromptService = GetService('ProximityPromptService')
const ContextActionService: ContextActionService = GetService('ContextActionService')
const GuiService: GuiService = GetService('GuiService')
const VirtualUser: VirtualUser = GetService('VirtualUser')
const TweenService: TweenService = GetService('TweenService')
const Stats: Stats = GetService('Stats')

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local Modules = TidalWave.Modules
local EntityLib = TidalWave.Libraries.EntityLib
local Drawing = TidalWave.Libraries.Drawing
local ObjectFunctions = TidalWave.Libraries.ObjectFunctions
local Signal = TidalWave.Libraries.Signal
local AuraAnimations = TidalWave.Libraries.AuraAnimations

local Combat = Categories.Combat
local PlayerCategory = Categories.Player
local Movement = Categories.Movement
local Visuals = Categories.Visuals
local World = Categories.World
local Other = Categories.Other
local Animations = Categories.Animations
local Scripts = Categories.Scripts
local Server = Categories.Server

const IsStudio = RunService:IsStudio()

local Plr: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')

local Color3 = table.clone(Color3)
Color3.White = Color3.new(1, 1, 1)
Color3.Black = Color3.new()

local table = table.clone(table)
function table.len(Tab)
	local Len = 0
	for _ in Tab do
		Len += 1
	end
	return Len
end

local UDim2 = table.clone(UDim2)
UDim2.zero = UDim2.new()

local vector = table.clone(vector)
vector.xAxis = vector.create(1, 0, 0)
vector.yAxis = vector.create(0, 1, 0)
vector.zAxis = vector.create(0, 0, 1)
vector.hort = vector.create(1, 0, 1)
vector.huge = vector.create(math.huge, math.huge, math.huge)
vector.hugeX = vector.create(math.huge, 0, 0)
vector.hugeY = vector.create(0, math.huge, 0)
vector.hugeZ = vector.create(0, 0, math.huge)
vector.hugeXZ = vector.create(math.huge, 0, math.huge)
function vector.round(Vec)
    return vector.create(math.round(Vec.X), math.round(Vec.Y), math.round(Vec.Z))
end

local newcclosure = newcclosure or function(f) return f end
local getnamecallmethod = getnamecallmethod or get_namecall_method
local setclipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
local fireproximityprompt = fireproximityprompt
local fireclickdetector = fireclickdetector
local firetouchinterest = firetouchinterest
local hookmetamethod = hookmetamethod
local mousemoverel = mousemoverel
local getconnections = getconnections or get_signal_cons
local hookfunction = hookfunction
local restorefunction = restorefunction
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
local getcustomasset = getcustomasset or function(Path) return `rbxassets://{Path}` end
local isfile = isfile or function() return false end
local readfile = readfile
local require = (IsStudio or (not table.find({'Solara', 'Xeno'}, ({identifyexecutor()})[1]))) and require or nil
local loadstring = IsStudio and require(script.Parent.Parent.Libraries.Loadstring) or loadstring

local ViewmodelTool
local ViewmodelMotor
local GetTextBoundsParams = Instance.new('GetTextBoundsParams')

TidalWave:Clean(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
    Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')
end))

local function Notify(Properties)
    TidalWave:Notify(Properties)
end

local function Run(f)
    f()
end

local function SafeRef(Obj: Instance, Path: {string}): Instance?
    return ObjectFunctions:SafeRef(Obj, Path)
end

local function NotifyPoopSploit(Function)
    Notify({
        Title = 'Poop Sploit',
        Text = `Your executor doesn't support '{Function}'`,
        Type = 'Error',
        Duration = 5,
    })
end

local function GetTextBounds(Text: string, TextSize: number, Font: Font, Width: number?)
    GetTextBoundsParams.Text = Text
    GetTextBoundsParams.Font = Font
    GetTextBoundsParams.Size = TextSize
    GetTextBoundsParams.Width = Width or 9e9
	GetTextBoundsParams.RichText = Text:match('<[^<>]->') ~= nil

    return TextService:GetTextBoundsAsync(GetTextBoundsParams)
end

local function IsFriend(Player: Player): boolean
    return TidalWave:IsFriend(Player)
end

local function GetTeamColor(Ent): Color3
    return EntityLib:GetTeamColor(Ent)
end

local function GetFullPlayerName(Player: Player): string
    return Player.DisplayName == Player.Name and Player.Name or `{Player.DisplayName} (@{Player.Name})`
end

local function GetFullName(Object: Instance): string
    return ObjectFunctions:GetFullName(Object)
end

local function CanClick(): boolean
    if UIS:GetFocusedTextBox() then return false end
    if TidalWave.Gui.ScaledGui.Gui.TopBar.Visible then return false end
    if iswindowactive and not iswindowactive() then return false end
    return true
end

local function GetAssetFromText(Text: string): string
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
					Notify({
						Text = 'File not found',
						Duration = 10,
						Type = 'Error'
					})
				end
			else
				local Success, Result = pcall(function()
					return getcustomasset(Text)
				end)

				if Success and Result and Result ~= '' then
					return Result
				else
					Notify({
						Text = Result,
						Duration = 10,
						Type = 'Error'
					})
				end
			end
		end
	end

	return nil
end

local FrictionTable, OldPhysicalProperties = {}, {}

local function UpdateFriction()
	if table.len(FrictionTable) > 0 then
		if EntityLib.Alive then
			for _, v in EntityLib.Character:GetChildren() do
				if v:IsA('BasePart') and v ~= EntityLib.Root and not OldPhysicalProperties[v] then
					OldPhysicalProperties[v] = v.CustomPhysicalProperties or 'None'
					v.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.2, 0.5, 1, 1)
				end
			end
		end
	else
		for Part, Old in OldPhysicalProperties do
			Part.CustomPhysicalProperties = Old ~= 'None' and Old or nil
		end
		table.clear(OldPhysicalProperties)
	end
end

local TargetStrafeVector

Run(function() -- Combat
    Run(function() -- Aimbot
        local Aimbot, Method, WallCheck, Part, Fov, Speed, Circle, CircleObject, OutlineColor, FillColor, Thickness

        local UserGameSettings = UserSettings():GetService('UserGameSettings')

        local function CreateCircle()
            CircleObject = Drawing.new('Circle')
            CircleObject.Radius = Fov.Value
            CircleObject.FillTransparency = FillColor.Transparency
            CircleObject.OutlineTransparency = OutlineColor.Transparency
            CircleObject.FillColor = FillColor.Color
            CircleObject.OutlineColor = OutlineColor.Color
            CircleObject.Thickness = Thickness.Value
            CircleObject.Position = UIS:GetMouseLocation()
            CircleObject.Visible = Aimbot.Enabled
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
                CircleObject.FillTransparency = FillColor.Transparency
                CircleObject.OutlineTransparency = OutlineColor.Transparency
                CircleObject.FillColor = FillColor.Color
                CircleObject.OutlineColor = OutlineColor.Color
                CircleObject.Thickness = Thickness.Value
            end
        end

        Aimbot = Combat:CreateModule({
            Name = 'Aimbot',
            Info = 'Automatically moves your mouse towards the closest player',
            Function = function(Enabled)
                if Enabled then
                    if not mousemoverel then NotifyPoopSploit('mousemoverel') return end
                    if Circle.Enabled and not CircleObject then
                        CreateCircle()
                    end
                    
                    Aimbot:Clean(RunService.PreRender:Connect(function(Delta)
                        if CircleObject then
                            CircleObject.Position = UIS:GetMouseLocation()
                        end

                        if EntityLib.Alive and CanClick() then
                            local Ent, Vector = EntityLib:GetClosestEntityWithinMouse({
                                Part = Part.Value,
                                Range = Fov.Value,
                                Origin = Camera.CFrame.Position,
                                WallCheck = WallCheck.Enabled,
                                NPCs = true,
                                Players = true
                            })

                            if Ent then
                                if Method.Value == 'Camera' then
                                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Ent[Part.Value].Position)
                                else
                                    local MouseLocation = UIS:GetMouseLocation()
                                    local MouseDelta = Vector2.new(Vector.X - MouseLocation.X, Vector.Y - MouseLocation.Y) / UserGameSettings.MouseSensitivity
                                    if MouseDelta.Magnitude > 1 then
                                        MouseDelta *= math.min(Speed.Value * Delta, 1)
                                        mousemoverel(MouseDelta.X, MouseDelta.Y)
                                    end
                                end
                            end
                        end
                    end))
                else
                    RemoveCircle()
                end
            end
        })

        Method = Aimbot:CreateDropdown({
            Name = 'Method',
            List = {'Mouse', 'Camera'}
        })

        WallCheck = Aimbot:CreateToggle({
            Name = 'Wall Check',
            Default = true
        })

        Part = Aimbot:CreateDropdown({
            Name = 'Part',
            List = {'Head', 'Root', 'Closest'}
        })

        Fov = Aimbot:CreateSlider({
            Name = 'Fov',
            Default = 100,
            Min = 0,
            Max = 1000,
            Function = UpdateCircle
        })

        Speed = Aimbot:CreateSlider({
            Name = 'Speed',
            Default = 10,
            Min = 1,
            Max = 30,
            Decimal = 10
        })

        Circle = Aimbot:CreateToggle({
            Name = 'Circle',
            Function = function(Enabled)
                if Enabled and Aimbot.Enabled then
                    CreateCircle()
                else
                    RemoveCircle()
                end
            end
        })

        Thickness = Circle:CreateSlider({
            Name = 'Thickness',
            Default = 1,
            Min = 1,
            Max = 10,
            Function = UpdateCircle
        })

        OutlineColor = Circle:CreateColorPicker({
            Name = 'Outline Color',
            Function = UpdateCircle
        })

        FillColor = Circle:CreateColorPicker({
            Name = 'Fill Color',
            Transparency = 1,
            Function = UpdateCircle
        })
    end)

    Run(function() -- TriggerBot
        local TriggerBot, MouseButton, Mode, MaxDistance

        local Held

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true

        TriggerBot = Combat:CreateModule({
            Name = 'TriggerBot',
            Info = 'Automatically clicks when hovering over another player',
            Function = function(Enabled)
                if Enabled then
                    if EntityLib.Alive then
                        Params.FilterDescendantsInstances = {EntityLib.Character}
                    end

                    TriggerBot:Clean(EntityLib.Events.LocalAdded:Connect(function()
                        Params.FilterDescendantsInstances = {EntityLib.Character}
                    end))
                    
                    TriggerBot:Clean(RunService.PreRender:Connect(function()
                        if EntityLib.Alive and CanClick() then
                            local MouseLocation = UIS:GetMouseLocation()
                            local MouseRaycast = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)
                            local Raycast = workspace:Raycast(MouseRaycast.Origin, MouseRaycast.Direction * MaxDistance.Value, Params)
                            local Ent = Raycast and Raycast.Instance.Parent.ClassName == 'Model' and EntityLib:FindEntity(Raycast.Instance.Parent)

                            if Ent and not Ent.Teammate and EntityLib:CanAttack(Ent) then
                                if Mode.Value == 'Hold' then
                                    if not Held then
                                        (MouseButton.Value == 'LeftClick' and mouse1press or mouse2press)()
                                        Held = true
                                    end
                                else
                                    (MouseButton.Value == 'LeftClick' and mouse1click or mouse2click)()
                                end
                            elseif Held and Mode.Value == 'Hold' then
                                Held = false
                                (MouseButton.Value == 'LeftClick' and mouse1release or mouse2release)()
                            end
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

        MaxDistance = TriggerBot:CreateSlider({
            Name = 'Max Distance',
            Default = 1000,
            Min = 0,
            Max = 1000
        })
    end)

    Run(function() -- AutoClicker
        local AutoClicker, Interval, RandomizeInterval, IntervalMin, IntervalMax

        local Rand = Random.new()

        local function Wait()
            if RandomizeInterval.Enabled then
                task.wait(Rand:NextNumber(IntervalMin.Value, IntervalMax.Value))
            else
                task.wait(Interval.Value)
            end
        end

        AutoClicker = Combat:CreateModule({
            Name = 'AutoClicker',
            Info = 'Automatically clicks for you',
            Enabled = function()
                AutoClicker:Clean(UIS.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 and CanClick() then
                        repeat
                            local Tool = EntityLib.Alive and EntityLib.Character:FindFirstChildOfClass('Tool')
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
            Name = 'Interval',
            Default = 0.1,
            Min = 0,
            Max = 1,
        })

        RandomizeInterval = AutoClicker:CreateToggle({
            Name = 'Randomize Interval',
        })

        IntervalMin = AutoClicker:CreateSlider({
            Name = 'Interval Min',
            Default = 0.09,
            Min = 0,
            Max = 1,
        })

        IntervalMax = AutoClicker:CreateSlider({
            Name = 'Interval Max',
            Default = 0.11,
            Min = 0,
            Max = 1,
        })
    end)

    Run(function() -- Reach
        local Reach, UsePlayers, UseNPCs, Mode, Value, Chance
        
        local Modified = {}
        local Tool, TouchInterest

        local Params = OverlapParams.new()
        Params.FilterType = Enum.RaycastFilterType.Include
        
        local Rand = Random.new()

        local function LocalAdded()
            Tool = EntityLib.Character:FindFirstChildWhichIsA('Tool', true)
            TouchInterest = Tool and Tool:FindFirstChildWhichIsA('TouchTransmitter', true) or nil

            Reach:Clean(EntityLib.Character.DescendantAdded:Connect(function(Child)
                if Child:IsA('Tool') then
                    Tool = Child
                    TouchInterest = Tool:FindFirstChildWhichIsA('TouchTransmitter', true)
                end
            end))

            Reach:Clean(EntityLib.Character.DescendantRemoving:Connect(function(Child)
                if Child == Tool then
                    Tool = nil
                    TouchInterest = nil
                end
            end))
        end

        local function LocalRemoved()
            Reach:CleanUp()
            Tool = nil
            TouchInterest = nil
        end
        
        Reach = Combat:CreateModule({
            Name = 'Reach',
            Info = 'Extends tool attack reach',
            Function = function(Enabled)
                if Enabled then
                    if EntityLib.Alive then
                        LocalAdded()
                    end

                    Reach:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    Reach:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))

                    while Reach.Enabled do
                        if Tool and TouchInterest then
                            if Mode.Value == 'TouchInterest' and firetouchinterest then
                                local Characters = {}
                                for _, Entity in EntityLib.List do
                                    if Entity.Player and not UsePlayers.Enabled then continue end
                                    if Entity.NPC and not UseNPCs.Enabled then continue end
                                    if EntityLib:CanAttack(Entity) then
                                        table.insert(Characters, Entity.Character)
                                    end
                                end
        
                                Params.FilterDescendantsInstances = Characters
                                local Parts = workspace:GetPartBoundsInBox(TouchInterest.Parent.CFrame * CFrame.new(0, 0, Value.Value / 2), TouchInterest.Parent.Size + vector.create(0, 0, Value.Value), Params)
        
                                for _, Part in Parts do
                                    if Rand:NextNumber(0, 100) > Chance.Value then
                                        task.wait(0.2)
                                        break
                                    end
        
                                    firetouchinterest(TouchInterest.Parent, Part, true)
                                    firetouchinterest(TouchInterest.Parent, Part, false)
                                end
                            else
                                if not Modified[TouchInterest.Parent] then
                                    Modified[TouchInterest.Parent] = {
                                        Size = TouchInterest.Parent.Size,
                                        Massless = TouchInterest.Parent.Massless
                                    }
                                end
        
                                TouchInterest.Parent.Size = Modified[TouchInterest.Parent].Size + vector.create(0, 0, Value.Value)
                                TouchInterest.Parent.Massless = true
                            end
                        end

                        task.wait()
                    end
                else
                    Tool = nil
                    TouchInterest = nil
                    for Part, Properties in Modified do
                        for Property, Value in Properties do
                            Part[Property] = Value
                        end
                    end
                    table.clear(Modified)
                end
            end,
        })

        UsePlayers = Reach:CreateToggle({
            Name = 'Players',
            Default = true
        })

        UseNPCs = Reach:CreateToggle({
            Name = 'NPCs',
        })

        Mode = Reach:CreateDropdown({
            Name = 'Mode',
            List = {'TouchInterest', 'Resize'},
            Info = 'TouchInterest - Reports fake collision events to the server\nResize - Physically modifies the tools size',
            Function = function(Val)
                Chance:SetVisible(Val == 'TouchInterest')
            end,
        })

        Value = Reach:CreateSlider({
            Name = 'Range',
            Default = 2,
            Min = 0,
            Max = 2,
            Decimal = 10
        })

        Chance = Reach:CreateSlider({
            Name = 'Chance',
            Min = 0,
            Max = 100,
            Default = 100,
            Suffix = '%'
        })
    end)
    
    Run(function() -- HitboxExpander
        local HitboxExpander, Target, Color, X, Y, Z, Collision

        local Parts = {}
        local db = {}

        local function AddPart(Part)
            local Tab = {
                Size = Part.Size,
                Color = Part.Color,
                Transparency = Part.Transparency,
                CanCollide = Part.CanCollide
            }

            Part.Size = vector.create(X.Value, Y.Value, Z.Value)
            Part.Color = Color.Color
            Part.Transparency = Color.Transparency
            Part.CanCollide = Collision.Enabled

            HitboxExpander:Clean(Part.Changed:Connect(function(Property)
                if db[Part] then return end
                db[Part] = true
                if Property == 'CanCollide' then
                    Part.CanCollide = Collision.Enabled
                end
                if Tab[Property] then
                    Tab[Property] = Part[Property]
                end
                db[Part] = nil
            end))

            Parts[Part] = Tab
        end

        HitboxExpander = Combat:CreateModule({
            Name = "HitboxExpander",
            Info = "Expands the hitbox of enemies",
            Function = function(Enabled)
                if Enabled then
                    HitboxExpander:Clean(RunService.PreSimulation:Connect(function()
                        for _, Player in EntityLib.List do
                            if Player.Teammate then continue end
                            if Target.Value == 'Head' then
                                if Player.Head and not Parts[Player.Head] then
                                    AddPart(Player.Head)
                                end
                            elseif Target.Value == 'Root' then
                                if Player.Root and not Parts[Player.Root] then
                                    AddPart(Player.Root)
                                end
                            elseif Target.Value == 'All' then
                                for _, Part in Player.Character:QueryDescendants('BasePart') do
                                    if Parts[Part] then continue end
                                    AddPart(Part)
                                end
                            end
                        end
                    end))
                else
                    for Part, Properties in Parts do
                        for Property, Value in Properties do
                            Part[Property] = Value
                        end
                    end
                    table.clear(Parts)
                    table.clear(db)
                end
            end
        })

        local function Restart()
            if HitboxExpander.Enabled then
                HitboxExpander:Toggle(true)
                HitboxExpander:Toggle(true)
            end
        end

        local function UpdateSize()
            for Part in Parts do
                db[Part] = true
                Part.Size = vector.create(X.Value, Y.Value, Z.Value)
                db[Part] = nil
            end
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

        Target = HitboxExpander:CreateDropdown({
            Name = 'Target',
            List = {'Head', 'Root', 'All'},
            Function = Restart
        })

        Color = HitboxExpander:CreateColorPicker({
            Name = "Color",
            Default = Color3.fromRGB(163, 162, 165),
            Function = function(Color, Transparency)
                for Part in Parts do
                    db[Part] = true
                    Part.Color = Color
                    Part.Transparency = Transparency
                end
                table.clear(db)
            end
        })

        Collision = HitboxExpander:CreateToggle({
            Name = 'Collision',
            Info = 'Toggles the collision of modified parts',
            Function = function(Enabled)
                for Part in Parts do
                    db[Part] = true
                    Part.CanCollide = Enabled
                end
                table.clear(db)
            end
        })
    end)

    Run(function() -- KillAura
        local KillAura, UsePlayers, UseNPCs, WallCheck, MaxTargets, CPS, SwingRange, AttackRange, AngleSlider, RequireMouseDown, Lunge
        local BoxSwingColor, BoxAttackColor, ParticleTexture, ParticleSize, ParticleColor1, ParticleColor2, Face
        local AnimationEnabled, Animation, AnimationSpeed, ReverseAnimation, UpdateRate

        local OldC0, Tween, StopTween, Attacking

        local Particles = {}
        local Boxes = {}
        local AttackDelay = os.clock()
        local Bounds = vector.create(4, 4, 4)
        local Tool, TouchInterest

        local Params = OverlapParams.new()
        Params.FilterType = Enum.RaycastFilterType.Include

        local function MouseCheck()
            if RequireMouseDown.Enabled and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                return false
            end

            return true
        end

        local function LocalAdded()
            Tool = EntityLib.Character:FindFirstChildWhichIsA('Tool', true)
            TouchInterest = Tool and Tool:FindFirstChildWhichIsA('TouchTransmitter', true) or nil

            KillAura:Clean(EntityLib.Character.DescendantAdded:Connect(function(Child)
                if Child:IsA('Tool') then
                    Tool = Child
                    TouchInterest = Tool:FindFirstChildWhichIsA('TouchTransmitter', true)
                end
            end))

            KillAura:Clean(EntityLib.Character.DescendantRemoving:Connect(function(Child)
                if Child == Tool then
                    Tool = nil
                    TouchInterest = nil
                end
            end))
        end

        local function LocalRemoved()
            KillAura:CleanUp()
            Tool = nil
            TouchInterest = nil
        end
        
        KillAura = Combat:CreateModule({
            Name = 'KillAura',
            Info = 'Automatically attacks players around you',
            Function = function(Enabled)
                if Enabled then
                    if EntityLib.Alive then
                        LocalAdded()
                    end

                    KillAura:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    KillAura:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))

                    if AnimationEnabled.Enabled then
                        KillAura:Clean(task.spawn(function()
                            local First = true

                            while KillAura.Enabled do
                                if not OldC0 and ViewmodelMotor then
                                    OldC0 = ViewmodelMotor.C0
                                end

                                if ViewmodelMotor and OldC0 then
                                    if Attacking then
                                        if StopTween then
                                            StopTween:Cancel()
                                            StopTween = nil
                                        end

                                        for i, Keyframe in AuraAnimations[Animation.Value] do
                                            local cf = ReverseAnimation.Enabled and Keyframe.CFrame:Inverse() or Keyframe.CFrame
                                            Tween = TweenService:Create(ViewmodelMotor, TweenInfo.new(First and 0.1 or Keyframe.Duration / AnimationSpeed.Value, Enum.EasingStyle.Linear), {C0 = OldC0 * cf})
                                            First = nil
                                            Tween:Play()
                                            Tween.Completed:Wait()
                                            if not (Attacking and ViewmodelMotor) then break end
                                        end
                                    elseif Tween and not Attacking then
                                        First = true
                                        Tween:Cancel()
                                        Tween = nil

                                        StopTween = TweenService:Create(ViewmodelMotor, TweenInfo.new(0.3 / AnimationSpeed.Value, Enum.EasingStyle.Exponential), {C0 = OldC0})
                                        StopTween:Play()
                                        StopTween.Completed:Once(function(State)
                                            if State == Enum.PlaybackState.Completed then
                                                StopTween = nil
                                            end
                                        end)
                                    end
                                end

                                task.wait(1 / UpdateRate.Value)
                            end
                        end))
                    end

                    while KillAura.Enabled do
                        local Attacked = {}
                        if Tool and TouchInterest and MouseCheck() then
                            local Entities = EntityLib:GetClosestEntities({
                                Range = SwingRange.Value,
                                WallCheck = WallCheck.Enabled,
                                Part = 'Root',
                                Players = UsePlayers.Enabled,
                                NPCs = UseNPCs.Enabled,
                                Limit = MaxTargets.Value
                            })
        
                            if #Entities > 0 then
                                local LookVector = EntityLib.Root.CFrame.LookVector * vector.hort
                                local MaxAngle = math.rad(AngleSlider.Value) / 2
        
                                for _, Ent in Entities do
                                    local Direction = (Ent.Root.Position - EntityLib.Root.Position)
                                    local Unit = vector.normalize(Direction * vector.hort)
                                    local Dot = vector.dot(LookVector, Unit)
                                    local Angle = math.acos(Dot)
                                    if Angle > MaxAngle then continue end

                                    local PastAttackRange = vector.magnitude(Direction) > AttackRange.Value
        
                                    table.insert(Attacked, {
                                        Entity = Ent,
                                        Color = PastAttackRange and BoxSwingColor.Color or BoxAttackColor.Color,
                                        Transparency = PastAttackRange and BoxSwingColor.Transparency or BoxAttackColor.Transparency
                                    })
        
                                    if AttackDelay < os.clock() then
                                        AttackDelay = os.clock() + (1 / CPS.Value)
                                        Tool:Activate()
                                    end
        
                                    if Lunge.Enabled and Tool.GripUp.X == 0 then break end
                                    if PastAttackRange then continue end
                                    
                                    Attacking = true

                                    if firetouchinterest then
                                        Params.FilterDescendantsInstances = {Ent.Character}
                                        for _, Part in workspace:GetPartBoundsInBox(Ent.Root.CFrame, Bounds, Params) do
                                            firetouchinterest(TouchInterest.Parent, Part, true)
                                            firetouchinterest(TouchInterest.Parent, Part, false)
                                        end
                                    end
                                end
                            else
                                Attacking = false
                            end
                        end
        
                        for i, Box in Boxes do
                            local Tab = Attacked[i]
                            Box.Adornee = Tab and Tab.Entity.Root or nil
                            if Tab then
                                Box.Color3 = Tab.Color
                                Box.Transparency = Tab.Transparency
                            end
                        end
        
                        for i, Particle in Particles do
                            local Tab = Attacked[i]
                            Particle.Position = Tab and Tab.Entity.Root.Position or vector.huge
                            Particle.Parent = Tab and Camera or nil
                        end
        
                        if Face.Enabled and Attacked[1] then
                            local TargetPosition = Attacked[1].Character.Root.Position
                            local ModdedPosition = vector.create(TargetPosition.X, EntityLib.Root.Position.Y, TargetPosition.Z)
                            EntityLib.Root.CFrame = CFrame.lookAt(EntityLib.Root.Position, ModdedPosition)
                        end
        
                        task.wait()
                    end
                else
                    if Tween then
                        Tween:Cancel()
                        Tween = nil
                    end
                    if StopTween then
                        StopTween:Cancel()
                        StopTween = nil
                    end
                    if ViewmodelMotor and OldC0 then
                        ViewmodelMotor.C0 = OldC0
                    end
                    OldC0 = nil
                    Tool = nil
                    TouchInterest = nil
                    Attacking = nil
                end
            end,
        })

        UsePlayers = KillAura:CreateToggle({
            Name = 'Players',
            Default = true
        })

        UseNPCs = KillAura:CreateToggle({
            Name = 'NPCs',
        })

        WallCheck = KillAura:CreateToggle({
            Name = 'Wall Check',
        })

        CPS = KillAura:CreateSlider({
            Name = 'Attacks Per Second',
            Default = 10,
            Min = 1,
            Max = 20
        })

        SwingRange = KillAura:CreateSlider({
            Name = 'Swing Range',
            Min = 1,
            Max = 30,
            Default = 13
        })

        AttackRange = KillAura:CreateSlider({
            Name = 'Attack Range',
            Min = 1,
            Max = 30,
            Default = 13
        })

        AngleSlider = KillAura:CreateSlider({
            Name = 'Max Angle',
            Min = 1,
            Max = 360,
            Default = 90
        })

        MaxTargets = KillAura:CreateSlider({
            Name = 'Max Targets',
            Min = 1,
            Max = 10,
            Default = 10
        })

        RequireMouseDown = KillAura:CreateToggle({
            Name = 'Require Mouse Down'
        })

        Lunge = KillAura:CreateToggle({
            Name = 'Sword Lunge Only'
        })

        Face = KillAura:CreateToggle({
            Name = 'Face target'
        })
        
        local KillAuraTargets
        local ShowTarget
        ShowTarget = KillAura:CreateToggle({
            Name = 'Show target',
            Function = function(Enabled)
                if Enabled then
                    KillAuraTargets = Instance.new('Folder')
                    KillAuraTargets.Name = 'KillAuraTargets'
                    KillAuraTargets.Parent = TidalWave.Gui

                    for i = 1, 10 do
                        local Box = Instance.new('BoxHandleAdornment')
                        Box.Adornee = nil
                        Box.AlwaysOnTop = true
                        Box.Size = vector.create(3, 5, 3)
                        Box.CFrame = CFrame.new(0, -0.5, 0)
                        Box.ZIndex = 0
                        Box.Parent = KillAuraTargets
                        Boxes[i] = Box
                    end
                else
                    if KillAuraTargets then
                        KillAuraTargets:Destroy()
                        KillAuraTargets = nil
                    end
                    table.clear(Boxes)
                end
            end
        })

        BoxSwingColor = ShowTarget:CreateColorPicker({
            Name = 'Target Color',
            Color = Color3.fromRGB(0, 100, 255),
            Transparency = 0.5
        })
        
        BoxAttackColor = ShowTarget:CreateColorPicker({
            Name = 'Attack Color',
            Color = Color3.fromRGB(255, 0, 0),
            Transparency = 0.5
        })

        local TargetParticles = KillAura:CreateToggle({
            Name = 'Target Particles',
            Function = function(Enabled)
                if Enabled then
                    for i = 1, 10 do
                        local Part = Instance.new('Part')
                        Part.Size = vector.create(2, 4, 2)
                        Part.Anchored = true
                        Part.CanCollide = false
                        Part.CanTouch = false
                        Part.CanQuery = false
                        Part.AudioCanCollide = false
                        Part.Transparency = 1
                        Part.Parent = KillAura.Enabled and Camera or nil

                        local Particle = Instance.new('ParticleEmitter')
                        Particle.Brightness = 1.5
                        Particle.Size = NumberSequence.new(ParticleSize.Value)
                        Particle.Shape = Enum.ParticleEmitterShape.Sphere
                        Particle.Texture = ParticleTexture.Text
                        Particle.Transparency = NumberSequence.new(0)
                        Particle.Lifetime = NumberRange.new(0.4)
                        Particle.Speed = NumberRange.new(16)
                        Particle.Rate = 128
                        Particle.Drag = 16
                        Particle.ShapePartial = 1
                        Particle.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, ParticleColor1.Color),
                            ColorSequenceKeypoint.new(1, ParticleColor2.Color)
                        })

                        Particle.Parent = Part
                        Particles[i] = Part
                    end
                else
                    table.clear(Particles)
                end
            end
        })

        ParticleTexture = TargetParticles:CreateTextBox({
            Name = 'Texture',
            Text = 'rbxassetid://14736249347',
            Function = function(Text)
                for _, v in Particles do
                    v.ParticleEmitter.Texture = Text
                end
            end,
        })

        ParticleColor1 = TargetParticles:CreateColorPicker({
            Name = 'Color Begin',
            Function = function(Color)
                local Sequence = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color),
                    ColorSequenceKeypoint.new(1, Color)
                })

                for _, Particle in Particles do
                    Particle.ParticleEmitter.Color = Sequence
                end
            end,
        })

        ParticleColor2 = TargetParticles:CreateColorPicker({
            Name = 'Color End',
            Function = function(Color)
                local Sequence = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color),
                    ColorSequenceKeypoint.new(1, Color)
                })
                for _, Particle in Particles do
                    Particle.ParticleEmitter.Color = Sequence
                end
            end,
        })
        
        ParticleSize = TargetParticles:CreateSlider({
            Name = 'Size',
            Min = 0,
            Max = 1,
            Default = 0.2,
            Decimal = 100,
            Function = function(Val)
                local Sequence = NumberSequence.new(Val)
                for _, Particle in Particles do
                    Particle.ParticleEmitter.Size = Sequence
                end
            end,
        })

        AnimationEnabled = KillAura:CreateToggle({
            Name = 'Custom Animation',
            Info = 'Requires the Viewmodel Module inside Visuals category for this to work',
            Function = function(Enabled)
                if Enabled and not Modules.Viewmodel.Enabled then
                    Modules.Viewmodel:Toggle(true)
                end
                if KillAura.Enabled then
                    KillAura:Toggle(true)
                    KillAura:Toggle(true)
                end
            end
        })

        local List = {}

        for Name in AuraAnimations do
            table.insert(List, Name)
        end

        Animation = AnimationEnabled:CreateDropdown({
            Name = 'Aura Animation',
            List = List
        })

        AnimationSpeed = AnimationEnabled:CreateSlider({
            Name = 'Animation Speed',
            Default = 1,
            Min = 0,
            Max = 2,
            Decimal = 100
        })

        ReverseAnimation = AnimationEnabled:CreateToggle({
            Name = 'Reverse Animation'
        })

        UpdateRate = AnimationEnabled:CreateSlider({
            Name = 'Update Rate',
            Default = 60,
            Min = 10,
            Max = 240
        })
    end)
end)

Run(function() -- Player
    Run(function() -- Phase
        local Phase, Method, ResetCollision, SignalDisabler, SignalDisablerPart

        local Parts = {}
        local Connections = {}

        local Params = OverlapParams.new()
        Params.MaxParts = 9e9

        local Functions = {
            Character = function()
                if not EntityLib.Alive then return end
                for _, Part in EntityLib.Character:QueryDescendants("BasePart[CanCollide = true]") do
                    Part.CanCollide = false
                end
            end,
            Part = function()
                if not EntityLib.Alive then return end
                local Characters = {EntityLib.Character}
                local Index = 1
                for _, v in EntityLib.List do
                    Index += 1
                    Characters[Index] = v.Character
                end
                Params.FilterDescendantsInstances = Characters
                local TouchingParts = workspace:GetPartBoundsInBox(EntityLib.Root.CFrame, vector.create(7, EntityLib.HipHeight, 7), Params)
                for Part in Parts do
                    if not table.find(TouchingParts, Part) then
                        Part.CanCollide = true
                        Parts[Part] = nil
                    end
                end
                for _, Part in TouchingParts do
                    if Part.CanCollide then
                        Parts[Part] = true
                        Part.CanCollide = false
                    end
                end
            end
        }

        local function DisableConnections(Part)
            for _, Connection in getconnections(Part:GetPropertyChangedSignal('CanCollide')) do
                Connection:Disable()
                table.insert(Connections, Connection)
            end
        end

        local function LocalAdded()
            table.clear(Connections)
            if SignalDisablerPart.Value == 'All' then
                Phase:Clean(EntityLib.Character.DescendantAdded:Connect(function(Child)
                    if Child:IsA('BasePart') then
                        task.wait()
                        DisableConnections(Child)
                    end
                end))
                for _, Part in EntityLib.Character:QueryDescendants('BasePart') do
                    DisableConnections(Part)
                end
            elseif SignalDisablerPart.Value == 'Torso' then
                if EntityLib.UpperTorso then
                    DisableConnections(EntityLib.UpperTorso)
                end
                if EntityLib.LowerTorso then
                    DisableConnections(EntityLib.LowerTorso)
                end
                if EntityLib.Torso then
                    DisableConnections(EntityLib.Torso)
                end
            else
                local Part = EntityLib[SignalDisablerPart.Value]
                DisableConnections(Part)
            end
        end

        Phase = PlayerCategory:CreateModule({
            Name = 'Phase',
            Info = 'Allows you to phase through walls',
            Function = function(Enabled)
                if Enabled then
                    Phase:Clean(RunService.PreSimulation:Connect(Functions[Method.Value]))
                    if SignalDisabler.Enabled then
                        if EntityLib.Alive then
                            task.spawn(LocalAdded)
                        end

                        Phase:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                        Phase:Clean(EntityLib.Events.LocalRemoved:Connect(function()
                            table.clear(Connections)
                        end))
                    end
                else
                    if Method.Value == 'Character' and ResetCollision.Enabled and EntityLib.Alive then
                        EntityLib.Root.CanCollide = true
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

        local function Restart()
            if Phase.Enabled then
                Phase:Toggle(true)
                Phase:Toggle(true)
            end
        end

        Method = Phase:CreateDropdown({
            Name = 'Method',
            List = {'Character', 'Part'},
            Info = 'Character - Disables the collision of your character.\nPart - Disables the collision of parts around you',
            Function = function(Val)
                SignalDisabler:SetVisible(Val == 'Character')
                ResetCollision:SetVisible(Val == 'Character')
                if Val == 'Character' then
                    for _, Connection in Connections do
                        Connection:Enable()
                    end
                    for Part in Parts do
                        Part.CanCollide = true
                    end
                    table.clear(Connections)
                    table.clear(Parts)
                elseif ResetCollision.Enabled and EntityLib.Alive then
                    EntityLib.Root.CanCollide = true
                end
            end
        })

        ResetCollision = Phase:CreateToggle({
            Name = "Reset Collision",
            Info = 'Re-enables collision when disabling Phase',
            Default = true
        })

        SignalDisabler = Phase:CreateToggle({
            Name = 'Signal Disabler',
            Info = 'Disables signals that can detect collision changes',
            Function = function(Enabled)
                if Enabled and not getconnections then
                    SignalDisabler:Toggle()
                    Notify({
                        Text = 'Your executor doesn\'t support \'getconnections\' this feature will not work',
                        Duration = 10,
                        Type = 'Error'
                    })
                    
                    return
                end

                Restart()
            end
        })

        SignalDisablerPart = SignalDisabler:CreateDropdown({
            Name = "Part",
            List = {'Head', 'Root', 'Torso', 'All'},
            Function = Restart
        })
    end)

    Run(function() -- Fling
        local Fling, FlingPower, AddMoveVelocity, FlingDirection

        local Directions = {
            Up = vector.create(0, 1, 0),
            Down = vector.create(0, 1, 0),
            None = vector.zero
        }

        Fling = PlayerCategory:CreateModule({
            Name = "Fling",
            Info = "Flings players when you touch them",
            Enabled = function()
                if Modules.Phase and not Modules.Phase.Enabled then
                    Modules.Phase:Toggle(true)
                end
                Fling:Clean(RunService.PostSimulation:Connect(function()
                    if not EntityLib.Alive then return end
                    local Vel = EntityLib.Root.AssemblyLinearVelocity
                    local NewVel = Directions[FlingDirection.Value] + (AddMoveVelocity.Enabled and Vel ~= vector.zero and vector.normalize(Vel) or vector.zero)
                    EntityLib.Root.AssemblyLinearVelocity = NewVel * FlingPower.Value
                    RunService.PreRender:Wait()
                    if not EntityLib.Alive then return end
                    EntityLib.Root.AssemblyLinearVelocity = Vel
                end))
            end
        })

        FlingPower = Fling:CreateSlider({
            Name = 'Fling Power',
            Default = 10000,
            Min = 1,
            Max = 10000,
        })

        AddMoveVelocity = Fling:CreateToggle({
            Name = 'Add Move Velocity',
            Info = 'Adds the velocity from you moving to the fling velocity'
        })

        FlingDirection = Fling:CreateDropdown({
            Name = 'Fling Direction',
            List = {'Up', 'Down', 'None'},
        })
    end)

    Run(function() -- AntiRagdoll
        local AntiRagdoll

        local OldFallingDown

        local function OnCharacterAdded()
            local db
            AntiRagdoll:Clean(EntityLib.Humanoid.StateEnabledChanged:Connect(function(State, Enabled)
                if db then return end
                db = true
                if State == Enum.HumanoidStateType.FallingDown then
                    OldFallingDown = Enabled
                    if Enabled then
                        EntityLib.Humanoid:SetStateEnabled(State, false)
                    end
                end
                db = nil
            end))
            local Enabled = EntityLib.Humanoid:GetStateEnabled(Enum.HumanoidStateType.FallingDown)
            OldFallingDown = Enabled
            EntityLib.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end

        AntiRagdoll = PlayerCategory:CreateModule({
            Name = "AntiRagdoll",
            Info = "Prevents your character from falling over",
            Function = function(Enabled)
                if Enabled then
                    AntiRagdoll:Clean(EntityLib.Events.LocalAdded:Connect(OnCharacterAdded))
                    if EntityLib.Alive then
                        OnCharacterAdded()
                        local State = EntityLib.Humanoid:GetState()
                        if State == Enum.HumanoidStateType.FallingDown then
                            EntityLib.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                        end
                    end
                else
                    if EntityLib.Alive then
                        EntityLib.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, OldFallingDown)
                    end
                end
            end
        })
    end)

    Run(function() -- JumpPower
        local JumpPower, Value
        local db, db2, OldJumpPower, OldUseJumpPower

        local function LocalAdded()
            OldJumpPower, OldUseJumpPower = EntityLib.Humanoid.JumpPower, EntityLib.Humanoid.UseJumpPower
            EntityLib.Humanoid.JumpPower = Value.Value
            EntityLib.Humanoid.UseJumpPower = true
            JumpPower:Clean(EntityLib.Humanoid:GetPropertyChangedSignal('JumpPower'):Connect(function()
                if db then return end
                db = true
                OldJumpPower = EntityLib.Humanoid.JumpPower
                EntityLib.Humanoid.JumpPower = Value.Value
                db = nil
            end))
            JumpPower:Clean(EntityLib.Humanoid:GetPropertyChangedSignal('UseJumpPower'):Connect(function()
                if db2 then return end
                db2 = true
                OldUseJumpPower = EntityLib.Humanoid.UseJumpPower
                EntityLib.Humanoid.UseJumpPower = true
                db2 = nil
            end))
        end

        JumpPower = PlayerCategory:CreateModule({
            Name = 'JumpPower',
            Info = 'Sets the jump power of your humanoid',
            Function = function(Enabled)
                if Enabled then
                    if EntityLib.Alive then
                        LocalAdded()
                    end
                    
                    JumpPower:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                else
                    if EntityLib.Alive then
                        if OldJumpPower then
                            EntityLib.Humanoid.JumpPower = OldJumpPower
                        end
                        if OldUseJumpPower then
                            EntityLib.Humanoid.UseJumpPower = OldUseJumpPower
                        end
                    end
                end
            end
        })

        Value = JumpPower:CreateSlider({
            Name = 'Jump Power',
            Default = 50,
            Min = 0,
            Max = 500,
            Function = function()
                if JumpPower.Enabled and EntityLib.Alive then
                    db, db2 = true, true
                    EntityLib.Humanoid.JumpPower = Value.Value
                    EntityLib.Humanoid.UseJumpPower = true
                    db, db2 = nil, nil
                end
            end
        })
    end)

    Run(function() -- HipHeight
        local HipHeight, Value
        local Old, db

        local function LocalAdded()
            Old = EntityLib.Humanoid.HipHeight
            EntityLib.Humanoid.HipHeight = Value.Value
            EntityLib.HipHeight = Value.Value + (EntityLib.Root.Size.Y / 2) + (EntityLib.Humanoid.RigType == Enum.HumanoidRigType.R6 and 2 or 0)
            HipHeight:Clean(EntityLib.Humanoid:GetPropertyChangedSignal("HipHeight"):Connect(function()
                if db then return end
                db = true
                Old = EntityLib.Humanoid.HipHeight
                EntityLib.Humanoid.HipHeight = Value.Value
                EntityLib.HipHeight = Value.Value + (EntityLib.Root.Size.Y / 2) + (EntityLib.Humanoid.RigType == Enum.HumanoidRigType.R6 and 2 or 0)
                db = nil
            end))
        end

        HipHeight = PlayerCategory:CreateModule({
            Name = "HipHeight",
            Info = "Sets the hip height of your humanoid",
            Function = function(Enabled)
                if Enabled then
                    HipHeight:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    if EntityLib.Alive then
                        LocalAdded()
                    end
                else
                    if EntityLib.Alive then
                        EntityLib.Humanoid.HipHeight = Old
                        EntityLib.HipHeight = Old
                    end
                    Old, db = nil, nil
                end
            end
        })

        Value = HipHeight:CreateSlider({
            Name = "Hip Height",
            Default = EntityLib.Alive and math.floor(EntityLib.Humanoid.HipHeight * 100) / 100 or 2,
            Min = 0,
            Max = 10,
            Decimal = 100,
            Function = function(Val)
                if HipHeight.Enabled and EntityLib.Alive then
                    db = true
                    EntityLib.Humanoid.HipHeight = Val
                    db = nil
                end
            end
        })
    end)

    Run(function() -- MaxSlopeAngle
        local MaxSlopeAngle, Value
        local Old, db

        local function LocalAdded()
            Old = EntityLib.Humanoid.MaxSlopeAngle
            EntityLib.Humanoid.MaxSlopeAngle = Value.Value
            MaxSlopeAngle:Clean(EntityLib.Humanoid:GetPropertyChangedSignal("MaxSlopeAngle"):Connect(function()
                if db then return end
                db = true
                Old = EntityLib.Humanoid.MaxSlopeAngle
                EntityLib.Humanoid.MaxSlopeAngle = Value.Value
                db = nil
            end))
        end

        MaxSlopeAngle = PlayerCategory:CreateModule({
            Name = "MaxSlopeAngle",
            Info = "Sets the max angle you can climb up slopes",
            Function = function(Enabled)
                if Enabled then
                    if EntityLib.Alive then
                        LocalAdded()
                    end
                    MaxSlopeAngle:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                else
                    if EntityLib.Alive then
                        EntityLib.Humanoid.MaxSlopeAngle = Old
                    end
                    Old, db = nil, nil
                end
            end
        })

        Value = MaxSlopeAngle:CreateSlider({
            Name = "Angle",
            Default = 90,
            Min = 0,
            Max = 90,
            Decimal = 10,
            Function = function(Val)
                if MaxSlopeAngle.Enabled and EntityLib.Alive then
                    db = true
                    EntityLib.Humanoid.MaxSlopeAngle = Val
                    db = nil
                end
            end
        })
    end)

    Run(function() -- DropTools
        PlayerCategory:CreateButton({
            Name = "Drop Tools",
            Info = "Drops all the tools in your backpack\nMay lag depending on how many tools you have",
            Function = function()
                local Backpack = Plr:FindFirstChildOfClass("Backpack")
                if not (Backpack and EntityLib.Alive) then return end
                for _, v in Backpack:GetChildren() do
                    if v.ClassName == "Tool" then
                        v.Parent = EntityLib.Character
                    end
                end
                task.wait(0.2)
                if not EntityLib.Alive then return end
                for _, v in EntityLib.Character:GetChildren() do
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
        local Speed, Value, Method, UsePercentage, Percentage, UseLimits, MinSpeed, MaxSpeed, AutoJump, CustomJump, CustomJumpPower, IgnoreCars
        local Shift, ShiftSpeed, ShiftUsePercentage, ShiftPercentage, UseShiftLimits, MinShiftSpeed, MaxShiftSpeed, ShiftKeybind
        local OldWalkSpeed, WalkSpeedCon, db

        local ShiftPressed = false

        local function GetMoveDirection()
            local CalculatedSpeed
            if Shift.Enabled and ShiftPressed then
                CalculatedSpeed = ShiftUsePercentage.Enabled and EntityLib.Humanoid.WalkSpeed * (ShiftPercentage.Value / 100) or ShiftSpeed.Value
                if ShiftUsePercentage.Enabled and UseShiftLimits.Enabled then
                    CalculatedSpeed = math.clamp(CalculatedSpeed, MinShiftSpeed.Value, MaxShiftSpeed.Value)
                end
            else
                CalculatedSpeed = UsePercentage.Enabled and EntityLib.Humanoid.WalkSpeed * (Percentage.Value / 100) or Value.Value
                if UsePercentage.Enabled and UseLimits.Enabled then
                    CalculatedSpeed = math.clamp(CalculatedSpeed, MinSpeed.Value, MaxSpeed.Value)
                end
            end

            return (TargetStrafeVector or EntityLib.Humanoid.MoveDirection) * CalculatedSpeed
        end

        local function GetWalkSpeed()
            local CalculatedSpeed = UsePercentage.Enabled and OldWalkSpeed * (Percentage.Value / 100) or Value.Value
            if UsePercentage.Enabled and UseLimits.Enabled then
                CalculatedSpeed = math.clamp(CalculatedSpeed, MinSpeed.Value, MaxSpeed.Value)
            end
            return CalculatedSpeed
        end

        local function UpdateWalkSpeed()
            if Speed.Enabled and Method.Value == 'WalkSpeed' and EntityLib.Alive then
                db = true
                EntityLib.Humanoid.WalkSpeed = GetWalkSpeed()
                db = nil
            end
        end
        
        local Methods = {
            LinearVelocity = {
                Init = function()
                    local Attachment = Speed:CreateInstance('Attachment', 'Attachment', {
                        Name = 'RootAttachment',
                        Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position,
                        Parent = EntityLib.Root
                    })
                    Speed:CreateInstance('LinearVelocity', 'LinearVelocity', {
                        ForceLimitMode = Enum.ForceLimitMode.PerAxis,
                        MaxAxesForce = vector.hugeXZ,
                        Attachment0 = Attachment,
                        VectorVelocity = GetMoveDirection(),
                        Parent = workspace
                    })
                end,
                Function = function()
                    local ExistingLinearVelocity, ExistingAttachment = Speed:GetInstance('LinearVelocity'), Speed:GetInstance('Attachment')
                    if ExistingLinearVelocity and ExistingAttachment then
                        ExistingAttachment.Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position
                        ExistingLinearVelocity.VectorVelocity = GetMoveDirection()
                    end
                end,
                Disable = function()
                    local LinearVelocity = Speed:GetInstance('LinearVelocity')
                    if LinearVelocity then
                        LinearVelocity.Enabled = false
                        LinearVelocity.VectorVelocity = vector.zero
                    end
                end,
                Enable = function()
                    local LinearVelocity = Speed:GetInstance('LinearVelocity')
                    if LinearVelocity then
                        LinearVelocity.Enabled = true
                    end
                end,
            },
            Velocity = {
                Function = function()
                    local MoveDirection = GetMoveDirection()
                    local Vel = vector.create(MoveDirection.X, EntityLib.Root.AssemblyLinearVelocity.Y, MoveDirection.Z)
                    EntityLib.Root.AssemblyLinearVelocity = Vel
                end,
            },
            CFrame = {
                Function = function(Delta)
                    local MoveDirection = GetMoveDirection()
                    local CurrentMoveDirection = (EntityLib.Humanoid.MoveDirection * EntityLib.Humanoid.WalkSpeed)
                    
                    EntityLib.Character:TranslateBy((MoveDirection - CurrentMoveDirection) * Delta)
                end,
            },
        }

        local function LocalRemoved()
            if WalkSpeedCon then
                WalkSpeedCon:Disconnect()
                WalkSpeedCon = nil
            end
            Speed:CleanUp()
            Speed:ClearInstances()
            FrictionTable.Speed = nil
            UpdateFriction()
        end

        local function LocalAdded()
            LocalRemoved()
            FrictionTable.Speed = Method.Value == 'Velocity' or nil
            UpdateFriction()
            if Method.Value == 'WalkSpeed' then
                OldWalkSpeed = EntityLib.Humanoid.WalkSpeed
                EntityLib.Humanoid.WalkSpeed = GetWalkSpeed()
                
                WalkSpeedCon = Speed:Clean(EntityLib.Humanoid:GetPropertyChangedSignal('WalkSpeed'):Connect(function()
                    if db then return end
                    db = true
                    OldWalkSpeed = EntityLib.Humanoid.WalkSpeed
                    EntityLib.Humanoid.WalkSpeed = GetWalkSpeed()
                    db = nil
                end))
            else
                local CurrentMethod = Methods[Method.Value]
                if CurrentMethod.Init then
                    CurrentMethod.Init()
                end
            end
        end

        local function DisableCurrentMethod()
            local CurrentMethod = Methods[Method.Value]
            if CurrentMethod.Disable then
                CurrentMethod.Disable()
            end
        end

        local function EnableCurrentMethod()
            local CurrentMethod = Methods[Method.Value]
            if CurrentMethod.Enable then
                CurrentMethod.Enable()
            end
        end

        local Sat = false

        local function SeatCheck()
            if IgnoreCars.Enabled then
                if EntityLib.Humanoid.SeatPart then
                    if not Sat then
                        Sat = true
                        DisableCurrentMethod()

                        return true
                    end
                elseif Sat then
                    Sat = false
                    EnableCurrentMethod()
                end
            end

            return false
        end

        local Climbed = false

        local function ClimbingCheck()
            local State = EntityLib.Humanoid:GetState()
            if State == Enum.HumanoidStateType.Climbing then
                if not Climbed then
                    Climbed = true
                    DisableCurrentMethod()
                end

                return true
            elseif Climbed then
                Climbed = false
                EnableCurrentMethod()
            end

            return false
        end

        Speed = Movement:CreateModule({
            Name = 'Speed',
            Info = 'Increases your speed using various methods',
            Function = function(Enabled)
                if Enabled then
                    if EntityLib.Alive then
                        LocalAdded()
                    end
                    Speed:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    Speed:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))

                    ShiftPressed = ShiftKeybind:IsPressed()

                    for i = 1, 0, -1 do
                        local Signal = i == 1 and UIS.InputBegan or UIS.InputEnded
                        Speed:Clean(Signal:Connect(function(Input)
                            if i == 1 and UIS:GetFocusedTextBox() then return end
                            if ShiftKeybind:Check(Input) then
                                ShiftPressed = i == 1
                            end
                        end))
                    end

                    Climbed = false
                    Sat = false
                    
                    if Method.Value ~= 'WalkSpeed' then
                        Speed:Clean(RunService.PreSimulation:Connect(function(Delta)
                            if not EntityLib.Alive or (Modules.Fly and Modules.Fly.Enabled) or (Modules.LongJump and Modules.LongJump.Enabled) then return end
                            if SeatCheck() then return end
                            if ClimbingCheck() then return end
                            
                            Methods[Method.Value].Function(Delta)

                            if AutoJump.Enabled and EntityLib.Humanoid.MoveDirection ~= vector.zero and EntityLib.Humanoid.FloorMaterial ~= Enum.Material.Air then
                                if CustomJump.Enabled then
                                    local Vel = EntityLib.Root.AssemblyLinearVelocity
                                    Vel = vector.create(Vel.X, CustomJumpPower.Value, Vel.Z)
                                    EntityLib.Root.AssemblyLinearVelocity = Vel
                                else
                                    EntityLib.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                end
                            end
                        end))
                    end
                else
                    FrictionTable.Speed = nil
                    UpdateFriction()
                    if Method.Value == 'WalkSpeed' and OldWalkSpeed and EntityLib.Alive then
                        EntityLib.Humanoid.WalkSpeed = OldWalkSpeed
                    end
                    OldWalkSpeed = nil
                end
            end,
            ExtraText = function()
                return Method.Value
            end,
        })

        function Speed:DisableMovers()
            local CurrentMethod = Methods[Method.Value]
            if CurrentMethod.Disable then
                CurrentMethod.Disable()
            end
        end

        function Speed:EnableMovers()
            local CurrentMethod = Methods[Method.Value]
            if CurrentMethod.Enable then
                CurrentMethod.Enable()
            end
        end

        Value = Speed:CreateSlider({
            Name = "Speed",
            Default = 16,
            Min = 0,
            Max = 200,
            Function = UpdateWalkSpeed
        })

        Method = Speed:CreateDropdown({
            Name = 'Method',
            List = {'LinearVelocity', 'Velocity', 'CFrame', 'WalkSpeed'},
            Info = 'LinearVelocity - Adjusts the velocity of your character using a LinearVelocity object\nVelocity - Directly adjusts the velocity your character\nCFrame - Directly adjusts the position of your character',
            Function = function(Val)
                if Speed.Enabled then
                    if Val ~= 'WalkSpeed' and OldWalkSpeed then
                        if EntityLib.Alive then
                            LocalRemoved()
                            EntityLib.Humanoid.WalkSpeed = OldWalkSpeed
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
            Info = "Uses speed based off a percentage of your humanoid's walk speed",
            Function = UpdateWalkSpeed,
        })

        Percentage = UsePercentage:CreateSlider({
            Name = "Percentage",
            Min = 0,
            Default = 110,
            Max = 200,
            Suffix = "%",
            Function = UpdateWalkSpeed
        })

        UseLimits = UsePercentage:CreateToggle({
            Name = 'Use Limits',
            Info = 'Limits the speed calculated by Speed Percentage between the minimum and maximum values',
            Function = UpdateWalkSpeed,
        })

        MinSpeed = UseLimits:CreateSlider({
            Name = "Min Speed",
            Default = 0,
            Min = 0,
            Max = 32,
            Function = UpdateWalkSpeed
        })

        MaxSpeed = UseLimits:CreateSlider({
            Name = 'Max Speed',
            Default = 32,
            Min = 0,
            Max = 64,
            Function = UpdateWalkSpeed
        })

        AutoJump = Speed:CreateToggle({
            Name = 'Auto Jump',
            Info = 'Automatically jumps when moving',
        })

        CustomJump = AutoJump:CreateToggle({
            Name = 'Custom Jump',
            Info = 'Allows you to have a custom jump',
        })

        CustomJumpPower = CustomJump:CreateSlider({
            Name = 'Jump Power',
            Default = 30,
            Min = 1,
            Max = 75,
        })

        Shift = Speed:CreateToggle({
            Name = 'Shift',
            Info = 'Allows you to toggle a faster speed when holding your keybind',
        })

        ShiftSpeed = Shift:CreateSlider({
            Name = 'Shift Speed',
            Default = 32,
            Min = 16,
            Max = 200,
        })

        ShiftUsePercentage = Shift:CreateToggle({
            Name = 'Shift Use Percentage',
        })

        ShiftPercentage = ShiftUsePercentage:CreateSlider({
            Name = 'Shift Percentage',
            Default = 120,
            Min = 0,
            Max = 300,
            Suffix = '%',
        })

        UseShiftLimits = ShiftUsePercentage:CreateToggle({
            Name = 'Use Shift Limits',
            Info = 'Limits the speed calculated by Speed Percentage between the minimum and maximum values',
            Function = UpdateWalkSpeed,
        })

        MinShiftSpeed = UseShiftLimits:CreateSlider({
            Name = "Min Shift Speed",
            Default = 0,
            Min = 0,
            Max = 32,
            Function = UpdateWalkSpeed
        })

        MaxShiftSpeed = UseShiftLimits:CreateSlider({
            Name = 'Max Shift Speed',
            Default = 32,
            Min = 0,
            Max = 64,
            Function = UpdateWalkSpeed
        })

        ShiftKeybind = Shift:CreateKeybind({
            Name = 'Shift',
            Keybind = 'LeftShift',
        })

        IgnoreCars = Speed:CreateToggle({
            Name = 'Ignore Cars',
            Info = 'Disables speed while inside a car',
            Default = true,
            Function = function(Enabled)
                if Speed.Enabled and not Enabled and Sat then
                    Sat = false
                    EnableCurrentMethod()
                end
            end
        })
    end)

    Run(function() -- TargetStrafe
        local TargetStrafe, SearchRange, StrafeRange, YFactor, UsePlayers, UseNPCs, WallCheck

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true

        const AirCheckVector = vector.create(0, -70, 0)

        local Module, Old, Fly, Angle, LastEntity

        local MoveFunction = function(self, MoveDirection, Face)
            local Entity = not UIS:IsKeyDown(Enum.KeyCode.S) and EntityLib:GetClosestEntity({
                Range = SearchRange.Value,
                WallCheck = WallCheck.Enabled,
                Players = UsePlayers.Enabled,
                NPCs = UseNPCs.Enabled,
                Part = 'Root'
            }) or nil

            if Entity then
                local RootPos = Entity.Root.Position
                Params.FilterDescendantsInstances = {EntityLib.Character, Entity.Character}
                Params.CollisionGroup = EntityLib.Root.CollisionGroup

                if Fly.Enabled or workspace:Raycast(RootPos, AirCheckVector, Params) then
                    local LocalPos = EntityLib.Root.Position
                    local Factor = 0
                    if Entity ~= LastEntity then
                        local _, Y = CFrame.lookAt(RootPos, EntityLib.Root.Position):ToOrientation()
                        Angle = math.deg(Y)
                    end

                    local yFactor = math.abs(LocalPos.Y - RootPos.Y) * (YFactor.Value / 100)
                    local CharPos = vector.create(RootPos.X, LocalPos.Y, RootPos.Z)
                    local LookVector = CFrame.Angles(0, math.rad(Angle), 0).LookVector
                    local NewPos = CharPos + (LookVector * (StrafeRange.Value - yFactor))
                    local Origin = CharPos
                    local Target = NewPos

                    if not WallCheck.Enabled and workspace:Raycast(RootPos, (LocalPos - RootPos), Params) then
                        Origin = CharPos + (LookVector * vector.magnitude(CharPos - LocalPos))
                        Target = CharPos
                    end
                    
                    local Magnitude = vector.magnitude(LocalPos - NewPos)
                    if Magnitude < 3 then
                        Factor = (8 - math.min(Magnitude, 3))
                    else
                        local Blockcast = workspace:Blockcast(CFrame.new(Origin), vector.create(1, EntityLib.HipHeight + (EntityLib.Root.Size.Y / 2), 1), (Target - Origin), Params)
                        if Blockcast then
                            NewPos = Blockcast.Position + (Blockcast.Normal * 1.5)
                            Factor = Magnitude > 3 and 0 or (8 - math.min(Magnitude, 3))
                        end
                    end

                    local Raycast = workspace:Raycast(NewPos, AirCheckVector, Params)
                    
                    if not Fly.Enabled and not Raycast then
                        NewPos = CharPos
                        Factor = 40
                    end

                    Angle += Factor % 360
                    MoveDirection = (NewPos - LocalPos) * vector.hort
                    MoveDirection = MoveDirection ~= vector.zero and vector.normalize(MoveDirection) or vector.zero
                    LastEntity = Entity
                else
                    Entity = nil
                end
            end

            TargetStrafeVector = Entity and MoveDirection or nil
            LastEntity = Entity

            return Old(self, MoveDirection, Face)
        end

        TargetStrafe = Movement:CreateModule({
            Name = 'TargetStrafe',
            Info = 'Automatically strafes around enemies',
            Enabled = function()
                Fly = Modules.Fly or {Enabled = false}

                if require then
                    if not Module then
                        local PlayerScripts = Plr:FindFirstChildOfClass('PlayerScripts')
                        local PlayerModule = PlayerScripts and PlayerScripts:FindFirstChild('PlayerModule')
                        if not PlayerModule then
                            Notify({
                                Text = 'Failed to find player module',
                                Duration = 5,
                                Type = 'Error'
                            })

                            return
                        end
                        
                        Module = require(PlayerModule).controls
                    end

                    Old = Module.moveFunction
                    Module.moveFunction = MoveFunction

                    TargetStrafe:Clean(function()
                        if Module and Old then
                            Module.moveFunction = Old
                        end
                        Old = nil
                        LastEntity = nil
                        TargetStrafeVector = nil
                        Fly = nil
                    end)
                else
                    Old = Plr.Move

                    TargetStrafe:Clean(RunService.PreRender:Connect(function()
                        if EntityLib.Alive then
                            MoveFunction(Plr, EntityLib.Humanoid.MoveDirection, false)
                        end
                    end))

                    TargetStrafe:Clean(function()
                        Old = nil
                        LastEntity = nil
                        TargetStrafeVector = nil
                        Fly = nil
                    end)
                end
            end,
        })

        UsePlayers = TargetStrafe:CreateToggle({
            Name = 'Use Players',
            Default = true
        })

        UseNPCs = TargetStrafe:CreateToggle({
            Name = 'Use NPCs',
        })

        WallCheck = TargetStrafe:CreateToggle({
            Name = 'Wall Check',
            Info = 'Ignores enemies through walls',
            Default = true
        })

        SearchRange = TargetStrafe:CreateSlider({
            Name = 'Search Range',
            Min = 1,
            Max = 30,
            Default = 15,
        })

        StrafeRange = TargetStrafe:CreateSlider({
            Name = 'Strafe Range',
            Min = 1,
            Max = 20,
            Default = 10,
        })

        YFactor = TargetStrafe:CreateSlider({
            Name = 'Y Factor',
            Min = 0,
            Max = 100,
            Default = 100,
            Suffix = '%'
        })
    end)

    Run(function() -- HighJump
        local HighJump, Method, JumpPower, ResetVel, CustomGravity, JumpingGravity, FallingGravity, AutoDisable, Down

        local CustomVel

        local function StepCFrame(Delta)
            CustomVel -= (CustomGravity.Enabled and (CustomVel > 0 and JumpingGravity.Value or FallingGravity.Value) or workspace.Gravity) * Delta
            EntityLib.Root.AssemblyLinearVelocity = vector.create(EntityLib.Root.AssemblyLinearVelocity.X, 0, EntityLib.Root.AssemblyLinearVelocity.Z)
            EntityLib.Character:TranslateBy(vector.create(0, CustomVel * Delta, 0))
            RunService.PostSimulation:Wait()
            if not EntityLib.Alive then return end
            EntityLib.Root.AssemblyLinearVelocity = vector.create(EntityLib.Root.AssemblyLinearVelocity.X, 0, EntityLib.Root.AssemblyLinearVelocity.Z)
        end

        local function StepLinearVel(Delta)
            CustomVel -= (CustomGravity.Enabled and (CustomVel > 0 and JumpingGravity.Value or FallingGravity.Value) or workspace.Gravity) * Delta
            local ExistingLinearVelocity, ExistingAttachment = HighJump:GetInstance('LinearVelocity'), HighJump:GetInstance('Attachment')
            if ExistingLinearVelocity and ExistingAttachment then
                ExistingLinearVelocity.LineVelocity = CustomVel
                ExistingAttachment.Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position
            end
        end

        local Methods = {
            LinearVelocity = {
                Init = function()
                    CustomVel = JumpPower.Value
                    local Attachment = HighJump:CreateInstance('Attachment', 'Attachment', {
                        Name = 'RootAttachment',
                        Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position,
                        Parent = EntityLib.Root
                    })
                    HighJump:CreateInstance('LinearVelocity', 'LinearVelocity', {
                        VelocityConstraintMode = Enum.VelocityConstraintMode.Line,
                        LineDirection = vector.yAxis,
                        ForceLimitsEnabled = false,
                        LineVelocity = CustomVel,
                        Attachment0 = Attachment,
                        Parent = workspace
                    })
                    local TimeOut = os.clock() + 1
                    repeat
                        if not EntityLib.Alive then return end
                        local Delta = RunService.PreSimulation:Wait()
                        if not EntityLib.Alive then return end
                        StepLinearVel(Delta)
                    until not HighJump.Enabled or not EntityLib.Alive or EntityLib.Humanoid.FloorMaterial == Enum.Material.Air or os.clock() >= TimeOut
                end,
                Function = StepLinearVel
            },
            Velocity = {
                Init = function()
                    EntityLib.Root.AssemblyLinearVelocity = vector.create(EntityLib.Root.AssemblyLinearVelocity.X, JumpPower.Value, EntityLib.Root.AssemblyLinearVelocity.Z)
                    local TimeOut = os.clock() + 1
                    while EntityLib.Alive and EntityLib.Humanoid.FloorMaterial ~= Enum.Material.Air and HighJump.Enabled and os.clock() < TimeOut do
                        RunService.PostSimulation:Wait()
                    end
                end,
                Function = function(Delta)
                    if CustomGravity.Enabled then
                        EntityLib.Root.AssemblyLinearVelocity += vector.create(0, Delta * (workspace.Gravity - (EntityLib.Root.AssemblyLinearVelocity.Y > 0 and JumpingGravity.Value or FallingGravity.Value)), 0)
                    end
                end
            },
            CFrame = {
                Init = function()
                    CustomVel = JumpPower.Value
                    local TimeOut = os.clock() + 1
                    repeat
                        if not EntityLib.Alive then return end
                        local Delta = RunService.PreSimulation:Wait()
                        if not EntityLib.Alive then return end
                        StepCFrame(Delta)
                    until not HighJump.Enabled or not EntityLib.Alive or EntityLib.Humanoid.FloorMaterial == Enum.Material.Air or os.clock() >= TimeOut
                end,
                Function = StepCFrame
            }
        }

        local function Jump()
            if not EntityLib.Alive then return end
            if EntityLib.Humanoid.FloorMaterial ~= Enum.Material.Air then
                Methods[Method.Value].Init()
                if Methods[Method.Value].Function then
                    repeat
                        local Delta = RunService.PreSimulation:Wait()
                        if not EntityLib.Alive then break end
                        Methods[Method.Value].Function(Delta)
                    until not HighJump.Enabled or EntityLib.Humanoid.FloorMaterial ~= Enum.Material.Air
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
            HighJump:Clean(EntityLib.Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
                if EntityLib.Humanoid.FloorMaterial ~= Enum.HumanoidStateType.Air and Down then
                    Jump()
                end
            end))
        end

        HighJump = Movement:CreateModule({
            Name = "HighJump",
            Info = "Makes you jump high",
            Function = function(Enabled)
                if Enabled then
                    if AutoDisable.Enabled then
                        Jump()
                    else
                        Down = false
                        HighJump:Clean(UIS.InputBegan:Connect(function(Input)
                            if Input.KeyCode == Enum.KeyCode.Space and not UIS:GetFocusedTextBox() then
                                Down = true
                                if EntityLib.Humanoid.FloorMaterial ~= Enum.HumanoidStateType.Air then
                                    Jump()
                                end
                            end
                        end))
                        HighJump:Clean(UIS.InputEnded:Connect(function(Input)
                            if Input.KeyCode == Enum.KeyCode.Space then
                                Down = false
                            end
                        end))
                        HighJump:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                        HighJump:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                        if EntityLib.Alive then
                            LocalAdded()
                        end
                    end
                elseif ResetVel.Enabled and EntityLib.Alive and EntityLib.Root.AssemblyLinearVelocity.Y > 0 then
                    EntityLib.Root.AssemblyLinearVelocity = vector.create(EntityLib.Root.AssemblyLinearVelocity.X, 0, EntityLib.Root.AssemblyLinearVelocity.Z)
                end
            end,
            ExtraText = function()
                return Method.Value
            end
        })

        Method = HighJump:CreateDropdown({
            Name = "Method",
            List = {'LinearVelocity', 'Velocity', 'CFrame'},
            Function = function(Val)
                ResetVel:SetVisible(Val ~= 'CFrame')
            end
        })

        JumpPower = HighJump:CreateSlider({
            Name = "Jump Power",
            Default = 75,
            Min = 1,
            Max = 200
        })

        ResetVel = HighJump:CreateToggle({
            Name = 'Reset Vel',
            Info = 'Resets you Y velocity after disabling HighJump',
        })

        CustomGravity = HighJump:CreateToggle({
            Name = 'Custom Gravity',
        })

        JumpingGravity = CustomGravity:CreateSlider({
            Name = 'Jumping Gravity',
            Default = 196.2,
            Min = 0,
            Max = 500,
            Decimal = 10,
        })

        FallingGravity = CustomGravity:CreateSlider({
            Name = 'Falling Gravity',
            Default = 196.2,
            Min = 0,
            Max = 500,
            Decimal = 10,
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
        local LongJump, Method, Speed, CustomJump, CustomJumpPower, CustomJumpMethod, JumpPower, CustomGravity, JumpingGravity, FallingGravity, AutoDisable, Down

        local Methods = {
            LinearVelocity = {
                Init = function()
                    local Attachment = LongJump:CreateInstance('Attachment', 'Attachment', {
                        Name = 'RootAttachment',
                        Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position,
                        Parent = EntityLib.Root
                    })
                    LongJump:CreateInstance('LinearVelocity', 'LinearVelocity', {
                        ForceLimitMode = Enum.ForceLimitMode.PerAxis,
                        MaxAxesForce = vector.hugeXZ,
                        VectorVelocity = EntityLib.Humanoid.MoveDirection * Speed.Value,
                        Attachment0 = Attachment,
                        Parent = workspace
                    })
                end,
                Function = function()
                    local ExistingLinearVelocity, ExistingAttachment = LongJump:GetInstance('LinearVelocity'), LongJump:GetInstance('Attachment')
                    if ExistingLinearVelocity and ExistingAttachment then
                        ExistingAttachment.Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position
                        ExistingLinearVelocity.VectorVelocity = EntityLib.Humanoid.MoveDirection * Speed.Value
                    end
                end,
            },
            Velocity = {
                Function = function()
                    local MoveDirection = EntityLib.Humanoid.MoveDirection
                    EntityLib.Root.AssemblyLinearVelocity = vector.create(MoveDirection.X * Speed.Value, EntityLib.Root.AssemblyLinearVelocity.Y, MoveDirection.Z * Speed.Value)
                end,
            },
            CFrame = {
                Function = function(Delta)
                    local Vel = EntityLib.Humanoid.MoveDirection * (Speed.Value - EntityLib.Humanoid.WalkSpeed)
                    EntityLib.Character:TranslateBy(Vel * Delta)
                end,
            },
        }

        local CustomVel

        local function StepCFrame(Delta)
            CustomVel -= (CustomGravity.Enabled and (CustomVel > 0 and JumpingGravity.Value or FallingGravity.Value) or workspace.Gravity) * Delta
            EntityLib.Root.AssemblyLinearVelocity = vector.create(EntityLib.Root.AssemblyLinearVelocity.X, 0, EntityLib.Root.AssemblyLinearVelocity.Z)
            EntityLib.Character:TranslateBy(vector.create(0, CustomVel * Delta, 0))
            RunService.PostSimulation:Wait()
            if not EntityLib.Alive then return end
            EntityLib.Root.AssemblyLinearVelocity = vector.create(EntityLib.Root.AssemblyLinearVelocity.X, 0, EntityLib.Root.AssemblyLinearVelocity.Z)
        end
        
        local function StepLinearVel(Delta)
            CustomVel -= (CustomGravity.Enabled and (CustomVel > 0 and JumpingGravity.Value or FallingGravity.Value) or workspace.Gravity) * Delta
            local ExistingLinearVelocity, ExistingAttachment = LongJump:GetInstance('VertLinearVelocity'), LongJump:GetInstance('VertAttachment')
            if ExistingLinearVelocity and ExistingAttachment then
                ExistingAttachment.Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position
                ExistingLinearVelocity.LineVelocity = CustomVel
            end
        end

        local CustomJumpMethods = {
            LinearVelocity = {
                Init = function()
                    CustomVel = CustomJumpPower.Enabled and JumpPower.Value or EntityLib.Humanoid.JumpPower
                    local Attachment = LongJump:CreateInstance('Attachment', 'VertAttachment', {
                        Name = 'RootAttachment',
                        Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position,
                        Parent = EntityLib.Root
                    })
                    LongJump:CreateInstance('LinearVelocity', 'VertLinearVelocity', {
                        VelocityConstraintMode = Enum.VelocityConstraintMode.Line,
                        LineDirection = vector.yAxis,
                        ForceLimitsEnabled = false,
                        LineVelocity = CustomVel,
                        Attachment0 = Attachment,
                        Parent = workspace
                    })

                    local TimeOut = os.clock() + 0.1
                    repeat
                        local Delta = RunService.PreSimulation:Wait()
                        if not EntityLib.Alive then break end
                        StepLinearVel(Delta)
                    until not LongJump.Enabled or not EntityLib.Alive or EntityLib.Humanoid.FloorMaterial == Enum.Material.Air or os.clock() >= TimeOut
                end,
                Function = StepLinearVel,
            },
            Velocity = {
                Init = function()
                    EntityLib.Root.AssemblyLinearVelocity = vector.create(EntityLib.Root.AssemblyLinearVelocity.X, JumpPower.Value, EntityLib.Root.AssemblyLinearVelocity.Z)
                    local TimeOut = os.clock() + 0.1
                    repeat
                        RunService.Heartbeat:Wait()
                    until EntityLib.FloorMaterial == Enum.Material.Air or os.clock() >= TimeOut
                end,
                Function = function(Delta)
                    if CustomGravity.Enabled then
                        EntityLib.Root.AssemblyLinearVelocity += vector.create(0, Delta * (workspace.Gravity - (EntityLib.Root.AssemblyLinearVelocity.Y > 0 and JumpingGravity.Value or FallingGravity.Value)), 0)
                    end
                end
            },
            CFrame = {
                Init = function()
                    CustomVel = CustomJumpPower.Enabled and JumpPower.Value or EntityLib.Humanoid.JumpPower
                    local TimeOut = os.clock() + 0.1
                    repeat
                        local Delta = RunService.PreSimulation:Wait()
                        if not EntityLib.Alive then break end
                        StepCFrame(Delta)
                    until not LongJump.Enabled or not EntityLib.Alive or EntityLib.Humanoid.FloorMaterial == Enum.Material.Air or os.clock() >= TimeOut
                end,
                Function = StepCFrame
            }
        }

        local function Jump()
            if EntityLib.Alive and EntityLib.Humanoid.FloorMaterial ~= Enum.Material.Air then
                Modules.Speed:DisableMovers()
                if Methods[Method.Value].Init then
                    Methods[Method.Value].Init()
                end
                FrictionTable.LongJump = Method.Value == 'Velocity' or nil
                UpdateFriction()
                if CustomJump.Enabled then
                    CustomJumpMethods[CustomJumpMethod.Value].Init()
                else
                    EntityLib.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    local TimeOut = os.clock() + 0.1
                    repeat
                        RunService.PostSimulation:Wait()
                    until EntityLib.Humanoid.FloorMaterial == Enum.Material.Air or os.clock() >= TimeOut
                end

                if LongJump.Enabled and EntityLib.Alive then
                    repeat
                        local Delta = RunService.PreSimulation:Wait()
                        if not EntityLib.Alive then break end

                        if CustomJump.Enabled then
                            local CurrentJumpMethod = CustomJumpMethods[CustomJumpMethod.Value]
                            if CurrentJumpMethod.Function then
                                CustomJumpMethods[CustomJumpMethod.Value].Function(Delta)
                            end
                        end
                        Methods[Method.Value].Function(Delta)
                    until not LongJump.Enabled or EntityLib.Humanoid.FloorMaterial ~= Enum.Material.Air
                else
                    FrictionTable.LongJump = nil
                    UpdateFriction()
                end
            end

            Modules.Speed:EnableMovers()

            if LongJump.Enabled and AutoDisable.Enabled then
                LongJump:Toggle(true)
            end
        end

        local function LocalAdded()
            LongJump:CleanUp()
            LongJump:Clean(EntityLib.Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
                if EntityLib.Humanoid.FloorMaterial ~= Enum.Material.Air and Down then
                    Jump()
                end
            end))
        end

        LongJump = Movement:CreateModule({
            Name = "LongJump",
            Info = "Makes your jump very much long",
            Function = function(Enabled)
                if Enabled then
                    if AutoDisable.Enabled then
                        Jump()
                    else
                        LongJump:Clean(UIS.InputBegan:Connect(function(Input)
                            if Input.KeyCode == Enum.KeyCode.Space and not UIS:GetFocusedTextBox() then
                                Down = true
                                if EntityLib.Humanoid.FloorMaterial ~= Enum.Material.Air then
                                    Jump()
                                end
                            end
                        end))
                        LongJump:Clean(UIS.InputEnded:Connect(function(Input)
                            if Input.KeyCode == Enum.KeyCode.Space then 
                                Down = nil
                            end
                        end))
                        if EntityLib.Alive then
                            LocalAdded()
                        end
                        LongJump:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                        LongJump:Clean(EntityLib.Events.LocalRemoved:Connect(function()
                            LongJump:CleanUp()
                        end))
                    end
                else
                    Down = nil
                end
            end,
            ExtraText = function()
                return Method.Value
            end
        })

        Method = LongJump:CreateDropdown({
            Name = "Method",
            List = {'LinearVelocity', 'Velocity', 'CFrame'}
        })

        Speed = LongJump:CreateSlider({
            Name = "Speed",
            Default = 50,
            Min = 1,
            Max = 500
        })

        CustomJump = LongJump:CreateToggle({
            Name = 'Custom Jump',
        })

        CustomJumpMethod = CustomJump:CreateDropdown({
            Name = 'Custom Jump Method',
            List = {'LinearVelocity', 'Velocity', 'CFrame'},
        })

        CustomJumpPower = CustomJump:CreateToggle({
            Name = 'Custom Jump Power',
            Default = true
        })

        JumpPower = CustomJumpPower:CreateSlider({
            Name = 'Jump Power',
            Default = 50,
            Min = 1,
            Max = 100,
        })

        CustomGravity = CustomJump:CreateToggle({
            Name = 'Custom Gravity',
        })

        JumpingGravity = CustomGravity:CreateSlider({
            Name = 'Jumping Gravity',
            Default = 196.2,
            Min = 0,
            Max = 500,
            Decimal = 10
        })

        FallingGravity = CustomGravity:CreateSlider({
            Name = 'Falling Gravity',
            Default = 196.2,
            Min = 0,
            Max = 500,
            Decimal = 10
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
                if JumpPower.Value >= EntityLib.Humanoid.JumpPower then
                    EntityLib.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                EntityLib.Root.AssemblyLinearVelocity = vector.create(EntityLib.Root.AssemblyLinearVelocity.X, JumpPower.Value, EntityLib.Root.AssemblyLinearVelocity.Z)
            else
                EntityLib.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end

        AirJump = Movement:CreateModule({
            Name = "AirJump",
            Info = "Allows you to jump midair",
            Enabled = function()
                AirJump:Clean(UIS.InputBegan:Connect(function(Input)
                    if Input.KeyCode == Enum.KeyCode.Space and EntityLib.Alive and not UIS:GetFocusedTextBox() then
                        if Hold.Enabled then
                            repeat
                                if EntityLib.Humanoid.FloorMaterial == Enum.Material.Air then
                                    Jump()
                                    task.wait(JumpInterval.Value)
                                else
                                    RunService.PostSimulation:Wait()
                                end
                            until not AirJump.Enabled or not Hold.Enabled or not EntityLib.Alive or not UIS:IsKeyDown(Enum.KeyCode.Space)
                        elseif EntityLib.Humanoid.FloorMaterial == Enum.Material.Air then
                            Jump()
                        end
                    end
                end))
            end
        })

        Hold = AirJump:CreateToggle({
            Name = "Hold",
            Info = "Allows you to hold jump instead of spamming it",
        })

        JumpInterval = Hold:CreateSlider({
            Name = "Jump Interval",
            Default = 0.1,
            Min = 0,
            Max = 1,
            Decimal = 100
        })

        CustomJump = AirJump:CreateToggle({
            Name = 'Custom Jump',
            Info = 'Allows you to have a custom air jump',
        })

        JumpPower = CustomJump:CreateSlider({
            Name = 'Jump Power',
            Default = 35,
            Min = 5,
            Max = 70
        })
    end)

    Run(function() -- Fly
        local Fly, HorizontalSpeed, VerticalSpeed, FlyMethod, AlignMethod, MoveMethod, State, Percentage, UsePercentage, UpKeybind, DownKeybind
        local UseLimits, MinSpeed, MaxSpeed, Shift, ShiftSpeed, ShiftUsePercentage, ShiftPercentage, UseShiftLimits, MinShiftSpeed, MaxShiftSpeed, ShiftKeybind
        local W, A, S, D, E, Q, ShiftPressed

        local function GetMoveDirection()
            if MoveMethod.Value == 'MoveDirection' then
                return EntityLib.Humanoid.MoveDirection
            else
                return (Camera.CFrame.LookVector * (W - S)) + (Camera.CFrame.RightVector * (D - A))
            end
        end

        local function GetVerticalDirection()
            if MoveMethod.Value == 'MoveDirection' then
                return vector.create(0, E - Q, 0)
            else
                return Camera.CFrame.UpVector * (E - Q)
            end
        end

        local function GetHortVel()
            local MoveDirection = GetMoveDirection()
            local Vel

            if Shift.Enabled and ShiftPressed then
                Vel = ShiftUsePercentage.Enabled and EntityLib.Humanoid.WalkSpeed * (ShiftPercentage.Value / 100) or ShiftSpeed.Value
                if ShiftUsePercentage.Enabled and UseShiftLimits.Enabled then
                    Vel = math.clamp(Vel, MinShiftSpeed.Value, MaxShiftSpeed.Value)
                end
            else
                Vel = UsePercentage.Enabled and EntityLib.Humanoid.WalkSpeed * (Percentage.Value / 100) or HorizontalSpeed.Value
                if UsePercentage.Enabled and UseLimits.Enabled then
                    Vel = math.clamp(Vel, MinSpeed.Value, MaxSpeed.Value)
                end
            end

            return (TargetStrafeVector or MoveDirection) * Vel
        end

        local function GetVertVel()
            return GetVerticalDirection() * VerticalSpeed.Value
        end

        local function GetVel()
            return GetHortVel() + GetVertVel()
        end

        local FlyMethods = {
            LinearVelocity = {
                Init = function()
                    local Attachment = Fly:CreateInstance('Attachment', 'Attachment', {
                        Name = 'RootAttachment',
                        Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position,
                        Parent = EntityLib.Root
                    })

                    Fly:CreateInstance('LinearVelocity', 'LinearVelocity', {
                        ForceLimitMode = Enum.ForceLimitMode.PerAxis,
                        MaxAxesForce = vector.huge,
                        VectorVelocity = GetVel(),
                        Attachment0 = Attachment,
                        Parent = workspace
                    })
                end,
                Function = function()
                    local ExistingLinearVelocity, ExistingAttachment = Fly:GetInstance('LinearVelocity'), Fly:GetInstance('Attachment')
                    if ExistingLinearVelocity and ExistingAttachment then
                        ExistingAttachment.Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position
                        ExistingLinearVelocity.VectorVelocity = GetVel()
                    end
                end
            },
            Velocity = {
                Function = function()
                    EntityLib.Root.AssemblyLinearVelocity = GetVel() + vector.yAxis
                end,
            },
            CFrame = {
                Function = function(Delta)
                    EntityLib.Root.AssemblyLinearVelocity = vector.yAxis
                    EntityLib.Character:TranslateBy(GetVel() * Delta)
                end,
            },
        }

        local AlignMethods = {
            AlignOrientation = {
                Init = function()
                    local Attachment = Fly:CreateInstance('Attachment', 'Attachment2', {
                        Name = 'RootAttachment',
                        Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position,
                        Parent = EntityLib.Root
                    })

                    Fly:CreateInstance('AlignOrientation', 'AlignOrientation', {
                        Mode = Enum.OrientationAlignmentMode.OneAttachment,
                        Attachment0 = Attachment,
                        RigidityEnabled = true,
                        CFrame = Camera.CFrame,
                        Parent = workspace
                    })
                end,
                Function = function()
                    local ExistingAlignOrientation, ExistingAttachment = Fly:GetInstance('AlignOrientation'), Fly:GetInstance('Attachment2')
                    if ExistingAlignOrientation and ExistingAttachment then
                        ExistingAttachment.Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position
                        ExistingAlignOrientation.CFrame = Camera.CFrame
                    end
                end,
            },
            CFrame = {
                Function = function()
                    EntityLib.Root.CFrame = CFrame.lookAlong(EntityLib.Root.Position, Camera.CFrame.LookVector)
                    EntityLib.Root.AssemblyAngularVelocity = vector.zero
                end,
            }
        }

        local function LocalRemoved()
            FrictionTable.Fly = nil
            UpdateFriction()
            Fly:CleanUp()
            Fly:ClearInstances()
        end

        local function LocalAdded()
            LocalRemoved()
            FrictionTable.Fly = FlyMethod.Value == 'Velocity' or nil
            UpdateFriction()
            local CurrentFlyMethod = FlyMethods[FlyMethod.Value]
            if CurrentFlyMethod and CurrentFlyMethod.Init then
                CurrentFlyMethod.Init()
            end
            local CurrentAlignMethod = AlignMethods[AlignMethod.Value]
            if CurrentAlignMethod and CurrentAlignMethod.Init then
                CurrentAlignMethod.Init()
            end
        end

        Fly = Movement:CreateModule({
            Name = "Fly",
            Info = "Allows you to fly through the air with extra detected methods",
            Function = function(Enabled)
                if Enabled then
                    Modules.Speed:DisableMovers()
                    if Modules.LongJump and Modules.LongJump.Enabled then
                        Modules.LongJump:Toggle(true)
                    end
                    if Modules.HighJump and Modules.HighJump.Enabled then
                        Modules.HighJump:Toggle(true)
                    end
                    
                    W = UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0
                    A = UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0
                    S = UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0
                    D  = UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0
                    E = UpKeybind:IsPressed() and 1 or 0
                    Q = DownKeybind:IsPressed() and 1 or 0
                    ShiftPressed = ShiftKeybind:IsPressed()

                    if EntityLib.Alive then
                        LocalAdded()
                    end

                    Fly:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    Fly:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    Fly:Clean(RunService.PreRender:Connect(function()
                        if AlignMethod.Value ~= "None" and EntityLib.Alive then
                            AlignMethods[AlignMethod.Value].Function()
                        end
                    end))

                    Fly:Clean(RunService.PreSimulation:Connect(function(Delta)
                        if not EntityLib.Alive then return end
                        if State.Value ~= 'None' then
                            if State.Value == 'PlatformStand' then
                                EntityLib.Humanoid.PlatformStand = true
                            else
                                EntityLib.Humanoid:ChangeState(Enum.HumanoidStateType[State.Value])
                            end
                        end
                        FlyMethods[FlyMethod.Value].Function(Delta)
                    end))
                    
                    for i = 1, 0, -1 do
                        local Signal = i == 1 and UIS.InputBegan or UIS.InputEnded
                        Fly:Clean(Signal:Connect(function(Input)
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
                            elseif ShiftKeybind:Check(Input) then
                                ShiftPressed = i == 1
                            end
                        end))
                    end
                else
                    Modules.Speed:EnableMovers()
                    FrictionTable.Fly = nil
                    UpdateFriction()
                    if EntityLib.Alive and State.Value ~= 'None' then
                        if State.Value == 'PlatformStand' then
                            EntityLib.Humanoid.PlatformStand = false
                        elseif EntityLib.Humanoid:GetState() == Enum.HumanoidStateType[State.Value] then
                            EntityLib.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                        end
                    end
                    W, A, S, D, E, Q = nil, nil, nil, nil, nil, nil
                end
            end,
            ExtraText = function()
                return FlyMethod.Value
            end,
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
            Name = 'Fly Method',
            Info = 'LinearVelocity - Adjusts the velocity of your character by using a LinearVelocity object\nVelocity - Directly adjusts the velocity your character\nCFrame - Directly adjusts the position of your character',
            List = {'LinearVelocity', 'Velocity', 'CFrame'},
            Function = function(Val)
                if Fly.Enabled then
                    if Val ~= 'LinearVelocity' then
                        Fly:RemoveInstance('LinearVelocity')
                        Fly:RemoveInstance('Attachment')
                    end
                    if Fly.Enabled then
                        FrictionTable.Fly = Val == 'Velocity' or nil
                        UpdateFriction()
                    end
                end
            end
        })

        AlignMethod = Fly:CreateDropdown({
            Name = 'Align Method',
            List = {'AlignOrientation', 'CFrame', 'None'},
            Info = 'AlignOrientation - Smoothly adjusts your character\'s orientation.\nCFrame - Directly adjusts the CFrame of your character.\nNone - Doesn\'t align your character at all',
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
                if Fly.Enabled and EntityLib.Alive and Val == 'None' then
                    EntityLib.Humanoid:ChangeState(EntityLib.Humanoid.FloorMaterial == Enum.Material.Air and Enum.HumanoidStateType.Freefall or Enum.HumanoidStateType.Running)
                end
            end
        })

        UsePercentage = Fly:CreateToggle({
            Name = 'Use Percentage',
            Info = 'Uses speed based off a percentage of your humanoid\'s walk speed',
        })

        Percentage = UsePercentage:CreateSlider({
            Name = 'Percentage',
            Default = 110,
            Min = 0,
            Max = 200,
            Suffix = '%'
        })

        UseLimits = UsePercentage:CreateToggle({
            Name = 'Use Limits',
            Info = 'Limits the speed calculated by Speed Percentage between the minimum and maximum values',
        })

        MinSpeed = UseLimits:CreateSlider({
            Name = "Min Speed",
            Default = 0,
            Min = 0,
            Max = 32
        })

        MaxSpeed = UseLimits:CreateSlider({
            Name = 'Max Speed',
            Default = 32,
            Min = 0,
            Max = 64
        })

        Shift = Fly:CreateToggle({
            Name = 'Shift',
            Info = 'Allows you to toggle a faster speed when holding your keybind'
        })

        ShiftSpeed = Shift:CreateSlider({
            Name = 'Shift Speed',
            Default = 32,
            Min = 16,
            Max = 200,
        })

        ShiftUsePercentage = Shift:CreateToggle({
            Name = 'Shift Use Percentage',
        })

        ShiftPercentage = ShiftUsePercentage:CreateSlider({
            Name = 'Shift Percentage',
            Default = 120,
            Min = 0,
            Max = 300,
            Suffix = '%',
        })

        UseShiftLimits = ShiftUsePercentage:CreateToggle({
            Name = 'Use Shift Limits',
            Info = 'Limits the speed calculated by Speed Percentage between the minimum and maximum values'
        })

        MinShiftSpeed = UseShiftLimits:CreateSlider({
            Name = "Min Shift Speed",
            Default = 0,
            Min = 0,
            Max = 32
        })

        MaxShiftSpeed = UseShiftLimits:CreateSlider({
            Name = 'Max Shift Speed',
            Default = 32,
            Min = 0,
            Max = 64
        })

        ShiftKeybind = Shift:CreateKeybind({
            Name = 'Shift',
            Keybind = 'LeftShift'
        })
    end)

    Run(function() -- FastClimb
        local FastClimb, Speed, Method, ResetVel

        local Modified

        local Functions = {
            Velocity = function()
                if math.abs(EntityLib.Root.AssemblyLinearVelocity.Y) >= (Modified and Speed.Value or EntityLib.Humanoid.WalkSpeed) / 10 then
                    Modified = true
                    local CurrentVel = EntityLib.Root.AssemblyLinearVelocity
                    local Direction = math.sign(EntityLib.Root.AssemblyLinearVelocity.Y)
                    local Vel = vector.create(CurrentVel.X, Direction * Speed.Value, CurrentVel.Z)
                    EntityLib.Root.AssemblyLinearVelocity = Vel
                else
                    Modified = nil
                end
            end,
        }

        FastClimb = Movement:CreateModule({
            Name = 'FastClimb',
            Info = 'Increases the speed at which you climb ladders',
            Enabled = function()
                local Climbed
                FastClimb:Clean(RunService.PreSimulation:Connect(function(Delta)
                    if not EntityLib.Alive then return end
                    local State = EntityLib.Humanoid:GetState()
                    if State == Enum.HumanoidStateType.Climbing then
                        if EntityLib.Humanoid.MoveDirection ~= vector.zero then
                            Functions[Method.Value](Delta)
                            Climbed = true
                        end
                    elseif Climbed then
                        if Method.Value == 'Velocity' and ResetVel.Enabled then
                            EntityLib.Root.AssemblyLinearVelocity = vector.create(EntityLib.Root.AssemblyLinearVelocity.X, 16, EntityLib.Root.AssemblyLinearVelocity.Z)
                        end
                        Climbed = nil
                        Modified = nil
                    end
                end))
            end,
            ExtraText = function()
                return Method.Value
            end
        })

        Speed = FastClimb:CreateSlider({
            Name = 'Speed',
            Default = 20,
            Min = 1,
            Max = 200
        })

        Method = FastClimb:CreateDropdown({
            Name = 'Method',
            List = {'Velocity'},
            Info = 'Velocity - Increases the Y velocity of your character.',
            Function = function(Val)
                ResetVel:SetVisible(Val == 'Velocity')
            end
        })

        ResetVel = FastClimb:CreateToggle({
            Name = 'Reset Y Velocity',
            Info = 'Resets your Y velocity to zero after climbing a ladder',
        })
    end)

    Run(function() -- Spider
        local Spider, Speed, Radius, Method, ResetVel, MaxAngle

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true
        Params.IgnoreWater = true

        local Methods = {
            Velocity = function()
                EntityLib.Root.AssemblyLinearVelocity += vector.create(0, Speed.Value, 0)
            end,
            CFrame = function(Delta)
                EntityLib.Character:TranslateBy(vector.create(0, Speed.Value * Delta, 0))
            end,
        }

        Spider = Movement:CreateModule({
            Name = 'Spider',
            Info = 'Makes you climb up walls like a spider 🕷️',
            Enabled = function()
                local ClimbedLastFrame

                local Exclusions = {}

                local function RefreshExclusions()
                    table.clear(Exclusions)
                    if EntityLib.Alive then
                        Exclusions[1] = EntityLib.Character
                        Params.CollisionGroup = EntityLib.Root.CollisionGroup
                    end
                    for _, Ent in EntityLib.List do
                        table.insert(Exclusions, Ent.Character)
                    end
                    Params.FilterDescendantsInstances = Exclusions
                end

                RefreshExclusions()

                Spider:Clean(EntityLib.Events.LocalAdded:Connect(RefreshExclusions))
                Spider:Clean(EntityLib.Events.LocalRemoved:Connect(RefreshExclusions))
                Spider:Clean(EntityLib.Events.EntityAdded:Connect(RefreshExclusions))
                Spider:Clean(EntityLib.Events.EntityRemoved:Connect(RefreshExclusions))
                Spider:Clean(RunService.PreSimulation:Connect(function(Delta)
                    if not EntityLib.Alive then return end

                    local MoveDirection = EntityLib.Humanoid.MoveDirection * Radius.Value
                    
                    local Raycast = workspace:Raycast(EntityLib.Root.Position - vector.create(0, EntityLib.HipHeight - 0.5, 0), MoveDirection, Params)
                    if Raycast and Raycast.Normal.Y <= MaxAngle then
                        ClimbedLastFrame = true
                        Methods[Method.Value](Delta)
                    elseif ClimbedLastFrame then
                        if ResetVel.Enabled then
                            local Vel = EntityLib.Root.AssemblyLinearVelocity
                            EntityLib.Root.AssemblyLinearVelocity = vector.create(Vel.X, 0, Vel.Z)
                        end
                        ClimbedLastFrame = nil
                    end
                end))
            end,
            ExtraText = function()
                return Method.Value
            end,
        })

        Speed = Spider:CreateSlider({
            Name = 'Speed',
            Default = 20,
            Min = 0,
            Max = 100,
        })

        Radius = Spider:CreateSlider({
            Name = 'Radius',
            Default = 2.5,
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
                MaxAngle = 1 - math.cos(math.rad(Val))
            end
        })

        MaxAngle = 1 - math.cos(math.rad(10))

        Method = Spider:CreateDropdown({
            Name = 'Method',
            List = {'Velocity', 'CFrame'},
            Function = function(Val)
                ResetVel:SetVisible(Val == 'Velocity')
            end,
        })

        ResetVel = Spider:CreateToggle({
            Name = 'Reset Vel',
            Info = 'Resets your Y velocity back to zero after climbing over a wall'
        })
    end)

    Run(function() -- Step
        local Step, Radius, MinSize, MaxSize, MaxAngle

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true
        Params.IgnoreWater = true

        Step = Movement:CreateModule({
            Name = 'Step',
            Info = 'Allows you to walk up parts instantly',
            Enabled = function()
                local Exclusions = {}

                local function RefreshExclusions()
                    table.clear(Exclusions)
                    if EntityLib.Alive then
                        Exclusions[1] = EntityLib.Character
                        Params.CollisionGroup = EntityLib.Root.CollisionGroup
                    end
                    for _, Ent in EntityLib.List do
                        table.insert(Exclusions, Ent.Character)
                    end
                    Params.FilterDescendantsInstances = Exclusions
                end

                RefreshExclusions()

                Step:Clean(EntityLib.Events.LocalAdded:Connect(RefreshExclusions))
                Step:Clean(EntityLib.Events.LocalRemoved:Connect(RefreshExclusions))
                Step:Clean(EntityLib.Events.EntityAdded:Connect(RefreshExclusions))
                Step:Clean(EntityLib.Events.EntityRemoved:Connect(RefreshExclusions))
                Step:Clean(RunService.PreSimulation:Connect(function()
                    if not EntityLib.Alive then return end

                    local MoveDirection = EntityLib.Humanoid.MoveDirection * Radius.Value
                    
                    local Raycast = workspace:Raycast(EntityLib.Root.Position - vector.create(0, EntityLib.HipHeight - 0.5, 0), MoveDirection, Params)
                    if Raycast and Raycast.Normal.Y <= MaxAngle then
                        local TopPoint = Raycast.Instance.Position.Y + (Raycast.Instance.Size.Y / 2)
                        local HitPoint = Raycast.Position.Y - 0.5
                        local Diff = TopPoint - HitPoint

                        if Diff >= MinSize.Value and Diff <= MaxSize.Value then
                            EntityLib.Character:TranslateBy(vector.create(0, Diff, 0))
                        end
                    end
                end))
            end
        })

        Radius = Step:CreateSlider({
            Name = 'Radius',
            Default = 1.5,
            Min = 1,
            Max = 9,
            Decimal = 10
        })

        MinSize = Step:CreateSlider({
            Name = 'Min Size',
            Default = 2,
            Min = 0,
            Max = 4
        })

        MaxSize = Step:CreateSlider({
            Name = 'Max Size',
            Default = 4,
            Min = 1,
            Max = 20
        })

        Step:CreateSlider({
            Name = 'Max Angle',
            Default = 10,
            Min = 0,
            Max = 90,
            Function = function(Val)
                MaxAngle = 1 - math.cos(math.rad(Val))
            end
        })

        MaxAngle = 1 - math.cos(math.rad(10))
    end)

    Run(function() -- Float
        local Float, Method, Color, UpOffset, DownOffset, UpSpeed, DownSpeed, UpKeybind, DownKeybind
        local E, Q, EDown, QDown
        local Part

        Float = Movement:CreateModule({
            Name = "Float",
            Info = "Creates a part below you allowing you to float",
            Function = function(Enabled)
                if Enabled then
                    Part = Float:CreateInstance('Part', 'Part', {
                        Color = Color.Color,
                        Transparency = Color.Transparency,
                        Size = vector.create(2, 0.2, 2),
                        Anchored = true,
                        CanTouch = false,
                        CanQuery = false,
                        CastShadow = false,
                        AudioCanCollide = false,
                        Parent = workspace
                    })

                    EDown, QDown = UpKeybind:IsPressed(), DownKeybind:IsPressed()
                    E, Q = EDown and 1 or 0, QDown and 1 or 0

                    if Method.Value == 'Part' then
                        Float:Clean(RunService.PostSimulation:Connect(function()
                            if not EntityLib.Alive then return end
                            local Offset = (EntityLib.HipHeight - EntityLib.Root.Size.Y)
                            local Y = -(EntityLib.HipHeight + 0.1) + ((E - Q) * Offset) + ((EDown and UpOffset.Value or 0) - (QDown and DownOffset.Value or 0))
                            Part.CFrame = EntityLib.Root.CFrame * CFrame.new(0, Y, 0)
                        end))
                    else
                        local Attachment, LinearVelocity

                        local function LocalAdded()
                            Attachment = Float:CreateInstance('Attachment', 'Attachment', {
                                Name = 'RootAttachment',
                                Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position,
                                Parent = EntityLib.Root
                            })

                            LinearVelocity = Float:CreateInstance('LinearVelocity', 'LinearVelocity', {
                                VelocityConstraintMode = Enum.VelocityConstraintMode.Line,
                                LineDirection = vector.yAxis,
                                ForceLimitsEnabled = false,
                                LineVelocity = 0,
                                Attachment0 = Attachment,
                                Enabled = false,
                                Parent = workspace
                            })
                        end

                        local function LocalRemoved()
                            Float:RemoveInstance('Attachment')
                            Attachment = nil
                        end

                        Float:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                        Float:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                        Float:Clean(RunService.PreSimulation:Connect(function()
                            if not (EntityLib.Alive and Attachment) then return end
                            if (EDown or QDown) or (EntityLib.Humanoid.FloorMaterial == Enum.Material.Air and EntityLib.Root.AssemblyLinearVelocity.Y <= 0) then
                                local Vel = (E * UpSpeed.Value) - (Q * DownSpeed.Value)
                                if Vel < 0 and EntityLib.Humanoid.FloorMaterial ~= Enum.Material.Air then
                                    LinearVelocity.LineVelocity = 0
                                else
                                    LinearVelocity.LineVelocity = Vel
                                    Attachment.Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position
                                    LinearVelocity.Enabled = true
                                end
                            elseif EntityLib.Humanoid.FloorMaterial ~= Enum.Material.Air then
                                LinearVelocity.Enabled = false
                            else
                                LinearVelocity.LineVelocity = 0
                            end
                        end))

                        if EntityLib.Alive then
                            LocalAdded()
                        end
                    end

                    for i = 1, 0, -1 do
                        local Signal = i == 1 and UIS.InputBegan or UIS.InputEnded
                        Float:Clean(Signal:Connect(function(Input)
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
                else
                    Part = nil
                end
            end,
            ExtraText = function()
                return Method.Value
            end
        })

        Method = Float:CreateDropdown({
            Name = 'Method',
            List = {'Part', 'LinearVelocity'},
            Function = function(Val)
                UpOffset:SetVisible(Val == 'Part')
                DownOffset:SetVisible(Val == 'Part')
                Color:SetVisible(Val == 'Part')
                UpSpeed:SetVisible(Val == 'LinearVelocity')
                DownSpeed:SetVisible(Val == 'LinearVelocity')
                if Float.Enabled then
                    Float:Toggle(true)
                    Float:Toggle(true)
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

        UpSpeed = Float:CreateSlider({
            Name = 'Up Speed',
            Default = 50,
            Min = 1,
            Max = 100,
            Visible = false
        })

        DownSpeed = Float:CreateSlider({
            Name = 'Down Speed',
            Default = 50,
            Min = 1,
            Max = 100,
            Visible = false
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
    end)

    Run(function() -- ClickTP
        local ClickTP, Keybind

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true

        ClickTP = Movement:CreateModule({
            Name = 'ClickTP',
            Info = 'Teleports you to your mouse\'s location when you click while holding your keybind',
            Enabled = function()
                ClickTP:Clean(UIS.InputBegan:Connect(function(Input)
                    if UIS:GetFocusedTextBox() or not EntityLib.Alive then return end
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 and Keybind:IsPressed() then
                        Params.FilterDescendantsInstances = {EntityLib.Character}

                        local MouseLocation = UIS:GetMouseLocation()
                        local MouseRaycast = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)
                        local Raycast = workspace:Raycast(MouseRaycast.Origin, MouseRaycast.Direction * 9e9, Params)

                        if Raycast then
                            local HitPos = Raycast.Position + vector.create(0, EntityLib.HipHeight, 0)
                            local _, Y = CFrame.lookAt(EntityLib.Root.Position, HitPos):ToOrientation()
                            EntityLib.Root.CFrame = CFrame.new(HitPos) * CFrame.Angles(0, Y, 0)
                        end
                    end
                end))
            end
        })

        Keybind = ClickTP:CreateKeybind({
            Name = 'Teleport',
            Keybind = 'R'
        })
    end)

    Run(function() -- CFrameFly
        local CFrameFly, UpKeybind, DownKeybind, CFrameFlySpeed, TPBack, OriginTracer, Color, Thickness, PositionPreset

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
            if Preset == 'Mouse' then
                local MouseLocation = UIS:GetMouseLocation()
                return Path2DControlPoint.new(UDim2.fromOffset(MouseLocation.X, MouseLocation.Y))
            else
                return From
            end
        end

        CFrameFly = Movement:CreateModule({
            Name = 'CFrameFly',
            Info = 'Works like normal fly except it only updates your position client sided',
            Function = function(Enabled)
                if Enabled then
                    local ScreenGui = CFrameFly:CreateInstance('ScreenGui', 'ScreenGui', {
                        IgnoreGuiInset = true,
                        Name = 'CFrameFlyTracers',
                        Parent = TidalWave.Gui
                    })

                    local Tracer = CFrameFly:CreateInstance('Path2D', 'Tracer', {
                        Name = 'OriginalLocation',
                        Color3 = Color.Color,
                        Thickness = Thickness.Value,
                        Visible = false,
                        Parent = ScreenGui
                    })

                    local E, Q = UpKeybind:IsPressed() and 1 or 0, DownKeybind:IsPressed() and 1 or 0
                    local OldCFrame

                    CFrameFly:Clean(RunService.PreRender:Connect(function()
                        if EntityLib.Alive then
                            if not OldCFrame then
                                OldCFrame = EntityLib.Root.CFrame
                                CFrameFly:Clean(function()
                                    if TPBack.Enabled and EntityLib.Alive then
                                        EntityLib.Root.CFrame = OldCFrame
                                    end
                                end)
                            end
                            
                            if OriginTracer.Enabled then
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
                        end
                    end))

                    CFrameFly:Clean(RunService.PostSimulation:Connect(function(Delta)
                        if not EntityLib.Alive then return end
                        EntityLib.Root.Anchored = true
                        local CameraOffset = EntityLib.Root.CFrame:ToObjectSpace(Camera.CFrame).Position
                        Camera.CFrame *= CFrame.new(-CameraOffset.X, -CameraOffset.Y, -CameraOffset.Z + 1)
                        local ModdedCameraPos = vector.create(EntityLib.Root.CFrame.Position.X, Camera.CFrame.Position.Y, EntityLib.Root.CFrame.Position.Z)
                        local ObjectSpaceVelocity = CFrame.lookAt(Camera.CFrame.Position, ModdedCameraPos)
                        local MoveDirection =  EntityLib.Humanoid.MoveDirection + vector.create(0, E - Q, 0)
                        ObjectSpaceVelocity = ObjectSpaceVelocity:VectorToObjectSpace(MoveDirection * (CFrameFlySpeed.Value * Delta))
                        EntityLib.Root.CFrame = CFrame.new(EntityLib.Root.CFrame.Position) * (Camera.CFrame - Camera.CFrame.Position) * CFrame.new(ObjectSpaceVelocity)
                    end))

                    for i = 1, 0, -1 do
                        local Signal = i == 1 and UIS.InputBegan or UIS.InputEnded
                        CFrameFly:Clean(Signal:Connect(function(Input)
                            if i == 1 and UIS:GetFocusedTextBox() then return end
                            if UpKeybind:Check(Input) then
                                E = i
                            elseif DownKeybind:Check(Input) then
                                E = i
                            end
                        end))
                    end
                else
                    if EntityLib.Alive then
                        EntityLib.Root.Anchored = false
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

        TPBack = CFrameFly:CreateToggle({
            Name = 'TP Back',
            Info = 'Teleports you to the original location you started at'
        })

        OriginTracer = CFrameFly:CreateToggle({
            Name = 'Origin Tracer',
            Info = 'Creates a tracer pointing to the location you started at',
        })

        Color = OriginTracer:CreateColorPicker({
            Name = 'Tracer Color',
        })

        Thickness = OriginTracer:CreateSlider({
            Name = 'Tracer Thickness',
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

        PositionPreset = OriginTracer:CreateDropdown({
            Name = 'Position',
            List = {'Bottom', 'Bottom Left', 'Bottom Right', 'Top Left', 'Top', 'Top Right', 'Left', 'Middle', 'Right', 'Mouse'},
            Function = function(Val)
                From = TracerPositions[Val]
            end
        })

        UpKeybind = CFrameFly:CreateKeybind({
            Name = 'Up',
            Keybind = 'E',
            Secondary = true
        })

        DownKeybind = CFrameFly:CreateKeybind({
            Name = 'Down',
            Keybind = 'Q',
            Secondary = true
        })
    end)

    Run(function() -- Timer
        local Timer, Speed

        Timer = Movement:CreateModule({
            Name = 'Timer',
            Info = 'Changes the speed of your character',
            Enabled = function()
                Timer:Clean(RunService.PreRender:Connect(function(Delta)
                    if EntityLib.Alive and Speed.Value > 1 then
                        RunService:Pause()
                        workspace:StepPhysics(Delta * (Speed.Value - 1), {EntityLib.Root})
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

    Run(function() -- SpinBot
        local SpinBot, Speed

        SpinBot = Movement:CreateModule({
            Name = "SpinBot",
            Info = "Makes you spin (Doesn't work in first person)",
            Enabled = function()
                SpinBot:Clean(RunService.PreSimulation:Connect(function()
                    if EntityLib.Alive then
                        EntityLib.Root.AssemblyAngularVelocity = vector.create(EntityLib.Root.AssemblyAngularVelocity.X, Speed.Value, EntityLib.Root.AssemblyAngularVelocity.Z)
                    end
                end))
            end
        })

        Speed = SpinBot:CreateSlider({
            Name = "Speed",
            Default = 45,
            Min = 0,
            Max = 360
        })
    end)

    Run(function() -- Swim
        local Swim, Speed, UsePercentage, Percentage, UseLimits, MinSpeed, MaxSpeed
        local UpKeybind, DownKeybind
        local W, A, S, D, Q, E

        local DisabledStates = Enum.HumanoidStateType:GetEnumItems()
        DisabledStates[17] = nil
        table.remove(DisabledStates, 15)
        table.remove(DisabledStates, 5)
        local PrevStates = {}

        local function LocalRemoved()
            Swim:CleanUp()
            table.clear(PrevStates)
        end

        local function LocalAdded()
            LocalRemoved()
            for _, State in DisabledStates do
                PrevStates[State] = EntityLib.Humanoid:GetStateEnabled(State)
                if PrevStates[State] then
                    EntityLib.Humanoid:SetStateEnabled(State, false)
                end
            end
            local db = false
            Swim:Clean(EntityLib.Humanoid.StateEnabledChanged:Connect(function(State, Enabled)
                if db then return end
                db = true
                PrevStates[State] = Enabled
                if Enabled then
                    EntityLib.Humanoid:SetStateEnabled(State, false)
                end
                db = false
            end))
            EntityLib.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        end

        Swim = Movement:CreateModule({
            Name = "Swim",
            Info = "Makes you swim",
            Function = function(Enabled)
                if Enabled then
                    Swim:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    Swim:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if EntityLib.Alive then
                        LocalAdded()
                    end

                    W, A, S, D, E, Q = UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0, UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0, UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0, UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0, UpKeybind:IsPressed()  and 1 or 0, DownKeybind:IsPressed() and 1 or 0

                    for i = 1, 0, -1 do
                        local Signal = i == 1 and UIS.InputBegan or UIS.InputEnded
                        Swim:Clean(Signal:Connect(function(Input)
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
                        if EntityLib.Alive then
                            Vel = EntityLib.Root.AssemblyLinearVelocity + vector.create(0, Delta * workspace.Gravity, 0)
                            EntityLib.Root.AssemblyLinearVelocity = Vel
                        end
                        RunService.PostSimulation:Wait()
                        if EntityLib.Alive then
                            if W > 0 or A > 0 or S > 0 or D > 0 or E > 0 or Q > 0 then
                                local Multi = UsePercentage.Enabled and (EntityLib.Humanoid.WalkSpeed * (Percentage.Value / 100)) or Speed.Value
                                if UsePercentage.Enabled and UseLimits.Enabled then
                                    Multi = math.clamp(Multi, MinSpeed.Value, MaxSpeed.Value)
                                end
                                EntityLib.Root.AssemblyLinearVelocity = vector.normalize((Camera.CFrame.LookVector * (W - S)) + (Camera.CFrame.RightVector * (D - A)) + (Camera.CFrame.UpVector * (E - Q))) * Multi
                            else
                                EntityLib.Root.AssemblyLinearVelocity = vector.zero
                            end
                        end
                    end))
                else
                    if EntityLib.Alive then
                        for State, Enabled in PrevStates do
                            EntityLib.Humanoid:SetStateEnabled(State, Enabled)
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
            Default = 16,
            Min = 0,
            Max = 64,
        })

        UsePercentage = Swim:CreateToggle({
            Name = "Use Percentage",
            Info = "Uses speed based off a percentage of your humanoid's walk speed",
        })

        Percentage = UsePercentage:CreateSlider({
            Name = "Percentage",
            Min = 0,
            Default = 110,
            Max = 200,
            Suffix = "%",
        })

        UseLimits = UsePercentage:CreateToggle({
            Name = 'Use Limits',
            Info = 'Limits the speed calculated by Speed Percentage between the minimum and maximum values',
        })

        MinSpeed = UseLimits:CreateSlider({
            Name = "Min Speed",
            Default = 0,
            Min = 0,
            Max = 32,
        })

        MaxSpeed = UseLimits:CreateSlider({
            Name = 'Max Speed',
            Default = 32,
            Min = 0,
            Max = 64,
        })
    end)
end)

Run(function() -- Visuals
    Run(function() -- Fullbright
        local Fullbright, Bloom, db

        local AtmosphereProperties = {
            Density = 0,
            Offset = 0,
            Glare = 0,
            Haze = 0
        }
        local LightingProperties = {}
        local EnabledProperties = {}
        local OldValues = {}

        local function AddAtmosphere(Atmosphere)
            local Tab = {}
            for Prop, Value in AtmosphereProperties do
                Tab[Prop] = Atmosphere[Prop]
                Atmosphere[Prop] = Value
            end
            local db2
            Fullbright:Clean(Atmosphere.Changed:Connect(function(Property)
                if AtmosphereProperties[Property] and not db2 then
                    db2 = true
                    Tab[Property] = Atmosphere[Property]
                    Atmosphere[Property] = AtmosphereProperties[Property]
                    db2 = nil
                end
            end))
            OldValues[Atmosphere] = Tab
        end

        local function AddEffect(Effect)
            local Tab = {
                Enabled = Effect.Enabled
            }
            local Enabled = Effect == Bloom
            Effect.Enabled = Enabled
            Fullbright:Clean(Effect:GetPropertyChangedSignal('Enabled'):Connect(function()
                Tab.Enabled = Effect.Enabled
                Effect.Enabled = Enabled
            end))
            OldValues[Effect] = Tab
        end

        Fullbright = Visuals:CreateModule({
            Name = "Fullbright",
            Info = "Increases the brightness of lighting and removes visual effects that can make it harder to see",
            Function = function(Enabled)
                if Enabled then
                    Bloom = Fullbright:CreateInstance('BloomEffect', 'Bloom', {
                        Intensity = 0,
                        Size = 0,
                        Threshold = 0,
                        Parent = Lighting
                    })

                    local Tab = {}

                    for Prop, v in LightingProperties do
                        Tab[Prop] = Lighting[Prop]
                        if EnabledProperties[Prop].Enabled then
                            Lighting[Prop] = v.Value or v.Color
                        end
                    end

                    OldValues[Lighting] = Tab
                    Fullbright:Clean(Lighting.Changed:Connect(function(Property)
                        local TabValue = LightingProperties[Property]
                        if TabValue and EnabledProperties[Property].Enabled and not db then
                            db = true
                            Tab[Property] = Lighting[Property]
                            Lighting[Property] = TabValue.Value or TabValue.Color
                            db = nil
                        end
                    end))

                    Fullbright:Clean(Lighting.DescendantAdded:Connect(function(Descendant)
                        if Descendant.ClassName == "Atmosphere" then
                            AddAtmosphere(Descendant)
                        elseif Descendant:IsA("PostEffect") then
                            AddEffect(Descendant)
                        end
                    end))

                    Fullbright:Clean(Camera.DescendantAdded:Connect(function(Descendant)
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
                    db = nil
                    Bloom = nil
                    for Obj, Tab in OldValues do
                        for Prop, Value in Tab do
                            Obj[Prop] = Value
                        end
                    end
                    table.clear(OldValues)
                end
            end
        })

        local function Restart()
            if Fullbright.Enabled then
                Fullbright:Toggle(true)
                Fullbright:Toggle(true)
            end
        end

        EnabledProperties.ExposureCompensation = Fullbright:CreateToggle({
            Name = "Set Exposure",
            Default = true,
            Function = Restart
        })

        LightingProperties.ExposureCompensation = EnabledProperties.ExposureCompensation:CreateSlider({
            Name = "Exposure",
            Default = 0,
            Min = -3,
            Max = 3,
            Decimal = 100,
            Function = function(Val)
                if Fullbright.Enabled and EnabledProperties.ExposureCompensation.Enabled then
                    db = true
                    Lighting.ExposureCompensation = Val
                    db = nil
                end
            end
        })

        EnabledProperties.Brightness = Fullbright:CreateToggle({
            Name = "Set Brightness",
            Default = true,
            Function = Restart
        })

        LightingProperties.Brightness = EnabledProperties.Brightness:CreateSlider({
            Name = "Brightness",
            Default = 3,
            Min = 0,
            Max = 10,
            Decimal = 10,
            Function = function(Val)
                if Fullbright.Enabled and EnabledProperties.Brightness.Enabled then
                    db = true
                    Lighting.Brightness = Val
                    db = nil
                end
            end
        })

        EnabledProperties.Ambient = Fullbright:CreateToggle({
            Name = "Set Ambient",
            Default = true,
            Function = Restart
        })

        LightingProperties.Ambient = EnabledProperties.Ambient:CreateColorPicker({
            Name = "Ambient",
            Function = function(Color)
                if Fullbright.Enabled and EnabledProperties.Ambient.Enabled then
                    db = true
                    Lighting.Ambient = Color
                    db = nil
                end
            end
        })

        EnabledProperties.OutdoorAmbient = Fullbright:CreateToggle({
            Name = "Set Outdoor Ambient",
            Default = true,
            Function = Restart
        })

        LightingProperties.OutdoorAmbient = EnabledProperties.OutdoorAmbient:CreateColorPicker({
            Name = "Outdoor Ambient",
            Function = function(Color)
                if Fullbright.Enabled and EnabledProperties.OutdoorAmbient.Enabled then
                    db = true
                    Lighting.OutdoorAmbient = Color
                    db = nil
                end
            end
        })

        EnabledProperties.ColorShift_Bottom = Fullbright:CreateToggle({
            Name = "Set Color Shift Bottom",
            Default = true,
            Function = Restart
        })

        LightingProperties.ColorShift_Bottom = EnabledProperties.ColorShift_Bottom:CreateColorPicker({
            Name = "Color Shift Bottom",
            Default = Color3.White,
            Function = function(Color)
                if Fullbright.Enabled and EnabledProperties.ColorShift_Bottom.Enabled then
                    db = true
                    Lighting.ColorShift_Bottom = Color
                    db = nil
                end
            end
        })

        EnabledProperties.ColorShift_Top = Fullbright:CreateToggle({
            Name = "Set Color Shift Top",
            Default = true,
            Function = Restart
        })

        LightingProperties.ColorShift_Top = EnabledProperties.ColorShift_Top:CreateColorPicker({
            Name = "Color Shift Top",
            Default = Color3.White,
            Function = function(Color)
                if Fullbright.Enabled and EnabledProperties.ColorShift_Top.Enabled then
                    db = true
                    Lighting.ColorShift_Top = Color
                    db = nil
                end
            end
        })

        EnabledProperties.GlobalShadows = Fullbright:CreateToggle({
            Name = "Set Shadows",
            Default = true,
            Function = Restart
        })

        LightingProperties.GlobalShadows = EnabledProperties.GlobalShadows:CreateToggle({
            Name = "Shadows",
            Function = function(Enabled)
                if Fullbright.Enabled and EnabledProperties.GlobalShadows.Enabled then
                    db = true
                    Lighting.GlobalShadows = Enabled
                    db = nil
                end
            end
        })

        EnabledProperties.EnvironmentDiffuseScale = Fullbright:CreateToggle({
            Name = "Set Diffuse Scale",
            Default = true,
            Function = Restart
        })

        LightingProperties.EnvironmentDiffuseScale = EnabledProperties.EnvironmentDiffuseScale:CreateSlider({
            Name = "Diffuse Scale",
            Default = 0,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = function(Val)
                if Fullbright.Enabled and EnabledProperties.EnvironmentDiffuseScale.Enabled then
                    db = true
                    Lighting.EnvironmentDiffuseScale = Val
                    db = nil
                end
            end
        })

        EnabledProperties.EnvironmentSpecularScale = Fullbright:CreateToggle({
            Name = "Set Specular Scale",
            Default = true,
            Function = Restart
        })

        LightingProperties.EnvironmentSpecularScale = EnabledProperties.EnvironmentSpecularScale:CreateSlider({
            Name = "Specular Scale",
            Default = 0,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = function(Val)
                if Fullbright.Enabled and EnabledProperties.EnvironmentSpecularScale.Enabled then
                    db = true
                    Lighting.EnvironmentSpecularScale = Val
                    db = nil
                end
            end
        })

        EnabledProperties.ClockTime = Fullbright:CreateToggle({
            Name = "Set Clock Time",
            Default = true,
            Function = Restart
        })

        LightingProperties.ClockTime = EnabledProperties.ClockTime:CreateSlider({
            Name = "Clock Time",
            Default = 12,
            Min = 0,
            Max = 24,
            Decimal = 10,
            Function = function(Val)
                if Fullbright.Enabled and EnabledProperties.ClockTime.Enabled then
                    db = true
                    Lighting.ClockTime = Val
                    db = nil
                end
            end
        })

        EnabledProperties.FogStart = Fullbright:CreateToggle({
            Name = "Set Fog Start",
            Default = true,
            Function = Restart
        })

        LightingProperties.FogStart = EnabledProperties.FogStart:CreateSlider({
            Name = "Fog Start",
            Default = Lighting.FogStart,
            Min = 0,
            Max = 100,
            Function = function(Val)
                if Fullbright.Enabled and EnabledProperties.FogStart.Enabled then
                    db = true
                    Lighting.FogStart = Val
                    db = nil
                end
            end
        })

        EnabledProperties.FogEnd = Fullbright:CreateToggle({
            Name = "Set Fog End",
            Default = true,
            Function = Restart
        })

        LightingProperties.FogEnd = EnabledProperties.FogEnd:CreateSlider({
            Name = "Fog End",
            Default = 100000,
            Min = 0,
            Max = 100000,
            Function = function(Val)
                if Fullbright.Enabled and EnabledProperties.FogEnd.Enabled then
                    db = true
                    Lighting.FogEnd = Val
                    db = nil
                end
            end
        })

        EnabledProperties.FogColor = Fullbright:CreateToggle({
            Name = "Set Fog Color",
            Function = Restart
        })

        LightingProperties.FogColor = EnabledProperties.FogColor:CreateColorPicker({
            Name = "Fog Color",
            Default = Color3.White,
            Function = function(Color)
                if Fullbright.Enabled and EnabledProperties.FogColor.Enabled then
                    db = true
                    Lighting.FogColor = Color
                    db = nil
                end
            end
        })
    end)

    Run(function() -- WaterModifer
        local WaterModifier, WaterColor, WaterReflectance, WaterWaveSize, WaterWaveSpeed

        local Terrain = workspace.Terrain
        local Properties, db
        local OldValues = {}

        WaterModifier = Visuals:CreateModule({
            Name = 'WaterModifier',
            Info = 'Allows you to modify different properties of terrain water',
            Function = function(Enabled)
                if Enabled then
                    OldValues = {
                        WaterColor = Terrain.WaterColor,
                        WaterTransparency = Terrain.WaterTransparency,
                        WaterReflectance = Terrain.WaterReflectance,
                        WaterWaveSize = Terrain.WaterWaveSize,
                        WaterWaveSpeed = Terrain.WaterWaveSpeed
                    }

                    for Prop, Option in Properties do
                        OldValues[Prop] = Terrain[Prop]
                        Terrain[Prop] = Option.Value or Option.Transparency or Option.Color
                    end

                    WaterModifier:Clean(Terrain.Changed:Connect(function(Prop)
                        if OldValues[Prop] and not db then
                            db = true
                            OldValues[Prop] = Terrain[Prop]
                            local Option = Properties[Prop]
                            local Value = Option and (Option.Value or Option.Color or Option.Transparency)
                            Terrain[Prop] = Value
                            db = nil
                        end
                    end))
                else
                    db = nil
                    for Prop, Value in OldValues do
                        Terrain[Prop] = Value
                    end
                    table.clear(OldValues)
                end
            end
        })

        WaterColor = WaterModifier:CreateColorPicker({
            Name = 'Water Color',
            Default = Terrain.WaterColor,
            Function = function(Color, Transparency)
                if WaterModifier.Enabled then
                    db = true
                    Terrain.WaterColor, Terrain.WaterTransparency = Color, Transparency
                    db = nil
                end
            end
        })
        WaterReflectance = WaterModifier:CreateSlider({
            Name = 'Water Reflectance',
            Default = Terrain.WaterReflectance,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = function(Val)
                if WaterModifier.Enabled then
                    db = true
                    Terrain.WaterReflectance = Val
                    db = nil
                end
            end
        })
        WaterWaveSize = WaterModifier:CreateSlider({
            Name = 'Water Wave Size',
            Default = Terrain.WaterWaveSize,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = function(Val)
                if WaterModifier.Enabled then
                    db = true
                    Terrain.WaterWaveSize = Val
                    db = nil
                end
            end
        })
        WaterWaveSpeed = WaterModifier:CreateSlider({
            Name = 'Water Wave Speed',
            Default = Terrain.WaterWaveSpeed,
            Min = 0,
            Max = 100,
            Function = function(Val)
                if WaterModifier.Enabled then
                    db = true
                    Terrain.WaterWaveSpeed = Val
                    db = nil
                end
            end
        })

        Properties = {
            WaterColor = WaterColor,
            WaterTransparency = WaterColor,
            WaterReflectance = WaterReflectance,
            WaterWaveSize = WaterWaveSize,
            WaterWaveSpeed = WaterWaveSpeed
        }
    end)

    Run(function() -- Chams
        local Chams, OutlineColor, FillColor, Priority, NpcOutlineColor, NpcFillColor, ShowPlayers, ShowNPCs, Folder

        local Highlights = {}
        local Entities = 0

        local function EntityRemoved(Ent)
            local Tab = Highlights[Ent.Character]
            if Tab then
                Entities -= 1
                Chams:UpdateTextGUI()
                Tab.Highlight:Destroy()
                Highlights[Ent.Character] = nil
            end
        end

        local function EntityAdded(Ent)
            EntityRemoved(Ent)

            if not ShowPlayers.Enabled and Ent.Player then return end
            if not ShowNPCs.Enabled and Ent.NPC then return end
            if Priority.Value ~= 'All' then
                if (Priority.Value == 'Enemies' and Ent.Teammate) or (Priority.Value == 'Teammates' and not Ent.Teammate) or (Priority.Value == 'Friends' and not IsFriend(Ent.Player)) then
                    return
                end
            end

            Entities += 1
            Chams:UpdateTextGUI()

            local TeamColor = GetTeamColor(Ent)

            local Highlight = Instance.new('Highlight')
            Highlight.Name = `{Ent.Player and Ent.Player.Name or Ent.Character.Name}_Chams`
            Highlight.Adornee = Ent.Character
            Highlight.OutlineColor = TeamColor or (Ent.Player and OutlineColor.Color or NpcOutlineColor.Color)
            Highlight.FillColor = TeamColor or (Ent.Player and FillColor.Color or NpcFillColor.Color)
            Highlight.OutlineTransparency = (Ent.Player and OutlineColor.Transparency or NpcOutlineColor.Transparency)
            Highlight.FillTransparency = (Ent.Player and FillColor.Transparency or NpcFillColor.Transparency)
            Highlight.Parent = Folder

            Highlights[Ent.Character] = {
                Highlight = Highlight,
                Entity = Ent
            }
        end

        Chams = Visuals:CreateModule({
            Name = "Chams",
            Info = "Renders players through walls",
            Function = function(Enabled)
                if Enabled then
                    Folder = Instance.new("Folder")
                    Folder.Name = "Chams"
                    Folder.Parent = TidalWave.Gui
                    
                    Chams:Clean(EntityLib.Events.EntityAdded:Connect(EntityAdded))
                    Chams:Clean(EntityLib.Events.EntityRemoved:Connect(EntityRemoved))

                    for _, Ent in EntityLib.List do
                        EntityAdded(Ent)
                    end
                else
                    if Folder then
                        Folder:Destroy()
                        Folder = nil
                    end
                    Entities = 0
                    table.clear(Highlights)
                end
            end,
            ExtraText = function()
                return tostring(Entities)
            end
        })

        local function Restart()
            if Chams.Enabled then
                Chams:Toggle(true)
                Chams:Toggle(true)
            end
        end

        local function UpdateHighlights()
            for _, Tab in Highlights do
                local Ent = Tab.Entity
                local Highlight = Tab.Highlight
                local Player = Ent.Player
                local TeamColor = GetTeamColor(Ent)

                Highlight.OutlineColor = TeamColor or (Player and OutlineColor.Color or NpcOutlineColor.Color)
                Highlight.FillColor = TeamColor or (Player and FillColor.Color or NpcFillColor.Color)
                Highlight.OutlineTransparency = (Player and OutlineColor.Transparency or NpcOutlineColor.Transparency)
                Highlight.FillTransparency = (Player and FillColor.Transparency or NpcFillColor.Transparency)
            end
        end

        ShowPlayers = Chams:CreateToggle({
            Name = 'Players',
            Info = 'Whether or not to show players',
            Default = true,
            Function = Restart,
        })

        OutlineColor = ShowPlayers:CreateColorPicker({
            Name = "Player Outline Color",
            Function = UpdateHighlights
        })

        FillColor = ShowPlayers:CreateColorPicker({
            Name = "Player Fill Color",
            Transparency = 0.5,
            Function = UpdateHighlights
        })

        ShowNPCs = Chams:CreateToggle({
            Name = "NPCs",
            Info = "Whether or not to show NPCs",
            Function = Restart,
        })

        NpcOutlineColor = ShowNPCs:CreateColorPicker({
            Name = "NPC Outline Color",
            Function = UpdateHighlights
        })

        NpcFillColor = ShowNPCs:CreateColorPicker({
            Name = "NPC Fill Color",
            Transparency = 0.5,
            Function = UpdateHighlights
        })

        Priority = Chams:CreateDropdown({
            Name = 'Priority',
            List = {'All', 'Enemies', 'Teammates', 'Friends'},
            Function = Restart
        })
    end)

    Run(function() -- Tracers
        local Tracers, UsePlayers, UseNPCs, Thickness, Color, NPCColor, Priority, XBoxConnect, HideMainTracer, ScreenGui, TracerTarget, TracerOffsetX, TracerOffsetY, TracerOffsetZ

        local TracerOffsetVector = vector.zero
        local Entities = 0

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
                local Tracers = Tab.Tracers
                local Ent = Tab.Entity

                if HideMainTracer.Enabled then
                    Tracers.Tracer.Visible = false
                else
                    local Tracer = Tracers.Tracer
                    local Part = Ent[TracerTarget.Value] or Ent.Root
                    local Vector, OnScreen = Camera:WorldToViewportPoint(Part.Position + TracerOffsetVector)
                    if OnScreen then
                        TracerControlPoints[2] = Path2DControlPoint.new(UDim2.fromOffset(Vector.X, Vector.Y))
                        Tracer:SetControlPoints(TracerControlPoints)
                        Tracer.Visible = true
                    else
                        Tracer.Visible = false
                    end
                end

                if XBoxConnect.Enabled then
                    for RigType, Data in TracerPath[Ent.Humanoid.RigType.Name] do
                        local NewControlPoints = {}
                        local AnyCreated

                        for _, LimbData in Data do
                            local Limb = Ent.Character:FindFirstChild(LimbData[1])
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
                            table.insert(NewControlPoints, Path2DControlPoint.new(UDim2.fromOffset(LimbPos.X, LimbPos.Y)))
                            AnyCreated = true
                        end

                        local Tracer = Tracers[RigType]

                        if AnyCreated then
                            Tracer.Visible = true
                            Tracer:SetControlPoints(NewControlPoints)
                        else
                            Tracer.Visible = false
                        end
                    end
                end
            end
        end

        local function CreateTracer(Char, LimbName)
            local Line = Instance.new('Path2D')
            Line.Name = `{Char.Player and Char.Player.Name or Char.Character.Name}_{LimbName and LimbName .. '_' or ''}Tracer`
            Line.Color3 = GetTeamColor(Char) or (Char.Player and Color.Color) or NPCColor.Color
            Line.Thickness = Thickness.Value
            Line.Parent = ScreenGui

            return Line
        end

        local function EntityRemoved(Char)
            local Tab = TracerObjects[Char.Character]
            if Tab then
                Entities -= 1
                Tracers:UpdateTextGUI()
                for _, Tracer in Tab.Tracers do
                    Tracer:Destroy()
                end
                TracerObjects[Char.Character] = nil
            end
        end

        local function EntityAdded(Ent)
            EntityRemoved(Ent)

            if Ent.Player and not UsePlayers.Enabled then return end
            if Ent.NPC and not UseNPCs.Enabled then return end
            if Priority.Value ~= 'All' then
                if (Priority.Value == 'Enemies' and Ent.Teammate) or (Priority.Value == 'Teammates' and not Ent.Teammate) or (Priority.Value == 'Friends' and not IsFriend(Ent.Player)) then
                    return
                end
            end
            
            Entities += 1
            Tracers:UpdateTextGUI()

            local Tracers = {
                Tracer = CreateTracer(Ent)
            }

            for Limb in TracerPath.R15 do
                Tracers[Limb] = CreateTracer(Ent, Limb)
            end

            local Tab = {
                Entity = Ent,
                Tracers = Tracers
            }
            
            TracerObjects[Ent.Character] = Tab
        end

        local function UpdateTracers()
            if not Tracers.Enabled then return end
            for _, Tab in TracerObjects do
                local Color = GetTeamColor(Tab.Entity) or (Tab.Entity.Player and Color.Color) or NPCColor.Color
                for _, Tracer in Tab.Tracers do
                    Tracer.Color3 = Color
                    Tracer.Thickness = Thickness.Value
                end
            end
        end

        local function Restart()
            if Tracers.Enabled then
                Tracers:Toggle(true)
                Tracers:Toggle(true)
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

                    for _, Ent in EntityLib.List do
                        EntityAdded(Ent)
                    end

                    Tracers:Clean(EntityLib.Events.EntityAdded:Connect(EntityAdded))
                    Tracers:Clean(EntityLib.Events.EntityRemoved:Connect(EntityRemoved))
                    Tracers:Clean(RunService.PreRender:Connect(RenderTracers))
                else
                    if ScreenGui then
                        ScreenGui:Destroy()
                        ScreenGui = nil
                    end
                    Entities = 0
                    table.clear(TracerObjects)
                end
            end,
            ExtraText = function()
                return tostring(Entities)
            end
        })

        UsePlayers = Tracers:CreateToggle({
            Name = 'Players',
            Default = true,
            Function = Restart
        })

        Color = UsePlayers:CreateColorPicker({
            Name = 'Player Color',
            Function = UpdateTracers
        })

        UseNPCs = Tracers:CreateToggle({
            Name = 'NPCs',
            Function = Restart
        })

        NPCColor = UseNPCs:CreateColorPicker({
            Name = 'NPC Color',
            Function = UpdateTracers
        })

        Priority = Tracers:CreateDropdown({
            Name = 'Priority',
            List = {'All', 'Enemies', 'Teammates', 'Friends'},
            Function = Restart
        })

        Thickness = Tracers:CreateSlider({
            Name = "Thickness",
            Default = 1,
            Min = 1,
            Max = 5,
            Function = UpdateTracers
        })

        XBoxConnect = Tracers:CreateToggle({
            Name = "XBox Connect",
            Info = "It connects the xbox",
            Function = function(Enabled)
                if not Enabled then
                    for _, v in TracerObjects do
                        for i2, v2 in v.Tracers do
                            if i2 ~= 'Tracer' then
                                v2.Visible = false
                            end
                        end
                    end
                end
            end
        })

        HideMainTracer = XBoxConnect:CreateToggle({
            Name = 'Hide Main Tracer',
            Info = 'Hides the main tracer for if you want to only see xbox connect'
        })

        Tracers:CreateDropdown({
            Name = 'Position',
            List = {'Bottom', 'Bottom Left', 'Bottom Right', 'Top Left', 'Top', 'Top Right', 'Left', 'Middle', 'Right', 'Mouse'},
            Function = function(Val)
                TracerControlPoints[1] = PresetPositons[Val:gsub(' ', '')]
            end
        })

        TracerTarget = Tracers:CreateDropdown({
            Name = 'Tracer Target',
            List = {'Root', 'Head', 'Torso'}
        })

        TracerOffsetX = Tracers:CreateSlider({
            Name = 'Tracer Offset X',
            Default = 0,
            Min = -3,
            Max = 3,
            Decimal = 100,
            Function = function(Val)
                TracerOffsetVector = vector.create(Val, TracerOffsetY.Value, TracerOffsetZ.Value)
            end
        })

        TracerOffsetY = Tracers:CreateSlider({
            Name = 'Tracer Offset Y',
            Default = 0,
            Min = -3,
            Max = 3,
            Decimal = 100,
            Function = function(Val)
                TracerOffsetVector = vector.create(TracerOffsetX.Value, Val, TracerOffsetZ.Value)
            end
        })

        TracerOffsetZ = Tracers:CreateSlider({
            Name = 'Tracer Offset Z',
            Default = 0,
            Min = -3,
            Max = 3,
            Decimal = 100,
            Function = function(Val)
                TracerOffsetVector = vector.create(TracerOffsetX.Value, TracerOffsetY.Value, Val)
            end
        })
    end)

    Run(function() -- NameTags
        local NameTags, UsePlayers, UseNPCs, TextColor, BackgroundColor, TextSize, Font, Priority
        local ShowName, ShowDisplayName, ShowHealth, ShowHealthAsPercentage, ShowDistance, PixelsOffset, UseLimits, MinDistance, MaxDistance
        local Folder
        local Entities = 0

        local NameTagObjects = {}

        local function EntityRemoved(Ent)
            local Player = NameTagObjects[Ent.Character]
            if Player then
                Entities -= 1
                NameTags:UpdateTextGUI()
                Player.NameTag:Destroy()
                NameTagObjects[Ent.Character] = nil
            end
        end

        local function EntityAdded(Ent)
            EntityRemoved(Ent)

            if Ent.Player and not UsePlayers.Enabled then return end
            if Ent.NPC and not UseNPCs.Enabled then return end
            if Priority.Value ~= 'All' then
                if (Priority.Value == 'Enemies' and Ent.Teammate) or (Priority.Value == 'Teammates' and not Ent.Teammate) or (Priority.Value == 'Friends' and not IsFriend(Ent.Player)) then
                    return
                end
            end

            Entities += 1
            NameTags:UpdateTextGUI()

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Active = false
            TextLabel.Interactable = false
            TextLabel.Name = `{Ent.Player and Ent.Player.Name or Ent.Character.Name}_NameTag`
            TextLabel.BorderSizePixel = 0
            TextLabel.BackgroundColor3 = BackgroundColor.Color
            TextLabel.BackgroundTransparency = BackgroundColor.Transparency
            TextLabel.TextColor3 = GetTeamColor(Ent) or TextColor.Color
            TextLabel.TextTransparency = TextColor.Transparency
            TextLabel.TextSize = TextSize.Value
            TextLabel.FontFace = Font.Font
            TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel.RichText = true
            TextLabel.ZIndex = 0
            TextLabel.Parent = Folder

            NameTagObjects[Ent.Character] = {NameTag = TextLabel, Entity = Ent}

            return TextLabel
        end

        local StudsOffsetVector = vector.create(0, 0.5, 0)

        local function RenderNameTags()
            for _, Tab in NameTagObjects do
                local NameTag = Tab.NameTag

                if EntityLib.Alive and UseLimits.Enabled then
                    local Magnitude = vector.magnitude(EntityLib.Root.Position - Tab.Entity.Root.Position)
                    if Magnitude > MaxDistance.Value or Magnitude < MinDistance.Value then
                        NameTag.Visible = false
                        continue
                    end
                end
                local HeadPos, HeadOnScreen = Camera:WorldToViewportPoint(Tab.Entity.Head.Position + StudsOffsetVector)
                if HeadOnScreen then
                    local Text = ''
                    local Player = Tab.Entity.Player
                    local Character = Tab.Entity.Character
                    if ShowDistance.Enabled and EntityLib.Alive then
                        Text ..= `[<font color = 'rgb(255, 255, 255)'>{math.floor(vector.magnitude(EntityLib.Root.Position - Tab.Entity.Root.Position))}</font>]`
                    end
                    if ShowName.Enabled and ShowDisplayName.Enabled then
                        Text ..= `{Text == '' and '' or ' '}{Player and GetFullPlayerName(Player) or Character.Name}`
                    elseif ShowName.Enabled then
                        Text ..= `{Text == '' and '' or ' '}{Player and Player.Name or Character.Name}`
                    elseif ShowDisplayName.Enabled then
                        Text ..= `{Text == '' and '' or ' '}{Player and Player.DisplayName or Character.Name}`
                    end
                    if ShowHealth.Enabled then
                        local Percentage = (Tab.Entity.Health or 100) / (Tab.Entity.MaxHealth or 100)
                        local HealthColor = Color3.fromHSV((1 / 3) * Percentage, 1, 1)
                        local Health = math.floor(ShowHealthAsPercentage.Enabled and Percentage * 100 or Tab.Entity.Health or 100)
                        Text ..= `{Text == '' and '' or ' '}<font color = '#{HealthColor:ToHex()}'>{Health}{ShowHealthAsPercentage.Enabled and '%' or ''}</font>`
                    end
                    
                    local TextBounds = GetTextBounds(Text, TextSize.Value, Font.Font)
                    NameTag.Text = Text
                    NameTag.Size = UDim2.fromOffset(TextBounds.X + 8, TextBounds.Y + 8)
                    NameTag.Position = UDim2.fromOffset(HeadPos.X, HeadPos.Y - PixelsOffset.Value)
                    NameTag.Visible = true
                else
                    NameTag.Visible = false
                end
            end
        end

        NameTags = Visuals:CreateModule({
            Name = "NameTags",
            Function = function(Enabled)
                if Enabled then
                    Folder = Instance.new('Folder')
                    Folder.Name = 'NameTags'
                    Folder.Parent = TidalWave.Gui

                    NameTags:Clean(RunService.PreRender:Connect(RenderNameTags))
                    NameTags:Clean(EntityLib.Events.EntityAdded:Connect(EntityAdded))
                    NameTags:Clean(EntityLib.Events.EntityRemoved:Connect(EntityRemoved))

                    for _, Ent in EntityLib.List do
                        EntityAdded(Ent)
                    end
                else
                    if Folder then
                        Folder:Destroy()
                        Folder = nil
                    end
                    Entities = 0
                    table.clear(NameTagObjects)
                end
            end,
            ExtraText = function()
                return tostring(Entities)
            end
        })

        local function Update()
            if not NameTags.Enabled then return end
            for _, Tab in NameTagObjects do
                local NameTag = Tab.NameTag
                local Ent = Tab.Entity

                NameTag.BackgroundTransparency = BackgroundColor.Transparency
                NameTag.BackgroundColor3 = BackgroundColor.Color
                NameTag.TextColor3 = GetTeamColor(Ent) or TextColor.Color
                NameTag.TextTransparency = TextColor.Transparency
                NameTag.TextSize = TextSize.Value
                NameTag.FontFace = Font.Font
            end
        end

        TextSize = NameTags:CreateSlider({
            Name = "Text Size",
            Default = 16,
            Min = 8,
            Max = 32,
            Function = Update
        })

        Font = NameTags:CreateFont({
            Name = 'Font',
            Function = Update
        })

        TextColor = NameTags:CreateColorPicker({
            Name = "Text Color",
            Default = Color3.White,
            Function = Update
        })

        BackgroundColor = NameTags:CreateColorPicker({
            Name = "Background Color",
            Default = Color3.Black,
            Transparency = 0.5,
            Function = Update
        })

        NameTags:CreateSlider({
            Name = "Studs Offset",
            Default = 1,
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

        local function Restart()
            if NameTags.Enabled then
                NameTags:Toggle(true)
                NameTags:Toggle(true)
            end
        end

        UsePlayers = NameTags:CreateToggle({
            Name = "Players",
            Info = "Whether or not to show players",
            Default = true,
            Function = Restart
        })

        UseNPCs = NameTags:CreateToggle({
            Name = "NPCs",
            Info = "Whether or not to show NPCs",
            Function = Restart
        })

        Priority = NameTags:CreateDropdown({
            Name = 'Priority',
            List = {'All', 'Enemies', 'Teammates', 'Friends'},
            Function = Restart
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
            Default = true
        })

        ShowHealthAsPercentage = ShowHealth:CreateToggle({
            Name = 'Show Health As Percentage'
        })

        ShowDistance = NameTags:CreateToggle({
            Name = "Distance"
        })

        UseLimits = NameTags:CreateToggle({
            Name = 'Use Limits',
            Info = 'Sets the minimum and maximum distance to render nametags within',
        })

        MinDistance = UseLimits:CreateSlider({
            Name = 'Min Distance',
            Default = 0,
            Min = 0,
            Max = 40
        })

        MaxDistance = UseLimits:CreateSlider({
            Name = 'Max Distance',
            Default = 1000,
            Min = 100,
            Max = 1000
        })
    end)

    Run(function() -- BoxESP
        local BoxESP, FillColor, OutlineColor, Thickness, UsePlayers, UseNPCs, Priority, Folder, SizeX, SizeY

        local Frames = {}
        local Entities = 0

        local function EntityRemoved(Ent)
            local Box = Frames[Ent.Character]
            if Box then
                Entities -= 1
                BoxESP:UpdateTextGUI()
                Box.Frame:Destroy()
                Frames[Ent.Character] = nil
            end
        end

        local function EntityAdded(Ent)
            EntityRemoved(Ent)

            if Ent.Player and not UsePlayers.Enabled then return end
            if Ent.NPC and not UseNPCs.Enabled then return end
            if Priority.Value ~= 'All' then
                if (Priority.Value == 'Enemies' and Ent.Teammate) or (Priority.Value == 'Teammates' and not Ent.Teammate) or (Priority.Value == 'Friends' and not IsFriend(Ent.Player)) then
                    return
                end
            end
            
            Entities += 1
            BoxESP:UpdateTextGUI()

            local Box = Instance.new("Frame")
            Box.BackgroundColor3 = FillColor.Color
            Box.BackgroundTransparency = FillColor.Transparency
            Box.Active = false
            Box.Interactable = false
            Box.Name = `{Ent.Player and Ent.Player.Name or Ent.Character.Name}_BoxESP`
            Box.AnchorPoint = Vector2.new(0.5, 0.5)
            Box.ZIndex = 0
            Box.BorderSizePixel = 0
            Box.Parent = Folder
            
            local UIStroke = Instance.new("UIStroke")
            UIStroke.Thickness = Thickness.Value
            UIStroke.Color = GetTeamColor(Ent) or OutlineColor.Color
            UIStroke.Transparency = OutlineColor.Transparency
            UIStroke.LineJoinMode = Enum.LineJoinMode.Miter
            UIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
            UIStroke.Parent = Box

            Frames[Ent.Character] = {
                Frame = Box,
                Entity = Ent
            }
        end

        BoxESP = Visuals:CreateModule({
            Name = "BoxESP",
            Function = function(Enabled)
                if Enabled then
                    Folder = Instance.new("Folder")
                    Folder.Name = "BoxESP"
                    Folder.Parent = TidalWave.Gui

                    BoxESP:Clean(Folder)
                    BoxESP:Clean(EntityLib.Events.EntityAdded:Connect(EntityAdded))
                    BoxESP:Clean(EntityLib.Events.EntityRemoved:Connect(EntityRemoved))
                    for _, Ent in EntityLib.List do
                        EntityAdded(Ent)
                    end

                    BoxESP:Clean(RunService.PreRender:Connect(function()
                        for _, Tab in Frames do
                            local Box = Tab.Frame
                            local Outline = Box.UIStroke
                            local RootPos, RootOnScreen = Camera:WorldToViewportPoint(Tab.Entity.Root.Position)

                            if RootOnScreen then
                                Box.Size = UDim2.fromOffset(((134400 * SizeX.Value) / Camera.FieldOfView) / RootPos.Z, ((134400 * SizeY.Value) / Camera.FieldOfView) / RootPos.Z)
                                Box.Position = UDim2.fromOffset(RootPos.X, RootPos.Y)
                                Outline.Thickness = Thickness.Value
                                Outline.Enabled = true
                            else
                                Outline.Enabled = false
                            end
                        end
                    end))
                else
                    Entities = 0
                    Folder = nil
                    table.clear(Frames)
                end
            end,
            ExtraText = function()
                return tostring(Entities)
            end
        })

        Thickness = BoxESP:CreateSlider({
            Name = "Box Thickness",
            Default = 1,
            Min = 1,
            Max = 5,
        })

        OutlineColor = BoxESP:CreateColorPicker({
            Name = "Outline Color",
            Default = Color3.fromRGB(255, 255, 255),
            Function = function(Color, Transparency)
                for _, Tab in Frames do
                    Tab.Frame.UIStroke.Color = GetTeamColor(Tab.Entity) or Color
                    Tab.Frame.UIStroke.Transparency = Transparency
                end
            end,
        })

        FillColor = BoxESP:CreateColorPicker({
            Name = 'Fill Color',
            Transparency = 1,
            Function = function(Color, Transparency)
                for _, Tab in Frames do
                    Tab.Frame.BackgroundColor3 = GetTeamColor(Tab.Entity) or Color
                    Tab.Frame.BackgroundTransparency = Transparency
                end
            end
        })

        local function Restart()
            if BoxESP.Enabled then
                BoxESP:Toggle(true)
                BoxESP:Toggle(true)
            end
        end

        Priority = BoxESP:CreateDropdown({
            Name = 'Priority',
            List = {'All', 'Enemies', 'Teammates', 'Friends'},
            Function = Restart
        })

        UsePlayers = BoxESP:CreateToggle({
            Name = "Players",
            Info = "Whether or not to show players",
            Default = true,
            Function = Restart
        })

        UseNPCs = BoxESP:CreateToggle({
            Name = "NPCs",
            Info = "Whether or not to show NPCs",
            Function = Restart
        })

        SizeX = BoxESP:CreateSlider({
            Name = "X Size",
            Default = 1.5,
            Min = 0,
            Max = 3,
            Decimal = 100,
        })

        SizeY = BoxESP:CreateSlider({
            Name = "Y Size",
            Default = 2.5,
            Min = 0,
            Max = 3,
            Decimal = 100,
        })
    end)

    Run(function() -- ViewportChams
        local ViewportChams, ViewportFrame, ViewportModel, Color, Priority, ShowPlayers, ShowNPCs

        local Models = {}
        local Parts = {}
        local OtherObjects = {}
        local Entities = 0

        local Blacklist = {
            Status = true,
            LocalScript = true,
            Script = true,
            ModuleScript = true,
            TouchTransmitter = true,
            Sound = true
        }

        local function CharacterRemoved(Char)
            if Models[Char.Character] then
                Entities -= 1
                ViewportChams:UpdateTextGUI()
                Models[Char.Character]:Destroy()
                Models[Char.Character] = nil
            end
        end

        local function CharacterAdded(Char)
            CharacterRemoved(Char)
            if Char.Player and not ShowPlayers.Enabled then return end
            if Char.NPC and not ShowNPCs.Enabled then return end
            if Priority.Value ~= 'All' then
                if (Priority.Value == 'Enemies' and Char.Teammate) or (Priority.Value == 'Teammates' and not Char.Teammate) or (Priority.Value == 'Friends' and not IsFriend(Char.Player)) then
                    return
                end
            end

            Entities += 1
            ViewportChams:UpdateTextGUI()

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

            local Model = Instance.new('Model')
            Model.Name = (Char.Player and Char.Player.Name or Char.Character.Name) .. '_Chams'
            Model.Parent = ViewportModel

            Recursive(Char.Character, Model)

            ViewportChams:Clean(Char.Character.DescendantAdded:Connect(function(Child)
                if Blacklist[Child.ClassName] then return end
                local NewClone = Instance.fromExisting(Child)
                if Child:IsA('BasePart') then
                    Parts[Child] = NewClone
                else
                    OtherObjects[Child] = NewClone
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
                
                NewClone.Parent = Parent or Model
            end))

            ViewportChams:Clean(Char.Character.DescendantRemoving:Connect(function(Child)
                if Blacklist[Child.ClassName] then return end
                if Parts[Child] then
                    Parts[Child]:Destroy()
                    Parts[Child] = nil
                elseif OtherObjects[Child] then
                    OtherObjects[Child]:Destroy()
                    OtherObjects[Child] = nil
                end
            end))

            Models[Char.Character] = Model
        end

        ViewportChams = Visuals:CreateModule({
            Name = "ViewportChams",
            Info = "Renders players through walls using viewport frames.\nMay cause lag spikes when characters are being added",
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
                    ViewportFrame.ZIndex = -1
                    ViewportFrame.Parent = TidalWave.Gui

                    ViewportModel = Instance.new('WorldModel')
                    ViewportModel.Name = 'ChamsWorldModel'
                    ViewportModel.Parent = ViewportFrame
                    
                    ViewportChams:Clean(EntityLib.Events.EntityAdded:Connect(CharacterAdded))
                    ViewportChams:Clean(EntityLib.Events.EntityRemoved:Connect(CharacterRemoved))
                    for _, Character in EntityLib.List do
                        CharacterAdded(Character)
                    end

                    ViewportChams:Clean(RunService.PreRender:Connect(function()
                        for Part, Clone in Parts do
                            Clone.CFrame = Part.CFrame
                        end
                    end))
                else
                    Entities = 0
                    ViewportFrame:Destroy()
                    ViewportFrame = nil
                    table.clear(Parts)
                    table.clear(OtherObjects)
                    table.clear(Models)
                end
            end,
            ExtraText = function()
                return tostring(Entities)
            end
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

        local function Restart()
            if ViewportChams.Enabled then
                ViewportChams:Toggle(true)
                ViewportChams:Toggle(true)
            end
        end

        ShowPlayers = ViewportChams:CreateToggle({
            Name = 'Players',
            Info = 'Whether or not to show players',
            Default = true,
            Function = Restart
        })

        ShowNPCs = ViewportChams:CreateToggle({
            Name = 'NPCs',
            Info = 'Whether or not to show NPCs',
            Function = Restart
        })

        Priority = ViewportChams:CreateDropdown({
            Name = 'Priority',
            List = {'All', 'Enemies', 'Teammates', 'Friends'},
            Function = Restart
        })
    end)

    Run(function() -- PartESP
        local PartESP, NameCheckMethod, HighlightType, OutlineColor, FillColor, SearchMethod, Names, FilterType

        local DepthMode
        local Shading, ModelSizeMode

        local Folder, Path
        local Highlights = {}
        local Boxes = {}

        local function GetSize(Part)
            if Part:IsA('Model') then
                if ModelSizeMode.Value == 'ExtentsSize' or Part.PrimaryPart == nil then
                    return Part:GetExtentsSize()
                else
                    return Part.PrimaryPart.Size
                end
            else
                return Part.Size
            end
        end

        local function HighlightPart(Part)
            if HighlightType.Value == 'Highlight' then
                local Highlight = Instance.new('Highlight')
                Highlight.Name = `{Part.Name}_ESP`
                Highlight.OutlineColor = OutlineColor.Color
                Highlight.FillColor = FillColor.Color
                Highlight.OutlineTransparency = OutlineColor.Transparency
                Highlight.FillTransparency = FillColor.Transparency
                Highlight.DepthMode = Enum.HighlightDepthMode[DepthMode.Value]
                Highlight.Adornee = Part
                Highlight.Parent = Folder

                Highlights[Highlight] = {}
            else
                local Box = Instance.new('BoxHandleAdornment')
                Box.Shading = Enum.AdornShading[Shading.Value]
                Box.Size = GetSize(Part)
                Box.Name = `{Part.Name}_ESP`
                Box.Color3 = FillColor.Color
                Box.Transparency = FillColor.Transparency
                Box.Adornee = Part
                Box.ZIndex = 1
                Box.Parent = Folder

                Boxes[Box] = {
                    PartESP:Clean(Part.ChildAdded:Connect(function(Child)
                        if Child:IsA('BasePart') then
                            Box.Size = GetSize(Part)
                        end
                    end)),
                    PartESP:Clean(Part.ChildRemoved:Connect(function(Child)
                        if Child:IsA('BasePart') then
                            Box.Size = GetSize(Part)
                        end
                    end))
                }
            end
        end

        local function NameCheck(Child)
            if FilterType.Value == 'None' then return true end
            local Name = Child.Name:lower()
            for _, v in Names.Enabled do
                local ListName = v:lower()
                if NameCheckMethod.Value == 'Exact Name' then
                    return if FilterType.Value == 'Include' then Name:sub(1, #ListName) == Name else Name:sub(1, #ListName) ~= Name
                else
                    return if FilterType == 'Include' then Name:match(ListName) else not Name:match(ListName)
                end
            end
            return false
        end

        local function ChildRemoved(Child)
            for Highlight, Tab in Highlights do
                if Highlight.Adornee == Child then
                    Highlight:Destroy()
                    for _, Connection in Tab do
                        Connection:Disconnect()
                    end
                    table.clear(Tab)
                    Highlights[Highlight] = nil
                    break
                end
            end

            for Box, Tab in Boxes do
                if Box.Adornee == Child then
                    Box:Destroy()
                    for _, Connection in Tab do
                        Connection:Disconnect()
                    end
                    table.clear(Tab)
                    Boxes[Box] = nil
                    break
                end
            end
        end

        local function Loop(Obj)
            for _, v in Obj:GetChildren() do
                if v:IsA('Folder') then
                    Loop(v)
                elseif (v:IsA('BasePart') or v:IsA('Model')) and NameCheck(v) then
                    HighlightPart(v)
                end
            end

            PartESP:Clean(Obj.ChildAdded:Connect(function(Child)
                if Child:IsA('Model') or Child:IsA('BasePart') then
                    if NameCheck(Child) then
                        HighlightPart(Child)
                    end
                end
            end))
            
            PartESP:Clean(Obj.ChildRemoved:Connect(function(Child)
                if Child:IsA('Model') or Child:IsA('BasePart') then
                    ChildRemoved(Child)
                end
            end))
        end

        PartESP = Visuals:CreateModule({
            Name = 'PartESP',
            Function = function(Enabled)
                if Enabled then
                    Folder = Instance.new('Folder')
                    Folder.Name = 'PartESP'
                    Folder.Parent = TidalWave.Gui

                    local RootPath = Path or workspace

                    if SearchMethod.Value == 'Children' then
                        Loop(RootPath)
                    else
                        for _, v in RootPath:QueryDescendants('BasePart, Model') do
                            if NameCheck(v) then
                                HighlightPart(v)
                            end
                        end
                        PartESP:Clean(RootPath.DescendantAdded:Connect(function(Child)
                            if Child:IsA('BasePart') or Child:IsA('Model') then
                                if NameCheck(Child) then
                                    HighlightPart(Child)
                                end
                            end
                        end))
                        PartESP:Clean(RootPath.DescendantRemoving:Connect(function(Child)
                            if Child:IsA('Model') or Child:IsA('BasePart') then
                                ChildRemoved(Child)
                            end
                        end))
                    end
                else
                    Folder:Destroy()
                    Folder = nil
                    table.clear(Highlights)
                    table.clear(Boxes)
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
            for Highlight in Highlights do
                Highlight.OutlineColor = OutlineColor.Color
                Highlight.FillColor = FillColor.Color
                Highlight.OutlineTransparency = OutlineColor.Transparency
                Highlight.FillTransparency = FillColor.Transparency
            end
            for Box in Boxes do
                Box.Color3 = FillColor.Color
                Box.Transparency = FillColor.Transparency
            end
        end

        HighlightType = PartESP:CreateDropdown({
            Name = 'Highlight Type',
            List = {'Highlight', 'BoxHandle'},
            Function = function(Val)
                DepthMode:SetVisible(Val == 'Highlight')
                OutlineColor:SetVisible(Val == 'Highlight')
                FillColor:SetVisible(Val == 'Highlight')
                Shading:SetVisible(Val ~= 'Highlight')
                OutlineColor:SetVisible(Val == 'Highlight')
                ModelSizeMode:SetVisible(Val ~= 'Highlight')
                Restart()
            end
        })

        Shading = PartESP:CreateDropdown({
            Name = 'Shading',
            List = {'AlwaysOnTop', 'Default', 'Shaded', 'XRay', 'XRayShaded'},
            Visible = false,
            Function = function(Val)
                for _, v in Highlights do
                    v.Shading = Enum.AdornShading[Val]
                end
            end,
        })

        ModelSizeMode = PartESP:CreateDropdown({
            Name = 'Model Size Mode',
            List = {'ExtentsSize', 'PrimaryPart'},
            Visible = false,
            Function = function(Val)
                for Box in Boxes do
                    Box.Size = Val == 'PrimaryPart' and Box.Adornee.Size or GetSize(Box.Adornee)
                end
            end
        })

        DepthMode = PartESP:CreateDropdown({
            Name = 'Depth Mode',
            List = {'AlwaysOnTop', 'Occluded'},
            Function = function(Val)
                for _, Highlight in Highlights do
                    Highlight.DepthMode = Enum.HighlightDepthMode[Val]
                end
            end,
        })

        OutlineColor = PartESP:CreateColorPicker({
            Name = 'Outline Color',
            Function = UpdateColors
        })

        FillColor = PartESP:CreateColorPicker({
            Name = 'Fill Color',
            Transparency = 0.5,
            Function = UpdateColors
        })

        PartESP:CreateTextBox({
            Name = 'Folder Path',
            PlaceholderText = 'Enter path',
            Function = function(Text, Loaded)
                if Text:match('%w+') then
                    local Function = loadstring(`return {Text}`)
                    if typeof(Function) == 'function' then
                        local Success, Result = pcall(Function)
                        if Success and typeof(Result) == 'Instance' then
                            Path = Result
                            if Loaded then return end
                            Notify({
                                Text = `Set Object to {GetFullName(Path)}`,
                                Duration = 5
                            })
                        else
                            Path = nil
                            if Loaded then return end
                            Notify({
                                Text = Result,
                                Duration = 10,
                                Type = 'Error'
                            })
                        end
                    else
                        Notify({
                            Text = Function,
                            Duration = 10,
                            Type = 'Error'
                        })
                    end
                else
                    Path = nil
                end
            end
        })

        SearchMethod = PartESP:CreateDropdown({
            Name = 'Search Method',
            List = {'Children', 'Descendants'},
            Function = Restart
        })

        FilterType = PartESP:CreateDropdown({
            Name = 'Filter Type',
            List = {'None', 'Include', 'Exclude'},
            Function = function(Val)
                Names:SetVisible(Val ~= 'None')
                NameCheckMethod:SetVisible(Val ~= 'None')
            end
        })

        NameCheckMethod = PartESP:CreateDropdown({
            Name = 'Name Method',
            List = {'Exact Name', 'Contains String'},
            Visible = false,
            Function = Restart
        })

        Names = PartESP:CreateTextList({
            Name = 'Names',
            Visible = false,
            Function = Restart
        })
    end)

    Run(function() -- FovChanger
        local FovChanger, Fov, db

        local OldFov = Camera.FieldOfView

        FovChanger = Visuals:CreateModule({
            Name = "FovChanger",
            Info = "Sets your field of view to the specified value",
            Function = function(Enabled)
                if Enabled then
                    OldFov = Camera.FieldOfView
                    Camera.FieldOfView = Fov.Value

                    FovChanger:Clean(Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
                        if db then return end
                        db = true
                        OldFov = Camera.FieldOfView
                        Camera.FieldOfView = Fov.Value
                        db = nil
                    end))
                else
                    if OldFov then
                        Camera.FieldOfView = OldFov
                        OldFov = nil
                    end
                    
                end
            end,
            ExtraText = function()
                return tostring(Fov.Value)
            end
        })

        function FovChanger:Enable()
            db = nil
        end

        function FovChanger:Disable()
            db = true
        end

        Fov = FovChanger:CreateSlider({
            Name = "Field Of View",
            Default = math.floor(Camera.FieldOfView),
            Min = 1,
            Max = 120,
            Function = function(Val)
                if FovChanger.Enabled then
                    db = true
                    Camera.FieldOfView = Val
                    db = nil
                    FovChanger:UpdateTextGUI()
                end
            end
        })
    end)

    Run(function() -- CameraZoom
        local CameraZoom, MinZoom, MaxZoom
        local db, db2

        CameraZoom = Visuals:CreateModule({
            Name = "CameraZoom",
            Info = "Loop Sets Camera Min Zoom And Max Zoom",
            Function = function(Enabled)
                local OldMinZoom, OldMaxZoom = Plr.CameraMinZoomDistance, Plr.CameraMaxZoomDistance
                Plr.CameraMaxZoomDistance, Plr.CameraMinZoomDistance = MaxZoom.Value, MinZoom.Value
                CameraZoom:Clean(Plr:GetPropertyChangedSignal("CameraMinZoomDistance"):Connect(function()
                    if db then return end
                    db = true
                    OldMinZoom = Plr.CameraMinZoomDistance
                    Plr.CameraMinZoomDistance = MinZoom.Value
                    db = nil
                end))
                CameraZoom:Clean(Plr:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
                    if db2 then return end
                    db2 = true
                    OldMaxZoom = Plr.CameraMaxZoomDistance
                    Plr.CameraMaxZoomDistance = MaxZoom.Value
                    db2 = nil
                end))
                CameraZoom:Clean(function()
                    Plr.CameraMinZoomDistance = OldMinZoom
                    Plr.CameraMaxZoomDistance = OldMaxZoom
                end)
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
                    db = true
                    Plr.CameraMinZoomDistance = Val
                    db = nil
                end
            end
        })

        MaxZoom = CameraZoom:CreateSlider({
            Name = "Max Zoom",
            Default = math.floor(Plr.CameraMaxZoomDistance * 10) / 10,
            Min = 1,
            Max = 1000,
            Function = function(Val)
                if CameraZoom.Enabled then
                    db2 = true
                    Plr.CameraMaxZoomDistance = Val
                    db2 = nil
                end
            end
        })
    end)

    Run(function() -- CameraMode
        local CameraMode, Mode
        local db, OldCameraMode

        local CameraModes = {
            ['First Person'] = Enum.CameraMode.LockFirstPerson,
            ['Third Person'] = Enum.CameraMode.Classic
        }

        CameraMode = Visuals:CreateModule({
            Name = "CameraMode",
            Info = "Sets your camera to third/first person",
            Function = function(Enabled)
                if Enabled then
                    OldCameraMode = Plr.CameraMode
                    Plr.CameraMode = CameraModes[Mode.Value]
                    CameraMode:Clean(Plr:GetPropertyChangedSignal("CameraMode"):Connect(function()
                        if db then return end
                        db = true
                        OldCameraMode = Plr.CameraMode
                        Plr.CameraMode = CameraModes[Mode.Value]
                        db = nil
                    end))
                elseif OldCameraMode then
                    Plr.CameraMode = OldCameraMode
                    OldCameraMode = nil
                end
            end
        })

        Mode = CameraMode:CreateDropdown({
            Name = "Camera Mode",
            List = {"Third Person", "First Person"},
            Function = function(Val)
                if CameraMode.Enabled then
                    db = true
                    Plr.CameraMode = CameraModes[Val]
                    db = nil
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

        AntiLag = Visuals:CreateModule({
            Name = 'AntiLag',
            Info = 'Removes lots of diffent details to increase FPS',
            Function = function(Enabled)
                if Enabled then
                    local Children = workspace:QueryDescendants('Part, MeshPart, SpawnLocation, Seat, VehicleSeat, UnionOperation, NegateOperation, IntersectOperation, Decal, Texture, ParticleEmitter, Trail, Explosion, Sparkles, Smoke, Fire, ForceField')
                    local Index = table.find(Children, workspace.Terrain)
                    if Index then
                        table.remove(Children, Index) -- Removing terrain because it's a base part apparently
                    end
                    for _, v in Children do
                        local Function = Functions[v.ClassName]
                        if Function then
                            Function(v)
                        end 
                    end

                    AntiLag:Clean(workspace.DescendantAdded:Connect(function(Descendant)
                        local Function = Functions[Descendant.ClassName]
                        if Function then
                            task.delay(0, Function, Descendant)
                        end
                    end))
                    AntiLag:Clean(workspace.DescendantRemoving:Connect(function(Descendant)
                        if Objects[Descendant] then
                            Objects[Descendant] = nil
                        end
                    end))
                else
                    for Obj, Properties in Objects do
                        for Property, OldValue in Properties do
                            Obj[Property] = OldValue
                        end
                    end
                    table.clear(Objects)
                end
            end
        })
    end)

    Run(function() -- Xray
        local Xray, Transparency, FilterType, Filter, Path

        local Modified = {}

        local function DescendantAdded(Part)
            if Part:IsA('BasePart') then
                if not Part.Parent then
                    local TimeOut = os.clock() + 5
                    repeat
                        task.wait()
                    until Part.Parent or os.clock() >= TimeOut or not Xray.Enabled

                    if not Part.Parent or not Xray.Enabled then return end
                end

                if Part.Parent.ClassName == 'Model' and Players:GetPlayerFromCharacter(Part.Parent) then return end

                if FilterType.Value == 'None' or (FilterType.Value == 'Include' and not Filter:Find(Part.Name)) or (FilterType.Value == 'Exclude' and Filter:Find(Part.Name)) then
                    Modified[Part] = Part.LocalTransparencyModifier
                    Part.LocalTransparencyModifier = Transparency.Value
                end
            end
        end
            
        Xray = Visuals:CreateModule({
            Name = "Xray",
            Info = "Makes parts transparent",
            Function = function(Enabled)
                if Enabled then
                    for _, Part in workspace:QueryDescendants('BasePart') do
                        task.spawn(DescendantAdded, Part)
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
            Info = 'The folder/model to look through',
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

    Run(function() -- Cape
        local Cape, Texture, Part, Motor

        local function CreateMotor()
            if Motor then
                Motor:Destroy()
                Motor = nil
            end

            local Part1 = EntityLib.Torso or EntityLib.Root

            Part.Parent = Camera
            Motor = Instance.new('Motor6D')
            Motor.MaxVelocity = 0.08
            Motor.Part0 = Part
            Motor.Part1 = Part1
            Motor.C0 = CFrame.new(0, 2, 0) * CFrame.Angles(0, math.rad(-90), 0)
            Motor.C1 = CFrame.new(0, Part1.Size.Y / 2, 0.45) * CFrame.Angles(0, math.rad(90), 0)
            Motor.Parent = Part
        end

        Cape = Visuals:CreateModule({
            Name = 'Cape',
            Info = 'Add\'s a cool cape to your character',
            Function = function(Enabled)
                if Enabled then
                    Part = Instance.new('Part')
                    Part.Size = vector.create(2, 4, 0.1)
                    Part.CanCollide = false
                    Part.CanQuery = false
                    Part.CastShadow = false
                    Part.AudioCanCollide = false
                    Part.Massless = true
                    Part.Material = Enum.Material.SmoothPlastic
                    Part.Color = Color3.Black
                    Part.Parent = Camera

                    if EntityLib.Alive then
                        CreateMotor()
                    end
                    
                    local SurfaceGui = Instance.new('SurfaceGui')
                    SurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
                    SurfaceGui.Adornee = Part
                    SurfaceGui.Parent = Part

                    if Texture.Text:find('.webm') then
                        local VideoFrame = Instance.new('VideoFrame')
                        VideoFrame.Video = getcustomasset(Texture.Text)
                        VideoFrame.Size = UDim2.fromScale(1, 1)
                        VideoFrame.BackgroundTransparency = 1
                        VideoFrame.Looped = true
                        VideoFrame.Parent = SurfaceGui
                        VideoFrame:Play()
                    else
                        local Image = Instance.new('ImageLabel')
                        Image.Image = Texture.Text ~= '' and (Texture.Text:find('rbxassetid://%d+') and Texture.Text or getcustomasset(Texture.Text)) or 'rbxassetid://14637958134'
                        Image.Size = UDim2.fromScale(1, 1)
                        Image.BackgroundTransparency = 1
                        Image.Parent = SurfaceGui
                    end

                    local math_rad_6 = math.rad(6)

                    Cape:Clean(EntityLib.Events.LocalAdded:Connect(CreateMotor))
                    Cape:Clean(RunService.PreRender:Connect(function()
                        if EntityLib.Alive and Motor then
                            local Vel = math.min(vector.magnitude(EntityLib.Root.AssemblyLinearVelocity), 90)
                            Motor.DesiredAngle = math_rad_6 + math.rad(Vel) + (Vel > 1 and math.abs(math.cos(os.clock() * 5)) / 3 or 0)
                        end
                        local ThirdPerson = vector.magnitude(Camera.CFrame.Position - Camera.Focus.Position) > 0.6
                        SurfaceGui.Enabled = ThirdPerson
                        Part.Transparency = ThirdPerson and 0 or 1
                    end))
                else
                    if Part then
                        Part:Destroy()
                        Part = nil
                    end
                    if Motor then
                        Motor:Destroy()
                        Motor = nil
                    end
                end
            end,
        })

        Texture = Cape:CreateTextBox({
            Name = 'Texture',
            Placeholder = '[rbxassetid://12345 | coolimage.png',
            Function = function()
                if Cape.Enabled then
                    Cape:Toggle(true)
                    Cape:Toggle(true)
                end
            end
        })
    end)

    Run(function() -- Viewmodel
        local Viewmodel, X, Y, Z, RotationX, RotationY, RotationZ
        local OldTool, Handle

        local cf, Rotation

        local function ToolAdded(Tool)
            local TimeOut = os.clock() + 3
            repeat
                Handle = Tool:FindFirstChild('Handle')
            until Handle or not Viewmodel.Enabled or os.clock() >= TimeOut

            if not (Viewmodel.Enabled and Handle) then return end

            OldTool = Tool

            ViewmodelTool = Instance.fromExisting(Handle)
            ViewmodelTool.CanCollide = false
            ViewmodelTool.Massless = true
            ViewmodelTool.Anchored = true
            ViewmodelTool.Parent = Camera

            local Mesh = Handle:FindFirstChildWhichIsA('DataModelMesh')

            if Mesh then
                Instance.fromExisting(Mesh).Parent = ViewmodelTool
            end

            Handle.LocalTransparencyModifier = 1
        end

        local function LocalAdded()
            local Tool = EntityLib.Character:FindFirstChildWhichIsA('Tool', true)

            if Tool then
                ToolAdded(Tool)
            end

            Viewmodel:Clean(EntityLib.Character.DescendantAdded:Connect(function(Tool)
                if Tool:IsA('Tool') then
                    ToolAdded(Tool)
                end
            end))
            
            Viewmodel:Clean(EntityLib.Character.DescendantRemoving:Connect(function(Obj)
                if Obj == OldTool then 
                    ViewmodelTool:Destroy()
                    ViewmodelTool = nil
                    OldTool = nil
                    Handle = nil
                end
            end))
        end

        local function LocalRemoved()
            if ViewmodelTool then
                ViewmodelTool:Destroy()
                ViewmodelTool = nil
            end
            OldTool = nil
            Handle = nil
        end
        
        Viewmodel = Visuals:CreateModule({
            Name = 'Viewmodel',
            Info = 'Replaces the default viewmodel',
            Function = function(Enabled)
                if Enabled then
                    ViewmodelMotor = Instance.new('Motor6D')

                    if EntityLib.Alive then
                        LocalAdded()
                    end

                    Viewmodel:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    Viewmodel:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    Viewmodel:Clean(RunService.PreRender:Connect(function()
                        if ViewmodelTool then
                            ViewmodelTool.CFrame = (Camera.CFrame * cf * Rotation) * ViewmodelMotor.C0
                            local ThirdPerson = vector.magnitude(Camera.CFrame.Position - Camera.Focus.Position) > 0.6
                            ViewmodelTool.LocalTransparencyModifier = ThirdPerson and 1 or 0
                            Handle.LocalTransparencyModifier = ThirdPerson and 0 or 1
                        end
                    end))
                else
                    if Handle then
                        Handle.LocalTransparencyModifier = 0
                        Handle = nil
                    end
                    
                    OldTool = nil

                    if ViewmodelTool then 
                        ViewmodelTool:Destroy()
                        ViewmodelTool = nil
                    end
                    if ViewmodelMotor then
                        ViewmodelMotor:Destroy()
                        ViewmodelMotor =  nil
                    end
                end
            end,
        })

        local function UpdateCF()
            cf = CFrame.new(X.Value, Y.Value, Z.Value)
        end

        X = Viewmodel:CreateSlider({
            Name = 'X',
            Default = 2.6,
            Min = -5,
            Max = 5,
            Decimal = 100,
            Function = UpdateCF
        })

        Y = Viewmodel:CreateSlider({
            Name = 'Y',
            Default = -1,
            Min = -5,
            Max = 5,
            Decimal = 100,
            Function = UpdateCF
        })

        Z = Viewmodel:CreateSlider({
            Name = 'Z',
            Default = -4,
            Min = -10,
            Max = 0,
            Decimal = 100,
            Function = UpdateCF
        })

        local function UpdateRotation()
            Rotation = CFrame.Angles(math.rad(RotationX.Value), math.rad(RotationY.Value), math.rad(RotationZ.Value))
        end

        RotationX = Viewmodel:CreateSlider({
            Name = 'Rotation X',
            Default = 90,
            Min = -360,
            Max = 360,
            Function = UpdateRotation
        })

        RotationY = Viewmodel:CreateSlider({
            Name = 'Rotation Y',
            Default = 0,
            Min = -360,
            Max = 360,
            Function = UpdateRotation
        })

        RotationZ = Viewmodel:CreateSlider({
            Name = 'Rotation Z',
            Default = 0,
            Min = -360,
            Max = 360,
            Function = UpdateRotation
        })

        UpdateCF()
        UpdateRotation()
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
        local Gravity, Value, Method
        local OldGravity, db

        local Methods = {
            Velocity = {
                Function = function(Delta)
                    EntityLib.Root.AssemblyLinearVelocity += vector.create(0, Delta * (workspace.Gravity - Value.Value), 0)
                end
            },
            Gravity = {
                Init = function()
                    OldGravity = workspace.Gravity
                    workspace.Gravity = Value.Value
                    Gravity:Clean(workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
                        if db then return end
                        db = true
                        OldGravity = workspace.Gravity
                        workspace.Gravity = Value.Value
                        db = nil
                    end))
                end
            },
        }

        Gravity = World:CreateModule({
            Name = "Gravity",
            Info = "Changes the speed at which you fall",
            Function = function(Enabled)
                if Enabled then
                    local CurrentMethod = Methods[Method.Value]
                    if CurrentMethod.Init then
                        CurrentMethod.Init()
                    end
                    if CurrentMethod.Function then
                        Gravity:Clean(RunService.PreSimulation:Connect(function(Delta)
                            if EntityLib.Alive and EntityLib.Humanoid.FloorMaterial == Enum.Material.Air then
                                CurrentMethod.Function(Delta)
                            end
                        end))
                    end
                elseif OldGravity then
                    workspace.Gravity = OldGravity
                    OldGravity = nil
                end
            end
        })

        Value = Gravity:CreateSlider({
            Name = "Gravity",
            Default = 196.2,
            Min = 0,
            Max = 1000,
            Decimal = 10,
            Function = function(Val)
                if Gravity.Enabled and Method.Value == 'Gravity' then
                    db = true
                    workspace.Gravity = Val
                    db = nil
                end
            end
        })

        Method = Gravity:CreateDropdown({
            Name = 'Method',
            List = {'Velocity', 'Gravity'},
            Function = function()
                if Gravity.Enabled then
                    Gravity:Toggle(true)
                    Gravity:Toggle(true)
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
            Info = 'Allows you to walk on water',
            Enabled = function()
                local Part = Instance.new('Part')
                Part.Transparency = 1
                Part.Size = vector.create(2, 0.2, 2)
                Part.Anchored = true
                Part.CanCollide = false
                Part.CanTouch = false
                Part.CanQuery = false
                Part.AudioCanCollide = false
                Part.CastShadow = false
                Part.Parent = workspace
                Jesus:Clean(Part)
                Jesus:Clean(RunService.PostSimulation:Connect(function()
                    if EntityLib.Alive then
                        local Raycast = workspace:Raycast(EntityLib.Root.Position, vector.create(0, -(EntityLib.HipHeight + 0.1), 0), Params)
                        if Raycast and Raycast.Material == Enum.Material.Water then
                            Part.Position = Raycast.Position
                            Part.CanCollide = true
                        else
                            Part.CanCollide = false
                        end
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
            Info = "Modifies how fast you interact with proximity prompts",
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

    Run(function() -- VehiclePhase
        local VehiclePhase

        local Modified = {}

        VehiclePhase = World:CreateModule({
            Name = 'VehiclePhase',
            Info = 'Allows the vehicle you\'re currently driving to phase through walls',
            Function = function(Enabled)
                if Enabled then
                    local Vehicle

                    local function SeatChanged()
                        if EntityLib.Humanoid.SeatPart then
                            Vehicle = EntityLib.Humanoid.SeatPart
                            while Vehicle.Parent.ClassName == 'Model' do
                                Vehicle = Vehicle.Parent
                            end
                        else
                            Vehicle = nil
                        end
                    end

                    local function LocalAdded()
                        VehiclePhase:Clean(EntityLib.Humanoid:GetPropertyChangedSignal('SeatPart'):Connect(SeatChanged))
                        if EntityLib.Humanoid.SeatPart then
                            SeatChanged()
                        end
                    end

                    local function LocalRemoved()
                        Vehicle = nil
                        VehiclePhase:CleanUp()
                        for Part in Modified do
                            Part.CanCollide = true
                        end
                        table.clear(Modified)
                    end

                    VehiclePhase:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    VehiclePhase:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    VehiclePhase:Clean(RunService.PreSimulation:Connect(function()
                        if Vehicle then
                            for _, Part in Vehicle:QueryDescendants('BasePart[CanCollide = true]') do
                                Modified[Part] = true
                                Part.CanCollide = false
                            end
                        end
                    end))

                    if EntityLib.Alive then
                        LocalAdded()
                    end
                else
                    for Part in Modified do
                        Part.CanCollide = true
                    end
                    table.clear(Modified)
                end
            end
        })
    end)

    Run(function() -- Tpua
        local Tpua, Fling, Player

        local Limbs = {
            -- R15
            ['LowerTorso'] = true,
            ['UpperTorso'] = true,
            ['UpperRightArm'] = true,
            ['LowerRightArm'] = true,
            ['UpperLeftArm'] = true,
            ['LowerLeftArm'] = true,
            ['UpperRightLeg'] = true,
            ['LowerRightLeg'] = true,
            ['UpperLeftLeg'] = true,
            ['LowerLeftLeg'] = true,
            ['HumanoidRootPart'] = true,
            -- R6
            ['Head'] = true,
            ['Torso'] = true,
            ['Right Arm'] = true,
            ['Left Arm'] = true,
            ['Right Leg'] = true,
            ['Left Leg'] = true,
        }

        local BodyPositions = {}

        Tpua = World:CreateModule({
            Name = 'Tpua',
            Info = 'Teleports un-anchored parts to the specified player\nYou must have network ownership of the parts for it to work',
            Function = function(Enabled)
                if Enabled then
                    local Character = EntityLib:FindEntity(Player)
                    local Target = Character and Character.Root or EntityLib.Alive and EntityLib.Root or nil
                    if not Target then return end

                    for _, Part in workspace:QueryDescendants('BasePart[Anchored = false]') do
                        if Limbs[Part.Name] or (EntityLib.Alive and Part:IsDescendantOf(EntityLib.Character)) then continue end

                        local BodyPosition = Instance.new('BodyPosition')
                        BodyPosition.MaxForce = vector.huge
                        BodyPosition.Position = Target.Position
                        BodyPosition.D = Fling.Enabled and 0 or 1250
                        BodyPosition.Parent = Part
                        table.insert(BodyPositions, BodyPosition)
                    end
                else
                    for _, v in BodyPositions do
                        v:Destroy()
                    end
                    table.clear(BodyPositions)
                end
            end
        })

        Tpua:CreatePlayerTextBox({
            Name = 'Target',
            PlaceholderText = '[Player Name]',
            Function = function(NewPlayer)
                Player = NewPlayer
            end
        })

        Fling = Tpua:CreateToggle({
            Name = 'Fling',
            Info = 'Flings people that touch the parts',
            Function = function(Enabled)
                for _, v in BodyPositions do
                    v.D = Enabled and 0 or 1250
                end
            end
        })
    end)

    Run(function() -- FireClickDetectors
        World:CreateButton({
            Name = 'Fire Click Detectors',
            Info = 'Fires all click detectors',
            Function = function()
                if not fireclickdetector then NotifyPoopSploit('fireclickdetector') return end
                for _, v in workspace:QueryDescendants('ClickDetector') do
                    fireclickdetector(v)
                end
            end,
        })
    end)

    Run(function() -- FireProximityPrompts
        World:CreateButton({
            Name = 'Fire Proximity Prompts',
            Info = 'Fires all proximity prompts',
            Function = function()
                if not fireproximityprompt then NotifyPoopSploit('fireproximityprompt') return end
                for _, v in workspace:QueryDescendants('ProximityPrompt') do
                    fireproximityprompt(v)
                end
            end,
        })
    end)

    Run(function() -- Fire Touch Interests
        World:CreateButton({
            Name = 'Fire Touch Interests',
            Info = 'Fires all touch interests',
            Function = function()
                if not firetouchinterest then NotifyPoopSploit("firetouchinterest") return end
                if EntityLib.Alive then
                    for _, TouchInterest in workspace:QueryDescendants('TouchTransmitter') do
                        firetouchinterest(TouchInterest.Parent, EntityLib.Root, true)
                        task.wait()
                        firetouchinterest(TouchInterest.Parent, EntityLib.Root, false)
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
                Direction = vector.normalize(Direction)
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
                    Part.CFrame = EntityLib.Alive and EntityLib.Head.CFrame or Camera.CFrame
                    Part.Parent = workspace

                    ActionName = HttpService:GenerateGUID(false)

                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Part.Position)
                    Camera.CameraSubject = Part
                    
                    Freecam:Clean(Camera:GetPropertyChangedSignal('CameraSubject'):Connect(function()
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
                    if EntityLib.Alive then
                        Camera.CameraSubject = EntityLib.Humanoid
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
        local Zoom, ZoomSpeed, ZoomFactor, AllowScrolling, ScrollSpeed, SensitivityFactor, Keybind

        local OldFov, ActionName, OldSensitivity, Con, db, db2, Zoomed

        local function ScrollFunction(_, _, Input)
            if UIS:GetFocusedTextBox() or not AllowScrolling.Enabled then return end
            if Zoomed then
                if Con then
                    Con:Disconnect()
                end
                local Start = Camera.FieldOfView
                local Goal = math.min(Start - (Input.Position.Z * ScrollSpeed.Value * (Start / 12)), 120)
                local Alpha = 0

                db, db2 = true, true
                Modules.FovChanger:Disable()

                Con = RunService.PreRender:Connect(function(Delta)
                    Alpha = math.min(Alpha + Delta * 2.5, 1)
                    local Value = TweenService:GetValue(Alpha, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
                    Camera.FieldOfView = math.lerp(Start, Goal, Value)
                    UIS.MouseDeltaSensitivity = math.min((Camera.FieldOfView / OldFov) * SensitivityFactor.Value, OldSensitivity)

                    if Value >= 1 then
                        Con:Disconnect()
                        Con = nil
                        task.wait()
                        db, db2 = false, false
                        Modules.FovChanger:Enable()
                    end
                end)
            end
        end

        Zoom = Other:CreateModule({
            Name = 'Zoom',
            Info = 'Zooms in your camera when pressing your binded key',
            Function = function(Enabled)
                if Enabled then
                    OldFov = Camera.FieldOfView
                    ActionName = HttpService:GenerateGUID(false)
                    OldSensitivity = UIS.MouseDeltaSensitivity

                    Zoom:Clean(UIS:GetPropertyChangedSignal('MouseDeltaSensitivity'):Connect(function()
                        if db2 then return end
                        db2 = true
                        OldSensitivity = UIS.MouseDeltaSensitivity
                        db2 = false
                    end))

                    Zoom:Clean(Camera:GetPropertyChangedSignal('FieldOfView'):Connect(function()
                        if db then return end
                        db = true
                        OldFov = Camera.FieldOfView

                        if Zoomed then
                            Modules.FovChanger:Disable()
                            Camera.FieldOfView = OldFov * (1 / ZoomFactor.Value)
                            UIS.MouseDeltaSensitivity = math.min((Camera.FieldOfView / OldFov) * SensitivityFactor.Value, OldSensitivity)
                            Modules.FovChanger:Enable()
                        end

                        db = false
                    end))

                    Zoom:Clean(UIS.InputBegan:Connect(function(Input)
                        if UIS:GetFocusedTextBox() then return end
                        if Keybind:Check(Input) then
                            if Con then
                                Con:Disconnect()
                            end

                            local Alpha = 0

                            db, db2 = true, true
                            Modules.FovChanger:Disable()

                            Con = RunService.PreRender:Connect(function(Delta)
                                Alpha = math.min(Alpha + (Delta * ZoomSpeed.Value), 1)
                                local Value = TweenService:GetValue(Alpha, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
                                Camera.FieldOfView = math.lerp(OldFov, OldFov * (1 / ZoomFactor.Value), Value)
                                UIS.MouseDeltaSensitivity = math.min((Camera.FieldOfView / OldFov) * SensitivityFactor.Value, OldSensitivity)

                                if Value >= 1 then
                                    Con:Disconnect()
                                    Con = nil
                                    Zoomed = true
                                    ContextActionService:BindActionAtPriority(`ZoomScroll_{ActionName}`, ScrollFunction, false, 69420, Enum.UserInputType.MouseWheel)
                                    task.wait()
                                    db, db2 = false, false
                                    Modules.FovChanger:Enable()
                                end
                            end)
                        end
                    end))

                    Zoom:Clean(UIS.InputEnded:Connect(function(Input)
                        if Keybind:Check(Input) then
                            if Con then
                                Con:Disconnect()
                            end
                            
                            Zoomed = false
                            ContextActionService:UnbindAction(`ZoomScroll_{ActionName}`)

                            local Start = Camera.FieldOfView
                            local Alpha = 0

                            db, db2 = true, true
                            Modules.FovChanger:Disable()
                            
                            Con = RunService.PreRender:Connect(function(Delta)
                                Alpha = math.min(Alpha + (Delta * ZoomSpeed.Value), 1)
                                local Value = TweenService:GetValue(Alpha, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
                                Camera.FieldOfView = math.lerp(Start, OldFov, Value)
                                UIS.MouseDeltaSensitivity = math.min((Camera.FieldOfView / OldFov) * SensitivityFactor.Value, OldSensitivity)

                                if Value >= 1 then
                                    db, db2 = false, false
                                    Modules.FovChanger:Enable()
                                    Con:Disconnect()
                                    Con = nil
                                end
                            end)
                        end
                    end))
                else
                    if Con then
                        Con:Disconnect()
                        Con = nil
                    end
                    Modules.FovChanger:Disable()
                    Camera.FieldOfView = OldFov
                    UIS.MouseDeltaSensitivity = OldSensitivity
                    ContextActionService:UnbindAction(`ZoomScroll_{ActionName}`)
                    Modules.FovChanger:Enable()
                end
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
            Info = 'Allows you to scroll to change the zoom factor',
            Default = true
        })

        ScrollSpeed = AllowScrolling:CreateSlider({
            Name = 'Scroll Speed',
            Default = 2,
            Min = 1,
            Max = 5
        })

        SensitivityFactor = Zoom:CreateSlider({
            Name = 'Sensitivity Factor',
            Default = 1,
            Min = 0.5,
            Max = 2,
            Decimal = 10
        })

        Keybind = Zoom:CreateKeybind({
            Name = 'Zoom',
            Keybind = 'C'
        })
    end)

    Run(function() -- View
        local View, TextBox, Player

        local function PlayerAdded(NewPlayer)
            if TextBox:CheckPlayer(NewPlayer) then
                Player = NewPlayer
            end
        end

        local function PlayerRemoved(PlayerRemoving)
            if PlayerRemoving == Player then
                Notify({
                    Text = 'View has been disabled becuase the player left',
                    Duration = 10
                })

                Player = nil
                View:Toggle(true)
            end
        end

        View = Other:CreateModule({
            Name = 'View',
            Info = 'Views the specified player',
            Function = function(Enabled)
                if Enabled then
                    TextBox:Refresh()

                    local Ent = Player and EntityLib:FindEntity(Player) or nil

                    local function CharacterAdded(Char)
                        if Char.Player and Char.Player == Player then
                            Camera.CameraSubject = Char.Humanoid
                        end
                    end

                    local function CharacterRemoved(Char)
                        if Char.Player and Char.Player == Player and EntityLib.Alive then
                            Camera.CameraSubject = EntityLib.Humanoid
                        end
                    end

                    View:Clean(Camera:GetPropertyChangedSignal('CameraSubject'):Connect(function()
                        if Ent then
                            Camera.CameraSubject = Ent.Humanoid
                        end
                    end))

                    if Ent then
                        Camera.CameraSubject = Ent.Humanoid
                    end

                    View:Clean(EntityLib.Events.EntityAdded:Connect(CharacterAdded))
                    View:Clean(EntityLib.Events.EntityRemoved:Connect(CharacterRemoved))
                    View:Clean(Players.PlayerAdded:Connect(PlayerAdded))
                    View:Clean(Players.PlayerRemoving:Connect(PlayerRemoved))
                else
                    if EntityLib.Alive then
                        Camera.CameraSubject = EntityLib.Humanoid
                    end
                end
            end
        })

        TextBox = View:CreatePlayerTextBox({
            Name = 'Target',
            Placeholder = '[Player Name]',
            Function = function(NewPlayer)
                Player = NewPlayer
            end
        })
    end)

    Run(function() -- AntiKick
        local AntiKick, OldIndex, OldNamecall

        AntiKick = Other:CreateModule({
            Name = 'AntiKick',
            Info = 'Prevents you from getting kicked by local scripts',
            Enabled = function()
                if not hookmetamethod then NotifyPoopSploit('hookmetamethod') return end
                if not getnamecallmethod then NotifyPoopSploit('getnamecallmethod') return end

                OldIndex = hookmetamethod(game, '__index', newcclosure(function(self, Key)
                    if self == Plr and Key:lower() == 'kick' then
                        return error("Expected ':' not '.' calling member function Kick", 2)
                    end

                    return OldIndex(self, Key)
                end))

                OldNamecall = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
                    if self == Plr and getnamecallmethod():lower() == 'kick' then
                        return
                    end

                    return OldNamecall(self, ...)
                end))

                AntiKick:Clean(function()
                    hookmetamethod(game, '__index', OldIndex)
                    hookmetamethod(game, '__namecall', OldNamecall)
                end)
            end,
        })
    end)

    Run(function() -- AntiTeleport
        local AntiTeleport, OldIndex, OldNamecall

        AntiTeleport = Other:CreateModule({
            Name = 'AntiTeleport',
            Info = 'Prevents you from getting teleported by local scripts',
            Enabled = function()
                if not hookmetamethod then NotifyPoopSploit('hookmetamethod') return end
                if not getnamecallmethod then NotifyPoopSploit('getnamecallmethod') return end

                OldIndex = hookmetamethod(game, '__index', newcclosure(function(self, Key)
                    if self == TeleportService then
                        if Key:lower() == 'teleport' then
                            return error("Expected ':' not '.' calling member function Teleport", 2)
                        elseif Key == 'TeleportToPlaceInstance' then
                            return error("Expected ':' not '.' calling member function TeleportToPlaceInstance", 2)
                        end
                    end

                    return OldIndex(self, Key)
                end))

                OldNamecall = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
                    if self == TeleportService then
                        local Method = getnamecallmethod()
                        if Method:lower() == 'teleport' or Method == 'TeleportToPlaceInstance' then
                            return
                        end
                    end

                    return OldNamecall(self, ...)
                end))

                AntiTeleport:Clean(function()
                    hookmetamethod(game, '__index', OldIndex)
                    hookmetamethod(game, '__namecall', OldNamecall)
                end)
            end,
        })
    end)

    Run(function() -- AntiAFK
        local AntiAFK

        AntiAFK = Other:CreateModule({
            Name = 'AntiAFK',
            Info = 'Prevents you from getting kicked for being idle',
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
            Name = 'AntiFling',
            Info = 'Prevents you from getting flung by other players',
            Enabled = function()
                AntiFling:Clean(RunService.PreSimulation:Connect(function()
                    for _, Ent in EntityLib.List do
                        for _, Part in Ent.Character:QueryDescendants('BasePart[CanCollide = true]') do
                            Part.CanCollide = false
                        end
                    end
                end))
            end
        })
    end)

    Run(function() -- CameraPhase
        local CameraPhase

        CameraPhase = Other:CreateModule({
            Name = "CameraPhase",
            Info = "Allows your camera to phase through walls",
            Enabled = function()
                if debug.setconstant and debug.getconstants and getgc then
                    for _, Function in getgc() do
                        if typeof(Function) == "function" then
                            local Source, Name = debug.info(Function, "sn")
                            if Name == "queryPoint" and Source:match('ZoomController%.Popper') then
                                for i, c in debug.getconstants(Function) do
                                    if c == 0.25 then
                                        debug.setconstant(Function, i, 0)
                                        CameraPhase:Clean(debug.setconstant, Function, i, 0.25)
                                        break
                                    end
                                end
                                break
                            end
                        end
                    end
                else
                    Notify({
                        Text = 'Your executor doesn\'t support debug library/getgc, Using Invisicam instead',
                        Duration = 5,
                        Type = 'Warning'
                    })

                    local Old = Plr.DevCameraOcclusionMode
                    CameraPhase:Clean(function()
                        Plr.DevCameraOcclusionMode = Old
                    end)

                    Plr.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
                end
            end
        })
    end)

    Run(function() -- FPS Cap
        local FPSCap, FPS

        FPSCap = Other:CreateModule({
            Name = 'FPSCap',
            Info = 'Sets your fps cap to the specified value',
            Enabled = function()
                if setfpscap then
                    local OldCap = getfpscap and getfpscap() or 60
                    setfpscap(FPS.Value)
                    FPSCap:Clean(setfpscap, OldCap)
                else
                    local NextFrame = os.clock() + (1 / FPS.Value)
                    while FPSCap.Enabled do
                        local CurrentTime = os.clock()
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

        local Old

        ShiftLock = Other:CreateModule({
            Name = 'ShiftLock',
            Info = 'Force enables the option to toggle shift lock',
            Function = function(Enabled)
                if Enabled then
                    Old = Plr.DevEnableMouseLock
                    Plr.DevEnableMouseLock = true
                else
                    Plr.DevEnableMouseLock = Old
                    Old = nil
                end
            end,
        })
    end)

    Run(function()
        Other:CreateModule({
            Name = 'GameplayPausedDisabler',
            Info = 'Removes the gameplay paused popup',
            Function = function(Enabled)
                GuiService:SetGameplayPausedNotificationEnabled(not Enabled)
            end
        })
    end)

    Run(function()
        local PartPath

        PartPath = Other:CreateModule({
            Name = 'Part Path',
            Info = 'Copies the path of parts you click on',
            Enabled = function()
                if not setclipboard then
                    NotifyPoopSploit('setclipboard')
                    PartPath:Toggle(true)
                    return
                end

                PartPath:Clean(UIS.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 and CanClick() then
                        local MouseLocation = UIS:GetMouseLocation()
                        local MouseRaycast = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)
                        local Raycast = workspace:Raycast(MouseRaycast.Origin, MouseRaycast.Direction * 1000)
                        if Raycast then
                            local FullName = GetFullName(Raycast.Instance)
                            setclipboard(FullName)

                            Notify({
                                Text = 'Copied path to Clipboard',
                                Duration = 3
                            })
                        end
                    end
                end))
            end
        })
    end)

    Run(function() -- Panic
        Other:CreateButton({
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
end)

Run(function() -- Animations
    Run(function() -- Spasm
        local Spasm, Speed, Track

        local Animation = Instance.new("Animation")
        Animation.AnimationId = "rbxassetid://33796059"

        local function LocalRemoved()
            if Track then
                Track:Stop()
                Track:Destroy()
                Track = nil
            end
        end

        local function LocalAdded()
            if EntityLib.RigType == Enum.HumanoidRigType.R15 then
                Notify({
                    Text = "Spasm only works on R6",
                    Duration = 10,
                    Type = 'Error'
                })
                
                Spasm:Toggle(true)

                return
            end

            LocalRemoved()

            local Animator: Animator = EntityLib.Animator or EntityLib.Humanoid
            Track = Animator:LoadAnimation(Animation)
            Track.Priority = Enum.AnimationPriority.Action4
            Track.Looped = true
            Track:Play(0, 1, Speed.Value)
        end

        Spasm = Animations:CreateModule({
            Name = "Spasm",
            Function = function(Enabled)
                if Enabled then
                    Spasm:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    Spasm:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))

                    if EntityLib.Alive then
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

        local function LocalRemoved()
            if Track then
                Track:Stop()
                Track:Destroy()
                Track = nil
            end
        end

        local function LocalAdded()
            if EntityLib.Humanoid.RigType == Enum.HumanoidRigType.R15 then
                Notify({
                    Text = 'HeadThrow only works on R6',
                    Duration = 10,
                    Type = 'Error'
                })
                
                HeadThrow:Toggle(true)
                
                return
            end

            LocalRemoved()

            local Animator: Animator = EntityLib.Animator or EntityLib.Humanoid
            Track = Animator:LoadAnimation(Animation)
            Track.Priority = Enum.AnimationPriority.Action4
            Track.Looped = true
            Track:Play(0, 1, Speed.Value)
        end

        HeadThrow = Animations:CreateModule({
            Name = "HeadThrow",
            Function = function(Enabled)
                if Enabled then
                    HeadThrow:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    HeadThrow:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))

                    if EntityLib.Alive then
                        LocalAdded()
                    end
                else
                    LocalRemoved()
                end
            end,
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

    Run(function() -- AnimationSpeed
        local AnimationSpeed, Speed, UseMulti, Multi

        local Tracks = {}
        local db = {}

        local function CalculateSpeed(Track)
            return UseMulti.Enabled and (Tracks[Track] * Multi.Value) or Speed.Value
        end

        local function AnimationPlayed(Track: AnimationTrack)
            if not Tracks[Track] then
                Tracks[Track] = Track.Speed
            end
            local CalculatedSpeed = CalculateSpeed(Track)
            Track:AdjustSpeed(CalculatedSpeed)
            Track:GetPropertyChangedSignal('Speed'):Connect(function()
                if db[Track] then return end
                db[Track] = true
                Tracks[Track] = Track.Speed
                CalculatedSpeed = CalculateSpeed(Track)
                Track:AdjustSpeed(CalculatedSpeed)
                db[Track] = nil
            end)
        end

        local function LocalRemoved()
            table.clear(Tracks)
            table.clear(db)
        end

        local function LocalAdded()
            LocalRemoved()
            local Animator = EntityLib.Animator or EntityLib.Humanoid
            AnimationSpeed:Clean(Animator.AnimationPlayed:Connect(AnimationPlayed))
            for _, Track in Animator:GetPlayingAnimationTracks() do
                AnimationPlayed(Track)
            end
        end

        AnimationSpeed = Animations:CreateModule({
            Name = "AnimationSpeed",
            Info = "Sets the speed of all your currently playing animations",
            Function = function(Enabled)
                if Enabled then
                    AnimationSpeed:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    AnimationSpeed:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if EntityLib.Alive then
                        LocalAdded()
                    end
                else
                    for Track, OldSpeed in Tracks do
                        Track:AdjustSpeed(OldSpeed)
                    end
                    table.clear(Tracks)
                    table.clear(db)
                end
            end,
        })

        Speed = AnimationSpeed:CreateSlider({
            Name = "Speed",
            Default = 1,
            Min = 0,
            Max = 3,
            Decimal = 10,
            Function = function(Val)
                if AnimationSpeed.Enabled and not UseMulti.Enabled then
                    for Track in Tracks do
                        db[Track] = true
                        local Speed = CalculateSpeed(Track)
                        Track:AdjustSpeed(Speed)
                        db[Track] = nil
                    end
                end
            end
        })

        UseMulti = AnimationSpeed:CreateToggle({
            Name = "Use Multi",
            Info = "Multiplies the speed of all your animations rather than just setting it",
        })

        Multi = UseMulti:CreateSlider({
            Name = "Multi",
            Default = 1,
            Min = 0,
            Max = 3,
            Decimal = 10,
            Function = function(Val)
                if AnimationSpeed.Enabled and UseMulti.Enabled then
                    for Track in Tracks do
                        db[Track] = true
                        local Speed = CalculateSpeed(Track)
                        Track:AdjustSpeed(Speed)
                        db[Track] = nil
                    end
                end
            end
        })
    end)

    Run(function() -- Jerk
        local Jerk, Speed, Track

        local Animation = Instance.new("Animation")

        local function LocalRemoved()
            if Track then
                Track:Stop()
                Track:Destroy()
                Track = nil
            end
        end

        local function LocalAdded()
            LocalRemoved()

            Animation.AnimationId = EntityLib.RigType == Enum.HumanoidRigType.R15 and 'rbxassetid://698251653' or 'rbxassetid://72042024'

            local Animator: Animator = EntityLib.Animator or EntityLib.Humanoid
            Track = Animator:LoadAnimation(Animation)
            Track.Priority = Enum.AnimationPriority.Action4
            Track:Play(0, 1, Speed.Value * 0.7)
            Track.TimePosition = 0.6
        end

        Jerk = Animations:CreateModule({
            Name = "Jerk",
            Info = "Makes you absolutely jork it",
            Function = function(Enabled)
                if Enabled then
                    Jerk:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    Jerk:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    Jerk:Clean(RunService.PreAnimation:Connect(function()
                        if EntityLib.Alive and Track and Track.TimePosition >= 0.7 then
                            Track.TimePosition = 0.6
                        end
                    end))
                    
                    if EntityLib.Alive then
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
                    Track:AdjustSpeed(Val * 0.7)
                end
            end
        })
    end)

    Run(function() -- Bang
        local Bang, TextBox, Speed, Track

        local Player, Character

        local Offset = CFrame.new(0, 0, 1.1)
        local Animation = Instance.new('Animation')

        local function LocalRemoved()
            if Track then
                Track:Stop()
                Track:Destroy()
                Track = nil
            end
        end

        local function LocalAdded()
            LocalRemoved()

            Animation.AnimationId = EntityLib.Humanoid.RigType == Enum.HumanoidRigType.R15 and 'rbxassetid://5918726674' or 'rbxassetid://148840371'
            local Animator: Animator = EntityLib.Animator or EntityLib.Humanoid
            Track = Animator:LoadAnimation(Animation)
            Track.Looped = true
            Track.Priority = Enum.AnimationPriority.Action4
            Track:Play(0, 1, Speed.Value * 3)
        end

        local function PlayerAdded(NewPlayer)
            if TextBox:CheckPlayer(NewPlayer) then
                Player = NewPlayer
            end
        end

        local function PlayerRemoved(PlayerRemoving)
            if PlayerRemoving == Player then
                Notify({
                    Text = 'Bang has been disabled because the player left',
                    Duration = 10
                })

                Bang:Toggle(true)
                Player = nil
            end
        end

        Bang = Animations:CreateModule({
            Name = 'Bang',
            Info = 'Bangs the specified player',
            Function = function(Enabled)
                if Enabled then
                    TextBox:Refresh()

                    local function CharacterAdded(Char)
                        if Char.Player and Player and Char.Player == Player then
                            Character = Char
                        end
                    end

                    local function CharacterRemoved(Char)
                        if Char.Player and Player and Char.Player == Player then
                            Character = nil
                        end
                    end

                    local function UpdateLocalCharacter()
                        if EntityLib.Alive and Character then
                            EntityLib.Root.CFrame = Character.Root.CFrame * Offset
                            EntityLib.Root.AssemblyLinearVelocity = vector.zero
                        end
                    end

                    if EntityLib.Alive then
                        LocalAdded()
                    end

                    Bang:Clean(RunService.PreSimulation:Connect(UpdateLocalCharacter))
                    Bang:Clean(RunService.PostSimulation:Connect(UpdateLocalCharacter))
                    Bang:Clean(Players.PlayerAdded:Connect(PlayerAdded))
                    Bang:Clean(Players.PlayerRemoving:Connect(PlayerRemoved))
                    Bang:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    Bang:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    Bang:Clean(EntityLib.Events.EntityAdded:Connect(CharacterAdded))
                    Bang:Clean(EntityLib.Events.EntityRemoved:Connect(CharacterRemoved))
                else
                    Player, Character = nil, nil
                    LocalRemoved()
                end
            end
        })

        TextBox = Bang:CreatePlayerTextBox({
            Name = 'Player',
            Placeholder = '[Player Name]',
            Function = function(NewPlayer)
                if Bang.Enabled then
                    Player = NewPlayer
                    Character = Player and EntityLib:FindEntity(Player) or nil
                end
            end
        })

        Speed = Bang:CreateSlider({
            Name = 'Speed',
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
        local Carpet, TextBox, Track

        local Player, Character

        local Animation = Instance.new('Animation')
        Animation.AnimationId = 'rbxassetid://282574440'

        local Angle = CFrame.Angles(math.rad(-90), 0, 0)

        local function LocalRemoved()
            if Track then
                Track:Stop()
                Track:Destroy()
                Track = nil
            end
        end

        local function LocalAdded()
            LocalRemoved()

            if EntityLib.RigType == Enum.HumanoidRigType.R6 then
                local Animator: Animator = EntityLib.Animator or EntityLib.Humanoid
                Track = Animator:LoadAnimation(Animation)
                Track.Priority = Enum.AnimationPriority.Action4
                Track.Looped = true
                Track:Play(0, 1, 1)
            end
        end

        local function PlayerAdded(NewPlayer)
            if TextBox:CheckPlayer(NewPlayer) then
                Player = NewPlayer
            end
        end

        local function PlayerRemoved(PlayerRemoving)
            if Player and PlayerRemoving == Player then
                Notify({
                    Text = 'Carpet has been disabled because the player left',
                    Duration = 10
                })

                Carpet:Toggle(true)
                Player = nil
            end
        end

        Carpet = Animations:CreateModule({
            Name = "Carpet",
            Info = "You become the specifed player's carpet",
            Function = function(Enabled)
                if Enabled then
                    TextBox:Refresh()

                    local function CharacterAdded(Char)
                        if Char.Player and Player and Char.Player == Player then
                            Character = Char
                        end
                    end

                    local function CharacterRemoved(Char)
                        if Char.Player and Player and Char.Player == Player then
                            Character = nil
                        end
                    end

                    local function Update()
                        if EntityLib.Alive and Character then
                            if EntityLib.RigType == Enum.HumanoidRigType.R15 then
                                EntityLib.Root.CFrame = Character.Root.CFrame:ToWorldSpace(CFrame.new(0, -EntityLib.HipHeight, 0) * Angle)
                                EntityLib.Root.AssemblyLinearVelocity = vector.zero
                                EntityLib.Root.AssemblyAngularVelocity = vector.zero
                            else
                                EntityLib.Root.CFrame = Character.Root.CFrame
                                EntityLib.Root.AssemblyLinearVelocity = vector.zero
                            end
                        end
                    end

                    Carpet:Clean(RunService.PreSimulation:Connect(Update))
                    Carpet:Clean(RunService.PostSimulation:Connect(Update))
                    Carpet:Clean(Players.PlayerAdded:Connect(PlayerAdded))
                    Carpet:Clean(Players.PlayerRemoving:Connect(PlayerRemoved))
                    Carpet:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    Carpet:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    Carpet:Clean(EntityLib.Events.EntityAdded:Connect(CharacterAdded))
                    Carpet:Clean(EntityLib.Events.EntityRemoved:Connect(CharacterRemoved))

                    if EntityLib.Alive then
                        LocalAdded()
                    end
                else
                    Player, Character = nil, nil
                    LocalRemoved()
                end
            end
        })

        TextBox = Carpet:CreatePlayerTextBox({
            Name = 'Target',
            Placeholder = '[Player Name]',
            Function = function(NewPlayer)
                if Carpet.Enabled then
                    Player = NewPlayer
                    Character = Player and EntityLib:FindEntity(Player) or nil
                end
            end
        })
    end)

    Run(function() -- HeadSit
        local HeadSit, TextBox

        local Player, Character

        local Offset = CFrame.new(0, 1.6, 0.4)

        local function LocalRemoved()
            HeadSit:CleanUp()
        end

        local function LocalAdded()
            LocalRemoved()

            EntityLib.Humanoid.Sit = true
            HeadSit:Clean(EntityLib.Humanoid:GetPropertyChangedSignal('Sit'):Once(function()
                HeadSit:Toggle(true)
            end))
        end

        local function PlayerAdded(NewPlayer)
            if TextBox:CheckPlayer(NewPlayer) then
                Player = NewPlayer
            end
        end

        local function PlayerRemoved(PlayerRemoving)
            if Player and PlayerRemoving == Player then
                Notify({
                    Text = 'HeadSit has been disabled because the player left',
                    Duration = 10
                })

                HeadSit:Toggle(true)
                Player = nil
            end
        end

        HeadSit = Animations:CreateModule({
            Name = 'HeadSit',
            Info = 'Sits on the specified player\'s head',
            Function = function(Enabled)
                if Enabled then
                    TextBox:Refresh()

                    local function CharacterAdded(Char)
                        if Char.Player and Player and Char.Player == Player then
                            Character = Char
                        end
                    end

                    local function CharacterRemoved(Char)
                        if Char.Player and Player and Char.Player == Player then
                            Character = nil
                        end
                    end

                    local function Update()
                        if EntityLib.Alive and Character then
                            EntityLib.Root.CFrame = Character.Root.CFrame:ToWorldSpace(Offset)
                            EntityLib.Root.AssemblyLinearVelocity = vector.zero
                        end
                    end

                    HeadSit:Clean(RunService.PreSimulation:Connect(Update))
                    HeadSit:Clean(RunService.PostSimulation:Connect(Update))
                    HeadSit:Clean(Players.PlayerAdded:Connect(PlayerAdded))
                    HeadSit:Clean(Players.PlayerRemoving:Connect(PlayerRemoved))
                    HeadSit:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    HeadSit:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    HeadSit:Clean(EntityLib.Events.EntityAdded:Connect(CharacterAdded))
                    HeadSit:Clean(EntityLib.Events.EntityRemoved:Connect(CharacterRemoved))
                    
                    if EntityLib.Alive then
                        LocalAdded()
                    end
                else
                    Player, Character = nil, nil
                    if EntityLib.Alive then
                        EntityLib.Humanoid.Sit = false
                    end
                end
            end
        })

        TextBox = HeadSit:CreatePlayerTextBox({
            Name = 'Player',
            Placeholder = '[Player Name]',
            Function = function(NewPlayer)
                if HeadSit.Enabled then
                    Player = NewPlayer
                    Character = Player and EntityLib:FindEntity(Player) or nil
                end
            end
        })
    end)

    Run(function() -- BendOver
        local BendOver, TextBox

        local Player, Character, Track

        local Offset = CFrame.new(0.4, 0, -2.1) * CFrame.Angles(0, math.rad(14), 0)

        local Animation = Instance.new('Animation')
        Animation.AnimationId = 'rbxassetid://10214311282'

        local function LocalRemoved()
            if Track then
                Track:Stop()
                Track:Destroy()
                Track = nil
            end
        end

        local function LocalAdded()
            if EntityLib.RigType == Enum.HumanoidRigType.R6 then
                Notify({
                    Text = 'BendOver only works on R15',
                    Duration = 10,
                    Type = 'Error'
                })

                BendOver:Toggle(true)
                return
            end

            LocalRemoved()

            local Animator: Animator = EntityLib.Animator or EntityLib.Humanoid

            Track = Animator:LoadAnimation(Animation)
            Track.Priority = Enum.AnimationPriority.Action4
            Track:Play(0.1, 1, 1)
            Track.TimePosition = 4
            Track:AdjustSpeed(0)
        end

        local function PlayerAdded(NewPlayer)
            if TextBox:CheckPlayer(NewPlayer) then
                Player = NewPlayer
            end
        end

        local function PlayerRemoved(PlayerRemoving)
            if Player and PlayerRemoving == Player then
                Notify({
                    Text = 'BendOver has been disabled because the player left',
                    Duration = 10
                })

                BendOver:Toggle(true)
                Player = nil
            end
        end

        BendOver = Animations:CreateModule({
            Name = 'BendOver',
            Info = 'Makes you bend over',
            Function = function(Enabled)
                if Enabled then
                    TextBox:Refresh()

                    local function CharacterAdded(Char)
                        if Char.Player and Player and Char.Player == Player then
                            Character = Char
                        end
                    end

                    local function CharacterRemoved(Char)
                        if Char.Player and Player and Char.Player == Player then
                            Character = nil
                        end
                    end

                    local function Update()
                        if EntityLib.Alive and Character then
                            EntityLib.Root.AssemblyLinearVelocity = vector.zero
                            EntityLib.Root.CFrame = Character.Root.CFrame * Offset
                        end
                    end

                    BendOver:Clean(RunService.PreSimulation:Connect(Update))
                    BendOver:Clean(RunService.PostSimulation:Connect(Update))
                    BendOver:Clean(Players.PlayerAdded:Connect(PlayerAdded))
                    BendOver:Clean(Players.PlayerRemoving:Connect(PlayerRemoved))
                    BendOver:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    BendOver:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    BendOver:Clean(EntityLib.Events.EntityAdded:Connect(CharacterAdded))
                    BendOver:Clean(EntityLib.Events.EntityRemoved:Connect(CharacterRemoved))
                    
                    if EntityLib.Alive then
                        LocalAdded()
                    end
                else
                    Player, Character = nil, nil
                    LocalRemoved()
                end
            end,
        })

        TextBox = BendOver:CreatePlayerTextBox({
            Name = 'Target',
            PlaceholderText = '[Player Name]',
            Function = function(NewPlayer)
                if BendOver.Enabled then
                    Player = NewPlayer
                    Character = Player and EntityLib:FindEntity(Player) or nil
                end
            end
        })
    end)

    Run(function() -- Orbit
        local Orbit, TextBox, Speed, Distance

        local Player, Character

        local function PlayerAdded(NewPlayer)
            if TextBox:CheckPlayer(NewPlayer) then
                Player = NewPlayer
            end
        end

        local function PlayerRemoved(PlayerRemoving)
            if Player and PlayerRemoving == Player then
                Notify({
                    Text = 'Orbit has been disabled because the player left',
                    Duration = 10
                })

                Orbit:Toggle(true)
            end
        end

        Orbit = Animations:CreateModule({
            Name = 'Orbit',
            Info = 'Orbits the specified player',
            Function = function(Enabled)
                if Enabled then
                    TextBox:Refresh()

                    local Rot = 0

                    local function CharacterAdded(Char)
                        if Player and Char.Player and Char.Player == Player then
                            Character = Char
                        end
                    end

                    local function CharacterRemoved(Char)
                        if Player and Char.Player and Char.Player == Player then
                            Character = nil
                        end
                    end

                    local function Update(Delta)
                        if EntityLib.Alive and Character then
                            Rot += Speed.Value * Delta
                            local cf = CFrame.new(Character.Root.Position) * CFrame.Angles(0, math.rad(Rot), 0) * CFrame.new(0, 0, Distance.Value)
                            EntityLib.Root.AssemblyLinearVelocity = vector.zero
                            EntityLib.Root.CFrame = cf
                        end
                    end
                    
                    Orbit:Clean(Players.PlayerAdded:Connect(PlayerAdded))
                    Orbit:Clean(Players.PlayerRemoving:Connect(PlayerRemoved))
                    Orbit:Clean(EntityLib.Events.EntityAdded:Connect(CharacterAdded))
                    Orbit:Clean(EntityLib.Events.EntityRemoved:Connect(CharacterRemoved))
                    Orbit:Clean(RunService.PreSimulation:Connect(Update))
                else
                    Player, Character = nil, nil
                end
            end
        })

        TextBox = Orbit:CreatePlayerTextBox({
            Name = 'Taget',
            PlaceholderText = '[Player Name]',
            Function = function(NewPlayer)
                if Orbit.Enabled then
                    Player = NewPlayer
                    Character = Player and EntityLib:FindEntity(Player) or nil
                end
            end
        })

        Speed = Orbit:CreateSlider({
            Name = "Speed",
            Default = 45,
            Min = 0,
            Max = 360,
            Suffix = '°'
        })

        Distance = Orbit:CreateSlider({
            Name = "Distance",
            Default = 5,
            Min = 0,
            Max = 20,
            Decimal = 100,
        })
    end)

    Run(function() -- Stare
        local Stare, TextBox

        local Player, Character

        local function PlayerAdded(NewPlayer)
            if TextBox:CheckPlayer(NewPlayer) then
                Player = NewPlayer
            end
        end

        local function PlayerRemoved(PlayerRemoving)
            if Player and PlayerRemoving == Player then
                Notify({
                    Text = 'Stare has been disabled because the player left',
                    Duration = 10,
                })

                Stare:Toggle(true)
            end
        end

        Stare = Animations:CreateModule({
            Name = 'Stare',
            Info = 'Stares at the specified player',
            Enabled = function()
                TextBox:Refresh()

                Character = Player and EntityLib:FindEntity(Player) or nil

                local function CharacterAdded(Char)
                    if Char.Player and Player and Char.Player == Player then
                        Character = Char
                    end
                end

                local function CharacterRemoved(Char)
                    if Char.Player and Player and Char.Player == Player then
                        Character = nil
                    end
                end

                local function Update()
                    if EntityLib.Alive and Character then
                        EntityLib.Root.CFrame = CFrame.lookAt(EntityLib.Root.Position, vector.create(Character.Root.Position.X, EntityLib.Root.Position.Y, Character.Root.Position.Z))
                    end
                end

                Stare:Clean(Players.PlayerAdded:Connect(PlayerAdded))
                Stare:Clean(Players.PlayerRemoving:Connect(PlayerRemoved))
                Stare:Clean(EntityLib.Events.EntityAdded:Connect(CharacterAdded))
                Stare:Clean(EntityLib.Events.EntityRemoved:Connect(CharacterRemoved))
                Stare:Clean(RunService.PreRender:Connect(Update))
            end
        })

        TextBox = Stare:CreatePlayerTextBox({
            Name = 'Player',
            Placeholder = '[Player Name]',
            Function = function(NewPlayer)
                if Stare.Enabled then
                    Player = NewPlayer
                end
            end
        })
    end)

    Run(function() -- Dance
        local Dance, Track, R15Dance, R6Dance

        local R6Dances = {
            ['Dance'] = 'rbxassetid://27789359',
            ['Moonwalk'] = 'rbxassetid://30196114',
            ['Dance Like There\'s no Tomorrow'] = 'rbxassetid://248263260',
            ['Disco'] = 'rbxassetid://45834924',
            ['Party'] = 'rbxassetid://33796059',
            ['Goal'] = 'rbxassetid://28488254',
            ['Flute Dance'] = 'rbxassetid://52155728'
        }

        local R15Dances = {
            ['River Dance'] = 'rbxassetid://3333432454',
            ['Keeping Time'] = 'rbxassetid://4555808220',
            ['Line Dance'] = 'rbxassetid://4049037604',
            ['Air Dance'] = 'rbxassetid://4555782893',
            ['Break Dance'] = 'rbxassetid://10214311282',
            ['Reflex'] = 'rbxassetid://10714010337',
            ['Around Town'] = 'rbxassetid://10713981723',
            ['Idol Face'] = 'rbxassetid://10714372526',
            ['Fancy Feet'] = 'rbxassetid://10714076981',
            ['Robot'] = 'rbxassetid://10714392151',
            ['Still Standing'] = 'rbxassetid://11444443576'
        }

        local Animation = Instance.new('Animation')

        local function LocalAdded()
            Animation.AnimationId = EntityLib.RigType == Enum.HumanoidRigType.R15 and R15Dances[R15Dance.Value] or R6Dances[R6Dance.Value]

            local Animator: Animator = EntityLib.Animator or EntityLib.Humanoid
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
            Name = 'Dance',
            Info = 'It makes you dance',
            Function = function(Enabled)
                if Enabled then
                    Dance:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    Dance:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if EntityLib.Alive then
                        LocalAdded()
                    end
                else
                    LocalRemoved()
                end
            end,
        })

        local R6List = {}

        for i, v in R6Dances do
            table.insert(R6List, i)
        end

        R6Dance = Dance:CreateDropdown({
            Name = 'R6 Dance',
            List = R6List,
            Function = function(Val)
                if Dance.Enabled and EntityLib.Alive and EntityLib.Humanoid.RigType == Enum.HumanoidRigType.R6 then
                    LocalRemoved()
                    Animation.AnimationId = R6Dances[R6Dance.Value]
                    LocalAdded()
                end
            end
        })

        local R15List = {}

        for i, v in R15Dances do
            table.insert(R15List, i)
        end

        R15Dance = Dance:CreateDropdown({
            Name = 'R15 Dance',
            List = R15List,
            Function = function(Val)
                if Dance.Enabled and EntityLib.Alive and EntityLib.Humanoid.RigType == Enum.HumanoidRigType.R15 then
                    LocalRemoved()
                    Animation.AnimationId = R15Dances[Val]
                    LocalAdded()
                end
            end
        })
    end)
end)

Run(function() -- Scripts
    Run(function() -- Infinite Yield
        Scripts:CreateButton({
            Name = 'Infinite Yield',
            Function = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
            end
        })
    end)

    Run(function() -- Dex
        Scripts:CreateButton({
            Name = 'Dex',
            Function = function()
                local Dex = isfile('DexModified.lua') and readfile('DexModified.lua') or game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/dex.lua')
                loadstring(Dex)()
            end
        })
    end)

    Run(function() -- Simple Spy
        Scripts:CreateButton({
            Name = 'Simple Spy',
            Function = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua'))()
            end
        })
    end)

    Run(function() -- Cobalt Spy
        Scripts:CreateButton({
            Name = 'Cobalt Spy',
            Function = function()
                loadstring(game:HttpGet('https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau'))()
            end
        })
    end)

    Run(function() -- Audio Logger
        Scripts:CreateButton({
            Name = 'Audio Logger',
            Function = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua'))()
            end
        })
    end)

    Run(function() -- Syn Save Instance
        Scripts:CreateButton({
            Name = 'Syn Save Instance',
            Function = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.lua'), 'saveinstance')({})
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
                        if typeof(v.id) == 'string' and typeof(v.playing) == 'number' and v.id ~= game.JobId then
                            if UseExtraOptions.Enabled and v.playing < MinPlayers.Value and v.playing > MaxPlayers.Value and v.ping < MinPing.Value and v.ping > MaxPing.Value then continue end
                            table.insert(Servers, {
                                JobId = v.id,
                                Ping = v.ping,
                                Players = v.playing
                            })
                        end
                    end
                end

                table.sort(Servers, Priorities[Priority.Value])

                if #Servers > 0 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, Servers[1].JobId, Plr)
                else
                    Notify({
                        Text = 'Failed to find any servers',
                        Duration = 5,
                        Type = 'Error'
                    })
                end
            end
        })

        Priority = ServerHop:CreateDropdown({
            Name = 'Priority',
            List = {'Low Players', 'High Players', 'Low Ping', 'High Ping'}
        })

        UseExtraOptions = ServerHop:CreateToggle({
            Name = 'Use Extra Options',
        })

        MinPlayers = UseExtraOptions:CreateSlider({
            Name = 'Min Players',
            Default = 0,
            Min = 0,
            Max = 10
        })

        MaxPlayers = UseExtraOptions:CreateSlider({
            Name = 'Max Players',
            Default = 100,
            Min = 0,
            Max = 100
        })

        MinPing = UseExtraOptions:CreateSlider({
            Name = 'Min Ping',
            Default = 0,
            Min = 0,
            Max = 50
        })

        MaxPing = UseExtraOptions:CreateSlider({
            Name = 'Max Ping',
            Default = 100,
            Min = 0,
            Max = 100
        })
    end)
    
    Run(function() -- Rejoin
        Server:CreateButton({
            Name = 'Rejoin',
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
            Name = 'Copy GameId',
            Function = function()
                if not setclipboard then NotifyPoopSploit('setclipboard') return end
                setclipboard(tostring(game.GameId))
                Notify({
                    Text = 'Copied game Id to clipboard',
                    Duration = 5
                })
            end
        })
    end)

    Run(function() -- Notify GameId
        Server:CreateButton({
            Name = 'Notify GameId',
            Function = function()
                Notify({
                    Text = tostring(game.GameId),
                    Duration = 10
                })
            end
        })
    end)

    Run(function() -- Copy PlaceId
        Server:CreateButton({
            Name = 'Copy PlaceId',
            Function = function()
                if not setclipboard then NotifyPoopSploit('setclipboard') return end
                setclipboard(tostring(game.PlaceId))
                Notify({
                    Text = 'Copied place Id to clipboard',
                    Duration = 5
                })
            end
        })
    end)

    Run(function() -- Notify PlaceId
        Server:CreateButton({
            Name = 'Notify PlaceId',
            Function = function()
                Notify({
                    Text = tostring(game.PlaceId),
                    Duration = 10
                })
            end
        })
    end)

    Run(function() -- Copy JobId
        Server:CreateButton({
            Name = 'Copy JobId',
            Function = function()
                if not setclipboard then NotifyPoopSploit('setclipboard') return end
                setclipboard(tostring(game.JobId))
                Notify({
                    Text = 'Copied job Id to clipboard',
                    Duration = 5
                })
            end
        })
    end)

    Run(function() -- Copy Root Position
        Server:CreateButton({
            Name = 'Copy Root Position',
            Function = function()
                if not setclipboard then NotifyPoopSploit('setclipboard') return end
                if not EntityLib.Alive then return end

                local Position = vector.floor(EntityLib.Root.Position * 100)
                setclipboard(`{Position.X / 100}, {Position.Y / 100}, {Position.Z / 100}`)
                Notify({
                    Text = 'Copied root position to clipboard',
                    Duration = 5
                })
            end
        })
    end)

    Run(function()
        Server:CreateButton({
            Name = 'Notify Root Position',
            Function = function()
                if not EntityLib.Alive then return end
                Notify({
                    Text = tostring(vector.floor(EntityLib.Root.Position)),
                    Duration = 10
                })
            end
        })
    end)

    Run(function() -- Copy WalkSpeed
        Server:CreateButton({
            Name = 'Copy WalkSpeed',
            Function = function()
                if not setclipboard then NotifyPoopSploit('setclipboard') return end
                if not EntityLib.Alive then return end
                setclipboard(tostring(math.floor(EntityLib.Humanoid.WalkSpeed * 100) / 100))
                Notify({
                    Text = 'Copied WalkSpeed to clipboard',
                    Duration = 5
                })
            end
        })
    end)

    Run(function() -- Notify WalkSpeed
        Server:CreateButton({
            Name = 'Notify WalkSpeed',
            Function = function()
                if not EntityLib.Alive then return end
                Notify({
                    Text = tostring(math.floor(EntityLib.Humanoid.WalkSpeed * 10) / 10),
                    Duration = 10
                })
            end
        })
    end)

    Run(function() -- Copy JumpPower
        Server:CreateButton({
            Name = 'Copy JumpPower',
            Function = function()
                if not setclipboard then NotifyPoopSploit('setclipboard') return end
                if not EntityLib.Alive then return end
                setclipboard(tostring(math.floor(EntityLib.Humanoid.JumpPower * 100) / 100))
                Notify({
                    Text = 'Copied JumpPower to clipboard',
                    Duration = 5
                })
            end
        })
    end)
    
    Run(function() -- Notify JumpPower
        Server:CreateButton({
            Name = 'Notify JumpPower',
            Function = function()
                if not EntityLib.Alive then return end
                Notify({
                    Text = tostring(math.floor(EntityLib.Humanoid.JumpPower * 100) / 100),
                    Duration = 10
                })
            end
        })
    end)

    Run(function() -- Notify Velocity
        Server:CreateButton({
            Name = 'Notify Velocity',
            Function = function()
                if not EntityLib.Alive then return end
                Notify({
                    Text = tostring(math.floor(vector.magnitude(EntityLib.Root.AssemblyLinearVelocity) * 10) / 10),
                    Duration = 10
                })
            end
        })
    end)

    Run(function() -- Copy Fov
        Server:CreateButton({
            Name = 'Copy Fov',
            Function = function()
                if not setclipboard then NotifyPoopSploit('setclipboard') return end
                setclipboard(tostring(math.floor(Camera.FieldOfView)))
                Notify({
                    Text = 'Copied Fov to clipboard',
                    Duration = 5
                })
            end
        })
    end)

    Run(function() -- Notify Fov
        Server:CreateButton({
            Name = 'Notify Fov',
            Function = function()
                if not EntityLib.Alive then return end
                Notify({
                    Text = tostring(math.floor(Camera.FieldOfView)),
                    Duration = 10
                })
            end
        })
    end)
end)

Run(function() -- Hud
    local HudMenu = TidalWave.Menus.HUD

    function HudMenu:CreateLabel(Properties)
        local Option, TextSize, TextColor, BackgroundColor, OutlineColor, OutlineThickness, Font, CornerRadius, TopLeftRadius, TopRightRadius, BottomLeftRadius, BottomRightRadius, SizeX, SizeY
        local Label, Corner, Outline

        Option = HudMenu:CreateOption({
            Name = Properties.Name,
            Function = function(Enabled)
                Label.Visible = Enabled
                Properties.Function(Enabled)
            end
        })

        TextSize = Option:CreateSlider({
            Name = 'Text Size',
            Default = 16,
            Min = 8,
            Max = 32,
            Clamp = {1, 100},
            Function = function(Val)
                Label.TextSize = Val
            end
        })

        TextColor = Option:CreateColorPicker({
            Name = 'Text Color',
            Default = Color3.White,
            Function = function(Color, Transparency)
                Label.TextColor3 = Color
                Label.TextTransparency = Transparency
            end
        })

        BackgroundColor = Option:CreateColorPicker({
            Name = 'Background Color',
            Default = Color3.Black,
            Transparency = 0.5,
            Function = function(Color, Transparency)
                Label.BackgroundColor3 = Color
                Label.BackgroundTransparency = Transparency
            end
        })

        OutlineColor = Option:CreateColorPicker({
            Name = 'Outline Color',
            Default = Color3.Black,
            Function = function(Color, Transparency)
                Outline.Color = Color
                Outline.Transparency = Transparency
            end
        })

        OutlineThickness = Option:CreateSlider({
            Name = 'Outline Thickness',
            Default = 1,
            Min = 0,
            Max = 5,
            Function = function(Val)
                Outline.Thickness = Val
            end
        })

        Option:CreateDropdown({
            Name = 'Corner Mode',
            List = {'Single', 'Specific'},
            Function = function(Val)
                CornerRadius:SetVisible(Val == 'Single')
                for _, v in {TopLeftRadius, TopRightRadius, BottomLeftRadius, BottomRightRadius} do
                    v:SetVisible(Val == 'Specific')
                end
                if Val == 'Single' then
                    Corner.CornerRadius = UDim.new(0, CornerRadius.Value)
                else
                    Corner.CornerRadius = UDim.new(0, 0)
                    Corner.TopLeftRadius = UDim.new(0, TopLeftRadius.Value)
                    Corner.TopRightRadius = UDim.new(0, TopLeftRadius.Value)
                    Corner.BottomLeftRadius = UDim.new(0, TopLeftRadius.Value)
                    Corner.BottomRightRadius = UDim.new(0, TopLeftRadius.Value)
                end
            end
        })

        local function CreateRadiusSlider(Name)
            local Property = Name:gsub(' ', '')
            return Option:CreateSlider({
                Name = Name,
                Default = 5,
                Min = 0,
                Max = 25,
                Visible = Name == 'Corner Radius',
                Function = function(Val)
                    Corner[Property] = UDim.new(0, Val)
                end
            })
        end

        CornerRadius = CreateRadiusSlider('Corner Radius')
        TopLeftRadius = CreateRadiusSlider('Top Left Radius')
        TopRightRadius = CreateRadiusSlider('Top Right Radius')
        BottomLeftRadius = CreateRadiusSlider('Bottom Left Radius')
        BottomRightRadius = CreateRadiusSlider('Bottom Right Radius')

        Font = Option:CreateFont({
            Name = 'Font',
            Function = function(Font)
                Label.FontFace = Font
            end,
        })

        SizeX = Option:CreateSlider({
            Name = 'X Size',
            Default = 100,
            Min = 50,
            Max = 150,
            Function = function(Val)
                Label.Size = UDim2.fromOffset(Val, Label.Size.Y.Offset)
            end
        })

        SizeY = Option:CreateSlider({
            Name = 'Y Size',
            Default = 40,
            Min = 20,
            Max = 60,
            Function = function(Val)
                Label.Size = UDim2.fromOffset(Label.Size.X.Offset, Val)
            end
        })

        Label = Instance.new('TextLabel')
        Label.Name = Properties.Name
        Label.TextSize = TextSize.Value
        Label.FontFace = Font.Font
        Label.TextColor3 = TextColor.Color
        Label.TextTransparency = TextColor.Transparency
        Label.BackgroundColor3 = BackgroundColor.Color
        Label.BackgroundTransparency = BackgroundColor.Transparency
        Label.BorderSizePixel = 0
        Label.Size = UDim2.fromOffset(SizeX.Value, SizeY.Value)
        Label.Position = UDim2.fromOffset(0, 60)
        Label.Text = Properties.Text
        Label.Visible = false
        Label.Parent = TidalWave.Gui.ScaledGui.Hud

        Corner = Instance.new('UICorner')
        Corner.CornerRadius = UDim.new(0, CornerRadius.Value)
        Corner.Parent = Label

        Outline = Instance.new('UIStroke')
        Outline.Thickness = OutlineThickness.Value
        Outline.Color = OutlineColor.Color
        Outline.Transparency = OutlineColor.Transparency
        Outline.BorderStrokePosition = Enum.BorderStrokePosition.Inner
        Outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Outline.Parent = Label

        Option.Label = Label

        return Option
    end

    Run(function() -- FPS
        local FPS, UpdateInterval

        --[[
            Grabbing an accurate count of the current framerate
            Source: https://devforum.roblox.com/t/get-client-FPS-trough-a-script/282631
        ]]

        FPS = HudMenu:CreateLabel({
            Name = 'FPS',
            Text = '0 FPS',
            Function = function(Enabled)
                if Enabled then
                    local Frames = {}
                    local Start = os.clock()
                    local UpdateClock = Start

                    FPS:Clean(RunService.Heartbeat:Connect(function()
                        local Clock = os.clock()
                        for i = #Frames, 1, -1 do
                            Frames[i + 1] = Frames[i] >= Clock - 1 and Frames[i] or nil
                        end

                        Frames[1] = Clock
                        if UpdateClock < Clock then
                            UpdateClock = Clock + UpdateInterval.Value
                            FPS.Label.Text = `{math.floor(Clock - Start >= 1 and #Frames or #Frames / (Clock - Start))} FPS`
                        end
                    end))
                end
            end
        })

        UpdateInterval = FPS:CreateSlider({
            Name = 'Update Interval',
            Default = 0.1,
            Min = 0.05,
            Max = 1,
            Decimal = 100,
            Clamp = {0, 1}
        })
    end)

    Run(function() -- Ping
        local Ping, UpdateInterval
        
        Ping = HudMenu:CreateLabel({
            Name = 'Ping',
            Text = '0 ms',
            Function = function(Enabled)
                if Enabled then
                    while Ping.Enabled do
                        Ping.Label.Text = `Ping: {math.floor(Stats.PerformanceStats.Ping:GetValue())}`
                        task.wait(UpdateInterval.Value)
                    end
                end
            end
        })

        UpdateInterval = Ping:CreateSlider({
            Name = 'Update Interval',
            Default = 0.5,
            Min = 0.25,
            Max = 1,
            Decimal = 100,
            Clamp = {0, 1}
        })
    end)

    Run(function() -- SpeedMeter
        local SpeedMeter, UpdateInterval, Decimal, Mode

        SpeedMeter = HudMenu:CreateLabel({
            Name = 'SpeedMeter',
            Text = '0 sps',
            Function = function(Enabled)
                if Enabled then
                    while SpeedMeter.Enabled do
                        if EntityLib.Alive then
                            if Mode.Value == 'Velocity' then
                                local Magnitude = vector.magnitude(EntityLib.Root.AssemblyLinearVelocity * vector.hort)
                                SpeedMeter.Label.Text = `{math.floor(Magnitude * Decimal.Value) / Decimal.Value} sps`
                                task.wait(UpdateInterval.Value)
                            else
                                local LastPosition = EntityLib.Root.Position * vector.hort
                                local Delta = task.wait(UpdateInterval.Value)
                                if not EntityLib.Alive then continue end
                                local CurrentPosition = EntityLib.Root.Position * vector.hort
                                local Diff = (LastPosition - CurrentPosition) * (1 / Delta)
                                local Magnitude = vector.magnitude(Diff)
                                SpeedMeter.Label.Text = `{math.floor(Magnitude * Decimal.Value) / Decimal.Value} sps`
                            end
                        else
                            task.wait(UpdateInterval.Value)
                        end
                    end
                end
            end
        })

        UpdateInterval = SpeedMeter:CreateSlider({
            Name = 'Update Interval',
            Default = 0.1,
            Min = 0.05,
            Max = 1,
            Decimal = 100,
            Clamp = {0, 1}
        })

        Decimal = SpeedMeter:CreateSlider({
            Name = 'Decimal',
            Default = 1,
            Min = 1,
            Max = 100,
            Clamp = {1, 100000}
        })

        Mode = SpeedMeter:CreateDropdown({
            Name = 'Mode',
            List = {'Magnitude', 'Velocity'},
            Info = 'Magnitude - Calculates the distance you traveled\nVelocity - Shows your current velocity',
            Function = function()
                if SpeedMeter.Enabled then
                    SpeedMeter:Toggle(true)
                    SpeedMeter:Toggle(true)
                end
            end
        })
    end)
end)