local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local EntityLib = TidalWave.Libraries.EntityLib

local Players: Players = GetService('Players')
local ReplicatedStorage: ReplicatedStorage = GetService('ReplicatedStorage')
local UIS: UserInputService = GetService('UserInputService')

local Plr: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')

local Combat = Categories.Combat
local World = Categories.World

TidalWave:Clean(workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
    Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')
end))

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

Run(function()
    Run(function()
        local Boom, Interval

        local ExplodeRocket = ReplicatedStorage.Remotes.explodeRocket

        local Params = RaycastParams.new()
        Params.RespectCanCollide = true

        Boom = World:CreateModule({
            Name = "Boom",
            Info = "It go boom.",
            Enabled = function()
                while Boom.Enabled do
                    local Launcher = EntityLib.Alive and EntityLib.Character:FindFirstChildOfClass("Tool")
                    if Launcher then
                        Params.FilterDescendantsInstances = {EntityLib.Character}
                        local MouseLocation = UIS:GetMouseLocation()
                        local MouseRaycast = Camera:ViewportPointToRay(MouseLocation.X, MouseLocation.Y)
                        local Raycast = workspace:Raycast(MouseRaycast.Origin, MouseRaycast.Direction * 1000, Params)
                        if Raycast then
                            ExplodeRocket:FireServer(tick(), Launcher.Stats, Raycast.Position, Launcher.Assets.Rocket.Boom)
                            task.wait(Interval.Value)
                        else
                            task.wait()
                        end
                    else
                        task.wait()
                    end
                end
            end
        })

        Interval = Boom:CreateSlider({
            Name = "Interval",
            Default = 0,
            Min = 0,
            Max = 1,
            Decimal = 100,
        })
    end)
end)