local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local ReplicatedStorage: ReplicatedStorage = GetService('ReplicatedStorage')

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local ObjectFunctions = TidalWave.Libraries.ObjectFunctions

local Combat = Categories.Combat
local PlayerCategory = Categories.Player
local Movement = Categories.Movement
local Visuals = Categories.Visuals
local World = Categories.World
local Other = Categories.Other

local hookfunction = hookfunction
local restorefunction = restorefunction
local getgc = getgc or get_gc_objects
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

Run(function() -- Player
    Run(function() -- Noclip
        local Noclip, CurrentGame, GuiRef, Old, Old2

        local Hook2 = function(Result)
            if Result == 'died' then
                local Percentage = CurrentGame:GetPercentage()
                local PercentageGui = GuiRef and GuiRef:FindFirstChild('Percentage')
                local Status = SafeRef(GuiRef, {'PauseFrame', 'Header', 'Progressbar', 'Status'})
                if PercentageGui then
                    PercentageGui.Text = string.format("%.1f%%", math.floor(1000 * Percentage) / 10)
                end
                if Status then
                    Status.Size = UDim2.fromScale(math.clamp(Percentage, 0, 1), 1)
                end
                return nil
            end

            return Old2(Result)
        end

        local Hook = function(a, b, RunFunctions, c)
            GuiRef = debug.getupvalue(RunFunctions.FrameRendered, 2)
            Old2 = hookfunction(RunFunctions.FrameRendered, Hook2)
            Noclip:Clean(function()
                if restorefunction then
                    restorefunction(RunFunctions.FrameRendered)
                elseif Old2 then
                    hookfunction(RunFunctions.FrameRendered, Old2)
                    Old2 = nil
                end
                GuiRef = nil
                CurrentGame = nil
            end)

            CurrentGame = Old(a, b, RunFunctions, c)
            return CurrentGame
        end

        Noclip = PlayerCategory:CreateModule({
            Name = 'Noclip',
            Info = 'Allows you to pass through objects without dying',
            Enabled = function()
                if not require then NotifyPoopSploit('require') return end
                if not getgc then NotifyPoopSploit('getgc') return end
                if not hookfunction then NotifyPoopSploit('hookfunction') return end
                if not debug.getupvalue then NotifyPoopSploit('debug.getupvalue') return end

                local CoreGame = require(ReplicatedStorage.Core.Game)
                Old = hookfunction(CoreGame.New, Hook)
                for _, v in getgc() do
                    if typeof(v) == 'function' and debug.info(v, 'n') == 'FrameRendered' then
                        CurrentGame = debug.getupvalue(v, 1)
                        GuiRef = debug.getupvalue(v, 2)
                        Old2 = hookfunction(v, Hook2)
                        Noclip:Clean(function()
                            if restorefunction then
                                restorefunction(v)
                            elseif Old2 then
                                hookfunction(v, Old2)
                                Old2 = nil
                            end
                            GuiRef = nil
                            CurrentGame = nil
                        end)
                    end
                end

                Noclip:Clean(function()
                    if restorefunction then
                        restorefunction(CoreGame.New)
                    else
                        hookfunction(CoreGame.New, Old)
                    end
                    Old = nil
                end)
            end
        })
    end)
end)