local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local Players: Players = GetService("Players")
local ReplicatedStorage: ReplicatedStorage = GetService("ReplicatedStorage")
local RunService: RunService = GetService("RunService")
local TweenService: TweenService = GetService("TweenService")
local UIS: UserInputService = GetService('UserInputService')
local CollectionService: CollectionService = GetService('CollectionService')

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local EntityLib = TidalWave.Libraries.EntityLib
local Prediction = TidalWave.Libraries.Prediction
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

local hookfunction = hookfunction or hookfunc
local setthreadidentity = setthreadidentity
local getconnections = getconnections or get_signal_cons

TidalWave:Clean(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
    Camera = workspace.CurrentCamera or workspace:FindFirstAncestorOfClass('Camera')
end))

local function Notify(Properties)
    TidalWave:Notify(Properties)
end

local function Run(f)
    f()
end

local function SafeRef(Obj, Path)
    return ObjectFunctions:SafeRef(Obj, Path)
end

local skywars, remotes = {}, {}
local store = {
	blocks = {},
	hand = {},
	inventory = {},
	tools = {}
}

local function collection(tags, module, customadd, customremove)
	tags = typeof(tags) ~= 'table' and {tags} or tags
	local objs, connections = {}, {}

	for _, tag in tags do
		table.insert(connections, CollectionService:GetInstanceAddedSignal(tag):Connect(function(v)
			if customadd then
				customadd(objs, v, tag)
				return
			end
			table.insert(objs, v)
		end))
		table.insert(connections, CollectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
			if customremove then
				customremove(objs, v, tag)
				return
			end
			v = table.find(objs, v)
			if v then
				table.remove(objs, v)
			end
		end))

		for _, v in CollectionService:GetTagged(tag) do
			if customadd then
				customadd(objs, v, tag)
				continue
			end
			table.insert(objs, v)
		end
	end

	local cleanFunc = function()
		for _, v in connections do
			v:Disconnect()
		end
		table.clear(connections)
		table.clear(objs)
	end
	if module then
		module:Clean(cleanFunc)
	end
	return objs, cleanFunc
end

local function getItem(check)
	for _, item in store.inventory do
		if item.Type == check then
			return item
		end
	end
end

local function getSword()
	local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
	for slot, item in store.inventory do
		item = skywars.ItemMeta[item.Type]
		local swordDamage = item.Melee and item.Melee.Damage or 0
		if swordDamage > bestSwordDamage then
			bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage
		end
	end
	return bestSword, bestSwordSlot
end

local function getPickaxe()
	local bestPick, bestPickSlot, bestPickDamage = nil, nil, math.huge
	for slot, item in store.inventory do
		item = skywars.ItemMeta[item.Type]
		local pickDamage = item.Pickaxe and item.Pickaxe.TimeMultiplier or math.huge
		if pickDamage < bestPickDamage then
			bestPick, bestPickSlot, bestPickDamage = item, slot, pickDamage
		end
	end
	return bestPick, bestPickSlot
end

local function parsePositions(v, func)
	if v:IsA('Part') and v.Size // 1 == v.Size then
		local start = (v.Position - (v.Size / 2)) + vector.create(1.5, 1.5, 1.5)
		for x = 0, v.Size.X - 1, 3 do
			for y = 0, v.Size.Y - 1, 3 do
				for z = 0, v.Size.Z - 1, 3 do
					func(start + vector.create(x, y, z))
				end
			end
		end
	end
end

Run(function() -- EntityLib
    function EntityLib:GetUpdateConnections(Character)
        return {
			Character.Player:GetAttributeChangedSignal('Health'),
		}
    end

    function EntityLib:IsTeammate(Character)
        if TidalWave:IsFriend(Character.Player) then return true end
        return Plr:GetAttribute('TeamId') == Character.Player:GetAttribute('TeamId')
    end

    function EntityLib:GetTeamColor(Character)
        local IsFriend, FriendColor = TidalWave:IsFriend(Character.Player)
        if IsFriend and FriendColor then
            return FriendColor
        end
        
        return skywars.TeamController:getTeamColour(Character.Player:GetAttribute('TeamId'))
    end

    EntityLib:Restart()
end)

