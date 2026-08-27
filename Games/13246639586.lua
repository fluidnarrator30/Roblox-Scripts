local function DownloadFile(Path, Function)
	if not isfile(Path) then
		local Success, Result = pcall(function()
			return game:HttpGet(`https://raw.githubusercontent.com/fluidnarrator30/Tidal-Wave/{readfile('TidalWave/Profiles/Commit.txt')}/{Path:gsub('TidalWave/', '')}`, true)
		end)
        if Success and Result ~= "404: Not Found" then
            writefile(Path, Result)
        end
	end
    return (Function or readfile)(Path)
end

loadstring(DownloadFile('TidalWave/Games/8542275097.lua'))()

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
local Modules = TidalWave.Modules
local ObjectFunctions = TidalWave.Libraries.ObjectFunctions

local Plr = Players.LocalPlayer
local Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')

local Combat = Categories.Combat

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

local firetouchinterest = firetouchinterest

local function Run(f)
    f()
end

local function SafeRef(Obj, Path)
    return ObjectFunctions:SafeRef(Obj, Path)
end

Run(function()
    Run(function() -- AutoWin
        local AutoWin

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
        
        AutoWin = Combat:CreateModule({
            Name = 'AutoWin',
            Info = 'Automatically wins the game for you',
            Enabled = function()
                repeat
                    task.wait()
                until GameInProgress() or not AutoWin.Enabled
                if not AutoWin.Enabled then return end

                local SpawnLocations

                repeat
                    SpawnLocations = SafeRef(workspace, {'BlockContainer', 'Map', 'SpawnLocations'})
                    task.wait()
                until SpawnLocations or not AutoWin.Enabled

                while GameInProgress() and AutoWin.Enabled do
                    for _, SpawnLocation in SpawnLocations:GetChildren() do
                        if #SpawnLocation:GetChildren() <= 0 then
                            local Portals
                            repeat
                                Portals = SafeRef(workspace, {'BlockContainer', 'Map', 'Portals'})
                                task.wait()
                            until Portals or not AutoWin.Enabled
                            
                            if Portals and AutoWin.Enabled then
                                for _, v in Portals:GetChildren() do
                                    if v:IsA('BasePart') then
                                        if firetouchinterest then
                                            firetouchinterest(EntityLib.Root, v, true)
                                            task.wait()
                                            firetouchinterest(EntityLib.Root, v, false)
                                        else
                                            EntityLib.Root.CFrame = v.CFrame
                                        end
                                    end
                                end
                            end
                            task.wait()
                            break
                        end
                        if not AutoWin.Enabled then break end
                    end
                    task.wait()
                end
            end,
        })
    end)
end)