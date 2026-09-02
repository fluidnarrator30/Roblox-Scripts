local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local Players: Players = GetService('Players')
local ReplicatedStorage: ReplicatedStorage = GetService('ReplicatedStorage')
local RunService: RunService = GetService('RunService')
local UIS: UserInputService = GetService('UserInputService')

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local Modules = TidalWave.Modules
local EntityLib = TidalWave.Libraries.EntityLib
local Drawing = TidalWave.Libraries.Drawing
local ObjectFunctions = TidalWave.Libraries.ObjectFunctions

local Combat = Categories.Combat
local PlayerCategory = Categories.Player
local Movement = Categories.Movement
local Visuals = Categories.Visuals
local World = Categories.World
local Other = Categories.Other
local Animations = Categories.Animations
local Server = Categories.Server

local Plr: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')

local require = table.find({'Xeno', 'Solara'}, ({identifyexecutor()})[1]) == nil and require or nil

local function Notify(Properties)
    TidalWave:Notify(Properties)
end

local function Run(f)
    f()
end

local function GetFullName(Obj)
    return ObjectFunctions:GetFullName(Obj)
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

TidalWave:Clean(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
    Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')
end))

for _, v in {'SilentAim',  'KillAura', 'Reach', 'AutoClicker'} do
    TidalWave:RemoveModule(v)
end

Run(function() -- EntityLib
    function EntityLib:IsTeammate()
        return false
    end

    local function ChildAdded(Child)
        if Child:IsA('Model') then
            local Animate = Child:WaitForChild('Animate', 5)

            if Animate and Animate.ClassName == 'Script' then
                EntityLib:AddEntity(Child)
            end
        end
    end

    local function ChildRemoved(Child)
        if Child:IsA('Model') then
            local Ent = EntityLib:FindNPC(Child)
            if Ent then
                EntityLib:RemoveEntity(Ent.Character)
            end
        end
    end

    TidalWave:Clean(workspace.ChildAdded:Connect(ChildAdded))
    TidalWave:Clean(workspace.ChildRemoved:Connect(ChildRemoved))

    for _, v in workspace:GetChildren() do
        if v:IsA('Model') then
            task.spawn(ChildAdded, v)
        end
    end
end)

local WeaponClient
local ShootFunction
local ShootPacket
local OldSend
local WeaponManager
local Viewmodel

local function GrabWeaponManager()
    if WeaponManager then return true end

    if require then
        WeaponManager = require(ReplicatedStorage.Common.Managers.WeaponManager)

        return WeaponManager ~= nil
    end

    return false
end

local function GrabShootPacket()
    if ShootPacket then return true end

    if require and debug.getupvalue then
        WeaponClient = require(Plr.PlayerScripts.Start.Game.WeaponClient)

        ShootFunction = WeaponClient and debug.getupvalue(WeaponClient.__setValues, 1) or nil
        ShootPacket = ShootFunction and debug.getupvalue(ShootFunction, 14) or nil

        return ShootFunction ~= nil and WeaponClient ~= nil and ShootPacket ~= nil and WeaponManager ~= nil
    end

    return false
end