Run(function() -- Base
    local Flamework = require(ReplicatedStorage.rbxts_include.node_modules['@flamework'].core.out).Flamework
    local ControllerTable = {}

    if not debug.getupvalue(Flamework.ignite, 1) then
        repeat task.wait() until debug.getupvalue(Flamework.ignite, 1)
    end

    local function searchFunction(name, i2, v2)
        for _, v3 in debug.getconstants(v2) do
            if tostring(v3):find('-') == 9 then
                remotes[(rawget(remotes, i2) and name..':' or '')..i2] = v3
            end
        end
    end

    for i, v in debug.getupvalue(Flamework.ignite, 2).idToObj do
        local name = tostring(v)
        ControllerTable[name] = Flamework.resolveDependency(i)
        for i2, v2 in v do
            if type(v2) == 'function' then
                searchFunction(name, i2, v2)

                for _, v3 in debug.getprotos(v2) do
                    searchFunction(name, i2, v3)
                end
            end
        end
    end

    local roactCheck = ReplicatedStorage.rbxts_include.node_modules['@rbxts']:FindFirstChild('roact')
    skywars = setmetatable({
        CameraUtil = require(Plr.PlayerScripts.TS.util['camera-util']).CameraUtil,
        FireOrigin = debug.getupvalue(ControllerTable.ProjectileController.chargeBow, 11).ORIGIN_OFFSET,
        Gravity = debug.getupvalue(ControllerTable.ProjectileController.chargeBow, 13).WORLD_ACCELERATION.Y,
        ItemMeta = debug.getupvalue(ControllerTable.HotbarController.getSword, 1),
        Remotes = debug.getupvalue(ControllerTable.MeleeController.strikeDesktop, 6),
        Roact = require(roactCheck and roactCheck.src or ReplicatedStorage.rbxts_include.node_modules['@rbxts'].ReactLua.node_modules['@jsdotlua']['roact-compat']),
        Store = require(Plr.PlayerScripts.TS.ui.rodux['global-store']).GlobalStore,
        Shop = require(ReplicatedStorage.TS.game.shop['game-shop']).Shops
    }, {
        __index = function(self, ind)
            rawset(self, ind, ControllerTable[ind])
            return rawget(self, ind)
        end
    })

    local function updateStore(newStore, oldStore)
        if newStore.ActiveSlot ~= oldStore.ActiveSlot then
            store.hand = newStore.Inventory.Contents[newStore.ActiveSlot]
            store.hand = store.hand and skywars.ItemMeta[store.hand.Type] or {}
        end

        if newStore.Inventory ~= oldStore.Inventory then
            store.inventory = newStore.Inventory.Contents
            store.hand = newStore.Inventory.Contents[newStore.ActiveSlot]
            store.hand = store.hand and skywars.ItemMeta[store.hand.Type] or {}
            store.tools.sword = getSword()
            store.tools.pickaxe = getPickaxe()
        end
    end

    local storeChanged = skywars.Store.changed:connect(updateStore)
    updateStore(skywars.Store:getState(), {})

    TidalWave:Clean(workspace.BlockContainer.DescendantAdded:Connect(function(v)
        parsePositions(v, function(pos)
            store.blocks[pos] = v
        end)
    end))
    TidalWave:Clean(workspace.BlockContainer.DescendantRemoving:Connect(function(v)
        parsePositions(v, function(pos)
            store.blocks[pos] = nil
        end)
    end))
    for _, v in workspace.BlockContainer:GetDescendants() do
        parsePositions(v, function(pos)
            store.blocks[pos] = v
        end)
    end

    TidalWave:Clean(function()
        table.clear(ControllerTable)
        table.clear(skywars)
        table.clear(store.blocks)
        table.clear(store)
        storeChanged:disconnect()
        storeChanged = nil
    end)
end)

