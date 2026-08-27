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

local World = Categories.World

local function Notify(Properties)
    TidalWave:Notify(Properties)
end

local function Run(f)
    f()
end

local function GetClosestCubes(MaxDistance)
    local ClosestCubes = {}

    if EntityLib.Alive then
        for _, Cube in workspace.Cubes:GetChildren() do
            if Cube:IsA('BasePart') then
                local Distance = (Cube.CFrame.Position - EntityLib.Root.CFrame.Position).Magnitude
                if Distance <= MaxDistance then
                    ClosestCubes[#ClosestCubes + 1] = {
                        Cube = Cube,
                        Distance = Distance
                    }
                end
            end
        end
    end

    table.sort(ClosestCubes, function(a, b)
        return a.Distance < b.Distance
    end)

    for i, v in ClosestCubes do
        ClosestCubes[i] = v.Cube
    end

    return ClosestCubes
end

local function GetPickaxe(CheckBackpack)
    if CheckBackpack then
        local Tool
        for _, v in Plr.Backpack:GetChildren() do
            if v:IsA('Tool') and v.Name:find('Pickaxe') then
                Tool = v
                break
            end
        end
        if Tool then
            return Tool
        end
    end
    local Tool = EntityLib.Alive and EntityLib.Character:FindFirstChildOfClass('Tool')
    return Tool and Tool.Name:find('Pickaxe') and Tool or nil
end

Run(function() -- World
    Run(function() -- Nuker
        local Nuker, MineInterval, PerBlockInterval, MaxRange, AutoEquipPickaxe

        local MineRequest = ReplicatedStorage.Remotes.MineRequest

        Nuker = World:CreateModule({
            Name = 'Nuker',
            Info = 'Automatically mines blocks around you.',
            Enabled = function()
                while Nuker.Enabled do
                    local Pickaxe
                    if AutoEquipPickaxe.Enabled and EntityLib.Alive then
                        Pickaxe = GetPickaxe(true)
                        if Pickaxe.Parent == Plr.Backpack then
                            EntityLib.Humanoid:EquipTool(Pickaxe)
                            task.wait(0.1)
                        end
                    end
                    Pickaxe = Pickaxe or GetPickaxe(true)
                    if Pickaxe then
                        local ClosestCubes = GetClosestCubes(MaxRange.Value)
                        if #ClosestCubes > 0 then
                            for _, v in ClosestCubes do
                                MineRequest:FireServer(v, 'Glowy Scythe')
                                if PerBlockInterval.Value > 0 then
                                    task.wait(PerBlockInterval.Value)
                                end
                            end
                        end
                    end
                    task.wait(MineInterval.Value)
                end
            end
        })

        MineInterval = Nuker:CreateSlider({
            Name = 'Mine Interval',
            Default = 0.1,
            Min = 0,
            Max = 1,
            Decimal = 100
        })

        PerBlockInterval = Nuker:CreateSlider({
            Name = 'Per Block Interval',
            Default = 0,
            Max = 0.1,
            Min = 0,
            Decimal = 100
        })

        MaxRange = Nuker:CreateSlider({
            Name = 'Max Range',
            Default = 8,
            Min = 1,
            Max = 16,
            Decimal = 100
        })

        AutoEquipPickaxe = Nuker:CreateToggle({
            Name = 'Auto Equip Pickaxe',
            Info = 'Automatically equips your pickaxe.',
            Default = true
        })
    end)
end)