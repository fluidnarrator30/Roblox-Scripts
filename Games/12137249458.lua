local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local EntityLib = TidalWave.Libraries.EntityLib
local Drawing = TidalWave.Libraries.Drawing

local Players: Players = GetService("Players")
local TweenService: TweenService = GetService("TweenService")
local RunService: RunService = GetService("RunService")
local ReplicatedStorage: ReplicatedStorage = GetService("ReplicatedStorage")
local UIS: UserInputService = GetService("UserInputService")

local Plr: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')

local Combat = Categories.Combat

local require = table.find({'Xeno', 'Solara'}, ({identifyexecutor()})[1]) == nil and require or nil

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

Run(function()
    Run(function()
        local SilentAimbot, WallCheck, WallBang, Part, Fov, Circle, OutlineColor, FillColor, Thickness

        local CircleObject, Old

        local function CreateCircle()
            CircleObject = Drawing.new("Circle")
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
            Info = "Silently adjusts your aim towards the nearest target",
            Enabled = function()
                if not require then NotifyPoopSploit('require') return end

                local ProjectileModule = require(ReplicatedStorage.ModuleScripts.GunModules.GunFramework.Projectile)

                Old = ProjectileModule.Cast
                ProjectileModule.Cast = function(self, Tick, Origin, Direction, BulletForce)
                    local Character = EntityLib:GetClosestEntityWithinMouse({
                        Part = Part.Value,
                        Range = Fov.Value,
                        Origin = Origin,
                        WallCheck = WallCheck.Enabled,
                        NPCs = false,
                        Players = true
                    })

                    if Character then
                        if WallBang.Enabled and not WallCheck.Enabled then
                            Origin = Character[Part.Value].Position
                            local LookVector = Character[Part.Value].CFrame.LookVector
                            return Old(self, Tick, Origin - (LookVector * 3), Origin + (LookVector * 1000), BulletForce)
                        end

                        return Old(self, Tick, Origin, Origin + (Character[Part.Value].Position - Origin), BulletForce)
                    end

                    return Old(self, Tick, Origin, Direction, BulletForce)
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
                        ProjectileModule.Cast = Old
                    end
                end)
            end
        })

        WallCheck = SilentAimbot:CreateToggle({
            Name = 'WallCheck',
            Info = 'Ignores players behind walls',
            Function = function(Enabled)
                WallBang:SetVisible(not Enabled)
            end
        })

        WallBang = SilentAimbot:CreateToggle({
            Name = 'WallBang',
            Info = 'Allows you to shoot players through walls\nWorks best when shooting towards the air'
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