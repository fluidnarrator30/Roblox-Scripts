local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local Players: Players = GetService("Players")
local ReplicatedStorage: ReplicatedStorage = GetService("ReplicatedStorage")
local RunService: RunService = GetService("RunService")
local UIS: UserInputService = GetService('UserInputService')
local TweenService: TweenService = GetService('TweenService')

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local EntityLib = TidalWave.Libraries.EntityLib
local Modules = TidalWave.Modules
local ObjectFunctions = TidalWave.Libraries.ObjectFunctions
local AuraAnimations = TidalWave.Libraries.AuraAnimations

local Plr = Players.LocalPlayer
local Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')

local Combat = Categories.Combat
local PlayerCategory = Categories.Player
local Movement = Categories.Movement
local Visuals = Categories.Visuals
local World = Categories.World
local Other = Categories.Other

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
vector.unit = vector.normalize
function vector.round(Vec)
    return vector.create(math.round(Vec.X), math.round(Vec.Y), math.round(Vec.Z))
end

local ViewmodelTool
local ViewmodelMotor

TidalWave:Clean(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
    Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')
end))

local function Run(f)
    f()
end

local function Notify(Properties)
    TidalWave:Notify(Properties)
end

local function NotifyPoopSploit(Function)
    Notify({
        Title = 'Poop Sploit',
        Text = `Your executor doesn't support '{Function}'`,
        Type = 'Error',
        Duration = 5,
    })
end

local function SafeRef(Obj, Path)
    return ObjectFunctions:SafeRef(Obj, Path)
end

Run(function() -- EntityLib
    function EntityLib:CanAttack(Character)
        local LocalSafeZone = Plr:FindFirstChild('SafeZone')
        local SafeZone = Character.Player:FindFirstChild('SafeZone')
        return Character.Health > 0 and (SafeZone and not SafeZone.Value) and (LocalSafeZone and not LocalSafeZone.Value)
    end
end)

