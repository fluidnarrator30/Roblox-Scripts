local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local Players: Players = GetService('Players')
local HttpService: HttpService = GetService('HttpService')

local Plr: Player = Players.LocalPlayer

local TidalWave = shared.TidalWave
local Libraries = TidalWave.Libraries
local Hash = Libraries.Hash

local Whitelist = {
	CheckedPlayers = {},
	Hashes = setmetatable({}, {__index = function(self, i)
        self[i] = Hash.sha512(i)
        return self[i]
    end}),
	Data = {
        WhitelistedUsers = {}
    },
	Level = 1
}

local function Notify(Properties)
    TidalWave:Notify(Properties)
end

function Whitelist:Get(Player)
    local PlayerHash = self.Hashes[Player.Name .. Player.UserId]
    for _, User in self.Data.WhitelistedUsers do
        for _, Hash in User.Hashes do
            if Hash == PlayerHash then
                return User.Level, User.Attackable or Whitelist.Level >= User.Level
            end
        end
    end

    return 0, true
end

function Whitelist:IsInGame()
    for _, v in Players:GetPlayers() do
        if self:Get(v) ~= 0 then
            return true
        end
    end

    return false
end

function Whitelist:GetPlayer(Arg: string, Player: Player): boolean
    Arg = Arg:lower()

    if Arg == 'default' and self.Level == 0 then
        return true
    end

    if Arg == 'private' and self.Level == 1 then
        return true
    end

    if Arg == 'others' and Player ~= Plr then
        return true
    end

    if Plr.Name:lower():sub(1, #Arg) == Arg then
        return true
    end

    return false
end

local OldShutdown
function Whitelist:PlayerAdded(Player, joined)
    if self:Get(Player) ~= 0 then
        if self.CheckedPlayers[Player.UserId] then return end
        self.CheckedPlayers[Player.UserId] = true

        if self.Level == 0 and not OldShutdown then
            OldShutdown = TidalWave.Shutdown
            TidalWave.Shutdown = function()
                Notify({
                    Text = 'No escaping the private members :)',
                    Duration = 10
                })
            end
        end
    end
end

if not shared.TidalWaveDev then
    local Commit = readfile and readfile('TidalWave/Profiles/Commit.txt') or 'main'

    local Success, Result = pcall(function()
        return game:HttpGet(`https://raw.githubusercontent.com/fluidnarrator30/Tidal-Wave/{Commit}/Whitelist.json`)
    end)

    if Success and Result ~= '404: Not Found' then
        Whitelist.Data = HttpService:JSONDecode(Result)
    end
end

Whitelist.Level = Whitelist:Get(Plr)

TidalWave:Clean(Players.PlayerAdded:Connect(function(Player)
    Whitelist:PlayerAdded(Player, true)
end))

TidalWave:Clean(function()
    table.clear(Whitelist.Data.WhitelistedUsers)
    table.clear(Whitelist.Data)
    table.clear(Whitelist.Hashes)
    table.clear(Whitelist.CheckedPlayers)
    table.clear(Whitelist)
    Whitelist = nil
end)

return Whitelist
