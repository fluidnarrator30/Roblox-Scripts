local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local Players: Players = GetService("Players")
local ReplicatedStorage: ReplicatedStorage = GetService("ReplicatedStorage")

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local EntityLib = TidalWave.Libraries.EntityLib

local World = Categories.World
local Other = Categories.Other

local Plr: Player = Players.LocalPlayer

local firetouchinterest = firetouchinterest

local function Notify(Properties)
    TidalWave:Notify(Properties)
end

local function Run(f)
    f()
end

local function GetPlot()
    for _, Plot in workspace.Interactive.Plots:GetChildren() do
        if Plot:GetAttribute('OwnerUserId') == Plr.UserId then
            return Plot
        end
    end
    
    return nil
end

Run(function() -- World
    Run(function() -- AutoCollect
        local AutoCollect

        AutoCollect = World:CreateModule({
            Name = 'AutoCollect',
            Info = 'Automatically collects money from your femboys.',
            Enabled = function()
                while AutoCollect.Enabled do
                    if EntityLib.Alive then
                        local Plot = GetPlot()
                        if Plot then
                            for _, Slot in Plot.Slots:GetChildren() do
                                if Slot:GetAttribute('CharacterId') ~= nil then
                                    firetouchinterest(EntityLib.Root, Slot.Collecter.Button, true) -- they misspelled 'Collector' bruh
                                    task.wait()
                                    firetouchinterest(EntityLib.Root, Slot.Collecter.Button, false)
                                    task.wait()
                                end
                                if not AutoCollect.Enabled then break end
                            end
                        end
                    end
                    task.wait(1)
                end
            end
        })
    end)
end)

Run(function() -- Other
    Run(function() -- AutoSkip
        local AutoSkip
        
        AutoSkip = Other:CreateModule({
            Name = 'AutoSkip',
            Info = 'Automatically skips roles for you.',
            Enabled = function()
                local Module = require(ReplicatedStorage.Shared.Modules.RollAnimator)

                while AutoSkip.Enabled do
                    Module:RequestSkip()
                    task.wait(0.05)
                end
            end
        })
    end)

    Run(function() -- AutoDelete
        local AutoDelete, Rarities
        
        AutoDelete = Other:CreateModule({
            Name =  'AutoDelete',
            Info = 'Automatically deletes femboys of certain rarities.',
            Enabled = function()
                local Sell = ReplicatedStorage.Remotes.ServerBoundSellCharacter
                while AutoDelete.Enabled do
                    if EntityLib.Alive then
                        for _, Femboy in Plr.Backpack:GetChildren() do
                            local Rarity = Femboy:GetAttribute('Rarity')
                            if Rarity ~= nil and Rarities:Find(Rarity) then
                                EntityLib.Humanoid:EquipTool(Femboy)
                                task.wait()
                                Sell:FireServer(false)
                                local TimeOut = os.clock() + 1
                                repeat
                                    task.wait()
                                until Femboy.Parent ~= EntityLib.Character or not AutoDelete.Enabled or os.clock() >= TimeOut
                                if not AutoDelete.Enabled then break end
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end
        })

        Rarities = AutoDelete:CreateTextList({
            Name = 'Rarities',
            List = {'Common', 'Uncommon', 'Rare', 'Epic'},
            Enabled = {'Common', 'Uncommon'}
        })
    end)

    Run(function() -- AutoBuy
        local AutoBuy, Dices

        AutoBuy = Other:CreateModule({
            Name = 'AutoBuy',
            Info = 'Automatically buys the specified dices.',
            Enabled = function()
                local BuyDice = ReplicatedStorage.Remotes.ServerBoundBuyDice
                while AutoBuy.Enabled do
                    for _, Dice in Dices.Enabled do
                        BuyDice:FireServer(Dice:lower():gsub(' ', '_'), false)
                        task.wait()
                        if not AutoBuy.Enabled then break end
                    end
                    task.wait(0.05)
                end
            end
        })

        Dices = AutoBuy:CreateTextList({
            Name = 'Dices',
            List = {'Basic Dice', 'Silver Dice', 'Golden Dice', 'Platinum Dice', 'Diamond Dice', 'Molten Dice',  'Holy Dice', 'Emerald Dice', 'Marble Dice', 'Galaxy Dice', 'Fluffy Dice', 'Neon Dice', 'Void Dice', 'Calico Dice', 'Boykisser Dice', 'Infinity Dice', 'Ruby Dice', 'Aquamarine Dice', 'Glacial Dice', 'Pride Dice', 'Sakura Dice', 'Pirate Dice', 'Angel Dice', 'New Year Dice', 'Jade Dice', 'Rose Dice', 'Steampunk Dice', 'Cyber Dice', 'Starlight Dice', 'Nature Dice', 'Glitched Dice', 'Radioactive Dice', 'Storm Dice', 'Slime Dice', 'Hellstone Dice', 'Phantom Dice', 'Yinyang Dice', 'Glitter Dice', 'Ancient Dice', 'Witch Dice', 'Eldritch Dice'},
            Enabled = {'Basic Dice'}
        })
    end)
end)