Run(function() -- Combat
    Run(function() -- KillAura
        local KillAura, Range, WallCheck, AngleCheck, MaxTargets, RequireMouseDown, AttackInterval, SwingAnimation
        local BoxAttackColor, ParticleTexture, ParticleColor1,  ParticleColor2, ParticleSize, AnimationEnabled, Animation, AnimationSpeed, UpdateRate
        local Priority, HeatSeeker, HeatSeekerSpeed, HeatSeekerRange, Target
        
        local Boxes = {}
        local Particles = {}

        local OldC0, Tween, StopTween, Attacking, Track

        local RegularAnimation = Instance.new('Animation')
        RegularAnimation.AnimationId = 'rbxassetid://14745200410'

        local Weakest = function(a, b)
            return a.Character.Health < b.Character.Health
        end

        local function MouseCheck()
            if RequireMouseDown.Enabled and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                return false
            end

            return true
        end

        KillAura = Combat:CreateModule({
            Name = 'KillAura',
            Info = 'Automatically attacks the closest player.',
            Function = function(Enabled)
                if Enabled then
                    if HeatSeeker.Enabled then
                        KillAura:Clean(RunService.PreSimulation:Connect(function(Delta)
                            if EntityLib.Alive and Target then
                                local Direction = ((Target.Root.Position + (Target.Humanoid.MoveDirection * 5)) - EntityLib.Root.Position).Unit
                                EntityLib.Character:TranslateBy(Direction * EntityLib.Humanoid.WalkSpeed * HeatSeekerSpeed.Value * Delta)
                            end
                        end))
                    end

                    if EntityLib.Alive then
                        local Animator = EntityLib.Animator or EntityLib.Humanoid
                        Track = Animator:LoadAnimation(RegularAnimation)
                    end

                    KillAura:Clean(EntityLib.Events.LocalAdded:Connect(function()
                        local Animator = EntityLib.Animator or EntityLib.Humanoid
                        Track = Animator:LoadAnimation(RegularAnimation)
                    end))

                    KillAura:Clean(EntityLib.Events.LocalRemoved:Connect(function()
                        Track = nil
                    end))

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
                                            Tween = TweenService:Create(ViewmodelMotor, TweenInfo.new(First and 0.1 or Keyframe.Duration / AnimationSpeed.Value, Enum.EasingStyle.Linear), {C0 = OldC0 * Keyframe.CFrame})
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

                    local HitEvent = ReplicatedStorage.Remotes.Hit

                    while KillAura.Enabled do
                        local Attacked = {}
                        if EntityLib.Alive and MouseCheck() then
                            local Characters = EntityLib:GetClosestEntities({
                                Range = HeatSeeker.Enabled and HeatSeekerRange.Value or Range.Value,
                                WallCheck = WallCheck.Enabled,
                                Players = true,
                                Sort = Priority.Value == 'Weakest' and Weakest or nil,
                                Limit = MaxTargets.Value,
                            })

                            if #Characters > 0 then
                                Target = Characters[1]

                                local LookVector = EntityLib.Root.CFrame.LookVector * vector.hort
                                local MaxAngle = math.rad(AngleCheck.Value) / 2

                                for i, Character in Characters do
                                    if HeatSeeker.Enabled and (EntityLib.Root.Position - Character.Root.Position).Magnitude > Range.Value then continue end
                                    
                                    if AngleCheck.Value < 360 then
                                        local Direction = (Character.Root.Position - EntityLib.Root.Position)
                                        local Unit = vector.normalize(Direction * vector.hort)
                                        local Dot = vector.dot(LookVector, Unit)
                                        local Angle = math.acos(Dot)
                                        if Angle > MaxAngle then continue end
                                    end

                                    table.insert(Attacked, Character)

                                    Attacking = true

                                    if SwingAnimation.Enabled and Track then
                                        Track:Play()
                                    end

                                    HitEvent:FireServer({
                                        [Character.Player.Name] = {
                                            Victim = Character.Player,
                                            Vector = CFrame.lookAt(EntityLib.Root.Position, Character.Root.Position).LookVector
                                        }
                                    })
                                end

                                task.wait(AttackInterval.Value * #Characters)
                            else
                                Attacking = false
                                Target = nil
                            end
                        end

                        if setthreadidentity then
                            setthreadidentity(8)
                        end

                        for i, Box in Boxes do
                            local Character = Attacked[i]
                            Box.Adornee = Character and Character.Root or nil
                            if Character then
                                Box.Color3 = BoxAttackColor.Color
                                Box.Transparency = BoxAttackColor.Transparency
                            end
                        end

                        for i, Particle in Particles do
                            local Character = Attacked[i]
                            Particle.Position = Character and Character.Root.Position or vector.huge
                            Particle.Parent = Character and Camera or nil
                        end

                        task.wait()
                    end
                else
                    if Track then
                        Track:Stop()
                        Track:Destroy()
                        Track = nil
                    end
                    Target = nil
                    Attacking = nil
                end
            end
        })

        WallCheck = KillAura:CreateToggle({
            Name = 'Wall Check',
            Info = 'Ignores players behind walls.',
        })

        Range = KillAura:CreateSlider({
            Name = 'Range',
            Default = 7,
            Min = 1,
            Max = 7,
            Decimal = 10
        })

        AngleCheck = KillAura:CreateSlider({
            Name = 'Max Angle',
            Default = 360,
            Min = 1,
            Max = 360,
        })

        MaxTargets = KillAura:CreateSlider({
            Name = 'Max Targets',
            Default = 10,
            Min = 1,
            Max = 10
        })

        RequireMouseDown = KillAura:CreateToggle({
            Name = 'Require Mouse Down'
        })

        AttackInterval = KillAura:CreateSlider({
            Name = 'Attack Interval',
            Default = 0.15,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Clamp = {0, 1}
        })

        SwingAnimation = KillAura:CreateToggle({
            Name = 'Swing Animation',
            Info = 'Plays the sword swing animation',
            Default = true
        })

        Priority = KillAura:CreateDropdown({
            Name = 'Priority',
            List = {'Closest', 'Weakest'},
            Info = 'Closest - Targets the closest players\nWeakest - Targets players with the lowest health'
        })

        HeatSeeker = KillAura:CreateToggle({
            Name = 'Heat Seeker',
            Info = 'Guides your character towards the current target',
            Function = function(Enabled)
                if KillAura.Enabled then
                    KillAura:Toggle(true)
                    KillAura:Toggle(true)
                end
            end
        })

        HeatSeekerSpeed = HeatSeeker:CreateSlider({
            Name = 'Heat Seeker Speed',
            Default = 1,
            Min = 0.5,
            Max = 2,
            Decimal = 100
        })

        HeatSeekerRange = HeatSeeker:CreateSlider({
            Name = 'Heat Seeker Range',
            Default = 7,
            Min = 1,
            Max = 14
        })

        KillAura:CreateToggle({
            Name = 'Show target',
            Function = function(Enabled)
                if Enabled then
                    local KillAuraTargets = Instance.new('Folder')
                    KillAuraTargets.Name = 'KillAuraTargets'
                    KillAuraTargets.Parent = TidalWave.Gui
                    
                    TidalWave:Clean(KillAuraTargets)
                    
                    for i = 1, 10 do
                        local Box = Instance.new('BoxHandleAdornment')
                        Box.Adornee = nil
                        Box.AlwaysOnTop = true
                        Box.Size = Vector3.new(3, 5, 3)
                        Box.CFrame = CFrame.new(0, -0.5, 0)
                        Box.ZIndex = 0
                        Box.Parent = KillAuraTargets

                        Boxes[i] = Box
                    end
                else
                    table.clear(Boxes)
                end
            end
        })

        BoxAttackColor = KillAura:CreateColorPicker({
            Name = 'Attack Color',
            Color = Color3.fromRGB(255, 0, 0),
            Transparency = 0.5,
        })

        local TargetParticles = KillAura:CreateToggle({
            Name = 'Target Particles',
            Function = function(Enabled)
                if Enabled then
                    for i = 1, 10 do
                        local Part = Instance.new('Part')
                        Part.Size = Vector3.new(2, 4, 2)
                        Part.Anchored = true
                        Part.CanCollide = false
                        Part.Transparency = 1
                        Part.CanQuery = false
                        Part.Parent = KillAura.Enabled and Camera or nil

                        local Particle = Instance.new('ParticleEmitter')
                        Particle.Brightness = 1.5
                        Particle.Size = NumberSequence.new(ParticleSize.Value)
                        Particle.Shape = Enum.ParticleEmitterShape.Sphere
                        Particle.Texture = ParticleTexture.Value
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
                    for _, v in Particles do
                        v:Destroy()
                    end
                    table.clear(Particles)
                end
            end
        })

        ParticleTexture = TargetParticles:CreateAssetTextBox({
            Name = 'Texture',
            Default = 'rbxassetid://14736249347',
            Function = function(Asset)
                for _, Particle in Particles do
                    Particle.ParticleEmitter.Texture = Asset
                end
            end,
        })

        ParticleColor1 = TargetParticles:CreateColorPicker({
            Name = 'Color Begin',
            Function = function(Color)
                for _, Particle in Particles do
                    Particle.ParticleEmitter.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color),
                        ColorSequenceKeypoint.new(1, ParticleColor2.Color)
                    })
                end
            end,
        })

        ParticleColor2 = TargetParticles:CreateColorPicker({
            Name = 'Color End',
            Function = function(Color)
                for _, Particle in Particles do
                    Particle.ParticleEmitter.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, ParticleColor1),
                        ColorSequenceKeypoint.new(1, Color)
                    })
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
                for _, Particle in Particles do
                    Particle.ParticleEmitter.Size = NumberSequence.new(Val)
                end
            end,
        })

        AnimationEnabled = KillAura:CreateToggle({
            Name = 'Custom Animation',
            Info = 'Requires the Viewmodel Module inside Visuals category for this to work',
            Function = function()
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

        UpdateRate = AnimationEnabled:CreateSlider({
            Name = 'Update Rate',
            Default = 60,
            Min = 10,
            Max = 240
        })
    end)
end)

