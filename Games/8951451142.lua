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
local RunService: RunService = GetService("RunService")

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

local function Run(f)
    f()
end

local function SafeRef(Obj, Path)
    return ObjectFunctions:SafeRef(Obj, Path)
end

Run(function() -- Combat
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

        local UpOffset = vector.yAxis * 1000
        local CFrameOffset = CFrame.new(0, 3, 6)
        local EggOffset = CFrame.new(0, -7, 0)

        AutoWin = Combat:CreateModule({
            Name = "Auto Win",
            Info = "It Win For You (:",
            Enabled = function()
                repeat
                    task.wait()
                until GameInProgress() or not AutoWin.Enabled
                if not AutoWin.Enabled then return end
                
                local Eggs

                repeat
                    Eggs = workspace:FindFirstChild('Eggs')
                    task.wait()
                until Eggs or not AutoWin.Enabled
                if not AutoWin.Enabled then return end

                if not Modules.EggNuker.Enabled then
                    Modules.EggNuker:Toggle(true)
                end
                if not Modules.KillAura.Enabled then
                    Modules.KillAura:Toggle(true)
                end

                local LocalTeamId = Plr:GetAttribute('TeamId')

                for _, Egg in Eggs:GetChildren() do
                    if Egg:IsA('Model') and Egg.PrimaryPart and Egg:GetAttribute('TeamId') ~= LocalTeamId and Egg:GetAttribute('Health') > 0 then
                        repeat
                            RunService.PreSimulation:Wait()
                            EntityLib.Root.AssemblyLinearVelocity = vector.zero
                            EntityLib.Root.CFrame = Egg.PrimaryPart.CFrame:ToWorldSpace(EggOffset)
                            RunService.PostSimulation:Wait()
                            EntityLib.Root.AssemblyLinearVelocity = vector.zero
                            EntityLib.Root.CFrame = Egg.PrimaryPart.CFrame:ToWorldSpace(EggOffset)
                        until Egg:GetAttribute('Health') <= 0 or not AutoWin.Enabled
                        
                        if not AutoWin.Enabled then break end
                    end
                end

                if not AutoWin.Enabled then return end

                local AllPlayers = Players:GetPlayers()
                local TargetIndex = 1
                local Offset = vector.zero

                for i, Player in Players:GetPlayers() do
                    if Player == Plr then continue end

                    local TeamId = Player:GetAttribute('TeamId')
                    if TeamId == LocalTeamId then continue end

                    table.insert(AllPlayers, Player)
                end

                AutoWin:Clean(Players.PlayerAdded:Connect(function(Player)
                    local TeamId
                    repeat
                        TeamId = Player:GetAttribute('TeamId')
                        task.wait()
                    until TeamId or not AutoWin.Enabled

                    if TeamId == LocalTeamId or not AutoWin.Enabled then return end

                    table.insert(AllPlayers, Player)
                end))

                AutoWin:Clean(Players.PlayerRemoving:Connect(function(Player)
                    local Index = table.find(AllPlayers, Player)
                    if Index then
                        table.remove(AllPlayers, Index)
                    end
                end))

                Params.FilterDescendantsInstances = {workspace.BlockContainer}

                AutoWin:Clean(RunService.PreSimulation:Connect(function()
                    if #AllPlayers == 0 or not EntityLib.Alive then return end

                    local Player = AllPlayers[TargetIndex]
                    local Char = Player and EntityLib:FindEntity(Player) or nil

                    if not Char then return end

                    local Raycast = workspace:Raycast(Char.Root.Position, Char.Root.Position - UpOffset, Params)
                    if not Raycast and Char.Root.AssemblyLinearVelocity.Y <= -100 then
                        Target += 1
                        return
                    end

                    if Plr:GetAttribute('Health') < 25 then
                        Offset = UpOffset
                    else
                        Offset = vector.zero
                    end
                    
                    EntityLib.Root.AssemblyLinearVelocity = vector.zero
                    EntityLib.Root.CFrame = Char.Root.CFrame:ToWorldSpace(CFrameOffset) + Offset

                    RunService.PostSimulation:Wait()

                    EntityLib.Root.AssemblyLinearVelocity = vector.zero
                    EntityLib.Root.CFrame = Char.Root.CFrame:ToWorldSpace(CFrameOffset) + Offset
                end))
            end,
        })
    end)
end)