Run(function() -- Combat
    Run(function() -- KillAura
        local KillAura, UsePlayers, WallCheck, AttackRange, AngleCheck, MaxTargets, RequireMouseDown, RequireInHand, SwingAnimation
        local BoxAttackColor, ParticleTexture, ParticleColor1,  ParticleColor2, ParticleSize, AnimationEnabled, Animation, AnimationSpeed, UpdateRate
        
        local Particles = {}
        local Boxes = {}

        local OldC0, Tween, StopTween, Attacking

        local function MouseCheck()
            if RequireMouseDown.Enabled and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                return false
            end

            if RequireInHand.Enabled then
                return store.hand
            end

            return store.tools.sword
        end

        KillAura = Combat:CreateModule({
            Name = 'KillAura',
            Info = 'Automatically attacks players around you',
            Function = function(Enabled)
                if Enabled then
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

                    while KillAura.Enabled do
                        local Attacked = {}
                        local Tool = MouseCheck()

                        if Tool and Tool.Melee then
                            local Characters = EntityLib:GetClosestEntities({
                                Range = AttackRange.Value,
                                WallCheck = WallCheck.Enabled,
                                Part = 'Root',
                                Players = UsePlayers.Enabled,
                                Limit = MaxTargets.Value
                            })

                            local Switched = false

                            if #Characters > 0 then
                                local LookVector = EntityLib.Root.CFrame.LookVector * vector.hort

                                local MaxAngle = math.rad(AngleCheck.Value) / 2

                                for _, Character in Characters do
                                    local Delta = (Character.Root.Position - EntityLib.Root.Position)
                                    local Angle = math.acos(LookVector:Dot((Delta * vector.hort).Unit))
                                    if Angle > MaxAngle then continue end

                                    table.insert(Attacked, Character)

                                    Attacking = true

                                    if SwingAnimation.Enabled then
                                        skywars.MeleeController:playAnimation(EntityLib.Character, Tool)
                                    end

                                    if not Switched then
                                        Switched = true
                                        skywars.Remotes[remotes.updateActiveItem]:fire(Tool.Name)
                                    end

                                    skywars.Remotes[remotes.strikeDesktop]:fire(Character.Player)
                                end
                            else
                                Attacking = nil
                            end

                            if Switched then
                                skywars.Remotes[remotes.updateActiveItem](store.hand.Name)
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
                    for _, Box in Boxes do
                        Box.Adornee = nil
                    end
                    for _, Particle in Particles do
                        Particle.Parent = nil
                    end
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
                    Attacking = nil
                    OldC0 = nil
                end
            end,
        })

        UsePlayers = KillAura:CreateToggle({
            Name = 'Players',
            Default = true
        })

        WallCheck = KillAura:CreateToggle({
            Name = 'Wall Check'
        })

        AttackRange = KillAura:CreateSlider({
            Name = 'Attack Range',
            Default = 18,
            Min = 1,
            Max = 18
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

        RequireInHand = KillAura:CreateToggle({
            Name = 'Require In Hand',
            Tooltip = 'Only attacks when the sword is held'
        })

        SwingAnimation = KillAura:CreateToggle({
            Name = 'Swing Animation',
            Info = 'Plays the sword swing animation',
            Default = true
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
                        local part = Instance.new('Part')
                        part.Size = Vector3.new(2, 4, 2)
                        part.Anchored = true
                        part.CanCollide = false
                        part.Transparency = 1
                        part.CanQuery = false
                        part.Parent = KillAura.Enabled and Camera or nil

                        local particles = Instance.new('ParticleEmitter')
                        particles.Brightness = 1.5
                        particles.Size = NumberSequence.new(ParticleSize.Value)
                        particles.Shape = Enum.ParticleEmitterShape.Sphere
                        particles.Texture = ParticleTexture.Value
                        particles.Transparency = NumberSequence.new(0)
                        particles.Lifetime = NumberRange.new(0.4)
                        particles.Speed = NumberRange.new(16)
                        particles.Rate = 128
                        particles.Drag = 16
                        particles.ShapePartial = 1
                        particles.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, ParticleColor1.Color),
                            ColorSequenceKeypoint.new(1, ParticleColor2.Color)
                        })
                        particles.Parent = part
                        Particles[i] = part
                    end
                else
                    for _, v in Particles do
                        v:Destroy()
                    end
                    table.clear(Particles)
                end
            end
        })

        ParticleTexture = TargetParticles:CreateTextBox({
            Name = 'Texture',
            Default = 'rbxassetid://14736249347',
            Function = function()
                for _, Particle in Particles do
                    Particle.ParticleEmitter.Texture = ParticleTexture.Value
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
            Function = function(val)
                for _, Particle in Particles do
                    Particle.ParticleEmitter.Size = NumberSequence.new(val)
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
            Decimal = 10
        })

        UpdateRate = AnimationEnabled:CreateSlider({
            Name = 'Update Rate',
            Default = 60,
            Min = 10,
            Max = 240
        })
    end)

    Run(function() -- SilentAimbot
        local TargetPart
        local Fov
        local old, oldMobile
        local rayCheck = RaycastParams.new()
        rayCheck.FilterType = Enum.RaycastFilterType.Exclude
        
        local function aimFunction(...)
            if store.hand and store.hand.Ranged then
                local WithinMouse = EntityLib:GetClosestEntityWithinMouse({
                    Range = Fov.Value,
                    Part = 'Root',
                    Players = true
                })
        
                if WithinMouse then
                    rayCheck.FilterDescendantsInstances = {WithinMouse.Character, Camera}
                    rayCheck.CollisionGroup = WithinMouse[TargetPart.Value].CollisionGroup
                    local offsetpos = EntityLib.Root.CFrame * skywars.FireOrigin
                    local calc = Prediction.SolveTrajectory(offsetpos.Position, 200, math.abs(skywars.Gravity), WithinMouse[TargetPart.Value].Position, WithinMouse[TargetPart.Value].Velocity, workspace.Gravity, WithinMouse.HipHeight, nil, rayCheck)
        
                    if calc then
                        return CFrame.lookVector(offsetpos.Position, calc).LookVector
                    end
                end
            end
        
            return old(...)
        end
        
        local ProjectileAimbot = Combat:CreateModule({
            Name = 'SilentAimbot',
            Function = function(callback)
                if callback then
                    old = hookfunction(skywars.CameraUtil.getCursorDirection, function(...)
                        return aimFunction(...)
                    end)
        
                    oldMobile = hookfunction(skywars.CameraUtil.getDirection, function(...)
                        return aimFunction(...)
                    end)
                else
                    hookfunction(skywars.CameraUtil.getCursorDirection, old)
                    hookfunction(skywars.CameraUtil.getDirection, oldMobile)
                    old = nil
                    oldMobile = nil
                end
            end,
            Info = 'Silently adjusts your aim towards the enemy'
        })
        TargetPart = ProjectileAimbot:CreateDropdown({
            Name = 'Part',
            List = {'Root', 'Head'}
        })
        Fov = ProjectileAimbot:CreateSlider({
            Name = 'FOV',
            Min = 1,
            Max = 1000,
            Default = 1000
        })
    end)

    Run(function() -- ProjectileAura
        local ProjectileAura
        local WallCheck
        local Range
        local List
        local rayCheck = RaycastParams.new()
        rayCheck.FilterType = Enum.RaycastFilterType.Exclude
        local FireDelays = {}
        
        local function getProjectiles()
            local items = {}
            for slot, item in store.inventory do
                item = skywars.ItemMeta[item.Type]
                if item.Ranged and table.find(List.Enabled, item.Ranged.ProjectileType) and getItem(item.Ranged.ProjectileType) then
                    table.insert(items, item)
                end
            end
            return items
        end
        
        ProjectileAura = Combat:CreateModule({
            Name = 'ProjectileAura',
            Function = function(callback)
                if callback then
                    repeat
                        local Character = EntityLib:GetClosestEntity({
                            Part = 'Root',
                            Range = Range.Value,
                            Players = true,
                            WallCheck = WallCheck.Enabled
                        })
        
                        if Character then
                            local offsetpos = EntityLib.Root.CFrame * skywars.FireOrigin
                            for _, item in getProjectiles() do
                                if (FireDelays[item] or 0) < tick() then
                                    rayCheck.FilterDescendantsInstances = {Character.Character, Camera}
                                    rayCheck.CollisionGroup = Character.Root.CollisionGroup
                                    local calc = Prediction.SolveTrajectory(offsetpos.Position, 200, math.abs(skywars.Gravity), Character.Root.Position, Character.Root.AssemblyLinearVelocity, workspace.Gravity, Character.HipHeight, nil, rayCheck)
        
                                    if calc then
                                        FireDelays[item] = tick() + 0.5
                                        skywars.Remotes[remotes.updateActiveItem]:fire(item.Name)
                                        skywars.Remotes[remotes.chargeBow]:fire(CFrame.new(offsetpos.Position, calc).LookVector, 1)
                                        skywars.Remotes[remotes.updateActiveItem](store.hand.Name)
                                        break
                                    end
                                end
                            end
                        end
        
                        task.wait(0.1)
                    until not ProjectileAura.Enabled
                end
            end,
            Info = 'Shoots people around you'
        })
        WallCheck = ProjectileAura:CreateToggle({
            Name = 'WallCheck',
            Default = true
        })
        List = ProjectileAura:CreateTextList({
            Name = 'Projectiles',
            List = {'Arrow', 'Snowball', 'Capybara'}
        })
        Range = ProjectileAura:CreateSlider({
            Name = 'Range',
            Min = 1,
            Max = 50,
            Default = 50
        })
    end)

    Run(function() -- AutoWin
        local AutoWin, LootAmount

        local function GameInProgress()
            if workspace:FindFirstChild('Lobby') then return false end
            local SpawnLocations = SafeRef(workspace, {'BlockContainer', 'Map', 'SpawnLocations'})
            if SpawnLocations then
                for _, v in SpawnLocations:GetChildren() do
                    if #v:GetChildren() > 0 then
                        return false
                    end
                end
                return false
            end
            return true
        end

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true
        Params.FilterType = Enum.RaycastFilterType.Include

        local UpOffset = vector.yAxis * 1000
        local CFrameOffset = CFrame.new(0, 3, 6)
        
        AutoWin = Combat:CreateModule({
            Name = "AutoWin",
            Info = "It Win For You (:",
            Enabled = function()
                repeat
                    task.wait()
                until GameInProgress() or not AutoWin.Enabled
                if not AutoWin.Enabled then return end
                local Found = 0

                local Chests

                local TimeOut = os.clock() + 15

                repeat
                    Chests = SafeRef(workspace, {'BlockContainer', 'Map', 'Chests'})
                    task.wait()
                until Chests or not AutoWin.Enabled or os.clock() >= TimeOut

                if not Modules.AutoLoot.Enabled then
                    Modules.AutoLoot:Toggle(true)
                end
                if not Modules.KillAura.Enabled then
                    Modules.KillAura:Toggle(true)
                end
                if not Modules.SilentAimbot.Enabled then
                    Modules.SilentAimbot:Toggle(true)
                end
                if not Modules.ProjectileAura.Enabled then
                    Modules.ProjectileAura:Toggle(true)
                end
                for _, Chest in Chests:GetChildren() do
                    if Chest:IsA("Model") and Chest.PrimaryPart and Chest.Name == "ChestTierFour" then
                        EntityLib.Root.CFrame = Chest.PrimaryPart.CFrame
                        Found += 1
                        task.wait(0.5)
                        if Found >= LootAmount.Value then break end
                    end
                end
                if not AutoWin.Enabled then return end
                local AllPlayers = Players:GetPlayers()
                table.remove(AllPlayers, table.find(AllPlayers, Plr))
                local Target = 1
                local Offset = vector.zero

                AutoWin:Clean(Players.PlayerAdded:Connect(function(Player)
                    AllPlayers[#AllPlayers + 1] = Player
                end))

                AutoWin:Clean(Players.PlayerRemoving:Connect(function(Player)
                    local Index = table.find(AllPlayers, Player)
                    if Index then
                        table.remove(AllPlayers, Index)
                    end
                end))

                AutoWin:Clean(RunService.PreSimulation:Connect(function()
                    if #AllPlayers == 0 then return end
                    if AllPlayers[Target] and not AllPlayers[Target]:GetAttribute("Alive") or AllPlayers[Target] and AllPlayers[Target]:GetAttribute("TeamId") == Plr:GetAttribute("TeamId") then Target += 1 end
                    if Target > #AllPlayers then Target = 1 end

                    local Char = EntityLib:FindEntity(AllPlayers[Target])
                    if not (Char and EntityLib.Alive) then return end
                    
                    Params.FilterDescendantsInstances = {workspace.BlockContainer}

                    local Raycast = workspace:Raycast(Char.Root.Position, Char.Root.Position - UpOffset, Params)
                    if not Raycast and Char.Root.AssemblyLinearVelocity.Y <= -100 then Target += 1 return end

                    if Plr:GetAttribute("Health") < 25 then
                        Offset = vector.yAxis * 1000
                    else
                        Offset = vector.zero
                    end
                    
                    EntityLib.Root.AssemblyLinearVelocity = vector.zero
                    EntityLib.Root.CFrame = Char.Root.CFrame:ToWorldSpace(CFrameOffset) + Offset
                    RunService.PostSimulation:Wait()

                    Raycast = workspace:Raycast(Char.Root.Position, Char.Root.Position - UpOffset, Params)
                    if not Raycast and Char.Root.AssemblyLinearVelocity.Y <= -100 then Target += 1 return end

                    if Plr:GetAttribute("Health") < 25 then
                        Offset = UpOffset
                    else
                        Offset = vector.zero
                    end

                    EntityLib.Root.AssemblyLinearVelocity = vector.zero
                    EntityLib.Root.CFrame = Char.Root.CFrame:ToWorldSpace(CFrameOffset) + Offset
                end))
            end,
        })

        LootAmount = AutoWin:CreateSlider({
            Name = "Loot Amount",
            Min = 1,
            Default = 5,
            Max = 25
        })
    end)
end)