Run(function() -- Movement
    Run(function() -- Velocity
        local Velocity, Horizontal, Vertical, Chance, Connection, Old

        local Rand = Random.new()

        local function ScriptAdded()
            repeat
                for _, v in getconnections(ReplicatedStorage.Remotes.ApplyImpulse.OnClientEvent) do
                    if v.Function and debug.info(v.Function, 's'):match('LocalInputHandling') then
                        Connection = v
                        break
                    end
                end
                task.wait()
            until Connection or not Velocity.Enabled

            if not (Velocity.Enabled and Connection and Connection.Function) then return end

            Old = hookfunction(Connection.Function, function(Vel, Attacker)
                if Rand:NextNumber(1, 100) >= Chance.Value then
                    local Hort = Horizontal.Value / 100
                    local Vert = Vertical.Value / 100

                    return Old(vector.create(Vel.X * Hort, Vel.Y * Vert, Vel.Z * Hort), Attacker)
                end

                return Old(Vel, Attacker)
            end)
        end
        
        Velocity = Movement:CreateModule({
            Name = 'Velocity',
            Info = 'Modifies your knockback velocity.',
            Enabled = function()
                if not hookfunction then NotifyPoopSploit('hookfunction') return end
                if not getconnections then NotifyPoopSploit('getconnections') return end
                
                Velocity:Clean(Plr.PlayerGui.ChildAdded:Connect(function(Child)
                    if Child.Name == 'MobileButtons' then
                        local New = Child:WaitForChild('New', 5)
                        local LocalInputHandling = New and New:WaitForChild('LocalInputHandling', 5)
                        if LocalInputHandling then
                            ScriptAdded()
                        end
                    end
                end))

                local LocalInputHandling = SafeRef(Plr.PlayerGui, {'New', 'LocalInputHandling'})
                if LocalInputHandling then
                    ScriptAdded()
                end

                Velocity:Clean(function()
                    if Connection and Connection.Function then
                       if restorefunction then
                            restorefunction(Connection.Function)
                        elseif Old then
                            hookfunction(Connection.Function, Old)
                        end
                    end
                end)
            end,
        })

        Horizontal = Velocity:CreateSlider({
            Name = 'Horizontal',
            Default = 0,
            Min = 0,
            Max = 100,
            Suffix = '%'
        })

        Vertical = Velocity:CreateSlider({
            Name = 'Vertical',
            Default = 0,
            Min = 0,
            Max = 100,
            Suffix = '%'
        })

        Chance = Velocity:CreateSlider({
            Name = 'Chance',
            Default = 100,
            Min = 0,
            Max = 100,
            Suffix = '%'
        })
    end)
end)