Run(function() -- Combat
    Run(function() -- SilentAim
        local SilentAim, WallCheck, Part, Fov
        local Circle, OutlineColor, FillColor, OutlineTransparency, FillTransparency, Thickness

        local CircleObject

        local function CreateCircle()
            CircleObject = Drawing.new('Circle')
            CircleObject.Radius = Fov.Value
            CircleObject.FillTransparency = FillTransparency.Value
            CircleObject.OutlineTransparency = OutlineTransparency.Value
            CircleObject.FillColor = FillColor.Color
            CircleObject.OutlineColor = OutlineColor.Color
            CircleObject.Thickness = Thickness.Value
            CircleObject.Position = UIS:GetMouseLocation()
            CircleObject.Visible = SilentAim.Enabled
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

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true

        SilentAim = Combat:CreateModule({
            Name = 'SilentAim',
            Info = 'Silently Adjusts your aim towards the nearest player',
            Enabled = function()
                if not require then NotifyPoopSploit('require') return end
                if not debug.getupvalue then NotifyPoopSploit('getupvalue') return end

                if GrabShootPacket() and GrabWeaponManager() then
                    OldSend = ShootPacket.send
                    local OldCast = WeaponManager.cast
                    local Ent

                    ShootPacket.send = function(Tab)
                        Ent = EntityLib:GetClosestEntityWithinMouse({
                            Part = Part.Value,
                            Range = Fov.Value,
                            WallCheck = WallCheck.Enabled,
                            Origin = Tab.origin,
                            Players = true,
                            NPCs = true
                        })

                        if Ent then
                            local List = {EntityLib.Character}
                            for _, v in EntityLib.List do
                                table.insert(List, v.Character)
                            end
                            Params.FilterDescendantsInstances = List

                            local Direction = vector.normalize(Ent.Head.Position - Tab.origin)
                            local Raycast = workspace:Raycast(Tab.origin, Direction * 5000)
                            Tab.direction = Direction

                            if not WallCheck.Enabled or (WallCheck.Enabled and Raycast and Raycast.Instance.Parent == Ent.Character) then
                                Tab.position = Raycast and Raycast.Position or Ent.Head.Position
                                Tab.hitResult = Ent.Character
                                Tab.hitPart = SafeRef(Ent.Character, {'Hitbox', 'Hitbox_Head'}) or Ent.Head
                            end
                        end

                        return OldSend(Tab)
                    end

                    local Remove = false

                    WeaponManager.cast = function(Origin, Direction, BulletSpeed, MaxDistance, IgnoreList, FunctionTable, Bool1, Bool2, Bool3, BulletColor)
                        if Ent then
                            Direction = vector.normalize(Ent.Head.Position - Origin)
                            if Remove then
                                Ent = nil
                                Remove = false
                            else
                                Remove = true
                            end
                        end

                        return OldCast(Origin, Direction, BulletSpeed, MaxDistance, IgnoreList, FunctionTable, Bool1, Bool2, Bool3, BulletColor)
                    end

                    SilentAim:Clean(function()
                        ShootPacket.send = OldSend
                        WeaponManager.cast = OldCast
                        OldSend = nil
                        OldCast = nil
                    end)
                else
                    if not WeaponManager then
                        Notify({
                            Text = 'Failed to find WeaponManager',
                            Duration = 5,
                            Type = 'Error'
                        })
                    else
                        Notify({
                            Text = 'Failed to find shoot packet',
                            Duration = 5,
                            Type = 'Error'
                        })
                    end
                end

                if Circle.Enabled and not CircleObject then
                    CreateCircle()
                end

                SilentAim:Clean(RunService.PreRender:Connect(function()
                    if CircleObject then
                        CircleObject.Position = UIS:GetMouseLocation()
                    end
                end))

                SilentAim:Clean(RemoveCircle)
            end,
            ExtraText = 'OneTap'
        })

        WallCheck = SilentAim:CreateToggle({
            Name = 'Wall Check',
            Info = 'Ignores players behind walls',
        })

        Part = SilentAim:CreateDropdown({
            Name = 'Part',
            List = {'Head', 'Root'}
        })

        Fov = SilentAim:CreateSlider({
            Name = 'Fov',
            Default = 100,
            Min = 0,
            Max = 1000,
            Function = UpdateCircle
        })

        Circle = SilentAim:CreateToggle({
            Name = 'Circle',
            Function = function(Enabled)
                if Enabled and SilentAim.Enabled then
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
            Name = "Outline Color",
            Function = UpdateCircle
        })

        FillColor = Circle:CreateColorPicker({
            Name = "Fill Color",
            Transparency = 1,
            Function = UpdateCircle
        })

        OutlineTransparency = Circle:CreateSlider({
            Name = 'Outline Transparency',
            Default = 0,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = UpdateCircle
        })

        FillTransparency = Circle:CreateSlider({
            Name = 'Fill Transparency',
            Default = 1,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = UpdateCircle
        })
    end)
end)

