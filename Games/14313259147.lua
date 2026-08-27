local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local EntityLib = TidalWave.Libraries.EntityLib
local Drawing = TidalWave.Libraries.Drawing
local ObjectFunctions = TidalWave.Libraries.ObjectFunctions

local Players: Players = GetService("Players")
local RunService: RunService = GetService("RunService")
local ReplicatedStorage: ReplicatedStorage = GetService("ReplicatedStorage")
local UIS: UserInputService = GetService("UserInputService")

local Plr = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Combat = Categories.Combat
local Other = Categories.Other

local require = table.find({'Solara', 'Xeno'}, ({identifyexecutor()})[1]) == nil and require or nil

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

local function Run(f)
    f()
end

local function SafeRef(Obj, Path)
    return ObjectFunctions:SafeRef(Obj, Path)
end

Run(function() -- Combat
    Run(function() -- SilentAimbot
        local SilentAimbot, WallCheck, Part, Fov, Circle, CircleObject, OutlineColor, FillColor, Thickness, Old

        local function CreateCircle()
            CircleObject = Drawing.new('Circle')
            CircleObject.Radius = Fov.Value
            CircleObject.FillTransparency = FillColor.Transparency
            CircleObject.OutlineTransparency = OutlineColor.Transparency
            CircleObject.FillColor = FillColor.Color
            CircleObject.OutlineColor = OutlineColor.Color
            CircleObject.Thickness = Thickness.Value
            CircleObject.Position = UIS:GetMouseLocation()
            CircleObject.Visible = SilentAimbot.Enabled
            CircleObject.Parent = TidalWave.Gui
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

        local function RemoveCircle()
            if CircleObject then
                CircleObject:Destroy()
                CircleObject = nil
            end
        end

        SilentAimbot = Combat:CreateModule({
            Name = 'SilentAimbot',
            Info = 'Silently Adjusts your aim towards the nearest player',
            Enabled = function()
                if not require then NotifyPoopSploit('require') return end
                
                local BaseWeapon = require(ReplicatedStorage.WeaponsSystem.Libraries.BaseWeapon)
                Old = BaseWeapon.fire

                BaseWeapon.fire = function(Tab, Origin, Direction, a)
                    local Character = EntityLib:GetClosestEntityWithinMouse({
                        Part = Part.Value,
                        Range = Fov.Value,
                        WallCheck = WallCheck.Enabled,
                        Origin = Origin,
                        Players = true
                    })

                    if Character then
                        return Old(Tab, Origin, (Character[Part.Value].Position - Origin).Unit, a)
                    end
                    
                    return Old(Tab, Origin, Direction, a)
                end

                if Circle.Enabled and not CircleObject then
                    CreateCircle()
                end

                SilentAimbot:Clean(RunService.PreRender:Connect(function()
                    if CircleObject then
                        CircleObject.Position = UIS:GetMouseLocation()
                    end
                end))

                SilentAimbot:Clean(function()
                    RemoveCircle()
                    if Old then
                        BaseWeapon.fire = Old
                        Old = nil
                    end
                end)
            end
        })

        WallCheck = SilentAimbot:CreateToggle({
            Name = 'WallCheck',
            Info = 'Ignores players behind walls',
        })

        Part = SilentAimbot:CreateDropdown({
            Name = 'Part',
            List = {'Head', 'Root'}
        })

        Fov = SilentAimbot:CreateSlider({
            Name = 'Fov',
            Default = 100,
            Min = 0,
            Max = 1000,
            Function = UpdateCircle
        })

        Circle = SilentAimbot:CreateToggle({
            Name = 'Circle',
            Function = function(Enabled)
                if Enabled and SilentAimbot.Enabled then
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

    Run(function() -- UnlimitedAmmo
        local UnlimitedAmmo, Con, Con2

        local function LocalRemoved()
            if Con then
                Con:Disconnect()
                Con = nil
            end
            if Con2 then
                Con2:Disconnect()
                Con2 = nil
            end
        end

        local function LocalAdded()
            LocalRemoved()
            Con = UnlimitedAmmo:Clean(EntityLib.Character.ChildAdded:Connect(function(Child)
                if Child:IsA('Tool') then
                    local TimeOut = os.clock() + 5
                    local Ammo
                    local MaxAmmo
                    repeat
                        Ammo = Child:FindFirstChild('CurrentAmmo')
                        MaxAmmo = SafeRef(Child, {'Configuration', 'AmmoCapacity'})
                        task.wait()
                    until MaxAmmo and Ammo or not UnlimitedAmmo.Enabled or os.clock() >= TimeOut
                    if UnlimitedAmmo.Enabled and MaxAmmo and Ammo then
                        if Con2 then
                            Con2:Disconnect()
                            Con2 = nil
                        end
                        Ammo.Value = MaxAmmo.Value
                        Con2 = UnlimitedAmmo:Clean(Ammo:GetPropertyChangedSignal('Value'):Connect(function()
                            Ammo.Value = MaxAmmo.Value
                        end))
                    end
                end
            end))
        end

        UnlimitedAmmo = Combat:CreateModule({
            Name = 'UnlimitedAmmo',
            Info = 'Gives you unlimited ammo.',
            Function = function(Enabled)
                if Enabled then
                    UnlimitedAmmo:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    UnlimitedAmmo:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if EntityLib.Alive then
                        LocalAdded()
                    end
                else
                    Con, Con2 = nil, nil
                end
            end
        })
    end)

    Run(function() -- FullAuto
        local FullAuto, Con, Con2, Con3

        local Modifed = {}
        local FireModes = {}

        local function LocalRemoved()
            if Con then
                Con:Disconnect()
                Con = nil
            end
            if Con2 then
                Con2:Disconnect()
                Con2 = nil
            end
            if Con3 then
                Con3:Disconnect()
                Con3 = nil
            end
        end

        local function LocalAdded()
            LocalRemoved()
            Con = FullAuto:Clean(EntityLib.Character.ChildAdded:Connect(function(Child)
                if Child:IsA('Tool') then
                    local TimeOut = os.clock() + 5
                    local Configuration
                    local ShotCooldown
                    repeat
                        Configuration = Child:FindFirstChild('Configuration')
                        ShotCooldown = Configuration and Configuration:FindFirstChild('ShotCooldown')
                        task.wait()
                    until Configuration and ShotCooldown or not FullAuto.Enabled or os.clock() >= TimeOut
                    local FireMode = Child:FindFirstChild('FireMode')
                    if FireMode and not table.find(FireModes, FireMode) then
                        Modifed[FireMode] = FireMode.Value
                        FireMode.Value = 'Automatic'
                    elseif not table.find(FireModes, FireMode) then
                        FireMode = Instance.new('StringValue')
                        FireMode.Name = 'FireMode'
                        FireMode.Value = 'Automatic'
                        FireMode.Parent = Configuration
                        FireModes[#FireModes + 1] = FireMode
                    else
                        FireMode = nil
                    end
                    if FireMode then
                        if Con3 then
                            Con3:Disconnect()
                            Con3 = nil
                        end
                        Con3 = FireMode:GetPropertyChangedSignal('Value'):Connect(function()
                            Modifed[FireMode] = FireMode.Value
                            FireMode.Value = 'Automatic'
                        end)
                    end
                    if FullAuto.Enabled and ShotCooldown then
                        if Con2 then
                            Con2:Disconnect()
                            Con2 = nil
                        end
                        Modifed[ShotCooldown] = ShotCooldown.Value
                        ShotCooldown.Value = 0
                        Con2 = FullAuto:Clean(ShotCooldown:GetPropertyChangedSignal('Value'):Connect(function()
                            Modifed[ShotCooldown] = ShotCooldown.Value
                            ShotCooldown.Value = 0
                        end))
                    end
                end
            end))
        end

        FullAuto = Combat:CreateModule({
            Name = 'FullAuto',
            Info = 'ay ay no full auto in the building',
            Function = function(Enabled)
                if Enabled then
                    FullAuto:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    FullAuto:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if EntityLib.Alive then
                        LocalAdded()
                    end
                else
                    Con, Con2 = nil, nil
                    for i, v in Modifed do
                        i.Value = v
                    end
                    table.clear(Modifed)
                    for _, v in FireModes do
                        v:Destroy()
                    end
                    table.clear(FireModes)
                end
            end
        })
    end)
end)

Run(function() -- Other
    Run(function() -- NoRecoil
        local NoRecoil, Con, Con2, Con3

        local Modifed = {}

        local function LocalRemoved()
            if Con then
                Con:Disconnect()
                Con = nil
            end
            if Con2 then
                Con2:Disconnect()
                Con2 = nil
            end
            if Con3 then
                Con3:Disconnect()
                Con3 = nil
            end
        end

        local function LocalAdded()
            LocalRemoved()
            Con = NoRecoil:Clean(EntityLib.Character.ChildAdded:Connect(function(Child)
                if Child:IsA('Tool') then
                    local TimeOut = os.clock() + 5
                    local RecoilMin, RecoilMax
                    repeat
                        RecoilMin = SafeRef(Child, {'Configuration', 'RecoilMin'})
                        RecoilMax = SafeRef(Child, {'Configuration', 'RecoilMax'})
                        task.wait()
                    until RecoilMin and RecoilMax or not NoRecoil.Enabled or os.clock() >= TimeOut
                    if NoRecoil.Enabled and RecoilMin and RecoilMax then
                        if Con2 then
                            Con2:Disconnect()
                            Con2 = nil
                        end
                        if Con3 then
                            Con3:Disconnect()
                            Con3 = nil
                        end
                        Modifed[RecoilMin] = RecoilMin.Value
                        Modifed[RecoilMax] = RecoilMax.Value
                        RecoilMin.Value = 0
                        RecoilMax.Value = 0
                        Con2 = NoRecoil:Clean(RecoilMin:GetPropertyChangedSignal('Value'):Connect(function()
                            Modifed[RecoilMin] = RecoilMin.Value
                            RecoilMin.Value = 0
                        end))
                        Con3 = NoRecoil:Clean(RecoilMax:GetPropertyChangedSignal('Value'):Connect(function()
                            Modifed[RecoilMax] = RecoilMax.Value
                            RecoilMax.Value = 0
                        end))
                    end
                end
            end))
        end

        NoRecoil = Combat:CreateModule({
            Name = 'NoRecoil',
            Info = 'Removes gun recoil.',
            Function = function(Enabled)
                if Enabled then
                    NoRecoil:Clean(EntityLib.Events.LocalAdded:Connect(LocalAdded))
                    NoRecoil:Clean(EntityLib.Events.LocalRemoved:Connect(LocalRemoved))
                    if EntityLib.Alive then
                        LocalAdded()
                    end
                else
                    Con, Con2 = nil, nil
                    for i, v in Modifed do
                        i.Value = v
                    end
                    table.clear(Modifed)
                end
            end
        })
    end)
end)