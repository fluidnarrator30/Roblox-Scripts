local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local EntityLib = TidalWave.Libraries.EntityLib
local Drawing = TidalWave.Libraries.Drawing

local Players: Players = GetService("Players")
local RunService: RunService = GetService("RunService")
local ReplicatedStorage: ReplicatedStorage = GetService("ReplicatedStorage")
local UIS: UserInputService = GetService("UserInputService")

local Plr = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Combat = Categories.Combat

local hookfunction = hookfunction
local getcallingscript = getcallingscript
local restorefunction = restorefunction

local function Notify(Properties)
    TidalWave:Notify(Properties)
end

local function NotifyPoopSploit(Function)
    Notify({
        Title = 'Poop Sploit',
        Text = `Your executor doesn't support {Function}`,
        Type = 'Error',
        Duration = 5,
    })
end

local function Run(f)
    f()
end

for i, v in {workspace['Zombie Storage'], workspace.BossFolder} do
    TidalWave:Clean(v.ChildAdded:Connect(function(Child)
        EntityLib:AddEntity(Child)
    end))

    TidalWave:Clean(v.ChildRemoved:Connect(function(Child)
        EntityLib:RemoveEntity(Child)
    end))

    for i2, v2 in v:GetChildren() do
        EntityLib:AddEntity(v2)
    end
end

Run(function() -- Combat
    Run(function() -- SilentAimbot
        local SilentAimbot, WallCheck, Part, Fov, Circle, CircleObject, OutlineColor, FillColor, Thickness, Old

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

        SilentAimbot = Combat:CreateModule({
            Name = "SilentAimbot",
            Info = "Silently Adjusts your aim towards the nearest zombie",
            Enabled = function()
                if not hookfunction then NotifyPoopSploit("hookfunction") return end
                if not getcallingscript then NotifyPoopSploit("getcallingscript") return end

                if Circle.Enabled and not CircleObject then
                    CreateCircle()
                end

                SilentAimbot:Clean(RunService.PreRender:Connect(UpdateCirclePosition))

                Old = hookfunction(Ray.new, function(Origin, Direction)
                    local CallingScript = getcallingscript()

                    if CallingScript and CallingScript.Name == 'GunController' then
                        local Character, Vector = EntityLib:GetClosestEntityWithinMouse({
                            Part = Part.Value,
                            Range = Fov.Value,
                            WallCheck = WallCheck.Enabled,
                            Origin = Origin,
                            NPCs = true,
                            Players = false
                        })

                        if Character then
                            local CoolRay = Camera:ViewportPointToRay(Vector.X, Vector.Y)

                            return Old(CoolRay.Origin, CoolRay.Direction * 5000)
                        end
                    end

                    return Old(Origin, Direction)
                end)

                SilentAimbot:Clean(function()
                    RemoveCircle()
                    if restorefunction then
                        restorefunction(Ray.new)
                    else
                        hookfunction(Ray.new, Old)
                    end
                    Old = nil
                end)
            end
        })

        WallCheck = SilentAimbot:CreateToggle({
            Name = 'WallCheck',
            Info = 'Ignores zombies behind walls',
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
            Visible = false,
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
    end)
end)