local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories

local MarketplaceService: MarketplaceService = GetService('MarketplaceService')
local Players: Players = GetService('Players')
local ReplicatedStorage: ReplicatedStorage = GetService('ReplicatedStorage')

local Plr = Players.LocalPlayer

local World = Categories.World

local function Run(f)
    f()
end

Run(function()
    Run(function()
        local Nuke, Amount

        local Event = ReplicatedStorage.ServerEvents.Nuke

        Nuke = World:CreateButton({
            Name = 'Nuke',
            Info = 'Nukes the server :D',
            Function = function()
                for i = 1, Amount.Value do
                    MarketplaceService:SignalPromptProductPurchaseFinished(Plr.UserId, 1586234773, true)
                    Event:FireServer()
                end
            end
        })

        Amount = Nuke:CreateSlider({
            Name = 'Amount',
            Default = 1,
            Min = 1,
            Max = 100
        })
    end)
end)