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

local Plr: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera

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

local function GetFullName(Obj)
    return ObjectFunctions:GetFullName(Obj)
end

local function SafeRef(Obj, Path)
    return ObjectFunctions:SafeRef(Obj, Path)
end

TidalWave:Clean(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
    Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')
end))

Run(function() -- CharacterLib
    function CharacterLib:IsTeammate()
        return false
    end
    local function ChildAdded(Child)
        if Child.ClassName == 'Model' then
            local Animate = Child:WaitForChild('Animate', 5)
            if Animate and Animate.ClassName == 'Script' then
                CharacterLib:AddCharacter(Child)
            end
        end
    end
    TidalWave:Clean(workspace.ChildAdded:Connect(ChildAdded))
    TidalWave:Clean(workspace.ChildRemoved:Connect(function(Child)
        if Child.ClassName == 'Model' then
            local Character = CharacterLib:FindCharacter(Child, {NPCS = true})
            if Character then
                CharacterLib:RemoveCharacter(Character.Character)
            end
        end
    end))
    for _, v in workspace:GetChildren() do
        task.spawn(ChildAdded, v)
    end
end)

Run(function() -- Combat
    Run(function() -- SilentAimbot
        local SilentAimbot, WallCheck, Part, Fov, Circle, CircleObject, OutlineColor, FillColor, OutlineTransparency, FillTransparency, Thickness

        local function UpdateCirclePosition()
            if CircleObject then
                CircleObject.Position = UIS:GetMouseLocation()
            end
        end

        local function CreateCircle()
            CircleObject = Drawing.new("Circle")
            CircleObject.Radius = Fov.Value
            CircleObject.FillTransparency = FillTransparency.Value
            CircleObject.OutlineTransparency = OutlineTransparency.Value
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
                CircleObject.FillTransparency = FillTransparency.Value
                CircleObject.OutlineTransparency = OutlineTransparency.Value
                CircleObject.FillColor = FillColor.Color
                CircleObject.OutlineColor = OutlineColor.Color
                CircleObject.Thickness = Thickness.Value
            end
        end

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true

        SilentAimbot = Combat:CreateModule({
            Name = "SilentAimbot",
            Info = "Silently Adjusts your aim towards the nearest zombie",
            Enabled = function()
                SilentAimbot:Clean(RunService.PreRender:Connect(UpdateCirclePosition))

                local Packet = require(game:GetService("ReplicatedStorage").Common.Packets.WeaponPackets)

                local Old = Packet.useWeapon.send
                Packet.useWeapon.send = function(Tab)
                    local Character = CharacterLib:GetClosestCharacterWithinMouse({
                        Part = Part.Value,
                        Range = Fov.Value,
                        WallCheck = WallCheck.Enabled,
                        Origin = Tab.origin,
                        Players = true,
                        NPCS = true
                    })

                    if Character then
                        local List = {CharacterLib.Character}
                        for _, v in CharacterLib.List do
                            if not CharacterLib:CanAttack(v) then
                                List[#List + 1] = v
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
            Name = "WallCheck",
            Info = "Ignores zombies behind walls",
        })

        Part = SilentAimbot:CreateDropdown({
            Name = "Part",
            List = {"Head", "Root"}
        })

        Fov = SilentAimbot:CreateSlider({
            Name = "Fov",
            Default = 100,
            Min = 0,
            Max = 1000,
            Function = UpdateCircle
        })

        Circle = SilentAimbot:CreateToggle({
            Name = "Circle",
            Function = function(Enabled)
                if Enabled and SilentAimbot.Enabled then
                    CreateCircle()
                else
                    RemoveCircle()
                end
                for i, v in {Fov, Thickness, OutlineTransparency, FillTransparency, OutlineColor, FillColor} do
                    v:SetVisible(Enabled)
                end
            end
        })

        Thickness = SilentAimbot:CreateSlider({
            Name = "Thickness",
            Default = 1,
            Min = 1,
            Max = 10,
            Visible = false,
            Function = UpdateCircle
        })

        OutlineTransparency = SilentAimbot:CreateSlider({
            Name = "Outline Transparency",
            Default = 0,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Visible = false,
            Function = UpdateCircle
        })

        FillTransparency = SilentAimbot:CreateSlider({
            Name = "Fill Transparency",
            Default = 1,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Visible = false,
            Function = UpdateCircle
        })

        OutlineColor = SilentAimbot:CreateColorPicker({
            Name = "Outline Color",
            Default = Color3.fromRGB(255, 255, 255),
            Visible = false,
            Function = UpdateCircle
        })

        FillColor = SilentAimbot:CreateColorPicker({
            Name = "Fill Color",
            Default = Color3.fromRGB(255, 255, 255),
            Visible = false,
            Function = UpdateCircle
        })
    end)
end)