Run(function() -- Player
    Run(function() -- NoFall
        local NoFall

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true
        Params.FilterType = Enum.RaycastFilterType.Include
        Params.FilterDescendantsInstances = {workspace.BlockContainer}

        local Down = vector.create(0, -13, 0)
        local GroundPosition = vector.zero

        local Air = Enum.Material.Air
        local Ragdoll = Enum.HumanoidStateType.Ragdoll
        local Running = Enum.HumanoidStateType.Running

        NoFall = PlayerCategory:CreateModule({
            Name = 'NoFall',
            Info = 'Prevents you from taking fall damage.',
            Enabled = function()
                while NoFall.Enabled and RunService.PreSimulation:Wait() do
                    if EntityLib.Alive then
                        if EntityLib.Humanoid.FloorMaterial ~= Air then
                            GroundPosition = EntityLib.Root.Position
                        end
                        if (GroundPosition.Y - EntityLib.Root.Position.Y) > 10 then
                            local Raycast = workspace:Raycast(EntityLib.Root.Position, Down, Params)
                            if not Raycast then
                                EntityLib.Humanoid:ChangeState(Ragdoll)
                                task.wait(0.1)
                                EntityLib.Humanoid:ChangeState(Running)
                                local TimeOut = os.clock() + 0.05
                                repeat
                                    RunService.PostSimulation:Wait()
                                until EntityLib.Humanoid.FloorMaterial ~= Air or os.clock() >= TimeOut
                            end
                        end
                    end
                end
            end
        })
    end)

    Run(function() -- NoSlowdown
        local old, oldcheck
        
        PlayerCategory:CreateModule({
            Name = 'NoSlowdown',
            Info = 'Prevents slowing down when using items.',
            Function = function(callback)
                if callback then
                    old = skywars.HumanoidController.addSpeedModifier
                    oldcheck = skywars.SprintingController.setCanSprint
        
                    skywars.HumanoidController.addSpeedModifier = function(self, index, speed)
                        speed = math.max(speed, 1)
                        return old(self, index, speed)
                    end
        
                    skywars.SprintingController.setCanSprint = function(self, canSprint)
                        return oldcheck(self, true)
                    end
        
                    for i, v in skywars.HumanoidController.speedModifiers do
                        if v < 1 then
                            skywars.HumanoidController:removeSpeedModifier(i)
                        end
                    end
        
                    skywars.SprintingController:setCanSprint(true)
                    skywars.SprintingController:enableSprinting()
                else
                    skywars.HumanoidController.addSpeedModifier = old
                    skywars.SprintingController.setCanSprint = oldcheck
                    old = nil
                    oldcheck = nil
                end
            end
        })
    end)
end)

