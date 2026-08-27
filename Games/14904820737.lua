local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local EntityLib = TidalWave.Libraries.EntityLib

local World = Categories.World

local firetouchinterest = firetouchinterest

World:CreateButton({
    Name = 'Claim Obby Reward',
    Function = function()
        if not EntityLib.Alive then return end
        local Lobby = workspace:FindFirstChild('new lobby')
        local Obby = Lobby and Lobby:FindFirstChild('obby')
        local Reward = Obby and Obby:FindFirstChild('Reward')
        if Reward then
            if firetouchinterest then
                firetouchinterest(Reward, EntityLib.Root, true)
                task.wait()
                firetouchinterest(Reward, EntityLib.Root, false)
            else
                EntityLib.Root.CFrame = Reward.CFrame
            end
        end
    end
})