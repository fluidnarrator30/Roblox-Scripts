local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local EntityLib = TidalWave.Libraries.EntityLib
local Drawing = TidalWave.Libraries.Drawing

local Players: Players = GetService('Players')
local RunService: RunService = GetService('RunService')
local ReplicatedStorage: ReplicatedStorage = GetService('ReplicatedStorage')
local UIS: UserInputService = GetService('UserInputService')

local Plr: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')

local Combat = Categories.Combat
local Other = Categories.Other

local require = table.find({'Xeno', 'Solara'}, ({identifyexecutor()})[1]) == nil and require or nil

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

Run(function()
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
            Tooltip = "Silently adjusts your aim towards the nearest player.",
            Enabled = function()
                if not require then NotifyPoopSploit('require') return end

                local RaycastModule = require(ReplicatedStorage.Events.Modules.RaycastModule)
                Old = RaycastModule.Raycast

                RaycastModule.Raycast = function(Origin, Direction, Filter)
                    local Character = EntityLib:GetClosestEntityWithinMouse({
                        Part = Part.Value,
                        Range = Fov.Value,
                        Origin = Camera.CFrame.Position,
                        WallCheck = WallCheck.Enabled,
                        NPCs = true,
                        Players = true
                    })

                    if Character then
                        return Old(Origin, CFrame.lookAt(Camera.CFrame.Position, Character[Part.Value].Position).LookVector * 1000, Filter)
                    end

                    return Old(Origin, Direction, Filter)
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
                        RaycastModule.Raycast = Old
                        Old = nil
                    end
                end)
            end
        })

        WallCheck = SilentAimbot:CreateToggle({
            Name = 'Wall Check',
            Info = 'Ignores players behind walls'
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

        Thickness = SilentAimbot:CreateSlider({
            Name = 'Thickness',
            Default = 1,
            Min = 1,
            Max = 10,
            Visible = false,
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