Run(function() -- Movement
    Run(function() -- Sprint
        local Sprint
        local old
        
        Sprint = Movement:CreateModule({
            Name = 'Sprint',
            Info = 'Sets your sprinting to true.',
            Function = function(callback)
                if callback then
                    old = skywars.SprintingController.disableSprinting
                    skywars.SprintingController.disableSprinting = function(tab, ...)
                        local data = old(tab, ...)
        
                        if not tab.canSprint then
                            task.spawn(function()
                                repeat task.wait(0.1) until tab.canSprint or not Sprint.Enabled
        
                                if Sprint.Enabled then
                                    skywars.SprintingController:enableSprinting(tab)
                                end
                            end)
                        else
                            skywars.SprintingController:enableSprinting(tab)
                        end
        
                        return data
                    end
        
                    Sprint:Clean(EntityLib.Events.LocalAdded:Connect(function()
                        skywars.SprintingController:disableSprinting()
                    end))
        
                    skywars.SprintingController:disableSprinting()
                else
                    skywars.SprintingController.disableSprinting = old
                    skywars.SprintingController:disableSprinting()
                end
            end,
        })
    end)

    Run(function() -- Velocity
        local Velocity
        local Horizontal
        local Vertical
        local Chance
        local connection
        local rand, old = Random.new()
        
        local function velocityFunction(...)
            if rand:NextNumber(0, 100) > Chance.Value then return old(...) end
        
            local args = table.pack(...)
            local check = EntityLib:GetClosestEntity({
                Range = 50,
                Part = 'Root',
                Players = true
            })
        
            if check then
                local hort, vert = (Horizontal.Value / 100), (Vertical.Value / 100)
                if hort == 0 and vert == 0 then return end
                args[1] = vector.create(args[1].X * hort, args[1].Y * vert, args[1].Z * hort)
            end
        
            return old(unpack(args, 1, args.n))
        end
        
        Velocity = Movement:CreateModule({
            Name = 'Velocity',
            Info = 'Reduces knockback taken',
            Function = function(callback)
                if callback then
                    connection = getconnections(debug.getupvalue(debug.getupvalue(skywars.Remotes[remotes['PlayerVelocityController:onStart']].connect, 1).fireClient, 1).OnClientEvent)[1]
                    if not connection then return end
        
                    old = hookfunction(connection.Function, function(...)
                        return velocityFunction(...)
                    end)
                else
                    if old then
                        hookfunction(connection.Function, old)
                    end
                    connection = nil
                end
            end,
        })
        Horizontal = Velocity:CreateSlider({
            Name = 'Horizontal',
            Min = 0,
            Max = 100,
            Default = 0,
            Suffix = '%'
        })
        Vertical = Velocity:CreateSlider({
            Name = 'Vertical',
            Min = 0,
            Max = 100,
            Default = 0,
            Suffix = '%'
        })
        Chance = Velocity:CreateSlider({
            Name = 'Chance',
            Min = 0,
            Max = 100,
            Default = 100,
            Suffix = '%'
        })
    end)
end)