Run(function() -- Visuals
    Run(function() -- Viewmodel
        local Viewmodel
        local OldTool, Handle, Enchantment

        local function ChildAdded(Child)
            OldTool = Child
            local TimeOut = os.clock() + 5
            repeat
                for i, v in OldTool:GetChildren() do
                    if v ~= OldTool.PrimaryPart and v.Name ~= 'Enchantment' then
                        Handle = v
                        break
                    end
                end
                task.wait()
            until Handle or not Viewmodel.Enabled or os.clock() >= TimeOut

            if not (Viewmodel.Enabled and Handle) then return end

            Enchantment = OldTool:FindFirstChild('Enchantment')
            if Enchantment then
                Enchantment.LocalTransparencyModifier = 1
            end
            
            ViewmodelTool = Instance.fromExisting(Handle)
            ViewmodelTool.CanCollide = false
            ViewmodelTool.Massless = true
            ViewmodelTool.Anchored = true
            ViewmodelTool.Parent = Camera
            ViewmodelTool.LocalTransparencyModifier = 0
            Handle.LocalTransparencyModifier = 1
        end
        
        Viewmodel = Visuals:CreateModule({
            Name = 'Viewmodel',
            Info = 'Replaces the default viewmodel',
            Function = function(Enabled)
                if Enabled then
                    ViewmodelMotor = Instance.new('Motor6D')

                    Viewmodel:Clean(workspace.ChildAdded:Connect(function(Child)
                        if Child.Name:match(`{Plr.Name}%u%w+%u%w+`) then
                            ChildAdded(Child)
                        end
                    end))

                    Viewmodel:Clean(workspace.ChildRemoved:Connect(function(Child)
                        if Child == OldTool then
                            if ViewmodelTool then
                                ViewmodelTool:Destroy()
                                ViewmodelTool = nil
                            end
                            OldTool = nil
                            Handle = nil
                        end
                    end))

                    for _, v in workspace:GetChildren() do
                        if v.Name:match(`{Plr.Name}%u%w+%u%w+`) then
                            ChildAdded(v)
                        end
                    end

                    Viewmodel:Clean(RunService.PreRender:Connect(function()
                        if ViewmodelTool then
                            ViewmodelTool.CFrame = (Camera.CFrame * CFrame.new(2.66, -1, -4) * CFrame.Angles(math.rad(90), 0, 0)) * ViewmodelMotor.C0
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
                    if Enchantment then
                        Enchantment.LocalTransparencyModifier = 0
                        Enchantment = nil
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
    end)
end)

Run(function() -- World
    Run(function() -- AntiFall
        local AntiFall, Method, Material, Color, Part

        AntiFall = World:CreateModule({
            Name = 'AntiFall',
            Info = 'Prevents you from falling into the water.',
            Function = function(Enabled)
                if Enabled then
                    Part = Instance.new('Part')
                    Part.Size = vector.create(2048, 1, 2048)
                    Part.Transparency = Color.Transparency
                    Part.Material = Enum.Material[Material.Value]
                    Part.Color = Color.Color
                    Part.CanCollide = Method.Value == 'Collide'
                    Part.Anchored = true
                    Part.CanQuery = false
                    Part.Parent = workspace
                    local db = os.clock()
                    AntiFall:Clean(Part.Touched:Connect(function(Touch)
                        if Touch.Parent == EntityLib.Character and EntityLib.Alive and db < os.clock() then
                            db = os.clock() + 0.1
                            if Method.Value == 'Velocity' then
                                EntityLib.Root.Velocity = vector.create(EntityLib.Root.Velocity.X, 30, EntityLib.Root.Velocity.Z)
                            end
                        end
                    end))
                    while AntiFall.Enabled do
                        if EntityLib.Alive then
                            Part.Position = vector.create(EntityLib.Root.Position.X, 15, 8)
                        end
                        task.wait(0.4)
                    end
                else
                    if Part then
                        Part:Destroy()
                        Part = nil
                    end
                end
            end
        })

        Method = AntiFall:CreateDropdown({
            Name = 'Method',
            List = {'Velocity', 'Collide', 'CanTouch'},
            Info = 'Velocity - Launches you upward after touching\nCollide - Allows you to walk on the part\nCanTouch - Prevents the water from killing you',
            Function = function(Val)
                if Part then
                    Part.CanCollide = Val == 'Collide'
                end
            end,
        })
        
        local Materials = {'ForceField'}
        for _, v in Enum.Material:GetEnumItems() do
            if v.Name ~= 'ForceField' then
                Materials[#Materials + 1] = v.Name
            end
        end

        Material = AntiFall:CreateDropdown({
            Name = 'Material',
            List = Materials,
            Function = function(Val)
                if Part then
                    Part.Material = Enum.Material[Val]
                end
            end
        })

        Color = AntiFall:CreateColorPicker({
            Name = 'Color',
            Default = Color3.fromRGB(255, 255, 255),
            Transparency = 0.5,
            Function = function(Color, Transparency)
                if Part then
                    Part.Color = Color
                    Part.Transparency = Transparency
                end
            end
        })
    end)

    Run(function() -- AntiLava
        local AntiLava

        AntiLava = World:CreateModule({
            Name = 'AntiLava',
            Info = 'Prevents lava from killing you.',
            Function = function(Enabled)
                workspace.Interactives["Water4.5"].CanTouch = not Enabled
            end
        })
    end)

    Run(function() -- AntiCactus
        local AntiCactus

        AntiCactus = World:CreateModule({
            Name = 'AntiCactus',
            Info = 'Prevents cacti from damaging you',
            Function = function(Enabled)
                for _, Part in workspace.WorldInteractives:GetChildren() do
                    Part.CanTouch = not Enabled
                end
            end
        })
    end)
end)