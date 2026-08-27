local cloneref = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return cloneref(game:GetService(Service))
end

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local EntityLib = TidalWave.Libraries.EntityLib

local Players: Players = GetService('Players')
local RunService: RunService = GetService('RunService')
local ReplicatedStorage: ReplicatedStorage = GetService('ReplicatedStorage')

local Movement = Categories.Movement

local Plr = Players.LocalPlayer

local Goal = vector.create(0, 15300, 40030)

do
    local TweenSpeed
    local AutoRebirth

    local function TeleportToEnd()
        if not EntityLib.Alive then return end

        local Start = EntityLib.Root.Position
        local Alpha = 0

        while true do
            if not EntityLib.Alive then break end
            Alpha += RunService.PostSimulation:Wait() / TweenSpeed.Value
            if Alpha >= 1 then
                Alpha = 1
            end
            EntityLib.Root.CFrame = CFrame.new(vector.lerp(Start, Goal, Alpha))
            if Alpha == 1 then
                break
            end
        end
    end

    local function Rebirth()
        TeleportToEnd()

        local Leaderstats = Plr:FindFirstChild("leaderstats")
        local Steps = Leaderstats and Leaderstats:FindFirstChild("Steps")
        local TimeOut = os.clock() + 3

        while AutoRebirth.Enabled and Steps and Steps.Value < 20000 and os.clock() < TimeOut do
            task.wait()
        end
        
        local RebirthRemote = ReplicatedStorage:FindFirstChild("TurtleEvent")
        if RebirthRemote then
            RebirthRemote:FireServer()
        end
    end

    local TeleportToEndButton = Movement:CreateButton({
        Name = "Teleport To End",
        Function = TeleportToEnd
    })

    TweenSpeed = TeleportToEndButton:CreateSlider({
        Name = "Speed",
        Default = 1,
        Min = 0.1,
        Max = 3,
        Decimal = 100
    })

    Movement:CreateButton({
        Name = "Rebirth",
        Function = Rebirth
    })

    AutoRebirth = Movement:CreateModule({
        Name = "Auto Rebirth",
        Enabled = function()
            while AutoRebirth.Enabled do
                Rebirth()
                task.wait(0.2)
            end
        end,
    })
end