Run(function() -- Visuals
    Run(function() -- Viewmodel
        local Viewmodel
        local OldTool
        
        local function LocalAdded()
            local function ToolAdded(Tool)
                OldTool = Tool
                ViewmodelTool = Instance.fromExisting(OldTool.Handle)
                ViewmodelTool.CanCollide = false
                ViewmodelTool.Massless = true
                ViewmodelTool.Anchored = true
                ViewmodelTool.Parent = Camera
                ViewmodelTool.LocalTransparencyModifier = 0
                OldTool.Handle.LocalTransparencyModifier = 1
            end

            Viewmodel:Clean(EntityLib.Character.ChildAdded:Connect(function(Obj)
                if Obj:IsA('Tool') then 
                    ToolAdded(Obj)
                end
            end))
            
            Viewmodel:Clean(EntityLib.Character.ChildRemoved:Connect(function(Obj)
                if Obj == OldTool then 
                    ViewmodelTool:Destroy()
                    ViewmodelTool = nil
                    OldTool = nil
                end
            end))
        end

        local function LocalRemoved()
            Viewmodel:CleanUp()
            if ViewmodelTool then
                ViewmodelTool:Destroy()
                ViewmodelTool = nil
            end
        end
        
        Viewmodel = Visuals:CreateModule({
            Name = 'Viewmodel',
            Info = 'Replaces the default viewmodel',
            Function = function(Enabled)
                if Enabled then
                    ViewmodelMotor = Instance.new('Motor6D')

                    Viewmodel:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    Viewmodel:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if EntityLib.Alive then 
                        LocalAdded()
                    end

                    Viewmodel:Clean(RunService.PreRender:Connect(function()
                        if ViewmodelTool then 
                            local dcf = ((CFrame.new(2.06, -2.44, -2.24) * CFrame.new(0.6, -0.2, -0.6)) * CFrame.Angles(math.rad(99), math.rad(2), math.rad(-4))) * ViewmodelMotor.C0
                            local offsetcf = (CFrame.new(0, -0.15, -1.56) * CFrame.Angles(math.rad(-90), math.rad(-90), 0))
                            ViewmodelTool.CFrame = ((Camera.CFrame * dcf) * offsetcf)
                            local ThirdPerson = vector.magnitude(Camera.CFrame.Position - Camera.Focus.Position) > 0.6
                            ViewmodelTool.LocalTransparencyModifier = ThirdPerson and 1 or 0
                            OldTool.Handle.LocalTransparencyModifier = ThirdPerson and 0 or 1
                        end
                    end))
                else
                    if OldTool then
                        OldTool.Handle.LocalTransparencyModifier = 0
                        OldTool = nil
                    end
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
    Run(function() -- AutoLoot
        local ChestSteal
        local Range
        local Open
        local Delay = {}
        
        ChestSteal = World:CreateModule({
            Name = 'AutoLoot',
            Function = function(callback)
                if callback then
                    local chests = collection('block:chest', ChestSteal)
                    ChestSteal:Clean(skywars.Remotes[remotes['ChestController:onStart']]:connect(function(self, items)
                        if Delay[self] then return end
        
                        for _, item in items do
                            skywars.Remotes[remotes.updateChest]:fire(self, item.Type, -item.Quantity)
                        end
        
                        skywars.Remotes[remotes.closeChest]:fire(self)
                        Delay[self] = true
                    end))
        
                    repeat
                        if EntityLib.Alive and not Open.Enabled then
                            local localPosition = EntityLib.Root.Position
                            for i, v in chests do
                                if v.PrimaryPart and (localPosition - v.PrimaryPart.Position).Magnitude <= Range.Value and not Delay[v] then
                                    skywars.Remotes[remotes.openChest]:fire(v)
                                end
                            end
                        end
        
                        task.wait(0.1)
                    until not ChestSteal.Enabled
                end
            end,
            Info = 'Grabs items from near chests.'
        })
        Range = ChestSteal:CreateSlider({
            Name = 'Range',
            Min = 0,
            Max = 10,
            Default = 10
        })
        Open = ChestSteal:CreateToggle({Name = 'GUI Check'})
    end)

    Run(function() -- Scaffold
        local Scaffold
        local Expand
        local Tower
        local Downwards
        local Diagonal
        local LimitItem
        local adjacent, lastpos = {}, vector.zero
        
        for x = -3, 3, 3 do
            for y = -3, 3, 3 do
                for z = -3, 3, 3 do
                    local vec = vector.create(x, y, z)
                    if vec.Y ~= 0 and (vec.X ~= 0 or vec.Z ~= 0) then
                        continue
                    end
        
                    if vec ~= vector.zero then
                        table.insert(adjacent, vec)
                    end
                end
            end
        end
        
        local function getBlocksInPoints(s, e)
            local list = {}
            for x = s.X, e.X, 3 do
                for y = s.Y, e.Y, 3 do
                    for z = s.Z, e.Z, 3 do
                        local vec = vector.create(x, y, z)
                        if store.blocks[vec] then
                            table.insert(list, vec)
                        end
                    end
                end
            end
            return list
        end
        
        local function roundPos(vec)
            return vector.create(math.round(vec.X / 3) * 3, math.round(vec.Y / 3) * 3, math.round(vec.Z / 3) * 3)
        end
        
        local function nearCorner(poscheck, pos)
            local startpos = poscheck - vector.create(3, 3, 3)
            local endpos = poscheck + vector.create(3, 3, 3)
            local check = poscheck + (pos - poscheck).Unit * 100
            if math.abs(check.Y - startpos.Y) > 3 then
                return vector.create(poscheck.X, math.clamp(check.Y, startpos.Y, endpos.Y), poscheck.Z)
            end
        
            return vector.create(math.clamp(check.X, startpos.X, endpos.X), math.clamp(check.Y, startpos.Y, endpos.Y), math.clamp(check.Z, startpos.Z, endpos.Z))
        end
        
        local function blockProximity(pos)
            local mag, returned = 60
            local tab = getBlocksInPoints(pos - vector.create(21, 21, 21), pos + vector.create(21, 21, 21))
        
            for _, v in tab do
                local blockpos = nearCorner(v, pos)
                local newmag = (pos - blockpos).Magnitude
                if newmag < mag then
                    mag, returned = newmag, blockpos
                end
            end
        
            table.clear(tab)
            return returned
        end
        
        local function checkAdjacent(pos)
            for _, v in adjacent do
                if store.blocks[pos + v] then return true end
            end
            return false
        end
        
        local function getBlock()
            for slot, item in store.inventory do
                item = skywars.ItemMeta[item.Type]
                if item.Rewrite then return item, slot end
            end
        end
        
        Scaffold = World:CreateModule({
            Name = 'Scaffold',
            Function = function(callback)
                if callback then
                    repeat
                        if EntityLib.Alive then
                            local wool = (not LimitItem.Enabled) and getBlock() or store.hand.Rewrite and store.hand
                            if wool then
                                local root = EntityLib.Root
                                if Tower.Enabled and UIS:IsKeyDown(Enum.KeyCode.Space) and (not UIS:GetFocusedTextBox()) then
                                    root.Velocity = vector.create(root.Velocity.X, 38, root.Velocity.Z)
                                end
        
                                for i = Expand.Value, 1, -1 do
                                    local currentpos = roundPos(root.Position - vector.create(0, EntityLib.HipHeight + (Downwards.Enabled and UIS:IsKeyDown(Enum.KeyCode.LeftShift) and 4.5 or 1.5), 0) + EntityLib.Humanoid.MoveDirection * (i * 3))
                                    if Diagonal.Enabled then
                                        if math.abs(math.round(math.deg(math.atan2(-EntityLib.Humanoid.MoveDirection.X, -EntityLib.Humanoid.MoveDirection.Z)) / 45) * 45) % 90 == 45 then
                                            local dt = (lastpos - currentpos)
                                            if ((dt.X == 0 and dt.Z ~= 0) or (dt.X ~= 0 and dt.Z == 0)) and ((lastpos - root.Position) * vector.create(1, 0, 1)).Magnitude < 2.5 then
                                                currentpos = lastpos
                                            end
                                        end
                                    end
        
                                    if not store.blocks[currentpos] then
                                        local blockpos = checkAdjacent(currentpos) and currentpos or blockProximity(currentpos)
                                        if blockpos then
                                            local block = skywars.ItemMeta[wool.Rewrite.Type:gsub('{TeamId}', skywars.TeamController:getPlayerTeamId(Plr) or 'White')]
                                            skywars.BlockController:placeBlock(blockpos, wool.Name, block, vector.zero)
                                        end
                                    end
                                    lastpos = currentpos
                                end
                            end
                        end
        
                        task.wait(0.03)
                    until not Scaffold.Enabled
                end
            end,
            Info = 'Helps you make bridges/scaffold walk.'
        })
        Expand = Scaffold:CreateSlider({
            Name = 'Expand',
            Default = 1,
            Min = 1,
            Max = 6
        })
        Tower = Scaffold:CreateToggle({
            Name = 'Tower',
            Default = true
        })
        Downwards = Scaffold:CreateToggle({
            Name = 'Downwards',
            Default = true
        })
        Diagonal = Scaffold:CreateToggle({
            Name = 'Diagonal',
            Default = true
        })
        LimitItem = Scaffold:CreateToggle({
            Name = 'Limit to items'
        })
    end)

    Run(function() -- AntiVoid
        local AntiFall
        local Mode
        local Material
        local Color
        local part
        
        local function getLowGround()
            local mag = math.huge
            for pos in store.blocks do
                if pos.Y < mag and not store.blocks[pos + vector.create(0, 3, 0)] then
                    mag = pos.Y
                end
            end
            return mag
        end
        
        AntiFall = PlayerCategory:CreateModule({
            Name = 'AntiFall',
            Info = 'Help\'s you with your Parkinson\'s\nPrevents you from falling into the void.',
            Function = function(callback)
                if callback then
                    local pos, debounce = getLowGround(), tick()
                    if pos ~= math.huge then
                        local middle = next(store.blocks)
                        part = Instance.new('Part')
                        part.Size = vector.create(10000, 1, 10000)
                        part.Transparency = Color.Transparency
                        part.Material = Enum.Material[Material.Value]
                        part.Color = Color.Color
                        part.Position = vector.create(middle.X, pos - 2, middle.Z)
                        part.CanCollide = Mode.Value == 'Collide'
                        part.Anchored = true
                        part.CanQuery = false
                        part.Parent = workspace
                        AntiFall:Clean(part.Touched:Connect(function(touchedpart)
                            if touchedpart.Parent == Plr.Character and EntityLib.Alive and debounce < tick() then
                                local root = EntityLib.Root
                                debounce = tick() + 0.1
                                if Mode.Value == 'Velocity' then
                                    root.Velocity = vector.create(root.Velocity.X, 100, root.Velocity.Z)
                                end
                            end
                        end))
                    end
                else
                    if part then
                        part:Destroy()
                        part = nil
                    end
                end
            end,
        })
        Mode = AntiFall:CreateDropdown({
            Name = 'Move Mode',
            List = {'Velocity', 'Collide'},
            Function = function(val)
                if part then
                    part.CanCollide = val == 'Collide'
                end
            end,
            Info = 'Velocity - Launches you upward after touching\nCollide - Allows you to walk on the part'
        })
        local materials = {'ForceField'}
        for _, v in Enum.Material:GetEnumItems() do
            if v.Name ~= 'ForceField' then
                table.insert(materials, v.Name)
            end
        end
        Material = AntiFall:CreateDropdown({
            Name = 'Material',
            List = materials,
            Function = function(val)
                if part then
                    part.Material = Enum.Material[val]
                end
            end
        })
        Color = AntiFall:CreateColorPicker({
            Name = 'Color',
            Default = Color3.fromRGB(255, 255, 255),
            Transparency = 0.5,
            Function = function(Color, Transparency)
                if part then
                    part.Color = Color
                    part.Transparency = Transparency
                end
            end
        })
    end)

    Run(function() -- EggNuker
        local Breaker
        local Range
        local BreakerPart
        local BreakerUI
        local BreakerRef = skywars.Roact.createRef()
        
        local function clean()
            if not BreakerUI then return end
            if BreakerPart then
                BreakerPart:Destroy()
            end
        
            skywars.Roact.unmount(BreakerUI)
            BreakerUI = nil
            BreakerPart = nil
        end

        local White = Color3.new(1, 1, 1)
        
        local function customHealthbar(block, health, maxHealth, changeHealth)
            if not BreakerPart then
                local create = skywars.Roact.createElement
                local percent = math.clamp(health / maxHealth, 0, 1)
                local part = Instance.new('Part')
                part.Size = vector.one
                part.CFrame = block.PrimaryPart.CFrame
                part.Transparency = 1
                part.Anchored = true
                part.CanCollide = false
                part.Parent = workspace
                BreakerPart = part
        
                BreakerUI = skywars.Roact.mount(create('BillboardGui', {
                    Size = UDim2.fromOffset(249, 102),
                    StudsOffset = vector.create(0, 2.5, 0),
                    Adornee = part,
                    MaxDistance = 40,
                    AlwaysOnTop = true
                }, {
                    create('Frame', {
                        Size = UDim2.fromOffset(160, 50),
                        Position = UDim2.fromOffset(44, 32),
                        BackgroundColor3 = Color3.new(),
                        BackgroundTransparency = 0.5
                    }, {
                        create('UICorner', {CornerRadius = UDim.new(0, 5)}),
                        create('TextLabel', {
                            Size = UDim2.fromOffset(145, 14),
                            Position = UDim2.fromOffset(13, 12),
                            BackgroundTransparency = 1,
                            Text = block.Name,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextYAlignment = Enum.TextYAlignment.Top,
                            TextColor3 = Color3.new(),
                            TextScaled = true,
                            Font = Enum.Font.Arial
                        }),
                        create('TextLabel', {
                            Size = UDim2.fromOffset(145, 14),
                            Position = UDim2.fromOffset(12, 11),
                            BackgroundTransparency = 1,
                            Text = block.Name,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextYAlignment = Enum.TextYAlignment.Top,
                            TextColor3 = White,
                            TextScaled = true,
                            Font = Enum.Font.Arial
                        }),
                        create('Frame', {
                            Size = UDim2.fromOffset(138, 4),
                            Position = UDim2.fromOffset(12, 32),
                            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                        }, {
                            create('UICorner', {CornerRadius = UDim.new(1, 0)}),
                            create('Frame', {
                                [skywars.Roact.Ref] = BreakerRef,
                                Size = UDim2.fromScale(percent, 1),
                                BackgroundColor3 = Color3.fromHSV(math.clamp(percent / 2.5, 0, 1), 0.89, 0.75)
                            }, {create('UICorner', {CornerRadius = UDim.new(1, 0)})})
                        })
                    })
                }), part)
        
                task.delay(5, clean)
            end
        
            local progress = math.clamp((health - changeHealth) / maxHealth, 0, 1)
            if progress == 0 then
                clean()
                return
            end
        
            task.delay(0, function()
                local val = BreakerRef:getValue()
                if val then
                    TweenService:Create(val, TweenInfo.new(0.3), {Size = UDim2.fromScale(progress, 1), BackgroundColor3 = Color3.fromHSV(math.clamp(progress / 2.5, 0, 1), 0.89, 0.75)}):Play()
                end
            end)
        end
        
        Breaker = World:CreateModule({
            Name = 'EggNuker',
            Function = function(callback)
                if callback then
                    local eggs = collection('egg', Breaker)
                    local currentblock
                    local oldblockhealth = 0
        
                    repeat
                        if EntityLib.Alive and store.hand then
                            local localPosition = EntityLib.Root.CFrame.Position
                            for _, v in eggs do
                                if v.PrimaryPart and (localPosition - v.PrimaryPart.Position).Magnitude < Range.Value then
                                    local hp = v:GetAttribute('Health') or 0
                                    if v:GetAttribute('TeamId') == Plr:GetAttribute('TeamId') then continue end
                                    if currentblock ~= v then
                                        oldblockhealth = hp
                                        currentblock = v
                                    end
        
                                    if hp ~= oldblockhealth then
                                        customHealthbar(v, oldblockhealth, 100, oldblockhealth - hp)
                                        oldblockhealth = hp
                                    end
        
                                    if hp <= 0 then continue end
        
                                    if store.hand.Melee then
                                        skywars.Remotes[remotes['MeleeController:attemptStrikeDesktop']]:fire(v)
                                    elseif store.hand.Pickaxe then
                                        skywars.Remotes[remotes.hitBlock]:fire((v.PrimaryPart.Position + vector.create(0, 1.5, 0)) // 1)
                                    end
                                end
                            end
                        end
        
                        task.wait(1 / 60)
                    until not Breaker.Enabled
                end
            end,
            Info = 'Automatically destroys eggs around you.'
        })
        Range = Breaker:CreateSlider({
            Name = 'Break range',
            Min = 1,
            Max = 40,
            Default = 40
        })
    end)
end)

Run(function() -- Other
    Run(function() -- InvMove
        local InvMove, Old
        
        InvMove = Other:CreateModule({
            Name = 'InvMove',
            Info = 'Allows you to move while in your inventory and in shops.',
            Function = function(callback)
                if callback then
                    Old = skywars.FocusedController.enableFocus
                    skywars.FocusedController.enableFocus = function(self, screen, ...)
                        return Old(self, true, ...)
                    end
                else
                    skywars.FocusedController.enableFocus = Old
                    Old = nil
                end
            end
        })
    end)
end)