Run(function() -- Other
    Run(function() -- InstantReload
        local InstantReload

        InstantReload = Other:CreateModule({
            Name = 'InstantReload',
            Info = 'Instantly reloads your gun',
            Enabled = function()
                if not require then NotifyPoopSploit('require') return end

                if GrabWeaponManager() then
                    WeaponManager.Constants.DEFAULT_RELOAD_TIME = 0
                    WeaponManager.Constants.DEFAULT_PISTOL_RELOAD_TIME = 0

                    InstantReload:Clean(function()
                        WeaponManager.Constants.DEFAULT_RELOAD_TIME = 0.75
                        WeaponManager.Constants.DEFAULT_PISTOL_RELOAD_TIME = 0.5
                    end)
                else
                    Notify({
                        Text = 'Failed to find WeaponManager',
                        Duration = 5,
                        Type = 'Error'
                    })
                end
            end
        })
    end)

    Run(function() -- InfiniteFirerate
        local InfiniteFirerate

        InfiniteFirerate = Other:CreateModule({
            Name = 'InfiniteFirerate',
            Info = 'Removes the cooldown between shooting',
            Enabled = function()
                if GrabWeaponManager() then
                    WeaponManager.Constants.DEFAULT_PISTOL_FIRERATE = 9e9
                    WeaponManager.Constants.DEFAULT_FIRERATE = 9e9

                    InfiniteFirerate:Clean(function()
                        WeaponManager.Constants.DEFAULT_PISTOL_FIRERATE = 4
                        WeaponManager.Constants.DEFAULT_FIRERATE = 2
                    end)
                else
                    Notify({
                        Text = 'Failed to find WeaponManager',
                        Duration = 5,
                        Type = 'Error'
                    })
                end
            end
        })
    end)

    Run(function() -- NoRecoil
        local NoRecoil

        NoRecoil = Other:CreateModule({
            Name = 'NoRecoil',
            Info = 'Removes gun recoil',
            Enabled = function()
                if not require then NotifyPoopSploit('require') return end
                if not debug.setupvalue then NotifyPoopSploit('setupvalue') return end

                if not Viewmodel then
                    Viewmodel = require(Plr.PlayerScripts.Start.Game.ViewmodelClient)
                end

                if Viewmodel then
                    local FakeViewmodel = newproxy(true)
                    local FakeCamera = newproxy(true)
                    local OldViewmodel
                    local OldFunction

                    debug.setupvalue(Viewmodel.startViewmodel, 8, {RenderStepped = {Connect = function(_, Function)
                        OldFunction = Function
                        OldViewmodel = debug.getupvalue(Function, 1)
                        
                        getmetatable(FakeViewmodel).__index = function(self, i)
                            if i == 'Parent' then
                                return FakeCamera
                            else
                                return OldViewmodel[i]
                            end
                        end

                        getmetatable(FakeCamera).__index = function(self, i)
                            return Camera[i]
                        end

                        getmetatable(FakeCamera).__newindex = function() end

                        debug.setupvalue(Function, 1, FakeViewmodel)
                        debug.setupvalue(Function, 2, FakeCamera)

                        return RunService.RenderStepped:Connect(Function)
                    end}})

                    if EntityLib.Alive then
                        local CurrentWeapon = EntityLib.Character:GetAttribute('currentWeapon') or 'Primary'
                        CurrentWeapon = EntityLib.Character:GetAttribute(`{CurrentWeapon:lower()}Weapon`)
                        if CurrentWeapon then
                            Viewmodel.endViewmodel()
                            Viewmodel.startViewmodel(CurrentWeapon)
                        end
                    end

                    NoRecoil:Clean(function()
                        debug.setupvalue(Viewmodel.startViewmodel, 8, RunService)
                        if OldFunction then
                            debug.setupvalue(OldFunction, 1, OldViewmodel)
                            debug.setupvalue(OldFunction, 2, Camera)
                        end
                    end)
                else
                    Notify({
                        Text = 'Failed to find Viewmodel',
                        Duration = 5,
                        Type = 'Error'
                    })
                end
            end
        })
    end)

    Run(function() -- UnlimitedAmmo
        local UnlimitedAmmo

        UnlimitedAmmo = Other:CreateModule({
            Name = 'UnlimitedAmmo',
            Info = 'Gives you unlimited ammo',
            Enabled = function()
                if GrabWeaponManager() then
                    WeaponManager.Constants.DEFAULT_MAGAZINE = 9e9

                    UnlimitedAmmo:Clean(function()
                        WeaponManager.Constants.DEFAULT_MAGAZINE = 1
                    end)
                else
                    Notify({
                        Text = 'Failed to find WeaponManager',
                        Duration = 5,
                        Type = 'Error'
                    })
                end
            end
        })
    end)

    Run(function() -- FullAuto
        local FullAuto, Firerate

        FullAuto = Other:CreateModule({
            Name = 'FullAuto',
            Info = 'Makes your gun automatic',
            Enabled = function()
                if not require then NotifyPoopSploit('require') return end
                if not debug.getupvalue then NotifyPoopSploit('getupvalue') return end

                if GrabShootPacket() then
                    FullAuto:Clean(UIS.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                            repeat
                                ShootFunction()
                                task.wait(1 / Firerate.Value)
                            until not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or not FullAuto.Enabled
                        end
                    end))
                else
                    Notify({
                        Text = 'Failed to find packet',
                        Duration = 5,
                        Type = 'Error'
                    })
                end
            end
        })

        Firerate = FullAuto:CreateSlider({ 
            Name = 'Firerate',
            Default = 5,
            Min = 1,
            Max = 20
        })
    end)
end)
