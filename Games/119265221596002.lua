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

local getconnections = getconnections
local hookfunction = hookfunction
local restorefunction = restorefunction

local ViewmodelTool
local ViewmodelMotor

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

Modules.Speed.Options.Method:SetValue('CFrame')
Modules.Fly.Options.FlyMethod:SetValue('CFrame')
Modules.Spider.Options.Method:SetValue('CFrame')
Modules.LongJump.Options.Method:SetValue('CFrame')
Modules.HighJump.Options.Method:SetValue('CFrame')

local function Run(f)
    f()
end

local function Notify(Properties)
    TidalWave:Notify(Properties)
end

function EntityLib:CanAttack(Ent)
    return Ent.Health > 0 and Ent.Root.Position.Y < 135
end

TidalWave:Clean(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
    Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')
end))

Run(function() -- Combat
    Run(function() -- KillAura
        local KillAura, Range, WallCheck, AngleCheck, MaxTargets, RequireMouseDown, AttackInterval, SwingAnimation
        local BoxAttackColor, ParticleTexture, ParticleColor1,  ParticleColor2, ParticleSize, AnimationEnabled, Animation, AnimationSpeed, UpdateRate
        local Priority, HeatSeeker, HeatSeekerSpeed, HeatSeekerRange, Target
        
        local Boxes = {}
        local Particles = {}

        local OldC0, Tween, StopTween, Attacking, Track

        local RegularAnimation = Instance.new('Animation')
        RegularAnimation.AnimationId = 'rbxassetid://84237912099957'

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

                    local Attack = ReplicatedStorage.Remotes.Attack

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

                                    local cf = CFrame.lookAt(EntityLib.Root.Position, Character.Root.Position)
                                    local Hitbox = Character.Character:FindFirstChild('Hitbox')
                                    Attack:FireServer(vector.create(cf.LookVector.X, 0, cf.LookVector.Z), Hitbox)
                                end

                                task.wait(AttackInterval.Value * #Characters)
                            else
                                Attacking = false
                                Target = nil
                            end
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
    Run(function() -- Fly
        local Fly, HorizontalSpeed, VerticalSpeed, FlyMethod, AlignMethod, MoveMethod, Percentage, UsePercentage, UpKeybind, DownKeybind
        local W, A, S, D, E, Q

        local function GetMoveDirection()
            if MoveMethod.Value == 'MoveDirection' then
                return EntityLib.Humanoid.MoveDirection * (UsePercentage.Enabled and (EntityLib.Humanoid.WalkSpeed * (Percentage.Value / 100)) or HorizontalSpeed.Value)
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

        local AlignmentCreateFunctions = {
            AlignOrientation = function()
                local Attachment = Fly:CreateInstance('Attachment', 'Attachment2', {Name = 'RootAttachment', Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position, Parent = EntityLib.Root})
                Fly:CreateInstance('AlignOrientation', 'AlignOrientation', {Mode = Enum.OrientationAlignmentMode.OneAttachment, Attachment0 = Attachment, RigidityEnabled = true, CFrame = Camera.CFrame, Parent = workspace})
                Fly:Clean(EntityLib.Root:GetPropertyChangedSignal('AssemblyCenterOfMass'):Connect(function()
                    Attachment.Position = EntityLib.Root.AssemblyCenterOfMass - EntityLib.Root.Position
                end))
            end
        }

        local FlyMethods = {
            CFrame = function(Delta)
                EntityLib.Root.AssemblyLinearVelocity = vector.create(0, -10, 0)
                EntityLib.Character:TranslateBy((GetDirection() + vector.create(0, 11, 0)) * Delta)
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
                EntityLib.Root.CFrame = CFrame.lookAlong(EntityLib.Root.Position, Camera.CFrame.LookVector)
                EntityLib.Root.AssemblyAngularVelocity = vector.zero
            end
        }

        local function LocalRemoved()
            Fly:CleanUp()
            Fly:ClearInstances()
        end

        local function LocalAdded()
            LocalRemoved()
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
                        Modules.Speed:DisableMovers()
                    end
                    
                    W, A, S, D, E, Q = UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0, UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0, UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0, UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0, UpKeybind:IsPressed() and 1 or 0, DownKeybind:IsPressed() and 1 or 0

                    if EntityLib.Alive then
                        LocalAdded()
                    end
                    Fly:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    Fly:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    Fly:Clean(RunService.PreRender:Connect(function()
                        if AlignMethod.Value ~= "None" and EntityLib.Alive then
                            AlignMethods[AlignMethod.Value]()
                        end
                    end))
                    Fly:Clean(RunService.PreSimulation:Connect(function(Delta)
                        if not EntityLib.Alive then return end
                        FlyMethods[FlyMethod.Value](Delta)
                    end))
                    
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
                    Modules.Speed:EnableMovers()
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
            Name = "Fly Method",
            List = {'CFrame'}
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

    Run(function() -- Velocity
        local Velocity, Horizontal, Vertical, Chance

        local Rand = Random.new()

        local function CreateVelocity(Parent, Vel)
            local LinearVelocity = Instance.fromExisting(ReplicatedStorage.KnockbackVelocity)
            LinearVelocity.VectorVelocity = Vel
            LinearVelocity.Attachment0 = Parent
            LinearVelocity.Parent = Parent

            task.wait(0.1)

            LinearVelocity:Destroy()
        end
        
        Velocity = Movement:CreateModule({
            Name = 'Velocity',
            Info = 'Modifies your knockback velocity.',
            Enabled = function()
                if getconnections and hookfunction then
                    local Connection
                    repeat
                        Connection = getconnections(ReplicatedStorage.Remotes.Knockback.OnClientEvent)[1]
                        task.wait()
                    until Connection or not Velocity.Enabled

                    if not Velocity.Enabled then return end

                    local Old; Old = hookfunction(Connection.Function, function(Parent, Vel)
                        if Rand:NextNumber(0, 100) > Chance.Value then return Old(Parent, Vel) end

                        local Hort = Horizontal.Value / 100
                        local Vert = Vertical.Value / 100

                        if Hort == 0 and Vert == 0 then return end

                        return Old(Parent, vector.create(Vel.X * Hort, Vel.Y * Vert, Vel.Z * Hort))
                    end)

                    Velocity:Clean(function()
                        if restorefunction then
                            restorefunction(Connection.Function)
                        else
                            hookfunction(Connection.Function, Old)
                        end
                    end)
                else
                    Plr.PlayerScripts.Knockback.Enabled = false
                    Velocity:Clean(ReplicatedStorage.Remotes.Knockback.OnClientEvent:Connect(function(Parent, Vel)
                        if Rand:NextNumber(0, 100) > Chance.Value then CreateVelocity(Parent, Vel) return end
                            
                        local Hort = Horizontal.Value / 100
                        local Vert = Vertical.Value / 100

                        if Hort == 0 and Vert == 0 then return end

                        CreateVelocity(Parent, vector.create(Vel.X * Hort, Vel.Y * Vert, Vel.Z * Hort))
                    end))

                    Velocity:Clean(function()
                        Plr.PlayerScripts.Knockback.Enabled = true
                    end)
                end
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

        local OldTool, Handle, Mesh

        const Offset = CFrame.new(2.6, -1, -4)
        const Rotation = CFrame.Angles(math.rad(90), 0, 0)
        const SwordRotation = CFrame.Angles(math.rad(90), math.rad(-90), 0)
        const AxeRotation = CFrame.Angles(math.rad(-90), math.rad(-90), 0)

        local function ChildAdded(Child)
            OldTool = Child
            local TimeOut = os.clock() + 5
            repeat
                Handle = Child:FindFirstChild('HandlePart')
                task.wait()
            until Handle or not Viewmodel.Enabled or os.clock() >= TimeOut

            if not (Viewmodel.Enabled and Handle) then return end

            ViewmodelTool = Instance.new('Part')
            ViewmodelTool.CanCollide = false
            ViewmodelTool.Massless = true
            ViewmodelTool.Anchored = true
            ViewmodelTool.Size = vector.one
            ViewmodelTool.Transparency = 1
            ViewmodelTool.Parent = Camera
            
            Mesh = Instance.fromExisting(Handle)
            Mesh.CanCollide = false
            Mesh.Massless = true
            Mesh.Anchored = true
            Mesh.Parent = ViewmodelTool
            Mesh.LocalTransparencyModifier = 0
            Handle.LocalTransparencyModifier = 1
        end
        
        Viewmodel = Visuals:CreateModule({
            Name = 'Viewmodel',
            Info = 'Replaces the default viewmodel',
            Function = function(Enabled)
                if Enabled then
                    ViewmodelMotor = Instance.new('Motor6D')

                    Viewmodel:Clean(workspace.WeaponsContainer[Plr.UserId].ChildAdded:Connect(function(Child)
                        ChildAdded(Child)
                    end))

                    Viewmodel:Clean(workspace.WeaponsContainer[Plr.UserId].ChildRemoved:Connect(function(Child)
                        if Child == OldTool then
                            if ViewmodelTool then
                                ViewmodelTool:Destroy()
                                ViewmodelTool = nil
                            end
                            OldTool = nil
                            Handle = nil
                        end
                    end))

                    local Child = workspace.WeaponsContainer[Plr.UserId]:GetChildren()[1]

                    if Child then
                        ChildAdded(Child)
                    end

                    Viewmodel:Clean(RunService.PreRender:Connect(function()
                        if ViewmodelTool then
                            ViewmodelTool.CFrame = (Camera.CFrame * Offset * Rotation) * ViewmodelMotor.C0
                            Mesh.CFrame = ViewmodelTool.CFrame * (OldTool.Name == 'Sword' and SwordRotation or AxeRotation)
                            local ThirdPerson = vector.magnitude(Camera.CFrame.Position - Camera.Focus.Position) > 0.6
                            Mesh.LocalTransparencyModifier = ThirdPerson and 1 or 0
                            Handle.LocalTransparencyModifier = ThirdPerson and 0 or 1
                        end
                    end))
                else
                    if Handle then
                        Handle.LocalTransparencyModifier = 0
                        Handle = nil
                    end
                    
                    OldTool = nil
                    Mesh = nil

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
                    Part.Position = vector.create(0, -8, 0)
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
            List = {'Velocity', 'Collide'},
            Function = function(Val)
                if Part then
                    Part.CanCollide = Val == 'Collide'
                end
            end,
            Info = 'Velocity - Launches you upward after touching\nCollide - Allows you to walk on the part'
        })
        
        local Materials = {'ForceField'}
        for _, v in Enum.Material:GetEnumItems() do
            if v.Name ~= 'ForceField' then
                table.insert(Materials, v.Name)
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
            Info = 'Prevents you from dying to lava.',
            Function = function(Enabled)
                workspace.Map.Lava.CanTouch = not Enabled
            end
        })
    end)
end)