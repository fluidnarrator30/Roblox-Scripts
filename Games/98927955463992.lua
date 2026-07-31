local CloneRef = cloneref or function(Obj) return Obj end

local function GetService(Service)
    return CloneRef(game:GetService(Service))
end

local TidalWave = shared.TidalWave
local Categories = TidalWave.Categories
local CharacterLib = TidalWave.Libraries.CharacterLib
local ObjectFunctions = TidalWave.Libraries.ObjectFunctions

local Combat = Categories.Combat

local Players = GetService("Players")
local ReplicatedStorage = GetService("ReplicatedStorage")

local Plr = Players.LocalPlayer

local function Run(f)
    f()
end

Run(function() -- Combat
    Run(function() -- ProjectileAura
        local ProjectileAura, HitCooldown, AutoEquipGun, MaxDistance, Bullets, CachedGun

        local ZombiesLocal = workspace.Zombies_Local
        local GunHit = ReplicatedStorage.Remotes.GunRemotes.GunHit
        local Zombies = {}
        local HitZombies = {}

        local function GetZombieId(Zombie)
            return tonumber(Zombie.Name:match("%d+"))
        end

        local function GetClosestZombies()
            local ClosestZombies = {}
            local Clock = os.clock()
            for Zombie in Zombies do
                local TimeHit = HitZombies[Zombie]
                if TimeHit then
                    if Clock >= TimeHit then
                        HitZombies[Zombie] = nil
                    else
                        continue
                    end
                end
                local Root = Zombie:FindFirstChild("HumanoidRootPart")
                if not Root then continue end
                local Head = ObjectFunctions:FindFirstChildOfClassWithName(Zombie, "Part", "Head")
                if Head and Head.Transparency == 0 then
                    local Distance = (Root.Position - CharacterLib.Root.Position).Magnitude
                    if Distance <= MaxDistance.Value then
                        ClosestZombies[#ClosestZombies + 1] = {
                            Character = Zombie,
                            Root = Root,
                            Head = Head,
                            Distance = Distance
                        }
                    end
                end
            end

            table.sort(ClosestZombies, function(a, b)
                return a.Distance < b.Distance
            end)

            return ClosestZombies
        end

        ProjectileAura = Combat:CreateModule({
            Name = "ProjectileAura",
            Function = function(Enabled)
                if Enabled then
                    for _, Zombie in ZombiesLocal:GetChildren() do
                        Zombies[Zombie] = true
                    end

                    ProjectileAura:Clean(ZombiesLocal.ChildAdded:Connect(function(Zombie)
                        Zombies[Zombie] = true
                    end))
                    ProjectileAura:Clean(ZombiesLocal.ChildRemoved:Connect(function(Zombie)
                        Zombies[Zombie] = nil
                        HitZombies[Zombie] = nil
                    end))

                    local Tool

                    while ProjectileAura.Enabled do
                        if CharacterLib.Alive then
                            if AutoEquipGun.Enabled then
                                local Tool = Plr.Backpack:FindFirstChildOfClass('Tool')
                                if Tool then
                                    CharacterLib.Humanoid:EquipTool(Tool)
                                    task.wait()
                                end
                            end
                            
                            local Tool = CharacterLib.Character:FindFirstChildOfClass('Tool')

                            if Tool then
                                local ClosestZombies = GetClosestZombies()
                                if #ClosestZombies ~= 0 then
                                    local Index = 0

                                    for _, Zombie in ClosestZombies do
                                        Index += 1
                                        if Index > Bullets.Value then break end
                                        GunHit:FireServer(Tool.Name, GetZombieId(Zombie.Character), Zombie.Root.Position)
                                        HitZombies[Zombie.Character] = os.clock() + HitCooldown.Value
                                    end
                                end
                            end
                        end
                        task.wait()
                    end
                else
                    table.clear(Zombies)
                    table.clear(HitZombies)
                end
            end
        })

        HitCooldown = ProjectileAura:CreateSlider({
            Name = "Hit Cooldown",
            Default = 0.2,
            Min = 0,
            Max = 1,
            Decimal = 100,
            Function = function(Val)
                HitCooldown.Value = math.clamp(Val, 0, 1)
            end
        })

        AutoEquipGun = ProjectileAura:CreateToggle({
            Name = "Auto Equip Gun",
            Info = "Automatically equips your gun.",
            Default = true
        })

        MaxDistance = ProjectileAura:CreateSlider({
            Name = "Max Distance",
            Default = 130,
            Min = 1,
            Max = 130
        })

        Bullets = ProjectileAura:CreateSlider({
            Name = "Bullets",
            Default = 1,
            Min = 1,
            Max = 7
        })
    end)
end)
