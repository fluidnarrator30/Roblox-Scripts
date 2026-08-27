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
local Scripts = Categories.Scripts
local Server = Categories.Server

local Plr: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera

local require = table.find({'Xeno', 'Solara'}, ({identifyexecutor()})[1]) == nil and require or nil

local function Notify(Properties)
    TidalWave:Notify(Properties)
end

local function Run(f)
    f()
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

Run(function() -- EntityLib
    function EntityLib:IsTeammate()
        return false
    end

    local function ChildAdded(Child)
        if Child.ClassName == 'Model' then
            local Animate = Child:WaitForChild('Animate', 5)
            if Animate and Animate.ClassName == 'Script' then
                EntityLib:AddEntity(Child)
            end
        end
    end

    TidalWave:Clean(workspace.ChildAdded:Connect(ChildAdded))
    TidalWave:Clean(workspace.ChildRemoved:Connect(function(Child)
        if Child.ClassName == 'Model' then
            local Character = EntityLib:FindNPC(Child)
            if Character then
                EntityLib:RemoveEntity(Character.Character)
            end
        end
    end))

    for _, v in workspace:GetChildren() do
        if v.ClassName == 'Model' then
            task.spawn(ChildAdded, v)
        end
    end
end)

Run(function() -- Combat
    Run(function() -- SilentAimbot
        local SilentAimbot, WallCheck, Part, Fov, Circle, OutlineColor, FillColor, Thickness

        local CircleObject

        local function UpdateCirclePosition()
            if CircleObject then
                CircleObject.Position = UIS:GetMouseLocation()
            end
        end

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

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true

        SilentAimbot = Combat:CreateModule({
            Name = 'SilentAimbot',
            Info = 'Silently Adjusts your aim towards the closest player',
            Enabled = function()
                if not require then NotifyPoopSploit('require') return end

                local Packet = require(ReplicatedStorage.Common.Packets.WeaponPackets)

                local Old = Packet.useWeapon.send
                Packet.useWeapon.send = function(Tab)
                    local Character = EntityLib:GetClosestEntityWithinMouse({
                        Part = Part.Value,
                        Range = Fov.Value,
                        WallCheck = WallCheck.Enabled,
                        Origin = Tab.origin,
                        Players = true,
                        NPCs = true
                    })

                    if Character then
                        local List = {EntityLib.Character}
                        for _, v in EntityLib.List do
                            if not EntityLib:CanAttack(v) then
                                table.insert(List, v.Character)
                            end
                        end

                        Params.FilterDescendantsInstances = List

                        local Raycast = workspace:Raycast(Tab.origin, (Character.Head.Position - Tab.origin) * 1000, Params)
                        Tab.direction = CFrame.lookAt(Tab.origin, Character.Head.Position).LookVector
                        Tab.position = Raycast and Raycast.Position or Character.Head.Position
                        Tab.hitPart = SafeRef(Character.Character, {'Hitbox', 'Hitbox_Head'}) or Character.Head
                        Tab.hitResult = Character.Character
                    end

                    return Old(Tab)
                end

                SilentAimbot:Clean(RunService.PreRender:Connect(UpdateCirclePosition))

                if Circle.Enabled and not CircleObject then
                    CreateCircle()
                end

                SilentAimbot:Clean(function()
                    RemoveCircle()
                    if Old then
                        Packet.useWeapon.send = Old
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
end)